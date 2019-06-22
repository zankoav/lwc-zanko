@isTest
private class SalesDashboardKamPlanReportTest {
	public Static User u;
    public Static Account newAccount;
    public Static Task newTask;


    @isTest
    public static void testKamPlanReport () {
    	Test.startTest();
			createKAM();
		Test.stopTest();

		System.runAs(u) {
	    	createAccount();
			createTask();

			Fleetcor_Calendar_Year__c year = new Fleetcor_Calendar_Year__c( Name = '2017' );
				insert year;

			Fleetcor_Calendar_Month__c month = new Fleetcor_Calendar_Month__c(
				Name = 'January', 
				Start_Date__c = Date.newinstance(2016, 12, 25),
				End_Date__c = Date.today(),
				Fleetcor_Calendar_Year__c = year.Id);
				insert month;

			SalesDashboardKamPlanReport controller = new SalesDashboardKamPlanReport();
				Apexpages.currentPage().getParameters().put('userid', u.Id);
				Apexpages.currentPage().getParameters().put('month', 'January');
				Apexpages.currentPage().getParameters().put('year', '2017');
				controller.init();
		}   	
    }


     @future
	private static void createKAM() {
		Profile p = [SELECT Id FROM Profile WHERE Name='Key Account Manager']; 
		
		u = new User(
			ProfileId = p.Id,
			isActive = TRUE,
			Username = System.now().millisecond() + '_233121_test2@test.com',
		   	Alias = 'tlstarts',
			Email='teamlead.test@test.com',
			EmailEncodingKey='UTF-8',
			Firstname='test',
			Lastname='test',
			LanguageLocaleKey='en_US',
			LocaleSidKey='en_US',
			TimeZoneSidKey='America/Chicago');

		Database.insert(u);	   
	}


    private static void createAccount() {
		RecordType rt = [SELECT Id FROM RecordType WHERE Sobjecttype = 'Account' AND Name = 'Retailer'];

    	newAccount = new Account(
    		Name = 'test',
			Type = 'Retailer',
			RecordTypeId = rt.Id,
			Bundesland__c = 'Austria',
			Beschaeftigte__c = '1-4',
    		Strasse_E__c = 'test',
    		Hausnummer_E__c = 'test',
    		PLZ_E__c = 'test',
    		Ort_E__c = 'tet',
    		Land_E__c = 'DE',
    		Name_Zahlungspflichtigen_Kontoinhaber__c = 'test',
    		Strasse_und_Hausnummer__c = 'tes',
    		PLZ_und_Ort__c = 'test',
    		IBAN_des_Zahlungspflichtigen__c = 'tes',
    		SWIFT_BIC__c = 'test',
    		Gruende_fuer_Tankkarten__c = 'vereinfachte Abrechnung',
    		BillingStreet = 'test street',
    		BillingPostalCode = '212231',
    		BillingCity = 'test city',
    		BillingCountry = 'Germany',
    		Kraftstoffverbrauch_Liter_Monat__c = 2);

    	insert newAccount;
	}


	private static void createTask() {
		RecordType rtTask = [SELECT Id FROM RecordType WHERE Sobjecttype = 'Task' AND Name = 'CCS Tasks'];

		newTask = new Task(
			RecordTypeId = rtTask.Id,
			OwnerId = u.Id,		
			Subject = 'Meeting',
			Type = 'Call',
			Status = 'Completed',
			Priority = 'Normal',
			WhatId = newAccount.Id,
			ActivityDate = Date.newinstance(2016, 12, 28));

		insert newTask;
		Datetime createdDate = Date.newinstance(2016, 12, 27);
		Test.setCreatedDate(newTask.Id, createdDate);
	}
}