@isTest
private class CreditFactoryReportControllerTest {
    public static CreditFactoryReportController controller; 


    /*******************************************************************************
    *  Name            : testInvalidOpportunity()
    *  Summary         : Check not existing opportunity id 
    *  CreatedDate     : 18/11/2016
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testInvalidOpportunity() {
        Account account = CreditFactoryUtils.doCreateCreditreformAccount();
        insert account;
        Opportunity opportunity = CreditFactoryUtils.doCreateOpportunity(account.Id);
        insert opportunity;
        controller = new CreditfactoryReportController();
        controller.init();
        System.assertEquals(ApexPages.getMessages().get(0).getSummary(), 'Invalid opportunityId parameter.Please contact your administrator.');
        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        controller.init();
        System.assertEquals(ApexPages.getMessages().get(1).getSummary(), 'Invalid creditSystemCompanyNumber parameter.' + CreditFactoryUtilities.CONTACT_ADMIN);
    }


    /*******************************************************************************
    *  Name            : testInvalidSelected()
    *  Summary         : Chek empty field Supported_Countries__c for CreditSystem
    *  CreatedDate     : 18/11/2016
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testInvalidSelected() {
        Account account = CreditFactoryUtils.doCreateCreditreformAccount();
        account.BillingCountry = 'Germany';
        insert account;
        Opportunity opportunity = CreditFactoryUtils.doCreateOpportunity(account.Id);
        insert opportunity;
        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');
        controller = new CreditFactoryReportController();
        controller.init();
        System.assertEquals(ApexPages.getMessages().get(0).getSummary(), 'Select Credit System Settings failed. Please check Billing Country or contact your administrator.');
    }


    /*******************************************************************************
    *  Name            : testInvalidReportService()
    *  Summary         : Check invalid name for CreditSystem__c
    *  CreatedDate     : 18/11/2016
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testInvalidReportService() {
        Account account = CreditFactoryUtils.doCreateCreditreformAccount();
        account.BillingCountry = 'Germany';
        insert account;
        Opportunity opportunity = CreditFactoryUtils.doCreateOpportunity(account.Id);
        insert opportunity;
        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');
        CreditSystem__c creditSystem = CreditFactoryUtils.doCreateCreditSystem();
        creditSystem.Supported_Countries__c = 'Germany';
        creditSystem.Name = 'Test';
        insert creditSystem;
        controller = new CreditFactoryReportController();
        controller.init();
        System.assertEquals('Invalid name for Credit setting.', ApexPages.getMessages().get(0).getSummary());
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
        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');
        CreditSystem__c creditSystem = CreditFactoryUtils.doCreateCreditSystem();
        creditSystem.Supported_Countries__c = 'Germany';
        creditSystem.Name = 'Creditreform';
        insert creditSystem;
        controller = new CreditFactoryReportController();
        controller.init();
        System.assertEquals(ApexPages.getMessages().get(0).getSummary(), 'Account mapping select error. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.doCreateCreditFactoryAccount();
        accountMapping.Name = 'Creditreform';
        insert accountMapping;
        controller.init();
        System.assertEquals(ApexPages.getMessages().get(1).getSummary(), 'Opportunity mapping select error. ' + CreditFactoryUtilities.CONTACT_ADMIN);
    }


    /******************************************************************************
    *  Name            : testInvalidCurrentOpportunityCreditreform()
    *  Summary         : Check selecting opportunity with fields from mapping
    *  CreatedDate     : 15/11/2016
    *  Parameters      : 
    *  Returns         : void 
    *****************************************************************************/
    @isTest
    public static void testInvalidCurrentOpportunityCreditreform() {
        Account account = CreditFactoryUtils.doCreateCreditreformAccount();
        account.BillingCountry = 'Germany';
        insert account;
        Opportunity opportunity = CreditFactoryUtils.doCreateOpportunity(account.Id);
        insert opportunity;
        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');
        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.doCreateCreditFactoryAccount();
        accountMapping.Name = 'Creditreform';
        accountMapping.Number_of_employees__c = 'test';
        insert accountMapping;
        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.doCreateCreditFactoryOpportunity();
        opportunityMapping.Name = 'Creditreform';
        insert opportunityMapping;
        CreditSystem__c creditSystem = CreditFactoryUtils.doCreateCreditSystem();
        creditSystem.Supported_Countries__c = 'Germany';
        creditSystem.Name = 'Creditreform';
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        controller = new CreditFactoryReportController();
        controller.init();
        System.assertEquals(ApexPages.getMessages().get(0).getSummary(), 'Select Opportunity failed. Please contact your administrator.');
    }


    /*******************************************************************************
    *  Name            : testSetCompanyCreditreform()
    *  Summary         : Check setting company and employees   
    *  CreatedDate     : 18/11/2016
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testSetCompanyCreditreform() {
        Account account = CreditFactoryUtils.doCreateCreditreformAccount();
        account.BillingCountry = 'Germany';
        insert account;
        Opportunity opportunity = CreditFactoryUtils.doCreateOpportunity(account.Id);
        insert opportunity;
        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');
        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.doCreateCreditFactoryAccount();
        accountMapping.Name = 'Creditreform';
        insert accountMapping;
        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.doCreateCreditFactoryOpportunity();
        opportunityMapping.Name = 'Creditreform';
        insert opportunityMapping;
        CreditSystem__c creditSystem = CreditFactoryUtils.doCreateCreditSystem();
        creditSystem.Supported_Countries__c = 'Germany';
        creditSystem.Name = 'Creditreform';
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CreditreformReportRating1Mock());
        controller = new CreditFactoryReportController();
        controller.init();
        Test.stopTest();
        System.assertEquals(ApexPages.getMessages().get(0).getSummary(), 
                'Set company error. Please contact your administrator.<br/>Parsing Report Company failed. Please contact your administrator.');
    }


    /*******************************************************************************
    *  Name            : testDoOrder()
    *  Summary         : test do order in case of no company mathes
    *  CreatedDate     : 20/12/2017
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testDoOrder() {
        Account account = CreditFactoryUtils.doCreateCreditreformAccount();
        account.BillingCountry = 'Germany';
        insert account;
        Opportunity opportunity = CreditFactoryUtils.doCreateOpportunity(account.Id);
        insert opportunity;
        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '07017010437333');
        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.doCreateCreditFactoryAccount();
        accountMapping.Name = 'Creditreform';
        insert accountMapping;
        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.doCreateCreditFactoryOpportunity();
        opportunityMapping.Name = 'Creditreform';
        insert opportunityMapping;
        CreditSystem__c creditSystem = CreditFactoryUtils.doCreateCreditSystem();
        creditSystem.Supported_Countries__c = 'Germany';
        creditSystem.Name = 'Creditreform';
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformOrderMock());
            controller = new CreditFactoryReportController();
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
    *  Name            : testCreatingAttachmentCreditreform()
    *  Summary         : Check creating Attachment
    *  CreatedDate     : 20/11/2016
    *  ModifiedDate    : 14/11/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testCreatingAttachmentCreditreform() {
        Account account = CreditFactoryUtils.createCreditreformAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContact(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformReportRating1Mock());
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        List<Attachment> attachmentList = [
                SELECT Name
                FROM Attachment];
        System.assertEquals(attachmentList.size(), 1);
    }


    /*******************************************************************************
    *  Name            : testValidateAddressCreditreform()
    *  Summary         : Check valid address, isSales = false                     
    *  CreatedDate     : 20/11/2016
    *  ModifiedDate    : 20/02/2018 
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testValidateAddressCreditreform() {
        Account account = CreditFactoryUtils.createCreditreformAccount();
        account.BillingCity = 'test';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContact(opportunity.AccountId);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');
        
        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createCreditreformAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createCreditreformOpportunityMapping();
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformReportRating1Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.doUpdateAddress();
            controller.doUpdateWithAdditionalAddress();
        Test.stopTest();

        System.assertEquals('Account Billing and Shipping Addresses should be the same as Crefo address', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals('Fix all validation errors or refer to Credit.', ApexPages.getMessages().get(1).getSummary());
        System.assertEquals('Address has been updated.', ApexPages.getMessages().get(2).getSummary());
    }


    /******************************************************************************
    *  Name            : testValidateLegalFormCreditreform()
    *  Summary         : Check valid legal form, isSales = false                        
    *  CreatedDate     : 20/11/2016
    *  ModifiedDate    : 04/07/2018 
    *  Parameters      : 
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testValidateLegalFormCreditreform() {
        Account account = CreditFactoryUtils.createCreditreformAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContact(opportunity.AccountId);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');
        
        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createCreditreformAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createCreditreformOpportunityMapping();
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformPublicEntityMock());
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Customer is a public entity.', ApexPages.getMessages().get(0).getSummary());
    }


    /*****************************************************************************
    *  Name            : testValidateContactCreditreform()
    *  Summary         : Check valid contact, isSales = false                         
    *  CreatedDate     : 20/11/2016
    *  ModifiedDate    : 20/02/2018
    *  Parameters      : 
    *  Returns         : void
    ****************************************************************************/
    @isTest
    public static void testValidateContactCreditreform() {
        Account account = CreditFactoryUtils.createCreditreformAccount();
        account.Gesellschaftsform__c = 'UG';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunity(account.Id);
        insert opportunity;

        Task task = CreditFactoryUtils.createTask(opportunity.Id);
        insert task;

        Contact contact = CreditFactoryUtils.createCreditreformContact(opportunity.accountId);
        contact.LastName = 'test';
        insert contact;

        OpportunityContactRole contactRole = CreditFactoryUtils.createCreditreformOpportunityContactRole(contact.Id, opportunity.Id);
        insert contactRole;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createCreditreformAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createCreditreformOpportunityMapping();
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.doCreateCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformEntrepreneurialCompanyMock());
            controller = new CreditFactoryReportController();
            controller.callId = task.Id;
            controller.init();
            controller.confirmContactRole();
            controller.continueValidation();
        Test.stopTest();

