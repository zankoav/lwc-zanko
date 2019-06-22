public class E2ETotalConsumptionBasicImpl implements E2ETotalConsumption {
    private Map<String, Object> content;

    public void selectContent(String jsonSettings, String source) {
        E2ETotalConsumptionDAO dao = new E2ETotalConsumptionDAOImpl();
        dao.selectSettings(jsonSettings);        
        StaticResource settings = (StaticResource)dao.getSettings();
        this.content = (Map<String, Object>)JSON.deserializeUntyped(settings.Body.toString());
        this.content.put('total_consumption', addParamToField(this.content.get('total_consumption'), 'validationRegex', String.valueOf(E2E_Regex__c.getInstance('de_total_consumption').Regex__c)));

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
        validateField((String)content.get('total_consumption'), String.valueOf(E2E_Regex__c.getInstance('de_total_consumption').Regex__c));
    }

    public void save() {
        E2ETotalConsumptionDAO dao = new E2ETotalConsumptionDAOImpl();
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