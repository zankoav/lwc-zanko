@isTest
private class BatchCheckingAdoptionJITBprocessTest {
	public static Account acc;
	public static User abandonmentUser;

    
    /******************************************************************************
	*  Summary         : test checking adoption JITB process    
	*  CreatedDate     : 24/01/2019
	******************************************************************************/
    @isTest
    public static void testCheckingAdoptionJITBprocess() {
    	createAbandonmentUser();
		createAccounts();
    	createOpportunities();
    	createCustomSettings();

    	Test.startTest();
	    	BatchCheckingAdoptionJITBprocess batch = new BatchCheckingAdoptionJITBprocess();
	    	Database.executeBatch(batch);
    	Test.stopTest();

    	List<Opportunity> opptiesList = [SELECT OwnerId FROM Opportunity];
    	for (Opportunity oppty : opptiesList) {
    		System.assertEquals(abandonmentUser.Id, oppty.OwnerId);
    	}
    }


   	/******************************************************************************
   	*  Summary         : create users for test     
   	*  CreatedDate     : 24/01/2019
   	******************************************************************************/
   	private static void createAbandonmentUser() {
	   	List<User> usersList = [SELECT Id, Username FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1];
	   	if (! usersList.isEmpty()) {
	   		abandonmentUser = usersList.get(0);
	   	}
   	}


    /******************************************************************************
    *  Summary         : create data for test (account and opportunity)    
    *  CreatedDate     : 24/01/2019
    ******************************************************************************/
    private static void createAccounts() {
    	acc = new Account(
    		Name = 'test',
    		GFN_Nr__c  = '123',
			Type = 'Customer',
			Bundesland__c = 'Germany',
			Beschaeftigte__c = '1-4',
    		Strasse_E__c = 'test',
    		Hausnummer_E__c = 'test',
    		PLZ_E__c = 'test',
    		Ort_E__c = 'tet',
    		Land_E__c = 'DE',
    		BillingCountry = 'Germany',
    		Name_Zahlungspflichtigen_Kontoinhaber__c = 'test',
    		Strasse_und_Hausnummer__c = 'tes',
    		PLZ_und_Ort__c = 'test',
    		IBAN_des_Zahlungspflichtigen__c = 'tes',					
    		SWIFT_BIC__c = 'test',
    		Land__c = 'test land',
    		Gruende_fuer_Tankkarten__c = 'vereinfachte Abrechnung',
    		Kraftstoffverbrauch_Liter_Monat__c = 2);
    	insert acc;

    	Datetime cd = Datetime.now().addDays(-6);
		Test.setCreatedDate(acc.Id, cd);
	}

    private static void createOpportunities() {
    	List<User> usersList = [SELECT Id, Username FROM User WHERE Name = 'E2E Site Guest User' LIMIT 1];
    	RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Euroshell' AND sObjectType = 'Opportunity' LIMIT 1];
		Opportunity oppty = new Opportunity(
			RecordTypeId = rt.Id,
			AccountId = acc.Id,
			OwnerId = usersList.get(0).Id,
			Kraftstoffverbrauch_Liter_Monat__c = 2,
			Prio__c = 'A',
			Anzahl_der_Karten__c = 5,
			E2E__c = true,
			Sec_Channel__c = 'JITB',
			Derzeitige_Zahlungsmethode__c = 'Bank',
			Kundensegment__c = 'Campaign_1',
			Zahlungsart__c = 'Lastschrift',
			Zahlungsziel__c = '7',
			Angebotsdauer__c = 'test',
			StageName = 'Prospecting',
			Name = 'test e2e opp',
			Product__c = 'None',
			Disable_for_KPI__c = FALSE,
			Last_Owner_Change_Date__c = Date.newinstance(2016, 12, 27),
			CloseDate = Date.newinstance(2016, 12, 28));
		insert oppty;

		Datetime cd = Datetime.now().addDays(-6);
		Test.setCreatedDate(oppty.Id, cd);
    }


    /******************************************************************************
    *  Summary         : create custom setting for test of checking adoption JITB process     
    *  CreatedDate     : 24/01/2019
    ******************************************************************************/
    private static void createCustomSettings() {
		Adoption_Process_Settings__c adoptionSettings = new Adoption_Process_Settings__c(
			Name = 'GermanyJITB',
	        Number_Of_Days_To_Reassign__c = 5
		);
	    insert adoptionSettings;

	    E2E_Form_General_Settings__c generalSettings = new E2E_Form_General_Settings__c(
			Name = 'Germany',
	        Abandonment_User__c = abandonmentUser.Id
		);
	    insert generalSettings;
    } 
}