//***initial conditions***//
// 1. Sec_Channel__c = 'Inbound' OR Sec_Channel__c = 'JITB' ; Status = 'Open' OR Status = 'Contacted' ; OWNER LEAD NOT EQUALS OWNER salesteam for current teamleaders Inbound
// 2. Sec_Channel__c = 'Outbound' ; Status = 'Open' OR Status = 'Contacted' ; OWNER LEAD NOT EQUALS OWNER outbound salesteam for current teamleaders outbound
//**********************************************************************************************************************************************************************//
          		// case1- case3 for Teamleaders Inbound//
// case1 - Sec_Channel__c = 'Inbound'; Status = 'Contacted'; Owner lead = owner user from salesteam current teamlead (NOT INVALID LEAD)
// case2 - Sec_Channel__c = 'Inbound'; Status = 'Contacted'; Owner lead = current Teamleader Inbound (INVALID LEAD)
// case3 - Sec_Channel__c = 'Inbound'; Status = 'Disqualified'; Owner lead = current Teamleader Inbound (NOT INVALID LEAD)
				// case4- case6 for Teamleaders Outbound//
// case4 - Sec_Channel__c = 'Outbound'; Status = 'Contacted'; Owner lead = owner user from salesteam Inbound (INVALID LEAD)
// case5 - Sec_Channel__c = 'Outbound'; Status = 'Open'; Owner lead = current Teamleader Inbound (INVALID LEAD)
// case6 - Sec_Channel__c = 'Inbound'; Status = 'Contacted'; Owner lead = owner user from salesteam Inbound (NOT INVALID LEAD)

@isTest
private class InvalidLeadsCounterCtrlTest {
	public Static User u;
	public Static User u1;
	public Static User u2;
	public Static Lead newLead;


	@isTest
    public static void testInvalidLeadsCase1() {
        Test.startTest();
			createTeamLeader1();
			createSalesUser();
		Test.stopTest();

	    System.runAs(u1) {
			createLead();
			newLead.OwnerId = u.Id;
			update newLead;

			InvalidLeadsCounterCtrl controller = new InvalidLeadsCounterCtrl();
		    controller.init();
		    System.assertEquals(0, controller.numberOfInvalidLeads);
		    System.assertEquals(0, controller.invalidLeadsInbound);
		    System.assertEquals(0, controller.invalidLeadsInboundOpen);
		    System.assertEquals(0, controller.invalidLeadsInboundContacted);
		    System.assertEquals(0, controller.invalidLeadsJITB);
		    System.assertEquals(0, controller.invalidLeadsJITBOpen);
		    System.assertEquals(0, controller.invalidLeadsJITBContacted);
		    System.assertEquals(0, controller.invalidLeadsOutbound);
		    System.assertEquals(0, controller.invalidLeadsOutboundOpen);
		    System.assertEquals(0, controller.invalidLeadsOutboundContacted);
		}
	}


	@isTest
    public static void testInvalidLeadsCase2() {
        Test.startTest();
			createTeamLeader1();
		Test.stopTest();

	    System.runAs(u1) {
			createLead();
			newLead.OwnerId = u1.Id;
			update newLead;

			InvalidLeadsCounterCtrl controller = new InvalidLeadsCounterCtrl();
		    controller.init();
		    System.assertEquals(1, controller.numberOfInvalidLeads);
		    System.assertEquals(1, controller.invalidLeadsInbound);
		    System.assertEquals(0, controller.invalidLeadsInboundOpen);
		    System.assertEquals(1, controller.invalidLeadsInboundContacted);
		    System.assertEquals(0, controller.invalidLeadsJITB);
		    System.assertEquals(0, controller.invalidLeadsJITBOpen);
		    System.assertEquals(0, controller.invalidLeadsJITBContacted);
		    System.assertEquals(0, controller.invalidLeadsOutbound);
		    System.assertEquals(0, controller.invalidLeadsOutboundOpen);
		    System.assertEquals(0, controller.invalidLeadsOutboundContacted);
		}
	}


	@isTest
    public static void testInvalidLeadsCase3() {
        Test.startTest();
			createTeamLeader1();
		Test.stopTest();

	    System.runAs(u1) {
			createLead();
			newLead.OwnerId = u1.Id;
			newLead.Status = 'Disqualified';
			update newLead;

			InvalidLeadsCounterCtrl controller = new InvalidLeadsCounterCtrl();
		    controller.init();
		    System.assertEquals(0, controller.numberOfInvalidLeads);
		    System.assertEquals(0, controller.invalidLeadsInbound);
		    System.assertEquals(0, controller.invalidLeadsInboundOpen);
		    System.assertEquals(0, controller.invalidLeadsInboundContacted);
		    System.assertEquals(0, controller.invalidLeadsJITB);
		    System.assertEquals(0, controller.invalidLeadsJITBOpen);
		    System.assertEquals(0, controller.invalidLeadsJITBContacted);
		    System.assertEquals(0, controller.invalidLeadsOutbound);
		    System.assertEquals(0, controller.invalidLeadsOutboundOpen);
		    System.assertEquals(0, controller.invalidLeadsOutboundContacted);
		}
	}


