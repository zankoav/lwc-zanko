public class StepDepositOptionsController {

	@AuraEnabled
	public static Map<String, Object> getStaticData (String stepContent, String apexService, String source) {
		System.debug('StepContent === ' + stepContent);
		System.debug('ApexService === ' + apexService);
		System.debug('Source === ' + source);

		Type customType = Type.forName(apexService);
		E2EDepositOptions service = (E2EDepositOptions)customType.newInstance();
		service.selectContent(stepContent, source);
		System.debug('Service.getContent() === ' + service.getContent());

		return service.getContent();
	}

	@AuraEnabled
	public static void save (String apexService, Map<String, Object> stepState) {
		Type customType = Type.forName(apexService);
		E2EDepositOptions service = (E2EDepositOptions)customType.newInstance();
		System.debug('stepState === ' + stepState);

		service.setContent(stepState);
		service.save();
	}

}