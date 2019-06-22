public class E2EContactDetailsDEService extends E2EContactDetailsAbstract {
    
    public override String save() {
        Map<String, E2EContentJson.ContentElement> contentsMap = getContentsMap();
        String selectedPhone = returnPhone(contentsMap.get('PHONE').value);        
        String selectedEmail = contentsMap.get('EMAIL').value;

        // new account
        Account account = initNewAccount(contentsMap); 
        insert account;

        // new opportunity  
        Opportunity opportunity = initNewOpportunity(contentsMap, account);
        insert opportunity;

        // new contact
        Contact contact = initNewContact(contentsMap, account);
        insert contact;

        // new cards
        List<Tankkarten__c> cardsList = returnCards(opportunity);
        insert cardsList;

        // new contact roles
        OpportunityContactRole oppContactRole = returnOpportunityContactRole(opportunity, contact);
        insert oppContactRole;

        opportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(opportunity, 'E2EForm');
        opportunity.SEPA_Mandate_URL__c = LongFormGlobalUtils.generateOppWithSepaUrl(opportunity, 'E2EForm');
        opportunity.E2E_Short_Link__c = ShortURLHookService.generateShortId(null, opportunity.Id);
        update opportunity;

        return opportunity.E2E_Encoded_URL__c;
    }


    private OpportunityContactRole returnOpportunityContactRole(Opportunity opportunity, Contact contact) {
        OpportunityContactRole oppContactRole = new OpportunityContactRole(
            OpportunityId = opportunity.Id,
            ContactId = contact.Id,
            IsPrimary = true
        );

        return oppContactRole;
    }


    private List<Tankkarten__c> returnCards(Opportunity opportunity) {
        List<Tankkarten__c> cardsToInsertList = new List<Tankkarten__c>();
        String category = '2 Kategorie 1 plus fahrzeugbezogene Waren und Dienstleistungen (Öle, Autowäsche)';
        String type = 'Multi Network Card -- National';
        for (Integer i = 1; i <= opportunity.Anzahl_der_Karten__c; i++) {
            cardsToInsertList.add(
                new Tankkarten__c(
                    Opportunity__c = opportunity.Id,
                    Produktbezugskategorie__c = category,
                    Gewuenschter_Kartentyp__c = type));
        }

        return cardsToInsertList;
    }


    private Account initNewAccount(Map<String, E2EContentJson.ContentElement> contentsMap) {
        String firstNameFieldValue = contentsMap.get('FIRST NAME').value;
        String lastNameFieldValue = contentsMap.get('LAST NAME').value;

        Account account = new Account(
            Name = ('LongForm: ' + firstNameFieldValue + ' ' + lastNameFieldValue).toUpperCase(),
            BillingCountry = 'Germany',
            ShippingCountry = 'Germany',
            RecordTypeId = returnRecordTypeId('Account', 'Endkunde'),
            Type = 'Customer',
            E2E__c = true
        );

        return account;
    }


    private Contact initNewContact(Map<String, E2EContentJson.ContentElement> contentsMap, Account account) {
        String salutation = contentsMap.get('SALUTATION').value;
        String firstNameFieldValue = contentsMap.get('FIRST NAME').value;
        String lastNameFieldValue = contentsMap.get('LAST NAME').value;
        String phoneValue = contentsMap.get('PHONE').value;
        String emailValue = contentsMap.get('EMAIL').value;

        Contact contact = new Contact(
            Salutation = salutation,
            FirstName = firstNameFieldValue,
            LastName = lastNameFieldValue,
            AccountId = account.Id,
            Phone = phoneValue,
            Email = emailValue,
            Authorised_signatory__c = false,
            E2E__c = true,
            MailingCountry = 'Germany',
            RecordTypeId = returnRecordTypeId('Contact','Contact_layout')
        );

        return contact;
    }


    private Opportunity initNewOpportunity(Map<String, E2EContentJson.ContentElement> contentsMap, Account account) {
        String firstNameFieldValue = contentsMap.get('FIRST NAME').value;
        String lastNameFieldValue = contentsMap.get('LAST NAME').value;        
        String phoneValue = contentsMap.get('PHONE').value;
        String ipAddress = LongFormGlobalUtils.getUserIPAddress();
        Opportunity opportunity = new Opportunity(
            Name = ('LongForm: ' + firstNameFieldValue + ' ' + lastNameFieldValue).toUpperCase(),
            StageName = 'Prospecting',
            Product__c = '',
            AccountId = account.Id,
            CloseDate = Date.today(),
            Last_Owner_Change_Date__c = Datetime.now(),
            Language_preference__c = 'German',
            Primary_Contact_Phone__c = phoneValue,
            Agree_to_Privacy_Policy__c = Boolean.valueOf(contentsMap.get('NEWS AGREEMENT').value),
            Date_for_Agree_to_Privacy_Policy__c = Datetime.now(),
            E2E__c = true,
            LeadSource = 'E2E Form',
            Sec_Channel__c = 'Inbound',
            Channel__c = 'Internet',
            CurrencyIsoCode = 'EUR',
            Type = 'New Business',
            Device_Type__c = 'Desktop',
            E2E_Form_Type__c = 'Desktop' + ';',
            Eco_Fee__c = true,
            Visitor_ID__c = ipAddress,            
            AGB_Datenschutzhinweise_Richtigkeit__c = false,
            E2E_Form_of_Business__c = 'Company',
            E2E_Active_Step__c = 1,
            E2E_Last_Activity__c = Datetime.now(),
            Anzahl_der_Karten__c = returnNumberOfCards(contentsMap.get('NUMBER OF CARDS').value),
            E2E_Status__c = 'In progress',
            E2E_Sales_Type__c = 'Fully E2E',
            RecordTypeId = returnRecordTypeId('Opportunity','Euroshell')
        ); 

        return opportunity;
    }


    private Integer returnNumberOfCards(String numberOfCards) {
        if (numberOfCards == null) {
            return 1;
        }

        return Integer.valueOf(numberOfCards);
    }


    private String returnPhone(String phone) {
        if (phone != null && phone.contains('+490')) {
            phone = phone.replace('+490','+49');
        }

        return phone;
    }


    private String returnRecordTypeId(String sobjectName, String recordTypeName) {
        List<RecordType> recordTypeList = [
                SELECT Id 
                FROM RecordType 
                WHERE SobjectType = :sobjectName AND 
                      DeveloperName = :recordTypeName
                LIMIT 1];
        if ( ! recordTypeList.isEmpty() ) {
            return recordTypeList.get(0).Id;
        }
        return null;
    }


    public override void validate() {
        validateFirstName();
        validateLastName();
        validatePhone();
        validateEmail();
    }

    private void validateFirstName() {
        Map<String, E2EContentJson.ContentElement> contentsMap = getContentsMap();
        String firstName = contentsMap.get('FIRST NAME').value;

        if (firstName == null) {
            throw new E2EException('Invalid First Name');
        }
    }

    private void validateLastName() {

    }

    private void validatePhone() {

    }

    private void validateEmail() {

    }
}