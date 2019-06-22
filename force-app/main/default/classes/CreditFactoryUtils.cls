public class CreditFactoryUtils {
    /*******************************************************************************
    *  Name            : createCompanyInfoCreditSystem();
    *  Summary         : Create company info custom setting     
    *  CreatedDate     : 06/03/2018
    *  Parameters      : -
    *  Returns         : CreditSystem__c
    ******************************************************************************/
    public static CreditSystem__c createCompanyInfoCreditSystem() {
        CreditSystem__c creditSystem = new CreditSystem__c(
            Name = 'CompanyInfo',
            Endpoint__c = 'https://ws1.webservices.nl:443/soap_doclit.php', 
            Username__c = 'travelcardtest_User', 
            Password__c = '12345');
        return creditSystem;
    }


    /*******************************************************************************
    *  Name            : createCreditReformAccount()
    *  Summary         : Create test Account.
    *  CreatedDate     : 26/01/2018
    *  ModifiedDate    : 26/01/2018
    *  Parameters      : -
    *  Returns         : Account
    ******************************************************************************/
    public static Account createCreditReformAccount() {
        Account account = new Account(
            Name = 'Kundentestsystem Energie und Wasser AG - BITTE NICHT ÄNDERN', 
            BillingStreet = 'Dichterweg 27',
            ShippingStreet = 'Dichterweg 27',
            BillingPostalCode = '99423',
            ShippingPostalCode = '99423',
            BillingCity = 'Weimar',
            ShippingCity = 'Weimar',
            BillingCountry = 'Germany',
            Type = 'Customer',
            Beschaeftigte__c = '1-4',
            Gesellschaftsform__c = 'AG',
            Steuernummer__c = '234154542', 
            Umsatzsteuer_ID__c = 'DE821235454');
        return account;
    }


    /*******************************************************************************
    *  Name            : createCreditreformOpportunity(String accountId)
    *  Summary         : Create test Opportuinty.    
    *  CreatedDate     : 26/01/2018
    *  ModifiedDate    : 04/04/2019
    *  Parameters      : String accountId - id of related Account
    *  Returns         : Opportunity
    ******************************************************************************/
    public static Opportunity createCreditreformOpportunity(String accountId) {
        Opportunity opportunity = new Opportunity(
            Name = 'Kundentestsystem',
            AccountId = accountId,
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Angebotsdauer__c = '3 Monate',
            Total_consumption_l_month__c = 2000,
            Derzeitige_Zahlungsmethode__c = 'Barzahlung',
            Zahlungsziel_2__c = '30', 
            Rechnungsperiode_2__c = '7',
            Anzahl_der_Karten__c = 0,
            Zahlungsart__c = 'Lastschrift',
            Direct_Debit_Mandate_Type__c = 'B2B');
        return opportunity;
    }


    /*******************************************************************************
    *  Name            : createCreditreformContact(String accountId)
    *  Summary         : Create test Contact.
    *  CreatedDate     : 26/01/2018
    *  ModifiedDate    : 26/01/2018
    *  Parameters      : String accountId - id of related Account
    *  Returns         : Contact
    ******************************************************************************/
    public static Contact createCreditreformContact(String accountId) {
        Contact contact = new Contact(
            Salutation = 'Herr',
            LastName = 'Martina',
            FirstName = 'Muck KTO',
            Email = 'jrogers@burlington.com',
            AccountId = accountId, 
            Phone = '123123123');
        return contact;
    }


    /*******************************************************************************
    *  Name            : doCreateCreditreformAccount()
    *  Summary         : Creating new Account
    *  CreatedDate     : 11/11/2016
    *  Parameters      : 
    *  Returns         : Account
    ******************************************************************************/
    public static Account doCreateCreditreformAccount() {
        Account account = new Account(Name = 'Kundentestsystem Energie und Wasser AG - BITTE NICHT ÄNDERN', Beschaeftigte__c = 'test', Gruende_fuer_Tankkarten__c = 'test', 
                Type = 'test', BillingStreet = 'Dichterweg 27', ShippingStreet = 'Dichterweg 27', BillingPostalCode = '99423',ShippingPostalCode = '99423', 
                BillingCity = 'Weimar', ShippingCity = 'Weimar', IBAN_des_Zahlungspflichtigen__c = 'test', SWIFT_BIC__c = 'test', Name_Zahlungspflichtigen_Kontoinhaber__c = 'test',
                Strasse_und_Hausnummer__c = 'test', Hausnummer_E__c = '27', Gesellschaftsform__c = 'LEFO-DE-11', BillingCountry = 'Germany', BillingState = 'Berlin',
                Strasse_E__c = 'Dichterweg', PLZ_E__c = '99423', Ort_E__c = 'Weimar', Bundesland__c = 'test', Steuernummer__c = 'test', Umsatzsteuer_ID__c = 'DE821235454');
        return account;
    }


    /*******************************************************************************
    *  Name            : doCreateCreditsafeAccount()
    *  Summary         : Creating new Account
    *  CreatedDate     : 11/11/2016
    *  Parameters      : 
    *  Returns         : Account
    ******************************************************************************/
    public static Account doCreateCreditsafeAccount() {
        Account account = new Account(Name = 'ADIDAS (U.K.) LIMITED', Beschaeftigte__c = 'test', Gruende_fuer_Tankkarten__c = 'test', Type = 'test', 
                BillingStreet = 'PEPPER 12', ShippingStreet = 'PEPPER 12', BillingPostalCode = 'SK7 5SA',ShippingPostalCode = 'SK7 5SA', Steuernummer__c = '01075951',
                BillingCity = 'STOCKPORT', ShippingCity = 'STOCKPORT', Gesellschaftsform__c = 'Private limited with Share Capital', BillingCountry = 'Germany',
                BillingState = 'Berlin', BillingCountryCode = 'DE', IBAN_des_Zahlungspflichtigen__c = 'test', SWIFT_BIC__c = 'test', Name_Zahlungspflichtigen_Kontoinhaber__c = 'test',
                Strasse_und_Hausnummer__c = 'test', Hausnummer_E__c = '12', Strasse_E__c = 'PEPPER', Bundesland__c = 'test', Ort_E__c = 'STOCKPORT', PLZ_E__c = 'SK7 5SA',
                Umsatzsteuer_ID__c = 'test');
        return account;
    }


    /*******************************************************************************
    *  Name            : doCreateOpportunity(String accountId)
    *  Summary         : Creating new Opportunity
    *  CreatedDate     : 11/11/2016
    *  Parameters      : String accountId - Id of related Account
    *  Returns         : Opportunity
    ******************************************************************************/
    public static Opportunity doCreateOpportunity(String accountId) {
        Opportunity opportunity = new Opportunity(Name = 'Kundentestsystem', StageName = 'Prospecting', CloseDate = date.today().addDays(+5), AccountId = accountId,
                Product__c = 'test', Anzahl_der_Karten__c = 000, Derzeitige_Zahlungsmethode__c = 'test', Kundensegment__c = 'test',
                Zahlungsziel__c = 'test', Zahlungsziel_Credit__c = 'test', Credit_check_date__c = date.today(), Prio__c = 'A', 
                Billing_Period_by_Sales__c = true, Zahlungsart__c = 'Banküberweisung', Number_of_cars__c = 10, Number_of_trucks__c = 10, Total_consumption_l_month__c = 2000,
                Name_of_the_payer_Account_holder__c = 'test', SWIFT_BIC__c = 'test', Buffer__c = 9, Zahlungsziel_2__c = '30', Rechnungsperiode_2__c = '7');
        return opportunity;
    }


    /*******************************************************************************
    *  Name            : doCreateContact(String accountId)
    *  Summary         : Creating new Contact
    *  CreatedDate     : 20/11/2016
    *  Parameters      : String accountId - Id of related Account
    *  Returns         : Contact
    ******************************************************************************/
    public static Contact doCreateContact(String accountId) {
        Contact contact = new Contact(LastName = 'KTO Martina', FirstName = 'Muck', Email = 'jrogers@burlington.com', Phone = '(336) 222-7000', AccountId = accountId, 
                Salutation = 'Herr');
        return contact;
    }


    /*******************************************************************************
    *  Name            : createCreditreformOpportunityContactRole(String contactId, String opportunityId)
    *  Summary         : Create test Opportunity Cotnact Role.    
    *  CreatedDate     : 26/01/2018
    *  ModifiedDate    : 07/06/2018
    *  Parameters      : String contactId - id of contact, String opportunityId - id of opportunity
    *  Returns         : OpportunityContactRole
    ******************************************************************************/
    public static OpportunityContactRole createCreditreformOpportunityContactRole(String contactId, String opportunityId) {
        OpportunityContactRole opportunityContactRole = new OpportunityContactRole(
            OpportunityId = opportunityId,
            ContactId = contactId,
            Role = 'Fleet manager',
            IsPrimary = true);
        return opportunityContactRole;
    }


    /*******************************************************************************
    *  Name            : createCreditreformAccountMapping()
    *  Summary         : Create test mapping for Account.
    *  CreatedDate     : 26/01/2018
    *  ModifiedDate    : 26/01/2018
    *  Parameters      : -
    *  Returns         : Credit_Factory_Account__c
    ******************************************************************************/
    public static Credit_Factory_Account__c createCreditreformAccountMapping() {
        Credit_Factory_Account__c creditFactoryAccount = new Credit_Factory_Account__c(
            Name = 'Creditreform', 
            Company_Form__c = 'Gesellschaftsform__c', 
            Number_of_employees__c = 'Beschaeftigte__c', 
            Bussines_Street_and_House_Number__c = 'Strasse_und_Hausnummer__c', 
            Reason_for_fuel_cards__c = 'Gruende_fuer_Tankkarten__c', 
            Type__c = 'Type', 
            Tax_Id__c = 'Steuernummer__c', 
            VAT_Number__c = 'Umsatzsteuer_ID__c', 
            Business_Street__c = 'BillingStreet', 
            City__c = 'BillingCity', 
            Country__c = 'BillingCountry', 
            Federal_State__c = 'BillingState', 
            Postal_Code__c = 'BillingPostalCode', 
            House_Number__c = 'Hausnummer_E__c', 
            IBAN__c = 'IBAN_des_Zahlungspflichtigen__c',
            Payer_Owner_Name__c = 'Name_Zahlungspflichtigen_Kontoinhaber__c', 
            SWIFT_BIC__c = 'SWIFT_BIC__c');
        return creditFactoryAccount;
    }


    /*******************************************************************************
    *  Name            : createCrifOpportunityMapping()
    *  Summary         : Create test mapping for Opportunity.
    *  CreatedDate     : 26/01/2018
    *  ModifiedDate    : 26/01/2018
    *  Parameters      : -
    *  Returns         : Credit_Factory_Opportunity__c
    ******************************************************************************/
    public static Credit_Factory_Opportunity__c createCreditreformOpportunityMapping() {
        Credit_Factory_Opportunity__c creditFactoryOpportunity = new Credit_Factory_Opportunity__c(
            Name = 'Creditreform', 
            Credit_System_Limit__c = 'Credit_System_Recommended_Limit__c',
            Number_of_employees__c = 'Zahl_der_Mitarbeiter__c',
            Year_of_foundation__c = 'Gruendungsjahr__c',
            Billing_Period__c = 'Rechnungsperiode__c', 
            Credit_Check_Date__c = 'Credit_check_date__c',
            Credit_Decision__c = 'Kredit_Entscheidung__c',
            Security_Level__c = 'Security_level_H_he_der_Sicherheit__c', 
            Product__c = 'Product__c',
            Current_Payment_Method__c = 'Derzeitige_Zahlungsmethode__c',
            Payment_Method__c = 'Zahlungsart__c',
            Turn_Over__c = 'Umsatz__c', 
            Credit_System_Number__c = 'Credit_System_Number__c',
            Payment_Terms__c = 'Zahlungsziel__c',
            Risk_Category__c = 'Risk_Category__c', 
            Details_Correct__c = 'Angaben_korrekt__c', 
            Financials__c = 'Financials__c', 
            Processed_by__c = 'bearbeitet_von__c', 
            Fuel_consumption_l_month__c = 'Total_consumption_l_month__c', 
            Customer_Segment__c = 'Kundensegment__c',
            Number_of_Cards__c = 'Anzahl_der_Karten__c', 
            Credit_System_Rating__c = 'Credit_System_Rating__c',
            Buffer__c = 'Buffer__c',
            Monthly_Volume_Currency__c = 'Auftragsvolumen__c',
            Payment_Terms_Credit__c = 'Zahlungsziel_Credit__c',
            Payer_Owner_Name__c = 'Name_of_the_payer_Account_holder__c',
            IBAN__c = 'IBAN_des_Zahlungspflichtigen__c',
            SWIFT_BIC__c = 'SWIFT_BIC__c',
            Max_Credit_Limit__c = 'Max_Credit_Limit__c',
            CF_Credit_Limit__c = 'CF_Credit_Limit__c');
        return creditFactoryOpportunity;
    }


    /*******************************************************************************
    *  Name            : createCreditreformCreditSystem()
    *  Summary         : Create test Credit System for Crif.    
    *  CreatedDate     : 26/01/2018
    *  ModifiedDate    : 26/01/2018
    *  Parameters      : -
    *  Returns         : CreditSystem__c
    ******************************************************************************/
    public static CreditSystem__c createCreditreformCreditSystem() {
        CreditSystem__c creditSystem = new CreditSystem__c(
            Name = 'Creditreform',
            Endpoint__c = 'https://ktu.onlineservice.creditreform.de:443/webservice/0520-0018/soap12/messages.wsdl', 
            Username__c = '345013323001', 
            Password__c = '1ppf39vE',
            Supported_Countries__c = 'Germany',
            API_Key__c = 'CFflt123');
        return creditSystem;
    }


    /*******************************************************************************
    *  Name            : createCreditsafeAccount()
    *  Summary         : Creating new Account
    *  CreatedDate     : 02/04/2018
    *  ModifiedDate    : 02/04/2018
    *  Parameters      : -
    *  Returns         : Account
    ******************************************************************************/
    public static Account createCreditsafeAccount() {
        Account account = new Account(
            Name = 'ADIDAS (U.K.) LIMITED',
            Beschaeftigte__c = 'test',
            Type = 'test',
            BillingStreet = 'PEPPER 12', 
            ShippingStreet = 'PEPPER 12', 
            BillingPostalCode = 'SK7 5SA',
            ShippingPostalCode = 'SK7 5SA', 
            BillingCity = 'STOCKPORT', 
            ShippingCity = 'STOCKPORT', 
            BillingCountry = 'Netherlands',
            Steuernummer__c = '01075951',
            Gesellschaftsform__c = 'Private limited with Share Capital', 
            Umsatzsteuer_ID__c = '123123123');
        return account;
    }


    /*******************************************************************************
    *  Name            : createCreditsafeOpportunity(String accountId)
    *  Summary         : Creating new Opportunity
    *  CreatedDate     : 02/04/2018
    *  ModifiedDate    : 04/04/2019
    *  Parameters      : String accountId - Id of related Account
    *  Returns         : Opportunity
    ******************************************************************************/
    public static Opportunity createCreditsafeOpportunity(String accountId) {
        Opportunity opportunity = new Opportunity(
            Name = 'Kundentestsystem', 
            StageName = 'Prospecting', 
            CloseDate = Date.today(), 
            AccountId = accountId,
            Angebotsdauer__c = '3 Monate',
            Derzeitige_Zahlungsmethode__c = 'test',
            Total_consumption_l_month__c = 2000,
            Zahlungsziel_2__c = '30', 
            Rechnungsperiode_2__c = '7',
            Zahlungsart__c = 'Lastschrift',
            Anzahl_der_Karten__c = 0,
            Direct_Debit_Mandate_Type__c = 'B2B');
        return opportunity;
    }


    /*******************************************************************************
    *  Name            : createCreditsafeContact(String accountId)
    *  Summary         : Creating new Contact
    *  CreatedDate     : 02/04/2018
    *  ModifiedDate    : 02/04/2018
    *  Parameters      : String accountId - Id of related Account
    *  Returns         : Contact
    ******************************************************************************/
    public static Contact createCreditsafeContact(String accountId) {
        Contact contact = new Contact(
            LastName = 'KTO Martina',
            FirstName = 'Muck',
            Email = 'jrogers@burlington.com',
            Phone = '01614192500',
            AccountId = accountId,
            Salutation = 'Herr');
        return contact;
    }


    /*******************************************************************************
    *  Name            : createCreditsafeAccountMapping()
    *  Summary         : Create test mapping for Account.
    *  CreatedDate     : 02/04/2018
    *  ModifiedDate    : 02/04/2018
    *  Parameters      : -
    *  Returns         : Credit_Factory_Account__c
    ******************************************************************************/
    public static Credit_Factory_Account__c createCreditsafeAccountMapping() {
        Credit_Factory_Account__c creditFactoryAccount = new Credit_Factory_Account__c(
            Name = 'Creditsafe', 
            Company_Form__c = 'Gesellschaftsform__c', 
            Number_of_employees__c = 'Beschaeftigte__c', 
            Bussines_Street_and_House_Number__c = 'Strasse_und_Hausnummer__c', 
            Reason_for_fuel_cards__c = 'Gruende_fuer_Tankkarten__c', 
            Type__c = 'Type', 
            Tax_Id__c = 'Steuernummer__c', 
            VAT_Number__c = 'Umsatzsteuer_ID__c', 
            Business_Street__c = 'BillingStreet', 
            City__c = 'BillingCity', 
            Country__c = 'BillingCountry', 
            Federal_State__c = 'BillingState', 
            Postal_Code__c = 'BillingPostalCode', 
            House_Number__c = 'Hausnummer_E__c', 
            IBAN__c = 'IBAN_des_Zahlungspflichtigen__c',
            Payer_Owner_Name__c = 'Name_Zahlungspflichtigen_Kontoinhaber__c', 
            SWIFT_BIC__c = 'SWIFT_BIC__c');
        return creditFactoryAccount;
    }


    /*******************************************************************************
    *  Name            : createCreditsafeOpportunityMapping()
    *  Summary         : Create test mapping for Opportunity.
    *  CreatedDate     : 02/04/2018
    *  ModifiedDate    : 02/04/2018
    *  Parameters      : -
    *  Returns         : Credit_Factory_Opportunity__c
    ******************************************************************************/
    public static Credit_Factory_Opportunity__c createCreditsafeOpportunityMapping() {
        Credit_Factory_Opportunity__c creditFactoryOpportunity = new Credit_Factory_Opportunity__c(
            Name = 'Creditsafe', 
            Credit_System_Limit__c = 'Credit_System_Recommended_Limit__c',
            Number_of_employees__c = 'Zahl_der_Mitarbeiter__c',
            Year_of_foundation__c = 'Gruendungsjahr__c',
            Billing_Period__c = 'Rechnungsperiode__c', 
            Credit_Check_Date__c = 'Credit_check_date__c',
            Credit_Decision__c = 'Kredit_Entscheidung__c',
            Security_Level__c = 'Security_level_H_he_der_Sicherheit__c', 
            Product__c = 'Product__c',
            Current_Payment_Method__c = 'Derzeitige_Zahlungsmethode__c',
            Payment_Method__c = 'Zahlungsart__c',
            Turn_Over__c = 'Umsatz__c', 
            Credit_System_Number__c = 'Credit_System_Number__c',
            Payment_Terms__c = 'Zahlungsziel__c',
            Risk_Category__c = 'Risk_Category__c', 
            Details_Correct__c = 'Angaben_korrekt__c', 
            Financials__c = 'Financials__c', 
            Processed_by__c = 'bearbeitet_von__c', 
            Fuel_consumption_l_month__c = 'Total_consumption_l_month__c', 
            Customer_Segment__c = 'Kundensegment__c',
            Number_of_Cards__c = 'Anzahl_der_Karten__c', 
            Credit_System_Rating__c = 'Credit_System_Rating__c',
            Buffer__c = 'Buffer__c',
            Monthly_Volume_Currency__c = 'Auftragsvolumen__c',
            Payment_Terms_Credit__c = 'Zahlungsziel_Credit__c',
            Payer_Owner_Name__c = 'Name_of_the_payer_Account_holder__c',
            IBAN__c = 'IBAN_des_Zahlungspflichtigen__c',
            SWIFT_BIC__c = 'SWIFT_BIC__c',
            Max_Credit_Limit__c = 'Max_Credit_Limit__c',
            CF_Credit_Limit__c = 'CF_Credit_Limit__c');
        return creditFactoryOpportunity;
    }


    /*******************************************************************************
    *  Name            : createCreditsafeCreditSystem()
    *  Summary         : Creating Creditsafe CreditSystem
    *  CreatedDate     : 02/04/2018
    *  ModifiedDate    : 02/04/2018
    *  Parameters      : -
    *  Returns         : CreditSystem__c
    ******************************************************************************/
    public static CreditSystem__c createCreditsafeCreditSystem() {
        CreditSystem__c creditSystem = new CreditSystem__c(
            Name = 'Creditsafe', 
            Endpoint__c = 'https://webservices.creditsafe.com/GlobalData/1.3/MainServiceBasic.svc',
            Username__c = '345013323001', 
            Password__c = '1ppf39vE', 
            API_Key__c = 'CFflt123',
            Supported_Countries__c = 'Netherlands, France');
        return creditSystem;
    }


    /*******************************************************************************
    *  Name            : doCreateCreditSystem()
    *  Summary         : Creating new CreditSystem
    *  CreatedDate     : 11/11/2016
    *  Parameters      : 
    *  Returns         : CreditSystem__c
    ******************************************************************************/
    public static CreditSystem__c doCreateCreditSystem() {
        CreditSystem__c creditSystem = new CreditSystem__c(Name = 'test', Endpoint__c = 'https://webservices.creditsafe.com/GlobalData/1.3/MainServiceBasic.svc',
                Username__c = '345013323001', Password__c = '1ppf39vE', API_Key__c = 'CFflt123');
        return creditSystem;
    }


    /*******************************************************************************
    *  Name            : doCreateCreditFactoryAccount()
    *  Summary         : Creating CreditFactoryAccount
    *  CreatedDate     : 15/11/2016
    *  Parameters      : 
    *  Returns         : Credit_Factory_Account__c
    ******************************************************************************/
    public static Credit_Factory_Account__c doCreateCreditFactoryAccount() {
        Credit_Factory_Account__c creditFactoryAccount = new Credit_Factory_Account__c(Name = 'Test', Company_Form__c = 'Gesellschaftsform__c', 
                Number_of_employees__c = 'Beschaeftigte__c', Bussines_Street_and_House_Number__c = 'Strasse_und_Hausnummer__c', 
                Reason_for_fuel_cards__c = 'Gruende_fuer_Tankkarten__c', Type__c = 'Type', Tax_Id__c = 'Steuernummer__c', 
                VAT_Number__c = 'Umsatzsteuer_ID__c', Business_Street__c = 'BillingStreet', City__c = 'BillingCity', Country__c = 'BillingCountry', 
                Federal_State__c = 'BillingState', Postal_Code__c = 'BillingPostalCode', House_Number__c = 'Hausnummer_E__c', IBAN__c = 'IBAN_des_Zahlungspflichtigen__c',
                Payer_Owner_Name__c = 'Name_Zahlungspflichtigen_Kontoinhaber__c', SWIFT_BIC__c = 'SWIFT_BIC__c');
        return creditFactoryAccount;
    }


    /*******************************************************************************
    *  Name            : doCreateCreditFactoryOpportunity()
    *  Summary         : Creating CreditFactoryOpportunity
    *  CreatedDate     : 15/11/2016
    *  Parameters      : 
    *  Returns         : Credit_Factory_Opportunity__c
    ******************************************************************************/
    public static Credit_Factory_Opportunity__c doCreateCreditFactoryOpportunity() {
        Credit_Factory_Opportunity__c creditFactoryOpportunity = new Credit_Factory_Opportunity__c(Name = 'Test', Credit_System_Limit__c = 'Credit_System_Recommended_Limit__c',
                Number_of_employees__c = 'Zahl_der_Mitarbeiter__c', Year_of_foundation__c = 'Gruendungsjahr__c', Billing_Period__c = 'Rechnungsperiode__c', 
                Credit_Check_Date__c = 'Credit_check_date__c', Credit_Decision__c = 'Kredit_Entscheidung__c', Security_Level__c = 'Security_level_H_he_der_Sicherheit__c', 
                Product__c = 'Product__c', Current_Payment_Method__c = 'Derzeitige_Zahlungsmethode__c', Payment_Method__c = 'Zahlungsart__c', Turn_Over__c = 'Umsatz__c', 
                Credit_System_Number__c = 'Credit_System_Number__c', Payment_Terms__c = 'Zahlungsziel__c', Risk_Category__c = 'Risk_Category__c', 
                Details_Correct__c = 'Angaben_korrekt__c', Financials__c = 'Financials__c', Processed_by__c = 'bearbeitet_von__c', 
                Fuel_consumption_l_month__c = 'Total_consumption_l_month__c', Customer_Segment__c = 'Kundensegment__c', Number_of_Cards__c = 'Anzahl_der_Karten__c', 
                Credit_System_Rating__c = 'Credit_System_Rating__c', Buffer__c = 'Buffer__c', Monthly_Volume_Currency__c = 'Auftragsvolumen__c',
                Payment_Terms_Credit__c = 'Zahlungsziel_Credit__c', Payer_Owner_Name__c = 'Name_of_the_payer_Account_holder__c', IBAN__c = 'IBAN_des_Zahlungspflichtigen__c',
                SWIFT_BIC__c = 'SWIFT_BIC__c', Max_Credit_Limit__c = 'Max_Credit_Limit__c', CF_Credit_Limit__c = 'CF_Credit_Limit__c');
        return creditFactoryOpportunity;
    }


    /*******************************************************************************
    *  Name            : doCreateCreditSystemSalesProfile()
    *  Summary         : Creating CreditSystemSalesProfile__c
    *  CreatedDate     : 15/11/2016
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    public static CreditSystemSalesProfile__c doCreateCreditSystemSalesProfile() {
        CreditSystemSalesProfile__c creditSystemSalesProfile = new CreditSystemSalesProfile__c(Name = 'System Administrator');
        return creditSystemSalesProfile;
    }


    /*******************************************************************************
    *  Name            : doCreateAttachment(String opportunityId)
    *  Summary         : Creating Attachment
    *  CreatedDate     : 18/11/2016 
    *  Parameters      : String opportunityId - Id of related Opportunity
    *  Returns         : void
    ******************************************************************************/
    public static Attachment doCreateAttachment(String opportunityId) {
        Attachment attachment = new Attachment(Name = 'CrefoReport.pdf', ParentId = opportunityId, Body = Blob.valueOf('test'));
        return attachment;
    }


    /*******************************************************************************
    *  Name            : doCreateCreditBlackListCompany()
    *  Summary         : Creating Credit_Black_List_Company__c
    *  CreatedDate     : 25/11/2016
    *  Parameters      : 
    *  Returns         : Credit_Black_List_Company__c
    ******************************************************************************/
    public static Credit_Black_List_Company__c doCreateCreditBlackListCompany(String accountName) {
        Credit_Black_List_Company__c blackList = new Credit_Black_List_Company__c(Customer_Full_Name__c = accountName);
        return blackList;
    }


    /*******************************************************************************
    *  Name            : doCreateCreditreformReport()
    *  Summary         : create Credit_Factory_Report__c
    *  CreatedDate     : 24/10/2017
    *  ModifiedDate    : 16/01/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public static Credit_Factory_Report__c doCreateCreditreformReport() {
        Credit_Factory_Report__c creditReport = new Credit_Factory_Report__c(
                Credit_System_Number__c = '123123', Class_Rating__c = '1', Legal_Form__c = 'AG', Company_Id__c = '123',
                Name = 'KUNDENTESTSYSTEM ENERGIE UND WASSER AG - BITTE NICHT ÄNDERN', Street__c = 'DICHTERWEG', 
                Name__c = 'KUNDENTESTSYSTEM ENERGIE UND WASSER AG - BITTE NICHT ÄNDERN',City__c = 'WEIMAR', Housenumber__c = '27', 
                Postcode__c = '99423');
        return creditReport;
    }


    /*******************************************************************************
    *  Name            : doCreateCreditreformReportEmployee()
    *  Summary         : create Credit_Factory_Report_Employee__c
    *  CreatedDate     : 24/10/2017
    *  ModifiedDate    : 24/10/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public static Credit_Factory_Report_Employee__c doCreateCreditreformReportEmployee() {
        Credit_Factory_Report_Employee__c creditReportEmployee = new Credit_Factory_Report_Employee__c(
            Name = 'Martina');
        return creditReportEmployee;
    }


    /*******************************************************************************
    *  Name            : doCreateCreditsafeReport()
    *  Summary         : create Credit_Factory_Report__c
    *  CreatedDate     : 24/10/2017
    *  ModifiedDate    : 16/01/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public static Credit_Factory_Report__c doCreateCreditsafeReport() {
        Credit_Factory_Report__c creditReport = new Credit_Factory_Report__c(
                Credit_System_Number__c = '123123', Class_Rating__c = '5', Legal_Form__c = 'Private limited with Share Capital', VAT_Number__c = '123123123', 
                Name = 'ADIDAS (U.K.) LIMITED', Name__c = 'ADIDAS (U.K.) LIMITED', Street__c = 'PEPPER', City__c = 'STOCKPORT', Housenumber__c = '12', Postcode__c = 'SK7 5SA', Email__c = 'test@gmail.com', 
                Date_of_Foundation__c = '2010-10-10');
        return creditReport;
    }


    /*******************************************************************************
    *  Name            : doCreateCreditsafeReportEmployee()
    *  Summary         : create Credit_Factory_Report_Employee__c
    *  CreatedDate     : 24/10/2017
    *  ModifiedDate    : 24/10/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public static Credit_Factory_Report_Employee__c doCreateCreditsafeReportEmployee() {
        Credit_Factory_Report_Employee__c creditReportEmployee = new Credit_Factory_Report_Employee__c(
            Name = 'KTO Martina');
        return creditReportEmployee;
    }


    /*******************************************************************************
    *  Name            : createCrifAccount()
    *  Summary         : Create test Account.
    *  CreatedDate     : 15/01/2018
    *  ModifiedDate    : 15/01/2018
    *  Parameters      : -
    *  Returns         : Account
    ******************************************************************************/
    public static Account createCrifAccount() {
        Account account = new Account(
            Name = 'Kacze wyroby BIS Mariusz Wernyks', 
            BillingStreet = 'Kacza 1',
            ShippingStreet = 'Kacza 1',
            BillingPostalCode = '82-333',
            ShippingPostalCode = '82-333',
            BillingCity = 'Wodnowo',
            ShippingCity = 'Wodnowo',
            BillingCountry = 'Poland',
            Type = 'Customer',
            Beschaeftigte__c = '1-4',
            Gesellschaftsform__c = 'Single person company confirmed',
            Steuernummer__c = '8338085693',
            HR_Abteilung_HRA_HRB_und_HR_Nummer__c = '414052396');
        return account;
    }


    /*******************************************************************************
    *  Name            : createCrifOpportunity(String accountId)
    *  Summary         : Create test Opportuinty.    
    *  CreatedDate     : 15/01/2018
    *  ModifiedDate    : 15/01/2018
    *  Parameters      : String accountId - id of related Account
    *  Returns         : Opportunity
    ******************************************************************************/
    public static Opportunity createCrifOpportunity(String accountId) {
        Opportunity opportunity = new Opportunity(
            Name = 'Kacze wyroby BIS Mariusz Wernyks',
            AccountId = accountId,
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Angebotsdauer__c = '3 Monate',
            Zahlungsziel_2__c = '15',
            Rechnungsperiode_2__c = '14',
            Total_consumption_l_month__c = 100,
            Derzeitige_Zahlungsmethode__c = 'Barzahlung',
            Anzahl_der_Karten__c = 0,
            Zahlungsart__c = 'Lastschrift');
        return opportunity;
    }


    /*******************************************************************************
    *  Name            : createCrifContact(String accountId)
    *  Summary         : Create test Contact.
    *  CreatedDate     : 15/01/2018
    *  ModifiedDate    : 15/01/2018
    *  Parameters      : String accountId - id of related Account
    *  Returns         : Contact
    ******************************************************************************/
    public static Contact createCrifContact(String accountId) {
        Contact contact = new Contact(
            Salutation = 'Herr',
            LastName = 'Wernyks',
            FirstName = 'Mariusz',
            Email = 'mariusz.wernyks@test.com',
            AccountId = accountId);
        return contact;
    }


    /*******************************************************************************
    *  Name            : createCrifCreditSystem()
    *  Summary         : Create test Credit System for Crif.    
    *  CreatedDate     : 26/01/2018
    *  ModifiedDate    : 26/01/2018
    *  Parameters      : -
    *  Returns         : CreditSystem__c
    ******************************************************************************/
    public static CreditSystem__c createCrifCreditSystem() {
        CreditSystem__c creditSystem = new CreditSystem__c(
            Name = 'Crif',
            Endpoint__c = 'https://demo.deltavista.pl/Search_Soap_Service_PL/services/SearchService,' + 
                'https://demo.deltavista.pl/dvs-soap/services/OrderCheckService,https://demo.deltavista.pl/pdfservice/pdfservlet', 
            Username__c = 'demo_fleetcor_soap', 
            Password__c = 'cvujmHe4',
            Supported_Countries__c = 'Poland');
        return creditSystem;
    }


    /*******************************************************************************
    *  Name            : createCrifAccountMapping()
    *  Summary         : Create test mapping for Account.
    *  CreatedDate     : 15/01/2018
    *  ModifiedDate    : 15/01/2018
    *  Parameters      : -
    *  Returns         : Credit_Factory_Account__c
    ******************************************************************************/
    public static Credit_Factory_Account__c createCrifAccountMapping() {
        Credit_Factory_Account__c creditFactoryAccount = new Credit_Factory_Account__c(
            Name = 'Crif', 
            Company_Form__c = 'Gesellschaftsform__c', 
            Number_of_employees__c = 'Beschaeftigte__c', 
            Bussines_Street_and_House_Number__c = 'Strasse_und_Hausnummer__c', 
            Reason_for_fuel_cards__c = 'Gruende_fuer_Tankkarten__c', 
            Type__c = 'Type', 
            Tax_Id__c = 'Steuernummer__c', 
            VAT_Number__c = 'Umsatzsteuer_ID__c', 
            Business_Street__c = 'BillingStreet', 
            City__c = 'BillingCity', 
            Country__c = 'BillingCountry', 
            Federal_State__c = 'BillingState', 
            Postal_Code__c = 'BillingPostalCode', 
            House_Number__c = 'Hausnummer_E__c', 
            IBAN__c = 'IBAN_des_Zahlungspflichtigen__c',
            Payer_Owner_Name__c = 'Name_Zahlungspflichtigen_Kontoinhaber__c', 
            SWIFT_BIC__c = 'SWIFT_BIC__c');
        return creditFactoryAccount;
    }


    /*******************************************************************************
    *  Name            : createCrifOpportunityMapping()
    *  Summary         : Create test mapping for Opportunity.
    *  CreatedDate     : 15/01/2018
    *  ModifiedDate    : 15/01/2018
    *  Parameters      : -
    *  Returns         : Credit_Factory_Opportunity__c
    ******************************************************************************/
    public static Credit_Factory_Opportunity__c createCrifOpportunityMapping() {
        Credit_Factory_Opportunity__c creditFactoryOpportunity = new Credit_Factory_Opportunity__c(
            Name = 'Crif',
            Credit_System_Limit__c = 'Credit_System_Recommended_Limit__c',
            Number_of_employees__c = 'Zahl_der_Mitarbeiter__c',
            Year_of_foundation__c = 'Gruendungsjahr__c',
            Billing_Period__c = 'Rechnungsperiode__c', 
            Credit_Check_Date__c = 'Credit_check_date__c',
            Credit_Decision__c = 'Kredit_Entscheidung__c',
            Security_Level__c = 'Security_level_H_he_der_Sicherheit__c', 
            Product__c = 'Product__c',
            Current_Payment_Method__c = 'Derzeitige_Zahlungsmethode__c',
            Payment_Method__c = 'Zahlungsart__c',
            Turn_Over__c = 'Umsatz__c', 
            Credit_System_Number__c = 'Credit_System_Number__c',
            Payment_Terms__c = 'Zahlungsziel__c',
            Risk_Category__c = 'Risk_Category__c', 
            Details_Correct__c = 'Angaben_korrekt__c', 
            Financials__c = 'Financials__c', 
            Processed_by__c = 'bearbeitet_von__c', 
            Fuel_consumption_l_month__c = 'Total_consumption_l_month__c', 
            Customer_Segment__c = 'Kundensegment__c',
            Number_of_Cards__c = 'Anzahl_der_Karten__c', 
            Credit_System_Rating__c = 'Credit_System_Rating__c',
            Buffer__c = 'Buffer__c',
            Monthly_Volume_Currency__c = 'Auftragsvolumen__c',
            Payment_Terms_Credit__c = 'Zahlungsziel_Credit__c',
            Payer_Owner_Name__c = 'Name_of_the_payer_Account_holder__c',
            IBAN__c = 'IBAN_des_Zahlungspflichtigen__c',
            SWIFT_BIC__c = 'SWIFT_BIC__c',
            Max_Credit_Limit__c = 'Max_Credit_Limit__c',
            CF_Credit_Limit__c = 'CF_Credit_Limit__c');
        return creditFactoryOpportunity;
    }


    /*******************************************************************************
    *  Name            : createCrifBlackList()
    *  Summary         : Create test Black list for Crif.
    *  CreatedDate     : 15/01/2018
    *  ModifiedDate    : 15/01/2018
    *  Parameters      : -
    *  Returns         : Credit_Black_List_Company__c
    ******************************************************************************/
    public static Credit_Black_List_Company__c createCrifBlackList() {
        Credit_Black_List_Company__c blackList = new Credit_Black_List_Company__c(
            Customer_Full_Name__c = 'Test Black List');
        return blackList;
    }


    /*******************************************************************************
    *  Name            : createCrifOpportunityContactRole(String contactId, String opportunityId)
    *  Summary         : Create test Opportunity Cotnact Role.    
    *  CreatedDate     : 15/01/2017
    *  ModifiedDate    : 07/06/2017
    *  Parameters      : String contactId - id of contact, String opportunityId - id of opportunity
    *  Returns         : OpportunityContactRole
    ******************************************************************************/
    public static OpportunityContactRole createCrifOpportunityContactRole(String contactId, String opportunityId) {
        OpportunityContactRole opportunityContactRole = new OpportunityContactRole(
            OpportunityId = opportunityId,
            ContactId = contactId,
            Role = 'Fleet manager');
        return opportunityContactRole;
    }


    /*******************************************************************************
    *  Name            : createCrifReport()
    *  Summary         : create Credit_Factory_Report__c
    *  CreatedDate     : 16/01/2018
    *  ModifiedDate    : 16/01/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public static Credit_Factory_Report__c createCrifReport() {
        Credit_Factory_Report__c creditReport = new Credit_Factory_Report__c(
                Credit_System_Number__c = '123123', 
                Tax_Id__c = '8338085693',
                Class_Rating__c = '1', 
                Legal_Form__c = 'Single person company confirmed', 
                VAT_Number__c = '414052396', 
                Company_Id__c = '123',
                Name = 'Kacze wyroby BIS Mariusz Wernyks', 
                Name__c = 'Kacze wyroby BIS Mariusz Wernyks', 
                Street__c = 'Kacza', 
                City__c = 'Wodnowo', 
                Housenumber__c = '1', 
                Postcode__c = '82-333',
                Request_Status__c = 'OK',
                Obligation_Overdue__c = false,
                Date_of_Foundation__c = String.valueOf(Date.today().addMonths(-19)).replace('-', ''));
        return creditReport;
    }


    /*******************************************************************************
    *  Name            : createCrifReportEmployee()
    *  Summary         : create Credit_Factory_Report_Employee__c
    *  CreatedDate     : 16/01/2018
    *  ModifiedDate    : 16/01/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public static Credit_Factory_Report_Employee__c createCrifReportEmployee() {
        Credit_Factory_Report_Employee__c creditReportEmployee = new Credit_Factory_Report_Employee__c(
            Name = 'Mariusz Wernyks');
        return creditReportEmployee;
    }


    /*******************************************************************************
    *  Name            : createCofaceAccount()
    *  Summary         : Create test Account.
    *  CreatedDate     : 06/03/2018
    *  ModifiedDate    : 04/04/2019
    *  Parameters      : -
    *  Returns         : Account
    ******************************************************************************/
    public static Account createCofaceAccount() {
        Account account = new Account(
            Name = 'Hild Ingatlanbefektető Kft.', 
            BillingStreet = 'Lajos utca 74-76.',
            ShippingStreet = 'Lajos utca 74-76.',
            BillingPostalCode = '1036',
            ShippingPostalCode = '1036',
            BillingCity = 'BUDAPEST',
            ShippingCity = 'BUDAPEST',
            BillingCountry = 'Hungary',
            Type = 'Customer',
            Beschaeftigte__c = '1-4',
            Gesellschaftsform__c = 'Limited Liability Company',
            Steuernummer__c = '13373344-2-41',
            Umsatzsteuer_ID__c = 'HU13373344',
            HR_Abteilung_HRA_HRB_und_HR_Nummer__c = '0109731931');
        return account;
    }


    /*******************************************************************************
    *  Name            : createCofaceOpportunity(String accountId)
    *  Summary         : Create test Opportuinty.    
    *  CreatedDate     : 06/03/2018
    *  ModifiedDate    : 06/03/2018
    *  Parameters      : String accountId - id of related Account
    *  Returns         : Opportunity
    ******************************************************************************/
    public static Opportunity createCofaceOpportunity(String accountId) {
        Opportunity opportunity = new Opportunity(
            Name = 'MVM MAGYAR VILLAMOS MUVEK ZART',
            AccountId = accountId,
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Angebotsdauer__c = '3 Monate',
            Zahlungsziel_2__c = '15',
            Rechnungsperiode_2__c = '14',
            Total_consumption_l_month__c = 100,
            Derzeitige_Zahlungsmethode__c = 'Barzahlung',
            Anzahl_der_Karten__c = 0,
            Zahlungsart__c = 'Lastschrift');
        return opportunity;
    }


    /*******************************************************************************
    *  Name            : createCofaceContact(String accountId)
    *  Summary         : Create test Contact.
    *  CreatedDate     : 06/03/2018
    *  ModifiedDate    : 06/03/2018
    *  Parameters      : String accountId - id of related Account
    *  Returns         : Contact
    ******************************************************************************/
    public static Contact createCofaceContact(String accountId) {
        Contact contact = new Contact(
            Salutation = 'Herr',
            LastName = 'Tibor',
            FirstName = 'BIRÓ Balázs',
            AccountId = accountId,
            Phone = '123123123');
        return contact;
    }


    /*******************************************************************************
    *  Name            : createCofaceCreditSystem()
    *  Summary         : Create test Credit System for Coface.    
    *  CreatedDate     : 07/03/2018
    *  ModifiedDate    : 07/03/2018
    *  Parameters      : -
    *  Returns         : CreditSystem__c
    ******************************************************************************/
    public static CreditSystem__c createCofaceCreditSystem() {
        CreditSystem__c creditSystem = new CreditSystem__c(
            Name = 'Coface',
            Endpoint__c = 'https://test.cofacecentraleurope.com/iconwebservices', 
            Username__c = 'Petr.Cermak@fleetcor.eu', 
            Password__c = 'Fleetcor2018',
            Supported_Countries__c = 'Hungary');
        return creditSystem;
    }


    /*******************************************************************************
    *  Name            : createCofaceAccountMapping()
    *  Summary         : Create test mapping for Account.
    *  CreatedDate     : 07/03/2018
    *  ModifiedDate    : 07/03/2018
    *  Parameters      : -
    *  Returns         : Credit_Factory_Account__c
    ******************************************************************************/
    public static Credit_Factory_Account__c createCofaceAccountMapping() {
        Credit_Factory_Account__c creditFactoryAccount = new Credit_Factory_Account__c(
            Name = 'Coface', 
            Company_Form__c = 'Gesellschaftsform__c', 
            Number_of_employees__c = 'Beschaeftigte__c', 
            Bussines_Street_and_House_Number__c = 'Strasse_und_Hausnummer__c', 
            Reason_for_fuel_cards__c = 'Gruende_fuer_Tankkarten__c', 
            Type__c = 'Type', 
            Tax_Id__c = 'Steuernummer__c', 
            VAT_Number__c = 'Umsatzsteuer_ID__c', 
            Business_Street__c = 'BillingStreet', 
            City__c = 'BillingCity', 
            Country__c = 'BillingCountry', 
            Federal_State__c = 'BillingState', 
            Postal_Code__c = 'BillingPostalCode', 
            House_Number__c = 'Hausnummer_E__c', 
            IBAN__c = 'IBAN_des_Zahlungspflichtigen__c',
            Payer_Owner_Name__c = 'Name_Zahlungspflichtigen_Kontoinhaber__c', 
            SWIFT_BIC__c = 'SWIFT_BIC__c');
        return creditFactoryAccount;
    }


    /*******************************************************************************
    *  Name            : createCofaceOpportunityMapping()
    *  Summary         : Create test mapping for Opportunity.
    *  CreatedDate     : 07/03/2018
    *  ModifiedDate    : 07/03/2018
    *  Parameters      : -
    *  Returns         : Credit_Factory_Opportunity__c
    ******************************************************************************/
    public static Credit_Factory_Opportunity__c createCofaceOpportunityMapping() {
        Credit_Factory_Opportunity__c creditFactoryOpportunity = new Credit_Factory_Opportunity__c(
            Name = 'Coface',
            Credit_System_Limit__c = 'Credit_System_Recommended_Limit__c',
            Number_of_employees__c = 'Zahl_der_Mitarbeiter__c',
            Year_of_foundation__c = 'Gruendungsjahr__c',
            Billing_Period__c = 'Rechnungsperiode__c', 
            Credit_Check_Date__c = 'Credit_check_date__c',
            Credit_Decision__c = 'Kredit_Entscheidung__c',
            Security_Level__c = 'Security_level_H_he_der_Sicherheit__c', 
            Product__c = 'Product__c',
            Current_Payment_Method__c = 'Derzeitige_Zahlungsmethode__c',
            Payment_Method__c = 'Zahlungsart__c',
            Turn_Over__c = 'Umsatz__c', 
            Credit_System_Number__c = 'Credit_System_Number__c',
            Payment_Terms__c = 'Zahlungsziel__c',
            Risk_Category__c = 'Risk_Category__c', 
            Details_Correct__c = 'Angaben_korrekt__c', 
            Financials__c = 'Financials__c', 
            Processed_by__c = 'bearbeitet_von__c', 
            Fuel_consumption_l_month__c = 'Total_consumption_l_month__c', 
            Customer_Segment__c = 'Kundensegment__c',
            Number_of_Cards__c = 'Anzahl_der_Karten__c', 
            Credit_System_Rating__c = 'Credit_System_Rating__c',
            Buffer__c = 'Buffer__c',
            Monthly_Volume_Currency__c = 'Auftragsvolumen__c',
            Payment_Terms_Credit__c = 'Zahlungsziel_Credit__c',
            Payer_Owner_Name__c = 'Name_of_the_payer_Account_holder__c',
            IBAN__c = 'IBAN_des_Zahlungspflichtigen__c',
            SWIFT_BIC__c = 'SWIFT_BIC__c',
            Max_Credit_Limit__c = 'Max_Credit_Limit__c',
            CF_Credit_Limit__c = 'CF_Credit_Limit__c');
        return creditFactoryOpportunity;
    }


    /*******************************************************************************
    *  Name            : createCofaceBlackList()
    *  Summary         : Create test Black list for Coface.
    *  CreatedDate     : 07/03/2018
    *  ModifiedDate    : 07/03/2018
    *  Parameters      : -
    *  Returns         : Credit_Black_List_Company__c
    ******************************************************************************/
    public static Credit_Black_List_Company__c createCofaceBlackList() {
        Credit_Black_List_Company__c blackList = new Credit_Black_List_Company__c(
            Customer_Full_Name__c = 'Test Black List');
        return blackList;
    }

    /*******************************************************************************
    *  Name            : createCofaceOpportunityContactRole(String contactId, String opportunityId)
    *  Summary         : Create test Opportunity Cotnact Role.    
    *  CreatedDate     : 08/03/2017
    *  ModifiedDate    : 07/06/2018
    *  Parameters      : String contactId - id of contact, String opportunityId - id of opportunity
    *  Returns         : OpportunityContactRole
    ******************************************************************************/
    public static OpportunityContactRole createCofaceOpportunityContactRole(String contactId, String opportunityId) {
        OpportunityContactRole opportunityContactRole = new OpportunityContactRole(
            OpportunityId = opportunityId,
            ContactId = contactId,
            Role = 'Fleet manager');
        return opportunityContactRole;
    }


    /*******************************************************************************
    *  Name            : createCofaceReport()
    *  Summary         : create Credit_Factory_Report__c
    *  CreatedDate     : 08/03/2018
    *  ModifiedDate    : 05/04/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public static Credit_Factory_Report__c createCofaceReport() {
        Credit_Factory_Report__c creditReport = new Credit_Factory_Report__c(
                Credit_System_Number__c = '123123', 
                Tax_Id__c = '13373344-2-41',
                Class_Rating__c = '1', 
                Legal_Form__c = 'Limited Liability Company', 
                VAT_Number__c = 'HU13373344', 
                Company_Id__c = '123',
                Name = 'Hild Ingatlanbefektető Korlátolt Felelősségű Társaság', 
                Name__c = 'Hild Ingatlanbefektető Korlátolt Felelősségű Társaság', 
                Trade_Name__c = 'Hild Ingatlanbefektető Kft.',
                Street__c = 'Lajos utca', 
                City__c = 'BUDAPEST', 
                Housenumber__c = '74-76.', 
                Postcode__c = '1036',
                Request_Status__c = 'OK',
                Obligation_Overdue__c = false,
                Date_of_Foundation__c = '10.10.2010',
                Credit_Limit__c = '3000000',
                Profit_loss_last_year__c = '31000000',
                Profit_loss_year_before_last__c = '31000000',
                Turn_Over_last_year__c = '31000000');
        return creditReport;
    }


    /*******************************************************************************
    *  Name            : createCofaceReportEmployee()
    *  Summary         : create Credit_Factory_Report_Employee__c
    *  CreatedDate     : 08/03/2018
    *  ModifiedDate    : 08/03/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public static Credit_Factory_Report_Employee__c createCofaceReportEmployee() {
        Credit_Factory_Report_Employee__c creditReportEmployee = new Credit_Factory_Report_Employee__c(
            Name = 'BIRÓ Balázs Tibor');
        return creditReportEmployee;
    }


    /*******************************************************************************
    *  Name            : createCreditReformAccountAT()
    *  Summary         : Create test Account.
    *  CreatedDate     : 01/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Account
    ******************************************************************************/
    public static Account createCreditReformAccountAT() {
        Account account = new Account(
            Name = 'AT Kundentestsystem Aktiengesellschaft - BITTE NICHT ÄNDERN', 
            BillingStreet = 'Salzstrasse 46',
            ShippingStreet = 'Salzstrasse 46',
            BillingPostalCode = '2560',
            ShippingPostalCode = '2560',
            BillingCity = 'Berndorf',
            ShippingCity = 'Berndorf',
            BillingCountry = 'Austria',
            Type = 'Customer',
            Beschaeftigte__c = '1-4',
            Gesellschaftsform__c = 'Gesellschaft mit beschränkter Haftung',
            Steuernummer__c = '463186478',
            Umsatzsteuer_ID__c = 'ATU69772169');
        return account;
    }


    /*******************************************************************************
    *  Name            : createCreditreformOpportunityAT(String accountId)
    *  Summary         : Create test Opportuinty.    
    *  CreatedDate     : 01/10/2018
    *  ModifiedDate    : 04/04/2019
    *  Parameters      : String accountId - id of related Account
    *  Returns         : Opportunity
    ******************************************************************************/
    public static Opportunity createCreditreformOpportunityAT(String accountId) {
        Opportunity opportunity = new Opportunity(
            Name = 'AT Kundentestsystem Aktiengesellschaft - BITTE NICHT ÄNDERN',
            AccountId = accountId,
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Angebotsdauer__c = '3 Monate',
            Total_consumption_l_month__c = 2000,
            Derzeitige_Zahlungsmethode__c = 'Barzahlung',
            Zahlungsziel_2__c = '30', 
            Rechnungsperiode_2__c = '7',
            Zahlungsart__c = 'Lastschrift',
            Anzahl_der_Karten__c = 0,
            Sec_Channel__c = 'JITB',
            Direct_Debit_Mandate_Type__c = 'B2B');
        return opportunity;
    }


    /*******************************************************************************
    *  Name            : createCreditreformContactAT(String accountId)
    *  Summary         : Create test Contact.
    *  CreatedDate     : 01/10/2018
    *  ModifiedDate    : -
    *  Parameters      : String accountId - id of related Account
    *  Returns         : Contact
    ******************************************************************************/
    public static Contact createCreditreformContactAT(String accountId) {
        Contact contact = new Contact(
            Salutation = 'Herr',
            LastName = 'Ochsenkott KTO',
            FirstName = 'Oswald',
            AccountId = accountId, 
            Phone = '123123123');
        return contact;
    }


    /*******************************************************************************
    *  Name            : createCreditreformCreditSystemAT()
    *  Summary         : Create test Credit System for Creditreform AT.    
    *  CreatedDate     : 01/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : CreditSystem__c
    ******************************************************************************/
    public static CreditSystem__c createCreditreformCreditSystemAT() {
        CreditSystem__c creditSystem = new CreditSystem__c(
            Name = 'CreditReformAT',
            Endpoint__c = 'https://ktu.onlineservice.creditreform.de:443/webservice/0520-0018/soap12/messages.wsdl', 
            Username__c = '345013323001', 
            Password__c = '1ppf39vE',
            API_Key__c = 'CFflt123',
            Supported_Countries__c = 'Austria');
        return creditSystem;
    }


    /*******************************************************************************
    *  Name            : createCreditreformAccountMappingAT()
    *  Summary         : Create test mapping for Account.
    *  CreatedDate     : 02/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Credit_Factory_Account__c
    ******************************************************************************/
    public static Credit_Factory_Account__c createCreditreformAccountMappingAT() {
        Credit_Factory_Account__c creditFactoryAccount = new Credit_Factory_Account__c(
            Name = 'CreditreformAT', 
            Company_Form__c = 'Gesellschaftsform__c', 
            Number_of_employees__c = 'Beschaeftigte__c', 
            Bussines_Street_and_House_Number__c = 'Strasse_und_Hausnummer__c', 
            Reason_for_fuel_cards__c = 'Gruende_fuer_Tankkarten__c', 
            Type__c = 'Type', 
            Tax_Id__c = 'Steuernummer__c', 
            VAT_Number__c = 'Umsatzsteuer_ID__c', 
            Business_Street__c = 'BillingStreet', 
            City__c = 'BillingCity', 
            Country__c = 'BillingCountry', 
            Federal_State__c = 'BillingState', 
            Postal_Code__c = 'BillingPostalCode', 
            House_Number__c = 'Hausnummer_E__c', 
            IBAN__c = 'IBAN_des_Zahlungspflichtigen__c',
            Payer_Owner_Name__c = 'Name_Zahlungspflichtigen_Kontoinhaber__c', 
            SWIFT_BIC__c = 'SWIFT_BIC__c');
        return creditFactoryAccount;
    }


    /*******************************************************************************
    *  Name            : createCrifOpportunityMappingAT()
    *  Summary         : Create test mapping for Opportunity.
    *  CreatedDate     : 02/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Credit_Factory_Opportunity__c
    ******************************************************************************/
    public static Credit_Factory_Opportunity__c createCreditreformOpportunityMappingAT() {
        Credit_Factory_Opportunity__c creditFactoryOpportunity = new Credit_Factory_Opportunity__c(
            Name = 'CreditreformAT', 
            Credit_System_Limit__c = 'Credit_System_Recommended_Limit__c',
            Number_of_employees__c = 'Zahl_der_Mitarbeiter__c',
            Year_of_foundation__c = 'Gruendungsjahr__c',
            Billing_Period__c = 'Rechnungsperiode__c', 
            Credit_Check_Date__c = 'Credit_check_date__c',
            Credit_Decision__c = 'Kredit_Entscheidung__c',
            Security_Level__c = 'Security_level_H_he_der_Sicherheit__c', 
            Product__c = 'Product__c',
            Current_Payment_Method__c = 'Derzeitige_Zahlungsmethode__c',
            Payment_Method__c = 'Zahlungsart__c',
            Turn_Over__c = 'Umsatz__c', 
            Credit_System_Number__c = 'Credit_System_Number__c',
            Payment_Terms__c = 'Zahlungsziel__c',
            Risk_Category__c = 'Risk_Category__c', 
            Details_Correct__c = 'Angaben_korrekt__c', 
            Financials__c = 'Financials__c', 
            Processed_by__c = 'bearbeitet_von__c', 
            Fuel_consumption_l_month__c = 'Total_consumption_l_month__c', 
            Customer_Segment__c = 'Kundensegment__c',
            Number_of_Cards__c = 'Anzahl_der_Karten__c', 
            Credit_System_Rating__c = 'Credit_System_Rating__c',
            Buffer__c = 'Buffer__c',
            Monthly_Volume_Currency__c = 'Auftragsvolumen__c',
            Payment_Terms_Credit__c = 'Zahlungsziel_Credit__c',
            Payer_Owner_Name__c = 'Name_of_the_payer_Account_holder__c',
            IBAN__c = 'IBAN_des_Zahlungspflichtigen__c',
            SWIFT_BIC__c = 'SWIFT_BIC__c',
            Max_Credit_Limit__c = 'Max_Credit_Limit__c',
            CF_Credit_Limit__c = 'CF_Credit_Limit__c');
        return creditFactoryOpportunity;
    }


    /*******************************************************************************
    *  Name            : createCreditreformBlackListAT()
    *  Summary         : Create test Black list for Crif.
    *  CreatedDate     : 02/10/2018
    *  ModifiedDate    : -
    *  Parameters      : String accountName - name of account
    *  Returns         : Credit_Black_List_Company__c
    ******************************************************************************/
    public static Credit_Black_List_Company__c createCreditreformBlackListAT(String accountName) {
        Credit_Black_List_Company__c blackList = new Credit_Black_List_Company__c(
            Customer_Full_Name__c = accountName,
            Customer_Id__c = 'AT');
        return blackList;
    }


    /*******************************************************************************
    *  Name            : createCreditreformOpportunityContactRoleAT(String contactId, String opportunityId)
    *  Summary         : Create test Opportunity Cotnact Role.    
    *  CreatedDate     : 02/10/2018
    *  ModifiedDate    : -
    *  Parameters      : String contactId - id of Сontact, String opportunityId - id of Щpportunity
    *  Returns         : OpportunityContactRole
    ******************************************************************************/
    public static OpportunityContactRole createCreditreformOpportunityContactRoleAT(String contactId, String opportunityId) {
        OpportunityContactRole opportunityContactRole = new OpportunityContactRole(
            OpportunityId = opportunityId,
            ContactId = contactId,
            Role = 'Fleet manager');
        return opportunityContactRole;
    }


    /*******************************************************************************
    *  Name            : createCreditreformReportAT()
    *  Summary         : Create Credit Factory Report
    *  CreatedDate     : 02/10/2018
    *  ModifiedDate    : 16/01/2019
    *  Parameters      : String opportunityId - id of parent Opportunity
    *  Returns         : void
    ******************************************************************************/
    public static Credit_Factory_Report__c createCreditreformReportAT(String opportunityId) {
        Credit_Factory_Report__c creditReport = new Credit_Factory_Report__c(
                Class_Rating__c = '1', Legal_Form__c = 'Gesellschaft mit beschränkter Haftung', Company_Id__c = '123',
                Name = 'AT Kundentestsystem Aktiengesellschaft - BITTE NICHT ÄNDERN',
                Name__c = 'AT Kundentestsystem Aktiengesellschaft - BITTE NICHT ÄNDERN', Street__c = 'Salzstrasse', City__c = 'Berndorf', 
                Housenumber__c = '46', Postcode__c = '2560');
        return creditReport;
    }

    /*******************************************************************************
    *  Name            : createCreditreformReportEmployeeAT()
    *  Summary         : Create Credit Factory Report Employee
    *  CreatedDate     : 02/10/2018
    *  ModifiedDate    : -
    *  Parameters      : String reportId - id of parent Credit Factory Report
    *  Returns         : void
    ******************************************************************************/
    public static Credit_Factory_Report_Employee__c createCreditreformReportEmployeeAT(String reportId) {
        Credit_Factory_Report_Employee__c creditReportEmployee = new Credit_Factory_Report_Employee__c(
            Name = 'Oswald Ochsenkott KTO',
            Credit_Factory_Report__c = reportId);
        return creditReportEmployee;
    }


    /*******************************************************************************
    *  Name            : createCrediconnectAccountCH()
    *  Summary         : Create test Account.
    *  CreatedDate     : 12/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Account
    ******************************************************************************/
    public static Account createCrediconnectAccountCH() {
        Account account = new Account(
            Name = 'TesT AG Schweiz', 
            BillingStreet = 'Bösch 63',
            ShippingStreet = 'Bösch 63',
            BillingPostalCode = '6331',
            ShippingPostalCode = '6331',
            BillingCity = 'Hünenberg',
            ShippingCity = 'Hünenberg',
            BillingCountry = 'Switzerland-DE',
            Type = 'Customer',
            Beschaeftigte__c = '1-4',
            Gesellschaftsform__c = 'Aktiengesellschaft',
            Steuernummer__c = 'CH17030143616',
            Umsatzsteuer_ID__c = 'CHE110477663');
        return account;
    }


    /*******************************************************************************
    *  Name            : createCrediconnectOpportunityCH(String accountId)
    *  Summary         : Create test Opportuinty.    
    *  CreatedDate     : 12/10/2018
    *  ModifiedDate    : -
    *  Parameters      : String accountId - id of related Account
    *  Returns         : Opportunity
    ******************************************************************************/
    public static Opportunity createCrediconnectOpportunityCH(String accountId) {
        Opportunity opportunity = new Opportunity(
            Name = 'TesT AG Schweiz',
            AccountId = accountId,
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Angebotsdauer__c = '3 Monate',
            Total_consumption_l_month__c = 1000,
            Derzeitige_Zahlungsmethode__c = 'Barzahlung',
            Zahlungsart__c = 'Lastschrift',
            Anzahl_der_Karten__c = 0,
            Sec_Channel__c = 'JITB');
        return opportunity;
    }


    /*******************************************************************************
    *  Name            : createCrediconnectContactCH(String accountId)
    *  Summary         : Create test Contact.
    *  CreatedDate     : 15/10/2018
    *  ModifiedDate    : -
    *  Parameters      : String accountId - id of related Account
    *  Returns         : Contact
    ******************************************************************************/
    public static Contact createCrediconnectContactCH(String accountId) {
        Contact contact = new Contact(
            Salutation = 'Herr',
            FirstName = 'Therese',
            LastName = 'Havemann',
            AccountId = accountId, 
            Phone = '1234123414');
        return contact;
    }


    /*******************************************************************************
    *  Name            : createCrediconnectContactRoleCH(String contactId, String opportunityId)
    *  Summary         : Create test Opportunity Cotnact Role.    
    *  CreatedDate     : 15/10/2018
    *  ModifiedDate    : -
    *  Parameters      : String contactId - id of Сontact, String opportunityId - id of Щpportunity
    *  Returns         : OpportunityContactRole
    ******************************************************************************/
    public static OpportunityContactRole createCrediconnectContactRoleCH(String contactId, String opportunityId) {
        OpportunityContactRole opportunityContactRole = new OpportunityContactRole(
            OpportunityId = opportunityId,
            ContactId = contactId,
            Role = 'Fleet manager');
        return opportunityContactRole;
    }


    /*******************************************************************************
    *  Name            : createCrediconnectCreditSystemCH()
    *  Summary         : Create test Credit System for Crediconnect CH.    
    *  CreatedDate     : 12/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : CreditSystem__c
    ******************************************************************************/
    public static CreditSystem__c createCrediconnectCreditSystemCH() {
        CreditSystem__c creditSystem = new CreditSystem__c(
            Name = 'CrediConnectCH',
            Endpoint__c = 'https://webservice.crediconnect.ch/V2/03/CrediConnect.svc/basic', 
            Username__c = 'VENT4CC20_CONNECT', 
            Password__c = 'CON4CC20VENT99',
            Supported_Countries__c = 'Switzerland-DE, Switzerland-AT, Switzerland-IT');
        return creditSystem;
    }


    /*******************************************************************************
    *  Name            : createCrediconnectAccountMappingCH()
    *  Summary         : Create test mapping for Account.
    *  CreatedDate     : 15/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Credit_Factory_Account__c
    ******************************************************************************/
    public static Credit_Factory_Account__c createCrediconnectAccountMappingCH() {
        Credit_Factory_Account__c creditFactoryAccount = new Credit_Factory_Account__c(
            Name = 'CrediconnectCH', 
            Company_Form__c = 'Gesellschaftsform__c', 
            Number_of_employees__c = 'Beschaeftigte__c', 
            Bussines_Street_and_House_Number__c = 'Strasse_und_Hausnummer__c', 
            Reason_for_fuel_cards__c = 'Gruende_fuer_Tankkarten__c', 
            Type__c = 'Type', 
            Tax_Id__c = 'Steuernummer__c', 
            VAT_Number__c = 'Umsatzsteuer_ID__c', 
            Business_Street__c = 'BillingStreet', 
            City__c = 'BillingCity', 
            Country__c = 'BillingCountry', 
            Federal_State__c = 'BillingState', 
            Postal_Code__c = 'BillingPostalCode', 
            House_Number__c = 'Hausnummer_E__c', 
            IBAN__c = 'IBAN_des_Zahlungspflichtigen__c',
            Payer_Owner_Name__c = 'Name_Zahlungspflichtigen_Kontoinhaber__c', 
            SWIFT_BIC__c = 'SWIFT_BIC__c');
        return creditFactoryAccount;
    }


    /*******************************************************************************
    *  Name            : createCrediconnectOpportunityMappingCH()
    *  Summary         : Create test mapping for Opportunity.
    *  CreatedDate     : 15/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Credit_Factory_Opportunity__c
    ******************************************************************************/
    public static Credit_Factory_Opportunity__c createCrediconnectOpportunityMappingCH() {
        Credit_Factory_Opportunity__c creditFactoryOpportunity = new Credit_Factory_Opportunity__c(
            Name = 'CrediconnectCH', 
            Credit_System_Limit__c = 'Credit_System_Recommended_Limit__c',
            Number_of_employees__c = 'Zahl_der_Mitarbeiter__c',
            Year_of_foundation__c = 'Gruendungsjahr__c',
            Billing_Period__c = 'Rechnungsperiode__c', 
            Credit_Check_Date__c = 'Credit_check_date__c',
            Credit_Decision__c = 'Kredit_Entscheidung__c',
            Security_Level__c = 'Security_level_H_he_der_Sicherheit__c', 
            Product__c = 'Product__c',
            Current_Payment_Method__c = 'Derzeitige_Zahlungsmethode__c',
            Payment_Method__c = 'Zahlungsart__c',
            Turn_Over__c = 'Umsatz__c', 
            Credit_System_Number__c = 'Credit_System_Number__c',
            Payment_Terms__c = 'Zahlungsziel__c',
            Risk_Category__c = 'Risk_Category__c', 
            Details_Correct__c = 'Angaben_korrekt__c', 
            Financials__c = 'Financials__c', 
            Processed_by__c = 'bearbeitet_von__c', 
            Fuel_consumption_l_month__c = 'Total_consumption_l_month__c', 
            Customer_Segment__c = 'Kundensegment__c',
            Number_of_Cards__c = 'Anzahl_der_Karten__c', 
            Credit_System_Rating__c = 'Credit_System_Rating__c',
            Buffer__c = 'Buffer__c',
            Monthly_Volume_Currency__c = 'Auftragsvolumen__c',
            Payment_Terms_Credit__c = 'Zahlungsziel_Credit__c',
            Payer_Owner_Name__c = 'Name_of_the_payer_Account_holder__c',
            IBAN__c = 'IBAN_des_Zahlungspflichtigen__c',
            SWIFT_BIC__c = 'SWIFT_BIC__c',
            Max_Credit_Limit__c = 'Max_Credit_Limit__c',
            CF_Credit_Limit__c = 'CF_Credit_Limit__c');
        return creditFactoryOpportunity;
    }


    /*******************************************************************************
    *  Name            : createCrediconnectBlackListCH()
    *  Summary         : Create test Black list for Crif.
    *  CreatedDate     : 15/10/2018
    *  ModifiedDate    : -
    *  Parameters      : String accountName - name of account
    *  Returns         : Credit_Black_List_Company__c
    ******************************************************************************/
    public static Credit_Black_List_Company__c createCrediconnectBlackListCH(String accountName) {
        Credit_Black_List_Company__c blackList = new Credit_Black_List_Company__c(
            Customer_Full_Name__c = accountName,
            Customer_Id__c = 'CH');
        return blackList;
    }


    /*******************************************************************************
    *  Name            : createCrediconnectReportCH()
    *  Summary         : Create Credit Factory Report
    *  CreatedDate     : 02/10/2018
    *  ModifiedDate    : 16/01/2019
    *  Parameters      : String opportunityId - id of parent Opportunity
    *  Returns         : void
    ******************************************************************************/
    public static Credit_Factory_Report__c createCrediconnectReportCH(String opportunityId) {
        Credit_Factory_Report__c creditReport = new Credit_Factory_Report__c(
                Class_Rating__c = '4', Legal_Form__c = 'Aktiengesellschaft', Company_Id__c = '123',
                Name = 'TesT AG Schweiz', Name__c = 'TesT AG Schweiz', Street__c = 'Bösch', City__c = 'Hünenberg', 
                Housenumber__c = '63', Postcode__c = '6331', Phone__c = '0417856010', 
                Date_of_Foundation__c = CreditFactoryUtilities.returnCurrentDate());
        return creditReport;
    }

    /*******************************************************************************
    *  Name            : createCrediconnectReportEmployeeCH()
    *  Summary         : Create Credit Factory Report Employee
    *  CreatedDate     : 02/10/2018
    *  ModifiedDate    : -
    *  Parameters      : String reportId - id of parent Credit Factory Report
    *  Returns         : void
    ******************************************************************************/
    public static Credit_Factory_Report_Employee__c createCrediconnectReportEmployeeCH(String reportId) {
        Credit_Factory_Report_Employee__c creditReportEmployee = new Credit_Factory_Report_Employee__c(
            Name = 'Therese Havemann',
            Credit_Factory_Report__c = reportId);
        return creditReportEmployee;
    }


    /*******************************************************************************
    *  Name            : createCreditReformAccountLU()
    *  Summary         : Create test Account.
    *  CreatedDate     : 16/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Account
    ******************************************************************************/
    public static Account createCreditReformAccountLU() {
        Account account = new Account(
            Name = 'LU - Kundentestsystem Group SA - BITTE NICHT ÄNDERN', 
            BillingStreet = 'Bld. Pierre Rot 169',
            ShippingStreet = 'Bld. Pierre Rot 169',
            BillingPostalCode = '1543',
            ShippingPostalCode = '1543',
            BillingCity = 'Luxembourg',
            ShippingCity = 'Luxembourg',
            BillingCountry = 'Luxembourg',
            Type = 'Customer',
            Beschaeftigte__c = '1-4',
            Gesellschaftsform__c = 'Gesellschaft mit beschränkter Haftung',
            Steuernummer__c = '2013/2204/773',
            Umsatzsteuer_ID__c = 'LU 260.900.41');
        return account;
    }


    /*******************************************************************************
    *  Name            : createCreditreformOpportunityLU(String accountId)
    *  Summary         : Create test Opportuinty.    
    *  CreatedDate     : 16/11/2018
    *  ModifiedDate    : 04/04/2019
    *  Parameters      : String accountId - id of related Account
    *  Returns         : Opportunity
    ******************************************************************************/
    public static Opportunity createCreditreformOpportunityLU(String accountId) {
        Opportunity opportunity = new Opportunity(
            Name = 'LU - Kundentestsystem Group SA - BITTE NICHT ÄNDERN',
            AccountId = accountId,
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Angebotsdauer__c = '3 Monate',
            Total_consumption_l_month__c = 2000,
            Derzeitige_Zahlungsmethode__c = 'Barzahlung',
            Zahlungsziel_2__c = '30', 
            Rechnungsperiode_2__c = '7',
            Zahlungsart__c = 'Lastschrift',
            Anzahl_der_Karten__c = 0,
            Sec_Channel__c = 'JITB',
            Direct_Debit_Mandate_Type__c = 'B2B');
        return opportunity;
    }


    /*******************************************************************************
    *  Name            : createCreditreformContactLU(String accountId)
    *  Summary         : Create test Contact.
    *  CreatedDate     : 16/11/2018
    *  ModifiedDate    : -
    *  Parameters      : String accountId - id of related Account
    *  Returns         : Contact
    ******************************************************************************/
    public static Contact createCreditreformContactLU(String accountId) {
        Contact contact = new Contact(
            Salutation = 'Herr',
            LastName = 'Auteil - KTO',
            FirstName = 'Alain',
            AccountId = accountId,
            Phone = '1234123412');
        return contact;
    }


    /*******************************************************************************
    *  Name            : createCreditreformCreditSystemLU()
    *  Summary         : Create test Credit System for Creditreform AT.    
    *  CreatedDate     : 16/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : CreditSystem__c
    ******************************************************************************/
    public static CreditSystem__c createCreditreformCreditSystemLU() {
        CreditSystem__c creditSystem = new CreditSystem__c(
            Name = 'CreditReformLU',
            Endpoint__c = 'https://ktu.onlineservice.creditreform.de:443/webservice/0520-0018/soap12/messages.wsdl', 
            Username__c = '345013323001', 
            Password__c = '1ppf39vE',
            API_Key__c = 'CFflt123',
            Supported_Countries__c = 'Luxembourg');
        return creditSystem;
    }


    /*******************************************************************************
    *  Name            : createCreditreformAccountMappingLU()
    *  Summary         : Create test mapping for Account.
    *  CreatedDate     : 16/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Credit_Factory_Account__c
    ******************************************************************************/
    public static Credit_Factory_Account__c createCreditreformAccountMappingLU() {
        Credit_Factory_Account__c creditFactoryAccount = new Credit_Factory_Account__c(
            Name = 'CreditreformLU', 
            Company_Form__c = 'Gesellschaftsform__c', 
            Number_of_employees__c = 'Beschaeftigte__c', 
            Bussines_Street_and_House_Number__c = 'Strasse_und_Hausnummer__c', 
            Reason_for_fuel_cards__c = 'Gruende_fuer_Tankkarten__c', 
            Type__c = 'Type', 
            Tax_Id__c = 'Steuernummer__c', 
            VAT_Number__c = 'Umsatzsteuer_ID__c', 
            Business_Street__c = 'BillingStreet', 
            City__c = 'BillingCity', 
            Country__c = 'BillingCountry', 
            Federal_State__c = 'BillingState', 
            Postal_Code__c = 'BillingPostalCode', 
            House_Number__c = 'Hausnummer_E__c', 
            IBAN__c = 'IBAN_des_Zahlungspflichtigen__c',
            Payer_Owner_Name__c = 'Name_Zahlungspflichtigen_Kontoinhaber__c', 
            SWIFT_BIC__c = 'SWIFT_BIC__c');
        return creditFactoryAccount;
    }


    /*******************************************************************************
    *  Name            : createCreditreformOpportunityMappingLU()
    *  Summary         : Create test mapping for Opportunity.
    *  CreatedDate     : 16/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Credit_Factory_Opportunity__c
    ******************************************************************************/
    public static Credit_Factory_Opportunity__c createCreditreformOpportunityMappingLU() {
        Credit_Factory_Opportunity__c creditFactoryOpportunity = new Credit_Factory_Opportunity__c(
            Name = 'CreditreformLU', 
            Credit_System_Limit__c = 'Credit_System_Recommended_Limit__c',
            Number_of_employees__c = 'Zahl_der_Mitarbeiter__c',
            Year_of_foundation__c = 'Gruendungsjahr__c',
            Billing_Period__c = 'Rechnungsperiode__c', 
            Credit_Check_Date__c = 'Credit_check_date__c',
            Credit_Decision__c = 'Kredit_Entscheidung__c',
            Security_Level__c = 'Security_level_H_he_der_Sicherheit__c', 
            Product__c = 'Product__c',
            Current_Payment_Method__c = 'Derzeitige_Zahlungsmethode__c',
            Payment_Method__c = 'Zahlungsart__c',
            Turn_Over__c = 'Umsatz__c', 
            Credit_System_Number__c = 'Credit_System_Number__c',
            Payment_Terms__c = 'Zahlungsziel__c',
            Risk_Category__c = 'Risk_Category__c', 
            Details_Correct__c = 'Angaben_korrekt__c', 
            Financials__c = 'Financials__c', 
            Processed_by__c = 'bearbeitet_von__c', 
            Fuel_consumption_l_month__c = 'Total_consumption_l_month__c', 
            Customer_Segment__c = 'Kundensegment__c',
            Number_of_Cards__c = 'Anzahl_der_Karten__c', 
            Credit_System_Rating__c = 'Credit_System_Rating__c',
            Buffer__c = 'Buffer__c',
            Monthly_Volume_Currency__c = 'Auftragsvolumen__c',
            Payment_Terms_Credit__c = 'Zahlungsziel_Credit__c',
            Payer_Owner_Name__c = 'Name_of_the_payer_Account_holder__c',
            IBAN__c = 'IBAN_des_Zahlungspflichtigen__c',
            SWIFT_BIC__c = 'SWIFT_BIC__c',
            Max_Credit_Limit__c = 'Max_Credit_Limit__c',
            CF_Credit_Limit__c = 'CF_Credit_Limit__c');
        return creditFactoryOpportunity;
    }


    /*******************************************************************************
    *  Name            : createCreditreformBlackListLU()
    *  Summary         : Create test Black list for Creditreform.
    *  CreatedDate     : 16/11/2018
    *  ModifiedDate    : -
    *  Parameters      : String accountName - name of account
    *  Returns         : Credit_Black_List_Company__c
    ******************************************************************************/
    public static Credit_Black_List_Company__c createCreditreformBlackListLU(String accountName) {
        Credit_Black_List_Company__c blackList = new Credit_Black_List_Company__c(
            Customer_Full_Name__c = accountName,
            Customer_Id__c = 'LU');
        return blackList;
    }


    /*******************************************************************************
    *  Name            : createCreditreformOpportunityContactRoleLU(String contactId, String opportunityId)
    *  Summary         : Create test Opportunity Cotnact Role.    
    *  CreatedDate     : 16/11/2018
    *  ModifiedDate    : -
    *  Parameters      : String contactId - id of Сontact, String opportunityId - id of Opportunity
    *  Returns         : OpportunityContactRole
    ******************************************************************************/
    public static OpportunityContactRole createCreditreformOpportunityContactRoleLU(String contactId, String opportunityId) {
        OpportunityContactRole opportunityContactRole = new OpportunityContactRole(
            OpportunityId = opportunityId,
            ContactId = contactId,
            Role = 'Fleet manager');
        return opportunityContactRole;
    }


    /*******************************************************************************
    *  Name            : createCreditreformReportLU()
    *  Summary         : Create Credit Factory Report
    *  CreatedDate     : 16/11/2018
    *  ModifiedDate    : 16/01/2019
    *  Parameters      : String opportunityId - id of parent Opportunity
    *  Returns         : void
    ******************************************************************************/
    public static Credit_Factory_Report__c createCreditreformReportLU(String opportunityId) {
        Credit_Factory_Report__c creditReport = new Credit_Factory_Report__c(
                Class_Rating__c = '1', Legal_Form__c = 'Gesellschaft mit beschränkter Haftung', Company_Id__c = '123',
                Name = 'LU - Kundentestsystem Group SA - BITTE NICHT ÄNDERN',
                Name__c = 'LU - Kundentestsystem Group SA - BITTE NICHT ÄNDERN', Street__c = 'Bld. Pierre Rot', City__c = 'Luxembourg', 
                Housenumber__c = '169', Postcode__c = '1543');
        return creditReport;
    }

    /*******************************************************************************
    *  Name            : createCreditreformReportEmployeeLU()
    *  Summary         : Create Credit Factory Report Employee
    *  CreatedDate     : 16/11/2018
    *  ModifiedDate    : -
    *  Parameters      : String reportId - id of parent Credit Factory Report
    *  Returns         : void
    ******************************************************************************/
    public static Credit_Factory_Report_Employee__c createCreditreformReportEmployeeLU(String reportId) {
        Credit_Factory_Report_Employee__c creditReportEmployee = new Credit_Factory_Report_Employee__c(
            Name = 'Alain Auteil - KTO',
            Credit_Factory_Report__c = reportId);
        return creditReportEmployee;
    }


    /*******************************************************************************
    *  Name            : сreateCreditSystemSalesProfile()
    *  Summary         : Create CreditSystemSalesProfile__c
    *  CreatedDate     : 02/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public static CreditSystemSalesProfile__c createCreditSystemSalesProfile() {
        CreditSystemSalesProfile__c creditSystemSalesProfile = new CreditSystemSalesProfile__c(Name = 'System Administrator');
        return creditSystemSalesProfile;
    }


    /*******************************************************************************
    *  Name            : createTask(String opportunityId)
    *  Summary         : Create task on Opportunity    
    *  CreatedDate     : 07/06/2018
    *  ModifiedDate    : -
    *  Parameters      : String opportunityId - Id of related Opportunity
    *  Returns         : Task
    ******************************************************************************/
    public static Task createTask(String opportunityId) {
        Task task = new Task(
            WhatId = opportunityId);
        return task;
    }


    /*******************************************************************************
    *  Name            : createCreditFactorySoqlFieldsList()
    *  Summary         : Create set of fields to select    
    *  CreatedDate     : 02/05/2018
    *  ModifiedDate    : 04/04/2019
    *  Parameters      : -
    *  Returns         : List<CreditFactory_Opportunity_SOQL__c>
    ******************************************************************************/
    public static List<CreditFactory_Opportunity_SOQL__c> createCreditFactorySoqlFieldsList() {
        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = new List<CreditFactory_Opportunity_SOQL__c>();
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Angaben_korrekt__c', Field_Name__c = 'Angaben_korrekt__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Anzahl_der_Karten__c', Field_Name__c = 'Anzahl_der_Karten__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Auftragsvolumen__c', Field_Name__c = 'Auftragsvolumen__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'bearbeitet_von__c', Field_Name__c = 'bearbeitet_von__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Buffer__c', Field_Name__c = 'Buffer__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'CF_Credit_Limit__c', Field_Name__c = 'CF_Credit_Limit__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'CF_Stage__c', Field_Name__c = 'CF_Stage__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Credit_check_date__c', Field_Name__c = 'Credit_check_date__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Credit_System_Id__c', Field_Name__c = 'Credit_System_Id__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Credit_System_Number__c', Field_Name__c = 'Credit_System_Number__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Credit_System_Rating__c', Field_Name__c = 'Credit_System_Rating__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Credit_System_Recommended_Limit__c', Field_Name__c = 'Credit_System_Recommended_Limit__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Custom_PIN__c', Field_Name__c = 'Custom_PIN__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Derzeitige_Zahlungsmethode__c', Field_Name__c = 'Derzeitige_Zahlungsmethode__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Einwilligung_Lastschriftverfahren__c', Field_Name__c = 'Einwilligung_Lastschriftverfahren__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Financials__c', Field_Name__c = 'Financials__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Gruendungsjahr__c', Field_Name__c = 'Gruendungsjahr__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'IBAN__c', Field_Name__c = 'IBAN__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Kredit_Entscheidung__c', Field_Name__c = 'Kredit_Entscheidung__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Kundensegment__c', Field_Name__c = 'Kundensegment__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Last_CF_Errors__c', Field_Name__c = 'Last_CF_Errors__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Max_Credit_Limit__c', Field_Name__c = 'Max_Credit_Limit__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Name', Field_Name__c = 'Name'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Name_of_the_payer_Account_holder__c', Field_Name__c = 'Name_of_the_payer_Account_holder__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Probability', Field_Name__c = 'Probability'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Product__c', Field_Name__c = 'Product__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Rechnungsperiode_2__c', Field_Name__c = 'Rechnungsperiode_2__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Rechnungsperiode__c', Field_Name__c = 'Rechnungsperiode__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Risk_Category__c', Field_Name__c = 'Risk_Category__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Security_level_H_he_der_Sicherheit__c', Field_Name__c = 'Security_level_H_he_der_Sicherheit__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'SEPA_Request_Approved__c', Field_Name__c = 'SEPA_Request_Approved__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'StageName', Field_Name__c = 'StageName'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'SWIFT_BIC__c', Field_Name__c = 'SWIFT_BIC__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Total_consumption_l_month__c', Field_Name__c = 'Total_consumption_l_month__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Umsatz__c', Field_Name__c = 'Umsatz__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Updated_From_Credit_Factory__c', Field_Name__c = 'Updated_From_Credit_Factory__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Zahlungsart__c', Field_Name__c = 'Zahlungsart__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Zahlungsziel_2__c', Field_Name__c = 'Zahlungsziel_2__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Zahlungsziel_Credit__c', Field_Name__c = 'Zahlungsziel_Credit__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Zahlungsziel__c', Field_Name__c = 'Zahlungsziel__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Zahl_der_Mitarbeiter__c', Field_Name__c = 'Zahl_der_Mitarbeiter__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Send_SEPA_approval_link__c', Field_Name__c = 'Send_SEPA_approval_link__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Profit_loss_last_year__c', Field_Name__c = 'Profit_loss_last_year__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Profit_loss_year_before_last__c', Field_Name__c = 'Profit_loss_year_before_last__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Turnover_last_year__c', Field_Name__c = 'Turnover_last_year__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'DocuSign_Status__c', Field_Name__c = 'DocuSign_Status__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Contact_Role_Confirmation_Call__c', Field_Name__c = 'Contact_Role_Confirmation_Call__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'E2E_Form_of_Business__c', Field_Name__c = 'E2E_Form_of_Business__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Sec_Channel__c', Field_Name__c = 'Sec_Channel__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'e_Invoicing_PDF__c', Field_Name__c = 'e_Invoicing_PDF__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Papierrechnung__c', Field_Name__c = 'Papierrechnung__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'CF_Full_Report_Date__c', Field_Name__c = 'CF_Full_Report_Date__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Non_fuel_exposure__c', Field_Name__c = 'Non_fuel_exposure__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Direct_Debit_Mandate_Type__c', Field_Name__c = 'Direct_Debit_Mandate_Type__c'));
        return creditFactorySoqlFieldsList;
    }
}