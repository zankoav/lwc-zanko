public class SwitchLeadToE2EController {
    public static final String E2E_DE_URL = 'https://online.fleetcor.de';
    public static final String E2E_NL_URL = 'https://online.fleetcor.nl';
    public static final String E2E_BE_URL = 'https://online.fleetcorcards.be';
    public static final String E2E_PL_URL = 'https://online.fleetcor.pl';
    public static final String E2E_HU_URL = 'https://online.fleetcor.hu';
    public static final String E2E_SANDBOX = 'https://e2e-e2efleetcor.cs88.force.com';

    public Boolean isError {get; set;}

    public SwitchLeadToE2EController() {}

    public PageReference init() {
        try {
            this.isError = false;
            String leadId = ApexPages.CurrentPage().getparameters().get('lid');
            if (leadId == null) {
                return goToSite('Germany', null, null); //Exception
            }

            List<Lead> leadsList = [
                    SELECT IsConverted, ConvertedOpportunity.E2E_Encoded_URL__c, Country, Anzahl_der_Fahrzeuge__c, Channel__c, Salutation,
                           LeadSource, CCS_number_of_cards__c, Email, CountryCode, Number_of_Cards_facebook__c, Sec_Channel__c
                    FROM Lead
                    WHERE Id = :leadId AND 
                          Country != NULL AND 
                          Quali_Status__c = 'Switched to E2E'
                    LIMIT 1];
            
            if (leadsList.isEmpty() || (! leadsList.isEmpty() && leadsList.get(0).IsConverted && leadsList.get(0).ConvertedOpportunity.E2E_Encoded_URL__c == null)) {
                return goToSite('Germany', null, null); //Exception
            } 

            if ( ! leadsList.isEmpty() && leadsList.get(0).IsConverted && leadsList.get(0).ConvertedOpportunity.E2E_Encoded_URL__c != null) {
                return goToSite(leadsList.get(0).Country, leadsList.get(0).ConvertedOpportunity.E2E_Encoded_URL__c, leadsList.get(0).Sec_Channel__c);
            }

            // Convert and redirect
            Lead currentLead = leadsList.get(0);
            
            if (isSwitchToE2EFromFacebook(currentLead) || isSwitchToE2EInboundCall(currentLead) || isSwitchToE2EInboundEmail(currentLead) ||
                isSwitchToE2EInboundEmailShell(currentLead) || isSwitchToE2EFromPopup(currentLead) || isSwitchToE2EFromShortForm(currentLead) || isSwitchToE2EFromPartnerJITB(currentLead)) {
                if (currentLead.CCS_number_of_cards__c == null) {
                    if (currentLead.Number_of_Cards_facebook__c != null) {
                        currentLead.CCS_number_of_cards__c = Integer.valueOf(currentLead.Number_of_Cards_facebook__c);
                    } else if (currentLead.Anzahl_der_Fahrzeuge__c != null) {
                        currentLead.CCS_number_of_cards__c = Integer.valueOf(currentLead.Anzahl_der_Fahrzeuge__c);
                    }
                }
                List<User> e2eUser = [SELECT Id FROM User WHERE Name = 'E2E Site Guest User' LIMIT 1];
                if ( ! e2eUser.isEmpty() ) {
                    currentLead.OwnerId = e2eUser.get(0).Id;
                }
                update currentLead;
                
                Database.LeadConvert lc = new Database.LeadConvert();
                LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
                lc.setConvertedStatus(convertStatus.MasterLabel);
                lc.setLeadId(leadId);
                Database.LeadConvertResult lcr = Database.convertLead(lc);

                String encodedUrl = updateConvertedOppToE2E(leadId);

                return goToSite(leadsList.get(0).Country,encodedUrl, leadsList.get(0).Sec_Channel__c);                 
            } else {
                return goToSite('Germany', null, null); //Exception
            }
        } catch (Exception e) {
            ExceptionLogger.sendException(String.valueOf('Lead Switch to E2E Exception: ' + e.getMessage()), String.valueOf(e.getStackTraceString()));
            this.isError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Internal error'));
            return null;
        }        
    }

    // 1. Facebook: Germany, Netherlands, Belgium-NL, Belgium-FR
    private static Boolean isSwitchToE2EFromFacebook(Lead lead) {
        if ((lead.Country == 'Germany' || lead.CountryCode == 'DE' ||
             lead.Country == 'Netherlands' || lead.CountryCode == 'NL' ||
             lead.Country == 'Belgium-NL' || lead.CountryCode == 'BENL' ||
             lead.Country == 'Belgium-FR' || lead.CountryCode == 'BEFR') && 
             lead.LeadSource == 'Facebook' && lead.Number_of_Cards_facebook__c != null) {
            return true;
        }
        return false;
    }

    // 2. Inbound Call: Germany, Netherlands, Belgium-NL, Belgium-FR
    private static Boolean isSwitchToE2EInboundCall(Lead lead) {
        if ((lead.Country == 'Germany' || lead.CountryCode == 'DE' ||
             lead.Country == 'Netherlands' || lead.CountryCode == 'NL' ||
             lead.Country == 'Belgium-NL' || lead.CountryCode == 'BENL' ||
             lead.Country == 'Belgium-FR' || lead.CountryCode == 'BEFR') && 
             lead.LeadSource == 'Inbound Call' && lead.CCS_number_of_cards__c != null && lead.Email != null) {
            return true;
        }
        return false;
    }   

    // 3. Inbound Email: Germany, Netherlands, Belgium-NL, Belgium-FR
    private static Boolean isSwitchToE2EInboundEmail(Lead lead) {
        if ((lead.Country == 'Germany' || lead.CountryCode == 'DE' ||
             lead.Country == 'Netherlands' || lead.CountryCode == 'NL' ||
             lead.Country == 'Belgium-NL' || lead.CountryCode == 'BENL' ||
             lead.Country == 'Belgium-FR' || lead.CountryCode == 'BEFR') && 
             lead.LeadSource == 'Inbound Email' && lead.CCS_number_of_cards__c != null && 
             lead.Email != null) {
            return true;
        }
        return false;
    }  

    // 4. Inbound Email Shell: Netherlands, Belgium-NL, Belgium-FR
    private static Boolean isSwitchToE2EInboundEmailShell(Lead lead) {
        if ((lead.Country == 'Netherlands' || lead.CountryCode == 'NL' ||
             lead.Country == 'Belgium-NL' || lead.CountryCode == 'BENL' ||
             lead.Country == 'Belgium-FR' || lead.CountryCode == 'BEFR') && 
             lead.LeadSource == 'Shell Email' && lead.CCS_number_of_cards__c != null && 
             lead.Email != null) {
            return true;
        }
        return false;
    }        

    // 5. Popup_window: Germany, Netherlands, Belgium-NL, Belgium-FR
    private static Boolean isSwitchToE2EFromPopup(Lead lead) {
        if ((lead.Country == 'Germany' || lead.CountryCode == 'DE' ||
             lead.Country == 'Netherlands' || lead.CountryCode == 'NL' ||
             lead.Country == 'Belgium-NL' || lead.CountryCode == 'BENL' ||
             lead.Country == 'Belgium-FR' || lead.CountryCode == 'BEFR') && 
             lead.LeadSource == 'popup_window' && lead.Number_of_Cards_facebook__c != null) {
            return true;
        }
        return false;
    }    

    // 6. Web_LP: Germany, Netherlands, Belgium-NL, Belgium-FR
    private static Boolean isSwitchToE2EFromShortForm(Lead lead) {
        if ((lead.Country == 'Germany' || lead.CountryCode == 'DE' ||
             lead.Country == 'Netherlands' || lead.CountryCode == 'NL' ||
             lead.Country == 'Belgium-NL' || lead.CountryCode == 'BENL' ||
             lead.Country == 'Belgium-FR' || lead.CountryCode == 'BEFR') && 
             lead.LeadSource == 'Web_LP' && lead.Number_of_Cards_facebook__c != null) {
            return true;
        }
        return false;
    }    

    // 7. Partner JITB: Germany, Poland, Hungary
    private static Boolean isSwitchToE2EFromPartnerJITB(Lead lead) {
        if ((((lead.Country == 'Germany' || lead.CountryCode == 'DE') && lead.Anzahl_der_Fahrzeuge__c != null) ||
            (((lead.Country == 'Poland' || lead.CountryCode == 'PL') || (lead.Country == 'Hungary' || lead.CountryCode == 'HU')) && lead.CCS_number_of_cards__c != null))
            &&
            lead.Sec_Channel__c == 'JITB' &&
            lead.Channel__c == 'Internet' &&
            lead.LeadSource == 'Partner' &&
            lead.Salutation != null) {
            return true;
        }
        return false;
    }

    public String updateConvertedOppToE2E(String leadId) {
        Lead convertedLead = [
                SELECT ConvertedAccountId, ConvertedOpportunityId, ConvertedContactId, Description, 
                       LeadSource, Phone, Number_of_Cards_facebook__c, Anzahl_der_Fahrzeuge__c, CCS_number_of_cards__c
                FROM Lead
                WHERE Id = :leadId
        ];
        Account convertedAccount = [
                SELECT BillingCountry, BillingStreet, BillingCity, 
                       BillingState, BillingPostalCode, AccountSource                       
                FROM Account
                WHERE Id = :convertedLead.ConvertedAccountId
        ];

        List<User> e2eUser = [SELECT Id FROM User WHERE Name = 'E2E Site Guest User'];
        convertedAccount.OwnerId = e2eUser.get(0).Id;
        convertedAccount.ShippingCountry = convertedAccount.BillingCountry;
        convertedAccount.ShippingStreet = convertedAccount.BillingStreet;
        convertedAccount.ShippingCity = convertedAccount.BillingCity;
        convertedAccount.ShippingState = convertedAccount.BillingState;
        convertedAccount.ShippingPostalCode = convertedAccount.BillingPostalCode;
        convertedAccount.AccountSource = convertedLead.LeadSource;
        convertedAccount.Type = 'Customer';
        update convertedAccount;

        Opportunity convertedOpportunity = [
                SELECT Primary_Contact_Phone__c, E2E_Active_Step__c, E2E_Active_Substep__c, Language_preference__c,
                       LeadSource, AGB_Datenschutzhinweise_Richtigkeit__c, E2E_Form_of_Business__c, Description,
                       E2E_Encoded_URL__c, E2E_Sales_Type__c, Product__c, Home_Station__c, ESI__c, Anzahl_der_Karten__c,
                       (SELECT AccountTo.OBN__c, AccountTo.BillingStreet, AccountTo.BillingCity, AccountTo.BillingCountry FROM Partners
                        WHERE AccountTo.OBN__c != NULL AND AccountTo.BillingStreet != null AND AccountTo.BillingCity != NULL AND AccountTo.BillingCountry != NULL LIMIT 1)
                FROM Opportunity
                WHERE Id = :convertedLead.ConvertedOpportunityId
        ];

        convertedOpportunity.OwnerId = e2eUser.get(0).Id;
        convertedOpportunity.Primary_Contact_Phone__c = convertedLead.Phone;
        convertedOpportunity.E2E_Active_Step__c = 0;
        convertedOpportunity.E2E_Active_Substep__c = 'Contact details';
        if (convertedAccount.BillingCountry == 'Germany') {
            convertedOpportunity.Language_preference__c = 'German';    
        } else 
        if (convertedAccount.BillingCountry == 'Netherlands' || convertedAccount.BillingCountry == 'Belgium-NL') {
            convertedOpportunity.Language_preference__c = 'Dutch';
        } else 
        if (convertedAccount.BillingCountry == 'Belgium-FR') {
            convertedOpportunity.Language_preference__c = 'French';
        } else 
        if (convertedAccount.BillingCountry == 'Poland') {
            convertedOpportunity.Language_preference__c = 'Polish';
        } else 
        if (convertedAccount.BillingCountry == 'Hungary') {
            convertedOpportunity.Language_preference__c = 'Hungarian';
        }
        
        convertedOpportunity.E2E__c = true;
        convertedOpportunity.E2E_Sales_Type__c = 'Fully E2E';
        convertedOpportunity.E2E_Status__c = 'Introduction';
        convertedOpportunity.E2E_Sub_Status__c = 'Marketing automation';
        convertedOpportunity.AGB_Datenschutzhinweise_Richtigkeit__c = false;
        convertedOpportunity.E2E_Form_of_Business__c = 'Company';
        convertedOpportunity.Description = convertedLead.Description;
        convertedOpportunity.E2E_Encoded_URL__c = LongFormGlobalUtils.generateOppWithEncodedUrl(convertedOpportunity, 'E2EForm');
        convertedOpportunity.SEPA_Mandate_URL__c = LongFormGlobalUtils.generateOppWithSepaUrl(convertedOpportunity, 'E2EForm');
        if ( ! convertedOpportunity.Partners.isEmpty() ) {
            convertedOpportunity.Home_Station__c = convertedOpportunity.Partners.get(0).AccountTo.BillingStreet + ', ' +
                                                   convertedOpportunity.Partners.get(0).AccountTo.BillingCity + ', ' +
                                                   convertedOpportunity.Partners.get(0).AccountTo.BillingCountry;
            convertedOpportunity.ESI__c = convertedOpportunity.Partners.get(0).AccountTo.OBN__c;
        }

        List<LongForm_Element_Item__c> ecoFee = [
                SELECT Value__c
                FROM LongForm_Element_Item__c
                WHERE Long_Form_Element__r.Long_Form_Page__r.Name = 'ADDITIONAL' AND Long_Form_Element__r.Name = 'CO2 TAKE CARE' AND Name = 'VALUE'
                LIMIT 1];
        Boolean isEcoFee = false;
        if ( ! ecoFee.isEmpty() ) {
            isEcoFee = Boolean.valueOf(ecoFee.get(0).Value__c);
        }
        convertedOpportunity.Eco_Fee__c = isEcoFee;
        if (convertedOpportunity.ESI__c != null) {
            convertedOpportunity.E2E_Short_Link__c = ShortURLHookService.generateShortId(convertedOpportunity.ESI__c, convertedOpportunity.Id);
        }

        update convertedOpportunity;

        Contact convertedContact = [SELECT Id FROM Contact WHERE Id = :convertedLead.ConvertedContactId LIMIT 1];
        convertedContact.OwnerId = e2eUser.get(0).Id; 
        update convertedContact;

        List<Tankkarten__c> cardsToInsertList = new List<Tankkarten__c>();
        for (Integer i = 1; i <= convertedOpportunity.Anzahl_der_Karten__c; i++) {
            cardsToInsertList.add(
                new Tankkarten__c(
                    Opportunity__c = convertedOpportunity.Id,
                    Produktbezugskategorie__c = '2 Kategorie 1 plus fahrzeugbezogene Waren und Dienstleistungen (Öle, Autowäsche)',
                    Gewuenschter_Kartentyp__c = 'Multi Network Card -- National'));
        }
        insert cardsToInsertList;

        List<Emarsys_Log__c> emarsysLogList = [SELECT Opportunity__c FROM Emarsys_Log__c WHERE Lead__c = :leadId];
        if (! emarsysLogList.isEmpty()) {
            for (Emarsys_Log__c emarsysLog : emarsysLogList) {
                emarsysLog.Opportunity__c = convertedOpportunity.Id;
            }
            update emarsysLogList;
        }

        return convertedOpportunity.E2E_Encoded_URL__c;       
    }


    public PageReference goToSite(String country, String encodedUrl, String secchannel) {
        String finalurl;

        if (LongFormGlobalUtils.isSandbox()) {
            if (countryToSiteSandboxMap.containsKey(country)) {
                finalurl = countryToSiteSandboxMap.get(country);
            } else {
                finalurl = countryToSiteSandboxMap.get('Germany');
            }
        } else {
            if (countryToSiteMap.containsKey(country)) {
                finalurl = countryToSiteMap.get(country);
            } else {
                finalurl = countryToSiteMap.get('Germany');
            }
        }

        if (encodedUrl != null && finalurl.contains('Germany')) {
            finalurl += '&source=' + encodedUrl;
        } else 
        if (encodedUrl != null) {
            finalurl += '?source=' + encodedUrl;
        }

        if (secchannel == 'JITB') {
            finalurl += '&utm_source=jitb&utm_medium=e';
        }

        return new PageReference(finalurl);
    }


    public static Map<String, String> countryToSiteMap = new Map<String, String> {
        'Germany' => E2E_DE_URL + '/e2eform?country=Germany',
        'Netherlands' => E2E_NL_URL + '/e2eformnl',
        'Belgium-NL' => E2E_BE_URL + '/e2eformbenl',
        'Belgium-FR' => E2E_BE_URL + '/e2eformbefr',
        'Poland' => E2E_PL_URL + '/e2eformpl',
        'Hungary' => E2E_HU_URL + '/e2eformhu'
    };

    public static Map<String, String> countryToSiteSandboxMap = new Map<String, String> {
        'Germany' => E2E_SANDBOX + '/e2eform?country=Germany',
        'Netherlands' => E2E_SANDBOX + '/e2eformnl',
        'Belgium-NL' => E2E_SANDBOX + '/e2eformbenl',
        'Belgium-FR' => E2E_SANDBOX + '/e2eformbefr',
        'Poland' => E2E_SANDBOX + '/e2eformpl',
        'Hungary' => E2E_SANDBOX + '/e2eformhu'
    };    
}