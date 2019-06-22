@isTest
private class EmarsysRusReactionLogsScheduleTest {

    /*******************************************************************************
     *  Name            : launchScheduleTest()
     *  Summary         : test launch Schedule Test
     *  CreatedDate     : 12/10/2017
     *  Parameters      : -
     *  Returns         : void
     ******************************************************************************/
    @isTest
    static void launchScheduleTest() {
        Emarsys_Contact_Subscriptions__c contactSubscriptions = new Emarsys_Contact_Subscriptions__c(
                Name = 'LeadSegment1',
                Segment_Id__c = '17564',
                Subscription_Name__c = 'Кейс №1: Не проданы карты, не устроила цена. Промо',
                Last_Update_Segment_Date__c = Datetime.now().addDays(-10),
                Type__c = 'Lead'
        );
        insert contactSubscriptions;

        Test.startTest();

        Map<String, String> headers = new Map<String, String>();
        headers.put('Content-Type', 'application/json');
        SingleRequestMock response = new SingleRequestMock(
                200, 'Complete',
                '{"replyCode": 0, "replyText": "OK", "data": ["385885793", "393615693", "371354459"]}',
                headers);
        Test.setMock(HttpCalloutMock.class, response);

        EmarsysRusReactionLogsSchedule logsReactionSchedule = new EmarsysRusReactionLogsSchedule();
        String sch = '0 0 23 * * ?';
        System.schedule('Test Rus Reaction Logs schedule', sch, logsReactionSchedule);

        Test.stopTest();
    }
}