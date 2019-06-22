@isTest
private class E2ESwitchToManualBatchTest {
	@isTest
    static void switchToManualAbandonmentEmailTest() {
    	createOppWithAbondonedEmail();

	    Test.startTest();
	        E2ESwitchToManualBatch batch = new E2ESwitchToManualBatch();
	    	Database.executeBatch(batch);
    	Test.stopTest();

    	List<Opportunity> oppList = [SELECT E2E_Sub_Status__c, E2E_Sales_Type__c FROM Opportunity];
    	System.assertEquals('Switched to manual', oppList.get(0).E2E_Sub_Status__c);
    	System.assertEquals('E2E downgraded to manual', oppList.get(0).E2E_Sales_Type__c);
    }
    

    @isTest
    static void switchToManualSaveContinueTest() {
        createOppWithSaveContinue();

        Test.startTest();
            E2ESwitchToManualBatch batch = new E2ESwitchToManualBatch();
            Database.executeBatch(batch);
        Test.stopTest();

        List<Opportunity> oppList = [SELECT E2E_Sub_Status__c, E2E_Sales_Type__c FROM Opportunity];
        System.assertEquals('Switched to manual', oppList.get(0).E2E_Sub_Status__c);
        System.assertEquals('E2E downgraded to manual', oppList.get(0).E2E_Sales_Type__c);
    }


	private static void createOppWithAbondonedEmail() {
		Opportunity newOpp = new Opportunity(
			StageName = 'Prospecting',
			Name = 'test opp',
            E2E__c = true,
        	E2E_Status__c = 'Abandoned (hard)', 
        	E2E_Sub_Status__c = 'Marketing automation',
        	CloseDate = Date.today()
		);
		insert newOpp;

		Emarsys_Log__c testLog = new Emarsys_Log__c(
        	Email_Name__c = 'E2E Abandonment Email DE 3', 
        	Opportunity__c = newOpp.Id
        );
        insert testLog;

        E2E_Switched_to_Manual_Templates__c setting = new E2E_Switched_to_Manual_Templates__c(
            Name = 'E2E Abandonment Email DE 3');
        insert setting;
	}


    private static void createOppWithSaveContinue() {
        Opportunity newOpp = new Opportunity(
            StageName = 'Prospecting',
            Name = 'test opp',
            E2E__c = true,
            E2E_Status__c = 'Abandoned (hard)', 
            E2E_Sub_Status__c = 'Marketing automation',
            CloseDate = Date.today()
        );
        insert newOpp;

        Emarsys_Log__c testLog = new Emarsys_Log__c(
            Email_Name__c = 'E2E Save And Continue 3', 
            Opportunity__c = newOpp.Id
        );
        insert testLog;

        E2E_Switched_to_Manual_Templates__c setting = new E2E_Switched_to_Manual_Templates__c(
            Name = 'E2E Save And Continue 3');
        insert setting;        
    }
}