public with sharing class AgfWorkCustomTriggerHandler {

    /*******************************************************************************
    *  Name            : createDefaultTasks(List<agf__ADM_Work__c> listWork)
    *  Summary         : create default task for every "User Story" work
    *  CreatedDate     : 18/12/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public static void createDefaultTasks(List<agf__ADM_Work__c> listWork) {
        Set<Id> userStoryRecordType = new Set<Id>();
        if (Schema.SObjectType.agf__ADM_Work__c.getRecordTypeInfosByName().get('User Story') != null) {
            userStoryRecordType.add(Schema.SobjectType.agf__ADM_Work__c.getRecordTypeInfosByName().get('User Story').getRecordTypeId());
        }

        for (agf__ADM_Work__c work : listWork) {
            if (userStoryRecordType.contains(work.RecordTypeId)) {
                Id ownerOfTasks;
                if (work.agf__Assignee__c != null) {
                    ownerOfTasks = work.agf__Assignee__c;
                } else {
                    ownerOfTasks = work.CreatedById;
                }
                List<agf__ADM_Task__c> newTasks = new List<agf__ADM_Task__c>();
                newTasks.add(new agf__ADM_Task__c(agf__Assigned_To__c = ownerOfTasks,
                        agf__Hours_Remaining__c = 0,
                        agf__Starting_Hours__c = 0,
                        agf__Status__c = 'Not Started',
                        agf__Subject__c = 'Investigation \n' + '(Planned "0" h) -> (Actual "0" h)',
                        agf__Work__c = work.id));
                newTasks.add(new agf__ADM_Task__c(agf__Assigned_To__c = ownerOfTasks,
                        agf__Hours_Remaining__c = 0,
                        agf__Starting_Hours__c = 0,
                        agf__Status__c = 'Not Started',
                        agf__Subject__c = 'Development \n' + '(Planned "0" h) -> (Actual "0" h)',
                        agf__Work__c = work.id));
                newTasks.add(new agf__ADM_Task__c(agf__Assigned_To__c = ownerOfTasks,
                        agf__Hours_Remaining__c = 0,
                        agf__Starting_Hours__c = 0,
                        agf__Status__c = 'Not Started',
                        agf__Subject__c = 'Unit Test \n' + '(Planned "0" h) -> (Actual "0" h)',
                        agf__Work__c = work.id));
                newTasks.add(new agf__ADM_Task__c(agf__Assigned_To__c = ownerOfTasks,
                        agf__Hours_Remaining__c = 1,
                        agf__Starting_Hours__c = 0,
                        agf__Status__c = 'Not Started',
                        agf__Subject__c = 'Roll out full sandbox \n' + '(Planned "1" h) -> (Actual "0" h)',
                        agf__Work__c = work.id));
                newTasks.add(new agf__ADM_Task__c(agf__Assigned_To__c = ownerOfTasks,
                        agf__Hours_Remaining__c = 0,
                        agf__Starting_Hours__c = 0,
                        agf__Status__c = 'Not Started',
                        agf__Subject__c = 'Code review \n' + '(Planned "0" h) -> (Actual "0" h)',
                        agf__Work__c = work.id));
                insert newTasks;
            }
        }
    }

    /*******************************************************************************
    *  Name            : updateOwnerOfTask(Map<Id, agf__ADM_Work__c> oldMap, Map<Id, agf__ADM_Work__c> newMap)
    *  Summary         : change owner of task, when owner of work(New,Triaged) is changed
    *  CreatedDate     : 18/12/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public static void updateOwnerOfTask(Map<Id, agf__ADM_Work__c> oldMap, Map<Id, agf__ADM_Work__c> newMap) {
        Set<Id> userStoryRecordType = new Set<Id>();
        if (Schema.SObjectType.agf__ADM_Work__c.getRecordTypeInfosByName().get('User Story') != null) {
            userStoryRecordType.add(Schema.SobjectType.agf__ADM_Work__c.getRecordTypeInfosByName().get('User Story').getRecordTypeId());
        }

        Map<Id, agf__ADM_Work__c> workToUpdate = new Map<Id, agf__ADM_Work__c>();
        for (agf__ADM_Work__c newWork : newMap.values()) {
            agf__ADM_Work__c oldWork = oldMap.get(newWork.id);
            if ((oldWork.agf__Assignee__c != newWork.agf__Assignee__c) &&
                    (newWork.agf__Status__c == 'New' || newWork.agf__Status__c == 'Triaged') &&
                    (userStoryRecordType.contains(newWork.RecordTypeId))) {
                workToUpdate.put(newWork.id, newWork);
            }
        }

        if (workToUpdate.size() != 0) {
            List<agf__ADM_Task__c> allTasksInWorks = [
                    SELECT id, agf__Assigned_To__c,agf__Work__c
                    FROM agf__ADM_Task__c
                    WHERE agf__Work__c = :workToUpdate.keySet()
            ];
            for (agf__ADM_Task__c task : allTasksInWorks) {
                if (workToUpdate.containsKey(task.agf__Work__c)) {
                    task.agf__Assigned_To__c = workToUpdate.get(task.agf__Work__c).agf__Assignee__c;
                }
            }
            update allTasksInWorks;
        }
    }

    /*******************************************************************************
    *  Name            : updateWorkEstimateEndDate
    *  Summary         : update field 'Work_End_Date__c' on work by parse description field
    *  CreatedDate     : 26/03/2018
    *  Parameters      : (List<agf__ADM_Work__c> newList)
    *  Returns         : void
    ******************************************************************************/
    public static void updateWorkEstimateEndDate(List<agf__ADM_Work__c> newList) {
        String currentDate = system.now().format('dd/MM/yyyy');
        for(agf__ADM_Work__c work : newList){
            if(work.agf__Details__c != null){
                if( !work.agf__Details__c.contains('Предполагаемая дата завершения задачи') ){
                    work.agf__Details__c =  '*** Предполагаемая дата завершения задачи = "' + currentDate + '" ***\n' + work.agf__Details__c;
                }
            }
            else {
                work.agf__Details__c = '*** Предполагаемая дата завершения задачи = "' + currentDate + '" ***\n';
            }
            work.Work_End_Date__c = (work.agf__Details__c.substringAfter('*** Предполагаемая дата завершения задачи = "')).substringBefore('"').left(10);
        }
    }
}