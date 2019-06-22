global class UpdateLeadPhoneFieldsBatch implements Database.Batchable<sObject> {
    public String query;

    global UpdateLeadPhoneFieldsBatch() {
        this.query = 'SELECT Phone, MobilePhone, CountryCode ' +
                    'FROM Lead ' +
                    'WHERE (Phone != null OR MobilePhone != null) AND ' +
                        'CountryCode != null AND ' + 
                        'IsConverted = false';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Sobject> scope) {
        List<Lead> leadsToUpdateList = new List<Lead>();
        for (SObject sobj : scope) {
            Lead lead = (Lead)sobj;
            if (lead.Phone != null) {
                lead.Phone = ClickToCallHandler.returnValidNumber(lead.Phone, lead.CountryCode);
            }
            if (lead.MobilePhone != null) {
                lead.MobilePhone = ClickToCallHandler.returnValidNumber(lead.MobilePhone, lead.CountryCode);
            }
            leadsToUpdateList.add(lead);
        }
        if ( ! leadsToUpdateList.isEmpty()) {
            update leadsToUpdateList;
        }
    }

    global void finish(Database.BatchableContext BC) {

    }
}