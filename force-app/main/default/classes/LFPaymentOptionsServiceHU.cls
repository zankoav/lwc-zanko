public class LFPaymentOptionsServiceHU implements LFPaymentOptions {
    private Map<String, LongFormPage> pagesMap;
    public Map<String, String> paymentMap;
    private Payment_Transaction__c currentTransaction;
    private Account account;
    private Opportunity opportunity;
    private Contact contact;
    private String errorMessage;


    /*******************************************************************************
    *  Name            : setPagesMap()
    *  Summary         : generate pages map for Step 3 (Additional)
    *  CreatedDate     : 26/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void setPagesMap(String deviceView) {
        E2E_Form_General_Settings__c settings = E2E_Form_General_Settings__c.getInstance('Hungary');

        Map<Id, LongForm_Page__c> lfPagesMap = new Map<Id, LongForm_Page__c>([
            SELECT Name, Type__c, Long_Form__c
            FROM LongForm_Page__c
            WHERE Long_Form__r.Country__c = 'Hungary' AND
                Name IN :paymentOptionsPagesSet AND
                Device_View__c = :deviceView AND
                Long_Form__r.Test_mode__c = :settings.Test_mode__c
            LIMIT 10000
        ]);

        List<LongForm_Element__c> elementsList = [
            SELECT Name, Long_Form_Page__r.Title__c, Long_Form_Page__r.System_Error__c, Long_Form_Page__r.Name, Type__c,
                   (SELECT Name, Active__c, Type__c, Value__c FROM Long_Form_Element_Items__r)
            FROM LongForm_Element__c
            WHERE Long_Form_Page__c IN :lfPagesMap.keySet()
            LIMIT 10000];

        this.pagesMap = new Map<String, LongFormPage>();
        Set<String> fieldTypes = new Set<String>{'Text Field', 'Picklist Field', 'Radio-button Field', 'Checkbox Field', 'Slider Field'};
        for (LongForm_Element__c element : elementsList) {
            if (! this.pagesMap.containsKey(element.Long_Form_Page__r.Name) ) {
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
    *  Name            : Map<String, LongFormPage> getPagesMap()
    *  Summary         : return all pages for Step 3
    *  CreatedDate     : 26/11/2018
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
    *  CreatedDate     : 26/11/2018
    *  ModifiedDate    : -
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
    *  Name            : validate(Decimal activeStep, String activeSubstep)
    *  Summary         : validate field of 4 step
    *  CreatedDate     : 26/11/2018
    *  ModifiedDate    : -
    *  Parameters      : Decimal activeStep, String activeSubstep
    *  Returns         : void
    ******************************************************************************/
    public void validate(Decimal activeStep, String activeSubstep) {}


    /*******************************************************************************
    *  Name            : jsValidateIBAN()
    *  Summary         : validate IBAN field
    *  CreatedDate     : 19/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Boolean
    ******************************************************************************/
    public Boolean jsValidateIBAN() {return null;}


    /*******************************************************************************
    *  Name            : requestSwiftInfo()
    *  Summary         : request swift info    
    *  CreatedDate     : 12/02/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Boolean - show swift field OR not
    ******************************************************************************/
    public Boolean requestSwiftInfo() {return null;}


    /*******************************************************************************
    *  Name            : validateSWIFT(Decimal activeStep, String activeSubstep)
    *  Summary         : validate SWIFT field
    *  CreatedDate     : 26/11/2018
    *  ModifiedDate    : -
    *  Parameters      : Decimal activeStep, String activeSubstep
    *  Returns         : void
    ******************************************************************************/
    private void validateAgreements(Decimal activeStep, String activeSubstep) {}


    /*******************************************************************************
    *  Name            : void savePaymentOptionsDataWithoutDeposit(String activeSubstep)
    *  Summary         : do save data for payment options without deposit
    *  CreatedDate     : 19/10/2018
    *  ModifiedDate    : -
    *  Parameters      : String activeSubstep
    *  Returns         : void
    ******************************************************************************/
    public void savePaymentOptionsDataWithoutDeposit(String activeSubstep) {}


    /*******************************************************************************
    *  Name            : savePaymentOptionsDataWithDeposit(String activeSubstep)
    *  Summary         : DO NOT USED
    *  CreatedDate     : 19/10/2018
    *  ModifiedDate    : -
    *  Parameters      : String activeSubstep
    *  Returns         : void
    ******************************************************************************/
    public void savePaymentOptionsDataWithDeposit(String activeSubstep) {

    }


    /*******************************************************************************
    *  Name            : goToThanksPageFromPaymentSystem(String paymentStatus)
    *  Summary         : go to thanks page from external payment system
    *  CreatedDate     : 19/10/2018
    *  ModifiedDate    : -
    *  Parameters      : String paymentStatus
    *  Returns         : void
    ******************************************************************************/
    public void goToThanksPageFromPaymentSystem(String paymentStatus) {
        if (this.opportunity.E2E_Active_Substep__c != 'Congratulations') {
            this.opportunity.E2E_Sub_Status__c = '';
            List<User> e2eUser = [SELECT Id FROM User WHERE Name = 'E2E Site Guest User' LIMIT 1];
            if ( ! e2eUser.isEmpty() ) {
                this.opportunity.OwnerId = e2eUser.get(0).Id;
            }
            if (paymentStatus == 'A') {
                prepareOpptyFieldsForClosedWon();
                this.opportunity.Kredit_Entscheidung__c = 'Genehmigt, Sicherheit geliefert';
                if (this.opportunity.Garantie_other__c == null) {
                    this.opportunity.StageName = 'Pending Sales – Deposit';
                    this.opportunity.Starts_Status__c = '';
                }
            } else {
                String ipAddress = LongFormGlobalUtils.getUserIPAddress();
                this.opportunity.StageName = 'Pending Sales – Deposit';
                this.opportunity.E2E_Active_Substep__c = 'Congratulations';
                this.opportunity.Visitor_ID__c = ipAddress;
                this.opportunity.E2E_Active_Step__c = 5;
                this.opportunity.E2E_Status__c = 'Finished';
            }
            update this.opportunity;
            EmarsysSenderEuropeanService.sendE2EOpportunityToEmarsys(opportunity.Id);
        }
    }


    /*******************************************************************************
    *  Name            : prepareOpptyFieldsForClosedWon()
    *  Summary         : prepare opportunity fields for closed won
    *  CreatedDate     : 19/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void prepareOpptyFieldsForClosedWon() {
        E2E_Form_General_Settings__c settings = E2E_Form_General_Settings__c.getInstance('Hungary');
        String ipAddress = LongFormGlobalUtils.getUserIPAddress();
        if (settings.Set_GFN_Status__c) {
            this.opportunity.Starts_Status__c = '0.9 Ready for GFN';
        }
        this.opportunity.StageName = 'Closed Won';
        this.opportunity.ForecastCategoryName = 'Closed';
        this.opportunity.Visitor_ID__c = ipAddress;
        this.opportunity.Closed_Won_by_CF__c = true;
        this.opportunity.CF_Stage__c = 'Auto CW';
        this.opportunity.CloseDate = Date.today();
        this.opportunity.Billing_Period_by_Sales__c = true;
        this.opportunity.Last_CF_Errors__c = null;
        this.opportunity.E2E_Active_Substep__c = 'Congratulations';
        this.opportunity.E2E_Last_Activity__c = Datetime.now();
        this.opportunity.E2E_Active_Step__c = 5;
        this.opportunity.E2E_Status__c = 'Finished';
    }


    /*******************************************************************************
    *  Name            : setSFobjects(String opptyId)
    *  Summary         : set objects (account, opportunity, contact)
    *  CreatedDate     : 19/10/2018
    *  ModifiedDate    : -
    *  Parameters      : String opptyId
    *  Returns         : void
    ******************************************************************************/
    public void setSFobjects(String opptyId) {
        // opportunity
        List<Opportunity> opptyList = [
            SELECT Id, Name, AccountId, RecordTypeId, E2E_Active_Step__c, E2E_Active_Substep__c, E2E_Encoded_URL__c, StageName, LeadSource, SEPA_Mandate_URL__c, E2E_Last_Activity__c, Primary_Contact_Phone__c,
                E2E_Form_of_Business__c, E2E_Status__c, E2E_Sub_Status__c, Visitor_ID__c, Agree_to_process_pers_data_for_marketing__c, Agree_to_telephone_contact__c, Agree_to_receive_comm_info_by_email__c,
                Gruende_verloren__c, Utm_campaign__c, Utm_content__c, Utm_medium__c, Utm_placement__c, Utm_source__c, Utm_term__c, Utm_url__c, Zahlungsart__c, Total_consumption_l_month__c,
                Rechnungsperiode__c, CF_Credit_Limit__c, Security_Amount_To_Pay__c, Eco_Fee__c, IBAN__c, SWIFT_BIC__c, Papierrechnung__c, E2E_payment_status__c, CF_Stage__c, E2E_CF_Reports_Counter__c,
                Home_Station__c, ESI__c, Gasoline_consumption_l_month__c, Diesel_consumption_l_month__c, Auftragsvolumen__c, CloseDate, OwnerId, Owner.Email, Credit_System_Rating__c, Umsatz__c,
                Gruendungsjahr__c, Credit_System_Number__c, Zahl_der_Mitarbeiter__c, Zahlungsziel_Credit__c, Security_To_Pay__c, Kredit_Entscheidung__c, Credit_check_date__c, bearbeitet_von__c,
                Billing_Period_by_Sales__c, Pending_Deposit_by_CF__c, Max_Credit_Limit__c, Garantie__c, Buffer__c, Risk_Category__c, Product__c, Derzeitige_Zahlungsmethode__c, Number_of_cars__c,
                Number_of_trucks__c, Anzahl_der_Karten__c, Total_number_of_vehicles__c, Name_of_the_payer_Account_holder__c, Send_SEPA_approval_link__c, SEPA_Request_Approved__c,
                Einwilligung_Lastschriftverfahren__c, SEPA_Request_Approval_Date__c, E2E_Errors__c, e_Invoicing_PDF__c, AGB_Datenschutzhinweise_Richtigkeit__c, Garantie_other__c, Starts_Status__c,
                ForecastCategoryName, Closed_Won_by_CF__c, Last_CF_Errors__c, Clubsmart__c, Language_preference__c, Sec_Channel__c, Channel__c, CurrencyIsoCode, Type, E2E_Sales_Type__c, E2E_Chat_Step__c,
                E2E_Form_Type__c, Agree_To_Deposit_Agreement__c, Date_For_Agree_To_Deposit_Agreement__c, E2E_System_Error_Description__c, 
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
                    ShippingStreet, Gesellschaftsform__c, Steuernummer__c, Beschaeftigte__c, Type, HR_Abteilung_HRA_HRB_und_HR_Nummer__c
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
                        LeadSource, Birthdate
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
    *  CreatedDate     : 19/10/2018
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
    *  Name            : getAccount()
    *  Summary         : returns the created account
    *  CreatedDate     : 19/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : return Account
    ******************************************************************************/
    public Account getAccount() {
        return this.account;
    }


    /*******************************************************************************
    *  Name            : setOpportunity(Id opportunityId)
    *  Summary         : set opportunity
    *  CreatedDate     : 19/10/2018
    *  ModifiedDate    : -
    *  Parameters      : Id opportunityId
    *  Returns         : void
    ******************************************************************************/
    public void setOpportunity(Id opptyId) {
        if (opptyId == null) {
           opptyId = this.opportunity.Id;
        }
        // opportunity
        List<Opportunity> opptyList = [
            SELECT Id, Name, AccountId, RecordTypeId, E2E_Active_Step__c, E2E_Active_Substep__c, E2E_Encoded_URL__c, StageName, LeadSource, SEPA_Mandate_URL__c, E2E_Last_Activity__c, Primary_Contact_Phone__c, E2E_Form_of_Business__c, E2E_Status__c, E2E_Sub_Status__c, Visitor_ID__c, Agree_to_process_pers_data_for_marketing__c,
                Agree_to_telephone_contact__c, Agree_to_receive_comm_info_by_email__c,
                Gruende_verloren__c, Utm_campaign__c, Utm_content__c, Utm_medium__c, Utm_placement__c, Utm_source__c, Utm_term__c, Utm_url__c, Zahlungsart__c, Total_consumption_l_month__c,
                Rechnungsperiode__c, CF_Credit_Limit__c, Security_Amount_To_Pay__c, Eco_Fee__c, IBAN__c, SWIFT_BIC__c, Papierrechnung__c, E2E_payment_status__c, CF_Stage__c, E2E_CF_Reports_Counter__c,
                Home_Station__c, ESI__c, Gasoline_consumption_l_month__c, Diesel_consumption_l_month__c, Auftragsvolumen__c, CloseDate, OwnerId, Owner.Email, Credit_System_Rating__c, Umsatz__c,
                Gruendungsjahr__c, Credit_System_Number__c, Zahl_der_Mitarbeiter__c, Zahlungsziel_Credit__c, Security_To_Pay__c, Kredit_Entscheidung__c, Credit_check_date__c, bearbeitet_von__c,
                Billing_Period_by_Sales__c, Pending_Deposit_by_CF__c, Max_Credit_Limit__c, Garantie__c, Buffer__c, Risk_Category__c, Product__c, Derzeitige_Zahlungsmethode__c, Number_of_cars__c,
                Number_of_trucks__c, Anzahl_der_Karten__c, Total_number_of_vehicles__c, Name_of_the_payer_Account_holder__c, Send_SEPA_approval_link__c, SEPA_Request_Approved__c,
                Einwilligung_Lastschriftverfahren__c, SEPA_Request_Approval_Date__c, E2E_Errors__c, e_Invoicing_PDF__c, AGB_Datenschutzhinweise_Richtigkeit__c, Garantie_other__c, Starts_Status__c,
                ForecastCategoryName, Closed_Won_by_CF__c, Last_CF_Errors__c, Clubsmart__c, Language_preference__c, Sec_Channel__c, Channel__c, CurrencyIsoCode, Type, E2E_Sales_Type__c, E2E_Chat_Step__c,
                E2E_Form_Type__c, Agree_To_Deposit_Agreement__c, Date_For_Agree_To_Deposit_Agreement__c, E2E_System_Error_Description__c, 
                (SELECT ContactId FROM OpportunityContactRoles WHERE IsPrimary = true LIMIT 1)
            FROM Opportunity
            WHERE Id = :opptyId
            LIMIT 1
        ];
        if (! opptyList.isEmpty() ) {
            this.opportunity = opptyList.get(0);
        }
    }


    /*******************************************************************************
    *  Name            : getOpportunity()
    *  Summary         : returns the created opportunity
    *  CreatedDate     : 19/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : return Opportunity
    ******************************************************************************/
    public Opportunity getOpportunity() {
        return this.opportunity;
    }


    /*******************************************************************************
    *  Name            : getContact()
    *  Summary         : returns the created contact
    *  CreatedDate     : 19/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : return Contact
    ******************************************************************************/
    public Contact getContact() {
        return this.contact;
    }


    public Map<String, String> getPaymentMap() {
        return paymentMap;
    }


    /*******************************************************************************
    *  Name            : prepareTransaction(String deviceView)
    *  Summary         : prepare client transaction and paymentMap with parameters.
    *  CreatedDate     : 19/10/2018
    *  ModifiedDate    : -
    *  Parameters      : String deviceView
    *  Returns         : -
    *  ****************************************************************************/
    public void prepareTransaction(String deviceView) {
        E2E_Form_General_Settings__c settings = E2E_Form_General_Settings__c.getInstance('Hungary');

        paymentMap = new Map<String, String>();
        if ((opportunity != null) && (E2EKeysAPI__c.getValues('E2EFormHU') != null)){

            List<Payment_Transaction__c> checkExistTransactions = [
                    SELECT id, OrderID__c, Amount__c, Currency__c,OpportunityID__c
                    FROM Payment_Transaction__c
                    WHERE Status__c = null
                    AND OpportunityID__c = :opportunity.id
                    AND Amount__c = :opportunity.Security_Amount_To_Pay__c
                    LIMIT 1
            ];

            if (checkExistTransactions.isEmpty()) {
                currentTransaction = new Payment_Transaction__c();
                currentTransaction.Currency__c = 'HUF';
                currentTransaction.Amount__c = opportunity.Security_Amount_To_Pay__c;
                currentTransaction.OpportunityId__c = opportunity.id;
                insert currentTransaction;

                //Get autonumber OrderID__c (generated after insert)
                currentTransaction = [
                        SELECT id, OrderID__c, Amount__c, Currency__c, OpportunityId__c
                        FROM Payment_Transaction__c
                        WHERE Id = :currentTransaction.id
                ];
            } else {
                currentTransaction = checkExistTransactions.get(0);
            }

            paymentMap.put('ORDERID'     , currentTransaction.OrderID__c);
            paymentMap.put('PSPID'       , E2EKeysAPI__c.getValues('E2EFormHU').PSPID__c);
            paymentMap.put('CURRENCY'    , currentTransaction.Currency__c);
            if (currentTransaction.Amount__c != null) {
                paymentMap.put('AMOUNT'      , String.valueOf(currentTransaction.Amount__c*100));
            } else {
                paymentMap.put('AMOUNT'      , '0');
            } //Need value*100 without "."
            paymentMap.put('LANGUAGE'    , 'hu_HU'); // ar_AR (Arabic);  cs_CZ (Czech);  dk_DK (Danish);  de_DE (German);   el_GR (Greek);   es_ES (Spanish);  fi_FI (Finnish);
                  // fr_FR (French);  he_IL (Hebrew);   hu_(HU hungarian);  it_IT (Italian);  ja_JP (Japanese);  ko_KR (Korean);  nl_BE (Flemish);  nl_NL (Dutch);
                  // no_NO (Norwegian);  pl_PL (Polish);  pt_PT (Portugese);  ru_RU (Russian);  se_SE (Swedish);  sk_SK (Slovak);  tr_TR (Turkish);  zh_CN (Simplified Chinese)
            String vfPageWithParams;
            if (deviceView == 'Desktop') {
                vfPageWithParams = '/e2eformhu?source=';
            } else if (deviceView == 'Mobile') {
                vfPageWithParams = '/e2eformmobhu?source=';
            }
            Blob keyAES256 = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EFormHU').AES256_Key__c);
            paymentMap.put('ACCEPTURL'   , settings.Payment_URL__c + vfPageWithParams
                    + E2EFormEncryption.getHashAlgorithAES256(keyAES256, String.valueOf(this.opportunity.Id + '-5@A'))
            );
            paymentMap.put('DECLINEURL'  , settings.Payment_URL__c + vfPageWithParams
                    + E2EFormEncryption.getHashAlgorithAES256(keyAES256, String.valueOf(this.opportunity.Id + '-5@D'))
            );
            paymentMap.put('EXCEPTIONURL', settings.Payment_URL__c + vfPageWithParams
                    + E2EFormEncryption.getHashAlgorithAES256(keyAES256, String.valueOf(this.opportunity.Id + '-5@E'))
            );
            paymentMap.put('CANCELURL'   , settings.Payment_URL__c + vfPageWithParams
                    + E2EFormEncryption.getHashAlgorithAES256(keyAES256, String.valueOf(this.opportunity.Id + '-5@C'))
            );
            paymentMap.put('TP'          , 'mainTemplateHU.html'); //FOR NL - mainTemplateNL.html , FOR BE mainTemplateBE.html
            // paymentMap.put('ISSUERID'          , '9999%2BTST');

            calculateSHAParameter();
        }
    }


    /*******************************************************************************
    *  Name            : updatePaymentMethod
    *  Summary         : update Payment Method, Brand for transaction parameters
    *  CreatedDate     : 19/10/2018
    *  ModifiedDate    : -
    *  Parameters      : String paymentMethod
    *  Returns         : -
    ******************************************************************************/
    public void updatePaymentMethod(String paymentMethod) {
        if (paymentMethod == 'Sofort'){
            paymentMap.put('BRAND', 'DirectEbankingNL');
        } else
        if (paymentMethod == 'iDeal') {
            paymentMap.put('BRAND', 'iDEAL');
        } else
        if (paymentMethod == 'Bancontact') {
            paymentMap.put('BRAND', 'BCMC');
        } else
        {
            paymentMap.put('BRAND', paymentMethod);
        }

        if (paymentMap.get('BRAND') == 'Visa' || paymentMap.get('BRAND') == 'MasterCard'  ||
                paymentMap.get('BRAND') == 'Maestro' || paymentMap.get('BRAND') == 'BCMC'){
            paymentMap.put('PM', 'CreditCard');
        } else if (paymentMap.get('BRAND') != ''){
            paymentMap.put('PM', paymentMap.get('BRAND'));
        }
        calculateSHAParameter();
    }


    /*******************************************************************************
    *  Name            : calculateSHAParameter
    *  Summary         : calculate SHA1 hash code(SHASIGN) (send transaction to Ingenico)
    *  CreatedDate     : 19/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Boolean
    ******************************************************************************/
    public Boolean calculateSHAParameter(){
        Boolean result = false;
        if (E2EKeysAPI__c.getValues('E2EFormHU') != null) {
            paymentMap.put('SHASIGN', E2EFormEncryption.getHashAlgorithmStringSHA1(
                    'ACCEPTURL=' + paymentMap.get('ACCEPTURL') + E2EKeysAPI__c.getValues('E2EFormHU').SHA_KeyIn__c +
                    'AMOUNT=' + paymentMap.get('AMOUNT') + E2EKeysAPI__c.getValues('E2EFormHU').SHA_KeyIn__c +
                    'BRAND=' + paymentMap.get('BRAND') + E2EKeysAPI__c.getValues('E2EFormHU').SHA_KeyIn__c +
                    'CANCELURL=' + paymentMap.get('CANCELURL') + E2EKeysAPI__c.getValues('E2EFormHU').SHA_KeyIn__c +
                    'CURRENCY=' + paymentMap.get('CURRENCY') + E2EKeysAPI__c.getValues('E2EFormHU').SHA_KeyIn__c +
                    'DECLINEURL=' + paymentMap.get('DECLINEURL') + E2EKeysAPI__c.getValues('E2EFormHU').SHA_KeyIn__c +
                    'EXCEPTIONURL=' + paymentMap.get('EXCEPTIONURL') + E2EKeysAPI__c.getValues('E2EFormHU').SHA_KeyIn__c +
                    //'ISSUERID=' + paymentMap.get('ISSUERID') + E2EKeysAPI__c.getValues('E2EFormHU').SHA_KeyIn__c +
                    'LANGUAGE=' + paymentMap.get('LANGUAGE') + E2EKeysAPI__c.getValues('E2EFormHU').SHA_KeyIn__c +
                    'ORDERID=' + paymentMap.get('ORDERID') + E2EKeysAPI__c.getValues('E2EFormHU').SHA_KeyIn__c +
                    'PM=' + paymentMap.get('PM') + E2EKeysAPI__c.getValues('E2EFormHU').SHA_KeyIn__c +
                    'PSPID=' + paymentMap.get('PSPID') + E2EKeysAPI__c.getValues('E2EFormHU').SHA_KeyIn__c +
                    'TP=' + paymentMap.get('TP') + E2EKeysAPI__c.getValues('E2EFormHU').SHA_KeyIn__c
            ));
            result = true;
        }
        return result;
    }


    /*******************************************************************************
    *  Name            : receiveFreeBonus(Integer numberOfCards)
    *  Summary         : to receive FREE extra bonus
    *  CreatedDate     : 19/10/2018
    *  ModifiedDate    : -
    *  Parameters      : Integer numberOfCards
    *  Returns         : void
    ******************************************************************************/
    public void receiveFreeBonus(Integer numberOfCards) {}


    /*******************************************************************************
    *  Name            : saveTransactionData()
    *  Summary         : set transaction data
    *  CreatedDate     : 19/10/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void saveTransactionData() {
        if (currentTransaction != null){
            currentTransaction.PaymentMethod__c = paymentMap.get('PM');
            currentTransaction.Brand__c = paymentMap.get('BRAND');
            update currentTransaction;
        }
    }


    public static Set<String> paymentOptionsPagesSet = new Set<String>{
        'PAYMENT OPTIONS',
        'CONGRATULATIONS',
        'CARD CONFIGURATION. SPECIAL OFFERS',
        'ORDER DETAIL BLOCK',
        'SAVE AND CONTINUE LATER',
        'SEND HOW TO PAY TO THE EMAIL',
        'SEND TC TO THE EMAIL',
        'SEND DD MANDATE ACCEPTANCE TO THE EMAIL',
        'CREDIT SCORE. ADDITIONAL CREDIT SCORING',
        'HEADER',
        'FOOTER',
        'SYSTEM ERROR',
        'PROCESS ERROR',
        'VOUCHER'
    };
}