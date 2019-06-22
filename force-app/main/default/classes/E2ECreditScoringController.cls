public class E2ECreditScoringController {
    public Map<String,Object> contentsMap {get; set;}
    public Boolean isContinue {get; set;}
    public String stepContentName;
    public String apexServiceName;
    private E2ECreditScoring service;  

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
        this.service = (E2ECreditScoring)customType.newInstance();        
        this.service.selectContent(this.stepContentName, source);
        this.contentsMap = this.service.getContent();
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

    public void changeBillingPeriod() {
        this.service.changeBillingPeriod((String)((Map<String, Object>)this.contentsMap.get('billing_period')).get('value'));
    }

    public void increaseCreditLimit() {
        Map<String, Object> creditLimit = (Map<String, Object>)this.contentsMap.get('credit_limit');
        Integer creditLimitValue = Integer.valueOf(creditLimit.get('value')) + 100;
        creditLimit.put('value', String.valueOf(creditLimitValue));
        this.contentsMap.put('credit_limit', creditLimit);
        this.service.changeCreditLimit(this.contentsMap);
    }

    public void decreaseCreditLimit() {
        Map<String, Object> creditLimit = (Map<String, Object>)this.contentsMap.get('credit_limit');
        Integer creditLimitValue = Integer.valueOf(creditLimit.get('value')) - 100;
        creditLimit.put('value', String.valueOf(creditLimitValue));
        this.contentsMap.put('credit_limit', creditLimit);
        this.service.changeCreditLimit(this.contentsMap);
    }
  
    public void submitStep() {
        this.service.save();
        this.isContinue = true;
    }    
}