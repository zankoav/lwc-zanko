public with sharing class FirmenwissenJSONgenerator {
 //    public String searchTerm {get; set;}
 //    public String country {get; set;}

	// @RemoteAction
	// public static List<CompanyWrapper> getSearchSuggestions(String searchString) {
 //        Blob headerValue = Blob.valueOf('AFW-Fleetcor' + ':' + 'gFb=R3dx7j4Fm#6d');
	// 	String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue); 
	// 	Http h = new Http();
	// 	HttpRequest request = new HttpRequest();
	// 	String endpoint = 'https://www.firmenwissen.de/search/suggest/companywithaddress/' + searchString + '?country=DE';
	// 	request.setEndpoint(endpoint);     
	// 	request.setMethod('GET');
	// 	request.setHeader('Authorization', authorizationHeader);
	// 	HttpResponse response = h.send(request);
	// 	FirmenwissenResponse firmenwissenResponse = (FirmenwissenResponse)JSON.deserialize(response.getBody(), FirmenwissenResponse.class);
	// 	List<CompanyWrapper> companyWrappers = new List<CompanyWrapper>();
	// 	for (firmenwissenResponse.CompanyNameSuggestions foundedCompany : firmenwissenResponse.companyNameSuggestions) {
	// 		CompanyWrapper wrap = new CompanyWrapper (
	// 			foundedCompany.identnummer, 
	// 			foundedCompany.name, 
	// 			foundedCompany.bundesland, 
	// 			foundedCompany.plz, 
	// 			foundedCompany.ort, 
	// 			foundedCompany.strasseHausnummer);
	// 		companyWrappers.add(wrap);
	// 	}
	// 	return companyWrappers;
	// }


	public String searchTerm {get; set;}
    public String country {get; set;}

	@RemoteAction
	public static List<CompanyWrapper> getSearchSuggestions(String searchString, String country) {
		if (country != null) {
			Firmenwissen_Settings__c firmenwissenSettings;
			if (System.URL.getSalesforceBaseURL().toExternalForm().contains('eu9.salesforce.com')) {
				firmenwissenSettings = Firmenwissen_Settings__c.getInstance(country);
			} else {
				firmenwissenSettings = Firmenwissen_Settings__c.getInstance(country + '_TEST');
			}
	        Blob headerValue = Blob.valueOf(firmenwissenSettings.Login__c + ':' + firmenwissenSettings.Password__c);
			String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue); 
			Http h = new Http();
			HttpRequest request = new HttpRequest();
			String endpoint = firmenwissenSettings.End_Point__c + searchString + '?country=' + firmenwissenSettings.Country_Code__c;
			request.setEndpoint(endpoint);     
			request.setMethod('GET');
			request.setHeader('Authorization', authorizationHeader);
			HttpResponse response = h.send(request);
			FirmenwissenResponse firmenwissenResponse = (FirmenwissenResponse)JSON.deserialize(response.getBody(), FirmenwissenResponse.class);
			List<CompanyWrapper> companyWrappers = new List<CompanyWrapper>();
			for (firmenwissenResponse.CompanyNameSuggestions foundedCompany : firmenwissenResponse.companyNameSuggestions) {
				CompanyWrapper wrap = new CompanyWrapper (
					foundedCompany.identnummer, 
					foundedCompany.name, 
					foundedCompany.bundesland, 
					foundedCompany.plz, 
					foundedCompany.ort, 
					foundedCompany.strasseHausnummer);
				companyWrappers.add(wrap);
			}
			return companyWrappers;
		}
		return null;
	}


	public class CompanyWrapper {
		public String id {get; set;}
		public String name {get; set;}
		public String state {get; set;}
		public String postcode {get; set;}
		public String city {get; set;}
		public String street {get; set;}
		
		public CompanyWrapper(String id, String name, String state, String postcode, String city, String street) {
			this.id = id;
			this.name = name;
			this.state = state;
			this.postcode = postcode;
			this.city = city;
			this.street = street;
		}
	}
}