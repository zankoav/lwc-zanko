@isTest
private class ShortURLHookServiceTest {

    // covers ShortURLHookService,LinkRedirectController

    public static final String COUNTRY_DE = 'Germany';
    public static final String COUNTRY_PL = 'Poland';
    final static String client_number = '+0000000000';
    final static String obnNumberDE = '000000';
    final static String obnNumberPL = 'R000001';
    final static String nonexisting_obnNumber = '0001000';
    final static String nonexisting_url = 'XXXXXXXXX'; //
    static String existing_short_urlDE;
    static String existing_encoded_urlDE;
    static String existing_short_urlPL;
    static String existing_encoded_urlPL;


    static{
        prepareRecordsDE();
        prepareRecordsPL();
    }

    static void prepareRecordsPL() {

        String base_url = Url.getSalesforceBaseUrl().toString();

        E2ELongFormUtilsTest.createLongForm('Poland');
        E2ELongFormUtilsTest.createLongFormMenu();
        E2ELongFormUtilsTest.createMenuItemForStep1('Desktop');
        E2ELongFormUtilsTest.createContactDeatilsData('Desktop');

        List<SObject> custom_settings = new List<SObject>();

        E2E_Form_General_Settings__c settingseE2EFormGeneral = new E2E_Form_General_Settings__c();
        settingseE2EFormGeneral.Name = 'Poland';
        settingseE2EFormGeneral.Enable_authorization_non_granted_check__c = false;
        settingseE2EFormGeneral.Files_Generator_Url__c = base_url;
        settingseE2EFormGeneral.Payment_URL__c = base_url;
        settingseE2EFormGeneral.Set_GFN_Status__c = false;
        settingseE2EFormGeneral.Test_Mode__c = false;
        custom_settings.add(settingseE2EFormGeneral);

        E2E_Short_Url__c settingsE2EShortUrl = new E2E_Short_Url__c();
        settingsE2EShortUrl.Name = 'Poland';
        settingsE2EShortUrl.Private_Key__c = '1234567890123456';
        settingsE2EShortUrl.Short_Url__c = base_url + '/i';
        settingsE2EShortUrl.E2E_Form_Url__c = base_url + '/e2eformpl';
        settingsE2EShortUrl.E2E_JITB_Form_Url__c = base_url + '/e2ejitblocator';
        custom_settings.add(settingsE2EShortUrl);

        E2EKeysAPI__c settingsEKeysAPI = new E2EKeysAPI__c();
        settingsEKeysAPI.Name = 'E2EForm';
        settingsEKeysAPI.AES256_Key__c = 'MTIzNDU2Nzg5MDEyMzQ1NjEyMzQ1Njc4OTAxMjM0NTY=';
        custom_settings.add(settingsEKeysAPI);

        insert custom_settings;

        String esi;
        Account station;
        String homestation;

        Account retailerAccount = new Account(
                OBN__c = obnNumberPL,
                Name = 'ValidOBN2',
                ShippingCountry = 'Poland',
                BillingCountry = 'Poland',
                BillingCity = 'Warsaw',
                BillingStreet = 'Strasse',
                Type = 'Customer',
                E2E__c = true);
        insert retailerAccount;


        List<Account> checkRetailer = [SELECT BillingStreet,BillingCity,BillingCountry FROM Account WHERE BillingCountry = :COUNTRY_PL AND OBN__c != null AND OBN__c = :obnNumberDE ORDER BY CreatedDate DESC LIMIT 1];
        if ( ! checkRetailer.isEmpty() ) {
            esi = obnNumberDE;
            station = checkRetailer.get(0);
            homestation = station.BillingStreet +', '+station.BillingCity+', '+station.BillingCountry;
        }

        String tempLongFormName;
        Decimal random = math.random() * 100000000;
        if (client_number == null) {
            tempLongFormName = 'LongForm:' + obnNumberDE + '_' + random;
        } else {
            tempLongFormName = 'LongForm: ' + client_number;
        }

        Account account = new Account(
                Name = tempLongFormName,
                BillingCountry = 'Poland',
                ShippingCountry = 'Poland',
                Type = 'Customer',
                E2E__c = true);
        insert account;

        // Opportunity creation
        Opportunity opportunity = new Opportunity(
                Name = tempLongFormName,
                ESI__c = esi,
                Home_Station__c = homestation,
                StageName = 'Prospecting',
                Product__c = '',
                AccountId = account.Id,
                CloseDate = Date.today(),
                Language_preference__c = 'Polish',
                Primary_Contact_Phone__c = client_number,
                Agree_to_Privacy_Policy__c = true,
                Date_for_Agree_to_Privacy_Policy__c = Datetime.now(),
                E2E__c = true,
                Sec_Channel__c = 'JITB',
                Channel__c = 'POS',
                LeadSource = 'SMS',
                CurrencyIsoCode = 'EUR',
                Type = 'New Business',
                //Device_Type__c = deviceView,
                Eco_Fee__c = true,
                //Visitor_ID__c = ipAddress,
                AGB_Datenschutzhinweise_Richtigkeit__c = false,
                E2E_Form_of_Business__c = 'Form of Business',
                E2E_Active_Step__c = 0,
                E2E_Status__c = 'In progress',
                E2E_Sales_Type__c = 'Fully E2E');
        insert opportunity;

        Datetime to_be_removed_time = Datetime.now().addDays(-8);
        Opportunity opportunity2 = new Opportunity(
                Name = tempLongFormName,
                ESI__c = esi,
                Home_Station__c = homestation,
                StageName = 'Prospecting',
                Product__c = 'Shell Standard 2019',
                AccountId = account.Id,
                CloseDate = Date.today(),
                Language_preference__c = 'Polish',
                Primary_Contact_Phone__c = client_number,
                Agree_to_process_pers_data_for_marketing__c = true,
                Agree_to_telephone_contact__c = true,
                Agree_to_receive_comm_info_by_email__c = true,
                E2E__c = true,
                Sec_Channel__c = 'JITB',
                Channel__c = 'POS',
                LeadSource = 'Tablet',
                CurrencyIsoCode = 'PLN',
                Type = 'New Business',
                //Device_Type__c = deviceView,
                Eco_Fee__c = true,
                //Visitor_ID__c = ipAddress,
                AGB_Datenschutzhinweise_Richtigkeit__c = false,
                E2E_Active_Step__c = 0,
                E2E_Status__c = 'In progress',
                E2E_Sales_Type__c = 'Fully E2E');
        insert opportunity2;
        Test.setCreatedDate(opportunity2.Id, to_be_removed_time);

        // Contact creation
        Contact contact = new Contact(
                Salutation = 'Mrs',
                LastName = tempLongFormName,
                AccountId = account.Id,
                Phone = client_number,
                Authorised_signatory__c = false,
                E2E__c = true,
                MailingCountry = 'Poland');
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
            System.debug('inserted partner');
        }

