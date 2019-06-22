global class CreditreformReportBatchLU implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful { 
    public String query;
    public transient HttpResponse responseBodyForAttachment;
    public String xmlResponseWithReport;
    public List<Opportunity> opportunitiesToUpdateList;
    public transient List<Messaging.SingleEmailMessage> messages;
    public Map<Id, Credit_Factory_Report__c> crefoReportsMap;
    public Map<Id, List<Credit_Factory_Report_Employee__c>> crefoReportEmployeesMap;
    public List<Attachment> crefoAttachmentsList;


    /*******************************************************************************
    *  Name            : CreditreformMailboxBatch()
    *  Summary         : constructor    
    *  CreatedDate     : 21/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    global CreditreformReportBatchLU() {
        this.query = 'SELECT CF_Order_Reference_Number__c, CF_Stage__c, OwnerId, Name, Account.Gesellschaftsform__c, ' + 
                     'Account.BillingPostalCode, Account.BillingCity, Account.BillingStreet, Account.Steuernummer__c, ' +
                     'Account.Umsatzsteuer_ID__c, Account.HR_Abteilung_HRA_HRB_und_HR_Nummer__c, Account.Gruendungsjahr__c, ' +
                     'Account.Branche_NACE__c, Account.Website, AccountId, ' +
                        '(SELECT Contact.FirstName, Contact.Lastname, Contact.Phone, Contact.Email, Contact.Birthdate, IsPrimary ' + 
                        'FROM OpportunityContactRoles), ' +
                        '(SELECT Id ' + 
                        'FROM Credit_Factory_Reports__r ' +
                        'WHERE CreatedDate > :threeMonthsAgoDate), ' +
                        '(SELECT CreatedDate, Field ' + 
                        'FROM Histories ' + 
                        'ORDER BY CreatedDate DESC) ' +
                     'FROM Opportunity ' +
                     'WHERE CF_Order_Reference_Number__c != null AND StageName = \'Pending Credit Report\' AND ' +
                     'CF_Stage__c != \'Manual Scoring\' AND CF_Stage__c != \'Pending Credit Report - Need information\' AND ' + 
                     'Account.BillingCountry = \'Luxembourg\'';
    }


    /*******************************************************************************
    *  Name            : start(Database.BatchableContext bc)
    *  Summary         : Collect SObjects to pass to the execute method   
    *  CreatedDate     : 21/11/2018
    *  ModifiedDate    : -
    *  Parameters      : Database.BatchableContext bc - object for tracking the progress of the batch job
    *  Returns         : Database.QueryLocator
    ******************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Date threeMonthsAgoDate = Date.today().addMonths(-3);
        return Database.getQueryLocator(query);
    }


    /*******************************************************************************
    *  Name            : execute(Database.BatchableContext BC, List<Opportunity> opportunitiesList)
    *  Summary         : Call this method for each batch of records. Create reports for completed orders
    *  CreatedDate     : 21/11/2018
    *  ModifiedDate    : -
    *  Parameters      : Database.BatchableContext bc - object for tracking the progress of the batch job,
                         List<Opportunity> opportunitiesList - list of Leads or Opportunities to process
    *  Returns         : void
    ******************************************************************************/
    global void execute(Database.BatchableContext BC, List<Opportunity> opportunitiesList) {
        try {
            List<Opportunity> opportunitiesToCheckList = returnOpportunitiesToCheckList(opportunitiesList);
            if (! opportunitiesToCheckList.isEmpty()) {
                this.opportunitiesToUpdateList = new List<Opportunity>();
                this.messages = new List<Messaging.SingleEmailMessage>();
                this.crefoReportsMap = new Map<Id, Credit_Factory_Report__c>();
                this.crefoReportEmployeesMap = new Map<Id, List<Credit_Factory_Report_Employee__c>>();
                this.crefoAttachmentsList = new List<Attachment>();
                for (Opportunity opportunity : opportunitiesToCheckList) {
                    if (isOpportuintyOld(opportunity) == true) {
                        processOldOpportunity(opportunity);
                        break;
                    }

                    CreditSystemService creditSystem = new CreditSystemService();
                    creditSystem.setCreditSystemSource(opportunity.Id);
                    Dom.XMLNode mailboxDirectoryBody = checkMailboxDirectory(creditSystem, opportunity);
                    if (mailboxDirectoryBody != null) {
                        String mailboxEntryNumber;
                        String identificationNumber;
                        String orderStatus;
                        for (Dom.XMLNode field : mailboxDirectoryBody.getChildElements()) {
                            if (field.getName() == 'entry') {
                                mailboxEntryNumber = CreditReformWebserviceLU.returnMailboxEntryNumber(field);
                                identificationNumber = CreditReformWebserviceLU.returnIdentificationNumber(field);
                                orderStatus = CreditReformWebserviceLU.returnOrderStatus(field);
                            }
                        }

                        if (mailboxEntryNumber != null && (orderStatus == 'ORST-1' || orderStatus == 'ORST-2')) {
                            Dom.XMLNode mailboxEntryBody = checkMailboxEntry(creditSystem, mailboxEntryNumber);
                            if (mailboxEntryBody != null) {
                                String reportStatus = CreditReformWebserviceLU.returnReportStatus(mailboxEntryBody);
                                for (Dom.XMLNode field : mailboxEntryBody.getChildElements()) {
                                    if (field.getName() == 'report') {
                                        Boolean negativeReport = Boolean.valueOf(CreditReformWebserviceLU.returnNegativeReport(field));
                                        if (reportStatus == 'DLTY-2' && negativeReport == true) {
                                            processUnavailableReportLogic(opportunity);
                                        } else if (reportStatus == 'DLTY-3'){
                                            processInformationRequiredLogic(opportunity);
                                        } else {
                                            processAvailableReportLogic(field, identificationNumber, opportunity);
                                        }

                                        break;
                                    }
                                }
                            }   
                        }
                    }
                }

                doBulkOperations();
            }
        } catch (Exception e) {
            ExceptionLogger.sendException(String.valueOf(e.getMessage()), String.valueOf(e.getStackTraceString()));
        }
    }


    /*******************************************************************************
    *  Name            : returnOpportunitiesToCheckList(List<Opportunity> opportunitiesList)
    *  Summary         : Return list of waiting for report opportunities    
    *  CreatedDate     : 21/11/2018
    *  ModifiedDate    : -
    *  Parameters      : List<Opportunity> opportunitiesList
    *  Returns         : List<Opportunity>
    ******************************************************************************/
    public List<Opportunity> returnOpportunitiesToCheckList(List<Opportunity> opportunitiesList) {
        List<Opportunity> opportunitiesToCheckList = new List<Opportunity>();
        for (Opportunity opportunity : opportunitiesList) {
            if (opportunity.Credit_Factory_Reports__r.size() == 0) {
                opportunitiesToCheckList.add(opportunity);
            }
        }

        return opportunitiesToCheckList;
    }


    /*******************************************************************************
    *  Name            : isOpportuintyOld()
    *  Summary         : Check last change of Stage  
    *  CreatedDate     : 21/11/2018
    *  ModifiedDate    : -
    *  Parameters      : Opportunity opportunity - opportunity to check last change of Stage
    *  Returns         : Boolean
    ******************************************************************************/
    public Boolean isOpportuintyOld(Opportunity opportunity) {
        for (OpportunityFieldHistory history : opportunity.Histories) {
            if (history.Field == 'StageName' && history.CreatedDate < Date.today().addDays(-28)) {
                return true;
            }
        }

        return false;
    }


    /*******************************************************************************
    *  Name            : processOldOpportunity(Opportunity opportunity)
    *  Summary         : Process logic if opportunity is old.    
    *  CreatedDate     : 21/11/2018
    *  ModifiedDate    : -
    *  Parameters      : Opportunity opportunity
    *  Returns         : void
    ******************************************************************************/
    public void processOldOpportunity(Opportunity opportunity) {
        opportunity.StageName = 'Closed Lost';
        opportunity.Gruende_verloren__c = 'Credit Report not available';
        this.opportunitiesToUpdateList.add(opportunity);
        this.messages.add(prepareUnavailableReportEmail(opportunity));
    }


    /*******************************************************************************
    *  Name            : checkMailboxDirectory(CreditSystemService creditSystem)
    *  Summary         : request mailbox directory and available mailbox entries 
    *  CreatedDate     : 21/11/2018
    *  ModifiedDate    : -
    *  Parameters      : CreditSystem - credit system object with Creditreform credentials,
                         Opportunity opportunity - opportunity to check
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public Dom.XMLNode checkMailboxDirectory(CreditSystemService creditSystem, Opportunity opportunity) {
        HttpRequest request = CreditReformWebserviceLU.generateMailboxDirectoryRequest(creditSystem.getEndpointUrl(),
                creditSystem.getUserName(), creditSystem.getUserPassword(), creditSystem.getApiKey(),
                opportunity.CF_Order_Reference_Number__c);
        Http http = new Http();
        HttpResponse response;
        response = http.send(request);
        String xmlResponse = response.getBody();
        System.debug('DEBUG: MAILBOX DIRECTORY === ' + xmlResponse);
        xmlResponse = CreditReformWebserviceLU.clearSearchXML(xmlResponse);
        Dom.Document domDoc = new Dom.Document();
        domDoc.load(xmlResponse);
        Dom.XMLNode xmldom = domDoc.getRootElement();
        Dom.XMLNode globalBody = CreditReformWebserviceLU.returnGlobalBody(xmldom);
        Dom.XMLNode innerBody = CreditReformWebserviceLU.returnInnerBody(globalBody);
        return innerBody;
    }


    /*******************************************************************************
    *  Name            : checkMailboxEntry(CreditSystemService creditSystem, String mailboxEntryNumber)
    *  Summary         : request mailbox entry and get report from reponse and create it   
    *  CreatedDate     : 21/11/2018
    *  ModifiedDate    : -
    *  Parameters      : CreditSystem - credit system object with Creditreform credentials,
                         String mailboxEntryNumber - number of checked mailbox entry
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public Dom.XMLNode checkMailboxEntry(CreditSystemService creditSystem, String mailboxEntryNumber) {
        HttpRequest request = CreditReformWebserviceLU.generateMailboxEntryRequest(creditSystem.getEndpointUrl(),
                creditSystem.getUserName(), creditSystem.getUserPassword(), creditSystem.getApiKey(), mailboxEntryNumber);
        Http http = new Http();
        HttpResponse response;
        response = http.send(request);
        this.responseBodyForAttachment = response;
        String xmlResponse = response.getBody();
        this.xmlResponseWithReport = xmlResponse;
        System.debug('DEBUG: MAILBOX ENTRY === ' + xmlResponse);
        xmlResponse = CreditReformWebserviceLU.clearSearchXML(xmlResponse);
        Dom.Document domDoc = new Dom.Document();
        domDoc.load(xmlResponse);
        Dom.XMLNode xmldom = domDoc.getRootElement();
        Dom.XMLNode globalBody = CreditReformWebserviceLU.returnGlobalBody(xmldom);
        Dom.XMLNode innerBody = CreditReformWebserviceLU.returnInnerBody(globalBody);
        return innerBody;
    }


    /*******************************************************************************
    *  Name            : processUnavailableReportLogic(Opportunity opportunity)
    *  Summary         : Process logic if report is unavailable.    
    *  CreatedDate     : 21/11/2018
    *  ModifiedDate    : -
    *  Parameters      : Opportunity opportunity - opportunity to process.
    *  Returns         : void
    ******************************************************************************/
    public void processUnavailableReportLogic(Opportunity opportunity) {
        // prepare opportuinty to close as lost
        opportunity.StageName = 'Closed Lost';
        opportunity.Gruende_verloren__c = 'Credit Report not available';
        this.opportunitiesToUpdateList.add(opportunity);
        //send email to owner
        this.messages.add(prepareUnavailableReportEmail(opportunity));
    }


    /*******************************************************************************
    *  Name            : processInformationRequiredLogic(Opportunity opportunity)
    *  Summary         : Process logic if additional information required to identify report.
    *  CreatedDate     : 21/11/2018
    *  ModifiedDate    : -
    *  Parameters      : Opportuinty opportunity - opportunity to process
    *  Returns         : void
    ******************************************************************************/
    public void processInformationRequiredLogic(Opportunity opportunity) {
        // send order with addition information
        CreditSystemService creditService = new CreditSystemService();
        creditService.setCreditSystemSource(opportunity.Id);
        OrderCreditreformServiceLU order = new OrderCreditreformServiceLU();
        order.doOrder(creditService, opportunity, '', null);
        // send email to owner
        this.messages.add(prepareNeedInformationEmail(opportunity, order.orderSpecifyingText));
    }


    /*******************************************************************************
    *  Name            : processAvailableReportLogic(Dom.XMLNode reportBody, String id, Opportunity opportunity)
    *  Summary         : Process logic if report is available.    
    *  CreatedDate     : 21/11/2018
    *  ModifiedDate    : -
    *  Parameters      : (Dom.XMLNode reportBody - report xml body, String id - company identification number, 
                         Opportunity opportunity - opportunity to process
    *  Returns         : void
    ******************************************************************************/
    public void processAvailableReportLogic(Dom.XMLNode reportBody, String id, Opportunity opportunity) {
        if (id != null) {
            // set company and employess
            CreditCompany company = CreditReformWebserviceLU.returnReportCompany(reportBody, id);
            List<CreditCompanyEmployee> companyEmployeesList = CreditReformWebserviceLU.returnEmployees(reportBody);
            // prepare credit report, employees and pdf attachment to insert
            Credit_Factory_Report__c creditReportToInsert = prepareCreditReport(company, opportunity.Id);
            this.crefoReportsMap.put(opportunity.Id, creditReportToInsert);
            List<Credit_Factory_Report_Employee__c> creditReportEmployeesList = prepareCreditReportEmployess(companyEmployeesList);
            this.crefoReportEmployeesMap.put(opportunity.Id, creditReportEmployeesList);
            Attachment attachment = prepareCreditReportAttachment(opportunity.Id);
            if (attachment != null) {
                this.crefoAttachmentsList.add(attachment);
            }
            // update opportunity
            opportunity.Credit_Factory_PDF_Report_Created__c = true;
            opportunity.StageName = 'Credit Report Generated';
            opportunity.CF_Stage__c = 'Credit Report Generated';
            this.opportunitiesToUpdateList.add(opportunity);
            // send email to owner
            this.messages.add(prepareAvailableReportEmail(opportunity));
        }
    }


    /*******************************************************************************
    *  Name            : prepareCreditReport()
    *  Summary         : prepare credit report to insert     
    *  CreatedDate     : 21/11/2018
    *  ModifiedDate    : 08/01/2019
    *  Parameters      : CreditCompany company - company from response, String opportunityId - Id of processed opportunity
    *  Returns         : void
    ******************************************************************************/
    public Credit_Factory_Report__c prepareCreditReport(CreditCompany company, String opportunityId) {
        String reportName = company.name;
        if (reportName.length() > 80) {
            reportName = reportName.substring(0,80);
        }
        Credit_Factory_Report__c creditReport = new Credit_Factory_Report__c(
            Credit_System_Number__c = company.creditSystemCompanyNumber,
            Age_of_Company__c = company.ageofcompany,
            City__c = company.city,
            Company_Status__c = company.status,
            Country__c = company.country,
            County_Court__c = company.countyCourt,
            Credit_Decision__c = company.creditDecision,
            Credit_Limit__c = company.creditLimit,
            Date_Last_Register_Entry__c = company.datelastregisterentry,
            Date_Legal_Form__c = company.datelegalform,
            Date_of_Foundation__c = company.dateoffoundation,
            Email__c = company.email,
            Fax__c = company.fax,
            First_Legal_Form__c = company.firstlegalform,
            Fiscal_Number__c = company.taxnumber,
            Housenumber__c = company.housenumber,
            Legal_Form__c = company.legalform,
            Mobile__c = company.mobile,
            Opportunity__c = opportunityId,
            Order_Situation__c = company.orderSituation,
            Payment_Behaviour__c = company.paymentBehaviour,
            Phone__c = company.phone,
            Postcode__c = company.postcode,
            Reference_Number__c = company.referencenumber,
            Register_Number__c = company.registerNumber,
            Staff_Range__c = company.staffcompanyrange,
            Street__c = company.street,
            Trade_Name__c = company.tradename,
            Turn_Over__c = company.turnOver,
            VAT_Number__c = company.vatid,
            Tax_Id__c = company.taxnumber,
            Website__c = company.website,
            Company_Id__c = company.identificationnumber,
            Class_Rating__c = company.classRating,
            Solvency_Index__c = company.solvencyIndex,
            Name = reportName,
            Name__c = company.name);
        return creditReport;
    }


    /*******************************************************************************
    *  Name            : prepareCreditReportEmployess()
    *  Summary         : prepare list of credit report employees to insert    
    *  CreatedDate     : 21/11/2018
    *  ModifiedDate    : -
    *  Parameters      : List<CreditCompanyEmployee> companyEmployeesList - company employess from response
    *  Returns         : Credit_Factory_Report_Employee__c
    ******************************************************************************/
    public List<Credit_Factory_Report_Employee__c> prepareCreditReportEmployess(List<CreditCompanyEmployee> companyEmployeesList) {
        List<Credit_Factory_Report_Employee__c> creditReportEmployeesList = new List<Credit_Factory_Report_Employee__c>();
        for (CreditCompanyEmployee employee : companyEmployeesList) {
            String employeeName = employee.ename;
            if (employeeName != null && employeeName.length() > 80) {
                employeeName = employeeName.substring(0,80);
            }
            creditReportEmployeesList.add(new Credit_Factory_Report_Employee__c(
                Address__c = employee.address,
                Date_of_Birth__c = employee.dateofbirth,
                Id__c = employee.enumber,
                Name = employeeName,
                Participation_Date__c = employee.participationdate,
                Type__c = employee.type));
        }
        return creditReportEmployeesList;
    }


    /*******************************************************************************
    *  Name            : prepareAvailableReportEmail(Opportunity opportunity)
    *  Summary         : prepare email to send for sales if report is available
    *  CreatedDate     : 21/11/2018
    *  ModifiedDate    : -
    *  Parameters      : Opportunity opportunity - processed Opportunity 
    *  Returns         : Messaging.SingleEmailMessage
    ******************************************************************************/
    public Messaging.SingleEmailMessage prepareAvailableReportEmail(Opportunity opportunity) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setTargetObjectId(opportunity.ownerId);
        message.subject = 'Credit Factory Report is created.';
        message.setSenderDisplayName('Salesforce Notification');
        message.htmlBody = 'Credit Factory Report is created.<br/><br/>Please launch Credit Factory again: <a href="' + 
            URL.getSalesforceBaseUrl().toExternalForm() + '/' + opportunity.Id + '"> ' + opportunity.Name + '</a><br/><br/>' + 
            'This is an automatically generated e-mail, please do not respond.';
        message.saveAsActivity = false;
        return message;
    }


    /*******************************************************************************
    *  Name            : prepareUnavailableReportEmail(Opportunity opportunity)
    *  Summary         : prepare email to send for sales if report is not available
    *  CreatedDate     : 21/11/2018
    *  ModifiedDate    : -
    *  Parameters      : Opportunity opportunity - processed Opportunity 
    *  Returns         : Messaging.SingleEmailMessage
    ******************************************************************************/
    public Messaging.SingleEmailMessage prepareUnavailableReportEmail(Opportunity opportunity) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setTargetObjectId(opportunity.ownerId);
        message.subject = 'Credit Factory Report cannot be created.';
        message.setSenderDisplayName('Salesforce Notification');
        message.htmlBody = 'Credit Factory Report can not be created.<br/><br/>Opportunity is closed as Lost: <a href="' + 
            URL.getSalesforceBaseUrl().toExternalForm() + '/' + opportunity.Id + '"> ' + opportunity.Name + '</a><br/><br/>' +
            'This is an automatically generated e-mail, please do not respond.';
        message.saveAsActivity = false;
        return message;
    }


    /*******************************************************************************
    *  Name            : prepareNeedInformationEmail(Opportunity opportunity)
    *  Summary         : prepare email to send for sales order researcher needs more information
    *  CreatedDate     : 21/11/2018
    *  ModifiedDate    : -
    *  Parameters      : Opportunity opportunity - processed Opportunity, 
                         String additionalInformation - information from researcher
    *  Returns         : Messaging.SingleEmailMessage
    ******************************************************************************/
    public Messaging.SingleEmailMessage prepareNeedInformationEmail(Opportunity opportunity, String additionalInformation) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setTargetObjectId(opportunity.ownerId);
        message.subject = 'Additional information for Credit Factory Report was sent.';
        message.setSenderDisplayName('Salesforce Notification');
        message.htmlBody = 'Additional information for Credit Factory Report was sent:<br/><br/>' 
            + additionalInformation.replace('\n', '</br>').removeEnd('</br>') + 
            '<br/><br/>You will receive a notification when a new report is generated for your customer. ' + 
            'If it is not possible to generate a new report the Opportunity will be closed as Lost automatically.' +
            '<br/><br/>Opportunity: <a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + opportunity.Id + '"> ' + opportunity.Name + '</a><br/><br/>' + 
            'This is an automatically generated e-mail, please do not respond.';
        message.saveAsActivity = false;
        return message;
    }


    /*******************************************************************************
    *  Name            : prepareCreditReportAttachment(Opportunity opportunity)
    *  Summary         : prepare Credit Company Report PDF Attachment to insert
    *  CreatedDate     : 21/11/2018
    *  ModifiedDate    : -
    *  Parameters      : String opportunityId - processed Opportunity
    *  Returns         : Attachment
    ******************************************************************************/
    public Attachment prepareCreditReportAttachment(String opportunityId) {
        Blob blobBody = this.responseBodyForAttachment.getBodyAsBlob();
        String blobBodyHex = EncodingUtil.convertToHex(blobBody);
        String blobPdfHex = blobBodyHex.substringBetween('25504446','2525454f46');
        Blob blobPdf;
        if (blobPdfHex != null) {
            blobPdfHex = '25504446' + blobPdfHex + '2525454f46';
            blobPdf = EncodingUtil.convertFromHex(blobPdfHex);
        }
        if (blobPdf != null) {
            Attachment creforeport = new Attachment(
                ParentId = opportunityId,
                Name = 'CrefoReport.pdf',
                Body = blobPdf);
            return creforeport; 
        }

        return null;
    }


    /*******************************************************************************
    *  Name            : doBulkOperations()
    *  Summary         : Do bulk inserts, updates, send emails.    
    *  CreatedDate     : 21/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doBulkOperations() {
        if (! this.crefoReportsMap.isEmpty()) {
            insert this.crefoReportsMap.values();
            List<Credit_Factory_Report_Employee__c> crefoReportEmployeesListToInsert = new List<Credit_Factory_Report_Employee__c>();
            for (Id opportunityId : this.crefoReportsMap.keySet()) {
                for (Credit_Factory_Report_Employee__c employee : this.crefoReportEmployeesMap.get(opportunityId)) {
                    employee.Credit_Factory_Report__c = this.crefoReportsMap.get(opportunityId).Id;
                    crefoReportEmployeesListToInsert.add(employee);
                }
            }

            if (! crefoReportEmployeesListToInsert.isEmpty()) {
                insert crefoReportEmployeesListToInsert;
            }
        }

        if (! this.crefoAttachmentsList.isEmpty()) {
            insert this.crefoAttachmentsList;
        }

        if (! this.opportunitiesToUpdateList.isEmpty()) {
            update this.opportunitiesToUpdateList;
        }

        if (! this.messages.isEmpty()) {
            Messaging.sendEmail(this.messages);
        }
    }


    global void finish(Database.BatchableContext BC) {}
}