public with sharing class CustomSubmitForApprovalCtrl {
    // public List<Opportunity> oppList;
    public Opportunity opp {get; set;}
    // public List<Account> accList;
    public Account acc {get; set;}
    public List<ProcessInstance> pi;
    public List<String> finalOpportunityFieldsList {get; set;}
    public List<String> finalAccountFieldsList {get; set;}
    private Map<String, User> subordinateUsersMap;
    public String type {get; set;}
    public String oppId;


    public CustomSubmitForApprovalCtrl() {}

    public PageReference init() {
        try {
            if (this.oppId == null) {
                this.oppId = ApexPages.currentPage().getParameters().get('id');
            }
            this.type = ApexPages.currentPage().getParameters().get('type');
            User currentUser = [
                SELECT UserRole.Name, Profile.Name, Name, UserRoleId
                FROM User
                WHERE Id = :UserInfo.getUserId()];

            this.subordinateUsersMap = new Map<String, User>([
                SELECT Id
                FROM User 
                WHERE UserRole.ParentRoleId = :currentUser.UserRoleId
            ]);

            List<Opportunity> oppList = [
                SELECT Id, OwnerId, Owner.UserRole.Name, Name, StageName, Owner.Name, Zahlungsart__c, AccountId, Requested_monthly_Company_Credit_Spend__c, RecordType.Name,
                       AGB_Datenschutzhinweise_Richtigkeit__c, Data_Protection_Act_1998__c, Anzahl_der_Karten__c, Language_preference__c, bearbeitet_von__c,
                       Name_of_the_payer_Account_holder__c, Derzeitige_Zahlungsmethode__c, Direct_Debit_Mandate_Type__c, IBAN__c, SWIFT_BIC__c, Total_consumption_l_month__c, Zahlungsziel__c,
                       Zahlungssystem__c, Bank__c, Tankkarte_Emittent__c, Product__c, Angebotsdauer__c, Home_Station__c, Sec_Channel__c, Channel__c,
                       Eco_Fee__c, ESI__c, Registered_Country__c, CF_Stage__c, Last_CF_Errors__c, (SELECT Id FROM Credit_Factory_Reports__r WHERE CreatedDate > :Date.today().addMonths(-30))
                FROM Opportunity 
                WHERE Id = :oppId
                LIMIT 1];

            if (! oppList.isEmpty()) {
                this.opp = oppList.get(0);

                List<Account> accList = [
                    SELECT Id, NIP__c, Gesellschaftsform__c, Trading_Name__c, BillingCountry, YearStarted, Beschaeftigte__c, Bundesland__c, OwnerId
                    FROM Account
                    WHERE Id = :opp.AccountId 
                    LIMIT 1];
                this.acc = accList.get(0);

                this.pi = [
                    SELECT TargetObjectId, Status, ProcessDefinitionId, (SELECT ActorId, Comments, StepStatus FROM StepsAndWorkitems WHERE StepStatus != 'Started')
                    FROM ProcessInstance 
                    WHERE TargetObjectId = :this.opp.Id
                    ORDER BY CreatedDate DESC
                    LIMIT 1];

                validateOpportunity();
                this.finalOpportunityFieldsList = generateOppRequiredFieldsList(currentUser.Profile.Name);
                this.finalAccountFieldsList = generateAccRequiredFieldsList(currentUser.Profile.Name);

                PageReference page;
                if (this.type == 'submitforapproval') {
                    if (this.pi.isEmpty() || this.pi.get(0).Status == 'Approved') {
                        validateSubmitForApproval();
                        page = initiallySubmitForApproval();
                    } else {
                        String approveProcessName = [SELECT DeveloperName FROM ProcessDefinition WHERE Id = :this.pi.get(0).ProcessDefinitionId].DeveloperName;
                        validateResubmitForApproval(approveProcessName);
                        page = resubmitForApproval();  
                    }
                } else 
                if (this.type == 'creditfactory') {
                    // Credit factory redirect
                    page = redirectToCreditFactory();
                }

                return page;     
            }
        } catch (Exception e) {
            if (ApexPages.currentPage() != null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
            } else {
                ExceptionLogger.sendException(String.valueOf(e.getMessage()), String.valueOf(e.getStackTraceString()));
            }
        }       
        return null;    
    }

    /*******************************************************************************
    *  Name            : initiallySubmitForApproval()
    *  Summary         : Submit for approval (opportunity is submit for the first time)   
    *  CreatedDate     : 06/06/2017
    *  ModifiedDate    : 05/04/2019
    *  Parameters      : -
    *  Returns         : home page opportunity OR page with error and required fields
    ******************************************************************************/
    public PageReference initiallySubmitForApproval() {
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments('Submitting request for CreditCheck.');
        req.setObjectId(this.opp.id);
        req.setSubmitterId(UserInfo.getUserId()); 
        req.setSkipEntryCriteria(false);
        String currentStageName;
        String currentCFStageName;
        try {
            currentStageName = this.opp.StageName;
            currentCFStageName = this.opp.CF_Stage__c;
            this.opp.StageName = 'CreditCheck';
            if (this.opp.CF_Stage__c != 'Pending deposit' && this.opp.CF_Stage__c != 'Pending Credit - Contract Check') {
                this.opp.CF_Stage__c = 'Manual Scoring';
            }
            update this.opp;
            Approval.process(req);  
        } catch (Exception e) {
            this.opp.StageName = currentStageName;
            this.opp.CF_Stage__c = currentCFStageName;
            update this.opp;
            String errorText = e.getMessage();
            if (errorText.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                errorText = errorText.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ',': [');
            } else {
                errorText = 'This record does not meet the entry criteria. Please fill all required fields or contact your administrator for assistance.';
            }
            if (ApexPages.currentPage() != null) {  
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, errorText));
            } else {
                ExceptionLogger.sendException(String.valueOf(e.getMessage()), String.valueOf(e.getStackTraceString()));
            }
            return null;     
        }   
        PageReference page = new PageReference('/' + opp.Id);
        return page;
    }


    /*******************************************************************************
    *  Name            : resubmitForApproval()
    *  Summary         : send for approval if Approval History not empty
    *  CreatedDate     : 07/06/2017
    *  ModifiedDate    : 05/04/2019
    *  Parameters      : -
    *  Returns         : opportunity page or validation page
    ******************************************************************************/
    public PageReference resubmitForApproval() {
        if (this.pi.get(0).Status == 'Rejected') {
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Submitting request for CreditCheck.');
            req.setObjectId(this.opp.id);
            req.setSubmitterId(UserInfo.getUserId()); 
            req.setSkipEntryCriteria(false);
            String currentStageName;
            String currentCFStageName;
            try {
                currentStageName = this.opp.StageName;
                currentCFStageName = this.opp.CF_Stage__c;
                this.opp.StageName = 'CreditCheck';
                if (this.opp.CF_Stage__c != 'Pending deposit' && this.opp.CF_Stage__c != 'Pending Credit - Contract Check') {
                    this.opp.CF_Stage__c = 'Manual Scoring';
                }
                update this.opp;
                Approval.process(req);                 
            } catch (Exception e) {
                this.opp.StageName = currentStageName;
                this.opp.CF_Stage__c = currentCFStageName;
                update this.opp;
                String errorText = e.getMessage();          
                if (errorText.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                    errorText = errorText.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ',': [');
                } else {
                    errorText = 'This record does not meet the entry criteria. Please fill all required fields or contact your administrator for assistance.';
                }
                if (ApexPages.currentPage() != null) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, errorText));
                } else {
                    ExceptionLogger.sendException(String.valueOf(e.getMessage()), String.valueOf(e.getStackTraceString()));
                }
                return null;    
            }   
            PageReference page = new PageReference('/' + this.opp.Id);
            return page;
        } else if (this.pi.get(0).Status == 'Pending') {
            if (this.opp.RecordType.Name == 'AllStar') {
                this.opp.StageName = 'Pending Credit Check';
                update opp; 
                Approval.lock(this.opp.Id);

                List<Messaging.SingleEmailMessage> emails = preporationEmailsForSending('Information_Required_to_Credit');
                if (! Test.isRunningTest()) {
                    Messaging.sendEmail(emails);
                } 
                PageReference page = new PageReference('/' + this.opp.Id);
                return page; 
            } else if (this.opp.RecordType.Name == 'Euroshell' || this.opp.RecordType.Name == 'Euroshell Starts') {
                this.opp.StageName = 'Credit Check - Pending Credit';
                if (this.opp.CF_Stage__c != 'Pending deposit' && this.opp.CF_Stage__c != 'Pending Credit - Contract Check') {
                    this.opp.CF_Stage__c = 'Manual Scoring';
                }
                update opp; 
                Approval.lock(this.opp.Id);
                PageReference page = new PageReference('/' + this.opp.Id);
                return page;
            }
        }      
        return null;
    }


    /*******************************************************************************
    *  Name            : submitForApprovalFromValidationPage() 
    *  Summary         : save opportunity and send for approval    
    *  CreatedDate     : 24/05/2017
    *  Parameters      : -
    *  Returns         : opportunity page or validation page
    ******************************************************************************/
    public PageReference submitForApprovalFromValidationPage() {     
        try {
            if (! Test.isRunningTest()) {
                update this.acc;
                update this.opp; 
            }
            if (this.pi.isEmpty() || this.pi.get(0).Status == 'Approved') {
                validateSubmitForApproval();
                PageReference page = initiallySubmitForApproval();
                return page;
            } else {
                String approveProcessName = [SELECT DeveloperName FROM ProcessDefinition WHERE Id = :this.pi.get(0).ProcessDefinitionId].DeveloperName;
                validateResubmitForApproval(approveProcessName);
                PageReference page = resubmitForApproval();
                return page;
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
        }       
        return null;
    }


    /*******************************************************************************
    *  Name            : preporationEmailsForSending()
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
        Messaging.SingleEmailMessage mailToCredit = new Messaging.SingleEmailMessage();
        //email for credit
        mailToCredit.setTemplateID(emailTemplate.Id); 
        if (! Test.isRunningTest()) {
            mailToCredit.setTargetObjectId(pi.get(0).StepsAndWorkitems.get(0).ActorId); 
        } 
        mailToCredit.setSaveAsActivity(false);
        mailToCredit.setWhatId(opp.Id);
        allmsg.add(mailToCredit);

        return allmsg;  
    }


    /*******************************************************************************
    *  Name            : returnOpportunityStage()
    *  Summary         : returns Stagename of the current opportunity depending on the Record type   
    *  CreatedDate     : 05/07/2017
    *  Parameters      : -
    *  Returns         : String stageName
    ******************************************************************************/
    public String returnOpportunityStage() {
        String stageName;
        if (this.opp.RecordType.Name == 'Euroshell' || this.opp.RecordType.Name == 'Euroshell Starts') {
            stageName = 'Credit Check - Pending Credit';
        } else if (this.opp.RecordType.Name == 'AllStar') {
            stageName = 'Pending Credit Check';
        }
        return stageName;
    }


    /*******************************************************************************
    *  Name            : redirectToCreditFactory() 
    *  Summary         : Redirect to Credit Factory Finder     
    *  CreatedDate     : 21/12/2017
    *  ModifiedDate    : 
    *  Parameters      : 
    *  Returns         : PageReference
    ******************************************************************************/
    public PageReference redirectToCreditFactory() {
        try {
            validateCreditFactory();
            update this.opp;
            update this.acc;
            return new PageReference('/apex/CreditFactoryFinder?id=' + this.opp.Id);
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
            return null;
        }
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
        if (this.opp.RecordType.Name != 'Euroshell' && this.opp.RecordType.Name != 'Euroshell Starts' && 
            this.opp.RecordType.Name != 'AllStar') {
            throw new MessageException('This button is only for opportunities with "Euroshell", "Euroshell Starts", "AllStar" record types only');
        }
        //check country for Euroshell
        if ((this.opp.RecordType.Name == 'Euroshell' || this.opp.RecordType.Name == 'Euroshell Starts') &&
            this.acc.BillingCountry != 'Germany' &&
            this.acc.BillingCountry != 'Austria' && 
            (! this.acc.BillingCountry.contains('Belgium')) &&
            this.acc.BillingCountry != 'Netherlands' &&
            this.acc.BillingCountry != 'Hungary' && 
            this.acc.BillingCountry != 'Poland' &&
            (! this.acc.BillingCountry.contains('Switzerland')) && 
            this.acc.BillingCountry != 'Luxembourg' && 
            this.acc.BillingCountry != 'Slovakia' &&
            this.acc.BillingCountry != 'Czech Republic' && 
            this.acc.BillingCountry != 'France') {
            throw new MessageException('There\'s no active approval process for this country with this Record type. Please select other country.');
        }
        //check country for AllStar
        if (this.opp.RecordType.Name == 'AllStar' && this.acc.BillingCountry != 'Poland') {
            throw new MessageException('There\'s no active approval process for this country with this Record type. Please select other country.');
        }
    }


    /*******************************************************************************
    *  Name            : validateSubmitForApproval()
    *  Summary         : validate submit for approval (note: 00e20000001nSOBAA2 = 'System Administrator')    
    *  CreatedDate     : 29/06/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void validateSubmitForApproval() {
        if (this.opp.OwnerId != UserInfo.getUserId() && UserInfo.getProfileId() != '00e20000001nSOBAA2' && ! this.subordinateUsersMap.containsKey(this.opp.OwnerId)) {
            throw new MessageException('Only opportunity owner can submit for approval.');
        }
        if (this.opp.OwnerId != this.acc.OwnerId && UserInfo.getProfileId() != '00e20000001nSOBAA2') {
            throw new MessageException('Opportunity owner should be the same as Account owner.');
        }
        if (this.opp.CF_Stage__c != null && this.opp.CF_Stage__c.contains('Pending Credit Report')) {
            throw new MessageException('Please waiting for Credit Report.');
        }
        if ((this.opp.Registered_Country__c == 'Germany' || this.opp.Registered_Country__c == 'Netherlands' || this.opp.Registered_Country__c == 'Belgium-NL' ||
                this.opp.Registered_Country__c == 'France' || this.opp.Registered_Country__c == 'Belgium-FR' || this.opp.Registered_Country__c == 'Poland' ||
                this.opp.Registered_Country__c == 'Hungary' || this.opp.Registered_Country__c == 'Austria' || this.opp.Registered_Country__c == 'Switzerland-DE' ||
                this.opp.Registered_Country__c == 'Switzerland-FR' || this.opp.Registered_Country__c == 'Switzerland-IT' || this.opp.Registered_Country__c == 'Luxembourg') && 
                this.opp.RecordType.Name == 'Euroshell' && this.opp.CF_Stage__c != 'Pending deposit' && this.opp.CF_Stage__c != 'Pending Credit - Contract Check' && 
                this.opp.Last_CF_Errors__c == null) {
            throw new MessageException('Please process your Opportunity in Credit Factory before submitting it for manual review.');
        }
    }


    /*******************************************************************************
    *  Name            : validateCreditFactory()
    *  Summary         : Validate fields for available countries
    *  CreatedDate     : 21/12/2017
    *  ModifiedDate    : 10/04/2019
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    public void validateCreditFactory() {
        if (this.opp.OwnerId != this.acc.OwnerId && UserInfo.getProfileId() != '00e20000001nSOBAA2') {
            throw new MessageException('Opportunity owner should be the same as Account owner.');
        }
        if ((this.opp.StageName == 'CreditCheck' ||
             this.opp.StageName == 'Pending Credit Check' || 
             this.opp.StageName == 'Credit Check - Pending Credit' || 
             this.opp.StageName == 'Pending Credit AML') &&
             this.opp.Bearbeitet_von__c != null) {
            throw new MessageException('Your Customer is already on Credit review.');
        }
        if (this.opp.Total_consumption_l_month__c == 0) {
            throw new MessageException('You cannot launch Credit Factory for a customer with 0 Total consumption (l/month).');
        }

        if (this.opp.RecordType.Name == 'Euroshell' || this.opp.RecordType.Name == 'Euroshell Starts') {
            if ((this.acc.BillingCountry == 'Germany' || this.acc.BillingCountry == 'Austria') &&
                (this.opp.Anzahl_der_Karten__c == null ||
                this.opp.Language_preference__c == null ||
                this.opp.Total_consumption_l_month__c == null ||
                this.opp.Derzeitige_Zahlungsmethode__c == null ||
                this.acc.Beschaeftigte__c == null ||
                ((this.opp.Derzeitige_Zahlungsmethode__c == 'Bankkarte' || this.opp.Derzeitige_Zahlungsmethode__c == 'Kreditkarte') && (this.opp.Zahlungssystem__c == null || this.opp.Bank__c == null)) ||
                (this.opp.Derzeitige_Zahlungsmethode__c == 'Tankkarte' && this.opp.Tankkarte_Emittent__c == null) ||
                this.opp.Zahlungsart__c == null ||
                (this.opp.Zahlungsart__c == 'Lastschrift' && (this.opp.Direct_Debit_Mandate_Type__c == null || this.opp.IBAN__c == null || this.opp.SWIFT_BIC__c == null)) ||
                ((this.opp.Product__c == 'Home Station offer (v.1)' || this.opp.Product__c == 'Sales no fee promo Feb 2016') && this.opp.Home_Station__c == null)
                )) {
                throw new MessageException('This record does not meet the entry criteria. Please fill all required fields or contact your administrator for assistance.');
            } else if (this.acc.BillingCountry.contains('Belgium') &&
                (this.opp.Anzahl_der_Karten__c == null ||
                this.opp.Language_preference__c == null ||
                this.opp.Derzeitige_Zahlungsmethode__c == null ||
                this.acc.Beschaeftigte__c == null ||
                ((this.opp.Derzeitige_Zahlungsmethode__c == 'Bankkarte' || this.opp.Derzeitige_Zahlungsmethode__c == 'Kreditkarte') && (this.opp.Zahlungssystem__c == null || this.opp.Bank__c == null)) ||
                (this.opp.Derzeitige_Zahlungsmethode__c == 'Tankkarte' && this.opp.Tankkarte_Emittent__c == null) ||
                this.opp.Zahlungsart__c == null ||
                (this.opp.Zahlungsart__c == 'Lastschrift' && (this.opp.Direct_Debit_Mandate_Type__c == null || this.opp.IBAN__c == null || this.opp.SWIFT_BIC__c == null)) ||
                ((this.opp.Product__c == 'Home Station offer (v.1)' || this.opp.Product__c == 'Sales no fee promo Feb 2016') && this.opp.Home_Station__c == null)
                )) {
                throw new MessageException('This record does not meet the entry criteria. Please fill all required fields or contact your administrator for assistance.');
            } else if (this.acc.BillingCountry == 'Netherlands' &&
                (this.opp.Anzahl_der_Karten__c == null ||
                this.opp.Language_preference__c == null ||
                this.opp.Derzeitige_Zahlungsmethode__c == null ||
                this.acc.Beschaeftigte__c == null ||
                ((this.opp.Derzeitige_Zahlungsmethode__c == 'Bankkarte' || this.opp.Derzeitige_Zahlungsmethode__c == 'Kreditkarte') && (this.opp.Zahlungssystem__c == null || this.opp.Bank__c == null)) ||
                (this.opp.Derzeitige_Zahlungsmethode__c == 'Tankkarte' && this.opp.Tankkarte_Emittent__c == null) ||
                this.opp.Zahlungsart__c == null ||
                (this.opp.Zahlungsart__c == 'Lastschrift' && (this.opp.Direct_Debit_Mandate_Type__c == null || this.opp.IBAN__c == null || this.opp.SWIFT_BIC__c == null)) ||
                ((this.opp.Product__c == 'Home Station offer (v.1)' || this.opp.Product__c == 'Sales no fee promo Feb 2016') && this.opp.Home_Station__c == null)
                )) {
                throw new MessageException('This record does not meet the entry criteria. Please fill all required fields or contact your administrator for assistance.');
            } else if (this.acc.BillingCountry == 'France' &&
                (this.opp.Anzahl_der_Karten__c == null ||
                this.opp.Language_preference__c == null ||
                this.opp.Derzeitige_Zahlungsmethode__c == null ||
                this.acc.Beschaeftigte__c == null ||
                ((this.opp.Derzeitige_Zahlungsmethode__c == 'Bankkarte' || this.opp.Derzeitige_Zahlungsmethode__c == 'Kreditkarte') && (this.opp.Zahlungssystem__c == null || this.opp.Bank__c == null)) ||
                (this.opp.Derzeitige_Zahlungsmethode__c == 'Tankkarte' && this.opp.Tankkarte_Emittent__c == null) ||
                this.opp.Zahlungsart__c == null ||
                (this.opp.Zahlungsart__c == 'Lastschrift' && (this.opp.Direct_Debit_Mandate_Type__c == null || this.opp.IBAN__c == null || this.opp.SWIFT_BIC__c == null)) ||
                ((this.opp.Product__c == 'Home Station offer (v.1)' || this.opp.Product__c == 'Sales no fee promo Feb 2016') && this.opp.Home_Station__c == null)
                )) {
                throw new MessageException('This record does not meet the entry criteria. Please fill all required fields or contact your administrator for assistance.');
            } else if (this.acc.BillingCountry == 'Poland' &&
                (this.opp.Anzahl_der_Karten__c == null ||
                this.opp.Language_preference__c == null ||
                this.opp.Derzeitige_Zahlungsmethode__c == null ||
                this.acc.Beschaeftigte__c == null ||
                ((this.opp.Derzeitige_Zahlungsmethode__c == 'Bankkarte' || this.opp.Derzeitige_Zahlungsmethode__c == 'Kreditkarte') && (this.opp.Zahlungssystem__c == null || this.opp.Bank__c == null)) ||
                (this.opp.Derzeitige_Zahlungsmethode__c == 'Tankkarte' && this.opp.Tankkarte_Emittent__c == null) ||
                this.opp.Zahlungsart__c == null ||
                (this.opp.Zahlungsart__c == 'Lastschrift' && (this.opp.IBAN__c == null || this.opp.SWIFT_BIC__c == null)) ||
                ((this.opp.Product__c == 'Home Station offer (v.1)' || this.opp.Product__c == 'Sales no fee promo Feb 2016') && this.opp.Home_Station__c == null)
                )) {
                throw new MessageException('This record does not meet the entry criteria. Please fill all required fields or contact your administrator for assistance.');
            } else if (this.acc.BillingCountry == 'Hungary' &&
                (this.opp.Anzahl_der_Karten__c == null ||
                this.opp.Language_preference__c == null ||
                this.opp.Derzeitige_Zahlungsmethode__c == null ||
                this.acc.Beschaeftigte__c == null ||
                ((this.opp.Derzeitige_Zahlungsmethode__c == 'Bankkarte' || this.opp.Derzeitige_Zahlungsmethode__c == 'Kreditkarte') && (this.opp.Zahlungssystem__c == null || this.opp.Bank__c == null)) ||
                (this.opp.Derzeitige_Zahlungsmethode__c == 'Tankkarte' && this.opp.Tankkarte_Emittent__c == null) ||
                this.opp.Zahlungsart__c == null ||
                (this.opp.Zahlungsart__c == 'Lastschrift' && (this.opp.IBAN__c == null || this.opp.SWIFT_BIC__c == null)) ||
                ((this.opp.Product__c == 'Home Station offer (v.1)' || this.opp.Product__c == 'Sales no fee promo Feb 2016') && this.opp.Home_Station__c == null)
                )) {
                throw new MessageException('This record does not meet the entry criteria. Please fill all required fields or contact your administrator for assistance.');
            } else if (this.acc.BillingCountry.contains('Switzerland') &&
                (this.opp.Anzahl_der_Karten__c == null ||
                this.opp.Language_preference__c == null ||
                this.opp.Derzeitige_Zahlungsmethode__c == null ||
                this.acc.Beschaeftigte__c == null ||
                ((this.opp.Derzeitige_Zahlungsmethode__c == 'Bankkarte' || this.opp.Derzeitige_Zahlungsmethode__c == 'Kreditkarte') && (this.opp.Zahlungssystem__c == null || this.opp.Bank__c == null)) ||
                (this.opp.Derzeitige_Zahlungsmethode__c == 'Tankkarte' && this.opp.Tankkarte_Emittent__c == null) ||
                this.opp.Zahlungsart__c == null ||
                (this.opp.Zahlungsart__c == 'Lastschrift' && (this.opp.IBAN__c == null || this.opp.SWIFT_BIC__c == null)) ||
                ((this.opp.Product__c == 'Home Station offer (v.1)' || this.opp.Product__c == 'Sales no fee promo Feb 2016') && this.opp.Home_Station__c == null)
                )) {
                throw new MessageException('This record does not meet the entry criteria. Please fill all required fields or contact your administrator for assistance.');
            } else if (this.acc.BillingCountry == 'Luxembourg' &&
                (this.opp.Anzahl_der_Karten__c == null ||
                this.opp.Language_preference__c == null ||
                this.opp.Derzeitige_Zahlungsmethode__c == null ||
                this.acc.Beschaeftigte__c == null ||
                ((this.opp.Derzeitige_Zahlungsmethode__c == 'Bankkarte' || this.opp.Derzeitige_Zahlungsmethode__c == 'Kreditkarte') && (this.opp.Zahlungssystem__c == null || this.opp.Bank__c == null)) ||
                (this.opp.Derzeitige_Zahlungsmethode__c == 'Tankkarte' && this.opp.Tankkarte_Emittent__c == null) ||
                this.opp.Zahlungsart__c == null ||
                (this.opp.Zahlungsart__c == 'Lastschrift' && (this.opp.Direct_Debit_Mandate_Type__c == null || this.opp.IBAN__c == null || this.opp.SWIFT_BIC__c == null)) ||
                ((this.opp.Product__c == 'Home Station offer (v.1)' || this.opp.Product__c == 'Sales no fee promo Feb 2016') && this.opp.Home_Station__c == null)
                )) {
                throw new MessageException('This record does not meet the entry criteria. Please fill all required fields or contact your administrator for assistance.');
            }
        }
    }


    /*******************************************************************************
    *  Name            : validateResubmitForApproval(String approveProcessName)
    *  Summary         : validating Resubmit For Approval (note: 00e20000001nSOBAA2 = 'System Administrator')
    *  CreatedDate     : 21/06/2017
    *  Parameters      : String approveProcessName
    *  Returns         : void
    ******************************************************************************/
    public void validateResubmitForApproval(String approveProcessName) {
        if (this.opp.OwnerId != UserInfo.getUserId() && UserInfo.getProfileId() != '00e20000001nSOBAA2' && ! this.subordinateUsersMap.containsKey(this.opp.OwnerId)) {
            throw new MessageException('Only opportunity owner can submit for approval.');
        }
        if (this.opp.OwnerId != this.acc.OwnerId && UserInfo.getProfileId() != '00e20000001nSOBAA2') {
            throw new MessageException('Opportunity owner should be the same as Account owner.');
        }
        if (this.opp.CF_Stage__c != null && this.opp.CF_Stage__c.contains('Pending Credit Report')) {
            throw new MessageException('Please waiting for Credit Report.');
        }
        if ((this.opp.Registered_Country__c == 'Germany' || this.opp.Registered_Country__c == 'Netherlands' || this.opp.Registered_Country__c == 'Belgium-NL' ||
                this.opp.Registered_Country__c == 'France' || this.opp.Registered_Country__c == 'Belgium-FR' || this.opp.Registered_Country__c == 'Poland' ||
                this.opp.Registered_Country__c == 'Hungary' || this.opp.Registered_Country__c == 'Austria' || this.opp.Registered_Country__c == 'Switzerland-DE' ||
                this.opp.Registered_Country__c == 'Switzerland-FR' || this.opp.Registered_Country__c == 'Switzerland-IT' || this.opp.Registered_Country__c == 'Luxembourg') &&
                this.opp.RecordType.Name == 'Euroshell' && this.opp.CF_Stage__c != 'Pending deposit' && this.opp.CF_Stage__c != 'Pending Credit - Contract Check' && 
                this.opp.Last_CF_Errors__c == null) {
            throw new MessageException('Please process your Opportunity in Credit Factory before submitting it for manual review.');
        }
        if (this.opp.StageName == 'CreditCheck' ||
            this.opp.StageName == 'Pending Credit Check' || 
            this.opp.StageName == 'Credit Check - Pending Credit' || 
            this.opp.StageName == 'Pending Credit AML') {
            throw new MessageException('This opportunity is already in the stage of CreditCheck.');
        }
        if (this.opp.RecordType.Name == 'Euroshell' || this.opp.RecordType.Name == 'Euroshell Starts') {
            if (this.pi.get(0).Status == 'Pending') {
                if (this.opp.StageName != 'Pending Sales – Information' && this.opp.StageName != 'Pending Sales – Deposit') {
                    throw new MessageException('This action is available for Pending Sales Opportunity Stage only.');
                }
                if (approveProcessName == 'CreditCheck' &&
                    ((this.acc.BillingCountry != 'Germany' && this.acc.BillingCountry != 'Austria') ||
                    this.opp.Anzahl_der_Karten__c == null ||
                    this.opp.Language_preference__c == null ||
                    this.opp.Total_consumption_l_month__c == null ||
                    this.opp.Derzeitige_Zahlungsmethode__c == null ||
                    this.acc.Beschaeftigte__c == null ||
                    ((this.opp.Derzeitige_Zahlungsmethode__c == 'Bankkarte' || this.opp.Derzeitige_Zahlungsmethode__c == 'Kreditkarte') && (this.opp.Zahlungssystem__c == null || this.opp.Bank__c == null)) ||
                    (this.opp.Derzeitige_Zahlungsmethode__c == 'Tankkarte' && this.opp.Tankkarte_Emittent__c == null) ||
                    this.opp.Zahlungsart__c == null ||
                    (this.opp.Zahlungsart__c == 'Lastschrift' && (this.opp.Direct_Debit_Mandate_Type__c == null || this.opp.IBAN__c == null || this.opp.SWIFT_BIC__c == null)) ||
                    ((this.opp.Product__c == 'Home Station offer (v.1)' || this.opp.Product__c == 'Sales no fee promo Feb 2016') && this.opp.Home_Station__c == null)
                    )) {
                    throw new MessageException('This record does not meet the entry criteria. Please fill all required fields or contact your administrator for assistance.');
                } else if (approveProcessName == 'CreditCheck_BE' && 
                    (! this.acc.BillingCountry.contains('Belgium') ||
                    this.opp.Anzahl_der_Karten__c == null ||
                    this.opp.Language_preference__c == null ||
                    this.opp.Derzeitige_Zahlungsmethode__c == null ||
                    this.acc.Beschaeftigte__c == null ||
                    ((this.opp.Derzeitige_Zahlungsmethode__c == 'Bankkarte' || this.opp.Derzeitige_Zahlungsmethode__c == 'Kreditkarte') && (this.opp.Zahlungssystem__c == null || this.opp.Bank__c == null)) ||
                    (this.opp.Derzeitige_Zahlungsmethode__c == 'Tankkarte' && this.opp.Tankkarte_Emittent__c == null) ||
                    this.opp.Zahlungsart__c == null ||
                    (this.opp.Zahlungsart__c == 'Lastschrift' && (this.opp.Direct_Debit_Mandate_Type__c == null || this.opp.IBAN__c == null || this.opp.SWIFT_BIC__c == null)) ||
                    ((this.opp.Product__c == 'Home Station offer (v.1)' || this.opp.Product__c == 'Sales no fee promo Feb 2016') && this.opp.Home_Station__c == null)
                    )) {
                    throw new MessageException('This record does not meet the entry criteria. Please fill all required fields or contact your administrator for assistance.');
                } else if (approveProcessName == 'CreditCheck_BeNeFra' &&
                    (this.acc.BillingCountry != 'Netherlands' ||
                    this.opp.Anzahl_der_Karten__c == null ||
                    this.opp.Language_preference__c == null ||
                    this.opp.Derzeitige_Zahlungsmethode__c == null ||
                    this.acc.Beschaeftigte__c == null ||
                    ((this.opp.Derzeitige_Zahlungsmethode__c == 'Bankkarte' || this.opp.Derzeitige_Zahlungsmethode__c == 'Kreditkarte') && (this.opp.Zahlungssystem__c == null || this.opp.Bank__c == null)) ||
                    (this.opp.Derzeitige_Zahlungsmethode__c == 'Tankkarte' && this.opp.Tankkarte_Emittent__c == null) ||
                    this.opp.Zahlungsart__c == null ||
                    (this.opp.Zahlungsart__c == 'Lastschrift' && (this.opp.Direct_Debit_Mandate_Type__c == null || this.opp.IBAN__c == null || this.opp.SWIFT_BIC__c == null)) ||
                    ((this.opp.Product__c == 'Home Station offer (v.1)' || this.opp.Product__c == 'Sales no fee promo Feb 2016') && this.opp.Home_Station__c == null)
                    )) {
                    throw new MessageException('This record does not meet the entry criteria. Please fill all required fields or contact your administrator for assistance.');
                } else if (approveProcessName == 'CreditCheck_Callcenter' && 
                    ((this.acc.BillingCountry != 'Germany' && this.acc.BillingCountry != 'Austria') ||
                    UserInfo.getProfileId() != '00e20000001AnIR' ||
                    this.opp.Anzahl_der_Karten__c == null ||
                    this.opp.Zahlungsziel__c == null ||
                    this.opp.Zahlungsart__c == null ||
                    (this.opp.Zahlungsart__c == 'Lastschrift' && (this.opp.Direct_Debit_Mandate_Type__c == null || this.opp.IBAN__c == null || this.opp.SWIFT_BIC__c == null)) ||
                    ((this.opp.Product__c == 'Home Station offer (v.1)' || this.opp.Product__c == 'Sales no fee promo Feb 2016') && this.opp.Home_Station__c == null)
                    )) {
                    throw new MessageException('This record does not meet the entry criteria. Please fill all required fields or contact your administrator for assistance.');
                } else if (approveProcessName == 'CreditCheck_HU' &&
                    ( this.acc.BillingCountry != 'Hungary' ||
                    this.opp.Anzahl_der_Karten__c == null ||
                    this.opp.Language_preference__c == null ||
                    this.opp.Derzeitige_Zahlungsmethode__c == null ||
                    this.acc.Beschaeftigte__c == null ||
                    ((this.opp.Derzeitige_Zahlungsmethode__c == 'Bankkarte' || this.opp.Derzeitige_Zahlungsmethode__c == 'Kreditkarte') && (this.opp.Zahlungssystem__c == null || this.opp.Bank__c == null)) ||
                    (this.opp.Derzeitige_Zahlungsmethode__c == 'Tankkarte' && this.opp.Tankkarte_Emittent__c == null) ||
                    this.opp.Zahlungsart__c == null ||
                    (this.opp.Zahlungsart__c == 'Lastschrift' && (this.opp.IBAN__c == null || this.opp.SWIFT_BIC__c == null)) ||
                    ((this.opp.Product__c == 'Home Station offer (v.1)' || this.opp.Product__c == 'Sales no fee promo Feb 2016') && this.opp.Home_Station__c == null)
                    )) {
                    throw new MessageException('This record does not meet the entry criteria. Please fill all required fields or contact your administrator for assistance.');
                } else if (approveProcessName == 'CreditCheck_PL' &&
                    (this.acc.BillingCountry != 'Poland' ||
                    this.opp.Anzahl_der_Karten__c == null ||
                    this.opp.Language_preference__c == null ||
                    this.opp.Derzeitige_Zahlungsmethode__c == null ||
                    this.acc.Beschaeftigte__c == null ||
                    ((this.opp.Derzeitige_Zahlungsmethode__c == 'Bankkarte' || this.opp.Derzeitige_Zahlungsmethode__c == 'Kreditkarte') && (this.opp.Zahlungssystem__c == null || this.opp.Bank__c == null)) ||
                    (this.opp.Derzeitige_Zahlungsmethode__c == 'Tankkarte' && this.opp.Tankkarte_Emittent__c == null) ||
                    this.opp.Zahlungsart__c == null ||
                    (this.opp.Zahlungsart__c == 'Lastschrift' && (this.opp.IBAN__c == null || this.opp.SWIFT_BIC__c == null)) ||
                    ((this.opp.Product__c == 'Home Station offer (v.1)' || this.opp.Product__c == 'Sales no fee promo Feb 2016') && this.opp.Home_Station__c == null)
                    )) {
                    throw new MessageException('This record does not meet the entry criteria. Please fill all required fields or contact your administrator for assistance.');
                } else if (approveProcessName == 'CreditCheck_CH' &&
                    (! this.acc.BillingCountry.contains('Switzerland') ||
                    this.opp.Anzahl_der_Karten__c == null ||
                    this.opp.Language_preference__c == null ||
                    this.opp.Derzeitige_Zahlungsmethode__c == null ||
                    this.acc.Beschaeftigte__c == null ||
                    ((this.opp.Derzeitige_Zahlungsmethode__c == 'Bankkarte' || this.opp.Derzeitige_Zahlungsmethode__c == 'Kreditkarte') && (this.opp.Zahlungssystem__c == null || this.opp.Bank__c == null)) ||
                    (this.opp.Derzeitige_Zahlungsmethode__c == 'Tankkarte' && this.opp.Tankkarte_Emittent__c == null) ||
                    this.opp.Zahlungsart__c == null ||
                    (this.opp.Zahlungsart__c == 'Lastschrift' && (this.opp.IBAN__c == null || this.opp.SWIFT_BIC__c == null)) ||
                    ((this.opp.Product__c == 'Home Station offer (v.1)' || this.opp.Product__c == 'Sales no fee promo Feb 2016') && this.opp.Home_Station__c == null)
                    )) {
                    throw new MessageException('This record does not meet the entry criteria. Please fill all required fields or contact your administrator for assistance.');
                } else if (approveProcessName == 'CreditCheck_LU' &&
                    (this.acc.BillingCountry != 'Luxembourg' ||
                    this.opp.Anzahl_der_Karten__c == null ||
                    this.opp.Language_preference__c == null ||
                    this.opp.Derzeitige_Zahlungsmethode__c == null ||
                    this.acc.Beschaeftigte__c == null ||
                    ((this.opp.Derzeitige_Zahlungsmethode__c == 'Bankkarte' || this.opp.Derzeitige_Zahlungsmethode__c == 'Kreditkarte') && (this.opp.Zahlungssystem__c == null || this.opp.Bank__c == null)) ||
                    (this.opp.Derzeitige_Zahlungsmethode__c == 'Tankkarte' && this.opp.Tankkarte_Emittent__c == null) ||
                    this.opp.Zahlungsart__c == null ||
                    (this.opp.Zahlungsart__c == 'Lastschrift' && (this.opp.Direct_Debit_Mandate_Type__c == null || this.opp.IBAN__c == null || this.opp.SWIFT_BIC__c == null)) ||
                    ((this.opp.Product__c == 'Home Station offer (v.1)' || this.opp.Product__c == 'Sales no fee promo Feb 2016') && this.opp.Home_Station__c == null)
                    )) {
                    throw new MessageException('This record does not meet the entry criteria. Please fill all required fields or contact your administrator for assistance.');
                } else if (approveProcessName == 'CreditCheck_SK' &&                   
                    (this.acc.BillingCountry != 'Slovakia' ||
                    this.opp.Anzahl_der_Karten__c == null ||
                    this.opp.Language_preference__c == null ||
                    this.opp.Derzeitige_Zahlungsmethode__c == null ||
                    this.acc.Beschaeftigte__c == null ||
                    ((this.opp.Derzeitige_Zahlungsmethode__c == 'Bankkarte' || this.opp.Derzeitige_Zahlungsmethode__c == 'Kreditkarte') && (this.opp.Zahlungssystem__c == null || this.opp.Bank__c == null)) ||
                    (this.opp.Derzeitige_Zahlungsmethode__c == 'Tankkarte' && this.opp.Tankkarte_Emittent__c == null) ||
                    this.opp.Zahlungsart__c == null ||
                    (this.opp.Zahlungsart__c == 'Lastschrift' && (this.opp.IBAN__c == null || this.opp.SWIFT_BIC__c == null)) ||
                    ((this.opp.Product__c == 'Home Station offer (v.1)' || this.opp.Product__c == 'Sales no fee promo Feb 2016') && this.opp.Home_Station__c == null)
                    )) {
                    throw new MessageException('This record does not meet the entry criteria. Please fill all required fields or contact your administrator for assistance.');
                } else if (approveProcessName == 'CreditCheck_CZ' &&   
                    (this.acc.BillingCountry != 'Czech Republic' ||
                    this.opp.Anzahl_der_Karten__c == null ||
                    this.opp.Language_preference__c == null ||
                    this.opp.Derzeitige_Zahlungsmethode__c == null ||
                    this.acc.Beschaeftigte__c == null ||
                    ((this.opp.Derzeitige_Zahlungsmethode__c == 'Bankkarte' || this.opp.Derzeitige_Zahlungsmethode__c == 'Kreditkarte') && (this.opp.Zahlungssystem__c == null || this.opp.Bank__c == null)) ||
                    (this.opp.Derzeitige_Zahlungsmethode__c == 'Tankkarte' && this.opp.Tankkarte_Emittent__c == null) ||
                    this.opp.Zahlungsart__c == null ||
                    (this.opp.Zahlungsart__c == 'Lastschrift' && (this.opp.IBAN__c == null || this.opp.SWIFT_BIC__c == null)) ||
                    ((this.opp.Product__c == 'Home Station offer (v.1)' || this.opp.Product__c == 'Sales no fee promo Feb 2016') && this.opp.Home_Station__c == null)
                    )) {
                    throw new MessageException('This record does not meet the entry criteria. Please fill all required fields or contact your administrator for assistance.');
                } else if (approveProcessName == 'CreditCheck_Fra' &&  
                    (this.acc.BillingCountry != 'France' ||
                    this.opp.Anzahl_der_Karten__c == null ||
                    this.opp.Language_preference__c == null ||
                    this.opp.Derzeitige_Zahlungsmethode__c == null ||
                    this.acc.Beschaeftigte__c == null ||
                    ((this.opp.Derzeitige_Zahlungsmethode__c == 'Bankkarte' || this.opp.Derzeitige_Zahlungsmethode__c == 'Kreditkarte') && (this.opp.Zahlungssystem__c == null || this.opp.Bank__c == null)) ||
                    (this.opp.Derzeitige_Zahlungsmethode__c == 'Tankkarte' && this.opp.Tankkarte_Emittent__c == null) ||
                    this.opp.Zahlungsart__c == null ||
                    (this.opp.Zahlungsart__c == 'Lastschrift' && (this.opp.Direct_Debit_Mandate_Type__c == null || this.opp.IBAN__c == null || this.opp.SWIFT_BIC__c == null)) ||
                    ((this.opp.Product__c == 'Home Station offer (v.1)' || this.opp.Product__c == 'Sales no fee promo Feb 2016') && this.opp.Home_Station__c == null)
                    )) {
                    throw new MessageException('This record does not meet the entry criteria. Please fill all required fields or contact your administrator for assistance.');
                }
            }
        } else if (this.opp.RecordType.Name == 'AllStar') {
            if (this.pi.get(0).Status == 'Pending') {
                if (this.opp.Anzahl_der_Karten__c == null || 
                    this.opp.RecordType.Name != 'AllStar' ||  
                    this.opp.Requested_monthly_Company_Credit_Spend__c == null ||
                    this.opp.AGB_Datenschutzhinweise_Richtigkeit__c == false || 
                    this.opp.Data_Protection_Act_1998__c == false ||
                    this.acc.BillingCountry != 'Poland' || 
                    this.acc.Beschaeftigte__c == null || 
                    this.acc.NIP__c == null || 
                    this.acc.Gesellschaftsform__c == null ||
                    this.acc.Trading_Name__c == null || 
                    this.acc.YearStarted == null) {
                    throw new MessageException('This record does not meet the entry criteria. Please fill all required fields or contact your administrator for assistance.'); 
                }
                if (this.opp.StageName == 'Pending Sales – PIT/CIT' || this.opp.StageName == 'Pending Sales – AML doc.') {
                    throw new MessageException('Please use "Submit for Approval AML" button.');       
                } else if (this.opp.StageName == 'Pending Sales - Token payment') {
                    throw new MessageException('Please use "Waiting for token payment" button.');
                } else if (this.opp.StageName != 'Pending Sales – Information' && this.opp.StageName != 'Pending Sales – Deposit') {
                    throw new MessageException('Invalid stage for current approval process.');
                }
            }
        }
    }


    /*******************************************************************************
    *  Name            : generateOppRequiredFieldsList(String currentUserProfile)
    *  Summary         : generate Opportunity Required Fields List    
    *  CreatedDate     : 21/06/2017
    *  Parameters      : currentUserProfile
    *  Returns         : fields list
    ******************************************************************************/
    public List<String> generateOppRequiredFieldsList(String currentUserProfile) {
        List<String> additionalRequiredFieldsList = new List<String>();
        if (this.opp.RecordType.Name == 'Euroshell' || this.opp.RecordType.Name == 'Euroshell Starts') {
            if ((this.acc.BillingCountry == 'Germany' || this.acc.BillingCountry == 'Austria') && currentUserProfile == 'Callcenter') { return oppFieldsEuroshellList_ATDEcallcenter; } 
            else if ((this.acc.BillingCountry == 'Germany' || this.acc.BillingCountry == 'Austria')) { return oppFieldsEuroshellList_ATDE; }
            else if (this.acc.BillingCountry.contains('Belgium')) { return oppFieldsEuroshellList_BE; } 
            else if (this.acc.BillingCountry == 'Netherlands') { return oppFieldsEuroshellList_NL; } 
            else if (this.acc.BillingCountry == 'Hungary') { return oppFieldsEuroshellList_HU; } 
            else if (this.acc.BillingCountry == 'Poland') { return oppFieldsEuroshellList_PL; } 
            else if (this.acc.BillingCountry.contains('Switzerland')) { return oppFieldsEuroshellList_CH; } 
            else if (this.acc.BillingCountry == 'Luxembourg') { return oppFieldsEuroshellList_LU; } 
            else if (this.acc.BillingCountry == 'Slovakia') { return oppFieldsEuroshellList_SK; } 
            else if (this.acc.BillingCountry == 'Czech Republic') { return oppFieldsEuroshellList_CZ; } 
            else if (this.acc.BillingCountry == 'France') { return oppFieldsEuroshellList_FR; }     
        } else if (this.opp.RecordType.Name == 'AllStar') {
            if (this.acc.BillingCountry == 'Poland') { return oppFieldsAllStarList_PL; } 
        }
        return null; 
    }


    /*******************************************************************************
    *  Name            : generateAccRequiredFieldsList()
    *  Summary         : generate Account Required Fields List    
    *  CreatedDate     : 21/06/2017
    *  Parameters      : -
    *  Returns         : fields list
    ******************************************************************************/
    public List<String> generateAccRequiredFieldsList(String currentUserProfile) {
        if (this.opp.RecordType.Name == 'Euroshell' || this.opp.RecordType.Name == 'Euroshell Starts') {
            if ((this.acc.BillingCountry == 'Germany' || this.acc.BillingCountry == 'Austria')) {
                return accFieldsEuroshellList_ATDE;
            } 
            else if (this.acc.BillingCountry.contains('Belgium')) { return accFieldsEuroshellList_BE; } 
            else if (this.acc.BillingCountry == 'Netherlands') { return accFieldsEuroshellList_NL; } 
            else if (this.acc.BillingCountry == 'Hungary') { return accFieldsEuroshellList_HU; } 
            else if (this.acc.BillingCountry == 'Poland') { return accFieldsEuroshellList_PL; } 
            else if (this.acc.BillingCountry.contains('Switzerland')) { return accFieldsEuroshellList_CH; } 
            else if (this.acc.BillingCountry == 'Luxembourg') { return accFieldsEuroshellList_LU; } 
            else if (this.acc.BillingCountry == 'Slovakia') { return accFieldsEuroshellList_SK; } 
            else if (this.acc.BillingCountry == 'Czech Republic') { return accFieldsEuroshellList_CZ; } 
            else if (this.acc.BillingCountry == 'France') { return accFieldsEuroshellList_FR; }    
        } else if (this.opp.RecordType.Name == 'AllStar') {
            if (this.acc.BillingCountry == 'Poland') { return accFieldsAllStarList_PL; } 
        }
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
        if (opp.StageName == 'CreditCheck' || 
            opp.StageName == 'Credit Check - Pending Credit' || 
            opp.StageName == 'Pending Credit AML' ||
            opp.StageName == 'Closed Won') {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You can\'t save. This opportunity is locked.'));
                PageReference page = new PageReference('/apex/CustomSubmitForApproval?id=' + opp.Id);
                return page;
        } else {
            if (! Test.isRunningTest()) {
                update acc;
                update opp; 
            }
            PageReference page = new PageReference('/' + opp.Id);
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
        PageReference page = new PageReference('/' + opp.Id);
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

    //1.1 Opportunity required fields for CreditCheck_Callcenter approval process (Germany, Austria)
    public static List<String> oppFieldsEuroshellList_ATDEcallcenter = new List<String> {
        'Anzahl_der_Karten__c',
        'Total_consumption_l_month__c',
        'Zahlungsart__c',
        'Zahlungsziel__c'      
    };

    //2.1 Opportunity required fields for CreditCheck approval process (Germany, Austria)
    public static List<String> oppFieldsEuroshellList_ATDE = new List<String> {
        'Anzahl_der_Karten__c',
        'Language_preference__c',
        'Total_consumption_l_month__c',
        'Derzeitige_Zahlungsmethode__c',
        'Zahlungssystem__c',    
        'Bank__c',
        'Tankkarte_Emittent__c'    
    };
    //2.2 Account required fields for CreditCheck approval process (Germany, Austria)
    public static List<String> accFieldsEuroshellList_ATDE = new List<String> {
        'Beschaeftigte__c'
    };


    //3.1 Opportunity required fields for CreditCheck_BE approval process (Belgium-NL, Belgium-FR)
    public static List<String> oppFieldsEuroshellList_BE = new List<String> {
        'Anzahl_der_Karten__c',
        'Language_preference__c',
        'Total_consumption_l_month__c',
        'Derzeitige_Zahlungsmethode__c',
        'Zahlungssystem__c',    
        'Bank__c',
        'Tankkarte_Emittent__c'
    };
    //3.2 Account required fields for CreditCheck_BE approval process (Belgium-NL, Belgium-FR)
    public static List<String> accFieldsEuroshellList_BE = new List<String> {
        'Beschaeftigte__c'
    };


    //4.1 Opportunity required fields for CreditCheck_NL approval process (Netherlands)
    public static List<String> oppFieldsEuroshellList_NL = new List<String> {
        'Anzahl_der_Karten__c',
        'Language_preference__c',
        'Total_consumption_l_month__c',
        'Derzeitige_Zahlungsmethode__c',
        'Zahlungssystem__c',    
        'Bank__c',
        'Tankkarte_Emittent__c'
    };
    //4.2 Account required fields for CreditCheck_NL approval process (Netherlands)
    public static List<String> accFieldsEuroshellList_NL = new List<String> {
        'Beschaeftigte__c'
    };


    //5.1 Opportunity required fields for CreditCheck_HU approval process (Hungary)
    public static List<String> oppFieldsEuroshellList_HU = new List<String> {
        'Anzahl_der_Karten__c',
        'Language_preference__c',
        'Total_consumption_l_month__c',
        'Derzeitige_Zahlungsmethode__c',
        'Zahlungssystem__c',    
        'Bank__c',
        'Tankkarte_Emittent__c'
    };
    //5.2 Account required fields for CreditCheck_HU approval process (Hungary)
    public static List<String> accFieldsEuroshellList_HU = new List<String> {
        'Beschaeftigte__c'
    };


    //6.1 Opportunity required fields for CreditCheck_PL approval process (Poland)
    public static List<String> oppFieldsEuroshellList_PL = new List<String> {
        'Anzahl_der_Karten__c',
        'Language_preference__c',
        'Total_consumption_l_month__c',
        'Derzeitige_Zahlungsmethode__c',
        'Zahlungssystem__c',    
        'Bank__c',
        'Tankkarte_Emittent__c'
    };
    //6.2 Account required fields for CreditCheck_PL approval process (Poland)
    public static List<String> accFieldsEuroshellList_PL = new List<String> {
        'Beschaeftigte__c'
    };


    //7.1 Opportunity required fields for CreditCheck_CH approval process (Switzerland-NL, Switzerland-FR, Switzerland-IT)
    public static List<String> oppFieldsEuroshellList_CH = new List<String> {
        'Anzahl_der_Karten__c',
        'Language_preference__c',
        'Total_consumption_l_month__c',
        'Derzeitige_Zahlungsmethode__c',
        'Zahlungssystem__c',    
        'Bank__c',
        'Tankkarte_Emittent__c'
    };
    //7.2 Account required fields for CreditCheck_CH approval process (Switzerland-NL, Switzerland-FR, Switzerland-IT)
    public static List<String> accFieldsEuroshellList_CH = new List<String> {
        'Beschaeftigte__c'
    };


    //8.1 Opportunity required fields for CreditCheck_LU approval process (Luxembourg)
    public static List<String> oppFieldsEuroshellList_LU = new List<String> {
        'Anzahl_der_Karten__c',
        'Language_preference__c',
        'Total_consumption_l_month__c',
        'Derzeitige_Zahlungsmethode__c',
        'Zahlungssystem__c',    
        'Bank__c',
        'Tankkarte_Emittent__c'
    };
    //8.2 Account required fields for CreditCheck_LU approval process (Luxembourg)
    public static List<String> accFieldsEuroshellList_LU = new List<String> {
        'Beschaeftigte__c'
    };


    //9.1 Opportunity required fields for CreditCheck_SK approval process (Slovakia)
    public static List<String> oppFieldsEuroshellList_SK = new List<String> {
        'Anzahl_der_Karten__c',
        'Language_preference__c',
        'Total_consumption_l_month__c',
        'Derzeitige_Zahlungsmethode__c',
        'Zahlungssystem__c',    
        'Bank__c',
        'Tankkarte_Emittent__c'
    };
    //9.2 Account required fields for CreditCheck_SK approval process (Slovakia)
    public static List<String> accFieldsEuroshellList_SK = new List<String> {
        'Beschaeftigte__c'
    };


    //10.1 Opportunity required fields for CreditCheck_CZ approval process (Czech Republic)
    public static List<String> oppFieldsEuroshellList_CZ = new List<String> {
        'Anzahl_der_Karten__c',
        'Language_preference__c',
        'Total_consumption_l_month__c',
        'Derzeitige_Zahlungsmethode__c',
        'Zahlungssystem__c',    
        'Bank__c',
        'Tankkarte_Emittent__c'
    };
    //10.2 Account required fields for CreditCheck_CZ approval process (Czech Republic)
    public static List<String> accFieldsEuroshellList_CZ = new List<String> {
        'Beschaeftigte__c'
    };


    //11.1 Opportunity required fields for CreditCheck_Fra approval process (France)
    public static List<String> oppFieldsEuroshellList_FR = new List<String> {
        'Anzahl_der_Karten__c',
        'Language_preference__c',
        'Total_consumption_l_month__c',
        'Derzeitige_Zahlungsmethode__c',
        'Zahlungssystem__c',    
        'Bank__c',
        'Tankkarte_Emittent__c'
    };
    //11.2 Account required fields for CreditCheck_Fra approval process (France)
    public static List<String> accFieldsEuroshellList_FR = new List<String> {
        'Beschaeftigte__c'
    };


    //12.1 Opportunity required fields for CreditCheck_PL_AllStar approval process (Poland)
    public static List<String> oppFieldsAllStarList_PL = new List<String> {
        'Anzahl_der_Karten__c',
        'Requested_monthly_Company_Credit_Spend__c',
        'Data_Protection_Act_1998__c',
        'AGB_Datenschutzhinweise_Richtigkeit__c'
    };
    //12.2 Account required fields for CreditCheck_PL_AllStar approval process (Poland)
    public static List<String> accFieldsAllStarList_PL = new List<String> {
        'Beschaeftigte__c',
        'NIP__c',
        'Gesellschaftsform__c',
        'Trading_Name__c',
        'YearStarted'
    };  
}