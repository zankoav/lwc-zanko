@isTest
private class DashboardIntensityOfSalesWorkReportTest {
	public Static User u;
	public Static Lead newLead;
	public Static Opportunity newOpp;
    public Static Task newTask;


    @isTest
    public static void testIntensityOfSalesWorkReport1() {
    	Test.startTest();
			createLeadUser();
		Test.stopTest();

		System.runAs(u) {
			createLead();
			createOpp();
			createTask();

		Fleetcor_Calendar_Year__c year = new Fleetcor_Calendar_Year__c(Name = String.valueOf(Date.today().year()));
			insert year;

			Fleetcor_Calendar_Month__c month = new Fleetcor_Calendar_Month__c(
				Name = 'July', 
				Start_Date__c = Date.today().addDays(-10),
				End_Date__c = Date.today().addDays(20),
				Fleetcor_Calendar_Year__c = year.Id);
			insert month;

			Fleetcor_Calendar_Week__c week = new Fleetcor_Calendar_Week__c( 
				Start_Date__c = Date.today().addDays(-3), 
				End_Date__c = Date.today().addDays(3),
				Fleetcor_Calendar_Month__c = month.Id);
			insert week;

			DashboardIntensityOfSalesWorkReportCtrl controller = new DashboardIntensityOfSalesWorkReportCtrl();
 			ApexPages.currentPage().getParameters().put('userid', u.Id);
 			ApexPages.currentPage().getParameters().put('period', week.Id);
 			ApexPages.currentPage().getParameters().put('year', String.valueOf(Date.today().year()));
		    controller.init();
		    controller.getPeriodsList();
		    controller.getYearsList();
		    controller.changeYear();
		}	
	}

	@isTest
    public static void testIntensityOfSalesWorkReport2() {
    	Test.startTest();
			createLeadUser();
		Test.stopTest();

		System.runAs(u) {
			createLead();
			createOpp();
			createTask();

		newTask.WhatId = null;
		newTask.WhoId = newLead.Id;
		update newTask;

		Fleetcor_Calendar_Year__c year = new Fleetcor_Calendar_Year__c(Name = String.valueOf(Date.today().year()));
			insert year;

			Fleetcor_Calendar_Month__c month = new Fleetcor_Calendar_Month__c(
				Name = 'July', 
				Start_Date__c = Date.today().addDays(-10),
				End_Date__c = Date.today().addDays(20),
				Fleetcor_Calendar_Year__c = year.Id);
			insert month;

			Fleetcor_Calendar_Week__c week = new Fleetcor_Calendar_Week__c( 
				Start_Date__c = Date.today().addDays(-3), 
				End_Date__c = Date.today().addDays(3),
				Fleetcor_Calendar_Month__c = month.Id);
			insert week;

			DashboardIntensityOfSalesWorkReportCtrl controller = new DashboardIntensityOfSalesWorkReportCtrl();
 			ApexPages.currentPage().getParameters().put('userid', u.Id);
 			ApexPages.currentPage().getParameters().put('period', month.Id);
 			ApexPages.currentPage().getParameters().put('year', String.valueOf(Date.today().year()));
		    controller.init();
		}	
	}


    @future
	private static void createLeadUser() {
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

    private static void createLead() {
		newLead = new Lead(
			OwnerId = u.Id,
			Country = 'Germany',
			Company = 'test company',
			Salutation = 'Herr',
			Anzahl_der_Karten_Euroshell__c = 'test',
			Status = 'Open',
			Anzahl_der_Fahrzeuge__c = 2, 
			FirstName = 'testName', 
			LastName = 'testFam',  
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

    private static void createOpp() {
		newOpp = new Opportunity(
			OwnerId = u.Id,
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
			CloseDate = Date.today());
		insert newOpp;
	}

	private static void createTask() {
		RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Layout Tasks' AND sObjectType = 'Task' LIMIT 1];
		newTask = new Task(
			OwnerId = u.Id,
			RecordTypeId = rt.Id,		
			Subject = 'Call',
			Type = 'Call',
			Status = 'Completed',
			Priority = 'Normal',
			WhatId = newOpp.Id,
			WhoId = null,
			ActivityDate = Date.today());
		insert newTask;
		Datetime createdDate = Date.today();
		Test.setCreatedDate(newTask.Id, createdDate);
	}
}