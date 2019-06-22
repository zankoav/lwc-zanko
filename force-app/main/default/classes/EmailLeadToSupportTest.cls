@isTest
public class EmailLeadToSupportTest {
	@isTest
	public static void myTest() {
		Lead l = new Lead(
			LastName = 'test',
			Country = 'Austria',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test',
			Description = 'test');
		insert l;
		Apexpages.currentPage().getParameters().put('leadId', l.Id);

		EmailLeadToSupport controller = new EmailLeadToSupport();
		controller.sendEmailToSupport();
	}

	@isTest
	public static void myTest2() {
		Lead l = new Lead(
			LastName = 'test',
			Country = 'Belgium-NL',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test',
			Description = 'test');
		insert l;
		Apexpages.currentPage().getParameters().put('leadId', l.Id);

		EmailLeadToSupport controller = new EmailLeadToSupport();
		controller.sendEmailToSupport();
	}

	@isTest
	public static void myTest3() {
		Lead l = new Lead(
			LastName = 'test',
			Country = 'Belgium-FR',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test',
			Description = 'test');
		insert l;
		Apexpages.currentPage().getParameters().put('leadId', l.Id);

		EmailLeadToSupport controller = new EmailLeadToSupport();
		controller.sendEmailToSupport();
	}

	@isTest
	public static void myTest4() {
		Lead l = new Lead(
			LastName = 'test',
			Country = 'Netherlands',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test',
			Description = 'test');
		insert l;
		Apexpages.currentPage().getParameters().put('leadId', l.Id);

		EmailLeadToSupport controller = new EmailLeadToSupport();
		controller.sendEmailToSupport();
	}


	@isTest
	public static void myTest5() {
		Lead l = new Lead(
			LastName = 'test',
			Country = 'France',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test',
			Description = 'test');
		insert l;
		Apexpages.currentPage().getParameters().put('leadId', l.Id);

		EmailLeadToSupport controller = new EmailLeadToSupport();
		controller.sendEmailToSupport();
	}


	@isTest
	public static void myTest6() {
		Lead l = new Lead(
			LastName = 'test',
			Country = 'Hungary',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test',
			Description = 'test');
		insert l;
		Apexpages.currentPage().getParameters().put('leadId', l.Id);

		EmailLeadToSupport controller = new EmailLeadToSupport();
		controller.sendEmailToSupport();
	}

	@isTest
	public static void myTest7() {
		Lead l = new Lead(
			LastName = 'test',
			Country = 'Poland',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test',
			Description = 'test');
		insert l;
		Apexpages.currentPage().getParameters().put('leadId', l.Id);

		EmailLeadToSupport controller = new EmailLeadToSupport();
		controller.sendEmailToSupport();
	}

	@isTest
	public static void myTest8() {
		Lead l = new Lead(
			LastName = 'test',
			Country = 'Germany',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test',
			Description = 'test');
		insert l;
		Apexpages.currentPage().getParameters().put('leadId', l.Id);

		EmailLeadToSupport controller = new EmailLeadToSupport();
		controller.sendEmailToSupport();
	}

	@isTest
	public static void myTest9() {
		Lead l = new Lead(
			LastName = 'test',
			Country = 'Slovakia',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test',
			Description = 'test');
		insert l;
		Apexpages.currentPage().getParameters().put('leadId', l.Id);

		EmailLeadToSupport controller = new EmailLeadToSupport();
		controller.sendEmailToSupport();
	}

	@isTest
	public static void myTest10() {
		Lead l = new Lead(
			LastName = 'test',
			Country = 'Czech Republic',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test',
			Description = 'test');
		insert l;
		Apexpages.currentPage().getParameters().put('leadId', l.Id);

		EmailLeadToSupport controller = new EmailLeadToSupport();
		controller.sendEmailToSupport();
	}

	@isTest
	public static void myTest11() {
		Lead l = new Lead(
			LastName = 'test',
			Country = 'Luxembourg',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test',
			Description = 'test');
		insert l;
		Apexpages.currentPage().getParameters().put('leadId', l.Id);

		EmailLeadToSupport controller = new EmailLeadToSupport();
		controller.sendEmailToSupport();
	}

	@isTest
	public static void myTest12() {
		Lead l = new Lead(
			LastName = 'test',
			Country = 'Switzerland-IT',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test',
			Description = 'test');
		insert l;
		Apexpages.currentPage().getParameters().put('leadId', l.Id);

		EmailLeadToSupport controller = new EmailLeadToSupport();
		controller.sendEmailToSupport();
	}

	@isTest
	public static void myTest13() {
		Lead l = new Lead(
			LastName = 'test',
			Country = 'Switzerland-FR',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test',
			Description = 'test');
		insert l;
		Apexpages.currentPage().getParameters().put('leadId', l.Id);

		EmailLeadToSupport controller = new EmailLeadToSupport();
		controller.sendEmailToSupport();
	}

	@isTest
	public static void myTest14() {
		Lead l = new Lead(
			LastName = 'test',
			Country = 'Switzerland-DE',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test',
			Description = 'test');
		insert l;
		Apexpages.currentPage().getParameters().put('leadId', l.Id);

		EmailLeadToSupport controller = new EmailLeadToSupport();
		controller.sendEmailToSupport();
	}
}