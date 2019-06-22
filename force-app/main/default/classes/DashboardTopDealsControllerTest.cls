@isTest
private class DashboardTopDealsControllerTest {
	public Static User u;
	public Static Account newAccount;
    public Static Opportunity newOpp;
    public Static Lead newLead;
    public Static Task newTask;

    @isTest
    public static void testTopDealsDashboard1() {    	
		Test.startTest();
			createTeamLeadUser();
		Test.stopTest();

		System.runAs(u) {
			createAccount();
			createOpp();
			createLead();
			createTask();

			Fleetcor_Calendar_Year__c year = new Fleetcor_Calendar_Year__c(Name = String.valueOf(Date.today().year()));
			insert year;

			Fleetcor_Calendar_Month__c month = new Fleetcor_Calendar_Month__c(
				Name = 'July',
				Month_Number__c = 7, 
				Start_Date__c = Date.today().addDays(-10),
				End_Date__c = Date.today().addDays(20),
				Fleetcor_Calendar_Year__c = year.Id);
			insert month;

			Fleetcor_Calendar_Week__c week = new Fleetcor_Calendar_Week__c( 
				Start_Date__c = Date.today().addDays(-3), 
				End_Date__c = Date.today().addDays(4),
				Fleetcor_Calendar_Month__c = month.Id);
			insert week;

			DashboardTopDealsController controller = new DashboardTopDealsController();
			controller.init();
			controller.getPeriodsList();
			controller.getYearsList();		
			controller.selectedPeriod = month.Id;
			controller.init();
			controller.changeYear();
		}	
	}

	 @isTest
    public static void testTopDealsDashboard2() {    	
		Test.startTest();
			createTeamLeadUser();
		Test.stopTest();

		System.runAs(u) {
			createAccount();
			createOpp();
			createLead();
			createTask();

			newTask.WhatId = null;
			newTask.WhoId = newLead.Id;
			update newTask;
			
			Fleetcor_Calendar_Year__c year = new Fleetcor_Calendar_Year__c(Name = String.valueOf(Date.today().year()));
			insert year;

			Fleetcor_Calendar_Month__c month = new Fleetcor_Calendar_Month__c(
				Name = 'July',
				Month_Number__c = 7, 
				Start_Date__c = Date.today().addDays(-10),
				End_Date__c = Date.today().addDays(20),
				Fleetcor_Calendar_Year__c = year.Id);
			insert month;

			Fleetcor_Calendar_Week__c week = new Fleetcor_Calendar_Week__c( 
				Start_Date__c = Date.today().addDays(-3), 
				End_Date__c = Date.today().addDays(4),
				Fleetcor_Calendar_Month__c = month.Id);
			insert week;

			DashboardTopDealsController controller = new DashboardTopDealsController();
			controller.init();
			controller.getPeriodsList();
			controller.getYearsList();		
			controller.selectedPeriod = week.Id;
			controller.init();
			controller.changeYear();
		}	
	}


	@isTest
    public static void testTopDealsDashboard3() {    	
		Test.startTest();
			createTeamLeadUser();
		Test.stopTest();

		System.runAs(u) {
			createAccount();
			createOpp();
			createLead();
			createTask();

			Fleetcor_Calendar_Year__c year = new Fleetcor_Calendar_Year__c(Name = '2016');
			insert year;

			Fleetcor_Calendar_Month__c month = new Fleetcor_Calendar_Month__c(
				Name = 'January',
				Month_Number__c = 1, 
				Start_Date__c = Date.newInstance(2016, 1, 1),
				End_Date__c = Date.newInstance(2016, 1, 31),
				Fleetcor_Calendar_Year__c = year.Id);
			insert month;

			Fleetcor_Calendar_Week__c week = new Fleetcor_Calendar_Week__c( 
				Start_Date__c = Date.newInstance(2016, 1, 1), 
				End_Date__c = Date.newInstance(2016, 1, 7),
				Fleetcor_Calendar_Month__c = month.Id);
			insert week;

			DashboardTopDealsController controller = new DashboardTopDealsController();
			controller.selectedYear = '2016';
			controller.init();
			controller.changeYear();
		}	
	}

