@isTest
public class FindDuplicatesRuControllerTest {

    @isTest
    public static void searchTest() {
        String RecordTypeLead = [select id from recordtype where name = 'Russian Sales' and SobjectType = 'Lead'].id;
        String RecordTypeOpp = [select id from recordtype where name = 'Russian Sales' and SobjectType = 'Opportunity'].id;
        String RecordTypeAcc = [select id from recordtype where name = 'Russian' and SobjectType = 'Account'].id;
        String RWL;
        if ([select id from group where name = 'Russian Web Leads'].size() == 1)
            RWL = [select id from group where name = 'Russian Web Leads'].id; else RWL = '0BLANKIDBLANKID';

        Lead lead = new Lead(Phone = '1234567891098754321', LastName = 'test12345678910987654321',
                Company = 'test12345678910987654321', Email = 'Email12345678910@gggmail.ru', Salutation = 'Herr',
                Date_of_First_Contact_Inbound_Outbound__c = date.today(), Country = 'Russia', INN__C = '1234567899999',
                First_Contact_Inbound_Outbound__c = 'Inbound Call', Source_of_lead__c = 'Сайт Petrolplus.ru',
                RecordTypeId = RecordTypeLead, ownerid = RWL);
        insert lead;
        Account accountt = new Account(Name = 'test12345678910987654321', BillingPostalCode = '123', Phone = '1234567891098754321',
                INN__C = '1234567899999',
                RecordTypeId = RecordTypeAcc);
        insert accountt;

        Contact contt = new Contact(LastName = 'testcontact12345',Phone = '1234567890',Email = 'test@testcont.ru',AccountId = accountt.Id);
        insert contt;

        Opportunity opportunity = new Opportunity(Name = 'test12345678910987654321', StageName = 'Prospecting', CloseDate = date.today(),
                AccountId = accountt.id, RecordTypeId = RecordTypeOpp, Starts_Status__c = '0. Request received');
        insert opportunity;

        Ru_Admin_Approver__c approver = new Ru_Admin_Approver__c(Name = 'test@test.com');
        insert approver;
        FindDuplicatesRuController contr = new FindDuplicatesRuController();
        contr.idForRequest = opportunity.Id;
        contr.sendRequestForChangeOwner();

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        FindDuplicatesRuController controller = new FindDuplicatesRuController();
        controller.isINNSelected = true;
        controller.isCompanySelected = true;
        controller.isEmailSelected = true;
        controller.isPhoneSelected = true;
        controller.init();
        controller.searchPage();

        System.assertEquals(controller.matchingAccounts.size(), 1);
        System.assertEquals(controller.matchingOpportunities.size(), 1);

    }
    @isTest
    public static void searchTest2() {
        String RecordTypeLead = [select id from recordtype where name = 'Russian Sales' and SobjectType = 'Lead'].id;
        String RecordTypeOpp = [select id from recordtype where name = 'Russian Sales' and SobjectType = 'Opportunity'].id;
        String RecordTypeAcc = [select id from recordtype where name = 'Russian' and SobjectType = 'Account'].id;

        Lead lead = new Lead(Phone = '1098765432112345678910', LastName = 'pro567verkaAAAAAAA567', Company = 'pro567verkaAAAAAAA567',
                Email = 'mail123456@gmail.com', Salutation = 'Herr', INN__C = '1234567888888',
                Date_of_First_Contact_Inbound_Outbound__c = date.today(), Country = 'Russia',
                First_Contact_Inbound_Outbound__c = 'Inbound Call', Source_of_lead__c = 'Сайт Petrolplus.ru',
                RecordTypeId = RecordTypeLead);
        insert lead;
        Account accountt = new Account(Name = 'pro567verkaAAAAAAA567', BillingPostalCode = '123', Phone = '1098765432112345678910',
                INN__C = '1234567888888',
                RecordTypeiD = RecordTypeAcc);
        insert accountt;
        Opportunity opportunity = new Opportunity(Name = 'pro567verkaAAAAAAA567', StageName = 'Prospecting', CloseDate = date.today(),
                AccountId = accountt.id, Recordtypeid = RecordTypeOpp, Starts_Status__c = '0. Request received');
        insert opportunity;
        Test.startTest();
        Test.stopTest();
        ApexPages.currentPage().getParameters().put('id', lead.Id);
        FindDuplicatesRuController controller = new FindDuplicatesRuController();
        controller.isINNSelected = true;
        controller.isCompanySelected = true;
        controller.isEmailSelected = true;
        controller.isPhoneSelected = true;
        controller.init();
        controller.searchPage();

        System.assertEquals(controller.matchingAccounts.size(), 1);
        System.assertEquals(controller.matchingOpportunities.size(), 1);
    }

