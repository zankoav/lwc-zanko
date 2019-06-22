global class CreditreformMailboxSchedule implements Schedulable {
	// Once in 2 hours
    global void execute(SchedulableContext sc) {
        CreditreformMailboxBatch mailboxBatch = new CreditreformMailboxBatch();
        Database.executeBatch(mailboxBatch, 1);
    }
}