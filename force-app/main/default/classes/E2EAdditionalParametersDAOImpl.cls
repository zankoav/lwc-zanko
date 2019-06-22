public class E2EAdditionalParametersDAOImpl implements E2EAdditionalParametersDAO {
    private Map<String, SObject> sobjectsMap;
    private Sobject jsonSettings;
    private Map<String, String> soqlFieldsMap = new Map<String, String>{
        'Opportunity' => 'E2E_Encoded_URL__c, Name, AccountId, E2E_Active_Step__c, Eco_Fee__c'
    };

    public E2EAdditionalParametersDAOImpl() {
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
        if (opportunity.Eco_Fee__c) {
        	List<Object> services = (List<Object>)originalContent.get('additional_services');
        	Map<String, Object> service = (Map<String, Object>)services.get(0);
        	service.put('checkbox_value', String.valueOf(opportunity.Eco_Fee__c));
        	List<Object> newServices = new List<Object>();
        	newServices.add(service);
        	originalContent.put('services', newServices);
        }

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

        Opportunity opportunity = new Opportunity();
        opportunity.Id = (String)data.get('opportunity_id');
        opportunity.E2E_Active_Step__c = 9; // TO REVIEW FOR DYNAMIC
        String jsonStr = JSON.serialize(data);
        Map<String, Object> dataNew = (Map<String, Object>)JSON.deserializeUntyped(jsonStr);
        opportunity.Eco_Fee__c = Boolean.valueOf(((Map<String,Object>)((List<Object>)dataNew.get('services')).get(0)).get('checkbox_value'));
        update opportunity;
        System.debug('DEBUG: opportunity === ' + opportunity);
    }

    private SObject getRecord(String sobjectName) {
        return sobjectsMap.get(sobjectName);
    }

    private Object addParamToField(Object field, String parameter, String value) {
        Map<String, Object> fieldMap = (Map<String, Object>)field;
        fieldMap.put(parameter,  value);
        return fieldMap;
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