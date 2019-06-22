public class LongFormField {
	// public String inputValue;
	// public String type;
	public List<SelectOption> options {get; set;}
	// public LongForm_Element__c element;
	public Map<String, LongForm_Element_Item__c> elementItemsMap {get; set;}

	public Map<String, LongFormOffer> offers {get; set;}


    public LongFormField() {    
    }
}