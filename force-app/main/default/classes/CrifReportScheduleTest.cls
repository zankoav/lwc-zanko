@isTest
private class CrifReportScheduleTest {


    /*******************************************************************************
	*  Name            : testScheduleLaunch()
	*  Summary         : Test schedule launch.  
	*  CreatedDate     : 12/07/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	@isTest
    static void testScheduleLaunch() {
        Test.startTest();
	        CrifReportSchedule schedule = new CrifReportSchedule();
			String sch = '0 59 7-23 ? * MON-FRI'; 
			system.schedule('Test Crif Report Job', sch, schedule); 
		Test.stopTest(); 
    }
}