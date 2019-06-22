public interface E2EContactDetails {
    void setContent(Map<String, Object> content);
    Map<String, Object> getContent();
    void selectContent(String jsonSettings, String source);
    void validate();
    String save();
}