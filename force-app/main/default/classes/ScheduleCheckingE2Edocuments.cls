global class ScheduleCheckingE2Edocuments implements Schedulable {
    global void execute(SchedulableContext sc) {
        BatchCheckingE2Edocuments batch = new BatchCheckingE2Edocuments();
        Database.executeBatch(batch);
    }
}