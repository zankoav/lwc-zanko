@isTest
private class BatchToUpdateNumberOfOpenTasksLeadTest {
    public static Lead newLead;

    static testMethod void testMethod1() {
        createLead();
        createTask(); 

        newLead.Number_of_open_tasks__c = null;
        update newLead;
        Test.startTest();
            BatchToUpdateNumberOfOpenTasksForLead batch = new BatchToUpdateNumberOfOpenTasksForLead();
            Database.executeBatch(batch); 
        Test.stopTest();
    }

    private static void createLead() {
        newLead = new Lead(
            Country = 'Germany',
            Company = 'Company test',
            Salutation = 'Herr',
            Anzahl_der_Karten_Euroshell__c = 'test',
            Anzahl_der_Fahrzeuge__c = 1, 
            FirstName = 'nameLead', 
            LastName = 'familyLead', 
            Number_of_open_tasks__c = 0, 
            Sec_Channel__c = 'Inbound',
            Phone = '3333333',
            LeadSource = 'Internet',
            Status = 'Contacted',
            CreatedDate = Datetime.newInstance(2018, 1, 20),
            Disable_for_KPI__c = FALSE           
            );
        insert newLead;
    }

    private static void createTask() {
        Task newTaskToLead = new Task(
            Subject = 'Call',
            Priority = 'Normal',
            WhoId = newLead.Id,
            Status = 'In Bearbeitung');
        
        insert newTaskToLead;
    }
}