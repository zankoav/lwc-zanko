@isTest
public class SparkWebServiceImplTest {

    static String URL = 'http://99.240.174.55/PPRMiddleware';
    static String TOKEN = 'token';

    static String inn = '7743676000';
    static String sparkId = '6329708';
    static String entrepreneurInn = '770605086143';
    static String companyName = 'ОБЩЕСТВО С ОГРАНИЧЕННОЙ ОТВЕТСТВЕННОСТЬЮ "НКТ СОФТВЭР"';

    public static void initCustomSettings() {
        insert new E2E_Form_Ru_General_Settings__c(
                Name = 'E2EFormRu',
                Middleware_Url__c = 'http://99.240.174.55/PPRMiddleware',
                Test_Middleware_Url__c = 'http://99.240.174.55/PPRMiddleware',
                Middleware_Token__c = 'token'
        );
    }

    @isTest
    static void testSparkApi200() {
        initCustomSettings();

        //Test response with status 200
        Test.startTest();

        Map<String, HttpCalloutMock> responses = getMultiResponsesForMock();
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        SparkWebServiceImpl sparkWebService = new SparkWebServiceImpl();

        List<CompanySpark> companies = sparkWebService.getCompanyListByInn(inn);
        System.assertEquals(true, !companies.isEmpty());
        SoleProprietorSpark soleProprietorReport = sparkWebService.getEntrepreneurShortReportByInn(entrepreneurInn);
        System.assertEquals(true, soleProprietorReport.sparkID == 35976716);
        List<FinancialReportSpark> accountReport = sparkWebService.getCompanyAccountingReportBySparkId(inn, sparkId);
        System.assertEquals(true, !accountReport.isEmpty());
        ExtendedReportSpark extendedReport = sparkWebService.getCompanyExtendedReportBySparkId(inn, sparkId);
        System.assertEquals(true, extendedReport.sparkID == 6329708);
        ExtendedReportSpark.Leader leader = sparkWebService.getCompanyActualLeader(extendedReport.LeaderList.leader);
        System.assertEquals(true, leader.fio != '');

        Test.stopTest();
    }

    @isTest
    static void testSparkEmptyResponse() {
        initCustomSettings();

        //Test response with status 200 with empty decision
        Test.startTest();

        Map<String, HttpCalloutMock> responses = getMultiResponsesForMockEmpty();
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        SparkWebServiceImpl sparkWebService = new SparkWebServiceImpl();

        try{
            List<CompanySpark> companies = sparkWebService.getCompanyListByInn(inn);
            System.assertEquals(true, companies.isEmpty());
        } catch (Exception e) {
            System.assert(true, 'Exceptions should be handled by the method');
        }

        try {
            SoleProprietorSpark soleProprietorReport = sparkWebService.getEntrepreneurShortReportByInn(entrepreneurInn);
            System.assertEquals(true, soleProprietorReport.sparkID == null);
        } catch (Exception e) {
            System.assert(true, 'Exceptions should be handled by the method');
        }

        try {
            List<FinancialReportSpark> accountReport = sparkWebService.getCompanyAccountingReportBySparkId(inn, sparkId);
            System.assertEquals(true, accountReport.isEmpty());
        } catch (Exception e) {
            System.assert(true, 'Exceptions should be handled by the method');
        }

        try {
            ExtendedReportSpark extendedReport = sparkWebService.getCompanyExtendedReportBySparkId(inn, sparkId);
            System.assertEquals(true, extendedReport.sparkID == null);
        } catch (Exception e) {
            System.assert(true, 'Exceptions should be handled by the method');
        }

        Test.stopTest();
    }

    @isTest
    static void testSparkApi400() {
        initCustomSettings();

        //Test response with status 400
        Test.startTest();

        Map<String, HttpCalloutMock> responses = getMultiResponsesForMock400();
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        SparkWebServiceImpl sparkWebService = new SparkWebServiceImpl();

        List<CompanySpark> companies = sparkWebService.getCompanyListByInn(inn);
        System.assertEquals(true, companies.isEmpty());
        SoleProprietorSpark soleProprietorReport = sparkWebService.getEntrepreneurShortReportByInn(entrepreneurInn);
        System.assertEquals(true, soleProprietorReport.sparkID == null);
        List<FinancialReportSpark> accountReport = sparkWebService.getCompanyAccountingReportBySparkId(inn, sparkId);
        System.assertEquals(true, accountReport.isEmpty());

        Test.stopTest();
    }

