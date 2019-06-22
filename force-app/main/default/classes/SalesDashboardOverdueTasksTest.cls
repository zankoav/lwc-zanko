@isTest
private class SalesDashboardOverdueTasksTest {
    public static User u;
    public static User u2;
    public static Account newAccount;
    public static Opportunity newOpp;
    public static Contact newContact;
    public static Task newTask;

    @isTest
    public static void testLeadDashboard() {
		Test.startTest();
			createSalesUser();
			createLeadUser();
		Test.stopTest();

		System.runAs(u2) {
			createAccount();
			createOpp();
			createContact();
			createTask();

			Fleetcor_Calendar_Year__c year = new Fleetcor_Calendar_Year__c(Name = String.valueOf(Date.today().year()));
	        insert year;

	        Fleetcor_Calendar_Month__c month = new Fleetcor_Calendar_Month__c(
	            Name = 'January', 
	            Start_Date__c = Date.today(),
	            End_Date__c = Date.today().addDays(31),
	            Fleetcor_Calendar_Year__c = year.Id);
	        insert month;

	        Sales_Plan__c plan1 = new Sales_Plan__c(User__c = UserInfo.getUserId(), Fleetcor_Calendar_Month__c = month.Id);
	        insert plan1;

			//next year
	        Fleetcor_Calendar_Year__c nextYear = new Fleetcor_Calendar_Year__c(Name = String.valueOf(Date.today().year() + 1));
	        insert nextYear;

	        Fleetcor_Calendar_Month__c monthOfNextYear = new Fleetcor_Calendar_Month__c(
	            Name = 'January', 
	            Start_Date__c = Date.newInstance(Date.today().year() + 1, Date.today().month(), Date.today().day()),
	            End_Date__c = Date.newInstance(Date.today().year() + 1, Date.today().month(), Date.today().day() + 31),
	            Fleetcor_Calendar_Year__c = nextYear.Id);
	        insert monthOfNextYear;

	        Sales_Plan__c plan2 = new Sales_Plan__c(User__c = UserInfo.getUserId(), Fleetcor_Calendar_Month__c = monthOfNextYear.Id);
	        insert plan2;
		    
		    SalesDashboardOverdueTasksCtrl controller = new SalesDashboardOverdueTasksCtrl();
		    controller.init();
		    controller.getYears();
			controller.getCurrentMonths();
			controller.changeYear();
		}
    }


    @isTest
    public static void testSalesDashboard() {
		Test.startTest();
			createSalesUser();
			createLeadUser();
		Test.stopTest();

		System.runAs(u) {
			createAccount();
			createOpp();
			createContact();
			createTask();

			Fleetcor_Calendar_Year__c year = new Fleetcor_Calendar_Year__c(Name = String.valueOf(Date.today().year()));
	        insert year;

	        Fleetcor_Calendar_Month__c month = new Fleetcor_Calendar_Month__c(
	            Name = 'January', 
	            Start_Date__c = Date.today(),
	            End_Date__c = Date.today().addDays(31),
	            Fleetcor_Calendar_Year__c = year.Id);
	        insert month;

	        Sales_Plan__c plan1 = new Sales_Plan__c(User__c = UserInfo.getUserId(), Fleetcor_Calendar_Month__c = month.Id);
	        insert plan1;

			//next year
	        Fleetcor_Calendar_Year__c nextYear = new Fleetcor_Calendar_Year__c(Name = String.valueOf(Date.today().year() + 1));
	        insert nextYear;

	        Fleetcor_Calendar_Month__c monthOfNextYear = new Fleetcor_Calendar_Month__c(
	            Name = 'January', 
	            Start_Date__c = Date.newInstance(Date.today().year() + 1, Date.today().month(), Date.today().day()),
	            End_Date__c = Date.newInstance(Date.today().year() + 1, Date.today().month(), Date.today().day() + 31),
	            Fleetcor_Calendar_Year__c = nextYear.Id);
	        insert monthOfNextYear;

	        Sales_Plan__c plan2 = new Sales_Plan__c(User__c = UserInfo.getUserId(), Fleetcor_Calendar_Month__c = monthOfNextYear.Id);
	        insert plan2;
		    
		    SalesDashboardOverdueTasksCtrl controller = new SalesDashboardOverdueTasksCtrl();
		    controller.init();
		}
    }

	@future
	private static void createSalesUser() {
		Profile p = [SELECT Id FROM Profile WHERE Name='Sales']; 
		UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'Salesteam Outbound 2'];
		Integer rand = Math.round(Math.random()*100000);
		u = new User(
			UserRoleId = ur.Id,
			ProfileId = p.Id,
			Username = rand + '@' + rand + 'test.com',
		   	Alias = 'batman',
			Email='bruce.wayne_'+ rand +'@wayneenterprises.com',
			EmailEncodingKey='UTF-8',
			Firstname='Bruce',
			Lastname='Wayne',
			LanguageLocaleKey='en_US',
			LocaleSidKey='en_US',
			TimeZoneSidKey='America/Chicago'
		);
		Database.insert(u);	   
	}

	@future
	private static void createLeadUser() {
		Profile p = [SELECT Id FROM Profile WHERE Name='Salesteamleiter']; 
		UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'Teamleiter Outbound 2'];
		Integer rand = Math.round(Math.random()*100000);
		u2 = new User(
			UserRoleId = ur.Id,
			ProfileId = p.Id,
			Username = rand + '@' + rand + 'test.com',
		   	Alias = 'batman',
			Email='bruce.wayne_'+ rand +'@wayneenterprises.com',
			EmailEncodingKey='UTF-8',
			Firstname='Bruce',
			Lastname='Wayne',
			LanguageLocaleKey='en_US',
			LocaleSidKey='en_US',
			TimeZoneSidKey='America/Chicago'
		);
		Database.insert(u2);	   
	}

	private static void createAccount() {
    	newAccount = new Account(
    		Name = 'test',
			Type = 'Customer',
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
    		BillingCountry = 'test country',
    		Kraftstoffverbrauch_Liter_Monat__c = 2);
	}

	private static void createOpp() {
		newOpp = new Opportunity(
			AccountId = newAccount.Id,
			Kraftstoffverbrauch_Liter_Monat__c = 2,
			Prio__c = 'A',
			Anzahl_der_Karten__c = 5,
			Angebotsdauer__c = '5',
			Derzeitige_Zahlungsmethode__c = 'Bank',
			Kundensegment__c = 'Campaign_1',
			Zahlungsart__c = 'Lastschrift',
			Zahlungsziel__c = '7',
			Herkunft_Land__c = 'DE',
			StageName = 'Prospecting',
			Name = 'test opp',
			Product__c = 'test product',
			CloseDate = Date.newinstance(2017, 1, 3));
		insert newOpp;
	}

	private static void createContact() {
		newContact = new Contact(
    		LastName =  'test',
    		MailingCountry = 'Poland',
    		Salutation = 'Herr',
    		Phone = '049123123'
		);
    	insert newContact;
	}

	private static void createTask() {
		newTask = new Task(
			RecordTypeId = '01220000000jlNV',		
			Subject = 'Call',
			Type = 'Call',
			Status = 'In progress',
			Priority = 'Normal',
			WhatId = newOpp.Id,
			WhoId = newContact.Id,
			ActivityDate = Date.newinstance(2017, 1, 1)
		);
		insert newTask;

		Datetime createdDate = Date.newinstance( 2016, 12, 27 );
		Test.setCreatedDate(newTask.Id, createdDate);
	}    
}