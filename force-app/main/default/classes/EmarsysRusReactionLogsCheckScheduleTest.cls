@isTest
private class EmarsysRusReactionLogsCheckScheduleTest {

    @isTest
    static void checkErrorsTest() {
        Test.startTest();

        EmarsysRusReactionLogsCheckSchedule scheduledContactReaction = new EmarsysRusReactionLogsCheckSchedule();
        String sch = '0 0 23 * * ?';
        system.schedule('Test Job Reaction', sch, scheduledContactReaction);

        Test.stopTest();
    }
}