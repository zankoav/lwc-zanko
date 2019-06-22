public with sharing class ScoringWebServiceImpl implements ScoringWebService {

    private final static String SCORING_URL = GlobalUtils.getPPRMiddleware(GlobalUtils.PPRMiddleware.url.name());
    private final static String SCORING_TOKEN = GlobalUtils.getPPRMiddleware(GlobalUtils.PPRMiddleware.token.name());

    /*******************************************************************************
    *  Name            : verifyCompany(String inn, String sparkId, Id opportunityId)
    *  Summary         : make company verification with Scoring system
    *  CreatedDate     : 22/08/2018
    *  Parameters      : String inn - company inn, String sparkId - id in Spark system, Id opportunityId - opportunity id in Salesforce
    *  Returns         : DecisionScoring
    ******************************************************************************/
    public CompanyVerificationScoring verifyCompany(String inn, String sparkId, Id opportunityId) {
        CompanyVerificationScoring verificationResponse = new CompanyVerificationScoring();
        String url = SCORING_URL + '/scoring/blacklist-company-verification?from=SF&SFRequestId=' + opportunityId + '&inn=' + inn + '&sparkId=' + sparkId;
        HttpResponse response = sendRequest(url);

        if (response.getStatusCode() == 200) { // Middleware response code
            String responseBody = response.getBody();
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            System.debug('**** SCORING VERIFICATION CONTENT: ' + responseMap.get('content'));
            if (responseMap.get('statusCode') == 200) { // SCORING response code
                if (responseBody.contains('"decision"')) {
                    Object responseContent = (Object) (responseMap.get('content'));
                    verificationResponse = (CompanyVerificationScoring) (JSON.deserialize(JSON.serialize(responseContent), CompanyVerificationScoring.class));
                    System.debug('**** SCORING VERIFICATION: ' + verificationResponse);
                } else {
                    String notificationMessage = '<br/>E2E RU method verifyCompany(): inn=' + inn;
                    String stackTraceString = 'status code: ' + responseMap.get('statusCode') + ', content: ' + responseMap.get('content');
                    ExceptionLogger.sendException(notificationMessage, stackTraceString);
                }
            } else {
                throw new E2EFormRuException('SparkWebServiceImpl verifyCompany(): '
                        + responseMap.get('statusCode') + ' ' + responseMap.get('message') + ' content ' + responseMap.get('content'));
            }
        } else {
            throw new E2EFormRuException('SparkWebServiceImpl verifyCompany(): '
                    + response.getStatusCode() + ' - ' + response.getStatus() + ' response ' + response.getBody());
        }
        return verificationResponse;
    }

    /*******************************************************************************
    *  Name            : getScoringDecision(String inn, String sparkId, Id opportunityId)
    *  Summary         : get scoring decision
    *  CreatedDate     : 22/08/2018
    *  Parameters      : String inn - company inn, String sparkId - id in Spark system, Id opportunityId - opportunity id in Salesforce
    *  Returns         : DecisionScoring
    ******************************************************************************/
    public DecisionScoring getScoringDecision(String inn, String sparkId, Id opportunityId) {
        DecisionScoring scoringDecision = new DecisionScoring();
        String url = SCORING_URL + '/scoring/get-decision?from=SF&SFRequestId=' + opportunityId + '&inn=' + inn + '&sparkId=' + sparkId;
        HttpResponse response = sendRequest(url);

        if (response.getStatusCode() == 200) { // Middleware response code
            String responseBody = response.getBody();
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            System.debug('**** SCORING DECISION CONTENT: ' + responseMap.get('content'));
            if (responseMap.get('statusCode') == 200) { // SCORING response code
                if (responseBody.contains('"decision"')) {
                    Object responseContent = (Object) (responseMap.get('content'));
                    scoringDecision = (DecisionScoring) (JSON.deserialize(JSON.serialize(responseContent), DecisionScoring.class));
                    System.debug('**** SCORING DECISION: ' + scoringDecision);
                } else {
                    String notificationMessage = '<br/>E2E RU method getScoringDecision(): inn=' + inn;
                    String stackTraceString = 'status code: ' + responseMap.get('statusCode') + ', content: ' + responseMap.get('content');
                    ExceptionLogger.sendException(notificationMessage, stackTraceString);
                }
            } else {
                throw new E2EFormRuException('SparkWebServiceImpl getScoringDecision(): '
                        + responseMap.get('statusCode') + ' ' + responseMap.get('message') + ' content ' + responseMap.get('content'));
            }
        } else {
            throw new E2EFormRuException('SparkWebServiceImpl getScoringDecision(): '
                    + response.getStatusCode() + ' - ' + response.getStatus() + ' response ' + response.getBody());
        }
        return scoringDecision;
    }

    public String prepareBlackListDecisionForSF(Integer verificationDecision) {
        String blackListDecisionForSF = 'Согласование с ОУР';
        if (verificationDecision == 0 || verificationDecision == 2) { // if positive decision
            blackListDecisionForSF = 'ОК';
        } else if (verificationDecision == 3) { // if denied
            blackListDecisionForSF = 'Отказ';
        } else if (verificationDecision == 4) { // if need approval
            blackListDecisionForSF = 'Согласование перекупщика';
        }
        return blackListDecisionForSF;
    }

    public String prepareScoringDecisionForSF(Integer scoringDecision) {
        String decisionForSF = 'Отказ';
        if (scoringDecision == 1 || scoringDecision == 3) { // if credit denied
            decisionForSF = 'Предоплата';
        } else if (scoringDecision == 0) { // if positive decision
            decisionForSF = 'Платный овердрафт';
        }
        return decisionForSF;
    }

    private static HttpResponse sendRequest(String url) {
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization', SCORING_TOKEN);
        request.setEndpoint(url);
        request.setMethod('GET');
        request.setTimeout(120000);
        Http http = new Http();
        return http.send(request);
    }
}