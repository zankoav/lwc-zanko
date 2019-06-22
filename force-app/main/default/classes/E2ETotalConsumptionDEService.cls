public class E2ETotalConsumptionDEService extends E2ETotalConsumptionAbstract {
    public override void save(Map<String, E2EContentJson.ContentElement> contentsMap) {
    	disableTriggers();
    	Opportunity opportunity = getOpportunity();
    	opportunity.Total_consumption_l_month__c = Decimal.valueOf(contentsMap.get('TOTAL CONSUMPTION').value);
    	update opportunity;
    }


    public override void validate() {

    }


    private void disableTriggers() {
        AccountTriggerHandler.enablesTrigger = false;
        ContactTriggerHandler.enablesTrigger = false;
        OpportunityTriggerHandler.enablesTrigger = false;
        OpportunityTriggerHandler.isE2EForm = true;
    }
}