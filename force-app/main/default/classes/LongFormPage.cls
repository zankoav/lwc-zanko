public class LongFormPage {
	public String systemError;
	public String pageTitle {get; set;}
	public Map<String, Map<String, LongForm_Element_Item__c>> elements {get; set;}
	public Map<String, LongFormField> fields {get; set;}


    public LongFormPage() {     
    }
}