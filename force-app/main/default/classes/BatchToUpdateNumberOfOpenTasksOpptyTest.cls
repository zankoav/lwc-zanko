@isTest
private class BatchToUpdateNumberOfOpenTasksOpptyTest {
	public static Opportunity newOpportunity;

    static testMethod void testMethod1() {
        createOpportunity();
        createTask(); 

        Test.startTest();
		  	BatchToUpdateNumberOfOpenTasksForOppty batch = new BatchToUpdateNumberOfOpenTasksForOppty();
	        Database.executeBatch(batch); 
        Test.stopTest();
    }

    private static void createOpportunity() {
        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Euroshell' AND sObjectType = 'Opportunity' LIMIT 1];
        newOpportunity = new Opportunity(
            RecordTypeId = rt.Id,
            Name = 'test opportunity',
            Starts_Status__c = '0. Request received',
            Starts_Schedule__c = Date.today().addDays(-1),
            Starts_Status_Delay__c = false,
            Anzahl_der_Karten__c = 123,
            Zahlungsart__c = 'Lastschrift',
            Name_of_the_payer_Account_holder__c = 'test payer',
            Angebotsdauer__c = 'test',
            Language_preference__c = 'Polish',
            Product__c = 'Home Station offer (v.1)',
            Home_Station__c = '123test',
            IBAN__c = '23424',
            SWIFT_BIC__c = '23423',
            Number_of_open_tasks__c = null,
            Derzeitige_Zahlungsmethode__c = 'Barzahlung',
            Requested_monthly_Company_Credit_Spend__c = 12345,
            AGB_Datenschutzhinweise_Richtigkeit__c = true,
            Data_Protection_Act_1998__c = true,
            Umsatz__c = '123', 
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(-50),
            CreatedDate = Datetime.newInstance(2018, 1, 20),
            Bevollmaechtigung__c = true
        );
        insert newOpportunity;
    }


    private static void createTask() {
    	List<Task> tasksToInsert = new List<Task>();
    	Task newTaskToOppty = new Task(
			Subject = 'Call',
			Priority = 'Normal',
			WhatId = newOpportunity.Id,
			Status = 'In Bearbeitung');
		
		tasksToInsert.add(newTaskToOppty);
    }
}