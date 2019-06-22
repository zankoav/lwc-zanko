/*******************************************************************************
*  ReportCofaceService 
*  
*  Implementation of CreditReport for Coface Webservice. Get company from webservice, validation, 
*  flows for Credit and Sales users.
*
******************************************************************************/
public class ReportCofaceService implements CreditReport {
    private Opportunity sourceObject;
    private CreditCompany company;
    private List<CreditCompanyEmployee> companyEmployeesList;
    private Decimal buffer;
    private String riskCategory;
    private Decimal securityLevel;
    private Decimal creditLimitWeeklyPlus7;
    private Decimal maxCreditLimitWeeklyPlus7;
    private Decimal maxValueWeeklyPlus7;
    private Decimal depositWeeklyPlus7;
    private Decimal creditLimitBiWeeklyPlus14;
    private Decimal maxCreditLimitBiWeeklyPlus14;
    private Decimal maxValueBiWeeklyPlus14;
    private Decimal depositBiWeeklyPlus14;
    private Integer billingPeriod;
    private Integer paymentTerms;
    private Decimal creditLimit;
    private Decimal maxCreditLimit;
    private Decimal maxValue;
    private Decimal deposit;
    private CreditFactoryDecision decision;
    private transient String xmlResponseBody;
    private transient Blob attachmentBody;
    private String creditSystemCompanyNumber;
    private Set<String> errorsSet;
    private Credit_Factory_Account__c accountMapping;
    private Credit_Factory_Opportunity__c opportunityMapping; 
    private String COMPANY_FORM = CreditFactoryUtilities.returnLabelOfField('Account','Gesellschaftsform__c');
    private String TAX_ID = CreditFactoryUtilities.returnLabelOfField('Account','Steuernummer__c');
    private String VAT_NUMBER = CreditFactoryUtilities.returnLabelOfField('Account','Umsatzsteuer_ID__c');
    private String TRADE_REGISTER_NUMBER = CreditFactoryUtilities.returnLabelOfField('Account','HR_Abteilung_HRA_HRB_und_HR_Nummer__c');
    public final String ADDRESS_ERROR = 'Address';
    public final String COMPANY_NAME_ERROR = 'CompanyName';
    public final String CONTACT_ERROR = 'Contact';
    public final String CONTACT_ROLE_ERROR = 'ContactRole';
    public final String TAX_ID_ERROR = 'TaxId';
    public final String VAT_NUMBER_ERROR = 'VatNumber';
    public final String TRADE_REGISTER_NUMBER_ERROR = 'TradeRegisterNumber';
    public final String LOST_OPPORTUNITY_ERROR = 'LostOpportunity';
    public final String PIT_ERROR = 'PIT';
    public Credit_Factory_Report__c existingCreditReport;
    private String errorToRequestOrder;
    public Boolean isReportExists;
    public String internalId;
    public Boolean isUpdateTooOld;
    public String userSource;


