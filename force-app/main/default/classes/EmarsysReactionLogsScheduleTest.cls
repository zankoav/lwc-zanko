@isTest
private class EmarsysReactionLogsScheduleTest {


	/*******************************************************************************
	*  Name            : createLeadLogsTest()
	*  Summary         : test creating logs
	*  CreatedDate     : 21/08/2017
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	@isTest
    static void createLeadLogsTest() {
    	List<RecordType> rtList = [
                SELECT Id
                FROM RecordType
                WHERE Name = 'Russian Sales' AND SobjectType = 'Lead'
                LIMIT 1];

        Profile p = [ SELECT Id  FROM Profile  WHERE Name = 'System Administrator'];

        User user = new User(Username = 'usertest123@fleetcor.de', ProfileId = p.Id, Alias = 'uset@fl', Email = 'usertes64t@fleetcor.de',
                EmailEncodingKey = 'UTF-8', Lastname = 'usertest', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Chicago');
        insert user;

        Lead lead = new Lead(
            Status = 'Contacted',
            LastName = 'test',
            Company = 'test',
            Phone = '1234567890',
            Country = 'Germany',
            State = 'Bavaria',
            Email = 'test@test.com',
            OwnerId = user.Id,
            Channel__c = 'Inbound',
            RecordTypeId = rtList.get(0).Id,
            Sec_Channel__c = 'Fax',
            Emarsys_Contact_Id__c = '393615693');
        insert lead;

        Test.setCreatedDate(lead.Id, Date.today().addDays(-5));
        Emarsys_Contact_Subscriptions__c leadSubscription = new Emarsys_Contact_Subscriptions__c(
        	Name = 'Lead Test Subscription',
            Subscription_Name__c = 'Lead Subscription',
            Type__c = 'Lead');
		insert leadSubscription;

        Test.StartTest();

        Test.setMock(HttpCalloutMock.class, new ListingContactsHttpResponseGenerator());
        EmarsysReactionLogsSchedule schedule = new EmarsysReactionLogsSchedule();
        schedule.execute(null);

        Test.stopTest();

        List<Emarsys_Log__c> leadLogsList = [
                SELECT Email_Name__c, Owner_Manager_Email__c
                FROM Emarsys_Log__c
                WHERE Lead__c = :lead.Id];
        System.assertEquals(leadLogsList.size(), 1);
    }


   	/*******************************************************************************
	*  Name            : createOpportunityLogsTest()
	*  Summary         : test creating logs
	*  CreatedDate     : 21/08/2017
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	@isTest
    static void createOpportunityLogsTest() {
    	List<RecordType> rtList = [
                SELECT Id
                FROM RecordType
                WHERE Name = 'Russian Sales' AND SobjectType = 'Opportunity'
                LIMIT 1];


        Profile p = [ SELECT Id  FROM Profile  WHERE Name = 'System Administrator'];

        User user = new User(Username = 'usertest123@fleetcor.de', ProfileId = p.Id, Alias = 'uset@fl', Email = 'usertes64t@fleetcor.de',
                EmailEncodingKey = 'UTF-8', Lastname = 'usertest', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Chicago');
        insert user;

        Account account = new Account(
            Name ='Test');
        insert account;

        Opportunity opportunity = new Opportunity(
            Name = 'Test', StageName = 'Prospecting',
            AccountID = account.Id,
            CloseDate = date.today().addMonths(1),
            Product__c = 'Home Station offer (v.1)',
            Angebotsdauer__c = '3 Monate',
            RecordTypeId = rtList.get(0).Id,
            OwnerId = user.Id,
            Emarsys_Contact_Id__c = '393615693');
        insert opportunity;

        Emarsys_Contact_Subscriptions__c leadSubscription = new Emarsys_Contact_Subscriptions__c(
        	Name = 'Opportunity Test Subscription',
            Subscription_Name__c = 'Opportunity Subscription',
            Type__c = 'Opportunity');
		insert leadSubscription;

        Test.StartTest();

        Test.setMock(HttpCalloutMock.class, new ListingContactsHttpResponseGenerator());
        EmarsysReactionLogsSchedule schedule = new EmarsysReactionLogsSchedule();
        schedule.execute(null);

		Test.stopTest();

        List<Emarsys_Log__c> opportunityLogsList = [
                SELECT Email_Name__c, Owner_Manager_Email__c
                FROM Emarsys_Log__c
                WHERE Opportunity__c = :opportunity.Id];
        System.assertEquals(opportunityLogsList.size(), 1);
    }
}