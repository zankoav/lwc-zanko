@isTest
private class CreditFactoryFinderControllerCofaceTest {
    public static CreditFactoryFinderController controller;


	/*******************************************************************************
	*  Name            : testInvalidOpportunityId()
	*  Summary         : Leave opportunity id as null in vf page.
	*  CreatedDate     : 07/03/2018
	*  ModifiedDate    : 07/03/2018
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	@isTest
    public static void testInvalidOpportunityId() {
        Test.startTest();
        	controller = new CreditFactoryFinderController();
        	controller.init();
        Test.stopTest();

        System.assertEquals('Invalid record id.', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testInvalidCountry()
    *  Summary         : Leave country field as empty.
    *  CreatedDate     : 07/03/2018
	*  ModifiedDate    : 07/03/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testInvalidCountry() {
    	Account account = CreditFactoryUtils.createCofaceAccount();
        account.BillingCountry = '';
    	insert account;

    	Opportunity opportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
    	insert opportunity;

    	ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        Test.startTest();
        	controller = new CreditFactoryFinderController();
        	controller.init();
        Test.stopTest();

        System.assertEquals('Please add Billing Country to Account.', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testInvalidCreditSystem()
    *  Summary         : Don't create Credit System custom setting.
    *  CreatedDate     : 07/03/2018
    *  ModifiedDate    : 07/03/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testInvalidCreditSystem() {
    	Account account = CreditFactoryUtils.createCofaceAccount();
    	insert account;

    	Opportunity opportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
    	insert opportunity;

    	ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        Test.startTest();
        	controller = new CreditFactoryFinderController();
        	controller.init();
        Test.stopTest();

    	System.assertEquals('Select Credit System Settings failed. Please check Billing Country or contact your administrator.', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testInvalidCreditSystemName()
    *  Summary         : Create Credit System custom setting not with "Coface" name.
    *  CreatedDate     : 07/03/2018
    *  ModifiedDate    : 04/10/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testInvalidCreditSystemName() {
        Account account = CreditFactoryUtils.createCofaceAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
        insert opportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCofaceCreditSystem();
        creditSystem.Name = 'test';
        insert creditSystem;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        Test.startTest();
            controller = new CreditFactoryFinderController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Invalid name for Credit setting.', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testInvalidAccountMappingName()
    *  Summary         : Create Account mapping not with "Coface" name.
    *  CreatedDate     : 07/03/2018
    *  ModifiedDate    : 07/03/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testInvalidAccountMappingName() {
        Account account = CreditFactoryUtils.createCofaceAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        Credit_Factory_Account__c creditFactoryAccount = new Credit_Factory_Account__c(Name = 'Test');
        insert creditFactoryAccount;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCofaceCreditSystem();
        insert creditSystem;

        Test.startTest();
            controller = new CreditFactoryFinderController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Account mapping select error. ' + CreditFactoryUtilities.CONTACT_ADMIN, ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testInvalidOpportunityMappingName()
    *  Summary         : Create Opportunity mapping not with "Coface" name.
    *  CreatedDate     : 07/03/2018
    *  ModifiedDate    : 07/03/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testInvalidOpportunityMappingName() {
        Account account = CreditFactoryUtils.createCofaceAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        Credit_Factory_Account__c creditFactoryAccount = new Credit_Factory_Account__c(Name = 'Coface');
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = new Credit_Factory_Opportunity__c(Name = 'Test');
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCofaceCreditSystem();
        insert creditSystem;

        Test.startTest();
            controller = new CreditFactoryFinderController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Opportunity mapping select error. ' + CreditFactoryUtilities.CONTACT_ADMIN, ApexPages.getMessages().get(0).getSummary());
    }


    /******************************************************************************
    *  Name            : testInvalidAccountMapping()
    *  Summary         : Leave empty Account mapping field.
    *  CreatedDate     : 07/03/2018
    *  ModifiedDate    : 07/03/2018 
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testInvalidAccountMapping() {
        Account account = CreditFactoryUtils.createCofaceAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCofaceAccountMapping();
        creditFactoryAccount.Company_Form__c = '';
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCofaceOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCofaceCreditSystem();
        insert creditSystem;

        Test.startTest();
            controller = new CreditFactoryFinderController();
            controller.init();
        Test.stopTest();

        System.assertEquals('All fields in Account mapping should not be null. ' + CreditFactoryUtilities.CONTACT_ADMIN, ApexPages.getMessages().get(0).getSummary());
    }


    /******************************************************************************
    *  Name            : testInvalidOpportunityMapping()
    *  Summary         : Leave empty Opportunity mapping field.
    *  CreatedDate     : 07/03/2018
    *  ModifiedDate    : 07/03/2018 
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testInvalidOpportunityMapping() {
        Account account = CreditFactoryUtils.createCofaceAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCofaceAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCofaceOpportunityMapping();
        creditFactoryOpportunity.Credit_System_Limit__c = '';
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCofaceCreditSystem();
        insert creditSystem;

        Test.startTest();
            controller = new CreditFactoryFinderController();
            controller.init();
        Test.stopTest();

        System.assertEquals('All fields in Opportunity mapping should not be null. ' + CreditFactoryUtilities.CONTACT_ADMIN, ApexPages.getMessages().get(0).getSummary());
    }


    /******************************************************************************
    *  Name            : testClosedOpportunity()
    *  Summary         : Try to launch Credit Factory for Closed Opportunity.
    *  CreatedDate     : 07/03/2018
    *  ModifiedDate    : 07/03/2018 
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest 
    public static void testClosedOpportunity() {
        Account account = CreditFactoryUtils.createCofaceAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
        opportunity.StageName = 'Closed Won';
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCofaceAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCofaceOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCofaceCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            controller = new CreditFactoryFinderController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Opportunity was already closed.', ApexPages.getMessages().get(0).getSummary());
    }


    /*****************************************************************************
    *  Name            : testBlackListValidation()
    *  Summary         : Create Opportunity (or Account) that stores in Black List
    *  CreatedDate     : 07/03/2018
    *  ModifiedDate    : 07/03/2018
    *  Parameters      : -
    *  Returns         : void
    ****************************************************************************/
    @isTest
    public static void testBlackListValidation() {
        Account account = CreditFactoryUtils.createCofaceAccount();
        account.Name = 'Test Black List';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCofaceAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCofaceOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCofaceCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Credit_Black_List_Company__c blackList = CreditFactoryUtils.createCofaceBlackList();
        blackList.Customer_Id__c = 'HU';
        insert blackList;

        Test.startTest();
            controller = new CreditFactoryFinderController();
            controller.init();
        Test.stopTest();

        System.assertEquals(true, ApexPages.getMessages().get(0).getSummary().contains('Company found in black list. Please refer to credit.'));
    }


