public interface LFPaymentOptions {
    void setPagesMap(String deviceView);
    Map<String, LongFormPage> getPagesMap();
    void updateOpportunityOnReturnFromEmail(String deviceView);
    void validate(Decimal activeStep, String activeSubstep);
    Boolean jsValidateIBAN();
    Boolean requestSwiftInfo();
    void savePaymentOptionsDataWithoutDeposit(String activeSubstep);
    void savePaymentOptionsDataWithDeposit(String activeSubstep);
    void goToThanksPageFromPaymentSystem(String paymentStatus);
    void setSFobjects(String opptyId);
    void doSaveAndContinueLater();
    Account getAccount();
    void setOpportunity(Id opptyId);
    Opportunity getOpportunity();
    Contact getContact();  
    void updatePaymentMethod(String paymentMethod);
    void prepareTransaction(String deviceView);
    void saveTransactionData();
    void receiveFreeBonus(Integer numberOfCards);
    Map<String, String> getPaymentMap();
}