    /*******************************************************************************
    *  Name            : setUserSource(String userSource)
    *  Summary         : set user source    
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
    *  Summary         : return user source     
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
    *  CreatedDate     : 13/02/2018
    *  Parameters      : 
    *  Returns         : 
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
    *  Name            : setSourceObject(String sfdcRecordId)
    *  Summary         : Get required information from object
    *  CreatedDate     : 13/02/2018
    *  Parameters      : sfdcRecordId - id of Salesforce record. In our case - Opportunity id.
    *  Returns         : void
    ******************************************************************************/
    public void setSourceObject(String sfdcRecordId) {
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
            soql += ' Account.ShippingCountry, Account.ShippingStreet, Account.ShippingState, Account.ShippingPostalCode, ' +
                    ' Account.ShippingCity, RecordType.Name, Account.Name, Account.GFN_Nr__c, Account.BillingCountryCode, ' + 
                    ' Account.HR_Abteilung_HRA_HRB_und_HR_Nummer__c, (SELECT Contact.Id, Contact.Email, Contact.Phone, ' + 
                    ' Contact.LastName, Contact.FirstName, Contact.Name, IsPrimary, Role FROM OpportunityContactRoles) ' +
                    ' FROM Opportunity' + 
                    ' WHERE Id = :sfdcRecordId';
            sourceObject = Database.query(soql);    
        } catch (Exception e) {
            System.debug('Credit Factory Error === ' + e.getMessage());
            throw new CreditFactoryException('Select Opportunity failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : getSourceObject()
    *  Summary         : Returns sObject that we need to use for credit request
    *  CreatedDate     : 13/02/2018
    *  Parameters      : 
    *  Returns         : sObject - Opportunity 
    ******************************************************************************/
    public sObject getSourceObject() {
        return this.sourceObject;
    }


    /*******************************************************************************
    *  Name            : setXmlResponse(CreditSystem creditSystem, String companyId)
    *  Summary         : Get data for company (no need to create XML body because of webservice class)
    *  CreatedDate     : 13/02/2018
    *  Parameters      : creditSystem - credit system
                         companyId - parameter value from search page,
    *  Returns         : 
    ******************************************************************************/
    public void setXmlResponse(CreditSystem creditSystem, String companyId) {
        // Send request for report
        HttpRequest request;
        try {
            request = CofaceWebservice.generateReportRequest(
                creditSystem.getEndpointUrl(), creditSystem.getUserName(), creditSystem.getUserPassword(), 
                companyId);
            Http h = new Http();
            HttpResponse response = h.send(request);
            this.xmlResponseBody = response.getBody();
            this.creditSystemCompanyNumber = companyId;
        } catch (Exception e) {
            System.debug('Credit Factory === ' + request.getBody());
            String errorMessage = 'Error when sending request for report. ' + CreditFactoryUtilities.CONTACT_ADMIN;
            throw new CreditFactoryException(errorMessage);
        }

        // Send request for PDF attachment
        HttpRequest requestPdf;
        try {
            requestPdf = CofaceWebservice.generatePdfReportRequest(
                creditSystem.getEndpointUrl(), creditSystem.getUserName(), creditSystem.getUserPassword(), 
                companyId, '9997');
            Http h = new Http();
            HttpResponse response = h.send(requestPdf);
            this.attachmentBody = CofaceWebservice.getBinaryAttachment(response.getBody());
        } catch (Exception e) {
            System.debug('Credit Factory === ' + requestPdf.getBody());
            String errorMessage = 'Error when sending request for report. ' + CreditFactoryUtilities.CONTACT_ADMIN;
            throw new CreditFactoryException(errorMessage);
        }
    }


    /*******************************************************************************
    *  Name            : getXmlResponse()
    *  Summary         : Returns xml reponse after report request sending
    *  CreatedDate     : 13/02/2018
    *  Parameters      : String - xml 
    *  Returns         : sObject
    ******************************************************************************/
    public String getXmlResponse() {
        return this.xmlResponseBody;
    }


    /*******************************************************************************
    *  Name            : setCompany()
    *  Summary         : Send request for Company details
    *  CreatedDate     : 13/02/2018
    *  Parameters      : creditSystem - credit system
                         companyId - parameter value from search page
    *  Returns         : 
    ******************************************************************************/
    public void setCompany(CreditSystem creditSystem, String companyId) {
        if (this.existingCreditReport != null) {
            this.company = getExistingReportCompany();
        } else {
            isCreditReportAvailable(creditSystem, companyId);
            if (this.isReportExists == false) {
                return;
            }

            setXmlResponse(creditSystem, companyId);

            try {
                String xml = this.xmlResponseBody;
                Dom.Document domDoc = new Dom.Document();
                domDoc.load(xml);
                Dom.XMLNode xmldom = domDoc.getRootElement();
                Dom.XMLNode globalBody = CofaceWebservice.returnGlobalBody(xmldom);

                Boolean isValidreport = CofaceWebservice.checkResponseForFault(globalBody);
                if ( ! isValidreport ) {
                    throw new CreditFactoryException('Internal Credit System Error');
                }

                Dom.XMLNode xmlReport = CofaceWebservice.returnInnerXmlReport(globalBody);
                String dateOfLastMajorUpdateString = CofaceWebservice.returnDateOfLastMajorUpdate(xmlReport);
                if (dateOfLastMajorUpdateString != null) {
                    Date dateOfLastMajorUpdate = Date.newInstance(Integer.valueOf(dateOfLastMajorUpdateString.substring(0, 4)), 
                        Integer.valueOf(dateOfLastMajorUpdateString.substring(4, 6)), Integer.valueOf(dateOfLastMajorUpdateString.substring(6, 8)));
                    if (dateOfLastMajorUpdate.daysBetween(Date.today().addYears(-1)) > 0) {
                        this.isUpdateTooOld = true;
                        this.errorToRequestOrder = 'Date of Last Major Update is too old.';
                        return;
                    }
                } else {
                    this.isUpdateTooOld = true;
                    this.errorToRequestOrder = 'Date of Last Major Update is unknown.';
                    return;
                }

                this.company = CofaceWebservice.returnReportCompany(globalBody, this.creditSystemCompanyNumber);
            } catch (Exception e) {
                System.debug('Credit Factory === ' + e.getMessage());
                String errorMessage = 'Set company error. ' + CreditFactoryUtilities.CONTACT_ADMIN;
                throw new CreditFactoryException(errorMessage);
            }
        }
    }


    /*******************************************************************************
    *  Name            : isCreditReportAvailable(CreditSystem creditSystem, String companyId)
    *  Summary         : API Call: Check availability of COFACE SELECT PREMIUM report (Code: 9997)
    *  CreatedDate     : 20/02/2018
    *  ModifiedDate    : 08/01/2019
    *  Parameters      : creditSystem - credit system
                         companyId - parameter value from search page
    *  Returns         : void
    ******************************************************************************/
    public void isCreditReportAvailable(CreditSystem creditSystem, String companyId) {
        try {
            HttpRequest request = CofaceWebservice.generateRequestForCheckAvailability(creditSystem.getEndpointUrl(), 
                creditSystem.getUserName(), creditSystem.getUserPassword(), companyId);
            Http h = new Http();
            HttpResponse response = h.send(request);
            if (response == null || response.getStatusCode() == 400) {
                throw new CreditFactoryException('Bad request. ' + CreditFactoryUtilities.CONTACT_ADMIN);
            }
            if (response.getStatusCode() == 500) {
                System.debug('Credit Factory Error, Internal Server Error === ' + response.getBody());
                throw new CreditFactoryException('Internal Server Error. ' + CreditFactoryUtilities.CONTACT_ADMIN);
            }

            Dom.Document domDoc = new Dom.Document();
            domDoc.load(response.getBody());
            Dom.XMLNode xmldom = domDoc.getRootElement();
            Dom.XMLNode globalBody = CofaceWebservice.returnGlobalBody(xmldom);
            this.isReportExists = CofaceWebservice.isCofaceReportProductAvailable(globalBody);
            
            if ( ! isReportExists ) {
                this.internalId = CofaceWebservice.returnInternalId(globalBody);
                this.errorToRequestOrder = 'COFACE SELECT PREMIUM is not available.';
            }
        } catch (Exception e) {
            throw new CreditFactoryException(e.getMessage()); 
        }
    }


    /*******************************************************************************
    *  Name            : getErrorToRequestOrder()
    *  Summary         : Return error for order request. 
    *  CreatedDate     : 12/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : String
    ******************************************************************************/
    public String getErrorToOrderRequest() {
        return this.errorToRequestOrder;
    }  


    /*******************************************************************************
    *  Name            : getInternalId()
    *  Summary         : Returm Internal Id.    
    *  CreatedDate     : 12/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : String
    ******************************************************************************/
    public String getInternalId() {
        return this.internalId;
    }


    /*******************************************************************************
    *  Name            : getCompany()
    *  Summary         : Returns Company with Credit information
    *  CreatedDate     : 2/11/2016
    *  Parameters      : 
    *  Returns         : CreditCompany
    ******************************************************************************/
    public CreditCompany getCompany() {
        return this.company;
    }


    /*******************************************************************************
    *  Name            : setEmployees()
    *  Summary         : Set employees from credit company
    *  CreatedDate     : 23/02/2018
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    public void setEmployees() {
        try {
            if (this.existingCreditReport != null) {
                this.companyEmployeesList = getExistingReportCompanyEmployees();
            } else {
                if (this.isReportExists == false || this.isUpdateTooOld == true) {
                    return;
                }

                String xml = this.xmlResponseBody;
                Dom.Document domDoc = new Dom.Document();
                domDoc.load(xml);
                Dom.XMLNode xmldom = domDoc.getRootElement();
                Dom.XMLNode globalBody = CofaceWebservice.returnGlobalBody(xmldom);
                Dom.XMLNode xmlReport = CofaceWebservice.returnInnerXmlReport(globalBody);
                this.companyEmployeesList = CofaceWebservice.returnReportCompanyEmployees(xmlReport);
            }
        } catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            String errorMessage = 'Set company employees error. ' + CreditFactoryUtilities.CONTACT_ADMIN;
            throw new CreditFactoryException(errorMessage);
        }
    }


    public void updateEmployees(CreditSystem creditSystem, String companyId) {}


    /*******************************************************************************
    *  Name            : setEmployee(Object employeeFromWSDL)
    *  Summary         : Set employees from credit company
    *  CreatedDate     : 2/11/2016
    *  Parameters      : employeeFromWSDL company employee of credit company
    *  Returns         : void
    ******************************************************************************/
    public List<Object> getEmployees() {
        return this.companyEmployeesList;
    }


    public void setAdditionalCompany(String companyId) {}


    public CreditCompany getAdditionalCompany() {
        return null;
    }


    public void setAdditionalCompanyEmployees(String companyId) {}


    public List<CreditCompanyEmployee> getAdditionalCompanyEmployees() {
        return null;
    }


    /*******************************************************************************
    *  Name            : setExistingCreditReports()
    *  Summary         : Return company employees data.     
    *  CreatedDate     : 27/02/2018
    *  ModifiedDate    : 08/01/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void setExistingCreditReports() {
        List<Credit_Factory_Report__c> creditReportsList = [
                SELECT Credit_System_Number__c, Reference_Number__c, Class_Rating__c, 
                       Turn_Over__c, Legal_Form__c, VAT_Number__c, Tax_Id__c, Trade_Register_Number__c, Date_Legal_Form__c, Register_Number__c,
                       Date_Last_Register_Entry__c, County_Court__c, Payment_Behaviour__c, Staff_Range__c, 
                       Credit_Limit__c, Credit_Limit_Currency__c, Credit_Decision__c, Date_of_Foundation__c,
                       Age_of_Company__c, First_Legal_Form__c, Company_Status__c, Name, Trade_Name__c, 
                       Street__c, Housenumber__c, Postcode__c, City__c, Country__c, Phone__c, Fax__c, Mobile__c, 
                       Email__c, Website__c, Date_Of_Last_Major_Update__c, Name__c, Profit_Loss_Last_Year__c, 
                       Profit_Loss_Year_Before_Last__c, Turn_Over_Last_Year__c,
                       (SELECT Type__c, Name, Date_of_Birth__c, Address__c, Participation_Date__c, 
                               Company_Id__c, Company_Type__c, Company_Role__c, Reported__c 
                        FROM Credit_Factory_Report_Employees__r)
                FROM Credit_Factory_Report__c
                WHERE Opportunity__c = :this.sourceObject.Id AND 
                      CreatedDate > :Date.today().addMonths(-3)
                ORDER BY CreatedDate DESC
                LIMIT 1];
        if ( ! creditReportsList.isEmpty() ) {
            this.existingCreditReport = creditReportsList.get(0);
        }
    }



    /*******************************************************************************
    *  Name            : getExistingReportCompany()
    *  Summary         : Return company from Credit Factory Report object.
    *  CreatedDate     : 23/10/2017
    *  ModifiedDate    : 08/01/2019
    *  Parameters      : -
    *  Returns         : CreditCompany
    ******************************************************************************/
    private CreditCompany getExistingReportCompany() {
        CreditCompany company = new CreditCompany();
        company.creditSystemCompanyNumber = this.existingCreditReport.Credit_System_Number__c;
        company.referencenumber = this.existingCreditReport.Reference_Number__c;
        company.classRating = this.existingCreditReport.Class_Rating__c;
        company.turnOver = this.existingCreditReport.Turn_Over__c;
        company.legalform = this.existingCreditReport.Legal_Form__c;
        company.vatid = this.existingCreditReport.VAT_Number__c;
        company.taxnumber = this.existingCreditReport.Tax_Id__c;
        company.tradeRegisterNumber = this.existingCreditReport.Trade_Register_Number__c;
        company.datelegalform = this.existingCreditReport.Date_Legal_Form__c;
        company.registerNumber = this.existingCreditReport.Register_Number__c;
        company.datelastregisterentry = this.existingCreditReport.Date_Last_Register_Entry__c;
        company.countyCourt = this.existingCreditReport.County_Court__c;
        company.paymentBehaviour = this.existingCreditReport.Payment_Behaviour__c;
        company.staffcompanyrange = this.existingCreditReport.Staff_Range__c;
        company.creditLimit = this.existingCreditReport.Credit_Limit__c;
        company.creditLimitCurrency = this.existingCreditReport.Credit_Limit_Currency__c;
        company.creditDecision = this.existingCreditReport.Credit_Decision__c;
        company.dateoffoundation = this.existingCreditReport.Date_of_Foundation__c;
        company.ageofcompany = this.existingCreditReport.Age_of_Company__c;
        company.firstlegalform = this.existingCreditReport.First_Legal_Form__c;
        company.status = this.existingCreditReport.Company_Status__c;
        company.name = this.existingCreditReport.Name__c;
        company.tradename = this.existingCreditReport.Trade_Name__c;
        company.street = this.existingCreditReport.Street__c;
        company.housenumber = this.existingCreditReport.Housenumber__c;
        company.postcode = this.existingCreditReport.Postcode__c;
        company.city = this.existingCreditReport.City__c;
        company.country = this.existingCreditReport.Country__c;
        company.phone = this.existingCreditReport.Phone__c;
        company.fax = this.existingCreditReport.Fax__c;
        company.mobile = this.existingCreditReport.Mobile__c;
        company.email = this.existingCreditReport.Email__c;
        company.website = this.existingCreditReport.Website__c;
        company.identificationnumber = this.existingCreditReport.Credit_System_Number__c;
        company.dateOfLastMajorUpdate = this.existingCreditReport.Date_Of_Last_Major_Update__c;
        company.profitLossLastYear = this.existingCreditReport.Profit_Loss_Last_Year__c;
        company.profitLossYearBeforeLast = this.existingCreditReport.Profit_Loss_Year_Before_Last__c;
        company.turnOverLastYear = this.existingCreditReport.Turn_Over_Last_Year__c;
        return company;
    }


    /*******************************************************************************
    *  Name            : getExistingReportCompanyEmployees()
    *  Summary         : return company from Credit Factory Report Employee object      
    *  CreatedDate     : 23/09/2017
    *  ModifiedDate    : 20/04/2017
    *  Parameters      : -
    *  Returns         : List<CreditCompanyEmployee>
    ******************************************************************************/
    private List<CreditCompanyEmployee> getExistingReportCompanyEmployees() {
        List<CreditCompanyEmployee> employeesList = new List<CreditCompanyEmployee>();
        for (Credit_Factory_Report_Employee__c existingEmployee : this.existingCreditReport.Credit_Factory_Report_Employees__r) {
            CreditCompanyEmployee employee = new CreditCompanyEmployee();
            employee.type = existingEmployee.Type__c;
            employee.enumber = existingEmployee.Id;
            employee.ename = existingEmployee.Name;
            employee.dateofbirth = existingEmployee.Date_of_Birth__c;
            employee.address = existingEmployee.Address__c;
            employee.participationdate = existingEmployee.Participation_Date__c;
            employee.companyId = existingEmployee.Company_Id__c;
            employee.companyType = existingEmployee.Company_Type__c;
            employee.companyRole = existingEmployee.Company_Role__c;
            employee.Reported = existingEmployee.Reported__c;
            employeesList.add(employee);
        }
        return employeesList;
    }


    /*******************************************************************************
    *  Name            : isSales()
    *  Summary         : Check Sales Profile
    *  CreatedDate     : 13/02/2018
    *  Parameters      : 
    *  Returns         : Boolean
    ******************************************************************************/
    public Boolean isSales() {
        String profileName = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
        if (CreditSystemSalesProfile__c.getInstance(profileName) != null) {
            return true;
        }
        return false;
    }


    /*******************************************************************************
    *  Name            : getErrorsSet()
    *  Summary         : Returns set of errors and display section to fix error on page
    *  CreatedDate     : 07/11/2016
    *  Parameters      : 
    *  Returns         : Set<String>
    ******************************************************************************/
    public Set<String> getErrorsSet() {
        return this.errorsSet;
    }


    /*******************************************************************************
    *  Name            : validate()
    *  Summary         : Compare information from Coface with Salesforce
    *  CreatedDate     : 2/11/2016
    *  ModifiedDate    : 13/03/2019
    *  Parameters      : 
    *  Returns         : Boolean - returns true if no errors
    ******************************************************************************/
    public Boolean validate() {
        errorsSet = new Set<String>();
        Boolean isValid = true;
        if (isSales()) {
            if ( ! validateAddress()) isValid = false;
            if ( ! validateLegalForm()) isValid = false;
            if ( ! validateCompanyName()) isValid = false;
            if ( ! validateTaxId()) isValid = false;
            if ( ! validateVatNumber()) isValid = false;
            if ( ! validateTradeRegisterNumber()) isValid = false;
            if ( ! validateLostOpportunities()) isValid = false;
            if ( ! validatePIT()) isValid = false;
            validateContact();
        } else {
            if ( ! validateAddress()) isValid = false;
            if ( ! validateLegalForm()) isValid = false;
            if ( ! validateTaxId()) isValid = false;
            if ( ! validateVatNumber()) isValid = false;
            if ( ! validateTradeRegisterNumber()) isValid = false;
            if ( ! validateLostOpportunities()) isValid = false;
            if ( ! validatePIT()) isValid = false;
            validateContact();
        }

        return isValid;
    }


    /*******************************************************************************
    *  Name            : validateAddress()
    *  Summary         : Compare Address information from Coface with Salesforce
    *  CreatedDate     : 2/11/2016
    *  Parameters      : 
    *  Returns         : Boolean - returns TRUE if no errors
    ******************************************************************************/
    public Boolean validateAddress() {
        String billingStreetAndHouseNumber = '';
        if (sourceObject.Account.BillingStreet != null) {
            billingStreetAndHouseNumber = sourceObject.Account.BillingStreet;
        }
        String shippingStreetAndHouseNumber = '';
        if (sourceObject.Account.ShippingStreet != null) {
            shippingStreetAndHouseNumber = sourceObject.Account.ShippingStreet;
        }
        String crefoStreetAndHouseNumber = (company.street != null ? company.street : '') + ' ' + (company.housenumber != null ? company.housenumber : '');
        crefoStreetAndHouseNumber = crefoStreetAndHouseNumber.removeStart(' ').removeEnd(' ');
        String crefoHouseNumberAndStreet = (company.housenumber != null ? company.housenumber : '') + ' ' + (company.street != null ? company.street : '');
        crefoHouseNumberAndStreet = crefoHouseNumberAndStreet.removeStart(' ').removeEnd(' ');
        
        String billingPostalCode = sourceObject.Account.BillingPostalCode;
        String shippingPostalCode = sourceObject.Account.ShippingPostalCode;
        String crefoPostalcode = company.postcode;

        String billingCity = sourceObject.Account.BillingCity;
        String shippingCity = sourceObject.Account.ShippingCity;
        String crefoCity = company.city;
        
        if (! ((validateStreet(billingStreetAndHouseNumber, shippingStreetAndHouseNumber, crefoStreetAndHouseNumber) ||
            validateStreet(billingStreetAndHouseNumber, shippingStreetAndHouseNumber, crefoHouseNumberAndStreet)) &&
            validateCity(billingCity, shippingCity, crefoCity) && 
            validatePostalCode(billingPostalCode, shippingPostalCode, crefoPostalCode))) {
            errorsSet.add(ADDRESS_ERROR);
            String errorMessage = 'Account Billing and Shipping Addresses should be the same as ' +
                CofaceWebservice.CREDIT_SYSTEM_NAME + ' address';
            CreditFactoryUtilities.displayMessage('error',errorMessage);
            return false;
        }

        return true;
    }


    public void doUpdateWithAdditionalAddress() {}


    /*******************************************************************************
    *  Name            : validateStreet(String billingStreet, String shippingStreet, String crefoStreet)
    *  Summary         : Utility method for validateAddress();    
    *  CreatedDate     : 11/11/2016
    *  Parameters      : String billingStreet – Billing Street 
                         String shippingStreet – Shipping Street 
                         String crefoStreet – Street for Coface 
    *  Returns         : Boolean – returns TRUE if all streets are the same
    ******************************************************************************/
    public Boolean validateStreet(String billingStreet, String shippingStreet, String crefoStreet) {
        Boolean isValid = false;
        if (CreditFactoryUtilities.isStringsEquals(billingStreet,shippingStreet) && 
                          CreditFactoryUtilities.isStringsEquals(billingStreet,crefoStreet)) {
            isValid = true;
        }
        return isValid;                       
    }


    /*******************************************************************************
    *  Name            : validateCity(String billingCity, String shippingCity, String crefoCity)
    *  Summary         : Utility method for validateAddress();    
    *  CreatedDate     : 11/11/2016
    *  Parameters      : String billingCity – Billing City 
                         String shippingCity – Shipping City 
                         String crefoCity – City for Coface 
    *  Returns         : Boolean – returns TRUE if all cities are the same
    ******************************************************************************/
    public Boolean validateCity(String billingCity, String shippingCity, String crefoCity) {
        Boolean isValid = false;
        if (CreditFactoryUtilities.isStringsEquals(billingCity,shippingCity) && 
            CreditFactoryUtilities.isStringsEquals(billingCity,crefoCity)) {
            isValid = true;
        }
        return isValid;                       
    }


    /*******************************************************************************
    *  Name            : validatePostalCode(String billingPostalCode, String shippingPostalCode, String crefoPostalCode)
    *  Summary         : Utility method for validateAddress();    
    *  CreatedDate     : 11/11/2016
    *  Parameters      : String billingPostalCode – Billing PostalCode 
                         String shippingPostalCode – Shipping PostalCode 
                         String crefoPostalCode – PostalCode for Coface 
    *  Returns         : Boolean – returns TRUE if all cities are the same
    ******************************************************************************/
    public Boolean validatePostalCode(String billingPostalCode, String shippingPostalCode, String crefoPostalCode) {
        Boolean isValid = false;
        if (CreditFactoryUtilities.isStringsEquals(billingPostalCode,shippingPostalCode) && 
            CreditFactoryUtilities.isStringsEquals(billingPostalCode,crefoPostalCode)) {
            isValid = true;
        }
        return isValid;                       
    }



    /*******************************************************************************
    *  Name            : validateHousenumber(String billingHousenumber, String shippingHousenumber, String crefoHousenumber)
    *  Summary         : Utility method for validateAddress();    
    *  CreatedDate     : 11/11/2016
    *  Parameters      : String billingHousenumber – Billing Housenumber 
                         String shippingHousenumber – Shipping Housenumber 
                         String crefoHousenumber – House number for Coface 
    *  Returns         : Boolean – returns TRUE if all cities are the same
    ******************************************************************************/
    public Boolean validateHouseNumber(String billingHousenumber, String shippingHousenumber, String crefoHousenumber) {
        Boolean isValid = false;
        if (CreditFactoryUtilities.isStringsEquals(billingHousenumber,shippingHousenumber) && 
            CreditFactoryUtilities.isStringsEquals(billingHousenumber,crefoHousenumber)) {
            isValid = true;
        }
        return isValid;                       
    }


    /*******************************************************************************
    *  Name            : validateLegalForm()
    *  Summary         : Compare Legal Form information from Coface with Salesforce
    *  CreatedDate     : 2/11/2016
    *  Parameters      : 
    *  Returns         : Boolean - returns true if no errors
    ******************************************************************************/
    public Boolean validateLegalForm() {
        return true;
    }


    /*******************************************************************************
    *  Name            : validateContact()
    *  Summary         : Check that contact from Coface exists in Salesforce
    *  CreatedDate     : 2/11/2016
    *  ModifiedDate    : 08/11/2018
    *  Parameters      : 
    *  Returns         : Boolean - returns true if no errors
    ******************************************************************************/
    public Boolean validateContact() {
        List<AccountContactRelation> relationsList = [
                SELECT Account.Name, Contact.LastName, Contact.FirstName, Contact.Email, Contact.Phone
                FROM AccountContactRelation
                WHERE AccountId = :this.sourceObject.AccountId];
        Set<String> contactsLastNamesSet = new Set<String>();
        Set<String> contactsFirstAndLastNamesSet = new Set<String>();
        Set<String> contactsEmailsDomainsSet = new Set<String>();
        Set<String> contactsPhonesSet = new Set<String>();
        for (AccountContactRelation contactRelation : relationsList) {
            String firstName = '';
            if (contactRelation.Contact.FirstName != null) {
                firstName = CreditFactoryUtilities.replaceHungarianCharacters(contactRelation.Contact.FirstName).toUpperCase().replace('’', '\'');
            }

            String lastName = CreditFactoryUtilities.replaceHungarianCharacters(contactRelation.Contact.LastName).toUpperCase().replace('’', '\'');
            contactsLastNamesSet.add(lastName);
            contactsFirstAndLastNamesSet.add((firstName + ' ' + lastName).removeStart(' '));
            contactsFirstAndLastNamesSet.add((lastName + ' ' + firstName).removeEnd(' '));

            if (contactRelation.Contact.Email != null) {
                contactsEmailsDomainsSet.add(contactRelation.Contact.Email.substringAfterLast('@').toUpperCase());
            }
            
            if (contactRelation.Contact.Phone != null && contactRelation.Contact.Phone.length() >= 6) {
                String phone = contactRelation.Contact.Phone;
                contactsPhonesSet.add(phone.substring(phone.length() - 6, phone.length()));
            }
        }

        String primaryContactRole = '';
        for (OpportunityContactRole contactRole : this.sourceObject.OpportunityContactRoles) {
            if (contactrole.IsPrimary == true) {
                primaryContactRole = contactRole.Role;
            }
        }

        Boolean isContactExists = false;
        for (CreditCompanyEmployee emp : this.companyEmployeesList) {
            if (emp.ename != null) {
                for (String lastName : contactsLastNamesSet) {
                    if (CreditFactoryUtilities.replaceHungarianCharacters(emp.ename).toUpperCase().replace('\u00a0', ' ').contains(lastName)) {
                        isContactExists = true;
                    }
                }
            }
        }

        if (this.userSource == 'E2E Long Form') {
            for (String firstAndLastName : contactsFirstAndLastNamesSet) {
                if (firstAndLastName == CreditFactoryUtilities.replaceHungarianCharacters(this.company.Name).toUpperCase().replace('’', '\'')) {
                    isContactExists = true;
                }
            }
        } else if (validateCompanyName() == true) {
            for (String firstAndLastName : contactsFirstAndLastNamesSet) {
                if (firstAndLastName == CreditFactoryUtilities.replaceHungarianCharacters(this.sourceObject.Account.Name).toUpperCase().replace('’', '\'')) {
                    isContactExists = true;
                }
            }
        }

        String companyEmailDomain = '';
        if (this.company.email != null) {
            companyEmailDomain = this.company.email.substringAfterLast('@').toUpperCase();
        }

        String companyPhone = '';
        if (this.company.Phone != null && this.company.phone.length() >= 6) {
            companyPhone = this.company.phone.substring(this.company.phone.length() - 6, this.company.phone.length());
        }

        String companyMobile = '';
        if (this.company.mobile != null && this.company.mobile.length() >= 6) {
            companyMobile = this.company.mobile.substring(this.company.mobile.length() - 6, this.company.mobile.length());
        }

        if ( ! (contactsEmailsDomainsSet.contains(companyEmailDomain) || contactsPhonesSet.contains(companyPhone) || contactsPhonesSet.contains(companyMobile) ||
                (primaryContactRole == 'Executive assistant' || primaryContactRole == 'Fleet manager' || primaryContactRole == 'Owner\'s relative') && this.sourceObject.Contact_Role_Confirmation_Call__c != null)) {
            if (this.companyEmployeesList.isEmpty()) {
                if (this.userSource != 'E2E Long Form') {
                    errorsSet.add(CONTACT_ERROR);
                    String errorMessage = 'No directors information for this company';
                    CreditFactoryUtilities.displayMessage('error', errorMessage);
                    if ((primaryContactRole == 'Executive assistant' || primaryContactRole == 'Fleet manager' || primaryContactRole == 'Owner\'s relative')) {
                        errorsSet.add(CONTACT_ROLE_ERROR);
                        CreditFactoryUtilities.displayMessage('error', 'Please choose call with contact role confirmation.'); 
                    }
                }

                return false;
            } else if ( ! isContactExists) {
                if (this.userSource != 'E2E Long Form') {
                    errorsSet.add(CONTACT_ERROR);
                    String errorMessage = CofaceWebservice.CREDIT_SYSTEM_NAME + ' Contact person doesn\'t exist in Account\'s Contacts';
                    CreditFactoryUtilities.displayMessage('error', errorMessage);
                    if ((primaryContactRole == 'Executive assistant' || primaryContactRole == 'Fleet manager' || primaryContactRole == 'Owner\'s relative')) {
                        errorsSet.add(CONTACT_ROLE_ERROR);
                        CreditFactoryUtilities.displayMessage('error', 'Please choose call with contact role confirmation.'); 
                    }
                }

                return false;
            }
        }

        return true;
    }


    /*******************************************************************************
    *  Name            : validateTaxId()
    *  Summary         : Compare Coface tax id with Salesforce    
    *  CreatedDate     : 29/01/2018
    *  ModifiedDate    : 29/01/2018
    *  Parameters      : -
    *  Returns         : Boolean
    ******************************************************************************/
    public Boolean validateTaxId() {
        if (company.taxnumber != '' && company.taxnumber != null && ! CreditFactoryUtilities.isStringsEquals(company.taxnumber, (String)sourceObject.getSobject('Account').get(this.accountMapping.Tax_Id__c))) {
            errorsSet.add(TAX_ID_ERROR);
            String errorMessage = 'Account Tax ID mismatch (' + CofaceWebservice.CREDIT_SYSTEM_NAME + 
                ' to Account ' + TAX_ID + ')';
            CreditFactoryUtilities.displayMessage('error',errorMessage);
            return false;
        }

        return true;
    }


    /*******************************************************************************
    *  Name            : validateVatNumber()
    *  Summary         : Compare Coface tax id with Salesforce    
    *  CreatedDate     : 29/01/2018
    *  ModifiedDate    : 29/01/2018
    *  Parameters      : -
    *  Returns         : Boolean
    ******************************************************************************/
    public Boolean validateVatNumber() {
        if (company.vatid != null && ! CreditFactoryUtilities.isStringsEquals(company.vatid, (String)sourceObject.getSobject('Account').get(this.accountMapping.VAT_Number__c))) {
            errorsSet.add(VAT_NUMBER_ERROR);
            String errorMessage = 'Account VAT number mismatch (' + CofaceWebservice.CREDIT_SYSTEM_NAME + 
                ' to Account ' + VAT_NUMBER + ')';
            CreditFactoryUtilities.displayMessage('error',errorMessage);
            return false;
        }

        return true;
    }


    /*******************************************************************************
    *  Name            : validateTradeRegisterNumber()
    *  Summary         : Compare Creditsafe trade register number with Salesforce    
    *  CreatedDate     : 12/12/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Boolean
    ******************************************************************************/
    public Boolean validateTradeRegisterNumber() {
        if (company.tradeRegisterNumber != null && ! CreditFactoryUtilities.isStringsEquals(company.tradeRegisterNumber, this.sourceObject.Account.HR_Abteilung_HRA_HRB_und_HR_Nummer__c)) {
            errorsSet.add(TRADE_REGISTER_NUMBER_ERROR);
            String errorMessage = 'Account Trade Register Number mismatch (' + CofaceWebservice.CREDIT_SYSTEM_NAME + 
                ' to Account ' + TRADE_REGISTER_NUMBER + ')';
            CreditFactoryUtilities.displayMessage('error',errorMessage);
            return false;
        }

        return true;
    }


    /*******************************************************************************
    *  Name            : validateLostOpportunities()
    *  Summary         : Check for Lost Opportunities relates to current Opportunity's 
                         Account or its Contacts    
    *  CreatedDate     : 02/04/2018
    *  ModifiedDate    : 02/04/2018
    *  Parameters      : -
    *  Returns         : Boolean
    ******************************************************************************/
    private Boolean validateLostOpportunities() {
        // Collect Opportunities related to Account of current opportunity
        List<Opportunity> relatedOpportunitiesList = [
                SELECT StageName, Gruende_verloren__c
                FROM Opportunity
                WHERE AccountId = :this.sourceObject.AccountId];
        List<Opportunity> opportunitiesToCheckList = new List<Opportunity>();
        for (Opportunity opportunity : relatedOpportunitiesList) {
            opportunitiesToCheckList.add(opportunity);
        }

        // Collect Opportunities related with Contacts of current Opportunity's Account
        List<AccountContactRelation> contactRelationsList = [
                SELECT ContactId
                FROM AccountContactRelation
                WHERE AccountId = :this.sourceObject.AccountId];
        Set<Id> relatedContactsIdsSet = new Set<Id>();
        for (AccountContactRelation relation : contactRelationsList) {
            relatedContactsIdsSet.add(relation.ContactId);
        }

        if (! relatedContactsIdsSet.isEmpty()) {
            List<OpportunityContactRole> contactRolesList = [
                    SELECT Opportunity.StageName, Opportunity.Gruende_verloren__c
                    FROM OpportunityContactRole
                    WHERE ContactId IN :relatedContactsIdsSet];
            for (OpportunityContactRole contactRole : contactRolesList) {
                opportunitiesToCheckList.add(contactRole.Opportunity);
            }
        }

        // Check Opportunity stage
        for (Opportunity opportunity : opportunitiesToCheckList) {
            if (opportunity.StageName == 'CreditCheck abgelehnt' || (opportunity.StageName == 'Closed Lost' && 
                opportunity.Gruende_verloren__c == 'Refused Credit')) {
                errorsSet.add(LOST_OPPORTUNITY_ERROR);
                CreditFactoryUtilities.displayMessage('error', 'Credit Check was rejected for one of the Opportunities linked with your Account or its Contacts. Please refer to Credit.');
                return false;
            }
        }

        return true;
    }


    /*******************************************************************************
    *  Name            : validatePIT()
    *  Summary         : Check profit/loss for the last year and year before last and turn over
                            for the last year.
    *  CreatedDate     : 13/03/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Boolean
    ******************************************************************************/
    public Boolean validatePIT() {
        if (! (this.company.dateoffoundation != null && this.company.dateoffoundation.length() == 10 && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(6, 10)), 
                Integer.valueOf(this.company.dateoffoundation.substring(3, 5)), Integer.valueOf(this.company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) < 18)) {
            setBuffer(this.company.classRating);
            setCreditLimitWeeklyPlus7(getBuffer()); // the lowest CL (if the lowest limit is too high, then other limits is also too high)
            if (this.company.profitLossLastYear == null || this.company.profitLossYearBeforeLast == null || this.company.turnOverLastYear == null) {
                errorsSet.add(PIT_ERROR);
                CreditFactoryUtilities.displayMessage('error', 'Financial details missing in the Credit report. Please refer to Credit.');
                return false;
            } else if (Decimal.valueOf(this.company.profitLossLastYear) < 0 || Decimal.valueOf(this.company.profitLossYearBeforeLast) < 0 || 
                    Decimal.valueOf(this.company.turnOverLastYear) * 0.1 < this.creditLimitWeeklyPlus7) {
                errorsSet.add(PIT_ERROR);
                CreditFactoryUtilities.displayMessage('error', 'Financial details require additional review. Please refer to Credit.');
                return false;
            }
        }

        return true;
    }


    /*******************************************************************************
    *  Name            : validateBlackList()
    *  Summary         : Check if Company is in black list.
    *  CreatedDate     : 08/11/2018
    *  ModifiedDate    : -
    *  Parameters      : 
    *  Returns         : Boolean
    ******************************************************************************/
    public Boolean validateBlackList() {
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
            return false;
        } 

        return true;
    }