        System.assertEquals('Customer is an Entrepreneurial company', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals('Crefo Contact person doesn\'t exist in Account\'s Contacts', ApexPages.getMessages().get(1).getSummary());
        System.assertEquals('Please choose call with contact role confirmation.', ApexPages.getMessages().get(2).getSummary());
        System.assertEquals('Contact role has been confirmed.', ApexPages.getMessages().get(3).getSummary());
    }


    /******************************************************************************
    *  Name            : testValidateCompanyNameCreditReform()
    *  Summary         : Check valid company name isSales = true
    *  CreatedDate     : 20/11/2016
    *  ModifiedDate    : 20/02/2018
    *  Parameters      : 
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testValidateCompanyNameCreditreform() {
        Account account = CreditFactoryUtils.createCreditreformAccount();
        account.Name = 'test';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContact(opportunity.AccountId);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createCreditreformAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createCreditreformOpportunityMapping();
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.doCreateCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformReportRating1Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.doUpdateCompanyName();
        Test.stopTest();

        System.assertEquals('Account Name and Crefo Name mismatch', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals('Fix all validation errors or refer to Credit.', ApexPages.getMessages().get(1).getSummary());
        System.assertEquals('Account Name has been updated.', ApexPages.getMessages().get(2).getSummary());

    }


    /****************************************************************************
    *  Name            : testTaxIdValidationCreditreform()
    *  Summary         : Put in Account Tax Id different from Creditreform company name value.                      
    *  CreatedDate     : 20/02/2018
    *  ModifiedDate    : 11/06/2018 
    *  Parameters      : -
    *  Returns         : void
    ***************************************************************************/
    @isTest
    public static void testTaxIdValidationCreditreform() {
        Account account = CreditFactoryUtils.createCreditreformAccount();
        account.Steuernummer__c = 'test';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContact(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformReportRating1Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.doUpdateTaxId();
        Test.stopTest();

        System.assertEquals('Account Tax ID mismatch (' + CreditreformWebservice.CREDIT_SYSTEM_NAME + 
            ' to Account Tax ID)', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals('Fix all validation errors or refer to Credit.', ApexPages.getMessages().get(1).getSummary());
        System.assertEquals('Account Tax ID has been updated.', ApexPages.getMessages().get(2).getSummary());
    }


    /******************************************************************************
    *  Name            : testVatNumberValidationCreditreform()
    *  Summary         : Put in Account Tax Id different from Creditreform company name value.                      
    *  CreatedDate     : 20/02/2018
    *  ModifiedDate    : 11/06/2018 
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testVatNumberValidationCreditreform() {
        Account account = CreditFactoryUtils.createCreditreformAccount();
        account.Umsatzsteuer_ID__c = 'test';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContact(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformReportRating1Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.doUpdateVatNumber();
        Test.stopTest();

        System.assertEquals('Account VAT number mismatch (' + CreditreformWebservice.CREDIT_SYSTEM_NAME + 
            ' to Account VAT number)', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals('Fix all validation errors or refer to Credit.', ApexPages.getMessages().get(1).getSummary());
        System.assertEquals('Account VAT number has been updated.', ApexPages.getMessages().get(2).getSummary());
    }


    /******************************************************************************
    *  Name            : testTradeRegisterNumberValidationCreditsafe()
    *  Summary         : Put in Account Trade Register Number different from Creditsafe company value.                      
    *  CreatedDate     : 12/12/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testTradeRegisterNumberValidationCreditsafe() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        account.BillingCountry = 'France';
        account.HR_Abteilung_HRA_HRB_und_HR_Nummer__c = 'test';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditsafeContact(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditsafeAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditsafeOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditsafeCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditsafeReportRating1Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.doUpdateTradeRegisterNumber();
        Test.stopTest();

        System.assertEquals('Account Trade Register Number mismatch (' + CreditSafeWebservice.CREDIT_SYSTEM_NAME + 
            ' to Account Trade Register Number)', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals('Fix all validation errors or refer to Credit.', ApexPages.getMessages().get(1).getSummary());
        System.assertEquals('Account Trade Register Number has been updated.', ApexPages.getMessages().get(2).getSummary());
    }


    /******************************************************************************
    *  Name            : testLostOpportunitiesValidationCreditrefor()
    *  Summary         : Create Closed Lost Opportunity related to the current Opportunity's Account
    *  CreatedDate     : 02/04/2018
    *  ModifiedDate    : 02/04/2018 
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testLostOpportunitiesValidationCreditreform() {
        Account account = CreditFactoryUtils.createCreditreformAccount();
        insert account;

        List<Opportunity> opportunitiesList = new List<Opportunity>();
        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunity(account.Id);
        opportunitiesList.add(opportunity);

        Opportunity lostOpportunity = CreditFactoryUtils.createCreditreformOpportunity(account.Id);
        opportunity.StageName = 'Closed Lost';
        opportunity.Gruende_verloren__c = 'Refused Credit';
        opportunitiesList.add(lostOpportunity);
        insert opportunitiesList;

        Contact contact = CreditFactoryUtils.createCreditreformContact(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformReportRating1Mock());
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Credit Check was rejected for one of the Opportunities linked with your Account or its Contacts. Please refer to Credit.', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testBlackListValidation()
    *  Summary         : Create Credit_Black_List_Company__c and Opportunity objects with
                         the same fields   
    *  CreatedDate     : 11/06/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testBlackListValidation() {
        Account account = CreditFactoryUtils.createCreditreformAccount();
        insert account;

        List<Opportunity> opportunitiesList = new List<Opportunity>();
        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunity(account.Id);
        opportunitiesList.add(opportunity);

        Opportunity lostOpportunity = CreditFactoryUtils.createCreditreformOpportunity(account.Id);
        opportunity.StageName = 'Closed Lost';
        opportunity.Gruende_verloren__c = 'Refused Credit';
        opportunitiesList.add(lostOpportunity);
        insert opportunitiesList;

        Contact contact = CreditFactoryUtils.createCreditreformContact(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystem();
        insert creditSystem;

        Credit_Black_List_Company__c blackList = CreditFactoryUtils.doCreateCreditBlackListCompany(account.Name);
        blackList.Customer_Id__c = 'DE';
        insert blackList;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformReportRating1Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            Boolean isCompanyNotInBlackList = controller.reportService.validateBlackList();
        Test.stopTest();

        System.assertEquals('Credit Check was rejected for one of the Opportunities linked with your Account or its Contacts. Please refer to Credit.', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals(false, isCompanyNotInBlackList);
    }
 

    /*******************************************************************************
    *  Name            : testSetBillingPeriodRating1Creditreform()
    *  Summary         : ClassRating = 1
    *  CreatedDate     : 21/11/2016
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testSetBillingPeriodRating1Creditreform() {
        Account account = CreditFactoryUtils.createCreditReformAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContact(opportunity.AccountId);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createCreditreformAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createCreditreformOpportunityMapping();
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.doCreateCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformReportRating1Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.reportService.getBuffer();
            controller.reportService.getRiskCategory();
            controller.reportService.getSecurityLevel();
            controller.reportService.getCreditLimitWeeklyPlus7();
            controller.reportService.getMaxCreditLimitWeeklyPlus7();
            controller.reportService.getDepositWeeklyPlus7();
            controller.reportService.getCreditLimitBiWeeklyPlus7();
            controller.reportService.getMaxCreditLimitBiWeeklyPlus7();
            controller.reportService.getDepositBiWeeklyPlus7();
            controller.reportService.getCreditLimitBiWeeklyPlus14();
            controller.reportService.getMaxCreditLimitBiWeeklyPlus14();
            controller.reportService.getCreditLimitMonthlyPlus7();
            controller.reportService.getMaxCreditLimitMonthlyPlus7();
            controller.reportService.getDepositMonthlyPlus7();
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
            controller.changeToClosedWon();
            CreditCompany company = new CreditCompany();
            company.classRating = '1';
            controller.reportService.resetDeposit(company, 30, 7, 2000, 4000, 3500, 5500, opportunity.Id);
            controller.reportService.resetDecision(30, 7, 0, '1', null, null);
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 30', ApexPages.getMessages().get(0).getSummary());
    }


    /******************************************************************************
    *  Name            : testSetBillingPeriodRating2Creditreform()
    *  Summary         : ClassRating = 2
    *  CreatedDate     : 21/11/2016
    *  Parameters      : 
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testSetBillingPeriodRating2Creditreform() {
        Account account = CreditFactoryUtils.createCreditReformAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunity(account.Id);
        opportunity.Total_consumption_l_month__c = 4500;
        // for warnings check
        opportunity.Rechnungsperiode_2__c = '14';
        opportunity.Zahlungsziel_2__c = '30';
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContact(opportunity.AccountId);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createCreditreformAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createCreditreformOpportunityMapping();
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.doCreateCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformReportRating2Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.changeToPendingSEPAConfirmation();
            CreditCompany company = new CreditCompany();
            company.classRating = '2';
            controller.reportService.resetDeposit(company, 15, 7, 2000, 4000, 3500, 5500, opportunity.Id);
            controller.reportService.resetDecision(15, 7, 0, '2', null, null);
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 15', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testSetBillingPeriodRating3Creditreform()
    *  Summary         : ClassRating = 3
    *  CreatedDate     : 21/11/2016
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testSetBillingPeriodRating3Creditreform() {
        Account account = CreditFactoryUtils.createCreditReformAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunity(account.Id);
        opportunity.Total_consumption_l_month__c = 9000;
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContact(opportunity.AccountId);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createCreditreformAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createCreditreformOpportunityMapping();
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.doCreateCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformReportRating3Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            CreditCompany company = new CreditCompany();
            company.classRating = '3';
            controller.reportService.resetDeposit(company, 7, 7, 2000, 4000, 3500, 5500, opportunity.Id);
            controller.reportService.resetDecision(7, 7, 0, '3', null, null);
            controller.updateOpportunityByCredit();
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 7', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testSetBillingPeriodRating4Creditreform()
    *  Summary         : ClassRating = 4 
    *  CreatedDate     : 21/11/2016
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testSetBillingPeriodRating4Creditreform() {
        Account account = CreditFactoryUtils.createCreditReformAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContact(opportunity.AccountId);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createCreditreformAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createCreditreformOpportunityMapping();
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.doCreateCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformReportRating4Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            CreditCompany company = new CreditCompany();
            company.classRating = '4';
            controller.reportService.resetDeposit(company, 30, 7, 2000, 4000, 3500, 5500, opportunity.Id);
            controller.reportService.resetDecision(30, 7, 0, '4', null, null);
        Test.stopTest();
        System.assertEquals('Billing Period can be set to 30', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testSetBillingPeriodRating4DepositCreditreform()
    *  Summary         : ClassRating = 4, Deposit is provided
    *  CreatedDate     : 28/03/2018
    *  ModifiedDate    : 28/03/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testSetBillingPeriodRating4DepositCreditreform() {
        Account account = CreditFactoryUtils.createCreditReformAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunity(account.Id);
        opportunity.Total_consumption_l_month__c = 10000;
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContact(opportunity.AccountId);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createCreditreformAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createCreditreformOpportunityMapping();
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.doCreateCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformReportRating4Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            CreditCompany company = new CreditCompany();
            company.classRating = '4';
            controller.reportService.resetDeposit(company, 30, 7, 2000, 4000, 3500, 5500, opportunity.Id);
            controller.reportService.resetDecision(30, 7, 0, '4', null, null);
        Test.stopTest();
        List<Opportunity> opList = [
                SELECT Security_level_H_he_der_Sicherheit__c
                FROM Opportunity
                WHERE Id = :opportunity.Id];
        System.assertEquals(4, opList.get(0).Security_level_H_he_der_Sicherheit__c);
    }


    /*******************************************************************************
    *  Name            : testSetBillingPeriodRating5Creditreform()
    *  Summary         : ClassRating = 5 
    *  CreatedDate     : 20/02/2018
    *  ModifiedDate    : 28/03/2018
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testSetBillingPeriodRating5Creditreform() {
        Account account = CreditFactoryUtils.createCreditReformAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunity(account.Id);
        opportunity.Zahlungsart__c = 'Lastschrift';
        opportunity.Anzahl_der_Karten__c = 1;
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContact(opportunity.AccountId);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createCreditreformAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createCreditreformOpportunityMapping();
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.doCreateCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformReportRating5Mock());
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();
        System.assertEquals('Billing Period can be set to 15', ApexPages.getMessages().get(0).getSummary());
    }


    /******************************************************************************
    *  Name            : testSetBillingPeriodRating5DepositCreditreform()
    *  Summary         : ClassRating = 5, Deposit is provided
    *  CreatedDate     : 21/11/2016
    *  Parameters      : 
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testSetBillingPeriodRating5DepositCreditreform() {
        Account account = CreditFactoryUtils.createCreditReformAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunity(account.Id);
        opportunity.Anzahl_der_Karten__c = 3;
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContact(opportunity.AccountId);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createCreditreformAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createCreditreformOpportunityMapping();
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.doCreateCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformReportRating5Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            CreditCompany company = new CreditCompany();
            company.classRating = '5';
            controller.reportService.resetDeposit(company, 30, 7, 2000, 4000, 3500, 5500, opportunity.Id);
            controller.reportService.resetDecision(30, 7, 0, '5', null, null);
        Test.stopTest();

        List<Opportunity> opList = [
                SELECT Security_level_H_he_der_Sicherheit__c
                FROM Opportunity
                WHERE Id = :opportunity.Id];
        System.assertEquals(70, opList.get(0).Security_level_H_he_der_Sicherheit__c);
    }


    /*******************************************************************************
    *  Name            : testSetBillingPeriodRating6Creditreform()
    *  Summary         : ClassRating = 6 
    *  CreatedDate     : 21/11/2016
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testSetBillingPeriodRating6Creditreform() {
        Account account = CreditFactoryUtils.createCreditReformAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContact(opportunity.AccountId);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.doCreateCreditFactoryAccount();
        accountMapping.Name = 'Creditreform';
        insert accountMapping;
        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.doCreateCreditFactoryOpportunity();
        opportunityMapping.Name = 'Creditreform';
        insert opportunityMapping;
        CreditSystem__c creditSystem = CreditFactoryUtils.doCreateCreditSystem();
        creditSystem.Supported_Countries__c = 'Germany';
        creditSystem.Name = 'Creditreform';
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.doCreateCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformReportRating6Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            CreditCompany company = new CreditCompany();
            company.classRating = '6';
            controller.reportService.resetDeposit(company, 30, 7, 2000, 4000, 3500, 5500, opportunity.Id);
            controller.reportService.resetDecision(30, 7, 0, '6', null, null);
        Test.stopTest();
        
        List<Opportunity> opList = [
                SELECT Security_level_H_he_der_Sicherheit__c
                FROM Opportunity
                WHERE Id = :opportunity.Id];
        System.assertEquals(110, opList.get(0).Security_level_H_he_der_Sicherheit__c);
    }


    /*******************************************************************************
    *  Name            : testSetBillingPeriodNoRatingCreditreform()
    *  Summary         : ClassRating is empty
    *  CreatedDate     : 21/11/2016
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testSetBillingPeriodNoRatingCreditreform() {
        Account account = CreditFactoryUtils.createCreditReformAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunity(account.Id);
        opportunity.Total_consumption_l_month__c = 600;
        opportunity.Anzahl_der_Karten__c = 2;
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContact(opportunity.AccountId);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createCreditreformAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createCreditreformOpportunityMapping();
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.doCreateCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformReportNoRatingMock());
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();
        System.assertEquals('Billing Period can be set to 15', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testSetBillingPeriodNoRatingDepositCreditreform()
    *  Summary         : ClassRating is empty, Deposit is provided
    *  CreatedDate     : 28/03/2018
    *  ModifiedDate    : 28/03/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testSetBillingPeriodNoRatingDepositCreditreform() {
        Account account = CreditFactoryUtils.createCreditReformAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContact(opportunity.AccountId);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createCreditreformAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createCreditreformOpportunityMapping();
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.doCreateCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformReportNoRatingMock());
            controller = new CreditFactoryReportController();
            controller.init();
            CreditCompany company = new CreditCompany();
            company.classRating = null;
            controller.reportService.resetDeposit(company, 30, 7, 2000, 4000, 3500, 5500, opportunity.Id);
            controller.reportService.resetDecision(30, 7, 0, null, null, null);
            controller.reportService.setUserSource('E2E Long Form');
            controller.reportService.saveReports();
        Test.stopTest();
        
        List<Opportunity> opList = [
                SELECT Security_level_H_he_der_Sicherheit__c
                FROM Opportunity
                WHERE Id = :opportunity.Id];
        System.assertEquals(100, opList.get(0).Security_level_H_he_der_Sicherheit__c);
    }


    /*******************************************************************************
    *  Name            : testFinancialDataCreditreform()
    *  Summary         : Creating Financial Data in case of too high limit
    *  CreatedDate     : 05/11/2018
    *  ModifiedDate    : 14/11/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testFinancialDataCreditreform() {
        Account account = CreditFactoryUtils.createCreditReformAccount();
        account.BillingStreet = 'Am Sundern 15';
        account.BillingPostalCode = '58762';
        account.BillingCity = 'Altena';
        account.ShippingStreet = 'Am Sundern 15';
        account.ShippingPostalCode = '58762';
        account.ShippingCity = 'Altena';
        account.Name = 'KUNDENTESTSYSTEM BILANZBONITÄT KONZERN - BITTE NICHT ÄNDERN';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunity(account.Id);
        opportunity.Total_consumption_l_month__c = 10000;
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContact(opportunity.AccountId);
        contact.FirstName = 'Sander KTO';
        contact.LastName = 'Solveig';
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createCreditreformAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createCreditreformOpportunityMapping();
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.doCreateCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformFinanceMock());
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        List<Financial_Module__c> financialModulesList = [
                SELECT Name, 
                        (SELECT Year__c, Type__c, Total_Assets__c, Total_Fixed_Assets__c, Intangible_Fixed_Assets__c, 
                            Tangible_Fixed_Assets__c, Financial_LT_Assets__c, Total_Current_Assets__c, Stock_material_work__c, 
                            Trade_debtors__c, Cash_Cash_equivalent__c,  Others_Current_Assets__c, Total_Liabilities__c, 
                            Net_worth__c, Reserves__c, Liabilities__c, LongTerm_Liabilities__c, From_that_LT_bank_debt__c, 
                            From_that_Other_LT_Liabilities__c, ShortTerm_Liabilities__c, From_that_Trade_Creditors__c, 
                            From_that_ST_bank_debt__c, From_that_Other_ST_Liabilities__c, Total_Turnover__c, Turnover__c, 
                            Activation__c, Other_operational_income__c, Cost_of_goods_sold__c, Gross_profit_loss__c,  Depreciation__c, 
                            Income_and_other_taxes__c, EBIT_from_Crefo__c, Operational_profit_EBIT__c, EBITDA__c, Calculated_CF__c, 
                            Financial_Income__c, Financial_Charges__c, Net_Interest_expense__c, EAT__c, Extraordinary_Items__c, 
                            Exceptional_Income__c, Exceptional_Charges__c, Exceptional_Items_Total__c, Profit_Margin__c, 
                            ROA_calculation_includes_taxes_x_D_B__c, ROE_without_Reserves__c, Profitability__c, Solvency_ratio__c, 
                            Leverage__c, Debt_to_EBITDA__c, EBITDA_coverage__c, Current_ratio__c, Quick_acid_ratio__c, Working_capital__c, 
                            Cash_flow_ratio__c, DSO_in_days__c, DPO_in_days__c, Overall_score__c
                        FROM Financial_Details__r
                        ORDER BY Year__c DESC)
                FROM Financial_Module__c
                WHERE Account__c = :account.Id
                ORDER BY CreatedDate DESC
                LIMIT 1];

        // 1 "annual" and 1 "change" details
        System.assertEquals(2, financialModulesList.get(0).Financial_Details__r.size());

        // 2015 annual
        System.assertEquals(39249000, financialModulesList.get(0).Financial_Details__r.get(1).Total_Assets__c);
        System.assertEquals(34614000, financialModulesList.get(0).Financial_Details__r.get(1).Total_Fixed_Assets__c);
        System.assertEquals(20000, financialModulesList.get(0).Financial_Details__r.get(1).Intangible_Fixed_Assets__c);
        System.assertEquals(327000, financialModulesList.get(0).Financial_Details__r.get(1).Tangible_Fixed_Assets__c);
        System.assertEquals(34267000, financialModulesList.get(0).Financial_Details__r.get(1).Financial_LT_Assets__c);
        System.assertEquals(4635000, financialModulesList.get(0).Financial_Details__r.get(1).Total_Current_Assets__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(1).Stock_material_work__c);
        System.assertEquals(24000, financialModulesList.get(0).Financial_Details__r.get(1).Trade_debtors__c);
        System.assertEquals(1831000, financialModulesList.get(0).Financial_Details__r.get(1).Cash_Cash_equivalent__c);
        System.assertEquals(2780000, financialModulesList.get(0).Financial_Details__r.get(1).Others_Current_Assets__c);
        System.assertEquals(39249000, financialModulesList.get(0).Financial_Details__r.get(1).Total_Liabilities__c);
        System.assertEquals(14478000, financialModulesList.get(0).Financial_Details__r.get(1).Net_worth__c);
        System.assertEquals(3328000, financialModulesList.get(0).Financial_Details__r.get(1).Reserves__c);
        System.assertEquals(21443000, financialModulesList.get(0).Financial_Details__r.get(1).Liabilities__c);
        System.assertEquals(5837000, financialModulesList.get(0).Financial_Details__r.get(1).LongTerm_Liabilities__c);
        System.assertEquals(5837000, financialModulesList.get(0).Financial_Details__r.get(1).From_that_LT_bank_debt__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(1).From_that_Other_LT_Liabilities__c);
        System.assertEquals(15606000, financialModulesList.get(0).Financial_Details__r.get(1).ShortTerm_Liabilities__c);
        System.assertEquals(28000, financialModulesList.get(0).Financial_Details__r.get(1).From_that_Trade_Creditors__c);
        System.assertEquals(5000, financialModulesList.get(0).Financial_Details__r.get(1).From_that_ST_bank_debt__c);
        System.assertEquals(15573000, financialModulesList.get(0).Financial_Details__r.get(1).From_that_Other_ST_Liabilities__c);
        System.assertEquals(2355000, financialModulesList.get(0).Financial_Details__r.get(1).Total_Turnover__c);
        System.assertEquals(0, financialModulesList.get(0).Financial_Details__r.get(1).Turnover__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(1).Activation__c);
        System.assertEquals(2355000, financialModulesList.get(0).Financial_Details__r.get(1).Other_operational_income__c);
        System.assertEquals(0, financialModulesList.get(0).Financial_Details__r.get(1).Cost_of_goods_sold__c);
        System.assertEquals(0, financialModulesList.get(0).Financial_Details__r.get(1).Gross_profit_loss__c);
        System.assertEquals(0, financialModulesList.get(0).Financial_Details__r.get(1).Depreciation__c);
        System.assertEquals(204000, financialModulesList.get(0).Financial_Details__r.get(1).Income_and_other_taxes__c);
        System.assertEquals(-80000, financialModulesList.get(0).Financial_Details__r.get(1).EBIT_from_Crefo__c);
        System.assertEquals(-80000, financialModulesList.get(0).Financial_Details__r.get(1).Operational_profit_EBIT__c);
        System.assertEquals(-80000, financialModulesList.get(0).Financial_Details__r.get(1).EBITDA__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(1).Calculated_CF__c);
        System.assertEquals(2502000, financialModulesList.get(0).Financial_Details__r.get(1).Financial_Income__c);
        System.assertEquals(973000, financialModulesList.get(0).Financial_Details__r.get(1).Financial_Charges__c);
        System.assertEquals(1529000, financialModulesList.get(0).Financial_Details__r.get(1).Net_Interest_expense__c);
        System.assertEquals(1240000, financialModulesList.get(0).Financial_Details__r.get(1).EAT__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(1).Extraordinary_Items__c);
        System.assertEquals(0, financialModulesList.get(0).Financial_Details__r.get(1).Exceptional_Income__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(1).Exceptional_Charges__c);
        System.assertEquals(0, financialModulesList.get(0).Financial_Details__r.get(1).Exceptional_Items_Total__c);
        System.assertEquals(0.53, financialModulesList.get(0).Financial_Details__r.get(1).Profit_Margin__c);
        System.assertEquals(0.03, financialModulesList.get(0).Financial_Details__r.get(1).ROA_calculation_includes_taxes_x_D_B__c);
        System.assertEquals(0.09, financialModulesList.get(0).Financial_Details__r.get(1).ROE_without_Reserves__c);
        System.assertEquals(0.03, financialModulesList.get(0).Financial_Details__r.get(1).Profitability__c);
        System.assertEquals(0.21, financialModulesList.get(0).Financial_Details__r.get(1).Solvency_ratio__c);
        System.assertEquals(0.63, financialModulesList.get(0).Financial_Details__r.get(1).Leverage__c);
        System.assertEquals(-73.02, financialModulesList.get(0).Financial_Details__r.get(1).Debt_to_EBITDA__c);
        System.assertEquals(0.05, financialModulesList.get(0).Financial_Details__r.get(1).EBITDA_coverage__c);
        System.assertEquals(0.30, financialModulesList.get(0).Financial_Details__r.get(1).Current_ratio__c);
        System.assertEquals(0.30, financialModulesList.get(0).Financial_Details__r.get(1).Quick_acid_ratio__c);
        System.assertEquals(-10971000, financialModulesList.get(0).Financial_Details__r.get(1).Working_capital__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(1).Cash_flow_ratio__c);
        System.assertEquals(3.67, financialModulesList.get(0).Financial_Details__r.get(1).DSO_in_days__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(1).DPO_in_days__c);

        // 2015 score
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Total_Assets__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Total_Fixed_Assets__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Intangible_Fixed_Assets__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Tangible_Fixed_Assets__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Financial_LT_Assets__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Total_Current_Assets__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Stock_material_work__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Trade_debtors__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Cash_Cash_equivalent__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Others_Current_Assets__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Total_Liabilities__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Net_worth__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Reserves__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Liabilities__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).LongTerm_Liabilities__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).From_that_LT_bank_debt__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).From_that_Other_LT_Liabilities__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).ShortTerm_Liabilities__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).From_that_Trade_Creditors__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).From_that_ST_bank_debt__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).From_that_Other_ST_Liabilities__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Total_Turnover__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Turnover__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Activation__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Other_operational_income__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Cost_of_goods_sold__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Gross_profit_loss__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Depreciation__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Income_and_other_taxes__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).EBIT_from_Crefo__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Operational_profit_EBIT__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).EBITDA__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Calculated_CF__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Financial_Income__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Financial_Charges__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Net_Interest_expense__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).EAT__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Extraordinary_Items__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Exceptional_Income__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Exceptional_Charges__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Exceptional_Items_Total__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Profit_Margin__c);
        System.assertEquals(4, financialModulesList.get(0).Financial_Details__r.get(0).ROA_calculation_includes_taxes_x_D_B__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).ROE_without_Reserves__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Profitability__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Solvency_ratio__c);
        System.assertEquals(3, financialModulesList.get(0).Financial_Details__r.get(0).Leverage__c);
        System.assertEquals(6, financialModulesList.get(0).Financial_Details__r.get(0).Debt_to_EBITDA__c);
        System.assertEquals(6, financialModulesList.get(0).Financial_Details__r.get(0).EBITDA_coverage__c);
        System.assertEquals(6, financialModulesList.get(0).Financial_Details__r.get(0).Current_ratio__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Quick_acid_ratio__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Working_capital__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Cash_flow_ratio__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).DSO_in_days__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).DPO_in_days__c);
        System.assertEquals(5, financialModulesList.get(0).Financial_Details__r.get(0).Overall_score__c);

        System.assertEquals('Requested limit too high. Please refer to credit.', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testExistingCompanyCreditreform()
    *  Summary         : Check success search company
    *  CreatedDate     : 16/01/2018
    *  ModifiedDate    : 20/02/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest 
    public static void testExistingCompanyCreditreform() {
        Account account = CreditFactoryUtils.createCreditReformAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditreformOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditreformContact(account.Id);
        contact.LastName = contact.LastName + 'ÄäÖöÜüß';
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditreformAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditreformOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditreformCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Credit_Factory_Report__c creditReport = CreditFactoryUtils.doCreateCreditreformReport();
        creditReport.Opportunity__c = opportunity.Id;
        insert creditReport;

        Credit_Factory_Report_Employee__c creditReportEmployee = CreditFactoryUtils.doCreateCreditreformReportEmployee();
        creditReportEmployee.Credit_Factory_Report__c = creditReport.Id;
        creditReportEmployee.Name = creditReportEmployee.Name + 'AEaeOEoeUEuess';
        insert creditReportEmployee;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.doCreateCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        Test.startTest();
            controller = new CreditFactoryReportController();
            controller.init();
            controller.reportService.setUserSource('test');
            controller.reportService.getUserSource();
            controller.updateOpportunityByCredit();
            controller.changeBillingPeriodBySales();
            controller.backToOpportunity();
            controller.reportService.setUserSource('E2E Long Form');
            controller.reportService.saveReports();
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 30', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testInvalidMappingCreditSafe()
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
        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');
        CreditSystem__c creditSystem = CreditFactoryUtils.doCreateCreditSystem();
        creditSystem.Supported_Countries__c = 'Germany';
        creditSystem.Name = 'Creditsafe';
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        controller = new CreditFactoryReportController();
        controller.init();
        System.assertEquals(ApexPages.getMessages().get(0).getSummary(), 'Account mapping select error. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.doCreateCreditFactoryAccount();
        accountMapping.Name = 'Creditsafe';
        insert accountMapping;
        controller.init();
        System.assertEquals(ApexPages.getMessages().get(1).getSummary(), 'Opportunity mapping select error. ' + CreditFactoryUtilities.CONTACT_ADMIN);
    }


    /*****************************************************************************
    *  Name            : testInvalidCurrentOpportunityCreditsafe()
    *  Summary         : Check selecting opportunity with fields from mapping
    *  CreatedDate     : 22/11/2016
    *  Parameters      : 
    *  Returns         : void 
    ****************************************************************************/
    @isTest
    public static void testInvalidCurrentOpportunityCreditsafe() {
        Account account = CreditFactoryUtils.doCreateCreditsafeAccount();
        account.BillingCountry = 'Germany';
        insert account;
        Opportunity opportunity = CreditFactoryUtils.doCreateOpportunity(account.Id);
        insert opportunity;
        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '3452013902');
        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.doCreateCreditFactoryAccount();
        accountMapping.Name = 'Creditsafe';
        accountMapping.Number_of_employees__c = 'test';
        insert accountMapping;
        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.doCreateCreditFactoryOpportunity();
        opportunityMapping.Name = 'Creditsafe';
        insert opportunityMapping;
        CreditSystem__c creditSystem = CreditFactoryUtils.doCreateCreditSystem();
        creditSystem.Supported_Countries__c = 'Germany';
        creditSystem.Name = 'Creditsafe';
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        controller = new CreditFactoryReportController();
        controller.init();
        System.assertEquals(ApexPages.getMessages().get(0).getSummary(), 'Select Opportunity failed. Please contact your administrator.');
    }
    

    /*******************************************************************************
    *  Name            : testCreatingAttachmentCreditsafe()
    *  Summary         : Check creating Attachment
    *  CreatedDate     : 25/11/2016
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testCreatingAttachmentCreditsafe() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

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
            Test.setMock(HttpCalloutMock.class, new CreditsafeReportRating1Mock());
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        List<Attachment> attachmentList = [
               SELECT Name
               FROM Attachment];
        System.assertEquals(attachmentList.size(), 1);
    }


    /*******************************************************************************
    *  Name            : testCompanyInfoContacts()
    *  Summary         : Check contacts from company info                  
    *  CreatedDate     : 06/03/2018
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testCompanyInfoContacts() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

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

        CreditSystem__c creditSystemCompanyInfo = CreditFactoryUtils.createCompanyInfoCreditSystem();
        insert creditSystemCompanyInfo;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditsafeReportRating1Mock());
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        List<Credit_Factory_Report_Employee__c> listToTest = [
                SELECT Name
                FROM Credit_Factory_Report_Employee__c
                WHERE Name LIKE '%Hakan%'
                LIMIT 1000];
        System.assert( ! listToTest.isEmpty() );
    }


    /*******************************************************************************
    *  Name            : testValidateAddressCreditSafe()
    *  Summary         : Check valid address, isSales = false                     
    *  CreatedDate     : 22/11/2016
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testValidateAddressCreditSafe() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        account.BillingCity = 'test';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', 'NL007/X/200340990002');

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
            Test.setMock(HttpCalloutMock.class, new CreditsafeReportRating1Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.doUpdateAddress();
            controller.doUpdateWithAdditionalAddress();
            controller.doUpdateWithPostalAddress();
            controller.doUpdateWithRegisteredAddress();
        Test.stopTest();

        System.assertEquals(ApexPages.getMessages().get(0).getSummary(), 'Account Billing and Shipping Addresses should be the same as Creditsafe address');
    }


    /******************************************************************************
    *  Name            : testValidateContactCreditsafe()
    *  Summary         : Check valid contact, isSales = false                         
    *  CreatedDate     : 22/11/2016
    *  Parameters      : 
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testValidateContactCreditsafe() {
        Account account = CreditFactoryUtils.doCreateCreditsafeAccount();
        account.BillingCountry = 'Netherlands';
        account.BillingCountryCode = 'NL';
        account.BillingState = 'Zeeland';
        account.BillingStreet = 'Eendekooi 28';
        account.BillingCity = 'DRUNEN';
        account.BillingPostalCode = '5151RL';
        account.ShippingStreet = 'Eendekooi 28';
        account.ShippingCity = 'DRUNEN';
        account.ShippingPostalCode = '5151RL';
        account.Gesellschaftsform__c = 'Private limited liability company (BV) with ordinary structure';
        insert account;
        Opportunity opportunity = CreditFactoryUtils.doCreateOpportunity(account.Id);
        opportunity.Zahlungsart__c = 'Lastschrift';
        insert opportunity;
        Contact contact = CreditFactoryUtils.doCreateContact(opportunity.accountId);
        contact.LastName = 'test';
        insert contact;
        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');
        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.doCreateCreditFactoryAccount();
        accountMapping.Name = 'Creditsafe';
        insert accountMapping;
        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.doCreateCreditFactoryOpportunity();
        opportunityMapping.Name = 'Creditsafe';
        insert opportunityMapping;
        CreditSystem__c creditSystem = CreditFactoryUtils.doCreateCreditSystem();
        creditSystem.Supported_Countries__c = 'Netherlands';
        creditSystem.Name = 'Creditsafe';
        insert creditSystem;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.doCreateCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Credit_Factory_Report__c newReport = new Credit_Factory_Report__c(
            RecordTypeId = GlobalUtils.returnRecordTypeId('Credit_Factory_Report__c', 'Default'),
            Name = 'ADIDAS (U.K.) LIMITED',
            Name__c = 'ADIDAS (U.K.) LIMITED',
            Credit_System_Number__c = 'NL007/X/181206820000',
            City__c = 'DRUNEN',
            Country__c = 'Netherlands',
            Housenumber__c = '28',
            Legal_Form__c = 'Private limited liability company (BV) with ordinary structure',
            Opportunity__c = opportunity.Id,
            Postcode__c = '5151RL',
            Street__c = 'Eendekooi',
            Company_Id__c = 'NL007/X/181206820000',
            Class_Rating__c = '1',
            Date_Of_Foundation__c = '2015-12-10');
        insert newReport;

        Credit_Factory_Report_Employee__c employee = new Credit_Factory_Report_Employee__c(
            Credit_Factory_Report__c = newReport.Id,
            RecordTypeId = GlobalUtils.returnRecordTypeId('Credit_Factory_Report_Employee__c', 'Default'),
            Name = 'Ad Kraamer Music B.V.',
            Company_Id__c = 'NL007/X/181184350000',
            Company_Type__c = 'Ultimate Parent',
            Company_Role__c = 'ShareHolder');
        insert employee;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditsafeOwnedByCompanyMock());
            controller = new CreditFactoryReportController();
            controller.init();
            System.assertEquals('NL007/X/181184350000', controller.parentCompanyId);
            controller.doParentCompanyRequest();
            controller.changeToPendingDeposit();
        Test.stopTest();

        System.assertEquals('Creditsafe Contact person doesn\'t exist in Account\'s Contacts', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals('Decision about deposit was accepted for your client.', ApexPages.getMessages().get(1).getSummary());

        List<Credit_Factory_Report_Employee__c> testEmployees = [
                SELECT Reported__c
                FROM Credit_Factory_Report_Employee__c
                WHERE Id = :employee.Id];

        System.assertEquals(true, testEmployees.get(0).Reported__c);
    }



    /******************************************************************************
    *  Name            : testValidateCompanyNameCreditsafe()
    *  Summary         : Check valid company name, isSales = false    
    *  CreatedDate     : 22/11/2016
    *  Parameters      : 
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testValidateCompanyNameCreditsafe() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        account.Name = 'test';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.doCreateContact(opportunity.AccountId);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

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

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.doCreateCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditsafeReportRating1Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.doUpdateCompanyName();
            controller.doUpdateWithAdditionalCompanyName();
        Test.stopTest();

        System.assertEquals('Account Name and Creditsafe Name mismatch', (ApexPages.getMessages().get(0).getSummary()));
    }


    /****************************************************************************
    *  Name            : testTaxIdValidationCreditsafe()
    *  Summary         : Put in Account Tax Id different from Creditsafe company name value.                      
    *  CreatedDate     : 04/12/2018
    *  ModifiedDate    : - 
    *  Parameters      : -
    *  Returns         : void
    ***************************************************************************/
    @isTest
    public static void testTaxIdValidationCreditsafe() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        account.Steuernummer__c = 'test';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditsafeContact(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditsafeAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditsafeOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditsafeCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditsafeReportRating1Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.doUpdateTaxId();
        Test.stopTest();

        System.assertEquals('Account Tax ID mismatch (' + CreditsafeWebservice.CREDIT_SYSTEM_NAME + 
            ' to Account Tax ID)', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals('Fix all validation errors or refer to Credit.', ApexPages.getMessages().get(1).getSummary());
        System.assertEquals('Account Tax ID has been updated.', ApexPages.getMessages().get(2).getSummary());
    }


    /******************************************************************************
    *  Name            : testVatNumberValidationCreditsafe()
    *  Summary         : Put in Account Vat Number different from Creditsafe company name value.                      
    *  CreatedDate     : 04/12/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testVatNumberValidationCreditsafe() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        account.Umsatzsteuer_ID__c = 'test';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditsafeContact(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditsafeAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditsafeOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditsafeCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditsafeReportRating1Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.doUpdateVatNumber();
        Test.stopTest();

        System.assertEquals('Account VAT number mismatch (' + CreditsafeWebservice.CREDIT_SYSTEM_NAME + 
            ' to Account VAT number)', ApexPages.getMessages().get(0).getSummary());
        System.assertEquals('Fix all validation errors or refer to Credit.', ApexPages.getMessages().get(1).getSummary());
        System.assertEquals('Account VAT number has been updated.', ApexPages.getMessages().get(2).getSummary());
    }


    /******************************************************************************
    *  Name            : testLostOpportunitiesValidationCreditsafe()
    *  Summary         : Create Closed Lost Opportunity related to the current Opportunity's Account
    *  CreatedDate     : 02/04/2018
    *  ModifiedDate    : 02/04/2018 
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testLostOpportunitiesValidationCreditsafe() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        insert account;

        List<Opportunity> opportunitiesList = new List<Opportunity>();
        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        opportunitiesList.add(opportunity);

        Opportunity lostOpportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        opportunity.StageName = 'Closed Lost';
        opportunity.Gruende_verloren__c = 'Refused Credit';
        opportunitiesList.add(lostOpportunity);
        insert opportunitiesList;

        Contact contact = CreditFactoryUtils.createCreditsafeContact(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditsafeAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditsafeOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditsafeCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        CreditSystem__c additionalCreditSystem = CreditFactoryUtils.createCompanyInfoCreditSystem();
        insert additionalCreditSystem;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditsafeReportRating1Mock());
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Credit Check was rejected for one of the Opportunities linked with your Account or its Contacts. Please refer to Credit.', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testPaymentMethodValidation()
    *  Summary         : Create Opportunity with "Bank Transfer" payment method    
    *  CreatedDate     : 25/04/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testPaymentMethodValidation() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        opportunity.Zahlungsart__c = 'Banküberweisung';
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditsafeContact(account.Id);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditsafeAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditsafeOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditsafeCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        CreditSystem__c additionalCreditSystem = CreditFactoryUtils.createCompanyInfoCreditSystem();
        insert additionalCreditSystem;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.doCreateCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditsafeReportRating1Mock());
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Opportunity cannot be closed automatically with Payment Method Bank Transfer.', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testCalculateCreditLimitCreditsafe()
    *  Summary         : Check calculation Weekly+7, BiWeekly+7, Monthly+7 CreditLimit
    *  CreatedDate     : 23/11/2016
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testCalculateCreditLimitCreditsafe() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditsafeContact(opportunity.AccountId);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c accountMapping = CreditFactoryUtils.createCreditsafeAccountMapping();
        insert accountMapping;

        Credit_Factory_Opportunity__c opportunityMapping = CreditFactoryUtils.createCreditsafeOpportunityMapping();
        opportunityMapping.Monthly_Volume_Currency__c = 'test';
        insert opportunityMapping;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditsafeCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        CreditSystem__c additionalCreditSystem = CreditFactoryUtils.createCompanyInfoCreditSystem();
        insert additionalCreditSystem;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.doCreateCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditsafeReportRating1Mock());
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Credit Limit Weekly + 7 calculation failed. Please contact your administrator.', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testSetBillingPeriodRating1Creditsafe()
    *  Summary         : ClassRating = 1
    *  CreatedDate     : 23/11/2016
    *  ModifiedDate    : 19/03/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testSetBillingPeriodRating1Creditsafe() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        opportunity.SEPA_Request_Approved__c = true;
        opportunity.Total_consumption_l_month__c = 600;
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditsafeContact(opportunity.AccountId);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

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

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.doCreateCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditsafeReportRating1Mock());
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
            controller.changeToClosedWon();
            CreditCompany company = new CreditCompany();
            company.classRating = '1';
            controller.reportService.resetDeposit(company, 15, 7, 900, 900, 1000, 600, opportunity.Id);
            controller.reportService.resetDecision(15, 7, 0, '1', null, company);
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 15', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : test2SetBillingPeriodRating1Creditsafe()
    *  Summary         : ClassRating = 1
    *  CreatedDate     : 19/03/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void test2SetBillingPeriodRating1Creditsafe() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        opportunity.SEPA_Request_Approved__c = true;
        opportunity.Total_consumption_l_month__c = 1000;
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditsafeContact(opportunity.AccountId);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

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

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.doCreateCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditsafeReportRating1Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            CreditCompany company = new CreditCompany();
            company.classRating = '1';
            controller.reportService.resetDeposit(company, 30, 7, 1500, 1500, 1500, 1000, opportunity.Id);
            controller.reportService.resetDecision(30, 7, 1500, '1', null, company);
        Test.stopTest();

        System.assertEquals('Decision about deposit was accepted for your client.', ApexPages.getMessages().get(0).getSummary());
    }


    /******************************************************************************
    *  Name            : testSetBillingPeriodRating2Creditsafe()
    *  Summary         : ClassRating = 2
    *  CreatedDate     : 23/11/2016
    *  ModifiedDate    : 19/03/2019
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testSetBillingPeriodRating2Creditsafe() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        opportunity.Total_consumption_l_month__c = 600;
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditsafeContact(opportunity.AccountId);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

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

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.doCreateCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditsafeReportRating2Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.changeToPendingSEPAConfirmation();
            CreditCompany company = new CreditCompany();
            company.classRating = '2';
            controller.reportService.resetDeposit(company, 15, 7, 1500, 1500, 1500, 1000, opportunity.Id);
            controller.reportService.resetDecision(15, 7, 1500, '2', null, company);
        Test.stopTest();

        System.assertEquals(ApexPages.getMessages().get(0).getSummary(), 'Billing Period can be set to 15');
    }


    /******************************************************************************
    *  Name            : test2SetBillingPeriodRating2Creditsafe()
    *  Summary         : ClassRating = 2
    *  CreatedDate     : 19/03/2019
    *  ModifiedDate    : -
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void test2SetBillingPeriodRating2Creditsafe() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        opportunity.Total_consumption_l_month__c = 1000;
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditsafeContact(opportunity.AccountId);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

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

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.doCreateCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditsafeReportRating2Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.changeToPendingSEPAConfirmation();
            CreditCompany company = new CreditCompany();
            company.classRating = '2';
            controller.reportService.resetDeposit(company, 30, 7, 1500, 1500, 1500, 1000, opportunity.Id);
            controller.reportService.resetDecision(30, 7, 1500, '2', null, company);
        Test.stopTest();

        System.assertEquals('Decision about deposit was accepted for your client.', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testSetBillingPeriodRating3Creditsafe()
    *  Summary         : ClassRating = 3
    *  CreatedDate     : 23/11/2016
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testSetBillingPeriodRating3Creditsafe() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        opportunity.Kraftstoffverbrauch_Liter_Monat__c = 23;
        opportunity.Total_consumption_l_month__c = 6000;
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditsafeContact(opportunity.AccountId);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

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

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.doCreateCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditsafeReportRating3Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            CreditCompany company = new CreditCompany();
            company.classRating = '3';
            controller.reportService.resetDeposit(company, 7, 7, 2000, 4000, 3500, 5500, opportunity.Id);
            controller.reportService.resetDecision(7, 7, 3000, '3', null, null);
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 7', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testSetBillingPeriodRating3Creditsafe()
    *  Summary         : ClassRating = 3
    *  CreatedDate     : 23/11/2016
    *  ModifiedDate    : 28/03/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void test2SetBillingPeriodRating3Creditsafe() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        opportunity.Total_consumption_l_month__c = 600;
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditsafeContact(opportunity.AccountId);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

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

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.doCreateCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditsafeReportRating3Mock2());
            controller = new CreditFactoryReportController();
            controller.init();
            CreditCompany company = new CreditCompany();
            company.classRating = '3';
            controller.reportService.resetDeposit(company, 15, 7, 1000, 1000, 800, 600, opportunity.Id);
            controller.reportService.resetDecision(15, 7, 1000, '3', null, null);
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 15', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testSetBillingPeriodRating4Creditsafe()
    *  Summary         : ClassRating = 4 
    *  CreatedDate     : 23/11/2016
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testSetBillingPeriodRating4Creditsafe() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        opportunity.Total_consumption_l_month__c = 600;
        opportunity.Anzahl_der_Karten__c = 2;
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditsafeContact(opportunity.AccountId);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

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

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.doCreateCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditsafeReportRating4Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            CreditCompany company = new CreditCompany();
            company.classRating = '4';
            controller.reportService.resetDeposit(company, 30, 7, 2000, 4000, 3500, 5500, opportunity.Id);
            controller.reportService.resetDecision(30, 7, 3000, '4', null, null);
        Test.stopTest();

        System.assertEquals('Billing Period can be set to 15', ApexPages.getMessages().get(0).getSummary());
    }


    /******************************************************************************
    *  Name            : testSetBillingPeriodRating5Creditsafe()
    *  Summary         : ClassRating = 5 
    *  CreatedDate     : 23/11/2016
    *  Parameters      : 
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void testSetBillingPeriodRating5Creditsafe() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditsafeContact(opportunity.AccountId);
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

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

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.doCreateCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditsafeReportRating5Mock());
            controller = new CreditFactoryReportController();
            controller.init();
            controller.updateOpportunityByCredit();
            controller.changeBillingPeriodBySales();
            controller.backToOpportunity();
            CreditCompany company = new CreditCompany();
            company.classRating = '5';
            controller.reportService.resetDeposit(company, 30, 7, 2000, 4000, 3500, 5500, opportunity.Id);
            controller.reportService.resetDecision(30, 7, 3000, '5', null, null);
            controller.reportService.setUserSource('E2E Long Form');
            controller.doValidate();
            controller.reportService.saveReports();
        Test.stopTest();

        System.assertEquals('Decision about deposit was accepted for your client.', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Name            : testExistingCompanyCreditsafe()
    *  Summary         : Check CF launch with existing Credit_Factory_Report__C
    *  CreatedDate     : 27/06/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest 
    public static void testExistingCompanyCreditsafe() {
        Account account = CreditFactoryUtils.createCreditsafeAccount();
        account.BillingCountry = 'France';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createCreditsafeOpportunity(account.Id);
        insert opportunity;

        Contact contact = CreditFactoryUtils.createCreditsafeContact(account.Id);
        contact.LastName = contact.LastName + 'ÇçÉéÂâÊêÎîÔôÛûÀàÈèÙùËëÏïÜü';
        insert contact;

        ApexPages.currentPage().getParameters().put('opportunityId', opportunity.Id);
        ApexPages.currentPage().getParameters().put('creditSystemCompanyNumber', '03453452013902');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createCreditsafeAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createCreditsafeOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createCreditsafeCreditSystem();
        insert creditSystem;

        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        insert creditFactorySoqlFieldsList;

        List<Credit_Factory_Report__c> creditReportsList = new List<Credit_Factory_Report__c>();
        Credit_Factory_Report__c creditReport = CreditFactoryUtils.doCreateCreditsafeReport();
        creditReport.Opportunity__c = opportunity.Id;
        creditReportsList.add(creditReport);
        Credit_Factory_Report__c creditReport2 = CreditFactoryUtils.doCreateCreditsafeReport();
        creditReport2.Opportunity__c = opportunity.Id;
        creditReport2.RecordTypeId = GlobalUtils.returnRecordTypeId('Credit_Factory_Report__c', 'Company Info');
        creditReportsList.add(creditReport2);
        insert creditReportsList;

        List<Credit_Factory_Report_Employee__c> creditReportsEmployeesList = new List<Credit_Factory_Report_Employee__c>();
        Credit_Factory_Report_Employee__c creditReportEmployee = CreditFactoryUtils.doCreateCreditsafeReportEmployee();
        creditReportEmployee.Credit_Factory_Report__c = creditReport.Id;
        creditReportEmployee.Name = creditReportEmployee.Name + 'CcEeAaEeIiOoUuAaEeUuEeIiUu';
        creditReportsEmployeesList.add(creditReportEmployee);
        Credit_Factory_Report_Employee__c creditReportEmployee2 = CreditFactoryUtils.doCreateCreditsafeReportEmployee();
        creditReportEmployee2.Credit_Factory_Report__c = creditReport2.Id;
        creditReportEmployee2.Name = creditReportEmployee2.Name + 'CcEeAaEeIiOoUuAaEeUuEeIiUu';
        creditReportEmployee2.RecordTypeId = GlobalUtils.returnRecordTypeId('Credit_Factory_Report_Employee__c', 'Company Info');
        creditReportsEmployeesList.add(creditReportEmployee2);
        insert creditReportsEmployeesList;

        CreditSystemSalesProfile__c creditSystemSalesProfile = CreditFactoryUtils.doCreateCreditSystemSalesProfile();
        insert creditSystemSalesProfile;

        Test.startTest();
            controller = new CreditFactoryReportController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Decision about deposit was accepted for your client.', ApexPages.getMessages().get(0).getSummary());
    }
}