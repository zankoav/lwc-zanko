global class CofaceMailboxBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    public String query;

    global CofaceMailboxBatch() {
        this.query = 'SELECT CF_Order_Reference_Number__c, CF_Order_Party_Id__c, OwnerId, Name, Owner.Email, ' +
                            '(SELECT Id ' + 
                            'FROM Credit_Factory_Reports__r ' +
                            'WHERE CreatedDate > :threeMonthsAgoDate), ' +
                            '(SELECT CreatedDate, Field ' + 
                            'FROM Histories ' + 
                            'ORDER BY CreatedDate DESC) ' +
                     'FROM Opportunity ' +
                     'WHERE CF_Order_Reference_Number__c != null AND CF_Order_Party_Id__c != null AND' + 
                            ' StageName = \'Pending Credit Report\' AND Account.BillingCountry = \'Hungary\'';
    }

    /*******************************************************************************
    *  Name            : start(Database.BatchableContext bc)
    *  Summary         : Collect SObjects to pass to the execute method.
    *  CreatedDate     : 29/06/2018
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
    *  Summary         : Call this method for each batch of records, create reports for completed orders.
    *  CreatedDate     : 29/06/2018
    *  ModifiedDate    : -
    *  Parameters      : Database.BatchableContext bc - object for tracking the progress of the batch job,
                         List<Opportunity> opportunitiesList - list Opportunities to process
    *  Returns         : void
    ******************************************************************************/
    global void execute(Database.BatchableContext BC, List<Opportunity> opportunitiesList) {
        try {
            List<Opportunity> opportunitiesToCheckList = new List<Opportunity>();
            for (Opportunity opportunity : opportunitiesList) {
                if (opportunity.Credit_Factory_Reports__r.size() == 0) {
                    opportunitiesToCheckList.add(opportunity);
                }
            }

            List<Opportunity> opportunitiesToUpdateList = new List<Opportunity>();
            List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
            Map<Id, Credit_Factory_Report__c> creditReportsMap = new Map<Id, Credit_Factory_Report__c>();
            Map<Id, List<Credit_Factory_Report_Employee__c>> creditReportEmployeesMap = new Map<Id, List<Credit_Factory_Report_Employee__c>>();
            List<Attachment> attachmentsList = new List<Attachment>();
            for (Opportunity opportunity : opportunitiesToCheckList) {
                if (isOpportuintyOld(opportunity) == true) {
                    opportunity.StageName = 'Closed Lost';
                    opportunity.Gruende_verloren__c = 'Credit Report not available';
                    opportunitiesToUpdateList.add(opportunity);
                    messages.add(prepareUnavailableReportEmail(opportunity));
                }

                CreditSystemService creditSystem = new CreditSystemService();
                creditSystem.setCreditSystemSource(opportunity.Id);
                String orderStatus = getOrderStatus(creditSystem, opportunity);
                if (orderStatus == 'FinishedNegative') {
                    // unavailable report
                    opportunity.StageName = 'Closed Lost';
                    opportunity.Gruende_verloren__c = 'Credit Report not available';
                    opportunitiesToUpdateList.add(opportunity);
                    messages.add(prepareUnavailableReportEmail(opportunity));
                } else if (orderStatus == 'Finished') {
                    // available report
                    // xml report
                    Dom.XMLNode xmlReportResponse = getXMLReportResponse(creditSystem, opportunity);
                    String internalId = CofaceWebservice.returnInternalId(xmlReportResponse);
                    CreditCompany company = CofaceWebservice.returnReportCompany(xmlReportResponse, internalId);
                    Dom.XMLNode innerXML = CofaceWebservice.returnInnerXmlReport(xmlReportResponse);
                    List<CreditCompanyEmployee> companyEmployeesList = CofaceWebservice.returnReportCompanyEmployees(innerXML);
                    creditReportsMap.put(opportunity.Id, prepareCreditReport(company, opportunity.Id));
                    creditReportEmployeesMap.put(opportunity.Id, prepareCreditReportEmployess(companyEmployeesList));

                    // pdf report
                    Dom.XMLNode binaryReportResponse = getReportBinaryResponse(creditSystem, opportunity, internalId);
                    Blob blobBody = CofaceWebservice.getOrderedBinaryAttachment(binaryReportResponse);
                    attachmentsList.add(prepareCreditReportAttachment(opportunity.Id, blobBody));
                    opportunity.Credit_Factory_PDF_Report_Created__c = true;
                    opportunity.StageName = 'Credit Report Generated';
                    opportunity.CF_Stage__c = 'Credit Report Generated';
                    opportunitiesToUpdateList.add(opportunity);
                    messages.add(prepareAvailableReportEmail(opportunity));
                } // else research is not finished
            }   

            if (! creditReportsMap.isEmpty()) {
                insert creditReportsMap.values();
                List<Credit_Factory_Report_Employee__c> crefoReportEmployeesListToInsert = new List<Credit_Factory_Report_Employee__c>();
                for (Id opportunityId : creditReportsMap.keySet()) {
                    for (Credit_Factory_Report_Employee__c employee : creditReportEmployeesMap.get(opportunityId)) {
                        employee.Credit_Factory_Report__c = creditReportsMap.get(opportunityId).Id;
                        crefoReportEmployeesListToInsert.add(employee);
                    }
                }

                if (! crefoReportEmployeesListToInsert.isEmpty()) {
                    insert crefoReportEmployeesListToInsert;
                }
            }

            if (! attachmentsList.isEmpty()) {
                insert attachmentsList;
            }

            if (! opportunitiesToUpdateList.isEmpty()) {
                update opportunitiesToUpdateList;
            }

            if (! messages.isEmpty()) {
                Messaging.sendEmail(messages);
            }
        } catch (Exception e) {
            ExceptionLogger.sendException(String.valueOf(e.getMessage()), String.valueOf(e.getStackTraceString()));
        }
    }


    /*******************************************************************************
    *  Name            : isOpportuintyOld()
    *  Summary         : Check last change of Stage. 
    *  CreatedDate     : 29/06/2018
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
    *  Name            : prepareAvailableReportEmail(Opportunity opportunity)
    *  Summary         : Prepare email to send for sales if report is available to use.
    *  CreatedDate     : 29/06/2018
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
    *  Summary         : Prepare email to send for sales if report is not available to use
    *  CreatedDate     : 29/06/2018
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
    *  Name            : getOrderStatus(CreditSystem creditSystem, Opportunity opportunity)
    *  Summary         : Send request to get order status.
    *  CreatedDate     : 29/06/2018
    *  ModifiedDate    : -
    *  Parameters      : CreditSystem - credit system object with Coface credentials,
                         Opportunity opportunity - ordered opportunity
    *  Returns         : String
    ******************************************************************************/
    public String getOrderStatus(CreditSystem creditSystem, Opportunity opportunity) {
        HttpRequest request = CofaceWebservice.generateOrderStatusrequest(creditSystem.getEndpointUrl(),
                creditSystem.getUserName(), creditSystem.getUserPassword(), opportunity.CF_Order_Party_Id__c,
                opportunity.CF_Order_Reference_Number__c);
        Http http = new Http();
        HttpResponse response = http.send(request);
        System.debug('DEBUG: ORDER STATUS RESPONSE === ' + response.getBody());
        String xmlResponse = response.getBody();
        Dom.Document domDoc = new Dom.Document();
        domDoc.load(xmlResponse);
        Dom.XMLNode xmldom = domDoc.getRootElement();
        Dom.XMLNode globalBody = CofaceWebservice.returnGlobalBody(xmldom);
        Boolean isValidreport = CofaceWebservice.checkResponseForFault(globalBody);
        if ( ! isValidreport ) {
            String errorMessageResponse = CofaceWebservice.returnErrorMessage(globalBody);
            throw new CreditFactoryException('Order status request failed. ' + errorMessageResponse);
        }

        return CofaceWebservice.returnOrderStatus(globalBody); 
    }


    /*******************************************************************************
    *  Name            : getXMLReportResponse(CreditSystem creditSystem, Opportunity opportunity)
    *  Summary         : Send request to get ordered report.
    *  CreatedDate     : 29/06/2018
    *  ModifiedDate    : -
    *  Parameters      : CreditSystem - credit system object with Coface credentials,
                         Opportunity opportunity - ordered opportunity
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public Dom.XMLNode getXMLReportResponse(CreditSystem creditSystem, Opportunity opportunity) {
        HttpRequest request = CofaceWebservice.generateOrderedReportRequest(creditSystem.getEndpointUrl(),
                creditSystem.getUserName(), creditSystem.getUserPassword(), opportunity.CF_Order_Party_Id__c,
                opportunity.CF_Order_Reference_Number__c);
        Http http = new Http();
        HttpResponse response = http.send(request);
        System.debug('DEBUG: ORDERED XML REPORT RESPONSE === ' + response.getBody());
        String xmlResponse = response.getBody();
        Dom.Document domDoc = new Dom.Document();
        domDoc.load(xmlResponse);
        Dom.XMLNode xmldom = domDoc.getRootElement();
        Dom.XMLNode globalBody = CofaceWebservice.returnGlobalBody(xmldom);
        Boolean isValidreport = CofaceWebservice.checkResponseForFault(globalBody);
        if ( ! isValidreport ) {
            String errorMessageResponse = CofaceWebservice.returnErrorMessage(globalBody);
            throw new CreditFactoryException('Ordered Report request failed. ' + errorMessageResponse);
        }

        return globalBody;
    }


    /*******************************************************************************
    *  Name            : getReportBinaryResponse(CreditSystem creditSystem, Opportunity opportunity)
    *  Summary         : Send request to get ordered pdf report.
    *  CreatedDate     : 29/06/2018
    *  ModifiedDate    : -
    *  Parameters      : CreditSystem - credit system object with Coface credentials,
                         Opportunity opportunity - ordered opportunity, String internalId - Coface company internal Id
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public Dom.XMLNode getReportBinaryResponse(CreditSystem creditSystem, Opportunity opportunity, String internalId) {
        HttpRequest request = CofaceWebservice.generatePdfReportRequest(creditSystem.getEndpointUrl(),
                creditSystem.getUserName(), creditSystem.getUserPassword(), internalId, '200');
        Http http = new Http();
        HttpResponse response = http.send(request);
        System.debug('DEBUG: ORDERED BINARY REPORT RESPONSE === ' + response.getBody());
        String xmlResponse = response.getBody();
        Dom.Document domDoc = new Dom.Document();
        domDoc.load(xmlResponse);
        Dom.XMLNode xmldom = domDoc.getRootElement();
        Dom.XMLNode globalBody = CofaceWebservice.returnGlobalBody(xmldom);
        Boolean isValidreport = CofaceWebservice.checkResponseForFault(globalBody);
        if ( ! isValidreport ) {
            String errorMessageResponse = CofaceWebservice.returnErrorMessage(globalBody);
            throw new CreditFactoryException('Ordered Binary Report request failed. ' + errorMessageResponse);
        }

        return globalBody;
    }


    /*******************************************************************************
    *  Name            : prepareCreditReport(CreditCompany company, String opportunityId)
    *  Summary         : prepare credit report to insert     
    *  CreatedDate     : 29/06/2018
    *  ModifiedDate    : -
    *  Parameters      : CreditCompany company - company from response, String opportunityId - Id of processed opportunity
    *  Returns         : void
    ******************************************************************************/
    public Credit_Factory_Report__c prepareCreditReport(CreditCompany company, String opportunityId) {
        String reportname = company.name;
        if (reportname.length() > 80) {
            reportname = reportname.substring(0,80);
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
            Register_Number__c = company.registerNumber,
            Staff_Range__c = company.staffcompanyrange,
            Street__c = company.street,
            Trade_Name__c = company.tradename,
            Turn_Over__c = company.turnOver,
            VAT_Number__c = company.vatid,
            Website__c = company.website,
            Name = reportname,
            Company_Id__c = company.identificationnumber,
            Date_Of_Last_Major_Update__c = company.dateOfLastMajorUpdate,
            Class_Rating__c = company.classRating,
            Reference_Number__c = company.referencenumber);
        return creditReport;
    }


    /*******************************************************************************
    *  Name            : prepareCreditReportEmployess(List<CreditCompanyEmployee> companyEmployeesList)
    *  Summary         : prepare list of credit report employees to insert    
    *  CreatedDate     : 29/06/2018
    *  ModifiedDate    : -
    *  Parameters      : List<CreditCompanyEmployee> companyEmployeesList - company employess from response
    *  Returns         : Credit_Factory_Report_Employee__c
    ******************************************************************************/
    public List<Credit_Factory_Report_Employee__c> prepareCreditReportEmployess(List<CreditCompanyEmployee> companyEmployeesList) {
        List<Credit_Factory_Report_Employee__c> creditReportEmployeesList = new List<Credit_Factory_Report_Employee__c>();
        for (CreditCompanyEmployee employee : companyEmployeesList) {
            String employeeName = employee.ename;
            if (employee.ename.length() > 80) {
                employeeName = employeeName.substring(0,80);
            }
            creditReportEmployeesList.add(new Credit_Factory_Report_Employee__c(
                Address__c = employee.address,
                Date_of_Birth__c = employee.dateofbirth,
                Id__c = employee.enumber,
                Name = employeeName,
                Participation_Date__c = employee.participationdate,
                Type__c = employee.type,
                Company_Id__c = employee.companyId,
                Company_Type__c = employee.companyType,
                Company_Role__c = employee.companyRole));
        }

        return creditReportEmployeesList;
    }


    /*******************************************************************************
    *  Name            : prepareCreditReportAttachment(Opportunity opportunity)
    *  Summary         : Prepare Credit Company Report PDF Attachment to insert
    *  CreatedDate     : 29/06/2018
    *  ModifiedDate    : -
    *  Parameters      : String opportunityId - processed Opportunity, Blob blobBody - blob body for attachment
    *  Returns         : Attachment
    ******************************************************************************/
    public Attachment prepareCreditReportAttachment(String opportunityId, Blob blobBody) {
        if (blobBody != null) {
            Attachment creforeport = new Attachment(
                ParentId = opportunityId,
                Name = 'CofaceReport.pdf',
                Body = blobBody);
            return creforeport; 
        }

        return null;
    }


    global void finish(Database.BatchableContext BC) {

    }
}