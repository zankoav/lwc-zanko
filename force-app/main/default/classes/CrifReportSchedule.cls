global class CrifReportSchedule implements Schedulable {
    // Once in an hour 
    // 00 59 7-23 ? * MON-FRI
    global void execute(SchedulableContext sc) {
        CrifReportBatch batch = new CrifReportBatch();
        Database.executeBatch(batch, 1);
    }
}