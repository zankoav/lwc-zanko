/**
 * Created by Nikita.Mikhailov on 21.01.2019.
 * Class for creating REST request to the GFNI via IBM GW
 * Fields logic defined in mapping documents and GFNI_Mapping static resource
 */
//TODO: check code coverage
public with sharing class GFNI_RequestBuilder {

//    public static String buildJSONGetCustomerId(Opportunity opp) {
////        Opportunity opp = [
////                SELECT Id, Account.Account_Nr__c, Account.Name, Account.Umsatzsteuer_ID__c, Account.BillingCountryCode,
////                        Account.BillingCountry, Account.Owner.Name, (SELECT Id, Contact.Email FROM OpportunityContactRoles WHERE IsPrimary = true LIMIT 1)
////                FROM Opportunity
////                WHERE Id = :opportunity.Id
////        ];
//
//        GFNI_GetCustomerIdRequest getCustomerIdRequest = new GFNI_GetCustomerIdRequest();
//        getCustomerIdRequest.Metadata = buildMetadataObject(opp.Account);
//
//        getCustomerIdRequest.Name = opp.Account.Name;
//        getCustomerIdRequest.EmailAddress = opp.OpportunityContactRoles.get(0).Contact.Email;
//        getCustomerIdRequest.CompanyRegNumber = opp.Account.Account_Nr__c;
//        getCustomerIdRequest.VATNumber = opp.Account.Umsatzsteuer_ID__c;
//
//        return JSON.serialize(getCustomerIdRequest);
//    }


    /*******************************************************************************
    *  Name            : buildJSONCreateCustomerAndCards
    *  Summary         : build create new customer with cards REST request. Mapping are provided by business in mapping doc
    *  CreatedDate     : 21/01/2019
    *  Parameters      : Set<Id> opptysToUpdate
    *  Returns         : void
    ******************************************************************************/
    public static String buildJSONCreateCustomerAndCards(Opportunity opportunity) {

        /*******************************************************************************
        *   Mapping for GFN Ids is presented as JSON file in static resources - GFNI_Mapping. First get look into it!
        *   Examples of not standard data input:
        *       acc.BillingCountryCode.substring(0, 2) - there may situation when in country code we can have doubled value (BENL, CHFR etc.). In that case need to use first two letters to get country code. Confirmed by Fučíková Michaela <michaela.fucikova@fleetcor.de>
        *       gfni_contact.Primary = contact.IsPrimary == true ? 1 : 0 - as long GFN is not understand "true" or "false" as boolean this code changes boolean to integer 1 or 0
        ******************************************************************************/

        Opportunity opp = [
                SELECT Name, AccountId, Id, Sec_Channel__c, Language_Preference__c, Owner.FirstName,
                        Owner.LastName, Owner.Name, SWIFT_BIC__c, IBAN__c, Credit_System_Number__c, Product__c,
                        ESI__c, Total_number_of_vehicles__c, Total_consumption_l_month__c, Zahlungsart__c, Credit_Limit__c,
                        Zahlungsziel_Credit__c, Risk_Category__c, Next_Review_date__c, Rechnungsperiode__c, Papierrechnung__c, e_Invoicing_PDF__c,
                        Credit_System_Rating__c, Garantie__c, Garantie_other__c,Eco_Fee__c, VAT_Recovery__c, Direct_Debit_Mandate_Type__c, Custom_PIN__c, (
                        SELECT Contact.Id, Contact.Name, Contact.Salutation, Contact.FirstName, Contact.MiddleName, Contact.LastName,
                                Role, Contact.Email, Contact.Phone, Contact.MobilePhone, Contact.Fax, IsPrimary
                        FROM OpportunityContactRoles
                        LIMIT 3
                ), (
                        SELECT Id, Gewuenschter_Kartentyp__c, Produktbezugskategorie__c, Fahrzeugtyp__c, Firmenname_auf_der_Karte__c,
                                KFZ_Kennzeichen_oder_Fahrername__c, Driver_Name__c, Kilometerstand_Abfrage__c
                        FROM Tankkarten__r
                )
                FROM Opportunity
                WHERE id = :opportunity.Id
                LIMIT 1
        ];

        Account acc = [
                SELECT Id, Owner.Name, Account_Nr__c, Name, Steuernummer__c, HR_Abteilung_HRA_HRB_und_HR_Nummer__c,
                        Umsatzsteuer_ID__c, BillingCountry, BillingCountryCode, BillingState, BillingCity,
                        BillingPostalCode, BillingStreet, ShippingCountry, ShippingCountryCode, ShippingState,
                        ShippingCity, ShippingPostalCode, ShippingStreet, Phone, UMR__c
                FROM Account
                WHERE Id = :opp.AccountId
                LIMIT 1
        ];

        GFNI_CommunicationPreferences communicationPreferences = new GFNI_CommunicationPreferences();

        if (opp.Papierrechnung__c) {
            communicationPreferences.InvoicingType = 'Print';
            communicationPreferences.OutputTypeId = GFNI_Utils.getIntegerValue('Print', null, 'OutputTypeId');
        } else if (opp.e_Invoicing_PDF__c) {
            communicationPreferences.InvoicingType = 'Email';
            communicationPreferences.OutputTypeId = GFNI_Utils.getIntegerValue('Link', null, 'OutputTypeId');
        } else {
            communicationPreferences.InvoicingType = 'Email';
            communicationPreferences.OutputTypeId = GFNI_Utils.getIntegerValue('PDF', null, 'OutputTypeId');
        }

        GFNI_BankAccount bankAccount = new GFNI_BankAccount();
        GFNI_PaymentInfo paymentInfo = new GFNI_PaymentInfo();

        Map<String, Object> paymentMethodMapping = (Map<String, Object>) GFNI_Utils.gfniMapping.get('PaymentMethodId');
        Map<String, Object> paymentMethodCountryMapping = (Map<String, Object>) paymentMethodMapping.get(acc.BillingCountryCode.substring(0, 2));

        //business requires for all CEE countries (PL,HU,CZ,SK) ignore this logic and always set Payment Method as 'Bank transfer' and leave bank account section blank. This is kostyl and I don't like it!
        if (acc.BillingCountryCode.substring(0, 2) != 'PL' && acc.BillingCountryCode.substring(0, 2) != 'HU' && acc.BillingCountryCode.substring(0, 2) != 'CZ' && acc.BillingCountryCode.substring(0, 2) != 'SK') {
            if (paymentMethodCountryMapping.get(GlobalUtils.getPicklistValueTranslation(Schema.Opportunity.Zahlungsart__c.getDescribe(), opp.Zahlungsart__c)) instanceof Map<String, Object>) {
                Map<String, Object> paymentMethodDDMapping = (Map<String, Object>) paymentMethodCountryMapping.get(GlobalUtils.getPicklistValueTranslation(Schema.Opportunity.Zahlungsart__c.getDescribe(), opp.Zahlungsart__c));
                paymentInfo.PaymentMethodId = Integer.valueOf(paymentMethodDDMapping.get(opp.Direct_Debit_Mandate_Type__c));
            } else {
                paymentInfo.PaymentMethodId = Integer.valueOf(paymentMethodCountryMapping.get(GlobalUtils.getPicklistValueTranslation(Schema.Opportunity.Zahlungsart__c.getDescribe(), opp.Zahlungsart__c)));
            }

            if (!GlobalUtils.blankStringIfNull(GlobalUtils.getPicklistValueTranslation(Schema.Opportunity.Zahlungsart__c.getDescribe(), opp.Zahlungsart__c)).equals('Bank transfer')) {
                bankAccount.SwiftCode = opp.SWIFT_BIC__c;

                if (opp.IBAN__c != null)
                    bankAccount.IBAN = opp.IBAN__c.replaceAll('\\W', '');

                bankAccount.DDDRefNo = acc.UMR__c;
                bankAccount.DDEffectiveDate = Datetime.newInstance(Date.today().year(), Date.today().month(), Date.today().day()).format('yyyy-MM-dd');

                bankAccount.DDMandateTypeId = GFNI_Utils.getIntegerValue(opp.Direct_Debit_Mandate_Type__c, null, 'DirectDebitMandateTypeID');
            }
        } else {
            paymentInfo.PaymentMethodId = Integer.valueOf(paymentMethodCountryMapping.get('Bank transfer'));
        }

        if (String.isNotBlank(opp.Zahlungsziel_Credit__c)) {
            paymentInfo.PaymentTermsId = GFNI_Utils.getIntegerValue(opp.Zahlungsziel_Credit__c, null, 'PaymentTermsId');
        } else {
            throw new GlobalException('Payment terms Credit is empty.');
        }

        Map<String, Object> paymentFrequencyIdMapping = (Map<String, Object>) GlobalUtils.getValueUntypedFromJSON(GFNI_Utils.gfniMapping, 'PaymentFrequencyId');
        Map<String, Object> paymentFrequencyIdCountry = (Map<String, Object>) paymentFrequencyIdMapping.get(acc.BillingCountryCode.substring(0, 2));
        paymentInfo.PaymentFrequencyId = Integer.valueOf(paymentFrequencyIdCountry.get(GlobalUtils.getPicklistValueTranslation(Schema.Opportunity.Rechnungsperiode__c.getDescribe(), opp.Rechnungsperiode__c)));

        paymentInfo.addBankAccount(bankAccount);

        List<GFNI_Card> cardOrder = new List<GFNI_Card>();

        if (!opp.Custom_PIN__c) {
            Map<String, Object> cardIdMapping = (Map<String, Object>) GlobalUtils.getValueUntypedFromJSON(GFNI_Utils.gfniMapping, 'CardTypeId');
            Map<String, Object> cardIdCountry = (Map<String, Object>) cardIdMapping.get(GlobalUtils.blankStringIfNull(acc.BillingCountryCode.substring(0, 2)));

            Map<String, Object> purchaseCategoryIdMapping = (Map<String, Object>) GlobalUtils.getValueUntypedFromJSON(GFNI_Utils.gfniMapping, 'PurchaseCategoryId');
            Map<String, Object> purchaseCategoryIdCountry = (Map<String, Object>) purchaseCategoryIdMapping.get(GlobalUtils.blankStringIfNull(acc.BillingCountryCode.substring(0, 2)));

            List<Tankkarten__c> cardsWithInvalidCardTypeId = new List<Tankkarten__c>();

            for (Tankkarten__c card : opp.Tankkarten__r) {
                GFNI_Card gfni_card = new GFNI_Card();

                gfni_card.CardRefId = GlobalUtils.generateGUIDFromId(card.Id);

                if (card.Driver_Name__c == null) {
                    //vehicle
                    gfni_card.CardCategoryId = GFNI_Utils.getIntegerValue('Vehicle', null, 'CardCategoryId');
                    gfni_card.EmbossingId = GFNI_Utils.getIntegerValue('Vehicle', null, 'EmbossingId');
                    gfni_card.VehicleRegistrationNumber = GFNI_Utils.replaceSpecialCharacters(card.KFZ_Kennzeichen_oder_Fahrername__c);
                } else {
                    //driver
                    gfni_card.CardCategoryId = GFNI_Utils.getIntegerValue('Driver', null, 'CardCategoryId');
                    gfni_card.EmbossingId = GFNI_Utils.getIntegerValue('Driver', null, 'EmbossingId');
                    gfni_card.DriverName = GFNI_Utils.replaceSpecialCharacters(card.Driver_Name__c);
                }

                Map<String, Object> cardIdBusiness = (Map<String, Object>) cardIdCountry.get(GlobalUtils.blankStringIfNull(GlobalUtils.getPicklistValueTranslation(Schema.Tankkarten__c.Fahrzeugtyp__c.getDescribe(), card.Fahrzeugtyp__c)));
                gfni_card.CardTypeId = Integer.valueOf(cardIdBusiness.get(GlobalUtils.getPicklistValueTranslation(Schema.Tankkarten__c.Gewuenschter_Kartentyp__c.getDescribe(), card.Gewuenschter_Kartentyp__c)));

                if (gfni_card.CardTypeId == null)
                    cardsWithInvalidCardTypeId.add(card);

                gfni_card.OdometerPromptRequired = card.Kilometerstand_Abfrage__c == true ? 1 : 0;

                if (String.isNotBlank(card.Produktbezugskategorie__c)) {
                    if (purchaseCategoryIdCountry.get(GlobalUtils.getPicklistValueTranslation(Schema.Tankkarten__c.Produktbezugskategorie__c.getDescribe(), card.Produktbezugskategorie__c)) instanceof Map<String, Object>) {
                        Map<String, Object> purchaseCategoryIdNational = (Map<String, Object>) purchaseCategoryIdCountry.get(GlobalUtils.getPicklistValueTranslation(Schema.Tankkarten__c.Produktbezugskategorie__c.getDescribe(), card.Produktbezugskategorie__c));
                        gfni_card.PurchaseCategoryId = Integer.valueOf(purchaseCategoryIdNational.get((GlobalUtils.getPicklistValueTranslation(Schema.Tankkarten__c.Gewuenschter_Kartentyp__c.getDescribe(), card.Gewuenschter_Kartentyp__c)).split('.+ -- ').get(1)));
                    } else {
                        gfni_card.PurchaseCategoryId = Integer.valueOf(purchaseCategoryIdCountry.get(GlobalUtils.getPicklistValueTranslation(Schema.Tankkarten__c.Produktbezugskategorie__c.getDescribe(), card.Produktbezugskategorie__c)));
                    }
                } else {
                    throw new GlobalException('Category of product is empty on card: ' + card.Name);
                }

                cardOrder.add(gfni_card);
            }

            if (!cardsWithInvalidCardTypeId.isEmpty()) {
                String errorMessage = 'Card type is not mapped for client cards.\n' +
                        'Opportunity name: ' + opp.Name + '\n' +
                        'Cards: \n';
                for (Tankkarten__c card : cardsWithInvalidCardTypeId) {
                    errorMessage += URL.getSalesforceBaseUrl().toExternalForm() + '/' + card.Id + ' \n';
                }
                throw new GlobalException(errorMessage);
            }
        }

        GFNI_CreditInfo creditInfo = new GFNI_CreditInfo();
        creditInfo.CreditSystemNumber = opp.Credit_System_Number__c;

        creditInfo.CreditLimit = opp.Credit_Limit__c;

        if (String.isNotBlank(GFNI_Utils.getStringValue(opp.Credit_System_Rating__c, Schema.Opportunity.Credit_System_Rating__c.getDescribe(), 'CreditSystemRating'))) {
            creditInfo.CreditSystemRating = GFNI_Utils.getStringValue(opp.Credit_System_Rating__c, Schema.Opportunity.Credit_System_Rating__c.getDescribe(), 'CreditSystemRating');
        } else {
            creditInfo.CreditSystemRating = opp.Credit_System_Rating__c;
        }

        if (opp.Risk_Category__c != null) {
            creditInfo.CreditRatingId = GFNI_Utils.getIntegerValue(opp.Risk_Category__c, Schema.Opportunity.Risk_Category__c.getDescribe(), 'CreditRatingId');
        } else {
            throw new GlobalException('Risk Category is empty.');
        }

        List<GFNI_Contact> contacts = new List<GFNI_Contact>();

        String primaryContactPhone;

        for (OpportunityContactRole contact : opp.OpportunityContactRoles) {
            GFNI_Contact gfni_contact = new GFNI_Contact();
            gfni_contact.Primary = contact.IsPrimary == true ? 1 : 0;

            if (contact.IsPrimary) {
                if (contact.Contact.Phone != null) {
                    primaryContactPhone = GFNI_Utils.returnCorrectPhoneNumber(contact.Contact.Phone, acc.BillingCountryCode.substring(0, 2));
                } else {
                    primaryContactPhone = GFNI_Utils.returnCorrectPhoneNumber(contact.Contact.MobilePhone, acc.BillingCountryCode.substring(0, 2));
                }
            }

            if (String.isNotBlank(contact.Contact.Salutation)) {
                gfni_contact.SalutationId = GFNI_Utils.getIntegerValue(contact.Contact.Salutation, Schema.Contact.Salutation.getDescribe(), 'SalutationId');
            } else {
                throw new GlobalException('Salutation is empty on contact: ' + contact.Contact.Name);
            }
            gfni_contact.FirstName = contact.Contact.FirstName;
            gfni_contact.MiddleName = contact.Contact.MiddleName;
            if (contact.Contact.LastName != null) {
                gfni_contact.LastName = contact.Contact.LastName;
            } else {
                throw new GlobalException('Last name is empty on contact ' + contact.Contact.Name);
            }
            if (contact.Contact.Phone != null)
                gfni_contact.Phone = GFNI_Utils.returnCorrectPhoneNumber(contact.Contact.Phone, acc.BillingCountryCode.substring(0, 2));

            gfni_contact.Fax = contact.Contact.Fax;

            if (contact.Contact.MobilePhone != null)
                gfni_contact.Mobile = GFNI_Utils.returnCorrectPhoneNumber(contact.Contact.MobilePhone, acc.BillingCountryCode.substring(0, 2));


            gfni_contact.Email = contact.Contact.Email;

            if (String.isNotBlank(opp.Language_preference__c)) {
                gfni_contact.Language = GFNI_Utils.getStringValue(opp.Language_preference__c, Schema.Opportunity.Language_preference__c.getDescribe(), 'LanguageCode');
            } else {
                throw new GlobalException('Language preference is empty.');
            }

            contacts.add(gfni_contact);
        }

        List<GFNI_Address> addresses = new List<GFNI_Address>();

        GFNI_Address address = new GFNI_Address();

//        List<String> addressLines = GlobalUtils.splitStringByNumberOfLines(acc.BillingStreet, 3, 40);
//        String addressLine = '';

        addresses.add(buildAddressObject(acc, 3, primaryContactPhone, true));

        List<Object> addressTypeIdList = (List<Object>) GlobalUtils.getValueUntypedFromJSON(GFNI_Utils.gfniMapping, 'AddressTypeId');

        for (Object typeId : addressTypeIdList) {
            addresses.add(buildAddressObject(acc, Integer.valueOf(typeId), primaryContactPhone, false));
        }

        GFNI_Customer customer = new GFNI_Customer();

        if (acc.Name != null) {
            customer.AccountName = acc.Name;
        } else {
            throw new GlobalException('Customer name is empty.');
        }

        if (acc.Account_Nr__c != null)
            customer.AccountNumber = acc.Account_Nr__c.remove('-');

        customer.AccountManager = opp.Owner.Name;
        if (acc.Steuernummer__c != null) {
            customer.TradeRegistrationNumber = acc.Steuernummer__c;
        } else {
            customer.TradeRegistrationNumber = acc.HR_Abteilung_HRA_HRB_und_HR_Nummer__c;
        }

        Map<String, Object> legalEntityIdMapping = (Map<String, Object>) GlobalUtils.getValueUntypedFromJSON(GFNI_Utils.gfniMapping, 'LegalEntityId');
        customer.LegalEntityId = Integer.valueOf(legalEntityIdMapping.get(acc.BillingCountryCode.substring(0, 2)));

        if (acc.BillingCountryCode != null)
            customer.RegisteredCountryCode = acc.BillingCountryCode.substring(0, 2);

        if (acc.BillingCountryCode != null) {
            switch on acc.BillingCountryCode.substring(0, 2) {
                when 'HU' {
                    customer.VATNumber = acc.Umsatzsteuer_ID__c;
                }
                when else {
                    if (acc.Umsatzsteuer_ID__c != null)
                        customer.VATNumber = acc.Umsatzsteuer_ID__c.replaceAll('\\W', '');
                }
            }
        }

        Map<String, Object> priceProfileIdByCountry = (Map<String, Object>) GlobalUtils.getValueUntypedFromJSON(GFNI_Utils.gfniMapping, 'PriceProfileId');
        Map<String, Object> priceProfileIdByProduct = (Map<String, Object>) priceProfileIdByCountry.get(acc.BillingCountryCode.substring(0, 2));

        if (priceProfileIdByProduct.containsKey(opp.Product__c)) {
            if (priceProfileIdByProduct.get(opp.Product__c) instanceof Map<String, Object>) {
                Map<String, Object> priceProfileIdByPaymentMethod = (Map<String, Object>) priceProfileIdByProduct.get(opp.Product__c);
                customer.PriceProfileId = Integer.valueOf(priceProfileIdByPaymentMethod.get(GlobalUtils.getPicklistValueTranslation(Schema.Opportunity.Zahlungsart__c.getDescribe(), opp.Zahlungsart__c)));
            } else {
                customer.PriceProfileId = Integer.valueOf(priceProfileIdByProduct.get(opp.Product__c));
            }
        } else {
            throw new GlobalException('Price profile is not mapped to product ' + opp.Product__c);
        }

        if (opp.Total_number_of_vehicles__c > 10) {
            customer.CustomerSegmentationId = GFNI_Utils.getIntegerValue(11, null, 'CustomerSegmentationId');
        } else {
            customer.CustomerSegmentationId = GFNI_Utils.getIntegerValue(opp.Total_number_of_vehicles__c.intValue(), Schema.Opportunity.Total_number_of_vehicles__c.getDescribe(), 'CustomerSegmentationId');
        }

        if (String.isNotBlank(opp.Product__c)) {
            customer.MarketingSegmentationId = GFNI_Utils.getIntegerValue(opp.Product__c, Schema.Opportunity.Product__c.getDescribe(), 'MarketingSegmentationId');
            if (customer.MarketingSegmentationId == null)
                throw new GlobalException('Marketing segmentation have no mapping for product ' + opp.Product__c);
        } else {
            throw new GlobalException('Product is empty.');
        }

        customer.EstimatedFuelVolume = opp.Total_consumption_l_month__c;

        if (opp.Language_preference__c != null) {
            customer.Language = GFNI_Utils.getStringValue(opp.Language_preference__c, Schema.Opportunity.Language_preference__c.getDescribe(), 'LanguageCode');
            customer.BillingLanguage = GFNI_Utils.getStringValue(opp.Language_preference__c, Schema.Opportunity.Language_preference__c.getDescribe(), 'LanguageCode');
        } else {
            throw new GlobalException('Language preference is empty.');
        }

        if (!opp.Tankkarten__r.isEmpty()) {
            if (String.isNotBlank(GFNI_Utils.replaceSpecialCharacters(opp.Tankkarten__r.get(0).Firmenname_auf_der_Karte__c))) {
                customer.ShortName = GFNI_Utils.replaceSpecialCharacters(opp.Tankkarten__r.get(0).Firmenname_auf_der_Karte__c);
            }
        }

        if (!String.isNotBlank(customer.ShortName))
            throw new GlobalException('No company short name are provided.');

        Map<String, Object> feeGroupIdMapping = (Map<String, Object>) GlobalUtils.getValueUntypedFromJSON(GFNI_Utils.gfniMapping, 'FeeGroupId');
        Map<String, Object> feeGroupIdCountry = (Map<String, Object>) feeGroupIdMapping.get(acc.BillingCountryCode.substring(0, 2));

        if (feeGroupIdCountry.get(GlobalUtils.getPicklistValueTranslation(Schema.Opportunity.Product__c.getDescribe(), opp.Product__c)) instanceof Map<String, Object>) {
            Map<String, Object> feeGroupIdDebit = (Map<String, Object>) feeGroupIdCountry.get(GlobalUtils.getPicklistValueTranslation(Schema.Opportunity.Product__c.getDescribe(), opp.Product__c));
            customer.FeeGroupId = Integer.valueOf(feeGroupIdDebit.get(GlobalUtils.getPicklistValueTranslation(Schema.Opportunity.Zahlungsart__c.getDescribe(), opp.Zahlungsart__c)));
            if (customer.FeeGroupId == null)
                throw new GlobalException('Fee Group have no mapping for payment method ' + GlobalUtils.getPicklistValueTranslation(Schema.Opportunity.Zahlungsart__c.getDescribe(), opp.Zahlungsart__c));
        } else {
            customer.FeeGroupId = Integer.valueOf(feeGroupIdCountry.get(GlobalUtils.getPicklistValueTranslation(Schema.Opportunity.Product__c.getDescribe(), opp.Product__c)));
            if (customer.FeeGroupId == null)
                throw new GlobalException('Fee Group have no mapping for product ' + opp.Product__c);
        }

        if (opp.ESI__c != null)
            customer.HomeSiteCode = opp.ESI__c.replaceAll('(\\W|\\D)', '');

        if (opp.Eco_Fee__c != null)
            customer.IsEcoFeeRuleApplied = opp.Eco_Fee__c == true ? 1 : 0;

        Map<String, Object> acquisitionChannelIdMapping = (Map<String, Object>) GlobalUtils.getValueUntypedFromJSON(GFNI_Utils.gfniMapping, 'AcquisitionChannelId');
        Map<String, Object> acquisitionChannelIdCountry = (Map<String, Object>) acquisitionChannelIdMapping.get(GlobalUtils.blankStringIfNull(acc.BillingCountryCode.substring(0, 2)));

        customer.AcquisitionChannelId = Integer.valueOf(acquisitionChannelIdCountry.get((GlobalUtils.getPicklistValueTranslation(Schema.Opportunity.Sec_Channel__c.getDescribe(), opp.Sec_Channel__c))));

        //logic defined by business
        Map<String, Object> NumberOfCardsSelfServiceMapping = (Map<String, Object>) GlobalUtils.getValueUntypedFromJSON(GFNI_Utils.gfniMapping, 'NumberOfCardsSelfService');
        If (opp.Tankkarten__r.size() > Integer.valueOf(NumberOfCardsSelfServiceMapping.get(acc.BillingCountryCode.substring(0, 2)))) {
            customer.SelfServeUserId = 0;
        } else {
            customer.SelfServeUserId = 1;
        }

        //logic defined by business
        if (opp.Next_Review_Date__c != null) {
            customer.NextReviewDate = DateTime.newInstance(opp.Next_Review_Date__c.year(), opp.Next_Review_Date__c.month(), opp.Next_Review_Date__c.day()).format('yyyy-MM-dd');
        }

        customer.SecurityTypeId = GFNI_Utils.getIntegerValue(opp.Garantie__c, Schema.Opportunity.Garantie__c.getDescribe(), 'SecurityTypeId');
        customer.SecurityAmount = opp.Garantie_other__c;

        customer.Contacts = contacts;
        customer.Addresses = addresses;
        customer.CreditInfo = creditInfo;
        customer.CardOrder = cardOrder;
        customer.PaymentInfo = paymentInfo;
        customer.CommunicationPreferences = communicationPreferences;

        GFNI_CreateCustomerCardsRequest createCustomerCardsRequest = new GFNI_CreateCustomerCardsRequest();
        createCustomerCardsRequest.Metadata = buildMetadataObject(acc, opp.Owner.Name);

        Map<String, Object> serviceIdMapping = (Map<String, Object>) GlobalUtils.getValueUntypedFromJSON(GFNI_Utils.gfniMapping, 'ServiceId');

        if (opp.VAT_Recovery__c) {
            createCustomerCardsRequest.addServiceId(Integer.valueOf(serviceIdMapping.get('VAT Recovery')));
        }

        createCustomerCardsRequest.ApplicationId = GlobalUtils.generateGUID();
        createCustomerCardsRequest.Customer = customer;

        System.debug(createCustomerCardsRequest);

        return JSON.serialize(createCustomerCardsRequest);
    }

    /*******************************************************************************
    *  Name            : buildJSONApplicationStatus
    *  Summary         : build application status REST request as String. Mapping are provided by business in mapping doc
    *  CreatedDate     : 21/01/2019
    *  Parameters      : List<Opportunity> opportunities
    *  Returns         : String
    ******************************************************************************/
    public static String buildJSONApplicationStatus(List<Opportunity> opportunities) {
        GFNI_ApplicationStatusRequest applicationStatusRequest = new GFNI_ApplicationStatusRequest();
        applicationStatusRequest.Metadata = buildMetadataObject(opportunities.get(0).Account, 'E2EIntegration');

        List<GFNI_Application> applications = new List<GFNI_Application>();

        for (Opportunity opportunity : opportunities) {
            GFNI_Application application = new GFNI_Application();
            application.ApplicationDate = opportunity.CreatedDate.format('yyyy-MM-dd');
            application.ApplicationId = opportunity.GFNI_ApplicationId__c;
            applications.add(application);
        }

        applicationStatusRequest.Applications = applications;

        return JSON.serialize(applicationStatusRequest);
    }

    private static GFNI_Metadata buildMetadataObject(Account acc, String userName) {
        GFNI_Metadata metadata = new GFNI_Metadata();

        metadata.ColCoID = GFNI_Utils.getIntegerValue(acc.BillingCountry.split('-').get(0), Schema.Account.BillingCountry.getDescribe(), 'CompanyId');
        metadata.RequestID = GlobalUtils.generateGUID();
        metadata.UserCulture = GFNI_Utils.getStringValue(acc.BillingCountry, Schema.Account.BillingCountry.getDescribe(), 'CultureCode');
        metadata.UserName = userName.replaceAll(' ', '');

        return metadata;
    }

    private static GFNI_Address buildAddressObject(Account acc, Integer typeId, String primaryContactPhone, Boolean isBillingAddress) {
        GFNI_Address address = new GFNI_Address();

        if (typeId != null) {
            address.TypeId = typeId;
        } else {
            throw new GlobalException('Address type id empty.');
        }

        address.Phone = primaryContactPhone;

        if (isBillingAddress) {
            try {
                fillAddressWithChecks(address, acc.BillingCity, acc.BillingCountryCode.substring(0, 2), acc.BillingPostalCode, acc.BillingStreet);
            } catch (Exception e) {
                throw new GlobalException('Billing ' + e.getMessage());
            }
        } else {
            try {
                fillAddressWithChecks(address, acc.ShippingCity, acc.ShippingCountryCode.substring(0, 2), acc.ShippingPostalCode, acc.ShippingStreet);
            } catch (Exception e) {
                throw new GlobalException('Shipping ' + e.getMessage());
            }
        }

        return address;
    }

    private static void fillAddressWithChecks(GFNI_Address address, String city, String countryCode, String postalCode, String street) {
        if (String.isNotBlank(city)) {
            address.City = city;
        } else {
            throw new GlobalException('city is empty.');
        }

        if (String.isNotBlank(countryCode)) {
            address.CountryCode = countryCode;
        } else {
            throw new GlobalException('country code is empty.');
        }

        address.ZipCode = getZipCodeWithChecks(postalCode, countryCode);

        if (String.isNotBlank(street)) {
            if (street.length() <= 40) {
                address.Line1 = street;
            } else {
                throw new GlobalException('Address line is more than 40 characters.');
            }
        } else {
            throw new GlobalException('street is empty.');
        }
    }

    private static String getZipCodeWithChecks(String postalCode, String countryCode) {
        if (String.isNotBlank(postalCode)) {
            if (countryCode.substring(0, 2).equals('CH') || countryCode.substring(0, 2).equals('SK')) {
                if (postalCode.length() >= 5) {
                    postalCode = postalCode.remove(' ');
                    return postalCode.substring(0, 3) + ' ' + postalCode.substring(3);
                } else {
                    throw new GlobalException('postal code length is less than 5 characters.');
                }
            } else {
                return postalCode;
            }
        } else {
            throw new GlobalException('postal code is empty.');
        }
    }
}