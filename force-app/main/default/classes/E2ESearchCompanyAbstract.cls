public abstract class E2ESearchCompanyAbstract implements E2ESearchCompany {
    private Map<String, E2EContentJson.ContentElement> contentsMap;
    private Opportunity opportunity;
    private Account account;
    private Contact contact;

    
    public void setContentsMap(String resourceName, String source) {
        setContentsMapData(resourceName);
        setSObjectsData(source);
    }

    
    public Map<String, E2EContentJson.ContentElement> getContentsMap() {
        return this.contentsMap;
    }

    
    public abstract void save(Map<String, E2EContentJson.ContentElement> contentsMap);
    

    public abstract List<CreditCompany> search();

    
    public abstract void selectCompany(String selectedCompanyId);


    public abstract void validate();


    public Account getAccount() {
    	return this.account;
    }


    public Contact getContact() {
    	return this.contact;
    }


    public Opportunity getOpportunity() {
    	return this.opportunity;
    }

    public void setAccount(Account account) {
    	this.account = account;
    }

    public void setContact(Contact contact) {
    	this.contact = contact;
    }


    public void setOpportunity(Opportunity opportunity) {
    	this.opportunity = opportunity;
    }    


    private void setSObjectsData(String source) {
        String opportunityId = E2ENewUtils.decryptOpportunityId(source);
        selectRecords(opportunityId);
        contentsMap.get('COMPANY NAME').value = returnCompanyName(this.opportunity.Name);
        contentsMap.get('CITY').value = this.account.BillingCity;
    }


    private void selectRecords(String opportunityId) {
        this.opportunity = selectOpportunity(opportunityId);
        this.account = selectAccount(this.opportunity.AccountId);
        this.contact = selectContact(this.opportunity.OpportunityContactRoles.get(0).ContactId);
    }


    private Opportunity selectOpportunity(String opportunityId) {
        Opportunity opportunity = [
            SELECT E2E_Encoded_URL__c, Name, Account.BillingCity,
                   (SELECT ContactId
                    FROM OpportunityContactRoles 
                    WHERE IsPrimary = TRUE
                    LIMIT 1)
            FROM Opportunity
            WHERE Id = :opportunityId
            LIMIT 1];

        return opportunity;
    }


    private Account selectAccount(String accountId) {
    	Account account = [
    			SELECT Name, BillingCity
    			FROM Account
    			WHERE Id = :accountId
    	LIMIT 1];

    	return account;
    }


    private Contact selectContact(String contactId) {
    	Contact contact = [
    			SELECT FirstName, LastName, Phone, Email
    			FROM Contact
    			WHERE Id = :contactId
    			LIMIT 1];
    	return contact;
    }


    private String returnCompanyName(String companyName) {
    	if (companyName != null && companyName.contains('LONGFORM:')) {
    		return '';
    	}

    	return companyName;
    }


    private void setContentsMapData(String resourceName) {
        this.contentsMap = new Map<String, E2EContentJson.ContentElement>();
        List<StaticResource> resource = [SELECT Body FROM StaticResource WHERE Name = :resourceName LIMIT 1];
        
        if (resource.isEmpty()) return;

        E2EContentJson deserializedJson = (E2EContentJson)JSON.deserialize(resource.get(0).Body.toString(), E2EContentJson.class);

        for (E2EContentJson.ContentElement contactDetailsElement : deserializedJson.component.contentElements) {
            contentsMap.put(contactDetailsElement.name.toUpperCase(), contactDetailsElement);
        }
    }
}