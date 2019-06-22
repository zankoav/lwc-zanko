global class UpdateTaskPhoneFieldsBatch implements Database.Batchable<sObject> {
    public String query;

    global UpdateTaskPhoneFieldsBatch() {
        this.query = 'SELECT NVMContactWorld__ContactWorld_Number__c, NVMContactWorld__Customer_Number__c, WhatId, WhoId ' + 
                    'FROM Task ' + 
                    'WHERE (WhatId != null OR WhoId != null) AND ' + 
                        '(NVMContactWorld__ContactWorld_Number__c != null OR NVMContactWorld__Customer_Number__c != null)';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Sobject> scope) {
        Set<Id> leadIdsSet = new Set<Id>();
        Set<Id> contactIdsSet = new Set<Id>();
        Set<Id> opportunityIdsSet = new Set<Id>();
        Set<Id> accountIdsSet = new Set<Id>();

        for (SObject sobj : scope) {
            Task task = (task)sobj;

            if (task.WhoId != null && String.valueOf(task.WhoId).substring(0, 3) == '00Q') {
                leadIdsSet.add(task.WhoId);
            } else if (task.WhoId != null && String.valueOf(task.WhoId).substring(0, 3) == '003') {
                contactIdsSet.add(task.WhoId);
            }

            if (task.WhoId == null && task.WhatId != null && String.valueOf(task.WhatId).substring(0, 3) == '006') {
                opportunityIdsSet.add(task.WhatId);
            } else if (task.WhoId == null && task.WhatId != null && String.valueOf(task.WhatId).substring(0, 3) == '001') {
                accountIdsSet.add(task.WhatId);
            }
        }

        if ( ! leadIdsSet.isEmpty()) {
            Map<Id, Lead> idToLeadMap = new Map<Id, Lead>([
                    SELECT Id, CountryCode
                    FROM Lead 
                    WHERE Id IN :leadIdsSet AND 
                        CountryCode != null
                    LIMIT 50000]);

            List<Task> taskWithLeadsToUpdateList = [
                    SELECT NVMContactWorld__ContactWorld_Number__c, NVMContactWorld__Customer_Number__c, WhoId
                    FROM Task 
                    WHERE WhoId IN :leadIdsSet
                    LIMIT 50000];

            if ( ! taskWithLeadsToUpdateList.isEmpty() && ! idToLeadMap.isEmpty()) {
                for (Task task : taskWithLeadsToUpdateList) {
                    if (task.NVMContactWorld__ContactWorld_Number__c != null) {
                        task.NVMContactWorld__ContactWorld_Number__c = ClickToCallHandler.returnValidNumber(task.NVMContactWorld__ContactWorld_Number__c, idToLeadMap.get(task.WhoId).CountryCode);
                    }
                    if (task.NVMContactWorld__Customer_Number__c != null) {
                        task.NVMContactWorld__Customer_Number__c = ClickToCallHandler.returnValidNumber(task.NVMContactWorld__Customer_Number__c, idToLeadMap.get(task.WhoId).CountryCode);
                    }
                }
                update taskWithLeadsToUpdateList;
            }
        }

        if ( ! contactIdsSet.isEmpty()) {
            Map<Id, Contact> idToContactMap = new Map<Id, Contact>([
                    SELECT Id, MailingCountryCode
                    FROM Contact 
                    WHERE Id IN :contactIdsSet AND 
                        MailingCountryCode != null
                    LIMIT 50000]);

            List<Task> taskWithContactsToUpdateList = [
                    SELECT NVMContactWorld__ContactWorld_Number__c, NVMContactWorld__Customer_Number__c, WhoId
                    FROM Task 
                    WHERE WhoId IN :contactIdsSet
                    LIMIT 50000];

            if ( ! taskWithContactsToUpdateList.isEmpty() && ! idToContactMap.isEmpty()) {
                for (Task task : taskWithContactsToUpdateList) {
                    if (task.NVMContactWorld__ContactWorld_Number__c != null) {
                        task.NVMContactWorld__ContactWorld_Number__c = ClickToCallHandler.returnValidNumber(task.NVMContactWorld__ContactWorld_Number__c, idToContactMap.get(task.WhoId).MailingCountryCode);
                    }
                    if (task.NVMContactWorld__Customer_Number__c != null) {
                        task.NVMContactWorld__Customer_Number__c = ClickToCallHandler.returnValidNumber(task.NVMContactWorld__Customer_Number__c, idToContactMap.get(task.WhoId).MailingCountryCode);
                    }
                }
                update taskWithContactsToUpdateList;
            }
        }

        if ( ! opportunityIdsSet.isEmpty()) {
            Map<Id, Opportunity> idToOpptyMap = new Map<Id, Opportunity>([
                    SELECT Id, Account.BillingCountryCode
                    FROM Opportunity 
                    WHERE Id IN :opportunityIdsSet AND 
                        Account.BillingCountryCode != null
                    LIMIT 50000]);

            List<Task> taskWithOpportunitiesToUpdateList = [
                    SELECT NVMContactWorld__ContactWorld_Number__c, NVMContactWorld__Customer_Number__c, WhatId
                    FROM Task 
                    WHERE WhatId IN :opportunityIdsSet
                    LIMIT 50000];

            if ( ! taskWithOpportunitiesToUpdateList.isEmpty() && ! idToOpptyMap.isEmpty()) {
                for (Task task : taskWithOpportunitiesToUpdateList) {
                    if (task.NVMContactWorld__ContactWorld_Number__c != null) {
                        task.NVMContactWorld__ContactWorld_Number__c = ClickToCallHandler.returnValidNumber(task.NVMContactWorld__ContactWorld_Number__c, idToOpptyMap.get(task.WhatId).Account.BillingCountryCode);
                    }
                    if (task.NVMContactWorld__Customer_Number__c != null) {
                        task.NVMContactWorld__Customer_Number__c = ClickToCallHandler.returnValidNumber(task.NVMContactWorld__Customer_Number__c, idToOpptyMap.get(task.WhatId).Account.BillingCountryCode);
                    }
                }
                update taskWithOpportunitiesToUpdateList;
            }
        }

        if ( ! accountIdsSet.isEmpty()) {
            Map<Id, Account> idToAccountMap = new Map<Id, Account>([
                    SELECT Id, BillingCountryCode
                    FROM Account 
                    WHERE Id IN :accountIdsSet AND 
                        BillingCountryCode != null
                    LIMIT 50000]);

            List<Task> taskWithAccountToUpdateList = [
                    SELECT NVMContactWorld__ContactWorld_Number__c, NVMContactWorld__Customer_Number__c, WhatId
                    FROM Task 
                    WHERE WhatId IN :accountIdsSet
                    LIMIT 50000];

            if ( ! taskWithAccountToUpdateList.isEmpty() && ! idToAccountMap.isEmpty()) {
                for (Task task : taskWithAccountToUpdateList) {
                    if (task.NVMContactWorld__ContactWorld_Number__c != null) {
                        task.NVMContactWorld__ContactWorld_Number__c = ClickToCallHandler.returnValidNumber(task.NVMContactWorld__ContactWorld_Number__c, idToAccountMap.get(task.WhatId).BillingCountryCode);
                    }
                    if (task.NVMContactWorld__Customer_Number__c != null) {
                        task.NVMContactWorld__Customer_Number__c = ClickToCallHandler.returnValidNumber(task.NVMContactWorld__Customer_Number__c, idToAccountMap.get(task.WhatId).BillingCountryCode);
                    }
                }
                update taskWithAccountToUpdateList;
            }
        }
    }

    global void finish(Database.BatchableContext BC) {

    }
}