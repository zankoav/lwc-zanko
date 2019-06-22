/**
 * Created by Nikita.Mikhailov on 17.01.2019.
 */
public with sharing class GFNI_Utils {
    private static final Map<String, GFNI_General_Settings__c> gfni_general_settings = GFNI_General_Settings__c.getAll();
    private static final StaticResource mappingStaticResource = [SELECT Id, Body FROM StaticResource WHERE Name = 'GFNI_Mapping' LIMIT 1];
    private static final OrgWideEmailAddress[] orgEmails = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'no-reply@fleetcor.eu'];

    public static final Map<String, Object> gfniMapping {
        get {
            return (Map<String, Object>) JSON.deserializeUntyped(GFNI_Utils.mappingStaticResource.Body.toString());
        }
        private set;
    }

    /*******************************************************************************
    *  Name            : getStringValue
    *  Summary         : Retrieves String value from GFNI mapping
    *  CreatedDate     : 17/01/2019
    *  Parameters      : Object fieldValueToGet, Schema.DescribeFieldResult fieldDescribe, String mappingToFind
    *  Returns         : String
    ******************************************************************************/
    public static String getStringValue(Object fieldValueToGet, Schema.DescribeFieldResult fieldDescribe, String mappingToFind) {
        if (fieldValueToGet == null)
            return GlobalUtils.blankStringIfNull(String.valueOf(fieldValueToGet));

        return String.valueOf(((Map<String, Object>) GlobalUtils.getValueUntypedFromJSON(GFNI_Utils.gfniMapping, mappingToFind)).get((GlobalUtils.blankStringIfNull(GlobalUtils.getPicklistValueTranslation(fieldDescribe, String.valueOf(fieldValueToGet))))));
    }

    /*******************************************************************************
    *  Name            : getStringValue
    *  Summary         : Retrieves String value from provided JSON
    *  CreatedDate     : 17/01/2019
    *  Parameters      : Object fieldValueToGet, Schema.DescribeFieldResult fieldDescribe, String mappingToFind
    *  Returns         : String
    ******************************************************************************/
    public static String getStringValue(String json, String keyValueToFind) {
        if (json == null || keyValueToFind == null) {
            return null;
        }

        return String.valueOf(GlobalUtils.getValueUntypedFromJSON((Map<String, Object>) System.JSON.deserializeUntyped(json), keyValueToFind));
    }

    /*******************************************************************************
    *  Name            : getIntegerValue
    *  Summary         : Retrieves Integer value from provided GFNI mapping
    *  CreatedDate     : 17/01/2019
    *  Parameters      : Object fieldValueToGet, Schema.DescribeFieldResult fieldDescribe, String mappingToFind
    *  Returns         : String
    ******************************************************************************/
    public static Integer getIntegerValue(Object fieldValueToGet, Schema.DescribeFieldResult fieldDescribe, String mappingToFind) {
        if (fieldValueToGet == null)
            return null;

        if (fieldDescribe == null) {
            return Integer.valueOf(((Map<String, Object>) GlobalUtils.getValueUntypedFromJSON(GFNI_Utils.gfniMapping, mappingToFind)).get(String.valueOf(fieldValueToGet)));
        } else {
            return Integer.valueOf(((Map<String, Object>) GlobalUtils.getValueUntypedFromJSON(GFNI_Utils.gfniMapping, mappingToFind)).get((GlobalUtils.blankStringIfNull(GlobalUtils.getPicklistValueTranslation(fieldDescribe, String.valueOf(fieldValueToGet))))));
        }
    }

    /*******************************************************************************
    *  Name            : getGeneralSettings
    *  Summary         : Retrieves Integer setting from GFNI_General_Settings__c defined by key
    *  CreatedDate     : 17/01/2019
    *  Parameters      : String key
    *  Returns         : GFNI_General_Settings__c
    ******************************************************************************/
    public static GFNI_General_Settings__c getGeneralSettings(String key) {
        return GFNI_Utils.gfni_general_settings.get(key);
    }

    /*******************************************************************************
    *  Name            : getIdType
    *  Summary         : Defines type of input line
    *  CreatedDate     : 17/01/2019
    *  Parameters      : String checkingLine
    *  Returns         : String
    ******************************************************************************/
    public static String getIdType(String checkingLine) {
        String Account_Nr_regEx = 'FC-[0-9]{9}';
        String GFN_Nr_regEx = '[A-Z]{2}[0-9]{8}';

        if (checkingLine instanceof Id) {
            return 'SF';
        }

        if (Pattern.matches(Account_Nr_regEx, checkingLine)) {
            return 'Account_Nr';
        }

        if (Pattern.matches(GFN_Nr_regEx, checkingLine)) {
            return 'GFN_Nr';
        }

        return null;
    }

    /*******************************************************************************
    *  Name            : replaceSpecialCharacters
    *  Summary         : Replaces special characters using keys and values from GFNI Mapping
    *  CreatedDate     : 17/01/2019
    *  Parameters      : String input
    *  Returns         : String
    ******************************************************************************/
    public static String replaceSpecialCharacters(String input) {
        if (input == null)
            return null;

        input = input.replaceAll('(\\pS|\\pP)', '');

        Map<String, Object> specialCharactersMapping = (Map<String, Object>) GFNI_Utils.gfniMapping.get('SpecialCharacters');
        String output = '';
        Integer i = 0;
        do {
            if (i < input.length()) {
                if (specialCharactersMapping.containsKey(input.substring(i, i + 1))) {
                    output += specialCharactersMapping.get(input.substring(i, i + 1));
                } else {
                    output += input.substring(i, i + 1);
                }
            }
            i = i + 1;
        } while (i < input.length());

        output = output.replaceAll('\\s+', ' ');

        return output;
    }

    /*******************************************************************************
    *  Name            : returnCorrectPhoneNumber
    *  Summary         : Returns phone number in correct format defined by country
    *  CreatedDate     : 17/01/2019
    *  Parameters      : String input, String countryCode
    *  Returns         : String
    ******************************************************************************/
    public static String returnCorrectPhoneNumber(String input, String countryCode) {
        if (input == null)
            return null;

        String result = input.replaceAll('(\\D+|^0+)', '');

        Map<String, Object> phoneCodesMapping = (Map<String, Object>) GFNI_Utils.gfniMapping.get('PhoneCodes');
        String currentPhoneCode = String.valueOf(phoneCodesMapping.get(countryCode));
        if (result.startsWith(currentPhoneCode.replaceAll('^0+', ''))) {
            result = currentPhoneCode.substring(0, 3) + result;
        } else if (!result.startsWith(currentPhoneCode)) {
            result = currentPhoneCode + result;
        }

        return result;
    }

    /*******************************************************************************
    *  Name            : isProductionOrg
    *  Summary         : Returns true or false in case of production or sandbox environment
    *  CreatedDate     : 17/01/2019
    *  Parameters      : -
    *  Returns         : Boolean
    ******************************************************************************/
    public static Boolean isProductionOrg() { // Method to check of environment is Production ORG or not
        Organization org = [SELECT IsSandbox FROM Organization WHERE Id = :UserInfo.getOrganizationId()];
        return (org.IsSandbox == true) ? false : true;
    }

    /*******************************************************************************
    *  Name            : sendEmail
    *  Summary         : Generates and sends e-mail without attachment for support team defined by country in custom setting
    *  CreatedDate     : 17/01/2019
    *  Parameters      : String subject, String emailBody, String countryCode
    *  Returns         : -
    ******************************************************************************/
    public static void sendEmail(String subject, String emailBody, String countryCode) {
        //OrgWideEmailAddress[] orgEmails = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'no-reply@fleetcor.eu'];

        Messaging.SingleEmailMessage mail = null;

        if (GFNI_Utils.gfni_general_settings.get(countryCode).Test_mode__c) {
            mail = EmailGenerator.sendHtmlEmailWithoutAttachment(GFNI_Utils.gfni_general_settings.get(countryCode).Test_support_email__c.split(';'), GFNI_Utils.orgEmails, subject, emailBody);
        } else {
            mail = EmailGenerator.sendHtmlEmailWithoutAttachment(GFNI_Utils.gfni_general_settings.get(countryCode).Support_email__c.split(';'), GFNI_Utils.orgEmails, subject, emailBody);
        }

        sendEmail(mail);
    }

    /*******************************************************************************
    *  Name            : sendEmail
    *  Summary         : Generates and sends e-mail with attachment for support team defined by country in custom setting
    *  CreatedDate     : 17/01/2019
    *  Parameters      : String subject, String emailBody, String countryCode, Messaging.EmailFileAttachment attachment
    *  Returns         : -
    ******************************************************************************/
    public static void sendEmail(String subject, String emailBody, String countryCode, Messaging.EmailFileAttachment attachment) {
        //OrgWideEmailAddress[] orgEmails = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'no-reply@fleetcor.eu'];

        Messaging.SingleEmailMessage mail = null;

        if (GFNI_Utils.gfni_general_settings.get(countryCode).Test_mode__c) {
            mail = EmailGenerator.sendHtmlEmailWithAttachment(GFNI_Utils.gfni_general_settings.get(countryCode).Test_support_email__c.split(';'), GFNI_Utils.orgEmails, subject, emailBody, attachment);
        } else {
            mail = EmailGenerator.sendHtmlEmailWithAttachment(GFNI_Utils.gfni_general_settings.get(countryCode).Support_email__c.split(';'), GFNI_Utils.orgEmails, subject, emailBody, attachment);
        }

        sendEmail(mail);
    }

    /*******************************************************************************
    *  Name            : sendEmail
    *  Summary         : Generates and sends e-mail without attachment for provided list of emails
    *  CreatedDate     : 17/01/2019
    *  Parameters      : String subject, String emailBody, String[] emailAddresses
    *  Returns         : -
    ******************************************************************************/
