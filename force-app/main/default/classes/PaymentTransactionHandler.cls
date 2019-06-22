public without sharing class PaymentTransactionHandler {

    /*******************************************************************************
    *  Name            : updateTransactionConfiramtion
    *  Summary         : update parent opportunity field after payment transaction are confirmed
    *  CreatedDate     : 28.02.2018
    *  ModifiedDate    : 28.02.2018
    *  Parameters      : --
    *  Returns         : --
    ******************************************************************************/
    public static void updateTransactionConfirmation(Map<Id, Payment_Transaction__c> oldMap, Map<Id, Payment_Transaction__c> newMap){
        try {
            Set<Id> relatedOpportunitiesIds = new Set<id>();
            for (Payment_Transaction__c newPaymentTransaction : newMap.values()) {
                relatedOpportunitiesIds.add(newPaymentTransaction.OpportunityId__c);
            }
            Map<Id, Opportunity> relatedOpportunities = new Map<Id, Opportunity>([
                    SELECT id, Security_Amount_To_Pay__c, Security_To_Pay__c, Garantie__c, Garantie_other__c, E2E_payment_status__c, StageName, Starts_Status__c, Registered_Country__c
                    FROM Opportunity
                    WHERE id in :relatedOpportunitiesIds
            ]);

            List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
            for (Payment_Transaction__c newPaymentTransaction : newMap.values()) {
                Payment_Transaction__c oldPaymentTransaction = oldMap.get(newPaymentTransaction.Id);
                if ((newPaymentTransaction.Authorized__c != oldPaymentTransaction.Authorized__c) &&
                        (newPaymentTransaction.Authorized__c == TRUE)) {
                    Opportunity currentOpportunity = relatedOpportunities.get(newPaymentTransaction.OpportunityId__c);
                    if (currentOpportunity != null){
                        if ((currentOpportunity.Security_Amount_To_Pay__c == newPaymentTransaction.Amount__c) && (newPaymentTransaction.Status__c == '9')) {
                            E2E_Form_General_Settings__c settings = E2E_Form_General_Settings__c.getInstance(currentOpportunity.Registered_Country__c);
                            if (settings.Enable_authorization_non_granted_check__c) {
                                currentOpportunity.Starts_Status__c = '0.9 Ready for GFN';
                            }
                            currentOpportunity.Garantie_other__c = currentOpportunity.Security_Amount_To_Pay__c;
                            currentOpportunity.Garantie__c = currentOpportunity.Security_To_Pay__c;
                            currentOpportunity.StageName = 'Closed Won';
                        }

                        if((newPaymentTransaction.Status__c == '5') || (newPaymentTransaction.Status__c == '9')){
                            currentOpportunity.E2E_payment_status__c = 'ACCEPT';
                        }
                        else if(newPaymentTransaction.Status__c == '1'){
                            currentOpportunity.E2E_payment_status__c = 'CANCEL';
                        }
                        else if((newPaymentTransaction.Status__c == '2') || (newPaymentTransaction.Status__c == '93')) {
                            currentOpportunity.E2E_payment_status__c = 'DECLINE';
                        }
                        else if(newPaymentTransaction.Status__c.substring(1,2) == '2') {
                            currentOpportunity.E2E_payment_status__c = 'EXCEPTION';
                        }
                        opportunitiesToUpdate.add(currentOpportunity);
                    }
                    else {
                        ExceptionLogger.sendException('PaymentTransactionHandler Exception: Payment_Transaction__c ID=' +newPaymentTransaction.id,
                                ' Update transaction with Opportunity = "null"');
                    }
                }
            }
            if (opportunitiesToUpdate.size() != 0) {
                update opportunitiesToUpdate;
            }
        }
        catch (Exception e){
            ExceptionLogger.sendException('PaymentTransactionHandler '+String.valueOf(e.getMessage()), String.valueOf(e.getStackTraceString()));
        }
    }

}