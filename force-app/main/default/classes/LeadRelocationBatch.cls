global class LeadRelocationBatch implements Database.Batchable<sObject> {
    public String query;
    public Date myDate;
    private Set<String> RWLlistid = new Set<String>();
    private Datetime correctDatetime;
    private Id russianQueueId;
    private Set<String> countriesSet = new Set<String>{
        'Austria',
        'Germany',
        'France',
        'Hungary',
        'Netherlands',
        'Poland',
        'Belgium-NL',
        'Belgium-FR',
        'Switzerland-DE',
        'Switzerland-IT',
        'Switzerland-FR',
        'Luxembourg',
        'Czech Republic',
        'Slovakia',
        'Russia'
    };

    global LeadRelocationBatch() {
        this.query ='';
        Boolean ExecuteJobInBerlin=false;
        Boolean ExecuteJobInMoscow=false;

        Datetime GMTDate = Datetime.newInstanceGmt(
            datetime.now().yearGmt(), datetime.now().monthGmt(), datetime.now().dayGmt(),
            datetime.now().hourGmt(), datetime.now().minuteGmt(), 0);
        Integer HourBerlin = Integer.valueOf(GMTDate.format('HH','Europe/Berlin'));
        Integer HourMoscow = Integer.valueOf(GMTDate.format('HH','Europe/Moscow'));

        if ((HourBerlin >= 8) && (HourBerlin <= 17)) ExecuteJobInBerlin = true;
        if ((HourMoscow >= 8) && (HourMoscow <= 17)) ExecuteJobInMoscow = true;
        if (Test.isRunningTest()) {
            ExecuteJobInBerlin = true;
            ExecuteJobInMoscow = true;
        }

        if (ExecuteJobInBerlin || ExecuteJobInMoscow) {
            this.query = 'SELECT Owner.Email, Status, CreatedDate, Sec_Channel__c, OwnerId, Last_Owner_Change_Date__c, Channel__c,' +
                    '       LeadSource, Country, Salutation, CountryCode, RecordType.Name, Is_External__c, Lead_Source_type__c, Anzahl_der_Fahrzeuge__c, CCS_number_of_cards__c, ' + 
                    '       Recycle_counter__c, Quali_Status__c, ' +
                    '       (SELECT OldValue, NewValue FROM Histories WHERE Field = \'Quali_Status__c\') ' +
                    'FROM Lead ' +
                    'WHERE  isConverted = FALSE AND ' +
                    '       Last_Owner_Change_Date__c != NULL AND ' +
                    '       Country IN :countriesSet  AND ' +
                    '       RecordType.Name != \'CCS Sales process\' AND ' +
                    '       (Recycle_counter__c = 0 OR Recycle_counter__c = null) AND ' +
                    '(';
            if (ExecuteJobInBerlin) {
                myDate = date.newinstance(2016, 3, 30);
                this.query +=
                    '   ( ' +
                    '     ((Sec_Channel__c = \'Inbound\' AND (Channel__c = \'Internet\' OR Channel__c = \'E-mail\')) OR ' +
                    '      (Sec_Channel__c = \'JITB\' AND Channel__c = \'Internet\') OR (Sec_Channel__c = \'Partner\')) AND ' +
                    '       Status = \'Open\'  AND ' +
                    '       First_Call__c = NULL AND ' +
                    '       LeadSource != \'Online_chat\' AND ' +
                    '       CreatedDate >= :myDate ' +
                    '   ) OR';
            }
            if (ExecuteJobInMoscow) {
                RWLlistid.clear();
                List<Group> russianQueue = [
                        SELECT Id
                        FROM Group 
                        WHERE Name = 'Russian Web Leads'];
                if ( ! russianQueue.isEmpty() ) {
                    RWLlistid.add(russianQueue.get(0).Id);
                    russianQueueId = russianQueue.get(0).Id;
                }
                for (GroupMember gm : [Select UserOrGroupId From GroupMember where Group.name = 'Russian Web Leads']) {
                    RWLlistid.add(gm.UserOrGroupId);
                }
                correctDatetime = System.now().addMinutes(-9);
                this.query +=
                    '   ( ' +
                    '        OwnerId IN :RWLlistid AND ' +
                    '        Status = \'NEW - Not Yet Contacted\' AND ' +
                    '       (Last_Owner_Change_Date__c <= :correctDatetime OR OwnerId = :russianQueueId ) AND ' +
                    '       (Lead_Source_Type__c = \'Webform\' OR Lead_Source_Type__c = \'Popup\' OR ' +
                    '        Lead_Source_Type__c = \'Chat\'    OR Lead_Source_Type__c = \'Email\') ' +
                    '   ) ';
            }
            this.query = this.query.removeEnd('OR');
            this.query += ') ';
        } else {
            this.query = 'SELECT id,name FROM Lead WHERE id=\'0BLANKIDBLANKID\'';
        }
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Sobject> scope) {
        LeadRelocationService.customLeadAssignBatch(scope);
        LeadHandler.isSwitchToE2E = false;
        update scope;
    }

    global void finish(Database.BatchableContext BC)  {}
}