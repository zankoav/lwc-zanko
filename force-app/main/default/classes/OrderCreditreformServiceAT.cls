public class OrderCreditreformServiceAT implements Order {
	public String name;
	public String postalCode;
	public String city;
	public String street;
	public String houseNumber;
	public String houseNumberAffix;
	public String orderSpecifyingText;
    

    /*******************************************************************************
	*  Name            : doOrder(CreditSystem creditSystem, Opportunity opportunity)
	*  Summary         : do order request if report is not available 
	*  CreatedDate     : 15/12/2017
	*  ModifiedDate    : 21/03/2018
	*  Parameters      : CreditSystem - credit system object with Creditreform credentials,
						 Opportunity opportunity - opportunity for order, String errorMessage - 
						 part of error message to display, String internalId - null for Creditreform
	*  Returns         : void
	******************************************************************************/
	public void doOrder(CreditSystem creditSystem, Opportunity opportunity, String errorMessage, String internalId) {
		validateOpportunity(opportunity, errorMessage);
		try {
			setDataForRequest(opportunity, errorMessage);
    		HttpRequest request = CreditReformWebserviceAT.generateOrderRequest(creditSystem.getEndpointUrl(),
    				creditSystem.getUserName(), creditSystem.getUserPassword(), creditSystem.getApiKey(),
    				this.name, this.postalCode, this.city, this.street, this.houseNumber, this.orderSpecifyingText);
    		System.debug('DEBUG: ORDER REQUEST === ' + request.getBody());
			Http http = new Http();
			HttpResponse response = http.send(request);
			System.debug('DEBUG: ORDER RESPONSE === ' + response.getBody());
			String xmlResponse = response.getBody();
	        xmlResponse = CreditReformWebserviceAT.clearSearchXML(xmlResponse);
	        Dom.Document domDoc = new Dom.Document();
			domDoc.load(xmlResponse);
	        Dom.XMLNode xmldom = domDoc.getRootElement();
	        Dom.XMLNode globalBody = CreditReformWebserviceAT.returnGlobalBody(xmldom);
	        Dom.XMLNode innerBody = CreditReformWebserviceAT.returnInnerBody(globalBody);

	        // If error - display on the page
	        if (innerBody == null) {
	            String errorMessageResponse = CreditReformWebserviceAT.returnErrorMessage(globalBody);
	            throw new CreditFactoryException(errorMessage + 'Order request failed. ' + errorMessageResponse + CreditFactoryUtilities.CONTACT_ADMIN);
	        }

	        String orderReferenceNumber = CreditReformWebserviceAT.returnReferenceNumber(innerBody);
	        if (errorMessage != '') {
	        	updateOpportunityInitialOrder(opportunity, orderReferenceNumber);
	        } else {
	        	updateOpportunityAdditionalOrder(opportunity, orderReferenceNumber);
	        }
	    } catch (Exception e) {
	    	throw new CreditFactoryException(errorMessage + 'Order request failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
	    }
	}


	/*******************************************************************************
	*  Name            : validateOpportunity(Opportunity opportunity, String errorMessage)
	*  Summary         : check opportunity for sending order request    
	*  CreatedDate     : 21/03/2018
	*  ModifiedDate    : 21/03/2018
	*  Parameters      : Opportunity opportunity - opportunity for order, String errorMessage - 
						 part of error message to display
	*  Returns         : void
	******************************************************************************/
	public void validateOpportunity(Opportunity opportunity, String errorMessage) {
		if (errorMessage != '') {
			if (opportunity.CF_Stage__c == 'Pending Credit Report - Order was sent' || opportunity.CF_Stage__c == 'Pending Credit Report - Additional information was sent') {
				throw new CreditFactoryException(errorMessage + ' Order request already sent.');
			}
			
			if (opportunity.Account.BillingCity == null || opportunity.Account.BillingPostalCode == null) {
				throw new CreditFactoryException(errorMessage + ' Please fill Billing City and Billing Postal Code to do order request.');
			}
		}
	}


	/*******************************************************************************
	*  Name            : setDataForRequest(Opportunity opportunity)
	*  Summary         : prepare company data for request    
	*  CreatedDate     : 21/03/2018
	*  ModifiedDate    : 21/03/2018
	*  Parameters      : Opportunity opportunity - opportunity with fields for request, 
						 String errorMessage - part of error message to display
	*  Returns         : void
	******************************************************************************/
	public void setDataForRequest(Opportunity opportunity, String errorMessage) {
		this.name = opportunity.Name.replace('&', '&amp;');
        this.postalCode = opportunity.Account.BillingPostalCode;
        this.city = opportunity.Account.BillingCity;
        this.street = CreditFactoryUtilities.getStreet(opportunity.Account.BillingStreet);
        this.houseNumber = CreditFactoryUtilities.getHousenumber(opportunity.Account.BillingStreet);

        // automatical request with additional information
        if (errorMessage == '') {
        	String legalForm = opportunity.Account.Gesellschaftsform__c;
	        String streetAndHouseNumberWithAffix = opportunity.Account.BillingStreet;
	        String taxId = opportunity.Account.Steuernummer__c;
	        String vatNumber = opportunity.Account.Umsatzsteuer_ID__c;
	        String tradeRegisterNumber = opportunity.Account.HR_Abteilung_HRA_HRB_und_HR_Nummer__c;
	        String yearOfFoundation = opportunity.Account.Gruendungsjahr__c;
	        String industry = opportunity.Account.Branche_NACE__c;
	        String webSite = opportunity.Account.Website;
	        String firstName;
	        String lastName;
	        String phone;
	        String email;
	        String birthdate;
	        for (OpportunityContactRole role : opportunity.OpportunityContactRoles) {
	            if (role.IsPrimary == true) {
	                firstName = role.Contact.FirstName;
	                lastname = role.Contact.Lastname;
	                phone = role.Contact.Phone;
	                email = role.Contact.Email;
	                birthDate = String.valueOf(role.Contact.Birthdate);
	            }
	        }
	        this.orderSpecifyingText = (legalForm != null ? 'Gesellschaftsform: ' + legalForm + '\n' : '') +
	        						   (streetAndHouseNumberWithAffix != null && streetAndHouseNumberWithAffix != this.street + this.houseNumber ? 'Straße: ' + streetAndHouseNumberWithAffix + '\n' : '') +
	        						   (taxId != null ? 'Steuernummer: ' + taxId + '\n' : '') +
						               (vatNumber != null ? 'USt-IdNr.: ' + vatNumber + '\n' : '') +
						               (tradeRegisterNumber != null ? 'HR Nr.: ' + tradeRegisterNumber + '\n' : '') +
						               (yearOfFoundation != null ? 'Grundungsjahr: ' + yearOfFoundation + '\n' : '') +
						               (industry != null ? 'Branche: ' + industry + '\n' : '') + 
						               (webSite != null ? 'Webseite: ' + webSite + '\n' : '') +
						               (firstName != null ? 'Vorname: ' + firstName + '\n' : '') +
						               (lastName != null ? 'Nachname: ' + lastName + '\n' : '') +
						               (phone != null ? 'Phone: ' + phone + '\n' : '') +
						               (email != null ? 'E-mail: ' + email + '\n' : '') +
						               (birthdate != null ? 'Geburtsdatum: ' + birthdate + '\n' : '');
		    if (this.orderSpecifyingText.length() > 364) {
		    	this.orderSpecifyingText = this.orderSpecifyingText.substring(0, 364);
		    }
		}
	}


	/*******************************************************************************
	*  Name            : updateOpportunityInitialOrder(Opportunity opportunity, String referenceNumber)
	*  Summary         : update opportunity fields after succeed order request 
	*  CreatedDate     : 15/15/2017
	*  ModifiedDate    : 15/15/2017
	*  Parameters      : Opportunity opportunity - opportunity to update, 
						 String referenceNumber - reference number 
	*  Returns         : void
	******************************************************************************/
	private void updateOpportunityInitialOrder(Opportunity opportunity, String referenceNumber) {
		opportunity.CF_Order_Reference_Number__c = referenceNumber;
		opportunity.StageName = 'Pending Credit Report';
		opportunity.CF_Stage__c = 'Pending Credit Report - Order was sent';
		update opportunity;
	}

	/*******************************************************************************
	*  Name            : updateOpportunityAdditionalOrder(Opportunity opportunity, String referenceNumber)
	*  Summary         : update opportunity fields after succeed order request 
	*  CreatedDate     : 15/15/2017
	*  ModifiedDate    : 15/15/2017
	*  Parameters      : Opportunity opportunity - opportunity to update, 
						 String referenceNumber - reference number 
	*  Returns         : void
	******************************************************************************/
	private void updateOpportunityAdditionalOrder(Opportunity opportunity, String referenceNumber) {
		opportunity.CF_Order_Reference_Number__c = referenceNumber;
		opportunity.StageName = 'Pending Credit Report';
		opportunity.CF_Stage__c = 'Pending Credit Report - Additional information was sent';
		update opportunity;
	}


	/*******************************************************************************
	*  Name            : getSuccessfulOrderStatus()
	*  Summary         : Get successful status string of order.    
	*  CreatedDate     : 17/08/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : String
	******************************************************************************/
	public String getSuccessfulOrderStatus() {
		return 'Order request was sent.';
	}
}