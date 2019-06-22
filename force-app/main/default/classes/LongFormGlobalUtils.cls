public class LongFormGlobalUtils {
    public static final String EMAIL_REGEX = '^\\w+([.-]\\w+)*@\\w+([.-]\\w+)*(\\.\\w{2,4})+$';
    public static final String SWIFT_REGEX = '^[A-Za-z]{4}[A-Za-z]{2}[A-Za-z0-9]{2}([A-Za-z0-9]{3})?$';
    public static final String LETTERS_SPACES_REGEX = '^[a-zA-ZÀ-ž\\x7f-\\xff\\s\'-]+$';
    public static final String COMPANY_NAME_REGEX = '^[0-9a-zA-ZÀ-ž\\x7f-\\xff\\s\'&.,-]+$';
    public static final String CITY_REGEX = '^[a-zA-ZÀ-ž\\x7f-\\xff\\s\'.-]+$';
    public static final String CARD_COMPANY_DE = '^[0-9a-zA-Z\\s]+$';
    public static final String DATE_OF_BIRTH_REGEX = '^[0-9]{2}[.]{1}[0-9]{2}[.]{1}[0-9]{4}?$';
    public static final String PHONE_DE_REGEX = '^([0-9+]{13,15})$';
    public static final String PHONE_AT_REGEX = '^([0-9+]{3}[0]{0,1}[0-9]{13})$';
    public static final String PHONE_NL_REGEX = '^([0-9+]{12,13})$';
    public static final String PHONE_BENL_REGEX = '^([0-9+]{11,13})$';
    public static final String PHONE_BEFR_REGEX = '^([0-9+]{11,13})$';
    public static final String PHONE_RU_REGEX = '^([0-9]{10})+$';
    public static final String PHONE_PL_REGEX = '^([0-9+]{12,12})$';
    public static final String PHONE_HU_REGEX = '^([0-9+]{11,12})$';
    public static final String PHONE_FR_REGEX = '^([0-9+]{11,13})$';
    public static final String PHONE_CH_REGEX = '^([0-9+]{3}[0]{0,1}[0-9]{9})$';
    public static final String VAT_HU_REGEX = '^([0-9]{8}[-]{1}[1-5]{1}[-]{1}[0-9]{2})+$';
    public static final String VAT_FR_REGEX = '^(FR)?[0-9A-Z]{2}[0-9]{9}$';
    public static final String TAXID_AT_REGEX = '^([0-9]{2}[-]{1}[0-9]{7})+$';
    public static final String TAXID_CHDE_REGEX = '/^([Cc]{1}[Hh]{1}[Ee]{1}[0-9]{9})+$/';


    /*******************************************************************************
    *  Name            : returnActiveLongForm(String country)
    *  Summary         : return active Long Form
    *  CreatedDate     : 19/02/2018
    *  ModifiedDate    : -
    *  Parameters      : String country
    *  Returns         : LongForm__c
    ******************************************************************************/
    public static LongForm__c returnActiveLongForm(String country) {
        E2E_Form_General_Settings__c settings = E2E_Form_General_Settings__c.getInstance(country);

        List<LongForm__c> longFormList = [
            SELECT Active__c, Country__c, Test_Locator__c, Test_Payment__c, Title__c
            FROM LongForm__c
            WHERE Country__c = :country AND
                  Test_mode__c = :settings.Test_mode__c
            LIMIT 1
        ];

        LongForm__c longForm;
        if (! longFormList.isEmpty()) {
            longForm = longFormList.get(0);
        }
        return longForm;
    }


    /*******************************************************************************
    *  Name            : validateEmailFormat(String email)
    *  Summary         : email format validation
    *  CreatedDate     : 29/01/2018
    *  ModifiedDate    : -
    *  Parameters      : String email
    *  Returns         : Boolean isValid
    ******************************************************************************/
    public static Boolean validateEmailFormat(String email) {
        Boolean isValid = true;
        Pattern myPattern = Pattern.compile(EMAIL_REGEX);
        Matcher myMatcher = myPattern.matcher(email);
        if (! myMatcher.matches() ) isValid = false;
        return isValid;
    }


    /*******************************************************************************
    *  Name            : validatePhone(String phoneNumber, String country)
    *  Summary         : phone format validation
    *  CreatedDate     : 29/01/2018
    *  ModifiedDate    : 26/11/2018 by Ivan: was added Hungary
    *  Parameters      : String phoneNumber, String country
    *  Returns         : Boolean isValid
    ******************************************************************************/
    public static Boolean validatePhone(String phoneNumber, String country) {
        Boolean isValid = true;
        String phoneRegex = '';
        if (country == 'Germany') {
            phoneRegex = PHONE_DE_REGEX;
        } 
        else
        if (country == 'Austria') {
            phoneRegex = PHONE_AT_REGEX;
        } 
        else
        if (country == 'Netherlands') {
            phoneRegex = PHONE_NL_REGEX;
        } else
        if (country == 'Belgium-NL') {
            phoneRegex = PHONE_BENL_REGEX;
        } else
        if (country == 'Belgium-FR') {
            phoneRegex = PHONE_BEFR_REGEX;
        } else
        if (country == 'Russia') {
            phoneRegex = PHONE_RU_REGEX;
        } else
        if (country == 'Poland') {
            phoneRegex = PHONE_PL_REGEX;
        } else
        if (country == 'France') {
            phoneRegex = PHONE_FR_REGEX;
        } else 
        if (country == 'Hungary') {
            phoneRegex = PHONE_HU_REGEX;
        } 
        else 
        if (country == 'Switzerland-DE') {
            phoneRegex = PHONE_CH_REGEX;
        } else 
        if (country == 'Switzerland-FR') {
            phoneRegex = PHONE_CH_REGEX;
        }
        Pattern myPattern = Pattern.compile(phoneRegex);
        Matcher myMatcher = myPattern.matcher(phoneNumber);

        if (! myMatcher.matches() ) isValid = false;
        return isValid;
    }


    /*******************************************************************************
    *  Name            : getUserIPAddress()
    *  Summary         : get user ip address
    *  CreatedDate     : 16/05/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public static String getUserIPAddress() {
        String ipAddress = '';
        // True-Client-IP has the value when the request is coming via the caching integration.
        ipAddress = ApexPages.currentPage().getHeaders().get('True-Client-IP');

        // X-Salesforce-SIP has the value when no caching integration or via secure URL.
        if (ipAddress == '' || ipAddress == null) {
            ipAddress = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
        }// get IP address when no caching (sandbox, dev, secure urls)

        if (ipAddress == '' || ipAddress == null) {
            ipAddress = ApexPages.currentPage().getHeaders().get('X-Forwarded-For');
        } // get IP address from standard header if proxy in use
        return ipAddress;
    }


    /*******************************************************************************
    *  Name            : returnFieldType()
    *  Summary         : return field type
    *  CreatedDate     : 02/02/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : return Schema.DisplayType fieldType
    ******************************************************************************/
    public static Schema.DisplayType returnFieldType(String objectType, String fieldAPIname) {
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType objectSchema = schemaMap.get(objectType);
        Map<String, Schema.SObjectField> fieldMap = objectSchema.getDescribe().fields.getMap();
        Schema.SObjectField field = fieldMap.get(fieldAPIname);
        Schema.DisplayType fieldType = field.getDescribe().getType();

        return fieldType;
    }


    /*******************************************************************************
    *  Name            : returnErrorPage(String country, String deviceView)
    *  Summary         : set error page
    *  CreatedDate     : 15/04/2018
    *  ModifiedDate    : -
    *  Parameters      : String country, String deviceView
    *  Returns         : Map<String, LongFormPage> pagesMapErrors
    ******************************************************************************/
    public static Map<String, LongFormPage> returnErrorPage(String country, String deviceView) {
        if (! availableCountriesSet.contains(country)) country = 'Germany';
        E2E_Form_General_Settings__c settings = E2E_Form_General_Settings__c.getInstance(country);
        Map<Id, LongForm_Page__c> errorPageMap = new Map<Id, LongForm_Page__c>([
            SELECT Name, Type__c, Long_Form__c
            FROM LongForm_Page__c
            WHERE Long_Form__r.Country__c = :country AND
                (Name = 'SYSTEM ERROR' OR Name = 'VOUCHER' OR
                Name = 'HEADER' OR Name = 'FOOTER') AND
                Device_View__c = :deviceView AND
                Long_Form__r.Test_mode__c = :settings.Test_mode__c
            LIMIT 4
        ]);

        List<LongForm_Element__c> elementsList = [
            SELECT Name, Long_Form_Page__r.Title__c, Long_Form_Page__r.System_Error__c, Long_Form_Page__r.Name, Type__c,
                (SELECT Name, Active__c, Type__c, Value__c FROM Long_Form_Element_Items__r)
            FROM LongForm_Element__c
            WHERE Long_Form_Page__c IN :errorPageMap.keySet()
            LIMIT 10000
        ];

        Map<String, LongFormPage> pagesMapErrors = new Map<String, LongFormPage>();
        for (LongForm_Element__c element : elementsList) {
            if (! pagesMapErrors.containsKey(element.Long_Form_Page__r.Name) ) {
                pagesMapErrors.put(element.Long_Form_Page__r.Name, new LongFormPage());
                pagesMapErrors.get(element.Long_Form_Page__r.Name).elements = new Map<String, Map<String, LongForm_Element_Item__c>>();
            }
            if (! pagesMapErrors.get(element.Long_Form_Page__r.Name).elements.containsKey(element.Name) ) {
                pagesMapErrors.get(element.Long_Form_Page__r.Name).elements.put(element.Name, new Map<String, LongForm_Element_Item__c>());
            }
            for (LongForm_Element_Item__c elementItem : element.Long_Form_Element_Items__r) {
                pagesMapErrors.get(element.Long_Form_Page__r.Name).elements.get(element.Name).put(elementItem.Name, elementItem);
            }
        }
        return pagesMapErrors;
    }


    /*******************************************************************************
    *  Name            : generateOppWithEncodedUrl(Opportunity opportunity, String e2eKeysApiName)
    *  Summary         : based on opportunity id and step generate unique id
    *  CreatedDate     : 01/06/18
    *  ModifiedDate    : -
    *  Parameters      : Opportunity opportunity, String e2eKeysApiName
    *  Returns         : String - encoded parameter
    ******************************************************************************/
    public static String generateOppWithEncodedUrl(Opportunity opportunity, String e2eKeysApiName) {
        // update opportunity with e2e encoded id
        Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues(e2eKeysApiName).AES256_Key__c);
        // generate link to e2e last active step
        String stringToEncode = opportunity.Id + '-' + opportunity.E2E_Active_Step__c;
        String encodedStringUrl = E2EFormEncryption.getHashAlgorithAES256(key256AES, stringToEncode);

        return encodedStringUrl;
    }


    public static String generateRecordIdWithEncodedUrl(String recordId, String e2eKeysApiName) {
        // update opportunity with e2e encoded id
        Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues(e2eKeysApiName).AES256_Key__c);
        // generate link to e2e last active step
        String encodedStringUrl = E2EFormEncryption.getHashAlgorithAES256(key256AES, recordId);

        return encodedStringUrl;
    }


    /*******************************************************************************
    *  Name            : generateOppWithSepaUrl(Opportunity opportunity, String e2eKeysApiName)
    *  Summary         : based on opportunity id and generate unique sepa param
    *  CreatedDate     : 01/06/18
    *  ModifiedDate    : -
    *  Parameters      : Opportunity opportunity, String e2eKeysApiName
    *  Returns         : String - encoded sepa url
    ******************************************************************************/
    public static String generateOppWithSepaUrl(Opportunity opportunity, String e2eKeysApiName) {
        // generate link to SEPA MANDATE
        String sepaStringToEncode = 'documentName=SEPAMandate&opportunityID=' + opportunity.Id + '&pdfDownload=TRUE';
        Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues(e2eKeysApiName).AES256_Key__c);
        String sepaEncodedStringUrl = E2EFormEncryption.getHashAlgorithAES256(key256AES, sepaStringToEncode);

        return sepaEncodedStringUrl;
    }


    /*******************************************************************************
    *  Name            : generateTokenUrl(Opportunity opportunity, String e2eKeysApiName, String documentName)
    *  Summary         : based on opportunity id generate unique url param
    *  CreatedDate     : 06/12/18
    *  ModifiedDate    : -
    *  Parameters      : Opportunity opportunity, String e2eKeysApiName
    *  Returns         : String - encoded url param
    ******************************************************************************/
    public static String generateTokenUrl(Opportunity opportunity, String e2eKeysApiName, String documentName) {
        // generate link to document
        String stringToEncode = 'documentName=' + documentName + '&opportunityID=' + opportunity.Id + '&pdfDownload=TRUE';
        Blob key256AES = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues(e2eKeysApiName).AES256_Key__c);
        String encodedStringUrl = E2EFormEncryption.getHashAlgorithAES256(key256AES, stringToEncode);

        return encodedStringUrl;
    }


    /*******************************************************************************
    *  Name            : returnMenuService(String countryName)
    *  Summary         : get menu service
    *  CreatedDate     : 08/03/2018
    *  ModifiedDate    : 02/03/2019 by Ivan: was added Austria
    *  Parameters      : String countryName
    *  Returns         : LFMenu menuService
    ******************************************************************************/
    public static LFMenu returnMenuService(String countryName) {
        LFMenu currentMenuService;
        if (countryName == 'Germany') {
            currentMenuService = new LFMenuServiceDE();
        } 
        else if (countryName == 'Austria') {
            currentMenuService = new LFMenuServiceAT();
        } 
        else if (countryName == 'Netherlands') {
            currentMenuService = new LFMenuServiceNL();
        } else if (countryName == 'Belgium-NL') {
            currentMenuService = new LFMenuServiceBENL();
        } else if (countryName == 'Belgium-FR') {
            currentMenuService = new LFMenuServiceBEFR();
        } else if (countryName == 'Poland') {
            currentMenuService = new LFMenuServicePL();
        } else if (countryName == 'France') {
           currentMenuService = new LFMenuServiceFR();
        } else if (countryName == 'Hungary') {
            currentMenuService = new LFMenuServiceHU();
        } 
        else if (countryName == 'Switzerland-DE') {
            currentMenuService = new LFMenuServiceCHDE();
        } else if (countryName == 'Switzerland-FR') {
            currentMenuService = new LFMenuServiceCHFR();
        }
        return currentMenuService;
    }


    /*******************************************************************************
    *  Name            : returnContactDetailsService(String countryName)
    *  Summary         : get Contact Details Service
    *  CreatedDate     : 07/06/2018
    *  ModifiedDate    : 02/03/2019 by Ivan: was added Austria
    *  Parameters      : String countryName
    *  Returns         : LFContactDetails conDetailsService
    ******************************************************************************/
    public static LFContactDetails returnContactDetailsService(String countryName) {
        LFContactDetails conDetailsService;
        if (countryName == 'Germany') {
            conDetailsService = new LFContactDetailsServiceDE();
        } 
        else if (countryName == 'Austria') {
            conDetailsService = new LFContactDetailsServiceAT();
        } 
        else if (countryName == 'Netherlands') {
            conDetailsService = new LFContactDetailsServiceNL();
        } else if (countryName == 'Belgium-NL') {
            conDetailsService = new LFContactDetailsServiceBENL();
        } else if (countryName == 'Belgium-FR') {
            conDetailsService = new LFContactDetailsServiceBEFR();
        } else if (countryName == 'Poland') {
            conDetailsService = new LFContactDetailsServicePL();
        } else if (countryName == 'France') {
           conDetailsService = new LFContactDetailsServiceFR();
        } else if (countryName == 'Hungary') {
            conDetailsService = new LFContactDetailsServiceHU();
        } 
        else if (countryName == 'Switzerland-DE') {
            conDetailsService = new LFContactDetailsServiceCHDE();
        } else if (countryName == 'Switzerland-FR') {
            conDetailsService = new LFContactDetailsServiceCHFR();
        }
        return conDetailsService;
    }


    /*******************************************************************************
    *  Name            : returnCreditScoringService(String countryName)
    *  Summary         : get credit scoring service
    *  CreatedDate     : 12/06/2018
    *  ModifiedDate    : 02/03/2019 by Ivan: was added Austria
    *  Parameters      : String countryName
    *  Returns         : LFCreditScoring currentCreditScoringService
    ******************************************************************************/
    public static LFCreditScoring returnCreditScoringService(String countryName) {
        LFCreditScoring currentCreditScoringService;
        if (countryName == 'Germany') {
            currentCreditScoringService = new LFCreditScoringServiceDE();
        } 
        else if (countryName == 'Austria') {
            currentCreditScoringService = new LFCreditScoringServiceAT();
        } 
        else if (countryName == 'Netherlands') {
            currentCreditScoringService = new LFCreditScoringServiceNL();
        } else if (countryName == 'Belgium-NL') {
            currentCreditScoringService = new LFCreditScoringServiceBENL();
        } else if (countryName == 'Belgium-FR') {
            currentCreditScoringService = new LFCreditScoringServiceBEFR();
        } else if (countryName == 'Poland') {
            currentCreditScoringService = new LFCreditScoringServicePL();
        } else if (countryName == 'France') {
           currentCreditScoringService = new LFCreditScoringServiceFR();
        } else if (countryName == 'Hungary') {
            currentCreditScoringService = new LFCreditScoringServiceHU();
        } 
        else if (countryName == 'Switzerland-DE') {
            currentCreditScoringService = new LFCreditScoringServiceCHDE();
        } else if (countryName == 'Switzerland-FR') {
            currentCreditScoringService = new LFCreditScoringServiceCHFR();
        }
        return currentCreditScoringService;
    }


    /*******************************************************************************
    *  Name            : returnCardsConfigService(String countryName)
    *  Summary         : return cards config service
    *  CreatedDate     : 06/03/2018
    *  ModifiedDate    : 02/03/2019 by Ivan: was added Austria
    *  Parameters      : -
    *  Returns         : LFCardsConfig currentCardsConfigService
    ******************************************************************************/
    public static LFCardsConfig returnCardsConfigService(String countryName) {
        LFCardsConfig currentCardsConfigService;
        if (countryName == 'Germany') {
            currentCardsConfigService = new LFCardsConfigServiceDE();
        } 
        else if (countryName == 'Austria') {
            currentCardsConfigService = new LFCardsConfigServiceAT();
        } 
        else if (countryName == 'Netherlands') {
            currentCardsConfigService = new LFCardsConfigServiceNL();
        } else if (countryName == 'Belgium-NL') {
            currentCardsConfigService = new LFCardsConfigServiceBENL();
        } else if (countryName == 'Belgium-FR') {
            currentCardsConfigService = new LFCardsConfigServiceBEFR();
        } else if (countryName == 'Poland') {
            currentCardsConfigService = new LFCardsConfigServicePL();
        } else if (countryName == 'France') {
           currentCardsConfigService = new LFCardsConfigServiceFR();
        } else if (countryName == 'Hungary') {
            currentCardsConfigService = new LFCardsConfigServiceHU();
        } 
        else if (countryName == 'Switzerland-DE') {
            currentCardsConfigService = new LFCardsConfigServiceCHDE();
        } else if (countryName == 'Switzerland-FR') {
            currentCardsConfigService = new LFCardsConfigServiceCHFR();
        }
        return currentCardsConfigService;
    }


    /*******************************************************************************
    *  Name            : returnAdditionalService(String countryName)
    *  Summary         : Return Additional service
    *  CreatedDate     : 30/01/2018
    *  ModifiedDate    : 02/03/2019 by Ivan: was added Austria
    *  Parameters      : String countryName
    *  Returns         : LFAdditional
    ******************************************************************************/
    public static LFAdditional returnAdditionalService(String countryName) {
        LFAdditional currentAdditionalService;
        if (countryName == 'Germany') {
            currentAdditionalService = new LFAdditionalServiceDE();
        } 
        else if (countryName == 'Austria') {
            currentAdditionalService = new LFAdditionalServiceAT();
        } 
        else if (countryName == 'Netherlands') {
            currentAdditionalService = new LFAdditionalServiceNL();
        } else if (countryName == 'Belgium-NL') {
            currentAdditionalService = new LFAdditionalServiceBENL();
        } else if (countryName == 'Belgium-FR') {
            currentAdditionalService = new LFAdditionalServiceBEFR();
        } else if (countryName == 'Poland') {
            currentAdditionalService = new LFAdditionalServicePL();
        } else if (countryName == 'France') {
           currentAdditionalService = new LFAdditionalServiceFR();
        } else if (countryName == 'Hungary') {
            currentAdditionalService = new LFAdditionalServiceHU();
        } 
        else if (countryName == 'Switzerland-DE') {
            currentAdditionalService = new LFAdditionalServiceCHDE();
        } else if (countryName == 'Switzerland-FR') {
            currentAdditionalService = new LFAdditionalServiceCHFR();
        }
        return currentAdditionalService;
    }


    /*******************************************************************************
    *  Name            : returnDocumentsService(String countryName)
    *  Summary         : Return Documents Service
    *  CreatedDate     : 15/10/2018
    *  ModifiedDate    : 26/11/2018 by Ivan: was added Hungary
    *  Parameters      : String countryName
    *  Returns         : LFDocuments
    ******************************************************************************/
    public static LFDocuments returnDocumentsService(String countryName) {
        LFDocuments currentDocumentsService;
        if (countryName == 'Poland') {
            currentDocumentsService = new LFDocumentsServicePL();
        }
        else if (countryName == 'Hungary') {
            currentDocumentsService = new LFDocumentsServiceHU();
        }
        return currentDocumentsService;
    }


    /*******************************************************************************
    *  Name            : returnPaymentOptionsService(String countryName)
    *  Summary         : Return Payment Options service
    *  CreatedDate     : 28/03/2018
    *  ModifiedDate    : 02/03/2019 by Ivan: was added Austria
    *  Parameters      : String countryName
    *  Returns         : LFPaymentOptions
    ******************************************************************************/
    public static LFPaymentOptions returnPaymentOptionsService(String countryName) {
        LFPaymentOptions currentPaymentOptionsService;
        if (countryName == 'Germany') {
            currentPaymentOptionsService = new LFPaymentOptionsServiceDE();
        } 
        else if (countryName == 'Austria') {
            currentPaymentOptionsService = new LFPaymentOptionsServiceAT();
        } 
        else if (countryName == 'Netherlands') {
            currentPaymentOptionsService = new LFPaymentOptionsServiceNL();
        } else if (countryName == 'Belgium-NL') {
            currentPaymentOptionsService = new LFPaymentOptionsServiceBENL();
        } else if (countryName == 'Belgium-FR') {
            currentPaymentOptionsService = new LFPaymentOptionsServiceBEFR();
        } else if (countryName == 'Poland') {
            currentPaymentOptionsService = new LFPaymentOptionsServicePL();
        } else if (countryName == 'France') {
           currentPaymentOptionsService = new LFPaymentOptionsServiceFR();
        } else if (countryName == 'Hungary') {
            currentPaymentOptionsService = new LFPaymentOptionsServiceHU();
        } 
        else if (countryName == 'Switzerland-DE') {
            currentPaymentOptionsService = new LFPaymentOptionsServiceCHDE();
        } else if (countryName == 'Switzerland-FR') {
            currentPaymentOptionsService = new LFPaymentOptionsServiceCHFR();
        }
        return currentPaymentOptionsService;
    }


    /*******************************************************************************
    *  Name            : returnDocusignService(String countryName)
    *  Summary         : Return docusign service
    *  CreatedDate     : 05/11/2018
    *  ModifiedDate    : 26/11/2018 by Ivan: was added Hungary
    *  Parameters      : String countryName
    *  Returns         : LFDocusign
    ******************************************************************************/
    public static LFDocusign returnDocusignService(String countryName) {
        LFDocusign currentDocusignService;
        if (countryName == 'Poland') {
            currentDocusignService = new LFDocuSignServicePL();
        }
        else if (countryName == 'Hungary') {
            currentDocusignService = new LFDocuSignServiceHU();
        }
        return currentDocusignService;
    }


    /*******************************************************************************
    *  Name            : findAndProcessDuplicateLead()
    *  Summary         : Find duplicate Lead
    *  CreatedDate     : 11/10/2018
    *  ModifiedDate    : -
    *  Parameters      :
    *  Returns         : void
    ******************************************************************************/
    public static void findAndProcessDuplicateLead(String firstName, String lastName, String email, String phone,
                                                   String country, String recordTypeName) {
        if (System.isFuture() || System.isBatch()) {
            System.enqueueJob(new DuplicateLeadQueueuable(firstName, lastName, email, phone, country, recordTypeName));
        } else {
            findAndProcessDuplicateLeadFuture(firstName, lastName, email, phone, country, recordTypeName);
        }
    }


    /*******************************************************************************
    *  Name            : findAndProcessDuplicateLead()
    *  Summary         : Find duplicate Lead
    *  CreatedDate     : 11/10/2018
    *  ModifiedDate    : -
    *  Parameters      :
    *  Returns         : void
    ******************************************************************************/
    @future
    public static void findAndProcessDuplicateLeadFuture(String firstName, String lastName, String email, String phone,
                                                         String country, String recordTypeName) {
        try {
            String emailDomain = '%' + email.substringAfter('@');

            List<Lead> duplicateLeadsList = [
                    SELECT Status, FirstName, LastName, Company, OwnerId,
                           Owner.FirstName, Owner.LastName, Owner.Email
                    FROM Lead
                    WHERE (Email = :email OR Phone = :phone OR
                           (FirstName = :firstName AND LastName = :lastName AND Email LIKE :emailDomain)) AND
                          Country = :country AND
                          RecordType.Name = :recordTypeName AND
                          Status != 'Disqualified' AND
                          IsConverted = FALSE
                    ORDER BY CreatedDate DESC
                    LIMIT 1];

            if ( ! duplicateLeadsList.isEmpty() ) {
                String oldStatus = duplicateLeadsList.get(0).Status;
                duplicateLeadsList.get(0).Status = 'Disqualified';
                duplicateLeadsList.get(0).Quali_Status__c = 'Switched to E2E';
                Database.SaveResult sRdupLead = Database.update(duplicateLeadsList.get(0), false);
                if (! sRdupLead.isSuccess() ) {
                    String error = '';
                    for(Database.Error err : sRdupLead.getErrors()) {
                        error += err.getMessage();
                    }
                    throw new LongFormException(error);
                }

                String ownerId = duplicateLeadsList.get(0).OwnerId;
                if (ownerId.substring(0,3) == '00G') {
                    // WHAT TO DO WITH QUEUE?
                } else {
                    String body = 'Dear , ' + duplicateLeadsList.get(0).Owner.FirstName + ' ' + duplicateLeadsList.get(0).Owner.LastName + '<br/>' +
                                  'Status of your current lead ' + duplicateLeadsList.get(0).FirstName + ' ' + duplicateLeadsList.get(0).LastName + ' / ' +
                                  duplicateLeadsList.get(0).Company + 'was changed from ' + oldStatus + ' to ' + duplicateLeadsList.get(0).Status +
                                  ' because your customer started e2e Application and tries to order cards online.<br/>' +
                                  '<a href="https://eu9.salesforce.com/' + duplicateLeadsList.get(0).Id + '" target="_blank">Current Lead</a><br/>' +
                                  'No actions are required at the moment.<br/>' +
                                  'Thanks and best regards.';
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    message.setSubject('E2E Notification');
                    message.setHtmlBody(body);
                    message.setToAddresses(new List<String>{duplicateLeadsList.get(0).Owner.Email});
                    Messaging.sendEmail(new List<Messaging.Email>{message});
                }
            }
        } catch (Exception e) {
            ExceptionLogger.sendException('LongFormGlobalUtils.findAndProcessDuplicateLeadFuture', String.valueOf(e.getStackTraceString()));
        }
    }


    /*****************************************************************************
    *  Name            : doDecryptParams(String encryptedParams)
    *  Summary         : do decrypt url params
    *  CreatedDate     : 29/10/2018
    *  ModifiedDate    : by Artem Voitik
    *  Parameters      : String encryptedParams, String e2eFormName
    *  Returns         : String - Opportunity ID
    ******************************************************************************/
    public static String doDecryptParams(String encryptedParams, String e2eFormName) {
        encryptedParams = encryptedParams.replaceAll('(\\s|%2B)', '+');
        if (E2EKeysAPI__c.getValues(e2eFormName) == null ) throw new LongFormException('The link is corrupted.');
        Blob key = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues(e2eFormName).AES256_Key__c);
        Blob dest = EncodingUtil.base64Decode(encryptedParams);
        Blob decrypted = Crypto.decryptWithManagedIv('AES256', key, dest);
        String decryptedParams = decrypted.toString();
        if (decryptedParams != null) {
            String opptyId = decryptedParams.substringBefore('-');
            return opptyId;
        } else {
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : validateDateOfBirth()
    *  Summary         : Validate date of birth
    *  CreatedDate     : 15/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Boolean
    ******************************************************************************/
    public static Boolean validateDateOfBirth(String dateOfBirth) {
        Pattern lettersPattern = Pattern.compile(DATE_OF_BIRTH_REGEX);
        Matcher lettersMatcher = lettersPattern.matcher(dateOfBirth);
        if ( ! lettersMatcher.matches() || dateOfBirth == '' || dateOfBirth == null) {
            return false;
        }
        return true;
    }


    /*******************************************************************************
    *  Name            : setTimeExecutionOfApexCall
    *  Summary         : set time execution of apex call    
    *  CreatedDate     : 21/01/2019
    *  ModifiedDate    : -
    *  Parameters      : Datetime startApexCall, Datetime endApexCall, String country, String device
    *  Returns         : void
    ******************************************************************************/
    @future
    public static void setTimeExecutionOfApexCall(Datetime startApexCall, Datetime endApexCall, String opptyId, String fromStep, String toStep, String description, String country, String device) {
        if (opptyId != null) {
            Long startApexCallLong = startApexCall.getTime();
            Long endApexCallLong = endApexCall.getTime();
            Long timeExecution = endApexCallLong - startApexCallLong;
            Health_Check__c healthCheck = new Health_Check__c(
                Name = 'E2E Load Time Tracking',
                Opportunity__c = opptyId,
                Start_Action__c = startApexCall,
                From_Step__c = fromStep,
                To_Step__c = toStep,
                Time_execution__c = timeExecution,
                Description__c = description,
                Country__c = country,
                Device__c = device
            );
            insert healthCheck;
        }
    }


    /*******************************************************************************
    *  Name            : returnActiveSubstep(Opportunity oppty)
    *  Summary         : return active substep    
    *  CreatedDate     : 25/01/2019
    *  ModifiedDate    : -
    *  Parameters      : Opportunity oppty
    *  Returns         : String activeSubstep
    ******************************************************************************/
    public static String returnActiveSubstep(Opportunity oppty) {
        String activeSubstep;
        if (stopProcessOnReturnToForm.contains(oppty.E2E_Errors__c)) {
            activeSubstep = oppty.E2E_Errors__c;
        } else {
            activeSubstep = oppty.E2E_Active_Substep__c;
        }
        return activeSubstep;
    }


    /*******************************************************************************
    *  Name            : returnSalutationDependLocation(String country, String salutation)
    *  Summary         : return salutation depend location    
    *  CreatedDate     : 07/03/2019
    *  ModifiedDate    : -
    *  Parameters      : String country, String salutation
    *  Returns         : String - valid salutation depend location
    ******************************************************************************/
    public static String returnSalutationDependLocation(String country, String salutation) {
        if (salutationDependLocationMap.containsKey(country) && salutationDependLocationMap.get(country).containsKey(salutation)) {
            return salutationDependLocationMap.get(country).get(salutation) + ' ';
        }
        return '';
    }


    /*******************************************************************************
    *  Name            : isSandbox()
    *  Summary         : Returns true if sandbox     
    *  CreatedDate     : 19/03/2019
    *  ModifiedDate    : 
    *  Parameters      : 
    *  Returns         : Boolean
    ******************************************************************************/
    public static Boolean isSandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }    


    public static Set<String> mobileDevicesSet = new Set<String>{
        'Android',
        'webOS',
        'iPhone',
        'iPad',
        'iPod',
        'BlackBerry',
        'IEMobile',
        'Opera Mini'
    };

    public static Set<String> availableCountriesSet = new Set<String>{
        'Germany',
        'Austria',
        'Netherlands',
        'Belgium-NL',
        'Belgium-FR',
        'France',
        'Poland',
        'Hungary',
        'Switzerland-DE',
        'Switzerland-FR'
    };

    private static Map<String, Map<String, String>> salutationDependLocationMap = new Map<String, Map<String, String>> {
        'Germany' => new Map<String, String> { 'Herr' => 'Sehr geehrter', 'Frau' => 'Sehr geehrte'},
        'Austria' => new Map<String, String> { 'Herr' => 'Sehr geehrter', 'Frau' => 'Sehr geehrte'},
        'Switzerland-DE' => new Map<String, String> { 'Herr' => 'Sehr geehrter', 'Frau' => 'Sehr geehrte'},
        'Netherlands' => new Map<String, String> { 'Herr' => 'Geachte', 'Frau' => 'Geachte'},
        'Belgium-NL' => new Map<String, String> { 'Herr' => 'Geachte', 'Frau' => 'Geachte'},
        'Belgium-FR' => new Map<String, String> { 'Herr' => 'Cher', 'Frau' => 'Chère'},
        'France' => new Map<String, String> { 'Herr' => 'Cher', 'Frau' => 'Chère'},
        'Switzerland-FR' => new Map<String, String> { 'Herr' => 'Cher', 'Frau' => 'Chère'}
    };

    public static Set<String> stopProcessOnReturnToForm = new Set<String>{
        'Already a customer'
    };

    public static Map<String, String> countryParamToCountryMap = new Map<String, String>{
        'chde' => 'Switzerland-DE',
        'chfr' => 'Switzerland-FR',
        'Germany' => 'Germany',
        'at' => 'Austria'
    };
    public static Map<String, String> countryToCountryParamMap = new Map<String, String>{
        'Switzerland-DE' => 'chde',
        'Switzerland-FR' => 'chfr',
        'Germany' => 'Germany',
        'Austria' => 'at'
    };

    public static Map<String, String> countryParamToCustomSettingsMap = new Map<String, String>{
        'chde' => 'E2EFormCHDE',
        'chfr' => 'E2EFormCHFR',
        'Germany' => 'E2EForm',
        'at' => 'E2EFormAT'
    };
}