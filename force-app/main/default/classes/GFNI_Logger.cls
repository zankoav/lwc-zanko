/**
 * Created by Nikita.Mikhailov on 18.01.2019.
 *
 * Class to create and store logs in scope of GFN Integration project
 * All logs saves to BigObject GFNI_Opportunity_log__b
 *
 * Have a static workaround to save List<GFNI_Logger>
 */
public with sharing class GFNI_Logger {

    public List<GFNI_Opportunity_log__b> logs { get; set; }
    public Id opportunityId { get; set; }
    public Boolean isFirst { get; set; }

    public GFNI_Logger(Id opportunityId, Boolean isFirst) {
        this.opportunityId = opportunityId;
        this.isFirst = isFirst;
    }

    /*******************************************************************************
    *  Name            : addLog
    *  Summary         : adds new log to the logs list
    *  CreatedDate     : 18/01/2019
    *  Parameters      : String logType('Request, Response, Error, Message etc.'), String message, String requestId in request
    *  Returns         : void
    ******************************************************************************/
    public void addLog(String logType, String message, String requestId) {
        if (this.logs == null)
            this.logs = new List<GFNI_Opportunity_log__b>();

        GFNI_Opportunity_log__b log = new GFNI_Opportunity_log__b ();

        log.Request_Id__c = requestId;
        log.RecordDateTime__c = System.now();
        log.LogType__c = logType;
        log.Message__c = message;
        log.Opportunity__c = this.opportunityId;

        if (isFirst) {
            log.IsFirst__c = 1;
            this.isFirst = false;
        } else {
            log.IsFirst__c = 0;
        }

        this.logs.add(log);
    }

    /*******************************************************************************
    *  Name            : saveLogs
    *  Summary         : saves logs to the BigObject GFNI_Opportunity_log__b
    *  CreatedDate     : 18/01/2019
    *  Parameters      : none
    *  Returns         : void
    ******************************************************************************/
    public void saveLogs() {
        if (this.logs.isEmpty())
            return;

        System.enqueueJob(new GFNI_QueueableLogSave(this.logs));
    }

//    /*******************************************************************************
//    *  Name            : debugLogs
//    *  Summary         : prints all existing logs to the console
//    *  CreatedDate     : 18/01/2019
//    *  Parameters      : none
//    *  Returns         : void
//    ******************************************************************************/
//    public void debugLogs() {
//        for (GFNI_Opportunity_log__b log : logs) {
//            System.debug(log);
//        }
//    }

    /*******************************************************************************
    *  Name            : saveLogsList
    *  Summary         : static workaround for saving logs for different objects. Method just moves all logs to one list and saves to the BigObject GFNI_Opportunity_log__b
    *  CreatedDate     : 18/01/2019
    *  Parameters      : List<GFNI_Logger> list of loggers
    *  Returns         : void
    ******************************************************************************/
    public static void saveLogsList(List<GFNI_Logger> logs) {
        List<GFNI_Opportunity_log__b> allLogs = new List<GFNI_Opportunity_log__b>();

        for (GFNI_Logger i : logs) {
            for (GFNI_Opportunity_log__b j : i.logs) {
                allLogs.add(j);
            }
        }

        System.enqueueJob(new GFNI_QueueableLogSave(allLogs));
    }
}