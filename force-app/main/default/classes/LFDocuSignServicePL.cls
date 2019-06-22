public class LFDocuSignServicePL implements LFDocusign {
    private OpportunityContactRole signer;
    private Opportunity opportunity;
    private String token;
    private String envelopeId;

    /*******************************************************************************
    *  Name            : createEnvelope()
    *  Summary         : Create docusign envelope with recipient    
    *  CreatedDate     : 14/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : String - token to sign dociments
    ******************************************************************************/
    public String createEnvelope(String deviceView, String activeSubstep) {
        E2E_Docusign_Settings__c docusignSettings = E2E_Docusign_Settings__c.getInstance('Poland');
        this.envelopeId = '';
        String auth;
        String integratorsKey;

        DocusignNetApi30.RequestRecipientTokenAuthenticationAssertion authenticationAssert = setAuthenticationAssert();
        DocusignNetApi30.RequestRecipientTokenClientURLs clientURLs = generateRedirectUrl();

        if (deviceView == 'Mobile') {
            integratorsKey = docusignSettings.IntegratorsKeyMob__c;
        } else {
            integratorsKey = docusignSettings.IntegratorsKeyDesktop__c;
        }
        auth = setAuthentication(docusignSettings.UserId__c, docusignSettings.Password__c, integratorsKey);

        DocusignNetApi30.ApiServiceSOAP dsApiSend = dsapi_send(docusignSettings.WebServiceUrl__c, auth);

        // check if we already sent envelope to the customer and if customer change contact data
        Boolean isAlreadySent = checkDuplicate(activeSubstep);
        if ( isAlreadySent ) {
            this.token = dsApiSend.RequestRecipientToken(this.envelopeId, '1', this.signer.Contact.Name, this.signer.Contact.Email, authenticationAssert, clientURLs);
            return this.token;
        }

        // create envelope info
        DocusignNetApi30.EnvelopeInformation envelope = new DocusignNetApi30.EnvelopeInformation();
        envelope.Subject = docusignSettings.Subject__c;
        envelope.EmailBlurb = docusignSettings.Body__c;
        envelope.AccountId  = docusignSettings.AccountId__c;

        // Set salesforce object
        DocusignNetApi30.CustomField field = new DocusignNetApi30.CustomField(); 
        field.Name = '##SFOpportunity'; 
        field.Value = this.opportunity.Id;
        field.Show = 'false';
        DocusignNetApi30.ArrayOfCustomField arrayOfCustomField = new DocusignNetApi30.ArrayOfCustomField();
        arrayOfCustomField.CustomField  = new DocusignNetApi30.CustomField[1];
        arrayOfCustomField.CustomField[0] = field;
        envelope.CustomFields = arrayOfCustomField;

        // Recipient Information
        DocusignNetApi30.Recipient recipient = new DocusignNetApi30.Recipient();
        recipient.ID = 1;
        recipient.Type_x = 'Signer';
        recipient.RoutingOrder = 1;
        recipient.Email = this.signer.Contact.Email;
        recipient.UserName = this.signer.Contact.Name;
        recipient.RoleName = 'Signer';

        // make recipient captive for embedded experience
        recipient.CaptiveInfo = new DocusignNetApi30.RecipientCaptiveInfo();
        recipient.CaptiveInfo.ClientUserId = '1';

        // Role assignments
        DocusignNetApi30.TemplateReferenceRoleAssignment roleAssignment = new DocusignNetApi30.TemplateReferenceRoleAssignment();
        roleAssignment.RoleName = recipient.RoleName;
        roleAssignment.RecipientID = recipient.ID;

        // Create array of recipients
        DocusignNetApi30.ArrayOfRecipient1 signers = new DocusignNetApi30.ArrayOfRecipient1();
        signers.Recipient = new DocusignNetApi30.Recipient[1];
        signers.Recipient[0] = recipient;

        // create array of templates
        DocusignNetApi30.ArrayOfTemplateReference templateReferences = generateDocusignTemplates(roleAssignment);

        // create docusign envelope from templates
        DocusignNetApi30.EnvelopeStatus envelopeStatus = dsApiSend.CreateEnvelopeFromTemplates(templateReferences, signers, envelope, true);
        this.envelopeId = envelopeStatus.EnvelopeID;

        // assumes apiService = preconfigured api proxy
        this.token = dsApiSend.RequestRecipientToken(this.envelopeId, recipient.captiveinfo.ClientUserId, recipient.UserName, recipient.Email, authenticationAssert, clientURLs);
        return this.token;
    }


    /*******************************************************************************
    *  Name            : generateDocusignTemplates(DocusignNetApi30.TemplateReferenceRoleAssignment roleAssignment)
    *  Summary         : Generate array of docusign templates    
    *  CreatedDate     : 20/11/2018
    *  ModifiedDate    : -
    *  Parameters      : DocusignNetApi30.TemplateReferenceRoleAssignment roleAssignment - recipient role for assignment
    *  Returns         : DocusignNetApi30.ArrayOfTemplateReference
    ******************************************************************************/
    private DocusignNetApi30.ArrayOfTemplateReference generateDocusignTemplates(DocusignNetApi30.TemplateReferenceRoleAssignment roleAssignment) {
        DocusignNetApi30.ArrayOfTemplateReference templateReferences = new DocusignNetApi30.ArrayOfTemplateReference();

        if (this.opportunity.E2E_Active_Substep__c == 'Additional Credit Scoring Allowance') {
            E2E_Docusign_Templates__c creditScoringAllowanceSettings = E2E_Docusign_Templates__c.getInstance('E2E PL Credit Scoring Allowance');
            DocusignNetApi30.TemplateReference creditScoringAllowanceTemplate = createCreditScotingAllowanceTemplate(roleAssignment, creditScoringAllowanceSettings.Docusign_Template_Id__c);

            templateReferences.TemplateReference = new List<DocusignNetApi30.TemplateReference>();
            templateReferences.TemplateReference.add(creditScoringAllowanceTemplate);
        } 
        else if (this.opportunity.E2E_Active_Substep__c == 'Documents' || 
                this.opportunity.E2E_Active_Substep__c == 'DirectDebitDeposit' ||
                this.opportunity.E2E_Active_Substep__c == 'BankTransferDeposit') {

            E2E_Docusign_Templates__c contractSettings = E2E_Docusign_Templates__c.getInstance('E2E PL Contract');
            DocusignNetApi30.TemplateReference contractTemplate = createContractTemplate(roleAssignment, contractSettings.Docusign_Template_Id__c);

            templateReferences.TemplateReference = new List<DocusignNetApi30.TemplateReference>();
            templateReferences.TemplateReference.add(contractTemplate);

            if (this.opportunity.Security_To_Pay__c == 'Kaution') {
                E2E_Docusign_Templates__c deposisSettings = E2E_Docusign_Templates__c.getInstance('E2E PL Deposit Agreement');
                DocusignNetApi30.TemplateReference depositTemplate = createDepositTemplate(roleAssignment, deposisSettings.Docusign_Template_Id__c);

                templateReferences.TemplateReference.add(depositTemplate);
            }
        }

        return templateReferences;
    }


    /*******************************************************************************
    *  Name            : createCreditScotingAllowanceTemplate(DocusignNetApi30.TemplateReferenceRoleAssignment roleAssignment)
    *  Summary         : Set fields for credit scoring allowance template   
    *  CreatedDate     : 19/11/2018
    *  ModifiedDate    : -
    *  Parameters      : DocusignNetApi30.TemplateReferenceRoleAssignment roleAssignment - template of roles, String templateId
    *  Returns         : docusignTemplate - template from docusign
    ******************************************************************************/
    private DocusignNetApi30.TemplateReference createCreditScotingAllowanceTemplate(DocusignNetApi30.TemplateReferenceRoleAssignment roleAssignment, String templateId) {
        // Create object for server-side template
        DocusignNetApi30.TemplateReference docusignTemplate = new DocusignNetApi30.TemplateReference();
        docusignTemplate.Template = templateId;
        docusignTemplate.TemplateLocation = 'Server';

        // Add role assignment
        docusignTemplate.RoleAssignments = new DocusignNetApi30.ArrayOfTemplateReferenceRoleAssignment();
        docusignTemplate.RoleAssignments.RoleAssignment = new DocusignNetApi30.TemplateReferenceRoleAssignment[1];
        docusignTemplate.RoleAssignments.RoleAssignment[0] = roleAssignment;

        // Add data for fields (TabLabel it's Data Label filed in docusign template)
        DocusignNetApi30.TemplateReferenceFieldDataDataValue fd1 = new DocusignNetApi30.TemplateReferenceFieldDataDataValue();
        fd1.TabLabel = 'AccountName';
        fd1.Value = this.opportunity.Account.Name;
        
        DocusignNetApi30.TemplateReferenceFieldDataDataValue fd2 = new DocusignNetApi30.TemplateReferenceFieldDataDataValue();
        fd2.TabLabel = 'TaxID';
        fd2.Value = this.opportunity.Account.Steuernummer__c;

        DocusignNetApi30.TemplateReferenceFieldDataDataValue fd3 = new DocusignNetApi30.TemplateReferenceFieldDataDataValue();
        fd3.TabLabel = 'RegNumber';
        fd3.Value = this.opportunity.Account.HR_Abteilung_HRA_HRB_und_HR_Nummer__c;

        DocusignNetApi30.TemplateReferenceFieldDataDataValue fd4 = new DocusignNetApi30.TemplateReferenceFieldDataDataValue();
        fd4.TabLabel = 'Street';
        fd4.Value = this.opportunity.Account.BillingStreet;

        DocusignNetApi30.TemplateReferenceFieldDataDataValue fd5 = new DocusignNetApi30.TemplateReferenceFieldDataDataValue();
        fd5.TabLabel = 'City';
        fd5.Value = this.opportunity.Account.BillingCity;

        DocusignNetApi30.TemplateReferenceFieldDataDataValue fd6 = new DocusignNetApi30.TemplateReferenceFieldDataDataValue();
        fd6.TabLabel = 'Zip';
        fd6.Value = this.opportunity.Account.BillingPostalCode;

        DocusignNetApi30.TemplateReferenceFieldDataDataValue fd7 = new DocusignNetApi30.TemplateReferenceFieldDataDataValue();
        fd7.TabLabel = 'City';
        fd7.Value = this.opportunity.Account.BillingCity;

        DocusignNetApi30.TemplateReferenceFieldDataDataValue fd8 = new DocusignNetApi30.TemplateReferenceFieldDataDataValue();
        fd8.TabLabel = 'ContactName';
        fd8.Value = this.signer.Contact.Name;

        docusignTemplate.FieldData = new DocusignNetApi30.TemplateReferenceFieldData();
        docusignTemplate.FieldData.DataValues = new DocusignNetApi30.ArrayOfTemplateReferenceFieldDataDataValue();
        docusignTemplate.FieldData.DataValues.DataValue = new DocusignNetApi30.TemplateReferenceFieldDataDataValue[8];
        docusignTemplate.FieldData.DataValues.DataValue[0] = fd1;
        docusignTemplate.FieldData.DataValues.DataValue[1] = fd2;
        docusignTemplate.FieldData.DataValues.DataValue[2] = fd3;
        docusignTemplate.FieldData.DataValues.DataValue[3] = fd4;
        docusignTemplate.FieldData.DataValues.DataValue[4] = fd5;
        docusignTemplate.FieldData.DataValues.DataValue[5] = fd6;
        docusignTemplate.FieldData.DataValues.DataValue[6] = fd7;
        docusignTemplate.FieldData.DataValues.DataValue[7] = fd8;

        return docusignTemplate;
    }


    /*******************************************************************************
    *  Name            : createDepositTemplate(DocusignNetApi30.TemplateReferenceRoleAssignment roleAssignment, String templateId)
    *  Summary         : Set fields for Deposit template    
    *  CreatedDate     : 20/11/2018
    *  ModifiedDate    : -
    *  Parameters      : DocusignNetApi30.TemplateReferenceRoleAssignment roleAssignment - template of roles, String templateId
    *  Returns         : docusignTemplate - template from docusign
    ******************************************************************************/
    private DocusignNetApi30.TemplateReference createDepositTemplate(DocusignNetApi30.TemplateReferenceRoleAssignment roleAssignment, String templateId) {
        // Create object for server-side template
        DocusignNetApi30.TemplateReference docusignTemplate = new DocusignNetApi30.TemplateReference();
        docusignTemplate.Template = templateId;
        docusignTemplate.TemplateLocation = 'Server';

        // Add role assignment
        docusignTemplate.RoleAssignments = new DocusignNetApi30.ArrayOfTemplateReferenceRoleAssignment();
        docusignTemplate.RoleAssignments.RoleAssignment = new DocusignNetApi30.TemplateReferenceRoleAssignment[1];
        docusignTemplate.RoleAssignments.RoleAssignment[0] = roleAssignment;

        // Add data for fields (TabLabel it's Data Label filed in docusign template)
        DocusignNetApi30.TemplateReferenceFieldDataDataValue fd1 = new DocusignNetApi30.TemplateReferenceFieldDataDataValue();
        fd1.TabLabel = 'AccountName';
        fd1.Value = this.opportunity.Account.Name;
        
        DocusignNetApi30.TemplateReferenceFieldDataDataValue fd2 = new DocusignNetApi30.TemplateReferenceFieldDataDataValue();
        fd2.TabLabel = 'AmountToPay';
        fd2.Value = String.valueOf(this.opportunity.Security_Amount_To_Pay__c);

        DocusignNetApi30.TemplateReferenceFieldDataDataValue fd3 = new DocusignNetApi30.TemplateReferenceFieldDataDataValue();
        fd3.TabLabel = 'City';
        fd3.Value = this.opportunity.Account.BillingCity;

        DocusignNetApi30.TemplateReferenceFieldDataDataValue fd4 = new DocusignNetApi30.TemplateReferenceFieldDataDataValue();
        fd4.TabLabel = 'ContactName';
        fd4.Value = this.signer.Contact.Name;

        docusignTemplate.FieldData = new DocusignNetApi30.TemplateReferenceFieldData();
        docusignTemplate.FieldData.DataValues = new DocusignNetApi30.ArrayOfTemplateReferenceFieldDataDataValue();
        docusignTemplate.FieldData.DataValues.DataValue = new DocusignNetApi30.TemplateReferenceFieldDataDataValue[4];
        docusignTemplate.FieldData.DataValues.DataValue[0] = fd1;
        docusignTemplate.FieldData.DataValues.DataValue[1] = fd2;
        docusignTemplate.FieldData.DataValues.DataValue[2] = fd3;
        docusignTemplate.FieldData.DataValues.DataValue[3] = fd4;

        return docusignTemplate;
    }


    /*******************************************************************************
    *  Name            : createContractTemplate(DocusignNetApi30.TemplateReferenceRoleAssignment roleAssignment, String templateId)
    *  Summary         : Set fields for Contract template   
    *  CreatedDate     : 20/11/2018
    *  ModifiedDate    : -
    *  Parameters      : DocusignNetApi30.TemplateReferenceRoleAssignment roleAssignment - template of roles, String templateId
    *  Returns         : docusignTemplate - template from docusign
    ******************************************************************************/
    private DocusignNetApi30.TemplateReference createContractTemplate(DocusignNetApi30.TemplateReferenceRoleAssignment roleAssignment, String templateId) {
        // Create object for server-side template
        DocusignNetApi30.TemplateReference docusignTemplate = new DocusignNetApi30.TemplateReference();
        docusignTemplate.Template = templateId;
        docusignTemplate.TemplateLocation = 'Server';

        // Add role assignment
        docusignTemplate.RoleAssignments = new DocusignNetApi30.ArrayOfTemplateReferenceRoleAssignment();
        docusignTemplate.RoleAssignments.RoleAssignment = new DocusignNetApi30.TemplateReferenceRoleAssignment[1];
        docusignTemplate.RoleAssignments.RoleAssignment[0] = roleAssignment;

        // Add data for fields (TabLabel it's Data Label filed in docusign template)
        DocusignNetApi30.TemplateReferenceFieldDataDataValue fd1 = new DocusignNetApi30.TemplateReferenceFieldDataDataValue();
        fd1.TabLabel = 'AccountName';
        fd1.Value = this.opportunity.Account.Name;
        
        DocusignNetApi30.TemplateReferenceFieldDataDataValue fd2 = new DocusignNetApi30.TemplateReferenceFieldDataDataValue();
        fd2.TabLabel = 'Street';
        fd2.Value = this.opportunity.Account.BillingStreet;

        DocusignNetApi30.TemplateReferenceFieldDataDataValue fd3 = new DocusignNetApi30.TemplateReferenceFieldDataDataValue();
        fd3.TabLabel = 'Zip';
        fd3.Value = this.opportunity.Account.BillingPostalCode;

        DocusignNetApi30.TemplateReferenceFieldDataDataValue fd4 = new DocusignNetApi30.TemplateReferenceFieldDataDataValue();
        fd4.TabLabel = 'City';
        fd4.Value = this.opportunity.Account.BillingCity;

        DocusignNetApi30.TemplateReferenceFieldDataDataValue fd5 = new DocusignNetApi30.TemplateReferenceFieldDataDataValue();
        fd5.TabLabel = 'TaxID';
        fd5.Value = this.opportunity.Account.Steuernummer__c;

        DocusignNetApi30.TemplateReferenceFieldDataDataValue fd6 = new DocusignNetApi30.TemplateReferenceFieldDataDataValue();
        fd6.TabLabel = 'RegNumber';
        fd6.Value = this.opportunity.Account.HR_Abteilung_HRA_HRB_und_HR_Nummer__c;

        DocusignNetApi30.TemplateReferenceFieldDataDataValue fd7 = new DocusignNetApi30.TemplateReferenceFieldDataDataValue();
        fd7.TabLabel = 'ContactName';
        fd7.Value = this.signer.Contact.Name;

        DocusignNetApi30.TemplateReferenceFieldDataDataValue fd8 = new DocusignNetApi30.TemplateReferenceFieldDataDataValue();
        fd8.TabLabel = 'Title';
        fd8.Value = this.signer.Contact.Title;

        DocusignNetApi30.TemplateReferenceFieldDataDataValue fd9 = new DocusignNetApi30.TemplateReferenceFieldDataDataValue();
        fd9.TabLabel = 'City';
        fd9.Value = this.opportunity.Account.BillingCity;

        docusignTemplate.FieldData = new DocusignNetApi30.TemplateReferenceFieldData();
        docusignTemplate.FieldData.DataValues = new DocusignNetApi30.ArrayOfTemplateReferenceFieldDataDataValue();
        docusignTemplate.FieldData.DataValues.DataValue = new DocusignNetApi30.TemplateReferenceFieldDataDataValue[9];
        docusignTemplate.FieldData.DataValues.DataValue[0] = fd1;
        docusignTemplate.FieldData.DataValues.DataValue[1] = fd2;
        docusignTemplate.FieldData.DataValues.DataValue[2] = fd3;
        docusignTemplate.FieldData.DataValues.DataValue[3] = fd4;
        docusignTemplate.FieldData.DataValues.DataValue[4] = fd5;
        docusignTemplate.FieldData.DataValues.DataValue[5] = fd6;
        docusignTemplate.FieldData.DataValues.DataValue[6] = fd7;
        docusignTemplate.FieldData.DataValues.DataValue[7] = fd8;
        docusignTemplate.FieldData.DataValues.DataValue[8] = fd9;

        return docusignTemplate;
    }


    /*******************************************************************************
    *  Name            : setAuthenticationAssert()
    *  Summary         : Set assert if something goes wrong  
    *  CreatedDate     : 14/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private DocusignNetApi30.RequestRecipientTokenAuthenticationAssertion setAuthenticationAssert() {
        DocusignNetApi30.RequestRecipientTokenAuthenticationAssertion authenticationAssert = new DocusignNetApi30.RequestRecipientTokenAuthenticationAssertion();
        authenticationAssert.AssertionID = 'Your AssertionID Here';
        authenticationAssert.AuthenticationInstant = system.now();
        authenticationAssert.AuthenticationMethod = 'Password';
        authenticationAssert.SecurityDomain = 'YourApp.com';

        return authenticationAssert;
    }


    /*******************************************************************************
    *  Name            : generateRedirectUrl()
    *  Summary         : Generate redirect url from docusign to E2E form    
    *  CreatedDate     : 14/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private DocusignNetApi30.RequestRecipientTokenClientURLs generateRedirectUrl() {
        DocusignNetApi30.RequestRecipientTokenClientURLs clientURLs = new DocusignNetApi30.RequestRecipientTokenClientURLs();
        clientURLs.OnAccessCodeFailed = getURL() + this.opportunity.E2E_Encoded_URL__c + '&event=OnAccessCodeFailed';
        clientURLs.OnCancel = getURL() + this.opportunity.E2E_Encoded_URL__c + '&event=OnCancel';
        clientURLs.OnDecline = getURL() + this.opportunity.E2E_Encoded_URL__c + '&event=OnDecline';
        clientURLs.OnException = getURL() + this.opportunity.E2E_Encoded_URL__c + '&event=OnException';
        clientURLs.OnFaxPending = getURL()+ this.opportunity.E2E_Encoded_URL__c + '&event=OnFaxPending';
        clientURLs.OnIdCheckFailed = getURL() + this.opportunity.E2E_Encoded_URL__c + '&event=OnIdCheckFailed';
        clientURLs.OnSessionTimeout = getURL() + this.opportunity.E2E_Encoded_URL__c + '&event=OnSessionTimeout';
        clientURLs.OnSigningComplete = getURL() + this.opportunity.E2E_Encoded_URL__c + '&event=OnSigningComplete';
        clientURLs.OnTTLExpired = getURL() + this.opportunity.E2E_Encoded_URL__c + '&event=OnTTLExpired';
        clientURLs.OnViewingComplete = getURL() + this.opportunity.E2E_Encoded_URL__c + '&event=OnViewingComplete';

        return clientURLs;
    }


    /*******************************************************************************
    *  Name            : setContactRole(String opptyId)
    *  Summary         : Set contact role    
    *  CreatedDate     : 14/11/2018
    *  ModifiedDate    : -
    *  Parameters      : String opptyId
    *  Returns         : void
    ******************************************************************************/
    public void setContactRole(String opptyId) {
        List<OpportunityContactRole> signerList = [
                SELECT Id, Contact.Email, Contact.Name, Contact.Title
                FROM OpportunityContactRole 
                WHERE OpportunityId = :opptyId AND 
                    IsPrimary = TRUE
                LIMIT 1];

        if (! signerList.isEmpty() ) {
            this.signer = signerList.get(0);
        }
    }


    /*******************************************************************************
    *  Name            : setOpportunity(String opptyId)
    *  Summary         : Set opportunity    
    *  CreatedDate     : 14/11/2018
    *  ModifiedDate    : -
    *  Parameters      : String opptyId
    *  Returns         : void
    ******************************************************************************/
    public void setOpportunity(String opptyId) {
        List<Opportunity> opptyList = [
                SELECT Account.Name,  E2E_Encoded_URL__c, Device_Type__c, Account.Steuernummer__c, Account.HR_Abteilung_HRA_HRB_und_HR_Nummer__c, Account.BillingStreet, Account.BillingCity, 
                    Account.BillingPostalCode, Security_Amount_To_Pay__c, E2E_Active_Substep__c, Security_To_Pay__c, Zahlungsart__c
                FROM Opportunity 
                WHERE Id = :opptyId 
                LIMIT 1];

        if (! opptyList.isEmpty() ) {
            this.opportunity = opptyList.get(0);
        }
    }


    /*******************************************************************************
    *  Name            : getOpportunity()
    *  Summary         : returns the created opportunity
    *  CreatedDate     : 21/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : return Opportunity
    ******************************************************************************/
    public Opportunity getOpportunity() {
        return this.opportunity;
    }


    /*******************************************************************************
    *  Name            : setAuthentication()
    *  Summary         : Set authentication to get DSapi   
    *  CreatedDate     : 14/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private static String setAuthentication(String userId, String password, String integratorsKey) {
        String auth = '<DocuSignCredentials><Username>' + userId 
            + '</Username><Password>' + password 
            + '</Password><IntegratorKey>' + integratorsKey 
            + '</IntegratorKey></DocuSignCredentials>';

        return auth;
    }


    /*******************************************************************************
    *  Name            : dsapi_send()
    *  Summary         : Get the proxy for the dsapi-send wsdl    
    *  CreatedDate     : 14/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : DocusignNetApi30.APIServiceSoap
    ******************************************************************************/
    private static DocusignNetApi30.APIServiceSoap dsapi_send(String webServiceUrl, String auth) {
        // Get DSapi and authenticate
        DocusignNetApi30.APIServiceSoap dsApiSend = new DocusignNetApi30.APIServiceSoap();
        dsApiSend.endpoint_x = webServiceUrl;
        dsApiSend.inputHttpHeaders_x = new Map<String, String>();
        dsApiSend.inputHttpHeaders_x.put('X-DocuSign-Authentication', auth);
        return dsApiSend;
    }


    /*******************************************************************************
    *  Name            : getURL()
    *  Summary         : returns URL   
    *  CreatedDate     : 14/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : String
    ******************************************************************************/
    private String getURL() {
        String popURL = URL.getSalesforceBaseUrl().toExternalForm();
        if (this.opportunity.Device_Type__c == 'Mobile') {
            return popURL + '/apex/e2eformmobpl?source=';
        } else {
            return popURL + '/apex/e2eformpl?source=';
        }
    }


    /*******************************************************************************
    *  Name            : deleteDocusignStatuses(String opptyId, Set<String> pdfNamesSet)
    *  Summary         : delete docusign status and envelope from docusign
    *  CreatedDate     : 20/11/2018
    *  ModifiedDate    : -
    *  Parameters      : String opptyId, Set<String> pdfNamesSet
    *  Returns         : void
    ******************************************************************************/
    @future(callout=true)
    public static void deleteDocusignStatuses(String opptyId, Set<String> pdfNamesSet) {
        List<dsfs__DocuSign_Status__c> allDocusignStatusesList = [
            SELECT Id, dsfs__DocuSign_Envelope_ID__c, dsfs__Opportunity__c, dsfs__Envelope_Status__c, 
                (SELECT Id, Name FROM Attachments WHERE Name IN :pdfNamesSet)
            FROM dsfs__DocuSign_Status__c 
            WHERE dsfs__Opportunity__c = :opptyId
            LIMIT 100];

        List<dsfs__DocuSign_Status__c> statusListToDelete = new List<dsfs__DocuSign_Status__c>();
        Set<String> opptyAttachNamesSet = new Set<String>();
        Set<String> envelopeIdsSet = new Set<String>();

        for (dsfs__DocuSign_Status__c docusignStatus : allDocusignStatusesList) {
            for (Attachment attach : docusignStatus.Attachments) {
                opptyAttachNamesSet.add(attach.Name);

                if ( ! statusListToDelete.contains(docusignStatus) ) statusListToDelete.add(docusignStatus);
                if ( ! envelopeIdsSet.contains(docusignStatus.dsfs__DocuSign_Envelope_ID__c) ) envelopeIdsSet.add(docusignStatus.dsfs__DocuSign_Envelope_ID__c);
            }
        }
        List<Attachment> opptyAttachsList = [
            SELECT Id 
            FROM Attachment 
            WHERE Name IN :opptyAttachNamesSet AND
                ParentId = :opptyId
        ];
        if ( ! statusListToDelete.isEmpty() ) {
            moveEnvelopeToDelete(envelopeIdsSet);

            delete opptyAttachsList;
            delete statusListToDelete;
        }
    }


    /*******************************************************************************
    *  Name            : moveEnvelopeToDelete(Set<String> envelopeIdsSet)
    *  Summary         : Move docusign envelope from Sent to Delete folder    
    *  CreatedDate     : 28/11/2018
    *  ModifiedDate    : -
    *  Parameters      : Set<String> envelopeIdsSet
    *  Returns         : void
    ******************************************************************************/
    private static void moveEnvelopeToDelete(Set<String> envelopeIdsSet) {
        E2E_Docusign_Settings__c docusignSettings = E2E_Docusign_Settings__c.getInstance('Poland');
        String integratorsKey = docusignSettings.IntegratorsKeyDesktop__c;
        String auth = setAuthentication(docusignSettings.UserId__c, docusignSettings.Password__c, integratorsKey);

        DocusignNetApi30.ApiServiceSOAP dsApiSend = dsapi_send(docusignSettings.WebServiceUrl__c, auth);
        DocusignNetApi30.DeleteEnvelopesArg arg = new DocusignNetApi30.DeleteEnvelopesArg();

        DocusignNetApi30.ArrayOfString2 envelope = new DocusignNetApi30.ArrayOfString2();
        envelope.EnvelopeId = new List<String>();
        for (String envelopeId : envelopeIdsSet) {
            envelope.EnvelopeId.add(envelopeId);
        }

        DocusignNetApi30.FolderTypeInfo sentFolder = new DocusignNetApi30.FolderTypeInfo();
        sentFolder.FolderType = 'SentItems';
        sentFolder.FolderName = 'Sent';
        // sentFolder.FolderPath;
        // sentFolder.FolderId;

        arg.EnvelopeIds = envelope;
        arg.AccountId = docusignSettings.AccountId__c;
        arg.FolderFrom = sentFolder;

        dsApiSend.DeleteEnvelopes(arg);
    }


    /*******************************************************************************
    *  Name            : checkDuplicate()
    *  Summary         : Check duplidate before create envelope and get envelopeId
    *  CreatedDate     : 20/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Boolean
    ******************************************************************************/
    private Boolean checkDuplicate(String activeSubstep) {
        Set<String> attachmentNamesToTemplatesSet = new Set<String>();
        Map<String, E2E_Docusign_Templates__c> docusignTemplatesMap = E2E_Docusign_Templates__c.getAll();
        if (activeSubstep == 'Additional Credit Scoring Allowance') {
            attachmentNamesToTemplatesSet.add(docusignTemplatesMap.get('E2E PL Credit Scoring Allowance').Attachment_Name__c);
        } else if (activeSubstep == 'Documents' || 
                   activeSubstep == 'DirectDebitDeposit' ||
                   activeSubstep == 'BankTransferDeposit') {

            attachmentNamesToTemplatesSet.add(docusignTemplatesMap.get('E2E PL Contract').Attachment_Name__c);
            if (this.opportunity.Security_To_Pay__c == 'Kaution') {
                attachmentNamesToTemplatesSet.add(docusignTemplatesMap.get('E2E PL Deposit Agreement').Attachment_Name__c);
            }
        }

        List<dsfs__DocuSign_Status__c> docusignStatusList = [
                SELECT dsfs__DocuSign_Envelope_ID__c, dsfs__Opportunity__c, dsfs__Envelope_Status__c, 
                    (SELECT Id, Name FROM Attachments WHERE Name IN :attachmentNamesToTemplatesSet)
                FROM dsfs__DocuSign_Status__c 
                WHERE dsfs__Opportunity__c = :this.opportunity.Id
                LIMIT 1000];

        if ( ! docusignStatusList.isEmpty() ) {
            for (dsfs__DocuSign_Status__c docusignStatus : docusignStatusList) {
                for (Attachment attach : docusignStatus.Attachments) {
                    if ( attachmentNamesToTemplatesSet.contains(attach.Name) && docusignStatus.dsfs__Envelope_Status__c != 'Declined' ) {
                        this.envelopeId = docusignStatus.dsfs__DocuSign_Envelope_ID__c;
                        return true;
                    }
                }
            }
        }
        return false;
    }


    /*******************************************************************************
    *  Name            : checkContact()
    *  Summary         : check if customer sign documents and go back to change contact data. In this case need to re-sign documents   
    *  CreatedDate     : 29/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Boolean
    ******************************************************************************/
    public Boolean checkContact() {
        List<dsfs__DocuSign_Recipient_Status__c> docusignRecipient = [
                SELECT Name, dsfs__DocuSign_Recipient_Email__c
                FROM dsfs__DocuSign_Recipient_Status__c 
                WHERE dsfs__Parent_Status_Record__r.dsfs__Opportunity__r.Id = :this.opportunity.Id];

        Boolean isSameContact = true;
        if ( ! docusignRecipient.isEmpty() ) {
            if ( (this.signer.Contact.Name != docusignRecipient.get(0).Name) || 
                 (this.signer.Contact.Email != docusignRecipient.get(0).dsfs__DocuSign_Recipient_Email__c) ) {

                isSameContact = false;
            }
        }

        return isSameContact;
    }
}