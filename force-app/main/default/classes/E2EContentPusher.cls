global class E2EContentPusher implements Schedulable {
    global void execute(SchedulableContext sc) {
    	Database.executeBatch(new E2EContentPusherBatch());
    }
}