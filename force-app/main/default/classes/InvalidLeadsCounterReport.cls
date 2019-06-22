public with sharing class InvalidLeadsCounterReport {
    private String userid;
	public Integer numberInvalidLead;
    public Integer realNumberOfInvalidLead {get; set;}
    public List<Lead> finalInvalidLeadList {get; set;}

    public void init() {
        realNumberOfInvalidLead = 0;
    	returnUserId();
    	invalidLeadsSelected();

	if (numberInvalidLead >= 1000) {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Table displays 1000 record max.'));
    	}        
    }


    /*******************************************************************************
    *  Name            : invalidLeadsSelected()
    *  Summary         : getting invalid leads for teamleaders    
    *  CreatedDate     : 01.12.2016
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void invalidLeadsSelected() {
    	User currentUser = [
            SELECT Id, UserRole.Name, Profile.Name, Name, UserRoleId
            FROM User
            WHERE Id = :userid];

        if (roleMap.containskey(currentUser.UserRole.Name)) {
            
            Map<Id, UserRole> salesRolesMap = new Map<Id, UserRole>([
                    SELECT Id, Name
                    FROM UserRole
                    WHERE ParentRoleId = :currentUser.UserRoleId
                    LIMIT 1000]);

            Map<Id, User> salesTeamMap = new Map<Id, User>([
                    SELECT Name
                    FROM User
                    WHERE ((UserRole.Name LIKE 'Salesteam Outbound%') OR (UserRole.Name = 'Salesteam Flexcard') OR
                            (UserRoleId IN :salesRolesMap.keySet())) AND isActive = TRUE
                    LIMIT 10000]);

        	List<Lead> invalidLeads = new List<Lead>();

            if (currentUser.UserRole.Name == 'Teamleiter Inbound') {
                invalidLeads = [
                    SELECT Id, OwnerId, IsConverted, Status, LastTransferDate, Sec_Channel__c, Channel__c, Number_of_days__c, 
                           LeadSource, Lead_Nr__c, ConvertedOpportunityId, FirstName, LastName, Country
                    FROM Lead
                    WHERE (Sec_Channel__c = 'Inbound' OR Sec_Channel__c = 'JITB') AND 
                          (Status = 'Open' OR Status = 'Contacted') AND 
                           LeadSource != 'WinBack' AND
                           Country IN : inboundCountiesSet AND 
                           RecordTypeId = '012200000006oVTAAY' AND /*RecordTypeId = '012200000006oVTAAY' - Endkunde*/
                           OwnerId NOT IN :salesTeamMap.keySet() AND 
                           Owner.UserRole.Name != 'Salesteam Inbound 2' AND
                           IsConverted = false AND 
                           OwnerId != '00520000003QsEH' AND /* Willem Venterink */
                           OwnerId != '0050O000006SPE9' /* Xavier Roulan */
                    ORDER BY CreatedDate
                    LIMIT 40000];
                realNumberOfInvalidLead = invalidLeads.size();
            } else if (currentUser.UserRole.Name == 'Teamleiter Inbound 2') {
                invalidLeads = [
                    SELECT Id, OwnerId, IsConverted, Status, LastTransferDate, Sec_Channel__c, Channel__c, Number_of_days__c, 
                           LeadSource, Lead_Nr__c, ConvertedOpportunityId, FirstName, LastName, Country
                    FROM Lead
                    WHERE (Sec_Channel__c = 'Inbound' OR Sec_Channel__c = 'JITB') AND 
                          (Status = 'Open' OR Status = 'Contacted') AND 
                          Country IN :inbound2CountiesSet AND 
                          Owner.UserRole.Name != 'Salesteam Inbound' AND
                          RecordTypeId = '012200000006oVTAAY' AND  /*RecordTypeId = '012200000006oVTAAY' - Endkunde*/
                          OwnerId NOT IN :salesTeamMap.keySet() AND 
                          Owner.Name != 'LeadAssignPLJITB' AND
                          IsConverted = false
                    ORDER BY CreatedDate
                    LIMIT 40000];
                realNumberOfInvalidLead = invalidLeads.size();
            } else if (inboundRolesSet.contains(currentUser.UserRole.Name) && currentUser.UserRole.Name.containsIgnoreCase('Harte Hank')) {
                invalidLeads = [
                    SELECT Id, OwnerId, IsConverted, Status, LastTransferDate, Sec_Channel__c, Channel__c, Number_of_days__c, 
                           LeadSource, Lead_Nr__c, ConvertedOpportunityId, FirstName, LastName, Country
                    FROM Lead
                    WHERE (Sec_Channel__c = 'Inbound' OR Sec_Channel__c = 'JITB') AND 
                          (Status = 'Open' OR Status = 'Contacted') AND
                           Country = 'France' AND
                           OwnerId NOT IN :salesTeamMap.keySet() AND
                           IsConverted = false
                    ORDER BY CreatedDate
                    LIMIT 40000];
                realNumberOfInvalidLead = invalidLeads.size();
            } else if (outboundRolesSet.contains(currentUser.UserRole.Name)) {
                invalidLeads = [
                    SELECT Id, OwnerId, IsConverted, Status, LastTransferDate, Sec_Channel__c, Channel__c, Number_of_days__c, 
                           LeadSource, Lead_Nr__c, ConvertedOpportunityId, FirstName, LastName, Country
                    FROM Lead
                    WHERE Sec_Channel__c = 'Outbound' AND 
                          (Status = 'Open' OR Status = 'Contacted') AND 
                          OwnerId NOT IN :salesTeamMap.keySet() AND
                          IsConverted = false
                    ORDER BY CreatedDate
                    LIMIT 40000];
                realNumberOfInvalidLead = invalidLeads.size();
            }

            finalInvalidLeadList = new List<Lead>();
            Integer counter = 0;
	        for (Lead lead : invalidLeads) {
	        	if (counter == 1000) break;
	        	finalInvalidLeadList.add(lead);
	        	counter++;
	        }
	        numberInvalidLead = finalInvalidLeadList.size();
        }
    }
    

    /*******************************************************************************
    *  Name            : returnUserId()
    *  Summary         : getting ID current user    
    *  CreatedDate     : 01.12.2016
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void returnUserId() {
        userid = Apexpages.currentPage().getParameters().get('userid');
            if (userid == null) {
                userid = UserInfo.getUserId();
            }
    }


    private final Set<String> inboundRolesSet = new Set<String>{
        'Teamleiter Inbound',
        'Teamleiter Inbound 2',
        'Teamleiter Harte Hank'
    };


    private final Set<String> outboundRolesSet = new Set<String>{
        'Teamleiter Outbound 1',
        'Teamleiter Outbound 2',
        'Teamleiter Outbound 3',
        'Teamleiter Outbound 4',
        'Teamleiter Outbound 5'
    };

    private Map<String, Integer> roleMap = new Map<String, Integer>{
        'Teamleiter Inbound' => 1,
        'Teamleiter Inbound 2' => 2, 
        'Teamleiter Harte Hank' => 3,
        'Teamleiter Outbound 1' => 5,
        'Teamleiter Outbound 2' => 6,
        'Teamleiter Outbound 3' => 7,
        'Teamleiter Outbound 4' => 8,
        'Teamleiter Outbound 5' => 9
    };

    private Set<String> inboundCountiesSet = new Set<String>{
        'Germany',
        'Austria', 
        'Switzerland-DE', 
        'Switzerland-FR',
        'Switzerland-IT',
        'France',
        'Belgium-FR',
        'Luxembourg',
        'Poland'
    };

    private Set<String> inbound2CountiesSet = new Set<String>{
        'Hungary',
        'Poland', 
        'Slovakia', 
        'Czech Republic',
        'Netherlands',
        'Belgium-NL'
    }; 
}