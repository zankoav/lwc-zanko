global class EmailToLeadService implements Messaging.InboundEmailHandler {
	global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env) {
		// // Create an inboundEmailResult object for returning 
		// // the result of the Force.com Email Service
		Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
		String htmlTextBody = '';

		// Add the email plain text into the local variable
		htmlTextBody = email.htmlBody;

		htmlTextBody = 'Subject: ' + email.subject + '<br/>' + htmlTextBody;
		if (htmlTextBody.contains('Spam') || htmlTextBody.contains('spam')) {
			return null;
		}
		String currentCountry = '';
		String fromEmailAddress = '';
		String currentSecChannel = '';
		String currentCompany = '';
		String currentLeadSource = '';
		String currentLeadName = 'New Lead Contact Form';
		system.debug('email === ' + email);
		if (email.headers != null) {
			for (Messaging.InboundEmail.Header header : email.headers) {
				system.debug('===header: ' + header);
			}
		}
		//set default values for lead fields
		currentSecChannel = 'Inbound';
		currentCompany = 'New Inbound Lead';
		if (htmlTextBody != null && htmlTextBody.containsIgnoreCase('Formstack')) {
			currentLeadSource = 'Shell Email';
		} else {
			currentLeadSource = 'Inbound Email';
		}		

		if (email.fromAddress == 'kontakt@fleetcor.at') currentCountry = 'Austria';
		if (email.fromAddress == 'kontakt@fleetcor.de') currentCountry = 'Germany';
		if (email.fromAddress == 'kundewerden@fleetcor.de') currentCountry = 'Germany';
		if (email.fromAddress == 'contact@fleetcor.nl') currentCountry = 'Netherlands';
		if (email.fromAddress == 'contact@fleetcorcards.be') currentCountry = 'Belgium-NL';
		if (email.fromAddress == 'contact.fr@fleetcorcards.be') currentCountry = 'Belgium-FR';
		if (email.fromAddress == 'contact@fleetcor.fr') currentCountry = 'France';
		if (email.fromAddress == 'nowyklient@fleetcor.pl') currentCountry = 'Poland';
		if (email.fromAddress == 'ujugyfel@fleetcor.hu') currentCountry = 'Hungary';
		if (email.fromAddress == 'contact@fleetcor.ch') currentCountry = 'Switzerland-DE';
		if (email.fromAddress == 'contact-fr@fleetcor.ch') currentCountry = 'Switzerland-FR';
		if (email.fromAddress == 'contact-it@fleetcor.ch') currentCountry = 'Switzerland-IT';
		if (email.fromAddress == 'contact@fleetcor.lu') currentCountry = 'Luxembourg';
		if (email.fromAddress == 'kontakt@fleetcor.cz') currentCountry = 'Czech Republic';
		if (email.fromAddress == 'kontakt@fleetcor.sk') currentCountry = 'Slovakia';

		if (email.fromAddress == 'flash.log@gmail.com') currentCountry = 'Belgium-FR';

		if (email.fromAddress == 'retailer@fleetcor.cz') {
			currentCountry = 'Czech Republic';
			currentSecChannel = 'JITB';
			currentLeadName = 'New Lead JITB Email';
		} 

		if (email.fromAddress == 'retailer@fleetcor.sk') {
			currentCountry = 'Slovakia';
			currentSecChannel = 'JITB';
			currentLeadName = 'New Lead JITB Email';
		}
		
		if ( ! String.isBlank(email.subject)) {
			fromEmailAddress = email.subject.substringBetween('##email:', ' ');
		}
		Lead newLead = new Lead(
			Company = currentCompany,
			Contact_Email_Body__c = htmlTextBody,
			LeadSource = currentLeadSource,
			Country = currentCountry,
			Sec_Channel__c = currentSecChannel,
			Channel__c = 'E-mail',
			LastName = currentLeadName);

		if ( ! String.isBlank(fromEmailAddress)) {
			newLead.Email = fromEmailAddress;
		}

		try {
			insert newLead;

			// Save attachments, if any
			List<Attachment> attachmentsToInsert = new List<Attachment>();
			if (email.textAttachments != null) {
				for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments) {
				  Attachment attachment = new Attachment();
				 
				  attachment.Name = tAttachment.fileName;
				  attachment.Body = Blob.valueOf(tAttachment.body);
				  attachment.ParentId = newLead.Id;
				  attachmentsToInsert.add(attachment);
				}				
			}

			if (email.binaryAttachments != null) {
				for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
				  Attachment attachment = new Attachment();
				 
				  attachment.Name = bAttachment.fileName;
				  attachment.Body = bAttachment.body;
				  attachment.ParentId = newLead.Id;
				  attachmentsToInsert.add(attachment);
				}
			}
			insert attachmentsToInsert;
		} catch (System.StringException e) {
			system.debug('newLead exception: ' + e);
		}

		// Set the result to true, no need to send an email back to the user
		// with an error message
		result.success = true;

		// Return the result for the Force.com Email Service
		return result;
	}
}