public class E2EAsyncSenderRequests implements Queueable, DataBase.AllowsCallouts{
    private E2EFormRuService formService;
    private E2EFormRuDao e2eFormRuDao;
    private TransitWebService transitWebService;
    private MZKWebService mzkWebService;
    private ReportWebService reportWebService;

    private E2EFormParams formParams;
    private E2EFormData__c formDataRecord;
    private Map<String, LongFormPage> pagesContentMap;

    public E2EAsyncSenderRequests(Id formDataId, E2EFormParams formParamsValue, Map<String, LongFormPage> pagesContentMapValue){
        this.formService = new E2EFormRuServiceImpl();
        this.e2eFormRuDao = new E2EFormRuDaoImpl();
        this.transitWebService = new TransitWebServiceImpl();
        this.mzkWebService = new MZKWebServiceImpl();
        this.reportWebService = new reportWebServiceImpl();

        this.formDataRecord = e2eFormRuDao.getFormDataById(formDataId);
        this.formParams = formParamsValue;
        this.pagesContentMap = pagesContentMapValue;
    }

    public void execute(QueueableContext param1){
        try{
            if( !formParams.sendToInbound ){ // Standard E2E process
                // Generate Contract
                ReportResponseData reportResponseData = sendRequestForGenerateContract(false);
                this.formParams.saveReport = ' > ' + GlobalUtils.E2ERuProcessStatus.SaveReport.name(); // log process
                System.debug('******* REPORT RESPONSE: ' + reportResponseData);

                // Create Transit Cont
                TransitRequestData transitRequestData = formService.prepareTransitRequestData(this.formDataRecord.Id, this.formParams, this.pagesContentMap);
                TransitResponseData response = this.transitWebService.storeContData(transitRequestData);
                this.formParams.transitContId = response.createdId;
                this.formParams.createContInTransit = ' > ' + GlobalUtils.E2ERuProcessStatus.CreateContInTransit.name(); // log process
                System.debug('this.formParams.transitContId: ' + this.formParams.transitContId);

                // Create MZK proposal
                MZKRequest request = formService.prepareMzkRequest(this.formDataRecord.Id, this.formParams);
                this.formParams.requestNumMZK = this.mzkWebService.getRequestNumber(request);
                System.debug('MZK number: ' + this.formParams.requestNumMZK);

                // Create document links for client private office (для личного кабинета)
                sendRequestForCreateDocLinks(reportResponseData);

                // Update sObjects
                formDataRecord.E2E_Contract_Number__c = (formParams.contractPrefix != null && formParams.contractCounter != null) ? (String.format('{0}-{1}', new List<String>{formParams.contractPrefix, formParams.contractCounter})) : '';
                formDataRecord.E2E_Req_Num_MZK__c = GlobalUtils.blankStringIfNull(formParams.requestNumMZK);
                formDataRecord.E2E_Transit_Cont_Id__c = GlobalUtils.blankStringIfNull(formParams.transitContId);
                e2eFormRuDao.updateFormData(formDataRecord);

                Opportunity opportunity = new Opportunity(Id = formDataRecord.E2E_Opportunity_Id__c);
                opportunity.Req_Num_MZK__c = formParams.requestNumMZK;
                opportunity.Transit_ID__c = formParams.transitContId;
                opportunity.StageName = 'Awaiting payment';
                opportunity.e2e_payment_status__c = 'Ожидание платежа'; // Emarsys send email trigger
                e2eFormRuDao.updateOpportunity(opportunity);
            }
            else { // Send to Inbound
                // Generate Contract
                ReportResponseData reportResponseData = sendRequestForGenerateContract(false);
                this.formParams.saveReport = ' > ' + GlobalUtils.E2ERuProcessStatus.SaveReport.name(); // log process
                System.debug('******* REPORT RESPONSE: ' + reportResponseData);

                // Update sObjects
                formDataRecord.E2E_Contract_Number__c = (formParams.contractPrefix != null && formParams.contractCounter != null) ? (String.format('{0}-{1}', new List<String>{formParams.contractPrefix, formParams.contractCounter})) : '';
                e2eFormRuDao.updateFormData(formDataRecord);
            }
        }
        catch (Exception e){
            ExceptionLogger.sendException('<br/>E2EAsyncSenderRequests.execute : ' + String.valueOf(e.getMessage()), String.valueOf(e.getStackTraceString()));

            Opportunity opportunity = new Opportunity(Id = formDataRecord.E2E_Opportunity_Id__c);
            opportunity.E2E_Sub_Status__c = 'Перевод в ручную обработку';
            opportunity.E2E_Errors__c = String.valueOf(e.getMessage());
            e2eFormRuDao.updateOpportunity(opportunity);

            // send notification to call center
            String body = this.formService.getEmailBodyNotificationCallCenter(opportunity.Id, 'New E2E Client');
            this.formService.sendE2ENotification(body, 'Russia E2E System Error', GlobalUtils.E2ERuGroupsNotification.CallCenter);
        }
    }

    private List<String> getReportIdsForContract(Boolean isDraft) {
        ReportRequestData requestData = this.formService.prepareReportRequestData(this.formDataRecord.Id, this.formParams, this.pagesContentMap, isDraft);
        System.debug('********* REPORT REQUEST DATA: ' + requestData);
        ReportResponseData response = this.reportWebService.getReportIdsFromCreditFactory(requestData);
        System.debug('********* REPORT RESPONSE DATA: ' + response);

        if (!isDraft) {
            this.formParams.contractPrefix = response.reportParams.SALESFORCE_CONTRACT_PREFIX;
            this.formParams.contractCounter = response.reportParams.SALESFORCE_CONTRACT_COUNTER;
            this.formParams.invoicePrefix = response.reportParams.SALESFORCE_INVOICE_PREFIX;
            this.formParams.invoiceCounter = response.reportParams.SALESFORCE_INVOICE_COUNTER;
        }
        return this.reportWebService.getOrderReportIds(response, GlobalUtils.reportIdsSequence);
    }

    private ReportResponseData sendRequestForGenerateContract(Boolean isDraft) {
        ReportRequestData requestData = this.formService.prepareReportRequestData(this.formDataRecord.Id, this.formParams, this.pagesContentMap, isDraft);
        System.debug('********* REPORT REQUEST DATA: ' + requestData);
        ReportResponseData response = this.reportWebService.getReportIdsFromCreditFactory(requestData);
        System.debug('********* REPORT RESPONSE DATA: ' + response);

        if (!isDraft) {
            saveContractNumber(response);
        }
        return response;
    }

    private void saveContractNumber(ReportResponseData response) {
        this.formParams.contractPrefix = response.reportParams.SALESFORCE_CONTRACT_PREFIX;
        this.formParams.contractCounter = response.reportParams.SALESFORCE_CONTRACT_COUNTER;
        this.formParams.invoicePrefix = response.reportParams.SALESFORCE_INVOICE_PREFIX;
        this.formParams.invoiceCounter = response.reportParams.SALESFORCE_INVOICE_COUNTER;
    }

    private void sendRequestForCreateDocLinks(ReportResponseData responseData) {
        try {
            TransitDocLinkRequestData requestData = this.formService.prepareTransitDocLinkRequestData(responseData, this.formParams);
            System.debug('********* TRANSIT DOC LINK REQUEST DATA: ' + requestData);

            // send request to create document links
            this.transitWebService.createDocumentLinks(requestData);
        } catch (Exception e) {
            ExceptionLogger.sendException('<br/>E2EAsyncSenderRequests.sendRequestForCreateDocLinks : ' + String.valueOf(e.getMessage()), String.valueOf(e.getStackTraceString()));
        }
    }

}