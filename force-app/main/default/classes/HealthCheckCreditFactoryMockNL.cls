@isTest
global class HealthCheckCreditFactoryMockNL implements HttpCalloutMock {
  	global HttpResponse respond(HTTPRequest req) {
  		String requestType = '';
  		if (req.getBody().contains('<oper:FindCompanies>')) {
            requestType = 'search'; // by Tax Id or by Name
        } else if (req.getBody().contains('<oper:RetrieveCompanyOnlineReport>')) {
            requestType = 'report';
        } 

	  	Map<String, String> requestBodyMap = new Map<String, String>();
	    requestBodyMap.put('search', '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"><s:Body><FindCompaniesResponse xmlns="http://www.creditsafe.com/globaldata/operations"><FindCompaniesResult xmlns:q1="http://www.creditsafe.com/globaldata/datatypes"><q1:Companies><q1:Company Country="NL" Id="NL007/X/092052510000" Monitoring="true" OnlineReports="true"></q1:Company></q1:Companies></FindCompaniesResult></FindCompaniesResponse></s:Body></s:Envelope>');
	    requestBodyMap.put('report', '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"><s:Body><RetrieveCompanyOnlineReportResponse xmlns="http://www.creditsafe.com/globaldata/operations"><RetrieveCompanyOnlineReportResult xmlns:q1="http://www.creditsafe.com/globaldata/datatypes/reports"><q1:Reports><q1:Report CompanyId="NL007/X/092052510000" Language="EN" OrderNumber="58637472" ReportCurrency="EUR" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="q1:LtdCompanyFullReport"></q1:Report></q1:Reports></RetrieveCompanyOnlineReportResult></RetrieveCompanyOnlineReportResponse></s:Body></s:Envelope>');
	    HttpResponse response = new HttpResponse();
	    response.setStatus('OK');
	    response.setStatusCode(200);
	    response.setBody(requestBodyMap.get(requestType));
	    return response;
  	}
}