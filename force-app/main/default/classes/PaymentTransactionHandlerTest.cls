@isTest
private class PaymentTransactionHandlerTest {

    static testMethod void testmethod1(){
        E2E_Form_General_Settings__c e2eFormGeneralSettings = new E2E_Form_General_Settings__c(
            Name = 'Germany',
            Test_mode__c = false,
            Payment_URL__c = 'https://e2e-e2efleetcor.cs89.force.com',
            Files_Generator_Url__c = 'https://e2e-e2efleetcor.cs89.force.com', 
            Enable_authorization_non_granted_check__c = true, 
            Set_GFN_Status__c = true
        );
        insert e2eFormGeneralSettings;
        Account account = new Account(Name = 'test1', BillingPostalCode = '1231');
        insert account;
        Opportunity opportunity = new Opportunity(Name = 'test1', StageName = 'Qualified Lead', CloseDate = date.today(), Accountid = account.id);
        insert opportunity;

        Payment_Transaction__c paymentTransaction = new Payment_Transaction__c();
        paymentTransaction.Amount__c = 10;
        paymentTransaction.currency__c = 'EUR';
        paymentTransaction.OpportunityId__c = opportunity.id;
        insert paymentTransaction;

        paymentTransaction.status__c = '0';
        update paymentTransaction;

        List<Payment_transaction__c> list1 = [
                SELECT id
                FROM Payment_Transaction__c
                WHERE id = :paymentTransaction.id
                AND Authorized__c = TRUE
        ];
        system.assertEquals(list1.size(),0);
    }


    static testMethod void testmethod2(){
        E2E_Form_General_Settings__c e2eFormGeneralSettings = new E2E_Form_General_Settings__c(
            Name = 'Germany',
            Test_mode__c = false,
            Payment_URL__c = 'https://e2e-e2efleetcor.cs89.force.com',
            Files_Generator_Url__c = 'https://e2e-e2efleetcor.cs89.force.com', 
            Enable_authorization_non_granted_check__c = true, 
            Set_GFN_Status__c = true
        );
        insert e2eFormGeneralSettings;
        Account account = new Account(Name = 'test1', BillingPostalCode = '1231');
        insert account;
        Opportunity opportunity = new Opportunity(Name = 'test1', StageName = 'Qualified Lead', CloseDate = date.today(), Accountid = account.id,
                Security_Amount_To_Pay__c=10);
        insert opportunity;

        Payment_Transaction__c paymentTransaction = new Payment_Transaction__c();
        paymentTransaction.Amount__c = 10;
        paymentTransaction.currency__c = 'EUR';
        paymentTransaction.OpportunityId__c = opportunity.id;
        insert paymentTransaction;

        paymentTransaction.status__c = '9';
        paymentTransaction.Authorized__c = TRUE;
        update paymentTransaction;

        List<Payment_transaction__c> list1 = [
                SELECT id
                FROM Payment_Transaction__c
                WHERE id = :paymentTransaction.id
                AND Authorized__c = TRUE
        ];

        List<Opportunity> list2 = [
                SELECT id, stagename, garantie_other__c
                FROM Opportunity
                WHERE id=:opportunity.id
                LIMIT 1
        ];

        system.assertEquals(list1.size(),1);

        system.assertEquals(list2.get(0).Stagename,'Closed Won');
        system.assertEquals(list2.get(0).garantie_other__c,paymentTransaction.Amount__c);
    }

