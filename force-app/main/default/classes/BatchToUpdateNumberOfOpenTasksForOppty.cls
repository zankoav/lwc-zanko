global class BatchToUpdateNumberOfOpenTasksForOppty implements Database.Batchable<sObject> {
    public String query;
    public Datetime startDate;
    public Datetime endDate;

    global BatchToUpdateNumberOfOpenTasksForOppty() {
        startDate = Datetime.newInstance(2017, 1, 1);
        endDate = Datetime.newInstance(2018, 1, 22);
        this.query = 'SELECT Id, Number_of_open_tasks__c, (SELECT Id FROM Tasks WHERE IsClosed = false) ' +
                        'FROM Opportunity ' +
                        'WHERE CreatedDate >= :startDate AND CreatedDate <= :endDate AND ' +
                            'Number_of_open_tasks__c = null';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Sobject> scope) {
        List<Opportunity> opptiesToUpdateList = new List<Opportunity>();
        for (SObject sobj : scope) {
            Opportunity oppty = (Opportunity)sobj;
            oppty.Number_of_open_tasks__c = oppty.Tasks.size();
            opptiesToUpdateList.add(oppty);
        }
        update opptiesToUpdateList;
    }

    global void finish(Database.BatchableContext BC) {

    }
}