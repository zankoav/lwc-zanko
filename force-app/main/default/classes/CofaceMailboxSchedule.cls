global class CofaceMailboxSchedule implements Schedulable {
	// Once in an hours
    global void execute(SchedulableContext sc) {
        CofaceMailboxBatch mailboxBatch = new CofaceMailboxBatch();
        Database.executeBatch(mailboxBatch, 1);
    }
}