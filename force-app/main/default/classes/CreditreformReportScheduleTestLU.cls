@isTest
private class CreditreformReportScheduleTestLU {


	/*******************************************************************************
	*  Name            : testSchedule()
	*  Summary         : Test schedule job  
	*  CreatedDate     : 21/11/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	@isTest
    static void testSchedule() {
        Test.startTest();
	        CreditreformReportScheduleLU schedule = new CreditreformReportScheduleLU();
			String sch = '0 0 0 * * ?'; 
			system.schedule('Test report LU Job', sch, schedule); 
		Test.stopTest(); 
    }
}