    @isTest
    static void testSparkErrorApi500() {
        initCustomSettings();

        //Test response with status 500 from Spark
        Test.startTest();
        Map<String, HttpCalloutMock> responses = getMultiResponsesForMockError500();
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        SparkWebServiceImpl sparkWebService = new SparkWebServiceImpl();

        try{
            List<CompanySpark> companies = sparkWebService.getCompanyListByInn(inn);
            System.assertEquals(true, companies.isEmpty());
        } catch (Exception e) {
            System.assert(true, 'Exceptions should be handled by the method');
        }

        try {
            SoleProprietorSpark soleProprietorReport = sparkWebService.getEntrepreneurShortReportByInn(entrepreneurInn);
            System.assertEquals(true, soleProprietorReport.sparkID == null);
        } catch (Exception e) {
            System.assert(true, 'Exceptions should be handled by the method');
        }

        try {
            List<FinancialReportSpark> accountReport = sparkWebService.getCompanyAccountingReportBySparkId(inn, sparkId);
            System.assertEquals(true, accountReport.isEmpty());
        } catch (Exception e) {
            System.assert(true, 'Exceptions should be handled by the method');
        }

        try {
            ExtendedReportSpark extendedReport = sparkWebService.getCompanyExtendedReportBySparkId(inn, sparkId);
            System.assertEquals(true, extendedReport.sparkID == null);
        } catch (Exception e) {
            System.assert(true, 'Exceptions should be handled by the method');
        }

        Test.stopTest();
    }

    @isTest
    static void testSparkApi500() {
        initCustomSettings();
        //Test response with status 500
        Test.startTest();
        Map<String, HttpCalloutMock> responses = getMultiResponsesForMock500();
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        SparkWebServiceImpl sparkWebService = new SparkWebServiceImpl();

        try{
            List<CompanySpark> companies = sparkWebService.getCompanyListByInn(inn);
            System.assertEquals(true, companies.isEmpty());
        } catch (Exception e) {
            System.assert(true, 'Exceptions should be handled by the method');
        }

        try{
            SoleProprietorSpark soleProprietorReport = sparkWebService.getEntrepreneurShortReportByInn(entrepreneurInn);
            System.assertEquals(true, soleProprietorReport.sparkID == null);
        } catch (Exception e) {
            System.assert(true, 'Exceptions should be handled by the method');
        }

        try {
            List<FinancialReportSpark> accountReport = sparkWebService.getCompanyAccountingReportBySparkId(inn, sparkId);
            System.assertEquals(true, accountReport.isEmpty());
        } catch (Exception e) {
            System.assert(true, 'Exceptions should be handled by the method');
        }

        try{
            ExtendedReportSpark extendedReport = sparkWebService.getCompanyExtendedReportBySparkId(inn, sparkId);
            System.assertEquals(true, extendedReport.sparkID == null);
        } catch (Exception e) {
            System.assert(true, 'Exceptions should be handled by the method');
        }

        Test.stopTest();
    }

