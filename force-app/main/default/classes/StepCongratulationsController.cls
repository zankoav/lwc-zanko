public with sharing class StepCongratulationsController {
    
    @AuraEnabled
	public static Map<String, Object> getStaticData (String stepContent, String apexService, String source) {
		Type customType = Type.forName(apexService);
		E2ECongratulations service = (E2ECongratulations)customType.newInstance();
		service.selectContent(stepContent, source);
		return service.getContent();
	}

}