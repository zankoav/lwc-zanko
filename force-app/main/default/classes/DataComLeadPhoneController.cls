public with sharing class DataComLeadPhoneController {
	public Lead currentLead {get; set;}
	public List<DatacloudCompany> dataCloudCompanies {get; set;}
	public void init() {
		String leadId = ApexPages.currentPage().getParameters().get('id');
		currentLead = [
				SELECT Phone, Data_com_phone__c, Company, Country
				FROM Lead
				WHERE Id = :leadId];	
		if (currentLead.Country != null) {
			String country = currentLead.Country;
			if (currentLead.Country.contains('-')) {
				country = country.substringBefore('-');
			}

			dataCloudCompanies = [
					SELECT Name, CompanyId, City, Zip, Phone, Country, Industry
					FROM DataCloudCompany
					WHERE Name = :currentLead.Company AND Country = :country];
		} else {
			ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter country in Lead'));
		}
	}

	public void purchaseCompanyFromDataCom() {
		String companyId = Apexpages.currentPage().getParameters().get('companyId');
		String endPoint = System.URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v32.0/connect/datacloud/orders';
		String jsonBody = '{"userType":"Monthly", "companyIds":["' + companyId + '"]}';
		HttpRequest request = new HttpRequest();
		request.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionID());
		request.setHeader('Content-Type', 'application/json');
		request.setEndpoint(endPoint);
		request.setMethod('POST');
		request.setBody(jsonBody);
		Http http = new Http();
		HTTPResponse response = http.send(request);
		if (response.getStatus() == 'Created') {
			dataCloudCompanies = [
					SELECT Name, CompanyId, City, Zip, Phone, Country, Industry
					FROM DataCloudCompany
					WHERE Name = :currentLead.Company AND Country = :currentLead.Country];
		}

			if (response.getBody().contains('All the specified ID numbers are already purchased')) {
			ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.INFO,'Data.com company is already purchased'));
		}
	}

	public Pagereference updatePhone() {
		String companyId = Apexpages.currentPage().getParameters().get('companyId');
		DataCloudCompany dataCloudCompany = [
					SELECT Name, CompanyId, City, Zip, Phone, Country, Industry
					FROM DataCloudCompany
					WHERE CompanyId = :companyId];
		currentLead.Data_com_phone__c = dataCloudCompany.Phone.replace('.', '');
		update currentLead;
		return backToLead();
	}

	public Pagereference backToLead() {
		String id = Apexpages.currentPage().getParameters().get('id');
		Pagereference ref =  new Pagereference('/' + id);
		ref.setredirect(True);
		return ref;
	}
}