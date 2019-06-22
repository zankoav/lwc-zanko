public class LFCreditScoringServiceDE implements LFCreditScoring {
    private Map<String, LongFormPage> pagesMap;
    private CFSearchResponse cfSearchResponse;
    private CFReportResponse cfReportResponse;
    private CreditFactoryReportController cfReportCtrl;
    private Decimal deposit;
    private CreditFactoryDecision cfDecision;
    private Account account;
    private Opportunity opportunity;
    private Contact contact;
    private String errorMessage;
    private Boolean isAuthorizatedGranted;
    private Boolean isNotAtBlackList;
    private String unavailableOptions;


    public LFCreditScoringServiceDE() {
    }


    /*******************************************************************************
    *  Name            : setPagesMap()
    *  Summary         : generate pages map for Step 1
    *  CreatedDate     : 30/01/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void setPagesMap(String deviceView) {
        E2E_Form_General_Settings__c settings = E2E_Form_General_Settings__c.getInstance('Germany');

        Map<Id, LongForm_Page__c> lfPagesMap = new Map<Id, LongForm_Page__c>([
            SELECT Name, Type__c, Long_Form__c
            FROM LongForm_Page__c
            WHERE Long_Form__r.Country__c = 'Germany' AND
                Name IN :creditScoreStepPagesSet AND
                Device_View__c = :deviceView AND
                Long_Form__r.Test_mode__c = :settings.Test_mode__c
            LIMIT 10000
        ]);

        List<LongForm_Element__c> elementsList = [
            SELECT Name, Long_Form_Page__r.Title__c, Long_Form_Page__r.System_Error__c, Long_Form_Page__r.Name, Type__c, (SELECT Name, Active__c, Type__c, Value__c FROM Long_Form_Element_Items__r)
            FROM LongForm_Element__c
            WHERE Long_Form_Page__c IN :lfPagesMap.keySet()
            LIMIT 10000
        ];

        pagesMap = new Map<String, LongFormPage>();
        Set<String> fieldTypes = new Set<String>{'Text Field', 'Picklist Field', 'Radio-button Field', 'Checkbox Field', 'Slider Field'};
        for (LongForm_Element__c element : elementsList) {
            if (! pagesMap.containsKey(element.Long_Form_Page__r.Name) ) {
                pagesMap.put(element.Long_Form_Page__r.Name, new LongFormPage());
                pagesMap.get(element.Long_Form_Page__r.Name).pageTitle = element.Long_Form_Page__r.Title__c;
                pagesMap.get(element.Long_Form_Page__r.Name).systemError = element.Long_Form_Page__r.System_Error__c;
                pagesMap.get(element.Long_Form_Page__r.Name).elements = new Map<String, Map<String, LongForm_Element_Item__c>>();
                pagesMap.get(element.Long_Form_Page__r.Name).fields = new Map<String, LongFormField>();
            }

            if (fieldTypes.contains(element.Type__c) && ! element.Long_Form_Element_Items__r.isEmpty()) {
                LongFormField field = new LongFormField();
                field.options = new List<SelectOption>();
                field.elementItemsMap = new Map<String, LongForm_Element_Item__c>();
                for (LongForm_Element_Item__c elementItem : element.Long_Form_Element_Items__r) {
                    if (elementItem.Type__c == 'Options') {
                        elementItem.Value__c = elementItem.Value__c.deleteWhitespace();
                        elementItem.Value__c = elementItem.Value__c.replaceAll('_', ' ');
                        List<String> optionsList = elementItem.Value__c.split(';');
                        for (String option : optionsList) {
                            field.options.add(new SelectOption(option.substringBefore('=>'), option.substringAfter('=>')));
                        }
                    }
                    field.elementItemsMap.put(elementItem.Name, elementItem);
                }
                pagesMap.get(element.Long_Form_Page__r.Name).fields.put(element.Name, field);
            } else {
                if (! pagesMap.get(element.Long_Form_Page__r.Name).elements.containsKey(element.Name) ) {
                    pagesMap.get(element.Long_Form_Page__r.Name).elements.put(element.Name, new Map<String, LongForm_Element_Item__c>());
                }
                for (LongForm_Element_Item__c elementItem : element.Long_Form_Element_Items__r) {
                    pagesMap.get(element.Long_Form_Page__r.Name).elements.get(element.Name).put(elementItem.Name, elementItem);
                }
            }
        }
    }


    /*******************************************************************************
    *  Name            : Map<String, LongFormPage> getPagesMap()
    *  Summary         : return all pages for Step 1
    *  CreatedDate     : 30/01/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Map<String, LongFormPage> pagesMap
    ******************************************************************************/
    public Map<String, LongFormPage> getPagesMap() {
        return pagesMap;
    }


    /*******************************************************************************
    *  Name            : updateOpportunityOnReturnFromEmail(String deviceView)
    *  Summary         : Update Opportunity fields on return from marketing email
    *  CreatedDate     : 08/08/2018
    *  ModifiedDate    : 08/11/2018 by Eugene: do not update fields if opportunity has closed status
    *  Parameters      : String deviceView
    *  Returns         : void
    ******************************************************************************/
    public void updateOpportunityOnReturnFromEmail(String deviceView) {
        if (this.opportunity != null && (this.opportunity.StageName == 'Closed Won' || this.opportunity.StageName == 'Closed Lost' || this.opportunity.StageName == 'Pending Sales – Deposit')) {
            // do not update fields if opportunity has closed status
            return;
        }        

        this.opportunity.E2E_Status__c = 'In progress';
        this.opportunity.E2E_Sub_Status__c = '';
        
        List<User> e2eUser = [SELECT Id FROM User WHERE Name = 'E2E Site Guest User' LIMIT 1];
        if ( ! e2eUser.isEmpty() ) {
            this.opportunity.OwnerId = e2eUser.get(0).Id;

            List<Tankkarten__c> cardsList = [SELECT OwnerId FROM Tankkarten__c WHERE Opportunity__c = :this.opportunity.Id];
            List<Tankkarten__c> cardsToUpdateList = new List<Tankkarten__c>();
            for (Tankkarten__c card : cardsList) {
                if (card.OwnerId != e2eUser.get(0).Id) {
                    card.OwnerId = e2eUser.get(0).Id;
                    cardsToUpdateList.add(card);
                }                
            }
            if ( ! cardsToUpdateList.isEmpty() ) {
                update cardsToUpdateList;
            }
           
        }
        this.opportunity.Last_E2E_Error__c = null;
        this.opportunity.Device_Type__c = deviceView;
        this.opportunity.E2E_Last_Activity__c = Datetime.now();
        if (this.opportunity.E2E_Form_Type__c != null && ! this.opportunity.E2E_Form_Type__c.contains(deviceView)) {
            this.opportunity.E2E_Form_Type__c += ';' + deviceView;
        } else if (this.opportunity.E2E_Form_Type__c == null) {
            this.opportunity.E2E_Form_Type__c = deviceView;
        }
        update this.opportunity;
        EmarsysSenderEuropeanService.sendE2EOpportunityToEmarsys(opportunity.Id);
    }


    /*******************************************************************************
    *  Name            : validateFields(String substep)
    *  Summary         : field validation on step 1
    *  CreatedDate     : 31/01/2018
    *  ModifiedDate    : -
    *  Parameters      : String substep
    *  Returns         : void
    ******************************************************************************/
    public void validateFields(String substep) {
        errorMessage = '';
        if (substep == 'company details') {
            validateCompanyName();
            validateCity();
        } else if (substep == 'Set total consumption') {
            validateTotalConsumption();
        }
        if (errorMessage != '') throw new LongFormException(errorMessage);
    }


    /*******************************************************************************
    *  Name            : saveCompanyDetails()
    *  Summary         : update company details
    *  CreatedDate     : 18/04/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void saveCompanyDetails() {
        String companyName = (pagesMap.get('CREDIT SCORE. SEARCH COMPANY').fields.get('COMPANY NAME').elementItemsMap.get('DEFAULT VALUE').Value__c).toUpperCase();
        String city = pagesMap.get('CREDIT SCORE. SEARCH COMPANY').fields.get('CITY').elementItemsMap.get('DEFAULT VALUE').Value__c;
        if (this.account.Name != companyName || this.opportunity.Name != companyName ||
                this.account.BillingCity != city || this.account.ShippingCity != city) {
            city = city.toUpperCase();
            this.account.Name = companyName;
            this.account.BillingPostalCode = '';
            this.account.BillingCity = city;
            this.account.BillingStreet = '';
            this.account.ShippingPostalCode = '';
            this.account.ShippingCity = city;
            this.account.ShippingStreet = '';
            //update account
            update this.account;
            String ipAddress = LongFormGlobalUtils.getUserIPAddress();
            this.opportunity.Name = companyName;
            this.opportunity.E2E_Active_Step__c = 1;
            this.opportunity.E2E_Active_Substep__c = 'Search company';
            this.opportunity.E2E_Last_Activity__c = Datetime.now();
            this.opportunity.Visitor_ID__c = ipAddress;
            this.opportunity.E2E_Status__c = 'In progress';
            this.opportunity.E2E_Sub_Status__c = '';
            List<User> e2eUser = [SELECT Id FROM User WHERE Name = 'E2E Site Guest User' LIMIT 1];
            if ( ! e2eUser.isEmpty() ) {
                this.opportunity.OwnerId = e2eUser.get(0).Id;
            }   
            //update opportunity
            update this.opportunity;
            EmarsysSenderEuropeanService.sendE2EOpportunityToEmarsys(opportunity.Id);
        }
    }


    /*******************************************************************************
    *  Name            : saveTotalConsumption()
    *  Summary         : save total consumption value to SF database
    *  CreatedDate     : 18/04/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void saveTotalConsumption() {
        String totalConsumption = pagesMap.get('CREDIT SCORE. TOTAL CONSUMPTION').fields.get('TOTAL CONSUMPTION').elementItemsMap.get('DEFAULT VALUE').Value__c;
        this.opportunity.Gasoline_consumption_l_month__c = 0;
        this.opportunity.Diesel_consumption_l_month__c = Decimal.valueOf(totalConsumption);
        this.opportunity.Total_consumption_l_month__c = Decimal.valueOf(totalConsumption);
        this.opportunity.E2E_Last_Activity__c = Datetime.now();
        this.opportunity.E2E_Active_Step__c = 1;
        this.opportunity.E2E_Active_Substep__c = 'Calculating credit score';
        this.opportunity.Rechnungsperiode__c = null;
        if (this.opportunity.Suggested_Total_Consumption__c == null) {
            E2E_Consumption_per_Card__c consumptionPerCard = E2E_Consumption_per_Card__c.getInstance(this.Account.BillingCountry);
            if (consumptionPerCard != null && consumptionPerCard.Consumption__c != null && opportunity.Anzahl_der_Karten__c != null) {
                this.opportunity.Suggested_Total_Consumption__c = consumptionPerCard.Consumption__c * opportunity.Anzahl_der_Karten__c;
            } 
        }
        this.opportunity.E2E_Status__c = 'In progress';
        this.opportunity.E2E_Sub_Status__c = '';
        List<User> e2eUser = [SELECT Id FROM User WHERE Name = 'E2E Site Guest User' LIMIT 1];
        if ( ! e2eUser.isEmpty() ) {
            this.opportunity.OwnerId = e2eUser.get(0).Id;
        }    
        //update opportunity
        update this.opportunity;
        EmarsysSenderEuropeanService.sendE2EOpportunityToEmarsys(opportunity.Id);
    }


    /*******************************************************************************
    *  Name            : doGenerateCreditFactoryReport(String selectedCompanyId)
    *  Summary         : saving credit factory report to SF
    *  CreatedDate     : 05/03/2018
    *  ModifiedDate    : -
    *  Parameters      : String selectedCompanyId
    *  Returns         : void
    ******************************************************************************/
    public void doGenerateCreditFactoryReport(String selectedCompanyId) {    
        //set creditreform report service and account/opportunity mapping from custom settings
        this.cfReportCtrl = new CreditFactoryReportController();
        this.cfReportCtrl.creditService = new CreditSystemService();
        this.cfReportCtrl.creditService.setCreditSystemSource(opportunity.Id);
        String creditSystemName = this.cfReportCtrl.creditService.getCreditSystemName();
        this.cfReportCtrl.reportService = this.cfReportCtrl.returnReportService(creditSystemName, opportunity.Id);
        this.cfReportCtrl.reportService.setUserSource('E2E Long Form');
        this.cfReportCtrl.reportService.setMapping();
        //set opportunity record
        this.cfReportCtrl.reportService.setSourceObject(opportunity.Id);
        //get credit report from SF if exists
        this.cfReportCtrl.reportService.setExistingCreditReports();
        //send request, get company and employees
        this.cfReportCtrl.reportService.setCompany(this.cfReportCtrl.creditService, selectedCompanyId);
        this.cfReportCtrl.company = (CreditCompany)this.cfReportCtrl.reportService.getCompany();
        this.cfReportCtrl.reportService.setEmployees();
        if (this.cfReportCtrl.reportService.getErrorToOrderRequest() != null) {
            throw new LongFormException(E2EExceptionUtils.errorsMap.get('Report does not exist'));
        }
        doCheckAuthorizatedGranted();
        this.cfReportCtrl.isSales = this.cfReportCtrl.reportService.isSales();
        this.cfReportCtrl.calculateBillingPeriod();
        //create PDF Report
        Boolean isPdfCreated = this.cfReportCtrl.reportService.doCreateReportAttachment(opportunity.Id);
        if (isPdfCreated) {
            this.cfReportCtrl.reportService.updateOpportunityWithPDF(opportunity);
        }
        this.cfReportCtrl.reportService.saveReports();    
    }


    /*******************************************************************************
    *  Name            : calculateCreditFactoryReports()
    *  Summary         : Calculate credit factory reports
    *  CreatedDate     : 12/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void calculateCreditFactoryReports() {
        if (this.opportunity.E2E_CF_Reports_Counter__c == null) {
            this.opportunity.E2E_CF_Reports_Counter__c = 1;
        } else {
            this.opportunity.E2E_CF_Reports_Counter__c = this.opportunity.E2E_CF_Reports_Counter__c + 1;
        }
    }


    /*******************************************************************************
    *  Name            : deleteCreditFactoryReports(String identificationnumber)
    *  Summary         : Delete reports from database
    *  CreatedDate     : 30/09/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void deleteCreditFactoryReports(String identificationnumber) {
        List<Credit_Factory_Report__c> creditReport = [
                SELECT Company_Id__c, Opportunity__r.E2E_CF_Reports_Counter__c
                FROM Credit_Factory_Report__c 
                WHERE Opportunity__c = :this.opportunity.Id
                LIMIT 1];
        Boolean isTheSameCompany = false;
        if ( ! creditReport.isEmpty() && identificationnumber == creditReport.get(0).Company_Id__c) {
            isTheSameCompany = true;
        }

        if ( ! isTheSameCompany ) {
            if (! creditReport.isEmpty() && creditReport.get(0).Opportunity__r.E2E_CF_Reports_Counter__c < 2) {
                // delete credit factory report and attachment
                if (! creditReport.isEmpty()) delete creditReport;

                List<Attachment> attachsList = [
                    SELECT Name
                    FROM Attachment
                    WHERE ParentId = :opportunity.Id AND Name = 'CrefoReport.pdf'
                    LIMIT 1];
                if (! attachsList.isEmpty()) delete attachsList.get(0);
     
                //zeroing tax id value in account
                this.account.Steuernummer__c = null;
                update this.account;
            }

            calculateCreditFactoryReports();         
        }
    }    


    /*******************************************************************************
    *  Name            : getCreditScoreData(String selectedCompanyId)
    *  Summary         : get credit score data
    *  CreatedDate     : 08/06/2018
    *  ModifiedDate    : -
    *  Parameters      : String selectedCompanyId
    *  Returns         : void
    ******************************************************************************/
    public void getCreditScoreData(String selectedCompanyId) {
        //set creditreform report service and account/opportunity mapping from custom settings
        this.cfReportCtrl = new CreditFactoryReportController();
        this.cfReportCtrl.creditService = new CreditSystemService();
        this.cfReportCtrl.creditService.setCreditSystemSource(opportunity.Id);
        String creditSystemName = this.cfReportCtrl.creditService.getCreditSystemName();
        this.cfReportCtrl.reportService = this.cfReportCtrl.returnReportService(creditSystemName, opportunity.Id);
        this.cfReportCtrl.reportService.setUserSource('E2E Long Form');
        this.cfReportCtrl.reportService.setMapping();
        //set opportunity record
        this.cfReportCtrl.reportService.setSourceObject(opportunity.Id);
        //get credit report from SF if exists
        this.cfReportCtrl.reportService.setExistingCreditReports();
        //send request, get company and employees
        this.cfReportCtrl.reportService.setCompany(this.cfReportCtrl.creditService, selectedCompanyId);
        this.cfReportCtrl.company = (CreditCompany)this.cfReportCtrl.reportService.getCompany();
        this.cfReportCtrl.isSales = this.cfReportCtrl.reportService.isSales();
        this.cfReportCtrl.calculateBillingPeriod();
        this.cfDecision = this.cfReportCtrl.reportService.getDecision();
        //update credit report with credit score data
        this.cfReportCtrl.reportService.saveReports();
    }


    /*******************************************************************************
    *  Name            : doCheckAuthorizatedGranted
    *  Summary         : do check authorizated granted
    *  CreatedDate     : 25/04/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doCheckAuthorizatedGranted() {
        this.isAuthorizatedGranted = this.cfReportCtrl.reportService.validateContact();
    }


    /*******************************************************************************
    *  Name            : getResultOfCheckAuthorizatedGranted()
    *  Summary         : get result of check authorizated granted
    *  CreatedDate     : 25/04/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Boolean
    ******************************************************************************/
    public Boolean getResultOfCheckAuthorizatedGranted() {
        return this.isAuthorizatedGranted;
    }


    /*******************************************************************************
    *  Name            : doCheckBlackList()
    *  Summary         : сheck whether the company is in a black list
    *  CreatedDate     : 11/06/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doCheckBlackList() {
        this.isNotAtBlackList = this.cfReportCtrl.reportService.validateBlackList();
    }


    /*******************************************************************************
    *  Name            : setResultOfCheckBlackList()
    *  Summary         : set result of check black list
    *  CreatedDate     : 16/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void setResultOfCheckBlackList() {
        //set creditreform report service and account/opportunity mapping from custom settings
        this.cfReportCtrl = new CreditFactoryReportController();
        this.cfReportCtrl.creditService = new CreditSystemService();
        this.cfReportCtrl.creditService.setCreditSystemSource(opportunity.Id);
        String creditSystemName = this.cfReportCtrl.creditService.getCreditSystemName();
        this.cfReportCtrl.reportService = this.cfReportCtrl.returnReportService(creditSystemName, opportunity.Id);
        this.cfReportCtrl.reportService.setUserSource('E2E Long Form');
        this.cfReportCtrl.reportService.setMapping();
        //set opportunity record
        this.cfReportCtrl.reportService.setSourceObject(opportunity.Id);
        doCheckBlackList();
    }


    /*******************************************************************************
    *  Name            : getResultOfCheckBlackList()
    *  Summary         : get result of check black list
    *  CreatedDate     : 11/06/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Boolean isNotAtBlackList
    ******************************************************************************/
    public Boolean getResultOfCheckBlackList() {
        return this.isNotAtBlackList;
    }


    /*******************************************************************************
    *  Name            : resetCfDecision(Integer defaultBillingPeriod, Integer defaultPaymentTerms, Decimal depositValue, String classRating)
    *  Summary         : reset decision
    *  CreatedDate     : 05/03/2018
    *  ModifiedDate    : 22/12/2018
    *  Parameters      : Integer defaultBillingPeriod, Integer defaultPaymentTerms, Decimal depositValue, String classRating, CreditCompany company
    *  Returns         : void
    ******************************************************************************/
    public void resetCfDecision(Integer defaultBillingPeriod, Integer defaultPaymentTerms, Decimal depositValue, String classRating, CreditCompany company) {
        if (this.cfReportCtrl == null) {
            this.cfReportCtrl = new CreditFactoryReportController();
            this.cfReportCtrl.creditService = new CreditSystemService();
            this.cfReportCtrl.creditService.setCreditSystemSource(opportunity.Id);
            String creditSystemName = this.cfReportCtrl.creditService.getCreditSystemName();
            this.cfReportCtrl.reportService = this.cfReportCtrl.returnReportService(creditSystemName, opportunity.Id);
        }
        this.cfReportCtrl.reportService.resetDecision(defaultBillingPeriod, defaultPaymentTerms, depositValue, classRating, opportunity.Anzahl_der_Karten__c, company);
        this.cfDecision = this.cfReportCtrl.reportService.getDecision();
    }


    /*******************************************************************************
    *  Name            : getCfDecision()
    *  Summary         : return credit score decision
    *  CreatedDate     : 05/03/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : CreditFactoryDecision cfDecision
    ******************************************************************************/
    public CreditFactoryDecision getCfDecision() {
        return this.cfDecision;
    }


    /*******************************************************************************
    *  Name            : setDeposit(CreditCompany company, Integer defaultBillingPeriod, Integer defaultPaymentTerms, Decimal creditLimit, Decimal maxCreditLimit)
    *  Summary         : do recalculate deposit
    *  CreatedDate     : 05/03/2018
    *  ModifiedDate    : -
    *  Parameters      : CreditCompany company, Integer defaultBillingPeriod, Decimal creditLimit, Decimal maxCreditLimit
    *  Returns         : void
    ******************************************************************************/
    public void setDeposit(CreditCompany company, Integer defaultBillingPeriod, Integer defaultPaymentTerms, Decimal creditLimit, Decimal maxCreditLimit) {
        this.cfReportCtrl = new CreditFactoryReportController();
        this.cfReportCtrl.creditService = new CreditSystemService();
        this.cfReportCtrl.creditService.setCreditSystemSource(opportunity.Id);
        String creditSystemName = this.cfReportCtrl.creditService.getCreditSystemName();
        this.cfReportCtrl.reportService = this.cfReportCtrl.returnReportService(creditSystemName, opportunity.Id);
        this.cfReportCtrl.reportService.resetDeposit(company, defaultBillingPeriod, defaultPaymentTerms, creditLimit, maxCreditLimit, this.opportunity.Auftragsvolumen__c,
                                                     this.opportunity.Total_consumption_l_month__c, this.opportunity.Id);
        this.deposit = this.cfReportCtrl.reportService.getDeposit();
    }


    /*******************************************************************************
    *  Name            : getDeposit()
    *  Summary         : return calculated deposit
    *  CreatedDate     : 05/03/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Decimal calculated deposit
    ******************************************************************************/
    public Decimal getDeposit() {
        return this.deposit;
    }


    /*******************************************************************************
    *  Name            : searchDuplicates()
    *  Summary         : search duplicate contact
    *  CreatedDate     : 16/02/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public String searchDuplicates(CreditCompany selectedCompany) {
        String taxId = selectedCompany.taxnumber;
        if (String.isEmpty(taxId)) {
            taxId = null;
        } else {
            taxId = taxId.replaceAll('[^0-9a-zA-z]', '');
        }
        String vatid = selectedCompany.vatid;
        String streetUpper = selectedCompany.street != null ? selectedCompany.street.toUpperCase() : '';
        String housenumberUpper = selectedCompany.housenumber != null ? selectedCompany.housenumber.toUpperCase() : '';
        String cityUpper = selectedCompany.city != null ? selectedCompany.city.toUpperCase() : '';
        String companyName = String.escapeSingleQuotes(selectedCompany.Name);
        String accountDupsQuery = 'SELECT OwnerId, Owner.FirstName, Owner.LastName, Owner.Email, Steuernummer__c, Name, ' +
                       ' (SELECT StageName, CloseDate, Gruende_verloren__c, Owner.Email, ' +
                               ' Owner.FirstName, Owner.LastName, E2E_Active_Step__c, Name  ' +
                        ' FROM Opportunities ' +
                        ' WHERE Id != \'' + opportunity.Id + '\'' +
                        ' ORDER BY CreatedDate DESC ' +
                        ' LIMIT 100) ' +
                ' FROM Account  ' +
                ' WHERE ';
        if ( ! String.isEmpty(taxId) && taxId != 'unbekannt' && taxId != 'nicht bekannt' && taxId != '0') {
            accountDupsQuery += '(';
        }
        accountDupsQuery += '(Name = \'' + companyName + '\' ';

        if ( ! String.isEmpty(taxId) && taxId != 'unbekannt' && taxId != 'nicht bekannt' && taxId != '0') {
            accountDupsQuery += ' AND Steuernummer__c = \'' + taxId + '\') ';
        }
        if (vatid != null && vatid != '') {
            accountDupsQuery += ' OR Umsatzsteuer_ID__c = \'' + vatid + '\' ';
        }
        accountDupsQuery += ') AND Id != \'' + account.Id + '\' AND BillingCountry = \'Germany\'' +
                ' ORDER BY CreatedDate DESC ' +
                ' LIMIT 1';
        List<Account> accountsDupsList = Database.query(accountDupsQuery);

        if ( ! accountsDupsList.isEmpty() && accountsDupsList.get(0).Steuernummer__c == taxId) {
            // Contact
            this.contact.AccountId = accountsDupsList.get(0).Id;
            update this.contact;

            // Opportunity
            Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EForm').AES256_Key__c);
            String stringToEncode = opportunity.Id + '-' + opportunity.E2E_Active_Step__c;
            String encodedStringUrl = E2EFormEncryption.getHashAlgorithAES256(key256AES, stringToEncode);
            this.opportunity.E2E_Encoded_URL__c = encodedStringUrl;
            this.opportunity.AccountId = accountsDupsList.get(0).Id;
            this.opportunity.Name = selectedCompany.Name;
            update this.opportunity;
            EmarsysSenderEuropeanService.sendE2EOpportunityToEmarsys(opportunity.Id);

            // Account
            Account accountToDelete = this.account;
            // Delete old Account
            if (accountToDelete != null) {
                delete accountToDelete;
            }

            // Update duplicate and set as main account
            accountsDupsList.get(0).Name = selectedCompany.Name.toUpperCase();
            accountsDupsList.get(0).Steuernummer__c = taxId;
            accountsDupsList.get(0).BillingStreet = streetUpper + ' ' + housenumberUpper;
            accountsDupsList.get(0).BillingCity = cityUpper;
            update accountsDupsList.get(0);
            setAccount(accountsDupsList.get(0).Id);

            String exceptionMessage;
            if ( ! accountsDupsList.get(0).Opportunities.isEmpty() ) {
                Map<String, Opportunity> duplicateCaseMap = new Map<String, Opportunity>();
                String oldStage = this.opportunity.StageName;
                for (Opportunity existingOpportunity : accountsDupsList.get(0).Opportunities) {
                    if (existingOpportunity.StageName == 'Closed Won') {
                        duplicateCaseMap.put('case1', existingOpportunity);
                    } else
                    if (existingOpportunity.StageName == 'CreditCheck' ||
                        existingOpportunity.StageName == 'Pending Sales – Information' ||
                        existingOpportunity.StageName == 'Pending Sales – Deposit' ||
                        existingOpportunity.StageName == 'Pending Credit' ||
                        existingOpportunity.StageName == 'Pending Sales - SEPA Confirmation' ||
                        (existingOpportunity.StageName == 'Closed Lost' && existingOpportunity.Gruende_verloren__c == 'Refused Credit' &&
                         existingOpportunity.CloseDate.daysBetween(Date.today()) < 90) ||
                         existingOpportunity.StageName == 'CreditCheck abgelehnt' && existingOpportunity.CloseDate.daysBetween(Date.today()) < 90) {
                        duplicateCaseMap.put('case2', existingOpportunity);
                    } else
                    if (existingOpportunity.StageName == 'Prospecting' || existingOpportunity.StageName == 'Credit approved') {
                        duplicateCaseMap.put('case5', existingOpportunity);
                    } else
                    if (existingOpportunity.StageName == 'Closed Lost' && existingOpportunity.Gruende_verloren__c == 'Refused Credit' &&
                         existingOpportunity.CloseDate.daysBetween(Date.today()) >= 90) {
                        duplicateCaseMap.put('case3', existingOpportunity);
                    } else
                    if (existingOpportunity.StageName == 'CreditCheck abgelehnt' && existingOpportunity.CloseDate.daysBetween(Date.today()) >= 90) {
                        duplicateCaseMap.put('case4', existingOpportunity);
                    }
                }

                if (duplicateCaseMap.containsKey('case1')) {
                    exceptionMessage = doDuplicateCase1(duplicateCaseMap.get('case1'), oldStage);
                } else
                if (duplicateCaseMap.containsKey('case2')) {
                    exceptionMessage = doDuplicateCase2(duplicateCaseMap.get('case2'));
                } else
                if (duplicateCaseMap.containsKey('case3')) {
                    exceptionMessage = doDuplicateCase3(duplicateCaseMap.get('case3'));
                } else
                if (duplicateCaseMap.containsKey('case4')) {
                    exceptionMessage = doDuplicateCase4(duplicateCaseMap.get('case4'), oldStage);
                } else
                if (duplicateCaseMap.containsKey('case5')) {
                    exceptionMessage = doDuplicateCase5(duplicateCaseMap.get('case5'), oldStage);
                }
            }
            if (exceptionMessage != null) {
                return exceptionMessage;
            }
        }

        return null;
    }


    private String doDuplicateCase1(Opportunity existingOpportunity, String oldStage) {
        E2E_Form_General_Settings__c settings = E2E_Form_General_Settings__c.getInstance('Germany');
        if (settings != null && settings.Abandonment_User__c != null) {
            this.opportunity.OwnerId = settings.Abandonment_User__c;
            update this.opportunity;
            EmarsysSenderEuropeanService.sendE2EOpportunityToEmarsys(opportunity.Id);
        }        
        String body = LFCreditScoringUtils.generateBodyForStartsPushEmail6(existingOpportunity, this.opportunity, oldStage);
        Starts_Settings__c startsSetting = Starts_Settings__c.getInstance('Germany');
        if (startsSetting != null && startsSetting.Notifications_Email__c != null) {
            LFCreditScoringUtils.sendSingleEmail(existingOpportunity, body, startsSetting.Notifications_Email__c);
        }
        return 'Already a customer';
    }


    private String doDuplicateCase2(Opportunity existingOpportunity) {
        // Set E2E Opportunity as duplicate
        this.opportunity.StageName = 'Closed Lost';
        this.opportunity.Gruende_verloren__c = 'Duplicate';

        update this.opportunity;
        EmarsysSenderEuropeanService.sendE2EOpportunityToEmarsys(opportunity.Id);

        // Make E2E Opportunity as main
        Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EForm').AES256_Key__c);
        String stringToEncodeCurrentOpp = existingOpportunity.Id + '-' + existingOpportunity.E2E_Active_Step__c;
        String encodedStringUrlCurrentOpp = E2EFormEncryption.getHashAlgorithAES256(key256AES, stringToEncodeCurrentOpp);
        existingOpportunity.E2E_Encoded_URL__c = encodedStringUrlCurrentOpp;
        update existingOpportunity;
        EmarsysSenderEuropeanService.sendE2EOpportunityToEmarsys(opportunity.Id);
        OpportunityContactRole role = new OpportunityContactRole(
            OpportunityId = existingOpportunity.Id,
            ContactId = contact.Id);
        insert role;
        setOpportunity(existingOpportunity.Id);

        // Email #5 notification
        String body = LFCreditScoringUtils.generateBodyForSalesPushEmail5(existingOpportunity);
        LFCreditScoringUtils.sendSingleEmail(existingOpportunity, body, existingOpportunity.Owner.Email);

        return 'Already in process';
    }


    private String doDuplicateCase3(Opportunity existingOpportunity) {
        // Email #3 notification
        String body = LFCreditScoringUtils.generateBodyForCreditDepartmentPush(existingOpportunity, this.opportunity);
        User user = [SELECT Email FROM User WHERE Name = 'Credit' LIMIT 1];
        LFCreditScoringUtils.sendSingleEmail(opportunity, body, user.Email);

        return null;
    }

    private String doDuplicateCase4(Opportunity existingOpportunity, String oldStage) {
        // Close current Opportunity
        existingOpportunity.StageName = 'Closed Lost';
        existingOpportunity.Gruende_verloren__c = 'Switched to E2E';
        existingOpportunity.E2E_Status__c = 'Finished';

        update existingOpportunity;
        EmarsysSenderEuropeanService.sendE2EOpportunityToEmarsys(opportunity.Id);

        // Email #3 notification
        String body = LFCreditScoringUtils.generateBodyForCreditDepartmentPush(existingOpportunity, this.opportunity);
        User user = [SELECT Email FROM User WHERE Name = 'Credit' LIMIT 1];
        LFCreditScoringUtils.sendSingleEmail(opportunity, body, user.Email);

        // Email #4 notification
        String body2 = LFCreditScoringUtils.generateBodyForSalesPushEmail4(existingOpportunity, opportunity, oldStage);
        LFCreditScoringUtils.sendSingleEmail(existingOpportunity, body2, existingOpportunity.Owner.Email);

        return null;
    }


    private String doDuplicateCase5(Opportunity existingOpportunity, String oldStage) {
        // Close current Opportunity
        existingOpportunity.StageName = 'Closed Lost';
        existingOpportunity.Gruende_verloren__c = 'Switched to E2E';
        existingOpportunity.E2E_Status__c = 'Finished';

        update existingOpportunity;
        EmarsysSenderEuropeanService.sendE2EOpportunityToEmarsys(opportunity.Id);

        // Email #4 notification
        String body = LFCreditScoringUtils.generateBodyForSalesPushEmail4(existingOpportunity, this.opportunity, oldStage);
        LFCreditScoringUtils.sendSingleEmail(existingOpportunity, body, existingOpportunity.Owner.Email);

        return null;
    }


    /*******************************************************************************
    *  Name            : doUpdateSFobjects(CFReportResponse reportResponse)
    *  Summary         : updating objects with company data from a credit factory
    *  CreatedDate     : 01/03/2018
    *  ModifiedDate    : -
    *  Parameters      : CFReportResponse reportResponse
    *  Returns         : void
    ******************************************************************************/
    public void doUpdateSFobjects(CFReportResponse reportResponse) {
        Boolean isError = false;
        String errorMsg = '';
        account.Name = (reportResponse.company.name).touppercase();
        String streetUpper = reportResponse.company.street != null ? reportResponse.company.street.toUpperCase() : '';
        String housenumberUpper = reportResponse.company.housenumber != null ? reportResponse.company.housenumber.toUpperCase() : '';
        String cityUpper = reportResponse.company.city != null ? reportResponse.company.city.toUpperCase() : '';

        account.BillingStreet = streetUpper + ' ' + housenumberUpper;
        account.BillingPostalCode = reportResponse.company.postcode;
        account.BillingCity = cityUpper;
        account.ShippingCountry = 'Germany';
        account.ShippingStreet = streetUpper + ' ' + housenumberUpper;
        account.ShippingPostalCode = reportResponse.company.postcode;
        account.ShippingCity = cityUpper;
        account.Gesellschaftsform__c = reportResponse.company.legalform;
        account.Umsatzsteuer_ID__c = reportResponse.company.vatid;
        if (reportResponse.company.taxnumber != null) account.Steuernummer__c = reportResponse.company.taxnumber;   
        //update account
        Database.SaveResult accUpdateResult = Database.update(account, false);
        if (! accUpdateResult.isSuccess() ) {
            isError = true;
            for(Database.Error err : accUpdateResult.getErrors()) {
                errorMsg += err.getMessage();
            }
        }

        String ipAddress = LongFormGlobalUtils.getUserIPAddress();
        opportunity.Name = (reportResponse.company.name).touppercase();
        opportunity.StageName = 'Prospecting';
        if (reportResponse.company.staffcompanyrange != null) {
            opportunity.Zahl_der_Mitarbeiter__c = reportResponse.company.staffcompanyrange;
        } else {
            opportunity.Zahl_der_Mitarbeiter__c = String.valueOf(reportResponse.companyEmployees.size());
        }
        opportunity.E2E_Active_Step__c = 1;
        if (reportResponse.company.taxnumber == null && reportResponse.company.vatid == null && this.account.Steuernummer__c == null) {
            opportunity.E2E_Active_Substep__c = 'Enter Tax ID';
        } else {
            opportunity.E2E_Active_Substep__c = 'Set total consumption';
        }
        opportunity.E2E_Last_Activity__c = Datetime.now();
        opportunity.Visitor_ID__c = ipAddress;
        opportunity.E2E_Status__c = 'In progress';
        opportunity.E2E_Sub_Status__c = '';
        List<User> e2eUser = [SELECT Id FROM User WHERE Name = 'E2E Site Guest User' LIMIT 1];
        if ( ! e2eUser.isEmpty() ) {
            opportunity.OwnerId = e2eUser.get(0).Id;
        }
        Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EForm').AES256_Key__c);
        String stringToEncode = opportunity.Id + '-' + opportunity.E2E_Active_Step__c;
        String encodedStringUrl = E2EFormEncryption.getHashAlgorithAES256(key256AES, stringToEncode);
        opportunity.E2E_Encoded_URL__c = encodedStringUrl;
        //update opportunity
        Database.SaveResult opptyUpdateResult = Database.update(opportunity, false);
        if (! opptyUpdateResult.isSuccess() ) {
            isError = true;
            for(Database.Error err : opptyUpdateResult.getErrors()) {
                errorMsg += err.getMessage();
            }
        }
        EmarsysSenderEuropeanService.sendE2EOpportunityToEmarsys(opportunity.Id);

        contact.MailingStreet = streetUpper + ' ' + housenumberUpper;
        contact.MailingPostalCode = reportResponse.company.postcode;
        contact.MailingCity = cityUpper;
        //update contact
        Database.SaveResult conUpdateResult = Database.update(contact, false);
        if (! conUpdateResult.isSuccess() ) {
            isError = true;
            for(Database.Error err : conUpdateResult.getErrors()) {
                errorMsg += err.getMessage();
            }
        }
        if (isError) {
            throw new LongFormException(errorMsg);
        }
    }
    

    /*******************************************************************************
    *  Name            : goToSetVatNumberStep()
    *  Summary         : go to set vat number step    
    *  CreatedDate     : 26/12/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void goToSetVatNumberStep() {
        // this.opportunity.E2E_Active_Step__c = 1;
        // this.opportunity.E2E_Active_Substep__c = 'Enter VAT Number';
        // update this.opportunity;
    }


    /*******************************************************************************
    *  Name            : validateVatId()
    *  Summary         : Validate vat id for format and valid value (API call)
    *  CreatedDate     : 24/12/2018
    *  ModifiedDate    :
    *  Parameters      : -
    *  Returns         : Boolean isVatIdValid
    ******************************************************************************/
    public Boolean validateVatId() {
        // String vatid = this.pagesMap.get('CREDIT SCORE. INPUT VAT ID').fields.get('VAT NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c;
        // if (vatid == null || vatid.substring(0, 2) != 'NL' || vatid.length() != 14) {
        //     return false;
        // }
        // EcEuropaEu.CheckVatPort checker = new EcEuropaEu.CheckVatPort();
        // EcEuropaEu.CheckVatResponse_element result = checker.checkVat('NL', vatid.substring(2, 14));
        // if (result != null && result.valid != null && ! result.valid) {
        //     return false;
        // }
        return true;
    }


    /*******************************************************************************
    *  Name            : doUpdateVatNumber()
    *  Summary         : Update account vat number
    *  CreatedDate     : 24/12/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doUpdateVatNumber() {
        // String vatid = this.pagesMap.get('CREDIT SCORE. INPUT VAT ID').fields.get('VAT NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c;
        // this.account.Umsatzsteuer_ID__c = vatid;
        // update this.account;

        // this.opportunity.E2E_Active_Step__c = 1;
        // this.opportunity.E2E_Active_Substep__c = 'Set total consumption';
        // update this.opportunity;
        // EmarsysSenderEuropeanService.sendE2EOpportunityToEmarsys(this.opportunity.Id);
    }


    /*******************************************************************************
    *  Name            : doUpdateTaxId(String taxId)
    *  Summary         : do update tax id in account
    *  CreatedDate     : 11/07/2018
    *  ModifiedDate    : -
    *  Parameters      : String taxId
    *  Returns         : void
    ******************************************************************************/
    public void doUpdateTaxId(String taxId) {
        validateTaxId(taxId);
        this.account.Steuernummer__c = taxId;
        update this.account;

        this.opportunity.E2E_Active_Step__c = 1;
        this.opportunity.E2E_Active_Substep__c = 'Set total consumption';
        this.opportunity.E2E_Status__c = 'In progress';
        this.opportunity.E2E_Sub_Status__c = '';
        List<User> e2eUser = [SELECT Id FROM User WHERE Name = 'E2E Site Guest User' LIMIT 1];
        if ( ! e2eUser.isEmpty() ) {
            this.opportunity.OwnerId = e2eUser.get(0).Id;
        }
        update this.opportunity;
        EmarsysSenderEuropeanService.sendE2EOpportunityToEmarsys(opportunity.Id);
    }


    /*******************************************************************************
    *  Name            : setUnavailableOptions(String verdict, String statusCode)
    *  Summary         : set unavailable options
    *  CreatedDate     : 27/04/2018
    *  ModifiedDate    : -
    *  Parameters      : String verdict, String statusCode
    *  Returns         : void
    ******************************************************************************/
    public void setUnavailableOptions(String verdict, String statusCode) {
        if (verdict == 'Yes') {
            if (statusCode == '004' || statusCode == '005' || statusCode == '008') {
                this.unavailableOptions = 'Bank Transfer & Inbound Typ C';
            } else if (statusCode == '006') {
                this.unavailableOptions = 'Bank Transfer';
            } else {
                this.unavailableOptions = '';
            }
        }
    }


    /*******************************************************************************
    *  Name            : getUnavailableOptions()
    *  Summary         : get unavailable options
    *  CreatedDate     : 27/04/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : String unavailableOptions
    ******************************************************************************/
    public String getUnavailableOptions() {
        return this.unavailableOptions;
    }


    /*******************************************************************************
    *  Name            : saveCreditScoringResult(Integer defaultBillingPeriod, Integer defaultPaymentTerms, Decimal creditLimit, Decimal deposit)
    *  Summary         : save credit scoring result and go to step 2
    *  CreatedDate     : 06/03/2018
    *  ModifiedDate    : -
    *  Parameters      : Integer defaultBillingPeriod, Integer defaultPaymentTerms, Decimal creditLimit, Decimal deposit
    *  Returns         : void
    ******************************************************************************/
    public void saveCreditScoringResult(Integer defaultBillingPeriod, Integer defaultPaymentTerms, Decimal creditLimit, Decimal deposit) {
        Decimal minLimit;
        Decimal maxLimit;
        if (defaultBillingPeriod == 7) {
            minLimit = this.cfReportResponse.creditLimit7;
            maxLimit = this.cfReportResponse.maxValue7;
        } else if (defaultBillingPeriod == 15) {
            minLimit = this.cfReportResponse.creditLimit15;
            maxLimit = this.cfReportResponse.maxValue15;
        } else if (defaultBillingPeriod == 30) {
            minLimit = this.cfReportResponse.creditLimit30;
            maxLimit = this.cfReportResponse.maxValue30;
        }
        if (creditLimit < minLimit || creditLimit > maxLimit) {
            throw new LongFormException('Unexpected error');
        }
        String ipAddress = LongFormGlobalUtils.getUserIPAddress();
        opportunity.Visitor_ID__c = ipAddress;
        opportunity.Zahlungsart__c = pagesMap.get('CREDIT SCORE. SCORING RESULT').fields.get('PAYMENT METHOD').elementItemsMap.get('DEFAULT VALUE').Value__c;
        opportunity.Rechnungsperiode__c = String.valueOf(defaultBillingPeriod);
        opportunity.CF_Credit_Limit__c = creditLimit;
        opportunity.Zahlungsziel_Credit__c = '7';
        opportunity.bearbeitet_von__c = 'Autoprocessed by E2E';
        opportunity.Credit_check_date__c = Date.today();
        if (deposit != 0 && deposit != null) {
            opportunity.Security_To_Pay__c = 'Kaution';
            opportunity.Security_Amount_To_Pay__c = deposit;
            opportunity.Kredit_Entscheidung__c = 'Sicherheit verlangt';
            opportunity.Billing_Period_by_Sales__c = true;
            opportunity.Pending_Deposit_by_CF__c = true;
            opportunity.CF_Stage__c = 'Pending deposit';
            opportunity.Max_Credit_Limit__c = creditLimit;
            if (this.cfReportResponse.company.classRating == null) {
                opportunity.Credit_System_Rating__c = 'Keine Bonität';
            }
            if (this.cfReportResponse.company.classRating == '4') {
                opportunity.Security_level_H_he_der_Sicherheit__c = 4;
            } else if (this.cfReportResponse.company.classRating == '5') {
                opportunity.Security_level_H_he_der_Sicherheit__c = 70;
            } else if (this.cfReportResponse.company.classRating == '6') {
                opportunity.Security_level_H_he_der_Sicherheit__c = 110;
            } else if (this.cfReportResponse.company.classRating == null) {
                opportunity.Security_level_H_he_der_Sicherheit__c = 100;
            }
        } else {
            opportunity.Security_To_Pay__c = '';
            opportunity.Garantie__c = '';
            opportunity.Kredit_Entscheidung__c = 'Genehmigt';
            if (opportunity.Rechnungsperiode__c == '7') {
                opportunity.Max_Credit_Limit__c = this.cfReportResponse.maxCreditLimit7;
            } else if (opportunity.Rechnungsperiode__c == '15') {
                opportunity.Max_Credit_Limit__c = this.cfReportResponse.maxCreditLimit15;
            } else if (opportunity.Rechnungsperiode__c == '30') {
                opportunity.Max_Credit_Limit__c = this.cfReportResponse.maxCreditLimit30;
            }
            if (this.cfReportResponse.company.classRating == null) {
                opportunity.Credit_System_Rating__c = '0-EX';
            }
        }
        if (this.cfReportResponse.company.classRating != null) {
           if (this.cfReportResponse.company.classRating == '1' || this.cfReportResponse.company.classRating == '2') {
               opportunity.Buffer__c = 30;
               opportunity.Risk_Category__c = 'Low';
           } else if (this.cfReportResponse.company.classRating == '3') {
               opportunity.Buffer__c = 20;
               opportunity.Risk_Category__c = 'Medium';
           } else if (this.cfReportResponse.company.classRating == '4' || this.cfReportResponse.company.classRating == '5') {
                opportunity.Buffer__c = 10;
                opportunity.Risk_Category__c = 'High';
           } else if (this.cfReportResponse.company.classRating == '6') {
                opportunity.Buffer__c = 0;
                opportunity.Risk_Category__c = 'Very';
           }
        } else {
           opportunity.Buffer__c = 10;
           opportunity.Risk_Category__c = 'High';
        }

        if (opportunity.Zahlungsart__c == 'Lastschrift') {
            if (opportunity.Total_consumption_l_month__c <= 1500) {
                opportunity.Direct_Debit_Mandate_Type__c = 'Core';
            } else {
                if (opportunity.Risk_Category__c == 'Low') {
                    opportunity.Direct_Debit_Mandate_Type__c = 'Core';
                } else {
                    opportunity.Direct_Debit_Mandate_Type__c = 'B2B';
                }
            }
        } else if (opportunity.Zahlungsart__c == 'Banküberweisung') {
            opportunity.Direct_Debit_Mandate_Type__c = '';
        }
        opportunity.E2E_Active_Step__c = 2;
        opportunity.E2E_Active_Substep__c = 'Card configuration';
        opportunity.E2E_Last_Activity__c = Datetime.now();
        opportunity.E2E_Status__c = 'In progress';
        opportunity.E2E_Sub_Status__c = '';
        List<User> e2eUser = [SELECT Id FROM User WHERE Name = 'E2E Site Guest User' LIMIT 1];
        if ( ! e2eUser.isEmpty() ) {
            opportunity.OwnerId = e2eUser.get(0).Id;
        }
        Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EForm').AES256_Key__c);
        String stringToEncode = opportunity.Id + '-' + opportunity.E2E_Active_Step__c;
        String encodedStringUrl = E2EFormEncryption.getHashAlgorithAES256(key256AES, stringToEncode);
        opportunity.E2E_Encoded_URL__c = encodedStringUrl;
        opportunity.StageName = 'Credit Approved';
        Database.SaveResult opptyUpdateResult = Database.update(opportunity, false);
        if (! opptyUpdateResult.isSuccess() ) {
            String error = '';
            for(Database.Error err : opptyUpdateResult.getErrors()) {
                error += err.getMessage();
            }
            throw new LongFormException(error);
        }
        this.cfReportResponse.sfReport.Decision_Verdict__c = this.cfDecision.verdict;
        this.cfReportResponse.sfReport.Decision_Status_Code__c = this.cfDecision.statusCode;
        Database.SaveResult reportUpdateResult = Database.update(this.cfReportResponse.sfReport, false);
        if (! reportUpdateResult.isSuccess() ) {
            String error = '';
            for(Database.Error err : reportUpdateResult.getErrors()) {
                error += err.getMessage();
            }
            throw new LongFormException(error);
        }
    }


    /*******************************************************************************
    *  Name            : validateCompanyName()
    *  Summary         : company name field validation
    *  CreatedDate     : 31/01/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void validateCompanyName() {
        Boolean companyNamerIsValid = true;
        String companyName = pagesMap.get('CREDIT SCORE. SEARCH COMPANY').fields.get('COMPANY NAME').elementItemsMap.get('DEFAULT VALUE').Value__c;
        Pattern myPattern = Pattern.compile(LongFormGlobalUtils.COMPANY_NAME_REGEX);
        Matcher myMatcher = myPattern.matcher(companyName);
        if (! myMatcher.matches() ) companyNamerIsValid = false;

        if (companyNamerIsValid != true) {
            errorMessage += 'Company name format is not valid' + '\n';
        }
    }


    /*******************************************************************************
    *  Name            : validateCity()
    *  Summary         : City validation
    *  CreatedDate     : 05/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void validateCity() {
        Boolean cityIsValid = true;
        String city = pagesMap.get('CREDIT SCORE. SEARCH COMPANY').fields.get('CITY').elementItemsMap.get('DEFAULT VALUE').Value__c;
        Pattern myPattern = Pattern.compile(LongFormGlobalUtils.CITY_REGEX);
        Matcher myMatcher = myPattern.matcher(city);
        if (! myMatcher.matches() ) cityIsValid = false;

        if ( ! cityIsValid ) {
            errorMessage += 'City format is not valid' + '\n';
        }
    }


    /*******************************************************************************
    *  Name            : validateTaxId(String taxid)
    *  Summary         : tax id field validation
    *  CreatedDate     : 31/01/2018
    *  ModifiedDate    : -
    *  Parameters      : String taxid
    *  Returns         : void
    ******************************************************************************/
    private void validateTaxId(String taxId) {
        if ( ! taxid.isNumeric() || taxid == '' || taxid == null || taxid.length() < 9 || taxid.length() > 12) {
            throw new LongFormException('Tax Id format is not valid');
        }
    }


    /*******************************************************************************
    *  Name            : validateTotalConsumption()
    *  Summary         : total consumption field validation
    *  CreatedDate     : 31/01/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void validateTotalConsumption() {
        String totalConsumption = pagesMap.get('CREDIT SCORE. TOTAL CONSUMPTION').fields.get('TOTAL CONSUMPTION').elementItemsMap.get('DEFAULT VALUE').Value__c;
        if (! totalConsumption.isNumeric() || totalConsumption == '' || totalConsumption == null || Decimal.valueOf(totalConsumption) < 75 || Decimal.valueOf(totalConsumption) > 50000) {
            errorMessage += 'Total Consumption is not valid: ' + totalConsumption;
        }
    }


    /*******************************************************************************
    *  Name            : setCompaniesFromCF(String opportunityId)
    *  Summary         : get companies
    *  CreatedDate     : 05/02/2018
    *  ModifiedDate    : -
    *  Parameters      : String opportunityId
    *  Returns         : void
    ******************************************************************************/
    public void setCompaniesFromCF(String opportunityId) {
        CreditSystemService creditService = new CreditSystemService();
        creditService.setCreditSystemSource(opportunityId);
        String creditSystemName = creditService.getCreditSystemName();
        CreditFactoryFinderController cfFinder = new CreditFactoryFinderController();
        Finder finderService = cfFinder.returnFinderService(creditSystemName);
        finderService.setUserSource('E2E Long Form');
        //Set and validate mapping
        finderService.setMapping();
        finderService.validateMapping();
        finderService.getSourceObject(opportunityId);
        List<CreditCompany> companiesList = finderService.searchCompany(creditService);
        cfSearchResponse = new CFSearchResponse();
        if (! companiesList.isEmpty() ) {
            cfSearchResponse.status = 'completed';
            cfSearchResponse.companiesMap = new Map<String, CreditCompany>();
            for (CreditCompany company : companiesList) {
                if (company.identificationnumber != null) {
                    cfSearchResponse.companiesMap.put(company.identificationnumber, company);
                }
            }
        } else {
            cfSearchResponse.status = 'not found';
            cfSearchResponse.companiesMap = new Map<String, CreditCompany>();
        }
    }


    /*******************************************************************************
    *  Name            : getCompaniesFromCF()
    *  Summary         : return companies
    *  CreatedDate     : 05/02/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public CFSearchResponse getCompaniesFromCF() {
        return cfSearchResponse;
    }


    /*******************************************************************************
    *  Name            : setCreditReportFromSF(String companyId)
    *  Summary         : set report for selected company
    *  CreatedDate     : 16/02/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void setCreditReportFromSF(String opportunityId) {
        List<Credit_Factory_Report__c> cfReportList = [
            SELECT Name, Name__c, Age_of_Company__c, City__c, Class_Rating__c, Company_Id__c, Company_Status__c, Country__c, County_Court__c, Credit_Decision__c, Credit_Limit__c, Credit_Limit_Currency__c,
                Credit_System_Number__c, Date_Last_Register_Entry__c, Date_Legal_Form__c, Date_of_Foundation__c, Email__c, Fax__c, First_Legal_Form__c, Fiscal_Number__c, Housenumber__c, Legal_Form__c,
                Mobile__c, Obligation_Overdue__c, Opportunity__c, Order_Situation__c, Payment_Behaviour__c, Phone__c, Postcode__c, Reference_Number__c, Register_Number__c, Request_Status__c,
                Solvency_Index__c, Staff_Range__c, Street__c, Tax_Id__c, Trade_Name__c, Turn_Over__c, VAT_Number__c, Website__c, Billing_Period__c, Credit_Limit_Default__c, Credit_Limit_Weekly_7__c, Credit_Limit_Bi_Weekly_7__c,
                Credit_Limit_Monthly_7__c, Max_Credit_Limit_Weekly_7__c, Max_Credit_Limit_Bi_Weekly_7__c, Max_Credit_Limit_Monthly_7__c, Max_Value_Weekly_7__c, Max_Value_Bi_Weekly_7__c, Max_Value_Monthly_7__c,
                Deposit_Weekly_7__c, Deposit_Bi_Weekly_7__c, Deposit_Monthly_7__c, Decision_Verdict__c, Decision_Status_Code__c,
                (SELECT Name, Id__c, Address__c, Company_Id__c, Company_Role__c, Company_Type__c, Credit_Factory_Report__c, Date_of_Birth__c, Participation_Date__c, Reported__c, Type__c
                FROM Credit_Factory_Report_Employees__r)
            FROM Credit_Factory_Report__c
            WHERE Opportunity__c = :opportunityId
            ORDER BY CreatedDate
            LIMIT 1
        ];
        if (! cfReportList.isEmpty()) {
            Credit_Factory_Report__c report = cfReportList.get(0);
            setUnavailableOptions(report.Decision_Verdict__c, report.Decision_Status_Code__c);
            CreditCompany company = new CreditCompany();
            company.identificationnumber = report.Company_Id__c;
            company.name = report.Name__c;
            company.tradename = report.Trade_Name__c;
            company.street = report.Street__c;
            company.housenumber = report.Housenumber__c;
            company.postcode = report.Postcode__c;
            company.city = report.City__c;
            company.country = report.Country__c;
            company.referencenumber = report.Reference_Number__c;
            company.classRating = report.Class_Rating__c;
            company.creditLimit = report.Credit_Limit__c;
            company.creditLimitCurrency = report.Credit_Limit_Currency__c;
            company.dateoffoundation = report.Date_of_Foundation__c;
            company.phone = report.Phone__c;
            company.fax = report.Fax__c;
            company.status = report.Company_Status__c;
            company.legalform = report.Legal_Form__c;
            company.staffcompanyrange = report.Staff_Range__c;
            company.countyCourt = report.County_Court__c;
            company.datelegalform = report.Date_Legal_Form__c;
            company.datelastregisterentry = report.Date_Last_Register_Entry__c;
            company.ageofcompany = report.Age_of_Company__c;
            company.firstlegalform = report.First_Legal_Form__c;
            company.email = report.Email__c;
            company.website = report.Website__c;
            company.mobile = report.Mobile__c;
            company.vatid = report.VAT_Number__c;
            company.taxnumber = report.Tax_Id__c;
            company.registerNumber = report.Register_Number__c;
            company.creditDecision = report.Credit_Decision__c;
            company.paymentBehaviour = report.Payment_Behaviour__c;
            company.turnOver = report.Turn_Over__c;
            company.creditSystemCompanyNumber = report.Credit_System_Number__c;
            company.orderSituation = report.Order_Situation__c;
            company.solvencyIndex = report.Solvency_Index__c;
            company.requestStatus = report.Request_Status__c;
            company.obligationOverdue = report.Obligation_Overdue__c;
            company.isReportExists = true;

            this.cfReportResponse = new CFReportResponse();
            this.cfReportResponse.sfReport = report;
            this.cfReportResponse.status = 'Success';
            this.cfReportResponse.company = company;
            this.cfReportResponse.recommendedBillingPeriod = report.Billing_Period__c;
            this.cfReportResponse.creditLimitDefault = report.Credit_Limit_Default__c;
            this.cfReportResponse.creditLimit7 = report.Credit_Limit_Weekly_7__c;
            this.cfReportResponse.creditLimit15 = report.Credit_Limit_Bi_Weekly_7__c;
            this.cfReportResponse.creditLimit30 = report.Credit_Limit_Monthly_7__c;
            this.cfReportResponse.maxCreditLimit7 = report.Max_Credit_Limit_Weekly_7__c;
            this.cfReportResponse.maxCreditLimit15 = report.Max_Credit_Limit_Bi_Weekly_7__c;
            this.cfReportResponse.maxCreditLimit30 = report.Max_Credit_Limit_Monthly_7__c;
            this.cfReportResponse.maxValue7 = report.Max_Value_Weekly_7__c;
            this.cfReportResponse.maxValue15 = report.Max_Value_Bi_Weekly_7__c;
            this.cfReportResponse.maxValue30 = report.Max_Value_Monthly_7__c;
            this.cfReportResponse.deposit7 = report.Deposit_Weekly_7__c;
            this.cfReportResponse.deposit15 = report.Deposit_Bi_Weekly_7__c;
            this.cfReportResponse.deposit30 = report.Deposit_Monthly_7__c;

            this.cfReportResponse.companyEmployees = new List<CreditCompanyEmployee>();
            for (Credit_Factory_Report_Employee__c empl : cfReportList.get(0).Credit_Factory_Report_Employees__r) {
                CreditCompanyEmployee employee = new CreditCompanyEmployee();
                employee.type = empl.Type__c;
                employee.ename = empl.Name;
                employee.dateofbirth = empl.Date_of_Birth__c;
                employee.address = empl.Address__c;
                employee.participationdate = empl.Participation_Date__c;
                employee.companyRole = empl.Company_Role__c;
                employee.companyType = empl.Company_Type__c;
                employee.companyId = empl.Company_Id__c;
                employee.Reported = empl.Reported__c;
                this.cfReportResponse.companyEmployees.add(employee);
            }
        }
    }


    /*******************************************************************************
    *  Name            : getCreditReportFromSF()
    *  Summary         : get report for selected company
    *  CreatedDate     : 16/02/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public CFReportResponse getCreditReportFromSF() {
        return this.cfReportResponse;
    }


    /*******************************************************************************
    *  Name            : setSFobjects(String opptyId)
    *  Summary         : set objects (account, opportunity, contact)
    *  CreatedDate     : 07/05/2018
    *  ModifiedDate    : -
    *  Parameters      : String opptyId
    *  Returns         : void
    ******************************************************************************/
    public void setSFobjects(String opptyId) {
        // opportunity
        List<Opportunity> opptyList = [
            SELECT Name, AccountId, RecordTypeId, E2E_Active_Step__c, E2E_Active_Substep__c, E2E_Encoded_URL__c, StageName, LeadSource, SEPA_Mandate_URL__c, 
                E2E_Last_Activity__c, Primary_Contact_Phone__c, E2E_Form_of_Business__c, Agree_to_Privacy_Policy__c, Date_for_Agree_to_Privacy_Policy__c, E2E_Status__c, E2E_Sub_Status__c, Visitor_ID__c,
                Gruende_verloren__c, Utm_campaign__c, Utm_content__c, Utm_medium__c, Utm_placement__c, Utm_source__c, Utm_term__c, Utm_url__c, Zahlungsart__c, Total_consumption_l_month__c,
                Rechnungsperiode__c, CF_Credit_Limit__c, Security_Amount_To_Pay__c, Eco_Fee__c, IBAN__c, SWIFT_BIC__c, Papierrechnung__c, E2E_payment_status__c, CF_Stage__c, E2E_CF_Reports_Counter__c,
                Home_Station__c, ESI__c, Gasoline_consumption_l_month__c, Diesel_consumption_l_month__c, Auftragsvolumen__c, CloseDate, OwnerId, Owner.Email, Credit_System_Rating__c, Umsatz__c,
                Gruendungsjahr__c, Credit_System_Number__c, Zahl_der_Mitarbeiter__c, Zahlungsziel_Credit__c, Security_To_Pay__c, Kredit_Entscheidung__c, Credit_check_date__c, Bearbeitet_von__c,
                Billing_Period_by_Sales__c, Pending_Deposit_by_CF__c, Max_Credit_Limit__c, Garantie__c, Buffer__c, Risk_Category__c, Product__c, Derzeitige_Zahlungsmethode__c, Number_of_cars__c,
                Number_of_trucks__c, Anzahl_der_Karten__c, Total_number_of_vehicles__c, Name_of_the_payer_Account_holder__c, Send_SEPA_approval_link__c, SEPA_Request_Approved__c, 
                Einwilligung_Lastschriftverfahren__c, SEPA_Request_Approval_Date__c, E2E_Errors__c, E_Invoicing_PDF__c, AGB_Datenschutzhinweise_Richtigkeit__c, Garantie_other__c, Starts_Status__c,
                ForecastCategoryName, Closed_Won_by_CF__c, Last_CF_Errors__c, Clubsmart__c, Language_preference__c, Sec_Channel__c, Channel__c, CurrencyIsoCode, Type, E2E_Sales_Type__c, E2E_Chat_Step__c,
                E2E_Form_Type__c, Agree_To_Deposit_Agreement__c, Date_For_Agree_To_Deposit_Agreement__c, E2E_System_Error_Description__c, Direct_Debit_Mandate_Type__c,Suggested_Total_Consumption__c,
                (SELECT ContactId FROM OpportunityContactRoles WHERE IsPrimary = true LIMIT 1)
            FROM Opportunity
            WHERE Id = :opptyId
            LIMIT 1
        ];
        if (! opptyList.isEmpty() ) {
            this.opportunity = opptyList.get(0);

            //account
            List<Account> accountList = [
                SELECT Id, Name, AccountSource, RecordTypeId, Umsatzsteuer_ID__c, BillingCountry, BillingCity, BillingStreet, BillingPostalCode, ShippingCountry, ShippingPostalCode, ShippingCity,
                    ShippingStreet, Gesellschaftsform__c, Steuernummer__c, Beschaeftigte__c, Type
                FROM Account
                WHERE Id = :this.opportunity.AccountId
                LIMIT 1
            ];
            if (! accountList.isEmpty() ) {
                this.account = accountList.get(0);
            }

            //contact
            if (! this.opportunity.OpportunityContactRoles.isEmpty() ) {
                List<Contact> contactList = [
                    SELECT Id, Name, AccountId, RecordTypeId, Salutation, FirstName, LastName, Phone, Email, MailingCountry, MailingStreet, MailingPostalCode, MailingCity, Authorised_signatory__c, 
                        LeadSource 
                    FROM Contact
                    WHERE Id = :this.opportunity.OpportunityContactRoles.get(0).ContactId
                    LIMIT 1
                ];
                if (! contactList.isEmpty() ) {
                    this.contact = contactList.get(0);
                }
            }
        }
    }


    /*******************************************************************************
    *  Name            : doSaveAndContinueLater()
    *  Summary         : do save data and send email to primary contact
    *  CreatedDate     : 30/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doSaveAndContinueLater() {
        this.opportunity.E2E_Status__c = 'Abandoned (soft)';
        this.opportunity.E2E_Sub_Status__c = 'Marketing automation';

        update this.opportunity;
        EmarsysSenderEuropeanService.sendE2EOpportunityToEmarsys(opportunity.Id);
    }


    /*******************************************************************************
    *  Name            : setAccount(String accId)
    *  Summary         : set account
    *  CreatedDate     : 31/01/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void setAccount(String accId) {
        List<Account> accountList = [
            SELECT Id, Name, AccountSource, RecordTypeId, Umsatzsteuer_ID__c, BillingCountry, BillingCity, BillingStreet, BillingPostalCode, ShippingCountry, ShippingPostalCode, ShippingCity,
                ShippingStreet, Gesellschaftsform__c, Steuernummer__c, Beschaeftigte__c, Type
            FROM Account
            WHERE Id = :accId
            LIMIT 1
        ];
        if (! accountList.isEmpty() ) {
            account = accountList.get(0);
        }
    }


    /*******************************************************************************
    *  Name            : getAccount()
    *  Summary         : return account
    *  CreatedDate     : 31/01/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : return account
    ******************************************************************************/
    public Account getAccount() {
        return account;
    }


    /*******************************************************************************
    *  Name            : setOpportunity(String opptyId)
    *  Summary         : set opportunity
    *  CreatedDate     : 31/01/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void setOpportunity(String opptyId) {
        List<Opportunity> opptyList = [
            SELECT Name, AccountId, RecordTypeId, E2E_Active_Step__c, E2E_Active_Substep__c, E2E_Encoded_URL__c, StageName, LeadSource, SEPA_Mandate_URL__c, 
                E2E_Last_Activity__c, Primary_Contact_Phone__c, E2E_Form_of_Business__c, Agree_to_Privacy_Policy__c, Date_for_Agree_to_Privacy_Policy__c, E2E_Status__c, E2E_Sub_Status__c, Visitor_ID__c,
                Gruende_verloren__c, Utm_campaign__c, Utm_content__c, Utm_medium__c, Utm_placement__c, Utm_source__c, Utm_term__c, Utm_url__c, Zahlungsart__c, Total_consumption_l_month__c,
                Rechnungsperiode__c, CF_Credit_Limit__c, Security_Amount_To_Pay__c, Eco_Fee__c, IBAN__c, SWIFT_BIC__c, Papierrechnung__c, E2E_payment_status__c, CF_Stage__c, E2E_CF_Reports_Counter__c,
                Home_Station__c, ESI__c, Gasoline_consumption_l_month__c, Diesel_consumption_l_month__c, Auftragsvolumen__c, CloseDate, OwnerId, Owner.Email, Credit_System_Rating__c, Umsatz__c,
                Gruendungsjahr__c, Credit_System_Number__c, Zahl_der_Mitarbeiter__c, Zahlungsziel_Credit__c, Security_To_Pay__c, Kredit_Entscheidung__c, Credit_check_date__c, Bearbeitet_von__c,
                Billing_Period_by_Sales__c, Pending_Deposit_by_CF__c, Max_Credit_Limit__c, Garantie__c, Buffer__c, Risk_Category__c, Product__c, Derzeitige_Zahlungsmethode__c, Number_of_cars__c,
                Number_of_trucks__c, Anzahl_der_Karten__c, Total_number_of_vehicles__c, Name_of_the_payer_Account_holder__c, Send_SEPA_approval_link__c, SEPA_Request_Approved__c, 
                Einwilligung_Lastschriftverfahren__c, SEPA_Request_Approval_Date__c, E2E_Errors__c, E_Invoicing_PDF__c, AGB_Datenschutzhinweise_Richtigkeit__c, Garantie_other__c, Starts_Status__c,
                ForecastCategoryName, Closed_Won_by_CF__c, Last_CF_Errors__c, Clubsmart__c, Language_preference__c, Sec_Channel__c, Channel__c, CurrencyIsoCode, Type, E2E_Sales_Type__c, E2E_Chat_Step__c,
                E2E_Form_Type__c, Agree_To_Deposit_Agreement__c, Date_For_Agree_To_Deposit_Agreement__c, E2E_System_Error_Description__c, Direct_Debit_Mandate_Type__c, Suggested_Total_Consumption__c,
                (SELECT ContactId FROM OpportunityContactRoles WHERE IsPrimary = true LIMIT 1)
            FROM Opportunity
            WHERE Id = :opptyId
            LIMIT 1
        ];
        if (! opptyList.isEmpty() ) {
            opportunity = opptyList.get(0);
        }
    }


    /*******************************************************************************
    *  Name            : getOpportunity()
    *  Summary         : return opportunity
    *  CreatedDate     : 31/01/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : return opportunity
    ******************************************************************************/
    public Opportunity getOpportunity() {
        return opportunity;
    }


    /*******************************************************************************
    *  Name            : getContact()
    *  Summary         : return contact
    *  CreatedDate     : 19/02/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : return contact
    ******************************************************************************/
    public Contact getContact() {
        return contact;
    }


    /*******************************************************************************
    *  Name            : resetOpportunityToStep(String substep)
    *  Summary         : Set substep to Opportunity and update the record
    *  CreatedDate     : 01/06/18
    *  ModifiedDate    :
    *  Parameters      : String substep – substep name
    *  Returns         : void
    ******************************************************************************/
    public void resetOpportunityToStep(String substep) {
        opportunity.E2E_Active_Substep__c = substep;
        update opportunity;
        EmarsysSenderEuropeanService.sendE2EOpportunityToEmarsys(opportunity.Id);
    }


    public static Set<String> creditScoreStepPagesSet = new Set<String>{
        'CREDIT SCORE. SEARCH COMPANY',
        'CREDIT SCORE. ENTER TAX ID',
        'CREDIT SCORE. TOTAL CONSUMPTION',
        'CREDIT SCORE. SCORING RESULT',
        'SAVE AND CONTINUE LATER',
        'ORDER DETAIL BLOCK',
        'HEADER',
        'FOOTER',
        'SYSTEM ERROR',
        'PROCESS ERROR',
        'VOUCHER'
    };
}