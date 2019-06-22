@isTest
private class SwitchLeadToE2EControllerTest {
    @isTest
    static void testPartnerJITB() {
        Lead_Switched_To_E2E__c switchedToE2ESettings = new Lead_Switched_To_E2E__c(
            Name = 'PolandJITB',
            Min_Cards__c = 1,
            Max_Cards__c = 2);
        insert switchedToE2ESettings;

        E2EKeysAPI__c e2eKeysApi = new E2EKeysAPI__c(
            Name = 'E2EForm',
            AES256_Key__c = 'F1kCSPMj49W2arKn9Ut0DmywkswU6E1Q/wlyutztVww=',
            paymentTransactionURL__c = 'https://ogone.test.v-psp.com/ncol/test//orderstandard_utf8.asp',
            PSPID__c = 'fleetcorTEST',
            SHA_KeyIn__c = 'FleetcorTest!12@',
            SHA_KeyOut__c = 'IngenFleetTest1!'
        );
        insert e2eKeysApi;

        List<User> e2eUser = [SELECT Id FROM User WHERE Name = 'E2E Site Guest User' LIMIT 1];
        E2E_Form_General_Settings__c e2eGeneralSettings = generateE2EGeneralSettings('Poland', e2eUser.get(0).id);
        insert e2eGeneralSettings;  

        Account newAccount = new Account(
                Name = 'test',
                OBN__c = '12312312');
        insert newAccount;    

        Lead l = new Lead(
            Salutation = 'Herr',
            LastName = 'Test JITB',
            Company = 'Test company',
            FirstName = 'Test First name',
            CountryCode = 'PL',
            Phone = '123123123',
            Email = 'test1123@wewr.wer',
            LeadSource = 'Partner',
            Partner__c = newAccount.Id,
            Partner_OBN__c = '12312312',
            Sec_Channel__c = 'JITB',
            Channel__c = 'Internet',
            OPT_IN__c = true,
            Utm_source__c = 'Partner',
            Utm_medium__c = 'display',
            Utm_campaign__c = 'Partner campaign name',
            Utm_content__c = 'Partner adset name',
            Utm_term__c = 'Partner ad name',
            Is_external__c = true,
            CCS_number_of_cards__c = 1);
        Test.startTest();            
            insert l;
        Test.stopTest();

        ApexPages.CurrentPage().getparameters().put('lid',l.Id);
        SwitchLeadToE2EController controller = new SwitchLeadToE2EController();
        controller.init();      
        List<Opportunity> oppsTest = [SELECT E2E__c FROM Opportunity LIMIT 1];  
        System.assert( ! oppsTest.isEmpty() );
        System.assert( oppsTest.get(0).E2E__c );        
    }

    @isTest
    static void testFacebook() {
        Lead_Switched_To_E2E__c switchedToE2ESettings = new Lead_Switched_To_E2E__c(
            Name = 'Germany',
            Min_Cards__c = 1,
            Max_Cards__c = 2);
        insert switchedToE2ESettings;

        E2EKeysAPI__c e2eKeysApi = new E2EKeysAPI__c(
            Name = 'E2EForm',
            AES256_Key__c = 'F1kCSPMj49W2arKn9Ut0DmywkswU6E1Q/wlyutztVww=',
            paymentTransactionURL__c = 'https://ogone.test.v-psp.com/ncol/test//orderstandard_utf8.asp',
            PSPID__c = 'fleetcorTEST',
            SHA_KeyIn__c = 'FleetcorTest!12@',
            SHA_KeyOut__c = 'IngenFleetTest1!'
        );
        insert e2eKeysApi;

        List<User> e2eUser = [SELECT Id FROM User WHERE Name = 'E2E Site Guest User' LIMIT 1];
        E2E_Form_General_Settings__c e2eGeneralSettings = generateE2EGeneralSettings('Germany', e2eUser.get(0).id);
        insert e2eGeneralSettings;      

        Lead l = new Lead(
            LastName = 'Test Facebook 1',
            Company = 'Test company',
            FirstName = 'Test First name',
            CountryCode = 'DE',
            Phone = '123123123',
            Email = 'test1123@wewr.wer',
            LeadSource = 'Facebook',
            Sec_Channel__c = 'Inbound',
            Channel__c = 'Internet',
            OPT_IN__c = true,
            Utm_source__c = 'facebook',
            Utm_medium__c = 'display',
            Utm_campaign__c = 'Facebook campaign name',
            Utm_content__c = 'Facebook adset name',
            Utm_term__c = 'Facebook ad name',
            Is_external__c = true,
            Number_of_Cards_facebook__c = '1');
        Test.startTest();       
            insert l;
        Test.stopTest();

        ApexPages.CurrentPage().getparameters().put('lid',l.Id);
        SwitchLeadToE2EController controller = new SwitchLeadToE2EController();
        controller.init();  

        List<Opportunity> oppsTest = [SELECT E2E__c FROM Opportunity LIMIT 1];  
        System.assert( ! oppsTest.isEmpty() );
        System.assert( oppsTest.get(0).E2E__c );
    }

