public class E2EStepContent {
    public List<E2EContentElement> e2eContentElements {get; set;}

	public class E2EContentElement {
		public String name {get; set;}		
		public String value {get; set;}
		public String label {get; set;}
		public String label2 {get; set;}
		public String type {get; set;}
		public String errorMessage {get; set;}
		public String validationRegex {get; set;}
		public String helpText {get; set;}
		public List<Option> options {get; set;}
	}

	public class Option {
		public String label {get; set;}
		public String value {get; set;}
		public String helpText {get; set;}
	}

	public Map<String, E2EContentElement> getE2EContentElementsMap() {
		Map<String, E2EContentElement> e2eContentElementsMap = new Map<String, E2EContentElement>();
		for (E2EContentElement e2eContentElement : e2eContentElements) {
			e2eContentElementsMap.put(e2eContentElement.name, e2eContentElement);
		}

		return e2eContentElementsMap;
	}
}