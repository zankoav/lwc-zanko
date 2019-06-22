public class LinkRedirectController {

    String country = 'Germany'; // default for sandbox , cause sandbox url is different

    public PageReference redirectURL() {
        Map<String, String> parameters = ApexPages.currentPage().getParameters();
        String country_code = ApexPages.currentPage().getHeaders().get('Host').substringAfterLast('.');
        switch on country_code{
            when 'de'{
                country = 'Germany';
            }
            when 'pl'{
                country = 'Poland';
            }
        }
        String shortid;
        for (String pName : parameters.keySet()) {
            shortid = pName;
            break;
        }

        if (parameters.get('preload') != null && shortid != null && shortid.startsWith('l')) {
            String obn = shortid.substringAfter('l');
            ShortURLHookService.preMakeOpp(obn, 5,country);
            return null;
        }


        return new PageReference(generateUrl(shortid));
    }

    @TestVisible
    private String generateUrl(String shortid) {
        E2E_Short_Url__c e2eShortUrlDetail;

        if (shortid != null) {
            if (shortid.startsWith('s')) {  // SMS source
                String codeToCheck = shortid.substringAfter('s');
                List<Opportunity> opportunityToCheck = [
                        SELECT E2E_Encoded_Url__c, Account.BillingCountry, Sec_Channel__c, (
                                SELECT AccountTo.OBN__c, AccountTo.BillingStreet, AccountTo.BillingCity, AccountTo.BillingCountry
                                FROM Partners
                                WHERE AccountTo.OBN__c != NULL AND AccountTo.BillingStreet != null AND AccountTo.BillingCity != NULL AND AccountTo.BillingCountry != NULL
                                LIMIT 1
                        )
                        FROM Opportunity
                        WHERE E2E_Encoded_Url__c != NULL AND
                        E2E_Short_Link__c = :codeToCheck
                        LIMIT 1
                ];
                if (!opportunityToCheck.isEmpty()) {
                    e2eShortUrlDetail = E2E_Short_Url__c.getInstance(opportunityToCheck.get(0).Account.BillingCountry);
                    if(opportunityToCheck.get(0).Partners.isEmpty() && e2eShortUrlDetail.E2E_JITB_Form_Url__c != null) {
                        return e2eShortUrlDetail.E2E_JITB_Form_Url__c + '?source=' + opportunityToCheck.get(0).E2E_Encoded_Url__c;
                    }
                    if (opportunityToCheck.get(0).Account.BillingCountry == country) {
                        String finalUrl;
                        if(country == 'Germany'){
                            finalUrl = e2eShortUrlDetail.E2E_Form_Url__c + '&source=' + opportunityToCheck.get(0).E2E_Encoded_Url__c + '&followup=sms';
                        }
                        else{
                            finalUrl = e2eShortUrlDetail.E2E_Form_Url__c + '?source=' + opportunityToCheck.get(0).E2E_Encoded_Url__c + '&followup=sms';
                        }
                        if (opportunityToCheck.get(0).Sec_Channel__c == 'JITB') {
                            finalUrl += '&utm_source=jitb&utm_medium=s&utm_content=' + opportunityToCheck.get(0).Partners.get(0).AccountTo.OBN__c;
                        }
                        return finalUrl;
                    }
                }
            }

            else if (shortid.startsWith('q')) {  // QR source
                e2eShortUrlDetail = E2E_Short_Url__c.getInstance(country);
                String obn = shortid.substringAfter('q');
                String source = ShortURLHookService.getShortLinkId(null, obn, false,ShortURLHookService.sourceQR,country);
                if (source != null && country == 'Germany') {
                    return e2eShortUrlDetail.E2E_Form_Url__c + '&source=' + source + '&utm_source=jitb&utm_medium=q&utm_content=' + obn;
                } else
                        if (source != null) {
                            return e2eShortUrlDetail.E2E_Form_Url__c + '?source=' + source + '&utm_source=jitb&utm_medium=q&utm_content=' + obn;
                        }
            }

            else if (shortid.startsWith('l')) { // tablet source
                e2eShortUrlDetail = E2E_Short_Url__c.getInstance(country);
                String obn = shortid.substringAfter('l');
                String source = ShortURLHookService.getShortLinkId(null, obn, false,ShortURLHookService.sourceTablet,country);
                if (source != null && country == 'Germany') {
                    return e2eShortUrlDetail.E2E_Form_Url__c + '&source=' + source + '&utm_source=jitb&utm_medium=l&utm_content=' + obn + '&tablet=true';
                } else
                        if (source != null) {
                            return e2eShortUrlDetail.E2E_Form_Url__c + '?source=' + source + '&utm_source=jitb&utm_medium=l&utm_content=' + obn + '&tablet=true';
                        }
            }

            else if (shortid.startsWith('u')) { // URL source
                e2eShortUrlDetail = E2E_Short_Url__c.getInstance(country);
                String obn = shortid.substringAfter('u');
                String source = ShortURLHookService.getShortLinkId(null, obn, false,ShortURLHookService.sourceURL,country);
                if (source != null && country == 'Germany') {
                    return e2eShortUrlDetail.E2E_Form_Url__c + '&source=' + source + '&utm_source=jitb&utm_medium=u&utm_content=' + obn;
                } else
                        if (source != null) {
                            return e2eShortUrlDetail.E2E_Form_Url__c + '?source=' + source + '&utm_source=jitb&utm_medium=u&utm_content=' + obn;
                        }
            }
        }

        e2eShortUrlDetail = E2E_Short_Url__c.getInstance(country);
        return e2eShortUrlDetail.E2E_Form_Url__c;
    }
}