    @future
	private static void createTeamLeadUser() {
		Profile p = [SELECT Id FROM Profile WHERE Name='Salesteamleiter']; 
		UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'Teamleiter Inbound'];
		
		u = new User(
			UserRoleId = ur.Id,
			ProfileId = p.Id,
			Username = System.now().millisecond() + '_23423_test2@test.com',
		   	Alias = 'batman',
			Email='bruce.wayne_1233@wayneenterprises.com',
			EmailEncodingKey='UTF-8',
			Firstname='Bruce',
			Lastname='Wayne',
			LanguageLocaleKey='en_US',
			LocaleSidKey='en_US',
			TimeZoneSidKey='America/Chicago'
		);
		Database.insert(u);
	}


	private static void createAccount() {
    	newAccount = new Account(
    		Name = 'test',
    		GFN_Nr__c  = '123',
			Type = 'Customer',
			Bundesland__c = 'Austria',
			Beschaeftigte__c = '1-4',
    		Strasse_E__c = 'test',
    		Hausnummer_E__c = 'test',
    		BillingStreet = 'test street',
    		BillingPostalCode = '1234',
    		BillingCity = 'test city',
    		BillingCountry = 'Germany',
    		PLZ_E__c = 'test',
    		Ort_E__c = 'tet',
    		Land_E__c = 'DE',
    		Name_Zahlungspflichtigen_Kontoinhaber__c = 'test',
    		Strasse_und_Hausnummer__c = 'tes',
    		PLZ_und_Ort__c = 'test',
    		IBAN_des_Zahlungspflichtigen__c = 'tes',					
    		SWIFT_BIC__c = '1231231',
    		Land__c = 'test land',
    		Gruende_fuer_Tankkarten__c = 'vereinfachte Abrechnung',
    		Kraftstoffverbrauch_Liter_Monat__c = 2);
    	insert newAccount;
	}

    private static void createOpp() {
		RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Euroshell' AND sObjectType = 'Opportunity' LIMIT 1];
		newOpp = new Opportunity(
			OwnerId = u.Id,
			AccountId = newAccount.Id,
			RecordTypeId = rt.Id,
			Kraftstoffverbrauch_Liter_Monat__c = 2,
			Name_of_the_payer_Account_holder__c = 'test',
			IBAN__c = '12312412341',
			SWIFT_BIC__c = '123123123',
			Total_consumption_l_month__c = 123,
			Prio__c = 'A',
			Anzahl_der_Karten__c = 5,
			Sec_Channel__c = 'Inbound',
			Derzeitige_Zahlungsmethode__c = 'Bank',
			Kundensegment__c = 'Campaign_1',
			Zahlungsart__c = 'Lastschrift',
			Zahlungsziel__c = '7',
			Angebotsdauer__c = 'test',
			StageName = 'Prospecting',
			Name = 'test opp',
			Product__c = 'None',
			Disable_for_KPI__c = FALSE,
			Last_Owner_Change_Date__c = Date.today(),
			CloseDate = Date.today()
		);
		insert newOpp;
	}
		
	private static void createLead() {
		newLead = new Lead(
			OwnerId = u.Id,
			Country = 'Germany',
			Company = 'test company',
			Salutation = 'Herr',
			Anzahl_der_Karten_Euroshell__c = 'test',
			Monatlicher_Kraftstoffverbrauch_in_Liter__c = 12345,
			Anzahl_der_Fahrzeuge__c = 2, 
			FirstName = 'testName', 
			LastName = 'testFam',
			Status = 'Open',  
            Sec_Channel__c = 'Inbound',
            Phone = '3333333',
            LeadSource = 'Internet',
            Quali_Status__c = 'Refused to talk',
            Branche_NACE__c = 'Apotheken - 4773',
            Beschaeftigte__c = '1-4',
            Disable_for_KPI__c = FALSE           
            );
		insert newLead;	
	}

	private static void createTask() {
		newTask = new Task(
			RecordTypeId = '01220000000jlNV',		
			Subject = 'Call',
			Type = 'Call',
			Status = 'Completed',
			Priority = 'Normal',
			WhatId = newOpp.Id,
			ActivityDate = Date.newinstance(2017, 1, 1));
		insert newTask;
	}
}