    /*******************************************************************************
    *  Name            : testProcessedOpportunityValidation()
    *  Summary         : Fill Processed by field.
    *  CreatedDate     : 07/03/2018
    *  ModifiedDate    : 07/03/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testProcessedOpportunityValidation() {
        Account account = CreditFactoryUtils.createCofaceAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
        opportunity.bearbeitet_von__c = 'Autoprocessed by Sales';
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        
        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCofaceAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCofaceOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCofaceCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            controller = new CreditFactoryFinderController();
            controller.init();
        Test.stopTest();

        System.assertEquals(ApexPages.getMessages().get(0).getSummary(), 'Opportunity is already processed.');
    }


    /*******************************************************************************
    *  Name            : testRequiredFieldsValidation()
    *  Summary         : Check Opportunity (or Account) required fields for on null pointer
    *  CreatedDate     : 07/03/2018
    *  ModifiedDate    : 07/03/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testRequiredFieldsValidation() {
        Account account = CreditFactoryUtils.createCofaceAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
        opportunity.Anzahl_der_Karten__c = null;
        opportunity.StageName = 'Pending Sales – Information';
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCofaceAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCofaceOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCofaceCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.doCreateCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        Test.startTest();
            controller = new CreditFactoryFinderController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Please fill required fields: Opportunity: Number of Cards*', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testPaymentTermsValidation()
    *  Summary         : Check Opportunity (or Account) required fields for on null pointer
    *  CreatedDate     : 07/03/2018
    *  ModifiedDate    : 07/03/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testPaymentTermsValidation() {
        Account account = CreditFactoryUtils.createCofaceAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
        opportunity.Zahlungsziel_2__c = '30';
        opportunity.Rechnungsperiode_2__c = '14';
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCofaceAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCofaceOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCofaceCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.doCreateCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        Test.startTest();
            controller = new CreditFactoryFinderController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Desired Billing Period and Desired Payment terms are not available. Available options are: 7+7, 15+14.', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testDuplicatesCheck()
    *  Summary         : Test duplicates check in opportunities, accounts and contacts.
    *  CreatedDate     : 07/03/2018
    *  ModifiedDate    : 07/03/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testDuplicatesCheck() {
        List<Account> accountsList = new List<Account>();
        Account account = CreditFactoryUtils.createCofaceAccount();
        accountsList.add(account);
        Account duplicateAccount = CreditFactoryUtils.createCofaceAccount();
        duplicateAccount.Steuernummer__c = '123123123123';
        accountsList.add(duplicateAccount);
        insert accountsList;

        List<Opportunity> opportunitiesList = new List<Opportunity>();
        Opportunity opportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
        opportunitiesList.add(opportunity);
        Opportunity duplicateOpportunity = CreditFactoryUtils.createCofaceOpportunity(duplicateAccount.Id);
        opportunitiesList.add(duplicateOpportunity);
        insert opportunitiesList;

        List<Contact> contactsList = new List<Contact>();
        Contact contact = CreditFactoryUtils.createCofaceContact(account.Id);
        contactsList.add(contact);
        Contact duplicateContact = CreditFactoryUtils.createCofaceContact(duplicateAccount.Id);
        contactsList.add(duplicateContact);
        insert contactsList;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCofaceAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCofaceOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCofaceCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.doCreateCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        OpportunityContactRole opportunityContactRole = CreditFactoryUtils.createCofaceOpportunityContactRole(contact.Id, opportunity.Id);
        insert opportunityContactRole;

        Test.startTest();
            controller = new CreditFactoryFinderController();
            controller.init();
        Test.stopTest();

        System.assertEquals(true, String.valueOf(ApexPages.getMessages().get(0)).contains('Duplicate Accounts found'));
        System.assertEquals(true, String.valueOf(ApexPages.getMessages().get(0)).contains('Duplicate Opportunities found'));
        System.assertEquals(true, String.valueOf(ApexPages.getMessages().get(0)).contains('Duplicate Contacts found'));
    }


    /******************************************************************************
    *  Name            : testInvalidCompanySearch()
    *  Summary         : Test unsuccessful company search.
    *  CreatedDate     : 07/03/2018
    *  ModifiedDate    : 07/03/2018
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testInvalidCompanySearch() {
        Account account = CreditFactoryUtils.createCofaceAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        ApexPages.currentPage().getParameters().put('companyIndex', '0');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCofaceAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCofaceOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCofaceCreditSystem();
        creditSystem.Endpoint__c = null;
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            controller = new CreditFactoryFinderController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Search company failed. ' + CreditFactoryUtilities.CONTACT_ADMIN, ApexPages.getMessages().get(0).getSummary());   
    }


    /*******************************************************************************
    *  Name            : testValidCompanySearch()
    *  Summary         : Test successful company search.
    *  CreatedDate     : 07/03/2018
    *  ModifiedDate    : 07/03/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest 
    public static void testValidCompanySearch() {
        Account account = CreditFactoryUtils.createCofaceAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        ApexPages.currentPage().getParameters().put('companyIndex', '0');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCofaceAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCofaceOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCofaceCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CofaceSearchMock());
            controller = new CreditFactoryFinderController();
            controller.init();
            controller.selectCompanyForReport();
            controller.backToOpporutnity();
            controller.setInvalidSearch();
        Test.stopTest();

        System.assertEquals(false, controller.companiesList.isEmpty());
    }


    /*******************************************************************************
    *  Name            : testOrderRequest()
    *  Summary         : Test company search when there are no found companies    
    *  CreatedDate     : 29/06/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testOrderRequest() {
        Account account = CreditFactoryUtils.createCofaceAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        ApexPages.currentPage().getParameters().put('companyIndex', '0');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCofaceAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCofaceOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCofaceCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CofaceOrderMock());
            controller = new CreditFactoryFinderController();
            controller.init();
        Test.stopTest();

        List<Opportunity> opportunitiesList = [
                SELECT CF_Order_Party_Id__c, CF_Order_Reference_Number__c, CF_Stage__c
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals('CIC_HU', opportunitiesList.get(0).CF_Order_Party_Id__c);
        System.assertEquals('1439777', opportunitiesList.get(0).CF_Order_Reference_Number__c);
        System.assertEquals('Pending Credit Report - Order was sent', opportunitiesList.get(0).CF_Stage__c);
    }


    /*******************************************************************************
    *  Name            : testExistingCompany()
    *  Summary         : Check success search company
    *  CreatedDate     : 07/03/2018
    *  ModifiedDate    : 07/03/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest 
    public static void testExistingCompany() {
        Account account = CreditFactoryUtils.createCofaceAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        ApexPages.currentPage().getParameters().put('companyIndex', '0');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCofaceAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCofaceOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCofaceCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Credit_Factory_Report__c creditReport = CreditFactoryUtils.createCofaceReport();
        creditReport.Opportunity__c = opportunity.Id;
        insert creditReport;

        Credit_Factory_Report_Employee__c creditReportEmployee = CreditFactoryUtils.createCofaceReportEmployee();
        creditReportEmployee.Credit_Factory_Report__c = creditReport.Id;
        insert creditReportEmployee;

        Test.startTest();
            controller = new CreditFactoryFinderController();
            controller.init();
        Test.stopTest();

        System.assertEquals(true, ApexPages.currentPage().getRedirect());
    }
}