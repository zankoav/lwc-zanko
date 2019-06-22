public class AttachmentTriggerHandler {
    public static Boolean enablesTrigger = true;
    public static Boolean isCreditFactory = false;

    /*******************************************************************************
    *  Name            : creditFactoryDeleteReport(List<Attachment> oldList)
    *  Summary         :  Display error if report has been deleted by non-admin or non-credit user
    *  CreatedDate     : 01/08/2017
    *  Parameters      : oldList - old trigger list of Attachments
    *  Returns         : void
    ******************************************************************************/
    public static void creditFactoryDeleteReport(List<Attachment> oldList) {
        if (isCreditFactory) return;
        Map<Id, Profile> availableProfilesMap = new Map<Id, Profile>([
                SELECT Id
                FROM Profile
                WHERE Name IN :availableProfileNamesSet
        ]);
        for (Attachment attachment : oldList) {
            if (attachment.Name == 'CrefoReport.pdf' || attachment.Name == 'CreditsafeReport.pdf' || attachment.Name == 'CofaceReport.pdf' ||
                    attachment.Name == 'CrifReport.pdf' || attachment.Name == 'CrediconnectReport.pdf') {
                if (! availableProfilesMap.containsKey(UserInfo.getProfileId())) {
                    attachment.addError('Unable to delete CreditFactory report.');
                }
            }
        }
    }

    public static Set<String> availableProfileNamesSet = new Set<String>{
            'System Administrator',
            'E2E Profile',
            'Credit',
            'Administrador del sistema',
            'Administrateur système',
            'Amministratore del sistema',
            'Systemadministratör',
            'Administrador do sistema',
            'Systeembeheerder',
            'Systemadministrator',
            'Järjestelmän pääkäyttäjä',
            'Системный администратор',
            'Správce systému',
            'Administrator systemu',
            'Rendszergazda'
    };

    /*******************************************************************************
*  Name            : updateActivitiesWithAttachmentExist(List<Attachment> oldAttachments, List<Attachment> newAttachments)
*  Summary         : update field  Task.Is_Exist_Attachment__c , "True" if Task had attachment
*  CreatedDate     : 14/12/2017
*  Returns         : void
******************************************************************************/
    public static void updateActivitiesWithAttachmentExist(List<Attachment> oldAttachments, List<Attachment> newAttachments) {
        Set<Id> parentTaskIds = new Set<id>();
        Set<Id> parentEventIds = new Set<id>();
        if (oldAttachments != null) {
            for (Attachment attachment : oldAttachments) {
                if (String.valueOf(attachment.ParentId).startsWith('00T')) {
                    parentTaskIds.add(attachment.parentId);
                }
                if (String.valueOf(attachment.ParentId).startsWith('00U')) {
                    parentEventIds.add(attachment.parentId);
                }
            }
        }
        if (newAttachments != null) {
            for (Attachment attachment : newAttachments) {
                if (String.valueOf(attachment.ParentId).startsWith('00T')) {
                    parentTaskIds.add(attachment.parentId);
                }
                if (String.valueOf(attachment.ParentId).startsWith('00U')) {
                    parentEventIds.add(attachment.parentId);
                }
            }
        }
        if (parentTaskIds.size() != 0) {
            List<Task> parentTaskList = [
                    SELECT id, Attachments_Exist__c, (SELECT id FROM Attachments)
                    FROM Task
                    WHERE id IN :parentTaskIds AND RecordType.Name = 'Russian Sales'
            ];
            if (parentTaskList.size() != 0) {
                List<Task> taskForUpdate = new List<Task>();
                for (Task task : parentTaskList) {
                    if (task.Attachments.size() != 0 && task.Attachments_Exist__c != true) {
                        task.Attachments_Exist__c = true;
                        taskForUpdate.add(task);
                    } else if (task.Attachments.size() == 0 && task.Attachments_Exist__c != false) {
                        task.Attachments_Exist__c = false;
                        taskForUpdate.add(task);
                    }
                }
                if (taskForUpdate.size() != 0) {
                    update taskForUpdate;
                }
            }
        }

        if (parentEventIds.size() != 0) {
            List<Event> parentEventList = [
                    SELECT id, Attachments_Exist__c, (SELECT id FROM Attachments)
                    FROM Event
                    WHERE id IN :parentEventIds
                    AND RecordType.Name = 'Russian Sales Event'
                    AND (Event_Status__c = null OR Event_Status__c = 'In Progress')
            ];
            if (parentEventList.size() != 0) {
                List<Event> eventForUpdate = new List<Event>();
                for (Event event : parentEventList) {
                    if (event.Attachments.size() != 0 && event.Attachments_Exist__c != true) {
                        event.Attachments_Exist__c = true;
                        eventForUpdate.add(event);
                    } else if (event.Attachments.size() == 0 && event.Attachments_Exist__c != false) {
                        event.Attachments_Exist__c = false;
                        eventForUpdate.add(event);
                    }
                }
                if(eventForUpdate.size() != 0){
                    update eventForUpdate;
                }
            }
        }

    }
}