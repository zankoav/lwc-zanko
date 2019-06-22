@isTest
private class UpdateContactPhoneFieldsBatchTest {
	@isTest
    static void testMethod1() {
        List<Contact> contactsToInsertList = new List<Contact>();

        Contact contactGermany = new Contact(
			Phone = '0049 176 31 157924',
			MobilePhone = '01702153391',
			Fax = '282245167',
			MailingCountry = 'Germany',
			MailingCountryCode = 'DE',
			LastName = 'test', 
			Salutation = 'Herr');
		contactsToInsertList.add(contactGermany);

		Contact contactAustria = new Contact(
			Phone = '0451 - 5040367',
			MobilePhone = '01702153391',
			Fax = '282245167',
			MailingCountry = 'Austria',
			MailingCountryCode = 'AT',
			LastName = 'test',
			Salutation = 'Herr');
		contactsToInsertList.add(contactAustria);

		Contact contactPoland = new Contact(
			Phone = '+48 22 0476 75 950',
			MobilePhone = '01702153391',
			Fax = '282245167',
			MailingCountry = 'Poland',
			MailingCountryCode = 'PL',
			LastName = 'test',
			Salutation = 'Herr');
		contactsToInsertList.add(contactPoland);

		Contact contactNetherlands = new Contact(
			Phone = '+31 7121 9615-121',
			MobilePhone = '01702153391',
			Fax = '282245167',
			MailingCountry = 'Netherlands',
			MailingCountryCode = 'NL',
			LastName = 'test',
			Salutation = 'Herr');
		contactsToInsertList.add(contactNetherlands);

		Contact contactBelgium = new Contact(
			Phone = '0911 / 9 79 00 90',
			MobilePhone = '01702153391',
			Fax = '282245167',
			MailingCountry = 'Belgium-NL',
			MailingCountryCode = 'BENL',
			LastName = 'test',
			Salutation = 'Herr');
		contactsToInsertList.add(contactBelgium);

		Contact contactFrance = new Contact(
			Phone = '02133-2652-0',
			MobilePhone = '01702153391',
			Fax = '282245167',
			MailingCountry = 'France',
			MailingCountryCode = 'FR',
			LastName = 'test',
			Salutation = 'Herr');
		contactsToInsertList.add(contactFrance);

		Contact contactHungary = new Contact(
			Phone = '00036 176 31 157924',
			MobilePhone = '01702153391',
			Fax = '282245167',
			MailingCountry = 'Hungary',
			MailingCountryCode = 'HU',
			LastName = 'test',
			Salutation = 'Herr');
		contactsToInsertList.add(contactHungary);

		Contact contactSwitzerland = new Contact(
			Phone = '4117631157924',
			MobilePhone = '01702153391',
			Fax = '282245167',
			MailingCountry = 'Switzerland-DE',
			MailingCountryCode = 'CHDE',
			LastName = 'test',
			Salutation = 'Herr');
		contactsToInsertList.add(contactSwitzerland);

		Contact contactLuxembourg = new Contact(
			Phone = '(0)176/31 157924',
			MobilePhone = '01702153391',
			Fax = '282245167',
			MailingCountry = 'Luxembourg',
			MailingCountryCode = 'LU',
			LastName = 'test',
			Salutation = 'Herr');
		contactsToInsertList.add(contactLuxembourg);

		Contact contactCzechRepublic = new Contact(
			Phone = '+420(0)17/6 31 157*924',
			MobilePhone = '01702153391',
			Fax = '282245167',
			MailingCountry = 'Czech Republic',
			MailingCountryCode = 'CZ',
			LastName = 'test',
			Salutation = 'Herr');
		contactsToInsertList.add(contactCzechRepublic);

		Contact contactSlovakia = new Contact(
			Phone = '042176 31 157924',
			MobilePhone = '01702153391',
			Fax = '282245167',
			MailingCountry = 'Slovakia',
			MailingCountryCode = 'SK',
			LastName = 'test',
			Salutation = 'Herr');
		contactsToInsertList.add(contactSlovakia);

        insert contactsToInsertList;

        Test.startTest();
	        UpdateContactPhoneFieldsBatch batch = new UpdateContactPhoneFieldsBatch();
	    	Database.executeBatch(batch);
    	Test.stopTest();

    	Set<Id> idsToTest = new Set<Id>();
		for (Contact currentCon : contactsToInsertList) {
			idsToTest.add(currentCon.Id);
		}

		Map<Id, Contact> contactsToTestMap = new Map<Id, Contact>([
				SELECT Phone, MobilePhone, Fax, MailingCountry
				FROM Contact
				WHERE Id IN :idsToTest
				LIMIT 10000]);

		// Germany
		System.assertEquals('+4917631157924', contactsToTestMap.get(contactGermany.Id).Phone);
		System.assertEquals('+491702153391', contactsToTestMap.get(contactGermany.Id).MobilePhone);
		System.assertEquals('+49282245167', contactsToTestMap.get(contactGermany.Id).Fax);

		// Austria 
		System.assertEquals('+434515040367', contactsToTestMap.get(contactAustria.Id).Phone);

		// Poland
		System.assertEquals('+4822047675950', contactsToTestMap.get(contactPoland.Id).Phone);

		// Netherlands
		System.assertEquals('+3171219615121', contactsToTestMap.get(contactNetherlands.Id).Phone);

		// Belgium-NL
		System.assertEquals('+329119790090', contactsToTestMap.get(contactBelgium.Id).Phone);

		// France
		System.assertEquals('+33213326520', contactsToTestMap.get(contactFrance.Id).Phone);

		// Hungary
		System.assertEquals('+3617631157924', contactsToTestMap.get(contactHungary.Id).Phone);

		// Switzerland-DE
		System.assertEquals('+4117631157924', contactsToTestMap.get(contactSwitzerland.Id).Phone);

		// Luxembourg
		System.assertEquals('+35217631157924', contactsToTestMap.get(contactLuxembourg.Id).Phone);

		// Czech Republic
		System.assertEquals('+42017631157924', contactsToTestMap.get(contactCzechRepublic.Id).Phone);

		// Slovakia
		System.assertEquals('+4217631157924', contactsToTestMap.get(contactSlovakia.Id).Phone);
    }
}