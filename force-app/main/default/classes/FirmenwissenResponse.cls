public class FirmenwissenResponse {
	public String query;
	public String suggestionCategory;
	public List<CompanyNameSuggestions> companyNameSuggestions;

	public class CompanyNameSuggestions {
		public String crefonummer;
		public String identnummer;
		public String name;
		public String handelsName;
		public String land;
		public String bundesland;
		public String plz;
		public String ort;
		public String strasseHausnummer;
	}
}