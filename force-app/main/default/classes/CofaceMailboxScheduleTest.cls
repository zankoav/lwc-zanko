@isTest
private class CofaceMailboxScheduleTest {


    /*******************************************************************************
	*  Name            : testScheduleLaunch()
	*  Summary         : Test schedule launch.  
	*  CreatedDate     : 05/07/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	@isTest
    static void testScheduleLaunch() {
        Test.startTest();
	        CofaceMailboxSchedule schedule = new CofaceMailboxSchedule();
			String sch = '0 0 23 * * ?'; 
			system.schedule('Test Coface mailbox Job', sch, schedule); 
		Test.stopTest(); 
    }
}