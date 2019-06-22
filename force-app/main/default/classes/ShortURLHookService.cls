public class ShortURLHookService {

    public static final String COUNTRY_DE = 'Germany';
    public static final String COUNTRY_PL = 'Poland';
    public static Map<String, LongFormPage> pagesMap;
    private static final Integer cache_ttl = 172800; // 48 hours
    private static Cache.OrgPartition orgcache = null;

    public static final String sourceQR = 'QR Code';
    public static final String sourceSMS = 'SMS';
    public static final String sourceTablet = 'Tablet';
    public static final String sourceURL = 'URL';

    private static Cache.OrgPartition cache(){
        if(orgcache == null)
            orgcache = Cache.Org.getPartition('local.shortlinkcache');
        return orgcache;
    }

    // used during tablet's screen first initialization
    @Future
    public static void preMakeOpp(String obn,Integer maxOppBuffer,String country){
        if(obn==null||maxOppBuffer==null)
            return;
        String key = country+obn;
        String link = getShortLinkId(null,obn,true,sourceTablet,country);
        if(link!=null){
            List<String> previous_opps = (List<String>)cache().get(key);
            if(previous_opps!=null&&previous_opps.size()>=maxOppBuffer)
                return;
            if(previous_opps == null){
                cache().put(key,new List<String>{link},cache_ttl);
            }
            else{
                previous_opps.add(link);
                cache().put(key,previous_opps,cache_ttl);
            }
        }
    }


    private static String getCachedLink(String obn,String country){
        String linkid = null;
        String key = country+obn;
        List<String> opps = (List<String>)cache().get(key);
        if(opps!=null&&!opps.isEmpty()){
            linkid = opps.get(0);
            opps.remove(0);
            cache().put(key,opps);
            preMakeOpp(obn,1,country);
        }
        return linkid;
    }

    public static String getShortLinkId(String client_number, String obnNumber,boolean isFuture,String client_source,String country){

        Boolean useCache = (client_source==sourceTablet&&!isFuture&&obnNumber!=null);
        if(useCache){
            String cachedlink = getCachedLink(obnNumber,country);
            if(cachedlink!=null)
                return cachedlink;
        }

        switch on country {
            when 'Germany' {
                return getShortLinkIdDE(client_number, obnNumber, isFuture, client_source, useCache);
            }
            when 'Poland' {
                return getShortLinkIdPL(client_number, obnNumber, isFuture, client_source, useCache);
            }
            when else {
                return null;
            }
        }

    }

    public static String getShortLinkIdDE(String client_number, String obnNumber,boolean isFuture,String client_source,boolean useCache) {


        String tempLongFormName;
        if (client_number == null) {
            Decimal random = Integer.valueOf(Math.random() * 100000000);
            tempLongFormName = 'LongForm:' + obnNumber + '_' + String.valueOf(random);
        } else {
            tempLongFormName = 'LongForm: ' + client_number;
            // check for existing sms request
            List<Opportunity> checkExistingOpportunity = [SELECT E2E_Short_Link__c FROM Opportunity WHERE Name = :tempLongFormName AND E2E_Short_Link__c != NULL LIMIT 1];
            if (!checkExistingOpportunity.isEmpty())
                return checkExistingOpportunity.get(0).E2E_Short_Link__c;
        }

        LFContactDetails contactDetailsService = LongFormGlobalUtils.returnContactDetailsService(COUNTRY_DE);
        contactDetailsService.setPagesMap('Desktop');
        pagesMap = contactDetailsService.getPagesMap();
        List<LongForm_Element_Item__c> ecoFee = [
                SELECT Value__c
                FROM LongForm_Element_Item__c
                WHERE Long_Form_Element__r.Long_Form_Page__r.Name = 'ADDITIONAL' AND
                Long_Form_Element__r.Name = 'CO2 TAKE CARE' AND
                Name = 'VALUE' AND
                Long_Form_Element__r.Long_Form_Page__r.Long_Form__r.Country__c = :COUNTRY_DE
                LIMIT 1];
        Boolean isEcoFee = false;
        if ( ! ecoFee.isEmpty() ) {
            isEcoFee = Boolean.valueOf(ecoFee.get(0).Value__c);
        }

        String esi;
        Account station;
        String homestation;

        List<Account> checkRetailer = [SELECT BillingStreet,BillingCity,BillingCountry FROM Account WHERE BillingCountry = :COUNTRY_DE AND OBN__c != null AND OBN__c = :obnNumber ORDER BY CreatedDate DESC LIMIT 1];
        if ( ! checkRetailer.isEmpty() ) {
            esi = obnNumber;
            station = checkRetailer.get(0);
            homestation = station.BillingStreet +', '+station.BillingCity+', '+station.BillingCountry;
            if(useCache)
                preMakeOpp(obnNumber,1,COUNTRY_DE);
        }

        // Account creation
        List<RecordType> accountRecordTypeList = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Endkunde' LIMIT 1];
        Account account = new Account(
                Name = tempLongFormName,
                BillingCountry = COUNTRY_DE,
                ShippingCountry = COUNTRY_DE,
                Partner_OBN__c = esi,
                Type = 'Customer',
                E2E__c = true);
        if ( ! accountRecordTypeList.isEmpty() ) account.RecordTypeId = accountRecordTypeList.get(0).Id;
        insert account;

        // Opportunity creation
        List<RecordType> opptyRecordTypeList = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'Euroshell' LIMIT 1];
        Opportunity opportunity = new Opportunity(
                Name = tempLongFormName,
                ESI__c = esi,
                Home_Station__c = homestation,
                StageName = 'Prospecting',
                Product__c = 'Inbound Typ C',
                AccountId = account.Id,
                CloseDate = Date.today(),
                Language_preference__c = 'German',
                Primary_Contact_Phone__c = client_number,
                Agree_to_Privacy_Policy__c = Boolean.valueOf(pagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c),
                Date_for_Agree_to_Privacy_Policy__c = Datetime.now(),
                E2E__c = true,
                Sec_Channel__c = 'JITB',
                Channel__c = 'POS',
                LeadSource = client_source,
                CurrencyIsoCode = 'EUR',
                Type = 'New Business',
                //Device_Type__c = deviceView,
                Eco_Fee__c = isEcoFee,
                AGB_Datenschutzhinweise_Richtigkeit__c = false,
                E2E_Form_of_Business__c = pagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c,
                E2E_Active_Step__c = 0,
                E2E_Status__c = 'In progress',
                E2E_Sales_Type__c = 'Fully E2E');
        if ( ! opptyRecordTypeList.isEmpty() ) opportunity.RecordTypeId = opptyRecordTypeList.get(0).Id;
        insert opportunity;

        // Contact creation
        List<RecordType> contactRecordTypeList = [SELECT Id FROM RecordType WHERE SobjectType = 'Contact' AND DeveloperName = 'Contact_layout' LIMIT 1];
        Contact contact = new Contact(
                Salutation = pagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c,
                LastName = tempLongFormName,
                AccountId = account.Id,
                Phone = client_number,
                Authorised_signatory__c = false,
                E2E__c = true,
                MailingCountry = COUNTRY_DE);
        if ( ! contactRecordTypeList.isEmpty() ) contact.RecordTypeId = contactRecordTypeList.get(0).Id;
        insert contact;

        // create contact role
        OpportunityContactRole oppContactRole = new OpportunityContactRole(
                OpportunityId = opportunity.Id,
                ContactId = contact.Id,
                IsPrimary = true);
        insert oppContactRole;

        if (station != null) {
            Partner newPartner = new Partner();
            newPartner.AccountToId = station.Id;
            newPartner.OpportunityId = opportunity.Id;
            newPartner.Role = 'Multiplier';
            insert newPartner;
        }

        opportunity.E2E_Short_Link__c = generateShortId(obnNumber, opportunity.Id);
        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EForm');
        opportunity.SEPA_Mandate_URL__c = LongFormGlobalUtils.generateOppWithSepaUrl(opportunity, 'E2EForm');
        if(!isFuture)
            opportunity.E2E_Last_Activity__c = Datetime.now();
        update opportunity;

        if(client_number==null){  // url/qr user
            if(esi!=null)
                return opportunity.E2E_Encoded_URL__c;
            return null;
        }
        return opportunity.E2E_Short_Link__c;
    }

    public static String getShortLinkIdPL(String client_number, String obnNumber,boolean isFuture,String client_source,Boolean useCache) {

        String tempLongFormName;
        if (client_number == null) {
            Decimal random = Integer.valueOf(Math.random() * 100000000);
            tempLongFormName = 'LongForm:' + obnNumber + '_' + String.valueOf(random);
        } else {
            tempLongFormName = 'LongForm: ' + client_number;
            // check for existing sms request
            List<Opportunity> checkExistingOpportunity = [SELECT E2E_Short_Link__c FROM Opportunity WHERE Name = :tempLongFormName AND E2E_Short_Link__c != NULL LIMIT 1];
            if (!checkExistingOpportunity.isEmpty())
                return checkExistingOpportunity.get(0).E2E_Short_Link__c;
        }

        LFContactDetails contactDetailsService = LongFormGlobalUtils.returnContactDetailsService(COUNTRY_PL);
        contactDetailsService.setPagesMap('Desktop');
        pagesMap = contactDetailsService.getPagesMap();
        List<LongForm_Element_Item__c> ecoFee = [
                SELECT Value__c
                FROM LongForm_Element_Item__c
                WHERE Long_Form_Element__r.Long_Form_Page__r.Name = 'ADDITIONAL' AND Long_Form_Element__r.Name = 'ADDITIONAL SERVICE #1' AND Name = 'AGREEMENT CHECKBOX VALUE'
                LIMIT 1];
        Boolean isEcoFee = false;
        if ( ! ecoFee.isEmpty() ) {
            isEcoFee = Boolean.valueOf(ecoFee.get(0).Value__c);
        }

        String esi;
        Account station;
        String homestation;

        List<Account> checkRetailer = [SELECT BillingStreet,BillingCity,BillingCountry FROM Account WHERE BillingCountry = :COUNTRY_PL AND OBN__c != null AND OBN__c = :obnNumber ORDER BY CreatedDate DESC LIMIT 1];
        if ( ! checkRetailer.isEmpty() ) {
            esi = obnNumber;
            station = checkRetailer.get(0);
            homestation = station.BillingStreet +', '+station.BillingCity+', '+station.BillingCountry;
            if(useCache)
                preMakeOpp(obnNumber,1,COUNTRY_PL);
        }

        // Account creation
        List<RecordType> accountRecordTypeList = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Endkunde' LIMIT 1];
        Account account = new Account(
                Name = tempLongFormName,
                BillingCountry = COUNTRY_PL,
                ShippingCountry = COUNTRY_PL,
                Type = 'Customer',
                E2E__c = true);
        if ( ! accountRecordTypeList.isEmpty() ) account.RecordTypeId = accountRecordTypeList.get(0).Id;
        insert account;

        // Opportunity creation
        List<RecordType> opptyRecordTypeList = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'Euroshell' LIMIT 1];
        Opportunity opportunity = new Opportunity(
                Name = tempLongFormName,
                ESI__c = esi,
                Home_Station__c = homestation,
                StageName = 'Prospecting',
                Product__c = 'Shell Standard 2019',
                AccountId = account.Id,
                CloseDate = Date.today(),
                Language_preference__c = 'Polish',
                Primary_Contact_Phone__c = client_number,
                Agree_to_process_pers_data_for_marketing__c = Boolean.valueOf(pagesMap.get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c),
                Agree_to_telephone_contact__c = Boolean.valueOf(pagesMap.get('CONTACT DETAILS').fields.get('PHONE CONTACT AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c),
                Agree_to_receive_comm_info_by_email__c = Boolean.valueOf(pagesMap.get('CONTACT DETAILS').fields.get('RECEIVE COMM INFO BY EMAIL AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c),
                E2E__c = true,
                Sec_Channel__c = 'JITB',
                Channel__c = 'POS',
                LeadSource = client_source,
                CurrencyIsoCode = 'PLN',
                Type = 'New Business',
                //Device_Type__c = deviceView,
                Eco_Fee__c = isEcoFee,
                AGB_Datenschutzhinweise_Richtigkeit__c = false,
                E2E_Form_of_Business__c = pagesMap.get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c,
                E2E_Active_Step__c = 0,
                E2E_Status__c = 'In progress',
                E2E_Sales_Type__c = 'Fully E2E');
        if ( ! opptyRecordTypeList.isEmpty() ) opportunity.RecordTypeId = opptyRecordTypeList.get(0).Id;
        insert opportunity;

        // Contact creation
        List<RecordType> contactRecordTypeList = [SELECT Id FROM RecordType WHERE SobjectType = 'Contact' AND DeveloperName = 'Contact_layout' LIMIT 1];
        Contact contact = new Contact(
                Salutation = pagesMap.get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c,
                LastName = tempLongFormName,
                AccountId = account.Id,
                Phone = client_number,
                Authorised_signatory__c = false,
                E2E__c = true,
                MailingCountry = COUNTRY_PL);
        if ( ! contactRecordTypeList.isEmpty() ) contact.RecordTypeId = contactRecordTypeList.get(0).Id;
        insert contact;

        // create contact role
        OpportunityContactRole oppContactRole = new OpportunityContactRole(
                OpportunityId = opportunity.Id,
                ContactId = contact.Id,
                IsPrimary = true);
        insert oppContactRole;

        if (station != null) {
            Partner newPartner = new Partner();
            newPartner.AccountToId = station.Id;
            newPartner.OpportunityId = opportunity.Id;
            newPartner.Role = 'Multiplier';
            insert newPartner;
        }

        opportunity.E2E_Short_Link__c = generateShortId(obnNumber, opportunity.Id);
        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EForm');
        opportunity.SEPA_Mandate_URL__c = LongFormGlobalUtils.generateOppWithSepaUrl(opportunity, 'E2EForm');
        if(!isFuture)
            opportunity.E2E_Last_Activity__c = Datetime.now();
        update opportunity;

        if(client_number==null){  // url/qr user
            if(esi!=null)
                return opportunity.E2E_Encoded_URL__c;
            return null;
        }
        return opportunity.E2E_Short_Link__c;
    }


    /*******************************************************************************
    *  Name            : generateShortId(String obnNumber, Id oppId)
    *  Summary         : Generate short link id based on OBN and opportunity id
    *  CreatedDate     : 03/09/2018
    *  ModifiedDate    : 10/09/2018 - by Eugene. Change access to public due to new functionality (short link generation for JITB partners and fax).
    *  Parameters      : obnNumber – station OBN, oppId - opportunity id
    *  Returns         : String – generated code
    ******************************************************************************/
    public static String generateShortId(String obnNumber, Id oppId) {
        E2E_Short_Url__c e2eShortUrlDetail = E2E_Short_Url__c.getInstance('Germany');
        String finalParam;
        if (obnNumber != null) {
            finalParam = String.valueOf(obnNumber + oppId);
        } else {
            finalParam = String.valueOf(oppId);
        }
        String shortid = EncodingUtil.urlEncode(
                EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES128',
                        Blob.valueOf(e2eShortUrlDetail.Private_Key__c),
                        Blob.valueOf(finalParam))), 'UTF-8')
                .replace('%', '').substring(1, 7);
        return shortid;
    }
}