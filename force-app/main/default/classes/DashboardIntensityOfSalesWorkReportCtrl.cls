public with sharing class DashboardIntensityOfSalesWorkReportCtrl {
	public User currentUser {get; set;}
    public String selectedPeriod {get; set;}
    public String selectedYear {get; set;}
    public String startDateOfMonthString {get; set;}
    public String endDateOfMonthString {get; set;}
    public Integer numberTasks {get; set;}
    public Integer numberOppties {get; set;}
    public Integer numberLeads {get; set;}
    public Map<Id, Task> validTasksMap {get; set;}
    public Map<String, ObjectStatistics> finalObjectStatisticMap {get; set;}
    public List<String> finalWrapList {get; set;}
    public Date startDateOfPeriod;
    public Date endDateOfPeriod;

    public DashboardIntensityOfSalesWorkReportCtrl() {      
    }

    public void init() {
    	String periodId = Apexpages.currentPage().getParameters().get('period');
    	String year = ApexPages.currentPage().getParameters().get('year');
    	if (this.selectedPeriod == null) {
            this.selectedPeriod = periodId;
        }
        if (this.selectedYear == null) {
            this.selectedYear = year;
        }
        try {   	
        	generateDataForCharts();
        	calculatingIntensityOfSalesWorkReport();
        } catch (Exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
        } 	
    }


    /*******************************************************************************
    *  Name            : calculatingIntensityOfSalesWorkReport()
    *  Summary         : downloading a detailed sales intensity report for the user for the selected period   
    *  CreatedDate     : 13/07/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
 	public void calculatingIntensityOfSalesWorkReport() {
 		String userId = Apexpages.currentPage().getParameters().get('userid');
 		this.currentUser = [
            SELECT Name, Profile.Name, LocaleSidKey, UserRole.Name
            FROM User
            WHERE Id = :userId
            LIMIT 1
        ];
		Map<Id, Opportunity> validOpptiesMap = new Map<Id, Opportunity>([
            SELECT Name, OwnerId, StageName, CreatedDate
            FROM Opportunity
            WHERE OwnerId = :this.currentUser.Id AND 
            	  StageName != 'Closed Won' AND 
            	  StageName != 'Closed Lost' AND
                StageName != 'CreditCheck abgelehnt'
            LIMIT 50000
        ]);

        Map<Id, Opportunity> opptiesWithTerminalStatusMap = new Map<Id, Opportunity>([
            SELECT Name, OwnerId, StageName, CreatedDate,
                   (SELECT Field, CreatedDate, NewValue
                   	FROM Histories 
                   	WHERE Field = 'StageName' AND
       					  CreatedDate >= :this.startDateOfPeriod AND CreatedDate <= :this.endDateOfPeriod.addDays(1)
           		  	ORDER BY CreatedDate DESC
           		  	LIMIT 1)
            FROM Opportunity
            WHERE OwnerId = :this.currentUser.Id AND 
        	      (StageName = 'Closed Won' OR
                 StageName = 'Closed Lost' OR 
                 StageName = 'CreditCheck abgelehnt')
            LIMIT 50000
        ]);

        for (Opportunity opp : opptiesWithTerminalStatusMap.values()) {
    		if (! opp.Histories.isEmpty()) {
    			validOpptiesMap.put(opp.Id, opp);
    		}  
        }
        this.numberOppties = validOpptiesMap.size();
        
		Map<Id, Lead> validLeadsMap = new Map<Id, Lead>([
        	SELECT Name, OwnerId, Status, CreatedDate
		   	FROM Lead
		   	WHERE OwnerId = :this.currentUser.Id AND
   				  IsConverted = false AND
   				  Status != 'Disqualified'
		  	LIMIT 50000
    	]);

		Map<Id, Lead> leadsWithTerminalStatusMap = new Map<Id, Lead>([
        	SELECT Name, OwnerId, Status, CreatedDate,
				   (SELECT Field, CreatedDate, NewValue
                   	FROM Histories 
                   	WHERE Field = 'Status' AND
       					  CreatedDate >= :this.startDateOfPeriod AND CreatedDate <= :this.endDateOfPeriod.addDays(1)
           		  	ORDER BY CreatedDate DESC
           		  	LIMIT 1)
		   	FROM Lead
		   	WHERE OwnerId = :this.currentUser.Id AND
   				  IsConverted = false AND
   				  Status = 'Disqualified'
		  	LIMIT 50000
    	]);

        for (Lead ld : leadsWithTerminalStatusMap.values()) {
        	if (! ld.Histories.isEmpty()) {
        		validLeadsMap.put(ld.Id, ld);
        	} 
        }
        this.numberLeads = validLeadsMap.size();

        this.validTasksMap = new Map<Id, Task>([
        	SELECT Id, LastModifiedDate, WhatId, WhoId
		   	  FROM Task
       		WHERE CreatedDate >= :this.startDateOfPeriod AND CreatedDate <= :this.endDateOfPeriod AND
		          OwnerId = :this.currentUser.Id AND
	         	  IsClosed = TRUE
           	LIMIT 50000
       	]);
       	this.numberTasks = this.validTasksMap.size();

       	Map<String, Task> lastActiveTaskMap = new Map<String, Task>();
       	for (Task t : this.validTasksMap.values()) {
            if (t.WhatId != null) {
         		if (! lastActiveTaskMap.containsKey(t.WhatId)) {
         			lastActiveTaskMap.put(t.WhatId, t);
         		} else if (t.LastModifiedDate > lastActiveTaskMap.get(t.WhatId).LastModifiedDate) {
         			lastActiveTaskMap.put(t.WhatId, t);
         		}
          }
            if (t.WhoId != null) {
                if (! lastActiveTaskMap.containsKey(t.WhoId)) {
                  lastActiveTaskMap.put(t.WhoId, t);
                } else if (t.LastModifiedDate > lastActiveTaskMap.get(t.WhoId).LastModifiedDate) {
                  lastActiveTaskMap.put(t.WhoId, t);
                }
            }
       	}

       	this.finalObjectStatisticMap = new Map<String, ObjectStatistics>(); 
       	for (Opportunity opp : validOpptiesMap.values()) {
       		if (lastActiveTaskMap.containsKey(opp.Id)) {
       			ObjectStatistics objStat = new ObjectStatistics();
       			objStat.objectType = 'Opportunity';
       			objStat.objectId = opp.Id;
       			objStat.objectName = opp.Name;
                objStat.objectStatus = opp.StageName;
       			objStat.createdDate = String.valueOf(opp.CreatedDate);
                if (opp.StageName != 'Closed Won' && opp.StageName != 'Closed Lost' && opp.StageName != 'CreditCheck abgelehnt') {
                    objStat.daysSinceCreation = String.valueOf(opp.CreatedDate.Date().daysBetween(Datetime.now().Date()));
                    objStat.daysSinceLastActivity = String.valueOf(lastActiveTaskMap.get(opp.Id).LastModifiedDate.Date().daysBetween(Datetime.now().Date()));
                } else {
                    objStat.daysSinceCreation = String.valueOf(opp.CreatedDate.Date().daysBetween(opp.Histories.get(0).CreatedDate.Date()));
                    objStat.daysSinceLastActivity = String.valueOf(lastActiveTaskMap.get(opp.Id).LastModifiedDate.Date().daysBetween(opp.Histories.get(0).CreatedDate.Date()));
                } 	
       			this.finalObjectStatisticMap.put(opp.Id, objStat);
       		} else {
       			ObjectStatistics objStat = new ObjectStatistics();
       			objStat.objectType = 'Opportunity';
       			objStat.objectId = opp.Id;
       			objStat.objectName = opp.Name;
                objStat.objectStatus = opp.StageName;
       			objStat.createdDate = String.valueOf(opp.CreatedDate);
                if (opp.StageName != 'Closed Won' && opp.StageName != 'Closed Lost' && opp.StageName != 'CreditCheck abgelehnt') {
                    objStat.daysSinceCreation = String.valueOf(opp.CreatedDate.Date().daysBetween(Datetime.now().Date()));
                    objStat.daysSinceLastActivity = 'No tasks';
                } else {
                    objStat.daysSinceCreation = String.valueOf(opp.CreatedDate.Date().daysBetween(opp.Histories.get(0).CreatedDate.Date()));
                    objStat.daysSinceLastActivity = 'No tasks'; 
                }	
       			this.finalObjectStatisticMap.put(opp.Id, objStat);
       		}
       	}
 
       	for (Lead lead : validLeadsMap.values()) {
       		if (lastActiveTaskMap.containsKey(lead.Id)) {
       			ObjectStatistics objStat = new ObjectStatistics();
       			objStat.objectType = 'Lead';
       			objStat.objectId = lead.Id;
       			objStat.objectName = lead.Name;
                objStat.objectStatus = lead.Status;
       			objStat.createdDate = String.valueOf(lead.CreatedDate);
                if (lead.Status != 'Disqualified') {
                    objStat.daysSinceCreation = String.valueOf(lead.CreatedDate.Date().daysBetween(Datetime.now().Date()));
                    objStat.daysSinceLastActivity = String.valueOf(lastActiveTaskMap.get(lead.Id).LastModifiedDate.Date().daysBetween(Datetime.now().Date()));
                } else {
                    objStat.daysSinceCreation = String.valueOf(lead.CreatedDate.Date().daysBetween(lead.Histories.get(0).CreatedDate.Date()));
                    objStat.daysSinceLastActivity = String.valueOf(lastActiveTaskMap.get(lead.Id).LastModifiedDate.Date().daysBetween(lead.Histories.get(0).CreatedDate.Date()));
                }     			
       			this.finalObjectStatisticMap.put(lead.Id, objStat);
       		} else {
       			ObjectStatistics objStat = new ObjectStatistics();
       			objStat.objectType = 'Lead';
       			objStat.objectId = lead.Id;
       			objStat.objectName = lead.Name;
                objStat.objectStatus = lead.Status;
       			objStat.createdDate = String.valueOf(lead.CreatedDate);
                if (lead.Status != 'Disqualified') {
           			objStat.daysSinceCreation = String.valueOf(lead.CreatedDate.Date().daysBetween(Datetime.now().Date()));
           			objStat.daysSinceLastActivity = 'No tasks';
                } else {
                    objStat.daysSinceCreation = String.valueOf(lead.CreatedDate.Date().daysBetween(lead.Histories.get(0).CreatedDate.Date()));
                    objStat.daysSinceLastActivity = 'No tasks';
                }
       			this.finalObjectStatisticMap.put(lead.Id, objStat);
       		}
       	}
 	}

 	public class ObjectStatistics {
 		public String objectType {get; set;}
        public String objectId {get; set;}
        public String objectName {get; set;}
        public String objectStatus {get; set;}
        public String createdDate {get; set;}
        public String daysSinceCreation {get; set;}
        public String daysSinceLastActivity {get; set;}
    }


    /*******************************************************************************
    *  Name            : generateDataForCharts()
    *  Summary         : generating of the values of the selected period   
    *  CreatedDate     : 13/07/2017
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
            Id selectedId = this.selectedPeriod;           
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
                Fleetcor_Calendar_Month__c currentMonth = [
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
    *  CreatedDate     : 13/07/2017
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
    *  CreatedDate     : 13/07/2017
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
    *  Name            : changeYear()
    *  Summary         : Setting the period depending on the selected year    
    *  CreatedDate     : 13/07/2017
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
}