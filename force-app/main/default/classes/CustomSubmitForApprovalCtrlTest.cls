@isTest
private class CustomSubmitForApprovalCtrlTest {
    public static User u;
    public static Account newAccount;
    public static Opportunity newOpportunity;
    public static EmailTemplate newEmailTeamplte;


    /*******************************************************************************
    *  Name            : submitForApprovalValidAllStarCase()
    *  Summary         : testing submit for approval (valid case) 
    *  CreatedDate     : 25/05/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void submitForApprovalValidAllStarCase() {
        Test.startTest();
            createSalesUser();
        Test.stopTest();

        System.runAs(u) {
            createAccount();
            createOpportunity();
            createEmailTemplate();

            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'submitforapproval');
            controller.init();
            controller.submitForApprovalFromValidationPage();
            controller.preporationEmailsForSending('Information_Required_to_Credit');
            controller.saveAndBack();
            controller.backToOpportunity();
        } 
    }


    /*******************************************************************************
    *  Name            : submitForApprovalInvalidAllStarCase()
    *  Summary         : testing submit for approval (invalid case - Stage = 'CreditCheck') 
    *  CreatedDate     : 25/05/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void submitForApprovalInvalidAllStarCase() {
        Test.startTest();
            createSalesUser();  
        Test.stopTest();

        System.runAs(u) {
            createAccount();
            createOpportunity();

            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Approve.');
                req.setSubmitterId(u.Id);
                req.setObjectId(newOpportunity.Id);
                //Submit the approval request
            Approval.process(req);
            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'submitforapproval'); 
            controller.init();
            controller.resubmitForApproval();       
        } 
    }


    /*******************************************************************************
    *  Name            : submitForApprovalEuroshellTest1()
    *  Summary         : testing submit for approval for Germany
    *  CreatedDate     : 02/07/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void submitForApprovalEuroshellTest1() {
        Test.startTest();
            createSalesUser();  
        Test.stopTest();

        System.runAs(u) {
            createAccount();
            createOpportunity();
            RecordType rt = [SELECT Id, Name FROM RecordType WHERE Name = 'Euroshell' AND sObjectType = 'Opportunity' LIMIT 1];
            newOpportunity.RecordTypeId = rt.Id;
            newAccount.BillingCountry = 'Germany';
            update newOpportunity;
            update newAccount;

            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Approve.');
                req.setSubmitterId(u.Id);
                req.setObjectId(newOpportunity.Id);
                //Submit the approval request
            Approval.process(req);
            newOpportunity.StageName = 'Pending Sales – Information';
            update newOpportunity;
            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'submitforapproval'); 
            controller.init();      
        } 
    }


    /*******************************************************************************
    *  Name            : submitForApprovalEuroshellTest2()
    *  Summary         : testing submit for approval for Belgium-NL
    *  CreatedDate     : 02/07/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void submitForApprovalEuroshellTest2() {
        Test.startTest();
            createSalesUser();  
        Test.stopTest();

        System.runAs(u) {
            createAccount();
            createOpportunity();
            RecordType rt = [SELECT Id, Name FROM RecordType WHERE Name = 'Euroshell' AND sObjectType = 'Opportunity' LIMIT 1];
            newOpportunity.RecordTypeId = rt.Id;
            newAccount.BillingCountry = 'Belgium-NL';
            update newOpportunity;
            update newAccount;

            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Approve.');
                req.setSubmitterId(u.Id);
                req.setObjectId(newOpportunity.Id);
                //Submit the approval request
            Approval.process(req);
            newOpportunity.StageName = 'Pending Sales – Information';
            update newOpportunity;
            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'submitforapproval'); 
            controller.init();      
        } 
    }


    /*******************************************************************************
    *  Name            : submitForApprovalEuroshellTest3()
    *  Summary         : testing submit for approval for Netherlands
    *  CreatedDate     : 02/07/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void submitForApprovalEuroshellTest3() {
        Test.startTest();
            createSalesUser();  
        Test.stopTest();

        System.runAs(u) {
            createAccount();
            createOpportunity();
            RecordType rt = [SELECT Id, Name FROM RecordType WHERE Name = 'Euroshell' AND sObjectType = 'Opportunity' LIMIT 1];
            newOpportunity.RecordTypeId = rt.Id;
            newAccount.BillingCountry = 'Netherlands';
            update newOpportunity;
            update newAccount;

            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Approve.');
                req.setSubmitterId(u.Id);
                req.setObjectId(newOpportunity.Id);
                //Submit the approval request
            Approval.process(req);
            newOpportunity.StageName = 'Pending Sales – Information';
            update newOpportunity;
            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'submitforapproval'); 
            controller.init();      
        } 
    }


    /*****************************************************************************
    *  Name            : submitForApprovalEuroshellTest4()
    *  Summary         : testing submit for approval for Hungary
    *  CreatedDate     : 02/07/2017
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void submitForApprovalEuroshellTest4() {
        Test.startTest();
            createSalesUser();  
        Test.stopTest();

        System.runAs(u) {
            createAccount();
            createOpportunity();
            RecordType rt = [SELECT Id, Name FROM RecordType WHERE Name = 'Euroshell' AND sObjectType = 'Opportunity' LIMIT 1];
            newOpportunity.RecordTypeId = rt.Id;
            newAccount.BillingCountry = 'Hungary';
            update newOpportunity;
            update newAccount;

            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Approve.');
                req.setSubmitterId(u.Id);
                req.setObjectId(newOpportunity.Id);
                //Submit the approval request
            Approval.process(req);
            newOpportunity.StageName = 'Pending Sales – Information';
            update newOpportunity;
            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'submitforapproval'); 
            controller.init();      
        } 
    }


    /******************************************************************************
    *  Name            : submitForApprovalEuroshellTest5()
    *  Summary         : testing submit for approval for Poland
    *  CreatedDate     : 02/07/2017
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void submitForApprovalEuroshellTest5() {
        Test.startTest();
            createSalesUser();  
        Test.stopTest();

        System.runAs(u) {
            createAccount();
            createOpportunity();
            RecordType rt = [SELECT Id, Name FROM RecordType WHERE Name = 'Euroshell' AND sObjectType = 'Opportunity' LIMIT 1];
            newOpportunity.RecordTypeId = rt.Id;
            newAccount.BillingCountry = 'Poland';
            update newOpportunity;
            update newAccount;

            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Approve.');
                req.setSubmitterId(u.Id);
                req.setObjectId(newOpportunity.Id);
                //Submit the approval request
            Approval.process(req);
            newOpportunity.StageName = 'Pending Sales – Information';
            update newOpportunity;
            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'submitforapproval'); 
            controller.init();      
        } 
    }


    /*******************************************************************************
    *  Name            : submitForApprovalEuroshellTest6()
    *  Summary         : testing submit for approval for Switzerland-IT
    *  CreatedDate     : 02/07/2017
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void submitForApprovalEuroshellTest6() {
        Test.startTest();
            createSalesUser();  
        Test.stopTest();

        System.runAs(u) {
            createAccount();
            createOpportunity();
            RecordType rt = [SELECT Id, Name FROM RecordType WHERE Name = 'Euroshell' AND sObjectType = 'Opportunity' LIMIT 1];
            newOpportunity.RecordTypeId = rt.Id;
            newAccount.BillingCountry = 'Switzerland-IT';
            update newOpportunity;
            update newAccount;

            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Approve.');
                req.setSubmitterId(u.Id);
                req.setObjectId(newOpportunity.Id);
                //Submit the approval request
            Approval.process(req);
            newOpportunity.StageName = 'Pending Sales – Information';
            update newOpportunity;
            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'submitforapproval'); 
            controller.init();      
        } 
    }


    /*******************************************************************************
    *  Name            : submitForApprovalEuroshellTest7()
    *  Summary         : testing submit for approval for Luxembourg
    *  CreatedDate     : 02/07/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void submitForApprovalEuroshellTest7() {
        Test.startTest();
            createSalesUser();  
        Test.stopTest();

        System.runAs(u) {
            createAccount();
            createOpportunity();
            RecordType rt = [SELECT Id, Name FROM RecordType WHERE Name = 'Euroshell' AND sObjectType = 'Opportunity' LIMIT 1];
            newOpportunity.RecordTypeId = rt.Id;
            newAccount.BillingCountry = 'Luxembourg';
            update newOpportunity;
            update newAccount;

            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Approve.');
                req.setSubmitterId(u.Id);
                req.setObjectId(newOpportunity.Id);
                //Submit the approval request
            Approval.process(req);
            newOpportunity.StageName = 'Pending Sales – Information';
            update newOpportunity;
            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'submitforapproval'); 
            controller.init();      
        } 
    }

    @isTest
    public static void submitForApprovalEuroshellTest8() {
        Test.startTest();
            createSalesUser();
        Test.stopTest();

        System.runAs(u) {
            createAccount();
            createOpportunity();
            RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Euroshell' AND sObjectType = 'Opportunity' LIMIT 1];
            newOpportunity.RecordTypeId = rt.Id;
            newAccount.BillingCountry = 'Czech Republic';
            update newOpportunity;
            update newAccount;

            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'submitforapproval');
            controller.init();
            controller.submitForApprovalFromValidationPage();
        } 
    }


    /*******************************************************************************
    *  Name            : submitForApprovalEuroshellTest10()
    *  Summary         : Send valid CHDE opportunity for approval
    *  CreatedDate     : 10/10/2018
    *. ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void submitForApprovalEuroshellTest10() {
        Test.startTest();
            createSalesUser();
        Test.stopTest();

        System.runAs(u) {
            createAccount();
            createOpportunity();
            RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Euroshell' AND sObjectType = 'Opportunity' LIMIT 1];
            newOpportunity.RecordTypeId = rt.Id;
            newAccount.BillingCountry = 'Switzerland-DE';
            update newOpportunity;
            update newAccount;

            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'submitforapproval');
            controller.init();
            controller.submitForApprovalFromValidationPage();
        } 
    }


    /*******************************************************************************
    *  Name            : submitForApprovalEuroshellTest11()
    *  Summary         : Send valid CHIT opportunity for approval
    *  CreatedDate     : 18/10/2018
    *. ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void submitForApprovalEuroshellTest11() {
        Test.startTest();
            createSalesUser();
        Test.stopTest();

        System.runAs(u) {
            createAccount();
            createOpportunity();
            RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Euroshell' AND sObjectType = 'Opportunity' LIMIT 1];
            newOpportunity.RecordTypeId = rt.Id;
            newAccount.BillingCountry = 'Switzerland-IT';
            update newOpportunity;
            update newAccount;

            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'submitforapproval');
            controller.init();
            controller.submitForApprovalFromValidationPage();
        } 
    }


    /*******************************************************************************
    *  Name            : submitForApprovalEuroshellTest12()
    *  Summary         : Send valid CHFR opportunity for approval
    *  CreatedDate     : 18/10/2018
    *. ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void submitForApprovalEuroshellTest12() {
        Test.startTest();
            createSalesUser();
        Test.stopTest();

        System.runAs(u) {
            createAccount();
            createOpportunity();
            RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Euroshell' AND sObjectType = 'Opportunity' LIMIT 1];
            newOpportunity.RecordTypeId = rt.Id;
            newAccount.BillingCountry = 'Switzerland-FR';
            update newOpportunity;
            update newAccount;

            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'submitforapproval');
            controller.init();
            controller.submitForApprovalFromValidationPage();
        } 
    }


    /*******************************************************************************
    *  Name            : submitForApprovalEuroshellTest9()
    *  Summary         : Send valid AT opportunity for approval
    *  CreatedDate     : 10/10/2018
    *. ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void submitForApprovalEuroshellTest9() {
        Test.startTest();
            createSalesUser();
        Test.stopTest();

        System.runAs(u) {
            createAccount();
            createOpportunity();
            RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Euroshell' AND sObjectType = 'Opportunity' LIMIT 1];
            newOpportunity.RecordTypeId = rt.Id;
            newAccount.BillingCountry = 'Austria';
            update newOpportunity;
            update newAccount;

            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'submitforapproval');
            controller.init();
            controller.submitForApprovalFromValidationPage();
        } 
    }


    /*******************************************************************************
    *  Name            : submitForApprovalEuroshellTest9()
    *  Summary         : Send valid LU opportunity for approval
    *  CreatedDate     : 21/11/2018
    *. ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void submitForApprovalEuroshellTest13() {
        Test.startTest();
            createSalesUser();
        Test.stopTest();

        System.runAs(u) {
            createAccount();
            createOpportunity();
            RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Euroshell' AND sObjectType = 'Opportunity' LIMIT 1];
            newOpportunity.RecordTypeId = rt.Id;
            newAccount.BillingCountry = 'Luxembourg';
            update newOpportunity;
            update newAccount;

            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'submitforapproval');
            controller.init();
            controller.submitForApprovalFromValidationPage();
        } 
    }


    /*******************************************************************************
    *  Name            : validateCreditFactoryGermanyTest()
    *  Summary         : testing valid opportunity for CF
    *  CreatedDate     : 21/12/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void validateCreditFactoryGermanyTest() {
        Test.startTest();
            createSalesUser();
        Test.stopTest();

        System.runAs(u) {
            createAccount();
            createOpportunity();
            RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Euroshell' AND sObjectType = 'Opportunity' LIMIT 1];
            newOpportunity.RecordTypeId = rt.Id;
            newAccount.BillingCountry = 'Germany';
            update newOpportunity;
            update newAccount;

            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'creditfactory');
            controller.init();
        } 
    }


    /*******************************************************************************
    *  Name            : validateCreditFactoryBelgiumTest()
    *  Summary         : testing valid opportunity for CF
    *  CreatedDate     : 21/12/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void validateCreditFactoryBelgiumTest() {
        Test.startTest();
            createSalesUser();
        Test.stopTest();

        System.runAs(u) {
            createAccount();
            createOpportunity();
            RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Euroshell' AND sObjectType = 'Opportunity' LIMIT 1];
            newOpportunity.RecordTypeId = rt.Id;
            newAccount.BillingCountry = 'Belgium-FR';
            update newOpportunity;
            update newAccount;

            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'creditfactory');
            controller.init();
        } 
    }


    /******************************************************************************
    *  Name            : validateCreditFactoryNetherlandsTest()
    *  Summary         : testing valid opportunity for CF
    *  CreatedDate     : 21/12/2017
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    public static void validateCreditFactoryNetherlandsTest() {
        Test.startTest();
            createSalesUser();
        Test.stopTest();

        System.runAs(u) {
            createAccount();
            createOpportunity();
            RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Euroshell' AND sObjectType = 'Opportunity' LIMIT 1];
            newOpportunity.RecordTypeId = rt.Id;
            newAccount.BillingCountry = 'Netherlands';
            update newOpportunity;
            update newAccount;

            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'creditfactory');
            controller.init();
        } 
    }


    /*******************************************************************************
    *  Name            : validateCreditFactoryFranceTest()
    *  Summary         : testing valid opportunity for CF
    *  CreatedDate     : 21/12/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void validateCreditFactoryFranceTest() {
        Test.startTest();
            createSalesUser();
        Test.stopTest();

        System.runAs(u) {
            createAccount();
            createOpportunity();
            RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Euroshell' AND sObjectType = 'Opportunity' LIMIT 1];
            newOpportunity.RecordTypeId = rt.Id;
            newAccount.BillingCountry = 'France';
            update newOpportunity;
            update newAccount;

            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'creditfactory');
            controller.init();
        } 
    }


    /*******************************************************************************
    *  Name            : validateCreditFactoryPolandTest()
    *  Summary         : testing valid opportunity for CF
    *  CreatedDate     : 19/01/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void validateCreditFactoryPolandTest() {
        Test.startTest();
            createSalesUser();
        Test.stopTest();

        System.runAs(u) {
            createAccount();
            createOpportunity();
            RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Euroshell' AND sObjectType = 'Opportunity' LIMIT 1];
            newOpportunity.RecordTypeId = rt.Id;
            newAccount.BillingCountry = 'Poland';
            update newOpportunity;
            update newAccount;

            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'creditfactory');
            controller.init();
        } 
    }


    /*******************************************************************************
    *  Name            : validateCreditFactoryAustriaTest()
    *  Summary         : Launch CF for valid AT opportunity.
    *  CreatedDate     : 10/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void validateCreditFactoryAustriaTest() {
        Test.startTest();
            createSalesUser();
        Test.stopTest();

        System.runAs(u) {
            createAccount();
            createOpportunity();
            RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Euroshell' AND sObjectType = 'Opportunity' LIMIT 1];
            newOpportunity.RecordTypeId = rt.Id;
            newAccount.BillingCountry = 'Austria';
            update newOpportunity;
            update newAccount;

            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'creditfactory');
            controller.init();
        } 
    }


    /*******************************************************************************
    *  Name            : validateCreditFactorySwitzerlandDETest()
    *  Summary         : Launch CF for valid CHDE opportunity.
    *  CreatedDate     : 18/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void validateCreditFactorySwitzerlandDETest() {
        Test.startTest();
            createSalesUser();
        Test.stopTest();

        System.runAs(u) {
            createAccount();
            createOpportunity();
            RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Euroshell' AND sObjectType = 'Opportunity' LIMIT 1];
            newOpportunity.RecordTypeId = rt.Id;
            newAccount.BillingCountry = 'Switzerland-DE';
            update newOpportunity;
            update newAccount;

            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'creditfactory');
            controller.init();
        } 
    }


    /*******************************************************************************
    *  Name            : validateCreditFactorySwitzerlandITTest()
    *  Summary         : Launch CF for valid CHIT opportunity.
    *  CreatedDate     : 18/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void validateCreditFactorySwitzerlandITTest() {
        Test.startTest();
            createSalesUser();
        Test.stopTest();

        System.runAs(u) {
            createAccount();
            createOpportunity();
            RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Euroshell' AND sObjectType = 'Opportunity' LIMIT 1];
            newOpportunity.RecordTypeId = rt.Id;
            newAccount.BillingCountry = 'Switzerland-IT';
            update newOpportunity;
            update newAccount;

            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'creditfactory');
            controller.init();
        } 
    }


    /*******************************************************************************
    *  Name            : validateCreditFactorySwitzerlandFRTest()
    *  Summary         : Launch CF for valid CHFR opportunity.
    *  CreatedDate     : 18/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void validateCreditFactorySwitzerlandFRTest() {
        Test.startTest();
            createSalesUser();
        Test.stopTest();

        System.runAs(u) {
            createAccount();
            createOpportunity();
            RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Euroshell' AND sObjectType = 'Opportunity' LIMIT 1];
            newOpportunity.RecordTypeId = rt.Id;
            newAccount.BillingCountry = 'Switzerland-FR';
            update newOpportunity;
            update newAccount;

            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'creditfactory');
            controller.init();
        } 
    }


    /*******************************************************************************
    *  Name            : validateCreditFactoryLuxembourgTest()
    *  Summary         : Launch CF for valid LU opportunity.
    *  CreatedDate     : 21/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void validateCreditFactoryLuxembourgTest() {
        Test.startTest();
            createSalesUser();
        Test.stopTest();

        System.runAs(u) {
            createAccount();
            createOpportunity();
            RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Euroshell' AND sObjectType = 'Opportunity' LIMIT 1];
            newOpportunity.RecordTypeId = rt.Id;
            newAccount.BillingCountry = 'Luxembourg';
            update newOpportunity;
            update newAccount;

            CustomSubmitForApprovalCtrl controller = new CustomSubmitForApprovalCtrl();
            ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);
            ApexPages.currentPage().getParameters().put('type', 'creditfactory');
            controller.init();
        } 
    }


    @future
    private static void createSalesUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'AllStar Sales'];
        
        u = new User(
            UserRoleId = ur.Id,
            ProfileId = p.Id,
            Username = System.now().millisecond() + '_233232321_test@test.com',
            Alias = 'batman',
            Email='bruce.wayne_1233@wayneenterprises.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
        );
        Database.insert(u);    
    }

    private static void createAccount() {
        List<Account> accountsList = new List<Account>();
        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'AllStar' AND sObjectType = 'Account' LIMIT 1];
        newAccount = new Account(
            RecordTypeId = rt.Id,
            Name = 'test account',
            Trading_Name__c = 'test trading name',
            NIP__c = '1234567899',
            REGON__c = '9987654321',
            KRS__c = '1234554321',
            Gesellschaftsform__c = 'Sole trader',
            YearStarted = '1999',
            Phone = '+48 7777777',
            Mobile_Phone__c = '+48 3333333',
            Website = 'testsite.com',
            BillingCountry = 'Poland',
            BillingStreet = 'street name',
            BillingCity = 'Warsaw',
            BillingPostalCode = '123455',
            Bundesland__c = 'Berlin',
            Allstar_Email__c = 'test@test.com',
            ShippingStreet = 'shipping street',
            ShippingCity = 'Warsaw',
            ShippingPostalCode = '123455',
            ShippingCountry = 'Poland',
            Beschaeftigte__c = '5-9',
            Branche_NACE__c = 'Manufacturing',
            Web_form_password__c = 'password123'
        );   
        insert newAccount;
    }

    private static void createOpportunity() {
        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'AllStar' AND sObjectType = 'Opportunity' LIMIT 1];
        newOpportunity = new Opportunity(
            OwnerId = u.Id,
            RecordTypeId = rt.Id,
            Name = 'test opportunity',  
            Anzahl_der_Karten__c = 123,
            Name_of_the_payer_Account_holder__c = 'test payer',
            Language_preference__c = 'Polish',
            Total_consumption_l_month__c = 123,
            Derzeitige_Zahlungsmethode__c = 'Bankkarte',
            Zahlungssystem__c = 'Visa',
            Bank__c = 'bank',
            Zahlungsart__c = 'Lastschrift',
            IBAN__c = '1234567789',
            SWIFT_BIC__c = '987654321',
            Requested_monthly_Company_Credit_Spend__c = 12345,
            AGB_Datenschutzhinweise_Richtigkeit__c = true,
            Data_Protection_Act_1998__c = true,
            Umsatz__c = '123', 
            AccountId = newAccount.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(14),
            Bevollmaechtigung__c = true,
            CF_Stage__c = 'Launched',
            Last_CF_Errors__c = 'error'
        );
        insert newOpportunity;
    }

    private static void createEmailTemplate() {
        newEmailTeamplte = new EmailTemplate(
            Name = 'Email with URL to Form',
            DeveloperName = 'Information_Required_to_Credit',
            Subject = 'Request Information',
            Body = 'test',
            TemplateType = 'Text',
            FolderId = UserInfo.getUserId()
        );
        insert newEmailTeamplte;
    }
}