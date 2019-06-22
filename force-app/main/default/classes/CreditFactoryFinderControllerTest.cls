@isTest
private class CreditFactoryFinderControllerTest {
    public static CreditFactoryFinderController controller;        

    //Credireform
    /*******************************************************************************
    *  Name            : testOpportunityId()
    *  Summary         : Put null id in opportunity
    *  CreatedDate     : 11/11/2016
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testOpportunityId() {
        CreditFactoryException creditFactoryException = new CreditFactoryException();
        Account account = CreditFactoryUtils.doCreateCreditreformAccount();
        ApexPages.currentPage().getParameters().put('id', account.Id);
        controller = new CreditFactoryFinderController();
        controller.init();
        System.assertEquals(ApexPages.getMessages().get(0).getSummary(), 'Invalid record id.');
    }


    /*******************************************************************************
    *  Name            : testInvalidSelectedOpportunity()
    *  Summary         : Leave country field is empty
    *  CreatedDate     : 11/11/2016
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testInvalidSelectedOpportunity() {
        Account account = CreditFactoryUtils.doCreateCreditreformAccount();
        account.BillingCountry = '';
        account.BillingState = '';
        insert account;
        Opportunity opportunity = CreditFactoryUtils.doCreateOpportunity(account.Id);
        insert opportunity;
        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        controller = new CreditFactoryFinderController();
        controller.init();
        System.assertEquals(ApexPages.getMessages().get(0).getSummary(), 'Please add Billing Country to Account.');
    }


    /*******************************************************************************
    *  Name            : testInvalidSelectedCreditSystem()
    *  Summary         : Chek field Supported_Countries__c of CreditSystem empty or not
    *  CreatedDate     : 11/11/2016
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testInvalidSelectedCreditSystem() {
        //No credit system
        Account account = CreditFactoryUtils.doCreateCreditreformAccount();
        account.BillingCountry = 'Germany';
        insert account;
        Opportunity opportunity = CreditFactoryUtils.doCreateOpportunity(account.Id);
        insert opportunity;
        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        controller = new CreditFactoryFinderController();
        controller.init();
        System.assertEquals(ApexPages.getMessages().get(0).getSummary(), 'Select Credit System Settings failed. Please check Billing Country or contact your administrator.');

        //Credit system exist. Credit system name not equals to CreditReformWebService.CREDIT_SYSTEM_NAME
        CreditSystem__c creditSystem = CreditFactoryUtils.doCreateCreditSystem();
        creditSystem.Supported_Countries__c = 'Germany';
        creditSystem.Name = 'Test';
        insert creditSystem;
        controller.init();
        System.assertEquals('Invalid name for Credit setting.', ApexPages.getMessages().get(1).getSummary());
    }


    /*******************************************************************************
    *  Name            : testInvalidMappingCreditreform()
    *  Summary         : Check if Account and Opportunity mapping exist or not
    *  CreatedDate     : 14/11/2016 
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testInvalidMappingCreditreform() {
        Account account = CreditFactoryUtils.doCreateCreditreformAccount();
        account.BillingCountry = 'Germany';
        insert account;
        Opportunity opportunity = CreditFactoryUtils.doCreateOpportunity(account.Id);
        insert opportunity;
        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        Credit_Factory_Account__c creditFactoryAccount = new Credit_Factory_Account__c(Name = 'Test');
        insert creditFactoryAccount;
        Credit_Factory_Opportunity__c creditFactoryOpportunity = new Credit_Factory_Opportunity__c(Name = 'Test');
        insert creditFactoryOpportunity;
        CreditSystem__c creditSystem = CreditFactoryUtils.doCreateCreditSystem();
        creditSystem.Supported_Countries__c = 'Germany';
        creditSystem.Name = 'Creditreform';
        insert creditSystem;
        controller = new CreditFactoryFinderController();
        controller.init();
        System.assertEquals(ApexPages.getMessages().get(0).getSummary(), 'Account mapping select error. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        creditFactoryAccount.Name = 'Creditreform';
        update creditFactoryAccount;
        controller.init();
        System.assertEquals(ApexPages.getMessages().get(1).getSummary(), 'Opportunity mapping select error. ' + CreditFactoryUtilities.CONTACT_ADMIN);
    }


    /******************************************************************************
    *  Name            : testValidateMappingCreditreform()
    *  Summary         : Check filling Credit_Factory_Account__c and Credit_Factory__c fileds   
    *  CreatedDate     : 15/11/2016
    *  Parameters      : 
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testValidateMappingCreditreform() {
        Account account = CreditFactoryUtils.doCreateCreditreformAccount();
        account.BillingCountry = 'Germany';
        insert account;
        Opportunity opportunity = CreditFactoryUtils.doCreateOpportunity(account.Id);
        insert opportunity;
        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.doCreateCreditFactoryAccount();
        creditFactoryAccount.Name = 'Creditreform';
        creditFactoryAccount.Company_Form__c = '';
        insert creditFactoryAccount;
        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.doCreateCreditFactoryOpportunity();
        creditFactoryOpportunity.Name = 'Creditreform';
        creditFactoryOpportunity.Product__c = '';
        insert creditFactoryOpportunity;
        CreditSystem__c creditSystem = CreditFactoryUtils.doCreateCreditSystem();
        creditSystem.Supported_Countries__c = 'Germany';
        creditSystem.Name = 'Creditreform';
        insert creditSystem;
        controller = new CreditFactoryFinderController();
        controller.init();
        System.assertEquals(ApexPages.getMessages().get(0).getSummary(), 'All fields in Account mapping should not be null. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        creditFactoryAccount.Company_Form__c = 'test';
        update creditFactoryAccount;
        controller.init();
        System.assertEquals(ApexPages.getMessages().get(1).getSummary(), 'All fields in Opportunity mapping should not be null. ' + CreditFactoryUtilities.CONTACT_ADMIN);
    }


    /***************************************************************************
    *  Name            : testInvalidCurrentOpportunityCreditreform()
    *  Summary         : Check selecting opportunity with fields from mapping
    *  CreatedDate     : 15/11/2016
    *  Parameters      : 
    *  Returns         : void 
    **************************************************************************/
    @isTest
    public static void testInvalidCurrentOpportunityCreditreform() {
        Account account = CreditFactoryUtils.doCreateCreditreformAccount();
        account.BillingCountry = 'Germany';
        insert account;
        Opportunity opportunity = CreditFactoryUtils.doCreateOpportunity(account.Id);
        insert opportunity;
        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.doCreateCreditFactoryAccount();
        creditFactoryAccount.Name = 'Creditreform';
        creditFactoryAccount.Company_Form__c = 'test';
        insert creditFactoryAccount;
        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.doCreateCreditFactoryOpportunity();
        creditFactoryOpportunity.Name = 'Creditreform';
        insert creditFactoryOpportunity;
        CreditSystem__c creditSystem = CreditFactoryUtils.doCreateCreditSystem();
        creditSystem.Supported_Countries__c = 'Germany';
        creditSystem.Name = 'Creditreform';
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        controller = new CreditFactoryFinderController();
        controller.init();
        System.assertEquals(ApexPages.getMessages().get(0).getSummary(), 'Select Opportunity failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
    }


    /******************************************************************************
    *  Name            : testOpportunityForClosedCreditreform()
    *  Summary         : Check Opportunity Status for Closed Won/Lost
    *  CreatedDate     : 15/11/2016
    *  Parameters      : 
    *  Returns         : void
    *****************************************************************************/
    @isTest 
    public static void testOpportunityForClosedCreditreform() {
        Account account = CreditFactoryUtils.doCreateCreditreformAccount();
        account.BillingCountry = 'Germany';
        insert account;
        Opportunity opportunity = CreditFactoryUtils.doCreateOpportunity(account.Id);
        opportunity.StageName = 'Closed Won';
        insert opportunity;
        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.doCreateCreditFactoryAccount();
        creditFactoryAccount.Name = 'Creditreform';
        insert creditFactoryAccount;
        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.doCreateCreditFactoryOpportunity();
        creditFactoryOpportunity.Name = 'Creditreform';
        insert creditFactoryOpportunity;
        CreditSystem__c creditSystem = CreditFactoryUtils.doCreateCreditSystem();
        creditSystem.Supported_Countries__c = 'Germany';
        creditSystem.Name = 'Creditreform';
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        controller = new CreditFactoryFinderController();
        controller.init();
        System.assertEquals(ApexPages.getMessages().get(0).getSummary(), 'Opportunity was already closed.');
    }


    /*****************************************************************************
    *  Name            : testValidateBlackListCreditreform()
    *  Summary         : Test required fields for Account and Opportunity to null pointer
    *  CreatedDate     : 25/11/2016
    *  Parameters      : 
    *  Returns         : void
    ****************************************************************************/
    @isTest
    public static void testValidateBlackListCreditreform() {
        RecordType euroshellRecordType = [
                SELECT Name
                FROM RecordType
                WHERE Name = 'Euroshell'];
        Account account = CreditFactoryUtils.doCreateCreditreformAccount();
        account.BillingCountry = 'Germany';
        insert account;
        Opportunity opportunity = CreditFactoryUtils.doCreateOpportunity(account.Id);
        opportunity.StageName = 'Perception Analysis';
        opportunity.RecordTypeId = euroshellRecordType.Id;
        opportunity.IBAN_des_Zahlungspflichtigen__c = 'DE40632901100396751008';
        insert opportunity;
        Contact contact = CreditFactoryUtils.doCreateContact(opportunity.accountId);
        insert contact;
        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.doCreateCreditFactoryAccount();
        creditFactoryAccount.Name = 'Creditreform';
        insert creditFactoryAccount;
        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.doCreateCreditFactoryOpportunity();
        creditFactoryOpportunity.Name = 'Creditreform';
        insert creditFactoryOpportunity;
        CreditSystem__c creditSystem = CreditFactoryUtils.doCreateCreditSystem();
        creditSystem.Supported_Countries__c = 'Germany';
        creditSystem.Name = 'Creditreform';
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Credit_Black_List_Company__c blackList = CreditFactoryUtils.doCreateCreditBlackListCompany(account.Name);
        blackList.Customer_Id__c = 'DE';
        insert blackList;
        controller = new CreditFactoryFinderController();
        controller.init();
        System.assertEquals(true, ApexPages.getMessages().get(0).getSummary().contains('Company found in black list. Please refer to credit.'));
    }
    

    /*******************************************************************************
    *  Name            : testValidateRequiredFieldsCreditreform()
    *  Summary         : Test required fields for Account and Opportunity to null pointer
    *  CreatedDate     : 16/11/2016
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testValidateRequiredFieldsCreditreform() {
        RecordType euroshellRecordType = [
                SELECT Name
                FROM RecordType
                WHERE Name = 'Euroshell'];
        Account account = CreditFactoryUtils.doCreateCreditreformAccount();
        account.BillingCountry = 'Germany';
        account.Beschaeftigte__c = '';
        insert account;
        Opportunity opportunity = CreditFactoryUtils.doCreateOpportunity(account.Id);
        opportunity.StageName = 'Perception Analysis';
        opportunity.RecordTypeId = euroshellRecordType.Id;
        opportunity.IBAN_des_Zahlungspflichtigen__c = 'DE40632901100396751008';
        insert opportunity;
        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.doCreateCreditFactoryAccount();
        creditFactoryAccount.Name = 'Creditreform';
        insert creditFactoryAccount;
        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.doCreateCreditFactoryOpportunity();
        creditFactoryOpportunity.Name = 'Creditreform';
        insert creditFactoryOpportunity;
        CreditSystem__c creditSystem = CreditFactoryUtils.doCreateCreditSystem();
        creditSystem.Supported_Countries__c = 'Germany';
        creditSystem.Name = 'Creditreform';
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.doCreateCreditSystemSalesProfile();
        insert creditSystemSalesProfile;
        controller = new CreditFactoryFinderController();
        controller.init();
        System.assertEquals(ApexPages.getMessages().get(0).getSummary(), 'Please fill required fields: Account: Employee*');
        opportunity.Kraftstoffverbrauch_Liter_Monat__c = 000;
        update opportunity;
        creditFactoryOpportunity.Fuel_consumption_l_month__c = 'test';
        update creditFactoryOpportunity;
        controller.init();
        System.assertEquals(ApexPages.getMessages().get(1).getSummary(), 'Error parsing sObject. Please contact your administrator.');
        account.Beschaeftigte__c = 'test';
        update account;
        opportunity.Anzahl_der_Karten__c = null;
        opportunity.StageName = 'Needs Analysis';
        update opportunity;
        controller.init(); 
        System.assertEquals(ApexPages.getMessages().get(2).getSummary(), 'Please fill required fields: Opportunity: Number of Cards*');
        opportunity.Anzahl_der_Karten__c = 000;
        update opportunity;
        creditFactoryOpportunity.Number_of_Cards__c = 'test';
        update creditFactoryOpportunity;
        controller.init();
        System.assertEquals(ApexPages.getMessages().get(1).getSummary(), 'Error parsing sObject. Please contact your administrator.');
    }


    /*******************************************************************************
    *  Name            : testProcessedOpportunityValidationCreditreform()
    *  Summary         : Fill Processed by field.
    *  CreatedDate     : 19/01/2017
    *  ModifiedDate    : 19/01/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testProcessedOpportunityValidationCreditreform() {
        Account account = CreditFactoryUtils.doCreateCreditreformAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.doCreateOpportunity(account.Id);
        opportunity.bearbeitet_von__c = 'Autoprocessed by Sales';
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        
        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.doCreateCreditFactoryAccount();
        creditFactoryAccount.Name = 'Creditreform';
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.doCreateCreditFactoryOpportunity();
        creditFactoryOpportunity.Name = 'Creditreform';
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.doCreateCreditSystem();
        creditSystem.Supported_Countries__c = 'Germany';
        creditSystem.Name = 'Creditreform';
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            controller = new CreditFactoryFinderController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Opportunity is already processed.', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testCheckDuplicatesCreditreform()
    *  Summary         : test check duplicate opportunities, accounts and contacts
    *  CreatedDate     : 16/11/2016
    *  ModifiedDate    : 26/01/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testCheckDuplicatesCreditreform() {
        List<Account> accountsList = new List<Account>();
        Account account = CreditFactoryUtils.createCreditReformAccount();
        accountsList.add(account);
        Account duplicateAccount = CreditFactoryUtils.createCreditReformAccount();
        duplicateAccount.Steuernummer__c = '123123123';
        accountsList.add(duplicateAccount);
        insert accountsList;

        List<Opportunity> opportunitiesList = new List<Opportunity>();
        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunity(account.Id);
        opportunitiesList.add(opportunity);
        Opportunity duplicateOpportunity = CreditFactoryUtils.createCreditreformOpportunity(duplicateAccount.Id);
        opportunitiesList.add(duplicateOpportunity);
        insert opportunitiesList;

        List<Contact> contactsList = new List<Contact>();
        Contact contact = CreditFactoryUtils.createCreditreformContact(account.Id);
        contactsList.add(contact);
        Contact duplicateContact = CreditFactoryUtils.createCreditreformContact(duplicateAccount.Id);
        contactsList.add(duplicateContact);
        insert contactsList;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.doCreateCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        OpportunityContactRole opportunityContactRole = CreditFactoryUtils.createCreditreformOpportunityContactRole(contact.Id, opportunity.Id);
        insert opportunityContactRole;

        Test.startTest();
            controller = new CreditFactoryFinderController();
            controller.init();
        Test.stopTest();

        System.assertEquals(true, String.valueOf(ApexPages.getMessages().get(0)).contains('Duplicate Accounts found'));
        System.assertEquals(true, String.valueOf(ApexPages.getMessages().get(0)).contains('Duplicate Opportunities found'));
        System.assertEquals(true, String.valueOf(ApexPages.getMessages().get(0)).contains('Duplicate Contacts found'));
    }


    /*******************************************************************************
    *  Name            : testDoInitialOrder()
    *  Summary         : test do order in case of no company mathes
    *  CreatedDate     : 19/12/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest 
    public static void testDoInitialOrder() {
        Account account = CreditFactoryUtils.doCreateCreditreformAccount();
        account.BillingCountry = 'Germany';
        insert account;
        Opportunity opportunity = CreditFactoryUtils.doCreateOpportunity(account.Id);
        insert opportunity;
        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        ApexPages.currentPage().getParameters().put('companyIndex', '0');
        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.doCreateCreditFactoryAccount();
        creditFactoryAccount.Name = 'Creditreform';
        insert creditFactoryAccount;
        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.doCreateCreditFactoryOpportunity();
        creditFactoryOpportunity.Name = 'Creditreform';
        insert creditFactoryOpportunity;
        CreditSystem__c creditSystem = CreditFactoryUtils.doCreateCreditSystem();
        creditSystem.Supported_Countries__c = 'Germany';
        creditSystem.Name = 'Creditreform';
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            controller = new CreditFactoryFinderController();
            Test.setMock(HttpCalloutMock.class, new CreditreformOrderMock());
            controller.init();
        Test.stopTest();

        List<Opportunity> opportunitiesList = [
                SELECT CF_Order_Reference_Number__c, CF_Stage__c
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals('100000001', opportunitiesList.get(0).CF_Order_Reference_Number__c);
        System.assertEquals('Pending Credit Report - Order was sent', opportunitiesList.get(0).CF_Stage__c);
    }


    /*******************************************************************************
    *  Name            : testInvalidSearchCompanyCreditreform()
    *  Summary         : Check fail search company, isSales = false
    *  CreatedDate     : 16/11/2016
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testInvalidSearchCompanyCreditreform() {
        Account account = CreditFactoryUtils.doCreateCreditreformAccount();
        account.BillingCountry = 'Germany';
        insert account;
        Opportunity opportunity = CreditFactoryUtils.doCreateOpportunity(account.Id);
        insert opportunity;
        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.doCreateCreditFactoryAccount();
        creditFactoryAccount.Name = 'Creditreform';
        insert creditFactoryAccount;
        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.doCreateCreditFactoryOpportunity();
        creditFactoryOpportunity.Name = 'Creditreform';
        insert creditFactoryOpportunity;
        CreditSystem__c creditSystem = CreditFactoryUtils.doCreateCreditSystem();
        creditSystem.Supported_Countries__c = 'Germany';
        creditSystem.Name = 'Creditreform';
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
        controller = new CreditFactoryFinderController();
        Test.setMock(HttpCalloutMock.class, new ErrorCreditreformSearchMock());
        controller.init();
        Test.stopTest();
        System.assertEquals(ApexPages.getMessages().get(0).getSummary(), 'Search company failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
    }


    /*******************************************************************************
    *  Name            : testValidSearchCompanyCreditreform()
    *  Summary         : Check success search company
    *  CreatedDate     : 17/11/2016
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    @isTest 
    public static void testValidSearchCompanyCreditreform() {
        Account account = CreditFactoryUtils.doCreateCreditreformAccount();
        account.BillingCountry = 'Germany';
        insert account;
        Opportunity opportunity = CreditFactoryUtils.doCreateOpportunity(account.Id);
        insert opportunity;
        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        ApexPages.currentPage().getParameters().put('companyIndex', '0');
        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.doCreateCreditFactoryAccount();
        creditFactoryAccount.Name = 'Creditreform';
        insert creditFactoryAccount;
        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.doCreateCreditFactoryOpportunity();
        creditFactoryOpportunity.Name = 'Creditreform';
        insert creditFactoryOpportunity;
        CreditSystem__c creditSystem = CreditFactoryUtils.doCreateCreditSystem();
        creditSystem.Supported_Countries__c = 'Germany';
        creditSystem.Name = 'Creditreform';
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
        controller = new CreditFactoryFinderController();
        Test.setMock(HttpCalloutMock.class, new CreditreformSearchMock());
        controller.init();
        Test.stopTest();
        controller.selectCompanyForReport();
        controller.backToOpporutnity();
        controller.setInvalidSearch();
    }


    /*******************************************************************************
    *  Name            : testSelectInactiveCompanyCreditreform()
    *  Summary         : Select inactive company from the list.    
    *  CreatedDate     : 27/04/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testSelectInactiveCompanyCreditreform() {
        Account account = CreditFactoryUtils.createCreditReformAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        ApexPages.currentPage().getParameters().put('companyIndex', '0');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createCreditreformAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createCreditreformOpportunityMapping();
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            controller = new CreditFactoryFinderController();
            Test.setMock(HttpCalloutMock.class, new CreditreformSearchInactiveCompanyMock());
            controller.init();
            controller.selectCompanyForReport();
        Test.stopTest();

        System.assertEquals(ApexPages.getMessages().get(0).getSummary(), 'Selected company is not active. Opportunity is closed as lost.');
    }


    /*******************************************************************************
    *  Name            : testExistingCompanyCreditreform()
    *  Summary         : Check success search company
    *  CreatedDate     : 25/10/2017
    *  ModifiedDate    : 25/10/2017
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    @isTest 
    public static void testExistingCompanyCreditreform() {
        Account account = CreditFactoryUtils.doCreateCreditreformAccount();
        account.BillingCountry = 'Germany';
        insert account;
        Opportunity opportunity = CreditFactoryUtils.doCreateOpportunity(account.Id);
        insert opportunity;
        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        ApexPages.currentPage().getParameters().put('companyIndex', '0');
        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.doCreateCreditFactoryAccount();
        creditFactoryAccount.Name = 'Creditreform';
        insert creditFactoryAccount;
        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.doCreateCreditFactoryOpportunity();
        creditFactoryOpportunity.Name = 'Creditreform';
        insert creditFactoryOpportunity;
        CreditSystem__c creditSystem = CreditFactoryUtils.doCreateCreditSystem();
        creditSystem.Supported_Countries__c = 'Germany';
        creditSystem.Name = 'Creditreform';
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Credit_Factory_Report__c creditReport = CreditFactoryUtils.doCreateCreditreformReport();
        creditReport.Opportunity__c = opportunity.Id;
        creditReport.Company_Id__c = '123';
        insert creditReport;
        Credit_Factory_Report_Employee__c creditReportEmployee = CreditFactoryUtils.doCreateCreditreformReportEmployee();
        creditReportEmployee.Credit_Factory_Report__c = creditReport.Id;
        insert creditReportEmployee;
        Test.startTest();
            controller = new CreditFactoryFinderController();
            Test.setMock(HttpCalloutMock.class, new CreditreformSearchMock());
            controller.init();
        Test.stopTest();
    }


    //CreditSafe
    /*******************************************************************************
    *  Name            : testInvalidMappingCreditsafe()
    *  Summary         : Check if Account and Opportunity mapping exist or not
    *  CreatedDate     : 22/11/2016 
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testInvalidMappingCreditsafe() {
        Account account = CreditFactoryUtils.doCreateCreditsafeAccount();
        account.BillingCountry = 'Germany';
        insert account;
        Opportunity opportunity = CreditFactoryUtils.doCreateOpportunity(account.Id);
        insert opportunity;
        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        Credit_Factory_Account__c creditFactoryAccount = new Credit_Factory_Account__c(Name = 'Test');
        insert creditFactoryAccount;
        Credit_Factory_Opportunity__c creditFactoryOpportunity = new Credit_Factory_Opportunity__c(Name = 'Test');
        insert creditFactoryOpportunity;
        CreditSystem__c creditSystem = CreditFactoryUtils.doCreateCreditSystem();
        creditSystem.Supported_Countries__c = 'Germany';
        creditSystem.Name = 'Creditsafe';
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        controller = new CreditFactoryFinderController();
        controller.init();
        System.assertEquals(ApexPages.getMessages().get(0).getSummary(), 'Account mapping select error. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        creditFactoryAccount.Name = 'Creditsafe';
        update creditFactoryAccount;
        controller.init();
        System.assertEquals(ApexPages.getMessages().get(1).getSummary(), 'Opportunity mapping select error. ' + CreditFactoryUtilities.CONTACT_ADMIN);
    }


    /*******************************************************************************
    *  Name            : testValidateMappingCreditsafe()
    *  Summary         : Check filling Credit_Factory_Account__c and Credit_Factory__c fileds   
    *  CreatedDate     : 22/11/2016
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testValidateMappingCreditsafe() {
        Account account = CreditFactoryUtils.doCreateCreditsafeAccount();
        account.BillingCountry = 'Germany';
        insert account;
        Opportunity opportunity = CreditFactoryUtils.doCreateOpportunity(account.Id);
        insert opportunity;
        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.doCreateCreditFactoryAccount();
        creditFactoryAccount.Name = 'Creditsafe';
        creditFactoryAccount.Company_Form__c = '';
        insert creditFactoryAccount;
        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.doCreateCreditFactoryOpportunity();
        creditFactoryOpportunity.Name = 'Creditsafe';
        creditFactoryOpportunity.Product__c = '';
        insert creditFactoryOpportunity;
        CreditSystem__c creditSystem = CreditFactoryUtils.doCreateCreditSystem();
        creditSystem.Supported_Countries__c = 'Germany';
        creditSystem.Name = 'Creditsafe';
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        controller = new CreditFactoryFinderController();
        controller.init();
        System.assertEquals(ApexPages.getMessages().get(0).getSummary(), 'All fields in Account mapping should not be null. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        creditFactoryAccount.Company_Form__c = 'test';
        update creditFactoryAccount;
        controller.init();
        System.assertEquals(ApexPages.getMessages().get(1).getSummary(), 'All fields in Opportunity mapping should not be null. ' + CreditFactoryUtilities.CONTACT_ADMIN);
    }


    /***************************************************************************
    *  Name            : testInvalidCurrentOpportunityCreditsafe()
    *  Summary         : Check selecting opportunity with fields from mapping
    *  CreatedDate     : 22/11/2016
    *  Parameters      : 
    *  Returns         : void 
    **************************************************************************/
    @isTest
    public static void testInvalidCurrentOpportunityCreditsafe() {
        Account account = CreditFactoryUtils.doCreateCreditsafeAccount();
        account.BillingCountry = 'Germany';
        insert account;
        Opportunity opportunity = CreditFactoryUtils.doCreateOpportunity(account.Id);
        insert opportunity;
        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.doCreateCreditFactoryAccount();
        creditFactoryAccount.Name = 'Creditsafe';
        creditFactoryAccount.Company_Form__c = 'test';
        insert creditFactoryAccount;
        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.doCreateCreditFactoryOpportunity();
        creditFactoryOpportunity.Name = 'Creditsafe';
        insert creditFactoryOpportunity;
        CreditSystem__c creditSystem = CreditFactoryUtils.doCreateCreditSystem();
        creditSystem.Supported_Countries__c = 'Germany';
        creditSystem.Name = 'Creditsafe';
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        controller = new CreditFactoryFinderController();
        controller.init();
        System.assertEquals(ApexPages.getMessages().get(0).getSummary(), 'Select Opportunity failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
    }


    /*******************************************************************************
    *  Name            : testOpportunityForClosedCreditsafe()
    *  Summary         : Check Opportunity Status for Closed Won/Lost
    *  CreatedDate     : 22/11/2016
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    @isTest 
    public static void testOpportunityForClosedCreditsafe() {
        Account account = CreditFactoryUtils.doCreateCreditsafeAccount();
        account.BillingCountry = 'Germany';
        insert account;
        Opportunity opportunity = CreditFactoryUtils.doCreateOpportunity(account.Id);
        opportunity.StageName = 'Closed Won';
        insert opportunity;
        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.doCreateCreditFactoryAccount();
        creditFactoryAccount.Name = 'Creditsafe';
        insert creditFactoryAccount;
        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.doCreateCreditFactoryOpportunity();
        creditFactoryOpportunity.Name = 'Creditsafe';
        insert creditFactoryOpportunity;
        CreditSystem__c creditSystem = CreditFactoryUtils.doCreateCreditSystem();
        creditSystem.Supported_Countries__c = 'Germany';
        creditSystem.Name = 'Creditsafe';
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        controller = new CreditFactoryFinderController();
        controller.init();
        System.assertEquals(ApexPages.getMessages().get(0).getSummary(), 'Opportunity was already closed.');
    }


    /******************************************************************************
    *  Name            : testValidateBlackListCreditsafe()
    *  Summary         : Test required fields for Account and Opportunity to null pointer
    *  CreatedDate     : 25/11/2016
    *  Parameters      : 
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testValidateBlackListCreditsafe() {
        RecordType euroshellRecordType = [
                SELECT Name
                FROM RecordType
                WHERE Name = 'Euroshell'];
        Account account = CreditFactoryUtils.doCreateCreditsafeAccount();
        account.BillingCountry = 'Germany';
        insert account;
        Opportunity opportunity = CreditFactoryUtils.doCreateOpportunity(account.Id);
        opportunity.StageName = 'Perception Analysis';
        opportunity.RecordTypeId = euroshellRecordType.Id;
        opportunity.IBAN_des_Zahlungspflichtigen__c = 'DE40632901100396751008';
        insert opportunity;
        Contact contact = CreditFactoryUtils.doCreateContact(opportunity.accountId);
        insert contact;
        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.doCreateCreditFactoryAccount();
        creditFactoryAccount.Name = 'Creditsafe';
        insert creditFactoryAccount;
        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.doCreateCreditFactoryOpportunity();
        creditFactoryOpportunity.Name = 'Creditsafe';
        insert creditFactoryOpportunity;
        CreditSystem__c creditSystem = CreditFactoryUtils.doCreateCreditSystem();
        creditSystem.Supported_Countries__c = 'Germany';
        creditSystem.Name = 'Creditsafe';
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Credit_Black_List_Company__c blackList = CreditFactoryUtils.doCreateCreditBlackListCompany(account.Name);
        blackList.Customer_Id__c = 'DE';
        insert blackList;
        controller = new CreditFactoryFinderController();
        controller.init();
        System.assertEquals(true, ApexPages.getMessages().get(0).getSummary().contains('Company found in black list. Please refer to credit.'));
    }


    /*******************************************************************************
    *  Name            : testValidateRequiredFieldsCreditsafe()
    *  Summary         : Test required fields for Account and Opportunity to null pointer
    *  CreatedDate     : 22/11/2016
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testValidateRequiredFieldsCreditsafe() {
        RecordType euroshellRecordType = [
                SELECT Name
                FROM RecordType
                WHERE Name = 'Euroshell'];
        Account account = CreditFactoryUtils.doCreateCreditsafeAccount();
        account.BillingCountry = 'Germany';
        account.Beschaeftigte__c = '';
        insert account;
        Opportunity opportunity = CreditFactoryUtils.doCreateOpportunity(account.Id);
        opportunity.StageName = 'Perception Analysis';
        opportunity.RecordTypeId = euroshellRecordType.Id;
        opportunity.IBAN_des_Zahlungspflichtigen__c = 'DE40632901100396751008';
        insert opportunity;
        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.doCreateCreditFactoryAccount();
        creditFactoryAccount.Name = 'Creditsafe';
        insert creditFactoryAccount;
        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.doCreateCreditFactoryOpportunity();
        creditFactoryOpportunity.Name = 'Creditsafe';
        insert creditFactoryOpportunity;
        CreditSystem__c creditSystem = CreditFactoryUtils.doCreateCreditSystem();
        creditSystem.Supported_Countries__c = 'Germany';
        creditSystem.Name = 'Creditsafe';
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.doCreateCreditSystemSalesProfile();
        insert creditSystemSalesProfile;
        controller = new CreditFactoryFinderController();
        controller.init();
        System.assertEquals(ApexPages.getMessages().get(0).getSummary(), 'Please fill required fields: Account: Employee*');
        opportunity.Kraftstoffverbrauch_Liter_Monat__c = 000;
        update opportunity;
        creditFactoryOpportunity.Fuel_consumption_l_month__c = 'test';
        update creditFactoryOpportunity;
        controller.init();
        System.assertEquals(ApexPages.getMessages().get(1).getSummary(), 'Error parsing sObject. Please contact your administrator.');
        account.Beschaeftigte__c = 'test';
        update account;
        opportunity.Anzahl_der_Karten__c = null;
        opportunity.StageName = 'Needs Analysis';
        update opportunity;
        controller.init(); 
        System.assertEquals(ApexPages.getMessages().get(2).getSummary(), 'Please fill required fields: Opportunity: Number of Cards*');
        opportunity.Anzahl_der_Karten__c = 000;
        update opportunity;
        creditFactoryOpportunity.Number_of_Cards__c = 'test';
        update creditFactoryOpportunity;
        controller.init();
        System.assertEquals(ApexPages.getMessages().get(1).getSummary(), 'Error parsing sObject. Please contact your administrator.');
    }


    /*******************************************************************************
    *  Name            : testProcessedOpportunityValidationCreditsafe()
    *  Summary         : Fill Processed by field.
    *  CreatedDate     : 19/01/2017
    *  ModifiedDate    : 19/01/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testProcessedOpportunityValidationCreditsafe() {
        Account account = CreditFactoryUtils.doCreateCreditsafeAccount();
        account.BillingCountry = 'Netherlands';
        account.BillingCountryCode = 'NL';
        account.BillingState = 'South Holland';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.doCreateOpportunity(account.Id);
        opportunity.bearbeitet_von__c = 'Autoprocessed by Sales';
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        
        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.doCreateCreditFactoryAccount();
        creditFactoryAccount.Name = 'Creditsafe';
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.doCreateCreditFactoryOpportunity();
        creditFactoryOpportunity.Name = 'Creditsafe';
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.doCreateCreditSystem();
        creditSystem.Supported_Countries__c = 'Netherlands';
        creditSystem.Name = 'Creditsafe';
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            controller = new CreditFactoryFinderController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Opportunity is already processed.', ApexPages.getMessages().get(0).getSummary());
    }



    /*******************************************************************************
    *  Name            : testInvalidSearchCompanyCreditsafe()
    *  Summary         : Check fail search company, isSales = false
    *  CreatedDate     : 22/11/2016
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testInvalidSearchCompanyCreditsafe() {
        Account account = CreditFactoryUtils.doCreateCreditsafeAccount();
        account.BillingCountry = 'Germany';
        insert account;
        Opportunity opportunity = CreditFactoryUtils.doCreateOpportunity(account.Id);
        insert opportunity;
        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.doCreateCreditFactoryAccount();
        creditFactoryAccount.Name = 'Creditsafe';
        insert creditFactoryAccount;
        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.doCreateCreditFactoryOpportunity();
        creditFactoryOpportunity.Name = 'Creditsafe';
        insert creditFactoryOpportunity;
        CreditSystem__c creditSystem = CreditFactoryUtils.doCreateCreditSystem();
        creditSystem.Supported_Countries__c = 'Germany';
        creditSystem.Name = 'Creditsafe';
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
        controller = new CreditFactoryFinderController();
        Test.setMock(HttpCalloutMock.class, new ErrorCreditreformSearchMock());
        controller.init();
        Test.stopTest();
        System.assertEquals(ApexPages.getMessages().get(0).getSummary(), 'Search company failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
    }


    /*******************************************************************************
    *  Name            : testValidSearchCompanyCreditsafe
    *  Summary         : Check success search company
    *  CreatedDate     : 22/11/2016
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    @isTest 
    public static void testValidSearchCompanyCreditsafe() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        ApexPages.currentPage().getParameters().put('companyIndex', '0');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createCreditsafeAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createCreditsafeOpportunityMapping();
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditsafeCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;
        
        Test.startTest();
        controller = new CreditFactoryFinderController();
        Test.setMock(HttpCalloutMock.class, new CreditsafeSearchMock());
        controller.init();
        Test.stopTest();
        controller.selectCompanyForReport();
        controller.backToOpporutnity();
        controller.setInvalidSearch();
    }


    /*******************************************************************************
    *  Name            : testValidSearchCompanyInfo()
    *  Summary         : Check success company search in Company.info
    *  CreatedDate     : 21/05/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testValidSearchCompanyInfo() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        ApexPages.currentPage().getParameters().put('companyIndex', '0');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createCreditsafeAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createCreditsafeOpportunityMapping();
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditsafeCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        CreditSystem__c additionalCreditSystem = CreditFactoryUtils.createCompanyInfoCreditSystem();
        insert additionalCreditSystem;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CompanyInfoSearchMock());
            controller = new CreditFactoryFinderController();
            controller.init();
            controller.selectCompanyForReport();
        Test.stopTest();
    }
}