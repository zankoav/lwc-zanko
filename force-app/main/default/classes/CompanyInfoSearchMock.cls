global class CompanyInfoSearchMock implements HttpCalloutMock {
    global HttpResponse respond(HTTPRequest request) {
  		String creditSystemName = '';
  		if (request.getEndpoint() == 'https://webservices.creditsafe.com/GlobalData/1.3/MainServiceBasic.svc') {
  			creditSystemName = 'Creditsafe';
  		} else if (request.getEndpoint() == 'https://ws1.webservices.nl:443/soap_doclit.php') {
            creditSystemName = 'CompanyInfo';
        } 

	  	Map<String, String> requestBodyMap = new Map<String, String>();
	  		requestBodyMap.put('Creditsafe', '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"><s:Body><FindCompaniesResponse xmlns="http://www.creditsafe.com/globaldata/operations"><FindCompaniesResult xmlns:q1="http://www.creditsafe.com/globaldata/datatypes"><q1:Companies></q1:Companies></FindCompaniesResult></FindCompaniesResponse></s:Body></s:Envelope>');
	    	requestBodyMap.put('CompanyInfo', '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><SOAP-ENV:Body><dutchBusinessSearchResponse xmlns="http://www.webservices.nl/soap/"><out><paging><curpage>1</curpage><perpage>20</perpage><numpages>1</numpages><numresults>1</numresults><maxresults>500</maxresults></paging><results><item><dossier_number>64184382</dossier_number><establishment_number>000033032157</establishment_number><trade_name>Ucar Bouw</trade_name><match_type>undetermined</match_type><establishment_city>\'S-HERTOGENBOSCH</establishment_city><establishment_street>Aert van Nesstraat</establishment_street><correspondence_city>\'S-HERTOGENBOSCH</correspondence_city><correspondence_street>Aert van Nesstraat</correspondence_street><indication_main_establishment>true</indication_main_establishment></item></results></out></dutchBusinessSearchResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>');
	    HttpResponse response = new HttpResponse();
	    response.setStatus('OK');
	    response.setStatusCode(200);
	    response.setBody(requestBodyMap.get(creditSystemName));
	    return response;
  	}
}