public class E2EContentJson {
	public Component component {get; set;}

    public class Component {
		public List<ContentElement> contentElements {get; set;}
	}

	public class ContentElement {
		public String name {get; set;}
		public String apiName {get; set;}		
		public String value {get; set;}
		public String label {get; set;}
		public String label2 {get; set;}
		public String type {get; set;}
		public String errorMessage {get; set;}
		public String helpText {get; set;}
		public List<Option> options {get; set;}
	}

	public class Option {
		public String label {get; set;}
		public String value {get; set;}
		public String helpText {get; set;}
	}    
}