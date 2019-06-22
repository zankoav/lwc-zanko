public class E2EContactDetailsDAOImpl implements E2EContactDetailsDAO {
    private Map<String, SObject> sobjectsMap;
    private Sobject jsonSettings;
    private Map<String, String> soqlFieldsMap = new Map<String, String>{
        'Opportunity' => 'E2E_Encoded_URL__c, E2E_Form_of_Business__c, Anzahl_der_Karten__c, Agree_to_Privacy_Policy__c, AccountId, ' + 
                         '(SELECT ContactId, Contact.Salutation, Contact.FirstName, Contact.LastName, Contact.Phone, Contact.Email FROM OpportunityContactRoles WHERE IsPrimary = TRUE LIMIT 1)'
    };

    public E2EContactDetailsDAOImpl() {
        this.sobjectsMap = new Map<String, SObject>();
    }

    public void selectSettings(String name) {
        this.jsonSettings = [SELECT Body FROM StaticResource WHERE Name = :name LIMIT 1];
    }

    public Sobject getSettings() {
        return this.jsonSettings;
    }

    public Map<String, Object> addDataFromDatabase(Map<String, Object> originalContent, String source) {
        String opportunityId = E2ENewUtils.decryptOpportunityId(source);            
        selectRecord(opportunityId);

        Opportunity opportunity = (Opportunity)getRecord('Opportunity');
        originalContent.put('salutation', addParamToField(originalContent.get('salutation'), 'value', opportunity.OpportunityContactRoles.get(0).Contact.Salutation.toLowerCase()));
        originalContent.put('first_name', addParamToField(originalContent.get('first_name'), 'value', opportunity.OpportunityContactRoles.get(0).Contact.FirstName));        
        originalContent.put('last_name', addParamToField(originalContent.get('last_name'), 'value', opportunity.OpportunityContactRoles.get(0).Contact.LastName));        
        originalContent.put('phone', addParamToField(originalContent.get('phone'), 'value', opportunity.OpportunityContactRoles.get(0).Contact.Phone));        
        originalContent.put('email', addParamToField(originalContent.get('email'), 'value', opportunity.OpportunityContactRoles.get(0).Contact.Email));        
        originalContent.put('business_type', addParamToField(originalContent.get('business_type'), 'value', opportunity.E2E_Form_of_Business__c));
        originalContent.put('number_of_cards', addParamToField(originalContent.get('number_of_cards'), 'value', String.valueOf(opportunity.Anzahl_der_Karten__c)));
        originalContent.put('news_agreement', addParamToField(originalContent.get('news_agreement'), 'value', String.valueOf(opportunity.Agree_to_Privacy_Policy__c)));
        originalContent.put('opportunity_id', opportunity.Id);
        originalContent.put('contact_id', opportunity.OpportunityContactRoles.get(0).Id);
        originalContent.put('account_id', opportunity.AccountId);

        return originalContent;
    }

    private void selectRecord(String recordId) {
        String sobjectName = getSobjectName(recordId);
        String query = 'SELECT ' + soqlFieldsMap.get(sobjectName) + ' FROM ' + sobjectName + ' WHERE Id = :recordId';
        SObject record = Database.query(query);
        this.sobjectsMap.put(sobjectName, record);
    }


    private SObject getRecord(String sobjectName) {
        return sobjectsMap.get(sobjectName);
    }

    // public void setRecord(Sobject sobjectRecord) {
    //     Id recordId = Id.valueOf(String.valueOf(sobjectRecord.get('Id')));
    //     String sobjectName = String.valueOf(recordId.getSobjectType());
    //     sobjectsMap.put(
    //         sobjectName,
    //         sobjectRecord);
    // }

    public String insertRecords(Map<String, Object> content) {
        AccountTriggerHandler.enablesTrigger = false;
        ContactTriggerHandler.enablesTrigger = false;
        OpportunityTriggerHandler.enablesTrigger = false;
        OpportunityTriggerHandler.isE2EForm = true;
        TankkartenHandler.enablesTrigger = false;
        // new account
        Account account = initNewAccount(content); 
        insert account;
        sobjectsMap.put('Account', account);

        // new opportunity  
        Opportunity opportunity = initNewOpportunity(content);
        insert opportunity;
        sobjectsMap.put('Opportunity', opportunity);

        // new contact
        Contact contact = initNewContact(content);
        insert contact;
        sobjectsMap.put('Contact', contact);

        // new cards
        List<Tankkarten__c> cardsList = initCards();
        insert cardsList;

        // new contact roles
        OpportunityContactRole oppContactRole = initOpportunityContactRole();
        insert oppContactRole;

        // generate codes
        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EForm');
        opportunity.SEPA_Mandate_URL__c = LongFormGlobalUtils.generateOppWithSepaUrl(opportunity, 'E2EForm');
        opportunity.E2E_Short_Link__c = ShortURLHookService.generateShortId(null, opportunity.Id);        
        update opportunity;
        sobjectsMap.put('Opportunity', opportunity);

        return opportunity.E2E_Encoded_URL__c;
    }

    public String updateRecords(Map<String, Object> content) {
        AccountTriggerHandler.enablesTrigger = false;
        ContactTriggerHandler.enablesTrigger = false;
        OpportunityTriggerHandler.enablesTrigger = false;
        OpportunityTriggerHandler.isE2EForm = true;
        TankkartenHandler.enablesTrigger = false;
        String recordName = ('LongForm: ' + 
                            (String)content.get('first_name') + ' ' + 
                            (String)content.get('last_name')).toUpperCase();        
        Opportunity opportunity = new Opportunity();
        opportunity.Id = (String)content.get('opportunity_id');
        opportunity.Name = recordname;
        opportunity.E2E_Form_of_Business__c = (String)content.get('business_type');
        update opportunity;

        Account account = new Account();
        account.Id = (String)content.get('opportunity_id');
        account.Name = recordName;
        update account;

        Contact contact = new Contact();
        contact.FirstName = (String)content.get('first_name');
        contact.LastName = (String)content.get('last_name');
        contact.Phone = (String)content.get('phone');
        contact.Email = (String)content.get('email');
        update contact;

        return LongFormGlobalUtils.generateRecordIdWithEncodedUrl(opportunity.Id, 'E2EForm');   
    }

    private String getSobjectName(String recordIdStr) {
        Id recordId = Id.valueOf(recordIdStr);
        String sobjectName = String.valueOf(recordId.getSobjectType());

        return sobjectName;
    }


    private Account initNewAccount(Map<String, Object> content) {
        String accountName = ('LongForm: ' + 
                            (String)content.get('first_name') + ' ' + 
                            (String)content.get('last_name')).toUpperCase();
        Account account = new Account(
            Name = accountName,
            BillingCountry = (String)content.get('country'),
            ShippingCountry = (String)content.get('country'),
            RecordTypeId = returnRecordTypeId('Account', 'Endkunde'),
            Type = 'Customer',
            E2E__c = true
        );

        return account;
    }

    private Opportunity initNewOpportunity(Map<String, Object> content) {
        String opportunityName = ('LongForm: ' + 
                            (String)content.get('first_name') + ' ' + 
                            (String)content.get('last_name')).toUpperCase();
        Opportunity opportunity = new Opportunity(
            Name = opportunityName,
            StageName = 'Prospecting',
            Product__c = '',
            AccountId = (String)sobjectsMap.get('Account').get('Id'),
            CloseDate = Date.today(),
            Last_Owner_Change_Date__c = Datetime.now(),
            Language_preference__c = (String)content.get('language'),
            Primary_Contact_Phone__c = (String)content.get('phone'),
            Agree_to_Privacy_Policy__c = Boolean.valueOf(content.get('news_agreement')),
            Date_for_Agree_to_Privacy_Policy__c = Datetime.now(),
            E2E__c = true,
            LeadSource = 'E2E Form',
            Sec_Channel__c = 'Inbound',
            Channel__c = 'Internet',
            CurrencyIsoCode = 'EUR',
            Type = 'New Business',
            Device_Type__c = 'Desktop',
            E2E_Form_Type__c = 'Desktop' + ';',    
            AGB_Datenschutzhinweise_Richtigkeit__c = false,
            E2E_Form_of_Business__c = (String)content.get('business_type'),
            E2E_Active_Step__c = 1,
            E2E_Last_Activity__c = Datetime.now(),
            Anzahl_der_Karten__c = Decimal.valueOf((String)content.get('number_of_cards')),
            E2E_Status__c = 'In progress',
            E2E_Sales_Type__c = 'Fully E2E',
            RecordTypeId = returnRecordTypeId('Opportunity','Euroshell')
        ); 

        return opportunity;
    }

    private Contact initNewContact(Map<String, Object> content) {
        Contact contact = new Contact(
            Salutation = (String)content.get('salutation'),
            FirstName = (String)content.get('first_name'),
            LastName = (String)content.get('last_name'),
            AccountId = (String)sobjectsMap.get('Account').get('Id'),
            Phone = (String)content.get('phone'),
            Email = (String)content.get('email'),
            Authorised_signatory__c = false,
            E2E__c = true,
            MailingCountry = (String)content.get('country'),
            RecordTypeId = returnRecordTypeId('Contact','Contact_layout')
        );

        return contact;
    } 

    private List<Tankkarten__c> initCards() {
        List<Tankkarten__c> cardsToInsertList = new List<Tankkarten__c>();
        String category = '2 Kategorie 1 plus fahrzeugbezogene Waren und Dienstleistungen (Öle, Autowäsche)';
        String type = 'Multi Network Card -- National';
        for (Integer i = 1; i <= Integer.valueOf(sobjectsMap.get('Opportunity').get('Anzahl_der_Karten__c')); i++) {
            cardsToInsertList.add(
                new Tankkarten__c(
                    Opportunity__c = (String)sobjectsMap.get('Opportunity').get('Id'),
                    Produktbezugskategorie__c = category,
                    Gewuenschter_Kartentyp__c = type));
        }

        return cardsToInsertList;
    }

    private OpportunityContactRole initOpportunityContactRole() {
        OpportunityContactRole oppContactRole = new OpportunityContactRole(
            OpportunityId = (String)sobjectsMap.get('Opportunity').get('Id'),
            ContactId = (String)sobjectsMap.get('Contact').get('Id'),
            IsPrimary = true
        );

        return oppContactRole;
    }

    private Object addParamToField(Object field, String parameter, String value) {
        Map<String, Object> fieldMap = (Map<String, Object>)field;
        fieldMap.put(parameter,  value);
        return fieldMap;
    }       

    private String returnRecordTypeId(String sobjectName, String recordTypeName) {
        List<RecordType> recordTypeList = [
                SELECT Id 
                FROM RecordType 
                WHERE SobjectType = :sobjectName AND 
                      DeveloperName = :recordTypeName
                LIMIT 1];
        if ( ! recordTypeList.isEmpty() ) {
            return recordTypeList.get(0).Id;
        }
        return null;
    }

    private void disableTriggers() {
        AccountTriggerHandler.enablesTrigger = false;
        ContactTriggerHandler.enablesTrigger = false;
        OpportunityTriggerHandler.enablesTrigger = false;
        OpportunityTriggerHandler.isE2EForm = true;
    }
}