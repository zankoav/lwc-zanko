public class OrderCofaceService implements Order {
	public String orderReferenceNumber;
	public String orderPartyId;
    

    /*******************************************************************************
	*  Name            : doOrder(CreditSystem creditSystem, Opportunity opportunity, String errorMessage)
	*  Summary         : Do order request if report is not available or company doen't exist.
	*  CreatedDate     : 29/06/2018
	*  ModifiedDate    : -
	*  Parameters      : CreditSystem - credit system object with Coface credentials,
						 Opportunity opportunity - opportunity for order, String errorMessage - 
						 part of error message to display, String internalId - Coface internal Id
	*  Returns         : void
	******************************************************************************/
	public void doOrder(CreditSystem creditSystem, Opportunity opportunity, String errorMessage, String internalId) {
		validateOpportunity(opportunity, errorMessage);
		try {
    		HttpRequest request = CofaceWebservice.generateOrderRequest(creditSystem.getEndpointUrl(),
					creditSystem.getUserName(), creditSystem.getUserPassword(), internalId,
					opportunity.Account.Umsatzsteuer_ID__c, opportunity.Name, opportunity.Account.BillingPostalCode, 
					opportunity.Account.BillingCity, CreditFactoryUtilities.getStreet(opportunity.Account.BillingStreet), 
					CreditFactoryUtilities.getHousenumber(opportunity.Account.BillingStreet));
			Http http = new Http();
			HttpResponse response = http.send(request);
			System.debug('DEBUG: ORDER RESPONSE === ' + response.getBody());
			String xmlResponse = response.getBody();
	        Dom.Document domDoc = new Dom.Document();
			domDoc.load(xmlResponse);
	        Dom.XMLNode xmldom = domDoc.getRootElement();
	        Dom.XMLNode globalBody = CofaceWebservice.returnGlobalBody(xmldom);
	        Boolean isValidreport = CofaceWebservice.checkResponseForFault(globalBody);
	        if ( ! isValidreport ) {
	            String errorMessageResponse = CofaceWebservice.returnErrorMessage(globalBody);
	            throw new CreditFactoryException(errorMessage + 'Order request failed. ' + errorMessageResponse + CreditFactoryUtilities.CONTACT_ADMIN);
	        }

	        String orderReferenceNumber = CofaceWebservice.returnOrderReferenceNumber(globalBody);
			String orderPartyId = CofaceWebservice.returnPartyId(globalBody);

	        updateOpportunity(opportunity, orderReferenceNumber, orderPartyId);
	    } catch (Exception e) {
	    	throw new CreditFactoryException(errorMessage + ' Order request failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
	    }
	}


	/*******************************************************************************
	*  Name            : validateOpportunity(Opportunity opportunity, String errorMessage)
	*  Summary         : Check opportunity for sending order request.
	*  CreatedDate     : 29/06/2018
	*  ModifiedDate    : -
	*  Parameters      : Opportunity opportunity - opportunity for order, String errorMessage - 
						 part of error message to display
	*  Returns         : void
	******************************************************************************/
	private void validateOpportunity(Opportunity opportunity, String errorMessage) {
		if (errorMessage != '') {
			if (opportunity.CF_Stage__c == 'Pending Credit Report - Order was sent' || opportunity.CF_Stage__c == 'Pending Credit Report - Additional information was sent') {
				throw new CreditFactoryException(errorMessage + ' Order request already sent.');
			}
		}
	}


	/*******************************************************************************
	*  Name            : updateOpportunity(Opportunity opportunity, String orderReferenceNumber, String orderPartyId)
	*  Summary         : Update opportunity fields after succeed order request.
	*  CreatedDate     : 29/06/2018
	*  ModifiedDate    : -
	*  Parameters      : Opportunity opportunity - opportunity to update, String referenceNumber - reference number, 
						 String orderReferenceNumber, String orderPartyId
	*  Returns         : void
	******************************************************************************/
	private void updateOpportunity(Opportunity opportunity, String orderReferenceNumber, String orderPartyId) {
		opportunity.CF_Order_Reference_Number__c = orderReferenceNumber;
		opportunity.CF_Order_Party_Id__c = orderPartyId;
		opportunity.StageName = 'Pending Credit Report';
		opportunity.CF_Stage__c = 'Pending Credit Report - Order was sent';
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