@isTest
private class E2EDesktopPLTest {
    public static LongFormDesktopPLController controller;

    /*******************************************************************************
    *  Name            : createLongFormData()
    *  Summary         : Creating all LongForm data    
    *  CreatedDate     : 30/11/2018
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
        E2ELongFormUtilsTest.createInternationalPartnersDiffPrice('Poland', 'JITB');
        E2ELongFormUtilsTest.createNationalNotPartnersDiffPrice('Poland', 'JITB');
        E2ELongFormUtilsTest.createInternationalNotPartnersDiffPrice('Poland', 'JITB');
        E2ELongFormUtilsTest.createNationalPartnersDiffPrice('Poland', 'JITB');
        E2ELongFormUtilsTest.createLongForm('Poland');
        E2ELongFormUtilsTest.createLongFormMenu();
        E2ELongFormUtilsTest.createMenuItemForStep1('Desktop');
        E2ELongFormUtilsTest.createMenuItemForStep2('Desktop');
        E2ELongFormUtilsTest.createMenuItemForStep3('Desktop');
        E2ELongFormUtilsTest.createMenuItemForStep4('Desktop');
        E2ELongFormUtilsTest.createHeader('Desktop');
        E2ELongFormUtilsTest.createContactDeatilsData('Desktop');
        E2ELongFormUtilsTest.createCustomSettings('Poland', 'E2EFormPL', 'Crif', '0050O000007Drnn');
        E2ELongFormUtilsTest.createOrderDetailsBlock('Desktop');
        E2ELongFormUtilsTest.createFooter('Desktop');
        E2ELongFormUtilsTest.createCreditScoreSearchCompany('Desktop');
        E2ELongFormUtilsTest.createCreditScoreTotalConsumption('Desktop');
        E2ELongFormUtilsTest.createAdditionalCreditScoring('Desktop');
        E2ELongFormUtilsTest.createCreditScoringResult('Desktop');
        E2ELongFormUtilsTest.createCardConfiguration('Desktop');
        E2ELongFormUtilsTest.createCardConfigurationSpecialOffers('Desktop', 'SHELL STANDARD 2019 OFFER CONTENT PL DESKTOP', 'SHELL STANDARD 2019 OFFER CONTENT PL DESKTOP', 'Poland', 'Inbound', 'Shell Standard 2019', 'Shell Standard 2019');
        // E2ELongFormUtilsTest.createCardConfigurationSpecialOfferPLHU('Desktop', 'Poland');
        E2ELongFormUtilsTest.createCardConfigurationTechnicalParameters('Desktop');
        E2ELongFormUtilsTest.createAdditionalPage('Desktop');
        E2ELongFormUtilsTest.createAdditionalDateOfBirth('Desktop');
        E2ELongFormUtilsTest.createDocuments('Desktop');

        E2ELongFormUtilsTest.createPaymentOptions('Desktop');
        E2ELongFormUtilsTest.createCongratulations('Desktop');
        E2ELongFormUtilsTest.createCongratulationsPage('Desktop');
        E2ELongFormUtilsTest.createSystemErrorPage('Desktop');
        E2ELongFormUtilsTest.createProcessErrorPage('Desktop');
        E2ELongFormUtilsTest.createAlreadyCustomerPage('Desktop');
        E2ELongFormUtilsTest.createAlreadyInProcessPage('Desktop');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCrifAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCrifOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.doCreateCreditSystemSalesProfile();
        insert creditSystemSalesProfile;
    }


    /*******************************************************************************
    *  Name            : findDupLeadWithSameDataPLTest()
    *  Summary         : Verify that when Contact #2 and Lead #1 has the same First Name + Last Name + Email + Phone domain then Lead is disqualified 
    *  ExpectedResult  : E2E Contact #2 was created. Lead #1 Status = Disqualified Quali Status = Switched to E2E Notification was sent to the Lead Owner
    *  CreatedDate     : 30/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void findDupLeadWithSameDataPLTest() {
        User e2eUser = E2ELongFormUtilsTest.createE2EDEUser();
        Database.insert(e2eUser);
        
        System.runAs(e2eUser) {
            Lead lead = E2ELongFormUtilsTest.createLeadForDuplicateDE();
            lead.Country = 'Poland';
            lead.Phone = '+48123456789';
            insert lead;

            controller = new LongFormDesktopPLController();
            controller.init();
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
    *  Name            : insertDupConSameDataClosedLostPLTest()
    *  Summary         : Verify that two Contacts were merged when First Name + Last Name + Email + Phone are the same and Contact #1 has E2E Opportunity #1 in stage Closed Lost    
    *  ExpectedResult  : Two contacts were merged. E2E Account #2, E2E Opportuinty #2 were created. Direct Connections were changed to E2E records
    *  CreatedDate     : 20/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void insertDupConSameDataClosedLostPLTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Poland';
        Account.ShippingCountry = 'Poland';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Closed Lost';
        opportunity.Product__c = '';
        opportunity.Anzahl_der_Karten__c = 1;
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        contact.MailingCountry = 'Poland';
        contact.Phone = '+48123456789';
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        controller = new LongFormDesktopPLController();
        controller.activeStep = 0;
        controller.init();
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
        System.assertEquals('+48123456789', contactList.get(0).Phone, 'Expected Phone from form.');
        System.assertEquals('test@fleetcor.com', contactList.get(0).Email, 'Expected Email from form.');
    }


    /*******************************************************************************
    *  Name            : insertDupConSameDataWithE2EOppPLTest()
    *  Summary         : Verify that two Contacts were merged when First Name + Last Name + Email + Phone are the same 
                         and Contact #1 has E2E Opportunity #1 NOT in stage Closed Lost / Closed WON / Pending Sales - Deposit
    *  ExpectedResult  : Two contacts were merged. Form of the business is updated in Opportunity #1 User is redirected to last E2E step of the Opportunity #1
    *  CreatedDate     : 30/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void insertDupConSameDataWithE2EOppPLTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Poland';
        Account.ShippingCountry = 'Poland';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Prospecting';
        opportunity.E2E_Active_Step__c = 1;
        opportunity.E2E_Active_Substep__c = 'Search company';
        opportunity.Product__c = '';
        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EFormPL');
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        contact.MailingCountry = 'Poland';
        contact.Phone = '+48123456789';
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        controller = new LongFormDesktopPLController();
        controller.activeStep = 0;
        controller.init();
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
        System.assertEquals('+48123456789', contactList.get(0).Phone, 'Expected Phone from form.');
        System.assertEquals('test@fleetcor.com', contactList.get(0).Email, 'Expected Email from form.');
    }


    /*******************************************************************************
    *  Name            : updateDupConSameDataClosedLostPLTest()
    *  Summary         : Verify that two Contacts were merged when First Name + Last Name + Email + Phone are the same and Contact #1 has E2E Opportunity #1 in stage Closed Lost
    *  ExpectedResult  : E2E Opportunity #2 Stage = Closed Lost. Reason = Duplicate. E2E Account #2, E2E Contact #2 were NOT deleted.
                         Contacts were merged. New E2E Account #3, New E2E Opportunity #3 were created. Direct Connections were changed to E2E records
    *  CreatedDate     : 30/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void updateDupConSameDataClosedLostPLTest() {
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

        controller = new LongFormDesktopPLController();
        controller.activeStep = 0;
        controller.init();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JohnAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SmithAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+48111111111';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'testAA@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('PHONE CONTACT AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('RECEIVE COMM INFO BY EMAIL AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();
        // back to update data
        controller.goToContactDetails();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHN';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SMITH';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+48123456789';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'test@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('PHONE CONTACT AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('RECEIVE COMM INFO BY EMAIL AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
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
        System.assertEquals('+48123456789', contactList.get(0).Phone, 'Expected Phone from form.');
        System.assertEquals('test@fleetcor.com', contactList.get(0).Email, 'Expected Email from form.');
    }


    /*******************************************************************************
    *  Name            : updateDupConSameDataProspectingPLTest()
    *  Summary         : Verify that two Contacts were merged when First Name + Last Name + Email + Phone are the same and 
                         Contact #1 has E2E Opportunity #1 NOT in stage Closed Lost / Closed WON / Pending Sales - Deposit
    *  ExpectedResult  : E2E Opportunity #2 Stage = Closed Lost. Reason = Duplicate. E2E Account #2, E2E Contact #2 were NOT deleted. Contacts were merged. 
                         User is redirected to the last E2E step of the Opportunity #1
    *  CreatedDate     : 30/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void updateDupConSameDataProspectingPLTest() {
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
       
        controller = new LongFormDesktopPLController();
        controller.activeStep = 0;
        controller.init();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JohnAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SmithAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+48111111111';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'testAA@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('PHONE CONTACT AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('RECEIVE COMM INFO BY EMAIL AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();
        // back to update data
        controller.goToContactDetails();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHN';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SMITH';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+48123456789';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'test@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('PHONE CONTACT AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('RECEIVE COMM INFO BY EMAIL AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
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
        System.assertEquals('+48123456789', contactList.get(0).Phone, 'Expected Phone from form.');
        System.assertEquals('test@fleetcor.com', contactList.get(0).Email, 'Expected Email from form.');
    }


    /*******************************************************************************
    *  Name            : contactDetailsPLTest()
    *  Summary         : Verify all fields on contact details step
    *  CreatedDate     : 30/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void contactDetailsPLTest() {
        controller = new LongFormDesktopPLController();
        controller.init();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Herr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Test First Name';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Test Last Name';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+48123456789';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'test@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NUMBER OF CARDS').elementItemsMap.get('DEFAULT VALUE').Value__c = '1';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('PHONE CONTACT AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('RECEIVE COMM INFO BY EMAIL AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.showAgreeToPhoneContact();
        controller.showAgreeToInfoByEmail();
        controller.showAgreeNews();
        controller.goToCreditScoring();

        // back button code coverage
        controller.backToCreditScoring();

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
        System.assertEquals('TEST FIRST NAME', contactList.get(0).FirstName, 'Should be value from form.');
        System.assertEquals('TEST LAST NAME', contactList.get(0).LastName, 'Should be value from form.');
        System.assertEquals('+48123456789', contactList.get(0).Phone, 'Should be value from form.');
        System.assertEquals('test@fleetcor.com', contactList.get(0).Email, 'Should be value from form.');
        System.assertEquals(false, contactList.get(0).Authorised_signatory__c, 'Should be Automatic filling by default.');
        System.assertEquals(true, contactList.get(0).E2E__c, 'Should be Automatic filling by default.');
        System.assertEquals('Poland', contactList.get(0).MailingCountry, 'Should be Automatic filling by default.');
        System.assertEquals('Contact layout', contactList.get(0).RecordType.Name, 'Should be Automatic filling by default.');

        // account
        System.assertEquals(1, contactList.get(0).AccountContactRelations.size(), 'One Account is expected.');
        System.assertEquals('LONGFORM: TEST FIRST NAME TEST LAST NAME', contactList.get(0).AccountContactRelations.get(0).Account.Name, 'Should be value from form.');
        System.assertEquals('Endkunde', contactList.get(0).AccountContactRelations.get(0).Account.RecordType.Name, 'Should be Automatic filling by default.');
        System.assertEquals('Customer', contactList.get(0).AccountContactRelations.get(0).Account.Type, 'Should be Automatic filling by default.');
        System.assertEquals(true, contactList.get(0).AccountContactRelations.get(0).Account.E2E__c, 'Should be Automatic filling by default.');
        System.assertEquals('Poland', contactList.get(0).AccountContactRelations.get(0).Account.BillingCountry, 'Should be Automatic filling by default.');
        System.assertEquals('Poland', contactList.get(0).AccountContactRelations.get(0).Account.ShippingCountry, 'Should be Automatic filling by default.');

        // opportunity
        System.assertEquals(1, contactList.get(0).OpportunityContactRoles.size(), 'One Opportunity is expected.');
        System.assertEquals('LONGFORM: TEST FIRST NAME TEST LAST NAME', contactList.get(0).OpportunityContactRoles.get(0).Opportunity.Name, 'Should be value from form.');
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
    *  Name            : searchCompanyPLTest()
    *  Summary         : Testing flow from Search Company with Mock
    *  CreatedDate     : 31/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void searchCompanyPLTest() {
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
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EFormPL');
        update opportunity;

        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormDesktopPLController();
        controller.init();
        
        controller.stepPagesMap.get('CREDIT SCORE. SEARCH COMPANY').fields.get('COMPANY NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'TEST';
        controller.stepPagesMap.get('CREDIT SCORE. SEARCH COMPANY').fields.get('TAX ID').elementItemsMap.get('DEFAULT VALUE').Value__c = '1234567890';
        controller.activeSubstep = 'Set total consumption';
        controller.doSaveCompanyDetailsData();

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new E2ELongFromPLCreditFactoryMock());
            controller.doSearchCompany();
        Test.stopTest();

        controller.editContactDetails();

        List<Account> accountList = [SELECT Name, Steuernummer__c FROM Account];
        System.assertEquals('TEST', accountList.get(0).Name);
        System.assertEquals('1234567890', accountList.get(0).Steuernummer__c);
    }


    /*******************************************************************************
    *  Name            : verifyAllFieldsPLTest()
    *  Summary         : Verify that Credit Report record was created and updated with info    
    *  CreatedDate     : 30/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void verifyAllFieldsPLTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Poland';
        Account.ShippingCountry = 'Poland';
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

        controller = new LongFormDesktopPLController();
        controller.init();
        controller.activeStep = 1;
        controller.initPageElements();
        controller.initSObjects(opportunity.Id);
        controller.selectedCompany = new CreditCompany();
        controller.selectedCompany.identificationnumber = '8338085693';
        controller.deleteReportsForPreviousCompany();

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new E2ELongFromPLCreditFactoryMock());
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
        System.assertEquals('MUSZELKI WALDEMAR SZYBKI', oppList.get(0).Name, 'Should be Automatic filling by default from CF.');
        System.assertEquals('Prospecting', oppList.get(0).StageName, 'Should be Automatic filling by default.');
        System.assertEquals(0, oppList.get(0).Gasoline_consumption_l_month__c, 'Always should be 0.');
        System.assertEquals(1000, oppList.get(0).Diesel_consumption_l_month__c, 'Shoul be the same as total consumption.');
        System.assertEquals(1000, oppList.get(0).Total_consumption_l_month__c, 'Wrong total consumption.');
        System.assertEquals('Calculating credit score', oppList.get(0).E2E_Active_Substep__c, 'Wrong active substep.');
        System.assertEquals(1, oppList.get(0).E2E_Active_Step__c, 'Should be Automatic filling by default.');

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
    *  Name            : creditScoringAllowancePLTest()
    *  Summary         : Testing credit scoring allowance step    
    *  CreatedDate     : 04/12/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void creditScoringAllowancePLTest() {
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

        Contact contact = E2ELongFormUtilsTest.createContactDE(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EFormPL');
        update opportunity;

        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormDesktopPLController();
        controller.init();
        // credit scoring allowance
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new DocusignPLMock());
            controller.goToSignDocuments();
        Test.stopTest();
    }


    /*******************************************************************************
    *  Name            : searchDuplicateCase5PLTest()
    *  Summary         : Search duplicate account case #5   
    *  CreatedDate     : 30/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void searchDuplicateCase5PLTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Poland';
        Account.ShippingCountry = 'Poland';
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
        account2.BillingCountry = 'Poland';
        account2.ShippingCountry = 'Poland';
        account2.Steuernummer__c = '2451803340';
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

        controller = new LongFormDesktopPLController();
        controller.init();
        controller.activeStep = 1;
        controller.initPageElements();
        controller.initSObjects(opportunity.Id);
        controller.selectedCompany = new CreditCompany();
        controller.selectedCompany.identificationnumber = '8338085693';
        controller.deleteReportsForPreviousCompany();

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new E2ELongFromPLCreditFactoryMock());
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
    *  Name            : searchDuplicateCase1PLTest()
    *  Summary         : Search duplicate account case #1   
    *  CreatedDate     : 30/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void searchDuplicateCase1PLTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Poland';
        Account.ShippingCountry = 'Poland';
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
        account2.BillingCountry = 'Poland';
        account2.ShippingCountry = 'Poland';
        account2.Steuernummer__c = '2451803340';
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

        controller = new LongFormDesktopPLController();
        controller.init();
        controller.activeStep = 1;
        controller.initPageElements();
        controller.initSObjects(opportunity.Id);
        controller.selectedCompany = new CreditCompany();
        controller.selectedCompany.identificationnumber = '8338085693';
        controller.deleteReportsForPreviousCompany();

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new E2ELongFromPLCreditFactoryMock());
            controller.goToSetTotalConsumption();
        Test.stopTest();

        List<Opportunity> oppList = [SELECT Owner.Name FROM Opportunity WHERE Id = :opportunity.Id];
        System.assertEquals('E2E Site Guest User', oppList.get(0).Owner.Name);
    }


    /*******************************************************************************
    *  Name            : searchDuplicateCase2PLTest()
    *  Summary         : Search duplicate account case #2   
    *  CreatedDate     : 30/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void searchDuplicateCase2PLTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Poland';
        Account.ShippingCountry = 'Poland';
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
        account2.BillingCountry = 'Poland';
        account2.ShippingCountry = 'Poland';
        account2.Steuernummer__c = '2451803340';
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

        controller = new LongFormDesktopPLController();
        controller.init();
        controller.activeStep = 1;
        controller.initPageElements();
        controller.initSObjects(opportunity.Id);
        controller.selectedCompany = new CreditCompany();
        controller.selectedCompany.identificationnumber = '8338085693';
        controller.deleteReportsForPreviousCompany();

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new E2ELongFromPLCreditFactoryMock());
            controller.goToSetTotalConsumption();
        Test.stopTest();

        controller.stepPagesMap.get('CREDIT SCORE. TOTAL CONSUMPTION').fields.get('TOTAL CONSUMPTION').elementItemsMap.get('DEFAULT VALUE').Value__c = '1000';
        controller.doCalculateCreditScoring();

        List<Opportunity> oppList = [SELECT StageName, Gruende_verloren__c FROM Opportunity WHERE Id = :opportunity.Id];
        System.assertEquals('Closed Lost', oppList.get(0).StageName);
        System.assertEquals('Duplicate', oppList.get(0).Gruende_verloren__c);
    }


    /*******************************************************************************
    *  Name            : searchDuplicateCase3PLTest()
    *  Summary         : Search duplicate account case #3   
    *  CreatedDate     : 30/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void searchDuplicateCase3PLTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Poland';
        Account.ShippingCountry = 'Poland';
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
        account2.BillingCountry = 'Poland';
        account2.ShippingCountry = 'Poland';
        account2.Steuernummer__c = '2451803340';
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

        controller = new LongFormDesktopPLController();
        controller.init();
        controller.activeStep = 1;
        controller.initPageElements();
        controller.initSObjects(opportunity.Id);
        controller.selectedCompany = new CreditCompany();
        controller.selectedCompany.identificationnumber = '8338085693';
        controller.deleteReportsForPreviousCompany();

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new E2ELongFromPLCreditFactoryMock());
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
    *  Name            : goToCardConfigNonDepositPLTest()
    *  Summary         : Verify all fields when you go from 1 step to 2 step 
    *  CreatedDate     : 20/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void goToCardConfigNonDepositPLTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Poland';
        Account.ShippingCountry = 'Poland';
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

        controller = new LongFormDesktopPLController();
        controller.init();
        controller.activeStep = 1;
        controller.initPageElements();
        controller.initSObjects(opportunity.Id);
        controller.selectedCompany = new CreditCompany();
        controller.selectedCompany.identificationnumber = '8338085693';
        controller.deleteReportsForPreviousCompany();

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new E2ELongFromPLCreditFactoryMock());
            controller.goToSetTotalConsumption();
        Test.stopTest();

        controller.stepPagesMap.get('CREDIT SCORE. TOTAL CONSUMPTION').fields.get('TOTAL CONSUMPTION').elementItemsMap.get('DEFAULT VALUE').Value__c = '1000';
        controller.doCalculateCreditScoring();
        // calculate Lastschrift weekly credit score data
        controller.stepPagesMap.get('CREDIT SCORE. SCORING RESULT').fields.get('PAYMENT METHOD').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Lastschrift';
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
    *  Name            : cardConfigurationWithThreeCardsPLTest()
    *  Summary         : Testing card configuration step, add 3 diff card   
    *  CreatedDate     : 30/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void cardConfigurationWithThreeCardsPLTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Poland';
        Account.ShippingCountry = 'Poland';
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

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EFormPL');
        update opportunity;

        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormDesktopPLController();
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
        System.assertEquals('Technical parameters', oppList.get(0).E2E_Active_Substep__c);
        System.assertEquals(2, oppList.get(0).Anzahl_der_Karten__c);
        System.assertEquals(2, oppList.get(0).Total_number_of_vehicles__c);
    }


    /*******************************************************************************
    *  Name            : choosingOfferPLTest()
    *  Summary         : Testing choosing offer step    
    *  CreatedDate     : 03/12/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void choosingOfferPLTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Poland';
        Account.ShippingCountry = 'Poland';
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

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EFormPL');
        update opportunity;

        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        ApexPages.currentPage().getParameters().put('offerName', 'Shell Standard 2019');
        controller = new LongFormDesktopPLController();
        controller.init();
        controller.selectOffer();
        // testing remove offer
        controller.removeOffer();
        controller.selectOffer();
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
        System.assertEquals('Shell Standard 2019', opportunityList.get(0).Product__c, 'Wrong product.');
        System.assertEquals(null, opportunityList.get(0).Home_Station__c, 'Should be null fro this product.');
        System.assertEquals(null, opportunityList.get(0).ESI__c, 'Should be null fro this product.');
        System.assertEquals('Credit approved', opportunityList.get(0).StageName, 'Wrong stagename.');
        System.assertEquals(2, opportunityList.get(0).E2E_Active_Step__c, 'Wrong active step.');
    }


    /*******************************************************************************
    *  Name            : technicalParametersPLTest()
    *  Summary         : Testing technical parameters step    
    *  CreatedDate     : 03/12/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void technicalParametersPLTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Poland';
        Account.ShippingCountry = 'Poland';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.E2E_Active_Step__c = 2;
        opportunity.E2E_Active_Substep__c = 'Technical parameters';
        opportunity.Product__c = 'Shell Standard 2019';
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

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EFormPL');
        update opportunity;

        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormDesktopPLController();
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
        System.assertEquals(2, opportunityList.get(0).E2E_Active_Step__c, 'Wrong active step.');
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
    *  Name            : additionalStepPLTest()
    *  Summary         : Testing additional step and date of birth substep 
    *  CreatedDate     : 03/12/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void additionalStepPLTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Poland';
        Account.ShippingCountry = 'Poland';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Pending Credit Check';
        opportunity.E2E_Active_Step__c = 2;
        opportunity.E2E_Active_Substep__c = 'Additional services';
        opportunity.Product__c = 'Shell Standard 2019';
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

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EFormPL');
        update opportunity;

        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormDesktopPLController();
        controller.init();
        controller.stepPagesMap.get('ADDITIONAL').elements.get('ADDITIONAL SERVICE #1').get('AGREEMENT CHECKBOX VALUE').Value__c = 'true';
        controller.stepPagesMap.get('ADDITIONAL').elements.get('ADDITIONAL SERVICE #2').get('VAT AGREEMENT CHECKBOX VALUE').Value__c = 'true';
        controller.stepPagesMap.get('ADDITIONAL').elements.get('ADDITIONAL SERVICE #2').get('VAT TC AGREEMENT CHECKBOX VALUE').Value__c = 'true';
        controller.goToDocuments();
        // date of birth
        controller.backToAdditionalFromDOB();
        controller.goToDocuments();
        controller.stepPagesMap.get('ADDITIONAL. ENTER DATE OF BIRTH').fields.get('DATE OF BIRTH').elementItemsMap.get('DEFAULT VALUE').Value__c = '24.01.1990';
        controller.continueToAdditionalParamsFromDob();

        // testing back buttton
        controller.backToAdditionalParams();

        controller.stepPagesMap.get('ADDITIONAL').elements.get('ADDITIONAL SERVICE #1').get('AGREEMENT CHECKBOX VALUE').Value__c = 'false';
        controller.stepPagesMap.get('ADDITIONAL').elements.get('ADDITIONAL SERVICE #2').get('VAT AGREEMENT CHECKBOX VALUE').Value__c = 'false';
        controller.stepPagesMap.get('ADDITIONAL').elements.get('ADDITIONAL SERVICE #2').get('VAT TC AGREEMENT CHECKBOX VALUE').Value__c = 'false';
        controller.stepPagesMap.get('ADDITIONAL').elements.get('ADDITIONAL SERVICE #3').get('AGREEMENT CHECKBOX VALUE').Value__c = 'true';
        controller.goToDocuments();

        List<Contact> contactList = [
                SELECT Birthdate,
                    (SELECT Opportunity.VAT_Recovery__c, Opportunity.Agree_to_VAT_Recovery_TC__c, Opportunity.Eco_Fee__c, Opportunity.E2E_Active_Step__c, Opportunity.E2E_Active_Substep__c, Opportunity.Interested_in_Telematics__c
                    FROM OpportunityContactRoles)
                FROM Contact];

        // Contact
        System.assertEquals('1990-01-24', String.valueOf(contactList.get(0).Birthdate));
        // Opportunity
        System.assertEquals(false, contactList.get(0).OpportunityContactRoles.get(0).Opportunity.VAT_Recovery__c);
        System.assertEquals(false, contactList.get(0).OpportunityContactRoles.get(0).Opportunity.Agree_to_VAT_Recovery_TC__c);
        System.assertEquals(false, contactList.get(0).OpportunityContactRoles.get(0).Opportunity.Eco_Fee__c);
        System.assertEquals(true, contactList.get(0).OpportunityContactRoles.get(0).Opportunity.Interested_in_Telematics__c);
        System.assertEquals(3, contactList.get(0).OpportunityContactRoles.get(0).Opportunity.E2E_Active_Step__c);
        System.assertEquals('Documents', contactList.get(0).OpportunityContactRoles.get(0).Opportunity.E2E_Active_Substep__c);
    }


    /*******************************************************************************
    *  Name            : documentsPLTest()
    *  Summary         : Testing documents step    
    *  CreatedDate     : 03/12/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void documentsPLTest() {
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
        controller = new LongFormDesktopPLController();
        controller.init();
        // catch errors
        controller.saveDocumentsStepData();
        // normal flow
        controller.stepPagesMap.get('DOCUMENTS').fields.get('PAPER INVOICE').elementItemsMap.get('VALUE').Value__c = 'true';
        controller.stepPagesMap.get('DOCUMENTS').fields.get('DECISION').elementItemsMap.get('VALUE').Value__c = 'true';
        controller.stepPagesMap.get('DOCUMENTS').fields.get('ACCEPT TERMS AND CONDITIONS').elementItemsMap.get('VALUE').Value__c = 'true';
        controller.saveDocumentsStepData();

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new DocusignPLMock());
            controller.goToSignDocuments();
        Test.stopTest();
        //Order details
        controller.editTotalConsumption();
        controller.editCompanyDetails();
        controller.editContactDetails();

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
    *  Name            : returnFromDocusignDepositPLTest()
    *  Summary         : Testing flow when customer signed documents (deposit required)   
    *  CreatedDate     : 04/12/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void returnFromDocusignDepositPLTest() {
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
        controller = new LongFormDesktopPLController();
        controller.init();

        // order details
        controller.editCardsEmbossing();
        controller.editCreditLimit();

        List<Opportunity> opportunityList = [SELECT E2E_Active_Step__c, StageName, E2E_Active_Substep__c FROM Opportunity WHERE Id = :opportunity.Id];
        System.assertEquals(4, opportunityList.get(0).E2E_Active_Step__c);
        System.assertEquals('Credit approved', opportunityList.get(0).StageName);
        System.assertEquals('DirectDebitDeposit', opportunityList.get(0).E2E_Active_Substep__c);
    }


    /*******************************************************************************
    *  Name            : returnFromDocusignNoNDepositPLTest()
    *  Summary         : Testing flow when customer signed documents (deposit is not required)   
    *  CreatedDate     : 04/12/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void returnFromDocusignNoNDepositPLTest() {
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
        controller = new LongFormDesktopPLController();
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
    *  Name            : paymentOptionsPLTest()
    *  Summary         : Testing payment options step    
    *  CreatedDate     : 04/12/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void paymentOptionsPLTest() {
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
        controller = new LongFormDesktopPLController();
        controller.init();
        controller.proceedToCheckout();
        // back button code coverage
        controller.backToDocuments();
        // order details
        controller.editCardsFeesAndCosts();

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
    *  Name            : congratulationsPLTest()
    *  Summary         : Testing return to congratulation test (Step 5)     
    *  CreatedDate     : 04/12/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void congratulationsPLTest() {
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
        controller = new LongFormDesktopPLController();
        controller.paymentStatus = 'A';
        controller.init();

        controller.showAdditionalCreditScoringAllowanceModal();
        controller.showTermsAndConditionsVatRecoveryModal();
        controller.showDocumentsModal();
        controller.showTermsAndConditionsModal();
        controller.showDDmandateAcceptanceDocModal();

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