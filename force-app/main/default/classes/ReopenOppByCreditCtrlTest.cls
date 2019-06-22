@isTest
private class ReopenOppByCreditCtrlTest {
    public Static User u;
	public Static Opportunity newOpp;
	public Static Opportunity newOpp2;
	public Static EmailTemplate emailTemplateReject;
	public Static EmailTemplate emailTemplateApprove;

	@isTest
    static void testApproveReopen() {
        Test.startTest();
			createUser();
		Test.stopTest();

		System.runAs(u) {
			createOpps();
			createEmailTemplate();
					
			ReopenOppByCreditCtrl controller = new ReopenOppByCreditCtrl();
			ApexPages.currentPage().getParameters().put('Id', newOpp.Id);
			Approval.lock(newOpp.Id);
			controller.init();
			controller.approveReopen();

			List<Opportunity> oppList = [SELECT StageName FROM Opportunity WHERE Id = :newOpp.Id];
			System.assertEquals('Prospecting', oppList.get(0).StageName);
		}
    }


    @isTest
    static void testRejectReopen() {
        Test.startTest();
			createUser();
		Test.stopTest();

		System.runAs(u) {
			createOpps();
			createEmailTemplate();
					
			ReopenOppByCreditCtrl controller = new ReopenOppByCreditCtrl();
			ApexPages.currentPage().getParameters().put('Id', newOpp.Id);
			controller.init();
			controller.rejectReopen();

			List<Opportunity> oppList = [SELECT StageName FROM Opportunity WHERE Id = :newOpp.Id];
			System.assertEquals('Closed Lost', oppList.get(0).StageName);
		}
    }


    @isTest
    static void testValidateFirstException() {
        Test.startTest();
			createUser();
		Test.stopTest();

		System.runAs(u) {
			try {
				createOpps();
				createEmailTemplate();
					
				ReopenOppByCreditCtrl controller = new ReopenOppByCreditCtrl();
				ApexPages.currentPage().getParameters().put('Id', newOpp.Id);
				Approval.lock(newOpp.Id);
				controller.init();
				controller.approveReopen();
            } catch (Exception e) {
                Boolean expectedExceptionThrown =  e.getMessage().contains('There was no request for reopen.') ? true : false;
                System.AssertEquals(true, expectedExceptionThrown);
            } 
		}
    }


    @isTest
    static void testValidateSecondException() {
        Test.startTest();
			createUser();
		Test.stopTest();

		System.runAs(u) {
			try {
				createOpps();
				createEmailTemplate();
					
				ReopenOppByCreditCtrl controller = new ReopenOppByCreditCtrl();
				ApexPages.currentPage().getParameters().put('Id', newOpp2.Id);
				Approval.lock(newOpp2.Id);
				controller.init();
				controller.approveReopen();
            } catch (Exception e) {
                Boolean expectedExceptionThrown =  e.getMessage().contains('This action is available for Closed Lost and CreditCheck rejected Opportunity Stage only.') ? true : false;
                System.AssertEquals(true, expectedExceptionThrown);
            } 
		}
    }

    @future
	private static void createUser() {
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator']; 
		
		u = new User(
			ProfileId = p.Id,
			isActive = TRUE,
			Username = System.now().millisecond() + '_233121_test2@test.com',
		   	Alias = 'kam',
			Email = 'manager.test@test.com',
			EmailEncodingKey = 'UTF-8',
			Firstname = 'test',
			Lastname = 'test',
			LanguageLocaleKey = 'en_US',
			LocaleSidKey = 'en_US',
			TimeZoneSidKey = 'America/Chicago');

		Database.insert(u);	   
	}

	private static void createOpps() {
		newOpp = new Opportunity(
			Kraftstoffverbrauch_Liter_Monat__c = 2,
			Anzahl_der_Karten__c = 5,
			Derzeitige_Zahlungsmethode__c = 'Bank',
			Kundensegment__c = 'Campaign_1',
			Zahlungsart__c = 'Lastschrift',
			Zahlungsziel__c = '7',
			Angebotsdauer__c = 'test',
			StageName = 'Closed Lost',
			Credit_check_date__c = Date.today().addDays(-89),
			Name = 'test opp',
			Product__c = 'None',
			Disable_for_KPI__c = FALSE,
			Last_Owner_Change_Date__c = Date.newinstance(2017, 12, 21),
			CloseDate = Date.newinstance(2017, 12, 28)
		);
		insert newOpp;

		newOpp2 = new Opportunity(
			Kraftstoffverbrauch_Liter_Monat__c = 2,
			Anzahl_der_Karten__c = 5,
			Derzeitige_Zahlungsmethode__c = 'Bank',
			Kundensegment__c = 'Campaign_1',
			Zahlungsart__c = 'Lastschrift',
			Zahlungsziel__c = '7',
			Angebotsdauer__c = 'test',
			StageName = 'Prospecting',
			Name = 'test opp',
			Product__c = 'None',
			Disable_for_KPI__c = FALSE,
			Last_Owner_Change_Date__c = Date.newinstance(2017, 12, 21),
			CloseDate = Date.newinstance(2017, 12, 28)
		);
		insert newOpp2;
	}

	private static void createEmailTemplate() {

		emailTemplateReject = new EmailTemplate(
			Name = 'test name',
			Subject = 'Reject Reopen',
			Body = 'test',
			TemplateType = 'Text',
			FolderId = u.Id,
			DeveloperName = 'Reject_reopen'
		);
		insert emailTemplateReject;

		emailTemplateApprove = new EmailTemplate(
			Name = 'test name',
			Subject = 'Approve Reopen',
			Body = 'test',
			TemplateType = 'Text',
			FolderId = u.Id,
			DeveloperName = 'Approve_reopen'
		);
		insert emailTemplateApprove;
	}
}