@isTest
private class EmarsysLogCheckerScheduleTest {
	@testSetup
	static void createData() {
		// ---------------------- Leads ---------------------- //
		String endkundeRecId = GlobalUtils.returnRecordTypeId('Lead', 'Endkunde');
		List<Lead> leadsToInsertList = new List<Lead>();
		Lead facebookDELead = new Lead(
            LastName = 'test',
            Company = 'test',
            Country = 'Germany',
            LeadSource = 'Facebook', 
            Quali_Status__c = 'Switched to E2E', 
            CreatedDate = Datetime.now().addDays(-15),
            RecordTypeId = endkundeRecId);
        leadsToInsertList.add(facebookDELead);

        Lead inboundCallNLLead = new Lead(
            LastName = 'test',
            Company = 'test',
            Country = 'Netherlands',
            LeadSource = 'Inbound Call', 
            Quali_Status__c = 'Switched to E2E', 
            CreatedDate = Datetime.now().addDays(-15),
            RecordTypeId = endkundeRecId);
        leadsToInsertList.add(inboundCallNLLead);

        Lead shellNLLead = new Lead(
            LastName = 'test',
            Company = 'test',
            Country = 'Netherlands',
            LeadSource = 'Shell Email', 
            Quali_Status__c = 'Switched to E2E', 
            CreatedDate = Datetime.now().addDays(-15),
            RecordTypeId = endkundeRecId);
        leadsToInsertList.add(shellNLLead);

        Lead inboundEmailBENLLead = new Lead(
            LastName = 'test',
            Company = 'test',
            Country = 'Belgium-NL',
            LeadSource = 'Inbound Email', 
            Quali_Status__c = 'Switched to E2E', 
            CreatedDate = Datetime.now().addDays(-15),
            RecordTypeId = endkundeRecId);
        leadsToInsertList.add(inboundEmailBENLLead);

        Lead inboundEmailBEFRLead = new Lead(
            LastName = 'test',
            Company = 'test',
            Country = 'Belgium-FR',
            LeadSource = 'Inbound Email', 
            Quali_Status__c = 'Switched to E2E', 
            CreatedDate = Datetime.now().addDays(-15),
            RecordTypeId = endkundeRecId);
        leadsToInsertList.add(inboundEmailBEFRLead);

        Lead otherChannelPLLead = new Lead(
            LastName = 'test',
            Company = 'test',
            Country = 'Poland',
            Email = 'test@test.com',
            Sec_Channel__c = 'JITB',
            Quali_Status__c = 'Switched to E2E', 
            CreatedDate = Datetime.now().addDays(-15),
            RecordTypeId = endkundeRecId);
        leadsToInsertList.add(otherChannelPLLead);

        Lead otherChannelHULead = new Lead(
            LastName = 'test',
            Company = 'test',
            Country = 'Hungary',
            Email = 'test@test.com',
            Sec_Channel__c = 'JITB',
            Quali_Status__c = 'Switched to E2E', 
            CreatedDate = Datetime.now().addDays(-15),
            RecordTypeId = endkundeRecId);
        leadsToInsertList.add(otherChannelHULead);

        // Leads with wrong emarsys
        // Germany
        Lead facebookDELead1 = new Lead(
            LastName = 'test',
            Company = 'test',
            Country = 'Germany',
            LeadSource = 'Facebook', 
            Quali_Status__c = 'Switched to E2E', 
            CreatedDate = Datetime.now().addDays(-15),
            RecordTypeId = endkundeRecId);
        leadsToInsertList.add(facebookDELead1);

        Lead inboundCallDELead1 = new Lead(
            LastName = 'test',
            Company = 'test',
            Country = 'Germany',
            LeadSource = 'Inbound Call', 
            Quali_Status__c = 'Switched to E2E', 
            CreatedDate = Datetime.now().addDays(-15),
            RecordTypeId = endkundeRecId);
        leadsToInsertList.add(inboundCallDELead1);

        Lead inboundEmailDELead1 = new Lead(
            LastName = 'test',
            Company = 'test',
            Country = 'Germany',
            LeadSource = 'Inbound Email', 
            Quali_Status__c = 'Switched to E2E', 
            CreatedDate = Datetime.now().addDays(-15),
            RecordTypeId = endkundeRecId);
        leadsToInsertList.add(inboundEmailDELead1);

        Lead otherChannelDELead1 = new Lead(
            LastName = 'test',
            Company = 'test',
            Country = 'Germany',
            Email = 'test@test.com',
            Sec_Channel__c = 'JITB',
            Quali_Status__c = 'Switched to E2E', 
            CreatedDate = Datetime.now().addDays(-15),
            RecordTypeId = endkundeRecId);
        leadsToInsertList.add(otherChannelDELead1);

        // Netherlands 
        Lead facebookNLLead2 = new Lead(
            LastName = 'test',
            Company = 'test',
            Country = 'Netherlands',
            LeadSource = 'Facebook', 
            Quali_Status__c = 'Switched to E2E', 
            CreatedDate = Datetime.now().addDays(-15),
            RecordTypeId = endkundeRecId);
        leadsToInsertList.add(facebookNLLead2);

        Lead inboundCallNLLead2 = new Lead(
            LastName = 'test',
            Company = 'test',
            Country = 'Netherlands',
            LeadSource = 'Inbound Call', 
            Quali_Status__c = 'Switched to E2E', 
            CreatedDate = Datetime.now().addDays(-15),
            RecordTypeId = endkundeRecId);
        leadsToInsertList.add(inboundCallNLLead2);

        Lead inboundEmailNLLead2 = new Lead(
            LastName = 'test',
            Company = 'test',
            Country = 'Netherlands',
            LeadSource = 'Inbound Email', 
            Quali_Status__c = 'Switched to E2E', 
            CreatedDate = Datetime.now().addDays(-15),
            RecordTypeId = endkundeRecId);
        leadsToInsertList.add(inboundEmailNLLead2);

        Lead shellEmailNLLead2 = new Lead(
            LastName = 'test',
            Company = 'test',
            Country = 'Netherlands',
            Email = 'test@test.com',
            LeadSource = 'Shell Email',
            Quali_Status__c = 'Switched to E2E', 
            CreatedDate = Datetime.now().addDays(-15),
            RecordTypeId = endkundeRecId);
        leadsToInsertList.add(shellEmailNLLead2);

        // Belgium-NL 
        Lead facebookNBELLead3 = new Lead(
            LastName = 'test',
            Company = 'test',
            Country = 'Belgium-NL',
            LeadSource = 'Facebook', 
            Quali_Status__c = 'Switched to E2E', 
            CreatedDate = Datetime.now().addDays(-15),
            RecordTypeId = endkundeRecId);
        leadsToInsertList.add(facebookNBELLead3);

        Lead inboundCallBENLLead3 = new Lead(
            LastName = 'test',
            Company = 'test',
            Country = 'Belgium-NL',
            LeadSource = 'Inbound Call', 
            Quali_Status__c = 'Switched to E2E', 
            CreatedDate = Datetime.now().addDays(-15),
            RecordTypeId = endkundeRecId);
        leadsToInsertList.add(inboundCallBENLLead3);

        Lead inboundEmailBENLLead3 = new Lead(
            LastName = 'test',
            Company = 'test',
            Country = 'Belgium-NL',
            LeadSource = 'Inbound Email', 
            Quali_Status__c = 'Switched to E2E', 
            CreatedDate = Datetime.now().addDays(-15),
            RecordTypeId = endkundeRecId);
        leadsToInsertList.add(inboundEmailBENLLead3);

        Lead shellEmailBENLLead3 = new Lead(
            LastName = 'test',
            Company = 'test',
            Country = 'Belgium-NL',
            Email = 'test@test.com',
            LeadSource = 'Shell Email',
            Quali_Status__c = 'Switched to E2E', 
            CreatedDate = Datetime.now().addDays(-15),
            RecordTypeId = endkundeRecId);
        leadsToInsertList.add(shellEmailBENLLead3);

        // Belgium-FR 
        Lead facebookBEFRLead4 = new Lead(
            LastName = 'test',
            Company = 'test',
            Country = 'Belgium-FR',
            LeadSource = 'Facebook', 
            Quali_Status__c = 'Switched to E2E', 
            CreatedDate = Datetime.now().addDays(-15),
            RecordTypeId = endkundeRecId);
        leadsToInsertList.add(facebookBEFRLead4);

        Lead inboundCallBEFRLead4 = new Lead(
            LastName = 'test',
            Company = 'test',
            Country = 'Belgium-FR',
            LeadSource = 'Inbound Call', 
            Quali_Status__c = 'Switched to E2E', 
            CreatedDate = Datetime.now().addDays(-15),
            RecordTypeId = endkundeRecId);
        leadsToInsertList.add(inboundCallBEFRLead4);

        Lead inboundEmailBEFRLead4 = new Lead(
            LastName = 'test',
            Company = 'test',
            Country = 'Belgium-FR',
            LeadSource = 'Inbound Email', 
            Quali_Status__c = 'Switched to E2E', 
            CreatedDate = Datetime.now().addDays(-15),
            RecordTypeId = endkundeRecId);
        leadsToInsertList.add(inboundEmailBEFRLead4);

        Lead shellEmailBEFRLead4 = new Lead(
            LastName = 'test',
            Company = 'test',
            Country = 'Belgium-FR',
            Email = 'test@test.com',
            LeadSource = 'Shell Email',
            Quali_Status__c = 'Switched to E2E', 
            CreatedDate = Datetime.now().addDays(-15),
            RecordTypeId = endkundeRecId);
        leadsToInsertList.add(shellEmailBEFRLead4);

        // Poland
		Lead otherChannelPLLead5 = new Lead(
            LastName = 'test',
            Company = 'test',
            Country = 'Poland',
            Email = 'test@test.com',
            Sec_Channel__c = 'JITB',
            Quali_Status__c = 'Switched to E2E', 
            CreatedDate = Datetime.now().addDays(-15),
            RecordTypeId = endkundeRecId);
        leadsToInsertList.add(otherChannelPLLead5);

        // Hungary
		Lead otherChannelHULead6 = new Lead(
            LastName = 'test',
            Company = 'test',
            Country = 'Hungary',
            Email = 'test@test.com',
            Sec_Channel__c = 'JITB',
            Quali_Status__c = 'Switched to E2E', 
            CreatedDate = Datetime.now().addDays(-15),
            RecordTypeId = endkundeRecId);
        leadsToInsertList.add(otherChannelHULead6);

        insert leadsToInsertList;

        List<Emarsys_Log__c> emarsysLogsList = new List<Emarsys_Log__c>();
        // Germany logs
        Emarsys_Log__c facebookDELog = new Emarsys_Log__c(
        	Email_Name__c = 'test', 
        	CreatedDate = Datetime.now().addDays(-7), 
        	Lead__c = facebookDELead1.Id);
        emarsysLogsList.add(facebookDELog);

        Emarsys_Log__c inboundCallDELog = new Emarsys_Log__c(
        	Email_Name__c = 'test', 
        	CreatedDate = Datetime.now().addDays(-7), 
        	Lead__c = inboundCallDELead1.Id);
        emarsysLogsList.add(inboundCallDELog);

        Emarsys_Log__c inboundEmailDELog = new Emarsys_Log__c(
        	Email_Name__c = 'test', 
        	CreatedDate = Datetime.now().addDays(-7), 
        	Lead__c = inboundEmailDELead1.Id);
        emarsysLogsList.add(inboundEmailDELog);

        Emarsys_Log__c otherChannelDELog = new Emarsys_Log__c(
        	Email_Name__c = 'test', 
        	CreatedDate = Datetime.now().addDays(-7), 
        	Lead__c = otherChannelDELead1.Id);
        emarsysLogsList.add(otherChannelDELog);

        // Netherlands logs
        Emarsys_Log__c facebookNLLog = new Emarsys_Log__c(
        	Email_Name__c = 'test', 
        	CreatedDate = Datetime.now().addDays(-7), 
        	Lead__c = facebookNLLead2.Id);
        emarsysLogsList.add(facebookNLLog);

        Emarsys_Log__c inboundCallNLLog = new Emarsys_Log__c(
        	Email_Name__c = 'test', 
        	CreatedDate = Datetime.now().addDays(-7), 
        	Lead__c = inboundCallNLLead2.Id);
        emarsysLogsList.add(inboundCallNLLog);

        Emarsys_Log__c inboundEmailNLLog = new Emarsys_Log__c(
        	Email_Name__c = 'test', 
        	CreatedDate = Datetime.now().addDays(-7), 
        	Lead__c = inboundEmailNLLead2.Id);
        emarsysLogsList.add(inboundEmailNLLog);

        Emarsys_Log__c shellEmailNLLog = new Emarsys_Log__c(
        	Email_Name__c = 'test', 
        	CreatedDate = Datetime.now().addDays(-7), 
        	Lead__c = shellEmailNLLead2.Id);
        emarsysLogsList.add(shellEmailNLLog);

        // Belgium-NL logs
        Emarsys_Log__c facebookBENLLog = new Emarsys_Log__c(
        	Email_Name__c = 'test', 
        	CreatedDate = Datetime.now().addDays(-7), 
        	Lead__c = facebookNBELLead3.Id);
        emarsysLogsList.add(facebookBENLLog);

        Emarsys_Log__c inboundCallBENLLog = new Emarsys_Log__c(
        	Email_Name__c = 'test', 
        	CreatedDate = Datetime.now().addDays(-7), 
        	Lead__c = inboundCallBENLLead3.Id);
        emarsysLogsList.add(inboundCallBENLLog);

        Emarsys_Log__c inboundEmailBENLLog = new Emarsys_Log__c(
        	Email_Name__c = 'test', 
        	CreatedDate = Datetime.now().addDays(-7), 
        	Lead__c = inboundEmailBENLLead3.Id);
        emarsysLogsList.add(inboundEmailBENLLog);

        Emarsys_Log__c shellEmailBENLLog = new Emarsys_Log__c(
        	Email_Name__c = 'test', 
        	CreatedDate = Datetime.now().addDays(-7), 
        	Lead__c = shellEmailBENLLead3.Id);
        emarsysLogsList.add(shellEmailBENLLog);

        // Belgium-FR logs
        Emarsys_Log__c facebookBEFRLog = new Emarsys_Log__c(
        	Email_Name__c = 'test', 
        	CreatedDate = Datetime.now().addDays(-7), 
        	Lead__c = facebookBEFRLead4.Id);
        emarsysLogsList.add(facebookBEFRLog);

        Emarsys_Log__c inboundCallBEFRLog = new Emarsys_Log__c(
        	Email_Name__c = 'test', 
        	CreatedDate = Datetime.now().addDays(-7), 
        	Lead__c = inboundCallBEFRLead4.Id);
        emarsysLogsList.add(inboundCallBEFRLog);

        Emarsys_Log__c inboundEmailBEFRLog = new Emarsys_Log__c(
        	Email_Name__c = 'test', 
        	CreatedDate = Datetime.now().addDays(-7), 
        	Lead__c = inboundEmailBEFRLead4.Id);
        emarsysLogsList.add(inboundEmailBEFRLog);

        Emarsys_Log__c shellEmailBEFRLog = new Emarsys_Log__c(
        	Email_Name__c = 'test', 
        	CreatedDate = Datetime.now().addDays(-7), 
        	Lead__c = shellEmailBEFRLead4.Id);
        emarsysLogsList.add(shellEmailBEFRLog);

        // Poland logs
        Emarsys_Log__c otherChannelPLLog = new Emarsys_Log__c(
        	Email_Name__c = 'test', 
        	CreatedDate = Datetime.now().addDays(-7), 
        	Lead__c = otherChannelPLLead5.Id);
        emarsysLogsList.add(otherChannelPLLog);

        // Hungary logs
        Emarsys_Log__c otherChannelHULog = new Emarsys_Log__c(
        	Email_Name__c = 'test', 
        	CreatedDate = Datetime.now().addDays(-7), 
        	Lead__c = otherChannelHULead6.Id);
        emarsysLogsList.add(otherChannelHULog);

        // ---------------------- Opportunities ---------------------- //
        String euroShellRecId = GlobalUtils.returnRecordTypeId('Opportunity', 'Euroshell');
        Account accountDE = new Account(
            Name = 'test',
            BillingCountry = 'Germany');
        insert accountDE;

        Contact contact = new Contact(
            Email = 'john@wick.com', 
            LastName = 'Wick', 
            FirstName = 'John', 
            Salutation = 'Mr', 
            AccountId = accountDE.Id);
        insert contact;

        List<Opportunity> opportunityToInsertList = new List<Opportunity>();
        Opportunity upgradedToE2EOpp = new Opportunity(
            Name = 'test app', 
            AccountId = accountDE.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            E2E_Sales_Type__c = 'Manual upgraded to E2E', 
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(upgradedToE2EOpp);

        Opportunity directDebitNoDepositOpp = new Opportunity(
            Name = 'test app', 
            AccountId = accountDE.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            Zahlungsart__c = 'Lastschrift', 
            E2E_payment_status__c = 'NO DEPOSIT', 
            E2E_Active_Step__c = 4,
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(directDebitNoDepositOpp);

        Opportunity directDebitAcceptOpp = new Opportunity(
            Name = 'test app', 
            AccountId = accountDE.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            Zahlungsart__c = 'Lastschrift', 
            E2E_payment_status__c = 'ACCEPT', 
            Security_Amount_To_Pay__c = 1000,
            E2E_Active_Step__c = 4,
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(directDebitAcceptOpp);

        Opportunity directDebitCancelOpp = new Opportunity(
            Name = 'test app', 
            AccountId = accountDE.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            Zahlungsart__c = 'Lastschrift', 
            E2E_payment_status__c = 'CANCEL', 
            Security_Amount_To_Pay__c = 1000,
            E2E_Active_Step__c = 4,
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(directDebitCancelOpp);

        Opportunity directDebitExceptionOpp = new Opportunity(
            Name = 'test app', 
            AccountId = accountDE.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            Zahlungsart__c = 'Lastschrift', 
            E2E_payment_status__c = 'EXCEPTION', 
            Security_Amount_To_Pay__c = 1000,
            E2E_Active_Step__c = 4,
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(directDebitExceptionOpp);

        Opportunity bankTransferNoDepositOpp = new Opportunity(
            Name = 'test app', 
            AccountId = accountDE.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            Zahlungsart__c = 'Banküberweisung', 
            E2E_payment_status__c = 'NO DEPOSIT', 
            Security_Amount_To_Pay__c = null,
            E2E_Active_Step__c = 4,
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(bankTransferNoDepositOpp);

        Opportunity bankTransferAcceptOpp = new Opportunity(
            Name = 'test app', 
            AccountId = accountDE.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            Zahlungsart__c = 'Banküberweisung', 
            E2E_payment_status__c = 'ACCEPT', 
            Security_Amount_To_Pay__c = 1000,
            E2E_Active_Step__c = 4,
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(bankTransferAcceptOpp);

        Opportunity bankTransferCancelOpp = new Opportunity(
            Name = 'test app', 
            AccountId = accountDE.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            Zahlungsart__c = 'Banküberweisung', 
            E2E_payment_status__c = 'CANCEL', 
            Security_Amount_To_Pay__c = 1000,
            E2E_Active_Step__c = 4,
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(bankTransferCancelOpp);

        Opportunity bankTransferExceptionOpp = new Opportunity(
            Name = 'test app', 
            AccountId = accountDE.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            Zahlungsart__c = 'Banküberweisung', 
            E2E_payment_status__c = 'EXCEPTION', 
            Security_Amount_To_Pay__c = 1000,
            E2E_Active_Step__c = 4,
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(bankTransferExceptionOpp);

        Opportunity abandonmentScenarioOpp = new Opportunity(
            Name = 'test app', 
            AccountId = accountDE.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            E2E_Switch_To_Manual__c = false, 
            E2E_Status__c = 'Abandoned (hard)', 
            E2E_Sub_Status__c = 'Marketing automation',
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(abandonmentScenarioOpp);

        Opportunity saveAndContinueOpp = new Opportunity(
            Name = 'test app', 
            AccountId = accountDE.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            E2E_Switch_To_Manual__c = false, 
            E2E_Status__c = 'Abandoned (soft)', 
            E2E_Sub_Status__c = 'Marketing automation',
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(saveAndContinueOpp);

        Opportunity upgradedToE2EOpp1 = new Opportunity(
            Name = 'test app', 
            AccountId = accountDE.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            E2E_Sales_Type__c = 'Manual upgraded to E2E', 
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(upgradedToE2EOpp1);

        Opportunity directDebitNoDepositOpp1 = new Opportunity(
            Name = 'test app', 
            AccountId = accountDE.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            Zahlungsart__c = 'Lastschrift', 
            E2E_payment_status__c = 'NO DEPOSIT', 
            E2E_Active_Step__c = 4,
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(directDebitNoDepositOpp1);

        insert opportunityToInsertList;

        List<OpportunityContactRole> contactRolesList = new List<OpportunityContactRole>();
        OpportunityContactRole upgradedToE2EDERole = new OpportunityContactRole(
            ContactId = contact.Id,
            OpportunityId = upgradedToE2EOpp.Id,
            isPrimary = true);
        contactRolesList.add(upgradedToE2EDERole);

        OpportunityContactRole directDebitNoDepositDERole = new OpportunityContactRole(
            ContactId = contact.Id,
            OpportunityId = directDebitNoDepositOpp.Id,
            isPrimary = true);
        contactRolesList.add(directDebitNoDepositDERole);

        OpportunityContactRole directDebitAcceptDERole = new OpportunityContactRole(
            ContactId = contact.Id,
            OpportunityId = directDebitAcceptOpp.Id,
            isPrimary = true);
        contactRolesList.add(directDebitAcceptDERole);

        OpportunityContactRole directDebitCancelDERole = new OpportunityContactRole(
            ContactId = contact.Id,
            OpportunityId = directDebitCancelOpp.Id,
            isPrimary = true);
        contactRolesList.add(directDebitCancelDERole);

        OpportunityContactRole directDebitExceptionDERole = new OpportunityContactRole(
            ContactId = contact.Id,
            OpportunityId = directDebitExceptionOpp.Id,
            isPrimary = true);
        contactRolesList.add(directDebitExceptionDERole);

        OpportunityContactRole bankTransferNoDepositDERole = new OpportunityContactRole(
            ContactId = contact.Id,
            OpportunityId = bankTransferNoDepositOpp.Id,
            isPrimary = true);
        contactRolesList.add(bankTransferNoDepositDERole);

        OpportunityContactRole bankTransferAcceptDERole = new OpportunityContactRole(
            ContactId = contact.Id,
            OpportunityId = bankTransferAcceptOpp.Id,
            isPrimary = true);
        contactRolesList.add(bankTransferAcceptDERole);

        OpportunityContactRole bankTransferCancelDERole = new OpportunityContactRole(
            ContactId = contact.Id,
            OpportunityId = bankTransferCancelOpp.Id,
            isPrimary = true);
        contactRolesList.add(bankTransferCancelDERole);

        OpportunityContactRole bankTransferExceptionDERole = new OpportunityContactRole(
            ContactId = contact.Id,
            OpportunityId = bankTransferExceptionOpp.Id,
            isPrimary = true);
        contactRolesList.add(bankTransferExceptionDERole);

        OpportunityContactRole abandonmentScenarioDERole = new OpportunityContactRole(
            ContactId = contact.Id,
            OpportunityId = abandonmentScenarioOpp.Id,
            isPrimary = true);
        contactRolesList.add(abandonmentScenarioDERole);

        OpportunityContactRole saveAndContinueDERole = new OpportunityContactRole(
            ContactId = contact.Id,
            OpportunityId = saveAndContinueOpp.Id,
            isPrimary = true);
        contactRolesList.add(saveAndContinueDERole);

        OpportunityContactRole upgradedToE2EDERole1 = new OpportunityContactRole(
            ContactId = contact.Id,
            OpportunityId = upgradedToE2EOpp1.Id,
            isPrimary = true);
        contactRolesList.add(upgradedToE2EDERole1);

        OpportunityContactRole directDebitNoDepositDERole1 = new OpportunityContactRole(
            ContactId = contact.Id,
            OpportunityId = directDebitNoDepositOpp1.Id,
            isPrimary = true);
        contactRolesList.add(directDebitNoDepositDERole1);

        insert contactRolesList;

        // emarsys de
        Emarsys_Log__c upgradedToE2EDELog = new Emarsys_Log__c(
            Email_Name__c = 'test', 
            CreatedDate = Datetime.now().addDays(-7), 
            Opportunity__c = upgradedToE2EOpp1.Id);
        emarsysLogsList.add(upgradedToE2EDELog);

        Emarsys_Log__c directDebitNoDepositDELog = new Emarsys_Log__c(
            Email_Name__c = 'test', 
            CreatedDate = Datetime.now().addDays(-7), 
            Opportunity__c = directDebitNoDepositOpp1.Id);
        emarsysLogsList.add(directDebitNoDepositDELog);

        insert emarsysLogsList;
	}

	@isTest
    static void emarsysJobTest() {
        Test.startTest();
	        EmarsysLogCheckerSchedule schedule = new EmarsysLogCheckerSchedule();
			String sch = '0 0 0 15 3 ? 2023'; 
			System.schedule('Emarsys log checker Job', sch, schedule);
		Test.stopTest();
    }
}