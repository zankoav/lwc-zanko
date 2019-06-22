@isTest
private class ContactClickToCallSectionControllerTest {
    @isTest
    private static void testSTD1() {
    	Contact newContact = new Contact(
    		LastName =  'test',
    		MailingCountry = 'Germany',
    		Salutation = 'Herr',
    		Phone = '+049123123');
    	insert newContact;

		ApexPages.CurrentPage().getparameters().put('id', newContact.id);

		ApexPages.StandardController sc = new ApexPages.standardController(newContact);
		ContactClickToCallSectionController sic = new ContactClickToCallSectionController(sc);
    }

    @isTest
    private static void testSTD2() {
    	Contact newContact = new Contact(
    		LastName =  'test',
    		MailingCountry = 'Austria',
    		Salutation = 'Herr',
    		Phone = '049123123');
    	insert newContact;

		ApexPages.CurrentPage().getparameters().put('id', newContact.id);

		ApexPages.StandardController sc = new ApexPages.standardController(newContact);
		ContactClickToCallSectionController sic = new ContactClickToCallSectionController(sc);
    }

    @isTest
    private static void testSTD3() {
    	Contact newContact = new Contact(
    		LastName =  'test',
    		MailingCountry = 'Poland',
    		Salutation = 'Herr',
    		Phone = '049123123');
    	insert newContact;

		ApexPages.CurrentPage().getparameters().put('id', newContact.id);

		ApexPages.StandardController sc = new ApexPages.standardController(newContact);
		ContactClickToCallSectionController sic = new ContactClickToCallSectionController(sc);
    }    

    @isTest
    private static void testSTD4() {
    	Contact newContact = new Contact(
    		LastName =  'test',
    		MailingCountry = 'Netherlands',
    		Salutation = 'Herr',
    		Phone = '+049123123');
    	insert newContact;

		ApexPages.CurrentPage().getparameters().put('id', newContact.id);

		ApexPages.StandardController sc = new ApexPages.standardController(newContact);
		ContactClickToCallSectionController sic = new ContactClickToCallSectionController(sc);
    } 

    @isTest
    private static void testSTD5() {
    	Contact newContact = new Contact(
    		LastName =  'test',
    		MailingCountry = 'Belgium-FR',
    		Salutation = 'Herr',
    		Phone = '+049123123');
    	insert newContact;

		ApexPages.CurrentPage().getparameters().put('id', newContact.id);

		ApexPages.StandardController sc = new ApexPages.standardController(newContact);
		ContactClickToCallSectionController sic = new ContactClickToCallSectionController(sc);
    }    

    @isTest
    private static void testSTD6() {
    	Contact newContact = new Contact(
    		LastName =  'test',
    		MailingCountry = 'France',
    		Salutation = 'Herr',
    		Phone = '+049123123');
    	insert newContact;

		ApexPages.CurrentPage().getparameters().put('id', newContact.id);

		ApexPages.StandardController sc = new ApexPages.standardController(newContact);
		ContactClickToCallSectionController sic = new ContactClickToCallSectionController(sc);
    } 

    @isTest
    private static void testSTD7() {
    	Contact newContact = new Contact(
    		LastName =  'test',
    		MailingCountry = 'Hungary',
    		Salutation = 'Herr',
    		Phone = '+049123123');
    	insert newContact;

		ApexPages.CurrentPage().getparameters().put('id', newContact.id);

		ApexPages.StandardController sc = new ApexPages.standardController(newContact);
		ContactClickToCallSectionController sic = new ContactClickToCallSectionController(sc);
    }

    @isTest
    private static void testSTD8() {
        Contact newContact = new Contact(
            LastName =  'test',
            MailingCountry = 'Luxembourg',
            Salutation = 'Herr',
            Phone = '+0352123123');
        insert newContact;

        ApexPages.CurrentPage().getparameters().put('id', newContact.id);

        ApexPages.StandardController sc = new ApexPages.standardController(newContact);
        ContactClickToCallSectionController sic = new ContactClickToCallSectionController(sc);
    }

    @isTest
    private static void testSTD9() {
        Contact newContact = new Contact(
            LastName =  'test',
            MailingCountry = 'Czech Republic',
            Salutation = 'Herr',
            Phone = '04202123123');
        insert newContact;

        ApexPages.CurrentPage().getparameters().put('id', newContact.id);

        ApexPages.StandardController sc = new ApexPages.standardController(newContact);
        ContactClickToCallSectionController sic = new ContactClickToCallSectionController(sc);
    }

    @isTest
    private static void testSTD10() {
        Contact newContact = new Contact(
            LastName =  'test',
            MailingCountry = 'Slovakia',
            Salutation = 'Herr',
            Phone = '04212123123');
        insert newContact;

        ApexPages.CurrentPage().getparameters().put('id', newContact.id);

        ApexPages.StandardController sc = new ApexPages.standardController(newContact);
        ContactClickToCallSectionController sic = new ContactClickToCallSectionController(sc);
    }

    @isTest
    private static void testSTD11() {
        Contact newContact = new Contact(
            LastName =  'test',
            MailingCountry = 'Switzerland-DE',
            Salutation = 'Herr',
            Phone = '+04212123123');
        insert newContact;

        ApexPages.CurrentPage().getparameters().put('id', newContact.id);

        ApexPages.StandardController sc = new ApexPages.standardController(newContact);
        ContactClickToCallSectionController sic = new ContactClickToCallSectionController(sc);
    }
}