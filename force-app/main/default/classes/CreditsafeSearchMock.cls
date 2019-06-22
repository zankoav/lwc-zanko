@isTest
global class CreditsafeSearchMock implements HttpCalloutMock {
  global HttpResponse respond(HTTPRequest req){
    HttpResponse res = new HttpResponse();
    res.setStatus('OK');
    res.setStatusCode(200);
    res.setBody('<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"><s:Body><FindCompaniesResponse xmlns="http://www.creditsafe.com/globaldata/operations"><FindCompaniesResult xmlns:q1="http://www.creditsafe.com/globaldata/datatypes"><q1:Companies><q1:Company OnlineReports="true" Monitoring="false" Country="NL" Id="NL007/X/200340990002"><q1:Name>adidas Benelux B.V.</q1:Name><q1:OfficeType>Branch</q1:OfficeType><q1:Status>Active</q1:Status><q1:RegistrationNumber>20034099</q1:RegistrationNumber><q1:Address><q1:Street>Stadsweide</q1:Street><q1:HouseNumber>142</q1:HouseNumber><q1:City>ROERMOND</q1:City><q1:PostalCode>6041TD</q1:PostalCode></q1:Address><q1:AvailableReportTypes><q1:AvailableReportType>Full</q1:AvailableReportType><q1:AvailableReportType>Basic</q1:AvailableReportType></q1:AvailableReportTypes><q1:AvailableLanguages><q1:AvailableLanguage>EN</q1:AvailableLanguage><q1:AvailableLanguage>NL</q1:AvailableLanguage></q1:AvailableLanguages></q1:Company></q1:Companies></FindCompaniesResult></FindCompaniesResponse></s:Body></s:Envelope>');
    return res;
  }
}