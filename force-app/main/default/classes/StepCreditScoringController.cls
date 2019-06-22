public with sharing class StepCreditScoringController {

	@AuraEnabled
	public static Map<String, Object> getStaticData (String stepContent, String apexService, String source) {
		System.debug('StepContent === ' + stepContent);
		System.debug('ApexService === ' + apexService);
		System.debug('Source === ' + source);

		Type customType = Type.forName(apexService);
		E2ECreditScoring service = (E2ECreditScoring)customType.newInstance();
		service.selectContent(stepContent, source);
		Map<String,Object> m = service.getContent();
		System.debug('credit_limit ========== ' + m.get('credit_limit'));
		
//		System.debug('Service.getContent() === ' + service.getContent());

		return service.getContent();
	}
   
    @AuraEnabled
	public static void changeBillingPeriod (String apexService, Map<String, Object> stateStep) {
		System.debug(' =changeBillingPeriod= ');

		Type customType = Type.forName(apexService);
		E2ECreditScoring service = (E2ECreditScoring)customType.newInstance();
		service.setContent(stateStep);
		service.changeBillingPeriod( String.valueOf(stateStep.get('billing_period')) );
	}

    @AuraEnabled
	public static void changeCreditLimit (String apexService, Map<String, Object> stateStep) {
		System.debug(' =changeCreditLimit= ');
		System.debug('StateStep === ' + stateStep);


		Type customType = Type.forName(apexService);
		E2ECreditScoring service = (E2ECreditScoring)customType.newInstance();
		service.setContent(stateStep);
		service.changeCreditLimit(stateStep);
	}

	@AuraEnabled
	public static void stepSubmit(String apexService, Map<String, Object> stateStep) {
		System.debug('ApexService === ' + apexService);
		System.debug('StateStep === ' + stateStep);

		Type customType = Type.forName(apexService);
		E2ECreditScoring service = (E2ECreditScoring)customType.newInstance();
		service.setContent(stateStep);
		service.save();
	}


}