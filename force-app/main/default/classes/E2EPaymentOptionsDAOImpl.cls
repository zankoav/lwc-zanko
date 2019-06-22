public class E2EPaymentOptionsDAOImpl implements E2EPaymentOptionsDAO {
    private Map<String, SObject> sobjectsMap;
    private Sobject jsonSettings;
    private Map<String, String> soqlFieldsMap = new Map<String, String>{
        'Opportunity' => 'E2E_Encoded_URL__c, Name, AccountId, E2E_Active_Step__c, IBAN__c, SWIFT_BIC__c, Name_of_the_payer_Account_holder__c, Papierrechnung__c,' +
                         'SEPA_Request_Approved__c, AGB_Datenschutzhinweise_Richtigkeit__c, (SELECT ContactId, Contact.Authorised_signatory__c FROM OpportunityContactRoles LIMIT 1)'
    };

    public E2EPaymentOptionsDAOImpl() {
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
        System.debug('DEBUG: originalContent 1 === ' + originalContent.get('account_holder'));
        Opportunity opportunity = (Opportunity)getRecord('Opportunity');
        originalContent.put('iban', addParamToField(originalContent.get('iban'), 'value', opportunity.IBAN__c));     
        originalContent.put('swift', addParamToField(originalContent.get('swift'), 'value', opportunity.SWIFT_BIC__c));     
        originalContent.put('account_holder', addParamToField(originalContent.get('account_holder'), 'value', opportunity.Name_of_the_payer_Account_holder__c));     
        originalContent.put('paper_invoice', addParamToField(originalContent.get('paper_invoice'), 'value', String.valueOf(opportunity.Papierrechnung__c)));
        originalContent.put('sepa_block', addParamToField(originalContent.get('sepa_block'), 'accept_value', String.valueOf(opportunity.SEPA_Request_Approved__c)));
        originalContent.put('decision_agreement', addParamToField(originalContent.get('decision_agreement'), 'value', String.valueOf(opportunity.AGB_Datenschutzhinweise_Richtigkeit__c)));
        originalContent.put('terms_and_cond_agreement', addParamToField(originalContent.get('terms_and_cond_agreement'), 'value', String.valueOf(opportunity.OpportunityContactRoles.get(0).Contact.Authorised_signatory__c)));
        originalContent.put('opportunity_id', opportunity.Id);
        originalContent.put('account_id', opportunity.AccountId);
        originalContent.put('contact_id', opportunity.OpportunityContactRoles.get(0).ContactId);
        System.debug('DEBUG: originalContent 2 === ' + originalContent.get('account_holder'));
        return originalContent;
    }

    private void selectRecord(String recordId) {
        String sobjectName = getSobjectName(recordId);
        String query = 'SELECT ' + soqlFieldsMap.get(sobjectName) + ' FROM ' + sobjectName + ' WHERE Id = :recordId';
        SObject record = Database.query(query);
        this.sobjectsMap.put(sobjectName, record);
    }

    public void updateRecords(Map<String, Object> data) {
        AccountTriggerHandler.enablesTrigger = false;
        ContactTriggerHandler.enablesTrigger = false;
        OpportunityTriggerHandler.enablesTrigger = false;
        OpportunityTriggerHandler.isE2EForm = true;
        TankkartenHandler.enablesTrigger = false;

        Opportunity opportunity = new Opportunity();
        opportunity.Id = (String)data.get('opportunity_id');
        opportunity.E2E_Active_Step__c = 10; // TO REVIEW FOR DYNAMIC
        opportunity.IBAN__c = (String)data.get('iban');
        opportunity.SWIFT_BIC__c = (String)data.get('swift');
        opportunity.Name_of_the_payer_Account_holder__c = (String)data.get('account_holder');
        opportunity.Papierrechnung__c = Boolean.valueOf(data.get('paper_invoice'));
        opportunity.SEPA_Request_Approved__c = Boolean.valueOf(data.get('sepa_block'));
        opportunity.AGB_Datenschutzhinweise_Richtigkeit__c = Boolean.valueOf(data.get('decision_agreement'));        
        update opportunity;

        Contact contact = new Contact();
        contact.Id = (String)data.get('contact_id');
        contact.Authorised_signatory__c = Boolean.valueOf(data.get('terms_and_cond_agreement'));
        update contact;
    }

    private SObject getRecord(String sobjectName) {
        return sobjectsMap.get(sobjectName);
    }

    private Object addParamToField(Object field, String parameter, String value) {
        if (value == null) {
            value = '';
        }
        Map<String, Object> fieldMap = (Map<String, Object>)field;
        fieldMap.put(parameter,  value);
        return fieldMap;
    }

    private String returnFieldValue(Object field, String parameter) {
        System.debug('DEBUG: field === ' + field);
        System.debug('DEBUG: parameter === ' + parameter);
        return String.valueOf(((Map<String, Object>)field).get(parameter));
    }

    private String getSobjectName(String recordIdStr) {
        Id recordId = Id.valueOf(recordIdStr);
        String sobjectName = String.valueOf(recordId.getSobjectType());

        return sobjectName;
    }

    private void disableTriggers() {
        AccountTriggerHandler.enablesTrigger = false;
        ContactTriggerHandler.enablesTrigger = false;
        OpportunityTriggerHandler.enablesTrigger = false;
        OpportunityTriggerHandler.isE2EForm = true;
    }
}