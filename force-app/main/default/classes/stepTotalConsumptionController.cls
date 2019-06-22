public class stepTotalConsumptionController {

	@AuraEnabled
	public static Map<String, Object> getStaticData (String stepContent, String apexService, String source) {
		Type customType = Type.forName(apexService);
		E2ETotalConsumption service = (E2ETotalConsumption)customType.newInstance();
		service.selectContent(stepContent, source);
		return service.getContent();
	}

	@AuraEnabled
	public static void save (String apexService, Map<String, Object> stateStep) {
		Type customType = Type.forName(apexService);
		E2ETotalConsumption service = (E2ETotalConsumption)customType.newInstance();
		service.setContent(stateStep);
		service.save();
	}
}