public class StepSearchCompanyController {

	@AuraEnabled
	public static Map<String, Object> getStaticData (String stepContent, String apexService, String source) {
		Type customType = Type.forName(apexService);
		E2ESearchCompany service = (E2ESearchCompany)customType.newInstance();
		service.selectContent(stepContent, source);
		System.debug('Service.getContent() === ' + service.getContent());

		return service.getContent();
	}

	@AuraEnabled
	public static void saveCompany (Map<String, Object> stepState, String stepContent, String apexService) {
		if (stepState != null && stepContent != null && apexService != null) {
			Type customType = Type.forName(apexService);
			E2ESearchCompany service = (E2ESearchCompany)customType.newInstance();
			service.setContent(stepState);
			service.validate();
			service.saveCompany();
		}
	}

	@AuraEnabled
	public static List<Object> searchCompanies (Map<String, Object> stepState, String apexService) {
		System.debug('StepState === ' + stepState);
		System.debug('ApexService === ' + apexService);

		List<Object> resultList;
		if (apexService != null) {
			Type customType = Type.forName(apexService);
			E2ESearchCompany service = (E2ESearchCompany)customType.newInstance();
			service.setContent(stepState);
			List<CreditCompany> companies = service.search();
			System.debug('Companies === ' + companies);


			resultList = new List<Object>();
			for (CreditCompany company : companies) {
				String description = company.street + ' ' + company.housenumber;
				description += company.postcode != null ? ', ' + company.postcode : '';
				description += company.city != null ? ', ' + company.city : '';
				description += company.country != null ? ', ' + company.country : '';

			    Map<String, Object> m = new Map<String, Object>{
					'id' => company.identificationnumber,
					'name' => company.name,
					'description' => description
				};
				resultList.add(m);
			}
		}

		return resultList;
	}

	@AuraEnabled
	public static void save (String apexService, Map<String, Object> stateStep) {
		Type customType = Type.forName(apexService);
		E2ESearchCompany service = (E2ESearchCompany)customType.newInstance();
		System.debug('Data === ' + stateStep);

		service.setContent(stateStep);
		service.save();
	}


}