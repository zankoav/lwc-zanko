@isTest
private class AccountHandlerTest {
    @isTest
    public static void testAccountUpper() {
        Account a = new Account(Name = 'test');
        insert a;
        a.Name = 'test1';
        a.Firmenname2_Zusatz__c = 'test';
        a.BillingStreet = 'test';
        a.ShippingStreet = 'test';
        a.BillingCity = 'test';
        a.ShippingCity = 'test';
        update a;
        Account testAcc = [SELECT Name FROM Account WHERE Id = :a.Id LIMIT 1];
        system.assertEquals('TEST1', testAcc.Name);
    }

    @isTest
    public static void testUpdateLastContactDate() {
        Account parentAccount = new Account(Name = 'parent');
        insert parentAccount;
        Account childAccount1 = new Account(Name = 'child1', ParentId = parentAccount.Id);
        insert childAccount1;
        Account childAccount2 = new Account(Name = 'child2', ParentId = parentAccount.Id);
        insert childAccount2;
        childAccount2.Last_contact_date__c = date.today().addDays(-2);
        update childAccount2;

        Account testParentAccount = [
                SELECT Name, Last_contact_date__c
                FROM Account
                WHERE ParentId = null
        ];
        System.assertEquals(testParentAccount.Last_contact_date__c, date.today().addDays(-2));

        Account testChildAccount = [
                SELECT Name, Last_contact_date__c
                FROM Account
                WHERE Name = 'child1'
        ];
        System.assertEquals(testChildAccount.Last_contact_date__c, date.today().addDays(-2));
    }