    public static Map<String, HttpCalloutMock> getMultiResponsesForMock() {

        Map<String, String> responseHeaders = new Map<String, String>{
                'Authorization' => TOKEN
        };
        SingleRequestMock getJSONCompanyList = new SingleRequestMock(
                200, 'Complete',
                '{"statusCode":200,"message":"SPARK API",' +
                        '"content":[{"sparkID":6329708,"inn":"7743676000","ogrn":"1087746118162","okpo":"84763430",' +
                        '"fullName":"ОБЩЕСТВО С ОГРАНИЧЕННОЙ ОТВЕТСТВЕННОСТЬЮ \\"НКТ СОФТВЭР\\"",' +
                        '"address":"г. Москва, ул. Хуторская 2-Я, д. 38А стр. 15",' +
                        '"industry":"Торговля розничная компьютерами, периферийными устройствами к ним и программным обеспечением в специализированных магазинах",' +
                        '"regionCode":null,"regionName":"Москва","manager":"Управляющая компания ТД НКТ, ООО",' +
                        '"okopfname":"Общества с ограниченной ответственностью","okopfcode":12300}]}',
                responseHeaders);

        SingleRequestMock getJSONEntrepreneurShortReport = new SingleRequestMock(
                200, 'Complete',
                '{"statusCode":200,"message":"SPARK API",' +
                        '"content":{"sparkID":35976716,"status":{"isActing":true,"text":"Действующее","code":24},' +
                        '"dateReg":"2009-08-25T21:00:00.000+0000","fullNameRus":"Иванов Иван Иванович",' +
                        '"inn":"770605086143","ogrnip":"309774623800678","okpo":"0116896779",' +
                        '"okato":{"code":"45286596000","regionName":"Москва","regionCode":45},' +
                        '"birthDate":"1979-03-12T21:00:00.000+0000","birthPlace":"г. Москва",' +
                        '"okvedlist":{"okved":[{"code":"74.14","name":"Консультирование по вопросам коммерческой деятельности и управления","isMain":true},' +
                        '{"code":"51.16","name":"Деятельность агентов по оптовой торговле текстильными изделиями, одеждой, обувью, изделиями из кожи и меха","isMain":null},' +
                        '{"code":"51.42","name":"Оптовая торговля одеждой, включая нательное белье, и обувью","isMain":null},' +
                        '{"code":"51.47","name":"Оптовая торговля прочими непродовольственными потребительскими товарами","isMain":null},' +
                        '{"code":"52.4","name":"Прочая розничная торговля в специализированных магазинах","isMain":null},' +
                        '{"code":"52.42","name":"Розничная торговля одеждой","isMain":null},' +
                        '{"code":"52.48.39","name":"Специализированная розничная торговля прочими непродовольственными  товарами, не включенными в другие группировки","isMain":null},' +
                        '{"code":"52.61.2","name":"Розничная торговля, осуществляемая непосредственно при помощи телевидения, радио, телефона и Интернет","isMain":null},' +
                        '{"code":"74.40","name":"Рекламная деятельность","isMain":null},' +
                        '{"code":"80.42","name":"Образование для взрослых и прочие виды образования, не включенные в другие группировки","isMain":null}]}}}',
                responseHeaders);

        SingleRequestMock getJSONAccountReport = new SingleRequestMock(
                200, 'Complete',
                '{"statusCode":200,"message":"SPARK API","content":[{"sparkID":6329708,' +
                        '"inn":"7743676000","ogrn":"1087746118162","okpo":"84763430","shortName":"ООО \\"НКТ СОФТВЭР\\"",' +
                        '"period":{"form":[{"value":[{"value":65401,"code":"4110","name":"Поступления - всего","column":3},' +
                        '{"value":59395,"code":"4111","name":"от продажи продукции, товаров, работ и услуг","column":3},' +
                        '{"value":6006,"code":"4119","name":"прочие поступления","column":3},' +
                        '{"value":128394,"code":"4120","name":"Платежи - всего","column":3},' +
                        '{"value":692,"code":"4129","name":"прочие платежи","column":3},' +
                        '{"value":-62993,"code":"4100","name":"Сальдо денежных потоков от текущих операций","column":3},' +
                        '{"value":42585,"code":"4210","name":"Поступления - всего","column":3},' +
                        '{"value":20000,"code":"4310","name":"Поступления - всего","column":3},' +
                        '{"value":20000,"code":"4311","name":"получение кредитов и займов","column":3},' +
                        '{"value":20000,"code":"4300","name":"Сальдо денежных потоков от финансовых операций","column":3},' +
                        '{"value":-408,"code":"4400","name":"Сальдо денежных потоков за отчетный период","column":3},' +
                        '{"value":617,"code":"4490","name":"Величина влияния изменений курса иностранной валюты по отношению к рублю","column":3}],' +
                        '"id":4,"power":1000},{"value":[{"value":500,"code":"3200","name":"Величина капитала на 31 декабря предыдущего года","column":3},' +
                        '{"value":0,"code":"3200","name":"Величина капитала на 31 декабря предыдущего года","column":4},' +
                        '{"value":0,"code":"3200","name":"Величина капитала на 31 декабря предыдущего года","column":5},' +
                        '{"value":500,"code":"3300","name":"Величина капитала на 31 декабря отчетного года","column":3},' +
                        '{"value":0,"code":"3300","name":"Величина капитала на 31 декабря отчетного года","column":4},' +
                        '{"value":0,"code":"3300","name":"Величина капитала на 31 декабря отчетного года","column":5},' +
                        '{"value":30246,"code":"3600","name":"Чистые активы","column":3},' +
                        '{"value":83663,"code":"3600","name":"Чистые активы","column":4}],' +
                        '"id":3,"power":1000},{"value":[{"value":58467,"code":"2110","name":"Выручка","column":3},' +
                        '{"value":70261,"code":"2110","name":"Выручка","column":4},' +
                        '{"value":42,"code":"2120","name":"Себестоимость продаж","column":3},' +
                        '{"value":35,"code":"2120","name":"Себестоимость продаж","column":4},' +
                        '{"value":58425,"code":"2100","name":"Валовая прибыль (убыток)","column":3},' +
                        '{"value":124178,"code":"2220","name":"Управленческие расходы","column":4},' +
                        '{"value":-67977,"code":"2200","name":"Прибыль (убыток) от продаж","column":3},' +
                        '{"value":-53952,"code":"2200","name":"Прибыль (убыток) от продаж","column":4},' +
                        '{"value":-65676,"code":"2300","name":"Прибыль (убыток) до налогообложения","column":3},' +
                        '{"value":12257,"code":"2450","name":"Изменение отложенных налоговых активов","column":3},' +
                        '{"value":9735,"code":"2450","name":"Изменение отложенных налоговых активов","column":4},' +
                        '{"value":-53419,"code":"2400","name":"Чистая прибыль (убыток)","column":3},' +
                        '{"value":-45012,"code":"2400","name":"Чистая прибыль (убыток)","column":4},' +
                        '{"value":-53419,"code":"2500","name":"Совокупный финансовый результат периода","column":3},' +
                        '{"value":-45012,"code":"2500","name":"Совокупный финансовый результат периода","column":4}],' +
                        '"id":2,"power":1000},{"value":[{"value":144,"code":"1110","name":"Нематериальные активы","column":3},' +
                        '{"value":186,"code":"1110","name":"Нематериальные активы","column":4},' +
                        '{"value":30010,"code":"1180","name":"Отложенные налоговые активы","column":3},' +
                        '{"value":17753,"code":"1180","name":"Отложенные налоговые активы","column":4},' +
                        '{"value":8,"code":"1190","name":"Прочие внеоборотные активы","column":3},' +
                        '{"value":30246,"code":"1300","name":"Итого по разделу III","column":3},' +
                        '{"value":83663,"code":"1300","name":"Итого по разделу III","column":4},' +
                        '{"value":33,"code":"1420","name":"Отложенные налоговые обязательства","column":3},' +
                        '{"value":0,"code":"1420","name":"Отложенные налоговые обязательства","column":4},' +
                        '{"value":33,"code":"1400","name":"Итого по разделу IV","column":3},' +
                        '{"value":103041,"code":"1700","name":"БАЛАНС (пассив)","column":4}],' +
                        '"id":1,"power":1000}],"periodName":"2017","dateEnd":"2017-12-30T21:00:00.000+0000","dateBegin":"2016-12-31T21:00:00.000+0000"},' +
                        '"egrpoincluded":"true","egrullikvidation":null}]}',
                responseHeaders);

        SingleRequestMock getJSONExtendedReport = new SingleRequestMock(
                200, 'Complete',
                '{"statusCode":200,"message":"SPARK API",' +
                        '"content":{"sparkID":6329708,"companyType":1,"status":{"date":"2018-07-31T21:00:00.000+0000","type":"Действующее","code":24},' +
                        '"isActing":"true","dateFirstReg":"2008-01-28","shortNameRus":"ООО \\"НКТ СОФТВЭР\\"","shortNameEn":"OOO \\"NKT SOFTVER\\"",' +
                        '"fullNameRus":"ОБЩЕСТВО С ОГРАНИЧЕННОЙ ОТВЕТСТВЕННОСТЬЮ \\"НКТ СОФТВЭР\\"",' +
                        '"normName":"НКТ СОФТВЭР, ООО","inn":"7743676000","kpp":"771301001","ogrn":"1087746118162",' +
                        '"okpo":"84763430","rts":null,"okato":{"code":"45277586000","regionName":"Москва","regionCode":45},' +
                        '"okogu":{"code":"4210011","name":"Хозяйственные общества и товарищества с участием иностранных юридических и (или) физических лиц, а также лиц без гражданства"},' +
                        '"okfs":{"code":"34","name":"Совместная частная и иностранная собственность"},' +
                        '"okopf":{"code":"65","name":"Общества с ограниченной ответственностью","codeNew":"12300"},' +
                        '"charterCapital":"500000","leaderList":{"leader":[{"actualDate":"2012-11-05T21:00:00.000+0000",' +
                        '"fio":"Кремнев Антон Юрьевич","position":"президент","inn":null},{"actualDate":"2009-07-19T21:00:00.000+0000",' +
                        '"fio":"Лаврентьев Леонид Геннадьевич","position":"генеральный директор","inn":null},' +
                        '{"actualDate":"2008-01-27T21:00:00.000+0000","fio":"Еремин Игорь Юрьевич","position":"генеральный директор",' +
                        '"inn":"502408806323"}]},"legalAddresses":{"address":{"postCode":"127287","address":"г. Москва, ул. Хуторская 2-Я, д. 38А стр. 15",' +
                        '"actualDate":"2018-04-27T21:00:00.000+0000","region":"г. Москва","rayon":null,"city":"г. Москва",' +
                        '"streetname":"ул. Хуторская 2-Я","buildingnumber":"дом 38А"}},"adjustAddress":null,' +
                        '"previousAddress":{"address":[{"postCode":"125195","address":"г. Москва, ул. Смольная, д. 20А",' +
                        '"actualDate":"2016-07-21T21:00:00.000+0000"},{"postCode":"127486","address":"г. Москва, ул. Пяловская, д. 7 стр. 3",' +
                        '"actualDate":"2008-08-24T21:00:00.000+0000"},{"postCode":"127486","address":"г. Москва, ул. Дегунинская, д. 10",' +
                        '"actualDate":"2008-01-27T21:00:00.000+0000"}]},"phoneList":{"phone":[{"code":"495","number":7887921,"status":null},' +
                        '{"code":"495","number":7887922,"status":null}]},"faxList":null,"email":null,"www":null,"workersRange":null,' +
                        '"includeInList":{"listName":[{"value":"Компании, отсутствующие по юр. адресу по данным ФНС","id":13,"isNegative":1}]},' +
                        '"creditRisk":null,"failureScore":{"failureScoreValue":"85","failureScoreDesc":"Средний риск"},' +
                        '"paymentIndex":null,"federalTaxRegistration":{"regDate":"2008-01-27T21:00:00.000+0000",' +
                        '"regAuthority":"Межрайонная инспекция ФНС России №46 по г.Москве","regAuthorityAddress":"125373,Москва г,Походный проезд, домовладение 3, стр.2"},' +
                        '"structureInfo":{"countCoownerFCSM":0,"countCoownerRosstat":2,"countCoownerEGRUL":2,"countBranch":0,' +
                        '"countBranchRosstat":0,"countAffiliatedCompanyFCSM":0,"countAffiliatedCompanyRosstat":0,' +
                        '"countAffiliatedCompanyEGRUL":0,"nonprofitOrganizationRosstat":0},"vestnikMessage":null,' +
                        '"bankruptcyMessage":null,"accessibleFinData":{"period":[{"name":"2017","endDate":"2017-12-30T21:00:00.000+0000",' +
                        '"idperiod":547},{"name":"2016","endDate":"2016-12-30T21:00:00.000+0000","idperiod":543},' +
                        '{"name":"2008","endDate":"2008-12-30T21:00:00.000+0000","idperiod":323}]},' +
                        '"finance":{"finPeriod":[{"stringList":{"string":[{"form":"Баланс","section":"Актив","name":"Нематериальные активы",' +
                        '"code":"1110","value":"589000"},{"form":"Баланс","section":"Актив","name":"Основные средства","code":"1150","value":"1064000"},' +
                        '{"form":"Баланс","section":"Пассив","name":"Уставный капитал","code":"1310","value":"500000"},' +
                        '{"form":"Отчет о прибыли и убытках","section":"Операционные доходы и расходы","name":"Чистая прибыль (убыток)","code":"2400","value":"124078000"}]},' +
                        '"periodName":"2016","dateBegin":"2015-12-31T21:00:00.000+0000","dateEnd":"2016-12-30T21:00:00.000+0000"},' +
                        '{"stringList":{"string":[{"form":"Баланс","section":"Актив","name":"Нематериальные активы","code":"1110","value":"144000"},' +
                        '{"form":"Баланс","section":"Пассив","name":"Уставный капитал","code":"1310","value":"500000"},' +
                        '{"form":"Отчет о прибыли и убытках","section":"Доходы и расходы по обычным видам деятельности","name":"Выручка","code":"2110","value":"58467000"}]},' +
                        '"periodName":"2017","dateBegin":"2016-12-31T21:00:00.000+0000","dateEnd":"2017-12-30T21:00:00.000+0000"}]},' +
                        '"companyWithSameInfo":{"telephoneCount":{"value":26,"phoneCode":"495","phoneNumber":"7887922"},' +
                        '"addressCount":12,"managerCountInCountry":0,"managerCountInRegion":0},' +
                        '"indexOfDueDiligence":{"index":"1","indexDesc":"Низкий риск"},"companySize":{"revenue":"58,50","description":"Микропредприятие"},' +
                        '"eventsList":null,"boardOfDirectors":null,"executiveBody":{"member":[{"name":"ТД НКТ, ООО","inn":"7743857461",' +
                        '"birthdayYear":null,"position":{"name":"Внешний исполнительный орган","code":0},"sharePart":null}],' +
                        '"actualDate":"2012-11-05T21:00:00.000+0000"},"personsWithoutWarrant":null,"stateContracts":{"federalLaw94":null,' +
                        '"federalLaw223":{"year":[{"tenders":{"admittedNumber":0,"notAdmittedNumber":0,"winnerNumber":0},' +
                        '"contracts":{"signedNumber":1,"sum":"1980645"},"year":2016},{"tenders":{"admittedNumber":8,"notAdmittedNumber":0,"winnerNumber":8},' +
                        '"contracts":{"signedNumber":2,"sum":"1928417"},"year":2015}]}},' +
                        '"arbitrationCases":{"year":[{"plaintiff":{"casesNumber":0,"sum":"0"},"defendant":{"casesNumber":2,"sum":"42854"},' +
                        '"thirdOrOtherPerson":{"casesNumber":0},"year":"2017"},{"plaintiff":{"casesNumber":0,"sum":"0"},' +
                        '"defendant":{"casesNumber":2,"sum":"1259266"},"thirdOrOtherPerson":{"casesNumber":0},"year":"2014"},' +
                        '{"plaintiff":{"casesNumber":0,"sum":"0"},"defendant":{"casesNumber":1,"sum":"0"},"thirdOrOtherPerson":{"casesNumber":1},' +
                        '"year":"2013"},{"plaintiff":{"casesNumber":0,"sum":"0"},"defendant":{"casesNumber":1,"sum":"0"},' +
                        '"thirdOrOtherPerson":{"casesNumber":0},"year":"2011"}]},"egrullikvidation":null,' +
                        '"okvedlist":{"okved":[{"code":"52.48.13","name":"Розничная торговля компьютерами, программным обеспечением и периферийными устройствами","isMain":true},' +
                        '{"code":"30.02","name":"Производство электронных вычислительных машин и прочего оборудования для обработки информации","isMain":null},' +
                        '{"code":"51.14.2","name":"Деятельность агентов по оптовой торговле прочими видами машин и оборудования","isMain":null},' +
                        '{"code":"51.43.22","name":"Оптовая торговля техническими носителями информации (с записями и без записей)","isMain":null},' +
                        '{"code":"72.2","name":"Разработка программного обеспечения и консультирование в этой области","isMain":null},' +
                        '{"code":"72.3","name":"Обработка данных","isMain":null},' +
                        '{"code":"74.3","name":"Технические испытания, исследования и сертификация","isMain":null}]},"egrpoincluded":"true","fcsmcode":null}}',
                responseHeaders);

        SingleRequestMock getJSONCompanyAccountingReport = new SingleRequestMock(
                200, 'Complete',
                '{"statusCode":200,"message":"SPARK API",' +
                        '"content":[{"sparkID":6329708,"inn":"7743676000","ogrn":"1087746118162","okpo":"84763430","shortName":"ООО \\"НКТ СОФТВЭР\\"",' +
                        '"period":{"form":[{"value":[{"value":65401,"code":"4110","name":"Поступления - всего","column":3},' +
                        '{"value":617,"code":"4490","name":"Величина влияния изменений курса иностранной валюты по отношению к рублю","column":3}],' +
                        '"id":4,"power":1000},{"value":[{"value":500,"code":"3200","name":"Величина капитала на 31 декабря предыдущего года","column":3},' +
                        '{"value":83663,"code":"3600","name":"Чистые активы","column":4}],' +
                        '"id":3,"power":1000},{"value":[{"value":58467,"code":"2110","name":"Выручка","column":3},' +
                        '{"value":-45012,"code":"2500","name":"Совокупный финансовый результат периода","column":4}],' +
                        '"id":2,"power":1000},{"value":[{"value":144,"code":"1110","name":"Нематериальные активы","column":3},' +
                        '{"value":103041,"code":"1700","name":"БАЛАНС (пассив)","column":4}],' +
                        '"id":1,"power":1000}],"periodName":"2017","dateEnd":"2017-12-30T21:00:00.000+0000",' +
                        '"dateBegin":"2016-12-31T21:00:00.000+0000"},"egrpoincluded":"true","egrullikvidation":null}]}',
                responseHeaders);

        Map<String, HttpCalloutMock> responses = new Map<String, HttpCalloutMock>();
        responses.put(URL + '/spark/company-list?inn=' + inn + '&onlyMain=true', getJSONCompanyList);
        responses.put(URL + '/spark/entrepreneur-short-report?inn=' + entrepreneurInn, getJSONEntrepreneurShortReport);
        responses.put(URL + '/spark/company-accounting-report?inn=' + inn +'&sparkId=' + sparkId, getJSONAccountReport);
        responses.put(URL + '/spark/extended-report?inn=' + inn + '&sparkId=' + sparkId, getJSONExtendedReport);
        return responses;
    }

