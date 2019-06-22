public class E2EPaymentOptionsController {
    public Map<String,Object> contentsMap {get; set;}
    public Boolean isContinue {get; set;}
    public String stepContentName;
    public String apexServiceName;
    private E2EPaymentOptions service;

    public E2EPaymentOptionsController() {}


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
        this.service = (E2EPaymentOptions)customType.newInstance();        
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

    public void submitStep() {
        Map<String, Object> dataMap = returnDataForSaving();
        this.service.setContent(dataMap);
        this.service.validate();
        this.service.save();
        this.isContinue = true;
    }

    private Map<String, Object> returnDataForSaving() {
        Map<String, Object> dataMap = new Map<String, Object>();        
        dataMap.put('country', (String)this.contentsMap.get('country'));
        dataMap.put('language', (String)this.contentsMap.get('language'));
        dataMap.put('opportunity_id', (String)this.contentsMap.get('opportunity_id'));
        dataMap.put('account_id', (String)this.contentsMap.get('account_id'));
        dataMap.put('contact_id', (String)this.contentsMap.get('contact_id'));
        dataMap.put('iban', ((Map<String, Object>)this.contentsMap.get('iban')).get('value'));
        dataMap.put('swift', ((Map<String, Object>)this.contentsMap.get('swift')).get('value'));
        dataMap.put('sepa_block', ((Map<String, Object>)this.contentsMap.get('sepa_block')).get('accept_value'));
        dataMap.put('account_holder', ((Map<String, Object>)this.contentsMap.get('account_holder')).get('value'));
        dataMap.put('paper_invoice', ((Map<String, Object>)this.contentsMap.get('paper_invoice')).get('value'));
        dataMap.put('decision_agreement', ((Map<String, Object>)this.contentsMap.get('decision_agreement')).get('value'));
        dataMap.put('terms_and_cond_agreement', ((Map<String, Object>)this.contentsMap.get('terms_and_cond_agreement')).get('value'));

        return dataMap;
    }
}