    public void setParentCompanyId() {}


    public String getParentCompanyId() {
        return null;
    }


    /*******************************************************************************
    *  Name            : validateCompanyName()
    *  Summary         : Check that Account Name is the same as Company Name from Salesforce
    *  CreatedDate     : 2/11/2016
    *  Parameters      : 
    *  Returns         : Boolean - returns true if no errors
    ******************************************************************************/
    public Boolean validateCompanyName() {
        if ( ! CreditFactoryUtilities.isStringsEquals(sourceObject.Account.Name, company.tradename)) {
            errorsSet.add(COMPANY_NAME_ERROR);
            String errorMessage = 'Account Name and ' + CofaceWebservice.CREDIT_SYSTEM_NAME + ' Name mismatch';
            CreditFactoryUtilities.displayMessage('error',errorMessage);
            return false;
        }
        return true;
    }


    /*******************************************************************************
    *  Name            : doUpdateAddress()
    *  Summary         : Update address information in Account based on address from Coface
    *  CreatedDate     : 11/11/2016
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    public void doUpdateAddress() {
        String crefoStreetAndHouseNumber = (this.company.street != null ? this.company.street : '') + ' ' + (this.company.housenumber != null ? this.company.housenumber : '');
        crefoStreetAndHouseNumber = crefoStreetAndHouseNumber.removeStart(' ').removeEnd(' ');
        Account account = new Account(
            Id = sourceObject.AccountId,
            ShippingStreet = crefoStreetAndHouseNumber,
            ShippingPostalCode = this.company.postcode,
            ShippingCity = this.company.city,
            BillingStreet = crefoStreetAndHouseNumber,
            BillingPostalCode = this.company.postcode,
            BillingCity = this.company.city);
        try {
            update account;
            CreditFactoryUtilities.displayMessage('confirm','Address has been updated.');
        } catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Address update failed.'); 
        }

        setSourceObject(sourceObject.Id);
    }


    public void doUpdateWithPostalAddress() {}


    public void doUpdateWithRegisteredAddress() {}


    /*******************************************************************************
    *  Name            : doUpdateCompanyName()
    *  Summary         : Update Account name with Credireform Company Name
    *  CreatedDate     : 11/11/2016
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    public void doUpdateCompanyName() {
        Account account = new Account(
            Id = sourceObject.AccountId,
            Name = company.tradename);

        try {
            update account;
            CreditFactoryUtilities.displayMessage('confirm','Account Name has been updated.');
        } catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Account Name update failed.');    
        }

        setSourceObject(sourceObject.Id);
    }


    public void doUpdateWithAdditionalCompanyName() {}


    /*******************************************************************************
    *  Name            : doUpdateTaxId()
    *  Summary         : Update Account Tax Id with Coface Tax Id
    *  CreatedDate     : 29/01/2018
    *  ModifiedDate    : 29/01/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doUpdateTaxId() {
        Account account = new Account(
            Id = sourceObject.AccountId,
            Steuernummer__c = this.company.taxnumber);
        try {
            update account;
            CreditFactoryUtilities.displayMessage('confirm','Account Tax ID has been updated.');
        } catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            if (e.getMessage().contains('duplicate value found: ')) {
                String duplicateValueError = e.getMessage().substringAfter('duplicate value found: ').substringBeforeLast(':');
                CreditFactoryUtilities.displayMessage('error', duplicateValueError);
            }
            throw new CreditFactoryException('Account Tax ID update failed.');  
        }

        setSourceObject(sourceObject.Id);
    }


    /*******************************************************************************
    *  Name            : doUpdateVatNumber()
    *  Summary         : Update Account Vat Number with Coface Vat Number
    *  CreatedDate     : 29/01/2018
    *  ModifiedDate    : 29/01/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doUpdateVatNumber() {
        Account account = new Account(
            Id = sourceObject.AccountId,
            Umsatzsteuer_ID__c = this.company.vatid);
        try {
            update account;
            CreditFactoryUtilities.displayMessage('confirm','Account VAT number has been updated.');
        } catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            if (e.getMessage().contains('duplicate value found: ')) {
                String duplicateValueError = e.getMessage().substringAfter('duplicate value found: ').substringBeforeLast(':');
                CreditFactoryUtilities.displayMessage('error', duplicateValueError);
            }
            throw new CreditFactoryException('Account VAT number update failed.');  
        }

        setSourceObject(sourceObject.Id);
    }


    /*******************************************************************************
    *  Name            : doUpdateTradeRegisterNumber()
    *  Summary         : Update Account Trade Register Number with Creditsafe Trade Register Number
    *  CreatedDate     : 12/12/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doUpdateTradeRegisterNumber() {
        Account account = new Account(
            Id = sourceObject.AccountId,
            HR_Abteilung_HRA_HRB_und_HR_Nummer__c = this.company.tradeRegisterNumber);
        try {
            update account;
            CreditFactoryUtilities.displayMessage('confirm','Account Trade Register Number has been updated.');
        } catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Account Trade Register Number update failed.');   
        }

        setSourceObject(sourceObject.Id);
    }


    /*******************************************************************************
    *  Name            : updateDefaultFieldSetForValidRecord()
    *  Summary         : Update specific fields in Opportunity by Sales
    *  CreatedDate     : 2/11/2016
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    public void updateDefaultFieldSetForValidRecord() {
        try {
            this.sourceObject.Updated_From_Credit_Factory__c = true;
            if (this.company.classRating != null) {
                this.sourceObject.put(
                    this.opportunityMapping.Credit_System_Rating__c,
                    this.company.classRating);
            }
            if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
                this.sourceObject.put(
                    this.opportunityMapping.Credit_System_Limit__c,
                    Decimal.valueOf(this.company.creditLimit));
            } else {
                this.sourceObject.put(this.opportunityMapping.Credit_System_Limit__c, 0);
            }
            if (this.company.turnOver != null) {
                this.sourceObject.put(
                    this.opportunityMapping.Turn_Over__c, 
                    this.company.turnOver);
            }
            if (this.company.dateoffoundation != null) {
                if (this.company.dateoffoundation.length() == 10) {
                    this.sourceObject.put(
                        this.opportunityMapping.Year_of_foundation__c,
                        this.company.dateoffoundation.substring(6, 10));
                } else if (this.company.dateoffoundation.length() == 4) {
                    this.sourceObject.put(
                        this.opportunityMapping.Year_of_foundation__c,
                        this.company.dateoffoundation.substring(0, 4));
                }
            }
            if (this.company.creditSystemCompanyNumber != null) {
                this.sourceObject.put(
                    this.opportunityMapping.Credit_System_Number__c,
                    this.company.creditSystemCompanyNumber);
            }
            if (this.company.staffcompanyrange != null) {
                this.sourceObject.put(
                    this.opportunityMapping.Number_of_employees__c,
                    this.company.staffcompanyrange);
            }
            this.sourceObject.put(
                this.opportunityMapping.Details_Correct__c,
                'Ja');
            if (this.sourceObject.CF_Stage__c != 'Pending Deposit') {
                this.sourceObject.CF_Stage__c = 'Report generated';
            }
            this.sourceObject.Last_CF_Errors__c = null;
            update this.sourceObject;
            update this.sourceObject.Account;
        } catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Default fields update failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : updateDefaultFieldSetForInvalidRecord()
    *  Summary         : Update specific fields in Opportunity by Sales even with some validation errors    
    *  CreatedDate     : 19/03/2019
    *  ModifiedDate    : 01/04/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void updateDefaultFieldSetForRecord() {
        if (this.company.profitLossLastYear != null && Decimal.valueOf(this.company.profitLossLastYear) != null) {
            this.sourceObject.Profit_loss_last_year__c = Decimal.valueOf(this.company.profitLossLastYear);
        }
        if (this.company.profitLossYearBeforeLast != null && Decimal.valueOf(this.company.profitLossYearBeforeLast) != null) {
            this.sourceObject.Profit_loss_year_before_last__c = Decimal.valueOf(this.company.profitLossYearBeforeLast);
        }
        if (this.company.turnOverLastYear != null && Decimal.valueOf(this.company.turnOverLastYear) != null) {
            this.sourceObject.Turnover_last_year__c = Decimal.valueOf(this.company.turnOverLastYear);
        }
        setRiskCategory(this.company.classRating);
        this.sourceObject.put(this.opportunityMapping.Risk_Category__c, this.riskCategory);
        update this.sourceObject;
    }


    /*******************************************************************************
    *  Name            : getBuffer()
    *  Summary         : Return buffer value
    *  CreatedDate     : 2/11/2016
    *  Parameters      : 
    *  Returns         : String
    ******************************************************************************/
    public Decimal getBuffer() {
        return this.buffer;
    }


