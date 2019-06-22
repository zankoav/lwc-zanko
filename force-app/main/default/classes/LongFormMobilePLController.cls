global class LongFormMobilePLController {
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
    public Integer defaultBillingPeriod {get; set;}
    public Integer defaultPaymentTerms {get; set;}

    // Docusign
    private LFDocusign docusignService;
    
    public Decimal creditLimit {get; set;}
    public Decimal minCreditLimit {get; set;}
    public Decimal creditLimit15_Plus14 {get; set;}
    public Decimal creditLimit7_Plus7 {get; set;}
    public Decimal maxCreditLimit {get; set;}
    private Decimal maxCreditLimit15_Plus14;
    private Decimal maxCreditLimit7_Plus7;
    public Decimal maxValue {get; set;}
    private Decimal maxValue15_Plus14;
    private Decimal maxValue7_Plus7;
    public Decimal deposit {get; set;}
    private Decimal deposit15_Plus14;
    private Decimal deposit7_Plus7;
    private CreditFactoryDecision cfDecision;
    // Card configuration
    private LFCardsConfig cardsConfigService;
    public Integer numberOfCards {get; set;}
    public Map<Integer, LongFormCard> finalCardsMap {get; set;}
    public Map<String, List<LongFormCostItem>> costsColumnsMap {get; set;}
    public Boolean showInternationalFeesBlock {get; set;}
    public List<LongFormSpecialOffer> nonHomeOffersList {get; set;}
    public Boolean isVatIdValid {get; set;}
    // public String jsonStation {get; set;}
    public String urlLocator {get; set;}
    // Additional
    private LFAdditional additionalService;
    // Documents
    private LFDocuments documentsService;
    // Payment Options
    private LFPaymentOptions paymentOptionsService;
    public String paymentStatus {get; set;}
    public String selectedPaymentMethod {get; set;}
    public String paymentURL {get; set;}
    public Map<String, String> paymentParameters {get; set;}
    // public Boolean isIBANValid {get; set;}

    // Tablet
    public Boolean isTablet {get; set;}     

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
    *  CreatedDate     : 16/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : PageReference – possible redirect to the desktop
    ******************************************************************************/
    public PageReference init() {
        try {
            // is Station Tablet
            this.isTablet = false;
            String stationTablet = ApexPages.CurrentPage().getParameters().get('tablet');
            if (stationTablet != null) isTablet = true;
            
            this.activeStep = 0;
            String encryptedParams = ApexPages.CurrentPage().getParameters().get('source');
            if (encryptedParams != null && encryptedParams != '') doDecryptParams(encryptedParams);
            //menu
            LFMenu menuService = LongFormGlobalUtils.returnMenuService('Poland');
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
                if (this.activeStep == 1 || this.activeStep == 3) {
                    checkEnvelopeStatus();
                }
            }
            // check case for special offers
            checkFormStage();
            if (this.activeSubstep == null) this.activeSubstep = 'Get started';
            return null;
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            if (this.stepPagesMap == null) this.stepPagesMap = new Map<String, LongFormPage>();
            this.stepPagesMap.putAll(LongFormGlobalUtils.returnErrorPage('Poland', 'Mobile'));
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
            return new PageReference('/e2eformhu');
        }

        return null;
    }     


    /*******************************************************************************
    *  Name            : redirectToDesktop(String encodedId)
    *  Summary         : If device is desktop then redirect to the desktop version
    *  CreatedDate     : 16/10/2018
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
                url = new PageReference('/e2eformpl');
            } else {
                url = new PageReference('/apex/e2eformpl');
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
    *  CreatedDate     : 16/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void checkFormStage() {
        // UNCOMMENT LATER

        // if (this.opportunity.E2E_Active_Substep__c == 'Choosing offer' && this.finalCardsMap != null) {
        //     Boolean isReturnToCardConfig = false;
        //     for (LongFormCard card : this.finalCardsMap.values()) {
        //         if ((card.driverNameOrCarNumberInputValue == null || card.driverNameOrCarNumberInputValue == '')) {
        //             isReturnToCardConfig = true;
        //             break;
        //         }
        //     }
        //     if (isReturnToCardConfig) {
        //         this.activeSubstep = 'Card configuration';
        //         this.cardsConfigService.setContinueButtonStatusMobile(this.activeStep, this.activeSubStep);
        //         this.continueButtonStatus = this.cardsConfigService.getContinueButtonStatusMobile();
        //     }
        // }
        if (this.opportunity.StageName == 'Closed Won' && this.opportunity.E2E_Active_Substep__c != 'Congratulations') this.activeSubstep = 'Stop order';

        // TEMP BLOCK DUE TO "SPECIAL OFFER" STEP REMOVAL (MUST BE REMOVED)
        // ================================================================
        if (this.opportunity.E2E_Active_Substep__c == 'Choosing offer') {
            this.activeSubstep = 'Card configuration';
            this.cardsConfigService.setContinueButtonStatusMobile(this.activeStep, this.activeSubStep);
            this.continueButtonStatus = this.cardsConfigService.getContinueButtonStatusMobile();
        }
        // ================================================================
    }


    /*******************************************************************************
    *  Name            : checkEnvelopeStatus()
    *  Summary         : check envelope status when you return from docusign
    *  CreatedDate     : 06/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void checkEnvelopeStatus() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            this.startApexCall = Datetime.now();
            doDisabledTriggers();
            String event = ApexPages.CurrentPage().getParameters().get('event');
            if (event == 'OnSigningComplete' || event == 'OnViewingComplete') {
                if (this.activeStep == 1) {
                    this.activeSubStep = 'Too high limit. Additional Credit Scoring Allowance';
                    E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, null);
                }
                if (this.activeStep == 3) {
                    if (this.opportunity.Security_To_Pay__c == 'Kaution') {
                        this.documentsService.goToPaymentOptions();
                    } else {
                        this.documentsService.goToCongratulations();
                    }
                    this.opportunity = this.documentsService.getOpportunity();
                    this.activeStep = Integer.valueOf(this.opportunity.E2E_Active_Step__c);
                    this.activeSubStep = this.opportunity.E2E_Active_Substep__c;
                    activateNewStep(this.opportunity.Id);
                }
                this.endApexCall = Datetime.now();
                LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, 'Return From Docusign', 'Poland', 'Mobile');
            }
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'checkEnvelopeStatus()', e);
        }
    }


    /*******************************************************************************
    *  Name            : initPageElements()
    *  Summary         : do activate specific step
    *  CreatedDate     : 16/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void initPageElements() {
        if (this.activeStep == 0) {
            // zero step elements
            this.contactDetailsService = LongFormGlobalUtils.returnContactDetailsService('Poland');
            this.contactDetailsService.setPagesMap('Mobile');
            this.docusignService = LongFormGlobalUtils.returnDocusignService('Poland');
            this.stepPagesMap = this.contactDetailsService.getPagesMap();
            if (E2EKeysAPI__c.getValues('E2EFormPL') != null) {
                Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EFormPL').AES256_Key__c);
                // Agree to telephone contact
                this.stepPagesMap.get('CONTACT DETAILS').fields.get('PHONE CONTACT AGREEMENT').elementItemsMap.get('IFRAME URL').Value__c = '/apex/E2EAdditionalDocuments?hash=' +
                        E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=agreeToTelephoneContactPL&');

                // Agree to receive comm info by email
                this.stepPagesMap.get('CONTACT DETAILS').fields.get('RECEIVE COMM INFO BY EMAIL AGREEMENT').elementItemsMap.get('IFRAME URL').Value__c = '/apex/E2EAdditionalDocuments?hash=' +
                        E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=agreeToReceiveCommInfoByEmailPL&');

                // Agree to process pers data for marketing
                this.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('IFRAME URL').Value__c = '/apex/E2EAdditionalDocuments?hash=' +
                        E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=agreeToReceiveNewsPL&');
            }
        } else if (this.activeStep == 1) {
            // first step elements
            this.creditScoringService = LongFormGlobalUtils.returnCreditScoringService('Poland');
            this.creditScoringService.setPagesMap('Mobile');
            this.docusignService = LongFormGlobalUtils.returnDocusignService('Poland');
            this.stepPagesMap = this.creditScoringService.getPagesMap();
        } else if (this.activeStep == 2) {
            // second step elements
            this.cardsConfigService = LongFormGlobalUtils.returnCardsConfigService('Poland');
            this.cardsConfigService.setPagesMap('Mobile');
            this.stepPagesMap = this.cardsConfigService.getPagesMap();
            this.additionalService = LongFormGlobalUtils.returnAdditionalService('Poland');
            this.additionalService.setPagesMap('Mobile');
            Map<String, LongFormPage> stepPagesForAdditionalMap = this.additionalService.getPagesMap();
            this.stepPagesMap.putAll(stepPagesForAdditionalMap);
        } else if (this.activeStep == 3) {
            // third step elements
            this.documentsService = LongFormGlobalUtils.returnDocumentsService('Poland');
            this.documentsService.setPagesMap('Mobile');
            this.additionalService = LongFormGlobalUtils.returnAdditionalService('Poland');
            this.stepPagesMap = this.documentsService.getPagesMap();
            this.cardsConfigService = LongFormGlobalUtils.returnCardsConfigService('Poland');
            this.docusignService = LongFormGlobalUtils.returnDocusignService('Poland');
            this.cardsConfigService.setPagesMap('Mobile');
            this.additionalService.setPagesMap('Mobile');
            Map<String, LongFormPage> stepPagesForAdditionalMap = this.additionalService.getPagesMap();
            this.stepPagesMap.putAll(stepPagesForAdditionalMap);
        } else if (this.activeStep == 4 || this.activeStep == 5) {
            // fourth step elements
            this.paymentOptionsService = LongFormGlobalUtils.returnPaymentOptionsService('Poland');
            this.paymentOptionsService.setPagesMap('Mobile');
            this.stepPagesMap = this.paymentOptionsService.getPagesMap();
            this.paymentParameters = new Map<String, String>();
            this.cardsConfigService = LongFormGlobalUtils.returnCardsConfigService('Poland');
            this.cardsConfigService.setPagesMap('Mobile');
        }
    }


    /*******************************************************************************
    *  Name            : initSObjects(String opptyId)
    *  Summary         : init sobjects
    *  CreatedDate     : 16/10/2018
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
            this.additionalService.setSFobjects(opptyId);
            this.opportunity = this.cardsConfigService.getOpportunity();
            this.account = this.cardsConfigService.getAccount();
            this.contact = this.cardsConfigService.getContact();
            this.cardsConfigService.setPriceLists();
        } else if (this.activeStep == 3) {
            this.cardsConfigService.setOpportunity(opptyId);
            this.documentsService.setSFobjects(opptyId);
            this.additionalService.setSFobjects(opptyId);
            this.opportunity = this.documentsService.getOpportunity();
            this.account = this.documentsService.getAccount();
            this.contact = this.documentsService.getContact();
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
    *  CreatedDate     : 16/10/2018
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
            if (E2EKeysAPI__c.getValues('E2EFormPL') != null) {
                Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EFormPL').AES256_Key__c);        
                // Direct Debit Mandate Acceptance
                this.stepPagesMap.get('CONGRATULATIONS').elements.get('DIRECT DEBIT MANDATE ACCEPTANCE BLOCK').get('DOCUMENT. IFRAME URL').Value__c = '/apex/E2EAdditionalDocuments?hash=' +
                    E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=ddMandateAcceptancePL&' + 'opportunityID=' + String.valueOf(opportunity.ID)+'&');         
            }
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, 'Payment Gateway Service', this.activeSubstep, 'Return from a external service', 'Poland', 'Mobile');
        }
        deactivateInactiveServices();
    }


    /*******************************************************************************
    *  Name            : doPreFillingFieldsStep_0()
    *  Summary         : pre-filling of the nil step fields
    *  CreatedDate     : 16/10/2018
    *  ModifiedDate    : 01/11/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doPreFillingFieldsStep_0() {
        if (this.contact.Salutation != null) this.stepPagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c = this.contact.Salutation;
        if (this.contact != null) {
            this.stepPagesMap.get('CONTACT DETAILS').fields.get('FIRST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = this.contact.FirstName;
            if (contact.LastName != null && ! contact.LastName.containsIgnoreCase('LongForm')) {
                this.stepPagesMap.get('CONTACT DETAILS').fields.get('LAST NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = this.contact.LastName;
            }            
            this.stepPagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = this.contact.Phone;
            this.stepPagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = this.contact.Email;
        }
        if (this.opportunity.Agree_to_process_pers_data_for_marketing__c != null) {
            this.stepPagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = String.valueOf(this.opportunity.Agree_to_process_pers_data_for_marketing__c);
        }
        if (this.opportunity.Agree_to_telephone_contact__c != null) {
            this.stepPagesMap.get('CONTACT DETAILS').fields.get('PHONE CONTACT AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = String.valueOf(this.opportunity.Agree_to_telephone_contact__c);
        }
        if (this.opportunity.Agree_to_receive_comm_info_by_email__c != null) {
            this.stepPagesMap.get('CONTACT DETAILS').fields.get('RECEIVE COMM INFO BY EMAIL AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c = String.valueOf(this.opportunity.Agree_to_receive_comm_info_by_email__c);
        }
        if (this.opportunity.E2E_Form_of_Business__c != null) {
            this.stepPagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c = this.opportunity.E2E_Form_of_Business__c;
        }
    }


    /*******************************************************************************
    *  Name            : doPreFillingFieldsStep_1()
    *  Summary         : pre-filling of the first step fields
    *  CreatedDate     : 16/10/2018
    *  ModifiedDate    : 22/12/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doPreFillingFieldsStep_1() {
        if (! this.account.Name.startsWithIgnoreCase('LONGFORM:')) {
            this.stepPagesMap.get('CREDIT SCORE. SEARCH COMPANY').fields.get('COMPANY NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = this.account.Name;
        }
        if (this.account.Steuernummer__c != null) {
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
        if (opportunity.Zahlungsart__c != null) {
            this.stepPagesMap.get('CREDIT SCORE. SCORING RESULT').fields.get('PAYMENT METHOD').elementItemsMap.get('DEFAULT VALUE').Value__c = this.opportunity.Zahlungsart__c;
        }
        this.creditScoringService.setCreditReportFromSF(this.opportunity.Id);
        this.cfReportResponse = this.creditScoringService.getCreditReportFromSF();
        if (this.cfReportResponse != null) {
            this.selectedCompany = this.cfReportResponse.company;
        }
        if (E2EKeysAPI__c.getValues('E2EFormPL') != null) {
        Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EFormPL').AES256_Key__c);
            // Additional Credit Scoring Allowance
            this.stepPagesMap.get('CREDIT SCORE. ADDITIONAL CREDIT SCORING').elements.get('DOCUMENT').get('IFRAME URL').Value__c = '/apex/E2EAdditionalDocuments?hash=' +
                    E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=AdditionalCreditScoringAllowancePL&' + 'opportunityID=' + String.valueOf(this.opportunity.Id)+'&');
        }
        if (this.activeSubStep == 'Calculating credit score') {
            if (this.selectedCompany != null ) {
                setCreditScoreParameters();
                if (this.opportunity.Rechnungsperiode__c != null && this.opportunity.CF_Credit_Limit__c != null && this.opportunity.Zahlungsziel_Credit__c != null) {
                    this.defaultBillingPeriod = Integer.valueOf(this.opportunity.Rechnungsperiode__c);
                    this.defaultPaymentTerms = Integer.valueOf(this.opportunity.Zahlungsziel_Credit__c);
                    this.creditLimit = this.opportunity.CF_Credit_Limit__c;
                    returnFinalCreditScoreData();
                    this.deposit = this.opportunity.Security_Amount_To_Pay__c;
                } else {
                    returnFinalCreditScoreData();
                }
                this.creditScoringService.resetCfDecision(this.defaultBillingPeriod, this.defaultPaymentTerms, this.deposit, this.selectedCompany.classRating, null);
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
    *  CreatedDate     : 16/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doPreFillingFieldsStep_2() {
        if (E2EKeysAPI__c.getValues('E2EFormPL') != null) {
            Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EFormPL').AES256_Key__c);
            // Terms And Conditions Of Vat-Recovery Program
            this.stepPagesMap.get('ADDITIONAL').elements.get('ADDITIONAL SERVICE #2').get('TC IFRAME URL').Value__c = '/apex/E2EAdditionalDocuments?hash=' +
                    E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=vatRecoveryTC&' + 'opportunityID=' + String.valueOf(this.opportunity.Id)+'&');
        }
        this.cardsConfigService.setCardParamsMobile();
        this.numberOfCards = this.cardsConfigService.getNumberOfCards();
        this.cardsConfigService.setCreditReport();
        this.selectedCompany = this.cardsConfigService.getCreditReport();
        this.cardsConfigService.setSpecialOffers('Mobile');
        this.nonHomeOffersList = this.cardsConfigService.getnonHomeOffersList();
        calculateFeesAndCosts();
        this.cardsConfigService.setUrlLocator();
        this.urlLocator = this.cardsConfigService.getUrlLocator();
        this.finalCardsMap = this.cardsConfigService.getFinalOrderCardsMap();
        this.cardsConfigService.setContinueButtonStatusMobile(this.activeStep, this.activeSubStep);
        this.continueButtonStatus = this.cardsConfigService.getContinueButtonStatusMobile();
        this.stepPagesMap.get('ADDITIONAL').elements.get('ADDITIONAL SERVICE #1').get('AGREEMENT CHECKBOX VALUE').Value__c = String.valueOf(this.opportunity.Eco_Fee__c);
        this.stepPagesMap.get('ADDITIONAL').elements.get('ADDITIONAL SERVICE #2').get('VAT AGREEMENT CHECKBOX VALUE').Value__c = String.valueOf(this.opportunity.VAT_Recovery__c);
        this.stepPagesMap.get('ADDITIONAL').elements.get('ADDITIONAL SERVICE #2').get('VAT TC AGREEMENT CHECKBOX VALUE').Value__c = String.valueOf(this.opportunity.Agree_to_VAT_Recovery_TC__c);
        this.stepPagesMap.get('ADDITIONAL').elements.get('ADDITIONAL SERVICE #3').get('AGREEMENT CHECKBOX VALUE').Value__c = String.valueOf(this.opportunity.Interested_in_Telematics__c);
        this.chatService.setOpportunity(this.opportunity);
        this.chatService.setContact(this.contact);
        prepareOnlineChat();
    }


    /*******************************************************************************
    *  Name            : doPreFillingFieldsStep_3()
    *  Summary         : pre-filling of the third step fields
    *  CreatedDate     : 16/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doPreFillingFieldsStep_3() {
        this.cardsConfigService.setCardParamsMobile();
        this.numberOfCards = cardsConfigService.getNumberOfCards();
        this.cardsConfigService.setCreditReport();
        this.selectedCompany = this.cardsConfigService.getCreditReport();
        this.finalCardsMap = this.cardsConfigService.getFinalOrderCardsMap();
        this.cardsConfigService.setCostsColumnsMap();
        this.cardsConfigService.setSpecialOffers('Mobile');
        this.nonHomeOffersList = this.cardsConfigService.getnonHomeOffersList();
        calculateFeesAndCosts();
        if (E2EKeysAPI__c.getValues('E2EFormPL') != null) {
            Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EFormPL').AES256_Key__c);
            // Documents Agreement (Contract Assignment + Deposit Agreement)
            this.stepPagesMap.get('DOCUMENTS').elements.get('DOCUMENTS BLOCK').get('IFRAME URL').Value__c = '/apex/E2EAdditionalDocuments?hash=' +
                    E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=documentsAgreementPL&' + 'opportunityID=' + String.valueOf(opportunity.ID)+'&');
            // Accept with terms and conditions
            this.stepPagesMap.get('DOCUMENTS').fields.get('ACCEPT TERMS AND CONDITIONS').elementItemsMap.get('IFRAME URL').Value__c = '/apex/E2EAdditionalDocuments?hash=' +
                    E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=documentsTermsAndConditionsPL&');
        }
        this.stepPagesMap.get('DOCUMENTS').fields.get('PAPER INVOICE').elementItemsMap.get('VALUE').Value__c = String.valueOf(this.opportunity.Papierrechnung__c);
        this.stepPagesMap.get('DOCUMENTS').fields.get('DECISION').elementItemsMap.get('VALUE').Value__c = String.valueOf(this.opportunity.AGB_Datenschutzhinweise_Richtigkeit__c);
        this.stepPagesMap.get('DOCUMENTS').fields.get('ACCEPT TERMS AND CONDITIONS').elementItemsMap.get('VALUE').Value__c = String.valueOf(this.contact.Authorised_signatory__c);
        this.chatService.setOpportunity(opportunity);
        this.chatService.setContact(contact);
        prepareOnlineChat();
    }


    /*******************************************************************************
    *  Name            : doPreFillingFieldsStep_4()
    *  Summary         : pre-filling of the fourth step fields
    *  CreatedDate     : 16/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doPreFillingFieldsStep_4() {
        this.cardsConfigService.setCardParamsMobile();
        this.numberOfCards = cardsConfigService.getNumberOfCards();
        this.cardsConfigService.setCreditReport();
        this.selectedCompany = this.cardsConfigService.getCreditReport();
        this.finalCardsMap = this.cardsConfigService.getFinalOrderCardsMap();
        this.cardsConfigService.setCostsColumnsMap();
        this.costsColumnsMap = this.cardsConfigService.getCostsColumnsMap();
        this.cardsConfigService.setSpecialOffers('Mobile');
        this.nonHomeOffersList = this.cardsConfigService.getnonHomeOffersList();
        calculateFeesAndCosts();
        if (opportunity.Security_Amount_To_Pay__c != null && this.paymentStatus == null) {
            this.paymentOptionsService.prepareTransaction('Mobile');
            this.selectedPaymentMethod = this.stepPagesMap.get('PAYMENT OPTIONS').fields.get('PaymentMethod Cards').options.get(0).getValue();
            changePaymentMethod(); // pre-filling payment method (init data)
        }
        this.chatService.setOpportunity(this.opportunity);
        this.chatService.setContact(this.contact);
        prepareOnlineChat();
    }


    /*******************************************************************************
    *  Name            : doPreFillingFieldsStep_5()
    *  Summary         : pre-filling of the five step fields
    *  CreatedDate     : 06/11/2018
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
        if (E2EKeysAPI__c.getValues('E2EFormPL') != null) {
            Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EFormPL').AES256_Key__c);

            // Direct Debit Mandate Acceptance
            this.stepPagesMap.get('CONGRATULATIONS').elements.get('DIRECT DEBIT MANDATE ACCEPTANCE BLOCK').get('DOCUMENT. IFRAME URL').Value__c = '/apex/E2EAdditionalDocuments?hash=' +
                    E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=ddMandateAcceptancePL&' + 'opportunityID=' + String.valueOf(opportunity.ID)+'&');
        }
        this.cardsConfigService.setCardParams();
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
    *  CreatedDate     : 16/10/2018
    *  ModifiedDate    : -
    *  Parameters      : String opptyId
    *  Returns         : void
    ******************************************************************************/
    public void activateNewStep(String opptyId) {
        initPageElements();
        initSObjects(opptyId);
        doPreFillingFormFields();
    }


    /*******************************************************************************
    *  Name            : getStarted()
    *  Summary         : go to 'Contact details' substep
    *  CreatedDate     : 16/10/2018
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
    *  CreatedDate     : 16/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
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
                                String url = returnLinkToRedirect(true);
                                PageReference reference = new PageReference(url + contactRole.Opportunity.E2E_Encoded_URL__c);
                                reference.setRedirect(true);
                                if (this.opportunity != null) {
                                    LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'Poland', 'Mobile');
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
                                String url = returnLinkToRedirect(true);
                                PageReference reference = new PageReference(url + contactRole.Opportunity.E2E_Encoded_URL__c);
                                reference.setRedirect(true);
                                this.endApexCall = Datetime.now();
                                LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, contactRole.Opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'Poland', 'Mobile');
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
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'Poland', 'Mobile');
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
    *  CreatedDate     : 16/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doSaveCompanyDetailsData() {
        try {
            this.startApexCall = Datetime.now();
            doDisabledTriggers();
            deleteDocusignStatus();
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
    *  CreatedDate     : 16/10/2018
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
            update this.opportunity;
            if (this.selectedCompany == null) this.selectedCompany = new CreditCompany();
            if (! this.foundCompaniesList.companiesMap.isEmpty() ) {
                this.activeInnerPage = 'Select company';
            } else {
                throw new LongFormException(E2EExceptionUtils.errorsMap.get('Company not found'));
            }
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, 'This is a company search process.', 'Poland', 'Mobile');
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
    *  Name            : deleteReportsForPreviousCompany()
    *  Summary         : delete all credit factory reports and docusign statuses if user selects new company
    *  CreatedDate     : 09/11/2018
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
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'deleteReportsForPreviousCompany()', e);
        }
    }


    /*******************************************************************************
    *  Name            : goToSetTotalConsumption()
    *  Summary         : go to total consumption substep
    *  CreatedDate     : 16/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void goToSetTotalConsumption() {
        try {
            doDisabledTriggers();
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
                E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubStep, null);
                return;
            }
            this.creditScoringService.doUpdateSFobjects(this.cfReportResponse);
            this.creditScoringService.setResultOfCheckBlackList();
            E2E_Form_General_Settings__c settings = E2E_Form_General_Settings__c.getInstance('Poland');
            if (settings.Enable_authorization_non_granted_check__c) {
                Boolean isAuthorizatedGranted = this.creditScoringService.getResultOfCheckAuthorizatedGranted();
                Boolean isNotAtBlackList = this.creditScoringService.getResultOfCheckBlackList();
                if (! isAuthorizatedGranted || ! isNotAtBlackList) {
                    if (! isAuthorizatedGranted ) {
                        this.activeSubStep = 'Authorization not granted';
                    } else if (! isNotAtBlackList ) {
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
            prepareOnlineChat();
        } catch (Exception e) {
            initSObjects(opportunity.Id);
            this.activeInnerPage = null;
            if (e.getMessage() == E2EExceptionUtils.errorsMap.get('Report does not exist')) {
                this.activeStep = null;
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
    *  Name            : validateVatId()
    *  Summary         : validate VAT ID    
    *  CreatedDate     : 19/02/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void validateVatId() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            if (this.activeSubStep == 'Set total consumption') {
                this.creditScoringService.setAccount(this.account.Id);
                this.account = this.creditScoringService.getAccount();
                this.stepPagesMap.get('CREDIT SCORE. INPUT VAT ID').fields.get('NO VAT').elementItemsMap.get('DEFAULT VALUE').Value__c = String.valueOf(this.account.No_Vat__c);
                if (this.cfReportResponse.company.taxnumber != null) {
                    this.stepPagesMap.get('CREDIT SCORE. INPUT VAT ID').fields.get('VAT NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = 'PL' + this.cfReportResponse.company.taxnumber;
                } else {
                    this.stepPagesMap.get('CREDIT SCORE. INPUT VAT ID').fields.get('VAT NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = 'PL' + this.account.Steuernummer__c;
                }
                this.isVatIdValid = this.creditScoringService.validateVatId();
                if (! this.isVatIdValid && ! this.account.No_Vat__c) {
                    this.stepPagesMap.get('CREDIT SCORE. INPUT VAT ID').fields.get('NO VAT').elementItemsMap.get('DEFAULT VALUE').Value__c = 'false';
                    this.stepPagesMap.get('CREDIT SCORE. INPUT VAT ID').fields.get('VAT NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = '';
                    this.activeSubStep = 'Enter VAT Number';
                    this.creditScoringService.goToSetVatNumberStep();
                } else {
                    this.creditScoringService.doUpdateVatNumber();
                }
            }
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'Poland', 'Mobile');
        } catch (Exception e) {
            this.activeSubStep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'validateVatId()', e);
        }
    }


    /*******************************************************************************
    *  Name            : updateVatNumber()
    *  Summary         : update VAT number if and go to "Set total consumption" step
    *  CreatedDate     : 19/02/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void updateVatNumber() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            this.startApexCall = Datetime.now();
            doDisabledTriggers();
            this.isVatIdValid = this.creditScoringService.validateVatId();
            if (this.isVatIdValid) {
                this.creditScoringService.doUpdateVatNumber();
                this.activeInnerPage = '';
                this.activeStep = 1;
                this.activeSubStep = 'Set total consumption';
            }
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'Poland', 'Mobile');
        } catch (Exception e) {
            this.activeSubStep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'updateVatNumber()', e);
        }
    }


    /*******************************************************************************
    *  Name            : goToSignDocuments()
    *  Summary         : Prepare envelope and redirect to sign dociments
    *  CreatedDate     : 14/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : PageReference
    ******************************************************************************/
    public PageReference goToSignDocuments() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            this.docusignService.setContactRole(this.opportunity.Id);
            this.docusignService.setOpportunity(this.opportunity.Id);
            // create envelope and generate token to sign documents
            String token = this.docusignService.createEnvelope('Mobile', this.activeSubstep);
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, 'Transition To Docusign Service.', 'Poland', 'Mobile');
            return new PageReference(token);
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'goToSignDocuments()', e);
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : doCalculateCreditScoring()
    *  Summary         : calculating credit scoring
    *  CreatedDate     : 16/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doCalculateCreditScoring() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            this.startApexCall = Datetime.now();
            doDisabledTriggers();
            deleteDocusignStatus();

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
                if (this.cfDecision.statusCode == '003') {
                    throw new LongFormException(E2EExceptionUtils.errorsMap.get('Additional Credit Scoring Allowance'));
                } else if (this.cfDecision.statusCode == '005') {
                    throw new LongFormException(E2EExceptionUtils.errorsMap.get('Risky but manageable'));
                } else if (this.cfDecision.statusCode == '006' || this.cfDecision.statusCode == '007') {
                    throw new LongFormException(E2EExceptionUtils.errorsMap.get('Too risky'));
                }
            }
            prepareOnlineChat();
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'Poland', 'Mobile');
        } catch (Exception e) {
            if (e.getMessage() == E2EExceptionUtils.errorsMap.get('Additional Credit Scoring Allowance')) {
                this.activeStep = 1;
                this.activeInnerPage = 'Additional Credit Scoring Allowance';
                this.activeSubStep = 'Additional Credit Scoring Allowance';
                if (E2EKeysAPI__c.getValues('E2EFormPL') != null) {
                    Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EFormPL').AES256_Key__c);
                    // Additional Credit Scoring Allowance
                    this.stepPagesMap.get('CREDIT SCORE. ADDITIONAL CREDIT SCORING').elements.get('DOCUMENT').get('IFRAME URL').Value__c = '/apex/E2EAdditionalDocuments?hash=' +
                        E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=AdditionalCreditScoringAllowancePL&' + 'opportunityID=' + String.valueOf(this.opportunity.Id)+'&');
                }                
            } else if (e.getMessage() == E2EExceptionUtils.errorsMap.get('Risky but manageable')) {
                this.activeSubStep = 'Risky but manageable';
                E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            } else if (e.getMessage() == E2EExceptionUtils.errorsMap.get('Too risky')) {
                this.activeSubStep = 'Too risky';
                E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            } else {
                this.activeSubStep = 'System error';
                E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'doCalculateCreditScoring()', e);
                E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            }            
        }
    }


    /*******************************************************************************
    *  Name            : deleteDocusignStatus()
    *  Summary         : Delete docusign status and move envelope to the Deleted folder    
    *  CreatedDate     : 29/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void deleteDocusignStatus() {
        Set<String> attachNamesSet = new Set<String>();
        if (this.activeSubstep == 'Set total consumption' || this.activeSubstep == 'Additional Credit Scoring Allowance') {
            E2E_Docusign_Templates__c creditScoringAllowanceSettings = E2E_Docusign_Templates__c.getInstance('E2E PL Credit Scoring Allowance');
            attachNamesSet.add(creditScoringAllowanceSettings.Attachment_Name__c);
            if (this.stepPagesMap.get('CREDIT SCORE. TOTAL CONSUMPTION').fields.get('TOTAL CONSUMPTION').elementItemsMap.get('DEFAULT VALUE').Value__c != null &&
                this.stepPagesMap.get('CREDIT SCORE. TOTAL CONSUMPTION').fields.get('TOTAL CONSUMPTION').elementItemsMap.get('DEFAULT VALUE').Value__c != '') {
                Integer totalConsumption = Integer.valueOf(this.stepPagesMap.get('CREDIT SCORE. TOTAL CONSUMPTION').fields.get('TOTAL CONSUMPTION').elementItemsMap.get('DEFAULT VALUE').Value__c);
                if (totalConsumption <= 8000) this.docusignService.deleteDocusignStatuses(this.opportunity.Id, attachNamesSet);
            }
        } else {
            this.docusignService.setContactRole(this.opportunity.Id);
            this.docusignService.setOpportunity(this.opportunity.Id);
            Boolean isSameContact = this.docusignService.checkContact();
            if ( ! isSameContact ) {
                E2E_Docusign_Templates__c contractSettings = E2E_Docusign_Templates__c.getInstance('E2E PL Contract');
                E2E_Docusign_Templates__c depositSettings = E2E_Docusign_Templates__c.getInstance('E2E PL Deposit Agreement');
                attachNamesSet.add(contractSettings.Attachment_Name__c);
                attachNamesSet.add(depositSettings.Attachment_Name__c);
                this.docusignService.deleteDocusignStatuses(this.opportunity.Id, attachNamesSet);
            }
        }
    }


    /*******************************************************************************
    *  Name            : setCreditScoreParameters()
    *  Summary         : set credit score parameters
    *  CreatedDate     : 16/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void setCreditScoreParameters() {
        this.defaultBillingPeriod = Integer.valueOf(this.cfReportResponse.recommendedBillingPeriod);
        this.defaultPaymentTerms = Integer.valueOf(this.cfReportResponse.recommendedPaymentTerms);
        this.creditLimit = this.cfReportResponse.creditLimitDefault;
        this.creditLimit15_Plus14 = this.cfReportResponse.creditLimit15_Plus14;
        this.maxCreditLimit15_Plus14 = this.cfReportResponse.maxCreditLimit15_Plus14;
        this.maxValue15_Plus14 = this.cfReportResponse.maxValue15_Plus14;
        this.deposit15_Plus14 = this.cfReportResponse.deposit15_Plus14;
        this.creditLimit7_Plus7 = this.cfReportResponse.creditLimit7;
        this.maxCreditLimit7_Plus7 = this.cfReportResponse.maxCreditLimit7;
        this.maxValue7_Plus7 = this.cfReportResponse.maxValue7;
        this.deposit7_Plus7 = this.cfReportResponse.deposit7;
    }


    /*******************************************************************************
    *  Name            : changeBillingPeriod()
    *  Summary         : do change billing period when click button
    *  CreatedDate     : 16/10/2018
    *  ModifiedDate    : 22/12/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void changeBillingPeriod() {
        returnFinalCreditScoreData();
        this.creditScoringService.resetCfDecision(this.defaultBillingPeriod, this.defaultPaymentTerms, this.deposit, this.selectedCompany.classRating, null);
        this.cfDecision = this.creditScoringService.getCfDecision();
    }


    /*******************************************************************************
    *  Name            : returnFinalCreditScoreData()
    *  Summary         : return final of credit score data
    *  CreatedDate     : 16/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void returnFinalCreditScoreData() {
        if (this.defaultBillingPeriod == 15 && this.defaultPaymentTerms == 14) {
            this.minCreditLimit = this.creditLimit15_Plus14;
            this.maxCreditLimit = this.maxCreditLimit15_Plus14;
            this.maxValue = this.maxValue15_Plus14;
            this.deposit = this.deposit15_Plus14;
        } else if (this.defaultBillingPeriod == 7 && this.defaultPaymentTerms == 7) {
            this.minCreditLimit = this.creditLimit7_Plus7;
            this.maxCreditLimit = this.maxCreditLimit7_Plus7;
            this.maxValue = this.maxValue7_Plus7;
            this.deposit = this.deposit7_Plus7;
        }
    }


    /*******************************************************************************
    *  Name            : doRecalculateDeposit()
    *  Summary         : recalculate deposit
    *  CreatedDate     : 16/10/2018
    *  ModifiedDate    : 22/12/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doRecalculateDeposit() {
        try {
            this.activeInnerPage = '';
            creditScoringService.setDeposit(this.selectedCompany, this.defaultBillingPeriod, this.defaultPaymentTerms, this.creditLimit, this.maxCreditLimit);
            this.deposit = creditScoringService.getDeposit();
            creditScoringService.resetCfDecision(this.defaultBillingPeriod, this.defaultPaymentTerms, this.deposit, this.selectedCompany.classRating, null);
            this.cfDecision = creditScoringService.getCfDecision();
        } catch(Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'doRecalculateDeposit()', e);
        }
    }


    /*******************************************************************************
    *  Name            : goToCardsConfig()
    *  Summary         : go to long form step 2
    *  CreatedDate     : 16/10/2018
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
            this.creditScoringService.saveCreditScoringResult(this.defaultBillingPeriod, this.defaultPaymentTerms, this.creditLimit, this.deposit);
            activateNewStep(this.opportunity.Id);
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'Poland', 'Mobile');
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'goToCardsConfig()', e);
        }
    }


    /*******************************************************************************
    *  Name            : goToEmbossing()
    *  Summary         : go to "Embossing" tab of "Card configuration" step
    *  CreatedDate     : 16/10/2018
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
    *  CreatedDate     : 16/10/2018
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
    *  CreatedDate     : 16/10/2018
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
    *  CreatedDate     : 16/10/2018
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
    *  CreatedDate     : 16/10/2018
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
    *  CreatedDate     : 16/10/2018
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
    *  CreatedDate     : 16/10/2018
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
    *  CreatedDate     : 16/10/2018
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
    *  CreatedDate     : 14/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void goToOptions() {
        this.cardsConfigService.setContinueButtonStatusMobile(this.activeStep, this.activeSubStep);
        this.continueButtonStatus = this.cardsConfigService.getContinueButtonStatusMobile();
    }


    /*******************************************************************************
    *  Name            : saveConfiguration()
    *  Summary         : saving all selected cards
    *  CreatedDate     : 16/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void goToSpecialOffers() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            this.startApexCall = Datetime.now();
            doDisabledTriggers();
            this.activeStep = 2;
            this.activeSubStep = 'Choosing offer';
            this.cardsConfigService.saveCardsConfigResultMobile(this.activeSubStep);
            this.finalCardsMap = this.cardsConfigService.getFinalOrderCardsMap();
            this.cardsConfigService.setSpecialOffers('Mobile');
            this.nonHomeOffersList = this.cardsConfigService.getnonHomeOffersList();

            // UNCOMMED LATER

            // if (this.urlLocator == null) {
            //     this.cardsConfigService.setUrlLocator();
            //     this.urlLocator = this.cardsConfigService.getUrlLocator();
            // }
            // this.activeStep = 2;
            // this.activeSubStep = 'Choosing offer';
            // this.cardsConfigService.setContinueButtonStatusMobile(this.activeStep, this.activeSubStep);
            // this.continueButtonStatus = this.cardsConfigService.getContinueButtonStatusMobile();
            // prepareOnlineChat();


            // TEMP BLOCK DUE TO "SPECIAL OFFER" STEP REMOVAL (MUST BE REMOVED)
            // ====================================================================================
            this.activeInnerPage = '';
            this.activeStep = 2;
            this.activeSubStep = 'Additional services';
            this.additionalService.setSFobjects(this.opportunity.Id);
            // ====================================================================================


            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'Poland', 'Mobile');
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'goToSpecialOffers()', e);
        }
    }


    /*******************************************************************************
    *  Name            : chooseStation()
    *  Summary         : open locator to select station point
    *  CreatedDate     : 16/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void chooseStation() {
        try {
            this.activeInnerPage = 'Locator';
            String offerName = ApexPages.CurrentPage().getParameters().get('offerName');
            this.cardsConfigService.chooseStation(offerName);
            this.nonHomeOffersList = this.cardsConfigService.getnonHomeOffersList();
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'chooseStation()', e);
        }
    }


    /*******************************************************************************
    *  Name            : selectOffer()
    *  Summary         : set selected offer
    *  CreatedDate     : 16/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void selectOffer() {
        try {
            this.activeInnerPage = '';
            String offerName = ApexPages.CurrentPage().getParameters().get('offerName');
            this.cardsConfigService.selectOffer(offerName);
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
    *  CreatedDate     : 16/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void removeOffer() {
        try {
            this.activeInnerPage = '';
            this.cardsConfigService.removeOffer();
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
    *  CreatedDate     : 16/10/2018
    *  ModifiedDate    : 16/11/2018
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
            this.activeStep = 2;
            this.activeSubStep = 'Additional services';
            this.additionalService.setSFobjects(this.opportunity.Id);
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'Poland', 'Mobile');
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'goToAdditionalParams()', e);
        }
    }


    /*******************************************************************************
    *  Name            : goToDocuments()
    *  Summary         : save additional service data and go to "Documents" step
    *  CreatedDate     : 12/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void goToDocuments() {
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
                if (isInternationalSoloTrader()) return;
            }
            this.activeStep = 3;
            this.activeSubStep = 'Documents';
            this.additionalService.updateRecords();
            activateNewStep(this.opportunity.Id);
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'Poland', 'Mobile');
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'goToDocuments()', e);
        }
    }


    /*******************************************************************************
    *  Name            : showTermsAndConditionsVatRecoveryModal()
    *  Summary         : show "Terms And Conditions Of Vat-Recovery Program" modal window
    *  CreatedDate     : 20/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void showTermsAndConditionsVatRecoveryModal() {
        this.activeInnerPage = 'Modal Vat-Recovery Program TC';
    }


    /*******************************************************************************
    *  Name            : continueToAdditionalParams()
    *  Summary         : go to "Additional" step from DOB
    *  CreatedDate     : 16/11/2018
    *  ModifiedDate    :
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void continueToDocumentsFromDateOfBirth() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            this.startApexCall = Datetime.now();
            doDisabledTriggers();
            if ( ! isDobValid() ) throw new LongFormException('Date of birth is not valid.');
            this.activeStep = 3;
            this.activeSubStep = 'Documents';
            this.additionalService.updateRecords();
            activateNewStep(this.opportunity.Id);
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'Poland', 'Mobile');
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'goToAdditionalParams()', e);
        }
    }


    /*******************************************************************************
    *  Name            : isInternationalSoloTrader()
    *  Summary         : Display DOB field for international Solo-trader
    *  CreatedDate     : 16/11/2018
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
            this.activeStep = 2;
            this.activeSubStep = 'Enter Date of Birth';
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'Poland', 'Mobile');
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
    *  CreatedDate     : 16/11/2018
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
    *  Name            : saveDocumentsAgreements()
    *  Summary         : save documents step data
    *  CreatedDate     : 12/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : PageReference - Docusign service
    ******************************************************************************/
    public void saveDocumentsStepData() {
        try {
            this.startApexCall = Datetime.now();
            doDisabledTriggers();
            this.activeInnerPage = '';
            this.documentsService.validateAgreements();
            this.documentsService.saveDocumentsStepData();
        } catch (Exception e) {
            this.activeSubStep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'saveDocumentsStepData()', e);
        }
    }


    /*******************************************************************************
    *  Name            : changePaymentMethod()
    *  Summary         : set payment method
    *  CreatedDate     : 16/10/2018
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
    *  CreatedDate     : 16/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void proceedToCheckout() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            this.startApexCall = Datetime.now();
            doDisabledTriggers();
            // this.activeInnerPage = '';
            // this.paymentOptionsService.saveTransactionData();


            // TEMP BLOCK (MUST BE REMOVED)
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
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'Poland', 'Mobile');
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'proceedToCheckout()', e);
        }
    }


    /*******************************************************************************
    *  Name            : showSaveAndContinueLaterModal()
    *  Summary         : show save and continue later modal
    *  CreatedDate     : 16/10/2018
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
    *  CreatedDate     : 16/10/2018
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
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'Poland', 'Mobile');
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'editContactDetails()', e);
        }
    }


    /*******************************************************************************
    *  Name            : editCompanyDetails()
    *  Summary         : edit company details
    *  CreatedDate     : 16/10/2018
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
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'Poland', 'Mobile');
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'editCompanyDetails()', e);
        }
    }


    /*******************************************************************************
    *  Name            : editCreditScoreData()
    *  Summary         : edit credit score data
    *  CreatedDate     : 16/10/2018
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
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'Poland', 'Mobile');
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'editCreditScoreData()', e);
        }
    }


    /*******************************************************************************
    *  Name            : editCardConfiguration()
    *  Summary         : edit card configuration
    *  CreatedDate     : 16/10/2018
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
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'Poland', 'Mobile');
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'editCardConfiguration()', e);
        }
    }


    /*******************************************************************************
    *  Name            : editSpecialOffers()
    *  Summary         : edit card configuration
    *  CreatedDate     : 16/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void editSpecialOffers() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            this.startApexCall = Datetime.now();
            this.activeStep = 2;

            // UNCOMMENT LATER
            // this.activeSubStep = 'Choosing offer';

            // TEMP BLOCK DUE TO "SPECIAL OFFER" STEP REMOVAL (MUST BE REMOVED)
            // ================================================================
            this.activeSubStep = 'Additional services';
            // ================================================================


            activateNewStep(this.opportunity.Id);
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'Poland', 'Mobile');
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'editSpecialOffers()', e);
        }
    }


    /*******************************************************************************
    *  Name            : editDocuments()
    *  Summary         : edit documents step
    *  CreatedDate     : 25/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void editDocuments() {
        try {
            String currentActiveSubstep = this.activeSubStep;
            this.startApexCall = Datetime.now();
            this.activeStep = 3;
            this.activeSubStep = 'Documents';
            activateNewStep(this.opportunity.Id);
            this.endApexCall = Datetime.now();
            LongFormGlobalUtils.setTimeExecutionOfApexCall(this.startApexCall, this.endApexCall, this.opportunity.Id, currentActiveSubstep, this.activeSubStep, null, 'Poland', 'Mobile');
        } catch (Exception e) {
            this.activeSubstep = 'System error';
            E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
            E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'editDocuments()', e);
        }
    }


    /*******************************************************************************
    *  Name            : closeModal()
    *  Summary         : close modal window
    *  CreatedDate     : 16/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void closeModal() {
        this.activeInnerPage = null;
    }


    /*******************************************************************************
    *  Name            : showTermsAndConditions()
    *  Summary         : show term and conditions modal window
    *  CreatedDate     : 16/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void showTermsAndConditions() {
        this.activeInnerPage = 'Modal Term And Conditions';
    }


    /*******************************************************************************
    *  Name            : showDocumentsModal()
    *  Summary         : show documents modal window
    *  CreatedDate     : 12/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void showDocumentsModal() {
        this.activeInnerPage = 'Modal Documents';
    }


    /*******************************************************************************
    *  Name            : showAgreeToPhoneContact()
    *  Summary         : show agree to phone contact modal window
    *  CreatedDate     : 01/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void showAgreeToPhoneContact() {
        this.activeInnerPage = 'Modal Agree To Phone Contact';
    }


    /*******************************************************************************
    *  Name            : showAgreeToInfoByEmail()
    *  Summary         : show agree to info by email modal window
    *  CreatedDate     : 01/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void showAgreeToInfoByEmail() {
        this.activeInnerPage = 'Modal Agree To Info By Email';
    }


    /*******************************************************************************
    *  Name            : showAgreeNews()
    *  Summary         : show agree to news modal window
    *  CreatedDate     : 01/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void showAgreeNews() {
        this.activeInnerPage = 'Modal Agree To News';
    }


    /*******************************************************************************
    *  Name            : showDDMandateModal()
    *  Summary         : show dd mandate aggrement modal window
    *  CreatedDate     : 25/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void showDDMandateModal() {
        this.activeInnerPage = 'Modal ddMandate';
    }


    /*******************************************************************************
    *  Name            : doSaveAndContinueLater()
    *  Summary         : do save and continue later
    *  CreatedDate     : 16/10/2018
    *  ModifiedDate    : 14/11/2018
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
            } else if (this.activeSubstep == 'Documents') {
                this.documentsService.doSaveAndContinueLater();
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
    *  Name            : sendCSAllowanceToEmail()
    *  Summary         : Send docusign Zgoda na weryfikacje as attachment to the user email
    *  CreatedDate     : 18/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    // public void sendCSAllowanceToEmail() {
    //     this.activeInnerPage = null;
    //     try {
    //         String fileName = 'Zgoda na weryfikacje';
    //         Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EFormPL').AES256_Key__c);
    //         String pageRefString = '/apex/E2EAdditionalDocuments?hash=' +
    //                     E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=AdditionalCreditScoringAllowancePL&' + 'opportunityID=' + String.valueOf(opportunity.Id) + '&');

    //         PageReference sepaMandatePage = new PageReference(pageRefString);
    //         Blob pdfContent;
    //         if (Test.IsRunningTest()) pdfContent = Blob.valueOf('UNIT.TEST');
    //         else pdfContent = sepaMandatePage.getContentAsPDF();

    //         Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
    //         attachment.setFileName(fileName + '.pdf');
    //         attachment.setBody(pdfContent);
    //         Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    //         String[] toAddresses = new list<string> {this.contact.Email};
    //         String subject = 'Zgoda na weryfikacje.';
    //         email.setSubject(subject);
    //         email.setToAddresses(toAddresses);
    //         email.setHtmlBody('<p>We confirm that you have requested us to send documents: Zgoda na weryfikacje. If desired, you can download the documents here and save them for your administration.</p>');
    //         email.setFileAttachments(new Messaging.EmailFileAttachment[]{attachment});
    //         Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    //     } catch (Exception e) {
    //         this.activeSubstep = 'System error';
    //         E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
    //         E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'sendCSAllowanceToEmail()', e);
    //     }
    // }


    /*******************************************************************************
    *  Name            : sendDDMandateAcceptance()
    *  Summary         : Send docusign DDMandateAcceptance as attachment to the user email
    *  CreatedDate     : 25/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    // public void sendDDMandateAcceptance() {
    //     this.activeInnerPage = null;
    //     try {
    //         String fileName = 'ddMandateAcceptance';
    //         Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EFormPL').AES256_Key__c);
    //         String pageRefString = '/apex/E2EAdditionalDocuments?hash=' +
    //                     E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=ddMandateAcceptancePL&' + 'opportunityID=' + String.valueOf(opportunity.Id) + '&');

    //         PageReference sepaMandatePage = new PageReference(pageRefString);
    //         Blob pdfContent;
    //         if (Test.IsRunningTest()) pdfContent = Blob.valueOf('UNIT.TEST');
    //         else pdfContent = sepaMandatePage.getContentAsPDF();

    //         Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
    //         attachment.setFileName(fileName + '.pdf');
    //         attachment.setBody(pdfContent);
    //         Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    //         String[] toAddresses = new list<string> {this.contact.Email};
    //         String subject = 'ddMandateAcceptance.';
    //         email.setSubject(subject);
    //         email.setToAddresses(toAddresses);
    //         email.setHtmlBody('<p>We confirm that you have requested us to send documents: ddMandateAcceptance. If desired, you can download the documents here and save them for your administration.</p>');
    //         email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
    //         Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
    //     } catch (Exception e) {
    //         this.activeSubstep = 'System error';
    //         E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
    //         E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'sendDDMandateAcceptance()', e);
    //     }
    // }


    /*******************************************************************************
    *  Name            : showDDMandateDocument()
    *  Summary         : Show DD Mandate Agreement Document window
    *  CreatedDate     : 25/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    // public void showDDMandateDocument() {
    //     this.activeInnerPage = 'Send ddMandateAggrement to email';
    // }


    /*******************************************************************************
    *  Name            : showCSAllowanceDocument()
    *  Summary         : Show Credit Scoring Allowance Document window
    *  CreatedDate     : 22/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    // public void showCSAllowanceDocument() {
    //     this.activeInnerPage = 'Send CS Allowance to email';
    // }


    /*******************************************************************************
    *  Name            : sendVatTcToEmail()
    *  Summary         : Send Vat recovery programm TC as attachment email to the user email
    *  CreatedDate     : 16/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    // public void sendVatTcToEmail() {
    //     this.activeInnerPage = null;
    //     try {
    //         String fileName = 'vatRecoveryTC';
    //         String accountHolder = this.opportunity.Name_of_the_payer_Account_holder__c;
    //         Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EFormPL').AES256_Key__c);
    //         String pageRefString = '/apex/E2EAdditionalDocuments?hash=' +
    //                     E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=vatRecoveryTC&' + 'opportunityID=' + String.valueOf(opportunity.Id) + '&dynamicAccHolder=' + accountHolder + '&');
    //         PageReference sepaMandatePage = new PageReference(pageRefString);
    //         Blob pdfContent;
    //         if (Test.IsRunningTest()) pdfContent = Blob.valueOf('UNIT.TEST');
    //         else pdfContent = sepaMandatePage.getContentAsPDF();

    //         Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
    //         attachment.setFileName(fileName + '.pdf');
    //         attachment.setBody(pdfContent);
    //         Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    //         String[] toAddresses = new list<string> {this.contact.Email};
    //         String subject = 'Zamówienie Karty Shell online.';
    //         email.setSubject(subject);
    //         email.setToAddresses(toAddresses);
    //         email.setHtmlBody('<p>Wij bevestigen dat u ons hebt verzocht documenten toe te sturen: Algemene Voorwaarden. Desgewenst kunt u hier de documenten downloaden en opslaan voor uw administratie.</p>');
    //         email.setFileAttachments(new Messaging.EmailFileAttachment[]{attachment});
    //         Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    //     } catch (Exception e) {
    //         this.activeSubstep = 'System error';
    //         E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
    //         E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'sendTcToEmail()', e);
    //     }
    // }


    /*******************************************************************************
    *  Name            : showSendTCDocument()
    *  Summary         : Show Vat recovery programm TC Document window
    *  CreatedDate     : 16/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    // public void showSendVatTcDocument() {
    //     this.activeInnerPage = 'Send Vat TC to email';
    // }


    /*******************************************************************************
    *  Name            : sendHowToPayToEmail()
    *  Summary         : Send How to Pay as attachment email to the user email
    *  CreatedDate     : 16/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    // public void sendHowToPayToEmail() {
    //     this.activeInnerPage = null;
    //     try {
    //         String fileName = 'Sposób płatności depozytu';
    //         String accountHolder = this.opportunity.Name_of_the_payer_Account_holder__c;
    //         Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EFormPL').AES256_Key__c);
    //         String pageRefString = '/apex/E2EAdditionalDocuments?hash=' +
    //                     E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=PaymentInformationPL&' + 'opportunityID=' + String.valueOf(opportunity.Id) + '&dynamicAccHolder=' + accountHolder + '&');
    //         PageReference kautionPage = new PageReference(pageRefString);
    //         Blob pdfContent;
    //         if (Test.IsRunningTest()) pdfContent = Blob.valueOf('UNIT.TEST');
    //         else pdfContent = kautionPage.getContentAsPDF();

    //         Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
    //         attachment.setFileName(fileName + '.pdf');
    //         attachment.setBody(pdfContent);
    //         Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    //         String[] toAddresses = new list<string> {this.contact.Email};
    //         String subject = 'Kontynuacja zamówienia kart Shell online.';
    //         email.setSubject(subject);
    //         email.setToAddresses(toAddresses);
    //         email.setHtmlBody('<p>Potwierdzamy złożenie prośby o przesłanie dokumentów: Sposób płatności depozytu. Prosimy o pobranie i zapisanie dokumentów na swoje potrzeby.</p>');
    //         email.setFileAttachments(new Messaging.EmailFileAttachment[]{attachment});
    //         Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    //     } catch (Exception e) {
    //         this.activeSubstep = 'System error';
    //         E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
    //         E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'sendHowToPayToEmail()', e);
    //     }
    // }


    /*******************************************************************************
    *  Name            : showSendHowToPayDocument()
    *  Summary         : Show How to Pay Document window
    *  CreatedDate     : 16/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    // public void showSendHowToPayDocument() {
    //     this.activeInnerPage = 'Send How to Pay to email';
    // }


    /*******************************************************************************
    *  Name            : sendDocuments()
    *  Summary         : Send documents as attachment email to the user email
    *  CreatedDate     : 16/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    // public void sendDocuments() {
    //     this.activeInnerPage = null;
    //     try {
    //         String fileName = 'DocumentsAgreement';
    //         String accountHolder = this.opportunity.Name_of_the_payer_Account_holder__c;
    //         Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EFormPL').AES256_Key__c);
    //         String pageRefString = '/apex/E2EAdditionalDocuments?hash=' +
    //                     E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=documentsAgreementPL&' + 'opportunityID=' + String.valueOf(opportunity.ID)+'&');
    //         PageReference kautionPage = new PageReference(pageRefString);
    //         Blob pdfContent;
    //         if (Test.IsRunningTest()) pdfContent = Blob.valueOf('UNIT.TEST');
    //         else pdfContent = kautionPage.getContentAsPDF();

    //         Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
    //         attachment.setFileName(fileName + '.pdf');
    //         attachment.setBody(pdfContent);
    //         Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    //         String[] toAddresses = new list<string> {this.contact.Email};
    //         String subject = 'Shell tankpassen online bestellen.';
    //         email.setSubject(subject);
    //         email.setToAddresses(toAddresses);
    //         email.setHtmlBody('<p>Wij bevestigen dat u ons hebt verzocht documenten toe te sturen: Documents. Desgewenst kunt u hier de documenten downloaden en opslaan voor uw administratie.</p>');
    //         email.setFileAttachments(new Messaging.EmailFileAttachment[]{attachment});
    //         Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    //     } catch (Exception e) {
    //         this.activeSubstep = 'System error';
    //         E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
    //         E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'sendDocuments()', e);
    //     }
    // }


    /*******************************************************************************
    *  Name            : showSendDocuments()
    *  Summary         : Show documents window
    *  CreatedDate     : 12/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    // public void showSendDocuments() {
    //     this.activeInnerPage = 'Send documents to email';
    // }


    /*******************************************************************************
    *  Name            : showTermsAndConditionsModal()
    *  Summary         : show "Terms And Conditions" modal window on "Documents" step
    *  CreatedDate     : 26/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void showTermsAndConditionsModal() {
        this.activeInnerPage = 'Modal Terms And Conditions';
    }


    /*******************************************************************************
    *  Name            : showSendTermsAndConditions()
    *  Summary         : show "Terms And Conditions" modal window on "Documents" step
    *  CreatedDate     : 26/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    // public void showSendTermsAndConditions() {
    //     this.activeInnerPage = 'Send TC to email';
    // }


    /*******************************************************************************
    *  Name            : sendTC()
    *  Summary         : Send documents as TC email to the user email
    *  CreatedDate     : 26/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    // public void sendTC() {
    //     this.activeInnerPage = null;
    //     try {
    //         String fileName = 'Warunkami';
    //         String accountHolder = this.opportunity.Name_of_the_payer_Account_holder__c;
    //         Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EFormPL').AES256_Key__c);
    //         String pageRefString = '/apex/E2EAdditionalDocuments?hash=' +
    //                 E2EFormEncryption.getHashAlgorithAES256(key256AES, 'documentName=documentsTermsAndConditionsPL&');
    //         PageReference kautionPage = new PageReference(pageRefString);
    //         Blob pdfContent;
    //         if (Test.IsRunningTest()) pdfContent = Blob.valueOf('UNIT.TEST');
    //         else pdfContent = kautionPage.getContentAsPDF();

    //         Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
    //         attachment.setFileName(fileName + '.pdf');
    //         attachment.setBody(pdfContent);
    //         Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    //         String[] toAddresses = new list<string> {this.contact.Email};
    //         String subject = 'Zamówienie Karty Shell online.';
    //         email.setSubject(subject);
    //         email.setToAddresses(toAddresses);
    //         email.setHtmlBody('<p>Potwierdzamy złożenie prośby o przesłanie dokumentów: Warunkami. Prosimy o pobranie i zapisanie dokumentów na swoje potrzeby.</p>');
    //         email.setFileAttachments(new Messaging.EmailFileAttachment[]{attachment});
    //         Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    //     } catch (Exception e) {
    //         this.activeSubstep = 'System error';
    //         E2EExceptionUtils.saveExceptionData(this.account, this.opportunity, this.activeSubstep, e);
    //         E2EExceptionUtils.sendExceptionEmail(this.account, this.opportunity, this.contact, 'Mobile', 'sendTC()', e);
    //     }
    // }


    /*******************************************************************************
    *  Name            : updateOpportunityOnReturnFromEmail()
    *  Summary         : update Opportunity fields on return from marketing email
    *  CreatedDate     : 16/10/2018
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
            this.documentsService.updateOpportunityOnReturnFromEmail('Mobile');
        } else if (this.activeStep == 4) {
            this.paymentOptionsService.updateOpportunityOnReturnFromEmail('Mobile');
        } else if (this.activeStep == 5 || this.activeStep == 6) {
            this.paymentOptionsService.updateOpportunityOnReturnFromEmail('Mobile');
        }
    }


    /*****************************************************************************
    *  Name            : doDecryptParams(String encryptedParams)
    *  Summary         : do decrypt url params
    *  CreatedDate     : 16/10/2018
    *  ModifiedDate    : -
    *  Parameters      : String encryptedParams
    *  Returns         : void
    ******************************************************************************/
    private void doDecryptParams(String encryptedParams) {
        encryptedParams = encryptedParams.replaceAll('(\\s|%2B)', '+');
        if (E2EKeysAPI__c.getValues('E2EFormPL') == null ) throw new LongFormException('The link is corrupted.');
        Blob key = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EFormPL').AES256_Key__c);
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
    *  CreatedDate     : 16/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @RemoteAction
    global static void setFlagChatToOpportunity(String oppId, String activeStep, String activeSubStep, String modeOfChat) {
        if(modeOfChat != ''){
            LFChatService.setFlagChatToOpportunity(oppId, modeOfChat, Integer.valueof(activeStep), activeSubStep);
        }
    }


    /*******************************************************************************
    *  Name            : initChatSetup()
    *  Summary         : init chat setup
    *  CreatedDate     : 16/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void initChatSetup() {
        this.chatService = new LFChatService();
        this.chatService.setChatDefaultSettings('Poland');
        this.chatButtonId = this.chatService.chatButtonId;
        this.chatDeploymentId = this.chatService.chatDeploymentId;
        this.chatDeploymentJsURL = this.chatService.chatDeploymentJsURL;
        this.chatURL = this.chatService.chatURL;

        this.chatService.setPageMap('Poland');
        this.pageMapChat = chatService.getPagesMap();
    }


    /*******************************************************************************
    *  Name            : saveOfflineChatLog()
    *  Summary         : update offline chat
    *  CreatedDate     : 16/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @RemoteAction
    global static void saveOfflineChatLog(String oppId, String conId, String activeStep, String activeSubStep,  String textBody) {
        LFChatService.saveOfflineChatLog(textBody, '', Integer.valueof(activeStep), activeSubStep, 'Poland', oppId, conId);
    }


    /*******************************************************************************
    *  Name            : prepareOnlineChat()
    *  Summary         : prepare online chat
    *  CreatedDate     : 16/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void prepareOnlineChat() {
        String clientNameToChat = '';
        if (this.contact != null) {
            if (this.contact.Salutation == 'Frau') {
                clientNameToChat = ' ' + 'Pani' + ' ' + this.contact.FirstName + ' ' + this.contact.LastName;
            } else {
                clientNameToChat = ' ' + 'Panie' + ' ' + this.contact.FirstName + ' ' + this.contact.LastName;
            }
        }
        this.chatFirstMessage = this.chatService.getFirstChatMessage('Poland', this.activeStep, this.activeSubStep, clientNameToChat);
    }

    /******************************************************************************
    *  Name            : doDisabledTriggers()
    *  Summary         : disabling SF triggers
    *  CreatedDate     : 06/11/2018
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
    *  Name            : returnLinkToRedirect(Boolean redirectToMobile)
    *  Summary         : return final link to redirect
    *  CreatedDate     : 09/11/2018
    *  ModifiedDate    : -
    *  Parameters      : Boolean redirectToMobile
    *  Returns         : void
    ******************************************************************************/
    private String returnLinkToRedirect(Boolean redirectToMobile) {
        String directory;
        if (redirectToMobile) {
            directory = '/e2eformmobpl?source=';
        } else {
            directory = '/e2eformpl?source=';
        }
        Organization org = [SELECT IsSandbox, InstanceName FROM Organization LIMIT 1];
        Site site = [SELECT GuestUserId, Name, Subdomain, MasterLabel, UrlPathPrefix FROM Site WHERE Name = :'E2E' LIMIT 1];
        String url;
        if (UserInfo.getName() == 'E2E Site Guest User') {
            if (org.IsSandbox) {
                url = 'https://' + UserInfo.getUserName().substringAfterLast('.') + '-' + site.Subdomain + '.' + org.InstanceName.toLowerCase() + '.force.com' + directory;
            } else {
                url = 'https://online.fleetcor.pl' + directory;
            }
        } else {
            url = System.Url.getSalesforceBaseURL().toExternalForm() + '/apex' + directory;
        }
        return url;
    }


    /*******************************************************************************
    *  Name            : deactivateInactiveServices()
    *  Summary         : deactivate inactive e2e services when changing to another step (Reset Viewstate)
    *  CreatedDate     : 16/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void deactivateInactiveServices() {
        // if (this.activeStep == 0) {
        //     // 1 step
        //     this.cfDecision =  null;
        //     this.cfReportResponse = null;
        //     this.creditScoringService = null;
        //     this.foundCompaniesList = null;
        //     this.creditLimit = null;
        //     this.creditLimit15 = null;
        //     this.creditLimit30 = null;
        //     this.creditLimit7 = null;
        //     this.defaultBillingPeriod = null;
        //     this.deposit = null;
        //     this.deposit15 = null;
        //     this.deposit30 = null;
        //     this.deposit7 = null;
        //     this.maxCreditLimit = null;
        //     this.maxCreditLimit15 = null;
        //     this.maxCreditLimit30 = null;
        //     this.maxCreditLimit7 = null;
        //     this.maxValue = null;
        //     this.maxValue15 = null;
        //     this.maxValue30 = null;
        //     this.maxValue7 = null;
        //     this.selectedCompany = null;
        //     // 2 step
        //     this.cardsConfigService = null;
        //     this.homeOffersList = null;
        //     this.nonHomeOffersList = null;
        //     // 3 step
        //     this.additionalService = null;
        //     // 4 step
        //     this.paymentOptionsService = null;
        // } else if (this.activeStep == 1) {
        //     // 0 step
        //     this.contactDetailsService = null;
        //     // 2 step
        //     this.cardsConfigService = null;
        //     this.homeOffersList = null;
        //     this.nonHomeOffersList = null;
        //     // 3 step
        //     this.additionalService = null;
        //     // 4 step
        //     this.paymentOptionsService = null;
        // } else if (this.activeStep == 2) {
        //     // 0 step
        //     this.contactDetailsService = null;
        //     // 1 step
        //     this.cfDecision =  null;
        //     this.cfReportResponse = null;
        //     this.creditScoringService = null;
        //     this.foundCompaniesList = null;
        //     this.creditLimit = null;
        //     this.creditLimit15 = null;
        //     this.creditLimit30 = null;
        //     this.creditLimit7 = null;
        //     this.defaultBillingPeriod = null;
        //     this.deposit = null;
        //     this.deposit15 = null;
        //     this.deposit30 = null;
        //     this.deposit7 = null;
        //     this.maxCreditLimit = null;
        //     this.maxCreditLimit15 = null;
        //     this.maxCreditLimit30 = null;
        //     this.maxCreditLimit7 = null;
        //     this.maxValue = null;
        //     this.maxValue15 = null;
        //     this.maxValue30 = null;
        //     this.maxValue7 = null;
        //     this.minCreditLimit = null;
        //     // 3 step
        //     this.additionalService = null;
        //     // 4 step
        //     this.paymentOptionsService = null;
        // } else if (this.activeStep == 3) {
        //     // 0 step
        //     this.contactDetailsService = null;
        //     // 1 step
        //     this.cfDecision =  null;
        //     this.cfReportResponse = null;
        //     this.creditScoringService = null;
        //     this.foundCompaniesList = null;
        //     this.creditLimit = null;
        //     this.creditLimit15 = null;
        //     this.creditLimit30 = null;
        //     this.creditLimit7 = null;
        //     this.defaultBillingPeriod = null;
        //     this.deposit = null;
        //     this.deposit15 = null;
        //     this.deposit30 = null;
        //     this.deposit7 = null;
        //     this.maxCreditLimit = null;
        //     this.maxCreditLimit15 = null;
        //     this.maxCreditLimit30 = null;
        //     this.maxCreditLimit7 = null;
        //     this.maxValue = null;
        //     this.maxValue15 = null;
        //     this.maxValue30 = null;
        //     this.maxValue7 = null;
        //     this.minCreditLimit = null;
        //     // 4 step
        //     this.paymentOptionsService = null;
        // } else if (this.activeStep == 4 || this.activeStep == 5) {
        //     // 0 step
        //     this.contactDetailsService = null;
        //     // 1 step
        //     this.cfDecision =  null;
        //     this.cfReportResponse = null;
        //     this.creditScoringService = null;
        //     this.foundCompaniesList = null;
        //     this.creditLimit = null;
        //     this.creditLimit15 = null;
        //     this.creditLimit30 = null;
        //     this.creditLimit7 = null;
        //     this.defaultBillingPeriod = null;
        //     this.deposit = null;
        //     this.deposit15 = null;
        //     this.deposit30 = null;
        //     this.deposit7 = null;
        //     this.maxCreditLimit = null;
        //     this.maxCreditLimit15 = null;
        //     this.maxCreditLimit30 = null;
        //     this.maxCreditLimit7 = null;
        //     this.maxValue = null;
        //     this.maxValue15 = null;
        //     this.maxValue30 = null;
        //     this.maxValue7 = null;
        //     this.minCreditLimit = null;
        //     // 2 step
        //     this.cardsConfigService = null;
        //     // 3 step
        //     this.additionalService = null;
        // }
    }


    /*******************************************************************************
    *  Name            : getTransactionParameters()
    *  Summary         : return transaction parameters
    *  CreatedDate     : 16/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void getTransactionParameters() {
        if (E2EKeysAPI__c.getValues('E2EFormPL') != null) {
            this.paymentURL = E2EKeysAPI__c.getValues('E2EFormPL').paymentTransactionURL__c;
            this.paymentParameters = this.paymentOptionsService.getPaymentMap();
        }
    }
}