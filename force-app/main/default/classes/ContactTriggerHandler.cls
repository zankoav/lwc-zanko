public class ContactTriggerHandler {
    public static Boolean enablesTrigger = true;
    public static Boolean isExecuting = false;
    public static Boolean isE2EForm = false;

    public static void setRecordType(List<Contact> newList) {
        List<RecordType> recordTypesList = [
                SELECT Name
                FROM RecordType
                WHERE (Name = 'AllStar' OR Name = 'Russian') AND
                      sObjectType = 'Contact'
                LIMIT 100];
        Map<String, RecordType> recordTypesMap = new Map<String, RecordType>();
        for (RecordType rt : recordTypesList) {
            recordTypesMap.put(rt.Name, rt);
        }

        if ( ! recordTypesMap.isEmpty() ) {
            for (Contact contact : newList) {
                if (contact.Lead_Record_Type__c == 'AllStar' && recordTypesMap.containsKey('AllStar')) {
                    contact.RecordTypeId = recordTypesMap.get('AllStar').Id;
                } else if (contact.Lead_Record_Type__c == 'Russian Sales' && recordTypesMap.containsKey('Russian')) {
                    contact.RecordTypeId = recordTypesMap.get('Russian').Id;
                }
            }
        }
    }


    /*******************************************************************************
    *  Name            : updatePrimaryContactPhone(Map<Id, Contact> oldMap, Map<Id, Contact> newMap)
    *  Summary         : update Primary_Contact_Phone__c in Opportunity if phone is changed and
                         this contact is used as primary contact role in opportunity
    *  CreatedDate     : 11/12/2017
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public static void updatePrimaryContactPhone(Map<Id, Contact> oldMap, Map<Id, Contact> newMap) {
        Map<String, Contact> changedContactsMap = new Map<String, Contact>();
        for (Contact contact : newMap.values()) {
            if (contact.Phone != oldMap.get(contact.Id).Phone) {
                changedContactsMap.put(contact.Id, contact);
            }
        }

        if (! changedContactsMap.isEmpty()) {
            List<OpportunityContactRole> primaryContactRolesList = [
                SELECT OpportunityId, ContactId, IsPrimary
                FROM OpportunityContactRole
                WHERE ContactId IN :changedContactsMap.keySet() AND
                    IsPrimary = TRUE AND
                    OpportunityId != null
                LIMIT 50000
            ];

            if (! primaryContactRolesList.isEmpty()) {
                Set<String> opptyIdsSet = new Set<String>();
                for (OpportunityContactRole ocr : primaryContactRolesList) {
                    opptyIdsSet.add(ocr.OpportunityId);
                }

                Map<String, Opportunity> opptiesToUpdateMap = new Map<String, Opportunity>([
                    SELECT Primary_Contact_Phone__c
                    FROM Opportunity
                    WHERE Id IN :opptyIdsSet
                    LIMIT 50000
                ]);

                for (OpportunityContactRole ocr : primaryContactRolesList) {
                    opptiesToUpdateMap.get(ocr.OpportunityId).Primary_Contact_Phone__c = changedContactsMap.get(ocr.ContactId).Phone;
                }
                update opptiesToUpdateMap.values();
            }
        }
    }

    /*******************************************************************************
    *  Name            : createContactRoleInOpportunities()
    *  Summary         : create OpportunityContactRole after new Contact created for Account
    *  CreatedDate     : 18.01.2018
    *  Parameters      : List<Contact> newContactsList
    *  Returns         : void
    ******************************************************************************/
    public static void createContactRoleInOpportunities(List<Contact> newContactsList){
        String recordContactTypeId = [
                SELECT Id
                From RecordType
                Where Name = 'Russian'
                AND SobjectType = 'Contact'].Id;

        if( ContactTriggerHandler.isExecuting ){
            return;
        }

        ContactTriggerHandler.isExecuting = true;

        Set<Id> accountIds = new Set<Id>();
        for(Contact con : newContactsList){
            accountIds.add(con.AccountId);
        }

        List<Opportunity> opportunities = new List<Opportunity>();
        opportunities = [SELECT Id, AccountId FROM Opportunity WHERE AccountId IN: accountIds ORDER BY CreatedDate LIMIT 5000];

        Map<Id,List<Opportunity>> opportunitiesByAccount = new Map<ID,List<Opportunity>>();
        for(Opportunity o : opportunities){
            if(!opportunitiesByAccount.containsKey(o.AccountId)){
                opportunitiesByAccount.put(o.AccountId,new List<Opportunity>());
            }
            opportunitiesByAccount.get(o.AccountId).add(o);
        }

        List<OpportunityContactRole> opportunityContactRoles = new List<OpportunityContactRole>();
        for(Contact con : newContactsList){
            if(opportunitiesByAccount.containsKey(con.AccountId) && con.RecordTypeId == recordContactTypeId){
                for(Opportunity opt : opportunitiesByAccount.get(con.AccountId)){
                    OpportunityContactRole ocr = new OpportunityContactRole(OpportunityId = opt.Id, ContactId = con.Id);
                    opportunityContactRoles.add(ocr);
                }
            }
        }
        insert opportunityContactRoles;
    }


    /*******************************************************************************
    *  Name            : setFive9Phone(Map<Id, Contact> oldMap, List<Contact> newList)
    *  Summary         : Set Phone in E.164 format
    *  CreatedDate     : 30/03/2018
    *  ModifiedDate    : 30/03/2018
    *  Parameters      : oldMap, newMap – maps from the trigger
    *  Returns         : void
    ******************************************************************************/
    public static void setValidPhone(Map<Id, Contact> oldMap, List<Contact> newList) {
        for (Contact contact : newList) {
            if (contact.MailingCountryCode != null) {
                if (oldMap != null) {
                    // before update
                    if (contact.Phone != null && oldMap.get(contact.Id).Phone != contact.Phone) {
                        contact.Phone = ClickToCallHandler.returnValidNumber(contact.Phone, contact.MailingCountryCode);
                    }
                    if (contact.MobilePhone != null && oldMap.get(contact.Id).MobilePhone != contact.MobilePhone) {
                        contact.MobilePhone = ClickToCallHandler.returnValidNumber(contact.MobilePhone, contact.MailingCountryCode);
                    }
                    if (contact.Fax != null && oldMap.get(contact.Id).Fax != contact.Fax) {
                        contact.Fax = ClickToCallHandler.returnValidNumber(contact.Fax, contact.MailingCountryCode);
                    }
                }
                if (OldMap == null) {
                    // before insert
                    if (contact.Phone != null) {
                        contact.Phone = ClickToCallHandler.returnValidNumber(contact.Phone, contact.MailingCountryCode);
                    }
                    if (contact.MobilePhone != null) {
                        contact.MobilePhone = ClickToCallHandler.returnValidNumber(contact.MobilePhone, contact.MailingCountryCode);
                    }
                    if (contact.Fax != null) {
                        contact.Fax = ClickToCallHandler.returnValidNumber(contact.Fax, contact.MailingCountryCode);
                    }
                }
            }
        }
    }
}