@isTest
private class SalesDashboardKamPlanCtrlTest {
    public Static User u;
    public Static User u1;
    public Static Account newAccount;
    public Static Task newTask;
    public Static KAM_Plan__c newKamPlan;

    // valid case
    @isTest
    public static void kamPlanForManagerDashboardTest1 () {    	
		Test.startTest();
			createKAM();
		Test.stopTest();

		System.runAs(u) {
			createAccount();
			createKamPlan();
			createTask();
			
			Fleetcor_Calendar_Year__c year = new Fleetcor_Calendar_Year__c(Name = String.valueOf(Date.today().year()));
	        insert year;

	        Fleetcor_Calendar_Month__c month = new Fleetcor_Calendar_Month__c(
	            Name = 'January', 
	            Start_Date__c = Date.today(),
	            End_Date__c = Date.today().addDays(31),
	            Fleetcor_Calendar_Year__c = year.Id);
	        insert month;

	        //next year
	        Fleetcor_Calendar_Year__c nextYear = new Fleetcor_Calendar_Year__c(Name = String.valueOf(Date.today().year() + 1));
	        insert nextYear;

	        Fleetcor_Calendar_Month__c monthOfNextYear = new Fleetcor_Calendar_Month__c(
	            Name = 'January', 
	            Start_Date__c = Date.newInstance(Date.today().year() + 1, Date.today().month(), Date.today().day()),
	            End_Date__c = Date.newInstance(Date.today().year() + 1, Date.today().month(), Date.today().day() + 31),
	            Fleetcor_Calendar_Year__c = nextYear.Id);
	        insert monthOfNextYear;

			SalesDashboardKamPlanCtrl controller = new SalesDashboardKamPlanCtrl();
			controller.init();

		    System.assertEquals(1, controller.numberAllTask);
		}
    }


    // invalid case - RecordType Account != Retailer
    @isTest
    public static void kamPlanForManagerDashboardTest2 () {    	
		Test.startTest();
			createKAM();
		Test.stopTest();

		System.runAs(u) {
			createAccount();
			createKamPlan();
			createTask();

			RecordType rt = [SELECT Id FROM RecordType WHERE Sobjecttype = 'Account' AND Name = 'CCS'];
			newAccount.RecordTypeId = rt.Id;
			update newAccount;
			
			Fleetcor_Calendar_Year__c year = new Fleetcor_Calendar_Year__c(Name = String.valueOf(Date.today().year()));
	        insert year;

	        Fleetcor_Calendar_Month__c month = new Fleetcor_Calendar_Month__c(
	            Name = 'January', 
	            Start_Date__c = Date.today(),
	            End_Date__c = Date.today().addDays(31),
	            Fleetcor_Calendar_Year__c = year.Id);
	        insert month;

	        //next year
	        Fleetcor_Calendar_Year__c nextYear = new Fleetcor_Calendar_Year__c(Name = String.valueOf(Date.today().year() + 1));
	        insert nextYear;

	        Fleetcor_Calendar_Month__c monthOfNextYear = new Fleetcor_Calendar_Month__c(
	            Name = 'January', 
	            Start_Date__c = Date.newInstance(Date.today().year() + 1, Date.today().month(), Date.today().day()),
	            End_Date__c = Date.newInstance(Date.today().year() + 1, Date.today().month(), Date.today().day() + 31),
	            Fleetcor_Calendar_Year__c = nextYear.Id);
	        insert monthOfNextYear;

			SalesDashboardKamPlanCtrl controller = new SalesDashboardKamPlanCtrl();
			controller.init();

		    System.assertEquals(0, controller.numberAllTask);
		}
    }


    // invalid case - Subject Task != Meeting
    public static void kamPlanForManagerDashboardTest3 () {    	
		Test.startTest();
			createKAM();
		Test.stopTest();

		System.runAs(u) {
			createAccount();
			createKamPlan();
			createTask();

			newTask.Subject = 'Call';
			update newTask;
			
			Datetime createdDate = Date.newinstance( 2016, 12, 27 );
			Test.setCreatedDate(newTask.Id, createdDate);

			Fleetcor_Calendar_Year__c year = new Fleetcor_Calendar_Year__c(Name = String.valueOf(Date.today().year()));
	        insert year;

	        Fleetcor_Calendar_Month__c month = new Fleetcor_Calendar_Month__c(
	            Name = 'January', 
	            Start_Date__c = Date.today(),
	            End_Date__c = Date.today().addDays(31),
	            Fleetcor_Calendar_Year__c = year.Id);
	        insert month;

	        //next year
	        Fleetcor_Calendar_Year__c nextYear = new Fleetcor_Calendar_Year__c(Name = String.valueOf(Date.today().year() + 1));
	        insert nextYear;

	        Fleetcor_Calendar_Month__c monthOfNextYear = new Fleetcor_Calendar_Month__c(
	            Name = 'January', 
	            Start_Date__c = Date.newInstance(Date.today().year() + 1, Date.today().month(), Date.today().day()),
	            End_Date__c = Date.newInstance(Date.today().year() + 1, Date.today().month(), Date.today().day() + 31),
	            Fleetcor_Calendar_Year__c = nextYear.Id);
	        insert monthOfNextYear;

			SalesDashboardKamPlanCtrl controller = new SalesDashboardKamPlanCtrl();
			controller.init();

		    System.assertEquals(0, controller.numberAllTask);
		}
    }


