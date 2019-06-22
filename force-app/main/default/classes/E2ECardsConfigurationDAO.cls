public interface E2ECardsConfigurationDAO {
	void selectSettings(String name);
	Sobject getSettings();
	Map<String, Object> addDataFromDatabase(Map<String, Object> originalContent, String source);
	void updateRecords(Map<String, Object> content);
}