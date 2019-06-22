public with sharing class StepOfferSelectionController {

    @AuraEnabled
	public static Map<String, Object> getStaticData (String stepContent, String apexService, String source) {
		Type customType = Type.forName(apexService);
		E2EOfferSelection service = (E2EOfferSelection)customType.newInstance();
		service.selectContent(stepContent, source);
		return service.getContent();
	}
    
    @AuraEnabled
    public static void stepSubmit(Map<String, String> state, String apexService) {
		System.debug('StepContent === ' + state);
		System.debug('ApexService === ' + apexService);
		Type customType = Type.forName(apexService);
		E2EOfferSelection service = (E2EOfferSelection)customType.newInstance();
        service.setContent(state);
        service.save();
    }
}