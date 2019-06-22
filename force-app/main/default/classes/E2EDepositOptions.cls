public interface E2EDepositOptions {
	void setContent(Map<String, Object> content);
    Map<String, Object> getContent();
    void selectContent(String jsonSettings, String source);
    void validate();
    void save();
}