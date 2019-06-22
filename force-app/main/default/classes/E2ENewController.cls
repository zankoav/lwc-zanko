public class E2ENewController {
    public String encodedUrl {get; set;}
    public String activeStep {get; set;}
    
    public E2ENewController() {
        displayStep();
    }

    public void doNext() {
        displayStep();
    }  

    public void doBack() {
        String source = ApexPages.currentPage().getParameters().get('source');
        if (source == null) {
            Cookie sourceCookie = ApexPages.currentPage().getCookies().get('source');
            if (sourceCookie != null) {
                source = sourceCookie.getValue();
            }
        }

        if (source != null) {
            String opportunityId = E2ENewUtils.decryptOpportunityId(source);
            this.activeStep = String.valueOf([SELECT E2E_Active_Step__c FROM Opportunity WHERE Id = :opportunityId].E2E_Active_Step__c - 1);
        } else {
            this.activeStep = '0';
        } 
    }  

    public void displayStep() {
        String source = ApexPages.currentPage().getParameters().get('source');
        if (source == null) {
            Cookie sourceCookie = ApexPages.currentPage().getCookies().get('source');
            if (sourceCookie != null) {
                source = sourceCookie.getValue();
            }
        }

        if (source != null) {
            String opportunityId = E2ENewUtils.decryptOpportunityId(source);
            this.activeStep = String.valueOf([SELECT E2E_Active_Step__c FROM Opportunity WHERE Id = :opportunityId].E2E_Active_Step__c);
        } else {
            this.activeStep = '0';
        }        
    }     
}