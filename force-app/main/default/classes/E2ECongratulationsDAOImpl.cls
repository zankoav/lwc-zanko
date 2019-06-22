public class E2ECongratulationsDAOImpl implements E2ECongratulationsDAO {
	private Map<String, SObject> sobjectsMap;
	private Sobject jsonSettings;
	private Map<String, String> soqlFieldsMap = new Map<String, String>{
	    'Opportunity' => 'E2E_Encoded_URL__c, Name, AccountId, E2E_Active_Step__c, Account.Steuernummer__c, Anzahl_der_Karten__c, ' +
	    				 'Account.BillingCity, Account.BillingStreet, Account.BillingPostalCode, Clubsmart__c, ' +
	    				 '(SELECT Contact.Salutation, Contact.FirstName, Contact.LastName FROM OpportunityContactRoles)'
	};

	public E2ECongratulationsDAOImpl() {
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
	    originalContent.put('number_of_cards', String.valueOf(opportunity.Anzahl_der_Karten__c));
	    originalContent.put('is_clubsmart', String.valueOf(opportunity.Clubsmart__c));


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
	    opportunity.Clubsmart__c = Decimal.valueOf((String)data.get('number_of_cards')); // TO REVIEW FOR DYNAMIC
	    update opportunity;
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