    @isTest
    static void testInboundcall() {
        Lead_Switched_To_E2E__c switchedToE2ESettings = new Lead_Switched_To_E2E__c(
            Name = 'Belgium-FR',
            Min_Cards__c = 1,
            Max_Cards__c = 2);
        insert switchedToE2ESettings;

        E2EKeysAPI__c e2eKeysApi = new E2EKeysAPI__c(
            Name = 'E2EForm',
            AES256_Key__c = 'F1kCSPMj49W2arKn9Ut0DmywkswU6E1Q/wlyutztVww=',
            paymentTransactionURL__c = 'https://ogone.test.v-psp.com/ncol/test//orderstandard_utf8.asp',
            PSPID__c = 'fleetcorTEST',
            SHA_KeyIn__c = 'FleetcorTest!12@',
            SHA_KeyOut__c = 'IngenFleetTest1!'
        );
        insert e2eKeysApi;

        List<User> e2eUser = [SELECT Id FROM User WHERE Name = 'E2E Site Guest User' LIMIT 1];
        E2E_Form_General_Settings__c e2eGeneralSettings = generateE2EGeneralSettings('Belgium-FR', e2eUser.get(0).id);
        insert e2eGeneralSettings;      

        Lead l = new Lead(
            LastName = 'Test Facebook 1',
            Company = 'Test company',
            FirstName = 'Test First name',
            CountryCode = 'BEFR',
            Phone = '123123123',
            Email = 'test1123@wewr.wer',
            LeadSource = 'Inbound Call',
            Sec_Channel__c = 'Inbound',
            Channel__c = 'Internet',
            OPT_IN__c = true,
            Utm_source__c = 'facebook',
            Utm_medium__c = 'display',
            Utm_campaign__c = 'Facebook campaign name',
            Utm_content__c = 'Facebook adset name',
            Utm_term__c = 'Facebook ad name',
            Is_external__c = true,
            CCS_number_of_cards__c = 1);
        Test.startTest();            
            insert l;
        Test.stopTest();

        ApexPages.CurrentPage().getparameters().put('lid',l.Id);
        SwitchLeadToE2EController controller = new SwitchLeadToE2EController();
        controller.init();      
        List<Opportunity> oppsTest = [SELECT E2E__c FROM Opportunity LIMIT 1];  
        System.assert( ! oppsTest.isEmpty() );
        System.assert( oppsTest.get(0).E2E__c );        
    } 

    @isTest
    static void testInboundEmail() {
        Lead_Switched_To_E2E__c switchedToE2ESettings = new Lead_Switched_To_E2E__c(
            Name = 'Germany',
            Min_Cards__c = 1,
            Max_Cards__c = 2);
        insert switchedToE2ESettings;

        E2EKeysAPI__c e2eKeysApi = new E2EKeysAPI__c(
            Name = 'E2EForm',
            AES256_Key__c = 'F1kCSPMj49W2arKn9Ut0DmywkswU6E1Q/wlyutztVww=',
            paymentTransactionURL__c = 'https://ogone.test.v-psp.com/ncol/test//orderstandard_utf8.asp',
            PSPID__c = 'fleetcorTEST',
            SHA_KeyIn__c = 'FleetcorTest!12@',
            SHA_KeyOut__c = 'IngenFleetTest1!'
        );
        insert e2eKeysApi;

        List<User> e2eUser = [SELECT Id FROM User WHERE Name = 'E2E Site Guest User' LIMIT 1];
        E2E_Form_General_Settings__c e2eGeneralSettings = generateE2EGeneralSettings('Germany', e2eUser.get(0).id);
        insert e2eGeneralSettings;      

        Lead l = new Lead(
            LastName = 'Test Facebook 1',
            Company = 'Test company',
            FirstName = 'Test First name',
            CountryCode = 'DE',
            Phone = '123123123',
            Email = 'test1123@wewr.wer',
            LeadSource = 'Inbound Email',
            Sec_Channel__c = 'Inbound',
            Channel__c = 'Internet',
            OPT_IN__c = true,
            Utm_source__c = 'facebook',
            Utm_medium__c = 'display',
            Utm_campaign__c = 'Facebook campaign name',
            Utm_content__c = 'Facebook adset name',
            Utm_term__c = 'Facebook ad name',
            Is_external__c = true,
            CCS_number_of_cards__c = 1);
        Test.startTest();       
            insert l;
        Test.stopTest();

        ApexPages.CurrentPage().getparameters().put('lid',l.Id);
        SwitchLeadToE2EController controller = new SwitchLeadToE2EController();
        controller.init();      
        List<Opportunity> oppsTest = [SELECT E2E__c FROM Opportunity LIMIT 1];  
        System.assert( ! oppsTest.isEmpty() );
        System.assert( oppsTest.get(0).E2E__c );        
    } 

