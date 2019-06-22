public class E2ENewUtils {

	// public static E2E_Form_Step__c returnActiveStep(String source, String country) {	
	// 	System.debug('DEBUG: source === ' + source);
	// 	Integer step;
	// 	if (source != null) {
	// 		String opportunityId = decryptOpportunityId(source);
	// 		step = Integer.valueOf([SELECT E2E_Active_Step__c FROM Opportunity WHERE Id = :opportunityId].E2E_Active_Step__c);
	// 	} else {
	// 		step = 0;
	// 	}

	// 	List<E2E_Form_Step__c> stepsList = [
	// 			SELECT Name, Order__c, E2E_Form__r.Template_Name__c, JavaScripts__c,
	// 				   CSS_Styles__c, Content_Settings__c, Apex_Service__c
	// 			FROM E2E_Form_Step__c
	// 			WHERE Order__c = :step AND 
	// 				  E2E_Form__r.Country__c = :country
	// 			ORDER BY Order__c
	// 			LIMIT 1];

	// 	return stepsList.get(0);
	// }

 //    public static String decryptOpportunityId(String encryptedParams) {
 //    	System.debug('DEBUG: encryptedParams === ' + encryptedParams);
 //        encryptedParams = encryptedParams.replaceAll('(\\s|%2B)', '+');
 //        if (E2EKeysAPI__c.getValues('E2EForm') == null ) throw new LongFormException('The link is corrupted.');
 //        Blob key = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EForm').AES256_Key__c);
 //        Blob dest = EncodingUtil.base64Decode(encryptedParams);
 //        Blob decrypted = Crypto.decryptWithManagedIv('AES256', key, dest);
 //        String decryptedParams = decrypted.toString();
 //        if (decryptedParams != null) {
 //        	if (decryptedParams.contains('-')) {
 //        		return decryptedParams.substringBefore('-');	
 //        	}
 //            return decryptedParams;
 //        }
 //        return null;
 //    }  

	public static String returnActiveStep(String source, String country) {	
		System.debug('DEBUG: source === ' + source);
		String step;
		if (source != null) {
			String opportunityId = decryptOpportunityId(source);
			step = [SELECT E2E_Active_Step__c FROM Opportunity WHERE Id = :opportunityId].E2E_Active_Substep__c;
		} else {
			step = 'Contact details';
		}
		return step;
	}

    public static String decryptOpportunityId(String encryptedParams) {
    	System.debug('DEBUG: encryptedParams === ' + encryptedParams);
        encryptedParams = encryptedParams.replaceAll('(\\s|%2B)', '+');
        if (E2EKeysAPI__c.getValues('E2EForm') == null ) throw new LongFormException('The link is corrupted.');
        Blob key = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EForm').AES256_Key__c);
        Blob dest = EncodingUtil.base64Decode(encryptedParams);
        Blob decrypted = Crypto.decryptWithManagedIv('AES256', key, dest);
        String decryptedParams = decrypted.toString();
        if (decryptedParams != null) {
        	if (decryptedParams.contains('-')) {
        		return decryptedParams.substringBefore('-');	
        	}
            return decryptedParams;
        }
        return null;
    }  	
}