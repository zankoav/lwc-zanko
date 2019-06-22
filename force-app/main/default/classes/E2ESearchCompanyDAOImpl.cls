public class E2ESearchCompanyDAOImpl implements E2ESearchCompanyDAO {
    private Map<String, SObject> sobjectsMap;
    private Sobject jsonSettings;
    private Set<Id> reportIdsToDeleteSet;
    private Map<String, String> soqlFieldsMap = new Map<String, String>{
        'Opportunity' => 'E2E_Encoded_URL__c, Name, AccountId, E2E_Active_Step__c, Account.Name, Account.ShippingCity, Account.BillingCity'
    };    

    public E2ESearchCompanyDAOImpl() {
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
        originalContent.put('company_name', addParamToField(originalContent.get('company_name'), 'value', opportunity.Name));
        if (opportunity.Account.BillingCity != null) {
            originalContent.put('city', addParamToField(originalContent.get('city'), 'value', opportunity.Account.BillingCity));
        }        
        originalContent.put('opportunity_id', opportunity.Id);
        originalContent.put('account_id', opportunity.AccountId);

        return originalContent;
    }

    public void setReportIdsToDelete(Map<String, Object> content) {
        this.reportIdsToDeleteSet = new Set<Id>();
        String opportunityId = (String)content.get('opportunity_id');
        Map<Id, Credit_Factory_Report__c> reportsMap = new Map<Id, Credit_Factory_Report__c>([
                SELECT Id 
                FROM Credit_Factory_Report__c 
                WHERE Opportunity__c = :opportunityId]);

        Map<Id, Attachment> attachmentsMap = new Map<Id, Attachment>([
                SELECT Id
                FROM Attachment
                WHERE ParentId = :opportunityId AND 
                      Name = 'CrefoReport.pdf']);
        reportIdsToDeleteSet.addAll(reportsMap.keySet());
        reportIdsToDeleteSet.addAll(attachmentsMap.keySet());
    }

    public void deleteReports() {
        disableTriggers();
        delete [SELECT Id FROM Attachment WHERE Id IN :this.reportIdsToDeleteSet];
        delete [SELECT Id FROM Credit_Factory_Report__c WHERE Id IN :this.reportIdsToDeleteSet];
    }

    private Object addParamToField(Object field, String parameter, String value) {
        Map<String, Object> fieldMap = (Map<String, Object>)field;
        fieldMap.put(parameter,  value);
        return fieldMap;
    }

    private void selectRecord(String recordId) {
        String sobjectName = getSobjectName(recordId);
        String query = 'SELECT ' + soqlFieldsMap.get(sobjectName) + ' FROM ' + sobjectName + ' WHERE Id = :recordId';
        SObject record = Database.query(query);
        this.sobjectsMap.put(sobjectName, record);
    }

    public SObject getRecord(String sobjectName) {
        return sobjectsMap.get(sobjectName);
    }

    public void updateRecords(Map<String, Object> content, Boolean isContinue) {
        AccountTriggerHandler.enablesTrigger = false;
        ContactTriggerHandler.enablesTrigger = false;
        OpportunityTriggerHandler.enablesTrigger = false;
        OpportunityTriggerHandler.isE2EForm = true;
        TankkartenHandler.enablesTrigger = false;
        if (isContinue) {
            Opportunity opportunity = new Opportunity();
            opportunity.Id = (String)content.get('opportunity_id');
            opportunity.E2E_Active_Step__c = 2;
            update opportunity;
        } else {
            Opportunity opportunity = new Opportunity();
            opportunity.Id = (String)content.get('opportunity_id');
            opportunity.Name = (String)content.get('company_name');
            update opportunity;

            Account account = new Account();
            account.Id = (String)content.get('account_id');
            account.Name = (String)content.get('company_name');
            account.ShippingCity = (String)content.get('city');
            account.BillingCity = (String)content.get('city');
            update account;
        }
    }

    private String getSobjectName(String recordIdStr) {
        Id recordId = Id.valueOf(recordIdStr);
        String sobjectName = String.valueOf(recordId.getSobjectType());

        return sobjectName;
    }

    private String returnFieldValue(Object field, String parameter) {
        return (String)((Map<String, Object>)field).get(parameter);
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