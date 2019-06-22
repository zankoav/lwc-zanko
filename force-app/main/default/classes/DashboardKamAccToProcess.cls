public with sharing class DashboardKamAccToProcess {
    public Integer quantityAllAccounts {get; set;}
    public Integer quantityAccountsGermany {get; set;}
    public Integer quantityAccountsAustria {get; set;}
    public Integer quantityAccountsSwitzerlandDE {get; set;}
	public User currentUser {get; set;}
	// public String startDatePeriodString {get; set;}
 //    public String endDatePeriodString {get; set;}
	private Date startDatePeriod;
    private Date endDatePeriod;


	public void init() {
		this.quantityAllAccounts = 0;
		this.quantityAccountsGermany = 0;
		this.quantityAccountsAustria = 0;
		this.quantityAccountsSwitzerlandDE = 0;
		generateDataForDashboard();
		selectAccountWithoutMeetingTasks();
	}


    /*******************************************************************************
    *  Name            : selectAccountWithoutMeetingTasks()
    *  Summary         : Getting all accounts without meeting tasks over the past three months for
						 Germany, Austria, Switzerland-DE   
    *  CreatedDate     : 10/01/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void selectAccountWithoutMeetingTasks() {
		if (this.currentUser.Profile.Name == 'Key Account Manager' || this.currentUser.Profile.Name == 'Sales Director' ||
			this.currentUser.Profile.Name == 'System Administrator') {
	    	List<Account> allAccountsList = [
				SELECT Id, Name, BillingCountry, OwnerId, Owner.Name, CreatedDate, OBN__c, Last_contact_date__c, Last_contact_results__c
				FROM Account
				WHERE RecordType.Name = 'Retailer' AND
					  (BillingCountry = 'Germany' OR BillingCountry = 'Austria' OR BillingCountry = 'Switzerland-DE')
				LIMIT 50000];

		 	Set<Id> allAccountsIdSet = new Set<Id>();
		  	for (Account ac : allAccountsList){
		  		allAccountsIdSet.add(ac.Id);
		  	}

		  	List<Task> allMeetingTaskList =	[
				SELECT Id, WhatId, Subject, ActivityDate
				FROM Task 
				WHERE Subject = 'Meeting' AND 
	                Status = 'Completed' AND
	                ActivityDate >= :this.startDatePeriod AND 
	                ActivityDate <= :this.endDatePeriod AND
					WhatId IN :allAccountsIdSet
				LIMIT 50000];

			Set<Id> accountsWithTasksIdSet = new Set<Id>();
		  	for (Task t : allMeetingTaskList){
		  		accountsWithTasksIdSet.add(t.WhatId);
		  	}

		  	List<Account> accountsWithoutTasks = new List<Account>();
		  	for (Account acc : allAccountsList){
		  		if (! accountsWithTasksIdSet.contains(acc.Id)){
		  			accountsWithoutTasks.add(acc);
		  		}
		  	}

		  	//accounts count
			this.quantityAllAccounts = accountsWithoutTasks.size();

			for (Account account : accountsWithoutTasks){
				if (account.BillingCountry == 'Germany'){
					this.quantityAccountsGermany++;
				}
				if (account.BillingCountry == 'Austria'){
					this.quantityAccountsAustria++;
				}
				if (account.BillingCountry == 'Switzerland-DE'){
					this.quantityAccountsSwitzerlandDE++;
				}
			}	  
		} else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Invalid User Profile'));
		}
    }


    /*******************************************************************************
    *  Name            : generateDataForDashboard()
    *  Summary         : generate Data For Dashboard    
    *  CreatedDate     : 10/01/2016
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void generateDataForDashboard() {
        String userId = UserInfo.getUserId();
    	this.currentUser = [
            SELECT UserRole.Name, Profile.Name, Name, UserRoleId
            FROM User
            WHERE Id = :userId
            LIMIT 1];

        this.endDatePeriod = Date.today();
        this.startDatePeriod = endDatePeriod.addMonths(-3);

        // if (this.startDatePeriod.year() == this.endDatePeriod.year()) {
        // 	startDatePeriodString = String.valueOf(this.startDatePeriod.day()) + ' ' + monthsMap.get(this.startDatePeriod.month());
        // 	endDatePeriodString = String.valueOf(this.endDatePeriod.day()) + ' ' + monthsMap.get(this.endDatePeriod.month()) + ' ' + this.endDatePeriod.year();
        // } else {
        // 	startDatePeriodString = String.valueOf(this.startDatePeriod.day()) + ' ' + monthsMap.get(this.startDatePeriod.month()) + ' ' + this.startDatePeriod.year();
        // 	endDatePeriodString = String.valueOf(this.endDatePeriod.day()) + ' ' + monthsMap.get(this.endDatePeriod.month()) + ' ' + this.endDatePeriod.year();
        // }     
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