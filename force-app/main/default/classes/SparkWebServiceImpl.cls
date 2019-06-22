public with sharing class SparkWebServiceImpl implements SparkWebService {

    private final static String SPARK_URL = GlobalUtils.getPPRMiddleware(GlobalUtils.PPRMiddleware.url.name());
    private final static String SPARK_TOKEN = GlobalUtils.getPPRMiddleware(GlobalUtils.PPRMiddleware.token.name());

    /*******************************************************************************
    *  Name            : getCompanyListByInn(String inn)
    *  Summary         : get main company from SPARK by INN
    *  CreatedDate     : 15/08/2018
    *  Parameters      : String inn - company inn
    *  Returns         : List<CompanySpark>
    ******************************************************************************/
    public List<CompanySpark> getCompanyListByInn(String inn) {
        List<CompanySpark> companies = new List<CompanySpark>();
        String url = SPARK_URL + '/spark/company-list?inn=' + inn + '&onlyMain=true';
        HttpResponse response = sendRequest(url);

        if (response.getStatusCode() == 200) { // Middleware response code
            String responseBody = response.getBody();
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            System.debug('**** SPARK RESPONSE CONTENT: ' + responseMap.get('content'));
            if (responseMap.get('statusCode') == 200) { // SPARK response code
                if (responseBody.contains('"sparkID"')) {
                    List<Object> responseContent = (List<Object>) (responseMap.get('content'));
                    for (Object entry : responseContent) {
                        companies.add((CompanySpark) (JSON.deserialize(JSON.serialize(entry), CompanySpark.class)));
                    }
                    System.debug('**** SPARK COMPANY: ' + companies);
                } else {
                    String notificationMessage = '<br/>E2E RU method getCompanyListByInn() - Error 1 : inn=' + inn;
                    String stackTraceString = 'response code: ' + responseMap.get('statusCode') + ', content: ' + responseMap.get('content');
                    ExceptionLogger.sendException(notificationMessage, stackTraceString);
                }
            } else if(responseMap.get('statusCode') == 400){
                String notificationMessage = '<br/>E2E RU method getCompanyListByInn() - Error 2: inn=' + inn;
                String stackTraceString = 'Spark No data found';
                ExceptionLogger.sendException(notificationMessage, stackTraceString);
            } else {
                throw new E2EFormRuException('SparkWebServiceImpl getCompanyListByInn() - Error 3: '
                        + responseMap.get('statusCode') + ' ' + responseMap.get('message')
                        + ' content ' + responseMap.get('content'));
            }
        } else {
            throw new E2EFormRuException('SparkWebServiceImpl getCompanyListByInn() - Error 4: '
                    + response.getStatusCode() + ' - ' + response.getStatus() + ' response ' + response.getBody());
        }
        return companies;
    }

    /*******************************************************************************
    *  Name            : getEntrepreneurShortReportByInn(String inn)
    *  Summary         : get sole proprietor report from SPARK by INN
    *  CreatedDate     : 06/08/2018
    *  Parameters      : String inn - company inn
    *  Returns         : SoleProprietorSpark
    ******************************************************************************/
    public SoleProprietorSpark getEntrepreneurShortReportByInn(String inn) {
        SoleProprietorSpark soleProprietorInfo = new SoleProprietorSpark();
        String url = SPARK_URL + '/spark/entrepreneur-short-report?inn=' + inn;
        System.debug('URL: ' + url);

        HttpResponse response = sendRequest(url);
        System.debug('RESPONSE: ' + response);

        if (response.getStatusCode() == 200) { // Middleware response code
            String responseBody = response.getBody();
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            System.debug('**** SPARK ENTREPRENEUR REPORT CONTENT: ' + responseMap.get('content'));
            if (responseMap.get('statusCode') == 200) { // SPARK response code
                if (responseBody.contains('"sparkID"')) {
                    Object responseContent = (Object) (responseMap.get('content'));
                    soleProprietorInfo = (SoleProprietorSpark) (JSON.deserialize(JSON.serialize(responseContent), SoleProprietorSpark.class));
                    System.debug('**** SPARK ENTREPRENEUR REPORT: ' + soleProprietorInfo);
                } else {
                    String notificationMessage = '<br/>E2E RU method getEntrepreneurShortReportByInn() - Error 1: inn=' + inn;
                    String stackTraceString = 'status code: ' + responseMap.get('statusCode') + ', content: ' + responseMap.get('content');
                    ExceptionLogger.sendException(notificationMessage, stackTraceString);
                }
            } else if(responseMap.get('statusCode') == 400){
                String notificationMessage = '<br/>E2E RU method getEntrepreneurShortReportByInn() - Error 2: inn=' + inn;
                String stackTraceString = 'Spark No data found';
                ExceptionLogger.sendException(notificationMessage, stackTraceString);
            } else {
                throw new E2EFormRuException('SparkWebServiceImpl getEntrepreneurShortReportByInn() - Error 3: '
                        + responseMap.get('statusCode') + ' ' + responseMap.get('message')
                        + 'content ' + responseMap.get('content'));
            }
        } else {
            throw new E2EFormRuException('SparkWebServiceImpl getEntrepreneurShortReportByInn() - Error 3: '
                    + response.getStatusCode() + ' - ' + response.getStatus() + ' response ' + response.getBody());
        }
        return soleProprietorInfo;
    }

    /*******************************************************************************
    *  Name            : getCompanyAccountingReport(String inn, String sparkId)
    *  Summary         : get companies' accounting reports from SPARK by SPARK id
    *  CreatedDate     : 15/08/2018
    *  Parameters      : String sparkId - id in SPARK system
    *  Returns         : List<FinancialReportSpark>
    ******************************************************************************/
    public List<FinancialReportSpark> getCompanyAccountingReportBySparkId(String inn, String sparkId) {
        List<FinancialReportSpark> financialReport = new List<FinancialReportSpark>();
        String url = SPARK_URL + '/spark/company-accounting-report?inn=' + inn + '&sparkId=' + sparkId;
        HttpResponse response = sendRequest(url);

        if (response.getStatusCode() == 200) { // Middleware response code
            String responseBody = response.getBody();
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            System.debug('**** SPARK FINANCIAL REPORT CONTENT: ' + responseMap.get('content'));
            if (responseMap.get('statusCode') == 200) { // SPARK response code
                if (responseBody.contains('"sparkID"')) {
                    List<Object> responseContent = (List<Object>) (responseMap.get('content'));
                    for (Object entry : responseContent) {
                        financialReport.add((FinancialReportSpark) (JSON.deserialize(JSON.serialize(entry), FinancialReportSpark.class)));
                    }
                    System.debug('**** SPARK FINANCIAL REPORT: ' + financialReport);
                } else {
                    String notificationMessage = '<br/>E2E RU method getCompanyAccountingReportBySparkId() - Error 1: inn=' + inn;
                    String stackTraceString = 'status code: ' + responseMap.get('statusCode') + ', content: ' + responseMap.get('content');
                    ExceptionLogger.sendException(notificationMessage, stackTraceString);
                }
            } else if(responseMap.get('statusCode') == 400){
                String notificationMessage = '<br/>E2E RU method getCompanyAccountingReportBySparkId() - Error 2: inn=' + inn;
                String stackTraceString = 'Spark No data found';
                ExceptionLogger.sendException(notificationMessage, stackTraceString);
            } else {
                throw new E2EFormRuException('SparkWebServiceImpl getCompanyAccountingReportBySparkId() - Error 3: '
                        + responseMap.get('statusCode') + ' ' + responseMap.get('message')
                        + ' content ' + responseMap.get('content'));
            }
        } else {
            throw new E2EFormRuException('SparkWebServiceImpl getCompanyAccountingReportBySparkId() - Error 4: '
                    + response.getStatusCode() + ' - ' + response.getStatus() + ' response ' + response.getBody());
        }
        return financialReport;
    }

    /*******************************************************************************
    *  Name            : getCompanyExtendedReportBySparkId(String inn, String sparkId)
    *  Summary         : get company's extended report from SPARK by SPARK id
    *  CreatedDate     : 15/08/2018
    *  Parameters      : String sparkId - id in SPARK system
    *  Returns         : ExtendedReportSpark
    ******************************************************************************/
    public ExtendedReportSpark getCompanyExtendedReportBySparkId(String inn, String sparkId) {
        ExtendedReportSpark extendedReport = new ExtendedReportSpark();
        String url = SPARK_URL + '/spark/extended-report?inn=' + inn + '&sparkId=' + sparkId;
        HttpResponse response = sendRequest(url);

        if (response.getStatusCode() == 200) { // Middleware response code
            String responseBody = response.getBody();
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            System.debug('**** SPARK EXTENDED REPORT CONTENT: ' + responseMap.get('content'));
            if (responseMap.get('statusCode') == 200) { // SPARK response code
                if (responseBody.contains('"sparkID"')) {
                    Object responseContent = (Object) (responseMap.get('content'));
                    extendedReport = (ExtendedReportSpark) (JSON.deserialize(JSON.serialize(responseContent), ExtendedReportSpark.class));
                    System.debug('**** SPARK EXTENDED REPORT: ' + extendedReport);
                } else {
                    String notificationMessage = '<br/>E2E RU method getCompanyExtendedReportBySparkId() - Error 1: inn=' + inn;
                    String stackTraceString = 'status code: ' + responseMap.get('statusCode') + ', content: ' + responseMap.get('content');
                    ExceptionLogger.sendException(notificationMessage, stackTraceString);
                }
            } else {
                throw new E2EFormRuException('SparkWebServiceImpl getCompanyExtendedReportBySparkId() - Error 2: '
                        + responseMap.get('statusCode') + ' ' + responseMap.get('message')
                        + ' content ' + responseMap.get('content'));
            }
        } else {
            throw new E2EFormRuException('SparkWebServiceImpl getCompanyExtendedReportBySparkId() - Error 3: '
                    + response.getStatusCode() + ' - ' + response.getStatus() + ' response ' + response.getBody());
        }
        return extendedReport;
    }

    /*******************************************************************************
    *  Name            : getCompanyActualLeader(ExtendedReportSpark.LeaderList leaders)
    *  Summary         : get company actual leader from SPARK list
    *  CreatedDate     : 21/08/2018
    *  ModifiedDate    : -
    *  Parameters      : ExtendedReportSpark.LeaderList leaders
    *  Returns         : ExtendedReportSpark.Leader
    ******************************************************************************/
    public ExtendedReportSpark.Leader getCompanyActualLeader(List<ExtendedReportSpark.Leader> leaders) {
        // Get dates list
        List<Date> allDates = new List<Date>();
        for (ExtendedReportSpark.Leader leader : leaders) {
            allDates.add(Date.valueOf(leader.actualDate));
        }
        allDates.sort();

        // Get actual leader
        Date actualDate = allDates[allDates.size() - 1];
        ExtendedReportSpark.Leader actualLeader = new ExtendedReportSpark.Leader();
        for (ExtendedReportSpark.Leader leader : leaders) {
            if (Date.valueOf(leader.actualDate) == actualDate) {
                actualLeader = leader;
            }
        }
        System.debug('**** SPARK COMPANY LEADER: ' + actualLeader);
        return actualLeader;
    }

    @TestVisible
    private static HttpResponse sendRequest(String url) {
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization', SPARK_TOKEN);
        request.setEndpoint(url);
        request.setMethod('GET');
        request.setTimeout(120000);
        Http http = new Http();
        return http.send(request);
    }
}