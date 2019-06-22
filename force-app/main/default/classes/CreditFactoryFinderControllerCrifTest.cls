@isTest
public class CreditFactoryFinderControllerCrifTest {
	public static CreditFactoryFinderController controller;


	/*******************************************************************************
	*  Name            : testInvalidOpportunityId()
	*  Summary         : Leave opportunity id as null in vf page.
	*  CreatedDate     : 15/01/2018
	*  ModifiedDate    : 15/01/2018
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
    *  CreatedDate     : 15/01/2018
	*  ModifiedDate    : 15/01/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testInvalidCountry() {
    	Account account = CreditFactoryUtils.createCrifAccount();
        account.BillingCountry = '';
    	insert account;

    	Opportunity opportunity = CreditFactoryUtils.createCrifOpportunity(account.Id);
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
    *  CreatedDate     : 15/01/2018
    *  ModifiedDate    : 15/01/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testInvalidCreditSystem() {
    	Account account = CreditFactoryUtils.createCrifAccount();
    	insert account;

    	Opportunity opportunity = CreditFactoryUtils.createCrifOpportunity(account.Id);
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
    *  Summary         : Create Credit System custom setting not with "Crif" name.
    *  CreatedDate     : 15/01/2018
    *  ModifiedDate    : 04/10/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testInvalidCreditSystemName() {
        Account account = CreditFactoryUtils.createCrifAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrifOpportunity(account.Id);
        insert opportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrifCreditSystem();
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
    *  Summary         : Create Account mapping not with "Crif" name.
    *  CreatedDate     : 15/01/2018
    *  ModifiedDate    : 15/01/2018 
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testInvalidAccountMappingName() {
        Account account = CreditFactoryUtils.createCrifAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrifOpportunity(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        Credit_Factory_Account__c creditFactoryAccount = new Credit_Factory_Account__c(Name = 'Test');
        insert creditFactoryAccount;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrifCreditSystem();
        insert creditSystem;

        Test.startTest();
            controller = new CreditFactoryFinderController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Account mapping select error. ' + CreditFactoryUtilities.CONTACT_ADMIN, ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testInvalidOpportunityMappingName()
    *  Summary         : Create Opportunity mapping not with "Crif" name.
    *  CreatedDate     : 15/01/2018
    *  ModifiedDate    : 15/01/2018 
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testInvalidOpportunityMappingName() {
        Account account = CreditFactoryUtils.createCrifAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrifOpportunity(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        Credit_Factory_Account__c creditFactoryAccount = new Credit_Factory_Account__c(Name = 'Crif');
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = new Credit_Factory_Opportunity__c(Name = 'Test');
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrifCreditSystem();
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
    *  CreatedDate     : 15/01/2018
    *  ModifiedDate    : 15/01/2018 
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testInvalidAccountMapping() {
        Account account = CreditFactoryUtils.createCrifAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrifOpportunity(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCrifAccountMapping();
        creditFactoryAccount.Company_Form__c = '';
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCrifOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrifCreditSystem();
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
    *  CreatedDate     : 15/01/2018
    *  ModifiedDate    : 15/01/2018 
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testInvalidOpportunityMapping() {
        Account account = CreditFactoryUtils.createCrifAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrifOpportunity(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCrifAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCrifOpportunityMapping();
        creditFactoryOpportunity.Credit_System_Limit__c = '';
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrifCreditSystem();
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
    *  CreatedDate     : 15/01/2018
    *  ModifiedDate    : 15/01/2018
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest 
    public static void testClosedOpportunity() {
        Account account = CreditFactoryUtils.createCrifAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrifOpportunity(account.Id);
        opportunity.StageName = 'Closed Won';
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCrifAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCrifOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrifCreditSystem();
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
    *  CreatedDate     : 15/01/2018
    *  ModifiedDate    : 15/01/2018
    *  Parameters      : -
    *  Returns         : void
    ****************************************************************************/
    @isTest
    public static void testBlackListValidation() {
        Account account = CreditFactoryUtils.createCrifAccount();
        account.Name = 'Test Black List';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrifOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCrifContact(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCrifAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCrifOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrifCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Credit_Black_List_Company__c blackList = CreditFactoryUtils.createCrifBlackList();
        blackList.Customer_Id__c = 'PL';
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
    *  CreatedDate     : 19/01/2017
    *  ModifiedDate    : 19/01/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testProcessedOpportunityValidation() {
        Account account = CreditFactoryUtils.createCrifAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrifOpportunity(account.Id);
        opportunity.bearbeitet_von__c = 'Autoprocessed by Sales';
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        
        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCrifAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCrifOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrifCreditSystem();
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
    *  Name            : testRequiredFieldsValidation()
    *  Summary         : Check Opportunity (or Account) required fields for on null pointer
    *  CreatedDate     : 15/01/2018
    *  ModifiedDate    : 15/01/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testRequiredFieldsValidation() {
        Account account = CreditFactoryUtils.createCrifAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrifOpportunity(account.Id);
        opportunity.Anzahl_der_Karten__c = null;
        opportunity.StageName = 'Pending Sales – Information';
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCrifAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCrifOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrifCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.doCreateCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        Test.startTest();
            controller = new CreditFactoryFinderController();
            controller.init();
        Test.stopTest();

        System.assertEquals(ApexPages.getMessages().get(0).getSummary(), 'Please fill required fields: Opportunity: Number of Cards*');
    }


    /*******************************************************************************
    *  Name            : testPaymentTermsValidation()
    *  Summary         : Check Opportunity (or Account) required fields for on null pointer
    *  CreatedDate     : 16/01/2018
    *  ModifiedDate    : 22/10/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testPaymentTermsValidation() {
        Account account = CreditFactoryUtils.createCrifAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrifOpportunity(account.Id);
        opportunity.Zahlungsziel_2__c = '';
        opportunity.Rechnungsperiode_2__c = '';
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCrifAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCrifOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrifCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.doCreateCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        Test.startTest();
            controller = new CreditFactoryFinderController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Desired Billing Period and Desired Payment terms are not available. Available options are: 15+14, 15+7, 7+7.', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testDuplicatesCheck()
    *  Summary         : Test duplicates check in opportunities, accounts and contacts.
    *  CreatedDate     : 15/01/2018
    *  ModifiedDate    : 15/01/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testDuplicatesCheck() {
        List<Account> accountsList = new List<Account>();
        Account account = CreditFactoryUtils.createCrifAccount();
        accountsList.add(account);
        Account duplicateAccount = CreditFactoryUtils.createCrifAccount();
        duplicateAccount.Steuernummer__c = '123123123';
        accountsList.add(duplicateAccount);
        insert accountsList;

        List<Opportunity> opportunitiesList = new List<Opportunity>();
        Opportunity opportunity = CreditFactoryUtils.createCrifOpportunity(account.Id);
        opportunitiesList.add(opportunity);
        Opportunity duplicateOpportunity = CreditFactoryUtils.createCrifOpportunity(duplicateAccount.Id);
        opportunitiesList.add(duplicateOpportunity);
        insert opportunitiesList;

        List<Contact> contactsList = new List<Contact>();
        Contact contact = CreditFactoryUtils.createCrifContact(account.Id);
        contactsList.add(contact);
        Contact duplicateContact = CreditFactoryUtils.createCrifContact(duplicateAccount.Id);
        contactsList.add(duplicateContact);
        insert contactsList;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCrifAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCrifOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrifCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.doCreateCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        OpportunityContactRole opportunityContactRole = CreditFactoryUtils.createCrifOpportunityContactRole(contact.Id, opportunity.Id);
        insert opportunityContactRole;

        Test.startTest();
            controller = new CreditFactoryFinderController();
            controller.init();
        Test.stopTest();

        System.assertEquals(String.valueOf(ApexPages.getMessages().get(0)).contains('Duplicate Accounts found'), true);
        System.assertEquals(String.valueOf(ApexPages.getMessages().get(0)).contains('Duplicate Opportunities found'), true);
        System.assertEquals(String.valueOf(ApexPages.getMessages().get(0)).contains('Duplicate Contacts found'), true);
    }


    /******************************************************************************
    *  Name            : testInvalidCompanySearch()
    *  Summary         : Test unsuccessful company search.
    *  CreatedDate     : 15/01/2018
    *  ModifiedDate    : 15/01/2018
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testInvalidCompanySearch() {
        Account account = CreditFactoryUtils.createCrifAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrifOpportunity(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        ApexPages.currentPage().getParameters().put('companyIndex', '0');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCrifAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCrifOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrifCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new ErrorCrifSearchMock());
            controller = new CreditFactoryFinderController();
            controller.init();
        Test.stopTest();

        System.assertEquals(ApexPages.getMessages().get(0).getSummary(), 'Search company failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);

        
    }


    /*******************************************************************************
    *  Name            : testValidCompanySearch()
    *  Summary         : Test successful company search.
    *  CreatedDate     : 15/01/2018
    *  ModifiedDate    : 15/01/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest 
    public static void testValidCompanySearch() {
        Account account = CreditFactoryUtils.createCrifAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrifOpportunity(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        ApexPages.currentPage().getParameters().put('companyIndex', '0');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCrifAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCrifOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrifCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CrifSearchMock());
            controller = new CreditFactoryFinderController();
            controller.init();
            controller.selectCompanyForReport();
            controller.backToOpporutnity();
            controller.setInvalidSearch();
        Test.stopTest();

        System.assertEquals(false, controller.companiesList.isEmpty());
    }


    /*******************************************************************************
    *  Name            : testPendingReportValidation()
    *  Summary         : Check if we are waiting for report without request status error
    *  CreatedDate     : 12/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testPendingReportValidation() {
        Account account = CreditFactoryUtils.createCrifAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrifOpportunity(account.Id);
        opportunity.StageName = 'Pending Credit Report';
        opportunity.CF_Stage__c = 'Pending Credit Report - Order was sent';
        opportunity.Anzahl_der_Karten__c = 0;
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCrifAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCrifOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrifCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.doCreateCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        Test.startTest();
		    Test.setMock(HttpCalloutMock.class, new CrifSearchMock());
            controller = new CreditFactoryFinderController();
            controller.init();
            controller.setInvalidSearch();
        Test.stopTest();

        System.assertEquals('Company is not in the list. Additional attempts to download a Credit Factory report will be performed automatically till the end of the day. ' +
        	'Once a report is downloaded you will receive an email notification.', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testExistingCompany()
    *  Summary         : Check success search company
    *  CreatedDate     : 15/01/2018
    *  ModifiedDate    : 15/01/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest 
    public static void testExistingCompany() {
        Account account = CreditFactoryUtils.createCrifAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrifOpportunity(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        ApexPages.currentPage().getParameters().put('companyIndex', '0');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCrifAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCrifOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrifCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Credit_Factory_Report__c creditReport = CreditFactoryUtils.doCreateCreditreformReport();
        creditReport.Opportunity__c = opportunity.Id;
        insert creditReport;

        Credit_Factory_Report_Employee__c creditReportEmployee = CreditFactoryUtils.doCreateCreditreformReportEmployee();
        creditReportEmployee.Credit_Factory_Report__c = creditReport.Id;
        insert creditReportEmployee;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CrifSearchMock());
            controller = new CreditFactoryFinderController();
            controller.init();
        Test.stopTest();

        System.assertEquals(true, ApexPages.currentPage().getRedirect());
    }
}