        opportunity.E2E_Short_Link__c = generateShortId(obnNumberDE, opportunity.Id);
        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EForm');
        opportunity.SEPA_Mandate_URL__c = LongFormGlobalUtils.generateOppWithSepaUrl(opportunity, 'E2EForm');
        opportunity.E2E_Last_Activity__c = Datetime.now();
        update opportunity;

        existing_short_urlPL = opportunity.E2E_Short_Link__c;
        existing_encoded_urlPL = opportunity.E2E_Encoded_URL__c;
        System.debug('PL existing short url: '+ existing_short_urlPL);

    }

    static void prepareRecordsDE() {

        String base_url = Url.getSalesforceBaseUrl().toString();

        E2ELongFormUtilsTest.createLongForm('Germany');
        E2ELongFormUtilsTest.createLongFormMenu();
        E2ELongFormUtilsTest.createMenuItemForStep1('Desktop');
        E2ELongFormUtilsTest.createContactDeatilsData('Desktop');

        List<SObject> custom_settings = new List<SObject>();

        E2E_Form_General_Settings__c settingseE2EFormGeneral = new E2E_Form_General_Settings__c();
        settingseE2EFormGeneral.Name = 'Germany';
        settingseE2EFormGeneral.Enable_authorization_non_granted_check__c = false;
        settingseE2EFormGeneral.Files_Generator_Url__c = base_url;
        settingseE2EFormGeneral.Payment_URL__c = base_url;
        settingseE2EFormGeneral.Set_GFN_Status__c = false;
        settingseE2EFormGeneral.Test_Mode__c = false;
        custom_settings.add(settingseE2EFormGeneral);

        E2E_Short_Url__c settingsE2EShortUrl = new E2E_Short_Url__c();
        settingsE2EShortUrl.Name = 'Germany';
        settingsE2EShortUrl.Private_Key__c = '1234567890123456';
        settingsE2EShortUrl.Short_Url__c = base_url + '/i';
        settingsE2EShortUrl.E2E_Form_Url__c = base_url + '/e2eform?country=Germany';
        settingsE2EShortUrl.E2E_JITB_Form_Url__c = base_url + '/e2ejitblocator';
        custom_settings.add(settingsE2EShortUrl);

        ShortLinkEmailNotification__c notifications = new ShortLinkEmailNotification__c();
        notifications.Name = 'roman.rastriga@fleetcor.ru';
        custom_settings.add(notifications);

        E2EKeysAPI__c settingsEKeysAPI = new E2EKeysAPI__c();
        settingsEKeysAPI.Name = 'E2EForm';
        settingsEKeysAPI.AES256_Key__c = 'MTIzNDU2Nzg5MDEyMzQ1NjEyMzQ1Njc4OTAxMjM0NTY=';
        custom_settings.add(settingsEKeysAPI);

        ShortLinkOBNsRefreshed__c cachedOBN = new ShortLinkOBNsRefreshed__c(Name = obnNumberDE);
        ShortLinkOBNsRefreshed__c cachedOBN2 = new ShortLinkOBNsRefreshed__c(Name = nonexisting_obnNumber);
        custom_settings.add(cachedOBN);
        custom_settings.add(cachedOBN2);

        insert custom_settings;

        String esi;
        Account station;
        String homestation;

        Account retailerAccount = new Account(
                OBN__c = obnNumberDE,
                Name = 'ValidOBN',
                ShippingCountry = 'Germany',
                BillingCountry = 'Germany',
                BillingCity = 'Berlin',
                BillingStreet = 'Strasse',
                Type = 'Customer',
                E2E__c = true);
        insert retailerAccount;


        List<Account> checkRetailer = [SELECT BillingStreet,BillingCity,BillingCountry FROM Account WHERE BillingCountry = :COUNTRY_DE AND OBN__c != null AND OBN__c = :obnNumberDE ORDER BY CreatedDate DESC LIMIT 1];
        if ( ! checkRetailer.isEmpty() ) {
            esi = obnNumberDE;
            station = checkRetailer.get(0);
            homestation = station.BillingStreet +', '+station.BillingCity+', '+station.BillingCountry;
        }

        String tempLongFormName;
        Decimal random = math.random() * 100000000;
        if (client_number == null) {
            tempLongFormName = 'LongForm:' + obnNumberDE + '_' + random;
        } else {
            tempLongFormName = 'LongForm: ' + client_number;
        }

        Account account = new Account(
                Name = tempLongFormName,
                BillingCountry = 'Germany',
                ShippingCountry = 'Germany',
                Type = 'Customer',
                E2E__c = true);
        insert account;

        // Opportunity creation
        Opportunity opportunity = new Opportunity(
                Name = tempLongFormName,
                ESI__c = esi,
                Home_Station__c = homestation,
                StageName = 'Prospecting',
                Product__c = '',
                AccountId = account.Id,
                CloseDate = Date.today(),
                Language_preference__c = 'German',
                Primary_Contact_Phone__c = client_number,
                Agree_to_Privacy_Policy__c = true,
                Date_for_Agree_to_Privacy_Policy__c = Datetime.now(),
                E2E__c = true,
                Sec_Channel__c = 'JITB',
                Channel__c = 'POS',
                LeadSource = 'SMS',
                CurrencyIsoCode = 'EUR',
                Type = 'New Business',
                //Device_Type__c = deviceView,
                Eco_Fee__c = true,
                //Visitor_ID__c = ipAddress,
                AGB_Datenschutzhinweise_Richtigkeit__c = false,
                E2E_Form_of_Business__c = 'Form of Business',
                E2E_Active_Step__c = 0,
                E2E_Status__c = 'In progress',
                E2E_Sales_Type__c = 'Fully E2E');
        insert opportunity;

        Datetime to_be_removed_time = Datetime.now().addDays(-8);
        Opportunity opportunity2 = new Opportunity(
                Name = 'LongForm:'+esi+'_123456789',
                E2E_Last_Activity__c = to_be_removed_time,
                ESI__c = esi,
                Home_Station__c = homestation,
                StageName = 'Prospecting',
                Product__c = '',
                AccountId = account.Id,
                CloseDate = Date.today(),
                Language_preference__c = 'German',
                Primary_Contact_Phone__c = client_number,
                Agree_to_Privacy_Policy__c = true,
                Date_for_Agree_to_Privacy_Policy__c = Datetime.now(),
                E2E__c = true,
                Sec_Channel__c = 'JITB',
                Channel__c = 'POS',
                LeadSource = 'Tablet',
                CurrencyIsoCode = 'EUR',
                Type = 'New Business',
                //Device_Type__c = deviceView,
                Eco_Fee__c = true,
                //Visitor_ID__c = ipAddress,
                AGB_Datenschutzhinweise_Richtigkeit__c = false,
                E2E_Form_of_Business__c = 'Form of Business',
                E2E_Active_Step__c = 0,
                E2E_Status__c = 'In progress',
                E2E_Sales_Type__c = 'Fully E2E');
        insert opportunity2;
        Test.setCreatedDate(opportunity2.Id, to_be_removed_time);

        // Contact creation
        Contact contact = new Contact(
                Salutation = 'Mr',
                LastName = tempLongFormName,
                AccountId = account.Id,
                Phone = client_number,
                Authorised_signatory__c = false,
                E2E__c = true,
                MailingCountry = 'Germany');
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
            System.debug('inserted partner');
        }

        opportunity.E2E_Short_Link__c = generateShortId(obnNumberDE, opportunity.Id);
        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EForm');
        opportunity.SEPA_Mandate_URL__c = LongFormGlobalUtils.generateOppWithSepaUrl(opportunity, 'E2EForm');
        opportunity.E2E_Last_Activity__c = Datetime.now();
        update opportunity;

        existing_short_urlDE = opportunity.E2E_Short_Link__c;
        existing_encoded_urlDE = opportunity.E2E_Encoded_URL__c;
        System.debug('DE existing short url: '+ existing_short_urlDE);

    }

    private static String generateShortId(String obnNumber, Id oppId) {
        E2E_Short_Url__c e2eShortUrlDetail = E2E_Short_Url__c.getInstance('Germany');
        String shortid = EncodingUtil.urlEncode(
                EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES128',
                        Blob.valueOf(e2eShortUrlDetail.Private_Key__c),
                        Blob.valueOf(String.valueOf(obnNumber + oppId)))), 'UTF-8')
                .replace('%', '').substring(1, 7);
        return shortid;
    }

    static testMethod void ShortURLHookServiceTestDE() {

        String new_client_number;

        test.startTest();

        System.assert(existing_short_urlDE !=null);

        // Existing client number + existing obn test
        String link = ShortURLHookService.getShortLinkId(client_number, obnNumberDE,false,ShortURLHookService.sourceSMS,COUNTRY_DE);
        System.assertEquals(link, existing_short_urlDE);
        System.debug('Existing client number + existing obn test... ok!');

        // New client number + existing obn test
        new_client_number = '+1111111111111';
        link = ShortURLHookService.getShortLinkId(new_client_number, obnNumberDE,false,ShortURLHookService.sourceSMS,COUNTRY_DE);
        String newoppname = 'LongForm: ' + new_client_number;
        List<Opportunity> opp = [SELECT E2E_Short_Link__c,ESI__c FROM Opportunity WHERE Name = :newoppname AND E2E_Short_Link__c != NULL LIMIT 1];
        System.assert(!opp.isEmpty());
        System.assert(!String.isEmpty(opp.get(0).ESI__c));
        System.assertEquals(link, opp.get(0).E2E_Short_Link__c);
        System.debug('New client number + existing obn test... ok!');

        // New client number + non-existing obn test
        new_client_number = '+1111111111112';
        link = ShortURLHookService.getShortLinkId(new_client_number, nonexisting_obnNumber,false,ShortURLHookService.sourceSMS,COUNTRY_DE);
        newoppname = 'LongForm: ' + new_client_number;
        opp = [SELECT E2E_Short_Link__c,ESI__c FROM Opportunity WHERE Name = :newoppname AND E2E_Short_Link__c != NULL LIMIT 1];
        System.assert(!opp.isEmpty());
        System.assert(String.isEmpty(opp.get(0).ESI__c));
        System.assertEquals(link, opp.get(0).E2E_Short_Link__c);
        System.debug('New client number + non-existing obn test... ok!');

//        // Empty client number + existing obn test
//        new_client_number = null;
//        link = ShortURLHookService.getShortLinkId(new_client_number,nonexisting_obnNumber);
//        newoppname = 'LongForm:' + obnNumber + '_';
//        opp = [SELECT E2E_Short_Link__c,ESI__c FROM Opportunity WHERE Name LIKE :newoppname AND E2E_Short_Link__c != NULL LIMIT 1];
//        System.assert(!opp.isEmpty());
//        System.assert(String.isEmpty(opp.get(0).ESI__c));
//        System.assertEquals(link,opp.get(0).E2E_Short_Link__c);
//        System.debug('Empty client number + existing obn test... ok!');

        test.stopTest();

    }

    static testMethod void ShortURLHookServiceTestPL() {

        test.startTest();

        System.assert(existing_short_urlPL !=null);

        // existing obn test
        String link = ShortURLHookService.getShortLinkId(null, obnNumberPL,false,ShortURLHookService.sourceTablet,COUNTRY_PL);
        System.assert(link!=null);
        System.debug('Existing obn test... ok!');

        test.stopTest();

    }

    static testMethod void redirectUrlTestDE() {

        Test.startTest();

        System.assert(existing_short_urlDE !=null);

        // existing opp-ty SMS test
        PageReference page = Page.i;
        Test.setCurrentPage(page);
        ApexPages.currentPage().getHeaders().put('Host', 'online.fleetcor.de');
        page.getParameters().put('s' + existing_short_urlDE, null);
        LinkRedirectController controller = new LinkRedirectController();
        PageReference res = controller.redirectURL();
        System.debug(EncodingUtil.urlDecode(res.getUrl(), 'UTF-8'));
        System.assert(EncodingUtil.urlDecode(res.getUrl(), 'UTF-8').contains(EncodingUtil.urlDecode('source=' + existing_encoded_urlDE, 'UTF-8')));
        System.debug('existing opp-ty SMS test.. ok!');


// non-existing opp-ty SMS test
        page.getParameters().clear();
        page.getParameters().put('s' + nonexisting_url, null);
        res = controller.redirectURL();
        System.assert(!EncodingUtil.urlDecode(res.getUrl(), 'UTF-8').contains(EncodingUtil.urlDecode('source=', 'UTF-8')));
        System.debug('non existing opp-ty SMS test.. ok!');


// obn QR test
        page.getParameters().clear();
        page.getParameters().put('q' + obnNumberDE, null);
        res = controller.redirectURL();
        System.assert(EncodingUtil.urlDecode(res.getUrl(), 'UTF-8').contains('source='));
        System.debug('obn QR test.. ok!');


// obn URL test
        page.getParameters().clear();
        page.getParameters().put('u' + obnNumberDE, null);
        res = controller.redirectURL();
        System.assert(EncodingUtil.urlDecode(res.getUrl(), 'UTF-8').contains('source='));
        System.debug('obn URL test.. ok!');


// obn Tablet test
        page.getParameters().clear();
        page.getParameters().put('l' + obnNumberDE, null);
        res = controller.redirectURL();
        System.assert(EncodingUtil.urlDecode(res.getUrl(), 'UTF-8').contains('source='));
        System.debug('obn Tablet test.. ok!');

// future opp create test
        page.getParameters().clear();
        page.getParameters().put('l' + obnNumberDE, null);
        page.getParameters().put('preload', 'true');
        res = controller.redirectURL();
        System.debug('future opp test.. ok!');


//opp cleaner batch test
        ShortLinkOppCleaner oppCleaner = new ShortLinkOppCleaner();
        String sch = '0 0 23 * * ?';
        system.schedule('Test cleaner batch', sch, oppCleaner);
        System.debug('oppCleaner batch test..ok!');


//cache refresher batch test
        ShortLinkCacheRefresher refresher = new ShortLinkCacheRefresher();
        system.schedule('Test cache refresher batch', sch, refresher);
        System.debug('cacheRefresher batch test..ok!');


        Test.stopTest();

    }

    static testMethod void redirectUrlTestPL() {

        Test.startTest();

        System.assert(existing_short_urlPL !=null);

// obn QR test
        PageReference page = Page.i;
        Test.setCurrentPage(page);
        ApexPages.currentPage().getHeaders().put('Host', 'online.fleetcor.pl');
        page.getParameters().put('q' + obnNumberPL, null);
        LinkRedirectController controller = new LinkRedirectController();
        PageReference res = controller.redirectURL();
        res = controller.redirectURL();
        System.assert(EncodingUtil.urlDecode(res.getUrl(), 'UTF-8').contains('source='));
        System.debug('obn QR test.. ok!');

// obn URL test
        page.getParameters().clear();
        page.getParameters().put('u' + obnNumberPL, null);
        res = controller.redirectURL();
        System.assert(EncodingUtil.urlDecode(res.getUrl(), 'UTF-8').contains('source='));
        System.debug('obn URL test.. ok!');


// obn Tablet test
        page.getParameters().clear();
        page.getParameters().put('l' + obnNumberPL, null);
        res = controller.redirectURL();
        System.assert(EncodingUtil.urlDecode(res.getUrl(), 'UTF-8').contains('source='));
        System.debug('obn Tablet test.. ok!');

// future opp create test
        page.getParameters().clear();
        page.getParameters().put('l' + obnNumberPL, null);
        page.getParameters().put('preload', 'true');
        res = controller.redirectURL();
        System.debug('future opp test.. ok!');

        Test.stopTest();

    }

    static testMethod void smsControllerTestDE(){

        Test.startTest();
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/twiliohook';
        req.httpMethod = 'POST';
        req.addParameter('from','123456789');
        req.addParameter('body','000000');
        req.addParameter('country','Germany');
        RestContext.request = req;
        String res = TwilioSMSHookController.getPost();
        System.assert(res.contains('{"link":"'));
        System.debug('smsController test DE...ok!');
        Test.stopTest();
    }

    static testMethod void smsControllerTestPL(){

        Test.startTest();
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/twiliohook';
        req.httpMethod = 'POST';
        req.addParameter('from','123456789');
        req.addParameter('body','000001');
        req.addParameter('country','Poland');
        RestContext.request = req;
        String res = TwilioSMSHookController.getPost();
        System.assert(res.contains('{"link":"'));
        System.debug('smsController test PL...ok!');
        Test.stopTest();
    }

    static testMethod void longFormJITBControllerTestDE(){

        String shortlink = ShortURLHookService.getShortLinkId('+1231211225',nonexisting_obnNumber,false,'SMS','Germany');
        System.assert(shortlink != null);
        LinkRedirectController lrcontroller = new LinkRedirectController();
        String link = lrcontroller.generateUrl('s'+shortlink);
        System.assert(link != null);
        String encodedUrl = link.substringAfterLast('=');
        PageReference page = Page.e2ejitbde;
        Test.setCurrentPage(page);
        ApexPages.currentPage().getHeaders().put('Host', 'online.fleetcor.de');
        page.getParameters().put('source', encodedUrl);
        LongFormJITBController controller = new LongFormJITBController();
        controller.init();
        controller.prepareOnlineChat();
        controller.saveOfflineChatLog();
        controller.jsonStation = '{"stationId" : "'+obnNumberDE+'"}';
        controller.returnStation();
        PageReference res = controller.goToTheForm();
        System.debug(EncodingUtil.urlDecode(res.getUrl(), 'UTF-8'));
        System.assert(res.getParameters().get('source').equals(encodedUrl));
        System.debug('locator rewrite wrong obn test DE.. ok!');
    }

    static testMethod void longFormJITBControllerTestPL(){

        String shortlink = ShortURLHookService.getShortLinkId('+1231211226',nonexisting_obnNumber,false,'SMS','Poland');
        System.assert(shortlink != null);
        LinkRedirectController lrcontroller = new LinkRedirectController();
        String link = lrcontroller.generateUrl('s'+shortlink);
        System.assert(link != null);
        String encodedUrl = link.substringAfterLast('=');
        PageReference page = Page.e2ejitbde;
        Test.setCurrentPage(page);
        ApexPages.currentPage().getHeaders().put('Host', 'online.fleetcor.pl');
        page.getParameters().put('source', encodedUrl);
        LongFormJITBController controller = new LongFormJITBController();
        controller.init();
        controller.prepareOnlineChat();
        controller.saveOfflineChatLog();
        controller.jsonStation = '{"stationId" : "'+obnNumberPL+'"}';
        controller.returnStation();
        PageReference res = controller.goToTheForm();
        System.debug(EncodingUtil.urlDecode(res.getUrl(), 'UTF-8'));
        System.assert(res.getParameters().get('source').equals(encodedUrl));
        System.debug('locator rewrite wrong obn test PL.. ok!');
    }



}