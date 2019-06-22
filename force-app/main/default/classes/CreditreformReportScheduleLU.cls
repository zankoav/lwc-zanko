global class CreditreformReportScheduleLU implements Schedulable {
	// Once in an hour 
    // 00 01 8,10,12,14,16,18,20,22,00 ? * MON-FRI
    global void execute(SchedulableContext sc) {
        CreditreformReportBatchLU reportBatch = new CreditreformReportBatchLU();
        Database.executeBatch(reportBatch, 1);
    }
}