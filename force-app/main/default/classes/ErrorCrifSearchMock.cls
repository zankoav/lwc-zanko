@isTest
global class ErrorCrifSearchMock implements HttpCalloutMock {
  global HttpResponse respond(HTTPRequest request){
    HttpResponse response = new HttpResponse();
    response.setStatus('OK');
    response.setStatusCode(200);
    response.setBody('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><soapenv:Fault><faultcode>soapenv:Server</faultcode><faultstring>Service error occurred: [[Unique request ID = 1142585304]: Internal service error. Contact your local administrator or try again later.]</faultstring><detail/></soapenv:Fault></soapenv:Body></soapenv:Envelope>');
    return response;
  }
}