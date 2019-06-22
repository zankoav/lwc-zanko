@isTest
private class BatchCheckingAdoptionProcessTest {

    /******************************************************************************
    *  Name            : testCheckingAdoptionProcess()
    *  Summary         : test checking adoption process    
    *  CreatedDate     : 14/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testCheckingAdoptionProcess() {
        Test.startTest();
            createLeads();
            createCustomSettings();

            BatchCheckingAdoptionProcess batch = new BatchCheckingAdoptionProcess();
            Database.executeBatch(batch);
        Test.stopTest();

        List<Lead> leadsList = [SELECT Quali_Status__c FROM Lead];
        for (Lead lead : leadsList) {
            System.assertEquals(null, lead.Quali_Status__c);
        }
    }


    /******************************************************************************
    *  Name            : createLeads()
    *  Summary         : create data for test (leads)    
    *  CreatedDate     : 14/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private static void createLeads() {
        List<Lead> leadsToInsertList = new List<Lead>();
        Lead l1 = new Lead(
            LastName = 'test1',
            Country = 'Germany',
            CountryCode = 'DE',
            Quali_Status__c = 'Switched to E2E',
            Sec_Channel__c = 'Inbound',
            Channel__c = 'Internet',
            Phone = '1231231111',
            Company = 'test3');
        leadsToInsertList.add(l1);

        Lead l2 = new Lead(
            LastName = 'test2',
            Country = 'Netherlands',
            CountryCode = 'NL',
            Quali_Status__c = 'Switched to E2E',
            Sec_Channel__c = 'Inbound',
            Channel__c = 'Internet',
            Phone = '1231231222',
            Company = 'test3');
        leadsToInsertList.add(l2);

        Lead l3 = new Lead(
            LastName = 'test3',
            Country = 'Belgium-NL',
            CountryCode = 'BENL',
            Quali_Status__c = 'Switched to E2E',
            Sec_Channel__c = 'Inbound',
            Channel__c = 'Internet',
            Phone = '1231231333',
            Company = 'test3');
        leadsToInsertList.add(l3);

        Lead l4 = new Lead(
            LastName = 'test1',
            Country = 'Germany',
            CountryCode = 'DE',
            Quali_Status__c = 'Switched to E2E',
            Sec_Channel__c = 'JITB',
            Channel__c = 'Internet',
            Phone = '1231231111',
            Company = 'test3');
        leadsToInsertList.add(l4);        

        insert leadsToInsertList;
    }


    /******************************************************************************
    *  Name            : createCustomSettings()
    *  Summary         : create custom setting for test of checking adoption process     
    *  CreatedDate     : 14/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private static void createCustomSettings() {
        List<Adoption_Process_Settings__c> csToInsertList = new List<Adoption_Process_Settings__c>();
        Adoption_Process_Settings__c cs1 = new Adoption_Process_Settings__c(
            Name = 'Germany',
            Number_Of_Days_To_Reassign__c = 5,
            Queue_Name__c = 'LeadAssignDE'
        );
        csToInsertList.add(cs1);

        Adoption_Process_Settings__c cs2 = new Adoption_Process_Settings__c(
            Name = 'Netherlands',
            Number_Of_Days_To_Reassign__c = 5,
            Queue_Name__c = 'LeadAssignNL'
        );
        csToInsertList.add(cs2);

        Adoption_Process_Settings__c cs3 = new Adoption_Process_Settings__c(
            Name = 'Belgium-NL',
            Number_Of_Days_To_Reassign__c = 5,
            Queue_Name__c = 'LeadAssignBE_NL'
        );
        csToInsertList.add(cs3);

        Adoption_Process_Settings__c cs4 = new Adoption_Process_Settings__c(
            Name = 'GermanyJITB',
            Number_Of_Days_To_Reassign__c = 5,
            Queue_Name__c = 'LeadAssignDEJITB'
        );
        csToInsertList.add(cs4);        

        insert csToInsertList;
    }  
}