    private static Map<String, HttpCalloutMock> getMultiResponsesForMockEmpty() {

        Map<String, String> responseHeaders = new Map<String, String>{
                'Authorization' => TOKEN
        };

        SingleRequestMock getJSONCompanyList = new SingleRequestMock(
                200, 'Complete',
                '{"statusCode":200,"message":"SPARK API",' +
                        '"content":[]}',
                responseHeaders);

        SingleRequestMock getJSONEntrepreneurShortReport = new SingleRequestMock(
                200, 'Complete',
                '{"statusCode":200,"message":"SPARK API",' +
                        '"content":[]}',
                responseHeaders);

        SingleRequestMock getJSONAccountReport = new SingleRequestMock(
                200, 'Complete',
                '{"statusCode":200,"message":"SPARK API",' +
                        '"content":[]}',
                responseHeaders);

        SingleRequestMock getJSONExtendedReport = new SingleRequestMock(
                200, 'Complete',
                '{"statusCode":200,"message":"SPARK API",' +
                        '"content":[]}',
                responseHeaders);

        SingleRequestMock getJSONCompanyAccountingReport = new SingleRequestMock(
                200, 'Complete',
                '{"statusCode":200,"message":"SPARK API",' +
                        '"content":[]}',
                responseHeaders);

        Map<String, HttpCalloutMock> responses = new Map<String, HttpCalloutMock>();
        responses.put(URL + '/spark/company-list?inn=' + inn + '&onlyMain=true', getJSONCompanyList);
        responses.put(URL + '/spark/entrepreneur-short-report?inn=' + entrepreneurInn, getJSONEntrepreneurShortReport);
        responses.put(URL + '/spark/company-accounting-report?inn=' + inn +'&sparkId=' + sparkId, getJSONAccountReport);
        responses.put(URL + '/spark/extended-report?inn=' + inn + '&sparkId=' + sparkId, getJSONExtendedReport);
        return responses;
    }

