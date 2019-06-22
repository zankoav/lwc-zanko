public interface E2ESearchCompanyDAO {
	void selectSettings(String name);
	Sobject getSettings();
	Map<String, Object> addDataFromDatabase(Map<String, Object> originalContent, String source);
	void updateRecords(Map<String, Object> content, Boolean isContinue);
	void setReportIdsToDelete(Map<String, Object> content);
	void deleteReports();
}