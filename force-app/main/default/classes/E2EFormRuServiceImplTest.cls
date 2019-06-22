@isTest
public with sharing class E2EFormRuServiceImplTest {

    public static String INN = '1111111111';
    public static String email = 'test@domovoi.ru';
    public static String phone = '9265444341';

    public static void initPagesStructure() {
        E2EFormRuTestUtils.createLongFormRU();
        E2EFormRuTestUtils.createContactDetailsStep();
        E2EFormRuTestUtils.createCompanyInformationStep();
        E2EFormRuTestUtils.createOrderStep();
        E2EFormRuTestUtils.createLegalDetailsStep();
        E2EFormRuTestUtils.createPaymentDetailsStep();
        E2EFormRuTestUtils.createCongratulationsStep();
    }

    public static void initCustomSettings() {
        E2EFormRuTestUtils.initCustomSettings();
    }

    public static void initE2EFormParamsData(E2EFormParams formParams) {
        formParams.sparkId = 123456;
        formParams.postCodeSpark = '123456';
        formParams.citySpark = 'Moscow';
        formParams.streetSpark = 'Lenina';
        formParams.buildingSpark = '2';
        formParams.housingSpark = '3';
        formParams.blockSpark = '';
        formParams.roomSpark = '';
        formParams.regionSpark = 'Moscow region';
        formParams.deviceType = 'Desktop';
        formParams.ipAddress = '192.168.1.2';

        // SoleProprietor
        formParams.isSoleProprietor = false;
        formParams.soleProprietorFio = 'Lebedev Ivan Nikola';
        formParams.ogrnipSpark = '231111111';
        formParams.registrationDateSpark = '2014-15-15T00:00:00.000';
        formParams.mainCompanyFullNameSpark = 'ИП Lebedev';


        // legal person
        formParams.executiveFio = 'Lebedev Ivan Nikola';
        formParams.okpoSpark = '333333333';
        formParams.normName = 'Ромашка Inc, ОАО';
        formParams.ogrnSpark = '45634563456';
        formParams.kppSpark = '43523456456';

        // contract
        formParams.contractPrefix = '4';
        formParams.contractCounter = '171';

        // bank info
        formParams.bankNameShort = 'Сбербанк';
        formParams.bankBic = '56435634';
        formParams.bankTown = 'Moscow';
        formParams.bankAddress = 'Vavilova street';

        // scoring
        formParams.scoringDecisionCode = '0';
        formParams.scoringDecision = 'Ok';
        formParams.scoringDate = System.Today();
        formParams.verifiedDecisionCode = '3';
        formParams.opportunityLostReason = 'Test Reason';

        formParams.promocodeName = '7E10';
        formParams.promocodeIdInTransit = '112';
        formParams.requestNumMZK = '123456';
        formParams.transitContId = '3452345234512341234';
    }

    public static void initContentMap(Map<String, LongFormPage> pagesMap) {
        pagesMap.get('COMPANY INFORMATION').fields.get('ACCOUNT NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Test Company Name';
        pagesMap.get('COMPANY INFORMATION').fields.get('INN').elementItemsMap.get('DEFAULT VALUE').Value__c = '1111111111';
        pagesMap.get('COMPANY INFORMATION').fields.get('IS MANUAL ENTRY').elementItemsMap.get('DEFAULT VALUE').Value__c = 'FALSE';

        pagesMap.get('LEGAL DETAILS').fields.get('OGRN').elementItemsMap.get('DEFAULT VALUE').Value__c = '1137847243028';
        pagesMap.get('LEGAL DETAILS').fields.get('KPP').elementItemsMap.get('DEFAULT VALUE').Value__c = '781001002';
        pagesMap.get('LEGAL DETAILS').fields.get('OKPO').elementItemsMap.get('DEFAULT VALUE').Value__c = '27464154';
        pagesMap.get('LEGAL DETAILS').fields.get('CODE WORD').elementItemsMap.get('DEFAULT VALUE').Value__c = 'йцукен';
        pagesMap.get('LEGAL DETAILS').fields.get('EXECUTIVE PERSON').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Ivanov Ivan Ivanovich';
        pagesMap.get('LEGAL DETAILS').fields.get('EXECUTIVE PERSON POSITION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Decision maker';
        pagesMap.get('LEGAL DETAILS').fields.get('CHIEF ACCOUNTANT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Pertova Maria Ivanovna';
        pagesMap.get('LEGAL DETAILS').fields.get('USER ACCOUNT EMAIL').elementItemsMap.get('DEFAULT VALUE').Value__c = 'test@test.ru';

        // legal address
        pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('CITY').Value__c = 'г. Санкт-Петербург';
        pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('STREET').Value__c  = 'ул. Свеаборгская';
        pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('HOUSE NUMBER').Value__c = ', дом 4, литера А';
        pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS ADDITIONALLY').elementItemsMap.get('DEFAULT VALUE').Value__c = '';
        pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('POSTAL CODE').Value__c = '196105';
        pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('STATE').Value__c = 'г. Санкт-Петербург';
        pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('COUNTRY').Value__c = 'Russia';
        pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'улица Пушкина, дом Колотушкина';

        // postal address
        pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('CITY').Value__c = 'г. Санкт-Петербург';
        pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('STREET').Value__c = 'ул. Свеаборгская';
        pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('HOUSE NUMBER').Value__c = ', дом 10, литера А';
        pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS ADDITIONALLY').elementItemsMap.get('DEFAULT VALUE').Value__c = '';
        pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('POSTAL CODE').Value__c = '196105';
        pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('COUNTRY').Value__c = 'Russia';
        pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('STATE').Value__c = '';
        pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'улица Пушкина, дом Колотушкина';

        pagesMap.get('PAYMENT DETAILS').fields.get('CHECKING ACCOUNT').elementItemsMap.get('DEFAULT VALUE').Value__c = '44444444444444444444';
        pagesMap.get('PAYMENT DETAILS').fields.get('BANK NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = 'ПАО СБЕРБАНК';
        pagesMap.get('PAYMENT DETAILS').fields.get('BIC').elementItemsMap.get('DEFAULT VALUE').Value__c = '044525235';
        pagesMap.get('PAYMENT DETAILS').fields.get('CORR BANK ACCOUNT').elementItemsMap.get('DEFAULT VALUE').Value__c = '30101810400000020225';
        pagesMap.get('PAYMENT DETAILS').fields.get('PREPAYMENT AMOUNT').elementItemsMap.get('DEFAULT VALUE').Value__c = '2000';

        // phone and email
        pagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '+7 (925) 651-31-27';
        pagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'test@test.ru';
        pagesMap.get('CONTACT DETAILS').fields.get('PERSONAL INFORMATION').elementItemsMap.get('DEFAULT VALUE').Value__c = 'TRUE';

                // order
        pagesMap.get('ORDER').fields.get('PRODUCTS').elementItemsMap.get('ID').Value__c = GlobalUtils.E2EProduct.PetrolPlus_Rover.name();
        pagesMap.get('ORDER').fields.get('PRODUCT TARIFF').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Оптимальный';
        pagesMap.get('ORDER').fields.get('PRODUCT TARIFF').elementItemsMap.get('TARIFF ID').Value__c = '1OPTIMAL_CARDS';
        pagesMap.get('ORDER').fields.get('AMOUNT CARD').elementItemsMap.get('DEFAULT VALUE').Value__c = '1';
        pagesMap.get('ORDER').fields.get('PROMOCODE').elementItemsMap.get('DEFAULT VALUE').Value__c = '7E10';
        pagesMap.get('ORDER').fields.get('PAY OVERDRAFT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'TRUE';
        pagesMap.get('ORDER').fields.get('GIFT LIST').elementItemsMap.get('LIST').Value__c = '<a target="_blank" rel="noopener noreferrer" href="#">АЗС-Локатор</a>,СМС-уведомления';
    }

    @isTest
    public static void testAccountService() {
        initPagesStructure();

        E2EFormRuService formService = new E2EFormRuServiceImpl();
        E2EFormParams formParams = new E2EFormParams();
        Map<String, LongFormPage> pagesMap = new Map<String, LongFormPage>();
        formService.collectContent(GlobalUtils.FleetcorCountries.Russia.name(), GlobalUtils.E2ERuSteps.Congratulations.name(), pagesMap, GlobalUtils.DeviceType.Desktop);
        initE2EFormParamsData(formParams);
        initContentMap(pagesMap);

        // create account
        Id accountId = formService.createAccount(formParams);
        System.assertNotEquals(null, accountId);

        //****** update account step: CompanyInformation ******//
        Test.startTest();
        formService.updateAccount(accountId, pagesMap, formParams, GlobalUtils.E2ERuSteps.CompanyInformation.name());
        Test.stopTest();
        Account accountFirst = E2EFormRuTestUtils.getAccountById(accountId);
        System.assertEquals(pagesMap.get('COMPANY INFORMATION').fields.get('ACCOUNT NAME').elementItemsMap.get('DEFAULT VALUE').Value__c.toUpperCase(), accountFirst.Name);
        System.assertEquals(pagesMap.get('COMPANY INFORMATION').fields.get('INN').elementItemsMap.get('DEFAULT VALUE').Value__c, accountFirst.INN__c);
        System.assertEquals(formParams.postCodeSpark, accountFirst.BillingPostalCode);
        System.assertEquals(formParams.citySpark.toUpperCase(), accountFirst.BillingCity);
        System.assertEquals(formParams.regionSpark, accountFirst.Region__c);

        //****** update account step: LegalDetails ******//
        formService.updateAccount(accountId, pagesMap, formParams, GlobalUtils.E2ERuSteps.LegalDetails.name());
        Account accountSecond = E2EFormRuTestUtils.getAccountById(accountId);
        System.assertEquals(pagesMap.get('LEGAL DETAILS').fields.get('OGRN').elementItemsMap.get('DEFAULT VALUE').Value__c, accountSecond.OGRN_ppr__c);
        System.assertEquals(Decimal.valueOf(pagesMap.get('LEGAL DETAILS').fields.get('KPP').elementItemsMap.get('DEFAULT VALUE').Value__c), accountSecond.KPP__c);
        System.assertEquals(pagesMap.get('LEGAL DETAILS').fields.get('OKPO').elementItemsMap.get('DEFAULT VALUE').Value__c, accountSecond.OKPO_ppr__c);
        System.assertEquals(pagesMap.get('LEGAL DETAILS').fields.get('CODE WORD').elementItemsMap.get('DEFAULT VALUE').Value__c, accountSecond.Code_Word__c);

        // check legal address
        System.assertEquals(pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('COUNTRY').Value__c, accountSecond.BillingCountry);
        System.assertEquals(pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('CITY').Value__c.toUpperCase(), accountSecond.BillingCity);
        System.assertEquals(pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('POSTAL CODE').Value__c.toUpperCase(), accountSecond.BillingPostalCode);
        String legalAddressStreet = pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('STREET').Value__c + ' ' +
                pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('HOUSE NUMBER').Value__c + ' ' +
                pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS ADDITIONALLY').elementItemsMap.get('DEFAULT VALUE').Value__c;
        System.assertEquals(legalAddressStreet.trim().toUpperCase(), accountSecond.BillingStreet);

        // check postal address
        System.assertEquals(pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('COUNTRY').Value__c, accountSecond.ShippingCountry);
        System.assertEquals(pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('CITY').Value__c.toUpperCase(), accountSecond.ShippingCity);
        System.assertEquals(pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('POSTAL CODE').Value__c, accountSecond.ShippingPostalCode);
        String postalAddressStreet = pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('STREET').Value__c + ' ' +
                pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('HOUSE NUMBER').Value__c + ' ' +
                pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS ADDITIONALLY').elementItemsMap.get('DEFAULT VALUE').Value__c;
        System.assertEquals(postalAddressStreet.trim().toUpperCase(), accountSecond.ShippingStreet);

        //****** update account step: PaymentDetails ******//
        formService.updateAccount(accountId, pagesMap, formParams, GlobalUtils.E2ERuSteps.PaymentDetails.name());
        Account accountThird = E2EFormRuTestUtils.getAccountById(accountId);
        System.assertEquals(pagesMap.get('PAYMENT DETAILS').fields.get('CHECKING ACCOUNT').elementItemsMap.get('DEFAULT VALUE').Value__c, accountThird.Checking_Account__c);
        System.assertEquals(pagesMap.get('PAYMENT DETAILS').fields.get('BANK NAME').elementItemsMap.get('DEFAULT VALUE').Value__c, accountThird.Bank__c);
        System.assertEquals(pagesMap.get('PAYMENT DETAILS').fields.get('BIC').elementItemsMap.get('DEFAULT VALUE').Value__c, accountThird.SWIFT_BIC__c);
        System.assertEquals(pagesMap.get('PAYMENT DETAILS').fields.get('CORR BANK ACCOUNT').elementItemsMap.get('DEFAULT VALUE').Value__c, accountThird.Cor_Bank_Account__c);

        //****** check get account by id *****//
        Account accountTest = formService.getAccountById(accountId);
        System.assertEquals(accountId, accountTest.Id);
    }

    @isTest
    public static void testContactService() {
        initPagesStructure();

        E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
        E2EFormParams formParams = new E2EFormParams();
        Map<String, LongFormPage> pagesMap = new Map<String, LongFormPage>();
        formService.collectContent(GlobalUtils.FleetcorCountries.Russia.name(), GlobalUtils.E2ERuSteps.Congratulations.name(), pagesMap, GlobalUtils.DeviceType.Desktop);
        initE2EFormParamsData(formParams);
        initContentMap(pagesMap);

        // init account
        Id accountId = E2EFormRuTestUtils.insertAccount(E2EFormRuTestUtils.createDefaultAccount()).Id;
        System.assertNotEquals(null, accountId);

        //***** test to create contact *****//
        Id contactId = formService.createContact(accountId, pagesMap, formParams);
        System.assertNotEquals(null, contactId);

        //***** test to update contact step: ContactDetails *****//
        formService.updateContact(contactId, pagesMap, formParams, GlobalUtils.E2ERuSteps.ContactDetails.name());
        Contact contactFirst = E2EFormRuTestUtils.getContactById(contactId);
        System.assertEquals(formService.convertPhone(pagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c), contactFirst.MobilePhone);
        System.assertEquals(pagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c, contactFirst.Email);
        System.assertEquals(Boolean.valueOf(pagesMap.get('CONTACT DETAILS').fields.get('MARKETING DISPATCH').elementItemsMap.get('DEFAULT VALUE').Value__c), contactFirst.Agree_to_receive_comm_info_by_email__c);
        System.assertEquals(Boolean.valueOf(pagesMap.get('CONTACT DETAILS').fields.get('PERSONAL INFORMATION').elementItemsMap.get('DEFAULT VALUE').Value__c), contactFirst.Agree_to_process_pers_data_for_marketing__c);

        //***** test to update contact step: CompanyInformation *****//
        formService.updateContact(contactId, pagesMap, formParams, GlobalUtils.E2ERuSteps.CompanyInformation.name());
        Contact contactSecond = E2EFormRuTestUtils.getContactById(contactId);
        System.assert(contactSecond.LastName.lastIndexOf('E2E') != -1);

        //***** test to create employee contact *****//
        Id employeeContactId = formService.createEmployeeContact(accountId, 'Ivanov Ivan Ivanovich', 'Decision Maker');
        Contact employeeContact = E2EFormRuTestUtils.getContactById(employeeContactId);
        System.assertEquals('Ivanov Ivan Ivanovich', employeeContact.LastName);
        System.assertEquals('Decision Maker', employeeContact.Title);

        //***** test to update employee contact *****//
        formService.updateEmployeeContact(employeeContactId, 'Petrov Petr Petrovich', 'Accounting (for invoices)');
        Contact contactThird = E2EFormRuTestUtils.getContactById(employeeContactId);
        System.assertEquals('Petrov Petr Petrovich', contactThird.LastName);
        System.assertEquals('Accounting (for invoices)', contactThird.Title);

        //***** test to update contact phone *****//
        formService.updateContactPhone(employeeContactId, '9237212121');
        Contact contactFourth = E2EFormRuTestUtils.getContactById(employeeContactId);
        System.assertEquals('9237212121', contactFourth.MobilePhone);

        //***** test to get contact by id *****//
        Contact existingContact = formService.getContactById(employeeContactId);
        System.assertNotEquals(null, existingContact);
    }

    @isTest
    public static void testOpportunityService() {
        initPagesStructure();
        initCustomSettings();

        E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
        E2EFormParams formParams = new E2EFormParams();
        Map<String, LongFormPage> pagesMap = new Map<String, LongFormPage>();
        formService.collectContent(GlobalUtils.FleetcorCountries.Russia.name(), GlobalUtils.E2ERuSteps.Congratulations.name(), pagesMap, GlobalUtils.DeviceType.Desktop);
        initE2EFormParamsData(formParams);
        initContentMap(pagesMap);

        // init account
        Id accountId = E2EFormRuTestUtils.insertAccount(E2EFormRuTestUtils.createDefaultAccount()).Id;
        System.assertNotEquals(null, accountId);

        //***** test to create opportunity *****//
        Id opportunityId = formService.createOpportunity(accountId, formParams);
        System.assertNotEquals(null, opportunityId);

        //***** test to update opportunity step: CompanyInformation *****//
        formService.updateOpportunity(opportunityId, pagesMap, formParams, GlobalUtils.E2ERuSteps.CompanyInformation.name());
        Opportunity opportunityFirst = E2EFormRuTestUtils.getOpportunityById(opportunityId);
        System.assertEquals(pagesMap.get('COMPANY INFORMATION').fields.get('ACCOUNT NAME').elementItemsMap.get('DEFAULT VALUE').Value__c.toUpperCase(), opportunityFirst.Name);
        System.assertEquals(Boolean.valueOf(pagesMap.get('COMPANY INFORMATION').fields.get('IS MANUAL ENTRY').elementItemsMap.get('DEFAULT VALUE').Value__c), opportunityFirst.Manual_Entry__c);
        System.assertEquals(formParams.scoringDate, opportunityFirst.Scoring_Date__c);
        System.assertEquals('Отклонен', opportunityFirst.E2E_Sales_Type__c);
        System.assertEquals('Чёрный список', opportunityFirst.E2E_Sub_Status__c);

        //***** test to update opportunity step: Order *****//
        formService.updateOpportunity(opportunityId, pagesMap, formParams, GlobalUtils.E2ERuSteps.Order.name());
        Opportunity opportunitySecond = E2EFormRuTestUtils.getOpportunityById(opportunityId);
        System.assertEquals('Вездеход Online "Оптимальный" Карты', opportunitySecond.Product_PPR__c);
        System.assertEquals(pagesMap.get('ORDER').fields.get('PROMOCODE').elementItemsMap.get('DEFAULT VALUE').Value__c, opportunitySecond.Promo_campaign__c);
        System.assertEquals(Integer.valueOf(pagesMap.get('ORDER').fields.get('AMOUNT CARD').elementItemsMap.get('DEFAULT VALUE').Value__c), opportunitySecond.Number_of_Cards__c);
        System.assertEquals('Agreement Terms and Conditions', opportunitySecond.StageName);

        //***** test to update opportunity step: PaymentDetails *****//
        formService.updateOpportunity(opportunityId, pagesMap, formParams, GlobalUtils.E2ERuSteps.PaymentDetails.name());
        Opportunity opportunityThird = E2EFormRuTestUtils.getOpportunityById(opportunityId);

        //***** test to update opportunity step: Congratulations *****//
        formService.updateOpportunity(opportunityId, pagesMap, formParams, GlobalUtils.E2ERuSteps.Congratulations.name());
        Opportunity opportunityFourth = E2EFormRuTestUtils.getOpportunityById(opportunityId);
        System.assertEquals('Клиент завершил', opportunityFourth.E2E_Status__c);

        //***** test forceUpdateOpportunity *****//
        formService.forceUpdateOpportunity(opportunityId, 'Error');
        Opportunity opportunityFifth = E2EFormRuTestUtils.getOpportunityById(opportunityId);
        System.assertEquals('Перевод в ручную обработку', opportunityFifth.E2E_Sub_Status__c);
        System.assertEquals('Клиент завершил', opportunityFifth.E2E_Status__c);
        System.assertEquals('Error', opportunityFifth.E2E_Errors__c);
    }

    @isTest
    public static void testOpportunityContactRoleService() {
        initPagesStructure();
        initCustomSettings();

        E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
        E2EFormParams formParams = new E2EFormParams();
        Map<String, LongFormPage> pagesMap = new Map<String, LongFormPage>();
        formService.collectContent(GlobalUtils.FleetcorCountries.Russia.name(), GlobalUtils.E2ERuSteps.Congratulations.name(), pagesMap, GlobalUtils.DeviceType.Desktop);
        initE2EFormParamsData(formParams);
        initContentMap(pagesMap);

        // init opportunity and account
        Opportunity opportunity = E2EFormRuTestUtils.insertOpportunity(E2EFormRuTestUtils.createDefaultOpportunity());

        Id accountId = opportunity.AccountId;
        Id opportunityId = opportunity.Id;

        //***** test to create opportunityContactRole *****//
        formService.createOpportunityContactRoles(opportunityId, accountId, pagesMap, GlobalUtils.E2ERuSteps.LegalDetails.name());
        //TODO: Дописать тест на проверку созданного контакта

    }

    @isTest
    public static void testFormDataService() {
        initPagesStructure();
        initCustomSettings();

        E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
        E2EFormParams formParams = new E2EFormParams();
        Map<String, LongFormPage> pagesMap = new Map<String, LongFormPage>();
        formService.collectContent(GlobalUtils.FleetcorCountries.Russia.name(), GlobalUtils.E2ERuSteps.Congratulations.name(), pagesMap, GlobalUtils.DeviceType.Desktop);
        initE2EFormParamsData(formParams);
        initContentMap(pagesMap);

        // init account
        Id accountId = E2EFormRuTestUtils.insertAccount(E2EFormRuTestUtils.createDefaultAccount()).Id;
        System.assertNotEquals(null, accountId);

        // create opportunity
        Id opportunityId = E2EFormRuTestUtils.insertOpportunity(E2EFormRuTestUtils.createOpportunity(accountId)).Id;
        System.assertNotEquals(null, opportunityId);

        // create contact
        Id contactId = E2EFormRuTestUtils.insertContact(E2EFormRuTestUtils.createContact(accountId)).Id;
        System.assertNotEquals(null, contactId);

        //***** test to create FormDataRecord *****//
        Id formDataId = formService.createFormDataRecord(accountId, contactId, opportunityId, pagesMap, formParams);
        E2EFormData__c formDataRecord = E2EFormRuTestUtils.getFormDataById(formDataId);
        System.assertEquals(formParams.ipAddress, formDataRecord.E2E_IP_Address__c);
        System.assertEquals(pagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c, formDataRecord.E2E_Contact_Phone__c);
        System.assertEquals(pagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c, formDataRecord.E2E_Contact_Email__c);
        System.assertEquals(Boolean.valueOf(pagesMap.get('CONTACT DETAILS').fields.get('MARKETING DISPATCH').elementItemsMap.get('DEFAULT VALUE').Value__c), formDataRecord.E2E_Send_Marketing_Email__c);
        System.assertEquals(Boolean.valueOf(pagesMap.get('CONTACT DETAILS').fields.get('PERSONAL INFORMATION').elementItemsMap.get('DEFAULT VALUE').Value__c), formDataRecord.E2E_Process_Personal_Data__c);
        System.assertEquals(GlobalUtils.E2ERuSteps.ContactDetails.name(), formDataRecord.E2E_Last_Step__c);

        //***** test to create FormDataRecord step: ContactDetails *****//
        formService.updateFormData(formDataId, pagesMap, formParams, GlobalUtils.E2ERuSteps.ContactDetails.name(), 'PetrolPlus');
        E2EFormData__c formDataRecordFirst = E2EFormRuTestUtils.getFormDataById(formDataId);
        System.assertEquals(pagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c, formDataRecordFirst.E2E_Contact_Phone__c);
        System.assertEquals(pagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c, formDataRecordFirst.E2E_Contact_Email__c);
        System.assertEquals(Boolean.valueOf(pagesMap.get('CONTACT DETAILS').fields.get('MARKETING DISPATCH').elementItemsMap.get('DEFAULT VALUE').Value__c), formDataRecordFirst.E2E_Send_Marketing_Email__c);
        System.assertEquals(Boolean.valueOf(pagesMap.get('CONTACT DETAILS').fields.get('PERSONAL INFORMATION').elementItemsMap.get('DEFAULT VALUE').Value__c), formDataRecordFirst.E2E_Process_Personal_Data__c);
        System.assertEquals(accountId, formDataRecordFirst.E2E_Account_Id__c);
        System.assertEquals(contactId, formDataRecordFirst.E2E_Contact_Id__c);
        System.assertEquals(opportunityId, formDataRecordFirst.E2E_Opportunity_Id__c);

        //***** test to create FormDataRecord step: CompanyInformation *****//
        formService.updateFormData(formDataId, pagesMap, formParams, GlobalUtils.E2ERuSteps.CompanyInformation.name(), 'PetrolPlus');
        E2EFormData__c formDataRecordSecond = E2EFormRuTestUtils.getFormDataById(formDataId);
        System.assertEquals(pagesMap.get('COMPANY INFORMATION').fields.get('ACCOUNT NAME').elementItemsMap.get('DEFAULT VALUE').Value__c, formDataRecordSecond.E2E_Account_Name__c);
        System.assertEquals(pagesMap.get('COMPANY INFORMATION').fields.get('INN').elementItemsMap.get('DEFAULT VALUE').Value__c, formDataRecordSecond.E2E_INN__c);
        // TODO: дописать проверку остальных полей

        //***** test to create FormDataRecord step: CompanyInformation *****//
        formService.updateFormData(formDataId, pagesMap, formParams, GlobalUtils.E2ERuSteps.Order.name(), 'PetrolPlus');
        E2EFormData__c formDataRecordThird = E2EFormRuTestUtils.getFormDataById(formDataId);
        System.assertEquals(pagesMap.get('ORDER').fields.get('PRODUCTS').elementItemsMap.get('ID').Value__c, formDataRecordThird.E2E_Product_Id__c);
        System.assertEquals(pagesMap.get('ORDER').fields.get('PRODUCT TARIFF').elementItemsMap.get('TARIFF ID').Value__c, formDataRecordThird.E2E_Tariff_Id__c);
        System.assertEquals(Integer.valueOf(pagesMap.get('ORDER').fields.get('AMOUNT CARD').elementItemsMap.get('DEFAULT VALUE').Value__c), formDataRecordThird.E2E_Num_Cards__c);
        System.assertEquals(pagesMap.get('ORDER').fields.get('PROMOCODE').elementItemsMap.get('DEFAULT VALUE').Value__c, formDataRecordThird.E2E_Promo_Campaign__c);
        // TODO: дописать проверку остальных полей

        //***** test to create FormDataRecord step: LegalDetails *****//
        formService.updateFormData(formDataId, pagesMap, formParams, GlobalUtils.E2ERuSteps.LegalDetails.name(), 'PetrolPlus');
        E2EFormData__c formDataRecordFourth = E2EFormRuTestUtils.getFormDataById(formDataId);
        System.assertEquals(pagesMap.get('LEGAL DETAILS').fields.get('OKPO').elementItemsMap.get('DEFAULT VALUE').Value__c, formDataRecordFourth.E2E_OKPO__c);
        System.assertEquals(pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c, formDataRecordFourth.E2E_Legal_Address__c);
        System.assertEquals(pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c, formDataRecordFourth.E2E_Post_Address__c);
        System.assertEquals(pagesMap.get('LEGAL DETAILS').fields.get('CODE WORD').elementItemsMap.get('DEFAULT VALUE').Value__c, formDataRecordFourth.E2E_Code_Word__c);
        // TODO: дописать проверку остальных полей

        //***** test to create FormDataRecord step: PaymentDetails *****//
        formService.updateFormData(formDataId, pagesMap, formParams, GlobalUtils.E2ERuSteps.PaymentDetails.name(), 'PetrolPlus');
        E2EFormData__c formDataRecordFifth = E2EFormRuTestUtils.getFormDataById(formDataId);
        System.assertEquals(pagesMap.get('PAYMENT DETAILS').fields.get('CHECKING ACCOUNT').elementItemsMap.get('DEFAULT VALUE').Value__c, formDataRecordFifth.E2E_Checking_Account__c);
        System.assertEquals(pagesMap.get('PAYMENT DETAILS').fields.get('BANK NAME').elementItemsMap.get('DEFAULT VALUE').Value__c, formDataRecordFifth.E2E_Bank__c);
        System.assertEquals(pagesMap.get('PAYMENT DETAILS').fields.get('BIC').elementItemsMap.get('DEFAULT VALUE').Value__c, formDataRecordFifth.E2E_BIC__c);
        // TODO: дописать проверку остальных полей
    }

    //****** Test Deduplication Service

    public static List<Id> initDefaultE2EObjects() {
        List<Id> sobjectIds = new List<Id>();
        // init default e2e objects
        Id e2eAccountId = E2EFormRuTestUtils.insertAccount(E2EFormRuTestUtils.createDefaultAccount()).Id;
        System.assertNotEquals(null, e2eAccountId);
        sobjectIds.add(e2eAccountId);

        Id e2eOpportunityId = E2EFormRuTestUtils.insertOpportunity(E2EFormRuTestUtils.createOpportunity(e2eAccountId)).Id;
        System.assertNotEquals(null, e2eOpportunityId);
        sobjectIds.add(e2eOpportunityId);

        Id e2eContactId = E2EFormRuTestUtils.insertContact(E2EFormRuTestUtils.createContact(e2eAccountId)).Id;
        System.assertNotEquals(null, e2eContactId);
        sobjectIds.add(e2eContactId);

        Id e2eFormDataId = E2EFormRuTestUtils.insertFormData(E2EFormRuTestUtils.createFormData(e2eAccountId, e2eContactId, e2eOpportunityId)).Id;
        System.assertNotEquals(null, e2eFormDataId);
        sobjectIds.add(e2eFormDataId);

        return sobjectIds;
    }

    @isTest // Тест для перехода в E2E, найден Account по INN
    public static void testDeduplicationGoToE2EProcessCase1() {
        User owner = E2EFormRuTestUtils.insertUser(E2EFormRuTestUtils.createUser());

        System.runAs(owner) {
            initCustomSettings();
            List<Id> sobjectIds = initDefaultE2EObjects();
            Id e2eAccountId = sobjectIds.get(0);
            Id e2eOpportunityId = sobjectIds.get(1);
            Id e2eContactId = sobjectIds.get(2);
            Id e2eFormDataId = sobjectIds.get(3);

            // init sf objects
            Account sfAccount = E2EFormRuTestUtils.insertAccount(E2EFormRuTestUtils.createAccount(INN, null, null));
            System.assertNotEquals(null, sfAccount);

            Opportunity sfOpportunityFirst = E2EFormRuTestUtils.insertOpportunity(E2EFormRuTestUtils.createOpportunity(sfAccount.Id, 'Qualified Lead', Date.today().addMonths(-9), owner));
            System.assertNotEquals(null, sfOpportunityFirst);

            Contact e2eContact = E2EFormRuTestUtils.insertContact(E2EFormRuTestUtils.createContact(sfAccount.Id, phone, email));
            System.assertNotEquals(null, e2eContact);

            E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
            E2EFormRuDeduplicationResult result = formService.deduplicationAccountProcess(INN, email, e2eAccountId, e2eContactId, e2eOpportunityId, e2eFormDataId);
            System.assertEquals(GlobalUtils.DeduplicationStatus.E2EProcess.name(), result.statusCode);
        }
    }

    @isTest // Тест для перехода в E2E, найден Account по INN, но ушел по статусам Opportunity
    public static void testDuplicateGoToE2EPrecessCase2() {
        User owner = E2EFormRuTestUtils.insertUser(E2EFormRuTestUtils.createUser());

        System.runAs(owner) {
            initCustomSettings();
            List<Id> sobjectIds = initDefaultE2EObjects();
            Id e2eAccountId = sobjectIds.get(0);
            Id e2eOpportunityId = sobjectIds.get(1);
            Id e2eContactId = sobjectIds.get(2);
            Id e2eFormDataId = sobjectIds.get(3);

            // init sf objects
            Account sfAccount = E2EFormRuTestUtils.insertAccount(E2EFormRuTestUtils.createAccount(INN, null, null));
            System.assertNotEquals(null, sfAccount);

            Opportunity sfOpportunityFirst = E2EFormRuTestUtils.insertOpportunity(E2EFormRuTestUtils.createOpportunity(sfAccount.Id, 'Moved to Start', Date.today().addMonths(-9), owner));
            System.assertNotEquals(null, sfOpportunityFirst);

            Opportunity sfOpportunitySecond = E2EFormRuTestUtils.insertOpportunity(E2EFormRuTestUtils.createOpportunity(sfAccount.Id, 'Отказ', Date.today().addMonths(-9), owner));
            System.assertNotEquals(null, sfOpportunitySecond);

            Contact e2eContact = E2EFormRuTestUtils.insertContact(E2EFormRuTestUtils.createContact(sfAccount.Id, phone, email));
            System.assertNotEquals(null, e2eContact);

            E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
            E2EFormRuDeduplicationResult result = formService.deduplicationAccountProcess(INN, email, e2eAccountId, e2eContactId, e2eOpportunityId, e2eFormDataId);
            System.assertEquals(GlobalUtils.DeduplicationStatus.E2EProcess.name(), result.statusCode);
        }
    }

    @isTest // Тест для перехода в E2EProcess, найден дубль по домену email. Отправлен в E2EProcess по Opportunity
    public static void testDuplicateGoToE2EPrecessCase3() {
        User owner = E2EFormRuTestUtils.insertUser(E2EFormRuTestUtils.createUser());

        System.runAs(owner) {
            initCustomSettings();
            List<Id> sobjectIds = initDefaultE2EObjects();
            Id e2eAccountId = sobjectIds.get(0);
            Id e2eOpportunityId = sobjectIds.get(1);
            Id e2eContactId = sobjectIds.get(2);
            Id e2eFormDataId = sobjectIds.get(3);

            // init sf objects
            Account sfAccount = E2EFormRuTestUtils.insertAccount(E2EFormRuTestUtils.createAccount('222222222', null, null));
            System.assertNotEquals(null, sfAccount);

            Opportunity sfOpportunityFirst = E2EFormRuTestUtils.insertOpportunity(E2EFormRuTestUtils.createOpportunity(sfAccount.Id, 'Moved to Start', Date.today().addMonths(-9), owner));
            System.assertNotEquals(null, sfOpportunityFirst);

            Opportunity sfOpportunitySecond = E2EFormRuTestUtils.insertOpportunity(E2EFormRuTestUtils.createOpportunity(sfAccount.Id, 'Отказ', Date.today().addMonths(-9), owner));
            System.assertNotEquals(null, sfOpportunitySecond);

            Contact e2eContact = E2EFormRuTestUtils.insertContact(E2EFormRuTestUtils.createContact(sfAccount.Id, phone, 'test1@domovoi.ru'));
            System.assertNotEquals(null, e2eContact);

            E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
            E2EFormRuDeduplicationResult result = formService.deduplicationAccountProcess(INN, email, e2eAccountId, e2eContactId, e2eOpportunityId, e2eFormDataId);
            System.assertEquals(GlobalUtils.DeduplicationStatus.E2EProcess.name(), result.statusCode);
        }
    }

    //******* Test: go to Inbound process ******//

    @isTest // Тест для перехода в Inbound, найден Account по INN, но ушел в Inbound по статусам Opportunity
    public static void testDuplicateGoToInboundCase1() {
        User owner = E2EFormRuTestUtils.insertUser(E2EFormRuTestUtils.createUser());

        System.runAs(owner) {
            initCustomSettings();
            List<Id> sobjectIds = initDefaultE2EObjects();
            Id e2eAccountId = sobjectIds.get(0);
            Id e2eOpportunityId = sobjectIds.get(1);
            Id e2eContactId = sobjectIds.get(2);
            Id e2eFormDataId = sobjectIds.get(3);

            // init sf objects
            Account sfAccount = E2EFormRuTestUtils.insertAccount(E2EFormRuTestUtils.createAccount(INN, null, null));
            System.assertNotEquals(null, sfAccount);

            Opportunity sfOpportunityFirst = E2EFormRuTestUtils.insertOpportunity(E2EFormRuTestUtils.createOpportunity(sfAccount.Id, 'Check Credit History', Date.today(), owner));
            System.assertNotEquals(null, sfOpportunityFirst);

            Opportunity sfOpportunitySecond = E2EFormRuTestUtils.insertOpportunity(E2EFormRuTestUtils.createOpportunity(sfAccount.Id, 'Договор на проверке', Date.today(), owner));
            System.assertNotEquals(null, sfOpportunitySecond);

            Contact e2eContact = E2EFormRuTestUtils.insertContact(E2EFormRuTestUtils.createContact(sfAccount.Id, phone, email));
            System.assertNotEquals(null, e2eContact);

            E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
            E2EFormRuDeduplicationResult result = formService.deduplicationAccountProcess(INN, email, e2eAccountId, e2eContactId, e2eOpportunityId, e2eFormDataId);
            System.assertEquals(GlobalUtils.DeduplicationStatus.Inbound.name(), result.statusCode);
        }
    }

    @isTest // Тест для перехода в Inbound, найден Account по Contact, но ушел в Inbound по статусам Opportunity
    public static void testDuplicateGoToInboundCase2() {
        User owner = E2EFormRuTestUtils.insertUser(E2EFormRuTestUtils.createUser());

        System.runAs(owner) {
            initCustomSettings();
            List<Id> sobjectIds = initDefaultE2EObjects();
            Id e2eAccountId = sobjectIds.get(0);
            Id e2eOpportunityId = sobjectIds.get(1);
            Id e2eContactId = sobjectIds.get(2);
            Id e2eFormDataId = sobjectIds.get(3);

            // init sf objects
            Account sfAccount = E2EFormRuTestUtils.insertAccount(E2EFormRuTestUtils.createAccount('3333333333', null, null));
            System.assertNotEquals(null, sfAccount);

            Opportunity sfOpportunityFirst = E2EFormRuTestUtils.insertOpportunity(E2EFormRuTestUtils.createOpportunity(sfAccount.Id, 'Check Credit History', Date.today(), owner));
            System.assertNotEquals(null, sfOpportunityFirst);

            Opportunity sfOpportunitySecond = E2EFormRuTestUtils.insertOpportunity(E2EFormRuTestUtils.createOpportunity(sfAccount.Id, 'Договор на проверке', Date.today(), owner));
            System.assertNotEquals(null, sfOpportunitySecond);

            Contact e2eContact = E2EFormRuTestUtils.insertContact(E2EFormRuTestUtils.createContact(sfAccount.Id, phone, email));
            System.assertNotEquals(null, e2eContact);

            E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
            E2EFormRuDeduplicationResult result = formService.deduplicationAccountProcess(INN, email, e2eAccountId, e2eContactId, e2eOpportunityId, e2eFormDataId);
            System.assertEquals(GlobalUtils.DeduplicationStatus.Inbound.name(), result.statusCode);
        }
    }

    //******* Test: go to KO ******//

    @isTest // Тест для перехода в KO, найден Account по INN, но ушел в KO по Opportunity.StageName == 'Договор на проверке' and Opportunity.CloseDate >= 5
    public static void testDuplicateGoToKOCase1() {
        User owner = E2EFormRuTestUtils.insertUser(E2EFormRuTestUtils.createUser());

        System.runAs(owner) {
            initCustomSettings();
            List<Id> sobjectIds = initDefaultE2EObjects();
            Id e2eAccountId = sobjectIds.get(0);
            Id e2eOpportunityId = sobjectIds.get(1);
            Id e2eContactId = sobjectIds.get(2);
            Id e2eFormDataId = sobjectIds.get(3);

            // init sf objects
            Account sfAccount = E2EFormRuTestUtils.insertAccount(E2EFormRuTestUtils.createAccount(INN, null, null));
            System.assertNotEquals(null, sfAccount);

            Opportunity sfOpportunityFirst = E2EFormRuTestUtils.insertOpportunity(E2EFormRuTestUtils.createOpportunity(sfAccount.Id, 'Moved to Start', Date.today().addMonths(-9), owner));
            System.assertNotEquals(null, sfOpportunityFirst);

            Opportunity sfOpportunitySecond = E2EFormRuTestUtils.insertOpportunity(E2EFormRuTestUtils.createOpportunity(sfAccount.Id, 'Договор на проверке', Date.today().addDays(-2), owner));
            System.assertNotEquals(null, sfOpportunitySecond);

            Contact e2eContact = E2EFormRuTestUtils.insertContact(E2EFormRuTestUtils.createContact(sfAccount.Id, phone, email));
            System.assertNotEquals(null, e2eContact);

            E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
            E2EFormRuDeduplicationResult result = formService.deduplicationAccountProcess(INN, email, e2eAccountId, e2eContactId, e2eOpportunityId, e2eFormDataId);
            System.assertEquals(GlobalUtils.DeduplicationStatus.KO.name(), result.statusCode);
        }
    }

    @isTest // Тест для перехода в KO, найден Account по INN, но ушел в KO по Opportunity.StageName == 'Договор на проверке' and Opportunity.CloseDate >= 5
    public static void testDuplicateGoToKOCase2() {
        User owner = E2EFormRuTestUtils.insertUser(E2EFormRuTestUtils.createUser());

        System.runAs(owner) {
            initCustomSettings();
            List<Id> sobjectIds = initDefaultE2EObjects();
            Id e2eAccountId = sobjectIds.get(0);
            Id e2eOpportunityId = sobjectIds.get(1);
            Id e2eContactId = sobjectIds.get(2);
            Id e2eFormDataId = sobjectIds.get(3);

            // init sf objects
            Account sfAccount = E2EFormRuTestUtils.insertAccount(E2EFormRuTestUtils.createAccount(INN, null, null));
            System.assertNotEquals(null, sfAccount);

            Opportunity sfOpportunityFirst = E2EFormRuTestUtils.insertOpportunity(E2EFormRuTestUtils.createOpportunity(sfAccount.Id, 'Moved to Start', Date.today().addMonths(-9), owner));
            System.assertNotEquals(null, sfOpportunityFirst);

            Opportunity sfOpportunitySecond = E2EFormRuTestUtils.insertOpportunity(E2EFormRuTestUtils.createOpportunity(sfAccount.Id, 'Contract Under Signing', Date.today().addDays(-2), owner));
            System.assertNotEquals(null, sfOpportunitySecond);

            Contact e2eContact = E2EFormRuTestUtils.insertContact(E2EFormRuTestUtils.createContact(sfAccount.Id, phone, email));
            System.assertNotEquals(null, e2eContact);

            E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
            E2EFormRuDeduplicationResult result = formService.deduplicationAccountProcess(INN, email, e2eAccountId, e2eContactId, e2eOpportunityId, e2eFormDataId);
            System.assertEquals(GlobalUtils.DeduplicationStatus.KO.name(), result.statusCode);
        }
    }

    @isTest // Тест переход в Сервис, найден Account по INN
    public static void testDeduplicationGoToServiceCase1() {
        User owner = E2EFormRuTestUtils.insertUser(E2EFormRuTestUtils.createUser());

        System.runAs(owner) {
            initCustomSettings();
            List<Id> sobjectIds = initDefaultE2EObjects();
            Id e2eAccountId = sobjectIds.get(0);
            Id e2eOpportunityId = sobjectIds.get(1);
            Id e2eContactId = sobjectIds.get(2);
            Id e2eFormDataId = sobjectIds.get(3);

            // init sf objects
            Account sfAccount = E2EFormRuTestUtils.insertAccount(E2EFormRuTestUtils.createAccount(INN, null, null));
            System.assertNotEquals(null, sfAccount);

            Opportunity sfOpportunityFirst = E2EFormRuTestUtils.insertOpportunity(E2EFormRuTestUtils.createOpportunity(sfAccount.Id, 'Moved to Start', Date.today(), owner));
            System.assertNotEquals(null, sfOpportunityFirst);

            Opportunity sfOpportunitySecond = E2EFormRuTestUtils.insertOpportunity(E2EFormRuTestUtils.createOpportunity(sfAccount.Id, 'Moved to Start', Date.today(), owner));
            System.assertNotEquals(null, sfOpportunitySecond);

            Contact e2eContact = E2EFormRuTestUtils.insertContact(E2EFormRuTestUtils.createContact(sfAccount.Id, phone, email));
            System.assertNotEquals(null, e2eContact);

            E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
            E2EFormRuDeduplicationResult result = formService.deduplicationAccountProcess(INN, email, e2eAccountId, e2eContactId, e2eOpportunityId, e2eFormDataId);
            System.assertEquals(GlobalUtils.DeduplicationStatus.Service.name(), result.statusCode);
        }
    }

    //******* Test: convert to Service ******//

    @isTest
    public static void testConvertClientToServiceInnDuplicate() {
        User owner = E2EFormRuTestUtils.insertUser(E2EFormRuTestUtils.createUser());

        System.runAs(owner) {
            initCustomSettings();
            List<Id> sobjectIds = initDefaultE2EObjects();
            Id e2eAccountId = sobjectIds.get(0);
            Id e2eOpportunityId = sobjectIds.get(1);
            Id e2eContactId = sobjectIds.get(2);
            Id e2eFormDataId = sobjectIds.get(3);

            E2EFormRuDeduplicationResult deduplicationResult = new E2EFormRuDeduplicationResult();
            deduplicationResult.statusCode = GlobalUtils.DeduplicationStatus.Service.name();
            deduplicationResult.innDuplication = true;

            deduplicationResult.formDataId = e2eFormDataId;
            deduplicationResult.e2eAccount = E2EFormRuTestUtils.getAccountById(e2eAccountId);
            deduplicationResult.e2eContact = E2EFormRuTestUtils.getContactById(e2eContactId);
            deduplicationResult.e2eOpportunity = E2EFormRuTestUtils.getOpportunityById(e2eOpportunityId);

            // init sf objects
            deduplicationResult.sfAccount = E2EFormRuTestUtils.insertAccount(E2EFormRuTestUtils.createAccount(INN, null, null));
            System.assertNotEquals(null, deduplicationResult.sfAccount);

            deduplicationResult.sfOpportunity = E2EFormRuTestUtils.insertOpportunity(E2EFormRuTestUtils.createOpportunity(deduplicationResult.sfAccount.Id, 'Moved to Start', Date.today().addDays(-2), owner));
            System.assertNotEquals(null, deduplicationResult.sfOpportunity);

            Contact e2eContact = E2EFormRuTestUtils.insertContact(E2EFormRuTestUtils.createContact(deduplicationResult.sfAccount.Id, phone, email));
            System.assertNotEquals(null, e2eContact);

            E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();

            Test.startTest();
                formService.transferCustomer(deduplicationResult);
            Test.stopTest();

            Opportunity resultOpportunity = E2EFormRuTestUtils.getOpportunityById(deduplicationResult.e2eOpportunity.Id);
            System.assertEquals('Отказ', resultOpportunity.StageName);
            System.assertEquals('Существующий клиент', resultOpportunity.PPR_Lost_Reasons__c);
            // TODO: Добавить проверку смены владельца
        }
    }

    @isTest
    public static void testConvertClientToService() {
        User owner = E2EFormRuTestUtils.insertUser(E2EFormRuTestUtils.createUser());

        System.runAs(owner) {
            initCustomSettings();
            List<Id> sobjectIds = initDefaultE2EObjects();
            Id e2eAccountId = sobjectIds.get(0);
            Id e2eOpportunityId = sobjectIds.get(1);
            Id e2eContactId = sobjectIds.get(2);
            Id e2eFormDataId = sobjectIds.get(3);

            E2EFormRuDeduplicationResult deduplicationResult = new E2EFormRuDeduplicationResult();
            deduplicationResult.statusCode = GlobalUtils.DeduplicationStatus.Service.name();
            deduplicationResult.innDuplication = false;

            deduplicationResult.formDataId = e2eFormDataId;
            deduplicationResult.e2eAccount = E2EFormRuTestUtils.getAccountById(e2eAccountId);
            deduplicationResult.e2eContact = E2EFormRuTestUtils.getContactById(e2eContactId);
            deduplicationResult.e2eOpportunity = E2EFormRuTestUtils.getOpportunityById(e2eOpportunityId);

            // init sf objects
            deduplicationResult.sfAccount = E2EFormRuTestUtils.insertAccount(E2EFormRuTestUtils.createAccount(INN, null, null));
            System.assertNotEquals(null, deduplicationResult.sfAccount);

            deduplicationResult.sfOpportunity = E2EFormRuTestUtils.insertOpportunity(E2EFormRuTestUtils.createOpportunity(deduplicationResult.sfAccount.Id, 'Moved to Start', Date.today().addDays(-2), owner));
            System.assertNotEquals(null, deduplicationResult.sfOpportunity);

            Contact e2eContact = E2EFormRuTestUtils.insertContact(E2EFormRuTestUtils.createContact(deduplicationResult.sfAccount.Id, phone, email));
            System.assertNotEquals(null, e2eContact);

            deduplicationResult.sfAccount = E2EFormRuTestUtils.getAccountById(deduplicationResult.sfAccount.Id);

            E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();

            Test.startTest();
                formService.transferCustomer(deduplicationResult);
            Test.stopTest();

            Opportunity resultOpportunity = E2EFormRuTestUtils.getOpportunityById(deduplicationResult.e2eOpportunity.Id);
            System.assertEquals('Отказ', resultOpportunity.StageName);
            // TODO: Добавить проверку смены владельца
        }
    }

    //******* Test: convert to Inbound ******//

    @isTest
    public static void testConvertClientToInboundInnDuplicate() {
        User owner = E2EFormRuTestUtils.insertUser(E2EFormRuTestUtils.createUser());

        System.runAs(owner) {
            initCustomSettings();
            List<Id> sobjectIds = initDefaultE2EObjects();
            Id e2eAccountId = sobjectIds.get(0);
            Id e2eOpportunityId = sobjectIds.get(1);
            Id e2eContactId = sobjectIds.get(2);
            Id e2eFormDataId = sobjectIds.get(3);

            E2EFormRuDeduplicationResult deduplicationResult = new E2EFormRuDeduplicationResult();
            deduplicationResult.statusCode = GlobalUtils.DeduplicationStatus.Inbound.name();
            deduplicationResult.innDuplication = true;

            deduplicationResult.formDataId = e2eFormDataId;
            deduplicationResult.e2eAccount = E2EFormRuTestUtils.getAccountById(e2eAccountId);
            deduplicationResult.e2eContact = E2EFormRuTestUtils.getContactById(e2eContactId);
            deduplicationResult.e2eOpportunity = E2EFormRuTestUtils.getOpportunityById(e2eOpportunityId);

            // init sf objects
            deduplicationResult.sfAccount = E2EFormRuTestUtils.insertAccount(E2EFormRuTestUtils.createAccount(INN, null, null));
            System.assertNotEquals(null, deduplicationResult.sfAccount);

            deduplicationResult.sfOpportunity = E2EFormRuTestUtils.insertOpportunity(E2EFormRuTestUtils.createOpportunity(deduplicationResult.sfAccount.Id, 'Contract Under Signing', Date.today().addDays(-2), owner));
            System.assertNotEquals(null, deduplicationResult.sfOpportunity);

            Contact e2eContact = E2EFormRuTestUtils.insertContact(E2EFormRuTestUtils.createContact(deduplicationResult.sfAccount.Id, phone, email));
            System.assertNotEquals(null, e2eContact);

            deduplicationResult.sfAccount = E2EFormRuTestUtils.getAccountById(deduplicationResult.sfAccount.Id);

            E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
            formService.transferCustomer(deduplicationResult);

            System.assertEquals('Qualified Lead', deduplicationResult.e2eOpportunity.StageName);
            // TODO: Добавить проверку смены владельца
        }
    }

    //******* Test: convert to KO ******//

    @isTest
    public static void testConvertClientToKOInnDuplicate() {
        User owner = E2EFormRuTestUtils.insertUser(E2EFormRuTestUtils.createUser());

        System.runAs(owner) {
            initCustomSettings();
            List<Id> sobjectIds = initDefaultE2EObjects();
            Id e2eAccountId = sobjectIds.get(0);
            Id e2eOpportunityId = sobjectIds.get(1);
            Id e2eContactId = sobjectIds.get(2);
            Id e2eFormDataId = sobjectIds.get(3);

            E2EFormRuDeduplicationResult deduplicationResult = new E2EFormRuDeduplicationResult();
            deduplicationResult.statusCode = GlobalUtils.DeduplicationStatus.KO.name();
            deduplicationResult.innDuplication = true;

            deduplicationResult.formDataId = e2eFormDataId;
            deduplicationResult.e2eAccount = E2EFormRuTestUtils.getAccountById(e2eAccountId);
            deduplicationResult.e2eContact = E2EFormRuTestUtils.getContactById(e2eContactId);
            deduplicationResult.e2eOpportunity = E2EFormRuTestUtils.getOpportunityById(e2eOpportunityId);

            // init sf objects

            deduplicationResult.sfAccount = E2EFormRuTestUtils.insertAccount(E2EFormRuTestUtils.createAccount(INN, null, null));
            System.assertNotEquals(null, deduplicationResult.sfAccount);

            deduplicationResult.sfOpportunity = E2EFormRuTestUtils.insertOpportunity(E2EFormRuTestUtils.createOpportunity(deduplicationResult.sfAccount.Id, 'Contract Under Signing', Date.today().addDays(-2), owner));
            System.assertNotEquals(null, deduplicationResult.sfOpportunity);

            Contact e2eContact = E2EFormRuTestUtils.insertContact(E2EFormRuTestUtils.createContact(deduplicationResult.sfAccount.Id, phone, email));
            System.assertNotEquals(null, e2eContact);

            deduplicationResult.sfAccount = E2EFormRuTestUtils.getAccountById(deduplicationResult.sfAccount.Id);

            E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
            Test.startTest();
                formService.transferCustomer(deduplicationResult);
            Test.stopTest();

            Opportunity resultOpportunity = E2EFormRuTestUtils.getOpportunityById(deduplicationResult.e2eOpportunity.Id);
            System.assertEquals('Отказ', resultOpportunity.StageName);
            System.assertEquals('Возврат в Воронку', resultOpportunity.PPR_Lost_Reasons__c);
            // TODO: Добавить проверку смены владельца
        }
    }

    @isTest
    public static void testConvertClientToKO() {
        User owner = E2EFormRuTestUtils.insertUser(E2EFormRuTestUtils.createUser());

        System.runAs(owner) {
            initCustomSettings();
            List<Id> sobjectIds = initDefaultE2EObjects();
            Id e2eAccountId = sobjectIds.get(0);
            Id e2eOpportunityId = sobjectIds.get(1);
            Id e2eContactId = sobjectIds.get(2);
            Id e2eFormDataId = sobjectIds.get(3);

            E2EFormRuDeduplicationResult deduplicationResult = new E2EFormRuDeduplicationResult();
            deduplicationResult.statusCode = GlobalUtils.DeduplicationStatus.KO.name();
            deduplicationResult.innDuplication = false;

            deduplicationResult.formDataId = e2eFormDataId;
            deduplicationResult.e2eAccount =  E2EFormRuTestUtils.getAccountById(e2eAccountId);
            deduplicationResult.e2eContact = E2EFormRuTestUtils.getContactById(e2eContactId);
            deduplicationResult.e2eOpportunity = E2EFormRuTestUtils.getOpportunityById(e2eOpportunityId);

            // init sf objects
            deduplicationResult.sfAccount = E2EFormRuTestUtils.insertAccount(E2EFormRuTestUtils.createAccount(INN, null, null));
            System.assertNotEquals(null, deduplicationResult.sfAccount);

            deduplicationResult.sfOpportunity = E2EFormRuTestUtils.insertOpportunity(E2EFormRuTestUtils.createOpportunity(deduplicationResult.sfAccount.Id, 'Contract Under Signing', Date.today().addDays(-2), owner));
            System.assertNotEquals(null, deduplicationResult.sfOpportunity);

            Contact e2eContact = E2EFormRuTestUtils.insertContact(E2EFormRuTestUtils.createContact(deduplicationResult.sfAccount.Id, phone, email));
            System.assertNotEquals(null, e2eContact);

            deduplicationResult.sfAccount = E2EFormRuTestUtils.getAccountById(deduplicationResult.sfAccount.Id);

            E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
            Test.startTest();
                formService.transferCustomer(deduplicationResult);
            Test.stopTest();

            Opportunity resultOpportunity = E2EFormRuTestUtils.getOpportunityById(e2eOpportunityId);
            System.assertEquals('Отказ', resultOpportunity.StageName);
            System.assertEquals('Возврат в Воронку', resultOpportunity.PPR_Lost_Reasons__c);
            // TODO: Добавить проверку смены владельца
        }
    }

    //******* Test: convert to E2E ******//

    @isTest
    public static void testConvertClientToE2EInnDuplicate() {
        User owner = E2EFormRuTestUtils.insertUser(E2EFormRuTestUtils.createUser());

        System.runAs(owner) {
            initCustomSettings();
            List<Id> sobjectIds = initDefaultE2EObjects();
            Id e2eAccountId = sobjectIds.get(0);
            Id e2eOpportunityId = sobjectIds.get(1);
            Id e2eContactId = sobjectIds.get(2);
            Id e2eFormDataId = sobjectIds.get(3);

            E2EFormRuDeduplicationResult deduplicationResult = new E2EFormRuDeduplicationResult();
            deduplicationResult.statusCode = GlobalUtils.DeduplicationStatus.E2EProcess.name();
            deduplicationResult.innDuplication = true;

            deduplicationResult.formDataId = e2eFormDataId;
            deduplicationResult.e2eAccount = E2EFormRuTestUtils.getAccountById(e2eAccountId);
            deduplicationResult.e2eContact = E2EFormRuTestUtils.getContactById(e2eContactId);
            deduplicationResult.e2eOpportunity = E2EFormRuTestUtils.getOpportunityById(e2eOpportunityId);

            // init sf objects
            deduplicationResult.sfAccount = E2EFormRuTestUtils.insertAccount(E2EFormRuTestUtils.createAccount(INN, null, null));
            System.assertNotEquals(null, deduplicationResult.sfAccount);

            deduplicationResult.sfOpportunity = E2EFormRuTestUtils.insertOpportunity(E2EFormRuTestUtils.createOpportunity(deduplicationResult.sfAccount.Id, 'Contract Under Signing', Date.today().addDays(-2), owner));
            System.assertNotEquals(null, deduplicationResult.sfOpportunity);

            Contact e2eContact = E2EFormRuTestUtils.insertContact(E2EFormRuTestUtils.createContact(deduplicationResult.sfAccount.Id, phone, email));
            System.assertNotEquals(null, e2eContact);

            deduplicationResult.sfAccount = E2EFormRuTestUtils.getAccountById(deduplicationResult.sfAccount.Id);

            Test.startTest();
                E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
                formService.transferCustomer(deduplicationResult);
            Test.stopTest();
            // TODO: Добавить проверку смены владельца
        }
    }

    @isTest
    public static void testConvertClientToE2E() {
        User owner = E2EFormRuTestUtils.insertUser(E2EFormRuTestUtils.createUser());

        System.runAs(owner) {
            initCustomSettings();
            List<Id> sobjectIds = initDefaultE2EObjects();
            Id e2eAccountId = sobjectIds.get(0);
            Id e2eOpportunityId = sobjectIds.get(1);
            Id e2eContactId = sobjectIds.get(2);
            Id e2eFormDataId = sobjectIds.get(3);

            E2EFormRuDeduplicationResult deduplicationResult = new E2EFormRuDeduplicationResult();
            deduplicationResult.statusCode = GlobalUtils.DeduplicationStatus.E2EProcess.name();
            deduplicationResult.innDuplication = false;

            deduplicationResult.formDataId = e2eFormDataId;
            deduplicationResult.e2eAccount = E2EFormRuTestUtils.getAccountById(e2eAccountId);
            deduplicationResult.e2eContact = E2EFormRuTestUtils.getContactById(e2eContactId);
            deduplicationResult.e2eOpportunity = E2EFormRuTestUtils.getOpportunityById(e2eOpportunityId);

            // init sf objects
            deduplicationResult.sfAccount = E2EFormRuTestUtils.insertAccount(E2EFormRuTestUtils.createAccount(INN, null, null));
            System.assertNotEquals(null, deduplicationResult.sfAccount);

            deduplicationResult.sfOpportunity = E2EFormRuTestUtils.insertOpportunity(E2EFormRuTestUtils.createOpportunity(deduplicationResult.sfAccount.Id, 'Contract Under Signing', Date.today().addDays(-2), owner));
            System.assertNotEquals(null, deduplicationResult.sfOpportunity);

            Contact e2eContact = E2EFormRuTestUtils.insertContact(E2EFormRuTestUtils.createContact(deduplicationResult.sfAccount.Id, phone, email));
            System.assertNotEquals(null, e2eContact);

            deduplicationResult.sfAccount = E2EFormRuTestUtils.getAccountById(deduplicationResult.sfAccount.Id);

            E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
            formService.transferCustomer(deduplicationResult);

            // TODO: Добавить проверку смены владельца
        }
    }

    //******* Test: prepare Transit request ******//

    @isTest
    public static void testPrepareTransitRequest() {
        initPagesStructure();
        initCustomSettings();

        E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
        E2EFormParams formParams = new E2EFormParams();
        Map<String, LongFormPage> pagesMap = new Map<String, LongFormPage>();
        formService.collectContent(GlobalUtils.FleetcorCountries.Russia.name(), GlobalUtils.E2ERuSteps.Congratulations.name(), pagesMap, GlobalUtils.DeviceType.Desktop);
        initE2EFormParamsData(formParams);
        initContentMap(pagesMap);

        // init account
        formParams.isSoleProprietor = false;
        Id accountId = E2EFormRuTestUtils.insertAccount(E2EFormRuTestUtils.createAccountWithData(pagesMap, formParams)).Id;
        System.assertNotEquals(null, accountId);

        // create opportunity
        Id opportunityId = E2EFormRuTestUtils.insertOpportunity(E2EFormRuTestUtils.createOpportunity(accountId)).Id;
        System.assertNotEquals(null, opportunityId);

        // create contact
        Id contactId = E2EFormRuTestUtils.insertContact(E2EFormRuTestUtils.createContact(accountId)).Id;
        System.assertNotEquals(null, contactId);

        Id formDataId = E2EFormRuTestUtils.insertFormData(E2EFormRuTestUtils.createFormDataWithData(accountId, contactId, opportunityId, pagesMap, formParams, 'PetrolPlus')).Id;
        System.assertNotEquals(null, formDataId);

        //  Prepare request for Legal Person
        TransitRequestData transitRequestDataLegalPerson = formService.prepareTransitRequestData(formDataId, formParams, pagesMap);
        System.assertEquals(String.format('{0}-{1}', new List<String>{formParams.contractPrefix, formParams.contractCounter}), transitRequestDataLegalPerson.cont.contractNumber);
        System.assertEquals(formParams.normName.substring(0, formParams.normName.lastIndexOf(',')), transitRequestDataLegalPerson.cont.companyName);
        System.assertEquals(formParams.normName.substring(formParams.normName.lastIndexOf(',') + 1).trim(), transitRequestDataLegalPerson.cont.companyType);
        System.assertEquals(formParams.ogrnSpark, transitRequestDataLegalPerson.cont.ogrn);
        System.assertEquals(formParams.kppSpark, transitRequestDataLegalPerson.cont.kpp);

        // TODO: добавить проверку остальных полей
    }

    @isTest
    public static void testPrepareTransitRequestSoleProprietor() {
        initPagesStructure();
        initCustomSettings();

        E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
        E2EFormParams formParams = new E2EFormParams();
        Map<String, LongFormPage> pagesMap = new Map<String, LongFormPage>();
        formService.collectContent(GlobalUtils.FleetcorCountries.Russia.name(), GlobalUtils.E2ERuSteps.Congratulations.name(), pagesMap, GlobalUtils.DeviceType.Desktop);
        initE2EFormParamsData(formParams);
        initContentMap(pagesMap);

        // init account
        formParams.isSoleProprietor = true;
        Id accountId = E2EFormRuTestUtils.insertAccount(E2EFormRuTestUtils.createAccountWithData(pagesMap, formParams)).Id;
        System.assertNotEquals(null, accountId);

        // create opportunity
        Id opportunityId = E2EFormRuTestUtils.insertOpportunity(E2EFormRuTestUtils.createOpportunity(accountId)).Id;
        System.assertNotEquals(null, opportunityId);

        // create contact
        Id contactId = E2EFormRuTestUtils.insertContact(E2EFormRuTestUtils.createContact(accountId)).Id;
        System.assertNotEquals(null, contactId);

        Id formDataId = E2EFormRuTestUtils.insertFormData(E2EFormRuTestUtils.createFormDataWithData(accountId, contactId, opportunityId, pagesMap, formParams, 'PetrolPlus')).Id;
        System.assertNotEquals(null, formDataId);

        // Prepare request for Sole Proprietor

        TransitRequestData transitRequestDataForSoleProprietor = formService.prepareTransitRequestData(formDataId, formParams, pagesMap);
        System.assertEquals(String.format('{0}-{1}', new List<String>{formParams.contractPrefix, formParams.contractCounter}), transitRequestDataForSoleProprietor.cont.contractNumber);
        System.assertEquals(formParams.mainCompanyFullNameSpark.removeStart('ИП '), transitRequestDataForSoleProprietor.cont.companyName);
        System.assertEquals('ИП', transitRequestDataForSoleProprietor.cont.companyType);
        System.assertEquals(formParams.ogrnipSpark, transitRequestDataForSoleProprietor.cont.ogrn);

        // TODO: добавить проверку остальных полей
    }




    @isTest
    public static void testPreparePersonalFio() {
        E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
        TransitRequestData.Personal transitPersonalRequestData = new TransitRequestData.Personal();

        formService.preparePersonalFio(transitPersonalRequestData, 'Иванов Иван Иванович');
        System.assertEquals('Иван', transitPersonalRequestData.name);
        System.assertEquals('Иванов', transitPersonalRequestData.surname);
        System.assertEquals('Иванович', transitPersonalRequestData.parentName);

        formService.preparePersonalFio(transitPersonalRequestData, 'Иванов Иван');
        System.assertEquals('Иван', transitPersonalRequestData.name);
        System.assertEquals('Иванов', transitPersonalRequestData.surname);
        System.assertEquals(' ', transitPersonalRequestData.parentName);

        formService.preparePersonalFio(transitPersonalRequestData, 'Иванов');
        System.assertEquals(' ', transitPersonalRequestData.name);
        System.assertEquals(' ', transitPersonalRequestData.surname);
        System.assertEquals(' ', transitPersonalRequestData.parentName);

        formService.preparePersonalFio(transitPersonalRequestData, null);
        System.assertEquals(' ', transitPersonalRequestData.name);
        System.assertEquals(' ', transitPersonalRequestData.surname);
        System.assertEquals(' ', transitPersonalRequestData.parentName);
    }

    //******* Test: prepare MZK request ******//

    @isTest
    public static void testPrepareMZKRequest() {
        initPagesStructure();
        initCustomSettings();

        E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
        E2EFormParams formParams = new E2EFormParams();
        Map<String, LongFormPage> pagesMap = new Map<String, LongFormPage>();
        formService.collectContent(GlobalUtils.FleetcorCountries.Russia.name(), GlobalUtils.E2ERuSteps.Congratulations.name(), pagesMap, GlobalUtils.DeviceType.Desktop);
        initE2EFormParamsData(formParams);
        initContentMap(pagesMap);

        // init account
        Id accountId = E2EFormRuTestUtils.insertAccount(E2EFormRuTestUtils.createAccountWithData(pagesMap, formParams)).Id;
        System.assertNotEquals(null, accountId);

        // create opportunity
        Id opportunityId = E2EFormRuTestUtils.insertOpportunity(E2EFormRuTestUtils.createOpportunity(accountId)).Id;
        System.assertNotEquals(null, opportunityId);

        // create contact
        Id contactId = E2EFormRuTestUtils.insertContact(E2EFormRuTestUtils.createContact(accountId)).Id;
        System.assertNotEquals(null, contactId);

        Id formDataId = E2EFormRuTestUtils.insertFormData(E2EFormRuTestUtils.createFormDataWithData(accountId, contactId, opportunityId, pagesMap, formParams, 'PetrolPlus')).Id;
        System.assertNotEquals(null, formDataId);

        Test.startTest();
            MZKRequest mzkRequest = formService.prepareMzkRequest(formDataId, formParams);
        Test.stopTest();

        E2E_Form_MZK_Settings__c mzkSettings = E2E_Form_MZK_Settings__c.getValues('E2EFormRu');
        System.assertEquals('e2e', mzkRequest.Cards.cardDescr);
        System.assertEquals(mzkSettings.Service_Groups__c, mzkRequest.Cards.serviceGroups);

        E2E_Ru_Product_Settings__c productSettings = E2E_Ru_Product_Settings__c.getValues(pagesMap.get('ORDER').fields.get('PRODUCTS').elementItemsMap.get('ID').Value__c);
        System.assertEquals(productSettings.Product_Id__c, mzkRequest.Cards.productId);


        // TODO: Добавить проверку остальных полей
    }

    //******* Test: prepare Crm request ******//

    @isTest
    public static void testPrepareCrmRequest() {
        initPagesStructure();
        initCustomSettings();

        E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
        E2EFormParams formParams = new E2EFormParams();
        Map<String, LongFormPage> pagesMap = new Map<String, LongFormPage>();
        formService.collectContent(GlobalUtils.FleetcorCountries.Russia.name(), GlobalUtils.E2ERuSteps.Congratulations.name(), pagesMap, GlobalUtils.DeviceType.Desktop);
        initE2EFormParamsData(formParams);
        initContentMap(pagesMap);

        String transitId = '344444222221111';
        String phone = '23234234234';
        String email = 'test@test.ru';
        String inn = '11111111111';
        CrmTask crmTask = formService.prepareCrmRequest(phone, email, inn, new List<Opportunity>{ new Opportunity(Transit_ID__c = transitId)});
        System.assertEquals(String.format('Тел: {0}; e-mail: {1}; ИНН: {2}; ', new List<String>{phone, email, inn}) + 'CONT_IDS: ' + transitId, crmTask.Description);

    }

    //******* Test: prepare Report request ******//

    @isTest
    public static void testPrepareReportRequest() {
        initPagesStructure();
        initCustomSettings();

        E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
        E2EFormParams formParams = new E2EFormParams();
        Map<String, LongFormPage> pagesMap = new Map<String, LongFormPage>();
        formService.collectContent(GlobalUtils.FleetcorCountries.Russia.name(), GlobalUtils.E2ERuSteps.Congratulations.name(), pagesMap, GlobalUtils.DeviceType.Desktop);
        initE2EFormParamsData(formParams);
        initContentMap(pagesMap);

        // init account
        Account account = E2EFormRuTestUtils.insertAccount(E2EFormRuTestUtils.createAccountWithData(pagesMap, formParams));
        System.assertNotEquals(null, account);

        // create opportunity
        Id opportunityId = E2EFormRuTestUtils.insertOpportunity(E2EFormRuTestUtils.createOpportunity(account.Id)).Id;
        System.assertNotEquals(null, opportunityId);

        // create contact
        Id contactId = E2EFormRuTestUtils.insertContact(E2EFormRuTestUtils.createContact(account.Id)).Id;
        System.assertNotEquals(null, contactId);

        E2EFormData__c formData = E2EFormRuTestUtils.insertFormData(E2EFormRuTestUtils.createFormDataWithData(account.Id, contactId, opportunityId, pagesMap, formParams, 'PetrolPlus'));
        System.assertNotEquals(null, formData);

        Test.startTest();
            ReportRequestData reportRequestData = formService.prepareReportRequestData(formData.Id, formParams, pagesMap, false);
        Test.stopTest();
        System.assertEquals(account.Name.toUpperCase(), reportRequestData.companyName);
        System.assertEquals(formData.E2E_INN__c, reportRequestData.inn);

        // TODO: добавить проверку остальных полей
    }


    @isTest
    public static void testCollectContent() {
        initPagesStructure();

        E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
        Map<String, LongFormPage> pagesMap = new Map<String, LongFormPage>();

        formService.collectContent('Russia', GlobalUtils.E2ERuSteps.ContactDetails.name(), pagesMap, GlobalUtils.DeviceType.Desktop);
        System.assert(pagesMap.containsKey('CONTACT DETAILS'));

        formService.collectContent('Russia', GlobalUtils.E2ERuSteps.CompanyInformation.name(), pagesMap, GlobalUtils.DeviceType.Desktop);
        System.assert(pagesMap.containsKey('COMPANY INFORMATION'));

        formService.collectContent('Russia', GlobalUtils.E2ERuSteps.Order.name(), pagesMap, GlobalUtils.DeviceType.Desktop);
        System.assert(pagesMap.containsKey('ORDER'));

        formService.collectContent('Russia', GlobalUtils.E2ERuSteps.LegalDetails.name(), pagesMap, GlobalUtils.DeviceType.Desktop);
        System.assert(pagesMap.containsKey('LEGAL DETAILS'));

        formService.collectContent('Russia', GlobalUtils.E2ERuSteps.PaymentDetails.name(), pagesMap, GlobalUtils.DeviceType.Desktop);
        System.assert(pagesMap.containsKey('PAYMENT DETAILS'));

        formService.collectContent('Russia', GlobalUtils.E2ERuSteps.Congratulations.name(), pagesMap, GlobalUtils.DeviceType.Desktop);
    }

    @isTest
    public static void testCollectContentByLink() {
        initPagesStructure();
        initCustomSettings();

        E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
        E2EFormParams formParams = new E2EFormParams();
        Map<String, LongFormPage> pagesMap = new Map<String, LongFormPage>();
        formService.collectContent(GlobalUtils.FleetcorCountries.Russia.name(), GlobalUtils.E2ERuSteps.Congratulations.name(), pagesMap, GlobalUtils.DeviceType.Desktop);
        initE2EFormParamsData(formParams);
        initContentMap(pagesMap);

        // init account
        Account account = E2EFormRuTestUtils.insertAccount(E2EFormRuTestUtils.createAccountWithData(pagesMap, formParams));
        System.assertNotEquals(null, account);

        // create opportunity
        Id opportunityId = E2EFormRuTestUtils.insertOpportunity(E2EFormRuTestUtils.createOpportunity(account.Id)).Id;
        System.assertNotEquals(null, opportunityId);

        // create contact
        Id contactId = E2EFormRuTestUtils.insertContact(E2EFormRuTestUtils.createContact(account.Id)).Id;
        System.assertNotEquals(null, contactId);

        Id formDataId = E2EFormRuTestUtils.insertFormData(E2EFormRuTestUtils.createFormDataWithData(account.Id, contactId, opportunityId, pagesMap, formParams, 'PetrolPlus')).Id;
        System.assertNotEquals(null, formDataId);

        Map<String, LongFormTariff> msl_suffix = new Map<String, LongFormTariff>();
        Map<String, String> objectIds = new Map<String, String>();

        formService.collectContentDataByLink(formDataId, GlobalUtils.E2ERuSteps.ContactDetails.name(), pagesMap, formParams, msl_suffix, objectIds);

        formService.collectContentDataByLink(formDataId, GlobalUtils.E2ERuSteps.CompanyInformation.name(), pagesMap, formParams, msl_suffix, objectIds);

        formService.collectContentDataByLink(formDataId, GlobalUtils.E2ERuSteps.Order.name(), pagesMap, formParams, msl_suffix, objectIds);

        formService.collectContentDataByLink(formDataId, GlobalUtils.E2ERuSteps.LegalDetails.name(), pagesMap, formParams, msl_suffix, objectIds);

        formService.collectContentDataByLink(formDataId, GlobalUtils.E2ERuSteps.PaymentDetails.name(), pagesMap, formParams, msl_suffix, objectIds);

    }

    //***** Remote Action *****//

    @isTest
    public static void  testUpdateSoleProprietorInfoFromSpark() {
        initPagesStructure();
        initCustomSettings();

        E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
        E2EFormParams formParams = new E2EFormParams();
        Map<String, LongFormPage> pagesMap = new Map<String, LongFormPage>();
        formService.collectContent(GlobalUtils.FleetcorCountries.Russia.name(), GlobalUtils.E2ERuSteps.Congratulations.name(), pagesMap, GlobalUtils.DeviceType.Desktop);
        initE2EFormParamsData(formParams);
        initContentMap(pagesMap);

        // init account
        Account account = E2EFormRuTestUtils.insertAccount(E2EFormRuTestUtils.createAccountWithData(pagesMap, formParams));
        System.assertNotEquals(null, account);

        // create opportunity
        Id opportunityId = E2EFormRuTestUtils.insertOpportunity(E2EFormRuTestUtils.createOpportunity(account.Id)).Id;
        System.assertNotEquals(null, opportunityId);

        // create contact
        Id contactId = E2EFormRuTestUtils.insertContact(E2EFormRuTestUtils.createContact(account.Id)).Id;
        System.assertNotEquals(null, contactId);

        Id formDataId = E2EFormRuTestUtils.insertFormData(E2EFormRuTestUtils.createFormDataWithData(account.Id, contactId, opportunityId, pagesMap, formParams, 'PetrolPlus')).Id;
        System.assertNotEquals(null, formDataId);

        formService.updateSoleProprietorInfoFromSpark(formParams, formDataId);

        E2EFormData__c formDataRecord = E2EFormRuTestUtils.getFormDataById(formDataId);
        System.assert(formDataRecord.E2E_OGRN__c == formParams.ogrnipSpark);
        System.assert(formDataRecord.E2E_OKPO__c == formParams.okpoSpark);

        // TODO: добавить проверку остальных полей
    }

    @isTest
    public static void  testUpdateCompanyInformationFromSpark() {
        initPagesStructure();
        initCustomSettings();

        E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
        E2EFormParams formParams = new E2EFormParams();
        Map<String, LongFormPage> pagesMap = new Map<String, LongFormPage>();
        formService.collectContent(GlobalUtils.FleetcorCountries.Russia.name(), GlobalUtils.E2ERuSteps.Congratulations.name(), pagesMap, GlobalUtils.DeviceType.Desktop);
        initE2EFormParamsData(formParams);
        initContentMap(pagesMap);

        // init account
        Account account = E2EFormRuTestUtils.insertAccount(E2EFormRuTestUtils.createAccountWithData(pagesMap, formParams));
        System.assertNotEquals(null, account);

        // create opportunity
        Id opportunityId = E2EFormRuTestUtils.insertOpportunity(E2EFormRuTestUtils.createOpportunity(account.Id)).Id;
        System.assertNotEquals(null, opportunityId);

        // create contact
        Id contactId = E2EFormRuTestUtils.insertContact(E2EFormRuTestUtils.createContact(account.Id)).Id;
        System.assertNotEquals(null, contactId);

        Id formDataId = E2EFormRuTestUtils.insertFormData(E2EFormRuTestUtils.createFormDataWithData(account.Id, contactId, opportunityId, pagesMap, formParams, 'PetrolPlus')).Id;
        System.assertNotEquals(null, formDataId);

        formService.updateCompanyInformationFromSpark(formParams, formDataId, opportunityId);

        E2EFormData__c formDataRecord = E2EFormRuTestUtils.getFormDataById(formDataId);
        System.assert(formDataRecord.E2E_Reg_Date__c == formParams.registrationDateSpark);
        System.assert(formDataRecord.E2E_OGRN__c == formParams.ogrnSpark);

        // TODO: добавить проверку остальных полей
    }

    @isTest
    public static void  testUpdateVerifiedDecision() {
        initPagesStructure();
        initCustomSettings();

        E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
        E2EFormParams formParams = new E2EFormParams();
        Map<String, LongFormPage> pagesMap = new Map<String, LongFormPage>();
        formService.collectContent(GlobalUtils.FleetcorCountries.Russia.name(), GlobalUtils.E2ERuSteps.Congratulations.name(), pagesMap, GlobalUtils.DeviceType.Desktop);
        initE2EFormParamsData(formParams);
        initContentMap(pagesMap);

        // init account
        Account account = E2EFormRuTestUtils.insertAccount(E2EFormRuTestUtils.createAccountWithData(pagesMap, formParams));
        System.assertNotEquals(null, account);

        // create opportunity
        Id opportunityId = E2EFormRuTestUtils.insertOpportunity(E2EFormRuTestUtils.createOpportunity(account.Id)).Id;
        System.assertNotEquals(null, opportunityId);

        // create contact
        Id contactId = E2EFormRuTestUtils.insertContact(E2EFormRuTestUtils.createContact(account.Id)).Id;
        System.assertNotEquals(null, contactId);

        Id formDataId = E2EFormRuTestUtils.insertFormData(E2EFormRuTestUtils.createFormDataWithData(account.Id, contactId, opportunityId, pagesMap, formParams, 'PetrolPlus')).Id;
        System.assertNotEquals(null, formDataId);

        formService.updateVerifiedDecision(formParams, formDataId, opportunityId);

        E2EFormData__c formDataRecord = E2EFormRuTestUtils.getFormDataById(formDataId);
        System.assert(formDataRecord.E2E_Black_List_Code__c == formParams.verifiedDecisionCode);

        // TODO: добавить проверку остальных полей
    }


    @isTest
    public static void  testUpdateScoringDecision() {
        initPagesStructure();
        initCustomSettings();

        E2EFormRuServiceImpl formService = new E2EFormRuServiceImpl();
        E2EFormParams formParams = new E2EFormParams();
        Map<String, LongFormPage> pagesMap = new Map<String, LongFormPage>();
        formService.collectContent(GlobalUtils.FleetcorCountries.Russia.name(), GlobalUtils.E2ERuSteps.Congratulations.name(), pagesMap, GlobalUtils.DeviceType.Desktop);
        initE2EFormParamsData(formParams);
        initContentMap(pagesMap);

        // init account
        Account account = E2EFormRuTestUtils.insertAccount(E2EFormRuTestUtils.createAccountWithData(pagesMap, formParams));
        System.assertNotEquals(null, account);

        // create opportunity
        Id opportunityId = E2EFormRuTestUtils.insertOpportunity(E2EFormRuTestUtils.createOpportunity(account.Id)).Id;
        System.assertNotEquals(null, opportunityId);

        // create contact
        Id contactId = E2EFormRuTestUtils.insertContact(E2EFormRuTestUtils.createContact(account.Id)).Id;
        System.assertNotEquals(null, contactId);

        Id formDataId = E2EFormRuTestUtils.insertFormData(E2EFormRuTestUtils.createFormDataWithData(account.Id, contactId, opportunityId, pagesMap, formParams, 'PetrolPlus')).Id;
        System.assertNotEquals(null, formDataId);

        formService.updateScoringDecision(formParams, formDataId, opportunityId);

        E2EFormData__c formDataRecord = E2EFormRuTestUtils.getFormDataById(formDataId);
        System.assert(formDataRecord.E2E_Scoring_Decision_Code__c == formParams.scoringDecisionCode);
        System.assert(formDataRecord.E2E_Scoring_Decision__c == formParams.scoringDecision);

        // TODO: добавить проверку остальных полей
    }

    @IsTest(SeeAllData = true)
    public static void getSummaryMailInfoTestGuestUser() {

        try {
            User guest = ([
                    SELECT Id, Name
                    FROM User
                    WHERE Name = 'E2E RU Site Guest User'
            ]);
            System.runAs(guest) {
                EmailTemplate summaryEmail = [
                        SELECT Id, HTMLValue, Name, Subject
                        FROM EmailTemplate
                        WHERE Name = 'E2E RU Order Confirmation'
                ];
                System.assertNotEquals(null, summaryEmail);
                System.debug('SUBJECT: ' + summaryEmail.Subject);
                System.debug('BODY: ' + summaryEmail.HtmlValue);
            }
        } catch (Exception e) {
            System.debug('EXCEPTION: ' + e.getMessage());
            System.debug('LINE: ' + e.getLineNumber());
        }

    }

    @IsTest(SeeAllData = true)
    public static void getSummaryMailInfoTestAdmin() {

        EmailTemplate summaryEmail = [
                SELECT Id, HTMLValue, Name, Subject
                FROM EmailTemplate
                WHERE Name = 'E2E RU Order Confirmation'
        ];
        System.assertNotEquals(null, summaryEmail);
        System.debug('SUBJECT: ' + summaryEmail.Subject);
        System.debug('BODY: ' + summaryEmail.HtmlValue);

    }
}