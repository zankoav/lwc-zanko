public class E2ECardsConfigurationController {
    public Map<String,Object> contentsMap {get; set;}
    public Boolean isContinue {get; set;}
    public String stepContentName;
    public String apexServiceName;
    private E2ECardsConfiguration service;  

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
        this.service = (E2ECardsConfiguration)customType.newInstance();        
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
        System.debug('DEBUG: dataMap === ' + dataMap);
        this.service.setContent(dataMap);        
        this.service.save();
        this.isContinue = true;
    }

    private Map<String, Object> returnDataForSaving() {
        Map<String, Object> dataMap = new Map<String, Object>();
        dataMap.put('number_of_cards', ((Map<String, Object>)this.contentsMap.get('number_of_cards')).get('value'));
        dataMap.put('category', (String)this.contentsMap.get('category'));
        dataMap.put('pumpOutsideCountry', String.valueOf(this.contentsMap.get('pumpOutsideCountry')));
        dataMap.put('pumpAtPartners', String.valueOf(this.contentsMap.get('pumpAtPartners')));
        dataMap.put('country', (String)this.contentsMap.get('country'));
        dataMap.put('language', (String)this.contentsMap.get('language'));
        dataMap.put('opportunity_id', (String)this.contentsMap.get('opportunity_id'));
        dataMap.put('account_id', (String)this.contentsMap.get('account_id'));

        return dataMap;
    }
}