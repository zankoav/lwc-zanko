public abstract class E2ECreditScoringAbstract implements E2ECreditScoring {
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


    public abstract void calculateCredit();


    public Account getAccount() {
        return this.account;
    }


    public Contact getContact() {
        return this.contact;
    }


    public Opportunity getOpportunity() {
        return this.opportunity;
    }    


    private void setSObjectsData(String source) {
        String opportunityId = E2ENewUtils.decryptOpportunityId(source);
        selectRecords(opportunityId);
        // contentsMap.get('TOTAL CONSUMPTION').value = String.valueOf(this.opportunity.Total_consumption_l_month__c);
    }


    private void selectRecords(String opportunityId) {
        this.opportunity = selectOpportunity(opportunityId);
        this.account = selectAccount(this.opportunity.AccountId);
        this.contact = selectContact(this.opportunity.OpportunityContactRoles.get(0).ContactId);
    }


    private Opportunity selectOpportunity(String opportunityId) {
        Opportunity opportunity = [
            SELECT E2E_Encoded_URL__c, Total_consumption_l_month__c, AccountId,
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