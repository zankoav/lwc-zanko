public class StepAdditionalParametersController {

	@AuraEnabled
	public static Map<String, Object> getStaticData (String stepContent, String apexService, String source) {
		System.debug('StepContent === ' + stepContent);
		System.debug('Source === ' + source);

		Type customType = Type.forName(apexService);
		E2EAdditionalParameters service = (E2EAdditionalParameters)customType.newInstance();
		service.selectContent(stepContent, source);
		System.debug('Service.getContent() === ' + service.getContent());

		return service.getContent();
	}

	@AuraEnabled
	public static void save (String apexService, Map<String, Object> stepState) {
		Type customType = Type.forName(apexService);
		E2EAdditionalParameters service = (E2EAdditionalParameters)customType.newInstance();
		System.debug('Data === ' + stepState);

		service.setContent(stepState);
		service.save();
	}

}