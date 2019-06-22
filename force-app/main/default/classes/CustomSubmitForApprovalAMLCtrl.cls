public with sharing class CustomSubmitForApprovalAMLCtrl {
    public List<Opportunity> oppList;
    public Opportunity opp {get; set;}
    public List<Account> accList;
    public Account acc {get; set;}
    public List<ProcessInstance> pi;
    public List<String> finalOpportunityFieldsList {get; set;}
    public List<String> finalAccountFieldsList {get; set;}
    private Map<String, User> subordinateUsersMap;

    public CustomSubmitForApprovalAMLCtrl() {      
    }

    public PageReference init() {
    try {    
        	String oppId = ApexPages.currentPage().getParameters().get('id');
        	this.oppList = [
        		SELECT Id, OwnerId, Name, StageName, AccountId, PIT_CIT_Annual_Financial_statement_for__c, Copy_of_national_ID_passport__c,
                       Details_of_REGON_CEIDG_or_KRS__c, Anzahl_der_Karten__c, Language_preference__c, RecordType.Name,
                       Requested_monthly_Company_Credit_Spend__c, AGB_Datenschutzhinweise_Richtigkeit__c, Data_Protection_Act_1998__c
        		FROM Opportunity
        		WHERE Id = :oppId
        		LIMIT 1];

            if (! oppList.isEmpty()) {
                User currentUser = [
                    SELECT UserRole.Name, Profile.Name, Name, UserRoleId
                    FROM User
                    WHERE Id = :UserInfo.getUserId()];

                this.subordinateUsersMap = new Map<String, User>([
                    SELECT Id
                    FROM User 
                    WHERE UserRole.ParentRoleId = :currentUser.UserRoleId
                ]);

                this.opp = oppList.get(0);

                this.accList = [
                    SELECT Id, NIP__c, Gesellschaftsform__c, Trading_Name__c, BillingCountry, YearStarted, Beschaeftigte__c
                    FROM Account
                    WHERE Id = :opp.AccountId
                    LIMIT 1];
                this.acc = accList.get(0);

                this.pi = [
                    SELECT TargetObjectId, Status, (SELECT ActorId, Comments, StepStatus FROM StepsAndWorkitems WHERE StepStatus != 'Started')
                    FROM ProcessInstance 
                    WHERE TargetObjectId = :this.opp.Id
                    ORDER BY CreatedDate DESC
                    LIMIT 1];

                validateOpportunity();
                this.finalOpportunityFieldsList = generateOppRequiredFieldsList();
                this.finalAccountFieldsList = generateAccRequiredFieldsList();

                if (this.pi.isEmpty()) {
                    validateSubmitForApprovalAML();
                    PageReference page = initiallySubmitForApprovalAML();
                    return page;
                } else {
                    validateResubmitForApprovalAML();
                    PageReference page = resubmitForApprovalAML();
                    return page;
                }   
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
        }       
        return null;
    }


    /*******************************************************************************
    *  Name            : initiallySubmitForApprovalAML()
    *  Summary         : Submit for approval (opportunity is submit for the first time)   
    *  CreatedDate     : 21/06/2017
    *  Parameters      : -
    *  Returns         : home page opportunity OR page with error and required fields
    ******************************************************************************/
    public PageReference initiallySubmitForApprovalAML() {
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments('Submitting request for Pending Credit AML.');
        req.setObjectId(this.opp.id);
        req.setProcessDefinitionNameOrId('CreditCheckAML_PL_Allstar');
        req.setSubmitterId(UserInfo.getUserId()); 
        req.setSkipEntryCriteria(false);
        String currentStageName;
        try {
            currentStageName = this.opp.StageName;
            this.opp.StageName = 'Pending Credit AML';
            update this.opp;
            Approval.process(req);  
        } catch (Exception e) {
            this.opp.StageName = currentStageName;
            update this.opp;
            String errorText = e.getMessage();
            if (errorText.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                errorText = errorText.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION,',': [');
            } else {
                errorText = 'This record does not meet the entry criteria. Please fill all required fields or contact your administrator for assistance.';
            }
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, errorText));
            return null;     
        }   
        PageReference page = new PageReference('/' + opp.Id);
        return page;
    }


    /*******************************************************************************
    *  Name            : resubmitForApprovalAML()
    *  Summary         : send for approval if Approval History not empty
    *  CreatedDate     : 21/06/2017
    *  Parameters      : -
    *  Returns         : opportunity page or validation page
    ******************************************************************************/
    public PageReference resubmitForApprovalAML() {
        if (this.pi.get(0).Status == 'Rejected') {
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Submitting request for Pending Credit AML.');
            req.setObjectId(this.opp.id);
            req.setProcessDefinitionNameOrId('CreditCheckAML_PL_Allstar');
            req.setSubmitterId(UserInfo.getUserId()); 
            req.setSkipEntryCriteria(false);
            String currentStageName;
            try {
                currentStageName = this.opp.StageName;
                this.opp.StageName = 'Pending Credit AML';
                update this.opp;
                Approval.process(req);                 
            } catch (Exception e) {
                this.opp.StageName = currentStageName;
                update this.opp;
                String errorText = e.getMessage();
                if (errorText.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                    errorText = errorText.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION,',': [');
                } else {
                    errorText = 'This record does not meet the entry criteria. Please fill all required fields or contact your administrator for assistance.';
                }
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, errorText));
                return null;   
            }   
            PageReference page = new PageReference('/' + this.opp.Id);
            return page;
        } else if (this.pi.get(0).Status == 'Pending') {
            this.opp.StageName = 'Pending Credit AML';
            update opp; 
            Approval.lock(this.opp.Id);

            List<Messaging.SingleEmailMessage> emails = preporationEmailsForSending('Submit_for_Credit_Check_AML_to_Credit');
            if (! Test.isRunningTest()) {
                Messaging.sendEmail(emails);
            } 
            PageReference page = new PageReference('/' + this.opp.Id);
            return page; 
        }      
        return null;
    } 


    /*******************************************************************************
    *  Name            : submitForApprovalAML() 
    *  Summary         : save opportunity and send for approval    
    *  CreatedDate     : 21/06/2017
    *  Parameters      : -
    *  Returns         : opportunity page
    ******************************************************************************/
    public PageReference submitForApprovalAML() {       
        try {
            if (! Test.isRunningTest()) {
                update this.acc;
                update this.opp; 
            } 
            if (this.pi.isEmpty()) {
                PageReference page = initiallySubmitForApprovalAML();
                return page;
            } else {
                validateResubmitForApprovalAML();
                PageReference page = resubmitForApprovalAML();
                return page;
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
        }       
        return null;
    }


    /*******************************************************************************
    *  Name            : preporationEmailsForSending(String emailTemplateName)
    *  Summary         : prepares to send email    
    *  CreatedDate     : 25/05/2017
    *  Parameters      : String emailTemplateName
    *  Returns         : all emails
    ******************************************************************************/
    public List<Messaging.SingleEmailMessage> preporationEmailsForSending(String emailTemplateName) {
        // getting email template id
        EmailTemplate emailTemplate = [
            SELECT Id, Subject, HtmlValue, Body
            FROM EmailTemplate 
            WHERE DeveloperName = :emailTemplateName
            LIMIT 1];

        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTemplateID(emailTemplate.Id); 
            if (! Test.isRunningTest()) {
                mail.setTargetObjectId(pi.get(0).StepsAndWorkitems.get(0).ActorId); 
            } 
            mail.setSaveAsActivity(false);
            mail.setWhatId(opp.Id);
            allmsg.add(mail);

            return allmsg;
    }


    /*******************************************************************************
    *  Name            : validateOpportunity()
    *  Summary         : validating RecordType and Country    
    *  CreatedDate     : 21/06/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void validateOpportunity() {
        //check Record Type
        if (this.opp.RecordType.Name != 'AllStar') {
            throw new MessageException('This button is only for opportunities with "AllStar" record types only');
        }
        //check country for AllStar
        if (this.opp.RecordType.Name == 'AllStar' && this.acc.BillingCountry != 'Poland') {
            throw new MessageException('There\'s no active approval process for this country with this Record type. Please select other country.');
        }
    }


    /*******************************************************************************
    *  Name            : validateSubmitForApprovalAML()
    *  Summary         : validate submit for approval AML (note: 00e20000001nSOBAA2 = 'System Administrator') 
    *  CreatedDate     : 29/06/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void validateSubmitForApprovalAML() {
        if (this.opp.OwnerId != UserInfo.getUserId() && UserInfo.getProfileId() != '00e20000001nSOBAA2' && ! this.subordinateUsersMap.containsKey(this.opp.OwnerId)) {
            throw new MessageException('Only opportunity owner can submit for approval AML.');
        }
    }


    /*******************************************************************************
    *  Name            : validateResubmitForApprovalAML()
    *  Summary         : validating Resubmit for approval AML (note: 00e20000001nSOBAA2 = 'System Administrator')
    *  CreatedDate     : 21/06/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void validateResubmitForApprovalAML() {
        if (this.opp.StageName == 'CreditCheck' || 
            this.opp.StageName == 'Credit Check - Pending Credit' || 
            this.opp.StageName == 'Pending Credit AML') {
            throw new MessageException('This opportunity is already in the stage of CreditCheck.');
        }
        if (this.pi.get(0).Status == 'Approved') {
            throw new MessageException('This opportunity was already approved.');
        }
        if (this.opp.OwnerId != UserInfo.getUserId() && UserInfo.getProfileId() != '00e20000001nSOBAA2' && ! this.subordinateUsersMap.containsKey(this.opp.OwnerId)) {
            throw new MessageException('Only opportunity owner can submit for approval AML.');
        }
        if (this.pi.get(0).Status == 'Pending') {
            if (this.opp.Anzahl_der_Karten__c == null || 
                this.opp.RecordType.Name != 'AllStar' ||  
                this.opp.Requested_monthly_Company_Credit_Spend__c == null ||
                this.opp.AGB_Datenschutzhinweise_Richtigkeit__c == false || 
                this.opp.Data_Protection_Act_1998__c == false ||
                this.opp.PIT_CIT_Annual_Financial_statement_for__c == false ||
                this.opp.Copy_of_national_ID_passport__c == false || 
                this.opp.Details_of_REGON_CEIDG_or_KRS__c == false ||
                this.acc.BillingCountry != 'Poland' || 
                this.acc.Beschaeftigte__c == null || 
                this.acc.NIP__c == null || 
                this.acc.Gesellschaftsform__c == null ||
                this.acc.Trading_Name__c == null || 
                this.acc.YearStarted == null) {
                throw new MessageException('This record does not meet the entry criteria. Please fill all required fields or contact your administrator for assistance.'); 
            }
            if (this.opp.StageName == 'Pending Sales - Token payment') {
                throw new MessageException('Please use "Waiting for token payment" button.');
            } else if (this.opp.StageName != 'Pending Sales – PIT/CIT' && this.opp.StageName != 'Pending Sales – AML doc.' &&
                       this.opp.StageName != 'Pending Sales – Information' && this.opp.StageName != 'Pending Sales – Deposit') {
                throw new MessageException('Invalid stage for current approval process.');
            }
        }
    }


    /*******************************************************************************
    *  Name            : generateOppRequiredFieldsList()
    *  Summary         : generate Opportunity Required Fields List    
    *  CreatedDate     : 21/06/2017
    *  Parameters      : currentUserProfile
    *  Returns         : fields list
    ******************************************************************************/
    public List<String> generateOppRequiredFieldsList() {
        if (this.acc.BillingCountry == 'Poland') { return oppFieldsAllStarList_PL; } 
        return null; 
    }


    /*******************************************************************************
    *  Name            : generateAccRequiredFieldsList()
    *  Summary         : generate Account Required Fields List    
    *  CreatedDate     : 21/06/2017
    *  Parameters      : -
    *  Returns         : fields list
    ******************************************************************************/
    public List<String> generateAccRequiredFieldsList() {
        if (this.acc.BillingCountry == 'Poland') { return accFieldsAllStarList_PL; } 
        return null; 
    }
        

    /*******************************************************************************
    *  Name            : saveAndBack()
    *  Summary         : back to opportunity with saving    
    *  CreatedDate     : 24/05/2017
    *  Parameters      : -
    *  Returns         : opportunity page
    ******************************************************************************/
    public PageReference saveAndBack() {
    	if (this.opp.StageName == 'CreditCheck' || 
            this.opp.StageName == 'Credit Check - Pending Credit' || 
            this.opp.StageName == 'Pending Credit AML' ||
            this.opp.StageName == 'Closed Won') {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You can\'t save. This opportunity is locked.'));
                PageReference page = new PageReference('/apex/CustomSubmitForApprovalAML?id=' + opp.Id);
                return page;
        } else {
            update this.opp;
            update this.acc;
            PageReference page = new PageReference('/' + this.opp.Id);
            return page;
        }
    }


    /*******************************************************************************
    *  Name            : backToOpportunity()
    *  Summary         : back to opportunity without saving    
    *  CreatedDate     : 24/05/2017
    *  Parameters      : -
    *  Returns         : opportunity page
    ******************************************************************************/
    public PageReference backToOpportunity() {
    	PageReference page = new PageReference('/' + this.opp.Id);
    	return page;
    }


    /*******************************************************************************
    *  Name            : changeRegisteredCountry()
    *  Summary         : return account page    
    *  CreatedDate     : 29/05/2017
    *  Parameters      : -
    *  Returns         : account page
    ******************************************************************************/
    public PageReference changeRegisteredCountry() {
        PageReference page = new PageReference('/' + acc.Id);
        return page;
    }

    public class MessageException extends Exception {}


    //1.1 Opportunity required fields for CreditCheck_PL_AllStar approval process (Poland)
    public static List<String> oppFieldsAllStarList_PL = new List<String> {
        'Anzahl_der_Karten__c',
        'Requested_monthly_Company_Credit_Spend__c',
        'Data_Protection_Act_1998__c',
        'AGB_Datenschutzhinweise_Richtigkeit__c',
        'PIT_CIT_Annual_Financial_statement_for__c',
        'Copy_of_national_ID_passport__c',
        'Details_of_REGON_CEIDG_or_KRS__c'   
    };
    
    //1.2 Account required fields for CreditCheck_PL_AllStar approval process (Poland)
    public static List<String> accFieldsAllStarList_PL = new List<String> {
        'NIP__c',
        'Gesellschaftsform__c',
        'Trading_Name__c',
        'YearStarted',
        'Beschaeftigte__c'
    };
}