public with sharing class DashboardIntensityOfSalesWorkCtrl {
	public String selectedPeriod {get; set;}
	public String selectedYear {get; set;}
	public String startDateOfMonthString {get; set;}
    public String endDateOfMonthString {get; set;}
    public User currentUser {get; set;}
    public Map<Id, User> salesTeamMap {get; set;}
    public List<FinalList> finalList {get; set;}
    public Map<String, Integer> finalOpportunitiesOfUserMap {get; set;}
    public Map<String, Integer> finalLeadsOfUserMap {get; set;}
    public Map<String, Integer> finalTasksOfUserMap {get; set;}
    private String userId;
    public Date startDateOfPeriod;
    public Date endDateOfPeriod;

    public DashboardIntensityOfSalesWorkCtrl() {
    }


    public void init() {
    	if (this.selectedYear == null) {
            this.selectedYear = returnCurrentYear();
        }
        this.finalList = new List<FinalList>();
        this.finalOpportunitiesOfUserMap = new Map<String, Integer>();
        this.finalLeadsOfUserMap = new Map<String, Integer>();
        this.finalTasksOfUserMap = new Map<String, Integer>();
        try {
        	generateDataForCharts();
        	calculatingIntensityOfSalesWork();
        } catch (Exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
        } 
    }


    /*******************************************************************************
    *  Name            : calculatingIntensityOfSalesWork()
    *  Summary         : calculating the intensity of sales for the selected period   
    *  CreatedDate     : 12/07/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
 	public void calculatingIntensityOfSalesWork() {
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

        this.salesTeamMap = new Map<Id, User>([
            SELECT Name
            FROM User
            WHERE (UserRoleId IN :salesRolesMap.keySet() OR Id = :currentUser.Id) AND 
        		  isActive = TRUE
            LIMIT 10000]);

        if (teamLeaderRolesSet.contains(this.currentUser.UserRole.Name) || this.currentUser.Profile.Name == 'System Administrator') {
    		List<Opportunity> validOpptiesList = new List<Opportunity>([
	            SELECT Name, OwnerId, StageName, CreatedDate
	            FROM Opportunity
	            WHERE OwnerId IN :this.salesTeamMap.keySet() AND 
	            	  StageName != 'Closed Won' AND 
	            	  StageName != 'Closed Lost' AND
                      StageName != 'CreditCheck abgelehnt'
	            LIMIT 50000
            ]);

            List<Opportunity> opptiesWithTerminalStatusList = new List<Opportunity>([
	            SELECT Name, OwnerId, StageName, CreatedDate,
	                   (SELECT Field, CreatedDate, NewValue
	                   	FROM Histories 
	                   	WHERE Field = 'StageName' AND
	       					  CreatedDate >= :this.startDateOfPeriod AND CreatedDate <= :this.endDateOfPeriod.addDays(1)
	           		  	ORDER BY CreatedDate DESC
	           		  	LIMIT 1)
	            FROM Opportunity
	            WHERE OwnerId IN :this.salesTeamMap.keySet() AND 
            	      (StageName = 'Closed Won' OR
                       StageName = 'Closed Lost' OR 
                       StageName = 'CreditCheck abgelehnt')
	            LIMIT 50000
            ]);

            for (Opportunity opp : opptiesWithTerminalStatusList) {
        		if (! opp.Histories.isEmpty()) {
        			validOpptiesList.add(opp);
        		}  
            }

        	Map<String, List<Opportunity>> allOpportunitiesOfUserMap = new Map<String, List<Opportunity>>();
        	for (Opportunity opp : validOpptiesList) {
	        	if (! allOpportunitiesOfUserMap.containsKey(opp.OwnerId)) {
			        allOpportunitiesOfUserMap.put(opp.OwnerId, new List<Opportunity>());
			    }
		    	allOpportunitiesOfUserMap.get(opp.OwnerId).add(opp);
			}
            
    		List<Lead> validLeadsList = new List<Lead>([
            	SELECT Name, OwnerId, Status, CreatedDate
			   	FROM Lead
			   	WHERE OwnerId IN :this.salesTeamMap.keySet() AND
	   				  IsConverted = false AND
	   				  Status != 'Disqualified'
			  	LIMIT 50000
        	]);

			List<Lead> leadsWithTerminalStatusList = new List<Lead>([
            	SELECT Name, OwnerId, Status, CreatedDate,
    				   (SELECT Field, CreatedDate, NewValue
	                   	FROM Histories 
	                   	WHERE Field = 'Status' AND
	       					  CreatedDate >= :this.startDateOfPeriod AND CreatedDate <= :this.endDateOfPeriod.addDays(1)
	           		  	ORDER BY CreatedDate DESC
	           		  	LIMIT 1)
			   	FROM Lead
			   	WHERE OwnerId IN :this.salesTeamMap.keySet() AND
	   				  IsConverted = false AND
	   				  Status = 'Disqualified'
			  	LIMIT 50000
        	]);

            for (Lead ld : leadsWithTerminalStatusList) {
            	if (! ld.Histories.isEmpty()) {
            		validLeadsList.add(ld);
            	} 
            }

        	Map<String, List<Lead>> allLeadsOfUserMap = new Map<String, List<Lead>>();
        	for (Lead lead : validLeadsList) {
            	if (! allLeadsOfUserMap.containsKey(lead.OwnerId)) {
			        allLeadsOfUserMap.put(lead.OwnerId, new List<Lead>());
			    }
		    	allLeadsOfUserMap.get(lead.OwnerId).add(lead);
            }

            List<Task> validTasksList = [
            	SELECT Id, OwnerId, Type, WhoId, Status, ActivityDate, isClosed
			   	FROM Task
           		WHERE CreatedDate >= :this.startDateOfPeriod AND CreatedDate <= :this.endDateOfPeriod AND
			          OwnerId IN :this.salesTeamMap.keySet() AND
		         	  IsClosed = TRUE
               	LIMIT 50000];

           	Map<String, List<Task>> allTasksOfUserMap = new Map<String, List<Task>>();
           	for (Task t : validTasksList) {
       			if (! allTasksOfUserMap.containsKey(t.OwnerId)) {
			        allTasksOfUserMap.put(t.OwnerId, new List<Task>());
			    }
		    	allTasksOfUserMap.get(t.OwnerId).add(t);
           	}

			///FINAL
            for (String userId : this.salesTeamMap.keySet()) {
                if ( ! allOpportunitiesOfUserMap.containsKey(userId)) {
                    allOpportunitiesOfUserMap.put(userId, new List<Opportunity>());
                }

                if ( ! allLeadsOfUserMap.containsKey(userId)) {
                    allLeadsOfUserMap.put(userId, new List<Lead>());
                }

                if ( ! allTasksOfUserMap.containsKey(userId)) {
                    allTasksOfUserMap.put(userId, new List<Task>());
                }

                this.finalOpportunitiesOfUserMap.put(userId, allOpportunitiesOfUserMap.get(userId).size());
                this.finalLeadsOfUserMap.put(userId, allLeadsOfUserMap.get(userId).size());
                this.finalTasksOfUserMap.put(userId, allTasksOfUserMap.get(userId).size());

                if (allOpportunitiesOfUserMap.get(userId).size() + allLeadsOfUserMap.get(userId).size() != 0) {
                	finalList.add(new FinalList(
                    userId,
                    Decimal.valueOf(allTasksOfUserMap.get(userId).size())/(allOpportunitiesOfUserMap.get(userId).size() + allLeadsOfUserMap.get(userId).size())));         
                } else {
                	finalList.add(new FinalList(
                    userId,
                    0)); 
                }              
            }
            finalList.sort();   			
        }
 	}

 	public class FinalList implements Comparable {
        public String id {get; set;}
        public Decimal compareValue {get; set;}

        public finalList(String id, Decimal compareValue) {
            this.id = id;
            this.compareValue = compareValue;
        }

        public Integer compareTo(Object compareTo) {
            FinalList compareToU = (FinalList)compareTo;
            if (compareValue == compareToU.compareValue) return 0;
            if (compareValue < compareToU.compareValue) return -1;
            return 1;        
        }
    }


    /*******************************************************************************
    *  Name            : generateDataForCharts()
    *  Summary         : generating of the values of the selected period   
    *  CreatedDate     : 12/07/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void generateDataForCharts() {
    	Date startDateOfMonth;
    	Date endDateOfMonth;
        List<Fleetcor_Calendar_Week__c> currentWeek = [
            SELECT Name, Fleetcor_Calendar_Month__r.Name, Fleetcor_Calendar_Month__r.Start_Date__c, Fleetcor_Calendar_Month__r.End_Date__c,
                   Start_Date__c, End_Date__c
            FROM Fleetcor_Calendar_Week__c 
            WHERE Fleetcor_Calendar_Month__r.Fleetcor_Calendar_Year__r.Name = :this.selectedYear AND 
                  Start_Date__c <= TODAY AND End_Date__c >= TODAY 
            LIMIT 1];

        Fleetcor_Calendar_Month__c currentMonth = new Fleetcor_Calendar_Month__c();
        if (this.selectedPeriod == null) {
            if ( currentWeek.isEmpty() ) {
                currentWeek = [
                    SELECT Name, Fleetcor_Calendar_Month__r.Name, Fleetcor_Calendar_Month__r.Start_Date__c, Fleetcor_Calendar_Month__r.End_Date__c,
                           Start_Date__c, End_Date__c
                    FROM Fleetcor_Calendar_Week__c 
                    WHERE Fleetcor_Calendar_Month__r.Fleetcor_Calendar_Year__r.Name = :this.selectedYear 
                    ORDER BY Start_Date__c DESC
                    LIMIT 1];
            }
	        //week
	        this.startDateOfPeriod = currentWeek.get(0).Start_Date__c;
            this.endDateOfPeriod = currentWeek.get(0).End_Date__c;
            startDateOfMonth = currentWeek.get(0).Fleetcor_Calendar_Month__r.Start_Date__c;
			endDateOfMonth = currentWeek.get(0).Fleetcor_Calendar_Month__r.End_Date__c;
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
        this.startDateOfMonthString = String.valueOf(startDateOfMonth.day()) + ' ' + monthsMap.get(startDateOfMonth.month());
        this.endDateOfMonthString = String.valueOf(endDateOfMonth.day()) + ' ' + monthsMap.get(endDateOfMonth.month());
    }


    /*******************************************************************************
    *  Name            : getPeriodsList()
    *  Summary         : generating FLT periods (months and weeks) list   
    *  CreatedDate     : 12/07/2017
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
    *  CreatedDate     : 12/07/2017
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
    *  CreatedDate     : 12/07/2017
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
    *  CreatedDate     : 12/07/2017
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
    *  CreatedDate     : 12/07/2017
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