    @isTest
    public static void kamPlanForDirectorDashboardTest () {    	
		Test.startTest();
			createDirector();
			createKAM();
		Test.stopTest();

		System.runAs(u1) {	
			createAccount();
			createKamPlan();
			createTask();
			
			Fleetcor_Calendar_Year__c year = new Fleetcor_Calendar_Year__c(Name = String.valueOf(Date.today().year()));
	        insert year;

	        Fleetcor_Calendar_Month__c month = new Fleetcor_Calendar_Month__c(
	            Name = 'January', 
	            Start_Date__c = Date.today(),
	            End_Date__c = Date.today().addDays(31),
	            Fleetcor_Calendar_Year__c = year.Id);
	        insert month;

	        //next year
	        Fleetcor_Calendar_Year__c nextYear = new Fleetcor_Calendar_Year__c(Name = String.valueOf(Date.today().year() + 1));
	        insert nextYear;

	        Fleetcor_Calendar_Month__c monthOfNextYear = new Fleetcor_Calendar_Month__c(
	            Name = 'January', 
	            Start_Date__c = Date.newInstance(Date.today().year() + 1, Date.today().month(), Date.today().day()),
	            End_Date__c = Date.newInstance(Date.today().year() + 1, Date.today().month(), Date.today().day() + 31),
	            Fleetcor_Calendar_Year__c = nextYear.Id);
	        insert monthOfNextYear;

			SalesDashboardKamPlanCtrl controller = new SalesDashboardKamPlanCtrl();
			controller.init();

		    System.assertEquals(1, controller.usersWithMeetingsFinal.get(u.Id));
		}
    }


    @future
	private static void createKAM () {
		Profile p = [SELECT Id FROM Profile WHERE Name='Key Account Manager']; 
		
		u = new User(
			ProfileId = p.Id,
			isActive = TRUE,
			Username = System.now().millisecond() + '_233121_test2@test.com',
		   	Alias = 'kam',
			Email='manager.test@test.com',
			EmailEncodingKey='UTF-8',
			Firstname='test',
			Lastname='test',
			LanguageLocaleKey='en_US',
			LocaleSidKey='en_US',
			TimeZoneSidKey='America/Chicago');

		Database.insert(u);	   
	}

	@future
	private static void createDirector () {
		Profile p = [SELECT Id FROM Profile WHERE Name='Sales Director']; 
		
		u1 = new User(
			ProfileId = p.Id,
			isActive = TRUE,
			Username = System.now().millisecond() + '_777_test2@test.com',
		   	Alias = 'direct',
			Email='director.test@test.com',
			EmailEncodingKey='UTF-8',
			Firstname='test name',
			Lastname='test family',
			LanguageLocaleKey='en_US',
			LocaleSidKey='en_US',
			TimeZoneSidKey='America/Chicago');

		Database.insert(u1);	   
	}


	private static void createAccount() {
		RecordType rt = [SELECT Id FROM RecordType WHERE Sobjecttype = 'Account' AND Name = 'Retailer'];

    	newAccount = new Account(
    		Name = 'test',
			Type = 'Retailer',
			RecordTypeId = rt.Id,
			KAM__c = u.Id,
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
		RecordType rtTask = [SELECT Id FROM RecordType WHERE Sobjecttype = 'Task' AND Name = 'Layout Tasks'];

		newTask = new Task(
			RecordTypeId = rtTask.Id,
			OwnerId = u.Id,		
			Subject = 'Meeting',
			Type = 'Call',
			Status = 'Completed',
			Priority = 'Normal',
			WhatId = newAccount.Id,
			ActivityDate = Date.today().addDays(2));

		insert newTask;
		Datetime createdDate = Date.today();
		Test.setCreatedDate(newTask.Id, createdDate);
	}

	private static void createKamPlan() {
		newKamPlan = new KAM_Plan__c(
			Meetings_Plan__c = 15, 
			KAM__c = u.Id);
		insert newKamPlan;  
	}
}