    /*******************************************************************************
    *  Name            : setBuffer(String classRating)
    *  Summary         : Calculate buffer
    *  CreatedDate     : 2/11/2016
    *  Parameters      : classRating - Credit Company rating (1, 2, 3, ...)
    *  Returns         : void
    ******************************************************************************/
    public void setBuffer(String classRating) {
        if (classRating != null) {
            if (classRating == '1') {
                this.buffer = 0;
            } else if (classRating == '4') {
                this.buffer = 0.1;
            } else if (classRating == '6') {
                this.buffer = 0.2;
            }
        }
    }


    /*******************************************************************************
    *  Name            : getRiskCategory()
    *  Summary         : Return Risk Category
    *  CreatedDate     : 2/11/2016
    *  Parameters      : 
    *  Returns         : String
    ******************************************************************************/
    public String getRiskCategory() {
        return this.riskCategory;
    }


    /*******************************************************************************
    *  Name            : setRiskCategory(String classRating)
    *  Summary         : Calculate Risk Category
    *  CreatedDate     : 2/11/2016
    *  Parameters      : classRating - Credit Company rating (1, 2, 3, ...)
    *  Returns         : void
    ******************************************************************************/
    public void setRiskCategory(String classRating) {
        if (classRating != null) {
            if (classRating == '1') {
                this.riskCategory = 'Very';
            } else if (classRating == '4') {
                this.riskCategory = 'High';
            } else if (classRating == '6') {
                this.riskCategory = 'Medium';
            }
        }   
    }


    /*******************************************************************************
    *  Name            : getSecurityLevel()
    *  Summary         : Return security level
    *  CreatedDate     : 22/03/2018
    *  ModifiedDate    : 22/03/2018
    *  Parameters      : -
    *  Returns         : String
    ******************************************************************************/
    public Decimal getSecurityLevel() {
        return this.securityLevel;
    }


