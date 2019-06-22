@isTest
private class CreditFactoryReportControllerTestLU {
	public static CreditFactoryReportController controller;


	/*******************************************************************************
    *  Name            : testInvalidOpportunityParameter()
    *  Summary         : Leave empty opportunity id parameter.
    *  CreatedDate     : 19/11/2018
	*  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest 
    public static void testInvalidOpportunityParameter() {
        Test.startTest();
	        controller = new CreditfactoryReportController();
	        controller.init();
	    Test.stopTest();

        System.assertEquals('Invalid opportunityId parameter.Please contact your administrator.', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testInvalidCompanyNumberParameter()
    *  Summary         : Leave empty credit system id parameter. 
    *  CreatedDate     : 19/11/2018
	*  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest 
    public static void testInvalidCompanyNumberParameter() {
    	Account account = CreditFactoryUtils.createCreditReformAccountLU();
    	insert account;

    	Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityLU(account.Id);
    	insert opportunity;

    	ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);

        Test.startTest();
	        controller = new CreditfactoryReportController();
	        controller.init();
	    Test.stopTest();

        System.assertEquals('Invalid creditSystemCompanyNumber parameter.' + CreditFactoryUtilities.CONTACT_ADMIN, ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testInvalidCreditSystem()
    *  Summary         : Don't create Credit System custom setting.
    *  CreatedDate     : 19/11/2018
	*  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest 
    public static void testInvalidCreditSystem() {
    	Account account = CreditFactoryUtils.createCreditReformAccountLU();
    	insert account;

    	Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityLU(account.Id);
    	insert opportunity;

    	ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
    	ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '09379370071090');

        Test.startTest();
        	controller = new CreditfactoryReportController();
        	controller.init();
        Test.stopTest();

    	System.assertEquals('Select Credit System Settings failed. Please check Billing Country or contact your administrator.', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testInvalidCreditSystemName()
    *  Summary         : Create Credit System custom setting not with "CreditreformLU" name.
    *  CreatedDate     : 19/11/2018
	*  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest 
    public static void testInvalidCreditSystemName() {
        Account account = CreditFactoryUtils.createCreditReformAccountLU();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityLU(account.Id);
        insert opportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemLU();
        creditSystem.Name = 'test';
        insert creditSystem;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '09379370071090');

        Test.startTest();
            controller = new CreditfactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Invalid name for Credit setting.', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testInvalidAccountMappingName()
    *  Summary         : Create Account mapping not with "CreditreformLU" name.
    *  CreatedDate     : 19/11/2018
	*  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest 
    public static void testInvalidAccountMappingName() {
        Account account = CreditFactoryUtils.createCreditReformAccountLU();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityLU(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '09379370071090');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemLU();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingLU();
        creditFactoryAccount.Name = 'test';
        insert creditFactoryAccount;

        Test.startTest();
            controller = new CreditfactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Account mapping select error. ' + CreditFactoryUtilities.CONTACT_ADMIN, ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testInvalidOpportunityMappingName()
    *  Summary         : Create Opportunity mapping not with "CreditreformLU" name.
    *  CreatedDate     : 19/11/2018
	*  ModifiedDate    : - 
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest 
    public static void testInvalidOpportunityMappingName() {
        Account account = CreditFactoryUtils.createCreditReformAccountLU();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityLU(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '09379370071090');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemLU();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingLU();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingLU();
        creditFactoryOpportunity.Name = 'test';
        insert creditFactoryOpportunity;

        Test.startTest();
            controller = new CreditfactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Opportunity mapping select error. ' + CreditFactoryUtilities.CONTACT_ADMIN, ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testAddressValidation()
    *  Summary         : Put in Account address different from Creditreform company name value                   
    *  CreatedDate     : 19/11/2018
	*  ModifiedDate    : - 
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest 
    public static void testAddressValidation() {
        Account account = CreditFactoryUtils.createCreditReformAccountLU();
        account.BillingCity = 'test';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityLU(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContactLU(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '09379370071090');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemLU();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingLU();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingLU();
        insert creditFactoryOpportunity;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformReportRating1MockLU());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.doUpdateAddress();
        Test.stopTest();

        System.assertEquals('Account Billing and Shipping Addresses should be the same as Crefo address', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals('Fix all validation errors or refer to Credit.', ApexPages.getMessages().get(1).getSummary());
        System.assertEquals('Address has been updated.', ApexPages.getMessages().get(2).getSummary());
    }


    /******************************************************************************
    *  Name            : testLegalFormValidation()
    *  Summary         : Check valid legal form                       
    *  CreatedDate     : 19/11/2018
	*  ModifiedDate    : - 
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest 
    public static void testLegalFormValidation() {
        Account account = CreditFactoryUtils.createCreditReformAccountLU();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityLU(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContactLU(account.Id);
        contact.LastName = 'test';
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '09379370071090');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemLU();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingLU();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingLU();
        insert creditFactoryOpportunity;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformReportPublicEntityMockLU());
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Customer is a public entity.', ApexPages.getMessages().get(0).getSummary());
    }


    /******************************************************************************
    *  Name            : testContactValidation()
    *  Summary         : Put Last name in Contact different from Creditreform contact Last name value.                    
    *  CreatedDate     : 19/11/2018
	*  ModifiedDate    : - 
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest 
    public static void testContactValidation() {
        Account account = CreditFactoryUtils.createCreditReformAccountLU();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityLU(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContactLU(account.Id);
        contact.LastName = 'test';
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '09379370071090');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemLU();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingLU();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingLU();
        insert creditFactoryOpportunity;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformReportRating1MockLU());
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Crefo Contact person doesn\'t exist in Account\'s Contacts', ApexPages.getMessages().get(0).getSummary());
    }


    /*****************************************************************************
    *  Name            : testCompanyNameValidation()
    *  Summary         : Put name in Account different from Creditreform company name value
    *  CreatedDate     : 19/11/2018
	*  ModifiedDate    : - 
    *  Parameters      : -
    *  Returns         : void
    ****************************************************************************/
    @isTest 
    public static void testCompanyNameValidation() {
        Account account = CreditFactoryUtils.createCreditReformAccountLU();
        account.Name = 'test';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityLU(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContactLU(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '09379370071090');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemLU();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingLU();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingLU();
        insert creditFactoryOpportunity;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.createCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformReportRating1MockLU());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.doUpdateCompanyName();
        Test.stopTest();

        System.assertEquals('Account Name and Crefo Name mismatch', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals('Fix all validation errors or refer to Credit.', ApexPages.getMessages().get(1).getSummary());
        System.assertEquals('Account Name has been updated.', ApexPages.getMessages().get(2).getSummary());
    }


    /******************************************************************************
    *  Name            : testTaxIdValidation()
    *  Summary         : Put Tax Id in Account different from Creditreform company value.                      
    *  CreatedDate     : 19/11/2018
	*  ModifiedDate    : - 
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest 
    public static void testTaxIdValidation() {
        Account account = CreditFactoryUtils.createCreditReformAccountLU();
        account.Steuernummer__c = 'test';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityLU(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContactLU(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '09379370071090');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemLU();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingLU();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingLU();
        insert creditFactoryOpportunity;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformReportRating1MockLU());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.doUpdateTaxId();
        Test.stopTest();

        System.assertEquals('Account Tax ID mismatch (Creditreform to Account Tax ID)', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals('Fix all validation errors or refer to Credit.', ApexPages.getMessages().get(1).getSummary());
        System.assertEquals('Account Tax ID has been updated.', ApexPages.getMessages().get(2).getSummary());
    }


    /******************************************************************************
    *  Name            : testVatNumberValidation()
    *  Summary         : Put in Account VAT Number different from Coface company value.                      
    *  CreatedDate     : 19/11/2018
	*  ModifiedDate    : - 
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest 
    public static void testVatNumberValidation() {
        Account account = CreditFactoryUtils.createCreditReformAccountLU();
        account.Umsatzsteuer_ID__c = 'test';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityLU(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContactLU(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '09379370071090');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemLU();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingLU();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingLU();
        insert creditFactoryOpportunity;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformReportRating1MockLU());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.doUpdateVatNumber();
        Test.stopTest();

        System.assertEquals('Account VAT number mismatch (Creditreform to Account VAT number)', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals('Fix all validation errors or refer to Credit.', ApexPages.getMessages().get(1).getSummary());
        System.assertEquals('Account VAT number has been updated.', ApexPages.getMessages().get(2).getSummary());
    }


    /******************************************************************************
    *  Name            : testLostOpportunitiesValidation()
    *  Summary         : Create Closed Lost Opportunity related to the current Opportunity's Account
    *  CreatedDate     : 19/11/2018
	*  ModifiedDate    : - 
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest 
    public static void testLostOpportunitiesValidation() {
        Account account = CreditFactoryUtils.createCreditReformAccountLU();
        insert account;

        List<Opportunity> opportunitiesList = new List<Opportunity>();
        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityLU(account.Id);
        opportunitiesList.add(opportunity);

        Opportunity lostOpportunity = CreditFactoryUtils.createCreditreformOpportunityLU(account.Id);
        opportunity.StageName = 'Closed Lost';
        opportunity.Gruende_verloren__c = 'Refused Credit';
        opportunitiesList.add(lostOpportunity);
        insert opportunitiesList;

        Contact contact = CreditFactoryUtils.createCreditreformContactLU(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '09379370071090');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemLU();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingLU();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingLU();
        insert creditFactoryOpportunity;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformReportRating1MockLU());
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Credit Check was rejected for one of the Opportunities linked with your Account or its Contacts. Please refer to Credit.', ApexPages.getMessages().get(0).getSummary());
    }


    /******************************************************************************
    *  Name            : testPaymentMethodValidation()
    *  Summary         : Create Opportunity with "Bank Transfer" payment method            
    *  CreatedDate     : 19/11/2018
	*  ModifiedDate    : - 
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest 
    public static void testPaymentMethodValidation() {
        Account account = CreditFactoryUtils.createCreditReformAccountLU();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityLU(account.Id);
        opportunity.Zahlungsart__c = 'Banküberweisung';
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContactLU(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '09379370071090');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemLU();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingLU();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingLU();
        insert creditFactoryOpportunity;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformReportRating1MockLU());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.doUpdateVatNumber();
        Test.stopTest();

        System.assertEquals('Opportunity cannot be closed automatically with Payment Method Bank Transfer.', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testDoOrder()
    *  Summary         : Test do order in case of report is not available.
    *  CreatedDate     : 19/11/2018
	*  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest 
    public static void testDoOrder() {
        Account account = CreditFactoryUtils.createCreditReformAccountLU();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityLU(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContactLU(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '09379370071090');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemLU();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingLU();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingLU();
        insert creditFactoryOpportunity;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformOrderMockLU());
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        List<Opportunity> opportunitiesList = [
                SELECT CF_Order_Reference_Number__c, CF_Stage__c
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals('40374221', opportunitiesList.get(0).CF_Order_Reference_Number__c);
        System.assertEquals('Pending Credit Report - Order was sent', opportunitiesList.get(0).CF_Stage__c);
    }


    /*******************************************************************************
    *  Name            : testBlackListValidation()
    *  Summary         : Create Credit_Black_List_Company__c and Opportunity objects with the same fields.  
    *  CreatedDate     : 19/11/2018
	*  ModifiedDate    : - 
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest 
    public static void testBlackListValidation() {
       	Account account = CreditFactoryUtils.createCreditReformAccountLU();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityLU(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContactLU(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '09379370071090');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemLU();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingLU();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingLU();
        insert creditFactoryOpportunity;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Credit_Black_List_Company__c blackList = CreditFactoryUtils.createCreditreformBlackListLU(account.Name);
        insert blackList;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformReportRating1MockLU());
            controller = new CreditFactoryReportController();
            controller.init();
            Boolean isValid = controller.reportService.validateBlackList();
        Test.stopTest();

        System.assertEquals(false, isValid);
    }
 

    /*******************************************************************************
    *  Name            : testSetBillingPeriodRating1()
    *  Summary         : ClassRating = 1
    *  CreatedDate     : 19/11/2018
	*  ModifiedDate    : - 
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest 
    public static void testSetBillingPeriodRating1() {
        Account account = CreditFactoryUtils.createCreditReformAccountLU();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityLU(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContactLU(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '09379370071090');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemLU();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingLU();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingLU();
        insert creditFactoryOpportunity;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.createCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformReportRating1MockLU());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.reportService.getBuffer();
            controller.reportService.getRiskCategory();
            controller.reportService.getSecurityLevel();
            controller.reportService.getCreditLimitWeeklyPlus7();
            controller.reportService.getMaxCreditLimitWeeklyPlus7();
            controller.reportService.getMaxValueWeeklyPlus7();
            controller.reportService.getDepositWeeklyPlus7();
            controller.reportService.getCreditLimitBiWeeklyPlus7();
            controller.reportService.getMaxCreditLimitBiWeeklyPlus7();
            controller.reportService.getMaxValueBiWeeklyPlus7();
            controller.reportService.getDepositBiWeeklyPlus7();
            controller.reportService.getCreditLimitBiWeeklyPlus14();
            controller.reportService.getMaxCreditLimitBiWeeklyPlus14();
            controller.reportService.getMaxValueBiWeeklyPlus14();
            controller.reportService.getDepositBiWeeklyPlus14();
            controller.reportService.getCreditLimitMonthlyPlus7();
            controller.reportService.getMaxCreditLimitMonthlyPlus7();
            controller.reportService.getMaxValueBiWeeklyPlus7();
            controller.reportService.getDepositMonthlyPlus7();
            controller.reportService.getMaxCreditLimitMonthlyPlus14();
            controller.reportService.getDepositMonthlyPlus14();
            controller.reportService.getMaxCreditLimitMonthlyPlus21();
            controller.reportService.getDepositMonthlyPlus21();
            controller.reportService.getMaxCreditLimitMonthlyPlus27();
            controller.reportService.getDepositMonthlyPlus27();
            controller.reportService.getPaymentTerms();
            controller.reportService.getCreditLimit();
            controller.reportService.getMaxCreditLimit();
            controller.reportService.getMaxValue();
            controller.reportService.getDeposit();
            controller.reportService.getDecision();
            controller.changeToClosedWon();
            CreditCompany company = new CreditCompany();
            company.classRating = '1';
            controller.reportService.resetDeposit(company, 30, 7, 2000, 4000, 2000, 2700, opportunity.Id);
            controller.reportService.resetDecision(30, 7, 0, '1', null, null);
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 30', ApexPages.getMessages().get(0).getSummary());

        List<Opportunity> opportunitiesList = [
                SELECT StageName
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals('Closed Won', opportunitiesList.get(0).StageName);
    }


    /******************************************************************************
    *  Name            : testSetBillingPeriodRating2()
    *  Summary         : ClassRating = 2
    *  CreatedDate     : 19/11/2018
	*  ModifiedDate    : - 
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest 
    public static void testSetBillingPeriodRating2() {
        Account account = CreditFactoryUtils.createCreditReformAccountLU();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityLU(account.Id);
        opportunity.Total_consumption_l_month__c = 4500;
        // for warnings check
        opportunity.Rechnungsperiode_2__c = '14';
        opportunity.Zahlungsziel_2__c = '30';
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContactLU(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '09379370071090');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemLU();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingLU();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingLU();
        insert creditFactoryOpportunity;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.createCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformReportRating2MockLU());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.changeToPendingSEPAConfirmation();
            CreditCompany company = new CreditCompany();
            company.classRating = '2';
            controller.reportService.resetDeposit(company, 15, 7, 2000, 4000, 2000, 2700, opportunity.Id);
            controller.reportService.resetDecision(15, 7, 0, '2', null, null);
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 15', ApexPages.getMessages().get(0).getSummary());

        List<Opportunity> opportunitiesList = [
                SELECT StageName
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals('Pending Sales - SEPA Confirmation', opportunitiesList.get(0).StageName);
    }


    /*******************************************************************************
    *  Name            : testSetBillingPeriodRating3()
    *  Summary         : ClassRating = 3
    *  CreatedDate     : 19/11/2018
	*  ModifiedDate    : 22/11/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest 
    public static void testSetBillingPeriodRating3() {
        Account account = CreditFactoryUtils.createCreditReformAccountLU();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityLU(account.Id);
        opportunity.Total_consumption_l_month__c = 8000;
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContactLU(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '09379370071090');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemLU();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingLU();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingLU();
        insert creditFactoryOpportunity;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.createCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformReportRating3MockLU());
            controller = new CreditFactoryReportController();
            controller.init();
            CreditCompany company = new CreditCompany();
            company.classRating = '3';
            controller.reportService.resetDeposit(company, 7, 7, 2000, 4000, 2000, 2700, opportunity.Id);
            controller.reportService.resetDecision(7, 7, 0, '3', null, null);
            controller.changeBillingPeriodBySales();
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 7', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testSetBillingPeriodRating4()
    *  Summary         : ClassRating = 4 
    *  CreatedDate     : 19/11/2018
	*  ModifiedDate    : - 
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest 
    public static void testSetBillingPeriodRating4() {
         Account account = CreditFactoryUtils.createCreditReformAccountLU();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityLU(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContactLU(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '09379370071090');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemLU();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingLU();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingLU();
        insert creditFactoryOpportunity;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.createCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformReportRating4MockLU());
            controller = new CreditFactoryReportController();
            controller.init();
            CreditCompany company = new CreditCompany();
            company.classRating = '4';
            controller.reportService.resetDeposit(company, 15, 7, 2000, 4000, 2000, 2700, opportunity.Id);
            controller.reportService.resetDecision(15, 7, 0, '4', null, null);
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 15', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testSetBillingPeriodRating4Deposit()
    *  Summary         : ClassRating = 4 with deposit.
    *  CreatedDate     : 19/11/2018
	*  ModifiedDate    : - 
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest 
    public static void testSetBillingPeriodRating4Deposit() {
         Account account = CreditFactoryUtils.createCreditReformAccountLU();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityLU(account.Id);
        opportunity.Total_consumption_l_month__c = 6000;
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContactLU(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '09379370071090');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemLU();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingLU();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingLU();
        insert creditFactoryOpportunity;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.createCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformReportRating4MockLU());
            controller = new CreditFactoryReportController();
            controller.init();
            CreditCompany company = new CreditCompany();
            company.classRating = '4';
            controller.reportService.resetDeposit(company, 7, 7, 500, 1000, 500, 700, opportunity.Id);
            controller.reportService.resetDecision(7, 7, 0, '4', null, null);
            controller.backToOpportunity();
        Test.stopTest();

        System.assertEquals('Decision about deposit was accepted for your client.', ApexPages.getMessages().get(0).getSummary());

        List<Opportunity> opportunitiesList = [
                SELECT Security_level_H_he_der_Sicherheit__c
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals(4, opportunitiesList.get(0).Security_level_H_he_der_Sicherheit__c);
    }


    /*******************************************************************************
    *  Name            : testSetBillingPeriodRating5()
    *  Summary         : ClassRating = 5.
    *  CreatedDate     : 20/11/2018
    *  ModifiedDate    : - 
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest 
    public static void testSetBillingPeriodRating5() {
        Account account = CreditFactoryUtils.createCreditReformAccountLU();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityLU(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContactLU(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '09159152001684');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemLU();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingLU();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingLU();
        insert creditFactoryOpportunity;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.createCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformReportRating5MockLU());
            controller = new CreditFactoryReportController();
            controller.init();
            CreditCompany company = new CreditCompany();
            company.classRating = '5';
            controller.reportService.resetDeposit(company, 30, 7, 2000, 4000, 2000, 2700, opportunity.Id);
            controller.reportService.resetDecision(30, 7, 0, '5', null, null);
        Test.stopTest();

        System.assertEquals('Decision about deposit was accepted for your client.', ApexPages.getMessages().get(0).getSummary());

        List<Opportunity> opportunitiesList = [
                SELECT Security_level_H_he_der_Sicherheit__c
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals(70, opportunitiesList.get(0).Security_level_H_he_der_Sicherheit__c);
    }



    /*******************************************************************************
    *  Name            : testSetBillingPeriodRating6()
    *  Summary         : ClassRating = 6.
    *  CreatedDate     : 19/11/2018
	*  ModifiedDate    : - 
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest 
    public static void testSetBillingPeriodRating6() {
        Account account = CreditFactoryUtils.createCreditReformAccountLU();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityLU(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContactLU(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '09379370071090');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemLU();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingLU();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingLU();
        insert creditFactoryOpportunity;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.createCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformReportRating6MockLU());
            controller = new CreditFactoryReportController();
            controller.init();
            CreditCompany company = new CreditCompany();
            company.classRating = '6';
            controller.reportService.resetDeposit(company, 30, 7, 2000, 4000, 2000, 2700, opportunity.Id);
            controller.reportService.resetDecision(30, 7, 0, '6', null, null);
        Test.stopTest();

        System.assertEquals('Decision about deposit was accepted for your client.', ApexPages.getMessages().get(0).getSummary());

        List<Opportunity> opportunitiesList = [
                SELECT Security_level_H_he_der_Sicherheit__c
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals(110, opportunitiesList.get(0).Security_level_H_he_der_Sicherheit__c);
    }


    /*******************************************************************************
    *  Name            : testSetBillingPeriodNoRating()
    *  Summary         : ClassRating = null.
    *  CreatedDate     : 19/11/2018
	*  ModifiedDate    : - 
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testSetBillingPeriodNoRating() {
        Account account = CreditFactoryUtils.createCreditReformAccountLU();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityLU(account.Id);
        opportunity.Total_consumption_l_month__c = 800;
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContactLU(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '09379370071090');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemLU();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingLU();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingLU();
        insert creditFactoryOpportunity;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.createCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformReportNoRatingMockLU());
            controller = new CreditFactoryReportController();
            controller.init();
            CreditCompany company = new CreditCompany();
            company.classRating = null;
            controller.reportService.resetDeposit(company, 30, 7, 2200, 4400, 2000, 2700, opportunity.Id);
            controller.reportService.resetDecision(30, 7, 0, null, null, null);
        Test.stopTest();

        System.assertEquals('Decision about deposit was accepted for your client.', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testExistingCompany()
    *  Summary         : Lauch CF with already created Credit Factory Report
   	*  CreatedDate     : 19/11/2018
	*  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest 
    public static void testExistingCompany() {
        Account account = CreditFactoryUtils.createCreditReformAccountLU();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunityLU(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContactLU(account.Id);
        contact.LastName = contact.LastName + 'ÄäÖöÜüß';
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '09379370071090');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystemLU();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMappingLU();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMappingLU();
        insert creditFactoryOpportunity;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.createCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        Credit_Factory_Report__c creditReport = CreditFactoryUtils.createCreditreformReportLU(opportunity.Id);
        creditReport.Opportunity__c = opportunity.Id;
        insert creditReport;

        Credit_Factory_Report_Employee__c creditReportEmployee = CreditFactoryUtils.createCreditreformReportEmployeeLU(creditReport.Id);
        creditReportEmployee.Name = creditReportEmployee.Name + 'AEaeOEoeUEuess';
        insert creditReportEmployee;

        Test.startTest();
            controller = new CreditFactoryReportController();
            controller.init();
            controller.reportService.setUserSource('test');
            controller.reportService.getUserSource();
            controller.updateOpportunityByCredit();
            controller.reportService.setUserSource('E2E Long Form');
            controller.reportService.saveReports();
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 30', ApexPages.getMessages().get(0).getSummary());
    }
}