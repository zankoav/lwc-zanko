public class LeadEmarsysLogService {
    /*******************************************************************************
	*  Name            : checkLeads(List<Lead> leadsList)
	*  Summary         : Check emarsys logs in leads    
	*  CreatedDate     : 08/04/2019
	*  ModifiedDate    : -
	*  Parameters      : List<Lead> leadsList
	*  Returns         : List<Lead>
	******************************************************************************/
    public List<Lead> checkLeads(List<Lead> leadList) {
    	List<Lead> leadsWithoutEmarsysLog = new List<Lead>();
    	for (Lead lead : leadList) {
    		// cases when emarsys log is empty
    		if (lead.Country == 'Germany' && lead.IsConverted == false && lead.Emarsys_Logs__r.isEmpty() && 
    			(isFacebook(lead) || isInboundCall(lead) || isInboundEmail(lead) || isOtherChannelJITB(lead)) ) {
    			leadsWithoutEmarsysLog.add(lead);
    		} else if (lead.Country == 'Netherlands' && lead.IsConverted == false && lead.Emarsys_Logs__r.isEmpty() && 
    				  (isFacebook(lead) || isInboundCall(lead) || isInboundEmail(lead) || isShellEmail(lead)) ) {
    			leadsWithoutEmarsysLog.add(lead);
    		} else if (lead.Country == 'Belgium-NL' && lead.IsConverted == false && lead.Emarsys_Logs__r.isEmpty() && 
    				  (isFacebook(lead) || isInboundCall(lead) || isInboundEmail(lead) || isShellEmail(lead)) ) {
    			leadsWithoutEmarsysLog.add(lead);
    		} else if (lead.Country == 'Belgium-FR' && lead.IsConverted == false && lead.Emarsys_Logs__r.isEmpty() && 
    				  (isFacebook(lead) || isInboundCall(lead) || isInboundEmail(lead) || isShellEmail(lead)) ) {
    			leadsWithoutEmarsysLog.add(lead);
    		} else if (lead.Country == 'Poland' && lead.IsConverted == false && lead.Emarsys_Logs__r.isEmpty() && isOtherChannelJITB(lead)) {
    			leadsWithoutEmarsysLog.add(lead);
    		} else if (lead.Country == 'Hungary' && lead.IsConverted == false && lead.Emarsys_Logs__r.isEmpty() && isOtherChannelJITB(lead)) {
    			leadsWithoutEmarsysLog.add(lead);
    		}
    		// cases when emarsys log does not empty but email name wrong
    		if (lead.Country == 'Germany' && lead.IsConverted == false && ! lead.Emarsys_Logs__r.isEmpty()) {
    			if (isFacebook(lead)) {
    				Datetime campaignEndDate = calculateCampaignEndDate(lead);
    				Decimal daysAfterLeadCreation = (lead.CreatedDate.getTime() - campaignEndDate.getTime()) / -86400000;
	    			for (Emarsys_Log__c emarsysLog : lead.Emarsys_Logs__r) {
	    				if ((daysAfterLeadCreation < 2 && emarsysLog.Email_Name__c != 'E2E Sales Scenario: Short Lead Form - DE 1') || 
	    					(daysAfterLeadCreation > 2 && daysAfterLeadCreation <= 4 && emarsysLog.Email_Name__c != 'E2E Sales Scenario: Short Lead Form - DE 2') || 
	    					(daysAfterLeadCreation > 4 && emarsysLog.Email_Name__c != 'E2E Sales Scenario: Short Lead Form - DE 3') ) {
	    					leadsWithoutEmarsysLog.add(lead);
	    				}
	    			}
    			} else if (isInboundCall(lead)) {
    				Datetime campaignEndDate = calculateCampaignEndDate(lead);
    				Decimal daysAfterLeadCreation = (lead.CreatedDate.getTime() - campaignEndDate.getTime()) / -86400000;
	    			for (Emarsys_Log__c emarsysLog : lead.Emarsys_Logs__r) {
	    				if ((daysAfterLeadCreation < 2 && emarsysLog.Email_Name__c != 'E2E Sales Scenario: Manual Upgrade to e2e (small deals) - DE 1') || 
	    					(daysAfterLeadCreation > 2 && daysAfterLeadCreation <= 4 && emarsysLog.Email_Name__c != 'E2E Sales Scenario: Manual Upgrade to e2e (small deals) - DE 2') || 
	    					(daysAfterLeadCreation > 4 && emarsysLog.Email_Name__c != 'E2E Sales Scenario: Manual Upgrade to e2e (small deals) - DE 3') ) {
	    					leadsWithoutEmarsysLog.add(lead);
	    				}
	    			}
    			} else if (isInboundEmail(lead)) {
    				Datetime campaignEndDate = calculateCampaignEndDate(lead);
    				Decimal daysAfterLeadCreation = (lead.CreatedDate.getTime() - campaignEndDate.getTime()) / -86400000;
	    			for (Emarsys_Log__c emarsysLog : lead.Emarsys_Logs__r) {
	    				if ((daysAfterLeadCreation < 2 && emarsysLog.Email_Name__c != 'E2E Sales Scenario: Email Leads: Non-Shell - DE 1') || 
	    					(daysAfterLeadCreation > 2 && daysAfterLeadCreation <= 4 && emarsysLog.Email_Name__c != 'E2E Sales Scenario: Email Leads: Non-Shell - DE 2') || 
	    					(daysAfterLeadCreation > 4 && emarsysLog.Email_Name__c != 'E2E Sales Scenario: Email Leads: Non-Shell - DE 3') ) {
	    					leadsWithoutEmarsysLog.add(lead);
	    				}
	    			}
    			} else if (isOtherChannelJITB(lead)) {
    				Datetime campaignEndDate = calculateCampaignEndDate(lead);
    				Decimal daysAfterLeadCreation = (lead.CreatedDate.getTime() - campaignEndDate.getTime()) / -86400000;
	    			for (Emarsys_Log__c emarsysLog : lead.Emarsys_Logs__r) {
	    				if ((daysAfterLeadCreation < 2 && emarsysLog.Email_Name__c != 'E2E Sales Scenario Other Channel DE - JITB 1') || 
	    					(daysAfterLeadCreation > 2 && daysAfterLeadCreation <= 4 && emarsysLog.Email_Name__c != 'E2E Sales Scenario Other Channel DE - JITB 2') || 
	    					(daysAfterLeadCreation > 4 && emarsysLog.Email_Name__c != 'E2E Sales Scenario Other Channel DE - JITB 3') ) {
	    					leadsWithoutEmarsysLog.add(lead);
	    				}
	    			}
    			}
    		} else if (lead.Country == 'Netherlands' && lead.IsConverted == false && ! lead.Emarsys_Logs__r.isEmpty()) {
    			if (isFacebook(lead)) {
	    			Datetime campaignEndDate = calculateCampaignEndDate(lead);
    				Decimal daysAfterLeadCreation = (lead.CreatedDate.getTime() - campaignEndDate.getTime()) / -86400000;
	    			for (Emarsys_Log__c emarsysLog : lead.Emarsys_Logs__r) {
	    				if ((daysAfterLeadCreation < 2 && emarsysLog.Email_Name__c != 'E2E Sales Scenario: Short Lead Form - NL 1') || 
	    					(daysAfterLeadCreation > 2 && daysAfterLeadCreation <= 4 && emarsysLog.Email_Name__c != 'E2E Sales Scenario: Short Lead Form - NL 2') || 
	    					(daysAfterLeadCreation > 4 && emarsysLog.Email_Name__c != 'E2E Sales Scenario: Short Lead Form - NL 3') ) {
	    					leadsWithoutEmarsysLog.add(lead);
	    				}
	    			}
    			} else if (isInboundCall(lead)) {
	    			Datetime campaignEndDate = calculateCampaignEndDate(lead);
    				Decimal daysAfterLeadCreation = (lead.CreatedDate.getTime() - campaignEndDate.getTime()) / -86400000;
	    			for (Emarsys_Log__c emarsysLog : lead.Emarsys_Logs__r) {
	    				if ((daysAfterLeadCreation < 2 && emarsysLog.Email_Name__c != 'E2E Sales Scenario: Manual Upgrade to e2e (small deals) - NL 1') || 
	    					(daysAfterLeadCreation > 2 && daysAfterLeadCreation <= 4 && emarsysLog.Email_Name__c != 'E2E Sales Scenario: Manual Upgrade to e2e (small deals) - NL 2') || 
	    					(daysAfterLeadCreation > 4 && emarsysLog.Email_Name__c != 'E2E Sales Scenario: Manual Upgrade to e2e (small deals) - NL 3') ) {
	    					leadsWithoutEmarsysLog.add(lead);
	    				}
	    			}
    			} else if (isInboundEmail(lead)) {
	    			Datetime campaignEndDate = calculateCampaignEndDate(lead);
    				Decimal daysAfterLeadCreation = (lead.CreatedDate.getTime() - campaignEndDate.getTime()) / -86400000;
	    			for (Emarsys_Log__c emarsysLog : lead.Emarsys_Logs__r) {
	    				if ((daysAfterLeadCreation < 2 && emarsysLog.Email_Name__c != 'E2E Sales Scenario: Email Leads: Non-Shell - NL 1') || 
	    					(daysAfterLeadCreation > 2 && daysAfterLeadCreation <= 4 && emarsysLog.Email_Name__c != 'E2E Sales Scenario: Email Leads: Non-Shell - NL 2') || 
	    					(daysAfterLeadCreation > 4 && emarsysLog.Email_Name__c != 'E2E Sales Scenario: Email Leads: Non-Shell - NL 3') ) {
	    					leadsWithoutEmarsysLog.add(lead);
	    				}
	    			}
    			} else if (isShellEmail(lead)) {
	    			Datetime campaignEndDate = calculateCampaignEndDate(lead);
    				Decimal daysAfterLeadCreation = (lead.CreatedDate.getTime() - campaignEndDate.getTime()) / -86400000;
	    			for (Emarsys_Log__c emarsysLog : lead.Emarsys_Logs__r) {
	    				if ((daysAfterLeadCreation < 2 && emarsysLog.Email_Name__c != 'E2E Sales Scenario: Email Leads: Shell - NL 1') || 
	    					(daysAfterLeadCreation > 2 && daysAfterLeadCreation <= 4 && emarsysLog.Email_Name__c != 'E2E Sales Scenario: Email Leads: Shell - NL 2') || 
	    					(daysAfterLeadCreation > 4 && emarsysLog.Email_Name__c != 'E2E Sales Scenario: Email Leads: Shell - NL 3') ) {
	    					leadsWithoutEmarsysLog.add(lead);
	    				}
	    			}
    			}
    		} else if (lead.Country == 'Belgium-NL' && lead.IsConverted == false && ! lead.Emarsys_Logs__r.isEmpty()) {
    			if (isFacebook(lead)) {
	    			Datetime campaignEndDate = calculateCampaignEndDate(lead);
    				Decimal daysAfterLeadCreation = (lead.CreatedDate.getTime() - campaignEndDate.getTime()) / -86400000;
	    			for (Emarsys_Log__c emarsysLog : lead.Emarsys_Logs__r) {
	    				if ((daysAfterLeadCreation < 2 && emarsysLog.Email_Name__c != 'E2E Sales Scenario: Short Lead Form - BENL 1') || 
	    					(daysAfterLeadCreation > 2 && daysAfterLeadCreation <= 4 && emarsysLog.Email_Name__c != 'E2E Sales Scenario: Short Lead Form - BENL 2') || 
	    					(daysAfterLeadCreation > 4 && emarsysLog.Email_Name__c != 'E2E Sales Scenario: Short Lead Form - BENL 3') ) {
	    					leadsWithoutEmarsysLog.add(lead);
	    				}
	    			}
    			} else if (isInboundCall(lead)) {
	    			Datetime campaignEndDate = calculateCampaignEndDate(lead);
    				Decimal daysAfterLeadCreation = (lead.CreatedDate.getTime() - campaignEndDate.getTime()) / -86400000;
	    			for (Emarsys_Log__c emarsysLog : lead.Emarsys_Logs__r) {
	    				if ((daysAfterLeadCreation < 2 && emarsysLog.Email_Name__c != 'E2E Sales Scenario: Manual Upgrade to e2e (small deals) - BENL 1') || 
	    					(daysAfterLeadCreation > 2 && daysAfterLeadCreation <= 4 && emarsysLog.Email_Name__c != 'E2E Sales Scenario: Manual Upgrade to e2e (small deals) - BENL 2') || 
	    					(daysAfterLeadCreation > 4 && emarsysLog.Email_Name__c != 'E2E Sales Scenario: Manual Upgrade to e2e (small deals) - BENL 3') ) {
	    					leadsWithoutEmarsysLog.add(lead);
	    				}
	    			}
    			} else if (isInboundEmail(lead)) {
	    			Datetime campaignEndDate = calculateCampaignEndDate(lead);
    				Decimal daysAfterLeadCreation = (lead.CreatedDate.getTime() - campaignEndDate.getTime()) / -86400000;
	    			for (Emarsys_Log__c emarsysLog : lead.Emarsys_Logs__r) {
	    				if ((daysAfterLeadCreation < 2 && emarsysLog.Email_Name__c != 'E2E Sales Scenario: Email Leads: Non-Shell - BENL 1') || 
	    					(daysAfterLeadCreation > 2 && daysAfterLeadCreation <= 4 && emarsysLog.Email_Name__c != 'E2E Sales Scenario: Email Leads: Non-Shell - BENL 2') || 
	    					(daysAfterLeadCreation > 4 && emarsysLog.Email_Name__c != 'E2E Sales Scenario: Email Leads: Non-Shell - BENL 3') ) {
	    					leadsWithoutEmarsysLog.add(lead);
	    				}
	    			}
    			} else if (isShellEmail(lead)) {
	    			Datetime campaignEndDate = calculateCampaignEndDate(lead);
    				Decimal daysAfterLeadCreation = (lead.CreatedDate.getTime() - campaignEndDate.getTime()) / -86400000;
	    			for (Emarsys_Log__c emarsysLog : lead.Emarsys_Logs__r) {
	    				if ((daysAfterLeadCreation < 2 && emarsysLog.Email_Name__c != 'E2E Sales Scenario: Email Leads: Shell - BENL 1') || 
	    					(daysAfterLeadCreation > 2 && daysAfterLeadCreation <= 4 && emarsysLog.Email_Name__c != 'E2E Sales Scenario: Email Leads: Shell - BENL 2') || 
	    					(daysAfterLeadCreation > 4 && emarsysLog.Email_Name__c != 'E2E Sales Scenario: Email Leads: Shell - BENL 3') ) {
	    					leadsWithoutEmarsysLog.add(lead);
	    				}
	    			}
    			}
    		} else if (lead.Country == 'Belgium-FR' && lead.IsConverted == false && ! lead.Emarsys_Logs__r.isEmpty()) {
    			if (isFacebook(lead)) {
	    			Datetime campaignEndDate = calculateCampaignEndDate(lead);
    				Decimal daysAfterLeadCreation = (lead.CreatedDate.getTime() - campaignEndDate.getTime()) / -86400000;
	    			for (Emarsys_Log__c emarsysLog : lead.Emarsys_Logs__r) {
	    				if ((daysAfterLeadCreation < 2 && emarsysLog.Email_Name__c != 'E2E Sales Scenario: Short Lead Form - BEFR 1') || 
	    					(daysAfterLeadCreation > 2 && daysAfterLeadCreation <= 4 && emarsysLog.Email_Name__c != 'E2E Sales Scenario: Short Lead Form - BEFR 2') || 
	    					(daysAfterLeadCreation > 4 && emarsysLog.Email_Name__c != 'E2E Sales Scenario: Short Lead Form - BEFR 3') ) {
	    					leadsWithoutEmarsysLog.add(lead);
	    				}
	    			}
    			} else if (isInboundCall(lead)) {
	    			Datetime campaignEndDate = calculateCampaignEndDate(lead);
    				Decimal daysAfterLeadCreation = (lead.CreatedDate.getTime() - campaignEndDate.getTime()) / -86400000;
	    			for (Emarsys_Log__c emarsysLog : lead.Emarsys_Logs__r) {
	    				if ((daysAfterLeadCreation < 2 && emarsysLog.Email_Name__c != 'E2E Sales Scenario: Manual Upgrade to e2e (small deals) - BEFR 1') || 
	    					(daysAfterLeadCreation > 2 && daysAfterLeadCreation <= 4 && emarsysLog.Email_Name__c != 'E2E Sales Scenario: Manual Upgrade to e2e (small deals) - BEFR 2') || 
	    					(daysAfterLeadCreation > 4 && emarsysLog.Email_Name__c != 'E2E Sales Scenario: Manual Upgrade to e2e (small deals) - BEFR 3') ) {
	    					leadsWithoutEmarsysLog.add(lead);
	    				}
	    			}
    			} else if (isInboundEmail(lead)) {
	    			Datetime campaignEndDate = calculateCampaignEndDate(lead);
    				Decimal daysAfterLeadCreation = (lead.CreatedDate.getTime() - campaignEndDate.getTime()) / -86400000;
	    			for (Emarsys_Log__c emarsysLog : lead.Emarsys_Logs__r) {
	    				if ((daysAfterLeadCreation < 2 && emarsysLog.Email_Name__c != 'E2E Sales Scenario: Email Leads: Non-Shell - BEFR 1') || 
	    					(daysAfterLeadCreation > 2 && daysAfterLeadCreation <= 4 && emarsysLog.Email_Name__c != 'E2E Sales Scenario: Email Leads: Non-Shell - BEFR 2') || 
	    					(daysAfterLeadCreation > 4 && emarsysLog.Email_Name__c != 'E2E Sales Scenario: Email Leads: Non-Shell - BEFR 3') ) {
	    					leadsWithoutEmarsysLog.add(lead);
	    				}
	    			}
    			} else if (isShellEmail(lead)) {
	    			Datetime campaignEndDate = calculateCampaignEndDate(lead);
    				Decimal daysAfterLeadCreation = (lead.CreatedDate.getTime() - campaignEndDate.getTime()) / -86400000;
	    			for (Emarsys_Log__c emarsysLog : lead.Emarsys_Logs__r) {
	    				if ((daysAfterLeadCreation < 2 && emarsysLog.Email_Name__c != 'E2E Sales Scenario: Email Leads: Shell - BEFR 1') || 
	    					(daysAfterLeadCreation > 2 && daysAfterLeadCreation <= 4 && emarsysLog.Email_Name__c != 'E2E Sales Scenario: Email Leads: Shell - BEFR 2') || 
	    					(daysAfterLeadCreation > 4 && emarsysLog.Email_Name__c != 'E2E Sales Scenario: Email Leads: Shell - BEFR 3') ) {
	    					leadsWithoutEmarsysLog.add(lead);
	    				}
	    			}
    			}
    		} else if (lead.Country == 'Poland' && lead.IsConverted == false && ! lead.Emarsys_Logs__r.isEmpty() && isOtherChannelJITB(lead)) {
    			Datetime campaignEndDate = calculateCampaignEndDate(lead);
				Decimal daysAfterLeadCreation = (lead.CreatedDate.getTime() - campaignEndDate.getTime()) / -86400000;
    			for (Emarsys_Log__c emarsysLog : lead.Emarsys_Logs__r) {
    				if ((daysAfterLeadCreation < 2 && emarsysLog.Email_Name__c != 'E2E Sales Scenario Other Channel PL - JITB 1') || 
    					(daysAfterLeadCreation > 2 && daysAfterLeadCreation <= 4 && emarsysLog.Email_Name__c != 'E2E Sales Scenario Other Channel PL - JITB 2') || 
    					(daysAfterLeadCreation > 4 && emarsysLog.Email_Name__c != 'E2E Sales Scenario Other Channel PL - JITB 3') ) {
    					leadsWithoutEmarsysLog.add(lead);
    				}
    			}
    		} else if (lead.Country == 'Hungary' && lead.IsConverted == false && ! lead.Emarsys_Logs__r.isEmpty() && isOtherChannelJITB(lead)) {
    			Datetime campaignEndDate = calculateCampaignEndDate(lead);
				Decimal daysAfterLeadCreation = (lead.CreatedDate.getTime() - campaignEndDate.getTime()) / -86400000;
    			for (Emarsys_Log__c emarsysLog : lead.Emarsys_Logs__r) {
    				if ((daysAfterLeadCreation < 2 && emarsysLog.Email_Name__c != 'E2E Sales Scenario Other Channel HU - JITB 1') || 
    					(daysAfterLeadCreation > 2 && daysAfterLeadCreation <= 4 && emarsysLog.Email_Name__c != 'E2E Sales Scenario Other Channel HU - JITB 2') || 
    					(daysAfterLeadCreation > 4 && emarsysLog.Email_Name__c != 'E2E Sales Scenario Other Channel HU - JITB 3') ) {
    					leadsWithoutEmarsysLog.add(lead);
    				}
    			}
    		}
    	}

		return leadsWithoutEmarsysLog;
    }


    /*******************************************************************************
	*  Name            : calculateCampaignEndDate(Lead lead)
	*  Summary         : Calculate campaign end date    
	*  CreatedDate     : 12/04/2019
	*  ModifiedDate    : -
	*  Parameters      : Lead lead
	*  Returns         : Datetime
	******************************************************************************/
	private Datetime calculateCampaignEndDate(Lead lead) {
		Datetime endDate = Datetime.now();
		if ( ! lead.Histories.isEmpty()) {
			for (LeadHistory lh : lead.Histories) {
	            if (lh.OldValue == 'Switched to E2E' && lh.NewValue == null) {
	                endDate = lh.CreatedDate;
	                break;
	            }
	        }
    	}
        return endDate;
	}


    /*******************************************************************************
    *  Name            : createExcelDocument(List<Lead> leadsWithoutEmarsysLog)
    *  Summary         : Generate excel document and insert in the Emarsys Logs folder    
    *  CreatedDate     : 10/04/2019
    *  ModifiedDate    : -
    *  Parameters      : List<Lead> leadsWithoutEmarsysLog - List of leads without emarsys logs
    *  Returns         : void
    ******************************************************************************/
    public void createExcelDocument(List<Lead> leadsWithoutEmarsysLog) {
    	List<Folder> folderList = [SELECT Id, Name FROM Folder WHERE Name = 'Emarsys Logs'];
        Document document = new Document();
        document.FolderId = folderList.get(0).Id;
    	String body = '';
        for (Lead lead : leadsWithoutEmarsysLog) {
            body += 'Lead ID = ' + lead.Id + ', Name = ' + lead.Name + ', Company = ' + lead.Company + ', Email = ' + lead.Email + ', Country = ' + lead.Country + '\r';
        }
        document.Body = Blob.valueOf(body);
        document.Name = 'Leads' + Datetime.now() + '.xls';
        Database.insert(document);
    }


    /*******************************************************************************
    *  Name            : checkLeadActOfCampaign(lead)
    *  Summary         : Check if lead is act of campaign    
    *  CreatedDate     : 12/04/2018
    *  ModifiedDate    : -
    *  Parameters      : Lead lead
    *  Returns         : Boolean
    ******************************************************************************/
    private static Boolean checkLeadActOfCampaign(Lead lead) {
    	Boolean isActOfCampaign;
    	if (! lead.Histories.isEmpty()) {
			for (LeadHistory oh : lead.Histories) {
	            if (oh.OldValue == 'Switched to E2E' && oh.NewValue == null) {
	                isActOfCampaign = true;
	                break;
	            }
	        }
		}
		return isActOfCampaign;
    }

    // Short Lead Forms DE, NL, BENL, BEFR (Germany, Netherlands, Belgium-NL, Belgium-FR)
	private static Boolean isFacebook(Lead lead) {
		Boolean isActOfCampaign = checkLeadActOfCampaign(lead);
	    if ((lead.Quali_Status__c == 'Switched to E2E' || isActOfCampaign == true) && 
	        (lead.LeadSource == 'Facebook' || lead.LeadSource == 'popup_window' || lead.LeadSource == 'Web_LP') && 
	        (lead.Sec_Channel__c != 'JITB' || lead.Sec_Channel__c == null)) {
	        return true;
	    }
	    return false;
	}

	// Manual Upgrade to e2e DE, NL, BENL, BEFR
	private static Boolean isInboundCall(Lead lead) {
		Boolean isActOfCampaign = checkLeadActOfCampaign(lead);
	    if ((lead.Quali_Status__c == 'Switched to E2E' || isActOfCampaign == true) && 
	        lead.LeadSource == 'Inbound Call' && 
	        (lead.Sec_Channel__c != 'JITB' || lead.Sec_Channel__c == null)) {
	        return true;
	    }
	    return false;
	}

	// Email Leads: Non-Shell DE, NL, BENL, BEFR
	private static Boolean isInboundEmail(Lead lead) {
		Boolean isActOfCampaign = checkLeadActOfCampaign(lead);
	    if ((lead.Quali_Status__c == 'Switched to E2E' || isActOfCampaign == true) && 
	        lead.LeadSource == 'Inbound Email' && 
	        (lead.Sec_Channel__c != 'JITB' || lead.Sec_Channel__c == null)) {
	        return true;
	    }
	    return false;
	}

	// Email Leads: Shell NL, BENL, BEFR
	private static Boolean isShellEmail(Lead lead) {
		Boolean isActOfCampaign = checkLeadActOfCampaign(lead);
	    if ((lead.Quali_Status__c == 'Switched to E2E' || isActOfCampaign == true) && 
	        lead.LeadSource == 'Shell Email' && 
	        (lead.Sec_Channel__c != 'JITB' || lead.Sec_Channel__c == null)) {
	        return true;
	    }
	    return false;
	}

	// Other Channel JITB DE, HU, PL
	private static Boolean isOtherChannelJITB(Lead lead) {
		Boolean isActOfCampaign = checkLeadActOfCampaign(lead);
	    if ((lead.Quali_Status__c == 'Switched to E2E' || isActOfCampaign == true) && 
	        lead.Sec_Channel__c == 'JITB' && 
	        lead.Email != null) {
	        return true;
	    }
	    return false;
	}
}