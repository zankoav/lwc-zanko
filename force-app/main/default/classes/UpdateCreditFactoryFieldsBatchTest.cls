@isTest
private class UpdateCreditFactoryFieldsBatchTest {
	@isTest
    static void testMethod1() {
        Account account = new Account(
            Name ='Test');
        insert account;

        List<Opportunity> opList = new List<Opportunity>();
        Opportunity opportunity1 = new Opportunity(
            Name = 'Test', 
            StageName = 'Prospecting', 
            AccountID = account.Id, 
            CloseDate = date.today().addMonths(1), 
            Creditreform_Nummer__c = '123123',
            Creditreform_Rating__c = '1',
            Creditreform_Recommended_Rating__c = 123); 
        opList.add(opportunity1);

        Opportunity opportunity2 = new Opportunity(
            Name = 'Test', 
            StageName = 'Prospecting', 
            AccountID = account.Id, 
            CloseDate = date.today().addMonths(1), 
            Emarsys_Contact_Id__c = '371354459',
            Creditreform_Nummer__c = '123123123',
            Creditreform_Rating__c = '2',
            Creditreform_Recommended_Rating__c = 1231); 
        opList.add(opportunity2);
        insert opList;

        Test.startTest();

            UpdateCreditFactoryFieldsBatch creditFactoryFieldsBatch = new UpdateCreditFactoryFieldsBatch();
    		Database.executeBatch(creditFactoryFieldsBatch);

		Test.stopTest();

		List<Opportunity> testOpportunitiesList = [
				SELECT Id
				FROM Opportunity
				WHERE Credit_System_Number__c != null AND Credit_System_Rating__c != null AND Credit_System_Recommended_Limit__c != null];
		System.assertEquals(testOpportunitiesList.size(), 2);
    }
}