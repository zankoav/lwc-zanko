public with sharing class SalesDashboardKamPlanCtrl {
	public User currentUser {get; set;}
    public Map<Id, User> salesTeamMap {get; set;}
    public String startDateOfMonthString {get; set;}
    public String endDateOfMonthString {get; set;}
    public String selectedMonth {get; set;}
    public String currentMonth {get; set;}
    public String selectedYear {get; set;}
    public Integer numberAllTask {get; set;}
    public Decimal numberAllMeetingsPlan {get; set;}
    public Map<Id, Integer> usersWithMeetingsFinal {get; set;}  
    public Map<Id, Decimal> usersWithMeetingsPlanMap {get; set;}
    public List<FinalList> finalList {get; set;}
    private Date startDateOfMonth;
    private Date endDateOfMonth;

    public void init () {
        this.salesTeamMap = new Map<Id, User>();
        if (this.selectedYear == null) {
            this.selectedYear = returnCurrentYear();
        }
    	generateStartEndDateMonth ();
    	generateAllTaskForUser ();
    }


    /*******************************************************************************
    *  Name            : generateAllTaskForUser ()
    *  Summary         : getting all data for dashboard: plan for user and existing completed tasks for him    
    *  CreatedDate     : 23.12.2016
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void generateAllTaskForUser () {
    	String userId = UserInfo.getUserId();
    	currentUser = [
	            SELECT UserRole.Name, Profile.Name, Name, UserRoleId
	            FROM User
	            WHERE Id = :userId
	            LIMIT 1];

		if (currentUser.Profile.Name == 'Key Account Manager') {

            List<KAM_Plan__c> planForCurrentUserList = [
                SELECT Id, Name, Meetings_Plan__c, KAM__c
                FROM KAM_Plan__c
                WHERE KAM__c = :currentUser.Id
                LIMIT 1];

            Set<Id> usersIdWithPlanSet = new Set<Id>();

            for (KAM_Plan__c kamPlan : planForCurrentUserList){
                    usersIdWithPlanSet.add(kamPlan.KAM__c);
                    numberAllMeetingsPlan = kamPlan.Meetings_Plan__c;
            }

            if (planForCurrentUserList.size() == 0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'No plan meetings for the user'));
            }
        
			List<Task> allTaskForUser =	[
				SELECT Id, Subject, ActivityDate
				FROM Task 
				WHERE Subject = 'Meeting' AND 
                    Status = 'Completed' AND
                    OwnerId = :usersIdWithPlanSet AND
                    CreatedDate >= :startDateOfMonth AND
                    CreatedDate <= :endDateOfMonth AND
					WhatId IN (SELECT Id FROM Account WHERE RecordType.Name = 'Retailer' AND KAM__c = :currentUser.Id)];

			numberAllTask = allTaskForUser.size();

		} else if (currentUser.Profile.Name == 'Sales Director' || currentUser.Profile.Name == 'System Administrator') {
            salesTeamMap = new Map<Id, User>([
                SELECT Name, Profile.Name
                FROM User
                WHERE Profile.Name = 'Key Account Manager' AND isActive = TRUE
                LIMIT 10000]);

            List<KAM_Plan__c> planForSalesTeamList = [
                SELECT Id, Name, Meetings_Plan__c, KAM__c
                FROM KAM_Plan__c
                WHERE KAM__c IN :salesTeamMap.keySet()
                LIMIT 1000];

            usersWithMeetingsPlanMap = new Map<Id, Decimal>();
            for (KAM_Plan__c kamPlan : planForSalesTeamList){
                if (salesTeamMap.containsKey( kamPlan.KAM__c )) {
                    usersWithMeetingsPlanMap.put( kamPlan.KAM__c, kamPlan.Meetings_Plan__c );
                }
            }

            Map<Id, Account> allAccountsKAM = new Map<Id, Account>([
                SELECT Id, KAM__c 
                FROM Account 
                WHERE RecordType.Name = 'Retailer' AND 
                      KAM__c IN :usersWithMeetingsPlanMap.keySet()]);

            List<Task> allMeetingTaskList = [
                SELECT Id, OwnerId, Subject, ActivityDate, WhatId
                FROM Task 
                WHERE Subject = 'Meeting' AND 
                    Status = 'Completed' AND
                    OwnerId IN :usersWithMeetingsPlanMap.keySet() AND
                    CreatedDate >= :startDateOfMonth AND
                    CreatedDate <= :endDateOfMonth];

            Map<Id, List<Task>> allTaskForDirectorMap = new Map<Id, List<Task>>();
            for (Task t : allMeetingTaskList) {
                if (allAccountsKAM.containsKey(t.WhatId) && t.OwnerId == allAccountsKAM.get(t.WhatId).KAM__c) {
                    if (! allTaskForDirectorMap.containsKey(t.WhatId)) {
                        allTaskForDirectorMap.put(t.WhatId, new List<Task>());
                    }
                    allTaskForDirectorMap.get(t.WhatId).add(t);
                }                
            }

            List<Task> finalMeetingTaskList = new List<Task>();
            for (Id idAcc : allTaskForDirectorMap.keySet()){
                for (Task tsk : allTaskForDirectorMap.get(idAcc)){
                    finalMeetingTaskList.add(tsk);
                }
            }

            Map<Id, List<Task>> usersWithTasksMap = new Map<Id, List<Task>>();
            for (Task task : finalMeetingTaskList) {
                if (! usersWithTasksMap.containsKey(task.OwnerId)) {
                    usersWithTasksMap.put(task.OwnerId, new List<Task>());
                }
                usersWithTasksMap.get(task.OwnerId).add(task);
            }

            //FINAL
            for (Id uid : usersWithMeetingsPlanMap.keySet()) {
                if ( ! usersWithTasksMap.containsKey(uid)) {
                    usersWithTasksMap.put(uid, new List<Task>());
                }
            }

            finalList = new List<FinalList>();
            usersWithMeetingsFinal = new Map<Id, Integer>();
            for (String uid : usersWithTasksMap.keySet()) {
                    finalList.add(new FinalList(
                        uid,
                        usersWithTasksMap.get(uid).size()));

                usersWithMeetingsFinal.put(uid, usersWithTasksMap.get(uid).size());
            }
            finalList.sort();

            if (finalList.size() == 0) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'No plan meetings for members'));
            } 
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Invalid User Profile'));
        }
    }


    /*******************************************************************************
    *  Name            : returnCurrentYear()
    *  Summary         : Returns current year based on Fleetcor Calendar (custom objects)     
    *  CreatedDate     : 26/12/2016
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
    *  Name            : generateStartEndDateMonth ()
    *  Summary         : getting start date and end date of the selected month 
    *  CreatedDate     : 23.12.2016
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void generateStartEndDateMonth () {
        if (selectedMonth != null && selectedMonth != 'None') {
            currentMonth = monthsMap.get(Integer.valueOf(selectedMonth));
        } else {
            currentMonth = [
                    SELECT Name 
                    FROM Fleetcor_Calendar_Month__c 
                    WHERE Fleetcor_Calendar_Year__r.Name = :this.selectedYear AND
                        Start_Date__c <= TODAY AND
                        End_Date__c >= TODAY LIMIT 1].Name;

            selectedMonth = String.valueOf(monthsMapRev.get(currentMonth));
        }

        startDateOfMonth = [
                SELECT Start_Date__c 
                FROM Fleetcor_Calendar_Month__c 
                WHERE Fleetcor_Calendar_Year__r.Name = :this.selectedYear AND
                    Name = :currentMonth LIMIT 1].Start_Date__c;

        endDateOfMonth = [
                SELECT End_Date__c 
                FROM Fleetcor_Calendar_Month__c 
                WHERE Fleetcor_Calendar_Year__r.Name = :this.selectedYear AND
                    Name = :currentMonth LIMIT 1].End_Date__c;

        startDateOfMonthString = String.valueOf(startDateOfMonth.day()) + ' ' + monthsMap.get(startDateOfMonth.month());
        endDateOfMonthString = String.valueOf(endDateOfMonth.day()) + ' ' + monthsMap.get(endDateOfMonth.month());
    }


    /*******************************************************************************
    *  Name            : getYears()
    *  Summary         : Display years in selectbox     
    *  CreatedDate     : 26/12/2016
    *  Parameters      : 
    *  Returns         : List<SelectOption>
    ******************************************************************************/
    public List<SelectOption> getYears() {
        List<SelectOption> options = new List<SelectOption>();
        List<Fleetcor_Calendar_Year__c> yearsList = [
                SELECT Name 
                FROM Fleetcor_Calendar_Year__c ORDER BY Name DESC LIMIT 1000]; 
        for (Fleetcor_Calendar_Year__c fcy : yearsList) {
            options.add(new SelectOption(fcy.Name, fcy.Name));
        }

        return options;
    }


    /*******************************************************************************
    *  Name            : getCurrentMonthsList ()
    *  Summary         : creating picklist with month values     
    *  CreatedDate     : 23.12.2016
    *  Parameters      : -
    *  Returns         : month options
    ******************************************************************************/
    public List<SelectOption> getCurrentMonths() {
        List<Fleetcor_Calendar_Month__c> currentMonthTemp = [
                SELECT Name, Month_Number__c
                FROM Fleetcor_Calendar_Month__c
                WHERE Fleetcor_Calendar_Year__r.Name = :this.selectedYear AND 
                      Start_Date__c <= TODAY AND 
                      End_Date__c >= TODAY
                LIMIT 1];

        List<SelectOption> options = new List<SelectOption>();
        if ( ! currentMonthTemp.isEmpty() ) {
            for (Integer i = 1; i <= currentMonthTemp.get(0).Month_Number__c; i++) {
                options.add(new SelectOption(String.valueOf(i), monthsMap.get(i)));
            }
        } else {
            for (Integer i = 1; i <= 12; i++) {
                options.add(new SelectOption(String.valueOf(i), monthsMap.get(i)));
            }      
        }
        return options;
    }


    public void changeYear() {
        List<Fleetcor_Calendar_Month__c> currentFLTmonth = [
            SELECT Month_Number__c, Fleetcor_Calendar_Year__r.Name
            FROM Fleetcor_Calendar_Month__c
            WHERE Start_Date__c <= TODAY AND 
                  End_Date__c >= TODAY
            LIMIT 1];

        Decimal currentMonthNumber;
        String currentFLTyear;
        if (! currentFLTmonth.isEmpty()) {
            currentMonthNumber = currentFLTmonth.get(0).Month_Number__c;
            currentFLTyear = currentFLTmonth.get(0).Fleetcor_Calendar_Year__r.Name;
        }

        if (this.selectedYear != currentFLTyear) {
            selectedMonth = '1';
        } else {
            selectedMonth = String.valueOf(currentMonthNumber);
        }
        init();       
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
            if (compareValue < compareToU.compareValue) return 1;
            return -1;        
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


    private Map<String, Integer> monthsMapRev = new Map<String, Integer>{
        'January' => 1, 
        'February' => 2, 
        'March' => 3,
        'April' => 4,
        'May' => 5,
        'June' => 6,
        'July' => 7,
        'August' => 8,
        'September' => 9,
        'October' => 10,
        'November' => 11,
        'December' => 12};
}