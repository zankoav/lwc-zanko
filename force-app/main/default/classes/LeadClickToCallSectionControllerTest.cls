@isTest
private class LeadClickToCallSectionControllerTest {
    @isTest
    private static void testDialoga() {
    	Test.setMock(HttpCalloutMock.class, new DialogaCalloutMock());
    	
    	Account newAccount = new Account(
    		Name = 'test');
    	insert newAccount;

		Lead lead = new Lead(
			Phone = '+049123123',
			Country = 'Germany',
			Company = 'test',
			MobilePhone = '123123, 123123',
			LastName = 'test');
		insert lead;

		ApexPages.CurrentPage().getparameters().put('id', lead.id);

		ApexPages.StandardController sc = new ApexPages.standardController(lead);
		LeadClickToCallSectionController sic = new LeadClickToCallSectionController(sc);
		sic.doDialogaCall();
    }

    @isTest
    private static void testSTD1() {
    	Account newAccount = new Account(
    		Name = 'test');
    	insert newAccount;

		Lead lead = new Lead(
			Phone = '+049123123',
			Country = 'Germany',
			Company = 'test',
			MobilePhone = '123123, 123123',
			LastName = 'test');
		insert lead;

		ApexPages.CurrentPage().getparameters().put('id', lead.id);

		ApexPages.StandardController sc = new ApexPages.standardController(lead);
		LeadClickToCallSectionController sic = new LeadClickToCallSectionController(sc);
		sic.makeacall();
    }

    @isTest
    private static void testSTD_Nederland() {
    	Account newAccount = new Account(
    		Name = 'test');
    	insert newAccount;

		Lead lead = new Lead(
			Phone = '+031(0)123123',
			Country = 'Netherlands',
			Company = 'test',
			MobilePhone = '123123, 123123',
			LastName = 'test');
		insert lead;

		ApexPages.CurrentPage().getparameters().put('id', lead.id);

		ApexPages.StandardController sc = new ApexPages.standardController(lead);
		LeadClickToCallSectionController sic = new LeadClickToCallSectionController(sc);
    }

    @isTest
    private static void testSTD_France() {
    	Account newAccount = new Account(
    		Name = 'test');
    	insert newAccount;

		Lead lead = new Lead(
			Phone = '+033(0)123123',
			Country = 'France',
			Company = 'test',
			MobilePhone = '123123, 123123',
			LastName = 'test');
		insert lead;

		ApexPages.CurrentPage().getparameters().put('id', lead.id);

		ApexPages.StandardController sc = new ApexPages.standardController(lead);
		LeadClickToCallSectionController sic = new LeadClickToCallSectionController(sc);
    }

    @isTest
    private static void testSTD_Osterreich() {
    	Account newAccount = new Account(
    		Name = 'test');
    	insert newAccount;

		Lead lead = new Lead(
			Phone = '+043(0)123123',
			Country = 'Austria',
			Company = 'test',
			MobilePhone = '123123, 123123',
			LastName = 'test');
		insert lead;

		ApexPages.CurrentPage().getparameters().put('id', lead.id);

		ApexPages.StandardController sc = new ApexPages.standardController(lead);
		LeadClickToCallSectionController sic = new LeadClickToCallSectionController(sc);
    }

    @isTest
    private static void testSTD_Polska() {
    	Account newAccount = new Account(
    		Name = 'test');
    	insert newAccount;

		Lead lead = new Lead(
			Phone = '+048(0)123123',
			Country = 'Poland',
			Company = 'test',
			MobilePhone = '123123, 123123',
			LastName = 'test');
		insert lead;

		ApexPages.CurrentPage().getparameters().put('id', lead.id);

		ApexPages.StandardController sc = new ApexPages.standardController(lead);
		LeadClickToCallSectionController sic = new LeadClickToCallSectionController(sc);
    }

    @isTest
    private static void testSTD_LU() {
    	Account newAccount = new Account(
    		Name = 'test');
    	insert newAccount;

		Lead lead = new Lead(
			Phone = '+0352(0)123123',
			Country = 'Luxembourg',
			Company = 'test',
			MobilePhone = '123123, 123123',
			LastName = 'test');
		insert lead;

		ApexPages.CurrentPage().getparameters().put('id', lead.id);

		ApexPages.StandardController sc = new ApexPages.standardController(lead);
		LeadClickToCallSectionController sic = new LeadClickToCallSectionController(sc);
    }

    @isTest
    private static void testSTD_CH() {
    	Account newAccount = new Account(
    		Name = 'test');
    	insert newAccount;

		Lead lead = new Lead(
			Phone = '+041(0)123123',
			Country = 'Switzerland-DE',
			Company = 'test',
			MobilePhone = '123123, 123123',
			LastName = 'test');
		insert lead;

		ApexPages.CurrentPage().getparameters().put('id', lead.id);

		ApexPages.StandardController sc = new ApexPages.standardController(lead);
		LeadClickToCallSectionController sic = new LeadClickToCallSectionController(sc);
    }

    @isTest
    private static void testSTD_CZ() {
    	Account newAccount = new Account(
    		Name = 'test');
    	insert newAccount;

		Lead lead = new Lead(
			Phone = '+0420(0)123123',
			Country = 'Czech Republic',
			Company = 'test',
			MobilePhone = '123123, 123123',
			LastName = 'test');
		insert lead;

		ApexPages.CurrentPage().getparameters().put('id', lead.id);

		ApexPages.StandardController sc = new ApexPages.standardController(lead);
		LeadClickToCallSectionController sic = new LeadClickToCallSectionController(sc);
    }

    @isTest
    private static void testSTD_SK() {
    	Account newAccount = new Account(
    		Name = 'test');
    	insert newAccount;

		Lead lead = new Lead(
			Phone = '+0421(0)123123',
			Country = 'Slovakia',
			Company = 'test',
			MobilePhone = '123123, 123123',
			LastName = 'test');
		insert lead;

		ApexPages.CurrentPage().getparameters().put('id', lead.id);

		ApexPages.StandardController sc = new ApexPages.standardController(lead);
		LeadClickToCallSectionController sic = new LeadClickToCallSectionController(sc);
    }

    @isTest
    private static void testSTD_BEFR() {
    	Account newAccount = new Account(
    		Name = 'test');
    	insert newAccount;

		Lead lead = new Lead(
			Phone = '+0421(0)123123',
			Country = 'Belgium-FR',
			Company = 'test',
			MobilePhone = '123123, 123123',
			LastName = 'test');
		insert lead;

		ApexPages.CurrentPage().getparameters().put('id', lead.id);

		ApexPages.StandardController sc = new ApexPages.standardController(lead);
		LeadClickToCallSectionController sic = new LeadClickToCallSectionController(sc);
    }

    @isTest
    private static void testSTD_HU() {
    	Account newAccount = new Account(
    		Name = 'test');
    	insert newAccount;

		Lead lead = new Lead(
			Phone = '+0421(0)123123',
			Country = 'Hungary',
			Company = 'test',
			MobilePhone = '123123, 123123',
			LastName = 'test');
		insert lead;

		ApexPages.CurrentPage().getparameters().put('id', lead.id);

		ApexPages.StandardController sc = new ApexPages.standardController(lead);
		LeadClickToCallSectionController sic = new LeadClickToCallSectionController(sc);
    }
}