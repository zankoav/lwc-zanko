@isTest
private class CrifReportBatchTest {


	/*******************************************************************************
	*  Name            : testCorrectReportCreation()
	*  Summary         : Get "OK" request status.
	*  CreatedDate     : 12/07/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	@isTest
    static void testCorrectReportCreation() {
        CreditSystem__c creditSystem = CreditFactoryUtils.createCrifCreditSystem();
        insert creditSystem;

	    Account account = new Account(
	        Name = 'test',
	        BillingCountry = 'Poland');
	    insert account;

	    Opportunity opportunity = new Opportunity(
	        Anzahl_der_Karten__c = 5,
	        Zahlungsart__c = 'Lastschrift',
	        StageName = 'Pending Credit Report',
	        Name = 'test opp',
	        Angebotsdauer__c = '3 Monate',
	        CloseDate = Date.today(),
	        AccountId = account.Id,
	        Credit_Report_Id__c = '7261656513',
	        Credit_Report_Request_Date__c = Date.today(),
	        OwnerId = UserInfo.getUserId());
	    insert opportunity;

	    List<Opportunity> opprtunitiesToBatchList = new List<Opportunity>{opportunity};

	    Test.startTest();
	    	Test.setMock(HttpCalloutMock.class, new CrifReportMock());
	    	Database.BatchableContext bc;
	    	CrifReportBatch batch = new CrifReportBatch();
	    	batch.start(bc);
	    	batch.execute(bc, opprtunitiesToBatchList);
	    	batch.finish(bc);
	    Test.stopTest();

	    List<Credit_Factory_Report__c> reportsList = [
	    		SELECT Request_Status__c
	    		FROM Credit_Factory_Report__c];

	    System.assertEquals(1, reportsList.size());
	    System.assertEquals('OK', reportsList.get(0).Request_Status__c);
    }


    /*******************************************************************************
	*  Name            : testWrongReportCreation()
	*  Summary         : Get "OK" request status.
	*  CreatedDate     : 12/07/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	@isTest
    static void testWrongReportCreation() {
        CreditSystem__c creditSystem = CreditFactoryUtils.createCrifCreditSystem();
        insert creditSystem;

	    Account account = new Account(
	        Name = 'test',
	        BillingCountry = 'Poland');
	    insert account;

	    Opportunity opportunity = new Opportunity(
	        Anzahl_der_Karten__c = 5,
	        Zahlungsart__c = 'Lastschrift',
	        StageName = 'Pending Credit Report',
	        Name = 'test opp',
	        Angebotsdauer__c = '3 Monate',
	        CloseDate = Date.today(),
	        AccountId = account.Id,
	        Credit_Report_Id__c = '6171543064',
	        Credit_Report_Request_Date__c = Date.today(),
	        OwnerId = UserInfo.getUserId());
	    insert opportunity;

	    List<Opportunity> opprtunitiesToBatchList = new List<Opportunity>{opportunity};

	    Test.startTest();
	    	Test.setMock(HttpCalloutMock.class, new CrifReportMock());
	    	Database.BatchableContext bc;
	    	CrifReportBatch batch = new CrifReportBatch();
	    	batch.start(bc);
	    	batch.execute(bc, opprtunitiesToBatchList);
	    	batch.finish(bc);
	    Test.stopTest();

	    List<Credit_Factory_Report__c> reportsList = [
	    		SELECT Request_Status__c
	    		FROM Credit_Factory_Report__c];

	    System.assertEquals(1, reportsList.size());
	    System.assertEquals('ERROR', reportsList.get(0).Request_Status__c);
    }
}