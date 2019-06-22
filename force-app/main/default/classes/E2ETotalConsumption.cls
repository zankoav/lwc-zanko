public interface E2ETotalConsumption {
    void setContent(Map<String, Object> content);
    Map<String, Object> getContent();
    void selectContent(String jsonSettings, String source);
    void validate();
    void save();
}