public class CreditFactoryUtilities {
    public static String CONTACT_ADMIN = 'Please contact your administrator.';

    public Static void displayMessage(String type, String message) {
        if (type == 'error') ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,message));
        if (type == 'info') ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,message));
        if (type == 'confirm') ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,message));
        if (type == 'warning') ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,message));
    }

    public static String returnCurrentDate()  {
        String strConvertedDate = Datetime.now().format(
            'yyyy-MM-dd HH:mm:ss');
        strConvertedDate = strConvertedDate.replace(' ', 'T');
        strConvertedDate = strConvertedDate + '.' + Datetime.now().millisecond();
        return strConvertedDate;
    }

    public static Boolean isStringsEquals(String string1, String string2) {
        if (string1 == null || string2 == null) {
            return false;
        }

        if (string1.toUpperCase() == string2.toUpperCase()) {
            return true;
        } else {
            return false;
        }
    }

    public static String returnLabelOfField(String objectName, String fieldName) {
        List<Schema.DescribeSObjectResult> describeSobjectsResult = Schema.describeSObjects(new List<String>{objectName});
        String objectLabel = describeSobjectsResult[0].getLabel();
        Map<String, Schema.SObjectField> allFields = describeSobjectsResult[0].fields.getMap();
        String fieldLabel = allFields.get(fieldName).getDescribe().getLabel();

        return fieldLabel;
    }

    public static List<Schema.SObjectField> returnAPINames(String objectName) {
        List<Schema.DescribeSObjectResult> describeSobjectsResult = Schema.describeSObjects(new List<String>{objectName});
        String objectLabel = describeSobjectsResult[0].getLabel();
        Map<String, Schema.SObjectField> allFields = describeSobjectsResult[0].fields.getMap();
        
        return allFields.values();
    }

    public static String returnArabicFromAlpha(String romanValue) {
        if (romanValue == 'A') return '1';
        if (romanValue == 'B') return '2';
        if (romanValue == 'C') return '3';
        if (romanValue == 'D') return '4';
        if (romanValue == 'E') return '5';
        return romanValue;
    }

    public static String returnArabic(String romanValue) {
        if (romanValue == 'I') return '1';
        if (romanValue == 'II') return '2';
        if (romanValue == 'III') return '3';
        if (romanValue == 'IV') return '4';
        if (romanValue == 'V') return '5';
        if (romanValue == 'VI') return '6';
        if (romanValue == 'VII') return '7';
        if (romanValue == 'VIII') return '8';
        if (romanValue == 'IX') return '9';
        if (romanValue == 'X') return '10';
        return romanValue;
    }


    /*******************************************************************************
    *  Name            : returnArabicFromSolvencyIndex(String solvencyIndex)
    *  Summary         : 100-216 - 1, 217-246 - 2, 247-283 - 3, 284-302 - 4, 303-358 - 5, 359-600 - 6    
    *  CreatedDate     : 05/02/2018
    *  ModifiedDate    : 28/09/2018
    *  Parameters      : String solvencyIndex - index related to class rating
    *  Returns         : String
    ******************************************************************************/
    public static String returnArabicFromSolvencyIndex(String solvencyIndex) {
        if (solvencyIndex != null && solvencyIndex.isNumeric()) {
            Integer solvencyIndexValue = Integer.valueOf(solvencyIndex);
            if (solvencyIndexValue >= 100 && solvencyIndexValue <= 216) return '1';
            if (solvencyIndexValue >= 217 && solvencyIndexValue <= 246) return '2';
            if (solvencyIndexValue >= 247 && solvencyIndexValue <= 283) return '3';
            if (solvencyIndexValue >= 284 && solvencyIndexValue <= 302) return '4';
            if (solvencyIndexValue >= 303 && solvencyIndexValue <= 358) return '5';
            if (solvencyIndexValue >= 359 && solvencyIndexValue <= 600) return '6';
        }
        return solvencyIndex;
    }


    /*******************************************************************************
    *  Name            : returnCofaceClassRating(String classRating)
    *  Summary         : 1-1, 2-4, 3-6    
    *  CreatedDate     : 12/03/2018
    *  ModifiedDate    : 12/03/2018
    *  Parameters      : String classRating - class rating from coface webservice
    *  Returns         : String
    ******************************************************************************/
    public static String returnCofaceClassRating(String classRating) {
        if (classRating == '1') return '1';
        if (classRating == '2') return '4';
        if (classRating == '3') return '6';
        return classRating;
    }


    /*******************************************************************************
    *  Name            : returnCofaceOrderedReportClassRating(String classRating)
    *  Summary         : 1,2,3-1; 4,5-4; 6,7,8,9,10-5    
    *  CreatedDate     : 05/07/2018
    *  ModifiedDate    : -
    *  Parameters      : String classRating - class rating from ordered report
    *  Returns         : String
    ******************************************************************************/
    public static String returnCofaceOrderedReportClassRating(String classRating) {
        if (classRating == '1' || classRating == '2' || classRating == '3') return '1';
        if (classRating == '4' || classRating == '5') return '4';
        if (classRating == '6' || classRating == '7' || classRating == '8' || classRating == '9' || classRating == '10') return '6';
        return null;
    }


    /*******************************************************************************
    *  Name            : returnArabicFromTrafficLight(String trafficLight)
    *  Summary         : green - 1, yellow - 2, red - 3    
    *  CreatedDate     : 11/01/2018
    *  ModifiedDate    : 11/01/2018
    *  Parameters      : String trafficLight - class Rating (green, yellow, red)
    *  Returns         : String
    ******************************************************************************/
    public static String returnArabicFromTrafficLight(String trafficLight) {
        if (trafficLight == 'GREEN') return '1';
        if (trafficLight == 'YELLOW') return '2';
        if (trafficLight == 'RED') return '3';

        return null;
    }


    /*******************************************************************************
    *  Name            : returnCrediconnectClassRating(String scoreString)
    *  Summary         : Return class rating number based on score (0-100)
    *  CreatedDate     : 09/10/2018
    *  ModifiedDate    : 28/11/2018
    *  Parameters      : String scoreString - class rating score
    *  Returns         : String
    ******************************************************************************/
    public static String returnCrediconnectClassRating(String scoreString) {
        if (scoreString != null && scoreString.isNumeric()) {
            Integer scoreNumber = Integer.valueOf(scoreString);
            if (scoreNumber >= 91 && scoreNumber <= 100) return '1';
            if (scoreNumber >= 81 && scoreNumber <= 90) return '2';
            if (scoreNumber >= 71 && scoreNumber <= 80) return '3';
            if (scoreNumber >= 60 && scoreNumber <= 70) return '4';
            if (scoreNumber >= 39 && scoreNumber <= 59) return '5';
            if ((scoreNumber >= 0 && scoreNumber <= 38) || scoreNumber == null) return '6';
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnCreditLimitValue(String classRating)
    *  Summary         : return value of credit limit based on class rating (U+)    
    *  CreatedDate     : 12/01/2017
    *  ModifiedDate    : 12/01/2017
    *  Parameters      : String classRating - credit company rating
    *  Returns         : String
    ******************************************************************************/
    public static String returnCreditLimitValue(String classRating) {
        if (classRating != null) {
            String ratingLetter = classRating.substring(0, 1);
            if (ratingLetter == 'A') {
                return '80000';
            } else if (ratingLetter == 'B') {
                return '40000';
            } else if (ratingLetter == 'C') {
                return '20000';
            } else if (ratingLetter == 'D') {
                return '10000';
            } else if (ratingLetter == 'U') {
                return '7000';
            }
        }

        return null;
    }


    /*******************************************************************************
    *  Name            : returnSolvencyIndex(String classRating)
    *  Summary         : return solvency index based on class rating (U+)
    *  CreatedDate     : 12/01/2017
    *  ModifiedDate    : 12/01/2017
    *  Parameters      : String classRating - credit company rating
    *  Returns         : String
    ******************************************************************************/
    public static String returnSolvencyIndex(String classRating) {
        if (classRating != null) {
            String ratingOperator = classRating.substring(1, classRating.length());
            if (ratingOperator == '+++') {
                return '100';
            } else if (ratingOperator == '++') {
                return '200';
            } else if (ratingOperator == '+') {
                return '300';
            } else if (ratingOperator == '-') {
                return '400';
            } else if (ratingOperator == '--') {
                return '500';
            } else if (ratingOperator == '---') {
                return '600';
            }
        }

        return null;
    }


    /*******************************************************************************
    *  Name            : returnTurnOverValue(String classRating)
    *  Summary         : return value of Turn Over based on class rating (U+)
    *  CreatedDate     : 12/01/2018
    *  ModifiedDate    : 12/01/2018
    *  Parameters      : String classRating - credit company rating
    *  Returns         : String
    ******************************************************************************/
    public static String returnTurnOverValue(String classRating) {
        if (classRating != null) {
            String ratingLetter = classRating.substring(0, 1);
            if (ratingLetter == 'A') {
                return '>= 5 Million';
            } else if (ratingLetter == 'B') {
                return '500.000 - 5 Million';
            } else if (ratingLetter == 'C') {
                return '100.000 - 499.999';
            } else if (ratingLetter == 'D') {
                return '< 100000';
            } else if (ratingLetter == 'U') {
                return 'unknown';
            }
        }

        return null;
    }


    /*******************************************************************************
    *  Name            : getStreet(String streetAndHouseNumber)
    *  Summary         : Get Street name from BillingStreet without House Number
    *  CreatedDate     : 8/12/2016
    *  Parameters      : streetAndHouseNumber - BillingStreet(Street + House Number)
    *  Returns         : String 
    ******************************************************************************/
    public static String getStreet(String streetAndHouseNumber) {
        String street;
        if (streetAndHouseNumber != null) {
            if (! streetAndHouseNumber.substringAfterLast(' ').isAlpha()) {
                street = streetAndHouseNumber.substringBeforeLast(' ');
            } else if (! (streetAndHouseNumber.substringBeforeLast(' ').substringAfterLast(' ') + ' ' + streetAndHouseNumber.substringAfterLast(' ')).isAlphaSpace()) {
                street = streetAndHouseNumber.substringBeforeLast(' ').substringBeforeLast(' ');
            } else {
                street = streetAndHouseNumber.substringBeforeLast(' ').substringBeforeLast(' ').substringBeforeLast(' ');
            }
        }

        return street;
    }


    /*******************************************************************************
    *  Name            : getHousenumber(String streetAndHouseNumber)
    *  Summary         : Get House Number from BillingStreet without Street Name 
    *  CreatedDate     : 8/12/2016
    *  Parameters      : streetAndHouseNumber - BillingStreet(Street + House Number)
    *  Returns         : String 
    ******************************************************************************/
    public static String getHousenumber(String streetAndHouseNumber) {
        String housenumber;
        if (streetAndHouseNumber != null) {
            if (! streetAndHouseNumber.substringAfterLast(' ').isAlpha()) {
                housenumber = streetAndHouseNumber.substringAfterLast(' ');
            } else if (! (streetAndHouseNumber.substringBeforeLast(' ').substringAfterLast(' ') + ' ' + streetAndHouseNumber.substringAfterLast(' ')).isAlphaSpace()) {
                housenumber = streetAndHouseNumber.substringBeforeLast(' ').substringAfterLast(' ') + ' ' + streetAndHouseNumber.substringAfterLast(' ');
            } else {
                housenumber = streetAndHouseNumber.substringBeforeLast(' ').substringBeforeLast(' ') + ' ' + streetAndHouseNumber.substringBeforeLast(' ').substringAfterLast(' ') + ' ' + streetAndHouseNumber.substringAfterLast(' ');
            }

            housenumber = housenumber.substringBefore(' ').substringBefore('-').substringBefore('/').substringBefore('.').replaceAll('[^0-9]', '');
        }

        return housenumber;
    }


    /*******************************************************************************
    *  Name            : checkDuplicates(Opportunity currentOpportunity)
    *  Summary         : if duplicates is existed then stop credit process    
    *  CreatedDate     : 06/01/2018
    *  Parameters      : Opportunity currentOpportunity - opportunity to check duplicates
    *  Returns         : void
    ******************************************************************************/
    public static void checkDuplicates(Opportunity currentOpportunity) {
        String exceptionString = checkOpportunityDuplicates(currentOpportunity);
        exceptionString += checkAccountDuplicates(currentOpportunity);
        exceptionString += checkContactDuplicates(currentOpportunity);
        if (exceptionString != '') {
            throw new CreditFactoryException(exceptionString);
        }
    }


    /*******************************************************************************
    *  Name            : checkOpportunityDuplicates(Opportunity currentOpportunity)
    *  Summary         : if Opportunity duplicates is existed then stop credit process      
    *  CreatedDate     : 06/01/2018
    *  Parameters      : Opportunity currentOpportunity - opportunity to check duplicates
    *  Returns         : String
    ******************************************************************************/
    private static String checkOpportunityDuplicates(Opportunity currentOpportunity) {
        String opportunitiesQuery = 'SELECT Name, IBAN__c, RecordType.Name, StageName, Gruende_verloren__c, Credit_System_Number__c, Creditreform_Nummer__c, AccountId' +
                ' FROM Opportunity' + 
                ' WHERE (RecordType.Name = \'Euroshell\' OR RecordType.Name = \'Euroshell Starts\')' + ((currentOpportunity.Account.BillingCountry != null) ? ' AND ' + 
                    (currentOpportunity.Account.BillingCountry.contains('Belgium') ? '(Account.BillingCountry = \'Belgium-NL\' OR Account.BillingCountry = \'Belgium-FR\')' : 
                    (currentOpportunity.Account.BillingCountry.contains('Switzerland') ? '(Account.BillingCountry = \'Switzerland-DE\' OR Account.BillingCountry = \'Switzerland-FR\'' + 
                    ' OR Account.BillingCountry = \'Switzerland-IT\')' : 'Account.BillingCountry = \'' + clearFieldSOQL(currentOpportunity.Account.BillingCountry) + '\'')) : '') + ' AND (' + 
                    ((currentOpportunity.Name != '[nicht vorhanden]' && currentOpportunity.Name != 'New Inbound Lead') ? 'Name = \'' + 
                    clearFieldSOQL(currentOpportunity.Name) + '\'' : '') + ((currentOpportunity.IBAN__c != null && currentOpportunity.IBAN__c != 'n/a' && 
                    currentOpportunity.IBAN__c != 'X' && currentOpportunity.IBAN__c != 'x' && currentOpportunity.IBAN__c != 'XX' && 
                    currentOpportunity.IBAN__c != 'xx' && ! currentOpportunity.IBAN__c.containsIgnoreCase('XXX') && currentOpportunity.IBAN__c != 'DE000') ? 
                    ' OR IBAN__c = \'' + clearFieldSOQL(currentOpportunity.IBAN__c) + '\'' : '') + ((currentOpportunity.Credit_System_Number__c != null) ? 
                    ' OR Credit_System_Number__c = \'' + clearFieldSOQL(currentOpportunity.Credit_System_Number__c) + '\' OR Creditreform_Nummer__c = \'' + 
                    clearFieldSOQL(currentOpportunity.Credit_System_Number__c) + '\'' : '') +
                ') LIMIT 100';

        List<Opportunity> duplicateOpportunitiesList = Database.query(opportunitiesQuery);
        String exceptionString = '';
        if (! duplicateOpportunitiesList.isEmpty()) {
            Integer counter = 0;
            for (Opportunity opportunity : duplicateOpportunitiesList) {
                if ((opportunity.Name == currentOpportunity.Name || opportunity.IBAN__c == currentOpportunity.IBAN__c ||
                        opportunity.Credit_System_Number__c == currentOpportunity.Credit_System_Number__c || 
                        opportunity.Creditreform_Nummer__c == currentOpportunity.Credit_System_Number__c) &&
                        ! (opportunity.StageName == 'Closed Lost' && opportunity.Gruende_verloren__c != 'Refused Credit') &&
                        opportunity.Id != currentOpportunity.Id && opportunity.AccountId != currentOpportunity.AccountId) {
                    if (! exceptionString.contains('<br/>Duplicate Opportunities found:<br/>')) {
                        exceptionString += '<br/>Duplicate Opportunities found:<br/>';
                    }
                    exceptionString += '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + opportunity.Id + 
                        '">' + opportunity.Name + '</a>' + '<br/>';
                    counter ++;
                    if (counter == 5) {
                        break;
                    }
                }
            }
        }

        return exceptionString;
    }


    /*******************************************************************************
    *  Name            : checkAccountDuplicates(Opportunity currentOpportunity)
    *  Summary         : if Account duplicates is existed then stop credit process      
    *  CreatedDate     : 06/01/2018
    *  Parameters      : Opportunity currentOpportunity - opportunity to check duplicates
    *  Returns         : String
    ******************************************************************************/
    private static String checkAccountDuplicates(Opportunity currentOpportunity) {
        String accountsQuery = 'SELECT Name, Steuernummer__c, Umsatzsteuer_ID__c, RecordType.Name, BillingCity, BillingStreet' +
                ' FROM Account' + 
                ' WHERE RecordType.Name = \'Endkunde\'' + ((currentOpportunity.Account.BillingCountry != null) ? ' AND ' + 
                    (currentOpportunity.Account.BillingCountry.contains('Belgium') ? '(BillingCountry = \'Belgium-NL\' OR BillingCountry = \'Belgium-FR\')' : 
                    (currentOpportunity.Account.BillingCountry.contains('Switzerland') ? '(BillingCountry = \'Switzerland-DE\' OR BillingCountry = \'Switzerland-FR\'' + 
                    ' OR BillingCountry = \'Switzerland-IT\')' : 'BillingCountry = \'' + clearFieldSOQL(currentOpportunity.Account.BillingCountry) + '\'')) : '') + 
                    ' AND (' + ((currentOpportunity.Name != '[nicht vorhanden]' && currentOpportunity.Name != 'New Inbound Lead') ? 'Name = \'' + 
                    clearFieldSOQL(currentOpportunity.Account.Name) + '\'' : '') + (currentOpportunity.Account.Umsatzsteuer_ID__c != null ? ' OR Umsatzsteuer_ID__c = \'' + 
                    clearFieldSOQL(currentOpportunity.Account.Umsatzsteuer_ID__c) + '\'' : '') + (currentOpportunity.Account.Steuernummer__c != null &&
                    currentOpportunity.Account.Steuernummer__c != 'nicht bekannt' && currentOpportunity.Account.Steuernummer__c != 'unbekannt' &&
                    currentOpportunity.Account.Steuernummer__c != '0' ? ' OR Steuernummer__c = \'' + clearFieldSOQL(currentOpportunity.Account.Steuernummer__c) + '\'' : '') + 
                    (currentOpportunity.Account.BillingCity != null && currentOpportunity.Account.BillingStreet != null ? ' OR (BillingCity = \'' + 
                    clearFieldSOQL(currentOpportunity.Account.BillingCity) + '\' AND BillingStreet = \'' + clearFieldSOQL(currentOpportunity.Account.BillingStreet) + '\')' : '') +
                ') LIMIT 6';

        String exceptionString = '';
        List<Account> duplicateAccountsList = Database.query(accountsQuery);
        if (! duplicateAccountsList.isEmpty()) {
            Integer counter = 0;
            for (Account account : duplicateAccountsList) {
                if ((account.Name == currentOpportunity.Account.Name || account.Steuernummer__c == currentOpportunity.Account.Steuernummer__c ||
                        account.Umsatzsteuer_ID__c == currentOpportunity.Account.Umsatzsteuer_ID__c || account.BillingCity == currentOpportunity.Account.BillingCity && 
                        account.BillingStreet == currentOpportunity.Account.BillingStreet) && account.Id != currentOpportunity.Account.Id) {
                    if (! exceptionString.contains('<br/>Duplicate Accounts found:<br/>')) {
                        exceptionString += '<br/>Duplicate Accounts found:<br/>';
                    }
                    exceptionString += '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + account.Id + '">' + account.Name + '</a>' + '<br/>';
                    if (counter == 5) {
                        break;
                    }
                }
            }
        }

        return exceptionString;
    }


    /*******************************************************************************
    *  Name            : checkContactDuplicates(Opportunity currentOpportunity)
    *  Summary         : if Contact duplicates is existed then stop credit process      
    *  CreatedDate     : 06/01/2018
    *  Parameters      : Opportunity currentOpportunity - opportunity to check duplicates
    *  Returns         : String
    ******************************************************************************/
    private static String checkContactDuplicates(Opportunity currentOpportunity) {
        Set<Id> currentContactsIdsSet = new Set<Id>();
        Set<String> contactEmailsSet = new Set<String>();
        Set<String> contactPhonesSet = new Set<String>();
        Set<String> contactFirstNamesSet = new Set<String>();
        Set<String> contactLastNamesSet = new Set<String>();
        Set<String> contactDataSet = new Set<String>();
        Map<String, Set<String>> contactLastNameToFirstNamesMap = new Map<String, Set<String>>();
        for (OpportunityContactRole contactRole : currentOpportunity.OpportunityContactRoles) {
            currentContactsIdsSet.add(contactRole.ContactId);
            String contactDataString = '';
            if (contactRole.Contact.FirstName != null) {
                contactFirstNamesSet.add(clearFieldSOQL(contactRole.Contact.FirstName));
                contactDataString += clearFieldSOQL(contactRole.Contact.FirstName) + ' ';
            }

            contactDataString += clearFieldSOQL(contactRole.Contact.LastName) + ' ';
            contactLastNamesSet.add(clearFieldSOQL(contactRole.Contact.LastName));
            if (contactRole.Contact.Email != null) {
                contactEmailsSet.add(clearFieldSOQL(contactRole.Contact.Email));
                contactDataString += clearFieldSOQL(contactRole.Contact.Email.substringAfter('@'));
            }

            contactDataSet.add(contactDataString);

            if (contactRole.Contact.Phone != null) {
                contactPhonesSet.add(clearFieldSOQL(contactRole.Contact.Phone));
            }
        }

        String contactsQuery = 'SELECT FirstName, LastName, Phone, Email, Name, Account.RecordType.Name' +
                ' FROM Contact' + 
                ' WHERE Account.RecordType.Name = \'Endkunde\'' + ((currentOpportunity.Account.BillingCountry != null) ? ' AND ' + 
                    (currentOpportunity.Account.BillingCountry.contains('Belgium') ? '(Account.BillingCountry = \'Belgium-NL\' OR Account.BillingCountry = \'Belgium-FR\')' : 
                    (currentOpportunity.Account.BillingCountry.contains('Switzerland') ? '(Account.BillingCountry = \'Switzerland-DE\' OR ' + 
                    'Account.BillingCountry = \'Switzerland-FR\' OR Account.BillingCountry = \'Switzerland-IT\')' : 'Account.BillingCountry = \'' + 
                    clearFieldSOQL(currentOpportunity.Account.BillingCountry) + '\'')) : '') + ' AND (' + (! contactEmailsSet.isEmpty() ? 
                    'Email IN :contactEmailsSet OR ' : '') + (! contactPhonesSet.isEmpty() ? 'Phone IN :contactPhonesSet OR ' : '') +
                    ((! contactEmailsSet.isEmpty() && ! contactFirstNamesSet.isEmpty()) ? '(FirstName IN :contactFirstNamesSet AND LastName IN :contactLastNamesSet)' : '');
        contactsQuery = contactsQuery.removeEnd('OR ') + ') LIMIT 20';
        String exceptionString = '';
        if (! contactsQuery.endsWith('() LIMIT 20')) {
            List<Contact> duplicateContactsList = Database.query(contactsQuery);
            if (! duplicateContactsList.isEmpty()) {
                Integer counter = 0;
                for (Contact contact : duplicateContactsList) {
                    if ((contactEmailsSet.contains(contact.Email) || contactPhonesSet.contains(contact.Phone) || 
                            (contact.Email != null && contactDataSet.contains(contact.FirstName + ' ' + contact.LastName + ' ' + contact.Email.substringAfter('@')))) &&
                            ! currentContactsIdsSet.contains(contact.Id)
                            ) {
                        if (! exceptionString.contains('<br/>Duplicate Contacts found:<br/>')) {
                            exceptionString += '<br/>Duplicate Contacts found:<br/>';
                        }

                        exceptionString += '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + contact.Id + 
                            '">' + contact.Name + '</a>' + '<br/>';
                        counter ++;
                        if (counter == 5) {
                            break;
                        }
                    }
                }
            }
        }

        return exceptionString;
    }


    /*******************************************************************************
    *  Name            : clearFieldSOQL(String field)
    *  Summary         : remove illegal characters from field for SOQL    
    *  CreatedDate     : 23/01/2017
    *  ModifiedDate    : 23/01/2017
    *  Parameters      : String field - field for SOQL
    *  Returns         : String
    ******************************************************************************/
    private static String clearFieldSOQL(String field) {
        if (field != null && field.contains('\'')) {
            field = field.replace('\'', '\\\'');
        }

        return field;
    }


    /*******************************************************************************
    *  Name            : clearErrorMessage(String error)
    *  Summary         : remove waste characters from error message    
    *  CreatedDate     : 09/02/2018
    *  ModifiedDate    : 09/02/2018
    *  Parameters      : String error - error message
    *  Returns         : String
    ******************************************************************************/
    public static String clearErrorMessage(String error) {
        if (error.contains('BLACK LIST')) {
            String comment = error.substringBetween('^^');
            error = 'Company found in black list. Please refer to credit.' + 
                    (comment != null ? '\nComment: ' + comment : '');
        } else if (error.contains('Duplicate Opportunities found:') || 
            error.contains('Duplicate Accounts found:') || 
            error.contains('Duplicate Contacts found:')) {
            error = 'Duplicates found.';
        } else if (error == 'Fix all validation errors or refer to Credit.') {
            error = '';
        }

        error = error.replace('<br/>', '').replace('<ul>', '').replace('</ul>', '').replace('<li>', '\n').replace('</li>', '');
        return error;
    }


    /*******************************************************************************
    *  Name            : getKvk(String kvk)
    *  Summary         : get Kvk number for search    
    *  CreatedDate     : 12/02/2018
    *  ModifiedDate    : 12/02/2018
    *  Parameters      : String kvk
    *  Returns         : String
    ******************************************************************************/
    public static String getKvk(String kvk) {
        if (kvk != null && kvk.length() == 10 && kvk.startsWith('0')) {
            return kvk.substring(1, 10); 
        }

        return kvk;
    }


    /*******************************************************************************
    *  Name            : replaceGermanCharacters(String stringInGerman)
    *  Summary         : replace letter-diacritic combinations Ä/ä, Ö/ö, Ü/ü and ligatures ß.
    *  CreatedDate     : 29/03/2018
    *  ModifiedDate    : 29/03/2018
    *  Parameters      : String stringInGerman - string with country specific letters
    *  Returns         : String
    ******************************************************************************/
    public static String replaceGermanCharacters(String stringInGerman) {
        if (stringInGerman != null) {
            if (stringInGerman.contains('Ä')) {
                stringInGerman = stringInGerman.replace('Ä', 'AE');
            }
            if (stringInGerman.contains('ä')) {
                stringInGerman = stringInGerman.replace('ä', 'ae');
            }
            if (stringInGerman.contains('Ö')) {
                stringInGerman = stringInGerman.replace('Ö', 'OE');
            } 
            if (stringInGerman.contains('ö')) {
                stringInGerman = stringInGerman.replace('ö', 'oe');
            } 
            if (stringInGerman.contains('Ü')) {
                stringInGerman = stringInGerman.replace('Ü', 'UE');
            } 
            if (stringInGerman.contains('ü')) {
                stringInGerman = stringInGerman.replace('ü', 'ue');
            }
            // "ß" cannot be capital
            if (stringInGerman.contains('ß')) {
                stringInGerman = stringInGerman.replace('ß', 'ss');
            }
        }

        return stringInGerman;
    }


    /*******************************************************************************
    *  Name            : replacePolishCharacters(String stringInPolish)
    *  Summary         : Replace Ć, ć, Ń, ń, Ó, ó, Ś, ś, Ź, ź, Ż, ż, Ą, ą, Ę, ę, Ł, ł, X, x.
    *  CreatedDate     : 26/06/2018
    *  ModifiedDate    : -
    *  Parameters      : String stringInPolish - string with country specific letters
    *  Returns         : String
    ******************************************************************************/
    public static String replacePolishCharacters(String stringInPolish) {
        if (stringInPolish != null) {
            if (stringInPolish.contains('Ć')) {
                stringInPolish = stringInPolish.replace('Ć', 'C');
            }
            if (stringInPolish.contains('ć')) {
                stringInPolish = stringInPolish.replace('ć', 'c');
            }
            if (stringInPolish.contains('Ń')) {
                stringInPolish = stringInPolish.replace('Ń', 'N');
            }
            if (stringInPolish.contains('ń')) {
                stringInPolish = stringInPolish.replace('ń', 'n');
            }
            if (stringInPolish.contains('Ó')) {
                stringInPolish = stringInPolish.replace('Ó', 'O');
            }
            if (stringInPolish.contains('ó')) {
                stringInPolish = stringInPolish.replace('ó', 'o');
            }
            if (stringInPolish.contains('Ś')) {
                stringInPolish = stringInPolish.replace('Ś', 'S');
            }
            if (stringInPolish.contains('ś')) {
                stringInPolish = stringInPolish.replace('ś', 's');
            }
            if (stringInPolish.contains('Ź')) {
                stringInPolish = stringInPolish.replace('Ź', 'Z');
            }
            if (stringInPolish.contains('ź')) {
                stringInPolish = stringInPolish.replace('ź', 'z');
            }
            if (stringInPolish.contains('Ż')) {
                stringInPolish = stringInPolish.replace('Ż', 'Z');
            }
            if (stringInPolish.contains('ż')) {
                stringInPolish = stringInPolish.replace('ż', 'z');
            }
            if (stringInPolish.contains('Ą')) {
                stringInPolish = stringInPolish.replace('Ą', 'A');
            }
            if (stringInPolish.contains('ą')) {
                stringInPolish = stringInPolish.replace('ą', 'a');
            }
            if (stringInPolish.contains('Ę')) {
                stringInPolish = stringInPolish.replace('Ę', 'E');
            }
            if (stringInPolish.contains('ę')) {
                stringInPolish = stringInPolish.replace('ę', 'e');
            }
            if (stringInPolish.contains('Ł')) {
                stringInPolish = stringInPolish.replace('Ł', 'L');
            }
            if (stringInPolish.contains('ł')) {
                stringInPolish = stringInPolish.replace('ł', 'l');
            }
            if (stringInPolish.contains('X')) {
                stringInPolish = stringInPolish.replace('X', 'KS');
            }
            if (stringInPolish.contains('x')) {
                stringInPolish = stringInPolish.replace('x', 'ks');
            }
        }

        return stringInPolish;
    }


    /*******************************************************************************
    *  Name            : replaceHungarianCharacters(String stringInHungarian)
    *  Summary         : Replace Á, á, É, é, Í, í, Ó, ó, Ö, ö, Ő, ő, Ú, ú, Ü, ü, Ű, ű.     
    *  CreatedDate     : 26/06/2018
    *  ModifiedDate    : -
    *  Parameters      : String stringInHungarian - string with country specific letters
    *  Returns         : String
    ******************************************************************************/
    public static String replaceHungarianCharacters(String stringInHungarian) {
        if (stringInHungarian != null) {
            if (stringInHungarian.contains('Á')) {
                stringInHungarian = stringInHungarian.replace('Á', 'A');
            }
            if (stringInHungarian.contains('á')) {
                stringInHungarian = stringInHungarian.replace('á', 'a');
            }
            if (stringInHungarian.contains('É')) {
                stringInHungarian = stringInHungarian.replace('É', 'E');
            }
            if (stringInHungarian.contains('é')) {
                stringInHungarian = stringInHungarian.replace('é', 'e');
            }
            if (stringInHungarian.contains('Í')) {
                stringInHungarian = stringInHungarian.replace('Í', 'I');
            }
            if (stringInHungarian.contains('í')) {
                stringInHungarian = stringInHungarian.replace('í', 'i');
            }
            if (stringInHungarian.contains('Ó')) {
                stringInHungarian = stringInHungarian.replace('Ó', 'O');
            }
            if (stringInHungarian.contains('ó')) {
                stringInHungarian = stringInHungarian.replace('ó', 'o');
            }
            if (stringInHungarian.contains('Ö')) {
                stringInHungarian = stringInHungarian.replace('Ö', 'O');
            }
            if (stringInHungarian.contains('ö')) {
                stringInHungarian = stringInHungarian.replace('ö', 'o');
            }
            if (stringInHungarian.contains('Ő')) {
                stringInHungarian = stringInHungarian.replace('Ő', 'O');
            }
            if (stringInHungarian.contains('ő')) {
                stringInHungarian = stringInHungarian.replace('ő', 'o');
            }
            if (stringInHungarian.contains('Ú')) {
                stringInHungarian = stringInHungarian.replace('Ú', 'U');
            }
            if (stringInHungarian.contains('ú')) {
                stringInHungarian = stringInHungarian.replace('ú', 'u');
            }
            if (stringInHungarian.contains('Ü')) {
                stringInHungarian = stringInHungarian.replace('Ü', 'U');
            }
            if (stringInHungarian.contains('ü')) {
                stringInHungarian = stringInHungarian.replace('ü', 'u');
            }
            if (stringInHungarian.contains('Ű')) {
                stringInHungarian = stringInHungarian.replace('Ű', 'U');
            }
            if (stringInHungarian.contains('ű')) {
                stringInHungarian = stringInHungarian.replace('ű', 'u');
            }
        }

        return stringInHungarian;
    }


    /*******************************************************************************
    *  Name            : replaceFrenchCharacters(String stringInFrench)
    *  Summary         : Replace Ç, ç, É, é, Â, â, Ê, ê, Î, î, Ô, ô, Û, û, À, à, È, è, Ù, ù, Ë, ë, Ï, ï, Ü, ü.
    *  CreatedDate     : 26/06/2018
    *  ModifiedDate    : -
    *  Parameters      : String stringInFrench - string with country specific letters
    *  Returns         : String
    ******************************************************************************/
    public static String replaceFrenchCharacters(String stringInFrench) {
        if (stringInFrench != null) {
            if (stringInFrench.contains('Ç')) {
                stringInFrench = stringInFrench.replace('Ç', 'C');
            }
            if (stringInFrench.contains('ç')) {
                stringInFrench = stringInFrench.replace('ç', 'c');
            }
            if (stringInFrench.contains('É')) {
                stringInFrench = stringInFrench.replace('É', 'E');
            }
            if (stringInFrench.contains('é')) {
                stringInFrench = stringInFrench.replace('é', 'e');
            }
            if (stringInFrench.contains('Â')) {
                stringInFrench = stringInFrench.replace('Â', 'A');
            }
            if (stringInFrench.contains('â')) {
                stringInFrench = stringInFrench.replace('â', 'a');
            }
            if (stringInFrench.contains('Ê')) {
                stringInFrench = stringInFrench.replace('Ê', 'E');
            }
            if (stringInFrench.contains('ê')) {
                stringInFrench = stringInFrench.replace('ê', 'e');
            }
            if (stringInFrench.contains('Î')) {
                stringInFrench = stringInFrench.replace('Î', 'I');
            }
            if (stringInFrench.contains('î')) {
                stringInFrench = stringInFrench.replace('î', 'i');
            }
            if (stringInFrench.contains('Ô')) {
                stringInFrench = stringInFrench.replace('Ô', 'O');
            }
            if (stringInFrench.contains('ô')) {
                stringInFrench = stringInFrench.replace('ô', 'o');
            }
            if (stringInFrench.contains('Û')) {
                stringInFrench = stringInFrench.replace('Û', 'U');
            }
            if (stringInFrench.contains('û')) {
                stringInFrench = stringInFrench.replace('û', 'u');
            }
            if (stringInFrench.contains('À')) {
                stringInFrench = stringInFrench.replace('À', 'A');
            }
            if (stringInFrench.contains('à')) {
                stringInFrench = stringInFrench.replace('à', 'a');
            }
            if (stringInFrench.contains('È')) {
                stringInFrench = stringInFrench.replace('È', 'E');
            }
            if (stringInFrench.contains('è')) {
                stringInFrench = stringInFrench.replace('è', 'e');
            }
            if (stringInFrench.contains('Ù')) {
                stringInFrench = stringInFrench.replace('Ù', 'U');
            }
            if (stringInFrench.contains('Ë')) {
                stringInFrench = stringInFrench.replace('Ë', 'E');
            }
            if (stringInFrench.contains('ë')) {
                stringInFrench = stringInFrench.replace('ë', 'e');
            }
            if (stringInFrench.contains('Ï')) {
                stringInFrench = stringInFrench.replace('Ï', 'I');
            }
            if (stringInFrench.contains('ï')) {
                stringInFrench = stringInFrench.replace('ï', 'i');
            }
            if (stringInFrench.contains('Ü')) {
                stringInFrench = stringInFrench.replace('Ü', 'U');
            }
            if (stringInFrench.contains('ü')) {
                stringInFrench = stringInFrench.replace('ü', 'u');
            }
        }

        return stringInFrench;
    }


    /*******************************************************************************
    *  Name            : replaceDutchCharacters(String stringInDutch)
    *  Summary         : Replace Á, á, É, é, Í, í, Ó, ó, Ú, ú, À, à, È, è, Ï, ï, Ö, ö, Ü, ü
    *  CreatedDate     : 26/06/2018
    *  ModifiedDate    : -
    *  Parameters      : String stringInDutch - string with country specific letters
    *  Returns         : String
    ******************************************************************************/
    public static String replaceDutchCharacters(String stringInDutch) {
        if (stringInDutch != null) {
            if (stringInDutch.contains('Á')) {
                stringInDutch = stringInDutch.replace('Á', 'A');
            }
            if (stringInDutch.contains('á')) {
                stringInDutch = stringInDutch.replace('á', 'a');
            }
            if (stringInDutch.contains('É')) {
                stringInDutch = stringInDutch.replace('É', 'E');
            }
            if (stringInDutch.contains('é')) {
                stringInDutch = stringInDutch.replace('é', 'e');
            }
            if (stringInDutch.contains('Í')) {
                stringInDutch = stringInDutch.replace('Í', 'I');
            }
            if (stringInDutch.contains('í')) {
                stringInDutch = stringInDutch.replace('í', 'i');
            }
            if (stringInDutch.contains('Ó')) {
                stringInDutch = stringInDutch.replace('Ó', 'O');
            }
            if (stringInDutch.contains('ó')) {
                stringInDutch = stringInDutch.replace('ó', 'o');
            }
            if (stringInDutch.contains('Ú')) {
                stringInDutch = stringInDutch.replace('Ú', 'U');
            }
            if (stringInDutch.contains('ú')) {
                stringInDutch = stringInDutch.replace('ú', 'u');
            }
            if (stringInDutch.contains('À')) {
                stringInDutch = stringInDutch.replace('À', 'A');
            }
            if (stringInDutch.contains('à')) {
                stringInDutch = stringInDutch.replace('à', 'a');
            }
            if (stringInDutch.contains('È')) {
                stringInDutch = stringInDutch.replace('È', 'E');
            }
            if (stringInDutch.contains('è')) {
                stringInDutch = stringInDutch.replace('è', 'e');
            }
            if (stringInDutch.contains('Ï')) {
                stringInDutch = stringInDutch.replace('Ï', 'I');
            }
            if (stringInDutch.contains('ï')) {
                stringInDutch = stringInDutch.replace('ï', 'i');
            }
            if (stringInDutch.contains('Ö')) {
                stringInDutch = stringInDutch.replace('Ö', 'O');
            }
            if (stringInDutch.contains('ö')) {
                stringInDutch = stringInDutch.replace('ö', 'o');
            }
            if (stringInDutch.contains('Ü')) {
                stringInDutch = stringInDutch.replace('Ü', 'U');
            }
            if (stringInDutch.contains('ü')) {
                stringInDutch = stringInDutch.replace('ü', 'u');
            }
        }

        return stringInDutch;
    }


    /*******************************************************************************
    *  Name            : returnIndicationOrganisation(String indicationOrganisationCode)
    *  Summary         : Return Indication Organisation based on code.
    *  CreatedDate     : 18/04/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : String
    ******************************************************************************/
    public static String returnIndicationOrganisation(String indicationOrganisationCode) {
        if (indicationOrganisationCode == 'O') {
            return 'Onderneming'; // "Business"
        } else if (indicationOrganisationCode == 'V') {
            return 'Vereniging'; // "Association"
        } else if (indicationOrganisationCode == 'S') {
            return 'Stichting'; // Non-profit organisation
        } else if (indicationOrganisationCode == 'K') {
            return 'Kerkgenootschap'; // Church community
        }

        return null;
    }
}