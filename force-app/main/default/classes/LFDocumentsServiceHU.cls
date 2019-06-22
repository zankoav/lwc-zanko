public class LFDocumentsServiceHU implements LFDocuments {
    private Map<String, LongFormPage> pagesMap;
    private String errorMessage;
    private Account account;
    private Opportunity opportunity;
    private Contact contact;


    /*******************************************************************************
    *  Name            : setPagesMap()
    *  Summary         : generate pages map for "Documents" step
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
                Name IN :documentsStepPagesSet AND
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
    *  Name            : validateAgreements()
    *  Summary         : validate checkboxes of agreements
    *  CreatedDate     : 26/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void validateAgreements() { 
        String decision = pagesMap.get('DOCUMENTS').fields.get('DECISION').elementItemsMap.get('VALUE').Value__c;
        String acceptTermConditions = pagesMap.get('DOCUMENTS').fields.get('ACCEPT TERMS AND CONDITIONS').elementItemsMap.get('VALUE').Value__c;
        if (decision == 'false' || acceptTermConditions == 'false') throw new LongFormException('Please agree with all conditions');
    }


    /*******************************************************************************
    *  Name            : saveDocumentsStepData()
    *  Summary         : save "Documents" step data
    *  CreatedDate     : 26/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void saveDocumentsStepData() {
        if (this.opportunity.Rechnungsperiode__c == '15' && this.opportunity.Zahlungsziel_Credit__c == '14') {
            if (pagesMap.get('DOCUMENTS').fields.get('PAPER INVOICE').elementItemsMap.get('VALUE').Value__c == 'false') {
                this.opportunity.e_Invoicing_PDF__c = true;
                this.opportunity.Papierrechnung__c = false;
            } else {
                this.opportunity.Papierrechnung__c = true;
                this.opportunity.e_Invoicing_PDF__c = false;
            }
        }
        this.opportunity.AGB_Datenschutzhinweise_Richtigkeit__c = true;
        this.opportunity.E2E_Status__c = 'In progress';
        this.opportunity.E2E_Sub_Status__c = '';
        List<User> e2eUser = [SELECT Id FROM User WHERE Name = 'E2E Site Guest User' LIMIT 1];
        if ( ! e2eUser.isEmpty() ) {
            this.opportunity.OwnerId = e2eUser.get(0).Id;
        }
        update this.opportunity;
        EmarsysSenderEuropeanService.sendE2EOpportunityToEmarsys(opportunity.Id);
        this.contact.Authorised_signatory__c = true;
        update this.contact;  
    }


    /*******************************************************************************
    *  Name            : saveDepositAgreementStepData()
    *  Summary         : save deposit agreement step data
    *  CreatedDate     : 26/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void saveDepositAgreementStepData() {
        this.opportunity.Agree_To_Deposit_Agreement__c = true;
        this.opportunity.Date_For_Agree_To_Deposit_Agreement__c = Datetime.now();
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
    *  Name            : goToPaymentOptions()
    *  Summary         : go to "Payment options" step from "Documents" step (deposit case)    
    *  CreatedDate     : 26/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void goToPaymentOptions() {
        this.opportunity.E2E_Active_Step__c = 4;
        Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EFormHU').AES256_Key__c);
        String stringToEncode = this.opportunity.Id + '-' + this.opportunity.E2E_Active_Step__c;
        String encodedStringUrl = E2EFormEncryption.getHashAlgorithAES256(key256AES, stringToEncode);
        String ipAddress = LongFormGlobalUtils.getUserIPAddress();
        this.opportunity.StageName = 'Credit Approved';
        this.opportunity.E2E_Encoded_URL__c = encodedStringUrl;
        this.opportunity.Visitor_ID__c = ipAddress;
        this.opportunity.E2E_Last_Activity__c = Datetime.now();
        if (this.opportunity.Zahlungsart__c == 'Lastschrift') {
            this.opportunity.E2E_Active_Substep__c = 'DirectDebitDeposit';
        } else if (this.opportunity.Zahlungsart__c == 'Banküberweisung') {
            this.opportunity.E2E_Active_Substep__c = 'BankTransferDeposit';
        }
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
    *  Name            : goToCongratulations()
    *  Summary         : go to "Congratulations" step from "Documents" step (no deposit case)    
    *  CreatedDate     : 26/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void goToCongratulations() {
        E2E_Form_General_Settings__c settings = E2E_Form_General_Settings__c.getInstance('Hungary');
        String ipAddress = LongFormGlobalUtils.getUserIPAddress();
        if (settings.Set_GFN_Status__c) {
            this.opportunity.Starts_Status__c = '0.9 Ready for GFN';
            GFNI_Handler.createFullGFNCustomer(this.opportunity.Id);
        }
        this.opportunity.StageName = 'Closed Won';
        this.opportunity.ForecastCategoryName = 'Closed';
        this.opportunity.Visitor_ID__c = ipAddress;
        this.opportunity.Closed_Won_by_CF__c = true;
        this.opportunity.CF_Stage__c = 'Auto CW';
        this.opportunity.CloseDate = Date.today();
        this.opportunity.Billing_Period_by_Sales__c = true;
        this.opportunity.Last_CF_Errors__c = null;
        this.opportunity.E2E_Active_Step__c = 5;
        this.opportunity.E2E_Active_Substep__c = 'Congratulations';
        this.opportunity.E2E_Last_Activity__c = Datetime.now(); 
        this.opportunity.E2E_payment_status__c = 'NO DEPOSIT';      
        this.opportunity.E2E_Status__c = 'Finished';
        this.opportunity.E2E_Sub_Status__c = '';
        List<User> e2eUser = [SELECT Id FROM User WHERE Name = 'E2E Site Guest User' LIMIT 1];
        if ( ! e2eUser.isEmpty() ) {
            this.opportunity.OwnerId = e2eUser.get(0).Id;
        }

        update this.opportunity;
        EmarsysSenderEuropeanService.sendE2EOpportunityToEmarsys(opportunity.Id);
    }


    /*******************************************************************************
    *  Name            : setSFobjects(String opptyId)
    *  Summary         : set objects (account, opportunity, contact)
    *  CreatedDate     : 26/11/2018
    *  ModifiedDate    : -
    *  Parameters      : String opptyId
    *  Returns         : void
    ******************************************************************************/
    public void setSFobjects(String opptyId) {
        // opportunity
        List<Opportunity> opptyList = [
            SELECT Name, AccountId, RecordTypeId, E2E_Active_Step__c, E2E_Active_Substep__c, E2E_Encoded_URL__c, StageName, LeadSource, SEPA_Mandate_URL__c, Agree_to_process_pers_data_for_marketing__c, 
                Agree_to_telephone_contact__c, Agree_to_receive_comm_info_by_email__c, E2E_Last_Activity__c, Primary_Contact_Phone__c, E2E_Form_of_Business__c, Agree_to_Privacy_Policy__c, 
                Date_for_Agree_to_Privacy_Policy__c, E2E_Status__c, E2E_Sub_Status__c, Visitor_ID__c, Gruende_verloren__c, Utm_campaign__c, Utm_content__c, Utm_medium__c, Utm_placement__c, Utm_source__c, 
                Utm_term__c, Utm_url__c, Zahlungsart__c, Total_consumption_l_month__c, Rechnungsperiode__c, CF_Credit_Limit__c, Security_Amount_To_Pay__c, Eco_Fee__c, IBAN__c, SWIFT_BIC__c, Papierrechnung__c, 
                E2E_payment_status__c, CF_Stage__c, E2E_CF_Reports_Counter__c, Home_Station__c, ESI__c, Gasoline_consumption_l_month__c, Diesel_consumption_l_month__c, Auftragsvolumen__c, CloseDate, OwnerId, 
                Owner.Email, Credit_System_Rating__c, Umsatz__c, Gruendungsjahr__c, Credit_System_Number__c, Zahl_der_Mitarbeiter__c, Zahlungsziel_Credit__c, Security_To_Pay__c, Kredit_Entscheidung__c, 
                Credit_check_date__c, Bearbeitet_von__c, Billing_Period_by_Sales__c, Pending_Deposit_by_CF__c, Max_Credit_Limit__c, Garantie__c, Buffer__c, Risk_Category__c, Product__c, Derzeitige_Zahlungsmethode__c, 
                Number_of_cars__c, Number_of_trucks__c, Anzahl_der_Karten__c, Total_number_of_vehicles__c, Name_of_the_payer_Account_holder__c, Send_SEPA_approval_link__c, SEPA_Request_Approved__c, 
                Einwilligung_Lastschriftverfahren__c, SEPA_Request_Approval_Date__c, E2E_Errors__c, E_Invoicing_PDF__c, AGB_Datenschutzhinweise_Richtigkeit__c, Garantie_other__c, Starts_Status__c,
                ForecastCategoryName, Closed_Won_by_CF__c, Last_CF_Errors__c, Clubsmart__c, Language_preference__c, Sec_Channel__c, Channel__c, CurrencyIsoCode, Type, E2E_Sales_Type__c, E2E_Chat_Step__c,
                E2E_Form_Type__c, Agree_To_Deposit_Agreement__c, Date_For_Agree_To_Deposit_Agreement__c, E2E_System_Error_Description__c, Last_E2E_Error__c,
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
                        LeadSource, Title, Birthdate
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
    *  CreatedDate     : 26/11/2018
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
    *  Summary         : return account
    *  CreatedDate     : 26/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : return account
    ******************************************************************************/
    public Account getAccount() {
        return this.account;
    }


    /*******************************************************************************
    *  Name            : getOpportunity()
    *  Summary         : return opportunity
    *  CreatedDate     : 26/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : return opportunity
    ******************************************************************************/
    public Opportunity getOpportunity() {
        return this.opportunity;
    }


    /*******************************************************************************
    *  Name            : getContact()
    *  Summary         : return contact
    *  CreatedDate     : 26/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : return contact
    ******************************************************************************/
    public Contact getContact() {
        return this.contact;
    }


    /*******************************************************************************
    *  Name            : getPagesMap()
    *  Summary         : return all pages for "Documents" step
    *  CreatedDate     : 26/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Map<String, LongFormPage> pagesMap
    ******************************************************************************/
    public Map<String, LongFormPage> getPagesMap() {
        return this.pagesMap;
    }


    public static Set<String> documentsStepPagesSet = new Set<String>{
        'CARD CONFIGURATION. SPECIAL OFFERS',
        'ORDER DETAIL BLOCK',
        'SAVE AND CONTINUE LATER',
        'SEND DOCUMENTS TO THE EMAIL',
        'SEND TC TO THE EMAIL',
        'DOCUMENTS',
        'HEADER',
        'FOOTER',
        'SYSTEM ERROR',
        'PROCESS ERROR',
        'VOUCHER'
    };
}