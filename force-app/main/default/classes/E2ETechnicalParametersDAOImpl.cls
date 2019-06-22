public class E2ETechnicalParametersDAOImpl implements E2ETechnicalParametersDAO {
    private Map<String, SObject> sobjectsMap;
    private Sobject jsonSettings;
    private Map<String, String> soqlFieldsMap = new Map<String, String>{
        'Opportunity' => 'E2E_Encoded_URL__c, Name, AccountId, E2E_Active_Step__c, ' +
                         '(SELECT Driver_Name__c, Fahrzeugtyp__c, Firmenname_auf_der_Karte__c, Gewuenschter_Kartentyp__c, GFNI_Status__c, ' + 
                         ' Kilometerstand_Abfrage__c, KFZ_Kennzeichen_oder_Fahrername__c, Produktbezugskategorie__c ' + 
                         ' FROM Tankkarten__r)'
    };

    public E2ETechnicalParametersDAOImpl() {
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
        originalContent.put('opportunity_id', opportunity.Id);
        originalContent.put('account_id', opportunity.AccountId);

        List<Object> cardsList = new List<Object>();
        Integer i = 1;
        for (Tankkarten__c card : opportunity.Tankkarten__r) {
            Map<String, Object> dataMap = new Map<String, Object>();
            if (card.Driver_Name__c != null) {
                dataMap.put('status', 'done');
                dataMap.put('card_name', card.Driver_Name__c);
            } else {
                dataMap.put('status', 'open');
                dataMap.put('card_name', 'Shell Card');
            }

            if (card.Produktbezugskategorie__c == '0 Diesel, Tunnel-, Maut- und Fährgebühren') {
                dataMap.put('card_type', 'Diesel');
            } 
            else if (card.Produktbezugskategorie__c == '1 Alle Kraftstoffe, Tunnel-, Maut- und Fährgebühren') {
                dataMap.put('card_type', 'All fuel types');
            } 
            else if (card.Produktbezugskategorie__c == '2 Kategorie 1 plus fahrzeugbezogene Waren und Dienstleistungen (Öle, Autowäsche)') {
                dataMap.put('card_type', 'All vehicle related product');
            }
            
            if (card.Gewuenschter_Kartentyp__c == 'Single Network Card -- International') {
                dataMap.put('internal_pump', 'true');
                dataMap.put('partners_pump', 'false');
            } 
            else if (card.Gewuenschter_Kartentyp__c == 'Multi Network Card -- International') {
                dataMap.put('internal_pump', 'true');
                dataMap.put('partners_pump', 'true');
            } 
            else if (card.Gewuenschter_Kartentyp__c == 'Single Network Card -- National') {
                dataMap.put('internal_pump', 'false');
                dataMap.put('partners_pump', 'false');
            } 
            else if (card.Gewuenschter_Kartentyp__c == 'Multi Network Card -- National') {
                dataMap.put('internal_pump', 'false');
                dataMap.put('partners_pump', 'true');
            }

            if (card.Firmenname_auf_der_Karte__c == null) {
                dataMap.put('company_name', opportunity.Name);
            } else {
                dataMap.put('company_name', card.Firmenname_auf_der_Karte__c);                
            }
            
            dataMap.put('card_id', card.Id);            
            // Map<String, Object> typeOfCar = new Map<String, Object>();
            // typeOfCar.put('value', card.Fahrzeugtyp__c);
            if (card.Fahrzeugtyp__c == null) {
                dataMap.put('type_of_car', 'PKW');
            } else {
                dataMap.put('type_of_car', card.Fahrzeugtyp__c);
            }
            
            if (card.Kilometerstand_Abfrage__c) {
                dataMap.put('need_odometer_options', 'EIN');
            } else {
                dataMap.put('need_odometer_options', 'AUS');
            }
            cardsList.add(dataMap);
            i++;
        }

        originalContent.put('cards', cardsList);
        System.debug('DEBUG: originalContent === ' + originalContent);

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
        opportunity.E2E_Active_Step__c = 8; // TO REVIEW FOR DYNAMIC
        update opportunity;

        List<Tankkarten__c> cardsToUpdate = new List<Tankkarten__c>();
        List<Object> cardsList = (List<Object>)data.get('cards');
        System.debug('DEBUG: cardsList === ' + cardsList);
        for (Object cardTemp : cardsList) {
            String jsonStr = JSON.serialize(cardTemp);
            Map<String, Object> card = (Map<String, Object>)JSON.deserializeUntyped(jsonStr);
            // Map<Object, Object> card = (Map<Object, Object>)cardTemp;
            Tankkarten__c databaseCard = new Tankkarten__c();
            databaseCard.Id = (String)card.get('card_id');
            databaseCard.Fahrzeugtyp__c = (String)(card.get('type_of_car'));
            databaseCard.Driver_Name__c = (String)(card.get('card_name'));
            if (card.get('need_odometer_options') == 'EIN') {
                databaseCard.Kilometerstand_Abfrage__c = true;
            } else {
                databaseCard.Kilometerstand_Abfrage__c = false;
            }
            
            cardsToUpdate.add(databaseCard);
        }
        update cardsToUpdate;
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