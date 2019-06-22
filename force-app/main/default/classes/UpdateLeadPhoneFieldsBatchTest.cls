@isTest
private class UpdateLeadPhoneFieldsBatchTest {
	@isTest
    static void testMethod1() {
        List<Lead> leadsToInsertList = new List<Lead>();
		Lead leadGermany = new Lead(
			Phone = '+49(0)111111',
			MobilePhone = '4570273322v.Lead',
			Country = 'Germany',
			CountryCode = 'DE',
			Company = 'test',
			LastName = 'test');
		leadsToInsertList.add(leadGermany);

		Lead leadGermany2 = new Lead(
			Phone = '0111111',
			MobilePhone = '+49 232352588',
			Country = 'Germany',
			CountryCode = 'DE',
			Company = 'test',
			LastName = 'test');
		leadsToInsertList.add(leadGermany2);

		Lead leadGermany3 = new Lead(
			Phone = '0271 - 25093460',
			MobilePhone = '4912345',
			Country = 'Germany',
			CountryCode = 'DE',
			Company = 'test',
			LastName = 'test');
		leadsToInsertList.add(leadGermany3);

		Lead leadGermany4 = new Lead(
			Phone = '*49413781401',
			MobilePhone = '0271 - 25093460',
			Country = 'Germany',
			CountryCode = 'DE',
			Company = 'test',
			LastName = 'test');
		leadsToInsertList.add(leadGermany4);

		Lead leadGermany5 = new Lead(
			Phone = '49(0)70 41 802-0',
			MobilePhone = '0271 - 25093460',
			Country = 'Germany',
			CountryCode = 'DE',
			Company = 'test',
			LastName = 'test');
		leadsToInsertList.add(leadGermany5);

		Lead leadGermany6 = new Lead(
			Phone = 'Tel.08741/306333',
			MobilePhone = '(0) 2154 - 208 36 - 8',
			Country = 'Germany',
			CountryCode = 'DE',
			Company = 'test',
			LastName = 'test');
		leadsToInsertList.add(leadGermany6);

		Lead leadAustria = new Lead(
			Phone = '0043222222',
			MobilePhone = '71 61 - 99 06 66',
			Country = 'Austria',
			CountryCode = 'AT',
			Company = 'test',
			LastName = 'test');
		leadsToInsertList.add(leadAustria);

		Lead leadPoland = new Lead(
			Phone = '48(0)333333',
			MobilePhone = '0048',
			Country = 'Poland',
			CountryCode = 'PL',
			Company = 'test',
			LastName = 'test');
		leadsToInsertList.add(leadPoland);

		Lead leadNetherlands = new Lead(
			Phone = '00031444444',
			MobilePhone = '+ 31 40 38 108 - 0',
			Country = 'Netherlands',
			CountryCode = 'NL',
			Company = 'test',
			LastName = 'test');
		leadsToInsertList.add(leadNetherlands);

		Lead leadBelgium = new Lead(
			Phone = '55555555',
			MobilePhone = '55555555',
			Country = 'Belgium-FR',
			CountryCode = 'BEFR',
			Company = 'test',
			LastName = 'test');
		leadsToInsertList.add(leadBelgium);

		Lead leadFrance = new Lead(
			Phone = '66666666',
			MobilePhone = '++3330555797381',
			Country = 'France',
			CountryCode = 'FR',
			Company = 'test',
			LastName = 'test');
		leadsToInsertList.add(leadFrance);

		Lead leadHungary = new Lead(
			Phone = '+79051111111',
			MobilePhone = 'x',
			Country = 'Hungary',
			CountryCode = 'HU',
			Company = 'test',
			LastName = 'test');
		leadsToInsertList.add(leadHungary);

		Lead leadSwitzerland = new Lead(
			Phone = '(0 22 03) 9 08 95 40',
			MobilePhone = '',
			Country = 'Switzerland-DE',
			CountryCode = 'CHDE',
			Company = 'test',
			LastName = 'test');
		leadsToInsertList.add(leadSwitzerland);

		Lead leadLuxembourg = new Lead(
			Phone = '+352(0)888888',
			MobilePhone = '5555',
			Country = 'Luxembourg',
			CountryCode = 'LU',
			Company = 'test',
			LastName = 'test');
		leadsToInsertList.add(leadLuxembourg);

		Lead leadCzech = new Lead(
			Phone = '000420999999',
			MobilePhone = '+4206641654556',
			Country = 'Czech Republic',
			CountryCode = 'CZ',
			Company = 'test',
			LastName = 'test');
		leadsToInsertList.add(leadCzech);

		Lead leadSlovakia = new Lead(
			Phone = '+4215555555',
			MobilePhone = '+42155(55555)',
			Country = 'Slovakia',
			CountryCode = 'SK',
			Company = 'test',
			LastName = 'test');
		leadsToInsertList.add(leadSlovakia);

		Lead leadSlovakia2 = new Lead(
			Phone = '4567654',
			MobilePhone = '040 / 55 20 36-42',
			Country = 'Slovakia',
			CountryCode = 'SK',
			Company = 'test',
			LastName = 'test');
		leadsToInsertList.add(leadSlovakia2);

		insert leadsToInsertList;

		Test.startTest();
	        UpdateLeadPhoneFieldsBatch batch = new UpdateLeadPhoneFieldsBatch();
	    	Database.executeBatch(batch);
    	Test.stopTest();

    	Set<Id> idsToTest = new Set<Id>();
		for (Lead currentLead : leadsToInsertList) {
			idsToTest.add(currentLead.Id);
		}

		Map<Id, Lead> leadsToTestMap = new Map<Id, Lead>([
				SELECT Phone, MobilePhone
				FROM Lead
				WHERE Id IN :idsToTest
				LIMIT 10000]);

		// Germany
		System.assertEquals('+49111111', leadsToTestMap.get(leadGermany.Id).Phone);
		System.assertEquals('4570273322v.Lead', leadsToTestMap.get(leadGermany.Id).MobilePhone);
		System.assertEquals('+49111111', leadsToTestMap.get(leadGermany2.Id).Phone);
		System.assertEquals('+49232352588', leadsToTestMap.get(leadGermany2.Id).MobilePhone);
		System.assertEquals('+4927125093460', leadsToTestMap.get(leadGermany3.Id).Phone);
		System.assertEquals('+4912345', leadsToTestMap.get(leadGermany3.Id).MobilePhone);
		System.assertEquals('+49413781401', leadsToTestMap.get(leadGermany4.Id).Phone);
		System.assertEquals('+4970418020', leadsToTestMap.get(leadGermany5.Id).Phone);
		System.assertEquals('Tel.08741/306333', leadsToTestMap.get(leadGermany6.Id).Phone);
		System.assertEquals('+492154208368', leadsToTestMap.get(leadGermany6.Id).MobilePhone);
		// Austria
		System.assertEquals('+43222222', leadsToTestMap.get(leadAustria.Id).Phone);
		System.assertEquals('+437161990666', leadsToTestMap.get(leadAustria.Id).MobilePhone);
		// Poland
		System.assertEquals('+48333333', leadsToTestMap.get(leadPoland.Id).Phone);
		System.assertEquals('+48', leadsToTestMap.get(leadPoland.Id).MobilePhone);
		// Netherlands
		System.assertEquals('+31444444', leadsToTestMap.get(leadNetherlands.Id).Phone);
		System.assertEquals('+3140381080', leadsToTestMap.get(leadNetherlands.Id).MobilePhone);
		// Belgium-FR
		System.assertEquals('+3255555555', leadsToTestMap.get(leadBelgium.Id).Phone);
		// France
		System.assertEquals('+3366666666', leadsToTestMap.get(leadFrance.Id).Phone);
		System.assertEquals('++3330555797381', leadsToTestMap.get(leadFrance.Id).MobilePhone);
		// Hungary
		System.assertEquals('+79051111111', leadsToTestMap.get(leadHungary.Id).Phone);
		System.assertEquals('x', leadsToTestMap.get(leadHungary.Id).MobilePhone);
		// Switzerland-DE
		System.assertEquals('+4122039089540', leadsToTestMap.get(leadSwitzerland.Id).Phone);
		System.assertEquals(null, leadsToTestMap.get(leadSwitzerland.Id).MobilePhone);
		// Luxembourg
		System.assertEquals('+352888888', leadsToTestMap.get(leadLuxembourg.Id).Phone);
		System.assertEquals('+3525555', leadsToTestMap.get(leadLuxembourg.Id).MobilePhone);
		// Czech Republic
		System.assertEquals('+420999999', leadsToTestMap.get(leadCzech.Id).Phone);
		System.assertEquals('+4206641654556', leadsToTestMap.get(leadCzech.Id).MobilePhone);
		// Slovakia
		System.assertEquals('+4215555555', leadsToTestMap.get(leadSlovakia.Id).Phone);
		System.assertEquals('+4215555555', leadsToTestMap.get(leadSlovakia.Id).MobilePhone);
		System.assertEquals('+4214567654', leadsToTestMap.get(leadSlovakia2.Id).Phone);
		System.assertEquals('+4214055203642', leadsToTestMap.get(leadSlovakia2.Id).MobilePhone);
    }
}