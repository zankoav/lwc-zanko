@isTest
private class LinkRedirectControllerTest {
    @isTest
    private static void testMethod1() {}
    //private static String generateShortId(String obnNumber, Id oppId) {
    //    E2E_Short_Url__c e2eShortUrlDetail = E2E_Short_Url__c.getInstance('Germany');
    //    String shortid = EncodingUtil.urlEncode(
    //            EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES128',
    //                    Blob.valueOf(e2eShortUrlDetail.Private_Key__c),
    //                    Blob.valueOf(String.valueOf(obnNumber + oppId)))), 'UTF-8')
    //            .replace('%', '').substring(1, 7);
    //    return shortid;
    //}

    //static testMethod void redirectUrlTest(){

    //    String base_url = 'https://e2e-e2efleetcor.cs89.force.com';
    //    List<SObject> custom_settings = new List<SObject>();

    //    E2E_Short_Url__c settingsE2EShortUrl = new E2E_Short_Url__c();
    //    settingsE2EShortUrl.Name = 'Germany';
    //    settingsE2EShortUrl.Private_Key__c = '1234567890123456';
    //    settingsE2EShortUrl.Short_Url__c = base_url+'/i';
    //    settingsE2EShortUrl.E2E_Form_Url__c = base_url+'/e2eform?country=Germany';
    //    settingsE2EShortUrl.E2E_JITB_Form_Url__c = base_url+'/e2ejitbde';
    //    custom_settings.add(settingsE2EShortUrl);

    //    E2EKeysAPI__c settingsEKeysAPI = new E2EKeysAPI__c();
    //    settingsEKeysAPI.Name = 'E2EForm';
    //    settingsEKeysAPI.AES256_Key__c = 'MTIzNDU2Nzg5MDEyMzQ1NjEyMzQ1Njc4OTAxMjM0NTY=';
    //    custom_settings.add(settingsEKeysAPI);

    //    insert custom_settings;

    //    System.assert(E2EKeysAPI__c.getValues('E2EForm').AES256_Key__c!=null);


    //    String obnNumber = '000000';
    //    String client_number = '+0000000000';
    //    String esi;
    //    Account station;
    //    String homestation;

    //    Account retailerAccount = new Account(
    //            OBN__c = obnNumber,
    //            Name = 'ValidOBN',
    //            BillingCountry = 'Germany',
    //            ShippingCountry = 'Germany',
    //            Type = 'Customer',
    //            Strasse_E__c = 'Strasse',
    //            Ort_E__c = 'Ort',
    //            Land_E__c = 'Land',
    //            AccountSource = 'E2E Form');
    //    insert retailerAccount;


    //    List<Account> checkRetailer = [SELECT Strasse_E__c,Ort_E__c,Land_E__c FROM Account WHERE OBN__c != null AND OBN__c = :obnNumber ORDER BY CreatedDate DESC LIMIT 1];
    //    if ( ! checkRetailer.isEmpty() ) {
    //        esi = obnNumber;
    //        station = checkRetailer.get(0);
    //        homestation = station.Strasse_E__c +', '+station.Ort_E__c+', '+station.Land_E__c;
    //    }

    //    String tempLongFormName;
    //    Decimal random = math.random() * 100000000;
    //    if (client_number == null) {
    //        tempLongFormName = 'LongForm:' + obnNumber + '_' + random;
    //    } else {
    //        tempLongFormName = 'LongForm: ' + client_number;
    //    }

    //    Account account = new Account(
    //            Name = tempLongFormName,
    //            BillingCountry = 'Germany',
    //            ShippingCountry = 'Germany',
    //            Type = 'Customer',
    //            AccountSource = 'E2E Form');
    //    insert account;

    //    // Opportunity creation
    //    List<RecordType> opptyRecordTypeList = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'Euroshell' LIMIT 1];
    //    Opportunity opportunity = new Opportunity(
    //            Name = tempLongFormName,
    //            ESI__c = esi,
    //            Home_Station__c = homestation,
    //            StageName = 'Prospecting',
    //            Product__c = '',
    //            AccountId = account.Id,
    //            CloseDate = Date.today(),
    //            Language_preference__c = 'German',
    //            Primary_Contact_Phone__c = client_number,
    //            Agree_to_Privacy_Policy__c = true,
    //            Date_for_Agree_to_Privacy_Policy__c = Datetime.now(),
    //            LeadSource = 'E2E Form',
    //            Sec_Channel__c = 'JITB',
    //            Channel__c = 'Internet',
    //            CurrencyIsoCode = 'EUR',
    //            Type = 'New Business',
    //            //Device_Type__c = deviceView,
    //            Eco_Fee__c = true,
    //            //Visitor_ID__c = ipAddress,
    //            AGB_Datenschutzhinweise_Richtigkeit__c = false,
    //            E2E_Form_of_Business__c = 'Form of Business',
    //            E2E_Active_Step__c = 0,
    //            E2E_Status__c = 'In progress',
    //            E2E_Sales_Type__c = 'Fully E2E');
    //    insert opportunity;

