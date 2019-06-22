global class UpdateAccountPhoneFieldsBatch implements Database.Batchable<sObject> {
    public String query;

    global UpdateAccountPhoneFieldsBatch() {
        this.query = 'SELECT Fax, Phone, CM_mobile__c, Phone_Crif__c, SM_mobile__c, TM_mobile__c, BillingCountryCode ' +
                    'FROM Account ' + 
                    'WHERE BillingCountryCode != null AND ' + 
                        '(Fax != null OR Phone != null OR CM_mobile__c != null OR Phone_Crif__c != null OR SM_mobile__c != null OR TM_mobile__c != null)';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Sobject> scope) {
        List<Account> accountsToUpdateList = new List<Account>();
        for (SObject sobj : scope) {
            Account account = (Account)sobj;
            if (account.Phone != null) {
                account.Phone = ClickToCallHandler.returnValidNumber(account.Phone, account.BillingCountryCode);
            }
            if (account.Fax != null) {
                account.Fax = ClickToCallHandler.returnValidNumber(account.Fax, account.BillingCountryCode);
            }
            if (account.CM_mobile__c != null) {
                account.CM_mobile__c = ClickToCallHandler.returnValidNumber(account.CM_mobile__c, account.BillingCountryCode);
            }
            if (account.Phone_Crif__c != null) {
                account.Phone_Crif__c = ClickToCallHandler.returnValidNumber(account.Phone_Crif__c, account.BillingCountryCode);
            }
            if (account.SM_mobile__c != null) {
                account.SM_mobile__c = ClickToCallHandler.returnValidNumber(account.SM_mobile__c, account.BillingCountryCode);
            }
            if (account.TM_mobile__c != null) {
                account.TM_mobile__c = ClickToCallHandler.returnValidNumber(account.TM_mobile__c, account.BillingCountryCode);
            }
            accountsToUpdateList.add(account);
        }
        if ( ! accountsToUpdateList.isEmpty()) {
            update accountsToUpdateList;
        }
    }

    global void finish(Database.BatchableContext BC) {

    }
}