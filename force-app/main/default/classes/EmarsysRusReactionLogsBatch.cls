global class EmarsysRusReactionLogsBatch implements Database.Batchable<String>, Database.AllowsCallouts, Database.Stateful {
    public AsyncApexJob asyncJob;
    public Set<Id> recordTypesIds;
    public List<SObject> parentSObjectsList;
    public String emailName;
    public String currentEmailId;
    public String currentHtmlSource; // email body template
    global Boolean canUpdateSegmentDate;
    global List<Emarsys_Contact_Subscriptions__c> emarsysContactSubscriptions = getEmarsysSubscriptionSegments();

    /*******************************************************************************
    *  Name            : Iterable<String> start(Database.BatchableContext bc)
    *  Summary         : Collect List of Emarsys contacts to pass to the interface method execute
    *  CreatedDate     : 12/10/2017
    *  Parameters      : Database.BatchableContext bc - object for tracking the progress of the batch job
    *  Returns         : Iterable<String>
    *****************************************************************************/
    global Iterable<String> start(Database.BatchableContext bc) {
        return getEmarsysContactsListing(bc);
    }

    global void execute(Database.BatchableContext BC, List<String> scope) {
        try {
            createEmarsysLogs(scope, emarsysContactSubscriptions.get(0));
        } catch (Exception e) {
            ExceptionLogger.sendException(String.valueOf(e.getMessage()), String.valueOf(e.getStackTraceString()));
        }
    }

    global void finish(Database.BatchableContext BC) {
        asyncJob = [
                SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems
                FROM AsyncApexJob
                WHERE Id = :bc.getJobId()
        ];

        if (asyncJob != null && asyncJob.Status == 'Completed' && canUpdateSegmentDate) {
            System.debug('JOB ID ' + bc.getJobId() + ' JOB ITEMS ' + asyncJob.JobItemsProcessed);
            emarsysContactSubscriptions.get(0).Last_Update_Segment_Date__c = datetime.now();
            update emarsysContactSubscriptions;
        }

        List<CronTrigger> jobsList = [
                SELECT Id
                FROM CronTrigger
                WHERE CronJobDetail.Name LIKE 'EmarsysLog Update Reaction Type%'
                LIMIT 100
        ];
        if (jobsList.isEmpty()) {
            List<Emarsys_Log__c> emarsysLogCheck = [
                    SELECT Id
                    FROM Emarsys_Log__c
                    WHERE Type__c = 'Reaction Open or Click'
                    AND Email_id__c <> ''
                    AND Business_Type__c = 'RU'
                    LIMIT 1
            ];
            if (EmarsysLogCheck.size() <> 0) {
                String schedule = datetime.now().addMinutes(1).second() + ' ' + datetime.now().addMinutes(1).minute() + ' 6-18' + ' ?' + ' *' + ' MON-FRI';
                EmarsysTypeReactionSchedule emarsysUpdateType = new EmarsysTypeReactionSchedule();
                System.schedule('EmarsysLog Update Reaction Type ' +
                        datetime.now().addMinutes(1).hour() + ':' + datetime.now().addMinutes(1).minute() + ':' + datetime.now().addMinutes(1).second(),
                        schedule,
                        emarsysUpdateType);
            }
        }
    }

    /*******************************************************************************
    *  Name            : void createEmarsysLogs(List<String> scope)
    *  Summary         : create Emarsys Reactions Russian logs
    *  CreatedDate     : 12/10/2017
    *  Parameters      : List<String> scope - contacts list from Emarsys
    *  Returns         : void
    *****************************************************************************/
    public void createEmarsysLogs(List<String> scope, Emarsys_Contact_Subscriptions__c emarsysContactSubscription) {

        //Emarsys_Contact_Subscriptions__c emarsysContactSubscription = emarsysContactSubscriptions.get(0);
        emailName = emarsysContactSubscription.Email_Name__c;

        String emarsysContactsIds = '';
        for (String contactId : scope) {
            emarsysContactsIds += contactId + ', ';
        }
        emarsysContactsIds = emarsysContactsIds.removeEnd(', ');

        recordTypesIds = getRussianRecordTypesIdsSet();
        parentSObjectsList = returnSObjectsList(emarsysContactSubscription, recordTypesIds, scope);

        // Get Email history and launch data
        Map<String, EmarsysEmailHistoryEntity.Data> emailsLaunchDataMap = new Map<String, EmarsysEmailHistoryEntity.Data>();
        String emarsysAccount = GlobalUtils.getEmarsysAccount(GlobalUtils.EmarsysAccounts.AccountRus.name());
        emailsLaunchDataMap = EmarsysWebService.getEmailLaunchData(emarsysContactsIds, emarsysAccount);

        // Email campaign data
        getEmailCampaignData(emailsLaunchDataMap);

        Map<Id, String> sObjectToOwnerManagerMap = generateSObjectToOwnerManagerMap();
        List<Emarsys_Log__c> newLogsToInsert = new List<Emarsys_Log__c>();
        for (SObject currentSObject : parentSObjectsList) {
            // Create log only for objects that haven't got Emarsys Log, other data wouldn't log
            if (currentSObject.getSObjects('Emarsys_Logs__r') == null || currentSObject.getSObjects('Emarsys_Logs__r').isEmpty()) {
                if (emailsLaunchDataMap.get(String.valueOf(currentSObject.get('Emarsys_Contact_Id__c'))) != null) {
                    if (String.valueOf(emailsLaunchDataMap.get(String.valueOf(currentSObject.get('Emarsys_Contact_Id__c'))).emailId) == currentEmailId) {
                        Emarsys_Log__c newLog = new Emarsys_Log__c(
                                Business_Type__c = 'RU',
                                Email_Id__c = String.valueOf(emailsLaunchDataMap.get(String.valueOf(currentSObject.get('Emarsys_Contact_Id__c'))).emailId),
                                Email_Date__c = String.valueOf(emailsLaunchDataMap.get(String.valueOf(currentSObject.get('Emarsys_Contact_Id__c'))).launch_date),
                                Email_Body__c = currentHtmlSource,
                                Email_Name__c = emarsysContactSubscription.Email_Name__c,
                                Segment_Name__c = emarsysContactSubscription.Subscription_Name__c,
                                Is_Email_Body_Updated__c = false,
                                OwnerId = String.valueOf(currentSObject.get('OwnerId')),
                                Type__c = GlobalUtils.getEmarsysReactionType(GlobalUtils.EmarsysReactionTypesRus.DefaultReaction.name())
                        );

                        if (emarsysContactSubscription.Type__c == 'Lead') {
                            newLog.Lead__c = String.valueOf(currentSObject.get('Id'));
                        } else if (emarsysContactSubscription.Type__c == 'Opportunity') {
                            newLog.Opportunity__c = String.valueOf(currentSObject.get('Id'));
                        }

                        if (sObjectToOwnerManagerMap.get(String.valueOf(currentSObject.get('OwnerId'))) != null) {
                            newLog.Owner_Manager_Email__c = sObjectToOwnerManagerMap.get(String.valueOf(currentSObject.get('OwnerId')));
                        }
                        newLogsToInsert.add(newLog);
                    }
                }
            }
        }

        insert newLogsToInsert;
    }

    /*******************************************************************************
    *  Name            : getEmarsysContactsListing()
    *  Summary         : Return Emarsys contacts listing depending on Emarsys Subscription
    *  CreatedDate     : 12/10/2017
    *  Parameters      : -
    *  Returns         : EmarsysListingContactsEntity
    ******************************************************************************/
    @TestVisible
    private List<String> getEmarsysContactsListing(Database.BatchableContext bc) {
        // Get Emarsys_Contact_Subscriptions__c list from Custom Settings
        EmarsysListingContactsEntity emarsysResponse = new EmarsysListingContactsEntity();
        Boolean isBatchInProgress = false;
        canUpdateSegmentDate = false;

        List<String> contactsListing = new List<String>();
        try {
            if (!emarsysContactSubscriptions.isEmpty()) {
                Emarsys_Contact_Subscriptions__c emarsysContactSubscription = emarsysContactSubscriptions.get(0);
                String emarsysAccount = GlobalUtils.getEmarsysAccount(GlobalUtils.EmarsysAccounts.AccountRus.name());
                String contactsListingResponse = EmarsysWebService.getListingContactsInSegment(emarsysContactSubscription.Segment_Id__c, emarsysAccount);

                if (!contactsListingResponse.contains('"data":""')) {
                    scheduleRusReactionJob(1); // restart in 1 minute

                    List<AsyncApexJob> currentJob = [SELECT Id, ApexClassId FROM AsyncApexJob WHERE Id = :bc.getJobId()];
                    if (currentJob.size() != 0) {
                        List<AsyncApexJob> existingJob = [
                                SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems
                                FROM AsyncApexJob
                                WHERE ApexClassId = :currentJob.get(0).ApexClassId
                                AND (Status = 'Processing' OR Status = 'Preparing' OR Status = 'Queued' OR Status = 'Holding')
                                AND Id != :bc.getJobId()
                                LIMIT 1
                        ];
                        if (existingJob.size() != 0) {
                            isBatchInProgress = true;
                        }
                    }

                    if (!isBatchInProgress) {
                        emarsysResponse = (EmarsysListingContactsEntity) JSON.deserialize(contactsListingResponse, EmarsysListingContactsEntity.class);
                        contactsListing = emarsysResponse.data;
                        canUpdateSegmentDate = true;
                        System.debug('DEBUG CONTACTS FROM EMARSYS ===' + contactsListing);
                    }
                } else {
                    scheduleRusReactionJob(5);
                }
            }
        } catch (Exception e) {
            ExceptionLogger.sendException(String.valueOf(e.getMessage()), String.valueOf(e.getStackTraceString()));
        }
        return contactsListing;
    }

    /*******************************************************************************
     *  Name            : scheduleRusReactionJob()
     *  Summary         : schedule next job
     *  CreatedDate     : 18/10/2017
     *  Parameters      : Integer minute
     *  Returns         : void
     ******************************************************************************/
    public void scheduleRusReactionJob(Integer minute) {
        List<CronTrigger> jobsList = [
                SELECT Id
                FROM CronTrigger
                WHERE CronJobDetail.Name LIKE 'Emarsys Reaction Logs%' AND PreviousFireTime != null
                LIMIT 100
        ];
        if (!jobsList.isEmpty()) {
            for (CronTrigger job : jobsList) {
                System.abortJob(job.Id);
            }
        }

        String schedule = datetime.now().addMinutes(minute).second() + ' ' + datetime.now().addMinutes(minute).minute() + ' 6-18' + ' ?'
                + ' *' + ' MON-FRI';
        EmarsysRusReactionLogsSchedule scheduledCreatingLogs = new EmarsysRusReactionLogsSchedule();
        System.schedule('Emarsys Reaction Logs reschedule ' + datetime.now().addMinutes(minute).hour() + ':' + datetime.now().addMinutes(minute).minute() + ':' + datetime.now().addMinutes(minute).second(),
                schedule,
                scheduledCreatingLogs);
    }


    /*******************************************************************************
    *  Name            : List<Emarsys_Contact_Subscriptions__c> getEmarsysSubscriptionSegments()
    *  Summary         : Get Emarsys Contact Subscription Segments from Custom Settings
    *  CreatedDate     : 13/10/2017
    *  Parameters      : -
    *  Returns         : List<Emarsys_Contact_Subscriptions__c>
    *****************************************************************************/
    @TestVisible
    private List<Emarsys_Contact_Subscriptions__c> getEmarsysSubscriptionSegments() {
        List<Emarsys_Contact_Subscriptions__c> listEmarsysSubscriptions = [
                SELECT Email_Name__c, Subscription_Name__c, Segment_Id__c, Type__c
                FROM Emarsys_Contact_Subscriptions__c
                ORDER BY Last_Update_Segment_Date__c
                LIMIT 1
        ];
        return listEmarsysSubscriptions;
    }

    /*******************************************************************************
    *  Name            : getRussianRecordTypesIdsSet()
    *  Summary         : return Russian Record Types
    *  CreatedDate     : 12/10/2017
    *  Parameters      : -
    *  Returns         : Set<Id>
    ******************************************************************************/
    @TestVisible
    private Set<Id> getRussianRecordTypesIdsSet() {
        Set<Id> recordTypesIds = new Set<Id>();
        List<RecordType> recordTypesList = [
                SELECT Id
                FROM RecordType
                WHERE Name = 'Russian Sales' AND (SObjectType = 'Lead' OR SObjectType = 'Opportunity')
        ];
        for (RecordType recordType : recordTypesList) {
            recordTypesIds.add(recordType.Id);
        }
        return recordTypesIds;
    }

    /*******************************************************************************
    *  Name            : returnSObjectsList(Emarsys_Contact_Subscriptions__c emarsysContactSubscription, Set<Id> recordTypesIds, List<String> contactsIds)
    *  Summary         : return sObjetcs List
    *  CreatedDate     : 12/10/2017
    *  Parameters      : Emarsys_Contact_Subscriptions__c emarsysContactSubscription - subscription from custom setting
                         Set<Id> recordTypesIds - supported record types ids set
                         List<String> contactsIds - contacts listing from Emarsys
    *  Returns         : List<SObject> parentSObjectsList
    ******************************************************************************/
    public List<SObject> returnSObjectsList(Emarsys_Contact_Subscriptions__c emarsysContactSubscription, Set<Id> recordTypesIds, List<String> contactsIds) {
        parentSObjectsList = new List<SObject>();
        if (emarsysContactSubscription.Type__c == 'Lead') {
            parentSObjectsList = [
                    SELECT Name, OwnerId, Emarsys_Contact_Id__c, (
                            SELECT Id
                            FROM Emarsys_Logs__r
                            WHERE (Email_Name__c = :emarsysContactSubscription.Subscription_Name__c OR Segment_Name__c = :emarsysContactSubscription.Subscription_Name__c)
                            LIMIT 1
                    )
                    FROM Lead
                    WHERE RecordTypeId IN :recordTypesIds AND Emarsys_Contact_Id__c IN :contactsIds AND Active_owner__c = true
            ];
        } else if (emarsysContactSubscription.Type__c == 'Opportunity') {
            parentSObjectsList = [
                    SELECT Name, OwnerId, Emarsys_Contact_Id__c, (
                            SELECT Id
                            FROM Emarsys_Logs__r
                            WHERE (Email_Name__c = :emarsysContactSubscription.Subscription_Name__c OR Segment_Name__c = :emarsysContactSubscription.Subscription_Name__c)
                            LIMIT 1
                    )
                    FROM Opportunity
                    WHERE RecordTypeId IN :recordTypesIds AND Emarsys_Contact_Id__c IN :contactsIds AND Owner.IsActive = true
            ];
        }

        return parentSObjectsList;
    }

    /*******************************************************************************
    *  Name            : getEmailCampaignData()
    *  Summary         : get Email Campaign id and name from Emarsys
    *  CreatedDate     : 12/10/2017
    *  Parameters      : Map<String, EmarsysEmailHistoryEntity.Data> emailsLaunchDataMap - email history data from Emarsys
    *  Returns         : void
    ******************************************************************************/
    private void getEmailCampaignData(Map<String, EmarsysEmailHistoryEntity.Data> emailsLaunchDataMap) {
        Set<String> emailIdsSet = new Set<String>();
        for (String contactId : emailsLaunchDataMap.keySet()) {
            emailIdsSet.add(String.valueOf(emailsLaunchDataMap.get(contactId).emailId));
        }

        for (String emailId : emailIdsSet) {
            String emailDataResponseBody = sendEmailCampaignDataRequest(emailId);
            EmarsysGetEmailDataEntity.JSON2Apex emailData = EmarsysGetEmailDataEntity.parse(emailDataResponseBody);
            if (emailData.data.name.contains(emailName)) {
                currentEmailId = emailId;
                currentHtmlSource = emailData.data.html_source;
                break;
            }
            System.debug('DEBUG CURRENT EMAIL ID ===' + currentEmailId);
        }
    }

    /*******************************************************************************
    *  Name            : sendEmailCampaignDataRequest(String emailId)
    *  Summary         : send request
    *  CreatedDate     : 12/10/2017
    *  Parameters      : String emailId - id of email for receiving data
    *  Returns         : String
    ******************************************************************************/
    private String sendEmailCampaignDataRequest(String emailId) {
        String endPointGetEmailName = 'https://suite15.emarsys.net/api/v2/email/' + emailId;
        String emarsysAccount = GlobalUtils.getEmarsysAccount(GlobalUtils.EmarsysAccounts.AccountRus.name());
        HttpRequest emailDataRequest = EmarsysWebService.generateEmailDataRequest(endPointGetEmailName, emarsysAccount);
        Http http = new Http();
        HTTPResponse emailDataResponse = http.send(emailDataRequest);
        return emailDataResponse.getBody();
    }

    /*******************************************************************************
    *  Name            : generateSObjectToOwnerManagerMap()
    *  Summary         : generate SObject To Owner Manager (for getting his email) Map
    *  CreatedDate     : 12/10/2017
    *  Parameters      : -
    *  Returns         : Map<Id, String> sObjectToOwnerManagerMap
    ******************************************************************************/
    public Map<Id, String> generateSObjectToOwnerManagerMap() {
        Map<Id, String> sObjectToOwnerManagerMap = new Map<Id, String>();
        Set<Id> sObjectsOwnersIdsSet = new Set<Id>();
        for (SObject currentSObject : parentSObjectsList) {
            if (String.valueOf(currentSObject.get('OwnerId')).substring(0, 3) == '005') {
                sObjectsOwnersIdsSet.add(String.valueOf(currentSObject.get('OwnerId')));
            }
        }

        List<User> sObjectOwners = [
                SELECT Manager.Email
                FROM User
                WHERE Id IN :sObjectsOwnersIdsSet
        ];
        for (User user : sObjectOwners) {
            if (user.Manager != null) {
                sObjectToOwnerManagerMap.put(user.Id, user.Manager.Email);
            }
        }

        return sObjectToOwnerManagerMap;
    }
}