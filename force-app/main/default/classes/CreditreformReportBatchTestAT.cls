@isTest
private class CreditreformReportBatchTestAT {


	/*******************************************************************************
	*  Name            : testAvailableReport()
	*  Summary         : Test check mailbox directory and entry with available report.
	*  CreatedDate     : 04/10/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	@isTest
	static void testAvailableReport() {
		CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemAT();
        insert creditSystem;

	    Account account = new Account(
	        Name = 'test',
	        BillingCountry = 'Austria');
	    insert account;

	    Opportunity opportunity = new Opportunity(
	        Anzahl_der_Karten__c = 5,
	        Zahlungsart__c = 'Lastschrift',
	        Zahlungsziel__c = '7',
	        Product__c = 'None',
	        StageName = 'Pending Credit Report',
	        Name = 'test opp',
	        Angebotsdauer__c = '3 Monate',
	        CloseDate = Date.today(),
	        AccountId = account.Id,
	        CF_Order_Reference_Number__c = '100000040',
	        OwnerId = UserInfo.getUserId());
	    insert opportunity;

	    List<Opportunity> opprtunitiesToBatchList = new List<Opportunity>{opportunity};

	    Test.startTest();
	    	Test.setMock(HttpCalloutMock.class, new CreditreformReportMockAT());
	    	Database.BatchableContext bc;
	    	CreditreformReportBatchAT batch = new CreditreformReportBatchAT();
	    	batch.start(bc);
	    	batch.execute(bc, opprtunitiesToBatchList);
	    	batch.finish(bc);
	    Test.stopTest();

	    List<Opportunity> opportunitiesList = [
	            SELECT Credit_Factory_PDF_Report_Created__c, StageName, (SELECT Id FROM Credit_Factory_Reports__r)
	            FROM Opportunity
	            WHERE Id = :opportunity.Id
	            LIMIT 1];

	    System.assertEquals(1, opportunitiesList.get(0).Credit_Factory_Reports__r.size());
	    System.assertEquals(true, opportunitiesList.get(0).Credit_Factory_PDF_Report_Created__c);
	    System.assertEquals('Credit Report Generated', opportunitiesList.get(0).StageName);
	}


	/******************************************************************************
	*  Name            : testNeedReportInformation()
	*  Summary         : Test check mailbox directory and entry with needed inforamtion about report
	*  CreatedDate     : 04/10/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	*****************************************************************************/
	@isTest
	static void testNeedReportInformation() {
		CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemAT();
        insert creditSystem;

	    Account account = new Account(
	        Name = 'test',
	        BillingCountry = 'Austria');
	    insert account;

	    Opportunity opportunity = new Opportunity(
	        Anzahl_der_Karten__c = 5,
	        Zahlungsart__c = 'Lastschrift',
	        Zahlungsziel__c = '7',
	        Product__c = 'None',
	        StageName = 'Pending Credit Report',
	        Name = 'test opp',
	        Angebotsdauer__c = '3 Monate',
	        CloseDate = Date.today(),
	        AccountId = account.Id,
	        CF_Order_Reference_Number__c = '100000045',
	        OwnerId = UserInfo.getUserId());
	    insert opportunity;

	    List<Opportunity> opprtunitiesToBatchList = new List<Opportunity>{opportunity};

	    Test.startTest();
	    	Test.setMock(HttpCalloutMock.class, new CreditreformReportMockAT());
	    	Database.BatchableContext bc;
	    	CreditreformReportBatchAT batch = new CreditreformReportBatchAT();
	    	batch.start(bc);
	    	batch.execute(bc, opprtunitiesToBatchList);
	    	batch.finish(bc);
	    Test.stopTest();

	    List<Opportunity> opportunitiesList = [
	            SELECT CF_Stage__c
	            FROM Opportunity
	            WHERE Id = :opportunity.Id
	            LIMIT 1];

	    System.assertEquals('Pending Credit Report - Additional information was sent', opportunitiesList.get(0).CF_Stage__c);
	}


	/*******************************************************************************
	*  Name            : testUnavailableReport()
	*  Summary         : Test check mailbox directory and entry with unavailable report response  
	*  CreatedDate     : 04/10/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	@isTest
	static void testUnavailableReport() {
		CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemAT();
        insert creditSystem;

	    Account account = new Account(
	        Name = 'test',
	        BillingCountry = 'Austria');
	    insert account;

	    Opportunity opportunity = new Opportunity(
	        Anzahl_der_Karten__c = 5,
	        Zahlungsart__c = 'Lastschrift',
	        Zahlungsziel__c = '7',
	        Product__c = 'None',
	        StageName = 'Pending Credit Report',
	        Name = 'test opp',
	        Angebotsdauer__c = '3 Monate',
	        CloseDate = Date.today(),
	        AccountId = account.Id,
	        CF_Order_Reference_Number__c = '100000043',
	        OwnerId = UserInfo.getUserId());
	    insert opportunity;

	    List<Opportunity> opprtunitiesToBatchList = new List<Opportunity>{opportunity};

	    Test.startTest();
	    	Test.setMock(HttpCalloutMock.class, new CreditreformReportMockAT());
	    	Database.BatchableContext bc;
	    	CreditreformReportBatchAT batch = new CreditreformReportBatchAT();
	    	batch.start(bc);
	    	batch.execute(bc, opprtunitiesToBatchList);
	    	batch.finish(bc);
	    Test.stopTest();

	    List<Opportunity> opportunitiesList = [
	            SELECT StageName
	            FROM Opportunity
	            WHERE Id = :opportunity.Id
	            LIMIT 1];

	    System.assertEquals('Closed Lost', opportunitiesList.get(0).StageName);
	}
}