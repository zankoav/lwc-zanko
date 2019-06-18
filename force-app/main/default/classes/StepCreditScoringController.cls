public with sharing class StepCreditScoringController {
   
    @AuraEnabled
    public static void stepSubmit(Map<String, String> state, String apexService) {
        // Type customType = Type.forName(apexService);
        // E2EContactDetails service = (E2EContactDetails)customType.newInstance();
        // service.save(state);
    }
}
