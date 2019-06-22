public class ClickToCallHandler {
    public static String ENG_ALPH = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz';
    public static String DE_CODE = '+49';
    public static String AT_CODE = '+43';
    public static String PL_CODE = '+48';
    public static String NL_CODE = '+31';
    public static String BE_CODE = '+32';
    public static String FR_CODE = '+33';
    public static String HU_CODE = '+36';
    public static String CH_CODE = '+41';
    public static String LU_CODE = '+352';
    public static String CZ_CODE = '+420';
    public static String SK_CODE = '+421';

    /*******************************************************************************
    *  Name            : returnValidNumber(String phone, String CountryCode)
    *  Summary         : Based on phone and CountryCode return correct phone number     
    *  CreatedDate     : 01/03/2017
    *  ModifiedDate    : 30/03/2018
    *  Parameters      : String phone – phone from the Salesforce
                         String CountryCode – CountryCode from object
    *  Returns         : String - valid phone
    ******************************************************************************/
    public static String returnValidNumber(String phone, String countryCode) {
        String validPhone = phone;
        if (validPhone != null && ! validPhone.containsAny(ENG_ALPH) && (countryCode != 'LT' || countryCode != 'RU')) {
            validPhone = validPhone.replaceAll('[- .,/_*]','');
        }

        if (countryCode == 'DE') {
            validPhone = returnPhone(validPhone, DE_CODE, invalidCodesDESet);
        } else if (countryCode == 'AT') {
            validPhone = returnPhone(validPhone, AT_CODE, invalidCodesATSet);
        } else if (countryCode == 'PL') {
            validPhone = returnPhone(validPhone, PL_CODE, invalidCodesPLSet);
        } else if (countryCode == 'NL') {
            validPhone = returnPhone(validPhone, NL_CODE, invalidCodesNLSet);
        } else if (countryCode == 'BEFR' || countryCode == 'BENL') {
            validPhone = returnPhone(validPhone, BE_CODE, invalidCodesBESet);
        } else if (countryCode == 'FR') {
            validPhone = returnPhone(validPhone, FR_CODE, invalidCodesFRSet);
        } else if (countryCode == 'HU') {
            validPhone = returnPhone(validPhone, HU_CODE, invalidCodesHUSet);
        } else if (countryCode == 'CHDE' || countryCode == 'CHFR' || countryCode == 'CHIT') {
            validPhone = returnPhone(validPhone, CH_CODE, invalidCodesCHSet);
        } else if (countryCode == 'LU') {
            validPhone = returnPhone(validPhone, LU_CODE, invalidCodesLUSet);
        } else if (countryCode == 'CZ') {
            validPhone = returnPhone(validPhone, CZ_CODE, invalidCodesCZSet);
        } else if (countryCode == 'SK') {
            validPhone = returnPhone(validPhone, SK_CODE, invalidCodesSKSet);
        }

        if (validPhone != null && ! validPhone.containsAny(ENG_ALPH) && (countryCode != 'LT' || countryCode != 'RU')) {
            validPhone = validPhone.replaceAll('[()]','');
        }
        return validPhone;
    }


    /*******************************************************************************
    *  Name            : returnPhone(String phoneFromSalesforce, String mainCode, Set<String> invalidCodesSet)
    *  Summary         : Return phone number with correct phone code     
    *  CreatedDate     : 01/03/2017
    *  ModifiedDate    : 30/03/2018
    *  Parameters      : phoneFromSalesforce - object Phone field 
                         mainCode – static code for the country 
                         invalidCodesSet – set with supported invlalid phone codes
    *  Returns         : String – phone number
    ******************************************************************************/
    public static String returnPhone(String phoneFromSalesforce, String mainCode, Set<String> invalidCodesSet) {
        String validPhone = '';
        for (String invalidCode : invalidCodesSet) {
            if (phoneFromSalesforce != null && phoneFromSalesforce.length() >= invalidCode.length() && invalidCode == phoneFromSalesforce.substring(0, invalidCode.length())) {
                validPhone = mainCode + phoneFromSalesforce.substring(invalidCode.length(), phoneFromSalesforce.length());
                return validPhone;
            }
        }
        if (phoneFromSalesforce != null && phoneFromSalesforce.length() >= mainCode.length() && phoneFromSalesforce.isNumeric() && phoneFromSalesforce.substring(0, mainCode.length()) != mainCode) {
            validPhone = mainCode + phoneFromSalesforce;
            return validPhone;
        }

        return phoneFromSalesforce;
    }


    public static Set<String> invalidCodesDESet = new Set<String>{
        '+49(0)',
        '0049',
        '49(0)',
        '00049',
        '49',
        '049',
        '0',
        '(0)'
    };

    public static Set<String> invalidCodesATSet = new Set<String>{
        '+43(0)',
        '0043',
        '43(0)',
        '00043',
        '43',
        '043',
        '0',
        '(0)'
    };

    public static Set<String> invalidCodesPLSet = new Set<String>{
        '+48(0)',
        '0048',
        '48(0)',
        '00048',
        '48',
        '048',
        '0',
        '(0)'
    };

    public static Set<String> invalidCodesNLSet = new Set<String>{
        '+31(0)',
        '0031',
        '31(0)',
        '00031',
        '31',
        '031',
        '0',
        '(0)'
    };

    public static Set<String> invalidCodesBESet = new Set<String>{
        '+32(0)',
        '0032',
        '32(0)',
        '00032',
        '32',
        '032',
        '0',
        '(0)'
    };

    public static Set<String> invalidCodesFRSet = new Set<String>{
        '+33(0)',
        '0033',
        '33(0)',
        '00033',
        '33',
        '033',
        '0',
        '(0)'
    };

    public static Set<String> invalidCodesHUSet = new Set<String>{
        '+36(0)',
        '0036',
        '36(0)',
        '00036',
        '36',
        '036',
        '0',
        '(0)'
    };

    public static Set<String> invalidCodesCHSet = new Set<String>{
        '+41(0)',
        '0041',
        '41(0)',
        '00041',
        '41',
        '041',
        '0',
        '(0)'
    };

    public static Set<String> invalidCodesLUSet = new Set<String>{
        '+352(0)',
        '00352',
        '352(0)',
        '000352',
        '352',
        '0352',
        '0',
        '(0)'
    };

    public static Set<String> invalidCodesCZSet = new Set<String>{
        '+420(0)',
        '00420',
        '420(0)',
        '000420',
        '420',
        '0420',
        '0',
        '(0)'
    };

    public static Set<String> invalidCodesSKSet = new Set<String>{
        '+421(0)',
        '00421',
        '421(0)',
        '000421',
        '421',
        '0421',
        '0',
        '(0)'
    };
}