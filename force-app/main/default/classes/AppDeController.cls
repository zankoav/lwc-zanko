public class AppDeController {

    public static final String EMPTY_COOKIE_SOURCE = '';
    public static final String FIRST_STEP = '1';
    public static final String KEY_SOURCE = 'source';
    public static final String KEY_STEP = 'step';

    public Map<String,String> getState() {

        Map<String,String> state = new Map<String, String>{
            KEY_STEP => FIRST_STEP,
            KEY_SOURCE => null
        };

        String sourceParam = ApexPages.currentPage().getParameters().get(KEY_SOURCE);
        if(sourceParam != null){
            Map<String, String> sourceState = this.getSourceState(sourceParam);
            if(sourceState != null){
                state = sourceState;
            }
        }

        if(state.get(KEY_SOURCE) == null){
            Cookie sourceCookie = ApexPages.currentPage().getCookies().get(KEY_SOURCE);
            if(sourceCookie != null){
                String sourceCookieParam = sourceCookie.getValue();
                Map<String, String> sourceState = this.getSourceState(sourceCookieParam);
                if(sourceState != null){
                    state = sourceState;
                }
            }
        }

        if(state.get(KEY_SOURCE) == null){
            state.put(KEY_SOURCE, EMPTY_COOKIE_SOURCE);
        }

        Cookie sourceCookie = new Cookie(KEY_SOURCE, state.get(KEY_SOURCE), null, -1, false);
        ApexPages.currentPage().setCookies(new Cookie[]{sourceCookie});

        // Need to remove
        state.put('step', ApexPages.currentPage().getParameters().get('step'));

        return state;
    }


    private Map<String,String> getSourceState(String sourceParam){

        Map<String,String> source;
        String opportunityId;
        Opportunity opportunity;

        try {
            opportunityId = E2ENewUtils.decryptOpportunityId(sourceParam);
        } catch (Exception e) {
            System.debug('error in decryptOpportunityId  === ' + e.getMessage());
        }
        
        if(opportunityId != null){
            opportunity = [SELECT E2E_Active_Step__c FROM Opportunity WHERE Id = :opportunityId];
        }

        if(opportunity != null){
            source = new Map<String,String>{
                KEY_STEP => String.valueOf(opportunity.E2E_Active_Step__c + 1),
                KEY_SOURCE => sourceParam
            };
        }

        return source;
    }
}