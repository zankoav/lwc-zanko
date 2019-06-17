public with sharing class StepContactDetailsController {
    
    @AuraEnabled
    public static void stepSubmit(Map<String, Object> state, String apexService) {
        Type customType = Type.forName(apexService);
        E2EContactDetails service = (E2EContactDetails)customType.newInstance();
        service.save(state);
    }
}