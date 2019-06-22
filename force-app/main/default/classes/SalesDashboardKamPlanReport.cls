public with sharing class SalesDashboardKamPlanReport {
    public User currentUser {get; set;}
	public String startDateOfMonthString {get; set;}
    public String endDateOfMonthString {get; set;}
    public String selectedMonth {get; set;}
    public String currentYear {get; set;}
    public List<Account> allAccountsForReport {get; set;}

    private Date startDateOfMonth;
    private Date endDateOfMonth;


    public void init () {
    	generateStartEndDateMonth ();
    	generateAllAccountsWithTasks ();
    }


    /*******************************************************************************
    *  Name            : generateAllAccountsWithTasks ()
    *  Summary         : getting all accounts with tasks (meetings)   
    *  CreatedDate     : 27.12.2016
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void generateAllAccountsWithTasks () {
    	String selectedUserId = Apexpages.currentPage().getParameters().get('userid');
    	
		currentUser = [
	            SELECT UserRole.Name, Profile.Name, Name, UserRoleId
	            FROM User
	            WHERE Id = :selectedUserId
	            LIMIT 1];

        List<Task> allTaskForUser =	[
				SELECT Id, WhatId, Subject, ActivityDate
				FROM Task 
				WHERE Subject = 'Meeting' AND 
                    Status = 'Completed' AND
                    OwnerId = :currentUser.Id AND
                    CreatedDate >= :startDateOfMonth AND
                    CreatedDate <= :endDateOfMonth AND
					WhatId IN (SELECT Id FROM Account WHERE RecordType.Name = 'Retailer' AND KAM__c = :currentUser.Id)
				LIMIT 50000];

		Set<Id> idRelationsAcc = new Set<Id>();
		for (Task t : allTaskForUser){
			idRelationsAcc.add(t.WhatId);
		}

		allAccountsForReport = [
				SELECT Id, Name, BillingCountry, OwnerId, Owner.Name, OBN__c, Last_contact_date__c, Last_contact_results__c
				FROM Account
				WHERE RecordType.Name = 'Retailer' AND
						Id IN :idRelationsAcc];
    }


    /*******************************************************************************
    *  Name            : generateStartEndDateMonth ()
    *  Summary         : getting start date and end date of the selected month 
    *  CreatedDate     : 27.12.2016
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public void generateStartEndDateMonth () {
    	selectedMonth = Apexpages.currentPage().getParameters().get('month');
    	currentYear = Apexpages.currentPage().getParameters().get('year');

    	startDateOfMonth = [
                SELECT Start_Date__c 
                FROM Fleetcor_Calendar_Month__c 
                WHERE Fleetcor_Calendar_Year__r.Name = :currentYear AND
                    Name = :selectedMonth LIMIT 1].Start_Date__c;

        endDateOfMonth = [
                SELECT End_Date__c 
                FROM Fleetcor_Calendar_Month__c 
                WHERE Fleetcor_Calendar_Year__r.Name = :currentYear AND
                    Name = :selectedMonth LIMIT 1].End_Date__c;

        startDateOfMonthString = String.valueOf(startDateOfMonth.day()) + ' ' + monthsMap.get(startDateOfMonth.month());
        endDateOfMonthString = String.valueOf(endDateOfMonth.day()) + ' ' + monthsMap.get(endDateOfMonth.month());
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