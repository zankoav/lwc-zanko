public with sharing class SubmitForReopenCtrl {
	public Opportunity currentOpportunity;
	public User currentUser;
    public Integer daysAfterCreditCheck;

    public SubmitForReopenCtrl() {}

    public PageReference init() {
    	try {
    		String userId = UserInfo.getUserId();
    	    String oppId = ApexPages.currentPage().getParameters().get('Id');

    	    this.currentUser = [
	                SELECT UserRole.Name, Profile.Name, Name, UserRoleId
	                FROM User
	                WHERE Id = :userId];

    	    this.currentOpportunity = [
	                SELECT Id, StageName, OwnerId, Name, Reopen__c, Account.GFN_Nr__c, Credit_check_date__c
	                FROM Opportunity
	                WHERE Id = :oppId
	                LIMIT 1];

            calcDiffBetweenDates();
            validate();
            this.currentOpportunity.Reopen__c = true;
            update this.currentOpportunity;
            sendEmail();

            Approval.lock(this.currentOpportunity.Id);
            return new PageReference('/' + this.currentOpportunity.Id);
    	} catch (Exception e) {
    	    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
            return null;
    	}
    }


    /*******************************************************************************
    *  Name            : calcDiffBetweenDates()
    *  Summary         : Calculate difference between 'Credit check date' and 'Today date'    
    *  CreatedDate     : 22/05/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void calcDiffBetweenDates() {
        if (this.currentOpportunity.Credit_check_date__c != null) {
            this.daysAfterCreditCheck = (Date.valueOf(this.currentOpportunity.Credit_check_date__c)).daysBetween(Date.today());
        }
    }


    /*******************************************************************************
    *  Name            : validate()
    *  Summary         : check current Opporunity StageName    
    *  CreatedDate     : 14/05/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void validate() {
        if (this.currentOpportunity.StageName == 'Closed Lost' && (this.currentOpportunity.Credit_check_date__c == null || this.daysAfterCreditCheck > 90)) {
            throw new StageException('You can Reopen Closed Lost Opportunity only within last 3 months "Credit check date". <a href="/' + this.currentOpportunity.Id + '">back to Opportunity</a>');
        }
    	if (this.currentOpportunity.StageName != 'Closed Lost' && this.currentOpportunity.StageName != 'CreditCheck abgelehnt' && this.currentOpportunity.StageName != 'Closed Won') {
            throw new StageException('This action is available for Closed Lost, Closed Won or CreditCheck rejected Opportunity Stage only. <a href="/' + this.currentOpportunity.Id + '">back to Opportunity</a>');
        }
        if ((this.currentOpportunity.StageName == 'Closed Won' || this.currentOpportunity.StageName == 'Closed Lost' || this.currentOpportunity.StageName == 'CreditCheck abgelehnt') && this.currentOpportunity.Account.GFN_Nr__c != null) {
            throw new StageException('The GFN Number must be empty. <a href="/' + this.currentOpportunity.Id + '">back to Opportunity</a>');
        }
        if (Approval.isLocked(this.currentOpportunity.Id) && this.currentOpportunity.Reopen__c == true) {
            throw new StageException('This Opportunity is already submitted for reopen. <a href="/' + this.currentOpportunity.Id + '">back to Opportunity</a>');
        }

        String profileName = [SELECT Profile.Name FROM User WHERE Id = :this.currentUser.Id].Profile.Name;
        if (Submit_for_reopen_profiles__c.getInstance(profileName) == null) {
            throw new StageException('User Profile is not valid.');
        }
    }


    /*******************************************************************************
    *  Name            : sendEmail()
    *  Summary         : sending letters by pressing the button    
    *  CreatedDate     : 15/05/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void sendEmail() {
        List<Messaging.SingleEmailMessage> emails = preporationEmailsForSending(this.currentOpportunity, 'Petr Cermak');

        if (! Test.isRunningTest()) {
            Messaging.sendEmail(emails);
        }
    }


    /*******************************************************************************
    *  Name            : preporationEmailsForSending(Opportunity currentOpportunity, String customEmailName)
    *  Summary         : prepares to send email    
    *  CreatedDate     : 15/05/2018
    *  Parameters      : Opportunity opportunity, String customEmailName
    *  Returns         : all emails
    ******************************************************************************/
    public List<Messaging.SingleEmailMessage> preporationEmailsForSending(Opportunity opportunity, String customEmailName) {
	    Notifications_for_reopening_Opportunity__c emailCustomSetting = Notifications_for_reopening_Opportunity__c.getInstance(customEmailName);
	    String headerData = ApexPages.currentPage().getHeaders().get('Host');

    	List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mailToCredit = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {emailCustomSetting.Email__c};
        mailToCredit.setToAddresses(toAddresses);
        mailToCredit.setSubject('Reopen request for ' + opportunity.Name);
        mailToCredit.setHtmlBody('<messaging:emailTemplate> ' +
                '<html> <style type="text/css"> body {size: 12pt;} td { border-width: 1px;  padding: 4px;' +
                'border-style: solid; border-color: #000000; background-color: #FFEECC;}th { color: #000000; border-width: 1px ; padding: 4px ;' +
                'border-style: solid ;  border-color: #000000; background-color: #FFFFF0;}</style>' +
                '<body>' +
                'Dear Credit Team, <br/>' +
                '<br/>' +
                'Please reopen the following Opportunity: https://' + headerData + '/' + opportunity.Id + '<br/>' +
                '<br/>' +
                'Best regards, <br/>' +
                this.currentUser.Name +
                '</body> ' +
                '</html> </messaging:emailTemplate>');
        allmsg.add(mailToCredit);

        return allmsg;
    }

    public class StageException extends Exception {}
}