    //    // Contact creation
    //    Contact contact = new Contact(
    //            Salutation = 'Mr',
    //            LastName = tempLongFormName,
    //            AccountId = account.Id,
    //            Phone = client_number,
    //            Authorised_signatory__c = false,
    //            LeadSource = 'E2E Form',
    //            MailingCountry = 'Germany');
    //    insert contact;

    //    // create contact role
    //    OpportunityContactRole oppContactRole = new OpportunityContactRole(
    //            OpportunityId = opportunity.Id,
    //            ContactId = contact.Id,
    //            IsPrimary = true);
    //    insert oppContactRole;

    //    if (station != null) {
    //        Partner newPartner = new Partner();
    //        newPartner.AccountToId = station.Id;
    //        newPartner.OpportunityId = opportunity.Id;
    //        newPartner.Role = 'Multiplier';
    //        insert newPartner;
    //    }

    //    opportunity.E2E_Short_Link__c = generateShortId(obnNumber, opportunity.Id);
    //    opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EForm');
    //    opportunity.SEPA_Mandate_URL__c = LongFormGlobalUtils.generateOppWithSepaUrl(opportunity, 'E2EForm');
    //    opportunity.E2E_Last_Activity__c = Datetime.now();
    //    update opportunity;


    //    String existing_short_url = opportunity.E2E_Short_Link__c;
    //    String existing_encoded_url = opportunity.E2E_Encoded_URL__c;
    //    System.debug('generated short url: '+existing_short_url);
    //    String nonexisting_url = 'XXXXXXXXX';


    //    test.startTest();

    //    // existing opp-ty SMS test
    //    PageReference page = Page.i;
    //    Test.setCurrentPage(page);
    //    page.getParameters().put('s'+existing_short_url,null);
    //    LinkRedirectController controller = new LinkRedirectController();
    //    PageReference res = controller.redirectURL();
    //    System.assert(EncodingUtil.urlDecode(res.getUrl(),'UTF-8').endsWith(EncodingUtil.urlDecode('&source=' + existing_encoded_url,'UTF-8')));
    //    System.debug('existing opp-ty SMS test.. ok!');


    //    // non-existing opp-ty SMS test
    //    page.getParameters().clear();
    //    page.getParameters().put('s'+nonexisting_url,null);
    //    res = controller.redirectURL();
    //    System.assert(!EncodingUtil.urlDecode(res.getUrl(),'UTF-8').contains(EncodingUtil.urlDecode('&source=','UTF-8')));
    //    System.debug('non existing opp-ty SMS test.. ok!');


    //    // // obn QR test
    //    // page.getParameters().clear();
    //    // page.getParameters().put('q'+obnNumber,null);
    //    // res = controller.redirectURL();
    //    // System.assert(EncodingUtil.urlDecode(res.getUrl(),'UTF-8').endsWith('?obn='+obnNumber));
    //    // System.debug('obn QR test.. ok!');


    //    // // obn URL test
    //    // page.getParameters().clear();
    //    // page.getParameters().put('l'+obnNumber,null);
    //    // res = controller.redirectURL();
    //    // System.assert(EncodingUtil.urlDecode(res.getUrl(),'UTF-8').endsWith('?obn='+obnNumber));
    //    // System.debug('obn URL test.. ok!');

    //    // // empty link test
    //    // page.getParameters().clear();
    //    // res = controller.redirectURL();
    //    // System.assert(!EncodingUtil.urlDecode(res.getUrl(),'UTF-8').contains('?source='));
    //    // System.assert(!EncodingUtil.urlDecode(res.getUrl(),'UTF-8').contains('?obn='));
    //    // System.debug('empty link test.. ok!');

    //    // // incorrect link test
    //    // page.getParameters().clear();
    //    // page.getParameters().put('zxcvbnm','hey');
    //    // page.getParameters().put('asdfg','ho');
    //    // res = controller.redirectURL();
    //    // System.assert(!EncodingUtil.urlDecode(res.getUrl(),'UTF-8').contains('?source='));
    //    // System.assert(!EncodingUtil.urlDecode(res.getUrl(),'UTF-8').contains('?obn='));
    //    // System.debug('incorrect link test.. ok!');

    //    test.stopTest();
    //}

}