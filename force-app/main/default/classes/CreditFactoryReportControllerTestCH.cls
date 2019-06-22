@isTest
private class CreditFactoryReportControllerTestCH {
    public static CreditFactoryReportController controller;


    /*******************************************************************************
    *  Name            : testInvalidOpportunityParameter()
    *  Summary         : Leave empty opportunity id parameter.
    *  CreatedDate     : 15/10/2018
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
    *  CreatedDate     : 15/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testInvalidCompanyNumberParameter() {
        Account account = CreditFactoryUtils.createCrediconnectAccountCH();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrediconnectOpportunityCH(account.Id);
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
    *  CreatedDate     : 15/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testInvalidCreditSystem() {
        Account account = CreditFactoryUtils.createCrediconnectAccountCH();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrediconnectOpportunityCH(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '406471879');

        Test.startTest();
            controller = new CreditfactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Select Credit System Settings failed. Please check Billing Country or contact your administrator.', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testInvalidCreditSystemName()
    *  Summary         : Create Credit System custom setting not with "CrediconnectCH" name.
    *  CreatedDate     : 15/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testInvalidCreditSystemName() {
        Account account = CreditFactoryUtils.createCrediconnectAccountCH();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrediconnectOpportunityCH(account.Id);
        insert opportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrediconnectCreditSystemCH();
        creditSystem.Name = 'test';
        insert creditSystem;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '406471879');

        Test.startTest();
            controller = new CreditfactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Invalid name for Credit setting.', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testInvalidAccountMappingName()
    *  Summary         : Create Account mapping not with "CrediconnectCH" name.
    *  CreatedDate     : 15/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testInvalidAccountMappingName() {
        Account account = CreditFactoryUtils.createCrediconnectAccountCH();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrediconnectOpportunityCH(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '406471879');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrediconnectCreditSystemCH();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCrediconnectAccountMappingCH();
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
    *  Summary         : Create Opportunity mapping not with "CrediconnectCH" name.
    *  CreatedDate     : 15/10/2018
    *  ModifiedDate    : - 
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testInvalidOpportunityMappingName() {
        Account account = CreditFactoryUtils.createCrediconnectAccountCH();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrediconnectOpportunityCH(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '406471879');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrediconnectCreditSystemCH();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCrediconnectAccountMappingCH();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCrediconnectOpportunityMappingCH();
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
    *  Summary         : Put in Account address different from Crediconnect company name value                   
    *  CreatedDate     : 15/10/2018
    *  ModifiedDate    : - 
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testAddressValidation() {
        Account account = CreditFactoryUtils.createCrediconnectAccountCH();
        account.BillingCity = 'test';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrediconnectOpportunityCH(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCrediconnectContactCH(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '406471879');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrediconnectCreditSystemCH();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCrediconnectAccountMappingCH();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCrediconnectOpportunityMappingCH();
        insert creditFactoryOpportunity;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CrediconnectReportRating4MockCH());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.doUpdateAddress();
            controller.doUpdateWithAdditionalAddress();
            controller.doUpdateWithPostalAddress();
            controller.doUpdateWithRegisteredAddress();
        Test.stopTest();

        System.assertEquals('Account Billing and Shipping Addresses should be the same as Crefo address', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals('Fix all validation errors or refer to Credit.', ApexPages.getMessages().get(1).getSummary());
        System.assertEquals('Address has been updated.', ApexPages.getMessages().get(2).getSummary());
    }


    /******************************************************************************
    *  Name            : testContactValidation()
    *  Summary         : Put Last name in Contact different from Crediconnect contact Last name value.                    
    *  CreatedDate     : 15/10/2018
    *  ModifiedDate    : - 
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testContactValidation() {
        Account account = CreditFactoryUtils.createCrediconnectAccountCH();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrediconnectOpportunityCH(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCrediconnectContactCH(account.Id);
        contact.LastName = 'test';
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '406471879');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrediconnectCreditSystemCH();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCrediconnectAccountMappingCH();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCrediconnectOpportunityMappingCH();
        insert creditFactoryOpportunity;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CrediconnectReportRating4MockCH());
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Crediconnect Contact person doesn\'t exist in Account\'s Contacts', ApexPages.getMessages().get(0).getSummary());
    }


    /*****************************************************************************
    *  Name            : testCompanyNameValidation()
    *  Summary         : Put name in Account different from Creditreform company name value
    *  CreatedDate     : 15/10/2018
    *  ModifiedDate    : - 
    *  Parameters      : -
    *  Returns         : void
    ****************************************************************************/
    @isTest
    public static void testCompanyNameValidation() {
        Account account = CreditFactoryUtils.createCrediconnectAccountCH();
        account.Name = 'test';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrediconnectOpportunityCH(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCrediconnectContactCH(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '406471879');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrediconnectCreditSystemCH();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCrediconnectAccountMappingCH();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCrediconnectOpportunityMappingCH();
        insert creditFactoryOpportunity;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.createCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CrediconnectReportRating4MockCH());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.doUpdateCompanyName();
            controller.doUpdateWithAdditionalCompanyName();
        Test.stopTest();

        System.assertEquals('Account Name and Crefo Name mismatch', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals('Fix all validation errors or refer to Credit.', ApexPages.getMessages().get(1).getSummary());
        System.assertEquals('Account Name has been updated.', ApexPages.getMessages().get(2).getSummary());
    }


    /******************************************************************************
    *  Name            : testTaxIdValidation()
    *  Summary         : Put Tax Id in Account different from Creditreform company value.                      
    *  CreatedDate     : 15/10/2018
    *  ModifiedDate    : - 
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testTaxIdValidation() {
        Account account = CreditFactoryUtils.createCrediconnectAccountCH();
        account.Steuernummer__c = 'test';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrediconnectOpportunityCH(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCrediconnectContactCH(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '406471879');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrediconnectCreditSystemCH();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCrediconnectAccountMappingCH();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCrediconnectOpportunityMappingCH();
        insert creditFactoryOpportunity;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CrediconnectReportRating4MockCH());
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
    *  CreatedDate     : 15/10/2018
    *  ModifiedDate    : - 
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testVatNumberValidation() {
        Account account = CreditFactoryUtils.createCrediconnectAccountCH();
        account.Umsatzsteuer_ID__c = 'test';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrediconnectOpportunityCH(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCrediconnectContactCH(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '406471879');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrediconnectCreditSystemCH();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCrediconnectAccountMappingCH();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCrediconnectOpportunityMappingCH();
        insert creditFactoryOpportunity;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CrediconnectReportRating4MockCH());
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
    *  CreatedDate     : 15/10/2018
    *  ModifiedDate    : - 
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testLostOpportunitiesValidation() {
        Account account = CreditFactoryUtils.createCrediconnectAccountCH();
        insert account;

        List<Opportunity> opportunitiesList = new List<Opportunity>();
        Opportunity opportunity = CreditFactoryUtils.createCrediconnectOpportunityCH(account.Id);
        opportunitiesList.add(opportunity);

        Opportunity lostOpportunity = CreditFactoryUtils.createCrediconnectOpportunityCH(account.Id);
        opportunity.StageName = 'Closed Lost';
        opportunity.Gruende_verloren__c = 'Refused Credit';
        opportunitiesList.add(lostOpportunity);
        insert opportunitiesList;

        Contact contact = CreditFactoryUtils.createCrediconnectContactCH(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '406471879');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrediconnectCreditSystemCH();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCrediconnectAccountMappingCH();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCrediconnectOpportunityMappingCH();
        insert creditFactoryOpportunity;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CrediconnectReportRating4MockCH());
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Credit Check was rejected for one of the Opportunities linked with your Account or its Contacts. Please refer to Credit.', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testSetBillingPeriodRating1()
    *  Summary         : ClassRating = 1
    *  CreatedDate     : 29/11/2018
    *  ModifiedDate    : - 
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testSetBillingPeriodRating1() {
        Account account = CreditFactoryUtils.createCrediconnectAccountCH();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrediconnectOpportunityCH(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCrediconnectContactCH(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '406471879');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrediconnectCreditSystemCH();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCrediconnectAccountMappingCH();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCrediconnectOpportunityMappingCH();
        insert creditFactoryOpportunity;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.createCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CrediconnectReportRating1MockCH());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.changeToPendingSEPAConfirmation();
            // coverage cf code that e2e uses
            CreditCompany company = new CreditCompany();
            company.classRating = '1';
            controller.reportService.resetDeposit(company, 30, 27, 1000, 2000, 700, 500, opportunity.Id);
            controller.reportService.resetDecision(30, 27, 0, '1', null, company);
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 30', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals('Payment Terms can be set to 27', ApexPages.getMessages().get(1).getSummary());

        List<Opportunity> opportunitiesList = [
                SELECT StageName
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals('Pending Sales - SEPA Confirmation', opportunitiesList.get(0).StageName);
    }


    /*******************************************************************************
    *  Name            : testSetBillingPeriodRating1_2()
    *  Summary         : ClassRating = 1, exception with lower payment terms
    *  CreatedDate     : 04/03/2019
    *  ModifiedDate    : - 
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testSetBillingPeriodRating1_2() {
        Account account = CreditFactoryUtils.createCrediconnectAccountCH();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrediconnectOpportunityCH(account.Id);
        opportunity.Einwilligung_Lastschriftverfahren__c = true;
        opportunity.Zahlungsart__c = 'Banküberweisung';
        opportunity.Total_consumption_l_month__c = 800;
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCrediconnectContactCH(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '406471879');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrediconnectCreditSystemCH();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCrediconnectAccountMappingCH();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCrediconnectOpportunityMappingCH();
        insert creditFactoryOpportunity;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.createCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CrediconnectReportRating1_2MockCH());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.changeToClosedWon();
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 30', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals('Payment Terms can be set to 14', ApexPages.getMessages().get(1).getSummary());

        List<Opportunity> opportunitiesList = [
                SELECT StageName
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals('Closed Won', opportunitiesList.get(0).StageName);
    }


    /*******************************************************************************
    *  Name            : testSetBillingPeriodRating2()
    *  Summary         : ClassRating = 2
    *  CreatedDate     : 29/11/2018
    *  ModifiedDate    : - 
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testSetBillingPeriodRating2() {
        Account account = CreditFactoryUtils.createCrediconnectAccountCH();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrediconnectOpportunityCH(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCrediconnectContactCH(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '406471879');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrediconnectCreditSystemCH();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCrediconnectAccountMappingCH();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCrediconnectOpportunityMappingCH();
        insert creditFactoryOpportunity;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.createCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CrediconnectReportRating2MockCH());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.changeToClosedWon();
            // coverage cf code that e2e uses
            CreditCompany company = new CreditCompany();
            company.classRating = '2';
            controller.reportService.resetDeposit(company, 30, 27, 1000, 2100, 500, 400, opportunity.Id);
            controller.reportService.resetDecision(30, 27, 0, '2', null, company);
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 30', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals('Payment Terms can be set to 27', ApexPages.getMessages().get(1).getSummary());

        List<Opportunity> opportunitiesList = [
                SELECT StageName
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals('Closed Won', opportunitiesList.get(0).StageName);
    }


    /*******************************************************************************
    *  Name            : testSetBillingPeriodRating2_2()
    *  Summary         : ClassRating = 1, exception with lower payment terms
    *  CreatedDate     : 04/03/2019
    *  ModifiedDate    : - 
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testSetBillingPeriodRating2_2() {
        Account account = CreditFactoryUtils.createCrediconnectAccountCH();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrediconnectOpportunityCH(account.Id);
        opportunity.Einwilligung_Lastschriftverfahren__c = true;
        opportunity.Zahlungsart__c = 'Banküberweisung';
        opportunity.Total_consumption_l_month__c = 350;
        opportunity.Sec_Channel__c = 'Inbound';
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCrediconnectContactCH(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '406471879');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrediconnectCreditSystemCH();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCrediconnectAccountMappingCH();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCrediconnectOpportunityMappingCH();
        insert creditFactoryOpportunity;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.createCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CrediconnectReportRating2_2MockCH());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.changeToClosedWon();
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 30', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals('Payment Terms can be set to 21', ApexPages.getMessages().get(1).getSummary());

        List<Opportunity> opportunitiesList = [
                SELECT StageName
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals('Closed Won', opportunitiesList.get(0).StageName);
    }


    /*******************************************************************************
    *  Name            : testSetBillingPeriodRating3()
    *  Summary         : ClassRating = 3
    *  CreatedDate     : 29/11/2018
    *  ModifiedDate    : - 
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testSetBillingPeriodRating3() {
        Account account = CreditFactoryUtils.createCrediconnectAccountCH();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrediconnectOpportunityCH(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCrediconnectContactCH(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '406471879');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrediconnectCreditSystemCH();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCrediconnectAccountMappingCH();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCrediconnectOpportunityMappingCH();
        insert creditFactoryOpportunity;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.createCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CrediconnectReportRating3MockCH());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.changeToClosedWon();
            // coverage cf code that e2e uses
            CreditCompany company = new CreditCompany();
            company.classRating = '3';
            controller.reportService.resetDeposit(company, 30, 27, 500, 1000, 300, 200, opportunity.Id);
            controller.reportService.resetDecision(30, 27, 0, '3', null, company);
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 30', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals('Payment Terms can be set to 27', ApexPages.getMessages().get(1).getSummary());

        List<Opportunity> opportunitiesList = [
                SELECT StageName
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals('Closed Won', opportunitiesList.get(0).StageName);
    }


    /*******************************************************************************
    *  Name            : testSetBillingPeriodRating4()
    *  Summary         : ClassRating = 4
    *  CreatedDate     : 15/10/2018
    *  ModifiedDate    : - 
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testSetBillingPeriodRating4() {
        Account account = CreditFactoryUtils.createCrediconnectAccountCH();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrediconnectOpportunityCH(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCrediconnectContactCH(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '406471879');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrediconnectCreditSystemCH();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCrediconnectAccountMappingCH();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCrediconnectOpportunityMappingCH();
        insert creditFactoryOpportunity;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.createCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CrediconnectReportRating4MockCH());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.reportService.setUserSource(null);
            controller.reportService.getUserSource();
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
            controller.reportService.getMaxValueMonthlyPlus7();
            controller.reportService.getDepositMonthlyPlus7();
            controller.reportService.getCreditLimitMonthlyPlus7();
            controller.reportService.getMaxCreditLimitMonthlyPlus7();
            controller.reportService.getMaxValueMonthlyPlus7();
            controller.reportService.getDepositMonthlyPlus7();
            controller.reportService.getCreditLimitMonthlyPlus14();
            controller.reportService.getMaxCreditLimitMonthlyPlus14();
            controller.reportService.getDepositMonthlyPlus14();
            controller.reportService.getCreditLimitMonthlyPlus21();
            controller.reportService.getMaxCreditLimitMonthlyPlus21();
            controller.reportService.getDepositMonthlyPlus21();
            controller.reportService.getCreditLimitMonthlyPlus27();
            controller.reportService.getMaxCreditLimitMonthlyPlus27();
            controller.reportService.getMaxValueMonthlyPlus27();
            controller.reportService.getDepositMonthlyPlus27();
            controller.reportService.getPaymentTerms();
            controller.reportService.getCreditLimit();
            controller.reportService.getMaxCreditLimit();
            controller.reportService.getMaxValue();
            controller.reportService.getDeposit();
            controller.reportService.getDecision();
            controller.reportService.validateBlackList();
            controller.reportService.getInternalId();
            controller.changeToPendingSEPAConfirmation();
            CreditCompany company = new CreditCompany();
            company.classRating = '4';
            controller.reportService.resetDeposit(company, 30, 27, 1000, 2000, 2500, 3000, opportunity.Id);
            controller.reportService.resetDecision(30, 27, 0, '4', null, company);
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 30', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals('Payment Terms can be set to 27', ApexPages.getMessages().get(1).getSummary());

        List<Opportunity> opportunitiesList = [
                SELECT StageName
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals('Pending Sales - SEPA Confirmation', opportunitiesList.get(0).StageName);
    }


    /*******************************************************************************
    *  Name            : testSetBillingPeriodRating4_2()
    *  Summary         : ClassRating = 4, exception with lower payment terms
    *  CreatedDate     : 16/10/2018
    *  ModifiedDate    : - 
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testSetBillingPeriodRating4_2() {
        Account account = CreditFactoryUtils.createCrediconnectAccountCH();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrediconnectOpportunityCH(account.Id);
        opportunity.Einwilligung_Lastschriftverfahren__c = true;
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCrediconnectContactCH(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '406471879');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrediconnectCreditSystemCH();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCrediconnectAccountMappingCH();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCrediconnectOpportunityMappingCH();
        insert creditFactoryOpportunity;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.createCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CrediconnectReportRating4_2MockCH());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.changeToClosedWon();
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 30', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals('Payment Terms can be set to 7', ApexPages.getMessages().get(1).getSummary());

        List<Opportunity> opportunitiesList = [
                SELECT StageName
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals('Closed Won', opportunitiesList.get(0).StageName);
    }


    /*******************************************************************************
    *  Name            : testSetBillingPeriodRating5()
    *  Summary         : ClassRating = 5.
    *  CreatedDate     : 15/10/2018
    *  ModifiedDate    : 04/03/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testSetBillingPeriodRating5() {
         Account account = CreditFactoryUtils.createCrediconnectAccountCH();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrediconnectOpportunityCH(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCrediconnectContactCH(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '406471879');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrediconnectCreditSystemCH();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCrediconnectAccountMappingCH();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCrediconnectOpportunityMappingCH();
        insert creditFactoryOpportunity;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.createCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CrediconnectReportRating5MockCH());
            controller = new CreditFactoryReportController();
            controller.init();
            // coverage cf code that e2e uses
            CreditCompany company = new CreditCompany();
            company.classRating = '5';
            controller.reportService.resetDeposit(company, 30, 27, 1000, 2000, 700, 500, opportunity.Id);
            controller.reportService.resetDecision(30, 27, 700, '1', null, company);
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
    *  CreatedDate     : 16/10/2018
    *  ModifiedDate    : 04/03/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testSetBillingPeriodRating6() {
         Account account = CreditFactoryUtils.createCrediconnectAccountCH();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrediconnectOpportunityCH(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCrediconnectContactCH(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '406471879');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrediconnectCreditSystemCH();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCrediconnectAccountMappingCH();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCrediconnectOpportunityMappingCH();
        insert creditFactoryOpportunity;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.createCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CrediconnectReportRating6MockCH());
            controller = new CreditFactoryReportController();
            controller.init();
            CreditCompany company = new CreditCompany();
            company.classRating = '6';
            controller.reportService.resetDeposit(company, 30, 27, 1000, 2000, 700, 500, opportunity.Id);
            controller.reportService.resetDecision(30, 27, 1200, '1', null, company);
        Test.stopTest();

        System.assertEquals('Decision about deposit was accepted for your client.', ApexPages.getMessages().get(0).getSummary());

        List<Opportunity> opportunitiesList = [
                SELECT Security_level_H_he_der_Sicherheit__c
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals(110, opportunitiesList.get(0).Security_level_H_he_der_Sicherheit__c);
    }


    /*******************************************************************************
    *  Name            : testExistingCompany()
    *  Summary         : Check set company from existing credit report 
    *  CreatedDate     : 16/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest 
    public static void testExistingCompany() {
        Account account = CreditFactoryUtils.createCrediconnectAccountCH();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrediconnectOpportunityCH(account.Id);
        opportunity.Total_consumption_l_month__c = 800;
        opportunity.Zahlungsart__c = 'Banküberweisung';
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCrediconnectContactCH(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '406471879');

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrediconnectCreditSystemCH();
        insert creditSystem;

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCrediconnectAccountMappingCH();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCrediconnectOpportunityMappingCH();
        insert creditFactoryOpportunity;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.createCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        Credit_Factory_Report__c creditReport = CreditFactoryUtils.createCrediconnectReportCH(opportunity.Id);
        creditReport.Opportunity__c = opportunity.Id;
        insert creditReport;

        Credit_Factory_Report_Employee__c creditReportEmployee = CreditFactoryUtils.createCrediconnectReportEmployeeCH(creditReport.Id);
        creditReportEmployee.Name = creditReportEmployee.Name;
        insert creditReportEmployee;

        Test.startTest();
            controller = new CreditFactoryReportController();
            controller.init();
            controller.changeBillingPeriodBySales();
            controller.updateOpportunityByCredit();
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 30', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals('Payment Terms can be set to 14', ApexPages.getMessages().get(1).getSummary());
    }
}