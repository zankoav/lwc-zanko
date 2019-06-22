public interface E2EFormRuService {

    //******* Content Service *****//
    void collectContent(String country, String stepName, Map<String, LongFormPage> pagesMap, GlobalUtils.DeviceType deviceType);
    void collectSharedResource(String country, Map<String, LongFormPage> pagesMap, GlobalUtils.DeviceType deviceType, String source);
    void collectContentDataByLink(Id formDataId, String stepName, Map<String, LongFormPage> pagesMap, E2EFormParams formParams, Map<String, LongFormTariff> msl_suffix, Map<String, String> objectIds);

    //****** Account Service *****//
    Id createAccount(E2EFormParams formParams);
    void updateAccount(Id accountId, Map<String, LongFormPage> pagesMap, E2EFormParams formParams, String step);
    Account getAccountById(Id accountId);
    void deleteAccountById(Id accountId);

    //****** Contact Service *****//
    Id createContact(Id accountId, Map<String, LongFormPage> pagesMap, E2EFormParams formParams);
    Id createEmployeeContact(Id accountId, String employeeFio, String title);
    void updateContact(Id contactId, Map<String, LongFormPage> pagesMap, E2EFormParams formParams, String step);
    void updateEmployeeContact(Id contactId, String employeeFio, String title);
    Contact getContactById(Id contactId);
    void updateContactPhone(Id contactId, String phone);

    //****** Opportunity Service *****//
    Id createOpportunity(Id accountId, E2EFormParams formParams);
    void updateOpportunity(Id opportunityId, Map<String, LongFormPage> pagesMap, E2EFormParams formParams, String step);
    Opportunity getOpportunityById(Id opportunity);
    void forceUpdateOpportunity(Id opportunityId, String error);
    void updateEncodedUrl(Id opportunityId, Id formDataId, E2EFormParams formParams);

    //****** OpportunityContactRole Service *****//
    void createOpportunityContactRoles(Id opportunityId, Id accountId, Map<String, LongFormPage> pagesMap, String step);
    void updateOpportunityContactRole(Id opportunityId, Id contactId, String role, Boolean isPrimary);

    //****** Document Service *****//
    Id createDocument(String name, Blob content, String contentType, Id folderId);

    //****** Form Service *****//
    Id createFormDataRecord(Id accountId, Id contactId, Id opportunityId, Map<String, LongFormPage> pagesMap, E2EFormParams formParams);
    void updateFormData(Id formDataId, Map<String, LongFormPage> pagesMap, E2EFormParams formParams, String step, String source);
    E2EFormData__c getFormDataById(Id formDataRecordId);
    void prepareFormParamsData(E2EFormParams e2EFormParams, String opportunityId);
    void changeObjectOwner(Id objectId, String newUserName);

    //******* Duplicate Process *****//
    void duplicateLeadProcess(Map<String, LongFormPage> pagesMap);
    Map<String, String> deduplicateE2EClient(String name, Map<String, LongFormPage> pagesMap);
    E2EFormRuDeduplicationResult deduplicationAccountProcess(String INN, String email, Id e2eAccountId, Id e2eContactId, Id e2eOpportunityId, Id formDataId);
    E2EFormRuDeduplicationResult deduplicationAccountProcess(String INN, String email, E2EFormRuDeduplicationResult deduplicationResult);
    E2EFormRuDeduplicationResult transferCustomer(E2EFormRuDeduplicationResult deduplicationResult);

    //******* Report Service Integration *****//
    ReportRequestData prepareReportRequestData(Id formDataId, E2EFormParams formParams, Map<String, LongFormPage> pagesMap, Boolean preview);

    //******* Transit Integration *****//
    TransitRequestData prepareTransitRequestData(Id formDataId, E2EFormParams formParams, Map<String, LongFormPage> pagesMap);
    TransitDocLinkRequestData prepareTransitDocLinkRequestData(ReportResponseData responseData, E2EFormParams formParams);

    //******** MZK Integration ********//
    MZKRequest prepareMzkRequest(Id formDataId, E2EFormParams formParams);

    //******** Crm Integration ********//
    CrmTask prepareCrmRequest(String phone, String email, String inn, List<Opportunity> opportunities);


    void collectDataFromSpark(Id formDataId, Id accountId, E2EFormParams formParams);

    //********* Email Notification *********//
    void sendE2ENotification(String body, String subject, GlobalUtils.E2ERuGroupsNotification additionalGroupsNotification);
    String getEmailBodyCoordinationWithRiskManagementDepartment(Id opportunityId);
    String getEmailBodyForReseller(Id opportunityId);
    String getEmailBodyOfManualEntryNotification(Id opportunityId);
    String getEmailBodyOfCardLimitExceeded(Id opportunityId);
    String getEmailBodyTransferToInboundFromCallCenter(Id opportunityId);
    String getEmailBodyNotificationCallCenter(Id opportunityId, String opportunityName);
    String getEmailBodyTransferToKOMore10Cards(Boolean isManualEntry, Integer cardsNumber, Id opportunityId);
    String getEmailBodyTransferToKOManualEntry(Id opportunityId);

    //******* Remote Actions *****//
    void updateSoleProprietorInfoFromSpark(E2EFormParams formParams, String formDataId);
    void updateCompanyInformationFromSpark (E2EFormParams formParams, String formDataId, String opportunityId);
    void updateVerifiedDecision(E2EFormParams formParams, String formDataId, String opportunityId);
    void updateScoringDecision(E2EFormParams formParams, String formDataId, String opportunityId);
}