public class LFCardsConfigServiceBENL implements LFCardsConfig {
    private Map<String, LongFormPage> pagesMap;
    private Map<Integer, LongFormCard> sameCardsMap;
    private Map<Integer, LongFormCard> diffCardsMap;
    private Map<Integer, LongFormCard> finalCardsMap;
    private Map<String, Tankkarten__c> allSavedCardsMap;
    private CreditCompany company;
    private String activeCardConfigTab;
    private Integer numberOfCards;
    private Boolean pumpOutsideCountry;
    private Boolean pumpAtPartners;
    private Boolean showInternationalFeesBlock;
    private Boolean showCardsEmbossingBlock;
    private Boolean continueButtonIsDisabled;
    private String continueButtonStatus;
    private List<LongFormSpecialOffer> homeOffersList;
    private List<LongFormSpecialOffer> nonHomeOffersList;
    private String urlLocator;
    private String activeProductName;
    private Account account;
    private Opportunity opportunity;
    private Contact contact;
    private String unavailableOptions;

    private Map<String, List<LongFormCostItem>> costsColumnsMap;
    private Map<String, LongForm_Pricelist_Item__c> priceItemsMap;


    /*******************************************************************************
    *  Name            : setPagesMap()
    *  Summary         : generate pages map for Step 2
    *  CreatedDate     : 06/03/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void setPagesMap(String deviceView) {
        E2E_Form_General_Settings__c settings = E2E_Form_General_Settings__c.getInstance('Belgium-NL');

        Map<Id, LongForm_Page__c> lfPagesMap = new Map<Id, LongForm_Page__c>([
            SELECT Name, Type__c, Long_Form__c
            FROM LongForm_Page__c
            WHERE Long_Form__r.Country__c = 'Belgium-NL' AND
                Name IN :cardConfigStepPagesSet AND
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

        this.pagesMap = new Map<String, LongFormPage>();
        Set<String> fieldTypes = new Set<String>{'Text Field', 'Picklist Field', 'Radio-button Field', 'Checkbox Field', 'Slider Field'};
        for (LongForm_Element__c element : elementsList) {
            if (! pagesMap.containsKey(element.Long_Form_Page__r.Name) ) {
                this.pagesMap.put(element.Long_Form_Page__r.Name, new LongFormPage());
                this.pagesMap.get(element.Long_Form_Page__r.Name).elements = new Map<String, Map<String, LongForm_Element_Item__c>>();
                this.pagesMap.get(element.Long_Form_Page__r.Name).fields = new Map<String, LongFormField>();
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
                this.pagesMap.get(element.Long_Form_Page__r.Name).fields.put(element.Name, field);
            } else {
                if (! this.pagesMap.get(element.Long_Form_Page__r.Name).elements.containsKey(element.Name) ) {
                    this.pagesMap.get(element.Long_Form_Page__r.Name).elements.put(element.Name, new Map<String, LongForm_Element_Item__c>());
                }
                for (LongForm_Element_Item__c elementItem : element.Long_Form_Element_Items__r) {
                    this.pagesMap.get(element.Long_Form_Page__r.Name).elements.get(element.Name).put(elementItem.Name, elementItem);
                }
            }
        }
    }


    /*******************************************************************************
    *  Name            : getPagesMap()
    *  Summary         : return all pages for Step 2
    *  CreatedDate     : 06/03/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Map<String, LongFormPage> pagesMap
    ******************************************************************************/
    public Map<String, LongFormPage> getPagesMap() {
        return this.pagesMap;
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
        EmarsysSenderEuropeanService.sendE2EOpportunityToEmarsys(this.opportunity.Id);
    }