//    public static void sendEmail(String subject, String emailBody, String[] emailAddresses) {
//        OrgWideEmailAddress[] orgEmails = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'no-reply@fleetcor.eu'];
//
//        Messaging.SingleEmailMessage mail = EmailGenerator.sendHtmlEmailWithoutAttachment(emailAddresses, this.orgEmails, subject, emailBody);
//
//        sendEmail(mail);
//    }

    /*******************************************************************************
    *  Name            : sendEmail
    *  Summary         : Generates and sends e-mail with attachment for provided list of emails
    *  CreatedDate     : 17/01/2019
    *  Parameters      : String subject, String emailBody, String[] emailAddresses, Messaging.EmailFileAttachment attachment
    *  Returns         : -
    ******************************************************************************/
    public static void sendEmail(String subject, String emailBody, String[] emailAddresses, Messaging.EmailFileAttachment attachment) {
        //OrgWideEmailAddress[] orgEmails = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'no-reply@fleetcor.eu'];

        Messaging.SingleEmailMessage mail = EmailGenerator.sendHtmlEmailWithAttachment(emailAddresses, GFNI_Utils.orgEmails, subject, emailBody, attachment);

        sendEmail(mail);
    }

    /*******************************************************************************
    *  Name            : sendEmail
    *  Summary         : Generates and sends e-mail with attachment for provided list of emails and with send logging in SF
    *  CreatedDate     : 17/01/2019
    *  Parameters      : String subject, String emailBody, String[] emailAddresses, Messaging.EmailFileAttachment attachment, AccountGfnReportSendingLog gfnReportSendingLog
    *  Returns         : -
    ******************************************************************************/
    public static void sendEmail(String subject, String emailBody, String[] emailAddresses, Messaging.EmailFileAttachment attachment, AccountGfnReportSendingLog gfnReportSendingLog) {
        //OrgWideEmailAddress[] orgEmails = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'no-reply@fleetcor.eu'];

        Messaging.SingleEmailMessage mail = EmailGenerator.sendHtmlEmailWithAttachment(emailAddresses, GFNI_Utils.orgEmails, subject, emailBody, attachment);

        sendEmail(mail, gfnReportSendingLog);
    }

    /*******************************************************************************
    *  Name            : sendEmail
    *  Summary         : Sends e-mail without logging
    *  CreatedDate     : 17/01/2019
    *  Parameters      : Messaging.SingleEmailMessage mail
    *  Returns         : -
    ******************************************************************************/
    private static void sendEmail(Messaging.SingleEmailMessage mail) {
        if (!Test.isRunningTest()) {
            try {
                Messaging.SendEmailResult[] results = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{
                        mail
                });
                if (results[0].isSuccess()) {
                    System.debug('Email send Success: ' + results[0].isSuccess());
                } else {
                    System.debug('Email send Failed: ' + results[0].isSuccess());
                }
            } catch (Exception e) {
                System.debug('Exception - GFNI_Utils.sendEmail: ' + e);
                ExceptionLogger.sendException(e.getMessage(), String.valueOf(e.getStackTraceString()));
            }
        } else {
            System.debug('this is test case');
        }
    }

    /*******************************************************************************
    *  Name            : sendEmail
    *  Summary         : Sends e-mail with logging
    *  CreatedDate     : 17/01/2019
    *  Parameters      : Messaging.SingleEmailMessage mail, AccountGfnReportSendingLog accountGfnReportSendingLogs
    *  Returns         : -
    ******************************************************************************/
    private static void sendEmail(Messaging.SingleEmailMessage mail, AccountGfnReportSendingLog accountGfnReportSendingLogs) {
        if (!Test.isRunningTest()) {
            try {
                Messaging.SendEmailResult[] results = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{
                        mail
                });
                if (results[0].isSuccess()) {
                    createMailingLog(accountGfnReportSendingLogs, 'Success');
                    System.debug('Email send Success: ' + results[0].isSuccess());
                } else {
                    createMailingLog(accountGfnReportSendingLogs, 'Failed');
                    System.debug('Email send Failed: ' + results[0].isSuccess());
                }
            } catch (Exception e) {
                createMailingLog(accountGfnReportSendingLogs, 'Failed');
                System.debug('Exception - GFNI_Utils.sendEmail: ' + e);
                ExceptionLogger.sendException(e.getMessage(), String.valueOf(e.getStackTraceString()));
            }
        } else {
            createMailingLog(accountGfnReportSendingLogs, 'Success');
            System.debug('this is test case');
        }
    }

    /*******************************************************************************
    *  Name            : createMailingLog
    *  Summary         : create mailing log
    *  CreatedDate     : 28.11.2018
    *  Parameters      : AccountGfnReportSendingLog sendingLogs, String status
    *  Returns         : void
    ******************************************************************************/
    private static void createMailingLog(AccountGfnReportSendingLog sendingLog, String status) {
        Mailing_Account_GFN_Report_Log__c log = new Mailing_Account_GFN_Report_Log__c(
                Account__c = sendingLog.accountId,
                Opportunity__c = sendingLog.opportunityId,
                Starts_Status_Changed_By__c = sendingLog.userId,
                Address__c = sendingLog.address,
                File_Name__c = sendingLog.fileName,
                Sending_Status__c = status);

        insert log;
    }

    //deduplication logic with API usage
