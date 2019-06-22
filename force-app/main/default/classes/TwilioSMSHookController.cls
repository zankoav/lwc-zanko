@RestResource(urlMapping = '/twiliohook/*')
global class TwilioSMSHookController {
    @HttpPost
    global static String getPost() {
        RestRequest req = RestContext.request;
        System.debug(req);
        String sms_from = req.params.get('from').replace('%2B', '+');
        String sms_body = req.params.get('body');
        String country = req.params.get('country');
        System.debug(Datetime.now().format() + ': got sms from ' + sms_from + ':   ' + sms_body);
        // getting obn from sms
//        String obn_number = sms_body.substringAfterLast(':').replaceAll('\\s+', '');
        try {
            String obn_number = sms_body.replaceAll('[^0-9]', '');
            if(country == 'Poland')
                obn_number='R'+obn_number;
            String shortid = ShortURLHookService.getShortLinkId(sms_from, obn_number, false, ShortURLHookService.sourceSMS, country);
            if (shortid == null) {
                System.debug('error creating opportunity in response to sms! no exception caught');
                return JSON.serialize(new GeneratedLink(null, country));
            }
            System.debug('opportunity for sms from:' + sms_from + ' with body: ' + sms_body + ' was created');
            GeneratedLink generatedLink = new GeneratedLink(shortid, country);
            return JSON.serialize(generatedLink);
        } catch (Exception e) {
            System.debug('error creating entities in response to sms!\n' + e.getMessage() + ': ' + e.getStackTraceString());
            return JSON.serialize(new GeneratedLink(null, country));
        }
    }

    public class GeneratedLink {
        public String link;

        public GeneratedLink(String link, String country) {
            E2E_Short_Url__c e2eShortUrlDetail = E2E_Short_Url__c.getInstance(country);
            if (link != null) {
                this.link = e2eShortUrlDetail.Short_Url__c + '?s' + link;
            } else {
                this.link = e2eShortUrlDetail.E2E_Form_Url__c;
            }
        }
    }
}