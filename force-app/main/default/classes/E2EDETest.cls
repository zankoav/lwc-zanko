@isTest
private class E2EDETest {
    public static LongFormController controller;

    /*******************************************************************************
    *  Name            : createLongFormData()
    *  Summary         : Creating all LongForm data    
    *  CreatedDate     : 06/06/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @testSetup
    static void createLongFormData() {
        E2ELongFormUtilsTest.createInternationalPartnersPrice('Germany', 'Inbound');
        E2ELongFormUtilsTest.createNationalNotPartnersPrice('Germany', 'Inbound');
        E2ELongFormUtilsTest.createInternationalNotPartnersPrice('Germany', 'Inbound');
        E2ELongFormUtilsTest.createNationalPartnersPrice('Germany', 'Inbound');
        E2ELongFormUtilsTest.createInternationalPartnersDiffPrice('Germany', 'Inbound');
        E2ELongFormUtilsTest.createNationalNotPartnersDiffPrice('Germany', 'Inbound');
        E2ELongFormUtilsTest.createInternationalNotPartnersDiffPrice('Germany', 'Inbound');
        E2ELongFormUtilsTest.createNationalPartnersDiffPrice('Germany', 'Inbound');
        E2ELongFormUtilsTest.createLongForm('Germany');
        E2ELongFormUtilsTest.createLongFormMenu();
        E2ELongFormUtilsTest.createMenuItemForStep1('Desktop');
        E2ELongFormUtilsTest.createMenuItemForStep2('Desktop');
        E2ELongFormUtilsTest.createMenuItemForStep3('Desktop');
        E2ELongFormUtilsTest.createMenuItemForStep4('Desktop');
        E2ELongFormUtilsTest.createHeader('Desktop');
        E2ELongFormUtilsTest.createContactDeatilsData('Desktop');
        E2ELongFormUtilsTest.createCustomSettings('Germany', 'E2EForm', 'Creditreform', '00520000005vYf3');
        E2ELongFormUtilsTest.createOrderDetailsBlock('Desktop');
        E2ELongFormUtilsTest.createFooter('Desktop');
        E2ELongFormUtilsTest.createCreditScoreAnotherTaxID('Desktop');
        E2ELongFormUtilsTest.createCreditScoreSearchCompany('Desktop');
        E2ELongFormUtilsTest.createCreditScoreTotalConsumption('Desktop');
        E2ELongFormUtilsTest.createCreditScoringResult('Desktop');
        E2ELongFormUtilsTest.createCardConfiguration('Desktop');
        E2ELongFormUtilsTest.createCardConfigurationSpecialOffers('Desktop', 'INBOUND TYPE C OFFER #1', 'INBOUND TYPE B OFFER #1', 'Germany', 'Inbound', 'Inbound Typ C', 'Inbound Typ B');
        E2ELongFormUtilsTest.createCardConfigurationTechnicalParameters('Desktop');
        E2ELongFormUtilsTest.createCardConfigurationInputVatId('Desktop');
        E2ELongFormUtilsTest.createAdditionalPage('Desktop');
        E2ELongFormUtilsTest.createAdditionalDateOfBirth('Desktop');
        E2ELongFormUtilsTest.createPaymentOptions('Desktop');
        E2ELongFormUtilsTest.createPaymentOptionsCongratulations('Desktop');
        E2ELongFormUtilsTest.createSystemErrorPage('Desktop');
        E2ELongFormUtilsTest.createProcessErrorPage('Desktop');
        E2ELongFormUtilsTest.createAlreadyCustomerPage('Desktop');
        E2ELongFormUtilsTest.createAlreadyInProcessPage('Desktop');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.doCreateCreditSystemSalesProfile();
        insert creditSystemSalesProfile;
    }


    /*******************************************************************************
    *  Name            : insertPrivateContact()
    *  Summary         : Verify that user is redirected to error page when choose Private Entity    
    *  ExpectedResult  : User is redirected to error page. Contact is not created.
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void insertPrivateContact() {
        ApexPages.currentPage().getparameters().put('country', 'Germany');
        controller = new LongFormController();
        controller.init();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHN';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SMITH';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491234567890';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'test@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Private';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();

        List<Account> accountList = [SELECT Id FROM Account];
        System.assertEquals(0, accountList.size(), 'Unnecessary Account was created.');

        List<Opportunity> opportunityList = [SELECT Id FROM Opportunity];
        System.assertEquals(0, opportunityList.size(), 'Unnecessary Opportunity was created.');

        List<Contact> contactList = [SELECT Id FROM Contact];
        System.assertEquals(0, contactList.size(), 'Unnecessary Contact was created.');
    }


    /*******************************************************************************
    *  Name            : insertDupConSameDataClosedLost()
    *  Summary         : Verify that two Contacts were merged when First Name + Last Name + Email + Phone are the same and Contact #1 has E2E Opportunity #1 in stage Closed Lost    
    *  ExpectedResult  : Two contacts were merged. E2E Account #2, E2E Opportuinty #2 were created. Direct Connections were changed to E2E records
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void insertDupConSameDataClosedLost() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Closed Lost';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        controller = new LongFormController();
        controller.init();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHN';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SMITH';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491234567899';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'test@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();

        List<Account> accountList = [SELECT Id FROM Account];
        System.assertEquals(2, accountList.size(), 'Two Accounts are expected.');

        List<Opportunity> opportunityList = [SELECT Id FROM Opportunity];
        System.assertEquals(2, opportunityList.size(), 'Two Opportunities are expected.');

        List<Contact> contactList = [
                SELECT FirstName, LastName, Phone, Email, 
                    (SELECT Id FROM AccountContactRelations), 
                    (SELECT Id FROM OpportunityContactRoles)
                FROM Contact];
        System.assertEquals(2, contactList.get(0).AccountContactRelations.size(), 'Two Accounts are expected.');
        System.assertEquals(2, contactList.get(0).OpportunityContactRoles.size(), 'Two Opportunities are expected.');
        System.assertEquals(1, contactList.size(), 'One contact is expected.');
        System.assertEquals('JOHN', contactList.get(0).FirstName, 'Expected FirstName from form.');
        System.assertEquals('SMITH', contactList.get(0).LastName, 'Expected LastName from form.');
        System.assertEquals('+491234567899', contactList.get(0).Phone, 'Expected Phone from form.');
        System.assertEquals('test@fleetcor.com', contactList.get(0).Email, 'Expected Email from form.');
    }


    /*******************************************************************************
    *  Name            : insertDupConSameDataClosedWon()
    *  Summary         : Verify that two Contacts were merged when First Name + Last Name + Email + Phone are the same and Contact #1 has E2E Opportunity #1 in stage Closed Won 
    *  ExpectedResult  : Two contacts were merged. E2E Account #2, E2E Opportuinty #2 were created. Direct Connections were changed to E2E records
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void insertDupConSameDataClosedWon() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Closed Won';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        controller = new LongFormController();
        controller.init();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHN';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SMITH';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491234567890';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'test@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();

        List<Account> accountList = [SELECT Id FROM Account];
        System.assertEquals(2, accountList.size(), 'Two Accounts are expected.');

        List<Opportunity> opportunityList = [SELECT Id FROM Opportunity];
        System.assertEquals(2, opportunityList.size(), 'Two Opportunities are expected.');

        List<Contact> contactList = [
                SELECT FirstName, LastName, Phone, Email, 
                    (SELECT Id FROM AccountContactRelations), 
                    (SELECT Id FROM OpportunityContactRoles)
                FROM Contact];
        System.assertEquals(2, contactList.get(0).AccountContactRelations.size(), 'Two Accounts are expected.');
        System.assertEquals(2, contactList.get(0).OpportunityContactRoles.size(), 'Two Opportunities are expected.');
        System.assertEquals(1, contactList.size(), 'One contact is expected.');
        System.assertEquals('JOHN', contactList.get(0).FirstName, 'Expected FirstName from form.');
        System.assertEquals('SMITH', contactList.get(0).LastName, 'Expected LastName from form.');
        System.assertEquals('+491234567890', contactList.get(0).Phone, 'Expected Phone from form.');
        System.assertEquals('test@fleetcor.com', contactList.get(0).Email, 'Expected Email from form.');
    }


    /*******************************************************************************
    *  Name            : insertDupConSameDataPendingSalesDeposit()
    *  Summary         : Verify that two Contacts were merged when First Name + Last Name + Email + Phone are the same and Contact #1 has E2E Opportunity #1 in stage Pending Sales – Deposit
    *  ExpectedResult  : Two contacts were merged. E2E Account #2, E2E Opportuinty #2 were created. Direct Connections were changed to E2E records
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void insertDupConSameDataPendingSalesDeposit() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Pending Sales – Deposit';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        controller = new LongFormController();
        controller.init();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHN';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SMITH';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491234567890';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'test@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();

        List<Account> accountList = [SELECT Id FROM Account];
        System.assertEquals(2, accountList.size(), 'Two Accounts are expected.');

        List<Opportunity> opportunityList = [SELECT Id FROM Opportunity];
        System.assertEquals(2, opportunityList.size(), 'Two Opportunities are expected.');

        List<Contact> contactList = [
                SELECT FirstName, LastName, Phone, Email, 
                    (SELECT Id FROM AccountContactRelations), 
                    (SELECT Id FROM OpportunityContactRoles)
                FROM Contact];
        System.assertEquals(2, contactList.get(0).AccountContactRelations.size(), 'Two Accounts are expected.');
        System.assertEquals(2, contactList.get(0).OpportunityContactRoles.size(), 'Two Opportunities are expected.');
        System.assertEquals(1, contactList.size(), 'One contact is expected.');
        System.assertEquals('JOHN', contactList.get(0).FirstName, 'Expected FirstName from form.');
        System.assertEquals('SMITH', contactList.get(0).LastName, 'Expected LastName from form.');
        System.assertEquals('+491234567890', contactList.get(0).Phone, 'Expected Phone from form.');
        System.assertEquals('test@fleetcor.com', contactList.get(0).Email, 'Expected Email from form.');
    }


    /*******************************************************************************
    *  Name            : insertDupConSameEmailClosedLost()
    *  Summary         : Verify that two Contacts were merged when Emails are the same and Contact #1 has E2E Opportunity #1 in stage Closed Lost
    *  ExpectedResult  : Two contacts were merged. E2E Account #2, E2E Opportuinty #2 were created. Direct Connections were changed to E2E records
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void insertDupConSameEmailClosedLost() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Closed Lost';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        controller = new LongFormController();
        controller.init();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'CONOR';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'MCGREGOR';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+499999999999';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'test@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();

        List<Account> accountList = [SELECT Id FROM Account];
        System.assertEquals(2, accountList.size(), 'Two Accounts are expected.');

        List<Opportunity> opportunityList = [SELECT Id FROM Opportunity];
        System.assertEquals(2, opportunityList.size(), 'Two Opportunities are expected.');

        List<Contact> contactList = [
                SELECT FirstName, LastName, Phone, Email, 
                    (SELECT Id FROM AccountContactRelations), 
                    (SELECT Id FROM OpportunityContactRoles)
                FROM Contact];
        System.assertEquals(2, contactList.get(0).AccountContactRelations.size(), 'Two Accounts are expected.');
        System.assertEquals(2, contactList.get(0).OpportunityContactRoles.size(), 'Two Opportunities are expected.');
        System.assertEquals(1, contactList.size(), 'One contact is expected.');
        System.assertEquals('CONOR', contactList.get(0).FirstName, 'Expected FirstName from form.');
        System.assertEquals('MCGREGOR', contactList.get(0).LastName, 'Expected LastName from form.');
        System.assertEquals('+499999999999', contactList.get(0).Phone, 'Expected Phone from form.');
        System.assertEquals('test@fleetcor.com', contactList.get(0).Email, 'Expected Email from form.');
    }


    /*******************************************************************************
    *  Name            : insertDupConSameEmailClosedWon()
    *  Summary         : Verify that two Contacts were merged when Emails are the same and Contact #1 has E2E Opportunity #1 in stage Closed Won
    *  ExpectedResult  : Two contacts were merged. E2E Account #2, E2E Opportuinty #2 were created. Direct Connections were changed to E2E records
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void insertDupConSameEmailClosedWon() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Closed Won';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        controller = new LongFormController();
        controller.init();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'CONOR';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'MCGREGOR';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+499999999999';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'test@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();

        List<Account> accountList = [SELECT Id FROM Account];
        System.assertEquals(2, accountList.size(), 'Two Accounts are expected.');

        List<Opportunity> opportunityList = [SELECT Id FROM Opportunity];
        System.assertEquals(2, opportunityList.size(), 'Two Opportunities are expected.');

        List<Contact> contactList = [
                SELECT FirstName, LastName, Phone, Email, 
                    (SELECT Id FROM AccountContactRelations), 
                    (SELECT Id FROM OpportunityContactRoles)
                FROM Contact];
        System.assertEquals(2, contactList.get(0).AccountContactRelations.size(), 'Two Accounts are expected.');
        System.assertEquals(2, contactList.get(0).OpportunityContactRoles.size(), 'Two Opportunities are expected.');
        System.assertEquals(1, contactList.size(), 'One contact is expected.');
        System.assertEquals('CONOR', contactList.get(0).FirstName, 'Expected FirstName from form.');
        System.assertEquals('MCGREGOR', contactList.get(0).LastName, 'Expected LastName from form.');
        System.assertEquals('+499999999999', contactList.get(0).Phone, 'Expected Phone from form.');
        System.assertEquals('test@fleetcor.com', contactList.get(0).Email, 'Expected Email from form.');
    }


    /*******************************************************************************
    *  Name            : insertDupConSameEmailPendingSalesDeposit()
    *  Summary         : Verify that two Contacts were merged when Emails are the same and Contact #1 has E2E Opportunity #1 in stage Pending Sales - Deposit
    *  ExpectedResult  : Two contacts were merged. E2E Account #2, E2E Opportuinty #2 were created. Direct Connections were changed to E2E records
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void insertDupConSameEmailPendingSalesDeposit() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Pending Sales – Deposit';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        controller = new LongFormController();
        controller.init();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'CONOR';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'MCGREGOR';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+499999999999';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'test@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();

        List<Account> accountList = [SELECT Id FROM Account];
        System.assertEquals(2, accountList.size(), 'Two Accounts are expected.');

        List<Opportunity> opportunityList = [SELECT Id FROM Opportunity];
        System.assertEquals(2, opportunityList.size(), 'Two Opportunities are expected.');

        List<Contact> contactList = [
                SELECT FirstName, LastName, Phone, Email, 
                    (SELECT Id FROM AccountContactRelations), 
                    (SELECT Id FROM OpportunityContactRoles)
                FROM Contact];
        System.assertEquals(2, contactList.get(0).AccountContactRelations.size(), 'Two Accounts are expected.');
        System.assertEquals(2, contactList.get(0).OpportunityContactRoles.size(), 'Two Opportunities are expected.');
        System.assertEquals(1, contactList.size(), 'One contact is expected.');
        System.assertEquals('CONOR', contactList.get(0).FirstName, 'Expected FirstName from form.');
        System.assertEquals('MCGREGOR', contactList.get(0).LastName, 'Expected LastName from form.');
        System.assertEquals('+499999999999', contactList.get(0).Phone, 'Expected Phone from form.');
        System.assertEquals('test@fleetcor.com', contactList.get(0).Email, 'Expected Email from form.');
    }


    /*******************************************************************************
    *  Name            : insertDupConSamePhoneClosedLost()
    *  Summary         : Verify that two Contacts were merged when Phones are the same and Contact #1 has E2E Opportunity #1 in stage Closed Lost
    *  ExpectedResult  : Two contacts were merged. E2E Account #2, E2E Opportuinty #2 were created. Direct Connections were changed to E2E records
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void insertDupConSamePhoneClosedLost() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Closed Lost';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        controller = new LongFormController();
        controller.init();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'CONOR';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'MCGREGOR';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491234567890';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'conor@mcgregor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();

        List<Account> accountList = [SELECT Id FROM Account];
        System.assertEquals(2, accountList.size(), 'Two Accounts are expected.');

        List<Opportunity> opportunityList = [SELECT Id FROM Opportunity];
        System.assertEquals(2, opportunityList.size(), 'Two Opportunities are expected.');

        List<Contact> contactList = [
                SELECT FirstName, LastName, Phone, Email, 
                    (SELECT Id FROM AccountContactRelations), 
                    (SELECT Id FROM OpportunityContactRoles)
                FROM Contact];
        System.assertEquals(2, contactList.get(0).AccountContactRelations.size(), 'Two Accounts are expected.');
        System.assertEquals(2, contactList.get(0).OpportunityContactRoles.size(), 'Two Opportunities are expected.');
        System.assertEquals(1, contactList.size(), 'One contact is expected.');
        System.assertEquals('CONOR', contactList.get(0).FirstName, 'Expected FirstName from form.');
        System.assertEquals('MCGREGOR', contactList.get(0).LastName, 'Expected LastName from form.');
        System.assertEquals('+491234567890', contactList.get(0).Phone, 'Expected Phone from form.');
        System.assertEquals('conor@mcgregor.com', contactList.get(0).Email, 'Expected Email from form.');
    }


    /*******************************************************************************
    *  Name            : insertDupConSamePhoneClosedWon()
    *  Summary         : Verify that two Contacts were merged when Phones are the same and Contact #1 has E2E Opportunity #1 in stage Closed Won
    *  ExpectedResult  : Two contacts were merged. E2E Account #2, E2E Opportuinty #2 were created. Direct Connections were changed to E2E records
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void insertDupConSamePhoneClosedWon() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Closed Won';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        controller = new LongFormController();
        controller.init();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'CONOR';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'MCGREGOR';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491234567890';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'conor@mcgregor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();

        List<Account> accountList = [SELECT Id FROM Account];
        System.assertEquals(2, accountList.size(), 'Two Accounts are expected.');

        List<Opportunity> opportunityList = [SELECT Id FROM Opportunity];
        System.assertEquals(2, opportunityList.size(), 'Two Opportunities are expected.');

        List<Contact> contactList = [
                SELECT FirstName, LastName, Phone, Email, 
                    (SELECT Id FROM AccountContactRelations), 
                    (SELECT Id FROM OpportunityContactRoles)
                FROM Contact];
        System.assertEquals(2, contactList.get(0).AccountContactRelations.size(), 'Two Accounts are expected.');
        System.assertEquals(2, contactList.get(0).OpportunityContactRoles.size(), 'Two Opportunities are expected.');
        System.assertEquals(1, contactList.size(), 'One contact is expected.');
        System.assertEquals('CONOR', contactList.get(0).FirstName, 'Expected FirstName from form.');
        System.assertEquals('MCGREGOR', contactList.get(0).LastName, 'Expected LastName from form.');
        System.assertEquals('+491234567890', contactList.get(0).Phone, 'Expected Phone from form.');
        System.assertEquals('conor@mcgregor.com', contactList.get(0).Email, 'Expected Email from form.');
    }


    /*******************************************************************************
    *  Name            : insertDupConSamePhonePendingSalesDeposit()
    *  Summary         : Verify that two Contacts were merged when Phones are the same and Contact #1 has E2E Opportunity #1 in stage Pending Sales – Deposit
    *  ExpectedResult  : Two contacts were merged. E2E Account #2, E2E Opportuinty #2 were created. Direct Connections were changed to E2E records
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void insertDupConSamePhonePendingSalesDeposit() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Pending Sales – Deposit';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        controller = new LongFormController();
        controller.init();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'CONOR';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'MCGREGOR';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491234567890';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'conor@mcgregor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();

        List<Account> accountList = [SELECT Id FROM Account];
        System.assertEquals(2, accountList.size(), 'Two Accounts are expected.');

        List<Opportunity> opportunityList = [SELECT Id FROM Opportunity];
        System.assertEquals(2, opportunityList.size(), 'Two Opportunities are expected.');

        List<Contact> contactList = [
                SELECT FirstName, LastName, Phone, Email, 
                    (SELECT Id FROM AccountContactRelations), 
                    (SELECT Id FROM OpportunityContactRoles)
                FROM Contact];
        System.assertEquals(2, contactList.get(0).AccountContactRelations.size(), 'Two Accounts are expected.');
        System.assertEquals(2, contactList.get(0).OpportunityContactRoles.size(), 'Two Opportunities are expected.');
        System.assertEquals(1, contactList.size(), 'One contact is expected.');
        System.assertEquals('CONOR', contactList.get(0).FirstName, 'Expected FirstName from form.');
        System.assertEquals('MCGREGOR', contactList.get(0).LastName, 'Expected LastName from form.');
        System.assertEquals('+491234567890', contactList.get(0).Phone, 'Expected Phone from form.');
        System.assertEquals('conor@mcgregor.com', contactList.get(0).Email, 'Expected Email from form.');
    }


    /*******************************************************************************
    *  Name            : insertDupConSameNameEmailDomClosedLost()
    *  Summary         : Verify that two Contacts were merged when Name + Email Domain are the same and Contact #1 has E2E Opportunity #1 in stage Closed Lost
    *  ExpectedResult  : Two contacts were merged. E2E Account #2, E2E Opportuinty #2 were created. Direct Connections were changed to E2E records
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void insertDupConSameNameEmailDomClosedLost() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Closed Lost';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        controller = new LongFormController();
        controller.init();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHN';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SMITH';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491111111111';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'testAAA@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();

        List<Account> accountList = [SELECT Id FROM Account];
        System.assertEquals(2, accountList.size(), 'Two Accounts are expected.');

        List<Opportunity> opportunityList = [SELECT Id FROM Opportunity];
        System.assertEquals(2, opportunityList.size(), 'Two Opportunities are expected.');

        List<Contact> contactList = [
                SELECT FirstName, LastName, Phone, Email, 
                    (SELECT Id FROM AccountContactRelations), 
                    (SELECT Id FROM OpportunityContactRoles)
                FROM Contact];
        System.assertEquals(2, contactList.get(0).AccountContactRelations.size(), 'Two Accounts are expected.');
        System.assertEquals(2, contactList.get(0).OpportunityContactRoles.size(), 'Two Opportunities are expected.');
        System.assertEquals(1, contactList.size(), 'One contact is expected.');
        System.assertEquals('JOHN', contactList.get(0).FirstName, 'Expected FirstName from form.');
        System.assertEquals('SMITH', contactList.get(0).LastName, 'Expected LastName from form.');
        System.assertEquals('+491111111111', contactList.get(0).Phone, 'Expected Phone from form.');
        System.assertEquals('testaaa@fleetcor.com', contactList.get(0).Email, 'Expected Email from form.');
    }


    /*******************************************************************************
    *  Name            : insertDupConSameNameEmailDomClosedWon()
    *  Summary         : Verify that two Contacts were merged when Name + Email Domain are the same and Contact #1 has E2E Opportunity #1 in stage Closed Won
    *  ExpectedResult  : Two contacts were merged. E2E Account #2, E2E Opportuinty #2 were created. Direct Connections were changed to E2E records
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void insertDupConSameNameEmailDomClosedWon() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Closed Won';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        controller = new LongFormController();
        controller.init();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHN';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SMITH';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491111111111';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'testAAA@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();

        List<Account> accountList = [SELECT Id FROM Account];
        System.assertEquals(2, accountList.size(), 'Two Accounts are expected.');

        List<Opportunity> opportunityList = [SELECT Id FROM Opportunity];
        System.assertEquals(2, opportunityList.size(), 'Two Opportunities are expected.');

        List<Contact> contactList = [
                SELECT FirstName, LastName, Phone, Email, 
                    (SELECT Id FROM AccountContactRelations), 
                    (SELECT Id FROM OpportunityContactRoles)
                FROM Contact];
        System.assertEquals(2, contactList.get(0).AccountContactRelations.size(), 'Two Accounts are expected.');
        System.assertEquals(2, contactList.get(0).OpportunityContactRoles.size(), 'Two Opportunities are expected.');
        System.assertEquals(1, contactList.size(), 'One contact is expected.');
        System.assertEquals('JOHN', contactList.get(0).FirstName, 'Expected FirstName from form.');
        System.assertEquals('SMITH', contactList.get(0).LastName, 'Expected LastName from form.');
        System.assertEquals('+491111111111', contactList.get(0).Phone, 'Expected Phone from form.');
        System.assertEquals('testaaa@fleetcor.com', contactList.get(0).Email, 'Expected Email from form.');
    }


    /*******************************************************************************
    *  Name            : insertDupConSameNameEmailDomPendingSalesDeposit()
    *  Summary         : Verify that two Contacts were merged when Name + Email Domain are the same and Contact #1 has E2E Opportunity #1 in stage Pending Sales – Deposit
    *  ExpectedResult  : Two contacts were merged. E2E Account #2, E2E Opportuinty #2 were created. Direct Connections were changed to E2E records
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void insertDupConSameNameEmailDomPendingSalesDeposit() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Pending Sales – Deposit';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        controller = new LongFormController();
        controller.init();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHN';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SMITH';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491111111111';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'testAAA@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();

        List<Account> accountList = [SELECT Id FROM Account];
        System.assertEquals(2, accountList.size(), 'Two Accounts are expected.');

        List<Opportunity> opportunityList = [SELECT Id FROM Opportunity];
        System.assertEquals(2, opportunityList.size(), 'Two Opportunities are expected.');

        List<Contact> contactList = [
                SELECT FirstName, LastName, Phone, Email, 
                    (SELECT Id FROM AccountContactRelations), 
                    (SELECT Id FROM OpportunityContactRoles)
                FROM Contact];
        System.assertEquals(2, contactList.get(0).AccountContactRelations.size(), 'Two Accounts are expected.');
        System.assertEquals(2, contactList.get(0).OpportunityContactRoles.size(), 'Two Opportunities are expected.');
        System.assertEquals(1, contactList.size(), 'One contact is expected.');
        System.assertEquals('JOHN', contactList.get(0).FirstName, 'Expected FirstName from form.');
        System.assertEquals('SMITH', contactList.get(0).LastName, 'Expected LastName from form.');
        System.assertEquals('+491111111111', contactList.get(0).Phone, 'Expected Phone from form.');
        System.assertEquals('testaaa@fleetcor.com', contactList.get(0).Email, 'Expected Email from form.');
    }


    /*******************************************************************************
    *  Name            : insertDupConSameDataWithoutOpp()
    *  Summary         : Verify that two Contacts were merged when First Name + Last Name + Email + Phone are the same and Contact #1 has no E2E Opportunity
    *  ExpectedResult  : Two contacts were merged. E2E Account #2, E2E Opportuinty #2 were created. Direct Connections were changed to E2E records
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void insertDupConSameDataWithoutOpp() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        insert account;

        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        insert contact;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        controller = new LongFormController();
        controller.init();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHN';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SMITH';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491234567890';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'test@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();

        List<Account> accountList = [SELECT Id FROM Account];
        System.assertEquals(2, accountList.size(), 'Two Accounts are expected.');

        List<Opportunity> opportunityList = [SELECT Id FROM Opportunity];
        System.assertEquals(1, opportunityList.size(), 'One Opportunity is expected.');

        List<Contact> contactList = [
                SELECT FirstName, LastName, Phone, Email, 
                    (SELECT Id FROM AccountContactRelations), 
                    (SELECT Id FROM OpportunityContactRoles)
                FROM Contact];
        System.assertEquals(2, contactList.get(0).AccountContactRelations.size(), 'Two Accounts are expected.');
        System.assertEquals(1, contactList.get(0).OpportunityContactRoles.size(), 'One Opportunity is expected.');
        System.assertEquals(1, contactList.size(), 'One contact is expected.');
        System.assertEquals('JOHN', contactList.get(0).FirstName, 'Expected FirstName from form.');
        System.assertEquals('SMITH', contactList.get(0).LastName, 'Expected LastName from form.');
        System.assertEquals('+491234567890', contactList.get(0).Phone, 'Expected Phone from form.');
        System.assertEquals('test@fleetcor.com', contactList.get(0).Email, 'Expected Email from form.');
    }


    /*******************************************************************************
    *  Name            : insertDupConSameDataWithE2EOpp()
    *  Summary         : Verify that two Contacts were merged when First Name + Last Name + Email + Phone are the same 
                         and Contact #1 has E2E Opportunity #1 NOT in stage Closed Lost / Closed WON / Pending Sales - Deposit
    *  ExpectedResult  : Two contacts were merged. Form of the business is updated in Opportunity #1 User is redirected to last E2E step of the Opportunity #1
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void insertDupConSameDataWithE2EOpp() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Prospecting';
        opportunity.E2E_Active_Step__c = 1;
        opportunity.E2E_Active_Substep__c = 'Search company';
        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EForm');
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        controller = new LongFormController();
        controller.init();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHN';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SMITH';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491234567890';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'test@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();

        List<Account> accountList = [SELECT Id FROM Account];
        System.assertEquals(1, accountList.size(), 'One Account is expected.');

        List<Opportunity> opportunityList = [SELECT Id FROM Opportunity];
        System.assertEquals(1, opportunityList.size(), 'One Opportunity is expected.');

        List<Contact> contactList = [
                SELECT FirstName, LastName, Phone, Email, 
                    (SELECT Id FROM AccountContactRelations), 
                    (SELECT Id FROM OpportunityContactRoles)
                FROM Contact];
        System.assertEquals(1, contactList.get(0).AccountContactRelations.size(), 'One Account is expected.');
        System.assertEquals(1, contactList.get(0).OpportunityContactRoles.size(), 'One Opportunity is expected.');
        System.assertEquals(1, contactList.size(), 'One contact is expected.');
        System.assertEquals('JOHN', contactList.get(0).FirstName, 'Expected FirstName from form.');
        System.assertEquals('SMITH', contactList.get(0).LastName, 'Expected LastName from form.');
        System.assertEquals('+491234567890', contactList.get(0).Phone, 'Expected Phone from form.');
        System.assertEquals('test@fleetcor.com', contactList.get(0).Email, 'Expected Email from form.');
    }


    /*******************************************************************************
    *  Name            : insertDupConSameEmailWithE2EOpp()
    *  Summary         : Verify that two Contacts were merged when Emails are the same and 
                         Contact #1 has E2E Opportunity #1 in stage not equals to Closed Lost / Closed WON / Pending Sales - Deposit
    *  ExpectedResult  : Two contacts were merged. Form of the business is updated in Opportunity #1 User is redirected to last E2E step of the Opportunity #1
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void insertDupConSameEmailWithE2EOpp() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Prospecting';
        opportunity.E2E_Active_Step__c = 1;
        opportunity.E2E_Active_Substep__c = 'Search company';
        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EForm');
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        controller = new LongFormController();
        controller.init();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'CONOR';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'MCGREGOR';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491111111111';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'test@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();

        List<Account> accountList = [SELECT Id FROM Account];
        System.assertEquals(1, accountList.size(), 'One Account is expected.');

        List<Opportunity> opportunityList = [SELECT Id FROM Opportunity];
        System.assertEquals(1, opportunityList.size(), 'One Opportunity is expected.');

        List<Contact> contactList = [
                SELECT FirstName, LastName, Phone, Email, 
                    (SELECT Id FROM AccountContactRelations), 
                    (SELECT Id FROM OpportunityContactRoles)
                FROM Contact];
        System.assertEquals(1, contactList.get(0).AccountContactRelations.size(), 'One Account is expected.');
        System.assertEquals(1, contactList.get(0).OpportunityContactRoles.size(), 'One Opportunity is expected.');
        System.assertEquals(1, contactList.size(), 'One contact is expected.');
        System.assertEquals('CONOR', contactList.get(0).FirstName, 'Expected FirstName from form.');
        System.assertEquals('MCGREGOR', contactList.get(0).LastName, 'Expected LastName from form.');
        System.assertEquals('+491111111111', contactList.get(0).Phone, 'Expected Phone from form.');
        System.assertEquals('test@fleetcor.com', contactList.get(0).Email, 'Expected Email from form.');
    }


    /*******************************************************************************
    *  Name            : insertDupConSamePhoneWithE2EOpp()
    *  Summary         : Verify that two Contacts were merged when Phones are the same and 
                         Contact #1 has E2E Opportunity #1 in stage != Closed Lost / Closed WON / Pending Sales - Deposit
    *  ExpectedResult  : Two contacts were merged. Form of the business is updated in Opportunity #1 User is redirected to last E2E step of the Opportunity #1
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void insertDupConSamePhoneWithE2EOpp() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Prospecting';
        opportunity.E2E_Active_Step__c = 1;
        opportunity.E2E_Active_Substep__c = 'Search company';
        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EForm');
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        controller = new LongFormController();
        controller.init();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'CONOR';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'MCGREGOR';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491234567890';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'conor@mcgregor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();

        List<Account> accountList = [SELECT Id FROM Account];
        System.assertEquals(1, accountList.size(), 'One Account is expected.');

        List<Opportunity> opportunityList = [SELECT Id FROM Opportunity];
        System.assertEquals(1, opportunityList.size(), 'One Opportunity is expected.');

        List<Contact> contactList = [
                SELECT FirstName, LastName, Phone, Email, 
                    (SELECT Id FROM AccountContactRelations), 
                    (SELECT Id FROM OpportunityContactRoles)
                FROM Contact];
        System.assertEquals(1, contactList.get(0).AccountContactRelations.size(), 'One Account is expected.');
        System.assertEquals(1, contactList.get(0).OpportunityContactRoles.size(), 'One Opportunity is expected.');
        System.assertEquals(1, contactList.size(), 'One contact is expected.');
        System.assertEquals('CONOR', contactList.get(0).FirstName, 'Expected FirstName from form.');
        System.assertEquals('MCGREGOR', contactList.get(0).LastName, 'Expected LastName from form.');
        System.assertEquals('+491234567890', contactList.get(0).Phone, 'Expected Phone from form.');
        System.assertEquals('conor@mcgregor.com', contactList.get(0).Email, 'Expected Email from form.');
    }


    /*******************************************************************************
    *  Name            : insertDupConSameNameEmailDomWithE2EOpp()
    *  Summary         : Verify that two Contacts were merged when Name + Email Domaing are the same and 
                         Contact #1 has E2E Opportunity #1 in stage != Closed Lost / Closed WON / Pending Sales - Deposit
    *  ExpectedResult  : Two contacts were merged. Form of the business is updated in Opportunity #1 User is redirected to last E2E step of the Opportunity #1
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void insertDupConSameNameEmailDomWithE2EOpp() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Prospecting';
        opportunity.E2E_Active_Step__c = 1;
        opportunity.E2E_Active_Substep__c = 'Search company';
        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EForm');
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        controller = new LongFormController();
        controller.init();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHN';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SMITH';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491111111111';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'testAAA@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();

        List<Account> accountList = [SELECT Id FROM Account];
        System.assertEquals(1, accountList.size(), 'One Account is expected.');

        List<Opportunity> opportunityList = [SELECT Id FROM Opportunity];
        System.assertEquals(1, opportunityList.size(), 'One Opportunity is expected.');

        List<Contact> contactList = [
                SELECT FirstName, LastName, Phone, Email, 
                    (SELECT Id FROM AccountContactRelations), 
                    (SELECT Id FROM OpportunityContactRoles)
                FROM Contact];
        System.assertEquals(1, contactList.get(0).AccountContactRelations.size(), 'One Account is expected.');
        System.assertEquals(1, contactList.get(0).OpportunityContactRoles.size(), 'One Opportunity is expected.');
        System.assertEquals(1, contactList.size(), 'One contact is expected.');
        System.assertEquals('JOHN', contactList.get(0).FirstName, 'Expected FirstName from form.');
        System.assertEquals('SMITH', contactList.get(0).LastName, 'Expected LastName from form.');
        System.assertEquals('+491111111111', contactList.get(0).Phone, 'Expected Phone from form.');
        System.assertEquals('testaaa@fleetcor.com', contactList.get(0).Email, 'Expected Email from form.');
    }


    /*******************************************************************************
    *  Name            : insertDifferentContact()
    *  Summary         : Verify that two Contacts were NOT merged when First Name + Last Name + Phone + Email are NOT the same
    *  ExpectedResult  : Contact #2 was created separately of Contact #1.
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void insertDifferentContact() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Prospecting';
        opportunity.E2E_Active_Step__c = 1;
        opportunity.E2E_Active_Substep__c = 'Search company';
        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EForm');
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        controller = new LongFormController();
        controller.init();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHNA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SMITHA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+493333333333';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'testAAA@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();

        List<Account> accountList = [SELECT Id FROM Account];
        System.assertEquals(2, accountList.size(), 'Two Accounts are expected.');

        List<Opportunity> opportunityList = [SELECT Id FROM Opportunity];
        System.assertEquals(2, opportunityList.size(), 'Two Opportunities are expected.');

        List<Contact> contactList = [SELECT Id FROM Contact];
        System.assertEquals(2, contactList.size(), 'Two Contacts are expected.');

        List<Contact> secondCon = [SELECT FirstName, LastName, Phone, Email FROM Contact WHERE Id != :contact.Id];
        System.assertEquals(1, secondCon.size(), 'One Contact is expected');
        System.assertEquals('JOHNA', secondCon.get(0).FirstName, 'Expected FirstName from form.');
        System.assertEquals('SMITHA', secondCon.get(0).LastName, 'Expected LastName from form.');
        System.assertEquals('+493333333333', secondCon.get(0).Phone, 'Expected Phone from form.');
        System.assertEquals('testaaa@fleetcor.com', secondCon.get(0).Email, 'Expected Email from form.');
    }


    /*******************************************************************************
    *  Name            : findDupLeadWithSameData()
    *  Summary         : Verify that when Contact #2 and Lead #1 has the same First Name + Last Name + Email + Phone domain then Lead is disqualified 
    *  ExpectedResult  : E2E Contact #2 was created. Lead #1 Status = Disqualified Quali Status = Switched to E2E Notification was sent to the Lead Owner
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void findDupLeadWithSameData() {
        User e2eUser = E2ELongFormUtilsTest.createE2EDEUser();
        Database.insert(e2eUser);
        
        System.runAs(e2eUser) {
            Lead lead = E2ELongFormUtilsTest.createLeadForDuplicateDE();
            insert lead;

            ApexPages.currentPage().getparameters().put('country', 'Germany');
            controller = new LongFormController();
            controller.init();
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHN';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SMITH';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491234567890';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'test@fleetcor.com';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
            Test.startTest();
            controller.goToCreditScoring();
            Test.stopTest();

            List<Contact> contactList = [SELECT Id FROM Contact];
            System.assertEquals(1, contactList.size(), 'One Contact is expected.');

            List<Lead> leadList = [SELECT Status, Quali_Status__c FROM Lead];
            System.assertEquals('Disqualified', leadList.get(0).Status, 'Lead status should be Disqualified.');
            System.assertEquals('Switched to E2E', leadList.get(0).Quali_Status__c, 'Lead quali status should be Switched to E2E.');
        }
    }


    /*******************************************************************************
    *  Name            : findDupLeadWithSameEmail()
    *  Summary         : Verify that when Contact #2 and Lead #1 has the same Emails then Lead is disqualified 
    *  ExpectedResult  : E2E Contact #2 was created. Lead #1 Status = Disqualified Quali Status = Switched to E2E Notification was sent to the Lead Owner
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void findDupLeadWithSameEmail() {
        User e2eUser = E2ELongFormUtilsTest.createE2EDEUser();
        Database.insert(e2eUser);
        
        System.runAs(e2eUser) {
            Lead lead = E2ELongFormUtilsTest.createLeadForDuplicateDE();
            insert lead;

            ApexPages.currentPage().getparameters().put('country', 'Germany');
            controller = new LongFormController();
            controller.init();
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'CONOR';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'MCGREGOR';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491111111111';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'test@fleetcor.com';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
            Test.startTest();
            controller.goToCreditScoring();
            Test.stopTest();

            List<Contact> contactList = [SELECT Id FROM Contact];
            System.assertEquals(1, contactList.size(), 'One Contact is expected.');

            List<Lead> leadList = [SELECT Status, Quali_Status__c FROM Lead];
            System.assertEquals('Disqualified', leadList.get(0).Status, 'Lead status should be Disqualified.');
            System.assertEquals('Switched to E2E', leadList.get(0).Quali_Status__c, 'Lead quali status should be Switched to E2E.');
        }
    }


    /*******************************************************************************
    *  Name            : findDupLeadWithSamePhone()
    *  Summary         : Verify that when Contact #2 and Lead #1 has the same Phones then Lead is disqualified 
    *  ExpectedResult  : E2E Contact #2 was created. Lead #1 Status = Disqualified Quali Status = Switched to E2E Notification was sent to the Lead Owner
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void findDupLeadWithSamePhone() {
        User e2eUser = E2ELongFormUtilsTest.createE2EDEUser();
        Database.insert(e2eUser);
        
        System.runAs(e2eUser) {
            Lead lead = E2ELongFormUtilsTest.createLeadForDuplicateDE();
            insert lead;

            ApexPages.currentPage().getparameters().put('country', 'Germany');
            controller = new LongFormController();
            controller.init();
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'CONOR';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'MCGREGOR';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491234567890';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'conor@mcgregor.com';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
            Test.startTest();
            controller.goToCreditScoring();
            Test.stopTest();

            List<Contact> contactList = [SELECT Id FROM Contact];
            System.assertEquals(1, contactList.size(), 'One Contact is expected.');

            List<Lead> leadList = [SELECT Status, Quali_Status__c FROM Lead];
            System.assertEquals('Disqualified', leadList.get(0).Status, 'Lead status should be Disqualified.');
            System.assertEquals('Switched to E2E', leadList.get(0).Quali_Status__c, 'Lead quali status should be Switched to E2E.');
        }
    }


    /*******************************************************************************
    *  Name            : findDupLeadWithSameNameEmailDom()
    *  Summary         : Verify that when Contact #2 and Lead #1 has the same First Name + Last Name + Email Domain then Lead is disqualified
    *  ExpectedResult  : E2E Contact #2 was created. Lead #1 Status = Disqualified Quali Status = Switched to E2E Notification was sent to the Lead Owner
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void findDupLeadWithSameNameEmailDom() {
        User e2eUser = E2ELongFormUtilsTest.createE2EDEUser();
        Database.insert(e2eUser);
        
        System.runAs(e2eUser) {
            Lead lead = E2ELongFormUtilsTest.createLeadForDuplicateDE();
            insert lead;

            ApexPages.currentPage().getparameters().put('country', 'Germany');
            controller = new LongFormController();
            controller.init();
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHN';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SMITH';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491111111111';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'test123@fleetcor.com';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
            Test.startTest();
            controller.goToCreditScoring();
            Test.stopTest();

            List<Contact> contactList = [SELECT Id FROM Contact];
            System.assertEquals(1, contactList.size(), 'One Contact is expected.');

            List<Lead> leadList = [SELECT Status, Quali_Status__c FROM Lead];
            System.assertEquals('Disqualified', leadList.get(0).Status, 'Lead status should be Disqualified.');
            System.assertEquals('Switched to E2E', leadList.get(0).Quali_Status__c, 'Lead quali status should be Switched to E2E.');
        }
    }


    /*******************************************************************************
    *  Name            : findDupLeadWithSameDataDisqualified()
    *  Summary         : Verify that when Contact #2 and Lead #1 are the same and Lead Status = Disqualified then Lead #1 stays in Status = Disqualified
    *  ExpectedResult  : New Contact was created. Lead #1 stays in Status = Disqualified
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void findDupLeadWithSameDataDisqualified() {
        Test.startTest();
            User e2eUser = E2ELongFormUtilsTest.createE2EDEUser();
            Database.insert(e2eUser);
        Test.stopTest();

        System.runAs(e2eUser) {

            Lead lead = E2ELongFormUtilsTest.createLeadForDuplicateDE();
            lead.Status = 'Disqualified';
            insert lead;

            ApexPages.currentPage().getparameters().put('country', 'Germany');
            controller = new LongFormController();
            controller.init();
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHN';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SMITH';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491234567890';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'test@fleetcor.com';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
            controller.goToCreditScoring();

            List<Contact> contactList = [SELECT Id FROM Contact];
            System.assertEquals(1, contactList.size(), 'One Contact is expected.');

            List<Lead> leadList = [SELECT Status, Quali_Status__c FROM Lead];
            System.assertEquals('Disqualified', leadList.get(0).Status, 'Lead status should be Disqualified.');

        }
    }


    /*******************************************************************************
    *  Name            : updateContactPrivateEntity()
    *  Summary         : Verify that #1 Opportunity is updated when Private Entity option was selected
    *  ExpectedResult  : Opportunity #1 Stage = Closed Lost Opportunity #1 E2E Errors = Private entity Reasonlost = Not a legal Entity
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void updateContactPrivateEntity() {
        ApexPages.currentPage().getparameters().put('country', 'Germany');
        controller = new LongFormController();
        controller.init();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHN';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SMITH';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491234567890';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'test@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();
        // back button to choose Private Entity
        controller.goToContactDetails();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Martina';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Muck KTO';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+493811698111';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'jrogers@burlington.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Private';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();

        List<Opportunity> opportunityList = [SELECT StageName, Gruende_verloren__c, E2E_Errors__c FROM Opportunity];
        System.assertEquals('Closed Lost', opportunityList.get(0).StageName, 'Opportunity StageName should be Closed Lost.');
        System.assertEquals('Not a legal entity', opportunityList.get(0).Gruende_verloren__c, 'Opportunity Reason Lost should be Not a legal entity.');
        System.assertEquals('Private entity', opportunityList.get(0).E2E_Errors__c, 'Opportunity Errors should be Private entity.');
    }


    /*******************************************************************************
    *  Name            : updateDupConSameDataClosedLost()
    *  Summary         : Verify that two Contacts were merged when First Name + Last Name + Email + Phone are the same and Contact #1 has E2E Opportunity #1 in stage Closed Lost
    *  ExpectedResult  : E2E Opportunity #2 Stage = Closed Lost. Reason = Duplicate. E2E Account #2, E2E Contact #2 were NOT deleted.
                         Contacts were merged. New E2E Account #3, New E2E Opportunity #3 were created. Direct Connections were changed to E2E records
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void updateDupConSameDataClosedLost() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Closed Lost';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        controller = new LongFormController();
        controller.init();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JohnAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SmithAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491111111111';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'testAA@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();
        // back button to update data
        controller.goToContactDetails();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHN';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SMITH';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491234567890';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'test@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();

        List<Account> accountList = [SELECT Id FROM Account];
        System.assertEquals(3, accountList.size(), 'Three Accounts are expected.');

        List<Opportunity> opportunityList = [SELECT Id FROM Opportunity];
        System.assertEquals(3, opportunityList.size(), 'Three Opportunities are expected.');

        List<Contact> contactList = [
                SELECT FirstName, LastName, Phone, Email, 
                    (SELECT Id FROM AccountContactRelations), 
                    (SELECT Id FROM OpportunityContactRoles)
                FROM Contact
                WHERE Id = :contact.Id];
        System.assertEquals(2, contactList.get(0).AccountContactRelations.size(), 'Two Accounts are expected.');
        System.assertEquals(2, contactList.get(0).OpportunityContactRoles.size(), 'Two Opportunities are expected.');
        System.assertEquals(1, contactList.size(), 'One Contact is expected.');
        System.assertEquals('JOHN', contactList.get(0).FirstName, 'Expected FirstName from form.');
        System.assertEquals('SMITH', contactList.get(0).LastName, 'Expected LastName from form.');
        System.assertEquals('+491234567890', contactList.get(0).Phone, 'Expected Phone from form.');
        System.assertEquals('test@fleetcor.com', contactList.get(0).Email, 'Expected Email from form.');
    }


    /*******************************************************************************
    *  Name            : updateDupConSameDataClosedWon()
    *  Summary         : Verify that two Contacts were merged when First Name + Last Name + Email + Phone are the same and Contact #1 has E2E Opportunity #1 in stage Closed Won
    *  ExpectedResult  : E2E Opportunity #2 Stage = Closed Lost. Reason = Duplicate. E2E Account #2, E2E Contact #2 were NOT deleted.
                         Contacts were merged. New E2E Account #3, New E2E Opportunity #3 were created. Direct Connections were changed to E2E records
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void updateDupConSameDataClosedWon() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Closed Won';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        controller = new LongFormController();
        controller.init();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JohnAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SmithAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491111111111';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'testAA@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();
        // back button to update data
        controller.goToContactDetails();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHN';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SMITH';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491234567890';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'test@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();

        List<Account> accountList = [SELECT Id FROM Account];
        System.assertEquals(3, accountList.size(), 'Three Accounts are expected.');

        List<Opportunity> opportunityList = [SELECT Id FROM Opportunity];
        System.assertEquals(3, opportunityList.size(), 'Three Opportunities are expected.');

        List<Contact> contactList = [
                SELECT FirstName, LastName, Phone, Email, 
                    (SELECT Id FROM AccountContactRelations), 
                    (SELECT Id FROM OpportunityContactRoles)
                FROM Contact
                WHERE Id = :contact.Id];
        System.assertEquals(2, contactList.get(0).AccountContactRelations.size(), 'Two Accounts are expected.');
        System.assertEquals(2, contactList.get(0).OpportunityContactRoles.size(), 'Two Opportunities are expected.');
        System.assertEquals(1, contactList.size(), 'One Contact is expected.');
        System.assertEquals('JOHN', contactList.get(0).FirstName, 'Expected FirstName from form.');
        System.assertEquals('SMITH', contactList.get(0).LastName, 'Expected LastName from form.');
        System.assertEquals('+491234567890', contactList.get(0).Phone, 'Expected Phone from form.');
        System.assertEquals('test@fleetcor.com', contactList.get(0).Email, 'Expected Email from form.');
    }


    /*******************************************************************************
    *  Name            : updateDupConSameDataPendingSalesDeposit()
    *  Summary         : Verify that two Contacts were merged when First Name + Last Name + Email + Phone are the same and Contact #1 has E2E Opportunity #1 in stage Pending Sales - Deposit
    *  ExpectedResult  : E2E Opportunity #2 Stage = Closed Lost. Reason = Duplicate. E2E Account #2, E2E Contact #2 were NOT deleted.
                         Contacts were merged. New E2E Account #3, New E2E Opportunity #3 were created. Direct Connections were changed to E2E records
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void updateDupConSameDataPendingSalesDeposit() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Pending Sales – Deposit';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        controller = new LongFormController();
        controller.init();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JohnAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SmithAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491111111111';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'testAA@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();
        // back button to update data
        controller.goToContactDetails();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHN';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SMITH';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491234567890';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'test@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();

        List<Account> accountList = [SELECT Id FROM Account];
        System.assertEquals(3, accountList.size(), 'Three Accounts are expected.');

        List<Opportunity> opportunityList = [SELECT Id FROM Opportunity];
        System.assertEquals(3, opportunityList.size(), 'Three Opportunities are expected.');

        List<Contact> contactList = [
                SELECT FirstName, LastName, Phone, Email, 
                    (SELECT Id FROM AccountContactRelations), 
                    (SELECT Id FROM OpportunityContactRoles)
                FROM Contact
                WHERE Id = :contact.Id];
        System.assertEquals(2, contactList.get(0).AccountContactRelations.size(), 'Two Accounts are expected.');
        System.assertEquals(2, contactList.get(0).OpportunityContactRoles.size(), 'Two Opportunities are expected.');
        System.assertEquals(1, contactList.size(), 'One Contact is expected.');
        System.assertEquals('JOHN', contactList.get(0).FirstName, 'Expected FirstName from form.');
        System.assertEquals('SMITH', contactList.get(0).LastName, 'Expected LastName from form.');
        System.assertEquals('+491234567890', contactList.get(0).Phone, 'Expected Phone from form.');
        System.assertEquals('test@fleetcor.com', contactList.get(0).Email, 'Expected Email from form.');
    }


    /*******************************************************************************
    *  Name            : updateDupConSameEmailClosedLost()
    *  Summary         : Verify that two Contacts were merged when Emails are the same and Contact #1 has E2E Opportunity #1 in stage Closed Lost
    *  ExpectedResult  : E2E Opportunity #2 Stage = Closed Lost. Reason = Duplicate. E2E Account #2, E2E Contact #2 were NOT deleted.
                         Contacts were merged. New E2E Account #3, New E2E Opportunity #3 were created. Direct Connections were changed to E2E records
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void updateDupConSameEmailClosedLost() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Closed Lost';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        controller = new LongFormController();
        controller.init();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JohnAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SmithAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491111111111';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'testAA@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();
        // back button to update data
        controller.goToContactDetails();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JohnAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SmithAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491111111111';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'test@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();

        List<Account> accountList = [SELECT Id FROM Account];
        System.assertEquals(3, accountList.size(), 'Three Accounts are expected.');

        List<Opportunity> opportunityList = [SELECT Id FROM Opportunity];
        System.assertEquals(3, opportunityList.size(), 'Three Opportunities are expected.');

        List<Contact> contactList = [
                SELECT FirstName, LastName, Phone, Email, 
                    (SELECT Id FROM AccountContactRelations), 
                    (SELECT Id FROM OpportunityContactRoles)
                FROM Contact
                WHERE Id = :contact.Id];
        System.assertEquals(2, contactList.get(0).AccountContactRelations.size(), 'Two Accounts are expected.');
        System.assertEquals(2, contactList.get(0).OpportunityContactRoles.size(), 'Two Opportunities are expected.');
        System.assertEquals(1, contactList.size(), 'One Contact is expected.');
        System.assertEquals('JOHNAA', contactList.get(0).FirstName, 'Expected FirstName from form.');
        System.assertEquals('SMITHAA', contactList.get(0).LastName, 'Expected LastName from form.');
        System.assertEquals('+491111111111', contactList.get(0).Phone, 'Expected Phone from form.');
        System.assertEquals('test@fleetcor.com', contactList.get(0).Email, 'Expected Email from form.');
    }


    /*******************************************************************************
    *  Name            : updateDupConSameEmailClosedWon()
    *  Summary         : Verify that two Contacts were merged when Emails are the same and Contact #1 has E2E Opportunity #1 in stage Closed Won
    *  ExpectedResult  : E2E Opportunity #2 Stage = Closed Lost. Reason = Duplicate. E2E Account #2, E2E Contact #2 were NOT deleted.
                         Contacts were merged. New E2E Account #3, New E2E Opportunity #3 were created. Direct Connections were changed to E2E records
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void updateDupConSameEmailClosedWon() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Closed Won';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        controller = new LongFormController();
        controller.init();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JohnAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SmithAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491111111111';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'testAA@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();
        // back button to update data
        controller.goToContactDetails();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JohnAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SmithAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491111111111';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'test@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();

        List<Account> accountList = [SELECT Id FROM Account];
        System.assertEquals(3, accountList.size(), 'Three Accounts are expected.');

        List<Opportunity> opportunityList = [SELECT Id FROM Opportunity];
        System.assertEquals(3, opportunityList.size(), 'Three Opportunities are expected.');

        List<Contact> contactList = [
                SELECT FirstName, LastName, Phone, Email, 
                    (SELECT Id FROM AccountContactRelations), 
                    (SELECT Id FROM OpportunityContactRoles)
                FROM Contact
                WHERE Id = :contact.Id];
        System.assertEquals(2, contactList.get(0).AccountContactRelations.size(), 'Two Accounts are expected.');
        System.assertEquals(2, contactList.get(0).OpportunityContactRoles.size(), 'Two Opportunities are expected.');
        System.assertEquals(1, contactList.size(), 'One Contact is expected.');
        System.assertEquals('JOHNAA', contactList.get(0).FirstName, 'Expected FirstName from form.');
        System.assertEquals('SMITHAA', contactList.get(0).LastName, 'Expected LastName from form.');
        System.assertEquals('+491111111111', contactList.get(0).Phone, 'Expected Phone from form.');
        System.assertEquals('test@fleetcor.com', contactList.get(0).Email, 'Expected Email from form.');
    }


    /*******************************************************************************
    *  Name            : updateDupConSameEmailPendingSalesDeposit()
    *  Summary         : Verify that two Contacts were merged when Emails are the same and Contact #1 has E2E Opportunity #1 in stage Pending Sales – Deposit
    *  ExpectedResult  : E2E Opportunity #2 Stage = Closed Lost. Reason = Duplicate. E2E Account #2, E2E Contact #2 were NOT deleted.
                         Contacts were merged. New E2E Account #3, New E2E Opportunity #3 were created. Direct Connections were changed to E2E records
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void updateDupConSameEmailPendingSalesDeposit() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Pending Sales – Deposit';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        controller = new LongFormController();
        controller.init();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JohnAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SmithAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491111111111';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'testAA@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();
        // back button to update data
        controller.goToContactDetails();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JohnAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SmithAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491111111111';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'test@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();

        List<Account> accountList = [SELECT Id FROM Account];
        System.assertEquals(3, accountList.size(), 'Three Accounts are expected.');

        List<Opportunity> opportunityList = [SELECT Id FROM Opportunity];
        System.assertEquals(3, opportunityList.size(), 'Three Opportunities are expected.');

        List<Contact> contactList = [
                SELECT FirstName, LastName, Phone, Email, 
                    (SELECT Id FROM AccountContactRelations), 
                    (SELECT Id FROM OpportunityContactRoles)
                FROM Contact
                WHERE Id = :contact.Id];
        System.assertEquals(2, contactList.get(0).AccountContactRelations.size(), 'Two Accounts are expected.');
        System.assertEquals(2, contactList.get(0).OpportunityContactRoles.size(), 'Two Opportunities are expected.');
        System.assertEquals(1, contactList.size(), 'One Contact is expected.');
        System.assertEquals('JOHNAA', contactList.get(0).FirstName, 'Expected FirstName from form.');
        System.assertEquals('SMITHAA', contactList.get(0).LastName, 'Expected LastName from form.');
        System.assertEquals('+491111111111', contactList.get(0).Phone, 'Expected Phone from form.');
        System.assertEquals('test@fleetcor.com', contactList.get(0).Email, 'Expected Email from form.');
    }


    /*******************************************************************************
    *  Name            : updateDupConSamePhoneClosedLost()
    *  Summary         : Verify that two Contacts were merged when Phones are the same and Contact #1 has E2E Opportunity #1 in stage Closed Lost
    *  ExpectedResult  : E2E Opportunity #2 Stage = Closed Lost. Reason = Duplicate. E2E Account #2, E2E Contact #2 were NOT deleted.
                         Contacts were merged. New E2E Account #3, New E2E Opportunity #3 were created. Direct Connections were changed to E2E records
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void updateDupConSamePhoneClosedLost() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Closed Lost';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        controller = new LongFormController();
        controller.init();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JohnAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SmithAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491111111111';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'testAA@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();
        // back button to update data
        controller.goToContactDetails();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JohnAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SmithAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491234567890';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'testAA@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();

        List<Account> accountList = [SELECT Id FROM Account];
        System.assertEquals(3, accountList.size(), 'Three Accounts are expected.');

        List<Opportunity> opportunityList = [SELECT Id FROM Opportunity];
        System.assertEquals(3, opportunityList.size(), 'Three Opportunities are expected.');

        List<Contact> contactList = [
                SELECT FirstName, LastName, Phone, Email, 
                    (SELECT Id FROM AccountContactRelations), 
                    (SELECT Id FROM OpportunityContactRoles)
                FROM Contact
                WHERE Id = :contact.Id];
        System.assertEquals(2, contactList.get(0).AccountContactRelations.size(), 'Two Accounts are expected.');
        System.assertEquals(2, contactList.get(0).OpportunityContactRoles.size(), 'Two Opportunities are expected.');
        System.assertEquals(1, contactList.size(), 'One Contact is expected.');
        System.assertEquals('JOHNAA', contactList.get(0).FirstName, 'Expected FirstName from form.');
        System.assertEquals('SMITHAA', contactList.get(0).LastName, 'Expected LastName from form.');
        System.assertEquals('+491234567890', contactList.get(0).Phone, 'Expected Phone from form.');
        System.assertEquals('testaa@fleetcor.com', contactList.get(0).Email, 'Expected Email from form.');
    }


    /*******************************************************************************
    *  Name            : updateDupConSamePhoneClosedWon()
    *  Summary         : Verify that two Contacts were merged when Phones are the same and Contact #1 has E2E Opportunity #1 in stage Closed Won
    *  ExpectedResult  : E2E Opportunity #2 Stage = Closed Lost. Reason = Duplicate. E2E Account #2, E2E Contact #2 were NOT deleted.
                         Contacts were merged. New E2E Account #3, New E2E Opportunity #3 were created. Direct Connections were changed to E2E records
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void updateDupConSamePhoneClosedWon() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Closed Won';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        controller = new LongFormController();
        controller.init();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JohnAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SmithAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491111111111';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'testAA@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();
        // back button to update data
        controller.goToContactDetails();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JohnAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SmithAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491234567890';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'testAA@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();

        List<Account> accountList = [SELECT Id FROM Account];
        System.assertEquals(3, accountList.size(), 'Three Accounts are expected.');

        List<Opportunity> opportunityList = [SELECT Id FROM Opportunity];
        System.assertEquals(3, opportunityList.size(), 'Three Opportunities are expected.');

        List<Contact> contactList = [
                SELECT FirstName, LastName, Phone, Email, 
                    (SELECT Id FROM AccountContactRelations), 
                    (SELECT Id FROM OpportunityContactRoles)
                FROM Contact
                WHERE Id = :contact.Id];
        System.assertEquals(2, contactList.get(0).AccountContactRelations.size(), 'Two Accounts are expected.');
        System.assertEquals(2, contactList.get(0).OpportunityContactRoles.size(), 'Two Opportunities are expected.');
        System.assertEquals(1, contactList.size(), 'One Contact is expected.');
        System.assertEquals('JOHNAA', contactList.get(0).FirstName, 'Expected FirstName from form.');
        System.assertEquals('SMITHAA', contactList.get(0).LastName, 'Expected LastName from form.');
        System.assertEquals('+491234567890', contactList.get(0).Phone, 'Expected Phone from form.');
        System.assertEquals('testaa@fleetcor.com', contactList.get(0).Email, 'Expected Email from form.');
    }


    /*******************************************************************************
    *  Name            : updateDupConSamePhonePendingSalesDeposit()
    *  Summary         : Verify that two Contacts were merged when Phones are the same and Contact #1 has E2E Opportunity #1 in stage Pending Sales – Deposit
    *  ExpectedResult  : E2E Opportunity #2 Stage = Closed Lost. Reason = Duplicate. E2E Account #2, E2E Contact #2 were NOT deleted.
                         Contacts were merged. New E2E Account #3, New E2E Opportunity #3 were created. Direct Connections were changed to E2E records
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void updateDupConSamePhonePendingSalesDeposit() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Pending Sales – Deposit';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        controller = new LongFormController();
        controller.init();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JohnAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SmithAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491111111111';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'testAA@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();
        // back button to update data
        controller.goToContactDetails();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JohnAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SmithAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491234567890';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'testAA@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();

        List<Account> accountList = [SELECT Id FROM Account];
        System.assertEquals(3, accountList.size(), 'Three Accounts are expected.');

        List<Opportunity> opportunityList = [SELECT Id FROM Opportunity];
        System.assertEquals(3, opportunityList.size(), 'Three Opportunities are expected.');

        List<Contact> contactList = [
                SELECT FirstName, LastName, Phone, Email, 
                    (SELECT Id FROM AccountContactRelations), 
                    (SELECT Id FROM OpportunityContactRoles)
                FROM Contact
                WHERE Id = :contact.Id];
        System.assertEquals(2, contactList.get(0).AccountContactRelations.size(), 'Two Accounts are expected.');
        System.assertEquals(2, contactList.get(0).OpportunityContactRoles.size(), 'Two Opportunities are expected.');
        System.assertEquals(1, contactList.size(), 'One Contact is expected.');
        System.assertEquals('JOHNAA', contactList.get(0).FirstName, 'Expected FirstName from form.');
        System.assertEquals('SMITHAA', contactList.get(0).LastName, 'Expected LastName from form.');
        System.assertEquals('+491234567890', contactList.get(0).Phone, 'Expected Phone from form.');
        System.assertEquals('testaa@fleetcor.com', contactList.get(0).Email, 'Expected Email from form.');
    }


    /*******************************************************************************
    *  Name            : updateDupConSameNameEmailDomClosedLost()
    *  Summary         : Verify that two Contacts were merged when Name + Email Domain are the same and Contact #1 has E2E Opportunity #1 in stage Closed Lost
    *  ExpectedResult  : E2E Opportunity #2 Stage = Closed Lost. Reason = Duplicate. E2E Account #2, E2E Contact #2 were NOT deleted.
                         Contacts were merged. New E2E Account #3, New E2E Opportunity #3 were created. Direct Connections were changed to E2E records
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void updateDupConSameNameEmailDomClosedLost() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Closed Lost';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        controller = new LongFormController();
        controller.init();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JohnAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SmithAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491111111111';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'testAA@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();
        // back button to update data
        controller.goToContactDetails();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHN';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SMITH';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491111111111';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'testAA@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();

        List<Account> accountList = [SELECT Id FROM Account];
        System.assertEquals(3, accountList.size(), 'Three Accounts are expected.');

        List<Opportunity> opportunityList = [SELECT Id FROM Opportunity];
        System.assertEquals(3, opportunityList.size(), 'Three Opportunities are expected.');

        List<Contact> contactList = [
                SELECT FirstName, LastName, Phone, Email, 
                    (SELECT Id FROM AccountContactRelations), 
                    (SELECT Id FROM OpportunityContactRoles)
                FROM Contact
                WHERE Id = :contact.Id];
        System.assertEquals(2, contactList.get(0).AccountContactRelations.size(), 'Two Accounts are expected.');
        System.assertEquals(2, contactList.get(0).OpportunityContactRoles.size(), 'Two Opportunities are expected.');
        System.assertEquals(1, contactList.size(), 'One Contact is expected.');
        System.assertEquals('JOHN', contactList.get(0).FirstName, 'Expected FirstName from form.');
        System.assertEquals('SMITH', contactList.get(0).LastName, 'Expected LastName from form.');
        System.assertEquals('+491111111111', contactList.get(0).Phone, 'Expected Phone from form.');
        System.assertEquals('testaa@fleetcor.com', contactList.get(0).Email, 'Expected Email from form.');
    }


    /*******************************************************************************
    *  Name            : updateDupConSameNameEmailDomClosedWon()
    *  Summary         : Verify that two Contacts were merged when Name + Email Domain are the same and Contact #1 has E2E Opportunity #1 in stage Closed Won
    *  ExpectedResult  : E2E Opportunity #2 Stage = Closed Lost. Reason = Duplicate. E2E Account #2, E2E Contact #2 were NOT deleted.
                         Contacts were merged. New E2E Account #3, New E2E Opportunity #3 were created. Direct Connections were changed to E2E records
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void updateDupConSameNameEmailDomClosedWon() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Closed Won';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        controller = new LongFormController();
        controller.init();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JohnAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SmithAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491111111111';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'testAA@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();
        // back button to update data
        controller.goToContactDetails();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHN';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SMITH';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491111111111';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'testAA@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();

        List<Account> accountList = [SELECT Id FROM Account];
        System.assertEquals(3, accountList.size(), 'Three Accounts are expected.');

        List<Opportunity> opportunityList = [SELECT Id FROM Opportunity];
        System.assertEquals(3, opportunityList.size(), 'Three Opportunities are expected.');

        List<Contact> contactList = [
                SELECT FirstName, LastName, Phone, Email, 
                    (SELECT Id FROM AccountContactRelations), 
                    (SELECT Id FROM OpportunityContactRoles)
                FROM Contact
                WHERE Id = :contact.Id];
        System.assertEquals(2, contactList.get(0).AccountContactRelations.size(), 'Two Accounts are expected.');
        System.assertEquals(2, contactList.get(0).OpportunityContactRoles.size(), 'Two Opportunities are expected.');
        System.assertEquals(1, contactList.size(), 'One Contact is expected.');
        System.assertEquals('JOHN', contactList.get(0).FirstName, 'Expected FirstName from form.');
        System.assertEquals('SMITH', contactList.get(0).LastName, 'Expected LastName from form.');
        System.assertEquals('+491111111111', contactList.get(0).Phone, 'Expected Phone from form.');
        System.assertEquals('testaa@fleetcor.com', contactList.get(0).Email, 'Expected Email from form.');
    }


    /*******************************************************************************
    *  Name            : updateDupConSameNameEmailDomPendingSalesDeposit()
    *  Summary         : Verify that two Contacts were merged when Name + Email Domain are the same and Contact #1 has E2E Opportunity #1 in stage Pending Sales – Deposit
    *  ExpectedResult  : E2E Opportunity #2 Stage = Closed Lost. Reason = Duplicate. E2E Account #2, E2E Contact #2 were NOT deleted.
                         Contacts were merged. New E2E Account #3, New E2E Opportunity #3 were created. Direct Connections were changed to E2E records
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void updateDupConSameNameEmailDomPendingSalesDeposit() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Pending Sales – Deposit';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        controller = new LongFormController();
        controller.init();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JohnAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SmithAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491111111111';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'testAA@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();
        // back button to update data
        controller.goToContactDetails();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHN';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SMITH';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491111111111';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'testAA@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();

        List<Account> accountList = [SELECT Id FROM Account];
        System.assertEquals(3, accountList.size(), 'Three Accounts are expected.');

        List<Opportunity> opportunityList = [SELECT Id FROM Opportunity];
        System.assertEquals(3, opportunityList.size(), 'Three Opportunities are expected.');

        List<Contact> contactList = [
                SELECT FirstName, LastName, Phone, Email, 
                    (SELECT Id FROM AccountContactRelations), 
                    (SELECT Id FROM OpportunityContactRoles)
                FROM Contact
                WHERE Id = :contact.Id];
        System.assertEquals(2, contactList.get(0).AccountContactRelations.size(), 'Two Accounts are expected.');
        System.assertEquals(2, contactList.get(0).OpportunityContactRoles.size(), 'Two Opportunities are expected.');
        System.assertEquals(1, contactList.size(), 'One Contact is expected.');
        System.assertEquals('JOHN', contactList.get(0).FirstName, 'Expected FirstName from form.');
        System.assertEquals('SMITH', contactList.get(0).LastName, 'Expected LastName from form.');
        System.assertEquals('+491111111111', contactList.get(0).Phone, 'Expected Phone from form.');
        System.assertEquals('testaa@fleetcor.com', contactList.get(0).Email, 'Expected Email from form.');
    }


    /*******************************************************************************
    *  Name            : updateDupConWithoutE2EOpp()
    *  Summary         : Verify that two Contacts were merged when First Name + Last Name + Email + Phone are the same and Contact #1 has no E2E Opportunity
    *  ExpectedResult  : E2E Opportunity #2 Stage = Closed Lost. Reason = Duplicate. E2E Account #2, E2E Contact #2 were NOT deleted.
                         Contacts were merged. New E2E Account #3, New E2E Opportunity #3 were created. Direct Connections were changed to E2E records
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void updateDupConWithoutE2EOpp() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        insert account;

        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        insert contact;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        controller = new LongFormController();
        controller.init();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JohnAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SmithAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491111111111';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'testAA@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();
        // back button to update data
        controller.goToContactDetails();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHN';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SMITH';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491234567890';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'test@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();

        List<Account> accountList = [SELECT Id FROM Account];
        System.assertEquals(3, accountList.size(), 'Three Accounts are expected.');

        List<Opportunity> opportunityList = [SELECT Id FROM Opportunity];
        System.assertEquals(2, opportunityList.size(), 'Two Opportunities are expected.');

        List<Contact> contactList = [
                SELECT FirstName, LastName, Phone, Email, 
                    (SELECT Id FROM AccountContactRelations), 
                    (SELECT Id FROM OpportunityContactRoles)
                FROM Contact
                WHERE Id = :contact.Id];
        System.assertEquals(2, contactList.get(0).AccountContactRelations.size(), 'Two Accounts are expected.');
        System.assertEquals(1, contactList.get(0).OpportunityContactRoles.size(), 'One Opportunity is expected.');
        System.assertEquals(1, contactList.size(), 'One Contact is expected.');
        System.assertEquals('JOHN', contactList.get(0).FirstName, 'Expected FirstName from form.');
        System.assertEquals('SMITH', contactList.get(0).LastName, 'Expected LastName from form.');
        System.assertEquals('+491234567890', contactList.get(0).Phone, 'Expected Phone from form.');
        System.assertEquals('test@fleetcor.com', contactList.get(0).Email, 'Expected Email from form.');
    }


    /*******************************************************************************
    *  Name            : updateDupConSameDataProspecting()
    *  Summary         : Verify that two Contacts were merged when First Name + Last Name + Email + Phone are the same and 
                         Contact #1 has E2E Opportunity #1 NOT in stage Closed Lost / Closed WON / Pending Sales - Deposit
    *  ExpectedResult  : E2E Opportunity #2 Stage = Closed Lost. Reason = Duplicate. E2E Account #2, E2E Contact #2 were NOT deleted. Contacts were merged. 
                         User is redirected to the last E2E step of the Opportunity #1
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void updateDupConSameDataProspecting() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Prospecting';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        controller = new LongFormController();
        controller.init();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JohnAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SmithAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491111111111';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'testAA@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();
        // back button to update data
        controller.goToContactDetails();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHN';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SMITH';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491234567890';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'test@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();

        List<Account> accountList = [SELECT Id FROM Account];
        System.assertEquals(2, accountList.size(), 'Two Accounts are expected.');

        List<Opportunity> opportunityList = [SELECT Id FROM Opportunity];
        System.assertEquals(2, opportunityList.size(), 'Two Opportunities are expected.');

        List<Opportunity> opportunityDupList = [SELECT StageName FROM Opportunity WHERE Id != :opportunity.Id];
        System.assertEquals('Closed Lost', opportunityDupList.get(0).StageName, 'Duplicate Opportunity from form should be switched to Closed Lost.');

        List<Contact> contactList = [
                SELECT FirstName, LastName, Phone, Email, 
                    (SELECT Id FROM AccountContactRelations), 
                    (SELECT Opportunity.StageName FROM OpportunityContactRoles)
                FROM Contact
                WHERE Id = :contact.Id];
        System.assertEquals(1, contactList.get(0).AccountContactRelations.size(), 'One Account is expected.');
        System.assertEquals(1, contactList.get(0).OpportunityContactRoles.size(), 'One Opportunity is expected.');
        System.assertEquals('Prospecting', contactList.get(0).OpportunityContactRoles.get(0).Opportunity.StageName, 'StageName should be Prospecting');
        System.assertEquals(1, contactList.size(), 'One Contact is expected.');
        System.assertEquals('JOHN', contactList.get(0).FirstName, 'Expected FirstName from form.');
        System.assertEquals('SMITH', contactList.get(0).LastName, 'Expected LastName from form.');
        System.assertEquals('+491234567890', contactList.get(0).Phone, 'Expected Phone from form.');
        System.assertEquals('test@fleetcor.com', contactList.get(0).Email, 'Expected Email from form.');
    }


    /*******************************************************************************
    *  Name            : updateDupConSameEmailProspecting()
    *  Summary         : Verify that two Contacts were merged when Emails are the same and Contact #1 has E2E Opportunity #1 in stage Closed Lost / Closed WON / Pending Sales - Deposit
    *  ExpectedResult  : E2E Opportunity #2 Stage = Closed Lost. Reason = Duplicate. E2E Account #2, E2E Contact #2 were NOT deleted. Contacts were merged. 
                         User is redirected to the last E2E step of the Opportunity #1
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void updateDupConSameEmailProspecting() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Prospecting';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        controller = new LongFormController();
        controller.init();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JohnAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SmithAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491111111111';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'testAA@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();
        // back button to update data
        controller.goToContactDetails();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JohnAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SmithAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491111111111';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'test@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();

        List<Account> accountList = [SELECT Id FROM Account];
        System.assertEquals(2, accountList.size(), 'Two Accounts are expected.');

        List<Opportunity> opportunityList = [SELECT Id FROM Opportunity];
        System.assertEquals(2, opportunityList.size(), 'Two Opportunities are expected.');

        List<Opportunity> opportunityDupList = [SELECT StageName FROM Opportunity WHERE Id != :opportunity.Id];
        System.assertEquals('Closed Lost', opportunityDupList.get(0).StageName, 'Duplicate Opportunity from form should be switched to Closed Lost.');

        List<Contact> contactList = [
                SELECT FirstName, LastName, Phone, Email, 
                    (SELECT Id FROM AccountContactRelations), 
                    (SELECT Opportunity.StageName FROM OpportunityContactRoles)
                FROM Contact
                WHERE Id = :contact.Id];
        System.assertEquals(1, contactList.get(0).AccountContactRelations.size(), 'One Account is expected.');
        System.assertEquals(1, contactList.get(0).OpportunityContactRoles.size(), 'One Opportunity is expected.');
        System.assertEquals('Prospecting', contactList.get(0).OpportunityContactRoles.get(0).Opportunity.StageName, 'StageName should be Prospecting');
        System.assertEquals(1, contactList.size(), 'One Contact is expected.');
        System.assertEquals('JOHNAA', contactList.get(0).FirstName, 'Expected FirstName from form.');
        System.assertEquals('SMITHAA', contactList.get(0).LastName, 'Expected LastName from form.');
        System.assertEquals('+491111111111', contactList.get(0).Phone, 'Expected Phone from form.');
        System.assertEquals('test@fleetcor.com', contactList.get(0).Email, 'Expected Email from form.');
    }


    /*******************************************************************************
    *  Name            : updateDupConSamePhoneProspecting()
    *  Summary         : Verify that two Contacts were merged when Phones are the same and Contact #1 has E2E Opportunity #1 NOT in stage Closed Lost / Closed WON / Pending Sales - Deposit
    *  ExpectedResult  : E2E Opportunity #2 Stage = Closed Lost. Reason = Duplicate. E2E Account #2, E2E Contact #2 were NOT deleted. Contacts were merged. 
                         User is redirected to the last E2E step of the Opportunity #1
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void updateDupConSamePhoneProspecting() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Prospecting';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        controller = new LongFormController();
        controller.init();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JohnAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SmithAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491111111111';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'testAA@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();
        // back button to update data
        controller.goToContactDetails();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JohnAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SmithAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491234567890';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'testAA@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();

        List<Account> accountList = [SELECT Id FROM Account];
        System.assertEquals(2, accountList.size(), 'Two Accounts are expected.');

        List<Opportunity> opportunityList = [SELECT Id FROM Opportunity];
        System.assertEquals(2, opportunityList.size(), 'Two Opportunities are expected.');

        List<Opportunity> opportunityDupList = [SELECT StageName FROM Opportunity WHERE Id != :opportunity.Id];
        System.assertEquals('Closed Lost', opportunityDupList.get(0).StageName, 'Duplicate Opportunity from form should be switched to Closed Lost.');

        List<Contact> contactList = [
                SELECT FirstName, LastName, Phone, Email, 
                    (SELECT Id FROM AccountContactRelations), 
                    (SELECT Opportunity.StageName FROM OpportunityContactRoles)
                FROM Contact
                WHERE Id = :contact.Id];
        System.assertEquals(1, contactList.get(0).AccountContactRelations.size(), 'One Account is expected.');
        System.assertEquals(1, contactList.get(0).OpportunityContactRoles.size(), 'One Opportunity is expected.');
        System.assertEquals('Prospecting', contactList.get(0).OpportunityContactRoles.get(0).Opportunity.StageName, 'StageName should be Prospecting');
        System.assertEquals(1, contactList.size(), 'One Contact is expected.');
        System.assertEquals('JOHNAA', contactList.get(0).FirstName, 'Expected FirstName from form.');
        System.assertEquals('SMITHAA', contactList.get(0).LastName, 'Expected LastName from form.');
        System.assertEquals('+491234567890', contactList.get(0).Phone, 'Expected Phone from form.');
        System.assertEquals('testaa@fleetcor.com', contactList.get(0).Email, 'Expected Email from form.');
    }


    /*******************************************************************************
    *  Name            : updateDupConSameNameEmailDomProspecting()
    *  Summary         : Verify that two Contacts were merged when Name + Email Domaing are the same and Contact #1 has E2E Opportunity #1 NOT Closed Lost / Closed WON / Pending Sales - Deposit
    *  ExpectedResult  : E2E Opportunity #2 Stage = Closed Lost. Reason = Duplicate. E2E Account #2, E2E Contact #2 were NOT deleted. Contacts were merged. 
                         User is redirected to the last E2E step of the Opportunity #1
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void updateDupConSameNameEmailDomProspecting() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Prospecting';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        controller = new LongFormController();
        controller.init();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JohnAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SmithAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491111111111';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'testAA@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();
        // back button to update data
        controller.goToContactDetails();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHN';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SMITH';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491111111111';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'testAA@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();

        List<Account> accountList = [SELECT Id FROM Account];
        System.assertEquals(2, accountList.size(), 'Two Accounts are expected.');

        List<Opportunity> opportunityList = [SELECT Id FROM Opportunity];
        System.assertEquals(2, opportunityList.size(), 'Two Opportunities are expected.');

        List<Opportunity> opportunityDupList = [SELECT StageName FROM Opportunity WHERE Id != :opportunity.Id];
        System.assertEquals('Closed Lost', opportunityDupList.get(0).StageName, 'Duplicate Opportunity from form should be switched to Closed Lost.');

        List<Contact> contactList = [
                SELECT FirstName, LastName, Phone, Email, 
                    (SELECT Id FROM AccountContactRelations), 
                    (SELECT Opportunity.StageName FROM OpportunityContactRoles)
                FROM Contact
                WHERE Id = :contact.Id];
        System.assertEquals(1, contactList.get(0).AccountContactRelations.size(), 'One Account is expected.');
        System.assertEquals(1, contactList.get(0).OpportunityContactRoles.size(), 'One Opportunity is expected.');
        System.assertEquals('Prospecting', contactList.get(0).OpportunityContactRoles.get(0).Opportunity.StageName, 'StageName should be Prospecting');
        System.assertEquals(1, contactList.size(), 'One Contact is expected.');
        System.assertEquals('JOHN', contactList.get(0).FirstName, 'Expected FirstName from form.');
        System.assertEquals('SMITH', contactList.get(0).LastName, 'Expected LastName from form.');
        System.assertEquals('+491111111111', contactList.get(0).Phone, 'Expected Phone from form.');
        System.assertEquals('testaa@fleetcor.com', contactList.get(0).Email, 'Expected Email from form.');
    }


    /*******************************************************************************
    *  Name            : findDupLeadOnUpdateWithSameData()
    *  Summary         : Verify that when Contact #2 and Lead #1 has the same First Name + Last Name + Email + Phone domain then Lead #1 is disqualified 
    *  ExpectedResult  : E2E Contact #2 was created. Lead #1 Status = Disqualified Quali Status = Switched to E2E Notification was sent to the Lead Owner
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void findDupLeadOnUpdateWithSameData() {
        User e2eUser = E2ELongFormUtilsTest.createE2EDEUser();
        Database.insert(e2eUser);
    

        System.runAs(e2eUser) {
            Lead lead = E2ELongFormUtilsTest.createLeadForDuplicateDE();
            insert lead;

            ApexPages.currentPage().getparameters().put('country', 'Germany');
            controller = new LongFormController();
            controller.init();
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHNAA';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SMITHAA';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491111111111';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'testAA@fleetcor.com';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
            controller.goToCreditScoring();
            // back button to update data
            controller.goToContactDetails();
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHN';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SMITH';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491234567890';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'testAA@fleetcor.com';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
            Test.startTest();
            controller.goToCreditScoring();
            Test.stopTest();

            List<Contact> contactList = [SELECT Id FROM Contact];
            System.assertEquals(1, contactList.size(), 'One Contact is expected.');

            List<Lead> leadList = [SELECT Status, Quali_Status__c FROM Lead];
            System.assertEquals('Disqualified', leadList.get(0).Status, 'Lead status should be Disqualified.');
            System.assertEquals('Switched to E2E', leadList.get(0).Quali_Status__c, 'Lead quali status should be Switched to E2E.');
        }
    }


    /*******************************************************************************
    *  Name            : findDupLeadOnUpdateWithSameEmail()
    *  Summary         : Verify that when Contact #2 and Lead #1 has the same Emails then Lead #1 is disqualified 
    *  ExpectedResult  : E2E Contact #2 was created. Lead #1 Status = Disqualified Quali Status = Switched to E2E Notification was sent to the Lead Owner
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void findDupLeadOnUpdateWithSameEmail() {
        User e2eUser = E2ELongFormUtilsTest.createE2EDEUser();
        Database.insert(e2eUser);
        
        System.runAs(e2eUser) {
            Lead lead = E2ELongFormUtilsTest.createLeadForDuplicateDE();
            insert lead;

            ApexPages.currentPage().getparameters().put('country', 'Germany');
            controller = new LongFormController();
            controller.init();
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHNAA';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SMITHAA';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491111111111';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'testAA@fleetcor.com';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
            controller.goToCreditScoring();
            // back button to update data
            controller.goToContactDetails();
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHNAA';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SMITHAA';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491111111111';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'test@fleetcor.com';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
            Test.startTest();
            controller.goToCreditScoring();
            Test.stopTest();

            List<Contact> contactList = [SELECT Id FROM Contact];
            System.assertEquals(1, contactList.size(), 'One Contact is expected.');

            List<Lead> leadList = [SELECT Status, Quali_Status__c FROM Lead];
            System.assertEquals('Disqualified', leadList.get(0).Status, 'Lead status should be Disqualified.');
            System.assertEquals('Switched to E2E', leadList.get(0).Quali_Status__c, 'Lead quali status should be Switched to E2E.');
        }
    }


    /*******************************************************************************
    *  Name            : findDupLeadOnUpdateWithSameEmail()
    *  Summary         : Verify that when Contact #2 and Lead #1 has the same Phones then Lead #1 is disqualified 
    *  ExpectedResult  : E2E Contact #2 was created. Lead #1 Status = Disqualified Quali Status = Switched to E2E Notification was sent to the Lead Owner
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void findDupLeadOnUpdateWithSamePhone() {
        User e2eUser = E2ELongFormUtilsTest.createE2EDEUser();
        Database.insert(e2eUser);
        
        System.runAs(e2eUser) {
            Lead lead = E2ELongFormUtilsTest.createLeadForDuplicateDE();
            insert lead;

            ApexPages.currentPage().getparameters().put('country', 'Germany');
            controller = new LongFormController();
            controller.init();
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHNAA';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SMITHAA';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491111111111';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'testAA@fleetcor.com';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
            controller.goToCreditScoring();
            // back button to update data
            controller.goToContactDetails();
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHNAA';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SMITHAA';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491234567890';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'testAA@fleetcor.com';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
            Test.startTest();
            controller.goToCreditScoring();
            Test.stopTest();

            List<Contact> contactList = [SELECT Id FROM Contact];
            System.assertEquals(1, contactList.size(), 'One Contact is expected.');

            List<Lead> leadList = [SELECT Status, Quali_Status__c FROM Lead];
            System.assertEquals('Disqualified', leadList.get(0).Status, 'Lead status should be Disqualified.');
            System.assertEquals('Switched to E2E', leadList.get(0).Quali_Status__c, 'Lead quali status should be Switched to E2E.');
        }
    }


    /*******************************************************************************
    *  Name            : findDupLeadOnUpdateWithSameNameEmailDom()
    *  Summary         : Verify that when Contact #2 and Lead #1 has the same First Name + Last Name + Email Domain then Lead #1 is disqualified 
    *  ExpectedResult  : E2E Contact #2 was created. Lead #1 Status = Disqualified Quali Status = Switched to E2E Notification was sent to the Lead Owner
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void findDupLeadOnUpdateWithSameNameEmailDom() {
        User e2eUser = E2ELongFormUtilsTest.createE2EDEUser();
        Database.insert(e2eUser);
        
        System.runAs(e2eUser) {
            Lead lead = E2ELongFormUtilsTest.createLeadForDuplicateDE();
            insert lead;

            ApexPages.currentPage().getparameters().put('country', 'Germany');
            controller = new LongFormController();
            controller.init();
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHNAA';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SMITHAA';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491111111111';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'testAA@fleetcor.com';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
            controller.goToCreditScoring();
            // back button to update data
            controller.goToContactDetails();
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHN';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SMITH';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491111111111';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'testAA@fleetcor.com';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
            Test.startTest();
            controller.goToCreditScoring();
            Test.stopTest();

            List<Contact> contactList = [SELECT Id FROM Contact];
            System.assertEquals(1, contactList.size(), 'One Contact is expected.');

            List<Lead> leadList = [SELECT Status, Quali_Status__c FROM Lead];
            System.assertEquals('Disqualified', leadList.get(0).Status, 'Lead status should be Disqualified.');
            System.assertEquals('Switched to E2E', leadList.get(0).Quali_Status__c, 'Lead quali status should be Switched to E2E.');
        }
    }


    /*******************************************************************************
    *  Name            : doNotfindDupLeadOnUpdateWithSameData()
    *  Summary         : Verify that when Contact #2 and Lead #1 are the same but Lead is NOT disqualified if Lead #1 Status = Disqualified 
    *  ExpectedResult  : E2E Contact #2 was created. Lead #1 Status = Disqualified Quali Status = Switched to E2E Notification was sent to the Lead Owner
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void doNotfindDupLeadOnUpdateWithSameData() {
        Test.startTest();
            User e2eUser = E2ELongFormUtilsTest.createE2EDEUser();
            Database.insert(e2eUser);
        Test.stopTest();

        System.runAs(e2eUser) {

            Lead lead = E2ELongFormUtilsTest.createLeadForDuplicateDE();
            lead.Status = 'Disqualified';
            insert lead;

            ApexPages.currentPage().getparameters().put('country', 'Germany');
            controller = new LongFormController();
            controller.init();
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHNAA';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SMITHAA';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491111111111';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'testAA@fleetcor.com';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
            controller.goToCreditScoring();
            // back button to update data
            controller.goToContactDetails();
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHN';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SMITH';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491234567890';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'test@fleetcor.com';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
            controller.goToCreditScoring();

            List<Contact> contactList = [SELECT Id FROM Contact];
            System.assertEquals(1, contactList.size(), 'One Contact is expected.');

            List<Lead> leadList = [SELECT Status, Quali_Status__c FROM Lead];
            System.assertEquals('Disqualified', leadList.get(0).Status, 'Lead status should be Disqualified.');
            System.assertNotEquals('Switched to E2E', leadList.get(0).Quali_Status__c, 'Lead should not be updated and switched.');

        }
    }


    /*******************************************************************************
    *  Name            : updateDupConSameNameEmailDomProspecting()
    *  Summary         : Verify all fields on contact details step
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void verifyAllFields() {
        ApexPages.currentPage().getparameters().put('country', 'Germany');
        controller = new LongFormController();
        controller.init();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Herr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Test First Name';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Test Last Name';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+491231231233';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'test@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();

        List<Contact> contactList = [
                SELECT Salutation, FirstName, LastName, Phone, Email, Authorised_signatory__c, LeadSource, MailingCountry, RecordType.Name, E2E__c,
                    (SELECT Account.Name, Account.E2E__c, Account.RecordType.Name, Account.Type, Account.AccountSource, Account.BillingCountry, Account.ShippingCountry 
                    FROM AccountContactRelations), 
                    (SELECT Opportunity.Name, Opportunity.StageName, Opportunity.E2E__c, Opportunity.Product__c, Opportunity.CloseDate, Opportunity.Language_preference__c, 
                        Opportunity.Primary_Contact_Phone__c, Opportunity.Agree_to_Privacy_Policy__c, Opportunity.Date_for_Agree_to_Privacy_Policy__c, 
                        Opportunity.LeadSource, Opportunity.Sec_Channel__c, Opportunity.Channel__c, Opportunity.CurrencyIsoCode, Opportunity.Type, Opportunity.Eco_Fee__c, 
                        Opportunity.Visitor_ID__c, Opportunity.AGB_Datenschutzhinweise_Richtigkeit__c, Opportunity.E2E_Form_of_Business__c, Opportunity.E2E_Active_Step__c, 
                        Opportunity.E2E_Active_Substep__c, Opportunity.Anzahl_der_Karten__c
                    FROM OpportunityContactRoles)
                FROM Contact];

        // contact
        System.assertEquals(1, contactList.size(), 'One Contact is expected.');
        System.assertEquals('Herr', contactList.get(0).Salutation, 'Should be value from form.');
        System.assertEquals('TEST FIRST NAME', contactList.get(0).FirstName, 'Should be value from form.');
        System.assertEquals('TEST LAST NAME', contactList.get(0).LastName, 'Should be value from form.');
        System.assertEquals('+491231231233', contactList.get(0).Phone, 'Should be value from form.');
        System.assertEquals('test@fleetcor.com', contactList.get(0).Email, 'Should be value from form.');
        System.assertEquals(false, contactList.get(0).Authorised_signatory__c, 'Should be Automatic filling by default.');
        System.assertEquals(true, contactList.get(0).E2E__c, 'Should be Automatic filling by default.');
        System.assertEquals('Germany', contactList.get(0).MailingCountry, 'Should be Automatic filling by default.');
        System.assertEquals('Contact layout', contactList.get(0).RecordType.Name, 'Should be Automatic filling by default.');

        // account
        System.assertEquals(1, contactList.get(0).AccountContactRelations.size(), 'One Account is expected.');
        System.assertEquals('LONGFORM: TEST FIRST NAME TEST LAST NAME', contactList.get(0).AccountContactRelations.get(0).Account.Name, 'Should be value from form.');
        System.assertEquals('Endkunde', contactList.get(0).AccountContactRelations.get(0).Account.RecordType.Name, 'Should be Automatic filling by default.');
        System.assertEquals('Customer', contactList.get(0).AccountContactRelations.get(0).Account.Type, 'Should be Automatic filling by default.');
        System.assertEquals(true, contactList.get(0).AccountContactRelations.get(0).Account.E2E__c, 'Should be Automatic filling by default.');
        System.assertEquals('Germany', contactList.get(0).AccountContactRelations.get(0).Account.BillingCountry, 'Should be Automatic filling by default.');
        System.assertEquals('Germany', contactList.get(0).AccountContactRelations.get(0).Account.ShippingCountry, 'Should be Automatic filling by default.');

        // opportunity
        System.assertEquals(1, contactList.get(0).OpportunityContactRoles.size(), 'One Opportunity is expected.');
        System.assertEquals('LONGFORM: TEST FIRST NAME TEST LAST NAME', contactList.get(0).OpportunityContactRoles.get(0).Opportunity.Name, 'Should be value from form.');
        System.assertEquals(3, contactList.get(0).OpportunityContactRoles.get(0).Opportunity.Anzahl_der_Karten__c, 'Should be value from form.');
        System.assertEquals('Prospecting', contactList.get(0).OpportunityContactRoles.get(0).Opportunity.StageName, 'Should be Automatic filling by default.');
        System.assertEquals(null, contactList.get(0).OpportunityContactRoles.get(0).Opportunity.Product__c, 'Should be Automatic filling by default.');
        System.assertEquals('German', contactList.get(0).OpportunityContactRoles.get(0).Opportunity.Language_preference__c, 'Should be Automatic filling by default.');
        System.assertEquals('+491231231233', contactList.get(0).OpportunityContactRoles.get(0).Opportunity.Primary_Contact_Phone__c, 'Should be value from form.');
        System.assertEquals(true, contactList.get(0).OpportunityContactRoles.get(0).Opportunity.Agree_to_Privacy_Policy__c, 'Should be Automatic filling by default.');
        System.assertEquals(true, contactList.get(0).OpportunityContactRoles.get(0).Opportunity.E2E__c, 'Should be Automatic filling by default.');
        System.assertEquals('Inbound', contactList.get(0).OpportunityContactRoles.get(0).Opportunity.Sec_Channel__c, 'Should be Automatic filling by default.');
        System.assertEquals('Internet', contactList.get(0).OpportunityContactRoles.get(0).Opportunity.Channel__c, 'Should be Automatic filling by default.');
        System.assertEquals('EUR', contactList.get(0).OpportunityContactRoles.get(0).Opportunity.CurrencyIsoCode, 'Should be Automatic filling by default.');
        System.assertEquals('New Business', contactList.get(0).OpportunityContactRoles.get(0).Opportunity.Type, 'Should be Automatic filling by default.');
        System.assertEquals(false, contactList.get(0).OpportunityContactRoles.get(0).Opportunity.Eco_Fee__c, 'Should be Automatic filling by default.');
        System.assertEquals(false, contactList.get(0).OpportunityContactRoles.get(0).Opportunity.AGB_Datenschutzhinweise_Richtigkeit__c, 'Should be Automatic filling by default.');
        System.assertEquals('Company', contactList.get(0).OpportunityContactRoles.get(0).Opportunity.E2E_Form_of_Business__c, 'Should be Automatic filling by default.');
        System.assertEquals(1, contactList.get(0).OpportunityContactRoles.get(0).Opportunity.E2E_Active_Step__c, 'Should be Automatic filling by default.');
        System.assertEquals('Search company', contactList.get(0).OpportunityContactRoles.get(0).Opportunity.E2E_Active_Substep__c, 'Should be Automatic filling by default.');
    }


    /*******************************************************************************
    *  Name            : searchCompanyTest()
    *  Summary         : Testing flow from Search Company with Mock
    *  CreatedDate     : 06/06/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void searchCompanyTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Prospecting';
        opportunity.E2E_Active_Step__c = 1;
        opportunity.E2E_Active_Substep__c = 'Search company';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactDE(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EForm');
        update opportunity;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormController();
        controller.init();
        
        controller.stepPagesMap.get('CREDIT SCORE. SEARCH COMPANY').fields.get('COMPANY NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'TEST';
        controller.stepPagesMap.get('CREDIT SCORE. SEARCH COMPANY').fields.get('CITY').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Weimar';
        controller.doSaveCompanyDetailsData();

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new E2ELongFromCreditFactoryMock());
            controller.doSearchCompany();
        Test.stopTest();

        controller.editContactDetails();

        List<Account> accountList = [SELECT Name, BillingCity FROM Account WHERE E2E__c = TRUE];
        System.assertEquals('TEST', accountList.get(0).Name);
        System.assertEquals('WEIMAR', accountList.get(0).BillingCity);
    }


    /*******************************************************************************
    *  Name            : verifyAllFieldsAndCreditReport()
    *  Summary         : Verify that Credit Report record was created and updated with info    
    *  CreatedDate     : 20/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void verifyAllFieldsAndCreditReport() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Prospecting';
        opportunity.E2E_Active_Step__c = 1;
        opportunity.E2E_Active_Substep__c = 'Calculating credit score';
        opportunity.Zahlungsart__c = '';
        opportunity.Rechnungsperiode__c = '';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactDE(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        ApexPages.currentPage().getparameters().put('country', 'Germany');

        controller = new LongFormController();
        controller.init();
        controller.country = 'Germany';
        controller.activeStep = 1;
        controller.initPageElements();
        controller.initSObjects(opportunity.Id);
        controller.selectedAvailableCompanyCreditScoring = new CreditCompany();
        controller.selectedAvailableCompanyCreditScoring.identificationnumber = '03453452015622';
        controller.deleteReportsForPreviousCompany();

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new E2ELongFromCreditFactoryMock());
            controller.goToSetTotalConsumption();
        Test.stopTest();

        // Verify that opportunity.E2E_Active_Substep__c field is updated when reportResponse.Tax_Id__c = null && reportResponse.Tax_Id__c = null
        controller.cfReportResponse.company.taxnumber = '12345678910';
        controller.continueToTotalConsumption();

        // Verify that opportunity.E2E_Active_Substep__c field is updated when reportResponse.Tax_Id__c != null || reportResponse.Tax_Id__c != null
        List<Opportunity> opptyList = [SELECT E2E_Active_Substep__c, E2E_Active_Step__c FROM Opportunity WHERE Id = :opportunity.Id];
        System.assertEquals('Set total consumption', opptyList.get(0).E2E_Active_Substep__c, 'Should be Automatic filling by default');
        System.assertEquals(1, opptyList.get(0).E2E_Active_Step__c, 'Should be Automatic filling by default');

        controller.stepPagesMap.get('CREDIT SCORE. TOTAL CONSUMPTION').fields.get('TOTAL CONSUMPTION').elementItemsMap.get('DEFAULT VALUE').Value__c = '1000';
        controller.doCalculateCreditScoring();

        // back button
        controller.backToSetTotalConsumption();

        List<Opportunity> oppList = [
                SELECT Name, StageName, CF_Stage__c, Credit_System_Rating__c, Umsatz__c, Credit_System_Number__c, E2E_Active_Step__c, E2E_Last_Activity__c, Visitor_ID__c, E2E_Encoded_URL__c, 
                    Account.Name, Account.BillingStreet, Account.BillingPostalCode, Account.BillingCity, Account.ShippingCountry, Account.ShippingStreet, Account.ShippingPostalCode, 
                    Account.ShippingCity, Account.Gesellschaftsform__c, Account.Umsatzsteuer_ID__c, Account.Steuernummer__c, Gruendungsjahr__c, Zahl_der_Mitarbeiter__c, E2E_Active_Substep__c, 
                    Gasoline_consumption_l_month__c, Diesel_consumption_l_month__c, Total_consumption_l_month__c, 
                    (SELECT Contact.MailingStreet, Contact.MailingPostalCode, Contact.MailingCity FROM OpportunityContactRoles),
                    (SELECT Age_of_Company__c, Authorized_Share_Capital__c, Authorized_Share_Capital_Currency__c, Billing_Period__c, City__c, Class_Rating__c, Company_Id__c, 
                        Company_Status__c, Continuation_Date__c, Country__c, County_Court__c, Credit_Decision__c, Credit_Limit__c, Credit_Limit_Bi_Weekly_7__c, Credit_Limit_Currency__c, 
                        Credit_Limit_Default__c, Credit_Limit_Monthly_7__c, Credit_Limit_Weekly_7__c, Credit_System_Number__c, Date_Last_Register_Entry__c, Date_Legal_Form__c, 
                        Date_of_Foundation__c, Date_of_Last_Major_Update__c, Decision_Status_Code__c, Decision_Verdict__c, Deposit_Bi_Weekly_7__c, Deposit_Monthly_7__c, Deposit_Weekly_7__c, 
                        Email__c, Establishment_Date__c, Fax__c, First_Legal_Form__c, Fiscal_Number__c, Housenumber__c, Indication_Bankruptcy__c, Indication_Dip__c, Indication_Economically_Active__c,
                        Indication_Main_Establishment__c, Indication_Non_Mailing__c, Indication_Organisation__c, Issued_Share_Capital__c, Issued_Share_Capital_Currency__c, Legal_Form__c, 
                        Max_Credit_Limit_Bi_Weekly_7__c, Max_Credit_Limit_Monthly_7__c, Max_Credit_Limit_Weekly_7__c, Max_Value_Bi_Weekly_7__c, Max_Value_Monthly_7__c, Max_Value_Weekly_7__c, 
                        Mobile__c, Obligation_Overdue__c, Opportunity__c, Order_Situation__c, Paid_Up_Share_Capital__c, Paid_Up_Share_Capital_Currency__c, Payment_Behaviour__c, Phone__c, 
                        Postcode__c, Primary_Sbi_Code__c, Primary_Sbi_Code_Text__c, Reference_Number__c, Register_Number__c, Request_Status__c, Rsin_Number__c, Solvency_Index__c, Staff_Range__c, 
                        Street__c, Tax_Id__c, Trade_Name__c, Trade_Register_Number__c, Turn_Over__c, VAT_Number__c, Website__c, Name 
                    FROM Credit_Factory_Reports__r),
                    (SELECT Id FROM Attachments WHERE Name = 'CrefoReport.pdf')
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        // Attachment
        System.assertEquals(1, oppList.get(0).Attachments.size());

        // Opportunity
        System.assertEquals('KUNDENTESTSYSTEM ENERGIE UND WASSER AG - BITTE NICHT ÄNDERN', oppList.get(0).Name, 'Should be Automatic filling by default from CF.');
        System.assertEquals('Prospecting', oppList.get(0).StageName, 'Should be Automatic filling by default.');
        System.assertEquals(0, oppList.get(0).Gasoline_consumption_l_month__c, 'Always should be 0.');
        System.assertEquals(1000, oppList.get(0).Diesel_consumption_l_month__c, 'Shoul be the same as total consumption.');
        System.assertEquals(1000, oppList.get(0).Total_consumption_l_month__c, 'Wrong total consumption.');
        System.assertEquals('Calculating credit score', oppList.get(0).E2E_Active_Substep__c, 'Wrong active substep.');
        System.assertEquals('Report generated', oppList.get(0).CF_Stage__c, 'Should be Automatic filling by default from CF.');
        System.assertEquals('1', oppList.get(0).Credit_System_Rating__c, 'Should be Automatic filling by default from CF.');
        System.assertEquals('10 - 25 Mio. EUR', oppList.get(0).Umsatz__c, 'Should be Automatic filling by default from CF.');
        System.assertEquals('3452015622', oppList.get(0).Credit_System_Number__c, 'Should be Automatic filling by default from CF.');
        System.assertEquals(1, oppList.get(0).E2E_Active_Step__c, 'Should be Automatic filling by default.');
        // Verify that Opportunity.Gruendungsjahr__c field is updated when reportResponse.Date_of_Foundation__c != null
        System.assertEquals('2006', oppList.get(0).Gruendungsjahr__c, 'Should be Automatic filling by default from CF.');
        // Verify that opportunity.Credit_System_Number__c field is updated when reportResponse.Staff_Range__c != null
        System.assertEquals('1.000 - 1.999 Mitarbeiter', oppList.get(0).Zahl_der_Mitarbeiter__c, 'Should be Automatic filling by default from CF.');

        // Account 
        System.assertEquals('KUNDENTESTSYSTEM ENERGIE UND WASSER AG - BITTE NICHT ÄNDERN', oppList.get(0).Account.Name, 'Should be Automatic filling by default from CF.');
        System.assertEquals('DICHTERWEG 27', oppList.get(0).Account.BillingStreet, 'Should be Automatic filling by default from CF.');
        System.assertEquals('99423', oppList.get(0).Account.BillingPostalCode, 'Should be Automatic filling by default from CF.');
        System.assertEquals('WEIMAR', oppList.get(0).Account.BillingCity, 'Should be Automatic filling by default from CF.');
        System.assertEquals('Germany', oppList.get(0).Account.ShippingCountry, 'Should be Automatic filling by default from CF.');
        System.assertEquals('DICHTERWEG 27', oppList.get(0).Account.ShippingStreet, 'Should be Automatic filling by default from CF.');
        System.assertEquals('99423', oppList.get(0).Account.ShippingPostalCode, 'Should be Automatic filling by default from CF.');
        System.assertEquals('WEIMAR', oppList.get(0).Account.ShippingCity, 'Should be Automatic filling by default from CF.');
        System.assertEquals('AG', oppList.get(0).Account.Gesellschaftsform__c, 'Should be Automatic filling by default from CF.');
        System.assertEquals(null, oppList.get(0).Account.Umsatzsteuer_ID__c, 'Should be Automatic filling by default from CF.');
        System.assertEquals('12345678910', oppList.get(0).Account.Steuernummer__c, 'Should be value from form.');

        // Contact
        System.assertEquals('DICHTERWEG 27', oppList.get(0).OpportunityContactRoles.get(0).Contact.MailingStreet, 'Should be Automatic filling by default from CF.');
        System.assertEquals('99423', oppList.get(0).OpportunityContactRoles.get(0).Contact.MailingPostalCode, 'Should be Automatic filling by default from CF.');
        System.assertEquals('WEIMAR', oppList.get(0).OpportunityContactRoles.get(0).Contact.MailingCity, 'Should be Automatic filling by default from CF.');

        // Credit factory report
        System.assertEquals(1, oppList.get(0).Credit_Factory_Reports__r.size(), 'One report is expected.');
        System.assertEquals('3452015622', oppList.get(0).Credit_Factory_Reports__r.get(0).Credit_System_Number__c, 'Should be Automatic filling by default from CF.');
        System.assertEquals('10', oppList.get(0).Credit_Factory_Reports__r.get(0).Age_of_Company__c, 'Should be Automatic filling by default from CF.');
        System.assertEquals('Weimar', oppList.get(0).Credit_Factory_Reports__r.get(0).City__c, 'Should be Automatic filling by default from CF.');
        System.assertEquals('aktiv', oppList.get(0).Credit_Factory_Reports__r.get(0).Company_Status__c, 'Should be Automatic filling by default from CF.');
        System.assertEquals('DE', oppList.get(0).Credit_Factory_Reports__r.get(0).Country__c, 'Should be Automatic filling by default from CF.');
        System.assertEquals('AG Weimar 99423', oppList.get(0).Credit_Factory_Reports__r.get(0).County_Court__c, 'Should be Automatic filling by default from CF.');
        System.assertEquals('Kredite und Geschäftsverbindung sind zulässig.', oppList.get(0).Credit_Factory_Reports__r.get(0).Credit_Decision__c, 'Should be Automatic filling by default from CF.');
        System.assertEquals('300000', oppList.get(0).Credit_Factory_Reports__r.get(0).Credit_Limit__c, 'Should be Automatic filling by default from CF.');
        System.assertEquals('2009-10-02', oppList.get(0).Credit_Factory_Reports__r.get(0).Date_Last_Register_Entry__c, 'Should be Automatic filling by default from CF.');
        System.assertEquals('2006-06-21', oppList.get(0).Credit_Factory_Reports__r.get(0).Date_Legal_Form__c, 'Should be Automatic filling by default from CF.');
        System.assertEquals('2006-06-21', oppList.get(0).Credit_Factory_Reports__r.get(0).Date_of_Foundation__c, 'Should be Automatic filling by default from CF.');
        System.assertEquals('info@KEW_AG.com', oppList.get(0).Credit_Factory_Reports__r.get(0).Email__c, 'Should be Automatic filling by default from CF.');
        System.assertEquals('+4936468768761', oppList.get(0).Credit_Factory_Reports__r.get(0).Fax__c, 'Should be Automatic filling by default from CF.');
        System.assertEquals('Aktiengesellschaft', oppList.get(0).Credit_Factory_Reports__r.get(0).First_Legal_Form__c, 'Should be Automatic filling by default from CF.');
        System.assertEquals(null, oppList.get(0).Credit_Factory_Reports__r.get(0).Fiscal_Number__c, 'Should be Automatic filling by default from CF.');
        System.assertEquals('27', oppList.get(0).Credit_Factory_Reports__r.get(0).Housenumber__c, 'Should be Automatic filling by default from CF.');
        System.assertEquals('AG', oppList.get(0).Credit_Factory_Reports__r.get(0).Legal_Form__c, 'Should be Automatic filling by default from CF.');
        System.assertEquals(null, oppList.get(0).Credit_Factory_Reports__r.get(0).Mobile__c, 'Should be Automatic filling by default from CF.');
        System.assertEquals(opportunity.Id, oppList.get(0).Credit_Factory_Reports__r.get(0).Opportunity__c, 'Should be Automatic filling by default from CF.');
        System.assertEquals(null, oppList.get(0).Credit_Factory_Reports__r.get(0).Order_Situation__c, 'Should be Automatic filling by default from CF.');
        System.assertEquals('PYMD-22', oppList.get(0).Credit_Factory_Reports__r.get(0).Payment_Behaviour__c, 'Should be Automatic filling by default from CF.');
        System.assertEquals('+493646876876012', oppList.get(0).Credit_Factory_Reports__r.get(0).Phone__c, 'Should be Automatic filling by default from CF.');
        System.assertEquals('99423', oppList.get(0).Credit_Factory_Reports__r.get(0).Postcode__c, 'Should be Automatic filling by default from CF.');
        System.assertEquals('40187781', oppList.get(0).Credit_Factory_Reports__r.get(0).Reference_Number__c, 'Should be Automatic filling by default from CF.');
        System.assertEquals('4711', oppList.get(0).Credit_Factory_Reports__r.get(0).Register_Number__c, 'Should be Automatic filling by default from CF.');
        System.assertEquals('1.000 - 1.999 Mitarbeiter', oppList.get(0).Credit_Factory_Reports__r.get(0).Staff_Range__c, 'Should be Automatic filling by default from CF.');
        System.assertEquals('Dichterweg', oppList.get(0).Credit_Factory_Reports__r.get(0).Street__c, 'Should be Automatic filling by default from CF.');
        System.assertEquals('Energie und Wasser', oppList.get(0).Credit_Factory_Reports__r.get(0).Trade_Name__c, 'Should be Automatic filling by default from CF.');
        System.assertEquals('10 - 25 Mio. EUR', oppList.get(0).Credit_Factory_Reports__r.get(0).Turn_Over__c, 'Should be Automatic filling by default from CF.');
        System.assertEquals(null, oppList.get(0).Credit_Factory_Reports__r.get(0).VAT_Number__c, 'Should be Automatic filling by default from CF.');
        System.assertEquals(null, oppList.get(0).Credit_Factory_Reports__r.get(0).Tax_Id__c, 'Should be Automatic filling by default from CF.');
        System.assertEquals('www.KEW_AG.com', oppList.get(0).Credit_Factory_Reports__r.get(0).Website__c, 'Should be Automatic filling by default from CF.');
        System.assertEquals('Kundentestsystem Energie und Wasser AG - BITTE NICHT ÄNDERN', oppList.get(0).Credit_Factory_Reports__r.get(0).Name, 'Should be Automatic filling by default from CF.');
        System.assertEquals('03453452015622', oppList.get(0).Credit_Factory_Reports__r.get(0).Company_Id__c, 'Should be Automatic filling by default from CF.');
        System.assertEquals(null, oppList.get(0).Credit_Factory_Reports__r.get(0).Solvency_Index__c, 'Should be Automatic filling by default from CF.');
        System.assertEquals(30, oppList.get(0).Credit_Factory_Reports__r.get(0).Billing_Period__c, 'Should be Automatic filling by default from CF.');
        System.assertEquals('Yes', oppList.get(0).Credit_Factory_Reports__r.get(0).Decision_Verdict__c, 'Should be Automatic filling by default from CF.');
        System.assertEquals('001', oppList.get(0).Credit_Factory_Reports__r.get(0).Decision_Status_Code__c, 'Should be Automatic filling by default from CF.');
        System.assertEquals('1', oppList.get(0).Credit_Factory_Reports__r.get(0).Class_Rating__c, 'Should be Automatic filling by default from CF.');
    }


    /*******************************************************************************
    *  Name            : dupLogicProspectingWithSameName()
    *  Summary         : Verify that two Accounts were merged when Company Names are the same
    *  ExpectedResult  : E2E Account #2 is delete. Account #1 is updated. E2E Opportunity #2 is created. Opportunity #1 Stage = Closed Lost.
                         Reason = Switched to E2E. Notification was sent to the Opportunity Owner
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void dupLogicProspectingWithSameName() {
        Account account2 = E2ELongFormUtilsTest.createAccountForTestDuplactes();
        insert account2;

        Opportunity opportunity2 = E2ELongFormUtilsTest.createOpportunityForTestDuplactes(account2.Id);
        insert opportunity2;

        Contact contact2 = E2ELongFormUtilsTest.createContactDE(account2.Id);
        insert contact2;

        OpportunityContactRole oppContactRole2 = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity2.Id, contact2.Id);
        insert oppContactRole2;

        // create duplicate account
        Account account = E2ELongFormUtilsTest.createAccountForTestDuplactes();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityForTestDuplactes(account.Id);
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactDE(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EForm');
        update opportunity;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormController();
        controller.init();
        controller.selectedAvailableCompanyCreditScoring = new CreditCompany();
        controller.selectedAvailableCompanyCreditScoring.identificationnumber = '03453452015622';
        controller.deleteReportsForPreviousCompany();

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new E2ELongFromCreditFactoryMock());
            controller.goToSetTotalConsumption();
        Test.stopTest();
        controller.backToCreditScoring();

        List<Account> accList = [SELECT Id, (SELECT Id FROM Opportunities) FROM Account WHERE Id = :account2.Id];
        List<Account> deletedAcc = [SELECT Id FROM Account WHERE Id = :account.Id];
        List<Opportunity> oppList = [SELECT StageName, Gruende_verloren__c FROM Opportunity WHERE Id = :opportunity2.Id];

        System.assertEquals(2, accList.get(0).Opportunities.size(), 'Wrong count of Opportunities.');
        System.assertEquals(0, deletedAcc.size(), 'Account should be deleted.');
        System.assertEquals('Closed Lost', oppList.get(0).StageName, 'Wrong stagename.');
        System.assertEquals('Switched to E2E', oppList.get(0).Gruende_verloren__c, 'Wrong reason lost.');
    }


    /*******************************************************************************
    *  Name            : dupLogicProspectingWithSameTaxId()
    *  Summary         : Verify that two Accounts were merged when TAX IDs are the same
    *  ExpectedResult  : E2E Account #2 is delete. Account #1 is updated. E2E Opportunity #2 is created. Opportunity #1 Stage = Closed Lost.
                         Reason = Switched to E2E. Notification was sent to the Opportunity Owner
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void dupLogicProspectingWithSameTaxId() {
        Account account2 = E2ELongFormUtilsTest.createAccountForTestDuplactes();
        account2.Steuernummer__c = '234154542';
        insert account2;

        Opportunity opportunity2 = E2ELongFormUtilsTest.createOpportunityForTestDuplactes(account2.Id);
        insert opportunity2;

        Contact contact2 = E2ELongFormUtilsTest.createContactDE(account2.Id);
        insert contact2;

        OpportunityContactRole oppContactRole2 = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity2.Id, contact2.Id);
        insert oppContactRole2;

        // create duplicate account
        Account account = E2ELongFormUtilsTest.createAccountForTestDuplactes();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityForTestDuplactes(account.Id);
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactDE(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EForm');
        update opportunity;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormController();
        controller.init();
        controller.selectedAvailableCompanyCreditScoring = new CreditCompany();
        controller.selectedAvailableCompanyCreditScoring.identificationnumber = '03453452013902';
        controller.deleteReportsForPreviousCompany();

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformEntrepreneurialCompanyMock());
            controller.goToSetTotalConsumption();
        Test.stopTest();

        List<Account> accList = [SELECT Id, (SELECT Id FROM Opportunities) FROM Account WHERE Id = :account2.Id];
        List<Account> deletedAcc = [SELECT Id FROM Account WHERE Id = :account.Id];
        List<Opportunity> oppList = [SELECT StageName, Gruende_verloren__c FROM Opportunity WHERE Id = :opportunity2.Id];

        System.assertEquals(2, accList.get(0).Opportunities.size(), 'Wrong count of Opportunities.');
        System.assertEquals(0, deletedAcc.size(), 'Account should be deleted.');
        System.assertEquals('Closed Lost', oppList.get(0).StageName, 'Wrong stagename.');
        System.assertEquals('Switched to E2E', oppList.get(0).Gruende_verloren__c, 'Wrong reason lost.');
    }


    /*******************************************************************************
    *  Name            : dupLogicProspectingWithSameVaTId()
    *  Summary         : Verify that two Accounts were merged when VAT IDs are the same
    *  ExpectedResult  : E2E Account #2 is delete. Account #1 is updated. E2E Opportunity #2 is created. Opportunity #1 Stage = Closed Lost.
                         Reason = Switched to E2E. Notification was sent to the Opportunity Owner
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void dupLogicProspectingWithSameVaTId() {
        Account account2 = E2ELongFormUtilsTest.createAccountForTestDuplactes();
        account2.Umsatzsteuer_ID__c = 'DE821235454';
        account2.Steuernummer__c = '234154542';
        insert account2;

        Opportunity opportunity2 = E2ELongFormUtilsTest.createOpportunityForTestDuplactes(account2.Id);
        insert opportunity2;

        Contact contact2 = E2ELongFormUtilsTest.createContactDE(account2.Id);
        insert contact2;

        OpportunityContactRole oppContactRole2 = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity2.Id, contact2.Id);
        insert oppContactRole2;

        // create duplicate account
        Account account = E2ELongFormUtilsTest.createAccountForTestDuplactes();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityForTestDuplactes(account.Id);
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactDE(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EForm');
        update opportunity;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormController();
        controller.init();
        controller.selectedAvailableCompanyCreditScoring = new CreditCompany();
        controller.selectedAvailableCompanyCreditScoring.identificationnumber = '03453452013902';
        controller.deleteReportsForPreviousCompany();

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformEntrepreneurialCompanyMock());
            controller.goToSetTotalConsumption();
        Test.stopTest();

        List<Account> accList = [SELECT Id, Name, BillingCity, (SELECT Id FROM Opportunities) FROM Account WHERE Id = :account2.Id];
        List<Account> deletedAcc = [SELECT Id FROM Account WHERE Id = :account.Id];
        List<Opportunity> oppList = [SELECT StageName, Gruende_verloren__c FROM Opportunity WHERE Id = :opportunity2.Id];

        System.assertEquals(2, accList.get(0).Opportunities.size(), 'Wrong count of Opportunities.');
        System.assertEquals(0, deletedAcc.size(), 'Account should be deleted.');
        System.assertEquals('Closed Lost', oppList.get(0).StageName, 'Wrong stagename.');
        System.assertEquals('Switched to E2E', oppList.get(0).Gruende_verloren__c, 'Wrong reason lost.');
    }


    /*******************************************************************************
    *  Name            : dupLogicClosedLostWithSameData()
    *  Summary         : Verify that two Accounts were merged when Company Names / TAX ID / VAT ID are the same
    *  ExpectedResult  : E2E Account #2 is delete. Account #1 is updated. E2E Opportunity #2 is created. Notification was sent to the Credit user
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void dupLogicClosedLostWithSameData() {
        Account account2 = E2ELongFormUtilsTest.createAccountForTestDuplactes();
        account2.Name = 'Kundentestsystem Energie und Wasser AG - BITTE NICHT ÄNDERN';
        account2.Umsatzsteuer_ID__c = 'DE821235454';
        account2.Steuernummer__c = '234154542';
        insert account2;

        Opportunity opportunity2 = E2ELongFormUtilsTest.createOpportunityForTestDuplactes(account2.Id);
        opportunity2.StageName = 'Closed Lost';
        opportunity2.Gruende_verloren__c = 'Refused Credit';
        opportunity2.CloseDate = Date.today().addDays(-100);
        insert opportunity2;

        opportunity2.CloseDate = Date.today().addDays(-100);
        update opportunity2;

        Contact contact2 = E2ELongFormUtilsTest.createContactDE(account2.Id);
        insert contact2;

        OpportunityContactRole oppContactRole2 = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity2.Id, contact2.Id);
        insert oppContactRole2;

        // create duplicate account
        Account account = E2ELongFormUtilsTest.createAccountForTestDuplactes();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityForTestDuplactes(account.Id);
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactDE(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EForm');
        update opportunity;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormController();
        controller.init();
        controller.selectedAvailableCompanyCreditScoring = new CreditCompany();
        controller.selectedAvailableCompanyCreditScoring.identificationnumber = '03453452013902';
        controller.deleteReportsForPreviousCompany();

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformEntrepreneurialCompanyMock());
            controller.goToSetTotalConsumption();
        Test.stopTest();

        List<Account> accList = [SELECT Id, Name, BillingCity, (SELECT Id FROM Opportunities) FROM Account WHERE Id = :account2.Id];
        List<Account> deletedAcc = [SELECT Id FROM Account WHERE Id = :account.Id];

        System.assertEquals(2, accList.get(0).Opportunities.size(), 'Wrong count of Opportunities.');
        System.assertEquals(0, deletedAcc.size(), 'Account should be deleted.');
    }


    /*******************************************************************************
    *  Name            : dupLogicAlreadyInProcessSameData()
    *  Summary         : Verify that two Accounts were merged when Company Names / TAX ID / VAT ID are the same
    *  ExpectedResult  : E2E Account #2 is delete. Account #1 is updated. E2E Opportunity #2 is created. Opportunity #2 Stage = Closed Lost.
                         Reason = Duplicate. Notification was sent to the Opportunity Owner Error 'Already in Proccess..' is displayed
    *  CreatedDate     : 26/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void dupLogicAlreadyInProcessSameData() {
        Account account2 = E2ELongFormUtilsTest.createAccountForTestDuplactes();
        account2.Name = 'Kundentestsystem Energie und Wasser AG - BITTE NICHT ÄNDERN';
        account2.Umsatzsteuer_ID__c = 'DE821235454';
        account2.Steuernummer__c = '234154542';
        insert account2;

        Opportunity opportunity2 = E2ELongFormUtilsTest.createOpportunityForTestDuplactes(account2.Id);
        opportunity2.StageName = 'CreditCheck';
        opportunity2.Home_Station__c = 'test';
        opportunity2.ESI__c = 'test';
        insert opportunity2;

        Contact contact2 = E2ELongFormUtilsTest.createContactDE(account2.Id);
        insert contact2;

        OpportunityContactRole oppContactRole2 = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity2.Id, contact2.Id);
        insert oppContactRole2;

        // create duplicate account
        Account account = E2ELongFormUtilsTest.createAccountForTestDuplactes();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityForTestDuplactes(account.Id);
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactDE(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EForm');
        update opportunity;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormController();
        controller.init();
        controller.selectedAvailableCompanyCreditScoring = new CreditCompany();
        controller.selectedAvailableCompanyCreditScoring.identificationnumber = '03453452013902';
        controller.deleteReportsForPreviousCompany();

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformEntrepreneurialCompanyMock());
            controller.goToSetTotalConsumption();
        Test.stopTest();

        List<Account> accList = [SELECT Id, Name, BillingCity, (SELECT Id FROM Opportunities) FROM Account WHERE Id = :account2.Id];
        List<Account> deletedAcc = [SELECT Id FROM Account WHERE Id = :account.Id];
        List<Opportunity> oppList = [SELECT StageName, Gruende_verloren__c FROM Opportunity WHERE Id = :opportunity.Id];

        System.assertEquals(2, accList.get(0).Opportunities.size(), 'Wrong count of Opportunities.');
        System.assertEquals(0, deletedAcc.size(), 'Account should be deleted.');
        System.assertEquals('Closed Lost', oppList.get(0).StageName, 'Wrong stagename.');
        System.assertEquals('Duplicate', oppList.get(0).Gruende_verloren__c, 'Wrong reason lost.');
        System.assertEquals('Already in process', controller.activeSubstep, 'Expected stop process.');
    }


    /*******************************************************************************
    *  Name            : dupLogicAlreadyInProcessPSInformation()
    *  Summary         : Verify that two Accounts were merged when Company Names / TAX ID / VAT ID are the same
    *  ExpectedResult  : E2E Account #2 is delete. Account #1 is updated. E2E Opportunity #2 is created. Opportunity #2 Stage = Closed Lost.
                         Reason = Duplicate. Notification was sent to the Opportunity Owner Error 'Already in Proccess..' is displayed
    *  CreatedDate     : 26/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void dupLogicAlreadyInProcessPSInformation() {
        Account account2 = E2ELongFormUtilsTest.createAccountForTestDuplactes();
        account2.Name = 'Kundentestsystem Energie und Wasser AG - BITTE NICHT ÄNDERN';
        account2.Umsatzsteuer_ID__c = 'DE821235454';
        account2.Steuernummer__c = '234154542';
        insert account2;

        Opportunity opportunity2 = E2ELongFormUtilsTest.createOpportunityForTestDuplactes(account2.Id);
        opportunity2.StageName = 'Pending Sales – Information';
        opportunity2.Home_Station__c = 'test';
        opportunity2.ESI__c = 'test';
        insert opportunity2;

        Contact contact2 = E2ELongFormUtilsTest.createContactDE(account2.Id);
        insert contact2;

        OpportunityContactRole oppContactRole2 = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity2.Id, contact2.Id);
        insert oppContactRole2;

        // create duplicate account
        Account account = E2ELongFormUtilsTest.createAccountForTestDuplactes();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityForTestDuplactes(account.Id);
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactDE(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EForm');
        update opportunity;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormController();
        controller.init();
        controller.selectedAvailableCompanyCreditScoring = new CreditCompany();
        controller.selectedAvailableCompanyCreditScoring.identificationnumber = '03453452013902';
        controller.deleteReportsForPreviousCompany();

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformEntrepreneurialCompanyMock());
            controller.goToSetTotalConsumption();
        Test.stopTest();

        List<Account> accList = [SELECT Id, Name, BillingCity, (SELECT Id FROM Opportunities) FROM Account WHERE Id = :account2.Id];
        List<Account> deletedAcc = [SELECT Id FROM Account WHERE Id = :account.Id];
        List<Opportunity> oppList = [SELECT StageName, Gruende_verloren__c FROM Opportunity WHERE Id = :opportunity.Id];

        System.assertEquals(2, accList.get(0).Opportunities.size(), 'Wrong count of Opportunities.');
        System.assertEquals(0, deletedAcc.size(), 'Account should be deleted.');
        System.assertEquals('Closed Lost', oppList.get(0).StageName, 'Wrong stagename.');
        System.assertEquals('Duplicate', oppList.get(0).Gruende_verloren__c, 'Wrong reason lost.');
        System.assertEquals('Already in process', controller.activeSubstep, 'Expected stop process.');
    }


    /*******************************************************************************
    *  Name            : dupLogicAlreadyInProcessPSDeposit()
    *  Summary         : Verify that two Accounts were merged when Company Names / TAX ID / VAT ID are the same
    *  ExpectedResult  : E2E Account #2 is delete. Account #1 is updated. E2E Opportunity #2 is created. Opportunity #2 Stage = Closed Lost.
                         Reason = Duplicate. Notification was sent to the Opportunity Owner Error 'Already in Proccess..' is displayed
    *  CreatedDate     : 26/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void dupLogicAlreadyInProcessPSDeposit() {
        Account account2 = E2ELongFormUtilsTest.createAccountForTestDuplactes();
        account2.Name = 'Kundentestsystem Energie und Wasser AG - BITTE NICHT ÄNDERN';
        account2.Umsatzsteuer_ID__c = 'DE821235454';
        account2.Steuernummer__c = '234154542';
        insert account2;

        Opportunity opportunity2 = E2ELongFormUtilsTest.createOpportunityForTestDuplactes(account2.Id);
        opportunity2.StageName = 'Pending Sales – Deposit';
        opportunity2.Home_Station__c = 'test';
        opportunity2.ESI__c = 'test';
        insert opportunity2;

        Contact contact2 = E2ELongFormUtilsTest.createContactDE(account2.Id);
        insert contact2;

        OpportunityContactRole oppContactRole2 = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity2.Id, contact2.Id);
        insert oppContactRole2;

        // create duplicate account
        Account account = E2ELongFormUtilsTest.createAccountForTestDuplactes();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityForTestDuplactes(account.Id);
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactDE(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EForm');
        update opportunity;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormController();
        controller.init();
        controller.selectedAvailableCompanyCreditScoring = new CreditCompany();
        controller.selectedAvailableCompanyCreditScoring.identificationnumber = '03453452013902';
        controller.deleteReportsForPreviousCompany();

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformEntrepreneurialCompanyMock());
            controller.goToSetTotalConsumption();
        Test.stopTest();

        List<Account> accList = [SELECT Id, Name, BillingCity, (SELECT Id FROM Opportunities) FROM Account WHERE Id = :account2.Id];
        List<Account> deletedAcc = [SELECT Id FROM Account WHERE Id = :account.Id];
        List<Opportunity> oppList = [SELECT StageName, Gruende_verloren__c FROM Opportunity WHERE Id = :opportunity.Id];

        System.assertEquals(2, accList.get(0).Opportunities.size(), 'Wrong count of Opportunities.');
        System.assertEquals(0, deletedAcc.size(), 'Account should be deleted.');
        System.assertEquals('Closed Lost', oppList.get(0).StageName, 'Wrong stagename.');
        System.assertEquals('Duplicate', oppList.get(0).Gruende_verloren__c, 'Wrong reason lost.');
        System.assertEquals('Already in process', controller.activeSubstep, 'Expected stop process.');
    }


    /*******************************************************************************
    *  Name            : dupLogicAlreadyInProcessPCredit()
    *  Summary         : Verify that two Accounts were merged when Company Names / TAX ID / VAT ID are the same
    *  ExpectedResult  : E2E Account #2 is delete. Account #1 is updated. E2E Opportunity #2 is created. Opportunity #2 Stage = Closed Lost.
                         Reason = Duplicate. Notification was sent to the Opportunity Owner Error 'Already in Proccess..' is displayed
    *  CreatedDate     : 26/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void dupLogicAlreadyInProcessPCredit() {
        Account account2 = E2ELongFormUtilsTest.createAccountForTestDuplactes();
        account2.Name = 'Kundentestsystem Energie und Wasser AG - BITTE NICHT ÄNDERN';
        account2.Umsatzsteuer_ID__c = 'DE821235454';
        account2.Steuernummer__c = '234154542';
        insert account2;

        Opportunity opportunity2 = E2ELongFormUtilsTest.createOpportunityForTestDuplactes(account2.Id);
        opportunity2.StageName = 'Pending Credit';
        opportunity2.Home_Station__c = 'test';
        opportunity2.ESI__c = 'test';
        insert opportunity2;

        Contact contact2 = E2ELongFormUtilsTest.createContactDE(account2.Id);
        insert contact2;

        OpportunityContactRole oppContactRole2 = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity2.Id, contact2.Id);
        insert oppContactRole2;

        // create duplicate account
        Account account = E2ELongFormUtilsTest.createAccountForTestDuplactes();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityForTestDuplactes(account.Id);
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactDE(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EForm');
        update opportunity;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormController();
        controller.init();
        controller.selectedAvailableCompanyCreditScoring = new CreditCompany();
        controller.selectedAvailableCompanyCreditScoring.identificationnumber = '03453452013902';
        controller.deleteReportsForPreviousCompany();

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformEntrepreneurialCompanyMock());
            controller.goToSetTotalConsumption();
        Test.stopTest();

        List<Account> accList = [SELECT Id, Name, BillingCity, (SELECT Id FROM Opportunities) FROM Account WHERE Id = :account2.Id];
        List<Account> deletedAcc = [SELECT Id FROM Account WHERE Id = :account.Id];
        List<Opportunity> oppList = [SELECT StageName, Gruende_verloren__c FROM Opportunity WHERE Id = :opportunity.Id];

        System.assertEquals(2, accList.get(0).Opportunities.size(), 'Wrong count of Opportunities.');
        System.assertEquals(0, deletedAcc.size(), 'Account should be deleted.');
        System.assertEquals('Closed Lost', oppList.get(0).StageName, 'Wrong stagename.');
        System.assertEquals('Duplicate', oppList.get(0).Gruende_verloren__c, 'Wrong reason lost.');
        System.assertEquals('Already in process', controller.activeSubstep, 'Expected stop process.');
    }


    /*******************************************************************************
    *  Name            : dupLogicAlreadyInProcessPSSepa()
    *  Summary         : Verify that two Accounts were merged when Company Names / TAX ID / VAT ID are the same
    *  ExpectedResult  : E2E Account #2 is delete. Account #1 is updated. E2E Opportunity #2 is created. Opportunity #2 Stage = Closed Lost.
                         Reason = Duplicate. Notification was sent to the Opportunity Owner Error 'Already in Proccess..' is displayed
    *  CreatedDate     : 26/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void dupLogicAlreadyInProcessPSSepa() {
        Account account2 = E2ELongFormUtilsTest.createAccountForTestDuplactes();
        account2.Name = 'Kundentestsystem Energie und Wasser AG - BITTE NICHT ÄNDERN';
        account2.Umsatzsteuer_ID__c = 'DE821235454';
        account2.Steuernummer__c = '234154542';
        insert account2;

        Opportunity opportunity2 = E2ELongFormUtilsTest.createOpportunityForTestDuplactes(account2.Id);
        opportunity2.StageName = 'Pending Sales - SEPA Confirmation';
        opportunity2.Home_Station__c = 'test';
        opportunity2.ESI__c = 'test';
        insert opportunity2;

        Contact contact2 = E2ELongFormUtilsTest.createContactDE(account2.Id);
        insert contact2;

        OpportunityContactRole oppContactRole2 = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity2.Id, contact2.Id);
        insert oppContactRole2;

        // create duplicate account
        Account account = E2ELongFormUtilsTest.createAccountForTestDuplactes();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityForTestDuplactes(account.Id);
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactDE(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EForm');
        update opportunity;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormController();
        controller.init();
        controller.selectedAvailableCompanyCreditScoring = new CreditCompany();
        controller.selectedAvailableCompanyCreditScoring.identificationnumber = '03453452013902';
        controller.deleteReportsForPreviousCompany();

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformEntrepreneurialCompanyMock());
            controller.goToSetTotalConsumption();
        Test.stopTest();

        List<Account> accList = [SELECT Id, Name, BillingCity, (SELECT Id FROM Opportunities) FROM Account WHERE Id = :account2.Id];
        List<Account> deletedAcc = [SELECT Id FROM Account WHERE Id = :account.Id];
        List<Opportunity> oppList = [SELECT StageName, Gruende_verloren__c FROM Opportunity WHERE Id = :opportunity.Id];

        System.assertEquals(2, accList.get(0).Opportunities.size(), 'Wrong count of Opportunities.');
        System.assertEquals(0, deletedAcc.size(), 'Account should be deleted.');
        System.assertEquals('Closed Lost', oppList.get(0).StageName, 'Wrong stagename.');
        System.assertEquals('Duplicate', oppList.get(0).Gruende_verloren__c, 'Wrong reason lost.');
        System.assertEquals('Already in process', controller.activeSubstep, 'Expected stop process.');
    }


    /*******************************************************************************
    *  Name            : dupLogicAlreadyInProcessClosedLost()
    *  Summary         : Verify that two Accounts were merged when Company Names / TAX ID / VAT ID are the same
    *  ExpectedResult  : E2E Account #2 is delete. Account #1 is updated. E2E Opportunity #2 is created. Opportunity #2 Stage = Closed Lost.
                         Reason = Duplicate. Notification was sent to the Opportunity Owner Error 'Already in Proccess..' is displayed
    *  CreatedDate     : 26/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void dupLogicAlreadyInProcessClosedLost() {
        Account account2 = E2ELongFormUtilsTest.createAccountForTestDuplactes();
        account2.Name = 'Kundentestsystem Energie und Wasser AG - BITTE NICHT ÄNDERN';
        account2.Umsatzsteuer_ID__c = 'DE821235454';
        account2.Steuernummer__c = '234154542';
        insert account2;

        Opportunity opportunity2 = E2ELongFormUtilsTest.createOpportunityForTestDuplactes(account2.Id);
        opportunity2.StageName = 'Closed Lost';
        opportunity2.Gruende_verloren__c = 'Refused Credit';
        insert opportunity2;

        opportunity2.CloseDate = Date.today().addDays(10);
        update opportunity2;

        Contact contact2 = E2ELongFormUtilsTest.createContactDE(account2.Id);
        insert contact2;

        OpportunityContactRole oppContactRole2 = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity2.Id, contact2.Id);
        insert oppContactRole2;

        // create duplicate account
        Account account = E2ELongFormUtilsTest.createAccountForTestDuplactes();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityForTestDuplactes(account.Id);
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactDE(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EForm');
        update opportunity;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormController();
        controller.init();
        controller.selectedAvailableCompanyCreditScoring = new CreditCompany();
        controller.selectedAvailableCompanyCreditScoring.identificationnumber = '03453452013902';
        controller.deleteReportsForPreviousCompany();

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformEntrepreneurialCompanyMock());
            controller.goToSetTotalConsumption();
        Test.stopTest();

        List<Account> accList = [SELECT Id, Name, BillingCity, (SELECT Id FROM Opportunities) FROM Account WHERE Id = :account2.Id];
        List<Account> deletedAcc = [SELECT Id FROM Account WHERE Id = :account.Id];
        List<Opportunity> oppList = [SELECT StageName, Gruende_verloren__c FROM Opportunity WHERE Id = :opportunity.Id];

        System.assertEquals(2, accList.get(0).Opportunities.size(), 'Wrong count of Opportunities.');
        System.assertEquals(0, deletedAcc.size(), 'Account should be deleted.');
        System.assertEquals('Closed Lost', oppList.get(0).StageName, 'Wrong stagename.');
        System.assertEquals('Duplicate', oppList.get(0).Gruende_verloren__c, 'Wrong reason lost.');
        System.assertEquals('Already in process', controller.activeSubstep, 'Expected stop process.');
    }


    /*******************************************************************************
    *  Name            : dupLogicAlreadyInProcessCreditCheckAbgelehnt()
    *  Summary         : Verify that two Accounts were merged when Company Names / TAX ID / VAT ID are the same
    *  ExpectedResult  : E2E Account #2 is delete. Account #1 is updated. E2E Opportunity #2 is created. Opportunity #2 Stage = Closed Lost.
                         Reason = Duplicate. Notification was sent to the Opportunity Owner Error 'Already in Proccess..' is displayed
    *  CreatedDate     : 26/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void dupLogicAlreadyInProcessCreditCheckAbgelehnt() {
        Account account2 = E2ELongFormUtilsTest.createAccountForTestDuplactes();
        account2.Name = 'Kundentestsystem Energie und Wasser AG - BITTE NICHT ÄNDERN';
        account2.Umsatzsteuer_ID__c = 'DE821235454';
        account2.Steuernummer__c = '234154542';
        insert account2;

        Opportunity opportunity2 = E2ELongFormUtilsTest.createOpportunityForTestDuplactes(account2.Id);
        opportunity2.StageName = 'CreditCheck abgelehnt';
        insert opportunity2;

        opportunity2.CloseDate = Date.today().addDays(10);
        update opportunity2;

        Contact contact2 = E2ELongFormUtilsTest.createContactDE(account2.Id);
        insert contact2;

        OpportunityContactRole oppContactRole2 = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity2.Id, contact2.Id);
        insert oppContactRole2;

        // create duplicate account
        Account account = E2ELongFormUtilsTest.createAccountForTestDuplactes();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityForTestDuplactes(account.Id);
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactDE(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EForm');
        update opportunity;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormController();
        controller.init();
        controller.selectedAvailableCompanyCreditScoring = new CreditCompany();
        controller.selectedAvailableCompanyCreditScoring.identificationnumber = '03453452013902';
        controller.deleteReportsForPreviousCompany();

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformEntrepreneurialCompanyMock());
            controller.goToSetTotalConsumption();
        Test.stopTest();

        List<Account> accList = [SELECT Id, Name, BillingCity, (SELECT Id FROM Opportunities) FROM Account WHERE Id = :account2.Id];
        List<Account> deletedAcc = [SELECT Id FROM Account WHERE Id = :account.Id];
        List<Opportunity> oppList = [SELECT StageName, Gruende_verloren__c FROM Opportunity WHERE Id = :opportunity.Id];

        System.assertEquals(2, accList.get(0).Opportunities.size(), 'Wrong count of Opportunities.');
        System.assertEquals(0, deletedAcc.size(), 'Account should be deleted.');
        System.assertEquals('Closed Lost', oppList.get(0).StageName, 'Wrong stagename.');
        System.assertEquals('Duplicate', oppList.get(0).Gruende_verloren__c, 'Wrong reason lost.');
        System.assertEquals('Already in process', controller.activeSubstep, 'Expected stop process.');
    }


    /*******************************************************************************
    *  Name            : dupLogicAlreadyCustomer()
    *  Summary         : Verify that two Accounts were merged when Company Names / TAX ID / VAT ID are the same
    *  ExpectedResult  : E2E Account #2 is delete. Account #1 is updated. E2E Opportunity #2 is created. Opportunity #1 Owner = Y. Aden-Farah
                         Account #1 Owner = Y. Aden-Farah Notification was sent to Starts team Error 'Already Customer..' is displayed
    *  CreatedDate     : 26/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void dupLogicAlreadyCustomer() {
        Account account2 = E2ELongFormUtilsTest.createAccountForTestDuplactes();
        account2.Name = 'Kundentestsystem Energie und Wasser AG - BITTE NICHT ÄNDERN';
        account2.Umsatzsteuer_ID__c = 'DE821235454';
        account2.Steuernummer__c = '234154542';
        insert account2;

        Opportunity opportunity2 = E2ELongFormUtilsTest.createOpportunityForTestDuplactes(account2.Id);
        opportunity2.StageName = 'Closed Won';
        insert opportunity2;

        Contact contact2 = E2ELongFormUtilsTest.createContactDE(account2.Id);
        insert contact2;

        OpportunityContactRole oppContactRole2 = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity2.Id, contact2.Id);
        insert oppContactRole2;

        // create duplicate account
        Account account = E2ELongFormUtilsTest.createAccountForTestDuplactes();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityForTestDuplactes(account.Id);
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactDE(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EForm');
        update opportunity;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormController();
        controller.init();
        controller.selectedAvailableCompanyCreditScoring = new CreditCompany();
        controller.selectedAvailableCompanyCreditScoring.identificationnumber = '03453452013902';
        controller.deleteReportsForPreviousCompany();

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformEntrepreneurialCompanyMock());
            controller.goToSetTotalConsumption();
        Test.stopTest();

        List<Account> accList = [SELECT Id, Name, BillingCity, (SELECT Id FROM Opportunities) FROM Account WHERE Id = :account2.Id];
        List<Account> deletedAcc = [SELECT Id FROM Account WHERE Id = :account.Id];
        List<Opportunity> oppList = [SELECT Owner.Name FROM Opportunity WHERE Id = :opportunity.Id];

        System.assertEquals(2, accList.get(0).Opportunities.size(), 'Wrong count of Opportunities.');
        System.assertEquals(0, deletedAcc.size(), 'Account should be deleted.');
        System.assertEquals('Y. Aden-Farah', oppList.get(0).Owner.Name, 'Wrong onwer.');
        System.assertEquals('Already a customer', controller.activeSubstep, 'Expected stop process.');
    }


    /*******************************************************************************
    *  Name            : dupLogicCreditCheckAbgelehnt()
    *  Summary         : Verify that two Accounts were merged when Company Names / TAX ID / VAT ID are the same
    *  ExpectedResult  : E2E Account #2 is delete. Account #1 is updated. E2E Opportunity #2 is created. Opportunity #2 Stage = Closed Lost.
                         Reason = Duplicate. Notification was sent to Credit user Notification was sent to the Opportunity Owner
    *  CreatedDate     : 26/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void dupLogicCreditCheckAbgelehnt() {
        Account account2 = E2ELongFormUtilsTest.createAccountForTestDuplactes();
        account2.Name = 'Kundentestsystem Energie und Wasser AG - BITTE NICHT ÄNDERN';
        account2.Umsatzsteuer_ID__c = 'DE821235454';
        account2.Steuernummer__c = '234154542';
        insert account2;

        Opportunity opportunity2 = E2ELongFormUtilsTest.createOpportunityForTestDuplactes(account2.Id);
        opportunity2.StageName = 'CreditCheck abgelehnt';
        insert opportunity2;

        opportunity2.CloseDate = Date.today().addDays(-100);
        update opportunity2;

        Contact contact2 = E2ELongFormUtilsTest.createContactDE(account2.Id);
        insert contact2;

        OpportunityContactRole oppContactRole2 = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity2.Id, contact2.Id);
        insert oppContactRole2;

        // create duplicate account
        Account account = E2ELongFormUtilsTest.createAccountForTestDuplactes();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityForTestDuplactes(account.Id);
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactDE(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EForm');
        update opportunity;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormController();
        controller.init();
        controller.selectedAvailableCompanyCreditScoring = new CreditCompany();
        controller.selectedAvailableCompanyCreditScoring.identificationnumber = '03453452013902';
        controller.deleteReportsForPreviousCompany();

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformEntrepreneurialCompanyMock());
            controller.goToSetTotalConsumption();
        Test.stopTest();

        List<Account> accList = [SELECT Id, Name, BillingCity, (SELECT Id FROM Opportunities) FROM Account WHERE Id = :account2.Id];
        List<Account> deletedAcc = [SELECT Id FROM Account WHERE Id = :account.Id];
        List<Opportunity> oppList = [SELECT StageName, Gruende_verloren__c FROM Opportunity WHERE Id = :opportunity2.Id];

        System.assertEquals(2, accList.get(0).Opportunities.size(), 'Wrong count of Opportunities.');
        System.assertEquals(0, deletedAcc.size(), 'Account should be deleted.');
        System.assertEquals('Closed Lost', oppList.get(0).StageName, 'Wrong stagename.');
        System.assertEquals('Switched to E2E', oppList.get(0).Gruende_verloren__c, 'Wrong reason lost.');
    }


    /*******************************************************************************
    *  Name            : goToCardConfigNonDepositTest()
    *  Summary         : Verify all fields when you go from 1 step to 2 step 
    *  CreatedDate     : 26/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void goToCardConfigNonDepositTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Prospecting';
        opportunity.E2E_Active_Step__c = 1;
        opportunity.E2E_Active_Substep__c = 'Calculating credit score';
        opportunity.Zahlungsart__c = '';
        opportunity.Rechnungsperiode__c = '';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactDE(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        ApexPages.currentPage().getparameters().put('country', 'Germany');

        controller = new LongFormController();
        controller.init();
        controller.country = 'Germany';
        controller.activeStep = 1;
        controller.initPageElements();
        controller.initSObjects(opportunity.Id);
        controller.selectedAvailableCompanyCreditScoring = new CreditCompany();
        controller.selectedAvailableCompanyCreditScoring.identificationnumber = '03453452015622';
        controller.deleteReportsForPreviousCompany();

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new E2ELongFromCreditFactoryMock());
            controller.goToSetTotalConsumption();
        Test.stopTest();

        // Verify that opportunity.E2E_Active_Substep__c field is updated when reportResponse.Tax_Id__c = null && reportResponse.Tax_Id__c = null
        controller.cfReportResponse.company.taxnumber = '12345678910';
        controller.continueToTotalConsumption();

        // Verify that opportunity.E2E_Active_Substep__c field is updated when reportResponse.Tax_Id__c != null || reportResponse.Tax_Id__c != null
        List<Opportunity> opptyList = [SELECT E2E_Active_Substep__c, E2E_Active_Step__c FROM Opportunity WHERE Id = :opportunity.Id];
        System.assertEquals('Set total consumption', opptyList.get(0).E2E_Active_Substep__c, 'Should be Automatic filling by default');
        System.assertEquals(1, opptyList.get(0).E2E_Active_Step__c, 'Should be Automatic filling by default');

        controller.stepPagesMap.get('CREDIT SCORE. TOTAL CONSUMPTION').fields.get('TOTAL CONSUMPTION').elementItemsMap.get('DEFAULT VALUE').Value__c = '1000';
        controller.doCalculateCreditScoring();
        // calculate Lastschrift weekly credit score data
        controller.stepPagesMap.get('CREDIT SCORE. SCORING RESULT').fields.get('PAYMENT METHOD').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Lastschrift';
        controller.defaultBillingPeriod = 7;
        controller.changeBillingPeriod();
        controller.stepPagesMap.get('CREDIT SCORE. SCORING RESULT').fields.get('BILLING PERIOD').elementItemsMap.get('WEEKLY BUTTON NAME').Value__c = '7';
        controller.returnFinalCreditScoreData();
        controller.doRecalculateDeposit();
        // calculacte Lastschrift BI-weekly credit score data
        controller.stepPagesMap.get('CREDIT SCORE. SCORING RESULT').fields.get('PAYMENT METHOD').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Lastschrift';
        controller.defaultBillingPeriod = 15;
        controller.changeBillingPeriod();
        controller.stepPagesMap.get('CREDIT SCORE. SCORING RESULT').fields.get('BILLING PERIOD').elementItemsMap.get('BI-WEEKLY BUTTON NAME').Value__c = '15';
        controller.returnFinalCreditScoreData();
        controller.doRecalculateDeposit();
        // calculacte Banküberweisung BI-weekly credit score data
        controller.stepPagesMap.get('CREDIT SCORE. SCORING RESULT').fields.get('PAYMENT METHOD').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Banküberweisung';
        controller.defaultBillingPeriod = 15;
        controller.changeBillingPeriod();
        controller.stepPagesMap.get('CREDIT SCORE. SCORING RESULT').fields.get('BILLING PERIOD').elementItemsMap.get('BI-WEEKLY BUTTON NAME').Value__c = '15';
        controller.returnFinalCreditScoreData();
        controller.doRecalculateDeposit();
        // calculacte Banküberweisung Monthly credit score data
        controller.stepPagesMap.get('CREDIT SCORE. SCORING RESULT').fields.get('PAYMENT METHOD').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Banküberweisung';
        controller.defaultBillingPeriod = 30;
        controller.changeBillingPeriod();
        controller.stepPagesMap.get('CREDIT SCORE. SCORING RESULT').fields.get('BILLING PERIOD').elementItemsMap.get('MONTHLY BUTTON NAME').Value__c = '30';
        controller.returnFinalCreditScoreData();
        controller.doRecalculateDeposit();
        // calculacte Lastschrift Monthly credit score data
        controller.stepPagesMap.get('CREDIT SCORE. SCORING RESULT').fields.get('PAYMENT METHOD').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Lastschrift';
        controller.defaultBillingPeriod = 30;
        controller.changeBillingPeriod();
        controller.stepPagesMap.get('CREDIT SCORE. SCORING RESULT').fields.get('BILLING PERIOD').elementItemsMap.get('MONTHLY BUTTON NAME').Value__c = '30';
        controller.returnFinalCreditScoreData();
        controller.doRecalculateDeposit();
        controller.goToCardsConfig();

        List<Opportunity> oppList = [
                SELECT StageName, Zahlungsart__c, Rechnungsperiode__c, CF_Credit_Limit__c, Zahlungsziel_Credit__c, Security_To_Pay__c, Security_Amount_To_Pay__c, 
                        Kredit_Entscheidung__c, Credit_check_date__c, bearbeitet_von__c, Billing_Period_by_Sales__c, Pending_Deposit_by_CF__c, CF_Stage__c, Max_Credit_Limit__c, 
                        Credit_System_Rating__c, Security_level_H_he_der_Sicherheit__c, Garantie__c, Buffer__c, Risk_Category__c, E2E_Active_Step__c, E2E_Active_Substep__c 
                FROM Opportunity 
                WHERE Id = :opportunity.Id];

        System.assertEquals('Credit approved', oppList.get(0).StageName, 'Wrong stage name.');
        System.assertEquals('Lastschrift', oppList.get(0).Zahlungsart__c, 'Wrong payment method.');
        System.assertEquals('30', oppList.get(0).Rechnungsperiode__c, 'Wrong billing period.');
        System.assertEquals('7', oppList.get(0).Zahlungsziel_Credit__c, 'Wrong Payment terms Credit.');
        System.assertEquals(null, oppList.get(0).Security_To_Pay__c, 'Wrong security to pay.');
        System.assertEquals(2100, oppList.get(0).Security_Amount_To_Pay__c, 'Wrong security amount to pay.');
        System.assertEquals('Genehmigt', oppList.get(0).Kredit_Entscheidung__c, 'Wrong Credit Decision.');
        System.assertEquals(Date.today(), oppList.get(0).Credit_check_date__c, 'Wrong Credit check date.');
        System.assertEquals('Autoprocessed by E2E', oppList.get(0).bearbeitet_von__c, 'Should be pre filling by default.');
        System.assertEquals(false, oppList.get(0).Billing_Period_by_Sales__c, 'Wrong billing period by Sales.');
        System.assertEquals(false, oppList.get(0).Pending_Deposit_by_CF__c, 'Wrong deposit by CF.');
        System.assertEquals('Not launched', oppList.get(0).CF_Stage__c, 'Wrong CF Stage.');
        System.assertEquals('1', oppList.get(0).Credit_System_Rating__c, 'Wrong credit system rating.');
        System.assertEquals(null, oppList.get(0).Security_level_H_he_der_Sicherheit__c, 'Wrong company classrating.');
        System.assertEquals(null, oppList.get(0).Garantie__c, 'Wrong security.');
        System.assertEquals(30, oppList.get(0).Buffer__c, 'Wrong buffer.');
        System.assertEquals('Low', oppList.get(0).Risk_Category__c, 'Wrong category of risk.');
        System.assertEquals(2, oppList.get(0).E2E_Active_Step__c, 'Wrong active step.');
        System.assertEquals('Card configuration', oppList.get(0).E2E_Active_Substep__c, 'Wrong active sub step.');
    }


    /*******************************************************************************
    *  Name            : goToCardConfigDepositTest()
    *  Summary         : Verify all fields when you go from 1 step to 2 step 
    *  CreatedDate     : 26/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void goToCardConfigDepositTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Prospecting';
        opportunity.E2E_Active_Step__c = 1;
        opportunity.E2E_Active_Substep__c = 'Calculating credit score';
        opportunity.Zahlungsart__c = '';
        opportunity.Rechnungsperiode__c = '';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactDE(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        ApexPages.currentPage().getparameters().put('country', 'Germany');

        controller = new LongFormController();
        controller.init();
        controller.country = 'Germany';
        controller.activeStep = 1;
        controller.initPageElements();
        controller.initSObjects(opportunity.Id);
        controller.selectedAvailableCompanyCreditScoring = new CreditCompany();
        controller.selectedAvailableCompanyCreditScoring.identificationnumber = '03453452015622';
        controller.deleteReportsForPreviousCompany();

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new E2ELongFromCreditFactoryMock());
            controller.goToSetTotalConsumption();
        Test.stopTest();

        // Verify that opportunity.E2E_Active_Substep__c field is updated when reportResponse.Tax_Id__c = null && reportResponse.Tax_Id__c = null
        controller.cfReportResponse.company.taxnumber = '12345678910';
        controller.continueToTotalConsumption();

        // Verify that opportunity.E2E_Active_Substep__c field is updated when reportResponse.Tax_Id__c != null || reportResponse.Tax_Id__c != null
        List<Opportunity> opptyList = [SELECT E2E_Active_Substep__c, E2E_Active_Step__c FROM Opportunity WHERE Id = :opportunity.Id];
        System.assertEquals('Set total consumption', opptyList.get(0).E2E_Active_Substep__c, 'Should be Automatic filling by default');
        System.assertEquals(1, opptyList.get(0).E2E_Active_Step__c, 'Should be Automatic filling by default');

        controller.stepPagesMap.get('CREDIT SCORE. TOTAL CONSUMPTION').fields.get('TOTAL CONSUMPTION').elementItemsMap.get('DEFAULT VALUE').Value__c = '1000';
        controller.doCalculateCreditScoring();
        // calculate Lastschrift weekly credit score data
        controller.stepPagesMap.get('CREDIT SCORE. SCORING RESULT').fields.get('PAYMENT METHOD').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Lastschrift';
        controller.defaultBillingPeriod = 7;
        controller.changeBillingPeriod();
        controller.stepPagesMap.get('CREDIT SCORE. SCORING RESULT').fields.get('BILLING PERIOD').elementItemsMap.get('WEEKLY BUTTON NAME').Value__c = '7';
        controller.returnFinalCreditScoreData();
        controller.doRecalculateDeposit();
        // calculacte Lastschrift BI-weekly credit score data
        controller.stepPagesMap.get('CREDIT SCORE. SCORING RESULT').fields.get('PAYMENT METHOD').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Lastschrift';
        controller.defaultBillingPeriod = 15;
        controller.changeBillingPeriod();
        controller.stepPagesMap.get('CREDIT SCORE. SCORING RESULT').fields.get('BILLING PERIOD').elementItemsMap.get('BI-WEEKLY BUTTON NAME').Value__c = '15';
        controller.returnFinalCreditScoreData();
        controller.doRecalculateDeposit();
        // calculacte Banküberweisung BI-weekly credit score data
        controller.stepPagesMap.get('CREDIT SCORE. SCORING RESULT').fields.get('PAYMENT METHOD').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Banküberweisung';
        controller.defaultBillingPeriod = 15;
        controller.changeBillingPeriod();
        controller.stepPagesMap.get('CREDIT SCORE. SCORING RESULT').fields.get('BILLING PERIOD').elementItemsMap.get('BI-WEEKLY BUTTON NAME').Value__c = '15';
        controller.returnFinalCreditScoreData();
        controller.doRecalculateDeposit();
        // calculacte Banküberweisung Monthly credit score data
        controller.stepPagesMap.get('CREDIT SCORE. SCORING RESULT').fields.get('PAYMENT METHOD').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Banküberweisung';
        controller.defaultBillingPeriod = 30;
        controller.changeBillingPeriod();
        controller.stepPagesMap.get('CREDIT SCORE. SCORING RESULT').fields.get('BILLING PERIOD').elementItemsMap.get('MONTHLY BUTTON NAME').Value__c = '30';
        controller.returnFinalCreditScoreData();
        controller.doRecalculateDeposit();
        // calculacte Lastschrift Monthly credit score data
        controller.stepPagesMap.get('CREDIT SCORE. SCORING RESULT').fields.get('PAYMENT METHOD').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Lastschrift';
        controller.defaultBillingPeriod = 30;
        controller.changeBillingPeriod();
        controller.stepPagesMap.get('CREDIT SCORE. SCORING RESULT').fields.get('BILLING PERIOD').elementItemsMap.get('MONTHLY BUTTON NAME').Value__c = '30';
        controller.returnFinalCreditScoreData();
        controller.doRecalculateDeposit();
        controller.deposit = 2000;
        controller.goToCardsConfig();

        List<Opportunity> oppList = [
                SELECT StageName, Zahlungsart__c, Rechnungsperiode__c, CF_Credit_Limit__c, Zahlungsziel_Credit__c, Security_To_Pay__c, Security_Amount_To_Pay__c, 
                        Kredit_Entscheidung__c, Credit_check_date__c, bearbeitet_von__c, Billing_Period_by_Sales__c, Pending_Deposit_by_CF__c, CF_Stage__c, Max_Credit_Limit__c, 
                        Credit_System_Rating__c, Security_level_H_he_der_Sicherheit__c, Garantie__c, Buffer__c, Risk_Category__c, E2E_Active_Step__c, E2E_Active_Substep__c 
                FROM Opportunity 
                WHERE Id = :opportunity.Id];

        System.assertEquals('Credit approved', oppList.get(0).StageName, 'Wrong stage name.');
        System.assertEquals('Lastschrift', oppList.get(0).Zahlungsart__c, 'Wrong payment method.');
        System.assertEquals('30', oppList.get(0).Rechnungsperiode__c, 'Wrong billing period.');
        System.assertEquals(2200, oppList.get(0).CF_Credit_Limit__c, 'Wrong CF Credit limit.');
        System.assertEquals('7', oppList.get(0).Zahlungsziel_Credit__c, 'Wrong Payment terms Credit.');
        System.assertEquals('Kaution', oppList.get(0).Security_To_Pay__c, 'Wrong security to pay.');
        System.assertEquals(2000, oppList.get(0).Security_Amount_To_Pay__c, 'Wrong security amount to pay.');
        System.assertEquals('Sicherheit verlangt', oppList.get(0).Kredit_Entscheidung__c, 'Wrong Credit Decision.');
        System.assertEquals(Date.today(), oppList.get(0).Credit_check_date__c, 'Wrong Credit check date.');
        System.assertEquals('Autoprocessed by E2E', oppList.get(0).bearbeitet_von__c, 'Should be pre filling by default.');
        System.assertEquals(true, oppList.get(0).Billing_Period_by_Sales__c, 'Wrong billing period by Sales.');
        System.assertEquals(true, oppList.get(0).Pending_Deposit_by_CF__c, 'Wrong deposit by CF.');
        System.assertEquals('Pending deposit', oppList.get(0).CF_Stage__c, 'Wrong CF Stage.');
        System.assertEquals(2200, oppList.get(0).Max_Credit_Limit__c, 'Wrong max credit limit.');
        System.assertEquals('1', oppList.get(0).Credit_System_Rating__c, 'Wrong credit system rating.');
        System.assertEquals(null, oppList.get(0).Security_level_H_he_der_Sicherheit__c, 'Wrong company classrating.');
        System.assertEquals(null, oppList.get(0).Garantie__c, 'Wrong security.');
        System.assertEquals(30, oppList.get(0).Buffer__c, 'Wrong buffer.');
        System.assertEquals('Low', oppList.get(0).Risk_Category__c, 'Wrong category of risk.');
        System.assertEquals(2, oppList.get(0).E2E_Active_Step__c, 'Wrong active step.');
        System.assertEquals('Card configuration', oppList.get(0).E2E_Active_Substep__c, 'Wrong active sub step.');
    }


    /*******************************************************************************
    *  Name            : cardConfigurationWithThreeCardsTest()
    *  Summary         : Testing card configuration step, add 3 diff card   
    *  CreatedDate     : 07/06/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void cardConfigurationWithThreeCardsTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.E2E_Active_Step__c = 2;
        opportunity.E2E_Active_Substep__c = 'Card configuration';
        insert opportunity;

        Tankkarten__c card1 = E2ELongFormUtilsTest.createMultiNetworkCardInternational(opportunity.Id);
        insert card1;

        Tankkarten__c card2 = E2ELongFormUtilsTest.createMultiNetworkCardNational(opportunity.Id);
        insert card2;

        Contact contact = E2ELongFormUtilsTest.createContactDE(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        Credit_Factory_Report__c cfReport = E2ELongFormUtilsTest.createCFReport(opportunity.Id);
        insert cfReport;

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EForm');
        update opportunity;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormController();
        controller.cardsConfigService = LongFormGlobalUtils.returnCardsConfigService('Germany');
        controller.init();
        controller.goToSpecialOffers();
        controller.backToCardConfiguration();

        controller.activeCardConfigTab = 'diff';
        controller.changeActiveTab();
        controller.numberOfCards = 4; 
        controller.changeNumberOfCards();      
        ApexPages.currentPage().getparameters().put('cardIndex', '1');
        controller.diffCardsMap.get(1).categoryCard = 'All vehicle related product';
        controller.diffCardsMap.get(1).pumpOutsideCountry = true;
        controller.diffCardsMap.get(1).pumpAtPartners = true;
        controller.addCard();
        ApexPages.currentPage().getparameters().put('cardIndex', '2');
        controller.diffCardsMap.get(2).categoryCard = 'All fuel types';
        controller.diffCardsMap.get(2).pumpOutsideCountry = true;
        controller.diffCardsMap.get(2).pumpAtPartners = false;
        controller.addCard();
        ApexPages.currentPage().getparameters().put('cardIndex', '3');
        controller.diffCardsMap.get(3).categoryCard = 'Diesel';
        controller.diffCardsMap.get(3).pumpOutsideCountry = false;
        controller.diffCardsMap.get(3).pumpAtPartners = false;
        controller.addCard();
        ApexPages.currentPage().getparameters().put('cardIndex', '4');
        controller.diffCardsMap.get(4).categoryCard = 'Diesel';
        controller.diffCardsMap.get(4).pumpOutsideCountry = false;
        controller.diffCardsMap.get(4).pumpAtPartners = true;
        controller.addCard();
        controller.goToSpecialOffers();
        // testing back button and remove cards
        controller.backToCardConfiguration();
        ApexPages.currentPage().getparameters().put('cardIndex', '1');
        controller.removeCard();
        ApexPages.currentPage().getparameters().put('cardIndex', '2');
        controller.removeCard();
        ApexPages.currentPage().getparameters().put('cardIndex', '3');
        controller.removeCard();
        controller.activeCardConfigTab = 'same';
        controller.changeActiveTab();
        controller.numberOfCards = 2; 
        controller.changeNumberOfCards();
        controller.sameCardsMap.get(1).categoryCard = 'All vehicle related product';
        controller.sameCardsMap.get(1).pumpOutsideCountry = false;
        controller.sameCardsMap.get(1).pumpAtPartners = false;
        controller.goToSpecialOffers();
        controller.editCompanyName();

        List<Opportunity> oppList = [
                SELECT StageName, E2E_Active_Step__c, E2E_Active_Substep__c, Anzahl_der_Karten__c, Total_number_of_vehicles__c, 
                    (SELECT Id FROM Tankkarten__r)
                FROM Opportunity 
                WHERE Id = :opportunity.Id];

        System.assertEquals(2, oppList.get(0).Tankkarten__r.size());
        System.assertEquals('Credit approved', oppList.get(0).StageName);
        System.assertEquals(2, oppList.get(0).E2E_Active_Step__c);
        System.assertEquals('Choosing offer', oppList.get(0).E2E_Active_Substep__c);
        System.assertEquals(2, oppList.get(0).Anzahl_der_Karten__c);
        System.assertEquals(2, oppList.get(0).Total_number_of_vehicles__c);
    }


    /*******************************************************************************
    *  Name            : choosingOfferTest()
    *  Summary         : Testing choosing offer step    
    *  CreatedDate     : 07/06/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void choosingOfferTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.E2E_Active_Step__c = 2;
        opportunity.E2E_Active_Substep__c = 'Choosing offer';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactDE(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        Credit_Factory_Report__c cfReport = E2ELongFormUtilsTest.createCFReport(opportunity.Id);
        insert cfReport;

        List<Tankkarten__c> cardsForInsert = new List<Tankkarten__c>();
        Tankkarten__c card1 = new Tankkarten__c(
            Opportunity__c = opportunity.Id,
            Gewuenschter_Kartentyp__c = 'Multi Network Card -- International',
            Produktbezugskategorie__c = '2 Kategorie 1 plus fahrzeugbezogene Waren und Dienstleistungen (Öle, Autowäsche)'
        );
        cardsForInsert.add(card1);

        Tankkarten__c card2 = new Tankkarten__c(
            Opportunity__c = opportunity.Id,
            Gewuenschter_Kartentyp__c = 'Multi Network Card -- National',
            Produktbezugskategorie__c = '1 Alle Kraftstoffe, Tunnel-, Maut- und Fährgebühren'
        );
        cardsForInsert.add(card2);

        Tankkarten__c card3 = new Tankkarten__c(
            Opportunity__c = opportunity.Id,
            Gewuenschter_Kartentyp__c = 'Single Network Card -- International',
            Produktbezugskategorie__c = '0 Diesel, Tunnel-, Maut- und Fährgebühren'
        );
        cardsForInsert.add(card3);

        Tankkarten__c card4 = new Tankkarten__c(
            Opportunity__c = opportunity.Id,
            Gewuenschter_Kartentyp__c = 'Single Network Card -- National',
            Produktbezugskategorie__c = '2 Kategorie 1 plus fahrzeugbezogene Waren und Dienstleistungen (Öle, Autowäsche)'
        );
        cardsForInsert.add(card4);
        
        insert cardsForInsert;

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EForm');
        update opportunity;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        ApexPages.currentPage().getParameters().put('offerName', 'Inbound Typ C');
        controller = new LongFormController();
        controller.cardsConfigService = LongFormGlobalUtils.returnCardsConfigService('Germany');
        controller.init();
        controller.selectOffer();
        // testing remove offer
        controller.removeOffer();
        controller.selectOffer();
        controller.chooseStation();
        controller.goToTechnicalParameters();
        // testing back button
        controller.backToSpecialOffers();

        ApexPages.currentPage().getparameters().put('cardindex', '1');
        controller.editCardConfiguration();

        List<Opportunity> opportunityList = [
                SELECT E2E_Active_Substep__c, Product__c, Home_Station__c, ESI__c, StageName, E2E_Active_Step__c
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals('Technical parameters', opportunityList.get(0).E2E_Active_Substep__c, 'Wrong stagename.');
        System.assertEquals('Inbound Typ C', opportunityList.get(0).Product__c, 'Wrong product.');
        System.assertEquals(null, opportunityList.get(0).Home_Station__c, 'Should be null fro this product.');
        System.assertEquals(null, opportunityList.get(0).ESI__c, 'Should be null fro this product.');
        System.assertEquals('Credit approved', opportunityList.get(0).StageName, 'Wrong stagename.');
        System.assertEquals(2, opportunityList.get(0).E2E_Active_Step__c, 'Wrong active step.');
    }


    /*******************************************************************************
    *  Name            : technicalParametersTest()
    *  Summary         : Testing technical parameters step    
    *  CreatedDate     : 07/06/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void technicalParametersTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.E2E_Active_Step__c = 2;
        opportunity.E2E_Active_Substep__c = 'Technical parameters';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactDE(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        Credit_Factory_Report__c cfReport = E2ELongFormUtilsTest.createCFReport(opportunity.Id);
        insert cfReport;

        List<Tankkarten__c> cardsForInsert = new List<Tankkarten__c>();
        Tankkarten__c card1 = new Tankkarten__c(
            Opportunity__c = opportunity.Id,
            Gewuenschter_Kartentyp__c = 'Multi Network Card -- International',
            Produktbezugskategorie__c = '2 Kategorie 1 plus fahrzeugbezogene Waren und Dienstleistungen (Öle, Autowäsche)'
        );
        cardsForInsert.add(card1);

        Tankkarten__c card2 = new Tankkarten__c(
            Opportunity__c = opportunity.Id,
            Gewuenschter_Kartentyp__c = 'Multi Network Card -- National',
            Produktbezugskategorie__c = '1 Alle Kraftstoffe, Tunnel-, Maut- und Fährgebühren'
        );
        cardsForInsert.add(card2);

        Tankkarten__c card3 = new Tankkarten__c(
            Opportunity__c = opportunity.Id,
            Gewuenschter_Kartentyp__c = 'Single Network Card -- International',
            Produktbezugskategorie__c = '0 Diesel, Tunnel-, Maut- und Fährgebühren'
        );
        cardsForInsert.add(card3);

        Tankkarten__c card4 = new Tankkarten__c(
            Opportunity__c = opportunity.Id,
            Gewuenschter_Kartentyp__c = 'Single Network Card -- National',
            Produktbezugskategorie__c = '2 Kategorie 1 plus fahrzeugbezogene Waren und Dienstleistungen (Öle, Autowäsche)'
        );
        cardsForInsert.add(card4);

        insert cardsForInsert;

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EForm');
        update opportunity;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormController();
        controller.init();
        ApexPages.currentPage().getparameters().put('cardindex', '1');
        controller.finalCardsMap.get(1).driverNameOrCarNumberInputValue = 'Shell Card 1';
        controller.finalCardsMap.get(1).companyNameInputValue = 'TEST';
        controller.finalCardsMap.get(1).selectedTypeOfCar = 'LKW';
        controller.finalCardsMap.get(1).needOdometerOptions = true;
        controller.saveTechParamForSingleCard();
        ApexPages.currentPage().getparameters().put('cardindex', '2');
        controller.finalCardsMap.get(2).driverNameOrCarNumberInputValue = 'Shell Card 2';
        controller.finalCardsMap.get(2).companyNameInputValue = 'TEST';
        controller.finalCardsMap.get(2).selectedTypeOfCar = 'PKW';
        controller.finalCardsMap.get(2).needOdometerOptions = true;
        controller.saveTechParamForSingleCard();
        ApexPages.currentPage().getparameters().put('cardindex', '3');
        controller.finalCardsMap.get(3).driverNameOrCarNumberInputValue = 'Shell Card 3';
        controller.finalCardsMap.get(3).companyNameInputValue = 'TEST';
        controller.finalCardsMap.get(3).selectedTypeOfCar = 'PKW';
        controller.finalCardsMap.get(3).needOdometerOptions = true;
        controller.saveTechParamForSingleCard();
        ApexPages.currentPage().getparameters().put('cardindex', '4');
        controller.finalCardsMap.get(4).driverNameOrCarNumberInputValue = 'Shell Card 4';
        controller.finalCardsMap.get(4).companyNameInputValue = 'TEST';
        controller.finalCardsMap.get(4).selectedTypeOfCar = 'LKW';
        controller.finalCardsMap.get(4).needOdometerOptions = false;
        controller.saveTechParamForSingleCard();
        controller.goToAdditionalParams();
        // testing case if account doesn't have VAT Number and client wants to get international card
        // not valid vat
        controller.stepPagesMap.get('CARD CONFIGURATION. INPUT VAT ID').fields.get('VAT NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = 'D12456789';
        controller.updateVatNumberAndGoToAdditionalStep();
        
        Test.startTest();
            Test.setMock(WebServiceMock.class, new EcEuropaEuMock());
            // valid vat number
            controller.stepPagesMap.get('CARD CONFIGURATION. INPUT VAT ID').fields.get('VAT NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = 'DE123456789';
            controller.updateVatNumberAndGoToAdditionalStep();
        Test.stopTest();
        // testing back button
        controller.backToTechnicalParams();
        ApexPages.currentPage().getparameters().put('cardindex', '1');
        controller.editTechnicalParameters();

        List<Opportunity> opportunityList = [
                SELECT StageName, E2E_Active_Step__c, E2E_Active_SubStep__c, Derzeitige_Zahlungsmethode__c, Number_of_cars__c, Number_of_trucks__c, 
                    Account.Umsatzsteuer_ID__c, Account.Beschaeftigte__c, 
                    (SELECT Id FROM Tankkarten__r)
                FROM Opportunity 
                WHERE Id = :opportunity.Id];

        System.assertEquals(4, opportunityList.get(0).Tankkarten__r.size(), 'Wrong number of cards.');
        System.assertEquals('Credit approved', opportunityList.get(0).StageName, 'Wrong stagename.');
        System.assertEquals(3, opportunityList.get(0).E2E_Active_Step__c, 'Wrong active step.');
        System.assertEquals('Additional services', opportunityList.get(0).E2E_Active_SubStep__c, 'Wrong active sub step.');
        System.assertEquals('Barzahlung', opportunityList.get(0).Derzeitige_Zahlungsmethode__c, 'Wrong Payment Method.');
        System.assertEquals(2, opportunityList.get(0).Number_of_cars__c, 'Wrong number of cars.');
        System.assertEquals(2, opportunityList.get(0).Number_of_trucks__c, 'Wrong number of trucks.');
        System.assertEquals('DE123456789', opportunityList.get(0).Account.Umsatzsteuer_ID__c, 'Wrong VAT ID.');
        System.assertEquals('1-4', opportunityList.get(0).Account.Beschaeftigte__c, 'Wrong number of Employee.');

        List<Tankkarten__c> card1List = [
                SELECT Produktbezugskategorie__c, Gewuenschter_Kartentyp__c, Driver_Name__c, KFZ_Kennzeichen_oder_Fahrername__c, Kilometerstand_Abfrage__c, 
                    Firmenname_auf_der_Karte__c, Fahrzeugtyp__c 
                FROM Tankkarten__c 
                WHERE Driver_Name__c = 'Shell Card 1'];
        System.assertEquals('2 Kategorie 1 plus fahrzeugbezogene Waren und Dienstleistungen (Öle, Autowäsche)', card1List.get(0).Produktbezugskategorie__c, 'Wrong name of product.');
        System.assertEquals('Multi Network Card -- International', card1List.get(0).Gewuenschter_Kartentyp__c, 'Wrong type of card.');
        System.assertEquals('Shell Card 1', card1List.get(0).Driver_Name__c, 'Wrong driver name.');
        System.assertEquals(true, card1List.get(0).Kilometerstand_Abfrage__c, 'Expected true.');
        System.assertEquals('TESTCOMPANY', card1List.get(0).Firmenname_auf_der_Karte__c, 'Wrong company name.');
        System.assertEquals('LKW', card1List.get(0).Fahrzeugtyp__c, 'Wrong type of vehicle.');

        List<Tankkarten__c> card2List = [
                SELECT Produktbezugskategorie__c, Gewuenschter_Kartentyp__c, Driver_Name__c, KFZ_Kennzeichen_oder_Fahrername__c, Kilometerstand_Abfrage__c, 
                    Firmenname_auf_der_Karte__c, Fahrzeugtyp__c 
                FROM Tankkarten__c 
                WHERE Driver_Name__c = 'Shell Card 2'];
        System.assertEquals('1 Alle Kraftstoffe, Tunnel-, Maut- und Fährgebühren', card2List.get(0).Produktbezugskategorie__c, 'Wrong name of product.');
        System.assertEquals('Multi Network Card -- National', card2List.get(0).Gewuenschter_Kartentyp__c, 'Wrong type of card.');
        System.assertEquals('Shell Card 2', card2List.get(0).Driver_Name__c, 'Wrong driver name.');
        System.assertEquals(true, card2List.get(0).Kilometerstand_Abfrage__c, 'Expected true.');
        System.assertEquals('TESTCOMPANY', card2List.get(0).Firmenname_auf_der_Karte__c, 'Wrong company name.');
        System.assertEquals('PKW', card2List.get(0).Fahrzeugtyp__c, 'Wrong type of vehicle.');

        List<Tankkarten__c> card3List = [
                SELECT Produktbezugskategorie__c, Gewuenschter_Kartentyp__c, Driver_Name__c, KFZ_Kennzeichen_oder_Fahrername__c, Kilometerstand_Abfrage__c, 
                    Firmenname_auf_der_Karte__c, Fahrzeugtyp__c 
                FROM Tankkarten__c 
                WHERE Driver_Name__c = 'Shell Card 3'];
        System.assertEquals('0 Diesel, Tunnel-, Maut- und Fährgebühren', card3List.get(0).Produktbezugskategorie__c, 'Wrong name of product.');
        System.assertEquals('Single Network Card -- International', card3List.get(0).Gewuenschter_Kartentyp__c, 'Wrong type of card.');
        System.assertEquals('Shell Card 3', card3List.get(0).Driver_Name__c, 'Wrong driver name.');
        System.assertEquals(true, card3List.get(0).Kilometerstand_Abfrage__c, 'Expected true.');
        System.assertEquals('TESTCOMPANY', card3List.get(0).Firmenname_auf_der_Karte__c, 'Wrong company name.');
        System.assertEquals('PKW', card3List.get(0).Fahrzeugtyp__c, 'Wrong type of vehicle.');

        List<Tankkarten__c> card4List = [
                SELECT Produktbezugskategorie__c, Gewuenschter_Kartentyp__c, Driver_Name__c, KFZ_Kennzeichen_oder_Fahrername__c, Kilometerstand_Abfrage__c, 
                    Firmenname_auf_der_Karte__c, Fahrzeugtyp__c 
                FROM Tankkarten__c 
                WHERE Driver_Name__c = 'Shell Card 4'];
        System.assertEquals('2 Kategorie 1 plus fahrzeugbezogene Waren und Dienstleistungen (Öle, Autowäsche)', card4List.get(0).Produktbezugskategorie__c, 'Wrong name of product.');
        System.assertEquals('Single Network Card -- National', card4List.get(0).Gewuenschter_Kartentyp__c, 'Wrong type of card.');
        System.assertEquals('Shell Card 4', card4List.get(0).Driver_Name__c, 'Wrong driver name.');
        System.assertEquals(false, card4List.get(0).Kilometerstand_Abfrage__c, 'Expected false.');
        System.assertEquals('TESTCOMPANY', card4List.get(0).Firmenname_auf_der_Karte__c, 'Wrong company name.');
        System.assertEquals('LKW', card4List.get(0).Fahrzeugtyp__c, 'Wrong type of vehicle.');
    }


    /*******************************************************************************
    *  Name            : additionalStepTest()
    *  Summary         : Testing additional step    
    *  CreatedDate     : 08/06/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void additionalStepTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Pending Credit Check';
        opportunity.E2E_Active_Step__c = 3;
        opportunity.E2E_Active_Substep__c = 'Additional services';
        opportunity.E2E_Form_of_Business__c = 'Solo-trader';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactDE(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        Credit_Factory_Report__c cfReport = E2ELongFormUtilsTest.createCFReport(opportunity.Id);
        insert cfReport;

        List<Tankkarten__c> cardsForInsert = new List<Tankkarten__c>();
        Tankkarten__c card1 = E2ELongFormUtilsTest.createMultiNetworkCardInternational(opportunity.Id);
        cardsForInsert.add(card1);

        Tankkarten__c card2 = E2ELongFormUtilsTest.createMultiNetworkCardNational(opportunity.Id);
        cardsForInsert.add(card2);

        Tankkarten__c card3 = E2ELongFormUtilsTest.createSingleNetworkCardInternational(opportunity.Id);
        cardsForInsert.add(card3);

        Tankkarten__c card4 = E2ELongFormUtilsTest.createSingleNetworkCardNational(opportunity.Id);
        cardsForInsert.add(card4);

        insert cardsForInsert;

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EForm');
        update opportunity;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormController();
        controller.init();
        controller.stepPagesMap.get('ADDITIONAL').fields.get('CO2 TAKE CARE').elementItemsMap.get('VALUE').Value__c = 'true';
        controller.stepPagesMap.get('ADDITIONAL').elements.get('ADDITIONAL SERVICE #2').get('VAT AGREEMENT CHECKBOX VALUE').Value__c = 'true';
        controller.stepPagesMap.get('ADDITIONAL').elements.get('ADDITIONAL SERVICE #2').get('VAT TC AGREEMENT CHECKBOX VALUE').Value__c = 'true';
        controller.goToPaymentOptions();
        controller.backToAdditionalFromDOB();
        controller.goToPaymentOptions();
        controller.stepPagesMap.get('ADDITIONAL. ENTER DATE OF BIRTH').fields.get('DATE OF BIRTH').elementItemsMap.get('DEFAULT VALUE').Value__c = '24.01.1990';
        controller.continueToPaymentOptionsFromDob();
        // testing back buttton
        controller.backToAdditionalParams();
        controller.stepPagesMap.get('ADDITIONAL').elements.get('ADDITIONAL SERVICE #2').get('VAT AGREEMENT CHECKBOX VALUE').Value__c = 'false';
        controller.stepPagesMap.get('ADDITIONAL').elements.get('ADDITIONAL SERVICE #2').get('VAT TC AGREEMENT CHECKBOX VALUE').Value__c = 'false';
        controller.goToPaymentOptions();


        List<Opportunity> oppList = [
                SELECT Eco_Fee__c, E2E_Active_Step__c, StageName, E2E_Active_Substep__c, VAT_Recovery__c, Agree_to_VAT_Recovery_TC__c
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals(true, oppList.get(0).Eco_Fee__c);
        System.assertEquals('Credit approved', oppList.get(0).StageName);
        System.assertEquals(4, oppList.get(0).E2E_Active_Step__c);
        System.assertEquals('DirectDebit', oppList.get(0).E2E_Active_Substep__c);
        System.assertEquals(false, oppList.get(0).VAT_Recovery__c);
        System.assertEquals(false, oppList.get(0).Agree_to_VAT_Recovery_TC__c);
    }


    /*******************************************************************************
    *  Name            : paymentOptionsDirectDebitTest()
    *  Summary         : Testing payment options step    
    *  CreatedDate     : 08/06/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void paymentOptionsDirectDebitTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.E2E_Active_Substep__c = 'DirectDebit';
        opportunity.E2E_Active_Step__c = 4;
        opportunity.Name_of_the_payer_Account_holder__c = '';
        opportunity.IBAN__c = '';
        opportunity.SWIFT_BIC__c = '';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactDE(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        Credit_Factory_Report__c cfReport = E2ELongFormUtilsTest.createCFReport(opportunity.Id);
        insert cfReport;

        List<Tankkarten__c> cardsForInsert = new List<Tankkarten__c>();
        Tankkarten__c card1 = E2ELongFormUtilsTest.createMultiNetworkCardInternational(opportunity.Id);
        cardsForInsert.add(card1);

        Tankkarten__c card2 = E2ELongFormUtilsTest.createMultiNetworkCardNational(opportunity.Id);
        cardsForInsert.add(card2);

        Tankkarten__c card3 = E2ELongFormUtilsTest.createSingleNetworkCardInternational(opportunity.Id);
        cardsForInsert.add(card3);

        Tankkarten__c card4 = E2ELongFormUtilsTest.createSingleNetworkCardNational(opportunity.Id);
        cardsForInsert.add(card4);

        insert cardsForInsert;

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EForm');
        update opportunity;

        Attachment attachment = E2ELongFormUtilsTest.createAttachment('SEPAMandate.pdf', opportunity.Id);
        insert attachment;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormController();
        controller.init();
        controller.activeStep = 4;
        controller.activeSubStep = 'DirectDebit';
        controller.stepPagesMap.get('PAYMENT OPTIONS').fields.get('ACCOUNT HOLDER').elementItemsMap.get('VALUE').Value__c = 'CONOR MCGREGOR';
        controller.stepPagesMap.get('PAYMENT OPTIONS').fields.get('IBAN').elementItemsMap.get('VALUE').Value__c = 'DE89370400440532013000';
        controller.stepPagesMap.get('PAYMENT OPTIONS').fields.get('PAPER INVOICE').elementItemsMap.get('VALUE').Value__c = 'true';
        controller.stepPagesMap.get('PAYMENT OPTIONS').fields.get('ACCEPT SEPA').elementItemsMap.get('VALUE').Value__c = 'true';
        controller.stepPagesMap.get('PAYMENT OPTIONS').fields.get('DECISION').elementItemsMap.get('VALUE').Value__c = 'true';
        controller.stepPagesMap.get('PAYMENT OPTIONS').fields.get('ACCEPT TERM CONDITIONS').elementItemsMap.get('VALUE').Value__c = 'true';
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new E2EIbanMock());
            controller.jsValidateIBAN();
        Test.stopTest();
        controller.doSavePaymentOptionsDataDirectDebit();
        controller.updateSepaDownloadURL();
        // testing back button
        controller.backToDirectDebitPaymentOption();

        List<Opportunity> oppList = [
                SELECT Name_of_the_payer_Account_holder__c, IBAN__c, SWIFT_BIC__c, E2E_Active_Substep__c, Send_SEPA_approval_link__c, SEPA_Request_Approved__c, Einwilligung_Lastschriftverfahren__c, 
                    SEPA_Request_Approval_Date__c, Papierrechnung__c, e_Invoicing_PDF__c, AGB_Datenschutzhinweise_Richtigkeit__c, 
                    (SELECT Contact.Authorised_signatory__c FROM OpportunityContactRoles)
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals('CONOR MCGREGOR', oppList.get(0).Name_of_the_payer_Account_holder__c);
        System.assertEquals('DE89370400440532013000', oppList.get(0).IBAN__c);
        System.assertEquals('GKCCBEBB', oppList.get(0).SWIFT_BIC__c);
        System.assertEquals('DirectDebitDeposit', oppList.get(0).E2E_Active_Substep__c);
        System.assertEquals(true, oppList.get(0).Send_SEPA_approval_link__c);
        System.assertEquals(true, oppList.get(0).SEPA_Request_Approved__c);
        System.assertEquals(true, oppList.get(0).Einwilligung_Lastschriftverfahren__c);
        System.assertEquals(true, oppList.get(0).Papierrechnung__c);
        System.assertEquals(false, oppList.get(0).e_Invoicing_PDF__c);
        System.assertEquals(true, oppList.get(0).AGB_Datenschutzhinweise_Richtigkeit__c);
        System.assertEquals(true, oppList.get(0).OpportunityContactRoles.get(0).Contact.Authorised_signatory__c);
    }


    /*******************************************************************************
    *  Name            : bankTransferNonDepositTest()
    *  Summary         : Testing payment options step    
    *  CreatedDate     : 08/06/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void bankTransferNonDepositTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.E2E_Active_Substep__c = 'BankTransfer';
        opportunity.Name_of_the_payer_Account_holder__c = '';
        opportunity.IBAN__c = '';
        opportunity.SWIFT_BIC__c = '';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactDE(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        Credit_Factory_Report__c cfReport = E2ELongFormUtilsTest.createCFReport(opportunity.Id);
        insert cfReport;

        List<Tankkarten__c> cardsForInsert = new List<Tankkarten__c>();
        Tankkarten__c card1 = E2ELongFormUtilsTest.createMultiNetworkCardInternational(opportunity.Id);
        cardsForInsert.add(card1);

        Tankkarten__c card2 = E2ELongFormUtilsTest.createMultiNetworkCardNational(opportunity.Id);
        cardsForInsert.add(card2);

        Tankkarten__c card3 = E2ELongFormUtilsTest.createSingleNetworkCardInternational(opportunity.Id);
        cardsForInsert.add(card3);

        Tankkarten__c card4 = E2ELongFormUtilsTest.createSingleNetworkCardNational(opportunity.Id);
        cardsForInsert.add(card4);

        insert cardsForInsert;

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EForm');
        update opportunity;

        Attachment attachment = E2ELongFormUtilsTest.createAttachment('SEPAMandate.pdf', opportunity.Id);
        insert attachment;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormController();
        controller.init();
        controller.activeStep = 4;
        controller.activeSubStep = 'BankTransfer';
        controller.stepPagesMap.get('PAYMENT OPTIONS').fields.get('PAPER INVOICE').elementItemsMap.get('VALUE').Value__c = 'true';
        controller.stepPagesMap.get('PAYMENT OPTIONS').fields.get('DECISION').elementItemsMap.get('VALUE').Value__c = 'true';
        controller.stepPagesMap.get('PAYMENT OPTIONS').fields.get('ACCEPT TERM CONDITIONS').elementItemsMap.get('VALUE').Value__c = 'true';
        controller.doSavePaymentOptionsDataBankTransfer();

        List<Opportunity> oppList = [
                SELECT StageName, Clubsmart__c, ForecastCategoryName, Closed_Won_by_CF__c, CF_Stage__c, CloseDate, bearbeitet_von__c, Kredit_Entscheidung__c, Credit_check_date__c, 
                        Billing_Period_by_Sales__c, Last_CF_Errors__c, E2E_Active_Substep__c, E2E_Active_Step__c, E2E_payment_status__c
                FROM Opportunity];

        System.assertEquals('Closed Won', oppList.get(0).StageName);
        System.assertEquals('Closed', oppList.get(0).ForecastCategoryName);
        System.assertEquals(true, oppList.get(0).Closed_Won_by_CF__c);
        System.assertEquals('Auto CW', oppList.get(0).CF_Stage__c);
        System.assertEquals(Date.today(), oppList.get(0).CloseDate);
        System.assertEquals(null, oppList.get(0).bearbeitet_von__c);
        System.assertEquals(null, oppList.get(0).Kredit_Entscheidung__c);
        System.assertEquals(null, oppList.get(0).Credit_check_date__c);
        System.assertEquals(true, oppList.get(0).Billing_Period_by_Sales__c);
        System.assertEquals(null, oppList.get(0).Last_CF_Errors__c);
        System.assertEquals('Congratulations', oppList.get(0).E2E_Active_Substep__c);
        System.assertEquals(5, oppList.get(0).E2E_Active_Step__c);
        System.assertEquals('NO DEPOSIT', oppList.get(0).E2E_payment_status__c, 'NO DEPOSIT IS EXPECTED.');
    }


    /*******************************************************************************
    *  Name            : bankTransferNonDepositTest()
    *  Summary         : Testing payment options step    
    *  CreatedDate     : 08/06/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void bankTransferDepositTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.E2E_Active_Substep__c = 'BankTransferDeposit';
        opportunity.Name_of_the_payer_Account_holder__c = '';
        opportunity.IBAN__c = '';
        opportunity.SWIFT_BIC__c = '';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactDE(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        Credit_Factory_Report__c cfReport = E2ELongFormUtilsTest.createCFReport(opportunity.Id);
        insert cfReport;

        List<Tankkarten__c> cardsForInsert = new List<Tankkarten__c>();
        Tankkarten__c card1 = E2ELongFormUtilsTest.createMultiNetworkCardInternational(opportunity.Id);
        cardsForInsert.add(card1);

        Tankkarten__c card2 = E2ELongFormUtilsTest.createMultiNetworkCardNational(opportunity.Id);
        cardsForInsert.add(card2);

        Tankkarten__c card3 = E2ELongFormUtilsTest.createSingleNetworkCardInternational(opportunity.Id);
        cardsForInsert.add(card3);

        Tankkarten__c card4 = E2ELongFormUtilsTest.createSingleNetworkCardNational(opportunity.Id);
        cardsForInsert.add(card4);

        insert cardsForInsert;

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EForm');
        update opportunity;

        Attachment attachment = E2ELongFormUtilsTest.createAttachment('DepositAgreement.pdf', opportunity.Id);
        insert attachment;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormController();
        controller.init();
        controller.stepPagesMap.get('PAYMENT OPTIONS').fields.get('PAPER INVOICE').elementItemsMap.get('VALUE').Value__c = 'true';
        controller.selectedPaymentMethod = 'Giropay';
        controller.changePaymentMethod();

        controller.stepPagesMap.get('PAYMENT OPTIONS').fields.get('DECISION').elementItemsMap.get('VALUE').Value__c = 'true';
        controller.stepPagesMap.get('PAYMENT OPTIONS').fields.get('ACCEPT TERM CONDITIONS').elementItemsMap.get('VALUE').Value__c = 'true';
        controller.stepPagesMap.get('PAYMENT OPTIONS').fields.get('DEPOSIT AGREEMENT').elementItemsMap.get('VALUE').Value__c = 'true';
        controller.savePaymentTransaction();

        List<Payment_Transaction__c> paymentTransactionList = [
                SELECT Brand__c, PaymentMethod__c, Status__c, Authorized__c, Amount__c, Currency__c, OpportunityId__r.Papierrechnung__c, 
                        OpportunityId__r.e_Invoicing_PDF__c, OpportunityId__r.AGB_Datenschutzhinweise_Richtigkeit__c
                FROM Payment_Transaction__c 
                WHERE OpportunityId__c = :opportunity.Id];

        System.assertEquals(true, paymentTransactionList.get(0).OpportunityId__r.Papierrechnung__c);
        System.assertEquals(true, paymentTransactionList.get(0).OpportunityId__r.AGB_Datenschutzhinweise_Richtigkeit__c);
        System.assertEquals(false, paymentTransactionList.get(0).OpportunityId__r.e_Invoicing_PDF__c);
        System.assertEquals('Giropay', paymentTransactionList.get(0).PaymentMethod__c);
        System.assertEquals(null, paymentTransactionList.get(0).Status__c);
        System.assertEquals(false, paymentTransactionList.get(0).Authorized__c);
        System.assertEquals(2100, paymentTransactionList.get(0).Amount__c);
        System.assertEquals('EUR', paymentTransactionList.get(0).Currency__c);
    }


    /*******************************************************************************
    *  Name            : paymentOptionsDirectDebitDepositTest()
    *  Summary         : Testing Direct Debit Deposit
    *  CreatedDate     : 08/06/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void paymentOptionsDirectDebitDepositTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactDE(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        Credit_Factory_Report__c cfReport = E2ELongFormUtilsTest.createCFReport(opportunity.Id);
        insert cfReport;

        Payment_Transaction__c paymentTransaction = E2ELongFormUtilsTest.createPaymentTransaction(opportunity.Id);
        insert paymentTransaction;

        List<Tankkarten__c> cardsForInsert = new List<Tankkarten__c>();
        Tankkarten__c card1 = E2ELongFormUtilsTest.createMultiNetworkCardInternational(opportunity.Id);
        cardsForInsert.add(card1);

        Tankkarten__c card2 = E2ELongFormUtilsTest.createMultiNetworkCardNational(opportunity.Id);
        cardsForInsert.add(card2);

        Tankkarten__c card3 = E2ELongFormUtilsTest.createSingleNetworkCardInternational(opportunity.Id);
        cardsForInsert.add(card3);

        Tankkarten__c card4 = E2ELongFormUtilsTest.createSingleNetworkCardNational(opportunity.Id);
        cardsForInsert.add(card4);

        insert cardsForInsert;

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EForm');
        update opportunity;

        Attachment attachment = E2ELongFormUtilsTest.createAttachment('DepositAgreement.pdf', opportunity.Id);
        insert attachment;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormController();
        controller.init();
        controller.paymentStatus = null;
        // Giropay payment method
        controller.selectedPaymentMethod = 'Giropay';
        controller.paymentOptionsService.prepareTransaction('Desktop');
        controller.changePaymentMethod();
        // Sofort payment method
        controller.selectedPaymentMethod = 'Sofort';
        controller.changePaymentMethod();
        controller.stepPagesMap.get('PAYMENT OPTIONS').fields.get('DEPOSIT AGREEMENT').elementItemsMap.get('VALUE').Value__c = 'true';
        controller.savePaymentTransaction();
        // Test buttons on order details block
        controller.editCardsFeesAndCosts();
        controller.editCardsEmbossing();
        controller.editCreditLimit();
        controller.editTotalConsumption();
        controller.editCompanyDetails();

        List<Payment_Transaction__c> paymentTransactionList = [
                SELECT Brand__c, PaymentMethod__c, Status__c, Authorized__c, Amount__c, Currency__c
                FROM Payment_Transaction__c 
                WHERE OpportunityId__c = :opportunity.Id];

        System.assertEquals('DirectEbankingDE', paymentTransactionList.get(0).Brand__c);
        System.assertEquals('DirectEbankingDE', paymentTransactionList.get(0).PaymentMethod__c);
        System.assertEquals(null, paymentTransactionList.get(0).Status__c);
        System.assertEquals(false, paymentTransactionList.get(0).Authorized__c);
        System.assertEquals(2100, paymentTransactionList.get(0).Amount__c);
        System.assertEquals('EUR', paymentTransactionList.get(0).Currency__c);
    }


    /*******************************************************************************
    *  Name            : congratulationPendingSalesDepositTest()
    *  Summary         : Go to congratulation step test pending sales - deposit    
    *  CreatedDate     : 08/06/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void congratulationPendingSalesDepositTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactDE(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        Credit_Factory_Report__c cfReport = E2ELongFormUtilsTest.createCFReport(opportunity.Id);
        insert cfReport;

        Payment_Transaction__c paymentTransaction = E2ELongFormUtilsTest.createPaymentTransaction(opportunity.Id);
        insert paymentTransaction;

        List<Tankkarten__c> cardsForInsert = new List<Tankkarten__c>();
        Tankkarten__c card1 = E2ELongFormUtilsTest.createMultiNetworkCardInternational(opportunity.Id);
        cardsForInsert.add(card1);

        Tankkarten__c card2 = E2ELongFormUtilsTest.createMultiNetworkCardNational(opportunity.Id);
        cardsForInsert.add(card2);

        Tankkarten__c card3 = E2ELongFormUtilsTest.createSingleNetworkCardInternational(opportunity.Id);
        cardsForInsert.add(card3);

        Tankkarten__c card4 = E2ELongFormUtilsTest.createSingleNetworkCardNational(opportunity.Id);
        cardsForInsert.add(card4);

        insert cardsForInsert;

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EForm');
        update opportunity;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormController();
        controller.paymentStatus = 'A';
        controller.init();
        controller.receiveFreeBonus();

        List<Opportunity> oppList = [
                SELECT StageName, Clubsmart__c, ForecastCategoryName, Closed_Won_by_CF__c, CF_Stage__c, CloseDate, bearbeitet_von__c, Kredit_Entscheidung__c, Credit_check_date__c, 
                        Billing_Period_by_Sales__c, Last_CF_Errors__c, E2E_Active_Substep__c, E2E_Active_Step__c
                FROM Opportunity];

        System.assertEquals('Pending Sales – Deposit', oppList.get(0).StageName);
        System.assertEquals('Closed', oppList.get(0).ForecastCategoryName);
        System.assertEquals(true, oppList.get(0).Closed_Won_by_CF__c);
        System.assertEquals('Auto CW', oppList.get(0).CF_Stage__c);
        System.assertEquals(Date.today(), oppList.get(0).CloseDate);
        System.assertEquals(null, oppList.get(0).bearbeitet_von__c);
        System.assertEquals('Genehmigt, Sicherheit geliefert', oppList.get(0).Kredit_Entscheidung__c);
        System.assertEquals(null, oppList.get(0).Credit_check_date__c);
        System.assertEquals(true, oppList.get(0).Billing_Period_by_Sales__c);
        System.assertEquals(null, oppList.get(0).Last_CF_Errors__c);
        System.assertEquals('Congratulations', oppList.get(0).E2E_Active_Substep__c);
        System.assertEquals(5, oppList.get(0).E2E_Active_Step__c);
        System.assertEquals(4, oppList.get(0).Clubsmart__c);
    }


    /*******************************************************************************
    *  Name            : returnToCongratulationTest()
    *  Summary         : Testing return to congratulation test (Step 5)  
    *  CreatedDate     : 30/06/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void returnToCongratulationTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.E2E_Active_Step__c = 5;
        opportunity.E2E_payment_status__c = 'Accept';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactDE(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        Credit_Factory_Report__c cfReport = E2ELongFormUtilsTest.createCFReport(opportunity.Id);
        insert cfReport;

        Payment_Transaction__c paymentTransaction = E2ELongFormUtilsTest.createPaymentTransaction(opportunity.Id);
        insert paymentTransaction;

        List<Tankkarten__c> cardsForInsert = new List<Tankkarten__c>();
        Tankkarten__c card1 = E2ELongFormUtilsTest.createMultiNetworkCardInternational(opportunity.Id);
        cardsForInsert.add(card1);

        Tankkarten__c card2 = E2ELongFormUtilsTest.createMultiNetworkCardNational(opportunity.Id);
        cardsForInsert.add(card2);

        Tankkarten__c card3 = E2ELongFormUtilsTest.createSingleNetworkCardInternational(opportunity.Id);
        cardsForInsert.add(card3);

        Tankkarten__c card4 = E2ELongFormUtilsTest.createSingleNetworkCardNational(opportunity.Id);
        cardsForInsert.add(card4);

        insert cardsForInsert;

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EForm');
        update opportunity;

        ApexPages.currentPage().getparameters().put('country', 'Germany');
        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormController();
        controller.init();
    }
}