public class OrderCrifService implements Order {
    

    /*******************************************************************************
	*  Name            : doOrder(CreditSystem creditSystem, Opportunity opportunity, String errorMessage)
	*  Summary         : Do order request if report is not available or company doen't exist.
	*  CreatedDate     : 17/08/2018
	*  ModifiedDate    : -
	*  Parameters      : CreditSystem - credit system object with Crif credentials,
						 Opportunity opportunity - opportunity for order, String errorMessage - 
						 part of error message to display, String internalId - Coface internal Id
	*  Returns         : void
	******************************************************************************/
	public void doOrder(CreditSystem creditSystem, Opportunity opportunity, String errorMessage, String internalId) {
		validateOpportunity(opportunity, errorMessage);
		try {
			String creditReportId = internalId;
			if (! (errorMessage == 'Credit Factory report received with a system error.')) {
				HttpRequest request = CrifWebservice.generateReportRequest(
	    			creditSystem.getEndpointUrl(), creditSystem.getUserName(), 
	    			creditSystem.getUserPassword(), opportunity.Account.Steuernummer__c);
				Http http = new Http();
				HttpResponse response = http.send(request);
				creditReportId = opportunity.Account.Steuernummer__c;
			}

			updateOpportunity(opportunity, creditReportId);
	    } catch (Exception e) {
	    	throw new CreditFactoryException(errorMessage + ' Order request failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
	    }
	}


	/*******************************************************************************
	*  Name            : validateOpportunity(Opportunity opportunity, String errorMessage)
	*  Summary         : Check opportunity for sending order request.
	*  CreatedDate     : 17/08/2018
	*  ModifiedDate    : 21/02/2019
	*  Parameters      : Opportunity opportunity - opportunity for order, String errorMessage - 
						 part of error message to display
	*  Returns         : void
	******************************************************************************/
	private void validateOpportunity(Opportunity opportunity, String errorMessage) {
		if (errorMessage != '') {
			if (errorMessage == 'Credit report is not available. Customer did not publish his company details. Please refer to Credit.') {
				throw new CreditFactoryException(errorMessage);
			}
			if (opportunity.CF_Stage__c == 'Pending Credit Report - Order was sent') {
				throw new CreditFactoryException(errorMessage + getSuccessfulOrderStatus());
			}

			if (opportunity.Account.Steuernummer__c == null) {
				throw new CreditFactoryException(errorMessage + ' Please fill Tax Id to do order request.');
			}
		}
	}


	/*******************************************************************************
	*  Name            : updateOpportunity(Opportunity opportunity)
	*  Summary         : Update opportunity fields after succeed order request.
	*  CreatedDate     : 17/08/2018
	*  ModifiedDate    : -
	*  Parameters      : Opportunity opportunity - opportunity to update, String creditReportId - Id of report
	*  Returns         : void
	******************************************************************************/
	private void updateOpportunity(Opportunity opportunity, String creditReportId) {
		opportunity.StageName = 'Pending Credit Report';
		opportunity.CF_Stage__c = 'Pending Credit Report - Order was sent';
		opportunity.Credit_Report_Id__c = creditReportId;
		opportunity.Credit_Report_Request_Date__c = Date.today();
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
		return 'Additional attempts to download a Credit Factory report will be performed automatically till the end of the day. ' +
			'Once a report is downloaded you will receive an email notification.';
	}
}