public class OpportunityTriggerHandler {
    public static Boolean enablesTrigger = true;
    public static Boolean isSendToZoho = false;
    public static Boolean isSendWelcomeEmail = false;
    public static Boolean isSendToBackOffice = false;
    public static Boolean isOpportunityClosed = true;
    public static Boolean isE2EForm = false;

    @TestVisible static Messaging.SingleEmailMessage flmtMail;

    public static void setRecordType(List<Opportunity> newList) {
        List<RecordType> recordTypesList = [
                SELECT Name
                FROM RecordType
                WHERE (Name = 'AllStar' OR Name = 'Russian Sales') AND
                sObjectType = 'Opportunity'
                LIMIT 1000
        ];
        Map<String, RecordType> recordTypesMap = new Map<String, RecordType>();
        for (RecordType rt : recordTypesList) {
            recordTypesMap.put(rt.Name, rt);
        }

        if (!recordTypesMap.isEmpty()) {
            for (Opportunity opp : newList) {
                if (opp.Lead_Record_Type__c == 'AllStar' && recordTypesMap.containsKey('AllStar')) {
                    opp.RecordTypeId = recordTypesMap.get('AllStar').Id;
                } else if (opp.Lead_Record_Type__c == 'Russian Sales' && recordTypesMap.containsKey('Russian Sales')) {
                    opp.RecordTypeId = recordTypesMap.get('Russian Sales').Id;
                }
            }
        }
    }


    public static void setOpporunityStageName(List<Opportunity> newList) {
        Set<Id> recordTypesIdsSet = getRussianSalesRecordType();

        if (!recordTypesIdsSet.isEmpty()) {
            for (Opportunity opp : newList) {
                if (opp.Lead_Record_Type__c == 'Russian Sales' && recordTypesIdsSet.contains(opp.RecordTypeId)) {
                    opp.StageName = 'Qualified Lead';
                }
            }
        }
    }


    public static void updateLastOwnerDate(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
        for (Opportunity opp : newMap.values()) {
            if (opp.OwnerId != oldMap.get(opp.Id).OwnerId) {
                opp.Last_Owner_Change_Date__c = Datetime.now();
            }
        }
    }

    public static void updateFirstLastOwnerDate(List<Opportunity> newOpps) {
        for (Opportunity o : newOpps) {
            o.Last_Owner_Change_Date__c = Datetime.now();
        }
    }

    public static void maketouppercase(List<Opportunity> newList) {
        for (Opportunity opp : newList) {
            opp.Name = opp.Name.touppercase();
        }
    }