    /*******************************************************************************
    *  Name            : setSecurityLevel()
    *  Summary         : Calculate security level
    *  CreatedDate     : 22/03/2018
    *  ModifiedDate    : 25/03/2019
    *  Parameters      : classRating - Credit Company rating (1, 2, 3, ...)
    *  Returns         : void
    ******************************************************************************/
    public void setSecurityLevel(String classRating) {
        if (classRating == '1') {
            this.securityLevel = 110;
        } else if (classRating == '4') {
            if (this.company.dateoffoundation != null && this.company.dateoffoundation.length() == 10 && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(6, 10)), 
                    Integer.valueOf(this.company.dateoffoundation.substring(3, 5)), Integer.valueOf(this.company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) < 18) {
                this.securityLevel = 100;
            } else {
                this.securityLevel = 4;
            }
        } else if (classRating == '6') {
            if (this.company.dateoffoundation != null && this.company.dateoffoundation.length() == 10 && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(6, 10)), 
                    Integer.valueOf(this.company.dateoffoundation.substring(3, 5)), Integer.valueOf(this.company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) < 18) {
                this.securityLevel = 100;
            } 
        }
    }


    /*******************************************************************************
    *  Name            : getCreditLimitWeeklyPlus7()
    *  Summary         : Return Credit Limit Weekly Plus 7
    *  CreatedDate     : 2/11/2016
    *  ModifiedDate    : 26/02/2019
    *  Parameters      : 
    *  Returns         : Decimal
    ******************************************************************************/
    public Decimal getCreditLimitWeeklyPlus7() {
        if (this.creditLimitWeeklyPlus7 < 10000) {
            return 10000;
        }

        return (this.creditLimitWeeklyPlus7 / 10000).round(System.RoundingMode.HALF_UP) * 10000;
    }


    /*******************************************************************************
    *  Name            : setCreditLimitWeeklyPlus7(Decimal buffer)
    *  Summary         : Calculate Credit Limit Weekly Plus 7
    *  CreatedDate     : 2/11/2016
    *  ModifiedDate    : 08/11/2018
    *  Parameters      : buffer - 0, 0.1, 0.2 or 0.3
    *  Returns         : void
    ******************************************************************************/
    public void setCreditLimitWeeklyPlus7(Decimal buffer) {
        try {
            this.creditLimitWeeklyPlus7 = ((Decimal)this.sourceObject.get(this.opportunityMapping.Monthly_Volume_Currency__c) * 
                ((7.0 + 7.0)/30.0)*(1.0 + buffer));
        } catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Credit Limit Weekly + 7 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : getMaxCreditLimitWeeklyPlus7()
    *  Summary         : Return Max Credit Limit Weekly Plus 7
    *  CreatedDate     : 16/03/2018
    *  ModifiedDate    : 26/02/2019
    *  Parameters      : -
    *  Returns         : Decimal
    ******************************************************************************/
    public Decimal getMaxCreditLimitWeeklyPlus7() {
        if (this.maxCreditLimitWeeklyPlus7 < 10000) {
            return 10000;
        }

        return (this.maxCreditLimitWeeklyPlus7 / 10000).round(System.RoundingMode.HALF_UP) * 10000;
    }


    /*******************************************************************************
    *  Name            : setMaxCreditLimitWeeklyPlus7()
    *  Summary         : Calculate Max Credit Limit Weekly Plus 7    
    *  CreatedDate     : 16/03/2018
    *  ModifiedDate    : 08/11/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void setMaxCreditLimitWeeklyPlus7() {
        try {
            if (this.company.classRating == '1') {
                setMaxCreditLimitWeeklyPlus7Rating1();
            } else if (this.company.classRating == '4') {
                setMaxCreditLimitWeeklyPlus7Rating4();
            } else if (this.company.classRating == '6') {
                setMaxCreditLimitWeeklyPlus7Rating6();
            }
        } catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Max Credit Limit Weekly + 7 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : setMaxCreditLimitWeeklyPlus7Rating1()
    *  Summary         : Calculate Max Credit Limit Weekly Plus 7 for Rating 1
    *  CreatedDate     : 08/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void setMaxCreditLimitWeeklyPlus7Rating1() {
        this.maxCreditLimitWeeklyPlus7 = 0;
    }


    /*******************************************************************************
    *  Name            : setMaxCreditLimitWeeklyPlus7Rating4()
    *  Summary         : Calculate Max Credit Limit Weekly Plus 7 for Rating 4
    *  CreatedDate     : 13/03/2019
    *  ModifiedDate    : 25/03/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void setMaxCreditLimitWeeklyPlus7Rating4() {
        if (this.company.dateoffoundation != null && this.company.dateoffoundation.length() == 10 && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(6, 10)), 
                Integer.valueOf(this.company.dateoffoundation.substring(3, 5)), Integer.valueOf(this.company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) < 18) {
            this.maxCreditLimitWeeklyPlus7 = 0;
        } else {
            Decimal recommendedCreditLimit = 0;
            if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
                recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
            }
            if (recommendedCreditLimit * 1.33 > this.creditLimitWeeklyPlus7 * 2) {
                if (this.creditLimitWeeklyPlus7 * 2 < 2500000) {
                    this.maxCreditLimitWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 2;
                } else {
                    this.maxCreditLimitWeeklyPlus7 = 2500000;
                }
            } else {
                if (recommendedCreditLimit * 1.33 < 2500000) {
                    this.maxCreditLimitWeeklyPlus7 = recommendedCreditLimit * 1.33;
                } else {
                    this.maxCreditLimitWeeklyPlus7 = 2500000;
                }
            }
        }
    }


    /*******************************************************************************
    *  Name            : setMaxCreditLimitWeeklyPlus7Rating6()
    *  Summary         : Calculate Max Credit Limit Weekly Plus 7 for Rating 6
    *  CreatedDate     : 08/11/2018
    *  ModifiedDate    : 25/03/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void setMaxCreditLimitWeeklyPlus7Rating6() {
        if (this.company.dateoffoundation != null && this.company.dateoffoundation.length() == 10 && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(6, 10)), 
                Integer.valueOf(this.company.dateoffoundation.substring(3, 5)), Integer.valueOf(this.company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) < 18) {
            this.maxCreditLimitWeeklyPlus7 = 0;
        } else {
            Decimal recommendedCreditLimit = 0;
            if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
                recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
            }
            if (recommendedCreditLimit > this.creditLimitWeeklyPlus7 * 2) {
                if (this.creditLimitWeeklyPlus7 * 2 < 2500000) {
                    this.maxCreditLimitWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 2;
                } else {
                    this.maxCreditLimitWeeklyPlus7 = 2500000;
                }
            } else if (recommendedCreditLimit > this.creditLimitWeeklyPlus7) {
                if (recommendedCreditLimit < 2500000) {
                    this.maxCreditLimitWeeklyPlus7 = recommendedCreditLimit;
                } else {
                    this.maxCreditLimitWeeklyPlus7 = 2500000;
                }
            } else {
                this.maxCreditLimitWeeklyPlus7 = this.creditLimitWeeklyPlus7;
            }
        }
    }


    /*******************************************************************************
    *  Name            : getMaxValueWeeklyPlus7()
    *  Summary         : Return Max value of Credit Limit including deposit Weekly Plus 7    
    *  CreatedDate     : 08/11/2018
    *  ModifiedDate    : 26/02/2019
    *  Parameters      : -
    *  Returns         : Decimal
    ******************************************************************************/
    public Decimal getMaxValueWeeklyPlus7() {
        if (this.maxValueWeeklyPlus7 < 10000) {
            return 10000;
        }

        return (this.maxValueWeeklyPlus7 / 10000).round(System.RoundingMode.HALF_UP) * 10000;
    }


    /*******************************************************************************
    *  Name            : setMaxValueWeeklyPlus7()
    *  Summary         : Calculate Max Value Weekly Plus 7    
    *  CreatedDate     : 08/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void setMaxValueWeeklyPlus7() {
        try {
            if (this.company.classRating == '1') {
                setMaxValueWeeklyPlus7Rating1();
            } else if (this.company.classRating == '4') {
                setMaxValueWeeklyPlus7Rating4();
            } else if (this.company.classRating == '6') {
                setMaxValueWeeklyPlus7Rating6();
            }
        } catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Max Value Weekly + 7 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : setMaxValueWeeklyPlus7Rating1()
    *  Summary         : Calculate Max Value Weekly Plus 7 for Rating 1
    *  CreatedDate     : 08/11/2018
    *  ModifiedDate    : 28/03/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void setMaxValueWeeklyPlus7Rating1() {
        if (this.creditLimitWeeklyPlus7 * 2 < 2500000) {
            this.maxValueWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 2;
        } else {
            this.maxValueWeeklyPlus7 = 2500000;
        }
    }


    /*******************************************************************************
    *  Name            : setMaxValueWeeklyPlus7Rating4()
    *  Summary         : Calculate Max Value Weekly Plus 7 for Rating 4
    *  CreatedDate     : 08/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void setMaxValueWeeklyPlus7Rating4() {
        if (this.creditLimitWeeklyPlus7 * 2 < 2500000) {
            this.maxValueWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 2;
        } else {
            this.maxValueWeeklyPlus7 = 2500000;
        }
    }


    /*******************************************************************************
    *  Name            : setMaxValueWeeklyPlus7Rating6()
    *  Summary         : Calculate Max Value Weekly Plus 7 for Rating 6
    *  CreatedDate     : 08/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void setMaxValueWeeklyPlus7Rating6() {
        Decimal recommendedCreditLimit = 0;
        if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
            recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
        }
        if (recommendedCreditLimit > this.creditLimitWeeklyPlus7 * 2) {
            if (this.creditLimitWeeklyPlus7 * 2 < 2500000) {
                this.maxValueWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 2;
            } else {
                this.maxValueWeeklyPlus7 = 2500000;
            }
        } else if (recommendedCreditLimit > this.creditLimitWeeklyPlus7) {
            if (recommendedCreditLimit < 2500000) {
                this.maxValueWeeklyPlus7 = recommendedCreditLimit;
            } else {
                this.maxValueWeeklyPlus7 = 2500000;
            }
        } else {
            this.maxValueWeeklyPlus7 = this.creditLimitWeeklyPlus7;
        }
    }


    /*******************************************************************************
    *  Name            : getDepositWeeklyPlus7()
    *  Summary         : Return Deposit Weekly Plus 7
    *  CreatedDate     : 08/11/2018
    *  ModifiedDate    : 26/02/2019
    *  Parameters      : -
    *  Returns         : Decimal
    ******************************************************************************/
    public Decimal getDepositWeeklyPlus7() {
        if (this.depositWeeklyPlus7 > 0 && this.depositWeeklyPlus7 < 10000) {
            return 10000;
        }

        return (this.depositWeeklyPlus7 / 10000).round(System.RoundingMode.HALF_UP) * 10000;
    }


    /*******************************************************************************
    *  Name            : setDepositWeeklyPlus7()
    *  Summary         : Calculate Deposit Weekly Plus 7    
    *  CreatedDate     : 08/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void setDepositWeeklyPlus7() {
        try {
            if (this.company.classRating == '1') {
                setDepositWeeklyPlus7Rating1();
            } else if (this.company.classRating == '4') {
                setDepositWeeklyPlus7Rating4();
            } else if (this.company.classRating == '6') {
                setDepositWeeklyPlus7Rating6();
            }
        } catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Deposit Weekly + 7 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : setDepositWeeklyPlus7Rating1()
    *  Summary         : Calculate Deposit Weekly Plus 7 for Rating 1    
    *  CreatedDate     : 08/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void setDepositWeeklyPlus7Rating1() {
        this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7 * (7.0 + 7.0 + 10.0) / (7.0 + 7.0);
    }


    /*******************************************************************************
    *  Name            : setDepositWeeklyPlus7Rating4()
    *  Summary         : Calculate Deposit Weekly Plus 7 for Rating 4
    *  CreatedDate     : 08/11/2018
    *  ModifiedDate    : 25/03/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void setDepositWeeklyPlus7Rating4() {
        if (this.company.dateoffoundation != null && this.company.dateoffoundation.length() == 10 && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(6, 10)), 
                Integer.valueOf(this.company.dateoffoundation.substring(3, 5)), Integer.valueOf(this.company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) < 18) {
            this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7;
        } else {
            Decimal recommendedCreditLimit = 0;
            if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
                recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
            }
            if (this.creditLimitWeeklyPlus7 <= this.maxCreditLimitWeeklyPlus7 && this.maxCreditLimitWeeklyPlus7 > 0) {
                this.depositWeeklyPlus7 = 0;
            } else {
                this.depositWeeklyPlus7 = (this.creditLimitWeeklyPlus7 - recommendedCreditLimit);
            }
        }
    }


    /*******************************************************************************
    *  Name            : setDepositWeeklyPlus7Rating6()
    *  Summary         : Calculate Deposit Weekly Plus 7 for Rating 6
    *  CreatedDate     : 08/11/2018
    *  ModifiedDate    : 25/03/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void setDepositWeeklyPlus7Rating6() {
        if (this.company.dateoffoundation != null && this.company.dateoffoundation.length() == 10 && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(6, 10)), 
                Integer.valueOf(this.company.dateoffoundation.substring(3, 5)), Integer.valueOf(this.company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) < 18) {
            this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7;
        } else {
            this.depositWeeklyPlus7 = 0;
        }
    }


    public Decimal getCreditLimitBiWeeklyPlus7() {
        return null;
    }


    public void setCreditLimitBiWeeklyPlus7(Decimal buffer) {}


    public Decimal getMaxCreditLimitBiWeeklyPlus7() {
        return null;
    }


    public void setMaxCreditLimitBiWeeklyPlus7() {}


    public Decimal getMaxValueBiWeeklyPlus7() {
        return null;
    }

    public void setMaxValueBiWeeklyPlus7() {}


    public Decimal getDepositBiWeeklyPlus7() {
        return null;
    }


    public void setDepositBiWeeklyPlus7() {}


    /*******************************************************************************
    *  Name            : getCreditLimitBiWeeklyPlus14()
    *  Summary         : Calculate Credit Limit BiWeekly Plus 14    
    *  CreatedDate     : 26/02/2018
    *  ModifiedDate    : 26/02/2019
    *  Parameters      : -
    *  Returns         : Decimal
    ******************************************************************************/
    public Decimal getCreditLimitBiWeeklyPlus14() {
        if (this.creditLimitBiWeeklyPlus14 < 10000) {
            return 10000;
        }

        return (this.creditLimitBiWeeklyPlus14 / 10000).round(System.RoundingMode.HALF_UP) * 10000;
    }


    /*******************************************************************************
    *  Name            : setCreditLimitBiWeeklyPlus14(Decimal buffer)
    *  Summary         : Calculate Credit Limit BiWeekly Plus 14
    *  CreatedDate     : 26/02/2018
    *  ModifiedDate    : 08/11/2018
    *  Parameters      : buffer - 0, 0.1, 0.2 or 0.3
    *  Returns         : void
    ******************************************************************************/
    public void setCreditLimitBiWeeklyPlus14(Decimal buffer) {
        try {
            this.creditLimitBiWeeklyPlus14 = ((Decimal)this.sourceObject.get(this.opportunityMapping.Monthly_Volume_Currency__c) * 
                ((15.0 + 14.0)/30.0)*(1.0 + buffer));
        } catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Credit Limit BiWeekly + 14 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : getMaxCreditLimitBiWeeklyPlus14()
    *  Summary         : Return Max Credit Limit BiWeekly Plus 14
    *  CreatedDate     : 16/03/2018
    *  ModifiedDate    : 26/02/2019
    *  Parameters      : -
    *  Returns         : Decimal
    ******************************************************************************/
    public Decimal getMaxCreditLimitBiWeeklyPlus14() {
        if (this.maxCreditLimitBiWeeklyPlus14 < 10000) {
            return 10000;
        }
        return (this.maxCreditLimitBiWeeklyPlus14 / 10000).round(System.RoundingMode.HALF_UP) * 10000;
    }


    /*******************************************************************************
    *  Name            : setMaxCreditLimitBiWeeklyPlus14()
    *  Summary         : Calculate Max Credit Limit BiWeekly Plus 14
    *  CreatedDate     : 16/03/2018
    *  ModifiedDate    : 08/11/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void setMaxCreditLimitBiWeeklyPlus14() {
        try {
            if (this.company.classRating == '1') {
                setMaxCreditLimitBiWeeklyPlus14Rating1();
            } else if (this.company.classRating == '4') {
                setMaxCreditLimitBiWeeklyPlus14Rating4();
            } else if (this.company.classRating == '6') {
                setMaxCreditLimitBiWeeklyPlus14Rating6();
            }
        } catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Max Credit Limit BiWeekly + 14 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : setMaxCreditLimitBiWeeklyPlus14Rating1()
    *  Summary         : Calculate Max Credit Limit BiWeekly Plus 14 for Rating 1  
    *  CreatedDate     : 06/04/2018
    *  ModifiedDate    : 08/11/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void setMaxCreditLimitBiWeeklyPlus14Rating1() {
        this.maxCreditLimitBiWeeklyPlus14 = 0;
    }


    /*******************************************************************************
    *  Name            : setMaxCreditLimitBiWeeklyPlus14Rating4()
    *  Summary         : Calculate Max Credit Limit BiWeekly Plus 14 for Rating 4
    *  CreatedDate     : 06/04/2018
    *  ModifiedDate    : 25/03/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void setMaxCreditLimitBiWeeklyPlus14Rating4() {
        if (this.company.dateoffoundation != null && this.company.dateoffoundation.length() == 10 && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(6, 10)), 
                Integer.valueOf(this.company.dateoffoundation.substring(3, 5)), Integer.valueOf(this.company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) < 18) {
            this.maxCreditLimitBiWeeklyPlus14 = 0;
        } else {
            Decimal recommendedCreditLimit = 0;
            if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
                recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
            }
            if (recommendedCreditLimit * 1.33 > this.creditLimitBiWeeklyPlus14 * 2) {
                if (this.creditLimitBiWeeklyPlus14 * 2 < 2500000) {
                    this.maxCreditLimitBiWeeklyPlus14 = this.creditLimitBiWeeklyPlus14 * 2;
                } else {
                    this.maxCreditLimitBiWeeklyPlus14 = 2500000;
                }
            } else {
                if (recommendedCreditLimit * 1.33 < 2500000) {
                    this.maxCreditLimitBiWeeklyPlus14 = recommendedCreditLimit * 1.33;
                } else {
                    this.maxCreditLimitBiWeeklyPlus14 = 2500000;
                }
            }
        }
    }


    /*******************************************************************************
    *  Name            : setMaxCreditLimitBiWeeklyPlus14Rating6()
    *  Summary         : Calculate Max Credit Limit BiWeekly Plus 14 for Rating 6
    *  CreatedDate     : 06/04/2018
    *  ModifiedDate    : 25/03/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void setMaxCreditLimitBiWeeklyPlus14Rating6() {
        if (this.company.dateoffoundation != null && this.company.dateoffoundation.length() == 10 && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(6, 10)), 
                Integer.valueOf(this.company.dateoffoundation.substring(3, 5)), Integer.valueOf(this.company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) < 18) {
            this.maxCreditLimitBiWeeklyPlus14 = 0;
        } else {
            Decimal recommendedCreditLimit = 0;
            if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
                recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
            }
            if (recommendedCreditLimit > this.creditLimitBiWeeklyPlus14 * 2) {
                if (this.creditLimitBiWeeklyPlus14 * 2 < 2500000) {
                    this.maxCreditLimitBiWeeklyPlus14 = this.creditLimitBiWeeklyPlus14 * 2;
                } else {
                    this.maxCreditLimitBiWeeklyPlus14 = 2500000;
                }
            } else if (recommendedCreditLimit > this.creditLimitBiWeeklyPlus14) {
                if (recommendedCreditLimit < 2500000) {
                    this.maxCreditLimitBiWeeklyPlus14 = recommendedCreditLimit;
                } else {
                    this.maxCreditLimitBiWeeklyPlus14 = 2500000;
                }
            } else {
                this.maxCreditLimitBiWeeklyPlus14 = this.creditLimitBiWeeklyPlus14;
            }
        }
    }


    /*******************************************************************************
    *  Name            : getDepositBiWeeklyPlus14()
    *  Summary         : Return Deposit BiWeekly Plus 14
    *  CreatedDate     : 06/03/2018
    *  ModifiedDate    : 26/02/2019
    *  Parameters      : -
    *  Returns         : Decimal
    ******************************************************************************/
    public Decimal getDepositBiWeeklyPlus14() {
        if (this.depositBiWeeklyPlus14 > 0 && this.depositBiWeeklyPlus14 < 10000) {
            return 10000;
        }

        return (this.depositBiWeeklyPlus14 / 10000).round(System.RoundingMode.HALF_UP) * 10000;
    }


    /*******************************************************************************
    *  Name            : setDepositBiWeeklyPlus14()
    *  Summary         : Calculate Deposit BiWeekly Plus 14
    *  CreatedDate     : 06/03/2018
    *  ModifiedDate    : 08/11/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void setDepositBiWeeklyPlus14() {
        try {
            if (this.company.classRating == '1') {
                setDepositBiWeeklyPlus14Rating1();
            } else if (this.company.classRating == '4') {
                setDepositBiWeeklyPlus14Rating4();
            } else if (this.company.classRating == '6') {
                setDepositBiWeeklyPlus14Rating6();
            }
        } catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Deposit BiWeekly + 14 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : setDepositBiWeeklyPlus14Rating1()
    *  Summary         : Calculate Deposit BiWeekly Plus 14 for Rating 1    
    *  CreatedDate     : 08/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void setDepositBiWeeklyPlus14Rating1() {
        this.depositBiWeeklyPlus14 = this.creditLimitBiWeeklyPlus14 * (15.0 + 14.0 + 10.0) / (15.0 + 14.0);
    }


    /*******************************************************************************
    *  Name            : setDepositBiWeeklyPlus14Rating4()
    *  Summary         : Calculate Deposit BiWeekly Plus 14 for Rating 4
    *  CreatedDate     : 08/11/2018
    *  ModifiedDate    : 25/03/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void setDepositBiWeeklyPlus14Rating4() {
        if (this.company.dateoffoundation != null && this.company.dateoffoundation.length() == 10 && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(6, 10)), 
                Integer.valueOf(this.company.dateoffoundation.substring(3, 5)), Integer.valueOf(this.company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) < 18) {
            this.depositBiWeeklyPlus14 = this.creditLimitBiWeeklyPlus14;
        } else {
            Decimal recommendedCreditLimit = 0;
            if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
                recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
            }
            if (this.creditLimitBiWeeklyPlus14 <= this.maxCreditLimitBiWeeklyPlus14 && this.maxCreditLimitBiWeeklyPlus14 > 0) {
                this.depositBiWeeklyPlus14 = 0;
            } else {
                this.depositBiWeeklyPlus14 = (this.creditLimitBiWeeklyPlus14 - recommendedCreditLimit);
            }
        }
    }


    /*******************************************************************************
    *  Name            : setDepositBiWeeklyPlus14Rating6()
    *  Summary         : Calculate Deposit BiWeekly Plus 14 for Rating 6
    *  CreatedDate     : 08/11/2018
    *  ModifiedDate    : 25/03/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void setDepositBiWeeklyPlus14Rating6() {
        if (this.company.dateoffoundation != null && this.company.dateoffoundation.length() == 10 && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(6, 10)), 
                Integer.valueOf(this.company.dateoffoundation.substring(3, 5)), Integer.valueOf(this.company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) < 18) {
            this.depositBiWeeklyPlus14 = this.creditLimitBiWeeklyPlus14;
        } else {
            this.depositBiWeeklyPlus14 = 0;
        }
    }


    /*******************************************************************************
    *  Name            : getMaxValueBiWeeklyPlus14()
    *  Summary         : Return Max value of Credit Limit including deposit Bi Weekly Plus 14    
    *  CreatedDate     : 08/11/2018
    *  ModifiedDate    : 26/02/2019
    *  Parameters      : -
    *  Returns         : Decimal
    ******************************************************************************/
    public Decimal getMaxValueBiWeeklyPlus14() {
        if (this.maxValueBiWeeklyPlus14 < 10000) {
            return 10000;
        }

        return (this.maxValueBiWeeklyPlus14 / 10000).round(System.RoundingMode.HALF_UP) * 10000;
    }


    /*******************************************************************************
    *  Name            : setMaxValueBiWeeklyPlus14()
    *  Summary         : Calculate Max Value BiWeekly Plus 14
    *  CreatedDate     : 08/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void setMaxValueBiWeeklyPlus14() {
        try {
            if (this.company.classRating == '1') {
                setMaxValueBiWeeklyPlus14Rating1();
            } else if (this.company.classRating == '4') {
                setMaxValueBiWeeklyPlus14Rating4();
            } else if (this.company.classRating == '6') {
                setMaxValueBiWeeklyPlus14Rating6();
            }
        } catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Max Value BiWeekly + 14 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : setMaxValueBiWeeklyPlus14Rating1()
    *  Summary         : Calculate Max Value BiWeekly Plus 14 for Rating 1  
    *  CreatedDate     : 08/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void setMaxValueBiWeeklyPlus14Rating1() {
        if (this.creditLimitBiWeeklyPlus14 * 2 < 2500000) {
            this.maxValueBiWeeklyPlus14 = this.creditLimitBiWeeklyPlus14 * 2;
        } else {
            this.maxValueBiWeeklyPlus14 = 2500000;
        }
    }


    /*******************************************************************************
    *  Name            : setMaxValueBiWeeklyPlus14Rating4()
    *  Summary         : Calculate Max Value BiWeekly Plus 14 for Rating 4
    *  CreatedDate     : 08/11/2018
    *  ModifiedDate    : 28/03/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void setMaxValueBiWeeklyPlus14Rating4() {
        if (this.creditLimitBiWeeklyPlus14 * 2 < 2500000) {
            this.maxValueBiWeeklyPlus14 = this.creditLimitBiWeeklyPlus14 * 2;
        } else {
            this.maxValueBiWeeklyPlus14 = 2500000;
        }
    }


    /*******************************************************************************
    *  Name            : setMaxValueBiWeeklyPlus14Rating6()
    *  Summary         : Calculate Max Value BiWeekly Plus 14 for Rating 6
    *  CreatedDate     : 08/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void setMaxValueBiWeeklyPlus14Rating6() {
        Decimal recommendedCreditLimit = 0;
        if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
            recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
        }
        if (recommendedCreditLimit > this.creditLimitBiWeeklyPlus14 * 2) {
            if (this.creditLimitBiWeeklyPlus14 * 2 < 2500000) {
                this.maxValueBiWeeklyPlus14 = this.creditLimitBiWeeklyPlus14 * 2;
            } else {
                this.maxValueBiWeeklyPlus14 = 2500000;
            }
        } else if (recommendedCreditLimit > this.creditLimitBiWeeklyPlus14) {
            if (recommendedCreditLimit < 2500000) {
                this.maxValueBiWeeklyPlus14 = recommendedCreditLimit;
            } else {
                this.maxValueBiWeeklyPlus14 = 2500000;
            }
        } else {
            this.maxValueBiWeeklyPlus14 = this.creditLimitBiWeeklyPlus14;
        }
    }

    public Decimal getCreditLimitMonthlyPlus7() {
        return null;
    }


    public void setCreditLimitMonthlyPlus7(Decimal buffer) {}


    public Decimal getMaxCreditLimitMonthlyPlus7() {
        return null;
    }


    public void setMaxCreditLimitMonthlyPlus7() {}


    public Decimal getMaxValueMonthlyPlus7() {
        return null;
    }


    public void setMaxValueMonthlyPlus7() {}


    public Decimal getDepositMonthlyPlus7() {
        return null;
    }


    public void setDepositMonthlyPlus7() {}


    public Decimal getCreditLimitMonthlyPlus14() {
        return null;
    }


    public void setCreditLimitMonthlyPlus14(Decimal buffer) {}
    

    public Decimal getMaxCreditLimitMonthlyPlus14() {
        return null;
    }


    public void setMaxCreditLimitMonthlyPlus14() {}
    

    public Decimal getDepositMonthlyPlus14() {
        return null;
    }


    public void setDepositMonthlyPlus14() {}


    public Decimal getCreditLimitMonthlyPlus21() {
        return null;
    }


    public void setCreditLimitMonthlyPlus21(Decimal buffer) {}


    public Decimal getMaxCreditLimitMonthlyPlus21() {
        return null;
    }


    public void setMaxCreditLimitMonthlyPlus21() {}


    public Decimal getDepositMonthlyPlus21() {
        return null;
    }


    public void setDepositMonthlyPlus21() {}


    public Decimal getCreditLimitMonthlyPlus27() {
        return null;
    }


    public void setCreditLimitMonthlyPlus27(Decimal buffer) {}


    public Decimal getMaxCreditLimitMonthlyPlus27() {
        return null;
    }


    public void setMaxCreditLimitMonthlyPlus27() {}


    public Decimal getMaxValueMonthlyPlus27() {
        return null;
    }


    public void setMaxValueMonthlyPlus27() {}


    public Decimal getDepositMonthlyPlus27() {
        return null;
    }


    public void setDepositMonthlyPlus27() {}


    /*******************************************************************************
    *  Name            : setPaymentDetails()
    *  Summary         : Calculate payment details such as billing period, payment terms and max credit limit  
    *  CreatedDate     : 16/03/2018
    *  ModifiedDate    : 12/11/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void setPaymentDetails() {
        if (this.company.classRating == '1') {
            setPaymentDetailsRating1();
        } else if (this.company.classRating == '4') {
            setPaymentDetailsRating4();
        } else if (this.company.classRating == '6') {
            setPaymentDetailsRating6();
        }
    }


    /*******************************************************************************
    *  Name            : setPaymentDetailsRating1()
    *  Summary         : Calculate payment details (billing period, payment terms) for rating 1 (RED)
    *  CreatedDate     : 27/02/2018
    *  ModifiedDate    : 13/03/2019
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    private void setPaymentDetailsRating1() {
        try {
            if (this.creditLimitBiWeeklyPlus14 < 2500000 && (this.userSource != 'E2E Long Form' && this.company.turnOverLastYear != null && 
                        Decimal.valueOf(this.company.turnOverLastYear) * 0.1 >= this.creditLimitBiWeeklyPlus14 || 
                    this.userSource == 'E2E Long Form')) {
                if (this.sourceObject.Zahlungsziel_2__c == '7' && this.sourceObject.Rechnungsperiode_2__c == '7') {
                    this.billingPeriod = 7;
                    this.paymentTerms = 7;
                } else {
                    this.billingPeriod = 15;
                    this.paymentTerms = 14;
                }
            } else if (this.creditLimitWeeklyPlus7 < 2500000) {
                this.billingPeriod = 7;
                this.paymentTerms = 7;
            }
        } catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Billing Period for Rating 1 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : setPaymentDetailsRating4()
    *  Summary         : Calculate billing period for Rating 4 : YELLOW
    *  CreatedDate     : 27/02/2018
    *  ModifiedDate    : 13/03/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void setPaymentDetailsRating4() {
        try {
            Decimal recommendedCL; 
            if (this.company.creditLimit != null) {
                recommendedCL = (Decimal.valueOf(this.company.creditLimit)).setScale(2);
            } else {
                recommendedCL = 0;
            }
            
            if (this.creditLimitBiWeeklyPlus14 < 2500000 && this.depositBiWeeklyPlus14 == 0 && (this.userSource != 'E2E Long Form' && this.company.turnOverLastYear != null &&
                    this.creditLimitBiWeeklyPlus14 <= Decimal.valueOf(this.company.turnOverLastYear) * 0.1 || this.userSource == 'E2E Long Form')) {
                if (this.sourceObject.Zahlungsziel_2__c == '7' && this.sourceObject.Rechnungsperiode_2__c == '7') {
                    this.billingPeriod = 7;
                    this.paymentTerms = 7;
                } else {
                    this.billingPeriod = 15;                                            
                    this.paymentTerms = 14;
                }
            } else if (this.creditLimitWeeklyPlus7 < 2500000 && recommendedCL != 0 && this.creditLimitWeeklyPlus7/recommendedCL < 1.33 && this.depositWeeklyPlus7 == 0) {
                this.billingPeriod = 7;   
                this.paymentTerms = 7;
            } else if (this.creditLimitBiWeeklyPlus14 < 2500000 && (this.userSource != 'E2E Long Form' && this.company.turnOverLastYear != null &&
                    this.creditLimitBiWeeklyPlus14 <= Decimal.valueOf(this.company.turnOverLastYear) * 0.1 || this.userSource == 'E2E Long Form')) {
                if (this.sourceObject.Zahlungsziel_2__c == '7' && this.sourceObject.Rechnungsperiode_2__c == '7') {
                    this.billingPeriod = 7;
                    this.paymentTerms = 7;
                } else {
                    this.billingPeriod = 15;                                            
                    this.paymentTerms = 14;
                }
            } else if (this.creditLimitWeeklyPlus7 < 2500000 && recommendedCL != 0 && this.creditLimitWeeklyPlus7/recommendedCL < 1.33) {
                this.billingPeriod = 7;   
                this.paymentTerms = 7;
            }
        } catch (Exception e) {
            System.debug('DEBUG: Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Billing Period for Rating 4 (YELLOW) calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : setPaymentDetailsRating6()
    *  Summary         : Calculate billing period for Rating 6 : GREEN
    *  CreatedDate     : 27/02/2018
    *  ModifiedDate    : 25/03/2019
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    private void setPaymentDetailsRating6() {
        try {
            if (this.creditLimitBiWeeklyPlus14 < 2500000 && this.depositBiWeeklyPlus14 == 0 && (this.userSource != 'E2E Long Form' && this.company.turnOverLastYear != null &&
                    this.creditLimitBiWeeklyPlus14 <= Decimal.valueOf(this.company.turnOverLastYear) * 0.1 || this.userSource == 'E2E Long Form')) {
                if (this.sourceObject.Zahlungsziel_2__c == '7' && this.sourceObject.Rechnungsperiode_2__c == '7') {
                    this.billingPeriod = 7;
                    this.paymentTerms = 7;
                } else {
                    this.billingPeriod = 15;
                    this.paymentTerms = 14;
                }
            } else if (this.creditLimitWeeklyPlus7 < 2500000 && this.depositWeeklyPlus7 == 0) {
                this.billingPeriod = 7;
                this.paymentTerms = 7;
            } else if (this.creditLimitBiWeeklyPlus14 < 2500000 && (this.userSource != 'E2E Long Form' && this.company.turnOverLastYear != null && 
                    this.creditLimitBiWeeklyPlus14 <= Decimal.valueOf(this.company.turnOverLastYear) * 0.1 || this.userSource == 'E2E Long Form')) {
                if (this.sourceObject.Zahlungsziel_2__c == '7' && this.sourceObject.Rechnungsperiode_2__c == '7') {
                    this.billingPeriod = 7;
                    this.paymentTerms = 7;
                } else {
                    this.billingPeriod = 15;
                    this.paymentTerms = 14;
                }
            } else if (this.creditLimitWeeklyPlus7 < 2500000) {
                this.billingPeriod = 7;
                this.paymentTerms = 7;
            }
        } catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Billing Period for Rating 6 (GREEN) calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        } 
    }


    /*******************************************************************************
    *  Name            : getBillingPeriod
    *  Summary         : Return billing period
    *  CreatedDate     : 2/11/2016
    *  Parameters      : 
    *  Returns         : Integer
    ******************************************************************************/
    public Integer getBillingPeriod() {
        return this.billingPeriod;
    }


    /*******************************************************************************
    *  Name            : getPaymentTerms()
    *  Summary         : Return payment terms.  
    *  CreatedDate     : 22/03/2018
    *  ModifiedDate    : 22/03/2018
    *  Parameters      : -
    *  Returns         : Integer
    ******************************************************************************/
    public Integer getPaymentTerms() {
        return this.paymentTerms;
    }


    /*******************************************************************************
    *  Name            : setCreditLimit()
    *  Summary         : Calculate Credit Limit    
    *  CreatedDate     : 15/10/2018
    *  ModifiedDate    : 08/11/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void setCreditLimit() {
        try {
            if (this.billingPeriod == 15 && this.paymentTerms == 14) {
                this.creditLimit = getCreditLimitBiWeeklyPlus14();
            } else if (this.billingPeriod == 7 && this.paymentterms == 7) {
                this.creditLimit = getCreditLimitWeeklyPlus7();
            }
        } catch (Exception e) {
            System.debug('DEBUG: Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Credit Limit calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : getCreditLimit()
    *  Summary         : Return Credit Limit    
    *  CreatedDate     : 08/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Decimal
    ******************************************************************************/
    public Decimal getCreditLimit() {
        return this.creditLimit;
    }


    /*******************************************************************************
    *  Name            : setMaxCreditLimit()
    *  Summary         : Calculate max credit limit    
    *  CreatedDate     : 27/02/2018
    *  ModifiedDate    : 26/02/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void setMaxCreditLimit() {
        try {
            if (this.billingPeriod == 15 && this.paymentTerms == 14) {
                this.maxCreditLimit = getMaxCreditLimitBiWeeklyPlus14();
            } else if (this.billingPeriod == 7 && this.paymentTerms == 7) {
                this.maxCreditLimit = getMaxCreditLimitWeeklyPlus7();
            }
        } catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Max Credit Limit calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : getMaxCreditLimit()
    *  Summary         : Return max credit limit.
    *  CreatedDate     : 22/03/2018
    *  ModifiedDate    : 22/03/2018 
    *  Parameters      : -
    *  Returns         : Decimal
    ******************************************************************************/
    public Decimal getMaxCreditLimit() {
        return this.maxCreditLimit;
    }


    /*******************************************************************************
    *  Name            : setMaxValue()
    *  Summary         : Calculate Max value of Credit Limit including deposit    
    *  CreatedDate     : 08/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Decimal
    ******************************************************************************/
    public void setMaxValue() {
        try {
            if (this.billingPeriod == 15 && this.paymentTerms == 14) {
                this.maxValue = getMaxValueBiWeeklyPlus14();
            } else if (this.billingPeriod == 7 && this.paymentTerms == 7) {
                this.maxValue = getMaxValueWeeklyPlus7();
            }
        } catch (Exception e) {
             System.debug('DEBUG: Credit Factory === ' + e.getMessage());
             throw new CreditFactoryException('Max value calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : getMaxValue()
    *  Summary         : Return Max value of Credit Limit including deposit
    *  CreatedDate     : 08/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Decimal
    ******************************************************************************/
    public Decimal getMaxValue() {
        return this.maxValue;
    }


    /*******************************************************************************
    *  Name            : setDeposit()
    *  Summary         : Calculate deposit   
    *  CreatedDate     : 07/03/2018
    *  ModifiedDate    : 08/11/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void setDeposit() {
        try {
            if (this.billingPeriod == 15 && this.paymentTerms == 14) {
                this.deposit = getDepositBiWeeklyPlus14(); 
            } else if (this.billingPeriod == 7 && this.paymentTerms == 7) {
                this.deposit = getDepositWeeklyPlus7();
            }
        } catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Deposit calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : resetDeposit(CreditCompany company, Integer billingPeriod, Decimal creditLimit, 
                             Decimal maxCreditLimit, Decimal monthlyVolume, Decimal totalConsumption,
                             String opportunityId)
    *  Summary         : recalculate deposit value for changed CL value    
    *  CreatedDate     : 22/03/2018
    *  ModifiedDate    : 26/03/2019
    *  Parameters      : CreditCompany company - company from Credit System, 
                         Integer billingPeriod - selected billing period, 
                         Integer paymentTerms - selected payment terms,
                         Decimal creditLimit - changed CL value,
                         Decimal maxCreditLimit - max Credit Limit for selected billing period,
                         Decimal monthlyVolume - currency based on total consumption of liters,
                         Decimal totalConsumption - total consumption of liters,
                         String opportunityId - id of related opportunity.
    *  Returns         : void
    ******************************************************************************/
    public void resetDeposit(CreditCompany company, Integer billingPeriod, Integer paymentTerms, Decimal creditLimit, 
                             Decimal maxCreditLimit, Decimal monthlyVolume, Decimal totalConsumption,
                             String opportunityId) {
        try {
            List<Credit_Factory_Report__c> creditReportsList = [
                    SELECT Credit_Limit_Weekly_7__c, Credit_Limit_Bi_Weekly_14__c,
                        Deposit_Weekly_7__c, Deposit_Bi_Weekly_14__c
                    FROM Credit_Factory_Report__c
                    WHERE Opportunity__c = :opportunityId AND CreatedDate > :Date.today().addMonths(-3)
                    ORDER BY CreatedDate DESC
                    LIMIT 1];
            if (! creditReportsList.isEmpty() && billingPeriod == 15 && paymentTerms == 14 && 
                    creditLimit == creditReportsList.get(0).Credit_Limit_Bi_Weekly_14__c) {
                this.deposit = creditReportsList.get(0).Deposit_Bi_Weekly_14__c;
            } else if (! creditReportsList.isEmpty() && billingPeriod == 7 && paymentTerms == 7 && 
                    creditLimit == creditReportsList.get(0).Credit_Limit_Weekly_7__c) {
                this.deposit = creditReportsList.get(0).Deposit_Weekly_7__c;
            } else if (company.classRating == '1') {
                this.deposit = resetDepositRating1(creditLimit, billingPeriod, paymentTerms);
            } else if (company.classRating == '4') {
                this.deposit = resetDepositRating4(creditLimit, maxCreditLimit, company);
            } else if (company.classRating == '6') {
                this.deposit = resetDepositRating6(creditLimit, company);
            }
        } catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Deposit recalculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : resetDepositRating1(Decimal creditLimit, Integer billingPeriod, Integer paymentTerms)
    *  Summary         : Reset deposit value for rating 1 and changed CL value.     
    *  CreatedDate     : 10/11/2018
    *  ModifiedDate    : 26/02/2019
    *  Parameters      : Decimal creditLimit - changed CL value, Integer billingPeriod - selected Billing Period, 
                         Integer paymentTerms - selected Payment Terms
    *  Returns         : Decimal
    ******************************************************************************/
    private Decimal resetDepositRating1(Decimal creditLimit, Integer billingPeriod, Integer paymentTerms) {
        return ((creditLimit * (billingPeriod + paymentTerms + 10.0) / (billingPeriod + paymentTerms)) / 10000).round(System.RoundingMode.HALF_UP) * 10000;
    }


    /*******************************************************************************
    *  Name            : resetDepositRating4()
    *  Summary         : Reset deposit value for rating 4 and changed CL value.
    *  CreatedDate     : 18/11/2018
    *  ModifiedDate    : 28/03/2019
    *  Parameters      : Decimal creditLimit - changed CL value, Decimal maxCreditLimit - max Credit Limit for selected billing period, 
                         CreditCompany company - company from Credit System
    *  Returns         : Decimal
    ******************************************************************************/
    private Decimal resetDepositRating4(Decimal creditLimit, Decimal maxCreditLimit, CreditCompany company) {
        if (company.dateoffoundation != null && company.dateoffoundation.length() == 10 && Date.newInstance(Integer.valueOf(company.dateoffoundation.substring(6, 10)), 
                Integer.valueOf(company.dateoffoundation.substring(3, 5)), Integer.valueOf(company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) < 18) {
            return creditLimit;
        } else if (creditLimit <= maxCreditLimit) {
            return 0;
        } else {
            Decimal recommendedCreditLimit = 0;
            if (company.creditLimit != null && company.creditLimit.isNumeric()) {
                recommendedCreditLimit = Decimal.valueOf(company.creditLimit);
            }
            return ((creditLimit - recommendedCreditLimit) / 10000).round(System.RoundingMode.HALF_UP) * 10000;
        }
    }


    /*******************************************************************************
    *  Name            : resetDepositRating6()
    *  Summary         : Reset deposit value for rating 6 and changed CL value. 
    *  CreatedDate     : 18/11/2018
    *  ModifiedDate    : 26/03/2019
    *  Parameters      : ecimal creditLimit - changed CL value, CreditCompany company - company from Credit System
    *  Returns         : Decimal
    ******************************************************************************/
    private Decimal resetDepositRating6(Decimal creditLimit, CreditCompany company) {
        if (company.dateoffoundation != null && company.dateoffoundation.length() == 10 && Date.newInstance(Integer.valueOf(company.dateoffoundation.substring(6, 10)), 
                Integer.valueOf(company.dateoffoundation.substring(3, 5)), Integer.valueOf(company.dateoffoundation.substring(0, 2))).monthsBetween(Date.today()) < 18) {
            return creditLimit;
        } else {
            return 0;
        }
    }


    /*******************************************************************************
    *  Name            : getDeposit()
    *  Summary         : Return deposit.    
    *  CreatedDate     : 18/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Decimal
    ******************************************************************************/
    public Decimal getDeposit() {
        return this.deposit;
    }


    /*******************************************************************************
    *  Name            : setDecision()
    *  Summary         : Set company decision   
    *  CreatedDate     : 18/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void setDecision() {
        try {
            this.decision = new CreditFactoryDecision();
            if (this.billingPeriod != null && this.paymentTerms != null && this.deposit == 0) {
                // Positive Decisions without deposit
                this.decision.verdict = 'Yes';
                this.decision.statusCode = '001'; // No Limits
            } else if (this.billingPeriod != null && this.paymentTerms != null && this.deposit != 0) {
                // Positive Decisions with deposit
                this.decision.verdict = 'Yes';
                this.decision.statusCode = '002'; // No Limits
            } else {
                // Negative Decisions
                this.decision.verdict = 'No';
                this.decision.statusCode = '003';
            }

            if (this.userSource != 'E2E Long Form') {
                if (! errorsSet.contains(CONTACT_ERROR)) {
                    if (this.decision.statusCode == '001') {
                        CreditFactoryUtilities.displayMessage('info','Billing Period can be set to ' + this.billingPeriod);
                        CreditFactoryUtilities.displayMessage('info','Payment Terms can be set to ' + this.paymentTerms);
                    } else if (this.decision.statusCode == '002') {
                        changeToPendingDeposit();
                    } else if (this.decision.statusCode == '003') {
                        CreditFactoryUtilities.displayMessage('error','Requested limit too high. Please refer to credit.');
                    }
                } else {
                    if (this.securityLevel == null || this.deposit == 0) {
                        this.securityLevel = 100;
                    }
                }
            } 
        } catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Set Decision failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : resetDecision()
    *  Summary         : Reset Company Decision
    *  CreatedDate     : 10/11/2018
    *  ModifiedDate    : 22/12/2018
    *  Parameters      : Integer billingPeriod - selected billing period, Integer paymentTerms - selected payment terms, Decimal deposit - selected deposit, 
                         String classRating - current company class rating, Integer numberOfCards - number of cards, CreditCompany company - company from Credit System
    *  Returns         : void
    ******************************************************************************/
    public void resetDecision(Integer billingPeriod, Integer paymentTerms, Decimal deposit, String classRating, Decimal numberOfCards, CreditCompany company) {
        try {
            this.decision = new CreditFactoryDecision();
            // Positive Decisions
            this.decision.verdict = 'Yes';
            if (deposit == 0) {
                // Decisions without deposit
                this.decision.statusCode = '001'; // No Limits
            } else {
                // Decisions with deposit
                this.decision.statusCode = '002'; // No Limit
            }
        } catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Reset Decision failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : getDecision()
    *  Summary         : Return decision.    
    *  CreatedDate     : 10/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : CreditFactoryDecision
    ******************************************************************************/
    public CreditFactoryDecision getDecision() {
        return this.decision;
    }


    /*******************************************************************************
    *  Name            : checkWarnings()
    *  Summary         : check for warnings to display on page
    *  CreatedDate     : 22/02/2018
    *  ModifiedDate    : 03/04/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void checkWarnings() {
        if (this.deposit == 0 && errorsSet != null && ! errorsSet.contains(CONTACT_ERROR)) {
            Boolean isPaymentTermsValid = checkPaymentTerms();
            Boolean isBillingPeriodValid = checkBillingPeriod();
            if (isPaymentTermsValid == false || isBillingPeriodValid == false) {
               CreditFactoryUtilities.displayMessage('warning', 'If you want to close your Opportunity with desired billing period and desired payment terms, please refer to Credit.');
            }
        }    
    }


    /*******************************************************************************
    *  Name            : checkPaymentTerms()
    *  Summary         : compare calculated and desired payment terms
    *  CreatedDate     : 22/02/2018
    *  ModifiedDate    : 03/04/2018
    *  Parameters      : -
    *  Returns         : Boolean
    ******************************************************************************/
    private Boolean checkPaymentTerms() {
        if (this.sourceObject.Rechnungsperiode_2__c != null && this.paymentTerms != null && this.sourceObject.Rechnungsperiode_2__c != String.valueOf(this.paymentTerms)) {
            CreditFactoryUtilities.displayMessage('warning', 'Desired payment terms (' + this.sourceObject.Rechnungsperiode_2__c + 
                ') cannot be provided. Requested limit is too high for the automatic processing.');
            return false;
        }

        return true;
    }


    /*******************************************************************************
    *  Name            : checkBillingPeriod()
    *  Summary         : compare calculated and desired billing period    
    *  CreatedDate     : 22/02/2018
    *  ModifiedDate    : 03/04/2018
    *  Parameters      : -
    *  Returns         : Boolean
    ******************************************************************************/
    private Boolean checkBillingPeriod() {
        if (this.sourceObject.Zahlungsziel_2__c != null && this.billingPeriod != null && this.sourceObject.Zahlungsziel_2__c != String.valueOf(this.billingPeriod)) {
            CreditFactoryUtilities.displayMessage('warning', 'Desired billing period (' + this.sourceObject.Zahlungsziel_2__c + 
                ') cannot be provided. Requested limit is too high for the automatic processing.');
            return false;
        }

        return true;
    }


    /*******************************************************************************
    *  Name            : saveReports()
    *  Summary         : Save information from Credit system to Salesforce     
    *  CreatedDate     : 19/10/2017
    *  ModifiedDate    : 09/04/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void saveReports() {
        if (this.existingCreditReport == null && company != null) {
            String reportName = company.name;
            if (reportName.length() > 80) {
                reportName = reportName.substring(0,80);
            }
            Credit_Factory_Report__c newReport = new Credit_Factory_Report__c(
                Credit_System_Number__c = company.creditSystemCompanyNumber,
                Age_of_Company__c = company.ageofcompany,
                City__c = company.city,
                Company_Status__c = company.status,
                Country__c = company.country,
                County_Court__c = company.countyCourt,
                Credit_Decision__c = company.creditDecision,
                Credit_Limit__c = company.creditLimit,
                Date_Last_Register_Entry__c = company.datelastregisterentry,
                Date_Legal_Form__c = company.datelegalform,
                Date_of_Foundation__c = company.dateoffoundation,
                Email__c = company.email,
                Fax__c = company.fax,
                First_Legal_Form__c = company.firstlegalform,
                Fiscal_Number__c = company.taxnumber,
                Tax_Id__c = company.taxnumber,
                Housenumber__c = company.housenumber,
                Legal_Form__c = company.legalform,
                Mobile__c = company.mobile,
                Opportunity__c = sourceObject.Id,
                Order_Situation__c = company.orderSituation,
                Payment_Behaviour__c = company.paymentBehaviour,
                Phone__c = company.phone,
                Postcode__c = company.postcode,
                Register_Number__c = company.registerNumber,
                Staff_Range__c = company.staffcompanyrange,
                Street__c = company.street,
                Trade_Name__c = company.tradename,
                Turn_Over__c = company.turnOver,
                VAT_Number__c = company.vatid,
                Trade_Register_Number__c = company.tradeRegisterNumber,
                Website__c = company.website,
                Name = reportName,
                Company_Id__c = company.identificationnumber,
                Date_Of_Last_Major_Update__c = company.dateOfLastMajorUpdate,
                Reference_Number__c = company.referencenumber,
                CurrencyIsoCode = 'HUF',
                Name__c = company.name,
                Profit_Loss_Last_Year__c = company.profitLossLastYear,
                Profit_Loss_Year_Before_Last__c = company.profitLossYearBeforeLast,
                Turn_Over_Last_Year__c = company.turnOverLastYear);

            if (this.userSource == 'E2E Long Form') {
                newReport.Billing_Period__c = this.billingPeriod;
                newReport.Payment_Terms__c = this.paymentTerms;
                newReport.Security_Level__c = this.securityLevel;
                newReport.Credit_Limit_Default__c = getCreditLimit();
                newReport.Credit_Limit_Weekly_7__c = getCreditLimitWeeklyPlus7();
                newReport.Credit_Limit_Bi_Weekly_14__c = getCreditLimitBiWeeklyPlus14();
                newReport.Max_Credit_Limit_Weekly_7__c = getMaxCreditLimitWeeklyPlus7();
                newReport.Max_Credit_Limit_Bi_Weekly_14__c = getMaxCreditLimitBiWeeklyPlus14();
                newReport.Max_Value_Weekly_7__c = getMaxValueWeeklyPlus7();
                newReport.Max_Value_Bi_Weekly_14__c = getMaxValueBiWeeklyPlus14();
                newReport.Deposit_Weekly_7__c = getDepositWeeklyPlus7();
                newReport.Deposit_Bi_Weekly_14__c = getDepositBiWeeklyPlus14();
                newReport.Decision_Verdict__c = this.decision.verdict;
                newReport.Decision_Status_Code__c = this.decision.statusCode;
            }

            if (company.classRating != null) {
                newReport.Class_Rating__c = company.classRating;
            }

            try {
                insert newReport;
                List<Credit_Factory_Report_Employee__c> employeesListToInsert = new List<Credit_Factory_Report_Employee__c>();
                for (CreditCompanyEmployee e : companyEmployeesList) {
                    String employeeName = e.ename;
                    if (e.ename.length() > 80) {
                        employeeName = employeeName.substring(0,80);
                    }
                    employeesListToInsert.add(new Credit_Factory_Report_Employee__c(
                        Credit_Factory_Report__c = newReport.Id,
                        Address__c = e.address,
                        Date_of_Birth__c = e.dateofbirth,
                        Id__c = e.enumber,
                        Name = employeeName,
                        Participation_Date__c = e.participationdate,
                        Type__c = e.type,
                        Company_Id__c = e.companyId,
                        Company_Type__c = e.companyType,
                        Company_Role__c = e.companyRole));
                }
                insert employeesListToInsert;
            } catch (Exception e) {
                CreditFactoryUtilities.displayMessage('error','Error on saving Opportunity. Contact your administrator.');
                system.debug('Credit Factory === ' + e.getMessage());
                return;
            }
        } else {
            // update
            if (this.userSource == 'E2E Long Form') {
                Credit_Factory_Report__c existingReport = new Credit_Factory_Report__c(
                    Id = this.existingCreditReport.Id,
                    Billing_Period__c = this.billingPeriod,
                    Payment_Terms__c = this.paymentTerms,
                    Security_Level__c = this.securityLevel,
                    Credit_Limit_Default__c = getCreditLimit(),
                    Credit_Limit_Weekly_7__c = getCreditLimitWeeklyPlus7(),
                    Max_Credit_Limit_Weekly_7__c = getMaxCreditLimitWeeklyPlus7(),
                    Max_Value_Weekly_7__c = getMaxValueWeeklyPlus7(),
                    Deposit_Weekly_7__c = getDepositWeeklyPlus7(),
                    Credit_Limit_Bi_Weekly_14__c = getCreditLimitBiWeeklyPlus14(),
                    Max_Credit_Limit_Bi_Weekly_14__c = getMaxCreditLimitBiWeeklyPlus14(),
                    Max_Value_Bi_Weekly_14__c = getMaxValueBiWeeklyPlus14(),
                    Deposit_Bi_Weekly_14__c = getDepositBiWeeklyPlus14(),
                    Decision_Verdict__c = this.decision.verdict,
                    Decision_Status_Code__c = this.decision.statusCode);
                try {
                    update existingReport;
                } catch (Exception e) {
                     System.debug('Credit Factory === ' + e.getMessage());
                     CreditFactoryUtilities.displayMessage('error', 'Error on updating Credit Factory Report. Contact your administrator.');
                }
            }
        }
    }


    /*******************************************************************************
    *  Name            : updateOpportunityByCredit()
    *  Summary         : Save information from Credit system to Salesforce
    *  CreatedDate     : 2/11/2016
    *  ModifiedDate    : 19/10/2017
    *  Parameters      : 
    *  Returns         : PageReference - redirect to Opportunity record
    ******************************************************************************/
    public PageReference updateOpportunityByCredit() {
        this.sourceObject.put(
            this.opportunityMapping.Credit_System_Rating__c,
            CreditFactoryUtilities.returnArabic(this.company.classRating));
        if (this.company.creditLimit != null) {
            this.sourceObject.put(
                this.opportunityMapping.Credit_System_Limit__c,
                Decimal.valueOf(company.creditLimit));
        }
        if (this.company.turnOver != null) {
            this.sourceObject.put(this.opportunityMapping.Turn_Over__c,this.company.turnOver);
        }
        this.sourceObject.put(this.opportunityMapping.Number_of_employees__c,company.staffcompanyrange);
        this.sourceObject.put(this.opportunityMapping.Credit_check_date__c,Date.today());
        this.sourceObject.put(this.opportunityMapping.Credit_System_Number__c,this.company.creditSystemCompanyNumber);
        // if (this.company.datelegalform != null) {
        //     this.sourceObject.put(this.opportunityMapping.Year_of_foundation__,this.company.datelegalform.substring(0, 4));
        // }
        if (this.company.dateoffoundation != null) {
            if (this.company.dateoffoundation.length() == 10) {
                this.sourceObject.put(this.opportunityMapping.Year_of_foundation__c,this.company.dateoffoundation.substring(6, 10));
            } else if (this.company.dateoffoundation.length() == 4) {
                this.sourceObject.put(this.opportunityMapping.Year_of_foundation__c,this.company.dateoffoundation.substring(0, 4));
            }
        }

        try {
            update this.sourceObject;
        } catch (Exception e) {
            CreditFactoryUtilities.displayMessage('error','Error on saving Opportunity. Contact your administrator.');
            system.debug('Credit Factory === ' + e.getMessage());
            return null;
        }

        return new PageReference('/' + sourceObject.Id);
    }


    /*******************************************************************************
    *  Name            : changeBillingPeriodBySales()
    *  Summary         : Change Billing Period and update fields in Opportunity
    *  CreatedDate     : 2/11/2016
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    public PageReference changeBillingPeriodBySales() {
        try {
            this.sourceObject.put(this.opportunityMapping.Payment_Terms_Credit__c,String.valueOf(this.paymentTerms));
            this.sourceObject.put(this.opportunityMapping.Billing_Period__c,String.valueOf(this.billingPeriod));
            this.sourceObject.put(this.opportunityMapping.CF_Credit_Limit__c, this.creditLimit);
            this.sourceObject.put(this.opportunityMapping.Credit_check_date__c,Date.today());
            this.sourceObject.Billing_Period_by_Sales__c = true;
            this.sourceObject.put(this.opportunityMapping.Risk_Category__c,this.riskCategory);
            this.sourceObject.put(this.opportunityMapping.Buffer__c, this.buffer * 100);

            if (this.maxCreditLimit != null) {
                this.sourceObject.put(this.opportunityMapping.Max_Credit_Limit__c, this.maxCreditLimit);
            }

            update this.sourceObject;
            return new PageReference('/' + this.sourceObject.Id);
        } catch (Exception e) {
            CreditFactoryUtilities.displayMessage('error','Change Billing Period failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
            system.debug('Credit Factory === ' + e.getMessage());
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : updateOpportunityWithPDF()
    *  Summary         : Update Opportunity field "PDF created"
    *  CreatedDate     : 3/11/2016
    *  Parameters      : sourceObject - Opportunity object
    *  Returns         : void
    ******************************************************************************/
    public void updateOpportunityWithPDF(sObject sourceObject) {
        try {
            Opportunity opportunityToUpdate = (Opportunity)sourceObject;
            opportunityToUpdate.Credit_Factory_PDF_Report_Created__c = true;
            update opportunityToUpdate;
        } catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            String errorMessage = 'Opportunity update failed. ';
            throw new CreditFactoryException(errorMessage + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : doCreateReportAttachment(String opportunityId)
    *  Summary         : Create Credit Company Report PDF Attachment in Salesforce and attach to Opportunity
    *  CreatedDate     : 2/11/2016
    *  Parameters      : opportunityId - source record Salesforce id
    *  Returns         : Boolean - true if report attached to opportunity
    ******************************************************************************/
    public Boolean doCreateReportAttachment(String opportunityId) {
        if (this.attachmentBody != null) {
            try {
                Attachment creforeport = new Attachment(
                    ParentId = opportunityId,
                    Name = 'CofaceReport.pdf',
                    Body = this.attachmentBody);
                insert creforeport;
                return true;   
            } catch (Exception e) {
                System.debug('Credit Factory === ' + e.getMessage());
                String errorMessage = 'Error on creating PDF report. ';
                throw new CreditFactoryException(errorMessage + CreditFactoryUtilities.CONTACT_ADMIN);
            }
        }
        return false;
    }


    public Boolean isPendingSEPAPossible() {
        return false;
    }


    public Boolean isAutoCWPossible() {
        return false;
    }


    public PageReference changeToPendingSEPAConfirmation() {
        return null;
    }


    public PageReference changeToClosedWon() {
        return null;
    }


    /*******************************************************************************
    *  Name            : countNumberOfRelatedTankkartens()
    *  Summary         : count number of Tankkarten__c objects related to the current Opportunity    
    *  CreatedDate     : 24/11/2017
    *  ModifiedDate    : 24/11/2017
    *  Parameters      : -
    *  Returns         : Integer
    ******************************************************************************/
    private Integer countNumberOfRelatedTankkartens() {
        List<Tankkarten__c> relatedTankkartensList = [
                SELECT Id
                FROM Tankkarten__c
                WHERE Opportunity__c = :this.sourceObject.Id];
        return relatedTankkartensList.size();
    }


    /*******************************************************************************
    *  Name            : checkDuplicates()
    *  Summary         : if duplicates is existed then stop credit process    
    *  CreatedDate     : 27/02/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void checkDuplicates() {
        if (isSales()) {
            CreditFactoryUtilities.checkDuplicates(this.sourceObject);
        }
    }


    /*******************************************************************************
    *  Name            : changeToPendingDeposit()
    *  Summary         : change Opportunity Stage Name to Pending Sales - Deposit automatically
    *  CreatedDate     : 27/02/2018
    *  ModifiedDate    : 28/03/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void changeToPendingDeposit() {
        try {
            this.sourceObject.StageName = 'Pending Sales – Deposit';
            this.sourceObject.put(this.opportunityMapping.Credit_Decision__c, 'Sicherheit verlangt');
            this.sourceObject.put(this.opportunityMapping.Credit_check_date__c,Date.today());
            this.sourceObject.put(this.opportunityMapping.Processed_by__c, 'Autoprocessed by Sales');
            this.sourceObject.Billing_Period_by_Sales__c = true;
            this.sourceObject.Pending_Deposit_by_CF__c = true;
            this.sourceObject.CF_Stage__c = 'Pending deposit';
            this.sourceObject.put(this.opportunityMapping.Risk_Category__c,this.riskCategory);
            this.sourceObject.put(this.opportunityMapping.Buffer__c, this.buffer * 100);
            this.sourceObject.put(this.opportunityMapping.Security_Level__c, this.securityLevel);
            this.sourceObject.Account.Gesellschaftsform__c = this.company.legalform;
            update this.sourceObject;
            update this.sourceObject.Account;
            CreditFactoryUtilities.displayMessage('error','Decision about deposit was accepted for your client.');
        } catch (Exception e) {
            throw new CreditFactoryException('Change to Pending Sales - Deposit failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : changeToContractCheck()
    *  Summary         : change Opportunity StageName to Pending Credit - Contract Check    
    *  CreatedDate     : 01/03/2018
    *  ModifiedDate    : 
    *  Parameters      : -
    *  Returns         : PageReference
    ******************************************************************************/
    public PageReference changeToContractCheck() {
        checkDuplicates();
        Integer numberOfRelatedTankkartens = countNumberOfRelatedTankkartens();
        Integer numberOfCardsField = 0;        
        if (this.sourceObject.Anzahl_der_Karten__c != null) {
            numberOfCardsField = (Integer) this.sourceObject.Anzahl_der_Karten__c;
        }
        if (numberOfRelatedTankkartens != numberOfCardsField && this.sourceObject.Custom_PIN__c != true) {
            throw new CreditFactoryException('Number of cards in the Opportunity is different from number of Tankkarten objects linked to the Opportunity.');
        }

        try {
            this.sourceObject.put(this.opportunityMapping.Payment_Terms_Credit__c,String.valueOf(this.paymentTerms));
            this.sourceObject.put(this.opportunityMapping.Billing_Period__c,String.valueOf(this.billingPeriod));
            this.sourceObject.put(this.opportunityMapping.CF_Credit_Limit__c, this.creditLimit);
            this.sourceObject.put(this.opportunityMapping.Credit_check_date__c,Date.today());
            this.sourceObject.put(this.opportunityMapping.Processed_by__c, 'Autoprocessed by Sales');
            this.sourceObject.put(this.opportunityMapping.Credit_Decision__c, 'Genehmigt');
            this.sourceObject.CloseDate = Date.today();
            this.sourceObject.Billing_Period_by_Sales__c = true;
            this.sourceObject.StageName = 'Pending Credit - Contract Check';
            this.sourceObject.CF_Stage__c = 'Pending Credit - Contract Check';
            this.sourceObject.put(this.opportunityMapping.Risk_Category__c,this.riskCategory);
            this.sourceObject.put(this.opportunityMapping.Buffer__c, this.buffer * 100);
            if (this.maxCreditLimit != null) {
                this.sourceObject.put(this.opportunityMapping.Max_Credit_Limit__c, this.maxCreditLimit);
            }
            this.sourceObject.Last_CF_Errors__c = null;
            this.sourceObject.Account.Gesellschaftsform__c = this.company.legalform;
            update this.sourceObject;
            update this.sourceObject.Account;
            submitForApproval();
            return new PageReference('/' + this.sourceObject.Id);
        } catch (Exception e) {
            throw new CreditFactoryException('Change to Contract check failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : submitForApproval()
    *  Summary         : submit opportunity for approval in case of too high monthly credit limit
    *  CreatedDate     : 10/01/2018
    *  ModifiedDate    : 10/01/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void submitForApproval() {
        Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
        request.setComments('Submitting request for Contract check.');
        request.setObjectId(this.sourceObject.Id);
        request.setSubmitterId(UserInfo.getUserId()); 
        request.setSkipEntryCriteria(false);
        Approval.process(request); 
    }
}