    @isTest
    public static void searchTest3() {
        String RecordTypeLead = [select id from recordtype where name = 'Russian Sales' and SobjectType = 'Lead'].id;

        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

        User user = new User(Username = 'usertest@fleetcor.ru', ProfileId = p.Id, Alias = 'uset@fl', Email = 'usertest@fleetcor.ru',
                EmailEncodingKey = 'UTF-8', Lastname = 'usertest', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Chicago');
        insert user;

        Lead lead = new Lead(Phone = '1098765432112345678910', LastName = 'pro567verkaAAAAAAA567', Company = 'pro567verkaAAAAAAA567',
                Email = 'mail123456@gmail.com', Salutation = 'Herr', INN__C = '1234567888888',
                Date_of_First_Contact_Inbound_Outbound__c = date.today(), Country = 'Russia',
                First_Contact_Inbound_Outbound__c = 'Inbound Call', Source_of_lead__c = 'Сайт Petrolplus.ru',
                RecordTypeId = RecordTypeLead, ownerid = user.id);
        insert lead;

        Test.startTest();
        Test.stopTest();

        FindDuplicatesRuController controller = new FindDuplicatesRuController();

        controller.idForRequest = lead.id;
        controller.commentForRequest = 'Comment';
        controller.sendRequestForChangeOwner();
    }

    @IsTest
    public static void searchForE2EOpportunityTest(){
        String RecordTypeLead = [select id from recordtype where name = 'Russian Sales' and SobjectType = 'Lead'].id;
        String RecordTypeOpp = [select id from recordtype where name = 'Russian Sales' and SobjectType = 'Opportunity'].id;
        String RecordTypeAcc = [select id from recordtype where name = 'Russian' and SobjectType = 'Account'].id;
        String RWL;
        if ([select id from group where name = 'Russian Web Leads'].size() == 1)
            RWL = [select id from group where name = 'Russian Web Leads'].id;
        else
                RWL = '0BLANKIDBLANKID';

        Lead lead = new Lead(Phone = '1234567891098754321', LastName = 'test12345678910987654321',
                Company = 'test12345678910987654321', Email = 'Email12345678910@gggmail.ru', Salutation = 'Herr',
                Date_of_First_Contact_Inbound_Outbound__c = Date.today(), Country = 'Russia', INN__C = '1234567899999',
                First_Contact_Inbound_Outbound__c = 'Inbound Call', Source_of_lead__c = 'E2E Form RU',
                RecordTypeId = RecordTypeLead, ownerid = RWL);
        insert lead;
        Account accountt = new Account(Name = 'test12345678910987654321', BillingPostalCode = '123', Phone = '1234567891098754321',
                INN__C = '1234567899999',
                RecordTypeId = RecordTypeAcc);
        insert accountt;

        Contact contt = new Contact(LastName = 'testcontact12345', Phone = '1234567890',Email = 'test@testcont.ru', AccountId = accountt.Id);
        insert contt;

        Opportunity opportunity = new Opportunity(Name = 'test12345678910987654321', StageName = 'Prospecting', CloseDate = Date.today(),
                AccountId = accountt.id, RecordTypeId = RecordTypeOpp, Source_of_Lead_o__c = 'E2E Form RU', Starts_Status__c = '0. Request received');
        insert opportunity;
        Ru_Admin_Approver__c approver = new Ru_Admin_Approver__c(Name = 'test@test.com');
        insert approver;
        FindDuplicatesRuController contr = new FindDuplicatesRuController();
        contr.idForRequest = opportunity.Id;
        contr.sendRequestForChangeOwner();
        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        FindDuplicatesRuController controller = new FindDuplicatesRuController();
        controller.isINNSelected = true;
        controller.isCompanySelected = true;
        controller.isEmailSelected = true;
        controller.isPhoneSelected = true;
        controller.init();
        controller.searchPage();

        System.assertEquals(controller.matchingAccounts.size(), 1);
        System.assertEquals(controller.matchingOpportunities.size(), 1);
    }


}