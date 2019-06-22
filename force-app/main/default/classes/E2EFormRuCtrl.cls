global class E2EFormRuCtrl {

    public E2EFormRuCtrl currentPage {
        get {
            return this;
        }
        set;
    }

    /* URL params */
    public E2EFormParams formParams { get; set; }
    public String country { get; set; }
    public String product { get; set; }
    public Boolean productNotChange { get; set; }
    public String offer { get; set; }

    public Map<String, LongFormTariff> msl_suffix { get; set; }
    public Map<String, String> sparkLegalDetailsData { get; set; }
    public String productID { get; set; }

    public Id accountId { get; set; }
    public Id opportunityId { get; set; }
    public Id contactId { get; set; }
    public Id formDataId { get; set; }

    public String ipAddress;
    public GlobalUtils.DeviceType deviceType;

    public String activeStep { get; set; }
    public String activeModalWindow { get; set; }
    public String errorStep { get; set; }
    public Boolean sparkCompanyNoDataFound { get; set; }

    public E2EFormRuService formService;
    public SparkWebService sparkWebService;
    public ScoringWebService scoringWebService;
    public CrmWebService crmWebService;
    public ReportWebService reportWebService;
    public TransitWebService transitWebService;
    public MZKWebService mzkWebService;
    public Map<String, LongFormPage> pagesContentMap { get; set; }

    // Contract
    public List<String> reportIdList = new List<String>();
    public Boolean isActivateContractPreview = false;
    public Boolean isActivateContract = false;

    public String previewContractContent {
        get {
            return EncodingUtil.Base64Encode(getPreviewContract());
        }
    }

    // ONLINE CHAT
    public Map<String, LongFormPage> pageMapChat { get; set; }
    public LFChatService chatService;
    public String chatButtonId { get; set; }
    public String chatDeploymentId { get; set; }
    public String chatDeploymentJsURL { get; set; }
    public string chatURL { get; set; }
    public String offlineChatGreetingMessage { get; set; }
    public String chatFirstMessage { get; set; }

    // FOR REMOTE ACTION
    global static String companyInfoSpark { get; set; }
    global static String soleInfoSpark { get; set; }
    public String blackListDecision { get; set; }
    public String scoringPassed { get; set; }
    global static Boolean scoringRefused { get; set; }

    /*******************************************************************************
    *  Name            : init()
    *  Summary         : page initialization
    *  CreatedDate     : 18/06/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void init() {
        try {
            Long startTime = System.currentTimeMillis();
            System.debug('TIME: init() start:'+startTime);
            System.debug('**** INIT FORM');
            productID = 'PPR_1';
            this.formParams = new E2EFormParams();
            readUrlParams();
            this.msl_suffix = new Map<String, LongFormTariff>();
            this.sparkLegalDetailsData = new Map<String, String>();

            // init E2EFormParams.sendToInbound param
            E2E_Form_Ru_General_Settings__c settings = E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu');
            if (settings != null) {
                this.formParams.sendToInbound = settings.Send_To_Inbound__c;
            } else {
                this.formParams.sendToInbound = true;
            }

            this.formParams.deviceType = GlobalUtils.DeviceType.Desktop.name();
            this.formParams.ipAddress = LongFormGlobalUtils.getUserIPAddress();
            this.deviceType = GlobalUtils.DeviceType.Desktop;
            this.sparkCompanyNoDataFound = false;
            System.debug('UTM: ' + this.formParams.utmCampaign + ' ' + this.formParams.utmContent + ' ' +
                    this.formParams.utmMedium + ' ' +this.formParams.utmTerm + ' ' + this.formParams.utmSource
                    + ' ' +this.formParams.utmUrl);

            this.formService = returnFormService(this.country);
            this.sparkWebService = returnSparkWebService(this.country);
            this.scoringWebService = returnScoringWebService(this.country);
            this.crmWebService = returnCrmWebService(this.country);
            this.reportWebService = returnReportWebService(this.country);
            this.transitWebService = returnTransitWebService(this.country);
            this.mzkWebService = returnMZKWebService(this.country);
            if (this.activeStep == null) {
                this.activeStep = GlobalUtils.E2ERuSteps.ContactDetails.name();

            }
            pagesContentMap = new Map<String, LongFormPage>();
            formService.collectContent(this.country, activeStep, pagesContentMap, GlobalUtils.DeviceType.Desktop);

            if (this.formDataId != null && this.activeStep != null) {
                // If the client come by special link
                Map<String, String> objectIds = new Map<String, String>();
                formService.collectContentDataByLink(this.formDataId, this.activeStep, this.pagesContentMap, this.formParams, this.msl_suffix, objectIds);
                this.accountId = objectIds.get('accountId');
                this.contactId = objectIds.get('contactId');
                this.opportunityId = objectIds.get('opportunityId');

                // set product and offer
                this.offer = this.formParams.offer;
                this.product = this.formParams.product;

                System.debug('Params by special link: offer ' + this.offer + ' product ' + this.product + ' ' + formParams.source);

                // If the client return by a special link he will become the owner of opportunity again (if a manager has changed it before)
                Opportunity existOpportunity = formService.getOpportunityById(this.opportunityId);
                // If the client return by a special link we check that opportunity has valid stage
                if( existOpportunity.stageName == 'Moved to start' || existOpportunity.stageName == 'Awaiting payment' ||
                        (existOpportunity.stageName == 'Отказ' && existOpportunity.PPR_Lost_Reasons__c == 'Не прошли скоринг') ||
                        ((existOpportunity.stageName == 'Договор на проверке' || existOpportunity.stageName == 'Contract Under Signing' ||
                                existOpportunity.stageName == 'Signing of a Contract') && existOpportunity.E2E_Sales_Type__c == 'Е2Е с участием Inbound')) {
                    throw new E2EFormRuException('Error: Link is deactivated, OpportunityId: ' + this.opportunityId + ' StageName: ' + existOpportunity.stageName);
                }

                // If the client return by a special link he will become the owner of opportunity again (if a manager has changed it before)
                if(existOpportunity != null){
                    this.formService.changeObjectOwner(this.opportunityId, 'E2E RU Site Guest User');
                }
            }

            formService.collectSharedResource(this.country, pagesContentMap, GlobalUtils.DeviceType.Desktop, this.formParams.source);

            initChatSetup();

            System.debug('formDataId=' + this.formDataId + '; accountId=' + this.accountId + '; contactId=' + this.contactId + '; opportunityId=' + this.opportunityId);
            System.debug('url: ' + URL.getSalesforceBaseUrl().toExternalForm());
            System.debug('TIME: init() end:'+System.currentTimeMillis());
        } catch (Exception e) {
            this.activeStep = GlobalUtils.E2ERuSteps.ErrorMessage.name();
            this.errorStep = GlobalUtils.E2ERuErrorSteps.SystemError.name();

            String notificationMessage = '<br/>E2E method init(): ' + String.valueOf(e.getMessage());
            ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
        }
    }

    /*******************************************************************************
    *  Name            : readUrlParams()
    *  Summary         : work with url params and set up base parameters
    *  CreatedDate     : 25/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void readUrlParams() {
        Map<String, String> urlParams = ApexPages.CurrentPage().getParameters();
        System.debug('Parameters: ' + urlParams);
        String countryParam = ApexPages.CurrentPage().getParameters().get('country');
        if (countryParam != null && countryParam != '' && countryParam == GlobalUtils.FleetcorCountries.Russia.name()) {
            this.country = countryParam;
        } else {
            this.country = 'Russia';
        }

        String productParam = ApexPages.CurrentPage().getParameters().get('product');
        if (productParam != null && productParam != '') { // заменить значение продукта
            this.formParams.product = productParam;
        }
        this.productNotChange = true;

        // параметр промокода (при его наличии предзаполняем поля и закрываем для редактирования)
        String promoParam = ApexPages.CurrentPage().getParameters().get('promo');
        if (promoParam != null && promoParam != '') {
            this.formParams.promoCode = promoParam;
        } else {
            this.formParams.promoCode = '';
        }

       /* if(urlParams.get('cphone') != null && urlParams.get('cemail') != null){
            if(urlParams.get('cphone') != '' && urlParams.get('cemail') != ''){
                this.formParams.sourceIfSelfSourced = 'Web-To-Lead';
            }
        } */

        this.formParams.sourcePP = '';
        this.formParams.source = 'PetrolPlus';
        this.formParams.promoCode = '';
        String sourceParam = ApexPages.CurrentPage().getParameters().get('source');
        if (sourceParam != null && sourceParam != '') {
            E2E_Sources__c sourceObject = E2E_Sources__c.getValues(sourceParam);
            if (sourceObject != null){
                this.formParams.source = sourceParam;
                this.offer = sourceObject.Offer__c;
                this.formParams.sourcePP = sourceParam;
                this.productNotChange = true;
                this.formParams.product = sourceObject.Product__c;
                if(sourceObject.Promo__c != null){
                    this.formParams.promoCode = sourceObject.Promo__c;
                }
                System.debug('*** PromoCode in formParam DEBUG ' + this.formParams.promoCode);
            } else {
                this.offer = 'PetrolPlus';
            }
        } else {
            this.offer = 'PetrolPlus';
        }
        this.formParams.offer = this.offer;

        if (this.formParams.product == null || this.formParams.product == ''){
            this.formParams.product = 'PetrolPlus_Rover';
        }

        String splitTesting = ApexPages.CurrentPage().getParameters().get('split');
        if (splitTesting != null && splitTesting != '') {
            E2E_Split_Testing__c splitObject = E2E_Split_Testing__c.getValues(splitTesting);
            if (splitObject != null){
                this.formParams.splitTesting = splitObject.Name;
                this.formParams.productSplitTesting = splitObject.Target__c;
            } else {
                this.formParams.splitTesting = '';
                this.formParams.productSplitTesting = this.formParams.product;
            }
        } else {
            this.formParams.splitTesting = '';
            this.formParams.productSplitTesting = this.formParams.product;
        }

        System.debug('**** URL PARAMS: country=' + this.country + ', product=' + this.formParams.product + ', source=' + this.offer + ', promo=' + this.formParams.promoCode+', product=' + this.formParams.product + ', productSplitTesting=' + this.formParams.productSplitTesting);

        String encryptedParams = ApexPages.CurrentPage().getParameters().get('link');
        if (encryptedParams != null && encryptedParams != '') {
            encryptedParams = encryptedParams.replaceAll('(\\s|%2B)', '+');
            if (E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu') == null) {
                throw new E2EFormRuException('The link is corrupted. Please contact your administrator');
            }
            Blob key = EncodingUtil.base64Decode(E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu').AES256_Key__c);
            Blob dest = EncodingUtil.base64Decode(encryptedParams);
            Blob decrypted = Crypto.decryptWithManagedIv('AES256', key, dest);
            String decryptedParams = decrypted.toString();
            if (decryptedParams != null) {
                String formDataIdParam = decryptedParams.substringBefore('-');
                String activeStepParam = decryptedParams.substringAfter('-');

                if (formDataIdParam != '' && activeStepParam != '') {
                    this.formDataId = Id.valueOf(formDataIdParam);
                    this.activeStep = activeStepParam;
                } else {
                    throw new E2EFormRuException('The link is corrupted. Please contact your administrator');
                }
                System.debug('**** DECODED URL PARAMS: formDataId=' + this.formDataId + ', activeStep=' + this.activeStep);
            }
        }
    }

    /*******************************************************************************
    *  Name            : setDeviceType()
    *  Summary         : set Device Type
    *  CreatedDate     : 28/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void setDeviceType() {
        if(ApexPages.currentPage().getParameters().get('deviceType') == 'Desktop'){
            this.deviceType = GlobalUtils.DeviceType.Desktop;
            this.formParams.deviceType = GlobalUtils.DeviceType.Desktop.name();
        } else {
            this.deviceType = GlobalUtils.DeviceType.Mobile;
            this.formParams.deviceType = GlobalUtils.DeviceType.Mobile.name();

        }
        System.debug('deviceType: ' +this.deviceType);
    }

    /*******************************************************************************
    *  Name            : returnFormService(String countryName)
    *  Summary         : get General Form Service
    *  CreatedDate     : 12/07/2018
    *  ModifiedDate    : -
    *  Parameters      : String countryName
    *  Returns         : E2EFormRuService formService
    ******************************************************************************/
    public E2EFormRuService returnFormService(String countryName) {
        E2EFormRuService formService;
        if (countryName == GlobalUtils.FleetcorCountries.Russia.name()) {
            formService = new E2EFormRuServiceImpl();
        }
        return formService;
    }

    /*******************************************************************************
    *  Name            : returnSparkWebService(String countryName)
    *  Summary         : get Spark Web Service
    *  CreatedDate     : 09/08/2018
    *  ModifiedDate    : -
    *  Parameters      : String countryName
    *  Returns         : SparkWebService sparkWebService
    ******************************************************************************/
    public SparkWebService returnSparkWebService(String countryName) {
        SparkWebService sparkWebService;
        if (countryName == GlobalUtils.FleetcorCountries.Russia.name()) {
            sparkWebService = new SparkWebServiceImpl();
        }
        return sparkWebService;
    }

    /*******************************************************************************
    *  Name            : returnCrmWebService(String countryName)
    *  Summary         : get Crm Web Service
    *  CreatedDate     : 30/08/2018
    *  ModifiedDate    : -
    *  Parameters      : String countryName
    *  Returns         : CrmWebService crmWebService
    ******************************************************************************/
    public CrmWebService returnCrmWebService(String countryName) {
        CrmWebService crmWebService;
        if (countryName == GlobalUtils.FleetcorCountries.Russia.name()) {
            crmWebService = new CrmWebServiceImpl();
        }
        return crmWebService;
    }

    /*******************************************************************************
    *  Name            : returnReportWebService(String countryName)
    *  Summary         : get Report Web Service
    *  CreatedDate     : 30/08/2018
    *  ModifiedDate    : -
    *  Parameters      : String countryName
    *  Returns         : ReportWebService reportWebService
    ******************************************************************************/
    public ReportWebService returnReportWebService(String countryName) {
        ReportWebService reportWebService;
        if (countryName == GlobalUtils.FleetcorCountries.Russia.name()) {
            reportWebService = new ReportWebServiceImpl();
        }
        return reportWebService;
    }

    /*******************************************************************************
    *  Name            : returnScoringWebService(String countryName)
    *  Summary         : get Scoring Web Service
    *  CreatedDate     : 23/08/2018
    *  ModifiedDate    : -
    *  Parameters      : String countryName
    *  Returns         : ScoringWebService scoringWebService
    ******************************************************************************/
    public ScoringWebService returnScoringWebService(String countryName) {
        ScoringWebService scoringWebService;
        if (countryName == GlobalUtils.FleetcorCountries.Russia.name()) {
            scoringWebService = new ScoringWebServiceImpl();
        }
        return scoringWebService;
    }

    /*******************************************************************************
    *  Name            : returnTransitWebService(String countryName)
    *  Summary         : get Transit Web Service
    *  CreatedDate     : 07/09/2018
    *  ModifiedDate    : -
    *  Parameters      : String countryName
    *  Returns         : TransitWebService transitWebService
    ******************************************************************************/
    public TransitWebService returnTransitWebService(String countryName) {
        TransitWebService transitWebService;
        if (countryName == GlobalUtils.FleetcorCountries.Russia.name()) {
            transitWebService = new TransitWebServiceImpl();
        }
        return transitWebService;
    }

    /*******************************************************************************
    *  Name            : returnMZKWebService(String countryName)
    *  Summary         : get MZK Web Service
    *  CreatedDate     : 11/09/2018
    *  ModifiedDate    : -
    *  Parameters      : String countryName
    *  Returns         :  MZKWebService mzkWebService
    ******************************************************************************/
    public MZKWebService returnMZKWebService(String countryName) {
        MZKWebService mzkWebService;
        if (countryName == GlobalUtils.FleetcorCountries.Russia.name()) {
            mzkWebService = new MZKWebServiceImpl();
        }
        return mzkWebService;
    }

    /*******************************************************************************
   *  Name            : updateSobjects
   *  Summary         : update sobject records
   *  CreatedDate     : 25/07/2018
   *  ModifiedDate    : -
   *  Parameters      : -
   *  Returns         : -
   ******************************************************************************/
    private void createSObjectsRecords() {
        if(!Test.isRunningTest()){
            try {
                system.debug('INIT='+system.currentTimeMillis());
                doDisabledTriggers();
                if (accountId == null || opportunityId == null || contactId == null || formDataId == null) {
                    accountId = this.formService.createAccount(formParams);
                    System.debug('***** created accountId=' + accountId+' '+system.currentTimeMillis());

                    opportunityId = this.formService.createOpportunity(accountId, formParams);
                    System.debug('***** created opportunityId=' + opportunityId+' '+system.currentTimeMillis());

                    contactId = this.formService.createContact(accountId, pagesContentMap, formParams);
                    this.formService.updateOpportunityContactRole(opportunityId, contactId, 'Decision Maker', true);
                    System.debug('***** created contactId=' + contactId+' '+system.currentTimeMillis());

                    formDataId = this.formService.createFormDataRecord(accountId, contactId, opportunityId, pagesContentMap, formParams);
                    System.debug('***** created formDataId=' + formDataId+' '+system.currentTimeMillis());
                } else {
                    formService.updateContact(contactId, pagesContentMap, formParams, activeStep);
                    System.debug('SOURCE **  ' +this.formParams.source);
                    formService.updateFormData(formDataId, pagesContentMap, formParams, activeStep, this.formParams.source);
                }
                system.debug('FINISH='+system.currentTimeMillis());
            } catch (Exception e) {
                String notificationMessage = '<br/>E2E method createSObjectsRecords(): ' + 'formDataId=' + formDataId
                        + 'accountId=' + accountId + 'opportunityId=' + opportunityId + 'contactId=' + contactId
                        + String.valueOf(e.getMessage());
                ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));

                throw new E2EFormRuException(notificationMessage);
            }
        }
    }

    /*******************************************************************************
    *  Name            : updateSobjects
    *  Summary         : update sobject records
    *  CreatedDate     : 25/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    private void updateSObjectsRecords() {
        try {
            System.debug('TIME: updateSObjectsRecords() begin:'+System.currentTimeMillis());
            if (formDataId != null && accountId != null && contactId != null && opportunityId != null) {
                doDisabledTriggers();

                formService.updateFormData(formDataId, pagesContentMap, formParams, activeStep, this.formParams.source);

                formService.updateAccount(accountId, pagesContentMap, formParams, activeStep);

                formService.updateOpportunity(opportunityId, pagesContentMap, formParams, activeStep);

                formService.updateContact(contactId, pagesContentMap, formParams, activeStep);
            }
            System.debug('TIME: updateSObjectsRecords() end:'+System.currentTimeMillis());
        } catch (Exception e) {
            String notificationMessage = '<br/>E2E method updateSObjectsRecords(): ' + String.valueOf(e.getMessage());
            ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));

            throw new E2EFormRuException(notificationMessage);
        }
    }

    /*******************************************************************************
    *  Name            : updateContactPhone
    *  Summary         : update contact phone
    *  CreatedDate     : 17/09/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void updateContactPhone() {
        try {
            deduplicationCurrentClient();
            createSObjectsRecords();
           // this.formService.updateContactPhone(this.contactId, this.pagesContentMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c);
        } catch (Exception e) {
            this.activeStep = GlobalUtils.E2ERuSteps.ErrorMessage.name();
            this.errorStep = GlobalUtils.E2ERuErrorSteps.SystemError.name();

            String notificationMessage = '<br/>E2E method updateContactPhone(): ' + String.valueOf(e.getMessage());
            ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
        }
    }

    /******************************************************************************
    *  Name            : doDisabledTriggers()
    *  Summary         : disabling SF triggers
    *  CreatedDate     : 29/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void doDisabledTriggers() {
        AccountTriggerHandler.enablesTrigger = false;
        ContactTriggerHandler.enablesTrigger = false;
        OpportunityTriggerHandler.enablesTrigger = false;

        ContactTriggerHandler.isE2EForm = true;
        OpportunityTriggerHandler.isE2EForm = true;
    }

    /*******************************************************************************
    *  Name            : backToContactDetails
    *  Summary         : back to contact details step
    *  CreatedDate     : 12/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void backToContactDetails() {
        try {
            this.activeStep = GlobalUtils.E2ERuSteps.ContactDetails.name();
            formService.collectContent(this.country, activeStep, pagesContentMap, GlobalUtils.DeviceType.Desktop);
        } catch (Exception e) {
            this.activeStep = GlobalUtils.E2ERuSteps.ErrorMessage.name();
            this.errorStep = GlobalUtils.E2ERuErrorSteps.SystemError.name();

            String notificationMessage = '<br/>E2E method backToContactDetails(): ' + String.valueOf(e.getMessage());
            ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
        }
    }

    /*******************************************************************************
    *  Name            : goToCompanyDetails(String countryName)
    *  Summary         : go to company details step
    *  CreatedDate     : 12/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void goToCompanyDetails() {
        try {
            System.debug('TIME: goToCompanyDetails() begin:'+System.currentTimeMillis());
            this.formParams.contactDetails = GlobalUtils.E2ERuProcessStatus.ContactDetails.name(); // log process
            // Deduplication Lead
            this.formService.duplicateLeadProcess(this.pagesContentMap);
            this.formParams.sfDeduplication1 = ' > ' + GlobalUtils.E2ERuProcessStatus.SFDeduplication1.name(); // log process
            // Deduplication current client
            deduplicationCurrentClient();
            this.formParams.sfDeduplication2 = ' > ' + GlobalUtils.E2ERuProcessStatus.SFDeduplication2.name(); // log process

            createSObjectsRecords();

            this.formParams.encodedURL = getEncodedUrl(this.formDataId, this.activeStep);
            this.formService.updateEncodedUrl(this.opportunityId, this.formDataId, this.formParams);

            this.activeStep = GlobalUtils.E2ERuSteps.CompanyInformation.name();
            formService.collectContent(this.country, activeStep, pagesContentMap, GlobalUtils.DeviceType.Desktop);
            System.debug('TIME: goToCompanyDetails() end:'+System.currentTimeMillis());
        } catch (Exception e) {
            // force update
            this.formService.forceUpdateOpportunity(this.opportunityId, String.valueOf(e.getMessage()));
            this.activeStep = GlobalUtils.E2ERuSteps.ErrorMessage.name();
            this.errorStep = GlobalUtils.E2ERuErrorSteps.SystemError.name();
            String notificationMessage = '<br/>E2E method goToCompanyDetails(): ' + String.valueOf(e.getMessage());
            ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
        }
    }

    /*******************************************************************************
    *  Name            : backToCompanyDetails()
    *  Summary         : back to Company Details step
    *  CreatedDate     : 12/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void backToCompanyInformation() {
        try {
            // reset overdraft
            this.pagesContentMap.get('ORDER').fields.get('PAY OVERDRAFT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'FALSE';

            System.debug('TIME: backToCompanyInformation() begin:'+System.currentTimeMillis());
            this.activeStep = GlobalUtils.E2ERuSteps.CompanyInformation.name();
            formService.collectContent(this.country, activeStep, pagesContentMap, GlobalUtils.DeviceType.Desktop);
            System.debug('TIME: backToCompanyInformation() end:'+System.currentTimeMillis());
        } catch (Exception e) {
            this.activeStep = GlobalUtils.E2ERuSteps.ErrorMessage.name();
            this.errorStep = GlobalUtils.E2ERuErrorSteps.SystemError.name();

            String notificationMessage = '<br/>E2E method backToCompanyInformation(): ' + String.valueOf(e.getMessage());
            ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
        }
    }

    /*******************************************************************************
    *  Name            : goToOrderInformation()
    *  Summary         : go to Order Information step
    *  CreatedDate     : 12/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void goToOrderInformation() {
        Long startTime = System.currentTimeMillis();
        System.debug('TIME: goToOrderInformation() start:'+startTime);
        String inn = this.pagesContentMap.get('COMPANY INFORMATION').fields.get('INN').elementItemsMap.get('DEFAULT VALUE').Value__c;
        String phone = this.pagesContentMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c;
        String email = this.pagesContentMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c;
        String sparkId = '';
        try {
            if (this.pagesContentMap.get('COMPANY INFORMATION').fields.get('INN').elementItemsMap.get('DEFAULT VALUE').Value__c.length() == 10) {
                formParams.isSoleProprietor = false;
            } else if (this.pagesContentMap.get('COMPANY INFORMATION').fields.get('INN').elementItemsMap.get('DEFAULT VALUE').Value__c.length() == 12) {
                formParams.isSoleProprietor = true;
            }

            Boolean isEntryManual = Boolean.valueOf(this.pagesContentMap.get('COMPANY INFORMATION').fields.get('IS MANUAL ENTRY').elementItemsMap.get('DEFAULT VALUE').Value__c);
            if (isEntryManual) {
                // if manual entry send to Inbound
                formParams.sendToInbound = true;
                this.formParams.isManualEntry = true;
                System.debug('**** goToOrderInformation(): isManualEntry = ' + this.formParams.isManualEntry);
                System.debug('**** COMPANY WILL BE SEND TO INBOUND: true');
            }

            this.formParams.getSparkData = ' > ' + GlobalUtils.E2ERuProcessStatus.GetSparkData.name(); // log process

            // Deduplication Account
            System.debug('TIME: DUB deduplicationAccountProcess start: '+System.currentTimeMillis());
            E2EFormRuDeduplicationResult deduplicationResult = this.formService.deduplicationAccountProcess(inn, email, this.accountId, this.contactId, this.opportunityId, this.formDataId);
            System.debug('TIME: DUB deduplicationAccountProcess end: '+System.currentTimeMillis());
            System.debug('*** deduplicationResult.statusCode; -> ' + deduplicationResult.statusCode);
            System.debug('*** deduplicationResult -> ' + deduplicationResult);
            this.formParams.deduplicationStatus = deduplicationResult.statusCode;
            this.formParams.deduplicationStatusInfo = deduplicationResult.getDedupStatusInformation();
            this.formParams.sfDeduplication3 = ' > ' + GlobalUtils.E2ERuProcessStatus.SFDeduplication3.name(); // log process

            if (deduplicationResult.statusCode == GlobalUtils.DeduplicationStatus.Service.name()) {
                // Create new task in CRM System
                CrmTask crmTask = this.formService.prepareCrmRequest(phone, email, inn, deduplicationResult.sfAccount.Opportunities);
                this.crmWebService.createTask(inn, crmTask);
                this.formParams.sendCrmRequest = ' > ' + GlobalUtils.E2ERuProcessStatus.SendCrmRequest.name(); // log process
            }

            System.debug('TIME: DUB transferCustomer start: '+System.currentTimeMillis());
            this.formService.transferCustomer(deduplicationResult);
            System.debug('TIME: DUB transferCustomer end: '+System.currentTimeMillis());

            // Account, который был определен как основной в процессе дедуюликации
            System.debug('*** deduplicationResult.e2eAccount.Id =' + deduplicationResult.e2eAccount.Id +' *** current.e2eAccount.Id =' + this.accountId);
            this.accountId = deduplicationResult.e2eAccount.Id;

            this.formParams.encodedURL = getEncodedUrl(this.formDataId, this.activeStep);
            updateSObjectsRecords();

            // Check deduplication status
            if (deduplicationResult.statusCode == GlobalUtils.DeduplicationStatus.Service.name()) {
                System.debug('Go to Service');
                throw new E2EFormRuException('Deduplication result: Go to Service => ' + this.formParams.deduplicationStatus);
            } else if (deduplicationResult.statusCode == GlobalUtils.DeduplicationStatus.Inbound.name()) {
                System.debug('Go to Inbound');
                this.formParams.sendToInbound = true;
                throw new E2EFormRuException('Deduplication result: Go to Inbound => ' + this.formParams.deduplicationStatus); // Change by Ilya I 15.03 (по просьбе Тани К)
            } else if (deduplicationResult.statusCode == GlobalUtils.DeduplicationStatus.KO.name()) {
                System.debug('Go to KO');
                throw new E2EFormRuException('Deduplication result: Go to KO => ' + this.formParams.deduplicationStatus);
            }

            // Create executive person contact
            if (this.formParams.executiveFio != null && this.formParams.executiveFio != '' &&
                    this.formParams.executivePosition != null && this.formParams.executivePosition != '') {
                this.formParams.executiveId = this.formService.createEmployeeContact(this.accountId, this.formParams.executiveFio, this.formParams.executivePosition);
            }

            this.activeStep = GlobalUtils.E2ERuSteps.Order.name();
            formService.collectContent(this.country, this.activeStep, pagesContentMap, GlobalUtils.DeviceType.Desktop);

            this.formParams.numberOfTariffsDependency = this.getTariffsDependency();
            this.pagesContentMap.get('ORDER').fields.get('PRODUCTS').elementItemsMap.get('ID').Value__c = this.formParams.product;
            this.pagesContentMap.get('ORDER').fields.get('PRODUCTS').elementItemsMap.get('DEFAULT VALUE').Value__c = this.pagesContentMap.get('ORDER').fields.get('PRODUCTS').offers.get(this.offer).products.get(this.formParams.product).productLabel;
            this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE ADDITIONAL FIELD').Value__c = '';

            System.debug('***** DEBUG formParams.promoCode: ' + this.formParams.promoCode);
            getPromocode(this.formParams.promoCode);

            setAZSLocatorLink(this.formParams.product);

            this.pagesContentMap.get('ORDER').fields.get('PROMOCODE').elementItemsMap.get('DEFAULT VALUE').Value__c = this.formParams.promoCode;

            this.formParams.companyDetails = ' > ' + GlobalUtils.E2ERuProcessStatus.CompanyDetails.name(); // log process
            System.debug('TIME: goToOrderInformation end: '+System.currentTimeMillis());
            System.debug('TIME: goToOrderInformation TOTAL:'+(Long)(System.currentTimeMillis()-startTime));

        } catch (Exception e) {
            if (this.formParams.deduplicationStatus != null &&
                    (this.formParams.deduplicationStatus == GlobalUtils.DeduplicationStatus.Service.name() ||
                     this.formParams.deduplicationStatus == GlobalUtils.DeduplicationStatus.KO.name())) {
                updateSObjectsRecords();
                this.activeStep = GlobalUtils.E2ERuSteps.ErrorMessage.name();
                this.errorStep = GlobalUtils.E2ERuErrorSteps.IsAClient.name();
            }
            else if ( this.formParams.deduplicationStatus != null &&
                    this.formParams.deduplicationStatus == GlobalUtils.DeduplicationStatus.Inbound.name()){
                updateSObjectsRecords();
                this.activeStep = GlobalUtils.E2ERuSteps.ErrorMessage.name();
                this.errorStep = GlobalUtils.E2ERuErrorSteps.Inbound.name();
            } else {
                // force update
                this.formService.forceUpdateOpportunity(this.opportunityId, String.valueOf(e.getMessage()));
                this.activeStep = GlobalUtils.E2ERuSteps.ErrorMessage.name();
                this.errorStep = GlobalUtils.E2ERuErrorSteps.SystemError.name();
            }

            System.debug('**** EXCEPTION: ' + String.valueOf(e.getMessage()) + '\r\n' + 'STACK TRACE: ' + String.valueOf(e.getStackTraceString()));
            String notificationMessage = '<br/>E2E RU method goToOrderInformation(): inn=' + inn + ', sparkId=' + sparkId + ' ' + String.valueOf(e.getMessage());
            ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
        }
    }

    /*******************************************************************************
    *  Name            : getTariffsOnCards()
    *  Summary         : get TariffsOnCards
    *  CreatedDate     : 22/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void getTariffsOnCards() {
        String suffix = ApexPages.currentPage().getParameters().get('suffix');
        getTariffs(suffix);
    }

    /*******************************************************************************
    *  Name            : getTariffsDependency()
    *  Summary         : get TariffsDependency
    *  CreatedDate     : 06/12/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public String getTariffsDependency(){
        if (this.pagesContentMap.get('ORDER').fields.get('PRODUCTS').offers.get(this.offer).products.get(this.formParams.productSplitTesting).tariffs.size() == 2){
            return '999';
        } else {
            return '5';
        }
    }

    /*******************************************************************************
    *  Name            : getTariffs()
    *  Summary         : get tariff
    *  CreatedDate     : 27/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void getTariffs(String suffix) {
        String production = this.pagesContentMap.get('ORDER').fields.get('PRODUCTS').elementItemsMap.get('ID').Value__c;
        Map<String, LongFormTariff> msl = this.pagesContentMap.get('ORDER').fields.get('PRODUCTS').offers.get(this.offer).products.get(this.formParams.productSplitTesting).tariffs;
        System.debug('*********  String suffix  ');
        System.debug(suffix);
        System.debug('*********  Tariffs  ');
        System.debug(msl);
        this.msl_suffix.clear();
        for (String lft : msl.keySet()) {
            System.debug('*********  Tariff  ');
            System.debug(lft);
            if (lft.indexOf(suffix) != -1) {
                System.debug('*********  PUT  ');
                System.debug(lft);
                this.msl_suffix.put(lft, msl.get(lft));
            }
        }
    }

    /*******************************************************************************
    *  Name            : setTariff()
    *  Summary         : set tariff
    *  CreatedDate     : 20/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void setTariff() {
        this.pagesContentMap.get('ORDER').fields.get('PRODUCT TARIFF').elementItemsMap.get('DEFAULT VALUE').Value__c = ApexPages.currentPage().getParameters().get('tariffName');
        this.pagesContentMap.get('ORDER').fields.get('PRODUCT TARIFF').elementItemsMap.get('TARIFF ID').Value__c = ApexPages.currentPage().getParameters().get('tariffID');
        System.debug('tariff: ' + this.pagesContentMap.get('ORDER').fields.get('PRODUCT TARIFF').elementItemsMap.get('DEFAULT VALUE').Value__c);
    }

    /*******************************************************************************
    *  Name            : setProduct()
    *  Summary         : set product
    *  CreatedDate     : 02/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void setProduct() {
        this.pagesContentMap.get('ORDER').fields.get('PRODUCTS').elementItemsMap.get('ID').Value__c = ApexPages.currentPage().getParameters().get('productID');
        this.formParams.product = ApexPages.currentPage().getParameters().get('productID');
        this.formParams.numberOfTariffsDependency = this.getTariffsDependency();
        setAZSLocatorLink(this.formParams.product);
        System.debug('numberOfTariffsDependency : ' + this.formParams.numberOfTariffsDependency);
        System.debug('product : ' + this.pagesContentMap.get('ORDER').fields.get('PRODUCTS').elementItemsMap.get('ID').Value__c);
        //System.debug('product : ' + this.productID);
    }

    /*******************************************************************************
    *  Name            : checkPromocode()
    *  Summary         : checkPromocode
    *  CreatedDate     : 10/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void checkPromocode() {
        String promocode = ApexPages.currentPage().getParameters().get('promocodeName');
        getPromocode(promocode);
    }

    public void getPromocode(String promocode) {
        String productName = this.pagesContentMap.get('ORDER').fields.get('PRODUCTS').elementItemsMap.get('DEFAULT VALUE').Value__c;
        this.pagesContentMap.get('ORDER').fields.get('PROMOCODE').elementItemsMap.get('WARN MESSAGE').Value__c = '';
        if (promocode != null && !promocode.equals('')) {
            E2E_Promocodes__c promocodeObject = E2E_Promocodes__c.getValues(promocode);
            if (promocodeObject != null) {
                if (promocodeObject.Product_Name__c != productName) {
                    this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE INVALID').Value__c = 'Данная акция действует только при заказе карт ' + promocodeObject.Product_Name__c;
                    this.pagesContentMap.get('ORDER').fields.get('PROMOCODE').elementItemsMap.get('WARN MESSAGE').Value__c = 'Данная акция действует только при заказе карт ' + promocodeObject.Product_Name__c;
                    this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE VALUE').Value__c = '';
                    this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE LABEL').Value__c = '';
                    this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE DESCRIPTION TITLE').Value__c = '';
                    this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE DESCRIPTION BODY').Value__c = '';
                    this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE ADDITIONAL FIELD').Value__c = '';
                    this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE CHOOSEN FIELD').Value__c = '';
                } else {
                    this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE VALUE').Value__c = promocodeObject.Name;
                    this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE LABEL').Value__c = String.format(promocodeObject.Promocode_Label__c, new List<String>{GlobalUtils.getE2ERuPartner(this.formParams.source)});
                    this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE DESCRIPTION TITLE').Value__c = promocodeObject.Promocode_Description_Title__c;
                    this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE DESCRIPTION BODY').Value__c = promocodeObject.Promocode_Description_Body__c;
                    if (promocodeObject.Promocode_Additional_Field__c == null || promocodeObject.Supplier_Selection__c == 'False') {
                        this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE ADDITIONAL FIELD').Value__c = '';
                        this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE CHOOSEN FIELD').Value__c = '';
                    } else {
                        String dropdownList = promocodeObject.Promocode_Additional_Field__c;
                        this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE ADDITIONAL FIELD').Value__c = dropdownList;
                        this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE CHOOSEN FIELD').Value__c = dropdownList.split(';')[0].split('@')[0];

                        String listPromocodeItems = this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE ADDITIONAL FIELD').Value__c;
                        Map<String, String> supplies = new Map<String, String>();
                        for (String val : listPromocodeItems.split(';')) {
                            supplies.put(val.split('@')[0], val.split('@')[1]);
                        }
                        String idPromocodeItem = supplies.get(this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE CHOOSEN FIELD').Value__c);
                        this.formParams.promocodeIdInTransit = idPromocodeItem;
                    }
                    this.pagesContentMap.get('ORDER').fields.get('PROMOCODE').elementItemsMap.get('WARN MESSAGE').Value__c = '';
                    this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE INVALID').Value__c = '';
                    System.debug(this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE ADDITIONAL FIELD').Value__c);

                    this.formParams.promocodeName = promocodeObject.Name;
                }
            } else {
                this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE INVALID').Value__c = 'Промокод недействителен';
                this.pagesContentMap.get('ORDER').fields.get('PROMOCODE').elementItemsMap.get('WARN MESSAGE').Value__c = 'Промокод недействителен';
                this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE VALUE').Value__c = '';
                this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE LABEL').Value__c = '';
                this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE DESCRIPTION TITLE').Value__c = '';
                this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE DESCRIPTION BODY').Value__c = '';
                this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE ADDITIONAL FIELD').Value__c = '';
                this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE CHOOSEN FIELD').Value__c = '';
            }
        }
    }

    /*******************************************************************************
    *  Name            : setPromocodeItem()
    *  Summary         : setPromocodeItem
    *  CreatedDate     : 16/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void setPromocodeItem() {
        String namePromocodeItem = ApexPages.currentPage().getParameters().get('promocodeItem');
        this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE CHOOSEN FIELD').Value__c = namePromocodeItem;
        String listPromocodeItems = this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE ADDITIONAL FIELD').Value__c;
        Map<String, String> supplies = new Map<String, String>();
        for (String val : listPromocodeItems.split(';')) {
            supplies.put(val.split('@')[0], val.split('@')[1]);
        }
        String idPromocodeItem = supplies.get(namePromocodeItem);
        this.pagesContentMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE CHOOSEN FIELD ID').Value__c = idPromocodeItem;
        this.formParams.promocodeIdInTransit = idPromocodeItem;
        System.debug('DEBUG ******' + idPromocodeItem);

    }

    /*******************************************************************************
    *  Name            : setAZSLocatorLink()
    *  Summary         : setAZSLocatorLink
    *  CreatedDate     : 28/09/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void setAZSLocatorLink(String locator) {
        E2E_Form_Ru_General_Settings__c generalSettingsObject = E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu');
        String linkLocator = '';
        if (locator.split('_')[1].equals('Rover')) {
            linkLocator = generalSettingsObject.Locator_Rover_url__c;
        }
        if (locator.split('_')[1].equals('Gaz')) {
            linkLocator = generalSettingsObject.Locator_Gaz_url__c;
        }
        if (locator.split('_')[1].equals('Shell')) {
            linkLocator = generalSettingsObject.Locator_Shell_url__c;
        }
        String prevHrefValue;
        Pattern p = Pattern.compile('\"([^\"]*)\"');
        Matcher m = p.matcher(this.pagesContentMap.get('ORDER').fields.get('GIFT LIST').elementItemsMap.get('LIST').Value__c);
        while (m.find()) {
            System.debug(m.group(1));
            prevHrefValue = m.group(1);
        }
        this.pagesContentMap.get('ORDER').fields.get('GIFT LIST').elementItemsMap.get('LIST').Value__c = this.pagesContentMap.get('ORDER').fields.get('GIFT LIST').elementItemsMap.get('LIST').Value__c.replace(prevHrefValue, linkLocator);
    }

    /*******************************************************************************
    *  Name            : backToOrderInformation()
    *  Summary         : back to Order Information step
    *  CreatedDate     : 12/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void backToOrderInformation() {
        try {
            this.pagesContentMap.get('ORDER').fields.get('PAY OVERDRAFT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'FALSE';
            System.debug('TIME: backToOrderInformation() begin:'+System.currentTimeMillis());
            this.activeStep = GlobalUtils.E2ERuSteps.Order.name();
            formService.collectContent(this.country, activeStep, pagesContentMap, GlobalUtils.DeviceType.Desktop);
            System.debug('TIME: backToOrderInformation() end:'+System.currentTimeMillis());
        } catch (Exception e) {
            // force update
            this.formService.forceUpdateOpportunity(this.opportunityId, String.valueOf(e.getMessage()));
            this.activeStep = GlobalUtils.E2ERuSteps.ErrorMessage.name();
            this.errorStep = GlobalUtils.E2ERuErrorSteps.SystemError.name();

            String notificationMessage = '<br/>E2E method backToOrderInformation(): ' + String.valueOf(e.getMessage());
            ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
        }
    }

    /*******************************************************************************
    *  Name            : goToOrderSummary()
    *  Summary         : go to Order Summary step
    *  CreatedDate     : 20/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void goToSummaryOrder() {
        try {
            System.debug('*******************goToSummaryOrder');
            setAZSLocatorLink(this.formParams.product);
            this.formParams.encodedURL = getEncodedUrl(this.formDataId, this.activeStep);
            updateSObjectsRecords();
            this.activeStep = GlobalUtils.E2ERuSteps.SummaryOrder.name();
            formService.collectContent(this.country, activeStep, pagesContentMap, GlobalUtils.DeviceType.Desktop);

            // check pay overdraft conditions
            if (this.formParams.verifiedDecisionCode == '0' && this.pagesContentMap.get('ORDER').fields.get('PAY OVERDRAFT').elementItemsMap.get('DEFAULT VALUE').Value__c == 'TRUE') {
                this.pagesContentMap.get('ORDER').fields.get('PAY OVERDRAFT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'TRUE';
            } else {
                this.pagesContentMap.get('ORDER').fields.get('PAY OVERDRAFT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'FALSE';
            }

            if (this.pagesContentMap.get('ORDER').fields.get('PAY OVERDRAFT').elementItemsMap.get('DEFAULT VALUE').Value__c == 'TRUE') {
                this.pagesContentMap.get('ORDER').fields.get('PAYMENT CONDITIONS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Предоплата с возможностью платного овердрафта';
            } else {
                this.pagesContentMap.get('ORDER').fields.get('PAYMENT CONDITIONS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Предоплата 100%';
            }

            Integer numberOfCards = Integer.valueOf(E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu').Number_of_Cards__c);
            this.formParams.numberOfCardsEntered = Integer.valueOf(this.pagesContentMap.get('ORDER').fields.get('AMOUNT CARD').elementItemsMap.get('DEFAULT VALUE').Value__c);
            if (this.formParams.numberOfCardsEntered > numberOfCards) {
                this.formParams.sendToInbound = true;
                this.formParams.isNumberOfCardsLimit = true;
            }

            System.debug('Summary order: numberOfCardsEntered = ' + this.formParams.numberOfCardsEntered);
            System.debug('Summary order: isNumberOfCardsLimit = ' + this.formParams.isNumberOfCardsLimit);
            System.debug('************ this.formParams.sendToInbound: ' + this.formParams.sendToInbound);
        } catch (Exception e) {
            // force update
            this.formService.forceUpdateOpportunity(this.opportunityId, String.valueOf(e.getMessage()));
            this.activeStep = GlobalUtils.E2ERuSteps.ErrorMessage.name();
            this.errorStep = GlobalUtils.E2ERuErrorSteps.SystemError.name();
            String notificationMessage = '<br/>E2E method goToOrderSummary(): ' + String.valueOf(e.getMessage());
            ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
        }
    }

    /*******************************************************************************
    *  Name            : goBackToSummaryOrder()
    *  Summary         : back to Order Information step
    *  CreatedDate     : 12/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void backToSummaryOrder() {
        try {
            System.debug('TIME: backToSummaryOrder() begin:'+System.currentTimeMillis());
            this.activeStep = GlobalUtils.E2ERuSteps.SummaryOrder.name();
            formService.collectContent(this.country, activeStep, pagesContentMap, GlobalUtils.DeviceType.Desktop);
            System.debug('TIME: backToSummaryOrder() end:'+System.currentTimeMillis());
        } catch (Exception e) {
            // force update
            this.formService.forceUpdateOpportunity(this.opportunityId, String.valueOf(e.getMessage()));
            this.activeStep = GlobalUtils.E2ERuSteps.ErrorMessage.name();
            this.errorStep = GlobalUtils.E2ERuErrorSteps.SystemError.name();
            String notificationMessage = '<br/>E2E method goBackToSummaryOrder(): ' + String.valueOf(e.getMessage());
            ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
        }
    }

    /*******************************************************************************
    *  Name            : goToLegalDetails()
    *  Summary         : go to Legal Details step 4.1
    *  CreatedDate     : 12/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void goToLegalDetails() {
        try {
            System.debug('************ this.formParams.sendToInbound: ' + this.formParams.sendToInbound);
            System.debug('scoringDecisionCode: ' + this.formParams.scoringDecisionCode);
            System.debug('verifiedDecisionCode: ' + this.formParams.verifiedDecisionCode);

            System.debug('TIME: goToLegalDetails() begin: '+System.currentTimeMillis());
            this.formParams.encodedURL = getEncodedUrl(this.formDataId, this.activeStep);
            updateSObjectsRecords();

            if (this.formParams.verifiedDecisionCode == '3' || this.formParams.scoringDecisionCode == '2') {
                System.debug('scoringDecisionCode: ' + this.formParams.scoringDecisionCode);
                System.debug('verifiedDecisionCode: ' + this.formParams.verifiedDecisionCode);
                this.activeStep = GlobalUtils.E2ERuSteps.ErrorMessage.name();
                this.errorStep = GlobalUtils.E2ERuErrorSteps.RefuseToCooperate.name();
                updateSObjectsRecords();
            } else if (this.formParams.verifiedDecisionCode == '1' || this.formParams.verifiedDecisionCode == '4') {
                System.debug('verifiedDecisionCode: ' + this.formParams.verifiedDecisionCode);
                this.activeStep = GlobalUtils.E2ERuSteps.ErrorMessage.name();
                this.errorStep = GlobalUtils.E2ERuErrorSteps.Inbound.name();
                updateSObjectsRecords();

                if (this.formParams.verifiedDecisionCode == '1') {
                    EmailTemplate template = EmailGenerator.getEmailTemplate(
                            GlobalUtils.EmailTemplateDevName.E2E_RU_Coordination_With_Risk_Management_Department,
                            new Map<String, Object> {
                                '/$domainUrl$/' => E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu').Domain_Url__c,
                                '/$opportunity.Id$/' => this.opportunityId
                            }
                    );
                    this.formService.sendE2ENotification(template.HtmlValue, template.Subject, GlobalUtils.E2ERuGroupsNotification.CallCenter);

                    System.debug('SUBJECT: ' + template.Subject);
                    System.debug('BODY: ' + template.HtmlValue);
                    //TODO: убрать закомментированное когда шаблоны будут стабильно работать на проде
//                    String body = this.formService.getEmailBodyCoordinationWithRiskManagementDepartment(this.opportunityId);
//                    this.formService.sendE2ENotification(body, 'Russia E2E Дополнительное согласование', GlobalUtils.E2ERuGroupsNotification.CallCenter);
                } else if (this.formParams.verifiedDecisionCode == '4') {
                    EmailTemplate template = EmailGenerator.getEmailTemplate(
                            GlobalUtils.EmailTemplateDevName.E2E_RU_Reseller,
                            new Map<String, Object> {
                                    '/$domainUrl$/' => E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu').Domain_Url__c,
                                    '/$opportunity.Id$/' => this.opportunityId
                            }
                    );
                    System.debug('SUBJECT: ' + template.Subject);
                    System.debug('BODY: ' + template.HtmlValue);
                    this.formService.sendE2ENotification(template.HtmlValue, template.Subject, GlobalUtils.E2ERuGroupsNotification.CallCenter);
                    //TODO: убрать закомментированное когда шаблоны будут стабильно работать на проде
//                    String body = this.formService.getEmailBodyForReseller(this.opportunityId);
//                    this.formService.sendE2ENotification(body, 'Russia E2E Дополнительное согласование', GlobalUtils.E2ERuGroupsNotification.CallCenter);
                }
            } else {
                this.activeStep = GlobalUtils.E2ERuSteps.LegalDetails.name();
                formService.collectContent(this.country, activeStep, pagesContentMap, GlobalUtils.DeviceType.Desktop);
                this.formService.collectDataFromSpark(this.formDataId, this.accountId, this.formParams);

                this.pagesContentMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('CITY').Value__c = this.formParams.citySpark;
                this.pagesContentMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('POSTAL CODE').Value__c = this.formParams.postCodeSpark;
                this.pagesContentMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('STATE').Value__c = this.formParams.regionSpark;
                this.pagesContentMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('STREET').Value__c = this.formParams.streetSpark;
                this.pagesContentMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('HOUSE NUMBER').Value__c = formParams.billingApartment;

                if (this.pagesContentMap.get('COMPANY INFORMATION').fields.get('INN').elementItemsMap.get('DEFAULT VALUE').Value__c.length() == 10) {
                    this.pagesContentMap.get('LEGAL DETAILS').fields.get('OGRN').elementItemsMap.get('DEFAULT VALUE').Value__c = this.formParams.ogrnSpark;
                    this.pagesContentMap.get('LEGAL DETAILS').fields.get('OKPO').elementItemsMap.get('DEFAULT VALUE').Value__c = this.formParams.okpoSpark;
                    this.pagesContentMap.get('LEGAL DETAILS').fields.get('KPP').elementItemsMap.get('DEFAULT VALUE').Value__c = this.formParams.kppSpark;
                    this.pagesContentMap.get('LEGAL DETAILS').fields.get('EXECUTIVE PERSON').elementItemsMap.get('DEFAULT VALUE').Value__c = this.formParams.executiveFio;
                    this.pagesContentMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = this.formParams.legalAddressSpark;
                    this.pagesContentMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS ADDITIONALLY').elementItemsMap.get('DEFAULT VALUE').Value__c = this.formParams.legalAddressAdditionally;
                    this.pagesContentMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = this.formParams.postalAddress;
                    this.pagesContentMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS ADDITIONALLY').elementItemsMap.get('DEFAULT VALUE').Value__c = this.formParams.postalAddressAdditionally;
                    this.pagesContentMap.get('LEGAL DETAILS').fields.get('EXECUTIVE PERSON POSITION').elementItemsMap.get('DEFAULT VALUE').Value__c = this.formParams.executivePosition;
                } else if (this.pagesContentMap.get('COMPANY INFORMATION').fields.get('INN').elementItemsMap.get('DEFAULT VALUE').Value__c.length() == 12) {
                    this.pagesContentMap.get('LEGAL DETAILS').fields.get('OGRNIP').elementItemsMap.get('DEFAULT VALUE').Value__c = this.formParams.ogrnipSpark;
                    this.pagesContentMap.get('LEGAL DETAILS').fields.get('OKPO').elementItemsMap.get('DEFAULT VALUE').Value__c = this.formParams.okpoSpark;
                    this.pagesContentMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = '';
                    this.pagesContentMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS ADDITIONALLY').elementItemsMap.get('DEFAULT VALUE').Value__c = '';
                    this.pagesContentMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = '';
                    this.pagesContentMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS ADDITIONALLY').elementItemsMap.get('DEFAULT VALUE').Value__c = '';
                }

                if(this.sparkCompanyNoDataFound == true) {
                    this.pagesContentMap.get('LEGAL DETAILS').fields.get('REWRITE DEFAULT SPARK VALUES').elementItemsMap.get('DEFAULT VALUE').Value__c = 'TRUE';
                } else {
                    this.pagesContentMap.get('LEGAL DETAILS').fields.get('REWRITE DEFAULT SPARK VALUES').elementItemsMap.get('DEFAULT VALUE').Value__c = 'FALSE';
                }

                this.formParams.cardOrderDetails = ' > ' + GlobalUtils.E2ERuProcessStatus.CardOrderDetails.name(); // log process
                System.debug('TIME: goToLegalDetails() end: '+System.currentTimeMillis());
            }

        } catch (Exception e) {
            // force update
            this.formService.forceUpdateOpportunity(this.opportunityId, String.valueOf(e.getMessage()));
            this.activeStep = GlobalUtils.E2ERuSteps.ErrorMessage.name();
            this.errorStep = GlobalUtils.E2ERuErrorSteps.SystemError.name();
            String notificationMessage = '<br/>E2E method goToLegalDetails(): ' + String.valueOf(e.getMessage());
            ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
        }
    }

    /*******************************************************************************
    *  Name            : returnDataSpark()
    *  Summary         : return Data Spark
    *  CreatedDate     : 21/09/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void returnDataSpark() {
        if (this.pagesContentMap.get('COMPANY INFORMATION').fields.get('INN').elementItemsMap.get('DEFAULT VALUE').Value__c.length() == 10) {
            this.pagesContentMap.get('LEGAL DETAILS').fields.get('OGRN').elementItemsMap.get('DEFAULT VALUE').Value__c = this.formParams.ogrnSpark;
            this.pagesContentMap.get('LEGAL DETAILS').fields.get('KPP').elementItemsMap.get('DEFAULT VALUE').Value__c = this.formParams.kppSpark;
            this.pagesContentMap.get('LEGAL DETAILS').fields.get('OKPO').elementItemsMap.get('DEFAULT VALUE').Value__c = this.formParams.okpoSpark;
            this.pagesContentMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = this.formParams.legalAddressSpark;
            this.pagesContentMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS ADDITIONALLY').elementItemsMap.get('DEFAULT VALUE').Value__c = '';

            this.pagesContentMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('CITY').Value__c = this.formParams.citySpark;
            this.pagesContentMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('POSTAL CODE').Value__c = this.formParams.postCodeSpark;
            this.pagesContentMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('STATE').Value__c = this.formParams.regionSpark;
            this.pagesContentMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('STREET').Value__c = this.formParams.streetSpark;
            this.pagesContentMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('HOUSE NUMBER').Value__c = formParams.billingApartment;

        } else {
            this.pagesContentMap.get('LEGAL DETAILS').fields.get('OGRNIP').elementItemsMap.get('DEFAULT VALUE').Value__c = this.formParams.ogrnipSpark;
            this.pagesContentMap.get('LEGAL DETAILS').fields.get('OKPO').elementItemsMap.get('DEFAULT VALUE').Value__c = this.formParams.okpoSpark;
        }
    }

    /*******************************************************************************
    *  Name            : backToLegalDetails()
    *  Summary         : back to Legal Details step
    *  CreatedDate     : 12/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void backToLegalDetails() {
        try {
            System.debug('TIME: backToLegalDetails() begin: '+System.currentTimeMillis());
            this.activeStep = GlobalUtils.E2ERuSteps.LegalDetails.name();
            formService.collectContent(this.country, activeStep, pagesContentMap, GlobalUtils.DeviceType.Desktop);
            System.debug('TIME: backToLegalDetails() end: '+System.currentTimeMillis());
        } catch (Exception e) {
            // force update
            this.formService.forceUpdateOpportunity(this.opportunityId, String.valueOf(e.getMessage()));
            this.activeStep = GlobalUtils.E2ERuSteps.ErrorMessage.name();
            this.errorStep = GlobalUtils.E2ERuErrorSteps.SystemError.name();
            String notificationMessage = '<br/>E2E method backToLegalDetails(): ' + String.valueOf(e.getMessage());
            ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
        }
    }

    /*******************************************************************************
    *  Name            : goToPaymentDetails()
    *  Summary         : go to Payment Details step 4.2
    *  CreatedDate     : 12/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void goToPaymentDetails() {
        try {
            System.debug('TIME: goToPaymentDetails() begin: '+System.currentTimeMillis());
            this.formParams.encodedURL = getEncodedUrl(this.formDataId, this.activeStep);
            updateSObjectsRecords();

            if (Boolean.valueOf(this.pagesContentMap.get('LEGAL DETAILS').fields.get('REWRITE DEFAULT SPARK VALUES').elementItemsMap.get('DEFAULT VALUE').Value__c) == true) {
                this.formParams.sendToInbound = true;
                this.formParams.isManualEntry = true;
                System.debug('Legal Details: ' + this.formParams.sendToInbound);
                System.debug('Legal Details: isManualEntry = ' + this.formParams.isManualEntry);
            }

            if (this.formParams.isSoleProprietor != true && this.formParams.executiveId != null && this.formParams.executiveId != '') {
                // Update execute person
                this.formService.updateEmployeeContact(
                        this.formParams.executiveId,
                        this.pagesContentMap.get('LEGAL DETAILS').fields.get('EXECUTIVE PERSON').elementItemsMap.get('DEFAULT VALUE').Value__c,
                        this.pagesContentMap.get('LEGAL DETAILS').fields.get('EXECUTIVE PERSON POSITION').elementItemsMap.get('DEFAULT VALUE').Value__c);
                // Update OpportunityContactRole for execute person
                this.formService.updateOpportunityContactRole(this.opportunityId, this.formParams.executiveId, 'Decision Maker', false);
            }

            this.activeStep = GlobalUtils.E2ERuSteps.PaymentDetails.name();
            formService.collectContent(this.country, activeStep, pagesContentMap, GlobalUtils.DeviceType.Desktop);
            this.pagesContentMap.get('PAYMENT DETAILS').fields.get('PREPAYMENT AMOUNT').elementItemsMap.get('DEFAULT VALUE').Value__c = String.valueOf(Integer.valueOf(this.pagesContentMap.get('ORDER').fields.get('AMOUNT CARD').elementItemsMap.get('DEFAULT VALUE').Value__c) * 2000);
            this.formParams.legalDetails = ' > ' + GlobalUtils.E2ERuProcessStatus.LegalDetails.name(); // log process
            System.debug('TIME: goToPaymentDetails() end: '+System.currentTimeMillis());
        } catch (Exception e) {
            // force update
            this.formService.forceUpdateOpportunity(this.opportunityId, String.valueOf(e.getMessage()));
            this.activeStep = GlobalUtils.E2ERuSteps.ErrorMessage.name();
            this.errorStep = GlobalUtils.E2ERuErrorSteps.SystemError.name();
            String notificationMessage = '<br/>E2E method goToPaymentDetails(): ' + String.valueOf(e.getMessage());
            ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
        }
    }

    /*******************************************************************************
    *  Name            : goToCongratulations()
    *  Summary         : go to Congratulations step
    *  CreatedDate     : 12/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void goToCongratulations() {
        try {
            // Update with step PaymentDetails
            if( formParams.isBankInformationInvalid){
                formParams.sendToInbound = true;
                formParams.isManualEntry = true;
            }

            this.formParams.paymentDetails = ' > ' + GlobalUtils.E2ERuProcessStatus.PaymentDetails.name();
            updateSObjectsRecords();

            // ASYNC : Generate Contract , Create Transit Cont, Create MZK proposal (Depending of formParams.sendToInbound)
            system.enqueueJob(new E2EAsyncSenderRequests(this.formDataId, this.formParams, this.pagesContentMap));

            if (this.formParams.sendToInbound == false) {
                System.debug('******* GO TO CONGRATULATIONS *******');
                this.activeModalWindow = null;
                this.activeStep = GlobalUtils.E2ERuSteps.Congratulations.name();
                updateSObjectsRecords();

                formService.collectContent(this.country, activeStep, pagesContentMap, GlobalUtils.DeviceType.Desktop);
                this.pagesContentMap.get('CONGRATULATIONS').fields.get('ORDER NUMBER BLOCK').elementItemsMap.get('VALUE').Value__c = this.formParams.formDataName;
            } else {
                System.debug('******* GO TO INBOUND *******');
                this.activeModalWindow = null;
                this.activeStep = GlobalUtils.E2ERuSteps.ErrorMessage.name();
                this.errorStep = GlobalUtils.E2ERuErrorSteps.Inbound.name();

                // Send Notification
                if (this.formParams.isNumberOfCardsLimit) {
                    //нотификация если введено больше 10 карт
                    EmailTemplate emailTemplate = EmailGenerator.getEmailTemplate(
                            GlobalUtils.EmailTemplateDevName.E2E_RU_Transfer_To_KO_More_10_Cards,
                            new Map<String, Object> {
                                    '/$domainUrl$/' => E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu').Domain_Url__c,
                                    '/$opportunity.Id$/' => opportunityId,
                                    '/$isManualEntry$/' => this.formParams.isManualEntry ? 'Да' : 'Нет',
                                    '/$cardsNumber$/' => this.formParams.numberOfCardsEntered
                            }
                    );
                    this.formService.sendE2ENotification(emailTemplate.HtmlValue, emailTemplate.Subject, GlobalUtils.E2ERuGroupsNotification.CallCenter);
                    //TODO: убрать закомментированное когда шаблоны будут стабильно работать на проде
//                    String body = formService.getEmailBodyTransferToKOMore10Cards(this.formParams.isManualEntry, this.formParams.numberOfCardsEntered, opportunityId);
//                    this.formService.sendE2ENotification(body, 'Russia E2E Перевод в KO', GlobalUtils.E2ERuGroupsNotification.CallCenter);

                } else {
                    if (this.formParams.isManualEntry) {
                        // нотификация если был ручной ввод
                        EmailTemplate emailTemplate = EmailGenerator.getEmailTemplate(
                                GlobalUtils.EmailTemplateDevName.E2E_RU_Transfer_To_KO_Manual_Entry,
                                new Map<String, Object> {
                                        '/$domainUrl$/' => E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu').Domain_Url__c,
                                        '/$opportunity.Id$/' => opportunityId
                                }
                        );
                        this.formService.sendE2ENotification(emailTemplate.HtmlValue, emailTemplate.Subject, GlobalUtils.E2ERuGroupsNotification.CallCenter);
                        //TODO: убрать закомментированное когда шаблоны будут стабильно работать на проде
//                        String body = formService.getEmailBodyTransferToKOManualEntry(opportunityId);
//                        this.formService.sendE2ENotification(body, 'Russia E2E Перевод в KO', GlobalUtils.E2ERuGroupsNotification.CallCenter);
                    }
                }
            }
        } catch (Exception e) {
            // force update
            this.formService.forceUpdateOpportunity(this.opportunityId, String.valueOf(e.getMessage()));
            this.activeModalWindow = null;
            this.activeStep = GlobalUtils.E2ERuSteps.ErrorMessage.name();
            this.errorStep = GlobalUtils.E2ERuErrorSteps.SystemError.name();
            String notificationMessage = '<br/>E2E method goToCongratulations(): ' + String.valueOf(e.getMessage());
            ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
        }
    }

    /*******************************************************************************
    *  Name            : initChatSetup()
    *  Summary         : init chat start settings
    *  CreatedDate     : 12/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void initChatSetup() {
        chatService = new LFChatService();
        chatService.setChatDefaultSettings('Russia');
        chatButtonId = chatService.chatButtonId;
        chatDeploymentId = chatService.chatDeploymentId;
        chatDeploymentJsURL = chatService.chatDeploymentJsURL;
        chatURL = chatService.chatURL;

        chatService.setPageMap(country);
        pageMapChat = chatService.getPagesMap();
        prepareOnlineChat();
    }

    /*******************************************************************************
    *  Name            : setFlagChatToOpportunity()
    *  Summary         : set flag chat to opportunity
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @RemoteAction
    global static void setFlagChatToOpportunity(String oppId, String activeStep, String activeSubStep, String modeOfChat) {
        if (modeOfChat != '') {
            LFChatService.setFlagChatToOpportunity(oppId, modeOfChat, 0, activeSubStep);
        }
    }

    /*******************************************************************************
    *  Name            : saveOfflineChatLog()
    *  Summary         : save offline chat log
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @RemoteAction
    global static void saveOfflineChatLog(String oppId, String conId, String activeStep, String activeSubStep, String textBody) {
        LFChatService.saveOfflineChatLog(textBody, '', 0, activeSubStep, 'Russia', oppId, conId);
    }

    /*******************************************************************************
    *  Name            : prepareOnlineChat()
    *  Summary         : prepare Online chat
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void prepareOnlineChat() {
        String clientNameToChat = '';
        if (contactId != null) {
            Contact contact = formService.getContactById(contactId);
            clientNameToChat = ' ' + contact.Salutation + ' ' + contact.LastName;
        }
        chatFirstMessage = chatService.getFirstChatMessage(country, 0, activeStep, clientNameToChat);
    }

    /*******************************************************************************
    *  Name            : sendExceptionEmail(String methodName, Exception excpt)
    *  Summary         : send exception email
    *  CreatedDate     : 28/05/2018
    *  ModifiedDate    : -
    *  Parameters      : String methodName, Exception excpt
    *  Returns         : void
    ******************************************************************************/
    public void sendExceptionEmail(String methodName, Exception excpt) {
        try {
            String notificationMessage = '<br/>E2E method ' + methodName + ': ' + String.valueOf(excpt.getMessage());
            if (this.accountId != null) {
                notificationMessage += '<br/>Account Id: ' + this.accountId;
            }
            if (this.contactId != null) {
                notificationMessage += '<br/>Contact Id: ' + this.contactId;
            }
            if (this.opportunityId != null) {
                notificationMessage += '<br/>Opportunity Id: ' + this.opportunityId;

                Opportunity opportunity = formService.getOpportunityById(opportunityId);
                opportunity.E2E_Errors__c = (opportunity.E2E_Errors__c != null ? opportunity.E2E_Errors__c + '\n' + String.valueOf(excpt.getMessage()) : String.valueOf(excpt.getMessage()));
                update opportunity;
            }
            ExceptionLogger.sendException(notificationMessage, String.valueOf(excpt.getStackTraceString()));
        } catch (Exception e) {
            String notificationMessage = '<br/>E2E method sendExceptionEmail(): ' + String.valueOf(e.getMessage());
            ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
        }
    }

    /*******************************************************************************
    *  Name            : printAgreement()
    *  Summary         : opens modal window to print Agreement
    *  CreatedDate     : 26/07/2018
    *  ModifiedDate    : -
    *  Parameters      : none
    *  Returns         : void
    ******************************************************************************/
    public void printAgreement() {
        this.activeModalWindow = GlobalUtils.E2ERuActiveModalWindows.PrintAgreement.name();
    }

    /*******************************************************************************
    *  Name            : closeModal()
    *  Summary         : closes modal window
    *  CreatedDate     : 26/07/2018
    *  ModifiedDate    : -
    *  Parameters      : none
    *  Returns         : void
    ******************************************************************************/
    public void closeModal() {
        this.activeModalWindow = null;
    }

    /*******************************************************************************
    *  Name            : showPreAgreement()
    *  Summary         : opens modal window to show PreAgreement
    *  CreatedDate     : 30/07/2018
    *  ModifiedDate    : -
    *  Parameters      : none
    *  Returns         : void
    ******************************************************************************/
    public void showPreAgreement() {
        this.activeModalWindow = GlobalUtils.E2ERuActiveModalWindows.ShowPreAgreement.name();
    }

    /*******************************************************************************
    *  Name            : showPersonalInfoPolicy()
    *  Summary         : opens modal window to show Personal Information Processing Policies
    *  CreatedDate     : 30/07/2018
    *  ModifiedDate    : -
    *  Parameters      : none
    *  Returns         : void
    ******************************************************************************/
    public void showPersonalInfoPolicy() {
        this.activeModalWindow = GlobalUtils.E2ERuActiveModalWindows.PersonalInfoPolicy.name();
    }

    /*******************************************************************************
    *  Name            : showSalesPromotion()
    *  Summary         : opens modal window to show Sales Promotion Policies
    *  CreatedDate     : 30/07/2018
    *  ModifiedDate    : -
    *  Parameters      : none
    *  Returns         : void
    ******************************************************************************/
    public void showSalesPromotion() {
        this.activeModalWindow = GlobalUtils.E2ERuActiveModalWindows.SalesPromotion.name();
    }

    /*******************************************************************************
    *  Name            : showWarningBeforeGoToCongratulations()
    *  Summary         : opens modal window to warn that user goes to final step
    *  CreatedDate     : 22/08/2018
    *  ModifiedDate    : -
    *  Parameters      : none
    *  Returns         : void
    ******************************************************************************/
    public void showWarningBeforeGoToCongratulations() {
        this.activeModalWindow = GlobalUtils.E2ERuActiveModalWindows.WarningStepBankDetails.name();
    }

    /*******************************************************************************
    *  Name            : activateContract()
    *  Summary         : set true to isActivateContract
    *  CreatedDate     : 03/09/2018
    *  ModifiedDate    : -
    *  Parameters      : none
    *  Returns         : void
    ******************************************************************************/
    public void activateViewContract() {
        this.isActivateContract = true;
    }

    /*******************************************************************************
    *  Name            : activateDraftContract()
    *  Summary         : set true to isActivateContractDraft
    *  CreatedDate     : 03/09/2018
    *  ModifiedDate    : -
    *  Parameters      : none
    *  Returns         : void
    ******************************************************************************/
    public void activatePreviewContract() {
        this.isActivateContractPreview = true;
    }

    /*******************************************************************************
    *  Name            : deduplicationCurrentClient()
    *  Summary         : check client by E2E name and phone
    *  CreatedDate     : 03/09/2018
    *  ModifiedDate    : -
    *  Parameters      : none
    *  Returns         : void
    ******************************************************************************/
    public void deduplicationCurrentClient() {
        Map<String, String> deduplicationResult = this.formService.deduplicateE2EClient('E2E', this.pagesContentMap);
        if (deduplicationResult.containsKey('statusCode') && deduplicationResult.get('statusCode') == GlobalUtils.DeduplicationStatus.E2EProcess.name()) {
            this.accountId = deduplicationResult.get('accountId');
            this.opportunityId = deduplicationResult.get('opportunityId');
            this.contactId = deduplicationResult.get('contactId');
            this.formDataId = deduplicationResult.get('formDataId');
        }
    }

    /*******************************************************************************
    *  Name            : getEncodedUrl()
    *  Summary         : return encoded url
    *  CreatedDate     : 22/08/2018
    *  ModifiedDate    : -
    *  Parameters      : none
    *  Returns         : String
    ******************************************************************************/
    private String getEncodedUrl(Id formDataId, String nextStep) {
        Blob key256AES = EncodingUtil.base64Decode(E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu').AES256_Key__c);
        if (key256AES == null) {
            throw new E2EFormRuException('E2EFormRuCtrl.getEncodedUrl: does not found key for encrypt');
        }

        String stringToEncode = formDataId + '-' + nextStep;
        String encodedStringUrl = E2EFormEncryption.getHashAlgorithAES256(key256AES, stringToEncode);
        return encodedStringUrl;
    }

    /*******************************************************************************
    *  Name            : getDraftContract()
    *  Summary         : return draft contract blob
    *  CreatedDate     : 03/09/2018
    *  ModifiedDate    : -
    *  Parameters      : none
    *  Returns         : Blob
    ******************************************************************************/
    private Blob getPreviewContract() {
        System.debug('TIME: getPreviewContract() start: '+System.currentTimeMillis());
        Blob body = Blob.valueOf('');
        if (this.isActivateContractPreview == true) {
            this.isActivateContractPreview = false;
            try {
                List<String> reportIds = getReportIdsForContract(true);
                System.debug('******* DRAFT REPORT IDS: ' + reportIds);
                body = getContractContent(reportIds);
                this.formParams.getReport = ' > ' + GlobalUtils.E2ERuProcessStatus.GetReport.name(); // log process
            } catch (Exception e) {
                String notificationMessage = '<br/>E2E  method getDraftAgreement: ' + String.valueOf(e.getMessage());
                ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
            }
        }
        System.debug('TIME: getPreviewContract() end: '+System.currentTimeMillis());
        return body;
    }

    private void requestToGenerateContract() {
        List<String> reportIds = getReportIdsForContract(false);
        this.formParams.saveReport = ' > ' + GlobalUtils.E2ERuProcessStatus.SaveReport.name(); // log process
        System.debug('******* REPORT IDS: ' + reportIds);
    }

    /*******************************************************************************
    *  Name            : getReportIdsForContract(Boolean isDraft)
    *  Summary         : return report ids list from credit factory
    *  CreatedDate     : 03/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Boolean isDraft
    *  Returns         : List<String> reportIds
    ******************************************************************************/
    private List<String> getReportIdsForContract(Boolean isDraft) {
        System.debug('TIME: getReportIdsForContract start: '+System.currentTimeMillis());
        ReportRequestData requestData = this.formService.prepareReportRequestData(this.formDataId, this.formParams, this.pagesContentMap, isDraft);
        System.debug('********* REPORT REQUEST DATA: ' + requestData);
        ReportResponseData response = this.reportWebService.getReportIdsFromCreditFactory(requestData);

        if (!isDraft) {
            this.formParams.contractPrefix = response.reportParams.SALESFORCE_CONTRACT_PREFIX;
            this.formParams.contractCounter = response.reportParams.SALESFORCE_CONTRACT_COUNTER;
            this.formParams.invoicePrefix = response.reportParams.SALESFORCE_INVOICE_PREFIX;
            this.formParams.invoiceCounter = response.reportParams.SALESFORCE_INVOICE_COUNTER;
        }
        System.debug('TIME: getReportIdsForContract start: '+System.currentTimeMillis());
        return this.reportWebService.getOrderReportIds(response, GlobalUtils.reportIdsSequence);
    }

    /*******************************************************************************
    *  Name            : getContractContent(List<String> reportIds)
    *  Summary         : return contract blob by report ids
    *  CreatedDate     : 03/09/2018
    *  ModifiedDate    : -
    *  Parameters      : List<String> reportIds
    *  Returns         : Blob
    ******************************************************************************/
    private Blob getContractContent(List<String> reportIds) {
        System.debug('TIME: getReportsFromReportService start: '+System.currentTimeMillis());
        if (reportIds != null && !reportIds.isEmpty()) {
            Blob body = this.reportWebService.getReportsFromReportService(reportIds);
            System.debug('TIME: getReportsFromReportService end: '+System.currentTimeMillis());
            return body;
        } else {
            throw new E2EFormRuException('<br/>E2E  method getAgreementContent (reportIds is empty)');
        }
    }

    public void createTransitCont() {
        System.debug('TIME: prepareTransitRequestData end: '+System.currentTimeMillis());
        TransitRequestData transitRequestData = this.formService.prepareTransitRequestData(this.formDataId, this.formParams, this.pagesContentMap);
        System.debug('TIME: prepareTransitRequestData end: '+System.currentTimeMillis());
        System.debug('TIME: transitWebService.storeContData end: '+System.currentTimeMillis());
        TransitResponseData response = this.transitWebService.storeContData(transitRequestData);
        System.debug('TIME: transitWebService.storeContData end: '+System.currentTimeMillis());
        this.formParams.transitContId = response.createdId;
        this.formParams.createContInTransit = ' > ' + GlobalUtils.E2ERuProcessStatus.CreateContInTransit.name(); // log process
        System.debug('this.formParams.transitContId: ' + this.formParams.transitContId);
    }

    public void createMzkProposal() {
        System.debug('TIME: prepareMzkRequest start: '+System.currentTimeMillis());
        MZKRequest request = this.formService.prepareMzkRequest(this.formDataId, this.formParams);
        System.debug('TIME: prepareMzkRequest end: '+System.currentTimeMillis());
        System.debug('TIME: mzkWebService.getRequestNumber start: '+System.currentTimeMillis());
        this.formParams.requestNumMZK = this.mzkWebService.getRequestNumber(request);
        System.debug('MZK number: ' + this.formParams.requestNumMZK);
    }

    @RemoteAction
    global static CompanySpark remoteGetCompanySparkInfoByInn(String inn) {
        SparkWebService sparkWebService = new SparkWebServiceImpl();

        // get company information from spark
        List<CompanySpark> mainCompanySpark = new List<CompanySpark>();
        CompanySpark companySpark;
        try{
            mainCompanySpark = sparkWebService.getCompanyListByInn(inn);
            if (!mainCompanySpark.isEmpty()) {
                companySpark = mainCompanySpark.get(0);
                System.debug('**** Remote Action SPARK ID: ' + companySpark.sparkId + ' SPARK COMPANY: ' + companySpark.fullName);

                // get extended information from spark
                ExtendedReportSpark extendedReport = sparkWebService.getCompanyExtendedReportBySparkId(inn, String.valueOf(companySpark.sparkId));
                System.debug('**** Remote Action EXTENDED REPORT: ' + extendedReport);
                if (extendedReport != null) {
                    companySpark.extendedReport = extendedReport;
                }
            }
        } catch (Exception e) {
            String notificationMessage = '<br/>E2E Remote Action getCompanyListByInn(): ' + String.valueOf(e.getMessage());
            ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
        }
        return companySpark;
    }

    @RemoteAction
    global static void remoteUpdateCompanySparkInfo(String companySparkInfoJson, String formDataId, String opportunityId, String companyInn) {
        String companySparkInfo = companySparkInfoJson.replace('&quot;', '\\"');
        System.debug('companySparkInfo: ' + companySparkInfo);
        if (companySparkInfo != null && companySparkInfo != '') {
            CompanySpark companySpark = (CompanySpark)System.JSON.deserialize(companySparkInfo, CompanySpark.class);

            if (companySpark.extendedReport != null) {
                SparkWebService sparkWebService = new SparkWebServiceImpl();
                E2EFormParams formParams = new E2EFormParams();
                ExtendedReportSpark.Leader actualLeader = sparkWebService.getCompanyActualLeader(companySpark.extendedReport.LeaderList.leader);
                formParams.sparkId = companySpark.sparkID;
                formParams.mainCompanyFullNameSpark = companySpark.fullName;
                formParams.registrationDateSpark = String.valueOf(((DateTime) Json.deserialize('"' + companySpark.extendedReport.dateFirstReg + '"', DateTime.class)).format('dd.MM.yyyy'));
                formParams.executiveFio = actualLeader.fio;
                formParams.executivePosition = actualLeader.position;
                formParams.okpoSpark = companySpark.extendedReport.okpo;
                formParams.ogrnSpark = companySpark.extendedReport.ogrn;
                formParams.kppSpark = companySpark.extendedReport.kpp;
                formParams.companyCountry = 'Россия';
                formParams.postCodeSpark = companySpark.extendedReport.LegalAddresses.address.postCode;
                formParams.regionSpark = companySpark.extendedReport.LegalAddresses.address.region;
                formParams.citySpark = companySpark.extendedReport.LegalAddresses.address.city;
                formParams.streetSpark = companySpark.extendedReport.LegalAddresses.address.streetName;
                formParams.buildingSpark = companySpark.extendedReport.LegalAddresses.address.buildingNumber;
                formParams.housingSpark = companySpark.extendedReport.LegalAddresses.address.housing;
                formParams.blockSpark = companySpark.extendedReport.LegalAddresses.address.block;
                formParams.roomSpark = companySpark.extendedReport.LegalAddresses.address.room;
                formParams.legalAddressSpark = companySpark.extendedReport.LegalAddresses.address.address;
                formParams.normName = companySpark.extendedReport.normName;
                formParams.companyInn = companyInn;

                E2EFormRuService formRuService = new E2EFormRuServiceImpl();
                formRuService.updateCompanyInformationFromSpark(formParams, formDataId, opportunityId);
            } else {
                throw new E2EFormRuException('Error: remoteUpdateCompanySparkInfo');
            }
        } else {
            throw new E2EFormRuException('Error: remoteUpdateCompanySparkInfo');
        }
    }

    @RemoteAction
    global static SoleProprietorSpark remoteGetEntrepreneurShortReportByInn(String inn) {
        SparkWebService sparkWebService = new SparkWebServiceImpl();
        E2EFormParams formParams = new E2EFormParams();

        // get sole proprietor information from spark
        SoleProprietorSpark soleProprietorInfo;
        try{
            soleProprietorInfo = sparkWebService.getEntrepreneurShortReportByInn(inn);
            System.debug('**** RemoteAction SOLE INFO SPARK: ' + soleProprietorInfo);
        } catch (Exception e) {
            String notificationMessage = '<br/>E2E Remote Action getEntrepreneurShortReportByInn(): ' + String.valueOf(e.getMessage());
            ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
        }
        return soleProprietorInfo;
    }

    @RemoteAction
    global static void remoteUpdateEntrepreneurShortReport(String soleProprietorInfoJson, String formDataId) {
        String soleProprietorInfo = soleProprietorInfoJson.replace('&quot;', '\"');
        System.debug('soleProprietorInfo: ' + soleProprietorInfo);
        if (soleProprietorInfo != null && soleProprietorInfo != '') {
            SoleProprietorSpark soleProprietorSpark = (SoleProprietorSpark)System.JSON.deserialize(soleProprietorInfo, SoleProprietorSpark.class);
            if (soleProprietorSpark != null && soleProprietorSpark.sparkID != null) {
                E2EFormParams formParams = new E2EFormParams();
                formParams.sparkId = soleProprietorSpark.sparkID;
                formParams.soleProprietorFio = soleProprietorSpark.fullNameRus;
                formParams.mainCompanyFullNameSpark = 'ИП ' + soleProprietorSpark.fullNameRus;
                formParams.registrationDateSpark = String.valueOf(((DateTime) Json.deserialize('"' + soleProprietorSpark.dateReg + '"', DateTime.class)).format('dd.MM.yyyy'));
                formParams.ogrnipSpark = soleProprietorSpark.ogrnip;
                formParams.okpoSpark = soleProprietorSpark.okpo;
                System.debug('**** RemoteAction SPARK ID: ' + formParams.sparkId + ' SPARK SOLE: ' + formParams.mainCompanyFullNameSpark);

                E2EFormRuService formService = new E2EFormRuServiceImpl();
                formService.updateSoleProprietorInfoFromSpark(formParams, formDataId);
            }
        } else {
            throw new E2EFormRuException('Error: remoteUpdateEntrepreneurShortReport');
        }
    }

    @RemoteAction
    global static CompanyVerificationScoring checkCompany(Boolean isSole, String inn, String sparkId, String opportunityId) {
        System.debug('inn' + inn);
        System.debug('sparkId' + sparkId);

        ScoringWebService scoringWebService = new ScoringWebServiceImpl();

        // verify company by black lists
        CompanyVerificationScoring verificationDecision;
        if (sparkId != '' && inn != '') {
            verificationDecision = scoringWebService.verifyCompany(inn, sparkId, opportunityId);
            System.debug('**** RemoteAction VERIFICATION DECISION: ' + verificationDecision.decision + ', listType=' + verificationDecision.blackListType);
        } else {
            System.debug('**** RemoteAction SPARK DATA IS EMPTY for inn = ' + inn + ' sparkId = ' + sparkId);
            String notificationMessage = '<br/>E2E RU RemoteAction SPARK DATA IS EMPTY for inn = ' + inn + ' sparkId = ' + sparkId;
            ExceptionLogger.sendException(notificationMessage, '');
        }
        return verificationDecision;
    }

    @RemoteAction
    global static void updateVerifiedDecision(String formDataId, String opportunityId, String inn, String verificationDecision) {
        ScoringWebService scoringWebService = new ScoringWebServiceImpl();
        E2EFormParams formParams;
        CompanyVerificationScoring verificationScoring;
        if (verificationDecision != '') {
            verificationScoring = (CompanyVerificationScoring)System.JSON.deserialize(verificationDecision, CompanyVerificationScoring.class);
        }

        if (verificationScoring != null) {
            formParams = new E2EFormParams();
            formParams.verifiedDecision = scoringWebService.prepareBlackListDecisionForSF(verificationScoring.decision);
            formParams.verifiedDecisionCode = String.valueOf(verificationScoring.decision);
            formParams.verifiedLimitation = String.valueOf(verificationScoring.limitation);

            E2EFormRuService formService = new E2EFormRuServiceImpl();
            formService.updateVerifiedDecision(formParams, formDataId, opportunityId);
        } else {
            throw new E2EFormRuException('**** Error: updateVerifiedDecision verificationScoring is null');
        }
    }

    @RemoteAction
    global static DecisionScoring getScore(Boolean isManualEntry, String inn, String sparkId, String opportunityId, String verificationDecision) {

        CompanyVerificationScoring verificationScoring;
        if (verificationDecision != '') {
            verificationScoring = (CompanyVerificationScoring)System.JSON.deserialize(verificationDecision, CompanyVerificationScoring.class);
        }

        ScoringWebService scoringWebService = new ScoringWebServiceImpl();

        DecisionScoring decision;
        // do not score the company if it was manual entry or if company is in a black list
        if (!isManualEntry && verificationScoring != null && verificationScoring.decision != 3) {
            decision = scoringWebService.getScoringDecision(inn, sparkId, (Id)opportunityId);
            System.debug('**** RemoteAction SCORING DECISION: ' + decision.decision);
        }
        return decision;
    }

    @RemoteAction
    global static void updateScoreDecision(String formDataId, String opportunityId, String scoreDecision) {
        System.debug('Ты здесь, я тебя вижу ' + scoreDecision);
        ScoringWebService scoringWebService = new ScoringWebServiceImpl();

        DecisionScoring decision;
        if (scoreDecision != null && scoreDecision != '') {
            decision = (DecisionScoring)System.JSON.deserialize(scoreDecision, DecisionScoring.class);
        }

        if (decision != null) {
            E2EFormParams formParams = new E2EFormParams();
            formParams.scoringDecision = scoringWebService.prepareScoringDecisionForSF(decision.decision);
            formParams.scoringDecisionCode = String.valueOf(decision.decision);
            formParams.scoringDate = Date.today();
            E2EFormRuService formService = new E2EFormRuServiceImpl();
            formService.updateScoringDecision(formParams, formDataId, opportunityId);
        }
    }

    @RemoteAction
    global static String remoteCreateExecutiveEmployee(String formDataId, String leaderListJson) {
        String leaderList = leaderListJson.replace('&quot;', '\\"');
        if (leaderList != null && leaderList != '') {
            ExtendedReportSpark.LeaderList leaders = (ExtendedReportSpark.LeaderList) System.JSON.deserialize(leaderList, ExtendedReportSpark.LeaderList.class);

            if (leaders != null) {
                SparkWebService sparkWebService = new SparkWebServiceImpl();
                ExtendedReportSpark.Leader actualLeader = sparkWebService.getCompanyActualLeader(leaders.leader);

                if (actualLeader != null) {
                    E2EFormRuService formService = new E2EFormRuServiceImpl();
                    E2EFormData__c formData = formService.getFormDataById(formDataId);
                    if (formData != null && formData.E2E_Account_Id__c != null) {
                        return formService.createEmployeeContact(formData.E2E_Account_Id__c, actualLeader.fio, actualLeader.position);
                    }
                }
            }
        }
        return null;
    }
}