    private static Map<String, HttpCalloutMock> getMultiResponsesForMock400(){
        Map<String, String> responseHeaders = new Map<String, String>{
                'Authorization' => TOKEN
        };
        SingleRequestMock getJSONCompanyList400 = new SingleRequestMock(200, 'Complete',
                '{"statusCode":400,"message":"SPARK API",' +
                        '"content":{"code": "400", "msg": "No data found", "field": ""}}',
                responseHeaders);

        SingleRequestMock getJSONEntrepreneurShortReport400 = new SingleRequestMock(200, 'Complete',
                '{"statusCode":400,"message":"SPARK API",' +
                        '"content":{"code": "400", "msg": "No data found", "field": ""}}',
                responseHeaders);

        SingleRequestMock getJSONCompanyAccountingReport400 = new SingleRequestMock(200, 'Complete',
                '{"statusCode":400,"message":"SPARK API",' +
                        '"content":{"code": "400", "msg": "No data found", "field": ""}}',
                responseHeaders);

        Map<String, HttpCalloutMock> responses = new Map<String, HttpCalloutMock>();
        responses.put(URL + '/spark/company-list?inn=' + inn + '&onlyMain=true', getJSONCompanyList400);
        responses.put(URL + '/spark/entrepreneur-short-report?inn=' + entrepreneurInn, getJSONEntrepreneurShortReport400);
        responses.put(URL + '/spark/company-accounting-report?inn=' + inn +'&sparkId=' + sparkId, getJSONCompanyAccountingReport400);
        return responses;
    }

