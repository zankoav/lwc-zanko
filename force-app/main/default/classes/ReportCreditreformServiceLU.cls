/*******************************************************************************
*  ReportCreditreformService 
*  
*  Implementation of CreditReport for CreditreformLU Webservice. Get company from webservice, validation, 
*  flows for Credit and Sales users.
*
******************************************************************************/
public class ReportCreditreformServiceLU implements CreditReport {
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
    private Decimal creditLimitBiWeeklyPlus7;
    private Decimal maxCreditLimitBiWeeklyPlus7;
    private Decimal maxValueBiWeeklyPlus7;
    private Decimal depositBiWeeklyPlus7;
    private Decimal creditLimitBiWeeklyPlus14;
    private Decimal maxCreditLimitBiWeeklyPlus14;
    private Decimal depositBiWeeklyPlus14;
    private Decimal creditLimitMonthlyPlus7;
    private Decimal maxCreditLimitMonthlyPlus7;
    private Decimal maxValueMonthlyPlus7;
    private Decimal depositMonthlyPlus7;
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
    private String TAX_ID = CreditFactoryUtilities.returnLabelOfField('Account','Steuernummer__c');
    private String VAT_NUMBER = CreditFactoryUtilities.returnLabelOfField('Account','Umsatzsteuer_ID__c');
    public final String ADDRESS_ERROR = 'Address';
    public final String COMPANY_NAME_ERROR = 'CompanyName';
    public final String CONTACT_ERROR = 'Contact';
    public final String CONTACT_ROLE_ERROR = 'ContactRole';
    public final String TAX_ID_ERROR = 'TaxId';
    public final String VAT_NUMBER_ERROR = 'VatNumber';
    public final String LOST_OPPORTUNITY_ERROR = 'LostOpportunity';
    public final String PAYMENT_METHOD_ERROR = 'PaymentMethod';
    public final String PUBLIC_ENTITY_ERROR = 'PublicEntity';
    private Credit_Factory_Report__c existingCreditReport;
    private String errorToRequestOrder;
    public String userSource;


    /*******************************************************************************
    *  Name            : setUserSource(String userSource)
    *  Summary         : set user source    
    *  CreatedDate     : 13/11/2018
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
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : String
    ******************************************************************************/
    public String getUserSource() {
    	return this.userSource;
    }


	/*******************************************************************************
	*  Name 		   : setMapping()
	*  Summary         : Set custom settings for Opportunity and Account.
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void setMapping() {
		try {
			accountMapping = Credit_Factory_Account__c.getInstance(CreditReformWebserviceLU.CREDIT_SYSTEM_NAME);
			if (accountMapping == null) {
				throw new CreditFactoryException('Account mapping does not exist. ' + CreditFactoryUtilities.CONTACT_ADMIN);
			}
		} catch (Exception e) {
			throw new CreditFactoryException('Account mapping select error. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}

		try {
			opportunityMapping = Credit_Factory_Opportunity__c.getInstance(CreditReformWebserviceLU.CREDIT_SYSTEM_NAME);
			if (opportunityMapping == null) {
				throw new CreditFactoryException('Opportunity mapping does not exist. ' + CreditFactoryUtilities.CONTACT_ADMIN);
			}
		} catch (Exception e) {
			throw new CreditFactoryException('Opportunity mapping select error. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}
	}


	/*******************************************************************************
	*  Name 		   : setSourceObject(String sfdcRecordId)
	*  Summary         : Get required information from object.
	*  CreatedDate     : 13/11/2018
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
							' (SELECT Contact.Id, Contact.Email, Contact.Phone, Contact.LastName, Contact.FirstName, Contact.Name, ' + 
							' IsPrimary, Role FROM OpportunityContactRoles) ' +
			        ' FROM Opportunity' + 
			        ' WHERE Id = :sfdcRecordId';
			sourceObject = Database.query(soql);	
    	} catch (Exception e) {
    		System.debug('Credit Factory Error === ' + e.getMessage());
    		throw new CreditFactoryException('Select Opportunity failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
    	}
    }


	/*******************************************************************************
	*  Name 		   : getSourceObject()
	*  Summary         : Returns sObject that we need to use for credit request.
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : sObject - Opportunity 
	******************************************************************************/
    public sObject getSourceObject() {
    	return this.sourceObject;
    }


