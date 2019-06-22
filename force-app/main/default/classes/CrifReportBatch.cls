global class CrifReportBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    public String query;
    @TestVisible static Messaging.SingleEmailMessage mail;

    global CrifReportBatch() {
        this.query = 'SELECT Credit_Report_Id__c, OwnerId, Name, Owner.Email, Owner.Name, Opportunity.Credit_Report_Request_Date__c, ' +
                            '(SELECT Id ' + 
                            'FROM Credit_Factory_Reports__r ' +
                            'WHERE CreatedDate > :threeMonthsAgoDate) ' +
                     'FROM Opportunity ' +
                     'WHERE Credit_Report_Id__c != null AND Credit_Report_Request_Date__c = TODAY AND Account.BillingCountry = \'Poland\'';
    }


    /*******************************************************************************
    *  Name            : start(Database.BatchableContext bc)
    *  Summary         : Collect SObjects to pass to the execute method.
    *  CreatedDate     : 07/07/2018
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
    *  CreatedDate     : 07/07/2018
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
                CreditSystemService creditSystem = new CreditSystemService();
                creditSystem.setCreditSystemSource(opportunity.Id);
                Dom.XMLNode reportBody = getReportBody(creditSystem, opportunity.Credit_Report_Id__c);
                CreditCompany company = CrifWebservice.returnReportCompany(reportBody, opportunity.Credit_Report_Id__c);
                Date dateOfNextRun = Datetime.now().addHours(1).date();
                if (Test.isRunningTest()) {
                    dateOfNextRun = Date.today().addDays(1);
                }

                if (company.requestStatus == 'OK' && company.identificationType != 'NOT_IDENTIFIED' || dateOfNextRun > opportunity.Credit_Report_Request_Date__c) {
                    creditReportsMap.put(opportunity.Id, prepareCreditReport(company, opportunity.Id));
                    List<CreditCompanyEmployee> companyEmployeesList = CrifWebservice.returnReportCompanyEmployees(reportBody);
                    creditReportEmployeesMap.put(opportunity.Id, prepareCreditReportEmployess(companyEmployeesList));
                    scheduleJobForPDFReport(creditSystem, company.creditSystemCompanyNumber, opportunity.Id);

                    opportunity.StageName = 'Credit Report Generated';
                    opportunity.CF_Stage__c = 'Credit Report Generated';
                    opportunitiesToUpdateList.add(opportunity);

                    if (company.requestStatus == 'OK' && company.identificationType != 'NOT_IDENTIFIED') {
                        messages.add(prepareCorrectReportEmail(opportunity));
                    } else {
                        messages.add(prepareWrongReportEmail(opportunity));
                    }
                }
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
    *  Name            : getReportBody(CreditSystem creditSystem, String reportId)
    *  Summary         : Send report request and get its body.
    *  CreatedDate     : 07/07/2018
    *  ModifiedDate    : -
    *  Parameters      : CreditSystem - credit system object with Crif credentials,
                         String reportId - internal Crif Id
    *  Returns         : String
    ******************************************************************************/
    public Dom.XMLNode getReportBody(CreditSystem creditSystem, String reportId) {
        try {
            HttpRequest request = CrifWebservice.generateReportRequest(
                creditSystem.getEndpointUrl(), creditSystem.getUserName(), 
                creditSystem.getUserPassword(), reportId);
            System.debug('DEBUG: REPORT REQUEST === ' + request.getBody());
            Http h = new Http();
            HttpResponse response = h.send(request);
            String xml = response.getBody();
            System.debug('DEBUG: REPORT RESPONSE === ' + xml);
            Dom.Document domDoc = new Dom.Document();
            domDoc.load(xml);
            Dom.XMLNode xmldom = domDoc.getRootElement();
            Dom.XMLNode reportDom = CrifWebservice.returnReportBody(xmldom);   
            return reportDom;
        } catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            String errorMessage = 'Send Report Request failed. ' + CreditFactoryUtilities.CONTACT_ADMIN;
            throw new CreditFactoryException(errorMessage); 
        }
    }


    /*******************************************************************************
    *  Name            : prepareCreditReport(CreditCompany company, String opportunityId)
    *  Summary         : prepare credit report to insert     
    *  CreatedDate     : 07/07/2018
    *  ModifiedDate    : -
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
            Credit_Limit__c = company.creditLimit,
            Date_of_Foundation__c = company.dateoffoundation,
            Email__c = company.email,
            Fax__c = company.fax,
            First_Legal_Form__c = company.firstlegalform,
            Fiscal_Number__c = company.taxnumber,
            Housenumber__c = company.housenumber,
            Legal_Form__c = company.legalform,
            Mobile__c = company.mobile,
            Opportunity__c = opportunityId,
            Phone__c = company.phone,
            Postcode__c = company.postcode,
            Register_Number__c = company.registerNumber,
            Staff_Range__c = company.staffcompanyrange,
            Street__c = company.street,
            Trade_Name__c = company.tradename,
            Turn_Over__c = company.turnOver,
            Trade_Register_Number__c = company.tradeRegisterNumber,
            Tax_Id__c = company.taxnumber,
            Website__c = company.website,
            Name = reportName,
            Company_Id__c = company.identificationnumber,
            Solvency_Index__c = company.solvencyIndex,
            Request_Status__c = company.requestStatus,
            Obligation_Overdue__c = company.obligationOverdue,
            Class_Rating__c = company.classRating,
            Number_Of_Hits__c = company.numberOfHits,
            Policy_Rules_Hits__c = String.join(company.policyRulesHits, '\r\n'),
            Name_Change_Decision__c = company.nameChangeDecision,
            Address_Change_Decision__c = company.addressChangeDecision,
            Postal_Street__c = company.postalStreet,
            Postal_Housenumber__c = company.postalHousenumber,
            Postal_City__c = company.postalCity,
            Postal_Postcode__c = company.postalPostcode,
            Registered_Street__c = company.registeredStreet,
            Registered_Housenumber__c = company.registeredHousenumber,
            Registered_City__c = company.registeredCity,
            Registered_Postcode__c = company.registeredPostcode,
            Name__c = company.name);
        return creditReport;
    }


    /*******************************************************************************
    *  Name            : prepareCreditReportEmployess(List<CreditCompanyEmployee> companyEmployeesList)
    *  Summary         : prepare list of credit report employees to insert    
    *  CreatedDate     : 07/07/2018
    *  ModifiedDate    : -
    *  Parameters      : List<CreditCompanyEmployee> companyEmployeesList - company employess from response
    *  Returns         : Credit_Factory_Report_Employee__c
    ******************************************************************************/
    public List<Credit_Factory_Report_Employee__c> prepareCreditReportEmployess(List<CreditCompanyEmployee> companyEmployeesList) {
        List<Credit_Factory_Report_Employee__c> creditReportEmployeesList = new List<Credit_Factory_Report_Employee__c>();
        for (CreditCompanyEmployee employee : companyEmployeesList) {
            String employeeName = employee.ename;
            if (employeeName != null && employeeName.length() > 80) {
                employeeName = employeeName.substring(0, 80);
            }
            creditReportEmployeesList.add(new Credit_Factory_Report_Employee__c(
                Address__c = employee.address,
                Name = employeeName,
                Type__c = employee.type));
        }

        return creditReportEmployeesList;
    }


    /*******************************************************************************
    *  Name            : scheduleJobForPDFReport()
    *  Summary         : schedule job for creating pdf attachment    
    *  CreatedDate     : 07/07/2018
    *  ModifiedDate    : -
    *  Parameters      : CreditSystem - credit system object with Crif credentials,
                         String creditReportId - internal Crif report Id, String opportunityId - 
                         Id of related Opportunity
    *  Returns         : void
    ******************************************************************************/
    public void scheduleJobForPDFReport(CreditSystem creditSystem, String creditReportId, String opportunityId) {
        // send pdf request asynchronously
        String schedule = Datetime.now().addSeconds(5).second() + ' ' + Datetime.now().addSeconds(5).minute() + ' ' + Datetime.now().addSeconds(5).hour() + ' ' 
            + Datetime.now().addSeconds(5).day() + ' ' + Datetime.now().addSeconds(5).month() + ' ? ' + Datetime.now().addSeconds(5).year();
        String scheduleName = 'Crif Pdf attachment ' + Datetime.now().addSeconds(5).minute() + Datetime.now().addSeconds(5).second() + 
            Datetime.now().addSeconds(5).millisecond();
        CrifPdfSchedule crifPdfSchedule = new CrifPdfSchedule(creditSystem.getEndpointUrl(), creditSystem.getUserName(), creditSystem.getUserPassword(), 
            creditReportId, opportunityId);
        System.schedule(scheduleName, schedule, crifPdfSchedule);
    }


    /*******************************************************************************
    *  Name            : prepareCorrectReportEmail(Opportunity opportunity)
    *  Summary         : Prepare email to send for sales if report is created without request status error
    *  CreatedDate     : 07/07/2018
    *  ModifiedDate    : -
    *  Parameters      : Opportunity opportunity - processed Opportunity 
    *  Returns         : Messaging.SingleEmailMessage
    ******************************************************************************/
    public Messaging.SingleEmailMessage prepareCorrectReportEmail(Opportunity opportunity) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setTargetObjectId(opportunity.ownerId);
        message.subject = 'Crif report is available for your Customer ' + opportunity.Name;
        message.setSenderDisplayName('Salesforce Notification');
        message.htmlBody = 'Dear ' + opportunity.Owner.Name + ',<br/><br/>Crif report is available for your Customer ' + opportunity.Name + '.<br/>' + 
            'Please launch the Credit Factory once again.<br/><br/>Link to the Opportunity: <a href="' + 
            URL.getSalesforceBaseUrl().toExternalForm() + '/' + opportunity.Id + '"> ' + opportunity.Name + '</a><br/><br/>' +
            'This is an automatically generated email, please do not respond.';    
        message.saveAsActivity = false;
        return message;
    }


    /*******************************************************************************
    *  Name            : prepareWrongReportEmail(Opportunity opportunity)
    *  Summary         : Prepare email to send for sales if report is created with request status error
    *  CreatedDate     : 07/07/2018
    *  ModifiedDate    : -
    *  Parameters      : Opportunity opportunity - processed Opportunity 
    *  Returns         : Messaging.SingleEmailMessage
    ******************************************************************************/
    public Messaging.SingleEmailMessage prepareWrongReportEmail(Opportunity opportunity) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setTargetObjectId(opportunity.ownerId);
        message.subject = 'Crif report came with error for your Customer ' + opportunity.Name;
        message.setSenderDisplayName('Salesforce Notification');
        message.htmlBody = 'Dear ' + opportunity.Owner.Name + ',<br/><br/>Crif report for your Customer ' + opportunity.Name + ' was received with an error.<br/>' + 
            'Please launch the Credit Factory once again to update the fields and submit your Opportunity for manual approval. ' + 
            'Link to the Opportunity: <a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + opportunity.Id + '"> ' + opportunity.Name + '</a><br/><br/>' +
            'This is an automatically generated email, please do not respond.';    
        message.saveAsActivity = false;
        return message;
    }


    global void finish(Database.BatchableContext BC) {

    }
}