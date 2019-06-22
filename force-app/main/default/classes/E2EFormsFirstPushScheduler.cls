global class E2EFormsFirstPushScheduler implements Schedulable {
    private static final String DE_DESKTOP = 'https://online.fleetcor.de/e2eform?country=Germany&utm_source=testjob';
	private static final String DE_MOBILE = 'https://online.fleetcor.de/e2eformmob?country=Germany&utm_source=testjob';
    private static final String NL_DESKTOP = 'https://online.fleetcor.nl/e2eformnl?utm_source=testjob';
    private static final String NL_MOBILE = 'https://online.fleetcor.nl/e2eformmobnl?utm_source=testjob';
    private static final String BENL_DESKTOP = 'https://online.fleetcorcards.be/e2eformbenl?utm_source=testjob';
    private static final String BENL_MOBILE = 'https://online.fleetcorcards.be/e2eformmobbenl?utm_source=testjob';
    private static final String BEFR_DESKTOP = 'https://online.fleetcorcards.be/e2eformbefr?utm_source=testjob';
    private static final String BEFR_MOBILE = 'https://online.fleetcorcards.be/e2eformmobbefr?utm_source=testjob'; 
    private static final String PL_DESKTOP = 'https://online.fleetcor.pl/e2eformpl?utm_source=testjob';
    private static final String PL_MOBILE = 'https://online.fleetcor.pl/e2eformmobpl?utm_source=testjob';
    private static final String HU_DESKTOP = 'https://online.fleetcor.hu/e2eformhu?utm_source=testjob';
    private static final String HU_MOBILE = 'https://online.fleetcor.hu/e2eformmobhu?utm_source=testjob';

	/*******************************************************************************
	*  Name            : E2EFormsFirstPushScheduler()
	*  Summary         : constructor    
	*  CreatedDate     : 02/11/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public E2EFormsFirstPushScheduler() {

	}


	/*******************************************************************************
    *  Name            : execute(Schedulable sc)
    *  Summary         : execute batch for sending request to E2E Form  
    *  CreatedDate     : 02/11/2018
    *  Parameters      : Schedulable sc - object to track the schedulable job
    *  Returns         : void
    ******************************************************************************/
    global void execute(SchedulableContext sc) {
    	try {
            sendRequestToE2E(DE_DESKTOP, DE_MOBILE);
            sendRequestToE2E(NL_DESKTOP, NL_MOBILE);
            sendRequestToE2E(BENL_DESKTOP, BENL_MOBILE);
            sendRequestToE2E(BEFR_DESKTOP, BEFR_MOBILE);
            sendRequestToE2E(PL_DESKTOP, PL_MOBILE);
            sendRequestToE2E(HU_DESKTOP, HU_MOBILE);
            
	        deleteExecutedJobs();
        } catch (Exception e) {} 
    }

    /*******************************************************************************
    *  Name            : sendRequestToE2E(String siteDesktopUrl, String siteMobileUrl)
    *  Summary         : send request to E2E forms (desktop and mobile versions)    
    *  CreatedDate     : 02/11/2018
    *  ModifiedDate    : -
    *  Parameters      : String siteDesktopUrl, String siteMobileUrl
    *  Returns         : void
    ******************************************************************************/
    @future(callout = true)
	public static void sendRequestToE2E(String siteDesktopUrl, String siteMobileUrl) {
		// Generate and send request to E2E desktop
		HttpRequest req = new HttpRequest();
     	req.setEndpoint(siteDesktopUrl);
     	req.setMethod('GET');
     	Http protocol = new Http();
     	protocol.send(req);

     	// Generate and send request to E2E mobile
		HttpRequest request = new HttpRequest();
     	request.setEndpoint(siteMobileUrl);
     	request.setMethod('GET');
     	Http ptcl = new Http();
     	ptcl.send(request);	       
    }


    /*******************************************************************************
    *  Name            : deleteExecutedJobs()
    *  Summary         : delete scheduled jobs that already executed
    *  CreatedDate     : 02/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void deleteExecutedJobs() {
    	List<CronTrigger> jobsList = [
                SELECT Id
                FROM CronTrigger
                WHERE CronJobDetail.Name LIKE 'E2E Forms First Push%' AND PreviousFireTime != null
                LIMIT 100
        ];
        if ( ! jobsList.isEmpty()) {
            for (CronTrigger job : jobsList) {
                System.abortJob(job.Id);
            }
        }

        String sch = Datetime.now().addMinutes(5).second() + ' ' + Datetime.now().addMinutes(5).minute() + ' *' + ' ?' + ' *' + ' *';
        E2EFormsFirstPushScheduler scheduleE2EformsFirstPush = new E2EFormsFirstPushScheduler();
        System.schedule('E2E Forms First Push' + ' ' + Datetime.now().addMinutes(5) + '(' + Math.random() + ')', sch, scheduleE2EformsFirstPush);
    }
}