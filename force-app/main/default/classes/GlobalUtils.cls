global class GlobalUtils {

    public enum FleetcorCountries {
        Germany,
        Austria,
        Belgium_FR,
        Belgium_NL,
        CzechRepublic,
        France,
        Hungary,
        Lithuania,
        Luxembourg,
        Netherlands,
        Poland,
        Russia,
        Slovakia,
        Switzerland_DE,
        Switzerland_FR,
        Switzerland_IT
    }

    private static Map<String, String> fleetcorCountriesMap = new Map<String, String>{
            'Germany' => 'Germany',
            'Austria' => 'Austria',
            'Belgium_FR' => 'Belgium-FR',
            'Belgium_NL' => 'Belgium-NL',
            'CzechRepublic' => 'Czech Republic',
            'France' => 'France',
            'Hungary' => 'Hungary',
            'Lithuania' => 'Lithuania',
            'Luxembourg' => 'Luxembourg',
            'Netherlands' => 'Netherlands',
            'Poland' => 'Poland',
            'Russia' => 'Russia',
            'Slovakia' => 'Slovakia',
            'Switzerland_DE' => 'Switzerland-DE',
            'Switzerland_FR' => 'Switzerland-FR',
            'Switzerland_IT' => 'Switzerland-IT'
    };

    public static String getFleetcorCountries(String s) {
        return fleetcorCountriesMap.get(s);
    }

    public static String returnRecordTypeId(String sobjectName, String recordTypeName) {
        if (Schema.getGlobalDescribe().get(sobjectName).getDescribe().getRecordTypeInfosByName().containsKey(recordTypeName)) {
            return Schema.getGlobalDescribe().get(sobjectName).getDescribe().getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        }

        return null;
    }

    public static String getRecordTypeId(String sobjectName, String recordTypeName) {
        List<RecordType> recordTypeList = ([
                SELECT Id
                FROM RecordType
                WHERE SobjectType = :sobjectName
                AND DeveloperName = :recordTypeName
                LIMIT 1
        ]);

        if (recordTypeList == null || recordTypeList.isEmpty()) {
            throw new E2EFormRuException('GLOBAL UTILS getRecordTypeId(): ' + sobjectName + ' RecordType list is empty.');
        }

        return recordTypeList.get(0).Id;
    }


    /* Enum for getting Emarsys Accounts */
    public enum EmarsysAccounts {
        AccountEuro,
        AccountRus
    }

    private static Map<String, String> emarsysAccountsMap = new Map<String, String>{
            'AccountEuro' => 'PPR_EU',
            'AccountRus' => 'PPR'
    };

    public static String getEmarsysAccount(String s) {
        return emarsysAccountsMap.get(s);
    }

    /* Enum for getting Emarsys reaction types*/
    public enum EmarsysReactionTypesRus {
        DefaultReaction,
        Open,
        Click
    }

    private static Map<String, String> emarsysReactionTypesRusMap = new Map<String, String>{
            'DefaultReaction' => 'Reaction Open or Click',
            'Open' => 'Opened',
            'Click' => 'Clicked'
    };

    public static String getEmarsysReactionType(String s) {
        return emarsysReactionTypesRusMap.get(s);
    }

    /* DOMAIN FUNCTIONS */
    /* Blank String field if the value is null */
    public static String blankStringIfNull(String var) {
        return (var != null) ? var : '';
    }

    /* Blank Integer field if the value is null */
    public static Integer blankIntegerIfNull(Integer var) {
        return (var != null) ? var : 0;
    }

    /* Blank Integer field if the value is null */
    public static Integer blankIntegerIfNull(String var) {
        return (var != null) ? Integer.valueOf(var) : 0;
    }

    /* Blank Boolean field if the value is null */
    public static Boolean blankBooleanIfNull(Boolean var) {
        return (var != null) ? var : false;
    }

    /* Blank Decimal field if the value is null */
    public static Decimal blankDecimalIfNull(Decimal var) {
        return (var != null) ? var : 0.0;
    }

    /*******************************************************************************
    *  Name            : getPicklistValuesTranslationsList()
    *  Summary         : return the list of translation of the Field picklist values
    *  CreatedDate     : 06.12.2017
    *  Parameters      : Schema.DescribeFieldResult fieldResult - filed description
    *  Returns         : List<Schema.PicklistEntry>
    ******************************************************************************/
    public static List<Schema.PicklistEntry> getPicklistValuesTranslationsList(Schema.DescribeFieldResult fieldResult){
        List<Schema.PicklistEntry> picklist = fieldResult.getPicklistValues();
        return picklist;
    }

    /*******************************************************************************
    *  Name            : getPicklistValueTranslation()
    *  Summary         : return one translation of the picklist value (if translation wasn't found - return current value)
    *  CreatedDate     : 06.12.2017
    *  Parameters      : Schema.DescribeFieldResult fieldResult - filed description
    *                    String currentValue - current value of the picklist
    *  Returns         : Schema.DescribeFieldResult
    ******************************************************************************/
    public static String getPicklistValueTranslation(Schema.DescribeFieldResult fieldResult, String currentValue){
        String finalLabel = '';
        if(currentValue != null){
            finalLabel = currentValue;
        }
        List<Schema.PicklistEntry> picklist = fieldResult.getPicklistValues();
        if (picklist.size() > 0 && (currentValue != null)) {
            for (Schema.PicklistEntry entry : picklist) {
                if (entry.getValue().contains(currentValue)) {
                    finalLabel = entry.getLabel();
                    break;
                }
            }
        }
        return finalLabel;
    }

    /*******************************************************************************
     *  Name            : getAllSubRoleIds()
     *  Summary         : return set of subordinated roles by set of parent role ids
     *  CreatedDate     : 21/1/2019
     *  Parameters      : Set<Id> roleIds - parent role Ids
     *  Returns         : Set<Id>
     ******************************************************************************/
    public static Set<Id> getAllSubRoleIds(Set<Id> roleIds) {

        Set<Id> currentRoleIds = new Set<Id>();
        for(UserRole userRole : ([
                SELECT Id
                FROM UserRole
                WHERE ParentRoleId IN :roleIds
                AND ParentRoleId != NULL
        ])) {
            currentRoleIds.add(userRole.Id);
        }
        if (currentRoleIds.size() > 0) {
            currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));
        }

        return currentRoleIds;
    }

    /*******************************************************************************

    /*******************************************************************************
     *  Name            : getSubordinateRoles()
     *  Summary         : return list of subordinated roles by roleId
     *  CreatedDate     : 15/1/2018
     *  Parameters      : Id roleId - role Id
     *  Returns         : Set<Id>
     ******************************************************************************/
    public static Set<Id> getSubordinateRoles(Id roleId) {
        Map<Id, Set<Id>> parentAndChildren = new Map<Id, set<Id>>();
        Set<Id> children;
        for (UserRole ur : [select Id, ParentRoleId from UserRole]) {
            children = parentAndChildren.containsKey(ur.ParentRoleId) ? parentAndChildren.get(ur.ParentRoleId) : new set<Id>();
            children.add(ur.Id);
            parentAndChildren.put(ur.ParentRoleId, children);
        }
        return getSubordinateRoles(roleId, parentAndChildren);
    }

    /*******************************************************************************
      *  Name            : getSubordinateRoles()
      *  Summary         : use in getSubordinateRoles(Id roleId) for return list of subordinated roles by roleId
      *  CreatedDate     : 15/1/2018
      *  Parameters      : Id roleId - role Id, map<Id, set<Id>> parentAndChildren - map relo and subordinate
      *  Returns         : Set<Id>
      ******************************************************************************/
    private static Set<Id> getSubordinateRoles(Id roleId, map<Id, set<Id>> parentAndChildren) {
        Set<Id> subordinateRoles = new Set<Id>();
        Set<Id> remainingSubordinateRoles = new Set<Id>();
        if (parentAndChildren.containsKey(roleId)) {
            subordinateRoles.addAll(parentAndChildren.get(roleId));
            for (Id subRoleId : subordinateRoles) {
                remainingSubordinateRoles.addAll(getSubordinateRoles(subRoleId, parentAndChildren));
            }
        }
        subordinateRoles.addAll(remainingSubordinateRoles);
        return subordinateRoles;
    }

    //********** Work.com  *******//
    /*******************************************************************************
    *  Name            : findFeedItemByWorkThanks()
    *  Summary         : find by WorkThanks Id related FeedItem
    *  CreatedDate     : 25/12/2017
    *  Parameters      : workThanksId - WorkThanks Id, feedItems - FeedItem list
    *  Returns         : String
    ******************************************************************************/
    public static FeedItem findFeedItemByWorkThanks(Id workThanksId, List<FeedItem> feedItems) {
        for (FeedItem item : feedItems) {
            if (item.RelatedRecordId == workThanksId) {
                return item;
            }
        }
        return null;
    }

    //***************** E2E Russia ***************//

    public enum PPRMiddleware {
        url,
        token
    }

    public static String getPPRMiddleware(String s) {
        if (s == PPRMiddleware.url.name()) {
            if (UserInfo.getOrganizationId() == '00D20000000oB2EEAU') {
                return E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu').Middleware_Url__c;
            } else {
                return E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu').Test_Middleware_Url__c;
            }
        } else if (s == PPRMiddleware.token.name())  {
            return E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu').Middleware_Token__c;
        } else {
            return '';
        }
    }

    public enum E2ESource {
        PetrolPlus,
        Gaz,
        Shell
    }

    public enum E2EProduct {
        PetrolPlus_Rover,
        PetrolPlus_Gaz,
        Shell,
        Partner_Rover
    }

    private static Map<String, String> e2eProductMap = new Map<String, String>{
            'PetrolPlus_Rover' => 'Вездеход Online',
            'PetrolPlus_Gaz' => 'ГАЗПРОМ',
            'Shell' => 'Шелл',
            'Partner_Rover' => 'Вездеход Online'
    };

    public static String getE2EProduct(String s) {
        return e2eProductMap.get(s);
    }

    public enum E2ERuSteps {
        ContactDetails,
        CompanyInformation,
        Order,
        SummaryOrder,
        LegalDetails,
        PaymentDetails,
        Congratulations,
        ErrorMessage
    }

    private static Map<String, String> e2eStepMap = new Map<String, String>{
            'ContactDetails' => 'Контактные Данные',
            'CompanyInformation' => 'Данные о Компании',
            'Order' => 'Заказ',
            'SummaryOrder' => 'Информация о заказе',
            'LegalDetails' => 'Юридические реквизиты',
            'PaymentDetails' => 'Платежные реквизиты',
            'Congratulations' => 'Спасибо',
            'ErrorMessage' => 'Ошибка'
    };

    public static String getE2ESteps(String s) {
        return e2eStepMap.get(s);
    }

    public enum E2ERuErrorSteps {
        Inbound,
        RefuseToCooperate,
        IsAClient,
        SystemError
    }

    public enum E2ERuActiveModalWindows {
        PrintAgreement,
        ShowPreAgreement,
        PersonalInfoPolicy,
        SalesPromotion,
        WarningStepBankDetails
    }

    public enum E2ERuProcessStatus {
        ContactDetails,
        SFDeduplication1,
        SFDeduplication2,
        CompanyDetails,
        GetSparkData,
        CheckedInBlackList,
        ScoringPassed,
        SFDeduplication3,
        SendCrmRequest,
        CardOrderDetails,
        LegalDetails,
        PaymentDetails,
        GetReport,
        CreateContInTransit,
        SendMzkRequest,
        SaveReport
    }

    private static Map<String, List<String>> e2eRuStepsMap = new Map<String, List<String>>{
            E2ERuSteps.ContactDetails.name() => new List<String>{
                    'CONTACT DETAILS'
            },
            E2ERuSteps.CompanyInformation.name() => new List<String>{
                    'COMPANY INFORMATION'
            },
            E2ERuSteps.LegalDetails.name() => new List<String>{
                    'LEGAL DETAILS'
            },
            E2ERuSteps.PaymentDetails.name() => new List<String>{
                    'PAYMENT DETAILS'
            },
            E2ERuSteps.Order.name() => new List<String>{
                    'ORDER'
            },
            E2ERuSteps.SummaryOrder.name() => new List<String>{
                    'ORDER'
            },
            E2ERuSteps.Congratulations.name() => new List<String>{
                    'CONGRATULATIONS'
            },
            E2ERuSteps.ErrorMessage.name() => new List<String>{
                    'SYSTEM ERROR'
            }
    };

    public static List<String> getE2ERuStep(String s) {
        return e2eRuStepsMap.get(s);
    }

    public enum DeviceType {
        Desktop,
        Mobile
    }

    public static Set<String> fieldTypes = new Set<String>{
            'Text Field',
            'Picklist Field',
            'Radio-button Field',
            'Checkbox Field',
            'Slider Field',
            'Text Block',
            'URL',
            'Button'
    };

    public enum DeduplicationStatus {   // Статусы дедубликации
        E2EProcess,                     // Есть дубль по Account (ИНН)
        E2EWithOutUpdate,               // Не дубля по Account (ИНН)
        Inbound,                        // Перевод в Inbound
        Service,                        // Перевод в Сервис
        KO                              // Перевод в КО
    }

    /*******************************************************************************
    *  Name            : addBusinessDays(Date startDate, integer businessDaysToAdd)
    *  Summary         : add business days without weekends to date
    *  CreatedDate     : 06/09/2018
    *  Parameters      : Date startDate - date for start, Integer businessDaysToAdd - how many days should add
    *  Returns         : Date
    ******************************************************************************/
    public static Date addBusinessDays(Date startDate, integer businessDaysToAdd) {

        //Add or decrease in BusinessDaysToAdd days
        Date finalDate = startDate;
        Integer direction = businessDaysToAdd < 0 ? -1 : 1;
        while (businessDaysToAdd != 0) {
            finalDate = finalDate.addDays(direction);
            if (!isWeekendDay(finalDate)) {
                businessDaysToAdd -= direction;
            }
        }
        return finalDate;
    }

    public static Boolean IsWeekendDay(Date dateParam) {
        Boolean result = false;
        System.debug('dateParam = ' + dateParam);
        //Recover the day of the week
        Date startOfWeek = dateParam.toStartOfWeek();
        System.debug('startOfWeek = ' + startOfWeek);
        Integer dayOfWeek = dateParam.day() - startOfWeek.day();
        System.debug('dayOfWeek = ' + dayOfWeek);
        result = dayOfWeek == 0 || dayOfWeek == 6 ? true : false;
        System.debug('result = ' + result);
        return result;
    }

    public enum E2ERuGroupsNotification {
        Inbound,
        Service,
        CallCenter,
        MainGroup,
        None
    }

    public static Set<String> publicEmailDomain = new Set<String>{
        'gmail.com',
        'yandex.ru',
        'mail.ru',
        'inbox.ru',
        'rambler.ru',
        'hotmail.ru',
        'nm.ru',
        'hotbox.ru',
        'yahoo.com',
        'bk.ru',
        'list.ru',
        'ngs.ru'
    };

    public static List<String> reportIdsSequence = new List<String>{
        '10007',
        '10002',
        '10003',
        '10004',
        '10005',
        '10006',
        '10037',
        '10038',
        // Special condition
        '10008',
        '10009',
        '10010',
        '10034',
        '10039',
        // ДС
        '10030',
        '10031',
        '10036',
        '10028',
        '10032'
    };

    public static List<String> unitList = new List<String>{
        '',
        'одна',
        'две',
        'три',
        'четыре',
        'пять',
        'шесть',
        'семь',
        'восемь',
        'девять',
        'десять',
        'одинадцать',
        'двенадцать',
        'тринадцать',
        'четырнадцать',
        'пятнадцать',
        'шестнадцать',
        'семнадцать',
        'восемнадцать',
        'девятнадцать'
     };

    public static List<String> decimalList = new List<String>{
        '',
        '',
        'двадцать',
        'тридцать',
        'сорок',
        'пятьдесят',
        'шестьдесят',
        'семьдесят',
        'восемьдесят',
        'девяносто'
    };

    public static List<String> hundredthsList = new List<String>{
        '',
        'сто',
        'двести',
        'триста',
        'четыреста',
        'пятьсот',
        'шестьсот',
        'семьсот',
        'восемьсот',
        'девятьсот'
    };

    /*******************************************************************************
    *  Name            : convertNumberToWord(Integer inputNumber)
    *  Summary         : convert number to word, only in ranger 1 to 999
    *  CreatedDate     : 4/10/2018
    *  Parameters      : Integer inputNumber
    *  Returns         : String resultWord
    ******************************************************************************/
    public static String convertNumberToWord(Integer inputNumber) {
        if (inputNumber == null || inputNumber <= 0 || inputNumber >= 1000) {
            return '';
        }

        String resultWord = '';
        Integer remainderOfDivision = 0;
        Integer dividerBase = 100;
        while(dividerBase > 1) {
            Integer num = inputNumber / dividerBase;
            remainderOfDivision = Math.Mod(inputNumber, dividerBase);

            if (dividerBase == 100) {
                resultWord += GlobalUtils.hundredthsList.get(num) + ' ';
            } else if (dividerBase == 10) {
                resultWord += GlobalUtils.decimalList.get(num) + ' ';
            } else {
                resultWord += GlobalUtils.unitList.get(num) + ' ';
            }

            if (remainderOfDivision < 20) {
                resultWord += GlobalUtils.unitList.get(remainderOfDivision);
                return resultWord.trim();
            }

            dividerBase = dividerBase / 10;
            inputNumber = remainderOfDivision;
        }
        return resultWord.trim();
    }

    /*******************************************************************************
    *  Name            : getStringOfMonth(Integer monthNumber)
    *  Summary         : get month for russian lang by month number
    *  CreatedDate     : 4/10/2018
    *  Parameters      : Integer monthNumber
    *  Returns         : String
    ******************************************************************************/
    public static String getStringOfMonth(Integer monthNumber) {
        if (monthNumber == 1) {
            return 'января';
        } else if (monthNumber == 2) {
            return 'февраля';
        } else if (monthNumber == 3) {
            return 'марта';
        } else if (monthNumber == 4) {
            return 'апреля';
        } else if (monthNumber == 5) {
            return 'мая';
        } else if (monthNumber == 6) {
            return 'июня';
        } else if (monthNumber == 7) {
            return 'июля';
        } else if (monthNumber == 8) {
            return 'августа';
        } else if (monthNumber == 9) {
            return 'сентября';
        } else if (monthNumber == 10) {
            return 'октября';
        } else if (monthNumber == 11) {
            return 'ноября';
        } else if (monthNumber == 12){
            return 'декабря';
        } else {
            return '';
        }
    }

    /*******************************************************************************
    *  Name            : parseNormNameForOrganization(String normName)
    *  Summary         : parse normName, which return spark
    *  CreatedDate     : 31/10/2018
    *  Parameters      : String normName
    *  Returns         : List<String> companyShortName and companyType
    ******************************************************************************/
    public static List<String> parseNormNameForOrganization(String normName) {
        String companyShortName = '';
        String companyType = '';
        String companyShortNameType = '';
        if (normName != null) {
            if (normName.contains(',')) {
                companyShortName = normName.substring(0, normName.lastIndexOf(','));
                companyType = normName.substring(normName.lastIndexOf(',') + 1).trim();
                if (companyType.contains(' ')) {
                    companyShortNameType = companyType.substringAfter(' ');
                    companyShortName = companyShortNameType + ' ' + companyShortName;
                    companyType = companyType.substringBefore(' ').trim();
                } else {
                    companyType = companyType.trim();
                }
            } else {
                companyShortName = normName;
                companyType = '';
            }
        }
        System.debug('*** companyShortName = ' + companyShortName);
        System.debug('*** companyType = ' + companyType);
        return new List<String>{companyShortName, companyType};
    }

    // E2E Ru partner
    public enum E2ERuPartner {
        MailRu,
        Metro
    }

    private static Map<String, String> e2eRuPartnerMap = new Map<String, String>{
            'MailRu' => 'Mail.ru',
            'Metro' => 'METRO'
    };

    public static String getE2ERuPartner(String s) {
        return e2eRuPartnerMap.get(s);
    }

    global enum EmailTemplateDevName {
        E2E_RU_Warning_Notification_Call_Center,
        E2E_RU_Disqualification_Lead,
        E2E_RU_Transfer_To_Service,
        E2E_RU_Transfer_To_Ko_With_INN,
        E2E_RU_Transfer_To_Ko_With_Email,
        E2E_RU_Transfer_To_Inbound,
        E2E_RU_Coordination_With_Risk_Management_Department,
        E2E_RU_Reseller,
        E2E_RU_Transfer_To_KO_More_10_Cards,
        E2E_RU_Transfer_To_KO_Manual_Entry,
        E2E_RU_Refusing_Opportunity
    }

    /*******************************************************************************
    *  Name            : generateGUID()
    *  Summary         : generates GUID that conform to UUID v4 standards
    *  CreatedDate     : 16/01/2019
    *  Parameters      :
    *  Returns         : String
    ******************************************************************************/
    public static String generateGUID() {
        String randomStringAsHex = EncodingUtil.convertToHex(Crypto.GenerateAESKey(128));

        String versionHexBits = randomStringAsHex.SubString(14, 16); // 7th bit
        String variantHexBits = randomStringAsHex.SubString(18, 20); // 9th bit

        Integer versionIntBits = convertHexToInt(versionHexBits);
        Integer variantIntBits = convertHexToInt(variantHexBits);

        Integer versionShiftedIntBits = versionIntBits & 15 | 64;  // (i & 0x0f) | 0x40
        Integer variantShiftedIntBits = variantIntBits & 63 | 128; // (i & 0x3f) | 0x80

        String versionShiftedHexBits = convertIntToHex(versionShiftedIntBits); // Always begins with 4
        String variantShiftedHexBits = convertIntToHex(variantShiftedIntBits); // Always begins with one of 8,9,a,b

        String guid = randomStringAsHex.SubString(0, 8) + '-' + randomStringAsHex.SubString(8, 12) + '-' + versionShiftedHexBits + randomStringAsHex.SubString(14, 16) + '-' + variantShiftedHexBits + randomStringAsHex.SubString(18, 20) + '-' + randomStringAsHex.substring(20);

        return guid;
    }

    private static Integer convertHexToInt(String hex) {
        Integer d0 = hexMap.IndexOf(hex.Substring(1, 2));
        Integer d1 = hexMap.IndexOf(hex.Substring(0, 1));

        Integer intval = d0 + (d1 * 16);
        return intval;
    }

    private static String convertIntToHex(Integer intval) {
        String hs0 = hexMap.Get(intval & 15); // i & 0x0f
        String hs1 = hexMap.Get(((intval >> 4) & 15)); //(i >> 4) & 0x0f
        return hs1 + hs0;
    }

    private static final List<String> hexMap = new List<String>{
            '0', '1', '2', '3', '4', '5', '6', '7',
            '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'
    };

    /*******************************************************************************
    *  Name            : getValueUntypedFromJSON()
    *  Summary         : search for JsonElement in JsonObject according to looking value
    *  CreatedDate     : 16/01/2019
    *  Parameters      : Map, String
    *  Returns         : Object or null if not found
    ******************************************************************************/
    public static Object getValueUntypedFromJSON(Map<String, Object> jsonObject, String lookingValueKey) {
        if (lookingValueKey == null) {
            return null;
        }

        if (jsonObject.get(lookingValueKey) != null) {
            return jsonObject.get(lookingValueKey);
        }
        Object result;

        for (String key : jsonObject.keySet()) {
            if (jsonObject.get(key) instanceof Map<String, Object>) {
                result = getValueUntypedFromJSON((Map<String, Object>) jsonObject.get(key), lookingValueKey);
                if (result != null) {
                    return result;
                }
            } else if (jsonObject.get(key) instanceof List<Object>) {
                for (Integer i = 0; i < ((List<Object>) jsonObject.get(key)).size(); i++) {
                    if (((List<Object>) jsonObject.get(key)).get(i) instanceof Map<String, Object>) {
                        result = getValueUntypedFromJSON((Map<String, Object>) ((List<Object>) jsonObject.get(key)).get(i), lookingValueKey);
                        if (result != null) {
                            return result;
                        }
                    }
                }
            }
        }

        return null;
    }

    /*******************************************************************************
    *  Name            : generateGUIDFromId
    *  Summary         : Codes SalesForce Id into GUID
    *  CreatedDate     : 17/01/2019
    *  Parameters      : Id inputId
    *  Returns         : String
    ******************************************************************************/
    public static String generateGUIDFromId(Id inputId) {
        String hex = EncodingUtil.convertToHex(EncodingUtil.base64Decode(String.valueOf(inputId) + 'ffff'));
        return hex.substring(0, 8) + '-' + hex.substring(8, 12) + '-' + hex.substring(12, 16) + '-' + hex.substring(16, 20) + '-' + hex.substring(20);
    }

    /*******************************************************************************
    *  Name            : retrieveIdFromGUID
    *  Summary         : Decodes SalesForce Id from GUID
    *  CreatedDate     : 17/01/2019
    *  Parameters      : String guid
    *  Returns         : Id
    ******************************************************************************/
    public static Id retrieveIdFromGUID(String guid) {
        return EncodingUtil.base64Encode(EncodingUtil.convertFromHex(guid.remove('-'))).substring(0, 18);
    }
}