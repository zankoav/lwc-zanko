@isTest
private class ChangeOwnerRequestControllerTest {
    public Static User u;
    public Static User u2;

    static testMethod void testApproveRequest() {
        Test.startTest();
            createSalesUser();
            createLeadUser();
        Test.stopTest();

        Account account;
        Contact contact;

        System.runAs(u) {
            account = new Account(
                Name = 'test',
                Active_Change_Owner_Request__c = true);
            insert account;

            contact = new Contact(
                Salutation = 'Mr',
                LastName = 'test lastname',
                AccountId = account.Id);
            insert contact;

            Opportunity opp = new Opportunity(
                StageName = 'Prospecting',
                CloseDate = Date.today(),
                Name = 'test',
                AccountId = account.Id);
            insert opp;

            ApexPages.CurrentPage().getparameters().put('id', account.Id);
            ApexPages.CurrentPage().getparameters().put('d', '1');
            ApexPages.CurrentPage().getparameters().put('newOwnerId', u2.Id);
        }

        System.runAs(u2) {
            Account testAccount = [SELECT OwnerId FROM Account WHERE Id = :account.Id];
            System.assert(testAccount.OwnerId != u2.Id);

            ChangeOwnerRequestController controller = new ChangeOwnerRequestController();
            controller.init();

            Account testAccount2 = [SELECT OwnerId FROM Account WHERE Id = :account.Id];
            System.assert(testAccount2.OwnerId == u2.Id);

            Contact testContact = [SELECT OwnerId FROM Contact WHERE Id = :contact.Id];
            System.assert(testContact.OwnerId == u2.Id);
        }
    }


    static testMethod void testRejectRequest() {
        Test.startTest();
            createSalesUser();
            createLeadUser();
        Test.stopTest();

        Account account;
        Contact contact;

        System.runAs(u) {
            account = new Account(
                Name = 'test',
                Active_Change_Owner_Request__c = true);
            insert account;

            contact = new Contact(
                Salutation = 'Mr',
                LastName = 'test lastname',
                AccountId = account.Id);
            insert contact;

            Opportunity opp = new Opportunity(
                StageName = 'Prospecting',
                CloseDate = Date.today(),
                Name = 'test',
                AccountId = account.Id);
            insert opp;

            ApexPages.CurrentPage().getparameters().put('id', account.Id);
            ApexPages.CurrentPage().getparameters().put('d', '0');
            ApexPages.CurrentPage().getparameters().put('newOwnerId', u2.Id);
        }

        System.runAs(u2) {
            Account testAccount = [SELECT OwnerId FROM Account WHERE Id = :account.Id];
            System.assert(testAccount.OwnerId != u2.Id);

            ChangeOwnerRequestController controller = new ChangeOwnerRequestController();
            controller.init();

            Account testAccount2 = [SELECT OwnerId FROM Account WHERE Id = :account.Id];
            System.assert(testAccount2.OwnerId != u2.Id);

            Contact testContact = [SELECT OwnerId FROM Contact WHERE Id = :contact.Id];
            System.assert(testContact.OwnerId != u2.Id);
        }
    }


    @future
    private static void createSalesUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales']; 
        UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'Salesteam Outbound 2'];
        Integer rand = Math.round(Math.random()*100000);
        u = new User(
            UserRoleId = ur.Id,
            ProfileId = p.Id,
            Username = rand + '@' + rand + 'test.com',
            Alias = 'batman',
            Email='bruce.wayne_'+rand+'@wayneenterprises.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
        );
        Database.insert(u);    
    }


    @future
    private static void createLeadUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Salesteamleiter']; 
        UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'Teamleiter Outbound 2'];
        Integer rand = Math.round(Math.random()*100000);
        u2 = new User(
            UserRoleId = ur.Id,
            ProfileId = p.Id,
            Username = rand + '@' + rand + 'test.com',
            Alias = 'batman',
            Email='bruce.wayne_'+rand+'@wayneenterprises.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
        );
        Database.insert(u2);       
    }
}