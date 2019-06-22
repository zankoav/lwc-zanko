public interface LFDocusign {
	String createEnvelope(String deviceView, String activeSubstep);
    void setContactRole(String opptyId);
    void setOpportunity(String opptyId);
    void deleteDocusignStatuses(String opptyId, Set<String> pdfNamesSet);
    Opportunity getOpportunity();
    Boolean checkContact();
}