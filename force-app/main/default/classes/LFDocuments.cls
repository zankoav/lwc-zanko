public interface LFDocuments {
    void setPagesMap(String deviceView);
    void updateOpportunityOnReturnFromEmail(String deviceView);
    Map<String, LongFormPage> getPagesMap();
    void validateAgreements();
    void saveDocumentsStepData();
    void saveDepositAgreementStepData();
    void goToPaymentOptions();
    void goToCongratulations();
    void setSFobjects(String opptyId);
    void doSaveAndContinueLater();
    Account getAccount();
    Opportunity getOpportunity();
    Contact getContact();
}