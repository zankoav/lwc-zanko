/**
 * Created by Nikita.Mikhailov on 26.02.2019.
 */

public with sharing class GFNI_LogReportAPI {

    public String idValueSearch { get; set; }
    public String countryValueSearch { get; set; }
    public Boolean isFinishedValueSearch { get; set; }
    public Integer totalSize { get; set; }
    public Date startDate { get; set; }
    public Date endDate { get; set; }

    private GFNI_LogDAO logDAO;

    public GFNI_LogReportAPI(Date startDate, Date endDate, GFNI_LogDAO logDAO) {
        this.startDate = startDate;
        this.endDate = endDate;
        this.totalSize = 0;
        this.logDAO = logDAO;
    }

    public void setFilteringValues(String idValueSearch, String countryValueSearch, Boolean isFinishedValueSearch) {
        this.idValueSearch = idValueSearch;
        this.countryValueSearch = countryValueSearch;
        this.isFinishedValueSearch = isFinishedValueSearch;
    }

    /*******************************************************************************
    *  Name            : createReportRecords
    *  Summary         : Creates GFNI_LogReport using data from GFNI_OpportunityLog__b
    *  CreatedDate     : 26.02.2019
    *  Returns         : List<GFNI_LogReportRecord>
    ******************************************************************************/
    public List<GFNI_LogReportRecord> createReportRecords() {

        if (this.logDAO == null)
            this.logDAO = new GFNI_LogDAO();

        List<GFNI_Opportunity_log__b> logs = this.logDAO.queryLog(this.startDate, this.endDate);

        Map<Id, GFNI_LogReportRecord> reportRecords = new Map<Id, GFNI_LogReportRecord>();

        for (GFNI_Opportunity_log__b log : logs) {

            if (String.isNotBlank(this.idValueSearch)) {
                if (log.Opportunity__c != idValueSearch)
                    continue;
            }

            if (reportRecords.containsKey(log.Opportunity__c)) {
                reportRecords.get(log.Opportunity__c).recordDate = log.RecordDateTime__c;
                if (log.IsFirst__c != null) {
                    reportRecords.get(log.Opportunity__c).hasFirst = log.IsFirst__c == 1 ? true : false;
                } else {
                    reportRecords.get(log.Opportunity__c).hasFirst = null;
                }
                continue;
            }

            GFNI_LogReportRecord reportRecord = new GFNI_LogReportRecord();
            reportRecord.message = log.Message__c;
            reportRecord.recordDate = log.RecordDateTime__c;
            if (log.IsFirst__c != null)
                reportRecord.hasFirst = log.IsFirst__c == 1 ? true : false;

            reportRecords.put(log.Opportunity__c, reportRecord);
        }

        List<Opportunity> opportunities = [
                SELECT Id, Registered_Country__c, Language_preference__c, GFN_Nr__c, Zahlungsart__c,
                        Product__c, GFNI_ApplicationId__c, Account.Name, Account.Account_Nr__c, AccountId, Account.BillingCountryCode, (SELECT Id FROM Tankkarten__r WHERE GFNI_Status__c = 'Pending' OR GFNI_Status__c = 'Failed' LIMIT 1)
                FROM Opportunity
                WHERE Id IN :reportRecords.keySet()
        ];

        List<GFNI_LogReportRecord> finalReport = new List<GFNI_LogReportRecord>();

        for (Opportunity opportunity : opportunities) {
            GFNI_LogReportRecord reportRecord = reportRecords.get(opportunity.Id);

            if (String.isNotBlank(this.countryValueSearch)) {
                if (opportunity.Registered_Country__c != this.countryValueSearch) {
                    reportRecords.remove(opportunity.Id);
                    continue;
                }
            }

            if (reportRecord.hasFirst == null) {
                reportRecords.remove(opportunity.Id);
                continue;
            } else {
                if (!reportRecord.hasFirst) {
                    reportRecords.remove(opportunity.Id);
                    continue;
                }
            }

            if (this.isFinishedValueSearch != null) {
                if ((opportunity.GFN_Nr__c != null && opportunity.GFNI_ApplicationId__c != null && opportunity.Tankkarten__r.isEmpty()) != isFinishedValueSearch) {
                    reportRecords.remove(opportunity.Id);
                    continue;
                }
            }

            reportRecord.registeredCountry = GlobalUtils.getPicklistValueTranslation(Schema.Opportunity.Registered_Country__c.getDescribe(), opportunity.Registered_Country__c);
            reportRecord.languagePreference = GlobalUtils.getPicklistValueTranslation(Schema.Opportunity.Language_preference__c.getDescribe(), opportunity.Language_preference__c);
            reportRecord.accountNumberSF = GlobalUtils.blankStringIfNull(opportunity.Account.Account_Nr__c);
            reportRecord.accountNumberGFN = GlobalUtils.blankStringIfNull(opportunity.GFN_Nr__c);
            reportRecord.accountName = GlobalUtils.blankStringIfNull(opportunity.Account.Name);
            reportRecord.accountId = opportunity.AccountId;
            reportRecord.product = GlobalUtils.getPicklistValueTranslation(Schema.Opportunity.Product__c.getDescribe(), opportunity.Product__c);

            if (opportunity.GFN_Nr__c != null && opportunity.GFNI_ApplicationId__c != null && opportunity.Tankkarten__r.isEmpty()) {
                reportRecord.isFinished = true;
            } else {
                reportRecord.isFinished = false;
            }

            //get product conclusion that need to be done by manual process
            Map<String, Object> conclusionByCountry = (Map<String, Object>) GlobalUtils.getValueUntypedFromJSON(GFNI_Utils.gfniMapping, 'ConclusionOffer');
            if (conclusionByCountry.containsKey(opportunity.Account.BillingCountryCode.substring(0, 2))) {
                Map<String, Object> conclusionByProduct = (Map<String, Object>) conclusionByCountry.get(opportunity.Account.BillingCountryCode.substring(0, 2));
                if (conclusionByProduct.containsKey(opportunity.Product__c)) {
                    if (conclusionByProduct.get(opportunity.Product__c) instanceof Map<String, Object>) {
                        Map<String, Object> conclusionByPaymentMethod = (Map<String, Object>) conclusionByProduct.get(opportunity.Product__c);
                        if (conclusionByPaymentMethod.containsKey(GlobalUtils.getPicklistValueTranslation(Schema.Opportunity.Zahlungsart__c.getDescribe(), opportunity.Zahlungsart__c)))
                            reportRecord.conclusion = (String) conclusionByPaymentMethod.get(GlobalUtils.getPicklistValueTranslation(Schema.Opportunity.Zahlungsart__c.getDescribe(), opportunity.Zahlungsart__c));
                    } else {
                        reportRecord.conclusion = (String) conclusionByProduct.get(opportunity.Product__c);
                    }
                }
            }

            reportRecord.opportunityId = opportunity.Id;
            reportRecord.applicationId = opportunity.GFNI_ApplicationId__c;

            finalReport.add(reportRecord);
        }

        this.totalSize = finalReport.size();

        finalReport.sort();

        return finalReport;
    }
}