    private static Map<String, HttpCalloutMock> getMultiResponsesForMockError500(){
        Map<String, String> responseHeaders = new Map<String, String>{
                'Authorization' => TOKEN
        };
        SingleRequestMock getJSONCompanyListError500 = new SingleRequestMock(200, 'Complete',
                '{"statusCode":500,"message":"SPARK API",' +
                        '"content":{"code":"500","msg":"Возникла ошибка на сервере! Повторите предыдущие действия заново. ' +
                        'Если ошибка будет повторяться, обратитесь к администратору.","field":""}}',
                responseHeaders);
        SingleRequestMock getJSONEntrepreneurShortReportError500 = new SingleRequestMock(200, 'Complete',
                '{"statusCode":500,"message":"SPARK API",' +
                        '"content":{"code":"500","msg":"Возникла ошибка на сервере! Повторите предыдущие действия заново. ' +
                        'Если ошибка будет повторяться, обратитесь к администратору.","field":""}}',
                responseHeaders);
        SingleRequestMock getJSONAccountReportError500 = new SingleRequestMock(200, 'Complete',
                '{"statusCode":500,"message":"SPARK API",' +
                        '"content":{"code":"500","msg":"Возникла ошибка на сервере! Повторите предыдущие действия заново. ' +
                        'Если ошибка будет повторяться, обратитесь к администратору.","field":""}}',
                responseHeaders);
        SingleRequestMock getJSONExtendedReportError500 = new SingleRequestMock(200, 'Complete',
                '{"statusCode":500,"message":"SPARK API",' +
                        '"content":{"code":"500","msg":"Возникла ошибка на сервере! Повторите предыдущие действия заново. ' +
                        'Если ошибка будет повторяться, обратитесь к администратору.","field":""}}',
                responseHeaders);
        SingleRequestMock getJSONCompanyAccountingReportError500 = new SingleRequestMock(200, 'Complete',
                '{"statusCode":500,"message":"SPARK API",' +
                        '"content":{"code":"500","msg":"Возникла ошибка на сервере! Повторите предыдущие действия заново. ' +
                        'Если ошибка будет повторяться, обратитесь к администратору.","field":""}}',
                responseHeaders);

        Map<String, HttpCalloutMock> responses = new Map<String, HttpCalloutMock>();
        responses.put(URL + '/spark/company-list?inn=' + inn + '&onlyMain=true', getJSONCompanyListError500);
        responses.put(URL + '/spark/entrepreneur-short-report?inn=' + entrepreneurInn, getJSONEntrepreneurShortReportError500);
        responses.put(URL + '/spark/company-accounting-report?inn=' + inn + '&sparkId=' + sparkId, getJSONAccountReportError500);
        responses.put(URL + '/spark/extended-report?inn=' + inn + '&sparkId=' + sparkId, getJSONExtendedReportError500);
        return responses;
    }

