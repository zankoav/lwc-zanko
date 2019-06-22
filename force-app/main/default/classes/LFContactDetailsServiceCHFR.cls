public class LFContactDetailsServiceCHFR implements LFContactDetails {
    private Map<String, LongFormPage> pagesMap;
    private Account account;
    private Opportunity opportunity;
    private Contact contact;
    private String errorMessage;


    public LFContactDetailsServiceCHFR() {}


    /*******************************************************************************
    *  Name            : setPagesMap(String deviceView)
    *  Summary         : generate pages map for Step 0
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : String deviceView
    *  Returns         : void
    ******************************************************************************/
    public void setPagesMap(String deviceView) {
        E2E_Form_General_Settings__c settings = E2E_Form_General_Settings__c.getInstance('Switzerland-FR');

        Map<Id, LongForm_Page__c> lfPagesMap = new Map<Id, LongForm_Page__c>([
            SELECT Name, Type__c, Long_Form__c
            FROM LongForm_Page__c
            WHERE Long_Form__r.Country__c = 'Switzerland-FR' AND
                Name IN :contactDetailsStepPagesSet AND
                Device_View__c = :deviceView AND
                Long_Form__r.Test_mode__c = :settings.Test_mode__c
            LIMIT 10000
        ]);

        List<LongForm_Element__c> elementsList = [
            SELECT Name, Long_Form_Page__r.Title__c, Long_Form_Page__r.System_Error__c, Long_Form_Page__r.Name, Type__c,
                   (SELECT Name, Active__c, Type__c, Value__c FROM Long_Form_Element_Items__r)
            FROM LongForm_Element__c
            WHERE Long_Form_Page__c IN :lfPagesMap.keySet()
            LIMIT 10000
        ];

        this.pagesMap = new Map<String, LongFormPage>();
        Set<String> fieldTypes = new Set<String>{'Text Field', 'Picklist Field', 'Radio-button Field', 'Checkbox Field', 'Slider Field'};
        for (LongForm_Element__c element : elementsList) {
            if (! this.pagesMap.containsKey(element.Long_Form_Page__r.Name) ) {
                this.pagesMap.put(element.Long_Form_Page__r.Name, new LongFormPage());
                this.pagesMap.get(element.Long_Form_Page__r.Name).pageTitle = element.Long_Form_Page__r.Title__c;
                this.pagesMap.get(element.Long_Form_Page__r.Name).systemError = element.Long_Form_Page__r.System_Error__c;
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
    *  Summary         : return all pages for Step 0
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Map<String, LongFormPage> pagesMap
    ******************************************************************************/
    public Map<String, LongFormPage> getPagesMap() {
        return this.pagesMap;
    }


    /*******************************************************************************
    *  Name            : updateOpportunityOnReturnFromEmail(String deviceView)
    *  Summary         : Update Opportunity fields on return from marketing email. 
                         Marketing automation and abondoment or manual upgraded to E2E(JITB or Inbound on returned from email)
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : String deviceView
    *  Returns         : void
    ******************************************************************************/
    public void updateOpportunityOnReturnFromEmail(String deviceView) {
        if (this.opportunity != null && (this.opportunity.StageName == 'Closed Won' || this.opportunity.StageName == 'Closed Lost' || this.opportunity.StageName == 'Pending Sales – Deposit')) {
            // do not update fields if opportunity has closed status
            return;
        }

        if (this.opportunity.E2E_Status__c != 'Introduction') {
            this.opportunity.E2E_Status__c = 'In progress';
            this.opportunity.E2E_Sub_Status__c = '';
        }
        
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
        if (this.opportunity.E2E_Status__c != 'Introduction') {
            this.opportunity.E2E_Last_Activity__c = Datetime.now();
        }
        this.opportunity.E2E_followup_channel__c = ApexPages.currentPage().getparameters().get('followup');
        if (this.opportunity.E2E_Form_Type__c != null && ! this.opportunity.E2E_Form_Type__c.contains(deviceView)) {
            this.opportunity.E2E_Form_Type__c += ';' + deviceView;
        } else if (this.opportunity.E2E_Form_Type__c == null) {
            this.opportunity.E2E_Form_Type__c = deviceView;
        }
        update this.opportunity;
        EmarsysSenderEuropeanService.sendE2EOpportunityToEmarsys(opportunity.Id);
    }


    /*******************************************************************************
    *  Name            : validate()
    *  Summary         : field validation in step 0
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void validate() {
        this.errorMessage = '';
        validateFirstName();
        validateLastName();
        validateMobilePhone();
        validateEmail();
        validateFormOfBusiness();
        validateNewsAgreement();
        if (this.errorMessage != '') {
            throw new LongFormException(this.errorMessage);
        }
    }


    /*******************************************************************************
    *  Name            : getDuplicateContact()
    *  Summary         : Find duplicate Contact
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : String – type of duplicate record and id
    ******************************************************************************/
    public Contact getDuplicateContact() {
        String firstNameFieldValue = this.pagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c;
        String lastNameFieldValue = this.pagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c;
        String selectedPhone = this.pagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c;
        String selectedEmail = this.pagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c;

        List<RecordType> contactRecordTypeList = [SELECT Id FROM RecordType WHERE SobjectType = 'Contact' AND DeveloperName = 'Contact_layout' LIMIT 1];
        String contactRecordTypeID;
        if ( ! contactRecordTypeList.isEmpty()) {
            contactRecordTypeID = contactRecordTypeList.get(0).Id;
        }
        String emailDomain = '%' + selectedEmail.substringAfter('@');
        String contactsQuery =  'SELECT Account.AccountSource, AccountId, ' +
                                        '(SELECT Opportunity.AccountId, Opportunity.E2E_Encoded_URL__c FROM OpportunityContactRoles ' +
                                        'WHERE (Opportunity.StageName != \'Closed Won\' AND Opportunity.StageName != \'Closed Lost\' AND Opportunity.StageName != \'Pending Sales – Deposit\') AND '  +
                                                ' Opportunity.E2E__c = TRUE) ' +
                                'FROM Contact ' +
                                'WHERE (Email = :selectedEmail OR Phone = :selectedPhone OR ' +
                                '(FirstName = :firstNameFieldValue AND LastName = :lastNameFieldValue AND Email LIKE :emailDomain)) AND ' +
                                'MailingCountry = \'Switzerland-FR\' AND RecordTypeId = :contactRecordTypeID ';
        if (contact != null && contact.Id != null) {
            contactsQuery += 'AND Id != \'' + contact.Id + '\'';
        }
        contactsQuery = contactsQuery + 'ORDER BY CreatedDate DESC LIMIT 1';
        List<Contact> duplicateContactsList = Database.query(contactsQuery);
        if ( ! duplicateContactsList.isEmpty() ) {
            return duplicateContactsList.get(0);
        }

        return null;
    }


    /*******************************************************************************
    *  Name            : insertRecords(Contact contact, String deviceView)
    *  Summary         : creating account, opporunity and contact objects
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : Contact – existing contact, String deviceView
    *  Returns         : void
    ******************************************************************************/
    public void insertRecords(Contact dupContact, String deviceView) {
        String firstNameFieldValue = this.pagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c;
        String lastNameFieldValue = this.pagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c;
        String selectedPhone = this.pagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c;
        String selectedEmail = this.pagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c;

        List<RecordType> contactRecordTypeList = [SELECT Id FROM RecordType WHERE SobjectType = 'Contact' AND DeveloperName = 'Contact_layout' LIMIT 1];
        String contactRecordTypeID;
        if ( ! contactRecordTypeList.isEmpty()) {
            contactRecordTypeID = contactRecordTypeList.get(0).Id;
        }
        String emailDomain = '%' + selectedEmail.substringAfter('@');

        //new account
        List<RecordType> accountRecordTypeList = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Endkunde' LIMIT 1];
        this.account = new Account(
            Name = ('LongForm: ' + firstNameFieldValue + ' ' + lastNameFieldValue).toUpperCase(),
            BillingCountry = 'Switzerland-FR',
            ShippingCountry = 'Switzerland-FR',
            Type = 'Customer',
            E2E__c = true
        );
        if (! accountRecordTypeList.isEmpty()) {
            this.account.RecordTypeId = accountRecordTypeList.get(0).Id;
        }
        insert this.account;

        //new opportunity
        List<RecordType> opptyRecordTypeList = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'Euroshell' LIMIT 1];
        String ipAddress = LongFormGlobalUtils.getUserIPAddress();
        List<LongForm_Element_Item__c> ecoFee = [
                SELECT Value__c
                FROM LongForm_Element_Item__c
                WHERE Long_Form_Element__r.Long_Form_Page__r.Name = 'ADDITIONAL' AND Long_Form_Element__r.Name = 'CO2 TAKE CARE' AND Name = 'VALUE'
                LIMIT 1];

        Boolean isEcoFee = false;
        if ( ! ecoFee.isEmpty() ) {
            isEcoFee = Boolean.valueOf(ecoFee.get(0).Value__c);
        }  
        this.opportunity = new Opportunity(
            Name = ('LongForm: ' + firstNameFieldValue + ' ' + lastNameFieldValue).toUpperCase(),
            StageName = 'Prospecting',
            Product__c = '',
            AccountId = this.account.Id,
            CloseDate = Date.today(),
            Last_Owner_Change_Date__c = Datetime.now(),
            Language_preference__c = 'French',
            Primary_Contact_Phone__c = selectedPhone,
            Agree_to_Privacy_Policy__c = Boolean.valueOf(this.pagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c),
            Date_for_Agree_to_Privacy_Policy__c = Datetime.now(),
            E2E__c = true,
            LeadSource = 'E2E Form',
            Sec_Channel__c = 'Inbound',
            Channel__c = 'Internet',
            CurrencyIsoCode = 'CHF',
            Type = 'New Business',
            Device_Type__c = deviceView,
            E2E_Form_Type__c = deviceView + ';',
            Eco_Fee__c = isEcoFee,
            Visitor_ID__c = ipAddress,            
            AGB_Datenschutzhinweise_Richtigkeit__c = false,
            E2E_Form_of_Business__c = this.pagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c,
            E2E_Active_Step__c = 1,
            E2E_Active_Substep__c = 'Search company',
            E2E_Status__c = 'In progress',
            E2E_Sales_Type__c = 'Fully E2E'
        ); 
        if (this.pagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c == null) {
            this.pagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '1';
        }
        this.opportunity.Anzahl_der_Karten__c = Integer.valueOf(this.pagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c);
        setUtmSources();
        this.opportunity.E2E_followup_channel__c = ApexPages.currentPage().getParameters().get('followup');
        if (! opptyRecordTypeList.isEmpty()) {
            this.opportunity.RecordTypeId = opptyRecordTypeList.get(0).Id;
        }
        insert this.opportunity;

        //contact
        if (dupContact != null) {
            this.contact = dupContact;
            this.contact.AccountId = this.account.Id;
            update this.contact;
        } else {
            this.contact = new Contact(
                Salutation = this.pagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c,
                FirstName = firstNameFieldValue,
                LastName = lastNameFieldValue,
                AccountId = this.account.Id,
                Phone = selectedPhone,
                Email = selectedEmail,
                Authorised_signatory__c = false,
                E2E__c = true,
                MailingCountry = 'Switzerland-FR'
            );
            if (contactRecordTypeID != null) {
                this.contact.RecordTypeId = contactRecordTypeID;
            }
            insert this.contact;
        }
        if (this.opportunity.Anzahl_der_Karten__c != null) {
            List<Tankkarten__c> cardsToInsertList = new List<Tankkarten__c>();
            for (Integer i = 1; i <= this.opportunity.Anzahl_der_Karten__c; i++) {
                cardsToInsertList.add(
                    new Tankkarten__c(
                        Opportunity__c = this.opportunity.Id,
                        Produktbezugskategorie__c = '3 Kategorie 2 plus alle Shopartikel',
                        Gewuenschter_Kartentyp__c = 'Single Network Card -- National', 
                        Fahrzeugtyp__c = 'PKW'));
            }
            insert cardsToInsertList;
        }
        // create contact role
        OpportunityContactRole oppContactRole = new OpportunityContactRole(
            OpportunityId = this.opportunity.Id,
            ContactId = this.contact.Id,
            IsPrimary = true
        );
        insert oppContactRole;

        this.opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(this.opportunity, 'E2EFormCHFR');
        this.opportunity.E2E_Last_Activity__c = Datetime.now();
        this.opportunity.E2E_Short_Link__c = ShortURLHookService.generateShortId(null, opportunity.Id);
        ApexPages.currentPage().getparameters().put('source', this.opportunity.E2E_Encoded_URL__c);
        update this.opportunity;
        EmarsysSenderEuropeanService.sendE2EOpportunityToEmarsys(this.opportunity.Id);
    }


    /*******************************************************************************
    *  Name            : findDuplicateLead()
    *  Summary         : Find duplicate Lead
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void findDuplicateLead() {
        String firstName = this.pagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c;
        String lastName = this.pagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c;
        String phone = this.pagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c;
        String email = this.pagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c;

        LongFormGlobalUtils.findAndProcessDuplicateLead(
            firstName, lastName, email, phone, 'Switzerland-FR', 'Endkunde'
        );
    }


    /*******************************************************************************
    *  Name            : setUtmSources()
    *  Summary         : Set UTM sources based on parameters from the URL
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void setUtmSources() {
        // UTM Sources
        this.opportunity.Utm_campaign__c = ApexPages.currentPage().getparameters().get('utm_campaign');
        this.opportunity.Utm_content__c = ApexPages.currentPage().getparameters().get('utm_content');
        this.opportunity.Utm_medium__c = ApexPages.currentPage().getparameters().get('utm_medium');
        this.opportunity.Utm_placement__c = ApexPages.currentPage().getparameters().get('utm_placement');
        this.opportunity.Utm_source__c = ApexPages.currentPage().getparameters().get('utm_source');
        this.opportunity.Utm_term__c = ApexPages.currentPage().getparameters().get('utm_term');
        this.opportunity.Utm_url__c = ApexPages.currentPage().getparameters().get('utm_url');
    }


    /*******************************************************************************
    *  Name            : updateRecord()
    *  Summary         : update contact
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void updateRecord(Boolean isE2ERecord) {
        //update contact
        contact.Salutation = this.pagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c;
        contact.FirstName = this.pagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c;
        contact.LastName = this.pagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c;
        contact.Phone = this.pagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c;
        contact.Email = this.pagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c;
        if (this.pagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c == null) {
            this.pagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '1';
        }

        Database.SaveResult conUpdateResult = Database.update(contact, false);
        if (! conUpdateResult.isSuccess() ) {
            throw new LongFormException(this.pagesMap.get('CONTACT DETAILS').systemError);
        }
        if (this.opportunity != null) {
            String ipAddress = LongFormGlobalUtils.getUserIPAddress();
            this.opportunity.Primary_Contact_Phone__c = this.pagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c;
            this.opportunity.E2E_Form_of_Business__c = this.pagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c;
            this.opportunity.Agree_to_Privacy_Policy__c = Boolean.valueOf(this.pagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c);
            this.opportunity.Date_for_Agree_to_Privacy_Policy__c = Datetime.now();

            if ( ! isE2ERecord ) {
                this.opportunity.StageName = 'Prospecting';
                this.opportunity.E2E_Active_Step__c = 1;
                this.opportunity.E2E_Active_Substep__c = 'Search company';
            }

            this.opportunity.E2E_Last_Activity__c = Datetime.now();
            this.opportunity.Visitor_ID__c = ipAddress;
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
        }
    }


    /*******************************************************************************
    *  Name            : updateOpportunityToLost()
    *  Summary         : Change opportunity status to closed lost
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void updateOpportunityToLost() {
        this.opportunity.StageName = 'Closed Lost';
        this.opportunity.Gruende_verloren__c = 'Duplicate';
        this.opportunity.E2E_Status__c = 'Finished';
        update this.opportunity;
        EmarsysSenderEuropeanService.sendE2EOpportunityToEmarsys(opportunity.Id);
        this.opportunity = null;
    }


    /*******************************************************************************
    *  Name            : validateFirstName()
    *  Summary         : first name field validation
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void validateFirstName() {
        String firstNameFieldValue = this.pagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c;
        Pattern lettersPattern = Pattern.compile(LongFormGlobalUtils.LETTERS_SPACES_REGEX);
        Matcher lettersMatcher = lettersPattern.matcher(firstNameFieldValue);
        if ( ! lettersMatcher.matches() || firstNameFieldValue == '' || firstNameFieldValue == null) {
            this.errorMessage += this.pagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('WARN MESSAGE').Value__c + '<br/>';
        }
    }


    /*******************************************************************************
    *  Name            : validateLastName()
    *  Summary         : last name field validation
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void validateLastName() {
        String lastNameFieldValue = this.pagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c;
        Pattern lettersPattern = Pattern.compile(LongFormGlobalUtils.LETTERS_SPACES_REGEX);
        Matcher lettersMatcher = lettersPattern.matcher(lastNameFieldValue);
        if ( ! lettersMatcher.matches() || lastNameFieldValue == '' || lastNameFieldValue == null) {
            this.errorMessage += this.pagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('WARN MESSAGE').Value__c + '<br/>';
        }
    }


    /*******************************************************************************
    *  Name            : validateMobilePhone()
    *  Summary         : mobile fhone number field validation
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void validateMobilePhone() {
        String phoneNumber = this.pagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c;
        Boolean phoneNumberIsValid = LongFormGlobalUtils.validatePhone(phoneNumber, 'Switzerland-FR');
        if (phoneNumberIsValid != true) {
            this.errorMessage += this.pagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('WARN MESSAGE').Value__c + '<br/>';
        }
    }


    /*******************************************************************************
    *  Name            : validateEmail()
    *  Summary         : email field validation
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void validateEmail() {
        String emailAddress = this.pagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c;
        Boolean emailIsValid = LongFormGlobalUtils.validateEmailFormat(emailAddress);
        if (emailIsValid != true) {
            this.errorMessage += this.pagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('WARN MESSAGE').Value__c + '<br/>';
        }
    }


    /*******************************************************************************
    *  Name            : validateFormOfBusiness()
    *  Summary         : Form of business validation
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void validateFormOfBusiness() {
        String formOfBusiness = this.pagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c;
        if (formOfBusiness == null || formOfBusiness == '') {
            this.errorMessage += 'Please choose one form of business' + '<br/>';
        }
    }


    /*******************************************************************************
    *  Name            : validateNewsAgreement()
    *  Summary         : news agreement validation
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void validateNewsAgreement() {
        String newsAgreeCheckbox = this.pagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c;
        if (newsAgreeCheckbox == 'false') {
            this.errorMessage += 'Please agree with all conditions' + '<br/>';
        }
    }


    /*******************************************************************************
    *  Name            : setSFobjects(String opptyId)
    *  Summary         : set objects (account, opportunity, contact)
    *  CreatedDate     : 21/01/2019
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
                E2E_Form_Type__c, Agree_To_Deposit_Agreement__c, Date_For_Agree_To_Deposit_Agreement__c, E2E_System_Error_Description__c,
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
    *  Name            : getAccount()
    *  Summary         : returns the created account
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : return Account
    ******************************************************************************/
    public Account getAccount() {
        return this.account;
    }


    /*******************************************************************************
    *  Name            : setOpportunity()
    *  Summary         : Set opportunity to service
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : Opportunity
    *  Returns         : void
    ******************************************************************************/
    public void setOpportunity(Opportunity opportunity) {
        this.opportunity = opportunity;
    }


    /*******************************************************************************
    *  Name            : getOpportunity()
    *  Summary         : returns the created opportunity
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : return Opportunity
    ******************************************************************************/
    public Opportunity getOpportunity() {
        return this.opportunity;
    }


    /*******************************************************************************
    *  Name            : setContact(Contact contact)
    *  Summary         : Set contact to service
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void setContact(Contact contact) {
        this.contact = contact;
    }


    /*******************************************************************************
    *  Name            : getContact()
    *  Summary         : returns the created contact
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : return Contact
    ******************************************************************************/
    public Contact getContact() {
        return this.contact;
    }


    public static Set<String> contactDetailsStepPagesSet = new Set<String>{
        'CONTACT DETAILS',
        'HEADER',
        'FOOTER',
        'SYSTEM ERROR',
        'PROCESS ERROR'
    };
}