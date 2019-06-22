@isTest
private class CrifPdfScheduleTest {


    /*******************************************************************************
    *  Name            : testCrifPdfRequest()
    *  Summary         : Get fake response, check creating attachment and opportunity update
    *  CreatedDate     : 17/01/2018
    *  ModifiedDate    : 17/01/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void testCrifPdfRequest() {
    	Account account = CreditFactoryUtils.createCrifAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrifOpportunity(account.Id);
        insert opportunity;
        
        Test.startTest();
	        Test.setMock(HttpCalloutMock.class, new CrifReportPdfMock());
	        CrifPdfSchedule.sendPdfRequest('https://demo.deltavista.pl/Search_Soap_Service_PL/services/SearchService,' + 
		    	'https://demo.deltavista.pl/dvs-soap/services/OrderCheckService,https://demo.deltavista.pl/pdfservice/pdfservlet', 
		    	'demo_fleetcor_soap', 'cvujmHe4', '4358000002428652', opportunity.Id);
        Test.stopTest();

        List<Attachment> attachmentsList = [
                SELECT Id
                FROM Attachment
                WHERE Name = 'CrifReport.pdf' AND ParentId = :opportunity.Id];

       	System.assertEquals(1, attachmentsList.size());
    }
}