    @isTest
    static void testInboundPopup() {
        Lead_Switched_To_E2E__c switchedToE2ESettings = new Lead_Switched_To_E2E__c(
            Name = 'Germany',
            Min_Cards__c = 1,
            Max_Cards__c = 2);
        insert switchedToE2ESettings;

        E2EKeysAPI__c e2eKeysApi = new E2EKeysAPI__c(
            Name = 'E2EForm',
            AES256_Key__c = 'F1kCSPMj49W2arKn9Ut0DmywkswU6E1Q/wlyutztVww=',
            paymentTransactionURL__c = 'https://ogone.test.v-psp.com/ncol/test//orderstandard_utf8.asp',
            PSPID__c = 'fleetcorTEST',
            SHA_KeyIn__c = 'FleetcorTest!12@',
            SHA_KeyOut__c = 'IngenFleetTest1!'
        );
        insert e2eKeysApi;

        List<User> e2eUser = [SELECT Id FROM User WHERE Name = 'E2E Site Guest User' LIMIT 1];
        E2E_Form_General_Settings__c e2eGeneralSettings = generateE2EGeneralSettings('Germany', e2eUser.get(0).id);
        insert e2eGeneralSettings;      

        Lead l = new Lead(
            LastName = 'Test Facebook 1',
            Company = 'Test company',
            FirstName = 'Test First name',
            CountryCode = 'DE',
            Phone = '123123123',
            Email = 'test1123@wewr.wer',
            LeadSource = 'popup_window',
            Sec_Channel__c = 'Inbound',
            Channel__c = 'Internet',
            OPT_IN__c = true,
            Utm_source__c = 'facebook',
            Utm_medium__c = 'display',
            Utm_campaign__c = 'Facebook campaign name',
            Utm_content__c = 'Facebook adset name',
            Utm_term__c = 'Facebook ad name',
            Is_external__c = true,
            Number_of_Cards_facebook__c = '1');
        Test.startTest();       
            insert l;
        Test.stopTest();

        ApexPages.CurrentPage().getparameters().put('lid',l.Id);
        SwitchLeadToE2EController controller = new SwitchLeadToE2EController();
        controller.init();      
        List<Opportunity> oppsTest = [SELECT E2E__c FROM Opportunity LIMIT 1];  
        System.assert( ! oppsTest.isEmpty() );
        System.assert( oppsTest.get(0).E2E__c );        
    } 

    @isTest
    static void testInboundWebLP() {
        Lead_Switched_To_E2E__c switchedToE2ESettings = new Lead_Switched_To_E2E__c(
            Name = 'Germany',
            Min_Cards__c = 1,
            Max_Cards__c = 2);
        insert switchedToE2ESettings;

        E2EKeysAPI__c e2eKeysApi = new E2EKeysAPI__c(
            Name = 'E2EForm',
            AES256_Key__c = 'F1kCSPMj49W2arKn9Ut0DmywkswU6E1Q/wlyutztVww=',
            paymentTransactionURL__c = 'https://ogone.test.v-psp.com/ncol/test//orderstandard_utf8.asp',
            PSPID__c = 'fleetcorTEST',
            SHA_KeyIn__c = 'FleetcorTest!12@',
            SHA_KeyOut__c = 'IngenFleetTest1!'
        );
        insert e2eKeysApi;

        List<User> e2eUser = [SELECT Id FROM User WHERE Name = 'E2E Site Guest User' LIMIT 1];
        E2E_Form_General_Settings__c e2eGeneralSettings = generateE2EGeneralSettings('Germany', e2eUser.get(0).id);
        insert e2eGeneralSettings;      

        Lead l = new Lead(
            LastName = 'Test Facebook 1',
            Company = 'Test company',
            FirstName = 'Test First name',
            CountryCode = 'DE',
            Phone = '123123123',
            Email = 'test1123@wewr.wer',
            LeadSource = 'Web_LP',
            Sec_Channel__c = 'Inbound',
            Channel__c = 'Internet',
            OPT_IN__c = true,
            Utm_source__c = 'facebook',
            Utm_medium__c = 'display',
            Utm_campaign__c = 'Facebook campaign name',
            Utm_content__c = 'Facebook adset name',
            Utm_term__c = 'Facebook ad name',
            Is_external__c = true,
            Number_of_Cards_facebook__c = '1');
        Test.startTest();       
            insert l;
        Test.stopTest();

        ApexPages.CurrentPage().getparameters().put('lid',l.Id);
        SwitchLeadToE2EController controller = new SwitchLeadToE2EController();
        controller.init();      
        List<Opportunity> oppsTest = [SELECT E2E__c FROM Opportunity LIMIT 1];  
        System.assert( ! oppsTest.isEmpty() );
        System.assert( oppsTest.get(0).E2E__c );        
    }          

    public static E2E_Form_General_Settings__c generateE2EGeneralSettings(String country, String userId) {
        E2E_Form_General_Settings__c e2eGeneralSettings = new E2E_Form_General_Settings__c(
            Name = country,
            Abandonment_User__c = userId,
            E2E_Guest_User_Id__c = userId,
            Enable_authorization_non_granted_check__c = false,
            Files_Generator_Url__c = 'http://e2e-e2efleetcor.cs108.force.com',
            Payment_URL__c = 'https://e2e-e2efleetcor.cs108.force.com',
            Set_GFN_Status__c = false,
            Test_Mode__c = false
        );
        return e2eGeneralSettings;
    }
}