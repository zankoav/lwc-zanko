public with sharing class StepContactDetailsController {

	@AuraEnabled
	public static Map<String, Object> getStaticData (String stepContent, String apexService, String source) {
		System.debug('StepContent === ' + stepContent);
		System.debug('ApexService === ' + apexService);
		System.debug('Source === ' + source);


		Type customType = Type.forName(apexService);
		E2EContactDetails service = (E2EContactDetails)customType.newInstance();
		service.selectContent(stepContent, source);
		return service.getContent();
	}
    
    @AuraEnabled
    public static String stepSubmit(Map<String, String> state, String apexService) {
		System.debug('StepContent === ' + state);
		System.debug('ApexService === ' + apexService);
		Type customType = Type.forName(apexService);
		E2EContactDetails service = (E2EContactDetails)customType.newInstance();
        service.setContent(state);
        service.validate();
        return service.save();
    }

}