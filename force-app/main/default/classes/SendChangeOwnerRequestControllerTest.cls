@isTest
private class SendChangeOwnerRequestControllerTest {
    public Static User u;

    static testMethod void testSendRequest() {
        Test.startTest();
            createSalesUser();
        Test.stopTest();

        Account account;
        Contact contact;

        System.runAs(u) {
            account = new Account(
                Name = 'test');
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

            SendChangeOwnerRequestController controller = new SendChangeOwnerRequestController();
            controller.init();

            Account testAccount = [
                    SELECT Active_Change_Owner_Request__c
                    FROM Account 
                    WHERE Id = :account.Id];
            System.assert(testAccount.Active_Change_Owner_Request__c);
        }
    }


    static testMethod void testInvalidAccountIdSendRequest() {
        Test.startTest();
            createSalesUser();
        Test.stopTest();

        Account account;
        Contact contact;

        System.runAs(u) {
            account = new Account(
                Name = 'test');
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

            SendChangeOwnerRequestController controller = new SendChangeOwnerRequestController();
            controller.init();
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
}