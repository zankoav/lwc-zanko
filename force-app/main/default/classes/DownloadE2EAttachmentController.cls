public class DownloadE2EAttachmentController {
    public String doc {get; set;}
    public String attachmentId {get; set;}
    public String docId {get; set;}

    public DownloadE2EAttachmentController() {}

    public void init() {        
        String encryptedParams = ApexPages.currentPage().getParameters().get('source');
        this.doc = ApexPages.currentPage().getParameters().get('doc');
        if (doc == null) return;

        String opportunityId;
        if (doc != 'hudd' && encryptedParams != null) {
            encryptedParams = encryptedParams.replaceAll('(\\s|%2B)', '+');
            Blob key = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EForm').AES256_Key__c);
            Blob dest = EncodingUtil.base64Decode(encryptedParams);
            Blob decrypted = Crypto.decryptWithManagedIv('AES256', key, dest);
            String decryptedParams = decrypted.toString();            
            if (decryptedParams != null) {
                opportunityId = decryptedParams.substringBefore('-');
            } 
        }       

        String attachmentName;
        if (doc == 'umowa1') {
        	attachmentName = 'Umowa Karty euroShell (DocuSign).pdf';
        } else 
        if (doc == 'umowa2') {
        	attachmentName = 'Umowa_o_kaucji (DocuSign).pdf';
        } else 
        if (doc == 'vatrecovery') {
            attachmentName = 'vatRecoveryTC.pdf';
        } else 
        if (doc == 'hudd') {
            attachmentName = 'HU_dd.pdf';
        } else 
        if (doc == 'contracthu') {
            attachmentName = 'ContractHU.pdf';
        } else 
        if (doc == 'agreementhu') {
            attachmentName = 'DepositAgreementHU.pdf';
        }        

        List<Attachment> attsList = [SELECT Id FROM Attachment WHERE Name = :attachmentName AND ParentId = :opportunityId ORDER BY CreatedDate DESC LIMIT 1];
        List<Document> docsList = [SELECT Id FROM Document WHERE Name = :attachmentName ORDER BY CreatedDate DESC LIMIT 1];
        if ( ! attsList.isEmpty() ) {
        	attachmentId = attsList.get(0).Id;
            return;
        } 
        if ( ! docsList.isEmpty() ) {
            docId = docsList.get(0).Id;
            return;
        }                
    }   
}