public class E2EAdditionalParametersBasicImpl implements E2EAdditionalParameters {
    private Map<String, Object> content;

    public void selectContent(String jsonSettings, String source) {
        E2EAdditionalParametersDAO dao = new E2EAdditionalParametersDAOImpl();
        dao.selectSettings(jsonSettings);        
        StaticResource settings = (StaticResource)dao.getSettings();
        this.content = (Map<String, Object>)JSON.deserializeUntyped(settings.Body.toString());

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

    public void save() {
        E2EAdditionalParametersDAO dao = new E2EAdditionalParametersDAOImpl();
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