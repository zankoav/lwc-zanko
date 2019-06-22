@isTest
private class CustomSubmitForApprovalAMLCtrlTest {
    public static User u;
    public static Account newAccount;
    public static Opportunity newOpportunity;
    public static EmailTemplate newEmailTemplate;


    /*******************************************************************************
    *  Name            : testSubmitForApprovalAMLValidCase()
    *  Summary         : testing submit for approval (valid case) 
    *  CreatedDate     : 25/05/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testSubmitForApprovalAMLValidCase() {
        Test.startTest();
            createSalesUser();
        Test.stopTest();

        System.runAs(u) {
            createAccount();
            createOpportunity();
            createEmailTemplate();

            CustomSubmitForApprovalAMLCtrl controller = new CustomSubmitForApprovalAMLCtrl();
            ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);
            controller.init();
            controller.submitForApprovalAML();
            controller.preporationEmailsForSending('AML_notification_to_Credit_Department');
            controller.changeRegisteredCountry();
            controller.saveAndBack();
            controller.backToOpportunity();
        } 
    }


    /*******************************************************************************
    *  Name            : testSubmitForApprovaAMLlInvalidCase()
    *  Summary         : testing submit for approval (invalid case - Stage = 'CreditCheck') 
    *  CreatedDate     : 25/05/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testSubmitForApprovaAMLlInvalidCase() {
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

            CustomSubmitForApprovalAMLCtrl controller = new CustomSubmitForApprovalAMLCtrl();
            ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);
            controller.init();
            controller.submitForApprovalAML();
            controller.resubmitForApprovalAML();      
        } 
    }

    @future
    private static void createSalesUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'AllStar Sales'];
        
        u = new User(
            UserRoleId = ur.Id,
            ProfileId = p.Id,
            Username = System.now().millisecond() + '_12233121_test@test.com',
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
            RecordTypeId = rt.Id,
            Name = 'test opportunity',  
            Anzahl_der_Karten__c = 123,
            Zahlungsart__c = 'Lastschrift',
            Name_of_the_payer_Account_holder__c = 'test payer',
            Language_preference__c = 'Polish',
            IBAN__c = '23424',
            SWIFT_BIC__c = '23423',
            Derzeitige_Zahlungsmethode__c = 'Barzahlung',
            PIT_CIT_Annual_Financial_statement_for__c = true,
            Utility_bill_bank_statement__c = true,
            Copy_of_national_ID_passport__c = true,
            Details_of_REGON_CEIDG_or_KRS__c = true,
            Requested_monthly_Company_Credit_Spend__c = 12345,
            AGB_Datenschutzhinweise_Richtigkeit__c = true,
            Data_Protection_Act_1998__c = true,
            Umsatz__c = '123', 
            AccountId = newAccount.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(14),
            Bevollmaechtigung__c = true
        );
        insert newOpportunity;
    }

    private static void createEmailTemplate() {
        newEmailTemplate = new EmailTemplate(
            Name = 'test name',
            Subject = 'AML Required',
            Body = 'test',
            TemplateType = 'Text',
            FolderId = u.Id,
            DeveloperName = 'AML_notification_to_Credit_Department'
        );
        insert newEmailTemplate;
    }
}