public class E2EContactDetailsController {
    public Map<String, Object> contentsMap {get; set;}
    public Boolean isContinue {get; set;}
    public String encodedUrl {get; set;}
    public String apexServiceName;
    public String stepContentName;
    private E2EContactDetails service;  

    public E2EContactDetailsController() {}

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
        this.service = (E2EContactDetails)customType.newInstance();        
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

    public void processStep() {
        // try {
            Map<String, Object> dataMap = returnDataForSaving();
            this.service.setContent(dataMap);
            this.service.validate();            
            String source = this.service.save();
            Cookie sourceCookie = new Cookie('source', source, null, 315569260, false);
            ApexPages.currentPage().setCookies(new Cookie[]{sourceCookie});
            this.isContinue = true;
        // } catch (Exception e) {
        //     this.isContinue = false;
        // }            
    }

    private Map<String, Object> returnDataForSaving() {
        Map<String, Object> dataMap = new Map<String, Object>();
        dataMap.put('salutation', ((Map<String, Object>)this.contentsMap.get('salutation')).get('value'));
        dataMap.put('first_name', ((Map<String, Object>)this.contentsMap.get('first_name')).get('value'));
        dataMap.put('last_name', ((Map<String, Object>)this.contentsMap.get('last_name')).get('value'));
        dataMap.put('phone', ((Map<String, Object>)this.contentsMap.get('phone')).get('value'));
        dataMap.put('email', ((Map<String, Object>)this.contentsMap.get('email')).get('value'));
        dataMap.put('business_type', ((Map<String, Object>)this.contentsMap.get('business_type')).get('value'));
        dataMap.put('number_of_cards', ((Map<String, Object>)this.contentsMap.get('number_of_cards')).get('value'));
        dataMap.put('news_agreement', ((Map<String, Object>)this.contentsMap.get('news_agreement')).get('value'));
        dataMap.put('country', (String)this.contentsMap.get('country'));
        dataMap.put('language', (String)this.contentsMap.get('language'));
        dataMap.put('opportunity_id', (String)this.contentsMap.get('opportunity_id'));
        dataMap.put('contact_id', (String)this.contentsMap.get('contact_id'));
        dataMap.put('account_id', (String)this.contentsMap.get('account_id'));

        return dataMap;
    }
}