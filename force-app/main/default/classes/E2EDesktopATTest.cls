@isTest
private class E2EDesktopATTest {
    public static LongFormController controller;

    /*******************************************************************************
    *  Name            : createLongFormData()
    *  Summary         : Creating all LongForm data    
    *  CreatedDate     : 26/03/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @testSetup
    static void createLongFormData() {
        E2ELongFormUtilsTest.createInternationalPartnersPrice('Austria', 'Inbound');
        E2ELongFormUtilsTest.createNationalNotPartnersPrice('Austria', 'Inbound');
        E2ELongFormUtilsTest.createInternationalNotPartnersPrice('Austria', 'Inbound');
        E2ELongFormUtilsTest.createNationalPartnersPrice('Austria', 'Inbound');
        E2ELongFormUtilsTest.createInternationalPartnersDiffPrice('Austria', 'Inbound');
        E2ELongFormUtilsTest.createNationalNotPartnersDiffPrice('Austria', 'Inbound');
        E2ELongFormUtilsTest.createInternationalNotPartnersDiffPrice('Austria', 'Inbound');
        E2ELongFormUtilsTest.createNationalPartnersDiffPrice('Austria', 'Inbound');
        E2ELongFormUtilsTest.createLongForm('Austria');
        E2ELongFormUtilsTest.createLongFormMenu();
        E2ELongFormUtilsTest.createMenuItemForStep1('Desktop');
        E2ELongFormUtilsTest.createMenuItemForStep2('Desktop');
        E2ELongFormUtilsTest.createMenuItemForStep3('Desktop');
        E2ELongFormUtilsTest.createMenuItemForStep4('Desktop');
        E2ELongFormUtilsTest.createHeader('Desktop');
        E2ELongFormUtilsTest.createContactDeatilsData('Desktop');
        E2ELongFormUtilsTest.createCustomSettings('Austria', 'E2EFormAT', 'CreditReformAT', '00520000005vYf3');
        E2ELongFormUtilsTest.createOrderDetailsBlock('Desktop');
        E2ELongFormUtilsTest.createFooter('Desktop');
        E2ELongFormUtilsTest.createCreditScoreAnotherTaxID('Desktop');
        E2ELongFormUtilsTest.createCreditScoreSearchCompany('Desktop');
        E2ELongFormUtilsTest.createCreditScoreTotalConsumption('Desktop');
        E2ELongFormUtilsTest.createCreditScoringResult('Desktop');
        E2ELongFormUtilsTest.createCardConfiguration('Desktop');
        E2ELongFormUtilsTest.createCardConfigurationSpecialOffers('Desktop', 'INBOUND TYPE C OFFER #1', 'INBOUND TYPE B OFFER #1', 'Austria', 'Inbound', 'Home Station offer (v.1)', 'Home Station offer (v.1)');
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

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingAT();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingAT();
        insert creditFactoryOpportunity;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.doCreateCreditSystemSalesProfile();
        insert creditSystemSalesProfile;
    }


    /*******************************************************************************
    *  Name            : findDupLeadWithSameDataAtTest()
    *  Summary         : Verify that when Contact #2 and Lead #1 has the same First Name + Last Name + Email + Phone domain then Lead is disqualified 
    *  ExpectedResult  : E2E Contact #2 was created. Lead #1 Status = Disqualified Quali Status = Switched to E2E Notification was sent to the Lead Owner
    *  CreatedDate     : 26/03/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void findDupLeadWithSameDataAtTest() {
        ApexPages.currentPage().getparameters().put('country', 'at');
        User e2eUser = E2ELongFormUtilsTest.createE2EDEUser();
        Database.insert(e2eUser);
        
        System.runAs(e2eUser) {
            Lead lead = E2ELongFormUtilsTest.createLeadForDuplicateDE();
            lead.Country = 'Austria';
            insert lead;

            controller = new LongFormController();
            controller.init();
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHN';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SMITH';
            controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+431872378123887';
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
    *  Name            : insertDupConSameDataClosedLostAtTest()
    *  Summary         : Verify that two Contacts were merged when First Name + Last Name + Email + Phone are the same and Contact #1 has E2E Opportunity #1 in stage Closed Lost    
    *  ExpectedResult  : Two contacts were merged. E2E Account #2, E2E Opportuinty #2 were created. Direct Connections were changed to E2E records
    *  CreatedDate     : 26/03/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void insertDupConSameDataClosedLostAtTest() {
        ApexPages.currentPage().getparameters().put('country', 'at');
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Austria';
        Account.ShippingCountry = 'Austria';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Closed Lost';
        opportunity.Product__c = '';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        contact.MailingCountry = 'Austria';
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        controller = new LongFormController();
        controller.activeStep = 0;
        controller.init();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHN';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SMITH';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+431872378123887';
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
        System.assertEquals('+431872378123887', contactList.get(0).Phone, 'Expected Phone from form.');
        System.assertEquals('test@fleetcor.com', contactList.get(0).Email, 'Expected Email from form.');
    }


    /*******************************************************************************
    *  Name            : insertDupConSameDataWithE2EOppATTest()
    *  Summary         : Verify that two Contacts were merged when First Name + Last Name + Email + Phone are the same 
                         and Contact #1 has E2E Opportunity #1 NOT in stage Closed Lost / Closed WON / Pending Sales - Deposit
    *  ExpectedResult  : Two contacts were merged. Form of the business is updated in Opportunity #1 User is redirected to last E2E step of the Opportunity #1
    *  CreatedDate     : 27/03/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void insertDupConSameDataWithE2EOppATTest() {
        ApexPages.currentPage().getparameters().put('country', 'at');
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Austria';
        Account.ShippingCountry = 'Austria';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Prospecting';
        opportunity.E2E_Active_Step__c = 1;
        opportunity.E2E_Active_Substep__c = 'Search company';
        opportunity.Product__c = '';
        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EFormAT');
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        contact.MailingCountry = 'Austria';
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        controller = new LongFormController();
        controller.activeStep = 0;
        controller.init();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHN';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SMITH';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+431872378123887';
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
        System.assertEquals('+431872378123887', contactList.get(0).Phone, 'Expected Phone from form.');
        System.assertEquals('test@fleetcor.com', contactList.get(0).Email, 'Expected Email from form.');
    }


    /*******************************************************************************
    *  Name            : updateDupConSameDataClosedLostATTest()
    *  Summary         : Verify that two Contacts were merged when First Name + Last Name + Email + Phone are the same and Contact #1 has E2E Opportunity #1 in stage Closed Lost
    *  ExpectedResult  : E2E Opportunity #2 Stage = Closed Lost. Reason = Duplicate. E2E Account #2, E2E Contact #2 were NOT deleted.
                         Contacts were merged. New E2E Account #3, New E2E Opportunity #3 were created. Direct Connections were changed to E2E records
    *  CreatedDate     : 27/03/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void updateDupConSameDataClosedLostATTest() {
        ApexPages.currentPage().getparameters().put('country', 'at');
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Austria';
        Account.ShippingCountry = 'Austria';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Closed Lost';
        opportunity.Product__c = '';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        contact.MailingCountry = 'Austria';
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        controller = new LongFormController();
        controller.activeStep = 0;
        controller.init();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JohnAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SmithAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+431872378123887';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'testAA@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();
        // back to update data
        controller.goToContactDetails();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHN';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SMITH';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+431872378123887';
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
        System.assertEquals('+431872378123887', contactList.get(0).Phone, 'Expected Phone from form.');
        System.assertEquals('test@fleetcor.com', contactList.get(0).Email, 'Expected Email from form.');
    }


    /*******************************************************************************
    *  Name            : updateDupConSameDataProspectingATTest()
    *  Summary         : Verify that two Contacts were merged when First Name + Last Name + Email + Phone are the same and 
                         Contact #1 has E2E Opportunity #1 NOT in stage Closed Lost / Closed WON / Pending Sales - Deposit
    *  ExpectedResult  : E2E Opportunity #2 Stage = Closed Lost. Reason = Duplicate. E2E Account #2, E2E Contact #2 were NOT deleted. Contacts were merged. 
                         User is redirected to the last E2E step of the Opportunity #1
    *  CreatedDate     : 27/03/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void updateDupConSameDataProspectingATTest() {
        ApexPages.currentPage().getparameters().put('country', 'at');
        Account account = E2ELongFormUtilsTest.createAccountDE();
        Account.BillingCountry = 'Austria';
        Account.ShippingCountry = 'Austria';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Prospecting';
        opportunity.Product__c = '';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactForTestingDeduplication(account.Id);
        contact.MailingCountry = 'Austria';
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        controller = new LongFormController();
        controller.activeStep = 0;
        controller.init();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JohnAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SmithAA';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+431111111111111';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'testAA@fleetcor.com';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Company';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'true';
        controller.goToCreditScoring();
        // back to update data
        controller.goToContactDetails();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Mr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'JOHN';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'SMITH';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+431872378123887';
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
        System.assertEquals('+431872378123887', contactList.get(0).Phone, 'Expected Phone from form.');
        System.assertEquals('test@fleetcor.com', contactList.get(0).Email, 'Expected Email from form.');
    }


    /*******************************************************************************
    *  Name            : contactDetailsATTest()
    *  Summary         : Verify all fields on contact details step
    *  CreatedDate     : 28/03/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void contactDetailsATTest() {
        ApexPages.currentPage().getparameters().put('country', 'at');
        controller = new LongFormController();
        controller.init();
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Herr';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Test First Name';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Test Last Name';
        controller.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+431872378123887';
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
        System.assertEquals('+431872378123887', contactList.get(0).Phone, 'Should be value from form.');
        System.assertEquals('test@fleetcor.com', contactList.get(0).Email, 'Should be value from form.');
        System.assertEquals(false, contactList.get(0).Authorised_signatory__c, 'Should be Automatic filling by default.');
        System.assertEquals(true, contactList.get(0).E2E__c, 'Should be Automatic filling by default.');
        System.assertEquals('Austria', contactList.get(0).MailingCountry, 'Should be Automatic filling by default.');
        System.assertEquals('Contact layout', contactList.get(0).RecordType.Name, 'Should be Automatic filling by default.');

        // account
        System.assertEquals(1, contactList.get(0).AccountContactRelations.size(), 'One Account is expected.');
        System.assertEquals('LONGFORM: TEST FIRST NAME TEST LAST NAME', contactList.get(0).AccountContactRelations.get(0).Account.Name, 'Should be value from form.');
        System.assertEquals('Endkunde', contactList.get(0).AccountContactRelations.get(0).Account.RecordType.Name, 'Should be Automatic filling by default.');
        System.assertEquals('Customer', contactList.get(0).AccountContactRelations.get(0).Account.Type, 'Should be Automatic filling by default.');
        System.assertEquals(true, contactList.get(0).AccountContactRelations.get(0).Account.E2E__c, 'Should be Automatic filling by default.');
        System.assertEquals('Austria', contactList.get(0).AccountContactRelations.get(0).Account.BillingCountry, 'Should be Automatic filling by default.');
        System.assertEquals('Austria', contactList.get(0).AccountContactRelations.get(0).Account.ShippingCountry, 'Should be Automatic filling by default.');

        // opportunity
        System.assertEquals(1, contactList.get(0).OpportunityContactRoles.size(), 'One Opportunity is expected.');
        System.assertEquals('LONGFORM: TEST FIRST NAME TEST LAST NAME', contactList.get(0).OpportunityContactRoles.get(0).Opportunity.Name, 'Should be value from form.');
        System.assertEquals('Prospecting', contactList.get(0).OpportunityContactRoles.get(0).Opportunity.StageName, 'Should be Automatic filling by default.');
        System.assertEquals(null, contactList.get(0).OpportunityContactRoles.get(0).Opportunity.Product__c, 'Should be Automatic filling by default.');
        System.assertEquals('German', contactList.get(0).OpportunityContactRoles.get(0).Opportunity.Language_preference__c, 'Should be Automatic filling by default.');
        System.assertEquals('+431872378123887', contactList.get(0).OpportunityContactRoles.get(0).Opportunity.Primary_Contact_Phone__c, 'Should be value from form.');
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
    *  Name            : searchCompanyATTest()
    *  Summary         : Testing flow from Search Company with Mock
    *  CreatedDate     : 28/03/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void searchCompanyATTest() {
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

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EFormAT');
        update opportunity;

        ApexPages.currentPage().getparameters().put('country', 'at');
        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormController();
        controller.init();
        
        controller.stepPagesMap.get('CREDIT SCORE. SEARCH COMPANY').fields.get('COMPANY NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'TEST';
        controller.stepPagesMap.get('CREDIT SCORE. SEARCH COMPANY').fields.get('CITY').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Weimar';
        controller.doSaveCompanyDetailsData();

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new E2ELongFromCreditFactoryMockAT());
            controller.doSearchCompany();
        Test.stopTest();

        controller.editContactDetails();

        List<Account> accountList = [SELECT Name, BillingCity FROM Account WHERE E2E__c = TRUE];
        System.assertEquals('TEST', accountList.get(0).Name);
        System.assertEquals('WEIMAR', accountList.get(0).BillingCity);
    }


    /*******************************************************************************
    *  Name            : verifyAllFieldsAndCreditReportATTest()
    *  Summary         : Verify that Credit Report record was created and updated with info    
    *  CreatedDate     : 28/03/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void verifyAllFieldsAndCreditReportATTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        account.BillingCountry = 'Austria';
        account.ShippingCountry = 'Austria';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Prospecting';
        opportunity.E2E_Active_Step__c = 1;
        opportunity.E2E_Active_Substep__c = 'Calculating credit score';
        opportunity.Product__c = '';
        opportunity.Zahlungsart__c = '';
        opportunity.Rechnungsperiode__c = '';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactDE(account.Id);
        contact.MailingCountry = 'Austria';
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        ApexPages.currentPage().getparameters().put('country', 'at');
        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EFormAT');
        update opportunity;
        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);

        controller = new LongFormController();
        controller.init();
        controller.country = 'Austria';
        controller.activeStep = 1;
        controller.initPageElements();
        controller.initSObjects(opportunity.Id);
        controller.selectedAvailableCompanyCreditScoring = new CreditCompany();
        controller.selectedAvailableCompanyCreditScoring.identificationnumber = '09159152001684';
        controller.deleteReportsForPreviousCompany();

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new E2ELongFromCreditFactoryMockAT());
            controller.goToSetTotalConsumption();
        Test.stopTest();

        controller.cfReportResponse.company.taxnumber = '12-3456789';
        controller.continueToTotalConsumption();

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
                    (SELECT Id FROM Attachments WHERE Name = 'CrefoReport.pdf')
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        // Attachment
        System.assertEquals(1, oppList.get(0).Attachments.size());

        // Opportunity
        System.assertEquals('AT KUNDENTESTSYSTEM AKTIENGESELLSCHAFT - BITTE NICHT ÄNDERN', oppList.get(0).Name, 'Should be Automatic filling by default from CF.');
        System.assertEquals('Prospecting', oppList.get(0).StageName, 'Should be Automatic filling by default.');
        System.assertEquals(0, oppList.get(0).Gasoline_consumption_l_month__c, 'Always should be 0.');
        System.assertEquals(1000, oppList.get(0).Diesel_consumption_l_month__c, 'Shoul be the same as total consumption.');
        System.assertEquals(1000, oppList.get(0).Total_consumption_l_month__c, 'Wrong total consumption.');
        System.assertEquals('Calculating credit score', oppList.get(0).E2E_Active_Substep__c, 'Wrong active substep.');
        System.assertEquals('Report generated', oppList.get(0).CF_Stage__c, 'Should be Automatic filling by default from CF.');
        System.assertEquals('1', oppList.get(0).Credit_System_Rating__c, 'Should be Automatic filling by default from CF.');
        System.assertEquals(null, oppList.get(0).Umsatz__c, 'Should be Automatic filling by default from CF.');
        System.assertEquals('9152001684', oppList.get(0).Credit_System_Number__c, 'Should be Automatic filling by default from CF.');
        System.assertEquals(1, oppList.get(0).E2E_Active_Step__c, 'Should be Automatic filling by default.');
        System.assertEquals(null, oppList.get(0).Gruendungsjahr__c, 'Should be Automatic filling by default from CF.');
        System.assertEquals('2', oppList.get(0).Zahl_der_Mitarbeiter__c, 'Should be Automatic filling by default from CF.');

        // Account 
        System.assertEquals('AT KUNDENTESTSYSTEM AKTIENGESELLSCHAFT - BITTE NICHT ÄNDERN', oppList.get(0).Account.Name, 'Should be Automatic filling by default from CF.');
        System.assertEquals('SALZSTRASSE 46', oppList.get(0).Account.BillingStreet, 'Should be Automatic filling by default from CF.');
        System.assertEquals('2560', oppList.get(0).Account.BillingPostalCode, 'Should be Automatic filling by default from CF.');
        System.assertEquals('BERNDORF', oppList.get(0).Account.BillingCity, 'Should be Automatic filling by default from CF.');
        System.assertEquals('Austria', oppList.get(0).Account.ShippingCountry, 'Should be Automatic filling by default from CF.');
        System.assertEquals('SALZSTRASSE 46', oppList.get(0).Account.ShippingStreet, 'Should be Automatic filling by default from CF.');
        System.assertEquals('2560', oppList.get(0).Account.ShippingPostalCode, 'Should be Automatic filling by default from CF.');
        System.assertEquals('BERNDORF', oppList.get(0).Account.ShippingCity, 'Should be Automatic filling by default from CF.');
        System.assertEquals('Aktiengesellschaft', oppList.get(0).Account.Gesellschaftsform__c, 'Should be Automatic filling by default from CF.');
        System.assertEquals(null, oppList.get(0).Account.Umsatzsteuer_ID__c, 'Should be Automatic filling by default from CF.');
        System.assertEquals('12-3456789', oppList.get(0).Account.Steuernummer__c, 'Should be value from form.');

        // Contact
        System.assertEquals('SALZSTRASSE 46', oppList.get(0).OpportunityContactRoles.get(0).Contact.MailingStreet, 'Should be Automatic filling by default from CF.');
        System.assertEquals('2560', oppList.get(0).OpportunityContactRoles.get(0).Contact.MailingPostalCode, 'Should be Automatic filling by default from CF.');
        System.assertEquals('BERNDORF', oppList.get(0).OpportunityContactRoles.get(0).Contact.MailingCity, 'Should be Automatic filling by default from CF.');
    }


    /*******************************************************************************
    *  Name            : dupLogicProspectingWithSameNameATTest()
    *  Summary         : Verify that two Accounts were merged when Company Names are the same
    *  ExpectedResult  : E2E Account #2 is delete. Account #1 is updated. E2E Opportunity #2 is created. Opportunity #1 Stage = Closed Lost.
                         Reason = Switched to E2E. Notification was sent to the Opportunity Owner
    *  CreatedDate     : 28/03/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void dupLogicCase5ATTest() {
        Account account2 = E2ELongFormUtilsTest.createAccountForTestDuplactes();
        account2.Name = 'AT KUNDENTESTSYSTEM AKTIENGESELLSCHAFT - BITTE NICHT ÄNDERN';
        account2.BillingCountry = 'Austria';
        account2.ShippingCountry = 'Austria';
        account2.Steuernummer__c = '463186478';
        insert account2;

        Opportunity opportunity2 = E2ELongFormUtilsTest.createOpportunityForTestDuplactes(account2.Id);
        opportunity2.Product__c = '';
        insert opportunity2;

        Contact contact2 = E2ELongFormUtilsTest.createContactDE(account2.Id);
        contact2.MailingCountry = 'Austria';
        insert contact2;

        OpportunityContactRole oppContactRole2 = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity2.Id, contact2.Id);
        insert oppContactRole2;

        // create duplicate account
        Account account = E2ELongFormUtilsTest.createAccountForTestDuplactes();
        account.BillingCountry = 'Austria';
        account.ShippingCountry = 'Austria';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityForTestDuplactes(account.Id);
        opportunity.Product__c = '';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactDE(account.Id);
        contact.MailingCountry = 'Austria';
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EFormAT');
        update opportunity;

        ApexPages.currentPage().getparameters().put('country', 'at');
        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormController();
        controller.init();
        controller.selectedAvailableCompanyCreditScoring = new CreditCompany();
        controller.selectedAvailableCompanyCreditScoring.identificationnumber = '09159152001684';
        controller.deleteReportsForPreviousCompany();

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new E2ELongFromCreditFactoryMockAT());
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
    *  Name            : searchDuplicateCase1ATTest()
    *  Summary         : Search duplicate account case #1   
    *  CreatedDate     : 28/03/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void searchDuplicateCase1ATTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        account.BillingCountry = 'Austria';
        account.ShippingCountry = 'Austria';
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
        account2.Name = 'AT KUNDENTESTSYSTEM AKTIENGESELLSCHAFT - BITTE NICHT ÄNDERN';
        account2.BillingCountry = 'Austria';
        account2.ShippingCountry = 'Austria';
        account2.Steuernummer__c = '463186478';
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

        ApexPages.currentPage().getparameters().put('country', 'at');
        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);

        controller = new LongFormController();
        controller.init();
        controller.activeStep = 1;
        controller.initPageElements();
        controller.initSObjects(opportunity.Id);
        controller.selectedAvailableCompanyCreditScoring = new CreditCompany();
        controller.selectedAvailableCompanyCreditScoring.identificationnumber = '09159152001684';
        controller.deleteReportsForPreviousCompany();

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new E2ELongFromCreditFactoryMockAT());
            controller.goToSetTotalConsumption();
        Test.stopTest();

        List<Opportunity> oppList = [SELECT Owner.Name FROM Opportunity WHERE Id = :opportunity.Id];
        System.assertEquals('Y. Aden-Farah', oppList.get(0).Owner.Name);
    }


    /*******************************************************************************
    *  Name            : searchDuplicateCase2ATTest()
    *  Summary         : Search duplicate account case #2   
    *  CreatedDate     : 28/03/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void searchDuplicateCase2ATTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        account.BillingCountry = 'Austria';
        account.ShippingCountry = 'Austria';
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
        account2.Name = 'AT KUNDENTESTSYSTEM AKTIENGESELLSCHAFT - BITTE NICHT ÄNDERN';
        account2.BillingCountry = 'Austria';
        account2.ShippingCountry = 'Austria';
        account2.Steuernummer__c = '463186478';
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

        ApexPages.currentPage().getparameters().put('country', 'at');
        controller = new LongFormController();
        controller.init();
        controller.activeStep = 1;
        controller.initPageElements();
        controller.initSObjects(opportunity.Id);
        controller.selectedAvailableCompanyCreditScoring = new CreditCompany();
        controller.selectedAvailableCompanyCreditScoring.identificationnumber = '09159152001684';
        controller.deleteReportsForPreviousCompany();

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new E2ELongFromCreditFactoryMockAT());
            controller.goToSetTotalConsumption();
        Test.stopTest();

        controller.stepPagesMap.get('CREDIT SCORE. TOTAL CONSUMPTION').fields.get('TOTAL CONSUMPTION').elementItemsMap.get('DEFAULT VALUE').Value__c = '1000';
        controller.doCalculateCreditScoring();

        List<Opportunity> oppList = [SELECT StageName, Gruende_verloren__c FROM Opportunity WHERE Id = :opportunity.Id];
        System.assertEquals('Closed Lost', oppList.get(0).StageName);
        System.assertEquals('Duplicate', oppList.get(0).Gruende_verloren__c);
    }


    /*******************************************************************************
    *  Name            : searchDuplicateCase4ATTest()
    *  Summary         : Search duplicate account case #3   
    *  CreatedDate     : 28/03/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void searchDuplicateCase4ATTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        account.BillingCountry = 'Austria';
        account.ShippingCountry = 'Austria';
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
        account2.Name = 'AT KUNDENTESTSYSTEM AKTIENGESELLSCHAFT - BITTE NICHT ÄNDERN';
        account2.BillingCountry = 'Austria';
        account2.ShippingCountry = 'Austria';
        account2.Steuernummer__c = '463186478';
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

        ApexPages.currentPage().getparameters().put('country', 'at');
        controller = new LongFormController();
        controller.init();
        controller.activeStep = 1;
        controller.initPageElements();
        controller.initSObjects(opportunity.Id);
        controller.selectedAvailableCompanyCreditScoring = new CreditCompany();
        controller.selectedAvailableCompanyCreditScoring.identificationnumber = '09159152001684';
        controller.deleteReportsForPreviousCompany();

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new E2ELongFromCreditFactoryMockAT());
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
    *  Name            : goToCardConfigNonDepositATTest()
    *  Summary         : Verify all fields when you go from 1 step to 2 step 
    *  CreatedDate     : 28/03/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void goToCardConfigNonDepositATTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        account.BillingCountry = 'Austria';
        account.ShippingCountry = 'Austria';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Prospecting';
        opportunity.E2E_Active_Step__c = 1;
        opportunity.E2E_Active_Substep__c = 'Calculating credit score';
        opportunity.Zahlungsart__c = '';
        opportunity.Rechnungsperiode__c = '';
        opportunity.Product__c = '';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactDE(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        ApexPages.currentPage().getparameters().put('country', 'at');

        controller = new LongFormController();
        controller.init();
        controller.country = 'Austria';
        controller.activeStep = 1;
        controller.initPageElements();
        controller.initSObjects(opportunity.Id);
        controller.selectedAvailableCompanyCreditScoring = new CreditCompany();
        controller.selectedAvailableCompanyCreditScoring.identificationnumber = '09159152001684';
        controller.deleteReportsForPreviousCompany();

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new E2ELongFromCreditFactoryMockAT());
            controller.goToSetTotalConsumption();
        Test.stopTest();

        controller.stepPagesMap.get('CREDIT SCORE. TOTAL CONSUMPTION').fields.get('TOTAL CONSUMPTION').elementItemsMap.get('DEFAULT VALUE').Value__c = '1000';
        controller.doCalculateCreditScoring();
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
    *  Name            : goToCardConfigDepositATTest()
    *  Summary         : Verify all fields when you go from 1 step to 2 step 
    *  CreatedDate     : 28/03/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void goToCardConfigDepositATTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        account.BillingCountry = 'Austria';
        account.ShippingCountry = 'Austria';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Prospecting';
        opportunity.E2E_Active_Step__c = 1;
        opportunity.E2E_Active_Substep__c = 'Calculating credit score';
        opportunity.Zahlungsart__c = '';
        opportunity.Rechnungsperiode__c = '';
        opportunity.Product__c = '';
        insert opportunity;

        Contact contact = E2ELongFormUtilsTest.createContactDE(account.Id);
        insert contact;

        OpportunityContactRole oppContactRole = E2ELongFormUtilsTest.createOpportunityContactRoleDE(opportunity.Id, contact.Id);
        insert oppContactRole;

        ApexPages.currentPage().getparameters().put('country', 'at');

        controller = new LongFormController();
        controller.init();
        controller.country = 'Austria';
        controller.activeStep = 1;
        controller.initPageElements();
        controller.initSObjects(opportunity.Id);
        controller.selectedAvailableCompanyCreditScoring = new CreditCompany();
        controller.selectedAvailableCompanyCreditScoring.identificationnumber = '09159152001684';
        controller.deleteReportsForPreviousCompany();

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new E2ELongFromCreditFactoryMockAT());
            controller.goToSetTotalConsumption();
        Test.stopTest();

        controller.stepPagesMap.get('CREDIT SCORE. TOTAL CONSUMPTION').fields.get('TOTAL CONSUMPTION').elementItemsMap.get('DEFAULT VALUE').Value__c = '1000';
        controller.doCalculateCreditScoring();
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
    *  Name            : cardConfigurationWithThreeCardsATTest()
    *  Summary         : Testing card configuration step, add 3 diff card   
    *  CreatedDate     : 28/03/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void cardConfigurationWithThreeCardsATTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        account.BillingCountry = 'Austria';
        account.ShippingCountry = 'Austria';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.E2E_Active_Step__c = 2;
        opportunity.E2E_Active_Substep__c = 'Card configuration';
        opportunity.Product__c = '';
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

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EFormAT');
        update opportunity;

        ApexPages.currentPage().getparameters().put('country', 'at');
        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormController();
        controller.cardsConfigService = LongFormGlobalUtils.returnCardsConfigService('Austria');
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
    *  Name            : choosingOfferATTest()
    *  Summary         : Testing choosing offer step    
    *  CreatedDate     : 28/03/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void choosingOfferATTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        account.BillingCountry = 'Austria';
        account.ShippingCountry = 'Austria';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.E2E_Active_Step__c = 2;
        opportunity.E2E_Active_Substep__c = 'Choosing offer';
        opportunity.Product__c = '';
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

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EFormAT');
        update opportunity;

        ApexPages.currentPage().getparameters().put('country', 'at');
        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        ApexPages.currentPage().getParameters().put('offerName', 'Home Station offer (v.1)');
        controller = new LongFormController();
        controller.cardsConfigService = LongFormGlobalUtils.returnCardsConfigService('Austria');
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
    *  Name            : technicalParametersATTest()
    *  Summary         : Testing technical parameters step    
    *  CreatedDate     : 28/03/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void technicalParametersATTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        account.BillingCountry = 'Austria';
        account.ShippingCountry = 'Austria';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.E2E_Active_Step__c = 2;
        opportunity.E2E_Active_Substep__c = 'Technical parameters';
        opportunity.Product__c = 'Home Station offer (v.1)';
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

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EFormAT');
        update opportunity;

        ApexPages.currentPage().getparameters().put('country', 'at');
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
        controller.stepPagesMap.get('CARD CONFIGURATION. INPUT VAT ID').fields.get('VAT NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = 'ATU69120514';
        controller.updateVatNumberAndGoToAdditionalStep();
        
        Test.startTest();
            Test.setMock(WebServiceMock.class, new EcEuropaEuMock());
            // valid vat number
            controller.stepPagesMap.get('CARD CONFIGURATION. INPUT VAT ID').fields.get('VAT NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = 'ATU69120514';
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
        System.assertEquals('ATU69120514', opportunityList.get(0).Account.Umsatzsteuer_ID__c, 'Wrong VAT ID.');
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
    *  Name            : additionalStepATTest()
    *  Summary         : Testing additional step    
    *  CreatedDate     : 28/03/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void additionalStepATTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        account.BillingCountry = 'Austria';
        account.ShippingCountry = 'Austria';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.StageName = 'Pending Credit Check';
        opportunity.E2E_Active_Step__c = 3;
        opportunity.E2E_Active_Substep__c = 'Additional services';
        opportunity.E2E_Form_of_Business__c = 'Solo-trader';
        opportunity.Product__c = 'Home Station offer (v.1)';
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

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EFormAT');
        update opportunity;

        ApexPages.currentPage().getparameters().put('country', 'at');
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
                SELECT Eco_Fee__c, E2E_Active_Step__c, StageName, E2E_Active_Substep__c, VAT_Recovery__c, Agree_to_VAT_Recovery_TC__c,
                    (SELECT Contact.Birthdate FROM OpportunityContactRoles)
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals(true, oppList.get(0).Eco_Fee__c);
        System.assertEquals('Credit approved', oppList.get(0).StageName);
        System.assertEquals(4, oppList.get(0).E2E_Active_Step__c);
        System.assertEquals('DirectDebit', oppList.get(0).E2E_Active_Substep__c);
        System.assertEquals(false, oppList.get(0).VAT_Recovery__c);
        System.assertEquals(false, oppList.get(0).Agree_to_VAT_Recovery_TC__c);
        System.assertNotEquals(null, oppList.get(0).OpportunityContactRoles.get(0).Contact.Birthdate);
    }


    /*******************************************************************************
    *  Name            : paymentOptionsDirectDebitATTest()
    *  Summary         : Testing payment options step    
    *  CreatedDate     : 28/03/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void paymentOptionsDirectDebitATTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        account.BillingCountry = 'Austria';
        account.ShippingCountry = 'Austria';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.E2E_Active_Substep__c = 'DirectDebit';
        opportunity.E2E_Active_Step__c = 4;
        opportunity.Name_of_the_payer_Account_holder__c = '';
        opportunity.IBAN__c = '';
        opportunity.SWIFT_BIC__c = '';
        opportunity.Product__c = 'Home Station offer (v.1)';
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

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EFormAT');
        update opportunity;

        Attachment attachment = E2ELongFormUtilsTest.createAttachment('SEPAMandate.pdf', opportunity.Id);
        insert attachment;

        ApexPages.currentPage().getparameters().put('country', 'at');
        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormController();
        controller.init();
        controller.activeStep = 4;
        controller.activeSubStep = 'DirectDebit';
        controller.stepPagesMap.get('PAYMENT OPTIONS').fields.get('ACCOUNT HOLDER').elementItemsMap.get('VALUE').Value__c = 'CONOR MCGREGOR';
        controller.stepPagesMap.get('PAYMENT OPTIONS').fields.get('IBAN').elementItemsMap.get('VALUE').Value__c = 'AT112050306800004332';
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
        System.assertEquals('AT112050306800004332', oppList.get(0).IBAN__c);
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
    *  Name            : bankTransferNonDepositATTest()
    *  Summary         : Testing payment options step    
    *  CreatedDate     : 28/03/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void bankTransferNonDepositATTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        account.BillingCountry = 'Austria';
        account.ShippingCountry = 'Austria';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.E2E_Active_Substep__c = 'BankTransfer';
        opportunity.Name_of_the_payer_Account_holder__c = '';
        opportunity.IBAN__c = '';
        opportunity.SWIFT_BIC__c = '';
        opportunity.Product__c = 'Home Station offer (v.1)';
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

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EFormAT');
        update opportunity;

        Attachment attachment = E2ELongFormUtilsTest.createAttachment('SEPAMandate.pdf', opportunity.Id);
        insert attachment;

        ApexPages.currentPage().getparameters().put('country', 'at');
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
        System.assertEquals('NO DEPOSIT', oppList.get(0).E2E_payment_status__c);
    }


    /*******************************************************************************
    *  Name            : bankTransferDepositATTest()
    *  Summary         : Testing payment options step    
    *  CreatedDate     : 28/03/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void bankTransferDepositATTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        account.BillingCountry = 'Austria';
        account.ShippingCountry = 'Austria';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.E2E_Active_Substep__c = 'BankTransferDeposit';
        opportunity.Name_of_the_payer_Account_holder__c = '';
        opportunity.IBAN__c = '';
        opportunity.SWIFT_BIC__c = '';
        opportunity.Product__c = 'Home Station offer (v.1)';
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

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EFormAT');
        update opportunity;

        Attachment attachment = E2ELongFormUtilsTest.createAttachment('DepositAgreement.pdf', opportunity.Id);
        insert attachment;

        ApexPages.currentPage().getparameters().put('country', 'at');
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
    *  Name            : paymentOptionsDirectDebitDepositATTest()
    *  Summary         : Testing Direct Debit Deposit
    *  CreatedDate     : 28/03/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void paymentOptionsDirectDebitDepositATTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        account.BillingCountry = 'Austria';
        account.ShippingCountry = 'Austria';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.Product__c = 'Home Station offer (v.1)';
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

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EFormAT');
        update opportunity;

        Attachment attachment = E2ELongFormUtilsTest.createAttachment('DepositAgreement.pdf', opportunity.Id);
        insert attachment;

        ApexPages.currentPage().getparameters().put('country', 'at');
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
    *  Name            : congratulationPendingSalesDepositATTest()
    *  Summary         : Go to congratulation step test pending sales - deposit    
    *  CreatedDate     : 28/03/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void congratulationPendingSalesDepositATTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        account.BillingCountry = 'Austria';
        account.ShippingCountry = 'Austria';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.Product__c = 'Home Station offer (v.1)';
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

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EFormAT');
        update opportunity;

        ApexPages.currentPage().getparameters().put('country', 'at');
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
    *  Name            : returnToCongratulationATTest()
    *  Summary         : Testing return to congratulation test (Step 5)  
    *  CreatedDate     : 28/03/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void returnToCongratulationATTest() {
        Account account = E2ELongFormUtilsTest.createAccountDE();
        account.BillingCountry = 'Austria';
        account.ShippingCountry = 'Austria';
        insert account;

        Opportunity opportunity = E2ELongFormUtilsTest.createOpportunityDE(account.Id);
        opportunity.E2E_Active_Step__c = 5;
        opportunity.E2E_payment_status__c = 'Accept';
        opportunity.Product__c = 'Home Station offer (v.1)';
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

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EFormAT');
        update opportunity;

        ApexPages.currentPage().getparameters().put('country', 'at');
        ApexPages.currentPage().getparameters().put('source', opportunity.E2E_Encoded_URL__c);
        controller = new LongFormController();
        controller.init();
    }
}