public with sharing class ReopenOppByCreditCtrl {
	public String oppId;
	public User currentUser;
    public Integer daysAfterCreditCheck;
	public Opportunity currentOpportunity {get; set;}
	public List<Opportunity> currentOppList;

    public ReopenOppByCreditCtrl() {}

    public void init() {
    	try {
    	    if (this.oppId == null) {
                this.oppId = ApexPages.currentPage().getParameters().get('id');
            }
            String userId = UserInfo.getUserId();

            this.currentUser = [
	                SELECT UserRole.Name, Profile.Name, Name, UserRoleId
	                FROM User
	                WHERE Id = :userId];

	        this.currentOppList = [
	                SELECT Id, Name, StageName, bearbeitet_von__c, Closed_Won_by_CF__c, Pending_Deposit_by_CF__c, CF_Stage__c, Notes__c, Credit_System_Rating__c, CF_Credit_Limit__c,
	                	Name_of_the_payer_Account_holder__c, IBAN__c, SWIFT_BIC__c, Owner.Name, Gruende_verloren__c, Reopen__c, Account.GFN_Nr__c, Credit_check_date__c
	                FROM Opportunity 
	                WHERE Id = :this.oppId
	                LIMIT 1];

	        this.currentOpportunity = currentOppList.get(0);
            calcDiffBetweenDates();
    	} catch (Exception e) {
    	    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
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
    *  Name            : approveReopen()
    *  Summary         : Approve reopen    
    *  CreatedDate     : 15/05/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public PageReference approveReopen() {
    	try {
    		validate();
    	    Approval.unlock(this.currentOppList.get(0).Id);
	    	sendEmail('Approve_reopen');

	    	for (Opportunity opp : this.currentOppList) {
	    		opp.StageName = 'Prospecting';
	    		opp.Gruende_verloren__c = '';
		    	opp.bearbeitet_von__c = '';
		        opp.Closed_Won_by_CF__c = false;
		        opp.Pending_Deposit_by_CF__c = false;
		        opp.CF_Stage__c = 'Not launched';
		        opp.Reopen__c = false;
                opp.CF_Credit_Limit__c = null;
	    	}

	        update this.currentOppList;
	        PageReference page = new PageReference('/' + currentOpportunity.Id);
	        return page;
    	} catch (Exception e) {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
    		return null;
    	}
    }


    /*******************************************************************************
    *  Name            : rejectReopen()
    *  Summary         : Reject reopen    
    *  CreatedDate     : 15/05/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : page
    ******************************************************************************/
    public PageReference rejectReopen() {
    	try {
    		validate();
    	    Approval.unlock(this.currentOpportunity.Id);
	    	sendEmail('Reject_reopen');

	    	PageReference page = new PageReference('/' + currentOpportunity.Id);
	        return page;
    	} catch (Exception e) {
    	    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
    	    return null;
    	}
    }


    /*******************************************************************************
    *  Name            : sendEmail(String)
    *  Summary         : sending letters by pressing the button    
    *  CreatedDate     : 15/05/2018
    *  Parameters      : String
    *  Returns         : void emailTemplateName
    ******************************************************************************/
    public void sendEmail(String emailTemplateName) {
        List<Messaging.SingleEmailMessage> emails = preporationEmailsForSending(this.currentOpportunity, emailTemplateName);

        if (! Test.isRunningTest()) {
            Messaging.sendEmail(emails);
        }
    }


    /*******************************************************************************
    *  Name            : preporationEmailsForSending(Opportunity currentOpportunity, String emailTemplateName)
    *  Summary         : prepares to send email    
    *  CreatedDate     : 15/05/2018
    *  Parameters      : Opportunity currentOpportunity, String emailTemplateName
    *  Returns         : all emails
    ******************************************************************************/
    public List<Messaging.SingleEmailMessage> preporationEmailsForSending(Opportunity currentOpportunity, String emailTemplateName) {
        EmailTemplate emailTemplate = [
            SELECT Id, Subject, HtmlValue, Body
            FROM EmailTemplate 
            WHERE DeveloperName = :emailTemplateName
            LIMIT 1];

        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateID(emailTemplate.Id); 
        mail.setTargetObjectId(currentOpportunity.OwnerId);
        mail.setSaveAsActivity(false);
        mail.setWhatId(currentOpportunity.Id);
        allmsg.add(mail);

        return allmsg;
    }


    /*******************************************************************************
    *  Name            : validate()
    *  Summary         : check current Opporunity StageName    
    *  CreatedDate     : 15/05/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void validate() {
        if (this.currentOpportunity.StageName == 'Closed Lost' && (this.currentOpportunity.Credit_check_date__c == null || this.daysAfterCreditCheck > 90)) {
            throw new StageException('You can Reopen Closed Lost Opportunity only within last 3 months "Credit check date');
        }
        if ( ! Approval.isLocked(this.currentOpportunity.Id) && this.currentOpportunity.Reopen__c == false) {
            throw new StageException('There was no request for reopen.');
        }
        if (this.currentOpportunity.StageName != 'Closed Lost' && this.currentOpportunity.StageName != 'CreditCheck abgelehnt' && this.currentOpportunity.StageName != 'Closed Won') {
            throw new StageException('This action is available for Closed Lost, Closed Won or CreditCheck rejected Opportunity Stage only.');
        }
        if ((this.currentOpportunity.StageName == 'Closed Won' || this.currentOpportunity.StageName == 'Closed Lost' || this.currentOpportunity.StageName == 'CreditCheck abgelehnt') && this.currentOpportunity.Account.GFN_Nr__c != null) {
            throw new StageException('The GFN Number must be empty.');
        }
        if (this.currentUser.Profile.Name != 'Credit' && this.currentUser.Profile.Name != 'System Administrator' &&
            this.currentUser.Profile.Name != 'Systemadministrator') {
            throw new StageException('Invalid User Profile.');
        }
    }


    /*******************************************************************************
    *  Name            : backToOpportunity()
    *  Summary         : back to opportunity  
    *  CreatedDate     : 15/05/2018
    *  Parameters      : -
    *  Returns         : opportunity page
    ******************************************************************************/
    public PageReference backToOpportunity() {
        PageReference page = new PageReference('/' + currentOpportunity.Id);
        return page;
    }

    public class StageException extends Exception {}
}