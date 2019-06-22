@IsTest
private class AgfThemeAssignmentTriggerHandlerTest {

    static testMethod void testBehavior() {

        Id recordTypeUserStory = Schema.SobjectType.agf__ADM_Work__c.getRecordTypeInfosByName().get('User Story').getRecordTypeId() ;

        agf__ADM_Work__c testWork = new agf__ADM_Work__c(RecordTypeId = recordTypeUserStory);
        insert testWork;

        agf__ADM_Theme__c testTheme = new agf__ADM_Theme__c();
        testTheme.Name='newtestnamefortheme';
        insert testTheme;

        agf__ADM_Theme_Assignment__c newThemeAssignment = new agf__ADM_Theme_Assignment__c();
        newThemeAssignment.agf__Work__c =  testWork.id;
        newThemeAssignment.agf__Theme__c = testTheme.id;
        insert newThemeAssignment;

        List<agf__ADM_Work__c> testlist = [SELECT id,ThemesAll__C from agf__ADM_Work__c where id=:testWork.id];

        system.assertEquals(testlist.get(0).ThemesAll__c,'newtestnamefortheme');
    }

    static testMethod void testBehavior2() {

        Id recordTypeUserStory = Schema.SobjectType.agf__ADM_Work__c.getRecordTypeInfosByName().get('User Story').getRecordTypeId() ;

        agf__ADM_Work__c testWork = new agf__ADM_Work__c(RecordTypeId = recordTypeUserStory);
        insert testWork;

        agf__ADM_Theme__c testTheme = new agf__ADM_Theme__c();
        testTheme.Name='newtestnamefortheme';
        insert testTheme;

        agf__ADM_Theme_Assignment__c newThemeAssignment = new agf__ADM_Theme_Assignment__c();
        newThemeAssignment.agf__Work__c =  testWork.id;
        newThemeAssignment.agf__Theme__c = testTheme.id;
        insert newThemeAssignment;

        delete newThemeAssignment;

        List<agf__ADM_Work__c> testlist = [SELECT id,ThemesAll__C from agf__ADM_Work__c where id=:testWork.id];

        system.assertEquals(testlist.get(0).ThemesAll__c,null);
    }

}