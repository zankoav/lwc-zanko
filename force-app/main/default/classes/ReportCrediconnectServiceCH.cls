/*******************************************************************************
*  ReportCrediconnectServiceCH 
*  
*  Implementation of CreditReport for CrediconnectCH Webservice. Get company from webservice, validation, 
*  flows for Credit and Sales users.
*
******************************************************************************/
public class ReportCrediconnectServiceCH implements CreditReport {
	private Credit_Factory_Account__c accountMapping;
    private Credit_Factory_Opportunity__c opportunityMapping;
    private Opportunity sourceObject;
    private transient String xmlResponseBody;
    private transient Blob attachmentBody;
    private String creditSystemCompanyNumber;
    private CreditCompany company;
    private List<CreditCompanyEmployee> companyEmployeesList;
    private Credit_Factory_Report__c existingCreditReport;
    private Set<String> errorsSet;
    public final String ADDRESS_ERROR = 'Address';
    public final String COMPANY_NAME_ERROR = 'CompanyName';
    public final String CONTACT_ERROR = 'Contact';
    public final String CONTACT_ROLE_ERROR = 'ContactRole';
    public final String TAX_ID_ERROR = 'TaxId';
    public final String VAT_NUMBER_ERROR = 'VatNumber';
    public final String LOST_OPPORTUNITY_ERROR = 'LostOpportunity';
    private String COMPANY_FORM = CreditFactoryUtilities.returnLabelOfField('Account','Gesellschaftsform__c');
    private String TAX_ID = CreditFactoryUtilities.returnLabelOfField('Account','Steuernummer__c');
    private String VAT_NUMBER = CreditFactoryUtilities.returnLabelOfField('Account','Umsatzsteuer_ID__c');
	private Decimal buffer;
	private String riskCategory;
    private Decimal securityLevel;
    private Decimal creditLimitMonthlyPlus7;
    private Decimal maxCreditLimitMonthlyPlus7;
    private Decimal maxValueMonthlyPlus7;
    private Decimal depositMonthlyPlus7;
    private Decimal creditLimitMonthlyPlus14;
    private Decimal maxCreditLimitMonthlyPlus14;
    private Decimal maxValueMonthlyPlus14;
    private Decimal depositMonthlyPlus14;
    private Decimal creditLimitMonthlyPlus21;
    private Decimal maxCreditLimitMonthlyPlus21;
    private Decimal maxValueMonthlyPlus21;
    private Decimal depositMonthlyPlus21;
    private Decimal creditLimitMonthlyPlus27;
    private Decimal maxCreditLimitMonthlyPlus27;
    private Decimal maxValueMonthlyPlus27;
    private Decimal depositMonthlyPlus27;
    private Integer billingPeriod;
    private Integer paymentTerms;
    private Decimal creditLimit;
    private Decimal maxCreditLimit;
    private Decimal maxValue;
    private Decimal deposit;
    private CreditFactoryDecision decision;
    private String userSource;
    private String exceptionCode;


    /*******************************************************************************
    *  Name            : setUserSource(String userSource)
    *  Summary         : Set user source.
    *  CreatedDate     : 17/01/2019
    *  ModifiedDate    : -
    *  Parameters      : String userSource - user source
    *  Returns         : void
    ******************************************************************************/
    public void setUserSource(String userSource) {
    	this.userSource = userSource;
    }


    /*******************************************************************************
    *  Name            : getUserSource()
    *  Summary         : Return user source.
    *  CreatedDate     : 17/01/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : String
    ******************************************************************************/
    public String getUserSource() {
    	return this.userSource;
    }


    /*******************************************************************************
	*  Name 		   : setMapping()
	*  Summary         : Set custom settings for Opportunity and Account
	*  CreatedDate     : 21/08/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void setMapping() {
		try {
			this.accountMapping = Credit_Factory_Account__c.getInstance(CrediconnectWebserviceCH.CREDIT_SYSTEM_NAME);
			if (this.accountMapping == null) {
				throw new CreditFactoryException('Account mapping does not exist. ' + CreditFactoryUtilities.CONTACT_ADMIN);
			}
		} catch (Exception e) {
			throw new CreditFactoryException('Account mapping select error. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}

		try {
			this.opportunityMapping = Credit_Factory_Opportunity__c.getInstance(CrediconnectWebserviceCH.CREDIT_SYSTEM_NAME);
			if (this.opportunityMapping == null) {
				throw new CreditFactoryException('Opportunity mapping does not exist. ' + CreditFactoryUtilities.CONTACT_ADMIN);
			}
		} catch (Exception e) {
			throw new CreditFactoryException('Opportunity mapping select error. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}
	}


	/*******************************************************************************
	*  Name 		   : setSourceObject(String sfdcRecordId)
	*  Summary         : Get required information from object
	*  CreatedDate     : 21/08/2018
	*  ModifiedDate    : -
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
					' Account.Phone, Account.HR_Abteilung_HRA_HRB_und_HR_Nummer__c, ' + 
							'(SELECT Contact.Id, Contact.Email, Contact.Phone, Contact.LastName, Contact.FirstName, Contact.Name, IsPrimary, Role ' + 
							'FROM OpportunityContactRoles), ' +
							'(SELECT Id FROM Tankkarten__r WHERE Produktbezugskategorie__c = \'3 Kategorie 2 plus alle Shopartikel\')' +
			        ' FROM Opportunity' + 
			        ' WHERE Id = :sfdcRecordId';
			this.sourceObject = Database.query(soql);	
    	} catch (Exception e) {
    		System.debug('Credit Factory Error === ' + e.getMessage());
    		throw new CreditFactoryException('Select Opportunity failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
    	}
    }


    /*******************************************************************************
	*  Name 		   : getSourceObject()
	*  Summary         : Returns sObject that we need to use for credit request
	*  CreatedDate     : 21/08/2018
	*  ModifiedDate    : -
	*  Parameters      : 
	*  Returns         : sObject - Opportunity 
	******************************************************************************/
    public sObject getSourceObject() {
    	return this.sourceObject;
    }


    /*******************************************************************************
	*  Name 		   : setXmlResponse(CreditSystem creditSystem, String companyNip)
	*  Summary         : Send request to Credit System to get company, employees and pdf report
	*  CreatedDate     : 21/08/2018
	*  ModifiedDate    : -
	*  Parameters      : CreditSystem creditSystem - credit system, String companyId - parameter value from search page
	*  Returns         : void
	******************************************************************************/
    public void setXmlResponse(CreditSystem creditSystem, String companyId) {
    	//send request
		HttpRequest request;
		try {
			// Generate and send request
    		request = CrediconnectWebserviceCH.generateReportRequest(
    			creditSystem.getEndpointUrl(), creditSystem.getUserName(), 
    			creditSystem.getUserPassword(), companyId);
			Http h = new Http();
			HttpResponse response = h.send(request);
			this.xmlResponseBody = CrediconnectWebserviceCH.clearReportXml(response.getBody());
			this.creditSystemCompanyNumber = companyId;
		} catch (Exception e) {
			System.debug('Credit Factory === ' + request.getBody());
			String errorMessage = 'Error when sending request for report. ' + CreditFactoryUtilities.CONTACT_ADMIN;
            throw new CreditFactoryException(errorMessage);
		}
    }


    /*******************************************************************************
	*  Name 		   : getXmlResponse()
	*  Summary         : Returns xml reponse after report request sending
	*  CreatedDate     : 21/08/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : String
	******************************************************************************/
    public String getXmlResponse() {
    	return this.xmlResponseBody;
    }


    /*******************************************************************************
	*  Name 		   : setCompany()
	*  Summary         : Set Company information from xml response body
	*  CreatedDate     : 21/08/2018
	*  ModifiedDate    : -
	*  Parameters      : creditSystem - credit system, companyId - parameter value from search page
	*  Returns         : void
	******************************************************************************/
	public void setCompany(CreditSystem creditSystem, String companyId) {
		if (this.existingCreditReport != null) {
        	this.company = getExistingReportCompany();
        } else {
			setXmlResponse(creditSystem, companyId);
			String errorMessage;
	        try {
				String xml = this.xmlResponseBody;
		        Dom.Document domDoc = new Dom.Document();
		        domDoc.load(xml);
		        Dom.XMLNode xmldom = domDoc.getRootElement();
		        Dom.XMLNode reportDom = CrediconnectWebserviceCH.returnReportBody(xmldom);
		        this.attachmentBody = EncodingUtil.base64Decode(CrediconnectWebserviceCH.returnBlobBody(reportDom));
				this.company = CrediconnectWebserviceCH.returnReportCompany(reportDom, companyId);
	        } catch (Exception e) {
				System.debug('Credit Factory === ' + e.getMessage());
				if (errorMessage == null) {
					errorMessage = 'Set company error. ' + CreditFactoryUtilities.CONTACT_ADMIN + '<br/>' + e.getMessage();
				}
	            throw new CreditFactoryException(errorMessage);
	        }
	    }
	}


	public String getErrorToOrderRequest() {
		return null;
	}


	public String getInternalId() {
        return null;
    }


	/*******************************************************************************
	*  Name 		   : getCompany()
	*  Summary         : Returns Company with Credit information
	*  CreatedDate     : 21/08/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : CreditCompany
	******************************************************************************/
	public CreditCompany getCompany() {
		return this.company;
	}


	/*******************************************************************************
	*  Name 		   : setEmployees()
	*  Summary         : Set employees from credit company
	*  CreatedDate     : 26/11/2018
	*  ModifiedDate    : -
	*  Parameters      : 
	*  Returns         : void
	******************************************************************************/
	public void setEmployees() {
		try {
			if (this.existingCreditReport != null) { 
        		this.companyEmployeesList = getExistingReportCompanyEmployees();
        	} else { 
		        String xml = this.xmlResponseBody;
		        Dom.Document domDoc = new Dom.Document();
		        domDoc.load(xml);
		        Dom.XMLNode xmldom = domDoc.getRootElement();
		        Dom.XMLNode reportDom = CrediconnectWebserviceCH.returnReportBody(xmldom);
		        this.companyEmployeesList = CrediconnectWebserviceCH.returnReportCompanyEmployees(reportDom);
		    }
		} catch (Exception e) {
			System.debug('Credit Factory === ' + e.getMessage());
			String errorMessage = 'Set employees error. ' + CreditFactoryUtilities.CONTACT_ADMIN;
            throw new CreditFactoryException(errorMessage);	
		}
	}


	public void updateEmployees(CreditSystem creditSystem, String companyId) {}


	/*******************************************************************************
	*  Name 		   : setEmployee(Object employeeFromWSDL)
	*  Summary         : Set employees from credit company
	*  CreatedDate     : 21/08/2018
	*  ModifiedDate    : -
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
    *  Summary         : Set existing credit report from database.
    *  CreatedDate     : 21/08/2018
	*  ModifiedDate    : 08/01/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void setExistingCreditReports() {
        List<Credit_Factory_Report__c> creditReportsList = [
                SELECT Credit_System_Number__c, Reference_Number__c, Class_Rating__c, Turn_Over__c, Legal_Form__c, VAT_Number__c, Tax_Id__c, Date_Legal_Form__c, Register_Number__c,
                	Date_Last_Register_Entry__c, County_Court__c, Payment_Behaviour__c, Staff_Range__c, Credit_Limit__c, Credit_Limit_Currency__c, Credit_Decision__c, Date_of_Foundation__c,
                	Age_of_Company__c, First_Legal_Form__c, Company_Status__c, Name, Trade_Name__c, Street__c, Housenumber__c, Postcode__c, City__c, Country__c, Phone__c, Fax__c, Mobile__c, 
                	Email__c, Website__c, Solvency_Index__c, Paid_Up_Share_Capital__c, Paid_Up_Share_Capital_Currency__c, Name__c, 
                			(SELECT Type__c, Name FROM Credit_Factory_Report_Employees__r)
                FROM Credit_Factory_Report__c
                WHERE Opportunity__c = :this.sourceObject.Id AND CreatedDate > :Date.today().addMonths(-3)
                ORDER BY CreatedDate DESC
                LIMIT 1];
        if (! creditReportsList.isEmpty()) {
        	this.existingCreditReport = creditReportsList.get(0);
        }
    }


    /*******************************************************************************
    *  Name            : getExistingReportCompany()
    *  Summary         : Return company from Credit Factory Report object    
    *  CreatedDate     : 21/08/2018
	*  ModifiedDate    : 08/01/2019
    *  Parameters      : -
    *  Returns         : CreditCompany
    ******************************************************************************/
    private CreditCompany getExistingReportCompany() {
    	CreditCompany company = new CreditCompany();
    	company.creditSystemCompanyNumber = this.existingCreditReport.Credit_System_Number__c;
        company.classRating = this.existingCreditReport.Class_Rating__c;
        company.turnOver = this.existingCreditReport.Turn_Over__c;
        company.legalform = this.existingCreditReport.Legal_Form__c;
        company.vatid = this.existingCreditReport.VAT_Number__c;
        company.taxnumber = this.existingCreditReport.Tax_Id__c;
        company.staffcompanyrange = this.existingCreditReport.Staff_Range__c;
        company.creditLimit = this.existingCreditReport.Credit_Limit__c;
        company.creditLimitCurrency = this.existingCreditReport.Credit_Limit_Currency__c;
        company.creditDecision = this.existingCreditReport.Credit_Decision__c;
        company.dateoffoundation = this.existingCreditReport.Date_of_Foundation__c;
        company.ageofcompany = this.existingCreditReport.Age_of_Company__c;
        company.status = this.existingCreditReport.Company_Status__c;
        company.name = this.existingCreditReport.Name__c;
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
        company.paidUpShareCapital = this.existingCreditReport.Paid_Up_Share_Capital__c;
        company.paidUpShareCapitalCurrency = this.existingCreditReport.Paid_Up_Share_Capital_Currency__c;
        company.solvencyIndex = this.existingCreditReport.Solvency_Index__c;
        return company;
    }


    /*******************************************************************************
    *  Name            : getExistingReportCompanyEmployees()
    *  Summary         : return company from Credit Factory Report Employee object      
    *  CreatedDate     : 21/08/2018
	*  ModifiedDate    : 26/11/2018
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
    		employeesList.add(employee);
    	}
    	return employeesList;
    }


    /*******************************************************************************
	*  Name 		   : isSales()
	*  Summary         : Check Sales Profile
	*  CreatedDate     : 23/08/2018
	*  ModifiedDate    : -
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
	*  Name 		   : getErrorsSet()
	*  Summary         : Returns set of errors and display section to fix error on page
	*  CreatedDate     : 23/08/2018
	*  ModifiedDate    : -
	*  Parameters      : 
	*  Returns         : Set<String>
	******************************************************************************/
	public Set<String> getErrorsSet() {
		return this.errorsSet;
	}


