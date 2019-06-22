public with sharing class StepTechnicalParametersController {
    
    @AuraEnabled
	public static Map<String, Object> getStaticData (String stepContent, String apexService, String source) {
		Type customType = Type.forName(apexService);
		E2ETechnicalParameters service = (E2ETechnicalParameters)customType.newInstance();
		service.selectContent(stepContent, source);
		return service.getContent();
	}
    
    @AuraEnabled
    public static void stepSubmit(Map<String, Object> state, String apexService) {
		Type customType = Type.forName(apexService);
		E2ETechnicalParameters service = (E2ETechnicalParameters)customType.newInstance();
        service.setContent(state);
        service.save();
    }
}