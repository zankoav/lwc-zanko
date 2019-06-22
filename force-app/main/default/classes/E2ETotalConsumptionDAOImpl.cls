public class E2ETotalConsumptionDAOImpl implements E2ETotalConsumptionDAO {
    private Map<String, SObject> sobjectsMap;
    private Sobject jsonSettings;
    private Map<String, String> soqlFieldsMap = new Map<String, String>{
        'Opportunity' => 'E2E_Encoded_URL__c, Name, AccountId, E2E_Active_Step__c, Total_consumption_l_month__c'
    };

    public E2ETotalConsumptionDAOImpl() {
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
        if (opportunity.Total_consumption_l_month__c != null) {
            originalContent.put('total_consumption', addParamToField(originalContent.get('total_consumption'), 'value', String.valueOf(opportunity.Total_consumption_l_month__c)));
        } else {
            originalContent.put('total_consumption', addParamToField(originalContent.get('total_consumption'), 'value', ''));
        }
        originalContent.put('opportunity_id', opportunity.Id);
        originalContent.put('account_id', opportunity.AccountId);

        return originalContent;
    }

    public void selectRecord(String recordId) {
        String sobjectName = getSobjectName(recordId);
        String query = 'SELECT ' + soqlFieldsMap.get(sobjectName) + ' FROM ' + sobjectName + ' WHERE Id = :recordId';
        SObject record = Database.query(query);
        this.sobjectsMap.put(sobjectName, record);
    }

    public SObject getRecord(String sobjectName) {
        return sobjectsMap.get(sobjectName);
    }

    public void updateRecords(Map<String, Object> data) {
        AccountTriggerHandler.enablesTrigger = false;
        ContactTriggerHandler.enablesTrigger = false;
        OpportunityTriggerHandler.enablesTrigger = false;
        OpportunityTriggerHandler.isE2EForm = true;
        TankkartenHandler.enablesTrigger = false;
        Opportunity opportunity = new Opportunity();
        opportunity.Id = (String)data.get('opportunity_id');
        opportunity.Total_consumption_l_month__c = Decimal.valueOf((String)data.get('total_consumption'));
        opportunity.E2E_Active_Step__c = 4; // TO REVIEW FOR DYNAMIC
        update opportunity;

        CreditFactoryReportController cfReportCtrl = new CreditFactoryReportController();
        cfReportCtrl.creditService = new CreditSystemService();
        cfReportCtrl.creditService.setCreditSystemSource(opportunity.Id);
        String creditSystemName = cfReportCtrl.creditService.getCreditSystemName();
        cfReportCtrl.reportService = cfReportCtrl.returnReportService(creditSystemName, opportunity.Id);
        cfReportCtrl.reportService.setUserSource('E2E Long Form');
        cfReportCtrl.reportService.setMapping();
        //set opportunity record
        cfReportCtrl.reportService.setSourceObject(opportunity.Id);
        //get credit report from SF if exists
        cfReportCtrl.reportService.setExistingCreditReports();
        //send request, get company and employees
        String selectedCompanyId = [SELECT Company_Id__c FROM Credit_Factory_Report__c WHERE Opportunity__c = :opportunity.Id].Company_Id__c;
        cfReportCtrl.reportService.setCompany(cfReportCtrl.creditService, selectedCompanyId);
        cfReportCtrl.company = (CreditCompany)cfReportCtrl.reportService.getCompany();
        cfReportCtrl.isSales = cfReportCtrl.reportService.isSales();
        cfReportCtrl.calculateBillingPeriod();
        CreditFactoryDecision cfDecision = cfReportCtrl.reportService.getDecision();
        //update credit report with credit score data
        cfReportCtrl.reportService.saveReports();
    }

    private String getSobjectName(String recordIdStr) {
        Id recordId = Id.valueOf(recordIdStr);
        String sobjectName = String.valueOf(recordId.getSobjectType());

        return sobjectName;
    }

    private Object addParamToField(Object field, String parameter, String value) {
        Map<String, Object> fieldMap = (Map<String, Object>)field;
        fieldMap.put(parameter,  value);
        return fieldMap;
    }

    private void disableTriggers() {
        AccountTriggerHandler.enablesTrigger = false;
        ContactTriggerHandler.enablesTrigger = false;
        OpportunityTriggerHandler.enablesTrigger = false;
        OpportunityTriggerHandler.isE2EForm = true;
    }    
}