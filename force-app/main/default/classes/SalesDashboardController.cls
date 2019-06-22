public with sharing class SalesDashboardController {
    public String startDateOfMonthString {get; set;}
    public String endDateOfMonthString {get; set;}
    public List<String> messagesList {get; set;}
    public PlanWrapper currentPlan {get; set;}
    public String currentMonth {get; set;}
    public Integer myNumberOfCards {get; set;}
    public Map<Id, Integer> teamOppsMap {get; set;}
    public Map<Id, Integer> teamOppsCardsMap {get; set;}
    public Map<Id, PlanWrapper> teamOppsPlanMap {get; set;}
    public List<FinalList> finalList {get; set;}
    public User currentUser {get; set;}
    public Integer bussinesDays {get; set;}
    public String selectedMonth {get; set;}
    public String selectedYear {get; set;}

    public Decimal todaysOpps {get; set;}
    public Map<String, Decimal> todaysSalesOppsMap {get; set;}

    //pie chart
    public Integer salesLess50 {get; set;}
    public Integer sales5080 {get; set;}
    public Integer sales80100 {get; set;}
    public Integer salesMore100 {get; set;}
    
    public Date startDateOfMonth {get; set;}
    public Date endDateOfMonth {get; set;}
    private static Date todayDate;
    private static String year;
    private String userId;

    public SalesDashboardController() {

    }

    /*
        Description: Initial generation data for charts and get current plan
        Author: Eugene Vabishchevich
    */

    public void init() {
        this.messagesList = new List<String>();
        this.currentPlan = new PlanWrapper('',0,0,'');
        this.teamOppsMap = new Map<Id, Integer>();
        this.teamOppsCardsMap = new Map<Id, Integer>();
        this.teamOppsPlanMap = new Map<Id, PlanWrapper>();
        this.finalList = new List<FinalList>();
        this.todaysSalesOppsMap = new Map<String, Decimal>();
        this.salesLess50 = 0;
        this.sales5080 = 0;
        this.sales80100 = 0;
        this.salesMore100 = 0;
        if (this.selectedYear == null) {
            this.selectedYear = returnCurrentYear();
        }
        generateDataForCharts();
        currentPlan();
    }

    /*
        Method: Get PLAN record or display error message
        Description: Generate data for charts and get current plan + get my current Closed Won Opportunities
        Author: Eugene Vabishchevich
    */
    public void currentPlan() {
        returnUserId();
        currentUser = [
                SELECT UserRole.Name, Profile.Name, Name
                FROM User
                WHERE Id = :userId];

        if (currentUser.Profile.Name == 'Sales' || currentUser.Profile.Name == 'Sales Inbound' || currentUser.Profile.Name == 'Harte Hanke (Sales)' || 
            currentUser.Profile.Name == 'CCS Sales Inbound' || currentUser.Profile.Name == 'AllStar Sales') {
            //sales
            if (currentUser.UserRole != null) {
                List<Sales_Plan__c> planList = [
                        SELECT Fleetcor_Calendar_Month__r.Name, Number_of_cards_Default__c, User__c, Year__c,
                               User__r.Name, Fleetcor_Calendar_Month__r.Number_of_weeks__c, User__r.UserRole.Name,
                               User__r.UserRoleId
                        FROM Sales_Plan__c
                        WHERE Year__c = :this.selectedYear AND
                              Fleetcor_Calendar_Month__r.Name = :currentMonth AND
                              User__c = :currentUser.Id
                        LIMIT 1];

                todaysOpps = 0;
                List<Opportunity> todaysOppsList = [
                        SELECT Anzahl_der_Karten__c
                        FROM Opportunity
                        WHERE OwnerId = :currentUser.Id AND StageName = 'Closed Won' AND 
                              CloseDate = TODAY
                        LIMIT 10000];
                for (Opportunity o : todaysOppsList) {
                    todaysOpps = todaysOpps + o.Anzahl_der_Karten__c;
                }


                List<Opportunity> myOpps = [
                        SELECT Anzahl_der_Karten__c
                        FROM Opportunity
                        WHERE OwnerId = :currentUser.Id AND StageName = 'Closed Won' AND 
                              CloseDate >= :startDateOfMonth AND CloseDate <= :endDateOfMonth
                        LIMIT 10000];

                
                myNumberOfCards = 0;
                for (Opportunity opp : myOpps) {
                    myNumberOfCards += Integer.valueOf(opp.Anzahl_der_Karten__c);
                }

                if (planList.isEmpty()) {
                    messagesList.add('You don\'t have plan for current month. Please contact your administrator or team lead.');
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, messagesList.get(0)));
                } else if (myNumberOfCards == 0) {
                    currentPlan = new PlanWrapper(
                        planList.get(0).User__r.Name, 
                        planList.get(0).Number_of_cards_Default__c, 
                        planList.get(0).Fleetcor_Calendar_Month__r.Number_of_weeks__c, 
                        planList.get(0).User__r.UserRole.Name);
                    messagesList.add('You don\'t have any ClosedWon Opportunity for current month.');
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, messagesList.get(0)));
                } else {
                    currentPlan = new PlanWrapper(
                        planList.get(0).User__r.Name, 
                        planList.get(0).Number_of_cards_Default__c, 
                        planList.get(0).Fleetcor_Calendar_Month__r.Number_of_weeks__c, 
                        planList.get(0).User__r.UserRole.Name);
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'You don\'t have User Role. Please contact your administrator.'));    
            }
        } else if (currentUser.Profile.Name == 'Salesteamleiter' || currentUser.Profile.Name == 'Harte Hank Teamleiter') {
            //team leader
            if (currentUser.UserRole.Name != null && currentUser.UserRole.Name.contains('Teamleiter')) {
                String leadRole = currentUser.UserRole.Name;
                Map<Id, UserRole> salesRolesMap = new Map<Id, UserRole>([
                        SELECT Id
                        FROM UserRole
                        WHERE ParentRoleId = :currentUser.UserRoleId
                        LIMIT 1000]);
                //String salesTeamRole = leadRole.replace('Teamleiter', 'Salesteam');

                Map<Id, User> salesTeamMap = new Map<Id, User>([
                        SELECT Id
                        FROM User
                        WHERE UserRoleId IN :salesRolesMap.keySet() AND isActive = TRUE
                        LIMIT 10000]);
                system.debug('=== ' + salesTeamMap);

                teamOppsPlanMap = new Map<Id, PlanWrapper>();
                teamOppsMap = new Map<Id, Integer>();

                List<Sales_Plan__c> planList = [
                        SELECT Fleetcor_Calendar_Month__r.Name, Number_of_cards_Default__c, User__c, Year__c,
                               User__r.Name, Fleetcor_Calendar_Month__r.Number_of_weeks__c, User__r.UserRole.Name
                        FROM Sales_Plan__c
                        WHERE Year__c = :this.selectedYear AND
                              Fleetcor_Calendar_Month__r.Name = :currentMonth AND
                              User__c IN :salesTeamMap.keySet()
                        LIMIT 10000];

                for (Sales_Plan__c plan : planList) {
                    if ( ! teamOppsPlanMap.containsKey(plan.User__c) ) {
                        teamOppsPlanMap.put(
                            plan.User__c, 
                            new PlanWrapper(plan.User__r.Name, plan.Number_of_cards_Default__c, plan.Fleetcor_Calendar_Month__r.Number_of_weeks__c, plan.User__r.UserRole.Name));    
                    }

                    if ( ! teamOppsCardsMap.containsKey(plan.User__c) ) {
                        teamOppsCardsMap.put(plan.User__c, 0);
                    }
                }

                List<Opportunity> salesOppsList = [
                        SELECT Anzahl_der_Karten__c, Name, OwnerId, Owner.Name
                        FROM Opportunity
                        WHERE OwnerId IN :teamOppsPlanMap.keySet() AND StageName = 'Closed Won' AND 
                              CloseDate >= :startDateOfMonth AND CloseDate <= :endDateOfMonth
                        LIMIT 10000];

                List<Opportunity> todaysSalesOppsList = [
                        SELECT Anzahl_der_Karten__c, Name, OwnerId, Owner.Name
                        FROM Opportunity
                        WHERE OwnerId IN :teamOppsPlanMap.keySet() AND StageName = 'Closed Won' AND 
                              CloseDate = TODAY
                        LIMIT 10000];

                for (Opportunity o : todaysSalesOppsList) {
                    if ( ! todaysSalesOppsMap.containsKey(o.Owner.Name)) {
                        todaysSalesOppsMap.put(o.Owner.Name, 0);
                    }

                    Decimal i = todaysSalesOppsMap.get(o.Owner.Name) + o.Anzahl_der_Karten__c;
                    todaysSalesOppsMap.put(o.Owner.Name, i);
                }

                for (Opportunity o : salesOppsList) {
                    //Todays
                    if ( ! todaysSalesOppsMap.containsKey(o.Owner.Name)) {
                        todaysSalesOppsMap.put(o.Owner.Name, 0);
                    }

                    //pie
                    if ( ! teamOppsMap.containsKey(o.OwnerId) ) {
                        teamOppsMap.put(o.OwnerId, 0);
                    }

                    Integer i = teamOppsMap.get(o.OwnerId) + 1;
                    teamOppsMap.put(o.OwnerId,i);

                    //Cards
                    if ( ! teamOppsCardsMap.containsKey(o.OwnerId) ) {
                        teamOppsCardsMap.put(o.OwnerId, 0);
                    }

                    Integer j = Integer.valueOf(teamOppsCardsMap.get(o.OwnerId) + o.Anzahl_der_Karten__c);
                    teamOppsCardsMap.put(o.OwnerId, j);
                }

                for (Sales_Plan__c plan : planList) {
                    if ( ! teamOppsMap.containsKey(plan.User__c) ) {
                        teamOppsMap.put(plan.User__c, 0);
                    }

                    if ( ! todaysSalesOppsMap.containsKey(plan.User__r.Name) ) {
                        todaysSalesOppsMap.put(plan.User__r.Name, 0);
                    }
                }

                for (String uid : teamOppsMap.keySet()) {
                    finalList.add(new FinalList(
                        uid,
                        teamOppsCardsMap.get(uid)));
                }

                finalList.sort();

                Boolean isPlanNull = false;

                for (String key : teamOppsPlanMap.keySet()) {
                    if (teamOppsPlanMap.get(key).numberOfCards != 0) {
                        //Decimal currentValueTemp = Decimal.valueOf(teamOppsCardsMap.get(key)) / teamOppsPlanMap.get(key).numberOfCards;
                        
                        Decimal daysPassed = returnDaysPassed(datetime.newInstance(startDateOfMonth.year(), startDateOfMonth.month(),startDateOfMonth.day()), Datetime.now(), 
                                                              datetime.newInstance(endDateOfMonth.year(), endDateOfMonth.month(),endDateOfMonth.day()), bussinesDays);

                        Decimal currentValueTemp = ((Decimal.valueOf(teamOppsCardsMap.get(key)) * bussinesDays) / daysPassed) / teamOppsPlanMap.get(key).numberOfCards;
                        
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
                    } else {
                        isPlanNull = true;
                    }
                }

                if (isPlanNull) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'You have sales users with 0 plan value. Please contact your administrator.'));     
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'You don\'t have valid User Role. Please contact your administrator.'));     
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Dashboard is available only for Sales and Sales Team Lead.'));
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


    public void generateDataForCharts() {
        todayDate = Date.today();
        year = String.valueOf(todayDate.year());
        if (selectedMonth != null) {
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
        //todayDate = Date.newinstance(2016, 4, 15);
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
        
        bussinesDays = returnBusinessDays(datetime.newInstance(startDateOfMonth.year(), startDateOfMonth.month(),startDateOfMonth.day()),datetime.newInstance(endDateOfMonth.year(), endDateOfMonth.month(),endDateOfMonth.day()));

        startDateOfMonthString = String.valueOf(startDateOfMonth.day()) + ' ' + monthsMap.get(startDateOfMonth.month());
        endDateOfMonthString = String.valueOf(endDateOfMonth.day()) + ' ' + monthsMap.get(endDateOfMonth.month());
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


    public Date returnFleetCorLastDayMonth(Date todayDateP) {
        DateTime tempEndDateOfMonth = DateTime.newInstance(todayDateP.toStartOfMonth().addDays(Date.daysInMonth(todayDateP.year(), todayDateP.month())), Time.newInstance(0, 0, 0, 0));
        Date dateEndDateOfMonth;

        if (tempEndDateOfMonth.format('EEEE') == 'Sunday') {
            dateEndDateOfMonth = Date.newinstance(tempEndDateOfMonth.year(), tempEndDateOfMonth.month(), tempEndDateOfMonth.day());
        } else {
            Date tempEndDate = Date.newinstance(tempEndDateOfMonth.year(), tempEndDateOfMonth.month(), tempEndDateOfMonth.day());
            dateEndDateOfMonth = tempEndDate.toStartOfWeek().toStartOfWeek().addDays(-1);
        }

        return dateEndDateOfMonth;
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

    public class PlanWrapper {
        public String name {get; set;}
        public Decimal numberOfCards {get; set;}
        public Decimal numberOfWeeks {get; set;}
        public String userRole {get; set;}

        public PlanWrapper(String name, Decimal numberOfCards, Decimal numberOfWeeks, String userRole) {
            this.name = name;
            this.numberOfWeeks = numberOfWeeks;
            this.userRole = userRole;
            if (userRole.contains('Inbound')) {
                if (numberOfWeeks == 3) {
                    this.numberOfCards = (numberOfCards * 1.3 * 0.75).round(System.RoundingMode.CEILING);
                } else if (numberOfWeeks == 5) {
                    this.numberOfCards = (numberOfCards * 1.3 * 1.25).round(System.RoundingMode.CEILING);
                } else {
                    this.numberOfCards = (numberOfCards * 1.3).round(System.RoundingMode.CEILING);
                }
            } else if (userRole.contains('Outbound') || userRole.contains('Salesteam Harte Hank')) {
                if (numberOfWeeks == 3) {
                    this.numberOfCards = (numberOfCards * 0.75).round(System.RoundingMode.CEILING);
                } else if (numberOfWeeks == 5) {
                    this.numberOfCards = (numberOfCards * 1.25).round(System.RoundingMode.CEILING);
                } else {
                    this.numberOfCards = (numberOfCards).round(System.RoundingMode.CEILING);
                }
            } else {
                this.numberOfCards = 0;
            }
        }
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
        12 => 'December'
    }; 

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
        'December' => 12
    };
}