    /*******************************************************************************
      *  Name            : testLastDateChangeOwnerRUSAndOpenTaskCheckBox()
      *  Summary         : check for change of field Last_Owner_Change_Date_RUS__c when changing owner
      *  CreatedDate     : 20/11/2017
      *  UpdateDate      : 11/05/2017
      *  UpdateBy        : Nikita Mikhailov
      *  Parameters      : -
      *  Returns         : void
      ******************************************************************************/
    @isTest
    public static void testLastDateChangeOwnerRUSAndOpenTaskCheckBox() {
        Profile p = [
                SELECT Id
                FROM Profile
                WHERE Name = 'System Administrator'
        ];

        User user = new User(
                Username = 'usertest@fleetcor.de',
                ProfileId = p.Id,
                Alias = 'uset@fl',
                Email = 'usertest@fleetcor.de',
                EmailEncodingKey = 'UTF-8',
                Lastname = 'usertest',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago');
        insert user;
        User user2 = new User(
                Username = 'usertest2@fleetcor.de',
                ProfileId = p.Id,
                Alias = 'uset2@fl',
                Email = 'usertest2@fleetcor.de',
                EmailEncodingKey = 'UTF-8',
                Lastname = 'usertest2',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago');
        insert user2;

        Id recordTypeId;
        Id recordTypeOpportunity;

        if (Schema.SObjectType.Account.getRecordTypeInfosByName().get('Российские') != null) {
            recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Российские').getRecordTypeId();
        } else if (Schema.SObjectType.Account.getRecordTypeInfosByName().get('Russian') != null) {
            recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Russian').getRecordTypeId();
        }

        if (Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Российские продажи') != null) {
            recordTypeOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Российские продажи').getRecordTypeId();
        } else if (Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Russian Sales') != null) {
            recordTypeOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Russian Sales').getRecordTypeId();
        }

        Account account = new Account(Name = 'testt', OwnerId = user.Id, RecordTypeId = recordTypeId);
        insert account;
        Opportunity opportunity = new Opportunity(
                Name = 'testt',
                AccountId = account.Id,
                StageName = 'Client Negotiations',
                CloseDate = Date.today() - 1,
                Angebotsdauer__c = '3 months',
                OwnerId = user.Id,
                RecordTypeId = recordTypeOpportunity
        );
        insert opportunity;

        account.OwnerId = user2.Id;
        update account;

        Opportunity testOpportunity = [
                SELECT Last_Owner_Change_Date_RUS__c
                FROM Opportunity
                WHERE Name = 'testt'
        ];


        System.assertNotEquals(testOpportunity.Last_Owner_Change_Date_RUS__c,
                opportunity.Last_Owner_Change_Date_RUS__c);
    }


    /*******************************************************************************
    *  Name            : testUpdateCurrencyIsoCode()
    *  Summary         : test checking CurrencyIsoCode after insert and after update
    *  CreatedDate     : 03.03.2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void testupdateCurrencyIsoCode() {
        Account account = new Account(
                Name = 'testt',
                BillingCountry = 'Germany'
        );
        insert account;

        Opportunity opportunity = new Opportunity(
                Name = 'testt',
                AccountId = account.Id,
                StageName = 'Closed Won',
                CloseDate = Date.today() - 100,
                Angebotsdauer__c = '3 months'
        );
        insert opportunity;

        account.BillingCountry = 'Poland';
        update account;

        List<Opportunity> oppList = [
                SELECT CurrencyIsoCode
                FROM Opportunity
                LIMIT 1
        ];

        System.assertEquals('PLN', oppList.get(0).CurrencyIsoCode);
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
        List<Account> accountsToInsertList = new List<Account>();

        Account accountGermany = new Account(
                Phone = '0049 111 22 33',
                Fax = '282245167',
                CM_mobile__c = '0112/33(0)2',
                Phone_Crif__c = '49282245167',
                SM_mobile__c = '(0)282245167',
                TM_mobile__c = '28224/5167',
                BillingCountry = 'Germany',
                BillingCountryCode = 'DE',
                Name = 'test');
        accountsToInsertList.add(accountGermany);
        insert accountsToInsertList;

        Set<Id> idsToTest = new Set<Id>();
        for (Account account : accountsToInsertList) {
            idsToTest.add(account.Id);
        }

        Map<Id, Account> accountsToTestMap = new Map<Id, Account>([
                SELECT Phone, Fax, CM_mobile__c, Phone_Crif__c, SM_mobile__c, TM_mobile__c
                FROM Account
                WHERE Id IN :idsToTest
                LIMIT 10000
        ]);

        // Germany
        System.assertEquals('+491112233', accountsToTestMap.get(accountGermany.Id).Phone);
        System.assertEquals('+49282245167', accountsToTestMap.get(accountGermany.Id).Fax);
        System.assertEquals('+491123302', accountsToTestMap.get(accountGermany.Id).CM_mobile__c);
        System.assertEquals('+49282245167', accountsToTestMap.get(accountGermany.Id).Phone_Crif__c);
        System.assertEquals('+49282245167', accountsToTestMap.get(accountGermany.Id).SM_mobile__c);
        System.assertEquals('+49282245167', accountsToTestMap.get(accountGermany.Id).TM_mobile__c);
    }


    /*******************************************************************************
    *  Name            : testAddErrorMessageForSalesTeam()
    *  Summary         : Testing addErrorMessageForSalesTeam() before update
    *  CreatedDate     : 19/04/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    private static void testAddErrorMessageForSalesTeam() {
        Test.startTest();
        Profile saleRepProfile = [SELECT Id FROM Profile WHERE Name = 'FleetcorEmea Profile'];
        User saleRep = new User(
                ProfileId = saleRepProfile.Id,
                Username = 'SaleRep' + System.now().millisecond() + '@fleetcor.de',
                Alias = 'sr',
                Email = 'test@fleetcor.de',
                Country = 'Germany',
                CountryCode = 'DE',
                EmailEncodingKey = 'UTF-8',
                LastName = 'test',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago');
        Database.insert(saleRep);

        System.runAs(saleRep) {
            List<Account_fields_after_Closed_Won__c> fieldsList = new List<Account_fields_after_Closed_Won__c>();
            fieldsList.add(new Account_fields_after_Closed_Won__c(Name = '1', Field_Name__c = 'Anzahl_der_Karten_All__c'));
            fieldsList.add(new Account_fields_after_Closed_Won__c(Name = '2', Field_Name__c = 'Kraftstoffverbrauch_Liter_Monat_ALL__c'));
            fieldsList.add(new Account_fields_after_Closed_Won__c(Name = '3', Field_Name__c = 'Moved_to_Start__c'));
            fieldsList.add(new Account_fields_after_Closed_Won__c(Name = '4', Field_Name__c = 'Number_of_Attachments__c'));
            fieldsList.add(new Account_fields_after_Closed_Won__c(Name = '5', Field_Name__c = 'Number_of_Files_and_Attachments__c'));
            fieldsList.add(new Account_fields_after_Closed_Won__c(Name = '6', Field_Name__c = 'Number_of_Files__c'));
            fieldsList.add(new Account_fields_after_Closed_Won__c(Name = '7', Field_Name__c = 'Number_of_Vehicles_All__c'));
            fieldsList.add(new Account_fields_after_Closed_Won__c(Name = '8', Field_Name__c = 'Number_of_Vehicles_WON__c'));
            fieldsList.add(new Account_fields_after_Closed_Won__c(Name = '9', Field_Name__c = 'Number_Opportunities__c'));
            fieldsList.add(new Account_fields_after_Closed_Won__c(Name = '10', Field_Name__c = 'N_of_Closed_Won_Opportunities__c'));
            fieldsList.add(new Account_fields_after_Closed_Won__c(Name = '11', Field_Name__c = 'N_of_Files_and_Attachments_Opportunities__c'));
            fieldsList.add(new Account_fields_after_Closed_Won__c(Name = '12', Field_Name__c = 'Opportunity_Sum__c'));
            insert fieldsList;

            RecordType accRecType = [SELECT Id FROM RecordType WHERE Sobjecttype = 'Account' AND Name = 'Endkunde'];
            Account account = new Account(
                    Name = 'testAddError',
                    AccountSource = 'ABVP',
                    Beschaeftigte__c = '5-9',
                    Gesellschaftsform__c = 'Agency of an Overseas Business',
                    Phone = '11111',
                    Type = 'Customer',
                    BillingCountry = 'Germany',
                    RecordTypeId = accRecType.Id
            );
            insert account;

            RecordType recordType = [SELECT Id FROM RecordType WHERE Name = 'Euroshell' AND SObjectType = 'Opportunity'];
            Opportunity opportunity = new Opportunity(
                    AccountId = account.Id,
                    RecordTypeId = recordType.Id,
                    Name = 'test',
                    StageName = 'Closed Won',
                    Angebotsdauer__c = '3 Monate',
                    Anzahl_der_Karten__c = 3,
                    CloseDate = Date.today() - 10);
            insert opportunity;

            try {
                account.Phone = '22222';
                update account;
            } catch (Exception e) {
                Boolean expectedExceptionThrown = e.getMessage().contains('You can\'t change Account fields for 3 months after Closed Won Opportunity') ? true : false;
                System.AssertEquals(true, expectedExceptionThrown);
            }
        }
        Test.stopTest();
    }


    /*******************************************************************************
    *  Name            : testFindDuplicateTaxId()
    *  Summary         : Find duplicate Tax ID and add error message if it's true
    *  CreatedDate     : 21/05/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    private static void testFindDuplicateTaxId() {
        RecordType accRecType = [SELECT Id FROM RecordType WHERE Sobjecttype = 'Account' AND Name = 'Endkunde'];
        Account account = new Account(
                Name = 'test',
                AccountSource = 'ABVP',
                Beschaeftigte__c = '5-9',
                Steuernummer__c = '1111',
                Gesellschaftsform__c = 'Agency of an Overseas Business',
                Phone = '11111',
                Type = 'Customer',
                BillingCountry = 'Belgium-NL',
                BillingCountryCode = 'BENL',
                RecordTypeId = accRecType.Id
        );
        insert account;

        Account duplicateAccountTaxId = new Account(
                Name = 'duplicate',
                AccountSource = 'ABVP',
                Beschaeftigte__c = '5-9',
                Steuernummer__c = '111',
                Gesellschaftsform__c = 'Agency of an Overseas Business',
                Phone = '11111',
                Type = 'Customer',
                BillingCountry = 'Belgium-FR',
                BillingCountryCode = 'BEFR',
                RecordTypeId = accRecType.Id
        );
        insert duplicateAccountTaxId;

        try {
            duplicateAccountTaxId.Steuernummer__c = '1111';
            update duplicateAccountTaxId;
        } catch (Exception e) {
            Boolean expectedExceptionThrown = e.getMessage().contains('Duplicate Tax ID number is found.') ? true : false;
            System.AssertEquals(true, expectedExceptionThrown);
        }
    }

    /*******************************************************************************
    *  Name            : testChangeAccountOwner()
    *  Summary         : testing sendRussianRequestForChangeAccountOwner
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testChangeAccountOwner() {
        Profile p = [
                SELECT Id
                FROM Profile
                WHERE Name = 'Russian Sales Manager'
        ];

        User user2 = new User(
                Username = 'usertest2@fleetcor.de',
                ProfileId = p.Id,
                Alias = 'uset2@fl',
                Email = 'usertest2@fleetcor.de',
                EmailEncodingKey = 'UTF-8',
                Lastname = 'usertest2',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago');
        insert user2;
        User user = new User(
                Username = 'usertest@fleetcor.de',
                ProfileId = p.Id,
                Alias = 'uset@fl',
                Email = 'usertest@fleetcor.de',
                EmailEncodingKey = 'UTF-8',
                Lastname = 'usertest',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago',
                ManagerId = user2.id);
        insert user;


        system.runAs(user) {
            Id recordTypeId;
            Id recordTypeOpportunity;
            if (Schema.SObjectType.Account.getRecordTypeInfosByName().get('Российские') != null) {
                recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Российские').getRecordTypeId();
            } else if (Schema.SObjectType.Account.getRecordTypeInfosByName().get('Russian') != null) {
                recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Russian').getRecordTypeId();
            }

            if (Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Российские продажи') != null) {
                recordTypeOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Российские продажи').getRecordTypeId();
            } else if (Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Russian Sales') != null) {
                recordTypeOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Russian Sales').getRecordTypeId();
            }

            Account account = new Account(Name = 'testt', OwnerId = user.Id, RecordTypeId = recordTypeId, INN__c = '1234543215');
            insert account;
            Opportunity opportunity = new Opportunity(
                    Name = 'testt',
                    AccountId = account.Id,
                    StageName = 'Qualified Lead',
                    CloseDate = Date.today() - 1,
                    Angebotsdauer__c = '3 months',
                    OwnerId = user.Id,
                    RecordTypeId = recordTypeOpportunity,
                    Source_of_Lead_o__c = 'Сайт petrolplus.ru'
            );
            insert opportunity;

            account.OwnerId = user2.Id;
            update account;
        }
        Opportunity testOpportunity = [
                SELECT OwnerId
                FROM Opportunity
                WHERE Name = 'testt'
        ];
        Account testAccount = [
                SELECT OwnerId
                FROM Account
                WHERE Name = 'testt'
        ];

        system.debug(testAccount.OwnerId+' '+ user.id);
        system.debug(testOpportunity.OwnerId+' '+ user.id);
        System.assertEquals(testAccount.OwnerId, user.id);
        System.assertEquals(testOpportunity.OwnerId, user.id);
    }
}