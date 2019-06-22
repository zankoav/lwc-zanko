/**
 * Created by Nikita.Mikhailov on 28.11.2018.
 * Class with future method to create new customer via REST or e-mail
 * Future method calls from OpportunityTrigger
 */
global class GFNI_Handler {

    /*******************************************************************************
    *  Name            : createFullGFNCustomer
    *  Summary         : future method for opportunity sorting and calling creation by REST or e-mail
    *  CreatedDate     : 28/11/2018
    *  Parameters      : Id opptyToUpdate
    *  Returns         : void
    ******************************************************************************/
    @Future(callout=true)
    public static void createFullGFNCustomer(Id opptyToUpdate) {
        System.debug('In future method');
        Set<Id> euroShellRecordTypesIds = new Set<Id>();
        if (GlobalUtils.returnRecordTypeId('Opportunity', 'Euroshell') != null) euroShellRecordTypesIds.add(GlobalUtils.returnRecordTypeId('Opportunity', 'Euroshell'));
        if (GlobalUtils.returnRecordTypeId('Opportunity', 'Euroshell Starts') != null) euroShellRecordTypesIds.add(GlobalUtils.returnRecordTypeId('Opportunity', 'Euroshell Starts'));
        List<Messaging.Email> mailsList = new List<Messaging.Email>();
        List<AccountGfnReportSendingLog> accountGfnReportSendingLogs = new List<AccountGfnReportSendingLog>();

        System.debug(opptyToUpdate);

        Opportunity opportunity = [
                SELECT Id,
                        Name,
                        RecordTypeId,
                        Starts_Status__c,
                        AccountId,
                        LastModifiedById,
                        Account.GFN_Nr__c,
                        Account.BillingCountryCode,
                        GFNI_ApplicationId__c
                FROM Opportunity
                WHERE Id = :opptyToUpdate
                LIMIT 1
        ];

        if (euroShellRecordTypesIds.contains(opportunity.RecordTypeId)) {
            if (GFNI_Utils.getGeneralSettings(opportunity.Account.BillingCountryCode).IsForRobot__c) {
                System.debug('Create by email');
                createByEmail(opportunity, mailsList, accountGfnReportSendingLogs);
            } else {
                System.debug('Create by request');
                if (Test.isRunningTest()) {
                    createByRequest(opportunity);
                } else {
                    if (GFNI_Utils.isProductionOrg()) {
                        createByRequest(opportunity);
                    } else if (GFNI_Utils.getGeneralSettings(opportunity.Account.BillingCountryCode).Test_mode__c) {
                        createByRequest(opportunity);
                    } else {
                        System.debug('WARNING!!! GFNI: You are running this code in sandbox. Please make sure that Test_mode is switched on for every country in GFNI_General_Settings__c!');
                    }
                }
            }
        }
    }

    /*******************************************************************************
    *  Name            : createByEmail
    *  Summary         : create by email
    *  CreatedDate     : 28.11.2018
    *  Parameters      : Opportunity opportunity, List<Messaging.Email> mailsList, List<AccountGfnReportSendingLog> accountGfnReportSendingLogs
    *  Returns         : void
    ******************************************************************************/
    public static void createByEmail(Opportunity opportunity, List<Messaging.Email> mailsList, List<AccountGfnReportSendingLog> accountGfnReportSendingLogs) {
        System.debug('*** PREPARE ACCOUNT REPORT FOR GFN ***');
        Account account = [SELECT Name, BillingCountry, Account_Nr__c FROM Account WHERE Id = :opportunity.AccountId];

        Account_GFN_Report_Email_Params__c emailParams = Account_GFN_Report_Email_Params__c.getInstance('Excel');
        String address = emailParams.Email__c;
        String emailBody = emailParams.Email_body__c;
        String format = emailParams.Attach_format__c;
        String subject = account.Name + ', ' + account.BillingCountry + ', ' + account.Account_Nr__c;
        String fileName = subject + format; // ex. Customer Account name, country, SFDC order number

        AccountGfnReportTemplate reportTemplate =
                new AccountGfnReportTemplate(opportunity.Id, opportunity.RecordTypeId, opportunity.AccountId);

        String htmlTemplate = reportTemplate.generateReportHtmlTemplate();
        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
        Blob excel = Blob.valueOf(htmlTemplate);
        attach.setBody(excel);
        attach.setFileName(fileName);
        //system.debug('EXCEL BLOB === ' + htmlTemplate);

        System.debug('*** SENDING GFN REPORT ***');

        // add address for debug
        Boolean debugMode = emailParams.Test_mode__c;
        String debugEmail = '';
        if (debugMode) {
            debugEmail = (emailParams.Test_mode_email__c != null) ? emailParams.Test_mode_email__c : '';
        }

        System.debug(subject);
        System.debug(emailBody);
        System.debug(address + ';' + debugEmail);

        GFNI_Utils.sendEmail(subject, emailBody, (address + ';' + debugEmail).split(';'), attach, new AccountGfnReportSendingLog(opportunity.AccountId, opportunity.Id, address, fileName, opportunity.LastModifiedById));
    }

    /*******************************************************************************
    *  Name            : createByRequest
    *  Summary         : create request, send it, receive response, consolidate results, save logs
    *  CreatedDate     : 28.11.2018
    *  Parameters      : Opportunity
    *  Returns         : void
    ******************************************************************************/
    public static void createByRequest(Opportunity opportunity) {
        System.debug('GFNI_Handler: ' + 'In create by request method');

        GFNI_Logger logger = String.isEmpty(opportunity.GFNI_ApplicationId__c) ? new GFNI_Logger(opportunity.Id, true) : new GFNI_Logger(opportunity.Id, false);
//Deduplication logic...
//        System.debug('GFNI_Handler: ' + '*** Check for double ***');
//
//        Boolean isExistingCustomer = null;
//
//        try{
//            isExistingCustomer = GFNI_Utils.isExistingCustomer(opportunity.Id);
//        } catch (Exception e) {
//            System.debug('GFNI_Handler: ' + 'exception on doubleCheck');
//            System.debug('GFNI_Handler: ' + e.getMessage() + ' : ' + e.getCause() + ' : ' + e.getStackTraceString());
//
//            logger.addLog('Error', e.getMessage() + ' : ' + e.getCause() + ' : ' + e.getStackTraceString(), 'N/A');
//
//            opportunity.GFNI_ApplicationId__c = 'N/A';
//            update opportunity;
//
//            logger.saveLogs();
//
//            GFNI_Utils.sendEmail('Exception!!', 'GFNI_Handler: ' + 'exception on doubleCheck \n' + +e.getMessage() + ' : ' + e.getCause() + ' : ' + e.getStackTraceString(), opportunity.Account.BillingCountryCode);
//
//            return;
//        }
//
//        if(isExistingCustomer){
//            //customer is double need to notify support team and don't create
//            return;
//        }

        System.debug('GFNI_Handler: ' + '*** PREPARE REQUEST FOR GFN ***');
        String body = '';
        try {
            body = GFNI_RequestBuilder.buildJSONCreateCustomerAndCards(opportunity);
        } catch (Exception e) {
            System.debug('GFNI_Handler: ' + 'exception on buildJSONCreateCustomerAndCards');
            System.debug('GFNI_Handler: ' + e.getMessage() + ' : ' + e.getCause() + ' : ' + e.getStackTraceString());

            logger.addLog('Error', e.getMessage() + ' : ' + e.getCause() + ' : ' + e.getStackTraceString(), 'N/A');

            opportunity.GFNI_ApplicationId__c = 'N/A';
            update opportunity;

            logger.saveLogs();

            GFNI_Utils.sendEmail('NCC_' + opportunity.Account.BillingCountryCode + '_Failure_' + opportunity.Name, 'Message: ' + e.getMessage() + '\n\nCause: ' + e.getCause() + '\n\nStackTrace: ' + e.getStackTraceString() + 'Method: GFNI_Handler.createByRequest.buildJSONCreateCustomerAndCards \n\n' + '\n\nHave a nice day!', opportunity.Account.BillingCountryCode);

            return;
        }
        System.debug(body);
        String requestId = GFNI_Utils.getStringValue(body, 'RequestID');
        System.debug('GFNI_Handler: ' + '*** SENDING GFN REQUEST ***');

        logger.addLog('Request', body, requestId);

        HttpResponse response;

        try {
            response = GFNI_RequestHandler.sendRequest(body, GFNI_Utils.getGeneralSettings(opportunity.Account.BillingCountryCode).Create_Customer_and_Cards__c, opportunity.Account.BillingCountryCode);
        } catch (Exception e) {
            //if there was a problem with request, update log with error and close session
            System.debug('GFNI_Handler: ' + 'exception on sendRequest');
            System.debug('GFNI_Handler: ' + e.getMessage() + ' : ' + e.getCause() + ' : ' + e.getStackTraceString());
            System.debug('Line number: ' + e.getLineNumber());

            logger.addLog('Error', e.getMessage() + ' : ' + e.getCause() + ' : ' + e.getStackTraceString(), requestId);

            opportunity.GFNI_ApplicationId__c = GFNI_Utils.getStringValue(body, 'ApplicationId');
            update opportunity;

            logger.saveLogs();

            GFNI_Utils.sendEmail('NCC_' + opportunity.Account.BillingCountryCode + '_Failure_' + opportunity.Name, 'Message: ' + e.getMessage() + '\n\nCause: ' + e.getCause() + '\n\nStackTrace: ' + e.getStackTraceString() + 'Method: GFNI_Handler.createByRequest.sendRequest \n\n' + '\n\nHave a nice day!', opportunity.Account.BillingCountryCode);

            return;
        }

        //if everything is fine, save response and update opportunity.GFNI_ApplicationId__c, account.GFN_Nr__c and card status for every card to Pending

        logger.addLog('Response', response.getBody(), requestId);

        System.debug('GFNI_Handler: ' + '*** UPDATING OPPORTUNITY AND ACCOUNT ***');
        opportunity.GFNI_ApplicationId__c = GFNI_Utils.getStringValue(body, 'ApplicationId');
        update opportunity;

        Account acc = opportunity.Account;
        acc.GFN_Nr__c = GFNI_Utils.getStringValue(response.getBody(), 'CustomerServiceReferenceId');
        update acc;

        System.debug('GFNI_Handler: ' + '*** UPDATING CARDS ***');
        List<Tankkarten__c> cards = new List<Tankkarten__c>();
        for (Tankkarten__c card : [SELECT Id, GFNI_Status__c FROM Tankkarten__c WHERE Opportunity__c = :opportunity.Id]) {
            card.GFNI_Status__c = 'Pending';
            cards.add(card);
        }
        update cards;

        System.debug('GFNI_Handler: ' + '*** UPDATING LOG ***');
        logger.saveLogs();
    }

    /*******************************************************************************
    *  Name            : checkCardStatus
    *  Summary         : future method for calling application status (cards creation status). Updates cards status. NOTE: this request is country specific, and must be called for opportunities with same country.
    *  CreatedDate     : 23.01.2019
    *  Parameters      : Set<Id>
    *  Returns         : void
    ******************************************************************************/
    @Future(callout=true)
    public static void checkCardStatus(Set<Id> opportunitiesIds) {

        List<Opportunity> opportunities = [
                SELECT Id, Name, Account.Id, Account.BillingCountry, Account.BillingCountryCode, CreatedDate, Account.Owner.Name,
                        GFNI_ApplicationId__c, GFN_Nr__c, (SELECT Id, GFNI_Status__c, Gewuenschter_Kartentyp__c, Driver_Name__c, KFZ_Kennzeichen_oder_Fahrername__c, Fahrzeugtyp__c FROM Tankkarten__r WHERE GFNI_Status__c = 'Pending')
                FROM Opportunity
                WHERE Id IN :opportunitiesIds
        ];

        Map<String, GFNI_Logger> logs = new Map<String, GFNI_Logger>();

        for (Opportunity opportunity : opportunities) {
            GFNI_Logger log = new GFNI_Logger(opportunity.Id, false);
            logs.put(opportunity.Id, log);
        }


        Map<String, Opportunity> opportunityMapByGFN = new Map<String, Opportunity>();

        System.debug('*** BUILDING REQUEST FOR: ' + opportunities.get(0).Account.BillingCountryCode + '***');

        String body;

        try {
            body = GFNI_RequestBuilder.buildJSONApplicationStatus(opportunities);
        } catch (Exception e) {
            System.debug('GFNI_ApplicationStatusSchedulable: ' + 'exception on buildRequest');
            System.debug('GFNI_ApplicationStatusSchedulable: ' + e.getMessage());

            for (Opportunity opportunity : opportunities) {
                GFNI_Logger log = logs.get(opportunity.Id);
                log.addLog('Error', e.getMessage() + ' : ' + e.getCause() + ' : ' + e.getStackTraceString(), 'N/A');
            }

            GFNI_Logger.saveLogsList(logs.values());

            GFNI_Utils.sendEmail('NCC_' + opportunities.get(0).Account.BillingCountryCode + '_Failure_', 'Message: ' + e.getMessage() + '\n\nCause: ' + e.getCause() + '\n\nStackTrace: ' + e.getStackTraceString() + 'Method: GFNI_Handler.checkCardStatus.buildRequest \n\n' + '\n\nHave a nice day!', opportunities.get(0).Account.BillingCountryCode);

            return;
        }

        System.debug(body);

        String requestId = GFNI_Utils.getStringValue(body, 'RequestID');

        //this code is needed for smooth logs. Using this logic, log will contain request for each opportunity individually. If not do it, log will contain all application info in every opp-ty log
        GFNI_ApplicationStatusRequest applicationApplicationStatusRequest = (GFNI_ApplicationStatusRequest) JSON.deserialize(body, GFNI_ApplicationStatusRequest.class);
        for (Opportunity opportunity : opportunities) {

            opportunityMapByGFN.put(opportunity.GFN_Nr__c, opportunity);

            GFNI_Logger log = logs.get(opportunity.Id);

            GFNI_ApplicationStatusRequest buffer = new GFNI_ApplicationStatusRequest();

            for (GFNI_Application application : applicationApplicationStatusRequest.Applications) {
                if (opportunity.GFNI_ApplicationId__c == application.ApplicationId) {
                    buffer.Metadata = applicationApplicationStatusRequest.Metadata;
                    buffer.addApplication(application);
                }
            }

            log.addLog('Request', JSON.serialize(buffer), requestId);
            System.debug(log);
        }

        System.debug('*** SENDING REQUEST FOR: ' + opportunities.get(0).Account.BillingCountryCode + '***');

        HttpResponse response;

        try {
            response = GFNI_RequestHandler.sendRequest(body, GFNI_Utils.getGeneralSettings(opportunities.get(0).Account.BillingCountryCode).Application_Status__c, opportunities.get(0).Account.BillingCountryCode);
        } catch (Exception e) {
            System.debug('GFNI_ApplicationStatusSchedulable: ' + 'exception on sendRequest');
            System.debug('GFNI_ApplicationStatusSchedulable: ' + e.getMessage());

            for (Opportunity opportunity : opportunities) {
                GFNI_Logger log = logs.get(opportunity.Id);
                log.addLog('Error', e.getMessage() + ' : ' + e.getCause() + ' : ' + e.getStackTraceString(), requestId);
            }

            GFNI_Logger.saveLogsList(logs.values());

            GFNI_Utils.sendEmail('NCC_' + opportunities.get(0).Account.BillingCountryCode + '_Failure_', 'Message: ' + e.getMessage() + '\n\nCause: ' + e.getCause() + '\n\nStackTrace: ' + e.getStackTraceString() + 'Method: GFNI_Handler.checkCardStatus.sendRequest \n\n' + '\n\nHave a nice day!', opportunities.get(0).Account.BillingCountryCode);

            return;
        }

        System.debug(response);
        System.debug(response.getBody());

        System.debug('*** CREATING CARDS TO UPDATE LIST ***');

        List<Object> responseObject = (List<Object>) JSON.deserializeUntyped(response.getBody());
        Map<String, List<Object>> cardsStatusesMap = new Map<String, List<Object>>();

        List<Tankkarten__c> cardsToUpdate = new List<Tankkarten__c>();
        Map<Id, String> failedCards = new Map<Id, String>();
        Map<Id, String> warningCards = new Map<Id, String>();

        for (Object application : responseObject) {
            for (Object cardStatus : (List<Object>) ((Map<String, Object>) application).get('CardsStatus')) {
                Tankkarten__c card = new Tankkarten__c();
                if (((Map<String, Object>) cardStatus).containsKey('CardRefId'))
                    card.Id = GlobalUtils.retrieveIdFromGUID(String.valueOf(((Map<String, Object>) cardStatus).get('CardRefId')));

                if (((Map<String, Object>) cardStatus).containsKey('CardApplicationStatusId')) {
                    switch on String.valueOf(((Map<String, Object>) cardStatus).get('CardApplicationStatusId')) {
                        when '1' {
                            card.GFNI_Status__c = 'Success';
                        }
                        when '2' {
                            card.GFNI_Status__c = 'Warning';
                            warningCards.put(card.Id, 'Failed to retrieve warning message');
                        }
                        when '3' {
                            card.GFNI_Status__c = 'Failed';
                            if (((Map<String, Object>) cardStatus).containsKey('CardProcessingError')) {
                                Map<String, Object> cardProcessingErrorObject = (Map<String, Object>) ((Map<String, Object>) cardStatus).get('CardProcessingError');
                                if (cardProcessingErrorObject.containsKey('ErrorMessage')) {
                                    failedCards.put(card.Id, String.valueOf(cardProcessingErrorObject.get('ErrorMessage')));
                                } else {
                                    failedCards.put(card.Id, 'Failed to retrieve failed message');
                                }
                            } else {
                                failedCards.put(card.Id, 'Failed to retrieve failed message');
                            }
                        }
                    }
                }

                cardsToUpdate.add(card);
            }
        }

        //if there was cards with warnings or failed send e-mail
        if (!warningCards.isEmpty() || !failedCards.isEmpty()) {
            String emailBody = 'There are some cards failed to be created or created with warnings!\n\n';
            if (!warningCards.isEmpty()) {
                emailBody += 'Cards created with warning:\n';
                for (Id key : warningCards.keySet()) {
                    emailBody += URL.getSalesforceBaseUrl().toExternalForm() + '/' + key + ' : ' + warningCards.get(key) + '\n';
                }
            }

            if (!failedCards.isEmpty()) {
                emailBody += 'Cards failed to be created:\n';
                for (Id key : failedCards.keySet()) {
                    emailBody += URL.getSalesforceBaseUrl().toExternalForm() + '/' + key + ' : ' + failedCards.get(key) + '\n';
                }
            }

            emailBody += '\nHave a nice day!';

            GFNI_Utils.sendEmail('NCC_' + opportunities.get(0).Account.BillingCountryCode + '_Failure_', emailBody, opportunities.get(0).Account.BillingCountryCode);
        }

        for (Opportunity opportunity : opportunityMapByGFN.values()) {

            //this code is needed for smooth logs. Using this logic, log will contain response for each opportunity individually. If not do it, log will contain all application info in every opp-ty log
            GFNI_Logger log = logs.get(opportunity.Id);

            String responseSmoothBody = '[';

            for (Object application : responseObject) {
                if (((Map<String, Object>) application).get('CustomerServiceReferenceId') == opportunity.GFN_Nr__c)
                    responseSmoothBody += JSON.serialize(application);
            }

            responseSmoothBody += ']';

            log.addLog('Response', responseSmoothBody, requestId);
        }

        System.debug('*** UPDATING CARDS ***');

        try {
            if (!cardsToUpdate.isEmpty())
                update cardsToUpdate;
        } catch (Exception e) {
            System.debug('GFNI_ApplicationStatusSchedulable: ' + 'exception on update cardsToUpdate');
            System.debug('GFNI_ApplicationStatusSchedulable: ' + e.getMessage());

            for (Opportunity opportunity : opportunities) {
                GFNI_Logger log = logs.get(opportunity.Id);
                log.addLog('Error', e.getMessage() + ' : ' + e.getCause() + ' : ' + e.getStackTraceString(), requestId);
            }

            GFNI_Logger.saveLogsList(logs.values());

            GFNI_Utils.sendEmail('NCC_' + opportunities.get(0).Account.BillingCountryCode + '_Failure_', 'Message: ' + e.getMessage() + '\n\nCause: ' + e.getCause() + '\n\nStackTrace: ' + e.getStackTraceString() + 'Method: GFNI_Handler.checkCardStatus.update cardsToUpdate \n\n' + '\n\nHave a nice day!', opportunities.get(0).Account.BillingCountryCode);

            return;
        }

        GFNI_Logger.saveLogsList(logs.values());
    }
}