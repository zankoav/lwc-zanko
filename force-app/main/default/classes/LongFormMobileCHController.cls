global class LongFormMobileCHController {
    public Integer activeStep {get; set;}
    public String activeSubstep {get; set;}
    public String activeInnerPage {get; set;}
    public Map<String, LongFormPage> stepPagesMap {get; set;}
    public Map<Decimal, LongForm_Menu_Item__c> menuItemsMap {get; set;}
    public String countryParam {get; set;}
    public String country;
    public String customSettingName;
    public Account account {get; set;}
    public Contact contact {get; set;}
    public Opportunity opportunity {get; set;}
    public String continueButtonStatus {get; set;}
    private String opptyIdParam;
    // Contact details
    private LFContactDetails contactDetailsService;
    // Credit Score
    private LFCreditScoring creditScoringService;
    public CFSearchResponse foundCompaniesList {get; set;}
    public CFReportResponse cfReportResponse {get; set;}
    public CreditCompany selectedCompany {get; set;}
    public Integer defaultBillingPeriod {get; set;}
    public Decimal creditLimit {get; set;}
    public Decimal minCreditLimit {get; set;}
    public Decimal creditLimit30_Plus27 {get; set;}
    public Decimal maxCreditLimit {get; set;}
    private Decimal maxCreditLimit30_Plus27;
    public Decimal maxValue {get; set;}
    private Decimal maxValue30_Plus27;
    public Decimal deposit {get; set;}
    private Decimal deposit30_Plus27;
    private CreditFactoryDecision cfDecision;
    public String unavailableOptions {get; set;}
    // Card configuration
    private LFCardsConfig cardsConfigService;
    public Integer numberOfCards {get; set;}
    public Map<Integer, LongFormCard> finalCardsMap {get; set;}
    public Map<String, List<LongFormCostItem>> costsColumnsMap {get; set;}
    public Boolean showInternationalFeesBlock {get; set;}
    public List<LongFormSpecialOffer> nonHomeOffersList {get; set;}
    // Additional
    private LFAdditional additionalService;
    // Payment Options
    private LFPaymentOptions paymentOptionsService;
    public String paymentStatus {get; set;}
    // public String selectedPaymentMethod {get; set;}
    // public String paymentURL {get; set;}
    // public Map<String, String> paymentParameters {get; set;}

    // ONLINE CHAT
    public Map<String, LongFormPage> pageMapChat {get; set;}
    public LFChatService chatService;
    public String chatButtonId {get;set;}
    public String chatDeploymentId {get; set;}
    public String chatDeploymentJsURL {get; set;}
    public String chatURL {get; set;}
    public String chatFirstMessage {get; set;}

    private Datetime startApexCall;
    private Datetime endApexCall;


    /*******************************************************************************
    *  Name            : init()
    *  Summary         : data initialization
    *  CreatedDate     : 24/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : PageReference – possible redirect to the desktop
    ******************************************************************************/
    public PageReference init() {
        try {
            // init start parameters
            this.activeStep = 0;
            this.countryParam = ApexPages.CurrentPage().getParameters().get('country');
            if ( LongFormGlobalUtils.countryParamToCountryMap.containsKey(this.countryParam) && LongFormGlobalUtils.countryParamToCustomSettingsMap.containsKey(this.countryParam) ) {
                this.country = LongFormGlobalUtils.countryParamToCountryMap.get(this.countryParam);
                this.customSettingName = LongFormGlobalUtils.countryParamToCustomSettingsMap.get(this.countryParam);
            } else {
                throw new LongFormException('The link is corrupted. Please contact your administrator');
            }
            String encryptedParams = ApexPages.CurrentPage().getParameters().get('source');
            if (encryptedParams != null && encryptedParams != '') doDecryptParams(encryptedParams);
            //menu
            LFMenu menuService = LongFormGlobalUtils.returnMenuService(this.country);
            menuService.setMenuItems('Mobile');
            this.menuItemsMap = menuService.getMenuItems();

            // check if it's mobile version
            PageReference desktopUrlRedirect = redirectToDesktop(encryptedParams);
            if (desktopUrlRedirect != null) return desktopUrlRedirect;

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
            // check case for special offers
            checkFormStage();
            if (this.activeSubstep == null) this.activeSubstep = 'Get started';
            return null;
        } catch (Exception e) {
            if (this.stepPagesMap == null) this.stepPagesMap = new Map<String, LongFormPage>();
            if (this.country != 'Switzerland-DE' || this.country != 'Switzerland-FR') {
                this.country = 'Switzerland-DE';
            }
            this.stepPagesMap.putAll(LongFormGlobalUtils.returnErrorPage(this.country, 'Mobile'));
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'init()', e);
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
            return new PageReference('/e2eformmobch?country' + this.countryParam);
        }

        return null;
    }


    /*******************************************************************************
    *  Name            : redirectToDesktop(String encodedId)
    *  Summary         : If device is desktop then redirect to the desktop version
    *  CreatedDate     : 24/01/2019
    *  ModifiedDate    : -
    *  Parameters      : String encodedId – optional encoded id for data preset
    *  Returns         : PageReference – url to desktop version
    ******************************************************************************/
    public PageReference redirectToDesktop(String encodedId) {
        String userAgent = ApexPages.currentPage().getHeaders().get('USER-AGENT');
        if (userAgent == null) return null;

        Boolean isDesktop = true;
        for (String deviceName : LongFormGlobalUtils.mobileDevicesSet) {
            if (userAgent.containsIgnoreCase(deviceName) ) {
                isDesktop = false;
                break;
            }
        }
        if (isDesktop) {
            String userName = UserInfo.getName();
            PageReference url;
            if (userName == 'E2E Site Guest User') {
                url = new PageReference('/e2eformch?country=' + this.countryParam);
            } else {
                url = new PageReference('/apex/e2eformch?country=' + this.countryParam);
            }
            if (encodedId != null) url.getParameters().put('source',encodedId);
            String utm_campaign = ApexPages.currentPage().getParameters().get('utm_campaign');
            String utm_content = ApexPages.currentPage().getParameters().get('utm_content');
            String utm_medium = ApexPages.currentPage().getParameters().get('utm_medium');
            String utm_term = ApexPages.currentPage().getParameters().get('utm_term');
            String utm_source = ApexPages.currentPage().getParameters().get('utm_source');
            String utm_url = ApexPages.currentPage().getParameters().get('utm_url');
            if (utm_campaign != null) url.getParameters().put('utm_campaign',utm_campaign);
            if (utm_content != null) url.getParameters().put('utm_content',utm_content);
            if (utm_medium != null) url.getParameters().put('utm_medium',utm_medium);
            if (utm_term != null) url.getParameters().put('utm_term',utm_term);
            if (utm_source != null) url.getParameters().put('utm_source',utm_source);
            if (utm_url != null) url.getParameters().put('utm_url',utm_url);

            return url;
        }

        return null;
    }


    /*******************************************************************************
    *  Name            : checkFormStage()
    *  Summary         : check case for special offers
    *  CreatedDate     : 24/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void checkFormStage() {
        if (this.opportunity.E2E_Active_Substep__c == 'Choosing offer' && this.finalCardsMap != null) {
            Boolean isReturnToCardConfig = false;
            for (LongFormCard card : this.finalCardsMap.values()) {
                if ((card.driverNameOrCarNumberInputValue == null || card.driverNameOrCarNumberInputValue == '')) {
                    isReturnToCardConfig = true;
                    break;
                }
            }
            if (isReturnToCardConfig) this.activeSubstep = 'Card configuration';
        }
    }


    /*******************************************************************************
    *  Name            : initPageElements()
    *  Summary         : do activate specific step
    *  CreatedDate     : 24/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void initPageElements() {
        if (this.activeStep == 0) {
            // zero step elements
            this.contactDetailsService = LongFormGlobalUtils.returnContactDetailsService(this.country);
            this.contactDetailsService.setPagesMap('Mobile');
            this.stepPagesMap = this.contactDetailsService.getPagesMap();
        } else if (this.activeStep == 1) {
            // first step elements
            this.creditScoringService = LongFormGlobalUtils.returnCreditScoringService(this.country);
            this.creditScoringService.setPagesMap('Mobile');
            this.stepPagesMap = this.creditScoringService.getPagesMap();
        } else if (this.activeStep == 2) {
            // second step elements
            this.cardsConfigService = LongFormGlobalUtils.returnCardsConfigService(this.country);
            this.cardsConfigService.setPagesMap('Mobile');
            this.stepPagesMap = this.cardsConfigService.getPagesMap();
        } else if (this.activeStep == 3) {
            // third step elements
            this.additionalService = LongFormGlobalUtils.returnAdditionalService(this.country);
            this.additionalService.setPagesMap('Mobile');
            this.stepPagesMap = this.additionalService.getPagesMap();
            this.cardsConfigService = LongFormGlobalUtils.returnCardsConfigService(this.country);
            this.cardsConfigService.setPagesMap('Mobile');
        } else if (this.activeStep == 4 || this.activeStep == 5) {
            // fourth step elements
            this.paymentOptionsService = LongFormGlobalUtils.returnPaymentOptionsService(this.country);
            this.paymentOptionsService.setPagesMap('Mobile');
            this.stepPagesMap = this.paymentOptionsService.getPagesMap();
            // this.paymentParameters = new Map<String, String>();
            this.cardsConfigService = LongFormGlobalUtils.returnCardsConfigService(this.country);
            this.cardsConfigService.setPagesMap('Mobile');
        }
    }


    /*******************************************************************************
    *  Name            : initSObjects(String opptyId)
    *  Summary         : init sobjects
    *  CreatedDate     : 24/01/2019
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
    *  CreatedDate     : 24/01/2019
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
            if (E2EKeysAPI__c.getValues(this.customSettingName) != null) {
                Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues(this.customSettingName).AES256_Key__c);
                // Direct Debit Mandate Acceptance
                this.stepPagesMap.get('CONGRATULATIONS').elements.get('DIRECT DEBIT MANDATE ACCEPTANCE BLOCK').get('DOCUMENT. IFRAME URL').Value__c = '/apex/E2EAdditionalDocuments?hash=' +
                    E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=ddMandateAcceptance' + this.countryParam.toUpperCase() + '&opportunityID=' + String.valueOf(opportunity.ID)+'&');
            }
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, 'Payment Gateway Service', this.activeSubstep, 'Return from a external service', this.country, 'Mobile');
        }
        deactivateInactiveServices();
    }


    /*******************************************************************************
    *  Name            : doPreFillingFieldsStep_0()
    *  Summary         : pre-filling of the nil step fields
    *  CreatedDate     : 24/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doPreFillingFieldsStep_0() {
        if (this.contact.Salutation != null) {
            this.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = this.contact.Salutation;
        }
        this.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = this.contact.FirstName;
        if (contact.LastName != null && ! contact.LastName.containsIgnoreCase('LongForm')) {
            this.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = this.contact.LastName;
        }
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
    *  CreatedDate     : 24/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doPreFillingFieldsStep_1() {
        if (! this.account.Name.startsWithIgnoreCase('LONGFORM:')) {
            this.stepPagesMap.get('CREDIT SCORE. SEARCH COMPANY').fields.get('COMPANY NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = this.account.Name;
        }
        if (account.BillingCity != null) {
            this.stepPagesMap.get('CREDIT SCORE. SEARCH COMPANY').fields.get('CITY').elementItemsMap.get('DEFAULT VALUE').Value__c = this.account.BillingCity;
        }
        if (this.opportunity.Total_consumption_l_month__c != null) {
            this.stepPagesMap.get('CREDIT SCORE. TOTAL CONSUMPTION').fields.get('TOTAL CONSUMPTION').elementItemsMap.get('DEFAULT VALUE').Value__c = String.valueOf(this.opportunity.Total_consumption_l_month__c);
        }
        if (opportunity.Zahlungsart__c != null) {
            this.stepPagesMap.get('CREDIT SCORE. SCORING RESULT').fields.get('PAYMENT METHOD').elementItemsMap.get('DEFAULT VALUE').Value__c = this.opportunity.Zahlungsart__c;
        }
        this.creditScoringService.setCreditReportFromSF(this.opportunity.Id);
        this.cfReportResponse = this.creditScoringService.getCreditReportFromSF();
        if (this.cfReportResponse != null) {
            this.selectedCompany = this.cfReportResponse.company;
        }
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
                restartActiveStep();
            }
        }
    }


    /*******************************************************************************
    *  Name            : doPreFillingFieldsStep_2()
    *  Summary         : pre-filling of the second step fields
    *  CreatedDate     : 24/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doPreFillingFieldsStep_2() {
        this.cardsConfigService.setCreditReport();
        this.unavailableOptions = cardsConfigService.getUnavailableOptions();
        this.cardsConfigService.setCardParamsMobile();
        this.numberOfCards = this.cardsConfigService.getNumberOfCards();
        this.selectedCompany = this.cardsConfigService.getCreditReport();
        this.cardsConfigService.setSpecialOffers('Mobile');
        this.nonHomeOffersList = this.cardsConfigService.getnonHomeOffersList();
        calculateFeesAndCosts();
        this.finalCardsMap = this.cardsConfigService.getFinalOrderCardsMap();
        this.cardsConfigService.setContinueButtonStatusMobile(this.activeStep, this.activeSubStep);
        this.continueButtonStatus = this.cardsConfigService.getContinueButtonStatusMobile();

        this.chatService.setOpportunity(this.opportunity);
        this.chatService.setContact(this.contact);
        prepareOnlineChat();
    }


    /*******************************************************************************
    *  Name            : doPreFillingFieldsStep_3()
    *  Summary         : pre-filling of the third step fields
    *  CreatedDate     : 24/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doPreFillingFieldsStep_3() {
        this.cardsConfigService.setCardParamsMobile();
        this.finalCardsMap = this.cardsConfigService.getFinalOrderCardsMap();
        this.numberOfCards = cardsConfigService.getNumberOfCards();
        this.cardsConfigService.setCreditReport();
        this.selectedCompany = this.cardsConfigService.getCreditReport();
        this.cardsConfigService.setSpecialOffers('Mobile');
        this.nonHomeOffersList = this.cardsConfigService.getnonHomeOffersList();
        calculateFeesAndCosts();
        if (! opportunity.Eco_Fee__c) this.stepPagesMap.get('ADDITIONAL').fields.get('CO2 TAKE CARE').elementItemsMap.get('VALUE').Value__c = String.valueOf(opportunity.Eco_Fee__c);
        if (E2EKeysAPI__c.getValues(this.customSettingName) != null) {
            Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues(this.customSettingName).AES256_Key__c);
            // TC
            this.stepPagesMap.get('PAYMENT OPTIONS').fields.get('ACCEPT TERM CONDITIONS').elementItemsMap.get('IFRAME URL').Value__c = '/apex/E2EAdditionalDocuments?hash=' +
                    E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=TermConditions' + this.countryParam.toUpperCase() + '&');
            this.stepPagesMap.get('PAYMENT OPTIONS').fields.get('ACCEPT TERM CONDITIONS').elementItemsMap.get('DOWNLOAD URL').Value__c = '/apex/E2EAdditionalDocuments?hash=' +
                    E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=TermConditions' + this.countryParam.toUpperCase() + '&pdfDownload=TRUE&');
        }
        this.chatService.setOpportunity(this.opportunity);
        this.chatService.setContact(this.contact);
        prepareOnlineChat();
    }


    /*******************************************************************************
    *  Name            : doPreFillingFieldsStep_4()
    *  Summary         : pre-filling of the fourth step fields
    *  CreatedDate     : 24/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doPreFillingFieldsStep_4() {
        this.cardsConfigService.setCardParamsMobile();
        this.finalCardsMap = this.cardsConfigService.getFinalOrderCardsMap();
        this.numberOfCards = cardsConfigService.getNumberOfCards();
        this.cardsConfigService.setCreditReport();
        this.selectedCompany = this.cardsConfigService.getCreditReport();
        this.cardsConfigService.setSpecialOffers('Mobile');
        this.nonHomeOffersList = this.cardsConfigService.getnonHomeOffersList();
        calculateFeesAndCosts();
        // if (opportunity.Security_Amount_To_Pay__c != null && this.paymentStatus == null) {
        //     this.paymentOptionsService.prepareTransaction('Mobile');
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
                    E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=DepositAgreement' + this.countryParam.toUpperCase() + '&opportunityID=' + String.valueOf(opportunity.ID) + '&');
            this.stepPagesMap.get('PAYMENT OPTIONS').fields.get('DEPOSIT AGREEMENT').elementItemsMap.get('DOWNLOAD URL').Value__c = '/apex/E2EAdditionalDocuments?hash=' +
                    E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=DepositAgreement' + this.countryParam.toUpperCase() + '&opportunityID=' + String.valueOf(opportunity.ID) + '&pdfDownload=TRUE&');
            // Payment information
            this.stepPagesMap.get('CONGRATULATIONS').elements.get('HOW TO PAY BLOCK').get('SAVE PAYMENT INFORMATION DOWNLOAD URL').Value__c = '/apex/E2EAdditionalDocuments?hash=' +
                E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=PaymentInformation&' + 'opportunityID=' + String.valueOf(opportunity.Id) + '&');
        }
        this.stepPagesMap.get('PAYMENT OPTIONS').fields.get('PAPER INVOICE').elementItemsMap.get('VALUE').Value__c = String.valueOf(this.opportunity.Papierrechnung__c);
        this.stepPagesMap.get('PAYMENT OPTIONS').fields.get('DECISION').elementItemsMap.get('VALUE').Value__c = String.valueOf(this.opportunity.AGB_Datenschutzhinweise_Richtigkeit__c);
        this.stepPagesMap.get('PAYMENT OPTIONS').fields.get('ACCEPT TERM CONDITIONS').elementItemsMap.get('VALUE').Value__c = String.valueOf(this.contact.Authorised_signatory__c);
        this.stepPagesMap.get('PAYMENT OPTIONS').fields.get('DEPOSIT AGREEMENT').elementItemsMap.get('VALUE').Value__c = String.valueOf(this.opportunity.Agree_To_Deposit_Agreement__c);
        this.chatService.setOpportunity(this.opportunity);
        this.chatService.setContact(this.contact);
        prepareOnlineChat();
    }


    /*******************************************************************************
    *  Name            : doPreFillingFieldsStep_5()
    *  Summary         : pre-filling of the fifth step fields
    *  CreatedDate     : 24/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doPreFillingFieldsStep_5() {
        // Payment information
        if (E2EKeysAPI__c.getValues(this.customSettingName) != null) {
            Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues(this.customSettingName).AES256_Key__c);
            this.stepPagesMap.get('CONGRATULATIONS').elements.get('HOW TO PAY BLOCK').get('SAVE PAYMENT INFORMATION DOWNLOAD URL').Value__c = '/apex/E2EAdditionalDocuments?hash=' +
                    E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=PaymentInformation&' + 'opportunityID=' + String.valueOf(opportunity.Id) + '&');
            // Direct Debit Mandate Acceptance
            this.stepPagesMap.get('CONGRATULATIONS').elements.get('DIRECT DEBIT MANDATE ACCEPTANCE BLOCK').get('DOCUMENT. IFRAME URL').Value__c = '/apex/E2EAdditionalDocuments?hash=' +
                    E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=ddMandateAcceptance' + this.countryParam.toUpperCase() + '&opportunityID=' + String.valueOf(opportunity.ID) + '&');
        }
        if (this.opportunity.E2E_payment_status__c != null && (this.opportunity.E2E_payment_status__c.substring(0, 1) == 'A' ||
            this.opportunity.E2E_payment_status__c.substring(0, 1) == 'D' || this.opportunity.E2E_payment_status__c.substring(0, 1) == 'C' ||
            this.opportunity.E2E_payment_status__c.substring(0, 1) == 'E')) {
                this.paymentStatus = this.opportunity.E2E_payment_status__c.substring(0, 1);
        }
        this.cardsConfigService.setCardParamsMobile();
        this.finalCardsMap = this.cardsConfigService.getFinalOrderCardsMap();
        this.numberOfCards = this.cardsConfigService.getNumberOfCards();
        this.cardsConfigService.setCreditReport();
        this.selectedCompany = this.cardsConfigService.getCreditReport();

        this.chatService.setOpportunity(this.opportunity);
        this.chatService.setContact(this.contact);
        prepareOnlineChat();
    }



    /*******************************************************************************
    *  Name            : setCreditScoreParameters()
    *  Summary         : set credit score parameters
    *  CreatedDate     : 24/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void setCreditScoreParameters() {
        this.defaultBillingPeriod = Integer.valueOf(this.cfReportResponse.recommendedBillingPeriod);
        this.creditLimit = this.cfReportResponse.creditLimitDefault;
        this.creditLimit30_Plus27 = this.cfReportResponse.creditLimit30_Plus27;
        this.maxCreditLimit30_Plus27 = this.cfReportResponse.maxCreditLimit30_Plus27;
        this.maxValue30_Plus27 = this.cfReportResponse.maxValue30_Plus27;
        this.deposit30_Plus27 = this.cfReportResponse.deposit30_Plus27;
    }


    /*****************************************************************************
    *  Name            : doDecryptParams(String encryptedParams)
    *  Summary         : do decrypt url params
    *  CreatedDate     : 24/01/2019
    *  ModifiedDate    : -
    *  Parameters      : String encryptedParams
    *  Returns         : void
    ******************************************************************************/
    private void doDecryptParams(String encryptedParams) {
        encryptedParams = encryptedParams.replaceAll('(\\s|%2B)', '+');
        if (E2EKeysAPI__c.getValues(this.customSettingName) == null ) throw new LongFormException('The link is corrupted.');
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
    *  Name            : restartActiveStep()
    *  Summary         : restarts active step
    *  CreatedDate     : 24/01/2019
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
    *  Name            : sendTcToEmail()
    *  Summary         : Send TC as attachment email to the user email
    *  CreatedDate     : 24/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void sendTcToEmail() {
        this.activeInnerPage = null;
        try {
            String fileName = this.stepPagesMap.get('SEND TC TO THE EMAIL').elements.get('EMAIL DATA').get('FILENAME').Value__c;
            Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues(this.customSettingName).AES256_Key__c);
            String pageRefString = '/apex/E2EAdditionalDocuments?hash=' +
                        E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=TermConditions' + this.countryParam.toUpperCase() + '&opportunityID=' + String.valueOf(opportunity.Id) + '&');
            PageReference tcPage = new PageReference(pageRefString);
            Blob pdfContent;
            if (Test.IsRunningTest()) pdfContent = Blob.valueOf('UNIT.TEST');
            else pdfContent = tcPage.getContentAsPDF();

            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName(fileName + '.pdf');
            attachment.setBody(pdfContent);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String[] toAddresses = new list<string> {this.contact.Email};
            String subject = this.stepPagesMap.get('SEND TC TO THE EMAIL').elements.get('EMAIL DATA').get('SUBJECT').Value__c;
            email.setSubject(subject);
            email.setToAddresses(toAddresses);
            String prefix;
            if (this.contact.Salutation == 'Herr') {
                prefix = this.stepPagesMap.get('SEND TC TO THE EMAIL').elements.get('EMAIL DATA').get('MR').Value__c;
            } else {
                prefix = this.stepPagesMap.get('SEND TC TO THE EMAIL').elements.get('EMAIL DATA').get('MS').Value__c;
            }
            email.setHtmlBody(prefix + ' ' + this.contact.FirstName + ' ' + this.contact.LastName + ', </br>' + this.stepPagesMap.get('SEND TC TO THE EMAIL').elements.get('EMAIL DATA').get('BODY').Value__c);
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{attachment});
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'sendTcToEmail()', e);
        }
    }


    /*******************************************************************************
    *  Name            : showSendTCDocument()
    *  Summary         : Show Send TC Document window
    *  CreatedDate     : 24/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void showSendTcDocument() {
        this.activeInnerPage = 'Send TC to the email';
    }


    /*******************************************************************************
    *  Name            : sendDepositAgreementToEmail()
    *  Summary         : Send Deposit Agreement as attachment email to the user email
    *  CreatedDate     : 24/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void sendDepositAgreementToEmail() {
        this.activeInnerPage = null;
        try {
            String fileName = this.stepPagesMap.get('SEND DEPOSIT AGREEMENT TO THE EMAIL').elements.get('EMAIL DATA').get('FILENAME').Value__c;
            Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues(this.customSettingName).AES256_Key__c);
            String pageRefString = '/apex/E2EAdditionalDocuments?hash=' +
                        E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=DepositAgreement' + this.countryParam.toUpperCase() + '&opportunityID=' + String.valueOf(opportunity.Id) + '&');
            PageReference kautionPage = new PageReference(pageRefString);
            Blob pdfContent;
            if (Test.IsRunningTest()) pdfContent = Blob.valueOf('UNIT.TEST');
            else pdfContent = kautionPage.getContentAsPDF();

            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName(fileName + '.pdf');
            attachment.setBody(pdfContent);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String[] toAddresses = new list<string> {this.contact.Email};
            String subject = this.stepPagesMap.get('SEND DEPOSIT AGREEMENT TO THE EMAIL').elements.get('EMAIL DATA').get('SUBJECT').Value__c;
            email.setSubject(subject);
            email.setToAddresses(toAddresses);
            String prefix;
            if (this.contact.Salutation == 'Herr') {
                prefix = this.stepPagesMap.get('SEND DEPOSIT AGREEMENT TO THE EMAIL').elements.get('EMAIL DATA').get('MR').Value__c;
            } else {
                prefix = this.stepPagesMap.get('SEND DEPOSIT AGREEMENT TO THE EMAIL').elements.get('EMAIL DATA').get('MS').Value__c;
            }
            email.setHtmlBody(prefix + ' ' + this.contact.FirstName + ' ' + this.contact.LastName + ', </br>' + this.stepPagesMap.get('SEND DEPOSIT AGREEMENT TO THE EMAIL').elements.get('EMAIL DATA').get('BODY').Value__c);
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{attachment});
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'sendDepositAgreementToEmail()', e);
        }
    }


    /*******************************************************************************
    *  Name            : showSendDepositAgreementDocument()
    *  Summary         : Show Send Deposit Agreement Document window
    *  CreatedDate     : 24/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void showSendDepositAgreementDocument() {
        this.activeInnerPage = 'Send Deposit Agreement to the email';
    }


    /*******************************************************************************
    *  Name            : sendHowToPayToEmail()
    *  Summary         : Send How to Pay as attachment email to the user email
    *  CreatedDate     : 24/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void sendHowToPayToEmail() {
        this.activeInnerPage = null;
        try {
            String fileName = this.stepPagesMap.get('SEND HOW TO PAY TO THE EMAIL').elements.get('EMAIL DATA').get('FILENAME').Value__c;
            Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues(this.customSettingName).AES256_Key__c);
            String pageRefString = '/apex/E2EAdditionalDocuments?hash=' +
                        E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=PaymentInformation&' + 'opportunityID=' + String.valueOf(opportunity.Id) + '&');
            PageReference kautionPage = new PageReference(pageRefString);
            Blob pdfContent;
            if (Test.IsRunningTest()) pdfContent = Blob.valueOf('UNIT.TEST');
            else pdfContent = kautionPage.getContentAsPDF();

            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName(fileName + '.pdf');
            attachment.setBody(pdfContent);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String[] toAddresses = new list<string> {this.contact.Email};
            String subject = this.stepPagesMap.get('SEND HOW TO PAY TO THE EMAIL').elements.get('EMAIL DATA').get('SUBJECT').Value__c;
            email.setSubject(subject);
            email.setToAddresses(toAddresses);
            String prefix;
            if (this.contact.Salutation == 'Herr') {
                prefix = this.stepPagesMap.get('SEND HOW TO PAY TO THE EMAIL').elements.get('EMAIL DATA').get('MR').Value__c;
            } else {
                prefix = this.stepPagesMap.get('SEND HOW TO PAY TO THE EMAIL').elements.get('EMAIL DATA').get('MS').Value__c;
            }
            email.setHtmlBody(prefix + ' ' + this.contact.FirstName + ' ' + this.contact.LastName + ', </br>' + this.stepPagesMap.get('SEND HOW TO PAY TO THE EMAIL').elements.get('EMAIL DATA').get('BODY').Value__c);
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{attachment});
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'sendHowToPayToEmail()', e);
        }
    }


    /*******************************************************************************
    *  Name            : showSendHowToPayDocument()
    *  Summary         : Show How to Pay Document window
    *  CreatedDate     : 24/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void showSendHowToPayDocument() {
        this.activeInnerPage = 'Send How to Pay to the email';
    }


    /*******************************************************************************
    *  Name            : sendDDMandateAcceptance()
    *  Summary         : Send docusign DDMandateAcceptance as attachment to the user email
    *  CreatedDate     : 11/02/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void sendDDMandateAcceptance() {
        this.activeInnerPage = null;
        try {
            String fileName = this.stepPagesMap.get('SEND DDMANDATE TO THE EMAIL').elements.get('EMAIL DATA').get('FILENAME').Value__c;
            Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues(this.customSettingName).AES256_Key__c);
            String pageRefString = '/apex/E2EAdditionalDocuments?hash=' +
                        E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=ddMandateAcceptance' + this.countryParam.toUpperCase() + '&opportunityID=' + String.valueOf(opportunity.Id) + '&');
            PageReference ddMandatePage = new PageReference(pageRefString);
            Blob pdfContent;
            if (Test.IsRunningTest()) pdfContent = Blob.valueOf('UNIT.TEST');
            else pdfContent = ddMandatePage.getContentAsPDF();

            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName(fileName + '.pdf');
            attachment.setBody(pdfContent);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String[] toAddresses = new list<string> {this.contact.Email};
            String subject = this.stepPagesMap.get('SEND DDMANDATE TO THE EMAIL').elements.get('EMAIL DATA').get('SUBJECT').Value__c;
            email.setSubject(subject);
            email.setToAddresses(toAddresses);
            String prefix;
            if (this.contact.Salutation == 'Herr') {
                prefix = this.stepPagesMap.get('SEND DDMANDATE TO THE EMAIL').elements.get('EMAIL DATA').get('MR').Value__c;
            } else {
                prefix = this.stepPagesMap.get('SEND DDMANDATE TO THE EMAIL').elements.get('EMAIL DATA').get('MS').Value__c;
            }
            email.setHtmlBody(prefix + ' ' + this.contact.FirstName + ' ' + this.contact.LastName + ', </br>' + this.stepPagesMap.get('SEND DDMANDATE TO THE EMAIL').elements.get('EMAIL DATA').get('BODY').Value__c);
            email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'sendDDMandateAcceptance()', e);
        }
    }


    /*******************************************************************************
    *  Name            : showDDMandateDocument()
    *  Summary         : Show DD Mandate Agreement Document window
    *  CreatedDate     : 11/02/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void showDDMandateDocument() {
        this.activeInnerPage = 'Send ddmandate to the email';
    }


    /*******************************************************************************
    *  Name            : sendEnvelope()
    *  Summary         : Method to send envelope with documents for customer/save and continue later
    *  CreatedDate     : 30/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void sendEnvelope() {
        if (this.activeInnerPage == 'Send How to Pay to the email') {
            sendHowToPayToEmail();
        } else if (this.activeInnerPage == 'Send TC to the email') {
            sendTcToEmail();
        } else if (this.activeInnerPage == 'Send Deposit Agreement to the email') {
            sendDepositAgreementToEmail();
        } else if (this.activeInnerPage == 'Send ddmandate to the email') {
            sendDDMandateAcceptance();
        } else if (this.activeInnerPage == 'Save and continue later') {
            doSaveAndContinueLater();
        }
    }


    /*******************************************************************************
    *  Name            : doSaveAndContinueLater()
    *  Summary         : Save and continue later
    *  CreatedDate     : 24/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void doSaveAndContinueLater() {
        try {
            this.activeInnerPage = '';
            if (this.activeSubstep == 'Enter Tax ID' ||
                this.activeSubstep == 'Set total consumption' || this.activeSubstep == 'Calculating credit score') {
                this.creditScoringService.doSaveAndContinueLater();
            } else if (this.activeSubstep == 'Card configuration' || this.activeSubstep == 'Choosing offer') {
                this.cardsConfigService.doSaveAndContinueLater();
            } else if (this.activeSubstep == 'Additional services') {
                this.additionalService.doSaveAndContinueLater();
            } else if (this.activeSubstep == 'DirectDebit' || this.activeSubstep == 'DirectDebitDeposit' ||
                    this.activeSubstep == 'BankTransfer' || this.activeSubstep == 'BankTransferDeposit') {
                this.paymentOptionsService.doSaveAndContinueLater();
            }
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'doSaveAndContinueLater()', e);
        }
    }


    /*******************************************************************************
    *  Name            : showSaveAndContinueLaterModal()
    *  Summary         : show save and continue later modal
    *  CreatedDate     : 24/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void showSaveAndContinueLaterModal() {
        this.activeInnerPage = 'Save and continue later';
    }


    /*******************************************************************************
    *  Name            : getStarted()
    *  Summary         : go to 'Contact details' substep
    *  CreatedDate     : 24/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void getStarted() {
        this.activeSubstep = 'Contact details';
    }


    /*******************************************************************************
    *  Name            : goToCompanyDetails()
    *  Summary         : save data and go to "Company details" step
    *  CreatedDate     : 24/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : PageReference
    ******************************************************************************/
    public PageReference goToCompanyDetails() {
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
                                    url = '/e2eFormMobch?country=' + this.countryParam + '&source=';
                                } else {
                                    url = '/apex/e2eFormMobch?country=' + this.countryParam + '&source=';
                                }
                                PageReference reference = new PageReference(url + contactRole.Opportunity.E2E_Encoded_URL__c);
                                reference.setRedirect(true);
                                if (this.opportunity != null) {
                                    LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, this.country, 'Mobile');
                                }
                                return reference;
                            }
                        }
                    }

                    // standard duplicate
                    this.contactDetailsService.setContact(duplicateContact);
                    this.contactDetailsService.updateRecord(false);
                    this.contactDetailsService.insertRecords(duplicateContact, 'Mobile');
                } else {
                    // no duplicates
                    this.contactDetailsService.insertRecords(null, 'Mobile');
                }

                this.opportunity = this.contactDetailsService.getOpportunity();
                initPageElements();
                initSObjects(opportunity.Id);
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
                                    url = '/e2eFormMobch?country=' + this.countryParam + '&source=';
                                } else {
                                    url = '/apex/e2eFormMobch?country=' + this.countryParam + '&source=';
                                }
                                PageReference reference = new PageReference(url + contactRole.Opportunity.E2E_Encoded_URL__c);
                                reference.setRedirect(true);
                                this.endApexCall = Datetime.now();
                                LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, contactRole.Opportunity.Id, currentActiveSubstep, this.activeSubStep, null, this.country, 'Mobile');
                                return reference;
                            }
                        }
                    }

                    // standard duplicate
                    this.contactDetailsService.updateOpportunityToLost();
                    this.contactDetailsService.setContact(duplicateContact);
                    this.contactDetailsService.updateRecord(false);
                    this.contactDetailsService.insertRecords(duplicateContact, 'Mobile');
                } else {
                    // update contact if no dups
                    this.contactDetailsService.updateRecord(false);
                }
                this.opportunity = this.contactDetailsService.getOpportunity();
                initPageElements();
                initSObjects(opportunity.Id);
                doPreFillingFormFields();
            }
            deactivateInactiveServices();
            this.chatService.setOpportunity(opportunity);
            this.chatService.setContact(contact);
            prepareOnlineChat();
            if (formOfBusiness == 'Solo-trader') {
                this.stepPagesMap.get('CREDIT SCORE. SEARCH COMPANY').fields.get('COMPANY NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = this.contact.Name;
            }
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, this.country, 'Mobile');
            return null;
        } catch (Exception e) {
            this.activeStep = 0;
            this.activeSubstep = 'System error';
            if (opportunity != null && opportunity.Id != null) {
                initSObjects(opportunity.Id);
                E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
                E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'goToCompanyDetails()', e);
            } else {
                E2EExceptionUtils.sendExceptionEmail(null, null, null, 'Mobile', 'goToCompanyDetails()', e);
            }
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : doSaveCompanyDetailsData()
    *  Summary         : do save company details data
    *  CreatedDate     : 24/01/2019
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
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'doSaveCompanyDetailsData()', e);
        }
    }


    /*******************************************************************************
    *  Name            : doSearchCompany()
    *  Summary         : search company
    *  CreatedDate     : 24/01/2019
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
            this.foundCompaniesList = this.creditScoringService.getCompaniesFromCF();
            disableTriggers();
            this.opportunity.CF_Stage__c = 'Launched';
            this.opportunity.E2E_Number_of_Search_Companies__c = this.foundCompaniesList.companiesMap.size();
            update this.opportunity;
            if (this.selectedCompany == null) this.selectedCompany = new CreditCompany();
            if (! this.foundCompaniesList.companiesMap.isEmpty() ) {
                this.activeInnerPage = 'Select company';
            } else {
                throw new LongFormException(E2EExceptionUtils.errorsMap.get('Company not found'));
            }
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, 'This is a company search process.', this.country, 'Mobile');
        } catch (Exception e) {
            if (e.getMessage() == E2EExceptionUtils.errorsMap.get('Company not found')) {
                this.activeSubStep = 'Company not found';
                E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            } else {
                this.activeSubstep = 'System error';
                E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
                E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'doSearchCompany()', e);
            }
        }
    }


    /*******************************************************************************
    *  Name            : goToSetTotalConsumption()
    *  Summary         : go to total consumption substep
    *  CreatedDate     : 24/01/2019
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
                this.activeStep = 1;
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
                this.activeSubStep = stopProcess;
                this.activeStep = 1;
                E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubStep, null);
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
                    this.activeStep = 1;
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
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, this.country, 'Mobile');
         } catch (Exception e) {
            initSObjects(opportunity.Id);
            this.activeInnerPage = null;
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'goToSetTotalConsumption()', e);
        }
    }


    /*******************************************************************************
    *  Name            : deleteReportsForPreviousCompany()
    *  Summary         : Delete all credit factory reports if user selects new company
    *  CreatedDate     : 24/01/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void deleteReportsForPreviousCompany() {
        try {
            this.startApexCall = Datetime.now();
            this.creditScoringService.deleteCreditFactoryReports(this.selectedCompany.identificationnumber);
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'deleteReportsForPreviousCompany()', e);
        }
    }


    /*******************************************************************************
    *  Name            : continueToTotalConsumption()
    *  Summary         : continue to "Total consumption" substep from "Another Tax Id" substep
    *  CreatedDate     : 24/01/2019
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
            String stopProcess = this.creditScoringService.searchDuplicates(selectedCompany);
            if (stopProcess != null) {
                this.activeSubStep = stopProcess;
                this.activeStep = null;
                E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubStep, null);
                return;
            }
            // Switzerland use VATID but call it TAXID. The code below is ok.
            this.creditScoringService.doUpdateTaxId(selectedCompany.vatid);
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
            prepareOnlineChat();
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, this.country, 'Mobile');
        } catch (Exception e) {
            initSObjects(opportunity.Id);
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'continueToTotalConsumption()', e);
        }
    }


    /*******************************************************************************
    *  Name            : doCalculateCreditScoring()
    *  Summary         : calculating credit scoring
    *  CreatedDate     : 24/01/2019
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
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, this.country, 'Mobile');
        } catch (Exception e) {
            if (e.getMessage() == E2EExceptionUtils.errorsMap.get('Too high limit')) {
                this.activeSubStep = 'Too high limit';
                E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            } else {
                this.activeSubstep = 'System error';
                E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
                E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'doCalculateCreditScoring()', e);
            }
        }
    }


    /*******************************************************************************
    *  Name            : returnFinalCreditScoreData()
    *  Summary         : return final of credit score data
    *  CreatedDate     : 24/01/2019
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
    *  Name            : doRecalculateDeposit()
    *  Summary         : recalculate deposit
    *  CreatedDate     : 24/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doRecalculateDeposit() {
        try {
            this.activeInnerPage = '';
            this.creditScoringService.setDeposit(this.selectedCompany, this.defaultBillingPeriod, null, this.creditLimit, this.maxCreditLimit);
            this.deposit = this.creditScoringService.getDeposit();
            this.creditScoringService.resetCfDecision(this.defaultBillingPeriod, null, this.deposit, this.selectedCompany.classRating, this.selectedCompany);
            this.cfDecision = this.creditScoringService.getCfDecision();
        } catch(Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'doRecalculateDeposit()', e);
        }
    }


    /*******************************************************************************
    *  Name            : goToCardsConfig()
    *  Summary         : go to long form step 2
    *  CreatedDate     : 24/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void goToCardsConfig() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            this.startApexCall = Datetime.now();
            disableTriggers();
            this.activeStep = 2;
            this.activeSubStep = 'Card configuration';
            this.creditScoringService.saveCreditScoringResult(this.defaultBillingPeriod, null, this.creditLimit, this.deposit);
            initPageElements();
            initSObjects(opportunity.Id);
            doPreFillingFormFields();
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, this.country, 'Mobile');
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'goToCardsConfig()', e);
        }
    }


    /*******************************************************************************
    *  Name            : calculateFeesAndCosts()
    *  Summary         : calculate fees and costs for selected cards
    *  CreatedDate     : 24/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void calculateFeesAndCosts() {
        this.cardsConfigService.setCostsColumnsMapMobile();
        this.costsColumnsMap = this.cardsConfigService.getCostsColumnsMap();
        this.showInternationalFeesBlock = this.cardsConfigService.getInternationalFeesBlock();
    }


    /*******************************************************************************
    *  Name            : goToOptions()
    *  Summary         : go to "Options" tab of "Card configuration" step
    *  CreatedDate     : 24/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void goToOptions() {
        this.cardsConfigService.setContinueButtonStatusMobile(this.activeStep, this.activeSubStep);
        this.continueButtonStatus = this.cardsConfigService.getContinueButtonStatusMobile();
    }


    /*******************************************************************************
    *  Name            : goToEmbossing()
    *  Summary         : go to "Embossing" tab of "Card configuration" step
    *  CreatedDate     : 24/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void goToEmbossing() {
        this.cardsConfigService.setContinueButtonStatusMobile(this.activeStep, this.activeSubStep);
        this.continueButtonStatus = this.cardsConfigService.getContinueButtonStatusMobile();
    }


    /*******************************************************************************
    *  Name            : changeNumberOfCards()
    *  Summary         : change total number of cards
    *  CreatedDate     : 24/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void changeNumberOfCards() {
        try {
            this.activeInnerPage = '';
            if (this.numberOfCards == null || this.numberOfCards == 0) this.numberOfCards = 1;
            this.cardsConfigService.changeNumberOfCardsMobile(this.numberOfCards);
            this.finalCardsMap = this.cardsConfigService.getFinalOrderCardsMap();
            this.cardsConfigService.setContinueButtonStatusMobile(this.activeStep, this.activeSubStep);
            this.continueButtonStatus = this.cardsConfigService.getContinueButtonStatusMobile();
            calculateFeesAndCosts();
        } catch (Exception e) {
            this.numberOfCards = this.cardsConfigService.getNumberOfCards();
            if (e.getMessage() == 'Remove extra cards error') {
                this.activeInnerPage = 'Remove extra cards';
            } else if (e.getMessage() == 'No more 2 card error') {
                this.activeInnerPage = 'No more 2 card error';
            } else if (e.getMessage() == 'No more 5 card error') {
                this.activeInnerPage = 'No more 5 card error';
            } else {
                this.activeSubstep = 'System error';
                E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
                E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'changeNumberOfCards()', e);
            }
        }
    }


    /*******************************************************************************
    *  Name            : saveCard()
    *  Summary         : save technical params for single card
    *  CreatedDate     : 24/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void saveCard() {
        try {
            this.cardsConfigService.saveTechParamForSingleCardMobile(Integer.valueOf(ApexPages.CurrentPage().getparameters().get('cardindex')));
            this.finalCardsMap = this.cardsConfigService.getFinalOrderCardsMap();
            this.continueButtonStatus = this.cardsConfigService.getContinueButtonStatusMobile();
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'saveCard()', e);
        }
    }


    /*******************************************************************************
    *  Name            : removeCard()
    *  Summary         : remove the card
    *  CreatedDate     : 24/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void removeCard() {
        try {
            this.activeInnerPage = '';
            Integer cardIndex = Integer.valueOf(ApexPages.CurrentPage().getparameters().get('cardIndex'));
            this.cardsConfigService.removeCardMobile(cardIndex);
            this.finalCardsMap = this.cardsConfigService.getFinalOrderCardsMap();
            this.numberOfCards = this.cardsConfigService.getNumberOfCards();
            this.cardsConfigService.setContinueButtonStatusMobile(this.activeStep, this.activeSubStep);
            this.continueButtonStatus = this.cardsConfigService.getContinueButtonStatusMobile();
            calculateFeesAndCosts();
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'removeCard()', e);
        }
    }


    /*******************************************************************************
    *  Name            : editCardConfigurationMobile()
    *  Summary         : open configuration block for selected card
    *  CreatedDate     : 24/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void editCardConfigurationMobile() {
        try {
            this.activeInnerPage = '';
            Integer cardIndex = Integer.valueOf(ApexPages.CurrentPage().getparameters().get('cardIndex'));
            this.cardsConfigService.editCardConfigurationMobile(cardIndex);
            this.finalCardsMap = this.cardsConfigService.getFinalOrderCardsMap();
            this.cardsConfigService.setSpecialOffers('Mobile');
            this.cardsConfigService.setContinueButtonStatusMobile(this.activeStep, this.activeSubstep);
            this.continueButtonStatus = this.cardsConfigService.getContinueButtonStatusMobile();
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'editCardConfigurationMobile()', e);
        }
    }


    /*******************************************************************************
    *  Name            : editCompanyName()
    *  Summary         : edit company name
    *  CreatedDate     : 24/01/2019
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
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'editCompanyName()', e);
        }
    }


    /*******************************************************************************
    *  Name            : goToFeesAndCosts()
    *  Summary         : go to "Fees and Costs" substep of "Card configuration" step
    *  CreatedDate     : 24/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void goToFeesAndCosts() {
        try {
            this.activeInnerPage = '';
            this.cardsConfigService.saveTechParamForSingleCardMobile(Integer.valueOf(ApexPages.CurrentPage().getparameters().get('cardindex')));
            this.finalCardsMap = this.cardsConfigService.getFinalOrderCardsMap();
            this.continueButtonStatus = this.cardsConfigService.getContinueButtonStatusMobile();
            calculateFeesAndCosts();
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'goToFeesAndCosts()', e);
        }
    }


    /*******************************************************************************
    *  Name            : saveConfiguration()
    *  Summary         : saving all selected cards
    *  CreatedDate     : 24/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void goToSpecialOffers() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            this.startApexCall = Datetime.now();
            disableTriggers();
            this.activeStep = 2;
            this.activeSubStep = 'Choosing offer';
            this.cardsConfigService.saveCardsConfigResultMobile(this.activeSubStep);
            this.finalCardsMap = this.cardsConfigService.getFinalOrderCardsMap();
            this.cardsConfigService.setSpecialOffers('Mobile');
            this.nonHomeOffersList = this.cardsConfigService.getnonHomeOffersList();
            this.activeStep = 2;
            this.activeSubStep = 'Choosing offer';
            this.cardsConfigService.setContinueButtonStatusMobile(this.activeStep, this.activeSubStep);
            this.continueButtonStatus = this.cardsConfigService.getContinueButtonStatusMobile();
            prepareOnlineChat();
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, this.country, 'Mobile');
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'goToSpecialOffers()', e);
        }
    }


    /*******************************************************************************
    *  Name            : goToAdditionalParams()
    *  Summary         : go to "Additional" step
    *  CreatedDate     : 24/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void goToAdditionalParams() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            this.startApexCall = Datetime.now();
            disableTriggers();
            this.cardsConfigService.saveSpecialOfferMobile();
            this.activeInnerPage = '';
            this.activeStep = 3;
            this.activeSubStep = 'Additional services';
            initPageElements();
            initSObjects(opportunity.Id);
            doPreFillingFormFields();
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, this.country, 'Mobile');
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'goToAdditionalParams()', e);
        }
    }


    /*******************************************************************************
    *  Name            : goToPaymentOptions()
    *  Summary         : Save CO2 if it exists and go to payments options (STEP 4)
    *  CreatedDate     : 24/01/2019
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
            initSObjects(opportunity.Id);
            doPreFillingFormFields();
            PageReference paymentPage = new PageReference('/apex/e2eformmobch?country=' + this.countryParam + '&source=' + this.opportunity.E2E_Encoded_URL__c);
            paymentPage.setRedirect(true);
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, this.country, 'Mobile');
            return paymentPage;
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'goToPaymentOptions()', e);
            return null;
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : changePaymentMethod()
    *  Summary         : set payment method
    *  CreatedDate     : 24/01/2019
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
    //         E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'changePaymentMethod()', e);
    //     }
    // }


    /*******************************************************************************
    *  Name            : getTransactionParameters()
    *  Summary         : return transaction parameters
    *  CreatedDate     : 24/01/2019
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


    /*******************************************************************************
    *  Name            : showTermsAndConditions()
    *  Summary         : show term and conditions modal window
    *  CreatedDate     : 24/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void showTermsAndConditions() {
        this.activeInnerPage = 'Modal Term And Conditions';
    }

    /*******************************************************************************
    *  Name            : showDepositAgreementModal()
    *  Summary         : show deposit agreement modal window
    *  CreatedDate     : 24/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void showDepositAgreementModal() {
        this.activeInnerPage = 'Modal Deposit Agreement';
    }


    /*******************************************************************************
    *  Name            : showDDMandateModal()
    *  Summary         : show dd mandate aggrement modal window
    *  CreatedDate     : 11/02/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void showDDMandateModal() {
        this.activeInnerPage = 'Modal ddMandate';
    }


    /*******************************************************************************
    *  Name            : proceedToCheckout()
    *  Summary         : go to payment system
    *  CreatedDate     : 24/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void proceedToCheckout() {
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
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, this.country, 'Mobile');
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'proceedToCheckout()', e);
        }
    }


    /*******************************************************************************
    *  Name            : editContactDetails()
    *  Summary         : edit contact details
    *  CreatedDate     : 24/01/2019
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
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, this.country, 'Mobile');
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'editContactDetails()', e);
        }
    }


    /*******************************************************************************
    *  Name            : editCompanyDetails()
    *  Summary         : edit company details
    *  CreatedDate     : 24/01/2019
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
            doPreFillingFormFields();
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, this.country, 'Mobile');
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'editCompanyDetails()', e);
        }
    }


    /*******************************************************************************
    *  Name            : editCreditScoreData()
    *  Summary         : edit credit score data
    *  CreatedDate     : 24/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void editCreditScoreData() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            this.startApexCall = Datetime.now();
            this.activeInnerPage = '';
            this.activeStep = 1;
            this.activeSubStep = 'Calculating credit score';
            initPageElements();
            initSObjects(opportunity.Id);
            doPreFillingFormFields();
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, this.country, 'Mobile');
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'editCreditScoreData()', e);
        }
    }


    /*******************************************************************************
    *  Name            : editCardConfiguration()
    *  Summary         : edit card configuration
    *  CreatedDate     : 24/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void editCardConfiguration() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            this.startApexCall = Datetime.now();
            this.activeStep = 2;
            this.activeSubStep = 'Card configuration';
            initPageElements();
            initSObjects(opportunity.Id);
            doPreFillingFormFields();
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, this.country, 'Mobile');
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'editCardConfiguration()', e);
        }
    }


    /*******************************************************************************
    *  Name            : editSpecialOffers()
    *  Summary         : edit card configuration
    *  CreatedDate     : 24/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void editSpecialOffers() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            this.startApexCall = Datetime.now();
            this.activeStep = 2;
            this.activeSubStep = 'Choosing offer';
            initPageElements();
            initSObjects(opportunity.Id);
            doPreFillingFormFields();
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, this.country, 'Mobile');
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'editSpecialOffers()', e);
        }
    }


    /*******************************************************************************
    *  Name            : closeModal()
    *  Summary         : close modal window
    *  CreatedDate     : 24/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void closeModal() {
        this.activeInnerPage = null;
    }


    /*******************************************************************************
    *  Name            : updateOpportunityOnReturnFromEmail()
    *  Summary         : Update Opportunity fields on return from marketing email
    *  CreatedDate     : 24/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void updateOpportunityOnReturnFromEmail() {
        if (this.activeStep == 0) {
            this.contactDetailsService.updateOpportunityOnReturnFromEmail('Mobile');
        } else if (this.activeStep == 1) {
            this.creditScoringService.updateOpportunityOnReturnFromEmail('Mobile');
        } else if (this.activeStep == 2) {
            this.cardsConfigService.updateOpportunityOnReturnFromEmail('Mobile');
        } else if (this.activeStep == 3) {
            this.additionalService.updateOpportunityOnReturnFromEmail('Mobile');
        } else if (this.activeStep == 4 || this.activeStep == 5) {
            this.paymentOptionsService.updateOpportunityOnReturnFromEmail('Mobile');
        }
    }


    /*******************************************************************************
    *  Name            : setFlagChatToOpportunity()
    *  Summary         : update opportunity chat flag
    *  CreatedDate     : 24/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/

    @RemoteAction
    global static void setFlagChatToOpportunity(String oppId, String activeStep, String activeSubStep, String modeOfChat){
        if(modeOfChat != ''){
            LFChatService.setFlagChatToOpportunity(oppId, modeOfChat, Integer.valueof(activeStep), activeSubStep);
        }
    }


    /*******************************************************************************
    *  Name            : initChatSetup()
    *  Summary         : init chat setup
    *  CreatedDate     : 24/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
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


    /*******************************************************************************
    *  Name            : saveOfflineChatLog()
    *  Summary         : update offline chat
    *  CreatedDate     : 24/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
     @RemoteAction
     global static void saveOfflineChatLog(String oppId, String conId, String activeStep, String activeSubStep,  String textBody, String country){
         LFChatService.saveOfflineChatLog(textBody, '', Integer.valueof(activeStep), activeSubStep, country, oppId, conId);
     }


    /*******************************************************************************
    *  Name            : prepareOnlineChat()
    *  Summary         : prepare online chat
    *  CreatedDate     : 24/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void prepareOnlineChat(){
        String clientNameToChat = '';
        if (contact != null) {
            clientNameToChat = ' ' + contact.Salutation + ' ' + contact.LastName;
        }
        chatFirstMessage = chatService.getFirstChatMessage(this.country, activeStep, activeSubStep, clientNameToChat);
    }


    /******************************************************************************
    *  Name            : disableTriggers()
    *  Summary         : disabling SF triggers
    *  CreatedDate     : 24/01/2019
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
    *  CreatedDate     : 24/01/2019
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
            this.foundCompaniesList = null;
            this.creditLimit = null;
            this.creditLimit30_Plus27 = null;
            this.defaultBillingPeriod = null;
            this.deposit = null;
            this.deposit30_Plus27 = null;
            this.maxCreditLimit = null;
            this.maxCreditLimit30_Plus27 = null;
            this.maxValue = null;
            this.maxValue30_Plus27 = null;
            this.selectedCompany = null;
            // 2 step
            this.cardsConfigService = null;
            this.nonHomeOffersList = null;
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
            this.foundCompaniesList = null;
            this.creditLimit = null;
            this.creditLimit30_Plus27 = null;
            this.defaultBillingPeriod = null;
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
            this.foundCompaniesList = null;
            this.creditLimit = null;
            this.creditLimit30_Plus27 = null;
            this.defaultBillingPeriod = null;
            this.deposit = null;
            this.deposit30_Plus27 = null;
            this.maxCreditLimit = null;
            this.maxCreditLimit30_Plus27 = null;
            this.maxValue = null;
            this.maxValue30_Plus27 = null;
            this.minCreditLimit = null;
            // 4 step
            this.paymentOptionsService = null;
        } else if (this.activeStep == 4 || this.activeStep == 5) {
            // 0 step
            this.contactDetailsService = null;
            // 1 step
            this.cfDecision =  null;
            this.cfReportResponse = null;
            this.creditScoringService = null;
            this.foundCompaniesList = null;
            this.creditLimit = null;
            this.creditLimit30_Plus27 = null;
            this.defaultBillingPeriod = null;
            this.deposit = null;
            this.deposit30_Plus27 = null;
            this.maxCreditLimit = null;
            this.maxCreditLimit30_Plus27 = null;
            this.maxValue = null;
            this.maxValue30_Plus27 = null;
            this.minCreditLimit = null;
            // 2 step
            this.cardsConfigService = null;
            // 3 step
            this.additionalService = null;
        }
    }
}