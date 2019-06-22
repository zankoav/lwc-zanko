public interface E2EAdditionalParameters {
    void setContent(Map<String, Object> content);
    Map<String, Object> getContent();
    void selectContent(String jsonSettings, String source);
    void save();
}