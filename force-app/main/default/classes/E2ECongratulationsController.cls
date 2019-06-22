public class E2ECongratulationsController {
    public Map<String,Object> contentsMap {get; set;}
    public Boolean isContinue {get; set;}
    public String stepContentName;
    public String apexServiceName;
    private E2ECongratulations service;

    public E2ECongratulationsController() {}


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
        this.service = (E2ECongratulations)customType.newInstance();        
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

    public void selectClubsmart() {
        Map<String, Object> dataMap = returnDataForSaving();
        this.service.setContent(dataMap);
        this.service.setupBonus();
        this.isContinue = true;
    }

    private Map<String, Object> returnDataForSaving() {
        Map<String, Object> dataMap = new Map<String, Object>();
        dataMap.put('number_of_cards', (String)this.contentsMap.get('number_of_cards'));
        dataMap.put('country', (String)this.contentsMap.get('country'));
        dataMap.put('language', (String)this.contentsMap.get('language'));
        dataMap.put('opportunity_id', (String)this.contentsMap.get('opportunity_id'));
        dataMap.put('account_id', (String)this.contentsMap.get('account_id'));

        return dataMap;
    }    
}