//    public static Boolean isExistingCustomer(Id opportunityId) {
//
//        Opportunity opportunity = [
//                SELECT Id, Account.Account_Nr__c, Account.Name, Account.Umsatzsteuer_ID__c, Account.BillingCountryCode, Account.GFN_Nr__c,
//                        Account.BillingCountry, Account.Owner.Name, (SELECT Id, Contact.Email FROM OpportunityContactRoles WHERE IsPrimary = true LIMIT 1)
//                FROM Opportunity
//                WHERE Id = :opportunityId
//        ];
//
//        if(opportunity.Account.GFN_Nr__c != null) {
//            return true;//definitely double
//        }
//
//        System.debug('GFNI_Handler: ' + '*** PREPARE DEDUPLICATION REQUEST FOR GFN ***');
//        String body = GFNI_RequestBuilder.buildJSONGetCustomerId(opportunity);
//        System.debug(body);
//        String requestId = GFNI_Utils.getStringValue(body, 'RequestID');
//        System.debug('GFNI_Handler: ' + '*** SENDING GET CUSTOMER ID REQUEST ***');
//
//
//        HttpResponse response = GFNI_RequestHandler.sendRequest(body, GFNI_Utils.getGeneralSettings(opportunity.Account.BillingCountryCode).Get_Customer_Id__c, opportunity.Account.BillingCountryCode);
//
//        //if everything is fine, check if double or not
//
////        if(GFNI_Utils.getStringValue(response.getBody(), 'CustomerServiceReferenceId') != null) {
////
////        }
//
//        return null;
//    }

    //Address line splitter
