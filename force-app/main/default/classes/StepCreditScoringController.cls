public with sharing class StepCreditScoringController {
   
    @AuraEnabled
    public static void stepSubmit(Map<String, String> state, String stepContent) {
        E2ECreditScoringBasicImpl service = new E2ECreditScoringBasicImpl();
        service.setContent(stepContent, null);
        service.save(state);
    }

    @AuraEnabled(cacheable=true)
	public static Map<String, Object> getStaticData (String stepContent) {
		E2ECreditScoringBasicImpl service = new E2ECreditScoringBasicImpl();
        service.setContent(stepContent, null);
		return service.getContent();
	}

    @AuraEnabled(cacheable=true)
	public static String changePaymantMethod (String paymantMethod) {
		return 'changePaymantMethod responce';
	}

    @AuraEnabled(cacheable=true)
	public static String changeBillingPeriod (String billingPeriod) {
		return 'changeBillingPeriod responce';
	}

    @AuraEnabled(cacheable=true)
	public static String changeCreditLimit (String creditLimit) {
		return 'changeCreditLimit responce';
	}

}
