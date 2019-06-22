@isTest
global class E2EIbanMock implements HttpCalloutMock {
	global HttpResponse respond(HTTPRequest request){
		HttpResponse response = new HttpResponse();
		response.setStatus('OK');
		response.setStatusCode(200);
		response.setBody('{"iban":"BE71096123456769","result":"passed","return_code":0,"checks":["length","bank_code","account_number","iban_checksum"],"bic_candidates":[{"bic":"GKCCBEBB","zip":"","city":"","wwwcount":0,"sampleurl":""}],"all_bic_candidates":[{"bic":"GKCCBEBB","zip":"","city":"","wwwcount":0,"sampleurl":""}],"country":"BE","bank_code":"096","bank_and_branch_code":"096","bank":"","bank_address":"Bd Pacheco 441000 Brussels","bank_street":"Bd Pacheco 44","bank_city":"Brussels","bank_state":"","bank_postal_code":"1000","bank_url":"","branch":"","branch_code":"","in_scl_directory":"yes","sct":"yes","sdd":"yes","cor1":"no","b2b":"yes","scc":"no","sct_inst":"yes","sct_inst_readiness_date":"2018-11-18","account_number":"096123456769","account_validation_method":"","account_validation":"","length_check":"passed","account_check":"passed","bank_code_check":"passed","iban_checksum_check":"passed","data_age":"20190405","iban_listed":"www","iban_www_occurrences":"1","www_seen_from":"2017-06-22","www_seen_until":"2017-06-22","iban_url":"","url_rank":"711224","url_category":"","url_min_depth":"0","www_prominence":"","iban_reported_to_exist":0,"iban_last_reported":"","iban_candidate":"","IBANformat":"BEkk BBBC CCCC CCCC","formatcomment":"The last 12 digits represent: B = bank code, C = account No.","balance":99408}');
		return response;
	}
}