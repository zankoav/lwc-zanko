@isTest
private class ContactTriggerHandlerTest {
    @isTest
    private static void testCreateContactRoleInOpportunities(){
        String recordTypeAcc = GlobalUtils.returnRecordTypeId('Account','Russian');
        Account testAccount = new Account(Name = 'testoppo1', RecordTypeId = recordTypeAcc);
        insert testAccount;

        String RecordTypeOpp = GlobalUtils.returnRecordTypeId('Opportunity','Russian Sales');
        Opportunity testOpportunity = new Opportunity();
        testOpportunity.Name = 'TESTOPPORTUNITIES';
        testOpportunity.Account = [SELECT Id, Name FROM Account WHERE Id =: testAccount.Id LIMIT 1];
        testOpportunity.Number_of_Vehicles__c = 1;
        testOpportunity.StageName = 'Qualified Lead';
        testOpportunity.CloseDate = Date.newInstance(2018, 01, 15);
        testOpportunity.Most_Important_Feature__c = 'Reporting';
        testOpportunity.Area_Traveled__c = 'Regional';
        testOpportunity.The_region__c = 'г. Санкт-Петербург';
        testOpportunity.Travel_Pattern__c = 'Regular Route';
        testOpportunity.Primary_Fueling_Method__c = 'Coupons';
        testOpportunity.PPR_First_Contact_Inbound_Outbound__c = 'Inbound call';
        testOpportunity.Source_of_Lead_o__c = 'Выставка';
        testOpportunity.RecordTypeId = RecordTypeOpp;
        insert testOpportunity;

        String recordTypeCon = GlobalUtils.returnRecordTypeId('Contact','Russian');
        Contact testContact = new Contact(LastName='Chang', RecordTypeId = recordTypeCon, Salutation='Mr.');
        insert testContact;
        update testContact;

        List<OpportunityContactRole> rolesList = [SELECT OpportunityId FROM OpportunityContactRole WHERE OpportunityId =: testOpportunity.Id];
        System.assertEquals(1, rolesList.size());
    }

    /*******************************************************************************
    *  Name            : testsetFive9Phone()
    *  Summary         : Testing setFive9Phone() before update and before insert    
    *  CreatedDate     : 01/04/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    private static void testsetFive9Phone() {
        List<Contact> contactsToInsertList = new List<Contact>();

        Contact contactGermany = new Contact(
            Phone = '0049 111 22 33',
            MobilePhone = '0112/33(0)2',
            Fax = '282245167',
            MailingCountry = 'Germany',
            MailingCountryCode = 'DE',
            LastName = 'test', 
            Salutation = 'Herr');
        contactsToInsertList.add(contactGermany);
        insert contactsToInsertList;

        Set<Id> idsToTest = new Set<Id>();
        for (Contact currentCon : contactsToInsertList) {
            idsToTest.add(currentCon.Id);
        }

        Map<Id, Contact> contactsToTestMap = new Map<Id, Contact>([
                SELECT Phone, MobilePhone, Fax, MailingCountry
                FROM Contact
                WHERE Id IN :idsToTest
                LIMIT 10000]);

        // Germany
        System.assertEquals('+491112233', contactsToTestMap.get(contactGermany.Id).Phone);
        System.assertEquals('+491123302', contactsToTestMap.get(contactGermany.Id).MobilePhone);
        System.assertEquals('+49282245167', contactsToTestMap.get(contactGermany.Id).Fax);
    }
}