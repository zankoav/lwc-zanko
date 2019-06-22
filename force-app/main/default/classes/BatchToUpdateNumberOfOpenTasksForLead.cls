global class BatchToUpdateNumberOfOpenTasksForLead implements Database.Batchable<sObject> {
    public String query;
    public Datetime startDate;
    public Datetime endDate;

    global BatchToUpdateNumberOfOpenTasksForLead() {
        startDate = Datetime.newInstance(2017, 1, 1);
        endDate = Datetime.newInstance(2018, 1, 22);
        this.query = 'SELECT Id, Number_of_open_tasks__c, (SELECT Id FROM Tasks WHERE IsClosed = false) ' +
                        'FROM Lead ' +
                        'WHERE isConverted = FALSE AND ' +
                        'Number_of_open_tasks__c = null AND ' +
                        'CreatedDate >= :startDate AND CreatedDate <= :endDate';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Sobject> scope) {
        List<Lead> leadsToUpdateList = new List<Lead>();
        for (SObject sobj : scope) {
            Lead lead = (Lead)sobj;
            lead.Number_of_open_tasks__c = lead.Tasks.size();
            leadsToUpdateList.add(lead);
        }
        update leadsToUpdateList;
    }

    global void finish(Database.BatchableContext BC) {

    }
}