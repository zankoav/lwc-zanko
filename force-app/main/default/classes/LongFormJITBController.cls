public class LongFormJITBController {
    private String country;
    private LFContactDetails contactDetailsService;
    private LFCardsConfig cardsConfigService;
    public Map<String, LongFormPage> stepPagesMap {get; set;}
    public Map<String, LongFormPage> cardPagesMap {get; set;}
    public E2ELocatorStation selectedStation {get; set;}
    public String opptyId {get; set;}

    private Account retailerAccount;
    public Account station {get; set;}

    public String jsonStation {get; set;}
    public String urlLocator {get; set;}
    public Boolean errorMode {get; set;}

    // ONLINE CHAT
    public Map<String, LongFormPage> pageMapChat {get; set;}

    public LFChatService chatService;
    public String chatButtonId {get; set;}
    public String chatDeploymentId {get; set;}
    public String chatDeploymentJsURL {get;set;}
    public string chatURL {get;set;}
    public String offlineChatGreetingMessage {get; set;}
    public String chatFirstMessage {get; set;}


    /*******************************************************************************
    *  Name            : LongFormJITBController()
    *  Summary         : Initiates detault values
    *  CreatedDate     : 03/09/2018
    *  ModifiedDate    :
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public LongFormJITBController() {
        this.selectedStation = new E2ELocatorStation();
        this.station = null;
        this.errorMode = false;
    }


    /*******************************************************************************
    *  Name            : init()
    *  Summary         : Set content for page elements, default values for chat and url for locator
    *  CreatedDate     : 03/08/2018
    *  ModifiedDate    :
    *  Parameters      : -
    *  Returns         : Pagereference
    ******************************************************************************/
    public PageReference init() {
        try {
            setCountry();
            initPageElements();
            initChatSetup();
            setUrlLocator();
        } catch (Exception e) {
            this.errorMode = true;
            E2EExceptionUtils.saveExceptionData(null, null, 'LongFormJITBController.init', e);
            E2EExceptionUtils.sendExceptionEmail(null, null, null, 'Desktop', 'LongFormJITBController.init()', e);
        }

        return null;
    }

    private String doDecryptParams(String encryptedParams) {
        encryptedParams = encryptedParams.replaceAll('(\\s|%2B)', '+');
        if (E2EKeysAPI__c.getValues('E2EForm') == null ) throw new LongFormException('The link is corrupted. Please contact your administrator');
        Blob key = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EForm').AES256_Key__c);
        Blob dest = EncodingUtil.base64Decode(encryptedParams);
        Blob decrypted = Crypto.decryptWithManagedIv('AES256', key, dest);
        String decryptedParams = decrypted.toString();
        if (decryptedParams != null) {
            String opptyId = decryptedParams.substringBefore('-');
            return opptyId;
        }
        return null;
    }

    public String getSelectedStationName() {
        return this.selectedStation.brand + ' ' +  this.selectedStation.stationId + ', ' + this.selectedStation.townName + ', ' + this.selectedStation.address;
    }

    public String getSelectedStationAddress() {
        return this.selectedStation.address;
    }

    public void returnStation() {
        try {
            this.selectedStation = new E2ELocatorStation();
            this.station = null;

            this.selectedStation = (E2ELocatorStation)JSON.deserialize(jsonStation, E2ELocatorStation.class);

            List<Account> accounts = [
                    SELECT OBN__c, BillingStreet, BillingCity, BillingCountry
                    FROM Account
                    WHERE OBN__c = :selectedStation.stationId AND BillingCountry =:country
                    LIMIT 1];

            if (accounts.isEmpty()) {
                this.station = null;
            }
            else {
                this.station = accounts.get(0);
            }
        } catch (Exception e) {
            this.errorMode = true;
            E2EExceptionUtils.saveExceptionData(null, null, 'LongFormJITBController.returnStation', e);
            E2EExceptionUtils.sendExceptionEmail(null, null, null, 'Desktop', 'LongFormJITBController.returnStation()', e);
        }
    }


    /*******************************************************************************
    *  Name            : goToTheForm()
    *  Summary         :
    *  CreatedDate     :
    *  Parameters      :
    *  Returns         :
    ******************************************************************************/
    public PageReference goToTheForm() {
        if (this.selectedStation.stationId == null) {
            return null;
        }
        try {
            String source = ApexPages.currentPage().getParameters().get('source');
            E2E_Short_Url__c jitbShortUrlSetting = E2E_Short_Url__c.getInstance(country);
            if (jitbShortUrlSetting == null) return null;

            if (source != null) {
                updateRecord();
            } else {
                source = insertRecords();
            }

            PageReference page = new PageReference(jitbShortUrlSetting.E2E_Form_Url__c);
            page.getParameters().put('source', source);
            return page;
        } catch (Exception e) {
            this.errorMode = true;
            E2EExceptionUtils.saveExceptionData(null, null, 'LongFormJITBController.goToTheForm', e);
            E2EExceptionUtils.sendExceptionEmail(null, null, null, 'Desktop', 'LongFormJITBController.goToTheForm()', e);
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : insertRecords()
    *  Summary         : Create records if we don't have a source param and return encoded url    
    *  CreatedDate     : 15/04/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : String - encoded url
    ******************************************************************************/
    public String insertRecords() {
        String returnUrl = '';
        Integer random = Integer.valueOf(Math.random() * 100000000);
        String tempLongFormName = 'LongForm:' + this.selectedStation.stationId + '_' + String.valueOf(random); 
        
        // Account creation
        List<RecordType> accountRecordTypeList = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Endkunde' LIMIT 1];
        Account account = new Account(
            Name = tempLongFormName,
            BillingCountry = 'Germany',
            ShippingCountry = 'Germany',
            Type = 'Customer',
            AccountSource = 'URL',
            Sec_Channel_Acc__c = 'JITB'
        );
        if (! accountRecordTypeList.isEmpty()) account.RecordTypeId = accountRecordTypeList.get(0).Id;
        insert account;
        
        // Opportunity creation
        List<RecordType> opptyRecordTypeList = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'Euroshell' LIMIT 1];
        String ipAddress = LongFormGlobalUtils.getUserIPAddress();
        List<LongForm_Element_Item__c> ecoFee = [
                SELECT Value__c
                FROM LongForm_Element_Item__c
                WHERE Long_Form_Element__r.Long_Form_Page__r.Name = 'ADDITIONAL' AND 
                Long_Form_Element__r.Name = 'CO2 TAKE CARE' AND 
                Name = 'VALUE' AND 
                Long_Form_Element__r.Long_Form_Page__r.Long_Form__r.Country__c = :COUNTRY
                LIMIT 1];
        Boolean isEcoFee = false;
        if ( ! ecoFee.isEmpty() ) {
            isEcoFee = Boolean.valueOf(ecoFee.get(0).Value__c);
        }  
        Opportunity opportunity = new Opportunity(
            Name = tempLongFormName,
            StageName = 'Prospecting',
            Product__c = 'Inbound Typ C',
            AccountId = account.Id,
            CloseDate = Date.today(),
            Language_preference__c = 'German',
            Agree_to_Privacy_Policy__c = Boolean.valueOf(this.contactDetailsService.getPagesMap().get('CONTACT DETAILS').fields.get('NEWS AGREEMENT').elementItemsMap.get('DEFAULT VALUE').Value__c),
            Date_for_Agree_to_Privacy_Policy__c = Datetime.now(),
            LeadSource = 'URL',
            Sec_Channel__c = 'JITB',
            Channel__c = 'Internet',
            CurrencyIsoCode = 'EUR',
            Type = 'New Business',
            Eco_Fee__c = isEcoFee,
            Visitor_ID__c = ipAddress,
            AGB_Datenschutzhinweise_Richtigkeit__c = false,
            E2E_Form_of_Business__c = this.contactDetailsService.getPagesMap().get('CONTACT DETAILS').fields.get('COMPANY FORM').elementItemsMap.get('DEFAULT VALUE').Value__c,
            E2E_Active_Step__c = 0,
            E2E_Active_Substep__c = 'Contact details',
            E2E_Status__c = 'In progress',
            E2E_Sales_Type__c = 'Fully E2E',
            Home_Station__c = this.selectedStation.address + ' ' + this.selectedStation.countryName,
            ESI__c = this.selectedStation.stationId
        );
        
        if (! opptyRecordTypeList.isEmpty()) opportunity.RecordTypeId = opptyRecordTypeList.get(0).Id;
        insert opportunity;

        // Contact creation
        List<RecordType> contactRecordTypeList = [SELECT Id FROM RecordType WHERE SobjectType = 'Contact' AND DeveloperName = 'Contact_layout' LIMIT 1];
        Contact contact = new Contact(
            Salutation = this.contactDetailsService.getPagesMap().get('CONTACT DETAILS').fields.get('SALUTATION').elementItemsMap.get('DEFAULT VALUE').Value__c,
            LastName = tempLongFormName,
            AccountId = account.Id,
            Authorised_signatory__c = false,
            LeadSource = 'E2E Form',
            MailingCountry = 'Germany'
        );
        if ( ! contactRecordTypeList.isEmpty()) contact.RecordTypeId = contactRecordTypeList.get(0).Id;
        insert contact;

        OpportunityContactRole oppContactRole = new OpportunityContactRole(
            OpportunityId = opportunity.Id,
            ContactId = contact.Id,
            IsPrimary = true);
        insert oppContactRole;

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EForm');
        opportunity.SEPA_Mandate_URL__c = LongFormGlobalUtils.generateOppWithSepaUrl(opportunity, 'E2EForm');
        opportunity.E2E_Last_Activity__c = Datetime.now();
        
        update opportunity;

        if (this.station != null) {
            Partner newPartner = new Partner();
            newPartner.AccountToId = this.station.Id;
            newPartner.OpportunityId = opportunity.Id;
            newPartner.Role = 'Multiplier';
            insert newPartner;
        }

        returnUrl = opportunity.E2E_Encoded_URL__c;
        return returnUrl;
    }


    /*******************************************************************************
    *  Name            : updateRecord()
    *  Summary         : Update Opportunity with selected station
    *  CreatedDate     : 03/09/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void updateRecord() {
        List<sObject> toUpdate = new List<SObject>();
        Opportunity opportunity = [SELECT AccountId FROM Opportunity WHERE Id = :opptyId];
        List<Account> accs = [SELECT Partner_OBN__c FROM Account WHERE Id = :opportunity.AccountId];

        if (this.station != null) {
            Partner newPartner = new Partner();
            newPartner.AccountToId = this.station.Id;
            newPartner.OpportunityId = opportunity.Id;
            newPartner.Role = 'Multiplier';
            insert newPartner;
        }

        opportunity.Home_Station__c = this.selectedStation.address + ' ' + this.selectedStation.countryName;
        opportunity.ESI__c = this.selectedStation.stationId;
        toUpdate.add(opportunity);
        if(!accs.isEmpty()){
            Account acc = accs.get(0);
            acc.Partner_OBN__c = this.selectedStation.stationId;
            toUpdate.add(acc);
        }
        update toUpdate;
    }


    // INIT
    private void initPageElements() {
        this.contactDetailsService = LongFormGlobalUtils.returnContactDetailsService(country);
        this.contactDetailsService.setPagesMap('Desktop');
        this.cardsConfigService = LongFormGlobalUtils.returnCardsConfigService(country);
        this.cardsConfigService.setPagesMap('Desktop');
        this.stepPagesMap = this.contactDetailsService.getPagesMap();
        this.cardPagesMap = this.cardsConfigService.getPagesMap();
    }


    private void setUrlLocator() {
        List<String> addressParts = new List<String>{country};

        String encryptedParams = ApexPages.currentPage().getParameters().get('source');
        String obnParam = ApexPages.currentPage().getParameters().get('obn');
        if (encryptedParams != null) {
            this.opptyId = doDecryptParams(encryptedParams);
        }
        loadRetailerAccount(opptyId, obnParam);

        if (this.retailerAccount != null && this.retailerAccount.BillingStreet != null) {
            addressParts.add(this.retailerAccount.BillingStreet);
        }
        if (this.retailerAccount != null && this.retailerAccount.BillingCity != null) {
            addressParts.add(this.retailerAccount.BillingCity);
        }

        // RIESSNERSTR. 14., WEIMAR, Germany

        String encodedAddress = EncodingUtil.urlEncode(String.join(addressParts, ', '), 'ASCII');
        this.urlLocator = this.cardsConfigService.getPagesMap().get('JITBLocator').elements.get('LOCATOR URL').get('BASIC').Value__c + encodedAddress +
                this.cardsConfigService.getPagesMap().get('JITBLocator').elements.get('LOCATOR URL').get('ZOOM PARAM').Value__c;
    }


    private void loadRetailerAccount(String opptyId, String obn) {
        String obnParam;
        if (opptyId != null) {
            List<OpportunityPartner> oppPartner = [
                    SELECT AccountTo.OBN__c
                    FROM OpportunityPartner
                    WHERE OpportunityId = :opptyId AND
                    AccountTo.OBN__c != NULL
                    LIMIT 1];
            if ( oppPartner.isEmpty() ) {
                return;
            }
            obnParam = oppPartner.get(0).AccountTo.OBN__c;
        } else
                if (obn != null) {
                    obnParam = obn;
                }

        List<Account> accounts = [
                SELECT OBN__c, BillingStreet, BillingCity, BillingCountry
                FROM Account
                WHERE OBN__c = :obnParam AND BillingCountry = :country
                LIMIT 1];

        if (accounts.isEmpty()) return;

        this.retailerAccount = accounts.get(0);
    }


    // CHAT
    public void initChatSetup() {
        chatService = new LFChatService();
        chatService.setChatDefaultSettings(country);
        chatButtonId = chatService.chatButtonId;
        chatDeploymentId = chatService.chatDeploymentId;
        chatDeploymentJsURL = chatService.chatDeploymentJsURL;
        chatURL = chatService.chatURL;

        chatService.setPageMap(country);
        pageMapChat = chatService.getPagesMap();
    }

    public void saveOfflineChatLog(){
        String textBody = ApexPages.currentPage().getParameters().get('offlineChatBody');
        String clientIpAddress = ApexPages.currentPage().getHeaders().get('True-Client-IP');
        if(clientIpAddress == ''){
            clientIpAddress = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
        }
        LFChatService.saveOfflineChatLog(textBody, clientIpAddress, 0, '',country, opptyId, null);
    }

    public void prepareOnlineChat(){
        String clientNameToChat = '';
        // if (contact != null) {
        //     clientNameToChat = ' ' + contact.Salutation + ' ' + contact.LastName;
        // }
        chatFirstMessage = chatService.getFirstChatMessage(country, 0, '', clientNameToChat);
    }

    private void setCountry(){
        String country_code = ApexPages.currentPage().getHeaders().get('Host').substringAfterLast('.');
        switch on country_code{
            when 'de'{
                country =  'Germany';
            }
            when 'pl'{
                country = 'Poland';
            }
            when else{
                country = 'Germany';
            }
        }
    }
}