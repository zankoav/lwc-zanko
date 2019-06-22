public interface LFAdditional {
    void setPagesMap(String deviceView);
    Map<String, LongFormPage> getPagesMap();
    void updateOpportunityOnReturnFromEmail(String deviceView);
    void setSFobjects(String opptyId);
    void doSaveAndContinueLater();
    Account getAccount();
    Opportunity getOpportunity();
    Contact getContact();
    void updateRecords();
}