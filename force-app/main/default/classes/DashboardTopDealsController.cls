public with sharing class DashboardTopDealsController {
	public String selectedPeriod {get; set;}
	public String selectedYear {get; set;}
	public String startDateOfMonthString {get; set;}
    public String endDateOfMonthString {get; set;}  
    public List<SortingList> sortingList {get;set;}
    public Map<String, Decimal> finalTopDealsMap {get; set;}
    public Map<String, String> namesOfTopDealsMap {get; set;}
    public Map<String, String> linkColorsMap {get; set;}  
    public User currentUser {get; set;}
    public Date startDateOfPeriod;
    public Date endDateOfPeriod;
    private String userId;

    public DashboardTopDealsController() {    
    }

    public void init() {
    	if (this.selectedYear == null) {
            this.selectedYear = returnCurrentYear();
        }
        this.finalTopDealsMap = new Map<String, Decimal>(); 
        this.namesOfTopDealsMap = new Map<String, String>();
        this.sortingList = new List<SortingList>();
        this.linkColorsMap = new Map<String, String>(); 
        try {
        	generateDataForCharts();
        	generateTopDealsList();
        } catch (Exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
        }  
    }


    /*******************************************************************************
    *  Name            : generateTopDealsList()
    *  Summary         : generating Top Deals in progress list for the selected period   
    *  CreatedDate     : 10/07/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
 	public void generateTopDealsList() {
 		returnUserId();
        this.currentUser = [
            SELECT Id, UserRole.Name, Profile.Name, Name, UserRoleId
            FROM User
            WHERE Id = :this.userId]; 

        Map<Id, UserRole> salesRolesMap = new Map<Id, UserRole>([
            SELECT Id
            FROM UserRole
            WHERE ParentRoleId = :currentUser.UserRoleId
            LIMIT 1000]);

        Map<Id, User> salesTeamMap = new Map<Id, User>([
            SELECT Name
            FROM User
            WHERE (UserRoleId IN :salesRolesMap.keySet() OR Id = :currentUser.Id) AND 
        		  isActive = TRUE
            LIMIT 10000]);

        if (teamLeaderRolesSet.contains(this.currentUser.UserRole.Name) || this.currentUser.Profile.Name == 'System Administrator') {
            Map<Id, Opportunity> allOpportunitiesMap = new Map<Id, Opportunity>([
                SELECT Name, OwnerId, StageName, Total_consumption_l_month__c, Anzahl_der_Karten__c, CreatedDate,
                       (SELECT Field, NewValue, CreatedDate FROM Histories WHERE Field = 'StageName' AND CreatedDate <= :endDateOfPeriod ORDER BY CreatedDate DESC LIMIT 1),
                       (SELECT Id, LastModifiedDate
                            FROM Tasks
                            WHERE IsClosed = TRUE AND
                                  LastModifiedDate >= :startDateOfPeriod AND LastModifiedDate <= :endDateOfPeriod
                            ORDER BY LastModifiedDate DESC
                            LIMIT 1)
                FROM Opportunity
                WHERE OwnerId IN :salesTeamMap.keySet() AND
                      CreatedDate <= :endDateOfPeriod AND
                      (Total_consumption_l_month__c >= 500 OR Anzahl_der_Karten__c >= 3)
                LIMIT 50000]);

            Map<Id, Opportunity> potentialOpptyTopDealsMap = new Map<Id, Opportunity>();
            for (Opportunity opp : allOpportunitiesMap.values()) {
                if (! opp.Histories.isEmpty()) {
                    if ((opp.Histories.get(0).NewValue == 'Closed Won' ||
                        opp.Histories.get(0).NewValue == 'Closed Lost' ||
                        opp.Histories.get(0).NewValue == 'CreditCheck abgelehnt') && 
                        opp.Histories.get(0).CreatedDate >= startDateOfPeriod && opp.Histories.get(0).CreatedDate <= endDateOfPeriod.addDays(1)) {
                        potentialOpptyTopDealsMap.put(opp.Id, opp);
                    } else if (opp.Histories.get(0).NewValue != 'Closed Won' &&
                              opp.Histories.get(0).NewValue != 'Closed Lost' &&
                              opp.Histories.get(0).NewValue != 'CreditCheck abgelehnt') {
                        potentialOpptyTopDealsMap.put(opp.Id, opp);
                    }
                } else {
                    if ((opp.StageName == 'Closed Won' ||
                        opp.StageName == 'Closed Lost' ||
                        opp.StageName == 'CreditCheck abgelehnt') &&
                        opp.CreatedDate >= startDateOfPeriod && opp.CreatedDate <= endDateOfPeriod.addDays(1)) {
                        potentialOpptyTopDealsMap.put(opp.Id, opp);
                    } else if (opp.StageName != 'Closed Won' &&
                              opp.StageName != 'Closed Lost' &&
                              opp.StageName != 'CreditCheck abgelehnt') {
                        potentialOpptyTopDealsMap.put(opp.Id, opp);
                    }
                }
            }

            List<SortingList> opportunitiesSortingList = new List<SortingList>();
            for (Opportunity opp : potentialOpptyTopDealsMap.values()) {
                if (opp.Total_consumption_l_month__c != null) {
                    SortingList opportynityToSort = new SortingList(opp.Id, opp.Total_consumption_l_month__c);
                    opportunitiesSortingList.add(opportynityToSort);       
                } else {
                    SortingList opportynityToSort = new SortingList(opp.Id, opp.Anzahl_der_Karten__c);
                    opportunitiesSortingList.add(opportynityToSort);
                }             
            }
            opportunitiesSortingList.sort();

            Map<Opportunity, String> topDealsOfOpportunityMap = new Map<Opportunity, String>();
            Integer counter = 0;
			while(topDealsOfOpportunityMap.size() < 10 && counter < allOpportunitiesMap.size()) {
                Opportunity oppty = allOpportunitiesMap.get(opportunitiesSortingList.get(counter).Id);
                if (Date.today() >= startDateOfPeriod && Date.today() <= endDateOfPeriod) {
                    if (oppty.Tasks.isEmpty()) {   
                        topDealsOfOpportunityMap.put(oppty, '6+');
                    } else if (oppty.Tasks.get(0).LastModifiedDate.Date().daysBetween(Datetime.now().Date()) >= 6) {
                        topDealsOfOpportunityMap.put(oppty, '6+');
                    } else if (oppty.Tasks.get(0).LastModifiedDate.Date().daysBetween(Datetime.now().Date()) == 4 ||
                               oppty.Tasks.get(0).LastModifiedDate.Date().daysBetween(Datetime.now().Date()) == 5) {
                        topDealsOfOpportunityMap.put(oppty, '4-5');
                    } else if (oppty.Tasks.get(0).LastModifiedDate.Date().daysBetween(Datetime.now().Date()) <= 3) {
                        topDealsOfOpportunityMap.put(oppty, '1-3');
                    }
                } else {
                    if (oppty.Tasks.isEmpty()) {   
                        topDealsOfOpportunityMap.put(oppty, '6+');
                    } else if (oppty.Tasks.get(0).LastModifiedDate.Date().daysBetween(endDateOfPeriod) >= 6) {
                        topDealsOfOpportunityMap.put(oppty, '6+');
                    } else if (oppty.Tasks.get(0).LastModifiedDate.Date().daysBetween(endDateOfPeriod) == 4 ||
                               oppty.Tasks.get(0).LastModifiedDate.Date().daysBetween(endDateOfPeriod) == 5) {
                        topDealsOfOpportunityMap.put(oppty, '4-5');
                    } else if (oppty.Tasks.get(0).LastModifiedDate.Date().daysBetween(endDateOfPeriod) <= 3) {
                        topDealsOfOpportunityMap.put(oppty, '1-3');
                    }
                }	 
			    counter++;
			}

            Map<Id, Lead> allLeadsMap = new Map<Id, Lead>([
                SELECT Name, OwnerId, Status, Monatlicher_Kraftstoffverbrauch_in_Liter__c, Anzahl_der_Fahrzeuge__c, CreatedDate,
                       (SELECT Field, NewValue, CreatedDate FROM Histories WHERE Field = 'Status' AND CreatedDate <= :endDateOfPeriod ORDER BY CreatedDate DESC LIMIT 1),
                       (SELECT Id, LastModifiedDate
                            FROM Tasks
                            WHERE IsClosed = TRUE AND 
                                  LastModifiedDate >= :startDateOfPeriod AND LastModifiedDate <= :endDateOfPeriod
                            ORDER BY LastModifiedDate DESC
                            LIMIT 1)
                FROM Lead
                WHERE OwnerId IN :salesTeamMap.keySet() AND
                      CreatedDate <= :endDateOfPeriod AND
                      (Monatlicher_Kraftstoffverbrauch_in_Liter__c >= 500 OR Anzahl_der_Fahrzeuge__c >= 3)
                LIMIT 50000]);

            Map<Id, Lead> potentialLeadTopDealsMap = new Map<Id, Lead>();
            for (Lead lead : allLeadsMap.values()) {
                if (! lead.Histories.isEmpty()) {
                    if ((lead.Histories.get(0).NewValue == 'Disqualified' ||
                        lead.Histories.get(0).NewValue == 'Konvertierte Leads') && 
                        lead.Histories.get(0).CreatedDate >= startDateOfPeriod && lead.Histories.get(0).CreatedDate <= endDateOfPeriod.addDays(1)) {
                        potentialLeadTopDealsMap.put(lead.Id, lead);
                    } else if (lead.Histories.get(0).NewValue != 'Disqualified' &&
                               lead.Histories.get(0).NewValue != 'Konvertierte Leads') {
                        potentialLeadTopDealsMap.put(lead.Id, lead);
                    } 
                } else {
                    if ((lead.Status == 'Disqualified' ||
                        lead.Status == 'Konvertierte Leads') &&
                        lead.CreatedDate >= startDateOfPeriod && lead.CreatedDate <= endDateOfPeriod.addDays(1)) {
                        potentialLeadTopDealsMap.put(lead.Id, lead);
                    } else if (lead.Status != 'Disqualified' &&
                              lead.Status != 'Konvertierte Leads') {
                        potentialLeadTopDealsMap.put(lead.Id, lead);
                    }
                }
            }

            List<SortingList> leadsSortingList = new List<SortingList>();
            for (Lead l : potentialLeadTopDealsMap.values()) {
                if (l.Monatlicher_Kraftstoffverbrauch_in_Liter__c != null) {
                    SortingList leadToSort = new SortingList(l.Id, l.Monatlicher_Kraftstoffverbrauch_in_Liter__c);
                    leadsSortingList.add(leadToSort);       
                } else {
                    SortingList leadToSort = new SortingList(l.Id, l.Anzahl_der_Fahrzeuge__c);
                    leadsSortingList.add(leadToSort);
                }             
            }
            leadsSortingList.sort();

            Map<Lead, String> topDealsOfLeadMap = new Map<Lead, String>();
            Integer calculator = 0;
            while(topDealsOfLeadMap.size() < 10 && calculator < allLeadsMap.size()) {
                Lead lead = allLeadsMap.get(leadsSortingList.get(calculator).Id);
                if (Date.today() >= startDateOfPeriod && Date.today() <= endDateOfPeriod) {
                    if (lead.Tasks.isEmpty()) {
                        topDealsOfLeadMap.put(lead, '6+');
                    } else if (lead.Tasks.get(0).LastModifiedDate.Date().daysBetween(Datetime.now().Date()) >= 6) {
                        topDealsOfLeadMap.put(lead, '6+');
                    } else if (lead.Tasks.get(0).LastModifiedDate.Date().daysBetween(Datetime.now().Date()) == 4 ||
                               lead.Tasks.get(0).LastModifiedDate.Date().daysBetween(Datetime.now().Date()) == 5) {
                        topDealsOfLeadMap.put(lead, '4-5');
                    } else if (lead.Tasks.get(0).LastModifiedDate.Date().daysBetween(Datetime.now().Date()) <= 3) {
                        topDealsOfLeadMap.put(lead, '1-3');
                    }
                } else {
                    if (lead.Tasks.isEmpty()) {
                        topDealsOfLeadMap.put(lead, '6+');
                    } else if (lead.Tasks.get(0).LastModifiedDate.Date().daysBetween(endDateOfPeriod) >= 6) {
                        topDealsOfLeadMap.put(lead, '6+');
                    } else if (lead.Tasks.get(0).LastModifiedDate.Date().daysBetween(endDateOfPeriod) == 4 ||
                               lead.Tasks.get(0).LastModifiedDate.Date().daysBetween(endDateOfPeriod) == 5) {
                        topDealsOfLeadMap.put(lead, '4-5');
                    } else if (lead.Tasks.get(0).LastModifiedDate.Date().daysBetween(endDateOfPeriod) <= 3) {
                        topDealsOfLeadMap.put(lead, '1-3');
                    }
                }   
                calculator++;
            }

			//FINAL
			List<SortingList> sortingListTemp = new List<SortingList>();
			for (Opportunity opp : topDealsOfOpportunityMap.keySet()) {
                SortingList sortingListValue;
                if (opp.Total_consumption_l_month__c != null) {
                    sortingListValue = new SortingList(opp.Id, opp.Total_consumption_l_month__c);
                } else {
                    Decimal potentialTotalConsumption = opp.Anzahl_der_Karten__c * (1750/12);
                    sortingListValue = new SortingList(opp.Id, potentialTotalConsumption );
                }           
				sortingListTemp.add(sortingListValue);
                if (! opp.Histories.isEmpty()) {
                    this.namesOfTopDealsMap.put(opp.Id, opp.Name + ' (' + opp.Histories.get(0).NewValue + ')');
                } else {
                    this.namesOfTopDealsMap.put(opp.Id, opp.Name + ' (' + opp.StageName + ')');
                }
                this.linkColorsMap.put(opp.Id, topDealsOfOpportunityMap.get(opp));
			}
			for (Lead lead : topDealsOfLeadMap.keySet()) {
                SortingList sortingListValue;	
                if (lead.Monatlicher_Kraftstoffverbrauch_in_Liter__c != null) {
                    sortingListValue = new SortingList(lead.Id, lead.Monatlicher_Kraftstoffverbrauch_in_Liter__c);
                } else {
                    Decimal potentialTotalConsumption = lead.Anzahl_der_Fahrzeuge__c * (1750/12);
                    sortingListValue = new SortingList(lead.Id, potentialTotalConsumption );
                }
                sortingListTemp.add(sortingListValue);
                if (! lead.Histories.isEmpty()) {
                    this.namesOfTopDealsMap.put(lead.Id, lead.Name + ' (' + lead.Histories.get(0).NewValue + ')');
                } else {
                    this.namesOfTopDealsMap.put(lead.Id, lead.Name + ' (' + lead.Status + ')');
                }	
                this.linkColorsMap.put(lead.Id, topDealsOfLeadMap.get(lead));
			}
            sortingListTemp.sort();
			Integer index = 0;
			while(this.sortingList.size() < 10 && index < sortingListTemp.size()) {
				this.sortingList.add(sortingListTemp.get(index));
			    index++;
			}
			this.sortingList.sort();
			for (SortingList sortList : this.sortingList) {
				this.finalTopDealsMap.put(sortList.Id, sortList.compareValue);
			}
        }
 	}
    

 	/*******************************************************************************
    *  Name            : sortingList()
    *  Summary         : Sorting by total fuel consumption    
    *  CreatedDate     : 10/07/2017
    *  Parameters      : String id, Decimal compareValue
    *  Returns         : Integer
    ******************************************************************************/
    public class SortingList implements Comparable {
        public String id {get; set;}
        public Decimal compareValue {get; set;}

        public sortingList(String id, Decimal compareValue) {
            this.id = id;
            this.compareValue = compareValue;
        }

        public Integer compareTo(Object compareTo) {
            SortingList compareToU = (SortingList)compareTo;
            if (this.compareValue == compareToU.compareValue) return 0;
            if (this.compareValue < compareToU.compareValue) return 1;
            return -1;        
        }
    }
    

    /*******************************************************************************
    *  Name            : generateDataForCharts()
    *  Summary         : generating of the values of the selected period   
    *  CreatedDate     : 10/07/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void generateDataForCharts() {
    	Date startDateOfMonth;
    	Date endDateOfMonth;
        List<Fleetcor_Calendar_Week__c> currentWeek = [
            SELECT Name, Fleetcor_Calendar_Month__r.Name, Start_Date__c, End_Date__c
            FROM Fleetcor_Calendar_Week__c 
            WHERE Fleetcor_Calendar_Month__r.Fleetcor_Calendar_Year__r.Name = :this.selectedYear AND 
                  Start_Date__c <= TODAY AND End_Date__c >= TODAY 
            LIMIT 1];

        Fleetcor_Calendar_Month__c currentMonth = new Fleetcor_Calendar_Month__c();
        if (this.selectedPeriod == null) {
            if ( currentWeek.isEmpty() ) {
                currentWeek = [
                    SELECT Name, Fleetcor_Calendar_Month__r.Name, Start_Date__c, End_Date__c
                    FROM Fleetcor_Calendar_Week__c 
                    WHERE Fleetcor_Calendar_Month__r.Fleetcor_Calendar_Year__r.Name = :this.selectedYear 
                    ORDER BY Start_Date__c DESC
                    LIMIT 1];
            }
            String curMonth = currentWeek.get(0).Fleetcor_Calendar_Month__r.Name;
            currentMonth = [
                SELECT Name, Start_Date__c, End_Date__c, Fleetcor_Calendar_Year__r.Name
                FROM Fleetcor_Calendar_Month__c 
                WHERE Name = :curMonth AND Fleetcor_Calendar_Year__r.Name = :this.selectedYear
                LIMIT 1];

	        //week
	        this.startDateOfPeriod = currentWeek.get(0).Start_Date__c;
            this.endDateOfPeriod = currentWeek.get(0).End_Date__c;
            startDateOfMonth = currentMonth.Start_Date__c;
			endDateOfMonth = currentMonth.End_Date__c;
			this.selectedPeriod = currentWeek.get(0).Id;
        } else {
    		Id selectedId = selectedPeriod;          
            if (String.valueOf(selectedId.getSobjectType()) == 'Fleetcor_Calendar_Week__c') {
                currentWeek = [
                    SELECT Name, Fleetcor_Calendar_Month__r.Name, Fleetcor_Calendar_Month__r.Start_Date__c, Fleetcor_Calendar_Month__r.End_Date__c,
                           Start_Date__c, End_Date__c
                    FROM Fleetcor_Calendar_Week__c 
                    WHERE Id = :this.selectedPeriod
                    LIMIT 1];

                //week
		        this.startDateOfPeriod = currentWeek.get(0).Start_Date__c;
	            this.endDateOfPeriod = currentWeek.get(0).End_Date__c;
	            startDateOfMonth = currentWeek.get(0).Fleetcor_Calendar_Month__r.Start_Date__c;
				endDateOfMonth = currentWeek.get(0).Fleetcor_Calendar_Month__r.End_Date__c;    
            } else if (String.valueOf(selectedId.getSobjectType()) == 'Fleetcor_Calendar_Month__c') {
                currentMonth = [
                    SELECT Name, Start_Date__c, End_Date__c
                    FROM Fleetcor_Calendar_Month__c 
                    WHERE Id = :this.selectedPeriod
                    LIMIT 1];

                //month
		        this.startDateOfPeriod = currentMonth.Start_Date__c;
	            this.endDateOfPeriod = currentMonth.End_Date__c;
	            startDateOfMonth = currentMonth.Start_Date__c;
				endDateOfMonth = currentMonth.End_Date__c;	
            }         
        }
        startDateOfMonthString = String.valueOf(startDateOfMonth.day()) + ' ' + monthsMap.get(startDateOfMonth.month());
        endDateOfMonthString = String.valueOf(endDateOfMonth.day()) + ' ' + monthsMap.get(endDateOfMonth.month());
    }


    /*******************************************************************************
    *  Name            : getPeriodsList()
    *  Summary         : generating FLT periods (months and weeks) list   
    *  CreatedDate     : 10/07/2017
    *  Parameters      : -
    *  Returns         : SelectOption (FLT periods)
    ******************************************************************************/
    public List<SelectOption> getPeriodsList() {
    	String thisMonth = '';
        Integer monthIndex = 12;
        
        List<Fleetcor_Calendar_Month__c> currentWeekTemp = [
                SELECT Name, Month_Number__c 
                FROM Fleetcor_Calendar_Month__c 
                WHERE Fleetcor_Calendar_Year__r.Name = :this.selectedYear AND 
                      Start_Date__c <= TODAY AND 
                      End_Date__c >= TODAY 
                LIMIT 1];
        
        List<SelectOption> options = new List<SelectOption>();
        Set<String> monthsSet = new Set<String>();

        if ( ! currentWeekTemp.isEmpty() ) {
            for (Integer i = 1; i <= currentWeekTemp.get(0).Month_Number__c; i++) {
                monthsSet.add(monthsMap.get(i));
            }
            monthIndex = Integer.valueOf(currentWeekTemp.get(0).Month_Number__c);
        } else {
            for (Integer i = 1; i <= 12; i++) {
                monthsSet.add(monthsMap.get(i));
            }      
        }

        List<Fleetcor_Calendar_Week__c> weeksList = [
                SELECT End_Date__c, Start_Date__c, Fleetcor_Calendar_Month__r.Name,
                    Fleetcor_Calendar_Month__c
                FROM Fleetcor_Calendar_Week__c
                WHERE Fleetcor_Calendar_Month__r.Name IN :monthsSet AND 
                   Fleetcor_Calendar_Month__r.Fleetcor_Calendar_Year__r.Name = :this.selectedYear
                ORDER BY Start_Date__c DESC];

        for (Fleetcor_Calendar_Week__c week : weeksList) {

            if (thisMonth != week.Fleetcor_Calendar_Month__r.Name) {
                thisMonth = week.Fleetcor_Calendar_Month__r.Name;
                options.add(new SelectOption(week.Fleetcor_Calendar_Month__c, monthsMap.get(monthIndex)));
                if (monthIndex != 1) {
                    monthIndex--;
                }
            }
            
            options.add(
                new SelectOption(
                    week.Id, 
                    '---' + week.Fleetcor_Calendar_Month__r.Name + ' (' + week.Start_Date__c.day() + '.' + week.Start_Date__c.month() + ' - ' + 
                    week.End_Date__c.day() + '.' + week.End_Date__c.month() + ')'));
        }
        return options;	
    }


    /*******************************************************************************
    *  Name            : getYearsList()
    *  Summary         : Display years in selectbox     
    *  CreatedDate     : 10/07/2017
    *  Parameters      : 
    *  Returns         : List<SelectOption>
    ******************************************************************************/
    public List<SelectOption> getYearsList() {
        List<SelectOption> options = new List<SelectOption>();
        List<Fleetcor_Calendar_Year__c> fltYearsList = [SELECT Name FROM Fleetcor_Calendar_Year__c ORDER BY Name DESC LIMIT 1000]; 
        for (Fleetcor_Calendar_Year__c fcy : fltYearsList) {
            options.add(new SelectOption(fcy.Name, fcy.Name));
        }
        return options;
    }


    /*******************************************************************************
    *  Name            : returnCurrentYear()
    *  Summary         : Returns current year based on Fleetcor Calendar (custom objects)     
    *  CreatedDate     : 10/07/2017
    *  Parameters      : 
    *  Returns         : String – year
    ******************************************************************************/
    public String returnCurrentYear() {
        String currentYear = String.valueOf(Date.today().year());
        Date lastDayOfYear = [
            SELECT End_Date__c 
            FROM Fleetcor_Calendar_Month__c
            WHERE Fleetcor_Calendar_Year__r.Name = :currentYear
            ORDER BY End_Date__c DESC 
            LIMIT 1].End_Date__c;
        if (Date.today() > lastDayOfYear) {
            return String.valueOf(Date.today().year() + 1);
        } else {
            return String.valueOf(Date.today().year());
        }
    }


    /*******************************************************************************
    *  Name            : changeYear()
    *  Summary         : Setting the period depending on the selected year    
    *  CreatedDate     : 10/07/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void changeYear() {
        List<Fleetcor_Calendar_Week__c> currentFLTweek = [
            SELECT Id, Fleetcor_Calendar_Month__r.Fleetcor_Calendar_Year__r.Name
            FROM Fleetcor_Calendar_Week__c
            WHERE Start_Date__c <= TODAY AND 
                  End_Date__c >= TODAY
            LIMIT 1];

        String currentWeekId;
        String currentFLTyear;
        if (! currentFLTweek.isEmpty()) {
            currentWeekId = currentFLTweek.get(0).Id;
            currentFLTyear = currentFLTweek.get(0).Fleetcor_Calendar_Month__r.Fleetcor_Calendar_Year__r.Name;
        }

        if (this.selectedYear != currentFLTyear) {
            String firstMonthId = [
                SELECT Id
                FROM Fleetcor_Calendar_Month__c
                WHERE Name = :monthsMap.get(1) AND
                    Fleetcor_Calendar_Year__r.Name = :this.selectedYear
                LIMIT 1].Id;
            this.selectedPeriod = firstMonthId;
        } else {
            this.selectedPeriod = currentWeekId;
        }
        init();       
    }
    

	/*******************************************************************************
    *  Name            : returnUserId()
    *  Summary         : getting current user ID    
    *  CreatedDate     : 10/07/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void returnUserId() {
        this.userId = Apexpages.currentPage().getParameters().get('userId');
            if (this.userId == null) {
                this.userId = UserInfo.getUserId();
            }
    }

    private Map<Integer, String> monthsMap = new Map<Integer, String>{
        1 => 'January', 
        2 => 'February', 
        3 => 'March',
        4 => 'April',
        5 => 'May',
        6 => 'June',
        7 => 'July',
        8 => 'August',
        9 => 'September',
        10 => 'October',
        11 => 'November',
        12 => 'December'};

    private Set<String> teamLeaderRolesSet = new Set<String>{
    	'CCS Telesales Team Lead',
		'Teamleiter Harte Hank', 
        'Teamleiter Inbound', 
        'Teamleiter Inbound 2',
        'Teamleiter Harte Hank',
        'Teamleiter Outbound 1',
        'Teamleiter Outbound 2',
        'Teamleiter Outbound 3',
        'Teamleiter Outbound 4',
        'Teamleiter Outbound 5',
        'AllStar Teamleader'};
}