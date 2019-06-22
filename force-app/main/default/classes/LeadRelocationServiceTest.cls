@isTest
private class LeadRelocationServiceTest {
	@isTest
	public static void testService() {
		List<Lead> leadsToInsert = new List<Lead>();

		Lead l = new Lead(
			LastName = 'test',
			CountryCode = 'AT',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l);

		Lead l2 = new Lead(
			LastName = 'test',
			CountryCode = 'DE',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l2);

		Lead l3 = new Lead(
			LastName = 'test',
			CountryCode = 'PL',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l3);

		Lead l4 = new Lead(
			LastName = 'test',
			CountryCode = 'FR',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l4);

		Lead l5 = new Lead(
			LastName = 'test',
			CountryCode = 'HU',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l5);

		Lead l6 = new Lead(
			LastName = 'test',
			CountryCode = 'NL',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l6);

		Lead l7 = new Lead(
			LastName = 'test',
			CountryCode = 'BEFR',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l7);

		Lead l9 = new Lead(
			LastName = 'test',
			CountryCode = 'CHDE',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l9);

		Lead l10 = new Lead(
			LastName = 'test',
			CountryCode = 'CHIT',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l10);

		Lead l11 = new Lead(
			LastName = 'test',
			CountryCode = 'CHFR',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l11);

		Lead l12 = new Lead(
			LastName = 'test',
			CountryCode = 'LU',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l12);

		Lead l13 = new Lead(
			LastName = 'test',
			CountryCode = 'CZ',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l13);

		Lead l14 = new Lead(
			LastName = 'test',
			CountryCode = 'SK',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l14);

		Lead l15 = new Lead(
			LastName = 'test',
			CountryCode = 'BENL',
			Sec_Channel__c = 'JITB',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l15);

		Lead l16 = new Lead(
			LastName = 'test',
			CountryCode = 'BEFR',
			Sec_Channel__c = 'JITB',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l16);

		Lead l17 = new Lead(
			LastName = 'test',
			CountryCode = 'FR',
			Sec_Channel__c = 'JITB',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l17);

		Lead l18 = new Lead(
			LastName = 'test',
			CountryCode = 'NL',
			Sec_Channel__c = 'JITB',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l18);

		Lead l19 = new Lead(
			LastName = 'test',
			CountryCode = 'CZ',
			Sec_Channel__c = 'JITB',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l19);

		Lead l20 = new Lead(
			LastName = 'test',
			CountryCode = 'SK',
			Sec_Channel__c = 'JITB',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l20);

		Lead l21 = new Lead(
			LastName = 'test',
			CountryCode = 'HU',
			Sec_Channel__c = 'JITB',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l21);

		Lead l22 = new Lead(
			LastName = 'test',
			CountryCode = 'PL',
			Sec_Channel__c = 'JITB',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');

		Lead l23 = new Lead(
			LastName = 'test',
			CountryCode = 'SK',
			Sec_Channel__c = 'Partner',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l23);

		Lead l24 = new Lead(
			LastName = 'test',
			CountryCode = 'HU',
			Sec_Channel__c = 'Partner',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l24);

		Lead l25 = new Lead(
			LastName = 'test',
			CountryCode = 'PL',
			Sec_Channel__c = 'Partner',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l25);

		Lead l26 = new Lead(
			LastName = 'test',
			CountryCode = 'DE',
			Sec_Channel__c = 'Partner',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l26);

		Lead l27 = new Lead(
			LastName = 'test',
			CountryCode = 'AT',
			Sec_Channel__c = 'Partner',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l27);

		Lead l28 = new Lead(
			LastName = 'test',
			CountryCode = 'CHDE',
			Sec_Channel__c = 'Partner',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l28);

		Lead l29 = new Lead(
			LastName = 'test',
			CountryCode = 'BENL',
			Sec_Channel__c = 'Partner',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l29);

		Lead l30 = new Lead(
			LastName = 'test',
			CountryCode = 'NL',
			Sec_Channel__c = 'Partner',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l30);

		Lead l31 = new Lead(
			LastName = 'test',
			CountryCode = 'BEFR',
			Sec_Channel__c = 'Partner',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l31);

		Lead l32 = new Lead(
				LastName = 'test',
				CountryCode = 'RU',
				Country = 'Russia',
				Lead_Source_Type__c = 'Webform',
				Phone = '1231231231',
				Company = 'test');
		leadsToInsert.add(l32);

		Lead l33 = new Lead(
				LastName = 'test',
				CountryCode = 'RU',
				Country = 'Russia',
				Lead_Source_Type__c = 'Email',
				Phone = '1231231231',
				Company = 'test');
		leadsToInsert.add(l33);

		Lead l34 = new Lead(
				LastName = 'test',
				CountryCode = 'RU',
				Country = 'Russia',
				Lead_Source_Type__c = 'Chat',
				Phone = '1231231231',
				Company = 'test');
		leadsToInsert.add(l34);

		Lead l35 = new Lead(
				LastName = 'test',
				CountryCode = 'RU',
				Country = 'Russia',
				Lead_Source_Type__c = 'Popup',
				Phone = '1231231231',
				Company = 'test');
		leadsToInsert.add(l35);
		insert leadsToInsert;

		Datetime dd = Datetime.now().addMinutes(-15);
		for (Lead ll : leadsToInsert) {
			Test.setCreatedDate(ll.Id, dd);
		}

		Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
		User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
		EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
		LocaleSidKey='en_US', ProfileId = p.Id,
		TimeZoneSidKey='America/Los_Angeles', UserName='standarduser-flt123@testorg.com');
		insert u;

		for (Lead ll : leadsToInsert) {
			ll.OwnerId = u.Id;
		}

		update leadsToInsert;
	}
}