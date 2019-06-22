public interface E2ECreditScoring {
    void setContent(Map<String, Object> content);
    Map<String, Object> getContent();
    void selectContent(String jsonSettings, String source);
    void changeBillingPeriod(String billing_period);
    void changeCreditLimit(Map<String, Object> data);
    void save();
}