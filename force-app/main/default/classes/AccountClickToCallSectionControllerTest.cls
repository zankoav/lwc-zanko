@isTest
private class AccountClickToCallSectionControllerTest {
    @isTest
    private static void testSTD1() {
    	Account newAccount = new Account(
    		Name = 'test',
    		BillingCountry = 'Germany',
    		Phone = '049123123');
    	insert newAccount;

		ApexPages.CurrentPage().getparameters().put('id', newAccount.id);

		ApexPages.StandardController sc = new ApexPages.standardController(newAccount);
		AccountClickToCallSectionController sic = new AccountClickToCallSectionController(sc);
    }

    @isTest
    private static void testSTD2() {
    	Account newAccount = new Account(
    		Name = 'test',
    		BillingCountry = 'Austria',
    		Phone = '049123123');
    	insert newAccount;

		ApexPages.CurrentPage().getparameters().put('id', newAccount.id);

		ApexPages.StandardController sc = new ApexPages.standardController(newAccount);
		AccountClickToCallSectionController sic = new AccountClickToCallSectionController(sc);
    }

    @isTest
    private static void testSTD3() {
    	Account newAccount = new Account(
    		Name = 'test',
    		BillingCountry = 'Poland',
    		Phone = '049123123');
    	insert newAccount;

		ApexPages.CurrentPage().getparameters().put('id', newAccount.id);

		ApexPages.StandardController sc = new ApexPages.standardController(newAccount);
		AccountClickToCallSectionController sic = new AccountClickToCallSectionController(sc);
    }    

    @isTest
    private static void testSTD4() {
    	Account newAccount = new Account(
    		Name = 'test',
    		BillingCountry = 'Netherlands',
    		Phone = '+049123123');
    	insert newAccount;

		ApexPages.CurrentPage().getparameters().put('id', newAccount.id);

		ApexPages.StandardController sc = new ApexPages.standardController(newAccount);
		AccountClickToCallSectionController sic = new AccountClickToCallSectionController(sc);
    } 

    @isTest
    private static void testSTD5() {
    	Account newAccount = new Account(
    		Name = 'test',
    		BillingCountry = 'Belgium-FR',
    		Phone = '+049123123');
    	insert newAccount;

		ApexPages.CurrentPage().getparameters().put('id', newAccount.id);

		ApexPages.StandardController sc = new ApexPages.standardController(newAccount);
		AccountClickToCallSectionController sic = new AccountClickToCallSectionController(sc);
    }    

    @isTest
    private static void testSTD6() {
    	Account newAccount = new Account(
    		Name = 'test',
    		BillingCountry = 'France',
    		Phone = '+049123123');
    	insert newAccount;

		ApexPages.CurrentPage().getparameters().put('id', newAccount.id);

		ApexPages.StandardController sc = new ApexPages.standardController(newAccount);
		AccountClickToCallSectionController sic = new AccountClickToCallSectionController(sc);
    } 

    @isTest
    private static void testSTD7() {
    	Account newAccount = new Account(
    		Name = 'test',
    		BillingCountry = 'Hungary',
    		Phone = '+049123123');
    	insert newAccount;

		ApexPages.CurrentPage().getparameters().put('id', newAccount.id);

		ApexPages.StandardController sc = new ApexPages.standardController(newAccount);
		AccountClickToCallSectionController sic = new AccountClickToCallSectionController(sc);
    } 

    @isTest
    private static void testSTD8() {
        Account newAccount = new Account(
            Name = 'test',
            BillingCountry = 'Luxembourg',
            Phone = '+0352123123');
        insert newAccount;

        ApexPages.CurrentPage().getparameters().put('id', newAccount.id);

        ApexPages.StandardController sc = new ApexPages.standardController(newAccount);
        AccountClickToCallSectionController sic = new AccountClickToCallSectionController(sc);
    } 

    @isTest
    private static void testSTD9() {
        Account newAccount = new Account(
            Name = 'test',
            BillingCountry = 'Czech Republic',
            Phone = '04202123123');
        insert newAccount;

        ApexPages.CurrentPage().getparameters().put('id', newAccount.id);

        ApexPages.StandardController sc = new ApexPages.standardController(newAccount);
        AccountClickToCallSectionController sic = new AccountClickToCallSectionController(sc);
    } 

    @isTest
    private static void testSTD10() {
        Account newAccount = new Account(
            Name = 'test',
            BillingCountry = 'Slovakia',
            Phone = '04212123123');
        insert newAccount;

        ApexPages.CurrentPage().getparameters().put('id', newAccount.id);

        ApexPages.StandardController sc = new ApexPages.standardController(newAccount);
        AccountClickToCallSectionController sic = new AccountClickToCallSectionController(sc);
    }

    @isTest
    private static void testSTD11() {
        Account newAccount = new Account(
            Name = 'test',
            BillingCountry = 'Switzerland-DE',
            Phone = '+04212123123');
        insert newAccount;

        ApexPages.CurrentPage().getparameters().put('id', newAccount.id);

        ApexPages.StandardController sc = new ApexPages.standardController(newAccount);
        AccountClickToCallSectionController sic = new AccountClickToCallSectionController(sc);
    }     
}