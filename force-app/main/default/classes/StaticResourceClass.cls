public class StaticResourceClass {

	@AuraEnabled(cacheable=true)
	public static Map<String, Object> getStaticData (String stateId, String stepContent, String apexService) {
		Map<String, Object> response = new Map<String, Object>{
			'status'=>0,
			'message'=>'Server error, please try again later'
		};
		
		if(stateId != null){
			// StaticResource resource = [SELECT Body FROM StaticResource WHERE Name =:stateId LIMIT 1];
			/**
			* TODO: init user data
			*/

			Type customType = Type.forName(apexService);
			E2EContactDetails service = (E2EContactDetails)customType.newInstance();
			Map<String, Object> contentsMap = service.getContent(stepContent, null);

			if(contentsMap != null){
				response.put('status', 1);
				response.put('resource', contentsMap);
				response.put('message', 'successful');
			}else{
				response.put('message', 'resource ' + stateId + ' not found');
			}
		}else{
			response.put('message', 'stateId is null');
		}
		return response;
	}
}