@isTest
private class CreditreformMailboxScheduleTest {


	/*******************************************************************************
	*  Name            : testMailBoxCheck()
	*  Summary         : test check mailbox directory and entry    
	*  CreatedDate     : 21/12/2017
	*  ModifiedDate    : 21/12/2017
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	@isTest
    static void testMailboxCheck() {
        Test.startTest();
	        CreditreformMailboxSchedule schedule = new CreditreformMailboxSchedule();
			String sch = '0 0 23 * * ?'; 
			system.schedule('Test mailbox Job', sch, schedule); 
		Test.stopTest(); 
    }
}