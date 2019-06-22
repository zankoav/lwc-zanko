public class LFCreditScoringUtils {
    /*******************************************************************************
    *  Name            : generateBodyForCreditDepartmentPush(Opportunity opportunity, Opportunity e2eOpportunity)
    *  Summary         : Generate string HTML body for email – Email #3 (from the doc)
    *  CreatedDate     : 24/04/2018
    *  ModifiedDate    : 
    *  Parameters      : opportunity – existing opportunity from the database, e2eOpportunity – new e2e opportunity
    *  Returns         : String – email body 
    ******************************************************************************/
    public static String generateBodyForCreditDepartmentPush(Opportunity opportunity, Opportunity e2eOpportunity) {
        String body = 'Dear Credit Manager,<br/>' +  
                      'New visitor started e2e Application and is trying to order card online.<br/><br/>' +
                      'This customer is already in SF:<br/>' +
                      'Opportunity Stage: Credit Check Rejected OR Closed Lost (Reason Lost: Refused Credit)<br/>' +
                      '<a href="https://eu9.salesforce.com/' + opportunity.Id + '" target="_blank">Link to Opportunity</a><br/><br/>' +
                      'Since more than 3 Months passed it will be allowed to run a Credit Score again.<br/>' +
                      '<a href="https://eu9.salesforce.com/' + e2eOpportunity.Id + '" target="_blank">Link to E2E Opportunity</a><br/><br/>' +
                      'No actions are required at the moment.<br/><br/>' +
                      'Thanks and best regards.';
        return body;
    }


    /*******************************************************************************
    *  Name            : generateBodyForSalesPush(Opportunity opportunity, Opportunity e2eOpportunity, String oldStage)
    *  Summary         : Generate string HTML body for email – Email #4 (from the doc)      
    *  CreatedDate     : 24/04/2018
    *  ModifiedDate    : 
    *  Parameters      : opportunity – existing opportunity from the database, 
                         e2eOpportunity – new e2e opportunity,
                         oldStage – old opportunity stage
    *  Returns         : String
    ******************************************************************************/
    public static String generateBodyForSalesPushEmail4(Opportunity opportunity, Opportunity e2eOpportunity, String oldStage) {
        String body = 'Dear ' + opportunity.Owner.FirstName + ' ' + opportunity.Owner.LastName + ',<br/><br/>' + 
                      'Stage of your opportunity ' + opportunity.Name + ' was changed from ' + oldStage + ' to ' + opportunity.StageName + ' ' +
                      'because your customer started e2e Application and tries to order cards online.<br/>' +
                      '<a href="https://eu9.salesforce.com/' + opportunity.Id + '" target="_blank">Link to Opportunity</a><br/><br/>' +
                      '<a href="https://eu9.salesforce.com/' + e2eOpportunity.Id + '" target="_blank">Link to E2E Opportunity</a><br/><br/>' +
                      'No actions are required at the moment.<br/><br/>' +
                      'Thanks and best regards.';
        return body;
    }


    /*******************************************************************************
    *  Name            : generateBodyForCurrentLeadOwnerPush(Opportunity opportunity)
    *  Summary         : Generate string HTML body for email – Email #5 (from the doc)    
    *  CreatedDate     : 24/04/2018
    *  ModifiedDate    : 
    *  Parameters      : opportunity – existing opportunity from the database
    *  Returns         : String – email body
    ******************************************************************************/
    public static String generateBodyForSalesPushEmail5(Opportunity opportunity) {
        String body = 'Dear ' + opportunity.Owner.FirstName + ' ' + opportunity.Owner.FirstName + ',<br/><br/>' + 
                      'Your customer ' + opportunity.Name + ' started e2e Application and tries to order cards online.<br/>' +
                      '<a href="https://eu9.salesforce.com/' + opportunity.Id + '" target="_blank">Current Opportunity</a><br/><br/>' +
                      'Please, contact this customer as soon as possible to close the deal.<br/><br/>' +
                      'Thanks and best regards.';
        return body;
    }


    /*******************************************************************************
    *  Name            : generateBodyForStartsPushEmail6(Opportunity opportunity, Opportunity e2eOpportunity, String oldStage)
    *  Summary         : Generate string HTML body for email – Email #6 (from the doc)      
    *  CreatedDate     : 24/04/2018
    *  ModifiedDate    : 
    *  Parameters      : opportunity – existing opportunity from the database, 
                         e2eOpportunity – new e2e opportunity,
                         oldStage – old opportunity stage
    *  Returns         : String
    ******************************************************************************/
    public static String generateBodyForStartsPushEmail6(Opportunity opportunity, Opportunity e2eOpportunity, String oldStage) {
        String body = 'Dear Start Team,<br/><br/>' +
                      'New visitor started e2e Application and seems to be our current customer.<br/>' +
                      'Please, check manually, if this is existing customer, who has transactions or if this customer has to be considered as a new one (>6 Months).<br/>' + 
                      '<a href="https://eu9.salesforce.com/' + opportunity.Id + '" target="_blank">Link to Opportunity</a><br/><br/>' +
                      '<a href="https://eu9.salesforce.com/' + e2eOpportunity.Id + '" target="_blank">Link to E2E Opportunity</a><br/><br/>' +
                      'Thanks and best regards.';
        return body;
    }


    /*******************************************************************************
    *  Name            : currentLeadOwnerPush(Opportunity opportunity, String body, String emailToSend)
    *  Summary         : Send email notification to Opportunity Owner     
    *  CreatedDate     : 24/04/2018
    *  ModifiedDate    : 
    *  Parameters      : opportunity – existing opportunity, 
                         body – HTML body for template,
                         emailToSend – recipient email
    *  Returns         : void
    ******************************************************************************/
    public static void sendSingleEmail(Opportunity opportunity, String body, String emailToSend) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setSubject('E2E Notification');
        message.setHtmlBody(body);
        message.setToAddresses(new List<String>{emailToSend});
        Messaging.sendEmail(new List<Messaging.Email>{message});
    }
}