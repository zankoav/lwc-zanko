public class E2ESearchCompanyController {
    public Map<String,Object> contentsMap {get; set;}
    public Boolean isContinue {get; set;}
    public List<CreditCompany> companiesList {get; set;}
    public String stepContentName;
    public String apexServiceName;
    private E2ESearchCompany service; 

    public E2ESearchCompanyController() {} 

    public void init() {
        String source = ApexPages.currentPage().getParameters().get('source');
        if (source == null) {
            Cookie sourceCookie = ApexPages.currentPage().getCookies().get('source');
            if (sourceCookie != null) {
                source = sourceCookie.getValue();
            }
        }
        this.isContinue = false;
        Type customType = Type.forName(this.apexServiceName);
        this.service = (E2ESearchCompany)customType.newInstance();        
        this.service.selectContent(this.stepContentName, source);
        this.contentsMap = this.service.getContent();
        this.companiesList = new List<CreditCompany>();
    }

    public void setApexServiceName(String apexService) {
        if (this.apexServiceName == null) {
            this.apexServiceName = apexService;
        }        
    }
    
    public String getApexServiceName() {
        return this.apexServiceName;
    }
    
    public void setStepContentName(String stepContent) {
        if (this.stepContentName == null) {
            this.stepContentName = stepContent;
            init();
        }
    }

    public String getStepContentName() {
        return this.stepContentName;
    }  

    public void save() {
        Map<String, Object> dataMap = returnDataForSaving();
        this.service.setContent(dataMap);
        this.service.validate();
        this.service.saveCompany();
    }

    public void searchCompanies() {        
        this.companiesList = this.service.search();
    }

    public void submitStep() {
        Map<String, Object> dataMap = returnDataForSaving();
        this.service.setContent(dataMap);
        this.service.save();
        this.isContinue = true;
    }

    private Map<String, Object> returnDataForSaving() {
        Map<String, Object> dataMap = new Map<String, Object>();
        dataMap.put('company_name', ((Map<String, Object>)this.contentsMap.get('company_name')).get('value'));
        dataMap.put('city', ((Map<String, Object>)this.contentsMap.get('city')).get('value'));
        dataMap.put('country', (String)this.contentsMap.get('country'));
        dataMap.put('language', (String)this.contentsMap.get('language'));
        dataMap.put('selected_company_id', (String)this.contentsMap.get('selected_company_id'));
        dataMap.put('opportunity_id', (String)this.contentsMap.get('opportunity_id'));
        dataMap.put('contact_id', (String)this.contentsMap.get('contact_id'));
        dataMap.put('account_id', (String)this.contentsMap.get('account_id'));

        return dataMap;
    }    
}