    static testMethod void testmethod3(){
        E2E_Form_General_Settings__c e2eFormGeneralSettings = new E2E_Form_General_Settings__c(
            Name = 'Germany',
            Test_mode__c = false,
            Payment_URL__c = 'https://e2e-e2efleetcor.cs89.force.com',
            Files_Generator_Url__c = 'https://e2e-e2efleetcor.cs89.force.com', 
            Enable_authorization_non_granted_check__c = true, 
            Set_GFN_Status__c = true
        );
        insert e2eFormGeneralSettings;
        Account account = new Account(Name = 'test1', BillingPostalCode = '1231');
        insert account;
        Opportunity opportunity = new Opportunity(Name = 'test1', StageName = 'Qualified Lead', CloseDate = date.today(), Accountid = account.id,
                Security_Amount_To_Pay__c=10);
        insert opportunity;

        Payment_Transaction__c paymentTransaction = new Payment_Transaction__c();
        paymentTransaction.Amount__c = 10;
        paymentTransaction.currency__c = 'EUR';
        paymentTransaction.OpportunityId__c = opportunity.id;
        insert paymentTransaction;

        paymentTransaction.status__c = '1';
        paymentTransaction.Authorized__c = TRUE;
        update paymentTransaction;

        List<Payment_transaction__c> list1 = [
                SELECT id
                FROM Payment_Transaction__c
                WHERE id = :paymentTransaction.id
                AND Authorized__c = TRUE
        ];
        system.assertEquals(list1.size(),1);
    }


    static testMethod void testmethod4(){
        E2E_Form_General_Settings__c e2eFormGeneralSettings = new E2E_Form_General_Settings__c(
            Name = 'Germany',
            Test_mode__c = false,
            Payment_URL__c = 'https://e2e-e2efleetcor.cs89.force.com',
            Files_Generator_Url__c = 'https://e2e-e2efleetcor.cs89.force.com', 
            Enable_authorization_non_granted_check__c = true, 
            Set_GFN_Status__c = true
        );
        insert e2eFormGeneralSettings;
        Account account = new Account(Name = 'test1', BillingPostalCode = '1231');
        insert account;
        Opportunity opportunity = new Opportunity(Name = 'test1', StageName = 'Qualified Lead', CloseDate = date.today(), Accountid = account.id,
                Security_Amount_To_Pay__c=10);
        insert opportunity;

        Payment_Transaction__c paymentTransaction = new Payment_Transaction__c();
        paymentTransaction.Amount__c = 10;
        paymentTransaction.currency__c = 'EUR';
        paymentTransaction.OpportunityId__c = opportunity.id;
        insert paymentTransaction;

        paymentTransaction.status__c = '2';
        paymentTransaction.Authorized__c = TRUE;
        update paymentTransaction;

        List<Payment_transaction__c> list1 = [
                SELECT id
                FROM Payment_Transaction__c
                WHERE id = :paymentTransaction.id
                AND Authorized__c = TRUE
        ];
        system.assertEquals(list1.size(),1);
    }


    static testMethod void testmethod5(){
        E2E_Form_General_Settings__c e2eFormGeneralSettings = new E2E_Form_General_Settings__c(
            Name = 'Germany',
            Test_mode__c = false,
            Payment_URL__c = 'https://e2e-e2efleetcor.cs89.force.com',
            Files_Generator_Url__c = 'https://e2e-e2efleetcor.cs89.force.com', 
            Enable_authorization_non_granted_check__c = true, 
            Set_GFN_Status__c = true
        );
        insert e2eFormGeneralSettings;
        Account account = new Account(Name = 'test1', BillingPostalCode = '1231');
        insert account;
        Opportunity opportunity = new Opportunity(Name = 'test1', StageName = 'Qualified Lead', CloseDate = date.today(), Accountid = account.id,
                Security_Amount_To_Pay__c=10);
        insert opportunity;

        Payment_Transaction__c paymentTransaction = new Payment_Transaction__c();
        paymentTransaction.Amount__c = 10;
        paymentTransaction.currency__c = 'EUR';
        paymentTransaction.OpportunityId__c = opportunity.id;
        insert paymentTransaction;

        paymentTransaction.status__c = '12';
        paymentTransaction.Authorized__c = TRUE;
        update paymentTransaction;

        List<Payment_transaction__c> list1 = [
                SELECT id
                FROM Payment_Transaction__c
                WHERE id = :paymentTransaction.id
                AND Authorized__c = TRUE
        ];
        system.assertEquals(list1.size(),1);
    }
}