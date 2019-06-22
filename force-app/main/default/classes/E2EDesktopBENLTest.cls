@isTest
private class E2EDesktopBENLTest {
    public static LongFormDesktopBENLController controller;

    /*******************************************************************************
    *  Name            : createLongFormData()
    *  Summary         : Creating all LongForm data    
    *  CreatedDate     : 03/09/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @testSetup
    static void createLongFormData() {
        E2ELongFormUtilsTest.createInternationalPartnersPrice('Belgium-NL', 'Inbound');
        E2ELongFormUtilsTest.createNationalNotPartnersPrice('Belgium-NL', 'Inbound');
        E2ELongFormUtilsTest.createInternationalNotPartnersPrice('Belgium-NL', 'Inbound');
        E2ELongFormUtilsTest.createNationalPartnersPrice('Belgium-NL', 'Inbound');
        E2ELongFormUtilsTest.createInternationalPartnersDiffPrice('Belgium-NL', 'Inbound');
        E2ELongFormUtilsTest.createNationalNotPartnersDiffPrice('Belgium-NL', 'Inbound');
        E2ELongFormUtilsTest.createInternationalNotPartnersDiffPrice('Belgium-NL', 'Inbound');
        E2ELongFormUtilsTest.createNationalPartnersDiffPrice('Belgium-NL', 'Inbound');
        E2ELongFormUtilsTest.createLongForm('Belgium-NL');
        E2ELongFormUtilsTest.createLongFormMenu();
        E2ELongFormUtilsTest.createMenuItemForStep1('Desktop');
        E2ELongFormUtilsTest.createMenuItemForStep2('Desktop');
        E2ELongFormUtilsTest.createMenuItemForStep3('Desktop');
        E2ELongFormUtilsTest.createMenuItemForStep4('Desktop');
        E2ELongFormUtilsTest.createHeader('Desktop');
        E2ELongFormUtilsTest.createContactDeatilsData('Desktop');
        E2ELongFormUtilsTest.createCustomSettings('Belgium-NL', 'E2EFormBENL', 'Creditsafe', '00520000005vRqs');
        E2ELongFormUtilsTest.createOrderDetailsBlock('Desktop');
        E2ELongFormUtilsTest.createFooter('Desktop');
        E2ELongFormUtilsTest.createCreditScoreAnotherTaxID('Desktop');
        E2ELongFormUtilsTest.createCreditScoreSearchCompany('Desktop');
        E2ELongFormUtilsTest.createCreditScoreInputVatId('Desktop');
        E2ELongFormUtilsTest.createCreditScoreTotalConsumption('Desktop');
        E2ELongFormUtilsTest.createCreditScoringResult('Desktop');
        E2ELongFormUtilsTest.createCardConfiguration('Desktop');
        E2ELongFormUtilsTest.createCardConfigurationSpecialOffers('Desktop', 'HOME 1 OFFER DESKTOP CONTENT', 'HOME 1 OFFER DESKTOP CONTENT', 'Belgium-NL', 'Inbound', 'Home Station offer (v.1)', 'Home Station offer (v.1)');
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

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditsafeAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditsafeOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.doCreateCreditSystemSalesProfile();
        insert creditSystemSalesProfile;
    }


    /*******************************************************************************
    *  Name            : findDupLeadWithSameDataBENLTest()
    *  Summary         : Verify that when Contact #2 and Lead #1 has the same First Name + Last Name + Email + Phone domain then Lead is disqualified 
    *  ExpectedResult  : E2E Contact #2 was created. Lead #1 Status = Disqualified Quali Status = Switched to E2E Notification was sent to the Lead Owner
    *  CreatedDate     : 03/09/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void findDupLeadWithSameDataBENLTest() {
        User e2eUser = E2ELongFormUtilsTest.createE2EDEUser();
        Database.insert(e2eUser);
        
        System.runAs(e2eUser) {
            Lead lead = E2ELongFormUtilsTest.createLeadForDuplicateDE();
            lead.Country = 'Belgium-NL';
            insert lead;

            controller = new LongFormDesktopBENLController();
            controller.init();
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHN';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SMITH';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+3212345678';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'test@fleetcor.com';
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
    *  Name            : insertDupConSameDataClosedLostBENLTest()
    *  Summary         : Verify that two Contacts were merged when First Name + Last Name + Email + Phone are the same and Contact #1 has E2E Opportunity #1 in stage Closed Lost    
    *  ExpectedResult  : Two contacts were merged. E2E Account #2, E2E Opportuinty #2 were created. Direct Connections were changed to E2E records
    *  CreatedDate     : 03/09/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void insertDupConSameDataClosedLostBENLTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Belgium-NL';
        Account.ShippingCountry = 'Belgium-NL';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Closed Lost';
        opportunity.Product__c = '';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        contact.MailingCountry = 'Belgium-NL';
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        controller = new LongFormDesktopBENLController();
        controller.activeStep = 0;
        controller.init();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHN';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SMITH';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+3212345678';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'test@fleetcor.com';
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
        System.assertEquals('+3212345678', contactList.get(0).Phone, 'Expected Phone from form.');
        System.assertEquals('test@fleetcor.com', contactList.get(0).Email, 'Expected Email from form.');
    }


    /*******************************************************************************
    *  Name            : insertDupConSameDataWithE2EOppBENLTest()
    *  Summary         : Verify that two Contacts were merged when First Name + Last Name + Email + Phone are the same 
                         and Contact #1 has E2E Opportunity #1 NOT in stage Closed Lost / Closed WON / Pending Sales - Deposit
    *  ExpectedResult  : Two contacts were merged. Form of the business is updated in Opportunity #1 User is redirected to last E2E step of the Opportunity #1
    *  CreatedDate     : 03/09/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void insertDupConSameDataWithE2EOppBENLTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Belgium-NL';
        Account.ShippingCountry = 'Belgium-NL';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Prospecting';
        opportunity.E2E_Active_Step__c = 1;
        opportunity.E2E_Active_Substep__c = 'Search company';
        opportunity.Product__c = '';
        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EFormBENL');
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        contact.MailingCountry = 'Belgium-NL';
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        controller = new LongFormDesktopBENLController();
        controller.activeStep = 0;
        controller.init();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHN';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SMITH';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+3212345678';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'test@fleetcor.com';
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
        System.assertEquals('+3212345678', contactList.get(0).Phone, 'Expected Phone from form.');
        System.assertEquals('test@fleetcor.com', contactList.get(0).Email, 'Expected Email from form.');
    }


    /*******************************************************************************
    *  Name            : updateDupConSameDataClosedLostBENLTest()
    *  Summary         : Verify that two Contacts were merged when First Name + Last Name + Email + Phone are the same and Contact #1 has E2E Opportunity #1 in stage Closed Lost
    *  ExpectedResult  : E2E Opportunity #2 Stage = Closed Lost. Reason = Duplicate. E2E Account #2, E2E Contact #2 were NOT deleted.
                         Contacts were merged. New E2E Account #3, New E2E Opportunity #3 were created. Direct Connections were changed to E2E records
    *  CreatedDate     : 03/09/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void updateDupConSameDataClosedLostBENLTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Belgium-NL';
        Account.ShippingCountry = 'Belgium-NL';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Closed Lost';
        opportunity.Product__c = '';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        contact.MailingCountry = 'Belgium-NL';
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        controller = new LongFormDesktopBENLController();
        controller.activeStep = 0;
        controller.init();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JohnAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SmithAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+3212345678';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'testAA@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();
        // back to update data
        controller.goToContactDetails();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHN';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SMITH';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+3212345678';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'test@fleetcor.com';
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
        System.assertEquals('+3212345678', contactList.get(0).Phone, 'Expected Phone from form.');
        System.assertEquals('test@fleetcor.com', contactList.get(0).Email, 'Expected Email from form.');
    }


    /*******************************************************************************
    *  Name            : updateDupConSameDataProspectingBENLTest()
    *  Summary         : Verify that two Contacts were merged when First Name + Last Name + Email + Phone are the same and 
                         Contact #1 has E2E Opportunity #1 NOT in stage Closed Lost / Closed WON / Pending Sales - Deposit
    *  ExpectedResult  : E2E Opportunity #2 Stage = Closed Lost. Reason = Duplicate. E2E Account #2, E2E Contact #2 were NOT deleted. Contacts were merged. 
                         User is redirected to the last E2E step of the Opportunity #1
    *  CreatedDate     : 03/09/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void updateDupConSameDataProspectingBENLTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Belgium-NL';
        Account.ShippingCountry = 'Belgium-NL';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Prospecting';
        opportunity.Product__c = '';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        contact.MailingCountry = 'Belgium-NL';
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        controller = new LongFormDesktopBENLController();
        controller.activeStep = 0;
        controller.init();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JohnAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SmithAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+3211111111';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'testAA@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();
        // back to update data
        controller.goToContactDetails();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHN';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SMITH';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+3212345678';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'test@fleetcor.com';
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
        System.assertEquals('+3212345678', contactList.get(0).Phone, 'Expected Phone from form.');
        System.assertEquals('test@fleetcor.com', contactList.get(0).Email, 'Expected Email from form.');
    }


    /*******************************************************************************
    *  Name            : contactDetailsBENLTest()
    *  Summary         : Verify all fields on contact details step
    *  CreatedDate     : 03/09/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void contactDetailsBENLTest() {
        controller = new LongFormDesktopBENLController();
        controller.init();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Herr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Test First Name';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Test Last Name';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+3212345678';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'test@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();

        List<Contact> contactList = [
                SELECT Salutation, FirstName, LastName, Phone, Email, Authorised_signatory__c, LeadSource, MailingCountry, RecordType.Name, E2E__c,
                    (SELECT Account.Name, Account.E2E__c, Account.RecordType.Name, Account.Type, Account.AccountSource, Account.BillingCountry, Account.ShippingCountry 
                    FROM AccountContactRelations), 
                    (SELECT Opportunity.Name, Opportunity.E2E__c, Opportunity.StageName, Opportunity.Product__c, Opportunity.CloseDate, Opportunity.Language_preference__c, 
                        Opportunity.Primary_Contact_Phone__c, Opportunity.Agree_to_Privacy_Policy__c, Opportunity.Date_for_Agree_to_Privacy_Policy__c, 
                        Opportunity.LeadSource, Opportunity.Sec_Channel__c, Opportunity.Channel__c, Opportunity.CurrencyIsoCode, Opportunity.Type, Opportunity.Eco_Fee__c, 
                        Opportunity.Visitor_ID__c, Opportunity.AGB_Datenschutzhinweise_Richtigkeit__c, Opportunity.E2E_Form_of_Business__c, Opportunity.E2E_Active_Step__c, 
                        Opportunity.E2E_Active_Substep__c 
                    FROM OpportunityContactRoles)
                FROM Contact];

        // contact
        System.assertEquals(1, contactList.size(), 'One Contact is expected.');
        System.assertEquals('Herr', contactList.get(0).Salutation, 'Should be value from form.');
        System.assertEquals('TEST FIRST NAME', contactList.get(0).FirstName, 'Should be value from form.');
        System.assertEquals('TEST LAST NAME', contactList.get(0).LastName, 'Should be value from form.');
        System.assertEquals('+3212345678', contactList.get(0).Phone, 'Should be value from form.');
        System.assertEquals('test@fleetcor.com', contactList.get(0).Email, 'Should be value from form.');
        System.assertEquals(false, contactList.get(0).Authorised_signatory__c, 'Should be Automatic filling by default.');
        System.assertEquals(true, contactList.get(0).E2E__c, 'Should be Automatic filling by default.');
        System.assertEquals('Belgium-NL', contactList.get(0).MailingCountry, 'Should be Automatic filling by default.');
        System.assertEquals('Contact layout', contactList.get(0).RecordType.Name, 'Should be Automatic filling by default.');

        // account
        System.assertEquals(1, contactList.get(0).AccountContactRelations.size(), 'One Account is expected.');
        System.assertEquals('LONGFORM: TEST FIRST NAME TEST LAST NAME', contactList.get(0).AccountContactRelations.get(0).Account.Name, 'Should be value from form.');
        System.assertEquals('Endkunde', contactList.get(0).AccountContactRelations.get(0).Account.RecordType.Name, 'Should be Automatic filling by default.');
        System.assertEquals('Customer', contactList.get(0).AccountContactRelations.get(0).Account.Type, 'Should be Automatic filling by default.');
        System.assertEquals(true, contactList.get(0).AccountContactRelations.get(0).Account.E2E__c, 'Should be Automatic filling by default.');
        System.assertEquals('Belgium-NL', contactList.get(0).AccountContactRelations.get(0).Account.BillingCountry, 'Should be Automatic filling by default.');
        System.assertEquals('Belgium-NL', contactList.get(0).AccountContactRelations.get(0).Account.ShippingCountry, 'Should be Automatic filling by default.');

        // opportunity
        System.assertEquals(1, contactList.get(0).OpportunityContactRoles.size(), 'One Opportunity is expected.');
        System.assertEquals('LONGFORM: TEST FIRST NAME TEST LAST NAME', contactList.get(0).OpportunityContactRoles.get(0).Opportunity.Name, 'Should be value from form.');
        System.assertEquals('Prospecting', contactList.get(0).OpportunityContactRoles.get(0).Opportunity.StageName, 'Should be Automatic filling by default.');
        System.assertEquals(null, contactList.get(0).OpportunityContactRoles.get(0).Opportunity.Product__c, 'Should be Automatic filling by default.');
        System.assertEquals('Dutch', contactList.get(0).OpportunityContactRoles.get(0).Opportunity.Language_preference__c, 'Should be Automatic filling by default.');
        System.assertEquals('+3212345678', contactList.get(0).OpportunityContactRoles.get(0).Opportunity.Primary_Contact_Phone__c, 'Should be value from form.');
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
    *  Name            : searchCompanyBENLTest()
    *  Summary         : Testing flow from Search Company with Mock
    *  CreatedDate     : 03/09/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void searchCompanyBENLTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Belgium-NL';
        Account.ShippingCountry = 'Belgium-NL';
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
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EFormBENL');
        update opportunity;

        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormDesktopBENLController();
        controller.init();
        
        controller.stepPagesMap.get('CREDIT SCORE. SEARCH COMPANY').fields.get('COMPANY NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'TEST';
        controller.stepPagesMap.get('CREDIT SCORE. SEARCH COMPANY').fields.get('TAX ID').elementItemsMap.get('DEFAULT VALUE').Value__c = '123456789';
        controller.doSaveCompanyDetailsData();

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new E2ELongFormBECreditFactoryMock());
            controller.doSearchCompany();
        Test.stopTest();

        controller.editContactDetails();

        List<Account> accountList = [SELECT Name, Steuernummer__c FROM Account];
        System.assertEquals('TEST', accountList.get(0).Name);
        System.assertEquals('123456789', accountList.get(0).Steuernummer__c);
    }


    /*******************************************************************************
    *  Name            : vatIdBENLTest()
    *  Summary         : Test vat id    
    *  CreatedDate     : 16/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void vatIdBENLTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Belgium-NL';
        Account.ShippingCountry = 'Belgium-NL';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Prospecting';
        opportunity.E2E_Active_Step__c = 1;
        opportunity.E2E_Active_Substep__c = 'Enter VAT Number';
        opportunity.Product__c = '';
        opportunity.Zahlungsart__c = '';
        opportunity.Rechnungsperiode__c = '';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactDE(account.Id);
        contact.MailingCountry = 'Belgium-NL';
        contact.Salutation = 'Mr';
        contact.FirstName = 'Andrew';
        contact.LastName = 'Richard Hackett';
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EFormBENL');
        update opportunity;

        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormDesktopBENLController();
        controller.init();
        controller.backToCreditScoring(); // back button for test coverage
        Test.startTest();
            Test.setMock(WebServiceMock.class, new EcEuropaEuMock());
            controller.stepPagesMap.get('CREDIT SCORE. INPUT VAT ID').fields.get('VAT NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = 'BE0708562630'; // valid vat number
            controller.updateVatNumber();
        Test.stopTest();

        List<Opportunity> oppList = [SELECT E2E_Active_Step__c, E2E_Active_Substep__c, Account.Umsatzsteuer_ID__c, Account.No_Vat__c FROM Opportunity];
        System.assertEquals(1, oppList.get(0).E2E_Active_Step__c);
        System.assertEquals('Set total consumption', oppList.get(0).E2E_Active_Substep__c);
        System.assertEquals('BE0708562630', oppList.get(0).Account.Umsatzsteuer_ID__c);
        System.assertEquals(false, oppList.get(0).Account.No_Vat__c);
    }


    /*******************************************************************************
    *  Name            : verifyAllFieldsBENLTest()
    *  Summary         : Verify that Credit Report record was created and updated with info    
    *  CreatedDate     : 03/09/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void verifyAllFieldsBENLTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Belgium-NL';
        Account.ShippingCountry = 'Belgium-NL';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Prospecting';
        opportunity.E2E_Active_Step__c = 1;
        opportunity.E2E_Active_Substep__c = 'Calculating credit score';
        opportunity.Zahlungsart__c = '';
        opportunity.Rechnungsperiode__c = '';
        opportunity.Product__c = '';
        opportunity.E2E_Status__c = 'Abandoned (hard)';
        opportunity.E2E_Sub_Status__c = 'Marketing automation';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactDE(account.Id);
        contact.FirstName = 'Roman';
        contact.LastName = 'Aydogdu';
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        controller = new LongFormDesktopBENLController();
        controller.init();
        controller.activeStep = 1;
        controller.initPageElements();
        controller.initSObjects(opportunity.Id);
        controller.selectedCompany = new CreditCompany();
        controller.selectedCompany.identificationnumber = '03453452015622';
        controller.deleteReportsForPreviousCompany();

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new E2ELongFormBECreditFactoryMock());
            controller.goToSetTotalConsumption();
        Test.stopTest();

        controller.stepPagesMap.get('CREDIT SCORE. TOTAL CONSUMPTION').fields.get('TOTAL CONSUMPTION').elementItemsMap.get('DEFAULT VALUE').Value__c = '1000';
        controller.doCalculateCreditScoring();

        // back button
        controller.backToSetTotalConsumption();

        List<Opportunity> oppList = [
                SELECT Name, StageName, CF_Stage__c, Credit_System_Rating__c, Umsatz__c, Credit_System_Number__c, E2E_Active_Step__c, E2E_Last_Activity__c, Visitor_ID__c, E2E_Encoded_URL__c, 
                    Account.Name, Account.BillingStreet, Account.BillingPostalCode, Account.BillingCity, Account.ShippingCountry, Account.ShippingStreet, Account.ShippingPostalCode, 
                    Account.ShippingCity, Account.Umsatzsteuer_ID__c, Account.Steuernummer__c, E2E_Active_Substep__c, 
                    Gasoline_consumption_l_month__c, Diesel_consumption_l_month__c, Total_consumption_l_month__c, 
                    (SELECT Contact.MailingStreet, Contact.MailingPostalCode, Contact.MailingCity FROM OpportunityContactRoles)
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        // Opportunity
        System.assertEquals('TEST SA', oppList.get(0).Name, 'Should be Automatic filling by default from CF.');
        System.assertEquals('Prospecting', oppList.get(0).StageName, 'Should be Automatic filling by default.');
        System.assertEquals(0, oppList.get(0).Gasoline_consumption_l_month__c, 'Always should be 0.');
        System.assertEquals(1000, oppList.get(0).Diesel_consumption_l_month__c, 'Shoul be the same as total consumption.');
        System.assertEquals(1000, oppList.get(0).Total_consumption_l_month__c, 'Wrong total consumption.');
        System.assertEquals('Calculating credit score', oppList.get(0).E2E_Active_Substep__c, 'Wrong active substep.');
        System.assertEquals(1, oppList.get(0).E2E_Active_Step__c, 'Should be Automatic filling by default.');

        // Account 
        System.assertEquals('TEST SA', oppList.get(0).Account.Name, 'Should be Automatic filling by default from CF.');
        System.assertEquals('RUE LOUIS RENARD 9B ', oppList.get(0).Account.BillingStreet, 'Should be Automatic filling by default from CF.');
        System.assertEquals('4367', oppList.get(0).Account.BillingPostalCode, 'Should be Automatic filling by default from CF.');
        System.assertEquals('CRISNÉE', oppList.get(0).Account.BillingCity, 'Should be Automatic filling by default from CF.');
        System.assertEquals('Belgium-NL', oppList.get(0).Account.ShippingCountry, 'Should be Automatic filling by default from CF.');
        System.assertEquals('RUE LOUIS RENARD 9B ', oppList.get(0).Account.ShippingStreet, 'Should be Automatic filling by default from CF.');
        System.assertEquals('4367', oppList.get(0).Account.ShippingPostalCode, 'Should be Automatic filling by default from CF.');
        System.assertEquals('CRISNÉE', oppList.get(0).Account.ShippingCity, 'Should be Automatic filling by default from CF.');
        // System.assertEquals('BE.0428.089.605', oppList.get(0).Account.Umsatzsteuer_ID__c, 'Should be Automatic filling by default from CF.');
        System.assertEquals('428089605', oppList.get(0).Account.Steuernummer__c, 'Should be value from form.');

        // Contact
        System.assertEquals('RUE LOUIS RENARD 9B ', oppList.get(0).OpportunityContactRoles.get(0).Contact.MailingStreet, 'Should be Automatic filling by default from CF.');
        System.assertEquals('4367', oppList.get(0).OpportunityContactRoles.get(0).Contact.MailingPostalCode, 'Should be Automatic filling by default from CF.');
        System.assertEquals('CRISNÉE', oppList.get(0).OpportunityContactRoles.get(0).Contact.MailingCity, 'Should be Automatic filling by default from CF.');
    }


    /*******************************************************************************
    *  Name            : searchDuplicateCase5BENLTest()
    *  Summary         : Search duplicate account case #5   
    *  CreatedDate     : 03/09/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void searchDuplicateCase5BENLTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Belgium-NL';
        Account.ShippingCountry = 'Belgium-NL';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Prospecting';
        opportunity.E2E_Active_Step__c = 1;
        opportunity.E2E_Active_Substep__c = 'Calculating credit score';
        opportunity.Zahlungsart__c = '';
        opportunity.Rechnungsperiode__c = '';
        opportunity.Product__c = '';
        opportunity.E2E_Status__c = 'Abandoned (hard)';
        opportunity.E2E_Sub_Status__c = 'Marketing automation';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactDE(account.Id);
        contact.FirstName = 'Roman';
        contact.LastName = 'Aydogdu';
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        // duplicate account
        Account account2 = E2ELongFormUtilsTest.createAccountDE();
        account2.BillingCountry = 'Belgium-NL';
        account2.ShippingCountry = 'Belgium-NL';
        account2.Steuernummer__c = '428089605';
        insert account2;

        Opportunity opportunity2 = E2ELongFormUtilsTest.createOpportunityDE(account2.Id);
        opportunity2.StageName = 'Prospecting';
        opportunity2.E2E_Active_Step__c = 1;
        opportunity2.E2E_Active_Substep__c = 'Calculating credit score';
        opportunity2.Zahlungsart__c = '';
        opportunity2.Rechnungsperiode__c = '';
        opportunity2.Product__c = '';
        insert opportunity2;

        Contact contact2 = E2ELongFormUtilsTest.createContactDE(account2.Id);
        insert contact2;

        OpportunityContactRole oppContactRole2 = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity2.Id, contact2.Id);
        insert oppContactRole2;

        controller = new LongFormDesktopBENLController();
        controller.init();
        controller.activeStep = 1;
        controller.initPageElements();
        controller.initSObjects(opportunity.Id);
        controller.selectedCompany = new CreditCompany();
        controller.selectedCompany.identificationnumber = '03453452015622';
        controller.deleteReportsForPreviousCompany();

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new E2ELongFormBECreditFactoryMock());
            controller.goToSetTotalConsumption();
        Test.stopTest();

        controller.stepPagesMap.get('CREDIT SCORE. TOTAL CONSUMPTION').fields.get('TOTAL CONSUMPTION').elementItemsMap.get('DEFAULT VALUE').Value__c = '1000';
        controller.doCalculateCreditScoring();

        List<Opportunity> oppList = [SELECT StageName, Gruende_verloren__c, E2E_Status__c FROM Opportunity WHERE Id = :opportunity2.Id];
        System.assertEquals('Closed Lost', oppList.get(0).StageName);
        System.assertEquals('Switched to E2E', oppList.get(0).Gruende_verloren__c);
        System.assertEquals('Finished', oppList.get(0).E2E_Status__c);
    }


    /*******************************************************************************
    *  Name            : searchDuplicateCase1BENLTest()
    *  Summary         : Search duplicate account case #1   
    *  CreatedDate     : 03/09/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void searchDuplicateCase1BENLTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Belgium-NL';
        Account.ShippingCountry = 'Belgium-NL';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Prospecting';
        opportunity.E2E_Active_Step__c = 1;
        opportunity.E2E_Active_Substep__c = 'Calculating credit score';
        opportunity.Zahlungsart__c = '';
        opportunity.Rechnungsperiode__c = '';
        opportunity.Product__c = '';
        opportunity.E2E_Status__c = 'Abandoned (hard)';
        opportunity.E2E_Sub_Status__c = 'Marketing automation';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactDE(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        // duplicate account
        Account account2 = E2ELongFormUtilsTest.createAccountDE();
        account2.BillingCountry = 'Belgium-NL';
        account2.ShippingCountry = 'Belgium-NL';
        account2.Steuernummer__c = '428089605';
        insert account2;

        Opportunity opportunity2 = E2ELongFormUtilsTest.createOpportunityDE(account2.Id);
        opportunity2.StageName = 'Closed Won';
        opportunity2.E2E_Active_Step__c = 1;
        opportunity2.E2E_Active_Substep__c = 'Calculating credit score';
        opportunity2.Zahlungsart__c = '';
        opportunity2.Rechnungsperiode__c = '';
        opportunity2.Product__c = '';
        insert opportunity2;

        Contact contact2 = E2ELongFormUtilsTest.createContactDE(account2.Id);
        insert contact2;

        OpportunityContactRole oppContactRole2 = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity2.Id, contact2.Id);
        insert oppContactRole2;

        controller = new LongFormDesktopBENLController();
        controller.init();
        controller.activeStep = 1;
        controller.initPageElements();
        controller.initSObjects(opportunity.Id);
        controller.selectedCompany = new CreditCompany();
        controller.selectedCompany.identificationnumber = '03453452015622';
        controller.deleteReportsForPreviousCompany();

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new E2ELongFormBECreditFactoryMock());
            controller.goToSetTotalConsumption();
        Test.stopTest();

        List<Opportunity> oppList = [SELECT Owner.Name FROM Opportunity WHERE Id = :opportunity.Id];
        System.assertEquals('Rutger Geerts', oppList.get(0).Owner.Name);
    }


    /*******************************************************************************
    *  Name            : searchDuplicateCase2BENLTest()
    *  Summary         : Search duplicate account case #2   
    *  CreatedDate     : 03/09/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void searchDuplicateCase2BENLTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Belgium-NL';
        Account.ShippingCountry = 'Belgium-NL';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Prospecting';
        opportunity.E2E_Active_Step__c = 1;
        opportunity.E2E_Active_Substep__c = 'Calculating credit score';
        opportunity.Zahlungsart__c = '';
        opportunity.Rechnungsperiode__c = '';
        opportunity.Product__c = '';
        opportunity.E2E_Status__c = 'Abandoned (hard)';
        opportunity.E2E_Sub_Status__c = 'Marketing automation';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactDE(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        // duplicate account
        Account account2 = E2ELongFormUtilsTest.createAccountDE();
        account2.BillingCountry = 'Belgium-NL';
        account2.ShippingCountry = 'Belgium-NL';
        account2.Steuernummer__c = '428089605';
        insert account2;

        Opportunity opportunity2 = E2ELongFormUtilsTest.createOpportunityDE(account2.Id);
        opportunity2.StageName = 'CreditCheck';
        opportunity2.E2E_Active_Step__c = 1;
        opportunity2.E2E_Active_Substep__c = 'Calculating credit score';
        opportunity2.Zahlungsart__c = '';
        opportunity2.Rechnungsperiode__c = '';
        opportunity2.Product__c = '';
        insert opportunity2;

        Contact contact2 = E2ELongFormUtilsTest.createContactDE(account2.Id);
        insert contact2;

        OpportunityContactRole oppContactRole2 = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity2.Id, contact2.Id);
        insert oppContactRole2;

        controller = new LongFormDesktopBENLController();
        controller.init();
        controller.activeStep = 1;
        controller.initPageElements();
        controller.initSObjects(opportunity.Id);
        controller.selectedCompany = new CreditCompany();
        controller.selectedCompany.identificationnumber = '03453452015622';
        controller.deleteReportsForPreviousCompany();

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new E2ELongFormBECreditFactoryMock());
            controller.goToSetTotalConsumption();
        Test.stopTest();

        controller.stepPagesMap.get('CREDIT SCORE. TOTAL CONSUMPTION').fields.get('TOTAL CONSUMPTION').elementItemsMap.get('DEFAULT VALUE').Value__c = '1000';
        controller.doCalculateCreditScoring();

        List<Opportunity> oppList = [SELECT StageName, Gruende_verloren__c FROM Opportunity WHERE Id = :opportunity.Id];
        System.assertEquals('Closed Lost', oppList.get(0).StageName);
        System.assertEquals('Duplicate', oppList.get(0).Gruende_verloren__c);
    }


    /*******************************************************************************
    *  Name            : searchDuplicateCase3BENLTest()
    *  Summary         : Search duplicate account case #3   
    *  CreatedDate     : 03/09/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void searchDuplicateCase3BENLTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Belgium-NL';
        Account.ShippingCountry = 'Belgium-NL';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Prospecting';
        opportunity.E2E_Active_Step__c = 1;
        opportunity.E2E_Active_Substep__c = 'Calculating credit score';
        opportunity.Zahlungsart__c = '';
        opportunity.Rechnungsperiode__c = '';
        opportunity.Product__c = '';
        opportunity.E2E_Status__c = 'Abandoned (hard)';
        opportunity.E2E_Sub_Status__c = 'Marketing automation';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactDE(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        // duplicate account
        Account account2 = E2ELongFormUtilsTest.createAccountDE();
        account2.BillingCountry = 'Belgium-NL';
        account2.ShippingCountry = 'Belgium-NL';
        account2.Steuernummer__c = '428089605';
        insert account2;

        Opportunity opportunity2 = E2ELongFormUtilsTest.createOpportunityDE(account2.Id);
        opportunity2.StageName = 'CreditCheck abgelehnt';
        opportunity2.CloseDate = Date.today().addDays(-1000);
        opportunity2.E2E_Active_Step__c = 1;
        opportunity2.E2E_Active_Substep__c = 'Calculating credit score';
        opportunity2.Zahlungsart__c = '';
        opportunity2.Rechnungsperiode__c = '';
        opportunity2.Product__c = '';
        insert opportunity2;

        Contact contact2 = E2ELongFormUtilsTest.createContactDE(account2.Id);
        insert contact2;

        OpportunityContactRole oppContactRole2 = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity2.Id, contact2.Id);
        insert oppContactRole2;

        controller = new LongFormDesktopBENLController();
        controller.init();
        controller.activeStep = 1;
        controller.initPageElements();
        controller.initSObjects(opportunity.Id);
        controller.selectedCompany = new CreditCompany();
        controller.selectedCompany.identificationnumber = '03453452015622';
        controller.deleteReportsForPreviousCompany();

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new E2ELongFormBECreditFactoryMock());
            controller.goToSetTotalConsumption();
        Test.stopTest();

        controller.stepPagesMap.get('CREDIT SCORE. TOTAL CONSUMPTION').fields.get('TOTAL CONSUMPTION').elementItemsMap.get('DEFAULT VALUE').Value__c = '1000';
        controller.doCalculateCreditScoring();

        List<Opportunity> oppList = [SELECT StageName, Gruende_verloren__c, E2E_Status__c FROM Opportunity WHERE Id = :opportunity2.Id];
        System.assertEquals('Closed Lost', oppList.get(0).StageName);
        System.assertEquals('Switched to E2E', oppList.get(0).Gruende_verloren__c);
        System.assertEquals('Finished', oppList.get(0).E2E_Status__c);
    }


    /*******************************************************************************
    *  Name            : goToCardConfigNonDepositBENLTest()
    *  Summary         : Verify all fields when you go from 1 step to 2 step 
    *  CreatedDate     : 03/09/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void goToCardConfigNonDepositBENLTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Belgium-NL';
        Account.ShippingCountry = 'Belgium-NL';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Prospecting';
        opportunity.E2E_Active_Step__c = 1;
        opportunity.E2E_Active_Substep__c = 'Calculating credit score';
        opportunity.Zahlungsart__c = '';
        opportunity.Rechnungsperiode__c = '';
        opportunity.Product__c = '';
        opportunity.E2E_Status__c = 'Abandoned (hard)';
        opportunity.E2E_Sub_Status__c = 'Marketing automation';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactDE(account.Id);
        contact.FirstName = 'Roman';
        contact.LastName = 'Aydogdu';
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        controller = new LongFormDesktopBENLController();
        controller.init();
        controller.activeStep = 1;
        controller.initPageElements();
        controller.initSObjects(opportunity.Id);
        controller.selectedCompany = new CreditCompany();
        controller.selectedCompany.identificationnumber = '03453452015622';
        controller.deleteReportsForPreviousCompany();

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new E2ELongFormBECreditFactoryMock());
            controller.goToSetTotalConsumption();
        Test.stopTest();

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
        // // calculacte Lastschrift Monthly credit score data
        // controller.stepPagesMap.get('CREDIT SCORE. SCORING RESULT').fields.get('PAYMENT METHOD').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Lastschrift';
        // controller.defaultBillingPeriod = 30;
        // controller.changeBillingPeriod();
        // controller.stepPagesMap.get('CREDIT SCORE. SCORING RESULT').fields.get('BILLING PERIOD').elementItemsMap.get('MONTHLY BUTTON NAME').Value__c = '30';
        // controller.returnFinalCreditScoreData();
        // controller.doRecalculateDeposit();
        controller.goToCardsConfig();

        List<Opportunity> oppList = [
                SELECT StageName, Zahlungsart__c, Rechnungsperiode__c, CF_Credit_Limit__c, E2E_Active_Step__c, E2E_Active_Substep__c 
                FROM Opportunity 
                WHERE Id = :opportunity.Id];

        System.assertEquals('Credit approved', oppList.get(0).StageName, 'Wrong stage name.');
        System.assertEquals('Lastschrift', oppList.get(0).Zahlungsart__c, 'Wrong payment method.');
        System.assertEquals('15', oppList.get(0).Rechnungsperiode__c, 'Wrong billing period.');
        System.assertEquals(2, oppList.get(0).E2E_Active_Step__c, 'Wrong active step.');
        System.assertEquals('Card configuration', oppList.get(0).E2E_Active_Substep__c, 'Wrong active sub step.');
    }


    /*******************************************************************************
    *  Name            : cardConfigurationWithThreeCardsBENLTest()
    *  Summary         : Testing card configuration step, add 3 diff card   
    *  CreatedDate     : 03/09/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void cardConfigurationWithThreeCardsBENLTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Belgium-NL';
        Account.ShippingCountry = 'Belgium-NL';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.E2E_Active_Step__c = 2;
        opportunity.E2E_Active_Substep__c = 'Card configuration';
        opportunity.Product__c = '';
        opportunity.E2E_Status__c = 'Abandoned (hard)';
        opportunity.E2E_Sub_Status__c = 'Marketing automation';
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

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EFormBENL');
        update opportunity;

        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormDesktopBENLController();
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
    *  Name            : returnCardConfigurationWithThreeCardsBENLTest()
    *  Summary         : Testing card configuration step, add 3 diff card   
    *  CreatedDate     : 03/09/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void returnCardConfigurationWithThreeCardsBENLTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Belgium-NL';
        Account.ShippingCountry = 'Belgium-NL';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.E2E_Active_Step__c = 2;
        opportunity.E2E_Active_Substep__c = 'Card configuration';
        opportunity.Product__c = 'Home Station offer (v.1)';
        opportunity.ESI__c = 'test';
        opportunity.E2E_Status__c = 'Abandoned (hard)';
        opportunity.E2E_Sub_Status__c = 'Marketing automation';
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

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EFormBENL');
        update opportunity;

        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormDesktopBENLController();
        controller.init();
    }


    /*******************************************************************************
    *  Name            : choosingOfferBENLTest()
    *  Summary         : Testing choosing offer step    
    *  CreatedDate     : 03/09/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void choosingOfferBENLTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Belgium-NL';
        Account.ShippingCountry = 'Belgium-NL';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.E2E_Active_Step__c = 2;
        opportunity.E2E_Active_Substep__c = 'Choosing offer';
        opportunity.Product__c = '';
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

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EFormBENL');
        update opportunity;

        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        ApexPages.currentPage().getParameters().put('offerName', 'Home Station offer (v.1)');
        controller = new LongFormDesktopBENLController();
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
        System.assertEquals('Home Station offer (v.1)', opportunityList.get(0).Product__c, 'Wrong product.');
        System.assertEquals(null, opportunityList.get(0).Home_Station__c, 'Should be null fro this product.');
        System.assertEquals(null, opportunityList.get(0).ESI__c, 'Should be null fro this product.');
        System.assertEquals('Credit approved', opportunityList.get(0).StageName, 'Wrong stagename.');
        System.assertEquals(2, opportunityList.get(0).E2E_Active_Step__c, 'Wrong active step.');
    }


    /*******************************************************************************
    *  Name            : technicalParametersBENLTest()
    *  Summary         : Testing technical parameters step    
    *  CreatedDate     : 03/09/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void technicalParametersBENLTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Belgium-NL';
        Account.ShippingCountry = 'Belgium-NL';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.E2E_Active_Step__c = 2;
        opportunity.E2E_Active_Substep__c = 'Technical parameters';
        opportunity.Product__c = 'Home Station offer (v.1)';
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

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EFormBENL');
        update opportunity;

        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormDesktopBENLController();
        controller.init();
        ApexPages.currentPage().getparameters().put('cardindex', '1');
        controller.finalCardsMap.get(1).driverNameOrCarNumberInputValue = 'CONOR MCGREGOR';
        controller.finalCardsMap.get(1).companyNameInputValue = 'TEST';
        controller.finalCardsMap.get(1).selectedTypeOfCar = 'LKW';
        controller.finalCardsMap.get(1).needOdometerOptions = true;
        controller.saveTechParamForSingleCard();
        ApexPages.currentPage().getparameters().put('cardindex', '2');
        controller.finalCardsMap.get(2).driverNameOrCarNumberInputValue = 'JOHN WICK';
        controller.finalCardsMap.get(2).companyNameInputValue = 'TEST';
        controller.finalCardsMap.get(2).selectedTypeOfCar = 'PKW';
        controller.finalCardsMap.get(2).needOdometerOptions = true;
        controller.saveTechParamForSingleCard();
        ApexPages.currentPage().getparameters().put('cardindex', '3');
        controller.finalCardsMap.get(3).driverNameOrCarNumberInputValue = 'KURT COBAIN';
        controller.finalCardsMap.get(3).companyNameInputValue = 'TEST';
        controller.finalCardsMap.get(3).selectedTypeOfCar = 'PKW';
        controller.finalCardsMap.get(3).needOdometerOptions = true;
        controller.saveTechParamForSingleCard();
        ApexPages.currentPage().getparameters().put('cardindex', '4');
        controller.finalCardsMap.get(4).driverNameOrCarNumberInputValue = 'TEST TEST';
        controller.finalCardsMap.get(4).companyNameInputValue = 'TEST';
        controller.finalCardsMap.get(4).selectedTypeOfCar = 'LKW';
        controller.finalCardsMap.get(4).needOdometerOptions = false;
        controller.saveTechParamForSingleCard();
        controller.goToAdditionalParams();
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
    *  Name            : additionalStepBENLTest()
    *  Summary         : Testing additional step    
    *  CreatedDate     : 03/09/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void additionalStepBENLTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Belgium-NL';
        Account.ShippingCountry = 'Belgium-NL';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Pending Credit Check';
        opportunity.E2E_Active_Step__c = 3;
        opportunity.E2E_Active_Substep__c = 'Additional services';
        opportunity.Product__c = 'Home Station offer (v.1)';
        opportunity.E2E_Status__c = 'Abandoned (hard)';
        opportunity.E2E_Sub_Status__c = 'Marketing automation';
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

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EFormBENL');
        update opportunity;

        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormDesktopBENLController();
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
    *  Name            : paymentOptionsDirectDebitBENLTest()
    *  Summary         : Testing payment options step    
    *  CreatedDate     : 03/09/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void paymentOptionsDirectDebitBENLTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Belgium-NL';
        Account.ShippingCountry = 'Belgium-NL';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.E2E_Active_Substep__c = 'DirectDebit';
        opportunity.E2E_Active_Step__c = 4;
        opportunity.Name_of_the_payer_Account_holder__c = '';
        opportunity.IBAN__c = '';
        opportunity.SWIFT_BIC__c = '';
        opportunity.Product__c = 'Home Station offer (v.1)';
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
        Tankkarten__c card1 = E2ELongFormUtilsTest.createMultiNetworkCardInternational(opportunity.Id);
        cardsForInsert.add(card1);

        Tankkarten__c card2 = E2ELongFormUtilsTest.createMultiNetworkCardNational(opportunity.Id);
        cardsForInsert.add(card2);

        Tankkarten__c card3 = E2ELongFormUtilsTest.createSingleNetworkCardInternational(opportunity.Id);
        cardsForInsert.add(card3);

        Tankkarten__c card4 = E2ELongFormUtilsTest.createSingleNetworkCardNational(opportunity.Id);
        cardsForInsert.add(card4);

        insert cardsForInsert;

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EFormBENL');
        update opportunity;

        Attachment attachment = E2ELongFormUtilsTest.createAttachment('SEPAMandate.pdf', opportunity.Id);
        insert attachment;

        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormDesktopBENLController();
        controller.init();
        controller.activeStep = 4;
        controller.activeSubStep = 'DirectDebit';
        controller.stepPagesMap.get('PAYMENT OPTIONS').fields.get('ACCOUNT HOLDER').elementItemsMap.get('VALUE').Value__c = 'CONOR MCGREGOR';
        controller.stepPagesMap.get('PAYMENT OPTIONS').fields.get('IBAN').elementItemsMap.get('VALUE').Value__c = 'BE71096123456769';
        controller.stepPagesMap.get('PAYMENT OPTIONS').fields.get('PAPER INVOICE').elementItemsMap.get('VALUE').Value__c = 'true';
        controller.stepPagesMap.get('PAYMENT OPTIONS').fields.get('ACCEPT SEPA').elementItemsMap.get('VALUE').Value__c = 'true';
        controller.stepPagesMap.get('PAYMENT OPTIONS').fields.get('DECISION').elementItemsMap.get('VALUE').Value__c = 'true';
        controller.stepPagesMap.get('PAYMENT OPTIONS').fields.get('ACCEPT TERM CONDITIONS').elementItemsMap.get('VALUE').Value__c = 'true';
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new E2EIbanMock());
            controller.jsValidateIBAN();
        Test.stopTest();
        controller.doSavePaymentOptionsData();
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
        System.assertEquals('BE71096123456769', oppList.get(0).IBAN__c);
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
    *  Name            : paymentOptionsDirectDebitDepositBENLTest()
    *  Summary         : Testing Direct Debit Deposit
    *  CreatedDate     : 03/09/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void paymentOptionsDirectDebitDepositBENLTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Belgium-NL';
        Account.ShippingCountry = 'Belgium-NL';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.Product__c = 'Home Station offer (v.1)';
        opportunity.E2E_Status__c = 'Abandoned (hard)';
        opportunity.E2E_Sub_Status__c = 'Marketing automation';
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

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EFormBENL');
        update opportunity;

        Attachment attachment = E2ELongFormUtilsTest.createAttachment('DepositAgreement.pdf', opportunity.Id);
        insert attachment;

        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormDesktopBENLController();
        controller.init();
        controller.paymentStatus = null;
        // Giropay payment method
        controller.selectedPaymentMethod = 'Giropay';
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
    *  Name            : congratulationPendingSalesDepositBENLTest()
    *  Summary         : Go to congratulation step test pending sales - deposit    
    *  CreatedDate     : 03/09/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void congratulationPendingSalesDepositBENLTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Belgium-NL';
        Account.ShippingCountry = 'Belgium-NL';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.Product__c = 'Home Station offer (v.1)';
        opportunity.E2E_Status__c = 'Abandoned (hard)';
        opportunity.E2E_Sub_Status__c = 'Marketing automation';
        opportunity.E2E_Active_Step__c = 5;
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

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EFormBENL');
        update opportunity;

        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormDesktopBENLController();
        controller.paymentStatus = 'A';
        controller.init();
        // controller.receiveFreeBonus();

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


    /*******************************************************************************
    *  Name            : returnToCongratulationBENLTest()
    *  Summary         : Testing return to congratulation test (Step 5)  
    *  CreatedDate     : 03/09/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void returnToCongratulationBENLTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Belgium-NL';
        Account.ShippingCountry = 'Belgium-NL';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.E2E_Active_Step__c = 5;
        opportunity.E2E_payment_status__c = 'Accept';
        opportunity.Product__c = 'Home Station offer (v.1)';
        opportunity.E2E_Status__c = 'Abandoned (hard)';
        opportunity.E2E_Sub_Status__c = 'Marketing automation';
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

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EFormBENL');
        update opportunity;

        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormDesktopBENLController();
        controller.init();
    }
}