	/*******************************************************************************
	*  Name 		   : setXmlResponse(CreditSystem creditSystem, String companyId)
	*  Summary         : Send request to Credit System to get company, employees and pdf report
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : creditSystem - credit system
					   	 companyId - parameter value from search page
	*  Returns         : 
	******************************************************************************/
    public void setXmlResponse(CreditSystem creditSystem, String companyId) {
    	//send request
		HttpRequest request;
		try {
			// Generate and send request
    		request = CreditReformWebserviceLU.generateReportRequest(
    			creditSystem.getEndpointUrl(), creditSystem.getUserName(), 
    			creditSystem.getUserPassword(), creditSystem.getApiKey(), companyId);
			Http h = new Http();
			HttpResponse response = h.send(request);
			this.attachmentBody = doPrepareBodyForAttachment(response);
			this.xmlResponseBody = response.getBody();
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
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : String - xml 
	*  Returns         : sObject
	******************************************************************************/
    public String getXmlResponse() {
    	return this.xmlResponseBody;
    }


	/*******************************************************************************
	*  Name 		   : setCompany()
	*  Summary         : Set Company information from xml response body
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : creditSystem - credit system
					   	 companyId - parameter value from search page
	*  Returns         : 
	******************************************************************************/
	public void setCompany(CreditSystem creditSystem, String companyId) {
		if (this.existingCreditReport != null) {
        	this.company = getExistingReportCompany();
        } else {
			setXmlResponse(creditSystem, companyId);

	        try {
				String xml = this.xmlResponseBody;
		        xml = CreditReformWebserviceLU.clearSearchXML(xml);
		        Dom.Document domDoc = new Dom.Document();
		        domDoc.load(xml);
		        Dom.XMLNode xmldom = domDoc.getRootElement();
		        Dom.XMLNode globalBody = CreditReformWebserviceLU.returnGlobalBody(xmldom);
		        Dom.XMLNode innerBody = CreditReformWebserviceLU.returnInnerBody(globalBody);
		        
		        // If error - display on the page
		        if (innerBody == null) {
		            String errorMessage = CreditReformWebserviceLU.returnErrorMessage(globalBody);
		            if (errorMessage == 'ER-114 Das gewählte Produkt ist für das angefragte Unternehmen nicht verfügbar. Sie können eine Wirtschaftsauskunft ' + 
		            	'abrufen oder bestellen.' || errorMessage == 'ER-66 Auskunft zur Zeit nicht möglich. Bitte Auftrag erteilen.') {
		            	this.errorToRequestOrder = errorMessage;
		            	return;
		            }

		            throw new CreditFactoryException(errorMessage);
		        }
				this.company = CreditReformWebserviceLU.returnReportCompany(innerBody, this.creditSystemCompanyNumber);
	        } catch (Exception e) {
				System.debug('Credit Factory === ' + e.getMessage());
				String errorMessage = 'Set company error. ' + CreditFactoryUtilities.CONTACT_ADMIN + '<br/>' + e.getMessage();
	            throw new CreditFactoryException(errorMessage);
	        }
	    }
	}


	/*******************************************************************************
	*  Name            : getErrorToRequestOrder()
	*  Summary         : check necessity to send order request    
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : String
	******************************************************************************/
	public String getErrorToOrderRequest() {
		return this.errorToRequestOrder;
	}


	public String getInternalId() {
        return null;
    }


	/*******************************************************************************
	*  Name 		   : getCompany()
	*  Summary         : Returns Company with Credit information
	*  CreatedDate     : 13/11/2018
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
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void setEmployees() {
		try {
			if (this.existingCreditReport != null) { 
        		this.companyEmployeesList = getExistingReportCompanyEmployees();
        	} else { 
		        String xml = this.xmlResponseBody;
		        xml = CreditReformWebserviceLU.clearSearchXML(xml);
		        Dom.Document domDoc = new Dom.Document();
		        domDoc.load(xml);
		        Dom.XMLNode xmldom = domDoc.getRootElement();
		        Dom.XMLNode globalBody = CreditReformWebserviceLU.returnGlobalBody(xmldom);
		        Dom.XMLNode innerBody = CreditReformWebserviceLU.returnInnerBody(globalBody);
		        
		        //If error - display on the page
		        if (innerBody == null) {
		            String errorMessage = CreditReformWebserviceLU.returnErrorMessage(globalBody);
		            if (errorMessage == 'ER-114 Das gewählte Produkt ist für das angefragte Unternehmen nicht verfügbar. Sie können eine Wirtschaftsauskunft ' + 
		            	'abrufen oder bestellen.' || errorMessage == 'ER-66 Auskunft zur Zeit nicht möglich. Bitte Auftrag erteilen.') {
		            	this.errorToRequestOrder = errorMessage;
		            	return;
		            }

		            throw new CreditFactoryException(errorMessage);	
		        }

		        this.companyEmployeesList = CreditReformWebserviceLU.returnReportCompanyEmployees(innerBody);
		    }
		} catch (Exception e) {
			System.debug('Credit Factory === ' + e.getMessage());
			String errorMessage = 'Set employees error. ' + CreditFactoryUtilities.CONTACT_ADMIN;
            throw new CreditFactoryException(errorMessage);	
		}
	}


	public void updateEmployees(CreditSystem creditSystem, String companyId) {}


	/*******************************************************************************
	*  Name 		   : setEmployee()
	*  Summary         : Set employees from credit company
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
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
    *  Summary         : Set existing in database credit reports.
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : 08/01/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void setExistingCreditReports() {
        List<Credit_Factory_Report__c> creditReportsList = [
                SELECT Credit_System_Number__c, Reference_Number__c, Class_Rating__c, Turn_Over__c, Legal_Form__c, VAT_Number__c, Tax_Id__c, Date_Legal_Form__c, Register_Number__c,
                	Date_Last_Register_Entry__c, County_Court__c, Payment_Behaviour__c, Staff_Range__c, Credit_Limit__c, Credit_Limit_Currency__c, Credit_Decision__c, Date_of_Foundation__c,
                	Age_of_Company__c, First_Legal_Form__c, Company_Status__c, Name, Trade_Name__c, Street__c, Housenumber__c, Postcode__c, City__c, Country__c, Phone__c, Fax__c, Mobile__c, 
                	Email__c, Website__c, Solvency_Index__c, Company_Id__c, Name__c, 
                			(SELECT Type__c, Name, Date_of_Birth__c, Address__c, Participation_Date__c 
                			FROM Credit_Factory_Report_Employees__r)
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
    *  Summary         : Return company from Credit Factory Report object.
    *  CreatedDate     : 13/11/2018
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
        company.solvencyIndex = this.existingCreditReport.Solvency_Index__c;
        return company;
    }


    /*******************************************************************************
    *  Name            : getExistingReportCompanyEmployees()
    *  Summary         : Return company from Credit Factory Report Employee object.    
    *  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
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
    		employeesList.add(employee);
    	}
    	return employeesList;
    }


	/*******************************************************************************
	*  Name 		   : isSales()
	*  Summary         : Check Sales Profile
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
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
	*  Summary         : Returns set of errors and display section to fix error on page.
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : Set<String>
	******************************************************************************/
	public Set<String> getErrorsSet() {
		return this.errorsSet;
	}


	/*******************************************************************************
	*  Name 		   : validate()
	*  Summary         : Compare information from CreditReform with Salesforce.
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
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
	    	if ( ! validateLostOpportunities()) isValid = false;
	    	if ( ! validatePaymentMethod()) isValid = false;
	    	validateContact();
    	} else {
	    	if ( ! validateAddress()) isValid = false;
	    	if ( ! validateLegalForm()) isValid = false;
	    	if ( ! validateTaxId()) isValid = false;
	    	if ( ! validateVatNumber()) isValid = false;
	    	if ( ! validateLostOpportunities()) isValid = false;
	    	if ( ! validatePaymentMethod()) isValid = false;
	    	validateContact();
    	}

    	return isValid;
	}


	/*******************************************************************************
	*  Name 		   : validateAddress()
	*  Summary         : Compare Address information from CreditReform with Salesforce.
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
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
        String crefoStreetAndHouseNumber = (company.street != null ? this.company.street : '') + ' ' + (company.housenumber != null ? this.company.housenumber : '');
        crefoStreetAndHouseNumber = crefoStreetAndHouseNumber.removeStart(' ').removeEnd(' ');
        String crefoHouseNumberAndStreet = (company.housenumber != null ? this.company.housenumber : '') + ' ' + (company.street != null ? this.company.street : '');
        crefoHouseNumberAndStreet = crefoHouseNumberAndStreet.removeStart(' ').removeEnd(' ');
        
        String billingPostalCode = sourceObject.Account.BillingPostalCode;
        String shippingPostalCode = sourceObject.Account.ShippingPostalCode;
        String crefoPostalcode = this.company.postcode;

        String billingCity = sourceObject.Account.BillingCity;
        String shippingCity = sourceObject.Account.ShippingCity;
        String crefoCity = this.company.city;

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
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : String billingStreet – Billing Street 
						 String shippingStreet – Shipping Street 
						 String crefoStreet – Street for Creditreform 
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
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : String billingCity – Billing City 
						 String shippingCity – Shipping City 
						 String crefoCity – City for Creditreform 
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
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : String billingPostalCode – Billing PostalCode 
						 String shippingPostalCode – Shipping PostalCode 
						 String crefoPostalCode – PostalCode for Creditreform 
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
	*  Name 		   : validateLegalForm()
	*  Summary         : Compare Legal Form information from CreditReform with Salesforce.
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : Boolean - returns true if no errors
	******************************************************************************/
	public Boolean validateLegalForm() {
		// Check public entity
		if (this.company.legalForm == 'Etablissement public') {
			// Just display message, do not return false.
			errorsSet.add(PUBLIC_ENTITY_ERROR);
			CreditFactoryUtilities.displayMessage('error', 'Customer is a public entity.');
		} 

        return true;
	}


	/*******************************************************************************
	*  Name 		   : validateContact()
	*  Summary         : Check that contact from CreditReform exists in Salesforce
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
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
        		firstName = CreditFactoryUtilities.replaceGermanCharacters(contactRelation.Contact.FirstName).toUpperCase().replace('’', '\'');
        	}
        	
        	String lastName = CreditFactoryUtilities.replaceGermanCharacters(contactRelation.Contact.LastName).toUpperCase().replace('’', '\'');
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
					if (CreditFactoryUtilities.replaceGermanCharacters(emp.ename).toUpperCase().replace('\u00a0', ' ').contains(lastName)) {
						isContactExists = true;
					}
				}
	        }
        }

        if (this.userSource == 'E2E Long Form') {
        	for (String firstAndLastName : contactsFirstAndLastNamesSet) {
				if (firstAndLastName == CreditFactoryUtilities.replaceGermanCharacters(this.company.Name).toUpperCase().replace('’', '\'')) {
					isContactExists = true;
				}
			}
        } else if (validateCompanyName() == true) {
        	for (String firstAndLastName : contactsFirstAndLastNamesSet) {
				if (firstAndLastName == CreditFactoryUtilities.replaceGermanCharacters(this.sourceObject.Account.Name).toUpperCase().replace('’', '\'')) {
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
        		errorsSet.add(CONTACT_ERROR);
        		String errorMessage = 'No directors information for this company';
        		CreditFactoryUtilities.displayMessage('error', errorMessage);
        		if (primaryContactRole == 'Executive assistant' || primaryContactRole == 'Fleet manager' || primaryContactRole == 'Owner\'s relative') {
	    			errorsSet.add(CONTACT_ROLE_ERROR);
	    			CreditFactoryUtilities.displayMessage('error', 'Please choose call with contact role confirmation.'); 
	    		}

        		return false;
        	} else if ( ! isContactExists) {
        		errorsSet.add(CONTACT_ERROR);
	        	String errorMessage = 'Crefo Contact person doesn\'t exist in Account\'s Contacts';
	        	CreditFactoryUtilities.displayMessage('error', errorMessage);
	        	if (primaryContactRole == 'Executive assistant' || primaryContactRole == 'Fleet manager' || primaryContactRole == 'Owner\'s relative') {
	    			errorsSet.add(CONTACT_ROLE_ERROR);
	    			CreditFactoryUtilities.displayMessage('error', 'Please choose call with contact role confirmation.'); 
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
	*  Summary         : Check that Account Name is the same as Company Name from Salesforce.
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : Boolean - returns true if no errors
	******************************************************************************/
	public Boolean validateCompanyName() {
        if ( ! CreditFactoryUtilities.isStringsEquals(sourceObject.Account.Name, this.company.Name)) {
            errorsSet.add(COMPANY_NAME_ERROR);
            String errorMessage = 'Account Name and Crefo Name mismatch';
            CreditFactoryUtilities.displayMessage('error',errorMessage);

            return false;
        }

		return true;
	}


	/*******************************************************************************
	*  Name            : validateTaxId()
	*  Summary         : Compare Creditreform Tax Id with Salesforce.
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : Boolean
	******************************************************************************/
	public Boolean validateTaxId() {
		if (company.taxnumber != null && this.company.taxnumber != '0' && this.company.taxnumber != 'nicht bekannt' && this.company.taxnumber != 'unbekannt' &&
				! CreditFactoryUtilities.isStringsEquals(company.taxnumber, (String)sourceObject.getSobject('Account').get(this.accountMapping.Tax_Id__c))) {
            errorsSet.add(TAX_ID_ERROR);
            String errorMessage = 'Account Tax ID mismatch (Creditreform to Account ' + TAX_ID + ')';
            CreditFactoryUtilities.displayMessage('error',errorMessage);
            return false;
        }

        return true;
	}


	/*******************************************************************************
	*  Name            : validateVatNumber()
	*  Summary         : Compare Creditreform Tax Id with Salesforce.
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : Boolean
	******************************************************************************/
	public Boolean validateVatNumber() {
		if (company.vatid != null && this.company.vatid != '0' && this.company.vatid != 'nicht bekannt' && this.company.vatid != 'unbekannt' &&
				! CreditFactoryUtilities.isStringsEquals(company.vatid, (String)sourceObject.getSobject('Account').get(this.accountMapping.VAT_Number__c))) {
            errorsSet.add(VAT_NUMBER_ERROR);
            String errorMessage = 'Account VAT number mismatch (Creditreform to Account ' + VAT_NUMBER + ')';
            CreditFactoryUtilities.displayMessage('error',errorMessage);
            return false;
        }

        return true;
	}


	/*******************************************************************************
	*  Name            : validateLostOpportunities()
	*  Summary         : Check for Lost Opportunities relates to current Opportunity's.
						 Account or its Contacts    
	*  CreatedDate     : 13/11/2018
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
	*  Name            : validatePaymentMethod()
	*  Summary         : Check available for autoprocess payment method. 
	*  CreatedDate     : 14/11/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : Boolean
	******************************************************************************/
	private Boolean validatePaymentMethod() {
		if (this.sourceObject.get(this.opportunityMapping.Payment_Method__c) == 'Banküberweisung') {
			errorsSet.add(PAYMENT_METHOD_ERROR);
			String errorMessage = 'Opportunity cannot be closed automatically with Payment Method Bank Transfer.';
			CreditFactoryUtilities.displayMessage('error', errorMessage);
			return false;
		}

		return true;
	}


	/*******************************************************************************
	*  Name 		   : validateBlackList()
	*  Summary         : Check if Company is in black list.
	*  CreatedDate     : 13/11/2018
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
	*  Summary         : Update address information in Account based on address from CreditReform
	*  CreatedDate     : 13/11/2018
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
	*  Summary         : Update Account name with Credireform Company Name.
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : 
	*  Returns         : void
	******************************************************************************/
    public void doUpdateCompanyName() {
    	Account account = new Account(
    		Id = sourceObject.AccountId,
            Name = this.company.name);
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
	*  Summary         : Update Account Tax Id with Credireform Tax Id.
	*  CreatedDate     : 13/11/2018
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
	*  Summary         : Update Account Vat Number with Crif Vat Number.
	*  CreatedDate     : 13/11/2018
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
	*  Summary         : Update specific fields in Opportunity by Sales when all validations are passed.
	*  CreatedDate     : 13/11/2018
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
		    if (this.company.dateoffoundation != null) {
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
	*  CreatedDate     : 13/11/2018
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
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : classRating - Credit Company rating (1, 2, 3, ...)
	*  Returns         : void
	******************************************************************************/
	public void setBuffer(String classRating) {
        if (classRating != null) {
            if (classRating == '1' || classRating == '2') {
                this.buffer = 0.3;
            } else if (classRating == '3') {
                this.buffer = 0.2;
            } else if (classRating == '4' || classRating == '5') {
				this.buffer = 0.1;
            } else if (classRating == '6') {
				this.buffer = 0;
            } 
        } else {
        	this.buffer = 0.1;
        }
	}


	/*******************************************************************************
	*  Name 		   : getRiskCategory()
	*  Summary         : Return Risk Category
	*  CreatedDate     : 13/11/2018
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
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : classRating - Credit Company rating (1, 2, 3, ...)
	*  Returns         : void
	******************************************************************************/
	public void setRiskCategory(String classRating) {
        if (classRating != null) {
            if (classRating == '1' || classRating == '2') {
                this.riskCategory = 'Low';
            } else if (classRating == '3') {
                this.riskCategory = 'Medium';
            } else if (classRating == '4' || classRating == '5') {
				this.riskCategory = 'High';
            } else if (classRating == '6') {
				this.riskCategory = 'Very';
            } 
        } else {
        	this.riskCategory = 'High';
        }
	}


	/*******************************************************************************
	*  Name            : getSecurityLevel()
	*  Summary         : Return security level
	*  CreatedDate     : 13/11/2018
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
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : classRating - Credit Company rating (1, 2, 3, ...)
	*  Returns         : void
	******************************************************************************/
	public void setSecurityLevel(String classRating) {
		if (classRating == '4') {
			this.securityLevel = 4;
		} else if (classRating == '5') {
			this.securityLevel = 70;
		} else if (classRating == '6') {
			this.securityLevel = 110;
		} else if (classRating == null) {
			this.securityLevel = 100;
		}
	}


	/*******************************************************************************
	*  Name 		   : getCreditLimitWeeklyPlus7()
	*  Summary         : Return Credit Limit Weekly Plus 7
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : Decimal
	******************************************************************************/
	public Decimal getCreditLimitWeeklyPlus7() {
		if (this.creditLimitWeeklyPlus7 < 50) {
			this.creditLimitWeeklyPlus7 = this.creditLimitWeeklyPlus7 + 50;
		}

		return (this.creditLimitWeeklyPlus7 / 100).round(System.RoundingMode.HALF_UP) * 100;
	}


	/*******************************************************************************
	*  Name 		   : setCreditLimitWeeklyPlus7(Decimal buffer)
	*  Summary         : Calculate Credit Limit Weekly Plus 7
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
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
	*  Name 		   : getMaxCreditLimitWeeklyPlus7()
	*  Summary         : Return Max Credit Limit Weekly Plus 7
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : Decimal
	******************************************************************************/
	public Decimal getMaxCreditLimitWeeklyPlus7() {
		return (this.maxCreditLimitWeeklyPlus7 / 100).round(System.RoundingMode.HALF_UP) * 100;
	}


	/*******************************************************************************
	*  Name            : setMaxCreditLimitWeeklyPlus7()
	*  Summary         : Calculate Max Credit Limit Weekly Plus 7    
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void setMaxCreditLimitWeeklyPlus7() {
		try {
			if (this.company.classRating == '1') {
				setMaxCreditLimitWeeklyPlus7Rating1();
			} else if (this.company.classRating == '2') {
				setMaxCreditLimitWeeklyPlus7Rating2();
			} else if (this.company.classRating == '3') {
				setMaxCreditLimitWeeklyPlus7Rating3();
			} else if (this.company.classRating == '4') {
				setMaxCreditLimitWeeklyPlus7Rating4();
			} else if (this.company.classRating == '5') {
				setMaxCreditLimitWeeklyPlus7Rating5();
			} else if (this.company.classRating == '6') {
				setMaxCreditLimitWeeklyPlus7Rating6();
			} else if (this.company.classRating == null) {
				setMaxCreditLimitWeeklyPlus7NoRating();
			}
	    } catch (Exception e) {
	    	System.debug('Credit Factory === ' + e.getMessage());
	    	throw new CreditFactoryException('Max Credit Limit Weekly + 7 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
	    }
	}


	/*******************************************************************************
	*  Name            : setMaxCreditLimitWeeklyPlus7Rating1()
	*  Summary         : Calculate Max Credit Limit Weekly Plus 7 for Rating 1  
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setMaxCreditLimitWeeklyPlus7Rating1() {
		if (this.creditLimitWeeklyPlus7 * 2 < 8000) {
			this.maxCreditLimitWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 2;
		} else {
			this.maxCreditLimitWeeklyPlus7 = 8000;
		}
	}


	/*******************************************************************************
	*  Name            : setMaxCreditLimitWeeklyPlus7Rating2()
	*  Summary         : Calculate Max Credit Limit Weekly Plus 7 for Rating 2 
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setMaxCreditLimitWeeklyPlus7Rating2() {
		if (this.creditLimitWeeklyPlus7 * 2 < 8000) {
			this.maxCreditLimitWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 2;
		} else {
			this.maxCreditLimitWeeklyPlus7 = 8000;
		}
	}


	/*******************************************************************************
	*  Name            : setMaxCreditLimitWeeklyPlus7Rating3()
	*  Summary         : Calculate Max Credit Limit Weekly Plus 7 for Rating 3  
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setMaxCreditLimitWeeklyPlus7Rating3() {
		if (this.creditLimitWeeklyPlus7 * 2 < 8000) {
			this.maxCreditLimitWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 2;
		} else {
			this.maxCreditLimitWeeklyPlus7 = 8000;
		}
	}


	/*******************************************************************************
	*  Name            : setMaxCreditLimitWeeklyPlus7Rating4()
	*  Summary         : Calculate Max Credit Limit Weekly Plus 7 for Rating 4  
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setMaxCreditLimitWeeklyPlus7Rating4() {
		Decimal recommendedCreditLimit = 0;
		if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
            recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
        }
		if (recommendedCreditLimit + 500 > this.creditLimitWeeklyPlus7 * 2) {
    		if (this.creditLimitWeeklyPlus7 * 2 < 8000) {
    			this.maxCreditLimitWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 2;
    		} else {
    			this.maxCreditLimitWeeklyPlus7 = 8000;
    		}
    	} else {
    		if (recommendedCreditLimit + 500 < 8000) {
    			this.maxCreditLimitWeeklyPlus7 = recommendedCreditLimit + 500;
    		} else {
    			this.maxCreditLimitWeeklyPlus7 = 8000;
    		}
    	}
	}


	/*******************************************************************************
	*  Name            : setMaxCreditLimitWeeklyPlus7Rating5()
	*  Summary         : Calculate Max Credit Limit Weekly Plus 7 for Rating 5
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setMaxCreditLimitWeeklyPlus7Rating5() {
		this.maxCreditLimitWeeklyPlus7 = 0;
	}


	/*******************************************************************************
	*  Name            : setMaxCreditLimitWeeklyPlus7Rating6()
	*  Summary         : Calculate Max Credit Limit Weekly Plus 7 for Rating 6
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setMaxCreditLimitWeeklyPlus7Rating6() {
		if (this.creditLimitWeeklyPlus7 * 2 < 8000) {
			this.maxCreditLimitWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 2;
		} else {
			this.maxCreditLimitWeeklyPlus7 = 8000;
		}
	}


	/*******************************************************************************
	*  Name            : setMaxCreditLimitWeeklyPlus7NoRating()
	*  Summary         : Calculate Max Credit Limit Weekly Plus 7 for NoRating
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setMaxCreditLimitWeeklyPlus7NoRating() {
		this.maxCreditLimitWeeklyPlus7 = 0;
	}


	/*******************************************************************************
	*  Name            : getMaxValueWeeklyPlus7()
	*  Summary         : Return Max value of Credit Limit including deposit Weekly Plus 7    
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : Decimal
	******************************************************************************/
	public Decimal getMaxValueWeeklyPlus7() {
		return (this.maxValueWeeklyPlus7 / 100).round(System.RoundingMode.HALF_UP) * 100;
	}


	/*******************************************************************************
	*  Name            : setMaxValueWeeklyPlus7()
	*  Summary         : Calculate Max value of Credit Limit including deposit Weekly Plus 7    
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void setMaxValueWeeklyPlus7() {
		try {
			if (this.creditLimitWeeklyPlus7 * 2 < 8000) {
				this.maxValueWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 2;
			} else {
				this.maxValueWeeklyPlus7 = 8000;
			}
	    } catch (Exception e) {
	    	System.debug('Credit Factory === ' + e.getMessage());
	    	throw new CreditFactoryException('Max Value Weekly + 7 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
	    }
	}


	/*******************************************************************************
	*  Name            : getDepositWeeklyPlus7()
	*  Summary         : Return Deposit Weekly Plus 7
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : Decimal
	******************************************************************************/
	public Decimal getDepositWeeklyPlus7() {
		if (this.depositWeeklyPlus7 > 0 && this.depositWeeklyPlus7 < 50) {
			this.depositWeeklyPlus7 = this.depositWeeklyPlus7 + 50;
		}

		return (this.depositWeeklyPlus7 / 100).round(System.RoundingMode.HALF_UP) * 100;
	}


	/*******************************************************************************
	*  Name            : setDepositWeeklyPlus7()
	*  Summary         : Calculate Deposit Weekly Plus 7    
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void setDepositWeeklyPlus7() {
		try {
			if (this.company.classRating == '1') {
				setDepositWeeklyPlus7Rating1();
			} else if (this.company.classRating == '2') {
				setDepositWeeklyPlus7Rating2();
			} else if (this.company.classRating == '3') {
				setDepositWeeklyPlus7Rating3();
			} else if (this.company.classRating == '4') {
				setDepositWeeklyPlus7Rating4();
			} else if (this.company.classRating == '5') {
				setDepositWeeklyPlus7Rating5();
			} else if (this.company.classRating == '6') {
				setDepositWeeklyPlus7Rating6();
			} else if (this.company.classRating == null) {
				setDepositWeeklyPlus7NoRating();
			}
		} catch (Exception e) {
			System.debug('Credit Factory === ' + e.getMessage());
			throw new CreditFactoryException('Deposit BiWeekly + 7 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}
	}


	/*******************************************************************************
	*  Name            : setDepositWeeklyPlus7Rating1()
	*  Summary         : Calculate Deposit Weekly Plus 7 for Rating 1    
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setDepositWeeklyPlus7Rating1() {
		this.depositWeeklyPlus7 = 0;
	}


	/*******************************************************************************
	*  Name            : setDepositWeeklyPlus7Rating2()
	*  Summary         : Calculate Deposit Weekly Plus 7 for Rating 2
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setDepositWeeklyPlus7Rating2() {
		this.depositWeeklyPlus7 = 0;
	}


	/*******************************************************************************
	*  Name            : setDepositWeeklyPlus7Rating3()
	*  Summary         : Calculate Deposit Weekly Plus 7 for Rating 3
	*  CreatedDate     : 05/03/2018
	*  ModifiedDate    : 05/03/2018
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setDepositWeeklyPlus7Rating3() {
		this.depositWeeklyPlus7 = 0;
	}


	/*******************************************************************************
	*  Name            : setDepositWeeklyPlus7Rating4()
	*  Summary         : Calculate Deposit Weekly Plus 7 for Rating 4
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setDepositWeeklyPlus7Rating4() {
		Decimal recommendedCreditLimit = 0;
		if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
            recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
        }
		if (this.creditLimitWeeklyPlus7 <= this.maxCreditLimitWeeklyPlus7 && this.maxCreditLimitWeeklyPlus7 > 0) {
			this.depositWeeklyPlus7 = 0;
		} else {
			if (this.creditLimitWeeklyPlus7 <= recommendedCreditLimit + 500) {
				this.depositWeeklyPlus7 = (this.creditLimitWeeklyPlus7 - this.maxCreditLimitWeeklyPlus7);
			} else {
				this.depositWeeklyPlus7 = (this.creditLimitWeeklyPlus7 - recommendedCreditLimit);
			}
		}
	}


	/*******************************************************************************
	*  Name            : setDepositWeeklyPlus7Rating5()
	*  Summary         : Calculate Deposit Weekly Plus 7 for Rating 5
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setDepositWeeklyPlus7Rating5() {	
		this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 0.7;
	}


	/*******************************************************************************
	*  Name            : setDepositWeeklyPlus7Rating6()
	*  Summary         : Calculate Deposit Weekly Plus 7 for Rating 6
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setDepositWeeklyPlus7Rating6() {
		this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7 * (15.0 + 7.0 + 10.0) / (15.0 + 7.0);
	}


	/*******************************************************************************
	*  Name            : setDepositWeeklyPlus7NoRating()
	*  Summary         : Calculate Deposit Weekly Plus 7 for No Rating
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setDepositWeeklyPlus7NoRating() {
		this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7;
	}


	/*******************************************************************************
	*  Name 		   : getCreditLimitBiWeeklyPlus7()
	*  Summary         : Return Credit Limit BiWeekly Plus 7
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : Decimal
	******************************************************************************/
	public Decimal getCreditLimitBiWeeklyPlus7() {
		if (this.creditLimitBiWeeklyPlus7 < 50) {
			this.creditLimitBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7 + 50;
		}

		return (this.creditLimitBiWeeklyPlus7 / 100).round(System.RoundingMode.HALF_UP) * 100;
	}


	/*******************************************************************************
	*  Name 		   : setCreditLimitBiWeeklyPlus7(Decimal buffer)
	*  Summary         : Calculate Credit Limit BiWeekly Plus 7
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : buffer - 0, 0.1, 0.2 or 0.3
	*  Returns         : void
	******************************************************************************/
	public void setCreditLimitBiWeeklyPlus7(Decimal buffer) {
		try {
			this.creditLimitBiWeeklyPlus7 = ((Decimal)this.sourceObject.get(this.opportunityMapping.Monthly_Volume_Currency__c) * 
				((15.0 + 7.0)/30.0)*(1.0 + buffer));
		} catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Credit Limit BiWeekly + 7 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}
	}


	/*******************************************************************************
	*  Name 		   : getMaxCreditLimitBiWeeklyPlus7()
	*  Summary         : Return Max Credit Limit BiWeekly Plus 7
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : Decimal
	******************************************************************************/
	public Decimal getMaxCreditLimitBiWeeklyPlus7() {
		return (this.maxCreditLimitBiWeeklyPlus7 / 100).round(System.RoundingMode.HALF_UP) * 100;
	}


	/*******************************************************************************
	*  Name            : setMaxCreditLimitBiWeeklyPlus7()
	*  Summary         : Calculate Max Credit Limit BiWeekly Plus 7    
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void setMaxCreditLimitBiWeeklyPlus7() {
		try {
			if (this.company.classRating == '1') {
				setMaxCreditLimitBiWeeklyPlus7Rating1();
			} else if (this.company.classRating == '2') {
				setMaxCreditLimitBiWeeklyPlus7Rating2();
			} else if (this.company.classRating == '3') {
				setMaxCreditLimitBiWeeklyPlus7Rating3();
			} else if (this.company.classRating == '4') {
				setMaxCreditLimitBiWeeklyPlus7Rating4();
			} else if (this.company.classRating == '5') {
				setMaxCreditLimitBiWeeklyPlus7Rating5();
			} else if (this.company.classRating == '6') {
				setMaxCreditLimitBiWeeklyPlus7Rating6();
			} else if (this.company.classRating == null) {
				setMaxCreditLimitBiWeeklyPlus7NoRating();
			}
	    } catch (Exception e) {
	    	System.debug('Credit Factory === ' + e.getMessage());
	    	throw new CreditFactoryException('Max Credit Limit BiWeekly + 7 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
	    }
	}


	/*******************************************************************************
	*  Name            : setMaxCreditLimitBiWeeklyPlus7Rating1()
	*  Summary         : Calculate Max Credit Limit BiWeekly Plus 7 for Rating 1  
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setMaxCreditLimitBiWeeklyPlus7Rating1() {
		if (this.creditLimitBiWeeklyPlus7 * 2 < 8000) {
			this.maxCreditLimitBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7 * 2;
		} else {
			this.maxCreditLimitBiWeeklyPlus7 = 8000;
		}
	}


	/*******************************************************************************
	*  Name            : setMaxCreditLimitBiWeeklyPlus7Rating2()
	*  Summary         : Calculate Max Credit Limit BiWeekly Plus 7 for Rating 2 
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setMaxCreditLimitBiWeeklyPlus7Rating2() {
		if (this.creditLimitBiWeeklyPlus7 * 2 < 8000) {
			this.maxCreditLimitBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7 * 2;
		} else {
			this.maxCreditLimitBiWeeklyPlus7 = 8000;
		}
	}


	/*******************************************************************************
	*  Name            : setMaxCreditLimitBiWeeklyPlus7Rating3()
	*  Summary         : Calculate Max Credit Limit BiWeekly Plus 7 for Rating 3  
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setMaxCreditLimitBiWeeklyPlus7Rating3() {
		if (this.creditLimitBiWeeklyPlus7 * 2 < 8000) {
			this.maxCreditLimitBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7 * 2;
		} else {
			this.maxCreditLimitBiWeeklyPlus7 = 8000;
		}
	}


	/*******************************************************************************
	*  Name            : setMaxCreditLimitBiWeeklyPlus7Rating4()
	*  Summary         : Calculate Max Credit Limit BiWeekly Plus 7 for Rating 4  
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setMaxCreditLimitBiWeeklyPlus7Rating4() {
		Decimal recommendedCreditLimit = 0;
		if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
            recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
        }
		if (recommendedCreditLimit + 500 > this.creditLimitBiWeeklyPlus7 * 2) {
    		if (this.creditLimitBiWeeklyPlus7 * 2 < 8000) {
    			this.maxCreditLimitBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7 * 2;
    		} else {
    			this.maxCreditLimitBiWeeklyPlus7 = 8000;
    		}
    	} else {
    		if (recommendedCreditLimit + 500 < 8000) {
    			this.maxCreditLimitBiWeeklyPlus7 = recommendedCreditLimit + 500;
    		} else {
    			this.maxCreditLimitBiWeeklyPlus7 = 8000;
    		}
    	}
	}


	/*******************************************************************************
	*  Name            : setMaxCreditLimitBiWeeklyPlus7Rating5()
	*  Summary         : Calculate Max Credit Limit BiWeekly Plus 7 for Rating 5
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setMaxCreditLimitBiWeeklyPlus7Rating5() {
		this.maxCreditLimitBiWeeklyPlus7 = 0;
	}


	/*******************************************************************************
	*  Name            : setMaxCreditLimitBiWeeklyPlus7Rating6()
	*  Summary         : Calculate Max Credit Limit BiWeekly Plus 7 for Rating 6
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setMaxCreditLimitBiWeeklyPlus7Rating6() {
		if (this.creditLimitBiWeeklyPlus7 * 2 < 8000) {
			this.maxCreditLimitBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7 * 2;
		} else {
			this.maxCreditLimitBiWeeklyPlus7 = 8000;
		}
	}


	/*******************************************************************************
	*  Name            : setMaxCreditLimitBiWeeklyPlus7NoRating()
	*  Summary         : Calculate Max Credit Limit BiWeekly Plus 7 for NoRating
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setMaxCreditLimitBiWeeklyPlus7NoRating() {
		this.maxCreditLimitBiWeeklyPlus7 = 0;
	}


	/*******************************************************************************
	*  Name            : getMaxValueBiWeeklyPlus7()
	*  Summary         : Return Max value of Credit Limit including deposit BiWeekly Plus 7    
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : Decimal
	******************************************************************************/
	public Decimal getMaxValueBiWeeklyPlus7() {
		return (this.maxValueBiWeeklyPlus7 / 100).round(System.RoundingMode.HALF_UP) * 100;
	}


	/*******************************************************************************
	*  Name            : setMaxValueBiWeeklyPlus7()
	*  Summary         : Calculate Max value of Credit Limit including deposit BiWeekly Plus 7    
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void setMaxValueBiWeeklyPlus7() {
		try {
			if (this.creditLimitBiWeeklyPlus7 * 2 < 8000) {
				this.maxValueBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7 * 2;
			} else {
				this.maxValueBiWeeklyPlus7 = 8000;
			}
	    } catch (Exception e) {
	    	System.debug('Credit Factory === ' + e.getMessage());
	    	throw new CreditFactoryException('Max Value BiWeekly + 7 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
	    }
	}


	/*******************************************************************************
	*  Name            : getDepositBiWeeklyPlus7()
	*  Summary         : Return Deposit BiWeekly Plus 7
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : Decimal
	******************************************************************************/
	public Decimal getDepositBiWeeklyPlus7() {
		if (this.depositBiWeeklyPlus7 > 0 && this.depositBiWeeklyPlus7 < 50) {
			this.depositBiWeeklyPlus7 = this.depositBiWeeklyPlus7 + 50;
		}

		return (this.depositBiWeeklyPlus7 / 100).round(System.RoundingMode.HALF_UP) * 100;
	}


	/*******************************************************************************
	*  Name            : setDepositBiWeeklyPlus7()
	*  Summary         : Calculate Deposit BiWeekly Plus 7    
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void setDepositBiWeeklyPlus7() {
		try {
			if (this.company.classRating == '1') {
				setDepositBiWeeklyPlus7Rating1();
			} else if (this.company.classRating == '2') {
				setDepositBiWeeklyPlus7Rating2();
			} else if (this.company.classRating == '3') {
				setDepositBiWeeklyPlus7Rating3();
			} else if (this.company.classRating == '4') {
				setDepositBiWeeklyPlus7Rating4();
			} else if (this.company.classRating == '5') {
				setDepositBiWeeklyPlus7Rating5();
			} else if (this.company.classRating == '6') {
				setDepositBiWeeklyPlus7Rating6();
			} else if (this.company.classRating == null) {
				setDepositBiWeeklyPlus7NoRating();
			}
		} catch (Exception e) {
			System.debug('Credit Factory === ' + e.getMessage());
			throw new CreditFactoryException('Deposit BiWeekly + 7 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}
	}


	/*******************************************************************************
	*  Name            : setDepositBiWeeklyPlus7Rating1()
	*  Summary         : Calculate Deposit BiWeekly Plus 7 for Rating 1    
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setDepositBiWeeklyPlus7Rating1() {
		this.depositBiWeeklyPlus7 = 0;
	}


	/*******************************************************************************
	*  Name            : setDepositBiWeeklyPlus7Rating2()
	*  Summary         : Calculate Deposit BiWeekly Plus 7 for Rating 2
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setDepositBiWeeklyPlus7Rating2() {
		this.depositBiWeeklyPlus7 = 0;
	}


	/*******************************************************************************
	*  Name            : setDepositBiWeeklyPlus7Rating3()
	*  Summary         : Calculate Deposit BiWeekly Plus 7 for Rating 3
	*  CreatedDate     : 05/03/2018
	*  ModifiedDate    : 05/03/2018
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setDepositBiWeeklyPlus7Rating3() {
		this.depositBiWeeklyPlus7 = 0;
	}


	/*******************************************************************************
	*  Name            : setDepositBiWeeklyPlus7Rating4()
	*  Summary         : Calculate Deposit Weekly Plus 7 for Rating 4
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setDepositBiWeeklyPlus7Rating4() {
		Decimal recommendedCreditLimit = 0;
		if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
            recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
        }
		if (this.creditLimitBiWeeklyPlus7 <= this.maxCreditLimitBiWeeklyPlus7 && this.maxCreditLimitBiWeeklyPlus7 > 0) {
			this.depositBiWeeklyPlus7 = 0;
		} else {
			if (this.creditLimitBiWeeklyPlus7 <= recommendedCreditLimit + 500) {
				this.depositBiWeeklyPlus7 = (this.creditLimitBiWeeklyPlus7 - this.maxCreditLimitBiWeeklyPlus7);
			} else {
				this.depositBiWeeklyPlus7 = (this.creditLimitBiWeeklyPlus7 - recommendedCreditLimit);
			}
		}
	}


	/*******************************************************************************
	*  Name            : setDepositBiWeeklyPlus7Rating5()
	*  Summary         : Calculate Deposit BiWeekly Plus 7 for Rating 5
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setDepositBiWeeklyPlus7Rating5() {
		this.depositBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7 * 0.7;
	}


	/*******************************************************************************
	*  Name            : setDepositBiWeeklyPlus7Rating6()
	*  Summary         : Calculate Deposit BiWeekly Plus 7 for Rating 6
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setDepositBiWeeklyPlus7Rating6() {
		this.depositBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7 * (15.0 + 7.0 + 10.0) / (15.0 + 7.0);
	}


	/*******************************************************************************
	*  Name            : setDepositBiWeeklyPlus7Rating4()
	*  Summary         : Calculate Deposit BiWeekly Plus 7 for Rating 4
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setDepositBiWeeklyPlus7NoRating() {
		this.depositBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7;
	}


	/*******************************************************************************
	*  Name            : getCreditLimitBiWeeklyPlus14()
	*  Summary         : Calculate Credit Limit BiWeekly Plus 14    
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : Decimal
	******************************************************************************/
	public Decimal getCreditLimitBiWeeklyPlus14() {
		if (this.creditLimitBiWeeklyPlus14 < 50) {
			this.creditLimitBiWeeklyPlus14 = this.creditLimitBiWeeklyPlus14 + 50;
		}

		return (this.creditLimitBiWeeklyPlus14 / 100).round(System.RoundingMode.HALF_UP) * 100;
	}


	/*******************************************************************************
	*  Name 		   : setCreditLimitBiWeeklyPlus14(Decimal buffer)
	*  Summary         : Calculate Credit Limit BiWeekly Plus 14
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
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
	*  Name 		   : getMaxCreditLimitBiWeeklyPlus14()
	*  Summary         : Return Max Credit Limit BiWeekly Plus 14
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : Decimal
	******************************************************************************/
	public Decimal getMaxCreditLimitBiWeeklyPlus14() {
		return (this.maxCreditLimitBiWeeklyPlus14 / 100).round(System.RoundingMode.HALF_UP) * 100;
	}


	/*******************************************************************************
	*  Name            : setMaxCreditLimitBiWeeklyPlus14()
	*  Summary         : Calculate Max Credit Limit BiWeekly Plus 14    
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void setMaxCreditLimitBiWeeklyPlus14() {
		try {
			if (this.company.classRating == '1') {
				setMaxCreditLimitBiWeeklyPlus14Rating1();
			} else if (this.company.classRating == '2') {
				setMaxCreditLimitBiWeeklyPlus14Rating2();
			} else if (this.company.classRating == '3') {
				setMaxCreditLimitBiWeeklyPlus14Rating3();
			} else if (this.company.classRating == '4') {
				setMaxCreditLimitBiWeeklyPlus14Rating4();
			} else if (this.company.classRating == '5') {
				setMaxCreditLimitBiWeeklyPlus14Rating5();
			} else if (this.company.classRating == '6') {
				setMaxCreditLimitBiWeeklyPlus14Rating6();
			} else if (this.company.classRating == null) {
				setMaxCreditLimitBiWeeklyPlus14NoRating();
			}
	    } catch (Exception e) {
	    	System.debug('Credit Factory === ' + e.getMessage());
	    	throw new CreditFactoryException('Max Credit Limit BiWeekly + 14 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
	    }
	}


	/*******************************************************************************
	*  Name            : setMaxCreditLimitBiWeeklyPlus14Rating1()
	*  Summary         : Calculate Max Credit Limit BiWeekly Plus 14 for Rating 1  
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setMaxCreditLimitBiWeeklyPlus14Rating1() {
		if (this.creditLimitBiWeeklyPlus14 * 2 < 8000) {
			this.maxCreditLimitBiWeeklyPlus14 = this.creditLimitBiWeeklyPlus14 * 2;
		} else {
			this.maxCreditLimitBiWeeklyPlus14 = 8000;
		}
	}


	/*******************************************************************************
	*  Name            : setMaxCreditLimitBiWeeklyPlus14Rating2()
	*  Summary         : Calculate Max Credit Limit BiWeekly Plus 14 for Rating 2 
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setMaxCreditLimitBiWeeklyPlus14Rating2() {
		if (this.creditLimitBiWeeklyPlus14 * 2 < 8000) {
			this.maxCreditLimitBiWeeklyPlus14 = this.creditLimitBiWeeklyPlus14 * 2;
		} else {
			this.maxCreditLimitBiWeeklyPlus14 = 8000;
		}
	}


	/*******************************************************************************
	*  Name            : setMaxCreditLimitBiWeeklyPlus14Rating3()
	*  Summary         : Calculate Max Credit Limit BiWeekly Plus 14 for Rating 3  
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setMaxCreditLimitBiWeeklyPlus14Rating3() {
		if (this.creditLimitBiWeeklyPlus14 * 2 < 8000) {
			this.maxCreditLimitBiWeeklyPlus14 = this.creditLimitBiWeeklyPlus14 * 2;
		} else {
			this.maxCreditLimitBiWeeklyPlus14 = 8000;
		}
	}


	/*******************************************************************************
	*  Name            : setMaxCreditLimitBiWeeklyPlus14Rating4()
	*  Summary         : Calculate Max Credit Limit BiWeekly Plus 14 for Rating 4  
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setMaxCreditLimitBiWeeklyPlus14Rating4() {
		Decimal recommendedCreditLimit = 0;
		if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
            recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
        }
		if (recommendedCreditLimit + 500 > this.creditLimitBiWeeklyPlus14 * 2) {
    		if (this.creditLimitBiWeeklyPlus14 * 2 < 8000) {
    			this.maxCreditLimitBiWeeklyPlus14 = this.creditLimitBiWeeklyPlus14 * 2;
    		} else {
    			this.maxCreditLimitBiWeeklyPlus14 = 8000;
    		}
    	} else {
    		if (recommendedCreditLimit + 500 < 8000) {
    			this.maxCreditLimitBiWeeklyPlus14 = recommendedCreditLimit + 500;
    		} else {
    			this.maxCreditLimitBiWeeklyPlus14 = 8000;
    		}
    	} 
	}


	/*******************************************************************************
	*  Name            : setMaxCreditLimitBiWeeklyPlus14Rating5()
	*  Summary         : Calculate Max Credit Limit BiWeekly Plus 14 for Rating 5
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setMaxCreditLimitBiWeeklyPlus14Rating5() {
		this.maxCreditLimitBiWeeklyPlus14 = 0;
	}


	/*******************************************************************************
	*  Name            : setMaxCreditLimitBiWeeklyPlus14Rating6()
	*  Summary         : Calculate Max Credit Limit BiWeekly Plus 14 for Rating 6
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setMaxCreditLimitBiWeeklyPlus14Rating6() {
		if (this.creditLimitBiWeeklyPlus14 * 2 < 8000) {
			this.maxCreditLimitBiWeeklyPlus14 = this.creditLimitBiWeeklyPlus14 * 2;
		} else {
			this.maxCreditLimitBiWeeklyPlus14 = 8000;
		}
	}


	/*******************************************************************************
	*  Name            : setMaxCreditLimitBiWeeklyPlus14NoRating()
	*  Summary         : Calculate Max Credit Limit BiWeekly Plus 14 for NoRating
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setMaxCreditLimitBiWeeklyPlus14NoRating() {
		this.maxCreditLimitBiWeeklyPlus14 = 0;
	}


	/*******************************************************************************
	*  Name            : getDepositBiWeeklyPlus14()
	*  Summary         : Return Deposit BiWeekly Plus 14
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : Decimal
	******************************************************************************/
	public Decimal getDepositBiWeeklyPlus14() {
		if (this.depositBiWeeklyPlus14 > 0 && this.depositBiWeeklyPlus14 < 50) {
			this.depositBiWeeklyPlus14 = this.depositBiWeeklyPlus14 + 50;
		}

		return (this.depositBiWeeklyPlus14 / 100).round(System.RoundingMode.HALF_UP) * 100;
	}


	/*******************************************************************************
	*  Name            : setDepositBiWeeklyPlus14()
	*  Summary         : Calculate Deposit BiWeekly Plus 14
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void setDepositBiWeeklyPlus14() {
		try {
			if (this.company.classRating == '1') {
				setDepositBiWeeklyPlus14Rating1();
			} else if (this.company.classRating == '2') {
				setDepositBiWeeklyPlus14Rating2();
			} else if (this.company.classRating == '3') {
				setDepositBiWeeklyPlus14Rating3();
			} else if (this.company.classRating == '4') {
				setDepositBiWeeklyPlus14Rating4();
			} else if (this.company.classRating == '5') {
				setDepositBiWeeklyPlus14Rating5();
			} else if (this.company.classRating == '6') {
				setDepositBiWeeklyPlus14Rating6();
			} else if (this.company.classRating == null) {
				setDepositBiWeeklyPlus14NoRating();
			}
		} catch (Exception e) {
			System.debug('Credit Factory === ' + e.getMessage());
			throw new CreditFactoryException('Deposit BiWeekly + 14 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}
	}


	/*******************************************************************************
	*  Name            : setDepositBiWeeklyPlus14Rating1()
	*  Summary         : Calculate Deposit BiWeekly Plus 14 for Rating 1    
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setDepositBiWeeklyPlus14Rating1() {
		this.depositBiWeeklyPlus14 = 0;
	}


	/*******************************************************************************
	*  Name            : setDepositBiWeeklyPlus14Rating2()
	*  Summary         : Calculate Deposit BiWeekly Plus 14 for Rating 2
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setDepositBiWeeklyPlus14Rating2() {
		this.depositBiWeeklyPlus14 = 0;
	}


	/*******************************************************************************
	*  Name            : setDepositBiWeeklyPlus14Rating3()
	*  Summary         : Calculate Deposit BiWeekly Plus 14 for Rating 3
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setDepositBiWeeklyPlus14Rating3() {
		this.depositBiWeeklyPlus14 = 0;
	}


	/*******************************************************************************
	*  Name            : setDepositBiWeeklyPlus7Rating4()
	*  Summary         : Calculate Deposit Weekly Plus 14 for Rating 4
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setDepositBiWeeklyPlus14Rating4() {
		Decimal recommendedCreditLimit = 0;
		if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
            recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
        }
		if (this.creditLimitBiWeeklyPlus14 <= this.maxCreditLimitBiWeeklyPlus14 && this.maxCreditLimitBiWeeklyPlus14 > 0) {
			this.depositBiWeeklyPlus14 = 0;
		} else {
			if (this.creditLimitBiWeeklyPlus14 <= recommendedCreditLimit + 500) {
				this.depositBiWeeklyPlus14 = (this.creditLimitBiWeeklyPlus14 - this.maxCreditLimitBiWeeklyPlus14);
			} else {
				this.depositBiWeeklyPlus14 = (this.creditLimitBiWeeklyPlus14 - recommendedCreditLimit);
			}
		}
	}


	/*******************************************************************************
	*  Name            : setDepositBiWeeklyPlus14Rating5()
	*  Summary         : Calculate Deposit BiWeekly Plus 14 for Rating 5
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setDepositBiWeeklyPlus14Rating5() {
		this.depositBiWeeklyPlus14 = this.creditLimitBiWeeklyPlus14 * 0.7;
	}


	/*******************************************************************************
	*  Name            : setDepositBiWeeklyPlus14Rating6()
	*  Summary         : Calculate Deposit BiWeekly Plus 14 for Rating 6
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setDepositBiWeeklyPlus14Rating6() {
		this.depositBiWeeklyPlus14 = this.creditLimitBiWeeklyPlus14 * (15.0 + 14.0 + 10.0) / (15.0 + 14.0);
	}


	/*******************************************************************************
	*  Name            : setDepositBiWeeklyPlus14Rating4()
	*  Summary         : Calculate Deposit BiWeekly Plus 14 for Rating 4
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setDepositBiWeeklyPlus14NoRating() {
		this.depositBiWeeklyPlus14 = this.creditLimitBiWeeklyPlus14;
	}


	public Decimal getMaxValueBiWeeklyPlus14() {
		return null;
	}


	public void setMaxValueBiWeeklyPlus14() {}


	/*******************************************************************************
	*  Name 		   : getCreditLimitMonthlyPlus7()
	*  Summary         : Return Credit Limit Monthly Plus 7
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : Decimal
	******************************************************************************/
	public Decimal getCreditLimitMonthlyPlus7() {
		if (this.creditLimitMonthlyPlus7 < 50) {
			this.creditLimitMonthlyPlus7 = this.creditLimitMonthlyPlus7 + 50;
		}
		
		return (this.creditLimitMonthlyPlus7 / 100).round(System.RoundingMode.HALF_UP) * 100;
	}


	/*******************************************************************************
	*  Name 		   : setCreditLimitMonthlyPlus7(Decimal buffer)
	*  Summary         : Calculate Credit Limit Monthly Plus 7
	*  CreatedDate     : 13/11/2018
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
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : Decimal
	******************************************************************************/
	public Decimal getMaxCreditLimitMonthlyPlus7() {
		return (this.maxCreditLimitMonthlyPlus7 / 100).round(System.RoundingMode.HALF_UP) * 100;
	}


	/*******************************************************************************
	*  Name            : setMaxCreditLimitMonthlyPlus7()
	*  Summary         : Calculate Max Credit Limit Monthly Plus 7    
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void setMaxCreditLimitMonthlyPlus7() {
		try {
			if (this.company.classRating == '1') {
				setMaxCreditLimitMonthlyPlus7Rating1();
			} else if (this.company.classRating == '2') {
				setMaxCreditLimitMonthlyPlus7Rating2();
			} else if (this.company.classRating == '3') {
				setMaxCreditLimitMonthlyPlus7Rating3();
			} else if (this.company.classRating == '4') {
				setMaxCreditLimitMonthlyPlus7Rating4();
			} else if (this.company.classRating == '5') {
				setMaxCreditLimitMonthlyPlus7Rating5();
			} else if (this.company.classRating == '6') {
				setMaxCreditLimitMonthlyPlus7Rating6();
			} else if (this.company.classRating == null) {
				setMaxCreditLimitMonthlyPlus7NoRating();
			}
	    } catch (Exception e) {
	    	System.debug('Credit Factory === ' + e.getMessage());
	    	throw new CreditFactoryException('Max Credit Limit Monthly + 7 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
	    }
	}


	/*******************************************************************************
	*  Name            : setMaxCreditLimitMonthlyPlus7Rating1()
	*  Summary         : Calculate Max Credit Limit Monthly Plus 7 for Rating 1  
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setMaxCreditLimitMonthlyPlus7Rating1() {
		if (this.creditLimitMonthlyPlus7 * 2 < 8000) {
			this.maxCreditLimitMonthlyPlus7 = this.creditLimitMonthlyPlus7 * 2;
		} else {
			this.maxCreditLimitMonthlyPlus7 = 8000;
		}
	}


	/*******************************************************************************
	*  Name            : setMaxCreditLimitMonthlyPlus7Rating2()
	*  Summary         : Calculate Max Credit Limit Monthly Plus 7 for Rating 2 
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setMaxCreditLimitMonthlyPlus7Rating2() {
		if (this.creditLimitMonthlyPlus7 * 2 < 8000) {
			this.maxCreditLimitMonthlyPlus7 = this.creditLimitMonthlyPlus7 * 2;
		} else {
			this.maxCreditLimitMonthlyPlus7 = 8000;
		}
	}


	/*******************************************************************************
	*  Name            : setMaxCreditLimitMonthlyPlus7Rating3()
	*  Summary         : Calculate Max Credit Limit Monthly Plus 7 for Rating 3  
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setMaxCreditLimitMonthlyPlus7Rating3() {
		if (this.creditLimitMonthlyPlus7 * 2 < 8000) {
			this.maxCreditLimitMonthlyPlus7 = this.creditLimitMonthlyPlus7 * 2;
		} else {
			this.maxCreditLimitMonthlyPlus7 = 8000;
		}
	}


	/*******************************************************************************
	*  Name            : setMaxCreditLimitMonthlyPlus7Rating4()
	*  Summary         : Calculate Max Credit Limit Monthly Plus 7 for Rating 4  
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setMaxCreditLimitMonthlyPlus7Rating4() {
		Decimal recommendedCreditLimit = 0;
		if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
            recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
        }
		if (recommendedCreditLimit + 500 > this.creditLimitMonthlyPlus7 * 2) {
    		if (this.creditLimitMonthlyPlus7 * 2 < 8000) {
    			this.maxCreditLimitMonthlyPlus7 = this.creditLimitMonthlyPlus7 * 2;
    		} else {
    			this.maxCreditLimitMonthlyPlus7 = 8000;
    		}
    	} else {
    		if (recommendedCreditLimit + 500 < 8000) {
    			this.maxCreditLimitMonthlyPlus7 = recommendedCreditLimit + 500;
    		} else {
    			this.maxCreditLimitMonthlyPlus7 = 8000;
    		}
    	} 
	}


	/*******************************************************************************
	*  Name            : setMaxCreditLimitMonthlyPlus7Rating5()
	*  Summary         : Calculate Max Credit Limit Monthly Plus 7 for Rating 5
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setMaxCreditLimitMonthlyPlus7Rating5() {
		this.maxCreditLimitMonthlyPlus7 = 0;
	}


	/*******************************************************************************
	*  Name            : setMaxCreditLimitMonthlyPlus7Rating6()
	*  Summary         : Calculate Max Credit Limit Monthly Plus 7 for Rating 6
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setMaxCreditLimitMonthlyPlus7Rating6() {
		if (this.creditLimitMonthlyPlus7 * 2 < 8000) {
			this.maxCreditLimitMonthlyPlus7 = this.creditLimitMonthlyPlus7 * 2;
		} else {
			this.maxCreditLimitMonthlyPlus7 = 8000;
		}
	}


	/*******************************************************************************
	*  Name            : setMaxCreditLimitMonthlyPlus7NoRating()
	*  Summary         : Calculate Max Credit Limit Monthly Plus 7 for NoRating
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setMaxCreditLimitMonthlyPlus7NoRating() {
		this.maxCreditLimitMonthlyPlus7 = 0;
	}


	/*******************************************************************************
	*  Name            : getMaxValueMonthlyPlus7()
	*  Summary         : Return Max value of Credit Limit including deposit Monthly Plus 7    
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : Decimal
	******************************************************************************/
	public Decimal getMaxValueMonthlyPlus7() {
		return (this.maxValueMonthlyPlus7 / 100).round(System.RoundingMode.HALF_UP) * 100;
	}


	/*******************************************************************************
	*  Name            : setMaxValueMonthlyPlus7()
	*  Summary         : Calculate Max value of Credit Limit including deposit Monthly Plus 7    
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void setMaxValueMonthlyPlus7() {
		try {
			if (this.creditLimitMonthlyPlus7 * 2 < 8000) {
				this.maxValueMonthlyPlus7 = this.creditLimitMonthlyPlus7 * 2;
			} else {
				this.maxValueMonthlyPlus7 = 8000;
			}
	    } catch (Exception e) {
	    	System.debug('Credit Factory === ' + e.getMessage());
	    	throw new CreditFactoryException('Max Value Monthly + 7 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
	    }
	}


	/*******************************************************************************
	*  Name            : getDepositMonthlyPlus7()
	*  Summary         : Return Deposit Monthly Plus 7
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : Decimal
	******************************************************************************/
	public Decimal getDepositMonthlyPlus7() {
		if (this.depositMonthlyPlus7 > 0 && this.depositMonthlyPlus7 < 50) {
			this.depositMonthlyPlus7 = this.depositMonthlyPlus7 + 50;
		}

		return (this.depositMonthlyPlus7 / 100).round(System.RoundingMode.HALF_UP) * 100;
	}


	/*******************************************************************************
	*  Name            : setDepositMonthlyPlus7()
	*  Summary         : Calculate Deposit Monthly Plus 7    
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void setDepositMonthlyPlus7() {
		try {
			if (this.company.classRating == '1') {
				setDepositMonthlyPlus7Rating1();
			} else if (this.company.classRating == '2') {
				setDepositMonthlyPlus7Rating2();
			} else if (this.company.classRating == '3') {
				setDepositMonthlyPlus7Rating3();
			} else if (this.company.classRating == '4') {
				setDepositMonthlyPlus7Rating4();
			} else if (this.company.classRating == '5') {
				setDepositMonthlyPlus7Rating5();
			} else if (this.company.classRating == '6') {
				setDepositMonthlyPlus7Rating6();
			} else if (this.company.classRating == null) {
				setDepositMonthlyPlus7NoRating();
			}
		} catch (Exception e) {
			System.debug('Credit Factory === ' + e.getMessage());
			throw new CreditFactoryException('Deposit Monthly calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}
	}


	/*******************************************************************************
	*  Name            : setDepositMonthlyPlus7Rating1()
	*  Summary         : Calculate Deposit Monthly Plus 7 for Rating 1    
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setDepositMonthlyPlus7Rating1() {
		this.depositMonthlyPlus7 = 0;
	}


	/*******************************************************************************
	*  Name            : setDepositMonthlyPlus7Rating2()
	*  Summary         : Calculate Deposit Monthly Plus 7 for Rating 2
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setDepositMonthlyPlus7Rating2() {
		this.depositMonthlyPlus7 = 0;
	}


	/*******************************************************************************
	*  Name            : setDepositMonthlyPlus7Rating3()
	*  Summary         : Calculate Deposit Monthly Plus 7 for Rating 3
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setDepositMonthlyPlus7Rating3() {
		this.depositMonthlyPlus7 = 0;
	}


	/*******************************************************************************
	*  Name            : setDepositMonthlyPlus7Rating4()
	*  Summary         : Calculate Deposit Weekly Plus 7 for Rating 4
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setDepositMonthlyPlus7Rating4() {
		Decimal recommendedCreditLimit = 0;
		if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
            recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
        }
		if (this.creditLimitMonthlyPlus7 <= this.maxCreditLimitMonthlyPlus7 && this.maxCreditLimitMonthlyPlus7 > 0) {
			this.depositMonthlyPlus7 = 0;
		} else {
			if (this.creditLimitMonthlyPlus7 <= recommendedCreditLimit + 500) {
				this.depositMonthlyPlus7 = (this.creditLimitMonthlyPlus7 - this.maxCreditLimitMonthlyPlus7);
			} else {
				this.depositMonthlyPlus7 = (this.creditLimitMonthlyPlus7 - recommendedCreditLimit);
			}
		}
	}


	/*******************************************************************************
	*  Name            : setDepositMonthlyPlus7Rating5()
	*  Summary         : Calculate Deposit Monthly Plus 7 for Rating 5
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setDepositMonthlyPlus7Rating5() {
		this.depositMonthlyPlus7 = this.creditLimitMonthlyPlus7 * 0.7;
	}


	/*******************************************************************************
	*  Name            : setDepositMonthlyPlus7Rating6()
	*  Summary         : Calculate Deposit Monthly Plus 7 for Rating 6
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setDepositMonthlyPlus7Rating6() {
		this.depositMonthlyPlus7 = this.creditLimitMonthlyPlus7 * (30.0 + 7.0 + 10.0) / (30.0 + 7.0);
	}


	/*******************************************************************************
	*  Name            : setDepositMonthlyPlus7Rating4()
	*  Summary         : Calculate Deposit Monthly Plus 7 for Rating 4
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setDepositMonthlyPlus7NoRating() {
		this.depositMonthlyPlus7 = this.creditLimitMonthlyPlus7;
	}


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
	*  Summary         : Calculate payment details such as billing period, payment terms, max credit limit and deposit    
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
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
		} else if (this.company.classRating == null) {
			setPaymentDetailsNoRating();
		}
	}


	/*******************************************************************************
	*  Name            : setPaymentDetailsRating1()
	*  Summary         : Calculate payment details (billing period, payment terms) for rating 1.    
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setPaymentDetailsRating1() {
		try {
            if (this.creditLimitMonthlyPlus7 < 8000) {
            	if (this.sourceObject.Zahlungsziel_2__c == '7' && this.sourceObject.Rechnungsperiode_2__c == '7') {
            		this.billingPeriod = 7;
            		this.paymentTerms = 7;
            	} else if (this.sourceObject.Zahlungsziel_2__c == '15' && this.sourceObject.Rechnungsperiode_2__c == '7') {
            		this.billingPeriod = 15;
            		this.paymentTerms = 7;
            	} else if (this.sourceObject.Zahlungsziel_2__c == '15' && this.sourceObject.Rechnungsperiode_2__c == '14' && this.userSource != 'E2E Long Form') {
            		this.billingPeriod = 15;
            		this.paymentTerms = 14;
            	} else {
            		this.billingPeriod = 30;
            		this.paymentTerms = 7;
            	}
            } else if (this.creditLimitBiWeeklyPlus14 < 8000 && this.userSource != 'E2E Long Form') {
            	if (this.sourceObject.Zahlungsziel_2__c == '7' && this.sourceObject.Rechnungsperiode_2__c == '7') {
            		this.billingPeriod = 7;
            		this.paymentTerms = 7;
            	} else if (this.sourceObject.Zahlungsziel_2__c == '15' && this.sourceObject.Rechnungsperiode_2__c == '7') {
            		this.billingPeriod = 15;
            		this.paymentTerms = 7;
            	} else {
            		this.billingPeriod = 15;
            		this.paymentTerms = 14;
            	}
            } else if (this.creditLimitBiWeeklyPlus7 < 8000) {
            	if (this.sourceObject.Zahlungsziel_2__c == '7' && this.sourceObject.Rechnungsperiode_2__c == '7') {
            		this.billingPeriod = 7;
            		this.paymentTerms = 7;
            	} else {
            		this.billingPeriod = 15;
        			this.paymentTerms = 7;
        		}
            } else if (this.creditLimitWeeklyPlus7 < 8000) {
            	this.billingPeriod = 7;
            	this.paymentTerms = 7;
            }
		} catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Payment details for Rating 1 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}
	}


	/*******************************************************************************
	*  Name            : setPaymentDetailsRating2()
	*  Summary         : Calculate payment details (billing period, payment terms) for rating 2.
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setPaymentDetailsRating2() {
		try {
            if (this.creditLimitMonthlyPlus7 < 8000) {
            	if (this.sourceObject.Zahlungsziel_2__c == '7' && this.sourceObject.Rechnungsperiode_2__c == '7') {
            		this.billingPeriod = 7;
            		this.paymentTerms = 7;
            	} else if (this.sourceObject.Zahlungsziel_2__c == '15' && this.sourceObject.Rechnungsperiode_2__c == '7') {
            		this.billingPeriod = 15;
            		this.paymentTerms = 7;
            	} else if (this.sourceObject.Zahlungsziel_2__c == '15' && this.sourceObject.Rechnungsperiode_2__c == '14' && this.userSource != 'E2E Long Form') {
            		this.billingPeriod = 15;
            		this.paymentTerms = 14;
            	} else {
            		this.billingPeriod = 30;
            		this.paymentTerms = 7;
            	}
            } else if (this.creditLimitBiWeeklyPlus14 < 8000 && this.userSource != 'E2E Long Form') {
            	if (this.sourceObject.Zahlungsziel_2__c == '7' && this.sourceObject.Rechnungsperiode_2__c == '7') {
            		this.billingPeriod = 7;
            		this.paymentTerms = 7;
            	} else if (this.sourceObject.Zahlungsziel_2__c == '15' && this.sourceObject.Rechnungsperiode_2__c == '7') {
            		this.billingPeriod = 15;
            		this.paymentTerms = 7;
            	} else {
            		this.billingPeriod = 15;
            		this.paymentTerms = 14;
            	}
            } else if (this.creditLimitBiWeeklyPlus7 < 8000) {
            	if (this.sourceObject.Zahlungsziel_2__c == '7' && this.sourceObject.Rechnungsperiode_2__c == '7') {
            		this.billingPeriod = 7;
            		this.paymentTerms = 7;
            	} else {
            		this.billingPeriod = 15;
        			this.paymentTerms = 7;
        		}
            } else if (this.creditLimitWeeklyPlus7 < 8000) {
            	this.billingPeriod = 7;
            	this.paymentTerms = 7;
            }
		} catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Payment details for Rating 2 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}
	}


	/*******************************************************************************
	*  Name            : setPaymentDetailsRating3()
	*  Summary         : Calculate payment details (billing period, payment terms) for rating 3   
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setPaymentDetailsRating3() {
		try {
            if (this.creditLimitMonthlyPlus7 < 8000) {
            	if (this.sourceObject.Zahlungsziel_2__c == '7' && this.sourceObject.Rechnungsperiode_2__c == '7') {
            		this.billingPeriod = 7;
            		this.paymentTerms = 7;
            	} else if (this.sourceObject.Zahlungsziel_2__c == '15' && this.sourceObject.Rechnungsperiode_2__c == '7') {
            		this.billingPeriod = 15;
            		this.paymentTerms = 7;
            	} else if (this.sourceObject.Zahlungsziel_2__c == '15' && this.sourceObject.Rechnungsperiode_2__c == '14' && this.userSource != 'E2E Long Form') {
            		this.billingPeriod = 15;
            		this.paymentTerms = 14;
            	} else {
            		this.billingPeriod = 30;
            		this.paymentTerms = 7;
            	}
            } else if (this.creditLimitBiWeeklyPlus14 < 8000 && this.userSource != 'E2E Long Form') {
            	if (this.sourceObject.Zahlungsziel_2__c == '7' && this.sourceObject.Rechnungsperiode_2__c == '7') {
            		this.billingPeriod = 7;
            		this.paymentTerms = 7;
            	} else if (this.sourceObject.Zahlungsziel_2__c == '15' && this.sourceObject.Rechnungsperiode_2__c == '7') {
            		this.billingPeriod = 15;
            		this.paymentTerms = 7;
            	} else {
            		this.billingPeriod = 15;
            		this.paymentTerms = 14;
            	}
            } else if (this.creditLimitBiWeeklyPlus7 < 8000) {
            	if (this.sourceObject.Zahlungsziel_2__c == '7' && this.sourceObject.Rechnungsperiode_2__c == '7') {
            		this.billingPeriod = 7;
            		this.paymentTerms = 7;
            	} else {
            		this.billingPeriod = 15;
        			this.paymentTerms = 7;
        		}
            } else if (this.creditLimitWeeklyPlus7 < 8000) {
            	this.billingPeriod = 7;
            	this.paymentTerms = 7;
            }
		} catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Payment details for Rating 3 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}
	}


	/*******************************************************************************
	*  Name            : setPaymentDetailsRating4()
	*  Summary         : Calculate payment details (billing period, payment terms) for rating 4
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setPaymentDetailsRating4() {
		try {
            if (this.creditLimitMonthlyPlus7 < 8000 && this.depositMonthlyPlus7 == 0) {
            	if (this.sourceObject.Zahlungsziel_2__c == '7' && this.sourceObject.Rechnungsperiode_2__c == '7') {
            		this.billingPeriod = 7;
            		this.paymentTerms = 7;
            	} else if (this.sourceObject.Zahlungsziel_2__c == '15' && this.sourceObject.Rechnungsperiode_2__c == '7') {
            		this.billingPeriod = 15;
            		this.paymentTerms = 7;
            	} else if (this.sourceObject.Zahlungsziel_2__c == '15' && this.sourceObject.Rechnungsperiode_2__c == '14' && this.userSource != 'E2E Long Form') {
            		this.billingPeriod = 15;
            		this.paymentTerms = 14;
            	} else {
            		this.billingPeriod = 30;
            		this.paymentTerms = 7;
            	}
            } else if (this.creditLimitBiWeeklyPlus14 < 8000 && this.depositBiWeeklyPlus14 == 0 && this.userSource != 'E2E Long Form') {
            	if (this.sourceObject.Zahlungsziel_2__c == '7' && this.sourceObject.Rechnungsperiode_2__c == '7') {
            		this.billingPeriod = 7;
            		this.paymentTerms = 7;
            	} else if (this.sourceObject.Zahlungsziel_2__c == '15' && this.sourceObject.Rechnungsperiode_2__c == '7') {
            		this.billingPeriod = 15;
            		this.paymentTerms = 7;
            	} else {
            		this.billingPeriod = 15;
            		this.paymentTerms = 14;
            	}
            } else if (this.creditLimitBiWeeklyPlus7 < 8000 && this.depositBiWeeklyPlus7 == 0) {
        		if (this.sourceObject.Zahlungsziel_2__c == '7' && this.sourceObject.Rechnungsperiode_2__c == '7') {
            		this.billingPeriod = 7;
            		this.paymentTerms = 7;
            	} else {
            		this.billingPeriod = 15;
	        		this.paymentTerms = 7;
	        	}
            } else if (this.creditLimitWeeklyPlus7 < 8000 && this.depositBiWeeklyPlus7 == 0) {
        		this.billingPeriod = 7;
        		this.paymentTerms = 7;
            } else if (this.creditLimitMonthlyPlus7 < 8000) {
            	if (this.sourceObject.Zahlungsziel_2__c == '7' && this.sourceObject.Rechnungsperiode_2__c == '7') {
            		this.billingPeriod = 7;
            		this.paymentTerms = 7;
            	} else if (this.sourceObject.Zahlungsziel_2__c == '15' && this.sourceObject.Rechnungsperiode_2__c == '7') {
            		this.billingPeriod = 15;
            		this.paymentTerms = 7;
            	} else if (this.sourceObject.Zahlungsziel_2__c == '15' && this.sourceObject.Rechnungsperiode_2__c == '14' && this.userSource != 'E2E Long Form') {
            		this.billingPeriod = 15;
            		this.paymentTerms = 14;
            	} else {
            		this.billingPeriod = 30;
            		this.paymentTerms = 7;
            	}
            } else if (this.creditLimitBiWeeklyPlus14 < 8000 && this.userSource != 'E2E Long Form') {
            	if (this.sourceObject.Zahlungsziel_2__c == '7' && this.sourceObject.Rechnungsperiode_2__c == '7') {
            		this.billingPeriod = 7;
            		this.paymentTerms = 7;
            	} else if (this.sourceObject.Zahlungsziel_2__c == '15' && this.sourceObject.Rechnungsperiode_2__c == '7') {
            		this.billingPeriod = 15;
            		this.paymentTerms = 7;
            	} else {
            		this.billingPeriod = 15;
            		this.paymentTerms = 14;
            	}
            } else if (this.creditLimitBiWeeklyPlus7 < 8000) {
        		if (this.sourceObject.Zahlungsziel_2__c == '7' && this.sourceObject.Rechnungsperiode_2__c == '7') {
            		this.billingPeriod = 7;
            		this.paymentTerms = 7;
            	} else {
            		this.billingPeriod = 15;
	        		this.paymentTerms = 7;
	        	}
        	} else if (this.creditLimitWeeklyPlus7 < 8000) {
        		this.billingPeriod = 7;
        		this.paymentTerms = 7;
        	}
		} catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Payment details for Rating 4 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}
	}


	/*******************************************************************************
	*  Name            : setPaymentDetailsRating5()
	*  Summary         : Calculate payment details (billing period, payment terms) for rating 5
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setPaymentDetailsRating5() {
		try {
			if (this.creditLimitMonthlyPlus7 < 8000) {
            	if (this.sourceObject.Zahlungsziel_2__c == '7' && this.sourceObject.Rechnungsperiode_2__c == '7') {
            		this.billingPeriod = 7;
            		this.paymentTerms = 7;
            	} else if (this.sourceObject.Zahlungsziel_2__c == '15' && this.sourceObject.Rechnungsperiode_2__c == '7') {
            		this.billingPeriod = 15;
            		this.paymentTerms = 7;
            	} else if (this.sourceObject.Zahlungsziel_2__c == '15' && this.sourceObject.Rechnungsperiode_2__c == '14' && this.userSource != 'E2E Long Form') {
            		this.billingPeriod = 15;
            		this.paymentTerms = 14;
            	} else {
            		this.billingPeriod = 30;
            		this.paymentTerms = 7;
            	}
            } else if (this.creditLimitBiWeeklyPlus14 < 8000 && this.userSource != 'E2E Long Form') {
            	if (this.sourceObject.Zahlungsziel_2__c == '7' && this.sourceObject.Rechnungsperiode_2__c == '7') {
            		this.billingPeriod = 7;
            		this.paymentTerms = 7;
            	} else if (this.sourceObject.Zahlungsziel_2__c == '15' && this.sourceObject.Rechnungsperiode_2__c == '7') {
            		this.billingPeriod = 15;
            		this.paymentTerms = 7;
            	} else {
            		this.billingPeriod = 15;
            		this.paymentTerms = 14;
            	}
            } else if (this.creditLimitBiWeeklyPlus7 < 8000) {
        		if (this.sourceObject.Zahlungsziel_2__c == '7' && this.sourceObject.Rechnungsperiode_2__c == '7') {
            		this.billingPeriod = 7;
            		this.paymentTerms = 7;
            	} else {
            		this.billingPeriod = 15;
	        		this.paymentTerms = 7;
	        	}
        	} else if (this.creditLimitWeeklyPlus7 < 8000) {
        		this.billingPeriod = 7;
        		this.paymentTerms = 7;
        	}
		} catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Payment details for Rating 5 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}
	}


	/*******************************************************************************
	*  Name            : setPaymentDetailsRating6()
	*  Summary         : Calculate payment details (billing period, payment terms) for rating 6
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setPaymentDetailsRating6() {
		try {
			if (this.creditLimitMonthlyPlus7 < 8000) {
            	if (this.sourceObject.Zahlungsziel_2__c == '7' && this.sourceObject.Rechnungsperiode_2__c == '7') {
            		this.billingPeriod = 7;
            		this.paymentTerms = 7;
            	} else if (this.sourceObject.Zahlungsziel_2__c == '15' && this.sourceObject.Rechnungsperiode_2__c == '7') {
            		this.billingPeriod = 15;
            		this.paymentTerms = 7;
            	} else if (this.sourceObject.Zahlungsziel_2__c == '15' && this.sourceObject.Rechnungsperiode_2__c == '14' && this.userSource != 'E2E Long Form') {
            		this.billingPeriod = 15;
            		this.paymentTerms = 14;
            	} else {
            		this.billingPeriod = 30;
            		this.paymentTerms = 7;
            	}
            } else if (this.creditLimitBiWeeklyPlus14 < 8000 && this.userSource != 'E2E Long Form') {
            	if (this.sourceObject.Zahlungsziel_2__c == '7' && this.sourceObject.Rechnungsperiode_2__c == '7') {
            		this.billingPeriod = 7;
            		this.paymentTerms = 7;
            	} else if (this.sourceObject.Zahlungsziel_2__c == '15' && this.sourceObject.Rechnungsperiode_2__c == '7') {
            		this.billingPeriod = 15;
            		this.paymentTerms = 7;
            	} else {
            		this.billingPeriod = 15;
            		this.paymentTerms = 14;
            	}
            } else if (this.creditLimitBiWeeklyPlus7 < 8000) {
            	if (this.sourceObject.Zahlungsziel_2__c == '7' && this.sourceObject.Rechnungsperiode_2__c == '7') {
            		this.billingPeriod = 7;
            		this.paymentTerms = 7;
            	} else {
            		this.billingPeriod = 15;
        			this.paymentTerms = 7;
        		}
            } else if (this.creditLimitWeeklyPlus7 < 8000) {
            	this.billingPeriod = 7;
            	this.paymentTerms = 7;
            }
		} catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Payment details for Rating 6 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}
	}


	/*******************************************************************************
	*  Name            : setPaymentDetailsNoRating()
	*  Summary         : Calculate payment details (billing period, payment terms) for no rating
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setPaymentDetailsNoRating() {
		try {
			if (this.creditLimitMonthlyPlus7 < 8000) {
            	if (this.sourceObject.Zahlungsziel_2__c == '7' && this.sourceObject.Rechnungsperiode_2__c == '7') {
            		this.billingPeriod = 7;
            		this.paymentTerms = 7;
            	} else if (this.sourceObject.Zahlungsziel_2__c == '15' && this.sourceObject.Rechnungsperiode_2__c == '7') {
            		this.billingPeriod = 15;
            		this.paymentTerms = 7;
            	} else if (this.sourceObject.Zahlungsziel_2__c == '15' && this.sourceObject.Rechnungsperiode_2__c == '14' && this.userSource != 'E2E Long Form') {
            		this.billingPeriod = 15;
            		this.paymentTerms = 14;
            	} else {
            		this.billingPeriod = 30;
            		this.paymentTerms = 7;
            	}
            } else if (this.creditLimitBiWeeklyPlus14 < 8000 && this.userSource != 'E2E Long Form') {
            	if (this.sourceObject.Zahlungsziel_2__c == '7' && this.sourceObject.Rechnungsperiode_2__c == '7') {
            		this.billingPeriod = 7;
            		this.paymentTerms = 7;
            	} else if (this.sourceObject.Zahlungsziel_2__c == '15' && this.sourceObject.Rechnungsperiode_2__c == '7') {
            		this.billingPeriod = 15;
            		this.paymentTerms = 7;
            	} else {
            		this.billingPeriod = 15;
            		this.paymentTerms = 14;
            	}
            } else if (this.creditLimitBiWeeklyPlus7 < 8000) {
        		if (this.sourceObject.Zahlungsziel_2__c == '7' && this.sourceObject.Rechnungsperiode_2__c == '7') {
            		this.billingPeriod = 7;
            		this.paymentTerms = 7;
            	} else {
            		this.billingPeriod = 15;
	        		this.paymentTerms = 7;
	        	}
        	} else if (this.creditLimitWeeklyPlus7 < 8000) {
        		this.billingPeriod = 7;
        		this.paymentTerms = 7;
        	}
		} catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Payment details for No Rating calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}
	}


	/*******************************************************************************
	*  Name 		   : getBillingPeriod
	*  Summary         : Return billing period
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : Integer
	******************************************************************************/
	public Integer getBillingPeriod() {
		return this.billingPeriod;
	}


	/*******************************************************************************
	*  Name            : getPaymentTerms()
	*  Summary         : Return payment terms.  
	*  CreatedDate     : 13/11/2018
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
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void setCreditLimit() {
		try {
			Decimal recommendedCreditLimit = 0;
		if (this.company.creditLimit != null && this.company.creditLimit.isNumeric()) {
            recommendedCreditLimit = Decimal.valueOf(this.company.creditLimit);
        }
		    if (this.billingPeriod == 30 && this.paymentTerms == 7) {
		    	this.creditLimit = this.creditLimitMonthlyPlus7;
		    	if (this.creditLimit < 700 && recommendedCreditLimit > 1000 && this.creditLimit * 1.5 <= this.maxCreditLimitMonthlyPlus7 && this.depositMonthlyPlus7 == 0) {
					this.creditLimit = this.creditLimit * 1.5;
				}
		    } else if (this.billingPeriod == 15 && this.paymentTerms == 14) {
		    	this.creditLimit = this.creditLimitBiWeeklyPlus14;
		    	if (this.creditLimit < 700 && recommendedCreditLimit > 1000 && this.creditLimit * 1.5 <= this.maxCreditLimitBiWeeklyPlus14 && this.depositBiWeeklyPlus14 == 0) {
					this.creditLimit = this.creditLimit * 1.5;
				}
		    } else if (this.billingPeriod == 15 && this.paymentTerms == 7) {
		    	this.creditLimit = this.creditLimitBiWeeklyPlus7;
		    	if (this.creditLimit < 700 && recommendedCreditLimit > 1000 && this.creditLimit * 1.5 <= this.maxCreditLimitBiWeeklyPlus7 && this.depositBiWeeklyPlus7 == 0) {
					this.creditLimit = this.creditLimit * 1.5;
				}
		    } else if (this.billingPeriod == 7 && this.paymentTerms == 7) {
		    	this.creditLimit = this.creditLimitWeeklyPlus7;
		    	if (this.creditLimit < 700 && recommendedCreditLimit > 1000 && this.creditLimit * 1.5 <= this.maxCreditLimitWeeklyPlus7 && this.depositWeeklyPlus7 == 0) {
					this.creditLimit = this.creditLimit * 1.5;
				}
		    }

		    if (this.creditLimit != null) {
		    	if (this.creditLimit < 50) {
					this.creditLimit = this.creditLimit + 50;
				}

				this.creditLimit = (this.creditLimit / 100).round(System.RoundingMode.HALF_UP) * 100;
			}
		} catch (Exception e) {
		    System.debug('DEBUG: Credit Factory === ' + e.getMessage());
		    throw new CreditFactoryException('Credit Limit calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}
	}


	/*******************************************************************************
	*  Name            : getCreditLimit()
	*  Summary         : Return Credit Limit    
	*  CreatedDate     : 13/11/2018
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
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void setMaxCreditLimit() {
		try {
			if (this.billingPeriod == 30 && this.paymentTerms == 7) {
				this.maxCreditLimit = getMaxCreditLimitMonthlyPlus7();
			} else if (this.billingPeriod == 15 && this.paymentTerms == 14) {
				this.maxCreditLimit = getMaxCreditLimitBiWeeklyPlus14();
			} else if (this.billingPeriod == 15 && this.paymentTerms == 7) {
				this.maxCreditLimit = getMaxCreditLimitBiWeeklyPlus7();
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
	*  CreatedDate     : 13/11/2018
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
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : Decimal
	******************************************************************************/
	public void setMaxValue() {
		try {
		    if (this.billingPeriod == 30 && this.paymentTerms == 7) {
		    	this.maxValue = getMaxValueMonthlyPlus7();
		    } else if (this.billingPeriod == 15 && this.paymentTerms == 7) {
		    	this.maxValue = getMaxValueBiWeeklyPlus7();
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
	*  CreatedDate     : 09/04/2018
	*  ModifiedDate    : 09/04/2018
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
	*  ModifiedDate    : 07/03/2018
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void setDeposit() {
		try {
            if (this.billingPeriod == 30 && this.paymentTerms == 7) {
            	this.deposit = getDepositMonthlyPlus7();
			} else if (this.billingPeriod == 15 && this.paymentTerms == 14) {
				this.deposit = getDepositBiWeeklyPlus14(); 
			} else if (this.billingPeriod == 15 && this.paymentTerms == 7) {
				this.deposit = getDepositBiWeeklyPlus7();
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
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : CreditCompany company - company from Credit System, 
						 Integer billingPeriod - selected billing period, 
						 Integer Integer paymentTerms - selected payment terms,
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
	                SELECT Credit_Limit_Weekly_7__c, Credit_Limit_Bi_Weekly_7__c, Credit_Limit_Monthly_7__c, 
	                	Deposit_Weekly_7__c, Deposit_Bi_Weekly_7__c, Deposit_Monthly_7__c
	                FROM Credit_Factory_Report__c
	                WHERE Opportunity__c = :opportunityId AND CreatedDate > :Date.today().addMonths(-3)
	                ORDER BY CreatedDate DESC
	                LIMIT 1];
	        if (! creditReportsList.isEmpty() && billingPeriod == 30 && creditLimit == creditReportsList.get(0).Credit_Limit_Monthly_7__c) {
	        	this.deposit = creditReportsList.get(0).Deposit_Monthly_7__c;
	        } else if (! creditReportsList.isEmpty() && billingPeriod == 15 && creditLimit == creditReportsList.get(0).Credit_Limit_Bi_Weekly_7__c) {
	        	this.deposit = creditReportsList.get(0).Deposit_Bi_Weekly_7__c;
	        } else if (! creditReportsList.isEmpty() && billingPeriod == 7 && creditLimit == creditReportsList.get(0).Credit_Limit_Weekly_7__c) {
	        	this.deposit = creditReportsList.get(0).Deposit_Weekly_7__c;
	        } else if (company.classRating == '1') {
				this.deposit = resetDepositRating1();
			} else if (company.classRating == '2') {
				this.deposit = resetDepositRating2();
			} else if (company.classRating == '3') {
				this.deposit = resetDepositRating3();
			} else if (company.classRating == '4') {
				this.deposit = resetDepositRating4(creditLimit, maxCreditLimit);
			} else if (company.classRating == '5') {
				this.deposit = resetDepositRating5(company, creditLimit, maxCreditLimit);
			} else if (company.classRating == '6') {
				this.deposit = resetDepositRating6(billingPeriod, creditLimit);
			} else if (company.classRating == null) {
				this.deposit = resetDepositNoRating(totalConsumption, company, creditLimit, maxCreditLimit);
			}
		} catch (Exception e) {
			System.debug('Credit Factory === ' + e.getMessage());
			throw new CreditFactoryException('Deposit recalculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}
	}

	/*******************************************************************************
	*  Name            : resetDepositRating1()
	*  Summary         : Reset deposit value for rating 1 and changed CL value.     
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : Decimal
	******************************************************************************/
	private Decimal resetDepositRating1() {
		return 0;
	}


	/*******************************************************************************
	*  Name            : resetDepositRating2()
	*  Summary         : Reset deposit value for rating 2 and changed CL value.
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : Decimal
	******************************************************************************/
	private Decimal resetDepositRating2() {
		return 0;
	}


	/*******************************************************************************
	*  Name            : resetDepositRating3()
	*  Summary         : Reset deposit value for rating 3 and changed CL value. 
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : Decimal
	******************************************************************************/
	private Decimal resetDepositRating3() {
		return 0;
	}


	/*******************************************************************************
	*  Name            : resetDepositRating4(Decimal creditLimit, Decimal maxCreditLimit)
	*  Summary         : Reset deposit value for rating 4 and changed CL value.
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : Decimal maxCreditLimit - max Credit Limit for selected billing period
	*  Returns         : Decimal
	******************************************************************************/
	private Decimal resetDepositRating4(Decimal creditLimit, Decimal maxCreditLimit) {
		if (creditLimit <= maxCreditLimit) {
			return 0;
		} else {
			return ((creditLimit - maxCreditLimit + 500) / 100).round(System.RoundingMode.HALF_UP) * 100;
		}
	}


	/*******************************************************************************
	*  Name            : resetDepositRating5(CreditCompany company, Decimal creditLimit)
	*  Summary         : Reset deposit value for rating 5 and changed CL value.   
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : CreditCompany company - company from Credit System, Decimal creditLimit - changed CL value,
						 Decimal maxCreditLimit - max Credit Limit for selected billing period
	*  Returns         : Decimal
	******************************************************************************/
	private Decimal resetDepositRating5(CreditCompany company, Decimal creditLimit, Decimal maxCreditLimit) {
		return (creditLimit * 0.7 / 100).round(System.RoundingMode.HALF_UP) * 100;
	}


	/*******************************************************************************
	*  Name            : resetDepositRating6(CreditCompany company, Integer billingPeriod, Decimal monthlyVolume)
	*  Summary         : Reset deposit value for rating 6 and changed CL value     
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : Integer billingPeriod - selected billing period,  
						 Decimal creditLimit - changed CL value,
	*  Returns         : Decimal
	******************************************************************************/
	private Decimal resetDepositRating6(Integer billingPeriod, Decimal creditLimit) {
		return ((creditLimit * (billingPeriod + 7.0 + 10.0) / (billingPeriod + 7.0)) / 100).round(System.RoundingMode.HALF_UP) * 100;
	}


	/*******************************************************************************
	*  Name            : resetDepositNoRating(Decimal creditLimit)
	*  Summary         : Reset deposit value for no rating and changed CL value     
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : Decimal totalConsumption - total consumption of liters, 
						 CreditCompany company - company from Credit System,
						 Decimal creditLimit - changed CL value,
						 Decimal maxCreditLimit - max Credit Limit for selected billing period
	*  Returns         : Decimal
	******************************************************************************/
	private Decimal resetDepositNoRating(Decimal totalConsumption, CreditCompany company, Decimal creditLimit, Decimal maxCreditLimit) {
		return (creditLimit / 100).round(System.RoundingMode.HALF_UP) * 100;
	}


	/*******************************************************************************
	*  Name            : getDeposit()
	*  Summary         : Return deposit.    
	*  CreatedDate     : 13/11/2018
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
	*  CreatedDate     : 13/11/2018
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
				if (this.company.classRating == '5') {
					this.decision.statusCode = '006'; // Payment Method "Bank Transfer" and Number of Cards > 3 are not available options
				} else if (this.company.classRating == null) {
					this.decision.statusCode = '007'; // Number of Cards > 3 is not available option
				} else {
					this.decision.statusCode = '001'; // No Limits
				}
			} else if (this.billingPeriod != null && this.paymentTerms != null && this.deposit != 0) {
				// Positive Decisions with deposit
				this.decision.verdict = 'Yes';
				if (this.company.classRating == '5' || this.company.classRating == null) {
					this.decision.statusCode = '010'; // Number of Cards < 3 is not available option
				} else {
					this.decision.statusCode = '002'; // No Limits
				}
			} else {
				// Negative Decisions
				this.decision.verdict = 'No';
            	this.decision.statusCode = '003';
			}

			if (this.userSource != 'E2E Long Form') {
				if (! errorsSet.contains(CONTACT_ERROR)) {
					if (this.decision.statusCode == '001' || this.decision.statusCode == '004' || this.decision.statusCode == '005' || this.decision.statusCode == '006' || this.decision.statusCode == '007') {
						// validate mandate type before final decision
                        if (! validateMandateType()) {
                            throw new CreditFactoryException('DD Core is not available for high-risk Customers with total consumption higher than 1500 l/month. ' + 
                                'Please change the Mandate Type to B2B and send SEPA Approval form.');
                        }
						CreditFactoryUtilities.displayMessage('info','Billing Period can be set to ' + this.billingPeriod);
		            	CreditFactoryUtilities.displayMessage('info','Payment Terms can be set to ' + this.paymentTerms);
					} else if (this.decision.statusCode == '002' || this.decision.statusCode == '008' || this.decision.statusCode == '009' || this.decision.statusCode == '010') {
						if (! errorsSet.contains(PUBLIC_ENTITY_ERROR)) {
							changeToPendingDeposit();
						}
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
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : 22/12/2018
	*  Parameters      : Integer billingPeriod - selected billing period, Integer paymentTerms - selected payment terms, 
						 Decimal deposit - selected deposit, String classRating - current company class rating, Integer numberOfCards - number of cards,
						 CreditCompany company - company from Credit System
	*  Returns         : void
	******************************************************************************/
	public void resetDecision(Integer billingPeriod, Integer paymentTerms, Decimal deposit, String classRating, Decimal numberOfCards, CreditCompany company) {
		try {
			this.decision = new CreditFactoryDecision();
			// Positive Decisions
			this.decision.verdict = 'Yes';
			if (deposit == 0) {
				// Decisions without deposit
				if (classRating == '5') {
					this.decision.statusCode = '006'; // Payment Method "Bank Transfer" and Number of Cards > 3 are not available options, Max Value should be updated
				} else if (classRating == null) {
					this.decision.statusCode = '007'; // Number of Cards > 3 is not available option, Max Value should be updated
				} else {
					this.decision.statusCode = '001'; // No Limits, Max Value should be updated
				}
			} else {
				// Decisions with deposit
				if ((classRating == '5' || classRating == null) && numberOfCards >= 3) {
					this.decision.statusCode = '010'; // Number of Cards < 3 is not available option
				} else {
					this.decision.statusCode = '002'; // No Limits, Max Value should be set
				}
			}
		} catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Reset Decision failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}
	}


	/*******************************************************************************
	*  Name            : getDecision()
	*  Summary         : Return decision.    
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : CreditFactoryDecision
	******************************************************************************/
	public CreditFactoryDecision getDecision() {
		return this.decision;
	}


	/*******************************************************************************
	*  Name            : checkWarnings()
	*  Summary         : Сheck for warnings to display on page.
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
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
	*  Summary         : Сompare calculated and desired payment terms.
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
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
	*  Summary         : Сompare calculated and desired billing period.  
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
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
	*  Summary         : Save information from Credit system to Salesforce.  
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : 08/01/2019
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void saveReports() {
		if (this.existingCreditReport == null && this.company != null) {
			// insert
			String reportName = company.name;
	        if (reportName.length() > 80) {
	            reportName = reportName.substring(0,80);
	        }
			Credit_Factory_Report__c newReport = new Credit_Factory_Report__c(
	            Credit_System_Number__c = this.company.creditSystemCompanyNumber,
	            Age_of_Company__c = this.company.ageofcompany,
	            City__c = this.company.city,
	            Company_Status__c = this.company.status,
	            Country__c = this.company.country,
	            County_Court__c = this.company.countyCourt,
	            Credit_Decision__c = this.company.creditDecision,
	            Credit_Limit__c = this.company.creditLimit,
	            Date_Last_Register_Entry__c = this.company.datelastregisterentry,
	            Date_Legal_Form__c = this.company.datelegalform,
	            Date_of_Foundation__c = this.company.dateoffoundation,
	            Email__c = this.company.email,
	            Fax__c = this.company.fax,
	            First_Legal_Form__c = this.company.firstlegalform,
	            Fiscal_Number__c = this.company.taxnumber,
	            Housenumber__c = this.company.housenumber,
	            Legal_Form__c = this.company.legalform,
	            Mobile__c = this.company.mobile,
	            Opportunity__c = sourceObject.Id,
	            Payment_Behaviour__c = this.company.paymentBehaviour,
	            Phone__c = this.company.phone,
	            Postcode__c = this.company.postcode,
	            Reference_Number__c = this.company.referencenumber,
	            Register_Number__c = this.company.registerNumber,
	            Staff_Range__c = this.company.staffcompanyrange,
	            Street__c = this.company.street,
	            Trade_Name__c = this.company.tradename,
	            Turn_Over__c = this.company.turnOver,
	            VAT_Number__c = this.company.vatid,
	            Tax_Id__c = this.company.taxnumber,
	            Website__c = this.company.website,
	            Name = reportName,
	            Company_Id__c = this.company.identificationnumber,
	            Solvency_Index__c = this.company.solvencyIndex,
	            Name__c = this.company.name);

				if (this.userSource == 'E2E Long Form') {
					newReport.Billing_Period__c = this.billingPeriod;
		            newReport.Credit_Limit_Default__c = getCreditLimit();
		            newReport.Credit_Limit_Weekly_7__c = getCreditLimitWeeklyPlus7();
		            newReport.Credit_Limit_Bi_Weekly_7__c = getCreditLimitBiWeeklyPlus7();
		            newReport.Credit_Limit_Monthly_7__c = getCreditLimitMonthlyPlus7();
					newReport.Max_Credit_Limit_Weekly_7__c = getMaxCreditLimitWeeklyPlus7();
					newReport.Max_Credit_Limit_Bi_Weekly_7__c = getMaxCreditLimitBiWeeklyPlus7();
					newReport.Max_Credit_Limit_Monthly_7__c = getMaxCreditLimitMonthlyPlus7();
					newReport.Max_Value_Weekly_7__c = getMaxValueWeeklyPlus7();
					newReport.Max_Value_Bi_Weekly_7__c = getMaxValueBiWeeklyPlus7();
					newReport.Max_Value_Monthly_7__c = getMaxValueMonthlyPlus7();
					newReport.Deposit_Weekly_7__c = getDepositWeeklyPlus7();
					newReport.Deposit_Bi_Weekly_7__c = getDepositBiWeeklyPlus7();
					newReport.Deposit_Monthly_7__c = getDepositMonthlyPlus7();
					newReport.Decision_Verdict__c = this.decision.verdict;
					newReport.Decision_Status_Code__c = this.decision.statusCode;
				}

	        if (company.classRating != null) {
	            newReport.Class_Rating__c = this.company.classRating;
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
		            Credit_Limit_Default__c = getCreditLimit(),
		            Credit_Limit_Weekly_7__c = getCreditLimitWeeklyPlus7(),
		            Credit_Limit_Bi_Weekly_7__c = getCreditLimitBiWeeklyPlus7(),
		            Credit_Limit_Monthly_7__c = getCreditLimitMonthlyPlus7(),
					Max_Credit_Limit_Weekly_7__c = getMaxCreditLimitWeeklyPlus7(),
					Max_Credit_Limit_Bi_Weekly_7__c = getMaxCreditLimitBiWeeklyPlus7(),
					Max_Credit_Limit_Monthly_7__c = getMaxCreditLimitMonthlyPlus7(),
					Max_Value_Weekly_7__c = getMaxValueWeeklyPlus7(),
					Max_Value_Bi_Weekly_7__c = getMaxValueBiWeeklyPlus7(),
					Max_Value_Monthly_7__c = getMaxValueMonthlyPlus7(),
					Deposit_Weekly_7__c = getDepositWeeklyPlus7(),
					Deposit_Bi_Weekly_7__c = getDepositBiWeeklyPlus7(),
					Deposit_Monthly_7__c = getDepositMonthlyPlus7(),
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
	*  Name 		   : updateOpportunityByCredit()
	*  Summary         : update opportunity with button by Credit
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : 
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
        if (this.company.solvencyIndex != null) {
	    	this.sourceObject.Bonitaetsindex__c = this.company.solvencyIndex;
	    }
        this.sourceObject.put(this.opportunityMapping.Number_of_employees__c,company.staffcompanyrange);
        this.sourceObject.put(this.opportunityMapping.Credit_check_date__c,Date.today());
        this.sourceObject.put(this.opportunityMapping.Credit_System_Number__c,this.company.creditSystemCompanyNumber);
        if (this.company.dateoffoundation != null) {
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
	*  CreatedDate     : 13/11/2018
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

		    if (this.company.classRating == null) {
			    this.sourceObject.put(this.opportunityMapping.Credit_System_Rating__c, '0-EX');
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
	*  Summary         : Update Opportunity field "PDF created".
	*  CreatedDate     : 13/11/2018
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
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : opportunityId - source record Salesforce id
	*  Returns         : Boolean - true if report attached to opportunity
	******************************************************************************/
	public Boolean doCreateReportAttachment(String opportunityId) {
        if (this.attachmentBody != null) {
            try {
                Attachment creforeport = new Attachment(
                    ParentId = opportunityId,
                    Name = 'CrefoReport.pdf',
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
	*  Name 		   : doPrepareBodyForAttachment(HttpResponse response)
	*  Summary         : Get pdf from reponse 
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
	*  Parameters      : response - response from request for report
	*  Returns         : Blob - body of PDF report
	******************************************************************************/
	public Blob doPrepareBodyForAttachment(HttpResponse response) {
		try {
			Blob blobBody = response.getBodyAsBlob();
	        String blobBodyHex = EncodingUtil.convertToHex(blobBody);
	        String blobPdfHex = blobBodyHex.substringBetween('25504446','2525454f46');
	        Blob blobPdf;
	        if (blobPdfHex != null) {
	            blobPdfHex = '25504446' + blobPdfHex + '2525454f46';
	            blobPdf = EncodingUtil.convertFromHex(blobPdfHex);
	            return blobPdf;
	        }
	        return null;	
		} catch (Exception e) {
    		System.debug('Credit Factory Attachment Error === ' + e.getMessage());
    		return null;
		}
	}


	/*******************************************************************************
	*  Name            : isPendingSEPAPossible()
	*  Summary         : check possibility to automatically change Stage to Pending Sales - SEPA Confirmation    
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : 03/04/2019
	*  Parameters      : -
	*  Returns         : Boolean
	******************************************************************************/
	public Boolean isPendingSEPAPossible() {
		if (this.sourceObject.get(this.opportunityMapping.Payment_Method__c) == 'Lastschrift' && this.sourceObject.SEPA_Request_Approved__c == false && 
				this.sourceObject.Einwilligung_Lastschriftverfahren__c == false && validateMandateType()) {
			return true;
		} else {
			return false;
		}
	}


	/*******************************************************************************
	*  Name            : isAutoCWPossible()
	*  Summary         : check possibility to automatically change Stage to Closed Won     
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : 03/04/2019
	*  Parameters      : -
	*  Returns         : Boolean
	******************************************************************************/
	public Boolean isAutoCWPossible() {
		if (this.sourceObject.get(this.opportunityMapping.Payment_Method__c) == 'Lastschrift' && 
				((this.sourceObject.Send_SEPA_approval_link__c == true && this.sourceObject.SEPA_Request_Approved__c == true) || 
				this.sourceObject.SEPA_Request_Approved__c == false && this.sourceObject.Einwilligung_Lastschriftverfahren__c == true) && validateMandateType()) {
			return true;
		} else {
			return false;
		}
	}


	/*******************************************************************************
	*  Name            : changeToPendingSEPAConfirmation()
	*  Summary         : Change Opportunity StageName to Pending Sales - SEPA Confirmation
	*  CreatedDate     : 13/11/2018
    *  ModifiedDate    : -
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
	*  CreatedDate     : 13/11/2018
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
	        this.sourceObject.Probability = 100;
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
	*  Summary         : Сount number of Tankkarten__c objects related to the current Opportunity    
	*  CreatedDate     : 13/11/2018
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
	*  CreatedDate     : 13/11/2018
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
	    if (this.company.classRating == null) {
		    this.sourceObject.put(this.opportunityMapping.Credit_System_Rating__c, '0-EX');
		}
		this.sourceObject.Last_CF_Errors__c = null;
		this.sourceObject.Account.Gesellschaftsform__c = this.company.legalform;
	}


	/*******************************************************************************
    *  Name            : checkDuplicates()
    *  Summary         : if duplicates is existed then stop credit process    
    *  CreatedDate     : 13/11/2018
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
	*  CreatedDate     : 13/11/2018
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
	        if (this.company.classRating == null) {
			    this.sourceObject.put(this.opportunityMapping.Credit_System_Rating__c, 'Keine Bonität');
			}
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


	/*******************************************************************************
    *  Name            : validateMandateType()
    *  Summary         : Check that mandate type is set correctly   
    *  CreatedDate     : 03/04/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Boolean
    ******************************************************************************/
    public Boolean validateMandateType() {
    	if (this.riskCategory == null) setRiskCategory(this.company.classRating);
        if ((this.sourceObject.get(this.opportunityMapping.Payment_Method__c) == 'Lastschrift' && 
                this.sourceObject.Total_consumption_l_month__c > 1500 && this.riskCategory != 'Low' && this.sourceObject.Direct_Debit_Mandate_Type__c == 'Core')) {
            return false;
        }

        return true;
    }
}