    private static Map<String, HttpCalloutMock> getMultiResponsesForMock500() {

        Map<String, String> responseHeaders = new Map<String, String>{
                'Authorization' => TOKEN
        };
        SingleRequestMock getJSONCompanyList500 = new SingleRequestMock(500, 'Failed',
                '{"statusCode":500,"message":"SPARK API",' +
                        '"content":{"code":"500","msg":"Возникла ошибка на сервере! Повторите предыдущие действия заново. ' +
                        'Если ошибка будет повторяться, обратитесь к администратору.","field":""}}',
                responseHeaders);
        SingleRequestMock getJSONEntrepreneurShortReport500 = new SingleRequestMock(500, 'Failed',
                '{"statusCode":500,"message":"SPARK API",' +
                        '"content":{"code":"500","msg":"Возникла ошибка на сервере! Повторите предыдущие действия заново. ' +
                        'Если ошибка будет повторяться, обратитесь к администратору.","field":""}}',
                responseHeaders);
        SingleRequestMock getJSONAccountReport500 = new SingleRequestMock(500, 'Failed',
                '{"statusCode":500,"message":"SPARK API",' +
                        '"content":{"code":"500","msg":"Возникла ошибка на сервере! Повторите предыдущие действия заново. ' +
                        'Если ошибка будет повторяться, обратитесь к администратору.","field":""}}',
                responseHeaders);
        SingleRequestMock getJSONExtendedReport500 = new SingleRequestMock(500, 'Failed',
                '{"statusCode":500,"message":"SPARK API",' +
                        '"content":{"code":"500","msg":"Возникла ошибка на сервере! Повторите предыдущие действия заново. ' +
                        'Если ошибка будет повторяться, обратитесь к администратору.","field":""}}',
                responseHeaders);
        SingleRequestMock getJSONCompanyAccountingReport500 = new SingleRequestMock(500, 'Failed',
                '{"statusCode":500,"message":"SPARK API",' +
                        '"content":{"code":"500","msg":"Возникла ошибка на сервере! Повторите предыдущие действия заново. ' +
                        'Если ошибка будет повторяться, обратитесь к администратору.","field":""}}',
                responseHeaders);

        Map<String, HttpCalloutMock> responses = new Map<String, HttpCalloutMock>();
        responses.put(URL + '/spark/company-list?inn=' + inn + '&onlyMain=true', getJSONCompanyList500);
        responses.put(URL + '/spark/entrepreneur-short-report?inn=' + entrepreneurInn, getJSONEntrepreneurShortReport500);
        responses.put(URL + '/spark/company-accounting-report?inn=' + inn + '&sparkId=' + sparkId, getJSONAccountReport500);
        responses.put(URL + '/spark/extended-report?inn=' + inn + '&sparkId=' + sparkId, getJSONExtendedReport500);
        return responses;
    }
}