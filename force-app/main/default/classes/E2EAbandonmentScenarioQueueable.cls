public with sharing class E2EAbandonmentScenarioQueueable implements Queueable,Database.AllowsCallouts{

    public List<Opportunity> listOpportunities;
/*
 Contact details                  --> activeStep == 0
  --------------------Case 1----------------------------------
 Company Details                  --> activeStep == 1, activeSubStep = 'Search company'
 Company Confirmation             --> activeStep == 1, activeSubStep = 'Another Tax ID'
 Fuel Consumption                 --> activeStep == 1, activeSubStep == 'Set total consumption'
 ---------------------Cas3 2----------------------------------
 Credit Offer                     --> activeStep == 1, activeSubStep = 'Calculating credit score'
 ---------------------Case 3----------------------------------
 Card Commercial Options          --> activeStep == 2, activeSubStep = 'Card configuration'
 Special Offer                    --> activeStep == 2, activeSubStep = 'Choosing offer'
 Card configuration (Technical )  --> activeStep == 2, activeSubStep = 'Technical parameters'
 ---------------------Case 4----------------------------------
 Value Added Services             --> activeStep == 3
 ---------------------Case 5----------------------------------
 Payment Options                  --> activeStep == 4, activeSubStep in 'DirectDebit' 'BankTransferDeposit' 'BankTransfer' 'DirectDebitDeposit'
 -------------------------------------------------------------
 Thank you for your order         --> activeStep == 4, activeSubStep = 'Congratulation'
*/
    public E2EAbandonmentScenarioQueueable(List<Opportunity> opportunities){
        listOpportunities = opportunities;
    }

    /*******************************************************************************
    *  Name            : updateAbandonmentStatus
    *  Summary         : update on Opportunity e2e_Abandonment_Status from E2EAbandonmentScenarioBatch
    *  CreatedDate     : 24/04/2018
    *  Parameters      : (List<Opportunity> listOpportunities)
    *  Returns         : void
    ******************************************************************************/
    public  void execute(QueueableContext qc) {
        try {
            List<User> e2eRuGuestUser = [
                    SELECT Id, Name
                    FROM User
                    WHERE Name = 'E2E RU Site Guest User'
                    LIMIT 1
            ];

            List<RecordType> russiaRecordType = [
                    SELECT id, name
                    FROM RecordType
                    WHERE Name = 'Russian Sales'
                    AND SobjectType = 'Opportunity'
            ];

            List<String> emailTargetsE2EManualRu = new List<String>();
            if(E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu') != null) {
                List<String> managers = GlobalUtils.blankStringIfNull(
                        E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu').Main_Managers__c +
                                E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu').Call_Center_Managers__c).split(';');
                for (User user : [SELECT Id, Name, Email FROM User WHERE Name IN :managers LIMIT 250]) {
                    emailTargetsE2EManualRu.add(user.Email);
                }
            }

            Set<Id> opportunityIds = new Set<Id>();
            for(Opportunity opportunity : listOpportunities) {
                opportunityIds.add(opportunity.Id);
            }

            Map<Id, E2EFormData__c> opportunityFormDataRelateMap = new Map<Id, E2EFormData__c>();
            for (E2EFormData__c formData :  [
                    SELECT Id, E2E_Opportunity_Id__c, E2E_Manual_Entry__c, E2E_Manual_Entry_Legal_Info__c
                    FROM E2EFormData__c
                    WHERE E2E_Opportunity_Id__c IN :opportunityIds
                    LIMIT 1000]) {
                opportunityFormDataRelateMap.put(formData.E2E_Opportunity_Id__c, formData);
            }

            List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
            List<Messaging.Email> emails = new List<Messaging.Email>();
            for (Opportunity opportunity: listOpportunities) {
                if(opportunity.RecordTypeId == russiaRecordType.get(0).Id){
                    Datetime timeToAbandonAndEmail = Datetime.valueOf(opportunity.E2E_Last_Activity__c).addMinutes(60);
                    Datetime timeToManual = Datetime.valueOf(opportunity.E2E_Last_Activity__c).addMinutes(420);

                    if(system.now() > timeToAbandonAndEmail &&  opportunity.E2E_Status__c == 'Клиент Активен'){
                        opportunity.E2E_Status__c = 'Клиент не активен';
                        if( !opportunitiesToUpdate.contains(opportunity) )   opportunitiesToUpdate.add(opportunity);
                    }

                    if (opportunity.IsClosed == false) {
                        if (system.now() > timeToAbandonAndEmail && system.now() < timeToManual) {
                            if(opportunity.E2E_Sub_Status__c != 'Автоматическое письмо' && opportunity.E2E_Sub_Status__c != 'Перевод в ручную обработку'){
                                opportunity.E2E_Sub_Status__c = 'Автоматическое письмо';
                                if( !opportunitiesToUpdate.contains(opportunity) )   opportunitiesToUpdate.add(opportunity);
                            }
                        }
                        else if ( system.now() > timeToManual ){
                            if (opportunity.E2E_Sub_Status__c != 'Перевод в ручную обработку'){
                                opportunity.E2E_Sub_Status__c = 'Перевод в ручную обработку';
                                if( !opportunitiesToUpdate.contains(opportunity) )   opportunitiesToUpdate.add(opportunity);

                                if (opportunity.E2E_Sales_Type__c != 'E2E с участием Inbound' && opportunity.OwnerId == e2eRuGuestUser.get(0).Id) {

                                    String manualEntryMessage = '';
                                    if (opportunityFormDataRelateMap.containsKey(opportunity.Id)) {
                                        E2EFormData__c formData = opportunityFormDataRelateMap.get(opportunity.Id);
                                        if (formData.E2E_Manual_Entry__c == true || formData.E2E_Manual_Entry_Legal_Info__c == true) {
                                            manualEntryMessage = '<p>Клиент выполнил ручную корректировку данных на форме</p>';
                                        }
                                    }

                                    emails.add(EmailGenerator.prepareHtmlEmailToTarget(
                                            emailTargetsE2EManualRu,
                                            'E2E Возможность неактивна',
                                            '<p>Возможность с E2E формы стала неактивна (клиент остановил заполнение формы)</p>' +
                                                    '<p>Статус возможности = "' +  opportunity.E2E_Sub_Status__c + '"</p>' +
                                                    manualEntryMessage +
                                                    '<p>Пожалуйста посмотрите информацию об это возможности по ссылке: ' +
                                                    '<a href ="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + opportunity.id + '" >' + opportunity.Name + '</a></p>'));
                                }
                            }
                        }
                    }

                    if (opportunity.E2E_Sub_Status__c == 'Перевод в ручную обработку' && opportunity.E2E_Sales_Type__c == 'Чистый e2e'){
                        opportunity.E2E_Sales_Type__c = 'Чистый e2e + помощь КЦ';
                        if( !opportunitiesToUpdate.contains(opportunity) )   opportunitiesToUpdate.add(opportunity);
                    }
                }
                else {
                    E2E_Form_General_Settings__c settings = E2E_Form_General_Settings__c.getInstance(opportunity.account.BillingCountry);
                    if (settings != null && settings.Abandonment_User__c != null) {
                        opportunity.OwnerId = settings.Abandonment_User__c;
                    }
                    Datetime timeToStart = Datetime.valueOf(opportunity.E2E_Last_Activity__c).addMinutes(30);
                    if (system.now() > timeToStart && opportunity.E2E_Status__c != 'Abandoned (hard)' && opportunity.E2E_Sub_Status__c != 'Marketing automation') {
                        opportunity.E2E_Status__c = 'Abandoned (hard)';
                        opportunity.E2E_Sub_Status__c = 'Marketing automation';
                        opportunitiesToUpdate.add(opportunity);
                    }
                }
            }
            if (opportunitiesToUpdate.size() != 0){
                update opportunitiesToUpdate;
            }
            if (emails.size() != 0) {
                Messaging.sendEmail(emails);
            }
        } catch (Exception e){
            String notificationMessage = '<br/>E2EAbandonmentScenario Exception: E2EAbandonmentScenarioQueueable ' + String.valueOf(e.getMessage());
            ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
        }
    }
}