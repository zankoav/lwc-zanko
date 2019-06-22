global class EmarsysRusReactionLogsCheckSchedule implements Schedulable {


    /*******************************************************************************
    *  Name            : execute(SchedulableContext sc)
    *  Summary         : run job for check errors in EmarsysRusReactionLogsCheckSchedule
    *  CreatedDate     : 27/10/2017
    *  Parameters      : Schedulable sc - object to track the schedulable job
    *  Returns         : void
    ******************************************************************************/
    global void execute(SchedulableContext sc) {
        List<CronTrigger> jobsList = [
                SELECT Id
                FROM CronTrigger
                WHERE CronJobDetail.Name LIKE 'Emarsys Reaction Logs%' AND StartTime > :Datetime.now().addMinutes(-10)
                LIMIT 100];
        if (jobsList.isEmpty()) {
            String schedule = datetime.now().addMinutes(1).second() + ' ' + datetime.now().addMinutes(1).minute() + ' 6-18' + ' ?'
                    + ' *' + ' MON-FRI';
            EmarsysRusReactionLogsSchedule scheduledCreatingLogs = new EmarsysRusReactionLogsSchedule();
            System.schedule('Emarsys Reaction Logs ' + datetime.now().addMinutes(1).minute(), schedule, scheduledCreatingLogs);
        }
    }
}