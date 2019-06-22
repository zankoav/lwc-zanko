global class LongFormDesktopCHcontroller {
    public Map<String, LongFormPage> stepPagesMap {get; set;}
    public Integer activeStep {get; set;}
    public String activeSubStep {get; set;}
    public Boolean continueButtonIsDisabled {get; set;}
    public String activeInnerPageCreditScoring {get; set;}
    public String activeInnerPage {get; set;}
    public String countryParam {get; set;}
    public String country;
    public String customSettingName;
    public Account account {get; set;}
    public Contact contact {get; set;}
    public Opportunity opportunity {get; set;}
    public Map<Decimal, LongForm_Menu_Item__c> menuItemsMap {get; set;}
    private String opptyIdParam;

    // Contact details
    public LFContactDetails contactDetailsService;

    // Credit Score
    public LFCreditScoring creditScoringService;
    public CFSearchResponse availableCompaniesListCreditScoring {get; set;}
    public CFReportResponse cfReportResponse {get; set;}
    public CreditCompany selectedAvailableCompanyCreditScoring {get; set;}
    public Integer defaultBillingPeriod {get; set;}
    public Integer defaultBillingPeriodTemp {get; set;}
    public Decimal creditLimit {get; set;}
    public Decimal minCreditLimit {get; set;}
    public Decimal creditLimit30_Plus27 {get; set;}
    public Decimal maxCreditLimit {get; set;}
    private Decimal maxCreditLimit30_Plus27;
    public Decimal maxValue {get; set;}
    private Decimal maxValue30_Plus27;
    public Decimal deposit {get; set;}
    private Decimal deposit30_Plus27;
    public CreditFactoryDecision cfDecision {get; set;}
    public String unavailableOptions {get; set;}

    // Card configuration
    public LFCardsConfig cardsConfigService;
    public Integer numberOfCards {get; set;}
    public Integer numberOfDiffCards {get; set;}
    public String activeCardConfigTab {get; set;}
    public Boolean showInternationalFeesBlock {get; set;}
    public Map<Integer, LongFormCard> sameCardsMap {get; set;}
    public Map<Integer, LongFormCard> diffCardsMap {get; set;}
    public Map<Integer, LongFormCard> finalCardsMap {get; set;}
    public String activeInnerPageCardsConfig;
    public List<LongFormSpecialOffer> nonHomeOffersList {get; set;}

    // Additional
    public LFAdditional additionalService;

    // Payment Options
    public LFPaymentOptions paymentOptionsService;
    public Map<String, String> paymentParameters {get; set;}
    // public String paymentURL {get; set;}
    // public String selectedPaymentMethod {get; set;}
    public String paymentStatus {get; set;}
    public Map<String, List<LongFormCostItem>> costsColumnsMap {get; set;}

    // ONLINE CHAT
    public Map<String, LongFormPage> pageMapChat {get; set;}
    public LFChatService chatService;
    public String chatButtonId {get;set;}
    public String chatDeploymentId {get; set;}
    public String chatDeploymentJsURL {get;set;}
    public string chatURL {get;set;}
    public String offlineChatGreetingMessage {get;set;}
    public String chatFirstMessage {get;set;}

    private Datetime startApexCall;
    private Datetime endApexCall;


    /*******************************************************************************
    *  Name            : init()
    *  Summary         : data initialization
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : PageReference – possible redirect to the mobile
    ******************************************************************************/
    public PageReference init() {
        try {
            // init start parameters
            if (this.activeStep == null) this.activeStep = 0;
            this.countryParam = ApexPages.CurrentPage().getParameters().get('country');
            if ( LongFormGlobalUtils.countryParamToCountryMap.containsKey(this.countryParam) && LongFormGlobalUtils.countryParamToCustomSettingsMap.containsKey(this.countryParam) ) {
                this.country = LongFormGlobalUtils.countryParamToCountryMap.get(this.countryParam);
                this.customSettingName = LongFormGlobalUtils.countryParamToCustomSettingsMap.get(this.countryParam);
            } else {
                throw new LongFormException('The link is corrupted. Please contact your administrator');
            }
            String encryptedParams = ApexPages.currentPage().getParameters().get('source');
            if (encryptedParams != null && encryptedParams != '') doDecryptParams(encryptedParams);

            // check if it's mobile version
            PageReference mobileUrlRedirect = redirectToMobile(encryptedParams);
            if (mobileUrlRedirect != null) return mobileUrlRedirect;

            //do activate specific step
            initPageElements();
            initChatSetup();
            if (this.opptyIdParam != null) {
                initSObjects(this.opptyIdParam);
                updateOpportunityOnReturnFromEmail();
                PageReference redirectForClosedLost = redirectForClosedLost();
                if (redirectForClosedLost != null) return redirectForClosedLost;
                if (this.opportunity.E2E_Active_Step__c != null && Integer.valueOf(this.opportunity.E2E_Active_Step__c) != this.activeStep) {
                    this.activeStep = Integer.valueOf(this.opportunity.E2E_Active_Step__c);
                    restartActiveStep();
                } else {
                    doPreFillingFormFields();
                }
            }
            //menu
            LFMenu menuService = LongFormGlobalUtils.returnMenuService(this.country);
            menuService.setMenuItems('Desktop');
            this.menuItemsMap = menuService.getMenuItems();
            if (this.activeSubStep == null) this.activeSubStep = 'Contact details';
            return null;
        } catch (Exception e) {
            this.activeStep = null;
            if (this.stepPagesMap == null) this.stepPagesMap = new Map<String, LongFormPage>();
            if (this.country != 'Switzerland-DE' || this.country != 'Switzerland-FR') {
                this.country = 'Switzerland-DE';
            }
            this.stepPagesMap.putAll(LongFormGlobalUtils.returnErrorPage(this.country, 'Desktop'));
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'init()', e);
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : redirectForClosedLost()
    *  Summary         : Redirect to the empty form if opportunity is Closed Lost
    *  CreatedDate     : 28/02/2019
    *  Parameters      :
    *  Returns         : PageReference
    ******************************************************************************/
    public PageReference redirectForClosedLost() {
        if (this.opportunity == null) return null;

        if (this.opportunity.StageName == 'Closed Lost') {
            return new PageReference('/e2eformch?country' + this.countryParam);
        }

        return null;
    }


    /*******************************************************************************
    *  Name            : redirectToMobile(String encodedId)
    *  Summary         : If device is mobile then redirect to mobile version
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : String encodedId – optional encoded id for data preset
    *  Returns         : PageReference – url to mobile version
    ******************************************************************************/
    public PageReference redirectToMobile(String encodedId) {
        String userAgent = ApexPages.currentPage().getHeaders().get('USER-AGENT');
        if (userAgent == null) return null;

        for (String deviceName : LongFormGlobalUtils.mobileDevicesSet) {
            if (userAgent.containsIgnoreCase(deviceName)) {
                String userName = UserInfo.getName();
                PageReference url;
                if (userName == 'E2E Site Guest User') {
                    url = new PageReference('/e2eformmobch?country=' + this.countryParam);
                } else {
                    url = new PageReference('/apex/e2eformmobch?country=' + this.countryParam);
                }

                String tablet = ApexPages.currentPage().getParameters().get('tablet');
                if (tablet != null && tablet == 'true') url.getParameters().put('tablet','true');

                if (encodedId != null) url.getParameters().put('source',encodedId);

                String utm_campaign = ApexPages.currentPage().getParameters().get('utm_campaign');
                String utm_content = ApexPages.currentPage().getParameters().get('utm_content');
                String utm_medium = ApexPages.currentPage().getParameters().get('utm_medium');
                String utm_term = ApexPages.currentPage().getParameters().get('utm_term');
                String utm_source = ApexPages.currentPage().getParameters().get('utm_source');
                String utm_url = ApexPages.currentPage().getParameters().get('utm_url');
                String followup = ApexPages.currentPage().getParameters().get('followup');

                if (utm_campaign != null) url.getParameters().put('utm_campaign',utm_campaign);
                if (utm_content != null) url.getParameters().put('utm_content',utm_content);
                if (utm_medium != null) url.getParameters().put('utm_medium',utm_medium);
                if (utm_term != null) url.getParameters().put('utm_term',utm_term);
                if (utm_source != null) url.getParameters().put('utm_source',utm_source);
                if (utm_url != null) url.getParameters().put('utm_url',utm_url);
                if (followup != null) url.getParameters().put('followup',followup);
                return url;
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : initPageElements()
    *  Summary         : do activate specific step
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void initPageElements() {
        if (this.activeStep == 0) {
            // zero step elements
            this.contactDetailsService = LongFormGlobalUtils.returnContactDetailsService(this.country);
            this.contactDetailsService.setPagesMap('Desktop');
            this.stepPagesMap = this.contactDetailsService.getPagesMap();
        } else
        if (this.activeStep == 1) {
            //first step elements
            this.creditScoringService = LongFormGlobalUtils.returnCreditScoringService(this.country);
            this.creditScoringService.setPagesMap('Desktop');
            this.stepPagesMap = this.creditScoringService.getPagesMap();
        } else
        if (this.activeStep == 2) {
            //second step elements
            this.cardsConfigService = LongFormGlobalUtils.returnCardsConfigService(this.country);
            this.cardsConfigService.setPagesMap('Desktop');
            this.stepPagesMap = this.cardsConfigService.getPagesMap();
            this.finalCardsMap = new Map<Integer, LongFormCard>();
        } else
        if (this.activeStep == 3) {
            this.cardsConfigService = LongFormGlobalUtils.returnCardsConfigService(this.country);
            this.cardsConfigService.setPagesMap('Desktop');
            // Additional
            this.additionalService = LongFormGlobalUtils.returnAdditionalService(this.country);
            this.additionalService.setPagesMap('Desktop');
            this.stepPagesMap = this.additionalService.getPagesMap();
        } else
        if (this.activeStep == 4 || this.activeStep == 5) {
            this.cardsConfigService = LongFormGlobalUtils.returnCardsConfigService(this.country);
            this.cardsConfigService.setPagesMap('Desktop');

            this.paymentOptionsService = LongFormGlobalUtils.returnPaymentOptionsService(this.country);
            this.paymentOptionsService.setPagesMap('Desktop');
            this.stepPagesMap = this.paymentOptionsService.getPagesMap();
            this.paymentParameters = new Map<String, String>();
        }
    }




    /*******************************************************************************
    *  Name            : restartActiveStep()
    *  Summary         : restarts active step
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void restartActiveStep() {
        initPageElements();
        initSObjects(this.opptyIdParam);
        doPreFillingFormFields();
    }


    /*******************************************************************************
    *  Name            : initSObjects(String opptyId)
    *  Summary         : init data of form fields
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : String opptyId
    *  Returns         : void
    ******************************************************************************/
    public void initSObjects(String opptyId) {
        if (this.activeStep == 0) {
            this.contactDetailsService.setSFobjects(opptyId);
            this.opportunity = this.contactDetailsService.getOpportunity();
            this.account = this.contactDetailsService.getAccount();
            this.contact = this.contactDetailsService.getContact();
        } else if (this.activeStep == 1) {
            this.creditScoringService.setSFobjects(opptyId);
            this.opportunity = this.creditScoringService.getOpportunity();
            this.account = this.creditScoringService.getAccount();
            this.contact = this.creditScoringService.getContact();
        } else if (this.activeStep == 2) {
            this.cardsConfigService.setSFobjects(opptyId);
            this.opportunity = this.cardsConfigService.getOpportunity();
            this.account = this.cardsConfigService.getAccount();
            this.contact = this.cardsConfigService.getContact();
            this.cardsConfigService.setPriceLists();
        } else if (this.activeStep == 3) {
            this.cardsConfigService.setOpportunity(opptyId);
            this.additionalService.setSFobjects(opptyId);
            this.opportunity = this.additionalService.getOpportunity();
            this.account = this.additionalService.getAccount();
            this.contact = this.additionalService.getContact();
            this.cardsConfigService.setPriceLists();
        } else if (this.activeStep == 4) {
            this.cardsConfigService.setOpportunity(opptyId);
            this.paymentOptionsService.setSFobjects(opptyId);
            this.opportunity = this.paymentOptionsService.getOpportunity();
            this.account = this.paymentOptionsService.getAccount();
            this.contact = this.paymentOptionsService.getContact();
            this.cardsConfigService.setPriceLists();
        } else if (this.activeStep == 5) {
            this.cardsConfigService.setOpportunity(opptyId);
            this.paymentOptionsService.setSFobjects(opptyId);
            this.opportunity = this.paymentOptionsService.getOpportunity();
            this.account = this.paymentOptionsService.getAccount();
            this.contact = this.paymentOptionsService.getContact();
        }
        if (this.account == null || this.opportunity == null || this.contact == null) throw new LongFormException('Error is merge or delete object');
    }


    /*******************************************************************************
    *  Name            : doPreFillingFormFields()
    *  Summary         : pre-filling form fields
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doPreFillingFormFields() {
        if (this.activeSubStep == null) this.activeSubStep = LongFormGlobalUtils.returnActiveSubstep(this.opportunity);
        if (this.activeStep == 0) {
            doPreFillingFieldsStep_0();
        } else if (this.activeStep == 1) {
            doPreFillingFieldsStep_1();
        } else if (this.activeStep == 2) {
            doPreFillingFieldsStep_2();
        } else if (this.activeStep == 3) {
            doPreFillingFieldsStep_3();
        } else if (this.activeStep == 4) {
            doPreFillingFieldsStep_4();
        } else if (this.activeStep == 5) {
            doPreFillingFieldsStep_5();
        }
        if (this.paymentStatus != null && this.activeSubstep != 'Congratulations') {
            this.startApexCall = Datetime.now();
            // A - Accept
            // D - Declined
            // C - Cancel
            // E - Exception
            this.paymentOptionsService.goToThanksPageFromPaymentSystem(this.paymentStatus);
            this.activeStep = 5;
            this.activeSubstep = 'Congratulations';
            // Payment information
            if (E2EKeysAPI__c.getValues(this.customSettingName) != null) {
                Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues(this.customSettingName).AES256_Key__c);
                // How to pay block
                this.stepPagesMap.get('CONGRATULATIONS').elements.get('HOW TO PAY BLOCK').get('SAVE PAYMENT INFORMATION DOWNLOAD URL').Value__c = '/apex/E2EAdditionalDocuments?hash=' +
                    E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=howToPayDeposit&' + 'opportunityID=' + String.valueOf(opportunity.Id) +'&pdfDownload=TRUE&');
                // Direct Debit Mandate Acceptance
                this.stepPagesMap.get('CONGRATULATIONS').elements.get('DIRECT DEBIT MANDATE ACCEPTANCE BLOCK').get('DOCUMENT. IFRAME URL').Value__c = '/apex/E2EAdditionalDocuments?hash=' +
                        E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=ddMandateAcceptance' + this.countryParam.toUpperCase() + '&opportunityID=' + String.valueOf(opportunity.ID)+'&');
                this.stepPagesMap.get('CONGRATULATIONS').elements.get('DIRECT DEBIT MANDATE ACCEPTANCE BLOCK').get('DOWNLOAD URL').Value__c = '/apex/E2EAdditionalDocuments?hash=' +
                        E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=ddMandateAcceptance' + this.countryParam.toUpperCase() + '&opportunityID=' + String.valueOf(opportunity.ID) +'&pdfDownload=TRUE&');
            }
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, 'Payment Gateway Service', this.activeSubstep, 'Return from a external service', this.country, 'Desktop');
        }
        deactivateInactiveServices();
    }


    /*******************************************************************************
    *  Name            : doPreFillingFieldsStep_0()
    *  Summary         : prefilling fields on step 0
    *  CreatedDate     : 22/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void doPreFillingFieldsStep_0() {
        if (this.activeSubStep == null) this.activeSubStep = this.opportunity.E2E_Active_Substep__c;
        if (this.contact.Salutation != null) {
            this.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = this.contact.Salutation;
        }
        this.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = this.contact.FirstName;
        if (this.contact.LastName != null && ! this.contact.LastName.containsIgnoreCase('LongForm')) {
            this.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = this.contact.LastName;
        }
        this.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = this.contact.Phone;
        this.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = this.contact.Email;
        if (this.opportunity.E2E_Form_of_Business__c != null) {
            this.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = this.opportunity.E2E_Form_of_Business__c;
        }
        if (this.opportunity.Agree_to_Privacy_Policy__c != null) {
            this.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = String.valueOf(this.opportunity.Agree_to_Privacy_Policy__c);
        }
        if (this.opportunity.E2E_Form_of_Business__c != null) {
            this.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = this.opportunity.E2E_Form_of_Business__c;
        }
    }


    /*******************************************************************************
    *  Name            : doPreFillingFieldsStep_1()
    *  Summary         : prefilling fields on step 1
    *  CreatedDate     : 22/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void doPreFillingFieldsStep_1() {
        if (this.activeSubStep == null) this.activeSubStep = this.opportunity.E2E_Active_Substep__c;
        if (! this.account.Name.startsWithIgnoreCase('LONGFORM:')) {
            this.stepPagesMap.get('CREDIT SCORE. SEARCH COMPANY').fields.get('COMPANY NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = this.account.Name;
        }
        if (this.account.BillingCity != null) {
            this.stepPagesMap.get('CREDIT SCORE. SEARCH COMPANY').fields.get('CITY').elementItemsMap.get('DEFAULT VALUE').Value__c = this.account.BillingCity;
        }
        if (this.opportunity.Zahlungsart__c != null) {
            this.stepPagesMap.get('CREDIT SCORE. SCORING RESULT').fields.get('PAYMENT METHOD').elementItemsMap.get('DEFAULT VALUE').Value__c = this.opportunity.Zahlungsart__c;
        }
        if (this.opportunity.Total_consumption_l_month__c != null) {
            this.stepPagesMap.get('CREDIT SCORE. TOTAL CONSUMPTION').fields.get('TOTAL CONSUMPTION').elementItemsMap.get('DEFAULT VALUE').Value__c = String.valueOf(this.opportunity.Total_consumption_l_month__c);
        }
        this.creditScoringService.setCreditReportFromSF(this.opportunity.Id);
        this.cfReportResponse = this.creditScoringService.getCreditReportFromSF();
        if (this.cfReportResponse != null) {
            this.selectedAvailableCompanyCreditScoring = this.cfReportResponse.company;
        }
        if (this.opportunity.E2E_Active_Substep__c == 'Calculating credit score') {
            if (this.selectedAvailableCompanyCreditScoring != null ) {
                this.activeSubStep = 'Calculating credit score';
                this.defaultBillingPeriod = Integer.valueOf(this.cfReportResponse.recommendedBillingPeriod);
                this.defaultBillingPeriodTemp = this.defaultBillingPeriod;
                this.creditLimit = this.cfReportResponse.creditLimitDefault;
                this.maxCreditLimit30_Plus27 = this.cfReportResponse.maxCreditLimit30_Plus27;
                this.creditLimit30_Plus27 = this.cfReportResponse.creditLimit30_Plus27;
                this.maxValue30_Plus27 = this.cfReportResponse.maxValue30_Plus27;
                this.deposit30_Plus27 = this.cfReportResponse.deposit30_Plus27;
                if (this.opportunity.Rechnungsperiode__c != null && this.opportunity.CF_Credit_Limit__c != null) {
                    this.defaultBillingPeriod = Integer.valueOf(this.opportunity.Rechnungsperiode__c);
                    this.deposit = this.opportunity.Security_Amount_To_Pay__c;
                    this.creditLimit = this.opportunity.CF_Credit_Limit__c;
                    this.minCreditLimit = this.creditLimit30_Plus27;
                    this.maxCreditLimit = this.maxCreditLimit30_Plus27;
                    this.maxValue = this.maxValue30_Plus27;
                } else {
                    returnFinalCreditScoreData();
                }
                this.creditScoringService.resetCfDecision(this.defaultBillingPeriod, null, this.deposit, this.selectedAvailableCompanyCreditScoring.classRating, this.selectedAvailableCompanyCreditScoring);
                this.cfDecision = this.creditScoringService.getCfDecision();
            } else {
                this.creditScoringService.resetOpportunityToStep('Search company');
                restartActiveStep();
            }
        }
        chatService.setOpportunity(this.opportunity);
        chatService.setContact(this.contact);
        prepareOnlineChat();
    }


    /*******************************************************************************
    *  Name            : doPreFillingFieldsStep_2()
    *  Summary         : prefilling fields on step 2
    *  CreatedDate     : 22/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void doPreFillingFieldsStep_2() {
        if (this.activeSubStep == null) this.activeSubStep = this.opportunity.E2E_Active_Substep__c;
        this.cardsConfigService.setCreditReport();
        this.unavailableOptions = cardsConfigService.getUnavailableOptions();
        this.selectedAvailableCompanyCreditScoring = this.cardsConfigService.getCreditReport();
        this.cardsConfigService.setCardParams();
        this.activeCardConfigTab = this.cardsConfigService.getActiveCardConfigTab();
        this.sameCardsMap = this.cardsConfigService.getSameCards();
        this.diffCardsMap = this.cardsConfigService.getDiffCards();
        this.numberOfCards = this.cardsConfigService.getNumberOfCards();
        this.numberOfDiffCards = this.diffCardsMap.size();
        this.cardsConfigService.setSpecialOffers('Desktop');
        this.nonHomeOffersList = this.cardsConfigService.getnonHomeOffersList();
        this.cardsConfigService.setFinalOrderCardsMap();
        this.finalCardsMap = this.cardsConfigService.getFinalOrderCardsMap();
        calculateFeesAndCosts();
        this.cardsConfigService.setEmbossingBlockVisibilityStatus();
        this.cardsConfigService.setContinueButtonStatus(this.activeStep, this.activeSubStep);
        this.continueButtonIsDisabled = this.cardsConfigService.getContinueButtonStatus();

        chatService.setOpportunity(this.opportunity);
        chatService.setContact(this.contact);
        prepareOnlineChat();
    }


    /*******************************************************************************
    *  Name            : doPreFillingFieldsStep_3()
    *  Summary         : prefilling fields on step 3
    *  CreatedDate     : 22/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void doPreFillingFieldsStep_3() {
        this.cardsConfigService.setCardParams();
        this.numberOfCards = cardsConfigService.getNumberOfCards();
        this.cardsConfigService.setCreditReport();
        this.selectedAvailableCompanyCreditScoring = this.cardsConfigService.getCreditReport();
        this.cardsConfigService.setFinalOrderCardsMap();
        this.finalCardsMap = this.cardsConfigService.getFinalOrderCardsMap();
        this.cardsConfigService.setEmbossingBlockVisibilityStatus();
        this.cardsConfigService.setCostsColumnsMap();
        this.costsColumnsMap = this.cardsConfigService.getCostsColumnsMap();
        this.stepPagesMap.get('ADDITIONAL').fields.get('CO2 TAKE CARE').elementItemsMap.get('VALUE').Value__c = String.valueOf(opportunity.Eco_Fee__c);
        if (E2EKeysAPI__c.getValues(this.customSettingName) != null) {
            Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues(this.customSettingName).AES256_Key__c);
            // TC
            this.stepPagesMap.get('PAYMENT OPTIONS').fields.get('ACCEPT TERM CONDITIONS').elementItemsMap.get('IFRAME URL').Value__c = '/apex/E2EAdditionalDocuments?hash=' +
                    E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=TermConditions' + this.countryParam.toUpperCase() + '&');
            this.stepPagesMap.get('PAYMENT OPTIONS').fields.get('ACCEPT TERM CONDITIONS').elementItemsMap.get('DOWNLOAD URL').Value__c = '/apex/E2EAdditionalDocuments?hash=' +
                    E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=TermConditions' + this.countryParam.toUpperCase() + '&pdfDownload=TRUE&');
        }
        chatService.setOpportunity(opportunity);
        chatService.setContact(contact);
        prepareOnlineChat();
    }


    /*******************************************************************************
    *  Name            : doPreFillingFieldsStep_4()
    *  Summary         : prefilling fields on step 4
    *  CreatedDate     : 22/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void doPreFillingFieldsStep_4() {
        if (this.activeSubStep == null) this.activeSubStep = this.opportunity.E2E_Active_Substep__c;
        this.cardsConfigService.setCardParams();
        this.activeCardConfigTab = cardsConfigService.getActiveCardConfigTab();
        this.diffCardsMap = this.cardsConfigService.getDiffCards();
        this.sameCardsMap = this.cardsConfigService.getSameCards();
        this.numberOfCards = cardsConfigService.getNumberOfCards();
        this.cardsConfigService.setCreditReport();
        this.selectedAvailableCompanyCreditScoring = this.cardsConfigService.getCreditReport();
        this.cardsConfigService.setFinalOrderCardsMap();
        this.finalCardsMap = this.cardsConfigService.getFinalOrderCardsMap();
        this.cardsConfigService.setEmbossingBlockVisibilityStatus();
        this.cardsConfigService.setCostsColumnsMap();
        this.costsColumnsMap = this.cardsConfigService.getCostsColumnsMap();
        // if (opportunity.Security_Amount_To_Pay__c != null && this.paymentStatus == null) {
        //     this.paymentOptionsService.prepareTransaction('Desktop');
        //     this.selectedPaymentMethod = this.stepPagesMap.get('PAYMENT OPTIONS').fields.get('PaymentMethod Online Bank').options.get(0).getValue();
        //     changePaymentMethod(); // pre-filling payment method (init data)
        // }
        if (E2EKeysAPI__c.getValues(this.customSettingName) != null) {
            Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues(this.customSettingName).AES256_Key__c);
            // TC
            this.stepPagesMap.get('PAYMENT OPTIONS').fields.get('ACCEPT TERM CONDITIONS').elementItemsMap.get('IFRAME URL').Value__c = '/apex/E2EAdditionalDocuments?hash=' +
                    E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=TermConditions' + this.countryParam.toUpperCase() + '&');
            this.stepPagesMap.get('PAYMENT OPTIONS').fields.get('ACCEPT TERM CONDITIONS').elementItemsMap.get('DOWNLOAD URL').Value__c = '/apex/E2EAdditionalDocuments?hash=' +
                    E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=TermConditions' + this.countryParam.toUpperCase() + '&pdfDownload=TRUE&');
            // Deposit Agreement
            this.stepPagesMap.get('PAYMENT OPTIONS').fields.get('DEPOSIT AGREEMENT').elementItemsMap.get('IFRAME URL').Value__c = '/apex/E2EAdditionalDocuments?hash=' +
                    E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=DepositAgreement' + this.countryParam.toUpperCase() + '&opportunityID=' + String.valueOf(opportunity.ID)+'&');
            this.stepPagesMap.get('PAYMENT OPTIONS').fields.get('DEPOSIT AGREEMENT').elementItemsMap.get('DOWNLOAD URL').Value__c = '/apex/E2EAdditionalDocuments?hash=' +
                    E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=DepositAgreement' + this.countryParam.toUpperCase() + '&opportunityID=' + String.valueOf(opportunity.ID) +'&pdfDownload=TRUE&');
            // Payment information
            this.stepPagesMap.get('CONGRATULATIONS').elements.get('HOW TO PAY BLOCK').get('SAVE PAYMENT INFORMATION DOWNLOAD URL').Value__c = '/apex/E2EAdditionalDocuments?hash=' +
                    E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=PaymentInformation&' + 'opportunityID=' + String.valueOf(opportunity.Id) +'&pdfDownload=TRUE&');
        }
        this.stepPagesMap.get('PAYMENT OPTIONS').fields.get('PAPER INVOICE').elementItemsMap.get('VALUE').Value__c = String.valueOf(opportunity.Papierrechnung__c);
        this.stepPagesMap.get('PAYMENT OPTIONS').fields.get('DECISION').elementItemsMap.get('VALUE').Value__c = String.valueOf(this.opportunity.AGB_Datenschutzhinweise_Richtigkeit__c);
        this.stepPagesMap.get('PAYMENT OPTIONS').fields.get('DEPOSIT AGREEMENT').elementItemsMap.get('VALUE').Value__c = String.valueOf(this.opportunity.Agree_To_Deposit_Agreement__c);
        this.stepPagesMap.get('PAYMENT OPTIONS').fields.get('ACCEPT TERM CONDITIONS').elementItemsMap.get('VALUE').Value__c = String.valueOf(this.contact.Authorised_signatory__c);

        chatService.setOpportunity(opportunity);
        chatService.setContact(contact);
        prepareOnlineChat();
    }


    /*******************************************************************************
    *  Name            : doPreFillingFieldsStep_5()
    *  Summary         : prefilling fields on step 5
    *  CreatedDate     : 22/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void doPreFillingFieldsStep_5() {
        // Payment information
        if (E2EKeysAPI__c.getValues(this.customSettingName) != null) {
            Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues(this.customSettingName).AES256_Key__c);
            this.stepPagesMap.get('CONGRATULATIONS').elements.get('HOW TO PAY BLOCK').get('SAVE PAYMENT INFORMATION DOWNLOAD URL').Value__c = '/apex/E2EAdditionalDocuments?hash=' +
                    E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=PaymentInformation&' + 'opportunityID=' + String.valueOf(opportunity.Id) +'&pdfDownload=TRUE&');
            // Direct Debit Mandate Acceptance
            this.stepPagesMap.get('CONGRATULATIONS').elements.get('DIRECT DEBIT MANDATE ACCEPTANCE BLOCK').get('DOCUMENT. IFRAME URL').Value__c = '/apex/E2EAdditionalDocuments?hash=' +
                    E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=ddMandateAcceptance' + this.countryParam.toUpperCase() + '&opportunityID=' + String.valueOf(opportunity.ID) + '&');
            this.stepPagesMap.get('CONGRATULATIONS').elements.get('DIRECT DEBIT MANDATE ACCEPTANCE BLOCK').get('DOWNLOAD URL').Value__c = '/apex/E2EAdditionalDocuments?hash=' +
                    E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=ddMandateAcceptance' + this.countryParam.toUpperCase() + '&opportunityID=' + String.valueOf(opportunity.ID) + '&pdfDownload=TRUE&');
        }
        if (this.activeSubStep == null) this.activeSubStep = this.opportunity.E2E_Active_Substep__c;
        if (this.opportunity.E2E_payment_status__c != null && (this.opportunity.E2E_payment_status__c.substring(0, 1) == 'A' ||
            this.opportunity.E2E_payment_status__c.substring(0, 1) == 'D' || this.opportunity.E2E_payment_status__c.substring(0, 1) == 'C' ||
            this.opportunity.E2E_payment_status__c.substring(0, 1) == 'E')) {
                this.paymentStatus = this.opportunity.E2E_payment_status__c.substring(0, 1);
        }
        this.cardsConfigService.setCardParams();
        this.diffCardsMap = this.cardsConfigService.getDiffCards();
        this.sameCardsMap = this.cardsConfigService.getSameCards();
        this.numberOfCards = cardsConfigService.getNumberOfCards();
        this.cardsConfigService.setCreditReport();
        this.selectedAvailableCompanyCreditScoring = this.cardsConfigService.getCreditReport();

        chatService.setOpportunity(opportunity);
        chatService.setContact(contact);
        prepareOnlineChat();
    }


    /*****************************************************************************
    *  Name            : doDecryptParams(String encryptedParams)
    *  Summary         : do decrypt url params
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : String encryptedParams
    *  Returns         : void
    ******************************************************************************/
    private void doDecryptParams(String encryptedParams) {
        encryptedParams = encryptedParams.replaceAll('(\\s|%2B)', '+');
        if (E2EKeysAPI__c.getValues(this.customSettingName) == null ) throw new LongFormException('The link is corrupted. Please contact your administrator');
        Blob key = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues(this.customSettingName).AES256_Key__c);
        Blob dest = EncodingUtil.base64Decode(encryptedParams);
        Blob decrypted = Crypto.decryptWithManagedIv('AES256', key, dest);
        String decryptedParams = decrypted.toString();
        if (decryptedParams != null) {
            this.opptyIdParam = decryptedParams.substringBefore('-');
            if (decryptedParams.contains('@')) {
                this.activeStep = Integer.valueOf(decryptedParams.substringBetween('-', '@'));
                this.paymentStatus = decryptedParams.substringAfter('@');
            } else {
                this.activeStep = Integer.valueOf(decryptedParams.substringAfter('-'));
            }
        }
    }


    /*******************************************************************************
    *  Name            : goToContactDetails()
    *  Summary         : go to contact details step (step 0)
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void goToContactDetails() {
        try {
            this.activeInnerPage = '';
            this.activeStep = 0;
            this.activeSubStep = 'Contact details';
            initPageElements();
            initSObjects(opportunity.Id);
            doPreFillingFormFields();
        } catch (Exception e) {
            this.activeStep = 1;
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'goToContactDetails()', e);
        }
    }


    /*******************************************************************************
    *  Name            : goToCreditScoring()
    *  Summary         : save data and go to the second step
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : PageReference
    ******************************************************************************/
    public PageReference goToCreditScoring() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            this.startApexCall = Datetime.now();
            disableTriggers();
            this.activeStep = 1;
            this.activeSubStep = 'Search company';
            String formOfBusiness = stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c;
            if (this.opportunity == null && formOfBusiness == 'Private') {
                this.activeSubStep = 'Private entity';
                return null;
            } else if (this.opportunity != null && formOfBusiness == 'Private') {
                this.activeSubStep = 'Private entity';
                E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubStep, null);
                return null;
            }
            Contact duplicateContact;
            this.activeInnerPage = '';
            this.contactDetailsService.validate();
            if (this.contact == null) {
                // insert
                duplicateContact = this.contactDetailsService.getDuplicateContact();
                this.contactDetailsService.findDuplicateLead();
                if (duplicateContact != null) {
                    // check if it's e2e contact or regular duplicate
                    if (duplicateContact.OpportunityContactRoles != null) {
                        for (OpportunityContactRole contactRole : duplicateContact.OpportunityContactRoles) {
                            if (contactRole.Opportunity.AccountId == duplicateContact.AccountId) {
                                // e2e duplicate
                                this.contactDetailsService.setContact(duplicateContact);
                                this.contactDetailsService.setOpportunity(contactRole.Opportunity);
                                this.contactDetailsService.updateRecord(true);
                                String userName = UserInfo.getName();
                                String url;
                                if (userName == 'E2E Site Guest User') {
                                    url = '/e2eFormCH?country=' + this.countryParam + '&source=';
                                } else {
                                    url = '/apex/e2eFormCH?country=' + this.countryParam + '&source=';
                                }
                                PageReference reference = new PageReference(url + contactRole.Opportunity.E2E_Encoded_URL__c);
                                reference.setRedirect(true);
                                this.endApexCall = Datetime.now();
                                if (this.opportunity != null) {
                                    LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, this.country, 'Desktop');
                                }
                                return reference;
                            }
                        }
                    }
                    // standard duplicate
                    this.contactDetailsService.setContact(duplicateContact);
                    this.contactDetailsService.updateRecord(false);
                    this.contactDetailsService.insertRecords(duplicateContact, 'Desktop');
                } else {
                    // no duplicates
                    this.contactDetailsService.insertRecords(null, 'Desktop');
                }
                this.opportunity = this.contactDetailsService.getOpportunity();
                initPageElements();
                initSObjects(this.opportunity.Id);
                deactivateInactiveServices();
                this.continueButtonIsDisabled = true;
            } else {
                // update
                duplicateContact = this.contactDetailsService.getDuplicateContact();
                this.contactDetailsService.findDuplicateLead();
                if (duplicateContact != null) {
                    // check if it's e2e contact or regular duplicate
                    if (duplicateContact.OpportunityContactRoles != null) {
                        for (OpportunityContactRole contactRole : duplicateContact.OpportunityContactRoles) {
                            if (contactRole.Opportunity.AccountId == duplicateContact.AccountId) {
                                // e2e duplicate
                                this.contactDetailsService.updateOpportunityToLost();
                                this.contactDetailsService.setContact(duplicateContact);
                                this.contactDetailsService.setOpportunity(contactRole.Opportunity);
                                this.contactDetailsService.updateRecord(true);
                                String userName = UserInfo.getName();
                                String url;
                                if (userName == 'E2E Site Guest User') {
                                    url = '/e2eFormCH?country=' + this.countryParam + '&source=';
                                } else {
                                    url = '/apex/e2eFormCH?country=' + this.countryParam + '&source=';
                                }
                                PageReference reference = new PageReference(url + contactRole.Opportunity.E2E_Encoded_URL__c);
                                reference.setRedirect(true);
                                this.endApexCall = Datetime.now();
                                LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, contactRole.Opportunity.Id, currentActiveSubstep, this.activeSubStep, null, this.country, 'Desktop');
                                return reference;
                            }
                        }
                    }
                    // standard duplicate
                    this.contactDetailsService.updateOpportunityToLost();
                    this.contactDetailsService.setContact(duplicateContact);
                    this.contactDetailsService.updateRecord(false);
                    this.contactDetailsService.insertRecords(duplicateContact, 'Desktop');
                } else {
                    // update contact if no dups
                    this.contactDetailsService.updateRecord(false);
                }
                this.opportunity = this.contactDetailsService.getOpportunity();
                initPageElements();
                initSObjects(this.opportunity.Id);
                doPreFillingFormFields();
            }
            chatService.setOpportunity(this.opportunity);
            chatService.setContact(contact);
            prepareOnlineChat();
            if (formOfBusiness == 'Solo-trader') {
                this.stepPagesMap.get('CREDIT SCORE. SEARCH COMPANY').fields.get('COMPANY NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = contact.Name;
            }
            if (this.selectedAvailableCompanyCreditScoring != null) this.selectedAvailableCompanyCreditScoring.identificationnumber = null; // disable continue button
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, this.country, 'Desktop');
            return null;
        } catch (Exception e) {
            this.activeStep = 0;
            this.activeSubStep = 'System error';
            initPageElements();
            if (this.opportunity != null && this.opportunity.Id != null) {
                initSObjects(this.opportunity.Id);
                E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
                E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'goToCreditScoring()', e);
            } else {
                E2EExceptionUtils.sendExceptionEmail(null, null, null, 'Desktop', 'goToCreditScoring()', e);
            }
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : backToCreditScoring()
    *  Summary         : back to step 1
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void backToCreditScoring() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            this.startApexCall = Datetime.now();
            this.activeInnerPage = '';
            this.activeStep = 1;
            this.activeSubStep = 'Search company';
            this.activeInnerPageCreditScoring = '';
            this.continueButtonIsDisabled = false;
            this.stepPagesMap.get('CREDIT SCORE. SEARCH COMPANY').fields.get('COMPANY NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = this.selectedAvailableCompanyCreditScoring.name;
            this.selectedAvailableCompanyCreditScoring.identificationnumber = null;
            prepareOnlineChat();
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, this.country, 'Desktop');
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'backToCreditScoring()', e);
        }
    }


    /*******************************************************************************
    *  Name            : editCreditLimit()
    *  Summary         : back to edit credit limit substep
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void editCreditLimit() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            this.startApexCall = Datetime.now();
            this.activeInnerPage = '';
            this.activeStep = 1;
            initPageElements();
            initSObjects(opportunity.Id);
            opportunity.E2E_Active_Substep__c = 'Calculating credit score';
            doPreFillingFormFields();
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, this.country, 'Desktop');
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'editCreditLimit()', e);
        }
    }


    /*******************************************************************************
    *  Name            : editTotalConsumption()
    *  Summary         : back to edit total consumption substep
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void editTotalConsumption() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            this.startApexCall = Datetime.now();
            this.activeInnerPage = '';
            this.activeStep = 1;
            this.activeSubStep = 'Set total consumption';
            initPageElements();
            initSObjects(opportunity.Id);
            opportunity.E2E_Active_Substep__c = '';
            doPreFillingFormFields();
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, this.country, 'Desktop');
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'editTotalConsumption()', e);
        }
    }


    /*******************************************************************************
    *  Name            : editCompanyDetails()
    *  Summary         : go to search company step
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void editCompanyDetails() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            this.startApexCall = Datetime.now();
            this.activeInnerPage = '';
            this.activeStep = 1;
            this.activeSubStep = 'Search company';
            initPageElements();
            initSObjects(opportunity.Id);
            opportunity.E2E_Active_Substep__c = '';
            doPreFillingFormFields();
            this.continueButtonIsDisabled = false;
            this.selectedAvailableCompanyCreditScoring.identificationnumber = null;
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, this.country, 'Desktop');
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'editCompanyDetails()', e);
        }
    }


    /*******************************************************************************
    *  Name            : editContactDetails()
    *  Summary         : go to edit contact details step
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void editContactDetails() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            this.startApexCall = Datetime.now();
            this.activeInnerPage = '';
            this.activeStep = 0;
            this.activeSubStep = 'Contact details';
            initPageElements();
            initSObjects(opportunity.Id);
            doPreFillingFormFields();
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, this.country, 'Desktop');
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'editContactDetails()', e);
        }
    }


    /*******************************************************************************
    *  Name            : doSaveCompanyDetailsData()
    *  Summary         : do save company details data
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doSaveCompanyDetailsData() {
        try {
            this.startApexCall = Datetime.now();
            disableTriggers();
            this.creditScoringService.validateFields('company details');
            this.creditScoringService.saveCompanyDetails();
            this.continueButtonIsDisabled = false;
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeInnerPage, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'doSaveCompanyDetailsData()', e);
        }
    }


    /*******************************************************************************
    *  Name            : doSearchCompany()
    *  Summary         : search company
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doSearchCompany() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            this.activeInnerPage = '';
            this.creditScoringService.setOpportunity(this.opportunity.Id);
            this.opportunity = this.creditScoringService.getOpportunity();
            this.creditScoringService.validateFields('company details');

            this.creditScoringService.setCompaniesFromCF(this.opportunity.Id);
            this.availableCompaniesListCreditScoring = this.creditScoringService.getCompaniesFromCF();
            disableTriggers();
            this.opportunity.CF_Stage__c = 'Launched';
            this.opportunity.E2E_Number_of_Search_Companies__c = this.availableCompaniesListCreditScoring.companiesMap.size();
            update this.opportunity;
            if (this.selectedAvailableCompanyCreditScoring == null) this.selectedAvailableCompanyCreditScoring = new CreditCompany();
            if (! this.availableCompaniesListCreditScoring.companiesMap.isEmpty() ) {
                this.activeInnerPageCreditScoring = 'Select company';
            } else {
                throw new LongFormException(E2EExceptionUtils.errorsMap.get('Company not found'));
            }
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, 'This is a company search process.', this.country, 'Desktop');
        } catch (Exception e) {
            if (e.getMessage() == E2EExceptionUtils.errorsMap.get('Company not found')) {
                this.activeStep = null;
                this.activeSubStep = 'Company not found';
                E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubStep, e);
            } else {
                this.activeSubstep = 'System error';
                E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
                E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'doSearchCompany()', e);
            }
        }
    }


    /*******************************************************************************
    *  Name            : goToSetTotalConsumption()
    *  Summary         : go to total consumption substep
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void goToSetTotalConsumption() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            disableTriggers();
            this.activeInnerPage = '';
            this.activeStep = 1;
            this.activeSubStep = 'Set total consumption';
            // check if we have more than two paid reports
            if (this.opportunity.E2E_CF_Reports_Counter__c > 2) {
                this.activeInnerPage = null;
                this.activeStep = null;
                this.opportunity.E2E_CF_Reports_Counter__c = 2;
                this.activeSubStep = 'Too many reports';
                E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubStep, null);
                return;
            }
            this.creditScoringService.doGenerateCreditFactoryReport(this.selectedAvailableCompanyCreditScoring.identificationnumber);
            this.creditScoringService.setCreditReportFromSF(this.opportunity.Id);
            this.cfReportResponse = this.creditScoringService.getCreditReportFromSF();
            this.selectedAvailableCompanyCreditScoring = this.cfReportResponse.company;

            // duplication
            String stopProcess = this.creditScoringService.searchDuplicates(selectedAvailableCompanyCreditScoring);
            if (stopProcess != null) {
                this.activeStep = null;
                this.activeSubstep = stopProcess;
                E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeInnerPage, null);
                return;
            }
            this.creditScoringService.doUpdateSFobjects(this.cfReportResponse);
            this.creditScoringService.setResultOfCheckBlackList();
            this.account = this.creditScoringService.getAccount();
            if (this.account.Umsatzsteuer_ID__c == null) {
               this.activeSubStep = 'Enter Tax ID';
            }

            E2E_Form_General_Settings__c settings = E2E_Form_General_Settings__c.getInstance(this.country);
            if (settings.Enable_authorization_non_granted_check__c) {
                Boolean isAuthorizatedGranted = this.creditScoringService.getResultOfCheckAuthorizatedGranted();
                Boolean isNotAtBlackList = this.creditScoringService.getResultOfCheckBlackList();
                if (! isAuthorizatedGranted || ! isNotAtBlackList) {
                   this.activeStep = null;
                   if (! isAuthorizatedGranted ) {
                       this.activeSubStep = 'Authorization not granted';
                   } else
                   if (! isNotAtBlackList ) {
                       this.activeSubStep = 'Black list';
                   }
                   E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubStep, null);
                   return;
                }
            }
            if (this.opportunity.Total_consumption_l_month__c != null) {
                this.stepPagesMap.get('CREDIT SCORE. TOTAL CONSUMPTION').fields.get('TOTAL CONSUMPTION').elementItemsMap.get('DEFAULT VALUE').Value__c = String.valueOf(this.opportunity.Total_consumption_l_month__c);
            }
            prepareOnlineChat();
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, this.country, 'Desktop');
        } catch (Exception e) {
            initSObjects(opportunity.Id);
            if (e.getMessage() == E2EExceptionUtils.errorsMap.get('Report does not exist')) {
                this.activeStep = null;
                this.activeSubStep = 'Report does not exist';
                E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubStep, e);
            } else {
                this.activeSubstep = 'System error';
                E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
                E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'goToSetTotalConsumption()', e);
            }
        }
    }


    /*******************************************************************************
    *  Name            : deleteReportsForPreviousCompany()
    *  Summary         : Delete all credit factory reports if user selects new company
    *  CreatedDate     : 21/01/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void deleteReportsForPreviousCompany() {
        try {
            this.startApexCall = Datetime.now();
            this.creditScoringService.deleteCreditFactoryReports(this.selectedAvailableCompanyCreditScoring.identificationnumber);
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, this.country, 'deleteReportsForPreviousCompany()', e);
        }
    }


    /*******************************************************************************
    *  Name            : continueToTotalConsumption()
    *  Summary         : continue to "Total consumption" substep from "Another Tax Id" substep
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void continueToTotalConsumption() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            this.startApexCall = Datetime.now();
            disableTriggers();
            // duplication
            String stopProcess = this.creditScoringService.searchDuplicates(selectedAvailableCompanyCreditScoring);
            if (stopProcess != null) {
                this.activeInnerPage = stopProcess;
                this.activeStep = null;
                this.activeSubstep = null;
                E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeInnerPage, null);
                return;
            }
            // Switzerland use VATID but call it TAXID. The code below is ok.
            this.creditScoringService.doUpdateTaxId(selectedAvailableCompanyCreditScoring.vatid);
            this.creditScoringService.setResultOfCheckBlackList();
            E2E_Form_General_Settings__c settings = E2E_Form_General_Settings__c.getInstance(this.country);
            if (settings.Enable_authorization_non_granted_check__c) {
                Boolean isNotAtBlackList = this.creditScoringService.getResultOfCheckBlackList();
                if (! isNotAtBlackList) {
                    this.activeStep = null;
                    this.activeSubStep = 'Black list';
                    E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubStep, null);
                    return;
                }
            }
            this.activeInnerPage = '';
            this.activeSubStep = 'Set total consumption';
            this.continueButtonIsDisabled = true;
            prepareOnlineChat();
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, this.country, 'Desktop');
        } catch (Exception e) {
            initSObjects(opportunity.Id);
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'continueToTotalConsumption()', e);
        }
    }


    /*******************************************************************************
    *  Name            : backToSetTotalConsumption()
    *  Summary         : go to back to set prognosed pumping
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void backToSetTotalConsumption() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            this.startApexCall = Datetime.now();
            this.activeInnerPage = '';
            this.activeStep = 1;
            this.activeSubStep = 'Set total consumption';
            prepareOnlineChat();
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, this.country, 'Desktop');
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'backToSetTotalConsumption()', e);
        }
    }


    /*******************************************************************************
    *  Name            : doCalculateCreditScoring()
    *  Summary         : calculating credit scoring
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doCalculateCreditScoring() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            this.startApexCall = Datetime.now();
            disableTriggers();
            this.activeInnerPage = '';
            this.creditScoringService.validateFields('Set total consumption');
            this.creditScoringService.saveTotalConsumption();
            this.account = this.creditScoringService.getAccount();
            this.creditScoringService.getCreditScoreData(opportunity.Id);
            this.cfDecision = this.creditScoringService.getCfDecision();
            this.creditScoringService.setCreditReportFromSF(opportunity.Id);
            this.cfReportResponse = this.creditScoringService.getCreditReportFromSF();
            this.selectedAvailableCompanyCreditScoring = this.cfReportResponse.company;
            this.defaultBillingPeriod = Integer.valueOf(this.cfReportResponse.recommendedBillingPeriod);
            this.defaultBillingPeriodTemp = this.defaultBillingPeriod;
            this.creditLimit = this.cfReportResponse.creditLimitDefault;
            this.creditLimit30_Plus27 = this.cfReportResponse.creditLimit30_Plus27;
            this.maxCreditLimit30_Plus27 = this.cfReportResponse.maxCreditLimit30_Plus27;
            this.maxValue30_Plus27 = this.cfReportResponse.maxValue30_Plus27;
            this.deposit30_Plus27 = this.cfReportResponse.deposit30_Plus27;
            returnFinalCreditScoreData();

            this.activeSubStep = 'Calculating credit score';
            if (this.cfDecision.verdict == 'No') {
                this.activeSubStep = ''; // now verdict = 'No' is available to status code = 003 only
                if (this.cfDecision.statusCode == '003') {
                    throw new LongFormException(E2EExceptionUtils.errorsMap.get('Too high limit'));
                }
            }
            prepareOnlineChat();
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, this.country, 'Desktop');
        } catch (Exception e) {
            if (e.getMessage() == E2EExceptionUtils.errorsMap.get('Too high limit')) {
                this.activeStep = null;
                this.activeSubStep = 'Too high limit';
                E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubStep, e);
            } else {
                this.activeSubstep = 'System error';
                E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
                E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'doCalculateCreditScoring()', e);
            }
        }
    }


    /*******************************************************************************
    *  Name            : doRecalculateDeposit()
    *  Summary         : recalculate deposit
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doRecalculateDeposit() {
        try {
            this.activeInnerPage = '';
            creditScoringService.setDeposit(this.selectedAvailableCompanyCreditScoring, this.defaultBillingPeriod, null, this.creditLimit, this.maxCreditLimit);
            this.deposit = creditScoringService.getDeposit();
            creditScoringService.resetCfDecision(this.defaultBillingPeriod, null, this.deposit, this.selectedAvailableCompanyCreditScoring.classRating, this.selectedAvailableCompanyCreditScoring);
            this.cfDecision = creditScoringService.getCfDecision();
        } catch(Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'doRecalculateDeposit()', e);
        }
    }


    /*******************************************************************************
    *  Name            : returnFinalCreditScoreData()
    *  Summary         : return final of credit score data
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void returnFinalCreditScoreData() {
        this.minCreditLimit = this.creditLimit30_Plus27;
        this.maxCreditLimit = this.maxCreditLimit30_Plus27;
        this.maxValue = this.maxValue30_Plus27;
        this.deposit = this.deposit30_Plus27;
    }


    /*******************************************************************************
    *  Name            : goToCardsConfig()
    *  Summary         : go to long form step 2
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void goToCardsConfig() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            this.startApexCall = Datetime.now();
            disableTriggers();
            this.activeInnerPage = '';
            this.activeStep = 2;
            this.activeSubStep = 'Card configuration';
            creditScoringService.saveCreditScoringResult(this.defaultBillingPeriod, null, this.creditLimit, this.deposit);
            creditScoringService.setOpportunity(this.opportunity.Id);
            this.opportunity = creditScoringService.getOpportunity();
            initPageElements();
            initSObjects(opportunity.Id);
            this.cardsConfigService.setContinueButtonStatus(this.activeStep, this.activeSubStep);
            this.continueButtonIsDisabled = this.cardsConfigService.getContinueButtonStatus();
            doPreFillingFormFields();
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, this.country, 'Desktop');
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'goToCardsConfig()', e);
        }
    }


    /*******************************************************************************
    *  Name            : changeNumberOfCards()
    *  Summary         : change total number of cards
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void changeNumberOfCards() {
        try {
            if (this.numberOfCards == null || this.numberOfCards == 0) {
                this.numberOfCards = 1;
            }
            if (this.numberOfCards > 50) {
                this.numberOfCards = 50;
            }
            this.activeInnerPage = '';
            this.cardsConfigService.changeNumberOfCards(this.numberOfCards);
            this.sameCardsMap = this.cardsConfigService.getSameCards();
            this.diffCardsMap = this.cardsConfigService.getDiffCards();
            if (this.numberOfCards == 1) {
                this.cardsConfigService.setActiveCardConfigTab('same');
                this.activeCardConfigTab = this.cardsConfigService.getActiveCardConfigTab();
            }
            calculateFeesAndCosts();
        } catch (Exception e) {
            this.numberOfCards = this.cardsConfigService.getNumberOfCards();
            if (e.getMessage() == 'Remove extra cards error') {
                this.activeInnerPage = 'Remove extra cards';
                this.activeCardConfigTab = 'diff';
            } else if (e.getMessage() == 'No more 2 card error') {
                this.activeInnerPage = 'No more 2 card error';
            } else if (e.getMessage() == 'No more 5 card error') {
                this.activeInnerPage = 'No more 5 card error';
            } else {
                this.activeSubstep = 'System error';
                E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
                E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'changeNumberOfCards()', e);
            }
        }
    }


    /*******************************************************************************
    *  Name            : changeActiveTab()
    *  Summary         : change active tab and calculate fees and costs
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void changeActiveTab() {
        try {
            this.activeInnerPage = '';
            cardsConfigService.setActiveCardConfigTab(this.activeCardConfigTab);
            this.activeCardConfigTab = cardsConfigService.getActiveCardConfigTab();
            this.numberOfCards = cardsConfigService.getNumberOfCards();
            this.numberOfDiffCards = this.diffCardsMap.size();
            calculateFeesAndCosts();
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'changeActiveTab()', e);
        }
    }


    /*******************************************************************************
    *  Name            : addCard()
    *  Summary         : add new card and go to next one
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void addCard() {
        try {
            this.activeInnerPage = '';
            Integer cardIndex = Integer.valueOf(ApexPages.CurrentPage().getparameters().get('cardIndex'));
            this.cardsConfigService.addCard(cardIndex);
            this.diffCardsMap = this.cardsConfigService.getDiffCards();
            this.numberOfDiffCards = this.diffCardsMap.size();
            calculateFeesAndCosts();
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'addCard()', e);
        }
    }


    /*******************************************************************************
    *  Name            : editCardConfiguration()
    *  Summary         : open configuration block for selected card
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void editCardConfiguration() {
        try {
            this.activeInnerPage = '';
            Integer cardIndex = Integer.valueOf(ApexPages.CurrentPage().getparameters().get('cardIndex'));
            this.cardsConfigService.editCardConfiguration(cardIndex);
            this.diffCardsMap = this.cardsConfigService.getDiffCards();
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'editCardConfiguration()', e);
        }
    }


    /*******************************************************************************
    *  Name            : removeCard()
    *  Summary         : remove the card
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void removeCard() {
        try {
            this.activeInnerPage = '';
            Integer cardIndex = Integer.valueOf(ApexPages.CurrentPage().getparameters().get('cardIndex'));
            this.cardsConfigService.removeCard(cardIndex);
            this.diffCardsMap = this.cardsConfigService.getDiffCards();
            this.numberOfCards = this.cardsConfigService.getNumberOfCards();
            this.numberOfDiffCards = this.diffCardsMap.size();
            if (this.diffCardsMap.size() == 1) {
                this.sameCardsMap = this.cardsConfigService.getSameCards();
                this.activeCardConfigTab = this.cardsConfigService.getActiveCardConfigTab();
            }
            calculateFeesAndCosts();
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'removeCard()', e);
        }
    }


    /*******************************************************************************
    *  Name            : calculateFeesAndCosts()
    *  Summary         : calculate fees and costs for selected cards
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void calculateFeesAndCosts() {
        if (this.activeCardConfigTab == 'same' && this.numberOfCards > 1) {
            this.cardsConfigService.rebuildSameMap();
            this.sameCardsMap = this.cardsConfigService.getSameCards();
        }
        this.cardsConfigService.setCostsColumnsMap();
        this.costsColumnsMap = this.cardsConfigService.getCostsColumnsMap();
        this.showInternationalFeesBlock = this.cardsConfigService.getInternationalFeesBlock();
        this.cardsConfigService.setContinueButtonStatus(this.activeStep, this.activeSubStep);
        this.continueButtonIsDisabled = this.cardsConfigService.getContinueButtonStatus();
    }


    /*******************************************************************************
    *  Name            : saveConfiguration()
    *  Summary         : saving all selected cards
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void goToSpecialOffers() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            this.startApexCall = Datetime.now();
            disableTriggers();
            this.activeInnerPage = '';
            if (this.sameCardsMap.size() != this.numberOfCards) {
                this.cardsConfigService.changeNumberOfCards(this.numberOfCards);
                this.sameCardsMap = this.cardsConfigService.getSameCards();
            }
            this.cardsConfigService.saveCardsConfigResult();
            this.cardsConfigService.setSpecialOffers('Desktop');
            this.diffCardsMap = this.cardsConfigService.getDiffCards();
            this.sameCardsMap = this.cardsConfigService.getSameCards();
            this.nonHomeOffersList = this.cardsConfigService.getnonHomeOffersList();
            this.cardsConfigService.setFinalOrderCardsMap();
            this.finalCardsMap = this.cardsConfigService.getFinalOrderCardsMap();
            this.activeStep = 2;
            this.activeSubStep = 'Choosing offer';
            this.cardsConfigService.setContinueButtonStatus(this.activeStep, this.activeSubStep);
            this.continueButtonIsDisabled = this.cardsConfigService.getContinueButtonStatus();
            prepareOnlineChat();
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, this.country, 'Desktop');
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'goToSpecialOffers()', e);
        }
    }


    /*******************************************************************************
    *  Name            : backToCardConfiguration()
    *  Summary         : back to card configuration page
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void backToCardConfiguration() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            this.startApexCall = Datetime.now();
            this.activeInnerPage = '';
            this.activeStep = 2;
            this.activeSubStep = 'Card configuration';
            this.activeCardConfigTab = this.cardsConfigService.getActiveCardConfigTab();
            this.cardsConfigService.setContinueButtonStatus(this.activeStep, this.activeSubStep);
            this.continueButtonIsDisabled = this.cardsConfigService.getContinueButtonStatus();
            prepareOnlineChat();
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, this.country, 'Desktop');
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'backToCardConfiguration()', e);
        }
    }


    /*******************************************************************************
    *  Name            : goToTechnicalParameters()
    *  Summary         : go to technical parameters
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void goToTechnicalParameters() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            this.startApexCall = Datetime.now();
            disableTriggers();
            this.activeInnerPage = '';
            this.cardsConfigService.saveSpecialOffer();
            this.activeStep = 2;
            this.activeSubStep = 'Technical parameters';
            this.cardsConfigService.setEmbossingBlockVisibilityStatus();
            this.cardsConfigService.setContinueButtonStatus(this.activeStep, this.activeSubStep);
            this.continueButtonIsDisabled = this.cardsConfigService.getContinueButtonStatus();
            this.cardsConfigService.setOpportunity(this.opportunity.Id);
            this.opportunity = this.cardsConfigService.getOpportunity();
            prepareOnlineChat();
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, this.country, 'Desktop');
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'goToTechnicalParameters()', e);
        }
    }


    /*******************************************************************************
    *  Name            : editTechnicalParameters()
    *  Summary         : edit technical parameters
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void editTechnicalParameters() {
        try {
            this.activeInnerPage = '';
            this.cardsConfigService.editTechnicalParameters(Integer.valueOf(ApexPages.CurrentPage().getparameters().get('cardindex')));
            this.finalCardsMap = this.cardsConfigService.getFinalOrderCardsMap();
            this.continueButtonIsDisabled = this.cardsConfigService.getContinueButtonStatus();
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'editTechnicalParameters()', e);
        }
    }


    /*******************************************************************************
    *  Name            : editCompanyName()
    *  Summary         : edit company name
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void editCompanyName() {
        try {
            this.activeInnerPage = '';
            this.cardsConfigService.editCompanyName(Integer.valueOf(ApexPages.CurrentPage().getparameters().get('cardindex')));
            this.finalCardsMap = this.cardsConfigService.getFinalOrderCardsMap();
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'editCompanyName()', e);
        }
    }


    /*******************************************************************************
    *  Name            : saveTechParamForSingleCard()
    *  Summary         : save technical params for single card
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void saveTechParamForSingleCard() {
        try {
            this.activeInnerPage = '';
            this.cardsConfigService.saveTechParamForSingleCard(Integer.valueOf(ApexPages.CurrentPage().getparameters().get('cardindex')));
            this.finalCardsMap = this.cardsConfigService.getFinalOrderCardsMap();
            this.cardsConfigService.setContinueButtonStatus(this.activeStep, this.activeSubStep);
            this.continueButtonIsDisabled = this.cardsConfigService.getContinueButtonStatus();
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'saveTechParamForSingleCard()', e);
        }
    }


    /*******************************************************************************
    *  Name            : backToSpecialOffers()
    *  Summary         : back to special offers substep
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void backToSpecialOffers() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            this.startApexCall = Datetime.now();
            this.activeInnerPage = '';
            this.activeStep = 2;
            this.activeSubStep = 'Choosing offer';
            this.cardsConfigService.setContinueButtonStatus(this.activeStep, this.activeSubStep);
            this.continueButtonIsDisabled = this.cardsConfigService.getContinueButtonStatus();
            prepareOnlineChat();
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, this.country, 'Desktop');
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'backToSpecialOffers()', e);
        }
    }


    /*******************************************************************************
    *  Name            : editCardsFeesAndCosts()
    *  Summary         : edit cards configuration and their fees and costs
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void editCardsFeesAndCosts() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            this.startApexCall = Datetime.now();
            this.activeInnerPage = '';
            this.activeSubstep = 'Card configuration';
            if (this.activeStep != 2) {
                this.activeStep = 2;
                initPageElements();
                initSObjects(opportunity.Id);
                doPreFillingFormFields();
            } else {
                this.activeCardConfigTab = this.cardsConfigService.getActiveCardConfigTab();
                calculateFeesAndCosts();
            }
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, this.country, 'Desktop');
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'editCardsFeesAndCosts()', e);
        }
    }


    /*******************************************************************************
    *  Name            : goToAdditionalParams()
    *  Summary         : go to "Additional" step
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void goToAdditionalParams() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            this.startApexCall = Datetime.now();
            disableTriggers();
            this.activeInnerPage = '';
            this.activeStep = 3;
            this.activeSubStep = 'Additional services';
            this.cardsConfigService.saveTechParamForAllCards(this.activeSubStep);
            initPageElements();
            initSObjects(opportunity.Id);
            doPreFillingFormFields();
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, this.country, 'Desktop');
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'goToAdditionalParams()', e);
        }
    }


    /*******************************************************************************
    *  Name            : backToAdditionalParams()
    *  Summary         : back to "Additional" step
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void backToAdditionalParams() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            this.startApexCall = Datetime.now();
            this.activeInnerPage = '';
            this.activeStep = 3;
            this.activeSubstep = '';
            initPageElements();
            initSObjects(opportunity.Id);
            doPreFillingFormFields();
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, this.country, 'Desktop');
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'backToAdditionalParams()', e);
        }
    }


    /*******************************************************************************
    *  Name            : backToTechnicalParams()
    *  Summary         : back to technical params
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void backToTechnicalParams() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            this.startApexCall = Datetime.now();
            this.activeInnerPage = '';
            this.activeStep = 2;
            this.activeSubStep = 'Technical parameters';
            initPageElements();
            initSObjects(opportunity.Id);
            doPreFillingFormFields();
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, this.country, 'Desktop');
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'backToTechnicalParams()', e);
        }
    }


    /*******************************************************************************
    *  Name            : goToPaymentOptions()
    *  Summary         : Save CO2 if it exists and go to payments options (STEP 4)
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public PageReference goToPaymentOptions() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            this.startApexCall = Datetime.now();
            disableTriggers();
            this.additionalService.updateRecords();
            this.opportunity = this.additionalService.getOpportunity();
            this.activeInnerPage = '';
            this.activeSubStep = this.opportunity.E2E_Active_Substep__c;
            this.activeStep = Integer.valueOf(this.opportunity.E2E_Active_Step__c);
            initPageElements();
            initSObjects(this.opportunity.Id);
            doPreFillingFormFields();
            String userName = UserInfo.getName();
            String url;
            if (userName == 'E2E Site Guest User') {
                url = '/e2eFormCH?country=' + this.countryParam + '&source=';
            } else {
                url = '/apex/e2eFormCH?country=' + this.countryParam + '&source=';
            }
            PageReference paymentPage = new PageReference(url + this.opportunity.E2E_Encoded_URL__c);
            paymentPage.setRedirect(true);
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, this.country, 'Desktop');
            return paymentPage;
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'goToPaymentOptions()', e);
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : changePaymentMethod()
    *  Summary         : set payment method
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    // public void changePaymentMethod() {
    //     try {
    //         this.activeInnerPage = '';
    //         this.paymentOptionsService.updatePaymentMethod(this.selectedPaymentMethod);
    //         getTransactionParameters();
    //     } catch (Exception e) {
    //         this.activeSubstep = 'System error';
    //         E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
    //         E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'changePaymentMethod()', e);
    //     }
    // }


    /*******************************************************************************
    *  Name            : getTransactionParameters()
    *  Summary         : Get payment parameters
    *  CreatedDate     : 20/02/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    // private void getTransactionParameters() {
    //     if (E2EKeysAPI__c.getValues(this.customSettingName) != null) {
    //         this.paymentURL = E2EKeysAPI__c.getValues(this.customSettingName).paymentTransactionURL__c;
    //         this.paymentParameters = this.paymentOptionsService.getPaymentMap();
    //     }
    // }


    public void showTermConditionsModal() {
        this.activeInnerPage = 'ModalTermConditions';
    }

    public void showDepositAgreementModal() {
        this.activeInnerPage = 'ModalDepositAgreement';
    }

    public void closeModal(){
        this.activeInnerPage = null;
    }

    public void savePaymentTransaction() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            this.startApexCall = Datetime.now();
            disableTriggers();
            this.activeInnerPage = '';
            this.paymentOptionsService.validate(this.activeStep, this.activeSubStep);
            // this.paymentOptionsService.saveTransactionData();
            this.paymentOptionsService.savePaymentOptionsDataWithDeposit(this.activeSubStep);
            this.paymentOptionsService.setOpportunity(this.opportunity.Id);
            this.opportunity = this.paymentOptionsService.getOpportunity();

            this.activeStep = 5;
            this.activeSubstep = 'Congratulations';
            initPageElements();
            initSObjects(this.opportunity.Id);
            doPreFillingFormFields();
            EmarsysSenderEuropeanService.sendE2EOpportunityToEmarsys(this.opportunity.Id);

            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, this.country, 'Desktop');
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'savePaymentTransaction()', e);
        }
    }


    /*******************************************************************************
    *  Name            : showDDmandateAcceptanceDocModal()
    *  Summary         : show "Direct Debit Mandate Acceptance" modal window
    *  CreatedDate     : 06/02/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void showDDmandateAcceptanceDocModal() {
        this.activeInnerPage = 'ModalDDmandateAcceptance';
    }


    /******************************************************************************
    *  Name            : disableTriggers()
    *  Summary         : disabling SF triggers
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void disableTriggers() {
        AccountTriggerHandler.enablesTrigger = false;
        ContactTriggerHandler.enablesTrigger = false;
        OpportunityTriggerHandler.enablesTrigger = false;
        OpportunityTriggerHandler.isE2EForm = true;
    }


    /*******************************************************************************
    *  Name            : deactivateInactiveServices()
    *  Summary         : deactivate inactive e2e services when changing to another step (Reset Viewstate)
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void deactivateInactiveServices() {
        if (this.activeStep == 0) {
            // 1 step
            this.cfDecision =  null;
            this.cfReportResponse = null;
            this.creditScoringService = null;
            this.availableCompaniesListCreditScoring = null;
            this.creditLimit = null;
            this.creditLimit30_Plus27 = null;
            this.defaultBillingPeriod = null;
            this.defaultBillingPeriodTemp = null;
            this.deposit = null;
            this.deposit30_Plus27 = null;
            this.maxCreditLimit = null;
            this.maxCreditLimit30_Plus27 = null;
            this.maxValue = null;
            this.maxValue30_Plus27 = null;
            // 2 step
            this.cardsConfigService = null;
            this.nonHomeOffersList = null;
            this.selectedAvailableCompanyCreditScoring = null;
            this.activeCardConfigTab = null;
            // 3 step
            this.additionalService = null;
            // 4 step
            this.paymentOptionsService = null;
        } else if (this.activeStep == 1) {
            // 0 step
            this.contactDetailsService = null;
            // 2 step
            this.cardsConfigService = null;
            this.nonHomeOffersList = null;
            this.activeInnerPageCreditScoring = null;
            // 3 step
            this.additionalService = null;
            // 4 step
            this.paymentOptionsService = null;
        } else if (this.activeStep == 2) {
            // 0 step
            this.contactDetailsService = null;
            // 1 step
            this.cfDecision =  null;
            this.cfReportResponse = null;
            this.creditScoringService = null;
            this.availableCompaniesListCreditScoring = null;
            this.creditLimit = null;
            this.creditLimit30_Plus27 = null;
            this.defaultBillingPeriod = null;
            this.defaultBillingPeriodTemp = null;
            this.deposit = null;
            this.deposit30_Plus27 = null;
            this.maxCreditLimit = null;
            this.maxCreditLimit30_Plus27 = null;
            this.maxValue = null;
            this.maxValue30_Plus27 = null;
            this.minCreditLimit = null;
            // 3 step
            this.additionalService = null;
            // 4 step
            this.paymentOptionsService = null;
        } else if (this.activeStep == 3) {
            // 0 step
            this.contactDetailsService = null;
            // 1 step
            this.cfDecision =  null;
            this.cfReportResponse = null;
            this.creditScoringService = null;
            this.availableCompaniesListCreditScoring = null;
            this.creditLimit = null;
            this.creditLimit30_Plus27 = null;
            this.defaultBillingPeriod = null;
            this.defaultBillingPeriodTemp = null;
            this.deposit = null;
            this.deposit30_Plus27 = null;
            this.maxCreditLimit = null;
            this.maxCreditLimit30_Plus27 = null;
            this.maxValue = null;
            this.maxValue30_Plus27 = null;
            this.minCreditLimit = null;
            // 2 step
            this.cardsConfigService = null;
            this.nonHomeOffersList = null;
            this.activeInnerPageCreditScoring = null;
            // 4 step
            this.paymentOptionsService = null;
        } else if (this.activeStep == 4) {
            // 0 step
            this.contactDetailsService = null;
            // 1 step
            this.cfDecision =  null;
            this.cfReportResponse = null;
            this.creditScoringService = null;
            this.availableCompaniesListCreditScoring = null;
            this.creditLimit = null;
            this.creditLimit30_Plus27 = null;
            this.defaultBillingPeriod = null;
            this.defaultBillingPeriodTemp = null;
            this.deposit = null;
            this.deposit30_Plus27 = null;
            this.maxCreditLimit = null;
            this.maxCreditLimit30_Plus27 = null;
            this.maxValue = null;
            this.maxValue30_Plus27 = null;
            this.minCreditLimit = null;
            // 2 step
            this.cardsConfigService = null;
            this.nonHomeOffersList = null;
            this.activeInnerPageCreditScoring = null;
            // 3 step
            this.additionalService = null;
        } else if (this.activeStep == 5) {
            // 0 step
            this.contactDetailsService = null;
            // 1 step
            this.cfDecision =  null;
            this.cfReportResponse = null;
            this.creditScoringService = null;
            this.availableCompaniesListCreditScoring = null;
            this.creditLimit = null;
            this.creditLimit30_Plus27 = null;
            this.defaultBillingPeriod = null;
            this.defaultBillingPeriodTemp = null;
            this.deposit = null;
            this.deposit30_Plus27 = null;
            this.maxCreditLimit = null;
            this.maxCreditLimit30_Plus27 = null;
            this.maxValue = null;
            this.maxValue30_Plus27 = null;
            this.minCreditLimit = null;
            // 2 step
            this.nonHomeOffersList = null;
            this.activeInnerPageCreditScoring = null;
            // 3 step
            this.additionalService = null;
        }
    }


    public void initChatSetup(){
        this.chatService = new LFChatService();
        this.chatService.setChatDefaultSettings(this.country);
        this.chatButtonId = this.chatService.chatButtonId;
        this.chatDeploymentId = this.chatService.chatDeploymentId;
        this.chatDeploymentJsURL = this.chatService.chatDeploymentJsURL;
        this.chatURL = this.chatService.chatURL;
        this.chatService.setPageMap(this.country);
        this.pageMapChat = this.chatService.getPagesMap();
    }

    @RemoteAction
    global static void setFlagChatToOpportunity(String oppId, String activeStep, String activeSubStep, String modeOfChat){
        if(modeOfChat != ''){
            LFChatService.setFlagChatToOpportunity(oppId, modeOfChat, Integer.valueof(activeStep), activeSubStep);
        }
    }

    @RemoteAction
    global static void saveOfflineChatLog(String oppId, String conId, String activeStep, String activeSubStep,  String textBody, String country){
         LFChatService.saveOfflineChatLog(textBody, '', Integer.valueof(activeStep), activeSubStep, country, oppId, conId);
    }


    public void prepareOnlineChat(){
        String clientNameToChat = '';
        if (contact != null) {
            clientNameToChat = ' ' + contact.Salutation + ' ' + contact.LastName;
        }
        chatFirstMessage = chatService.getFirstChatMessage(this.country, activeStep, activeSubStep, clientNameToChat);
    }


    /*******************************************************************************
    *  Name            : updateOpportunityOnReturnFromEmail()
    *  Summary         : Update Opportunity fields on return from marketing email
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void updateOpportunityOnReturnFromEmail() {
        if (this.activeStep == 0) {
            this.contactDetailsService.updateOpportunityOnReturnFromEmail('Desktop');
        } else if (this.activeStep == 1) {
            this.creditScoringService.updateOpportunityOnReturnFromEmail('Desktop');
        } else if (this.activeStep == 2) {
            this.cardsConfigService.updateOpportunityOnReturnFromEmail('Desktop');
        } else if (this.activeStep == 3) {
            this.additionalService.updateOpportunityOnReturnFromEmail('Desktop');
        } else if (this.activeStep == 4 || this.activeStep == 5) {
            this.paymentOptionsService.updateOpportunityOnReturnFromEmail('Desktop');
        }
    }
}