@IsTest private class AgfWorkCustomTriggerHandlerTest {

    static testMethod void createNewTasksTest() {
        Id recordTypeUserStory = Schema.SobjectType.agf__ADM_Work__c.getRecordTypeInfosByName().get('User Story').getRecordTypeId() ;

        agf__ADM_Work__c testWork = new agf__ADM_Work__c(RecordTypeId = recordTypeUserStory);
        insert testWork;

        List<agf__ADM_Task__c> testWorkTasks = [
                SELECT id,name
                FROM agf__ADM_Task__c
                WHERE agf__Work__c = :testWork.id
        ];

        system.assertEquals(testWorkTasks.size(), 5);
    }

    static testMethod void updateOwnerOfTaskTest() {
        Profile p = [
                SELECT Id
                FROM Profile
                WHERE Name = 'System Administrator'
        ];

        User user = new User(
                Username = 'usertest@fleetcor.de',
                ProfileId = p.Id,
                Alias = 'uset@fl',
                Email = 'usertest@fleetcor.de',
                EmailEncodingKey = 'UTF-8',
                Lastname = 'usertest',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago');
        insert user;

        Id recordTypeUserStory = Schema.SobjectType.agf__ADM_Work__c.getRecordTypeInfosByName().get('User Story').getRecordTypeId() ;

        agf__ADM_Work__c testWork = new agf__ADM_Work__c(RecordTypeId = recordTypeUserStory);
        insert testWork;

        testWork.agf__Assignee__c = user.id;
        update testWork;

        List<agf__ADM_Task__c> testWorkTasks = [
                SELECT id,name,agf__Assigned_To__c
                FROM agf__ADM_Task__c
                WHERE agf__Work__c = :testWork.id
        ];

        system.assertEquals(testWorkTasks.get(0).agf__Assigned_To__c, user.id);
    }

    static testMethod void updateWorkEstimateEndDateTest() {
        Id recordTypeUserStory = Schema.SobjectType.agf__ADM_Work__c.getRecordTypeInfosByName().get('User Story').getRecordTypeId() ;

        agf__ADM_Work__c testWork = new agf__ADM_Work__c(RecordTypeId = recordTypeUserStory);
        insert testWork;

        List<agf__ADM_Work__c> testList1 = [
                SELECT id, Work_End_Date__c
                FROM agf__ADM_Work__c
                WHERE Id = :testWork.iD
        ];

        system.assertEquals(testList1.get(0).Work_End_Date__c, system.now().format('dd/MM/yyyy'));

        testWork.agf__Details__c = '*** Предполагаемая дата завершения задачи = "28/03/2018" ***';
        update testWork;

        List<agf__ADM_Work__c> testList2 = [
                SELECT id, Work_End_Date__c
                FROM agf__ADM_Work__c
                WHERE Id = :testWork.iD
        ];

        system.assertEquals(testList2.get(0).Work_End_Date__c, '28/03/2018');
    }

}