    public static void sendWelcomeEmail(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
        Set<String> recordTypeIdsSet = new Set<String>{
                GlobalUtils.returnRecordTypeId('Opportunity', 'Euroshell'),
                GlobalUtils.returnRecordTypeId('Opportunity', 'Euroshell Starts')
        };

        Map<String, List<String>> accountToOpportunityMap = new Map<String, List<String>>();
        List<Task> welcomeTasksList = new List<Task>();
        Set<Id> oppsForContactRolesSet = new Set<Id>();
        for (Opportunity opp : newMap.values()) {
            E2E_Form_General_Settings__c e2eGeneralSettings = E2E_Form_General_Settings__c.getInstance(opp.Registered_Country__c);
            if ( (oldMap.get(opp.Id).StageName != opp.StageName && opp.StageName == 'Closed Won' && templatesForCountriesMap.containsKey(opp.Registered_Country__c) &&
                    recordTypeIdsSet.contains(opp.RecordTypeId) && ! opp.E2E__c)
                    ||
                    (opp.E2E__c && e2eGeneralSettings != null && opp.OwnerId != e2eGeneralSettings.E2E_Guest_User_Id__c &&
                            oldMap.get(opp.Id).StageName != opp.StageName && opp.StageName == 'Closed Won' &&
                            templatesForCountriesMap.containsKey(opp.Registered_Country__c) &&
                            recordTypeIdsSet.contains(opp.RecordTypeId)) ) {

                if ( ! accountToOpportunityMap.containsKey(opp.AccountId)) {
                    accountToOpportunityMap.put(opp.AccountId, new List<String>());
                }
                accountToOpportunityMap.get(opp.AccountId).add(opp.Id);
                Task newTask = createWelcomeEmailTask(opp);
                welcomeTasksList.add(newTask);
                oppsForContactRolesSet.add(opp.Id);
            }
        }

        if (!isSendWelcomeEmail && !oppsForContactRolesSet.isEmpty()) {
            Email_Notifications__c emailCustomSetting = Email_Notifications__c.getInstance('Opportunity Welcome Letters');
            if (emailCustomSetting != null && emailCustomSetting.Enabled__c) {
                List<OrgWideEmailAddress> owaList = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = 'no-reply@fleetcor.eu' LIMIT 1];
                if (owaList.isEmpty()) {
                    return;
                }
                String orgEmailAddressId = owaList.get(0).Id;

                List<EmailTemplate> allTemplates = [
                        SELECT Id, Name, Body, HtmlValue, Subject
                        FROM EmailTemplate
                        WHERE Name IN :templatesForCountriesMap.values()
                        LIMIT 1000
                ];

                Map<String, EmailTemplate> templatesMap = new Map<String, EmailTemplate>();
                Set<Id> templatesIdSet = new Set<Id>();
                for (EmailTemplate template : allTemplates) {
                    templatesMap.put(template.Name, template);
                    templatesIdSet.add(template.Id);
                }

                List<OpportunityContactRole> rolesList = [
                        SELECT Contact.Id, Contact.Email, Contact.AccountId, Contact.Account.BillingCountry, Role, OpportunityId
                        FROM OpportunityContactRole
                        WHERE OpportunityId IN :oppsForContactRolesSet AND
                        isPrimary = true
                        LIMIT 10000
                ];

                List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
                Map<String, Messaging.SingleEmailMessage> oppIdToMailMap = new Map<String, Messaging.SingleEmailMessage>();
                for (OpportunityContactRole role : rolesList) {
                    if (role.Contact.Email != null) {
                        if (accountToOpportunityMap.containsKey(role.Contact.AccountId)) {
                            for (String oppId : accountToOpportunityMap.get(role.Contact.AccountId)) {
                                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                mail.setTemplateID(templatesMap.get(templatesForCountriesMap.get(role.Contact.Account.BillingCountry)).Id);
                                mail.setTargetObjectId(role.Contact.Id);
                                mail.setWhatId(oppId);
                                mail.setSaveAsActivity(false);
                                mail.setCharset('UTF-8');
                                allmsg.add(mail);
                                oppIdToMailMap.put(oppId, mail);
                            }
                        }
                    }
                }

                Savepoint sp = Database.setSavepoint();
                if (!Test.isRunningTest() && !allmsg.isEmpty()) {
                    isSendWelcomeEmail = true;
                    Messaging.sendEmail(allmsg);
                    Database.rollback(sp);
                }

                List<Attachment> emailsToPdfList = new List<Attachment>();
                for (Messaging.SingleEmailMessage message : oppIdToMailMap.values()) {
                    if (!oppIdToMailMap.isEmpty() && !Test.isRunningTest()) {
                        Attachment newPdf = new Attachment();
                        newPdf.ParentId = message.getWhatId();
                        newPdf.Body = Blob.valueOf('<head><meta charset="utf-8"></head>' + message.getHtmlBody());
                        newPdf.Name = 'Welcome Email.html';
                        emailsToPdfList.add(newPdf);
                    }
                }
                insert emailsToPdfList;

                List<Messaging.SingleEmailMessage> allmsgCC = new List<Messaging.SingleEmailMessage>();
                Map<String, List<Messaging.Emailfileattachment>> fileTemplateToAttachmentsMap = new Map<String, List<Messaging.Emailfileattachment>>();
                for (Attachment a : [SELECT Name, Body, BodyLength, Parent.Name FROM Attachment WHERE ParentId IN :templatesIdSet]) {
                    if (!fileTemplateToAttachmentsMap.containsKey(a.Parent.Name)) {
                        fileTemplateToAttachmentsMap.put(a.Parent.Name, new List<Messaging.Emailfileattachment>());
                    }
                    Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                    efa.setFileName(a.Name);
                    efa.setBody(a.Body);
                    fileTemplateToAttachmentsMap.get(a.Parent.Name).add(efa);
                }
                List<Attachment> sepaAttachmentsList = [
                        SELECT ParentId, Name, Body
                        FROM Attachment
                        WHERE Name LIKE 'SEPAMandate%' AND ParentId IN :newMap.keySet()
                        LIMIT 1000];
                Map<Id, Attachment> sepaMap = new Map<Id, Attachment>();
                for (Attachment att : sepaAttachmentsList) {
                    sepaMap.put(att.ParentId, att);    
                }
                for (String oppId : oppIdToMailMap.keySet()) {
                    String templateName = templatesForCountriesMap.get(newMap.get(oppId).Registered_Country__c);
                    List<Messaging.Emailfileattachment> attachmentsList = fileTemplateToAttachmentsMap.get(templateName);
                    if (attachmentsList == null) {
                        attachmentsList = new List<Messaging.Emailfileattachment>();
                    }
                    if (sepaMap.containsKey(oppId)) {
                        Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                        efa.setFileName(sepaMap.get(oppId).Name);
                        efa.setBody(sepaMap.get(oppId).Body);
                        attachmentsList.add(efa);
                    }
                    Messaging.SingleEmailMessage mailCC = new Messaging.SingleEmailMessage();
                    mailCC.setFileAttachments(attachmentsList);
                    mailCC.setTargetObjectId(newMap.get(oppId).OwnerId);
                    mailCC.setOrgWideEmailAddressId(orgEmailAddressId);
                    mailCC.setSubject(oppIdToMailMap.get(oppId).getSubject());
                    mailCC.setHtmlBody(oppIdToMailMap.get(oppId).getHtmlBody());
                    mailCC.setPlainTextBody(oppIdToMailMap.get(oppId).getPlainTextBody());
                    mailCC.setSaveAsActivity(false);
                    mailCC.setCharset('UTF-8');
                    allmsgCC.add(mailCC);
                }
                for (OpportunityContactRole role : rolesList) {
                    if (role.Contact.Email != null) {
                        if (accountToOpportunityMap.containsKey(role.Contact.AccountId)) {
                            for (String oppId : accountToOpportunityMap.get(role.Contact.AccountId)) {
                                String templateName = templatesForCountriesMap.get(role.Contact.Account.BillingCountry);
                                List<Messaging.Emailfileattachment> attachmentsList = fileTemplateToAttachmentsMap.get(templateName);
                                if (attachmentsList == null) {
                                    attachmentsList = new List<Messaging.Emailfileattachment>();
                                }
                                if (sepaMap.containsKey(oppId)) {
                                    Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                                    efa.setFileName(sepaMap.get(oppId).Name);
                                    efa.setBody(sepaMap.get(oppId).Body);
                                    attachmentsList.add(efa);
                                }                                
                                Messaging.SingleEmailMessage mailCC = new Messaging.SingleEmailMessage();
                                mailCC.setFileAttachments(attachmentsList);
                                mailCC.setTargetObjectId(role.Contact.Id);
                                mailCC.setOrgWideEmailAddressId(orgEmailAddressId);
                                mailCC.setSubject(oppIdToMailMap.get(oppId).getSubject());
                                mailCC.setHtmlBody(oppIdToMailMap.get(oppId).getHtmlBody());
                                mailCC.setPlainTextBody(oppIdToMailMap.get(oppId).getPlainTextBody());
                                mailCC.setSaveAsActivity(false);
                                mailCC.setCharset('UTF-8');
                                allmsgCC.add(mailCC);
                            }
                        }
                    }
                }
                if (!Test.isRunningTest()) {
                    Messaging.sendEmail(allmsgCC);
                }
                insert welcomeTasksList;
            }
        }
    }


    /*******************************************************************************
    *  Name            : sendEmailToBackOffice(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap)
    *  Summary         : sending email to backoffice for Starts Processes
    *  CreatedDate     : 18/07/2017
    *  Parameters      : Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap
    *  Returns         : void
    ******************************************************************************/
    public static void sendEmailToBackOffice(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
        if (isSendToBackOffice) return;
        Map<String, String> accountIdsMap = new Map<String, String>();
        Map<String, Opportunity> opptiesWithChangedStartsStatusMap = new Map<String, Opportunity>();
        for (Opportunity oppty : newMap.values()) {
            if ((oppty.StageName != oldMap.get(oppty.Id).StageName &&
                    oppty.StageName == 'Closed Won' &&
                    oppty.RecordTypeId == '012200000006sWc'
            ) ||
                    ((oppty.Starts_Status__c != oldMap.get(oppty.Id).Starts_Status__c ||
                            oppty.Starts_Reason_for_Not_Fueling__c != oldMap.get(oppty.Id).Starts_Reason_for_Not_Fueling__c) &&
                            (oppty.Starts_Status__c == '2.3 First Check: Delay' ||
                                    oppty.Starts_Status__c == '3.3 Volume Check 1: Delay' ||
                                    oppty.Starts_Status__c == '4.3 Volume Check 2: Delay' ||
                                    oppty.Starts_Status__c == '5.3 Final Check: Delay') &&
                            (oppty.Starts_Reason_for_Not_Fueling__c == 'Did not receive PINs' ||
                                    oppty.Starts_Reason_for_Not_Fueling__c == 'Did not receive Cards')
                    ) ||
                    (oppty.Starts_Status__c != oldMap.get(oppty.Id).Starts_Status__c &&
                            oppty.Starts_Status__c == '5.5 Winback Failed' ||
                            oppty.Starts_Status__c == '0.6 Missing information provided'
                    )) {
                opptiesWithChangedStartsStatusMap.put(oppty.Id, oppty);
                accountIdsMap.put(oppty.Id, oppty.AccountId);
            }
        }

        if (!opptiesWithChangedStartsStatusMap.isEmpty()) {
            List<EmailTemplate> templatesList = [
                    SELECT Id, Name, Body, HtmlValue, Subject, DeveloperName
                    FROM EmailTemplate
                    WHERE DeveloperName IN :templatesForBackOfficeStartsStatusesMap.values()
                    LIMIT 10
            ];

            Map<String, EmailTemplate> templatesMap = new Map<String, EmailTemplate>();
            for (EmailTemplate template : templatesList) {
                templatesMap.put(template.DeveloperName, template);
            }

            Map<Id, Account> accountsMap = new Map<Id, Account>([
                    SELECT BillingCountry
                    FROM Account
                    WHERE Id IN :accountIdsMap.values()
            ]);

            List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
            Map<String, Messaging.SingleEmailMessage> oppIdToMailMap = new Map<String, Messaging.SingleEmailMessage>();
            for (Opportunity opp : opptiesWithChangedStartsStatusMap.values()) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                if (opp.StageName != oldMap.get(opp.Id).StageName && opp.StageName == 'Closed Won') {
                    mail.setTemplateID(templatesMap.get(templatesForBackOfficeStartsStatusesMap.get('new closed won')).Id);
                } else if ((opp.Starts_Status__c == '2.3 First Check: Delay' ||
                        opp.Starts_Status__c == '3.3 Volume Check 1: Delay' ||
                        opp.Starts_Status__c == '4.3 Volume Check 2: Delay' ||
                        opp.Starts_Status__c == '5.3 Final Check: Delay') && opp.Starts_Reason_for_Not_Fueling__c == 'Did not receive Cards') {
                    mail.setTemplateID(templatesMap.get(templatesForBackOfficeStartsStatusesMap.get('New Cards Requested to BO')).Id);
                } else if ((opp.Starts_Status__c == '2.3 First Check: Delay' ||
                        opp.Starts_Status__c == '3.3 Volume Check 1: Delay' ||
                        opp.Starts_Status__c == '4.3 Volume Check 2: Delay' ||
                        opp.Starts_Status__c == '5.3 Final Check: Delay') && opp.Starts_Reason_for_Not_Fueling__c == 'Did not receive PINs') {
                    mail.setTemplateID(templatesMap.get(templatesForBackOfficeStartsStatusesMap.get('New PINs Requested to BO')).Id);
                } else {
                    mail.setTemplateID(templatesMap.get(templatesForBackOfficeStartsStatusesMap.get(opp.Starts_Status__c)).Id);
                }
                mail.setTargetObjectId(opp.OwnerId);
                mail.setWhatId(opp.Id);
                mail.setSaveAsActivity(false);
                mail.setCharset('UTF-8');
                allmsg.add(mail);
                oppIdToMailMap.put(opp.Id, mail);
            }

            Savepoint sp = Database.setSavepoint();
            if (!allmsg.isEmpty()) {
                Messaging.sendEmail(allmsg);
                Database.rollback(sp);
            }

            String emailText;
            String emailSubject;
            Map<String, BackOffice_Notifications__c> backOfficeNotifyCustomSettingMap = BackOffice_Notifications__c.getAll();
            List<String> emailAddressesList = new List<String>();
            List<Messaging.SingleEmailMessage> allmessages = new List<Messaging.SingleEmailMessage>();
            List<Opportunity> opportunityForTasksList = new List<Opportunity>();
            if (!oppIdToMailMap.isEmpty()) {
                for (String oppId : oppIdToMailMap.keySet()) {
                    if (opptiesWithChangedStartsStatusMap.get(oppId).AccountId != null &&
                            accountsMap.get(opptiesWithChangedStartsStatusMap.get(oppId).AccountId).BillingCountry != null &&
                            backOfficeNotifyCustomSettingMap.get(accountsMap.get(opptiesWithChangedStartsStatusMap.get(oppId).AccountId).BillingCountry) != null &&
                            backOfficeNotifyCustomSettingMap.get(accountsMap.get(opptiesWithChangedStartsStatusMap.get(oppId).AccountId).BillingCountry).Active__c == true) {
                        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                        emailText = oppIdToMailMap.get(oppId).getHtmlBody();
                        emailSubject = oppIdToMailMap.get(oppId).getSubject();
                        emailAddressesList.add(backOfficeNotifyCustomSettingMap.get(accountsMap.get(opptiesWithChangedStartsStatusMap.get(oppId).AccountId).BillingCountry).Email__c);
                        message.setSubject(emailSubject);
                        message.setHtmlBody(emailText);
                        message.setToAddresses(emailAddressesList);
                        message.setSaveAsActivity(false);
                        message.setCharset('UTF8');
                        allmessages.add(message);
                        opportunityForTasksList.add(opptiesWithChangedStartsStatusMap.get(oppId));

                    }
                }
            }

            List<Messaging.SendEmailResult> resultsList = new List<Messaging.SendEmailResult>();
            if (!allmessages.isEmpty()) {
                resultsList = Messaging.sendEmail(allmessages);
                isSendToBackOffice = true;
            }

            logBackOfficeEmails(resultsList, opportunityForTasksList);
        }
    }


    /*******************************************************************************
    *  Name            : changeE2ECardsOwner(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap)
    *  Summary         : Update Cards Owner after E2E Opportunity Owner is changed      
    *  CreatedDate     : 23/01/2019
    *  ModifiedDate    : 
    *  Parameters      : Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap - from the trigger
    *  Returns         : void
    ******************************************************************************/
    public static void changeE2ECardsOwner(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
        Set<Id> oppIdsToProcessSet = new Set<Id>();
        for (Opportunity opp : newMap.values()) {
            if (opp.OwnerId != oldMap.get(opp.Id).OwnerId && opp.E2E__c) {
                oppIdsToProcessSet.add(opp.Id);
            }
        }

        if (oppIdsToProcessSet.isEmpty()) return;

        List<Tankkarten__c> cardsList = [SELECT Opportunity__c FROM Tankkarten__c WHERE Opportunity__c IN :oppIdsToProcessSet];
        Map<Id, List<Tankkarten__c>> oppToCardsMap = new Map<Id, List<Tankkarten__c>>();
        for (Tankkarten__c card : cardsList) {
            card.OwnerId = newMap.get(card.Opportunity__c).OwnerId;
        }

        update cardsList;
    }


    /*******************************************************************************
    *  Name            : logBackOfficeEmails(List<Messaging.SendEmailResult> resultsList, List<Opportunity> opportunityForTasksList)
    *  Summary         : create tasks on Opportunity in case of sending emails
    *  CreatedDate     : 01/03/2018
    *  ModifiedDate    : 01/03/2018
    *  Parameters      : List<Messaging.SendEmailResult> resultsList - results of sending emails, List<Opportunity> opportunityForTasksList - opportunities
    *  Returns         : void
    ******************************************************************************/
    public static void logBackOfficeEmails(List<Messaging.SendEmailResult> resultsList, List<Opportunity> opportunityForTasksList) {
        Boolean errors = false;
        List<Task> tasksList = new List<Task>();
        String emailBody = '<br/>';
        for (Integer i = 0; i < resultsList.size(); i++) {
            if (opportunityForTasksList.get(i).StageName == 'Closed Won') {
                Task task = new Task(
                        WhatId = opportunityForTasksList.get(i).Id,
                        ActivityDate = Date.today(),
                        Type = 'E-mail',
                        Status = 'Completed');
                if (resultsList.get(i).isSuccess() == true) {
                    task.Subject = 'SENT: Email about new Customer was sent to Back Office';
                } else {
                    errors = true;
                    emailBody += '<br/>Opportunity Id: ' + opportunityForTasksList.get(i).Id + '.<br/> Errors:';
                    String taskBody = 'Errors: ';
                    for (Messaging.SendEmailError error : resultsList.get(i).getErrors()) {
                        emailBody += '<br/>- ' + error.Message;
                        taskBody += '\n- ' + error.Message;
                    }

                    emailBody += '<br/>';
                    task.Subject = 'NOT SENT: Email about new Customer was not sent to Back Office';
                    task.Description = taskBody;
                }

                tasksList.add(task);
            }
        }

        insert tasksList;

        if (errors) {
            ExceptionLogger.sendException(emailBody, '');
        }
    }


    /*******************************************************************************
    *  Name            : sendEmailToStartsOpptyOwner(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap)
    *  Summary         : sending email to opportunity owner for Starts Processes
    *  CreatedDate     : 01/08/2017
    *  Parameters      : Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap
    *  Returns         : void
    ******************************************************************************/
    public static void sendEmailToStartsOpptyOwner(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
        Set<String> accountIdsSet = new Set<String>();
        List<Opportunity> finalOpportinitiesList = new List<Opportunity>();
        for (Opportunity opp : newMap.values()) {
            if (opp.Starts_Status__c != oldMap.get(opp.Id).Starts_Status__c) {
                if (opp.Starts_Status__c == '0.5 Missing information' || opp.Starts_Status__c == '0.4 Registration in GFN: Winback' || opp.Starts_Status__c == '3.4 Volume Check 1: Winback' ||
                        opp.Starts_Status__c == '4.4 Volume Check 2: Winback' || opp.Starts_Status__c == '5.4 Final Check: Winback') {
                    finalOpportinitiesList.add(opp);
                    accountIdsSet.add(opp.AccountId);
                }
            }
        }

        if (!finalOpportinitiesList.isEmpty()) {
            Map<Id, Account> accountsMap = new Map<Id, Account>([
                    SELECT BillingCountry
                    FROM Account
                    WHERE Id IN :accountIdsSet
                    LIMIT 1
            ]);

            List<EmailTemplate> templatesList = [
                    SELECT Id, Name, Body, HtmlValue, Subject, DeveloperName
                    FROM EmailTemplate
                    WHERE DeveloperName IN :templatesForOwnerStartsStatusesMap.values()
                    LIMIT 10
            ];

            Map<String, EmailTemplate> templatesMap = new Map<String, EmailTemplate>();
            for (EmailTemplate template : templatesList) {
                templatesMap.put(template.DeveloperName, template);
            }

            Map<String, BackOffice_Notifications__c> backOfficeNotifyCustomSettingMap = BackOffice_Notifications__c.getAll();
            List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
            for (Opportunity oppty : finalOpportinitiesList) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTemplateID(templatesMap.get(templatesForOwnerStartsStatusesMap.get(oppty.Starts_Status__c)).Id);
                if (oppty.AccountId != null &&
                        accountsMap.get(oppty.AccountId).BillingCountry != null &&
                        backOfficeNotifyCustomSettingMap.get(accountsMap.get(oppty.AccountId).BillingCountry).Email__c != null) {
                    mail.setReplyTo(backOfficeNotifyCustomSettingMap.get(accountsMap.get(oppty.AccountId).BillingCountry).Email__c);
                }
                mail.setTargetObjectId(oppty.OwnerId);
                mail.setWhatId(oppty.Id);
                mail.setSaveAsActivity(false);
                mail.setCharset('UTF-8');
                allmsg.add(mail);
            }
            if (!Test.isRunningTest() && !allmsg.isEmpty()) {
                Messaging.sendEmail(allmsg);
            }
        }
    }


    /*******************************************************************************
    *  Name            : updateVouchersSentField ()
    *  Summary         : after Opportunity StageName changes to "Closed Won" of update Vouchers Sent Field (increased by 1) in partner Account
    *  CreatedDate     : 17/01/2017
    *  Parameters      : Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap  - old and new opportunity values
    *  Returns         : void
    ******************************************************************************/
    public static void updateVouchersSentField(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
        Set<Id> oppClosedWonIdSet = new Set<Id>();
        for (Opportunity opp : newMap.values()) {
            if (oldMap.get(opp.Id).StageName != opp.StageName &&
                    opp.StageName == 'Closed Won') {
                oppClosedWonIdSet.add(opp.Id);
            }
        }

        if (!oppClosedWonIdSet.isEmpty()) {
            List<Lead> convertedLeadsList = [
                    SELECT Id, ConvertedOpportunityId, Partner__c
                    FROM Lead
                    WHERE ConvertedOpportunityId IN :oppClosedWonIdSet AND
                    Partner__r.RecordType.Name = 'Retailer'
                    LIMIT 50000
            ];

            Set<Id> partnerAccIdSet = new Set<Id>();
            for (Lead l : convertedLeadsList) {
                if (l.Partner__c != null) {
                    partnerAccIdSet.add(l.Partner__c);
                }
            }

            if (!partnerAccIdSet.isEmpty()) {
                Map<Id, Account> allPartnerAccMap = new Map<Id, Account>([
                        SELECT Id, Vouchers_Sent__c
                        FROM Account
                        WHERE Id IN :partnerAccIdSet
                        LIMIT 50000
                ]);

                List<Account> accListToUpdateList = new List<Account>();
                for (Lead le : convertedLeadsList) {
                    if (allPartnerAccMap.get(le.Partner__c).Vouchers_Sent__c == null) {
                        allPartnerAccMap.get(le.Partner__c).Vouchers_Sent__c = 1;
                        accListToUpdateList.add(allPartnerAccMap.get(le.Partner__c));
                    } else {
                        allPartnerAccMap.get(le.Partner__c).Vouchers_Sent__c += 1;
                        accListToUpdateList.add(allPartnerAccMap.get(le.Partner__c));
                    }
                }
                update accListToUpdateList;
            }
        }
    }


    /*******************************************************************************
    *  Name            : createWelcomeEmailTask(Opportunity newOpp)
    *  Summary         : creating Welcome Email Task
    *  CreatedDate     : 27/02/2017
    *  Parameters      : Opportunity newOpp
    *  Returns         : task (newTask)
    ******************************************************************************/
    public static Task createWelcomeEmailTask(Opportunity newOpp) {
        Task newTask = new Task(
                ActivityDate = Date.today(),
                Subject = 'Email: Welcome Email Sent',
                WhatId = newOpp.Id,
                Type = 'E-mail',
                Status = 'Completed');

        return newTask;
    }


    /*******************************************************************************
    *  Name            : validatingApprovalProcess(List<Opportunity> newListOpp)
    *  Summary         : Validation when sent to the approval process
    *  CreatedDate     : 15/05/2017
    *  Parameters      : List<Opportunity> newListOpp - new Opportunity values
    *  Returns         : void
    ******************************************************************************/
    public static void validatingApprovalProcess(List<Opportunity> newListOpp) {
        for (Opportunity opp : newListOpp) {
            if (opp.StageName == 'CreditCheck') {
                if ((opp.Product__c == 'Home Station offer (v.1)' || opp.Product__c == 'Sales no fee promo Feb 2016') &&
                        String.isBlank(opp.Home_Station__c) && opp.Datansatztyp_auto__c.containsIgnoreCase('Euroshell')) {
                    opp.adderror(System.Label.Homestation_approve_error);
                }
                if ((opp.Product__c == 'Home Station offer (v.1)' || opp.Product__c == 'Sales no fee promo Feb 2016') &&
                        String.isBlank(opp.ESI__c) && opp.Datansatztyp_auto__c.containsIgnoreCase('Euroshell')) {
                    opp.adderror(System.Label.ESI_approve_error);
                }
            }
        }
    }


    /*******************************************************************************
    *  Name            : sendToFleetmatics(Map<Id, Opportunity> oldOpportunitiesMap, Map<Id, Opportunity> newOpportunitiesMap)
    *  Summary         : send email to addresses from custom setting when fleetmatics lead is closed and won
    *  CreatedDate     : 12/06/2017
    *  Parameters      : Map<Id, Opportunity> oldOpportunitiesMap - old opportunity values, Map<Id, Opportunity> newOpportunitiesMap - new Opportunities values
    *  Returns         : void
    ******************************************************************************/
    public static void sendToFleetmatics(Map<Id, Opportunity> oldOpportunitiesMap, Map<Id, Opportunity> newOpportunitiesMap) {
        for (Opportunity opportunity : newOpportunitiesMap.values()) {
            if (opportunity.StageName != oldOpportunitiesMap.get(opportunity.Id).StageName && opportunity.StageName == 'Closed Won' &&
                    (opportunity.LeadSource == 'Fleetmatics' || opportunity.LeadSource == 'Fleetmatics_new')) {
                Map<String, Fleetmatics_Notifications__c> recipientsEmailsMap = Fleetmatics_Notifications__c.getAll();
                List<String> toAddresses = new List<String>();
                for (String recipientName : recipientsEmailsMap.keySet()) {
                    if (recipientsEmailsMap.get(recipientName).Active__c == true) {
                        toAddresses.add(recipientsEmailsMap.get(recipientName).Email__c);
                    }
                }

                List<Messaging.Email> mailsList = new List<Messaging.Email>();
                flmtMail = new Messaging.SingleEmailMessage();
                flmtMail.setToAddresses(toAddresses);
                flmtMail.setSenderDisplayName('SFDC');
                flmtMail.setSubject('Fleetmatics Form');
                flmtMail.setBccSender(false);
                flmtMail.setUseSignature(false);
                flmtMail.setSaveAsActivity(false);
                flmtMail.setHtmlBody('Opportunity Stage Name is changed to Closed Won ' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + opportunity.Id);
                mailsList.add(flmtMail);
                Messaging.sendEmail(mailsList);
            }
        }
    }


    /*******************************************************************************
    *  Name            : changeToClosedWonAfterPendingSepa(Map<Id, Opportunity> oldOpportunitiesMap, Map<Id, Opportuinty> newOpportunitiesMap)
    *  Summary         : change opportunity stage name from Pending Sales - SEPA Confirmation(exposed by Credit Factory) to Closed Won
    *  CreatedDate     : 29/09/2017
    *  ModifiedDate    : 29/06/2017
    *  Parameters      : Map<Id, Opportunity> oldOpportunitiesMap - old Opportunities values, Map<Id, Opportuinty> newOpportunitiesMap - new Opportunities values
    *  Returns         : void
    ******************************************************************************/
    public static void changeToClosedWonAfterPendingSepa(Map<Id, Opportunity> oldOpportunitiesMap, Map<Id, Opportunity> newOpportunitiesMap) {
        Set<Id> opportunitiesToCheckSEPAIdsSet = new Set<Id>();
        for (Opportunity opportunity : newOpportunitiesMap.values()) {
            if (opportunity.StageName == 'Pending Sales - SEPA Confirmation' && opportunity.SEPA_Request_Approved__c != true && opportunity.Zahlungsart__c == 'Lastschrift' &&
                    oldOpportunitiesMap.get(opportunity.Id).Einwilligung_Lastschriftverfahren__c == false && opportunity.Einwilligung_Lastschriftverfahren__c == true) {
                opportunitiesToCheckSEPAIdsSet.add(opportunity.Id);
            }
        }

        Map<Id, List<Attachment>> opportunityToAttachmentsMap = new Map<Id, List<Attachment>>();
        if (!opportunitiesToCheckSEPAIdsSet.isEmpty()) {
            List<Attachment> attachmentsList = [
                    SELECT ParentId
                    FROM Attachment
                    WHERE ParentId IN :opportunitiesToCheckSEPAIdsSet AND Name LIKE '%sepa%'
            ];
            for (Attachment attachment : attachmentsList) {
                if (!opportunityToAttachmentsMap.containsKey(attachment.ParentId)) {
                    opportunityToAttachmentsMap.put(attachment.ParentId, new List<Attachment>());
                }

                opportunityToAttachmentsMap.get(attachment.ParentId).add(attachment);
            }
        }

        for (Opportunity opportunity : newOpportunitiesMap.values()) {
            if ((opportunity.Send_SEPA_approval_link__c == true && oldOpportunitiesMap.get(opportunity.Id).SEPA_Request_Approved__c == false &&
                    opportunity.SEPA_Request_Approved__c == true || oldOpportunitiesMap.get(opportunity.Id).Einwilligung_Lastschriftverfahren__c == false &&
                    opportunity.Einwilligung_Lastschriftverfahren__c == true && (opportunity.SEPA_Request_Approved__c != true && opportunityToAttachmentsMap.get(opportunity.Id) != null ||
                    opportunity.SEPA_Request_Approved__c == true)) && opportunity.StageName == 'Pending Sales - SEPA Confirmation' && opportunity.Zahlungsart__c == 'Lastschrift') {
                opportunity.StageName = 'Closed Won';
                opportunity.CF_Stage__c = 'Auto CW';
                opportunity.Closed_Won_by_CF__c = true;
            } else if (opportunity.Zahlungsart__c == 'Lastschrift' && opportunity.SEPA_Request_Approved__c != true &&
                    oldOpportunitiesMap.get(opportunity.Id).Einwilligung_Lastschriftverfahren__c == false && opportunity.Einwilligung_Lastschriftverfahren__c == true &&
                    opportunity.StageName == 'Pending Sales - SEPA Confirmation' &&
                    opportunityToAttachmentsMap.get(opportunity.Id) == null) {
                opportunity.addError('Please attach SEPA form to the Opportunity.');
            }
        }
    }


    /*******************************************************************************
    *  Name            : updatePaymentMethodSEPAApproved(Map<Id, Opportunity> oldOpportunitiesMap, Map<Id, Opportunity> newOpportunitiesMap)
    *  Summary         : update payment method when SEPA request approved
    *  CreatedDate     : 19/08/2017
    *  Parameters      : Map<Id, Opportunity> oldOpportunitiesMap - old Opportunities values, Map<Id, Opportuinty> newOpportunitiesMap - new Opportunities values
    *  Returns         : void
    ******************************************************************************/
    public static void updatePaymentMethodSEPAApproved(Map<Id, Opportunity> oldOpportunitiesMap, Map<Id, Opportunity> newOpportunitiesMap) {
        for (Opportunity opportunity : newOpportunitiesMap.values()) {
            if (opportunity.StageName != 'Closed Won' && opportunity.Send_SEPA_approval_link__c == true && oldOpportunitiesMap.get(opportunity.Id).SEPA_Request_Approved__c == false &&
                    opportunity.SEPA_Request_Approved__c == true) {
                opportunity.Zahlungsart__c = 'Lastschrift';
            }
        }
    }


    /*******************************************************************************
    *  Name            : updateStartsPaymentMethodSEPAApproved(Map<Id, Opportunity> oldOpportunitiesMap, Map<Id, Opportunity> newOpportunitiesMap)
    *  Summary         : update Starts: Payment method when SEPA request approved
    *  CreatedDate     : 14/08/2017
    *  Parameters      : Map<Id, Opportunity> oldOpportunitiesMap - old Opportunities values, Map<Id, Opportuinty> newOpportunitiesMap - new Opportunities values
    *  Returns         : void
    ******************************************************************************/
    public static void updateStartsPaymentMethodSEPAApproved(Map<Id, Opportunity> oldOpportunitiesMap, Map<Id, Opportunity> newOpportunitiesMap) {
        for (Opportunity opportunity : newOpportunitiesMap.values()) {
            if (opportunity.StageName == 'Closed Won' && opportunity.Send_SEPA_approval_link__c == true && oldOpportunitiesMap.get(opportunity.Id).SEPA_Request_Approved__c == false &&
                    opportunity.SEPA_Request_Approved__c == true) {
                opportunity.Starts_Payment_method__c = 'Direct debit';
            }
        }
    }


    /*******************************************************************************
    *  Name            : updateStartsPaymentMethodSEPAApproved(Map<Id, Opportunity> oldOpportunitiesMap, List<Opportunity> newOpportunitiesList)
    *  Summary         : set CF Stage to Auto CW when Stage is set to Closed Won
    *  CreatedDate     : 30/01/2018
    *  ModifiedDate    : 30/01/2018
    *  Parameters      : Map<Id, Opportunity> oldOpportunitiesMap - old Opportunities values Map, List<Opportunity> newOpportunitiesList - new Opportunities values List
    *  Returns         : void
    ******************************************************************************/
    public static void updateCFStageClosedWon(Map<Id, Opportunity> oldOpportunitiesMap, List<Opportunity> newOpportunitiesList) {
        for (Opportunity opportunity : newOpportunitiesList) {
            if (opportunity.StageName == 'Closed Won' && oldOpportunitiesMap.get(opportunity.Id).StageName == 'Pending Credit - Contract Check') {
                opportunity.CF_Stage__c = 'Auto CW';
                opportunity.Closed_Won_by_CF__c = true;
            }
        }
    }


    /*******************************************************************************
    *  Name            : updateStartsFieldsAfterClosedWon(Map<Id, Opportunity> oldOpportunitiesMap, Map<Id, Opportunity> newOpportunitiesMap)
    *  Summary         : change starts fields when opportunity is closed (Before update)
    *  CreatedDate     : 2/09/2017
    *  ModifiedDate    : 2/09/2017
    *  Parameters      : Map<Id, Opportunity> oldOpportunitiesMap - old Opportunities values map, Map<Id, Opportunity> newOpportunitiesMap - new Opportunities values map
    *  Returns         : void
    ******************************************************************************/
    public static void updateStartsFieldsAfterClosedWon(Map<Id, Opportunity> oldOpportunitiesMap, Map<Id, Opportunity> newOpportunitiesMap) {
        Set<Id> recordTypesIdsSet = new Set<Id>();
        if (GlobalUtils.returnRecordTypeId('Opportunity', 'Euroshell') != null) recordTypesIdsSet.add(GlobalUtils.returnRecordTypeId('Opportunity', 'Euroshell'));
        if (!recordTypesIdsSet.isEmpty()) {
            Map<Id, Opportunity> opportunitiesToUpdateMap = new Map<Id, Opportunity>();
            for (Opportunity opportunity : newOpportunitiesMap.values()) {
                if (oldOpportunitiesMap.get(opportunity.Id).StageName != opportunity.StageName && opportunity.StageName == 'Closed Won' &&
                        ! opportunity.E2E__c && recordTypesIdsSet.contains(opportunity.RecordTypeId)) {
                    opportunitiesToUpdateMap.put(opportunity.Id, opportunity);
                }
            }

            if (!opportunitiesToUpdateMap.isEmpty()) {
                List<OpportunityFieldHistory> fieldHistories = [
                        SELECT Field, OpportunityId, NewValue, CreatedDate
                        FROM OpportunityFieldHistory
                        WHERE Field = 'Starts_Status__c' AND
                        OpportunityId IN :opportunitiesToUpdateMap.keySet()
                        ORDER BY CreatedDate DESC
                        LIMIT 30000
                ];
                Map<Id, List<OpportunityFieldHistory>> opportunitiesToFieldHistoriesMap = new Map<Id, List<OpportunityFieldHistory>>();
                for (OpportunityFieldHistory history : fieldHistories) {
                    if (!opportunitiesToFieldHistoriesMap.containsKey(history.OpportunityId)) {
                        opportunitiesToFieldHistoriesMap.put(history.OpportunityId, new List<OpportunityFieldHistory>());
                    }

                    opportunitiesToFieldHistoriesMap.get(history.OpportunityId).add(history);
                }

                List<BusinessHours> fleetcorBH = [
                        SELECT Name
                        FROM BusinessHours
                        WHERE Name = 'CZ' OR Name = 'SK' OR Name = 'HU' OR Name = 'PL' OR Name = 'Default'
                        LIMIT 10
                ];
                Map<String, BusinessHours> businessHoursMap = new Map<String, BusinessHours>();
                for (BusinessHours businessHours : fleetcorBH) {
                    businessHoursMap.put(businessHours.Name, businessHours);
                }

                for (Opportunity opportunity : opportunitiesToUpdateMap.values()) {
                    Datetime dateOfstatusChange;
                    if (opportunitiesToFieldHistoriesMap.containsKey(opportunity.Id) && !opportunitiesToFieldHistoriesMap.get(opportunity.Id).isEmpty()) {
                        dateOfstatusChange = opportunitiesToFieldHistoriesMap.get(opportunity.Id).get(0).CreatedDate;
                    } else {
                        dateOfstatusChange = opportunity.CloseDate;
                    }

                    String businessHoursId;
                    if (opportunity.Land_Opp__c == 'Czech Republic') {
                        businessHoursId = businessHoursMap.get('CZ').Id;
                    } else if (opportunity.Land_Opp__c == 'Slovakia') {
                        businessHoursId = businessHoursMap.get('SK').Id;
                    } else if (opportunity.Land_Opp__c == 'Hungary') {
                        businessHoursId = businessHoursMap.get('HU').Id;
                    } else if (opportunity.Land_Opp__c == 'Poland') {
                        businessHoursId = businessHoursMap.get('PL').Id;
                    } else {
                        businessHoursId = businessHoursMap.get('Default').Id;
                    }

                    Datetime dueDateTime = BusinessHours.addGmt(businessHoursId, dateOfstatusChange, 32400001);
                    Date dueDate = Date.newinstance(dueDateTime.year(), dueDateTime.month(), dueDateTime.day());
                    opportunity.Starts_Schedule__c = dueDate;
                    opportunity.Starts_Status_Delay__c = false;
                    opportunity.Starts_Number_of_Cards_Target__c = opportunity.Anzahl_der_Karten__c;
                    opportunity.Starts_Status__c = '0. Request received';
                }
            }
        }
    }


    /*******************************************************************************
    *  Name            : startsSLAcalculate()
    *  Summary         : update starts schedule value when starts status is changed (before update)
    *  CreatedDate     : 16/10/2017
    *  Parameters      : Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap
    *  Returns         : -
    ******************************************************************************/
    public static void startsSLAcalculate(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
        Map<String, Opportunity> opportunitiesToUpdateMap = new Map<String, Opportunity>();
        for (Opportunity opportunity : newMap.values()) {
            if (oldMap.get(opportunity.Id).Starts_Status__c != opportunity.Starts_Status__c && startsSLAvaluesMap.containsKey(opportunity.Starts_Status__c) && opportunity.StageName == 'Closed Won') {
                opportunitiesToUpdateMap.put(opportunity.Id, opportunity);
            }
        }

        if (!opportunitiesToUpdateMap.isEmpty()) {
            List<BusinessHours> bhList = [
                    SELECT Id, Name
                    FROM BusinessHours
                    WHERE IsActive = true
                    LIMIT 5
            ];

            Map<String, BusinessHours> fleetcorBHmap = new Map<String, BusinessHours>();
            for (BusinessHours bh : bhList) {
                if (bh.Name == 'CZ') {
                    fleetcorBHmap.put('Czech republic', bh);
                } else if (bh.Name == 'SK') {
                    fleetcorBHmap.put('Slovakia', bh);
                } else if (bh.Name == 'HU') {
                    fleetcorBHmap.put('Hungary', bh);
                } else if (bh.Name == 'PL') {
                    fleetcorBHmap.put('Poland', bh);
                } else if (bh.Name == 'Default') {
                    fleetcorBHmap.put('Default', bh);
                }
            }

            List<Task> tasksToInsertList = new List<Task>();
            for (Opportunity oppty : opportunitiesToUpdateMap.values()) {
                //calculating SLA
                Datetime dueDate;
                if (fleetcorBHmap.containsKey(oppty.Land_Opp__c)) {
                    dueDate = BusinessHours.addGmt(fleetcorBHmap.get(oppty.Land_Opp__c).Id, Datetime.now(), startsSLAvaluesMap.get(oppty.Starts_Status__c) * 32400000 + 1);
                } else if (fleetcorBHmap.containsKey('Default')) {
                    dueDate = BusinessHours.addGmt(fleetcorBHmap.get('Default').Id, Datetime.now(), startsSLAvaluesMap.get(oppty.Starts_Status__c) * 32400000 + 1);
                } else {
                    dueDate = Datetime.now();
                }

                Date dueDateFinal = Date.newinstance(dueDate.year(), dueDate.month(), dueDate.day());
                oppty.Starts_Schedule__c = dueDateFinal;
                oppty.Starts_Overdue_days__c = 0;
                oppty.Starts_Status_Delay__c = false;
            }
        }
    }


    /*******************************************************************************
    *  Name            : doCreateTaskMissingInformationToStartsProcess (Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap)
    *  Summary         : creating task if Starts Status = 0.5 Missing information
    *  CreatedDate     : 19/01/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public static void doCreateTaskMissingInformationToStartsProcess(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
        List<Opportunity> opportunitiesList = new List<Opportunity>();
        for (Opportunity opportunity : newMap.values()) {
            if (oldMap.get(opportunity.Id).Starts_Status__c != opportunity.Starts_Status__c && startsSLAvaluesMap.containsKey(opportunity.Starts_Status__c) && opportunity.StageName == 'Closed Won') {
                opportunitiesList.add(opportunity);
            }
        }
        List<Task> tasksToInsertList = new List<Task>();
        for (Opportunity oppty : opportunitiesList) {
            //creating task if Starts Status = 0.5 Missing information
            if (oppty.Starts_Status__c == '0.5 Missing information') {
                Task newTask = new Task(
                        ActivityDate = Date.today(),
                        IsReminderSet = true,
                        OwnerId = oppty.OwnerId,
                        Priority = 'High',
                        Status = 'Not Started',
                        Subject = 'Back Office Missing Information',
                        Type = 'Other',
                        WhatId = oppty.Id);

                tasksToInsertList.add(newTask);
            }
            if (!tasksToInsertList.isEmpty()) {
                insert tasksToInsertList;
            }
        }
    }


    /*******************************************************************************
    *  Name            : insertLastOwnerChangeDateRUS()
    *  Summary         : insert opportunity, set Last_Date_Change_Owner_RUS__c
    *  CreatedDate     : 20.11.2017
    *  Parameters      : List<Opportunity> newOpps
    *  Returns         : -
    ******************************************************************************/
    public static void insertLastOwnerChangeDateRUS(List<Opportunity> newOpps) {
        Set<id> idRecordTypesRussianSales = getRussianSalesRecordType();
        Boolean isExecute = false;
        for (Opportunity opportunity : newOpps) {
            if (idRecordTypesRussianSales.contains(opportunity.RecordTypeId)) {
                opportunity.Last_Owner_Change_Date_RUS__c = Datetime.now();
            }
        }
    }

    /*******************************************************************************
    *  Name            : updateLastOwnerChangeDateRUS()
    *  Summary         : update opportunity, set Last_Date_Change_Owner_RUS__c
    *  CreatedDate     : 20.11.2017
    *  Parameters      : Map<Id, Opportunity> oldOppMap, Map<Id, Opportunity> newOppMap
    *  Returns         : -
    ******************************************************************************/
    public static void updateLastOwnerChangeDateRUS(Map<Id, Opportunity> oldOppMap, Map<Id, Opportunity> newOppMap) {
        Set<id> idRecordTypesRussianSales = getRussianSalesRecordType();
        Boolean isExecute = false;
        for (Opportunity opportunity : newOppMap.values()) {
            if (idRecordTypesRussianSales.contains(opportunity.RecordTypeId) &&
                    opportunity.OwnerId != oldOppMap.get(opportunity.Id).OwnerId) {
                opportunity.Last_Owner_Change_Date_RUS__c = Datetime.now();
            }
        }
    }

    /*******************************************************************************
     *  Name            : sendRequestForChangeOwnerRu()
     *  Summary         : send request for change owner of Opportunity(Account) to owner.Manager
     *  CreatedDate     : 20.11.2017
     *  Parameters      : Map<Id, Opportunity> oldOpportunitiesMap, Map<Id, Opportunity> newOpportunitiesMap
     *  Returns         : void
     ******************************************************************************/
    public static void sendRequestForChangeOwnerRu(Map<Id, Opportunity> oldOpportunitiesMap, Map<Id, Opportunity> newOpportunitiesMap) {
        Set<id> idRecordTypesRussianSales = getRussianSalesRecordType();
        Boolean isExecute = false;
        for (Opportunity opportunity : newOpportunitiesMap.values()) {
            if (idRecordTypesRussianSales.contains(opportunity.RecordTypeId)) {
                isExecute = true;
                break;
            }
        }
        if (isExecute) {
            List<Profile> profileRussianSalesManagerList = [SELECT id FROM profile WHERE name IN ('Russian Sales Manager', 'Russian Inbound', 'Russian Telesales', 'Russian Field Sales', 'Russian KAM')];
            Set<Id> profileRussianSalesManagerSet = new Set<Id>();
            for (Profile profile : profileRussianSalesManagerList) {
                profileRussianSalesManagerSet.add(profile.Id);
            }
            if (profileRussianSalesManagerSet.contains(UserInfo.getProfileId())) {
                Map<Id, User> ownersOfOppportunitiesMap = new Map<Id, User>();
                Set<id> ownersOfOpportunitiesSet = new Set<Id>();
                for (Opportunity newOpportunity : newOpportunitiesMap.values()) {
                    ownersOfOpportunitiesSet.add(newOpportunity.ownerid);
                    ownersOfOpportunitiesSet.add(oldOpportunitiesMap.get(newOpportunity.Id).ownerid);
                }
                List<User> ownersOfOpportunitiesList = [SELECT id, name, ManagerId FROM User WHERE id = :ownersOfOpportunitiesSet];
                for (User userOwner : ownersOfOpportunitiesList) {
                    ownersOfOppportunitiesMap.put(userOwner.id, userOwner);
                }
                List<Messaging.Email> emails = new List<Messaging.Email>();
                for (Opportunity newOpportunity : newOpportunitiesMap.values()) {
                    Opportunity oldOpportunity = oldOpportunitiesMap.get(newOpportunity.Id);
                    if ((oldOpportunity.OwnerId == UserInfo.getUserId()) &&
                            (oldOpportunity.OwnerId <> newOpportunity.OwnerId) &&
                            (idRecordTypesRussianSales.contains(newOpportunity.RecordTypeId))) {
                        if ((ownersOfOppportunitiesMap.get(oldOpportunity.ownerid) != null) &&
                                (ownersOfOppportunitiesMap.get(newOpportunity.ownerid) != null)) {
                            emails.add(EmailGenerator.prepareHtmlEmailToTarget(ownersOfOppportunitiesMap.get(oldOpportunity.ownerid).ManagerId,
                                    'Запрос на изменение владельца возможности/организации',
                                    '<p>Поступил запрос на изменение владельца записи <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + newOpportunity.Id + '" > ' + newOpportunity.Id + ' </a> </p>' +
                                            '<p>Текущий  владелец     : ' + ownersOfOppportunitiesMap.get(oldOpportunity.ownerid).Name + '</p>' +
                                            '<p>Изменить владельца на : ' + ownersOfOppportunitiesMap.get(newOpportunity.ownerid).Name + '</p>' +
                                            '<p>Для того чтобы изменить владельца записи, нажмите на кнопку "Подтвердить"</p>' +
                                            '<table border="0"> <tr> ' +
                                            '<th> <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/apex/ApprovePprRequestFromEmail?Type=002&Answer=yes&idRecord=' + newOpportunity.Id + '&idNewOwner=' + ownersOfOppportunitiesMap.get(newOpportunity.ownerid).id + '"> Подтвердить </a> </th> ' +
                                            '<th> <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/apex/ApprovePprRequestFromEmail?Type=002&Answer=no&idRecord=' + newOpportunity.Id + '&idNewOwner=' + ownersOfOppportunitiesMap.get(newOpportunity.ownerid).id + '"> Отклонить </a> </th> ' +
                                            '</tr> </table> '));
                            emails.add(EmailGenerator.prepareHtmlEmailToTarget(ownersOfOppportunitiesMap.get(oldOpportunity.ownerid).id,
                                    'Запрос принят',
                                    '<p>Ваш запрос на передачу записи <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + oldOpportunity.id + '" > ' + oldOpportunity.id + ' </a> - отправлен вашему Тим Лидеру(Менеджеру)</p>' +
                                            '<p>Пожалуйста ожидайте ответа</p>'));
                            newOpportunity.Ownerid = oldOpportunity.OwnerId;
                        }
                    }
                }
                if (emails.size() != 0) {
                    Messaging.sendEmail(emails);
                }
            }
        }
    }

    /*******************************************************************************
    *  Name            : sendRequestForCreateSecondOpportunity()
    *  Summary         : send request for create second opportunity to owner.Manager
    *  CreatedDate     : 20.11.2017
    *  Parameters      : List<Opportunity>
    *  Returns         : void
    ******************************************************************************/
    public static void sendRequestForCreateSecondOpportunity(List<Opportunity> newOpportunitiesList) {
        Set<id> idRecordTypesRussianSales = getRussianSalesRecordType();
        Boolean isExecute = false;
        for (Opportunity opportunity : newOpportunitiesList) {
            if (idRecordTypesRussianSales.contains(opportunity.RecordTypeId)) {
                isExecute = true;
                break;
            }
        }
        if (isExecute) {
            List<User> currentUser = [
                    SELECT id, name, ManagerId, ProfileId
                    FROM User
                    WHERE id = :UserInfo.getUserId() AND Profile.Name = 'Russian Sales Manager'
            ];
            if (currentUser.size() == 1) {
                Set<id> AccountIds = new Set<Id>();
                for (Opportunity opportunity : newOpportunitiesList) {
                    AccountIds.add(opportunity.AccountId);
                }
                Map<String, Integer> countOpportunityInAccountMap = new Map<String, Integer>();
                for (AggregateResult aggregateResult : [
                        SELECT AccountId,count(id) num
                        FROM Opportunity
                        WHERE AccountId = :AccountIds
                        GROUP BY AccountId
                ]) {
                    countOpportunityInAccountMap.put(String.valueOf(aggregateResult.get('AccountId')), Integer.valueOf(aggregateResult.get('num')));
                }
                List<Messaging.Email> emails = new List<Messaging.Email>();
                for (Opportunity opportunity : newOpportunitiesList) {
                    if (idRecordTypesRussianSales.contains(opportunity.RecordTypeId)) {
                        if (opportunity.id == null) {
                            if (countOpportunityInAccountMap.get(String.valueOf(opportunity.AccountId)) > 0) {
                                opportunity.ownerid = currentUser.get(0).ManagerId;
                            }
                        } else {
                            if (countOpportunityInAccountMap.get(String.valueOf(opportunity.AccountId)) > 1) {
                                emails.add(EmailGenerator.prepareHtmlEmailToTarget(currentUser.get(0).id,
                                        'Запрос принят',
                                        '<p>Запрос на создание новой(очередной) возможности "' + opportunity.name + '", отправлен вашему Тим Лидеру(Менеджеру)</p>' +
                                                '<p>Пожалуйста ожидайте ответа</p>'));
                                emails.add(EmailGenerator.prepareHtmlEmailToTarget(currentUser.get(0).ManagerId,
                                        'Запрос на создание второй возможности',
                                        '<p>Поступил запрос от ' + currentUser.get(0).Name + ' на создание новой(очередной) возможности <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + opportunity.Id + '" > ' + opportunity.id + ' </a> </p>' +
                                                '<p>Для того чтобы подтвердить создание возможности, нажмите на кнопку "Подтвердить"</p>' +
                                                '<table border="0"> <tr> ' +
                                                '<th> <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/apex/ApprovePprRequestFromEmail?Type=003&Answer=yes&idRecord=' + opportunity.Id + '&idNewOwner=' + currentUser.get(0).id + '"> Подтвердить </a> </th> ' +
                                                '<th> <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/apex/ApprovePprRequestFromEmail?Type=003&Answer=no&idRecord=' + opportunity.Id + '&idNewOwner=' + currentUser.get(0).id + '"> Отклонить </a> </th> ' +
                                                '</tr> </table> '));
                            }
                        }
                    }
                }
                if (emails.size() != 0) {
                    Messaging.sendEmail(emails);
                }
            }
        }
    }


    /*******************************************************************************
    *  Name            : getRussianSalesRecordType()
    *  Summary         : return set of RecordType for Russia
    *  CreatedDate     : 20.11.2017
    *  Parameters      : -
    *  Returns         : result
    ******************************************************************************/
    public static Set<Id> getRussianSalesRecordType() {
        Set<id> result = new Set<id>();
        if (Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Российские продажи') != null) {
            result.add(Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Российские продажи').getRecordTypeId());
        } else if (Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Russian Sales') != null) {
            result.add(Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Russian Sales').getRecordTypeId());
        }
        return result;
    }


    /*******************************************************************************
    *  Name            : sendTotalConsumptionChangeAlert(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap)
    *  Summary         : send notification to Teamleaders if Sales Agent updates Total_consumption_l_month__c field 3 and more times in the same Opportunity
    *  CreatedDate     : 20/12/2017
    *  ModifiedDate    : -
    *  Parameters      : Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap
    *  Returns         : void
    ******************************************************************************/
    public static void sendTotalConsumptionChangeAlert(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
        Map<String, String> updatedOpptiesMap = new Map<String, String>();
        List<OpportunityFieldHistory> ofh = new List<OpportunityFieldHistory>();
        for (Opportunity opportunity : newMap.values()) {
            if (oldMap.get(opportunity.Id).Total_consumption_l_month__c != opportunity.Total_consumption_l_month__c) {
                updatedOpptiesMap.put(opportunity.Id, opportunity.OwnerId);
                if (Test.isRunningTest()) {
                    ofh.add(new OpportunityFieldHistory(OpportunityId = opportunity.Id, Field = 'Total_consumption_l_month__c'));
                    ofh.add(new OpportunityFieldHistory(OpportunityId = opportunity.Id, Field = 'Total_consumption_l_month__c'));
                    ofh.add(new OpportunityFieldHistory(OpportunityId = opportunity.Id, Field = 'Total_consumption_l_month__c'));
                }
            }
        }

        if (!updatedOpptiesMap.isEmpty()) {
            if (!Test.isRunningTest()) {
                ofh = [
                        SELECT OpportunityId, Field, OldValue, NewValue, CreatedById
                        FROM OpportunityFieldHistory
                        WHERE (Field = 'Total_consumption_l_month__c' OR Field = 'Owner') AND
                        OpportunityId IN :updatedOpptiesMap.keySet()
                        ORDER BY CreatedDate DESC
                        LIMIT 50000
                ];
            }

            Map<String, List<OpportunityFieldHistory>> numberOpptyFieldHistoryMap = new Map<String, List<OpportunityFieldHistory>>();
            for (OpportunityFieldHistory fieldHistory : ofh) {
                if (fieldHistory.Field == 'Owner') break;
                if (!numberOpptyFieldHistoryMap.containsKey(fieldHistory.OpportunityId)) {
                    numberOpptyFieldHistoryMap.put(fieldHistory.OpportunityId, new List<OpportunityFieldHistory>());
                }
                numberOpptyFieldHistoryMap.get(fieldHistory.OpportunityId).add(fieldHistory);
            }

            Map<String, String> opptiesToSendingEmailMapTemp = new Map<String, String>();
            for (String opptyId : numberOpptyFieldHistoryMap.keySet()) {
                Integer numberHistoryLines = numberOpptyFieldHistoryMap.get(opptyId).size();
                Integer lastHistoryLineIndex = 0;
                if (numberHistoryLines != 0) {
                    lastHistoryLineIndex = numberHistoryLines - 1;
                }
                // >= 2 since when last OpportunityFieldHistory is not visible (it working asynchronous: after update trigger and insert field history)
                if (numberOpptyFieldHistoryMap.get(opptyId).get(lastHistoryLineIndex).OldValue == null) {
                    if (numberOpptyFieldHistoryMap.get(opptyId).size() >= 3) {
                        opptiesToSendingEmailMapTemp.put(opptyId, updatedOpptiesMap.get(opptyId));
                    }
                } else {
                    if (numberOpptyFieldHistoryMap.get(opptyId).size() >= 2) {
                        opptiesToSendingEmailMapTemp.put(opptyId, updatedOpptiesMap.get(opptyId));
                    }
                }
            }

            if (!opptiesToSendingEmailMapTemp.isEmpty()) {
                Map<String, User> opptyOwnersMap = new Map<String, User>([
                        SELECT Name, UserRole.ParentRoleId
                        FROM User
                        WHERE Id = :opptiesToSendingEmailMapTemp.values() AND
                        isActive = TRUE AND
                        (UserRole.Name = 'Salesteam Inbound' OR UserRole.Name = 'Salesteam Outbound 1')
                        LIMIT 10000
                ]);

                if (!opptyOwnersMap.isEmpty()) {
                    // [1]. ----- Data preparation -----
                    Map<String, String> parentRoleIdForSaleMap = new Map<String, String>();
                    for (User usr : opptyOwnersMap.values()) {
                        parentRoleIdForSaleMap.put(usr.Id, usr.UserRole.ParentRoleId);
                    }
                    // [1.1]. Generating additional teamleaders set
                    Set<String> additionalUsersSet = new Set<String>{
                            'Aleksandar Ilic'
                    };

                    Map<String, User> teamleadersMap = new Map<String, User>([
                            SELECT Id, Name, UserRoleId, Email
                            FROM User
                            WHERE (UserRoleId IN :parentRoleIdForSaleMap.values() OR Name IN :additionalUsersSet) AND isActive = TRUE
                            LIMIT 10000
                    ]);

                    Map<String, List<String>> teamleadersWithRoleIdMap = new Map<String, List<String>>();
                    for (User teamLead : teamleadersMap.values()) {
                        if (additionalUsersSet.contains(teamLead.Name)) {
                            if (!teamleadersWithRoleIdMap.containsKey('additionalUsers')) {
                                teamleadersWithRoleIdMap.put('additionalUsers', new List<String>());
                            }
                            teamleadersWithRoleIdMap.get('additionalUsers').add(teamLead.Email);
                        } else {
                            if (!teamleadersWithRoleIdMap.containsKey(teamLead.UserRoleId)) {
                                teamleadersWithRoleIdMap.put(teamLead.UserRoleId, new List<String>());
                            }
                            teamleadersWithRoleIdMap.get(teamLead.UserRoleId).add(teamLead.Email);
                        }
                    }

                    // [1.2]. Generating list of Teamleaders with additional users for Sales Rep
                    Map<String, List<String>> userWithHisTeamleadersMap = new Map<String, List<String>>();
                    for (String saleId : parentRoleIdForSaleMap.keySet()) {
                        if (teamleadersWithRoleIdMap.containsKey(parentRoleIdForSaleMap.get(saleId))) {
                            userWithHisTeamleadersMap.put(saleId, new List<String>());
                            userWithHisTeamleadersMap.get(saleId).addAll(teamleadersWithRoleIdMap.get(parentRoleIdForSaleMap.get(saleId)));
                            if (teamleadersWithRoleIdMap.containsKey('additionalUsers')) {
                                userWithHisTeamleadersMap.get(saleId).addAll(teamleadersWithRoleIdMap.get('additionalUsers'));
                            }
                        }
                    }

                    // [1.3]. Generating list of updated Opportunities for Sales Rep
                    Map<String, List<String>> finalOpptiesToSendingEmailMap = new Map<String, List<String>>();
                    for (String opptyId : opptiesToSendingEmailMapTemp.keySet()) {
                        if (userWithHisTeamleadersMap.containsKey(opptiesToSendingEmailMapTemp.get(opptyId))) {
                            finalOpptiesToSendingEmailMap.put(opptiesToSendingEmailMapTemp.get(opptyId), new List<String>());
                        }
                        finalOpptiesToSendingEmailMap.get(opptiesToSendingEmailMapTemp.get(opptyId)).add(opptyId);
                    }

                    // [2]. ----- Sending email notification to teamleaders -----
                    List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
                    for (String saleId : finalOpptiesToSendingEmailMap.keySet()) {
                        for (String oppId : finalOpptiesToSendingEmailMap.get(saleId)) {
                            String fullRecordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + oppId;
                            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                            message.setToAddresses(userWithHisTeamleadersMap.get(saleId));
                            message.setSubject('Fuel consumption change alert');
                            message.setHtmlBody('<p>' + opptyOwnersMap.get(saleId).Name + ' updated Total consumption (l/month)* field in the following Opportunity more than 3 times: <a href="' + fullRecordURL + '">link</a></p>' +
                                    '<p>This is an automatically generated email, please do not respond.</p>');
                            allmsg.add(message);
                        }
                    }
                    if (!Test.isRunningTest()) {
                        Messaging.sendEmail(allmsg);
                    }
                }
            }
        }
    }


    /*******************************************************************************
    *  Name            : addSubjectsToCloneOpportunity(List<Opportunity> newList)
    *  Summary         : Add Attachment, Contact role and fuel card to clone Opportunity
    *  CreatedDate     : 21/02/2018
    *  ModifiedDate    : 16/05/2018
    *  Parameters      : List<Opportunity> newList
    *  Returns         : void
    ******************************************************************************/
    public static void addSubjectsToCloneOpportunity(List<Opportunity> newList) {
        Map<String, String> oldToNewOpptiesIdMap = new Map<String, String>();
        for (Opportunity oppty : newList) {
            if (oppty.isClone()) {
                oldToNewOpptiesIdMap.put(oppty.getCloneSourceId(), oppty.Id);
            }
        }

        List<Opportunity> oldOppList = [
                SELECT Credit_check_date__c, RecordType.Name
                FROM Opportunity
                WHERE Id IN :oldToNewOpptiesIdMap.keySet() AND
                RecordType.Name != 'Russian Sales' AND
                RecordType.Name != 'CCS Opportunity Layout'
                LIMIT 50000];

        if ( ! oldOppList.isEmpty() ) {
            for (Opportunity oppty : oldOppList) {
                Integer daysAfterCreditCheck;
                Integer count = 0;
                if (oppty.Credit_check_date__c != null) {
                    daysAfterCreditCheck = (Date.valueOf(oppty.Credit_check_date__c)).daysBetween(Date.today());
                }
                if (oppty.Credit_check_date__c == null || daysAfterCreditCheck < 90) {
                    Trigger.new[count].addError('You can\'t clone the record before 90 days "Credit check date".');
                }
                count++;
            }
        }

        if (! oldToNewOpptiesIdMap.isEmpty()) {
            // clone attachments
            List<Attachment> attachmentsList = [
                    SELECT Id, Name, Body, ParentId
                    FROM Attachment
                    WHERE ParentId IN :oldToNewOpptiesIdMap.keySet() AND
                    (Name != 'CrefoReport.pdf' AND Name != 'CreditsafeReport.pdf' AND Name != 'CrifReport.pdf' AND Name != 'CofaceReport.pdf')
                    LIMIT 10000];

            List<Attachment> cloneAttachmentsList = new List<Attachment>();
            for (Attachment attachment : attachmentsList) {
                Attachment newAttachment = attachment.clone();
                newAttachment.ParentId = oldToNewOpptiesIdMap.get(attachment.ParentId);
                cloneAttachmentsList.add(newAttachment);
            }

            if ( ! cloneAttachmentsList.isEmpty()) {
                insert cloneAttachmentsList;
            }

            // clone fuel cards
            List<Tankkarten__c> tankkartenList = [
                    SELECT Id, Name, Driver_Name__c, KFZ_Kennzeichen_oder_Fahrername__c, Gross__c, Fahrzeugtyp__c, Produktbezugskategorie__c, Firmenname_auf_der_Karte__c, Opportunity__c
                    FROM Tankkarten__c
                    WHERE Opportunity__c IN :oldToNewOpptiesIdMap.keySet()
                    LIMIT 10000];

            List<Tankkarten__c> cloneTankkartenList = new List<Tankkarten__c>();
            for (Tankkarten__c tankkarten : tankkartenList) {
                Tankkarten__c newTankkarten = tankkarten.clone();
                newTankkarten.Opportunity__c = oldToNewOpptiesIdMap.get(tankkarten.Opportunity__c);
                cloneTankkartenList.add(newTankkarten);
            }

            if ( ! cloneTankkartenList.isEmpty()) {
                insert cloneTankkartenList;
            }

            // clone contact role
            List<OpportunityContactRole> opptyContactRoleList = [
                    SELECT Id, Role, ContactId, OpportunityId, IsPrimary
                    FROM OpportunityContactRole
                    WHERE OpportunityId IN :oldToNewOpptiesIdMap.keySet()
                    LIMIT 10000];

            List<OpportunityContactRole> oppConRoleToInsertList = new List<OpportunityContactRole>();
            for (OpportunityContactRole opptyConRole : opptyContactRoleList) {
                OpportunityContactRole newOpptyContactRole = opptyConRole.clone();
                newOpptyContactRole.OpportunityId = oldToNewOpptiesIdMap.get(opptyConRole.OpportunityId);
                if (opptyConRole.IsPrimary == true) {
                    newOpptyContactRole.IsPrimary = true;
                }
                oppConRoleToInsertList.add(newOpptyContactRole);
            }

            if ( ! oppConRoleToInsertList.isEmpty()) {
                insert oppConRoleToInsertList;
            }
        }
    }


    /*******************************************************************************
    *  Name            : setOpptyFieldsForClone()
    *  Summary         : Set fields if Opportunity is clone
    *  CreatedDate     : 16/02/2018
    *  ModifiedDate    : 16/05/2018
    *  Parameters      : List<Opportunity> newList
    *  Returns         : void
    ******************************************************************************/
    public static void setOpptyFieldsForClone(List<Opportunity> newList) {
        for (Opportunity opp : newList) {
            if (opp.isClone() && opp.RecordType.Name != 'Russian Sales') {
                opp.StageName = 'Prospecting';
                opp.bearbeitet_von__c = '';
                opp.Closed_Won_by_CF__c = false;
                opp.Pending_Deposit_by_CF__c = false;
                opp.CF_Stage__c = 'Not launched';
                opp.Name_of_the_payer_Account_holder__c = '';
                opp.IBAN__c = '';
                opp.SWIFT_BIC__c = '';
            }
            if (opp.isClone() && opp.RecordType.Name == 'Russian Sales'){
                opp.StageName = 'Qualified Lead';
            }
        }
    }


    /*******************************************************************************
    *  Name            : updateCurrencyIsoCode()
    *  Summary         : Update the CurrencyIsoCode in Opportunity
    *  CreatedDate     : 02-03-2018
    *  ModifiedDate    : -
    *  Parameters      : Map<Id, Opportunity> oldMap, Map<Opportunity> newList
    *  Returns         : void
    ******************************************************************************/
    public static void updateCurrencyIsoCode(Map<Id, Opportunity> oldMap, List<Opportunity> newList) {
        if (oldMap == null) {
            // before insert
            for (Opportunity opp : newList) {
                if (opp.Registered_Country__c != null) {
                    opp.CurrencyIsoCode = CountryToCurrencyIsoCodeMap.get(opp.Registered_Country__c);
                }
            }
        } else {
            // before update
            for (Opportunity opp : newList) {
                if (opp.Registered_Country__c != null && oldMap.get(opp.Id).AccountId != opp.AccountId) {
                    opp.CurrencyIsoCode = CountryToCurrencyIsoCodeMap.get(opp.Registered_Country__c);
                }
            }
        }
    }


    /*******************************************************************************
    *  Name            : addErrorForCredit()
    *  Summary         : Add error for Credit if primary contact does not have valide email, incorrect details, Credit Decision is not "Endorsed" or "Endorsed, guarantee delivered"
    *  CreatedDate     : 05-03-2018
    *  ModifiedDate    : -
    *  Parameters      : Map<Id, Opportunity> oldMap, List<Opportunity> newList
    *  Returns         : void
    ******************************************************************************/
    public static void addErrorForCredit(Map<Id, Opportunity> oldMap, List<Opportunity> newList) {
        List<Profile> profileList = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1];

        String currentProfile = '';
        if ( ! profileList.isEmpty() ){
            currentProfile = profileList.get(0).Name;
        }

        List<Opportunity> opportunityList = [SELECT Id, (SELECT Contact.Email, IsPrimary FROM OpportunityContactRoles) FROM Opportunity WHERE Id IN :newList LIMIT 10000];
        String contactEmail;

        for (Opportunity opp : opportunityList) {
            for (OpportunityContactRole ocr : opp.OpportunityContactRoles) {
                if (ocr.IsPrimary == true) {
                    contactEmail = ocr.Contact.Email;
                }
            }
        }

        for (Opportunity opp : newList) {
            if (currentProfile == 'Credit' && opp.StageName == 'Closed Won' && oldMap.get(opp.Id).StageName != opp.StageName) {
                if (opp.Kredit_Entscheidung__c != 'Genehmigt' && opp.Kredit_Entscheidung__c != 'Genehmigt, Sicherheit geliefert') {
                    opp.Kredit_Entscheidung__c.addError('The field \"Credit Decision\" should be only \"Endorsed\" or \"Endorsed, guarantee delivered\"');
                }
                if (opp.Angaben_korrekt__c != 'Ja') {
                    opp.Angaben_korrekt__c.addError('The field \"Details correct\" should be only \"Yes\"');
                }
                if (contactEmail == null) {
                    opp.StageName.addError('Incorrect contact email or there is no primary contact');
                }
            }
        }
    }

    public static Map<String, String> CountryToCurrencyIsoCodeMap = new Map<String, String>{
            'Austria' => 'EUR',
            'Belgium-FR' => 'EUR',
            'Belgium-NL' => 'EUR',
            'Czech Republic' => 'CZK',
            'Germany' => 'EUR',
            'Hungary' => 'HUF',
            'Luxembourg' => 'EUR',
            'Netherlands' => 'EUR',
            'Poland' => 'PLN',
            'Slovakia' => 'EUR',
            'Switzerland-DE' => 'CHF',
            'Switzerland-FR' => 'CHF',
            'Switzerland-IT' => 'CHF'
    };

    public static Map<String, String> templatesForCountriesMap = new Map<String, String>{
            'Germany' => 'Letter_8_visualforce',
            'Czech Republic' => 'Letter 9 visualforce [CZ]',
            'Slovakia' => 'Letter 9 visualforce [SK]',
            'Switzerland-DE' => 'Letter 8 visualforce [CH-DE]',
            'Switzerland-FR' => 'Letter 8 visualforce [CH-FR]',
            'Switzerland-IT' => 'Letter 8 visualforce [CH-IT]',
            'Luxembourg' => 'Letter 8 visualforce [LU]',
            'Austria' => 'Letter_8_visualforce_AT',
            'Belgium-FR' => 'Letter_8_visualforce_[BE-FR]',
            'Belgium-NL' => 'Letter_8_visualforce_[BE-NL]',
            'France' => 'Letter_8_visualforce_[FR]',
            'Hungary' => 'Letter 9 visualforce [HU]',
            'Netherlands' => 'Letter_8_visualforce_[NL]',
            'Poland' => 'Letter_9_visualforce_PL'
    };

    public static Map<String, String> templatesForBackOfficeStartsStatusesMap = new Map<String, String>{
            '0.6 Missing information provided' => 'Notify_Missing_Info_Done_to_Back_Office',
            'New Cards Requested to BO' => 'New_Cards_Requested_to_BO',
            'New PINs Requested to BO' => 'New_PINs_Requested_to_BO',
            '5.5 Winback Failed' => 'Contract_Termination_to_BO',
            'new closed won' => 'New_Closed_Won_Customer_to_BO'
    };

    public static Map<String, String> templatesForOwnerStartsStatusesMap = new Map<String, String>{
            '0.5 Missing information' => 'BO_Requires_Additional_Information',
            '0.4 Registration in GFN: Winback' => 'Winback_Request_Setup_in_GFN',
            '3.4 Volume Check 1: Winback' => 'Winback_Request_Volume_Check_1',
            '4.4 Volume Check 2: Winback' => 'Winback_Request_Volume_Check_2',
            '5.4 Final Check: Winback' => 'Winback_Request_Final_Check'
    };

    public static Map<String, Integer> startsSLAvaluesMap = new Map<String, Integer>{
            '0.5 Missing information' => 1,
            '0.4 Registration in GFN: Winback' => 1,
            '0.6 Missing information provided' => 1,
            '0.9 Ready for GFN' => 1,
            '1. Customer registered in GFN (card issued & delivered)' => 9,
            '2.1 First Check: Cards/PINs Received' => 14,
            '2.2 First Check: Not Reached' => 7,
            '2.3 First Check: Delay' => 7,
            '2.4 First Check: Winback' => 7,
            '3.1 Volume Check 1: Customer Pumping' => 14,
            '3.2 Volume Check 1: Not Reached' => 7,
            '3.3 Volume Check 1: Delay' => 7,
            '3.4 Volume Check 1: Winback' => 7,
            '4.1.1 Volume Check 2: Pumping Enough' => 14,
            '4.1.2 Volume Check 2: Pumping NOT Enough' => 14,
            '4.2 Volume Check 2: Not Reached' => 7,
            '4.3 Volume Check 2: Delay' => 7,
            '4.4 Volume Check 2: Winback' => 7,
            '5.4 Final Check: Winback' => 7
    };

    /*******************************************************************************
    *  Name            : sendOpportunityReportToBackOffice()
    *  Summary         : generate and send Excel report about account and cards to GFN
    *  CreatedDate     : 24.11.2017
    *  Parameters      : Map<Id, Opportunity> oldOpportunitiesMap, Map<Id, Opportunity> newOpportunitiesMap
    *  Returns         : void
    ******************************************************************************/
    public static void sendAccountReportToBackOffice(Map<Id, Opportunity> oldOpportunitiesMap, Map<Id, Opportunity> newOpportunitiesMap) {
        System.debug('IN sendAccountReportToBackOffice');
        System.debug('New oppty ' + newOpportunitiesMap);
        for (Opportunity opportunity : newOpportunitiesMap.values()) {
            if (opportunity.Starts_Status__c == null)
                continue;

            System.debug('Is ready for GFN?: ' + opportunity.Starts_Status__c.equals('0.9 Ready for GFN'));
            System.debug('Is updated?: ' + !opportunity.Starts_Status__c.equals(oldOpportunitiesMap.get(opportunity.Id).Starts_Status__c));
            System.debug('Is GFNI_ApplicationId__c null?: ' + opportunity.GFNI_ApplicationId__c);
            System.debug('Is GFN_Nr__c null?: ' + opportunity.GFN_Nr__c);
            System.debug('Together: ' + (opportunity.Starts_Status__c.equals('0.9 Ready for GFN') && !opportunity.Starts_Status__c.equals(oldOpportunitiesMap.get(opportunity.Id).Starts_Status__c)));

            if (opportunity.Starts_Status__c != oldOpportunitiesMap.get(opportunity.Id).Starts_Status__c && opportunity.Starts_Status__c.equals('0.9 Ready for GFN') && opportunity.GFN_Nr__c == null)
            //&& opportunity.GFNI_ApplicationId__c == null && opportunity.GFN_Nr__c == null){
            {
                //opptysToUpdate.add(opportunity.Id);
                //System.debug('opp-ty added for update');
                System.debug('Call future method for ' + opportunity.Id);
                GFNI_Handler.createFullGFNCustomer(opportunity.Id);
            }
        }


//        Set<Id> opportunityIds = new Set<Id>();
//        for (Opportunity opportunity : newOpportunitiesMap.values()) {
//            if (opportunity.Starts_Status__c != oldOpportunitiesMap.get(opportunity.Id).Starts_Status__c) {
//                opportunityIds.add(opportunity.Id);
//            }
//        }
//
//        if(!opportunityIds.isEmpty()){
//            Set<Id> euroShellRecordTypesIds = new Set<Id>();
//            euroShellRecordTypesIds.add(GlobalUtils.getRecordTypeId('Opportunity', 'Euroshell'));
//            euroShellRecordTypesIds.add(GlobalUtils.getRecordTypeId('Opportunity', 'Euroshell_Starts'));
//
//            if(!euroShellRecordTypesIds.isEmpty()){
//                if(!System.isFuture() || !System.isBatch()){
//                    GfnReportSender.sendGFNReportToRobot(opportunityIds);
//                }
//            }
//        }
//    }
//
//    public static void createMailingLog(List<AccountGfnReportSendingLog> sendingLogs, String status) {
//        List<Mailing_Account_GFN_Report_Log__c> logsForInsert = new List<Mailing_Account_GFN_Report_Log__c>();
//        for (AccountGfnReportSendingLog sendingLog : sendingLogs) {
//            Mailing_Account_GFN_Report_Log__c log = new Mailing_Account_GFN_Report_Log__c(
//                    Account__c = sendingLog.accountId,
//                    Opportunity__c = sendingLog.opportunityId,
//                    Starts_Status_Changed_By__c = sendingLog.userId,
//                    Address__c = sendingLog.address,
//                    File_Name__c = sendingLog.fileName,
//                    Sending_Status__c = status);
//            logsForInsert.add(log);
//        }
//        insert logsForInsert;
    }

    /*********************************************************************************************************
    *  Name            : closeTasksAfterOpportunityClosed()
    *  Summary         : checks if Opportunity's status changed to 'Closed Lost' and closes its current Tasks
    *  CreatedDate     : 20/02/2018
    *  ModifiedDate    : -
    *  Parameters      : List<Opportunity> newList
    *  Returns         : void
    **********************************************************************************************************/
    public static void closeTasksAfterOpportunityClosed(List<Opportunity> newList, Map<ID, Opportunity> newMap) {
        isOpportunityClosed = false;
        String euroshellRecId = GlobalUtils.returnRecordTypeId('Opportunity', 'Euroshell');
        String allstarRecId = GlobalUtils.returnRecordTypeId('Opportunity', 'AllStar');
        String ccsOppoRecId = GlobalUtils.returnRecordTypeId('Opportunity', 'CCS Opportunity Layout');
        List<User> userList = [SELECT Id FROM User WHERE Name = 'Integration Administrator' LIMIT 1];

        Set<Id> oppIdsWithClosedStatus = new Set<Id>();
        for (Opportunity op : newList) {
            if (op.StageName == 'Closed Lost' &&
                    (op.RecordTypeId == euroshellRecId || op.RecordTypeId == allstarRecId || op.RecordTypeId == ccsOppoRecId)) {
                oppIdsWithClosedStatus.add(op.Id);
            }
        }

        if (oppIdsWithClosedStatus.isEmpty() || userList.isEmpty()) {
            return;
        }

        List<Task> listTasksToClose = new List<Task>();
        for (List<Task> listTasks : [
                SELECT Id, WhatId, IsClosed, OwnerId
                FROM Task
                WHERE WhatId IN :oppIdsWithClosedStatus
                AND IsClosed = False
        ]) {
            for (Task tk : listTasks) {
                Opportunity op = newMap.get(tk.WhatId);
                if (tk.OwnerID == op.OwnerID || tk.OwnerId == userList.get(0).Id) {
                    tk.Status = 'Completed';
                    listTasksToClose.add(tk);
                }
            }
        }

        if (!listTasksToClose.isEmpty()) {
            update listTasksToClose;
        }
    }

    /*******************************************************************************************************
    *  Name            : updateOpportunityAZSShellOne()
    *  Summary         : update AZS SHELL fields AZS_with_Discount_1_address__c and AZS_with_Discount_1__c  on OPPORTUNITY
    *  CreatedDate     : 02/03/2018
    *  ModifiedDate    : -
    *  Parameters      : List<Opportunity> newList
    *  Returns         : void
    *****************************************************************************************************/
    public static void updateOpportunityAZSShellOne(List<Opportunity> newList) {
        Set<id> idRecordTypesRussianSales = getRussianSalesRecordType();
        Set<String> stationAZS = new Set<String>();
        for (Opportunity newOpportunity : newList) {
            if ((newOpportunity.PPR_AZS_Retailer__c != null) &&
                    (idRecordTypesRussianSales.contains(newOpportunity.RecordTypeId))) {
                stationAZS.add(newOpportunity.PPR_AZS_Retailer__c);
            }
        }
        if (!stationAZS.isEmpty()) {
            List<ShellTerminalAZS__c> shellAZS = [
                    SELECT name, Terminallist__c
                    FROM ShellTerminalAZS__c
                    WHERE name in :stationAZS
            ];
            for (Opportunity opportunity : newList) {
                if (opportunity.PPR_AZS_Retailer__c != null) {
                    for (ShellTerminalAZS__c shellTerminalAZS : shellAZS) {
                        if (opportunity.PPR_AZS_Retailer__c == shellTerminalAZS.name) {
                            opportunity.AZS_with_Discount_1_address__c = shellTerminalAZS.name;
                            opportunity.AZS_with_Discount_1__c = shellTerminalAZS.Terminallist__c;
                        }
                    }
                }
            }
        }
    }

    /*******************************************************************************************************
   *  Name            : updateOpportunityAZSShellOneTwo()
   *  Summary         : update AZS SHELL fields AZS_with_Discount_1_address__c, AZS_with_Discount_1__c  and
   *                     AZS_with_Discount_2_address__c, AZS_with_Discount_2__con OPPORTUNITY
   *  CreatedDate     : 05/06/2018
   *  ModifiedDate    : -
   *  Parameters      : Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap
   *  Returns         : void
   *****************************************************************************************************/
    public static void updateOpportunityAZSShellOneTwo(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
        Set<id> idRecordTypesRussianSales = getRussianSalesRecordType();
        Map<Opportunity, String> azsOpportunitiesOne = new Map<Opportunity, String>();
        Map<Opportunity, String> azsOpportunitiesTwo = new Map<Opportunity, String>();
        for (Opportunity newOpportunity : newMap.values()) {
            Opportunity oldOpportunity = oldMap.get(newOpportunity.Id);
            if ((newOpportunity.AZS_with_Discount_1_address__c != oldOpportunity.AZS_with_Discount_1_address__c) &&
                    (idRecordTypesRussianSales.contains(newOpportunity.RecordTypeId)))
                azsOpportunitiesOne.put(newOpportunity, newOpportunity.AZS_with_Discount_1_address__c);

            if ((newOpportunity.AZS_with_Discount_2_address__c != oldOpportunity.AZS_with_Discount_2_address__c) &&
                    (idRecordTypesRussianSales.contains(newOpportunity.RecordTypeId)))
                azsOpportunitiesTwo.put(newOpportunity, newOpportunity.AZS_with_Discount_2_address__c);
        }
        if ( ! azsOpportunitiesOne.isEmpty() || ! azsOpportunitiesTwo.isEmpty() ) {
            Map<String, String> shellAZS = new Map<String, String>();
            for (ShellTerminalAZS__c shellTerminalAZS : [
                    SELECT name, TerminalList__c
                    FROM ShellTerminalAZS__c
                    WHERE (name IN :azsOpportunitiesOne.values()
                    OR name IN :azsOpportunitiesTwo.values())
            ]) {
                shellAZS.put(shellTerminalAZS.name, shellTerminalAZS.TerminalList__c);
            }

            for (Opportunity opportunity : azsOpportunitiesOne.keySet()) {
                if (opportunity.AZS_with_Discount_1_address__c == null) {
                    opportunity.AZS_with_Discount_1__c = '';
                } else {
                    opportunity.AZS_with_Discount_1__c = shellAZS.get(opportunity.AZS_with_Discount_1_address__c);
                }
            }

            for (Opportunity opportunity : azsOpportunitiesTwo.keySet()) {
                if (opportunity.AZS_with_Discount_2_address__c == null) {
                    opportunity.AZS_with_Discount_2__c = '';
                } else {
                    opportunity.AZS_with_Discount_2__c = shellAZS.get(opportunity.AZS_with_Discount_2_address__c);
                }
            }
        }
    }


    /*******************************************************************************
    *  Name            : setCloseDate(Map<Id, Opportunity> oldOpportunitiesMap, Map<Id, Opportunity> newOpportunitiesMap)
    *  Summary         : Update Closed Date when Stage is changed to "Closed Won" or "Closed Lost"    
    *  CreatedDate     : 08/05/2018
    *  ModifiedDate    : -
    *  Parameters      : Map<Id, Opportunity> oldOpportunitiesMap - map with old opportunity values, Map<Id, 
                         Opportunity> newOpportunitiesMap - map with new Opportunities values
    *  Returns         : void
    ******************************************************************************/
    public static void setCloseDate(Map<Id, Opportunity> oldOpportunitiesMap, Map<Id, Opportunity> newOpportunitiesMap) {
        Set<String> recordTypeIdsSet = new Set<String>{
                GlobalUtils.returnRecordTypeId('Opportunity', 'Euroshell'),
                GlobalUtils.returnRecordTypeId('Opportunity', 'Euroshell Starts')
        };
        for (Opportunity opportunity : newOpportunitiesMap.values()) {
            if (opportunity.StageName != oldOpportunitiesMap.get(opportunity.Id).StageName &&
                    (opportunity.StageName == 'Closed Won' || opportunity.StageName == 'Closed Lost') &&
                    recordTypeIdsSet.contains(opportunity.RecordTypeId)) {
                opportunity.CloseDate = Date.today();
            }
        }
    }

    /*******************************************************************************************************
    *  Name            : updateOpenTaskCheckbox(Map<Id, Opportunity> oldMap, List<Opportunity> newList)
    *  Summary         : update Open_Task__c field when opportunity owner is changed
    *  CreatedDate     : 07/05/2018
    *  ModifiedDate    : -
    *  Parameters      : Map<Id, Opportunity> oldMap, List<Opportunity> newList
    *  Returns         : void
    *****************************************************************************************************/
    public static void updateOpenTaskCheckbox(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
        Set<Id> opptysToUpdate = new Set<Id>();
        for (Opportunity opportunity : newMap.values()) {
            if (opportunity.OwnerId != oldMap.get(opportunity.Id).OwnerId) {
                opptysToUpdate.add(opportunity.Id);
            }
        }

        if (opptysToUpdate.size() > 0) {
            String requestUrl = System.URL.getCurrentRequestUrl().getPath();
            List<Opportunity> opptyList = [SELECT Id, (SELECT Id, OwnerId FROM Tasks WHERE IsClosed = false) FROM Opportunity WHERE Id in :opptysToUpdate];
            for (Opportunity opportunity : opptyList) {
                if (opportunity.Tasks.size() > 0) {
                    newMap.get(opportunity.Id).Open_Task__c = false;
                    /**
                     * есть 4 варианта смены владельца возможности. При одном из них так же меняется владелец таски, только без вызова таск триггера.
                     * Таким образом в 3 случаях нам надо сравнивать только нового владельца с владельцем таски, так как владелец тасок не поменяется.
                     * Иначе надо сравнивать и нового и старого владельца. В случае если хотябы один совпал, то ставится true. Тоесть если были таски с таким же вледельцем что и возможность,
                     * то владелец таски поменяется. Если же не было тасок с таким же владельцем, то надо проверить вдруг есть таски с новым пользователем.
                     *
                     * There are 4 options for changing the owner of the opportunity. With one of them, the owner of the task also changes, only without triggering a task trigger.
                     * Thus, in 3 cases, we need only compare the new owner with the owner of tasks, as the owner of tasks not changes.
                     * Otherwise, you need to compare the new and the old owner. In case if at least one coincided, then it is set to true. Ie if there were tasks with the same owner as the opportunity,
                     * then the owner of the user will change. If there were no tasks with the same owner, then you should check is there a task with a new owner.
                     *
                     * requestUrl.contains('/services/Soap/') - смена владельца через DataLoader/Api / owner change via DataLoader/Api
                     * requestUrl.contains('waitingJobPage') - смена владельца через Account / owner change via Account owner change
                     * requestUrl.contains('ApprovePprRequestFromEmail') - смена владельца через ApprovePprRequestFromEmail.page / owner change via ApprovePprRequestFromEmail.page
                     */
                    if (requestUrl.contains('/services/Soap/') || requestUrl.contains('waitingJobPage') || requestUrl.contains('ApprovePprRequestFromEmail')) {
                        //owner changed from acc or via data loader or approval process
                        for (Task task : opportunity.Tasks) {
                            if (task.OwnerId.equals(newMap.get(opportunity.Id).OwnerId)) {
                                newMap.get(opportunity.Id).Open_Task__c = true;
                                break;
                            }
                        }
                    } else {
                        //owner changed from oppty page
                        for (Task task : opportunity.Tasks) {
                            if (task.OwnerId.equals(newMap.get(opportunity.Id).OwnerId) || task.OwnerId.equals(oldMap.get(opportunity.Id).OwnerId)) {
                                newMap.get(opportunity.Id).Open_Task__c = true;
                                break;
                            }
                        }
                    }
                }
            }
        }
    }


    /*******************************************************************************
    *  Name            : closeSignedOpportunities(Map<Id, Opportunity> oldOpportunitiesMap, List<Opportunity> newOpportunitiesList)
    *  Summary         : If Opportunity Stage is "Contract Check" and DocuSign_Status__c 
                         is chaged to "Comleted", then change Opportunity Stage to "Closed Won"     
    *  CreatedDate     : 01/06/2018
    *  ModifiedDate    : -
    *  Parameters      : Map<Id, Opportunity> oldOpportunitiesMap - map of old Opportunities values, 
                         List<Opportunity> newOpportunitiesList - list of new Opportunities values
    *  Returns         : void
    ******************************************************************************/
    public static void closeSignedOpportunities(Map<Id, Opportunity> oldOpportunitiesMap, List<Opportunity> newOpportunitiesList) {
        for (Opportunity newOpportunity : newOpportunitiesList) {
            if (newOpportunity.StageName == 'Pending Credit - Contract Check' && newOpportunity.DocuSign_Status__c == 'Completed' &&
                    oldOpportunitiesMap.get(newOpportunity.Id).DocuSign_Status__c != newOpportunity.DocuSign_Status__c) {
                newOpportunity.StageName = 'Closed Won';
                newOpportunity.CF_Stage__c = 'Auto CW';
                newOpportunity.Closed_Won_by_CF__c = true;
            }
        }
    }


    /*******************************************************************************
    *  Name            : approveSignedOpportunities(Map<Id, Opportunity> oldOpportunitiesMap, List<Opportunity> newOpportunitiesList)
    *  Summary         : If Opportunity Stage is changed from "Contract Check" to "Closed Won" and DocuSign_Status__c 
                         is chaged to "Comleted", then approve Opportunity    
    *  CreatedDate     : 05/06/2018
    *  ModifiedDate    : -
    *  Parameters      : Map<Id, Opportunity> oldOpportunitiesMap - map of old Opportunities values, 
                         List<Opportunity> newOpportunitiesList - list of new Opportunities values
    *  Returns         : void
    ******************************************************************************/
    public static void approveSignedOpportunities(Map<Id, Opportunity> oldOpportunitiesMap, List<Opportunity> newOpportunitiesList) {
        Set<Id> opportunitiesToApproveIdsSet = new Set<Id>();
        for (Opportunity newOpportunity : newOpportunitiesList) {
            if (newOpportunity.StageName == 'Closed Won' && oldOpportunitiesMap.get(newOpportunity.Id).StageName == 'Pending Credit - Contract Check'
                    && newOpportunity.DocuSign_Status__c == 'Completed' && oldOpportunitiesMap.get(newOpportunity.Id).DocuSign_Status__c != newOpportunity.DocuSign_Status__c) {
                opportunitiesToApproveIdsSet.add(newOpportunity.Id);
            }
        }

        if (! opportunitiesToApproveIdsSet.isEmpty()) {
            List<ProcessInstance> processInstancesList = [
                    SELECT Id, (SELECT Id FROM Workitems)
                    FROM ProcessInstance
                    WHERE TargetObjectId IN :opportunitiesToApproveIdsSet AND Status = 'Pending'];

            List<Approval.ProcessWorkitemRequest> requestsList = new List<Approval.ProcessWorkitemRequest>();
            for (ProcessInstance processInstance : processInstancesList) {
                for (ProcessInstanceWorkItem workItem : processInstance.Workitems) {
                    Approval.ProcessWorkitemRequest request = new Approval.ProcessWorkitemRequest();
                    request.setAction('Approve');
                    request.setNextApproverIds(new Id[] {UserInfo.getUserId()});
                    request.setWorkitemId(workItem.Id);
                    requestsList.add(request);
                }
            }

            Approval.process(requestsList);
        }
    }


    /*******************************************************************************
    *  Name            : updateE2EFields()
    *  Summary         : update E2E_Status__c and E2E_Sales_Type__c before insert    
    *  CreatedDate     : 17/07/2018
    *  ModifiedDate    : -
    *  Parameters      : Map<Id, Opportunity> oldMap, List<Opportunity> newList
    *  Returns         : void
    ******************************************************************************/
    public static void updateE2EFields(Map<Id, Opportunity> oldMap, List<Opportunity> newList) {
        Set<Id> recordTypesIdsSet = new Set<Id>();
        if (GlobalUtils.returnRecordTypeId('Opportunity', 'Euroshell') != null) {
            recordTypesIdsSet.add(GlobalUtils.returnRecordTypeId('Opportunity', 'Euroshell'));
        }
        if (oldMap == null) {
            // before insert
            for (Opportunity opportunity : newList) {
                if ( ! opportunity.E2E__c && recordTypesIdsSet.contains(opportunity.RecordTypeId)) {
                    opportunity.E2E_Status__c = 'In progress';
                    opportunity.E2E_Sales_Type__c = 'Fully manual';
                }
            }
        } else {
            // before update
            for (Opportunity opportunity : newList) {
                if (recordTypesIdsSet.contains(opportunity.RecordTypeId) && oldMap.get(opportunity.Id).StageName != opportunity.StageName &&
                        (opportunity.StageName == 'Closed Lost' || opportunity.StageName == 'Closed Won' || opportunity.StageName == 'Pending Sales – Deposit')) {
                    opportunity.E2E_Status__c = 'Finished';
                }
            }
        }
    }


    /*******************************************************************************
    *  Name            : updateFieldsForVatRecovery(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap)
    *  Summary         : Update required for vat recovery fields or display an error if they are empty
    *  CreatedDate     : 25/12/2018
    *  ModifiedDate    : -
    *  Parameters      : Map<Id, Opportunity> oldMap - old Opportunity values, Map<Id, Opportunity> newMap - new Opportunity values
    *  Returns         : void
    ******************************************************************************/
    public static void updateFieldsForVatRecovery(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
        Set<Id> recordTypesIdsSet = new Set<Id>();
        if (GlobalUtils.returnRecordTypeId('Opportunity', 'Euroshell') != null) {
            recordTypesIdsSet.add(GlobalUtils.returnRecordTypeId('Opportunity', 'Euroshell'));
        }

        Set<Id> opportunitiesIdsSet = new Set<Id>();
        for (Opportunity opportunity : newMap.values()) {
            if (recordTypesIdsSet.contains(opportunity.RecordTypeId) && opportunity.Registered_Country__c == 'Poland' && opportunity.VAT_Recovery__c == true &&
                    (opportunity.StageName == 'Closed Won' || opportunity.StageName == 'Pending Credit - Contract Check') && opportunity.StageName != oldMap.get(opportunity.Id).StageName &&
                    opportunity.E2E__c == false) {
                opportunitiesIdsSet.add(opportunity.Id);
            }
        }

        if (! opportunitiesIdsSet.isEmpty()) {
            Map<Id, Opportunity> opportunitiesMap = new Map<Id, Opportunity>([
                    SELECT Account.Gesellschaftsform__c, 
                            (SELECT Contact.Birthdate, IsPrimary
                            FROM OpportunityContactRoles), 
                            (SELECT Fahrzeugtyp__c
                            FROM Tankkarten__r)
                    FROM Opportunity
                    WHERE Id IN :opportunitiesIdsSet]);
            for (Opportunity opportunity : newMap.values()) {
                if (opportunitiesMap.containsKey(opportunity.Id) && soloTradersLegalFormsList.contains(opportunitiesMap.get(opportunity.Id).Account.Gesellschaftsform__c)) {
                    for (OpportunityContactRole role : opportunitiesMap.get(opportunity.Id).OpportunityContactRoles) {
                        if (role.IsPrimary == true) {
                            if (role.Contact.Birthdate != null) {
                                opportunity.Primary_Contact_Birthdate__c = role.Contact.Birthdate;
                            } else {
                                opportunity.addError('Birthdate of primary contact shouldn\'t be empty.');
                            }

                            break;
                        }
                    }

                    Set<String> typesOfTheVehiclesSet = new Set<String>();
                    for (Tankkarten__c card : opportunitiesMap.get(opportunity.Id).Tankkarten__r) {
                        typesOfTheVehiclesSet.add(card.Fahrzeugtyp__c);
                    }

                    if (typesOfTheVehiclesSet.contains('PKW') && typesOfTheVehiclesSet.contains('LKW')) {
                        opportunity.Fleet_type_VAT_recovery__c = 'Mixed';
                    } else if (typesOfTheVehiclesSet.contains('PKW')) {
                        opportunity.Fleet_type_VAT_recovery__c = 'Fleet';
                    } else if (typesOfTheVehiclesSet.contains('LKW')) {
                        opportunity.Fleet_type_VAT_recovery__c = 'CRT';
                    }
                }
            }
        }
    }


    public static List<String> soloTradersLegalFormsList = new List<String> {
        'e.K', // e.K.
        'ENTREPRISE INDIVIDUELLE', // INDIVIDUAL ENTREPRISE
        'Private limited company',
        'Einzelfirma', // Single company
        'Single person company confirmed',
        'Eenmanszaak' // Sole proprietorship
    };
}