@isTest
public class CofaceMailboxBatchTest {


    /*******************************************************************************
	*  Name            : testUnavailableReportMailbox()
	*  Summary         : Get "FinishedNegative" status.
	*  CreatedDate     : 30/06/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	@isTest
	static void testUnavailableReportMailbox() {
		CreditSystem__c creditSystem = CreditFactoryUtils.createCofaceCreditSystem();
        insert creditSystem;

	    Account account = new Account(
	        Name = 'test',
	        BillingCountry = 'Hungary');
	    insert account;

	    Opportunity opportunity = new Opportunity(
	        Anzahl_der_Karten__c = 5,
	        Zahlungsart__c = 'Lastschrift',
	        StageName = 'Pending Credit Report',
	        Name = 'test opp',
	        Angebotsdauer__c = '3 Monate',
	        CloseDate = Date.today(),
	        AccountId = account.Id,
	        CF_Order_Reference_Number__c = '1439776');
	    insert opportunity;

	    List<Opportunity> opprtunitiesToBatchList = new List<Opportunity>{opportunity};

	    Test.startTest();
	    	Test.setMock(HttpCalloutMock.class, new CofaceMailboxMock());
	    	Database.BatchableContext bc;
	    	CofaceMailboxBatch batch = new CofaceMailboxBatch();
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

	/*******************************************************************************
	*  Name            : testAvailableReportMailbox()
	*  Summary         : Get "Finished" status.
	*  CreatedDate     : 04/07/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	@isTest
	static void testAvailableReportMailbox() {
		CreditSystem__c creditSystem = CreditFactoryUtils.createCofaceCreditSystem();
        insert creditSystem;

	    Account account = new Account(
	        Name = 'test',
	        BillingCountry = 'Hungary');
	    insert account;

	    Opportunity opportunity = new Opportunity(
	        Anzahl_der_Karten__c = 5,
	        Zahlungsart__c = 'Lastschrift',
	        StageName = 'Pending Credit Report',
	        Name = 'test opp',
	        Angebotsdauer__c = '3 Monate',
	        CloseDate = Date.today(),
	        AccountId = account.Id,
	        CF_Order_Reference_Number__c = '1439777',
	        OwnerId = UserInfo.getUserId());
	    insert opportunity;

	    List<Opportunity> opprtunitiesToBatchList = new List<Opportunity>{opportunity};

	    Test.startTest();
	    	Test.setMock(HttpCalloutMock.class, new CofaceMailboxMock());
	    	Database.BatchableContext bc;
	    	CofaceMailboxBatch batch = new CofaceMailboxBatch();
	    	batch.start(bc);
	    	batch.execute(bc, opprtunitiesToBatchList);
	    	batch.finish(bc);
	    Test.stopTest();

	    List<Credit_Factory_Report__c> reportsList = [
	            SELECT Id, (SELECT Id FROM Credit_Factory_Report_Employees__r)
	            FROM Credit_Factory_Report__c
	            WHERE Name = 'M-SÉTÁNY Kereskedelmi, Szolgáltató és Vendéglátó Korlátolt Felelősségű Társaság'];

	    System.assertEquals(1, reportsList.size());
	    System.assertEquals(1, reportsList.get(0).Credit_Factory_Report_Employees__r.size());

	    List<Attachment> attachmentsList = [
	            SELECT Id
	            FROM Attachment
	            WHERE Name = 'Cofacereport.pdf'];

	    System.assertEquals(1, attachmentsList.size());
	}
}