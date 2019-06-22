public with sharing class SalesDashboardTodaysTasksCtrl {
    public Map<Id, User> salesTeamMap {get; set;}
    public Map<Id, Integer> todaysTasks {get; set;}
    public String currentMonth {get; set;}
    public String startDateOfMonthString {get; set;}
    public String endDateOfMonthString {get; set;}
    public Integer monthTasksPlan {get; set;}
    public List<FinalUser> salesTeamFinalList {get; set;}
    public User currentUser {get; set;}
    public Integer todaysSalesTasks {get; set;}
    public Integer salesCurrentTasks {get; set;}
    public Map<String, Integer> todaysSalesMap {get; set;}
    public String selectedMonth {get; set;}

    //pie chart
    public Integer salesLess50 {get; set;}
    public Integer sales5080 {get; set;}
    public Integer sales80100 {get; set;}
    public Integer salesMore100 {get; set;}
    public String selectedYear {get; set;}

    private String userId;

    public SalesDashboardTodaysTasksCtrl() {

    }

    public void init() {
        this.salesTeamMap = new Map<Id, User>();
        this.todaysTasks = new Map<Id, Integer>();
        this.salesTeamFinalList = new List<FinalUser>();
        this.todaysSalesMap = new Map<String, Integer>();
        this.currentUser = new User();
        this.salesLess50 = 0;
        this.sales5080 = 0;
        this.sales80100 = 0;
        this.salesMore100 = 0;
        if (this.selectedYear == null) {
            this.selectedYear = returnCurrentYear();
        }
    	generateDataForChart();
    }

    /*
        Method: generateDataForChart
        Description: Get todays Tasks from the team
        Author: Eugene Vabishchevich
    */


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


    public void generateDataForChart() {
        returnUserId();
        currentUser = [
                SELECT UserRole.Name, Profile.Name, Name, UserRoleId
                FROM User
                WHERE Id = :userId];

        if (selectedMonth != null) {
            currentMonth = monthsMap.get(Integer.valueOf(selectedMonth));
        } else {
            currentMonth = [SELECT Name FROM Fleetcor_Calendar_Month__c WHERE Fleetcor_Calendar_Year__r.Name = :this.selectedYear AND Start_Date__c <= TODAY AND End_Date__c >= TODAY LIMIT 1].Name;
            selectedMonth = String.valueOf(monthsMapRev.get(currentMonth));
        }
        Date startDateOfMonth = [SELECT Start_Date__c FROM Fleetcor_Calendar_Month__c WHERE Fleetcor_Calendar_Year__r.Name = :this.selectedYear AND Name = :currentMonth LIMIT 1].Start_Date__c;
        Date endDateOfMonth = [SELECT End_Date__c FROM Fleetcor_Calendar_Month__c WHERE Fleetcor_Calendar_Year__r.Name = :this.selectedYear AND Name = :currentMonth LIMIT 1].End_Date__c;
        
        Integer bussinesDays = returnBusinessDays(datetime.newInstance(startDateOfMonth.year(), startDateOfMonth.month(),startDateOfMonth.day()),datetime.newInstance(endDateOfMonth.year(), endDateOfMonth.month(),endDateOfMonth.day()));
        
        monthTasksPlan = 70 * bussinesDays;
        startDateOfMonthString = String.valueOf(startDateOfMonth.day()) + ' ' + monthsMap.get(startDateOfMonth.month());
        endDateOfMonthString = String.valueOf(endDateOfMonth.day()) + ' ' + monthsMap.get(endDateOfMonth.month());

		if (currentUser.Profile.Name == 'Salesteamleiter' || currentUser.Profile.Name == 'Harte Hank Teamleiter') {
            //team leader
            if (currentUser.UserRole.Name != null && currentUser.UserRole.Name.contains('Teamleiter')) {
                // String leadRole = currentUser.UserRole.Name;
                // String salesTeamRole = leadRole.replace('Teamleiter', 'Salesteam');
                Map<Id, UserRole> salesRolesMap = new Map<Id, UserRole>([
                        SELECT Id
                        FROM UserRole
                        WHERE ParentRoleId = :currentUser.UserRoleId
                        LIMIT 1000]);

                salesTeamMap = new Map<Id, User>([
                        SELECT Name
                        FROM User
                        WHERE UserRoleId IN :salesRolesMap.keySet() AND isActive = TRUE
                        LIMIT 10000]);

                List<Task> tasksList = [
                		SELECT OwnerId, Owner.Name
                		FROM Task
                		WHERE CreatedDate >= :startDateOfMonth AND CreatedDate <= :endDateOfMonth AND OwnerId IN :salesTeamMap.keySet()
                		LIMIT 30000];

                List<Task> tasksTodaysList = [
                        SELECT OwnerId, Owner.Name
                        FROM Task
                        WHERE CreatedDate = TODAY AND OwnerId IN :salesTeamMap.keySet()
                        LIMIT 30000];

                for (Task t : tasksTodaysList) {
                    if ( ! todaysSalesMap.containsKey(t.Owner.Name) ) {
                        todaysSalesMap.put(t.Owner.Name, 0);
                    }

                    Integer i = todaysSalesMap.get(t.Owner.Name) + 1;
                    todaysSalesMap.put(t.Owner.Name, i);
                }


                Map<Id, List<Task>> userTotasksMap = new Map<Id, List<Task>>();

                for (Task t : tasksList) {
                	if ( ! userTotasksMap.containsKey(t.OwnerId)) {
                		userTotasksMap.put(t.OwnerId, new List<Task>());
                	}

                	userTotasksMap.get(t.OwnerId).add(t);
                }

                for (Id uid : salesTeamMap.keySet()) {
                	if ( ! userTotasksMap.containsKey(uid) ) {
                		userTotasksMap.put(uid, new List<Task>());
                	}
                    if ( ! todaysSalesMap.containsKey(salesTeamMap.get(uid).Name) ) {
                        todaysSalesMap.put(salesTeamMap.get(uid).Name, 0);
                    }

	                todaysTasks.put(uid, userTotasksMap.get(uid).size());
                }
                
                for (Id uid : salesTeamMap.keySet()) {
                    salesTeamFinalList.add(new FinalUser(
                        salesTeamMap.get(uid).Name,
                        salesTeamMap.get(uid).id,
                        todaysTasks.get(uid)));
                }

                salesTeamFinalList.sort();

                //pie
                for (String key : salesTeamMap.keySet()) {
                    if (monthTasksPlan != 0) {
                        Decimal daysPassed = returnDaysPassed(datetime.newInstance(startDateOfMonth.year(), startDateOfMonth.month(),startDateOfMonth.day()), Datetime.now(),
                                                                                   datetime.newInstance(endDateOfMonth.year(), endDateOfMonth.month(),endDateOfMonth.day()), bussinesDays);

                        Decimal currentValueTemp = 0;
                        if (daysPassed != 0) {
                            currentValueTemp = ((Decimal.valueOf(todaysTasks.get(key)) * bussinesDays) / daysPassed) / Decimal.valueOf(monthTasksPlan);
                        }
                        if (currentValueTemp <= 0.5) {
                            salesLess50++;
                        } else if (currentValueTemp > 0.5 && 
                                   currentValueTemp <= 0.8) {
                            sales5080++;
                        } else if (currentValueTemp > 0.5 &&
                                   currentValueTemp <= 1) {
                            sales80100++;
                        } else if (currentValueTemp > 1) {
                            salesMore100++;
                        }
                    }
                }

            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'You don\'t have valid User Role. Please contact your administrator.'));     
            }
        } else if ((currentUser.Profile.Name == 'Sales' || currentUser.Profile.Name == 'Sales Inbound' || currentUser.Profile.Name == 'Harte Hanke (Sales)')) {
            salesCurrentTasks = [
                    SELECT COUNT()
                    FROM Task
                    WHERE CreatedDate >= :startDateOfMonth AND CreatedDate <= :endDateOfMonth 
                          AND OwnerId = :currentUser.Id
                    LIMIT 30000];

            todaysSalesTasks = [
                    SELECT COUNT()
                    FROM Task
                    WHERE CreatedDate = TODAY 
                          AND OwnerId = :currentUser.Id
                    LIMIT 30000];
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Invalid profile. Please contact your administrator.'));
        }
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
        List<Fleetcor_Calendar_Year__c> yearsList = [SELECT Name FROM Fleetcor_Calendar_Year__c ORDER BY Name DESC LIMIT 1000]; 
        for (Fleetcor_Calendar_Year__c fcy : yearsList) {
            options.add(new SelectOption(fcy.Name, fcy.Name));
        }

        return options;
    }
    

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
    

    public Integer returnBusinessDays(Datetime sdate, Datetime edate) {
        Integer iCount = 0;
        while (sdate < edate) {
            if (sdate.format('E') != 'Sat' && sdate.format('E') != 'Sun') {
                iCount = iCount + 1;
            }
            sdate = sdate.addDays(1);
        }
        system.debug('=== ' + iCount);
        return iCount;
    }

    public Integer returnDaysPassed(Datetime sdate, Datetime edate, Datetime endDateMonth, Integer bussinesDays) {
        Integer iCount = 0;
        while (sdate < edate) {
            if (sdate.format('E') != 'Sat' && sdate.format('E') != 'Sun' && edate <= endDateMonth) {
                iCount = iCount + 1;
            } else if (edate > endDateMonth) {
                iCount = bussinesDays;
                break;
            }
            sdate = sdate.addDays(1);
        }
        return iCount;
    }

    public void returnUserId() {
        userId = Apexpages.currentPage().getParameters().get('userId');
        if (userId == null) {
            userId = UserInfo.getUserId();
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

    public class FinalUser implements Comparable {
        public String name {get; set;}
        public String id {get; set;}
        public Integer numberOfTasks {get; set;}

        public finalUser(String name, String id, Integer numberOfTasks) {
            this.name = name;
            this.id = id;
            this.numberOfTasks = numberOfTasks;
        }

        public Integer compareTo(Object compareTo) {
            FinalUser compareToU = (FinalUser)compareTo;
            if (numberOfTasks == compareToU.numberOfTasks) return 0;
            if (numberOfTasks < compareToU.numberOfTasks) return 1;
            return -1;        
        }
    }
}