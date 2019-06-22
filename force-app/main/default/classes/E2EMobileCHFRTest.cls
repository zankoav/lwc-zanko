@isTest
private class E2EMobileCHFRTest {
    public static LongFormMobileCHController controller;

    /*******************************************************************************
    *  Name            : createLongFormData()
    *  Summary         : Creating all LongForm data    
    *  CreatedDate     : 05/03/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @testSetup
    static void createLongFormData() {
        E2ELongFormUtilsTest.createInternationalPartnersPrice('Switzerland-FR', 'Inbound');
        E2ELongFormUtilsTest.createNationalNotPartnersPrice('Switzerland-FR', 'Inbound');
        E2ELongFormUtilsTest.createInternationalNotPartnersPrice('Switzerland-FR', 'Inbound');
        E2ELongFormUtilsTest.createNationalPartnersPrice('Switzerland-FR', 'Inbound');
        E2ELongFormUtilsTest.createInternationalPartnersDiffPrice('Switzerland-FR', 'Inbound');
        E2ELongFormUtilsTest.createNationalNotPartnersDiffPrice('Switzerland-FR', 'Inbound');
        E2ELongFormUtilsTest.createInternationalNotPartnersDiffPrice('Switzerland-FR', 'Inbound');
        E2ELongFormUtilsTest.createNationalPartnersDiffPrice('Switzerland-FR', 'Inbound');
        E2ELongFormUtilsTest.createLongForm('Switzerland-FR');
        E2ELongFormUtilsTest.createLongFormMenu();
        E2ELongFormUtilsTest.createMenuItemForStep1('Mobile');
        E2ELongFormUtilsTest.createMenuItemForStep2('Mobile');
        E2ELongFormUtilsTest.createMenuItemForStep3('Mobile');
        E2ELongFormUtilsTest.createMenuItemForStep4('Mobile');
        E2ELongFormUtilsTest.createHeader('Mobile');
        E2ELongFormUtilsTest.createContactDeatilsData('Mobile');
        E2ELongFormUtilsTest.createCustomSettings('Switzerland-FR', 'E2EFormCHFR', 'CrediConnectCH', '00520000005vYf3');
        E2ELongFormUtilsTest.createOrderDetailsBlock('Mobile');
        E2ELongFormUtilsTest.createFooter('Mobile');
        E2ELongFormUtilsTest.createCreditScoreAnotherTaxID('Mobile');
        E2ELongFormUtilsTest.createCreditScoreSearchCompany('Mobile');
        E2ELongFormUtilsTest.createCreditScoreTotalConsumption('Mobile');
        E2ELongFormUtilsTest.createCreditScoringResult('Mobile');
        E2ELongFormUtilsTest.createCardConfiguration('Mobile');
        E2ELongFormUtilsTest.createCardConfigurationSpecialOffers('Mobile', 'SWISS OFFER #1', 'SWISS OFFER #1', 'Switzerland-FR', 'Inbound', 'Swiss Star', 'Swiss Star');
        E2ELongFormUtilsTest.createCardConfigurationTechnicalParameters('Mobile');
        E2ELongFormUtilsTest.createCardConfigurationInputVatId('Mobile');
        E2ELongFormUtilsTest.createAdditionalPage('Mobile');
        E2ELongFormUtilsTest.createPaymentOptions('Mobile');
        E2ELongFormUtilsTest.createCongratulationsPage('Mobile');
        E2ELongFormUtilsTest.createSystemErrorPage('Mobile');
        E2ELongFormUtilsTest.createProcessErrorPage('Mobile');
        E2ELongFormUtilsTest.createAlreadyCustomerPage('Mobile');
        E2ELongFormUtilsTest.createAlreadyInProcessPage('Mobile');

        E2ELongFormUtilsTest.createSaveAndContinueLater('Mobile');
        E2ELongFormUtilsTest.createSendDepositAgreementToTheEmail('Mobile');
        E2ELongFormUtilsTest.createSendHowToPay('Mobile');
        E2ELongFormUtilsTest.createSendTC('Mobile');
        E2ELongFormUtilsTest.createDDMandate('Mobile');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCrediconnectAccountMappingCH();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCrediconnectOpportunityMappingCH();
        insert creditFactoryOpportunity;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.doCreateCreditSystemSalesProfile();
        insert creditSystemSalesProfile;
    }


    /*******************************************************************************
    *  Name            : insertDupConSameDataClosedLostCHFR()
    *  Summary         : Verify that two Contacts were merged when First Name + Last Name + Email + Phone are the same and Contact #1 has E2E Opportunity #1 in stage Closed Lost    
    *  ExpectedResult  : Two contacts were merged. E2E Account #2, E2E Opportuinty #2 were created. Direct Connections were changed to E2E records
    *  CreatedDate     : 20/02/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void insertDupConSameDataClosedLostCHFR() {
        ApexPages.currentPage().getparameters().put('country', 'chfr');
        Account account = E2ELongFormUtilsTest.createAccountDE();
        account.BillingCountry = 'Switzerland-FR';
        account.ShippingCountry = 'Switzerland-FR';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Closed Lost';
        opportunity.Product__c = '';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        contact.MailingCountry = 'Switzerland-FR';
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        controller = new LongFormMobileCHController();
        controller.activeStep = 0;
        controller.init();
        controller.getStarted();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHN';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SMITH';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+41212345678';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'test@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '3';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
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
        System.assertEquals('+41212345678', contactList.get(0).Phone, 'Expected Phone from form.');
        System.assertEquals('test@fleetcor.com', contactList.get(0).Email, 'Expected Email from form.');
    }


    /*******************************************************************************
    *  Name            : insertDupConSameDataWithE2EOppCHFRMob()
    *  Summary         : Verify that two Contacts were merged when First Name + Last Name + Email + Phone are the same 
                         and Contact #1 has E2E Opportunity #1 NOT in stage Closed Lost / Closed WON / Pending Sales - Deposit
    *  ExpectedResult  : Two contacts were merged. Form of the business is updated in Opportunity #1 User is redirected to last E2E step of the Opportunity #1
    *  CreatedDate     : 05/03/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void insertDupConSameDataWithE2EOppCHFRMob() {
        ApexPages.currentPage().getparameters().put('country', 'chfr');
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Switzerland-FR';
        Account.ShippingCountry = 'Switzerland-FR';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Prospecting';
        opportunity.E2E_Active_Step__c = 1;
        opportunity.E2E_Active_Substep__c = 'Search company';
        opportunity.Product__c = '';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        contact.MailingCountry = 'Switzerland-FR';
        contact.Phone = '+41212345678';
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        controller = new LongFormMobileCHController();
        controller.activeStep = 0;
        controller.init();
        controller.getStarted();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHN';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SMITH';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+41212345678';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'test@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
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
        System.assertEquals('+41212345678', contactList.get(0).Phone, 'Expected Phone from form.');
        System.assertEquals('test@fleetcor.com', contactList.get(0).Email, 'Expected Email from form.');
    }


    /*******************************************************************************
    *  Name            : updateDupConSameDataClosedLostCHFRMob()
    *  Summary         : Verify that two Contacts were merged when First Name + Last Name + Email + Phone are the same and Contact #1 has E2E Opportunity #1 in stage Closed Lost
    *  ExpectedResult  : E2E Opportunity #2 Stage = Closed Lost. Reason = Duplicate. E2E Account #2, E2E Contact #2 were NOT deleted.
                         Contacts were merged. New E2E Account #3, New E2E Opportunity #3 were created. Direct Connections were changed to E2E records
    *  CreatedDate     : 05/03/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void updateDupConSameDataClosedLostCHFRMob() {
        ApexPages.currentPage().getparameters().put('country', 'chfr');
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Switzerland-FR';
        Account.ShippingCountry = 'Switzerland-FR';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Closed Lost';
        opportunity.Product__c = '';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        contact.MailingCountry = 'Switzerland-FR';
        contact.Phone = '+41212345678';
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        controller = new LongFormMobileCHController();
        controller.activeStep = 0;
        controller.init();
        controller.getStarted();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JohnAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SmithAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+41211111111';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'testAA@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCompanyDetails();
        // back to update data
        controller.editContactDetails();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHN';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SMITH';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+41212345678';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'test@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
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
        System.assertEquals('+41212345678', contactList.get(0).Phone, 'Expected Phone from form.');
        System.assertEquals('test@fleetcor.com', contactList.get(0).Email, 'Expected Email from form.');
    }


    /*******************************************************************************
    *  Name            : updateDupConSameDataProspectingCHFRMob()
    *  Summary         : Verify that two Contacts were merged when First Name + Last Name + Email + Phone are the same and 
                         Contact #1 has E2E Opportunity #1 NOT in stage Closed Lost / Closed WON / Pending Sales - Deposit
    *  ExpectedResult  : E2E Opportunity #2 Stage = Closed Lost. Reason = Duplicate. E2E Account #2, E2E Contact #2 were NOT deleted. Contacts were merged. 
                         User is redirected to the last E2E step of the Opportunity #1
    *  CreatedDate     : 06/03/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void updateDupConSameDataProspectingCHFRMob() {
        ApexPages.currentPage().getparameters().put('country', 'chfr');
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Switzerland-FR';
        Account.ShippingCountry = 'Switzerland-FR';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Prospecting';
        opportunity.Product__c = '';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        contact.MailingCountry = 'Switzerland-FR';
        contact.Phone = '+41212345678';
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        controller = new LongFormMobileCHController();
        controller.activeStep = 0;
        controller.init();
        controller.getStarted();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JohnAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SmithAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+41211111111';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'testAA@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCompanyDetails();
        // back to update data
        controller.editContactDetails();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHN';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SMITH';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+41212345678';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'test@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
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
        System.assertEquals('+41212345678', contactList.get(0).Phone, 'Expected Phone from form.');
        System.assertEquals('test@fleetcor.com', contactList.get(0).Email, 'Expected Email from form.');
    }


    /*******************************************************************************
    *  Name            : contactDetailsCHFRMobTest()
    *  Summary         : Testing contact details step with valid data    
    *  CreatedDate     : 06/03/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void contactDetailsCHFRMobTest() {
        ApexPages.currentPage().getparameters().put('country', 'chfr');
        controller = new LongFormMobileCHController();
        // catch error in init method
        controller.init();
        controller.activeStep = 0;
        controller.init();
        controller.getStarted();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Herr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHN';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'WICK';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+41212345678';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'john@wick.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCompanyDetails();

        List<Contact> contactList = [
                SELECT Salutation, FirstName, LastName, Phone, Email, Authorised_signatory__c, LeadSource, MailingCountry, RecordType.Name, E2E__c, 
                    (SELECT Account.Name, Account.RecordType.Name, Account.Type, Account.AccountSource, Account.E2E__c, Account.BillingCountry, Account.ShippingCountry 
                    FROM AccountContactRelations), 
                    (SELECT Opportunity.Name, Opportunity.StageName, Opportunity.E2E__c, Opportunity.Product__c, Opportunity.CloseDate, Opportunity.Language_preference__c, 
                        Opportunity.Primary_Contact_Phone__c, Opportunity.Agree_to_Privacy_Policy__c, Opportunity.Date_for_Agree_to_Privacy_Policy__c, 
                        Opportunity.LeadSource, Opportunity.Sec_Channel__c, Opportunity.Channel__c, Opportunity.CurrencyIsoCode, Opportunity.Type, Opportunity.Eco_Fee__c, 
                        Opportunity.Visitor_ID__c, Opportunity.AGB_Datenschutzhinweise_Richtigkeit__c, Opportunity.E2E_Form_of_Business__c, Opportunity.E2E_Active_Step__c, 
                        Opportunity.E2E_Active_Substep__c
                    FROM OpportunityContactRoles)
                FROM Contact];

        // contact
        System.assertEquals(1, contactList.size(), 'One Contact is expected.');
        System.assertEquals('Herr', contactList.get(0).Salutation, 'Should be value from form.');
        System.assertEquals('JOHN', contactList.get(0).FirstName, 'Should be value from form.');
        System.assertEquals('WICK', contactList.get(0).LastName, 'Should be value from form.');
        System.assertEquals('+41212345678', contactList.get(0).Phone, 'Should be value from form.');
        System.assertEquals('john@wick.com', contactList.get(0).Email, 'Should be value from form.');
        System.assertEquals(false, contactList.get(0).Authorised_signatory__c, 'Should be Automatic filling by default.');
        System.assertEquals(true, contactList.get(0).E2E__c, 'Should be Automatic filling by default.');
        System.assertEquals('Switzerland-FR', contactList.get(0).MailingCountry, 'Should be Automatic filling by default.');
        System.assertEquals('Contact layout', contactList.get(0).RecordType.Name, 'Should be Automatic filling by default.');
        // account
        System.assertEquals(1, contactList.get(0).AccountContactRelations.size(), 'One Account is expected.');
        System.assertEquals('LONGFORM: JOHN WICK', contactList.get(0).AccountContactRelations.get(0).Account.Name, 'Should be value from form.');
        System.assertEquals('Endkunde', contactList.get(0).AccountContactRelations.get(0).Account.RecordType.Name, 'Should be Automatic filling by default.');
        System.assertEquals('Customer', contactList.get(0).AccountContactRelations.get(0).Account.Type, 'Should be Automatic filling by default.');
        System.assertEquals(true, contactList.get(0).AccountContactRelations.get(0).Account.E2E__c, 'Should be Automatic filling by default.');
        System.assertEquals('Switzerland-FR', contactList.get(0).AccountContactRelations.get(0).Account.BillingCountry, 'Should be Automatic filling by default.');
        System.assertEquals('Switzerland-FR', contactList.get(0).AccountContactRelations.get(0).Account.ShippingCountry, 'Should be Automatic filling by default.');
        // opportunity
        System.assertEquals(1, contactList.get(0).OpportunityContactRoles.size(), 'One Opportunity is expected.');
        System.assertEquals('LONGFORM: JOHN WICK', contactList.get(0).OpportunityContactRoles.get(0).Opportunity.Name, 'Should be value from form.');
        System.assertEquals('Prospecting', contactList.get(0).OpportunityContactRoles.get(0).Opportunity.StageName, 'Should be Automatic filling by default.');
        System.assertEquals(null, contactList.get(0).OpportunityContactRoles.get(0).Opportunity.Product__c, 'Should be Automatic filling by default.');
        System.assertEquals('French', contactList.get(0).OpportunityContactRoles.get(0).Opportunity.Language_preference__c, 'Should be Automatic filling by default.');
        System.assertEquals('+41212345678', contactList.get(0).OpportunityContactRoles.get(0).Opportunity.Primary_Contact_Phone__c, 'Should be value from form.');
        System.assertEquals(true, contactList.get(0).OpportunityContactRoles.get(0).Opportunity.Agree_to_Privacy_Policy__c, 'Should be Automatic filling by default.');
        System.assertEquals(true, contactList.get(0).OpportunityContactRoles.get(0).Opportunity.E2E__c, 'Should be Automatic filling by default.');
        System.assertEquals('Inbound', contactList.get(0).OpportunityContactRoles.get(0).Opportunity.Sec_Channel__c, 'Should be Automatic filling by default.');
        System.assertEquals('Internet', contactList.get(0).OpportunityContactRoles.get(0).Opportunity.Channel__c, 'Should be Automatic filling by default.');
        System.assertEquals('CHF', contactList.get(0).OpportunityContactRoles.get(0).Opportunity.CurrencyIsoCode, 'Should be Automatic filling by default.');
        System.assertEquals('New Business', contactList.get(0).OpportunityContactRoles.get(0).Opportunity.Type, 'Should be Automatic filling by default.');
        System.assertEquals(false, contactList.get(0).OpportunityContactRoles.get(0).Opportunity.Eco_Fee__c, 'Should be Automatic filling by default.');
        System.assertEquals(false, contactList.get(0).OpportunityContactRoles.get(0).Opportunity.AGB_Datenschutzhinweise_Richtigkeit__c, 'Should be Automatic filling by default.');
        System.assertEquals('Company', contactList.get(0).OpportunityContactRoles.get(0).Opportunity.E2E_Form_of_Business__c, 'Should be Automatic filling by default.');
        System.assertEquals(1, contactList.get(0).OpportunityContactRoles.get(0).Opportunity.E2E_Active_Step__c, 'Should be Automatic filling by default.');
        System.assertEquals('Search company', contactList.get(0).OpportunityContactRoles.get(0).Opportunity.E2E_Active_Substep__c, 'Should be Automatic filling by default.');
    }


    /*******************************************************************************
    *  Name            : searchCompanyCHFRMobTest()
    *  Summary         : Testing search company mock    
    *  CreatedDate     : 06/03/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void searchCompanyCHFRMobTest() {
        ApexPages.currentPage().getparameters().put('country', 'chfr');
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Switzerland-FR';
        Account.ShippingCountry = 'Switzerland-FR';
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
        contact.MailingCountry = 'Switzerland-FR';
        contact.Salutation = 'Mr';
        contact.FirstName = 'Andrew';
        contact.LastName = 'Richard Hackett';
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EFormCHFR');
        update opportunity;

        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormMobileCHController();
        controller.init();

        controller.stepPagesMap.get('CREDIT SCORE. SEARCH COMPANY').fields.get('COMPANY NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Association Maine Coon Test en liquidation';
        controller.stepPagesMap.get('CREDIT SCORE. SEARCH COMPANY').fields.get('CITY').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Cossonay-Ville';
        controller.doSaveCompanyDetailsData();

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new E2ELongFormCHCreditFactoryMock());
            controller.doSearchCompany();
        Test.stopTest();

        controller.editCompanyDetails();

        List<Opportunity> oppList = [
                SELECT Name, CF_Stage__c, E2E_Active_Step__c, E2E_Active_Substep__c, Account.Name, Account.BillingCity
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        // Opportunity
        System.assertEquals('ASSOCIATION MAINE COON TEST EN LIQUIDATION', oppList.get(0).Name, 'Expected company name from form.');
        System.assertEquals(1, oppList.get(0).E2E_Active_Step__c, 'Expected first step.');
        System.assertEquals('Launched', oppList.get(0).CF_Stage__c, 'Wrong CF Stage.');
        System.assertEquals('Search company', oppList.get(0).E2E_Active_Substep__c, 'Expected Search company substep.');
        // Account
        System.assertEquals('ASSOCIATION MAINE COON TEST EN LIQUIDATION', oppList.get(0).Account.Name, 'Expected company name from form.');
        System.assertEquals('COSSONAY-VILLE', oppList.get(0).Account.BillingCity, 'Expected city from form.');
    }


    /*******************************************************************************
    *  Name            : getReportCHFRMobTest()
    *  Summary         : Test get Report, Tax Id, fuel consumption,   
    *  CreatedDate     : 06/03/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void getReportCHFRMobTest() {
        ApexPages.currentPage().getparameters().put('country', 'chfr');
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Switzerland-FR';
        Account.ShippingCountry = 'Switzerland-FR';
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
        contact.MailingCountry = 'Switzerland-FR';
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EFormCHFR');
        update opportunity;

        Tankkarten__c card1 = E2ELongFormUtilsTest.createSingleNetworkCardInternational(opportunity.Id);
        insert card1;

        Tankkarten__c card2 = E2ELongFormUtilsTest.createSingleNetworkCardNational(opportunity.Id);
        insert card2;

        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormMobileCHController();
        controller.init();
        controller.selectedCompany = new CreditCompany();
        controller.selectedCompany.identificationnumber = '406471879';
        controller.deleteReportsForPreviousCompany();
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new E2ELongFormCHCreditFactoryMock());
            controller.goToSetTotalConsumption();
        Test.stopTest();

        // TAX ID step
        controller.selectedCompany.vatid = 'CHE110477663';
        controller.continueToTotalConsumption();

        // Fuel consumption
        controller.stepPagesMap.get('CREDIT SCORE. TOTAL CONSUMPTION').fields.get('TOTAL CONSUMPTION').elementItemsMap.get('DEFAULT VALUE').Value__c = '1000';
        controller.showSaveAndContinueLaterModal();
        controller.sendEnvelope();
        controller.doCalculateCreditScoring();

        controller.stepPagesMap.get('CREDIT SCORE. SCORING RESULT').fields.get('PAYMENT METHOD').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Banküberweisung';
        controller.defaultBillingPeriod = 30;
        controller.stepPagesMap.get('CREDIT SCORE. SCORING RESULT').fields.get('BILLING PERIOD').elementItemsMap.get('MONTHLY BUTTON NAME').Value__c = '30';
        controller.doRecalculateDeposit();

        controller.stepPagesMap.get('CREDIT SCORE. SCORING RESULT').fields.get('PAYMENT METHOD').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Lastschrift';
        controller.defaultBillingPeriod = 30;
        controller.stepPagesMap.get('CREDIT SCORE. SCORING RESULT').fields.get('BILLING PERIOD').elementItemsMap.get('MONTHLY BUTTON NAME').Value__c = '30';
        controller.doRecalculateDeposit();
        controller.goToCardsConfig();

        controller.editCreditScoreData();

        List<Opportunity> oppList = [
                SELECT Name, StageName, CF_Stage__c, Credit_System_Rating__c, Umsatz__c, Credit_System_Number__c, E2E_Active_Step__c, E2E_Last_Activity__c, Visitor_ID__c, E2E_Encoded_URL__c, 
                    Account.Name, Account.BillingStreet, Account.BillingPostalCode, Account.BillingCity, Account.ShippingCountry, Account.ShippingStreet, Account.ShippingPostalCode, 
                    Account.ShippingCity, Account.Umsatzsteuer_ID__c, Account.Steuernummer__c, E2E_Active_Substep__c, 
                    Gasoline_consumption_l_month__c, Diesel_consumption_l_month__c, Total_consumption_l_month__c, 
                    (SELECT Contact.MailingStreet, Contact.MailingPostalCode, Contact.MailingCity FROM OpportunityContactRoles)
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        // Opportunity
        System.assertEquals('TEST AG SCHWEIZ', oppList.get(0).Name, 'Should be Automatic filling by default from CF.');
        System.assertEquals('Credit approved', oppList.get(0).StageName, 'Should be Automatic filling by default.');
        System.assertEquals(0, oppList.get(0).Gasoline_consumption_l_month__c, 'Always should be 0.');
        System.assertEquals(1000, oppList.get(0).Diesel_consumption_l_month__c, 'Shoul be the same as total consumption.');
        System.assertEquals(1000, oppList.get(0).Total_consumption_l_month__c, 'Wrong total consumption.');
        System.assertEquals('Card configuration', oppList.get(0).E2E_Active_Substep__c, 'Wrong active substep.');
        System.assertEquals(2, oppList.get(0).E2E_Active_Step__c, 'Should be Automatic filling by default.');

        // Account 
        System.assertEquals('TEST AG SCHWEIZ', oppList.get(0).Account.Name, 'Should be Automatic filling by default from CF.');
        System.assertEquals('BÖSCH 63', oppList.get(0).Account.BillingStreet, 'Should be Automatic filling by default from CF.');
        System.assertEquals('6331', oppList.get(0).Account.BillingPostalCode, 'Should be Automatic filling by default from CF.');
        System.assertEquals('HÜNENBERG', oppList.get(0).Account.BillingCity, 'Should be Automatic filling by default from CF.');
        System.assertEquals('Switzerland-FR', oppList.get(0).Account.ShippingCountry, 'Should be Automatic filling by default from CF.');
        System.assertEquals('BÖSCH 63', oppList.get(0).Account.ShippingStreet, 'Should be Automatic filling by default from CF.');
        System.assertEquals('6331', oppList.get(0).Account.ShippingPostalCode, 'Should be Automatic filling by default from CF.');
        System.assertEquals('HÜNENBERG', oppList.get(0).Account.ShippingCity, 'Should be Automatic filling by default from CF.');
        System.assertEquals('CHE110477663', oppList.get(0).Account.Umsatzsteuer_ID__c, 'Should be Automatic filling by default from CF.');
        System.assertEquals('CH17030143616', oppList.get(0).Account.Steuernummer__c, 'Should be value from form.');

        // Contact
        System.assertEquals('BÖSCH 63', oppList.get(0).OpportunityContactRoles.get(0).Contact.MailingStreet, 'Should be Automatic filling by default from CF.');
        System.assertEquals('6331', oppList.get(0).OpportunityContactRoles.get(0).Contact.MailingPostalCode, 'Should be Automatic filling by default from CF.');
        System.assertEquals('HÜNENBERG', oppList.get(0).OpportunityContactRoles.get(0).Contact.MailingCity, 'Should be Automatic filling by default from CF.');
    }


    /*******************************************************************************
    *  Name            : cardConfigurationCHFRMobTest()
    *  Summary         : Test card configuration step    
    *  CreatedDate     : 06/03/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void cardConfigurationCHFRMobTest() {
        ApexPages.currentPage().getparameters().put('country', 'chfr');
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Switzerland-FR';
        Account.ShippingCountry = 'Switzerland-FR';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.E2E_Active_Step__c = 2;
        opportunity.E2E_Active_Substep__c = 'Card configuration';
        opportunity.Product__c = '';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactDE(account.Id);
        contact.MailingCountry = 'Switzerland-FR';
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EFormCHFR');
        update opportunity;

        Credit_Factory_Report__c cfReport = E2ELongFormUtilsTest.createCFReport(opportunity.Id);
        insert cfReport;

        Tankkarten__c card1 = E2ELongFormUtilsTest.createSingleNetworkCardInternational(opportunity.Id);
        insert card1;

        Tankkarten__c card2 = E2ELongFormUtilsTest.createSingleNetworkCardNational(opportunity.Id);
        insert card2;

        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormMobileCHController();
        controller.init();
        controller.editCardConfiguration();
        controller.showSaveAndContinueLaterModal();
        controller.sendEnvelope();
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
        controller.finalCardsMap.get(2).pumpAtPartners = false;
        controller.finalCardsMap.get(2).needOdometerOptions = true;
        controller.finalCardsMap.get(2).selectedTypeOfCar = 'PKW';
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
        controller.finalCardsMap.get(4).categoryCard = 'Shop related products';
        controller.finalCardsMap.get(4).activeCardConfigStepMobile = 'Options';
        controller.finalCardsMap.get(4).pumpOutsideCountry = true;
        controller.finalCardsMap.get(4).pumpAtPartners = false;
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
        controller.goToFeesAndCosts();
        controller.goToSpecialOffers();
        controller.goToOptions();

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
        System.assertEquals('Choosing offer', oppList.get(0).E2E_Active_Substep__c, 'Wrong active sub step.');
        System.assertEquals(3, oppList.get(0).Anzahl_der_Karten__c, 'Invalid number of cards.');
        System.assertEquals(3, oppList.get(0).Total_number_of_vehicles__c, 'Invalid total number of vehicles.');
        System.assertEquals('Barzahlung', oppList.get(0).Derzeitige_Zahlungsmethode__c, 'Wrong payment method.');
        System.assertEquals(3, oppList.get(0).Number_of_cars__c, 'Invalid number of cars.');
        System.assertEquals(0, oppList.get(0).Number_of_trucks__c, 'Invalid number of trucks.');
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
        System.assertEquals('Single Network Card -- National', card2List.get(0).Gewuenschter_Kartentyp__c, 'Wrong type of card.');
        System.assertEquals('Shell Card 2', card2List.get(0).Driver_Name__c, 'Wrong driver name.');
        System.assertEquals(true, card2List.get(0).Kilometerstand_Abfrage__c, 'Expected true.');
        System.assertEquals('TESTCOMPANY', card2List.get(0).Firmenname_auf_der_Karte__c, 'Should be name from account.');
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
        System.assertEquals('TESTCOMPANY', card3List.get(0).Firmenname_auf_der_Karte__c, 'Should be name from account.');
        System.assertEquals('PKW', card3List.get(0).Fahrzeugtyp__c, 'Wrong type of vehicle.');
    }


    /*******************************************************************************
    *  Name            : chooseOfferCHFRMobTest()
    *  Summary         : Test choose offer step    
    *  CreatedDate     : 06/03/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void chooseOfferCHFRMobTest() {
        ApexPages.currentPage().getparameters().put('country', 'chfr');
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Switzerland-FR';
        Account.ShippingCountry = 'Switzerland-FR';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.E2E_Active_Step__c = 2;
        opportunity.E2E_Active_Substep__c = 'Choosing offer';
        opportunity.Product__c = '';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactDE(account.Id);
        contact.MailingCountry = 'Switzerland-FR';
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EFormCHFR');
        update opportunity;

        Credit_Factory_Report__c cfReport = E2ELongFormUtilsTest.createCFReport(opportunity.Id);
        insert cfReport;

        Tankkarten__c card1 = E2ELongFormUtilsTest.createSingleNetworkCardInternational(opportunity.Id);
        insert card1;

        Tankkarten__c card2 = E2ELongFormUtilsTest.createSingleNetworkCardNational(opportunity.Id);
        insert card2;

        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormMobileCHController();
        controller.init();
        controller.editSpecialOffers();
        controller.goToAdditionalParams();

        List<Opportunity> oppList = [
                SELECT Product__c, Home_Station__c, ESI__c, StageName, E2E_Active_Step__c, E2E_Active_SubStep__c 
                FROM Opportunity 
                WHERE Id = :opportunity.Id];

        // System.assertEquals('Swiss Star', oppList.get(0).Product__c, 'Wrong type of product.');
        System.assertEquals('Credit approved', oppList.get(0).StageName, 'Wrong stage name.');
        System.assertEquals(3, oppList.get(0).E2E_Active_Step__c, 'Wrong active step.');
        System.assertEquals('Additional services', oppList.get(0).E2E_Active_SubStep__c, 'Wrong active sub step.');
    }


    /*******************************************************************************
    *  Name            : additionalServicesCHFRMobTest()
    *  Summary         : Additional services test    
    *  CreatedDate     : 28/02/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void additionalServicesCHFRMobTest() {
        ApexPages.currentPage().getparameters().put('country', 'chfr');
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Switzerland-FR';
        Account.ShippingCountry = 'Switzerland-FR';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Pending Credit Check';
        opportunity.Zahlungsart__c = 'Lastschrift';
        opportunity.Security_Amount_To_Pay__c = null;
        opportunity.E2E_Active_Step__c = 3;
        opportunity.E2E_Active_Substep__c = 'Additional services';
        opportunity.Product__c = 'Swiss Star';
        opportunity.E2E_Status__c = 'Abandoned (hard)';
        opportunity.E2E_Sub_Status__c = 'Marketing automation';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactDE(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        Credit_Factory_Report__c cfReport = E2ELongFormUtilsTest.createCFReport(opportunity.Id);
        insert cfReport;

        List<Tankkarten__c> cardsForInsert = new List<Tankkarten__c>();
        Tankkarten__c card3 = E2ELongFormUtilsTest.createSingleNetworkCardInternational(opportunity.Id);
        cardsForInsert.add(card3);

        Tankkarten__c card4 = E2ELongFormUtilsTest.createSingleNetworkCardNational(opportunity.Id);
        cardsForInsert.add(card4);

        insert cardsForInsert;

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EFormCHFR');
        update opportunity;

        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormMobileCHController();
        controller.init();
        controller.sendEnvelope();

        controller.showSendTcDocument();
        controller.sendEnvelope();

        controller.showSendDepositAgreementDocument();
        controller.sendEnvelope();

        controller.showSendHowToPayDocument();
        controller.sendEnvelope();

        controller.stepPagesMap.get('ADDITIONAL').fields.get('CO2 TAKE CARE').elementItemsMap.get('VALUE').Value__c = 'true';
        controller.stepPagesMap.get('ADDITIONAL').fields.get('PAPER INVOICE').elementItemsMap.get('VALUE').Value__c = 'true';
        controller.stepPagesMap.get('ADDITIONAL').elements.get('ADDITIONAL SERVICE #1').get('BEHALF OF COMPANY CHECKBOX VALUE').Value__c = 'true';
        controller.stepPagesMap.get('ADDITIONAL').elements.get('ADDITIONAL SERVICE #1').get('TC AGREEMENT CHECKBOX VALUE').Value__c = 'true';
        controller.goToPaymentOptions();

        List<Opportunity> oppList = [
                SELECT Eco_Fee__c, E2E_Active_Step__c, StageName, E2E_Active_Substep__c, Papierrechnung__c, e_Invoicing_PDF__c, AGB_Datenschutzhinweise_Richtigkeit__c, E2E_payment_status__c
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals(true, oppList.get(0).Eco_Fee__c);
        System.assertEquals('Closed Won', oppList.get(0).StageName);
        System.assertEquals(5, oppList.get(0).E2E_Active_Step__c);
        System.assertEquals('Congratulations', oppList.get(0).E2E_Active_Substep__c);
        System.assertEquals(true, oppList.get(0).Papierrechnung__c);
        System.assertEquals(false, oppList.get(0).e_Invoicing_PDF__c);
        System.assertEquals(true, oppList.get(0).AGB_Datenschutzhinweise_Richtigkeit__c);
        System.assertEquals('NO DEPOSIT', oppList.get(0).E2E_payment_status__c);
    }


    /*******************************************************************************
    *  Name            : paymentOptionsDirectDebitDepositCHFRMobTest()
    *  Summary         : Go to congratulations from payment options step      
    *  CreatedDate     : 06/03/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void paymentOptionsDirectDebitDepositCHFRMobTest() {
        ApexPages.currentPage().getparameters().put('country', 'chfr');
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Switzerland-FR';
        Account.ShippingCountry = 'Switzerland-FR';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Pending Credit Check';
        opportunity.Zahlungsart__c = 'Lastschrift';
        opportunity.E2E_Active_Step__c = 4;
        opportunity.E2E_Active_Substep__c = 'DirectDebitDeposit';
        opportunity.Product__c = 'Swiss Star';
        opportunity.E2E_Status__c = 'Abandoned (hard)';
        opportunity.E2E_Sub_Status__c = 'Marketing automation';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactDE(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        Credit_Factory_Report__c cfReport = E2ELongFormUtilsTest.createCFReport(opportunity.Id);
        insert cfReport;

        List<Tankkarten__c> cardsForInsert = new List<Tankkarten__c>();
        Tankkarten__c card3 = E2ELongFormUtilsTest.createSingleNetworkCardInternational(opportunity.Id);
        cardsForInsert.add(card3);

        Tankkarten__c card4 = E2ELongFormUtilsTest.createSingleNetworkCardNational(opportunity.Id);
        cardsForInsert.add(card4);

        insert cardsForInsert;

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EFormCHFR');
        update opportunity;

        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormMobileCHController();
        controller.init();
        controller.sendEnvelope();
        controller.stepPagesMap.get('PAYMENT OPTIONS').fields.get('PAPER INVOICE').elementItemsMap.get('VALUE').Value__c = 'true';
        controller.stepPagesMap.get('PAYMENT OPTIONS').fields.get('DECISION').elementItemsMap.get('VALUE').Value__c = 'true';
        controller.stepPagesMap.get('PAYMENT OPTIONS').fields.get('DEPOSIT AGREEMENT').elementItemsMap.get('VALUE').Value__c = 'true';
        controller.stepPagesMap.get('PAYMENT OPTIONS').fields.get('ACCEPT TERM CONDITIONS').elementItemsMap.get('VALUE').Value__c = 'true';
        controller.proceedToCheckout();

        List<Opportunity> oppList = [
                SELECT StageName, E2E_Active_Substep__c, E2E_Active_Step__c, E2E_Status__c, E2E_payment_status__c, Papierrechnung__c, AGB_Datenschutzhinweise_Richtigkeit__c, Agree_To_Deposit_Agreement__c
                FROM Opportunity 
                WHERE Id = :opportunity.Id];
        System.assertEquals('Pending Sales – Deposit', oppList.get(0).StageName);
        System.assertEquals('Congratulations', oppList.get(0).E2E_Active_Substep__c);
        System.assertEquals(5, oppList.get(0).E2E_Active_Step__c);
        System.assertEquals('Finished', oppList.get(0).E2E_Status__c);
        System.assertEquals('PAYMENT GATEWAY OFF', oppList.get(0).E2E_payment_status__c);
        System.assertEquals(true, oppList.get(0).Papierrechnung__c);
        System.assertEquals(true, oppList.get(0).AGB_Datenschutzhinweise_Richtigkeit__c);
        System.assertEquals(true, oppList.get(0).Agree_To_Deposit_Agreement__c);
    }


    /*******************************************************************************
    *  Name            : returnToCongratulationCHFRMobTest()
    *  Summary         : Simulate situation when user returned from payment system   
    *  CreatedDate     : 06/03/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void returnToCongratulationCHFRMobTest() {
        ApexPages.currentPage().getparameters().put('country', 'chfr');
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Switzerland-FR';
        Account.ShippingCountry = 'Switzerland-FR';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Pending Credit Check';
        opportunity.Zahlungsart__c = 'Lastschrift';
        opportunity.E2E_Active_Step__c = 5;
        opportunity.E2E_payment_status__c = 'ACCEPT';
        opportunity.E2E_Active_Substep__c = 'DirectDebitDeposit';
        opportunity.Product__c = 'Swiss Star';
        opportunity.E2E_Status__c = 'Abandoned (hard)';
        opportunity.E2E_Sub_Status__c = 'Marketing automation';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactDE(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        Credit_Factory_Report__c cfReport = E2ELongFormUtilsTest.createCFReport(opportunity.Id);
        insert cfReport;

        List<Tankkarten__c> cardsForInsert = new List<Tankkarten__c>();
        Tankkarten__c card3 = E2ELongFormUtilsTest.createSingleNetworkCardInternational(opportunity.Id);
        cardsForInsert.add(card3);

        Tankkarten__c card4 = E2ELongFormUtilsTest.createSingleNetworkCardNational(opportunity.Id);
        cardsForInsert.add(card4);

        insert cardsForInsert;

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EFormCHFR');
        update opportunity;

        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormMobileCHController();
        controller.paymentStatus = 'ACCEPT';
        controller.showDDMandateDocument();
        controller.sendEnvelope();
        controller.showDDMandateModal();
        controller.showDepositAgreementModal();
        controller.showTermsAndConditions();
        controller.closeModal();
        controller.init();

        List<Opportunity> oppList = [
                SELECT StageName, ForecastCategoryName, Closed_Won_by_CF__c, CF_Stage__c, bearbeitet_von__c, Kredit_Entscheidung__c, Billing_Period_by_Sales__c, Last_CF_Errors__c, E2E_Active_Substep__c, E2E_Active_Step__c, E2E_Status__c 
                FROM Opportunity 
                WHERE Id = :opportunity.Id];

        System.assertEquals('Pending Sales – Deposit', oppList.get(0).StageName);
        System.assertEquals('Closed', oppList.get(0).ForecastCategoryName);
        System.assertEquals(true, oppList.get(0).Closed_Won_by_CF__c);
        System.assertEquals('Auto CW', oppList.get(0).CF_Stage__c);
        System.assertEquals(null, oppList.get(0).bearbeitet_von__c);
        System.assertEquals('Genehmigt, Sicherheit geliefert', oppList.get(0).Kredit_Entscheidung__c);
        System.assertEquals(true, oppList.get(0).Billing_Period_by_Sales__c);
        System.assertEquals(null, oppList.get(0).Last_CF_Errors__c);
        System.assertEquals('Congratulations', oppList.get(0).E2E_Active_Substep__c);
        System.assertEquals(5, oppList.get(0).E2E_Active_Step__c);
        System.assertEquals('Finished', oppList.get(0).E2E_Status__c);
    }
}