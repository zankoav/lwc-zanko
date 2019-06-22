@isTest
private class LeadRelocationBatchTest {
    @isTest
    public static void relocationTest() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Austria',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest2() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Germany',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest3() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Netherlands',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest4() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Poland',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;
		
		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest5() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Hungary',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest6() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'France',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest7() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Belgium-FR',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest8() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Belgium-NL',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest9() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Belgium-FR',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest10() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'France',
			Sec_Channel__c = 'JITB',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest11() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Netherlands',
			Sec_Channel__c = 'JITB',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest12() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Czech Republic',
			Sec_Channel__c = 'JITB',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest13() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Slovakia',
			Sec_Channel__c = 'JITB',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest14() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Hungary',
			Sec_Channel__c = 'JITB',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest15() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Poland',
			Sec_Channel__c = 'JITB',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest16() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Switzerland-IT',
			Sec_Channel__c = 'Partner',
			Channel__c = 'FLMT_Form',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest17() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Switzerland-DE',
			Sec_Channel__c = 'Partner',
			Channel__c = 'FLMT_Form',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest18() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Switzerland-FR',
			Sec_Channel__c = 'Partner',
			Channel__c = 'FLMT_Form',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest19() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Czech Republic',
			Sec_Channel__c = 'Partner',
			Channel__c = 'FLMT_Form',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest20() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Hungary',
			Sec_Channel__c = 'Partner',
			Channel__c = 'FLMT_Form',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest21() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'France',
			Sec_Channel__c = 'Partner',
			Channel__c = 'FLMT_Form',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest22() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Switzerland-DE',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest23() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Switzerland-IT',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest24() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Switzerland-FR',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest25() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Luxembourg',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest26() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Czech Republic',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest27() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Slovakia',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest28() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Switzerland-FR',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest29() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Belgium-FR',
			Sec_Channel__c = 'Partner',
			Channel__c = 'FLMT_Form',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest30() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Netherlands',
			Sec_Channel__c = 'Partner',
			Channel__c = 'FLMT_Form',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest31() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Slovakia',
			Sec_Channel__c = 'Partner',
			Channel__c = 'FLMT_Form',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

	@isTest
	public static void relocationTest32() {
        String IdRWL = [select id from group where name='Russian Web Leads'].id;
		Lead l = new Lead(
				LastName = 'test',
				Status = 'NEW - Not Yet Contacted',
				Country = 'Russia',
				Lead_Source_Type__C='Webform',
				Phone = '1',
				Company = 'test',
		        Source_of_Lead__c='Выставка',
                ownerid = IdRWL);
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
	}
}