	/*******************************************************************************
	*  Name 		   : validate()
	*  Summary         : Compare information from Crediconnect with Salesforce
	*  CreatedDate     : 23/08/2018
	*  ModifiedDate    : -
	*  Parameters      : 
	*  Returns         : Boolean - returns true if no errors
	******************************************************************************/
	public Boolean validate() {
		errorsSet = new Set<String>();
    	Boolean isValid = true;
    	if ( ! validateAddress()) isValid = false;
    	if ( ! validateLegalForm()) isValid = false;
    	if (isSales()) {
	    	if ( ! validateCompanyName()) isValid = false;
    	}
    	if ( ! validateTaxId()) isValid = false;
    	if ( ! validateVatNumber()) isValid = false;
    	if ( ! validateLostOpportunities()) isValid = false;
    	validateContact();

    	return isValid;
	}


	/*******************************************************************************
	*  Name 		   : validateAddress()
	*  Summary         : Compare Address information from Crediconnect with Salesforce
	*  CreatedDate     : 23/08/2018
	*  ModifiedDate    : -
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
			String errorMessage = 'Account Billing and Shipping Addresses should be the same as Crefo address';
            CreditFactoryUtilities.displayMessage('error',errorMessage);
            return false;
        }

        return true;
	}


	/*******************************************************************************
	*  Name            : validateStreet(String billingStreet, String shippingStreet, String crefoStreet)
	*  Summary         : Utility method for validateAddress();    
	*  CreatedDate     : 23/08/2018
	*  ModifiedDate    : -
	*  Parameters      : String billingStreet – Billing Street 
						 String shippingStreet – Shipping Street 
						 String crefoStreet – Street for Crediconnect 
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
	*  CreatedDate     : 23/08/2018
	*  ModifiedDate    : -
	*  Parameters      : String billingCity – Billing City 
						 String shippingCity – Shipping City 
						 String crefoCity – City for Crediconnect 
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
	*  Name            : validatePostalCode(String billingPostalCode, 
											String shippingPostalCode, String crefoPostalCode)
	*  Summary         : Utility method for validateAddress();    
	*  CreatedDate     : 23/08/2018
	*  ModifiedDate    : -
	*  Parameters      : String billingPostalCode – Billing PostalCode 
						 String shippingPostalCode – Shipping PostalCode 
						 String crefoPostalCode – PostalCode for Crediconnect 
	*  Returns         : Boolean – returns TRUE if all cities are the same
	******************************************************************************/
	public Boolean validatePostalCode(String billingPostalCode, 
									  String shippingPostalCode, String crefoPostalCode) {
		Boolean isValid = false;
		if (CreditFactoryUtilities.isStringsEquals(billingPostalCode,shippingPostalCode) && 
			CreditFactoryUtilities.isStringsEquals(billingPostalCode,crefoPostalCode)) {
			isValid = true;
		}
	    return isValid;						  
	}


	/*******************************************************************************
	*  Name 		   : validateLegalForm()
	*  Summary         : Compare Legal Form information from Crediconnect with Salesforce
	*  CreatedDate     : 23/08/2018
	*  ModifiedDate    : -
	*  Parameters      : 
	*  Returns         : Boolean - returns true if no errors
	******************************************************************************/
	public Boolean validateLegalForm() {
        return true;
	}


	/*******************************************************************************
	*  Name 		   : validateContact()
	*  Summary         : Check that contact from CreditReform exists in Salesforce
	*  CreatedDate     : 23/08/2018
	*  ModifiedDate    : 28/11/2018
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
            String lastName;
        	if (this.sourceObject.Account.BillingCountryCode == 'CHDE') {
        		if (contactRelation.Contact.FirstName != null) {
	        		firstName = CreditFactoryUtilities.replaceGermanCharacters(contactRelation.Contact.FirstName).toUpperCase().replace('’', '\'');
	        	}
	            lastName = CreditFactoryUtilities.replaceGermanCharacters(contactRelation.Contact.LastName).toUpperCase().replace('’', '\'');
        	} else if (this.sourceObject.Account.BillingCountryCode == 'CHFR') {
        		if (contactRelation.Contact.FirstName != null) {
	        		firstName = CreditFactoryUtilities.replaceFrenchCharacters(contactRelation.Contact.FirstName).toUpperCase().replace('’', '\'');
		        }
		        lastName = CreditFactoryUtilities.replaceFrenchCharacters(contactRelation.Contact.LastName).toUpperCase().replace('’', '\'');
        	} else {
        		if (contactRelation.Contact.FirstName != null) {
	        		firstName = contactRelation.Contact.FirstName.toUpperCase().replace('’', '\'');
	        	}
	            lastName = contactRelation.Contact.LastName.toUpperCase().replace('’', '\'');
        	}

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
        		String empName;
        		if (this.sourceObject.Account.BillingCountryCode == 'CHDE') {
	        		empName = CreditFactoryUtilities.replaceGermanCharacters(emp.ename).toUpperCase().replace('\u00a0', ' ');
	        	} else if (this.sourceObject.Account.BillingCountryCode == 'CHFR') {
	        		empName = CreditFactoryUtilities.replaceFrenchCharacters(emp.ename).toUpperCase().replace('\u00a0', ' ');
	        	} else {
	        		empName = emp.ename.toUpperCase().replace('\u00a0', ' ');
	        	}

	        	for (String lastName : contactsLastNamesSet) {
					if (empName.contains(lastName)) {
						isContactExists = true;
					}
				}
	        }
        }

    	if (this.userSource == 'E2E Long Form') {
        	for (String firstAndLastName : contactsFirstAndLastNamesSet) {
				if (firstAndLastName == this.company.Name.toUpperCase().replace('’', '\'') ||
	        			this.sourceObject.Account.BillingCountryCode == 'CHDE' && firstAndLastName == CreditFactoryUtilities.replaceGermanCharacters(this.company.Name).toUpperCase().replace('’', '\'') ||
	        			this.sourceObject.Account.BillingCountryCode == 'CHFR' && firstAndLastName == CreditFactoryUtilities.replaceFrenchCharacters(this.company.Name).toUpperCase().replace('’', '\'')) {
        			isContactExists = true;
        		}
			}
        } else if (validateCompanyName() == true) {
            for (String firstAndLastName : contactsFirstAndLastNamesSet) {
            	if (firstAndLastName == this.sourceObject.Account.Name.toUpperCase().replace('’', '\'') ||
	        			this.sourceObject.Account.BillingCountryCode == 'CHDE' && firstAndLastName == CreditFactoryUtilities.replaceGermanCharacters(this.sourceObject.Account.Name).toUpperCase().replace('’', '\'') ||
	        			this.sourceObject.Account.BillingCountryCode == 'CHFR' && firstAndLastName == CreditFactoryUtilities.replaceFrenchCharacters(this.sourceObject.Account.Name).toUpperCase().replace('’', '\'')) {
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
	        		if (primaryContactRole == 'Executive assistant' || primaryContactRole == 'Fleet manager' || primaryContactRole == 'Owner\'s relative') {
		    			errorsSet.add(CONTACT_ROLE_ERROR);
		    			CreditFactoryUtilities.displayMessage('error', 'Please choose call with contact role confirmation.'); 
		    		}
		    	}

        		return false;
        	} else if ( ! isContactExists) {
        		if (this.userSource != 'E2E Long Form') {
	        		errorsSet.add(CONTACT_ERROR);
		        	String errorMessage = 'Crediconnect Contact person doesn\'t exist in Account\'s Contacts';
		        	CreditFactoryUtilities.displayMessage('error', errorMessage);
		        	if (primaryContactRole == 'Executive assistant' || primaryContactRole == 'Fleet manager' || primaryContactRole == 'Owner\'s relative') {
		    			errorsSet.add(CONTACT_ROLE_ERROR);
		    			CreditFactoryUtilities.displayMessage('error', 'Please choose call with contact role confirmation.'); 
		    		}
		    	}

	            return false;
	        }
        }

        return true;
	}


	public void setParentCompanyId() {}


	public String getParentCompanyId() {
		return null;
	}


	/*******************************************************************************
	*  Name 		   : validateCompanyName()
	*  Summary         : Check that Account Name is the same as Company Name from Salesforce
	*  CreatedDate     : 23/08/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : Boolean - returns true if no errors
	******************************************************************************/
	public Boolean validateCompanyName() {
        if ( ! CreditFactoryUtilities.isStringsEquals(sourceObject.Account.Name, company.Name)) {
            errorsSet.add(COMPANY_NAME_ERROR);
            String errorMessage = 'Account Name and Crefo Name mismatch';
            CreditFactoryUtilities.displayMessage('error',errorMessage);

            return false;
        }

		return true;
	}


	/*******************************************************************************
	*  Name            : validateTaxId()
	*  Summary         : Compare Crediconnect tax id with Salesforce    
	*  CreatedDate     : 23/08/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : Boolean
	******************************************************************************/
	public Boolean validateTaxId() {
		if (company.taxnumber != null && company.taxnumber != '0' && company.taxnumber != 'nicht bekannt' && company.taxnumber != 'unbekannt' &&
				! CreditFactoryUtilities.isStringsEquals(company.taxnumber, (String)sourceObject.getSobject('Account').get(this.accountMapping.Tax_Id__c))) {
            errorsSet.add(TAX_ID_ERROR);
            String errorMessage = 'Account Tax ID mismatch (' + CreditReformWebservice.CREDIT_SYSTEM_NAME + 
            	' to Account ' + TAX_ID + ')';
            CreditFactoryUtilities.displayMessage('error',errorMessage);
            return false;
        }

        return true;
	}


	/*******************************************************************************
	*  Name            : validateVatNumber()
	*  Summary         : Compare Crediconnect tax id with Salesforce    
	*  CreatedDate     : 23/08/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : Boolean
	******************************************************************************/
	public Boolean validateVatNumber() {
		if (company.vatid != null && company.vatid != '0' && company.vatid != 'nicht bekannt' && company.vatid != 'unbekannt' &&
				! CreditFactoryUtilities.isStringsEquals(company.vatid, (String)sourceObject.getSobject('Account').get(this.accountMapping.VAT_Number__c))) {
            errorsSet.add(VAT_NUMBER_ERROR);
            String errorMessage = 'Account VAT number mismatch (' + CreditReformWebservice.CREDIT_SYSTEM_NAME + 
            	' to Account ' + VAT_NUMBER + ')';
            CreditFactoryUtilities.displayMessage('error',errorMessage);
            return false;
        }

        return true;
	}


	/*******************************************************************************
	*  Name            : validateLostOpportunities()
	*  Summary         : Check for Lost Opportunities relates to current Opportunity's 
						 Account or its Contacts    
	*  CreatedDate     : 23/08/2018
	*  ModifiedDate    : -
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
	*  Name 		   : validateBlackList()
	*  Summary         : Check if Company is in black list.
	*  CreatedDate     : 17/01/2019
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


	/*******************************************************************************
	*  Name            : doUpdateAddress()
	*  Summary         : Update address information in Account based on address from Crediconnect
	*  CreatedDate     : 23/08/2018
	*  ModifiedDate    : -
	*  Parameters      : -
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


	public void doUpdateWithAdditionalAddress() {}


    public void doUpdateWithPostalAddress() {}


    public void doUpdateWithRegisteredAddress() {}


    /*******************************************************************************
	*  Name            : doUpdateCompanyName()
	*  Summary         : Update Account name with Crediconnect Company Name
	*  CreatedDate     : 23/08/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
    public void doUpdateCompanyName() {
    	Account account = new Account(
    		Id = sourceObject.AccountId,
            Name = company.name);
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
	*  Summary         : Update Account Tax Id with Crif Tax Id
	*  CreatedDate     : 23/08/2018
	*  ModifiedDate    : -
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
	*  Summary         : Update Account Vat Number with Crif Vat Number
	*  CreatedDate     : 23/08/2018
	*  ModifiedDate    : -
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


    public void doUpdateTradeRegisterNumber() {}


    /*******************************************************************************
	*  Name 		   : updateDefaultFieldSetForRecord()
	*  Summary         : Update specific fields in Opportunity by Sales when all validations passed
	*  CreatedDate     : 23/08/2018
	*  ModifiedDate    : -
	*  Parameters      : -
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
		    if (! String.isEmpty(this.company.dateoffoundation)) {
		    	this.sourceObject.put(
		    		this.opportunityMapping.Year_of_foundation__c,
		    		this.company.dateoffoundation.substring(0, 4));
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
		    if (this.company.solvencyIndex != null) {
		    	this.sourceObject.Bonitaetsindex__c = this.company.solvencyIndex;
		    }
	        this.sourceObject.put(
	        	this.opportunityMapping.Details_Correct__c,
	        	'Ja');
	        if (this.sourceObject.CF_Stage__c != 'Pending Deposit') {
		        this.sourceObject.CF_Stage__c = 'Report generated';
		    }
	        this.sourceObject.Last_CF_Errors__c = null;
	        update this.sourceObject;
		} catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Default fields update failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}
	}


	/*******************************************************************************
	*  Name            : updateDefaultFieldSetForInvalidRecord()
	*  Summary         : Update specific fields in Opportunity by Sales even with some validation errors    
	*  CreatedDate     : 01/03/2019
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void updateDefaultFieldSetForRecord() {
		try {
			setRiskCategory(this.company.classRating);
			this.sourceObject.put(this.opportunityMapping.Risk_Category__c, this.riskCategory);
		    update this.sourceObject;
		} catch (Exception e) {
			System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Default fields update failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}
	}


	/*******************************************************************************
	*  Name 		   : getBuffer()
	*  Summary         : Return buffer value
	*  CreatedDate     : 23/08/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : String
	******************************************************************************/
	public Decimal getBuffer() {
		return this.buffer;
	}


