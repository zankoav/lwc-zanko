public class E2EContactDetailsBasicImpl implements E2EContactDetails {    
    private Map<String, Object> content;

    public void selectContent(String jsonSettings, String source) {
        E2EContactDetailsDAO dao = new E2EContactDetailsDAOImpl();
        dao.selectSettings(jsonSettings);        
        StaticResource settings = (StaticResource)dao.getSettings();
        this.content = (Map<String, Object>)JSON.deserializeUntyped(settings.Body.toString());
        this.content.put('first_name', addParamToField(this.content.get('first_name'), 'validationRegex', String.valueOf(E2E_Regex__c.getInstance('de_first_name').Regex__c)));
        this.content.put('last_name', addParamToField(this.content.get('last_name'), 'validationRegex', String.valueOf(E2E_Regex__c.getInstance('de_last_name').Regex__c)));
        this.content.put('phone', addParamToField(this.content.get('phone'), 'validationRegex', String.valueOf(E2E_Regex__c.getInstance('de_phone').Regex__c)));
        this.content.put('email', addParamToField(this.content.get('email'), 'validationRegex', String.valueOf(E2E_Regex__c.getInstance('de_email').Regex__c)));

        if (source != null) {
            this.content = dao.addDataFromDatabase(content, source);
        }
    }

    public Map<String, Object> getContent() {
        return this.content;
    }

    public void setContent(Map<String, Object> data) {
        this.content = data;
    }

    public String save() {
        Integer startCPU = Limits.getCpuTime();
        System.debug('DEBUG: startCPU === ' + startCPU);
        this.content.put('phone',returnPhone((String)content.get('phone'),'Germany'));
        E2EContactDetailsDAO dao = new E2EContactDetailsDAOImpl();
        String source;
        if (this.content.containsKey('opportunity_id') && this.content.get('opportunity_id') != null) {
            // update            
            source = dao.updateRecords(this.content);
        } else {
            // insert
            source = dao.insertRecords(this.content);
        }
        Integer endCPU = Limits.getCpuTime();
        System.debug('DEBUG: endCPU === ' + endCPU);
        System.debug('DEBUG: Processing time === ' + (endCPU - startCPU));

        return source;
    }

    public void validate() {
        validateField((String)this.content.get('first_name'), String.valueOf(E2E_Regex__c.getInstance('de_first_name').Regex__c));
        validateField((String)this.content.get('last_name'), String.valueOf(E2E_Regex__c.getInstance('de_last_name').Regex__c));
        validateField((String)this.content.get('email'), String.valueOf(E2E_Regex__c.getInstance('de_email').Regex__c));
        validateField((String)this.content.get('phone'), String.valueOf(E2E_Regex__c.getInstance('de_phone').Regex__c));
    }

    private void validateField(String fieldValue, String regex) {
        if (regex == null) {
            System.debug('DEBUG: EXCEPTION EMPTY REGEX === ');
            return;
        }
        Pattern lettersPattern = Pattern.compile(regex);
        Matcher lettersMatcher = lettersPattern.matcher(fieldValue);
        if ( ! lettersMatcher.matches() || fieldValue == '' || fieldValue == null) {
            throw new E2EException('Invalid field value' + fieldValue + ', regex: ' + regex);
        }
    }

    private String returnFieldValue(Object field, String parameter) {
        return String.valueOf(((Map<String, Object>)field).get(parameter));
    }

    private Object addParamToField(Object field, String parameter, String value) {
        Map<String, Object> fieldMap = (Map<String, Object>)field;
        fieldMap.put(parameter,  value);
        return fieldMap;
    }

    private String returnPhone(String phone, String country) {
        if (country == 'Germany' && phone != null && phone.contains('+490')) {
            phone = phone.replace('+490','+49');
        }

        return phone;
    }
}