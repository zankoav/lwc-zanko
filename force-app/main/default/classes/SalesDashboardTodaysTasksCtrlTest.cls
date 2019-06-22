@isTest
private class SalesDashboardTodaysTasksCtrlTest {
    public Static User u;
    public Static User u2;
    public Static Account newAccount;
    public Static Opportunity newOpp;
    public Static Task newTask;

    @isTest
    public static void testLeadDashboard() {
		Test.startTest();
			createSalesUser();
			createLeadUser();
		Test.stopTest();

		System.runAs(u2) {
			createAccount();
			createOpp();
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
		    
		    SalesDashboardTodaysTasksCtrl controller = new SalesDashboardTodaysTasksCtrl();
		    controller.init();
		    controller.getYears();
			controller.getCurrentMonths();
			controller.changeYear();
		}
    }

    @isTest
    public static void testLeadDashboard2() {
		Test.startTest();
			createSalesUser();
			createLeadUser();
		Test.stopTest();

		System.runAs(u) {
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

			createAccount();
			createOpp();
		    
		    SalesDashboardTodaysTasksCtrl controller = new SalesDashboardTodaysTasksCtrl();
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
			Email='bruce.wayne_' + rand + '@wayneenterprises.com',
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
    		Kraftstoffverbrauch_Liter_Monat__c = 2);
    	insert newAccount;
	}

	private static void createOpp() {
		newOpp = new Opportunity(
			AccountId = newAccount.Id,
			Kraftstoffverbrauch_Liter_Monat__c = 2,
			Prio__c = 'A',
			Anzahl_der_Karten__c = 5,
			Derzeitige_Zahlungsmethode__c = 'Bank',
			Kundensegment__c = 'Campaign_1',
			Zahlungsart__c = 'Lastschrift',
			Zahlungsziel__c = '7',
			Herkunft_Land__c = 'DE',
			StageName = 'Prospecting',
			Name = 'test opp',
			CloseDate = Date.newinstance(2017, 1, 3));
		insert newOpp;
	}

	private static void createTask() {
		RecordType rtTask = [SELECT Id FROM RecordType WHERE Sobjecttype = 'Task' AND Name = 'CCS Tasks'];

		newTask = new Task(
			RecordTypeId = rtTask.Id,
			OwnerId = u.Id,		
			Subject = 'Call',
			Type = 'Call',
			Status = 'In Progress',
			Priority = 'Normal',
			WhatId = newAccount.Id,
			ActivityDate = Date.newinstance( 2017, 1, 10 ));

		insert newTask;

		Datetime createdDate = Date.newinstance( 2016, 12, 27 );
		Test.setCreatedDate(newTask.Id, createdDate);
	}     
}