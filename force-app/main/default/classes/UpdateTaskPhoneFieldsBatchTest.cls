@isTest
private class UpdateTaskPhoneFieldsBatchTest {
	@isTest
    static void testMethod1() {
	    Lead leadSlovakia = new Lead(
		    Country = 'Slovakia',
            CountryCode = 'SK',
	        Company = 'Company test',
	        Salutation = 'Herr',
	        FirstName = 'nameLead', 
	        LastName = 'familyLead', 
	        Phone = '3333333');
        insert leadSlovakia;

        Contact contactSlovakia = new Contact(
			Phone = '0451 - 5040367',
			MobilePhone = '01702153391',
			Fax = '282245167',
			MailingCountry = 'Slovakia',
            MailingCountryCode = 'SK',
			LastName = 'test',
			Salutation = 'Herr');
		insert contactSlovakia;

		Account accountSlovakia = new Account(
			Phone = '+48 22 0476 75 950',
			SM_mobile__c = '01702153391',
			Fax = '282245167',
			BillingCountry = 'Slovakia',
            BillingCountryCode = 'SK',
			Name = 'test');
		insert accountSlovakia;

		Account accountSlovakiaOpp = new Account(
            Name = 'test',
            GFN_Nr__c  = '123',
            Type = 'Customer',
            Bundesland__c = 'Germany',
            BillingCountry = 'Slovakia',
            BillingCountryCode = 'SK',
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
            Land__c = 'test land',
            Gruende_fuer_Tankkarten__c = 'vereinfachte Abrechnung',
            Kraftstoffverbrauch_Liter_Monat__c = 2
        );
        insert accountSlovakiaOpp;

		Opportunity opportunitySlovakia = new Opportunity(
			AccountId = accountSlovakia.Id,
            Name = 'test opportunity',
            Starts_Status__c = '0. Request received',
            Starts_Schedule__c = Date.today().addDays(-1),
            Starts_Overdue_days__c = 0,
            Starts_Status_Delay__c = false,
            Anzahl_der_Karten__c = 123,
            Zahlungsart__c = 'Lastschrift',
            Name_of_the_payer_Account_holder__c = 'test payer',
            Angebotsdauer__c = 'test',
            Language_preference__c = 'Polish',
            Product__c = 'Home Station offer (v.1)',
            Home_Station__c = '123test',
            IBAN__c = '23424',
            SWIFT_BIC__c = '23423',
            Derzeitige_Zahlungsmethode__c = 'Barzahlung',
            Requested_monthly_Company_Credit_Spend__c = 12345,
            AGB_Datenschutzhinweise_Richtigkeit__c = true,
            Data_Protection_Act_1998__c = true,
            Umsatz__c = '123', 
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(-50),
            Bevollmaechtigung__c = true
        );
        insert opportunitySlovakia;

		List<Task> tasksToInsertList = new List<Task>();
        Task taskLeadSK = new Task(
            Subject = 'Call',
            NVMContactWorld__ContactWorld_Number__c = '0271 - 25093460',
            NVMContactWorld__Customer_Number__c = '33333',
            Priority = 'Normal',
            WhoId = leadSlovakia.Id,
            Status = 'In Bearbeitung');
        tasksToInsertList.add(taskLeadSK);

        Task taskContactSK = new Task(
            Subject = 'Call',
            NVMContactWorld__ContactWorld_Number__c = '0042127125093460',
            NVMContactWorld__Customer_Number__c = '4912345',
            Priority = 'Normal',
            WhoId = contactSlovakia.Id,
            Status = 'In Bearbeitung');
        tasksToInsertList.add(taskContactSK);

        Task taskAccountSK = new Task(
            Subject = 'Call',
            NVMContactWorld__ContactWorld_Number__c = '421(0)25093460',
            NVMContactWorld__Customer_Number__c = '123123123 test@test',
            Priority = 'Normal',
            WhatId = accountSlovakia.Id,
            Status = 'In Bearbeitung');
        tasksToInsertList.add(taskAccountSK);

        Task taskOpportunitySK = new Task(
            Subject = 'Call',
            NVMContactWorld__ContactWorld_Number__c = '+421(0)333333',
            NVMContactWorld__Customer_Number__c = '491  23 / 99',
            Priority = 'Normal',
            WhatId = opportunitySlovakia.Id,
            Status = 'In Bearbeitung');
        tasksToInsertList.add(taskOpportunitySK);

        insert tasksToInsertList;

        Test.startTest();
	        UpdateTaskPhoneFieldsBatch batch = new UpdateTaskPhoneFieldsBatch();
	    	Database.executeBatch(batch);
    	Test.stopTest();

    	Set<Id> idsToTest = new Set<Id>();
		for (Task currentTask : tasksToInsertList) {
			idsToTest.add(currentTask.Id);
		}

		Map<Id, Task> leadsToTestMap = new Map<Id, Task>([
				SELECT NVMContactWorld__ContactWorld_Number__c, NVMContactWorld__Customer_Number__c
				FROM Task
				WHERE Id IN :idsToTest
				LIMIT 10000]);

		// Slovakia
		System.assertEquals('+42127125093460', leadsToTestMap.get(taskLeadSK.Id).NVMContactWorld__ContactWorld_Number__c);
		System.assertEquals('+42133333', leadsToTestMap.get(taskLeadSK.Id).NVMContactWorld__Customer_Number__c);

		System.assertEquals('+42127125093460', leadsToTestMap.get(taskContactSK.Id).NVMContactWorld__ContactWorld_Number__c);
		System.assertEquals('+4214912345', leadsToTestMap.get(taskContactSK.Id).NVMContactWorld__Customer_Number__c);

		System.assertEquals('+42125093460', leadsToTestMap.get(taskAccountSK.Id).NVMContactWorld__ContactWorld_Number__c);
		System.assertEquals('123123123 test@test', leadsToTestMap.get(taskAccountSK.Id).NVMContactWorld__Customer_Number__c);

		System.assertEquals('+421333333', leadsToTestMap.get(taskOpportunitySK.Id).NVMContactWorld__ContactWorld_Number__c);
		System.assertEquals('+4214912399', leadsToTestMap.get(taskOpportunitySK.Id).NVMContactWorld__Customer_Number__c);
	}
}