	/*******************************************************************************
	*  Name 		   : setBuffer(String classRating)
	*  Summary         : Calculate buffer
	*  CreatedDate     : 23/08/2018
	*  ModifiedDate    : 18/02/2019
	*  Parameters      : classRating - Credit Company rating
	*  Returns         : void
	******************************************************************************/
	public void setBuffer(String classRating) {
		if (classRating == '1' || classRating == '2') {
			if (! String.isEmpty(this.company.dateoffoundation) && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(0, 4)), 
					Integer.valueOf(this.company.dateoffoundation.substring(5, 7)), Integer.valueOf(this.company.dateoffoundation.substring(8, 10))).monthsBetween(Date.today()) < 18) {
				this.buffer = 0.1;
			} else {
				this.buffer = 0.3;
			}
		} else if (classRating == '3') {
			if (! String.isEmpty(this.company.dateoffoundation) && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(0, 4)), 
					Integer.valueOf(this.company.dateoffoundation.substring(5, 7)), Integer.valueOf(this.company.dateoffoundation.substring(8, 10))).monthsBetween(Date.today()) < 18) {
				this.buffer = 0.1;
			} else {
				this.buffer = 0.2;
			}
		} else if (classRating == '4' || classRating == '5') {
			this.buffer = 0.1;
        } else if (classRating == '6') {
			this.buffer = 0;
        } 
	}


	/*******************************************************************************
	*  Name 		   : getRiskCategory()
	*  Summary         : Return Risk Category
	*  CreatedDate     : 23/08/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : String
	******************************************************************************/
	public String getRiskCategory() {
		return this.riskCategory;
	}


	/*******************************************************************************
	*  Name 		   : setRiskCategory(String classRating)
	*  Summary         : Calculate Risk Category
	*  CreatedDate     : 23/08/2018
	*  ModifiedDate    : 18/02/2019
	*  Parameters      : classRating - Credit Company rating (1, 2, 3, ...)
	*  Returns         : void
	******************************************************************************/
	public void setRiskCategory(String classRating) {
		if (classRating == '1' || classRating == '2') {
			if (! String.isEmpty(this.company.dateoffoundation) && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(0, 4)), 
					Integer.valueOf(this.company.dateoffoundation.substring(5, 7)), Integer.valueOf(this.company.dateoffoundation.substring(8, 10))).monthsBetween(Date.today()) < 18) {
				this.riskCategory = 'High';
			} else {
				this.riskCategory = 'Low';
			}
		} else if (classRating == '3') {
			if (! String.isEmpty(this.company.dateoffoundation) && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(0, 4)), 
					Integer.valueOf(this.company.dateoffoundation.substring(5, 7)), Integer.valueOf(this.company.dateoffoundation.substring(8, 10))).monthsBetween(Date.today()) < 18) {
				this.riskCategory = 'High';
			} else {
				this.riskCategory = 'Medium';
			}
		} else if (classRating == '4' || classRating == '5') {
			this.riskCategory = 'High';
        } else if (classRating == '6') {
			this.riskCategory = 'Very';
        } 
	}


	/*******************************************************************************
	*  Name            : getSecurityLevel()
	*  Summary         : Return security level
	*  CreatedDate     : 23/08/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : String
	******************************************************************************/
	public Decimal getSecurityLevel() {
		return this.securityLevel;
	}


	/*******************************************************************************
	*  Name            : setSecurityLevel()
	*  Summary         : Calculate security level
	*  CreatedDate     : 23/08/2018
	*  ModifiedDate    : 13/02/2019
	*  Parameters      : classRating - Credit Company rating (1, 2, 3, ...)
	*  Returns         : void
	******************************************************************************/
	public void setSecurityLevel(String classRating) {
		if (classRating == '1' || classRating == '2' || classRating == '3') {
			this.securityLevel = 33;
		} else if (classRating == '4') {
			if (! String.isEmpty(this.company.dateoffoundation) && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(0, 4)), 
					Integer.valueOf(this.company.dateoffoundation.substring(5, 7)), Integer.valueOf(this.company.dateoffoundation.substring(8, 10))).monthsBetween(Date.today()) < 18) {
				this.securityLevel = 33;
			} else {
				this.securityLevel = 4;
			}
		} else if (classRating == '5') {
			this.securityLevel = 70;
		} else if (classRating == '6') {
			this.securityLevel = 110;
		}
	}


	public Decimal getCreditLimitWeeklyPlus7() {
		return null;
	}


	public void setCreditLimitWeeklyPlus7(Decimal buffer) {}


	public Decimal getMaxCreditLimitWeeklyPlus7() {
		return null;
	}


	public void setMaxCreditLimitWeeklyPlus7() {}


	public Decimal getMaxValueWeeklyPlus7() {
		return null;
	}


	public void setMaxValueWeeklyPlus7() {}


	public Decimal getDepositWeeklyPlus7() {
		return null;
	}


	public void setDepositWeeklyPlus7() {}


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


	public Decimal getCreditLimitBiWeeklyPlus14() {
		return null;
	}


	public void setCreditLimitBiWeeklyPlus14(Decimal buffer) {}


	public Decimal getMaxCreditLimitBiWeeklyPlus14() {
		return null;
	}


	public void setMaxCreditLimitBiWeeklyPlus14() {}


	public Decimal getDepositBiWeeklyPlus14() {
		return null;
	}


	public void setDepositBiWeeklyPlus14() {}


	public Decimal getMaxValueBiWeeklyPlus14() {
		return null;
	}


	public void setMaxValueBiWeeklyPlus14() {}


	/*******************************************************************************
	*  Name 		   : getCreditLimitMonthlyPlus7()
	*  Summary         : Return Credit Limit Monthly Plus 7
	*  CreatedDate     : 23/08/2018
	*  ModifiedDate    : 29/11/2018
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public Decimal getCreditLimitMonthlyPlus7() {
		if (this.creditLimitMonthlyPlus7 != null) {
			if (this.creditLimitMonthlyPlus7 < 50) {
				this.creditLimitMonthlyPlus7 = this.creditLimitMonthlyPlus7 + 50;
			}
			this.creditLimitMonthlyPlus7 = (this.creditLimitMonthlyPlus7 / 100).round(System.RoundingMode.HALF_UP) * 100;
		}

		return this.creditLimitMonthlyPlus7;

	}


	/*******************************************************************************
	*  Name 		   : setCreditLimitMonthlyPlus7(Decimal buffer)
	*  Summary         : Calculate Credit Limit Monthly Plus 7
	*  CreatedDate     : 23/08/2018
	*  ModifiedDate    : -
	*  Parameters      : buffer - 0, 0.1, 0.2 or 0.3
	*  Returns         : void
	******************************************************************************/
	public void setCreditLimitMonthlyPlus7(Decimal buffer) {
		try {
			this.creditLimitMonthlyPlus7 = ((Decimal)this.sourceObject.get(this.opportunityMapping.Monthly_Volume_Currency__c) * 
				((30.0 + 7.0)/30.0)*(1.0 + buffer));
		} catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Credit Limit Monthly + 7 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}
	}


	/*******************************************************************************
	*  Name 		   : getMaxCreditLimitMonthlyPlus7()
	*  Summary         : Return Max Credit Limit Monthly Plus 7
	*  CreatedDate     : 23/08/2018
	*  ModifiedDate    : 29/11/2108
	*  Parameters      : -
	*  Returns         : Decimal
	******************************************************************************/
	public Decimal getMaxCreditLimitMonthlyPlus7() {
		if (this.maxCreditLimitMonthlyPlus7 != null) {
			this.maxCreditLimitMonthlyPlus7 = (this.maxCreditLimitMonthlyPlus7 / 100).round(System.RoundingMode.HALF_UP) * 100;
		}

		return this.maxCreditLimitMonthlyPlus7;
	}


	/*******************************************************************************
	*  Name            : setMaxCreditLimitMonthlyPlus7()
	*  Summary         : Calculate Max Credit Limit Monthly Plus 7    
	*  CreatedDate     : 23/08/2018
	*  ModifiedDate    : 12/02/2019
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void setMaxCreditLimitMonthlyPlus7() {
		try {
			if (this.company.classRating == '1' || this.company.classRating == '2' || this.company.classRating == '3' || this.company.classRating == '4') {
				Decimal totalConsumption = this.sourceObject.Total_consumption_l_month__c;
				if (totalConsumption != null && totalConsumption != 0) {
					Decimal nonFuelExposure = 0;
					if (this.sourceObject.Non_fuel_exposure__c != null) nonFuelExposure = this.sourceObject.Non_fuel_exposure__c;
					Decimal creditLimit1000MonthlyPlus7 = (((Decimal)this.sourceObject.get(this.opportunityMapping.Monthly_Volume_Currency__c) - nonFuelExposure) / totalConsumption * 1000 + 
						this.sourceObject.Non_fuel_exposure__c) * (30.0 + 7.0) / 30.0 * (1.0 + this.buffer);

					if (this.creditLimitMonthlyPlus7 * 2 < creditLimit1000MonthlyPlus7) {
						this.maxCreditLimitMonthlyPlus7 = this.creditLimitMonthlyPlus7 * 2;
					} else {
						this.maxCreditLimitMonthlyPlus7 = creditLimit1000MonthlyPlus7;
					} 
				} else {
					this.maxCreditLimitMonthlyPlus7 = 0;
				}
		    }
	    } catch (Exception e) {
	    	System.debug('Credit Factory === ' + e.getMessage());
	    	throw new CreditFactoryException('Max Credit Limit Monthly + 7 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
	    }
	}


	/*******************************************************************************
	*  Name            : getMaxValueMonthlyPlus7()
	*  Summary         : Return Max value of Credit Limit including deposit Monthly Plus 7
	*  CreatedDate     : 31/01/2019
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : Decimal
	******************************************************************************/
	public Decimal getMaxValueMonthlyPlus7() {
		try {
			return this.maxValueMonthlyPlus7;
		} catch (Exception e) {
		    System.debug('Credit Factory === ' + e.getMessage());
	    	throw new CreditFactoryException('Max Value Monthly + 7 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}
	}


	/*******************************************************************************
	*  Name            : setMaxValueMonthlyPlus7()
	*  Summary         : Calculate Max value of Credit Limit including deposit Monthly Plus 7
	*  CreatedDate     : 31/01/2019
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void setMaxValueMonthlyPlus7() {
		try {
		    if (this.creditLimitMonthlyPlus7 * 2 < 10000) {
		    	this.maxValueMonthlyPlus7 = this.creditLimitMonthlyPlus7 * 2;
		    } else {
		    	this.maxValueMonthlyPlus7 = 10000;
		    }
		} catch (Exception e) {
		    System.debug('Credit Factory === ' + e.getMessage());
	    	throw new CreditFactoryException('Max Value Monthly + 7 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}
	}


	/*******************************************************************************
	*  Name            : getDepositMonthlyPlus7()
	*  Summary         : Return Deposit Monthly Plus 7
	*  CreatedDate     : 23/08/2018
	*  ModifiedDate    : 29/11/2018
	*  Parameters      : -
	*  Returns         : Decimal
	******************************************************************************/
	public Decimal getDepositMonthlyPlus7() {
		if (this.depositMonthlyPlus7 != null) {
			if (this.depositMonthlyPlus7 > 0 && this.depositMonthlyPlus7 < 50) {
				this.depositMonthlyPlus7 = this.depositMonthlyPlus7 + 50;
			}
			this.depositMonthlyPlus7 = (this.depositMonthlyPlus7 / 100).round(System.RoundingMode.HALF_UP) * 100;
		}

		return this.depositMonthlyPlus7;
	}


	/*******************************************************************************
	*  Name            : setDepositMonthlyPlus7()
	*  Summary         : Calculate Deposit Monthly Plus 7    
	*  CreatedDate     : 23/08/2018
	*  ModifiedDate    : 31/01/2019
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void setDepositMonthlyPlus7() {
		try {
			if ((this.company.classRating == '1' || this.company.classRating == '2' || this.company.classRating == '3' || this.company.classRating == '4') && 
					this.sourceObject.Total_consumption_l_month__c < 1001 && this.sourceObject.Sec_Channel__c == 'JITB' && 
					! String.isEmpty(this.company.dateoffoundation) && Integer.valueOf(this.company.dateoffoundation.substring(0, 4)) > Date.today().Year() - 2 && 
					Integer.valueOf(this.sourceObject.get(this.opportunityMapping.Number_of_Cards__c)) < 3 &&
					this.sourceObject.get(this.opportunityMapping.Payment_Method__c) == 'Lastschrift' &&
					this.sourceObject.Tankkarten__r.isEmpty()) {
				this.depositMonthlyPlus7 = 0;
			}
		} catch (Exception e) {
			System.debug('Credit Factory === ' + e.getMessage());
			throw new CreditFactoryException('Deposit Monthly calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}
	}


	/*******************************************************************************
	*  Name 		   : getCreditLimitMonthlyPlus14()
	*  Summary         : Return Credit Limit Monthly Plus 14
	*  CreatedDate     : 10/10/2018
	*  ModifiedDate    : 29/11/2018
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public Decimal getCreditLimitMonthlyPlus14() {
		if (this.creditLimitMonthlyPlus14 != null) {
			if (this.creditLimitMonthlyPlus14 < 50) {
				this.creditLimitMonthlyPlus14 = this.creditLimitMonthlyPlus14 + 50;
			}
			this.creditLimitMonthlyPlus14 = (this.creditLimitMonthlyPlus14 / 100).round(System.RoundingMode.HALF_UP) * 100;
		}

		return this.creditLimitMonthlyPlus14;
	}


	/*******************************************************************************
	*  Name 		   : setCreditLimitMonthlyPlus14(Decimal buffer)
	*  Summary         : Calculate Credit Limit Monthly Plus 14
	*  CreatedDate     : 10/10/2018
	*  ModifiedDate    : -
	*  Parameters      : buffer - 0, 0.1, 0.2 or 0.3
	*  Returns         : void
	******************************************************************************/
	public void setCreditLimitMonthlyPlus14(Decimal buffer) {
		try {
			this.creditLimitMonthlyPlus14 = ((Decimal)this.sourceObject.get(this.opportunityMapping.Monthly_Volume_Currency__c) * 
				((30.0 + 14.0)/30.0)*(1.0 + buffer));
		} catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Credit Limit Monthly + 14 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}
	}


	/*******************************************************************************
	*  Name 		   : getMaxCreditLimitMonthlyPlus14()
	*  Summary         : Return Max Credit Limit Monthly Plus 14
	*  CreatedDate     : 10/10/2018
	*  ModifiedDate    : 29/11/2018
	*  Parameters      : -
	*  Returns         : Decimal
	******************************************************************************/
	public Decimal getMaxCreditLimitMonthlyPlus14() {
		if (this.maxCreditLimitMonthlyPlus14 != null) {
			this.maxCreditLimitMonthlyPlus14 = (this.maxCreditLimitMonthlyPlus14 / 100).round(System.RoundingMode.HALF_UP) * 100;
		}

		return this.maxCreditLimitMonthlyPlus14;
	}


	/*******************************************************************************
	*  Name            : setMaxCreditLimitMonthlyPlus14()
	*  Summary         : Calculate Max Credit Limit Monthly Plus 14    
	*  CreatedDate     : 10/10/2018
	*  ModifiedDate    : 12/02/2019
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void setMaxCreditLimitMonthlyPlus14() {
		try {
			if (this.company.classRating == '1' || this.company.classRating == '2' || this.company.classRating == '3' || this.company.classRating == '4') {
				Decimal totalConsumption = this.sourceObject.Total_consumption_l_month__c;
				if (totalConsumption != null && totalConsumption != 0) {
					Decimal nonFuelExposure = 0;
					if (this.sourceObject.Non_fuel_exposure__c != null) nonFuelExposure = this.sourceObject.Non_fuel_exposure__c;
					Decimal creditLimit800MonthlyPlus14 = (((Decimal)this.sourceObject.get(this.opportunityMapping.Monthly_Volume_Currency__c) - nonFuelExposure) / totalConsumption * 800 + 
						this.sourceObject.Non_fuel_exposure__c) * (30.0 + 14.0) / 30.0 * (1.0 + this.buffer);

					if (this.creditLimitMonthlyPlus14 * 2 < creditLimit800MonthlyPlus14) {
						this.maxCreditLimitMonthlyPlus14 = this.creditLimitMonthlyPlus14 * 2;
					} else {
						this.maxCreditLimitMonthlyPlus14 = creditLimit800MonthlyPlus14;
					}
				} else {
					this.maxCreditLimitMonthlyPlus14 = 0;
				}
		    }
	    } catch (Exception e) {
	    	System.debug('Credit Factory === ' + e.getMessage());
	    	throw new CreditFactoryException('Max Credit Limit Monthly + 14 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
	    }
	}


	/*******************************************************************************
	*  Name            : getDepositMonthlyPlus14()
	*  Summary         : Return Deposit Monthly Plus 14
	*  CreatedDate     : 10/10/2018
	*  ModifiedDate    : 29/11/2018
	*  Parameters      : -
	*  Returns         : Decimal
	******************************************************************************/
	public Decimal getDepositMonthlyPlus14() {
		if (this.depositMonthlyPlus14 != null) {
			if (this.depositMonthlyPlus14 > 0 && this.depositMonthlyPlus14 < 50) {
				this.depositMonthlyPlus14 = this.depositMonthlyPlus14 + 50;
			}
			this.depositMonthlyPlus14 = (this.depositMonthlyPlus14 / 100).round(System.RoundingMode.HALF_UP) * 100;
		}

		return this.depositMonthlyPlus14;
	}


	/*******************************************************************************
	*  Name            : setDepositMonthlyPlus14()
	*  Summary         : Calculate Deposit Monthly Plus 14
	*  CreatedDate     : 10/10/2018
	*  ModifiedDate    : 31/01/2019
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void setDepositMonthlyPlus14() {
		try {
			if ((this.company.classRating == '1' || this.company.classRating == '2' || this.company.classRating == '3' || this.company.classRating == '4') && 
					this.sourceObject.Total_consumption_l_month__c < 801 && ! String.isEmpty(this.company.dateoffoundation) && 
					Integer.valueOf(this.company.dateoffoundation.substring(0, 4)) > Date.today().Year() - 2 && 
					this.sourceObject.Tankkarten__r.isEmpty() && Integer.valueOf(this.sourceObject.get(this.opportunityMapping.Number_of_Cards__c)) < 3 &&
					this.sourceObject.Sec_Channel__c == 'JITB' && this.sourceObject.get(this.opportunityMapping.Payment_Method__c) == 'Banküberweisung') {
				this.depositMonthlyPlus14 = 0;
			}
		} catch (Exception e) {
			System.debug('Credit Factory === ' + e.getMessage());
			throw new CreditFactoryException('Deposit Monthly + 14 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}
	}


	/*******************************************************************************
	*  Name 		   : getCreditLimitMonthlyPlus21()
	*  Summary         : Return Credit Limit Monthly Plus 21
	*  CreatedDate     : 10/10/2018
	*  ModifiedDate    : 29/11/2018
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public Decimal getCreditLimitMonthlyPlus21() {
		if (this.creditLimitMonthlyPlus21 != null) {
			if (this.creditLimitMonthlyPlus21 < 50) {
				this.creditLimitMonthlyPlus21 = this.creditLimitMonthlyPlus21 + 50;
			}
			
			this.creditLimitMonthlyPlus21 = (this.creditLimitMonthlyPlus21 / 100).round(System.RoundingMode.HALF_UP) * 100;
		} 

		return this.creditLimitMonthlyPlus21;
	}


	/*******************************************************************************
	*  Name 		   : setCreditLimitMonthlyPlus21(Decimal buffer)
	*  Summary         : Calculate Credit Limit Monthly Plus 21
	*  CreatedDate     : 10/10/2018
	*  ModifiedDate    : -
	*  Parameters      : buffer - 0, 0.1, 0.2 or 0.3
	*  Returns         : void
	******************************************************************************/
	public void setCreditLimitMonthlyPlus21(Decimal buffer) {
		try {
			this.creditLimitMonthlyPlus21 = ((Decimal)this.sourceObject.get(this.opportunityMapping.Monthly_Volume_Currency__c) * 
				((30.0 + 21.0)/30.0)*(1.0 + buffer));
		} catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Credit Limit Monthly + 21 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}
	}


	/*******************************************************************************
	*  Name 		   : getMaxCreditLimitMonthlyPlus21()
	*  Summary         : Return Max Credit Limit Monthly Plus 21
	*  CreatedDate     : 10/10/2018
	*  ModifiedDate    : 29/11/2018
	*  Parameters      : -
	*  Returns         : Decimal
	******************************************************************************/
	public Decimal getMaxCreditLimitMonthlyPlus21() {
		if (this.maxCreditLimitMonthlyPlus21 != null) {
			this.maxCreditLimitMonthlyPlus21 = (this.maxCreditLimitMonthlyPlus21 / 100).round(System.RoundingMode.HALF_UP) * 100;
		}

		return this.maxCreditLimitMonthlyPlus21;
	}


	/*******************************************************************************
	*  Name            : setMaxCreditLimitMonthlyPlus21()
	*  Summary         : Calculate Max Credit Limit Monthly Plus 21 
	*  CreatedDate     : 10/10/2018
	*  ModifiedDate    : 12/02/2019
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void setMaxCreditLimitMonthlyPlus21() {
		try {
			if (this.company.classRating == '1' || this.company.classRating == '2' || this.company.classRating == '3' || this.company.classRating == '4') {
				Decimal totalConsumption = this.sourceObject.Total_consumption_l_month__c;
				if (totalConsumption != null && totalConsumption != 0) {
					Decimal nonFuelExposure = 0;
					if (this.sourceObject.Non_fuel_exposure__c != null) nonFuelExposure = this.sourceObject.Non_fuel_exposure__c;
					Decimal creditLimit350MonthlyPlus21 = (((Decimal)this.sourceObject.get(this.opportunityMapping.Monthly_Volume_Currency__c) - nonFuelExposure) / totalConsumption * 350 + 
						this.sourceObject.Non_fuel_exposure__c) * (30.0 + 21.0) / 30.0 * (1.0 + this.buffer);

					if (this.creditLimitMonthlyPlus21 * 2 < creditLimit350MonthlyPlus21) {
						this.maxCreditLimitMonthlyPlus21 = this.creditLimitMonthlyPlus21 * 2;
					} else {
						this.maxCreditLimitMonthlyPlus21 = creditLimit350MonthlyPlus21;
					} 
				} else {
					this.maxCreditLimitMonthlyPlus21 = 0;
				}
		    }
	    } catch (Exception e) {
	    	System.debug('Credit Factory === ' + e.getMessage());
	    	throw new CreditFactoryException('Max Credit Limit Monthly + 21 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
	    }
	}


	/*******************************************************************************
	*  Name            : getDepositMonthlyPlus21()
	*  Summary         : Return Deposit Monthly Plus 21
	*  CreatedDate     : 10/10/2018
	*  ModifiedDate    : 29/11/2018
	*  Parameters      : -
	*  Returns         : Decimal
	******************************************************************************/
	public Decimal getDepositMonthlyPlus21() {
		if (this.depositMonthlyPlus21 != null) {
			if (this.depositMonthlyPlus21 > 0 && this.depositMonthlyPlus21 < 50) {
				this.depositMonthlyPlus21 = this.depositMonthlyPlus21 + 50;
			}

			this.depositMonthlyPlus21 = (this.depositMonthlyPlus21 / 100).round(System.RoundingMode.HALF_UP) * 100;
		}

		return this.depositMonthlyPlus21;
	}


	/*******************************************************************************
	*  Name            : setDepositMonthlyPlus21()
	*  Summary         : Calculate Deposit Monthly Plus 21
	*  CreatedDate     : 10/10/2018
	*  ModifiedDate    : 31/01/2019
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void setDepositMonthlyPlus21() {
		try {
			if ((this.company.classRating == '1' || this.company.classRating == '2' || this.company.classRating == '3' || this.company.classRating == '4') && 
					this.sourceObject.Total_consumption_l_month__c < 351 && ! String.isEmpty(this.company.dateoffoundation) && 
					Integer.valueOf(this.company.dateoffoundation.substring(0, 4)) > Date.today().Year() - 2 && 
					this.sourceObject.Tankkarten__r.isEmpty() && Integer.valueOf(this.sourceObject.get(this.opportunityMapping.Number_of_Cards__c)) < 3 &&
					this.sourceObject.Sec_Channel__c == 'Inbound' && this.sourceObject.get(this.opportunityMapping.Payment_Method__c) == 'Banküberweisung') {
				this.depositMonthlyPlus21 = 0;
			}
		} catch (Exception e) {
			System.debug('Credit Factory === ' + e.getMessage());
			throw new CreditFactoryException('Deposit Monthly + 21 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}
	}


	/*******************************************************************************
	*  Name 		   : getCreditLimitMonthlyPlus27()
	*  Summary         : Return Credit Limit Monthly Plus 27
	*  CreatedDate     : 10/10/2018
	*  ModifiedDate    : 29/11/2018
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public Decimal getCreditLimitMonthlyPlus27() {
		if (this.creditLimitMonthlyPlus27 != null) {
			if (this.creditLimitMonthlyPlus27 < 50) {
				this.creditLimitMonthlyPlus27 = this.creditLimitMonthlyPlus27 + 50;
			}
			
			this.creditLimitMonthlyPlus27 = (this.creditLimitMonthlyPlus27 / 100).round(System.RoundingMode.HALF_UP) * 100;
		}

		return this.creditLimitMonthlyPlus27;
	}


	/*******************************************************************************
	*  Name 		   : setCreditLimitMonthlyPlus27(Decimal buffer)
	*  Summary         : Calculate Credit Limit Monthly Plus 27
	*  CreatedDate     : 10/10/2018
	*  ModifiedDate    : -
	*  Parameters      : buffer - 0, 0.1, 0.2 or 0.3
	*  Returns         : void
	******************************************************************************/
	public void setCreditLimitMonthlyPlus27(Decimal buffer) {
		try {
			this.creditLimitMonthlyPlus27 = ((Decimal)this.sourceObject.get(this.opportunityMapping.Monthly_Volume_Currency__c) * 
				((30.0 + 27.0)/30.0)*(1.0 + buffer));
		} catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Credit Limit Monthly + 27 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}
	}


	/*******************************************************************************
	*  Name 		   : getMaxCreditLimitMonthlyPlus27()
	*  Summary         : Return Max Credit Limit Monthly Plus 27
	*  CreatedDate     : 10/10/2018
	*  ModifiedDate    : 29/11/2018
	*  Parameters      : -
	*  Returns         : Decimal
	******************************************************************************/
	public Decimal getMaxCreditLimitMonthlyPlus27() {
		if (this.maxCreditLimitMonthlyPlus27 != null) {
			this.maxCreditLimitMonthlyPlus27 = (this.maxCreditLimitMonthlyPlus27 / 100).round(System.RoundingMode.HALF_UP) * 100;
		}

		return this.maxCreditLimitMonthlyPlus27;
	}


	/*******************************************************************************
	*  Name            : setMaxCreditLimitMonthlyPlus21()
	*  Summary         : Calculate Max Credit Limit Monthly Plus 21 
	*  CreatedDate     : 10/10/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void setMaxCreditLimitMonthlyPlus27() {
		try {
			if (this.company.classRating == '1') {
				setMaxCreditLimitMonthlyPlus27Rating1();
		    } else if (this.company.classRating == '2') {
		    	setMaxCreditLimitMonthlyPlus27Rating2();
		    } else if (this.company.classRating == '3') {
		    	setMaxCreditLimitMonthlyPlus27Rating3();
		    } else if (this.company.classRating == '4') {
		    	setMaxCreditLimitMonthlyPlus27Rating4();
		    } else if (this.company.classRating == '5') {
		    	setMaxCreditLimitMonthlyPlus27Rating5();
		    } else if (this.company.classRating == '6') {
		    	setMaxCreditLimitMonthlyPlus27Rating6();
		    }
	    } catch (Exception e) {
	    	System.debug('Credit Factory === ' + e.getMessage());
	    	throw new CreditFactoryException('Max Credit Limit Monthly + 27 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
	    }
	}


	/*******************************************************************************
	*  Name            : setMaxCreditLimitMonthlyPlus27Rating1()
	*  Summary         : Calculate Max Credit Limit Monthly Plus 27 for Rating 1    
	*  CreatedDate     : 28/11/2018
	*  ModifiedDate    : 12/02/2019
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setMaxCreditLimitMonthlyPlus27Rating1() {
		Decimal nonFuelExposure = 0;
		if (this.sourceObject.Non_fuel_exposure__c != null) nonFuelExposure = this.sourceObject.Non_fuel_exposure__c;
		Decimal totalConsumption = this.sourceObject.Total_consumption_l_month__c;

        if (! String.isEmpty(this.company.dateoffoundation) &&
				Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(0, 4)), Integer.valueOf(this.company.dateoffoundation.substring(5, 7)), 
				Integer.valueOf(this.company.dateoffoundation.substring(8, 10))).monthsBetween(Date.today()) < 18) {
        	if (this.userSource == 'E2E Long Form' || this.sourceObject.Tankkarten__r.isEmpty()) {
	    		if (this.sourceObject.Total_consumption_l_month__c < 351 && this.sourceObject.Sec_Channel__c == 'Inbound' && 
	    				Integer.valueOf(this.sourceObject.get(this.opportunityMapping.Number_of_Cards__c)) < 3) {
	    			if (totalConsumption != null && totalConsumption != 0) {
		    			Decimal creditLimit350MonthlyPlus27 = (((Decimal)this.sourceObject.get(this.opportunityMapping.Monthly_Volume_Currency__c) - nonFuelExposure) / totalConsumption * 350 + 
							this.sourceObject.Non_fuel_exposure__c) * (30.0 + 27.0) / 30.0 * (1.0 + 0.1);
		    			if (this.creditLimitMonthlyPlus27 * 2 < creditLimit350MonthlyPlus27) {
							this.maxCreditLimitMonthlyPlus27 = this.creditLimitMonthlyPlus27 * 2;
						} else {
							this.maxCreditLimitMonthlyPlus27 = creditLimit350MonthlyPlus27;
						}
					} else {
						this.maxCreditLimitMonthlyPlus27 = 0;
					}
	    		} else if (this.company.paidUpShareCapital != null && this.sourceObject.Total_consumption_l_month__c <= 0.01 * Decimal.valueOf(this.company.paidUpShareCapital) &&
	    				Integer.valueOf(this.sourceObject.get(this.opportunityMapping.Number_of_Cards__c)) < 6) {
	    			if (totalConsumption != null && totalConsumption != 0) {
		    			Decimal creditLimitBasedOnCapital = (((Decimal)this.sourceObject.get(this.opportunityMapping.Monthly_Volume_Currency__c) - nonFuelExposure) / totalConsumption * 
		    				(0.01 * Decimal.valueOf(this.company.paidUpShareCapital) + this.sourceObject.Non_fuel_exposure__c) * ((30.0 + 27.0)/30.0)*(1.0 + 0.1));
		    			if (this.creditLimitMonthlyPlus27 * 2 < creditLimitBasedOnCapital) {
		    				if (this.creditLimitMonthlyPlus27 * 2 < 10000) {
				    			this.maxCreditLimitMonthlyPlus27 = this.creditLimitMonthlyPlus27 * 2;
				    		} else {
				    			this.maxCreditLimitMonthlyPlus27 = 10000;
				    		}
						} else {
							if (creditLimitBasedOnCapital < 10000) {
				    			this.maxCreditLimitMonthlyPlus27 = creditLimitBasedOnCapital;
				    		} else {
				    			this.maxCreditLimitMonthlyPlus27 = 10000;
				    		}
						}
					} else {
						this.maxCreditLimitMonthlyPlus27 = 0;
					}
	    		} else {
		    		this.maxCreditLimitMonthlyPlus27 = 0;
		    	}
	    	} else {
	    		this.maxCreditLimitMonthlyPlus27 = 0;
	    	}
        } else {
        	if (this.creditLimitMonthlyPlus27 * 2 < 10000) {
				this.maxCreditLimitMonthlyPlus27 = this.creditLimitMonthlyPlus27 * 2;
			} else {
				this.maxCreditLimitMonthlyPlus27 = 10000;
			}
        }
	}


	/*******************************************************************************
	*  Name            : setMaxCreditLimitMonthlyPlus27Rating2()
	*  Summary         : Calculate Max Credit Limit Monthly Plus 27 for Rating 2
	*  CreatedDate     : 28/11/2018
	*  ModifiedDate    : 12/02/2019
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setMaxCreditLimitMonthlyPlus27Rating2() {
		Decimal nonFuelExposure = 0;
		if (this.sourceObject.Non_fuel_exposure__c != null) nonFuelExposure = this.sourceObject.Non_fuel_exposure__c;
		Decimal totalConsumption = this.sourceObject.Total_consumption_l_month__c;

        if (! String.isEmpty(this.company.dateoffoundation) &&
				Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(0, 4)), Integer.valueOf(this.company.dateoffoundation.substring(5, 7)), 
				Integer.valueOf(this.company.dateoffoundation.substring(8, 10))).monthsBetween(Date.today()) < 18) {
        	if (this.userSource == 'E2E Long Form' || this.sourceObject.Tankkarten__r.isEmpty()) {
	    		if (this.sourceObject.Total_consumption_l_month__c < 351 && this.sourceObject.Sec_Channel__c == 'Inbound' && 
	    				Integer.valueOf(this.sourceObject.get(this.opportunityMapping.Number_of_Cards__c)) < 3) {
	    			if (totalConsumption != null && totalConsumption != 0) {
		    			Decimal creditLimit350MonthlyPlus27 = (((Decimal)this.sourceObject.get(this.opportunityMapping.Monthly_Volume_Currency__c) - nonFuelExposure) / totalConsumption * 350 + 
							this.sourceObject.Non_fuel_exposure__c) * (30.0 + 27.0) / 30.0 * (1.0 + 0.1);
		    			if (this.creditLimitMonthlyPlus27 * 2 < creditLimit350MonthlyPlus27) {
							this.maxCreditLimitMonthlyPlus27 = this.creditLimitMonthlyPlus27 * 2;
						} else {
							this.maxCreditLimitMonthlyPlus27 = creditLimit350MonthlyPlus27;
						}
					} else {
						this.maxCreditLimitMonthlyPlus27 = 0;
					}
	    		} else if (this.company.paidUpShareCapital != null && this.sourceObject.Total_consumption_l_month__c <= 0.01 * Decimal.valueOf(this.company.paidUpShareCapital) &&
	    				Integer.valueOf(this.sourceObject.get(this.opportunityMapping.Number_of_Cards__c)) < 6) {
	    			if (totalConsumption != null && totalConsumption != 0) {
		    			Decimal creditLimitBasedOnCapital = (((Decimal)this.sourceObject.get(this.opportunityMapping.Monthly_Volume_Currency__c) - nonFuelExposure) / totalConsumption * 
		    				(0.01 * Decimal.valueOf(this.company.paidUpShareCapital) + this.sourceObject.Non_fuel_exposure__c) * ((30.0 + 27.0)/30.0)*(1.0 + 0.1));
		    			if (this.creditLimitMonthlyPlus27 * 2 < creditLimitBasedOnCapital) {
		    				if (this.creditLimitMonthlyPlus27 * 2 < 10000) {
				    			this.maxCreditLimitMonthlyPlus27 = this.creditLimitMonthlyPlus27 * 2;
				    		} else {
				    			this.maxCreditLimitMonthlyPlus27 = 10000;
				    		}
						} else {
							if (creditLimitBasedOnCapital < 10000) {
				    			this.maxCreditLimitMonthlyPlus27 = creditLimitBasedOnCapital;
				    		} else {
				    			this.maxCreditLimitMonthlyPlus27 = 10000;
				    		}
						}
					} else {
						this.maxCreditLimitMonthlyPlus27 = 0;
					}
	    		} else {
		    		this.maxCreditLimitMonthlyPlus27 = 0;
		    	}
	    	} else {
	    		this.maxCreditLimitMonthlyPlus27 = 0;
	    	}
        } else {
        	if (this.creditLimitMonthlyPlus27 * 2 < 10000) {
				this.maxCreditLimitMonthlyPlus27 = this.creditLimitMonthlyPlus27 * 2;
			} else {
				this.maxCreditLimitMonthlyPlus27 = 10000;
			}
        }
	}


	/*******************************************************************************
	*  Name            : setMaxCreditLimitMonthlyPlus27Rating3()
	*  Summary         : Calculate Max Credit Limit Monthly Plus 27 for Rating 3
	*  CreatedDate     : 28/11/2018
	*  ModifiedDate    : 12/02/2019
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setMaxCreditLimitMonthlyPlus27Rating3() {
		Decimal nonFuelExposure = 0;
		if (this.sourceObject.Non_fuel_exposure__c != null) nonFuelExposure = this.sourceObject.Non_fuel_exposure__c;
		Decimal totalConsumption = this.sourceObject.Total_consumption_l_month__c;

        if (! String.isEmpty(this.company.dateoffoundation) &&
				Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(0, 4)), Integer.valueOf(this.company.dateoffoundation.substring(5, 7)), 
				Integer.valueOf(this.company.dateoffoundation.substring(8, 10))).monthsBetween(Date.today()) < 18) {
        	if (this.userSource == 'E2E Long Form' || this.sourceObject.Tankkarten__r.isEmpty()) {
	    		if (this.sourceObject.Total_consumption_l_month__c < 351 && this.sourceObject.Sec_Channel__c == 'Inbound' && 
	    				Integer.valueOf(this.sourceObject.get(this.opportunityMapping.Number_of_Cards__c)) < 3) {
	    			if (totalConsumption != null && totalConsumption != 0) {
		    			Decimal creditLimit350MonthlyPlus27 = (((Decimal)this.sourceObject.get(this.opportunityMapping.Monthly_Volume_Currency__c) - nonFuelExposure) / totalConsumption * 350 + 
							this.sourceObject.Non_fuel_exposure__c) * (30.0 + 27.0) / 30.0 * (1.0 + 0.1);
		    			if (this.creditLimitMonthlyPlus27 * 2 < creditLimit350MonthlyPlus27) {
							this.maxCreditLimitMonthlyPlus27 = this.creditLimitMonthlyPlus27 * 2;
						} else {
							this.maxCreditLimitMonthlyPlus27 = creditLimit350MonthlyPlus27;
						}
					} else {
						this.maxCreditLimitMonthlyPlus27 = 0;
					}
	    		} else if (this.company.paidUpShareCapital != null && this.sourceObject.Total_consumption_l_month__c <= 0.01 * Decimal.valueOf(this.company.paidUpShareCapital) &&
	    				Integer.valueOf(this.sourceObject.get(this.opportunityMapping.Number_of_Cards__c)) < 6) {
	    			if (totalConsumption != null && totalConsumption != 0) {
		    			Decimal creditLimitBasedOnCapital = (((Decimal)this.sourceObject.get(this.opportunityMapping.Monthly_Volume_Currency__c) - nonFuelExposure) / totalConsumption * 
		    				(0.01 * Decimal.valueOf(this.company.paidUpShareCapital) + this.sourceObject.Non_fuel_exposure__c) * ((30.0 + 27.0)/30.0)*(1.0 + 0.1));
		    			if (this.creditLimitMonthlyPlus27 * 2 < creditLimitBasedOnCapital) {
		    				if (this.creditLimitMonthlyPlus27 * 2 < 10000) {
				    			this.maxCreditLimitMonthlyPlus27 = this.creditLimitMonthlyPlus27 * 2;
				    		} else {
				    			this.maxCreditLimitMonthlyPlus27 = 10000;
				    		}
						} else {
							if (creditLimitBasedOnCapital < 10000) {
				    			this.maxCreditLimitMonthlyPlus27 = creditLimitBasedOnCapital;
				    		} else {
				    			this.maxCreditLimitMonthlyPlus27 = 10000;
				    		}
						}
					} else {
						this.maxCreditLimitMonthlyPlus27 = 0;
					}
	    		} else {
		    		this.maxCreditLimitMonthlyPlus27 = 0;
		    	}
	    	} else {
	    		this.maxCreditLimitMonthlyPlus27 = 0;
	    	}
        } else {
        	if (this.creditLimitMonthlyPlus27 * 2 < 10000) {
				this.maxCreditLimitMonthlyPlus27 = this.creditLimitMonthlyPlus27 * 2;
			} else {
				this.maxCreditLimitMonthlyPlus27 = 10000;
			}
        }
	}


	/*******************************************************************************
	*  Name            : setMaxCreditLimitMonthlyPlus27Rating4()
	*  Summary         : Calculate Max Credit Limit Monthly Plus 27 for Rating 4
	*  CreatedDate     : 28/11/2018
	*  ModifiedDate    : 12/02/2019
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setMaxCreditLimitMonthlyPlus27Rating4() {
		Decimal recommendedCreditLimit = 0;
		if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
            recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
        }
        Decimal nonFuelExposure = 0;
		if (this.sourceObject.Non_fuel_exposure__c != null) nonFuelExposure = this.sourceObject.Non_fuel_exposure__c;
		Decimal totalConsumption = this.sourceObject.Total_consumption_l_month__c;
		
        if (! String.isEmpty(this.company.dateoffoundation) &&
				Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(0, 4)), Integer.valueOf(this.company.dateoffoundation.substring(5, 7)), 
				Integer.valueOf(this.company.dateoffoundation.substring(8, 10))).monthsBetween(Date.today()) < 18) {
        	if (this.userSource == 'E2E Long Form' || this.sourceObject.Tankkarten__r.isEmpty()) {
	    		if (this.sourceObject.Total_consumption_l_month__c < 351 && this.sourceObject.Sec_Channel__c == 'Inbound' && 
	    				Integer.valueOf(this.sourceObject.get(this.opportunityMapping.Number_of_Cards__c)) < 3) {
	    			if (totalConsumption != null && totalConsumption != 0) {
		    			Decimal creditLimit350MonthlyPlus27 = (((Decimal)this.sourceObject.get(this.opportunityMapping.Monthly_Volume_Currency__c) - nonFuelExposure) / totalConsumption * 350 + 
							this.sourceObject.Non_fuel_exposure__c) * (30.0 + 27.0) / 30.0 * (1.0 + 0.1);
		    			if (this.creditLimitMonthlyPlus27 * 2 < creditLimit350MonthlyPlus27) {
							this.maxCreditLimitMonthlyPlus27 = this.creditLimitMonthlyPlus27 * 2;
						} else {
							this.maxCreditLimitMonthlyPlus27 = creditLimit350MonthlyPlus27;
						}
					} else {
						this.maxCreditLimitMonthlyPlus27 = 0;
					}
	    		} else if (this.company.paidUpShareCapital != null && this.sourceObject.Total_consumption_l_month__c <= 0.01 * Decimal.valueOf(this.company.paidUpShareCapital) &&
	    				Integer.valueOf(this.sourceObject.get(this.opportunityMapping.Number_of_Cards__c)) < 6) {
	    			if (totalConsumption != null && totalConsumption != 0) {
		    			Decimal creditLimitBasedOnCapital = (((Decimal)this.sourceObject.get(this.opportunityMapping.Monthly_Volume_Currency__c) - nonFuelExposure) / totalConsumption * 
		    				(0.01 * Decimal.valueOf(this.company.paidUpShareCapital) + this.sourceObject.Non_fuel_exposure__c) * ((30.0 + 27.0)/30.0)*(1.0 + 0.1));
		    			if (this.creditLimitMonthlyPlus27 * 2 < creditLimitBasedOnCapital) {
		    				if (this.creditLimitMonthlyPlus27 * 2 < 10000) {
				    			this.maxCreditLimitMonthlyPlus27 = this.creditLimitMonthlyPlus27 * 2;
				    		} else {
				    			this.maxCreditLimitMonthlyPlus27 = 10000;
				    		}
						} else {
							if (creditLimitBasedOnCapital < 10000) {
				    			this.maxCreditLimitMonthlyPlus27 = creditLimitBasedOnCapital;
				    		} else {
				    			this.maxCreditLimitMonthlyPlus27 = 10000;
				    		}
						}
					} else {
						this.maxCreditLimitMonthlyPlus27 = 0;
					}
	    		} else {
	    			this.maxCreditLimitMonthlyPlus27 = 0;
	    		}
	    	} else {
	    		this.maxCreditLimitMonthlyPlus27 = 0;
	    	}
        } else {
        	if (recommendedCreditLimit * 2 > this.creditLimitMonthlyPlus27 * 2) {
	    		if (this.creditLimitMonthlyPlus27 * 2 < 10000) {
	    			this.maxCreditLimitMonthlyPlus27 = this.creditLimitMonthlyPlus27 * 2;
	    		} else {
	    			this.maxCreditLimitMonthlyPlus27 = 10000;
	    		}
	    	} else {
	    		if (recommendedCreditLimit * 2 < 10000) {
	    			this.maxCreditLimitMonthlyPlus27 = recommendedCreditLimit * 2;
	    		} else {
	    			this.maxCreditLimitMonthlyPlus27 = 10000;
	    		}
	    	}
        }
	}


	/*******************************************************************************
	*  Name            : setMaxCreditLimitMonthlyPlus27Rating5()
	*  Summary         : Calculate Max Credit Limit Monthly Plus 27 for Rating 5    
	*  CreatedDate     : 21/01/2019
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setMaxCreditLimitMonthlyPlus27Rating5() {
		this.maxCreditLimitMonthlyPlus27 = 0;
	}


	/*******************************************************************************
	*  Name            : setMaxCreditLimitMonthlyPlus27Rating6()
	*  Summary         : Calculate Max Credit Limit Monthly Plus 27 for Rating 6
	*  CreatedDate     : 21/01/2019
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setMaxCreditLimitMonthlyPlus27Rating6() {
		this.maxCreditLimitMonthlyPlus27 = 0;
	}


	/*******************************************************************************
	*  Name            : getMaxValueMonthlyPlus27
	*  Summary         : Return Max value of Credit Limit including deposit Monthly Plus 27    
	*  CreatedDate     : 21/01/2019
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : Decimal
	******************************************************************************/
	public Decimal getMaxValueMonthlyPlus27() {
	    if (this.maxValueMonthlyPlus27 != null) {
			this.maxValueMonthlyPlus27 = (this.maxValueMonthlyPlus27 / 100).round(System.RoundingMode.HALF_UP) * 100;
		}

		return this.maxValueMonthlyPlus27;
	}


	/*******************************************************************************
	*  Name            : setMaxValueMonthlyPlus27()
	*  Summary         : Calculate Max value of Credit Limit including deposit Monthly Plus 27    
	*  CreatedDate     : 21/01/2019
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void setMaxValueMonthlyPlus27() {
		try {
		    if (this.creditLimitMonthlyPlus27 * 2 < 10000) {
		    	this.maxValueMonthlyPlus27 = this.creditLimitMonthlyPlus27 * 2;
		    } else {
		    	this.maxValueMonthlyPlus27 = 10000;
		    }
		} catch (Exception e) {
		    System.debug('Credit Factory === ' + e.getMessage());
	    	throw new CreditFactoryException('Max Value Weekly + 7 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}
	}


	/*******************************************************************************
	*  Name            : getDepositMonthlyPlus27()
	*  Summary         : Return Deposit Monthly Plus 27
	*  CreatedDate     : 10/10/2018
	*  ModifiedDate    : 29/11/2018
	*  Parameters      : -
	*  Returns         : Decimal
	******************************************************************************/
	public Decimal getDepositMonthlyPlus27() {
		if (this.depositMonthlyPlus27 != null) {
			if (this.depositMonthlyPlus27 > 0 && this.depositMonthlyPlus27 < 50) {
				this.depositMonthlyPlus27 = this.depositMonthlyPlus27 + 50;
			}

			this.depositMonthlyPlus27 = (this.depositMonthlyPlus27 / 100).round(System.RoundingMode.HALF_UP) * 100;
		}

		return this.depositMonthlyPlus27;
	}


	/*******************************************************************************
	*  Name            : setDepositMonthlyPlus27()
	*  Summary         : Calculate Deposit Monthly Plus 27
	*  CreatedDate     : 10/10/2018
	*  ModifiedDate    : 28/11/2018
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void setDepositMonthlyPlus27() {
		try {
			if (this.company.classRating == '1') {
				setDepositMonthlyPlus27Rating1();
			} else if (this.company.classRating == '2') {
				setDepositMonthlyPlus27Rating2();
			} else if (this.company.classRating == '3') {
				setDepositMonthlyPlus27Rating3();
			} else if (this.company.classRating == '4') {
				setDepositMonthlyPlus27Rating4();
			} else if (this.company.classRating == '5') {
				setDepositMonthlyPlus27Rating5();
			} else if (this.company.classRating == '6') {
				setDepositMonthlyPlus27Rating6();
			}
		} catch (Exception e) {
			System.debug('Credit Factory === ' + e.getMessage());
			throw new CreditFactoryException('Deposit Monthly + 27 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}
	}


	/*******************************************************************************
	*  Name            : setDepositMonthlyPlus27Rating1()
	*  Summary         : Calculate Deposit Monthly Plus 27 for Rating 1    
	*  CreatedDate     : 28/11/2018
	*  ModifiedDate    : 01/02/2019
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setDepositMonthlyPlus27Rating1() {
		if (! String.isEmpty(this.company.dateoffoundation) &&
				Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(0, 4)), Integer.valueOf(this.company.dateoffoundation.substring(5, 7)), 
				Integer.valueOf(this.company.dateoffoundation.substring(8, 10))).monthsBetween(Date.today()) < 18) {
			if ((this.userSource == 'E2E Long Form' || this.sourceObject.Tankkarten__r.isEmpty()) && (
					Integer.valueOf(this.sourceObject.get(this.opportunityMapping.Number_of_Cards__c)) < 3 && this.sourceObject.Total_consumption_l_month__c < 351 && 
					this.sourceObject.Sec_Channel__c == 'Inbound' || this.company.paidUpShareCapital != null && Integer.valueOf(this.sourceObject.get(this.opportunityMapping.Number_of_Cards__c)) < 6 &&
					this.sourceObject.Total_consumption_l_month__c <= 0.01 * Decimal.valueOf(this.company.paidUpShareCapital) &&
					this.creditLimitMonthlyPlus27 <= this.maxCreditLimitMonthlyPlus27 && this.maxCreditLimitMonthlyPlus27 > 0)) {
				this.depositMonthlyPlus27 = 0;
			} else {
				this.depositMonthlyPlus27 = this.creditLimitMonthlyPlus27 * 0.33;
			}
		} else {
			this.depositMonthlyPlus27 = 0;
		}
	}


	/*******************************************************************************
	*  Name            : setDepositMonthlyPlus27Rating2()
	*  Summary         : Calculate Deposit Monthly Plus 27 for Rating 2 
	*  CreatedDate     : 28/11/2018
	*  ModifiedDate    : 01/02/2019
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setDepositMonthlyPlus27Rating2() {
		if (! String.isEmpty(this.company.dateoffoundation) &&
				Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(0, 4)), Integer.valueOf(this.company.dateoffoundation.substring(5, 7)), 
				Integer.valueOf(this.company.dateoffoundation.substring(8, 10))).monthsBetween(Date.today()) < 18) {
			if ((this.userSource == 'E2E Long Form' || this.sourceObject.Tankkarten__r.isEmpty()) && (
					Integer.valueOf(this.sourceObject.get(this.opportunityMapping.Number_of_Cards__c)) < 3 && this.sourceObject.Total_consumption_l_month__c < 351 && 
					this.sourceObject.Sec_Channel__c == 'Inbound' || this.company.paidUpShareCapital != null && Integer.valueOf(this.sourceObject.get(this.opportunityMapping.Number_of_Cards__c)) < 6 &&
					this.sourceObject.Total_consumption_l_month__c <= 0.01 * Decimal.valueOf(this.company.paidUpShareCapital) &&
					this.creditLimitMonthlyPlus27 <= this.maxCreditLimitMonthlyPlus27 && this.maxCreditLimitMonthlyPlus27 > 0)) {
				this.depositMonthlyPlus27 = 0;
			} else {
				this.depositMonthlyPlus27 = this.creditLimitMonthlyPlus27 * 0.33;
			}
		} else {
			this.depositMonthlyPlus27 = 0;
		}
	}


	/*******************************************************************************
	*  Name            : setDepositMonthlyPlus27Rating3()
	*  Summary         : Calculate Deposit Monthly Plus 27 for Rating 3
	*  CreatedDate     : 28/11/2018
	*  ModifiedDate    : 01/02/2019
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setDepositMonthlyPlus27Rating3() {
		if (! String.isEmpty(this.company.dateoffoundation) &&
				Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(0, 4)), Integer.valueOf(this.company.dateoffoundation.substring(5, 7)), 
				Integer.valueOf(this.company.dateoffoundation.substring(8, 10))).monthsBetween(Date.today()) < 18) {
			if ((this.userSource == 'E2E Long Form' || this.sourceObject.Tankkarten__r.isEmpty()) && (
					Integer.valueOf(this.sourceObject.get(this.opportunityMapping.Number_of_Cards__c)) < 3 && this.sourceObject.Total_consumption_l_month__c < 351 && 
					this.sourceObject.Sec_Channel__c == 'Inbound' || this.company.paidUpShareCapital != null && Integer.valueOf(this.sourceObject.get(this.opportunityMapping.Number_of_Cards__c)) < 6 &&
					this.sourceObject.Total_consumption_l_month__c <= 0.01 * Decimal.valueOf(this.company.paidUpShareCapital) &&
					this.creditLimitMonthlyPlus27 <= this.maxCreditLimitMonthlyPlus27 && this.maxCreditLimitMonthlyPlus27 > 0)) {
				this.depositMonthlyPlus27 = 0;
			} else {
				this.depositMonthlyPlus27 = this.creditLimitMonthlyPlus27 * 0.33;
			}
		} else {
			this.depositMonthlyPlus27 = 0;
		}
	}


	/*******************************************************************************
	*  Name            : setDepositMonthlyPlus27Rating4()
	*  Summary         : Calculate Deposit Monthly Plus 27 for Rating 4
	*  CreatedDate     : 10/10/2018
	*  ModifiedDate    : 14/11/2018
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setDepositMonthlyPlus27Rating4() {
		if (! String.isEmpty(this.company.dateoffoundation) &&
				Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(0, 4)), Integer.valueOf(this.company.dateoffoundation.substring(5, 7)), 
				Integer.valueOf(this.company.dateoffoundation.substring(8, 10))).monthsBetween(Date.today()) < 18) {
			if ((this.userSource == 'E2E Long Form' || this.sourceObject.Tankkarten__r.isEmpty()) && (
					Integer.valueOf(this.sourceObject.get(this.opportunityMapping.Number_of_Cards__c)) < 3 && this.sourceObject.Total_consumption_l_month__c < 351 && 
					this.sourceObject.Sec_Channel__c == 'Inbound' || this.company.paidUpShareCapital != null && Integer.valueOf(this.sourceObject.get(this.opportunityMapping.Number_of_Cards__c)) < 6 &&
					this.sourceObject.Total_consumption_l_month__c <= 0.01 * Decimal.valueOf(this.company.paidUpShareCapital) &&
					this.creditLimitMonthlyPlus27 <= this.maxCreditLimitMonthlyPlus27 && this.maxCreditLimitMonthlyPlus27 > 0)) {
				this.depositMonthlyPlus27 = 0;
			} else {
				this.depositMonthlyPlus27 = this.creditLimitMonthlyPlus27 * 0.33;
			}
		} else {
			Decimal recommendedCreditLimit = 0;
			if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
	            recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
	        }
			if (this.creditLimitMonthlyPlus27 <= this.maxCreditLimitMonthlyPlus27 && this.maxCreditLimitMonthlyPlus27 > 0) {
				this.depositMonthlyPlus27 = 0;
			} else {
				this.depositMonthlyPlus27 = (this.creditLimitMonthlyPlus27 - recommendedCreditLimit);
			}
		}
	}


	/*******************************************************************************
	*  Name            : setDepositMonthlyPlus27Rating5()
	*  Summary         : Calculate Deposit Monthly Plus 27 for Rating 5
	*  CreatedDate     : 10/10/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setDepositMonthlyPlus27Rating5() {
		this.depositMonthlyPlus27 = this.creditLimitMonthlyPlus27 * 0.7;
	}


	/*******************************************************************************
	*  Name            : setDepositMonthlyPlus27Rating6()
	*  Summary         : Calculate Deposit Monthly Plus 27 for Rating 6
	*  CreatedDate     : 10/10/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setDepositMonthlyPlus27Rating6() {
		this.depositMonthlyPlus27 = this.creditLimitMonthlyPlus27 * (7.0 + 7.0 + 10.0) / (7.0 + 7.0);
	}


	/*******************************************************************************
	*  Name            : setPaymentDetails()
	*  Summary         : Calculate payment details such as billing period, payment terms, max credit limit and deposit    
	*  CreatedDate     : 10/10/2018
	*  ModifiedDate    : 28/11/2018
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void setPaymentDetails() {
		if (this.company.classRating == '1') {
			setPaymentDetailsRating1();
		} else if (this.company.classRating == '2') {
			setPaymentDetailsRating2();
		} else if (this.company.classRating == '3') {
			setPaymentDetailsRating3();
		} else if (this.company.classRating == '4') {
			setPaymentDetailsRating4();
		} else if (this.company.classRating == '5') {
			setPaymentDetailsRating5();
		} else if (this.company.classRating == '6') {
			setPaymentDetailsRating6();
		}
	}


	/*******************************************************************************
	*  Name            : setPaymentDetailsRating1()
	*  Summary         : Calculate payment details (billing period, payment terms) for rating 1
	*  CreatedDate     : 28/11/2018
	*  ModifiedDate    : 31/01/2019
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setPaymentDetailsRating1() {
		try {
            if (this.creditLimitMonthlyPlus7 <= 10000 && this.depositMonthlyPlus7 == 0 && this.userSource != 'E2E Long Form') {
        		this.billingPeriod = 30;
        		this.paymentTerms = 7;
            } else if (this.creditLimitMonthlyPlus14 <= 10000 && this.depositMonthlyPlus14 == 0 && this.userSource != 'E2E Long Form') {
            	this.billingPeriod = 30;
        		this.paymentTerms = 14;
            } else if (this.creditLimitMonthlyPlus21 <= 10000 && this.depositMonthlyPlus21 == 0 && this.userSource != 'E2E Long Form') {
                this.billingPeriod = 30;
                this.paymentTerms = 21;
            } else if (this.creditLimitMonthlyPlus27 <= 10000 && this.depositMonthlyPlus27 == 0) {
            	this.billingPeriod = 30;
                this.paymentTerms = 27;
            } else if (this.creditLimitMonthlyPlus27 <= 10000) {
            	this.billingPeriod = 30;
            	this.paymentTerms = 27;
            }
		} catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Billing Period for Rating 1 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}
	}


	/*******************************************************************************
	*  Name            : setPaymentDetailsRating2()
	*  Summary         : Calculate payment details (billing period, payment terms) for rating 2
	*  CreatedDate     : 28/11/2018
	*  ModifiedDate    : 31/01/2019
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setPaymentDetailsRating2() {
		try {
            if (this.creditLimitMonthlyPlus7 <= 10000 && this.depositMonthlyPlus7 == 0 && this.userSource != 'E2E Long Form') {
        		this.billingPeriod = 30;
        		this.paymentTerms = 7;
            } else if (this.creditLimitMonthlyPlus14 <= 10000 && this.depositMonthlyPlus14 == 0 && this.userSource != 'E2E Long Form') {
            	this.billingPeriod = 30;
        		this.paymentTerms = 14;
            } else if (this.creditLimitMonthlyPlus21 <= 10000 && this.depositMonthlyPlus21 == 0 && this.userSource != 'E2E Long Form') {
                this.billingPeriod = 30;
                this.paymentTerms = 21;
            } else if (this.creditLimitMonthlyPlus27 <= 10000 && this.depositMonthlyPlus27 == 0) {
            	this.billingPeriod = 30;
                this.paymentTerms = 27;
            } else if (this.creditLimitMonthlyPlus27 <= 10000) {
            	this.billingPeriod = 30;
            	this.paymentTerms = 27;
            }
		} catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Billing Period for Rating 2 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}
	}


	/*******************************************************************************
	*  Name            : setPaymentDetailsRating3()
	*  Summary         : Calculate payment details (billing period, payment terms) for rating 3
	*  CreatedDate     : 28/11/2018
	*  ModifiedDate    : 31/01/2019
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setPaymentDetailsRating3() {
		try {
            if (this.creditLimitMonthlyPlus7 <= 10000 && this.depositMonthlyPlus7 == 0 && this.userSource != 'E2E Long Form') {
        		this.billingPeriod = 30;
        		this.paymentTerms = 7;
            } else if (this.creditLimitMonthlyPlus14 <= 10000 && this.depositMonthlyPlus14 == 0 && this.userSource != 'E2E Long Form') {
            	this.billingPeriod = 30;
        		this.paymentTerms = 14;
            } else if (this.creditLimitMonthlyPlus21 <= 10000 && this.depositMonthlyPlus21 == 0 && this.userSource != 'E2E Long Form') {
                this.billingPeriod = 30;
                this.paymentTerms = 21;
            } else if (this.creditLimitMonthlyPlus27 <= 10000 && this.depositMonthlyPlus27 == 0) {
            	this.billingPeriod = 30;
                this.paymentTerms = 27;
            } else if (this.creditLimitMonthlyPlus27 <= 10000) {
            	this.billingPeriod = 30;
            	this.paymentTerms = 27;
            }
		} catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Billing Period for Rating 3 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}
	}


	/*******************************************************************************
	*  Name            : setPaymentDetailsRating4()
	*  Summary         : Calculate payment details (billing period, payment terms) for rating 4
	*  CreatedDate     : 10/10/2018
	*  ModifiedDate    : 21/01/2019
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setPaymentDetailsRating4() {
		try {
            if (this.creditLimitMonthlyPlus7 <= 10000 && this.depositMonthlyPlus7 == 0 && this.userSource != 'E2E Long Form') {
        		this.billingPeriod = 30;
        		this.paymentTerms = 7;
            } else if (this.creditLimitMonthlyPlus14 <= 10000 && this.depositMonthlyPlus14 == 0 && this.userSource != 'E2E Long Form') {
            	this.billingPeriod = 30;
        		this.paymentTerms = 14;
            } else if (this.creditLimitMonthlyPlus21 <= 10000 && this.depositMonthlyPlus21 == 0 && this.userSource != 'E2E Long Form') {
                this.billingPeriod = 30;
                this.paymentTerms = 21;
            } else if (this.creditLimitMonthlyPlus27 <= 10000 && this.depositMonthlyPlus27 == 0) {
            	this.billingPeriod = 30;
                this.paymentTerms = 27;
            } else if (this.creditLimitMonthlyPlus27 <= 10000) {
            	this.billingPeriod = 30;
            	this.paymentTerms = 27;
            }
		} catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Billing Period for Rating 4 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}
	}


	/*******************************************************************************
	*  Name            : setPaymentDetailsRating5()
	*  Summary         : Calculate payment details (billing period, payment terms) for rating 5
	*  CreatedDate     : 10/10/2018
	*  ModifiedDate    : 28/11/2018
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setPaymentDetailsRating5() {
		if (this.creditLimitMonthlyPlus27 <= 10000) {
        	this.billingPeriod = 30;
        	this.paymentTerms = 27;
        }
	}


	/*******************************************************************************
	*  Name            : setPaymentDetailsRating6()
	*  Summary         : Calculate payment details (billing period, payment terms) for rating 6
	*  CreatedDate     : 10/10/2018
	*  ModifiedDate    : 28/11/2018
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setPaymentDetailsRating6() {
		if (this.creditLimitMonthlyPlus27 <= 10000) {
        	this.billingPeriod = 30;
        	this.paymentTerms = 27;
        }
	}


	/*******************************************************************************
	*  Name 		   : getBillingPeriod
	*  Summary         : Return billing period
	*  CreatedDate     : 23/08/2018
	*  ModifiedDate    : -
	*  Parameters      : 
	*  Returns         : Integer
	******************************************************************************/
	public Integer getBillingPeriod() {
		return this.billingPeriod;
	}


	/*******************************************************************************
	*  Name            : getPaymentTerms()
	*  Summary         : Return payment terms.  
	*  CreatedDate     : 23/08/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : Integer
	******************************************************************************/
	public Integer getPaymentTerms() {
		return this.paymentTerms;
	}


	/*******************************************************************************
	*  Name            : setCreditLimit()
	*  Summary         : Calculate Credit Limit    
	*  CreatedDate     : 23/08/2018
	*  ModifiedDate    : 10/10/2018
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void setCreditLimit() {
		try {
		    if (this.billingPeriod == 30 && this.paymentTerms == 7) {
		    	this.creditLimit = getCreditLimitMonthlyPlus7();
		    } else if (this.billingPeriod == 30 && this.paymentTerms == 14) {
		    	this.creditLimit = getCreditLimitMonthlyPlus14();
		    } else if (this.billingPeriod == 30 && this.paymentTerms == 21) {
		    	this.creditLimit = getCreditLimitMonthlyPlus21();
		    } else if (this.billingPeriod == 30 && this.paymentTerms == 27) {
		    	this.creditLimit = getCreditLimitMonthlyPlus27();
		    }
		} catch (Exception e) {
		    System.debug('DEBUG: Credit Factory === ' + e.getMessage());
		    throw new CreditFactoryException('Credit Limit calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}
	}


	/*******************************************************************************
	*  Name            : getCreditLimit()
	*  Summary         : Return Credit Limit    
	*  CreatedDate     : 23/08/2018
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
	*  CreatedDate     : 23/08/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void setMaxCreditLimit() {
		try {
			if (this.billingPeriod == 30 && this.paymentTerms == 7) {
				this.maxCreditLimit = getMaxCreditLimitMonthlyPlus7();
			} else if (this.billingPeriod == 30 && this.paymentTerms == 14) {
				this.maxCreditLimit = getMaxCreditLimitMonthlyPlus14();
			} else if (this.billingPeriod == 30 && this.paymentTerms == 21) {
				this.maxCreditLimit = getMaxCreditLimitMonthlyPlus21();
			} else if (this.billingPeriod == 30 && this.paymentTerms == 27) {
				this.maxCreditLimit = getMaxCreditLimitMonthlyPlus27();
			}
		} catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Max Credit Limit calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}
	}


	/*******************************************************************************
	*  Name            : getMaxCreditLimit()
	*  Summary         : Return max credit limit.
	*  CreatedDate     : 23/08/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : Decimal
	******************************************************************************/
	public Decimal getMaxCreditLimit() {
		return this.maxCreditLimit;
	}


	/*******************************************************************************
	*  Name            : setMaxValue()
	*  Summary         : Calculate Max value of Credit Limit including deposit    
	*  CreatedDate     : 21/01/2019
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : Decimal
	******************************************************************************/
	public void setMaxValue() {
		if (this.billingPeriod == 30 && this.paymentTerms == 27) {
			this.maxValue = this.maxValueMonthlyPlus27;
		}
	}


	/*******************************************************************************
	*  Name            : getMaxValue()
	*  Summary         : Return Max value of Credit Limit including deposit    
	*  CreatedDate     : 21/01/2019
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
	*  CreatedDate     : 10/10/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void setDeposit() {
		try {
            if (this.billingPeriod == 30 && this.paymentTerms == 7) {
            	this.deposit = getDepositMonthlyPlus7();
			} else if (this.billingPeriod == 30 && this.paymentTerms == 14) {
				this.deposit = getDepositMonthlyPlus14(); 
			} else if (this.billingPeriod == 30 && this.paymentTerms == 21) {
				this.deposit = getDepositMonthlyPlus21();
			} else if (this.billingPeriod == 30 && this.paymentTerms == 27) {
				this.deposit = getDepositMonthlyPlus27();
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
	*  CreatedDate     : 21/09/2019
	*  ModifiedDate    : -
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
	                SELECT Credit_Limit_Monthly_27__c, Deposit_Monthly_27__c
	                FROM Credit_Factory_Report__c
	                WHERE Opportunity__c = :opportunityId AND CreatedDate > :Date.today().addMonths(-3)
	                ORDER BY CreatedDate DESC
	                LIMIT 1];
	        if (! creditReportsList.isEmpty() && creditLimit == creditReportsList.get(0).Credit_Limit_Monthly_27__c) {
	        	this.deposit = creditReportsList.get(0).Deposit_Monthly_27__c;
	        } else if (company.classRating == '1') {
	        	this.deposit = resetDepositRating1(creditLimit, maxCreditLimit, company);
			} else if (company.classRating == '2') {
	        	this.deposit = resetDepositRating2(creditLimit, maxCreditLimit, company);
			} else if (company.classRating == '3') {
	        	this.deposit = resetDepositRating3(creditLimit, maxCreditLimit, company);
			} else if (company.classRating == '4') {
	        	this.deposit = resetDepositRating4(creditLimit, maxCreditLimit, company);
			} else if (company.classRating == '5') {
	        	this.deposit = resetDepositRating5(creditLimit);
			} else if (company.classRating == '6') {
	        	this.deposit = resetDepositRating6(creditLimit);
			}
		} catch (Exception e) {
			System.debug('Credit Factory === ' + e.getMessage());
			throw new CreditFactoryException('Deposit recalculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}
	}


	/*******************************************************************************
	*  Name            : resetDepositRating1()
	*  Summary         : Reset deposit value for rating 1 and changed CL value.     
	*  CreatedDate     : 22/01/2019
	*  ModifiedDate    : 31/01/2019
	*  Parameters      : Decimal creditLimit - selected CL, Decimal maxCreditLimit - max Credit Limit for selected billing period, 
						 CreditCompany company - company from Credit System
	*  Returns         : Decimal
	******************************************************************************/
	private Decimal resetDepositRating1(Decimal creditLimit, Decimal maxCreditLimit, CreditCompany company) {
		if (company.dateoffoundation != null &&
				Date.newInstance(Integer.valueOf(company.dateoffoundation.substring(0, 4)), Integer.valueOf(company.dateoffoundation.substring(5, 7)), 
				Integer.valueOf(company.dateoffoundation.substring(8, 10))).monthsBetween(Date.today()) < 18) {
			if (creditLimit <= maxCreditLimit && maxCreditLimit > 0) {
				return 0;
			} else {
				return (creditLimit * 0.33 / 100).round(System.RoundingMode.HALF_UP) * 100;
			}
		} else {
			return 0;
		}
	}


	/*******************************************************************************
	*  Name            : resetDepositRating2()
	*  Summary         : Reset deposit value for rating 2 and changed CL value.
	*  CreatedDate     : 22/01/2019
	*  ModifiedDate    : 31/01/2019
	*  Parameters      : Decimal creditLimit - selected CL, Decimal maxCreditLimit - max Credit Limit for selected billing period,
						 CreditCompany company - company from Credit System
	*  Returns         : Decimal
	******************************************************************************/
	private Decimal resetDepositRating2(Decimal creditLimit, Decimal maxCreditLimit, CreditCompany company) {
		if (company.dateoffoundation != null &&
				Date.newInstance(Integer.valueOf(company.dateoffoundation.substring(0, 4)), Integer.valueOf(company.dateoffoundation.substring(5, 7)), 
				Integer.valueOf(company.dateoffoundation.substring(8, 10))).monthsBetween(Date.today()) < 18) {
			if (creditLimit <= maxCreditLimit && maxCreditLimit > 0) {
				return 0;
			} else {
				return (creditLimit * 0.33 / 100).round(System.RoundingMode.HALF_UP) * 100;
			}
		} else {
			return 0;
		}
	}


	/*******************************************************************************
	*  Name            : resetDepositRating3()
	*  Summary         : Reset deposit value for rating 3 and changed CL value. 
	*  CreatedDate     : 22/01/2019
	*  ModifiedDate    : 31/01/2019
	*  Parameters      : Decimal creditLimit - selected CL, Decimal maxCreditLimit - max Credit Limit for selected billing period,
						 CreditCompany company - company from Credit System
	*  Returns         : Decimal
	******************************************************************************/
	private Decimal resetDepositRating3(Decimal creditLimit, Decimal maxCreditLimit, CreditCompany company) {
		if (company.dateoffoundation != null &&
				Date.newInstance(Integer.valueOf(company.dateoffoundation.substring(0, 4)), Integer.valueOf(company.dateoffoundation.substring(5, 7)), 
				Integer.valueOf(company.dateoffoundation.substring(8, 10))).monthsBetween(Date.today()) < 18) {
			if (creditLimit <= maxCreditLimit && maxCreditLimit > 0) {
				return 0;
			} else {
				return (creditLimit * 0.33 / 100).round(System.RoundingMode.HALF_UP) * 100;
			}
		} else {
			return 0;
		}
	}


	/*******************************************************************************
	*  Name            : resetDepositRating4()
	*  Summary         : Reset deposit value for rating 4 and changed CL value    
	*  CreatedDate     : 22/01/2019
	*  ModifiedDate    : -
	*  Parameters      : Decimal creditLimit - selected CL, Decimal maxCreditLimit - max Credit Limit for selected billing period,
						 CreditCompany company - company from Credit System
	*  Returns         : Decimal
	******************************************************************************/
	private Decimal resetDepositRating4(Decimal creditLimit, Decimal maxCreditLimit, CreditCompany company) {
		Decimal recommendedCreditLimit = 0;
		if (company.creditLimit != null && company.creditLimit.isNumeric()) {
            recommendedCreditLimit = Decimal.valueOf(company.creditLimit);
        }
        if (company.dateoffoundation != null &&
				Date.newInstance(Integer.valueOf(company.dateoffoundation.substring(0, 4)), Integer.valueOf(company.dateoffoundation.substring(5, 7)), 
				Integer.valueOf(company.dateoffoundation.substring(8, 10))).monthsBetween(Date.today()) < 18) {
			if (creditLimit <= maxCreditLimit && maxCreditLimit > 0) {
				return 0;
			} else {
				return (creditLimit * 0.33 / 100).round(System.RoundingMode.HALF_UP) * 100;
			}
		} else {
			if (creditLimit <= maxCreditLimit && maxCreditLimit > 0) {
				return 0;
			} else {
				return ((creditLimit - recommendedCreditLimit) / 100).round(System.RoundingMode.HALF_UP) * 100;
			}
		}
	}


	/*******************************************************************************
	*  Name            : resetDepositRating5()
	*  Summary         : Reset deposit value for rating 5 and changed CL value    
	*  CreatedDate     : 22/01/2019
	*  ModifiedDate    : -
	*  Parameters      : Decimal creditLimit - changed CL value
	*  Returns         : Decimal
	******************************************************************************/
	private Decimal resetDepositRating5(Decimal creditLimit) {
		return (creditLimit * 0.7 / 100).round(System.RoundingMode.HALF_UP) * 100;
	}


	/*******************************************************************************
	*  Name            : resetDepositRating6()
	*  Summary         : Reset deposit value for rating 6 and changed CL value    
	*  CreatedDate     : 22/01/2019
	*  ModifiedDate    : -
	*  Parameters      : Decimal creditLimit - changed CL value
	*  Returns         : Decimal
	******************************************************************************/
	private Decimal resetDepositRating6(Decimal creditLimit) {
		return ((creditLimit * (30.0 + 27.0 + 10.0) / (30.0 + 27.0)) / 100).round(System.RoundingMode.HALF_UP) * 100;
	}


	/*******************************************************************************
	*  Name            : getDeposit()
	*  Summary         : Return deposit.    
	*  CreatedDate     : 15/10/2018
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
	*  CreatedDate     : 27/08/2018
	*  ModifiedDate    : 31/01/2019
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void setDecision() {
		try {
			this.decision = new CreditFactoryDecision();
			if (this.billingPeriod != null && this.paymentTerms != null && this.deposit == 0) {
				// Positive Decisions without deposit
				this.decision.verdict = 'Yes';
				if (! String.isEmpty(this.company.dateoffoundation) && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(0, 4)), 
						Integer.valueOf(this.company.dateoffoundation.substring(5, 7)), Integer.valueOf(this.company.dateoffoundation.substring(8, 10))).monthsBetween(Date.today()) < 18 &&
						this.billingPeriod == 30 && this.paymentTerms == 27) {
					// for E2E we use only 30+27, so we should check only 30+27 exceptions here, for internal CF it doesn't make sense
					if (this.sourceObject.Total_consumption_l_month__c < 351 && this.sourceObject.Sec_Channel__c == 'Inbound') {
						this.decision.statusCode = '004'; // '3 Kategorie 2 plus alle Shopartikel' of cards and Number of Cards >= 3 are not available options
						this.exceptionCode = '004';
					} else if (this.company.paidUpShareCapital != null && this.sourceObject.Total_consumption_l_month__c <= 0.01 * Decimal.valueOf(this.company.paidUpShareCapital)) {
						this.decision.statusCode = '005'; // '3 Kategorie 2 plus alle Shopartikel' of cards and Number of Cards >= 6 are not available options
						this.exceptionCode = '005';
					}
				} else {
					this.decision.statusCode = '001'; // No Limits, bp = 30, pt = 27
				}
			} else if (this.billingPeriod != null && this.paymentTerms != null && this.deposit != 0) {
				// Positive Decisions with deposit
				this.decision.verdict = 'Yes';
				this.decision.statusCode = '002'; // No Limits, bp = 30, pt = 27
			} else {
				// Negative Decisions
				this.decision.verdict = 'No';
				this.decision.statusCode = '003'; // Too high limit
			}
			if (this.userSource != 'E2E Long Form') {
				if (! errorsSet.contains(CONTACT_ERROR)) {
					if (this.decision.statusCode == '001' || this.decision.statusCode == '004' || this.decision.statusCode == '005') {
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
	*  Summary         : Reset Company Decision.    
	*  CreatedDate     : 21/01/2019
	*  ModifiedDate    : 20/02/2019
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
				if (company.dateoffoundation != null && Date.newInstance(Integer.valueOf(company.dateoffoundation.substring(0, 4)), 
						Integer.valueOf(company.dateoffoundation.substring(5, 7)), Integer.valueOf(company.dateoffoundation.substring(8, 10))).monthsBetween(Date.today()) < 18) {
					if (company.exceptionCode == '004') {
						this.decision.statusCode = '004'; // '3 Kategorie 2 plus alle Shopartikel' of cards and Number of Cards >= 3 are not available options
					} else if (company.exceptionCode == '005') {
						this.decision.statusCode = '005'; // '3 Kategorie 2 plus alle Shopartikel' of cards and Number of Cards >= 6 are not available options
					}
				} else {
					this.decision.statusCode = '001'; // No Limits, bp = 30, pt = 27
				}
			} else {
				// Decisions with deposit
				this.decision.statusCode = '002';
			}
		} catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Reset Decision failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}
	}


	/*******************************************************************************
	*  Name            : getDecision()
	*  Summary         : Return decision.    
	*  CreatedDate     : 22/01/2019
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : CreditFactoryDecision
	******************************************************************************/
	public CreditFactoryDecision getDecision() {
		return this.decision;
	}


	public void checkWarnings() {}



	/*******************************************************************************
	*  Name            : saveReports()
	*  Summary         : Save information from Credit system to Salesforce     
	*  CreatedDate     : 27/08/2018
	*  ModifiedDate    : 20/02/2019
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void saveReports() {
		if (this.existingCreditReport == null && company != null) {
			// insert
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
	            Credit_Decision__c = company.creditDecision,
	            Credit_Limit__c = company.creditLimit,
	            Date_of_Foundation__c = company.dateoffoundation,
	            Email__c = company.email,
	            Fax__c = company.fax,
	            Fiscal_Number__c = company.taxnumber,
	            Housenumber__c = company.housenumber,
	            Legal_Form__c = company.legalform,
	            Mobile__c = company.mobile,
	            Opportunity__c = sourceObject.Id,
	            Phone__c = company.phone,
	            Postcode__c = company.postcode,
	            Staff_Range__c = company.staffcompanyrange,
	            Street__c = company.street,
	            Turn_Over__c = company.turnOver,
	            VAT_Number__c = company.vatid,
	            Tax_Id__c = company.taxnumber,
	            Website__c = company.website,
	            Name = reportName,
	            Company_Id__c = company.identificationnumber,
	            Paid_Up_Share_Capital__c = company.paidUpShareCapital,
	            Paid_Up_Share_Capital_Currency__c = company.paidUpShareCapitalCurrency,
	            Solvency_Index__c = company.solvencyIndex,
	            Name__c = company.name,
	            CurrencyIsoCode = 'CHF');

				if (this.userSource == 'E2E Long Form') {
					newReport.Billing_Period__c = this.billingPeriod;
					newReport.Payment_Terms__c = this.paymentTerms;
	                newReport.Security_Level__c = this.securityLevel;
	                newReport.Buffer__c = this.buffer * 100;
	                newReport.Risk_Category__c = this.riskCategory;
		            newReport.Credit_Limit_Default__c = getCreditLimit();
		            newReport.Credit_Limit_Monthly_27__c = getCreditLimitMonthlyPlus27();
					newReport.Max_Credit_Limit_Monthly_27__c = getMaxCreditLimitMonthlyPlus27();
					newReport.Max_Value_Monthly_27__c = getMaxValueMonthlyPlus27();
					newReport.Deposit_Monthly_27__c = getDepositMonthlyPlus27();
					newReport.Decision_Verdict__c = this.decision.verdict;
					newReport.Decision_Status_Code__c = this.decision.statusCode;
					newReport.Exception_Code__c = this.exceptionCode;
				}

	        if (company.classRating != null) {
	            newReport.Class_Rating__c = company.classRating;
	        }

	        try {
	            insert newReport;
	            List<Credit_Factory_Report_Employee__c> employeesListToInsert = new List<Credit_Factory_Report_Employee__c>();
	            for (CreditCompanyEmployee e : companyEmployeesList) {
	                employeesListToInsert.add(new Credit_Factory_Report_Employee__c(
	                    Credit_Factory_Report__c = newReport.Id,
	                    Address__c = e.address,
	                    Date_of_Birth__c = e.dateofbirth,
	                    Id__c = e.enumber,
	                    Name = e.ename,
	                    Participation_Date__c = e.participationdate,
	                    Type__c = e.type));
	            }
	            insert employeesListToInsert;
	        } catch (Exception e) {
	        	CreditFactoryUtilities.displayMessage('error','Error on saving Credit Factory Report and Credit Factory Report Employees. Contact your administrator.');
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
	                Buffer__c = this.buffer * 100,
	                Risk_Category__c = this.riskCategory,
		            Credit_Limit_Default__c = getCreditLimit(),
		            Credit_Limit_Monthly_27__c = getCreditLimitMonthlyPlus27(),
					Max_Credit_Limit_Monthly_27__c = getMaxCreditLimitMonthlyPlus27(),
					Max_Value_Monthly_27__c = getMaxValueMonthlyPlus27(),
					Deposit_Monthly_27__c = getDepositMonthlyPlus27(),
					Decision_Verdict__c = this.decision.verdict,
					Decision_Status_Code__c = this.decision.statusCode,
					Exception_Code__c = this.exceptionCode);
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
	*  Name 		   : updateOpportunityByCredit()
	*  Summary         : update opportunity with button by Credit
	*  CreatedDate     : 27/08/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : PageReference - redirect to Opportunity record
	******************************************************************************/
	public PageReference updateOpportunityByCredit() {
        this.sourceObject.put(
        	this.opportunityMapping.Credit_System_Rating__c,
        	this.company.classRating);
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
        if (! String.isEmpty(this.company.dateoffoundation)) {
            this.sourceObject.put(this.opportunityMapping.Year_of_foundation__c,this.company.dateoffoundation.substring(0, 4));
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
	*  Name 		   : changeBillingPeriodBySales()
	*  Summary         : Change Billing Period and update fields in Opportunity
	*  CreatedDate     : 27/08/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public PageReference changeBillingPeriodBySales() {
		try {
	        this.sourceObject.put(this.opportunityMapping.Payment_Terms_Credit__c, String.valueOf(this.paymentTerms));
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
	*  Name 		   : updateOpportunityWithPDF()
	*  Summary         : Update Opportunity field "PDF created"
	*  CreatedDate     : 27/08/2018
	*  ModifiedDate    : -
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
	*  Name 		   : doCreateReportAttachment(String opportunityId)
	*  Summary         : Create Credit Company Report PDF Attachment in Salesforce and attach to Opportunity
	*  CreatedDate     : 27/08/2018
	*  ModifiedDate    : -
	*  Parameters      : opportunityId - source record Salesforce id
	*  Returns         : Boolean - true if report attached to opportunity
	******************************************************************************/
	public Boolean doCreateReportAttachment(String opportunityId) {
        if (this.attachmentBody != null) {
            try {
                Attachment creforeport = new Attachment(
                    ParentId = opportunityId,
                    Name = 'CrediconnectReport.pdf',
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


	/*******************************************************************************
	*  Name            : isPendingSEPAPossible()
	*  Summary         : check possibility to automatically change Stage to Pending Sales - SEPA Confirmation    
	*  CreatedDate     : 27/08/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : Boolean
	******************************************************************************/
	public Boolean isPendingSEPAPossible() {
		if ((this.sourceObject.get(this.opportunityMapping.Payment_Method__c) == 'Lastschrift' && this.sourceObject.Einwilligung_Lastschriftverfahren__c == false)) {
			return true;
		} else {
			return false;
		}
	}


	/*******************************************************************************
	*  Name            : isAutoCWPossible()
	*  Summary         : check possibility to automatically change Stage to Closed Won     
	*  CreatedDate     : 27/08/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : Boolean
	******************************************************************************/
	public Boolean isAutoCWPossible() {
		if ((this.sourceObject.get(this.opportunityMapping.Payment_Method__c) == 'Banküberweisung' || 
				(this.sourceObject.get(this.opportunityMapping.Payment_Method__c) == 'Lastschrift' && this.sourceObject.Einwilligung_Lastschriftverfahren__c == true))) {
			return true;
		} else {
			return false;
		}
	}


	/*******************************************************************************
	*  Name            : changeToPendingSEPAConfirmation()
	*  Summary         : Change Opportunity StageName to Pending Sales - SEPA Confirmation
	*  CreatedDate     : 15/10/2018
	*  Modifieddate    : -
	*  Parameters      : -
	*  Returns         : PageReference
	******************************************************************************/
	public PageReference changeToPendingSEPAConfirmation() {
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
			prepareGeneralFieldsForAutoprocess();
	        this.sourceObject.StageName = 'Pending Sales - SEPA Confirmation';
	        this.sourceObject.CF_Stage__c = 'SEPA Confirmation';
	        update this.sourceObject;
	        update this.sourceObject.Account;	
	        return new PageReference('/' + this.sourceObject.Id);
		} catch (Exception e) {
        	CreditFactoryUtilities.displayMessage('error','Change to Pending Sales - SEPA Confirmation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        	return null;
		}
	}


	/*******************************************************************************
	*  Name 		   : changeToClosedWon()
	*  Summary         : Change opportunity StageName to Closed Won
	*  CreatedDate     : 27/08/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : PageReference
	******************************************************************************/
	public PageReference changeToClosedWon() {
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
			prepareGeneralFieldsForAutoprocess();
	        this.sourceObject.StageName = 'Closed Won';
	        this.sourceObject.ForecastCategoryName = 'Closed';
	        this.sourceObject.Closed_Won_by_CF__c = true;
	        this.sourceObject.CF_Stage__c = 'Auto CW';
	        update this.sourceObject.Account;
	        update this.sourceObject;
	        return new PageReference('/' + this.sourceObject.Id);
		} catch (Exception e) {
			ExceptionLogger.sendException('<br/>Reason: ' + String.valueOf(e.getMessage()) + '<br/>Opportunity Id: ' + this.sourceObject.Id, String.valueOf(e.getStackTraceString()));
        	throw new CreditFactoryException('Change to Closed Won failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}
	}


	/*******************************************************************************
	*  Name            : countNumberOfRelatedTankkartens()
	*  Summary         : count number of Tankkarten__c objects related to the current Opportunity    
	*  CreatedDate     : 27/08/2018
	*  ModifiedDate    : -
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
	*  Name            : prepareGeneralFieldsForAutoprocess()
	*  Summary         : prepare fields for Closed Won or Pending Sales    
	*  CreatedDate     : 27/08/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void prepareGeneralFieldsForAutoprocess() {
		this.sourceObject.put(this.opportunityMapping.Payment_Terms_Credit__c, String.valueOf(this.paymentTerms));
        this.sourceObject.put(this.opportunityMapping.Billing_Period__c,String.valueOf(this.billingPeriod));
        this.sourceObject.put(this.opportunityMapping.CF_Credit_Limit__c, this.creditLimit);
        this.sourceObject.put(this.opportunityMapping.Credit_check_date__c,Date.today());
        this.sourceObject.put(this.opportunityMapping.Processed_by__c, 'Autoprocessed by Sales');
        this.sourceObject.put(this.opportunityMapping.Credit_Decision__c, 'Genehmigt');
        this.sourceObject.CloseDate = Date.today();
        this.sourceObject.Billing_Period_by_Sales__c = true;
    	this.sourceObject.put(this.opportunityMapping.Risk_Category__c, this.riskCategory);
    	this.sourceObject.put(this.opportunityMapping.Buffer__c, this.buffer * 100);
        if (this.maxCreditLimit != null) {
            this.sourceObject.put(this.opportunityMapping.Max_Credit_Limit__c, this.maxCreditLimit);
	    }
		this.sourceObject.Last_CF_Errors__c = null;
		this.sourceObject.Account.Gesellschaftsform__c = this.company.legalform;
	}


	/*******************************************************************************
    *  Name            : checkDuplicates()
    *  Summary         : if duplicates is existed then stop credit process    
    *  CreatedDate     : 27/08/2018
	*  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private void checkDuplicates() {
    	if (isSales()) {
    		CreditFactoryUtilities.checkDuplicates(this.sourceObject);
		}
    }


    /*******************************************************************************
	*  Name            : changeToPendingDeposit()
	*  Summary         : change Opportunity Stage Name to Pending Sales - Deposit automatically
	*  CreatedDate     : 27/08/2018
	*  ModifiedDate    : -
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


	public PageReference changeToContractCheck() {
		return null;
	}
}