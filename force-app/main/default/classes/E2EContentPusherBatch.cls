global class E2EContentPusherBatch implements Database.Batchable<sObject> {
    public String query;

    global E2EContentPusherBatch() {
        this.query = 'SELECT id FROM E2E_Regex__c LIMIT 1';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Sobject> scope) {
        StaticResource s0 = [SELECT Body FROM StaticResource WHERE Name = 'contactDetails_de'];      
        StaticResource s1 = [SELECT Body FROM StaticResource WHERE Name = 'search_company_de'];      
        StaticResource s2 = [SELECT Body FROM StaticResource WHERE Name = 'tax_id_de'];      
        StaticResource s3 = [SELECT Body FROM StaticResource WHERE Name = 'total_consumption_de'];      
        StaticResource s4 = [SELECT Body FROM StaticResource WHERE Name = 'credit_scoring_de'];      
        StaticResource s5 = [SELECT Body FROM StaticResource WHERE Name = 'cards_configuration_de'];      
        StaticResource s6 = [SELECT Body FROM StaticResource WHERE Name = 'offer_selection_de'];      
        StaticResource s7 = [SELECT Body FROM StaticResource WHERE Name = 'technical_parameters_de'];      
        StaticResource s8 = [SELECT Body FROM StaticResource WHERE Name = 'additional_parameters_de'];      
        StaticResource s9 = [SELECT Body FROM StaticResource WHERE Name = 'payment_options_de'];      
        StaticResource s10 = [SELECT Body FROM StaticResource WHERE Name = 'deposit_options_de'];      
        StaticResource s11 = [SELECT Body FROM StaticResource WHERE Name = 'congratulations_de'];  

        StaticResource s00 = [SELECT Body FROM StaticResource WHERE Name = 'E2EContactDetailsCSS'];      
        StaticResource s01 = [SELECT Body FROM StaticResource WHERE Name = 'E2ESearchCompanyCSS'];      
        StaticResource s02 = [SELECT Body FROM StaticResource WHERE Name = 'E2ETaxIdCSS'];      
        StaticResource s03 = [SELECT Body FROM StaticResource WHERE Name = 'E2ETotalConsumptionCSS'];      
        StaticResource s04 = [SELECT Body FROM StaticResource WHERE Name = 'E2ECreditScoringCSS'];      
        StaticResource s05 = [SELECT Body FROM StaticResource WHERE Name = 'E2ECardsConfigurationCSS'];      
        StaticResource s06 = [SELECT Body FROM StaticResource WHERE Name = 'E2EOfferSelectionCSS'];      
        StaticResource s07 = [SELECT Body FROM StaticResource WHERE Name = 'E2ETechnicalParametersCSS'];      
        StaticResource s08 = [SELECT Body FROM StaticResource WHERE Name = 'E2EAdditionalParametersCSS'];      
        StaticResource s09 = [SELECT Body FROM StaticResource WHERE Name = 'E2EPaymentOptionsCSS'];      
        StaticResource s010 = [SELECT Body FROM StaticResource WHERE Name = 'E2EDepositOptionsCSS'];      
        StaticResource s011 = [SELECT Body FROM StaticResource WHERE Name = 'E2ECongratulationsCSS']; 

        StaticResource s000 = [SELECT Body FROM StaticResource WHERE Name = 'E2EContactDetailsScripts'];      
        StaticResource s001 = [SELECT Body FROM StaticResource WHERE Name = 'E2ESearchCompanyScripts'];      
        StaticResource s002 = [SELECT Body FROM StaticResource WHERE Name = 'E2ETaxIdScripts'];      
        StaticResource s003 = [SELECT Body FROM StaticResource WHERE Name = 'E2ETotalConsumptionScripts'];      
        StaticResource s004 = [SELECT Body FROM StaticResource WHERE Name = 'E2ECreditScoringScripts'];      
        StaticResource s005 = [SELECT Body FROM StaticResource WHERE Name = 'E2ECardsConfigurationScripts'];      
        StaticResource s006 = [SELECT Body FROM StaticResource WHERE Name = 'E2EOfferSelectionScripts'];      
        StaticResource s007 = [SELECT Body FROM StaticResource WHERE Name = 'E2ETechnicalParametersScripts'];      
        StaticResource s008 = [SELECT Body FROM StaticResource WHERE Name = 'E2EAdditionalParametersScripts'];      
        StaticResource s009 = [SELECT Body FROM StaticResource WHERE Name = 'E2EPaymentOptionsScripts'];      
        StaticResource s0010 = [SELECT Body FROM StaticResource WHERE Name = 'E2EDepositOptionsScripts'];      
        StaticResource s0011 = [SELECT Body FROM StaticResource WHERE Name = 'E2ECongratulationsScripts']; 
    }

    global void finish(Database.BatchableContext BC) {
        // Schedule next run
        String day = String.valueOf(System.now().day());
        String month = String.valueOf(System.now().month());
        String hour = String.valueOf(System.now().hour());
        String minute = String.valueOf(System.now().minute() + 2);
        if (minute == '61') {
            minute = '1';
            hour = doNextHour(hour);
        } else if (minute == '60') {
            minute = '0';
            hour = doNextHour(hour);
        }
        String second = String.valueOf(System.now().second());
        String year = String.valueOf(System.now().year());
        
        String strJobName = 'E2EContentPusher-' + hour + ':' + minute + ':' + second + '_' + day + '.' + month + '.' + year;
        String strSchedule = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
        System.schedule(strJobName, strSchedule, new E2EContentPusher());

        List<CronTrigger> currentJobs = [
                SELECT CronJobDetail.Name,
                       CronJobDetail.Id, State
                FROM CronTrigger 
                WHERE CronJobDetail.Name LIKE 'E2EContentPusher-%' 
                LIMIT 1];
        if ( ! currentJobs.isEmpty() ) {
            for (CronTrigger job : currentJobs) {
                System.abortJob(job.Id);
            }            
        }
    }

    public static String doNextHour(String hour) {
        if (hour == '23') {
            return '0';
        }
        Integer nextHour = Integer.valueOf(hour);
        nextHour++;
        
        return String.valueOf(nextHour);
    }
}