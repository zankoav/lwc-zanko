public with sharing class SalesDashboardOverdueTasksCtrl {
    public Map<Id, User> salesTeamMap {get; set;}
    public Map<Id, Integer> overdueTasks {get; set;}
    public String currentMonth {get; set;}
    public String startDateOfMonthString {get; set;}
    public String endDateOfMonthString {get; set;}
    public Map<Id, Integer> userTodirectDebOpps {get; set;}
    public Map<Id, Integer> userToOtherOpps {get; set;}
    public List<FinalUser> salesTeamFinalList {get; set;}
    public List<FinalUser> salesTeamFinalOverdueList {get; set;}
    public User currentUser {get; set;}
    public Date fridayDate {get; set;}
    public String selectedMonth {get; set;}

    //sales
    public Integer allOpps {get; set;}
    public Integer allDirectDebitOpps {get; set;}
    public Integer overdueSalesTasks {get; set;}
    public String selectedYear {get; set;}

    private String userId;

    public SalesDashboardOverdueTasksCtrl() {

    }

    public void init() {
        this.salesTeamMap = new Map<Id, User>();
        this.overdueTasks = new Map<Id, Integer>();
        this.userTodirectDebOpps = new Map<Id, Integer>();
        this.userToOtherOpps = new Map<Id, Integer>();
        this.salesTeamFinalList = new List<FinalUser>();
        this.salesTeamFinalOverdueList = new List<FinalUser>();
        this.currentUser = new User();
        if (this.selectedYear == null) {
            this.selectedYear = returnCurrentYear();
        }
    	generateDataForChart();
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


    /*
        Method: generateDataForChart
        Description: Get todays Overdue Tasks from the team
        Author: Eugene Vabishchevich
    */
    public void generateDataForChart() {
        Date todayDate = Date.today();
        fridayDate = todayDate.toStartOfWeek().addDays(4);
        String year = String.valueOf(todayDate.year());
        if (selectedMonth != null) {
            currentMonth = monthsMap.get(Integer.valueOf(selectedMonth));
        } else {
            currentMonth = [SELECT Name FROM Fleetcor_Calendar_Month__c WHERE Fleetcor_Calendar_Year__r.Name = :this.selectedYear AND Start_Date__c <= TODAY AND End_Date__c >= TODAY LIMIT 1].Name;
            selectedMonth = String.valueOf(monthsMapRev.get(currentMonth));
        }
        Date startDateOfMonth = [SELECT Start_Date__c FROM Fleetcor_Calendar_Month__c WHERE Fleetcor_Calendar_Year__r.Name = :this.selectedYear AND Name = :currentMonth].Start_Date__c;
        Date endDateOfMonth = [SELECT End_Date__c FROM Fleetcor_Calendar_Month__c WHERE Fleetcor_Calendar_Year__r.Name = :this.selectedYear AND Name = :currentMonth].End_Date__c;
        startDateOfMonthString = String.valueOf(startDateOfMonth.day()) + ' ' + monthsMap.get(startDateOfMonth.month());
        endDateOfMonthString = String.valueOf(endDateOfMonth.day()) + ' ' + monthsMap.get(endDateOfMonth.month());

        returnUserId();
        currentUser = [
                SELECT UserRole.Name, Profile.Name, Name, UserRoleId
                FROM User
                WHERE Id = :userId];

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

                //Overdue tasks
                List<Task> tasksList = [
                		SELECT OwnerId
                		FROM Task
                		WHERE CreatedDate >= :startDateOfMonth AND CreatedDate <= :endDateOfMonth AND 
                			  OwnerId IN :salesTeamMap.keySet() AND ActivityDate < TODAY AND Status != 'Completed' AND Status != 'Geschlossen'
                		LIMIT 30000];

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

	                overdueTasks.put(uid, userTotasksMap.get(uid).size());
                }

                for (Id uid : salesTeamMap.keySet()) {
                    salesTeamFinalOverdueList.add(new FinalUser(
                        salesTeamMap.get(uid).Name,
                        salesTeamMap.get(uid).id,
                        overdueTasks.get(uid)));
                }

                salesTeamFinalOverdueList.sort();

                //credit debit transfer Opps
                List<Opportunity> directDebitOppsList = [
                        SELECT Anzahl_der_Karten__c, Name, OwnerId
                        FROM Opportunity
                        WHERE OwnerId IN :salesTeamMap.keySet() AND StageName = 'Closed Won' AND 
                              CloseDate >= :startDateOfMonth AND CloseDate <= :endDateOfMonth AND
                              Zahlungsart__c = 'Lastschrift'
                        LIMIT 10000];

                //Without method of payment
                List<Opportunity> otherOppsList = [
                        SELECT Anzahl_der_Karten__c, Name, OwnerId
                        FROM Opportunity
                        WHERE OwnerId IN :salesTeamMap.keySet() AND StageName = 'Closed Won' AND 
                              CloseDate >= :startDateOfMonth AND CloseDate <= :endDateOfMonth
                        LIMIT 10000];


                for (Opportunity opp : directDebitOppsList) {
                	if ( ! userTodirectDebOpps.containsKey(opp.OwnerId)) {
                		userTodirectDebOpps.put(opp.OwnerId, 0);
                	}

                	Integer i = userTodirectDebOpps.get(opp.OwnerId) + 1;
                	userTodirectDebOpps.put(opp.OwnerId, i);
                }

                for (Opportunity opp : otherOppsList) {
                	if ( ! userToOtherOpps.containsKey(opp.OwnerId)) {
                		userToOtherOpps.put(opp.OwnerId, 0);
                	}

                	Integer i = userToOtherOpps.get(opp.OwnerId) + 1;
                	userToOtherOpps.put(opp.OwnerId, i);
                }

                for (Id uid : salesTeamMap.keySet()) {
                	if ( ! userTodirectDebOpps.containsKey(uid)) {
                		userTodirectDebOpps.put(uid, 0);
                	}

                	if ( ! userToOtherOpps.containsKey(uid)) {
                		userToOtherOpps.put(uid, 0);
                	}
                }

                for (Id uid : salesTeamMap.keySet()) {
                    salesTeamFinalList.add(new FinalUser(
                        salesTeamMap.get(uid).Name,
                        salesTeamMap.get(uid).id,
                        userTodirectDebOpps.get(uid)));
                }

                salesTeamFinalList.sort();

            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'You don\'t have valid User Role. Please contact your administrator.'));     
            }
        } else if (currentUser.Profile.Name == 'Sales' || currentUser.Profile.Name == 'Sales Inbound' || currentUser.Profile.Name == 'Harte Hanke (Sales)') {
            //credit debit transfer Opps
            allDirectDebitOpps = [
                    SELECT COUNT()
                    FROM Opportunity
                    WHERE OwnerId = :currentUser.Id AND StageName = 'Closed Won' AND 
                          CloseDate >= :startDateOfMonth AND CloseDate <= :endDateOfMonth AND
                          Zahlungsart__c = 'Lastschrift'
                    LIMIT 10000];

            //Without method of payment
            allOpps = [
                    SELECT COUNT()
                    FROM Opportunity
                    WHERE OwnerId = :currentUser.Id AND StageName = 'Closed Won' AND 
                          CloseDate >= :startDateOfMonth AND CloseDate <= :endDateOfMonth
                    LIMIT 10000];

            //Overdue tasks
            overdueSalesTasks = [
                    SELECT COUNT()
                    FROM Task
                    WHERE CreatedDate >= :startDateOfMonth AND CreatedDate <= :endDateOfMonth AND 
                          OwnerId = :currentUser.Id AND ActivityDate < TODAY AND Status != 'Completed' AND Status != 'Geschlossen'
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
        public Integer compareValue {get; set;}

        public finalUser(String name, String id, Integer compareValue) {
            this.name = name;
            this.id = id;
            this.compareValue = compareValue;
        }

        public Integer compareTo(Object compareTo) {
            FinalUser compareToU = (FinalUser)compareTo;
            if (compareValue == compareToU.compareValue) return 0;
            if (compareValue < compareToU.compareValue) return 1;
            return -1;        
        }
    }

}