    /*******************************************************************************
    *  Name            : setCreditReport()
    *  Summary         : set credit report
    *  CreatedDate     : 19/03/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void setCreditReport() {
        List<Credit_Factory_Report__c> cfReportList = [
            SELECT Name, Name__c, Age_of_Company__c, City__c, Class_Rating__c, Company_Id__c, Company_Status__c, Country__c, County_Court__c, Credit_Decision__c, Credit_Limit__c, Credit_Limit_Currency__c,
                Credit_System_Number__c, Date_Last_Register_Entry__c, Date_Legal_Form__c, Date_of_Foundation__c, Email__c, Fax__c, First_Legal_Form__c, Fiscal_Number__c, Housenumber__c, Legal_Form__c,
                Mobile__c, Obligation_Overdue__c, Opportunity__c, Order_Situation__c, Payment_Behaviour__c, Phone__c, Postcode__c, Reference_Number__c, Register_Number__c, Request_Status__c,
                Solvency_Index__c, Staff_Range__c, Street__c, Tax_Id__c, Trade_Name__c, Turn_Over__c, VAT_Number__c, Website__c, Billing_Period__c, Credit_Limit_Weekly_7__c, Credit_Limit_Bi_Weekly_7__c,
                Credit_Limit_Monthly_7__c, Max_Credit_Limit_Weekly_7__c, Max_Credit_Limit_Bi_Weekly_7__c, Max_Credit_Limit_Monthly_7__c, Max_Value_Weekly_7__c, Max_Value_Bi_Weekly_7__c, Max_Value_Monthly_7__c,
                Deposit_Weekly_7__c, Deposit_Bi_Weekly_7__c, Deposit_Monthly_7__c,
                Decision_Verdict__c, Decision_Status_Code__c,
                (SELECT Name, Id__c, Address__c, Company_Id__c, Company_Role__c, Company_Type__c, Credit_Factory_Report__c, Date_of_Birth__c, Participation_Date__c, Reported__c, Type__c
                FROM Credit_Factory_Report_Employees__r)
            FROM Credit_Factory_Report__c
            WHERE Opportunity__c = :opportunity.Id
            ORDER BY CreatedDate
            LIMIT 1
        ];
        if (! cfReportList.isEmpty()) {
            Credit_Factory_Report__c report = cfReportList.get(0);
            this.company = new CreditCompany();
            this.company.identificationnumber = report.Company_Id__c;
            this.company.name = report.Name__c;
            this.company.tradename = report.Trade_Name__c;
            this.company.street = report.Street__c;
            this.company.housenumber = report.Housenumber__c;
            this.company.postcode = report.Postcode__c;
            this.company.city = report.City__c;
            this.company.country = report.Country__c;
            this.company.referencenumber = report.Reference_Number__c;
            this.company.classRating = report.Class_Rating__c;
            this.company.creditLimit = report.Credit_Limit__c;
            this.company.maxCreditLimit7 = report.Max_Credit_Limit_Weekly_7__c;
            this.company.maxCreditLimit15 = report.Max_Credit_Limit_Bi_Weekly_7__c;
            this.company.maxCreditLimit30 = report.Max_Credit_Limit_Monthly_7__c;
            this.company.maxCreditValue7 = report.Max_Value_Weekly_7__c;
            this.company.maxCreditValue15 = report.Max_Value_Bi_Weekly_7__c;
            this.company.maxCreditValue30 = report.Max_Value_Monthly_7__c;
            this.company.creditLimitCurrency = report.Credit_Limit_Currency__c;
            this.company.dateoffoundation = report.Date_of_Foundation__c;
            this.company.phone = report.Phone__c;
            this.company.fax = report.Fax__c;
            this.company.status = report.Company_Status__c;
            this.company.legalform = report.Legal_Form__c;
            this.company.staffcompanyrange = report.Staff_Range__c;
            this.company.countyCourt = report.County_Court__c;
            this.company.datelegalform = report.Date_Legal_Form__c;
            this.company.datelastregisterentry = report.Date_Last_Register_Entry__c;
            this.company.ageofcompany = report.Age_of_Company__c;
            this.company.firstlegalform = report.First_Legal_Form__c;
            this.company.email = report.Email__c;
            this.company.website = report.Website__c;
            this.company.mobile = report.Mobile__c;
            this.company.vatid = report.VAT_Number__c;
            this.company.taxnumber = report.Tax_Id__c;
            this.company.registerNumber = report.Register_Number__c;
            this.company.creditDecision = report.Credit_Decision__c;
            this.company.creditVerdict = report.Decision_Verdict__c;
            this.company.creditStatusCode = report.Decision_Status_Code__c;
            this.company.paymentBehaviour = report.Payment_Behaviour__c;
            this.company.turnOver = report.Turn_Over__c;
            this.company.creditSystemCompanyNumber = report.Credit_System_Number__c;
            this.company.orderSituation = report.Order_Situation__c;
            this.company.solvencyIndex = report.Solvency_Index__c;
            this.company.requestStatus = report.Request_Status__c;
            this.company.obligationOverdue = report.Obligation_Overdue__c;
            this.company.isReportExists = true;
        }
    }


    /*******************************************************************************
    *  Name            : getCreditReport()
    *  Summary         : get credit report from SF
    *  CreatedDate     : 19/03/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : CreditCompany company
    ******************************************************************************/
    public CreditCompany getCreditReport() {
        return this.company;
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
    *  Name            : setPriceLists()
    *  Summary         : set price lists
    *  CreatedDate     : 19/03/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void setPriceLists() {
        List<LongForm_Pricelist_Item__c> priceListItems = [
            SELECT Unit__c, Long_Form_Pricelist__r.Type__c, Long_Form_Pricelist__c, Price__c, Show_Category__c, Tariff__c, Type__c
            FROM LongForm_Pricelist_Item__c
            WHERE Long_Form_Pricelist__r.Country__c = 'Belgium-NL' AND 
                Long_Form_Pricelist__r.Channel__c = :this.opportunity.Sec_Channel__c
            LIMIT 1000
        ];
        this.priceItemsMap = new Map<String, LongForm_Pricelist_Item__c>();
        for (LongForm_Pricelist_Item__c item : priceListItems) {
            String key = item.Long_Form_Pricelist__r.Type__c + '_' + item.Type__c;
            this.priceItemsMap.put(key, item);
        }
    }


    /*******************************************************************************
    *  Name            : rebuildSameMap()
    *  Summary         : rebuild "sameCardsMap"     
    *  CreatedDate     : 10/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void rebuildSameMap() {
        for (Integer index : this.sameCardsMap.keySet()) {
            if (index != 1) {
                this.sameCardsMap.get(index).categoryCard = this.sameCardsMap.get(1).categoryCard;
                this.sameCardsMap.get(index).pumpOutsideCountry = this.sameCardsMap.get(1).pumpOutsideCountry;
                this.sameCardsMap.get(index).pumpAtPartners = this.sameCardsMap.get(1).pumpAtPartners;
            }
        }
    }
    

    /*******************************************************************************
    *  Name            : setCostsColumnsMap()
    *  Summary         : calculate fees and costs for current columns
    *  CreatedDate     : 19/03/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void setCostsColumnsMap() {
        // 1. SERVICE FEES
        // 1.1 Monthly fee
        LongFormCostItem monthlyFeeItem = new LongFormCostItem();
        monthlyFeeItem.contentName = 'MONTHLY FEE HEADING';
        monthlyFeeItem.costValue = 0;
        // 1.2 One time set up fee
        LongFormCostItem oneTimeSetupFeeItem = new LongFormCostItem();
        oneTimeSetupFeeItem.contentName = 'ONE TIME FEE HEADING';
        // oneTimeSetupFeeItem.style = 'margin-top: 37px';
        oneTimeSetupFeeItem.costValue = 0;
        // 2. NATIONAL TRANSACTIONS
        // 2.1 Fuel (Shell)
        LongFormCostItem fuelShellItem = new LongFormCostItem();
        fuelShellItem.contentName = 'FUEL SHELL';
        fuelShellItem.contentHelp = 'FUEL SHELL HELP';
        fuelShellItem.showHelpItem = false;
        fuelShellItem.costValue = 0;
        // 2.2 Fuel (Shell Favorite)
        LongFormCostItem fuelShellFavoriteItem = new LongFormCostItem();
        fuelShellFavoriteItem.contentName = 'FUEL SHELL FAVORITE';
        fuelShellFavoriteItem.contentHelp = 'FUEL SHELL FAVORITE HELP';
        fuelShellFavoriteItem.showHelpItem = false;
        fuelShellFavoriteItem.costValue = 0;
        // 2.3 Fuel (Shell Other)
        LongFormCostItem fuelShellOtherItem = new LongFormCostItem();
        fuelShellOtherItem.contentName = 'FUEL SHELL OTHER';
        fuelShellOtherItem.contentHelp = 'FUEL SHELL OTHER HELP';
        fuelShellOtherItem.showHelpItem = false;
        fuelShellOtherItem.costValue = 0;
        // 2.4 Shell Partner
        LongFormCostItem shellPartnerItem = new LongFormCostItem();
        shellPartnerItem.contentName = 'SHELL PARTNER';
        shellPartnerItem.contentHelp = 'SHELL PARTNER HELP';
        shellPartnerItem.showHelpItem = true;
        shellPartnerItem.costValue = 0;
        // 2.5 Fuel (Shell Partner)
        LongFormCostItem fuelShellPartnerItem = new LongFormCostItem();
        fuelShellPartnerItem.contentName = 'FUEL SHELL PARTNER';
        fuelShellPartnerItem.contentHelp = 'FUEL SHELL PARTNER HELP';
        fuelShellPartnerItem.showHelpItem = true;
        fuelShellPartnerItem.costValue = 0;
        // 2.6 Non-fuel (Shell Partner)
        LongFormCostItem nonFuelShellPartnerItem = new LongFormCostItem();
        nonFuelShellPartnerItem.contentName = 'NON-FUEL SHELL PARTNER';
        nonFuelShellPartnerItem.contentHelp = 'NON-FUEL SHELL PARTNER HELP';
        nonFuelShellPartnerItem.showHelpItem = true;
        nonFuelShellPartnerItem.costValue = 0;
        // 2.7 Non-fuel
        LongFormCostItem nonFuelItem = new LongFormCostItem();
        nonFuelItem.contentName = 'NON-FUEL';
        nonFuelItem.contentHelp = 'NON-FUEL HELP';
        nonFuelItem.showHelpItem = true;
        nonFuelItem.costValue = 0;
        // 2.8 Non-fuel (Shell Favorite)
        LongFormCostItem nonFuelShellFavoriteItem = new LongFormCostItem();
        nonFuelShellFavoriteItem.contentName = 'NON-FUEL SHELL FAVORITE';
        nonFuelShellFavoriteItem.contentHelp = 'NON-FUEL SHELL FAVORITE HELP';
        nonFuelShellFavoriteItem.showHelpItem = true;
        nonFuelShellFavoriteItem.costValue = 0;
        // 2.9 Non-fuel (Shell Other)
        LongFormCostItem nonFuelShellOtherItem = new LongFormCostItem();
        nonFuelShellOtherItem.contentName = 'NON-FUEL SHELL OTHER';
        nonFuelShellOtherItem.contentHelp = 'NON-FUEL SHELL OTHER HELP';
        nonFuelShellOtherItem.showHelpItem = true;
        nonFuelShellOtherItem.costValue = 0;
        // 3. INTERNATIONAL TRANSACTIONS
        // 3.1 All types
        LongFormCostItem allTypesItem = new LongFormCostItem();
        allTypesItem.contentName = 'ALL TYPES';
        allTypesItem.contentHelp = 'ALL TYPES HELP';
        allTypesItem.showHelpItem = false;
        allTypesItem.costValue = 0;
        // 3.2 All: Fuel
        LongFormCostItem allFuelItem = new LongFormCostItem();
        allFuelItem.contentName = 'ALL FUEL';
        allFuelItem.contentHelp = 'ALL FUEL HELP';
        allFuelItem.showHelpItem = false;
        allFuelItem.costValue = 0;
        // 3.1 All: Non-fuel
        LongFormCostItem allNonFuelItem = new LongFormCostItem();
        allNonFuelItem.contentName = 'ALL NON FUEL';
        allNonFuelItem.contentHelp = 'ALL NON FUEL HELP';
        allNonFuelItem.showHelpItem = false;
        allNonFuelItem.costValue = 0;
        // 4. OTHER FEES
        // 4.1 Duplicate invoice payment
        LongFormCostItem duplicatePaymentItem = new LongFormCostItem();
        duplicatePaymentItem.contentName = 'DUPLICATE PAYMENT';
        duplicatePaymentItem.contentHelp = 'DUPLICATE PAYMENT HELP';
        duplicatePaymentItem.showHelpItem = true;
        duplicatePaymentItem.costValue = 0;
        // 4.2 Late invoice payment
        LongFormCostItem latePaymentItem = new LongFormCostItem();
        latePaymentItem.contentName = 'LATE PAYMENT';
        latePaymentItem.contentHelp = 'LATE PAYMENT HELP';
        latePaymentItem.showHelpItem = true;
        latePaymentItem.costValue = 0;
        // 4.3 Card replacement
        LongFormCostItem cardReplacementPaymentItem = new LongFormCostItem();
        cardReplacementPaymentItem.contentName = 'CARD REPLACEMENT';
        cardReplacementPaymentItem.contentHelp = '';
        cardReplacementPaymentItem.showHelpItem = false;
        cardReplacementPaymentItem.costValue = 0;

        this.costsColumnsMap = new Map<String, List<LongFormCostItem>>();
        this.costsColumnsMap.put('1', new List<LongFormCostItem>());
        this.costsColumnsMap.put('DISCOUNT', new List<LongFormCostItem>());
        this.costsColumnsMap.put('2_1', new List<LongFormCostItem>());
        this.costsColumnsMap.put('2_2', new List<LongFormCostItem>());
        this.costsColumnsMap.put('3', new List<LongFormCostItem>());
        String pricelistKey;
        Boolean appliedPerAccount = true;
        if (this.activeCardConfigTab == 'same') {
            for (LongFormCard lfCard : this.sameCardsMap.values()) {
                if (lfCard.pumpOutsideCountry == true && lfCard.pumpAtPartners == false) {
                    pricelistKey = 'International Not Partners';
                } else if (lfCard.pumpOutsideCountry == true && lfCard.pumpAtPartners == true) {
                    pricelistKey = 'International Partners';
                } else if (lfCard.pumpOutsideCountry == false && lfCard.pumpAtPartners == false) {
                    pricelistKey = 'National Not Partners';
                } else if (lfCard.pumpOutsideCountry == false && lfCard.pumpAtPartners == true) {
                    pricelistKey = 'National Partners';
                }
                // PER ACCOUNT
                if (appliedPerAccount == true) {
                    oneTimeSetupFeeItem.costValue = this.priceItemsMap.get(pricelistKey + '_One Time Account Set Up').Price__c;
                    // Fuel (Shell)
                    if (this.priceItemsMap.get(pricelistKey + '_Transaction Shell Home Fuel').Price__c == this.priceItemsMap.get(pricelistKey + '_Transaction Shell Non-Home Fuel').Price__c) {
                        fuelShellItem.costValue = this.priceItemsMap.get(pricelistKey + '_Transaction Shell Home Fuel').Price__c;
                        fuelShellItem.costTariff = this.priceItemsMap.get(pricelistKey + '_Transaction Shell Home Fuel').Unit__c;
                        this.costsColumnsMap.get('2_1').add(fuelShellItem);
                    } else {
                        fuelShellFavoriteItem.costValue = this.priceItemsMap.get(pricelistKey + '_Transaction Shell Home Fuel').Price__c;
                        fuelShellFavoriteItem.costTariff = this.priceItemsMap.get(pricelistKey + '_Transaction Shell Home Fuel').Unit__c;
                        this.costsColumnsMap.get('2_1').add(fuelShellFavoriteItem);
                        fuelShellOtherItem.costValue = this.priceItemsMap.get(pricelistKey + '_Transaction Shell Non-Home Fuel').Price__c;
                        fuelShellOtherItem.costTariff = this.priceItemsMap.get(pricelistKey + '_Transaction Shell Non-Home Fuel').Unit__c;
                        this.costsColumnsMap.get('2_1').add(fuelShellOtherItem);
                    }
                    if (lfCard.pumpAtPartners) {
                        // Shell Partner
                        if (this.priceItemsMap.get(pricelistKey + '_Transaction Shell Partner Fuel').Price__c == this.priceItemsMap.get(pricelistKey + '_Transaction Shell Partner Non-Fuel').Price__c) {
                            shellPartnerItem.costValue = this.priceItemsMap.get(pricelistKey + '_Transaction Shell Partner Fuel').Price__c;
                            shellPartnerItem.costTariff = this.priceItemsMap.get(pricelistKey + '_Transaction Shell Partner Fuel').Unit__c;
                            this.costsColumnsMap.get('2_1').add(shellPartnerItem);
                        } else {
                            fuelShellPartnerItem.costValue = this.priceItemsMap.get(pricelistKey + '_Transaction Shell Partner Fuel').Price__c;
                            fuelShellPartnerItem.costTariff = this.priceItemsMap.get(pricelistKey + '_Transaction Shell Partner Fuel').Unit__c;
                            this.costsColumnsMap.get('2_1').add(fuelShellPartnerItem);
                            nonFuelShellPartnerItem.costValue = this.priceItemsMap.get(pricelistKey + '_Transaction Shell Partner Non-Fuel').Price__c;
                            nonFuelShellPartnerItem.costTariff = this.priceItemsMap.get(pricelistKey + '_Transaction Shell Partner Non-Fuel').Unit__c;
                            this.costsColumnsMap.get('2_1').add(nonFuelShellPartnerItem);
                        }
                    }
                    // Non-fuel
                    if (this.priceItemsMap.get(pricelistKey + '_Transaction Shell Home Non-Fuel').Price__c == this.priceItemsMap.get(pricelistKey + '_Transaction Shell Non-Home Non-Fuel').Price__c) {
                        nonFuelItem.costValue = this.priceItemsMap.get(pricelistKey + '_Transaction Shell Home Non-Fuel').Price__c;
                        nonFuelItem.costTariff = this.priceItemsMap.get(pricelistKey + '_Transaction Shell Home Non-Fuel').Unit__c;
                        this.costsColumnsMap.get('2_1').add(nonFuelItem);
                    } else {
                        nonFuelShellFavoriteItem.costValue = this.priceItemsMap.get(pricelistKey + '_Transaction Shell Home Non-Fuel').Price__c;
                        nonFuelShellFavoriteItem.costTariff = this.priceItemsMap.get(pricelistKey + '_Transaction Shell Home Non-Fuel').Unit__c;
                        this.costsColumnsMap.get('2_1').add(nonFuelShellFavoriteItem);
                        nonFuelShellOtherItem.costValue = this.priceItemsMap.get(pricelistKey + '_Transaction Shell Non-Home Non-Fuel').Price__c;
                        nonFuelShellOtherItem.costTariff = this.priceItemsMap.get(pricelistKey + '_Transaction Shell Non-Home Non-Fuel').Unit__c;
                        this.costsColumnsMap.get('2_1').add(nonFuelShellOtherItem);
                    }
                    if (lfCard.pumpOutsideCountry) {
                        this.showInternationalFeesBlock = true;
                        // All types
                        if (this.priceItemsMap.get(pricelistKey + '_All: Fuel').Price__c == this.priceItemsMap.get(pricelistKey + '_All: Non-Fuel').Price__c) {
                            allTypesItem.costValue = this.priceItemsMap.get(pricelistKey + '_All: Fuel').Price__c;
                            allTypesItem.costTariff = this.priceItemsMap.get(pricelistKey + '_All: Fuel').Unit__c;
                            this.costsColumnsMap.get('2_2').add(allTypesItem);
                        } else {
                            allFuelItem.costValue = this.priceItemsMap.get(pricelistKey + '_All: Fuel').Price__c;
                            allFuelItem.costTariff = this.priceItemsMap.get(pricelistKey + '_All: Fuel').Unit__c;
                            this.costsColumnsMap.get('2_2').add(allFuelItem);
                            allNonFuelItem.costValue = this.priceItemsMap.get(pricelistKey + '_All: Non-Fuel').Price__c;
                            allNonFuelItem.costTariff = this.priceItemsMap.get(pricelistKey + '_All: Non-Fuel').Unit__c;
                            this.costsColumnsMap.get('2_2').add(allNonFuelItem);
                        }
                        // Duplicate invoice payment
                        duplicatePaymentItem.costValue = this.priceItemsMap.get(pricelistKey + '_Duplicate Invoice').Price__c;
                        duplicatePaymentItem.costTariff = this.priceItemsMap.get(pricelistKey + '_Duplicate Invoice').Unit__c;
                        // Late invoice payment
                        latePaymentItem.costValue = this.priceItemsMap.get(pricelistKey + '_Late Invoice').Price__c;
                        latePaymentItem.costTariff = this.priceItemsMap.get(pricelistKey + '_Late Invoice').Unit__c;
                        // Card replacement
                        cardReplacementPaymentItem.costValue = this.priceItemsMap.get(pricelistKey + '_Card replacement').Price__c;
                        cardReplacementPaymentItem.costTariff = this.priceItemsMap.get(pricelistKey + '_Card replacement').Unit__c;
                    } else {
                        // Duplicate invoice payment
                        duplicatePaymentItem.costValue = this.priceItemsMap.get(pricelistKey + '_Duplicate Invoice').Price__c;
                        duplicatePaymentItem.costTariff = this.priceItemsMap.get(pricelistKey + '_Duplicate Invoice').Unit__c;
                        // Late invoice payment
                        latePaymentItem.costValue = this.priceItemsMap.get(pricelistKey + '_Late Invoice').Price__c;
                        latePaymentItem.costTariff = this.priceItemsMap.get(pricelistKey + '_Late Invoice').Unit__c;
                        // Card replacement
                        cardReplacementPaymentItem.costValue = this.priceItemsMap.get(pricelistKey + '_Card replacement').Price__c;
                        cardReplacementPaymentItem.costTariff = this.priceItemsMap.get(pricelistKey + '_Card replacement').Unit__c;
                        this.showInternationalFeesBlock = false;
                    }
                    appliedPerAccount = false;
                }

                // PER CARD
                if (lfCard.pumpOutsideCountry) {
                    // Monthly fee
                    if (this.opportunity.Zahlungsart__c == 'Lastschrift') {
                        monthlyFeeItem.costValue += this.priceItemsMap.get(pricelistKey + '_Monthly Direct Debit').Price__c;
                        monthlyFeeItem.costTariff = this.priceItemsMap.get(pricelistKey + '_Monthly Direct Debit').Unit__c;
                    } else if (this.opportunity.Zahlungsart__c == 'Banküberweisung') {
                        monthlyFeeItem.costValue += this.priceItemsMap.get(pricelistKey + '_Monthly Bank Transfer').Price__c;
                        monthlyFeeItem.costTariff = this.priceItemsMap.get(pricelistKey + '_Monthly Bank Transfer').Unit__c;
                    }
                } else {
                    // Monthly fee
                    if (this.opportunity.Zahlungsart__c == 'Lastschrift') {
                        monthlyFeeItem.costValue += this.priceItemsMap.get(pricelistKey + '_Monthly Direct Debit').Price__c;
                        monthlyFeeItem.costTariff = this.priceItemsMap.get(pricelistKey + '_Monthly Direct Debit').Unit__c;
                    } else if (this.opportunity.Zahlungsart__c == 'Banküberweisung') {
                        monthlyFeeItem.costValue += this.priceItemsMap.get(pricelistKey + '_Monthly Bank Transfer').Price__c;
                        monthlyFeeItem.costTariff = this.priceItemsMap.get(pricelistKey + '_Monthly Bank Transfer').Unit__c;
                    }
                }
                // One time set up fee (per Card)
                // oneTimeSetupFeeItem.costValue += this.priceItemsMap.get(pricelistKey + '_One Time Card Set Up').Price__c;
                // oneTimeSetupFeeItem.costTariff = this.priceItemsMap.get(pricelistKey + '_One Time Card Set Up').Unit__c;
            }
        } else if (this.activeCardConfigTab == 'diff') {
            Boolean lfCardIsConfigurated = true;
            Boolean fuelShellFeeSpecified = false;
            Boolean pumpAtPartnersFeeSpecified = false;
            Boolean nonFuelShellFeeSpecified = false;
            Boolean internationalTransacFeeSpecified = false;
            for (LongFormCard lfCard : this.diffCardsMap.values()) {
                if (lfCard.pumpOutsideCountry == true && lfCard.pumpAtPartners == false) {
                    pricelistKey = 'International Not Partners';
                } else if (lfCard.pumpOutsideCountry == true && lfCard.pumpAtPartners == true) {
                    pricelistKey = 'International Partners';
                } else if (lfCard.pumpOutsideCountry == false && lfCard.pumpAtPartners == false) {
                    pricelistKey = 'National Not Partners';
                } else if (lfCard.pumpOutsideCountry == false && lfCard.pumpAtPartners == true) {
                    pricelistKey = 'National Partners';
                }
                // PER ACCOUNT
                if (appliedPerAccount == true) {
                    oneTimeSetupFeeItem.costValue = this.priceItemsMap.get(pricelistKey + '_One Time Account Set Up').Price__c;
                    appliedPerAccount = false;
                }

                if (fuelShellFeeSpecified == false) {
                    // Fuel (Shell)
                    if (this.priceItemsMap.get(pricelistKey + '_Transaction Shell Home Fuel').Price__c == this.priceItemsMap.get(pricelistKey + '_Transaction Shell Non-Home Fuel').Price__c) {
                        fuelShellItem.costValue = this.priceItemsMap.get(pricelistKey + '_Transaction Shell Home Fuel').Price__c;
                        fuelShellItem.costTariff = this.priceItemsMap.get(pricelistKey + '_Transaction Shell Home Fuel').Unit__c;
                        this.costsColumnsMap.get('2_1').add(fuelShellItem);
                    } else {
                        fuelShellFavoriteItem.costValue = this.priceItemsMap.get(pricelistKey + '_Transaction Shell Home Fuel').Price__c;
                        fuelShellFavoriteItem.costTariff = this.priceItemsMap.get(pricelistKey + '_Transaction Shell Home Fuel').Unit__c;
                        this.costsColumnsMap.get('2_1').add(fuelShellFavoriteItem);
                        fuelShellOtherItem.costValue = this.priceItemsMap.get(pricelistKey + '_Transaction Shell Non-Home Fuel').Price__c;
                        fuelShellOtherItem.costTariff = this.priceItemsMap.get(pricelistKey + '_Transaction Shell Non-Home Fuel').Unit__c;
                        this.costsColumnsMap.get('2_1').add(fuelShellOtherItem);
                    }
                    fuelShellFeeSpecified = true;
                }

                if (lfCard.pumpAtPartners && pumpAtPartnersFeeSpecified == false) {
                    // Shell Partner
                    if (this.priceItemsMap.get(pricelistKey + '_Transaction Shell Partner Fuel').Price__c == this.priceItemsMap.get(pricelistKey + '_Transaction Shell Partner Non-Fuel').Price__c) {
                        shellPartnerItem.costValue = this.priceItemsMap.get(pricelistKey + '_Transaction Shell Partner Fuel').Price__c;
                        shellPartnerItem.costTariff = this.priceItemsMap.get(pricelistKey + '_Transaction Shell Partner Fuel').Unit__c;
                        this.costsColumnsMap.get('2_1').add(shellPartnerItem);
                    } else {
                        fuelShellPartnerItem.costValue = this.priceItemsMap.get(pricelistKey + '_Transaction Shell Partner Fuel').Price__c;
                        fuelShellPartnerItem.costTariff = this.priceItemsMap.get(pricelistKey + '_Transaction Shell Partner Fuel').Unit__c;
                        this.costsColumnsMap.get('2_1').add(fuelShellPartnerItem);
                        nonFuelShellPartnerItem.costValue = this.priceItemsMap.get(pricelistKey + '_Transaction Shell Partner Non-Fuel').Price__c;
                        nonFuelShellPartnerItem.costTariff = this.priceItemsMap.get(pricelistKey + '_Transaction Shell Partner Non-Fuel').Unit__c;
                        this.costsColumnsMap.get('2_1').add(nonFuelShellPartnerItem);
                    }
                    pumpAtPartnersFeeSpecified = true;
                }

                if (nonFuelShellFeeSpecified == false) {
                    // Non-fuel
                    if (this.priceItemsMap.get(pricelistKey + '_Transaction Shell Home Non-Fuel').Price__c == this.priceItemsMap.get(pricelistKey + '_Transaction Shell Non-Home Non-Fuel').Price__c) {
                        nonFuelItem.costValue = this.priceItemsMap.get(pricelistKey + '_Transaction Shell Home Non-Fuel').Price__c;
                        nonFuelItem.costTariff = this.priceItemsMap.get(pricelistKey + '_Transaction Shell Home Non-Fuel').Unit__c;
                        this.costsColumnsMap.get('2_1').add(nonFuelItem);
                    } else {
                        nonFuelShellFavoriteItem.costValue = this.priceItemsMap.get(pricelistKey + '_Transaction Shell Home Non-Fuel').Price__c;
                        nonFuelShellFavoriteItem.costTariff = this.priceItemsMap.get(pricelistKey + '_Transaction Shell Home Non-Fuel').Unit__c;
                        this.costsColumnsMap.get('2_1').add(nonFuelShellFavoriteItem);
                        nonFuelShellOtherItem.costValue = this.priceItemsMap.get(pricelistKey + '_Transaction Shell Non-Home Non-Fuel').Price__c;
                        nonFuelShellOtherItem.costTariff = this.priceItemsMap.get(pricelistKey + '_Transaction Shell Non-Home Non-Fuel').Unit__c;
                        this.costsColumnsMap.get('2_1').add(nonFuelShellOtherItem);
                    }
                    nonFuelShellFeeSpecified = true;
                }

                if (lfCard.pumpOutsideCountry) {
                    if (internationalTransacFeeSpecified == false) {
                        this.showInternationalFeesBlock = true;
                        // All types
                        if (this.priceItemsMap.get(pricelistKey + '_All: Fuel').Price__c == this.priceItemsMap.get(pricelistKey + '_All: Non-Fuel').Price__c) {
                            allTypesItem.costValue = this.priceItemsMap.get(pricelistKey + '_All: Fuel').Price__c;
                            allTypesItem.costTariff = this.priceItemsMap.get(pricelistKey + '_All: Fuel').Unit__c;
                            this.costsColumnsMap.get('2_2').add(allTypesItem);
                        } else {
                            allFuelItem.costValue = this.priceItemsMap.get(pricelistKey + '_All: Fuel').Price__c;
                            allFuelItem.costTariff = this.priceItemsMap.get(pricelistKey + '_All: Fuel').Unit__c;
                            this.costsColumnsMap.get('2_2').add(allFuelItem);
                            allNonFuelItem.costValue = this.priceItemsMap.get(pricelistKey + '_All: Non-Fuel').Price__c;
                            allNonFuelItem.costTariff = this.priceItemsMap.get(pricelistKey + '_All: Non-Fuel').Unit__c;
                            this.costsColumnsMap.get('2_2').add(allNonFuelItem);
                        }
                        internationalTransacFeeSpecified = true;
                    }
                } else {
                    if (internationalTransacFeeSpecified == false) {
                        this.showInternationalFeesBlock = false;
                    }
                }
                // Duplicate invoice payment
                duplicatePaymentItem.costValue = this.priceItemsMap.get(pricelistKey + '_Duplicate Invoice').Price__c;
                duplicatePaymentItem.costTariff = this.priceItemsMap.get(pricelistKey + '_Duplicate Invoice').Unit__c;
                // Late invoice payment
                latePaymentItem.costValue = this.priceItemsMap.get(pricelistKey + '_Late Invoice').Price__c;
                latePaymentItem.costTariff = this.priceItemsMap.get(pricelistKey + '_Late Invoice').Unit__c;
                // Card replacement
                cardReplacementPaymentItem.costValue = this.priceItemsMap.get(pricelistKey + '_Card replacement').Price__c;
                cardReplacementPaymentItem.costTariff = this.priceItemsMap.get(pricelistKey + '_Card replacement').Unit__c;


                //PER CARD
                if (lfCard.pumpOutsideCountry) {
                    // Monthly fee
                    if (this.opportunity.Zahlungsart__c == 'Lastschrift') {
                        monthlyFeeItem.costValue += this.priceItemsMap.get(pricelistKey + '_Monthly Direct Debit').Price__c;
                        monthlyFeeItem.costTariff = this.priceItemsMap.get(pricelistKey + '_Monthly Direct Debit').Unit__c;
                    } else if (this.opportunity.Zahlungsart__c == 'Banküberweisung') {
                        monthlyFeeItem.costValue += this.priceItemsMap.get(pricelistKey + '_Monthly Bank Transfer').Price__c;
                        monthlyFeeItem.costTariff = this.priceItemsMap.get(pricelistKey + '_Monthly Bank Transfer').Unit__c;
                    }
                    // One time set up fee (per Card)
                    oneTimeSetupFeeItem.costValue += this.priceItemsMap.get(pricelistKey + '_One Time Card Set Up').Price__c;
                    oneTimeSetupFeeItem.costTariff = this.priceItemsMap.get(pricelistKey + '_One Time Card Set Up').Unit__c;
                } else {
                    // Monthly fee
                    if (this.opportunity.Zahlungsart__c == 'Lastschrift') {
                        monthlyFeeItem.costValue += this.priceItemsMap.get(pricelistKey + '_Monthly Direct Debit').Price__c;
                        monthlyFeeItem.costTariff = this.priceItemsMap.get(pricelistKey + '_Monthly Direct Debit').Unit__c;
                    } else if (this.opportunity.Zahlungsart__c == 'Banküberweisung') {
                        monthlyFeeItem.costValue += this.priceItemsMap.get(pricelistKey + '_Monthly Bank Transfer').Price__c;
                        monthlyFeeItem.costTariff = this.priceItemsMap.get(pricelistKey + '_Monthly Bank Transfer').Unit__c;
                    }
                    // One time set up fee (per Card)
                    oneTimeSetupFeeItem.costValue += this.priceItemsMap.get(pricelistKey + '_One Time Card Set Up').Price__c;
                    oneTimeSetupFeeItem.costTariff = this.priceItemsMap.get(pricelistKey + '_One Time Card Set Up').Unit__c;
                }

                if (lfCard.cardIsConfigurated == false) {
                    lfCardIsConfigurated = false;
                }
            }
        }

        this.costsColumnsMap.get('1').add(monthlyFeeItem);
        // this.costsColumnsMap.get('1').add(oneTimeSetupFeeItem);
        this.costsColumnsMap.get('3').add(duplicatePaymentItem);
        this.costsColumnsMap.get('3').add(latePaymentItem);
        // this.costsColumnsMap.get('3').add(cardReplacementPaymentItem);

        LongFormCostItem discountItem = new LongFormCostItem();
        Integer oneTimeDiscount = 20; // one-time discount 20 euro
        Decimal discountFinal;
        Decimal sumAllDiscounts = 0;
        List<LongFormSpecialOffer> allOffersList = new List<LongFormSpecialOffer>();
        if (this.homeOffersList != null && this.nonHomeOffersList != null) {
            allOffersList.addAll(this.homeOffersList);
            allOffersList.addAll(this.nonHomeOffersList);

            for (LongFormSpecialOffer specialOffer : allOffersList) {
                String discount = specialOffer.offerDiscount.substringBefore(' ');
                discount = discount.replace('-', '');
                if (this.opportunity.Product__c != null && this.opportunity.Product__c == specialOffer.productName) {
                    discountFinal = 0;
                    discountFinal = Decimal.valueOf(discount) / 100;
                    break;
                } else {
                    sumAllDiscounts += Decimal.valueOf(discount) / 100;
                }
            }
            if (discountFinal == null && allOffersList.size() != 0) discountFinal = sumAllDiscounts / allOffersList.size();
            discountItem.discountValue = ((this.opportunity.Total_consumption_l_month__c * discountFinal * 12) + oneTimeDiscount).setScale(0);
            this.costsColumnsMap.get('DISCOUNT').add(discountItem);
        }
    }


    /*******************************************************************************
    *  Name            : setCostsColumnsMapMobile()
    *  Summary         : calculate fees and costs for current columns
    *  CreatedDate     : 24/06/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void setCostsColumnsMapMobile() {
        // 1. SERVICE FEES
        // 1.1 Monthly fee
        LongFormCostItem monthlyFeeItem = new LongFormCostItem();
        monthlyFeeItem.contentName = 'MONTHLY FEE HEADING';
        monthlyFeeItem.costValue = 0;
        // 1.2 One time set up fee
        LongFormCostItem oneTimeSetupFeeItem = new LongFormCostItem();
        oneTimeSetupFeeItem.contentName = 'ONE TIME FEE HEADING';
        // oneTimeSetupFeeItem.style = 'margin-top: 18px';
        oneTimeSetupFeeItem.costValue = 0;
        // 2. NATIONAL TRANSACTIONS
        // 2.1 Fuel (Shell)
        LongFormCostItem fuelShellItem = new LongFormCostItem();
        fuelShellItem.contentName = 'FUEL SHELL';
        fuelShellItem.contentHelp = 'FUEL SHELL HELP';
        fuelShellItem.showHelpItem = false;
        fuelShellItem.costValue = 0;
        // 2.2 Fuel (Shell Favorite)
        LongFormCostItem fuelShellFavoriteItem = new LongFormCostItem();
        fuelShellFavoriteItem.contentName = 'FUEL SHELL FAVORITE';
        fuelShellFavoriteItem.contentHelp = 'FUEL SHELL FAVORITE HELP';
        fuelShellFavoriteItem.showHelpItem = false;
        fuelShellFavoriteItem.costValue = 0;
        // 2.3 Fuel (Shell Other)
        LongFormCostItem fuelShellOtherItem = new LongFormCostItem();
        fuelShellOtherItem.contentName = 'FUEL SHELL OTHER';
        fuelShellOtherItem.contentHelp = 'FUEL SHELL OTHER HELP';
        fuelShellOtherItem.showHelpItem = false;
        fuelShellOtherItem.costValue = 0;
        // 2.4 Shell Partner
        LongFormCostItem shellPartnerItem = new LongFormCostItem();
        shellPartnerItem.contentName = 'SHELL PARTNER';
        shellPartnerItem.contentHelp = 'SHELL PARTNER HELP';
        shellPartnerItem.showHelpItem = true;
        shellPartnerItem.costValue = 0;
        // 2.5 Fuel (Shell Partner)
        LongFormCostItem fuelShellPartnerItem = new LongFormCostItem();
        fuelShellPartnerItem.contentName = 'FUEL SHELL PARTNER';
        fuelShellPartnerItem.contentHelp = 'FUEL SHELL PARTNER HELP';
        fuelShellPartnerItem.showHelpItem = true;
        fuelShellPartnerItem.costValue = 0;
        // 2.6 Non-fuel (Shell Partner)
        LongFormCostItem nonFuelShellPartnerItem = new LongFormCostItem();
        nonFuelShellPartnerItem.contentName = 'NON-FUEL SHELL PARTNER';
        nonFuelShellPartnerItem.contentHelp = 'NON-FUEL SHELL PARTNER HELP';
        nonFuelShellPartnerItem.showHelpItem = true;
        nonFuelShellPartnerItem.costValue = 0;
        // 2.7 Non-fuel
        LongFormCostItem nonFuelItem = new LongFormCostItem();
        nonFuelItem.contentName = 'NON-FUEL';
        nonFuelItem.contentHelp = 'NON-FUEL HELP';
        nonFuelItem.showHelpItem = true;
        nonFuelItem.costValue = 0;
        // 2.8 Non-fuel (Shell Favorite)
        LongFormCostItem nonFuelShellFavoriteItem = new LongFormCostItem();
        nonFuelShellFavoriteItem.contentName = 'NON-FUEL SHELL FAVORITE';
        nonFuelShellFavoriteItem.contentHelp = 'NON-FUEL SHELL FAVORITE HELP';
        nonFuelShellFavoriteItem.showHelpItem = true;
        nonFuelShellFavoriteItem.costValue = 0;
        // 2.9 Non-fuel (Shell Other)
        LongFormCostItem nonFuelShellOtherItem = new LongFormCostItem();
        nonFuelShellOtherItem.contentName = 'NON-FUEL SHELL OTHER';
        nonFuelShellOtherItem.contentHelp = 'NON-FUEL SHELL OTHER HELP';
        nonFuelShellOtherItem.showHelpItem = true;
        nonFuelShellOtherItem.costValue = 0;
        // 3. INTERNATIONAL TRANSACTIONS
        // 3.1 All types
        LongFormCostItem allTypesItem = new LongFormCostItem();
        allTypesItem.contentName = 'ALL TYPES';
        allTypesItem.contentHelp = 'ALL TYPES HELP';
        allTypesItem.showHelpItem = false;
        allTypesItem.costValue = 0;
        // 3.2 All: Fuel
        LongFormCostItem allFuelItem = new LongFormCostItem();
        allFuelItem.contentName = 'ALL FUEL';
        allFuelItem.contentHelp = 'ALL FUEL HELP';
        allFuelItem.showHelpItem = false;
        allFuelItem.costValue = 0;
        // 3.1 All: Non-fuel
        LongFormCostItem allNonFuelItem = new LongFormCostItem();
        allNonFuelItem.contentName = 'ALL NON FUEL';
        allNonFuelItem.contentHelp = 'ALL NON FUEL HELP';
        allNonFuelItem.showHelpItem = false;
        allNonFuelItem.costValue = 0;
        // 4. OTHER FEES
        // 4.1 Duplicate invoice payment
        LongFormCostItem duplicatePaymentItem = new LongFormCostItem();
        duplicatePaymentItem.contentName = 'DUPLICATE PAYMENT';
        duplicatePaymentItem.contentHelp = 'DUPLICATE PAYMENT HELP';
        duplicatePaymentItem.showHelpItem = true;
        duplicatePaymentItem.costValue = 0;
        // 4.2 Late invoice payment
        LongFormCostItem latePaymentItem = new LongFormCostItem();
        latePaymentItem.contentName = 'LATE PAYMENT';
        latePaymentItem.contentHelp = 'LATE PAYMENT HELP';
        latePaymentItem.showHelpItem = true;
        latePaymentItem.style = 'margin-bottom: 0;';
        latePaymentItem.costValue = 0;
        // 4.3 Card replacement
        LongFormCostItem cardReplacementPaymentItem = new LongFormCostItem();
        cardReplacementPaymentItem.contentName = 'CARD REPLACEMENT';
        cardReplacementPaymentItem.contentHelp = '';
        cardReplacementPaymentItem.showHelpItem = false;
        cardReplacementPaymentItem.costValue = 0;

        this.costsColumnsMap = new Map<String, List<LongFormCostItem>>();
        this.costsColumnsMap.put('1', new List<LongFormCostItem>());
        this.costsColumnsMap.put('2_1', new List<LongFormCostItem>());
        this.costsColumnsMap.put('2_2', new List<LongFormCostItem>());
        this.costsColumnsMap.put('3', new List<LongFormCostItem>());
        this.costsColumnsMap.put('DISCOUNT', new List<LongFormCostItem>());
        String pricelistKey;
        Boolean appliedPerAccount = true;
        Boolean lfCardIsConfigurated = true;
        Boolean fuelShellFeeSpecified = false;
        Boolean pumpAtPartnersFeeSpecified = false;
        Boolean nonFuelShellFeeSpecified = false;
        Boolean internationalTransacFeeSpecified = false;
        for (LongFormCard lfCard : this.finalCardsMap.values()) {
           if (lfCard.pumpOutsideCountry == true && lfCard.pumpAtPartners == false) {
               pricelistKey = 'International Not Partners';
           } else if (lfCard.pumpOutsideCountry == true && lfCard.pumpAtPartners == true) {
               pricelistKey = 'International Partners';
           } else if (lfCard.pumpOutsideCountry == false && lfCard.pumpAtPartners == false) {
               pricelistKey = 'National Not Partners';
           } else if (lfCard.pumpOutsideCountry == false && lfCard.pumpAtPartners == true) {
               pricelistKey = 'National Partners';
           }
           // PER ACCOUNT
           if (appliedPerAccount == true) {
               oneTimeSetupFeeItem.costValue = this.priceItemsMap.get(pricelistKey + '_One Time Account Set Up').Price__c;
               appliedPerAccount = false;
           }

           if (fuelShellFeeSpecified == false) {
               // Fuel (Shell)
               if (this.priceItemsMap.get(pricelistKey + '_Transaction Shell Home Fuel').Price__c == this.priceItemsMap.get(pricelistKey + '_Transaction Shell Non-Home Fuel').Price__c) {
                   fuelShellItem.costValue = this.priceItemsMap.get(pricelistKey + '_Transaction Shell Home Fuel').Price__c;
                   fuelShellItem.costTariff = this.priceItemsMap.get(pricelistKey + '_Transaction Shell Home Fuel').Unit__c;
                   this.costsColumnsMap.get('2_1').add(fuelShellItem);
               } else {
                   fuelShellFavoriteItem.costValue = this.priceItemsMap.get(pricelistKey + '_Transaction Shell Home Fuel').Price__c;
                   fuelShellFavoriteItem.costTariff = this.priceItemsMap.get(pricelistKey + '_Transaction Shell Home Fuel').Unit__c;
                   this.costsColumnsMap.get('2_1').add(fuelShellFavoriteItem);
                   fuelShellOtherItem.costValue = this.priceItemsMap.get(pricelistKey + '_Transaction Shell Non-Home Fuel').Price__c;
                   fuelShellOtherItem.costTariff = this.priceItemsMap.get(pricelistKey + '_Transaction Shell Non-Home Fuel').Unit__c;
                   this.costsColumnsMap.get('2_1').add(fuelShellOtherItem);
               }
               fuelShellFeeSpecified = true;
           }

           if (lfCard.pumpAtPartners && pumpAtPartnersFeeSpecified == false) {
               // Shell Partner
               if (this.priceItemsMap.get(pricelistKey + '_Transaction Shell Partner Fuel').Price__c == this.priceItemsMap.get(pricelistKey + '_Transaction Shell Partner Non-Fuel').Price__c) {
                   shellPartnerItem.costValue = this.priceItemsMap.get(pricelistKey + '_Transaction Shell Partner Fuel').Price__c;
                   shellPartnerItem.costTariff = this.priceItemsMap.get(pricelistKey + '_Transaction Shell Partner Fuel').Unit__c;
                   this.costsColumnsMap.get('2_1').add(shellPartnerItem);
               } else {
                   fuelShellPartnerItem.costValue = this.priceItemsMap.get(pricelistKey + '_Transaction Shell Partner Fuel').Price__c;
                   fuelShellPartnerItem.costTariff = this.priceItemsMap.get(pricelistKey + '_Transaction Shell Partner Fuel').Unit__c;
                   this.costsColumnsMap.get('2_1').add(fuelShellPartnerItem);
                   nonFuelShellPartnerItem.costValue = this.priceItemsMap.get(pricelistKey + '_Transaction Shell Partner Non-Fuel').Price__c;
                   nonFuelShellPartnerItem.costTariff = this.priceItemsMap.get(pricelistKey + '_Transaction Shell Partner Non-Fuel').Unit__c;
                   this.costsColumnsMap.get('2_1').add(nonFuelShellPartnerItem);
               }
               pumpAtPartnersFeeSpecified = true;
           }

           if (nonFuelShellFeeSpecified == false) {
               // Non-fuel
               if (this.priceItemsMap.get(pricelistKey + '_Transaction Shell Home Non-Fuel').Price__c == this.priceItemsMap.get(pricelistKey + '_Transaction Shell Non-Home Non-Fuel').Price__c) {
                   nonFuelItem.costValue = this.priceItemsMap.get(pricelistKey + '_Transaction Shell Home Non-Fuel').Price__c;
                   nonFuelItem.costTariff = this.priceItemsMap.get(pricelistKey + '_Transaction Shell Home Non-Fuel').Unit__c;
                   this.costsColumnsMap.get('2_1').add(nonFuelItem);
               } else {
                   nonFuelShellFavoriteItem.costValue = this.priceItemsMap.get(pricelistKey + '_Transaction Shell Home Non-Fuel').Price__c;
                   nonFuelShellFavoriteItem.costTariff = this.priceItemsMap.get(pricelistKey + '_Transaction Shell Home Non-Fuel').Unit__c;
                   this.costsColumnsMap.get('2_1').add(nonFuelShellFavoriteItem);
                   nonFuelShellOtherItem.costValue = this.priceItemsMap.get(pricelistKey + '_Transaction Shell Non-Home Non-Fuel').Price__c;
                   nonFuelShellOtherItem.costTariff = this.priceItemsMap.get(pricelistKey + '_Transaction Shell Non-Home Non-Fuel').Unit__c;
                   this.costsColumnsMap.get('2_1').add(nonFuelShellOtherItem);
               }
               nonFuelShellFeeSpecified = true;
           }
           if (lfCard.pumpOutsideCountry) {
               if (internationalTransacFeeSpecified == false) {
                   this.showInternationalFeesBlock = true;
                   // All types
                   if (this.priceItemsMap.get(pricelistKey + '_All: Fuel').Price__c == this.priceItemsMap.get(pricelistKey + '_All: Non-Fuel').Price__c) {
                       allTypesItem.costValue = this.priceItemsMap.get(pricelistKey + '_All: Fuel').Price__c;
                       allTypesItem.costTariff = this.priceItemsMap.get(pricelistKey + '_All: Fuel').Unit__c;
                       this.costsColumnsMap.get('2_2').add(allTypesItem);
                   } else {
                       allFuelItem.costValue = this.priceItemsMap.get(pricelistKey + '_All: Fuel').Price__c;
                       allFuelItem.costTariff = this.priceItemsMap.get(pricelistKey + '_All: Fuel').Unit__c;
                       this.costsColumnsMap.get('2_2').add(allFuelItem);
                       allNonFuelItem.costValue = this.priceItemsMap.get(pricelistKey + '_All: Non-Fuel').Price__c;
                       allNonFuelItem.costTariff = this.priceItemsMap.get(pricelistKey + '_All: Non-Fuel').Unit__c;
                       this.costsColumnsMap.get('2_2').add(allNonFuelItem);
                   }
                   internationalTransacFeeSpecified = true;
               }
           } else {
               if (internationalTransacFeeSpecified == false) {
                   this.showInternationalFeesBlock = false;
               }
           }
           // Duplicate invoice payment
           duplicatePaymentItem.costValue = this.priceItemsMap.get(pricelistKey + '_Duplicate Invoice').Price__c;
           duplicatePaymentItem.costTariff = this.priceItemsMap.get(pricelistKey + '_Duplicate Invoice').Unit__c;
           // Late invoice payment
           latePaymentItem.costValue = this.priceItemsMap.get(pricelistKey + '_Late Invoice').Price__c;
           latePaymentItem.costTariff = this.priceItemsMap.get(pricelistKey + '_Late Invoice').Unit__c;
            // Card replacement
            cardReplacementPaymentItem.costValue = this.priceItemsMap.get(pricelistKey + '_Card replacement').Price__c;
            cardReplacementPaymentItem.costTariff = this.priceItemsMap.get(pricelistKey + '_Card replacement').Unit__c;

           //PER CARD
           if (lfCard.pumpOutsideCountry) {
               // Monthly fee
               if (this.opportunity.Zahlungsart__c == 'Lastschrift') {
                   monthlyFeeItem.costValue += this.priceItemsMap.get(pricelistKey + '_Monthly Direct Debit').Price__c;
                   monthlyFeeItem.costTariff = this.priceItemsMap.get(pricelistKey + '_Monthly Direct Debit').Unit__c;
               } else if (this.opportunity.Zahlungsart__c == 'Banküberweisung') {
                   monthlyFeeItem.costValue += this.priceItemsMap.get(pricelistKey + '_Monthly Bank Transfer').Price__c;
                   monthlyFeeItem.costTariff = this.priceItemsMap.get(pricelistKey + '_Monthly Bank Transfer').Unit__c;
               }
               // One time set up fee (per Card)
               oneTimeSetupFeeItem.costValue += this.priceItemsMap.get(pricelistKey + '_One Time Card Set Up').Price__c;
               oneTimeSetupFeeItem.costTariff = this.priceItemsMap.get(pricelistKey + '_One Time Card Set Up').Unit__c;
           } else {
               // Monthly fee
               if (this.opportunity.Zahlungsart__c == 'Lastschrift') {
                   monthlyFeeItem.costValue += this.priceItemsMap.get(pricelistKey + '_Monthly Direct Debit').Price__c;
                   monthlyFeeItem.costTariff = this.priceItemsMap.get(pricelistKey + '_Monthly Direct Debit').Unit__c;
               } else if (this.opportunity.Zahlungsart__c == 'Banküberweisung') {
                   monthlyFeeItem.costValue += this.priceItemsMap.get(pricelistKey + '_Monthly Bank Transfer').Price__c;
                   monthlyFeeItem.costTariff = this.priceItemsMap.get(pricelistKey + '_Monthly Bank Transfer').Unit__c;
               }
               // One time set up fee (per Card)
               oneTimeSetupFeeItem.costValue += this.priceItemsMap.get(pricelistKey + '_One Time Card Set Up').Price__c;
               oneTimeSetupFeeItem.costTariff = this.priceItemsMap.get(pricelistKey + '_One Time Card Set Up').Unit__c;
           }

           if (lfCard.cardIsConfigurated == false) {
               lfCardIsConfigurated = false;
           }
        }

        this.costsColumnsMap.get('1').add(monthlyFeeItem);
        // this.costsColumnsMap.get('1').add(oneTimeSetupFeeItem);
        this.costsColumnsMap.get('3').add(duplicatePaymentItem);
        this.costsColumnsMap.get('3').add(latePaymentItem);
        // this.costsColumnsMap.get('3').add(cardReplacementPaymentItem);


        LongFormCostItem discountItem = new LongFormCostItem();
        Integer oneTimeDiscount = 20; // one-time discount 20 euro
        Decimal discountFinal;
        Decimal sumAllDiscounts = 0;
        List<LongFormSpecialOffer> allOffersList = new List<LongFormSpecialOffer>();
        if (this.homeOffersList != null && this.nonHomeOffersList != null) {
            allOffersList.addAll(this.homeOffersList);
            allOffersList.addAll(this.nonHomeOffersList);

            for (LongFormSpecialOffer specialOffer : allOffersList) {
                String discount = specialOffer.offerDiscount.substringBefore(' ');
                discount = discount.replace('-', '');
                if (this.opportunity.Product__c != null && this.opportunity.Product__c == specialOffer.productName) {
                    discountFinal = 0;
                    discountFinal = Decimal.valueOf(discount) / 100;
                    break;
                } else {
                    sumAllDiscounts += Decimal.valueOf(discount) / 100;
                }
            }
            if (discountFinal == null && allOffersList.size() != 0) discountFinal = sumAllDiscounts / allOffersList.size();
            discountItem.discountValue = ((this.opportunity.Total_consumption_l_month__c * discountFinal * 12) + oneTimeDiscount).setScale(0); 
            this.costsColumnsMap.get('DISCOUNT').add(discountItem);
        }
    }


    /*******************************************************************************
    *  Name            : getInternationalFeesBlock()
    *  Summary         : show international fees block or not
    *  CreatedDate     : 18/03/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Boolean true/false
    ******************************************************************************/
    public Boolean getInternationalFeesBlock() {
        return this.showInternationalFeesBlock;
    }


    /*******************************************************************************
    *  Name            : getCostsColumnsMap()
    *  Summary         : return fees and costs data
    *  CreatedDate     : 18/03/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Map<String, List<LongFormCostItem> costsColumnsMap
    ******************************************************************************/
    public Map<String, List<LongFormCostItem>> getCostsColumnsMap() {
        return this.costsColumnsMap;
    }


    /*******************************************************************************
    *  Name            : setActiveCardConfigTab(String activeTab)
    *  Summary         : set active tab of "Card configuration" step
    *  CreatedDate     : 18/03/2018
    *  ModifiedDate    : -
    *  Parameters      : String activeTab
    *  Returns         : void
    ******************************************************************************/
    public void setActiveCardConfigTab(String activeTab) {
        if (activeTab == 'diff') {
            if (this.numberOfCards < this.diffCardsMap.size()) {
                this.numberOfCards = this.diffCardsMap.size();
            }
        } else if (activeTab == 'same') {
            Integer currentNumberOfCard = this.sameCardsMap.size();
            if (currentNumberOfCard < this.numberOfCards) {
                for (Integer i = currentNumberOfCard + 1; i <= this.numberOfCards; i++) {
                    LongFormCard newCard = new LongFormCard();
                    newCard.categoryCard = this.sameCardsMap.get(1).categoryCard;
                    newCard.pumpOutsideCountry = this.sameCardsMap.get(1).pumpOutsideCountry;
                    newCard.pumpAtPartners = this.sameCardsMap.get(1).pumpAtPartners;
                    this.sameCardsMap.put(i, newCard);
                }
            } else if (currentNumberOfCard > this.numberOfCards) {
                for (Integer i = this.numberOfCards + 1; i <= currentNumberOfCard; i++) {
                    this.sameCardsMap.remove(i);
                }
            }
        }
        this.activeCardConfigTab = activeTab;
    }


    /*******************************************************************************
    *  Name            : getActiveCardConfigTab()
    *  Summary         : get active tab of "Card configuration" step
    *  CreatedDate     : 18/03/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : String activeCardConfigTab
    ******************************************************************************/
    public String getActiveCardConfigTab() {
        return this.activeCardConfigTab;
    }


    /*******************************************************************************
    *  Name            : getNumberOfCards()
    *  Summary         : get selected number of cards
    *  CreatedDate     : 18/03/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Integer numberOfCards
    ******************************************************************************/
    public Integer getNumberOfCards() {
        return this.numberOfCards;
    }


    /*******************************************************************************
    *  Name            : setCardParams()
    *  Summary         : set card parameters
    *  CreatedDate     : 18/03/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void setCardParams() {
        this.allSavedCardsMap = new Map<String, Tankkarten__c>([
            SELECT Account__c, Driver_Name__c, Fahrzeugtyp__c, Firmenname_auf_der_Karte__c, Gewuenschter_Kartentyp__c, Gross__c,
                KFZ_Kennzeichen_oder_Fahrername__c, Kilometerstand_Abfrage__c, Opportunity__c, Produktbezugskategorie__c, Zusatzinformation__c
            FROM Tankkarten__c
            WHERE Opportunity__c = :opportunity.Id
            LIMIT 100
        ]);
        this.diffCardsMap = new Map<Integer, LongFormCard>();
        this.sameCardsMap = new Map<Integer, LongFormCard>();
        Map<Integer, LongFormCard> allCardsMap = new Map<Integer, LongFormCard>();
        LongFormCard cardTemplate = new LongFormCard();

        if (this.pagesMap.get('CARD CONFIGURATION').fields.get('CARD TYPE 1').elementItemsMap.get('DEFAULT VALUE').Value__c == 'true') {
            cardTemplate.categoryCard = 'All vehicle related product';
        } else if (this.pagesMap.get('CARD CONFIGURATION').fields.get('CARD TYPE 2').elementItemsMap.get('DEFAULT VALUE').Value__c == 'true') {
            cardTemplate.categoryCard = 'All fuel types';
        } else if (this.pagesMap.get('CARD CONFIGURATION').fields.get('CARD TYPE 3').elementItemsMap.get('DEFAULT VALUE').Value__c == 'true') {
            cardTemplate.categoryCard = 'Diesel';
        }
        cardTemplate.pumpOutsideCountry = Boolean.valueOf(this.pagesMap.get('CARD CONFIGURATION').fields.get('PUMP LOCATION').elementItemsMap.get('DEFAULT VALUE').Value__c);
        cardTemplate.pumpAtPartners = Boolean.valueOf(this.pagesMap.get('CARD CONFIGURATION').fields.get('PUMP PARTNERS').elementItemsMap.get('DEFAULT VALUE').Value__c);
        cardTemplate.cardIsConfigurated = false;

        if (! this.allSavedCardsMap.isEmpty() ) {
            Set<String> cardCategoriesSet = new Set<String>();
            Set<String> cardTypesSet = new Set<String>();
            Integer counter = 1;
            for (Tankkarten__c card : this.allSavedCardsMap.values()) {
                cardCategoriesSet.add(card.Produktbezugskategorie__c);
                cardTypesSet.add(card.Gewuenschter_Kartentyp__c);
                LongFormCard lfCard = new LongFormCard();
                lfCard.sfCardId = card.Id;
                if (card.Produktbezugskategorie__c == '0 Diesel, Tunnel-, Maut- und Fährgebühren') {
                    lfCard.categoryCard = 'Diesel';
                } else if (card.Produktbezugskategorie__c == '1 Alle Kraftstoffe, Tunnel-, Maut- und Fährgebühren') {
                    lfCard.categoryCard = 'All fuel types';
                } else if (card.Produktbezugskategorie__c == '2 Kategorie 1 plus fahrzeugbezogene Waren und Dienstleistungen (Öle, Autowäsche)') {
                    lfCard.categoryCard = 'All vehicle related product';
                }

                if (card.Gewuenschter_Kartentyp__c == 'Single Network Card -- International') {
                    lfCard.pumpOutsideCountry = true;
                    lfCard.pumpAtPartners = false;
                } else if (card.Gewuenschter_Kartentyp__c == 'Multi Network Card -- International') {
                    lfCard.pumpOutsideCountry = true;
                    lfCard.pumpAtPartners = true;
                } else if (card.Gewuenschter_Kartentyp__c == 'Single Network Card -- National') {
                    lfCard.pumpOutsideCountry = false;
                    lfCard.pumpAtPartners = false;
                } else if (card.Gewuenschter_Kartentyp__c == 'Multi Network Card -- National') {
                    lfCard.pumpOutsideCountry = false;
                    lfCard.pumpAtPartners = true;
                }

                if (card.Driver_Name__c != null) {
                    lfCard.selectedDriverNameOrCarNumber = 'driver-name';
                    lfCard.driverNameOrCarNumberInputValue = card.Driver_Name__c;
                } else if (card.KFZ_Kennzeichen_oder_Fahrername__c != null) {
                    lfCard.selectedDriverNameOrCarNumber = 'car-number';
                    lfCard.driverNameOrCarNumberInputValue = card.KFZ_Kennzeichen_oder_Fahrername__c;
                } else {
                    lfCard.selectedDriverNameOrCarNumber = this.pagesMap.get('CARD CONFIGURATION. TECHNICAL PARAMETERS').fields.get('DRIVER OR CAR FIELD').elementItemsMap.get('BUTTON DEFAULT VALUE').Value__c;
                }

                lfCard.companyNameInputValue = card.Firmenname_auf_der_Karte__c;
                lfCard.displayCompanyNameField = false;
                lfCard.displayTechnicalParamsBlock = false;
                if (lfCard.driverNameOrCarNumberInputValue != null && lfCard.companyNameInputValue != null) {
                    lfCard.techParamsIsConfigurated = true;
                }

                if (card.Fahrzeugtyp__c == 'PKW') {
                    lfCard.selectedTypeOfCar = 'PKW';
                } else if (card.Fahrzeugtyp__c == 'LKW') {
                    lfCard.selectedTypeOfCar = 'LKW';
                } else {
                    lfCard.selectedTypeOfCar = this.pagesMap.get('CARD CONFIGURATION. TECHNICAL PARAMETERS').fields.get('TYPE OF CAR').elementItemsMap.get('DEFAULT VALUE').Value__c;
                }

                if ((card.Driver_Name__c != null || card.KFZ_Kennzeichen_oder_Fahrername__c != null) && card.Firmenname_auf_der_Karte__c != null && card.Fahrzeugtyp__c != null) {
                    lfCard.techParamsIsConfigurated = true;
                }

                lfCard.needOdometerOptions = card.Kilometerstand_Abfrage__c;
                if (Date.today().month() < 10) {
                    lfCard.emitDate = '0' + String.valueOf(Date.today().month()) + '/' + (String.valueOf(Date.today().year() + 4)).substring(2, 4);
                } else {
                    lfCard.emitDate = String.valueOf(Date.today().month()) + '/' + (String.valueOf(Date.today().year() + 4)).substring(2, 4);
                }

                lfCard.cardIsConfigurated = true;
                allCardsMap.put(counter, lfCard);
                counter++;
            }
            if (cardCategoriesSet.size() > 1 || cardTypesSet.size() > 1) {
                this.activeCardConfigTab = 'diff';
                this.diffCardsMap.putAll(allCardsMap);
                LongFormCard newCard = new LongFormCard();
                newCard.categoryCard = cardTemplate.categoryCard;
                newCard.pumpOutsideCountry = cardTemplate.pumpOutsideCountry;
                newCard.pumpAtPartners = cardTemplate.pumpAtPartners;
                newCard.cardIsConfigurated = cardTemplate.cardIsConfigurated;
                this.sameCardsMap.put(1, newCard);
            } else {
                this.activeCardConfigTab = 'same';
                this.sameCardsMap.putAll(allCardsMap);
                LongFormCard newCard = new LongFormCard();
                newCard.categoryCard = cardTemplate.categoryCard;
                newCard.pumpOutsideCountry = cardTemplate.pumpOutsideCountry;
                newCard.pumpAtPartners = cardTemplate.pumpAtPartners;
                newCard.cardIsConfigurated = cardTemplate.cardIsConfigurated;
                this.diffCardsMap.put(1, newCard);
            }
            this.numberOfCards = this.allSavedCardsMap.size();
        } else if (this.opportunity.E2E_Active_Substep__c == 'Card configuration') {
            this.activeCardConfigTab = 'same';
            LongFormCard diffCard = new LongFormCard();
            diffCard.categoryCard = cardTemplate.categoryCard;
            diffCard.pumpOutsideCountry = cardTemplate.pumpOutsideCountry;
            diffCard.pumpAtPartners = cardTemplate.pumpAtPartners;
            diffCard.cardIsConfigurated = cardTemplate.cardIsConfigurated;
            this.diffCardsMap.put(1, diffCard);
            LongFormCard sameCard = new LongFormCard();
            sameCard.categoryCard = cardTemplate.categoryCard;
            sameCard.pumpOutsideCountry = cardTemplate.pumpOutsideCountry;
            sameCard.pumpAtPartners = cardTemplate.pumpAtPartners;
            sameCard.cardIsConfigurated = cardTemplate.cardIsConfigurated;
            this.sameCardsMap.put(1, sameCard);
            this.numberOfCards = 1;
        } else {
            throw new LongFormException('Аt least one card in SF must be saved at this step');
        }
    }


    /*******************************************************************************
    *  Name            : Map<Integer, LongFormCard> getSameCards()
    *  Summary         : get cards from "same" tab
    *  CreatedDate     : 18/03/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Map<Integer, LongFormCard> sameCardsMap
    ******************************************************************************/
    public Map<Integer, LongFormCard> getSameCards() {
        return this.sameCardsMap;
    }


    /*******************************************************************************
    *  Name            : getDiffCards()
    *  Summary         : get cards from "different" tab
    *  CreatedDate     : 18/03/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Map<Integer, LongFormCard> diffCardsMap
    ******************************************************************************/
    public Map<Integer, LongFormCard> getDiffCards() {
        return this.diffCardsMap;
    }


    /*******************************************************************************
    *  Name            : setCardParamsMobile()
    *  Summary         : set card parameters for mobile version
    *  CreatedDate     : 20/06/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void setCardParamsMobile() {
        this.finalCardsMap = new Map<Integer, LongFormCard>();
        this.allSavedCardsMap = new Map<String, Tankkarten__c>([
           SELECT Account__c, Driver_Name__c, Fahrzeugtyp__c, Firmenname_auf_der_Karte__c, Gewuenschter_Kartentyp__c, Gross__c,
               KFZ_Kennzeichen_oder_Fahrername__c, Kilometerstand_Abfrage__c, Opportunity__c, Produktbezugskategorie__c, Zusatzinformation__c
           FROM Tankkarten__c
           WHERE Opportunity__c = :opportunity.Id
           LIMIT 100
        ]);

        if (! this.allSavedCardsMap.isEmpty() ) {
           Set<String> cardCategoriesSet = new Set<String>();
           Set<String> cardTypesSet = new Set<String>();
           Integer counter = 1;
           Boolean firstNotConfiguredCard = true;
           for (Tankkarten__c card : this.allSavedCardsMap.values()) {
               cardCategoriesSet.add(card.Produktbezugskategorie__c);
               cardTypesSet.add(card.Gewuenschter_Kartentyp__c);
               LongFormCard lfCard = new LongFormCard();
               lfCard.sfCardId = card.Id;
               if (card.Produktbezugskategorie__c == '0 Diesel, Tunnel-, Maut- und Fährgebühren') {
                   lfCard.categoryCard = 'Diesel';
               } else if (card.Produktbezugskategorie__c == '1 Alle Kraftstoffe, Tunnel-, Maut- und Fährgebühren') {
                   lfCard.categoryCard = 'All fuel types';
               } else if (card.Produktbezugskategorie__c == '2 Kategorie 1 plus fahrzeugbezogene Waren und Dienstleistungen (Öle, Autowäsche)') {
                   lfCard.categoryCard = 'All vehicle related product';
               }

               if (card.Gewuenschter_Kartentyp__c == 'Single Network Card -- International') {
                   lfCard.pumpOutsideCountry = true;
                   lfCard.pumpAtPartners = false;
               } else if (card.Gewuenschter_Kartentyp__c == 'Multi Network Card -- International') {
                   lfCard.pumpOutsideCountry = true;
                   lfCard.pumpAtPartners = true;
               } else if (card.Gewuenschter_Kartentyp__c == 'Single Network Card -- National') {
                   lfCard.pumpOutsideCountry = false;
                   lfCard.pumpAtPartners = false;
               } else if (card.Gewuenschter_Kartentyp__c == 'Multi Network Card -- National') {
                   lfCard.pumpOutsideCountry = false;
                   lfCard.pumpAtPartners = true;
               }

               if (card.Driver_Name__c != null) {
                   lfCard.selectedDriverNameOrCarNumber = 'driver-name';
                   lfCard.driverNameOrCarNumberInputValue = card.Driver_Name__c;
               } else if (card.KFZ_Kennzeichen_oder_Fahrername__c != null) {
                   lfCard.selectedDriverNameOrCarNumber = 'car-number';
                   lfCard.driverNameOrCarNumberInputValue = card.KFZ_Kennzeichen_oder_Fahrername__c;
               } else {
                   lfCard.selectedDriverNameOrCarNumber = this.pagesMap.get('CARD CONFIGURATION').fields.get('DRIVER OR CAR FIELD').elementItemsMap.get('DEFAULT VALUE').Value__c;
               }

               lfCard.companyNameInputValue = card.Firmenname_auf_der_Karte__c;
               lfCard.displayCompanyNameField = false;
               lfCard.displayTechnicalParamsBlock = false;

               if (card.Fahrzeugtyp__c == 'PKW') {
                   lfCard.selectedTypeOfCar = 'PKW';
               } else if (card.Fahrzeugtyp__c == 'LKW') {
                   lfCard.selectedTypeOfCar = 'LKW';
               } else {
                   lfCard.selectedTypeOfCar = this.pagesMap.get('CARD CONFIGURATION').fields.get('TYPE OF CAR').elementItemsMap.get('DEFAULT VALUE').Value__c;
               }

               if ((card.Driver_Name__c != null || card.KFZ_Kennzeichen_oder_Fahrername__c != null) && card.Firmenname_auf_der_Karte__c != null && card.Fahrzeugtyp__c != null) {
                   lfCard.techParamsIsConfigurated = true;
                   lfCard.cardIsConfigurated = true;
               } else if (firstNotConfiguredCard) {
                    lfCard.techParamsIsConfigurated = false;
                    lfCard.cardIsConfigurated = false;
                    lfCard.activeCardConfigStepMobile = 'Category';
                    lfCard.displayCompanyNameField = true;
                    firstNotConfiguredCard = false;
               } else {
                    lfCard.techParamsIsConfigurated = true;
                    lfCard.cardIsConfigurated = false;
                    lfCard.activeCardConfigStepMobile = 'Category';
                    lfCard.displayCompanyNameField = true;
               }

               lfCard.needOdometerOptions = card.Kilometerstand_Abfrage__c;
               if (Date.today().month() < 10) {
                   lfCard.emitDate = '0' + String.valueOf(Date.today().month()) + '/' + (String.valueOf(Date.today().year() + 4)).substring(2, 4);
               } else {
                   lfCard.emitDate = String.valueOf(Date.today().month()) + '/' + (String.valueOf(Date.today().year() + 4)).substring(2, 4);
               }

               this.finalCardsMap.put(counter, lfCard);
               counter++;
           }
        } else if (this.opportunity.E2E_Active_Substep__c == 'Card configuration') {
           LongFormCard lfcard = new LongFormCard();
           if (this.pagesMap.get('CARD CONFIGURATION').fields.get('CARD TYPE 1').elementItemsMap.get('DEFAULT VALUE').Value__c == 'true') {
               lfcard.categoryCard = 'All vehicle related product';
           } else if (this.pagesMap.get('CARD CONFIGURATION').fields.get('CARD TYPE 2').elementItemsMap.get('DEFAULT VALUE').Value__c == 'true') {
               lfcard.categoryCard = 'All fuel types';
           } else if (this.pagesMap.get('CARD CONFIGURATION').fields.get('CARD TYPE 3').elementItemsMap.get('DEFAULT VALUE').Value__c == 'true') {
               lfcard.categoryCard = 'Diesel';
           }
           lfCard.needOdometerOptions = Boolean.valueOf(this.pagesMap.get('CARD CONFIGURATION').fields.get('ODOMETER OPTIONS').elementItemsMap.get('DEFAULT VALUE').Value__c);
           lfcard.pumpOutsideCountry = Boolean.valueOf(this.pagesMap.get('CARD CONFIGURATION').fields.get('PUMP LOCATION').elementItemsMap.get('DEFAULT VALUE').Value__c);
           lfcard.pumpAtPartners = Boolean.valueOf(this.pagesMap.get('CARD CONFIGURATION').fields.get('PUMP PARTNERS').elementItemsMap.get('DEFAULT VALUE').Value__c);
           lfcard.selectedDriverNameOrCarNumber = this.pagesMap.get('CARD CONFIGURATION').fields.get('DRIVER OR CAR FIELD').elementItemsMap.get('DEFAULT VALUE').Value__c;
           lfcard.selectedTypeOfCar = this.pagesMap.get('CARD CONFIGURATION').fields.get('TYPE OF CAR').elementItemsMap.get('DEFAULT VALUE').Value__c;
           lfCard.displayCompanyNameField = true;
            if (this.account.Name.length() <= 25) {
                lfCard.companyNameInputValue = this.account.Name;
                lfCard.displayCompanyNameField = false;
            }
           lfcard.techParamsIsConfigurated = false;
           lfcard.cardIsConfigurated = false;
           lfcard.activeCardConfigStepMobile = 'Category';
           this.finalCardsMap.put(1, lfcard);
        } else {
           throw new LongFormException('Аt least one card in SF must be saved at this step');
        }
        this.numberOfCards = this.finalCardsMap.size();
    }


    /*******************************************************************************
    *  Name            : setFinalOrderCardsMap()
    *  Summary         : set final map with ordered cards
    *  CreatedDate     : 31/03/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : vid
    ******************************************************************************/
    public void setFinalOrderCardsMap() {
        this.finalCardsMap = new Map<Integer, LongFormCard>();
        if (this.activeCardConfigTab == 'same') {
            this.finalCardsMap.putAll(this.sameCardsMap);
        } else if (this.activeCardConfigTab == 'diff') {
            this.finalCardsMap.putAll(this.diffCardsMap);
        }
        String companyName;
        for (LongFormCard card : this.finalCardsMap.values()) {
            if (card.companyNameInputValue != null) {
                companyName = card.companyNameInputValue;
            }
        }
        // set default technical parameters
        Integer counter = 1;
        for (LongFormCard card : this.finalCardsMap.values()) {
            if (card.techParamsIsConfigurated == null) {
                card.selectedDriverNameOrCarNumber = this.pagesMap.get('CARD CONFIGURATION. TECHNICAL PARAMETERS').fields.get('DRIVER OR CAR FIELD').elementItemsMap.get('BUTTON DEFAULT VALUE').Value__c;
                card.selectedTypeOfCar = this.pagesMap.get('CARD CONFIGURATION. TECHNICAL PARAMETERS').fields.get('TYPE OF CAR').elementItemsMap.get('DEFAULT VALUE').Value__c;
                card.driverNameOrCarNumberInputValue = '';
                if (companyName != null) {
                    card.companyNameInputValue = companyName;
                    card.displayCompanyNameField = false;
                } else {
                    card.companyNameInputValue = '';
                    card.displayCompanyNameField = true;
                }
                if (counter == 1) {
                    card.displayTechnicalParamsBlock = true;
                } else {
                    card.displayTechnicalParamsBlock = false;
                }
                card.techParamsIsConfigurated = false;
                card.needOdometerOptions = Boolean.valueOf(this.pagesMap.get('CARD CONFIGURATION. TECHNICAL PARAMETERS').fields.get('TYPE OF CAR').elementItemsMap.get('DEFAULT VALUE').Value__c);
                if (Date.today().month() < 10) {
                    card.emitDate = '0' + String.valueOf(Date.today().month()) + '/' + (String.valueOf(Date.today().year() + 4)).substring(2, 4);
                } else {
                    card.emitDate = String.valueOf(Date.today().month()) + '/' + (String.valueOf(Date.today().year() + 4)).substring(2, 4);
                }
                counter++;
            }
        }
    }


    /*******************************************************************************
    *  Name            : Map<Integer, LongFormCard> getFinalOrderCardsMap()
    *  Summary         : get final map with ordered cards
    *  CreatedDate     : 31/03/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Map<Integer, LongFormCard> finalCardsMap
    ******************************************************************************/
    public Map<Integer, LongFormCard> getFinalOrderCardsMap() {
        return this.finalCardsMap;
    }


    /*******************************************************************************
    *  Name            : setEmbossingBlockVisibilityStatus()
    *  Summary         : set cards embossing visibility status
    *  CreatedDate     : 05/06/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void setEmbossingBlockVisibilityStatus() {
        this.showCardsEmbossingBlock = true;
        for (LongFormCard card : this.finalCardsMap.values()) {
            if (card.techParamsIsConfigurated == false) {
                this.showCardsEmbossingBlock = false;
                break;
            }
        }
    }


    /*******************************************************************************
    *  Name            : getEmbossingBlockVisibilityStatus()
    *  Summary         : return cards embossing visibility status
    *  CreatedDate     : 01/06/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Boolean showCardsEmbossingBlock
    ******************************************************************************/
    public Boolean getEmbossingBlockVisibilityStatus() {
        return this.showCardsEmbossingBlock;
    }


    /*******************************************************************************
    *  Name            : editTechnicalParameters(Integer cardindex)
    *  Summary         : do edit technical parameters
    *  CreatedDate     : 31/03/2018
    *  ModifiedDate    : -
    *  Parameters      : Integer cardindex
    *  Returns         : void
    ******************************************************************************/
    public void editTechnicalParameters(Integer cardindex) {
        this.finalCardsMap.get(cardindex).displayTechnicalParamsBlock = true;
        this.continueButtonIsDisabled = true;
        for (Integer key : this.finalCardsMap.keySet()) {
            if (key != cardindex) {
                this.finalCardsMap.get(key).displayTechnicalParamsBlock = false;
                if (this.finalCardsMap.get(key).companyNameInputValue != this.finalCardsMap.get(cardindex).companyNameInputValue) {
                    this.finalCardsMap.get(key).companyNameInputValue = this.finalCardsMap.get(cardindex).companyNameInputValue;
                }
                if (this.finalCardsMap.get(key).driverNameOrCarNumberInputValue == null || this.finalCardsMap.get(key).driverNameOrCarNumberInputValue == '' ||
                    this.finalCardsMap.get(key).companyNameInputValue == null || this.finalCardsMap.get(key).companyNameInputValue == '') {
                    this.finalCardsMap.get(key).techParamsIsConfigurated = false;
                } else if (this.finalCardsMap.get(key).companyNameInputValue != null && this.finalCardsMap.get(key).companyNameInputValue != '') {
                    this.finalCardsMap.get(key).displayCompanyNameField = false;
                }    
            }
        }          
    }


    /*******************************************************************************
    *  Name            : editCompanyName(Integer cardindex)
    *  Summary         : edit company name input field
    *  CreatedDate     : 31/03/2018
    *  ModifiedDate    : -
    *  Parameters      : Integer cardindex
    *  Returns         : void
    ******************************************************************************/
    public void editCompanyName(Integer cardindex) {
        this.finalCardsMap.get(cardindex).displayCompanyNameField = true;
    }


    /*******************************************************************************
    *  Name            : saveTechParamForSingleCard(Integer cardindex)
    *  Summary         : save technical params for single card
    *  CreatedDate     : 31/03/2018
    *  ModifiedDate    : -
    *  Parameters      : Integer cardindex
    *  Returns         : void
    ******************************************************************************/
    public void saveTechParamForSingleCard(Integer cardindex) {
        this.finalCardsMap.get(cardindex).driverNameOrCarNumberInputValue = 'Shell Card ' + cardindex;
        if(this.account.Name.length() <= 25) this.finalCardsMap.get(cardindex).companyNameInputValue = this.account.Name;
        if (this.finalCardsMap.get(cardindex).companyNameInputValue == null || this.finalCardsMap.get(cardindex).companyNameInputValue == '') {
            throw new LongFormException('Please fill in all required fields');
        }
        this.finalCardsMap.get(cardindex).displayTechnicalParamsBlock = false;
        this.finalCardsMap.get(cardindex).displayCompanyNameField = false;
        this.finalCardsMap.get(cardindex).techParamsIsConfigurated = true;
        Boolean showSingleTechParamsBlock = false;
        for (Integer key : this.finalCardsMap.keySet()) {
            if (key != cardindex) {
                if (this.finalCardsMap.get(key).techParamsIsConfigurated == false && showSingleTechParamsBlock == false) {
                    this.finalCardsMap.get(key).displayTechnicalParamsBlock = true;
                    showSingleTechParamsBlock = true;
                    this.continueButtonIsDisabled = true;
                } else {
                    this.continueButtonIsDisabled = false;
                }
                this.finalCardsMap.get(key).companyNameInputValue = this.finalCardsMap.get(cardindex).companyNameInputValue;
                this.finalCardsMap.get(key).displayCompanyNameField = false;
            }
        }
    }


    /*******************************************************************************
    *  Name            : saveTechParamForSingleCardMobile(Integer cardindex)
    *  Summary         : save technical params for single card
    *  CreatedDate     : 22/06/2018
    *  ModifiedDate    : -
    *  Parameters      : Integer cardindex
    *  Returns         : void
    ******************************************************************************/
    public void saveTechParamForSingleCardMobile(Integer cardindex) {
        this.finalCardsMap.get(cardindex).driverNameOrCarNumberInputValue = 'Shell Card ' + cardindex;
        if(this.account.Name.length() <= 25) this.finalCardsMap.get(cardindex).companyNameInputValue = this.account.Name;
        if (this.finalCardsMap.get(cardindex).companyNameInputValue == null || 
            this.finalCardsMap.get(cardindex).companyNameInputValue == '') {
            throw new LongFormException('Please fill in all required fields');
        }
        this.finalCardsMap.get(cardindex).displayCompanyNameField = false;
        this.finalCardsMap.get(cardindex).techParamsIsConfigurated = true;
        this.finalCardsMap.get(cardindex).cardIsConfigurated = true;
        this.finalCardsMap.get(cardindex).activeCardConfigStepMobile = null;
        Boolean showSingleTechParamsBlock = false;
        Set<LongFormCard> notConfiguratedCardsSet = new Set<LongFormCard>();
        for (Integer key : this.finalCardsMap.keySet()) {
            if (this.finalCardsMap.get(key).cardIsConfigurated == false) {
                notConfiguratedCardsSet.add(this.finalCardsMap.get(key));
            }
            if (key != cardindex) {
                if (this.finalCardsMap.get(key).cardIsConfigurated == false && showSingleTechParamsBlock == false) {
                    showSingleTechParamsBlock = true;
                    this.continueButtonStatus = 'show-saveSingleCardButton';
                    if (! this.finalCardsMap.get(key).cardIsConfigurated ) {
                        this.finalCardsMap.get(key).categoryCard = this.finalCardsMap.get(cardindex).categoryCard;
                        this.finalCardsMap.get(key).pumpOutsideCountry = this.finalCardsMap.get(cardindex).pumpOutsideCountry;
                        this.finalCardsMap.get(key).pumpAtPartners = this.finalCardsMap.get(cardindex).pumpAtPartners;
                        this.finalCardsMap.get(key).needOdometerOptions = this.finalCardsMap.get(cardindex).needOdometerOptions;
                        this.finalCardsMap.get(key).selectedDriverNameOrCarNumber = this.finalCardsMap.get(cardindex).selectedDriverNameOrCarNumber;
                        this.finalCardsMap.get(key).selectedTypeOfCar = this.finalCardsMap.get(cardindex).selectedTypeOfCar;
                        this.finalCardsMap.get(key).techParamsIsConfigurated = false;
                        this.finalCardsMap.get(key).activeCardConfigStepMobile = 'Category';
                   }
                } else {
                    this.continueButtonStatus = 'show-saveContinueButton';
                }
                this.finalCardsMap.get(key).companyNameInputValue = this.finalCardsMap.get(cardindex).companyNameInputValue;
                this.finalCardsMap.get(key).displayCompanyNameField = false;
            }
        }
        if (notConfiguratedCardsSet.isEmpty()) {
           this.continueButtonStatus = 'show-feesAgreementButton';
        } else if (notConfiguratedCardsSet.size() == 1){
           this.continueButtonStatus = 'show-saveContinueButton';
        } else if (notConfiguratedCardsSet.size() > 1){
           this.continueButtonStatus = 'show-saveSingleCardButton';
        }
    }


    /*******************************************************************************
    *  Name            : saveTechParamForAllCards(String activeSubStep)
    *  Summary         : save technical parameters for all cards
    *  CreatedDate     : 01/04/2018
    *  ModifiedDate    : -
    *  Parameters      : String activeSubStep
    *  Returns         : void
    ******************************************************************************/
    public void saveTechParamForAllCards(String activeSubStep) {
        for (Integer key : this.finalCardsMap.keySet()) {
            LongFormCard lfCard = this.finalCardsMap.get(key);
            this.allSavedCardsMap.get(lfCard.sfCardId).Driver_Name__c = 'Shell Card ' + key;
            this.allSavedCardsMap.get(lfCard.sfCardId).Kilometerstand_Abfrage__c = lfCard.needOdometerOptions;
            this.allSavedCardsMap.get(lfCard.sfCardId).Firmenname_auf_der_Karte__c = lfCard.companyNameInputValue;
            this.allSavedCardsMap.get(lfCard.sfCardId).Fahrzeugtyp__c = lfCard.selectedTypeOfCar;
        }
        Database.SaveResult[] srList = Database.update(this.allSavedCardsMap.values(), false);
        for (Database.SaveResult sr : srList) {
            if (! sr.isSuccess() ) {
                String error = '';
                for(Database.Error err : sr.getErrors()) {
                    error += err.getMessage();
                }
                throw new LongFormException(error);
                break;
            }
        }
        Integer countOfPKW = 0;
        Integer countOfLKW = 0;
        for (Tankkarten__c card : this.allSavedCardsMap.values()) {
           if (card.Fahrzeugtyp__c == 'PKW') {
               countOfPKW++;
           }
           if (card.Fahrzeugtyp__c == 'LKW') {
               countOfLKW++;
           }
        }

        String ipAddress = LongFormGlobalUtils.getUserIPAddress();
        this.opportunity.StageName = 'Credit Approved';
        this.opportunity.Visitor_ID__c = ipAddress;
        if (activeSubStep == 'Additional services') {
            this.opportunity.E2E_Active_Step__c = 3;
            this.opportunity.E2E_Active_SubStep__c = 'Additional services';
        } else if (activeSubStep == 'VAT Number') {
            this.opportunity.E2E_Active_Step__c = 2;
            this.opportunity.E2E_Active_SubStep__c = 'Technical parameters';
        }
        this.opportunity.Derzeitige_Zahlungsmethode__c = 'Barzahlung';
        this.opportunity.Number_of_cars__c = countOfPKW;
        this.opportunity.Number_of_trucks__c = countOfLKW;
        this.opportunity.E2E_Last_Activity__c = Datetime.now();
        Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EFormBENL').AES256_Key__c);
        String stringToEncode = opportunity.Id + '-' + opportunity.E2E_Active_Step__c;
        String encodedStringUrl = E2EFormEncryption.getHashAlgorithAES256(key256AES, stringToEncode);
        this.opportunity.E2E_Encoded_URL__c = encodedStringUrl;
        this.opportunity.E2E_Status__c = 'In progress';
        this.opportunity.E2E_Sub_Status__c = '';
        List<User> e2eUser = [SELECT Id FROM User WHERE Name = 'E2E Site Guest User' LIMIT 1];
        if ( ! e2eUser.isEmpty() ) {
            this.opportunity.OwnerId = e2eUser.get(0).Id;
        }
        Database.SaveResult opptyUpdateResult = Database.update(this.opportunity);
        if (! opptyUpdateResult.isSuccess() ) {
            String error = '';
            for (Database.Error err : opptyUpdateResult.getErrors()) {
                error += err.getMessage();
            }
            throw new LongFormException(error);
        }
        EmarsysSenderEuropeanService.sendE2EOpportunityToEmarsys(this.opportunity.Id);

        String employee;
        if (this.numberOfCards >= 1 && this.numberOfCards <= 4) {
            employee = '1-4';
        } else if (this.numberOfCards >= 5 && this.numberOfCards <= 9) {
            employee = '5-9';
        } else if (this.numberOfCards >= 10 && this.numberOfCards <= 19) {
            employee = '10-19';
        } else if (this.numberOfCards >= 20 && this.numberOfCards <= 49) {
            employee = '20-49';
        } else if (this.numberOfCards >= 50 && this.numberOfCards <= 74) {
            employee = '50-74';
        } else if (this.numberOfCards >= 75 && this.numberOfCards <= 99) {
            employee = '75-99';
        } else if (this.numberOfCards >= 100 && this.numberOfCards <= 149) {
            employee = '100-149';
        } else if (this.numberOfCards >= 150 && this.numberOfCards <= 199) {
            employee = '150-199';
        } else if (this.numberOfCards >= 200) {
            employee = '>200';
        }
        this.account.Beschaeftigte__c = employee;
        Database.SaveResult accUpdateResult = Database.update(this.account);
        if (! accUpdateResult.isSuccess() ) {
            String error = '';
            for (Database.Error err : accUpdateResult.getErrors()) {
                error += err.getMessage();
            }
            throw new LongFormException(error);
        }
    }


    /*******************************************************************************
    *  Name            : setContinueButtonStatus(Integer activeStep, String activeSubstep)
    *  Summary         : set continue button status
    *  CreatedDate     : 30/03/2018
    *  ModifiedDate    : -
    *  Parameters      : Integer activeStep, String activeSubstep
    *  Returns         : void
    ******************************************************************************/
    public void setContinueButtonStatus(Integer activeStep, String activeSubstep) {
        if (activeStep == 2 && activeSubstep == 'Card configuration') {
            if (this.activeCardConfigTab == 'same') {
                this.continueButtonIsDisabled = false;
            } else if (this.activeCardConfigTab == 'diff') {
                for (LongFormCard diffcard : this.diffCardsMap.values()) {
                    if (diffcard.cardIsConfigurated == false) {
                        this.continueButtonIsDisabled = true;
                        break;
                    }
                    this.continueButtonIsDisabled = false;
                }
            }
        } else if (activeStep == 2 && activeSubstep == 'Technical parameters') {
            for (LongFormCard lfcard : this.finalCardsMap.values()) {
                if (lfcard.techParamsIsConfigurated == false || lfcard.displayTechnicalParamsBlock) {
                    this.continueButtonIsDisabled = true;
                    break;
                }
                this.continueButtonIsDisabled = false;
            }
        }
    }


    /*******************************************************************************
    *  Name            : setContinueButtonStatusMobile(Integer activeStep, String activeSubstep)
    *  Summary         : set continue button status
    *  CreatedDate     : 21/06/2018
    *  ModifiedDate    : -
    *  Parameters      : Integer activeStep, String activeSubstep
    *  Returns         : void
    ******************************************************************************/
    public void setContinueButtonStatusMobile(Integer activeStep, String activeSubstep) {
        if (activeStep == 2 && (activeSubstep == 'Card configuration' || activeSubstep == 'Technical parameters')) {
            Set<LongFormCard> notConfiguratedCardsSet = new Set<LongFormCard>();
            LongFormCard activeCard;
            for (LongFormCard card : this.finalCardsMap.values()) {
                if (! card.cardIsConfigurated || ! card.techParamsIsConfigurated) {
                   notConfiguratedCardsSet.add(card);
                   if (! card.techParamsIsConfigurated) activeCard = card;
                }
            }
            if (activeCard != null) {
                if (activeCard.activeCardConfigStepMobile == 'Category' || activeCard.activeCardConfigStepMobile == 'Options') {
                    if (this.account.Name.length() <= 25) {  
                        if (notConfiguratedCardsSet.size() > 1) {
                            this.continueButtonStatus = 'show-saveSingleCardButton';
                        } else if (notConfiguratedCardsSet.size() == 1) {
                            this.continueButtonStatus = 'show-saveContinueButton';
                        }
                    } else {
                        this.continueButtonStatus = 'show-goToEmbossingButton';
                    }
                } else if (activeCard.activeCardConfigStepMobile == 'Embossing') {
                    if (notConfiguratedCardsSet.size() > 1) {
                        this.continueButtonStatus = 'show-saveSingleCardButton';
                    } else if (notConfiguratedCardsSet.size() == 1) {
                        this.continueButtonStatus = 'show-saveContinueButton';
                    } else {
                        this.continueButtonStatus = 'show-feesAgreementButton';
                    }
                } 
            } else {
                this.continueButtonStatus = 'show-feesAgreementButton';
            }
        }        
    }


    /*******************************************************************************
    *  Name            : getContinueButtonStatus()
    *  Summary         : return status button (disabled / not disabled)
    *  CreatedDate     : 20/03/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Boolean true/false
    ******************************************************************************/
    public Boolean getContinueButtonStatus() {
        return this.continueButtonIsDisabled;
    }


    /*******************************************************************************
    *  Name            : getContinueButtonStatusMobile()
    *  Summary         : return status button (disabled / not disabled)
    *  CreatedDate     : 22/06/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : String
    ******************************************************************************/
    public String getContinueButtonStatusMobile() {
        return this.continueButtonStatus;
    }


    /*******************************************************************************
    *  Name            : saveCardsConfigResult()
    *  Summary         : save cards configuration to SF database (upsert/delete)
    *  CreatedDate     : 21/03/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void saveCardsConfigResult() {
        List<Tankkarten__c> cardsToUpsertList = new List<Tankkarten__c>();
        List<Tankkarten__c> cardsToDeleteList = new List<Tankkarten__c>();
        Set<String> configuratedCardIdSet = new Set<String>();
        if (this.activeCardConfigTab == 'same') {
            for (LongFormCard samecard : this.sameCardsMap.values()) {
                if (samecard.sfCardId != null && this.allSavedCardsMap.containsKey(samecard.sfCardId)) {
                    configuratedCardIdSet.add(samecard.sfCardId);
                    // set category
                    if (samecard.categoryCard == 'Diesel') {
                        this.allSavedCardsMap.get(samecard.sfCardId).Produktbezugskategorie__c = '0 Diesel, Tunnel-, Maut- und Fährgebühren';
                    } else if (samecard.categoryCard == 'All fuel types') {
                        this.allSavedCardsMap.get(samecard.sfCardId).Produktbezugskategorie__c = '1 Alle Kraftstoffe, Tunnel-, Maut- und Fährgebühren';
                    } else if (samecard.categoryCard == 'All vehicle related product') {
                        this.allSavedCardsMap.get(samecard.sfCardId).Produktbezugskategorie__c = '2 Kategorie 1 plus fahrzeugbezogene Waren und Dienstleistungen (Öle, Autowäsche)';
                    }
                    // set card type
                    if (samecard.pumpOutsideCountry == true && samecard.pumpAtPartners == false) {
                        this.allSavedCardsMap.get(samecard.sfCardId).Gewuenschter_Kartentyp__c = 'Single Network Card -- International';
                    } else if (samecard.pumpOutsideCountry == true && samecard.pumpAtPartners == true) {
                        this.allSavedCardsMap.get(samecard.sfCardId).Gewuenschter_Kartentyp__c = 'Multi Network Card -- International';
                    } else if (samecard.pumpOutsideCountry == false && samecard.pumpAtPartners == false) {
                        this.allSavedCardsMap.get(samecard.sfCardId).Gewuenschter_Kartentyp__c = 'Single Network Card -- National';
                    } else if (samecard.pumpOutsideCountry == false && samecard.pumpAtPartners == true) {
                        this.allSavedCardsMap.get(samecard.sfCardId).Gewuenschter_Kartentyp__c = 'Multi Network Card -- National';
                    }
                    if(this.account.Name.length() <= 25) {
                        this.allSavedCardsMap.get(samecard.sfCardId).Firmenname_auf_der_Karte__c = this.account.Name;
                        samecard.companyNameInputValue = this.account.Name;
                    }

                    cardsToUpsertList.add(this.allSavedCardsMap.get(samecard.sfCardId));
                } else {
                    Tankkarten__c newCard = new Tankkarten__c();
                    // set category
                    if (samecard.categoryCard == 'Diesel') {
                        newCard.Produktbezugskategorie__c = '0 Diesel, Tunnel-, Maut- und Fährgebühren';
                    } else if (samecard.categoryCard == 'All fuel types') {
                        newCard.Produktbezugskategorie__c = '1 Alle Kraftstoffe, Tunnel-, Maut- und Fährgebühren';
                    } else if (samecard.categoryCard == 'All vehicle related product') {
                        newCard.Produktbezugskategorie__c = '2 Kategorie 1 plus fahrzeugbezogene Waren und Dienstleistungen (Öle, Autowäsche)';
                    }
                    // set card type
                    if (samecard.pumpOutsideCountry == true && samecard.pumpAtPartners == false) {
                        newCard.Gewuenschter_Kartentyp__c = 'Single Network Card -- International';
                    } else if (samecard.pumpOutsideCountry == true && samecard.pumpAtPartners == true) {
                        newCard.Gewuenschter_Kartentyp__c = 'Multi Network Card -- International';
                    } else if (samecard.pumpOutsideCountry == false && samecard.pumpAtPartners == false) {
                        newCard.Gewuenschter_Kartentyp__c = 'Single Network Card -- National';
                    } else if (samecard.pumpOutsideCountry == false && samecard.pumpAtPartners == true) {
                        newCard.Gewuenschter_Kartentyp__c = 'Multi Network Card -- National';
                    }
                    // set opportunity to
                    newCard.Opportunity__c = opportunity.Id;

                    if(this.account.Name.length() <= 25) newCard.Firmenname_auf_der_Karte__c = this.account.Name;

                    cardsToUpsertList.add(newCard);
                }
            }
        } else if (this.activeCardConfigTab == 'diff') {
            for (LongFormCard diffcard : this.diffCardsMap.values()) {
                if (diffcard.sfCardId != null && this.allSavedCardsMap.containsKey(diffcard.sfCardId)) {
                    configuratedCardIdSet.add(diffcard.sfCardId);
                    // set category
                    if (diffcard.categoryCard == 'Diesel') {
                        this.allSavedCardsMap.get(diffcard.sfCardId).Produktbezugskategorie__c = '0 Diesel, Tunnel-, Maut- und Fährgebühren';
                    } else if (diffcard.categoryCard == 'All fuel types') {
                        this.allSavedCardsMap.get(diffcard.sfCardId).Produktbezugskategorie__c = '1 Alle Kraftstoffe, Tunnel-, Maut- und Fährgebühren';
                    } else if (diffcard.categoryCard == 'All vehicle related product') {
                        this.allSavedCardsMap.get(diffcard.sfCardId).Produktbezugskategorie__c = '2 Kategorie 1 plus fahrzeugbezogene Waren und Dienstleistungen (Öle, Autowäsche)';
                    }
                    // set card type
                    if (diffcard.pumpOutsideCountry == true && diffcard.pumpAtPartners == false) {
                        this.allSavedCardsMap.get(diffcard.sfCardId).Gewuenschter_Kartentyp__c = 'Single Network Card -- International';
                    } else if (diffcard.pumpOutsideCountry == true && diffcard.pumpAtPartners == true) {
                        this.allSavedCardsMap.get(diffcard.sfCardId).Gewuenschter_Kartentyp__c = 'Multi Network Card -- International';
                    } else if (diffcard.pumpOutsideCountry == false && diffcard.pumpAtPartners == false) {
                        this.allSavedCardsMap.get(diffcard.sfCardId).Gewuenschter_Kartentyp__c = 'Single Network Card -- National';
                    } else if (diffcard.pumpOutsideCountry == false && diffcard.pumpAtPartners == true) {
                        this.allSavedCardsMap.get(diffcard.sfCardId).Gewuenschter_Kartentyp__c = 'Multi Network Card -- National';
                    }
                    if(this.account.Name.length() <= 25) {
                        this.allSavedCardsMap.get(diffcard.sfCardId).Firmenname_auf_der_Karte__c = this.account.Name;
                        diffcard.companyNameInputValue = this.account.Name;
                    }

                    cardsToUpsertList.add(this.allSavedCardsMap.get(diffcard.sfCardId));
                } else {
                    Tankkarten__c newCard = new Tankkarten__c();
                    // set category
                    if (diffcard.categoryCard == 'Diesel') {
                        newCard.Produktbezugskategorie__c = '0 Diesel, Tunnel-, Maut- und Fährgebühren';
                    } else if (diffcard.categoryCard == 'All fuel types') {
                        newCard.Produktbezugskategorie__c = '1 Alle Kraftstoffe, Tunnel-, Maut- und Fährgebühren';
                    } else if (diffcard.categoryCard == 'All vehicle related product') {
                        newCard.Produktbezugskategorie__c = '2 Kategorie 1 plus fahrzeugbezogene Waren und Dienstleistungen (Öle, Autowäsche)';
                    }
                    // set card type
                    if (diffcard.pumpOutsideCountry == true && diffcard.pumpAtPartners == false) {
                        newCard.Gewuenschter_Kartentyp__c = 'Single Network Card -- International';
                    } else if (diffcard.pumpOutsideCountry == true && diffcard.pumpAtPartners == true) {
                        newCard.Gewuenschter_Kartentyp__c = 'Multi Network Card -- International';
                    } else if (diffcard.pumpOutsideCountry == false && diffcard.pumpAtPartners == false) {
                        newCard.Gewuenschter_Kartentyp__c = 'Single Network Card -- National';
                    } else if (diffcard.pumpOutsideCountry == false && diffcard.pumpAtPartners == true) {
                        newCard.Gewuenschter_Kartentyp__c = 'Multi Network Card -- National';
                    }
                    // set opportunity to
                    newCard.Opportunity__c = opportunity.Id;

                    if(this.account.Name.length() <= 25) newCard.Firmenname_auf_der_Karte__c = this.account.Name;

                    cardsToUpsertList.add(newCard);
                }
            }
        }
        for (Tankkarten__c card : this.allSavedCardsMap.values()) {
            if (! configuratedCardIdSet.contains(card.Id)) {
                cardsToDeleteList.add(card);
            }
        }
        if (! cardsToUpsertList.isEmpty()) {
            upsert cardsToUpsertList;
        }
        if (! cardsToDeleteList.isEmpty()) {
            delete cardsToDeleteList;
        }
        setCardParams();

        String ipAddress = LongFormGlobalUtils.getUserIPAddress();
        opportunity.StageName = 'Credit Approved';
        opportunity.E2E_Active_Step__c = 2;
        opportunity.E2E_Active_Substep__c = 'Choosing offer';
        opportunity.E2E_Last_Activity__c = Datetime.now();
        opportunity.Anzahl_der_Karten__c = this.numberOfCards;
        opportunity.Total_number_of_vehicles__c = this.numberOfCards;
        opportunity.Visitor_ID__c = ipAddress;
        Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EFormBENL').AES256_Key__c);
        String stringToEncode = opportunity.Id + '-' + opportunity.E2E_Active_Step__c;
        String encodedStringUrl = E2EFormEncryption.getHashAlgorithAES256(key256AES, stringToEncode);
        opportunity.E2E_Encoded_URL__c = encodedStringUrl;
        this.opportunity.E2E_Status__c = 'In progress';
        this.opportunity.E2E_Sub_Status__c = '';
        List<User> e2eUser = [SELECT Id FROM User WHERE Name = 'E2E Site Guest User' LIMIT 1];
        if ( ! e2eUser.isEmpty() ) {
            this.opportunity.OwnerId = e2eUser.get(0).Id;
        }
        Database.SaveResult opptyUpdateResult = Database.update(opportunity, false);
        if (! opptyUpdateResult.isSuccess() ) {
            String error = '';
            for(Database.Error err : opptyUpdateResult.getErrors()) {
                error += err.getMessage();
            }
            throw new LongFormException(error);
        }
    }


    /*******************************************************************************
    *  Name            : saveCardsConfigResultMobile(String activeSubstep)
    *  Summary         : save cards configuration to SF database (upsert/delete)
    *  CreatedDate     : 25/06/2018
    *  ModifiedDate    : -
    *  Parameters      : String activeSubstep
    *  Returns         : void
    ******************************************************************************/
    public void saveCardsConfigResultMobile(String activeSubstep) {
        List<Tankkarten__c> cardsToUpsertList = new List<Tankkarten__c>();
        List<Tankkarten__c> cardsToDeleteList = new List<Tankkarten__c>();
        Set<String> configuratedCardIdSet = new Set<String>();
        Integer countOfPKW = 0;
        Integer countOfLKW = 0;
        for (LongFormCard lfcard : this.finalCardsMap.values()) {
            if (lfcard.sfCardId != null && this.allSavedCardsMap.containsKey(lfcard.sfCardId)) {
               configuratedCardIdSet.add(lfcard.sfCardId);
               // set category
               if (lfcard.categoryCard == 'Diesel') {
                   this.allSavedCardsMap.get(lfcard.sfCardId).Produktbezugskategorie__c = '0 Diesel, Tunnel-, Maut- und Fährgebühren';
               } else if (lfcard.categoryCard == 'All fuel types') {
                   this.allSavedCardsMap.get(lfcard.sfCardId).Produktbezugskategorie__c = '1 Alle Kraftstoffe, Tunnel-, Maut- und Fährgebühren';
               } else if (lfcard.categoryCard == 'All vehicle related product') {
                   this.allSavedCardsMap.get(lfcard.sfCardId).Produktbezugskategorie__c = '2 Kategorie 1 plus fahrzeugbezogene Waren und Dienstleistungen (Öle, Autowäsche)';
               }
               // set card type
               if (lfcard.pumpOutsideCountry == true && lfcard.pumpAtPartners == false) {
                   this.allSavedCardsMap.get(lfcard.sfCardId).Gewuenschter_Kartentyp__c = 'Single Network Card -- International';
               } else if (lfcard.pumpOutsideCountry == true && lfcard.pumpAtPartners == true) {
                   this.allSavedCardsMap.get(lfcard.sfCardId).Gewuenschter_Kartentyp__c = 'Multi Network Card -- International';
               } else if (lfcard.pumpOutsideCountry == false && lfcard.pumpAtPartners == false) {
                   this.allSavedCardsMap.get(lfcard.sfCardId).Gewuenschter_Kartentyp__c = 'Single Network Card -- National';
               } else if (lfcard.pumpOutsideCountry == false && lfcard.pumpAtPartners == true) {
                   this.allSavedCardsMap.get(lfcard.sfCardId).Gewuenschter_Kartentyp__c = 'Multi Network Card -- National';
               }
               if (lfCard.selectedDriverNameOrCarNumber == 'driver-name') {
                   this.allSavedCardsMap.get(lfCard.sfCardId).Driver_Name__c = lfCard.driverNameOrCarNumberInputValue;
               } else if (lfCard.selectedDriverNameOrCarNumber == 'car-number') {
                   this.allSavedCardsMap.get(lfCard.sfCardId).KFZ_Kennzeichen_oder_Fahrername__c = lfCard.driverNameOrCarNumberInputValue;
               }
               this.allSavedCardsMap.get(lfCard.sfCardId).Kilometerstand_Abfrage__c = lfCard.needOdometerOptions;
               this.allSavedCardsMap.get(lfCard.sfCardId).Firmenname_auf_der_Karte__c = lfCard.companyNameInputValue;
               this.allSavedCardsMap.get(lfCard.sfCardId).Fahrzeugtyp__c = lfCard.selectedTypeOfCar;
               cardsToUpsertList.add(this.allSavedCardsMap.get(lfcard.sfCardId));
            } else {
               Tankkarten__c newCard = new Tankkarten__c();
               // set category
               if (lfcard.categoryCard == 'Diesel') {
                   newCard.Produktbezugskategorie__c = '0 Diesel, Tunnel-, Maut- und Fährgebühren';
               } else if (lfcard.categoryCard == 'All fuel types') {
                   newCard.Produktbezugskategorie__c = '1 Alle Kraftstoffe, Tunnel-, Maut- und Fährgebühren';
               } else if (lfcard.categoryCard == 'All vehicle related product') {
                   newCard.Produktbezugskategorie__c = '2 Kategorie 1 plus fahrzeugbezogene Waren und Dienstleistungen (Öle, Autowäsche)';
               }
               // set card type
               if (lfcard.pumpOutsideCountry == true && lfcard.pumpAtPartners == false) {
                   newCard.Gewuenschter_Kartentyp__c = 'Single Network Card -- International';
               } else if (lfcard.pumpOutsideCountry == true && lfcard.pumpAtPartners == true) {
                   newCard.Gewuenschter_Kartentyp__c = 'Multi Network Card -- International';
               } else if (lfcard.pumpOutsideCountry == false && lfcard.pumpAtPartners == false) {
                   newCard.Gewuenschter_Kartentyp__c = 'Single Network Card -- National';
               } else if (lfcard.pumpOutsideCountry == false && lfcard.pumpAtPartners == true) {
                   newCard.Gewuenschter_Kartentyp__c = 'Multi Network Card -- National';
               }
               if (lfCard.selectedDriverNameOrCarNumber == 'driver-name') {
                   newCard.Driver_Name__c = lfCard.driverNameOrCarNumberInputValue;
               } else if (lfCard.selectedDriverNameOrCarNumber == 'car-number') {
                   newCard.KFZ_Kennzeichen_oder_Fahrername__c = lfCard.driverNameOrCarNumberInputValue;
               }
               newCard.Kilometerstand_Abfrage__c = lfCard.needOdometerOptions;
               newCard.Firmenname_auf_der_Karte__c = lfCard.companyNameInputValue;
               newCard.Fahrzeugtyp__c = lfCard.selectedTypeOfCar;

               // set opportunity to
               newCard.Opportunity__c = this.opportunity.Id;
               cardsToUpsertList.add(newCard);
            }
            if (lfCard.selectedTypeOfCar == 'PKW') {
                countOfPKW++;
            }
            if (lfCard.selectedTypeOfCar == 'LKW') {
                countOfLKW++;
            }
        }

        for (Tankkarten__c card : this.allSavedCardsMap.values()) {
           if (! configuratedCardIdSet.contains(card.Id)) {
               cardsToDeleteList.add(card);
           }
        }
        if (! cardsToUpsertList.isEmpty()) {
            upsert cardsToUpsertList;
        }
        if (! cardsToDeleteList.isEmpty()) {
            delete cardsToDeleteList;
        }
        setCardParamsMobile();

        String ipAddress = LongFormGlobalUtils.getUserIPAddress();
        this.opportunity.StageName = 'Credit Approved';
        this.opportunity.E2E_Active_Step__c = 2;
        this.opportunity.E2E_Active_Substep__c = 'Choosing offer';
        this.opportunity.E2E_Last_Activity__c = Datetime.now();
        this.opportunity.Anzahl_der_Karten__c = this.numberOfCards;
        this.opportunity.Total_number_of_vehicles__c = this.numberOfCards;
        this.opportunity.Derzeitige_Zahlungsmethode__c = 'Barzahlung';
        this.opportunity.Number_of_cars__c = countOfPKW;
        this.opportunity.Number_of_trucks__c = countOfLKW;
        this.opportunity.Visitor_ID__c = ipAddress;
        Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EFormBENL').AES256_Key__c);
        String stringToEncode = this.opportunity.Id + '-' + this.opportunity.E2E_Active_Step__c;
        String encodedStringUrl = E2EFormEncryption.getHashAlgorithAES256(key256AES, stringToEncode);
        this.opportunity.E2E_Encoded_URL__c = encodedStringUrl;
        this.opportunity.E2E_Status__c = 'In progress';
        this.opportunity.E2E_Sub_Status__c = '';
        List<User> e2eUser = [SELECT Id FROM User WHERE Name = 'E2E Site Guest User' LIMIT 1];
        if ( ! e2eUser.isEmpty() ) {
            this.opportunity.OwnerId = e2eUser.get(0).Id;
        }
        Database.SaveResult opptyUpdateResult = Database.update(this.opportunity, false);
        if (! opptyUpdateResult.isSuccess() ) {
           String error = '';
           for(Database.Error err : opptyUpdateResult.getErrors()) {
               error += err.getMessage();
           }
           throw new LongFormException(error);
        }
        EmarsysSenderEuropeanService.sendE2EOpportunityToEmarsys(this.opportunity.Id);

        String employee;
        if (this.numberOfCards >= 1 && this.numberOfCards <= 4) {
           employee = '1-4';
        } else if (this.numberOfCards >= 5 && this.numberOfCards <= 9) {
           employee = '5-9';
        } else if (this.numberOfCards >= 10 && this.numberOfCards <= 19) {
           employee = '10-19';
        } else if (this.numberOfCards >= 20 && this.numberOfCards <= 49) {
           employee = '20-49';
        } else if (this.numberOfCards >= 50 && this.numberOfCards <= 74) {
           employee = '50-74';
        } else if (this.numberOfCards >= 75 && this.numberOfCards <= 99) {
           employee = '75-99';
        } else if (this.numberOfCards >= 100 && this.numberOfCards <= 149) {
           employee = '100-149';
        } else if (this.numberOfCards >= 150 && this.numberOfCards <= 199) {
           employee = '150-199';
        } else if (this.numberOfCards >= 200) {
           employee = '>200';
        }
        this.account.Beschaeftigte__c = employee;
        Database.SaveResult accUpdateResult = Database.update(this.account);
        if (! accUpdateResult.isSuccess() ) {
           String error = '';
           for (Database.Error err : accUpdateResult.getErrors()) {
               error += err.getMessage();
           }
           throw new LongFormException(error);
        }
    }


    /*******************************************************************************
    *  Name            : changeNumberOfCards(Integer totalNumberOfCards)
    *  Summary         : change number of cards
    *  CreatedDate     : 21/03/2018
    *  ModifiedDate    : -
    *  Parameters      : Integer totalNumberOfCards
    *  Returns         : void
    ******************************************************************************/
    public void changeNumberOfCards(Integer totalNumberOfCards) {
        this.numberOfCards = totalNumberOfCards;
        if (this.company.creditStatusCode == '004' && this.numberOfCards > 2) {
            this.numberOfCards = 2;
            throw new LongFormException('No more 2 cards');
        }
        List<LongFormCard> savedCardsList = new List<LongFormCard>();
        List<LongFormCard> noSavedCardsList = new List<LongFormCard>();
        for (LongFormCard card : this.diffCardsMap.values()) {
            if (card.cardIsConfigurated == true) {
                savedCardsList.add(card);
            } else {
                noSavedCardsList.add(card);
            }
        }
        if (this.diffCardsMap.size() > this.numberOfCards && this.activeCardConfigTab != 'same') {
            this.numberOfCards = this.diffCardsMap.size();
            throw new LongFormException('Remove extra cards');
        }
        if (savedCardsList.size() < this.numberOfCards && noSavedCardsList.isEmpty()) {
            LongFormCard newCard = new LongFormCard();
            newCard.categoryCard = this.diffCardsMap.get(this.diffCardsMap.size()).categoryCard;
            newCard.pumpOutsideCountry = this.diffCardsMap.get(this.diffCardsMap.size()).pumpOutsideCountry;
            newCard.pumpAtPartners = this.diffCardsMap.get(this.diffCardsMap.size()).pumpAtPartners;
            newCard.cardIsConfigurated = false;
            this.diffCardsMap.put(this.diffCardsMap.size() + 1, newCard);
        }

        Integer currentNumberOfCard = this.sameCardsMap.size();
        Map<Integer, LOngFormCard> diffCardsMapTemp = new Map<Integer, LongFormCard>();
        Integer index = 1;
        for (LongFormCard card : this.diffCardsMap.values()) {
            diffCardsMapTemp.put(index, card);
            index++;
        }
        this.diffCardsMap = diffCardsMapTemp;
        if (currentNumberOfCard < this.numberOfCards) {
            for (Integer i = currentNumberOfCard + 1; i <= this.numberOfCards; i++) {
                LongFormCard newCard = new LongFormCard();
                newCard.categoryCard = this.sameCardsMap.get(1).categoryCard;
                newCard.pumpOutsideCountry = this.sameCardsMap.get(1).pumpOutsideCountry;
                newCard.pumpAtPartners = this.sameCardsMap.get(1).pumpAtPartners;
                this.sameCardsMap.put(i, newCard);
            }
        } else if (currentNumberOfCard > this.numberOfCards) {
            for (Integer i = this.numberOfCards + 1; i <= currentNumberOfCard; i++) {
                this.sameCardsMap.remove(i);
            }
        }
    }


    /*******************************************************************************
    *  Name            : changeNumberOfCardsMobile(Integer totalNumberOfCards)
    *  Summary         : change number of cards for mobile version
    *  CreatedDate     : 21/06/2018
    *  ModifiedDate    : -
    *  Parameters      : Integer totalNumberOfCards
    *  Returns         : void
    ******************************************************************************/
    public void changeNumberOfCardsMobile(Integer totalNumberOfCards) {
        this.numberOfCards = totalNumberOfCards;
        if (this.numberOfCards == 0) this.numberOfCards = 1;
        if (this.numberOfCards > 50) this.numberOfCards = 50;
        if (this.company.creditStatusCode == '004' && this.numberOfCards > 2) {
           this.numberOfCards = 2;
           throw new LongFormException('No more 2 cards');
        }
        List<LongFormCard> savedCardsList = new List<LongFormCard>();
        List<LongFormCard> noSavedCardsList = new List<LongFormCard>();
        for (LongFormCard card : this.finalCardsMap.values()) {
           if (card.cardIsConfigurated == true && card.techParamsIsConfigurated == true) {
               savedCardsList.add(card);
           } else {
               noSavedCardsList.add(card);
           }
        }
        Integer currentNumberOfCard = this.finalCardsMap.size();
        if (currentNumberOfCard < this.numberOfCards) {
           Boolean firstCard = true;
           for (Integer i = currentNumberOfCard + 1; i <= this.numberOfCards; i++) {
               LongFormCard newCard = new LongFormCard();
               newCard.categoryCard = this.finalCardsMap.get(this.finalCardsMap.size()).categoryCard;
               newCard.pumpOutsideCountry = this.finalCardsMap.get(this.finalCardsMap.size()).pumpOutsideCountry;
               newCard.pumpAtPartners = this.finalCardsMap.get(this.finalCardsMap.size()).pumpAtPartners;
               newCard.selectedTypeOfCar = this.finalCardsMap.get(this.finalCardsMap.size()).selectedTypeOfCar;
               newCard.selectedDriverNameOrCarNumber = this.finalCardsMap.get(this.finalCardsMap.size()).selectedDriverNameOrCarNumber;
               newCard.cardIsConfigurated = false;
               newCard.companyNameInputValue = this.finalCardsMap.get(this.finalCardsMap.size()).companyNameInputValue;
               if (newCard.companyNameInputValue != null) {
                    newCard.displayCompanyNameField = false;
               } else {
                    newCard.displayCompanyNameField = true;
               }
               if (firstCard && noSavedCardsList.isEmpty()) {
                    newCard.techParamsIsConfigurated = false;
                    newCard.activeCardConfigStepMobile = 'Category';
                    firstCard = false;
               } else {
                    newCard.techParamsIsConfigurated = true;
               }
               this.finalCardsMap.put(this.finalCardsMap.size() + 1, newCard);
           }
        } else if (currentNumberOfCard > this.numberOfCards) {
           for (Integer i = this.numberOfCards + 1; i <= currentNumberOfCard; i++) {
               // if(this.finalCardsMap.get(i).techParamsIsConfigurated == true && this.finalCardsMap.get(i).cardIsConfigurated == true) {
                   this.numberOfCards = this.finalCardsMap.size();
                   throw new LongFormException('Remove extra cards');
               // }
               // this.finalCardsMap.remove(i);
           }
        }
    }


    /*******************************************************************************
    *  Name            : editCardConfiguration(Integer cardIndex)
    *  Summary         : open configuration block for selected card
    *  CreatedDate     : 14/03/2018
    *  ModifiedDate    : -
    *  Parameters      : Integer cardIndex
    *  Returns         : void
    ******************************************************************************/
    public void editCardConfiguration(Integer cardIndex) {
        this.diffCardsMap.get(cardIndex).cardIsConfigurated = false;
    }


    /*******************************************************************************
    *  Name            : editCardConfigurationMobile(Integer cardIndex)
    *  Summary         : open configuration block for selected card
    *  CreatedDate     : 25/06/2018
    *  ModifiedDate    : -
    *  Parameters      : Integer cardIndex
    *  Returns         : void
    ******************************************************************************/
    public void editCardConfigurationMobile(Integer cardIndex) {
        for (Integer key : this.finalCardsMap.keySet()) {
           if (key != cardIndex && this.finalCardsMap.get(key).techParamsIsConfigurated == false) {
               this.finalCardsMap.get(key).techParamsIsConfigurated = true;
               this.finalCardsMap.get(key).activeCardConfigStepMobile = null;
           }
        }
        this.finalCardsMap.get(cardIndex).techParamsIsConfigurated = false;
        this.finalCardsMap.get(cardIndex).activeCardConfigStepMobile = 'Category';
    }


    /*******************************************************************************
    *  Name            : addCard(Integer cardIndex)
    *  Summary         : add new card and go to next one
    *  CreatedDate     : 14/03/2018
    *  ModifiedDate    : -
    *  Parameters      : Integer cardIndex
    *  Returns         : void
    ******************************************************************************/
    public void addCard(Integer cardIndex) {
        this.diffCardsMap.get(cardIndex).cardIsConfigurated = true;
        List<LongFormCard> noSavedCardsList = new List<LongFormCard>();
        for (LongFormCard card : this.diffCardsMap.values()) {
            if (card.cardIsConfigurated != true) {
                noSavedCardsList.add(card);
            }
        }
        if (this.diffCardsMap.size() < this.numberOfCards && noSavedCardsList.isEmpty()) {
            LongFormCard newCard = new LongFormCard();
            newCard.categoryCard = this.diffCardsMap.get(cardIndex).categoryCard;
            newCard.pumpOutsideCountry = this.diffCardsMap.get(cardIndex).pumpOutsideCountry;
            newCard.pumpAtPartners = this.diffCardsMap.get(cardIndex).pumpAtPartners;
            newCard.cardIsConfigurated = false;
            this.diffCardsMap.put(this.diffCardsMap.size() + 1, newCard);
        }
    }


    /*******************************************************************************
    *  Name            : removeCard(Integer cardIndex)
    *  Summary         : remove selected card
    *  CreatedDate     : 15/03/2018
    *  ModifiedDate    : -
    *  Parameters      : Integer cardIndex
    *  Returns         : void
    ******************************************************************************/
    public void removeCard(Integer cardIndex) {
        this.diffCardsMap.remove(cardIndex);
        Integer counter = 1;
        List<LongFormCard> noSavedCardsList = new List<LongFormCard>();
        Map<Integer, LongFormCard> diffCardsMapTemp = new Map<Integer, LongFormCard>();
        for (LongFormCard card : this.diffCardsMap.values()) {
            if (card.cardIsConfigurated != true) {
                noSavedCardsList.add(card);
            }
            diffCardsMapTemp.put(counter, card);
            counter++;
        }
        this.diffCardsMap = diffCardsMapTemp;
        if (this.diffCardsMap.size() < this.numberOfCards - 1 && noSavedCardsList.isEmpty()) {
            LongFormCard newCard = new LongFormCard();
            newCard.categoryCard = this.diffCardsMap.get(this.diffCardsMap.size()).categoryCard;
            newCard.pumpOutsideCountry = this.diffCardsMap.get(this.diffCardsMap.size()).pumpOutsideCountry;
            newCard.pumpAtPartners = this.diffCardsMap.get(this.diffCardsMap.size()).pumpAtPartners;
            newCard.cardIsConfigurated = false;
            this.diffCardsMap.put(this.diffCardsMap.size() + 1, newCard);
        }
        this.numberOfCards = this.diffCardsMap.size();
        if (this.numberOfCards == 1) {
            this.sameCardsMap = this.diffCardsMap;
            this.activeCardConfigTab = 'same';
        }
    }


    /*******************************************************************************
    *  Name            : removeCardMobile(Integer cardIndex)
    *  Summary         : remove selected card
    *  CreatedDate     : 15/03/2018
    *  ModifiedDate    : -
    *  Parameters      : Integer cardIndex
    *  Returns         : void
    ******************************************************************************/
    public void removeCardMobile(Integer cardIndex) {
        this.finalCardsMap.remove(cardIndex);
        Integer counter = 1;
        Map<Integer, LongFormCard> finalCardsMapTemp = new Map<Integer, LongFormCard>();
        Boolean firstNonConfigCard = true;
        for (LongFormCard card : this.finalCardsMap.values()) {
           if ( ! card.cardIsConfigurated && firstNonConfigCard) {
               card.activeCardConfigStepMobile = 'Category';
               if (card.displayCompanyNameField == null) card.displayCompanyNameField = true;
               card.techParamsIsConfigurated = false;
               firstNonConfigCard = false;
           }
           finalCardsMapTemp.put(counter, card);
           counter++;
        }
        this.finalCardsMap = finalCardsMapTemp;
        this.numberOfCards = finalCardsMapTemp.size();
    }


    /*******************************************************************************
    *  Name            : setSpecialOffers(String deviceView)
    *  Summary         : set all offers for current cards
    *  CreatedDate     : 22/03/2018
    *  ModifiedDate    : -
    *  Parameters      : String deviceView
    *  Returns         : void
    ******************************************************************************/
    public void setSpecialOffers(String deviceView) {
        List<LongFormCard> finalFormCardsList = new List<LongFormCard>();
        if (this.activeCardConfigTab == 'same') {
            finalFormCardsList.addAll(this.sameCardsMap.values());
        } else if (this.activeCardConfigTab == 'diff') {
            finalFormCardsList.addAll(this.diffCardsMap.values());
        } else if (this.activeCardConfigTab == null) {
            finalFormCardsList.addAll(this.finalCardsMap.values());
        }

        Set<String> priceListTypesSet = new Set<String>();
        for (LongFormCard lfCard : finalFormCardsList) {
            if (lfCard.pumpOutsideCountry == true && lfCard.pumpAtPartners == false) {
                priceListTypesSet.add('International Not Partners');
            } else if (lfCard.pumpOutsideCountry == true && lfCard.pumpAtPartners == true) {
                priceListTypesSet.add('International Partners');
            } else if (lfCard.pumpOutsideCountry == false && lfCard.pumpAtPartners == false) {
                priceListTypesSet.add('National Not Partners');
            } else if (lfCard.pumpOutsideCountry == false && lfCard.pumpAtPartners == true) {
                priceListTypesSet.add('National Partners');
            }
        }

        List<LongForm_Fleetcor_Product__c> productsList = [
            SELECT Long_Form_Offer__c
            FROM LongForm_Fleetcor_Product__c
            WHERE Long_Form_Pricelist__r.Country__c = 'Belgium-NL' AND
                Channel__c = :this.opportunity.Sec_Channel__c AND
                Long_Form_Pricelist__r.Type__c IN : priceListTypesSet AND
                Active__c = true
            LIMIT 1000
        ];

        Set<String> offerIdSet = new Set<String>();
        for (LongForm_Fleetcor_Product__c product : productsList) {
            offerIdSet.add(product.Long_Form_Offer__c);
        }
        this.homeOffersList = new List<LongFormSpecialOffer>();
        this.nonHomeOffersList = new List<LongFormSpecialOffer>();

        E2E_Form_General_Settings__c settings = E2E_Form_General_Settings__c.getInstance('Belgium-NL');
        if (! offerIdSet.isEmpty()) {
            String offersQuery = 'SELECT Id, Product__c, LongForm_Element__r.Name, LongForm_Element_Mobile__r.Name, ' +
                        '(SELECT Applied_For_Filter__c, Basic_Filter__c, Check_Fuel_Consumption__c, Currency__c, Fuel_Exception_Filter__c, ' +
                        'Fuel_Type_Filter__c, Rate__c, Rate_Per__c, Tariff__c, Geography__c, Stations__c, ' +
                        'Time_Filter__c, Type__c, Volume_Amount_Filter__c, Volume_Operator_Filter__c ' +
                        'FROM Long_Form_Offer_Items__r) ' +
                    'FROM LongForm_Offer__c ' +
                    'WHERE Id IN :offerIdSet ';

            if (deviceView == 'Desktop') {
                offersQuery += 'AND LongForm_Element__r.Long_Form_Page__r.Long_Form__r.Test_mode__c = ' + settings.Test_mode__c  + ' LIMIT 1000';
            } else if (deviceView == 'Mobile') {
                offersQuery += 'AND LongForm_Element_Mobile__r.Long_Form_Page__r.Long_Form__r.Test_mode__c = ' + settings.Test_mode__c  + ' LIMIT 1000';
            }
            List<LongForm_Offer__c> availableOffersList = (List<LongForm_Offer__c>) Database.query(offersQuery);

            String selectedOfferId;
            Map<String, LongFormSpecialOffer> homeOffersMapTemp = new Map<String, LongFormSpecialOffer>();
            Map<String, LongFormSpecialOffer> nonHomeOffersMapTemp = new Map<String, LongFormSpecialOffer>();
            this.nonHomeOffersList = new List<LongFormSpecialOffer>();
            for (LongForm_Offer__c offer : availableOffersList) {
                LongFormSpecialOffer lfOffer = new LongFormSpecialOffer();
                lfOffer.offerId = offer.Id;
                if (deviceView == 'Desktop') {
                    lfOffer.offerContentKey = offer.LongForm_Element__r.Name;
                } else if (deviceView == 'Mobile') {
                    lfOffer.offerContentKey = offer.LongForm_Element_Mobile__r.Name;
                }
                if (offer.Long_Form_Offer_Items__r.size() == 1) {
                    for (LongForm_Offer_Item__c offerItem : offer.Long_Form_Offer_Items__r) {
                        if (offerItem.Tariff__c == 'Amount') {
                            Decimal discountValue = (offerItem.Rate__c * 100).setScale(0);
                            lfOffer.offerDiscount = String.valueOf(discountValue) + ' ';
                            if (discountValue > 1 || discountValue < -1) {
                                lfOffer.offerDiscount += this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-CENTS OFF-').Value__c + ' ';
                            } else {
                                lfOffer.offerDiscount += this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-CENT OFF-').Value__c + ' ';
                            }
                            lfOffer.offerDiscountRatePer = this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-PER-').Value__c + ' ';
                            if (offerItem.Rate_Per__c != null && offerItem.Rate_Per__c.contains('Liter')) {
                                Decimal ratePer = Decimal.valueOf(offerItem.Rate_Per__c.substringBefore(' Liter'));
                                if (ratePer > 1) {
                                    lfOffer.offerDiscountRatePer += ratePer;
                                    lfOffer.offerDiscountRatePer += ' ' + this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-LITERS-').Value__c + ' ';
                                } else {
                                    lfOffer.offerDiscountRatePer += ' ' + this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-LITER-').Value__c;
                                }
                            }
                        } else if (offerItem.Tariff__c == 'Percent') {
                            lfOffer.offerDiscount = String.valueOf(offerItem.Rate__c);
                            lfOffer.offerDiscount += this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-PERCENT-').Value__c;
                        }
                        lfOffer.offerIsBased = offerItem.Basic_Filter__c;
                        if (offerItem.Time_Filter__c == 'Unlimited' || offerItem.Time_Filter__c == 'N/A') {
                            lfOffer.offerTime = this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-UNLIMITED-').Value__c;
                        } else if (offerItem.Time_Filter__c.contains('Week')) {
                            Decimal timeValue = Decimal.valueOf(offerItem.Time_Filter__c.substringBefore(' Week'));
                            lfOffer.offerTime = String.valueOf(timeValue) + ' ';
                            if (timeValue > 1) {
                                lfOffer.offerTime += this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-WEEKS-').Value__c;
                            } else {
                                lfOffer.offerTime += this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-WEEK-').Value__c;
                            }
                        } else if (offerItem.Time_Filter__c.contains('Month')) {
                            Decimal timeValue = Decimal.valueOf(offerItem.Time_Filter__c.substringBefore(' Month'));
                            lfOffer.offerTime = String.valueOf(timeValue) + ' ';
                            if (timeValue > 1) {
                                lfOffer.offerTime += this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-MONTHS-').Value__c;
                            } else {
                                lfOffer.offerTime += this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-MONTH-').Value__c;
                            }
                        } else if (offerItem.Time_Filter__c.contains('Year')) {
                            Decimal timeValue = Decimal.valueOf(offerItem.Time_Filter__c.substringBefore(' Year'));
                            lfOffer.offerTime = String.valueOf(timeValue) + ' ';
                            if (timeValue > 1) {
                                lfOffer.offerTime += this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-YEARS-').Value__c;
                            } else {
                                lfOffer.offerTime += this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-YEAR-').Value__c;
                            }
                        }

                        String literKey;
                        if (offerItem.Volume_Amount_Filter__c > 1) {
                            literKey = this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-LITERS-').Value__c;
                        } else if (offerItem.Volume_Amount_Filter__c <= 1) {
                            literKey = this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-LITER-').Value__c;
                        }

                        if (offerItem.Volume_Operator_Filter__c == 'Unlimited') {
                            lfOffer.offerVolume = this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-UNLIMITED-').Value__c;
                        } else if (literKey != null) {
                            if (offerItem.Volume_Operator_Filter__c == 'more than [X] liters' || offerItem.Volume_Operator_Filter__c == 'more than [X] liters per 1 month' ||
                                offerItem.Volume_Operator_Filter__c == 'more than [X] liters per 1 card' || offerItem.Volume_Operator_Filter__c == 'more than [X] liters per account company') {
                                lfOffer.offerVolume = this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-MORE THAN-').Value__c + ' ';
                                lfOffer.offerVolume += String.valueOf(offerItem.Volume_Amount_Filter__c) + ' ' + literKey;
                            } else if (offerItem.Volume_Operator_Filter__c == 'not more than [X] liters' || offerItem.Volume_Operator_Filter__c == 'not more than [X] liters per 1 month' ||
                                offerItem.Volume_Operator_Filter__c == 'not more than [X] liters per 1 card' || offerItem.Volume_Operator_Filter__c == 'not more than [X] liters per account company') {
                                lfOffer.offerVolume = this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-NOT MORE THAN-').Value__c + ' ';
                                lfOffer.offerVolume += String.valueOf(offerItem.Volume_Amount_Filter__c) + ' ' + literKey;
                            } else if (offerItem.Volume_Operator_Filter__c == 'only for [X] liters' || offerItem.Volume_Operator_Filter__c == 'only for [X] liters per 1 month' ||
                                offerItem.Volume_Operator_Filter__c == 'only for [X] liters per 1 card' || offerItem.Volume_Operator_Filter__c == 'only for [X] liters per account company') {
                                lfOffer.offerVolume = this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-NOT MORE THAN-').Value__c + ' ';
                                lfOffer.offerVolume += String.valueOf(offerItem.Volume_Amount_Filter__c) + ' ' + literKey;
                            }

                            if (offerItem.Volume_Operator_Filter__c == 'more than [X] liters per 1 month' || offerItem.Volume_Operator_Filter__c == 'not more than [X] liters per 1 month' ||
                                offerItem.Volume_Operator_Filter__c == 'only for [X] liters per 1 month') {
                                lfOffer.offerVolume += ' ' + this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-PER 1 MONTH-').Value__c;
                            } else if (offerItem.Volume_Operator_Filter__c == 'more than [X] liters per 1 card' || offerItem.Volume_Operator_Filter__c == 'not more than [X] liters per 1 card' ||
                                offerItem.Volume_Operator_Filter__c == 'only for [X] liters per 1 card') {
                                lfOffer.offerVolume += ' ' + this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-PER 1 CARD-').Value__c;
                            } else if (offerItem.Volume_Operator_Filter__c == 'more than [X] liters per account company' || offerItem.Volume_Operator_Filter__c == 'not more than [X] liters per account company' ||
                                offerItem.Volume_Operator_Filter__c == 'only for [X] liters per account company') {
                                lfOffer.offerVolume += ' ' + this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-PER ACCOUNT COMPANY-').Value__c;
                            }
                        }

                        if (offerItem.Fuel_Type_Filter__c != null) {
                            List<String> fuelTypesList = offerItem.Fuel_Type_Filter__c.split(';');
                            lfOffer.offerFuelType = '';
                            for (String fuelType : fuelTypesList) {
                                if (fuelType == 'All fuel types') {
                                    lfOffer.offerFuelType += this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-ALL FUEL TYPES-').Value__c + ', ';
                                } else if (fuelType == 'Petrol') {
                                    lfOffer.offerFuelType += this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-PETROL-').Value__c + ', ';
                                } else if (fuelType == 'Diesel (all types)') {
                                    lfOffer.offerFuelType += this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-DIESEL ALL TYPES-').Value__c + ', ';
                                } else if (fuelType == 'Diesel') {
                                    lfOffer.offerFuelType += this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-DIESEL-').Value__c + ', ';
                                } else if (fuelType == 'Diesel (AGO)') {
                                    lfOffer.offerFuelType += this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-DIESEL AGO-').Value__c + ', ';
                                } else if (fuelType == 'Diesel (AGO Low Sulphur)') {
                                    lfOffer.offerFuelType += this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-DIESEL AGO LOW SULPHUR-').Value__c + ', ';
                                } else if (fuelType == 'Diesel (V-Power)') {
                                    lfOffer.offerFuelType += this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-DIESEL V-POWER-').Value__c + ', ';
                                } else if (fuelType == 'Diesel (Bio)') {
                                    lfOffer.offerFuelType += this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-DIESEL BIO-').Value__c + ', ';
                                } else if (fuelType == 'Diesel (Plus)') {
                                    lfOffer.offerFuelType += this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-DIESEL PLUS-').Value__c + ', ';
                                } else if (fuelType == 'Diesel (for trucks)') {
                                    lfOffer.offerFuelType += this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-DIESEL FOR TRUCKS-').Value__c + ', ';
                                } else if (fuelType == 'MOGAS (all types)') {
                                    lfOffer.offerFuelType += this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-MOGAS ALL TYPES-').Value__c + ', ';
                                } else if (fuelType == 'MOGAS (leaded & unleaded)') {
                                    lfOffer.offerFuelType += this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-MOGAS LEADED UNLEADED-').Value__c + ', ';
                                } else if (fuelType == 'MOGAS (leaded)') {
                                    lfOffer.offerFuelType += this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-MOGAS LEADED-').Value__c + ', ';
                                } else if (fuelType == 'MOGAS (unleaded)') {
                                    lfOffer.offerFuelType += this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-MOGAS UNLEADED-').Value__c + ', ';
                                } else if (fuelType == 'Gas Fuel (all types)') {
                                    lfOffer.offerFuelType += this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-GAS FUEL ALL TYPES-').Value__c + ', ';
                                } else if (fuelType == 'Gas Fuel (LPG)') {
                                    lfOffer.offerFuelType += this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-GAS FUEL LPG-').Value__c + ', ';
                                } else if (fuelType == 'Gas Fuel (CNG)') {
                                    lfOffer.offerFuelType += this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-GAS FUEL CNG-').Value__c + ', ';
                                } else if (fuelType == 'Diesel (all types, except V-power)') {
                                    lfOffer.offerFuelType += this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-DIESEL ALL TYPES EXCEPT VPOWER-').Value__c + ', ';
                                }
                            }
                            lfOffer.offerFuelType = lfOffer.offerFuelType.removeEnd(', ');
                            // except
                            if (offerItem.Fuel_Exception_Filter__c != null) {
                                List<String> fuelTypesExceptList = offerItem.Fuel_Exception_Filter__c.split(';');
                                lfOffer.offerFuelType += this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-EXPECT-').Value__c + ' ';
                                for (String fuelType : fuelTypesExceptList) {
                                    if (fuelType == 'All fuel types') {
                                        lfOffer.offerFuelType += this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-ALL FUEL TYPES-').Value__c + ', ';
                                    } else if (fuelType == 'Petrol') {
                                        lfOffer.offerFuelType += this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-PETROL-').Value__c + ', ';
                                    } else if (fuelType == 'Diesel (all types)') {
                                        lfOffer.offerFuelType += this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-DIESEL ALL TYPES-').Value__c + ', ';
                                    } else if (fuelType == 'Diesel') {
                                        lfOffer.offerFuelType += this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-DIESEL-').Value__c + ', ';
                                    } else if (fuelType == 'Diesel (AGO)') {
                                        lfOffer.offerFuelType += this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-DIESEL AGO-').Value__c + ', ';
                                    } else if (fuelType == 'Diesel (AGO Low Sulphur)') {
                                        lfOffer.offerFuelType += this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-DIESEL AGO LOW SULPHUR-').Value__c + ', ';
                                    } else if (fuelType == 'Diesel (V-Power)') {
                                        lfOffer.offerFuelType += this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-DIESEL V-POWER-').Value__c + ', ';
                                    } else if (fuelType == 'Diesel (Bio)') {
                                        lfOffer.offerFuelType += this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-DIESEL BIO-').Value__c + ', ';
                                    } else if (fuelType == 'Diesel (Plus)') {
                                        lfOffer.offerFuelType += this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-DIESEL PLUS-').Value__c + ', ';
                                    } else if (fuelType == 'Diesel (for trucks)') {
                                        lfOffer.offerFuelType += this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-DIESEL FOR TRUCKS-').Value__c + ', ';
                                    } else if (fuelType == 'MOGAS (all types)') {
                                        lfOffer.offerFuelType += this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-MOGAS ALL TYPES-').Value__c + ', ';
                                    } else if (fuelType == 'MOGAS (leaded & unleaded)') {
                                        lfOffer.offerFuelType += this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-MOGAS LEADED UNLEADED-').Value__c + ', ';
                                    } else if (fuelType == 'MOGAS (leaded)') {
                                        lfOffer.offerFuelType += this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-MOGAS LEADED-').Value__c + ', ';
                                    } else if (fuelType == 'MOGAS (unleaded)') {
                                        lfOffer.offerFuelType += this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-MOGAS UNLEADED-').Value__c + ', ';
                                    } else if (fuelType == 'Gas Fuel (all types)') {
                                        lfOffer.offerFuelType += this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-GAS FUEL ALL TYPES-').Value__c + ', ';
                                    } else if (fuelType == 'Gas Fuel (LPG)') {
                                        lfOffer.offerFuelType += this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-GAS FUEL LPG-').Value__c + ', ';
                                    } else if (fuelType == 'Gas Fuel (CNG)') {
                                        lfOffer.offerFuelType += this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-GAS FUEL CNG-').Value__c + ', ';
                                    } else if (fuelType == 'Diesel (all types, except V-power)') {
                                        lfOffer.offerFuelType += this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-DIESEL ALL TYPES EXCEPT VPOWER-').Value__c + ', ';
                                    }
                                }
                                lfOffer.offerFuelType = lfOffer.offerFuelType.removeEnd(', ');
                            }
                        }
                        if (offerItem.Geography__c == 'België') {
                            lfOffer.offerCountry = this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-BELGIUM-').Value__c;
                        } else if (offerItem.Geography__c == 'België & Europe') {
                            lfOffer.offerCountry = this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-BELGIUM AND EUROPE-').Value__c;
                        }

                        if (offerItem.Stations__c == 'Not specified yet') {
                            lfOffer.offerStation = this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-NOT SPECIFIED YET-').Value__c;
                        } else if (offerItem.Stations__c == 'Shell (Home Station)') {
                            lfOffer.offerStation = this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-SHELL HOME STATION-').Value__c;
                        } else if (offerItem.Stations__c == 'Shell (All Stations)') {
                            lfOffer.offerStation = this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-SHELL ALL STATIONS-').Value__c;
                        } else if (offerItem.Stations__c == 'Shell & Partners') {
                            lfOffer.offerStation = this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get(lfOffer.offerContentKey).get('-SHELL AND PARTNERS-').Value__c;
                        }
                    }

                    lfOffer.productName = offer.Product__c;
                    if (this.opportunity.Product__c != null && this.opportunity.ESI__c != null) {
                        if (lfOffer.productName == this.opportunity.Product__c) {
                            selectedOfferId = lfOffer.offerId;
                        }
                        if (offer.Product__c == 'Home Station offer (v.1)') {
                            homeOffersMapTemp.put(lfOffer.offerId, lfOffer);
                        } else {
                            nonHomeOffersMapTemp.put(lfOffer.offerId, lfOffer);
                        }
                    } else {
                        if (offer.Product__c == 'Home Station offer (v.1)') {
                            // RENDERING EXCEPTION FOR BELGIUM (because of different behaviour in Desktop and Mobile versions)
                            if (deviceView == 'Desktop') {
                                lfOffer.homeMapSelectionBtnStatus = 'hide';
                                lfOffer.offerSelectionBtnStatus = 'show-disabled';
                                lfOffer.offerCancelBtnStatus = 'show-disabled';
                                lfOffer.offerRemoveBtnStatus = 'hide';
                            } else 
                            if (deviceView == 'Mobile') {
                                lfOffer.homeMapSelectionBtnStatus = 'show-enabled';
                                lfOffer.offerSelectionBtnStatus = 'hide';
                                lfOffer.offerCancelBtnStatus = 'hide';
                                lfOffer.offerRemoveBtnStatus = 'hide';
                            }
                            this.homeOffersList.add(lfOffer);
                        } else {
                            lfOffer.offerSelectionBtnStatus = 'show-enabled';
                            lfOffer.offerRemoveBtnStatus = 'hide';
                            this.nonHomeOffersList.add(lfOffer);
                        }
                    }
                }
            }

            if (! homeOffersMapTemp.isEmpty() || ! nonHomeOffersMapTemp.isEmpty()) {
                if (homeOffersMapTemp.containsKey(selectedOfferId)) {
                    for (String offerId : homeOffersMapTemp.keySet()) {
                        if (offerId == selectedOfferId) {
                            homeOffersMapTemp.get(offerId).homeMapSelectionBtnStatus = 'hide';
                            homeOffersMapTemp.get(offerId).offerSelectionBtnStatus = 'hide';
                            homeOffersMapTemp.get(offerId).offerCancelBtnStatus = 'hide';
                            // homeOffersMapTemp.get(offerId).offerRemoveBtnStatus = 'show-enabled';
                            this.homeOffersList.add(homeOffersMapTemp.get(offerId));
                        } else {
                            homeOffersMapTemp.get(offerId).homeMapSelectionBtnStatus = 'show-disabled';
                            homeOffersMapTemp.get(offerId).offerSelectionBtnStatus = 'hide';
                            homeOffersMapTemp.get(offerId).offerCancelBtnStatus = 'hide';
                            homeOffersMapTemp.get(offerId).offerRemoveBtnStatus = 'hide';
                            this.homeOffersList.add(homeOffersMapTemp.get(offerId));
                        }
                    }
                    for (String offerId : nonHomeOffersMapTemp.keySet()) {
                        nonHomeOffersMapTemp.get(offerId).offerSelectionBtnStatus = 'show-disabled';
                        nonHomeOffersMapTemp.get(offerId).offerRemoveBtnStatus = 'hide';
                        this.nonHomeOffersList.add(nonHomeOffersMapTemp.get(offerId));
                    }
                } else if (nonHomeOffersMapTemp.containsKey(selectedOfferId)) {
                    for (String offerId : nonHomeOffersMapTemp.keySet()) {
                        if (offerId == selectedOfferId) {
                            nonHomeOffersMapTemp.get(offerId).offerSelectionBtnStatus = 'hide';
                            nonHomeOffersMapTemp.get(offerId).offerRemoveBtnStatus = 'show-enabled';
                            this.nonHomeOffersList.add(nonHomeOffersMapTemp.get(offerId));
                        } else {
                            nonHomeOffersMapTemp.get(offerId).offerSelectionBtnStatus = 'show-disabled';
                            nonHomeOffersMapTemp.get(offerId).offerRemoveBtnStatus = 'hide';
                            this.nonHomeOffersList.add(nonHomeOffersMapTemp.get(offerId));
                        }
                    }
                    for (String offerId : homeOffersMapTemp.keySet()) {
                        homeOffersMapTemp.get(offerId).homeMapSelectionBtnStatus = 'show-disabled';
                        homeOffersMapTemp.get(offerId).offerSelectionBtnStatus = 'hide';
                        homeOffersMapTemp.get(offerId).offerCancelBtnStatus = 'hide';
                        homeOffersMapTemp.get(offerId).offerRemoveBtnStatus = 'hide';
                        this.homeOffersList.add(homeOffersMapTemp.get(offerId));
                    }
                } else {
                    for (String offerId : homeOffersMapTemp.keySet()) {
                        homeOffersMapTemp.get(offerId).homeMapSelectionBtnStatus = 'show-enabled';
                        homeOffersMapTemp.get(offerId).offerSelectionBtnStatus = 'hide';
                        homeOffersMapTemp.get(offerId).offerCancelBtnStatus = 'hide';
                        homeOffersMapTemp.get(offerId).offerRemoveBtnStatus = 'hide';
                        this.homeOffersList.add(homeOffersMapTemp.get(offerId));
                    }
                    for (String offerId : nonHomeOffersMapTemp.keySet()) {
                        nonHomeOffersMapTemp.get(offerId).offerSelectionBtnStatus = 'show-enabled';
                        nonHomeOffersMapTemp.get(offerId).offerRemoveBtnStatus = 'hide';
                        this.nonHomeOffersList.add(nonHomeOffersMapTemp.get(offerId));
                    }
                }
            }

            Integer finalNumberOfOffers = this.homeOffersList.size() + this.nonHomeOffersList.size();
            if (finalNumberOfOffers == 1) {
                if (! this.homeOffersList.isEmpty() ) {
                    if (this.homeOffersList.get(0).offerId == selectedOfferId) {
                        this.homeOffersList.get(0).homeMapSelectionBtnStatus = 'hide';
                        this.homeOffersList.get(0).offerSelectionBtnStatus = 'hide';
                        this.homeOffersList.get(0).offerCancelBtnStatus = 'hide';
                        this.homeOffersList.get(0).offerRemoveBtnStatus = 'show-enabled';
                    } else {
                        if (deviceView == 'Desktop') {
                            this.homeOffersList.get(0).homeMapSelectionBtnStatus = 'hide';
                            this.homeOffersList.get(0).offerSelectionBtnStatus = 'show-disabled';
                            this.homeOffersList.get(0).offerCancelBtnStatus = 'show-disabled';
                            this.homeOffersList.get(0).offerRemoveBtnStatus = 'hide';
                        } else 
                        if (deviceView == 'Mobile') {
                            this.homeOffersList.get(0).homeMapSelectionBtnStatus = 'show-enabled';
                            this.homeOffersList.get(0).offerSelectionBtnStatus = 'hide';
                            this.homeOffersList.get(0).offerCancelBtnStatus = 'hide';
                            this.homeOffersList.get(0).offerRemoveBtnStatus = 'hide';
                        }
                    }
                } else if (! this.nonHomeOffersList.isEmpty() ) {
                    this.nonHomeOffersList.get(0).offerSelectionBtnStatus = 'hide';
                    this.nonHomeOffersList.get(0).offerRemoveBtnStatus = 'hide';
                    this.opportunity.Product__c = this.nonHomeOffersList.get(0).productName;
                }
            }
        }
    }


    /*******************************************************************************
    *  Name            : getHomeOffersList()
    *  Summary         : get all offers for home stations
    *  CreatedDate     : 25/03/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : List<LongFormSpecialOffer>
    ******************************************************************************/
    public List<LongFormSpecialOffer> getHomeOffersList() {
        return this.homeOffersList;
    }


    /*******************************************************************************
    *  Name            : getNonHomeOffersList()
    *  Summary         : get all offers for non home stations
    *  CreatedDate     : 25/03/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : List<LongFormSpecialOffer>
    ******************************************************************************/
    public List<LongFormSpecialOffer> getNonHomeOffersList() {
        return this.nonHomeOffersList;
    }


    /*******************************************************************************
    *  Name            : setUrlLocator()
    *  Summary         : set url for search home stations (locator)
    *  CreatedDate     : 27/03/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void setUrlLocator() {
        String companyAddress = '';
        if (this.opportunity.Home_Station__c != null) {
            companyAddress = this.opportunity.Home_Station__c;
        } else {
            if (this.company.street != null) {
                companyAddress += this.company.street;
            }
            if (this.company.city != null) {
                companyAddress += ', ' + this.company.city;
            }
            if (this.company.country != null) {
                companyAddress += ', ' + this.company.country;
            }
        }
        companyAddress = EncodingUtil.urlEncode(companyAddress, 'ASCII');
        this.urlLocator = this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get('LOCATOR URL').get('BASIC').Value__c + ' ' + companyAddress + ' ' +
                            this.pagesMap.get('CARD CONFIGURATION. SPECIAL OFFERS').elements.get('LOCATOR URL').get('ZOOM PARAM').Value__c;
    }


    /*******************************************************************************
    *  Name            : getUrlLocator()
    *  Summary         : return url for search home stations (locator)
    *  CreatedDate     : 27/03/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : String urlLocator
    ******************************************************************************/
    public String getUrlLocator() {
        return this.urlLocator;
    }


    /*******************************************************************************
    *  Name            : selectOffer(String offerName)
    *  Summary         : set selected offer
    *  CreatedDate     : 26/03/2018
    *  ModifiedDate    : -
    *  Parameters      : String offerName
    *  Returns         : void
    ******************************************************************************/
    public void selectOffer(String offerName) {
        for (LongFormSpecialOffer offer : homeOffersList) {
            if (offer.productName != offerName) {
                offer.homeMapSelectionBtnStatus = 'show-disabled';
            } else {
                this.opportunity.Product__c = offerName;
                if (offerName == 'Home Station offer (v.1)') {
                    this.opportunity.Angebotsdauer__c = '3 months';
                } 
            }
        }
        for (LongFormSpecialOffer offer : nonHomeOffersList) {
            if (offer.productName != offerName) {
                offer.offerSelectionBtnStatus = 'show-disabled';
            } else {
                this.opportunity.Product__c = offerName;
                this.opportunity.Home_Station__c = null;
                this.opportunity.ESI__c = null;
                this.opportunity.Angebotsdauer__c = null;
            }
        }
    }


    /*******************************************************************************
    *  Name            : removeOffer()
    *  Summary         : remove selected offer
    *  CreatedDate     : 26/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void removeOffer() {
        for (LongFormSpecialOffer offer : homeOffersList) {
            offer.homeMapSelectionBtnStatus = 'hide';
            offer.offerSelectionBtnStatus = 'show-disabled';
            offer.offerCancelBtnStatus = 'show-disabled';
            offer.offerRemoveBtnStatus = 'hide';
        }
        for (LongFormSpecialOffer offer : nonHomeOffersList) {
            offer.offerSelectionBtnStatus = 'show-enabled';
            offer.offerRemoveBtnStatus = 'hide';
        }
        this.opportunity.Home_Station__c = null;
        this.opportunity.ESI__c = null;
        this.urlLocator = null;
    }


    /*******************************************************************************
    *  Name            : chooseStation(String offerName)
    *  Summary         : open locator to select station point
    *  CreatedDate     : 26/03/2018
    *  ModifiedDate    : -
    *  Parameters      : String offerName
    *  Returns         : void
    ******************************************************************************/
    public void chooseStation(String offerName) {
        for (LongFormSpecialOffer offer : homeOffersList) {
            if (offer.productName != offerName) {
                offer.homeMapSelectionBtnStatus = 'show-disabled';
                offer.offerSelectionBtnStatus = 'hide';
                offer.offerCancelBtnStatus = 'hide';
            }
        }
        for (LongFormSpecialOffer offer : nonHomeOffersList) {
            if (offer.productName != offerName) {
                offer.offerSelectionBtnStatus = 'show-disabled';
            }
        }
    }


    /*******************************************************************************
    *  Name            : saveSpecialOffer()
    *  Summary         : save offer
    *  CreatedDate     : 27/03/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void saveSpecialOffer() {
        String ipAddress = LongFormGlobalUtils.getUserIPAddress();
        this.opportunity.StageName = 'Credit Approved';
        this.opportunity.Visitor_ID__c = ipAddress;
        this.opportunity.E2E_Active_Step__c = 2;
        this.opportunity.E2E_Active_Substep__c = 'Technical parameters';
        Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EFormBENL').AES256_Key__c);
        String stringToEncode = opportunity.Id + '-' + opportunity.E2E_Active_Step__c;
        String encodedStringUrl = E2EFormEncryption.getHashAlgorithAES256(key256AES, stringToEncode);
        this.opportunity.E2E_Encoded_URL__c = encodedStringUrl;
        this.opportunity.E2E_Last_Activity__c = Datetime.now();
        this.opportunity.E2E_Status__c = 'In progress';
        this.opportunity.E2E_Sub_Status__c = '';
        List<User> e2eUser = [SELECT Id FROM User WHERE Name = 'E2E Site Guest User' LIMIT 1];
        if ( ! e2eUser.isEmpty() ) {
            this.opportunity.OwnerId = e2eUser.get(0).Id;
        }
        Database.SaveResult opptyUpdateResult = Database.update(this.opportunity);
        if (! opptyUpdateResult.isSuccess() ) {
            String error = '';
            for(Database.Error err : opptyUpdateResult.getErrors()) {
                error += err.getMessage();
            }
            throw new LongFormException(error);
        }
        EmarsysSenderEuropeanService.sendE2EOpportunityToEmarsys(this.opportunity.Id);
    }


    /*******************************************************************************
    *  Name            : saveSpecialOfferMobile()
    *  Summary         : save offer
    *  CreatedDate     : 30/06/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void saveSpecialOfferMobile() {
        String ipAddress = LongFormGlobalUtils.getUserIPAddress();
        this.opportunity.StageName = 'Credit Approved';
        this.opportunity.Visitor_ID__c = ipAddress;
        this.opportunity.E2E_Active_Step__c = 3;
        this.opportunity.E2E_Active_SubStep__c = 'Additional services';
        Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EFormBENL').AES256_Key__c);
        String stringToEncode = opportunity.Id + '-' + opportunity.E2E_Active_Step__c;
        String encodedStringUrl = E2EFormEncryption.getHashAlgorithAES256(key256AES, stringToEncode);
        this.opportunity.E2E_Encoded_URL__c = encodedStringUrl;
        this.opportunity.E2E_Last_Activity__c = Datetime.now();
        this.opportunity.E2E_Status__c = 'In progress';
        this.opportunity.E2E_Sub_Status__c = '';
        List<User> e2eUser = [SELECT Id FROM User WHERE Name = 'E2E Site Guest User' LIMIT 1];
        if ( ! e2eUser.isEmpty() ) {
            this.opportunity.OwnerId = e2eUser.get(0).Id;
        }
        Database.SaveResult opptyUpdateResult = Database.update(this.opportunity);
        if (! opptyUpdateResult.isSuccess() ) {
           String error = '';
           for(Database.Error err : opptyUpdateResult.getErrors()) {
               error += err.getMessage();
           }
           throw new LongFormException(error);
        }
        EmarsysSenderEuropeanService.sendE2EOpportunityToEmarsys(this.opportunity.Id);
    }


    /*******************************************************************************
    *  Name            : validateVatId()
    *  Summary         : Validate vat id for format and valid value (API call)
    *  CreatedDate     : 22/06/2018
    *  ModifiedDate    :
    *  Parameters      : -
    *  Returns         : Boolean isVatIdValid
    ******************************************************************************/
    public Boolean validateVatId() {return null;}


    /*******************************************************************************
    *  Name            : doUpdateVatNumber(String deviceView)
    *  Summary         : Update account vat number
    *  CreatedDate     : 19/06/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doUpdateVatNumber(String deviceView) {}


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
            SELECT Id, Name, AccountId, RecordTypeId, E2E_Active_Step__c, E2E_Active_Substep__c, E2E_Encoded_URL__c, StageName, LeadSource, SEPA_Mandate_URL__c, E2E_Last_Activity__c, Primary_Contact_Phone__c, E2E_Form_of_Business__c, Agree_to_Privacy_Policy__c, Date_for_Agree_to_Privacy_Policy__c, E2E_Status__c, E2E_Sub_Status__c, Visitor_ID__c,
                Gruende_verloren__c, Utm_campaign__c, Utm_content__c, Utm_medium__c, Utm_placement__c, Utm_source__c, Utm_term__c, Utm_url__c, Zahlungsart__c, Total_consumption_l_month__c,
                Rechnungsperiode__c, CF_Credit_Limit__c, Security_Amount_To_Pay__c, Eco_Fee__c, IBAN__c, SWIFT_BIC__c, Papierrechnung__c, E2E_payment_status__c, CF_Stage__c, E2E_CF_Reports_Counter__c,
                Home_Station__c, ESI__c, Gasoline_consumption_l_month__c, Diesel_consumption_l_month__c, Auftragsvolumen__c, CloseDate, OwnerId, Owner.Email, Credit_System_Rating__c, Umsatz__c,
                Gruendungsjahr__c, Credit_System_Number__c, Zahl_der_Mitarbeiter__c, Zahlungsziel_Credit__c, Security_To_Pay__c, Kredit_Entscheidung__c, Credit_check_date__c, bearbeitet_von__c,
                Billing_Period_by_Sales__c, Pending_Deposit_by_CF__c, Max_Credit_Limit__c, Garantie__c, Buffer__c, Risk_Category__c, Product__c, Derzeitige_Zahlungsmethode__c, Number_of_cars__c,
                Number_of_trucks__c, Anzahl_der_Karten__c, Total_number_of_vehicles__c, Name_of_the_payer_Account_holder__c, Send_SEPA_approval_link__c, SEPA_Request_Approved__c, 
                Einwilligung_Lastschriftverfahren__c, SEPA_Request_Approval_Date__c, E2E_Errors__c, e_Invoicing_PDF__c, AGB_Datenschutzhinweise_Richtigkeit__c, Garantie_other__c, Starts_Status__c,
                ForecastCategoryName, Closed_Won_by_CF__c, Last_CF_Errors__c, Clubsmart__c, Language_preference__c, Sec_Channel__c, Channel__c, CurrencyIsoCode, Type, E2E_Sales_Type__c, E2E_Chat_Step__c,
                E2E_System_Error_Description__c, 
                (SELECT ContactId FROM OpportunityContactRoles WHERE IsPrimary = true LIMIT 1)
            FROM Opportunity
            WHERE Id = :opptyId
            LIMIT 1
        ];
        if (! opptyList.isEmpty() ) {
            this.opportunity = opptyList.get(0);

            // account
            List<Account> accountList = [
                SELECT Id, Name, AccountSource, RecordTypeId, Umsatzsteuer_ID__c, BillingCountry, BillingCity, BillingStreet, BillingPostalCode, ShippingCountry, ShippingPostalCode, ShippingCity,
                    ShippingStreet, Gesellschaftsform__c, Steuernummer__c, Beschaeftigte__c, Type
                FROM Account
                WHERE Id = :this.opportunity.AccountId
                LIMIT 1
            ];
            if (! accountList.isEmpty() ) this.account = accountList.get(0);

            // contact
            if (! this.opportunity.OpportunityContactRoles.isEmpty() ) {
                List<Contact> contactList = [
                    SELECT Id, Name, AccountId, RecordTypeId, Salutation, FirstName, LastName, Phone, Email, MailingCountry, MailingStreet, MailingPostalCode, MailingCity, Authorised_signatory__c, 
                        LeadSource 
                    FROM Contact
                    WHERE Id = :this.opportunity.OpportunityContactRoles.get(0).ContactId
                    LIMIT 1
                ];
                if (! contactList.isEmpty() ) this.contact = contactList.get(0);
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
        EmarsysSenderEuropeanService.sendE2EOpportunityToEmarsys(this.opportunity.Id);
    }


    /*******************************************************************************
    *  Name            : getAccount()
    *  Summary         : return account
    *  CreatedDate     : 07/03/2018
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
    *  CreatedDate     : 07/03/2018
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
                E2E_System_Error_Description__c,
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
    *  CreatedDate     : 07/03/2018
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
    *  CreatedDate     : 07/03/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : return contact
    ******************************************************************************/
    public Contact getContact() {
        return contact;
    }


    public static Set<String> cardConfigStepPagesSet = new Set<String>{
        'CARD CONFIGURATION',
        'CARD CONFIGURATION. SPECIAL OFFERS',
        'CARD CONFIGURATION. TECHNICAL PARAMETERS',
        'ORDER DETAIL BLOCK',
        'SAVE AND CONTINUE LATER',
        'HEADER',
        'FOOTER',
        'SYSTEM ERROR',
        'PROCESS ERROR',
        'VOUCHER'
    }; 
}