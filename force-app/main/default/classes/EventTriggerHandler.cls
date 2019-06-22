public class EventTriggerHandler {
    public static Boolean enablesTrigger = true;
    public static Boolean enablesCheckAttachmentExist = true;

    /*******************************************************************************
    *  Name            : connectEventsWithContacts()
    *  Summary         : connect Event with Contact from Retailer Account after insert
    *  CreatedDate     : 27/07/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public static void connectEventsWithContacts(Map<Id, Event> oldEventsMap, List<Event> newEventsList) {
        Set<Id> accountsIdsSet = new Set<Id>();

        if (oldEventsMap == null) {
            // BEFORE INSERT
            for (Event event : newEventsList) {
                if (event.WhatId != null && event.Visit_Done__c == true) {
                    String whatId = event.WhatId;
                    if (whatId.subString(0,3) == '001') {
                        accountsIdsSet.add(event.WhatId);
                    }
                }
            }
        } else {
            // BEFORE UPDATE
            for (Event event : newEventsList) {
                if (event.WhatId != null && event.Visit_Done__c == true && oldEventsMap.get(event.Id).Visit_Done__c == false) {
                    String whatId = event.WhatId;
                    if (whatId.subString(0,3) == '001') {
                        accountsIdsSet.add(event.WhatId);
                    }
                }
            }
        }

        if ( ! accountsIdsSet.isEmpty() ) {
            Map<Id, Account> accountsMap = new Map<Id, Account>([
                    SELECT Email_retailer__c,
                           (SELECT Email FROM Contacts)
                    FROM Account
                    WHERE Id IN :accountsIdsSet
                    LIMIT 10000]);

            for (Event event : newEventsList) {
                if (accountsMap.containsKey(event.WhatId)) {
                    for (Contact contact : accountsMap.get(event.WhatId).Contacts) {
                        if (contact.Email == accountsMap.get(event.WhatId).Email_retailer__c) {
                            event.WhoId = contact.Id;
                            break;
                        }
                    }
                }
            }
        }
    }

    /*******************************************************************************
   *  Name            : checkAttachmentExist(List<Task> oldTasks, List<Task> newTasks)
   *  Summary         : update field task.Is_Exist_Attachment__c if exist any attachment in task
   *  CreatedDate     : 14/12/2017
   *  Parameters      : -
   *  Returns         : void
   ******************************************************************************/
    public static void checkAttachmentExist(List<Event> newEvents) {
        List<RecordType> russianRecordType = [
                SELECT id, name
                FROM RecordType
                WHERE SobjectType = 'Event' and name ='Russian Sales Event'];
        if(russianRecordType.size() != 0){
            Set<ID> russianEventIds = new Set<ID>();
            for (Event event : newEvents) {
                if (russianRecordType.get(0).id == event.RecordTypeId &&
                        (event.Event_Status__c == null || event.Event_Status__c == 'In Progress') ) {
                    russianEventIds.add(event.ID);
                }
            }
            if (russianEventIds.size() != 0) {
                List<Event> eventsWithAttachment = [
                        SELECT id, (SELECT id FROM Attachments)
                        FROM Event
                        WHERE ID IN :russianEventIds
                ];
                for (Event event : eventsWithAttachment) {
                    if (event.Attachments.size() != 0) {
                        event.Attachments_Exist__c = true;
                    } else {
                        event.Attachments_Exist__c = false;
                    }
                }
                enablesCheckAttachmentExist = false;
                update eventsWithAttachment;
            }
        }
    }
}