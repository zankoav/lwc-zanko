public abstract class E2EContactDetailsAbstract implements E2EContactDetails {
    // private Map<String, E2EContentJson.ContentElement> contentsMap;

    
    // public void setContentsMap(String resourceName, String source) {
    //     setContentsMapData(resourceName);
    //     setSObjectsData(source);
    // }

    
    // public Map<String, E2EContentJson.ContentElement> getContentsMap() {
    //     return this.contentsMap;
    // }

    
    // public abstract void validate();

    
    // public abstract String save();


    // private void setSObjectsData(String source) {
    //     if (source == null) return;
    //     String opportunityId = E2ENewUtils.decryptOpportunityId(source);
    //     List<Opportunity> opportunitiesList = [
    //             SELECT Id, E2E_Encoded_URL__c,
    //                    (SELECT Contact.FirstName, Contact.LastName, 
    //                            Contact.Phone, Contact.Email 
    //                     FROM OpportunityContactRoles 
    //                     WHERE IsPrimary = TRUE
    //                     LIMIT 1)
    //             FROM Opportunity
    //             WHERE Id = :opportunityId
    //             LIMIT 1];
    //     OpportunityContactRole contactRole = opportunitiesList.get(0).OpportunityContactRoles.get(0);
    //     this.contentsMap.get('FIRST NAME').value = contactRole.Contact.FirstName;
    //     this.contentsMap.get('LAST NAME').value = contactRole.Contact.LastName;
    //     this.contentsMap.get('PHONE').value = contactRole.Contact.Phone;
    //     this.contentsMap.get('EMAIL').value = contactRole.Contact.Email;
    // }


    // private void setContentsMapData(String resourceName) {
    //     this.contentsMap = new Map<String, E2EContentJson.ContentElement>();
    //     List<StaticResource> resource = [SELECT Body FROM StaticResource WHERE Name = :resourceName LIMIT 1];
        
    //     if (resource.isEmpty()) return;

    //     E2EContentJson deserializedJson = (E2EContentJson)JSON.deserialize(resource.get(0).Body.toString(), E2EContentJson.class);

    //     for (E2EContentJson.ContentElement contactDetailsElement : deserializedJson.component.contentElements) {
    //         contentsMap.put(contactDetailsElement.name.toUpperCase(), contactDetailsElement);
    //     }
    // }











    private Map<String, E2EStepContent.E2EContentElement> contentsMap;

    
    public void setContentsMap(String resourceName, String source) {
        setContentsMapData(resourceName);
        setSObjectsData(source);
    }

    
    public Map<String, E2EStepContent.E2EContentElement> getContentsMap() {
        return this.contentsMap;
    }

    
    public abstract void validate();

    
    public abstract String save();


    private void setSObjectsData(String source) {
        if (source == null) return;
        String opportunityId = E2ENewUtils.decryptOpportunityId(source);
        List<Opportunity> opportunitiesList = [
                SELECT Id, E2E_Encoded_URL__c,
                       (SELECT Contact.FirstName, Contact.LastName, 
                               Contact.Phone, Contact.Email 
                        FROM OpportunityContactRoles 
                        WHERE IsPrimary = TRUE
                        LIMIT 1)
                FROM Opportunity
                WHERE Id = :opportunityId
                LIMIT 1];
        OpportunityContactRole contactRole = opportunitiesList.get(0).OpportunityContactRoles.get(0);
        this.contentsMap.get('first_name').value = contactRole.Contact.FirstName;
        this.contentsMap.get('last_name').value = contactRole.Contact.LastName;
        this.contentsMap.get('phone').value = contactRole.Contact.Phone;
        this.contentsMap.get('email').value = contactRole.Contact.Email;
    }


    private void setContentsMapData(String resourceName) {
        this.contentsMap = new Map<String, E2EStepContent.E2EContentElement>();
        List<StaticResource> resource = [SELECT Body FROM StaticResource WHERE Name = :resourceName LIMIT 1];
        
        if (resource.isEmpty()) return;

        E2EStepContent deserializedJson = (E2EStepContent)JSON.deserialize(resource.get(0).Body.toString(), E2EStepContent.class);
        this.contentsMap.putAll(deserializedJson.getE2EContentElementsMap());
    }
}