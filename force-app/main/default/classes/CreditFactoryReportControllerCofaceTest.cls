@isTest
private class CreditFactoryReportControllerCofaceTest {
    public static CreditfactoryReportController controller;


    /*******************************************************************************
    *  Name            : testInvalidOpportunityParameter()
    *  Summary         : Leave empty opportunity id parameter.
    *  CreatedDate     : 08/03/2018
    *  ModifiedDate    : 08/03/2018
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
    *  CreatedDate     : 08/03/2018
    *  ModifiedDate    : 08/03/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testInvalidCompanyNumberParameter() {
        Account account = CreditFactoryUtils.createCofaceAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
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
    *  CreatedDate     : 08/03/2018
    *  ModifiedDate    : 08/03/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testInvalidCreditSystem() {
        Account account = CreditFactoryUtils.createCofaceAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

        Test.startTest();
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals(ApexPages.getMessages().get(0).getSummary(), 'Select Credit System Settings failed. Please check Billing Country or contact your administrator.');
    }


    /*******************************************************************************
    *  Name            : testInvalidCreditSystemName()
    *  Summary         : Create Credit System custom setting not with "Coface" name.
    *  CreatedDate     : 08/03/2018
    *  ModifiedDate    : 08/03/2018
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

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

        Test.startTest();
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Invalid name for Credit setting.', ApexPages.getMessages().get(0).getSummary());
    } 


    /*******************************************************************************
    *  Name            : testInvalidAccountMappingName()
    *  Summary         : Create Account mapping not with "Coface" name.
    *  CreatedDate     : 08/03/2018
    *  ModifiedDate    : 08/03/2018 
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testInvalidAccountMappingName() {
        Account account = CreditFactoryUtils.createCofaceAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

        Credit_Factory_Account__c creditFactoryAccount = new Credit_Factory_Account__c(Name = 'Test');
        insert creditFactoryAccount;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCofaceCreditSystem();
        insert creditSystem;

        Test.startTest();
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Account mapping select error. ' + CreditFactoryUtilities.CONTACT_ADMIN, ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testInvalidOpportunityMappingName()
    *  Summary         : Create Opportunity mapping not with "Coface" name.
    *  CreatedDate     : 08/03/2018
    *  ModifiedDate    : 08/03/2018 
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testInvalidOpportunityMappingName() {
        Account account = CreditFactoryUtils.createCofaceAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

        Credit_Factory_Account__c creditFactoryAccount = new Credit_Factory_Account__c(Name = 'Coface');
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = new Credit_Factory_Opportunity__c(Name = 'Test');
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCofaceCreditSystem();
        insert creditSystem;

        Test.startTest();
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Opportunity mapping select error. ' + CreditFactoryUtilities.CONTACT_ADMIN, ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testAddressValidation()
    *  Summary         : Put in Account address different from Coface company name value                   
    *  CreatedDate     : 08/03/2018
    *  ModifiedDate    : 08/03/2018 
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testAddressValidation() {
        Account account = CreditFactoryUtils.createCofaceAccount();
        account.BillingCity = 'test';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCofaceAccountMapping();
        insert creditFactoryAccount;

        Contact contact = CreditFactoryUtils.createCofaceContact(account.Id);
        insert contact;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCofaceOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCofaceCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CofaceReportRating1Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.doUpdateAddress();
        Test.stopTest();

        System.assertEquals('Account Billing and Shipping Addresses should be the same as Coface address', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals('Fix all validation errors or refer to Credit.', ApexPages.getMessages().get(1).getSummary());
        System.assertEquals('Address has been updated.', ApexPages.getMessages().get(2).getSummary());
    }


    /******************************************************************************
    *  Name            : testContactValidation()
    *  Summary         : Put in Contact Last name different from Coface contact Last name value                       
    *  CreatedDate     : 08/03/2018
    *  ModifiedDate    : 08/03/2018
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testContactValidation() {
        Account account = CreditFactoryUtils.createCofaceAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCofaceContact(account.Id);
        contact.LastName = 'test';
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCofaceAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCofaceOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCofaceCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CofaceReportRating1Mock());
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Coface Contact person doesn\'t exist in Account\'s Contacts', ApexPages.getMessages().get(0).getSummary());
    }


    /*****************************************************************************
    *  Name            : testCompanyNameValidation()
    *  Summary         : Put in Account name different from Coface company name value
    *  CreatedDate     : 08/03/2018
    *  ModifiedDate    : 08/03/2018
    *  Parameters      : -
    *  Returns         : void
    ****************************************************************************/
    @isTest
    public static void testCompanyNameValidation() {
        Account account = CreditFactoryUtils.createCofaceAccount();
        account.Name = 'test';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCofaceContact(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

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
            Test.setMock(HttpCalloutMock.class, new CofaceReportRating1Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.doUpdateCompanyName();
        Test.stopTest();

        System.assertEquals('Account Name and Coface Name mismatch', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals('Fix all validation errors or refer to Credit.', ApexPages.getMessages().get(1).getSummary());
        System.assertEquals('Account Name has been updated.', ApexPages.getMessages().get(2).getSummary());
    }


    /******************************************************************************
    *  Name            : testTaxIdValidation()
    *  Summary         : Put in Account Tax Id different from Coface company value.                      
    *  CreatedDate     : 08/03/2018
    *  ModifiedDate    : 08/03/2018 
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testTaxIdValidation() {
        Account account = CreditFactoryUtils.createCofaceAccount();
        account.Steuernummer__c = 'test';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCofaceContact(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCofaceAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCofaceOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCofaceCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CofaceReportRating1Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.doUpdateTaxId();
        Test.stopTest();

        System.assertEquals('Account Tax ID mismatch (' + CofaceWebservice.CREDIT_SYSTEM_NAME + 
            ' to Account Tax ID)', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals('Fix all validation errors or refer to Credit.', ApexPages.getMessages().get(1).getSummary());
        System.assertEquals('Account Tax ID has been updated.', ApexPages.getMessages().get(2).getSummary());
    }


    /******************************************************************************
    *  Name            : testVatNumberValidation()
    *  Summary         : Put in Account VAT Number different from Coface company value.                      
    *  CreatedDate     : 08/03/2018
    *  ModifiedDate    : 08/03/2018 
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testVatNumberValidation() {
        Account account = CreditFactoryUtils.createCofaceAccount();
        account.Umsatzsteuer_ID__c = 'test';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCofaceContact(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCofaceAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCofaceOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCofaceCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CofaceReportRating1Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.doUpdateVatNumber();
        Test.stopTest();

        System.assertEquals('Account VAT number mismatch (' + CofaceWebservice.CREDIT_SYSTEM_NAME + 
            ' to Account VAT number)', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals('Fix all validation errors or refer to Credit.', ApexPages.getMessages().get(1).getSummary());
        System.assertEquals('Account VAT number has been updated.', ApexPages.getMessages().get(2).getSummary());
    }


    /******************************************************************************
    *  Name            : testTradeRegisterNumberValidation()
    *  Summary         : Put in Account Trade Register Number different from Coface company value.                      
    *  CreatedDate     : 12/12/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testTradeRegisterNumberValidation() {
        Account account = CreditFactoryUtils.createCofaceAccount();
        account.HR_Abteilung_HRA_HRB_und_HR_Nummer__c = 'test';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCofaceContact(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCofaceAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCofaceOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCofaceCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CofaceReportRating1Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.doUpdateTradeRegisterNumber();
        Test.stopTest();

        System.assertEquals('Account Trade Register Number mismatch (' + CofaceWebservice.CREDIT_SYSTEM_NAME + 
            ' to Account Trade Register Number)', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals('Fix all validation errors or refer to Credit.', ApexPages.getMessages().get(1).getSummary());
        System.assertEquals('Account Trade Register Number has been updated.', ApexPages.getMessages().get(2).getSummary());
    }


    /******************************************************************************
    *  Name            : testLostOpportunitiesValidation()
    *  Summary         : Create Closed Lost Opportunity related to the current Opportunity's Account
    *  CreatedDate     : 02/04/2018
    *  ModifiedDate    : 02/04/2018 
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testLostOpportunitiesValidation() {
        Account account = CreditFactoryUtils.createCofaceAccount();
        insert account;

        List<Opportunity> opportunitiesList = new List<Opportunity>();
        Opportunity opportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
        opportunitiesList.add(opportunity);

        Opportunity lostOpportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
        opportunity.StageName = 'Closed Lost';
        opportunity.Gruende_verloren__c = 'Refused Credit';
        opportunitiesList.add(lostOpportunity);
        insert opportunitiesList;

        Contact contact = CreditFactoryUtils.createCofaceContact(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCofaceAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCofaceOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCofaceCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CofaceReportRating1Mock());
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Credit Check was rejected for one of the Opportunities linked with your Account or its Contacts. Please refer to Credit.', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testBlackListValidation()
    *  Summary         : Create Credit_Black_List_Company__c and Opportunity objects with
                         the same fields   
    *  CreatedDate     : 18/12/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testBlackListValidation() {
        Account account = CreditFactoryUtils.createCofaceAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCofaceContact(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCofaceAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCofaceOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCofaceCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Credit_Black_List_Company__c blackList = CreditFactoryUtils.doCreateCreditBlackListCompany(account.Name);
        blackList.Customer_Id__c = 'HU';
        insert blackList;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CofaceReportRating1Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            Boolean isCompanyNotInBlackList = controller.reportService.validateBlackList();
        Test.stopTest();

        System.assertEquals(false, isCompanyNotInBlackList);
    }


    /*******************************************************************************
    *  Name            : testPITValidation()
    *  Summary         : Set mock with invalid financial data for the last years
                         the same fields   
    *  CreatedDate     : 22/03/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testPITValidation() {
        Account account = CreditFactoryUtils.createCofaceAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCofaceContact(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCofaceAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCofaceOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCofaceCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CofaceReportFinancialDataMock());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.changeToContractCheck();
        Test.stopTest();

        List<Credit_Factory_Report__c> reportsList = [
                SELECT Profit_Loss_Last_Year__c, Profit_Loss_Year_Before_Last__c, Turn_Over_Last_Year__c
                FROM Credit_Factory_Report__c
                LIMIT 1];

        System.assertEquals(reportsList.get(0).Profit_Loss_Last_Year__c, '-31000000.00');
        System.assertEquals(reportsList.get(0).Profit_Loss_Year_Before_Last__c , '31000000.00');
        System.assertEquals(reportsList.get(0).Turn_Over_Last_Year__c, '31000000.00');
        System.assertEquals('Financial details require additional review. Please refer to Credit.', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testOrderRequest()
    *  Summary         : Test company search when COFACE SELECT PREMIUM is not available 
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

        Contact contact = CreditFactoryUtils.createCofaceContact(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

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
            Test.setMock(HttpCalloutMock.class, new CofaceOrderMock());
            controller = new CreditFactoryReportController();
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
    *  Name            : testOrderRequest2()
    *  Summary         : Test company select when date of last major update is too old 
    *  CreatedDate     : 13/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testOrderRequest2() {
        Account account = CreditFactoryUtils.createCofaceAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCofaceContact(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

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
            Test.setMock(HttpCalloutMock.class, new CofaceOrderMock2());
            controller = new CreditFactoryReportController();
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
    *  Name            : testSetBillingPeriodRating1()
    *  Summary         : ClassRating = 1
    *  CreatedDate     : 08/03/2018
    *  ModifiedDate    : 08/03/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testSetBillingPeriodRating1() {
        Account account = CreditFactoryUtils.createCofaceAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
        // for warnings check
        opportunity.Rechnungsperiode_2__c = '7';
        opportunity.Zahlungsziel_2__c = '7';
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCofaceContact(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

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
            Test.setMock(HttpCalloutMock.class, new CofaceReportRating1Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.changeBillingPeriodBySales();
            controller.reportService.getBuffer();
            controller.reportService.getRiskCategory();
            controller.reportService.getSecurityLevel();
            controller.reportService.getCreditLimitWeeklyPlus7();
            controller.reportService.getMaxCreditLimitWeeklyPlus7();
            controller.reportService.getDepositWeeklyPlus7();
            controller.reportService.getCreditLimitBiWeeklyPlus14();
            controller.reportService.getMaxCreditLimitBiWeeklyPlus14();
            controller.reportService.getDepositBiWeeklyPlus14();
            controller.reportService.getPaymentTerms();
            controller.reportService.getCreditLimit();
            controller.reportService.getMaxCreditLimit();
            controller.reportService.getMaxValue();
            controller.reportService.getDeposit();
            controller.reportService.getDecision();
            controller.reportService.setUserSource('E2E Long Form');
            controller.reportService.getUserSource();
            CreditCompany company = new CreditCompany();
            company.classRating = '1';
            controller.reportService.resetDeposit(company, 7, 7, 20000, 30000, 3500, 100, opportunity.Id);
            controller.reportService.resetDecision(7, 7, 0, '1', null, null);
        Test.stopTest();

        System.assertEquals('Decision about deposit was accepted for your client.', ApexPages.getMessages().get(0).getSummary());

        List<Opportunity> opportunitiesList = [
                SELECT Security_level_H_he_der_Sicherheit__c
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals(110, opportunitiesList.get(0).Security_level_H_he_der_Sicherheit__c);
    }


    /*******************************************************************************
    *  Name            : testSetBillingPeriodRating6()
    *  Summary         : ClassRating = 6
    *  CreatedDate     : 08/03/2018
    *  ModifiedDate    : 08/03/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testSetBillingPeriodRating4() {
        Account account = CreditFactoryUtils.createCofaceAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCofaceContact(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

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
            Test.setMock(HttpCalloutMock.class, new CofaceReportRating4Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.updateOpportunityByCredit();
            controller.changeToContractCheck();
            CreditCompany company = new CreditCompany();
            company.classRating = '4';
            controller.reportService.resetDeposit(company, 15, 14, 40000, 70000, 3500, 100, opportunity.Id);
            controller.reportService.resetDecision(15, 14, 0, '4', null, null);
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 15', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals('Payment Terms can be set to 14', ApexPages.getMessages().get(1).getSummary());
        System.assertEquals(0, controller.reportService.getDeposit());

        List<Opportunity> opportunitiesList = [
                SELECT StageName
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals('Pending Credit - Contract Check', opportunitiesList.get(0).StageName);
    }


    /*******************************************************************************
    *  Name            : testSetBillingPeriodRating6()
    *  Summary         : ClassRating = 6
    *  CreatedDate     : 08/03/2018
    *  ModifiedDate    : 08/03/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testSetBillingPeriodRating6() {
        Account account = CreditFactoryUtils.createCofaceAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCofaceContact(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

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
            Test.setMock(HttpCalloutMock.class, new CofaceReportRating6Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.updateOpportunityByCredit();
            controller.changeToContractCheck();
            CreditCompany company = new CreditCompany();
            company.classRating = '6';
            controller.reportService.resetDeposit(company, 15, 14, 30000, 70000, 3500, 100, opportunity.Id);
            controller.reportService.resetDecision(15, 14, 0, '6', null, null);
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 15', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals('Payment Terms can be set to 14', ApexPages.getMessages().get(1).getSummary());
        System.assertEquals(0, controller.reportService.getDeposit());

        List<Opportunity> opportunitiesList = [
                SELECT StageName
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals('Pending Credit - Contract Check', opportunitiesList.get(0).StageName);
    }


    /*******************************************************************************
    *  Name            : testExistingCompany()
    *  Summary         : Check success search company
    *  CreatedDate     : 08/03/2018
    *  ModifiedDate    : 08/03/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest 
    public static void testExistingCompany() {
        Account account = CreditFactoryUtils.createCofaceAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCofaceOpportunity(account.Id);
        opportunity.Total_consumption_l_month__c = 10000;
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCofaceContact(account.Id);
        contact.LastName = 'ÁáÉéÍíÓóÖöŐőÚúÜüŰű';
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

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
        creditReport.Class_Rating__c = '4';
        insert creditReport;

        Credit_Factory_Report_Employee__c creditReportEmployee = CreditFactoryUtils.createCofaceReportEmployee();
        creditReportEmployee.Credit_Factory_Report__c = creditReport.Id;
        creditReportEmployee.Name = creditReportEmployee.Name + 'AaEeIiOoOoOoUuUuUu';
        insert creditReportEmployee;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.doCreateCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        Test.startTest();
            controller = new CreditFactoryReportController();
            controller.init();
            controller.changeToContractCheck();
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 7', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals('Payment Terms can be set to 7', ApexPages.getMessages().get(1).getSummary());

        List<Opportunity> opportunitiesList = [
                SELECT StageName
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals('Pending Credit - Contract Check', opportunitiesList.get(0).StageName);
    }
}