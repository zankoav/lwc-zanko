public class LongFormMobileNLController {
    public Integer activeStep {get; set;}
    public String activeSubstep {get; set;}
    public String activeInnerPage {get; set;}
    public Map<String, LongFormPage> stepPagesMap {get; set;}
    public Map<Decimal, LongForm_Menu_Item__c> menuItemsMap {get; set;}
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
    public String unavailableOptions {get; set;}
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
    private Decimal deposit7;
    private Decimal deposit15;
    private Decimal deposit30;
    private CreditFactoryDecision cfDecision;
    // Card configuration
    private LFCardsConfig cardsConfigService;
    public Integer numberOfCards {get; set;}
    public Map<Integer, LongFormCard> finalCardsMap {get; set;}
    public Map<String, List<LongFormCostItem>> costsColumnsMap {get; set;}
    public Boolean showInternationalFeesBlock {get; set;}
    public List<LongFormSpecialOffer> homeOffersList {get; set;}
    public List<LongFormSpecialOffer> nonHomeOffersList {get; set;}
    public String jsonStation {get; set;}
    public String urlLocator {get; set;}
    public Boolean isVatIdValid {get; set;}
    // Additional
    private LFAdditional additionalService;
    // Payment Options
    private LFPaymentOptions paymentOptionsService;
    public String paymentStatus {get; set;}
    public String selectedPaymentMethod {get; set;}
    public String paymentURL {get; set;}
    public Map<String, String> paymentParameters {get; set;}
    public Boolean isIBANValid {get; set;}
    public Boolean showSwiftField {get; set;}

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
    *  CreatedDate     : 14/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : PageReference – possible redirect to the desktop
    ******************************************************************************/
    public PageReference init() {
        try {
            this.activeStep = 0;
            String encryptedParams = ApexPages.CurrentPage().getParameters().get('source');
            if (encryptedParams != null && encryptedParams != '') doDecryptParams(encryptedParams);

            //menu
            LFMenu menuService = LongFormGlobalUtils.returnMenuService('Netherlands');
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
                    activateNewStep(this.opptyIdParam);
                } else {
                    doPreFillingFormFields();
                }
            }
            // check case for special offers
            checkFormStage();
            if (this.activeSubstep == null) this.activeSubstep = 'Get started';
            return null;
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            if (this.stepPagesMap == null) this.stepPagesMap = new Map<String, LongFormPage>();
            this.stepPagesMap.putAll(LongFormGlobalUtils.returnErrorPage('Netherlands', 'Mobile'));
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
            return new PageReference('/e2eformmobnl');
        }

        return null;
    }      


    /*******************************************************************************
    *  Name            : redirectToDesktop(String encodedId)
    *  Summary         : If device is desktop then redirect to the desktop version
    *  CreatedDate     : 15/08/2018
    *  ModifiedDate    : 13/12/2018 - by Eugene. Added PageReference instead of hardcoded params in url.    
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
                url = new PageReference('/e2eformnl');
            } else {
                url = new PageReference('/apex/e2eformnl');
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
    *  CreatedDate     : 15/08/2018
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
            if (this.opportunity.E2E_Active_Substep__c == 'Choosing offer') {
                this.activeSubstep = 'Card configuration';
                this.cardsConfigService.setContinueButtonStatusMobile(this.activeStep, this.activeSubStep);
                this.continueButtonStatus = this.cardsConfigService.getContinueButtonStatusMobile();
            }
        }
        if (this.opportunity.StageName == 'Closed Won' && this.opportunity.E2E_Active_Substep__c != 'Congratulations') this.activeSubstep = 'Stop order';
    }


    /*******************************************************************************
    *  Name            : initPageElements()
    *  Summary         : do activate specific step
    *  CreatedDate     : 15/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void initPageElements() {
        if (this.activeStep == 0) {
            // zero step elements
            this.contactDetailsService = LongFormGlobalUtils.returnContactDetailsService('Netherlands');
            this.contactDetailsService.setPagesMap('Mobile');
            this.stepPagesMap = this.contactDetailsService.getPagesMap();
        } else if (this.activeStep == 1) {
            // first step elements
            this.creditScoringService = LongFormGlobalUtils.returnCreditScoringService('Netherlands');
            this.creditScoringService.setPagesMap('Mobile');
            this.stepPagesMap = this.creditScoringService.getPagesMap();
        } else if (this.activeStep == 2) {
            // second step elements
            this.cardsConfigService = LongFormGlobalUtils.returnCardsConfigService('Netherlands');
            this.cardsConfigService.setPagesMap('Mobile');
            this.stepPagesMap = this.cardsConfigService.getPagesMap();
        } else if (this.activeStep == 3) {
            // third step elements
            this.additionalService = LongFormGlobalUtils.returnAdditionalService('Netherlands');
            this.additionalService.setPagesMap('Mobile');
            this.stepPagesMap = this.additionalService.getPagesMap();
            this.cardsConfigService = LongFormGlobalUtils.returnCardsConfigService('Netherlands');
            this.cardsConfigService.setPagesMap('Mobile');
        } else if (this.activeStep == 4 || this.activeStep == 5) {
            // fourth step elements
            this.paymentOptionsService = LongFormGlobalUtils.returnPaymentOptionsService('Netherlands');
            this.paymentOptionsService.setPagesMap('Mobile');
            this.stepPagesMap = this.paymentOptionsService.getPagesMap();
            this.paymentParameters = new Map<String, String>();
            this.cardsConfigService = LongFormGlobalUtils.returnCardsConfigService('Netherlands');
            this.cardsConfigService.setPagesMap('Mobile');
        }
    }


    /*******************************************************************************
    *  Name            : initSObjects(String opptyId)
    *  Summary         : init sobjects
    *  CreatedDate     : 15/08/2018
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
    *  CreatedDate     : 15/08/2018
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
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, 'Payment Gateway Service', this.activeSubstep, 'Return from a external service', 'Netherlands', 'Mobile');
        }
        deactivateInactiveServices();
    }


    /*******************************************************************************
    *  Name            : doPreFillingFieldsStep_0()
    *  Summary         : pre-filling of the nil step fields
    *  CreatedDate     : 15/08/2018
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
    *  CreatedDate     : 15/08/2018
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
        } else {
            E2E_Consumption_per_Card__c consumptionPerCard = E2E_Consumption_per_Card__c.getInstance(this.Account.BillingCountry);
            if (consumptionPerCard != null && consumptionPerCard.Consumption__c != null && opportunity.Anzahl_der_Karten__c != null) {
                this.stepPagesMap.get('CREDIT SCORE. TOTAL CONSUMPTION').fields.get('TOTAL CONSUMPTION').elementItemsMap.get('DEFAULT VALUE').Value__c = String.valueOf(Integer.valueOf(consumptionPerCard.Consumption__c) * opportunity.Anzahl_der_Karten__c);
            }                  
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
                this.creditScoringService.setUnavailableOptions(this.cfDecision.verdict, this.cfDecision.statusCode);
                this.unavailableOptions = this.creditScoringService.getUnavailableOptions();
                if (this.unavailableOptions == 'Bank Transfer' || this.unavailableOptions == 'Bank Transfer & Inbound Typ C') {
                    this.stepPagesMap.get('CREDIT SCORE. SCORING RESULT').fields.get('PAYMENT METHOD').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Lastschrift';
                }
            }  else {
                this.creditScoringService.resetOpportunityToStep('Search company');
                activateNewStep(this.opportunity.Id);
            }
        }
    }


    /*******************************************************************************
    *  Name            : doPreFillingFieldsStep_2()
    *  Summary         : pre-filling of the second step fields
    *  CreatedDate     : 15/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doPreFillingFieldsStep_2() {
        this.cardsConfigService.setCardParamsMobile();
        this.numberOfCards = this.cardsConfigService.getNumberOfCards();
        this.cardsConfigService.setCreditReport();
        this.selectedCompany = this.cardsConfigService.getCreditReport();
        this.unavailableOptions = this.cardsConfigService.getUnavailableOptions();
        this.cardsConfigService.setSpecialOffers('Mobile');
        this.homeOffersList = this.cardsConfigService.gethomeOffersList();
        this.nonHomeOffersList = this.cardsConfigService.getnonHomeOffersList();
        calculateFeesAndCosts();
        this.cardsConfigService.setUrlLocator();
        this.urlLocator = this.cardsConfigService.getUrlLocator();
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
    *  CreatedDate     : 15/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doPreFillingFieldsStep_3() {
        if (E2EKeysAPI__c.getValues('E2EFormNL') != null) {
            Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EFormNL').AES256_Key__c);
            // Terms And Conditions Of Vat-Recovery Program
            this.stepPagesMap.get('ADDITIONAL').elements.get('ADDITIONAL SERVICE #2').get('TC IFRAME URL').Value__c = '/apex/E2EAdditionalDocuments?hash=' +
                    E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=vatRecoveryTC&' + 'opportunityID=' + String.valueOf(this.opportunity.Id)+'&');
        }
        this.cardsConfigService.setCardParamsMobile();
        this.finalCardsMap = this.cardsConfigService.getFinalOrderCardsMap();
        this.numberOfCards = cardsConfigService.getNumberOfCards();
        this.cardsConfigService.setCreditReport();
        this.selectedCompany = this.cardsConfigService.getCreditReport();
        this.cardsConfigService.setSpecialOffers('Mobile');
        this.homeOffersList = this.cardsConfigService.gethomeOffersList();
        this.nonHomeOffersList = this.cardsConfigService.getnonHomeOffersList();
        calculateFeesAndCosts();
        if (! opportunity.Eco_Fee__c) this.stepPagesMap.get('ADDITIONAL').fields.get('CO2 TAKE CARE').elementItemsMap.get('VALUE').Value__c = String.valueOf(opportunity.Eco_Fee__c);
        this.stepPagesMap.get('ADDITIONAL').elements.get('ADDITIONAL SERVICE #2').get('VAT AGREEMENT CHECKBOX VALUE').Value__c = String.valueOf(this.opportunity.VAT_Recovery__c);
        this.stepPagesMap.get('ADDITIONAL').elements.get('ADDITIONAL SERVICE #2').get('VAT TC AGREEMENT CHECKBOX VALUE').Value__c = String.valueOf(this.opportunity.Agree_to_VAT_Recovery_TC__c);
        this.chatService.setOpportunity(this.opportunity);
        this.chatService.setContact(this.contact);
        prepareOnlineChat();
    }


    /*******************************************************************************
    *  Name            : doPreFillingFieldsStep_4()
    *  Summary         : pre-filling of the fourth step fields
    *  CreatedDate     : 15/08/2018
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
            this.homeOffersList = this.cardsConfigService.gethomeOffersList();
            this.nonHomeOffersList = this.cardsConfigService.getnonHomeOffersList();
            calculateFeesAndCosts();
            if (opportunity.Security_Amount_To_Pay__c != null && this.paymentStatus == null) {
                this.paymentOptionsService.prepareTransaction('Mobile');
                // this.selectedPaymentMethod = this.stepPagesMap.get('PAYMENT OPTIONS').fields.get('PaymentMethod Cards').options.get(0).getValue();
                this.selectedPaymentMethod = this.stepPagesMap.get('PAYMENT OPTIONS').fields.get('PaymentMethod Online Bank').options.get(0).getValue();
                changePaymentMethod(); // pre-filling payment method (init data)
            }
            if (E2EKeysAPI__c.getValues('E2EFormNL') != null) {
                Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EFormNL').AES256_Key__c);
                // SEPA
                this.stepPagesMap.get('PAYMENT OPTIONS').elements.get('DD SEPA').get('IFRAME URL').Value__c = '/apex/E2EAdditionalDocuments?hash=' +
                        E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=SEPAMandate&' + 'opportunityID=' + String.valueOf(opportunity.ID) + '&' +
                            'dynamicAccHolder=' + this.contact.FirstName + ' ' + this.contact.LastName + '&');
                this.stepPagesMap.get('PAYMENT OPTIONS').elements.get('DD SEPA').get('DOWNLOAD URL').Value__c = '/apex/E2EAdditionalDocuments?hash=' +
                        E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=SEPAMandate&' + 'opportunityID=' + String.valueOf(opportunity.ID) +'&pdfDownload=TRUE&');

                // TC
                this.stepPagesMap.get('PAYMENT OPTIONS').fields.get('ACCEPT TERM CONDITIONS').elementItemsMap.get('IFRAME URL').Value__c = '/apex/E2EAdditionalDocuments?hash=' +
                        E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=TermConditionsNL&');
                this.stepPagesMap.get('PAYMENT OPTIONS').fields.get('ACCEPT TERM CONDITIONS').elementItemsMap.get('DOWNLOAD URL').Value__c = '/apex/E2EAdditionalDocuments?hash=' +
                        E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=TermConditionsNL&pdfDownload=TRUE&');

                // Deposit Agreement
                this.stepPagesMap.get('PAYMENT OPTIONS').fields.get('DEPOSIT AGREEMENT').elementItemsMap.get('IFRAME URL').Value__c = '/apex/E2EAdditionalDocuments?hash=' +
                        E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=DepositAgreementNL&' + 'opportunityID=' + String.valueOf(opportunity.ID)+'&');
                this.stepPagesMap.get('PAYMENT OPTIONS').fields.get('DEPOSIT AGREEMENT').elementItemsMap.get('DOWNLOAD URL').Value__c = '/apex/E2EAdditionalDocuments?hash=' +
                        E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=DepositAgreementNL&' + 'opportunityID=' + String.valueOf(opportunity.ID) +'&pdfDownload=TRUE&');
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
    *  CreatedDate     : 11/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doPreFillingFieldsStep_5() {
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
    *  Name            : activateNewStep(String opptyId)
    *  Summary         : restarts active step
    *  CreatedDate     : 15/08/2018
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
        0.1 Get started substep
    */
    /*******************************************************************************
    *  Name            : getStarted()
    *  Summary         : go to 'Contact details' substep
    *  CreatedDate     : 15/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void getStarted() {
        this.activeSubstep = 'Contact details';
    }


    /*
        0.2 Contact details substep
    */
    /*******************************************************************************
    *  Name            : goToCompanyDetails()
    *  Summary         : save data and go to "Company details" step
    *  CreatedDate     : 20/08/2018
    *  ModifiedDate    : -
    *  Parameters      : 14/07/2018
    *  Returns         : PageReference
    ******************************************************************************/
    public PageReference goToCompanyDetails() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            this.startApexCall = Datetime.now();
            doDisabledTriggers();
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
                                    url = '/e2eFormmobnl?source=';
                                } else {
                                    url = '/apex/e2eFormmobnl?source=';
                                }
                                PageReference reference = new PageReference(url + contactRole.Opportunity.E2E_Encoded_URL__c);
                                reference.setRedirect(true);
                                if (this.opportunity != null) {
                                    LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'Netherlands', 'Mobile');
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
                                    url = '/e2eFormmobnl?source=';
                                } else {
                                    url = '/apex/e2eformmobnl?source=';
                                }
                                PageReference reference = new PageReference(url + contactRole.Opportunity.E2E_Encoded_URL__c);
                                reference.setRedirect(true);
                                this.endApexCall = Datetime.now();
                                LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, contactRole.Opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'Netherlands', 'Mobile');
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
                activateNewStep(this.opportunity.Id);
            }
            deactivateInactiveServices();
            this.chatService.setOpportunity(opportunity);
            this.chatService.setContact(contact);
            prepareOnlineChat();
            if (formOfBusiness == 'Solo-trader') {
                this.stepPagesMap.get('CREDIT SCORE. SEARCH COMPANY').fields.get('COMPANY NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = this.contact.Name;
            }
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'Netherlands', 'Mobile');
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


    /*
        1. Credit score step
        1.1 Search company substep
    */
    /*******************************************************************************
    *  Name            : doSaveCompanyDetailsData()
    *  Summary         : do save company details data
    *  CreatedDate     : 20/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doSaveCompanyDetailsData() {
        try {
            this.startApexCall = Datetime.now();
            doDisabledTriggers();
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
    *  CreatedDate     : 20/08/2018
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
            doDisabledTriggers();
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
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, 'This is a company search process.', 'Netherlands', 'Mobile');
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
    *  CreatedDate     : 21/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void goToSetTotalConsumption() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            doDisabledTriggers();
            this.activeInnerPage = '';
            this.activeStep = 1;
            this.activeSubStep = 'Set total consumption';
            // check if we have more than two paid reports
            if (this.opportunity.E2E_CF_Reports_Counter__c > 2) {
                this.activeInnerPage = null;
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
                E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubStep, null);
                return;
            }
            this.creditScoringService.doUpdateSFobjects(this.cfReportResponse);
            this.creditScoringService.setResultOfCheckBlackList();
            E2E_Form_General_Settings__c settings = E2E_Form_General_Settings__c.getInstance('Netherlands');
            if (settings.Enable_authorization_non_granted_check__c) {
                Boolean isAuthorizatedGranted = this.creditScoringService.getResultOfCheckAuthorizatedGranted();
                Boolean isNotAtBlackList = this.creditScoringService.getResultOfCheckBlackList();
                if (! isAuthorizatedGranted || ! isNotAtBlackList) {
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
            } else {
                E2E_Consumption_per_Card__c consumptionPerCard = E2E_Consumption_per_Card__c.getInstance(this.Account.BillingCountry);
                if (consumptionPerCard != null && consumptionPerCard.Consumption__c != null && opportunity.Anzahl_der_Karten__c != null) {
                    this.stepPagesMap.get('CREDIT SCORE. TOTAL CONSUMPTION').fields.get('TOTAL CONSUMPTION').elementItemsMap.get('DEFAULT VALUE').Value__c = String.valueOf(Integer.valueOf(consumptionPerCard.Consumption__c) * opportunity.Anzahl_der_Karten__c);
                }                  
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
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'Netherlands', 'Mobile');
        } catch (Exception e) {
            initSObjects(opportunity.Id);
            this.activeInnerPage = null;
            if (e.getMessage() == E2EExceptionUtils.errorsMap.get('Report does not exist')) {
                this.activeStep = 1;
                this.activeSubStep = 'Report does not exist';
                E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            } else {
                this.activeSubstep = 'System error';
                E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
                E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'goToSetTotalConsumption()', e);
            }
        }
    }


    /*******************************************************************************
    *  Name            : deleteReportsForPreviousCompany()
    *  Summary         : Delete all credit factory reports if user selects new company     
    *  CreatedDate     : 25/12/2018
    *  Parameters      : 
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
    *  Name            : updateVatNumberAndGoToSetTotalConsumptionStep()
    *  Summary         : update VAT number if and go to "Set total consumption" step
    *  CreatedDate     : 25/12/2018
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
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'Netherlands', 'Mobile');
        } catch (Exception e) {
            this.activeSubStep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'updateVatNumber()', e);
        }
    }


    /*
        1.2 Set total consumption substep
    */
    /*******************************************************************************
    *  Name            : doCalculateCreditScoring()
    *  Summary         : calculating credit scoring
    *  CreatedDate     : 20/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doCalculateCreditScoring() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            this.startApexCall = Datetime.now();
            doDisabledTriggers();
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
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'Netherlands', 'Mobile');
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
    *  Name            : setCreditScoreParameters()
    *  Summary         : set credit score parameters
    *  CreatedDate     : 15/08/2018
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


    /*
        1.3 Calculating credit score substep
    */
    /*******************************************************************************
    *  Name            : changeBillingPeriod()
    *  Summary         : do change billing period when click button
    *  CreatedDate     : 20/08/2018
    *  ModifiedDate    : 22/12/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void changeBillingPeriod() {
        returnFinalCreditScoreData();
        this.creditScoringService.resetCfDecision(this.defaultBillingPeriod, null, this.deposit, this.selectedCompany.classRating, this.selectedCompany);
        this.cfDecision = this.creditScoringService.getCfDecision();
        creditScoringService.setUnavailableOptions(this.cfDecision.verdict, this.cfDecision.statusCode);
        this.unavailableOptions = this.creditScoringService.getUnavailableOptions();
        if (this.unavailableOptions == 'Bank Transfer' || this.unavailableOptions == 'Bank Transfer & Inbound Typ C') {
            this.stepPagesMap.get('CREDIT SCORE. SCORING RESULT').fields.get('PAYMENT METHOD').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Lastschrift';
        }
    }


    /*******************************************************************************
    *  Name            : returnFinalCreditScoreData()
    *  Summary         : return final of credit score data
    *  CreatedDate     : 20/08/2018
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


    /*******************************************************************************
    *  Name            : doRecalculateDeposit()
    *  Summary         : recalculate deposit
    *  CreatedDate     : 20/08/2018
    *  ModifiedDate    : 22/12/2018
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
            this.creditScoringService.setUnavailableOptions(this.cfDecision.verdict, this.cfDecision.statusCode);
            this.unavailableOptions = this.creditScoringService.getUnavailableOptions();
        } catch(Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'doRecalculateDeposit()', e);
        }
    }


    /*******************************************************************************
    *  Name            : goToCardsConfig()
    *  Summary         : go to long form step 2
    *  CreatedDate     : 20/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void goToCardsConfig() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            this.startApexCall = Datetime.now();
            doDisabledTriggers();
            this.activeStep = 2;
            this.activeSubStep = 'Card configuration';
            this.creditScoringService.saveCreditScoringResult(this.defaultBillingPeriod, null, this.creditLimit, this.deposit);
            activateNewStep(this.opportunity.Id);
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'Netherlands', 'Mobile');
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'goToCardsConfig()', e);
        }
    }


    /*
        2. Card configuration step
        2.1 Card configuration substep
    */
    /*******************************************************************************
    *  Name            : goToEmbossing()
    *  Summary         : go to "Embossing" tab of "Card configuration" step
    *  CreatedDate     : 21/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void goToEmbossing() {
        this.activeInnerPage = '';
        this.cardsConfigService.setContinueButtonStatusMobile(this.activeStep, this.activeSubStep);
        this.continueButtonStatus = this.cardsConfigService.getContinueButtonStatusMobile();
    }


    /*******************************************************************************
    *  Name            : changeNumberOfCards()
    *  Summary         : change total number of cards
    *  CreatedDate     : 30/08/2018
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
            if (e.getMessage() == 'Remove extra cards') {
                this.activeInnerPage = 'Remove extra cards';
            } else if (e.getMessage() == 'No more 2 cards') {
                this.activeInnerPage = 'No more 2 cards error';
            } else {
                this.activeSubstep = 'System error';
                E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
                E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'changeNumberOfCards()', e);
            }
        }
    }


    /*******************************************************************************
    *  Name            : editCompanyName()
    *  Summary         : edit company name
    *  CreatedDate     : 21/08/2018
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
    *  Name            : saveCard()
    *  Summary         : save technical params for single card
    *  CreatedDate     : 21/08/2018
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
    *  CreatedDate     : 21/08/2018
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
    *  CreatedDate     : 21/08/2018
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
    *  Name            : goToFeesAndCosts()
    *  Summary         : go to "Fees and Costs" substep of "Card configuration" step
    *  CreatedDate     : 21/08/2018
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
    *  Name            : calculateFeesAndCosts()
    *  Summary         : calculate fees and costs for selected cards
    *  CreatedDate     : 20/08/2018
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
    *  Name            : saveConfiguration()
    *  Summary         : saving all selected cards
    *  CreatedDate     : 21/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void goToSpecialOffers() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            this.startApexCall = Datetime.now();
            doDisabledTriggers();
            this.activeInnerPage = '';
            this.activeStep = 2;
            this.activeSubStep = 'Choosing offer';
            this.cardsConfigService.saveCardsConfigResultMobile(this.activeSubStep);
            this.finalCardsMap = this.cardsConfigService.getFinalOrderCardsMap();
            this.cardsConfigService.setSpecialOffers('Mobile');
            this.homeOffersList = this.cardsConfigService.gethomeOffersList();
            this.nonHomeOffersList = this.cardsConfigService.getnonHomeOffersList();
            if (this.urlLocator == null) {
                this.cardsConfigService.setUrlLocator();
                this.urlLocator = this.cardsConfigService.getUrlLocator();
            }
            this.activeStep = 2;
            this.activeSubStep = 'Choosing offer';
            this.cardsConfigService.setContinueButtonStatusMobile(this.activeStep, this.activeSubStep);
            this.continueButtonStatus = this.cardsConfigService.getContinueButtonStatusMobile();
            prepareOnlineChat();
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'Netherlands', 'Mobile');
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'goToSpecialOffers()', e);
        }
    }



    /*
        2.2 Choosing offer substep
    */
    /*******************************************************************************
    *  Name            : chooseStation()
    *  Summary         : open locator to select station point
    *  CreatedDate     : 21/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void chooseStation() {
        try {
            this.activeInnerPage = 'Locator';
            String offerName = ApexPages.CurrentPage().getParameters().get('offerName');
            this.cardsConfigService.chooseStation(offerName);
            this.homeOffersList = this.cardsConfigService.gethomeOffersList();
            this.nonHomeOffersList = this.cardsConfigService.getnonHomeOffersList();
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'chooseStation()', e);
        }
    }


    /*******************************************************************************
    *  Name            : returnStation()
    *  Summary         : return station data for selected station point
    *  CreatedDate     : 21/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void returnStation() {
        try {
            for (LongFormSpecialOffer offer : this.homeOffersList) {
                if (offer.homeMapSelectionBtnStatus == 'hide') {
                    offer.offerSelectionBtnStatus = 'show-enabled';
                }
            }
            E2ELocatorStation station = (E2ELocatorStation)JSON.deserialize(jsonStation, E2ELocatorStation.class);
            this.opportunity.Home_Station__c = station.address + ' ' + station.countryName;
            this.opportunity.ESI__c = station.stationId;
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'returnStation()', e);
        }
    }


    /*******************************************************************************
    *  Name            : selectOffer()
    *  Summary         : set selected offer
    *  CreatedDate     : 21/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void selectOffer() {
        try {
            this.activeInnerPage = '';
            String offerName = ApexPages.CurrentPage().getParameters().get('offerName');
            this.cardsConfigService.selectOffer(offerName);
            this.homeOffersList = this.cardsConfigService.gethomeOffersList();
            this.nonHomeOffersList = this.cardsConfigService.getnonHomeOffersList();
            this.cardsConfigService.setContinueButtonStatusMobile(this.activeStep, this.activeSubStep);
            this.continueButtonStatus = this.cardsConfigService.getContinueButtonStatusMobile();
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'selectOffer()', e);
        }
    }


    /*******************************************************************************
    *  Name            : removeOffer()
    *  Summary         : remove selected offer
    *  CreatedDate     : 21/08/2018
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
            this.cardsConfigService.setContinueButtonStatusMobile(this.activeStep, this.activeSubStep);
            this.continueButtonStatus = this.cardsConfigService.getContinueButtonStatusMobile();
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'removeOffer()', e);
        }
    }


    /*******************************************************************************
    *  Name            : goToAdditionalParams()
    *  Summary         : go to "Additional" step
    *  CreatedDate     : 21/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void goToAdditionalParams() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            this.startApexCall = Datetime.now();
            doDisabledTriggers();
            this.cardsConfigService.saveSpecialOfferMobile();
            this.activeInnerPage = '';
            this.activeStep = 3;
            this.activeSubStep = 'Additional services';
            activateNewStep(this.opportunity.Id);
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'Netherlands', 'Mobile');
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'goToAdditionalParams()', e);
        }
    }


    /*
        3. Additional services step
    */

    /*
        4. Payment options step
        4.1 Direct Debit substep
    */
    /*******************************************************************************
    *  Name            : goToPaymentOptions()
    *  Summary         : Save CO2 if it exists and go to payments options (STEP 4)
    *  CreatedDate     : 30/08/2018
    *  ModifiedDate    :
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public PageReference goToPaymentOptions() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            this.startApexCall = Datetime.now();
            doDisabledTriggers();
            this.activeInnerPage = '';
            Boolean vatRecoveryProgramAgree = Boolean.valueOf(this.stepPagesMap.get('ADDITIONAL').elements.get('ADDITIONAL SERVICE #2').get('VAT AGREEMENT CHECKBOX VALUE').Value__c);
            Boolean vatRecoveryTermsAndCondAgree = Boolean.valueOf(this.stepPagesMap.get('ADDITIONAL').elements.get('ADDITIONAL SERVICE #2').get('VAT TC AGREEMENT CHECKBOX VALUE').Value__c);
            if ((vatRecoveryProgramAgree && ! vatRecoveryTermsAndCondAgree) ||
                (! vatRecoveryProgramAgree && vatRecoveryTermsAndCondAgree)) {
                throw new LongFormException('Please agree to all terms and conditions of the VAT-Recovery program.');
            } else if (vatRecoveryProgramAgree && vatRecoveryProgramAgree) {
                if (isInternationalSoloTrader()) return null;
            }
            this.activeStep = 4;
            this.additionalService.updateRecords();
            activateNewStep(this.opportunity.Id);
            this.activeSubStep = this.opportunity.E2E_Active_Substep__c;
            PageReference paymentPage = new PageReference('/apex/e2eformmobnl?source=' + this.opportunity.E2E_Encoded_URL__c);
            paymentPage.setRedirect(true);
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'Netherlands', 'Mobile');
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
    *  Name            : showTermsAndConditionsVatRecoveryModal()
    *  Summary         : show "Terms And Conditions Of Vat-Recovery Program" modal window
    *  CreatedDate     : 01/03/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void showTermsAndConditionsVatRecoveryModal() {
        this.activeInnerPage = 'Modal Vat-Recovery Program TC';
    }


    /*******************************************************************************
    *  Name            : continueToPaymentOptionsFromDob()
    *  Summary         : go to "Payment Options" step from DOB
    *  CreatedDate     : 06/03/2019
    *  ModifiedDate    :
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public PageReference continueToPaymentOptionsFromDob() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            this.startApexCall = Datetime.now();
            doDisabledTriggers();
            if ( ! isDobValid() ) throw new LongFormException('Date of birth is not valid.');
            this.activeStep = 4;
            this.additionalService.updateRecords();
            activateNewStep(this.opportunity.Id);
            this.activeSubStep = this.opportunity.E2E_Active_Substep__c;
            PageReference paymentPage = new PageReference('/apex/e2eformmobnl?&source=' + this.opportunity.E2E_Encoded_URL__c);
            paymentPage.setRedirect(true);
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'Netherlands', 'Mobile');
            return paymentPage;
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'continueToPaymentOptionsFromDob()', e);
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : isInternationalSoloTrader()
    *  Summary         : Display DOB field for international Solo-trader
    *  CreatedDate     : 06/03/2019
    *  ModifiedDate    :
    *  Parameters      : Boolean
    *  Returns         : void
    ******************************************************************************/
    private Boolean isInternationalSoloTrader() {
        // check if solo-trader customer would like to take part in International VAT-Recovery Program
        this.activeInnerPage = '';
        if (this.showInternationalFeesBlock && 
            this.contact.Birthdate == null && 
            (this.opportunity.E2E_Form_of_Business__c == 'Solo-trader' || soloTradersLegalFormsSet.contains(this.account.Gesellschaftsform__c)) ) {
            String currentActiveSubstep = this.activeSubstep;
            // Display date of birth for International Solo-trader
            this.activeStep = 3;
            this.activeSubStep = 'Enter Date of Birth';
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'Netherlands', 'Mobile');
            return true;
        }
        return false;
    }


    private static Set<String> soloTradersLegalFormsSet = new Set<String> {
        'e.K', // e.K.
        'ENTREPRISE INDIVIDUELLE', // INDIVIDUAL ENTREPRISE
        'Private limited company',
        'Einzelfirma', // Single company
        'Single person company confirmed',
        'Eenmanszaak' // Sole proprietorship
    };


    /*******************************************************************************
    *  Name            : isDobValid()
    *  Summary         : Validate DOB on format
    *  CreatedDate     : 06/03/2019
    *  ModifiedDate    :
    *  Parameters      : Boolean
    *  Returns         : void
    ******************************************************************************/
    private Boolean isDobValid() {
        // Validate date of birth for International Solo-trader
        Boolean isDateOfBirthValid = LongFormGlobalUtils.validateDateOfBirth(this.stepPagesMap.get('ADDITIONAL. ENTER DATE OF BIRTH').fields.get('DATE OF BIRTH').elementItemsMap.get('DEFAULT VALUE').Value__c);
        return isDateOfBirthValid;
    }


    /*******************************************************************************
    *  Name            : doSavePaymentOptionsData()
    *  Summary         : do save payment options data and go to "thanks" page
    *  CreatedDate     : 11/09/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doSavePaymentOptionsData() {
        try {
            if (! this.showSwiftField) {
                String currentActiveSubstep = this.activeSubStep;
                this.startApexCall = Datetime.now();
                if (this.opportunity.Security_Amount_To_Pay__c != null) doDisabledTriggers();
                this.activeInnerPage = '';
                this.paymentOptionsService.validate(this.activeStep, this.activeSubStep);
                this.paymentOptionsService.savePaymentOptionsDataWithoutDeposit(this.activeSubStep);
                this.paymentOptionsService.setOpportunity(this.opportunity.Id);
                this.opportunity = this.paymentOptionsService.getOpportunity();
                this.activeStep = Integer.valueOf(this.opportunity.E2E_Active_Step__c);
                this.activeSubStep = this.opportunity.E2E_Active_Substep__c;
                this.endApexCall = Datetime.now();
                LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'Netherlands', 'Mobile');
            }
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'doSavePaymentOptionsData()', e);
        }
    }


    /*******************************************************************************
    *  Name            : jsValidateIBAN()
    *  Summary         : Validate IBAN on click CONTINUE button
    *  CreatedDate     : 11/09/2018
    *  ModifiedDate    :
    *  Parameters      : -
    *  Returns         : Boolean
    ******************************************************************************/
    public void jsValidateIBAN() {
        try {
            this.showSwiftField = false;
            this.isIBANValid = this.paymentOptionsService.jsValidateIBAN();
            if (this.isIBANValid) this.showSwiftField = this.paymentOptionsService.requestSwiftInfo();
        } catch (Exception e) {
            this.showSwiftField = true;
        }
    }


    /*
        4.2 Direct Debit Deposit substep
    */
    /*******************************************************************************
    *  Name            : changePaymentMethod()
    *  Summary         : set payment method
    *  CreatedDate     : 29/06/2018
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
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'changePaymentMethod()', e);
        }
    }


    /*******************************************************************************
    *  Name            : proceedToCheckout()
    *  Summary         : go to payment system
    *  CreatedDate     : 11/09/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void proceedToCheckout() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            this.startApexCall = Datetime.now();
            doDisabledTriggers();
            this.activeInnerPage = '';
            this.paymentOptionsService.validate(this.activeStep, this.activeSubStep);
            this.paymentOptionsService.saveTransactionData();
            this.paymentOptionsService.savePaymentOptionsDataWithDeposit(this.activeSubStep);
            this.paymentOptionsService.setOpportunity(this.opportunity.Id);
            this.opportunity = this.paymentOptionsService.getOpportunity();
            // this.activeStep = 5;
            // this.activeSubStep = 'Congratulations';
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, 'Payment Gateway Service', 'Transition to external service', 'Netherlands', 'Mobile');
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'proceedToCheckout()', e);
        }
    }


    /*
        5. Congratulations step
    */


    /*******************************************************************************
    *  Name            : showProgramDetails()
    *  Summary         : show program details on "Congratulations" step
    *  CreatedDate     : 04/06/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void showProgramDetails() {
        this.activeInnerPage = 'Program Details';
    }


    /*
        ORDER DETAILS BLOCK
    */
    /*******************************************************************************
    *  Name            : showSaveAndContinueLaterModal()
    *  Summary         : show save and continue later modal
    *  CreatedDate     : 20/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void showSaveAndContinueLaterModal() {
        this.activeInnerPage = 'Save and continue later';
    }


    /*******************************************************************************
    *  Name            : editContactDetails()
    *  Summary         : edit contact details
    *  CreatedDate     : 15/08/2018
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
            activateNewStep(this.opportunity.Id);
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'Netherlands', 'Mobile');
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'editContactDetails()', e);
        }
    }


    /*******************************************************************************
    *  Name            : editCompanyDetails()
    *  Summary         : edit company details
    *  CreatedDate     : 15/08/2018
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
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'Netherlands', 'Mobile');
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'editCompanyDetails()', e);
        }
    }


    /*******************************************************************************
    *  Name            : editCreditScoreData()
    *  Summary         : edit credit score data
    *  CreatedDate     : 15/08/2018
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
            activateNewStep(this.opportunity.Id);
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'Netherlands', 'Mobile');
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'editCreditScoreData()', e);
        }
    }


    /*******************************************************************************
    *  Name            : editCardConfiguration()
    *  Summary         : edit card configuration
    *  CreatedDate     : 15/08/2018
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
            activateNewStep(this.opportunity.Id);
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'Netherlands', 'Mobile');
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'editCardConfiguration()', e);
        }
    }


    /*******************************************************************************
    *  Name            : editSpecialOffers()
    *  Summary         : edit card configuration
    *  CreatedDate     : 15/08/2018
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
            activateNewStep(this.opportunity.Id);
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'Netherlands', 'Mobile');
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'editSpecialOffers()', e);
        }
    }


    /*******************************************************************************
    *  Name            : editDirectDebitPaymentOptions()
    *  Summary         : edit card configuration
    *  CreatedDate     : 15/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void editDirectDebitPaymentOptions() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            this.startApexCall = Datetime.now();
            this.activeStep = 4;
            this.activeSubStep = 'DirectDebit';
            activateNewStep(this.opportunity.Id);
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'Netherlands', 'Mobile');
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'editDirectDebitPaymentOptions()', e);
        }
    }


    /* SYSTEM METHODS */

    /*******************************************************************************
    *  Name            : closeModal()
    *  Summary         : close modal window
    *  CreatedDate     : 31/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void closeModal() {
        this.activeInnerPage = null;
    }


    /*******************************************************************************
    *  Name            : sendVatTcToEmail()
    *  Summary         : Send Vat recovery programm TC as attachment email to the user email
    *  CreatedDate     : 06/03/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void sendVatTcToEmail() {
        this.activeInnerPage = null;
        try {
            String fileName = 'vatRecoveryTC';
            String accountHolder = this.opportunity.Name_of_the_payer_Account_holder__c;
            Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EFormNL').AES256_Key__c);
            String pageRefString = '/apex/E2EAdditionalDocuments?hash=' +
                        E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=vatRecoveryTC&' + 'opportunityID=' + String.valueOf(opportunity.Id) + '&dynamicAccHolder=' + accountHolder + '&');
            PageReference sepaMandatePage = new PageReference(pageRefString);
            Blob pdfContent;
            if (Test.IsRunningTest()) pdfContent = Blob.valueOf('UNIT.TEST');
            else pdfContent = sepaMandatePage.getContentAsPDF();

            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName(fileName + '.pdf');
            attachment.setBody(pdfContent); 
            String htmlBody = '<p>' + LongFormGlobalUtils.returnSalutationDependLocation(this.account.BillingCountry, this.contact.Salutation) + 
                                this.contact.FirstName + ' ' + this.contact.LastName + '</p>' +
                                '<p>Hartelijk dank voor uw belangstelling voor Shell tankpassen.<br/>' + 
                                'Wij bevestigen dat u ons hebt verzocht documenten toe te sturen: algemene voorwaarden van het internationale btw-terugvorderingsprogramma.<br/>' +
                                'Desgewenst kunt u hier de documenten downloaden en opslaan voor uw administratie.</p>';
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String[] toAddresses = new List<string> {this.contact.Email};
            String subject = 'Shell tankpassen online bestellen.';
            email.setSubject(subject);
            email.setToAddresses(toAddresses);
            email.setHtmlBody(htmlBody);
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{attachment});
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'sendVatTcToEmail()', e);
        }
    }


    /*******************************************************************************
    *  Name            : showSendTCDocument()
    *  Summary         : Show Vat recovery programm TC Document window
    *  CreatedDate     : 06/03/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void showSendVatTcDocument() {
        this.activeInnerPage = 'Send Vat TC to email';
    }


    /*******************************************************************************
    *  Name            : showTermsAndConditions()
    *  Summary         : show term and conditions modal window
    *  CreatedDate     : 21/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void showTermsAndConditions() {
        this.activeInnerPage = 'Modal Term And Conditions';
    }


    /*******************************************************************************
    *  Name            : showSepaMandateModal()
    *  Summary         : show sepa mandate modal window
    *  CreatedDate     : 21/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void showSepaMandateModal() {
        this.activeInnerPage = 'Modal Sepa';
    }


    /*******************************************************************************
    *  Name            : showDepositAgreementModal()
    *  Summary         : show deposit agreement modal window
    *  CreatedDate     : 21/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void showDepositAgreementModal() {
        this.activeInnerPage = 'Modal Deposit Agreement';
    }


    /*******************************************************************************
    *  Name            : doSaveAndContinueLater()
    *  Summary         : do save and continue later
    *  CreatedDate     : 21/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doSaveAndContinueLater() {
        try {
            this.activeInnerPage = '';
            if (this.activeSubstep == 'Set total consumption' || this.activeSubstep == 'Calculating credit score') {
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
    *  Name            : sendSepaToEmail()
    *  Summary         : Send SEPA mandate as attachment email to the user email
    *  CreatedDate     : 21/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void sendSepaToEmail() {
        this.activeInnerPage = null;
        try {
            String fileName = 'SEPA-mandaat';
            String accountHolder = this.stepPagesMap.get('PAYMENT OPTIONS').fields.get('ACCOUNT HOLDER').elementItemsMap.get('VALUE').Value__c;
            Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EFormNL').AES256_Key__c);
            String pageRefString = '/apex/E2EAdditionalDocuments?hash=' +
                        E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=SEPAMandateNL&' + 'opportunityID=' + String.valueOf(opportunity.Id) + '&dynamicAccHolder=' + accountHolder + '&');
            PageReference sepaMandatePage = new PageReference(pageRefString);
            Blob pdfContent;
            if (Test.IsRunningTest()) pdfContent = Blob.valueOf('UNIT.TEST');
            else pdfContent = sepaMandatePage.getContentAsPDF();

            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName(fileName + '.pdf');
            attachment.setBody(pdfContent);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String[] toAddresses = new list<string> {this.contact.Email};
            String subject = 'Shell tankpassen online bestellen.';
            email.setSubject(subject);
            email.setToAddresses(toAddresses);
            email.setHtmlBody('<p>Wij bevestigen dat u ons hebt verzocht documenten toe te sturen: SEPA-mandaat. Desgewenst kunt u hier de documenten downloaden en opslaan voor uw administratie.</p>');
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{attachment});
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'sendSepaToEmail()', e);
            // Exception notification
            // sendExceptionEmail('sendSepaToEmail()', e);
        }
    }


    /*******************************************************************************
    *  Name            : showSendSepaDocument()
    *  Summary         : Show Send SEPA Document window
    *  CreatedDate     : 21/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void showSendSepaDocument() {
        this.activeInnerPage = 'Send SEPA to email';
    }


    /*******************************************************************************
    *  Name            : sendTcToEmail()
    *  Summary         : Send TC as attachment email to the user email
    *  CreatedDate     : 21/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void sendTcToEmail() {
        this.activeInnerPage = null;
        try {
            String fileName = 'Algemene Voorwaarden';
            String accountHolder = this.opportunity.Name_of_the_payer_Account_holder__c;
            Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EFormNL').AES256_Key__c);
            String pageRefString = '/apex/E2EAdditionalDocuments?hash=' +
                        E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=TermConditionsNL&' + 'opportunityID=' + String.valueOf(opportunity.Id) + '&dynamicAccHolder=' + accountHolder + '&');
            PageReference sepaMandatePage = new PageReference(pageRefString);
            Blob pdfContent;
            if (Test.IsRunningTest()) pdfContent = Blob.valueOf('UNIT.TEST');
            else pdfContent = sepaMandatePage.getContentAsPDF();

            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName(fileName + '.pdf');
            attachment.setBody(pdfContent);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String[] toAddresses = new list<string> {this.contact.Email};
            String subject = 'Shell tankpassen online bestellen.';
            email.setSubject(subject);
            email.setToAddresses(toAddresses);
            email.setHtmlBody('<p>Wij bevestigen dat u ons hebt verzocht documenten toe te sturen: Algemene Voorwaarden. Desgewenst kunt u hier de documenten downloaden en opslaan voor uw administratie.</p>');
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
    *  CreatedDate     : 21/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void showSendTcDocument() {
        this.activeInnerPage = 'Send TC to email';
    }


    /*******************************************************************************
    *  Name            : sendDepositAgreementToEmail()
    *  Summary         : Send Deposit Agreement as attachment email to the user email
    *  CreatedDate     : 21/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void sendDepositAgreementToEmail() {
        this.activeInnerPage = null;
        try {
            String fileName = 'Overeenkomst inzake de borgsom';
            String accountHolder = this.opportunity.Name_of_the_payer_Account_holder__c;
            Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EFormNL').AES256_Key__c);
            String pageRefString = '/apex/E2EAdditionalDocuments?hash=' +
                        E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=DepositAgreementNL&' + 'opportunityID=' + String.valueOf(opportunity.Id) + '&dynamicAccHolder=' + accountHolder + '&');
            PageReference kautionPage = new PageReference(pageRefString);
            Blob pdfContent;
            if (Test.IsRunningTest()) pdfContent = Blob.valueOf('UNIT.TEST');
            else pdfContent = kautionPage.getContentAsPDF();

            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName(fileName + '.pdf');
            attachment.setBody(pdfContent);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String[] toAddresses = new list<string> {this.contact.Email};
            String subject = 'Shell tankpassen online bestellen.';
            email.setSubject(subject);
            email.setToAddresses(toAddresses);
            email.setHtmlBody('<p>Wij bevestigen dat u ons hebt verzocht documenten toe te sturen: Overeenkomst inzake de borgsom. Desgewenst kunt u hier de documenten downloaden en opslaan voor uw administratie.</p>');
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
    *  CreatedDate     : 18/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void showSendDepositAgreementDocument() {
        this.activeInnerPage = 'Send Deposit Agreement to email';
    }


    /*******************************************************************************
    *  Name            : sendHowToPayToEmail()
    *  Summary         : Send How to Pay as attachment email to the user email
    *  CreatedDate     : 21/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void sendHowToPayToEmail() {
        this.activeInnerPage = null;
        try {
            String fileName = 'Betaling van de borgsom';
            String accountHolder = this.opportunity.Name_of_the_payer_Account_holder__c;
            Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EFormNL').AES256_Key__c);
            String pageRefString = '/apex/E2EAdditionalDocuments?hash=' +
                        E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=PaymentInformation&' + 'opportunityID=' + String.valueOf(opportunity.Id) + '&dynamicAccHolder=' + accountHolder + '&');
            PageReference kautionPage = new PageReference(pageRefString);
            Blob pdfContent;
            if (Test.IsRunningTest()) pdfContent = Blob.valueOf('UNIT.TEST');
            else pdfContent = kautionPage.getContentAsPDF();

            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName(fileName + '.pdf');
            attachment.setBody(pdfContent);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String[] toAddresses = new list<string> {this.contact.Email};
            String subject = 'Shell tankpassen online bestellen.';
            email.setSubject(subject);
            email.setToAddresses(toAddresses);
            email.setHtmlBody('<p>Wij bevestigen dat u ons hebt verzocht documenten toe te sturen: Betaling van de borgsom. Desgewenst kunt u hier de documenten downloaden en opslaan voor uw administratie.</p>');
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
    *  CreatedDate     : 21/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void showSendHowToPayDocument() {
        try {
            this.activeInnerPage = 'Send How to Pay to email';            
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'sendHowToPayToEmail()', e);
        }
    }


    /*******************************************************************************
    *  Name            : updateOpportunityOnReturnFromEmail()
    *  Summary         : update Opportunity fields on return from marketing email
    *  CreatedDate     : 15/08/2018
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


    /*****************************************************************************
    *  Name            : doDecryptParams(String encryptedParams)
    *  Summary         : do decrypt url params
    *  CreatedDate     : 15/08/2018
    *  ModifiedDate    : -
    *  Parameters      : String encryptedParams
    *  Returns         : void
    ******************************************************************************/
    private void doDecryptParams(String encryptedParams) {
        encryptedParams = encryptedParams.replaceAll('(\\s|%2B)', '+');
        if (E2EKeysAPI__c.getValues('E2EFormNL') == null ) throw new LongFormException('The link is corrupted.');
        Blob key = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EFormNL').AES256_Key__c);
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
    *  Name            : setFlagChatToOpportunity()
    *  Summary         : update opportunity chat flag
    *  CreatedDate     : 15/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @RemoteAction
    public static void setFlagChatToOpportunity(String oppId, String activeStep, String activeSubStep, String modeOfChat){
        if(modeOfChat != ''){
            LFChatService.setFlagChatToOpportunity(oppId, modeOfChat, Integer.valueof(activeStep), activeSubStep);
        }
    }


    /*******************************************************************************
    *  Name            : initChatSetup()
    *  Summary         : init chat setup
    *  CreatedDate     : 15/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void initChatSetup(){
        this.chatService = new LFChatService();
        this.chatService.setChatDefaultSettings('Netherlands');
        this.chatButtonId = this.chatService.chatButtonId;
        this.chatDeploymentId = this.chatService.chatDeploymentId;
        this.chatDeploymentJsURL = this.chatService.chatDeploymentJsURL;
        this.chatURL = this.chatService.chatURL;

        this.chatService.setPageMap('Netherlands');
        this.pageMapChat = chatService.getPagesMap();
    }


    /*******************************************************************************
    *  Name            : saveOfflineChatLog()
    *  Summary         : update offline chat
    *  CreatedDate     : 15/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @RemoteAction
    public static void saveOfflineChatLog(String oppId, String conId, String activeStep, String activeSubStep,  String textBody){
        LFChatService.saveOfflineChatLog(textBody, '', Integer.valueof(activeStep), activeSubStep, 'Netherlands', oppId, conId);
    }


    /*******************************************************************************
    *  Name            : prepareOnlineChat()
    *  Summary         : prepare online chat
    *  CreatedDate     : 15/08/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void prepareOnlineChat(){
        String clientNameToChat = '';
        if (this.contact != null) {
            if (this.contact.Salutation == 'Frau'){
                clientNameToChat = ' ' + 'Mevrouw' + ' ' + this.contact.LastName;
            } else {
                clientNameToChat = ' ' + 'Heer' + ' ' + this.contact.LastName;
            }
        }
        this.chatFirstMessage = this.chatService.getFirstChatMessage('Netherlands', this.activeStep, this.activeSubStep, clientNameToChat);
    }


    /******************************************************************************
    *  Name            : doDisabledTriggers()
    *  Summary         : disabling SF triggers    
    *  CreatedDate     : 01/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void doDisabledTriggers() {
        AccountTriggerHandler.enablesTrigger = false;
        ContactTriggerHandler.enablesTrigger = false;
        OpportunityTriggerHandler.enablesTrigger = false;
        OpportunityTriggerHandler.isE2EForm = true;
    }


    /*******************************************************************************
    *  Name            : deactivateInactiveServices()
    *  Summary         : deactivate inactive e2e services when changing to another step (Reset Viewstate)
    *  CreatedDate     : 11/09/2018
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
            this.selectedCompany = null;
            // 2 step
            this.cardsConfigService = null;
            this.homeOffersList = null;
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
            this.homeOffersList = null;
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
            this.foundCompaniesList = null;
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
            // 3 step
            this.additionalService = null;
        }
    }


    /*******************************************************************************
    *  Name            : getTransactionParameters()
    *  Summary         : return transaction parameters
    *  CreatedDate     : 29/06/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void getTransactionParameters() {
        if (E2EKeysAPI__c.getValues('E2EFormNL') != null) {
            this.paymentURL = E2EKeysAPI__c.getValues('E2EFormNL').paymentTransactionURL__c;
            this.paymentParameters = this.paymentOptionsService.getPaymentMap();
        }
    }
}