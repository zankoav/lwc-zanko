/*******************************************************************************
*  FinderCofaceService 
*  
*  Implementation of Finder for Coface Webservice. Get companies based on search request,
*  validation for Credit and Sales. Ability to process selected company for report.
*
******************************************************************************/
public class FinderCofaceService implements Finder {
    private Opportunity sourceObject;
    private List<CreditCompany> companiesList;
    private Credit_Factory_Account__c accountMapping;
    private Credit_Factory_Opportunity__c opportunityMapping;
    public String userSource;


    /*******************************************************************************
    *  Name            : setUserSource(String userSource)
    *  Summary         : Set user source.
    *  CreatedDate     : 08/11/2018
    *  ModifiedDate    : -
    *  Parameters      : String userSource - user source to set
    *  Returns         : void
    ******************************************************************************/
    public void setUserSource(String userSource) {
        this.userSource = userSource;
    }


    /*******************************************************************************
    *  Name            : getUserSource()
    *  Summary         : Return user source.   
    *  CreatedDate     : 08/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : String
    ******************************************************************************/
    public String getUserSource() {
        return this.userSource;
    }


    /*******************************************************************************
    *  Name            : setMapping()
    *  Summary         : Set custom settings for Opportunity and Account
    *  CreatedDate     : 12/02/2018
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    public void setMapping() {
        try {
            accountMapping = Credit_Factory_Account__c.getInstance(CofaceWebservice.CREDIT_SYSTEM_NAME);
            if (accountMapping == null) {
                throw new CreditFactoryException('Account mapping does not exist. ' + CreditFactoryUtilities.CONTACT_ADMIN);
            }
        } catch (Exception e) {
            throw new CreditFactoryException('Account mapping select error. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }

        try {
            opportunityMapping = Credit_Factory_Opportunity__c.getInstance(CofaceWebservice.CREDIT_SYSTEM_NAME);
            if (opportunityMapping == null) {
                throw new CreditFactoryException('Opportunity mapping does not exist. ' + CreditFactoryUtilities.CONTACT_ADMIN);
            }
        } catch (Exception e) {
            throw new CreditFactoryException('Opportunity mapping select error. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : validateMapping()
    *  Summary         : Validate custom setting for Credit System and all fields (should not be null)
    *  CreatedDate     : 12/02/2018
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    public void validateMapping() {
        List<Schema.SObjectField> accountFieldsList = CreditFactoryUtilities.returnAPINames('Credit_Factory_Account__c');
        for (Schema.SObjectField field : accountFieldsList) {
            if (accountMapping.get(field.getDescribe().getName()) == null) {
                throw new CreditFactoryException('All fields in Account mapping should not be null. ' + CreditFactoryUtilities.CONTACT_ADMIN);
            }
        }

        List<Schema.SObjectField> opportunityFieldsList = CreditFactoryUtilities.returnAPINames('Credit_Factory_Opportunity__c');
        for (Schema.SObjectField field : opportunityFieldsList) {
            if (opportunityMapping.get(field.getDescribe().getName()) == null) {
                throw new CreditFactoryException('All fields in Opportunity mapping should not be null. ' + CreditFactoryUtilities.CONTACT_ADMIN);
            }
        }
    }


    /*******************************************************************************
    *  Name            : setSourceObject(String sfdcRecordId)
    *  Summary         : Get required information from object
    *  CreatedDate     : 12/02/2018
    *  Parameters      : sfdcRecordId - id of Salesforce record. In our case - Opportunity id.
    *  Returns         : void
    ******************************************************************************/
    private void setSourceObject(String sfdcRecordId) {
        try {
            String fieldsStringForSQOL = '';
            Map<String, CreditFactory_Opportunity_SOQL__c> soqlFieldsMap = CreditFactory_Opportunity_SOQL__c.getAll();
            for (CreditFactory_Opportunity_SOQL__c field : soqlFieldsMap.values()) {
                fieldsStringForSQOL += field.Field_Name__c + ',';
            }

            String soql = '' +
                    ' SELECT ' + fieldsStringForSQOL;
            List<Schema.SObjectField> accountFieldsList = CreditFactoryUtilities.returnAPINames('Credit_Factory_Account__c');
            for (Schema.SObjectField field : accountFieldsList) {
                Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
                if (fieldDescribe.isCustom()) {
                    soql += 'Account.' + accountMapping.get(fieldDescribe.getName()) + ',';
                }
            }

            soql += ' Account.ShippingCountry, RecordType.Name, Account.Phone, Account.Name, Account.BillingCountryCode, Account.GFN_Nr__c' +
                    ' , Account.HR_Abteilung_HRA_HRB_und_HR_Nummer__c, (SELECT Name FROM Attachments), (SELECT Contact.Id, ' + 
                    ' Contact.Email, Contact.Phone, Contact.LastName, Contact.FirstName, Contact.Name FROM OpportunityContactRoles)' +
                    ' FROM Opportunity' + 
                    ' WHERE Id = :sfdcRecordId';

            sourceObject = Database.query(soql);
        } catch (Exception e) {
            system.debug('Credit Factory Error === ' + e.getMessage());
            throw new CreditFactoryException('Select Opportunity failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }



    /*******************************************************************************
    *  Name            : getSourceObject(String sfdcRecordId)
    *  Summary         : Returns sObject that we need to use for credit request
    *  CreatedDate     : 12/02/2018
    *  Parameters      : sfdcRecordId - id of Salesforce record. In our case - Opportunity id.
    *  Returns         : sObject
    ******************************************************************************/
    public sObject getSourceObject(String sfdcRecordId) {
        setSourceObject(sfdcRecordId);
        return sourceObject;
    }


    /*******************************************************************************
    *  Name            : searchCompany(CreditSystem creditSystem)
    *  Summary         : Returns Credit Company or Companies based on search request
    *  CreatedDate     : 20/02/2018
    *  ModifiedDate    : 02/04/2019
    *  Parameters      : CreditSystem creditSystem – Coface settings
    *  Returns         : List<CreditCompany>
    ******************************************************************************/
    public List<CreditCompany> searchCompany(CreditSystem creditSystem) {
        // Send Request
        try {
            if (this.sourceObject.Account.Steuernummer__c != null) {
                this.companiesList = searchCompanyByTaxId(creditSystem);
            } else {
                this.companiesList = searchCompanyByNameAndAddress(creditSystem);
            }

            if (this.companiesList.isEmpty() && this.userSource == 'E2E Long Form') {
                this.companiesList = searchCompanyByNameAndAddress(creditSystem);
            }
            
            return this.companiesList;
        } catch (Exception e) {
            system.debug('Credit Factory Error === ' + e.getMessage());
            ExceptionLogger.sendException('<br/>Reason: ' + e.getMessage() + '. ' + '<br/>Opportunity Id: ' + this.sourceObject.Id, String.valueOf(e.getStackTraceString()));
            throw new CreditFactoryException('Search company failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : searchCompanyByTaxId(CreditSystem creditSystem)
    *  Summary         : Returns List of Credit Companies based on search by Vat Number.
    *  CreatedDate     : 12/12/2018
    *  ModifiedDate    : 02/04/2019
    *  Parameters      : CreditSystem creditSystem - Coface settings
    *  Returns         : return List<CreditCompany>
    ******************************************************************************/
    public List<CreditCompany> searchCompanyByTaxId(CreditSystem creditSystem) {
        HttpRequest request = CofaceWebservice.generateSearchRequest(
            creditSystem.getEndpointUrl(), creditSystem.getUserName(), creditSystem.getUserPassword(),
            null, this.sourceObject.Account.BillingCountryCode, null, null, this.sourceObject.Account.Steuernummer__c);
        Http h = new Http();
        HttpResponse res = h.send(request);  
        // Get Response and parse it
        String xml = res.getBody();
        Dom.Document domDoc = new Dom.Document();
        domDoc.load(xml);
        Dom.XMLNode xmldom = domDoc.getRootElement();
        Dom.XMLNode globalBody = CofaceWebservice.returnGlobalBody(xmldom);
        return CofaceWebservice.returnSearchCompany(globalBody);
    }


    /*******************************************************************************
    *  Name            : searchCompanyByNameAndAddress(CreditSystem creditSystem)
    *  Summary         : Return Credit Companies based on search by Name and Address.
    *  CreatedDate     : 12/12/2018
    *  ModifiedDate    : -
    *  Parameters      : CreditSystem creditSystem - Coface settings
    *  Returns         : return List<CreditCompany>
    ******************************************************************************/
    public List<CreditCompany> searchCompanyByNameAndAddress(CreditSystem creditSystem) {
        HttpRequest request = CofaceWebservice.generateSearchRequest(
                creditSystem.getEndpointUrl(), creditSystem.getUserName(), creditSystem.getUserPassword(),
                this.sourceObject.Name, this.sourceObject.Account.BillingCountryCode, 
                this.sourceObject.Account.BillingPostalCode, this.sourceObject.Account.BillingCity, null);
        Http h = new Http();
        HttpResponse res = h.send(request);        
        // Get Response and parse it
        String xml = res.getBody();
        Dom.Document domDoc = new Dom.Document();
        domDoc.load(xml);
        Dom.XMLNode xmldom = domDoc.getRootElement();
        Dom.XMLNode globalBody = CofaceWebservice.returnGlobalBody(xmldom);
        return CofaceWebservice.returnSearchCompany(globalBody);
    }


    /*******************************************************************************
    *  Name            : isSales()
    *  Summary         : Check Sales Profile
    *  CreatedDate     : 12/02/2018
    *  Parameters      : 
    *  Returns         : Boolean – returns TRUE if sales profile exists in custom setting
    ******************************************************************************/
    public Boolean isSales() {
        String profileName = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
        if (CreditSystemSalesProfile__c.getInstance(profileName) != null) {
            return true;
        }
        return false;
    }


    /*******************************************************************************
    *  Name            : isOrderInformationUpdated()
    *  Summary         : check order additional information    
    *  CreatedDate     : 12/02/2018
    *  ModifiedDate    : 
    *  Parameters      : -
    *  Returns         : Boolean
    ******************************************************************************/
    public Boolean isOrderInformationUpdated() {
        // Now it doesn't work for Creditsafe
        return false;
    }


    /*******************************************************************************
    *  Name            : validate()
    *  Summary         : Validation data method.
    *  CreatedDate     : 12//2016
    *  Parameters      : 
    *  Returns         : 
    ******************************************************************************/
    public void validate() {
        validateClosedWon();
        validateBlackList();
        validateProcessedOpportunity();

        // Validation if Sales
        if (isSales()) {
            validateDesiredPaymentDetails();
            validateRequiredFields();
        }   
    }


    /*******************************************************************************
    *  Name            : validateBlackList()
    *  Summary         : Check if Company is in black list.
    *  CreatedDate     : 12/02/2018
    *  Parameters      : 
    *  Returns         : 
    ******************************************************************************/
    private void validateBlackList() {
        String classStreet = CreditFactoryUtilities.getStreet(this.sourceObject.Account.BillingStreet);
        String classHousenumber = CreditFactoryUtilities.getHousenumber(this.sourceObject.Account.BillingStreet);
        String accountName = (String)this.sourceObject.getSObject('Account').get('Name');
        String gfnNumber = (String)this.sourceObject.getSObject('Account').get('GFN_Nr__c');
        String city = (String)this.sourceObject.getSObject('Account').get('BillingCity');
        String country = String.valueOf(this.sourceObject.getSObject('Account').get('BillingCountry')).substringBefore('-');
        String countryCode = String.valueOf(this.sourceObject.getSObject('Account').get('BillingCountryCode')).substring(0, 2);
        String postalCode = (String)this.sourceObject.getSObject('Account').get('BillingPostalCode');
        String accountStreetHousenumber = '';
        if (classStreet != null && classHousenumber != null) {
            accountStreetHousenumber = classStreet.toUpperCase() + ' ' + classHousenumber.toUpperCase();
        }

        List<Contact> accountContacts = [
                SELECT FirstName, LastName, Email, Phone, MobilePhone
                FROM Contact
                WHERE AccountId = :(String)this.sourceObject.get('AccountId')
                LIMIT 1000];
        List<String> contactsEmailsSet = new List<String>();
        List<String> contactsNamesSet = new List<String>();
        List<String> contactsPhonesSet = new List<String>();
        for (Contact con : accountContacts) {
            if (con.Email != null) {
                contactsEmailsSet.add(con.Email.toUpperCase());
            }

            String firstName = '';
            if (con.FirstName != null) {
                firstName = con.FirstName;
            }

            String name1 = (firstName.toUpperCase() + ' ' + con.LastName.toUpperCase()).removeStart(' ');
            contactsNamesSet.add(name1);
            String name2 = (con.LastName.toUpperCase() + ' ' + firstName.toUpperCase()).removeEnd(' ');
            contactsNamesSet.add(name2);

            if (con.Phone != null) {
                contactsPhonesSet.add(con.Phone);
            }
            if (con.MobilePhone != null) {
                contactsPhonesSet.add(con.MobilePhone);
            }
        }

        String taxId = (String)this.sourceObject.getSObject('Account').get(this.accountMapping.Tax_id__c);
        String vatNumber = (String)this.sourceObject.getSObject('Account').get(this.accountMapping.Vat_number__c);
        String tradeRegisterNumber = (String)this.sourceObject.getSObject('Account').get('HR_Abteilung_HRA_HRB_und_HR_Nummer__c');
        String iban = (String)this.sourceObject.get('IBAN__c');

        List<Credit_Black_List_Company__c> blackListCompaniesList = [
                SELECT Customer_Full_Name__c, Trade_Register_Number__c, VATReg_Number__c, Reg_Address_Address_Lines__c, 
                        Reg_Address_City__c, Reg_Address_Country__c, Reg_Address_Zip_Code__c, Primary_Phone__c, Primary_Email__c, 
                        Primary_Contact__c, IBAN__c, Name, Comment__c, TAX_ID__c
                FROM Credit_Black_List_Company__c
                WHERE Customer_Id__c != null AND Customer_Id__c = :countryCode AND
                        ((Customer_Full_Name__c != null AND Customer_Full_Name__c = :accountName) OR 
                        (TAX_ID__c != null AND TAX_ID__c = :taxId) OR
                        (VATReg_Number__c != null AND VATReg_Number__c = :vatNumber) OR
                        (Trade_Register_Number__c != null AND Trade_Register_Number__c = :tradeRegisterNumber) OR
                        (Reg_Address_Address_Lines__c != null AND Reg_Address_Address_Lines__c  = :accountStreetHousenumber AND
                                Reg_Address_City__c != null AND Reg_Address_City__c = :city AND
                                Reg_Address_Zip_Code__c != null AND Reg_Address_Zip_Code__c = :postalCode) OR
                        (Primary_Phone__c != null AND Primary_Phone__c IN :contactsPhonesSet) OR 
                        (Primary_Email__c != null AND Primary_Email__c IN :contactsEmailsSet) OR
                        (Primary_Contact__c != null AND Primary_Contact__c IN :contactsNamesSet) OR
                        (IBAN__c != null AND IBAN__c = :iban) OR
                        Name = :gfnNumber)
                LIMIT 1];

        if ( ! blackListCompaniesList.isEmpty()) {
            Credit_Black_List_Company__c blackListCompany = blackListCompaniesList.get(0);
            String errorMessage = '<strong>BLACK LIST.</strong> Company found in black list. Please refer to credit. ';
            errorMessage = errorMessage + 'Click <a target="_blank" href="/' + blackListCompany.Id + '">here</a>.';

            errorMessage += '<br/><br/>Matched fields:<br/><ul>';
            if (blackListCompany.Customer_Full_Name__c != null && blackListCompany.Customer_Full_Name__c == accountName) {
                errorMessage += '<li>Account Name: ' + accountName + '</li>';
            }

            if (blackListCompany.TAX_ID__c != null && blackListCompany.TAX_ID__c == taxId) {
                errorMessage += '<li>Tax Id: ' + taxId + '</li>';
            }

            if (blackListCompany.VATReg_Number__c != null && blackListCompany.VATReg_Number__c == vatNumber) {
                errorMessage += '<li>VAT Number: ' + vatNumber + '</li>';
            }

            if (blackListCompany.Trade_Register_Number__c != null && blackListCompany.Trade_Register_Number__c == tradeRegisterNumber) {
                errorMessage += '<li>Trade Register Number: ' + tradeRegisterNumber + '</li>';
            }

            if (blackListCompany.Reg_Address_Address_Lines__c != null && blackListCompany.Reg_Address_Address_Lines__c == accountStreetHousenumber && 
                    blackListCompany.Reg_Address_City__c != null && blackListCompany.Reg_Address_City__c == city && 
                    blackListCompany.Reg_Address_Zip_Code__c != null && blackListCompany.Reg_Address_Zip_Code__c == postalCode) {
                errorMessage += '<li>Registered Address:<br/>' + accountStreetHousenumber + '<br/>' + postalCode + ' ' + city + '<br/>' + country + '</li>';
            }

            if (blackListCompany.Primary_Phone__c != null && contactsPhonesSet.contains(blackListCompany.Primary_Phone__c)) {
                errorMessage += '<li>Contact Phone Number: ' + blackListCompany.Primary_Phone__c + '</li>';
            }

            if (blackListCompany.Primary_Email__c != null && contactsEmailsSet.contains(blackListCompany.Primary_Email__c.toUpperCase())) {
                errorMessage += '<li>Contact Email: ' + blackListCompany.Primary_Email__c + '</li>';
            }

            if (blackListCompany.Primary_Contact__c != null && contactsNamesSet.contains(blackListCompany.Primary_Contact__c.toUpperCase())) {
                errorMessage += '<li>Contact Name: ' + blackListCompany.Primary_Contact__c + '</li>';
            }

            if (blackListCompany.IBAN__c != null && blackListCompany.IBAN__c == iban) {
                errorMessage += '<li>IBAN: ' + iban + '</li>';
            }

            if (blackListCompany.Name != null && blackListCompany.Name == gfnNumber) {
                errorMessage += '<li>GFN Number: ' + gfnNumber + '</li>';
            }

            errorMessage += '<ul/>';
            if (blackListCompany.Comment__c != null) {
                errorMessage += '<!--^^' + blackListCompany.Comment__c + '^^-->';
            }

            throw new CreditFactoryException(errorMessage);
        }
    }


    /*******************************************************************************
    *  Name            : validateDesiredPaymentDetails()
    *  Summary         : check desired payment terms fields that it not greater than 7  
    *  CreatedDate     : 12/02/2018
    *  ModifiedDate    : 19/02/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void validateDesiredPaymentDetails() {
        if (! (this.sourceObject.Zahlungsziel_2__c == '7' && this.sourceObject.Rechnungsperiode_2__c == '7' || 
            this.sourceObject.Zahlungsziel_2__c == '15' && this.sourceObject.Rechnungsperiode_2__c == '14')) {
            throw new CreditFactoryException('Desired Billing Period and Desired Payment terms are not available. Available options are: 7+7, 15+14.');
        }
    }


    /*******************************************************************************
    *  Name            : validateClosedWon()
    *  Summary         : Check if Opportunity NOT in Closed Won or Closed Lost Status
    *  CreatedDate     : 12/02/2018
    *  Parameters      : 
    *  Returns         : 
    ******************************************************************************/
    private void validateClosedWon() {
        if (sourceObject.StageName == 'Closed Won' || sourceObject.StageName == 'Closed Lost' || sourceObject.StageName == 'CreditCheck abgelehnt') {
            throw new CreditFactoryException('Opportunity was already closed.');
        }
    }


    /*******************************************************************************
    *  Name            : validateRequiredFields()
    *  Summary         : Check Required Fields
    *  CreatedDate     : 12/02/2018
    *  Parameters      : 
    *  Returns         : 
    ******************************************************************************/
    private void validateRequiredFields() {
        String requiredFields = '';

        if (sourceObject.RecordType.Name == 'Euroshell' && sourceObject.Probability >= 40) {
            try {
                requiredFields += validateField('Account','Business_Street__c',sourceObject);
                requiredFields += validateField('Account','Postal_Code__c',sourceObject);
                requiredFields += validateField('Account','City__c',sourceObject);
                requiredFields += validateField('Account','Country__c',sourceObject);
                requiredFields += validateField('Account','Type__c',sourceObject);
                requiredFields += validateField('Account','Number_of_employees__c',sourceObject);   
                requiredFields += validateField('Opportunity','Fuel_consumption_l_month__c',sourceObject);
                requiredFields += validateField('Opportunity','Product__c',sourceObject);
                requiredFields += validateField('Opportunity','Number_of_Cards__c',sourceObject);
                requiredFields += validateField('Opportunity','Current_Payment_Method__c',sourceObject);
            } catch (Exception e) {
                CreditFactoryUtilities.displayMessage('error','Error parsing sObject. ' + CreditFactoryUtilities.CONTACT_ADMIN);
                system.debug('Credit Factory === ' + e.getMessage());
            }
        } else if (sourceObject.RecordType.Name == 'Euroshell' && sourceObject.Probability >= 15) {
            try {
                requiredFields += validateField('Opportunity','Current_Payment_Method__c',sourceObject);
                requiredFields += validateField('Opportunity','Payment_Terms__c',sourceObject);
                requiredFields += validateField('Opportunity','Product__c',sourceObject);
                requiredFields += validateField('Opportunity','Payment_Method__c',sourceObject);
                requiredFields += validateField('Opportunity','Number_of_Cards__c',sourceObject);   
            } catch (Exception e) {
                CreditFactoryUtilities.displayMessage('error','Error parsing sObject. ' + CreditFactoryUtilities.CONTACT_ADMIN);
                system.debug('Credit Factory === ' + e.getMessage());   
            }
        }
        if (requiredFields != '') {
            requiredFields = requiredFields.removeEnd(', ');
            throw new CreditFactoryException('Please fill required fields: ' + requiredFields);
        }
    }


    /*******************************************************************************
    *  Name            : redirectToReport(String companyId)
    *  Summary         : Redirect to Create Report page
    *  CreatedDate     : 12/02/2018
    *  Parameters      : CreditCompany company - Credit Company from search response
    *  Returns         : PageReference
    ******************************************************************************/
    public PageReference redirectToReport(CreditCompany company) {
        return new PageReference('/apex/CreditFactoryReport?creditSystemCompanyNumber=' + company.identificationnumber + '&opportunityId=' + this.sourceObject.Id);
    }


    /*******************************************************************************
    *  Name            : validateField(String objectName, String fieldName, sObject sourceObject)
    *  Summary         : Utility method to checkfield
    *  CreatedDate     : 12/02/2018
    *  Parameters      : objectName – name of sObject, fieldName – API Name of field, sourceObject – sObject
    *  Returns         : String – error message
    ******************************************************************************/
    public String validateField(String objectName, String fieldName, sObject sourceObject) {
        String errorMessage = '';

        if (objectName == 'Opportunity') {
            if (sourceObject.get((String)opportunityMapping.get(fieldName)) == null) {
                String label = CreditFactoryUtilities.returnLabelOfField(objectName,(String)opportunityMapping.get(fieldName));
                errorMessage = objectName.capitalize() + ': ' + label + ', ';
            }
        } else if (objectName == 'Account') {
            if (sourceObject.getSObject('Account').get((String)accountMapping.get(fieldName)) == null) {
                String label = CreditFactoryUtilities.returnLabelOfField(objectName,(String)accountMapping.get(fieldName));
                errorMessage = objectName.capitalize() + ': ' + label + ', ';
            }   
        }

        return errorMessage;
    }


    /*******************************************************************************
    *  Name            : validateProcessedOpportunity()
    *  Summary         : check processed by field    
    *  CreatedDate     : 12/02/2018
    *  ModifiedDate    : 
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void validateProcessedOpportunity() {
        if (this.sourceObject.bearbeitet_von__c != null) {
            throw new CreditFactoryException('Opportunity is already processed.');
        }
    }


    /*******************************************************************************
    *  Name            : checkDuplicates()
    *  Summary         : if duplicates is existed then stop credit process    
    *  CreatedDate     : 12/02/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void checkDuplicates() {
        if (isSales()) {
            CreditFactoryUtilities.checkDuplicates(this.sourceObject);
        }
    }
}