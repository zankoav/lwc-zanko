global class EmarsysRusReactionLogsSchedule implements Schedulable {

    /*******************************************************************************
    *  Name            : execute(Schedulable sc)
    *  Summary         : execute batch for creating Russian Logs
    *  CreatedDate     : 12/10/2017
    *  Parameters      : Schedulable sc - object to track the schedulable job
    *  Returns         : void
    ******************************************************************************/
    global void execute(SchedulableContext sc){
            EmarsysRusReactionLogsBatch batch = new EmarsysRusReactionLogsBatch();
            Database.executeBatch(batch, 1000);
    }
}