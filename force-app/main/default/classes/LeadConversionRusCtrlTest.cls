/**
 * Created by ilja.garin on 27.07.2017.
 */
@isTest
public class LeadConversionRusCtrlTest {
	/*******************************************************************************
	*  Name            : testConvertLead()
	*  Summary         : test lead conversion if all required fields are filled, assigns tasks
						from lead to opportunity
	*  CreatedDate     : 31/08/2017
	*  Parameters      :
	*  Returns         : void
	******************************************************************************/
	@isTest
	static void testConvertLead() {
		RecordType rt = [
				SELECT Id
				FROM RecordType
				WHERE SObjectType = 'Lead' AND
				Name = 'Russian Sales'
		LIMIT 1];
		Lead lead = new Lead(
				LastName = 'Test',
				Company = 'Test',
				Country = 'Russia',
				Salutation = 'Mr.',
				INN__c = '123456789',
				Phone = '3242342',
				Email = 'mailtest@mail.ro',
				Region__c = 'Volga',
				RecordTypeId = rt.Id);
		insert lead;
		Task task = new Task(
				WhoId = lead.Id);
		insert task;
		ApexPages.CurrentPage().getparameters().put('id', lead.Id);
		LeadConversionRusCtrl controller = new LeadConversionRusCtrl();
		controller.init();
		Test.startTest();
			update lead;
			controller.continueConvert();
			controller.backToLeadWithSavingFields();
			controller.backToLeadWithoutSavingFields();
		Test.stopTest();
		List<Account> accountList = [
				SELECT ShippingStreet, BillingStreet
				FROM Account];
		System.assertEquals(accountList.size(), 1);
		System.assertEquals(accountList.get(0).BillingStreet, accountList.get(0).ShippingStreet);

		List<Contact> contactList = [
				SELECT Id
				FROM Contact];
		System.assertEquals(contactList.size(), 1);

		List<Opportunity> opportunityList = [
				SELECT Id
				FROM Opportunity];
		System.assertEquals(opportunityList.size(), 1);

		Task testTask = [
				SELECT WhoId, WhatId
				FROM Task];
		System.assertEquals(testTask.WhatId, opportunityList.get(0).Id);
		System.assertEquals(testTask.WhoId, contactList.get(0).Id);

	}
}