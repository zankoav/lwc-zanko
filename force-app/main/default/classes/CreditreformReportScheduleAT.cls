global class CreditreformReportScheduleAT implements Schedulable {
	// Once in an hour 
    // 00 01 8,10,12,14,16,18,20,22,00 ? * MON-FRI
    global void execute(SchedulableContext sc) {
        CreditreformReportBatchAT reportBatch = new CreditreformReportBatchAT();
        Database.executeBatch(reportBatch, 1);
    }
}