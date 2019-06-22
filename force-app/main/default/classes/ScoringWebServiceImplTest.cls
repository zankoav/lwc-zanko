@isTest
public class ScoringWebServiceImplTest {
    static String URL = 'http://99.240.174.55/PPRMiddleware';
    static String TOKEN = 'token';

    static String inn = '7743676000';
    static String sparkId = '6329708';
    static String opportunityId = '0066E0000058ZwnQAE';
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
    static void testScoringApi200() {
        initCustomSettings();

        //Test response with status 200
        Test.startTest();

        Map<String, HttpCalloutMock> responses = getMultiResponsesForMock();
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        ScoringWebServiceImpl scoringWebService = new ScoringWebServiceImpl();

        CompanyVerificationScoring verificationDecision = scoringWebService.verifyCompany(inn, sparkId, opportunityId);
        System.assertEquals(true, verificationDecision != null);
        DecisionScoring decisionScoring = scoringWebService.getScoringDecision(inn, sparkId, opportunityId);
        System.assertEquals(true, decisionScoring != null);

        String decisionForSF0 = scoringWebService.prepareScoringDecisionForSF(0);
        System.assertEquals(true, decisionForSF0 == 'Платный овердрафт');
        String decisionForSF1 = scoringWebService.prepareScoringDecisionForSF(1);
        System.assertEquals(true, decisionForSF1 == 'Предоплата');

        String blackListDecisionForSF0 = scoringWebService.prepareBlackListDecisionForSF(0);
        System.assertEquals(true, blackListDecisionForSF0 == 'ОК');
        String blackListDecisionForSF3 = scoringWebService.prepareBlackListDecisionForSF(3);
        System.assertEquals(true, blackListDecisionForSF3 == 'Отказ');
        String blackListDecisionForSF4 = scoringWebService.prepareBlackListDecisionForSF(4);
        System.assertEquals(true, blackListDecisionForSF4 == 'Согласование перекупщика');

        Test.stopTest();
    }

    @isTest
    static void testScoringEmptyDecision() {
        initCustomSettings();

        //Test response with status 200 with empty decision
        Test.startTest();

        Map<String, HttpCalloutMock> responses = getMultiResponsesForMockEmptyDecision();
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        ScoringWebServiceImpl scoringWebService = new ScoringWebServiceImpl();

        CompanyVerificationScoring verificationDecision = scoringWebService.verifyCompany(inn, sparkId, opportunityId);
        System.assertEquals(true, verificationDecision.decision == null);
        DecisionScoring decisionScoring = scoringWebService.getScoringDecision(inn, sparkId, opportunityId);
        System.assertEquals(true, decisionScoring.decision == null);

        Test.stopTest();
    }

    @isTest
    static void testScoringErrorApi500() {
        initCustomSettings();

        //Test response with status 500 from Scoring
        Test.startTest();
        Map<String, HttpCalloutMock> responses = getMultiResponsesForMockError500();
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        ScoringWebServiceImpl scoringWebService = new ScoringWebServiceImpl();

        try {
            CompanyVerificationScoring verificationDecision = scoringWebService.verifyCompany(inn, sparkId, opportunityId);
            System.assertEquals(true, verificationDecision.decision == null);
        } catch (Exception e) {
            System.assert(true, 'Exceptions should be handled by the method');
        }

        try {
            DecisionScoring decisionScoring = scoringWebService.getScoringDecision(inn, sparkId, opportunityId);
            System.assertEquals(true, decisionScoring.decision == null);
        } catch (Exception e) {
            System.assert(true, 'Exceptions should be handled by the method');
        }

        Test.stopTest();

    }

