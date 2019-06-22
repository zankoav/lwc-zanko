public with sharing class InvalidLeadsCounterCtrl {
	public User currentUser {get; set;}
    public Integer numberOfInvalidLeads {get; set;}
    public Integer invalidLeadsInbound {get; set;}
    public Integer invalidLeadsInboundOpen {get; set;}
    public Integer invalidLeadsInboundContacted {get; set;}
    public Integer invalidLeadsJITB {get; set;}
    public Integer invalidLeadsJITBOpen {get; set;}
    public Integer invalidLeadsJITBContacted {get; set;}
    public Integer invalidLeadsOutbound {get; set;}
    public Integer invalidLeadsOutboundOpen {get; set;}   
    public Integer invalidLeadsOutboundContacted {get; set;}
    public Map<String, Integer> invalidLeadsCountriesMap {get; set;}
    public String currentTeamType {get; set;}
    public List<Lead> invalidLeads;
    private String userid;


    public void init() {
        numberOfInvalidLeads = 0;
        invalidLeadsInbound = 0;
        invalidLeadsInboundOpen = 0;
        invalidLeadsInboundContacted = 0;
        invalidLeadsJITB = 0;
        invalidLeadsJITBOpen = 0;
        invalidLeadsJITBContacted = 0;
        invalidLeadsOutbound = 0;
        invalidLeadsOutboundOpen = 0;
        invalidLeadsOutboundContacted = 0;
    	returnUserId();
    	invalidLeadsSelected();
    }


    /*******************************************************************************
    *  Name            : invalidLeadsSelected()
    *  Summary         : getting invalid leads for teamleaders    
    *  CreatedDate     : 30.11.2016
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void invalidLeadsSelected() {
        currentTeamType = '';
		currentUser = [
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

            if (currentUser.UserRole.Name.containsIgnoreCase('outbound')) {
                currentTeamType = 'outbound';           
            } else {
                currentTeamType = 'inbound';          
            }

            if (currentUser.UserRole.Name == 'Teamleiter Inbound') {
                this.invalidLeads = [
                    SELECT Id, OwnerId, IsConverted, Status, LastTransferDate, Sec_Channel__c, Channel__c, 
                           LeadSource, Lead_Nr__c, ConvertedOpportunityId, FirstName, LastName, Country
                    FROM Lead
                    WHERE (Sec_Channel__c = 'Inbound' OR Sec_Channel__c = 'JITB') AND
                          (Status = 'Open' OR Status = 'Contacted') AND LeadSource != 'WinBack' AND
                           Country IN : inboundCountiesSet AND 
                           RecordType.Name = 'Endkunde' AND
                           OwnerId NOT IN :salesTeamMap.keySet() AND 
                           IsConverted = false AND 
                           Owner.UserRole.Name != 'Salesteam Inbound 2' AND
                           OwnerId != '00520000003QsEH' AND /* Willem Venterink */
                           OwnerId != '0050O000006SPE9' /* Xavier Roulan */
                    ORDER BY CreatedDate
                    LIMIT 40000];
                numberOfInvalidLeads = invalidLeads.size();
            } else if (currentUser.UserRole.Name == 'Teamleiter Inbound 2') {
                this.invalidLeads = [
                    SELECT Id, OwnerId, IsConverted, Status, LastTransferDate, Sec_Channel__c, Channel__c, 
                           LeadSource, Lead_Nr__c, ConvertedOpportunityId, FirstName, LastName, Country
                    FROM Lead
                    WHERE (Sec_Channel__c = 'Inbound' OR Sec_Channel__c = 'JITB') AND 
                          (Status = 'Open' OR Status = 'Contacted') AND 
                           Country IN :inbound2CountiesSet AND 
                           RecordType.Name = 'Endkunde' AND
                           OwnerId NOT IN :salesTeamMap.keySet() AND 
                           Owner.UserRole.Name != 'Salesteam Inbound' AND
                           Owner.Name != 'LeadAssignPLJITB' AND
                           IsConverted = false
                    ORDER BY CreatedDate
                    LIMIT 40000];
                numberOfInvalidLeads = invalidLeads.size();
            } else if (inboundRolesSet.contains(currentUser.UserRole.Name) && currentUser.UserRole.Name.containsIgnoreCase('Harte Hank')) {
                this.invalidLeads = [
                    SELECT Id, OwnerId, IsConverted, Status, LastTransferDate, Sec_Channel__c, Channel__c, 
                           LeadSource, Lead_Nr__c, ConvertedOpportunityId, FirstName, LastName, Country
                    FROM Lead
                    WHERE (Sec_Channel__c = 'Inbound' OR Sec_Channel__c = 'JITB') AND 
                          (Status = 'Open' OR Status = 'Contacted') AND
                           Country = 'France' AND 
                           OwnerId NOT IN :salesTeamMap.keySet() AND
                           IsConverted = false
                    ORDER BY CreatedDate
                    LIMIT 40000];
                numberOfInvalidLeads = invalidLeads.size();
            } else if (outboundRolesSet.contains(currentUser.UserRole.Name)) {
                this.invalidLeads = [
                    SELECT Id, OwnerId, IsConverted, Status, LastTransferDate, Sec_Channel__c, Channel__c, 
                           LeadSource, Lead_Nr__c, ConvertedOpportunityId, FirstName, LastName, Country
                    FROM Lead
                    WHERE Sec_Channel__c = 'Outbound' AND 
                          (Status = 'Open' OR Status = 'Contacted') AND 
                          OwnerId NOT IN :salesTeamMap.keySet() AND
                          IsConverted = false
                    ORDER BY CreatedDate
                    LIMIT 40000];
                numberOfInvalidLeads = invalidLeads.size();
            }

            invalidLeadsCountriesMap = new Map<String, Integer>();
            Integer quantityLeads = 1;
            for (Lead l : invalidLeads) {
            	if (l.Sec_Channel__c == 'Inbound') {
            		invalidLeadsInbound++;
            	}
            	if (l.Sec_Channel__c == 'Inbound' && l.Status == 'Open') {
            		invalidLeadsInboundOpen++;
            	}
            	if (l.Sec_Channel__c == 'Inbound' && l.Status == 'Contacted') {
            		invalidLeadsInboundContacted++;
            	}
            	if (l.Sec_Channel__c == 'JITB') {
            		invalidLeadsJITB++;
            	}
            	if (l.Sec_Channel__c == 'JITB' && l.Status == 'Open') {
            		invalidLeadsJITBOpen++;
            	}
            	if (l.Sec_Channel__c == 'JITB' && l.Status == 'Contacted') {
            		invalidLeadsJITBContacted++;
            	}
            	if (l.Sec_Channel__c == 'Outbound'){
            		invalidLeadsOutbound++;
            	}
            	if (l.Sec_Channel__c == 'Outbound' && l.Status == 'Open') {
            		invalidLeadsOutboundOpen++;
            	}
            	if (l.Sec_Channel__c == 'Outbound' && l.Status == 'Contacted') {
            		invalidLeadsOutboundContacted++;
            	}
                if (! invalidLeadsCountriesMap.containsKey(l.Country)) {
                    invalidLeadsCountriesMap.put(l.Country, quantityLeads);
                } else if ( invalidLeadsCountriesMap.containsKey(l.Country)) {
                    Integer quantityLeadsTemp = invalidLeadsCountriesMap.get(l.Country);
                    quantityLeadsTemp++;
                    invalidLeadsCountriesMap.put(l.Country, quantityLeadsTemp);
                }
            }
            if (invalidLeadsCountriesMap.containsKey(null)) {
                Integer numberWithoutCountries = invalidLeadsCountriesMap.get(null);
                invalidLeadsCountriesMap.put('Without Country', numberWithoutCountries);
                invalidLeadsCountriesMap.remove(null);
            }
            if (currentUser.UserRole.Name == 'Teamleiter Inbound') {
                for (String country : inboundCountiesSet) {
                    if (! invalidLeadsCountriesMap.containsKey(country)) {
                        invalidLeadsCountriesMap.put(country, 0);
                    }
                }
            }
            if (currentUser.UserRole.Name == 'Teamleiter Inbound 2') {
                for (String country : inbound2CountiesSet) {
                    if (! invalidLeadsCountriesMap.containsKey(country)) {
                        invalidLeadsCountriesMap.put(country, 0);
                    }
                }
            }
        }
    }

    /*******************************************************************************
    *  Name            : returnUserId()
    *  Summary         : getting ID current user    
    *  CreatedDate     : 30.11.2016
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
        'Slovakia', 
        'Czech Republic',
        'Netherlands',
        'Belgium-NL',
        'Poland'
    }; 
}