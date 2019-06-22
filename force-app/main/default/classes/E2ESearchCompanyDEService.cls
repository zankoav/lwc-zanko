public class E2ESearchCompanyDEService extends E2ESearchCompanyAbstract {


	public override void save(Map<String, E2EContentJson.ContentElement> contentsMap) {
		disableTriggers();
		Opportunity opportunity = getOpportunity();
		opportunity.Name = contentsMap.get('COMPANY NAME').value;
		update opportunity;
		setOpportunity(opportunity);

		Account account = getAccount();
		account.Name = contentsMap.get('COMPANY NAME').value;
		account.BillingCity = contentsMap.get('CITY').value;
		update account;
		setAccount(account);
	}

    public override List<CreditCompany> search() {
    	disableTriggers();
    	List<CreditCompany> companiesList = setCompaniesFromCF();

    	return companiesList;
    }

    public override void selectCompany(String selectedCompanyId) {
    	disableTriggers();
    	Opportunity opportunity = getOpportunity();        
    	Set<Id> itemsSet = returnItemsToDelete(opportunity.Id);
    	generateCreditfactoryReport(opportunity, selectedCompanyId);
        opportunity.E2E_Active_Step__c = 2;
        update opportunity;
    	deleteItems(itemsSet);
    }

    public override void validate() {
    	disableTriggers();
    	validateCompanyName();
    	validateCity();
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

    private Set<Id> returnItemsToDelete(String opportunityId) {
    	Opportunity opportunity = getOpportunity();
    	Map<Id, Credit_Factory_Report__c> reportsMap = new Map<Id, Credit_Factory_Report__c>([
    			SELECT Id 
    			FROM Credit_Factory_Report__c 
    			WHERE Opportunity__c = :opportunityId]);

    	Map<Id, Attachment> attachmentsMap = new Map<Id, Attachment>([
    			SELECT Id
    			FROM Attachment
    			WHERE ParentId = :opportunityId AND 
    				  Name = 'CrefoReport.pdf']);
    	Set<Id> itemsSet = new Set<Id>();
    	itemsSet.addAll(reportsMap.keySet());
    	itemsSet.addAll(attachmentsMap.keySet());

    	return itemsSet;
    }

    private void deleteItems(Set<Id> itemsToDeleteSet) {
    	delete [SELECT Id FROM Attachment WHERE Id IN :itemsToDeleteSet];
    	delete [SELECT Id FROM Credit_Factory_Report__c WHERE Id IN :itemsToDeleteSet];
    }

    private void validateCompanyName() {

    }

    private void validateCity() {

    }

    private List<CreditCompany> setCompaniesFromCF() {
    	List<CreditCompany> finalList = new List<CreditCompany>();
    	Opportunity opportunity = getOpportunity();
        CreditSystemService creditService = new CreditSystemService();
        creditService.setCreditSystemSource(opportunity.Id);
        String creditSystemName = creditService.getCreditSystemName();
        CreditFactoryFinderController cfFinder = new CreditFactoryFinderController();
        Finder finderService = cfFinder.returnFinderService(creditSystemName);
        finderService.setUserSource('E2E Long Form');
        //Set and validate mapping
        finderService.setMapping();
        finderService.validateMapping();
        finderService.getSourceObject(opportunity.Id);
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

    private void disableTriggers() {
        AccountTriggerHandler.enablesTrigger = false;
        ContactTriggerHandler.enablesTrigger = false;
        OpportunityTriggerHandler.enablesTrigger = false;
        OpportunityTriggerHandler.isE2EForm = true;
    }
}