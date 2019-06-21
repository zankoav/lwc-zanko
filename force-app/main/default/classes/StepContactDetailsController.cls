public with sharing class StepContactDetailsController {
    
    @AuraEnabled
    public static String stepSubmit(Map<String, String> state, String stepContent) {
        E2EContactDetailsBasicImpl service = new E2EContactDetailsBasicImpl();
        service.setContent(stepContent, null);
        return service.save(state);
    }

    @AuraEnabled(cacheable=true)
	public static Map<String, Object> getStaticData (String stepContent) {
		E2EContactDetailsBasicImpl service = new E2EContactDetailsBasicImpl();
        service.setContent(stepContent, null);
		return service.getContent();
	}
}