public class E2ECardsConfigurationBasicImpl implements E2ECardsConfiguration {
    private Map<String, Object> content;

    public void selectContent(String jsonSettings, String source) {
        E2ECardsConfigurationDAO dao = new E2ECardsConfigurationDAOImpl();
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
        E2ECardsConfigurationDAO dao = new E2ECardsConfigurationDAOImpl();
        dao.updateRecords(this.content);
    }
}