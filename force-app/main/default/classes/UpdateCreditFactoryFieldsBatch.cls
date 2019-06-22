global class UpdateCreditFactoryFieldsBatch implements Database.Batchable<sObject> {
    public String query;

    global UpdateCreditFactoryFieldsBatch() {
        this.query = 'SELECT Credit_System_Number__c, Creditreform_Nummer__c, Credit_System_Rating__c, Creditreform_Rating__c, Credit_System_Recommended_Limit__c, ' +
        'Creditreform_Recommended_Rating__c FROM Opportunity WHERE (Credit_System_Number__c = null AND Creditreform_Nummer__c != null) OR (Credit_System_Rating__c = null ' + 
        'AND Creditreform_Rating__c != null) OR (Credit_System_Recommended_Limit__c = null AND Creditreform_Recommended_Rating__c != null)';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Opportunity> opportunitiesScope) {
        for (Opportunity opportunity : opportunitiesScope) {
            if (opportunity.Credit_System_Number__c == null && opportunity.Creditreform_Nummer__c != null) {
                opportunity.Credit_System_Number__c = opportunity.Creditreform_Nummer__c;
            } 

            if (opportunity.Credit_System_Rating__c == null && opportunity.Creditreform_Rating__c != null) {
                opportunity.Credit_System_Rating__c = opportunity.Creditreform_Rating__c;
            }

            if (opportunity.Credit_System_Recommended_Limit__c == null && opportunity.Creditreform_Recommended_Rating__c != null) {
                opportunity.Credit_System_Recommended_Limit__c = opportunity.Creditreform_Recommended_Rating__c;
            }
        }

        update opportunitiesScope;
    }

    global void finish(Database.BatchableContext BC) {

    }
}