public class E2EDepositOptionsBasicImpl implements E2EDepositOptions {
    private Map<String, Object> content;

    public void selectContent(String jsonSettings, String source) {
        E2EDepositOptionsDAO dao = new E2EDepositOptionsDAOImpl();
        dao.selectSettings(jsonSettings);        
        StaticResource settings = (StaticResource)dao.getSettings();
        this.content = (Map<String, Object>)JSON.deserializeUntyped(settings.Body.toString());
        // this.content.put('account_holder', addParamToField(this.content.get('account_holder'), 'validationRegex', String.valueOf(E2E_Regex__c.getInstance('de_account_holder').Regex__c)));
        // this.content.put('iban', addParamToField(this.content.get('iban'), 'validationRegex', String.valueOf(E2E_Regex__c.getInstance('de_iban').Regex__c)));
        // this.content.put('swift', addParamToField(this.content.get('swift'), 'validationRegex', String.valueOf(E2E_Regex__c.getInstance('de_swift').Regex__c)));

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

    public void validate() {
    	// validateField((String)content.get('tax_id'), String.valueOf(E2E_Regex__c.getInstance('de_tax_id').Regex__c));
    }

    public void save() {
        E2EDepositOptionsDAO dao = new E2EDepositOptionsDAOImpl();
        dao.updateRecords(this.content);
    }

    private Object addParamToField(Object field, String parameter, String value) {
        Map<String, Object> fieldMap = (Map<String, Object>)field;
        fieldMap.put(parameter,  value);
        return fieldMap;
    }

    private void validateField(String fieldValue, String regex) {
        Pattern lettersPattern = Pattern.compile(regex);
        Matcher lettersMatcher = lettersPattern.matcher(fieldValue);
        if ( ! lettersMatcher.matches() || fieldValue == '' || fieldValue == null) {
            throw new E2EException('Invalid field ' + fieldValue);
        }
    }

    private String returnFieldValue(Object field, String parameter) {
        return (String)((Map<String, Object>)field).get(parameter);
    }
}