//    /*******************************************************************************
//*  Name            : splitStringByNumberOfLines()
//*  Summary         : splits input string to the List<String> defined by size of that list (ex. split address line to line1, line2, line3). Word bt word
//*  CreatedDate     : 25/01/2019
//*  Parameters      : List<String> input string, Integer number of lines, Integer length of line
//*  Returns         : List<String> with defined size and filled with words from input string
//******************************************************************************/
//    public static List<String> splitStringByNumberOfLines(String inputString, Integer numberOfLines, Integer lengthOfLine) {
//        List<String> split = inputString.split('\\s+');
//
//        List<String> lines = new List<String>();
//        for (Integer i = 0; i < numberOfLines; i++) {
//            lines.add('');
//        }
//        Integer i = 0;
//
//        for (String line : split) {
//            i = splitStringByNumberOfLinesReq(lines, i, line, numberOfLines, lengthOfLine);
//            if (i > numberOfLines - 1)
//                return lines;
//        }
//
//        return lines;
//    }

//    /*******************************************************************************
//*  Name            : splitStringByNumberOfLinesReq()
//*  Summary         : recursion of splitStringByNumberOfLines()
//*  CreatedDate     : 25/01/2019
//*  Parameters      : List<String> lines, Integer current index, String current line, Integer number of lines, Integer length of line
//*  Returns         : List<String> with defined size and filled with words from input string
//******************************************************************************/
//    private static Integer splitStringByNumberOfLinesReq(List<String> lines, Integer i, String line, Integer numberOfLines, Integer lengthOfLine) {
//        if (i > numberOfLines - 1) {
//            return i;
//        }
//
//        if ((lines.get(i) + ' ' + line).length() > lengthOfLine) {
//            return splitStringByNumberOfLinesReq(lines, i += 1, line, numberOfLines, lengthOfLine);
//        } else {
//            lines.set(i, (lines.get(i) + ' ' + line).trim());
//            return i;
//        }
//    }
}