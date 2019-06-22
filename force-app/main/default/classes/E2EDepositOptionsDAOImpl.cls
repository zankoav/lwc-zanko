public class E2EDepositOptionsDAOImpl implements E2EDepositOptionsDAO {
    private Map<String, SObject> sobjectsMap;
    private Sobject jsonSettings;
    private Map<String, String> soqlFieldsMap = new Map<String, String>{
        'Opportunity' => 'E2E_Encoded_URL__c, Name, AccountId, E2E_Active_Step__c, Agree_To_Deposit_Agreement__c'
    };

    public E2EDepositOptionsDAOImpl() {
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
        originalContent.put('opportunity_id', opportunity.Id);
        originalContent.put('account_id', opportunity.AccountId);

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
        opportunity.E2E_Active_Step__c = 11; // TO REVIEW FOR DYNAMIC
        opportunity.Agree_To_Deposit_Agreement__c = true;
        update opportunity;
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