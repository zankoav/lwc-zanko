public class E2ECardsConfigurationDAOImpl implements E2ECardsConfigurationDAO {
    private Map<String, SObject> sobjectsMap;
    private Sobject jsonSettings;
    private Map<String, String> soqlFieldsMap = new Map<String, String>{
        'Opportunity' => 'E2E_Encoded_URL__c, Anzahl_der_Karten__c, AccountId, E2E_Active_Step__c, ' + 
                         '(SELECT Driver_Name__c, Fahrzeugtyp__c, Firmenname_auf_der_Karte__c, ' + 
                                 'Gewuenschter_Kartentyp__c, Gross__c, KFZ_Kennzeichen_oder_Fahrername__c, ' + 
                                 'Kilometerstand_Abfrage__c, Produktbezugskategorie__c, Zusatzinformation__c ' + 
                          'FROM Tankkarten__r)'
    };

    public E2ECardsConfigurationDAOImpl() {
        this.sobjectsMap = new Map<String, SObject>();
    }

    public void selectSettings(String name) {
        this.jsonSettings = [SELECT Body FROM StaticResource WHERE Name = :name LIMIT 1];
    }

    public Sobject getSettings() {
        return this.jsonSettings;
    }

    public Map<String, Object> addDataFromDatabase(Map<String, Object> originalContent, String source) {
        String opportunityId = E2ENewUtils.decryptOpportunityId(source);            
        selectRecord(opportunityId);

        Opportunity opportunity = (Opportunity)getRecord('Opportunity');
        originalContent.put('number_of_cards', addParamToField(originalContent.get('number_of_cards'), 'value', String.valueOf(opportunity.Anzahl_der_Karten__c)));
        if (opportunity.Tankkarten__r.get(0).Produktbezugskategorie__c == '0 Diesel, Tunnel-, Maut- und Fährgebühren') {
            originalContent.put('category', 'Diesel');
        } 
        else if (opportunity.Tankkarten__r.get(0).Produktbezugskategorie__c == '1 Alle Kraftstoffe, Tunnel-, Maut- und Fährgebühren') {
            originalContent.put('category', 'All fuel types');
        } 
        else if (opportunity.Tankkarten__r.get(0).Produktbezugskategorie__c == '2 Kategorie 1 plus fahrzeugbezogene Waren und Dienstleistungen (Öle, Autowäsche)') {
            originalContent.put('category', 'All vehicle related product');
        }

        if (opportunity.Tankkarten__r.get(0).Gewuenschter_Kartentyp__c == 'Single Network Card -- International') {
            originalContent.put('pumpOutsideCountry', 'true');
            originalContent.put('pumpAtPartners', 'false');
        } 
        else if (opportunity.Tankkarten__r.get(0).Gewuenschter_Kartentyp__c == 'Multi Network Card -- International') {
            originalContent.put('pumpOutsideCountry', 'true');
            originalContent.put('pumpAtPartners', 'true');
        } 
        else if (opportunity.Tankkarten__r.get(0).Gewuenschter_Kartentyp__c == 'Single Network Card -- National') {
            originalContent.put('pumpOutsideCountry', 'false');
            originalContent.put('pumpAtPartners', 'false');
        } 
        else if (opportunity.Tankkarten__r.get(0).Gewuenschter_Kartentyp__c == 'Multi Network Card -- National') {
            originalContent.put('pumpOutsideCountry', 'false');
            originalContent.put('pumpAtPartners', 'true');
        }
        originalContent.put('opportunity_id', opportunity.Id);
        originalContent.put('account_id', opportunity.AccountId);

        return originalContent;
    }

    private void selectRecord(String recordId) {
        String sobjectName = getSobjectName(recordId);
        String query = 'SELECT ' + soqlFieldsMap.get(sobjectName) + ' FROM ' + sobjectName + ' WHERE Id = :recordId';
        SObject record = Database.query(query);
        this.sobjectsMap.put(sobjectName, record);
    }

    public void updateRecords(Map<String, Object> data) {
        AccountTriggerHandler.enablesTrigger = false;
        ContactTriggerHandler.enablesTrigger = false;
        OpportunityTriggerHandler.enablesTrigger = false;
        OpportunityTriggerHandler.isE2EForm = true;
        TankkartenHandler.enablesTrigger = false;
        Opportunity opportunity = new Opportunity();
        opportunity.Id = (String)data.get('opportunity_id');
        opportunity.Anzahl_der_Karten__c = Integer.valueOf(data.get('number_of_cards'));
        opportunity.E2E_Active_Step__c = 6; // TO REVIEW FOR DYNAMIC
        update opportunity;

        delete [SELECT Id FROM Tankkarten__c WHERE Opportunity__c = :opportunity.Id];

        List<Tankkarten__c> cards = new List<Tankkarten__c>();
        for (Integer i = 0; i < opportunity.Anzahl_der_Karten__c; i++) {
            Tankkarten__c card = new Tankkarten__c(Opportunity__c = opportunity.Id);
            if (Boolean.valueOf(data.get('pumpOutsideCountry')) &&
                Boolean.valueOf(data.get('pumpAtPartners'))) {
                    card.Gewuenschter_Kartentyp__c = 'Multi Network Card -- International';
            } 
            else if ( ! Boolean.valueOf(data.get('pumpOutsideCountry')) &&
                     Boolean.valueOf(data.get('pumpAtPartners'))) {
                    card.Gewuenschter_Kartentyp__c = 'Multi Network Card -- National';    
            }
            else if (Boolean.valueOf(data.get('pumpOutsideCountry')) &&
                     ! Boolean.valueOf(data.get('pumpAtPartners'))) {
                    card.Gewuenschter_Kartentyp__c = 'Single Network Card -- International';    
            }
            else if (! Boolean.valueOf(data.get('pumpOutsideCountry')) &&
                     ! Boolean.valueOf(data.get('pumpAtPartners'))) {
                    card.Gewuenschter_Kartentyp__c = 'Single Network Card -- National';    
            }

            if ((String)data.get('category') == 'Diesel') {
                card.Produktbezugskategorie__c = '0 Diesel, Tunnel-, Maut- und Fährgebühren';
            } 
            else if ((String)data.get('category') == 'All fuel types') {
                card.Produktbezugskategorie__c = '1 Alle Kraftstoffe, Tunnel-, Maut- und Fährgebühren';
            }
            else if ((String)data.get('category') == 'All vehicle related product') {
                card.Produktbezugskategorie__c = '2 Kategorie 1 plus fahrzeugbezogene Waren und Dienstleistungen (Öle, Autowäsche)';
            }
            cards.add(card);
        }
        insert cards;
    }

    private SObject getRecord(String sobjectName) {
        return sobjectsMap.get(sobjectName);
    }

    private Object addParamToField(Object field, String parameter, String value) {
        Map<String, Object> fieldMap = (Map<String, Object>)field;
        fieldMap.put(parameter,  value);
        return fieldMap;
    }

    private String getSobjectName(String recordIdStr) {
        Id recordId = Id.valueOf(recordIdStr);
        String sobjectName = String.valueOf(recordId.getSobjectType());

        return sobjectName;
    }

    private void disableTriggers() {
        AccountTriggerHandler.enablesTrigger = false;
        ContactTriggerHandler.enablesTrigger = false;
        OpportunityTriggerHandler.enablesTrigger = false;
        OpportunityTriggerHandler.isE2EForm = true;
    }
}