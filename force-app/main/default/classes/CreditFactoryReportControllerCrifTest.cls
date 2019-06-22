@isTest
private class CreditFactoryReportControllerCrifTest {
    public static CreditfactoryReportController controller;


    /*******************************************************************************
    *  Name            : testInvalidOpportunityParameter()
    *  Summary         : Leave empty opportunity id parameter.
    *  CreatedDate     : 16/01/2018
    *  ModifiedDate    : 16/01/2018
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
    *  CreatedDate     : 16/01/2018
    *  ModifiedDate    : 16/01/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testInvalidCompanyNumberParameter() {
        Account account = CreditFactoryUtils.createCrifAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrifOpportunity(account.Id);
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
    *  CreatedDate     : 16/01/2018
    *  ModifiedDate    : 16/01/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testInvalidCreditSystem() {
        Account account = CreditFactoryUtils.createCrifAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrifOpportunity(account.Id);
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
    *  Summary         : Create Credit System custom setting not with "Crif" name.
    *  CreatedDate     : 16/01/2018
    *  ModifiedDate    : 16/01/2018
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

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

        Test.startTest();
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Invalid name for Credit setting.', 
            ApexPages.getMessages().get(0).getSummary());
    } 


    /*******************************************************************************
    *  Name            : testInvalidAccountMappingName()
    *  Summary         : Create Account mapping not with "Crif" name.
    *  CreatedDate     : 16/01/2018
    *  ModifiedDate    : 16/01/2018 
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testInvalidAccountMappingName() {
        Account account = CreditFactoryUtils.createCrifAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrifOpportunity(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

        Credit_Factory_Account__c creditFactoryAccount = new Credit_Factory_Account__c(Name = 'Test');
        insert creditFactoryAccount;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrifCreditSystem();
        insert creditSystem;

        Test.startTest();
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Account mapping select error. ' + CreditFactoryUtilities.CONTACT_ADMIN, ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testInvalidOpportunityMappingName()
    *  Summary         : Create Opportunity mapping not with "Crif" name.
    *  CreatedDate     : 16/01/2018
    *  ModifiedDate    : 16/01/2018 
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testInvalidOpportunityMappingName() {
        Account account = CreditFactoryUtils.createCrifAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrifOpportunity(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

        Credit_Factory_Account__c creditFactoryAccount = new Credit_Factory_Account__c(Name = 'Crif');
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = new Credit_Factory_Opportunity__c(Name = 'Test');
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrifCreditSystem();
        insert creditSystem;

        Test.startTest();
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Opportunity mapping select error. ' + CreditFactoryUtilities.CONTACT_ADMIN, ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testAddressValidation()
    *  Summary         : Put in Account address value different from Crif address.
    *  CreatedDate     : 13/08/2018
    *  ModifiedDate    : - 
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testAddressValidation() {
        Account account = CreditFactoryUtils.createCrifAccount();
        account.BillingCity = 'test';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrifOpportunity(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCrifAccountMapping();
        insert creditFactoryAccount;

        Contact contact = CreditFactoryUtils.createCrifContact(account.Id);
        insert contact;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCrifOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrifCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CrifReportRating3Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.doUpdateAddress();
            controller.doUpdateWithPostalAddress();
            controller.doUpdateWithRegisteredAddress();
        Test.stopTest();

        System.assertEquals('Account Billing and Shipping Addresses should be the same as one of the Crif addresses', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals('Fix all validation errors or refer to Credit.', ApexPages.getMessages().get(1).getSummary());
        System.assertEquals('Address has been updated.', ApexPages.getMessages().get(2).getSummary());
    }


    /******************************************************************************
    *  Name            : testContactValidation()
    *  Summary         : Put in Contact Last name different from Crif contact Last name value                       
    *  CreatedDate     : 16/01/2018
    *  ModifiedDate    : 16/01/2018
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testContactValidation() {
        Account account = CreditFactoryUtils.createCrifAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrifOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCrifContact(account.Id);
        contact.LastName = 'test';
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCrifAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCrifOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrifCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CrifReportRating3Mock());
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Crif Contact person doesn\'t exist in Account\'s Contacts', ApexPages.getMessages().get(0).getSummary());
    }


    /****************************************************************************
    *  Name            : testCompanyNameValidation()
    *  Summary         : Put in Account name different from Crif company name value
    *  CreatedDate     : 16/01/2018
    *  ModifiedDate    : 16/01/2018
    *  Parameters      : -
    *  Returns         : void
    ****************************************************************************/
    @isTest
    public static void testCompanyNameValidation() {
        Account account = CreditFactoryUtils.createCrifAccount();
        account.Name = 'test';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrifOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCrifContact(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

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
            Test.setMock(HttpCalloutMock.class, new CrifReportRating3Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.doUpdateCompanyName();
        Test.stopTest();

        System.assertEquals('Account Name and Crefo Name mismatch', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals('Fix all validation errors or refer to Credit.', ApexPages.getMessages().get(1).getSummary());
        System.assertEquals('Account Name has been updated.', ApexPages.getMessages().get(2).getSummary());
    }


    /******************************************************************************
    *  Name            : testRequestStatusValidation()
    *  Summary         : Get company from Crif Mock with invalid request status
    *  CreatedDate     : 16/01/2018
    *  ModifiedDate    : 16/01/2018
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testRequestStatusValidation() {
        Account account = CreditFactoryUtils.createCrifAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrifOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCrifContact(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCrifAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCrifOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrifCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CrifReportInvalidRequestStatusMock());
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Credit Factory report received with a system error. Additional attempts to download a Credit Factory report' + 
            ' will be performed automatically till the end of the day. Once a report is downloaded you will receive an email notification.', 
            ApexPages.getMessages().get(0).getSummary());
    }


    /******************************************************************************
    *  Name            : testObligationOverdueValidation()
    *  Summary         : Get company from Crif Mock with Obligation Overdue
    *  CreatedDate     : 16/01/2018
    *  ModifiedDate    : 16/01/2018
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testObligationOverdueValidation() {
        Account account = CreditFactoryUtils.createCrifAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrifOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCrifContact(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

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
            Test.setMock(HttpCalloutMock.class, new CrifReportObligationOverdueMock());
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Сompany has an overdue obligation.', ApexPages.getMessages().get(0).getSummary());

        List<Opportunity> opportuintiesList = [
                SELECT StageName
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals('Pending Sales – Deposit', opportuintiesList.get(0).StageName);
    }


    /******************************************************************************
    *  Name            : testAgeOfCompanyValidation()
    *  Summary         : Get company from Crif with too small age of company
    *  CreatedDate     : 16/01/2018
    *  ModifiedDate    : 16/01/2018
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testAgeOfCompanyValidation() {
        Account account = CreditFactoryUtils.createCrifAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrifOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCrifContact(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

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
            Test.setMock(HttpCalloutMock.class, new CrifReportInvalidAgeOfCompanyMock());
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Age of company is too small.', ApexPages.getMessages().get(0).getSummary());

        List<Opportunity> opportuintiesList = [
                SELECT StageName
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals('Pending Sales – Deposit', opportuintiesList.get(0).StageName);
    }


    /******************************************************************************
    *  Name            : testTaxIdValidation()
    *  Summary         : Put in Account Tax Id different from Crif company value.                      
    *  CreatedDate     : 30/01/2018
    *  ModifiedDate    : 30/01/2018 
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testTaxIdValidation() {
        Account account = CreditFactoryUtils.createCrifAccount();
        account.Steuernummer__c = 'test';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrifOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCrifContact(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCrifAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCrifOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrifCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CrifReportRating3Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.doUpdateTaxId();
        Test.stopTest();

        System.assertEquals('Account Tax ID mismatch (' + CrifWebservice.CREDIT_SYSTEM_NAME + 
            ' to Account Tax ID)', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals('Fix all validation errors or refer to Credit.', ApexPages.getMessages().get(1).getSummary());
        System.assertEquals('Account Tax ID has been updated.', ApexPages.getMessages().get(2).getSummary());
    }


    /******************************************************************************
    *  Name            : testTradeRegisterNumberValidation()
    *  Summary         : Put in Account Trade Register Number different from Crif company value.                      
    *  CreatedDate     : 30/01/2018
    *  ModifiedDate    : 30/01/2018 
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testTradeRegisterNumberValidation() {
        Account account = CreditFactoryUtils.createCrifAccount();
        account.HR_Abteilung_HRA_HRB_und_HR_Nummer__c = 'test';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrifOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCrifContact(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCrifAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCrifOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrifCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CrifReportRating3Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.doUpdateTradeRegisterNumber();
        Test.stopTest();

        System.assertEquals('Account Trade Register Number mismatch (' + CrifWebservice.CREDIT_SYSTEM_NAME + 
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
        Account account = CreditFactoryUtils.createCrifAccount();
        insert account;

        List<Opportunity> opportunitiesList = new List<Opportunity>();
        Opportunity opportunity = CreditFactoryUtils.createCrifOpportunity(account.Id);
        opportunitiesList.add(opportunity);

        Opportunity lostOpportunity = CreditFactoryUtils.createCrifOpportunity(account.Id);
        opportunity.StageName = 'Closed Lost';
        opportunity.Gruende_verloren__c = 'Refused Credit';
        opportunitiesList.add(lostOpportunity);
        insert opportunitiesList;

        Contact contact = CreditFactoryUtils.createCrifContact(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCrifAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCrifOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrifCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CrifReportRating3Mock());
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Credit Check was rejected for one of the Opportunities linked with your Account or its Contacts. Please refer to Credit.', ApexPages.getMessages().get(0).getSummary());
    }
 

    /*******************************************************************************
    *  Name            : testSetBillingPeriodRating1()
    *  Summary         : ClassRating = 1
    *  CreatedDate     : 16/01/2018
    *  ModifiedDate    : 16/01/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testSetBillingPeriodRating1() {
        Account account = CreditFactoryUtils.createCrifAccount();
        account.BillingStreet = 'Zachodnia 30';
        account.ShippingStreet = 'Zachodnia 30';
        account.Name = 'Muszelki Waldemar Szybki';
        account.Steuernummer__c = '2451803340';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrifOpportunity(account.Id);
        opportunity.Rechnungsperiode_2__c = '7';
        opportunity.Zahlungsziel_2__c = '7';
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCrifContact(account.Id);
        contact.LastName = 'Szybki';
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

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
            Test.setMock(HttpCalloutMock.class, new CrifReportRating1Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.changeBillingPeriodBySales();
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


    /*******************************************************************************
    *  Name            : testSetBillingPeriodRating1Deposit()
    *  Summary         : ClassRating = 1, Deposit case 50%
    *  CreatedDate     : 11/05/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testSetBillingPeriodRating1Deposit() {
        Account account = CreditFactoryUtils.createCrifAccount();
        account.BillingStreet = 'Zachodnia 30';
        account.ShippingStreet = 'Zachodnia 30';
        account.Name = 'Muszelki Waldemar Szybki';
        account.Steuernummer__c = '2451803340';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrifOpportunity(account.Id);
        // for warnings check
        opportunity.Rechnungsperiode_2__c = '7';
        opportunity.Zahlungsziel_2__c = '7';
        // for decision with deposit
        opportunity.Total_consumption_l_month__c = 1900;
        opportunity.Profit_loss_last_year__c = 21000;
        opportunity.Profit_loss_year_before_last__c = 36000;
        opportunity.Turnover_last_year__c = 10;
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCrifContact(account.Id);
        contact.LastName = 'Szybki';
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

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
            Test.setMock(HttpCalloutMock.class, new CrifReportRating1Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.reportService.getUserSource();
            controller.reportService.getBuffer();
            controller.reportService.getRiskCategory();
            controller.reportService.getSecurityLevel();
            controller.reportService.getCreditLimitWeeklyPlus7();
            controller.reportService.getMaxCreditLimitWeeklyPlus7();
            controller.reportService.getDepositWeeklyPlus7();
            controller.reportService.getMaxValueWeeklyPlus7();
            controller.reportService.getCreditLimitBiWeeklyPlus7();
            controller.reportService.getMaxCreditLimitBiWeeklyPlus7();
            controller.reportService.getDepositBiWeeklyPlus7();
            controller.reportService.getMaxValueBiWeeklyPlus7();
            controller.reportService.getCreditLimitBiWeeklyPlus14();
            controller.reportService.getMaxCreditLimitBiWeeklyPlus14();
            controller.reportService.getDepositBiWeeklyPlus14();
            controller.reportService.getMaxValueBiWeeklyPlus14();
            controller.reportService.getCreditLimitMonthlyPlus7();
            controller.reportService.getMaxCreditLimitMonthlyPlus7();
            controller.reportService.getDepositMonthlyPlus7();
            controller.reportService.getMaxValueMonthlyPlus7();
            controller.reportService.getCreditLimitMonthlyPlus14();
            controller.reportService.getMaxCreditLimitMonthlyPlus14();
            controller.reportService.getDepositMonthlyPlus14();
            controller.reportService.getCreditLimitMonthlyPlus21();
            controller.reportService.getMaxCreditLimitMonthlyPlus21();
            controller.reportService.getDepositMonthlyPlus21();
            controller.reportService.getCreditLimitMonthlyPlus27();
            controller.reportService.getMaxCreditLimitMonthlyPlus27();
            controller.reportService.getDepositMonthlyPlus27();
            controller.reportService.getPaymentTerms();
            controller.reportService.getCreditLimit();
            controller.reportService.getMaxCreditLimit();
            controller.reportService.getMaxValue();
            controller.reportService.getDeposit();
            controller.reportService.getDecision();
            controller.reportService.validateBlackList();
            CreditCompany company = new CreditCompany();
            company.classRating = '1';
            controller.reportService.resetDeposit(company, 15, 14, 9900, 10000, 8550, 1900, opportunity.Id);
            controller.reportService.resetDecision(15, 14, 0, '1', null, null);
        Test.stopTest();

        System.assertEquals('Decision about deposit was accepted for your client.', ApexPages.getMessages().get(0).getSummary());

        List<Opportunity> opportunitiesList = [
                SELECT Security_level_H_he_der_Sicherheit__c
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals(50, opportunitiesList.get(0).Security_level_H_he_der_Sicherheit__c);
    }


    /*******************************************************************************
    *  Name            : test2SetBillingPeriodRating1Deposit()
    *  Summary         : ClassRating = 1, Deposit case 100%
    *  CreatedDate     : 22/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void test2SetBillingPeriodRating1Deposit() {
        Account account = CreditFactoryUtils.createCrifAccount();
        account.BillingStreet = 'Zachodnia 30';
        account.ShippingStreet = 'Zachodnia 30';
        account.Name = 'Muszelki Waldemar Szybki';
        account.Steuernummer__c = '2451803340';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrifOpportunity(account.Id);
        // for decision with deposit
        opportunity.Total_consumption_l_month__c = 1900;
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCrifContact(account.Id);
        contact.LastName = 'Szybki';
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

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
            Test.setMock(HttpCalloutMock.class, new CrifReportRating1Mock());
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Decision about deposit was accepted for your client.', ApexPages.getMessages().get(0).getSummary());

        List<Opportunity> opportunitiesList = [
                SELECT Security_level_H_he_der_Sicherheit__c
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals(100, opportunitiesList.get(0).Security_level_H_he_der_Sicherheit__c);
    }


    /*******************************************************************************
    *  Name            : testSetBillingPeriodRating1ClosedWon()
    *  Summary         : ClassRating = 1, Deposit case
    *  CreatedDate     : 11/05/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testSetBillingPeriodRating1ClosedWon() {
        Account account = CreditFactoryUtils.createCrifAccount();
        account.BillingStreet = 'Zachodnia 30';
        account.ShippingStreet = 'Zachodnia 30';
        account.Name = 'Muszelki Waldemar Szybki';
        account.Steuernummer__c = '2451803340';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrifOpportunity(account.Id);
        opportunity.DocuSign_Status__c = 'Completed';
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCrifContact(account.Id);
        contact.LastName = 'Szybki';
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

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
            Test.setMock(HttpCalloutMock.class, new CrifReportRating1Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.reportService.getDecision();
            controller.changeToClosedWon();
            CreditCompany company = new CreditCompany();
            company.classRating = '1';
            controller.reportService.resetDeposit(company, 15, 14, 9900, 10000, 8550, 1900, opportunity.Id);
            controller.reportService.resetDecision(15, 14, 0, '1', null, null);
        Test.stopTest();

        List<Opportunity> opportunitiesList = [
                SELECT StageName
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals('Closed Won', opportunitiesList.get(0).StageName);
    }


    /*******************************************************************************
    *  Name            : testSetBillingPeriodRating2()
    *  Summary         : ClassRating = 2
    *  CreatedDate     : 16/01/2018
    *  ModifiedDate    : 16/01/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testSetBillingPeriodRating2() {
        Account account = CreditFactoryUtils.createCrifAccount();
        account.BillingStreet = 'Klonowa 45';
        account.ShippingStreet = 'Klonowa 45';
        account.BillingPostalCode = '82-228';
        account.ShippingPostalCode = '82-228';
        account.Gesellschaftsform__c = 'Limited joint-stock';
        account.Name = 'Lambda sp. z o.o. komandytowo-akcyjna';
        account.Steuernummer__c = '4835372542';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrifOpportunity(account.Id);
        opportunity.Zahlungsziel_2__c = '15';
        opportunity.Rechnungsperiode_2__c = '7';
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCrifContact(account.Id);
        contact.LastName = 'Orłowski';
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

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
            Test.setMock(HttpCalloutMock.class, new CrifReportRating2Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            CreditCompany company = new CreditCompany();
            company.classRating = '2';
            controller.reportService.resetDeposit(company, 15, 7, 5500, 5500, 6750, 1500, opportunity.Id);
            controller.reportService.resetDecision(15, 7, 0, '2', null, null);
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 15', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals('Payment Terms can be set to 7', ApexPages.getMessages().get(1).getSummary());
    }


    /*******************************************************************************
    *  Name            : testSetBillingPeriodRating2Deposit()
    *  Summary         : ClassRating = 2 with deposit 50%
    *  CreatedDate     : 22/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testSetBillingPeriodRating2Deposit() {
        Account account = CreditFactoryUtils.createCrifAccount();
        account.BillingStreet = 'Klonowa 45';
        account.ShippingStreet = 'Klonowa 45';
        account.BillingPostalCode = '82-228';
        account.ShippingPostalCode = '82-228';
        account.Gesellschaftsform__c = 'Limited joint-stock';
        account.Name = 'Lambda sp. z o.o. komandytowo-akcyjna';
        account.Steuernummer__c = '4835372542';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrifOpportunity(account.Id);
        opportunity.Total_consumption_l_month__c = 1900;
        opportunity.Zahlungsziel_2__c = '30';
        opportunity.Rechnungsperiode_2__c = '21';
        opportunity.Profit_loss_last_year__c = 21000;
        opportunity.Profit_loss_year_before_last__c = 36000;
        opportunity.Turnover_last_year__c = 10;
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCrifContact(account.Id);
        contact.LastName = 'Orłowski';
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

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
            Test.setMock(HttpCalloutMock.class, new CrifReportRating2Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            CreditCompany company = new CreditCompany();
            company.classRating = '2';
            controller.reportService.resetDeposit(company, 15, 14, 7200, 7200, 6750, 1500, opportunity.Id);
            controller.reportService.resetDeposit(company, 15, 14, 9900, 10000, 8550, 1900, opportunity.Id);
            controller.reportService.resetDecision(15, 14, 0, '2', null, null);
        Test.stopTest();

        System.assertEquals('Decision about deposit was accepted for your client.', ApexPages.getMessages().get(0).getSummary());

        List<Opportunity> opportunitiesList = [
                SELECT Security_level_H_he_der_Sicherheit__c
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals(50, opportunitiesList.get(0).Security_level_H_he_der_Sicherheit__c);
    }


    /*******************************************************************************
    *  Name            : test2SetBillingPeriodRating2Deposit()
    *  Summary         : ClassRating = 2 with deposit 100%
    *  CreatedDate     : 22/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void test2SetBillingPeriodRating2Deposit() {
        Account account = CreditFactoryUtils.createCrifAccount();
        account.BillingStreet = 'Klonowa 45';
        account.ShippingStreet = 'Klonowa 45';
        account.BillingPostalCode = '82-228';
        account.ShippingPostalCode = '82-228';
        account.Gesellschaftsform__c = 'Limited joint-stock';
        account.Name = 'Lambda sp. z o.o. komandytowo-akcyjna';
        account.Steuernummer__c = '4835372542';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrifOpportunity(account.Id);
        opportunity.Total_consumption_l_month__c = 1900;
        opportunity.Zahlungsziel_2__c = '30';
        opportunity.Rechnungsperiode_2__c = '21';
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCrifContact(account.Id);
        contact.LastName = 'Orłowski';
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

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
            Test.setMock(HttpCalloutMock.class, new CrifReportRating2Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            CreditCompany company = new CreditCompany();
            company.classRating = '2';
            controller.reportService.resetDeposit(company, 15, 14, 7200, 7200, 6750, 1500, opportunity.Id);
            controller.reportService.resetDecision(15, 14, 0, '2', null, null);
        Test.stopTest();

        System.assertEquals('Decision about deposit was accepted for your client.', ApexPages.getMessages().get(0).getSummary());

        List<Opportunity> opportunitiesList = [
                SELECT Security_level_H_he_der_Sicherheit__c
                FROM Opportunity
                WHERE Id = :opportunity.Id];

        System.assertEquals(100, opportunitiesList.get(0).Security_level_H_he_der_Sicherheit__c);
    }


    /*******************************************************************************
    *  Name            : testSetBillingPeriodRating3()
    *  Summary         : ClassRating = 3
    *  CreatedDate     : 16/01/2018
    *  ModifiedDate    : 16/01/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testSetBillingPeriodRating3() {
        Account account = CreditFactoryUtils.createCrifAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrifOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCrifContact(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

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
            Test.setMock(HttpCalloutMock.class, new CrifReportRating3Mock());
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Opportunity is closed as Lost (Rating 3)', ApexPages.getMessages().get(0).getSummary());
    }


    /*****************************************************************************
    *  Name            : testExistingCompany()
    *  Summary         : Check success search company
    *  CreatedDate     : 16/01/2018
    *  ModifiedDate    : 17/01/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest 
    public static void testExistingCompany() {
        Account account = CreditFactoryUtils.createCrifAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCrifOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCrifContact(account.Id);
        contact.LastName = contact.LastName + 'ĆćŃńÓóŚśŹźŻżĄąĘęŁłXx';
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCrifAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCrifOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCrifCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Credit_Factory_Report__c creditReport = CreditFactoryUtils.createCrifReport();
        creditReport.Opportunity__c = opportunity.Id;
        insert creditReport;

        Credit_Factory_Report_Employee__c creditReportEmployee = CreditFactoryUtils.createCrifReportEmployee();
        creditReportEmployee.Credit_Factory_Report__c = creditReport.Id;
        creditReportEmployee.Name = creditReportEmployee.Name + 'CcNnOoSsZzZzAaEeLlKSks';
        insert creditReportEmployee;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.doCreateCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        Test.startTest();
            controller = new CreditFactoryReportController();
            controller.init();
            controller.updateOpportunityByCredit();
            controller.reportService.setUserSource('E2E Long Form');
            controller.reportService.saveReports();
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 15', ApexPages.getMessages().get(0).getSummary());
    }
}