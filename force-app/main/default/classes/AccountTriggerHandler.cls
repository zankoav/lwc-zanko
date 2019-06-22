public class AccountTriggerHandler {
    public static Boolean enablesTrigger = true;
    public static Boolean enablesBeforeUpdateTrigger = true;
    public static Boolean enablesBeforeInsertTrigger = true;
    public static Boolean enablesAfterUpdateTrigger = true;
    public static Boolean isParent = true;
    public static Boolean isChild;
    public static Map<Id, Opportunity> oldOpportunityMap;

    public static void setRecordType(List<Account> newList) {
        List<RecordType> recordTypesList = [
                SELECT Name
                FROM RecordType
                WHERE (Name = 'AllStar' OR Name = 'Russian') AND
                sObjectType = 'Account'
                LIMIT 100
        ];
        Map<String, RecordType> recordTypesMap = new Map<String, RecordType>();
        for (RecordType rt : recordTypesList) {
            recordTypesMap.put(rt.Name, rt);
        }

        if (!recordTypesMap.isEmpty()) {
            for (Account acc : newList) {
                if (acc.Lead_Record_Type__c == 'AllStar' && recordTypesMap.containsKey('AllStar')) {
                    acc.RecordTypeId = recordTypesMap.get('AllStar').Id;
                } else if (acc.Lead_Record_Type__c == 'Russian Sales' && recordTypesMap.containsKey('Russian')) {
                    acc.RecordTypeId = recordTypesMap.get('Russian').Id;
                }
            }
        }
    }

    public static void maketouppercase(List<Account> newList) {
        for (Account a : newList) {
            if (a.Name != null) {
                a.Name = a.Name.touppercase();
            }

            if (a.Firmenname2_Zusatz__c != null) {
                a.Firmenname2_Zusatz__c = a.Firmenname2_Zusatz__c.touppercase();
            }

            if (a.BillingStreet != null) {
                a.BillingStreet = a.BillingStreet.touppercase();
            }

            if (a.ShippingStreet != null) {
                a.ShippingStreet = a.ShippingStreet.touppercase();
            }

            if (a.BillingCity != null) {
                a.BillingCity = a.BillingCity.touppercase();
            }

            if (a.ShippingCity != null) {
                a.ShippingCity = a.ShippingCity.touppercase();
            }
        }
    }

    public static void parentChildDefinition(List<Account> accountsList) {
        for (Account account : accountsList) {
            if (account.ParentId == null) {
                isChild = true;
                isParent = false;
            } else {
                isChild = false;
            }
        }
    }

    public static void updateChild(Map<Id, Account> oldMap, Map<Id, Account> newMap) {
        Set<Id> recordTypeEuroshellSet = new Set<Id>();
        if (GlobalUtils.returnRecordTypeId('Account', 'AllStar') != null) recordTypeEuroshellSet.add(GlobalUtils.returnRecordTypeId('Account', 'AllStar'));
        if (GlobalUtils.returnRecordTypeId('Account', 'CCS') != null) recordTypeEuroshellSet.add(GlobalUtils.returnRecordTypeId('Account', 'CCS'));
        if (GlobalUtils.returnRecordTypeId('Account', 'Endkunde') != null) recordTypeEuroshellSet.add(GlobalUtils.returnRecordTypeId('Account', 'Endkunde'));
        if (GlobalUtils.returnRecordTypeId('Account', 'Endkunde PL and HU') != null) recordTypeEuroshellSet.add(GlobalUtils.returnRecordTypeId('Account', 'Endkunde PL and HU'));
        if (GlobalUtils.returnRecordTypeId('Account', 'Flexcard') != null) recordTypeEuroshellSet.add(GlobalUtils.returnRecordTypeId('Account', 'Flexcard'));
        if (GlobalUtils.returnRecordTypeId('Account', 'Retailer') != null) recordTypeEuroshellSet.add(GlobalUtils.returnRecordTypeId('Account', 'Retailer'));
        if (GlobalUtils.returnRecordTypeId('Account', 'WinBack') != null) recordTypeEuroshellSet.add(GlobalUtils.returnRecordTypeId('Account', 'WinBack'));
        Set<Id> parentAccountsId = new Set<Id>();
        for (Account parentAccount : newMap.values()) {
            if (parentAccount.Last_contact_date__c != oldMap.get(parentAccount.Id).Last_contact_date__c &&
                    recordTypeEuroshellSet.contains(parentAccount.RecordTypeId)) {
                parentAccountsId.add(parentAccount.Id);
            }
        }
        if (!parentAccountsId.isEmpty()) {
            List<Account> childAccountsList = [
                    SELECT ParentId
                    FROM Account
                    WHERE ParentId IN :parentAccountsId
            ];
            List<Account> childAccountsToUpdateList = new List<Account>();
            for (Account childAccount : childAccountsList) {
                childAccount.Last_contact_date__c = newMap.get(childAccount.ParentId).Last_contact_date__c;
                childAccountsToUpdateList.add(childAccount);
            }
            update childAccountsToUpdateList;
        }
    }


    public static void updateParent(Map<Id, Account> oldMap, Map<Id, Account> newMap) {
        Set<Id> recordTypeEuroshellSet = new Set<Id>();
        if (GlobalUtils.returnRecordTypeId('Account', 'AllStar') != null) recordTypeEuroshellSet.add(GlobalUtils.returnRecordTypeId('Account', 'AllStar'));
        if (GlobalUtils.returnRecordTypeId('Account', 'CCS') != null) recordTypeEuroshellSet.add(GlobalUtils.returnRecordTypeId('Account', 'CCS'));
        if (GlobalUtils.returnRecordTypeId('Account', 'Endkunde') != null) recordTypeEuroshellSet.add(GlobalUtils.returnRecordTypeId('Account', 'Endkunde'));
        if (GlobalUtils.returnRecordTypeId('Account', 'Endkunde PL and HU') != null) recordTypeEuroshellSet.add(GlobalUtils.returnRecordTypeId('Account', 'Endkunde PL and HU'));
        if (GlobalUtils.returnRecordTypeId('Account', 'Flexcard') != null) recordTypeEuroshellSet.add(GlobalUtils.returnRecordTypeId('Account', 'Flexcard'));
        if (GlobalUtils.returnRecordTypeId('Account', 'Retailer') != null) recordTypeEuroshellSet.add(GlobalUtils.returnRecordTypeId('Account', 'Retailer'));
        if (GlobalUtils.returnRecordTypeId('Account', 'WinBack') != null) recordTypeEuroshellSet.add(GlobalUtils.returnRecordTypeId('Account', 'WinBack'));
        Map<Id, Id> childToParentMap = new Map<Id, Id>();
        for (Account childAccount : newMap.values()) {
            if (childAccount.Last_contact_date__c != oldMap.get(childAccount.Id).Last_contact_date__c &&
                    recordTypeEuroshellSet.contains(childAccount.RecordTypeId)) {
                childToParentMap.put(childAccount.Id, childAccount.ParentId);
            }
        }

        if (!childToParentMap.isEmpty()) {
            List<Account> parentAccountsToUpdate = new List<Account>();
            for (Id childAccountId : childToParentMap.keySet()) {
                Account parentAccount = new Account(
                        Id = childToParentMap.get(childAccountId),
                        Last_contact_date__c = newMap.get(childAccountId).Last_contact_date__c);
                parentAccountsToUpdate.add(parentAccount);
            }
            update parentAccountsToUpdate;
        }
    }


    /*******************************************************************************
    *  Name            : updateBeforeLastOwnerChangeDateRUS()
    *  Summary         : update account, set Last_Date_Change_Owner_RUS__c to Opportunity
    *  CreatedDate     : 20.11.2017
    *  Parameters      : Map<Id, Account> oldMap, Map<Id, Account> newMap
    *  Returns         : -
    ******************************************************************************/
    public static void updateBeforeLastOwnerChangeDateRUS(Map<Id, Account> oldMap, Map<Id, Account> newMap) {
        Set<Id> idRecordTypeRussianSales = getRussianSalesRecordType();
        Set<Id> accSetB = new Set<Id>();
        for (Account acc : newMap.values()) {
            if (idRecordTypeRussianSales.contains(acc.RecordTypeId) && acc.OwnerId != oldMap.get(acc.Id).OwnerId) {
                accSetB.add(acc.Id);
            }
        }

        if (!accSetB.isEmpty()) {
            oldOpportunityMap = new Map<Id, Opportunity>();
            for (Opportunity o : [
                    SELECT Id, OwnerId, Last_Owner_Change_Date_RUS__c
                    FROM Opportunity
                    WHERE AccountId IN :oldMap.keySet()
            ]) {
                oldOpportunityMap.put(o.Id, o);
            }
        }
    }

    /*******************************************************************************
    *  Name            : updateLastDateChangeOwnerRUSOpportunityAndOpenTaskCheckBox()
    *  Summary         : update account, set Last_Date_Change_Owner_RUS__c to Opportunity
    *  CreatedDate     : 20.11.2017
    *  UpdateDate      : 11.05.2018
    *  UpdateBy        : Nikita Mikhailov
    *  Parameters      : Map<Id, Account> oldMap, Map<Id, Account> newMap
    *  Returns         : -
    ******************************************************************************/
    public static void updateLastDateChangeOwnerRUSOpportunityAndOpenTaskCheckBox(Map<Id, Account> oldMap, Map<Id, Account> newMap) {

        Set<Id> idRecordTypeRussianSales = getRussianSalesRecordType();
        Set<Id> accSet = new Set<Id>();
        for (Account acc : newMap.values()) {
            if (idRecordTypeRussianSales.contains(acc.RecordTypeId) && acc.OwnerId != oldMap.get(acc.Id).OwnerId) {
                accSet.add(acc.Id);
            }
        }

        System.debug(accSet);

        if (!accSet.isEmpty()) {
            List<Opportunity> oppUpdateList = new List<Opportunity>();
            List<Opportunity> oppList = [
                    SELECT Id,
                            Last_Owner_Change_Date_RUS__c,
                            AccountId,
                            OwnerId,
                            isClosed,
                            Open_Task__c, (SELECT Id, OwnerId FROM Tasks WHERE IsClosed = false)
                    FROM Opportunity
                    WHERE AccountId IN :accSet
            ];

            System.debug(oppList);

            for (Opportunity opp : oppList) {

                if (oldOpportunityMap.get(opp.Id).OwnerId != opp.OwnerId) {

                    if (opp.Tasks.size() > 0) {
                        opp.Open_Task__c = false;
                        for (Task task : opp.Tasks) {
                            If (task.OwnerId.equals(opp.OwnerId)) {
                                opp.Open_Task__c = true;
                                break;
                            }
                        }
                    }


                    opp.Last_Owner_Change_Date_RUS__c = Datetime.now();
                    oppUpdateList.add(opp);
                }
            }
            System.debug(oppUpdateList);
            update oppUpdateList;
        }
    }

    /*******************************************************************************
    *  Name            : getRussianSalesRecordType()
    *  Summary         : return set of RecordType for Russia
    *  CreatedDate     : 20.11.2017
    *  Parameters      : -
    *  Returns         : result
    ******************************************************************************/
    public static Set<Id> getRussianSalesRecordType() {
        Set<id> result = new Set<id>();
        if (Schema.SObjectType.Account.getRecordTypeInfosByName().get('Российские') != null) {
            result.add(Schema.SObjectType.Account.getRecordTypeInfosByName().get('Российские').getRecordTypeId());
        } else if (Schema.SObjectType.Account.getRecordTypeInfosByName().get('Russian') != null) {
            result.add(Schema.SObjectType.Account.getRecordTypeInfosByName().get('Russian').getRecordTypeId());
        }
        return result;
    }


    /*******************************************************************************
    *  Name            : updateCurrencyIsoCode()
    *  Summary         : Update the CurrencyIsoCode in Opportunity
    *  CreatedDate     : 02-03-2018
    *  ModifiedDate    : -
    *  Parameters      : Map<Id, Account> oldMap, Map<Account> newList
    *  Returns         : void
    ******************************************************************************/
    public static void updateCurrencyIsoCode(Map<Id, Account> oldMap, List<Account> newList) {
        // after update
        Set<String> accountIdsSet = new Set<String>();
        for (Account acc : newList) {
            if (acc.BillingCountry != null && CountryToCurrencyIsoCodeMap.containsKey(acc.BillingCountry)) {
                accountIdsSet.add(acc.Id);
            }
        }
        if (!accountIdsSet.isEmpty()) {
            List<Opportunity> opportunitiesList = [
                    SELECT CurrencyIsoCode, Account.BillingCountry, Account.Id
                    FROM Opportunity
                    WHERE AccountId IN :accountIdsSet
                    LIMIT 50000
            ];

            List<Opportunity> opportunityToUpdateList = new List<Opportunity>();
            for (Opportunity opp : opportunitiesList) {
                if (opp.Account.BillingCountry != oldMap.get(opp.Account.Id).BillingCountry) {
                    opp.CurrencyIsoCode = CountryToCurrencyIsoCodeMap.get(opp.Account.BillingCountry);
                    opportunityToUpdateList.add(opp);
                }
            }

            if (!opportunityToUpdateList.isEmpty()) {
                update opportunityToUpdateList;
            }
        }
    }


    /*******************************************************************************
    *  Name            : setFive9Phone(Map<Id, Account> oldMap, List<Account> newList)
    *  Summary         : Set Phone in E.164 format
    *  CreatedDate     : 30/03/2018
    *  ModifiedDate    : 30/03/2018
    *  Parameters      : oldMap, newMap – maps from the trigger
    *  Returns         : void
    ******************************************************************************/
    public static void setValidPhone(Map<Id, Account> oldMap, List<Account> newList) {
        for (Account account : newList) {
            if (account.BillingCountryCode != null) {
                if (oldMap != null) {
                    // before update
                    if (account.Phone != null && oldMap.get(account.Id).Phone != account.Phone) {
                        account.Phone = ClickToCallHandler.returnValidNumber(account.Phone, account.BillingCountryCode);
                    }
                    if (account.Fax != null && oldMap.get(account.Id).Fax != account.Fax) {
                        account.Fax = ClickToCallHandler.returnValidNumber(account.Fax, account.BillingCountryCode);
                    }
                    if (account.CM_mobile__c != null && oldMap.get(account.Id).CM_mobile__c != account.CM_mobile__c) {
                        account.CM_mobile__c = ClickToCallHandler.returnValidNumber(account.CM_mobile__c, account.BillingCountryCode);
                    }
                    if (account.Phone_Crif__c != null && oldMap.get(account.Id).Phone_Crif__c != account.Phone_Crif__c) {
                        account.Phone_Crif__c = ClickToCallHandler.returnValidNumber(account.Phone_Crif__c, account.BillingCountryCode);
                    }
                    if (account.SM_mobile__c != null && oldMap.get(account.Id).SM_mobile__c != account.SM_mobile__c) {
                        account.SM_mobile__c = ClickToCallHandler.returnValidNumber(account.SM_mobile__c, account.BillingCountryCode);
                    }
                    if (account.TM_mobile__c != null && oldMap.get(account.Id).TM_mobile__c != account.TM_mobile__c) {
                        account.TM_mobile__c = ClickToCallHandler.returnValidNumber(account.TM_mobile__c, account.BillingCountryCode);
                    }
                }
                if (OldMap == null) {
                    // before insert
                    if (account.Phone != null) {
                        account.Phone = ClickToCallHandler.returnValidNumber(account.Phone, account.BillingCountryCode);
                    }
                    if (account.Fax != null) {
                        account.Fax = ClickToCallHandler.returnValidNumber(account.Fax, account.BillingCountryCode);
                    }
                    if (account.CM_mobile__c != null) {
                        account.CM_mobile__c = ClickToCallHandler.returnValidNumber(account.CM_mobile__c, account.BillingCountryCode);
                    }
                    if (account.Phone_Crif__c != null) {
                        account.Phone_Crif__c = ClickToCallHandler.returnValidNumber(account.Phone_Crif__c, account.BillingCountryCode);
                    }
                    if (account.SM_mobile__c != null) {
                        account.SM_mobile__c = ClickToCallHandler.returnValidNumber(account.SM_mobile__c, account.BillingCountryCode);
                    }
                    if (account.TM_mobile__c != null) {
                        account.TM_mobile__c = ClickToCallHandler.returnValidNumber(account.TM_mobile__c, account.BillingCountryCode);
                    }
                }
            }
        }
    }


    /*******************************************************************************
    *  Name            : addErrorMessageForSalesTeam()
    *  Summary         : Don't allow sales team to change Account fields for 3 months after Closed Won Opportunity.
    *  CreatedDate     : 19/04/2018
    *  ModifiedDate    : 22/03/2019
    *  Parameters      : oldMap, newList from the trigger
    *  Returns         : void
    ******************************************************************************/
    public static void addErrorMessageForSalesTeam(Map<Id, Account> oldMap, Map<Id, Account> newMap) {
        // before update
        String userId = UserInfo.getUserId();
        List<User> currentUser = [SELECT Profile.Name FROM User WHERE Id = :userId LIMIT 1];

        if (salesTeamProfileSet.contains(currentUser.get(0).Profile.Name)) {
            String fieldsStringForSQOL = '';
            for (Account_fields_after_Closed_Won__c field : Account_fields_after_Closed_Won__c.getAll().values()) {
                fieldsStringForSQOL += field.Field_Name__c + ',';
            }
            Set<Id> accountsIdsSet = newMap.keySet();
            String soql = '' +
                    ' SELECT ' + fieldsStringForSQOL +
                            ' (SELECT StageName, CloseDate' + 
                            ' FROM Opportunities' + 
                            ' WHERE StageName = \'Closed Won\' AND RecordType.Name != \'Carnet\')' + 
                    ' FROM Account' + 
                    ' WHERE Id IN :accountsIdsSet AND RecordType.Name = \'Endkunde\'';

            List<Account> accountsList = Database.query(soql);

            if (! accountsList.isEmpty()) {
                for (Account acc : accountsList) {
                    Boolean isChanged = false;
                    for (Account_fields_after_Closed_Won__c field : Account_fields_after_Closed_Won__c.getAll().values()) {
                        if (newMap.get(acc.Id).get(field.Field_Name__c) != oldMap.get(acc.Id).get(field.Field_Name__c)) {
                            isChanged = true;
                            break;
                        }
                    }

                    if (! isChanged) {
                        for (Opportunity opp : acc.Opportunities) {
                            Integer daysAfterClosedDate = (Date.valueOf(opp.CloseDate)).daysBetween(Date.today());
                            if (daysAfterClosedDate < 90) {
                                newMap.get(acc.Id).addError('You can\'t change Account fields for 3 months after Closed Won Opportunity');
                                return;
                            }
                        }
                    }
                }
            }
        }
    }


    /*******************************************************************************
    *  Name            : findDuplicateTaxId(Map<Id, Account> oldMap, List<Account> newList)
    *  Summary         : Find duplicate Tax ID and add error message if it's true
    *  CreatedDate     : 18/05/2018
    *  ModifiedDate    : -
    *  Parameters      : oldMap and newList from trigger
    *  Returns         : void
    ******************************************************************************/
    public static void findDuplicateTaxId(Map<Id, Account> oldMap, List<Account> newList) {
        Set<String> taxIdSet = new Set<String>();
        // before insert
        if (oldMap == null) {
            for (Account acc : newList) {
                if (acc.Steuernummer__c != null && acc.BillingCountryCode != null && acc.RecordType.Name != 'Russian' && ! acc.E2E__c) {
                    if (taxIdSet.contains(acc.Steuernummer__c)) {
                        acc.addError('You try to insert accounts with duplicates TAX ID.', false);
                        return;
                    } else {
                        taxIdSet.add(acc.Steuernummer__c);
                    }
                }
            }
        }
        // before update
        if (oldMap != null) {
            for (Account acc : newList) {
                if (acc.Steuernummer__c != null && acc.BillingCountryCode != null && acc.RecordType.Name != 'Russian' && ! acc.E2E__c &&
                        ((oldMap.get(acc.Id).Steuernummer__c != acc.Steuernummer__c) || oldMap.get(acc.Id).BillingCountryCode != acc.BillingCountryCode)) {
                    taxIdSet.add(acc.Steuernummer__c);
                }
            }
        }

        if ( ! taxIdSet.isEmpty()) {
            List<Account> duplicateTaxIDList = [
                    SELECT Id, Steuernummer__c, BillingCountryCode, Name
                    FROM Account
                    WHERE Steuernummer__c IN :taxIdSet
                    LIMIT 50000];

            Map<String, List<Account>> taxIdToAccListMap = new Map<String, List<Account>>();
            for (Account acc : duplicateTaxIDList) {
                if ( ! taxIdToAccListMap.containsKey(acc.Steuernummer__c)) {
                    taxIdToAccListMap.put(acc.Steuernummer__c, new List<Account>());
                }
                taxIdToAccListMap.get(acc.Steuernummer__c).add(acc);
            }

            if ( ! taxIdToAccListMap.isEmpty()) {
                for (Account acc : newList) {
                    if (taxIdToAccListMap.containsKey(acc.Steuernummer__c)) {
                        for (Account accInMap : taxIdToAccListMap.get(acc.Steuernummer__c)) {
                            if (accInMap.Steuernummer__c == acc.Steuernummer__c && accInMap.BillingCountryCode.substring(0, 2) == acc.BillingCountryCode.substring(0, 2)) {
                                String accountError = 'Duplicate Tax ID number is found. <a href=\'/' + accInMap.Id + '\' target=\'_blank\'>' + accInMap.Name + '</a>';

                                acc.addError(accountError, false);
                            }
                        }
                    }
                }
            }
        }
    }

    /*******************************************************************************
    *  Name            : sendRussianRequestForChangeAccountOwner
    *  Summary         : Send request for Change Account Owner for Russian Team Leader
    *  CreatedDate     : 19/07/2018
    *  ModifiedDate    : -
    *  Parameters      : oldMap and newList from trigger
    *  Returns         : void
    ******************************************************************************/
    public static void sendRussianRequestForChangeAccountOwner(Map<Id, Account> oldMap, Map<Id, Account> newMap) {
        Set<Id> idRecordTypeRussianSales = getRussianSalesRecordType();
        Map<Id, Id> blockChangeOwnerInAccounts = new Map<Id, Id>();
        for (Account account : newMap.values()) {
            if (idRecordTypeRussianSales.contains(account.recordTypeId) &&
                    account.OwnerId != oldMap.get(account.Id).ownerId) {
                blockChangeOwnerInAccounts.put(account.id, account.ownerid);
            }
        }

        if (blockChangeOwnerInAccounts.size() != 0) {
            List<User> currentUser = [
                    SELECT id, name, ManagerId, ProfileId
                    FROM User
                    WHERE id = :UserInfo.getUserId()
                    AND  Profile.Name = 'Russian Sales Manager'
                    AND ManagerId != null ];
            if (currentUser.size() == 1) {
                Map<Id, User> newOwnersMap = new Map<Id, User>([SELECT id, name FROM User where id = :blockChangeOwnerInAccounts.values()]);
                List<Messaging.Email> emails = new List<Messaging.Email>();
                for (Account newAccount : newMap.values()) {
                    if (blockChangeOwnerInAccounts.containsKey(newAccount.id)) {
                        if (newAccount.Moved_to_Start__c == 0) {
                            emails.add(EmailGenerator.prepareHtmlEmailToTarget(currentUser.get(0).id,
                                    'Запрос принят',
                                    '<p>Запрос на перевод организации  <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + newAccount.Id + '" > ' + newAccount.id + ' </a>, ' +
                                            'отправлен вашему Тим Лидеру(Менеджеру)</p> <p>Пожалуйста ожидайте ответа</p>'));
                            emails.add(EmailGenerator.prepareHtmlEmailToTarget(currentUser.get(0).ManagerId,
                                    'Запрос на перевод организации',
                                    '<p>Поступил запрос от ' + currentUser.get(0).Name + ' на перевод организации <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + newAccount.Id + '" > ' + newAccount.id + ' </a> на пользователя ' + newOwnersMap.get(newAccount.OwnerId).Name + ' </p>' +
                                            '<p>Для того чтобы подтвердить перевод организации, нажмите на кнопку "Подтвердить"</p>' +
                                            '<table border="0"> <tr> ' +
                                            '<th> <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/apex/ApprovePprRequestFromEmail?Type=004&Answer=yes&idRecord=' + newAccount.Id + '&idNewOwner=' + newAccount.OwnerId + '"> Подтвердить </a> </th> ' +
                                            '<th> <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/apex/ApprovePprRequestFromEmail?Type=004&Answer=no&idRecord=' + newAccount.Id + '&idNewOwner=' + newAccount.OwnerId + '"> Отклонить </a> </th> ' +
                                            '</tr> </table> '));
                        } else {
                            emails.add(EmailGenerator.prepareHtmlEmailToTarget(currentUser.get(0).id,
                                    'Запрос отклонен',
                                    '<p>Запрос на перевод организации "' + newAccount.name + '", отклонен. Т.к. Организация имеет возможность, которая "Принята на старт"</p>'));
                        }
                        Account oldAccount = oldMap.get(newAccount.id);
                        newAccount.OwnerId = oldAccount.OwnerId;
                    }
                }
                Messaging.sendEmail(emails);
            }
        }
    }
    
    public static Set<String> salesTeamProfileSet = new Set<String>{
            'Sales',
            'Sales Inbound',
            'Salesteamleiter',
            'Salesteamleiter Inbound',
            'Starts Team',
            'Starts Team Lead',
            'FleetcorEmea Profile'
    };


    public static Map<String, String> CountryToCurrencyIsoCodeMap = new Map<String, String>{
            'Austria' => 'EUR',
            'Belgium-FR' => 'EUR',
            'Belgium-NL' => 'EUR',
            'Czech Republic' => 'CZK',
            'Germany' => 'EUR',
            'Hungary' => 'HUF',
            'Luxembourg' => 'EUR',
            'Netherlands' => 'EUR',
            'Poland' => 'PLN',
            'Slovakia' => 'EUR',
            'Switzerland-DE' => 'CHF',
            'Switzerland-FR' => 'CHF',
            'Switzerland-IT' => 'CHF'
    };
}