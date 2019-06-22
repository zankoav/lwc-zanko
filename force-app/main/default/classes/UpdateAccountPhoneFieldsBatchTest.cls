@isTest
private class UpdateAccountPhoneFieldsBatchTest {
	@isTest
    static void testMethod1() {
        List<Account> accountsToInsertList = new List<Account>();

        Account accountGermany = new Account(
			Phone = '0049 176 31 157924',
			CM_mobile__c = '01702153391',
			Fax = '282245167',
			BillingCountry = 'Germany',
			BillingCountryCode = 'DE',
			Name = 'test');
		accountsToInsertList.add(accountGermany);

		Account accountAustria = new Account(
			Phone = '0451 - 5040367',
			Phone_Crif__c = '01702153391',
			Fax = '282245167',
			BillingCountry = 'Austria',
			BillingCountryCode = 'AT',
			Name = 'test');
		accountsToInsertList.add(accountAustria);

		Account accountPoland = new Account(
			Phone = '+48 22 0476 75 950',
			SM_mobile__c = '01702153391',
			Fax = '282245167',
			BillingCountry = 'Poland',
			BillingCountryCode = 'PL',
			Name = 'test');
		accountsToInsertList.add(accountPoland);

		Account accountNetherlands = new Account(
			Phone = '+31 7121 9615-121',
			TM_mobile__c = '01702153391',
			Fax = '282245167',
			BillingCountry = 'Netherlands',
			BillingCountryCode = 'NL',
			Name = 'test');
		accountsToInsertList.add(accountNetherlands);

		Account accountBelgium = new Account(
			Phone = '0911 / 9 79 00 90',
			TM_mobile__c = '01702153391',
			Fax = '282245167',
			BillingCountry = 'Belgium-NL',
			BillingCountryCode = 'BENL',
			Name = 'test');
		accountsToInsertList.add(accountBelgium);

		Account accountFrance = new Account(
			Phone = '02133-2652-0',
			TM_mobile__c = '01702153391',
			Fax = '282245167',
			BillingCountry = 'France',
			BillingCountryCode = 'FR',
			Name = 'test');
		accountsToInsertList.add(accountFrance);

		Account accountHungary = new Account(
			Phone = '00036 176 31 157924',
			TM_mobile__c = '01702153391',
			Fax = '282245167',
			BillingCountry = 'Hungary',
			BillingCountryCode = 'HU',
			Name = 'test');
		accountsToInsertList.add(accountHungary);

		Account accountSwitzerland = new Account(
			Phone = '4117631157924',
			TM_mobile__c = '01702153391',
			Fax = '282245167',
			BillingCountry = 'Switzerland-DE',
			BillingCountryCode = 'CHDE',
			Name = 'test');
		accountsToInsertList.add(accountSwitzerland);

		Account accountLuxembourg = new Account(
			Phone = '(0)176/31 157924',
			TM_mobile__c = '01702153391',
			Fax = '282245167',
			BillingCountry = 'Luxembourg',
			BillingCountryCode = 'LU',
			Name = 'test');
		accountsToInsertList.add(accountLuxembourg);

		Account accountCzechRepublic = new Account(
			Phone = '+420(0)17/6 31 157*924',
			TM_mobile__c = '01702153391',
			Fax = '282245167',
			BillingCountry = 'Czech Republic',
			BillingCountryCode = 'CZ',
			Name = 'test');
		accountsToInsertList.add(accountCzechRepublic);

		Account accountSlovakia = new Account(
			Phone = '042176 31 157924',
			TM_mobile__c = '01702153391',
			Fax = '282245167',
			BillingCountry = 'Slovakia',
			BillingCountryCode = 'SK',
			Name = 'test');
		accountsToInsertList.add(accountSlovakia);

        insert accountsToInsertList;

        Test.startTest();
	        UpdateAccountPhoneFieldsBatch batch = new UpdateAccountPhoneFieldsBatch();
	    	Database.executeBatch(batch);
    	Test.stopTest();

    	Set<Id> idsToTest = new Set<Id>();
		for (Account currentAcc : accountsToInsertList) {
			idsToTest.add(currentAcc.Id);
		}

		Map<Id, Account> accountsToTestMap = new Map<Id, Account>([
				SELECT Fax, Phone, CM_mobile__c, Phone_Crif__c, SM_mobile__c, TM_mobile__c, BillingCountry
				FROM Account
				WHERE Id IN :idsToTest
				LIMIT 10000]);

		// Germany
		System.assertEquals('+4917631157924', accountsToTestMap.get(accountGermany.Id).Phone);
		System.assertEquals('+491702153391', accountsToTestMap.get(accountGermany.Id).CM_mobile__c);
		System.assertEquals('+49282245167', accountsToTestMap.get(accountGermany.Id).Fax);

		// Austria 
		System.assertEquals('+434515040367', accountsToTestMap.get(accountAustria.Id).Phone);

		// Poland
		System.assertEquals('+4822047675950', accountsToTestMap.get(accountPoland.Id).Phone);

		// Netherlands
		System.assertEquals('+3171219615121', accountsToTestMap.get(accountNetherlands.Id).Phone);

		// Belgium-NL
		System.assertEquals('+329119790090', accountsToTestMap.get(accountBelgium.Id).Phone);

		// France
		System.assertEquals('+33213326520', accountsToTestMap.get(accountFrance.Id).Phone);

		// Hungary
		System.assertEquals('+3617631157924', accountsToTestMap.get(accountHungary.Id).Phone);

		// Switzerland-DE
		System.assertEquals('+4117631157924', accountsToTestMap.get(accountSwitzerland.Id).Phone);

		// Luxembourg
		System.assertEquals('+35217631157924', accountsToTestMap.get(accountLuxembourg.Id).Phone);

		// Czech Republic
		System.assertEquals('+42017631157924', accountsToTestMap.get(accountCzechRepublic.Id).Phone);

		// Slovakia
		System.assertEquals('+4217631157924', accountsToTestMap.get(accountSlovakia.Id).Phone);
    }
}