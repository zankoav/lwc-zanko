public class E2ECongratulationsBasicImpl implements E2ECongratulations {
    private Map<String, Object> content;

    public void selectContent(String jsonSettings, String source) {
        E2ECongratulationsDAO dao = new E2ECongratulationsDAOImpl();
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

    public void setupBonus() {
        E2ECongratulationsDAO dao = new E2ECongratulationsDAOImpl();
        dao.updateRecords(this.content);
    }

    private String returnFieldValue(Object field, String parameter) {
        return (String)((Map<String, Object>)field).get(parameter);
    }
}