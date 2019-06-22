@isTest
global class DataComLeadPhoneMock implements HttpCalloutMock {
  global HttpResponse respond(HTTPRequest req){
    HttpResponse res = new HttpResponse();
    String responseBody = '{"entityUrl":"/services/data/v32.0/connect/datacloud/orders/09F6E0000004CAGUA2/companies","id":"09F6E0000004CAGUA2","purchaseCount":1,"purchaseDate":"2016-12-29T07:14:32.000Z","url":"/services/data/v32.0/connect/datacloud/orders/09F6E0000004CAGUA2"}';
    res.setBody(responseBody);
    res.setStatus('Created');
    return res;
	}
}