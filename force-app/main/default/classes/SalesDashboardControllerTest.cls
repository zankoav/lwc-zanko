@isTest
private class SalesDashboardControllerTest {
    public Static User u;
    public Static User u2;
    public Static Account newAccount;
    public Static Opportunity newOpp;

    @isTest
    public static void testSalesDashboard() {
		Test.startTest();
			createSalesUser();
			createLeadUser();
		Test.stopTest();

		System.runAs(u) {
			createAccount();
			createOpp();

			Fleetcor_Calendar_Year__c year = new Fleetcor_Calendar_Year__c(Name = String.valueOf(Date.today().year()));
	        insert year;

	        Fleetcor_Calendar_Month__c month = new Fleetcor_Calendar_Month__c(
	            Name = 'January', 
	            Start_Date__c = Date.today(),
	            End_Date__c = Date.today().addDays(31),
	            Fleetcor_Calendar_Year__c = year.Id);
	        insert month;

	        Fleetcor_Calendar_Week__c week = new Fleetcor_Calendar_Week__c(
	            Start_Date__c = Date.today(),
	            End_Date__c = Date.today().addDays(7),
	            Fleetcor_Calendar_Month__c = month.Id);
	        insert week;

	        Sales_Plan__c plan = new Sales_Plan__c(User__c = UserInfo.getUserId(), Fleetcor_Calendar_Month__c = month.Id);
	        insert plan;

	        //next year
	        Fleetcor_Calendar_Year__c nextYear = new Fleetcor_Calendar_Year__c(Name = String.valueOf(Date.today().year() + 1));
	        insert nextYear;

	        Fleetcor_Calendar_Month__c monthOfNextYear = new Fleetcor_Calendar_Month__c(
	            Name = 'January', 
	            Start_Date__c = Date.newInstance(Date.today().year() + 1, Date.today().month(), Date.today().day()),
	            End_Date__c = Date.newInstance(Date.today().year() + 1, Date.today().month(), Date.today().day() + 31),
	            Fleetcor_Calendar_Year__c = nextYear.Id);
	        insert monthOfNextYear;

	        Fleetcor_Calendar_Week__c weekOfNextYear = new Fleetcor_Calendar_Week__c(
	            Start_Date__c = Date.newInstance(Date.today().year() + 1, Date.today().month(), Date.today().day()),
	            End_Date__c = Date.newInstance(Date.today().year() + 1, Date.today().month(), Date.today().day() + 7),
	            Fleetcor_Calendar_Month__c = monthOfNextYear.Id);
	        insert weekOfNextYear;

	        Sales_Plan__c planOfNextYear = new Sales_Plan__c(User__c = UserInfo.getUserId(), Fleetcor_Calendar_Month__c = monthOfNextYear.Id);
	        insert planOfNextYear;
		    
		    SalesDashboardController controller = new SalesDashboardController();
		    controller.init();
		    controller.changeYear();
		    controller.getYears();
			controller.getCurrentMonths();
		    controller.returnFleetCorLastDayMonth(Date.today());
		}
    }

    @isTest
    public static void testLeadDashboard() {
		Test.startTest();
			createSalesUser();
			createLeadUser();
		Test.stopTest();

		System.runAs(u2) {
			createAccount();
			createOpp();

			Fleetcor_Calendar_Year__c year = new Fleetcor_Calendar_Year__c(Name = String.valueOf(Date.today().year()));
	        insert year;

	        Fleetcor_Calendar_Month__c month = new Fleetcor_Calendar_Month__c(
	            Name = 'January', 
	            Start_Date__c = Date.today(),
	            End_Date__c = Date.today().addDays(31),
	            Fleetcor_Calendar_Year__c = year.Id);
	        insert month;

	        Fleetcor_Calendar_Week__c week = new Fleetcor_Calendar_Week__c(
	            Start_Date__c = Date.today(),
	            End_Date__c = Date.today().addDays(31),
	            Fleetcor_Calendar_Month__c = month.Id);
	        insert week;

	        Sales_Plan__c plan = new Sales_Plan__c(User__c = UserInfo.getUserId(), Fleetcor_Calendar_Month__c = month.Id);
	        insert plan;

	        //next year
	        Fleetcor_Calendar_Year__c nextYear = new Fleetcor_Calendar_Year__c(Name = String.valueOf(Date.today().year() + 1));
	        insert nextYear;

	        Fleetcor_Calendar_Month__c monthOfNextYear = new Fleetcor_Calendar_Month__c(
	            Name = 'January', 
	            Start_Date__c = Date.newInstance(Date.today().year() + 1, Date.today().month(), Date.today().day()),
	            End_Date__c = Date.newInstance(Date.today().year() + 1, Date.today().month(), Date.today().day() + 31),
	            Fleetcor_Calendar_Year__c = nextYear.Id);
	        insert monthOfNextYear;

	        Fleetcor_Calendar_Week__c weekOfNextYear = new Fleetcor_Calendar_Week__c(
	            Start_Date__c = Date.newInstance(Date.today().year() + 1, Date.today().month(), Date.today().day()),
	            End_Date__c = Date.newInstance(Date.today().year() + 1, Date.today().month(), Date.today().day() + 7),
	            Fleetcor_Calendar_Month__c = monthOfNextYear.Id);
	        insert weekOfNextYear;

	        Sales_Plan__c planOfNextYear = new Sales_Plan__c(User__c = UserInfo.getUserId(), Fleetcor_Calendar_Month__c = monthOfNextYear.Id);
	        insert planOfNextYear;
		    
		    SalesDashboardController controller = new SalesDashboardController();
		    controller.init();
		    controller.bussinesDays = controller.returnDaysPassed(Datetime.newInstance(2017, 1, 3), Datetime.newInstance(2017, 2, 3), Datetime.newInstance(2017, 1, 3), 3);
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
			Email = 'bruce.wayne_1231231233@wayneenterprises.com',
			EmailEncodingKey = 'UTF-8',
			Firstname = 'Bruce',
			Lastname = 'Wayne',
			LanguageLocaleKey = 'en_US',
			LocaleSidKey ='en_US',
			TimeZoneSidKey = 'America/Chicago'
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
			Email = 'bruce.wayne_126634534533@wayneenterprises.com',
			EmailEncodingKey = 'UTF-8',
			Firstname = 'Bruce',
			Lastname = 'Wayne',
			LanguageLocaleKey = 'en_US',
			LocaleSidKey = 'en_US',
			TimeZoneSidKey = 'America/Chicago'
		);
		Database.insert(u2);	   
	}

	private static void createAccount() {
		RecordType rt = [SELECT Id FROM RecordType WHERE Sobjecttype = 'Account' AND Name = 'Retailer'];

    	newAccount = new Account(
    		Name = 'test',
			Type = 'Customer',
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

	private static void createOpp() {
		newOpp = new Opportunity(
			AccountId = newAccount.Id,
			Kraftstoffverbrauch_Liter_Monat__c = 2,
			Prio__c = 'A',
			Anzahl_der_Karten__c = 5,
			Angebotsdauer__c = 'test',
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
}