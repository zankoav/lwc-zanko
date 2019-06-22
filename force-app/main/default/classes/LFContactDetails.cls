public interface LFContactDetails { 
	void setPagesMap(String deviceView);
	Map<String, LongFormPage> getPagesMap();
	void updateOpportunityOnReturnFromEmail(String deviceView);
	void validate();
	Contact getDuplicateContact();
	void insertRecords(Contact contact, String deviceView);
	void findDuplicateLead();
	void updateRecord(Boolean isE2ERecord);
	void setSFobjects(String opptyId);
	Account getAccount();
	Opportunity getOpportunity();
	Contact getContact();
	void setOpportunity(Opportunity opportunity);
	void setContact(Contact contact);
	void updateOpportunityToLost();
}