@isTest
private class E2EMobilePLTest {
    public static LongFormMobilePLController controller;

    /*******************************************************************************
    *  Name            : createLongFormData()
    *  Summary         : Creating all LongForm data    
    *  CreatedDate     : 04/12/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @testSetup
    static void createLongFormData() {
        E2ELongFormUtilsTest.createInternationalPartnersPrice('Poland', 'Inbound');
        E2ELongFormUtilsTest.createNationalNotPartnersPrice('Poland', 'Inbound');
        E2ELongFormUtilsTest.createInternationalNotPartnersPrice('Poland', 'Inbound');
        E2ELongFormUtilsTest.createNationalPartnersPrice('Poland', 'Inbound');
        E2ELongFormUtilsTest.createInternationalPartnersDiffPrice('Poland', 'Inbound');
        E2ELongFormUtilsTest.createNationalNotPartnersDiffPrice('Poland', 'Inbound');
        E2ELongFormUtilsTest.createInternationalNotPartnersDiffPrice('Poland', 'Inbound');
        E2ELongFormUtilsTest.createNationalPartnersDiffPrice('Poland', 'Inbound');
        E2ELongFormUtilsTest.createLongForm('Poland');
        E2ELongFormUtilsTest.createLongFormMenu();
        E2ELongFormUtilsTest.createMenuItemForStep1('Mobile');
        E2ELongFormUtilsTest.createMenuItemForStep2('Mobile');
        E2ELongFormUtilsTest.createMenuItemForStep3('Mobile');
        E2ELongFormUtilsTest.createMenuItemForStep4('Mobile');
        E2ELongFormUtilsTest.createHeader('Mobile');
        E2ELongFormUtilsTest.createContactDeatilsData('Mobile');
        E2ELongFormUtilsTest.createCustomSettings('Poland', 'E2EFormPL', 'Crif', '0050O000007Drnn');
        E2ELongFormUtilsTest.createOrderDetailsBlock('Mobile');
        E2ELongFormUtilsTest.createFooter('Mobile');
        E2ELongFormUtilsTest.createCreditScoreSearchCompany('Mobile');
        E2ELongFormUtilsTest.createCreditScoreTotalConsumption('Mobile');
        E2ELongFormUtilsTest.createAdditionalCreditScoring('Mobile');
        E2ELongFormUtilsTest.createCreditScoringResult('Mobile');
        E2ELongFormUtilsTest.createCardConfiguration('Mobile');
        E2ELongFormUtilsTest.createCardConfigurationSpecialOffers('Mobile', 'SHELL STANDARD 2019 OFFER CONTENT PL DESKTOP', 'SHELL STANDARD 2019 OFFER CONTENT PL DESKTOP', 'Poland', 'Inbound', 'Shell Standard 2019', 'Shell Standard 2019');
        E2ELongFormUtilsTest.createCardConfigurationInputVatId('Mobile');
        E2ELongFormUtilsTest.createAdditionalPage('Mobile');
        E2ELongFormUtilsTest.createAdditionalDateOfBirth('Mobile');
        E2ELongFormUtilsTest.createDocuments('Mobile');
        E2ELongFormUtilsTest.createPaymentOptions('Mobile');
        E2ELongFormUtilsTest.createSystemErrorPage('Mobile');
        E2ELongFormUtilsTest.createProcessErrorPage('Mobile');

        E2ELongFormUtilsTest.createSaveAndContinueLater('Mobile');
        // E2ELongFormUtilsTest.createSendSepaToTheEmail('Mobile');
        // E2ELongFormUtilsTest.createSendDepositAgreementToTheEmail('Mobile');
        // E2ELongFormUtilsTest.createSendHowToPay('Mobile');
        // E2ELongFormUtilsTest.createSendTC('Mobile');
        E2ELongFormUtilsTest.createCongratulationsPage('Mobile');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCrifAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCrifOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.doCreateCreditSystemSalesProfile();
        insert creditSystemSalesProfile;
    }


    /*******************************************************************************
    *  Name            : insertDupConSameDataClosedLostPLMob()
    *  Summary         : Verify that two Contacts were merged when First Name + Last Name + Email + Phone are the same and Contact #1 has E2E Opportunity #1 in stage Closed Lost    
    *  ExpectedResult  : Two contacts were merged. E2E Account #2, E2E Opportuinty #2 were created. Direct Connections were changed to E2E records
    *  CreatedDate     : 04/12/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void insertDupConSameDataClosedLostPLMob() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Poland';
        Account.ShippingCountry = 'Poland';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Closed Lost';
        opportunity.Product__c = '';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        contact.MailingCountry = 'Poland';
        contact.Phone = '+48123456789';
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        controller = new LongFormMobilePLController();
        controller.activeStep = 0;
        controller.init();
        controller.getStarted();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHN';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SMITH';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+48123456789';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'test@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '1';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('PHONE CONTACT AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('RECEIVE COMM INFO BY EMAIL AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCompanyDetails();

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
        System.assertEquals('+48123456789', contactList.get(0).Phone, 'Expected Phone from form.');
        System.assertEquals('test@fleetcor.com', contactList.get(0).Email, 'Expected Email from form.');
    }


    /*******************************************************************************
    *  Name            : insertDupConSameDataWithE2EOppPLMob()
    *  Summary         : Verify that two Contacts were merged when First Name + Last Name + Email + Phone are the same 
                         and Contact #1 has E2E Opportunity #1 NOT in stage Closed Lost / Closed WON / Pending Sales - Deposit
    *  ExpectedResult  : Two contacts were merged. Form of the business is updated in Opportunity #1 User is redirected to last E2E step of the Opportunity #1
    *  CreatedDate     : 25/09/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void insertDupConSameDataWithE2EOppPLMob() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Poland';
        Account.ShippingCountry = 'Poland';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Prospecting';
        opportunity.E2E_Active_Step__c = 1;
        opportunity.E2E_Active_Substep__c = 'Search company';
        opportunity.Product__c = '';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        contact.MailingCountry = 'Poland';
        contact.Phone = '+48123456789';
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        controller = new LongFormMobilePLController();
        controller.activeStep = 0;
        controller.init();
        controller.getStarted();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHN';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SMITH';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+48123456789';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'test@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '1';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('PHONE CONTACT AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('RECEIVE COMM INFO BY EMAIL AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCompanyDetails();

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
        System.assertEquals('+48123456789', contactList.get(0).Phone, 'Expected Phone from form.');
        System.assertEquals('test@fleetcor.com', contactList.get(0).Email, 'Expected Email from form.');
    }


    /*******************************************************************************
    *  Name            : updateDupConSameDataClosedLostPLMob()
    *  Summary         : Verify that two Contacts were merged when First Name + Last Name + Email + Phone are the same and Contact #1 has E2E Opportunity #1 in stage Closed Lost
    *  ExpectedResult  : E2E Opportunity #2 Stage = Closed Lost. Reason = Duplicate. E2E Account #2, E2E Contact #2 were NOT deleted.
                         Contacts were merged. New E2E Account #3, New E2E Opportunity #3 were created. Direct Connections were changed to E2E records
    *  CreatedDate     : 04/12/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void updateDupConSameDataClosedLostPLMob() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Poland';
        Account.ShippingCountry = 'Poland';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Closed Lost';
        opportunity.Product__c = '';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        contact.MailingCountry = 'Poland';
        contact.Phone = '+48123456789';
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        controller = new LongFormMobilePLController();
        controller.activeStep = 0;
        controller.init();
        controller.getStarted();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JohnAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SmithAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+48111111111';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'testAA@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '1';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('PHONE CONTACT AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('RECEIVE COMM INFO BY EMAIL AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCompanyDetails();
        // back to update data
        controller.editContactDetails();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHN';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SMITH';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+48123456789';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'test@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Solo-trader';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '1';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('PHONE CONTACT AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('RECEIVE COMM INFO BY EMAIL AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCompanyDetails();

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
        System.assertEquals('+48123456789', contactList.get(0).Phone, 'Expected Phone from form.');
        System.assertEquals('test@fleetcor.com', contactList.get(0).Email, 'Expected Email from form.');
    }


    /*******************************************************************************
    *  Name            : updateDupConSameDataProspectingPLMob()
    *  Summary         : Verify that two Contacts were merged when First Name + Last Name + Email + Phone are the same and 
                         Contact #1 has E2E Opportunity #1 NOT in stage Closed Lost / Closed WON / Pending Sales - Deposit
    *  ExpectedResult  : E2E Opportunity #2 Stage = Closed Lost. Reason = Duplicate. E2E Account #2, E2E Contact #2 were NOT deleted. Contacts were merged. 
                         User is redirected to the last E2E step of the Opportunity #1
    *  CreatedDate     : 04/12/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void updateDupConSameDataProspectingPLMob() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Poland';
        Account.ShippingCountry = 'Poland';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Prospecting';
        opportunity.Product__c = '';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        contact.MailingCountry = 'Poland';
        contact.Phone = '+48123456789';
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        controller = new LongFormMobilePLController();
        controller.activeStep = 0;
        controller.init();
        controller.getStarted();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JohnAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SmithAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+48111111111';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'testAA@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '1';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('PHONE CONTACT AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('RECEIVE COMM INFO BY EMAIL AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCompanyDetails();
        // back to update data
        controller.editContactDetails();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHN';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SMITH';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+48123456789';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'test@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '1';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('PHONE CONTACT AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('RECEIVE COMM INFO BY EMAIL AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCompanyDetails();

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
        System.assertEquals('+48123456789', contactList.get(0).Phone, 'Expected Phone from form.');
        System.assertEquals('test@fleetcor.com', contactList.get(0).Email, 'Expected Email from form.');
    }


    /*******************************************************************************
    *  Name            : privateEntityPLMobTest()
    *  Summary         : Private entity test
    *  CreatedDate     : 06/12/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void privateEntityPLMobTest() {
        controller = new LongFormMobilePLController();
        controller.activeStep = 0;
        controller.init();
        controller.getStarted();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHN';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SMITH';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+48123456789';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'test@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Private';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '1';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('PHONE CONTACT AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('RECEIVE COMM INFO BY EMAIL AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCompanyDetails();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.goToCompanyDetails();
        // back to update data
        controller.editContactDetails();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Private';
        controller.goToCompanyDetails();

        List<Contact> contactList = [
                SELECT FirstName, LastName, Phone, Email, 
                    (SELECT Opportunity.StageName FROM OpportunityContactRoles)
                FROM Contact];
        System.assertEquals(1, contactList.get(0).OpportunityContactRoles.size(), 'One Opportunity is expected.');
        System.assertEquals('Closed Lost', contactList.get(0).OpportunityContactRoles.get(0).Opportunity.StageName, 'StageName should be Closed Lost');
        System.assertEquals(1, contactList.size(), 'One Contact is expected.');
        System.assertEquals('JOHN', contactList.get(0).FirstName, 'Expected FirstName from form.');
        System.assertEquals('SMITH', contactList.get(0).LastName, 'Expected LastName from form.');
        System.assertEquals('+48123456789', contactList.get(0).Phone, 'Expected Phone from form.');
        System.assertEquals('test@fleetcor.com', contactList.get(0).Email, 'Expected Email from form.');
    }


    /*******************************************************************************
    *  Name            : ContactDetailsPLMobTest()
    *  Summary         : Testing contact details step with valid data    
    *  CreatedDate     : 04/12/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void ContactDetailsPLMobTest() {
        controller = new LongFormMobilePLController();
        // catch error in init method
        controller.init();
        controller.activeStep = 0;
        controller.init();
        controller.getStarted();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Herr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHN';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'WICK';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+48123456789';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'john@wick.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '1';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('PHONE CONTACT AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('RECEIVE COMM INFO BY EMAIL AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';

        controller.showAgreeToPhoneContact();
        controller.showAgreeToInfoByEmail();
        controller.showAgreeNews();

        controller.goToCompanyDetails();

        List<Contact> contactList = [
                SELECT Salutation, FirstName, LastName, Phone, Email, Authorised_signatory__c, LeadSource, MailingCountry, RecordType.Name, E2E__c, 
                    (SELECT Account.Name, Account.E2E__c, Account.RecordType.Name, Account.Type, Account.AccountSource, Account.BillingCountry, Account.ShippingCountry 
                    FROM AccountContactRelations), 
                    (SELECT Opportunity.Name, Opportunity.E2E__c, Opportunity.StageName, Opportunity.Product__c, Opportunity.CloseDate, Opportunity.Language_preference__c, 
                        Opportunity.Primary_Contact_Phone__c, Opportunity.Agree_to_process_pers_data_for_marketing__c, Opportunity.Date_for_Agree_to_Privacy_Policy__c, 
                        Opportunity.LeadSource, Opportunity.Sec_Channel__c, Opportunity.Channel__c, Opportunity.CurrencyIsoCode, Opportunity.Type, Opportunity.Eco_Fee__c, 
                        Opportunity.Visitor_ID__c, Opportunity.AGB_Datenschutzhinweise_Richtigkeit__c, Opportunity.E2E_Form_of_Business__c, Opportunity.E2E_Active_Step__c, 
                        Opportunity.E2E_Active_Substep__c, Opportunity.Agree_to_telephone_contact__c, Opportunity.Agree_to_receive_comm_info_by_email__c
                    FROM OpportunityContactRoles)
                FROM Contact];

        // contact
        System.assertEquals(1, contactList.size(), 'One Contact is expected.');
        System.assertEquals('Herr', contactList.get(0).Salutation, 'Should be value from form.');
        System.assertEquals('JOHN', contactList.get(0).FirstName, 'Should be value from form.');
        System.assertEquals('WICK', contactList.get(0).LastName, 'Should be value from form.');
        System.assertEquals('+48123456789', contactList.get(0).Phone, 'Should be value from form.');
        System.assertEquals('john@wick.com', contactList.get(0).Email, 'Should be value from form.');
        System.assertEquals(false, contactList.get(0).Authorised_signatory__c, 'Should be Automatic filling by default.');
        System.assertEquals(true, contactList.get(0).E2E__c, 'Should be Automatic filling by default.');
        System.assertEquals('Poland', contactList.get(0).MailingCountry, 'Should be Automatic filling by default.');
        System.assertEquals('Contact layout', contactList.get(0).RecordType.Name, 'Should be Automatic filling by default.');
        // account
        System.assertEquals(1, contactList.get(0).AccountContactRelations.size(), 'One Account is expected.');
        System.assertEquals('LONGFORM: JOHN WICK', contactList.get(0).AccountContactRelations.get(0).Account.Name, 'Should be value from form.');
        System.assertEquals('Endkunde', contactList.get(0).AccountContactRelations.get(0).Account.RecordType.Name, 'Should be Automatic filling by default.');
        System.assertEquals('Customer', contactList.get(0).AccountContactRelations.get(0).Account.Type, 'Should be Automatic filling by default.');
        System.assertEquals(true, contactList.get(0).AccountContactRelations.get(0).Account.E2E__c, 'Should be Automatic filling by default.');
        System.assertEquals('Poland', contactList.get(0).AccountContactRelations.get(0).Account.BillingCountry, 'Should be Automatic filling by default.');
        System.assertEquals('Poland', contactList.get(0).AccountContactRelations.get(0).Account.ShippingCountry, 'Should be Automatic filling by default.');
        // opportunity
        System.assertEquals(1, contactList.get(0).OpportunityContactRoles.size(), 'One Opportunity is expected.');
        System.assertEquals('LONGFORM: JOHN WICK', contactList.get(0).OpportunityContactRoles.get(0).Opportunity.Name, 'Should be value from form.');
        System.assertEquals('Prospecting', contactList.get(0).OpportunityContactRoles.get(0).Opportunity.StageName, 'Should be Automatic filling by default.');
        System.assertEquals(null, contactList.get(0).OpportunityContactRoles.get(0).Opportunity.Product__c, 'Should be Automatic filling by default.');
        System.assertEquals('Polish', contactList.get(0).OpportunityContactRoles.get(0).Opportunity.Language_preference__c, 'Should be Automatic filling by default.');
        System.assertEquals('+48123456789', contactList.get(0).OpportunityContactRoles.get(0).Opportunity.Primary_Contact_Phone__c, 'Should be value from form.');
        System.assertEquals(true, contactList.get(0).OpportunityContactRoles.get(0).Opportunity.Agree_to_process_pers_data_for_marketing__c, 'Should be Automatic filling by default.');
        System.assertEquals(true, contactList.get(0).OpportunityContactRoles.get(0).Opportunity.Agree_to_telephone_contact__c, 'Should be Automatic filling by default.');
        System.assertEquals(true, contactList.get(0).OpportunityContactRoles.get(0).Opportunity.Agree_to_receive_comm_info_by_email__c, 'Should be Automatic filling by default.');
        System.assertEquals(true, contactList.get(0).OpportunityContactRoles.get(0).Opportunity.E2E__c, 'Should be Automatic filling by default.');
        System.assertEquals('Inbound', contactList.get(0).OpportunityContactRoles.get(0).Opportunity.Sec_Channel__c, 'Should be Automatic filling by default.');
        System.assertEquals('Internet', contactList.get(0).OpportunityContactRoles.get(0).Opportunity.Channel__c, 'Should be Automatic filling by default.');
        System.assertEquals('PLN', contactList.get(0).OpportunityContactRoles.get(0).Opportunity.CurrencyIsoCode, 'Should be Automatic filling by default.');
        System.assertEquals('New Business', contactList.get(0).OpportunityContactRoles.get(0).Opportunity.Type, 'Should be Automatic filling by default.');
        System.assertEquals(false, contactList.get(0).OpportunityContactRoles.get(0).Opportunity.Eco_Fee__c, 'Should be Automatic filling by default.');
        System.assertEquals(false, contactList.get(0).OpportunityContactRoles.get(0).Opportunity.AGB_Datenschutzhinweise_Richtigkeit__c, 'Should be Automatic filling by default.');
        System.assertEquals('Company', contactList.get(0).OpportunityContactRoles.get(0).Opportunity.E2E_Form_of_Business__c, 'Should be Automatic filling by default.');
        System.assertEquals(1, contactList.get(0).OpportunityContactRoles.get(0).Opportunity.E2E_Active_Step__c, 'Should be Automatic filling by default.');
        System.assertEquals('Search company', contactList.get(0).OpportunityContactRoles.get(0).Opportunity.E2E_Active_Substep__c, 'Should be Automatic filling by default.');
    }


    /*******************************************************************************
    *  Name            : searchCompanyPLMobTest()
    *  Summary         : Testing search company mock    
    *  CreatedDate     : 04/12/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void searchCompanyPLMobTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Poland';
        Account.ShippingCountry = 'Poland';
        Account.Steuernummer__c = '';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Prospecting';
        opportunity.E2E_Active_Step__c = 1;
        opportunity.E2E_Active_Substep__c = 'Search company';
        opportunity.Product__c = '';
        opportunity.E2E_Status__c = 'Abandoned (hard)';
        opportunity.E2E_Sub_Status__c = 'Marketing automation';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactDE(account.Id);
        contact.MailingCountry = 'Poland';
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EFormPL');
        update opportunity;

        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormMobilePLController();
        controller.init();

        // catch errors
        controller.stepPagesMap.get('CREDIT SCORE. SEARCH COMPANY').fields.get('COMPANY NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = '1111';
        controller.stepPagesMap.get('CREDIT SCORE. SEARCH COMPANY').fields.get('TAX ID').elementItemsMap.get('DEFAULT VALUE').Value__c = 'test';
        controller.doSaveCompanyDetailsData();

        controller.stepPagesMap.get('CREDIT SCORE. SEARCH COMPANY').fields.get('COMPANY NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'TEST';
        controller.stepPagesMap.get('CREDIT SCORE. SEARCH COMPANY').fields.get('TAX ID').elementItemsMap.get('DEFAULT VALUE').Value__c = '1234567890';
        controller.doSaveCompanyDetailsData();

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new E2ELongFromPLCreditFactoryMock());
            controller.doSearchCompany();
        Test.stopTest();

        List<Opportunity> oppList = [
                SELECT Name, CF_Stage__c, E2E_Active_Step__c, E2E_Active_Substep__c, Account.Name, Account.Steuernummer__c
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        // Opportunity
        System.assertEquals('TEST', oppList.get(0).Name, 'Expected company name from form.');
        System.assertEquals(1, oppList.get(0).E2E_Active_Step__c, 'Expected first step.');
        System.assertEquals('Launched', oppList.get(0).CF_Stage__c, 'Wrong CF Stage.');
        System.assertEquals('Search company', oppList.get(0).E2E_Active_Substep__c, 'Expected Search company substep.');
        // Account
        System.assertEquals('TEST', oppList.get(0).Account.Name, 'Expected company name from form.');
        System.assertEquals('1234567890', oppList.get(0).Account.Steuernummer__c, 'Expected city from form.');
    }


    /*******************************************************************************
    *  Name            : creditScoringAllowancePLMobTest()
    *  Summary         : Testing credit scoring allowance step    
    *  CreatedDate     : 04/12/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void creditScoringAllowancePLMobTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Poland';
        Account.ShippingCountry = 'Poland';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Prospecting';
        opportunity.E2E_Active_Step__c = 1;
        opportunity.E2E_Active_Substep__c = 'Additional Credit Scoring Allowance';
        opportunity.Zahlungsart__c = '';
        opportunity.Rechnungsperiode__c = '';
        opportunity.Product__c = '';
        opportunity.E2E_Status__c = 'Abandoned (hard)';
        opportunity.E2E_Sub_Status__c = 'Marketing automation';
        insert opportunity;

        Attachment creditScoringAllowanceForOppty = E2ELongFormUtilsTest.createAttachment('Zgoda na weryfikację (DocuSign).pdf', opportunity.Id);
        insert creditScoringAllowanceForOppty;

        Contact contact = E2ELongFormUtilsTest.createContactDE(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        dsfs__DocuSign_Status__c docusignStatus = E2ELongFormUtilsTest.createDocusignStatus(opportunity.Id);
        insert docusignStatus;

        Attachment creditScoringAllowanceForStatus = E2ELongFormUtilsTest.createAttachment('Zgoda na weryfikację (DocuSign).pdf', docusignStatus.Id);
        insert creditScoringAllowanceForStatus;

        dsfs__DocuSign_Recipient_Status__c docusignRecipientStatus = E2ELongFormUtilsTest.createRecipientStatus(docusignStatus.Id);
        insert docusignRecipientStatus;

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EFormPL');
        update opportunity;

        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormMobilePLController();
        controller.init();
        // credit scoring allowance
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new DocusignPLMock());
            controller.goToSignDocuments();
        Test.stopTest();
    }


    /*******************************************************************************
    *  Name            : getReportPLMobTest()
    *  Summary         : Test get Report, Tax Id, fuel consumption,   
    *  CreatedDate     : 04/12/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void getReportPLMobTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Poland';
        Account.ShippingCountry = 'Poland';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Prospecting';
        opportunity.E2E_Active_Step__c = 1;
        opportunity.E2E_Active_Substep__c = 'Set total consumption';
        opportunity.Product__c = '';
        opportunity.Zahlungsart__c = '';
        opportunity.Rechnungsperiode__c = '';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactDE(account.Id);
        contact.MailingCountry = 'Poland';
        contact.Salutation = 'Mr';
        contact.FirstName = 'Andrew';
        contact.LastName = 'Richard Hackett';
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EFormPL');
        update opportunity;

        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormMobilePLController();
        controller.init();
        controller.selectedCompany = new CreditCompany();
        controller.selectedCompany.identificationnumber = '8338085693';
        controller.deleteReportsForPreviousCompany();
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new E2ELongFromPLCreditFactoryMock());
            controller.goToSetTotalConsumption();
        Test.stopTest();

        // catch errors
        controller.stepPagesMap.get('CREDIT SCORE. TOTAL CONSUMPTION').fields.get('TOTAL CONSUMPTION').elementItemsMap.get('DEFAULT VALUE').Value__c = '2000';
        controller.doSaveAndContinueLater();
        controller.doCalculateCreditScoring();
        // norm flow
        controller.stepPagesMap.get('CREDIT SCORE. TOTAL CONSUMPTION').fields.get('TOTAL CONSUMPTION').elementItemsMap.get('DEFAULT VALUE').Value__c = '1000';
        controller.doSaveAndContinueLater();
        controller.doCalculateCreditScoring();
        // calculate Lastschrift weekly credit score data
        controller.stepPagesMap.get('CREDIT SCORE. SCORING RESULT').fields.get('PAYMENT METHOD').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Banküberweisung';
        controller.defaultBillingPeriod = 7;
        controller.changeBillingPeriod();
        controller.stepPagesMap.get('CREDIT SCORE. SCORING RESULT').fields.get('BILLING PERIOD').elementItemsMap.get('WEEKLY BUTTON NAME + 7').Value__c = '7';
        controller.returnFinalCreditScoreData();
        controller.doRecalculateDeposit();
        // calculacte Lastschrift BI-weekly credit score data
        controller.stepPagesMap.get('CREDIT SCORE. SCORING RESULT').fields.get('PAYMENT METHOD').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Lastschrift';
        controller.defaultBillingPeriod = 15;
        controller.changeBillingPeriod();
        controller.stepPagesMap.get('CREDIT SCORE. SCORING RESULT').fields.get('BILLING PERIOD').elementItemsMap.get('BI-WEEKLY BUTTON NAME + 14').Value__c = '15';
        controller.returnFinalCreditScoreData();
        controller.doRecalculateDeposit();
        controller.goToCardsConfig();

        controller.editCompanyDetails();

        List<Opportunity> oppList = [
                SELECT Name, StageName, CF_Stage__c, Credit_System_Rating__c, Umsatz__c, Credit_System_Number__c, E2E_Active_Step__c, E2E_Last_Activity__c, Visitor_ID__c, E2E_Encoded_URL__c, 
                    Account.Name, Account.BillingStreet, Account.BillingPostalCode, Account.BillingCity, Account.ShippingCountry, Account.ShippingStreet, Account.ShippingPostalCode, 
                    Account.ShippingCity, Account.Umsatzsteuer_ID__c, Account.Steuernummer__c, E2E_Active_Substep__c, 
                    Gasoline_consumption_l_month__c, Diesel_consumption_l_month__c, Total_consumption_l_month__c, 
                    (SELECT Contact.MailingStreet, Contact.MailingPostalCode, Contact.MailingCity FROM OpportunityContactRoles)
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        // Opportunity
        System.assertEquals('MUSZELKI WALDEMAR SZYBKI', oppList.get(0).Name, 'Should be Automatic filling by default from CF.');
        System.assertEquals('Credit approved', oppList.get(0).StageName, 'Should be Automatic filling by default.');
        System.assertEquals(0, oppList.get(0).Gasoline_consumption_l_month__c, 'Always should be 0.');
        System.assertEquals(1000, oppList.get(0).Diesel_consumption_l_month__c, 'Shoul be the same as total consumption.');
        System.assertEquals(1000, oppList.get(0).Total_consumption_l_month__c, 'Wrong total consumption.');
        System.assertEquals('Card configuration', oppList.get(0).E2E_Active_Substep__c, 'Wrong active substep.');
        System.assertEquals(2, oppList.get(0).E2E_Active_Step__c, 'Should be Automatic filling by default.');
        // Account 
        System.assertEquals('MUSZELKI WALDEMAR SZYBKI', oppList.get(0).Account.Name, 'Should be Automatic filling by default from CF.');
        System.assertEquals('ZACHODNIA 30', oppList.get(0).Account.BillingStreet, 'Should be Automatic filling by default from CF.');
        System.assertEquals('82-333', oppList.get(0).Account.BillingPostalCode, 'Should be Automatic filling by default from CF.');
        System.assertEquals('WODNOWO', oppList.get(0).Account.BillingCity, 'Should be Automatic filling by default from CF.');
        System.assertEquals('Poland', oppList.get(0).Account.ShippingCountry, 'Should be Automatic filling by default from CF.');
        System.assertEquals('ZACHODNIA 30', oppList.get(0).Account.ShippingStreet, 'Should be Automatic filling by default from CF.');
        System.assertEquals('82-333', oppList.get(0).Account.ShippingPostalCode, 'Should be Automatic filling by default from CF.');
        System.assertEquals('WODNOWO', oppList.get(0).Account.ShippingCity, 'Should be Automatic filling by default from CF.');
        System.assertEquals(null, oppList.get(0).Account.Umsatzsteuer_ID__c, 'Should be Automatic filling by default from CF.');
        System.assertEquals('2451803340', oppList.get(0).Account.Steuernummer__c, 'Should be value from form.');
        // Contact
        System.assertEquals('ZACHODNIA 30', oppList.get(0).OpportunityContactRoles.get(0).Contact.MailingStreet, 'Should be Automatic filling by default from CF.');
        System.assertEquals('82-333', oppList.get(0).OpportunityContactRoles.get(0).Contact.MailingPostalCode, 'Should be Automatic filling by default from CF.');
        System.assertEquals('WODNOWO', oppList.get(0).OpportunityContactRoles.get(0).Contact.MailingCity, 'Should be Automatic filling by default from CF.');
    }


    /*******************************************************************************
    *  Name            : cardConfigurationPLMobTest()
    *  Summary         : Test card configuration step    
    *  CreatedDate     : 04/12/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void cardConfigurationPLMobTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Poland';
        Account.ShippingCountry = 'Poland';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.E2E_Active_Step__c = 2;
        opportunity.E2E_Active_Substep__c = 'Card configuration';
        opportunity.Product__c = '';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactDE(account.Id);
        contact.MailingCountry = 'Poland';
        contact.Salutation = 'Mr';
        contact.FirstName = 'Andrew';
        contact.LastName = 'Richard Hackett';
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EFormPL');
        update opportunity;

        Credit_Factory_Report__c cfReport = E2ELongFormUtilsTest.createCFReport(opportunity.Id);
        insert cfReport;

        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormMobilePLController();
        controller.init();
        controller.doSaveAndContinueLater();
        controller.numberOfCards = 4;
        controller.changeNumberOfCards();

        ApexPages.currentPage().getparameters().put('cardindex', '1');
        controller.finalCardsMap.get(1).categoryCard = 'All vehicle related product';
        controller.finalCardsMap.get(1).activeCardConfigStepMobile = 'Options';
        controller.finalCardsMap.get(1).pumpOutsideCountry = false;
        controller.finalCardsMap.get(1).pumpAtPartners = false;
        controller.finalCardsMap.get(1).needOdometerOptions = true;
        controller.finalCardsMap.get(1).selectedTypeOfCar = 'PKW';
        controller.goToEmbossing();
        controller.finalCardsMap.get(1).selectedDriverNameOrCarNumber = 'driver-name';
        controller.finalCardsMap.get(1).driverNameOrCarNumberInputValue = 'JOHN WICK';
        controller.finalCardsMap.get(1).companyNameInputValue = 'JOHN WICK CORPORATION';
        controller.saveCard();

        ApexPages.currentPage().getparameters().put('cardindex', '2');
        controller.finalCardsMap.get(2).categoryCard = 'All fuel types';
        controller.finalCardsMap.get(2).activeCardConfigStepMobile = 'Options';
        controller.finalCardsMap.get(2).pumpOutsideCountry = false;
        controller.finalCardsMap.get(2).pumpAtPartners = true;
        controller.finalCardsMap.get(2).needOdometerOptions = true;
        controller.finalCardsMap.get(2).selectedTypeOfCar = 'LKW';
        controller.goToEmbossing();
        controller.finalCardsMap.get(2).selectedDriverNameOrCarNumber = 'driver-name';
        controller.finalCardsMap.get(2).driverNameOrCarNumberInputValue = 'CONOR MCGREGOR';
        controller.finalCardsMap.get(2).companyNameInputValue = 'JOHN WICK CORPORATION';
        controller.saveCard();

        ApexPages.currentPage().getparameters().put('cardindex', '3');
        controller.finalCardsMap.get(3).categoryCard = 'Diesel';
        controller.finalCardsMap.get(3).activeCardConfigStepMobile = 'Options';
        controller.finalCardsMap.get(3).pumpOutsideCountry = true;
        controller.finalCardsMap.get(3).pumpAtPartners = false;
        controller.finalCardsMap.get(3).needOdometerOptions = true;
        controller.finalCardsMap.get(3).selectedTypeOfCar = 'PKW';
        controller.goToEmbossing();
        controller.finalCardsMap.get(3).selectedDriverNameOrCarNumber = 'driver-name';
        controller.finalCardsMap.get(3).driverNameOrCarNumberInputValue = 'BRUCE WILLIS';
        controller.finalCardsMap.get(3).companyNameInputValue = 'JOHN WICK CORPORATION';
        controller.editCompanyName();
        controller.saveCard();

        ApexPages.currentPage().getparameters().put('cardindex', '4');
        controller.finalCardsMap.get(4).categoryCard = 'Diesel';
        controller.finalCardsMap.get(4).activeCardConfigStepMobile = 'Options';
        controller.finalCardsMap.get(4).pumpOutsideCountry = true;
        controller.finalCardsMap.get(4).pumpAtPartners = true;
        controller.finalCardsMap.get(4).needOdometerOptions = true;
        controller.finalCardsMap.get(4).selectedTypeOfCar = 'PKW';
        controller.goToEmbossing();
        controller.finalCardsMap.get(4).selectedDriverNameOrCarNumber = 'driver-name';
        controller.finalCardsMap.get(4).driverNameOrCarNumberInputValue = 'DANA WHITE';
        controller.finalCardsMap.get(4).companyNameInputValue = 'JOHN WICK CORPORATION';
        controller.saveCard();
        controller.editCardConfigurationMobile();
        controller.removeCard();

        ApexPages.currentPage().getparameters().put('cardindex', '3');
        controller.goToOptions();
        controller.goToFeesAndCosts();
        controller.goToSpecialOffers();

        controller.editCreditScoreData();

        List<Opportunity> oppList = [
                SELECT StageName, E2E_Active_Step__c, E2E_Active_Substep__c, Anzahl_der_Karten__c, Total_number_of_vehicles__c, Derzeitige_Zahlungsmethode__c, Diesel_consumption_l_month__c, 
                    Gasoline_consumption_l_month__c, Number_of_cars__c, Number_of_trucks__c, Account.Beschaeftigte__c, Account.Umsatzsteuer_ID__c, 
                    (SELECT Produktbezugskategorie__c, Gewuenschter_Kartentyp__c, Driver_Name__c, KFZ_Kennzeichen_oder_Fahrername__c, Kilometerstand_Abfrage__c, 
                        Firmenname_auf_der_Karte__c, Fahrzeugtyp__c 
                    FROM Tankkarten__r)
                FROM Opportunity 
                WHERE Id = :opportunity.Id];

        // Opportunity
        System.assertEquals('Credit approved', oppList.get(0).StageName, 'Wrong stage name.');
        System.assertEquals(2, oppList.get(0).E2E_Active_Step__c, 'Wrong active step.');
        System.assertEquals('Additional services', oppList.get(0).E2E_Active_Substep__c, 'Wrong active sub step.');
        System.assertEquals(3, oppList.get(0).Anzahl_der_Karten__c, 'Invalid number of cards.');
        System.assertEquals(3, oppList.get(0).Total_number_of_vehicles__c, 'Invalid total number of vehicles.');
        System.assertEquals('Barzahlung', oppList.get(0).Derzeitige_Zahlungsmethode__c, 'Wrong payment method.');
        System.assertEquals(2, oppList.get(0).Number_of_cars__c, 'Invalid number of cars.');
        System.assertEquals(1, oppList.get(0).Number_of_trucks__c, 'Invalid number of trucks.');
        System.assertEquals('1-4', oppList.get(0).Account.Beschaeftigte__c, 'Invalid number of employees.');
        // Tankkarten
        System.assertEquals(3, oppList.get(0).Tankkarten__r.size());
        
        List<Tankkarten__c> card1List = [
                SELECT Produktbezugskategorie__c, Gewuenschter_Kartentyp__c, Driver_Name__c, KFZ_Kennzeichen_oder_Fahrername__c, Kilometerstand_Abfrage__c, 
                    Firmenname_auf_der_Karte__c, Fahrzeugtyp__c 
                FROM Tankkarten__c 
                WHERE Driver_Name__c = 'Shell Card 1'];
        System.assertEquals('2 Kategorie 1 plus fahrzeugbezogene Waren und Dienstleistungen (Öle, Autowäsche)', card1List.get(0).Produktbezugskategorie__c, 'Wrong name of product.');
        System.assertEquals('Single Network Card -- National', card1List.get(0).Gewuenschter_Kartentyp__c, 'Wrong type of card.');
        System.assertEquals('Shell Card 1', card1List.get(0).Driver_Name__c, 'Wrong driver name.');
        System.assertEquals(true, card1List.get(0).Kilometerstand_Abfrage__c, 'Expected true.');
        System.assertEquals('TESTCOMPANY', card1List.get(0).Firmenname_auf_der_Karte__c, 'Should be name from account.');
        System.assertEquals('PKW', card1List.get(0).Fahrzeugtyp__c, 'Wrong type of vehicle.');

        List<Tankkarten__c> card2List = [
                SELECT Produktbezugskategorie__c, Gewuenschter_Kartentyp__c, Driver_Name__c, KFZ_Kennzeichen_oder_Fahrername__c, Kilometerstand_Abfrage__c, 
                    Firmenname_auf_der_Karte__c, Fahrzeugtyp__c 
                FROM Tankkarten__c 
                WHERE Driver_Name__c = 'Shell Card 2'];
        System.assertEquals('1 Alle Kraftstoffe, Tunnel-, Maut- und Fährgebühren', card2List.get(0).Produktbezugskategorie__c, 'Wrong name of product.');
        System.assertEquals('Multi Network Card -- National', card2List.get(0).Gewuenschter_Kartentyp__c, 'Wrong type of card.');
        System.assertEquals('Shell Card 2', card2List.get(0).Driver_Name__c, 'Wrong driver name.');
        System.assertEquals(true, card2List.get(0).Kilometerstand_Abfrage__c, 'Expected true.');
        System.assertEquals('TESTCOMPANY', card2List.get(0).Firmenname_auf_der_Karte__c, 'Should be name from account.');
        System.assertEquals('LKW', card2List.get(0).Fahrzeugtyp__c, 'Wrong type of vehicle.');

        List<Tankkarten__c> card3List = [
                SELECT Produktbezugskategorie__c, Gewuenschter_Kartentyp__c, Driver_Name__c, KFZ_Kennzeichen_oder_Fahrername__c, Kilometerstand_Abfrage__c, 
                    Firmenname_auf_der_Karte__c, Fahrzeugtyp__c 
                FROM Tankkarten__c 
                WHERE Driver_Name__c = 'Shell Card 3'];
        System.assertEquals('0 Diesel, Tunnel-, Maut- und Fährgebühren', card3List.get(0).Produktbezugskategorie__c, 'Wrong name of product.');
        System.assertEquals('Single Network Card -- International', card3List.get(0).Gewuenschter_Kartentyp__c, 'Wrong type of card.');
        System.assertEquals('Shell Card 3', card3List.get(0).Driver_Name__c, 'Wrong driver name.');
        System.assertEquals(true, card3List.get(0).Kilometerstand_Abfrage__c, 'Expected true.');
        System.assertEquals('TESTCOMPANY', card3List.get(0).Firmenname_auf_der_Karte__c, 'Should be name from account.');
        System.assertEquals('PKW', card3List.get(0).Fahrzeugtyp__c, 'Wrong type of vehicle.');
    }


    /*******************************************************************************
    *  Name            : chooseOfferPLMobTest()
    *  Summary         : Test choose offer step    
    *  CreatedDate     : 04/12/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void chooseOfferPLMobTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Poland';
        Account.ShippingCountry = 'Poland';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.E2E_Active_Step__c = 2;
        opportunity.E2E_Active_Substep__c = 'Choosing offer';
        opportunity.Product__c = '';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactDE(account.Id);
        contact.MailingCountry = 'Poland';
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EFormPL');
        update opportunity;

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

        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormMobilePLController();
        controller.init();

        ApexPages.currentPage().getparameters().put('offerName', 'Shell Standard 2019');
        controller.chooseStation();
        controller.selectOffer();
        // test remove offer
        controller.removeOffer();
        controller.selectOffer();
        controller.goToAdditionalParams();

        controller.editCardConfiguration();

        List<Opportunity> oppList = [
                SELECT Product__c, Home_Station__c, ESI__c, StageName, E2E_Active_Step__c, E2E_Active_SubStep__c 
                FROM Opportunity 
                WHERE Id = :opportunity.Id];

        System.assertEquals('Shell Standard 2019', oppList.get(0).Product__c, 'Wrong type of product.');
        System.assertEquals('Credit approved', oppList.get(0).StageName, 'Wrong stage name.');
        System.assertEquals(2, oppList.get(0).E2E_Active_Step__c, 'Wrong active step.');
        System.assertEquals('Additional services', oppList.get(0).E2E_Active_SubStep__c, 'Wrong active sub step.');
    }


    /*******************************************************************************
    *  Name            : additionalServicesPLMobTest()
    *  Summary         : Additional services test and date of birth   
    *  CreatedDate     : 04/12/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void additionalServicesPLMobTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Poland';
        Account.ShippingCountry = 'Poland';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.E2E_Active_Step__c = 2;
        opportunity.E2E_Active_Substep__c = 'Additional services';
        opportunity.Product__c = 'Shell Standard 2019';
        opportunity.E2E_Form_of_Business__c = 'Solo-trader';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactDE(account.Id);
        contact.MailingCountry = 'Poland';
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EFormPL');
        update opportunity;

        // Credit_Factory_Report__c cfReport = E2ELongFormUtilsTest.createCFReport(opportunity.Id);
        // insert cfReport;

        // List<Tankkarten__c> cardsForInsert = new List<Tankkarten__c>();
        // Tankkarten__c card1 = E2ELongFormUtilsTest.createMultiNetworkCardInternational(opportunity.Id);
        // cardsForInsert.add(card1);

        // Tankkarten__c card2 = E2ELongFormUtilsTest.createMultiNetworkCardNational(opportunity.Id);
        // cardsForInsert.add(card2);

        // Tankkarten__c card3 = E2ELongFormUtilsTest.createSingleNetworkCardInternational(opportunity.Id);
        // cardsForInsert.add(card3);

        // Tankkarten__c card4 = E2ELongFormUtilsTest.createSingleNetworkCardNational(opportunity.Id);
        // cardsForInsert.add(card4);

        // insert cardsForInsert;

        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormMobilePLController();
        controller.init();
        controller.showSaveAndContinueLaterModal();
        controller.doSaveAndContinueLater();
        controller.stepPagesMap.get('ADDITIONAL').elements.get('ADDITIONAL SERVICE #1').get('AGREEMENT CHECKBOX VALUE').Value__c = 'true';
        controller.stepPagesMap.get('ADDITIONAL').elements.get('ADDITIONAL SERVICE #2').get('VAT AGREEMENT CHECKBOX VALUE').Value__c = 'true';
        controller.stepPagesMap.get('ADDITIONAL').elements.get('ADDITIONAL SERVICE #2').get('VAT TC AGREEMENT CHECKBOX VALUE').Value__c = 'true';
        controller.stepPagesMap.get('ADDITIONAL').elements.get('ADDITIONAL SERVICE #3').get('AGREEMENT CHECKBOX VALUE').Value__c = 'true';
        controller.showTermsAndConditionsVatRecoveryModal();
        controller.goToDocuments();
        controller.stepPagesMap.get('ADDITIONAL. ENTER DATE OF BIRTH').fields.get('DATE OF BIRTH').elementItemsMap.get('DEFAULT VALUE').Value__c = '24.01.1990';
        controller.continueToDocumentsFromDateOfBirth();

        controller.editSpecialOffers();

        // controller.stepPagesMap.get('ADDITIONAL').elements.get('ADDITIONAL SERVICE #1').get('AGREEMENT CHECKBOX VALUE').Value__c = 'false';
        // controller.stepPagesMap.get('ADDITIONAL').elements.get('ADDITIONAL SERVICE #2').get('VAT AGREEMENT CHECKBOX VALUE').Value__c = 'false';
        // controller.stepPagesMap.get('ADDITIONAL').elements.get('ADDITIONAL SERVICE #2').get('VAT TC AGREEMENT CHECKBOX VALUE').Value__c = 'false';
        // controller.stepPagesMap.get('ADDITIONAL').elements.get('ADDITIONAL SERVICE #3').get('AGREEMENT CHECKBOX VALUE').Value__c = 'true';
        // controller.goToDocuments();

        List<Contact> contactList = [
                SELECT Birthdate,
                    (SELECT Opportunity.VAT_Recovery__c, Opportunity.Agree_to_VAT_Recovery_TC__c, Opportunity.Eco_Fee__c, Opportunity.E2E_Active_Step__c, Opportunity.E2E_Active_Substep__c, Opportunity.Interested_in_Telematics__c
                    FROM OpportunityContactRoles)
                FROM Contact];

        // Contact
        System.assertEquals('1990-01-24', String.valueOf(contactList.get(0).Birthdate));
        // Opportunity
        System.assertEquals(true, contactList.get(0).OpportunityContactRoles.get(0).Opportunity.VAT_Recovery__c);
        System.assertEquals(true, contactList.get(0).OpportunityContactRoles.get(0).Opportunity.Agree_to_VAT_Recovery_TC__c);
        System.assertEquals(true, contactList.get(0).OpportunityContactRoles.get(0).Opportunity.Eco_Fee__c);
        System.assertEquals(true, contactList.get(0).OpportunityContactRoles.get(0).Opportunity.Interested_in_Telematics__c);
        System.assertEquals(3, contactList.get(0).OpportunityContactRoles.get(0).Opportunity.E2E_Active_Step__c);
        System.assertEquals('Documents', contactList.get(0).OpportunityContactRoles.get(0).Opportunity.E2E_Active_Substep__c);
    }


    /*******************************************************************************
    *  Name            : documentsPLMobTest()
    *  Summary         : Testing documents step    
    *  CreatedDate     : 03/12/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void documentsPLMobTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Poland';
        Account.ShippingCountry = 'Poland';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Pending Credit Check';
        opportunity.E2E_Active_Step__c = 3;
        opportunity.E2E_Active_Substep__c = 'Documents';
        opportunity.Product__c = 'Shell Standard 2019';
        opportunity.E2E_Status__c = 'Abandoned (hard)';
        opportunity.E2E_Sub_Status__c = 'Marketing automation';
        opportunity.Rechnungsperiode__c = '15';
        opportunity.Zahlungsziel_Credit__c = '14';
        opportunity.Security_To_Pay__c = 'Kaution';
        insert opportunity;

        Attachment creditScoringAllowanceForOppty = E2ELongFormUtilsTest.createAttachment('Umowa Karty euroShell (DocuSign).pdf', opportunity.Id);
        insert creditScoringAllowanceForOppty;

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

        dsfs__DocuSign_Status__c docusignStatus = E2ELongFormUtilsTest.createDocusignStatus(opportunity.Id);
        insert docusignStatus;

        Attachment creditScoringAllowanceForStatus = E2ELongFormUtilsTest.createAttachment('Umowa Karty euroShell (DocuSign).pdf', docusignStatus.Id);
        insert creditScoringAllowanceForStatus;

        dsfs__DocuSign_Recipient_Status__c docusignRecipientStatus = E2ELongFormUtilsTest.createRecipientStatus(docusignStatus.Id);
        insert docusignRecipientStatus;

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EFormPL');
        update opportunity;

        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormMobilePLController();
        controller.init();
        // catch errors
        controller.saveDocumentsStepData();
        // normal flow
        controller.stepPagesMap.get('DOCUMENTS').fields.get('PAPER INVOICE').elementItemsMap.get('VALUE').Value__c = 'true';
        controller.stepPagesMap.get('DOCUMENTS').fields.get('DECISION').elementItemsMap.get('VALUE').Value__c = 'true';
        controller.stepPagesMap.get('DOCUMENTS').fields.get('ACCEPT TERMS AND CONDITIONS').elementItemsMap.get('VALUE').Value__c = 'true';
        controller.showTermsAndConditions();
        controller.showDocumentsModal();
        controller.closeModal();
        controller.saveDocumentsStepData();

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new DocusignPLMock());
            controller.goToSignDocuments();
        Test.stopTest();

        List<Contact> contactList = [
                SELECT Authorised_signatory__c,
                    (SELECT Opportunity.Papierrechnung__c, Opportunity.e_Invoicing_PDF__c, Opportunity.AGB_Datenschutzhinweise_Richtigkeit__c
                    FROM OpportunityContactRoles)
                FROM Contact];

        // Opportunity
        System.assertEquals(true, contactList.get(0).OpportunityContactRoles.get(0).Opportunity.Papierrechnung__c);
        System.assertEquals(false, contactList.get(0).OpportunityContactRoles.get(0).Opportunity.e_Invoicing_PDF__c);
        System.assertEquals(true, contactList.get(0).OpportunityContactRoles.get(0).Opportunity.AGB_Datenschutzhinweise_Richtigkeit__c);
        // Contact
        System.assertEquals(true, contactList.get(0).Authorised_signatory__c);
    }


    /*******************************************************************************
    *  Name            : returnFromDocusignDepositPLMobTest()
    *  Summary         : Testing flow when customer signed documents (deposit required)   
    *  CreatedDate     : 04/12/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void returnFromDocusignDepositPLMobTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Poland';
        Account.ShippingCountry = 'Poland';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Pending Credit Check';
        opportunity.E2E_Active_Step__c = 3;
        opportunity.E2E_Active_Substep__c = 'Documents';
        opportunity.Product__c = 'Shell Standard 2019';
        opportunity.E2E_Status__c = 'Abandoned (hard)';
        opportunity.E2E_Sub_Status__c = 'Marketing automation';
        opportunity.Rechnungsperiode__c = '15';
        opportunity.Zahlungsziel_Credit__c = '14';
        opportunity.Security_To_Pay__c = 'Kaution';
        insert opportunity;

        Attachment creditScoringAllowanceForOppty = E2ELongFormUtilsTest.createAttachment('Umowa Karty euroShell (DocuSign).pdf', opportunity.Id);
        insert creditScoringAllowanceForOppty;

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

        dsfs__DocuSign_Status__c docusignStatus = E2ELongFormUtilsTest.createDocusignStatus(opportunity.Id);
        insert docusignStatus;

        Attachment creditScoringAllowanceForStatus = E2ELongFormUtilsTest.createAttachment('Umowa Karty euroShell (DocuSign).pdf', docusignStatus.Id);
        insert creditScoringAllowanceForStatus;

        dsfs__DocuSign_Recipient_Status__c docusignRecipientStatus = E2ELongFormUtilsTest.createRecipientStatus(docusignStatus.Id);
        insert docusignRecipientStatus;

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EFormPL');
        update opportunity;

        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        ApexPages.currentPage().getparameters().put('event', 'OnSigningComplete');
        controller = new LongFormMobilePLController();
        controller.init();

        List<Opportunity> opportunityList = [SELECT E2E_Active_Step__c, StageName, E2E_Active_Substep__c FROM Opportunity WHERE Id = :opportunity.Id];
        System.assertEquals(4, opportunityList.get(0).E2E_Active_Step__c);
        System.assertEquals('Credit approved', opportunityList.get(0).StageName);
        System.assertEquals('DirectDebitDeposit', opportunityList.get(0).E2E_Active_Substep__c);
    }


    /*******************************************************************************
    *  Name            : returnFromDocusignNoNDepositPLMobTest()
    *  Summary         : Testing flow when customer signed documents (deposit is not required)   
    *  CreatedDate     : 04/12/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void returnFromDocusignNoNDepositPLMobTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Poland';
        Account.ShippingCountry = 'Poland';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Pending Credit Check';
        opportunity.E2E_Active_Step__c = 3;
        opportunity.E2E_Active_Substep__c = 'Documents';
        opportunity.Product__c = 'Shell Standard 2019';
        opportunity.E2E_Status__c = 'Abandoned (hard)';
        opportunity.E2E_Sub_Status__c = 'Marketing automation';
        opportunity.Rechnungsperiode__c = '15';
        opportunity.Zahlungsziel_Credit__c = '14';
        insert opportunity;

        Attachment creditScoringAllowanceForOppty = E2ELongFormUtilsTest.createAttachment('Umowa Karty euroShell (DocuSign).pdf', opportunity.Id);
        insert creditScoringAllowanceForOppty;

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

        dsfs__DocuSign_Status__c docusignStatus = E2ELongFormUtilsTest.createDocusignStatus(opportunity.Id);
        insert docusignStatus;

        Attachment creditScoringAllowanceForStatus = E2ELongFormUtilsTest.createAttachment('Umowa Karty euroShell (DocuSign).pdf', docusignStatus.Id);
        insert creditScoringAllowanceForStatus;

        dsfs__DocuSign_Recipient_Status__c docusignRecipientStatus = E2ELongFormUtilsTest.createRecipientStatus(docusignStatus.Id);
        insert docusignRecipientStatus;

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EFormPL');
        update opportunity;

        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        ApexPages.currentPage().getparameters().put('event', 'OnSigningComplete');
        controller = new LongFormMobilePLController();
        controller.init();

        List<Opportunity> opportunityList = [
                SELECT E2E_Active_Step__c, StageName, E2E_Active_Substep__c, ForecastCategoryName, Closed_Won_by_CF__c, CF_Stage__c, Bearbeitet_von__c, Kredit_Entscheidung__c, 
                    Billing_Period_by_Sales__c, Last_CF_Errors__c, E2E_payment_status__c, E2E_Status__c
                FROM Opportunity 
                WHERE Id = :opportunity.Id];
        System.assertEquals(5, opportunityList.get(0).E2E_Active_Step__c);
        System.assertEquals('Closed Won', opportunityList.get(0).StageName);
        System.assertEquals('Congratulations', opportunityList.get(0).E2E_Active_Substep__c);
        System.assertEquals('Closed', opportunityList.get(0).ForecastCategoryName);
        System.assertEquals(true, opportunityList.get(0).Closed_Won_by_CF__c);
        System.assertEquals('Auto CW', opportunityList.get(0).CF_Stage__c);
        System.assertEquals(null, opportunityList.get(0).Bearbeitet_von__c);
        System.assertEquals(null, opportunityList.get(0).Kredit_Entscheidung__c);
        System.assertEquals(true, opportunityList.get(0).Billing_Period_by_Sales__c);
        System.assertEquals(null, opportunityList.get(0).Last_CF_Errors__c);
        System.assertEquals('NO DEPOSIT', opportunityList.get(0).E2E_payment_status__c);
    }


    /*******************************************************************************
    *  Name            : paymentOptionsPLMobTest()
    *  Summary         : Testing payment options step    
    *  CreatedDate     : 04/12/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void paymentOptionsPLMobTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Poland';
        Account.ShippingCountry = 'Poland';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Pending Credit Check';
        opportunity.E2E_Active_Step__c = 4;
        opportunity.E2E_Active_Substep__c = 'DirectDebitDeposit';
        opportunity.Product__c = 'Shell Standard 2019';
        opportunity.E2E_Status__c = 'Abandoned (hard)';
        opportunity.E2E_Sub_Status__c = 'Marketing automation';
        opportunity.Rechnungsperiode__c = '15';
        opportunity.Zahlungsziel_Credit__c = '14';
        insert opportunity;

        Attachment creditScoringAllowanceForOppty = E2ELongFormUtilsTest.createAttachment('Umowa Karty euroShell (DocuSign).pdf', opportunity.Id);
        insert creditScoringAllowanceForOppty;

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

        dsfs__DocuSign_Status__c docusignStatus = E2ELongFormUtilsTest.createDocusignStatus(opportunity.Id);
        insert docusignStatus;

        Attachment creditScoringAllowanceForStatus = E2ELongFormUtilsTest.createAttachment('Umowa Karty euroShell (DocuSign).pdf', docusignStatus.Id);
        insert creditScoringAllowanceForStatus;

        dsfs__DocuSign_Recipient_Status__c docusignRecipientStatus = E2ELongFormUtilsTest.createRecipientStatus(docusignStatus.Id);
        insert docusignRecipientStatus;

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EFormPL');
        update opportunity;

        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormMobilePLController();
        controller.init();
        controller.proceedToCheckout();
        controller.editDocuments();

        // List<Payment_Transaction__c> paymentPransactionList = [SELECT Currency__c, PaymentMethod__c, Brand__c FROM Payment_Transaction__c];
        // System.assertEquals('PLN', paymentPransactionList.get(0).Currency__c);
        // System.assertEquals('CreditCard', paymentPransactionList.get(0).PaymentMethod__c);
        // System.assertEquals('Visa', paymentPransactionList.get(0).Brand__c);

        List<Opportunity> oppList = [
                SELECT StageName, E2E_Active_Substep__c, E2E_Active_Step__c, E2E_payment_status__c
                FROM Opportunity];

        System.assertEquals('Pending Sales – Deposit', oppList.get(0).StageName);
        System.assertEquals('Congratulations', oppList.get(0).E2E_Active_Substep__c);
        System.assertEquals(5, oppList.get(0).E2E_Active_Step__c);
        System.assertEquals('PAYMENT GATEWAY OFF', oppList.get(0).E2E_payment_status__c);
    }


    /*******************************************************************************
    *  Name            : congratulationsPLMobTest()
    *  Summary         : Testing return to congratulation test (Step 5)     
    *  CreatedDate     : 04/12/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void congratulationsPLMobTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Poland';
        Account.ShippingCountry = 'Poland';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.E2E_Active_Substep__c = 'DirectDebitDeposit';
        opportunity.Product__c = 'Shell Standard 2019';
        opportunity.E2E_Status__c = 'Abandoned (hard)';
        opportunity.E2E_Sub_Status__c = 'Marketing automation';
        opportunity.E2E_payment_status__c = 'ACCEPT';
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

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EFormPL');
        update opportunity;

        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormMobilePLController();
        controller.paymentStatus = 'A';
        controller.init();
        controller.showDDMandateModal();
        controller.showTermsAndConditionsModal();

        List<Opportunity> oppList = [
                SELECT StageName, ForecastCategoryName, Closed_Won_by_CF__c, CF_Stage__c, CloseDate, bearbeitet_von__c, Kredit_Entscheidung__c, Credit_check_date__c, 
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
    }
}