@isTest private class E2EAsyncSenderRequestsTest {

    @isTest
    static void testMethod1() {
        E2EFormRuTestUtils.initCustomSettings();

        E2EFormRuServiceImplTest.initPagesStructure();
        Map<String, LongFormPage> pagesContentMap = new  Map<String, LongFormPage>();
        E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
        formService.collectContent('Russia','PaymentDetails',pagesContentMap, GlobalUtils.DeviceType.Desktop);
        pagesContentMap.get('PAYMENT DETAILS').fields.get('PREPAYMENT AMOUNT').elementItemsMap.get('DEFAULT VALUE').Value__c = '123';

        Account account = E2EFormRuTestUtils.createAccount('123',system.today(),system.today());
        insert account;

        Opportunity opportunity = E2EFormRuTestUtils.createOpportunity(account.Id);
        insert opportunity;

        E2EFormData__c formData = E2EFormRuTestUtils.createDefaultFormData();
        formData.E2E_Account_Id__c = account.Id;
        formData.E2E_Opportunity_Id__c = opportunity.Id;
        insert formData;

        E2EFormParams formParams = new E2EFormParams();
        formParams.sendToInbound = false;
        String source ='';

        Test.startTest();
        system.enqueueJob(new E2EAsyncSenderRequests(formData.Id, formParams, pagesContentMap));
        Test.stopTest();
    }
}