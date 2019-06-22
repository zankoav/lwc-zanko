public class FindDuplicatesRuController {

    public Boolean isInnSelected { get; set; }
    public Boolean isCompanySelected { get; set; }
    public Boolean isEmailSelected { get; set; }
    public Boolean isPhoneSelected { get; set; }
    public Boolean isBackToRecord { get; set; }

    public String searchString { get; set; }
    public String searchINN { get; set; }
    public String searchCompany { get; set; }
    public String searchEmail { get; set; }
    public String searchPhone { get; set; }
    public String findPageTitle { get; set; }

    public Map<Id, Lead> matchingLeads { get; set; }
    public Map<Id, Opportunity> matchingOpportunities { get; set; }
    public Map<Id, Account> matchingAccounts { get; set; }
    public Map<Id, Contact> matchingContacts { get; set; }
    public Map<Id, User> managerUserMap { get; set; }
    public Map<Id, Lead> leadActivityMap { get; set; }
    public Map<Id, Opportunity> oppActivityMap { get; set; }
    public Map<Id, UserRecordAccess> recordAccessMap { get; set; }

    public String idForRequest { get; set; }
    public String commentForRequest { get; set; }

    public String companySOSL;
    public String emailSOSL;
    public String innSOSL;
    public String innSOQL;
    public String phoneSOQL;

    public String idObject;

    public Boolean isInboundRole{get; private set;}

    private Set<String> numberSet = new Set<String>{
            '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'
    };

    private List<String> escapedSymbols = new List<String>{
            '?', '&', '|', '!', '{', '}', '[', ']', '(', ')', '^', '~', '*', ':', '\\', '\"', '\'', '+', '-'
    };

    /*******************************************************************************
    *  Name            : search()
    *  Summary         : Action of Button from Home Page(VF-FindDuplicatesSidebar). For search lead/opp/acc/contact
    *  CreatedDate     : 31/08/2017
    *  Parameters      : -
    *  Returns         : PageReference
    *****************************************************************************/
    public PageReference search() {
        PageReference ref = new PageReference('/apex/FindDuplicatesRu');
        Set<Id> usersId = new Set<Id>();

        this.isCompanySelected = false;
        this.isEmailSelected = false;
        this.isPhoneSelected = false;
        this.isInnSelected = false;

        if (this.searchString.trim() != '' && numberConvert(this.searchString).length() > 4) {
            this.phoneSOQL = replaceQuotesSOQL(numberConvert(this.searchString));
            this.isPhoneSelected = true;
            this.searchPhone = numberConvert(this.searchString);
        }
        if (this.searchString.trim() != '' && this.searchString.trim().length() > 3) {
            this.companySOSL = replaceQuotesSOSL(this.searchString);
            this.emailSOSL = replaceQuotesSOSL(this.searchString);
            this.isCompanySelected = true;
            this.isEmailSelected = true;
            this.searchCompany = this.searchString;
            this.searchEmail = this.searchString;
        }
        if (numberConvert(this.searchString) != '' && numberConvert(this.searchString).length() > 9) {
            this.innSOQL = replaceQuotesSOQL(numberConvert(this.searchString));
            this.innSOSL = replaceQuotesSOSL(numberConvert(this.searchString));
            this.isInnSelected = true;
            this.searchINN = numberConvert(this.searchString);
        }

        selectSobjects();
        return ref;
    }

    /*******************************************************************************
    *  Name            : isInboundUserRole()
    *  Summary         : Check user is inbound
    *  CreatedDate     : 28/12/2017
    *  Parameters      : roleId - user role Id
    *  Returns         : Boolean
    ******************************************************************************/
    public static Boolean isInboundUserRole(Id roleId) {
        Set<String> restrictRoleNames = new Set<String>();
        for (RU_Inbound_Restrict_Group__c roleName : [SELECT id, name FROM RU_Inbound_Restrict_Group__c]) {
            restrictRoleNames.add(roleName.name);
        }

        List<UserRole> userRoles = ([SELECT Name FROM UserRole WHERE Id =: roleId AND Name =: restrictRoleNames]);

        if(userRoles.isEmpty()){
            return false;
        }
        return true;
    }

    /*******************************************************************************
    *  Name            : init()
    *  Summary         : Action of Controller. Display matching lead/opp/acc/contacts  with current lead
    *  CreatedDate     : 31/10/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void init() {
        this.isInboundRole = isInboundUserRole(UserInfo.getUserRoleId());
        this.findPageTitle = 'Поиск дубликатов';
        this.idObject = ApexPages.currentPage().getParameters().get('id');
        if (this.idObject != null) {
            this.isBackToRecord = true;
            String typeName = ID.valueOf(this.idObject).getSObjectType().getDescribe().getName();
            if (typeName == 'Lead') {
                Lead currentLead = [
                        SELECT Phone_clean__c, Company, Name, FirstName, LastName, Email, PostalCode, INN__c
                        FROM Lead
                        WHERE ID = :this.idObject
                ];
                this.findPageTitle = 'Поиск дубликатов по интересу: "' + currentLead.FirstName + ' ' + currentLead.LastName + '" ';

                if (currentLead.company != null)
                    this.searchCompany = currentLead.company; else
                        this.searchCompany = currentLead.name;
                this.isCompanySelected = true;
                this.companySOSL = replaceQuotesSOSL(this.searchCompany);

                if (currentLead.email != null) {
                    this.searchEmail = currentLead.email;
                    this.emailSOSL = replaceQuotesSOSL(this.searchEmail);
                    this.isEmailSelected = true;
                }
                if (currentLead.phone_clean__c != null) {
                    this.searchPhone = returnPhone(currentLead.phone_clean__c);
                    this.phoneSOQL = replaceQuotesSOQL(this.searchPhone);
                    this.isPhoneSelected = true;
                }
                if (currentLead.inn__c != null) {
                    this.searchINN = currentLead.inn__c;
                    this.innSOSL = replaceQuotesSOSL(this.searchINN);
                    this.innSOQL = replaceQuotesSOQL(this.searchINN);
                    this.isInnSelected = true;
                }
                selectSobjects();

            } else if (typeName == 'Opportunity') {
                Opportunity currentOpportunity = [
                        SELECT name, inn_opp__c, company_legal_name__c, account.name, account.phone_clean__c, Source_of_Lead_o__c
                        FROM Opportunity
                        WHERE ID = :idObject
                ];
                this.findPageTitle = 'Поиск дубликатов по возможности: "' + currentOpportunity.name + '"';

                if (currentOpportunity.name != null) {
                    this.searchCompany = currentOpportunity.name;
                    this.companySOSL = replaceQuotesSOSL(this.searchCompany);
                    this.isCompanySelected = true;
                }
                if (currentOpportunity.Account.phone_clean__c != null) {
                    this.searchPhone = currentOpportunity.Account.phone_clean__c;
                    this.phoneSOQL = replaceQuotesSOQL(this.searchPhone);
                    this.isPhoneSelected = true;
                }
                if (currentOpportunity.inn_opp__c != null) {
                    this.searchINN = currentOpportunity.inn_Opp__c;
                    this.innSOQL = replaceQuotesSOQL(this.searchINN);
                    this.innSOSL = replaceQuotesSOSL(this.searchINN);
                    this.isInnSelected = true;
                }
                selectSobjects();
                List<Contact> latestContacts;
                if(currentOpportunity.Source_of_Lead_o__c == 'E2E Form RU'){
                    latestContacts = [
                            SELECT Email,Phone
                            FROM Contact
                            WHERE AccountId = :currentOpportunity.AccountId
                            ORDER BY CreatedDate ASC
                            LIMIT 1
                    ];

                } else {
                    latestContacts = [
                            SELECT Email,Phone
                            FROM Contact
                            WHERE AccountId = :currentOpportunity.AccountId
                            ORDER BY CreatedDate DESC
                            LIMIT 1
                    ];
                }
                if (!latestContacts.isEmpty()) {
                    Contact cont = latestContacts.get(0);
                    if ((searchEmail == null || String.isEmpty(searchEmail)) && cont.Email != null && !String.isEmpty(cont.Email))
                        this.searchEmail = cont.Email;
                    if ((searchPhone == null || String.isEmpty(searchPhone)) && cont.Phone != null && !String.isEmpty(cont.Phone)){
                        this.searchPhone = cont.Phone;
                    }
                }
            }
        } else this.isBackToRecord = false;
    }


    /*******************************************************************************
    *  Name            : searchPage()
    *  Summary         : Display matching lead/opp/acc/contacts with selected checkboxes and their text fields.
                         Function Work from VF-FindDuplicates
    *  CreatedDate     : 31/08/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void searchPage() {
        if (this.searchCompany != null)
            this.companySOSL = replaceQuotesSOSL(this.searchCompany);
        if (this.searchINN != null)
            this.innSOQL = replaceQuotesSOQL(numberConvert(this.searchINN));
        this.innSOSL = replaceQuotesSOSL(numberConvert(this.searchINN));
        if (this.searchEmail != null)
            this.emailSOSL = replaceQuotesSOSL(this.searchEmail.trim());
        if (this.searchPhone != null)
            this.phoneSOQL = replaceQuotesSOQL(numberConvert(this.searchPhone));

        if (this.isCompanySelected == false && this.isInnSelected == false && this.isEmailSelected == false && this.isPhoneSelected == false) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.RU_0002_SelectFields));
            if (this.matchingLeads != null) this.matchingLeads.clear();
            if (this.matchingOpportunities != null) this.matchingOpportunities.clear();
            if (this.matchingAccounts != null) this.matchingAccounts.clear();
            if (this.matchingContacts != null) this.matchingContacts.clear();
        } else {
            selectSobjects();
        }
    }

    /*******************************************************************************
    *  Name            : selectSobjects()
    *  Summary         : select/find Sobjects records from Database with matching filters
    *  CreatedDate     : 31/08/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void selectSobjects() {
        String recordTypeLead = [SELECT id FROM recordtype WHERE name = 'Russian Sales' AND SobjectType = 'Lead'].ID;
        String recordTypeOpportunity = [SELECT id FROM recordtype WHERE name = 'Russian Sales' AND SobjectType = 'Opportunity'].ID;
        String recordTypeAccount = [SELECT id FROM recordtype WHERE name = 'Russian' AND SobjectType = 'Account'].ID;
        String recordTypeContact = [SELECT id FROM recordtype WHERE name = 'Russian' AND SobjectType = 'Contact'].ID;

        List<lead> listlead = new List<lead>();
        List<Opportunity> listOpportunities = new List<Opportunity>();
        List<Account> listAccount = new List<Account>();
        List<Contact> listContact = new List<Contact>();

        this.matchingLeads = new Map<id, lead>();
        this.matchingOpportunities = new Map<id, Opportunity>();
        this.matchingAccounts = new Map<id, Account>();
        this.matchingContacts = new Map<id, Contact>();
        this.recordAccessMap = new Map<Id, UserRecordAccess>();

        Integer maxRowsLead = 100;
        Integer maxRowsOpportunity = 100;
        Integer maxRowsAccount = 100;
        Integer maxRowsContact = 100;

        Boolean isSelectedLeadFields = false;
        Boolean isSelectedAccountFields = false;
        Boolean isSelectedOpportunitydFields = false;
        Boolean isSelectedContactFields = false;

        string queryLeads = ' Lead(Id, Name, INN__c, Email, Company, Status, CreatedDate, Phone, Owner.Name, Owner.Phone, Owner.Email,' +
                'OwnerId,Source_of_Lead__c,Phone_clean__c, IsConverted, LastTransferDate ' +
                'WHERE RecordType.id = \'' + recordTypeLead + '\' ';
        string queryOpportunities = ' Opportunity(Id, Name, INN_Opp__c, Organization_Type__c, Company_Legal_Name__c, Account.Name, Account.phone, Telefon_Phone__c,' +
                'StageName, CloseDate, CreatedDate, Owner.Alias, Owner.Name, Owner.Phone, Owner.Email, OwnerId, Owner.ManagerId, Source_of_lead_o__c,' +
                'Owner.Manager.FirstName, Owner.Manager.Phone, Owner.Manager.Email, Owner.Manager.LastName,Account.Phone_clean__c, IsWon, Last_Owner_Change_Date_RUS__c ' +
                'WHERE RecordType.id = \'' + recordTypeOpportunity + '\' ';
        String queryAccounts = ' Account(Id, Name, Company_Legal_Name1__c, INN__c, Type, ParentId, Parent.Name, Phone, CreatedDate, OwnerId, Owner.Alias, Owner.Phone,' +
                'Owner.Email, Owner.Manager.FirstName, account.Owner.Manager.LastName, Owner.Manager.Phone, Owner.Manager.Email,Phone_clean__c ' +
                'WHERE RecordType.id = \'' + recordTypeAccount + '\' ';
        String queryContacts = ' Contact(Id, Name, Phone,Email, CreatedDate, OwnerId, Owner.Alias, Owner.Phone, Owner.Email,' +
                'Owner.Manager.FirstName, Owner.Manager.LastName, Owner.Manager.Phone, Owner.Manager.Email,Phone_clean__c ' +
                'WHERE RecordType.id = \'' + recordTypeContact + '\' ';

//-----------------FIND sobjects by "Name"--------------------------------------
        if (this.isCompanySelected == true && this.companySOSL.length() > 3) {
            List<List<Sobject>> listSobjects = search.query('FIND {*' + this.companySOSL + '*} IN NAME FIELDS RETURNING ' +
                    queryLeads + ' ORDER BY NAME LIMIT ' + maxRowsLead + '),' +
                    queryOpportunities + ' ORDER BY NAME LIMIT ' + maxRowsOpportunity + '),' +
                    queryAccounts + ' ORDER BY NAME LIMIT ' + maxRowsAccount + '),' +
                    queryContacts + ' ORDER BY NAME LIMIT ' + maxRowsContact + ')');
            listlead = ((List<Lead>) listSobjects[0]);
            listOpportunities = ((List<Opportunity>) listSobjects[1]);
            listAccount = ((List<Account>) listSobjects[2]);
            listContact = ((List<Contact>) listSobjects[3]);
            //---Lead
            for (Lead lead : listLead) {
                if (!this.matchingLeads.containsKey(lead.id)) this.matchingLeads.put(lead.id, lead);
            }
            maxRowsLead = maxRowsLead - this.matchingLeads.size();
            if (maxRowsLead < 0) maxRowsLead = 0;
            //---Opportunity
            for (Opportunity opportunity : listOpportunities) {
                if (!this.matchingOpportunities.containsKey(opportunity.id)) this.matchingOpportunities.put(opportunity.id, opportunity);
            }
            maxRowsOpportunity = maxRowsOpportunity - this.matchingOpportunities.size();
            if (maxRowsOpportunity < 0) maxRowsOpportunity = 0;
            //---Account
            for (Account account : listAccount) {
                if (!this.matchingAccounts.containsKey(account.id)) this.matchingAccounts.put(account.id, account);
            }
            maxRowsAccount = maxRowsAccount - this.matchingAccounts.size();
            if (maxRowsAccount < 0) maxRowsAccount = 0;
            //---Contact
            for (Contact contact : listContact) {
                if (!this.matchingContacts.containsKey(contact.id)) this.matchingContacts.put(contact.id, contact);
            }
            maxRowsContact = maxRowsContact - this.matchingContacts.size();
            if (maxRowsContact < 0) maxRowsContact = 0;

            isSelectedLeadFields = true;
            isSelectedOpportunitydFields = true;
            isSelectedAccountFields = true;
            isSelectedContactFields = true;
        }
//-----------------FIND sobjects by "Email"--------------------------------------
        if (this.emailSOSL != null && this.isEmailSelected == true && this.emailSOSL.length() > 3) {
            List<List<Sobject>> listSobjects = search.query('FIND {*' + this.emailSOSL + '*} IN EMAIL FIELDS RETURNING' +
                    queryLeads + ' ORDER BY NAME LIMIT ' + maxRowsLead + '),' +
                    queryContacts + ' ORDER BY NAME LIMIT ' + maxRowsContact + ')');
            listLead = ((List<Lead>) listSobjects[0]);
            listContact = ((List<Contact>) listSobjects[1]);
            //---Lead
            for (Lead lead : listLead) {
                if (!this.matchingLeads.containsKey(lead.id)) this.matchingLeads.put(lead.id, lead);
            }
            maxRowsLead = maxRowsLead - this.matchingleads.size();
            if (maxRowsLead < 0) maxRowsLead = 0;
            //---Contact
            for (Contact contact : listContact) {
                if (!this.matchingContacts.containsKey(contact.id)) this.matchingContacts.put(contact.id, contact);
            }
            maxRowsContact = maxRowsContact - this.matchingContacts.size();
            if (maxRowsContact < 0) maxRowsContact = 0;

            isSelectedLeadFields = true;
            isSelectedContactFields = true;
        }
//-----------------FIND sobjects by "Phone"--------------------------------------
        if (this.isPhoneSelected == true && this.phoneSOQL.length() > 4) {
            //---Lead
            listlead = Database.query('SELECT Id, Name, INN__c, Email, Company, Status, CreatedDate, Phone, Owner.Name, Owner.Phone,' +
                    'Owner.Email,OwnerId,Source_of_Lead__c,Phone_clean__c, IsConverted, LastTransferDate, ' +
                    '(Select ActivityDate from OpenActivities Order by CreatedDate DESC Limit 1) ' +
                    'FROM LEAD WHERE RecordType.id = \'' + recordTypeLead + '\' AND ' +
                    'Phone_clean__c LIKE \'' + '%' + this.phoneSOQL + '%' + '\' ' +
                    'ORDER BY NAME LIMIT ' + maxRowsLead);
            for (Lead lead : listlead) {
                if (!this.matchingLeads.containsKey(lead.id)) this.matchingLeads.put(lead.id, lead);
            }
            maxRowsLead = maxRowsLead - this.matchingleads.size();
            if (maxRowsLead < 0) maxRowsLead = 0;
            //---Account
            listAccount = Database.query('SELECT Id, Name, Company_Legal_Name1__c, INN__c, Type, ParentId, Parent.Name, Phone, CreatedDate, OwnerId, Owner.Alias,' +
                    'Owner.Phone,Owner.Email, Owner.Manager.FirstName, account.Owner.Manager.LastName,' +
                    'Owner.Manager.Phone, Owner.Manager.Email,Phone_clean__c ' +
                    'FROM Account WHERE RecordType.id = \'' + recordTypeAccount + '\' AND ' +
                    'Phone_clean__c LIKE \'' + '%' + this.PhoneSOQL + '%' + '\' ORDER BY NAME LIMIT ' + maxRowsAccount);
            for (Account account : listAccount) {
                if (!this.matchingAccounts.containsKey(account.id)) this.matchingAccounts.put(account.id, account);
            }
            maxRowsAccount = maxRowsAccount - this.matchingAccounts.size();
            if (maxRowsAccount < 0) maxRowsAccount = 0;
            //---Opportunity (based on Account)
            List<ID> setAccountId = new List<ID>();
            for (Account account : listAccount) {
                setAccountId.add(account.id);
            }
            listOpportunities = Database.query('SELECT Id, Name, INN_Opp__c, Organization_Type__c, Company_Legal_Name__c, Account.Name, Account.phone, Telefon_Phone__c,' +
                    'StageName, CloseDate, CreatedDate, Owner.Alias, Owner.Name, Owner.Phone, Owner.Email, OwnerId,' +
                    'Owner.ManagerId,Owner.Manager.FirstName, Owner.Manager.Phone, Owner.Manager.Email,' +
                    'Owner.Manager.LastName,Account.Phone_clean__c,Source_of_lead_o__c, IsWon, Last_Owner_Change_Date_RUS__c,' +
                    '(Select ActivityDate from OpenActivities Order by CreatedDate DESC Limit 1) ' +
                    'FROM Opportunity WHERE RecordType.id = \'' + recordTypeOpportunity + '\'  AND ' +
                    'Account.id in :setAccountId ' +
                    'ORDER BY NAME LIMIT ' + maxRowsOpportunity);
            for (Opportunity opportunity : listOpportunities) {
                if (!this.matchingOpportunities.containsKey(opportunity.id)) this.matchingOpportunities.put(opportunity.id, opportunity);
            }
            maxRowsOpportunity = maxRowsOpportunity - this.matchingOpportunities.size();
            if (maxRowsOpportunity < 0) maxRowsOpportunity = 0;
            //---Contact
            listContact = Database.query('SELECT Id, Name, Phone,Email, CreatedDate, OwnerId, Owner.Alias, Owner.Phone, Owner.Email,' +
                    'Owner.Manager.FirstName, Owner.Manager.LastName, Owner.Manager.Phone, Owner.Manager.Email,Phone_clean__c ' +
                    'FROM Contact WHERE RecordType.id = \'' + recordTypeContact + '\' AND ' +
                    'Phone_clean__c LIKE \'' + '%' + this.phoneSOQL + '%' + '\' ORDER BY NAME LIMIT ' + maxRowsContact);
            for (Contact contact : listContact) {
                if (!this.matchingContacts.containsKey(contact.id)) this.matchingContacts.put(contact.id, contact);
            }
            maxRowsContact = maxRowsContact - this.matchingContacts.size();
            if (maxRowsContact < 0) maxRowsContact = 0;

            isSelectedLeadFields = true;
            isSelectedOpportunitydFields = true;
            isSelectedAccountFields = true;
            isSelectedContactFields = true;
        }
//-----------------FIND sobjects by "INN"--------------------------------------
        if (this.innSOQL != null && this.isInnSelected == true && this.innSOQL.length() > 9) {
            List<List<Sobject>> listSobjects = search.query('FIND {"' + this.innSOSL + '"} RETURNING ' +
                    queryLeads + ' AND INN__C = \'' + this.innSOQL + '\' ORDER BY NAME LIMIT ' + maxRowsLead + '),' +
                    queryAccounts + ' AND INN__C = \'' + this.innSOQL + '\' ORDER BY NAME  LIMIT ' + maxRowsAccount + ')');
            listLead = ((List<Lead>) listSobjects[0]);
            listAccount = ((List<Account>) listSobjects[1]);

            List<ID> setAccountId = new List<ID>();
            for (Account account : listAccount) {
                setAccountId.add(account.id);
            }
            listOpportunities = Database.query('SELECT Id, Name, INN_Opp__c, Organization_Type__c, Company_Legal_Name__c, Account.Name, Account.phone, Telefon_Phone__c,' +
                    'StageName, CloseDate, CreatedDate, Owner.Alias, Owner.Name, Owner.Phone, Owner.Email, OwnerId,' +
                    'Owner.ManagerId,Owner.Manager.FirstName, Owner.Manager.Phone, Owner.Manager.Email, Source_of_lead_o__c,' +
                    'Owner.Manager.LastName,Account.Phone_clean__c, IsWon, Last_Owner_Change_Date_RUS__c,' +
                    '(Select ActivityDate from OpenActivities Order by CreatedDate DESC Limit 1) ' +
                    'FROM Opportunity WHERE RecordType.id = \'' + recordTypeOpportunity + '\' AND ' +
                    'Account.id in :setAccountId ' +
                    'ORDER BY NAME LIMIT ' + maxRowsOpportunity) ;
            //---Lead
            for (Lead lead : listLead) {
                if (!this.matchingLeads.containsKey(lead.id)) this.matchingLeads.put(lead.id, lead);
            }
            maxRowsLead = maxRowsLead - this.matchingleads.size();
            if (maxRowsLead < 0) maxRowsLead = 0;
            //---Opportunity  (based on Account)
            for (Opportunity opportunity : listOpportunities) {
                if (!this.matchingOpportunities.containsKey(opportunity.id)) this.matchingOpportunities.put(opportunity.id, opportunity);
            }
            maxRowsOpportunity = maxRowsOpportunity - this.matchingOpportunities.size();
            if (maxRowsOpportunity < 0) maxRowsOpportunity = 0;
            //---Account
            for (Account account : listAccount) {
                if (!this.matchingAccounts.containsKey(account.id)) this.matchingAccounts.put(account.id, account);
            }
            maxRowsAccount = maxRowsAccount - this.matchingAccounts.size();
            if (maxRowsAccount < 0) maxRowsAccount = 0;

            isSelectedLeadFields = true;
            isSelectedOpportunitydFields = true;
            isSelectedAccountFields = true;
        }

        Integer allSize = 0; // Total amount of records for check result of user query
//-----------------IF Lead records are searched --------------------------------------
        if (isSelectedLeadFields == true) {
            allSize += this.matchingLeads.size();

            Set<Id> usersId = new Set<Id>();
            Set<id> selectedLeadId = new Set<Id>();
            for (Lead lead : this.matchingLeads.values()) {
                if (String.valueOf(lead.OwnerId).substring(0, 3) == '005') {
                    usersId.add(lead.OwnerId);
                }
                selectedLeadId.add(lead.id);
            }
            //---Lead Manager info
            List<User> usersList = new List<User>();
            usersList = [
                    SELECT Id, ManagerId, Manager.FirstName, Manager.LastName, Manager.Phone, Manager.Email
                    FROM User
                    WHERE Id IN :usersId
                    LIMIT 1000
            ];
            this.managerUserMap = new Map<Id, User>();
            for (User user : usersList) {
                if (user.Id != null) {
                    this.managerUserMap.put(user.Id, user);
                }
            }
            //---Lead Activity info
            List<Lead> leadActivity = new List<lead>();
            leadActivity = [
                    select id, (Select ActivityDate from OpenActivities Order by CreatedDate DESC Limit 1)
                    FROM lead
                    where ID IN :selectedLeadId
                    limit 100
            ];
            this.LeadActivityMap = new map<id, Lead>();
            for (Lead lead : leadActivity) {
                if (lead.Id != null) {
                    this.leadActivityMap.put(lead.Id, lead);
                }
            }
            //---Lead Access info
            for (UserRecordAccess userRecordAccess : [
                    SELECT recordId, hasReadAccess
                    FROM UserRecordAccess
                    WHERE recordid in :selectedLeadId AND UserId = :UserInfo.getUserId()
            ]) {
                this.recordAccessMap.put(userRecordAccess.recordId, userRecordAccess);
            }
            //-- chouse record for approve
        }
//-----------------IF Opportunity records are searched --------------------------------------
        if (isSelectedOpportunitydFields == true) {
            allSize += this.matchingOpportunities.size();

            Set<id> selectedOppId = new Set<Id>();
            for (Opportunity opp : this.matchingOpportunities.values()) {
                selectedOppId.add(opp.id);
            }
            //---Opportunity Activity info
            List<Opportunity> oppActivity = new List<Opportunity>();
            oppActivity = [
                    select id, (Select ActivityDate from OpenActivities Order by CreatedDate DESC Limit 1)
                    FROM Opportunity
                    WHERE ID IN :selectedOppId
                    limit 100
            ];
            this.oppActivityMap = new map<id, Opportunity>();
            for (Opportunity opportunity : oppActivity) {
                if (opportunity.Id != null) {
                    this.oppActivityMap.put(opportunity.Id, opportunity);
                }
            }
            //---Opportunity Access info
            for (UserRecordAccess userRecordAccess : [
                    SELECT recordId, hasReadAccess
                    FROM UserRecordAccess
                    WHERE recordid in :selectedOppId AND UserId = :UserInfo.getUserId()
            ]) {
                this.recordAccessMap.put(userRecordAccess.recordId, userRecordAccess);
            }
        }
//-----------------IF Account records are searched --------------------------------------
        if (isSelectedAccountFields == true) {
            allSize += this.matchingAccounts.size();

            Set<id> selectedAccountId = new Set<Id>();
            for (Account account : this.matchingAccounts.values()) {
                selectedAccountId.add(account.id);
                selectedAccountId.add(account.ParentId);
            }
            //---Account Access info
            for (UserRecordAccess userRecordAccess : [
                    SELECT RecordId, HasReadAccess
                    FROM UserRecordAccess
                    WHERE recordid in :selectedAccountId AND UserId = :UserInfo.getUserId()
            ]) {
                this.recordAccessMap.put(userRecordAccess.recordid, userRecordAccess);
            }
        }
//-----------------IF Contact records are searched --------------------------------------
        if (isSelectedContactFields == true) {
            allSize += this.matchingContacts.size();

            Set<id> SelectedContactId = new Set<Id>();
            for (Contact cont : this.matchingContacts.values()) {
                SelectedContactId.add(cont.id);
            }
            //---Contact Access info
            for (UserRecordAccess userRecordAccess : [
                    SELECT RecordId, HasReadAccess
                    FROM UserRecordAccess
                    WHERE recordid in :SelectedContactId AND UserId = :UserInfo.getUserId()
            ]) {
                this.recordAccessMap.put(userRecordAccess.recordid, userRecordAccess);
            }
        }

        if (allSize == 0) {
            if ((this.isCompanySelected && this.companySOSL.length() < 4) ||
                    (this.isEmailSelected && this.emailSOSL.length() < 4) ||
                    (this.isPhoneSelected && this.phoneSOQL.length() < 5)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.RU_0001_DuplicatesSymbol));
            } else if ((this.isCompanySelected && this.companySOSL.length() > 3) ||
                    (this.isEmailSelected && this.emailSOSL.length() > 3) ||
                    (this.isPhoneSelected && this.phoneSOQL.length() > 4)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.RU_0003_SelectAnother));
            } else if (this.isInnSelected && this.innSOQL.length() > 0) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.RU_0004_ForSearchINN));
            }
        }
    }

    /*******************************************************************************
    *  Name            : replaceQuotesSOSL(String queryString)
    *  Summary         : replace quotes in SOSL requests
    *  CreatedDate     : 31/08/2017
    *  Parameters      : String queryString - String to change
    *  Returns         : String
    ******************************************************************************/
    public String replaceQuotesSOSL(String queryString) {
        for (integer i = 0; i <= escapedSymbols.size() - 1; i++) {
            queryString = queryString.replace(escapedSymbols[i], '*');
        }
        return queryString;
    }

    /*******************************************************************************
    *  Name            : replaceQuotesSOQL(String queryString)
    *  Summary         : replace quotes in SOQL requests
    *  CreatedDate     : 24/05/2017
    *  Parameters      : String queryString - String to change
    *  Returns         : String
    ******************************************************************************/
    public String replaceQuotesSOQL(String queryString) {
        queryString = queryString.replace('\\', '\\' + '\\');
        queryString = queryString.replace('\'', '\\' + '\'');
        queryString = queryString.replace('\"', '\\' + '\"');
        return queryString;
    }

    /*******************************************************************************
    *  Name            : backToRecord()
    *  Summary         : Redirect to lead record
    *  CreatedDate     : 31/08/2017
    *  Parameters      :
    *  Returns         : PageReference
    ******************************************************************************/
    public PageReference backToRecord() {
        return new PageReference('/' + this.idObject);
    }


    /*******************************************************************************
    *  Name            : numberConvert()
    *  Summary         : Convert string to string of digit
    *  CreatedDate     : 15/08/2017
    *  Parameters      : String - phone number
    *  Returns         : String
    ******************************************************************************/
    public String numberConvert(String st) {
        String stringReturn = '';
        for (integer i = 0; i < st.length(); i++) {
            if (numberset.contains(st.substring(i, i + 1))) {
                stringReturn += st.substring(i, i + 1);
            }
        }
        return stringReturn;
    }

        /*******************************************************************************
        *  Name            : sendRequestForChangeOwner()
        *  Summary         : Send email to admin for change owner of record
        *  CreatedDate     : 31/10/2017
        *  Parameters      : -
        *  Returns         : void
        ******************************************************************************/
    public void sendRequestForChangeOwner() {
        try {
            Set<String> approveUsersEmails = new Set<String>();
			for (RU_Admin_Approver__c emailApprover : [SELECT id, name FROM Ru_Admin_Approver__c]) { //Custom Settings
				approveUsersEmails.add(emailApprover.name);
			}

            if ((this.idForRequest <> '') && (approveUsersEmails.size() <> 0)) {
                String typeName = ID.valueOf(this.idForRequest).getSObjectType().getDescribe().getName();
                String innForEmail;
                String recordOwnerName;
                id recordOwnerId;

				String additionalInfo = '';
				if (typeName == 'Lead') {
					List<Lead> recordLead =
					[SELECT inn__c, owner.name, Status, Source_of_Lead__c FROM lead WHERE id = :idForRequest];
					if (recordLead.size() == 1) {
						innForEmail = recordLead.get(0).INN__c;
						recordOwnerName = recordLead.get(0).owner.name;
						recordOwnerId = recordLead.get(0).ownerid;
						additionalInfo = '<p>Статус: ' + recordLead.get(0).Status + '</p>' + '<p>Источник интереса: ' + recordLead.get(0).Source_of_Lead__c + '</p>';

					}
				} else if (typeName == 'Opportunity') {
					List<Opportunity> recordOpportunity =
					[SELECT INN_Opp__c, owner.name, StageName, account.Type, Source_of_Lead_o__c FROM Opportunity WHERE id = :idForRequest];
					if (recordOpportunity.size() == 1) {
						innForEmail = recordOpportunity.get(0).INN_Opp__c;
						recordOwnerName = recordOpportunity.get(0).owner.name;
						recordOwnerId = recordOpportunity.get(0).ownerid;
						additionalInfo = '<p>Этап: ' + recordOpportunity.get(0).StageName + '</p>' +
								'<p>Тип организации: ' + recordOpportunity.get(0).account.Type  + '</p>' +
								'<p>Источник интереса: ' + recordOpportunity.get(0).Source_of_Lead_o__c + '</p>';
					}
				}
				Id currentUserId = UserInfo.getUserId();
				String currentUserEmail = UserInfo.getUserEmail();
				if ((currentUserId != recordOwnerId) && (recordOwnerId != null)) {

					String[] approveUsersEmailsArray = new List<String>();
					for (String item : approveUsersEmails) {
						approveUsersEmailsArray.add(item);
					}

					List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();

					emailMessageList.add(
							EmailGenerator.prepareHtmlEmailToTarget(
									approveUsersEmailsArray,
									'Изменение владельца записи',
											'<p>Поступил запрос на изменение владельца записи <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + this.idForRequest + '" > ' + this.idForRequest + ' </a> </p>' +
											'<p>Тип записи  : ' + typeName + '</p>' +
											additionalInfo +
											'<p>Инн : ' + innForEmail + '</p>' +
											'<p>Текущий  владелец     : ' + recordOwnerName + '</p>' +
											'<p>Изменить владельца на : ' + Userinfo.getFirstName() + ' ' + Userinfo.getLastName() + '</p>' +
											'<p>Комментарий : ' + this.commentForRequest + '</p>' +
											'<p>Для того чтобы изменить владельца записи, нажмите на кнопку "Подтвердить"</p>' +
											'<table border="0"> <tr> ' +
											'<th> <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/apex/ApprovePprRequestFromEmail?Type=001&Answer=yes&idRecord=' + this.idForRequest + '&idNewOwner=' + currentUserId + '"> Подтвердить </a> </th> ' +
											'<th> <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/apex/ApprovePprRequestFromEmail?Type=001&Answer=no&idRecord=' + this.idForRequest + '&idNewOwner=' + currentUserId + '"> Отклонить </a> </th> ' +
											'</tr> </table> '
							)
					);
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.RU_0007_RequestSended));
					emailMessageList.add(
							EmailGenerator.prepareHtmlEmailToTarget(
									new String[]{currentUserEmail},
									'Запрос принят',
											'<p>Ваш запрос на получение записи <a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + this.idForRequest + '" > ' + this.idForRequest + ' </a> - отправлен Администратору</p>' +
											'<p>Пожалуйста ожидайте ответа</p>'
							)
					);
					Messaging.sendEmail(emailMessageList);

				} else {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.RU_0007_OwnerCanNotBeChanged));
				}
			} else {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Ошибка! ' + Label.RU_0011_SelectTheRecord));
			}
		} catch (Exception e) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Ошибка! ' + e.getMessage() + '(' + e.getStackTraceString() + ')'));
		}
		this.commentForRequest = '';
		this.idForRequest = '';
    }

    /*******************************************************************************
    *  Name            : returnPhone()
    *  Summary         : Returns the first phone number before space
    *  CreatedDate     : 14/02/2018
    *  Parameters      : String phoneString
    *  Returns         : String
    ******************************************************************************/
    private String returnPhone(String phoneString){
        if(phoneString.contains(' ')){
            return phoneString.substringBefore(' ');
        } else {
            return phoneString;
        }
    }

}