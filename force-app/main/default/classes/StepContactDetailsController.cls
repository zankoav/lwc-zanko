public with sharing class StepContactDetailsController {
    
    @AuraEnabled
    public static void stepSubmit(Map<String, Object> state, String apexService) {
        // Map<String,Object> response = new Map<String,Object>{
        //     'status'=>0,
        //     'message'=>'Server Error'
        // };

        Type customType = Type.forName(apexService);
        E2EContactDetails service = (E2EContactDetails)customType.newInstance();
        service.save(state);
    }
}
