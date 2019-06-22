public class CribisCheckReportController {
        
    private String username, password, endpoint, apiKey, ico, country, pdf;
    public String opportunity {get;set;}
    
    public CribisCheckReportController()
    {
        
    }
    
    public pagereference actionReport()
    {
        apiKey = '65ded5353c5ee48d0b7d48c591b8f430';
        
        opportunity = Apexpages.currentPage().getParameters().get('id');
        ico = [SELECT account.CCS_Company_ID__c from opportunity where opportunity.id = :opportunity][0].Account.CCS_Company_ID__c;
        country = [SELECT account.BillingCountry from opportunity where opportunity.id = :opportunity][0].Account.BillingCountry;
        
        String countryWebalized = EncodingUtil.urlEncode(country, 'UTF-8');
        endpoint = 'http://intercodec.cz/subdom/ccs/cribis/www/?apiKey=' + apiKey + '&ico=' + ico + '&country=' + countryWebalized;
        
        this.getReportFromCribisDb();
        
        return null;
    }
    
    public void getReportFromCribisDb()
    {       
        String icoNumber = ico;
        
        Http h = new Http();
            HttpRequest req = new HttpRequest();
                req.setEndpoint(endpoint);
                req.setMethod('GET');           
            HttpResponse res = h.send(req);
        pdf = res.getBody();
        
        this.insertAttachment();
    }
    public void insertAttachment()
    {
        Blob b = EncodingUtil.base64Decode(pdf);
                
        Attachment a = new Attachment();
        a.Body = b;
        a.ParentID = opportunity;
        a.Name = ico + '_' + System.today().year() + '-' + System.today().month() + '-' + System.today().day() + '.pdf';
        a.Description = 'Cribis check opportunity for ' + ico;
        insert a;
    }
}