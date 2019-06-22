global class CrifPdfSchedule implements Schedulable {
	public String url;
	public String userName;
	public String password;
	public String archiveId;
	public String opportunityId;


	/*******************************************************************************
	*  Name            : CrifPdfSchedule(CreditSystem creditSystem, String archiveId)
	*  Summary         : constructor    
	*  CreatedDate     : 12/01/2018
    *  ModifiedDate    : 12/01/2018
    *  Parameters      : CreditSystem - creditSystem - credit system, String company Id - id of company for pdf,
    					 Opportunity opportunity - opportunity to update
    *  Returns         : -
	******************************************************************************/
	public CrifPdfSchedule(String url, String userName, String password, String archiveId, String opportunityId) {
		this.url = url;
		this.userName = userName;
		this.password = password;
		this.archiveId = archiveId;
		this.opportunityId = opportunityId;
	}


	/*******************************************************************************
	*  Name            : execute(SchedulableContext sc)
	*  Summary         : get pdf attachment from Crif
	*  CreatedDate     : 12/01/2018
	*  ModifiedDate    : 12/01/2018
	*  Parameters      : SchedulableContext sc - varibale to track schedulable job
	*  Returns         : void
	******************************************************************************/
    global void execute(SchedulableContext sc) {
        if (! Test.isRunningTest()) {
            sendPdfRequest(this.url, this.userName, this.password, this.archiveId, this.opportunityId);
        }
        deleteExecutedJobs();
    }


    /*******************************************************************************
    *  Name            : sendPdfRequest()
    *  Summary         : send pdf request to Crif, create attachment and update opportunity    
    *  CreatedDate     : 12/01/2017
    *  ModifiedDate    : 12/01/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @future(callout = true)
    public static void sendPdfRequest(String url, String userName, String password, String archiveId, String opportunityId) {
    	HttpRequest request;
		try {
			// Generate and send request
    		request = CrifWebservice.generatePdfRequest(url, userName, password, archiveId);
			Http h = new Http();
			HttpResponse response = h.send(request);
			Blob responseBody = response.getBodyAsBlob();
			if (responseBody != null) {
	            Attachment creforeport = new Attachment(
	                ParentId = opportunityId,
	                Name = 'CrifReport.pdf',
	                Body = response.getBodyAsBlob());
	            insert creforeport;
            }

            List<Opportunity> opportunitiesList = [
                    SELECT Credit_Factory_PDF_Report_Created__c
                    FROM Opportunity
                    WHERE Id = :opportunityId
                    LIMIT 1];
            if (! opportunitiesList.isEmpty() && opportunitiesList.get(0).Credit_Factory_PDF_Report_Created__c == false) {
		        opportunitiesList.get(0).Credit_Factory_PDF_Report_Created__c = true;
		        update opportunitiesList;
		    }
		} catch (Exception e) {
            ExceptionLogger.sendException(String.valueOf(e.getMessage()) + '\nOpportunityId: ' + opportunityId, String.valueOf(e.getStackTraceString()));
		}
    }


    /*******************************************************************************
    *  Name            : deleteExecutedJobs()
    *  Summary         : delete scheduled jobs that already executed
    *  CreatedDate     : 12/01/2017
    *  ModifiedDate    : 12/01/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void deleteExecutedJobs() {
    	List<CronTrigger> jobsList = [
                SELECT Id 
                FROM CronTrigger 
                WHERE CronJobDetail.Name LIKE 'Crif Pdf attachment%' AND NextFireTime = null
                LIMIT 10];
        if (! jobsList.isEmpty()) {
            for (CronTrigger job : jobsList) {
                System.abortJob(job.Id);
            }
        }
    }
}