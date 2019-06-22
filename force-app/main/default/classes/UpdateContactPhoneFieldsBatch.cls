global class UpdateContactPhoneFieldsBatch implements Database.Batchable<sObject> {
    public String query;

    global UpdateContactPhoneFieldsBatch() {
        this.query = 'SELECT Phone, MobilePhone, Fax, MailingCountryCode ' +
                    'FROM Contact ' +
                    'WHERE MailingCountryCode != null AND ' +
                        '(Phone != null OR MobilePhone != null OR Fax != null)';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Sobject> scope) {
        List<Contact> contactsToUpdateList = new List<Contact>();
        for (SObject sobj : scope) {
            Contact contact = (Contact)sobj;
            if (contact.Phone != null) {
                contact.Phone = ClickToCallHandler.returnValidNumber(contact.Phone, contact.MailingCountryCode);
            }
            if (contact.MobilePhone != null) {
                contact.MobilePhone = ClickToCallHandler.returnValidNumber(contact.MobilePhone, contact.MailingCountryCode);
            }
            if (contact.Fax != null) {
                contact.Fax = ClickToCallHandler.returnValidNumber(contact.Fax, contact.MailingCountryCode);
            }
            contactsToUpdateList.add(contact);
        }
        if ( ! contactsToUpdateList.isEmpty()) {
            update contactsToUpdateList;
        }
    }

    global void finish(Database.BatchableContext BC) {

    }
}