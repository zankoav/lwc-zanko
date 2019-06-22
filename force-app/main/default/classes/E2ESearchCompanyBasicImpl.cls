public class E2ESearchCompanyBasicImpl implements E2ESearchCompany {
    private Map<String, Object> content;

    public void selectContent(String jsonSettings, String source) {
        E2ESearchCompanyDAO dao = new E2ESearchCompanyDAOImpl();
        dao.selectSettings(jsonSettings);        
        StaticResource settings = (StaticResource)dao.getSettings();
        this.content = (Map<String, Object>)JSON.deserializeUntyped(settings.Body.toString());
        this.content.put('company_name', addParamToField(this.content.get('company_name'), 'validationRegex', String.valueOf(E2E_Regex__c.getInstance('de_company_name').Regex__c)));
        this.content.put('city', addParamToField(this.content.get('city'), 'validationRegex', String.valueOf(E2E_Regex__c.getInstance('de_city').Regex__c)));

        if (source != null) {
            this.content = dao.addDataFromDatabase(content, source);
        }
    }

    public Map<String, Object> getContent() {
        return this.content;
    }

    public void setContent(Map<String, Object> data) {
        this.content = data;
    }

    public void saveCompany() {
        E2ESearchCompanyDAO dao = new E2ESearchCompanyDAOImpl();
        dao.updateRecords(this.content, false);
    }

    public void save() {
        E2ESearchCompanyDAO dao = new E2ESearchCompanyDAOImpl();
        dao.setReportIdsToDelete(this.content);
        String opportunityId = (String)this.content.get('opportunity_id');
        Opportunity opp = [
            SELECT E2E_Encoded_URL__c, Name, AccountId, E2E_Active_Step__c, 
                   Account.Name, Account.ShippingCity, Account.BillingCity
            FROM Opportunity 
            WHERE Id = :opportunityId];
        generateCreditfactoryReport(opp, (String)this.content.get('selected_company_id'));
        dao.updateRecords(this.content, true);
        dao.deleteReports();
    }

    public List<CreditCompany> search() {
        E2ESearchCompanyDAO dao = new E2ESearchCompanyDAOImpl();
        String opportunityId = (String)content.get('opportunity_id');
        List<CreditCompany> finalList = new List<CreditCompany>();
        CreditSystemService creditService = new CreditSystemService();
        creditService.setCreditSystemSource(opportunityId);
        String creditSystemName = creditService.getCreditSystemName();
        CreditFactoryFinderController cfFinder = new CreditFactoryFinderController();
        Finder finderService = cfFinder.returnFinderService(creditSystemName);
        finderService.setUserSource('E2E Long Form');
        //Set and validate mapping
        finderService.setMapping();
        finderService.validateMapping();
        finderService.getSourceObject(opportunityId);
        List<CreditCompany> companiesTempList = finderService.searchCompany(creditService);
        if (! companiesTempList.isEmpty() ) {
            for (CreditCompany company : companiesTempList) {
                if (company.identificationnumber != null) {
                    finalList.add(company);
                }
            }
        }

        return finalList;
    }


    public void validate() {
        validateField((String)this.content.get('company_name'), String.valueOf(E2E_Regex__c.getInstance('de_company_name').Regex__c));
        validateField((String)this.content.get('city'), String.valueOf(E2E_Regex__c.getInstance('de_city').Regex__c));
    }

    private void generateCreditfactoryReport(Opportunity opportunity, String selectedCompanyId) {       
        CreditFactoryReportController cfReportCtrl = new CreditFactoryReportController();
        cfReportCtrl.creditService = new CreditSystemService();
        cfReportCtrl.creditService.setCreditSystemSource(opportunity.Id);
        String creditSystemName = cfReportCtrl.creditService.getCreditSystemName();
        cfReportCtrl.reportService = cfReportCtrl.returnReportService(creditSystemName, opportunity.Id);
        cfReportCtrl.reportService.setUserSource('E2E Long Form');
        cfReportCtrl.reportService.setMapping();
        //set opportunity record
        cfReportCtrl.reportService.setSourceObject(opportunity.Id);
        //get credit report from SF if exists
        // DELETED FOR TEST !!!cfReportCtrl.reportService.setExistingCreditReports();
        //send request, get company and employees
        cfReportCtrl.reportService.setCompany(cfReportCtrl.creditService, selectedCompanyId);
        cfReportCtrl.company = (CreditCompany)cfReportCtrl.reportService.getCompany();
        cfReportCtrl.reportService.setEmployees();
        // if (cfReportCtrl.reportService.getErrorToOrderRequest() != null) {
        //     throw new LongFormException(E2EExceptionUtils.errorsMap.get('Report does not exist'));
        // }
        // doCheckAuthorizatedGranted();
        cfReportCtrl.isSales = cfReportCtrl.reportService.isSales();
        cfReportCtrl.calculateBillingPeriod();
        //create PDF Report
        Boolean isPdfCreated = cfReportCtrl.reportService.doCreateReportAttachment(opportunity.Id);
        if (isPdfCreated) {
            cfReportCtrl.reportService.updateOpportunityWithPDF(opportunity);
        }
        cfReportCtrl.reportService.saveReports();        
    }    

    private Object addParamToField(Object field, String parameter, String value) {
        Map<String, Object> fieldMap = (Map<String, Object>)field;
        fieldMap.put(parameter,  value);
        return fieldMap;
    }

    private void validateField(String fieldValue, String regex) {
        Pattern lettersPattern = Pattern.compile(regex);
        Matcher lettersMatcher = lettersPattern.matcher(fieldValue);
        if ( ! lettersMatcher.matches() || fieldValue == '' || fieldValue == null) {
            throw new E2EException('Invalid field ' + fieldValue);
        }
    }

    private String returnFieldValue(Object field, String parameter) {
        return (String)((Map<String, Object>)field).get(parameter);
    }
}