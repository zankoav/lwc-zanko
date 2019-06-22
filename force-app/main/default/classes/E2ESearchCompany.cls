public interface E2ESearchCompany {
    void setContent(Map<String, Object> content);
    Map<String, Object> getContent();
    void selectContent(String jsonSettings, String source);
    void validate();
    void saveCompany();
    void save();
    List<CreditCompany> search();
}