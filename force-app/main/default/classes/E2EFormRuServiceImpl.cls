public without sharing class E2EFormRuServiceImpl implements E2EFormRuService {

    private E2EFormRuDao e2eFormRuDao;
    private FormDataValidator formDataValidator;

    public E2EFormRuServiceImpl() {
        this.e2eFormRuDao = new E2EFormRuDaoImpl();
        this.formDataValidator = new FormDataValidator();
    }

    //******* Content Service *****//

    /*******************************************************************************
   *  Name            : getPages(String country, String stepName, Map<String, LongFormPage> pagesMap, GlobalUtils.DeviceType deviceType)
   *  Summary         : generate pages map for some Step
   *  CreatedDate     : 10/07/2018
   *  ModifiedDate    : -
   *  Parameters      : String country, String stepName, Map<String, LongFormPage> pagesMap, GlobalUtils.DeviceType deviceType
   *  Returns         : -
   ******************************************************************************/
    public void collectContent(String country, String stepName, Map<String, LongFormPage> pagesMap, GlobalUtils.DeviceType deviceType) {
        GlobalUtils.E2ERuSteps activeStep = convertToStep(stepName);
        List<String> elementsOfStep = getStepElements(activeStep);

        List<String> needLoadElements = new List<String>();
        for (String element : elementsOfStep) {
            if ( ! pagesMap.containsKey(element) ) {
                needLoadElements.add(element);
            }
        }

        Map<Id, LongForm_Page__c> longFromPages = e2eFormRuDao.getLongFormPages(country, new Set<String>(needLoadElements), deviceType.name());
        List<LongForm_Element__c> elementsList = e2eFormRuDao.getElementsListByPages(longFromPages.keySet());

        Set<Id> offerIds = new Set<Id>();
        for (LongForm_Element__c element : elementsList) {
            for (LongForm_Offer__c offer : element.LongForm_Offers__r) {
                offerIds.add(offer.Id);
            }
        }

        Map<Id, LongForm_Offer__c> offers = new Map<Id, LongForm_Offer__c>();
        offers = e2eFormRuDao.getOffersByIds(offerIds);

        Map<Id, LongForm_Fleetcor_Product__c> products = new Map<Id, LongForm_Fleetcor_Product__c>();
        products = e2eFormRuDao.getProductsByOffer(offerIds);

        Map<Id, LongForm_Tariff__c> tariffs = new Map<Id, LongForm_Tariff__c>();
        tariffs = e2eFormRuDao.getTariffsByProduct(products.keySet());

        Map<Id, LongForm_Property__c> properties = new Map<Id, LongForm_Property__c>();
        properties = e2eFormRuDao.getPropertiesByTariff(tariffs.keySet());

        for (LongForm_Element__c element : elementsList) {
            if ( ! pagesMap.containsKey(element.Long_Form_Page__r.Name) ) {
                pagesMap.put(element.Long_Form_Page__r.Name, new LongFormPage());
                pagesMap.get(element.Long_Form_Page__r.Name).pageTitle = element.Long_Form_Page__r.Title__c;
                pagesMap.get(element.Long_Form_Page__r.Name).systemError = element.Long_Form_Page__r.System_Error__c;
                pagesMap.get(element.Long_Form_Page__r.Name).elements = new Map<String, Map<String, LongForm_Element_Item__c>>();
                pagesMap.get(element.Long_Form_Page__r.Name).fields = new Map<String, LongFormField>();
            }

            if (GlobalUtils.fieldTypes.contains(element.Type__c) && ! element.Long_Form_Element_Items__r.isEmpty()) {
                LongFormField field = new LongFormField();
                field.options = new List<SelectOption>();
                field.elementItemsMap = new Map<String, LongForm_Element_Item__c>();
                for (LongForm_Element_Item__c elementItem : element.Long_Form_Element_Items__r) {
                    if (elementItem.Type__c == 'Options') {
                        elementItem.Value__c = elementItem.Value__c.deleteWhitespace();
                        elementItem.Value__c = elementItem.Value__c.replaceAll('_', ' ');
                        List<String> optionsList = elementItem.Value__c.split(';');
                        for (String option : optionsList) {
                            field.options.add(new SelectOption(option.substringBefore('=>'), option.substringAfter('=>')));
                        }
                    }
                    field.elementItemsMap.put(elementItem.Name, elementItem);
                }
                pagesMap.get(element.Long_Form_Page__r.Name).fields.put(element.Name, field);
            } else {
                if (!pagesMap.get(element.Long_Form_Page__r.Name).elements.containsKey(element.Name)) {
                    pagesMap.get(element.Long_Form_Page__r.Name).elements.put(element.Name, new Map<String, LongForm_Element_Item__c>());
                }
                for (LongForm_Element_Item__c elementItem : element.Long_Form_Element_Items__r) {
                    pagesMap.get(element.Long_Form_Page__r.Name).elements.get(element.Name).put(elementItem.Name, elementItem);
                }
            }

            // Init offers
            for (LongForm_Offer__c offer : element.LongForm_Offers__r) {

                LongFormOffer longFormOffer = new LongFormOffer();
                longFormOffer.offerName = offer.Product__c;
                longFormOffer.products = new Map<String, LongFormProduct>();

                if (pagesMap.get(element.Long_Form_Page__r.Name).fields.get(element.Name).offers == null) {
                    pagesMap.get(element.Long_Form_Page__r.Name).fields.get(element.Name).offers = new Map<String, LongFormOffer>();
                }
                pagesMap.get(element.Long_Form_Page__r.Name).fields.get(element.Name).offers.put(offer.Product__c, longFormOffer);

                LongForm_Offer__c offerWithAllParameters = offers.get(offer.Id); // get offer with all filled fields
                for (LongForm_Fleetcor_Product__c productItem : offerWithAllParameters.Long_Form_Fleetcor_Products__r) {

                    LongFormProduct longFormProduct = new LongFormProduct();
                    longFormProduct.productName = productItem.Name;
                    longFormProduct.productLabel = productItem.Label__c;
                    longFormProduct.tariffs = new Map<String, LongFormTariff>();
                    longFormProduct.productProperties = new Map<String, LongFormTariffProperty>();

                    // put products to offer
                    longFormOffer.products.put(productItem.Name, longFormProduct);

                    LongForm_Fleetcor_Product__c productWithAllParameters = products.get(productItem.Id); // get product with all filled fields
                    for (LongForm_Tariff__c tariffItem : productWithAllParameters.LongForm_Tariffs__r) {

                        LongFormTariff longFormTariff = new LongFormTariff();
                        longFormTariff.tariffName = tariffItem.Name;
                        longFormTariff.tariffLabel = tariffItem.Label__c;
                        if (longFormTariff.properties == null) {
                            longFormTariff.properties = new Map<String, LongFormTariffProperty>();
                        }

                        // put tariff to product
                        longFormProduct.tariffs.put(tariffItem.Name, longFormTariff);

                        LongForm_Tariff__c tariffWithAllParameters = tariffs.get(tariffItem.Id); // get tariff with all filled fields
                        for (LongForm_Property__c propItem : tariffWithAllParameters.LongForm_Properties__r) {

                            LongForm_Property__c propertyWithAllParameters = properties.get(propItem.Id);
                            LongFormTariffProperty tariffProperty = new LongFormTariffProperty();
                            tariffProperty.propertyName = propertyWithAllParameters.Name;
                            tariffProperty.propertyValue = propertyWithAllParameters.Value__c;
                            tariffProperty.propertyPopup = propertyWithAllParameters.Popup__c;
                            tariffProperty.propertyItems = propertyWithAllParameters.LongForm_Property_Items__r;
                            tariffProperty.propertyItems.sort();
                            longFormTariff.properties.put(propertyWithAllParameters.Name, tariffProperty);
                            longFormProduct.productProperties.put(tariffProperty.propertyName, tariffProperty);
                        }
                    }

                    for (String keyItem : longFormProduct.productProperties.keySet()) {
                        LongFormTariffProperty property = longFormProduct.productProperties.get(keyItem);
                        property.propertyTariffs = longFormProduct.tariffs;


                        for (LongFormTariff tariff : longFormProduct.tariffs.values()) {
                            if( ! tariff.properties.containsKey(keyItem) ) {
                                LongFormTariffProperty tariffProperty = new LongFormTariffProperty();
                                tariffProperty.propertyName = property.propertyName;
                                tariffProperty.propertyValue = property.propertyValue;
                                tariffProperty.propertyPopup = property.propertyPopup;
                                tariffProperty.propertyItems = new List<LongForm_Property_Item__c>();
                                tariffProperty.propertyItems.add(new LongForm_Property_Item__c(Name = '', Value__c = '-'));
                                tariff.properties.put(tariffProperty.propertyName, tariffProperty);
                            }
                        }

                    }
                }
            }
        }

    }

    public void collectSharedResource(String country, Map<String, LongFormPage> pagesMap, GlobalUtils.DeviceType deviceType, String source) {
        String sharedStep = 'SHARED RESOURCES';

        List<String> needLoadElements = new List<String>();
        needLoadElements.add(sharedStep);

        Map<Id, LongForm_Page__c> longFromPages = e2eFormRuDao.getSharedResources(country, new Set<String>(needLoadElements), deviceType.name());
        List<LongForm_Element__c> elementsList = new List<LongForm_Element__c>();

        boolean isInList = false;

        System.debug('Source ' + source);

        for (LongForm_Element__c item : e2eFormRuDao.getElementsListByPages(longFromPages.keySet())) {
            if (item.Name.startsWith(source.toUpperCase())) {
                System.debug('Item ' + item.Name);
                item.Name  = item.Name.split(' ')[1].trim();
                isInList = true;
            }
        }

        if(!isInList) source = 'petrolplus';

        for (LongForm_Element__c item : e2eFormRuDao.getElementsListByPages(longFromPages.keySet())) {
            if (item.Name.contains('HEADERS')) {
                if (item.Name.startsWith(source.toUpperCase())) {
                    item.Name = item.Name.split(' ')[1].trim();
                    elementsList.add(item);
                }
            } else {
                System.debug(item.Name);
                elementsList.add(item);
            }
        }

        for (LongForm_Element__c element : elementsList) {

            if (!pagesMap.containsKey(element.Long_Form_Page__r.Name)) {
                pagesMap.put(element.Long_Form_Page__r.Name, new LongFormPage());
                pagesMap.get(element.Long_Form_Page__r.Name).pageTitle = element.Long_Form_Page__r.Title__c;
                pagesMap.get(element.Long_Form_Page__r.Name).systemError = element.Long_Form_Page__r.System_Error__c;
                pagesMap.get(element.Long_Form_Page__r.Name).elements = new Map<String, Map<String, LongForm_Element_Item__c>>();
                pagesMap.get(element.Long_Form_Page__r.Name).fields = new Map<String, LongFormField>();
            }

            if (GlobalUtils.fieldTypes.contains(element.Type__c) && !element.Long_Form_Element_Items__r.isEmpty()) {
                LongFormField field = new LongFormField();
                field.options = new List<SelectOption>();
                field.elementItemsMap = new Map<String, LongForm_Element_Item__c>();
                for (LongForm_Element_Item__c elementItem : element.Long_Form_Element_Items__r) {
                    if (elementItem.Type__c == 'Options') {
                        elementItem.Value__c = elementItem.Value__c.deleteWhitespace();
                        elementItem.Value__c = elementItem.Value__c.replaceAll('_', ' ');
                        List<String> optionsList = elementItem.Value__c.split(';');
                        for (String option : optionsList) {
                            field.options.add(new SelectOption(option.substringBefore('=>'), option.substringAfter('=>')));
                        }
                    }
                    field.elementItemsMap.put(elementItem.Name, elementItem);
                }
                pagesMap.get(element.Long_Form_Page__r.Name).fields.put(element.Name, field);
            } else {
                if (!pagesMap.get(element.Long_Form_Page__r.Name).elements.containsKey(element.Name)) {
                    pagesMap.get(element.Long_Form_Page__r.Name).elements.put(element.Name, new Map<String, LongForm_Element_Item__c>());
                }
                for (LongForm_Element_Item__c elementItem : element.Long_Form_Element_Items__r) {
                    pagesMap.get(element.Long_Form_Page__r.Name).elements.get(element.Name).put(elementItem.Name, elementItem);
                }
            }
        }

    }

    public void collectContentDataByLink(Id formDataId, String stepName, Map<String, LongFormPage> pagesMap, E2EFormParams formParams, Map<String, LongFormTariff> msl_suffix, Map<String, String> objectIds) {
        GlobalUtils.E2ERuSteps activeStep = convertToStep(stepName);
        E2EFormData__c formDataRecord = this.e2eFormRuDao.getFormDataById(formDataId);
        Account account = this.e2eFormRuDao.getAccountById(formDataRecord.E2E_Account_Id__c);
        Contact contact = this.e2eFormRuDao.getContactById(formDataRecord.E2E_Contact_Id__c);
        Opportunity opportunity = e2eFormRuDao.getOpportunityById(formDataRecord.E2E_Opportunity_Id__c);

        objectIds.put('accountId', account.Id);
        objectIds.put('contactId', contact.Id);
        objectIds.put('opportunityId', opportunity.Id);

        List<String> stepsList = getStepElements(activeStep);
        if ( ! stepsList.isEmpty() ) {
            for (String step : stepsList) {

                if (step == GlobalUtils.getE2ERuStep(GlobalUtils.E2ERuSteps.ContactDetails.name()).get(0)) {
                    // STEP CONTACT DETAILS

                    String offer = '';
                    String source = '';
                    String product = '';

                    if (formDataRecord.E2E_Product_Id__c != null && formDataRecord.E2E_Source__c != null && formDataRecord.E2E_Offer__c != null) {
                        offer = formDataRecord.E2E_Offer__c;
                        source = formDataRecord.E2E_Source__c;
                        product = formDataRecord.E2E_Product_Id__c;
                    } else {
                        offer = GlobalUtils.E2ESource.PetrolPlus.name();
                        source = GlobalUtils.E2ESource.PetrolPlus.name();
                        product = GlobalUtils.E2EProduct.PetrolPlus_Rover.name();
                    }

                    // set offer
                    formParams.offer = offer;

                    // set product
                    formParams.product = product;

                    // set source
                    formParams.source = source;


                    pagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c = contact.MobilePhone;
                    pagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = contact.Email;
                    pagesMap.get('CONTACT DETAILS').fields.get('MARKETING DISPATCH').elementItemsMap.get('DEFAULT VALUE').Value__c = String.valueOf(contact.Agree_to_receive_comm_info_by_email__c);
                    pagesMap.get('CONTACT DETAILS').fields.get('PERSONAL INFORMATION').elementItemsMap.get('DEFAULT VALUE').Value__c = String.valueOf(contact.Agree_to_process_pers_data_for_marketing__c);

                    formParams.source = formDataRecord.E2E_Source__c;
                    formParams.sourcePP = opportunity.Source_PP__c;

                } else if (step == GlobalUtils.getE2ERuStep(GlobalUtils.E2ERuSteps.CompanyInformation.name()).get(0)) {
                    pagesMap.get('COMPANY INFORMATION').fields.get('ACCOUNT NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = account.Name;
                    pagesMap.get('COMPANY INFORMATION').fields.get('INN').elementItemsMap.get('DEFAULT VALUE').Value__c = account.INN__c;
                    pagesMap.get('COMPANY INFORMATION').fields.get('IS MANUAL ENTRY').elementItemsMap.get('DEFAULT VALUE').Value__c = String.valueOf(formDataRecord.E2E_Manual_Entry__c);

                    formParams.okpoSpark = formDataRecord.E2E_OKPO__c;
                    formParams.kppSpark = formDataRecord.E2E_KPP__c;

                    if (formDataRecord.E2E_Manual_Entry__c == true) {
                        formParams.sendToInbound = true;
                    }

                    if(formDataRecord.E2E_Spark_Id__c != null) {
                        formParams.sparkId = Decimal.valueOf(formDataRecord.E2E_Spark_Id__c);
                    }
                    formParams.mainCompanyFullNameSpark = formDataRecord.E2E_Main_Company_Full_Name__c;
                    formParams.postCodeSpark = formDataRecord.E2E_Billing_Code__c;
                    formParams.regionSpark = formDataRecord.E2E_Billing_State__c;
                    formParams.citySpark = formDataRecord.E2E_Billing_City__c;
                    formParams.streetSpark = formDataRecord.E2E_Billing_Str__c;
                    formParams.buildingSpark = formDataRecord.E2E_Billing_House__c;
                    formParams.housingSpark = formDataRecord.E2E_Billing_Apartment__c;
                    formParams.blockSpark = '';
                    formParams.roomSpark = '';
                    formParams.legalAddressSpark = formDataRecord.E2E_Legal_Address__c;
                    formParams.legalAddressAdditionally = formDataRecord.E2E_Billing_Apartment__c;
                    formParams.postalAddress = formDataRecord.E2E_Post_Address__c;
                    formParams.postalAddressAdditionally = formDataRecord.E2E_Shipping_Apartment__c;
                    formParams.verifiedDecisionCode = formDataRecord.E2E_Black_List_Code__c;
                    formParams.verifiedDecision = formDataRecord.E2E_Black_List__c;
                    formParams.verifiedLimitation =  formDataRecord.E2E_Black_List_Limitations__c;
                    formParams.scoringDecisionCode = formDataRecord.E2E_Scoring_Decision_Code__c;
                    formParams.scoringDecision = formDataRecord.E2E_Scoring_Decision__c;
                    formParams.scoringDate = formDataRecord.E2E_Scoring_Date__c;

                    if (account.Organization_Type__c == 'ИП') {
                        formParams.ogrnipSpark = account.OGRN_ppr__c;
                        formParams.isSoleProprietor = true;
                        List<String> executivePersonData = parserExecutivePerson(formDataRecord.E2E_Executive_Person__c);
                        formParams.soleProprietorFio = executivePersonData.get(0);
                        formParams.executivePosition = executivePersonData.get(1);
                    } else {
                        formParams.ogrnSpark = account.OGRN_ppr__c;
                        formParams.isSoleProprietor = false;
                        List<String> executivePersonData = parserExecutivePerson(formDataRecord.E2E_Executive_Person__c);
                            formParams.executiveFio = executivePersonData.get(0);
                            formParams.executivePosition = executivePersonData.get(1);
                        if(executivePersonData.get(0) != '' && executivePersonData.get(1) != ''){
                            formParams.executiveId = createEmployeeContact(account.Id, formParams.executiveFio, formParams.executivePosition);
                        }
                    }

                    // if position does not exist, send to Inbound
                    if (formParams.executivePosition == null || formParams.executivePosition == '') {
                        formParams.sendToInbound = true;
                    }

                } else if (step == GlobalUtils.getE2ERuStep(GlobalUtils.E2ERuSteps.Order.name()).get(0)) {
                    // STEP ORDER
                    pagesMap.get('ORDER').fields.get('AMOUNT CARD').elementItemsMap.get('DEFAULT VALUE').Value__c = String.valueOf(formDataRecord.E2E_Num_Cards__c);
                    pagesMap.get('ORDER').fields.get('PROMOCODE').elementItemsMap.get('DEFAULT VALUE').Value__c = formDataRecord.E2E_Promo_Campaign__c;
                    pagesMap.get('ORDER').fields.get('PAYMENT CONDITIONS').elementItemsMap.get('DEFAULT VALUE').Value__c = formDataRecord.E2E_Payment_Condition__c;
                    pagesMap.get('ORDER').fields.get('PERSONAL MANAGER').elementItemsMap.get('DEFAULT VALUE').Value__c = String.valueOf(formDataRecord.E2E_Personal_Manager_srv__c);
                    pagesMap.get('ORDER').fields.get('DOCS DELIVERY').elementItemsMap.get('DEFAULT VALUE').Value__c = String.valueOf(formDataRecord.E2E_Document_Delivery_srv__c);
                    pagesMap.get('ORDER').fields.get('PAY OVERDRAFT').elementItemsMap.get('DEFAULT VALUE').Value__c = String.valueOf(formDataRecord.E2E_Overdraft_srv__c);

                    // check amount cards
                    Integer numberOfCards = Integer.valueOf(E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu').Number_of_Cards__c);
                    if (formDataRecord.E2E_Num_Cards__c > numberOfCards) {
                        formParams.sendToInbound = true;
                    }

                    String offer = '';
                    String source = '';
                    String product = '';
                    if (formDataRecord.E2E_Product_Id__c != null && formDataRecord.E2E_Tariff_Id__c != null && formDataRecord.E2E_Source__c != null && formDataRecord.E2E_Offer__c != null) {
                        offer = formDataRecord.E2E_Offer__c;
                        source = formDataRecord.E2E_Source__c;
                        product = formDataRecord.E2E_Product_Id__c;
                        formParams.product = formDataRecord.E2E_Product_Id__c;
                        pagesMap.get('ORDER').fields.get('PRODUCTS').elementItemsMap.get('ID').Value__c = formDataRecord.E2E_Product_Id__c;
                        pagesMap.get('ORDER').fields.get('PRODUCT TARIFF').elementItemsMap.get('TARIFF ID').Value__c = formDataRecord.E2E_Tariff_Id__c;
                        System.debug('INIT OK' + formDataRecord.E2E_Tariff_Id__c);
                    } else {
                        offer = GlobalUtils.E2ESource.PetrolPlus.name();
                        source = GlobalUtils.E2ESource.PetrolPlus.name();
                        product = GlobalUtils.E2EProduct.PetrolPlus_Rover.name();
                        formParams.product = GlobalUtils.E2EProduct.PetrolPlus_Rover.name();
                        pagesMap.get('ORDER').fields.get('PRODUCTS').elementItemsMap.get('ID').Value__c = GlobalUtils.E2EProduct.PetrolPlus_Rover.name();
                        pagesMap.get('ORDER').fields.get('PRODUCT TARIFF').elementItemsMap.get('TARIFF ID').Value__c = '1OPTIMAL_CARDS';
                    }

                    // set offer
                    formParams.offer = offer;

                    // set product
                    formParams.product = product;

                    // set source
                    formParams.source = source;

                    setAZSLocatorLink(product, pagesMap);
                    if(formDataRecord.E2E_Promo_Campaign__c != null){
                        formParams.promoCode = formDataRecord.E2E_Promo_Campaign__c;
                        getPromocode(formDataRecord.E2E_Promo_Campaign__c, pagesMap, formParams);
                    }

                    pagesMap.get('ORDER').fields.get('PRODUCTS').elementItemsMap.get('DEFAULT VALUE').Value__c = pagesMap.get('ORDER').fields.get('PRODUCTS').offers.get(offer).products.get(product).productLabel;
                    pagesMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE ADDITIONAL FIELD').Value__c = '';

                    // Init tariffs
                    Map<String, LongFormTariff> msl = pagesMap.get('ORDER').fields.get('PRODUCTS').offers.get(offer).products.get(product).tariffs;
                    System.debug('msl **');
                    System.debug(msl);

                    String suffix = null;
                    if (pagesMap.get('ORDER').fields.get('PRODUCTS').offers.get(offer).products.get(product).tariffs.size() == 2){
                        formParams.numberOfTariffsDependency = '999';
                        if(formParams.product == 'PetrolPlus_Gaz'){
                            pagesMap.get('ORDER').fields.get('PRODUCT TARIFF').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Тариф 2';
                            pagesMap.get('ORDER').fields.get('PRODUCT TARIFF').elementItemsMap.get('TARIFF ID').Value__c = '2CONTRACT_CARDS';
                        }
                        if(formParams.product == 'Partner_Rover'){
                            pagesMap.get('ORDER').fields.get('PRODUCT TARIFF').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Оптимальный Договор';
                            pagesMap.get('ORDER').fields.get('PRODUCT TARIFF').elementItemsMap.get('TARIFF ID').Value__c = '2CONTRACT_CARDS';
                        }

                        suffix = '_CARDS';
                    } else {
                        formParams.numberOfTariffsDependency = '5';
                        pagesMap.get('ORDER').fields.get('PRODUCT TARIFF').elementItemsMap.get('DEFAULT VALUE').Value__c = 'Избранный';
                        pagesMap.get('ORDER').fields.get('PRODUCT TARIFF').elementItemsMap.get('TARIFF ID').Value__c = '2CHOOSEN_CONTRACT';
                        suffix = '_CONTRACT';
                    }

                    msl_suffix.clear();
                    for (String lft : msl.keySet()) {
                        if (lft.indexOf(suffix) != -1) {
                            msl_suffix.put(lft, msl.get(lft));
                        }
                    }
                    System.debug(msl_suffix);
                    pagesMap.get('ORDER').fields.get('PROMOCODE').elementItemsMap.get('WARN MESSAGE').Value__c = '';

                } else if (step == GlobalUtils.getE2ERuStep(GlobalUtils.E2ERuSteps.LegalDetails.name()).get(0)) {
                    // STEP LegalDetails
                    pagesMap.get('LEGAL DETAILS').fields.get('OGRN').elementItemsMap.get('DEFAULT VALUE').Value__c = account.OGRN_ppr__c;
                    pagesMap.get('LEGAL DETAILS').fields.get('OGRNIP').elementItemsMap.get('DEFAULT VALUE').Value__c = account.OGRN_ppr__c;
                    pagesMap.get('LEGAL DETAILS').fields.get('KPP').elementItemsMap.get('DEFAULT VALUE').Value__c = String.valueOf(account.KPP__c);
                    pagesMap.get('LEGAL DETAILS').fields.get('OKPO').elementItemsMap.get('DEFAULT VALUE').Value__c = account.OKPO_ppr__c;
                    pagesMap.get('LEGAL DETAILS').fields.get('CODE WORD').elementItemsMap.get('DEFAULT VALUE').Value__c = account.Code_Word__c;

                    // Legal address
                    pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = formDataRecord.E2E_Legal_Address__c;
                    pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('COUNTRY').Value__c = account.BillingCountry;
                    pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('STATE').Value__c = account.Region__c;
                    pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('CITY').Value__c = account.BillingCity;
                    pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('STREET').Value__c = formDataRecord.E2E_Billing_Str__c;
                    pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('HOUSE NUMBER').Value__c = formDataRecord.E2E_Billing_House__c;
                    pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('POSTAL CODE').Value__c = account.BillingPostalCode;
                    pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS ADDITIONALLY').elementItemsMap.get('DEFAULT VALUE').Value__c = formDataRecord.E2E_Billing_Apartment__c;

                    // Postal address
                    pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = formDataRecord.E2E_Post_Address__c;
                    pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('COUNTRY').Value__c = account.ShippingCountry;
                    pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('STATE').Value__c = formDataRecord.E2E_Shipping_State__c;
                    pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('CITY').Value__c = account.ShippingCity;
                    pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('STREET').Value__c = formDataRecord.E2E_Shipping_Str__c;
                    pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('HOUSE NUMBER').Value__c = formDataRecord.E2E_Shipping_House__c;
                    pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('POSTAL CODE').Value__c = account.ShippingPostalCode;
                    pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS ADDITIONALLY').elementItemsMap.get('DEFAULT VALUE').Value__c = formDataRecord.E2E_Shipping_Apartment__c;

                    // set TRUE if Legal Address matches to Postal Address
                    if (formDataRecord.E2E_Legal_Address__c == formDataRecord.E2E_Post_Address__c && account.BillingCountry == account.ShippingCountry
                            && account.Region__c == formDataRecord.E2E_Shipping_State__c && account.BillingCity == account.ShippingCity
                            && formDataRecord.E2E_Billing_Str__c == formDataRecord.E2E_Shipping_Str__c && formDataRecord.E2E_Billing_House__c == formDataRecord.E2E_Shipping_House__c
                            && account.BillingPostalCode == account.ShippingPostalCode && formDataRecord.E2E_Billing_Apartment__c == formDataRecord.E2E_Shipping_Apartment__c) {
                        pagesMap.get('LEGAL DETAILS').fields.get('MATCHES LEGAL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c = 'TRUE';
                    }

                    String executiveFioWithPosition = formDataRecord.E2E_Executive_Person__c;
                    List<String> executiveProperties = executiveFioWithPosition.split(',');
                    if (executiveProperties != null && executiveProperties.size() == 2) {
                        pagesMap.get('LEGAL DETAILS').fields.get('EXECUTIVE PERSON').elementItemsMap.get('DEFAULT VALUE').Value__c = executiveProperties.get(0);
                        pagesMap.get('LEGAL DETAILS').fields.get('EXECUTIVE PERSON POSITION').elementItemsMap.get('DEFAULT VALUE').Value__c = executiveProperties.get(1);
                    } else if(executiveProperties != null && executiveProperties.size() == 1) {
                        pagesMap.get('LEGAL DETAILS').fields.get('EXECUTIVE PERSON').elementItemsMap.get('DEFAULT VALUE').Value__c = executiveProperties.get(0);
                        pagesMap.get('LEGAL DETAILS').fields.get('EXECUTIVE PERSON POSITION').elementItemsMap.get('DEFAULT VALUE').Value__c = '';
                    } else {
                        pagesMap.get('LEGAL DETAILS').fields.get('EXECUTIVE PERSON').elementItemsMap.get('DEFAULT VALUE').Value__c = '';
                        pagesMap.get('LEGAL DETAILS').fields.get('EXECUTIVE PERSON POSITION').elementItemsMap.get('DEFAULT VALUE').Value__c = '';
                    }

                    pagesMap.get('LEGAL DETAILS').fields.get('CHIEF ACCOUNTANT').elementItemsMap.get('DEFAULT VALUE').Value__c = formDataRecord.E2E_Chief_Accountant__c;
                    pagesMap.get('LEGAL DETAILS').fields.get('USER ACCOUNT EMAIL').elementItemsMap.get('DEFAULT VALUE').Value__c = formDataRecord.E2E_Personal_Office_Email__c;
                    pagesMap.get('LEGAL DETAILS').fields.get('CARDS DELIVERY INFORMATION').elementItemsMap.get('DEFAULT VALUE').Value__c = formDataRecord.E2E_Courier_Comments__c;

                    // check manual entry
                    if (formDataRecord.E2E_Manual_Entry_Legal_Info__c == true) {
                        formParams.sendToInbound = true;
                    }

                } else if (step == GlobalUtils.getE2ERuStep(GlobalUtils.E2ERuSteps.PaymentDetails.name()).get(0)) {
                    // STEP PaymentDetails
                    pagesMap.get('PAYMENT DETAILS').fields.get('CHECKING ACCOUNT').elementItemsMap.get('DEFAULT VALUE').Value__c = account.Checking_Account__c;
                    pagesMap.get('PAYMENT DETAILS').fields.get('BANK NAME').elementItemsMap.get('DEFAULT VALUE').Value__c = account.Bank__c;
                    pagesMap.get('PAYMENT DETAILS').fields.get('BIC').elementItemsMap.get('DEFAULT VALUE').Value__c = account.SWIFT_BIC__c;
                    pagesMap.get('PAYMENT DETAILS').fields.get('CORR BANK ACCOUNT').elementItemsMap.get('DEFAULT VALUE').Value__c = account.Cor_Bank_Account__c;
                    pagesMap.get('PAYMENT DETAILS').fields.get('PREPAYMENT AMOUNT').elementItemsMap.get('DEFAULT VALUE').Value__c = formDataRecord.E2E_Prepay_Amount__c;

                    formParams.bankAddress = formDataRecord.E2E_Bank_Address__c;
                    formParams.bankNameShort = formDataRecord.E2E_Bank_Name_Short__c;
                    formParams.bankOkpo = formDataRecord.E2E_Bank_OKPO__c;
                    formParams.bankTown = formDataRecord.E2E_Bank_Town__c;
                }
            }
        }
    }

    /*******************************************************************************
    *  Name            : setAZSLocatorLink()
    *  Summary         : setAZSLocatorLink
    *  CreatedDate     : 28/09/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void setAZSLocatorLink(String locator, Map<String, LongFormPage> pagesMap) {
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
        Matcher m = p.matcher(pagesMap.get('ORDER').fields.get('GIFT LIST').elementItemsMap.get('LIST').Value__c);
        while (m.find()) {
            System.debug(m.group(1));
            prevHrefValue = m.group(1);
        }
        pagesMap.get('ORDER').fields.get('GIFT LIST').elementItemsMap.get('LIST').Value__c = pagesMap.get('ORDER').fields.get('GIFT LIST').elementItemsMap.get('LIST').Value__c.replace(prevHrefValue, linkLocator);
    }


    public void getPromocode(String promocode, Map<String, LongFormPage> pagesMap, E2EFormParams formParams) {
        String productName = pagesMap.get('ORDER').fields.get('PRODUCTS').elementItemsMap.get('DEFAULT VALUE').Value__c;
        pagesMap.get('ORDER').fields.get('PROMOCODE').elementItemsMap.get('WARN MESSAGE').Value__c = '';
        if (promocode != null && !promocode.equals('')) {
            E2E_Promocodes__c promocodeObject = E2E_Promocodes__c.getValues(promocode);
            if (promocodeObject != null) {
                if (promocodeObject.Product_Name__c != productName) {
                    pagesMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE INVALID').Value__c = 'Данная акция действует только при заказе карт ' + promocodeObject.Product_Name__c;
                    pagesMap.get('ORDER').fields.get('PROMOCODE').elementItemsMap.get('WARN MESSAGE').Value__c = 'Данная акция действует только при заказе карт ' + promocodeObject.Product_Name__c;
                    pagesMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE VALUE').Value__c = '';
                    pagesMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE LABEL').Value__c = '';
                    pagesMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE DESCRIPTION TITLE').Value__c = '';
                    pagesMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE DESCRIPTION BODY').Value__c = '';
                    pagesMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE ADDITIONAL FIELD').Value__c = '';
                    pagesMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE CHOOSEN FIELD').Value__c = '';
                } else {
                    pagesMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE VALUE').Value__c = promocodeObject.Name;
                    pagesMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE LABEL').Value__c = String.format(promocodeObject.Promocode_Label__c, new List<String>{GlobalUtils.getE2ERuPartner(formParams.source)});
                    pagesMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE DESCRIPTION TITLE').Value__c = promocodeObject.Promocode_Description_Title__c;
                    pagesMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE DESCRIPTION BODY').Value__c = promocodeObject.Promocode_Description_Body__c;
                    if (promocodeObject.Promocode_Additional_Field__c == null || promocodeObject.Supplier_Selection__c == 'False') {
                        pagesMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE ADDITIONAL FIELD').Value__c = '';
                        pagesMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE CHOOSEN FIELD').Value__c = '';
                    } else {
                        String dropdownList = promocodeObject.Promocode_Additional_Field__c;
                        pagesMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE ADDITIONAL FIELD').Value__c = dropdownList;
                        pagesMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE CHOOSEN FIELD').Value__c = dropdownList.split(';')[0].split('@')[0];

                        String listPromocodeItems = pagesMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE ADDITIONAL FIELD').Value__c;
                        Map<String, String> supplies = new Map<String, String>();
                        for (String val : listPromocodeItems.split(';')) {
                            supplies.put(val.split('@')[0], val.split('@')[1]);
                        }
                        String idPromocodeItem = supplies.get(pagesMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE CHOOSEN FIELD').Value__c);
                        formParams.promocodeIdInTransit = idPromocodeItem;
                    }

                    pagesMap.get('ORDER').fields.get('PROMOCODE').elementItemsMap.get('WARN MESSAGE').Value__c = '';
                    pagesMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE INVALID').Value__c = '';
                    System.debug(pagesMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE ADDITIONAL FIELD').Value__c);

                    formParams.promocodeName = promocodeObject.Name;
                }
            } else {
                pagesMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE INVALID').Value__c = 'Промокод недействителен';
                pagesMap.get('ORDER').fields.get('PROMOCODE').elementItemsMap.get('WARN MESSAGE').Value__c = 'Промокод недействителен';
                pagesMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE VALUE').Value__c = '';
                pagesMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE LABEL').Value__c = '';
                pagesMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE DESCRIPTION TITLE').Value__c = '';
                pagesMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE DESCRIPTION BODY').Value__c = '';
                pagesMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE ADDITIONAL FIELD').Value__c = '';
                pagesMap.get('ORDER').fields.get('PROMOCODE DESCRIPTION').elementItemsMap.get('PROMOCODE CHOOSEN FIELD').Value__c = '';
            }
        }
    }

    /*******************************************************************************
    *  Name            : parserExecutivePerson(String executivePerson)
    *  Summary         : parser executive person information
    *  CreatedDate     : 01/11/2018
    *  ModifiedDate    : -
    *  Parameters      : String executivePerson
    *  Returns         : List<String> (1. executiveFio 2. executivePosition)
    ******************************************************************************/
    public List<String> parserExecutivePerson(String executivePerson) {
        String executiveFio = '';
        String executivePosition = '';
        if(executivePerson != null){
            String executiveFioWithPosition = executivePerson;
            List<String> executiveProperties = executiveFioWithPosition.split(',');
            if (executiveProperties != null && executiveProperties.size() == 2) {
                executiveFio = executiveProperties.get(0);
                executivePosition = executiveProperties.get(1);
            } else if(executiveProperties != null && executiveProperties.size() == 1) {
                executiveFio = executiveProperties.get(0);
                executivePosition = '';
            }
        } else {
            executiveFio = '';
            executivePosition = '';
        }
        return new List<String>{executiveFio, executivePosition};
    }

    //******* Account Service *****//

    /*******************************************************************************
   *  Name            : createAccount(Map<String, LongFormPage> pagesMap, E2EFormParams formParams)
   *  Summary         : create account
   *  CreatedDate     : 12/07/2018
   *  ModifiedDate    : -
   *  Parameters      : Map<String, LongFormPage> pagesMap
   *  Returns         : created account id
   ******************************************************************************/
    public Id createAccount(E2EFormParams formParams) {
        // New account
        Account account = new Account(
                RecordTypeId = GlobalUtils.getRecordTypeId('Account', 'Russian'),
                Name = 'E2E Account ' + Datetime.now().format('yyyyMMddHHmmss'),
                BillingCountry = GlobalUtils.FleetcorCountries.Russia.name(),
                ShippingCountry = GlobalUtils.FleetcorCountries.Russia.name(),
                Type = 'Customer',
                AccountSource = 'E2E Form RU',
                Utm_campaign__c = formParams.utmCampaign,
                Utm_content__c = formParams.utmContent,
                Utm_medium__c = formParams.utmMedium,
                Utm_source__c = formParams.utmSource,
                Utm_term__c = formParams.utmTerm,
                Utm_url__c = formParams.utmUrl
        );
        return this.e2eFormRuDao.createAccount(account);
    }

    /*******************************************************************************
   *  Name            : updateAccount(Id accountId, Map<String, LongFormPage> pagesMap, E2EFormParams formParams, String step)
   *  Summary         : update account
   *  CreatedDate     : 12/07/2018
   *  ModifiedDate    : -
   *  Parameters      : Id accountId, Map<String, LongFormPage> pagesMap, E2EFormParams formParams, String step
   *  Returns         : -
   ******************************************************************************/
    public void updateAccount(Id accountId, Map<String, LongFormPage> pagesMap, E2EFormParams formParams, String step) {
        GlobalUtils.E2ERuSteps activeStep = convertToStep(step);
        Account account = new Account(Id = accountId);
        if (activeStep == GlobalUtils.E2ERuSteps.CompanyInformation) {
            String accountName = pagesMap.get('COMPANY INFORMATION').fields.get('ACCOUNT NAME').elementItemsMap.get('DEFAULT VALUE').Value__c;
            String INN = pagesMap.get('COMPANY INFORMATION').fields.get('INN').elementItemsMap.get('DEFAULT VALUE').Value__c;
            Boolean isEntryManual = Boolean.valueOf(pagesMap.get('COMPANY INFORMATION').fields.get('IS MANUAL ENTRY').elementItemsMap.get('DEFAULT VALUE').Value__c);

            this.formDataValidator.validateAccountNameField(accountName);
            if (!isEntryManual){
                this.formDataValidator.validateInnField(INN);
            }

            account.Name = GlobalUtils.blankStringIfNull(accountName);
            if( formParams.verifiedDecisionCode != '4' ){ // костыль чтобы не сохранять INN
                account.INN__c = GlobalUtils.blankStringIfNull(INN);
            }

            // Save Address
            account.BillingPostalCode = GlobalUtils.blankStringIfNull(formParams.postCodeSpark);
            account.BillingCity = GlobalUtils.blankStringIfNull(formParams.citySpark);
            String street = formParams.streetSpark == null ? '' : GlobalUtils.blankStringIfNull(formParams.streetSpark);
            String building = formParams.buildingSpark == null ? '' : ', ' + GlobalUtils.blankStringIfNull(formParams.buildingSpark);
            String housing = formParams.housingSpark == null ? '' : ', ' +  GlobalUtils.blankStringIfNull(formParams.housingSpark);
            String block = formParams.blockSpark == null ? '' : ', ' +  GlobalUtils.blankStringIfNull(formParams.blockSpark);
            String room = formParams.roomSpark == null ? '' : ', ' +  GlobalUtils.blankStringIfNull(formParams.roomSpark);
            account.BillingStreet = street + building + housing + block + room;
            account.Region__c = GlobalUtils.blankStringIfNull(formParams.regionSpark);

            // Save OKPO
            account.OKPO_ppr__c = formParams.okpoSpark;

            // Save OGRN, KPP, Organization Type
            if (formParams.isSoleProprietor == true) {
                account.OGRN_ppr__c = formParams.ogrnipSpark;
                account.Organization_Type__c = 'ИП';
            } else {
                account.OGRN_ppr__c = formParams.ogrnSpark;
                String KPP = formParams.kppSpark;
                account.KPP__c = (KPP == '' || KPP == null) ? 0 : Decimal.valueOf(KPP);
                account.Organization_Type__c = GlobalUtils.parseNormNameForOrganization(formParams.normName).get(1);
            }

            // Update
            this.e2eFormRuDao.updateAccount(account);
        } else if (activeStep == GlobalUtils.E2ERuSteps.LegalDetails) {

            if(formParams.isSoleProprietor){
                String OGRNIP = pagesMap.get('LEGAL DETAILS').fields.get('OGRNIP').elementItemsMap.get('DEFAULT VALUE').Value__c;
                this.formDataValidator.validatePSRNField(OGRNIP);
                account.OGRN_ppr__c = GlobalUtils.blankStringIfNull(OGRNIP);
            } else {
                String OGRN = pagesMap.get('LEGAL DETAILS').fields.get('OGRN').elementItemsMap.get('DEFAULT VALUE').Value__c;
                String KPP = pagesMap.get('LEGAL DETAILS').fields.get('KPP').elementItemsMap.get('DEFAULT VALUE').Value__c;
                this.formDataValidator.validatePSRNField(OGRN);
                this.formDataValidator.validateKPPField(KPP);
                account.OGRN_ppr__c = GlobalUtils.blankStringIfNull(OGRN);
                account.KPP__c = Decimal.valueOf(KPP);
            }

            String OKPO = pagesMap.get('LEGAL DETAILS').fields.get('OKPO').elementItemsMap.get('DEFAULT VALUE').Value__c;
            String codeWord = pagesMap.get('LEGAL DETAILS').fields.get('CODE WORD').elementItemsMap.get('DEFAULT VALUE').Value__c;

            String legalAddressCity = pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('CITY').Value__c;
            String legalAddressStreet = pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('STREET').Value__c + ' ' +
                    pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('HOUSE NUMBER').Value__c + ' ' +
                    pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS ADDITIONALLY').elementItemsMap.get('DEFAULT VALUE').Value__c;
            String legalAddressPostalCode = pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('POSTAL CODE').Value__c;
            String legalAddressState = pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('STATE').Value__c;
            String legalAddressCountry = pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('COUNTRY').Value__c;

            String postalAddressCity = pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('CITY').Value__c;
            String postalAddressStreet = pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('STREET').Value__c + ' ' +
                    pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('HOUSE NUMBER').Value__c + ' ' +
                    pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS ADDITIONALLY').elementItemsMap.get('DEFAULT VALUE').Value__c;
            String postalAddressPostalCode = pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('POSTAL CODE').Value__c;
            String postalAddressCountry = pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('COUNTRY').Value__c;

            this.formDataValidator.validateOKPOField(OKPO);
            this.formDataValidator.validateStringField(codeWord);

            account.OKPO_ppr__c = GlobalUtils.blankStringIfNull(OKPO);
            account.Code_Word__c = GlobalUtils.blankStringIfNull(codeWord);


            if (! this.formDataValidator.isValidAddress(legalAddressCountry, legalAddressCity, legalAddressState, legalAddressStreet, legalAddressPostalCode) ||
                ! this.formDataValidator.isValidAddress(postalAddressCountry, postalAddressCity, postalAddressStreet, postalAddressPostalCode)) {
                formParams.sendToInbound = true;
            }

            // legal address
            account.BillingCountry = GlobalUtils.blankStringIfNull(legalAddressCountry);
            account.BillingCity = GlobalUtils.blankStringIfNull(legalAddressCity);
            account.BillingStreet = GlobalUtils.blankStringIfNull(legalAddressStreet);
            account.BillingPostalCode = GlobalUtils.blankStringIfNull(legalAddressPostalCode);
            account.Region__c = GlobalUtils.blankStringIfNull(legalAddressState);

            // postal address
            account.ShippingCountry = GlobalUtils.blankStringIfNull(postalAddressCountry);
            account.ShippingCity = GlobalUtils.blankStringIfNull(postalAddressCity);
            account.ShippingStreet = GlobalUtils.blankStringIfNull(postalAddressStreet);
            account.ShippingPostalCode = GlobalUtils.blankStringIfNull(postalAddressPostalCode);

            this.e2eFormRuDao.updateAccount(account);
        } else if (activeStep == GlobalUtils.E2ERuSteps.PaymentDetails) {
            String checkingAccount = pagesMap.get('PAYMENT DETAILS').fields.get('CHECKING ACCOUNT').elementItemsMap.get('DEFAULT VALUE').Value__c;
            String bank = pagesMap.get('PAYMENT DETAILS').fields.get('BANK NAME').elementItemsMap.get('DEFAULT VALUE').Value__c;
            String BIC = pagesMap.get('PAYMENT DETAILS').fields.get('BIC').elementItemsMap.get('DEFAULT VALUE').Value__c;
            String corBankAccount = pagesMap.get('PAYMENT DETAILS').fields.get('CORR BANK ACCOUNT').elementItemsMap.get('DEFAULT VALUE').Value__c;

            this.formDataValidator.validateCheckingAccount(checkingAccount);
            this.formDataValidator.validateIsNotBlank(bank, 'bank');
            this.formDataValidator.validateCheckingAccount(corBankAccount);
            this.formDataValidator.validateBICField(BIC);

            account.Checking_Account__c = GlobalUtils.blankStringIfNull(checkingAccount);
            account.Bank__c = GlobalUtils.blankStringIfNull(bank);
            account.SWIFT_BIC__c = GlobalUtils.blankStringIfNull(BIC);
            account.Cor_Bank_Account__c = GlobalUtils.blankStringIfNull(corBankAccount);

            this.e2eFormRuDao.updateAccount(account);
        }
    }

    /*******************************************************************************
   *  Name            : getAccountById(Id accountId)
   *  Summary         : get account by id
   *  CreatedDate     : 12/07/2018
   *  ModifiedDate    : -
   *  Parameters      : Id accounts
   *  Returns         : account id
   ******************************************************************************/
    public Account getAccountById(Id accountId) {
        return this.e2eFormRuDao.getAccountById(accountId);
    }

    /*******************************************************************************
    *  Name            : deleteAccountById(Id accountId)
    *  Summary         : get account by id
    *  CreatedDate     : 12/07/2018
    *  ModifiedDate    : -
    *  Parameters      : Id accounts
    *  Returns         : account id
    ******************************************************************************/
    public static void deleteAccountById(Id accountId) {
        E2EFormRuDaoImpl e2eFormRuDao = new E2EFormRuDaoImpl();
        e2eFormRuDao.deleteAccount(e2eFormRuDao.getAccountById(accountId));
    }


    //******* Contact Service *****//

    /*******************************************************************************
    *  Name            : createContact(Id accountId, Map<String, LongFormPage> pagesMap, E2EFormParams formParams)
    *  Summary         : create contact
    *  CreatedDate     : 12/07/2018
    *  ModifiedDate    : 25/07/2018
    *  Parameters      : Id accountId, Map<String, LongFormPage> pagesMap
    *  Returns         : created contact id
    ******************************************************************************/
    public Id createContact(Id accountId, Map<String, LongFormPage> pagesMap, E2EFormParams formParams) {
        String phone = convertPhone(pagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c);
        String email = pagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c;
        String sendMarketingEmail = pagesMap.get('CONTACT DETAILS').fields.get('MARKETING DISPATCH').elementItemsMap.get('DEFAULT VALUE').Value__c;
        String processPersonalInformation = pagesMap.get('CONTACT DETAILS').fields.get('PERSONAL INFORMATION').elementItemsMap.get('DEFAULT VALUE').Value__c;

        this.formDataValidator.validateMobilePhone(phone);
        this.formDataValidator.validateEmail(email);
        this.formDataValidator.validateBooleanField(sendMarketingEmail);
        this.formDataValidator.validateBooleanField(processPersonalInformation);

        // New contact
        Contact contact = new Contact(
                RecordTypeId = GlobalUtils.getRecordTypeId('Contact', 'Russian'),
                Salutation = 'Mr.',
                LeadSource = 'E2E Form RU',
                AccountId = accountId,
                FirstName = 'Contact ' + Datetime.now().format('yyyyMMddHHmmss'),
                LastName = 'E2E',
                Phone = phone,
                MobilePhone = phone,
                Agree_to_receive_comm_info_by_email__c = Boolean.valueOf(sendMarketingEmail),
                Agree_to_process_pers_data_for_marketing__c = Boolean.valueOf(processPersonalInformation),
                Utm_campaign__c = formParams.utmCampaign,
                Utm_content__c = formParams.utmContent,
                Utm_medium__c = formParams.utmMedium,
                Utm_source__c = formParams.utmSource,
                Utm_term__c = formParams.utmTerm,
                Utm_url__c = formParams.utmUrl
        );

        if(Boolean.valueOf(processPersonalInformation)){
            contact.Email = email;
        }

        return this.e2eFormRuDao.createContact(contact);
    }

    /*******************************************************************************
    *  Name            : createEmployeeContact(Id accountId, String employeeFio, String title)
    *  Summary         : create contact if its does not exists, which related to employee
    *  CreatedDate     : 27/08/2018
    *  Parameters      : Id accountId, String employeeFio, String title
    *  Returns         : created contact id
    ******************************************************************************/
    public Id createEmployeeContact(Id accountId, String employeeFio, String title) {
        this.formDataValidator.validateIsNotBlank(employeeFio, 'employeeFio');
        this.formDataValidator.validateIsNotBlank(title, 'title');

        // Check existing contact with this fio as LastName
        Contact existingContact = null;
        List<Contact> listContacts =  this.e2eFormRuDao.getContactsByLastName(employeeFio, accountId);
        if(listContacts.size() != 0){
            existingContact = listContacts.get(0);
        }

        if (existingContact == null) {
            Contact employee = new Contact(
                    RecordTypeId = GlobalUtils.getRecordTypeId('Contact', 'Russian'),
                    Salutation = 'Mr.',
                    LeadSource = 'E2E Form RU',
                    AccountId = accountId,
                    LastName = employeeFio,
                    Title = title
            );
            return this.e2eFormRuDao.createContact(employee);
        } else {
            return existingContact.Id;
        }
    }

    /*******************************************************************************
   *  Name            : updateContact(Id contactId, Map<String, LongFormPage> pagesMap, E2EFormParams formParams, String step)
   *  Summary         : update contact
   *  CreatedDate     : 12/07/2018
   *  ModifiedDate    : 25/07/2018
   *  Parameters      : Id contactId, Map<String, LongFormPage> pagesMap, E2EFormParams formParams, String step
   *  Returns         : -
   ******************************************************************************/
    public void updateContact(Id contactId, Map<String, LongFormPage> pagesMap, E2EFormParams formParams, String step) {
        GlobalUtils.E2ERuSteps activeStep = convertToStep(step);
        Contact contact = new Contact(Id = contactId);
        if (activeStep == GlobalUtils.E2ERuSteps.ContactDetails) {
            String phone = convertPhone(pagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c);
            String email = pagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c;
            String sendMarketingEmail = pagesMap.get('CONTACT DETAILS').fields.get('MARKETING DISPATCH').elementItemsMap.get('DEFAULT VALUE').Value__c;
            String processPersonalInformation = pagesMap.get('CONTACT DETAILS').fields.get('PERSONAL INFORMATION').elementItemsMap.get('DEFAULT VALUE').Value__c;

            this.formDataValidator.validateMobilePhone(phone);
            this.formDataValidator.validateEmail(email);
            this.formDataValidator.validateBooleanField(sendMarketingEmail);
            this.formDataValidator.validateBooleanField(processPersonalInformation);

            contact.Phone = phone;
            contact.MobilePhone = phone;
            contact.Agree_to_receive_comm_info_by_email__c = Boolean.valueOf(sendMarketingEmail);
            contact.Agree_to_process_pers_data_for_marketing__c = Boolean.valueOf(processPersonalInformation);

            if(Boolean.valueOf(processPersonalInformation)){
                contact.Email = email;
            }

            this.e2eFormRuDao.updateContact(contact);
        }
    }

    /*******************************************************************************
    *  Name            : updateEmployeeContact(Id contactId, String employeeFio, String title)
    *  Summary         : update contact
    *  CreatedDate     : 27/08/2018
    *  ModifiedDate    : 04/10/2018
    *  Parameters      : Id contactId, String employeeFio, String title
    *  Returns         : -
    ******************************************************************************/
    public void updateEmployeeContact(Id contactId, String employeeFio, String title) {
        System.debug('******* Employee Contact: ' + employeeFio + ', title: ' + title);
        this.formDataValidator.validateIsNotBlank(employeeFio, 'employeeFio');
        this.formDataValidator.validateIsNotBlank(title, 'title');

        if (contactId != null) {
            Contact employee = new Contact(
                    Id = contactId,
                    LastName = employeeFio,
                    Title = title
            );
            this.e2eFormRuDao.updateContact(employee);
        } else {
            System.debug('******* UPDATE EMPLOYEE CONTACT: contactId is null.');
        }
    }

    /*******************************************************************************
    *  Name            : updateContactPhone(Id contactId, String phone)
    *  Summary         : update contact phone
    *  CreatedDate     : 16/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Id contactId, String email
    *  Returns         : -
    ******************************************************************************/
    public void updateContactPhone(Id contactId, String phone) {
        String currentPhone = convertPhone(phone);
        this.formDataValidator.validateMobilePhone(currentPhone);
        Contact employee = new Contact(
                Id = contactId,
                Phone = currentPhone,
                MobilePhone = currentPhone
        );
        this.e2eFormRuDao.updateContact(employee);
    }

    /*******************************************************************************
   *  Name            : getContactById(Id contactId)
   *  Summary         : get contact by id
   *  CreatedDate     : 12/07/2018
   *  ModifiedDate    : -
   *  Parameters      : Id contact
   *  Returns         : contact id
   ******************************************************************************/
    public Contact getContactById(Id contactId) {
        return this.e2eFormRuDao.getContactById(contactId);
    }

    //******* Opportunity Service *****//

    /*******************************************************************************
    *  Name            : createOpportunity(Id accountId, Map<String, LongFormPage> pagesMap, E2EFormParams formParams)
    *  Summary         : create opportunity
    *  CreatedDate     : 12/07/2018
    *  ModifiedDate    : -
    *  Parameters      : Map<String, LongFormPage> pagesMap
    *  Returns         : created opportunity id
    ******************************************************************************/
    public Id createOpportunity(Id accountId, E2EFormParams formParams) {
        // New opportunity
        // if(formParams.sourceIfSelfSourced == ''){
        //     formParams.sourceIfSelfSourced = 'E2E Form RU';
        // }

        Opportunity opportunity = new Opportunity(
                Name = 'E2E Opportunity ' + Datetime.now().format('yyyyMMddHHmmss'),
                StageName = 'Qualified Lead',
                AccountId = accountId,
                CloseDate = GlobalUtils.addBusinessDays(Date.today(), 5),
                LeadSource = 'E2E Form RU',
                Lead_Source_TypeOpp__c = 'Webform',
                Source_of_Lead_o__c = 'E2E Form RU',
                Source_if_self_sourced_c__c = 'E2E Form RU',
                PPR_First_Contact_Inbound_Outbound__c = 'Inbound Website',
                Channel__c = 'Internet',
                RecordTypeId = GlobalUtils.getRecordTypeId('Opportunity', 'Russian_Sales'),
                E2E_Status__c = 'Клиент Активен',
                E2E_Sales_Type__c = 'Чистый e2e',
                Source_PP__c = formParams.sourcePP,
                E2E_Last_Activity__c = Datetime.now(),
                E2E_Active_Substep__c = GlobalUtils.getE2ESteps(GlobalUtils.E2ERuSteps.ContactDetails.name()),
                Utm_campaign__c = formParams.utmCampaign,
                Utm_content__c = formParams.utmContent,
                Utm_medium__c = formParams.utmMedium,
                Utm_source__c = formParams.utmSource,
                Utm_term__c = formParams.utmTerm,
                Utm_url__c = formParams.utmUrl,
                Website_Page_Form__c = formParams.websitePageForm
        );
        return e2eFormRuDao.createOpportunity(opportunity);
    }

    /*******************************************************************************
   *  Name            : updateOpportunity(Id opportunityId, Map<String, LongFormPage> pagesMap, E2EFormParams formParams, String step)
   *  Summary         : update opportunity
   *  CreatedDate     : 12/07/2018
   *  ModifiedDate    : 25/07/2018
   *  Parameters      : Id opportunityId, Map<String, LongFormPage> pagesMap, E2EFormParams formParams, String step
   *  Returns         : -
   ******************************************************************************/
    public void updateOpportunity(Id opportunityId, Map<String, LongFormPage> pagesMap, E2EFormParams formParams, String step) {
        GlobalUtils.E2ERuSteps activeStep = convertToStep(step);
        Opportunity opportunity = new Opportunity(Id = opportunityId);
        opportunity.E2E_Status__c = 'Клиент Активен';
        if (activeStep == GlobalUtils.E2ERuSteps.CompanyInformation) {
            String accountName = pagesMap.get('COMPANY INFORMATION').fields.get('ACCOUNT NAME').elementItemsMap.get('DEFAULT VALUE').Value__c;
            String isEntryManual = pagesMap.get('COMPANY INFORMATION').fields.get('IS MANUAL ENTRY').elementItemsMap.get('DEFAULT VALUE').Value__c;

            this.formDataValidator.validateIsNotBlank(accountName, 'accountName');
            this.formDataValidator.validateBooleanField(isEntryManual);

            opportunity.Name = accountName;
            opportunity.Manual_Entry__c = Boolean.valueOf(isEntryManual);
            if(formParams.scoringDate != null){
                opportunity.Scoring_Date__c = formParams.scoringDate;
                opportunity.Scoring_Expiration_Date__c = formParams.scoringDate.addMonths(3);
            }

            // Set field E2E_Sub_Status__c 'Чёрный список' or 'Дедубликация'
            if (formParams.verifiedDecisionCode != null) {
                if (formParams.verifiedDecisionCode == '3' || formParams.scoringDecisionCode == '2') {
                    opportunity.E2E_Sub_Status__c = 'Чёрный список';
                    opportunity.E2E_Sales_Type__c = 'Отклонен';
                    opportunity.StageName = 'Отказ';
                    opportunity.PPR_Lost_Reasons__c = formParams.opportunityLostReason;
                    opportunity.E2E_Status__c = 'Клиент завершил';
                }
            }

            if (formParams.deduplicationStatus != null){
                if (formParams.deduplicationStatus == GlobalUtils.DeduplicationStatus.Service.name() || formParams.deduplicationStatus == GlobalUtils.DeduplicationStatus.KO.name()) {
                    opportunity.E2E_Sub_Status__c = 'Дедубликация';
                    opportunity.E2E_Sales_Type__c = 'Отклонен';
                }
            }
        } else if (activeStep == GlobalUtils.E2ERuSteps.Order) {
            String product = pagesMap.get('ORDER').fields.get('PRODUCTS').elementItemsMap.get('ID').Value__c;
            String tariff = pagesMap.get('ORDER').fields.get('PRODUCT TARIFF').elementItemsMap.get('DEFAULT VALUE').Value__c;
            String tariffId = pagesMap.get('ORDER').fields.get('PRODUCT TARIFF').elementItemsMap.get('TARIFF ID').Value__c;
            String numberOfCards = pagesMap.get('ORDER').fields.get('AMOUNT CARD').elementItemsMap.get('DEFAULT VALUE').Value__c;
            String promoCode = pagesMap.get('ORDER').fields.get('PROMOCODE').elementItemsMap.get('DEFAULT VALUE').Value__c == null ? '' : pagesMap.get('ORDER').fields.get('PROMOCODE').elementItemsMap.get('DEFAULT VALUE').Value__c;

            this.formDataValidator.validateIsNotBlank(product, 'product');
            this.formDataValidator.validateNumberOfCards(numberOfCards);
            this.formDataValidator.validateIsNotBlank(tariff, 'tariff');
            this.formDataValidator.validateIsNotBlank(tariffId, 'tariffId');

            Integer numberOfCardsWithFeeCards = Integer.valueOf(E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu').Number_of_Cards_Card__c);
            String productResult = '';
            if (product == GlobalUtils.E2EProduct.PetrolPlus_Rover.name()) {
                productResult = GlobalUtils.getE2EProduct(product) + ' "' + tariff + '" ';
                if (Integer.valueOf(numberOfCards) < numberOfCardsWithFeeCards) {
                    productResult += 'Карты';
                } else {
                    productResult += 'Договор';
                }
            } else if (product == GlobalUtils.E2EProduct.PetrolPlus_Gaz.name()) {
                productResult = GlobalUtils.getE2EProduct(product) + ' – сеть АЗС ';
                if (tariff.equals('Тариф 1')) {
                    productResult += 'Карты';
                } else if (tariff.equals('Тариф 2')) {
                    productResult += 'Договор';
                }
            } else {
                productResult = GlobalUtils.getE2EProduct(product) + ' ' + tariff;
            }

            opportunity.Product_PPR__c = productResult;
            opportunity.Promo_campaign__c = promoCode;
            opportunity.Number_of_Cards__c = Integer.valueOf(numberOfCards);
            opportunity.StageName = 'Agreement Terms and Conditions';
        } else if (activeStep == GlobalUtils.E2ERuSteps.PaymentDetails) {

        } else if (activeStep == GlobalUtils.E2ERuSteps.Congratulations) {
            opportunity.E2E_Status__c = 'Клиент завершил';
        }

        if (formParams.sendToInbound == true) {
            opportunity.E2E_Sub_Status__c = 'Перевод в ручную обработку';
        }
        opportunity.E2E_Encoded_URL__c = formParams.encodedURL;
        opportunity.E2E_Active_Substep__c = GlobalUtils.getE2ESteps(step);
        opportunity.E2E_Last_Activity__c = Datetime.now();

        this.e2eFormRuDao.updateOpportunity(opportunity);
    }

    public void forceUpdateOpportunity(Id opportunityId, String error) {
        try {
            if (opportunityId != null) {
                Opportunity opportunity = new Opportunity(Id = opportunityId);
                opportunity.E2E_Sub_Status__c = 'Перевод в ручную обработку';
                opportunity.E2E_Errors__c = error;
                opportunity.E2E_Last_Activity__c = Datetime.now();
                this.e2eFormRuDao.updateOpportunity(opportunity);

//                String body = getEmailBodyNotificationCallCenter(opportunityId, 'New E2E Client');
                EmailTemplate emailTemplate = EmailGenerator.getEmailTemplate(
                        GlobalUtils.EmailTemplateDevName.E2E_RU_Warning_Notification_Call_Center,
                        new Map<String, Object>{
                                '/$domainUrl$/' => E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu').Domain_Url__c,
                                '/$opportunity.Id$/' => opportunity.Id,
                                '/$opportunity.Name$/' => 'New E2E Client'
                        }
                );

                // send notification to call center
                sendE2ENotification(new Set<Id>(), emailTemplate.HtmlValue, emailTemplate.Subject, GlobalUtils.E2ERuGroupsNotification.CallCenter);
//                sendE2ENotification(new Set<Id>(), body, 'Russia E2E System Error', GlobalUtils.E2ERuGroupsNotification.CallCenter);

            } else {
                String notificationMessage = '<br/>E2E method forceUpdateOpportunity(): opportunityId == null ';
                ExceptionLogger.sendException(notificationMessage, '');
            }
        } catch (E2EFormRuException e) {
            String notificationMessage = '<br/>E2E method forceUpdateOpportunity(): ' + String.valueOf(e.getMessage());
            ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
        }
    }

    public class updateOpportunityQueueable implements Queueable{
        public Opportunity opportunity;
        public String updateCase;

        public  updateOpportunityQueueable (Opportunity opp, String uCase){
            opportunity = opp;
            updateCase = uCase;
        }

        public void execute(QueueableContext param1){
            try {
                E2EFormRuDaoImpl e2eFormRuDao = new E2EFormRuDaoImpl();
                if(updateCase == 'firstFormUrl'){
                    Opportunity currentOpportunity = e2eFormRuDao.getOpportunityById(opportunity.Id);
                    if(currentOpportunity.E2E_Encoded_URL__c == null){
                        e2eFormRuDao.updateOpportunity(opportunity);
                    }
                }
            }
            catch (Exception e){
                ExceptionLogger.sendException( '<br/>E2E updateOpportunityQueueable: ' + String.valueOf(e.getMessage()), String.valueOf(e.getStackTraceString()));
            }
        }
    }

    /*******************************************************************************
   *  Name            : getOpportunityById(Id opportunityId)
   *  Summary         : get opportunity by id
   *  CreatedDate     : 12/07/2018
   *  ModifiedDate    : -
   *  Parameters      : Id opportunityId
   *  Returns         : opportunity id
   ******************************************************************************/
    public Opportunity getOpportunityById(Id opportunityId) {
        return this.e2eFormRuDao.getOpportunityById(opportunityId);
    }

    //****** OpportunityContactRole Service *****//

    /*******************************************************************************
    *  Name            : createOpportunityContactRoles(Id opportunityId, Id accountId, Map<String, LongFormPage> pagesMap, String step)
    *  Summary         : create OpportunityContactRole
    *  CreatedDate     : 20/07/2018
    *  ModifiedDate    : -
    *  Parameters      : Id opportunityId, Id accountId, Map<String, LongFormPage> pagesMap, String step
    *  Returns         : void
    ******************************************************************************/
    public void createOpportunityContactRoles(Id opportunityId, Id accountId, Map<String, LongFormPage> pagesMap, String step) {
        GlobalUtils.E2ERuSteps activeStep = convertToStep(step);
        if (activeStep == GlobalUtils.E2ERuSteps.LegalDetails) {
            List<Contact> contactList = new List<Contact>();
            String executivePerson = pagesMap.get('LEGAL DETAILS').fields.get('EXECUTIVE PERSON').elementItemsMap.get('DEFAULT VALUE').Value__c;
            String executivePersonTitle = pagesMap.get('LEGAL DETAILS').fields.get('EXECUTIVE PERSON POSITION').elementItemsMap.get('DEFAULT VALUE').Value__c;
            String chiefAccountant = pagesMap.get('LEGAL DETAILS').fields.get('CHIEF ACCOUNTANT').elementItemsMap.get('DEFAULT VALUE').Value__c;

            this.formDataValidator.validateStringField(executivePerson);
            this.formDataValidator.validateStringField(executivePersonTitle);
            this.formDataValidator.validateStringField(chiefAccountant);

            // Executive Person
            Contact executivePersonContact = new Contact(
                    RecordTypeId = GlobalUtils.getRecordTypeId('Contact', 'Russian'),
                    Salutation = 'Mr.',
                    AccountId = accountId,
                    LastName = executivePerson,
                    Title = executivePersonTitle
            );
            contactList.add(executivePersonContact);

            // Chief Accountant
            Contact chiefAccountantContact = new Contact(
                    RecordTypeId = GlobalUtils.getRecordTypeId('Contact', 'Russian'),
                    Salutation = 'Mr.',
                    AccountId = accountId,
                    LastName = chiefAccountant,
                    Title = 'Главный бухгалтер'
            );
            contactList.add(chiefAccountantContact);

            // create OpportunityContactRole
            this.e2eFormRuDao.createContacts(contactList);

            List<OpportunityContactRole> opportunityContactRoles = new List<OpportunityContactRole>();
            OpportunityContactRole executivePersonRole = this.e2eFormRuDao.getOpportunityContactRole(contactList.get(0).Id, opportunityId);
            executivePersonRole.Role = 'Decision Maker';
            opportunityContactRoles.add(executivePersonRole);
            OpportunityContactRole chiefAccountantRole = this.e2eFormRuDao.getOpportunityContactRole(contactList.get(1).Id, opportunityId);
            chiefAccountantRole.Role = 'Accounting (for invoices)';
            opportunityContactRoles.add(chiefAccountantRole);

            // update OpportunityContactRole
            this.e2eFormRuDao.updateOpportunityContactRole(opportunityContactRoles);
        }
    }

    /*******************************************************************************
    *  Name            : updateOpportunityContactRole
    *  Summary         : update OpportunityContactRole
    *  CreatedDate     : 20/07/2018
    *  ModifiedDate    : -
    *  Parameters      : Id opportunityId, Id accountId, String role - OpportunityContactRole
    *  Returns         : void
    ******************************************************************************/
    public static void updateOpportunityContactRole(Id opportunityId, Id contactId, String role, Boolean isPrimary) {
        E2EFormRuDaoImpl e2eFormRuDao = new E2EFormRuDaoImpl();
        List<OpportunityContactRole> opportunityContactRoles = e2eFormRuDao.getOpportunityContactRoles(contactId, opportunityId);
        if (opportunityContactRoles != null && ! opportunityContactRoles.isEmpty()) {
            OpportunityContactRole opportunityContactRole = opportunityContactRoles.get(0);
            opportunityContactRole.Role = role;
            opportunityContactRole.IsPrimary = isPrimary;
            e2eFormRuDao.updateOpportunityContactRole(new List<OpportunityContactRole>{opportunityContactRole});
        }
    }

    //******* Document Service *****//

    /*******************************************************************************
    *  Name            : createDocument(String name, Blob content, String contentType, Id folderId)
    *  Summary         : create document
    *  CreatedDate     : 24/07/2018
    *  ModifiedDate    : -
    *  Parameters      : String name, Blob content, String contentType, Id folderId
    *  Returns         : created document id
    ******************************************************************************/
    public Id createDocument(String name, Blob content, String contentType, Id folderId) {
        Document document = new Document(
                Name = name,
                FolderId = folderId,
                Body = content,
                ContentType = contentType,
                IsPublic = false,
                Type = 'pdf'
        );
        return this.e2eFormRuDao.createDocument(document);
    }

    //******** Report Service Integration ******//

    public ReportRequestData prepareReportRequestData(Id formDataId, E2EFormParams formParams, Map<String, LongFormPage> pagesMap, Boolean preview) {
        E2EFormData__c formDataRecord = this.e2EFormRuDao.getFormDataById(formDataId);
        Account account = this.e2eFormRuDao.getAccountById(formDataRecord.E2E_Account_Id__c);
        Opportunity opportunity = this.e2eFormRuDao.getOpportunityById(formDataRecord.E2E_Opportunity_Id__c);

        E2E_Form_Ru_General_Settings__c generalSettings = E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu');
        if (generalSettings == null) {
            throw new E2EFormRuException('Error: prepareReportRequestData(); E2E_Form_Ru_General_Settings__c does not found');
        }

        ReportRequestData requestData = new ReportRequestData();
        requestData.reportParams = new ReportRequestData.ReportParams();

        requestData.inn = formDataRecord.E2E_INN__c;
        requestData.companyName = account.Name; //formData.E2E_Main_Company_Full_Name__c
        requestData.sFRequestId = formDataRecord.E2E_Opportunity_Id__c;
        requestData.hasPersonalManager = formDataRecord.E2E_Personal_Manager_srv__c;
        requestData.hasExpressDelivery = formDataRecord.E2E_Document_Delivery_srv__c;
        requestData.preview = preview;
        requestData.amount = Integer.valueOf(pagesMap.get('PAYMENT DETAILS').fields.get('PREPAYMENT AMOUNT').elementItemsMap.get('DEFAULT VALUE').Value__c);
        requestData.bikBank = pagesMap.get('PAYMENT DETAILS').fields.get('BIC').elementItemsMap.get('DEFAULT VALUE').Value__c;

        // set partner
        if (opportunity.Source_PP__c != null && opportunity.Source_PP__c != '') {
            requestData.specPartner = true;
        } else {
            requestData.specPartner = false;
        }

        // set email for send completed contract to client
        if (generalSettings.Send_Contract_To_Client__c == true && formParams.sendToInbound == false && preview == false) {
            requestData.mailList = new List<String>{formDataRecord.E2E_Contact_Email__c};
            Map<String, String> mailInfo = getSummaryMailInfo(formDataRecord);
            requestData.mailType = mailInfo.get('type');
            requestData.mailSubject = mailInfo.get('subject');
            requestData.mailBody = mailInfo.get('body');
        } else {
            requestData.mailList = new List<String>();
        }

        //****  Init productId and tariffId ******//
        if (formDataRecord.E2E_Product_Id__c == GlobalUtils.E2EProduct.PetrolPlus_Rover.name()) {
            requestData.productId = '1'; // Пункт 1

            if (formDataRecord.E2E_Tariff_Id__c != null) {
                // Пункт 2
                if (formDataRecord.E2E_Tariff_Id__c.substring(0, 1) == '1') { // Optimal tariff
                    requestData.tariffId = formDataRecord.E2E_Num_Cards__c >= generalSettings.Number_of_Cards_Card__c ? '1' : '2';
                } else if (formDataRecord.E2E_Tariff_Id__c.substring(0, 1) == '2') { // Choosen tariff
                    requestData.tariffId = formDataRecord.E2E_Num_Cards__c >= generalSettings.Number_of_Cards_Card__c ? '3' : '4';
                }
            }
        } else if (formDataRecord.E2E_Product_Id__c == GlobalUtils.E2EProduct.PetrolPlus_Gaz.name()) {
            requestData.productId = '2'; // Пункт 1
            if (formDataRecord.E2E_Tariff_Id__c.substring(0, 1) == '1') { // Пункт 2
                requestData.tariffId = '6';
            } else {
                requestData.tariffId = '5';
            }
        } else if (formDataRecord.E2E_Product_Id__c == GlobalUtils.E2EProduct.Shell.name()) {
            requestData.productId = '3'; // Пункт 1
            requestData.tariffId = '7'; // Пункт 2
        } else if (formDataRecord.E2E_Product_Id__c == GlobalUtils.E2EProduct.Partner_Rover.name()) {
            requestData.productId = '1'; // Пункт 1

            if (formDataRecord.E2E_Tariff_Id__c != null) {
                // Пункт 2
                if (formDataRecord.E2E_Tariff_Id__c.substring(0, 1) == '1') { // Optimal cards
                    requestData.tariffId = '2';
                } else { // Optimal Contract
                    requestData.tariffId = '1';
                }
            }
        }

        //******* Init specialOfferId and Promocode  *******//
        requestData.reportParams.PROMOCODE = '';
        requestData.reportParams.SPECIAL_OFFER_NAME = '';
        requestData.reportParams.SUPPLIER = '';

        if (opportunity.Source_PP__c != null && opportunity.Source_PP__c != '') {
            requestData.reportParams.PARTNER_NAME = GlobalUtils.getE2ERuPartner(opportunity.Source_PP__c);
            requestData.reportParams.PROMOCODE = formParams.promocodeName;
            requestData.reportParams.SPECIAL_OFFER_NAME = formParams.source;
        } else {
            if (formParams.promocodeName != null) {
                E2E_Promocodes__c promocodeObject = E2E_Promocodes__c.getValues(formParams.promocodeName);
                if (promocodeObject != null && promocodeObject.Report_Identifiers__c != null) {
                    List<String> transitCoupleCode = promocodeObject.Report_Identifiers__c.split(';');
                    Map<String, String> codes = new Map<String, String>();
                    for (String coupleCode : transitCoupleCode) {
                        codes.put(coupleCode.split('@').get(0), coupleCode.split('@').get(1));
                    }

                    Map<String, String> supplies = new Map<String, String>();
                    for (String val : promocodeObject.Promocode_Additional_Field__c.split(';')) {
                        supplies.put(val.split('@')[1], val.split('@')[0]);
                    }

                    requestData.specialOfferId = codes.get(formParams.promocodeIdInTransit) != null ? codes.get(formParams.promocodeIdInTransit) : '';
                    requestData.reportParams.SPECIAL_OFFER_NAME = promocodeObject.Promocode_Label__c;
                    requestData.reportParams.SUPPLIER = supplies.get(formParams.promocodeIdInTransit);
                    requestData.reportParams.PROMOCODE = formParams.promocodeName;
                } else {
                    requestData.specialOfferId = '';
                }
            } else {
                requestData.specialOfferId = '';
            }
        }


        // Check permission to credit
        if (formDataRecord.E2E_Scoring_Decision_Code__c == '0') {
            requestData.hasCredit = formDataRecord.E2E_Overdraft_srv__c != null ? formDataRecord.E2E_Overdraft_srv__c : false;
            requestData.reportParams.HAS_OVERDRAFT = formDataRecord.E2E_Overdraft_srv__c != null ? formDataRecord.E2E_Overdraft_srv__c : false;
        } else {
            requestData.hasCredit = false;
            requestData.reportParams.HAS_OVERDRAFT = false;
        }

        requestData.reportParams.CONTRACT_DATE = createDateStringForReport(System.Today());
        requestData.reportParams.NUMBER_OF_CARDS = String.valueOf(formDataRecord.E2E_Num_Cards__c);
        requestData.reportParams.NUMBER_OF_CARDS_TEXT = GlobalUtils.convertNumberToWord(Integer.valueOf(formDataRecord.E2E_Num_Cards__c));
        requestData.reportParams.SECURITY_PHRASE = formDataRecord.E2E_Code_Word__c;
        requestData.reportParams.USERNAME = formDataRecord.E2E_Personal_Office_Email__c;
        requestData.reportParams.PRODUCT_NAME = formDataRecord.E2E_Product__c;
        requestData.reportParams.BILL_SUM = Integer.valueOf(pagesMap.get('PAYMENT DETAILS').fields.get('PREPAYMENT AMOUNT').elementItemsMap.get('DEFAULT VALUE').Value__c);
        requestData.reportParams.EXT_CLIENT_ID = formDataRecord.E2E_Opportunity_Id__c;

        // Requisite for client
        requestData.reportParams.CLIENT_INN = formDataRecord.E2E_INN__c;
        requestData.reportParams.CLIENT_KPP = GlobalUtils.blankStringIfNull(formDataRecord.E2E_KPP__c);
        requestData.reportParams.CLIENT_OGRN = formDataRecord.E2E_OGRN__c;
        requestData.reportParams.CLIENT_OKPO = formDataRecord.E2E_OKPO__c;
        requestData.reportParams.CLIENT_LEGAL_ADDRESS = formDataRecord.E2E_Legal_Address__c;
        requestData.reportParams.CLIENT_ADDRESS = formDataRecord.E2E_Post_Address__c;
        requestData.reportParams.CLIENT_CURRENT_ACCOUNT = GlobalUtils.blankStringIfNull(pagesMap.get('PAYMENT DETAILS').fields.get('CHECKING ACCOUNT').elementItemsMap.get('DEFAULT VALUE').Value__c);
        requestData.reportParams.CLIENT_COR_ACCOUNT = GlobalUtils.blankStringIfNull(pagesMap.get('PAYMENT DETAILS').fields.get('CORR BANK ACCOUNT').elementItemsMap.get('DEFAULT VALUE').Value__c);
        requestData.reportParams.CLIENT_BANK_NAME = GlobalUtils.blankStringIfNull(pagesMap.get('PAYMENT DETAILS').fields.get('BANK NAME').elementItemsMap.get('DEFAULT VALUE').Value__c);
        requestData.reportParams.CLIENT_BIK = GlobalUtils.blankStringIfNull(pagesMap.get('PAYMENT DETAILS').fields.get('BIC').elementItemsMap.get('DEFAULT VALUE').Value__c);
        requestData.reportParams.CLIENT_PHONE = formDataRecord.E2E_Contact_Phone__c;
        requestData.reportParams.CLIENT_EMAIL = formDataRecord.E2E_Contact_Email__c;
        requestData.reportParams.CLIENT_MOB_PHONE_FIN = formDataRecord.E2E_Contact_Phone__c;
        requestData.reportParams.CLIENT_MOB_PHONE_INFO = formDataRecord.E2E_Contact_Phone__c;
        requestData.reportParams.CLIENT_NAME = formDataRecord.E2E_Main_Company_Full_Name__c;

        List<String> executivePersonData = parserExecutivePerson(formDataRecord.E2E_Executive_Person__c);
        if (account.Organization_Type__c == 'ИП') {
            requestData.reportParams.CLIENT_SIGNER_POST = '';
            requestData.reportParams.CLIENT_SIGNER_FIO = executivePersonData.get(0);
        } else {
            requestData.reportParams.CLIENT_SIGNER_POST = executivePersonData.get(1);
            requestData.reportParams.CLIENT_SIGNER_FIO = executivePersonData.get(0);
        }

        requestData.reportParams.EXTRA_INFO = GlobalUtils.blankStringIfNull(formDataRecord.E2E_Courier_Comments__c);

        // Additional
        requestData.reportParams.ADDITIONAL_CONTRACT_DATE = createDateStringForReport(System.Today());
        requestData.reportParams.ATTACHMENT_NUM = '1';
        return requestData;
    }

    public static String createDateStringForReport(Date currentDate) {
        String dateStr = '«' + currentDate.day() + '»';
        dateStr += ' ' + GlobalUtils.getStringOfMonth(currentDate.month()) + ' ';
        dateStr += currentDate.year();
        dateStr += ' г.';
        return dateStr;
    }

    public Map<String, String> getSummaryMailInfo(E2EFormData__c formData){
        EmailTemplate summaryEmail = [
                SELECT Id, HTMLValue, Name, Subject
                FROM EmailTemplate
                WHERE Name = 'E2E RU Order Confirmation'
        ];

        //Get email body
        String emailBody = summaryEmail.HTMLValue;
        emailBody = emailBody.replace('$OrderNumber$', formData.Name);
        emailBody = emailBody.replace('$NumberOfCards$', String.valueof(formData.E2E_Num_Cards__c));
        String emailProductName = '';
        if (formData.E2E_Product__c.contains('Вездеход Online')){
            emailProductName = '"Вездеход Online"';
        } else {
            emailProductName = formData.E2E_Product__c;
        }
        emailBody = emailBody.replace('$E2EProductName$', emailProductName);

        //Get email Subject
        String emailSubject = summaryEmail.Subject;
        emailSubject = emailSubject.replace('$E2EProductName$', emailProductName);

        Map<String, String> emailData = new Map<String, String>();
        emailData.put('body', emailBody);
        emailData.put('subject', emailSubject);
        emailData.put('type', 'HTML');
        return emailData;
    }

    //******* Form Service *****//
        /*******************************************************************************
   *  Name            : createFormDataRecord(Map<String, LongFormPage> pagesMap, String ipAddress)
   *  Summary         : create Form Data log record
   *  CreatedDate     : 30/10/2018
   *  ModifiedDate    : -
   *  Parameters      : Id accountId, Id contactId, Id opportunityId, Map<String, LongFormPage> pagesMap
   *  Returns         : created record id
   ******************************************************************************/
    public Id createFormDataRecord(Id accountId, Id contactId, Id opportunityId, Map<String, LongFormPage> pagesMap, E2EFormParams formParams) {
        String phone = pagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c;
        String email = pagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c;
        Boolean sendMarketingEmail = Boolean.valueOf(pagesMap.get('CONTACT DETAILS').fields.get('MARKETING DISPATCH').elementItemsMap.get('DEFAULT VALUE').Value__c);
        Boolean processPersonalData = Boolean.valueOf(pagesMap.get('CONTACT DETAILS').fields.get('PERSONAL INFORMATION').elementItemsMap.get('DEFAULT VALUE').Value__c);
        // New Form Data record
        E2EFormData__c formDataLog = new E2EFormData__c(
                E2E_Account_Id__c = GlobalUtils.blankStringIfNull(accountId),
                E2E_Contact_Id__c = GlobalUtils.blankStringIfNull(contactId),
                E2E_Opportunity_Id__c = GlobalUtils.blankStringIfNull(opportunityId),
                E2E_Contact_Phone__c = phone,
                E2E_Send_Marketing_Email__c = sendMarketingEmail,
                E2E_Process_Personal_Data__c = processPersonalData,
                E2E_IP_Address__c = formParams.ipAddress,
                E2E_Last_Step__c = GlobalUtils.E2ERuSteps.ContactDetails.name(),
                E2E_Device_Type__c = formParams.deviceType,
                E2E_Source__c = formParams.source,
                E2E_Offer__c = formParams.offer,
                E2E_Product_Id__c = formParams.product,
                E2E_Split_Testing__c = formParams.splitTesting
        );

        if(processPersonalData){
            formDataLog.E2E_Contact_Email__c = email;
        }
        return this.e2eFormRuDao.createFormDataRecord(formDataLog);
    }

    /*******************************************************************************
    *  Name            : updateFormData(Id formDataId, Id accountId, Id contactId, Id opportunityId, Map<String, LongFormPage> pagesMap, E2EFormParams formParams, String step)
    *  Summary         : update Form Data log record
    *  CreatedDate     : 18/07/2018
    *  ModifiedDate    : 25/07/2018
    *  Parameters      : Id formDataId, Id accountId, Id contactId, Id opportunityId, Map<String, LongFormPage> pagesMap, E2EFormParams formParams, String step
    *  Returns         : -
    ******************************************************************************/
    public void updateFormData(Id formDataId, Map<String, LongFormPage> pagesMap, E2EFormParams formParams, String step, String source) {
        System.debug('*_*_*_* updateFORMdata: '+System.currentTimeMillis());
        GlobalUtils.E2ERuSteps activeStep = convertToStep(step);

        E2EFormData__c formDataRecord = this.e2eFormRuDao.getFormDataById(formDataId);
        formParams.formDataName = formDataRecord.Name;
        if (activeStep == GlobalUtils.E2ERuSteps.ContactDetails) {
            // STEP ContactDetails
            String phone = pagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c;
            String email = pagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c;
            Boolean sendMarketingEmail = Boolean.valueOf(pagesMap.get('CONTACT DETAILS').fields.get('MARKETING DISPATCH').elementItemsMap.get('DEFAULT VALUE').Value__c);
            Boolean processPersonalData = Boolean.valueOf(pagesMap.get('CONTACT DETAILS').fields.get('PERSONAL INFORMATION').elementItemsMap.get('DEFAULT VALUE').Value__c);

            formDataRecord.E2E_Offer__c = formParams.offer;
            formDataRecord.E2E_Source__c = formParams.source;
            formDataRecord.E2E_Product__c = formParams.product;

            if(processPersonalData){
                formDataRecord.E2E_Contact_Email__c = email;
            }
            formDataRecord.E2E_Contact_Phone__c = GlobalUtils.blankStringIfNull(phone);
            formDataRecord.E2E_Send_Marketing_Email__c = sendMarketingEmail;
            formDataRecord.E2E_Process_Personal_Data__c = processPersonalData;
        } else if (activeStep == GlobalUtils.E2ERuSteps.CompanyInformation) {
            // STEP CompanyInformation
            String accountName = pagesMap.get('COMPANY INFORMATION').fields.get('ACCOUNT NAME').elementItemsMap.get('DEFAULT VALUE').Value__c;
            String INN = pagesMap.get('COMPANY INFORMATION').fields.get('INN').elementItemsMap.get('DEFAULT VALUE').Value__c;
            Boolean isEntryManual = Boolean.valueOf(pagesMap.get('COMPANY INFORMATION').fields.get('IS MANUAL ENTRY').elementItemsMap.get('DEFAULT VALUE').Value__c);

            if (formParams.isSoleProprietor == true) {
                formDataRecord.E2E_Account_Short_Name__c = formParams.mainCompanyFullNameSpark.removeStart('ИП ');
                formDataRecord.E2E_Executive_Person__c = GlobalUtils.blankStringIfNull(formParams.soleProprietorFio) + ', ' + 'Индивидуальный предприниматель';
            } else {
                formDataRecord.E2E_Account_Short_Name__c = GlobalUtils.parseNormNameForOrganization(formParams.normName).get(0);
                String executiveFio = GlobalUtils.blankStringIfNull(formParams.executiveFio);
                String executivePosition = formParams.executivePosition == null ? '' : ', ' +  GlobalUtils.blankStringIfNull(formParams.executivePosition);
                formDataRecord.E2E_Executive_Person__c = executiveFio + executivePosition;
            }

            formDataRecord.E2E_Account_Name__c = GlobalUtils.blankStringIfNull(accountName);
            formDataRecord.E2E_Reg_Date__c = GlobalUtils.blankStringIfNull(formParams.registrationDateSpark);
            formDataRecord.E2E_INN__c = GlobalUtils.blankStringIfNull(INN);
            formDataRecord.E2E_OGRN__c = GlobalUtils.blankStringIfNull(formParams.ogrnSpark);
            formDataRecord.E2E_OKPO__c = GlobalUtils.blankStringIfNull(formParams.okpoSpark);
            formDataRecord.E2E_KPP__c = GlobalUtils.blankStringIfNull(formParams.kppSpark);
            formDataRecord.E2E_Manual_Entry__c = isEntryManual;
            formDataRecord.E2E_Spark_Id__c = GlobalUtils.blankStringIfNull(String.valueOf(formParams.sparkId));
            formDataRecord.E2E_Main_Company_Full_Name__c = GlobalUtils.blankStringIfNull(formParams.mainCompanyFullNameSpark);
            formDataRecord.E2E_Billing_Code__c = GlobalUtils.blankStringIfNull(formParams.postCodeSpark);
            formDataRecord.E2E_Billing_State__c = GlobalUtils.blankStringIfNull(formParams.regionSpark);
            formDataRecord.E2E_Billing_City__c = GlobalUtils.blankStringIfNull(formParams.citySpark);
            String street = formParams.streetSpark == null ? '' : GlobalUtils.blankStringIfNull(formParams.streetSpark);
            String building = formParams.buildingSpark == null ? '' : ', ' + GlobalUtils.blankStringIfNull(formParams.buildingSpark);
            String housing = formParams.housingSpark == null ? '' : ', ' +  GlobalUtils.blankStringIfNull(formParams.housingSpark);
            String block = formParams.blockSpark == null ? '' : ', ' +  GlobalUtils.blankStringIfNull(formParams.blockSpark);
            String room = formParams.roomSpark == null ? '' : ', ' +  GlobalUtils.blankStringIfNull(formParams.roomSpark);
            formDataRecord.E2E_Billing_Str__c = street + building;
            formDataRecord.E2E_Billing_Apartment__c = housing + block + room;
            formDataRecord.E2E_Legal_Address__c =  GlobalUtils.blankStringIfNull(formParams.legalAddressSpark);
            formDataRecord.E2E_Black_List_Code__c = GlobalUtils.blankStringIfNull(formParams.verifiedDecisionCode);
            formDataRecord.E2E_Black_List__c = GlobalUtils.blankStringIfNull(formParams.verifiedDecision);
            formDataRecord.E2E_Black_List_Limitations__c = GlobalUtils.blankStringIfNull(formParams.verifiedLimitation);
            formDataRecord.E2E_Scoring_Decision_Code__c = GlobalUtils.blankStringIfNull(formParams.scoringDecisionCode);
            formDataRecord.E2E_Scoring_Decision__c = GlobalUtils.blankStringIfNull(formParams.scoringDecision);
            formDataRecord.E2E_Scoring_Date__c = formParams.scoringDate;
            formDataRecord.E2E_Scoring_Expiration_Date__c = formParams.scoringDate == null ? null : formParams.scoringDate.addMonths(3);
            formDataRecord.E2E_Dedup_Status__c = GlobalUtils.blankStringIfNull(formParams.deduplicationStatus);
            formDataRecord.E2E_Dedup_Status_Info__c = GlobalUtils.blankStringIfNull(formParams.deduplicationStatusInfo);
        } else if (activeStep == GlobalUtils.E2ERuSteps.Order) {
            // STEP Order
            String product = pagesMap.get('ORDER').fields.get('PRODUCTS').elementItemsMap.get('ID').Value__c + '';
            String tariff = pagesMap.get('ORDER').fields.get('PRODUCT TARIFF').elementItemsMap.get('DEFAULT VALUE').Value__c;
            String tariffId = pagesMap.get('ORDER').fields.get('PRODUCT TARIFF').elementItemsMap.get('TARIFF ID').Value__c;
            Integer numberOfCards = Integer.valueOf(pagesMap.get('ORDER').fields.get('AMOUNT CARD').elementItemsMap.get('DEFAULT VALUE').Value__c);
            String promoCode = pagesMap.get('ORDER').fields.get('PROMOCODE').elementItemsMap.get('DEFAULT VALUE').Value__c;
            String paymentCondition = pagesMap.get('ORDER').fields.get('PAYMENT CONDITIONS').elementItemsMap.get('DEFAULT VALUE').Value__c;
            Boolean needPersonalManager = Boolean.valueOf(pagesMap.get('ORDER').fields.get('PERSONAL MANAGER').elementItemsMap.get('DEFAULT VALUE').Value__c);
            Boolean needDocumentDelivery = Boolean.valueOf(pagesMap.get('ORDER').fields.get('DOCS DELIVERY').elementItemsMap.get('DEFAULT VALUE').Value__c);
            Boolean needPayOverdraft = Boolean.valueOf(pagesMap.get('ORDER').fields.get('PAY OVERDRAFT').elementItemsMap.get('DEFAULT VALUE').Value__c);

            formDataRecord.E2E_Product_Id__c = GlobalUtils.blankStringIfNull(product);
            formDataRecord.E2E_Tariff_Id__c = GlobalUtils.blankStringIfNull(tariffId);
            formDataRecord.E2E_Product__c = GlobalUtils.getE2EProduct(product) + ' ' + GlobalUtils.blankStringIfNull(tariff);
            formDataRecord.E2E_Num_Cards__c = numberOfCards;
            formDataRecord.E2E_Promo_Campaign__c = GlobalUtils.blankStringIfNull(promoCode);
            formDataRecord.E2E_Personal_Manager_srv__c = needPersonalManager;
            formDataRecord.E2E_Document_Delivery_srv__c = needDocumentDelivery;
            formDataRecord.E2E_Overdraft_srv__c = needPayOverdraft;
            formDataRecord.E2E_Payment_Condition__c = GlobalUtils.blankStringIfNull(paymentCondition);
        } else if (activeStep == GlobalUtils.E2ERuSteps.LegalDetails) {
            // STEP LegalDetails
            String OGRN = '';
            String KPP = '';
            if(formParams.isSoleProprietor){
                OGRN = pagesMap.get('LEGAL DETAILS').fields.get('OGRNIP').elementItemsMap.get('DEFAULT VALUE').Value__c;
            } else {
                OGRN = pagesMap.get('LEGAL DETAILS').fields.get('OGRN').elementItemsMap.get('DEFAULT VALUE').Value__c;
                KPP = String.valueOf(Integer.valueOf(pagesMap.get('LEGAL DETAILS').fields.get('KPP').elementItemsMap.get('DEFAULT VALUE').Value__c));
            }
            String OKPO = pagesMap.get('LEGAL DETAILS').fields.get('OKPO').elementItemsMap.get('DEFAULT VALUE').Value__c;
            String legalAddress = pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c;
            String legalAddressCountry = pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('COUNTRY').Value__c;
            String legalAddressState = pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('STATE').Value__c;
            String legalAddressCity = pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('CITY').Value__c;
            String legalAddressStreet = pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('STREET').Value__c;
            String legalAddressHouse = pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('HOUSE NUMBER').Value__c;
            String legalAddressPostalCode = pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS').elementItemsMap.get('POSTAL CODE').Value__c;
            String legalAddressApartment = pagesMap.get('LEGAL DETAILS').fields.get('LEGAL ADDRESS ADDITIONALLY').elementItemsMap.get('DEFAULT VALUE').Value__c;
            String postalAddress = pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c;
            String postalAddressCountry = pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('COUNTRY').Value__c;
            String postalAddressState = pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('STATE').Value__c;
            String postalAddressCity = pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('CITY').Value__c;
            String postalAddressStreet = pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('STREET').Value__c;
            String postalAddressHouse = pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('HOUSE NUMBER').Value__c;
            String postalAddressPostalCode = pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS').elementItemsMap.get('POSTAL CODE').Value__c;
            String postalAddressApartment = pagesMap.get('LEGAL DETAILS').fields.get('POSTAL ADDRESS ADDITIONALLY').elementItemsMap.get('DEFAULT VALUE').Value__c;
            String executivePerson = pagesMap.get('LEGAL DETAILS').fields.get('EXECUTIVE PERSON').elementItemsMap.get('DEFAULT VALUE').Value__c;
            String executivePersonTitle = pagesMap.get('LEGAL DETAILS').fields.get('EXECUTIVE PERSON POSITION').elementItemsMap.get('DEFAULT VALUE').Value__c;
            String chiefAccountant = pagesMap.get('LEGAL DETAILS').fields.get('CHIEF ACCOUNTANT').elementItemsMap.get('DEFAULT VALUE').Value__c;
            String codeWord = pagesMap.get('LEGAL DETAILS').fields.get('CODE WORD').elementItemsMap.get('DEFAULT VALUE').Value__c;
            String cardsDeliveryInformation = pagesMap.get('LEGAL DETAILS').fields.get('CARDS DELIVERY INFORMATION').elementItemsMap.get('DEFAULT VALUE').Value__c;
            String personalOfficeEmail = pagesMap.get('LEGAL DETAILS').fields.get('USER ACCOUNT EMAIL').elementItemsMap.get('DEFAULT VALUE').Value__c;
            Boolean isManualEntryLegalInfo = Boolean.valueOf(pagesMap.get('LEGAL DETAILS').fields.get('REWRITE DEFAULT SPARK VALUES').elementItemsMap.get('DEFAULT VALUE').Value__c);

            this.formDataValidator.validateEmail(personalOfficeEmail);

            formDataRecord.E2E_OGRN__c = GlobalUtils.blankStringIfNull(OGRN);
            formDataRecord.E2E_KPP__c = String.valueOf(KPP);
            formDataRecord.E2E_OKPO__c = GlobalUtils.blankStringIfNull(OKPO);
            formDataRecord.E2E_Billing_Str__c = GlobalUtils.blankStringIfNull(legalAddressStreet);
            formDataRecord.E2E_Billing_House__c = GlobalUtils.blankStringIfNull(legalAddressHouse);
            formDataRecord.E2E_Billing_City__c = GlobalUtils.blankStringIfNull(legalAddressCity);
            formDataRecord.E2E_Billing_State__c = GlobalUtils.blankStringIfNull(legalAddressState);
            formDataRecord.E2E_Billing_Code__c = GlobalUtils.blankStringIfNull(legalAddressPostalCode);
            formDataRecord.E2E_Billing_Country__c = GlobalUtils.blankStringIfNull(legalAddressCountry);
            formDataRecord.E2E_Billing_Apartment__c = GlobalUtils.blankStringIfNull(legalAddressApartment);
            formDataRecord.E2E_Legal_Address__c = GlobalUtils.blankStringIfNull(legalAddress);
            formDataRecord.E2E_Shipping_Str__c = GlobalUtils.blankStringIfNull(postalAddressStreet);
            formDataRecord.E2E_Shipping_House__c = GlobalUtils.blankStringIfNull(postalAddressHouse);
            formDataRecord.E2E_Shipping_City__c = GlobalUtils.blankStringIfNull(postalAddressCity);
            formDataRecord.E2E_Shipping_State__c = GlobalUtils.blankStringIfNull(postalAddressState);
            formDataRecord.E2E_Shipping_Code__c = GlobalUtils.blankStringIfNull(postalAddressPostalCode);
            formDataRecord.E2E_Shipping_Country__c = GlobalUtils.blankStringIfNull(postalAddressCountry);
            formDataRecord.E2E_Shipping_Apartment__c = GlobalUtils.blankStringIfNull(postalAddressApartment);
            formDataRecord.E2E_Post_Address__c = GlobalUtils.blankStringIfNull(postalAddress);
            formDataRecord.E2E_Chief_Accountant__c = GlobalUtils.blankStringIfNull(chiefAccountant);
            formDataRecord.E2E_Code_Word__c = GlobalUtils.blankStringIfNull(codeWord);
            formDataRecord.E2E_Courier_Comments__c = GlobalUtils.blankStringIfNull(cardsDeliveryInformation);
            formDataRecord.E2E_Personal_Office_Email__c = personalOfficeEmail;
            formDataRecord.E2E_Manual_Entry_Legal_Info__c = isManualEntryLegalInfo;

            // Update executive fio only for legal person
            if (formParams.isSoleProprietor == false) {
                formDataRecord.E2E_Executive_Person__c = GlobalUtils.blankStringIfNull(executivePerson) + ', ' + GlobalUtils.blankStringIfNull(executivePersonTitle);
            }
        } else if (activeStep == GlobalUtils.E2ERuSteps.PaymentDetails) {
            // STEP PaymentDetails
            String checkingAccount = pagesMap.get('PAYMENT DETAILS').fields.get('CHECKING ACCOUNT').elementItemsMap.get('DEFAULT VALUE').Value__c;
            String bank = pagesMap.get('PAYMENT DETAILS').fields.get('BANK NAME').elementItemsMap.get('DEFAULT VALUE').Value__c;
            String BIC = pagesMap.get('PAYMENT DETAILS').fields.get('BIC').elementItemsMap.get('DEFAULT VALUE').Value__c;
            String corBankAccount = pagesMap.get('PAYMENT DETAILS').fields.get('CORR BANK ACCOUNT').elementItemsMap.get('DEFAULT VALUE').Value__c;
            String prepayAmount = pagesMap.get('PAYMENT DETAILS').fields.get('PREPAYMENT AMOUNT').elementItemsMap.get('DEFAULT VALUE').Value__c;

            this.formDataValidator.validateIsNotBlank(prepayAmount, 'prepayAmount');

            formDataRecord.E2E_Bank__c = GlobalUtils.blankStringIfNull(bank);
            formDataRecord.E2E_BIC__c = GlobalUtils.blankStringIfNull(BIC);
            formDataRecord.E2E_Cor_Bank_Account__c = GlobalUtils.blankStringIfNull(corBankAccount);
            formDataRecord.E2E_Checking_Account__c = GlobalUtils.blankStringIfNull(checkingAccount);
            formDataRecord.E2E_Bank_Address__c = GlobalUtils.blankStringIfNull(formParams.bankAddress);
            formDataRecord.E2E_Bank_Name_Short__c = GlobalUtils.blankStringIfNull(formParams.bankNameShort);
            formDataRecord.E2E_Bank_OKPO__c = GlobalUtils.blankStringIfNull(formParams.bankOkpo);
            formDataRecord.E2E_Bank_Town__c = GlobalUtils.blankStringIfNull(formParams.bankTown);
            formDataRecord.E2E_Bank_Information_Invalid__c = formParams.isBankInformationInvalid;

            E2E_Form_Ru_General_Settings__c generalSettings = E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu');
            formDataRecord.E2E_Prepay_Amount__c = String.valueOf(Integer.valueOf(prepayAmount) < generalSettings.Prepay_Amount__c ? generalSettings.Prepay_Amount__c : Integer.valueOf(prepayAmount));
        }
        formDataRecord.E2E_Form_URL__c = formParams.generatedUrlWithHash;
        formDataRecord.E2E_Last_Step__c = step;
        formDataRecord.E2E_Source__c = source;
        formDataRecord.E2E_Process_Status__c = formParams.contactDetails + formParams.sfDeduplication1
                + formParams.sfDeduplication2 + formParams.getSparkData + formParams.checkedInBlackList
                + formParams.scoringPassed + formParams.sfDeduplication3 + formParams.sendCrmRequest
                + formParams.companyDetails + formParams.cardOrderDetails + formParams.legalDetails
                + formParams.paymentDetails + formParams.getReport + formParams.createContInTransit
                + formParams.sendMzkRequest + formParams.saveReport;
        formDataRecord.E2E_Form_URL__c = URL.getSalesforceBaseUrl().toExternalForm() + '/e2eFormRu?country=Russia&link=' + formParams.encodedURL; // Save client link
        System.debug('++++ INN IN FORM DATA : ' + formDataRecord.E2E_INN__c);
        this.e2eFormRuDao.updateFormData(formDataRecord);
    }

    public class updateFormDataQueueable implements Queueable{
        public E2EFormData__c formDataRecord;
        public String updateCase;

        public  updateFormDataQueueable (E2EFormData__c formData, String uCase){
            formDataRecord = formData;
            updateCase = uCase;
        }

        public void execute(QueueableContext param1){
            try{
                E2EFormRuDaoImpl e2eFormRuDao = new E2EFormRuDaoImpl();
                if(updateCase == 'firstFormUrl'){
                    E2EFormData__c currentFormData = e2eFormRuDao.getFormDataById(formDataRecord.Id);
                    if(currentFormData.E2E_Form_URL__c == null){
                        e2eFormRuDao.updateFormData(formDataRecord);
                    }
                }
            }
            catch (Exception e){
                ExceptionLogger.sendException( '<br/>E2E updateFormDataQueueable: ' + String.valueOf(e.getMessage()), String.valueOf(e.getStackTraceString()));
            }
        }
    }

    /*******************************************************************************
   *  Name            : getFormData(Id formDataRecordId)
   *  Summary         : get Form Data record by id
   *  CreatedDate     : 18/07/2018
   *  ModifiedDate    : -
   *  Parameters      : Id formDataRecordId
   *  Returns         : form data record id
   ******************************************************************************/
    public E2EFormData__c getFormDataById(Id formDataRecordId) {
        return this.e2eFormRuDao.getFormDataById(formDataRecordId);
    }

    /*******************************************************************************
   *  Name            : changeObjectOwner(Id objectId, String newUserName)
   *  Summary         : change the object owner by id
   *  CreatedDate     : 10/10/2018
   *  ModifiedDate    : -
   *  Parameters      : Id objectId, String newUserName
   *  Returns         : -
   ******************************************************************************/
    public void changeObjectOwner(Id objectId, String newUserName){
        User userInfo = this.e2eFormRuDao.getUserByName(newUserName);
        if(userInfo != null){
            try {
                // change Opportunity owner
                if(String.valueOf(objectId).subString(0, 3) == '006'){
                    Opportunity currentOpportunity = this.e2eFormRuDao.getOpportunityById(objectId);
                    currentOpportunity.OwnerId = userInfo.Id;
                    currentOpportunity.E2E_Status__c = 'Клиент Активен';
                    currentOpportunity.E2E_Last_Activity__c = Datetime.now();
                    this.e2eFormRuDao.updateOpportunity(currentOpportunity);
                    System.debug('***** OPPORTUNITY OBJECT OWNER WAS CHANGED: Id=' + objectId + ', newUser=' + newUserName);
                }

                if(String.valueOf(objectId).subString(0, 3) == '001'){
                    Account currentAccount = this.e2eFormRuDao.getAccountById(objectId);
                    currentAccount.OwnerId = userInfo.Id;
                    this.e2eFormRuDao.updateAccount(currentAccount);
                    System.debug('***** ACCOUNT OBJECT OWNER WAS CHANGED: Id=' + objectId + ', newUser=' + newUserName);
                }

                if(String.valueOf(objectId).subString(0, 3) == '003'){
                    Contact currentContact = this.e2eFormRuDao.getContactById(objectId);
                    currentContact.OwnerId = userInfo.Id;
                    this.e2eFormRuDao.updateContact(currentContact);
                    System.debug('***** CONTACT OBJECT OWNER WAS CHANGED: Id=' + objectId + ', newUser=' + newUserName);
                }
            } catch (Exception e){
                System.debug('***** OBJECT OWNER CAN NOT BE CHANGED: newUserId=' + newUserName);
                throw new E2EFormRuException('SparkWebServiceImpl changeObjectOwner(): can not be changed');
            }
        }
    }

    /*******************************************************************************
    *  Name            : getStepElements(GlobalUtils.E2ERuSteps step)
    *  Summary         : get step elements
    *  CreatedDate     : 11/07/2018
    *  ModifiedDate    : -
    *  Parameters      : GlobalUtils.E2ERuSteps step
    *  Returns         : List<String> elements
    ******************************************************************************/
    private List<String> getStepElements(GlobalUtils.E2ERuSteps step) {
        List<String> elements = new List<String>();
        if (step == GlobalUtils.E2ERuSteps.ContactDetails) {
            elements.addAll(GlobalUtils.getE2ERuStep(GlobalUtils.E2ERuSteps.ContactDetails.name()));
        } else if (step == GlobalUtils.E2ERuSteps.CompanyInformation) {
            elements.addAll(GlobalUtils.getE2ERuStep(GlobalUtils.E2ERuSteps.ContactDetails.name()));
            elements.addAll(GlobalUtils.getE2ERuStep(GlobalUtils.E2ERuSteps.CompanyInformation.name()));
        } else if (step == GlobalUtils.E2ERuSteps.Order || step == GlobalUtils.E2ERuSteps.SummaryOrder) {
            elements.addAll(GlobalUtils.getE2ERuStep(GlobalUtils.E2ERuSteps.ContactDetails.name()));
            elements.addAll(GlobalUtils.getE2ERuStep(GlobalUtils.E2ERuSteps.CompanyInformation.name()));
            elements.addAll(GlobalUtils.getE2ERuStep(GlobalUtils.E2ERuSteps.Order.name()));
        } else if (step == GlobalUtils.E2ERuSteps.LegalDetails) {
            elements.addAll(GlobalUtils.getE2ERuStep(GlobalUtils.E2ERuSteps.ContactDetails.name()));
            elements.addAll(GlobalUtils.getE2ERuStep(GlobalUtils.E2ERuSteps.CompanyInformation.name()));
            elements.addAll(GlobalUtils.getE2ERuStep(GlobalUtils.E2ERuSteps.Order.name()));
            elements.addAll(GlobalUtils.getE2ERuStep(GlobalUtils.E2ERuSteps.LegalDetails.name()));
        } else if (step == GlobalUtils.E2ERuSteps.PaymentDetails) {
            elements.addAll(GlobalUtils.getE2ERuStep(GlobalUtils.E2ERuSteps.ContactDetails.name()));
            elements.addAll(GlobalUtils.getE2ERuStep(GlobalUtils.E2ERuSteps.CompanyInformation.name()));
            elements.addAll(GlobalUtils.getE2ERuStep(GlobalUtils.E2ERuSteps.Order.name()));
            elements.addAll(GlobalUtils.getE2ERuStep(GlobalUtils.E2ERuSteps.LegalDetails.name()));
            elements.addAll(GlobalUtils.getE2ERuStep(GlobalUtils.E2ERuSteps.PaymentDetails.name()));
        } else if (step == GlobalUtils.E2ERuSteps.Congratulations) {
            elements.addAll(GlobalUtils.getE2ERuStep(GlobalUtils.E2ERuSteps.ContactDetails.name()));
            elements.addAll(GlobalUtils.getE2ERuStep(GlobalUtils.E2ERuSteps.CompanyInformation.name()));
            elements.addAll(GlobalUtils.getE2ERuStep(GlobalUtils.E2ERuSteps.Order.name()));
            elements.addAll(GlobalUtils.getE2ERuStep(GlobalUtils.E2ERuSteps.LegalDetails.name()));
            elements.addAll(GlobalUtils.getE2ERuStep(GlobalUtils.E2ERuSteps.PaymentDetails.name()));
            elements.addAll(GlobalUtils.getE2ERuStep(GlobalUtils.E2ERuSteps.Congratulations.name()));
        } else {
            throw new E2EFormRuException('E2EFormRuServiceImpl: step not found');
        }
        return elements;
    }

    /*******************************************************************************
    *  Name            : prepareFormParamsData(E2EFormParams e2EFormParams, String opportunityId)
    *  Summary         : prepare params for E2EFormParams object
    *  CreatedDate     : 26/07/2018
    *  ModifiedDate    : -
    *  Parameters      : E2EFormParams e2EFormParams, String opportunityId
    *  Returns         : -
    ******************************************************************************/
    public void prepareFormParamsData(E2EFormParams e2eFormParams, String opportunityId){
        /*
        // is sole proprietor
        e2eFormParams.sparkId = null;
        e2eFormParams.mainCompanyFullNameSpark = '';
        e2eFormParams.bankNameShort = '';
        e2eFormParams.bankAddress = '';
        e2eFormParams.bankTown = '';
        e2eFormParams.bankOkpo = '';*/
    }

    /*******************************************************************************
   *  Name            : convertToStep(String stepName)
   *  Summary         : convert step name to step enum
   *  CreatedDate     : 12/07/2018
   *  ModifiedDate    : -
   *  Parameters      : String stepName
   *  Returns         : GlobalUtils.E2ERuSteps
   ******************************************************************************/
    private GlobalUtils.E2ERuSteps convertToStep(String stepName) {
        for (GlobalUtils.E2ERuSteps item : GlobalUtils.E2ERuSteps.values()) {
            if (item.name() == stepName) {
                return item;
            }
        }
        throw new E2EFormRuException('E2EFormRuServiceImpl: Could not convert ' + stepName + ' to enum GlobalUtils.E2ERuSteps.');
    }

    /*******************************************************************************
    *  Name            : convertPhone(String phoneNumber)
    *  Summary         : convert phone number to standard format eg (+7 (926) 777-77-77 => 9267777777)
    *  CreatedDate     : 23/07/2018
    *  ModifiedDate    : -
    *  Parameters      : String phoneNumber
    *  Returns         : String
    ******************************************************************************/
    public String convertPhone(String phoneNumber) {
        String phoneRegex = '^(\\+7|7|8)?[\\s\\-]?\\(?([0-9]{3})\\)?[\\s\\-]?([0-9]{3})[\\s\\-]?([0-9]{2})[\\s\\-]?([0-9]{2})$';
        Pattern regexPattern = Pattern.compile(phoneRegex);
        Matcher regexMatcher = regexPattern.matcher(phoneNumber);
        if (regexMatcher.matches() && regexMatcher.groupCount() == 5) {
            return regexMatcher.group(2) + regexMatcher.group(3) + regexMatcher.group(4) + regexMatcher.group(5);
        } else {
            return '';
        }
    }

    public void collectDataFromSpark(Id formDataId, Id accountId, E2EFormParams formParams) {
        E2EFormData__c formDataRecord = this.e2eFormRuDao.getFormDataById(formDataId);
        Account account = this.e2eFormRuDao.getAccountById(accountId);

        formParams.normName = formDataRecord.E2E_Account_Short_Name__c;
        formParams.ogrnSpark = formDataRecord.E2E_OGRN__c;
        formParams.ogrnipSpark = formDataRecord.E2E_OGRN__c;
        formParams.okpoSpark = formDataRecord.E2E_OKPO__c;
        formParams.kppSpark = formDataRecord.E2E_KPP__c;
        formParams.sparkId = formDataRecord.E2E_Spark_Id__c != null ? Decimal.valueOf(formDataRecord.E2E_Spark_Id__c) : 0.0;

        // Address
        formParams.postCodeSpark = GlobalUtils.blankStringIfNull(formDataRecord.E2E_Billing_Code__c);
        formParams.regionSpark = GlobalUtils.blankStringIfNull(formDataRecord.E2E_Billing_State__c);
        formParams.citySpark = GlobalUtils.blankStringIfNull(formDataRecord.E2E_Billing_City__c);
        formParams.streetSpark = GlobalUtils.blankStringIfNull(formDataRecord.E2E_Billing_Str__c);
        formParams.billingApartment = GlobalUtils.blankStringIfNull(formDataRecord.E2E_Billing_Apartment__c);
        formParams.legalAddressSpark = GlobalUtils.blankStringIfNull(formDataRecord.E2E_Legal_Address__c);
        formParams.legalAddressAdditionally = GlobalUtils.blankStringIfNull(formDataRecord.E2E_Billing_Apartment__c);
        formParams.postalAddress = GlobalUtils.blankStringIfNull(formDataRecord.E2E_Post_Address__c);
        formParams.postalAddressAdditionally = GlobalUtils.blankStringIfNull(formDataRecord.E2E_Shipping_Apartment__c);

        List<String> executivePersonData = parserExecutivePerson(formDataRecord.E2E_Executive_Person__c);
        formParams.executiveFio = executivePersonData.get(0);
        formParams.executivePosition = executivePersonData.get(1);
    }

    //***** Transit Integration *****//

    public TransitRequestData prepareTransitRequestData(Id formDataId, E2EFormParams formParams, Map<String, LongFormPage> pagesMap) {
        E2EFormData__c formDataRecord = this.e2eFormRuDao.getFormDataById(formDataId);
        Account account = this.e2eFormRuDao.getAccountById(formDataRecord.E2E_Account_Id__c);

        E2E_Form_Ru_General_Settings__c generalSettings = E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu');
        if (generalSettings == null) {
            throw new E2EFormRuException('Error: prepareTransitRequestData(); E2E_Form_Ru_General_Settings__c does not found');
        }

        E2E_Form_Transit_Settings__c transitSettings = E2E_Form_Transit_Settings__c.getValues('E2EFormRu');
        if (transitSettings == null) {
            throw new E2EFormRuException('Error: prepareTransitRequestData(); E2E_Form_Transit_Settings__c does not found');
        }

        TransitRequestData transitRequestData = new TransitRequestData();
        transitRequestData.Personal  = new List<TransitRequestData.Personal>();
        transitRequestData.Address = new List<TransitRequestData.Address>();

        // Persons
        // Add General Manager
        List<String> executivePersonData = parserExecutivePerson(formDataRecord.E2E_Executive_Person__c);
        String executivePersonFio = executivePersonData.get(0); // Fio
        String executivePersonPosition = executivePersonData.get(1); // Position

        TransitRequestData.Personal generalManager = new TransitRequestData.Personal();
        generalManager.fullName = executivePersonFio;
        preparePersonalFio(generalManager, executivePersonFio);
        generalManager.titleType = 1;

        if (account.Organization_Type__c == 'ИП') {
            generalManager.title = 'Индивидуальный предприниматель';
            generalManager.onBasis = String.format(transitSettings.On_Basis_Svidetelstva__c, new List<String>{account.OGRN_ppr__c, formDataRecord.E2E_Reg_Date__c});
        } else {
            generalManager.title = executivePersonPosition != null ? executivePersonPosition.trim() : '';
            generalManager.onBasis = transitSettings.On_Basis_Ustava__c;
        }
        transitRequestData.Personal.add(generalManager);

        // Address
        TransitRequestData.Address address = new TransitRequestData.Address();
        address.rekType = Integer.valueOf(transitSettings.Cont_Rek_Type__c);
        if (formDataRecord.E2E_Legal_Address__c.startsWith(formDataRecord.E2E_Billing_Code__c)) {
            address.address = String.format('{0} {1}', new List<String>{formDataRecord.E2E_Legal_Address__c, GlobalUtils.blankStringIfNull(formDataRecord.E2E_Billing_Apartment__c)});
        } else {
            address.address = String.format('{0} {1} {2}', new List<String>{formDataRecord.E2E_Billing_Code__c, formDataRecord.E2E_Legal_Address__c, GlobalUtils.blankStringIfNull(formDataRecord.E2E_Billing_Apartment__c)});
        }
        address.postCode = account.ShippingPostalCode;
        address.mailCity = null; // Пока обсуждается этот вопрос на ВЫСОКОМ уровне
        address.mailStreet = account.ShippingStreet;
        address.mailReceiver = generalManager.fullName; // Получатель письма это ген. Директор personal.fullName = formParams.executiveFio
        transitRequestData.address.add(address); // Add address

        // Add Cont
        TransitRequestData.Cont cont = new TransitRequestData.Cont();
        cont.opportunityId = formDataRecord.E2E_Opportunity_Id__c;
        cont.contractNumber = String.format('{0}-{1}', new List<String>{formParams.contractPrefix, formParams.contractCounter});
        cont.inn = formDataRecord.E2E_INN__c;
        cont.okpo = account.OKPO_ppr__c;

        if (account.Organization_Type__c == 'ИП') {
            cont.companyName = formDataRecord.E2E_Account_Short_Name__c;
            //cont.companyName = formDataRecord.E2E_Account_Name__c;
            cont.companyType = 'ИП';
            cont.ogrn = account.OGRN_ppr__c;
            cont.kpp = null;
        } else {
            cont.companyName = formDataRecord.E2E_Account_Short_Name__c;
            //cont.companyName = formDataRecord.E2E_Account_Name__c;
            cont.companyType = account.Organization_Type__c;
            cont.ogrn = account.OGRN_ppr__c;
            cont.kpp = String.valueOf(account.KPP__c);
        }

        cont.checkingAccount = account.Checking_Account__c;
        cont.eqv = Integer.valueOf(transitSettings.Id_Eqv__c);                 // 1
        cont.contractType2 = transitSettings.Contract_Type_Commerce__c;        // 'CNT_SLS_OFFERS'в КФ шаг 3 (категория контагента->МО->обработать карты), в трз переносится автоматически. Только для обычной МО, на кМО проставляем сами
        cont.carParkType = Integer.valueOf(transitSettings.Car_Park_Type__c);  // КФ->ШАГ 1-> коммерческая информация-> тип автопарка->прочее(всегда стандартно- прочее) Это Константа: 1
        cont.carParkForm = Integer.valueOf(transitSettings.Car_Park_Vid__c);   // Это константа: 0. В транзите это прочерк. //
        cont.codeWord = account.Code_Word__c;
        cont.ruleChangeType = transitSettings.Order_Of_Conditions_Change__c;   // Это константа: 'RULCH_NOTIFY'. В транзите: "Уведомление"

        // set partner information and promotion
        if (formParams.sourcePP != null && formParams.sourcePP != '') {
            cont.clientFrom = Integer.valueOf(transitSettings.External_Client__c);// КФ-> коммерческая инфо -> тип канала поиска: 12 (партнер)
            cont.p_standart_promos = transitSettings.External_Standard_Promos__c;
        } else {
            cont.clientFrom = Integer.valueOf(transitSettings.Internal_Client__c);// КФ-> коммерческая инфо -> тип канала поиска: 11 (внутренний клиент, pertolplus)
            cont.p_standart_promos = transitSettings.Standard_Promos__c;
        }

        // Init tariff
        E2E_Ru_Product_Settings__c productSettings = E2E_Ru_Product_Settings__c.getValues(formDataRecord.E2E_Product_Id__c);
        if (productSettings != null && formDataRecord.E2E_Tariff_Id__c != null) {
            if (formDataRecord.E2E_Product_Id__c == GlobalUtils.E2EProduct.PetrolPlus_Rover.name()) {
                if (formDataRecord.E2E_Tariff_Id__c.substring(0, 1) == '2') {
                    cont.tarif = Integer.valueOf(formDataRecord.E2E_Num_Cards__c >= generalSettings.Number_of_Cards_Card__c ? productSettings.Chosen_Contract__c : productSettings.Chosen_Card__c);
                } else {
                    cont.tarif = Integer.valueOf(formDataRecord.E2E_Num_Cards__c >= generalSettings.Number_of_Cards_Card__c ? productSettings.Optimal_Contract__c : productSettings.Optimal_Card__c);
                }
            } else if (formDataRecord.E2E_Product_Id__c == GlobalUtils.E2EProduct.Partner_Rover.name()) {
                if (formDataRecord.E2E_Tariff_Id__c.substring(0, 1) == '1') {
                    cont.tarif = Integer.valueOf(productSettings.Optimal_Card__c);
                } else {
                    cont.tarif = Integer.valueOf(productSettings.Optimal_Contract__c);
                }
            } else if (formDataRecord.E2E_Product_Id__c == GlobalUtils.E2EProduct.PetrolPlus_Gaz.name()) {
                if (formDataRecord.E2E_Tariff_Id__c.substring(0, 1) == '1') {
                    cont.tarif = Integer.valueOf(productSettings.Optimal_Card__c);
                } else {
                    cont.tarif = Integer.valueOf(productSettings.Optimal_Contract__c);
                }
            } else {
                throw new E2EFormRuException('Error: prepareTransitRequestData(); product ' + formDataRecord.E2E_Product_Id__c + ' does not found');
            }
        }

        // Init promocodes
        if (formParams.promocodeIdInTransit != null) {
            cont.promoCode = Integer.valueOf(formParams.promocodeIdInTransit);
        } else {
            cont.promoCode = 0;
        }

        Integer prepayAmount = 0;
        if (Integer.valueof(formDataRecord.E2E_Prepay_Amount__c) < generalSettings.Prepay_Amount__c) {
            prepayAmount = Integer.valueOf(generalSettings.Prepay_Amount__c);
        } else {
            prepayAmount = Integer.valueOf(formDataRecord.E2E_Prepay_Amount__c);
        }

        if (formDataRecord.E2E_Overdraft_srv__c == true) {
            cont.factProsrochki = Integer.valueOf(transitSettings.Payment_For_Overdue__c); // 890 если прошёл скоринг и выбрал овердрафт
            cont.lgotniyPeriod = Integer.valueOf(transitSettings.Lgotniy_Period__c);       // 0 если прошёл скоринг и выбрал овердрафт
            cont.procentPoCreditu = transitSettings.Credit_Percent__c;                     // 0.09 если прошёл скоринг и выбрал овердрафт
            cont.prepayAmount = 100;
            cont.tipCredita = Integer.valueOf(transitSettings.Credit_Type__c);             // платный если прошёл скоринг и выбрал овердрафт
            cont.contractType = Integer.valueOf(transitSettings.Contract_Type_Fin_Overdraft__c); // 16 - Мультиоферта, 17 - Кредитный овердрафт
            cont.tipPeni = transitSettings.Type_Peni__c;                                   // 'Процентная ставка(%в день)' если прошёл скоринг и выбрал овердрафт
            cont.znacheniePeni = transitSettings.Value_Peni__c;                            // 0.1 если прошёл скоринг и выбрал овердрафт
            cont.dopustimayaZadolzenostSumma = Integer.valueOf(transitSettings.Allowed_Debt_Sum__c); // 50000 если прошёл скоринг и выбрал овердрафт
            cont.dopustimayaZadolzenostValuta = Integer.valueOf(transitSettings.Allowed_Debt_Currency__c); // рубли(0) если прошёл скоринг и выбрал овердрафт
            cont.znachenieOvedrafta = Integer.valueOf(transitSettings.Overdraft_Value__c); // -50000 если прошёл скоринг и выбрал овердрафт
            cont.opoveshatPoEmail = null;                                                  // проставляем вручную - в письме значения нет
            cont.overdrSumm = Integer.valueOf(transitSettings.Overdraft_Sum__c);           // -50000 если прошёл скоринг и выбрал овердрафт
            cont.uslugaDoveria = transitSettings.Usluga_Doveria__c;                        // 'N' если прошёл скоринг и выбрал овердрафт
            cont.bezDS = transitSettings.Bez_DS__c;                                        // 'N' если прошёл скоринг и выбрал овердрафт
        } else {
            cont.contractType = Integer.valueOf(transitSettings.Contract_Type_Fin_Multioffer__c); // 16 - Мультиоферта, 17 - Кредитный овердрафт
            cont.prepayAmount = prepayAmount;
        }

        cont.contractForm = transitSettings.Contract_Form__c; // это константа.
        cont.contractType1 = transitSettings.Contract_Type_Service__c; // Это константа!в КФ шаг 3 (категория контагента->МО->обработать карты), в трз переносится автоматически.
        cont.personalManager = formDataRecord.E2E_Personal_Manager_srv__c == true ? 1 : 0;
        cont.curierDelivery = formDataRecord.E2E_Document_Delivery_srv__c == true ? 1 : 0;
        cont.bic = formDataRecord.E2E_BIC__c;

        // Bank parameters
        cont.bankNameFull = formDataRecord.E2E_Bank__c;
        cont.bankNameShort = formDataRecord.E2E_Bank_Name_Short__c != null ? formDataRecord.E2E_Bank_Name_Short__c : formDataRecord.E2E_Bank__c;
        cont.bankBic =  formDataRecord.E2E_BIC__c; // БИК РКЦ банка из Дадаты не приходит, поэтому заполняем обычным БИК банка (обязательное поле)
        cont.corBankAccount = formDataRecord.E2E_Cor_Bank_Account__c;
        cont.bankInn = null; // Уточняется: БРАТЬ ли ИНН! Нужно для сравнений
        cont.bankKpp = null; // Уточняется: БРАТЬ ли КПП! Нужно для сравнений
        cont.bankOkpo = formDataRecord.E2E_Bank_OKPO__c;
        cont.bankTown = formDataRecord.E2E_Bank_Town__c;
        cont.bankAddress = formDataRecord.E2E_Bank_Address__c;

        cont.companyPhone = String.format('+7{0}', new List<String>{convertPhone(formDataRecord.E2E_Contact_Phone__c)});
        cont.p_is_for_fin_sms = 1; // Это константа (можно не передавать) указ в кф, шаг 1 (Моб. для получения уведомлений финансового характера) в трз переносится автоматически
        cont.p_is_mobile = 1; // Это константа (можно не передавать) указ в кф, шаг 1 (Моб. для получения справочной информации) в трз переносится автоматически
        cont.companyEmail = formDataRecord.E2E_Contact_Email__c;
        cont.p_invoice_doc_num = String.format('{0}-{1}', new List<String>{formParams.invoicePrefix, formParams.invoiceCounter}); // Это генерируется репорт сервером
        cont.p_invoice_sum = prepayAmount;
        cont.p_invoice_sum_nds = (( prepayAmount / (1 + transitSettings.VAT__c) ) * transitSettings.VAT__c).setScale(2);
        //cont.p_invoice_article = String.format('Оплата по договору от {0} № {1}-{2}', new List<String>{DateTime.now().format('dd.MM.YYYY'), formParams.contractPrefix, formParams.contractCounter}); // 'Оплата по договору от (дата, сегодняшняя) № (договора)'
        cont.p_invoice_article = String.format(transitSettings.Article_Oplata_Po_Dogovoru__c, new List<String>{DateTime.now().format('dd.MM.YYYY'), formParams.contractPrefix, formParams.contractCounter});
        cont.emailForLK = formDataRecord.E2E_Personal_Office_Email__c;
        cont.postcode = account.BillingPostalCode;
        cont.contractDate = DateTime.now().format('dd.MM.YYYY');

        transitRequestData.cont = cont;

        return transitRequestData;

    }

    public TransitDocLinkRequestData prepareTransitDocLinkRequestData(ReportResponseData responseData, E2EFormParams formParams) {
        TransitDocLinkRequestData requestData = new TransitDocLinkRequestData();

        // set cont id
        requestData.idCont = formParams.transitContId;

        // init document list
        requestData.documentList = new List<TransitDocLinkRequestData.DocumentToLink>();

        for (ReportResponseData.ReportDocument document : responseData.reportDocumentList) {
            if (document.path != null && document.path.pdf != null && document.path.pdf != '') {
                TransitDocLinkRequestData.DocumentToLink docLink = new TransitDocLinkRequestData.DocumentToLink();
                docLink.docTypeId = document.reportTypeId;
                docLink.format = 'pdf';
                docLink.idLink = document.path.pdf;
                requestData.documentList.add(docLink);
            }
        }
        return requestData;
    }

    @TestVisible
    private void preparePersonalFio(TransitRequestData.Personal personal, String fio) {
        if (fio != null) {
            List<String> fioList = fio.split(' ');
            if (fioList.size() == 3) {
                personal.name = fioList.get(1);
                personal.surname = fioList.get(0);
                personal.parentName = fioList.get(2);
            } else if (fioList.size() == 2) {
                personal.name = fioList.get(1);
                personal.surname = fioList.get(0);
                personal.parentName = ' ';
            } else {
                personal.name = ' ';
                personal.surname = ' ';
                personal.parentName = ' ';
            }
        } else {
            personal.name = ' ';
            personal.surname = ' ';
            personal.parentName = ' ';
        }
    }

    //******** MZK Integration ********//

    public MZKRequest prepareMzkRequest(Id formDataId, E2EFormParams formParams) {
        E2EFormData__c formDataRecord = this.e2eFormRuDao.getFormDataById(formDataId);
        E2E_Form_MZK_Settings__c mzkSettings = E2E_Form_MZK_Settings__c.getValues('E2EFormRu');

        MZKRequest mzkRequest = new MZKRequest();
        if (mzkSettings != null) {
            mzkRequest.Cards = new MZKRequest.MzkCards();
            mzkRequest.Cards.sendType = 3;
            mzkRequest.Cards.transitId = formParams.transitContId;
            mzkRequest.Cards.requestDescription = GlobalUtils.blankStringIfNull(formDataRecord.E2E_Courier_Comments__c);
            mzkRequest.Cards.logUser = mzkSettings.Log_User__c; //?
            mzkRequest.Cards.isTemplate = 0;
            mzkRequest.Cards.eqv = 1;
            mzkRequest.Cards.serviceId = mzkSettings.Service_Ids__c;
            mzkRequest.Cards.limitVal = mzkSettings.Limit_Values__c;
            mzkRequest.Cards.limitTypeId = mzkSettings.Limit_Type_Ids__c;
            mzkRequest.Cards.isCommon = mzkSettings.Is_Common__c;
            mzkRequest.Cards.isRuble = mzkSettings.Is_Ruble__c;
            mzkRequest.Cards.totalLimitValue = null;
            mzkRequest.Cards.totalLimitType = null;
            mzkRequest.Cards.cardsNumber = Integer.valueOf(formDataRecord.E2E_Num_Cards__c);
            mzkRequest.Cards.cardDescr = 'e2e';
            mzkRequest.Cards.serviceGroups = mzkSettings.Service_Groups__c;

            // Add product Id
            E2E_Ru_Product_Settings__c productSettings = E2E_Ru_Product_Settings__c.getValues(formDataRecord.E2E_Product_Id__c);
            if (productSettings != null) {
                mzkRequest.Cards.productId = Integer.valueOf(productSettings.Product_Id__c);
            } else {
                throw new E2EFormRuException('Error: prepareMzkRequest(); product ' + formDataRecord.E2E_Product_Id__c + ' does not found');
            }

        } else {
            throw new E2EFormRuException('MZK Setting does not found');
        }
        return mzkRequest;
    }

    //*********** Crm Integration ********//

    public CrmTask prepareCrmRequest(String phone, String email, String inn, List<Opportunity> opportunities) {
        E2E_Form_CRM_Settings__c crmSettings = E2E_Form_CRM_Settings__c.getValues('E2EFormRu');
        CrmTask task = new CrmTask();
        if (crmSettings != null) {
            task.OwnerId = crmSettings.Task_OwnerId__c;
            task.SubjectId = crmSettings.Task_SubjectId__c;
            task.Title = crmSettings.Task_Title__c;
            task.CaseOriginCode = Integer.valueOf(crmSettings.Task_Case_Origin_Code__c);
            task.Description = String.format('Тел: {0}; e-mail: {1}; ИНН: {2}; ', new List<String>{phone, email, inn});

            // Add CONT_ID in to Description
            List<String> transitIds = new List<String>();
            for (Opportunity opportunity : opportunities) {
                if (opportunity.Transit_ID__c != null) {
                    transitIds.add(opportunity.Transit_ID__c);
                }
            }

            if ( ! transitIds.isEmpty() ) {
                task.Description += 'CONT_IDS: ' + String.join(transitIds, ',');
            }
        } else {
            throw new E2EFormRuException('Crm Setting does not found');
        }
        return task;
    }


    //******* Duplicate Process *****//

    /*******************************************************************************
    *  Name            : duplicateLeadProcess(Map<String, LongFormPage> pagesMap)
    *  Summary         : duplicate lead
    *  CreatedDate     : 10/08/2018
    *  ModifiedDate    : -
    *  Parameters      : Map<String, LongFormPage> pagesMap
    *  Returns         : void
    ******************************************************************************/
    public void duplicateLeadProcess(Map<String, LongFormPage> pagesMap) {
        System.debug('***** DEDUPLICATION LEAD');
        String phone = convertPhone(pagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c);
        String email = pagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c;

        this.formDataValidator.validateMobilePhone(phone);
        this.formDataValidator.validateEmail(email);

        duplicateLeadProcess(email, phone);
    }

    @Future
    private static void duplicateLeadProcess(String email, String phone) {
        System.debug('***** DEDUPLICATION LEAD FUTURE');
        try{
            E2EFormRuDaoImpl e2EFormRuDao = new E2EFormRuDaoImpl();
            List<Lead> duplicateLeadsList = e2EFormRuDao.getDuplicatedLeads(email, phone);
            System.debug('****** DEDUPLICATION LEAD FUTURE: find leads by email:'+ email +' or phone:' + phone + ' => ' + duplicateLeadsList);

            if ( ! duplicateLeadsList.isEmpty() ) {

                Set<Id> leadOwnerIds = new Set<Id>();
                for (Lead leadItem : duplicateLeadsList) {
                    if (leadItem.OwnerId != null) {
                        leadOwnerIds.add(leadItem.OwnerId);
                    }
                }
                system.debug('LEAD OWNER IDS: ' + leadOwnerIds);
                Map<Id, User> usersMap = e2eFormRuDao.getUsersMapByIds(leadOwnerIds);

                Set<Id> userIds = new Set<Id>();
                Set<String> externalEmails = new Set<String>();
                prepareAddressesForNotification(userIds, externalEmails, GlobalUtils.E2ERuGroupsNotification.CallCenter);
                System.debug('userIds: ' + userIds);
                List<Messaging.Email> messages = new List<Messaging.Email>();

                //params for each group of recipients ids (each ids set corresponds to particular lead that is being used in template params)
                Map<Set<Id>, Map<String, Object>> emailParams = new Map<Set<Id>, Map<String, Object>>();

                for (Lead lead : duplicateLeadsList) {
                    lead.Status = 'Disqualified';
                    lead.Lead_Status_Specific__c = 'Switched to E2E';

                    String ownerName = 'Undefined';
                    Set<Id> userIdsForLead = new Set<Id>(userIds);
                    if(lead.Owner.Type == 'User') {
                        if (usersMap.containsKey(lead.OwnerId)) {
                            User ownerUser = usersMap.get(lead.OwnerId);

                            // add TeamLead to notification
                            if (ownerUser.ManagerId != null) {
                                userIdsForLead.add(ownerUser.ManagerId);
                            }

                            // add Owner to notification
                            if (ownerUser.Id != null) {
                                userIdsForLead.add(ownerUser.Id);
                            }

                            // set owner name in email subject
                            if (ownerUser.Name != null) {
                                ownerName = ownerUser.Name;
                            }
                        }
                    } else if(lead.Owner.Type == 'Queue'){
                        //Will be sent only to CallCenter
                        System.debug('LEAD OWNER TYPE - QUEUE');
                        if (lead.Owner.Name != null) {
                            ownerName = lead.Owner.Name;
                        }
                    }

                    //fill emailParams map up with ids and corresponding params
                    emailParams.put(
                            userIdsForLead,
                            new Map<String, Object>{
                                    '/$lead.Owner.Name$/' => ownerName,
                                    '/$domainUrl$/' => E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu').Domain_Url__c,
                                    '/$lead.Id$/' => lead.Id,
                                    '/$lead.Name$/' => lead.Name,
                                    '/$lead.INN__c$/' => lead.INN__c == null ? 'none' : lead.INN__c,
                                    '/$lead.Phone$/' => lead.Phone == null ? 'none' : lead.Phone
                            }
                    );

//                    String body = getEmailBodyDisqualificationLeadForSalesPushEmail(lead);
//                    String subject = 'Russia E2E Disqualification Lead: ' + ownerName;
//                    for (Id currentUserId : userIdsForLead) {
//                        Messaging.SingleEmailMessage emailMessage = EmailGenerator.prepareHtmlEmailToTarget(currentUserId, subject, body);
//                        messages.add(emailMessage);
//                    }
                }

                //invoke method which returns prepared template with htmlBody and subject set up for each ids set
                //and send emails to users
                Map<Set<Id>, EmailTemplate> templatesByIds = EmailGenerator.getEmailTemplatesMap(GlobalUtils.EmailTemplateDevName.E2E_RU_Disqualification_Lead, emailParams);
                for (Set<Id> userIdsForLead : templatesByIds.keySet()) {
                    EmailTemplate templateForCurrentLead = templatesByIds.get(userIdsForLead);
                    for (Id currentUserId : userIdsForLead) {
                        Messaging.SingleEmailMessage emailMessage = EmailGenerator.prepareHtmlEmailToTarget(
                                currentUserId,
                                templateForCurrentLead.Subject,
                                templateForCurrentLead.HtmlValue
                        );
                        messages.add(emailMessage);
                    }
                }
                e2EFormRuDao.updateLeads(duplicateLeadsList);

                if ( ! Test.isRunningTest() ) {
                    if ( ! messages.isEmpty() ) {
                        System.debug('MESSAGES: ' + messages);
                        Messaging.sendEmail(messages);
                    }
                }
            }
        } catch (Exception e) {
            String notificationMessage = '<br/>E2E method @future duplicateLeadProcess(): ' + String.valueOf(e.getMessage());
            ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
        }
    }

    // Проверка, что клиент только сейчас заходил, вышел и снова зашел
    /*******************************************************************************
    *  Name            : deduplicateE2EClient()
    *  Summary         : Verifying that a customer has recently logged in
    *  CreatedDate     : 10/08/2018
    *  ModifiedDate    : -
    *  Parameters      : String name, Map<String, LongFormPage> pagesMap
    *  Returns         : Map<String, String> - map contains five key: 1. accountId  2. opportunityId 3. contactId 4. formDataId 5. statusCode
    ******************************************************************************/
    public Map<String, String> deduplicateE2EClient(String name, Map<String, LongFormPage> pagesMap) {
        System.debug('*********E2E method deduplicateE2EClient ****************');
        String phone = convertPhone(pagesMap.get('CONTACT DETAILS').fields.get('MOBILE NUMBER').elementItemsMap.get('DEFAULT VALUE').Value__c);
        String email = GlobalUtils.blankStringIfNull(pagesMap.get('CONTACT DETAILS').fields.get('EMAIL ADDRESS').elementItemsMap.get('DEFAULT VALUE').Value__c);

        if (phone != '' && email != '') {
            List<Contact> contacts = this.e2eFormRuDao.getContactsByNamePhoneEmail(name, phone, email, 'e2edefault@default.ru');
            System.debug('deduplicateE2EClient: ' + contacts);
            if ( ! contacts.isEmpty() ) {
                List<E2EFormData__c> formDataList = this.e2eFormRuDao.getFormDataByAccountIdAndContactId(contacts.get(0).AccountId, contacts.get(0).Id);
                if ( ! formDataList.isEmpty() ) {
                    if (formDataList.get(0).E2E_Opportunity_Id__c != null) {
                        Opportunity e2eOpportunity = this.e2eFormRuDao.getOpportunityById(formDataList.get(0).E2E_Opportunity_Id__c);
                        if (e2eOpportunity != null && e2eOpportunity.StageName != 'Awaiting payment' && e2eOpportunity.IsClosed == false) {
                            return new Map<String, String> {
                                    'accountId' => formDataList.get(0).E2E_Account_Id__c,
                                    'opportunityId' => formDataList.get(0).E2E_Opportunity_Id__c,
                                    'contactId' => formDataList.get(0).E2E_Contact_Id__c,
                                    'formDataId' => formDataList.get(0).Id,
                                    'statusCode' => GlobalUtils.DeduplicationStatus.E2EProcess.name()
                            };
                        }
                    }
                }
            }
        }
        return new Map<String, String>();
    }

    /*******************************************************************************
    *  Name            : deduplicationAccountProcess()
    *  Summary         : duplicate account
    *  CreatedDate     : 10/08/2018
    *  ModifiedDate    : -
    *  Parameters      : String INN, Id e2eAccountId, Id e2eContactId, Id e2eOpportunityId, String statusCode
    *  Returns         : Map<String, String> - map contains two key: 1. accountId  2. statusCode
    ******************************************************************************/
    public E2EFormRuDeduplicationResult deduplicationAccountProcess(String INN, String email, Id e2eAccountId, Id e2eContactId, Id e2eOpportunityId, Id formDataId) {
        // init deduplication result class
        E2EFormRuDeduplicationResult deduplicationResult = new E2EFormRuDeduplicationResult();
        deduplicationResult.formDataId = formDataId;
        deduplicationResult.e2eAccount = this.e2eFormRuDao.getAccountById(e2eAccountId);
        deduplicationResult.e2eContact = this.e2eFormRuDao.getContactById(e2eContactId);
        deduplicationResult.e2eOpportunity = this.e2eFormRuDao.getOpportunityById(e2eOpportunityId);

        return deduplicationAccountProcess(INN, email, deduplicationResult);
    }

    /*******************************************************************************
    *  Name            : deduplicationAccountProcess()
    *  Summary         : duplicate account by INN and email
    *  CreatedDate     : 25/09/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : E2EFormRuDeduplicationResult
    ******************************************************************************/
    public E2EFormRuDeduplicationResult deduplicationAccountProcess(String INN, String email, E2EFormRuDeduplicationResult deduplicationResult) {
        List<Account> duplicateAllAccounts = this.e2eFormRuDao.getAccountsByINN(INN);
        System.debug('******* DEDUPLICATION PROCESS: duplicateAllAccounts size ' + duplicateAllAccounts.size());
        System.debug('******* DEDUPLICATION PROCESS: (Search account by INN): Find by INN=' + INN + ' ' + duplicateAllAccounts);

        List<Account> duplicateAccountsList = excludeAccounts(duplicateAllAccounts, deduplicationResult.e2eAccount);
        System.debug('******* DEDUPLICATION PROCESS: duplicateAccountsList size ' + duplicateAccountsList.size());

        System.debug('******* DEDUPLICATION PROCESS: after exclude account ' + deduplicationResult.e2eAccount + '; resultList: ' + duplicateAccountsList);

        if (duplicateAccountsList.isEmpty()) {
            System.debug('******* DEDUPLICATION PROCESS: (Search account by INN): Does not found any account by INN=' + INN);

            deduplicationResult.innDuplication = false;
            Id e2eContactIdForExclude = deduplicationResult.e2eContact != null ? deduplicationResult.e2eContact.Id : null;
            String domain = email.substringAfter('@');
            Set<String> setPublicDomains = PublicEmailDomains__c.getAll().keySet();
            if (setPublicDomains.contains(domain)) {
                System.debug('******* DEDUPLICATION PROCESS: Search contact by email');
                List<Contact> contactListFindByEmail = searchDuplicatedContactsByEmail(email, e2eContactIdForExclude);

                if (! contactListFindByEmail.isEmpty() ) {
                    Set<Id> accountsIds = new Set<Id>();
                    for(Contact contact : contactListFindByEmail){
                        accountsIds.add(contact.AccountId);
                    }
                    List<Account> accountsByEmail = this.e2eFormRuDao.getAccountsByIds(accountsIds).values();
                    deduplicationResult.sfAccount = accountsByEmail.get(0);
                    for(Account account : accountsByEmail){
                        Boolean transferToService = checkingTransferToService(account);
                        if(transferToService) {
                            deduplicationResult.sfAccount = account;
                            deduplicationResult.statusCode = GlobalUtils.DeduplicationStatus.Service.name();
                            return deduplicationResult;
                        }
                    }
                    checkingOpportunityTransfer(deduplicationResult);
                    return deduplicationResult;
                } else {
                    return deduplicationResult;
                }
            } else {
                System.debug('******* DEDUPLICATION PROCESS: Search contact by domain=' + domain);
                List<Contact> contactListByDomain = searchDuplicatedContactsByDomain(domain, e2eContactIdForExclude);
                if (! contactListByDomain.isEmpty()) {
                    Set<Id> accountsIds = new Set<Id>();
                    for(Contact contact : contactListByDomain){
                        accountsIds.add(contact.AccountId);
                    }
                    List<Account> accountsByDomain = this.e2eFormRuDao.getAccountsByIds(accountsIds).values();
                    deduplicationResult.sfAccount = accountsByDomain.get(0);
                    for(Account account : accountsByDomain){
                        Boolean transferToService = checkingTransferToService(account);
                        if(transferToService) {
                            deduplicationResult.sfAccount = account;
                            deduplicationResult.statusCode = GlobalUtils.DeduplicationStatus.Service.name();
                            return deduplicationResult;
                        }
                    }
                    checkingOpportunityTransfer(deduplicationResult);
                    return deduplicationResult;
                } else {
                    return deduplicationResult;
                }
            }
        } else if (duplicateAccountsList.size() == 1) {
            System.debug('******* DEDUPLICATION PROCESS (Search account by INN): Find account by INN=' + INN + '; accountId=' + duplicateAccountsList.get(0).Id);
            deduplicationResult.innDuplication = true;
            deduplicationResult.sfAccount = duplicateAccountsList.get(0);

            Id e2eContactIdForExclude = deduplicationResult.e2eContact != null ? deduplicationResult.e2eContact.Id : null;
            String domain = email.substringAfter('@');
            Set<String> setPublicDomains = PublicEmailDomains__c.getAll().keySet();
            if (setPublicDomains.contains(domain)) {
                System.debug('******* DEDUPLICATION PROCESS: Search contact by email');
                List<Contact> contactListFindByEmail = searchDuplicatedContactsByEmail(email, e2eContactIdForExclude);
                if (! contactListFindByEmail.isEmpty() ) {
                    Set<Id> accountsIds = new Set<Id>();
                    for(Contact contact : contactListFindByEmail){
                        accountsIds.add(contact.AccountId);
                    }
                    List<Account> accountsByEmail = this.e2eFormRuDao.getAccountsByIds(accountsIds).values();
                    for(Account account : accountsByEmail){
                        Boolean transferToService = checkingTransferToService(account);
                        if(transferToService) {
                            deduplicationResult.statusCode = GlobalUtils.DeduplicationStatus.Service.name();
                            return deduplicationResult;
                        }
                    }
                }
            } else {
                System.debug('******* DEDUPLICATION PROCESS: Search contact by domain=' + domain);
                List<Contact> contactListByDomain = searchDuplicatedContactsByDomain(domain, e2eContactIdForExclude);
                if (! contactListByDomain.isEmpty()) {
                    Set<Id> accountsIds = new Set<Id>();
                    for(Contact contact : contactListByDomain){
                        accountsIds.add(contact.AccountId);
                    }
                    List<Account> accountsByDomain = this.e2eFormRuDao.getAccountsByIds(accountsIds).values();
                    for(Account account : accountsByDomain){
                        Boolean transferToService = checkingTransferToService(account);
                        if(transferToService) {
                            deduplicationResult.statusCode = GlobalUtils.DeduplicationStatus.Service.name();
                            return deduplicationResult;
                        }
                    }
                }
            }

            deduplicationSingleAccount(deduplicationResult);
            return deduplicationResult;
        } else {
            // Если Account больше одного, то все, ошибка
            System.debug('******* DEDUPLICATION PROCESS (Search account by INN): Find more one account accountList= ' + duplicateAccountsList);
            throw new E2EFormRuException('******* DEDUPLICATION PROCESS (Search account by INN): Find more one account accountList= ' + duplicateAccountsList);
        }
    }

    private List<Account> excludeAccounts(List<Account> accountList, Account excludeAccount)  {
        if (excludeAccount != null && excludeAccount.Id != null) {
            List<Account> freshAccountList = new List<Account>();
            for (Account account : accountList) {
                if (account.Id != excludeAccount.Id) {
                    freshAccountList.add(account);
                }
            }
            return freshAccountList;
        }
        return accountList;
    }

    private void deduplicationSingleAccount(E2EFormRuDeduplicationResult deduplicationResult) {
        if (checkingTransferToService(deduplicationResult.sfAccount)) {
            deduplicationResult.statusCode = GlobalUtils.DeduplicationStatus.Service.name();
            System.debug('******* DEDUPLICATION PROCESS: transfer account to Service; accountId=' + deduplicationResult.sfAccount.Id);
        } else {
            System.debug('******* DEDUPLICATION PROCESS: check opportunity status;');
            checkingOpportunityTransfer(deduplicationResult);
        }
    }

    private List<Contact> searchDuplicatedContactsByEmail(String email, Id contactId) {
        List<Contact> withoutExtraContactList = new List<Contact>();
        for (Contact contact : this.e2eFormRuDao.getContactsByEmail(email)) {
            if (contact.Id != contactId) {
                withoutExtraContactList.add(contact);
            }
        }
        return withoutExtraContactList;
    }

    private List<Contact> searchDuplicatedContactsByDomain(String domain, Id contactId) {
        List<Contact> withoutExtraContactList = new List<Contact>();
        for (Contact contact : this.e2eFormRuDao.getContactsByDomain(domain)) {
            if (contact.Id != contactId) {
                withoutExtraContactList.add(contact);
            }
        }
        return withoutExtraContactList;
    }

    public E2EFormRuDeduplicationResult transferCustomer(E2EFormRuDeduplicationResult deduplicationResult) {
        if (deduplicationResult.statusCode == GlobalUtils.DeduplicationStatus.Service.name()) {
            transferToService(deduplicationResult);
        } else if (deduplicationResult.statusCode == GlobalUtils.DeduplicationStatus.Inbound.name()) {
            transferToInbound(deduplicationResult);
        } else if (deduplicationResult.statusCode == GlobalUtils.DeduplicationStatus.KO.name()) {
            transferToKO(deduplicationResult);
        } else if (deduplicationResult.statusCode == GlobalUtils.DeduplicationStatus.E2EProcess.name()) {
            transferToE2E(deduplicationResult);
        }
        return deduplicationResult;
    }

    /*******************************************************************************
    *  Name            : checkingTransferToService(Account account)
    *  Summary         : check that account must transferred to Service
    *  CreatedDate     : 10/08/2018
    *  ModifiedDate    : -
    *  Parameters      : Account account
    *  Returns         : Boolean
    ******************************************************************************/
    private Boolean checkingTransferToService(Account account) {
        System.debug('******* DEDUPLICATION PROCESS: start check transfer to Service');
        Date nowDate = Date.Today();
        if (account.Last_pump_date__c >= nowDate.addYears(-1)) {
            System.debug('******* DEDUPLICATION PROCESS: check transfer to Service = TRUE');
            return true;
        } else if (account.Opportunities != null && ! account.Opportunities.isEmpty() ) {
            for (Opportunity opportunity : account.Opportunities) {
                if (opportunity.StageName == 'Moved to Start' && opportunity.CloseDate >= nowDate.addMonths(-6)) {
                    System.debug('******* DEDUPLICATION PROCESS: check transfer to Service = TRUE');
                    return true;
                }
            }
        }
        System.debug('******* DEDUPLICATION PROCESS: start check transfer to Service = FALSE');
        return false;
    }

    /*******************************************************************************
    *  Name            : checkingOpportunityTransfer()
    *  Summary         : check the conditions under which  opportunity must transferred to Service or KO
    *  CreatedDate     : 10/08/2018
    *  ModifiedDate    : -
    *  Parameters      : Account sfAccount, Account e2eAccount, Contact e2eContact, Opportunity e2eOpportunity, String statusCode
    *  Returns         : Map<String, String> - result parameters
    ******************************************************************************/
    private void checkingOpportunityTransfer(E2EFormRuDeduplicationResult deduplicationResult) {
        List<Opportunity> opportunities = deduplicationResult.sfAccount.Opportunities;
        System.debug('******* DEDUPLICATION PROCESS: all opportunities = ' + opportunities);

        if (opportunities.size() == 0) {
            System.debug('******* DEDUPLICATION PROCESS: account not have opportunity; Go to E2E');
            deduplicationResult.statusCode = GlobalUtils.DeduplicationStatus.E2EProcess.name(); // go to E2E process
        } else if (opportunities.size() == 1) {
            System.debug('******* DEDUPLICATION PROCESS: account have one opportunity; opportunityId=' + opportunities.get(0).Id);
            if (checkOpportunityGoToKO(opportunities.get(0))) {
                System.debug('******* DEDUPLICATION PROCESS: go to KO');
                // go to KO
                deduplicationResult.sfOpportunity = opportunities.get(0);
                deduplicationResult.statusCode = GlobalUtils.DeduplicationStatus.KO.name();
            } else {
                System.debug('******* DEDUPLICATION PROCESS: go to E2E');
                // go to E2E
                deduplicationResult.sfOpportunity = opportunities.get(0);
                deduplicationResult.statusCode = GlobalUtils.DeduplicationStatus.E2EProcess.name();
            }
        } else if (opportunities.size() == 2) {
            System.debug('******* DEDUPLICATION PROCESS: account have two opportunity; opportunities' + opportunities);
            Opportunity firstOpportunity = opportunities.get(0);
            Opportunity secondOpportunity = opportunities.get(1);
            if (shouldOpportunityBeTransferredToInbound(firstOpportunity, secondOpportunity)) {
                // go to Inbound
                System.debug('******* DEDUPLICATION PROCESS: Go to Inbound;');
                deduplicationResult.sfOpportunity = opportunities.get(0);
                deduplicationResult.statusCode = GlobalUtils.DeduplicationStatus.Inbound.name();
            } else if (shouldOpportunityBeTransferredToKO(firstOpportunity, secondOpportunity)) {
                // go to KO
                System.debug('******* DEDUPLICATION PROCESS: Go to KO;');
                if (opportunityInProgress(firstOpportunity)) {  // check opportunity stage
                    deduplicationResult.sfOpportunity = firstOpportunity;
                    deduplicationResult.statusCode = GlobalUtils.DeduplicationStatus.KO.name();
                } else {
                    deduplicationResult.sfOpportunity = secondOpportunity;
                    deduplicationResult.statusCode = GlobalUtils.DeduplicationStatus.KO.name();
                }
            } else {
                // go to E2E
                System.debug('******* DEDUPLICATION PROCESS: Go to E2E;');
                if (opportunityInProgress(firstOpportunity)) {
                    deduplicationResult.sfOpportunity = firstOpportunity;
                    deduplicationResult.statusCode = GlobalUtils.DeduplicationStatus.E2EProcess.name();
                } else if (opportunityInProgress(secondOpportunity)) {
                    deduplicationResult.sfOpportunity = secondOpportunity;
                    deduplicationResult.statusCode = GlobalUtils.DeduplicationStatus.E2EProcess.name();
                } else {
                    deduplicationResult.statusCode = GlobalUtils.DeduplicationStatus.E2EProcess.name();
                }
            }
        } else {
            // TODO: Берем то только те у которых isClosed == false и смотрим их количество.
            // Если isClosed.count == 0 то E2E
            // Если isClosed.count == 1 то таблица
            // Если isClosed.count >= 2 то Inbound
            System.debug('******* DEDUPLICATION PROCESS: count of opportunities more that 3');
            List<Opportunity> isClosedOpportunityList = new List<Opportunity>();
            for (Opportunity opportunity : opportunities) {
                if (opportunity.IsClosed == false) {
                    isClosedOpportunityList.add(opportunity);
                }
            }

            System.debug('******* DEDUPLICATION PROCESS: isClosed opportunities: ' + isClosedOpportunityList);
            if (isClosedOpportunityList.isEmpty()) {
                deduplicationResult.statusCode = GlobalUtils.DeduplicationStatus.E2EProcess.name();
            } else if (isClosedOpportunityList.size() == 1) {
                if (checkOpportunityGoToKO(isClosedOpportunityList.get(0))) {
                    System.debug('******* DEDUPLICATION PROCESS: go to KO');
                    // go to KO
                    deduplicationResult.sfOpportunity = isClosedOpportunityList.get(0);
                    deduplicationResult.statusCode = GlobalUtils.DeduplicationStatus.KO.name();
                } else {
                    System.debug('******* DEDUPLICATION PROCESS: go to E2E');
                    // go to E2E
                    deduplicationResult.sfOpportunity = isClosedOpportunityList.get(0);
                    deduplicationResult.statusCode = GlobalUtils.DeduplicationStatus.E2EProcess.name();
                }
            } else {
                System.debug('******* DEDUPLICATION PROCESS: Go to Inbound;');
                deduplicationResult.statusCode = GlobalUtils.DeduplicationStatus.Inbound.name();
            }
        }
    }

    /*******************************************************************************
    *  Name            : shouldOpportunityBeTransferredToInbound()
    *  Summary         : check stage under which  opportunity must transferred to Inbound
    *  CreatedDate     : 10/08/2018
    *  ModifiedDate    : -
    *  Parameters      : Opportunity firstOpportunity, Opportunity secondOpportunity
    *  Returns         : Boolean
    ******************************************************************************/
    private Boolean shouldOpportunityBeTransferredToInbound(Opportunity firstOpportunity, Opportunity secondOpportunity) {
        System.debug('******* DEDUPLICATION PROCESS: Check opportunity transfer to Inbound;');
        System.debug('******* DEDUPLICATION PROCESS: firstOpportunity=' + firstOpportunity + '; secondOpportunity=' + secondOpportunity );
        if (firstOpportunity.StageName == 'Moved to Start' && secondOpportunity.StageName == 'Moved to Start') {
            return false; // go to E2E
        } else if (firstOpportunity.StageName == 'Отказ' && secondOpportunity.StageName == 'Отказ') {
            return false; // go to E2E
        } else if (opportunityInProgress(firstOpportunity) && opportunityInProgress(secondOpportunity)) {
            return true; // go to Inbound
        } else if (firstOpportunity.StageName == 'Отказ' && secondOpportunity.StageName == 'Moved to Start') {
            return false; // go to E2E
        } else if (firstOpportunity.StageName == 'Moved to Start' && secondOpportunity.StageName == 'Отказ') {
            return false; // go to E2E
        }
        return false;
    }

    /*******************************************************************************
    *  Name            : shouldOpportunityBeTransferredToKO()
    *  Summary         : if we have two opportunity on account,
    *                    we must check stage under which opportunity need transferred to KO (Sales department)
    *  CreatedDate     : 10/08/2018
    *  ModifiedDate    : -
    *  Parameters      : Opportunity firstOpportunity, Opportunity secondOpportunity
    *  Returns         : Boolean
    ******************************************************************************/
    private Boolean shouldOpportunityBeTransferredToKO(Opportunity firstOpportunity, Opportunity secondOpportunity) {
        System.debug('******* DEDUPLICATION PROCESS: Check opportunity transfer to KO;');
        System.debug('******* DEDUPLICATION PROCESS: firstOpportunity=' + firstOpportunity + '; secondOpportunity=' + secondOpportunity );
        if (firstOpportunity.StageName == 'Moved to Start' && opportunityInProgress(secondOpportunity)) {
            return checkOpportunityGoToKO(secondOpportunity);
        } else if (opportunityInProgress(firstOpportunity) && secondOpportunity.StageName == 'Moved to Start') {
            return checkOpportunityGoToKO(firstOpportunity);
        } else if (firstOpportunity.StageName == 'Отказ' && opportunityInProgress(secondOpportunity)) {
            return checkOpportunityGoToKO(secondOpportunity);
        } else if (opportunityInProgress(firstOpportunity) && secondOpportunity.StageName == 'Отказ') {
            return checkOpportunityGoToKO(firstOpportunity);
        }
        return false;
    }

    /*******************************************************************************
    *  Name            : opportunityInProgress(Opportunity opportunity)
    *  Summary         : check that opportunity in progress status
    *  CreatedDate     : 10/08/2018
    *  ModifiedDate    : -
    *  Parameters      : Opportunity opportunity
    *  Returns         : Boolean
    ******************************************************************************/
    private Boolean opportunityInProgress(Opportunity opportunity) {
        if (opportunity.StageName == 'Qualified Lead' ||
                opportunity.StageName == 'Client Negotiations' ||
                opportunity.StageName == 'Check Credit History' ||
                opportunity.StageName == 'Agreement Terms and Conditions' ||
                opportunity.StageName == 'Договор на проверке' ||
                opportunity.StageName == 'Contract Under Signing' ||
                opportunity.StageName == 'Signing of a Contract' ||
                opportunity.StageName == 'Awaiting payment' ||
                opportunity.StageName == 'Suspended Opportunity') {
            return true;
        }
        return false;
    }

    /*******************************************************************************
    *  Name            : checkOpportunityGoToKO(Opportunity opportunity)
    *  Summary         : check opportunity stage under which opportunity must transferred to KO
    *  CreatedDate     : 10/08/2018
    *  ModifiedDate    : -
    *  Parameters      : Opportunity opportunity
    *  Returns         : Boolean
    ******************************************************************************/
    private Boolean checkOpportunityGoToKO(Opportunity opportunity) {
        System.debug('******* DEDUPLICATION PROCESS: check transfer to KO');
        System.debug('******* DEDUPLICATION PROCESS: opportunity.StageName -> ' + opportunity.StageName);
        if (opportunity.StageName == 'Qualified Lead' ||
                opportunity.StageName == 'Client Negotiations' ||
                opportunity.StageName == 'Check Credit History' ||
                opportunity.StageName == 'Agreement Terms and Conditions' ||
                opportunity.StageName == 'Suspended Opportunity' ||
                opportunity.StageName == 'Отказ' ||
                opportunity.StageName == 'Потерян в конкуренции' ||
                opportunity.StageName == 'Moved to Start') {
            System.debug('******* DEDUPLICATION PROCESS: FALSE');
            return false;
        }

        List<OpportunityHistory> historyList = this.e2eFormRuDao.getLastModifiedStageByOpportunityId(opportunity.Id);
        System.debug('historyList: ' + historyList);

        // if history is empty that opportunity was migrated from other source
        if ( ! historyList.isEmpty() || Test.isRunningTest()) {

            Date lastModifiedStageDate = Date.Today();
            if (Test.isRunningTest()) {
                lastModifiedStageDate = opportunity.CloseDate;
            } else {
                lastModifiedStageDate = historyList.get(0).CloseDate;
            }

            Date nowDate = Date.Today();

            if (opportunity.StageName == 'Договор на проверке') {
                System.debug('Договор на проверке ************');
                if (nowDate.daysBetween(lastModifiedStageDate) > 5) {
                    System.debug('******* DEDUPLICATION PROCESS: FALSE');
                    return false; // go to E2E
                } else {
                    System.debug('******* DEDUPLICATION PROCESS: TRUE');
                    return true; // go to KO
                }
            }

            if (opportunity.StageName == 'Contract Under Signing') {
                if (nowDate.daysBetween(lastModifiedStageDate) > 14) {
                    System.debug('******* DEDUPLICATION PROCESS: FALSE');
                    return false; // go to E2E
                } else {
                    System.debug('******* DEDUPLICATION PROCESS: TRUE');
                    return true; // go to KO
                }
            }

            if (opportunity.StageName == 'Signing of a Contract') {
                if (nowDate.daysBetween(lastModifiedStageDate) > 14) {
                    System.debug('******* DEDUPLICATION PROCESS: FALSE');
                    return false; // go to E2E
                } else {
                    System.debug('******* DEDUPLICATION PROCESS: TRUE');
                    return true; // go to KO
                }
            }

            if (opportunity.StageName == 'Awaiting payment') {
                if (nowDate.monthsBetween(lastModifiedStageDate) > 6) {
                    System.debug('******* DEDUPLICATION PROCESS: FALSE');
                    return false; // go to E2E
                } else {
                    System.debug('******* DEDUPLICATION PROCESS: TRUE');
                    return true; // go to KO
                }
            }
        }
        return false;
    }

    /*******************************************************************************
    *  Name            : transferToService()
    *  Summary         : convert E2E process to Service
    *  CreatedDate     : 10/08/2018
    *  ModifiedDate    : -
    *  Parameters      : Account sfAccount, Account e2eAccount, Contact e2eContact, Opportunity e2eOpportunity
    *  Returns         : Map<String, String> - result parameters
    ******************************************************************************/
    private void transferToService(E2EFormRuDeduplicationResult deduplicationResult) {
        System.debug('******* DEDUPLICATION PROCESS: execute transferToService');

        transferToService(deduplicationResult.innDuplication,
                deduplicationResult.sfAccount.Id,
                deduplicationResult.e2eAccount.Id,
                deduplicationResult.e2eOpportunity.Id,
                deduplicationResult.e2eContact.Id,
                deduplicationResult.formDataId
        );

        if (deduplicationResult.innDuplication == true) {
            deduplicationResult.e2eAccount = deduplicationResult.sfAccount;
        }
    }

    @Future
    public static void transferToService(Boolean innDuplication, Id sfAccountId, Id e2eAccountId, Id e2eOpportunityId, Id e2eContactId, Id formDataId) {
        try {
            E2EFormRuDao e2EFormRuDao = new E2EFormRuDaoImpl();
            Account sfAccount = e2eFormRuDao.getAccountById(sfAccountId);

            if (sfAccount != null) {
                if (innDuplication == true) {
                    // update  E2E opportunity
                    Opportunity e2eOpportunity = new Opportunity(Id = e2eOpportunityId);
                    e2eOpportunity.AccountId = sfAccountId;
                    e2eOpportunity.StageName = 'Отказ';
                    e2eOpportunity.PPR_Lost_Reasons__c = 'Существующий клиент';
                    e2eOpportunity.E2E_Status__c = 'Клиент завершил';
                    e2eFormRuDao.updateOpportunity(e2eOpportunity);

                    // update E2E contact
                    Contact e2eContact = new Contact(Id = e2eContactId);
                    e2eContact.AccountId = sfAccountId;
                    e2eFormRuDao.updateContact(e2eContact);

                    // update E2E FormData
                    E2EFormData__c formData = new E2EFormData__c(Id = formDataId);
                    formData.E2E_Account_Id__c = sfAccountId;
                    e2eFormRuDao.updateFormData(formData);

                    // delete E2E Account
                    if (e2eAccountId != sfAccountId) {
                        deleteAccountById(e2eAccountId);
                    }
                } else {
                    // update  E2E opportunity
                    Opportunity e2eOpportunity = new Opportunity(Id = e2eOpportunityId);
                    e2eOpportunity.StageName = 'Отказ';
                    e2eOpportunity.PPR_Lost_Reasons__c = 'Существующий клиент';
                    e2eOpportunity.E2E_Status__c = 'Клиент завершил';
                    e2eFormRuDao.updateOpportunity(e2eOpportunity);
                }

                // Email notification
                if (sfAccount.Opportunities != null && ! sfAccount.Opportunities.isEmpty()) {
                    Set<Id> userIds = new Set<Id>();
                    for (Opportunity opportunity : sfAccount.Opportunities) {
                        userIds.add(opportunity.OwnerId);
                    }
                    Map<Id, User> usersMap = e2eFormRuDao.getUsersMapByIds(userIds);

                    Set<Id> userIdsForNotification = new Set<Id>();
                    List<Opportunity> suitableOpportunities = new List<Opportunity>();
                    Date nowDate = System.Today();
                    for (Opportunity opportunity : sfAccount.Opportunities) {
                        if ((opportunity.Probability > 0 && opportunity.Probability < 100 && opportunity.Id != e2eOpportunityId) ||
                                (opportunity.StageName == 'Moved to Start' && nowDate.monthsBetween(opportunity.CloseDate) >= - 6)) {
                            suitableOpportunities.add(opportunity);

                            // Add Team Lead for notification
                            if (usersMap.containsKey(opportunity.OwnerId) && usersMap.get(opportunity.OwnerId).ManagerId != null) {
                                userIdsForNotification.add(usersMap.get(opportunity.OwnerId).ManagerId);
                            }
                        }
                    }

                    if (! suitableOpportunities.isEmpty()) {
//                String body = getEmailBodyTransferToServiceForSalesPushEmail(suitableOpportunities);
//                 send notification
//                sendE2ENotification(userIdsForNotification, body, '', GlobalUtils.E2ERuGroupsNotification.Service);
                        EmailTemplate emailTemplate = EmailGenerator.getEmailTemplate(
                                GlobalUtils.EmailTemplateDevName.E2E_RU_Transfer_To_Service,
                                new Map<String, Object>{
                                        '/$opportunities$/' => suitableOpportunities
                                }
                        );
                        System.debug('SUBJECT: ' + emailTemplate.Subject);
                        System.debug('BODY: ' + emailTemplate.HtmlValue);
                        // send notification
                        sendE2ENotification(userIdsForNotification, emailTemplate.HtmlValue, emailTemplate.Subject, GlobalUtils.E2ERuGroupsNotification.Service);
                    }
                }

                List<Opportunity> opportunitiesForUpdate = new List<Opportunity>();
                for (Opportunity opportunity : sfAccount.Opportunities) {
                    if (opportunity.Probability > 0 && opportunity.Probability < 100 && opportunity.Id != e2eOpportunityId) {
                        opportunity.StageName = 'Отказ';
                        opportunity.PPR_Lost_Reasons__c = 'Существующий клиент';
                        opportunity.E2E_Status__c = 'Клиент завершил';
                        opportunitiesForUpdate.add(opportunity);
                    }
                }
                e2eFormRuDao.updateOpportunities(opportunitiesForUpdate);
            } else {
                throw new E2EFormRuException('Error: Account with Id ' + sfAccountId + ' does not found');
            }
        } catch (Exception e) {
            String notificationMessage = '<br/>E2E future method transferToService: ' + String.valueOf(e.getMessage());
            ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
        }
    }

    /*******************************************************************************
    *  Name            : transferToInbound()
    *  Summary         : convert E2E process to Inbound
    *  CreatedDate     : 10/08/2018
    *  ModifiedDate    : -
    *  Parameters      : Account sfAccount, Account e2eAccount, Contact e2eContact, Opportunity e2eOpportunity
    *  Returns         : Map<String, String> - result parameters
    ******************************************************************************/
    private void transferToInbound(E2EFormRuDeduplicationResult deduplicationResult) {
        System.debug('******* DEDUPLICATION PROCESS: execute transferToInbound');

        transferToInbound(deduplicationResult.innDuplication,
                deduplicationResult.sfAccount.Id,
                deduplicationResult.e2eAccount.Id,
                deduplicationResult.e2eOpportunity.Id,
                deduplicationResult.e2eContact.Id,
                deduplicationResult.formDataId
        );

        if (deduplicationResult.innDuplication == true) {
            deduplicationResult.e2eAccount = deduplicationResult.sfAccount;
        }
    }

    @Future
    public static void transferToInbound(Boolean innDuplication, Id sfAccountId, Id e2eAccountId, Id e2eOpportunityId, Id e2eContactId, Id formDataId) {
        try {
            E2EFormRuDao e2EFormRuDao = new E2EFormRuDaoImpl();
            Account sfAccount = e2eFormRuDao.getAccountById(sfAccountId);

            if (sfAccount != null) {
                if (innDuplication == true) {
                    //update E2E FormData
                    E2EFormData__c formData = new E2EFormData__c(Id = formDataId);
                    formData.E2E_Account_Id__c = sfAccountId;
                    e2eFormRuDao.updateFormData(formData);

                    // update E2E opportunity
                    Opportunity e2eOpportunity = new Opportunity(Id = e2eOpportunityId);
                    e2eOpportunity.AccountId = sfAccountId;
                    e2eOpportunity.StageName = 'Qualified Lead';
                    e2eFormRuDao.updateOpportunity(e2eOpportunity);

                    // update E2E contact
                    Contact e2eContact = new Contact(Id = e2eContactId);
                    e2eContact.AccountId = sfAccountId;
                    e2eFormRuDao.updateContact(e2eContact);

                    // delete E2E Account
                    if (e2eAccountId != sfAccountId) {
                        deleteAccountById(e2eAccountId);
                    }
                } else {
                    // update E2E opportunity
                    Opportunity e2eOpportunity = new Opportunity(Id = e2eOpportunityId);
                    e2eOpportunity.StageName = 'Qualified Lead';
                    e2eFormRuDao.updateOpportunity(e2eOpportunity);
                }

                // Email notification
                if (sfAccount.Opportunities != null && ! sfAccount.Opportunities.isEmpty()) {

                    Set<Id> userIds = new Set<Id>();
                    for (Opportunity opportunity : sfAccount.Opportunities) {
                        userIds.add(opportunity.OwnerId);
                    }
                    Map<Id, User> usersMap = e2eFormRuDao.getUsersMapByIds(userIds);

                    Set<Id> userIdsForNotification = new Set<Id>();
                    List<Opportunity> suitableOpportunities = new List<Opportunity>();
                    Date nowDate = System.Today();
                    for (Opportunity opportunity : sfAccount.Opportunities) {
                        if (opportunity.Probability > 0 && opportunity.Probability < 100 && opportunity.Id != e2eOpportunityId) {
                            suitableOpportunities.add(opportunity);

                            // Add Team Lead for notification
                            if (usersMap.containsKey(opportunity.OwnerId) && usersMap.get(opportunity.OwnerId).ManagerId != null) {
                                userIdsForNotification.add(usersMap.get(opportunity.OwnerId).ManagerId);
                            }
                        }
                    }

                    if (! suitableOpportunities.isEmpty()) {
//                    String body = getEmailBodyTransferToInboundSalesPushEmail(suitableOpportunities);
                        // send notification
//                    sendE2ENotification(userIdsForNotification, body, '', GlobalUtils.E2ERuGroupsNotification.CallCenter);
                        EmailTemplate emailTemplate = EmailGenerator.getEmailTemplate(
                                GlobalUtils.EmailTemplateDevName.E2E_RU_Transfer_To_Inbound,
                                new Map<String, Object>{
                                        '/$opportunities$/' => suitableOpportunities
                                }
                        );
                        System.debug('SUBJECT: ' + emailTemplate.Subject);
                        System.debug('BODY: ' + emailTemplate.HtmlValue);
                        // send notification
                        sendE2ENotification(userIdsForNotification, emailTemplate.HtmlValue, emailTemplate.Subject, GlobalUtils.E2ERuGroupsNotification.CallCenter);
                    }
                }

            } else {
                throw new E2EFormRuException('Error: Account with Id ' + sfAccountId + ' does not found');
            }
        } catch (Exception e) {
            String notificationMessage = '<br/>E2E future method transferToInbound: ' + String.valueOf(e.getMessage());
            ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
        }
    }

    /*******************************************************************************
    *  Name            : transferToKO()
    *  Summary         : convert E2E process to Inbound
    *  CreatedDate     : 10/08/2018
    *  ModifiedDate    : -
    *  Parameters      : Account sfAccount, Account e2eAccount, Contact e2eContact, Opportunity e2eOpportunity
    *  Returns         : Map<String, String> - result parameters
    ******************************************************************************/
    private void transferToKO(E2EFormRuDeduplicationResult deduplicationResult) {
        System.debug('******* DEDUPLICATION PROCESS: execute transferToKO');

        transferToKO(deduplicationResult.innDuplication,
                deduplicationResult.sfAccount.Id,
                deduplicationResult.sfOpportunity.Id,
                deduplicationResult.e2eAccount.Id,
                deduplicationResult.e2eOpportunity.Id,
                deduplicationResult.e2eContact.Id,
                deduplicationResult.formDataId
        );

        if (deduplicationResult.innDuplication == true) {
            deduplicationResult.e2eAccount = deduplicationResult.sfAccount;
        }
    }

    @Future
    public static void transferToKO(Boolean innDuplication, Id sfAccountId, Id sfOpportunityId, Id e2eAccountId, Id e2eOpportunityId, Id e2eContactId, Id formDataId) {
        try {
            E2EFormRuDao e2EFormRuDao = new E2EFormRuDaoImpl();
            Account sfAccount = e2eFormRuDao.getAccountById(sfAccountId);
            Opportunity sfOpportunity = e2eFormRuDao.getOpportunityById(sfOpportunityId);
            Contact e2eContact = e2EFormRuDao.getContactById(e2eContactId);
            Account e2eAccount = e2EFormRuDao.getAccountById(e2eAccountId);
            System.debug('TRANSFER TO KO @FUTURE METHOD: innDuplication = ' + innDuplication);

            if (innDuplication == true) {
                // update  E2E opportunity
                Opportunity e2eOpportunity = new Opportunity(Id = e2eOpportunityId);
                e2eOpportunity.AccountId = sfAccountId;
                e2eOpportunity.StageName = 'Отказ';
                e2eOpportunity.PPR_Lost_Reasons__c = 'Возврат в Воронку';
                e2eOpportunity.E2E_Status__c = 'Клиент завершил';
                e2eFormRuDao.updateOpportunity(e2eOpportunity);

                // update E2E contact
                e2eContact.AccountId = sfAccountId;
                e2eFormRuDao.updateContact(e2eContact);

                //update E2E FormData
                E2EFormData__c formData = new E2EFormData__c(Id = formDataId);
                formData.E2E_Account_Id__c = sfAccountId;
                e2eFormRuDao.updateFormData(formData);

                // delete E2E Account
                if (e2eAccountId != sfAccountId) {
                    deleteAccountById(e2eAccountId);
                }
            } else {
                // update  E2E opportunity
                Opportunity e2eOpportunity = new Opportunity(Id = e2eOpportunityId);
                e2eOpportunity.StageName = 'Отказ';
                e2eOpportunity.OwnerId = sfOpportunity.OwnerId;
                e2eOpportunity.PPR_Lost_Reasons__c = 'Возврат в Воронку';
                e2eOpportunity.E2E_Status__c = 'Клиент завершил';
                e2eFormRuDao.updateOpportunity(e2eOpportunity);

                // update E2E contact
                e2eContact.OwnerId = sfOpportunity.OwnerId;
                e2eFormRuDao.updateContact(e2eContact);

                // update E2E account
                e2eAccount.OwnerId = sfOpportunity.OwnerId;
                e2eFormRuDao.updateAccount(e2eAccount);
            }

            // Email notification
            if (sfAccount.Opportunities != null && ! sfAccount.Opportunities.isEmpty()) {

                Set<Id> userIds = new Set<Id>();
                for (Opportunity opportunity : sfAccount.Opportunities) {
                    userIds.add(opportunity.OwnerId);
                }
                Map<Id, User> usersMap = e2eFormRuDao.getUsersMapByIds(userIds);

                Set<Id> userIdsForNotification = new Set<Id>();
                List<Opportunity> suitableOpportunities = new List<Opportunity>();
                Date nowDate = System.Today();
                for (Opportunity opportunity : sfAccount.Opportunities) {
                    if (opportunity.Id != e2eOpportunityId) {
                        suitableOpportunities.add(opportunity);
                        if (opportunity.OwnerId != null) {
                            userIdsForNotification.add(opportunity.OwnerId);

                            // Add Team Lead for notification
                            if (usersMap.containsKey(opportunity.OwnerId) && usersMap.get(opportunity.OwnerId).ManagerId != null) {
                                userIdsForNotification.add(usersMap.get(opportunity.OwnerId).ManagerId);
                            }
                        }
                    }
                }

                if (! suitableOpportunities.isEmpty()) {
                    System.debug('TRANSFER TO KO @FUTURE METHOD: suitableOpportunities = ' + suitableOpportunities);
//                String body = '';
                    EmailTemplate emailTemplate;
                    if (innDuplication == true) {
//                    body = getEmailBodyTransferToKoForSalesPushEmail(sfAccount, e2eContact);
                        emailTemplate = EmailGenerator.getEmailTemplate(
                                GlobalUtils.EmailTemplateDevName.E2E_RU_Transfer_To_Ko_With_INN,
                                new Map<String, Object>{
                                        '/$domainUrl$/' => E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu').Domain_Url__c,
                                        '/$sfAccount.INN__c$/' => sfAccount.INN__c,
                                        '/$sfAccount.Id$/' => sfAccount.Id,
                                        '/$sfAccount.Name$/' => sfAccount.Name,
                                        '/$e2eContact.MobilePhone$/' => e2eContact.MobilePhone,
                                        '/$e2eContact.Email$/' => e2eContact.Email
                                }
                        );
                    } else {
//                    body = getEmailBodyTransferToKoForSalesPushEmail(sfAccount, e2eAccount);
                        emailTemplate = EmailGenerator.getEmailTemplate(
                                GlobalUtils.EmailTemplateDevName.E2E_RU_Transfer_To_Ko_With_Email,
                                new Map<String, Object>{
                                        '/$domainUrl$/' => E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu').Domain_Url__c,
                                        '/$sfAccount.Id$/' => sfAccount.Id,
                                        '/$sfAccount.Name$/' => sfAccount.Name,
                                        '/$e2eAccount.Id$/' => e2eAccount.Id,
                                        '/$e2eAccount.Name$/' => e2eAccount.Name
                                }
                        );
                    }
                    System.debug('SUBJECT: ' + emailTemplate.Subject);
                    System.debug('BODY: ' + emailTemplate.HtmlValue);
                    // send notification
//                sendE2ENotification(userIdsForNotification, body, '', GlobalUtils.E2ERuGroupsNotification.MainGroup);
                    sendE2ENotification(userIdsForNotification, emailTemplate.HtmlValue, emailTemplate.Subject, GlobalUtils.E2ERuGroupsNotification.MainGroup);
                }
            }
        } catch (Exception e) {
            String notificationMessage = '<br/>E2E future method transferToKO: ' + String.valueOf(e.getMessage());
            ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
        }
    }

    /*******************************************************************************
    *  Name            : transferToE2E()
    *  Summary         : continue E2E process, when account does not have opportunity
    *  CreatedDate     : 10/08/2018
    *  ModifiedDate    : -
    *  Parameters      : Account sfAccount, Account e2eAccount, Contact e2eContact, Opportunity e2eOpportunity
    *  Returns         : Map<String, String> - result parameters
    ******************************************************************************/
    private void transferToE2E(E2EFormRuDeduplicationResult deduplicationResult) {
        System.debug('******* DEDUPLICATION PROCESS: execute transferToE2E');

        List<Id> refusingOpportunityIds = new List<Id>();
        prepareTransferToE2E(
                deduplicationResult.innDuplication,
                deduplicationResult.sfAccount.Id,
                deduplicationResult.e2eAccount.Id,
                deduplicationResult.e2eOpportunity.Id,
                deduplicationResult.e2eContact.Id,
                deduplicationResult.formDataId,
                refusingOpportunityIds
        );


        transferToE2E(deduplicationResult.innDuplication,
                deduplicationResult.sfAccount.Id,
                deduplicationResult.e2eAccount.Id,
                deduplicationResult.e2eOpportunity.Id,
                deduplicationResult.e2eContact.Id,
                deduplicationResult.formDataId,
                refusingOpportunityIds
        );

        if (deduplicationResult.innDuplication == true) {
            deduplicationResult.e2eAccount = deduplicationResult.sfAccount;
        }
    }

    /*******************************************************************************
    *  Name            : transferToE2E(Boolean innDuplication, Id sfAccountId, Id e2eAccountId, Id e2eOpportunityId,
                       : Id e2eContactId, Id formDataId, List<Id> refusingOpportunityIds)
    *  Summary         : prepare transfer to e2e process
    *  CreatedDate     : 10/08/2018
    *  ModifiedDate    : 05/03/2019
    *  Parameters      : Boolean innDuplication, Id sfAccountId, Id e2eAccountId, Id e2eOpportunityId,
                       : Id e2eContactId, Id formDataId, List<Id> refusingOpportunityIds
    *  Returns         : void
    ******************************************************************************/
    public void prepareTransferToE2E(Boolean innDuplication, Id sfAccountId, Id e2eAccountId, Id e2eOpportunityId,
            Id e2eContactId, Id formDataId, List<Id> refusingOpportunityIds)
    {
        E2EFormRuDao e2EFormRuDao = new E2EFormRuDaoImpl();
        Account sfAccount = e2eFormRuDao.getAccountById(sfAccountId);
        List<Opportunity> refusingOpportunityList = new List<Opportunity>();

        if (sfAccount != null) {
            if (innDuplication == true) {
                //update E2E FormData
                System.debug('@Future -> transferToE2E -> formDataId ' + formDataId);
                System.debug('@Future -> transferToE2E -> sfAccountId ' + sfAccountId);
                E2EFormData__c formData = new E2EFormData__c(Id = formDataId);
                formData.E2E_Account_Id__c = sfAccountId;
                e2eFormRuDao.updateFormData(formData);

                // update E2E contact
                Contact e2eContact = new Contact(Id = e2eContactId);
                e2eContact.AccountId = sfAccountId;
                e2eFormRuDao.updateContact(e2eContact);

                // update  E2E opportunity
                Opportunity e2eOpportunity = new Opportunity(Id = e2eOpportunityId);
                e2eOpportunity.AccountId = sfAccountId;
                e2eFormRuDao.updateOpportunity(e2eOpportunity);
                // update SF opportunity
                for (Opportunity opportunity : sfAccount.Opportunities) {
                    if(opportunity.StageName != 'Moved to Start' && opportunity.StageName != 'Отказ' && opportunity.Id != e2eOpportunityId) {
                        opportunity.StageName = 'Отказ';
                        opportunity.PPR_Lost_Reasons__c = 'Switched to E2E';
                        refusingOpportunityList.add(opportunity);
                    }
                }
                e2eFormRuDao.updateOpportunities(refusingOpportunityList);

                // delete E2E Account
                if(e2eAccountId != sfAccountId){
                    deleteAccountById(e2eAccountId);
                }
            } else {
                // update SF opportunity
                for (Opportunity opportunity : sfAccount.Opportunities) {
                    if(opportunity.StageName != 'Moved to Start' && opportunity.StageName != 'Отказ' && opportunity.Id != e2eOpportunityId) {
                        opportunity.StageName = 'Отказ';
                        opportunity.PPR_Lost_Reasons__c = 'Switched to E2E';
                        refusingOpportunityList.add(opportunity);
                    }
                }
                e2eFormRuDao.updateOpportunities(refusingOpportunityList);
            }

            //prepare and return refusingOpportunityIds list as parameter for future method
            System.debug('PREPARE TRANSFER TO E2E METHOD: refusingOpportunityList = ' + refusingOpportunityList);
            for (Opportunity opportunity : refusingOpportunityList) {
                refusingOpportunityIds.add(opportunity.Id);
            }
        } else {
            throw new E2EFormRuException('Error: Account with Id ' + sfAccountId + ' does not found');
        }
    }

    /*******************************************************************************
    *  Name            : transferToE2E(Boolean innDuplication, Id sfAccountId, Id e2eAccountId, Id e2eOpportunityId,
                       : Id e2eContactId, Id formDataId, List<Id> refusingOpportunityIds)
    *  Summary         : send notifications asynchronously
    *  CreatedDate     : 10/08/2018
    *  ModifiedDate    : 05/03/2019
    *  Parameters      : Boolean innDuplication, Id sfAccountId, Id e2eAccountId, Id e2eOpportunityId,
                       : Id e2eContactId, Id formDataId, List<Id> refusingOpportunityIds
    *  Returns         : void
    ******************************************************************************/
    @Future
    public static void transferToE2E(Boolean innDuplication, Id sfAccountId, Id e2eAccountId, Id e2eOpportunityId,
            Id e2eContactId, Id formDataId, List<Id> refusingOpportunityIds)
    {
        try {
            E2EFormRuDao e2EFormRuDao = new E2EFormRuDaoImpl();
            Account sfAccount = e2eFormRuDao.getAccountById(sfAccountId);
            List<Opportunity> refusingOpportunityList = e2eFormRuDao.getOpportunitiesByIds(new Set<Id>(refusingOpportunityIds));

            System.debug('TRANSFER TO E2E @FUTURE METHOD: refusingOpportunityList = ' + refusingOpportunityList);
            if (sfAccount != null) {

                // Notification
                if (! refusingOpportunityList.isEmpty()) {

                    Set<Id> opportunityOwnerIds = new Set<Id>();
                    for (Opportunity opportunity : refusingOpportunityList) {
                        if (opportunity.OwnerId != null) {
                            opportunityOwnerIds.add(opportunity.OwnerId);
                        }
                    }

                    Map<Id, User> usersMap = e2eFormRuDao.getUsersMapByIds(opportunityOwnerIds);

                    Set<Id> userIds = new Set<Id>();
                    Set<String> externalEmails = new Set<String>();
                    prepareAddressesForNotification(userIds, externalEmails, GlobalUtils.E2ERuGroupsNotification.MainGroup);
                    List<Messaging.Email> messages = new List<Messaging.Email>();

                    //params for each group of recipients ids (each ids set corresponds to particular opportunity that is being used in template params)
                    Map<Set<Id>, Map<String, Object>> emailParams = new Map<Set<Id>, Map<String, Object>>();

                    for (Opportunity opportunity : refusingOpportunityList) {
                        Set<Id> userIdsForOpportunity = new Set<Id>(userIds);
                        if (usersMap.containsKey(opportunity.OwnerId)) {

                            User ownerUser = usersMap.get(opportunity.OwnerId);
                            if (ownerUser.ManagerId != null) {
                                userIdsForOpportunity.add(ownerUser.ManagerId);
                            }

                            // add owner for notification
                            if (ownerUser.Id != null) {
                                userIdsForOpportunity.add(ownerUser.Id);
                            }
                        }
                        //fill emailParams map up with ids and corresponding params
                        emailParams.put(
                                userIdsForOpportunity,
                                new Map<String, Object>{
                                        '/$domainUrl$/' => E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu').Domain_Url__c,
                                        '/$opportunity.Id$/' => opportunity.Id
                                }
                        );

//                    String body = getEmailBodyForRefusingOpportunity(opportunity.Id);

//                    for (Id currentUserId : userIdsForOpportunity) {
//                        Messaging.SingleEmailMessage emailMessage = EmailGenerator.prepareHtmlEmailToTarget(currentUserId, 'Russia E2E Отказ Возможности', body);
//                        messages.add(emailMessage);
//                    }
                    }
                    //invoke method which returns prepared template with htmlBody and subject set up for each ids set
                    //and send emails to users
                    Map<Set<Id>, EmailTemplate> templatesByIds = EmailGenerator.getEmailTemplatesMap(GlobalUtils.EmailTemplateDevName.E2E_RU_Refusing_Opportunity, emailParams);
                    for (Set<Id> userIdsForOpportunity : templatesByIds.keySet()) {
                        EmailTemplate templateForCurrentOpportunity = templatesByIds.get(userIdsForOpportunity);
                        System.debug('SUBJECT: ' + templateForCurrentOpportunity.Subject);
                        System.debug('BODY: ' + templateForCurrentOpportunity.HtmlValue);
                        for (Id currentUserId : userIdsForOpportunity) {
                            Messaging.SingleEmailMessage emailMessage = EmailGenerator.prepareHtmlEmailToTarget(
                                    currentUserId,
                                    templateForCurrentOpportunity.Subject,
                                    templateForCurrentOpportunity.HtmlValue
                            );
                            messages.add(emailMessage);
                        }
                    }

                    System.debug('messages: ' + messages);

                    if (! Test.isRunningTest()) {
                        if (! messages.isEmpty()) {
                            Messaging.sendEmail(messages);
                        }
                    }
                }
            } else {
                throw new E2EFormRuException('Error: Account with Id ' + sfAccountId + ' does not found');
            }
        } catch (Exception e) {
            String notificationMessage = '<br/>E2E future method transferToE2E: ' + String.valueOf(e.getMessage());
            ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
        }
    }

    //TODO: оставить
    private static String getEmailBodyDisqualificationLeadForSalesPushEmail(Lead lead) {
        String body = 'Уважаемый менеджер. <br/><br/>' +
                'Интерес <a href="' + E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu').Domain_Url__c + '/' + lead.Id + '" target="_blank">' + lead.Name + '</a> ' +
                'дисквалифицирован, клиент передан в E2E. <br/>' +
                'ИНН: ' + (lead.INN__c == null ? 'none' : lead.INN__c) + '; <br/>' +
                'Телефон: ' + (lead.Phone == null ? 'none' : lead.Phone) + '; <br/>';

        return body;
    }

    //TODO: оставить
    private static String getEmailBodyTransferToServiceForSalesPushEmail(List<Opportunity> opportunities) {
        String body = 'По E2Е обратился существующий клиент, в CRM сформировано обращение. <br/>' +
                'Все открытые Возможности SF переведены в Отказ с причиной “Существующий клиент”. <br/>' +
                'Если Возможность Принята на Старт менее 6 мес. назад, помогите клиенту начать работу по сущ. договору. <br/><br/>';
        body += getOpportunitiesEmailTemplateFirst(opportunities);
        return body;
    }

    //TODO: делать ноне
    private static String getEmailBodyTransferToKoForSalesPushEmail(Account sfAccount, Contact e2eContact) {
        String body = 'Ваш потенциальный клиент обратился через E2Е, свяжитесь с ним и продолжайте работу в своей Возможности. <br/>' +
                'ИНН:' + sfAccount.INN__c + '; <br/>' +
                '<a href="' + E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu').Domain_Url__c + '/' + sfAccount.Id + '" target="_blank">' + sfAccount.Name + '</a>; <br/>' +
                'Телефон: ' + e2eContact.MobilePhone + '; <br/>' +
                'Email: ' + e2eContact.Email + '; <br/>';
        return body;
    }

    //TODO:
    private static String getEmailBodyTransferToKoForSalesPushEmail(Account sfAccount, Account e2eAccount) {
        String body = 'Через E2Е обратилась компания с дублем Email вашего потенциального клиента, свяжитесь с ними и продолжайте работу в своей Возможности или с Е2Е Возможностью, если договор будет заключен на новое ИНН <br/>' +
                '<a href="' + E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu').Domain_Url__c + '/' + sfAccount.Id + '" target="_blank">' + sfAccount.Name + '</a>; <br/>' +
                '<a href="' + E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu').Domain_Url__c + '/' + e2eAccount.Id + '" target="_blank">' + e2eAccount.Name + '</a>; <br/>';

        return body;
    }

    //TODO:
    public String getEmailBodyNotificationCallCenter(Id opportunityId, String opportunityName) {
        String body = 'Уважаемый менеджер. <br/>' +
                'Необходимо Ваше участие для решения сложностей с E2E возможностью: <a href="' + E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu').Domain_Url__c + '/' + opportunityId + '" target="_blank">' + opportunityName + '</a><br/>';
        return body;
    }

    //TODO:
    private static String getEmailBodyTransferToInboundSalesPushEmail(List<Opportunity> opportunities) {
        String body = 'По E2Е обратился потенциальный клиент, отправляем список Возможностей на открытых этапах для согласованной работы КО. <br/><br/>';
        body += getOpportunitiesEmailTemplateFirst(opportunities);
        return body;
    }

    //TODO:
    private static String getOpportunitiesEmailTemplateFirst(List<Opportunity> opportunities) {
        String template = '<table><tr><th>Инн</th>' +
                '<th>Имя Opp-ty</th>' +
                '<th>Имя Ответст.</th>' +
                '<th>Роль Ответст.</th>' +
                '<th>Этап</th>' +
                '<th>Дата перевода</th>' +
                '<th>Дата закрытия</th></tr>';

        E2E_Form_Ru_General_Settings__c settings = E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu');
        for (Opportunity opportunity : opportunities) {
            template += '<tr><td>' + opportunity.INN_Opp__c + '</td>';

            if (settings != null) {
                template += '<td><a href="'+  settings.Domain_Url__c + '/' + opportunity.Id + '" target="_blank">' + opportunity.Name + '</a></td>';
            } else {
                template += '<td>'+  + opportunity.Name + '</td>';
            }

            template += '<td>' + opportunity.Owner.Name + '</td>';

            if (opportunity.Owner.UserRole != null) {
                template += '<td>' + opportunity.Owner.UserRole.Name + '</td>';
            } else {
                template += '<td>None</td>';
            }

            template += '<td>' +  GlobalUtils.getPicklistValueTranslation(Schema.sObjectType.Opportunity.fields.StageName, opportunity.StageName) + '</td>' +
                    '<td>' + opportunity.Day_transfer__c + '</td>' +
                    '<td>' + opportunity.CloseDate + '</td></tr>';
        }
        template += '</table>';
        return template;
    }

    //TODO:
    public String getEmailBodyCoordinationWithRiskManagementDepartment(Id opportunityId) {
        String body =
                'Нужно согласование с ОУР: <a href="' + E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu').Domain_Url__c + '/' + opportunityId + '" target="_blank"> Ссылка на возможность </a><br/>';
        return body;
    }

    //TODO:
    public String getEmailBodyForReseller(Id opportunityId) {
        String body =
                'Нужно согласование с департаментом работы с партнерами: <a href="' + E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu').Domain_Url__c + '/' + opportunityId + '" target="_blank"> Ссылка на возможность </a><br/>';
        return body;
    }

    //TODO: не используется
    public String getEmailBodyOfManualEntryNotification(Id opportunityId) {
        String body =
                'Ручная корректировка: <a href="' + E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu').Domain_Url__c + '/' + opportunityId + '" target="_blank"> Ссылка на возможность </a><br/>';
        return body;
    }

    //TODO: не используется
    public String getEmailBodyOfCardLimitExceeded(Id opportunityId) {
        String body =
                'Клиент ввел больше ' + E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu').Number_Of_Cards__c + ' карт: <a href="' + E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu').Domain_Url__c + '/' + opportunityId + '" target="_blank"> Ссылка на возможность </a><br/>';
        return body;
    }

    //TODO: не используется
    public String getEmailBodyTransferToInboundFromCallCenter(Id opportunityId) {
        String body = 'Перевод в KO: <a href="' + E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu').Domain_Url__c + '/' + opportunityId + '" target="_blank"> Ссылка на возможность </a><br/>';
        return body;
    }

    //TODO:
    public String getEmailBodyTransferToKOMore10Cards(Boolean isManualEntry, Integer cardsNumber, Id opportunityId) {
        String manualEntry = isManualEntry ? 'Да' : 'Нет';
        return 'Перевод в КО. Данные были введены вручную = ' + manualEntry + '<br/>Количество карт = ' + String.valueOf(cardsNumber) +
                '<br/><a href="' + E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu').Domain_Url__c + '/' + opportunityId + '" target="_blank"> Ссылка на возможность</a>.';
    }

    //TODO:
    public String getEmailBodyTransferToKOManualEntry(Id opportunityId) {
        return 'Перевод в КО. Данные были введены вручную = Да<br/>Клиент дошел до заполнения Платежных реквизитов<a href="' +
                E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu').Domain_Url__c + '/' + opportunityId + '" target="_blank"> Ссылка на возможность</a>.';
    }

    //TODO:
    public static String getEmailBodyForRefusingOpportunity(Id opportunityId) {
        String body = 'Ваша Возможность: <a href="' + E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu').Domain_Url__c + '/' + opportunityId + '" target="_blank"> Ссылка на возможность </a> ' +
                'отправлена в Отказ, клиент передан в E2E <br/>';
        return body;
    }

    //******* Notification Part *******//

    public void sendE2ENotification(String body, String subject, GlobalUtils.E2ERuGroupsNotification additionalGroupsNotification) {
        try {
            sendE2ENotification(new Set<Id>(), body, subject, additionalGroupsNotification);
        } catch (Exception e) {
            String notificationMessage = '<br/>E2E method forceUpdateOpportunity(): ' + String.valueOf(e.getMessage());
            ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
        }
    }


    /*******************************************************************************
    *  Name            : sendE2ENotification()
    *  Summary         : return set of email address for notification
    *  CreatedDate     : 21/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Set<String> emailAddresses - addresses
    *                    String body - email body
    *                    GlobalUtils.E2ERuGroupsNotification groupsNotification
    *  Returns         : Set<String> emailAddresses
    ******************************************************************************/
    private static void sendE2ENotification(Set<Id> userIds, String body, String subject, GlobalUtils.E2ERuGroupsNotification additionalGroupsNotification) {
        if (subject == null || subject == '') {
            subject = 'Russia E2E Notification';
        }

        Set<String> externalEmailAddresses = new Set<String>();
        prepareAddressesForNotification(userIds, externalEmailAddresses, additionalGroupsNotification);

        System.debug('userIds: ' + userIds);
        System.debug('externalEmailAddresses: ' + externalEmailAddresses);

        List<Messaging.Email> messagesForSend = new List<Messaging.Email>();
        for (Id currentUserId : userIds) {
            Messaging.SingleEmailMessage emailMessage = EmailGenerator.prepareHtmlEmailToTarget(currentUserId, subject, body);
            messagesForSend.add(emailMessage);
        }

        if ( ! externalEmailAddresses.isEmpty() ) {
            Messaging.SingleEmailMessage externalEmailMessage = EmailGenerator.prepareHtmlEmailToTarget(new List<String>(externalEmailAddresses), subject, body);
            messagesForSend.add(externalEmailMessage);
        }

        if ( ! messagesForSend.isEmpty() && ! Test.isRunningTest() ) {
            System.debug('Send Emails: ' + messagesForSend);
            Messaging.sendEmail(messagesForSend);
        }
    }

    /*******************************************************************************
    *  Name            : getEmailAddressesForNotification(GlobalUtils.E2ERuGroupsNotification groupOfManagers)
    *  Summary         : return set of email address for notification
    *  CreatedDate     : 21/09/2018
    *  ModifiedDate    : -
    *  Parameters      : GlobalUtils.E2ERuGroupsNotification groupOfManagers
    *  Returns         : Set<String> emailAddresses
    ******************************************************************************/
    public static void prepareAddressesForNotification(Set<Id> userIds, Set<String> emails, GlobalUtils.E2ERuGroupsNotification groupOfManagers) {
        E2E_Form_Ru_General_Settings__c settings = E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu');
        if (settings != null) {

            E2EFormRuDaoImpl e2eFormRuDao = new E2EFormRuDaoImpl();
            // Default added email addresses from main managers group
            String emailAddressesOfMainManagers = settings.External_Main_Managers__c;
            if (settings.External_Main_Managers__c != null && settings.External_Main_Managers__c != '') {
                emails.addAll(emailAddressesOfMainManagers.split(';'));
            }

            // Default added user ids from main managers group
            String externalUserNames = GlobalUtils.blankStringIfNull(settings.Main_Managers__c);
            if (externalUserNames != null && externalUserNames != '') {
                userIds.addAll(e2eFormRuDao.getUsersByNames( new Set<String>(externalUserNames.split(';')) ).keySet());
            }

            if (groupOfManagers == GlobalUtils.E2ERuGroupsNotification.Service) {
                String emailAddressesOfServiceManagers = settings.External_Service_Managers__c;
                if (emailAddressesOfServiceManagers != null && emailAddressesOfServiceManagers != '') {
                    emails.addAll(emailAddressesOfServiceManagers.split(';'));
                }

                String externalServiceManagers = settings.Service_Managers__c;
                if (externalServiceManagers != null && externalServiceManagers != '') {
                    userIds.addAll(e2eFormRuDao.getUsersByNames( new Set<String>(externalServiceManagers.split(';')) ).keySet());
                }
            } else if (groupOfManagers == GlobalUtils.E2ERuGroupsNotification.CallCenter) {
                String emailAddressesOfCallCenterManagers = settings.External_Call_Center_Managers__c;
                if (emailAddressesOfCallCenterManagers != null && emailAddressesOfCallCenterManagers != '') {
                    emails.addAll(emailAddressesOfCallCenterManagers.split(';'));
                }

                String externalCallCenterManagers = settings.Call_Center_Managers__c;
                if (externalCallCenterManagers != null && externalCallCenterManagers != '') {
                    userIds.addAll(e2eFormRuDao.getUsersByNames( new Set<String>(externalCallCenterManagers.split(';')) ).keySet());
                }
            } else if (groupOfManagers == GlobalUtils.E2ERuGroupsNotification.Inbound) {
                String emailAddressesOfInboundManagers = settings.External_Inbound_Managers__c;
                if (emailAddressesOfInboundManagers != null && emailAddressesOfInboundManagers != '') {
                    emails.addAll(emailAddressesOfInboundManagers.split(';'));
                }

                String externalInboundManagers = GlobalUtils.blankStringIfNull(settings.Inbound_Managers__c);
                if (externalInboundManagers != null && externalInboundManagers != '') {
                    userIds.addAll(e2eFormRuDao.getUsersByNames( new Set<String>(externalInboundManagers.split(';')) ).keySet());
                }
            }
        }
    }

    public void updateEncodedUrl(Id opportunityId, Id formDataId, E2EFormParams formParams){
        Opportunity opportunity = new Opportunity(Id = opportunityId);
        opportunity.E2E_Encoded_URL__c = formParams.encodedURL;
        system.enqueueJob(new E2EFormRuServiceImpl.updateOpportunityQueueable(opportunity,'firstFormUrl'));

        E2EFormData__c formDataRecord = new E2EFormData__c(Id = formDataId);
        formDataRecord.E2E_Form_URL__c = URL.getSalesforceBaseUrl().toExternalForm() + '/e2eFormRu?country=Russia&link=' + formParams.encodedURL;
        system.enqueueJob(new E2EFormRuServiceImpl.updateFormDataQueueable(formDataRecord,'firstFormUrl'));
    }

    //***** Remote Action *****//

    public void updateSoleProprietorInfoFromSpark(E2EFormParams formParams, String formDataId) {
        // update FormData
        E2EFormData__c formDataRecord = this.e2eFormRuDao.getFormDataById(formDataId);
        formDataRecord.E2E_Account_Short_Name__c = formParams.mainCompanyFullNameSpark.removeStart('ИП ');
        formDataRecord.E2E_Executive_Person__c = GlobalUtils.blankStringIfNull(formParams.soleProprietorFio) + ', ' + 'Индивидуальный предприниматель';
        formDataRecord.E2E_OGRN__c = GlobalUtils.blankStringIfNull(formParams.ogrnipSpark);
        formDataRecord.E2E_OKPO__c = GlobalUtils.blankStringIfNull(formParams.okpoSpark);
        formDataRecord.E2E_Spark_Id__c = String.valueOf(formParams.sparkID);
        formDataRecord.E2E_Main_Company_Full_Name__c =  GlobalUtils.blankStringIfNull(formParams.mainCompanyFullNameSpark);
        formDataRecord.E2E_Reg_Date__c = GlobalUtils.blankStringIfNull(formParams.registrationDateSpark);
        this.e2eFormRuDao.updateFormData(formDataRecord);

        // update Account
        Account account = new Account(Id = formDataRecord.E2E_Account_Id__c);
        account.OGRN_ppr__c = GlobalUtils.blankStringIfNull(formParams.ogrnipSpark);
        account.Organization_Type__c = 'ИП';
        account.OKPO_ppr__c = GlobalUtils.blankStringIfNull(formParams.okpoSpark);
        this.e2eFormRuDao.updateAccount(account);
    }

    public void updateCompanyInformationFromSpark(E2EFormParams formParams, String formDataId, String opportunityId) {

        // init address
        String street = formParams.streetSpark == null ? '' : GlobalUtils.blankStringIfNull(formParams.streetSpark);
        String building = formParams.buildingSpark == null ? '' : ', ' + GlobalUtils.blankStringIfNull(formParams.buildingSpark);
        String housing = formParams.housingSpark == null ? '' : ', ' +  GlobalUtils.blankStringIfNull(formParams.housingSpark);
        String block = formParams.blockSpark == null ? '' : ', ' +  GlobalUtils.blankStringIfNull(formParams.blockSpark);
        String room = formParams.roomSpark == null ? '' : ', ' +  GlobalUtils.blankStringIfNull(formParams.roomSpark);

        // update FormData
        E2EFormData__c formDataRecord = this.e2eFormRuDao.getFormDataById(formDataId);
        System.debug('*** updateCompanyInformationFromSpark -> currentAccount ' + formDataRecord.E2E_Account_Id__c);
        formDataRecord.E2E_Account_Short_Name__c = GlobalUtils.parseNormNameForOrganization(formParams.normName).get(0);
        String executiveFio = GlobalUtils.blankStringIfNull(formParams.executiveFio);
        String executivePosition = formParams.executivePosition == null ? '' : ', ' +  GlobalUtils.blankStringIfNull(formParams.executivePosition);
        formDataRecord.E2E_Executive_Person__c = executiveFio + executivePosition;
        formDataRecord.E2E_Reg_Date__c = GlobalUtils.blankStringIfNull(formParams.registrationDateSpark);
        formDataRecord.E2E_OGRN__c = GlobalUtils.blankStringIfNull(formParams.ogrnSpark);
        formDataRecord.E2E_OKPO__c = GlobalUtils.blankStringIfNull(formParams.okpoSpark);
        formDataRecord.E2E_KPP__c = GlobalUtils.blankStringIfNull(formParams.kppSpark);
        formDataRecord.E2E_Spark_Id__c = GlobalUtils.blankStringIfNull(String.valueOf(formParams.sparkId));
        formDataRecord.E2E_Main_Company_Full_Name__c = GlobalUtils.blankStringIfNull(formParams.mainCompanyFullNameSpark);
        formDataRecord.E2E_INN__c = GlobalUtils.blankStringIfNull(formParams.companyInn);
        formDataRecord.E2E_Billing_Code__c = GlobalUtils.blankStringIfNull(formParams.postCodeSpark);
        formDataRecord.E2E_Billing_State__c = GlobalUtils.blankStringIfNull(formParams.regionSpark);
        formDataRecord.E2E_Billing_City__c = GlobalUtils.blankStringIfNull(formParams.citySpark);
        formDataRecord.E2E_Billing_Str__c = street + building;
        formDataRecord.E2E_Billing_Apartment__c = housing + block + room;
        formDataRecord.E2E_Legal_Address__c =  GlobalUtils.blankStringIfNull(formParams.legalAddressSpark);
        this.e2eFormRuDao.updateFormData(formDataRecord);

        // update Account
        Account account = new Account(Id = formDataRecord.E2E_Account_Id__c);
        account.BillingPostalCode = GlobalUtils.blankStringIfNull(formParams.postCodeSpark);
        account.BillingCity = GlobalUtils.blankStringIfNull(formParams.citySpark);
        account.BillingStreet = street + building + housing + block + room;
        account.Region__c = GlobalUtils.blankStringIfNull(formParams.regionSpark);
        account.OKPO_ppr__c = formParams.okpoSpark;
        account.OGRN_ppr__c = formParams.ogrnSpark;
        String KPP = formParams.kppSpark;
        account.KPP__c = (KPP == '' || KPP == null) ? 0 : Decimal.valueOf(KPP);
        account.Organization_Type__c = GlobalUtils.parseNormNameForOrganization(formParams.normName).get(1);
        this.e2eFormRuDao.updateAccount(account);
    }

    public void updateVerifiedDecision(E2EFormParams formParams, String formDataId, String opportunityId) {

        // update FormData
        E2EFormData__c formDataRecord = this.e2eFormRuDao.getFormDataById(formDataId);
        formDataRecord.E2E_Black_List_Code__c = GlobalUtils.blankStringIfNull(formParams.verifiedDecisionCode);
        formDataRecord.E2E_Black_List__c = GlobalUtils.blankStringIfNull(formParams.verifiedDecision);
        formDataRecord.E2E_Black_List_Limitations__c = GlobalUtils.blankStringIfNull(formParams.verifiedLimitation);
        this.e2eFormRuDao.updateFormData(formDataRecord);

        // update Opportunity
        Opportunity opportunity = new Opportunity(Id = opportunityId);
        if (formParams.verifiedDecisionCode != null) {
            if (formParams.verifiedDecisionCode == '3' || formParams.scoringDecisionCode == '2') {
                opportunity.E2E_Sub_Status__c = 'Чёрный список';
                opportunity.E2E_Sales_Type__c = 'Отклонен';
                opportunity.StageName = 'Отказ';
                opportunity.PPR_Lost_Reasons__c = formParams.opportunityLostReason;
                opportunity.E2E_Status__c = 'Клиент завершил';
            }
        }
        this.e2eFormRuDao.updateOpportunity(opportunity);
    }

    public void updateScoringDecision(E2EFormParams formParams, String formDataId, String opportunityId) {
        // update FormData
        E2EFormData__c formDataRecord = this.e2eFormRuDao.getFormDataById(formDataId);
        formDataRecord.E2E_Scoring_Decision_Code__c = GlobalUtils.blankStringIfNull(formParams.scoringDecisionCode);
        formDataRecord.E2E_Scoring_Decision__c = GlobalUtils.blankStringIfNull(formParams.scoringDecision);
        formDataRecord.E2E_Scoring_Date__c = formParams.scoringDate;
        formDataRecord.E2E_Scoring_Expiration_Date__c = formParams.scoringDate == null ? null : formParams.scoringDate.addMonths(3);
        this.e2eFormRuDao.updateFormData(formDataRecord);
    }

}