	@isTest
    public static void testInvalidLeadsCase4() {
        Test.startTest();
			createTeamLeader2();
			createSalesUser();
		Test.stopTest();

	    System.runAs(u2) {
			createLead();
			newLead.Sec_Channel__c = 'Outbound';
			newLead.OwnerId = u2.Id;
			update newLead;

			InvalidLeadsCounterCtrl controller = new InvalidLeadsCounterCtrl();
		    controller.init();
		    System.assertEquals(1, controller.numberOfInvalidLeads);
		    System.assertEquals(0, controller.invalidLeadsInbound);
		    System.assertEquals(0, controller.invalidLeadsInboundOpen);
		    System.assertEquals(0, controller.invalidLeadsInboundContacted);
		    System.assertEquals(0, controller.invalidLeadsJITB);
		    System.assertEquals(0, controller.invalidLeadsJITBOpen);
		    System.assertEquals(0, controller.invalidLeadsJITBContacted);
		    System.assertEquals(1, controller.invalidLeadsOutbound);
		    System.assertEquals(0, controller.invalidLeadsOutboundOpen);
		    System.assertEquals(1, controller.invalidLeadsOutboundContacted);
		}
	}


	@isTest
    public static void testInvalidLeadsCase5() {
        Test.startTest();
			createTeamLeader2();
		Test.stopTest();

	    System.runAs(u2) {
			createLead();
			newLead.OwnerId = u2.Id;
			newLead.Sec_Channel__c = 'Outbound';
			newLead.Status = 'Open';
			update newLead;

			InvalidLeadsCounterCtrl controller = new InvalidLeadsCounterCtrl();
		    controller.init();
		    System.assertEquals(1, controller.numberOfInvalidLeads);
		    System.assertEquals(0, controller.invalidLeadsInbound);
		    System.assertEquals(0, controller.invalidLeadsInboundOpen);
		    System.assertEquals(0, controller.invalidLeadsInboundContacted);
		    System.assertEquals(0, controller.invalidLeadsJITB);
		    System.assertEquals(0, controller.invalidLeadsJITBOpen);
		    System.assertEquals(0, controller.invalidLeadsJITBContacted);
		    System.assertEquals(1, controller.invalidLeadsOutbound);
		    System.assertEquals(1, controller.invalidLeadsOutboundOpen);
		    System.assertEquals(0, controller.invalidLeadsOutboundContacted);
		}
	}

	@isTest
    public static void testInvalidLeadsCase6() {
        Test.startTest();
			createTeamLeader2();
			createSalesUser();
		Test.stopTest();

	    System.runAs(u2) {
			createLead();
			newLead.OwnerId = u.Id;
			update newLead;

			InvalidLeadsCounterCtrl controller = new InvalidLeadsCounterCtrl();
		    controller.init();
		    System.assertEquals(0, controller.numberOfInvalidLeads);
		    System.assertEquals(0, controller.invalidLeadsInbound);
		    System.assertEquals(0, controller.invalidLeadsInboundOpen);
		    System.assertEquals(0, controller.invalidLeadsInboundContacted);
		    System.assertEquals(0, controller.invalidLeadsJITB);
		    System.assertEquals(0, controller.invalidLeadsJITBOpen);
		    System.assertEquals(0, controller.invalidLeadsJITBContacted);
		    System.assertEquals(0, controller.invalidLeadsOutbound);
		    System.assertEquals(0, controller.invalidLeadsOutboundOpen);
		    System.assertEquals(0, controller.invalidLeadsOutboundContacted);
		}
	}


	@future
	private static void createSalesUser() {
		Profile p = [SELECT Id FROM Profile WHERE Name='Sales']; 
		UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'Salesteam Inbound'];
		
		u = new User(
			UserRoleId = ur.Id,
			ProfileId = p.Id,
			Username = System.now().millisecond() + '_233121_test2@test.com',
		   	Alias = 'tu',
			Email='test.user_1233@test.com',
			EmailEncodingKey='UTF-8',
			Firstname='testUser',
			Lastname='test',
			LanguageLocaleKey='en_US',
			LocaleSidKey='en_US',
			TimeZoneSidKey='America/Chicago'
		);
		Database.insert(u);	   
	}


	@future
	private static void createTeamLeader1() {
		Profile p = [SELECT Id FROM Profile WHERE Name='Salesteamleiter']; 
		UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'Teamleiter Inbound'];
		
		u1 = new User(
			UserRoleId = ur.Id,
			ProfileId = p.Id,
			Username = System.now().millisecond() + '_45_test1@test.com',
		   	Alias = 'ti',
			Email='test_teamlead@test.com',
			EmailEncodingKey='UTF-8',
			Firstname='John',
			Lastname='Johnson',
			LanguageLocaleKey='en_US',
			LocaleSidKey='en_US',
			TimeZoneSidKey='America/Chicago'
		);
		Database.insert(u1);
	}


	@future
	private static void createTeamLeader2() {
		Profile p = [SELECT Id FROM Profile WHERE Name='Salesteamleiter']; 
		UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'Teamleiter Outbound 1'];
		
		u2 = new User(
			UserRoleId = ur.Id,
			ProfileId = p.Id,
			Username = System.now().millisecond() + '_11_test2@test.com',
		   	Alias = 'to1',
			Email='test_teamleader@test.com',
			EmailEncodingKey='UTF-8',
			Firstname='Mike',
			Lastname='Robson',
			LanguageLocaleKey='en_US',
			LocaleSidKey='en_US',
			TimeZoneSidKey='America/Chicago'
		);
		Database.insert(u2);
	}


	private static void createLead() {
		newLead = new Lead(
			Country = 'Germany',
			Company = 'Company test',
			Salutation = 'Herr',
			Anzahl_der_Karten_Euroshell__c = 'test',
			Anzahl_der_Fahrzeuge__c = 1, 
			FirstName = 'nameLead', 
			LastName = 'familyLead',  
            Sec_Channel__c = 'Inbound',
            Phone = '3333333',
            LeadSource = 'Internet',
            Status = 'Contacted',
            Disable_for_KPI__c = FALSE           
            );
		insert newLead;
	}
}