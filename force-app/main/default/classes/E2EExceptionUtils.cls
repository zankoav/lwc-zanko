public class E2EExceptionUtils {
	

	/*******************************************************************************
    *  Name            : saveExceptionData(Account account, Opportunity opportunity, String errorName, Exception excpt)
    *  Summary         : update opportuinty and account if we catch a exception    
    *  CreatedDate     : 23/07/2018
    *  ModifiedDate    : 15/10/2018 by Artem
    *  Parameters      : Account account, Opportunity opportunity, String errorName, Exception excpt
    *  Returns         : void
    ******************************************************************************/
    public static void saveExceptionData(Account account, Opportunity opportunity, String errorName, Exception excpt) {
    	try {
	        if (opportunity != null && account != null) {
	        	Boolean isVatIdError = false;
        		if (! errorsMap.containsKey(errorName)) {
                    opportunity.E2E_Errors__c = 'System Error';
	    			opportunity.Last_E2E_Error__c = 'System Error';
	    			String errorLocation;
	    			if (excpt.getStackTraceString() != null) errorLocation = excpt.getStackTraceString().substringBetween('Class.', ',');
	    			TimeZone tz = UserInfo.getTimeZone();
					DateTime dt = Datetime.now();
					Datetime errorDt = dt.addSeconds((tz.getOffset(dt)/1000));
					if (opportunity.E2E_System_Error_Description__c != null && opportunity.E2E_System_Error_Description__c != '') {
						opportunity.E2E_System_Error_Description__c += ';' + '\n' + errorDt + ': ' + excpt.getMessage() + ' (Cls: ' + errorLocation + ')';
					} else {
						opportunity.E2E_System_Error_Description__c = errorDt + ': ' + excpt.getMessage() + ' (Cls: ' + errorLocation + ')';
					}
	        		if (opportunity.E2E_System_Error_Description__c != null && opportunity.E2E_System_Error_Description__c.contains('Vat number is not valid')) {
	        			isVatIdError = true;
	        		}
	    		} else {
	    			opportunity.E2E_Errors__c = errorName;
                    opportunity.Last_E2E_Error__c = errorName;
	    		}	        
	            if (errorName == 'Private entity') {
	                opportunity.StageName = 'Closed Lost';
	                opportunity.E2E_Form_of_Business__c = 'Private';
	                opportunity.Gruende_verloren__c = 'Not a legal entity';
	            } else if (errorName == 'Too high limit' || errorName == 'Risky but manageable') {
	            	opportunity.E2E_Active_Step__c = 1;
	            	opportunity.E2E_Active_Substep__c = 'Set total consumption';
	            } else if (errorName == 'Additional Credit Scoring Allowance') {
	            	opportunity.E2E_Active_Step__c = 1;
	            	opportunity.E2E_Active_Substep__c = 'Additional Credit Scoring Allowance';
	            } else if (errorName == 'Too risky') {
	            	opportunity.E2E_Active_Step__c = 1;
	            	opportunity.E2E_Active_Substep__c = 'Too risky';
	            	opportunity.StageName = 'Closed Lost';
	            } else if (errorName == 'Too many reports' || 
            		errorName == 'Authorization not granted' ||
            		errorName == 'Black list' ||
            		errorName == 'Report does not exist' ||
            		errorName == 'Company not found' ||
            		errorName == 'Already a customer' ||
            		errorName == 'Already in process') {
	            	opportunity.E2E_Active_Step__c = 1;
	            	opportunity.E2E_Active_Substep__c = 'Search company';
	            } 
	            
	        	if (errorName == 'Already in process') {
	        		opportunity.E2E_Status__c = 'Finished';
	        	} else if ( ! isVatIdError ) {
	        		opportunity.E2E_Status__c = 'Rejected';
	        	}

	        	if ( ! isVatIdError ) {
		            opportunity.E2E_Sub_Status__c = 'Switched to manual';
		            opportunity.E2E_Sales_Type__c = 'E2E downgraded to manual';

		            E2E_Form_General_Settings__c settings = E2E_Form_General_Settings__c.getInstance(account.BillingCountry);
                    if (settings != null && settings.Abandonment_User__c != null) {
                    	account.OwnerId = settings.Abandonment_User__c;
                        opportunity.OwnerId = settings.Abandonment_User__c;
                    }			    	
	        	}
	            update opportunity;
	            update account;
	        }
        } catch (Exception e) {}
    }


    /*******************************************************************************
    *  Name            : sendExceptionEmail(Account account, Opportunity opportunity, Contact contact, String methodName, Exception excpt)
    *  Summary         : send exception email
    *  CreatedDate     : 23/07/2018
    *  ModifiedDate    : -
    *  Parameters      : Account account, Opportunity opportunity, Contact contact, String deviceView, String methodName, Exception excpt
    *  Returns         : void
    ******************************************************************************/
    public static void sendExceptionEmail(Account account, Opportunity opportunity, Contact contact, String deviceView, String methodName, Exception excpt) {
        try {
            String notificationMessage = '<br/>E2E method ' + methodName + ': ' + String.valueOf(excpt.getMessage());
            notificationMessage += '<br/>Device: ' + deviceView;
            if (account != null) {
                notificationMessage += '<br/>Account Id: ' + account.Id;
            }
            if (contact != null) {
                notificationMessage += '<br/>Contact Id: ' + contact.Id;
            }
            if (opportunity != null) {
                notificationMessage += '<br/>Opportunity Id: ' + opportunity.Id;
            }
            if ((methodName == 'goToCreditScoring()' || methodName == 'goToCompanyDetails()')) sendCCexceptionEmail(notificationMessage, String.valueOf(excpt.getStackTraceString()));
            ExceptionLogger.sendException(notificationMessage, String.valueOf(excpt.getStackTraceString()));
        } catch (Exception e) {
            String notificationMessage = '<br/>E2E method sendExceptionEmail(): ' + String.valueOf(e.getMessage());
            ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
        }
    }


    /*******************************************************************************
    *  Name            : sendCCexceptionEmail()
    *  Summary         : send cc exception email    
    *  CreatedDate     : 09/01/2019
    *  ModifiedDate    : -
    *  Parameters      : String exceptionDescription, String stackTraceString
    *  Returns         : void
    ******************************************************************************/
    private static void sendCCexceptionEmail(String exceptionDescription, String stackTraceString) {
    	Map<String, User> additionalRecipientsMap = new Map<String, User>([
    		SELECT Id FROM User WHERE Username = 'yulia.sivashova@fleetcor.ru'
		]);
        List<Messaging.Email> mailsList = new List<Messaging.Email>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        for (String id : additionalRecipientsMap.keySet()) {
            mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(id);
            mail.setSenderDisplayName('SFDC');
            mail.setSubject('Exception Logger ' + String.valueOf(URL.getSalesforceBaseUrl().toExternalForm()).substringAfter('//'));
            mail.setBccSender(false);
            mail.setUseSignature(false);
            mail.setSaveAsActivity(false);
            mail.setHtmlBody('Exception in ' + stackTraceString + '\n' + exceptionDescription);
            mailsList.add(mail);
        }
        Messaging.sendEmail(mailsList, false);
    }


    /*******************************************************************************
	*  Name            : errorsMap - static map
	*  Summary         : 'errorsMap' is static map for saving all e2e errors    
	*  CreatedDate     : 24/07/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : -
	******************************************************************************/	
	public static Map<String, String> errorsMap = new Map<String, String>{
		'Company not found' => 'Company not found',
		'Report does not exist' => 'Report does not exist',
		'Too high limit' => 'Too high limit',
		'Additional Credit Scoring Allowance' => 'Additional Credit Scoring Allowance',
		'Too high limit. Additional Credit Scoring Allowance' => 'Too high limit. Additional Credit Scoring Allowance',
		'Private entity' => 'Private entity',
		'Risky but manageable' => 'Risky but manageable',
		'Too risky' => 'Too risky',
		'Authorization not granted' => 'Authorization not granted',
		'Black list' => 'Black list',
		'Already a customer' => 'Already a customer',
		'Already in process' => 'Already in process',
		'More than two paid reports' => 'More than two paid reports'
	};
}