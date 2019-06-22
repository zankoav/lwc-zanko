global class LongFormDesktopFRController {
    public Account account {get; set;}
    public Contact contact {get; set;}
    public Opportunity opportunity {get; set;}
    public Integer activeStep {get; set;}
    public String activeSubStep {get; set;}
    public String activeInnerPage {get; set;}
    public String activeInnerPageCreditScoring {get; set;}
    public Boolean continueButtonIsDisabled {get; set;}
    private String opptyIdParam;
    public Map<String, LongFormPage> stepPagesMap {get; set;}
    public Map<Decimal, LongForm_Menu_Item__c> menuItemsMap {get; set;}
    // Contact details
    private LFContactDetails contactDetailsService;
    // Credit Score
    public LFCreditScoring creditScoringService;
    public CFSearchResponse availableCompaniesListCreditScoring {get; set;}
    public CFReportResponse cfReportResponse {get; set;}
    public CreditCompany selectedCompany {get; set;}
    public Integer defaultBillingPeriod {get; set;}
    public Decimal creditLimit {get; set;}
    public Decimal minCreditLimit {get; set;}
    public Decimal creditLimit7 {get; set;}
    public Decimal creditLimit15 {get; set;}
    public Decimal creditLimit30 {get; set;}
    public Decimal maxCreditLimit {get; set;}
    private Decimal maxCreditLimit7;
    private Decimal maxCreditLimit15;
    private Decimal maxCreditLimit30;
    public Decimal maxValue {get; set;}
    private Decimal maxValue7;
    private Decimal maxValue15;
    private Decimal maxValue30;
    public Decimal deposit {get; set;}
    public Decimal depositTemp {get; set;}
    private Decimal deposit7;
    private Decimal deposit15;
    private Decimal deposit30;
    public CreditFactoryDecision cfDecision {get; set;}
    // Card configuration
    private LFCardsConfig cardsConfigService;
    public Integer numberOfCards {get; set;}
    public Integer numberOfDiffCards {get; set;}
    public String activeCardConfigTab {get; set;}
    public Boolean showInternationalFeesBlock {get; set;}
    public Boolean showCardsEmbossingBlock {get; set;}
    public Map<String, List<LongFormCostItem>> costsColumnsMap {get; set;}
    public Map<Integer, LongFormCard> sameCardsMap {get; set;}
    public Map<Integer, LongFormCard> diffCardsMap {get; set;}
    public Map<Integer, LongFormCard> finalCardsMap {get; set;}
    public List<LongFormSpecialOffer> homeOffersList {get; set;}
    public List<LongFormSpecialOffer> nonHomeOffersList {get; set;}
    public String urlLocator {get; set;}
    public Boolean isVatIdValid {get; set;}
    public String jsonStation {get; set;}
    // Additional
    private LFAdditional additionalService;
    // Payment Options
    private LFPaymentOptions paymentOptionsService;
    public String paymentStatus {get; set;}
    public Map<String, String> paymentParameters {get; set;}
    public String paymentURL {get; set;}
    public String sepaDownloadURL {get; set;}
    public String selectedPaymentMethod {get; set;}
    public Boolean isIBANValid {get; set;}
    // ONLINE CHAT
    public Map<String, LongFormPage> pageMapChat {get; set;}
    public LFChatService chatService;
    public String chatButtonId {get;set;}
    public String chatDeploymentId {get; set;}
    public String chatDeploymentJsURL {get;set;}
    public String chatURL {get;set;}
    public String chatFirstMessage{get;set;}

    private Datetime startApexCall;
    private Datetime endApexCall;


    /*******************************************************************************
    *  Name            : init()
    *  Summary         : data initialization
    *  CreatedDate     : 22/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : PageReference – possible redirect to the mobile
    ******************************************************************************/
    public PageReference init() {
        try {
            this.activeStep = 0;
            String encryptedParams = ApexPages.CurrentPage().getParameters().get('source');
            if (encryptedParams != null && encryptedParams != '') doDecryptParams(encryptedParams);
            // check if it's mobile version
            PageReference mobileUrlRedirect = redirectToMobile(encryptedParams);
            if (mobileUrlRedirect != null) return mobileUrlRedirect;
            //menu
            LFMenu menuService = LongFormGlobalUtils.returnMenuService('France');
            menuService.setMenuItems('Desktop');
            this.menuItemsMap = menuService.getMenuItems();
            //do activate specific step
            initPageElements();
            initChatSetup();
            if (this.opptyIdParam != null) {
                initSObjects(this.opptyIdParam);
                updateOpportunityOnReturnFromEmail();
                if (this.opportunity.E2E_Active_Step__c != null && Integer.valueOf(this.opportunity.E2E_Active_Step__c) != this.activeStep) {
                    this.activeStep = Integer.valueOf(this.opportunity.E2E_Active_Step__c);
                    activateNewStep(this.opptyIdParam);
                } else {
                    doPreFillingFormFields();
                }
            }
            if (this.activeSubStep == null) this.activeSubStep = 'Contact details';
            return null;
        } catch (Exception e) {
            this.activeStep = null;
            this.activeSubStep = 'System error';
            if (this.stepPagesMap == null) this.stepPagesMap = new Map<String, LongFormPage>();
            this.stepPagesMap.putAll(LongFormGlobalUtils.returnErrorPage('France', 'Desktop'));
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'init()', e);
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : redirectToMobile(String encodedId)
    *  Summary         : If device is mobile then redirect to mobile version
    *  CreatedDate     : 22/08/2018
    *  ModifiedDate    : 13/12/2018 - by Eugene. Added PageReference instead of hardcoded params in url.
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
                    url = new PageReference('/e2eformmobfr');
                } else {
                    url = new PageReference('/apex/e2eformmobfr');
                }
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

    /* Init data */

    /*******************************************************************************
    *  Name            : initPageElements()
    *  Summary         : do activate specific step
    *  CreatedDate     : 22/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void initPageElements() {
        if (this.activeStep == 0) {
            // zero step elements
            this.contactDetailsService = LongFormGlobalUtils.returnContactDetailsService('France');
            this.contactDetailsService.setPagesMap('Desktop');
            this.stepPagesMap = this.contactDetailsService.getPagesMap();
        } else if (this.activeStep == 1) {
            // first step elements
            this.creditScoringService = LongFormGlobalUtils.returnCreditScoringService('France');
            this.creditScoringService.setPagesMap('Desktop');
            this.stepPagesMap = this.creditScoringService.getPagesMap();
        } else if (this.activeStep == 2) {
            // second step elements
            this.cardsConfigService = LongFormGlobalUtils.returnCardsConfigService('France');
            this.cardsConfigService.setPagesMap('Desktop');
            this.stepPagesMap = this.cardsConfigService.getPagesMap();
        } else if (this.activeStep == 3) {
            // third step elements
            this.additionalService = LongFormGlobalUtils.returnAdditionalService('France');
            this.additionalService.setPagesMap('Desktop');
            this.stepPagesMap = this.additionalService.getPagesMap();
            this.cardsConfigService = LongFormGlobalUtils.returnCardsConfigService('France');
            this.cardsConfigService.setPagesMap('Desktop');
        } else if (this.activeStep == 4 || this.activeStep == 5) {
            // fourth step elements
            this.paymentOptionsService = LongFormGlobalUtils.returnPaymentOptionsService('France');
            this.paymentOptionsService.setPagesMap('Desktop');
            this.stepPagesMap = this.paymentOptionsService.getPagesMap();
            this.paymentParameters = new Map<String, String>();
            this.cardsConfigService = LongFormGlobalUtils.returnCardsConfigService('France');
            this.cardsConfigService.setPagesMap('Desktop');
        }
    }


    /*******************************************************************************
    *  Name            : initSObjects(String opptyId)
    *  Summary         : init sobjects
    *  CreatedDate     : 22/08/2018
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
        } else if (this.activeStep == 4 || this.activeStep == 5) {
            this.cardsConfigService.setOpportunity(opptyId);
            this.paymentOptionsService.setSFobjects(opptyId);
            this.opportunity = this.paymentOptionsService.getOpportunity();
            this.account = this.paymentOptionsService.getAccount();
            this.contact = this.paymentOptionsService.getContact();
            this.cardsConfigService.setPriceLists();
        }
        if (this.account == null || this.opportunity == null || this.contact == null) throw new LongFormException('Error is merge or delete object');
    }


    /*******************************************************************************
    *  Name            : doPreFillingFormFields()
    *  Summary         : pre-filling form fields
    *  CreatedDate     : 22/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doPreFillingFormFields() {
        system.debug('zzzz='+stepPagesMap);
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
        if (this.paymentStatus != null && this.activeSubStep != 'Congratulations') {
            this.startApexCall = Datetime.now();
            // A - Accept
            // D - Declined
            // C - Cancel
            // E - Exception
            this.paymentOptionsService.goToThanksPageFromPaymentSystem(this.paymentStatus);
            this.activeStep = 5;
            this.activeSubStep = 'Congratulations';
            if (E2EKeysAPI__c.getValues('E2EFormFR') != null) {
                Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EFormFR').AES256_Key__c);
                // How to pay block
                this.stepPagesMap.get('CONGRATULATIONS').elements.get('HOW TO PAY BLOCK').get('SAVE PAYMENT INFORMATION DOWNLOAD URL').Value__c = '/apex/E2EAdditionalDocuments?hash=' +
                        E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=PaymentInformation&' + 'opportunityID=' + String.valueOf(opportunity.Id) +'&pdfDownload=TRUE&');
                // Direct Debit Mandate Acceptance
            }
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, 'Payment Gateway Service', this.activeSubstep, 'Return from a external service', 'France', 'Desktop');
        }
        deactivateInactiveServices();
    }


    /*******************************************************************************
    *  Name            : doPreFillingFieldsStep_0()
    *  Summary         : pre-filling of the nil step fields
    *  CreatedDate     : 22/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doPreFillingFieldsStep_0() {
        if (this.contact.Salutation != null) this.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = this.contact.Salutation;
        this.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = this.contact.FirstName;
        this.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = this.contact.LastName;
        this.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = this.contact.Phone;
        this.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = this.contact.Email;
        if (this.opportunity.Agree_to_Privacy_Policy__c != null) {
            this.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = String.valueOf(this.opportunity.Agree_to_Privacy_Policy__c);
        }
        if (this.opportunity.E2E_Form_of_Business__c != null) {
            this.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = this.opportunity.E2E_Form_of_Business__c;
        }
    }


    /*******************************************************************************
    *  Name            : doPreFillingFieldsStep_1()
    *  Summary         : pre-filling of the first step fields
    *  CreatedDate     : 22/08/2018
    *  ModifiedDate    : 22/12/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doPreFillingFieldsStep_1() {
        if (! this.account.Name.startsWithIgnoreCase('LONGFORM:')) {
            this.stepPagesMap.get('CREDIT SCORE. SEARCH COMPANY').fields.get('COMPANY NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = this.account.Name;
        }
        if (account.Steuernummer__c != null) {
            this.stepPagesMap.get('CREDIT SCORE. SEARCH COMPANY').fields.get('TAX ID').elementItemsMap.get('DEFAULT VALUE').Value__c = this.account.Steuernummer__c;
        }
        if (this.opportunity.Total_consumption_l_month__c != null) {
            this.stepPagesMap.get('CREDIT SCORE. TOTAL CONSUMPTION').fields.get('TOTAL CONSUMPTION').elementItemsMap.get('DEFAULT VALUE').Value__c = String.valueOf(this.opportunity.Total_consumption_l_month__c);
        }
        this.creditScoringService.setCreditReportFromSF(this.opportunity.Id);
        this.cfReportResponse = this.creditScoringService.getCreditReportFromSF();
        if (this.cfReportResponse != null) this.selectedCompany = this.cfReportResponse.company;
        if (this.activeSubStep == 'Calculating credit score') {
            if (this.selectedCompany != null ) {
                setCreditScoreParameters();
                if (this.opportunity.Rechnungsperiode__c != null && this.opportunity.CF_Credit_Limit__c != null) {
                    this.defaultBillingPeriod = Integer.valueOf(this.opportunity.Rechnungsperiode__c);
                    this.creditLimit = this.opportunity.CF_Credit_Limit__c;
                    returnFinalCreditScoreData();
                    this.deposit = this.opportunity.Security_Amount_To_Pay__c;
                } else {
                    returnFinalCreditScoreData();
                }
                this.creditScoringService.resetCfDecision(this.defaultBillingPeriod, null, this.deposit, this.selectedCompany.classRating, this.selectedCompany);
                this.cfDecision = creditScoringService.getCfDecision();
            }  else {
                this.creditScoringService.resetOpportunityToStep('Search company');
                activateNewStep(this.opportunity.Id);
            }
        }
    }


    /*******************************************************************************
    *  Name            : doPreFillingFieldsStep_2()
    *  Summary         : pre-filling of the second step fields
    *  CreatedDate     : 22/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doPreFillingFieldsStep_2() {
        this.cardsConfigService.setCardParams();
        this.activeCardConfigTab = cardsConfigService.getActiveCardConfigTab();
        this.sameCardsMap = cardsConfigService.getSameCards();
        this.diffCardsMap = cardsConfigService.getDiffCards();
        this.numberOfCards = this.cardsConfigService.getNumberOfCards();
        this.numberOfDiffCards = this.diffCardsMap.size();
        this.cardsConfigService.setCreditReport();
        this.selectedCompany = this.cardsConfigService.getCreditReport();
        this.cardsConfigService.setSpecialOffers('Desktop');
        this.homeOffersList = this.cardsConfigService.gethomeOffersList();
        this.nonHomeOffersList = this.cardsConfigService.getnonHomeOffersList();
        this.cardsConfigService.setUrlLocator();
        this.urlLocator = this.cardsConfigService.getUrlLocator();
        this.cardsConfigService.setFinalOrderCardsMap();
        this.finalCardsMap = this.cardsConfigService.getFinalOrderCardsMap();
        calculateFeesAndCosts();
        this.cardsConfigService.setEmbossingBlockVisibilityStatus();
        this.showCardsEmbossingBlock = this.cardsConfigService.getEmbossingBlockVisibilityStatus();
        this.cardsConfigService.setContinueButtonStatus(this.activeStep, this.activeSubStep);
        this.continueButtonIsDisabled = this.cardsConfigService.getContinueButtonStatus();
        selectOffer();
        this.chatService.setOpportunity(opportunity);
        this.chatService.setContact(contact);
        prepareOnlineChat();
    }


    /*******************************************************************************
    *  Name            : doPreFillingFieldsStep_3()
    *  Summary         : pre-filling of the third step fields
    *  CreatedDate     : 22/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doPreFillingFieldsStep_3() {
        this.cardsConfigService.setCardParams();
        this.activeCardConfigTab = cardsConfigService.getActiveCardConfigTab();
        this.numberOfCards = cardsConfigService.getNumberOfCards();
        this.cardsConfigService.setCreditReport();
        this.selectedCompany = this.cardsConfigService.getCreditReport();
        this.cardsConfigService.setFinalOrderCardsMap();
        this.finalCardsMap = this.cardsConfigService.getFinalOrderCardsMap();
        this.cardsConfigService.setEmbossingBlockVisibilityStatus();
        this.showCardsEmbossingBlock = this.cardsConfigService.getEmbossingBlockVisibilityStatus();
        this.cardsConfigService.setCostsColumnsMap();
        this.costsColumnsMap = this.cardsConfigService.getCostsColumnsMap();
        this.stepPagesMap.get('ADDITIONAL').fields.get('CO2 TAKE CARE').elementItemsMap.get('VALUE').Value__c = String.valueOf(this.opportunity.Eco_Fee__c);
        chatService.setOpportunity(opportunity);
        chatService.setContact(contact);
        prepareOnlineChat();
    }


    /*******************************************************************************
    *  Name            : doPreFillingFieldsStep_4()
    *  Summary         : pre-filling of the fourth step fields
    *  CreatedDate     : 22/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doPreFillingFieldsStep_4() {
        // How to pay block - TEMP BLOCK (MUST BE REMOVED)
        if (E2EKeysAPI__c.getValues('E2EFormFR') != null) {
            Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EFormFR').AES256_Key__c);
            // How to pay block
            this.stepPagesMap.get('CONGRATULATIONS').elements.get('HOW TO PAY BLOCK').get('SAVE PAYMENT INFORMATION DOWNLOAD URL').Value__c = '/apex/E2EAdditionalDocuments?hash=' +
                    E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=PaymentInformation&' + 'opportunityID=' + String.valueOf(opportunity.Id) +'&pdfDownload=TRUE&');
            // Direct Debit Mandate Acceptance
        }



        this.cardsConfigService.setCardParams();
        this.activeCardConfigTab = cardsConfigService.getActiveCardConfigTab();
        this.cardsConfigService.setFinalOrderCardsMap();
        this.finalCardsMap = this.cardsConfigService.getFinalOrderCardsMap();
        this.cardsConfigService.setEmbossingBlockVisibilityStatus();
        this.showCardsEmbossingBlock = this.cardsConfigService.getEmbossingBlockVisibilityStatus();
        this.numberOfCards = cardsConfigService.getNumberOfCards();
        this.cardsConfigService.setCreditReport();
        this.selectedCompany = this.cardsConfigService.getCreditReport();
        this.cardsConfigService.setSpecialOffers('Desktop');
        this.homeOffersList = this.cardsConfigService.gethomeOffersList();
        this.nonHomeOffersList = this.cardsConfigService.getnonHomeOffersList();
        calculateFeesAndCosts();

        if (opportunity.Security_Amount_To_Pay__c != null && this.paymentStatus == null) {
            this.paymentOptionsService.prepareTransaction('Desktop');
            this.selectedPaymentMethod = this.stepPagesMap.get('PAYMENT OPTIONS').fields.get('PaymentMethod Cards').options.get(0).getValue();
            // this.selectedPaymentMethod = this.stepPagesMap.get('PAYMENT OPTIONS').fields.get('PaymentMethod Online Bank').options.get(0).getValue();
            changePaymentMethod(); // pre-filling payment method (init data)
        }
        if (E2EKeysAPI__c.getValues('E2EFormFR') != null) {
            Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EFormFR').AES256_Key__c);
            // SEPA
            this.stepPagesMap.get('PAYMENT OPTIONS').elements.get('DD SEPA').get('IFRAME URL').Value__c = '/apex/E2EAdditionalDocuments?hash=' +
                    E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=SEPAMandate&' + 'opportunityID=' + String.valueOf(opportunity.ID) + '&' +
                            'dynamicAccHolder=' + this.contact.FirstName + ' ' + this.contact.LastName + '&');
            this.sepaDownloadURL = '/apex/E2EAdditionalDocuments?hash=' +
                    E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=SEPAMandate&' + 'opportunityID=' + String.valueOf(opportunity.ID) +'&pdfDownload=TRUE&');

            // TC
            this.stepPagesMap.get('PAYMENT OPTIONS').fields.get('ACCEPT TERM CONDITIONS').elementItemsMap.get('IFRAME URL').Value__c = '/apex/E2EAdditionalDocuments?hash=' +
                    E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=TermConditionsFR&');
            this.stepPagesMap.get('PAYMENT OPTIONS').fields.get('ACCEPT TERM CONDITIONS').elementItemsMap.get('DOWNLOAD URL').Value__c = '/apex/E2EAdditionalDocuments?hash=' +
                    E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=TermConditionsFR&pdfDownload=TRUE&');

            // Deposit Agreement
            this.stepPagesMap.get('PAYMENT OPTIONS').fields.get('DEPOSIT AGREEMENT').elementItemsMap.get('IFRAME URL').Value__c = '/apex/E2EAdditionalDocuments?hash=' +
                    E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=DepositAgreementFR&' + 'opportunityID=' + String.valueOf(opportunity.ID)+'&');
            this.stepPagesMap.get('PAYMENT OPTIONS').fields.get('DEPOSIT AGREEMENT').elementItemsMap.get('DOWNLOAD URL').Value__c = '/apex/E2EAdditionalDocuments?hash=' +
                    E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=DepositAgreementFR&' + 'opportunityID=' + String.valueOf(opportunity.ID) +'&pdfDownload=TRUE&');
        }
        this.stepPagesMap.get('PAYMENT OPTIONS').fields.get('ACCOUNT HOLDER').elementItemsMap.get('VALUE').Value__c = this.contact.FirstName + ' ' + this.contact.LastName;
        this.stepPagesMap.get('PAYMENT OPTIONS').fields.get('IBAN').elementItemsMap.get('VALUE').Value__c = this.opportunity.IBAN__c;
        this.stepPagesMap.get('PAYMENT OPTIONS').fields.get('SWIFT').elementItemsMap.get('VALUE').Value__c = this.opportunity.SWIFT_BIC__c;
        this.stepPagesMap.get('PAYMENT OPTIONS').fields.get('PAPER INVOICE').elementItemsMap.get('VALUE').Value__c = String.valueOf(this.opportunity.Papierrechnung__c);
        this.stepPagesMap.get('PAYMENT OPTIONS').fields.get('DECISION').elementItemsMap.get('VALUE').Value__c = String.valueOf(this.opportunity.AGB_Datenschutzhinweise_Richtigkeit__c);
        this.stepPagesMap.get('PAYMENT OPTIONS').fields.get('ACCEPT TERM CONDITIONS').elementItemsMap.get('VALUE').Value__c = String.valueOf(this.contact.Authorised_signatory__c);
        this.stepPagesMap.get('PAYMENT OPTIONS').fields.get('ACCEPT SEPA').elementItemsMap.get('VALUE').Value__c = String.valueOf(this.opportunity.SEPA_Request_Approved__c);
        this.chatService.setOpportunity(this.opportunity);
        this.chatService.setContact(this.contact);
        prepareOnlineChat();
    }


    /*******************************************************************************
    *  Name            : doPreFillingFieldsStep_5()
    *  Summary         : pre-filling of the fifth step fields
    *  CreatedDate     : 22/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doPreFillingFieldsStep_5() {
        if (this.opportunity.E2E_payment_status__c != null &&
                (this.opportunity.E2E_payment_status__c.substring(0, 1) == 'A' || this.opportunity.E2E_payment_status__c.substring(0, 1) == 'D' ||
                 this.opportunity.E2E_payment_status__c.substring(0, 1) == 'C' || this.opportunity.E2E_payment_status__c.substring(0, 1) == 'E')) {
            this.paymentStatus = this.opportunity.E2E_payment_status__c.substring(0, 1);
        }
        // Payment information
        if (E2EKeysAPI__c.getValues('E2EFormFR') != null) {
            Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EFormFR').AES256_Key__c);
            system.debug(stepPagesMap);
            this.stepPagesMap.get('CONGRATULATIONS').elements.get('HOW TO PAY BLOCK').get('SAVE PAYMENT INFORMATION DOWNLOAD URL').Value__c = '/apex/E2EAdditionalDocuments?hash=' +
                    E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=PaymentInformation&' + 'opportunityID=' + String.valueOf(opportunity.Id) +'&pdfDownload=TRUE&');
        }
        this.cardsConfigService.setCardParams();
        this.activeCardConfigTab = cardsConfigService.getActiveCardConfigTab();
        this.finalCardsMap = this.cardsConfigService.getFinalOrderCardsMap();
        this.numberOfCards = this.cardsConfigService.getNumberOfCards();
        this.cardsConfigService.setCreditReport();
        this.selectedCompany = this.cardsConfigService.getCreditReport();
        this.chatService.setOpportunity(this.opportunity);
        this.chatService.setContact(this.contact);
        prepareOnlineChat();
    }


    /*******************************************************************************
    *  Name            : initChatSetup()
    *  Summary         : init chat setup
    *  CreatedDate     : 22/08/2018
    *  ModifiedDate    :
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void initChatSetup(){
        this.chatService = new LFChatService();
        this.chatService.setChatDefaultSettings('France');
        this.chatButtonId = this.chatService.chatButtonId;
        this.chatDeploymentId = this.chatService.chatDeploymentId;
        this.chatDeploymentJsURL = this.chatService.chatDeploymentJsURL;
        this.chatURL = this.chatService.chatURL;
        this.chatService.setPageMap('France');
        this.pageMapChat = this.chatService.getPagesMap();
    }


    /*******************************************************************************
    *  Name            : activateNewStep(String opptyId)
    *  Summary         : restarts active step
    *  CreatedDate     : 22/08/2018
    *  ModifiedDate    : -
    *  Parameters      : String opptyId
    *  Returns         : void
    ******************************************************************************/
    public void activateNewStep(String opptyId) {
        initPageElements();
        initSObjects(opptyId);
        doPreFillingFormFields();
    }


    /*
        0. Contact details step
    */
    /*******************************************************************************
    *  Name            : goToCreditScoring()
    *  Summary         : save data and go to the second step
    *  CreatedDate     : 22/08/2018
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
            String formOfBusiness = this.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c;
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
            if (contact == null) {
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
                                    url = '/e2eFormFR?source=';
                                } else {
                                    url = '/apex/e2eFormFR?source=';
                                }
                                PageReference reference = new PageReference(url + contactRole.Opportunity.E2E_Encoded_URL__c);
                                reference.setRedirect(true);
                                if (this.opportunity != null) {
                                    LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'France', 'Desktop');
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
                                    url = '/e2eFormFR?source=';
                                } else {
                                    url = '/apex/e2eFormFR?source=';
                                }
                                PageReference reference = new PageReference(url + contactRole.Opportunity.E2E_Encoded_URL__c);
                                reference.setRedirect(true);
                                this.endApexCall = Datetime.now();
                                LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'France', 'Desktop');
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

                opportunity = this.contactDetailsService.getOpportunity();
                activateNewStep(this.opportunity.Id);
            }
            this.chatService.setOpportunity(opportunity);
            this.chatService.setContact(contact);
            prepareOnlineChat();
            if (formOfBusiness == 'Solo-trader') {
                this.stepPagesMap.get('CREDIT SCORE. SEARCH COMPANY').fields.get('COMPANY NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = contact.Name;
            }
            if (this.selectedCompany != null) {
                this.selectedCompany.identificationnumber = null; // disable button continue
            }
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'France', 'Desktop');
            return null;
        } catch (Exception e) {
            this.activeStep = 0;
            this.activeSubStep = 'System error';
            initPageElements();
            if (opportunity != null && opportunity.Id != null) {
                initSObjects(opportunity.Id);
                E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
                E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'goToCreditScoring()', e);
            } else {
                E2EExceptionUtils.sendExceptionEmail(null, null, null, 'Desktop', 'goToCreditScoring()', e);
            }
            return null;
        }
    }


    /*
        1. Credit score step
        1.1 Search company substep
    */
    /*******************************************************************************
    *  Name            : goToContactDetails()
    *  Summary         : go to contact details step (step 0)
    *  CreatedDate     : 22/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void goToContactDetails() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            this.startApexCall = Datetime.now();
            this.activeInnerPage = '';
            this.activeStep = 0;
            this.activeSubStep = 'Contact details';
            activateNewStep(this.opportunity.Id);
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'France', 'Desktop');
        } catch (Exception e) {
            this.activeSubStep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'goToContactDetails()', e);
        }
    }


    /*******************************************************************************
    *  Name            : doSearchCompany()
    *  Summary         : search company
    *  CreatedDate     : 22/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doSearchCompany() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            this.activeInnerPage = '';
            this.creditScoringService.setOpportunity(opportunity.Id);
            this.opportunity = this.creditScoringService.getOpportunity();
            this.creditScoringService.validateFields('company details');

            this.creditScoringService.setCompaniesFromCF(this.opportunity.Id);
            this.availableCompaniesListCreditScoring = this.creditScoringService.getCompaniesFromCF();
            disableTriggers();
            this.opportunity.CF_Stage__c = 'Launched';
            this.opportunity.E2E_Number_of_Search_Companies__c = this.availableCompaniesListCreditScoring.companiesMap.size();
            update this.opportunity;
            if (this.selectedCompany == null) this.selectedCompany = new CreditCompany();
            if (! this.availableCompaniesListCreditScoring.companiesMap.isEmpty() ) {
                this.activeInnerPageCreditScoring = 'Select company';
            } else {
                throw new LongFormException(E2EExceptionUtils.errorsMap.get('Company not found'));
            }
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, 'This is a company search process.', 'France', 'Desktop');
        } catch (Exception e) {
            if (e.getMessage() == E2EExceptionUtils.errorsMap.get('Company not found')) {
                this.activeStep = null;
                this.activeSubStep = 'Company not found';
                E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            } else {
                this.activeSubStep = 'System error';
                E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
                E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'doSearchCompany()', e);
            }
        }
    }


    /*******************************************************************************
    *  Name            : doSaveCompanyDetailsData()
    *  Summary         : do save company details data
    *  CreatedDate     : 22/04/2018
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
            this.activeSubStep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'doSaveCompanyDetailsData()', e);
        }
    }


    /*******************************************************************************
    *  Name            : goToSetTotalConsumption()
    *  Summary         : go to total consumption substep
    *  CreatedDate     : 22/08/2018
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
            this.creditScoringService.doGenerateCreditFactoryReport(this.selectedCompany.identificationnumber);
            this.creditScoringService.setCreditReportFromSF(this.opportunity.Id);
            this.cfReportResponse = this.creditScoringService.getCreditReportFromSF();
            this.selectedCompany = this.cfReportResponse.company;

            // duplication
            String stopProcess = this.creditScoringService.searchDuplicates(selectedCompany);
            if (stopProcess != null) {
                this.activeStep = null;
                this.activeSubStep = stopProcess;
                E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubStep, null);
                return;
            }
            this.creditScoringService.doUpdateSFobjects(this.cfReportResponse);
            this.creditScoringService.setResultOfCheckBlackList();

            E2E_Form_General_Settings__c settings = E2E_Form_General_Settings__c.getInstance('France');
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
            this.creditScoringService.setAccount(this.account.Id);
            this.account = this.creditScoringService.getAccount();
            if ((this.account.Umsatzsteuer_ID__c == null || this.account.Umsatzsteuer_ID__c == '') && ! this.account.No_Vat__c) {
                this.stepPagesMap.get('CREDIT SCORE. INPUT VAT ID').fields.get('NO VAT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'false';
                this.stepPagesMap.get('CREDIT SCORE. INPUT VAT ID').fields.get('VAT NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '';
                this.activeSubStep = 'Enter VAT Number';
                this.creditScoringService.goToSetVatNumberStep();
            }
            prepareOnlineChat();
        } catch (Exception e) {
            initSObjects(opportunity.Id);
            if (e.getMessage() == E2EExceptionUtils.errorsMap.get('Report does not exist')) {
                this.activeStep = null;
                this.activeSubStep = 'Report does not exist';
                E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            } else {
                this.activeSubStep = 'System error';
                E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
                E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'goToSetTotalConsumption()', e);
            }
        }
    }

    /*******************************************************************************
    *  Name            : updateVatNumber()
    *  Summary         : update VAT number
    *  CreatedDate     : 22/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void updateVatNumber() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            this.startApexCall = Datetime.now();
            this.isVatIdValid = this.creditScoringService.validateVatId();
            if (this.isVatIdValid) {
                this.creditScoringService.doUpdateVatNumber();
                this.activeInnerPage = '';
                this.activeStep = 1;
                this.activeSubStep = 'Set total consumption';
            }
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'France', 'Desktop');
        } catch (Exception e) {
            this.activeSubStep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'updateVatNumber()', e);
        }
    }

    /*******************************************************************************
     *  Name            : deleteReportsForPreviousCompany()
     *  Summary         : delete all credit factory reports if user selects new company
     *  CreatedDate     : 27/12/2018
     *  Parameters      :
     *  Returns         : void
     ******************************************************************************/
    public void deleteReportsForPreviousCompany() {
        try {
            this.startApexCall = Datetime.now();
            this.creditScoringService.deleteCreditFactoryReports(this.selectedCompany.identificationnumber);
        } catch (Exception e) {
            this.activeSubStep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'deleteReportsForPreviousCompany()', e);
        }
    }

    /*
        1.2 Set total consumption substep
    */
    /*******************************************************************************
    *  Name            : backToCreditScoring()
    *  Summary         : back to step 1
    *  CreatedDate     : 22/08/2018
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
            this.stepPagesMap.get('CREDIT SCORE. SEARCH COMPANY').fields.get('COMPANY NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = this.selectedCompany.name;
            this.selectedCompany.identificationnumber = null;
            prepareOnlineChat();
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'France', 'Desktop');
        } catch (Exception e) {
            this.activeSubStep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'backToCreditScoring()', e);
        }
    }


    /*******************************************************************************
    *  Name            : doCalculateCreditScoring()
    *  Summary         : calculating credit scoring
    *  CreatedDate     : 22/08/2018
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
            this.selectedCompany = this.cfReportResponse.company;
            setCreditScoreParameters();
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
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'France', 'Desktop');
        } catch (Exception e) {
            if (e.getMessage() == E2EExceptionUtils.errorsMap.get('Too high limit')) {
                this.activeStep = null;
                this.activeSubStep = 'Too high limit';
                E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            } else {
                this.activeSubStep = 'System error';
                E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
                E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'doCalculateCreditScoring()', e);
            }
        }
    }


    /*******************************************************************************
    *  Name            : setCreditScoreParameters()
    *  Summary         : set credit score parameters
    *  CreatedDate     : 22/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void setCreditScoreParameters() {
        this.defaultBillingPeriod = Integer.valueOf(this.cfReportResponse.recommendedBillingPeriod);
        this.creditLimit = this.cfReportResponse.creditLimitDefault;
        this.creditLimit7 = this.cfReportResponse.creditLimit7;
        this.creditLimit15 = this.cfReportResponse.creditLimit15;
        this.creditLimit30 = this.cfReportResponse.creditLimit30;
        this.maxCreditLimit7 = this.cfReportResponse.maxCreditLimit7;
        this.maxCreditLimit15 = this.cfReportResponse.maxCreditLimit15;
        this.maxCreditLimit30 = this.cfReportResponse.maxCreditLimit30;
        this.maxValue7 = this.cfReportResponse.maxValue7;
        this.maxValue15 = this.cfReportResponse.maxValue15;
        this.maxValue30 = this.cfReportResponse.maxValue30;
        this.deposit7 = this.cfReportResponse.deposit7;
        this.deposit15 = this.cfReportResponse.deposit15;
        this.deposit30 = this.cfReportResponse.deposit30;
    }


    /*******************************************************************************
    *  Name            : returnFinalCreditScoreData()
    *  Summary         : return final of credit score data
    *  CreatedDate     : 22/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void returnFinalCreditScoreData() {
        if (this.defaultBillingPeriod == 7) {
            this.minCreditLimit = this.creditLimit7;
            this.maxCreditLimit = this.maxCreditLimit7;
            this.maxValue = this.maxValue7;
            this.deposit = this.deposit7;
        } else if (this.defaultBillingPeriod == 15) {
            this.minCreditLimit = this.creditLimit15;
            this.maxCreditLimit = this.maxCreditLimit15;
            this.maxValue = this.maxValue15;
            this.deposit = this.deposit15;
        } else if (this.defaultBillingPeriod == 30) {
            this.minCreditLimit = this.creditLimit30;
            this.maxCreditLimit = this.maxCreditLimit30;
            this.maxValue = this.maxValue30;
            this.deposit = this.deposit30;
        }
    }


    /*
        1.3 Calculating credit score substep
    */
    /*******************************************************************************
    *  Name            : backToSetTotalConsumption()
    *  Summary         : go to back to set prognosed pumping
    *  CreatedDate     : 22/08/2018
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
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'France', 'Desktop');
        } catch (Exception e) {
            this.activeSubStep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'backToSetTotalConsumption()', e);
        }
    }


    /*******************************************************************************
    *  Name            : changeBillingPeriod()
    *  Summary         : do change billing period when click button
    *  CreatedDate     : 22/08/2018
    *  ModifiedDate    : 22/12/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void changeBillingPeriod() {
        returnFinalCreditScoreData();
        this.creditScoringService.resetCfDecision(this.defaultBillingPeriod, null, this.deposit, this.selectedCompany.classRating, this.selectedCompany);
        this.cfDecision = this.creditScoringService.getCfDecision();
    }


    /*******************************************************************************
    *  Name            : doRecalculateDeposit()
    *  Summary         : recalculate deposit
    *  CreatedDate     : 08/08/2018
    *  ModifiedDate    : 22/12/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doRecalculateDeposit() {
        try {
            this.activeInnerPage = '';
            creditScoringService.setDeposit(this.selectedCompany, this.defaultBillingPeriod, null, this.creditLimit, this.maxCreditLimit);
            this.deposit = creditScoringService.getDeposit();
            creditScoringService.resetCfDecision(this.defaultBillingPeriod, null, this.deposit, this.selectedCompany.classRating, this.selectedCompany);
            this.cfDecision = creditScoringService.getCfDecision();
        } catch(Exception e) {
            this.activeSubStep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'doRecalculateDeposit()', e);
        }
    }


    /*******************************************************************************
    *  Name            : goToCardsConfig()
    *  Summary         : go to long form step 2
    *  CreatedDate     : 22/08/2018
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
            this.creditScoringService.saveCreditScoringResult(this.defaultBillingPeriod, null, this.creditLimit, this.deposit);
            this.creditScoringService.setOpportunity(this.opportunity.Id);
            this.opportunity = creditScoringService.getOpportunity();
            initPageElements();
            initSObjects(opportunity.Id);
            this.cardsConfigService.setContinueButtonStatus(this.activeStep, this.activeSubStep);
            this.continueButtonIsDisabled = this.cardsConfigService.getContinueButtonStatus();
            doPreFillingFormFields();
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'France', 'Desktop');
        } catch (Exception e) {
            this.activeSubStep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'goToCardsConfig()', e);
        }
    }


    /*
        2. Card configuration step
        2.1 Card configuration substep
    */
    /*******************************************************************************
    *  Name            : changeNumberOfCards()
    *  Summary         : change total number of cards
    *  CreatedDate     : 22/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void changeNumberOfCards() {
        try {
            if (this.numberOfCards == null || this.numberOfCards == 0) this.numberOfCards = 1;
            if (this.numberOfCards > 50) this.numberOfCards = 50;
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
            if (e.getMessage() == 'Remove extra cards') {
                this.activeInnerPage = 'Remove extra cards';
                this.activeCardConfigTab = 'diff';
            } else if (e.getMessage() == 'No more 2 cards') {
                this.activeInnerPage = 'No more 2 cards error';
            } else {
                this.activeSubStep = 'System error';
                E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
                E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'changeNumberOfCards()', e);
            }
        }
    }


    /*******************************************************************************
    *  Name            : changeActiveTab()
    *  Summary         : change active tab and calculate fees and costs
    *  CreatedDate     : 22/08/2018
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
            this.activeSubStep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'changeActiveTab()', e);
        }
    }


    /*******************************************************************************
    *  Name            : addCard()
    *  Summary         : add new card and go to next one
    *  CreatedDate     : 22/08/2018
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
            this.activeSubStep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'addCard()', e);
        }
    }


    /*******************************************************************************
    *  Name            : editCardConfiguration()
    *  Summary         : open configuration block for selected card
    *  CreatedDate     : 22/08/2018
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
            this.activeSubStep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'editCardConfiguration()', e);
        }
    }


    /*******************************************************************************
    *  Name            : removeCard()
    *  Summary         : remove the card
    *  CreatedDate     : 22/08/2018
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
            this.activeSubStep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'removeCard()', e);
        }
    }


    /*******************************************************************************
    *  Name            : calculateFeesAndCosts()
    *  Summary         : calculate fees and costs for selected cards
    *  CreatedDate     : 22/08/2018
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
    *  CreatedDate     : 22/08/2018
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
            if (this.sameCardsMap.size() != this.numberOfCards) this.cardsConfigService.changeNumberOfCards(this.numberOfCards);
            this.cardsConfigService.saveCardsConfigResult();
            this.cardsConfigService.setSpecialOffers('Desktop');
            this.diffCardsMap = this.cardsConfigService.getDiffCards();
            this.sameCardsMap = this.cardsConfigService.getSameCards();
            this.homeOffersList = this.cardsConfigService.gethomeOffersList();
            this.nonHomeOffersList = this.cardsConfigService.getnonHomeOffersList();
            this.cardsConfigService.setFinalOrderCardsMap();
            this.finalCardsMap = this.cardsConfigService.getFinalOrderCardsMap();
            if (this.urlLocator == null) {
                this.cardsConfigService.setUrlLocator();
                this.urlLocator = this.cardsConfigService.getUrlLocator();
            }
            this.activeStep = 2;
            this.activeSubStep = 'Choosing offer';
            selectOffer();
            prepareOnlineChat();
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'France', 'Desktop');
        } catch (Exception e) {
            this.activeSubStep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'goToSpecialOffers()', e);
        }
    }


    /*
        2.2 Choosing offer substep
    */
    /*******************************************************************************
    *  Name            : backToCardConfiguration()
    *  Summary         : back to card configuration page
    *  CreatedDate     : 22/08/2018
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
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'France', 'Desktop');
        } catch (Exception e) {
            this.activeSubStep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'backToCardConfiguration()', e);
        }
    }


    /*******************************************************************************
    *  Name            : selectOffer()
    *  Summary         : set selected offer
    *  CreatedDate     : 22/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void selectOffer() {
        try {
            this.activeInnerPage = '';
            // String offerName = ApexPages.CurrentPage().getParameters().get('offerName');
            String offerName = 'Home Station offer (v.1)';
            this.cardsConfigService.selectOffer(offerName);
            this.homeOffersList = this.cardsConfigService.gethomeOffersList();
            this.nonHomeOffersList = this.cardsConfigService.getnonHomeOffersList();
            if (jsonStation != null) {
                E2ELocatorStation station = (E2ELocatorStation)JSON.deserialize(jsonStation, E2ELocatorStation.class);
                this.opportunity.Home_Station__c = station.address + ' ' + station.countryName;
                this.opportunity.ESI__c = station.stationId;
            }
        } catch (Exception e) {
            this.activeSubStep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'selectOffer()', e);
        }
    }


    /*******************************************************************************
    *  Name            : chooseStation()
    *  Summary         : open locator to select station point
    *  CreatedDate     : 22/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void chooseStation() {
        try {
            this.activeInnerPage = '';
            // String offerName = ApexPages.CurrentPage().getParameters().get('offerName');
            String offerName = 'Home Station offer (v.1)';
            this.cardsConfigService.chooseStation(offerName);
            this.homeOffersList = this.cardsConfigService.gethomeOffersList();
            this.nonHomeOffersList = this.cardsConfigService.getnonHomeOffersList();
        } catch (Exception e) {
            this.activeSubStep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'chooseStation()', e);
        }
    }


    /*******************************************************************************
    *  Name            : returnStation()
    *  Summary         : return station data for selected station point
    *  CreatedDate     : 22/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void returnStation() {
        try {
            this.activeInnerPage = '';
            for (LongFormSpecialOffer offer : this.homeOffersList) {
                if (offer.homeMapSelectionBtnStatus == 'hide') {
                    offer.offerSelectionBtnStatus = 'show-enabled';
                }
            }
        } catch (Exception e) {
            this.activeSubStep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'returnStation()', e);
        }
    }


    /*******************************************************************************
    *  Name            : removeOffer()
    *  Summary         : remove selected offer
    *  CreatedDate     : 22/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void removeOffer() {
        try {
            this.activeInnerPage = '';
            this.cardsConfigService.removeOffer();
            this.homeOffersList = this.cardsConfigService.gethomeOffersList();
            this.nonHomeOffersList = this.cardsConfigService.getnonHomeOffersList();
            this.cardsConfigService.setContinueButtonStatus(this.activeStep, this.activeSubStep);
            this.continueButtonIsDisabled = this.cardsConfigService.getContinueButtonStatus();
        } catch (Exception e) {
            this.activeSubStep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'removeOffer()', e);
        }
    }


    /*******************************************************************************
    *  Name            : goToTechnicalParameters()
    *  Summary         : go to technical parameters
    *  CreatedDate     : 22/08/2018
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
            this.showCardsEmbossingBlock = this.cardsConfigService.getEmbossingBlockVisibilityStatus();
            this.cardsConfigService.setContinueButtonStatus(this.activeStep, this.activeSubStep);
            this.continueButtonIsDisabled = this.cardsConfigService.getContinueButtonStatus();
            this.cardsConfigService.setOpportunity(this.opportunity.Id);
            this.opportunity = this.cardsConfigService.getOpportunity();
            prepareOnlineChat();
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'France', 'Desktop');
        } catch (Exception e) {
            this.activeSubStep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'goToTechnicalParameters()', e);
        }
    }


    /*
        2.3 Technical parameters substep
    */
    /*******************************************************************************
    *  Name            : backToSpecialOffers()
    *  Summary         : back to special offers substep
    *  CreatedDate     : 22/08/2018
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
            this.continueButtonIsDisabled = false;
            prepareOnlineChat();
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'France', 'Desktop');
        } catch (Exception e) {
            this.activeSubStep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'backToSpecialOffers()', e);
        }
    }


    /*******************************************************************************
    *  Name            : editTechnicalParameters()
    *  Summary         : edit technical parameters
    *  CreatedDate     : 22/08/2018
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
            this.activeSubStep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'editTechnicalParameters()', e);
        }
    }


    /*******************************************************************************
    *  Name            : editCompanyName()
    *  Summary         : edit company name
    *  CreatedDate     : 22/08/2018
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
            this.activeSubStep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'editCompanyName()', e);
        }
    }


    /*******************************************************************************
    *  Name            : saveTechParamForSingleCard()
    *  Summary         : save technical params for single card
    *  CreatedDate     : 22/08/2018
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
            if (this.continueButtonIsDisabled) {
                this.showCardsEmbossingBlock = false;
            } else {
                this.showCardsEmbossingBlock = true;
            }
        } catch (Exception e) {
            this.activeSubStep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'saveTechParamForSingleCard()', e);
        }
    }


    /*******************************************************************************
    *  Name            : goToAdditionalParams()
    *  Summary         : go to "Additional" step
    *  CreatedDate     : 22/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void goToAdditionalParams() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            this.startApexCall = Datetime.now();
            disableTriggers();
            this.finalCardsMap = this.cardsConfigService.getFinalOrderCardsMap();
            this.activeInnerPage = '';
            this.activeStep = 3;
            this.activeSubStep = 'Additional services';
            this.cardsConfigService.saveTechParamForAllCards(this.activeSubStep);
            activateNewStep(this.opportunity.Id);
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'France', 'Desktop');
        } catch (Exception e) {
            this.activeSubStep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'goToAdditionalParams()', e);
        }
    }



    /*
        3. Additional services step
    */
    /*******************************************************************************
    *  Name            : backToTechnicalParams()
    *  Summary         : back to technical params
    *  CreatedDate     : 22/08/2018
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
            activateNewStep(this.opportunity.Id);
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'France', 'Desktop');
        } catch (Exception e) {
            this.activeSubStep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'backToTechnicalParams()', e);
        }
    }


    /*******************************************************************************
    *  Name            : goToPaymentOptions()
    *  Summary         : save CO2 if it exists and go to payments options (STEP 4)
    *  CreatedDate     : 22/08/2018
    *  ModifiedDate    :
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public PageReference goToPaymentOptions() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            this.startApexCall = Datetime.now();
            disableTriggers();
            this.activeInnerPage = '';
            this.activeStep = 4;
            this.additionalService.updateRecords();
            activateNewStep(this.opportunity.Id);
            PageReference paymentPage = new PageReference('/apex/e2eFormFR?source=' + this.opportunity.E2E_Encoded_URL__c);
            paymentPage.setRedirect(true);
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'France', 'Desktop');
            return paymentPage;
        } catch (Exception e) {
            this.activeSubStep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'goToPaymentOptions()', e);
            return null;
        }
    }


    /*
        4. Payment options step
        4.1 Direct Debit substep
    */
    /*******************************************************************************
    *  Name            : backToAdditionalParams()
    *  Summary         : back to "Additional" step
    *  CreatedDate     : 22/08/2018
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
            this.activeSubStep = 'Additional services';
            activateNewStep(this.opportunity.Id);
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'France', 'Desktop');
        } catch (Exception e) {
            this.activeSubStep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'backToAdditionalParams()', e);
        }
    }


    /*******************************************************************************
    *  Name            : updateSepaDownloadURL(String contactId)
    *  Summary         : return contact
    *  CreatedDate     : 22/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void updateSepaDownloadURL() {
        if (E2EKeysAPI__c.getValues('E2EFormFR') != null) {
            Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EFormFR').AES256_Key__c);
            this.sepaDownloadURL = '/apex/E2EAdditionalDocuments?hash=' +
                    E2EFormEncryption.getHashAlgorithAES256(key256AES,
                            'documentName=SEPAMandate&' +
                            'opportunityID=' + String.valueOf(opportunity.ID) + '&' +
                            'pdfDownload=TRUE&' +
                            'dynamicAccHolder=' + this.stepPagesMap.get('PAYMENT OPTIONS').fields.get('ACCOUNT HOLDER').elementItemsMap.get('VALUE').Value__c + '&' +
                            'dynamicIBAN=' + this.stepPagesMap.get('PAYMENT OPTIONS').fields.get('IBAN').elementItemsMap.get('VALUE').Value__c + '&' +
                            'dynamicSWIFT=' + this.stepPagesMap.get('PAYMENT OPTIONS').fields.get('SWIFT').elementItemsMap.get('VALUE').Value__c  );
        }
    }


    /*******************************************************************************
    *  Name            : jsValidateIBAN()
    *  Summary         : validate IBAN on click CONTINUE button
    *  CreatedDate     : 22/08/2018
    *  ModifiedDate    :
    *  Parameters      : -
    *  Returns         : Boolean
    ******************************************************************************/
    public void jsValidateIBAN() {
        this.isIBANValid = this.paymentOptionsService.jsValidateIBAN();
    }


    /*******************************************************************************
    *  Name            : doSavePaymentOptionsData()
    *  Summary         : do save payment options data and go to "thanks" page or external payment system
    *  CreatedDate     : 22/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doSavePaymentOptionsData() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            this.startApexCall = Datetime.now();
            if (this.opportunity.Security_Amount_To_Pay__c != null) disableTriggers();
            this.activeInnerPage = '';
            this.paymentOptionsService.validate(this.activeStep, this.activeSubStep);
            this.paymentOptionsService.savePaymentOptionsDataWithoutDeposit(this.activeSubStep);
            this.paymentOptionsService.setOpportunity(this.opportunity.Id);
            this.opportunity = this.paymentOptionsService.getOpportunity();
            this.activeStep = Integer.valueOf(this.opportunity.E2E_Active_Step__c);
            this.activeSubStep = this.opportunity.E2E_Active_Substep__c;
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'France', 'Desktop');
        } catch (Exception e) {
            this.activeSubStep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'doSavePaymentOptionsData()', e);
        }
    }


    /*
        4.2 Direct Debit Deposit substep
    */
    /*******************************************************************************
    *  Name            : backToDirectDebitPaymentOption()
    *  Summary         : back to direct debit payment options substep
    *  CreatedDate     : 22/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void backToDirectDebitPaymentOption() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            this.startApexCall = Datetime.now();
            this.activeInnerPage = '';
            this.activeStep = 4;
            this.activeSubStep = 'DirectDebit';
            prepareOnlineChat();
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'France', 'Desktop');
        } catch (Exception e) {
            this.activeSubStep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'backToDirectDebitPaymentOption()', e);
        }
    }


    /*******************************************************************************
    *  Name            : changePaymentMethod()
    *  Summary         : set payment method
    *  CreatedDate     : 22/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void changePaymentMethod() {
        try {
            this.activeInnerPage = '';
            this.paymentOptionsService.updatePaymentMethod(this.selectedPaymentMethod);
            getTransactionParameters();
        } catch (Exception e) {
            this.activeSubStep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'changePaymentMethod()', e);
        }
    }


    /*******************************************************************************
    *  Name            : getTransactionParameters()
    *  Summary         : get transaction parameters
    *  CreatedDate     : 22/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void getTransactionParameters() {
        if (E2EKeysAPI__c.getValues('E2EFormFR') != null) {
            this.paymentURL = E2EKeysAPI__c.getValues('E2EFormFR').paymentTransactionURL__c;
            this.paymentParameters = this.paymentOptionsService.getPaymentMap();
        }
    }


    /*******************************************************************************
    *  Name            : savePaymentTransaction()
    *  Summary         : do save payment transaction
    *  CreatedDate     : 22/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void savePaymentTransaction() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            this.startApexCall = Datetime.now();
            disableTriggers();
            this.activeInnerPage = '';


            this.paymentOptionsService.validate(this.activeStep, this.activeSubStep);
            this.paymentOptionsService.saveTransactionData();
            this.paymentOptionsService.savePaymentOptionsDataWithDeposit(this.activeSubStep);
            this.paymentOptionsService.setOpportunity(this.opportunity.Id);
            this.opportunity = this.paymentOptionsService.getOpportunity();
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, 'Payment Gateway Service', 'Transition to external service', 'France', 'Desktop');
        } catch (Exception e) {
            this.activeSubStep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'savePaymentTransaction()', e);
        }
    }

    // TEMP FUNCTION (MUST BE REMOVED AFTER INGENICO IS ENABLED)
    public void proceedToCheckout(){
        try {
            String currentActiveSubstep = this.activeSubStep;
            this.startApexCall = Datetime.now();
            disableTriggers();

            String ipAddress = LongFormGlobalUtils.getUserIPAddress();
            this.opportunity.StageName = 'Pending Sales – Deposit';
            this.opportunity.E2E_Active_Substep__c = 'Congratulations';
            this.opportunity.Visitor_ID__c = ipAddress;
            this.opportunity.E2E_Active_Step__c = 5;
            this.opportunity.E2E_Status__c = 'Finished';
            this.opportunity.E2E_Last_Activity__c = Datetime.now();
            this.opportunity.E2E_payment_status__c = 'PAYMENT GATEWAY OFF';
            update this.opportunity;
            this.activeStep = 5;
            this.activeSubstep = 'Congratulations';
            activateNewStep(this.opportunity.Id);
            EmarsysSenderEuropeanService.sendE2EOpportunityToEmarsys(this.opportunity.Id);
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'France', 'Desktop');
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'proceedToCheckout()', e);
        }
    }


    /*
        ACTIONS WITH MODAL WINDOWS
    */
    /*******************************************************************************
    *  Name            : showPaymentDetailsModal()
    *  Summary         : show "Payment Details" modal window
    *  CreatedDate     : 22/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void showPaymentDetailsModal() {
        this.activeInnerPage = 'PaymentDetails';
    }


    /*******************************************************************************
    *  Name            : showSepaMandateModal()
    *  Summary         : show "Sepa Mandate" modal window
    *  CreatedDate     : 22/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void showSepaMandateModal() {
        this.activeInnerPage = 'ModalSepa';
    }


    /*******************************************************************************
    *  Name            : showTermConditionsModal()
    *  Summary         : show "Terms and conditions" modal window
    *  CreatedDate     : 22/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void showTermConditionsModal() {
        this.activeInnerPage = 'ModalTermConditions';
    }


    /*******************************************************************************
    *  Name            : showDepositAgreementModal()
    *  Summary         : show "Deposit Agreement" modal window
    *  CreatedDate     : 22/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void showDepositAgreementModal() {
        this.activeInnerPage = 'ModalDepositAgreement';
    }


    /*******************************************************************************
    *  Name            : closeModal()
    *  Summary         : close modal window
    *  CreatedDate     : 22/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void closeModal() {
        this.activeInnerPage = null;
    }


    /*
        ORDER DETAILS BLOCK
    */
    /*******************************************************************************
    *  Name            : editCreditLimit()
    *  Summary         : back to edit credit limit substep
    *  CreatedDate     : 22/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void editCreditLimit() {
        try {
            String currentActiveSubStep = this.activeSubStep;
            this.activeInnerPage = '';
            this.activeStep = 1;
            this.activeSubStep = 'Calculating credit score';
            activateNewStep(this.opportunity.Id);
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'France', 'Desktop');
        } catch (Exception e) {
            this.activeSubStep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'editCreditLimit()', e);
        }
    }


    /*******************************************************************************
    *  Name            : editTotalConsumption()
    *  Summary         : back to edit total consumption substep
    *  CreatedDate     : 22/08/2018
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
            activateNewStep(this.opportunity.Id);
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'France', 'Desktop');

        } catch (Exception e) {
            this.activeSubStep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'editTotalConsumption()', e);
        }
    }


    /*******************************************************************************
    *  Name            : editCompanyDetails()
    *  Summary         : go to search company step
    *  CreatedDate     : 22/08/2018
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
            activateNewStep(this.opportunity.Id);
            this.continueButtonIsDisabled = false;
            this.selectedCompany.identificationnumber = null;
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'France', 'Desktop');
        } catch (Exception e) {
            this.activeSubStep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'editCompanyDetails()', e);
        }
    }


    /*******************************************************************************
    *  Name            : editContactDetails()
    *  Summary         : go to edit contact details step
    *  CreatedDate     : 22/08/2018
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
            this.continueButtonIsDisabled = false;
            if (this.selectedCompany != null) {
                this.selectedCompany.identificationnumber = null;
            }
            activateNewStep(this.opportunity.Id);
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'France', 'Desktop');
        } catch (Exception e) {
            this.activeSubStep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'editContactDetails()', e);
        }
    }


    /*******************************************************************************
    *  Name            : editCardsFeesAndCosts()
    *  Summary         : edit cards configuration and their fees and costs
    *  CreatedDate     : 22/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void editCardsFeesAndCosts() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            this.startApexCall = Datetime.now();
            this.activeInnerPage = '';
            this.activeSubStep = 'Card configuration';
            if (this.activeStep != 2) {
                this.activeStep = 2;
                activateNewStep(this.opportunity.Id);
            } else {
                this.activeCardConfigTab = this.cardsConfigService.getActiveCardConfigTab();
                calculateFeesAndCosts();
            }
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'France', 'Desktop');
        } catch (Exception e) {
            this.activeSubStep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'editCardsFeesAndCosts()', e);
        }
    }


    /*******************************************************************************
    *  Name            : editCardsEmbossing()
    *  Summary         : edit embossing of cards
    *  CreatedDate     : 22/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void editCardsEmbossing() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            this.startApexCall = Datetime.now();
            this.activeInnerPage = '';
            this.activeStep = 2;
            this.activeSubStep = 'Technical parameters';
            activateNewStep(this.opportunity.Id);
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'France', 'Desktop');
        } catch (Exception e) {
            this.activeSubStep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Desktop', 'editCardsEmbossing()', e);
        }
    }



    /* SYSTEM METHODS */

    /*******************************************************************************
    *  Name            : updateOpportunityOnReturnFromEmail()
    *  Summary         : Update Opportunity fields on return from marketing email
    *  CreatedDate     : 22/08/2018
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


    @RemoteAction
    global static void setFlagChatToOpportunity(String oppId, String activeStep, String activeSubStep, String modeOfChat){
        if(modeOfChat != ''){
            LFChatService.setFlagChatToOpportunity(oppId, modeOfChat, Integer.valueof(activeStep), activeSubStep);
        }
    }

    @RemoteAction
    global static void saveOfflineChatLog(String oppId, String conId, String activeStep, String activeSubStep,  String textBody){
        LFChatService.saveOfflineChatLog(textBody, '', Integer.valueof(activeStep), activeSubStep, 'France', oppId, conId);
    }


    public void prepareOnlineChat(){
        String clientNameToChat = '';
        if (this.contact != null) {
            if (this.contact.Salutation == 'Frau'){
                clientNameToChat = ' ' + 'Chère Mme' + ' ' + this.contact.LastName;
            } else {
                clientNameToChat = ' ' + 'Cher M.' + ' ' + this.contact.LastName;
            }
        }
        this.chatFirstMessage = this.chatService.getFirstChatMessage('France', this.activeStep, this.activeSubStep, clientNameToChat);
    }


    /*****************************************************************************
    *  Name            : doDecryptParams(String encryptedParams)
    *  Summary         : do decrypt url params
    *  CreatedDate     : 22/08/2018
    *  ModifiedDate    : -
    *  Parameters      : String encryptedParams
    *  Returns         : void
    ******************************************************************************/
    private void doDecryptParams(String encryptedParams) {
        encryptedParams = encryptedParams.replaceAll('(\\s|%2B)', '+');
        if (E2EKeysAPI__c.getValues('E2EFormFR') == null ) throw new LongFormException('The link is corrupted.');
        Blob key = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EFormFR').AES256_Key__c);
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


    /******************************************************************************
    *  Name            : disableTriggers()
    *  Summary         : disabling SF triggers
    *  CreatedDate     : 01/11/2018
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
    *  Summary         : deactivate inactive e2e services when changing to another step (reset viewstate)
    *  CreatedDate     : 22/08/2018
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
            this.creditLimit15 = null;
            this.creditLimit30 = null;
            this.creditLimit7 = null;
            this.defaultBillingPeriod = null;
            this.deposit = null;
            this.deposit15 = null;
            this.deposit30 = null;
            this.deposit7 = null;
            this.maxCreditLimit = null;
            this.maxCreditLimit15 = null;
            this.maxCreditLimit30 = null;
            this.maxCreditLimit7 = null;
            this.maxValue = null;
            this.maxValue15 = null;
            this.maxValue30 = null;
            this.maxValue7 = null;
            // 2 step
            this.cardsConfigService = null;
            this.homeOffersList = null;
            this.nonHomeOffersList = null;
            this.activeInnerPageCreditScoring = null;
            this.diffCardsMap = null;
            this.sameCardsMap = null;
            this.selectedCompany = null;
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
            this.homeOffersList = null;
            this.nonHomeOffersList = null;
            this.activeInnerPageCreditScoring = null;
            this.diffCardsMap = null;
            this.sameCardsMap = null;
            this.activeCardConfigTab = null;
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
            this.creditLimit15 = null;
            this.creditLimit30 = null;
            this.creditLimit7 = null;
            this.defaultBillingPeriod = null;
            this.deposit = null;
            this.deposit15 = null;
            this.deposit30 = null;
            this.deposit7 = null;
            this.maxCreditLimit = null;
            this.maxCreditLimit15 = null;
            this.maxCreditLimit30 = null;
            this.maxCreditLimit7 = null;
            this.maxValue = null;
            this.maxValue15 = null;
            this.maxValue30 = null;
            this.maxValue7 = null;
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
            this.creditLimit15 = null;
            this.creditLimit30 = null;
            this.creditLimit7 = null;
            this.defaultBillingPeriod = null;
            this.deposit = null;
            this.deposit15 = null;
            this.deposit30 = null;
            this.deposit7 = null;
            this.maxCreditLimit = null;
            this.maxCreditLimit15 = null;
            this.maxCreditLimit30 = null;
            this.maxCreditLimit7 = null;
            this.maxValue = null;
            this.maxValue15 = null;
            this.maxValue30 = null;
            this.maxValue7 = null;
            this.minCreditLimit = null;
            // 2 step
            this.cardsConfigService = null;
            this.homeOffersList = null;
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
            this.creditLimit15 = null;
            this.creditLimit30 = null;
            this.creditLimit7 = null;
            this.defaultBillingPeriod = null;
            this.deposit = null;
            this.deposit15 = null;
            this.deposit30 = null;
            this.deposit7 = null;
            this.maxCreditLimit = null;
            this.maxCreditLimit15 = null;
            this.maxCreditLimit30 = null;
            this.maxCreditLimit7 = null;
            this.maxValue = null;
            this.maxValue15 = null;
            this.maxValue30 = null;
            this.maxValue7 = null;
            this.minCreditLimit = null;
            // 2 step
            this.cardsConfigService = null;
            this.homeOffersList = null;
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
            this.creditLimit15 = null;
            this.creditLimit30 = null;
            this.creditLimit7 = null;
            this.defaultBillingPeriod = null;
            this.deposit = null;
            this.deposit15 = null;
            this.deposit30 = null;
            this.deposit7 = null;
            this.maxCreditLimit = null;
            this.maxCreditLimit15 = null;
            this.maxCreditLimit30 = null;
            this.maxCreditLimit7 = null;
            this.maxValue = null;
            this.maxValue15 = null;
            this.maxValue30 = null;
            this.maxValue7 = null;
            this.minCreditLimit = null;
            // 2 step
            this.homeOffersList = null;
            this.nonHomeOffersList = null;
            this.activeInnerPageCreditScoring = null;
            // 3 step
            this.additionalService = null;
        }
    }
}