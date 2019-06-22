@isTest
private class CreditreformReportScheduleTestAT {


	/*******************************************************************************
	*  Name            : testSchedule()
	*  Summary         : Test schedule job  
	*  CreatedDate     : 04/10/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	@isTest
    static void testSchedule() {
        Test.startTest();
	        CreditreformReportScheduleAT schedule = new CreditreformReportScheduleAT();
			String sch = '0 0 0 * * ?'; 
			system.schedule('Test mailbox Job', sch, schedule); 
		Test.stopTest(); 
    }
}