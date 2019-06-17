public class StaticResourceClass {

	@AuraEnabled(cacheable=true)
	public static Map<String, Object> getStaticData (String stepContent, String apexService) {
		Type customType = Type.forName(apexService);
		E2EContactDetails service = (E2EContactDetails)customType.newInstance();
		Map<String, Object> contentsMap = service.getContent(stepContent, null);
		return contentsMap;
	}
}