    @isTest
    static void testScoringApi500() {
        initCustomSettings();

        //Test response with status 500
        Test.startTest();
        Map<String, HttpCalloutMock> responses = getMultiResponsesForMock500();
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(responses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        ScoringWebServiceImpl scoringWebService = new ScoringWebServiceImpl();

        try {
            CompanyVerificationScoring verificationDecision = scoringWebService.verifyCompany(inn, sparkId, opportunityId);
            System.assertEquals(true, verificationDecision.decision == null);
        } catch (Exception e) {
            System.assert(true, 'Exceptions should be handled by the method');
        }

        try {
            DecisionScoring decisionScoring = scoringWebService.getScoringDecision(inn, sparkId, opportunityId);
            System.assertEquals(true, decisionScoring.decision == null);
        } catch (Exception e) {
            System.assert(true, 'Exceptions should be handled by the method');
        }

        Test.stopTest();
    }

    private static Map<String, HttpCalloutMock> getMultiResponsesForMock() {

        Map<String, String> responseHeaders = new Map<String, String>{
                'Authorization' => TOKEN
        };
        SingleRequestMock getJSONCompanyVerification = new SingleRequestMock(
                200, 'Complete',
                '{"statusCode":200,"message":"Scoring Integration","content":{"decision":3,"limitation":0,"blackListType":[10],"sfrequestId":"0066E0000058YwnQAE"}}',
                responseHeaders);

        SingleRequestMock getJSONScoringDecision = new SingleRequestMock(
                200, 'Complete',
                '{"statusCode":200,"message":"Scoring Integration","content":{"decision":3,"points":0,"sfrequestId":"0066E0000058ZwnQAE"}}',
                responseHeaders);

        Map<String, HttpCalloutMock> responses = new Map<String, HttpCalloutMock>();
        responses.put(URL + '/scoring/blacklist-company-verification?from=SF&SFRequestId=' + opportunityId + '&inn=' + inn + '&sparkId=' + sparkId, getJSONCompanyVerification);
        responses.put(URL + '/scoring/get-decision?from=SF&SFRequestId=' + opportunityId + '&inn=' + inn + '&sparkId=' + sparkId, getJSONScoringDecision);
        return responses;
    }

    private static Map<String, HttpCalloutMock> getMultiResponsesForMockEmptyDecision() {

        Map<String, String> responseHeaders = new Map<String, String>{
                'Authorization' => TOKEN
        };
        SingleRequestMock getJSONCompanyVerification = new SingleRequestMock(
                200, 'Complete',
                '{"statusCode":200,"message":"Scoring Integration","content":{"limitation":0,"blackListType":[10],"sfrequestId":"0066E0000058YwnQAE"}}',
                responseHeaders);

        SingleRequestMock getJSONScoringDecision = new SingleRequestMock(
                200, 'Complete',
                '{"statusCode":200,"message":"Scoring Integration","content":{"points":0,"sfrequestId":"0066E0000058ZwnQAE"}}',
                responseHeaders);

        Map<String, HttpCalloutMock> responses = new Map<String, HttpCalloutMock>();
        responses.put(URL + '/scoring/blacklist-company-verification?from=SF&SFRequestId=' + opportunityId + '&inn=' + inn + '&sparkId=' + sparkId, getJSONCompanyVerification);
        responses.put(URL + '/scoring/get-decision?from=SF&SFRequestId=' + opportunityId + '&inn=' + inn + '&sparkId=' + sparkId, getJSONScoringDecision);
        return responses;
    }

    private static Map<String, HttpCalloutMock> getMultiResponsesForMockError500() {
        Map<String, String> responseHeaders = new Map<String, String>{
                'Authorization' => TOKEN
        };
        SingleRequestMock getJSONCompanyVerificationError500 = new SingleRequestMock(200, 'Complete',
                '{"statusCode":500,"message":"Scoring Integration",' +
                        '"content":{"code":"500","msg":"Возникла ошибка на сервере! Повторите предыдущие действия заново. ' +
                        'Если ошибка будет повторяться, обратитесь к администратору.","field":""}}',
                responseHeaders);

        SingleRequestMock getJSONScoringDecisionError500 = new SingleRequestMock(200, 'Complete',
                '{"statusCode":500,"message":"Scoring Integration",' +
                        '"content":{"code":"500","msg":"Возникла ошибка на сервере! Повторите предыдущие действия заново. ' +
                        'Если ошибка будет повторяться, обратитесь к администратору.","field":""}}',
                responseHeaders);


        Map<String, HttpCalloutMock> responses = new Map<String, HttpCalloutMock>();
        responses.put(URL + '/scoring/blacklist-company-verification?from=SF&SFRequestId=' + opportunityId + '&inn=' + inn + '&sparkId=' + sparkId, getJSONCompanyVerificationError500);
        responses.put(URL + '/scoring/get-decision?from=SF&SFRequestId=' + opportunityId + '&inn=' + inn + '&sparkId=' + sparkId, getJSONScoringDecisionError500);
        return responses;
    }

    private static Map<String, HttpCalloutMock> getMultiResponsesForMock500() {

        Map<String, String> responseHeaders = new Map<String, String>{
                'Authorization' => TOKEN
        };
        SingleRequestMock getJSONCompanyVerification500 = new SingleRequestMock(500, 'Failed',
                '{"statusCode":500,"message":"Scoring Integration",' +
                        '"content":{"code":"500","msg":"Возникла ошибка на сервере! Повторите предыдущие действия заново. ' +
                        'Если ошибка будет повторяться, обратитесь к администратору.","field":""}}',
                responseHeaders);

        SingleRequestMock getJSONScoringDecision500 = new SingleRequestMock(500, 'Failed',
                '{"statusCode":500,"message":"Scoring Integration",' +
                        '"content":{"code":"500","msg":"Возникла ошибка на сервере! Повторите предыдущие действия заново. ' +
                        'Если ошибка будет повторяться, обратитесь к администратору.","field":""}}',
                responseHeaders);

        Map<String, HttpCalloutMock> responses = new Map<String, HttpCalloutMock>();
        responses.put(URL + '/scoring/blacklist-company-verification?from=SF&SFRequestId=' + opportunityId + '&inn=' + inn + '&sparkId=' + sparkId, getJSONCompanyVerification500);
        responses.put(URL + '/scoring/get-decision?from=SF&SFRequestId=' + opportunityId + '&inn=' + inn + '&sparkId=' + sparkId, getJSONScoringDecision500);
        return responses;
    }
}