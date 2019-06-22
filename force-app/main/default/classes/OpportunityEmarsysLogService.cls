public class OpportunityEmarsysLogService {
	/*******************************************************************************
	*  Name            : checkOpportunities(List<Opportunity> oppList)
	*  Summary         : Check emarsys logs in opportunities    
	*  CreatedDate     : 11/04/2019
	*  ModifiedDate    : -
	*  Parameters      : List<Opportunity> oppList - list opportunities from batch
	*  Returns         : List<Opportunity>
	******************************************************************************/
	public List<Opportunity> checkOpportunities(List<Opportunity> oppList) {
		List<Opportunity> opportunitiesWithoutEmarsysLog = new List<Opportunity>();
		for (Opportunity opp : oppList) {
			// Upgraded to E2E 
			if (opp.Account.BillingCountry == 'Germany' && ! opp.OpportunityContactRoles.isEmpty()) {
				if (isManualUpgradedToE2E(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
				} else if (isManualUpgradedToE2E(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					for (Emarsys_Log__c emarsysLog : opp.Emarsys_Logs__r) {
						if (emarsysLog.Email_Name__c != 'E2E Manual Upgrade To E2E DE 1') {
							opportunitiesWithoutEmarsysLog.add(opp);
						}
					}
				}

				if (isDirectDebitNoDeposit(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
				} else if (isDirectDebitNoDeposit(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					for (Emarsys_Log__c emarsysLog : opp.Emarsys_Logs__r) {
						if (emarsysLog.Email_Name__c != 'E2E Order Confirmation DE - 1. Direct Debit - No Deposit') {
							opportunitiesWithoutEmarsysLog.add(opp);
						}
					}
				}

				if (isDirectDebitAccept(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
				} else if (isDirectDebitAccept(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					for (Emarsys_Log__c emarsysLog : opp.Emarsys_Logs__r) {
						if (emarsysLog.Email_Name__c != 'E2E Order Confirmation DE - 2. Direct Debit - ACCEPT') {
							opportunitiesWithoutEmarsysLog.add(opp);
						}
					}
				}

				if (isDirectDebitCancelDecline(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
				} else if (isDirectDebitCancelDecline(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					for (Emarsys_Log__c emarsysLog : opp.Emarsys_Logs__r) {
						if (emarsysLog.Email_Name__c != 'E2E Order Confirmation DE - 3. Direct Debit - CANCEL/DECLINE') {
							opportunitiesWithoutEmarsysLog.add(opp);
						}
					}
				}

				if (isDirectDebitException(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
				} else if (isDirectDebitException(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					for (Emarsys_Log__c emarsysLog : opp.Emarsys_Logs__r) {
						if (emarsysLog.Email_Name__c != 'E2E Order Confirmation DE - 4. Direct Debit - EXCEPTION') {
							opportunitiesWithoutEmarsysLog.add(opp);
						}
					}
				}

				if (isBankTransferNoDeposit(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
				} else if (isBankTransferNoDeposit(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					for (Emarsys_Log__c emarsysLog : opp.Emarsys_Logs__r) {
						if (emarsysLog.Email_Name__c != 'E2E Order Confirmation DE - 5. BT No Deposit') {
							opportunitiesWithoutEmarsysLog.add(opp);
						}
					}
				}

				if (isBankTransferAccept(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
				} else if (isBankTransferAccept(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					for (Emarsys_Log__c emarsysLog : opp.Emarsys_Logs__r) {
						if (emarsysLog.Email_Name__c != 'E2E Order Confirmation DE - 6. BT Accept') {
							opportunitiesWithoutEmarsysLog.add(opp);
						}
					}
				}

				if (isBankTransferCancelDecline(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
				} else if (isBankTransferCancelDecline(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					for (Emarsys_Log__c emarsysLog : opp.Emarsys_Logs__r) {
						if (emarsysLog.Email_Name__c != 'E2E Order Confirmation DE - 7. BT - CANCEL/DECLINE') {
							opportunitiesWithoutEmarsysLog.add(opp);
						}
					}
				}

				if (isBankTransferException(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
				} else if (isBankTransferException(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					for (Emarsys_Log__c emarsysLog : opp.Emarsys_Logs__r) {
						if (emarsysLog.Email_Name__c != 'E2E Order Confirmation DE - 8. BT - EXCEPTION') {
							opportunitiesWithoutEmarsysLog.add(opp);
						}
					}
				}

				if (isAbandonmentScenarios(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
				} else if (isAbandonmentScenarios(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					Datetime campaignEndDate = calculateCampaignEndDate(opp);
					Decimal daysAfterLeadCreation = (opp.CreatedDate.getTime() - campaignEndDate.getTime()) / -86400000;
					for (Emarsys_Log__c emarsysLog : opp.Emarsys_Logs__r) {
						if ((emarsysLog.Email_Name__c != 'E2E Abandonment Email DE 1') || 
							(daysAfterLeadCreation > 2 && daysAfterLeadCreation <= 4 && emarsysLog.Email_Name__c != 'E2E Abandonment Email DE 2') || 
							(daysAfterLeadCreation > 4 && emarsysLog.Email_Name__c != 'E2E Abandonment Email DE 3')) {
							opportunitiesWithoutEmarsysLog.add(opp);
						}
					}
				}

				if (isSaveAndContinueLater(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
				} else if (isSaveAndContinueLater(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					Datetime campaignEndDate = calculateCampaignEndDate(opp);
					Decimal daysAfterLeadCreation = (opp.CreatedDate.getTime() - campaignEndDate.getTime()) / -86400000;
					for (Emarsys_Log__c emarsysLog : opp.Emarsys_Logs__r) {
						if ((emarsysLog.Email_Name__c != 'E2E Save And Continue DE 1') || 
							(daysAfterLeadCreation > 2 && daysAfterLeadCreation <= 4 && emarsysLog.Email_Name__c != 'E2E Save And Continue DE 2') || 
							(daysAfterLeadCreation > 4 && emarsysLog.Email_Name__c != 'E2E Save And Continue DE 3')) {
							opportunitiesWithoutEmarsysLog.add(opp);
						}
					}
				}
			}

			if (opp.Account.BillingCountry == 'Netherlands' && ! opp.OpportunityContactRoles.isEmpty()) {
				if (isManualUpgradedToE2E(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
				} else if (isManualUpgradedToE2E(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					for (Emarsys_Log__c emarsysLog : opp.Emarsys_Logs__r) {
						if (emarsysLog.Email_Name__c != 'E2E Manual Upgrade To E2E NL 1') {
							opportunitiesWithoutEmarsysLog.add(opp);
						}
					}
				}

				if (isOrderConfirmation(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
				} else if (isOrderConfirmation(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					for (Emarsys_Log__c emarsysLog : opp.Emarsys_Logs__r) {
						if (emarsysLog.Email_Name__c != 'E2E Order Confirmation - NL') {
							opportunitiesWithoutEmarsysLog.add(opp);
						}
					}
				}

				if (isAbandonmentScenarios(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
				} else if (isAbandonmentScenarios(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					Datetime campaignEndDate = calculateCampaignEndDate(opp);
					Decimal daysAfterLeadCreation = (opp.CreatedDate.getTime() - campaignEndDate.getTime()) / -86400000;
					for (Emarsys_Log__c emarsysLog : opp.Emarsys_Logs__r) {
						if ((emarsysLog.Email_Name__c != 'E2E Abandonment Email NL 1') || 
							(daysAfterLeadCreation > 2 && daysAfterLeadCreation <= 4 && emarsysLog.Email_Name__c != 'E2E Abandonment Email NL 2') || 
							(daysAfterLeadCreation > 4 && emarsysLog.Email_Name__c != 'E2E Abandonment Email NL 3')) {
							opportunitiesWithoutEmarsysLog.add(opp);
						}
					}
				}

				if (isSaveAndContinueLater(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
				} else if (isSaveAndContinueLater(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					Datetime campaignEndDate = calculateCampaignEndDate(opp);
					Decimal daysAfterLeadCreation = (opp.CreatedDate.getTime() - campaignEndDate.getTime()) / -86400000;
					for (Emarsys_Log__c emarsysLog : opp.Emarsys_Logs__r) {
						if ((emarsysLog.Email_Name__c != 'E2E Save And Continue NL 1') || 
							(daysAfterLeadCreation > 2 && daysAfterLeadCreation <= 4 && emarsysLog.Email_Name__c != 'E2E Save And Continue NL 2') || 
							(daysAfterLeadCreation > 4 && emarsysLog.Email_Name__c != 'E2E Save And Continue NL 3')) {
							opportunitiesWithoutEmarsysLog.add(opp);
						}
					}
				}
			}

			if (opp.Account.BillingCountry == 'Belgium-NL' && ! opp.OpportunityContactRoles.isEmpty()) {
				if (isOrderConfirmation(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
				} else if (isOrderConfirmation(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					for (Emarsys_Log__c emarsysLog : opp.Emarsys_Logs__r) {
						if (emarsysLog.Email_Name__c != 'E2E Order Confirmation - BENL') {
							opportunitiesWithoutEmarsysLog.add(opp);
						}
					}
				}

				if (isAbandonmentScenarios(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
				} else if (isAbandonmentScenarios(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					Datetime campaignEndDate = calculateCampaignEndDate(opp);
					Decimal daysAfterLeadCreation = (opp.CreatedDate.getTime() - campaignEndDate.getTime()) / -86400000;
					for (Emarsys_Log__c emarsysLog : opp.Emarsys_Logs__r) {
						if ((emarsysLog.Email_Name__c != 'E2E Abandonment Email BENL 1') || 
							(daysAfterLeadCreation > 2 && daysAfterLeadCreation <= 4 && emarsysLog.Email_Name__c != 'E2E Abandonment Email BENL 2') || 
							(daysAfterLeadCreation > 4 && emarsysLog.Email_Name__c != 'E2E Abandonment Email BENL 3')) {
							opportunitiesWithoutEmarsysLog.add(opp);
						}
					}
				}

				if (isSaveAndContinueLater(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
				} else if (isSaveAndContinueLater(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					Datetime campaignEndDate = calculateCampaignEndDate(opp);
					Decimal daysAfterLeadCreation = (opp.CreatedDate.getTime() - campaignEndDate.getTime()) / -86400000;
					for (Emarsys_Log__c emarsysLog : opp.Emarsys_Logs__r) {
						if ((emarsysLog.Email_Name__c != 'E2E Save And Continue BENL 1') || 
							(daysAfterLeadCreation > 2 && daysAfterLeadCreation <= 4 && emarsysLog.Email_Name__c != 'E2E Save And Continue BENL 2') || 
							(daysAfterLeadCreation > 4 && emarsysLog.Email_Name__c != 'E2E Save And Continue BENL 3')) {
							opportunitiesWithoutEmarsysLog.add(opp);
						}
					}
				}
			}

			if (opp.Account.BillingCountry == 'Belgium-FR' && ! opp.OpportunityContactRoles.isEmpty()) {
				if (isOrderConfirmation(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
				} else if (isOrderConfirmation(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					for (Emarsys_Log__c emarsysLog : opp.Emarsys_Logs__r) {
						if (emarsysLog.Email_Name__c != 'E2E Order Confirmation - BEFR') {
							opportunitiesWithoutEmarsysLog.add(opp);
						}
					}
				}

				if (isAbandonmentScenarios(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
				} else if (isAbandonmentScenarios(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					Datetime campaignEndDate = calculateCampaignEndDate(opp);
					Decimal daysAfterLeadCreation = (opp.CreatedDate.getTime() - campaignEndDate.getTime()) / -86400000;
					for (Emarsys_Log__c emarsysLog : opp.Emarsys_Logs__r) {
						if ((emarsysLog.Email_Name__c != 'E2E Abandonment Email BEFR 1') || 
							(daysAfterLeadCreation > 2 && daysAfterLeadCreation <= 4 && emarsysLog.Email_Name__c != 'E2E Abandonment Email BEFR 2') || 
							(daysAfterLeadCreation > 4 && emarsysLog.Email_Name__c != 'E2E Abandonment Email BEFR 3')) {
							opportunitiesWithoutEmarsysLog.add(opp);
						}
					}
				}

				if (isSaveAndContinueLater(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
				} else if (isSaveAndContinueLater(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					Datetime campaignEndDate = calculateCampaignEndDate(opp);
					Decimal daysAfterLeadCreation = (opp.CreatedDate.getTime() - campaignEndDate.getTime()) / -86400000;
					for (Emarsys_Log__c emarsysLog : opp.Emarsys_Logs__r) {
						if ((emarsysLog.Email_Name__c != 'E2E Save And Continue BEFR 1') || 
							(daysAfterLeadCreation > 2 && daysAfterLeadCreation <= 4 && emarsysLog.Email_Name__c != 'E2E Save And Continue BEFR 2') || 
							(daysAfterLeadCreation > 4 && emarsysLog.Email_Name__c != 'E2E Save And Continue BEFR 3')) {
							opportunitiesWithoutEmarsysLog.add(opp);
						}
					}
				}
			}

			if (opp.Account.BillingCountry == 'Poland' && ! opp.OpportunityContactRoles.isEmpty()) {
				if (isOrderConfirmation(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
				} else if (isOrderConfirmation(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					for (Emarsys_Log__c emarsysLog : opp.Emarsys_Logs__r) {
						if (emarsysLog.Email_Name__c != 'E2E Order Confirmation - PL') {
							opportunitiesWithoutEmarsysLog.add(opp);
						}
					}
				}

				if (isAbandonmentScenarios(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
				} else if (isAbandonmentScenarios(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					Datetime campaignEndDate = calculateCampaignEndDate(opp);
					Decimal daysAfterLeadCreation = (opp.CreatedDate.getTime() - campaignEndDate.getTime()) / -86400000;
					for (Emarsys_Log__c emarsysLog : opp.Emarsys_Logs__r) {
						if ((emarsysLog.Email_Name__c != 'E2E Abandonment Email PL 1') || 
							(daysAfterLeadCreation > 2 && daysAfterLeadCreation <= 4 && emarsysLog.Email_Name__c != 'E2E Abandonment Email PL 2') || 
							(daysAfterLeadCreation > 4 && emarsysLog.Email_Name__c != 'E2E Abandonment Email PL 3')) {
							opportunitiesWithoutEmarsysLog.add(opp);
						}
					}
				}

				if (isSaveAndContinueLater(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
				} else if (isSaveAndContinueLater(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					Datetime campaignEndDate = calculateCampaignEndDate(opp);
					Decimal daysAfterLeadCreation = (opp.CreatedDate.getTime() - campaignEndDate.getTime()) / -86400000;
					for (Emarsys_Log__c emarsysLog : opp.Emarsys_Logs__r) {
						if ((emarsysLog.Email_Name__c != 'E2E Save And Continue PL 1') || 
							(daysAfterLeadCreation > 2 && daysAfterLeadCreation <= 4 && emarsysLog.Email_Name__c != 'E2E Save And Continue PL 2') || 
							(daysAfterLeadCreation > 4 && emarsysLog.Email_Name__c != 'E2E Save And Continue PL 3')) {
							opportunitiesWithoutEmarsysLog.add(opp);
						}
					}
				}
			}

			if (opp.Account.BillingCountry == 'Hungary' && ! opp.OpportunityContactRoles.isEmpty()) {
				if (isOrderConfirmation(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
				} else if (isOrderConfirmation(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					for (Emarsys_Log__c emarsysLog : opp.Emarsys_Logs__r) {
						if (emarsysLog.Email_Name__c != 'E2E Order Confirmation - HU') {
							opportunitiesWithoutEmarsysLog.add(opp);
						}
					}
				}

				if (isAbandonmentScenarios(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
				} else if (isAbandonmentScenarios(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					Datetime campaignEndDate = calculateCampaignEndDate(opp);
					Decimal daysAfterLeadCreation = (opp.CreatedDate.getTime() - campaignEndDate.getTime()) / -86400000;
					for (Emarsys_Log__c emarsysLog : opp.Emarsys_Logs__r) {
						if ((emarsysLog.Email_Name__c != 'E2E Abandonment Email HU 1') || 
							(daysAfterLeadCreation > 2 && daysAfterLeadCreation <= 4 && emarsysLog.Email_Name__c != 'E2E Abandonment Email HU 2') || 
							(daysAfterLeadCreation > 4 && emarsysLog.Email_Name__c != 'E2E Abandonment Email HU 3')) {
							opportunitiesWithoutEmarsysLog.add(opp);
						}
					}
				}

				if (isSaveAndContinueLater(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
				} else if (isSaveAndContinueLater(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					Datetime campaignEndDate = calculateCampaignEndDate(opp);
					Decimal daysAfterLeadCreation = (opp.CreatedDate.getTime() - campaignEndDate.getTime()) / -86400000;
					for (Emarsys_Log__c emarsysLog : opp.Emarsys_Logs__r) {
						if ((emarsysLog.Email_Name__c != 'E2E Save And Continue HU 1') || 
							(daysAfterLeadCreation > 2 && daysAfterLeadCreation <= 4 && emarsysLog.Email_Name__c != 'E2E Save And Continue HU 2') || 
							(daysAfterLeadCreation > 4 && emarsysLog.Email_Name__c != 'E2E Save And Continue HU 3')) {
							opportunitiesWithoutEmarsysLog.add(opp);
						}
					}
				}
			}

			if (opp.Account.BillingCountry == 'France' && ! opp.OpportunityContactRoles.isEmpty()) {
				if (isOrderConfirmation(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
				} else if (isOrderConfirmation(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					for (Emarsys_Log__c emarsysLog : opp.Emarsys_Logs__r) {
						if (emarsysLog.Email_Name__c != 'E2E Order Confirmation - FR') {
							opportunitiesWithoutEmarsysLog.add(opp);
						}
					}
				}

				if (isAbandonmentScenarios(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
				} else if (isAbandonmentScenarios(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					Datetime campaignEndDate = calculateCampaignEndDate(opp);
					Decimal daysAfterLeadCreation = (opp.CreatedDate.getTime() - campaignEndDate.getTime()) / -86400000;
					for (Emarsys_Log__c emarsysLog : opp.Emarsys_Logs__r) {
						if ((emarsysLog.Email_Name__c != 'E2E Abandonment Email FR 1') || 
							(daysAfterLeadCreation > 2 && daysAfterLeadCreation <= 4 && emarsysLog.Email_Name__c != 'E2E Abandonment Email FR 2') || 
							(daysAfterLeadCreation > 4 && emarsysLog.Email_Name__c != 'E2E Abandonment Email FR 3')) {
							opportunitiesWithoutEmarsysLog.add(opp);
						}
					}
				}

				if (isSaveAndContinueLater(opp) && opp.Emarsys_Logs__r.isEmpty()) {
					opportunitiesWithoutEmarsysLog.add(opp);
				} else if (isSaveAndContinueLater(opp) && ! opp.Emarsys_Logs__r.isEmpty()) {
					Datetime campaignEndDate = calculateCampaignEndDate(opp);
					Decimal daysAfterLeadCreation = (opp.CreatedDate.getTime() - campaignEndDate.getTime()) / -86400000;
					for (Emarsys_Log__c emarsysLog : opp.Emarsys_Logs__r) {
						if ((emarsysLog.Email_Name__c != 'E2E Save And Continue FR 1') || 
							(daysAfterLeadCreation > 2 && daysAfterLeadCreation <= 4 && emarsysLog.Email_Name__c != 'E2E Save And Continue FR 2') || 
							(daysAfterLeadCreation > 4 && emarsysLog.Email_Name__c != 'E2E Save And Continue FR 3')) {
							opportunitiesWithoutEmarsysLog.add(opp);
						}
					}
				}
			}
		}

		return opportunitiesWithoutEmarsysLog;
	}


	/*******************************************************************************
	*  Name            : calculateCampaignEndDate(Opportunity opp)
	*  Summary         : Calculate campaign end date    
	*  CreatedDate     : 12/04/2019
	*  ModifiedDate    : -
	*  Parameters      : Opportunity opp
	*  Returns         : Datetime
	******************************************************************************/
	private Datetime calculateCampaignEndDate(Opportunity opp) {
		Datetime endDate = Datetime.now();
		for (OpportunityFieldHistory ofh : opp.Histories) {
            if (ofh.OldValue == 'Marketing automation' && ofh.NewValue == 'Switched to manual') {
                endDate = ofh.CreatedDate;
                break;
            }
        }
        return endDate;
	}


	/*******************************************************************************
    *  Name            : createExcelDocument(List<Opportunity> opportunitiesWithoutEmarsysLog)
    *  Summary         : Generate excel document and insert in the Emarsys Logs folder    
    *  CreatedDate     : 11/04/2019
    *  ModifiedDate    : -
    *  Parameters      : List<Opportunity> opportunitiesWithoutEmarsysLog - List of opportunities without emarsys logs
    *  Returns         : void
    ******************************************************************************/
    public void createExcelDocument(List<Opportunity> opportunitiesWithoutEmarsysLog) {
    	List<Folder> folderList = [SELECT Id, Name FROM Folder WHERE Name = 'Emarsys Logs'];
        Document document = new Document();
        document.FolderId = folderList.get(0).Id;
    	String body = '';
        for (Opportunity opp : opportunitiesWithoutEmarsysLog) {
            body += 'Opportunity ID = ' + opp.Id + ', Name = ' + opp.Name + ', Country = ' + opp.Account.BillingCountry + '\r';
        }
        document.Body = Blob.valueOf(body);
        document.Name = 'Opportunities' + Datetime.now() + '.xls';
        Database.insert(document);
    }


    //  E2E Manual Upgraded To E2E (Germany, Netherlands)
	private static Boolean isManualUpgradedToE2E(Opportunity opp) {
		Boolean isActOfE2ECampaign;
		if (! opp.Histories.isEmpty()) {
			for (OpportunityFieldHistory ofh : opp.Histories) {
	            if (ofh.OldValue == 'Manual upgraded to E2E' && ofh.NewValue != 'Manual upgraded to E2E') {
	                isActOfE2ECampaign = true;
	                break;
	            }
	        }
		}
	    if ((opp.E2E_Sales_Type__c == 'Manual upgraded to E2E' || isActOfE2ECampaign == true) && 
	    	(opp.StageName != 'Closed Won' || opp.StageName != 'Closed Won') && 
	    	opp.Sec_Channel__c == 'Inbound') {
	        return true;
	    }
	    return false;
	}

	//  E2E Order Confirmation DE - 1. Direct Debit No Deposit (Germany)
	private static Boolean isDirectDebitNoDeposit(Opportunity opp) {
		Boolean isActOfE2ECampaign;
		if (! opp.Histories.isEmpty()) {
			for (OpportunityFieldHistory ofh : opp.Histories) {
	            if (ofh.OldValue == 'NO DEPOSIT' && ofh.NewValue != 'NO DEPOSIT') {
	                isActOfE2ECampaign = true;
	                break;
	            }
	        }
		}
	    if (opp.Zahlungsart__c == 'Lastschrift' && 
	    	(opp.E2E_payment_status__c == 'NO DEPOSIT' || isActOfE2ECampaign == true) && 
	    	(opp.Security_Amount_To_Pay__c == null || opp.Security_Amount_To_Pay__c == 0) && 
	    	(opp.E2E_Active_Step__c == 4 || opp.E2E_Active_Step__c == 5)) {
	        return true;
	    }
	    return false;
	}

	// E2E Order Confirmation DE - 2. Direct Debit ACCEPT (Germany)
	private static Boolean isDirectDebitAccept(Opportunity opp) {
		Boolean isActOfE2ECampaign;
		if (! opp.Histories.isEmpty()) {
			for (OpportunityFieldHistory ofh : opp.Histories) {
	            if (ofh.OldValue == 'ACCEPT' && ofh.NewValue != 'ACCEPT') {
	                isActOfE2ECampaign = true;
	                break;
	            }
	        }
	    }
	    if (opp.Zahlungsart__c == 'Lastschrift' && 
	        (opp.Security_Amount_To_Pay__c != null && opp.Security_Amount_To_Pay__c != 0) &&
	        (opp.E2E_payment_status__c == 'ACCEPT' || isActOfE2ECampaign == true) && 
	        (opp.E2E_Active_Step__c == 4 || opp.E2E_Active_Step__c == 5)) {
	        return true;
	    }
	    return false;
	}

	// E2E Order Confirmation DE - 3. Direct Debit CANCEL&DECLINE (Germany)
	private static Boolean isDirectDebitCancelDecline(Opportunity opp) {
		Boolean isActOfE2ECampaign;
		if (! opp.Histories.isEmpty()) {
			for (OpportunityFieldHistory ofh : opp.Histories) {
	            if ( (ofh.OldValue == 'CANCEL' && ofh.NewValue != 'CANCEL') || (ofh.OldValue == 'DECLINE' && ofh.NewValue != 'DECLINE') ) {
	                isActOfE2ECampaign = true;
	                break;
	            }
	        }
	    }
	    if (opp.Zahlungsart__c == 'Lastschrift' && 
	        (opp.Security_Amount_To_Pay__c != null && opp.Security_Amount_To_Pay__c != 0) &&
	        ((opp.E2E_payment_status__c == 'CANCEL' || opp.E2E_payment_status__c == 'DECLINE') || isActOfE2ECampaign == true) && 
	        (opp.E2E_Active_Step__c == 4 || opp.E2E_Active_Step__c == 5)) {
	        return true;
	    }
	    return false;
	}

	// E2E Order Confirmation DE - 4. Direct Debit EXCEPTION (Germany)
	private static Boolean isDirectDebitException(Opportunity opp) {
		Boolean isActOfE2ECampaign;
		if (! opp.Histories.isEmpty()) {
			for (OpportunityFieldHistory ofh : opp.Histories) {
	            if (ofh.OldValue == 'EXCEPTION' && ofh.NewValue != 'EXCEPTION') {
	                isActOfE2ECampaign = true;
	                break;
	            }
	        }
	    }
	    if (opp.Zahlungsart__c == 'Lastschrift' && 
	        (opp.Security_Amount_To_Pay__c != null && opp.Security_Amount_To_Pay__c != 0) &&
	        (opp.E2E_payment_status__c == 'EXCEPTION' || isActOfE2ECampaign == true) && 
	        (opp.E2E_Active_Step__c == 4 || opp.E2E_Active_Step__c == 5)) {
	        return true;
	    }
	    return false;
	}

	// E2E Order Confirmation DE - 5. Bank Transfer No Deposit (Germany)
	private static Boolean isBankTransferNoDeposit(Opportunity opp) {
		Boolean isActOfE2ECampaign;
		if (! opp.Histories.isEmpty()) {
			for (OpportunityFieldHistory ofh : opp.Histories) {
	            if (ofh.OldValue == 'EXCEPTION' && ofh.NewValue != 'EXCEPTION') {
	                isActOfE2ECampaign = true;
	                break;
	            }
	        }
	    }
	    if (opp.Zahlungsart__c == 'Banküberweisung' && 
	        (opp.Security_Amount_To_Pay__c == null || opp.Security_Amount_To_Pay__c == 0) &&
	        (opp.E2E_payment_status__c == 'NO DEPOSIT' || isActOfE2ECampaign == true) && 
	        (opp.E2E_Active_Step__c == 4 || opp.E2E_Active_Step__c == 5)) {
	        return true;
	    }
	    return false;
	}

	// E2E Order Confirmation DE - 6. Bank Transfer ACCEPT (Germany)
	private static Boolean isBankTransferAccept(Opportunity opp) {
		Boolean isActOfE2ECampaign;
		if (! opp.Histories.isEmpty()) {
			for (OpportunityFieldHistory ofh : opp.Histories) {
	            if (ofh.OldValue == 'ACCEPT' && ofh.NewValue != 'ACCEPT') {
	                isActOfE2ECampaign = true;
	                break;
	            }
	        }
	    }
	    if (opp.Zahlungsart__c == 'Banküberweisung' && 
	        (opp.Security_Amount_To_Pay__c != null && opp.Security_Amount_To_Pay__c != 0) &&
	        (opp.E2E_payment_status__c == 'ACCEPT' || isActOfE2ECampaign == true) && 
	        (opp.E2E_Active_Step__c == 4 || opp.E2E_Active_Step__c == 5)) {
	        return true;
	    }
	    return false;
	}

	// E2E Order Confirmation DE - 7. Bank Transfer CANCEL&DECLINE (Germany)
	private static Boolean isBankTransferCancelDecline(Opportunity opp) {
		Boolean isActOfE2ECampaign;
		if (! opp.Histories.isEmpty()) {
			for (OpportunityFieldHistory ofh : opp.Histories) {
	            if ( (ofh.OldValue == 'CANCEL' && ofh.NewValue != 'CANCEL') || (ofh.OldValue == 'DECLINE' && ofh.NewValue != 'DECLINE') ) {
	                isActOfE2ECampaign = true;
	                break;
	            }
	        }
	    }
	    if (opp.Zahlungsart__c == 'Banküberweisung' && 
	        (opp.Security_Amount_To_Pay__c != null && opp.Security_Amount_To_Pay__c != 0) &&
	        ((opp.E2E_payment_status__c == 'CANCEL' || opp.E2E_payment_status__c == 'DECLINE') || isActOfE2ECampaign == true) && 
	        (opp.E2E_Active_Step__c == 4 || opp.E2E_Active_Step__c == 5)) {
	        return true;
	    }
	    return false;
	}

	// E2E Order Confirmation DE - 8. Bank Transfer EXCEPTION
	private static Boolean isBankTransferException(Opportunity opp) {
		Boolean isActOfE2ECampaign;
		if (! opp.Histories.isEmpty()) {
			for (OpportunityFieldHistory ofh : opp.Histories) {
	            if (ofh.OldValue == 'ACCEPT' && ofh.NewValue != 'ACCEPT') {
	                isActOfE2ECampaign = true;
	                break;
	            }
	        }
	    }
	    if (opp.Zahlungsart__c == 'Banküberweisung' && 
	        (opp.Security_Amount_To_Pay__c != null && opp.Security_Amount_To_Pay__c != 0) &&
	        (opp.E2E_payment_status__c == 'EXCEPTION' || isActOfE2ECampaign == true) && 
	        (opp.E2E_Active_Step__c == 4 || opp.E2E_Active_Step__c == 5)) {
	        return true;
	    }
	    return false;
	}

	// Order Confirmation (Netherlands, Belgium-NL, Belgium-FR, Poland, Hungary, France)
	private static Boolean isOrderConfirmation(Opportunity opp) {
	    if (opp.Zahlungsart__c != null && opp.E2E_payment_status__c != null && 
	        (opp.E2E_Active_Step__c == 4 || opp.E2E_Active_Step__c == 5)) {
	        return true;
	    }
	    return false;
	}

	// E2E Abandonment Scenarios (Germany, Netherlands, Belgium-NL, Belgium-FR, Poland, Hungary, France)
	private static Boolean isAbandonmentScenarios(Opportunity opp) {
		Boolean isActOfE2ECampaign;
		if (! opp.Histories.isEmpty()) {
			for (OpportunityFieldHistory ofh : opp.Histories) {
	            if (ofh.OldValue == 'Marketing automation' && ofh.NewValue == 'Switched to manual') {
	                isActOfE2ECampaign = true;
	                break;
	            }
	        }
	    }
        if (opp.StageName != 'Closed Won' && opp.StageName != 'Closed Lost' &&
            (opp.E2E_Switch_To_Manual__c == null || opp.E2E_Switch_To_Manual__c != true) && 
            ((opp.E2E_Status__c == 'Abandoned (hard)' && opp.E2E_Sub_Status__c == 'Marketing automation') || isActOfE2ECampaign == true)) {
            return true;
        }
        return false;
    }

    // E2E Save And Continue (Germany, Netherlands, Belgium-NL, Belgium-FR, Poland, Hungary, France)
    private static Boolean isSaveAndContinueLater(Opportunity opp) {
    	Boolean isActOfE2ECampaign;
		if (! opp.Histories.isEmpty()) {
			for (OpportunityFieldHistory ofh : opp.Histories) {
	            if (ofh.OldValue == 'Marketing automation' && ofh.NewValue == 'Switched to manual') {
	                isActOfE2ECampaign = true;
	                break;
	            }
	        }
	    }
        if (opp.StageName != 'Closed Won' && opp.StageName != 'Closed Lost' &&
            (opp.E2E_Switch_To_Manual__c == null || opp.E2E_Switch_To_Manual__c != true) && 
            ((opp.E2E_Status__c == 'Abandoned (soft)' && opp.E2E_Sub_Status__c == 'Marketing automation') || isActOfE2ECampaign == true)) {
            return true;
        }
        return false;
    }	
}