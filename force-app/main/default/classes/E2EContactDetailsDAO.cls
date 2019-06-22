public interface E2EContactDetailsDAO {
	void selectSettings(String name);
	Sobject getSettings();
	Map<String, Object> addDataFromDatabase(Map<String, Object> originalContent, String source);
	String insertRecords(Map<String, Object> content);
	String updateRecords(Map<String, Object> content);
}