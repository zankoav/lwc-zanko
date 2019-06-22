/*******************************************************************************
*  ReportCreditreformService 
*  
*  Implementation of CreditReport for Crif Webservice. Get company from webservice, validation, 
*  flows for Credit and Sales users.
*
******************************************************************************/
public class ReportCrifService implements CreditReport {
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
    private Decimal securityLevelWeeklyPlus7;
	private Decimal creditLimitBiWeeklyPlus7;
	private Decimal maxCreditLimitBiWeeklyPlus7;
    private Decimal maxValueBiWeeklyPlus7;
    private Decimal depositBiWeeklyPlus7;
    private Decimal securityLevelBiWeeklyPlus7;
	private Decimal creditLimitBiWeeklyPlus14;
    private Decimal maxCreditLimitBiWeeklyPlus14;
    private Decimal maxValueBiWeeklyPlus14;
    private Decimal depositBiWeeklyPlus14;
    private Decimal securityLevelBiWeeklyPlus14;
    private Integer billingPeriod;
    private Integer paymentTerms;
    private Decimal creditLimit;
    private Decimal maxCreditLimit;
    private Decimal maxValue;
    private Decimal deposit;
    private CreditFactoryDecision decision;
	private transient String xmlResponseBody;
	private transient Blob attachmentBody;
	private Set<String> errorsSet;
	private String creditSystemCompanyNumber;
	private Credit_Factory_Account__c accountMapping;
    private Credit_Factory_Opportunity__c opportunityMapping;
    private String COMPANY_FORM = CreditFactoryUtilities.returnLabelOfField('Account','Gesellschaftsform__c');
    private String TAX_ID = CreditFactoryUtilities.returnLabelOfField('Account','Steuernummer__c');
    private String TRADE_REGISTER_NUMBER = CreditFactoryUtilities.returnLabelOfField('Account','HR_Abteilung_HRA_HRB_und_HR_Nummer__c');
    public final String ADDRESS_ERROR = 'Address';
    public final String COMPANY_NAME_ERROR = 'CompanyName';
    public final String CONTACT_ERROR = 'Contact';
    public final String CONTACT_ROLE_ERROR = 'ContactRole';
    public final String REQUEST_STATUS_ERROR = 'RequestStatus';
    public final String OBLIGATION_OVERDUE_ERROR = 'ObligationOverdue';
    public final String AGE_OF_COMPANY_ERROR = 'AgeOfCompany';
    public final String TAX_ID_ERROR = 'TaxId';
    public final String TRADE_REGISTER_NUMBER_ERROR = 'TradeRegisterNumber';
    public final String LOST_OPPORTUNITY_ERROR = 'LostOpportunity';
    public Credit_Factory_Report__c existingCreditReport; 
    public Boolean isLostOpportunitiesExist;
    private String errorToRequestOrder;
    public String internalId;
    public String userSource;
    public Map<String, List<String>> currentPolicyRulesMap;
    public String policyRulesPriority;


    /*******************************************************************************
    *  Name            : setUserSource(String userSource)
    *  Summary         : set user source    
    *  CreatedDate     : 10/10/2018
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
    *  CreatedDate     : 10/10/2018
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
	*  CreatedDate     : 10/01/2018
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void setMapping() {
		try {
			this.accountMapping = Credit_Factory_Account__c.getInstance(CrifWebservice.CREDIT_SYSTEM_NAME);
			if (this.accountMapping == null) {
				throw new CreditFactoryException('Account mapping does not exist. ' + CreditFactoryUtilities.CONTACT_ADMIN);
			}
		} catch (Exception e) {
			throw new CreditFactoryException('Account mapping select error. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}

		try {
			this.opportunityMapping = Credit_Factory_Opportunity__c.getInstance(CrifWebservice.CREDIT_SYSTEM_NAME);
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
	*  CreatedDate     : 09/01/2018
	*  ModifiedDate    : 09/01/2018
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
					' Account.ShippingCity, RecordType.Name, Account.Name, Account.GFN_Nr__c, Account.BillingCountryCode, Account.HR_Abteilung_HRA_HRB_und_HR_Nummer__c, (SELECT ' +
					' Contact.Id, Contact.Email, Contact.Phone, ' + 
					' Contact.LastName, Contact.FirstName, Contact.Name, IsPrimary, Role FROM OpportunityContactRoles) ' +
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
	*  CreatedDate     : 09/01/2018
	*  ModifiedDate    : 09/01/2018
	*  Parameters      : 
	*  Returns         : sObject - Opportunity 
	******************************************************************************/
    public sObject getSourceObject() {
    	return this.sourceObject;
    }


    /*******************************************************************************
	*  Name 		   : setCompany()
	*  Summary         : Set Company information from xml response body
	*  CreatedDate     : 09/01/2018
	*  ModifiedDate    : 20/04/2018
	*  Parameters      : creditSystem - credit system, companyNip - parameter value from search page
	*  Returns         : void
	******************************************************************************/
	public void setCompany(CreditSystem creditSystem, String companyNip) {
		if (this.existingCreditReport != null) {
        	this.company = getExistingReportCompany();
        	setPolicyRulesPriority(this.company);
        } else {
			setXmlResponse(creditSystem, companyNip);
			String errorMessage;
	        try {
				String xml = this.xmlResponseBody;
		        Dom.Document domDoc = new Dom.Document();
		        domDoc.load(xml);
		        Dom.XMLNode xmldom = domDoc.getRootElement();
		        Dom.XMLNode reportDom = CrifWebservice.returnReportBody(xmldom);
		        String identificationType = CrifWebservice.returnIdentificationType(reportDom);
		        if (identificationType == 'NOT_IDENTIFIED') {
		        	this.errorToRequestOrder = 'Credit report is not available. Customer did not publish his company details. Please refer to Credit.';
		        	return;
		        }
		        String requestStatus = CrifWebservice.returnRequestStatus(reportDom);
		        if (requestStatus != 'OK') {
		        	this.errorToRequestOrder = 'Credit Factory report received with a system error.';
		        	this.internalId = CrifWebservice.returnTaxNumber(reportDom);
		        	return;
		        }

				this.company = CrifWebservice.returnReportCompany(reportDom, companyNip);
				setPolicyRulesPriority(this.company);

				// send pdf request asynchronously
				String schedule = datetime.now().addSeconds(5).second() + ' ' + datetime.now().addSeconds(5).minute() + ' ' + datetime.now().addSeconds(5).hour() + ' ' 
					+ datetime.now().addSeconds(5).day() + ' ' + datetime.now().addSeconds(5).month() + ' ? ' + datetime.now().addSeconds(5).year();
				String scheduleName = 'Crif Pdf attachment ' + datetime.now().addSeconds(5).minute() + datetime.now().addSeconds(5).second() + 
					datetime.now().addSeconds(5).millisecond();
		        CrifPdfSchedule crifPdfSchedule = new CrifPdfSchedule(creditSystem.getEndpointUrl(), creditSystem.getUserName(), creditSystem.getUserPassword(), 
		        	this.company.creditSystemCompanyNumber, this.sourceObject.Id);
		        System.schedule(scheduleName, schedule, crifPdfSchedule);
	        } catch (Exception e) {
				System.debug('Credit Factory === ' + e.getMessage());
				if (errorMessage == null) {
					errorMessage = 'Set company error. ' + CreditFactoryUtilities.CONTACT_ADMIN + '<br/>' + e.getMessage();
				}
	            throw new CreditFactoryException(errorMessage);
	        }
	    }
	}


	/*******************************************************************************
	*  Name            : setPolicyRulesPriority(CreditCompany company)
	*  Summary         : Set the worst policy rules priority.    
	*  CreatedDate     : 11/10/2018
	*  ModifiedDate    : -
	*  Parameters      : CreditCompany company - company from Crif
	*  Returns         : void
	******************************************************************************/
	private void setPolicyRulesPriority(CreditCompany company) {
		this.currentPolicyRulesMap = new Map<String, List<String>>();
		List<String> prioritiesList = new List<String>();
		if (company.numberOfHits != null) {
			for (String policyRule : company.policyRulesHits) {
				if (policyRulesMap.containsKey(policyRule)) {
					if (! this.currentPolicyRulesMap.containsKey(policyRulesMap.get(policyRule))) {
						this.currentPolicyRulesMap.put(policyRulesMap.get(policyRule), new List<String>());
						prioritiesList.add(policyRulesMap.get(policyRule));
					}

					this.currentPolicyRulesMap.get(policyRulesMap.get(policyRule)).add(policyRule);
				}
			}

			if (! this.currentPolicyRulesMap.isEmpty()) {
				prioritiesList.sort();
				this.policyRulesPriority = prioritiesList.get(0);
			}
		} 
	}


	/*******************************************************************************
	*  Name 		   : setXmlResponse(CreditSystem creditSystem, String companyNip)
	*  Summary         : Send request to Credit System to get company, employees and pdf report
	*  CreatedDate     : 09/01/2018
	*  ModifiedDate    : 09/01/2018
	*  Parameters      : creditSystem - credit system, companyNip - parameter value from search page
	*  Returns         : 
	******************************************************************************/
    public void setXmlResponse(CreditSystem creditSystem, String companyNip) {
    	//send request
		HttpRequest request;
		try {
			// Generate and send request
    		request = CrifWebservice.generateReportRequest(
    			creditSystem.getEndpointUrl(), creditSystem.getUserName(), 
    			creditSystem.getUserPassword(), companyNip);
			Http h = new Http();
			HttpResponse response = h.send(request);
			this.xmlResponseBody = response.getBody();
			this.creditSystemCompanyNumber = companyNip;
		} catch (Exception e) {
			System.debug('Credit Factory === ' + request.getBody());
			String errorMessage = 'Error when sending request for report. ' + CreditFactoryUtilities.CONTACT_ADMIN;
            throw new CreditFactoryException(errorMessage);
		}
    }


	public String getErrorToOrderRequest() {
		return this.errorToRequestOrder;
	} 


	public String getInternalId() {
        return this.internalId;
    }


	/*******************************************************************************
	*  Name 		   : getCompany()
	*  Summary         : Returns Company with Credit information
	*  CreatedDate     : 10/01/2018
	*  ModifiedDate    : 10/01/2018
	*  Parameters      : -
	*  Returns         : CreditCompany
	******************************************************************************/
	public CreditCompany getCompany() {
		return this.company;
	}


	/*******************************************************************************
	*  Name 		   : setEmployees()
	*  Summary         : Set employees from credit company
	*  CreatedDate     : 10/01/2018
	*  ModifiedDate    : 20/04/2018
	*  Parameters      : -
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
		        Dom.XMLNode reportDom = CrifWebservice.returnReportBody(xmldom);
		        this.companyEmployeesList = CrifWebservice.returnReportCompanyEmployees(reportDom);
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
	*  CreatedDate     : 10/01/2018
	*  ModifiedDate    : 10/01/2018
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
    *  Summary         : Set existing in database credit reports  
    *  CreatedDate     : 10/01/2018
	*  ModifiedDate    : 01/08/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void setExistingCreditReports() {
        List<Credit_Factory_Report__c> creditReportsList = [
                SELECT Credit_System_Number__c, Reference_Number__c, Class_Rating__c, Turn_Over__c, Legal_Form__c, Trade_Register_Number__c, Tax_Id__c, 
                	Date_Legal_Form__c, Register_Number__c, Date_Last_Register_Entry__c, County_Court__c, Payment_Behaviour__c, Staff_Range__c, 
                	Credit_Limit__c, Credit_Limit_Currency__c, Credit_Decision__c, Date_of_Foundation__c, Age_of_Company__c, First_Legal_Form__c, 
                	Company_Status__c, Name, Trade_Name__c, Street__c, Housenumber__c, Postcode__c, City__c, Country__c, Phone__c, Fax__c, Mobile__c, 
                	Email__c, Website__c, Solvency_Index__c, Request_Status__c, Obligation_Overdue__c, Number_Of_Hits__c, Policy_Rules_Hits__c, 
                	Name_Change_Decision__c, Address_Change_Decision__c, Postal_City__c, Postal_Housenumber__c, Postal_Postcode__c, Postal_Street__c,
                	Registered_City__c, Registered_Housenumber__c, Registered_Postcode__c, Registered_Street__c, Profit_Loss_Last_Year__c, 
                	Profit_Loss_Year_Before_Last__c, Turn_Over_Last_Year__c, PIT_Currency__c, Name__c, 
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
    *  Summary         : return company from Credit Factory Report object    
    *  CreatedDate     : 10/01/2018
	*  ModifiedDate    : 01/08/2019
    *  Parameters      : -
    *  Returns         : CreditCompany
    ******************************************************************************/
    private CreditCompany getExistingReportCompany() {
    	CreditCompany company = new CreditCompany();
    	company.creditSystemCompanyNumber = this.existingCreditReport.Credit_System_Number__c;
        company.classRating = this.existingCreditReport.Class_Rating__c;
        company.turnOver = this.existingCreditReport.Turn_Over__c;
        company.legalform = this.existingCreditReport.Legal_Form__c;
        company.tradeRegisterNumber = this.existingCreditReport.Trade_Register_Number__c;
        company.taxnumber = this.existingCreditReport.Tax_Id__c;
        company.registerNumber = this.existingCreditReport.Register_Number__c;
        company.staffcompanyrange = this.existingCreditReport.Staff_Range__c;
        company.creditLimit = this.existingCreditReport.Credit_Limit__c;
        company.creditLimitCurrency = this.existingCreditReport.Credit_Limit_Currency__c;
        company.dateoffoundation = this.existingCreditReport.Date_of_Foundation__c;
        company.ageofcompany = this.existingCreditReport.Age_of_Company__c;
        company.status = this.existingCreditReport.Company_Status__c;
        company.name = this.existingCreditReport.Name__c;
        company.tradename = this.existingCreditReport.Trade_Name__c;
        company.street = this.existingCreditReport.Street__c;
        company.housenumber = this.existingCreditReport.Housenumber__c;
        company.postcode = this.existingCreditReport.Postcode__c;
        company.city = this.existingCreditReport.City__c;
        company.postalStreet = this.existingCreditReport.Postal_Street__c;
        company.postalHousenumber = this.existingCreditReport.Postal_Housenumber__c;
        company.postalPostcode = this.existingCreditReport.Postal_Postcode__c;
        company.postalCity = this.existingCreditReport.Postal_City__c;
        company.registeredStreet = this.existingCreditReport.Registered_Street__c;
        company.registeredHousenumber = this.existingCreditReport.Registered_Housenumber__c;
        company.registeredPostcode = this.existingCreditReport.Registered_Postcode__c;
        company.registeredCity = this.existingCreditReport.Registered_City__c;
        company.country = this.existingCreditReport.Country__c;
        company.phone = this.existingCreditReport.Phone__c;
        company.fax = this.existingCreditReport.Fax__c;
        company.mobile = this.existingCreditReport.Mobile__c;
        company.email = this.existingCreditReport.Email__c;
        company.website = this.existingCreditReport.Website__c;
        company.identificationnumber = this.existingCreditReport.Credit_System_Number__c;
        company.solvencyIndex = this.existingCreditReport.Solvency_Index__c;
        company.requestStatus = this.existingCreditReport.Request_Status__c;
        company.obligationOverdue = this.existingCreditReport.Obligation_Overdue__c;
        company.numberOfHits = this.existingCreditReport.Number_Of_Hits__c;
        company.nameChangeDecision = this.existingCreditReport.Name_Change_Decision__c;
        company.addressChangeDecision = this.existingCreditReport.Address_Change_Decision__c;
        company.profitLossLastYear = this.existingCreditReport.Profit_Loss_Last_Year__c;
        company.profitLossYearBeforeLast = this.existingCreditReport.Profit_Loss_Year_Before_Last__c;
        company.turnOverLastYear = this.existingCreditReport.Turn_Over_Last_Year__c;
        company.pitCurrency = this.existingCreditReport.PIT_Currency__c;
        if (this.existingCreditReport.Policy_Rules_Hits__c != null) {
        	company.policyRulesHits = this.existingCreditReport.Policy_Rules_Hits__c.split('\r\n');
        }

        return company;
    }


    /*******************************************************************************
    *  Name            : getExistingReportCompanyEmployees()
    *  Summary         : return company from Credit Factory Report Employee object      
    *  CreatedDate     : 10/01/2018
	*  ModifiedDate    : 20/04/2018
    *  Parameters      : -
    *  Returns         : List<CreditCompanyEmployee>
    ******************************************************************************/
    private List<CreditCompanyEmployee> getExistingReportCompanyEmployees() {
    	List<CreditCompanyEmployee> employeesList = new List<CreditCompanyEmployee>();
    	for (Credit_Factory_Report_Employee__c existingEmployee : this.existingCreditReport.Credit_Factory_Report_Employees__r) {
    		CreditCompanyEmployee employee = new CreditCompanyEmployee();
    		employee.type = existingEmployee.Type__c;
    		employee.ename = existingEmployee.Name;
    		employee.address = existingEmployee.Address__c;
    		employeesList.add(employee);
    	}
    	return employeesList;
    }


    /*******************************************************************************
	*  Name 		   : isSales()
	*  Summary         : Check Sales Profile
	*  CreatedDate     : 10/01/2018
	*  ModifiedDate    : 10/01/2018
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
	*  CreatedDate     : 10/01/2018
	*  ModifiedDate    : 10/01/2018
	*  Parameters      : 
	*  Returns         : Set<String>
	******************************************************************************/
	public Set<String> getErrorsSet() {
		return this.errorsSet;
	}


	/*******************************************************************************
	*  Name 		   : validate()
	*  Summary         : Compare information from CreditReform with Salesforce
	*  CreatedDate     : 10/01/2018
	*  ModifiedDate    : 10/01/2018
	*  Parameters      : 
	*  Returns         : Boolean - returns true if no errors
	******************************************************************************/
	public Boolean validate() {
		this.errorsSet = new Set<String>();
    	Boolean isValid = true;

    	if ( ! validateAddress()) isValid = false;
    	if ( ! validateLegalForm()) isValid = false;
    	if (isSales()) {
	    	if ( ! validateCompanyName()) isValid = false;
     	}
    	if ( ! validateRequestStatus()) isValid = false;
    	if ( ! validateObligationOverdue()) isvalid = false;
    	if ( ! validateAgeOfCompany()) isValid = false;
    	if ( ! validateTaxId()) isValid = false;
    	if ( ! validateTradeRegisterNumber()) isValid = false;
    	if ( ! validateLostOpportunities()) isValid = false;
    	validateContact();

    	if (isSales()) {
	    	// change to Pending Deposit
	    	if (! (this.errorsSet.contains(ADDRESS_ERROR) || this.errorsSet.contains(COMPANY_NAME_ERROR) || this.errorsSet.contains(CONTACT_ERROR) || 
	    			this.errorsSet.contains(REQUEST_STATUS_ERROR) || this.errorsSet.contains(TAX_ID_ERROR) || 
	    			this.errorsSet.contains(TRADE_REGISTER_NUMBER_ERROR) || this.errorsSet.contains(LOST_OPPORTUNITY_ERROR)) && 
	    			(this.errorsSet.contains(OBLIGATION_OVERDUE_ERROR) || this.errorsSet.contains(AGE_OF_COMPANY_ERROR))) {
	    		this.securityLevel = 100;
	    		changeToPendingDeposit();
	    	}
     	}

    	return isValid;
	}


	/*******************************************************************************
	*  Name 		   : validateAddress()
	*  Summary         : Compare Address information from CreditReform with Salesforce
	*  CreatedDate     : 10/01/2018
	*  ModifiedDate    : 08/10/2018
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
        String crifStreetAndHouseNumber = ((company.street != null ? company.street : '') + ' ' + (company.housenumber != null ? company.housenumber : '')).removeStart(' ').removeEnd(' ');
        String crifHouseNumberAndStreet = ((company.housenumber != null ? company.housenumber : '') + ' ' + (company.street != null ? company.street : '')).removeStart(' ').removeEnd(' ');
        String crifPostalStreetAndHouseNumber = ((company.postalStreet != null ? company.postalStreet : '') + ' ' + 
        	(company.postalHousenumber != null ? company.postalHousenumber : '')).removeStart(' ').removeEnd(' ');
        String crifPostalHouseNumberAndStreet = ((company.postalHousenumber != null ? company.postalHousenumber : '') + 
        	' ' + (company.postalStreet != null ? company.postalStreet : '')).removeStart(' ').removeEnd(' ');
        String crifRegisteredStreetAndHouseNumber = ((company.registeredStreet != null ? company.registeredStreet : '') + ' ' + 
        	(company.registeredHousenumber != null ? company.registeredHousenumber : '')).removeStart(' ').removeEnd(' ');
        String crifRegisteredHouseNumberAndStreet = ((company.registeredHousenumber != null ? company.registeredHousenumber : '') + 
        	' ' + (company.registeredStreet != null ? company.registeredStreet : '')).removeStart(' ').removeEnd(' ');

        String billingPostalCode = this.sourceObject.Account.BillingPostalCode;
        String shippingPostalCode = this.sourceObject.Account.ShippingPostalCode;
        String crifPostalcode = this.company.postcode;
        String crifRegisteredPostalCode = this.company.registeredPostcode;
        String crifPostalPostalCode = this.company.postalPostcode;

        String billingCity = this.sourceObject.Account.BillingCity;
        String shippingCity = this.sourceObject.Account.ShippingCity;
        String crifCity = this.company.city;
        String crifRegisteredCity = this.company.registeredCity;
        String crifPostalCity = this.company.postalCity;

		if (! ((CreditFactoryUtilities.isStringsEquals(billingStreetAndHouseNumber, crifStreetAndHouseNumber) || 
				CreditFactoryUtilities.isStringsEquals(billingStreetAndHouseNumber, crifHouseNumberAndStreet) || 
				CreditFactoryUtilities.isStringsEquals(billingStreetAndHouseNumber, crifRegisteredStreetAndHouseNumber) || 
        		CreditFactoryUtilities.isStringsEquals(billingStreetAndHouseNumber, crifRegisteredHouseNumberAndStreet) ||
        		CreditFactoryUtilities.isStringsEquals(billingStreetAndHouseNumber, crifPostalStreetAndHouseNumber) ||
        		CreditFactoryUtilities.isStringsEquals(billingStreetAndHouseNumber, crifPostalHouseNumberAndStreet)) &&
        		(CreditFactoryUtilities.isStringsEquals(shippingStreetAndHouseNumber, crifStreetAndHouseNumber) || 
				CreditFactoryUtilities.isStringsEquals(shippingStreetAndHouseNumber, crifHouseNumberAndStreet) || 
				CreditFactoryUtilities.isStringsEquals(shippingStreetAndHouseNumber, crifRegisteredStreetAndHouseNumber) || 
        		CreditFactoryUtilities.isStringsEquals(shippingStreetAndHouseNumber, crifRegisteredHouseNumberAndStreet) ||
        		CreditFactoryUtilities.isStringsEquals(shippingStreetAndHouseNumber, crifPostalStreetAndHouseNumber) ||
        		CreditFactoryUtilities.isStringsEquals(shippingStreetAndHouseNumber, crifPostalHouseNumberAndStreet)) && 
				(CreditFactoryUtilities.isStringsEquals(billingPostalCode, crifPostalcode) ||
				CreditFactoryUtilities.isStringsEquals(billingPostalCode, crifRegisteredPostalCode) || 
				CreditFactoryUtilities.isStringsEquals(billingPostalCode, crifPostalPostalCode)) &&
				(CreditFactoryUtilities.isStringsEquals(shippingPostalCode, crifPostalcode) ||
				CreditFactoryUtilities.isStringsEquals(shippingPostalCode, crifRegisteredPostalCode) ||
				CreditFactoryUtilities.isStringsEquals(shippingPostalCode, crifPostalPostalCode)) &&
				(CreditFactoryUtilities.isStringsEquals(billingCity, crifCity) ||
				CreditFactoryUtilities.isStringsEquals(billingCity, crifRegisteredCity) ||
				CreditFactoryUtilities.isStringsEquals(billingCity, crifPostalCity)) &&
				(CreditFactoryUtilities.isStringsEquals(shippingCity, crifCity) ||
				CreditFactoryUtilities.isStringsEquals(shippingCity, crifRegisteredCity) ||
				CreditFactoryUtilities.isStringsEquals(shippingCity, crifPostalCity)))) {
        	this.errorsSet.add(ADDRESS_ERROR);
	        CreditFactoryUtilities.displayMessage('error', 'Account Billing and Shipping Addresses should be the same as one of the Crif addresses');
        	return false;
        }

        return true;
	}


	/*******************************************************************************
	*  Name 		   : validateLegalForm()
	*  Summary         : Compare Legal Form information from CreditReform with Salesforce
	*  CreatedDate     : 10/01/2018
	*  ModifiedDate    : 04/07/2018
	*  Parameters      : -
	*  Returns         : Boolean - returns true if no errors
	******************************************************************************/
	public Boolean validateLegalForm() {
        return true;
	}


	/*******************************************************************************
	*  Name 		   : validateContact()
	*  Summary         : Check that contact from CreditReform exists in Salesforce
	*  CreatedDate     : 10/01/2018
	*  ModifiedDate    : 10/10/2018
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
	        	firstName = CreditFactoryUtilities.replacePolishCharacters(contactRelation.Contact.FirstName).toUpperCase().replace('’', '\'');
	        }

        	String lastName = CreditFactoryUtilities.replacePolishCharacters(contactRelation.Contact.LastName).toUpperCase().replace('’', '\'');
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
					if (CreditFactoryUtilities.replacePolishCharacters(emp.ename).toUpperCase().replace('\u00a0', ' ').contains(lastName)) {
						isContactExists = true;
					}
				}
	        }
        }

        if (this.userSource == 'E2E Long Form') {
        	for (String firstAndLastName : contactsFirstAndLastNamesSet) {
				if (firstAndLastName == CreditFactoryUtilities.replacePolishCharacters(this.company.Name).toUpperCase().replace('’', '\'')) {
					isContactExists = true;
				}
			}
        } else if (validateCompanyName() == true) {
        	for (String firstAndLastName : contactsFirstAndLastNamesSet) {
				if (firstAndLastName == CreditFactoryUtilities.replacePolishCharacters(this.sourceObject.Account.Name).toUpperCase().replace('’', '\'')) {
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
		        	String errorMessage1 = CrifWebservice.CREDIT_SYSTEM_NAME + ' Contact person doesn\'t exist in Account\'s Contacts';
		        	CreditFactoryUtilities.displayMessage('error',errorMessage1);
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


	/*******************************************************************************
	*  Name            : validateObligationOverdue()
	*  Summary         : check payment history with obligation overdue    
	*  CreatedDate     : 12/01/2018
	*  CreatedDate     : 12/01/2018
	*  Parameters      : -
	*  Returns         : Boolean
	******************************************************************************/
	public Boolean validateObligationOverdue() {
		if (this.company.obligationOverdue == true) {
			errorsSet.add(OBLIGATION_OVERDUE_ERROR);
			CreditFactoryUtilities.displayMessage('error', 'Сompany has an overdue obligation.');
			return false;
		}

		return true;
	}


	/*******************************************************************************
	*  Name            : validateRequestStatus()
	*  Summary         : check errors in request    
	*  CreatedDate     : 12/01/2018
	*  ModifiedDate    : 12/01/2018
	*  Parameters      : -
	*  Returns         : Boolean
	******************************************************************************/
	public Boolean validateRequestStatus() {
		if (this.company.requestStatus != 'OK') {
			errorsSet.add(REQUEST_STATUS_ERROR);
			CreditFactoryUtilities.displayMessage('error', 'Error with request status. Please refer to credit.');
			return false;
		}

		return true;
	}
	

	/*******************************************************************************
	*  Name            : validateAgeOfCompany()
	*  Summary         : check company age    
	*  CreatedDate     : 12/01/2018
	*  CreatedDate     : 12/01/2018
	*  Parameters      : -
	*  Returns         : Boolean
	******************************************************************************/
	public Boolean validateAgeOfCompany() {
		if (this.company.dateoffoundation != null) {
			Date dateOfFoundation = Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(0, 4)), 
				Integer.valueOf(this.company.dateoffoundation.substring(4, 6)), Integer.valueOf(this.company.dateoffoundation.substring(6, 8)));
			if (dateOfFoundation.monthsBetween(Date.today()) < 18) {
				errorsSet.add(AGE_OF_COMPANY_ERROR);
				CreditFactoryUtilities.displayMessage('error', 'Age of company is too small.');
				return false;
			}
		}

		return true;
	}


	/*******************************************************************************
	*  Name            : validateTaxId()
	*  Summary         : Compare Crif tax id with Salesforce    
	*  CreatedDate     : 29/01/2018
	*  ModifiedDate    : 29/01/2018
	*  Parameters      : -
	*  Returns         : Boolean
	******************************************************************************/
	public Boolean validateTaxId() {
		if (company.taxnumber != null && ! CreditFactoryUtilities.isStringsEquals(company.taxnumber, (String)sourceObject.getSobject('Account').get(this.accountMapping.Tax_Id__c))) {
            errorsSet.add(TAX_ID_ERROR);
            String errorMessage = 'Account Tax ID mismatch (' + CrifWebservice.CREDIT_SYSTEM_NAME + 
            	' to Account ' + TAX_ID + ')';
            CreditFactoryUtilities.displayMessage('error',errorMessage);
            return false;
        }

        return true;
	}


	/*******************************************************************************
	*  Name            : validateTradeRegisterNumber()
	*  Summary         : Compare Crif trade register number with Salesforce    
	*  CreatedDate     : 02/03/2018
	*  ModifiedDate    : 02/03/2018
	*  Parameters      : -
	*  Returns         : Boolean
	******************************************************************************/
	public Boolean validateTradeRegisterNumber() {
		if (company.tradeRegisterNumber != null && ! CreditFactoryUtilities.isStringsEquals(company.tradeRegisterNumber, this.sourceObject.Account.HR_Abteilung_HRA_HRB_und_HR_Nummer__c)) {
            errorsSet.add(TRADE_REGISTER_NUMBER_ERROR);
            String errorMessage = 'Account Trade Register Number mismatch (' + CrifWebservice.CREDIT_SYSTEM_NAME + 
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
	*  Name 		   : validateBlackList()
	*  Summary         : Check if Company is in black list.
	*  CreatedDate     : 10/10/2018
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
	*  Name 		   : validateCompanyName()
	*  Summary         : Check that Account Name is the same as Company Name from Salesforce
	*  CreatedDate     : 10/01/2018
	*  ModifiedDate    : 10/01/2018
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
    *  Name            : doUpdateAddress()
    *  Summary         : Update Billing and Shipping address in SF with main known address from Crif.     
    *  CreatedDate     : 08/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doUpdateAddress() {
    	String crifStreetAndHouseNumber = ((this.company.street != null ? this.company.street : '') + ' ' + (this.company.housenumber != null ? 
    		this.company.housenumber : '')).removeStart(' ').removeEnd(' ');
        Account account = new Account(
            Id = sourceObject.AccountId,
            BillingStreet = crifStreetAndHouseNumber,
            BillingPostalCode = this.company.postcode,
            BillingCity = this.company.city,
            ShippingStreet = crifStreetAndHouseNumber,
            ShippingPostalCode = this.company.postcode,
            ShippingCity = this.company.city);
        try {
            update account;
            CreditFactoryUtilities.displayMessage('confirm', 'Address has been updated.');
        } catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Address update failed.');	
        }

        setSourceObject(sourceObject.Id);
    }


    public void doUpdateWithAdditionalAddress() {}


    /*******************************************************************************
    *  Name            : doUpdateWithPostalAddress()
    *  Summary         : Update Billing and Shipping address in SF with Postal address from Crif.     
    *  CreatedDate     : 08/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doUpdateWithPostalAddress() {
    	String crifPostalStreetAndHouseNumber = ((company.postalStreet != null ? company.postalStreet : '') + ' ' + 
        	(company.postalHousenumber != null ? company.postalHousenumber : '')).removeStart(' ').removeEnd(' ');
        Account account = new Account(
            Id = sourceObject.AccountId,
            BillingStreet = crifPostalStreetAndHouseNumber,
            BillingPostalCode = this.company.postalPostcode,
            BillingCity = this.company.postalCity,
            ShippingStreet = crifPostalStreetAndHouseNumber,
            ShippingPostalCode = this.company.postalPostcode,
            ShippingCity = this.company.postalCity);
        try {
            update account;
            CreditFactoryUtilities.displayMessage('confirm', 'Address has been updated.');
        } catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Address update failed.');	
        }

        setSourceObject(sourceObject.Id);
    }


    /*******************************************************************************
    *  Name            : doUpdateWithRegisteredAddress()
    *  Summary         : Update Billing and Shipping address in SF with Registered address from Crif.    
    *  CreatedDate     : 08/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doUpdateWithRegisteredAddress() {
    	String crifRegisteredStreetAndHouseNumber = ((company.registeredStreet != null ? company.registeredStreet : '') + ' ' + 
        	(company.registeredHousenumber != null ? company.registeredHousenumber : '')).removeStart(' ').removeEnd(' ');
        Account account = new Account(
            Id = sourceObject.AccountId,
            BillingStreet = crifRegisteredStreetAndHouseNumber,
            BillingPostalCode = this.company.registeredPostcode,
            BillingCity = this.company.registeredCity,
            ShippingStreet = crifRegisteredStreetAndHouseNumber,
            ShippingPostalCode = this.company.registeredPostcode,
            ShippingCity = this.company.registeredCity);
        try {
            update account;
            CreditFactoryUtilities.displayMessage('confirm', 'Address has been updated.');
        } catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Address update failed.');	
        }

        setSourceObject(sourceObject.Id);
    }


	/*******************************************************************************
	*  Name            : doUpdateCompanyName()
	*  Summary         : Update Account name with Crif Company Name
	*  CreatedDate     : 10/01/2018
	*  ModifiedDate    : 10/01/2018
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
	*  Summary         : Update Account Tax Id with Crif Tax Id
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


    public void doUpdateVatNumber() {}


    /*******************************************************************************
	*  Name            : doUpdateTradeRegisterNumber()
	*  Summary         : Update Account Trade Register Number with Crif Trade Register Number
	*  CreatedDate     : 02/03/2018
	*  ModifiedDate    : 02/03/2018
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
	*  Name 		   : updateDefaultFieldSetForRecord()
	*  Summary         : Update specific fields in Opportunity by Sales when all validations passed
	*  CreatedDate     : 10/01/2018
	*  ModifiedDate    : 10/01/2018
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void updateDefaultFieldSetForValidRecord() {
		try {
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
	*  CreatedDate     : 14/02/2018
	*  ModifiedDate    : 01/04/2019
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void updateDefaultFieldSetForRecord() {
		try {
			this.sourceObject.Updated_From_Credit_Factory__c = true;
        	this.sourceObject.put(
        		this.opportunityMapping.Credit_System_Rating__c,
        		this.company.classRating);
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
		} catch (Exception e) {
			System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Default fields update failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}
	}


	/*******************************************************************************
	*  Name 		   : getBuffer()
	*  Summary         : Return buffer value
	*  CreatedDate     : 10/01/2018
	*  ModifiedDate    : 10/01/2018
	*  Parameters      : -
	*  Returns         : String
	******************************************************************************/
	public Decimal getBuffer() {
		return this.buffer;
	}


	/*******************************************************************************
	*  Name 		   : setBuffer(String classRating)
	*  Summary         : Calculate buffer
	*  CreatedDate     : 10/01/2018
	*  ModifiedDate    : 10/04/2018
	*  Parameters      : classRating - Credit Company rating
	*  Returns         : void
	******************************************************************************/
	public void setBuffer(String classRating) {
		if (classRating == '1') {
	        this.buffer = 0.2;
	    } else if (classRating == '2') {
	    	this.buffer = 0.1;
	    } else if (classRating == '3') {
	    	this.buffer = 0;
	    }
	}


	/*******************************************************************************
	*  Name 		   : getRiskCategory()
	*  Summary         : Return Risk Category
	*  CreatedDate     : 10/01/2018
	*  ModifiedDate    : 10/01/2018
	*  Parameters      : -
	*  Returns         : String
	******************************************************************************/
	public String getRiskCategory() {
		return this.riskCategory;
	}


	/*******************************************************************************
	*  Name 		   : setRiskCategory(String classRating)
	*  Summary         : Calculate Risk Category
	*  CreatedDate     : 10/01/2018
	*  ModifiedDate    : 10/04/2018
	*  Parameters      : classRating - Credit Company rating (1, 2, 3, ...)
	*  Returns         : void
	******************************************************************************/
	public void setRiskCategory(String classRating) {
		if (classRating == '1') {
	        this.riskCategory = 'Medium';
	    } else if (classRating == '2') {
	    	this.riskCategory = 'High';
	    } else if (classRating == '3') {
	    	this.riskCategory = 'Very';
	    }
	}


	/*******************************************************************************
	*  Name            : getSecurityLevel()
	*  Summary         : Return security level
	*  CreatedDate     : 10/10/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : String
	******************************************************************************/
	public Decimal getSecurityLevel() {
		return this.securityLevel;
	}


	public void setSecurityLevel(String classRating) {}


	/*******************************************************************************
    *  Name            : getCreditLimitWeeklyPlus7()
    *  Summary         : Calculate Credit Limit Weekly Plus 7
    *  CreatedDate     : 18/10/2018
    *  ModifiedDate    : 28/11/2018
    *  Parameters      : -
    *  Returns         : Decimal
    ******************************************************************************/
	public Decimal getCreditLimitWeeklyPlus7() {
		if (this.creditLimitWeeklyPlus7 != null) {
			if (this.creditLimitWeeklyPlus7 < 50) {
				this.creditLimitWeeklyPlus7 = this.creditLimitWeeklyPlus7 + 50;
			}
			this.creditLimitWeeklyPlus7 = (this.creditLimitWeeklyPlus7 / 100).round(System.RoundingMode.HALF_UP) * 100;
		}

		return this.creditLimitWeeklyPlus7;
	}

	
	/*******************************************************************************
    *  Name            : setCreditLimitWeeklyPlus7()
    *  Summary         : Calculate Credit Limit Weekly Plus 7   
    *  CreatedDate     : 18/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Decimal
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
	*  CreatedDate     : 18/10/2018
	*  ModifiedDate    : 28/11/2018
	*  Parameters      : -
	*  Returns         : Decimal
	******************************************************************************/
	public Decimal getMaxCreditLimitWeeklyPlus7() {
		if (this.maxCreditLimitWeeklyPlus7 != null) {
			this.maxCreditLimitWeeklyPlus7 = (this.maxCreditLimitWeeklyPlus7 / 100).round(System.RoundingMode.HALF_UP) * 100;
		}

		return this.maxCreditLimitWeeklyPlus7;
	}


	/*******************************************************************************
	*  Name            : setMaxCreditLimitWeeklyPlus7()
	*  Summary         : Calculate Max Credit Limit Weekly Plus 7
	*  CreatedDate     : 18/10/2018
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
			}
	    } catch (Exception e) {
	    	System.debug('Credit Factory === ' + e.getMessage());
	    	throw new CreditFactoryException('Max Credit Limit Weekly + 7 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
	    }
	}


	/*******************************************************************************
	*  Name            : setMaxCreditLimitWeeklyPlus7Rating1()
	*  Summary         : Calculate Max Credit Limit Weekly Plus 7 for Rating 1
	*  CreatedDate     : 19/10/2018
	*  ModifiedDate    : 08/04/2019
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setMaxCreditLimitWeeklyPlus7Rating1() {
		Decimal totalConsumption = this.sourceObject.Total_consumption_l_month__c;
		if (totalConsumption != null && totalConsumption != 0) {
			Decimal nonFuelExposure = 0;
			if (this.sourceObject.Non_fuel_exposure__c != null) nonFuelExposure = this.sourceObject.Non_fuel_exposure__c;
			Decimal creditLimit8000WeeklyPlus7 = (((Decimal)this.sourceObject.get(this.opportunityMapping.Monthly_Volume_Currency__c) - nonFuelExposure) / totalConsumption * 8000 + 
				this.sourceObject.Non_fuel_exposure__c) * (7.0 + 7.0) / 30.0 * (1.0 + 0.2);
			Decimal creditLimit2000WeeklyPlus7 = (((Decimal)this.sourceObject.get(this.opportunityMapping.Monthly_Volume_Currency__c) - nonFuelExposure) / totalConsumption * 2000 + 
				this.sourceObject.Non_fuel_exposure__c) * (7.0 + 7.0) / 30.0 * (1.0 + 0.2);

			if (this.userSource == 'E2E Long Form') {
				if (this.creditLimitWeeklyPlus7 * 2 <= creditLimit8000WeeklyPlus7) {
					this.maxCreditLimitWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 2;
				} else {
					this.maxCreditLimitWeeklyPlus7 = creditLimit8000WeeklyPlus7;
				}
			} else {
				this.maxCreditLimitWeeklyPlus7 = creditLimit2000WeeklyPlus7;
			}
		} else {
			this.maxCreditLimitWeeklyPlus7 = 0;
		}
	}


	/*******************************************************************************
	*  Name            : setMaxCreditLimitWeeklyPlus7Rating2()
	*  Summary         : Calculate Max Credit Limit Weekly Plus 7 for Rating 2   
	*  CreatedDate     : 19/10/2018
	*  ModifiedDate    : 08/04/2019
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setMaxCreditLimitWeeklyPlus7Rating2() {
		Decimal totalConsumption = this.sourceObject.Total_consumption_l_month__c;
		if (totalConsumption != null && totalConsumption != 0) {
			Decimal nonFuelExposure = 0;
			if (this.sourceObject.Non_fuel_exposure__c != null) nonFuelExposure = this.sourceObject.Non_fuel_exposure__c;
			Decimal creditLimit8000WeeklyPlus7 = (((Decimal)this.sourceObject.get(this.opportunityMapping.Monthly_Volume_Currency__c) - nonFuelExposure) / totalConsumption * 8000 + 
				this.sourceObject.Non_fuel_exposure__c) * (7.0 + 7.0) / 30.0 * (1.0 + 0.1);
			Decimal creditLimit2000WeeklyPlus7 = (((Decimal)this.sourceObject.get(this.opportunityMapping.Monthly_Volume_Currency__c) - nonFuelExposure) / totalConsumption * 2000 + 
				this.sourceObject.Non_fuel_exposure__c) * (7.0 + 7.0) / 30.0 * (1.0 + 0.1);

			if (this.userSource == 'E2E Long Form') {
				if (this.creditLimitWeeklyPlus7 * 2 <= creditLimit8000WeeklyPlus7) {
					this.maxCreditLimitWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 2;
				} else {
					this.maxCreditLimitWeeklyPlus7 = creditLimit8000WeeklyPlus7;
				}
			} else {
				this.maxCreditLimitWeeklyPlus7 = creditLimit2000WeeklyPlus7;
			}
		} else {
			this.maxCreditLimitWeeklyPlus7 = 0;
		}
	}


	/*******************************************************************************
	*  Name            : getMaxValueWeeklyPlus7()
	*  Summary         : Return Max value of Credit Limit including deposit Weekly Plus 7
	*  CreatedDate     : 18/10/2018
	*  ModifiedDate    : 28/11/2018
	*  Parameters      : -
	*  Returns         : Decimal
	******************************************************************************/
	public Decimal getMaxValueWeeklyPlus7() {
		if (this.maxValueWeeklyPlus7 != null) {
			this.maxValueWeeklyPlus7 = (this.maxValueWeeklyPlus7 / 100).round(System.RoundingMode.HALF_UP) * 100;
		}

		return this.maxValueWeeklyPlus7;
	}


	/*******************************************************************************
	*  Name            : setMaxValueWeeklyPlus7()
	*  Summary         : Calculate Max value of Credit Limit including deposit Weekly Plus 7
	*  CreatedDate     : 18/10/2018
	*  ModifiedDate    : 06/11/2018
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void setMaxValueWeeklyPlus7() {
		try {
			if (this.company.classRating == '1') {
				setMaxValueWeeklyPlus7Rating1();
			} else if (this.company.classRating == '2') {
				setMaxValueWeeklyPlus7Rating2();
			}
	    } catch (Exception e) {
	    	System.debug('Credit Factory === ' + e.getMessage());
	    	throw new CreditFactoryException('Max Value Weekly + 7 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
	    }
	}


	/*******************************************************************************
	*  Name            : setMaxValueWeeklyPlus7Rating1()
	*  Summary         : Calculate Max Value of Credit Limit including deposit Weekly Plus 7 for Rating 1
	*  CreatedDate     : 19/10/2108
	*  ModifiedDate    : 08/04/2019
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setMaxValueWeeklyPlus7Rating1() {
		Decimal totalConsumption = this.sourceObject.Total_consumption_l_month__c;
		if (totalConsumption != null && totalConsumption != 0) {
			Decimal nonFuelExposure = 0;
			if (this.sourceObject.Non_fuel_exposure__c != null) nonFuelExposure = this.sourceObject.Non_fuel_exposure__c;
			Decimal creditLimit8000WeeklyPlus7 = (((Decimal)this.sourceObject.get(this.opportunityMapping.Monthly_Volume_Currency__c) - nonFuelExposure) / totalConsumption * 8000 + 
				this.sourceObject.Non_fuel_exposure__c) * (7.0 + 7.0) / 30.0 * (1.0 + 0.2);

			if (this.creditLimitWeeklyPlus7 * 2 <= creditLimit8000WeeklyPlus7) {
				this.maxValueWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 2;
			} else {
				this.maxValueWeeklyPlus7 = creditLimit8000WeeklyPlus7;
			}
		} else {
			this.maxValueWeeklyPlus7 = 0;
		}
	}


	/*******************************************************************************
	*  Name            : setMaxValueWeeklyPlus7Rating2()
	*  Summary         : Calculate Max Value of Credit Limit including deposit Weekly Plus 7 for Rating 2
	*  CreatedDate     : 19/10/2108
	*  ModifiedDate    : 08/04/2019
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setMaxValueWeeklyPlus7Rating2() {
		Decimal totalConsumption = this.sourceObject.Total_consumption_l_month__c;
		if (totalConsumption != null && totalConsumption != 0) {
			Decimal nonFuelExposure = 0;
			if (this.sourceObject.Non_fuel_exposure__c != null) nonFuelExposure = this.sourceObject.Non_fuel_exposure__c;
			Decimal creditLimit8000WeeklyPlus7 = (((Decimal)this.sourceObject.get(this.opportunityMapping.Monthly_Volume_Currency__c) - nonFuelExposure) / totalConsumption * 8000 + 
				this.sourceObject.Non_fuel_exposure__c) * (7.0 + 7.0) / 30.0 * (1.0 + 0.1);

			if (this.creditLimitWeeklyPlus7 * 2 <= creditLimit8000WeeklyPlus7) {
				this.maxValueWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 2;
			} else {
				this.maxValueWeeklyPlus7 = creditLimit8000WeeklyPlus7;
			}
		} else {
			this.maxValueWeeklyPlus7 = 0;
		}
	}


	/*******************************************************************************
	*  Name            : getDepositWeeklyPlus7()
	*  Summary         : Return Deposit Weekly Plus 7
	*  CreatedDate     : 18/10/2018
	*  ModifiedDate    : 24/10/2018
	*  Parameters      : -
	*  Returns         : Decimal
	******************************************************************************/
	public Decimal getDepositWeeklyPlus7() {
		if (this.depositWeeklyPlus7 != null) {
			if (this.depositWeeklyPlus7 > 0 && this.depositWeeklyPlus7 < 50) {
				this.depositWeeklyPlus7 = this.depositWeeklyPlus7 + 50;
			}
			this.depositWeeklyPlus7 = (this.depositWeeklyPlus7 / 100).round(System.RoundingMode.HALF_UP) * 100;
		}
		return this.depositWeeklyPlus7;
	}


	/*******************************************************************************
	*  Name            : setDepositWeeklyPlus7()
	*  Summary         : Calculate Deposit Weekly Plus 7    
	*  CreatedDate     : 18/10/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void setDepositWeeklyPlus7() {
		try {
			if (this.company.obligationOverdue == true) {
				this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7;
				this.securityLevelWeeklyPlus7 = 100;
			} else if (this.company.dateoffoundation != null && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(0, 4)), 
					Integer.valueOf(this.company.dateoffoundation.substring(4, 6)), Integer.valueOf(this.company.dateoffoundation.substring(6, 8))).monthsBetween(Date.today()) < 18) {
				this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7;
				this.securityLevelWeeklyPlus7 = 100;
			} else if (this.company.classRating == '1') {
				setDepositWeeklyPlus7Rating1();
			} else if (this.company.classRating == '2') {
				setDepositWeeklyPlus7Rating2();
			} else {
				this.depositWeeklyPlus7 = 0;
			}
		} catch (Exception e) {
			System.debug('Credit Factory === ' + e.getMessage());
			throw new CreditFactoryException('Deposit Weekly + 7 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}
	}


	/*******************************************************************************
	*  Name            : setDepositWeeklyPlus7Rating1()
	*  Summary         : Calculate Deposit Weekly Plus 7 for Rating 1    
	*  CreatedDate     : 18/10/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setDepositWeeklyPlus7Rating1() {
		if (this.userSource == 'E2E Long Form' || Integer.valueOf(this.sourceObject.get(this.opportunityMapping.Fuel_consumption_l_month__c)) <= 1500) {
			this.depositWeeklyPlus7 = 0;
		} else {
			if (this.sourceObject.Profit_loss_last_year__c == 0 && this.sourceObject.Profit_loss_year_before_last__c == 0) {
				this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7;
				this.securityLevelWeeklyPlus7 = 100;
			} else if (this.sourceObject.Profit_loss_last_year__c < 0) {
				this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7;
				this.securityLevelWeeklyPlus7 = 100;
			} else if (this.sourceObject.Profit_loss_last_year__c > 0 && this.sourceObject.Profit_loss_year_before_last__c < 0) {
				this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 0.7;
				this.securityLevelWeeklyPlus7 = 70;
			} else if (this.sourceObject.Profit_loss_last_year__c <= 20000 || this.sourceObject.Profit_loss_year_before_last__c <= 35000) {
				this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 0.5;
				this.securityLevelWeeklyPlus7 = 50;
			} else if (this.creditLimitWeeklyPlus7 > this.sourceObject.Profit_loss_last_year__c) {
				this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 0.5;
				this.securityLevelWeeklyPlus7 = 50;
			} else if (this.creditLimitWeeklyPlus7 > this.sourceObject.Turnover_last_year__c * 0.1) {
				this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 0.5;
				this.securityLevelWeeklyPlus7 = 50;
			} else {
				this.depositWeeklyPlus7 = 0;
			}
		}
	}


	/*******************************************************************************
	*  Name            : setDepositWeeklyPlus7Rating2()
	*  Summary         : Calculate Deposit Weekly Plus 7 for Rating 2
	*  CreatedDate     : 18/10/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setDepositWeeklyPlus7Rating2() {
		if (this.userSource == 'E2E Long Form' || Integer.valueOf(this.sourceObject.get(this.opportunityMapping.Fuel_consumption_l_month__c)) <= 1500) {
			if (this.policyRulesPriority != null) {
				if (this.policyRulesPriority == '2') {
					this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7;
					this.securityLevelWeeklyPlus7 = 100;
				} else if (this.policyRulesPriority == '3') {
					if (this.company.LegalForm == 'Private person company' || this.company.LegalForm == 'General partnership' || 
							this.company.LegalForm == 'private company' || this.company.LegalForm == 'Partnership company' || 
							this.company.LegalForm == 'Single person company confirmed') {
						this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7;
						this.securityLevelWeeklyPlus7 = 100;
					} else {
						this.depositWeeklyPlus7 = 0;
					}
				} else if (this.policyRulesPriority == '4') {
					this.depositWeeklyPlus7 = 0;
				}
			} else if (this.company.nameChangeDecision == 'YELLOW' || this.company.addressChangeDecision == 'YELLOW') {
				this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7;
				this.securityLevelWeeklyPlus7 = 100;
			}
		} else {
			if (this.sourceObject.Profit_loss_last_year__c == 0 && this.sourceObject.Profit_loss_year_before_last__c == 0) {
				this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7;
				this.securityLevelWeeklyPlus7 = 100;
			} else if (this.sourceObject.Profit_loss_last_year__c < 0) {
				this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7;
				this.securityLevelWeeklyPlus7 = 100;
			} else if (this.sourceObject.Profit_loss_last_year__c > 0 && this.sourceObject.Profit_loss_year_before_last__c < 0) {
				this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 0.7;
				this.securityLevelWeeklyPlus7 = 70;
			} else if (this.sourceObject.Profit_loss_last_year__c <= 20000 || this.sourceObject.Profit_loss_year_before_last__c <= 35000) {
				this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 0.5;
				this.securityLevelWeeklyPlus7 = 50;
			} else if (this.creditLimitWeeklyPlus7 > this.sourceObject.Profit_loss_last_year__c) {
				this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 0.5;
				this.securityLevelWeeklyPlus7 = 50;
			} else if (this.creditLimitWeeklyPlus7 > this.sourceObject.Turnover_last_year__c * 0.1) {
				this.depositWeeklyPlus7 = this.creditLimitWeeklyPlus7 * 0.5;
				this.securityLevelWeeklyPlus7 = 50;
			} else {
				this.depositWeeklyPlus7 = 0;
			}
		}
	}


	/*******************************************************************************
    *  Name            : getCreditLimitBiWeeklyPlus7()
    *  Summary         : Calculate Credit Limit BiWeekly Plus 7
    *  CreatedDate     : 18/10/2018
    *  ModifiedDate    : 28/11/2018
    *  Parameters      : -
    *  Returns         : Decimal
    ******************************************************************************/
	public Decimal getCreditLimitBiWeeklyPlus7() {
		if (this.creditLimitBiWeeklyPlus7 != null) {
			if (this.creditLimitBiWeeklyPlus7 < 50) {
				this.creditLimitBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7 + 50;
			}
			this.creditLimitBiWeeklyPlus7 = (this.creditLimitBiWeeklyPlus7 / 100).round(System.RoundingMode.HALF_UP) * 100;
		}

		return this.creditLimitBiWeeklyPlus7;
	}


	/*******************************************************************************
    *  Name            : getCreditLimitBiWeeklyPlus7()
    *  Summary         : Calculate Credit Limit BiWeekly Plus 7   
    *  CreatedDate     : 18/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Decimal
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
	*  CreatedDate     : 18/10/2018
	*  ModifiedDate    : 28/11/2018
	*  Parameters      : -
	*  Returns         : Decimal
	******************************************************************************/
	public Decimal getMaxCreditLimitBiWeeklyPlus7() {
		if (this.maxCreditLimitBiWeeklyPlus7 != null) {
			this.maxCreditLimitBiWeeklyPlus7 = (this.maxCreditLimitBiWeeklyPlus7 / 100).round(System.RoundingMode.HALF_UP) * 100;
		}

		return this.maxCreditLimitBiWeeklyPlus7;
	}


	/*******************************************************************************
	*  Name            : setMaxCreditLimitBiWeeklyPlus7()
	*  Summary         : Calculate Max Credit Limit BiWeekly Plus 7
	*  CreatedDate     : 18/10/2018
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
			}
	    } catch (Exception e) {
	    	System.debug('Credit Factory === ' + e.getMessage());
	    	throw new CreditFactoryException('Max Credit Limit BiWeekly + 7 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
	    }
	}


	/*******************************************************************************
	*  Name            : setMaxCreditLimitBiWeeklyPlus7Rating1()
	*  Summary         : Calculate Max Credit Limit BiWeekly Plus 7 for Rating 1    
	*  CreatedDate     : 19/10/2018
	*  ModifiedDate    : 08/04/2019
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setMaxCreditLimitBiWeeklyPlus7Rating1() {
		Decimal totalConsumption = this.sourceObject.Total_consumption_l_month__c;
		if (totalConsumption != null && totalConsumption != 0) {
			Decimal nonFuelExposure = 0;
			if (this.sourceObject.Non_fuel_exposure__c != null) nonFuelExposure = this.sourceObject.Non_fuel_exposure__c;
			Decimal creditLimit2000BiWeeklyPlus7 = (((Decimal)this.sourceObject.get(this.opportunityMapping.Monthly_Volume_Currency__c) - nonFuelExposure) / totalConsumption * 2000 + 
				this.sourceObject.Non_fuel_exposure__c) * (15.0 + 7.0) / 30.0 * (1.0 + 0.2);
			this.maxCreditLimitBiWeeklyPlus7 = creditLimit2000BiWeeklyPlus7;
		} else {
			this.maxCreditLimitBiWeeklyPlus7 = 0;
		}
	}


	/*******************************************************************************
	*  Name            : setMaxCreditLimitBiWeeklyPlus7Rating2()
	*  Summary         : Calculate Max Credit Limit BiWeekly Plus 7 for Rating 2
	*  CreatedDate     : 19/10/2018
	*  ModifiedDate    : 08/04/2019
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setMaxCreditLimitBiWeeklyPlus7Rating2() {
		Decimal totalConsumption = this.sourceObject.Total_consumption_l_month__c;
		if (totalConsumption != null && totalConsumption != 0) {
			Decimal nonFuelExposure = 0;
			if (this.sourceObject.Non_fuel_exposure__c != null) nonFuelExposure = this.sourceObject.Non_fuel_exposure__c;
			Decimal creditLimit2000BiWeeklyPlus7 = (((Decimal)this.sourceObject.get(this.opportunityMapping.Monthly_Volume_Currency__c) - nonFuelExposure) / totalConsumption * 2000 + 
				this.sourceObject.Non_fuel_exposure__c) * (15.0 + 7.0) / 30.0 * (1.0 + 0.1);
			this.maxCreditLimitBiWeeklyPlus7 = creditLimit2000BiWeeklyPlus7;
		} else {
			this.maxCreditLimitBiWeeklyPlus7 = 0;
		}
	}


	public Decimal getMaxValueBiWeeklyPlus7() {
		return null;
	}


	public void setMaxValueBiWeeklyPlus7() {}
	

	/*******************************************************************************
	*  Name            : getDepositBiWeeklyPlus7()
	*  Summary         : Return Deposit BiWeekly Plus 7
	*  CreatedDate     : 18/10/2018
	*  ModifiedDate    : 24/10/2018
	*  Parameters      : -
	*  Returns         : Decimal
	******************************************************************************/
	public Decimal getDepositBiWeeklyPlus7() {
		if (this.depositBiWeeklyPlus7 != null) {
			if (this.depositBiWeeklyPlus7 > 0 && this.depositBiWeeklyPlus7 < 50) {
				this.depositBiWeeklyPlus7 = this.depositBiWeeklyPlus7 + 50;
			}
			this.depositBiWeeklyPlus7 = (this.depositBiWeeklyPlus7 / 100).round(System.RoundingMode.HALF_UP) * 100;
		}

		return this.depositBiWeeklyPlus7;
	}


	/*******************************************************************************
	*  Name            : setDepositBiWeeklyPlus7()
	*  Summary         : Calculate Deposit BiWeekly Plus 7    
	*  CreatedDate     : 18/10/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void setDepositBiWeeklyPlus7() {
		try {
			if (this.company.obligationOverdue == true) {
				this.depositBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7;
				this.securityLevelBiWeeklyPlus7 = 100;
			} else if (this.company.dateoffoundation != null && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(0, 4)), 
					Integer.valueOf(this.company.dateoffoundation.substring(4, 6)), Integer.valueOf(this.company.dateoffoundation.substring(6, 8))).monthsBetween(Date.today()) < 18) {
				this.depositBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7;
				this.securityLevelBiWeeklyPlus7 = 100;
			} else if (this.company.classRating == '1') {
				setDepositBiWeeklyPlus7Rating1();
			} else if (this.company.classRating == '2') {
				setDepositBiWeeklyPlus7Rating2();
			} else {
				this.depositBiWeeklyPlus7 = 0;
			}
		} catch (Exception e) {
			System.debug('Credit Factory === ' + e.getMessage());
			throw new CreditFactoryException('Deposit BiWeekly + 7 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}
	}


	/*******************************************************************************
	*  Name            : setDepositBiWeeklyPlus7Rating1()
	*  Summary         : Calculate Deposit BiWeekly Plus 7 for Rating 1    
	*  CreatedDate     : 18/10/2018
	*  ModifiedDate    : 29/10/2018
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setDepositBiWeeklyPlus7Rating1() {
		if (Integer.valueOf(this.sourceObject.get(this.opportunityMapping.Fuel_consumption_l_month__c)) <= 1500) {
			this.depositBiWeeklyPlus7 = 0;
		} else {
			if (this.sourceObject.Profit_loss_last_year__c == 0 && this.sourceObject.Profit_loss_year_before_last__c == 0) {
				this.depositBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7;
				this.securityLevelBiWeeklyPlus7 = 100;
			} else if (this.sourceObject.Profit_loss_last_year__c < 0) {
				this.depositBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7;
				this.securityLevelBiWeeklyPlus7 = 100;
			} else if (this.sourceObject.Profit_loss_last_year__c > 0 && this.sourceObject.Profit_loss_year_before_last__c < 0) {
				this.depositBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7 * 0.7;
				this.securityLevelBiWeeklyPlus7 = 70;
			} else if (this.sourceObject.Profit_loss_last_year__c <= 20000 || this.sourceObject.Profit_loss_year_before_last__c <= 35000) {
				this.depositBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7 * 0.5;
				this.securityLevelBiWeeklyPlus7 = 50;
			} else if (this.creditLimitBiWeeklyPlus7 > this.sourceObject.Profit_loss_last_year__c) {
				this.depositBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7 * 0.5;
				this.securityLevelBiWeeklyPlus7 = 50;
			} else if (this.creditLimitBiWeeklyPlus7 > this.sourceObject.Turnover_last_year__c * 0.1) {
				this.depositBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7 * 0.5;
				this.securityLevelBiWeeklyPlus7 = 50;
			} else {
				this.depositBiWeeklyPlus7 = 0;
			}
		}
	}


	/*******************************************************************************
	*  Name            : setDepositBiWeeklyPlus7Rating2()
	*  Summary         : Calculate Deposit BiWeekly Plus 7 for Rating 2
	*  CreatedDate     : 18/10/2018
	*  ModifiedDate    : 29/10/2018
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setDepositBiWeeklyPlus7Rating2() {
		if (Integer.valueOf(this.sourceObject.get(this.opportunityMapping.Fuel_consumption_l_month__c)) <= 1500) {
			if (this.policyRulesPriority != null) {
				if (this.policyRulesPriority == '2') {
					this.depositBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7;
					this.securityLevelBiWeeklyPlus7 = 100;
				} else if (this.policyRulesPriority == '3') {
					if (this.company.LegalForm == 'Private person company' || this.company.LegalForm == 'General partnership' || 
							this.company.LegalForm == 'private company' || this.company.LegalForm == 'Partnership company' || 
							this.company.LegalForm == 'Single person company confirmed') {
						this.depositBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7;
						this.securityLevelBiWeeklyPlus7 = 100;
					} else {
						this.depositBiWeeklyPlus7 = 0;
					}
				} else if (this.policyRulesPriority == '4') {
					this.depositBiWeeklyPlus7 = 0;
				}
			} else if (this.company.nameChangeDecision == 'YELLOW' || this.company.addressChangeDecision == 'YELLOW') {
				this.depositBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7;
				this.securityLevelBiWeeklyPlus7 = 100;
			}
		} else {
			if (this.sourceObject.Profit_loss_last_year__c == 0 && this.sourceObject.Profit_loss_year_before_last__c == 0) {
				this.depositBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7;
				this.securityLevelBiWeeklyPlus7 = 100;
			} else if (this.sourceObject.Profit_loss_last_year__c < 0) {
				this.depositBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7;
				this.securityLevelBiWeeklyPlus7 = 100;
			} else if (this.sourceObject.Profit_loss_last_year__c > 0 && this.sourceObject.Profit_loss_year_before_last__c < 0) {
				this.depositBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7 * 0.7;
				this.securityLevelBiWeeklyPlus7 = 70;
			} else if (this.sourceObject.Profit_loss_last_year__c <= 20000 || this.sourceObject.Profit_loss_year_before_last__c <= 35000) {
				this.depositBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7 * 0.5;
				this.securityLevelBiWeeklyPlus7 = 50;
			} else if (this.creditLimitBiWeeklyPlus7 > this.sourceObject.Profit_loss_last_year__c) {
				this.depositBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7 * 0.5;
				this.securityLevelBiWeeklyPlus7 = 50;
			} else if (this.creditLimitBiWeeklyPlus7 > this.sourceObject.Turnover_last_year__c * 0.1) {
				this.depositBiWeeklyPlus7 = this.creditLimitBiWeeklyPlus7 * 0.5;
				this.securityLevelBiWeeklyPlus7 = 50;
			} else {
				this.depositBiWeeklyPlus7 = 0;
			}
		}
	}


	/*******************************************************************************
    *  Name            : getCreditLimitBiWeeklyPlus14()
    *  Summary         : Calculate Credit Limit BiWeekly Plus 14    
    *  CreatedDate     : 10/10/2018
    *  ModifiedDate    : 28/11/2018
    *  Parameters      : -
    *  Returns         : Decimal
    ******************************************************************************/
	public Decimal getCreditLimitBiWeeklyPlus14() {
		if (this.creditLimitBiWeeklyPlus14 != null) {
			if (this.creditLimitBiWeeklyPlus14 < 50) {
				this.creditLimitBiWeeklyPlus14 = this.creditLimitBiWeeklyPlus14 + 50;
			}
			this.creditLimitBiWeeklyPlus14 = (this.creditLimitBiWeeklyPlus14 / 100).round(System.RoundingMode.HALF_UP) * 100;
		}

		return this.creditLimitBiWeeklyPlus14;
	}


	/*******************************************************************************
    *  Name            : setCreditLimitBiWeeklyPlus14(Decimal buffer)
    *  Summary         : Calculate Credit Limit BiWeekly Plus 14
    *  CreatedDate     : 10/05/2018
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
	*  CreatedDate     : 16/03/2018
	*  ModifiedDate    : 28/11/2018
	*  Parameters      : -
	*  Returns         : Decimal
	******************************************************************************/
	public Decimal getMaxCreditLimitBiWeeklyPlus14() {
		if (this.maxCreditLimitBiWeeklyPlus14 != null) {
			this.maxCreditLimitBiWeeklyPlus14 = (this.maxCreditLimitBiWeeklyPlus14 / 100).round(System.RoundingMode.HALF_UP) * 100;
		}
		return this.maxCreditLimitBiWeeklyPlus14;
	}


	/*******************************************************************************
	*  Name            : setMaxCreditLimitBiWeeklyPlus14()
	*  Summary         : Calculate Max Credit Limit BiWeekly Plus 14
	*  CreatedDate     : 16/03/2018
	*  ModifiedDate    : 19/10/2018
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void setMaxCreditLimitBiWeeklyPlus14() {
		try {
			if (this.company.classRating == '1') {
				setMaxCreditLimitBiWeeklyPlus14Rating1();
			} else if (this.company.classRating == '2') {
				setMaxCreditLimitBiWeeklyPlus14Rating2();
			}
	    } catch (Exception e) {
	    	System.debug('Credit Factory === ' + e.getMessage());
	    	throw new CreditFactoryException('Max Credit Limit BiWeekly + 14 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
	    }
	}


	/*******************************************************************************
	*  Name            : setMaxCreditLimitBiWeeklyPlus14Rating1()
	*  Summary         : Calculate Max Credit Limit BiWeekly Plus 14 Rating 1
	*  CreatedDate     : 19/10/2018
	*  ModifiedDate    : 08/04/2019
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setMaxCreditLimitBiWeeklyPlus14Rating1() {
		Decimal totalConsumption = this.sourceObject.Total_consumption_l_month__c;
		if (totalConsumption != null && totalConsumption != 0) {
			Decimal nonFuelExposure = 0;
			if (this.sourceObject.Non_fuel_exposure__c != null) nonFuelExposure = this.sourceObject.Non_fuel_exposure__c;
			Decimal creditLimit8000BiWeeklyPlus7 = (((Decimal)this.sourceObject.get(this.opportunityMapping.Monthly_Volume_Currency__c) - nonFuelExposure) / totalConsumption * 8000 + 
				this.sourceObject.Non_fuel_exposure__c) * (15.0 + 14.0) / 30.0 * (1.0 + 0.2);
			Decimal creditLimit2000BiWeeklyPlus7 = (((Decimal)this.sourceObject.get(this.opportunityMapping.Monthly_Volume_Currency__c) - nonFuelExposure) / totalConsumption * 2000 + 
				this.sourceObject.Non_fuel_exposure__c) * (15.0 + 14.0) / 30.0 * (1.0 + 0.2);

			if (this.userSource == 'E2E Long Form') {
				if (this.creditLimitBiWeeklyPlus14 * 2 <= creditLimit8000BiWeeklyPlus7) {
					this.maxCreditLimitBiWeeklyPlus14 = this.creditLimitBiWeeklyPlus14 * 2;
				} else {
					this.maxCreditLimitBiWeeklyPlus14 = creditLimit8000BiWeeklyPlus7;
				}
			} else {
				this.maxCreditLimitBiWeeklyPlus14 = creditLimit2000BiWeeklyPlus7;
			}
		} else {
			this.maxCreditLimitBiWeeklyPlus14 = 0;
		}
	}


	/*******************************************************************************
	*  Name            : setMaxCreditLimitBiWeeklyPlus14Rating2()
	*  Summary         : Calculate Max Credit Limit BiWeekly Plus 14 Rating 2 
	*  CreatedDate     : 19/10/2018
	*  ModifiedDate    : 08/04/2019
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setMaxCreditLimitBiWeeklyPlus14Rating2() {
		Decimal totalConsumption = this.sourceObject.Total_consumption_l_month__c;
		if (totalConsumption != null && totalConsumption != 0) {
			Decimal nonFuelExposure = 0;
			if (this.sourceObject.Non_fuel_exposure__c != null) nonFuelExposure = this.sourceObject.Non_fuel_exposure__c;
			Decimal creditLimit8000BiWeeklyPlus7 = (((Decimal)this.sourceObject.get(this.opportunityMapping.Monthly_Volume_Currency__c) - nonFuelExposure) / totalConsumption * 8000 + 
				this.sourceObject.Non_fuel_exposure__c) * (15.0 + 14.0) / 30.0 * (1.0 + 0.1);
			Decimal creditLimit2000BiWeeklyPlus7 = (((Decimal)this.sourceObject.get(this.opportunityMapping.Monthly_Volume_Currency__c) - nonFuelExposure) / totalConsumption * 2000 + 
				this.sourceObject.Non_fuel_exposure__c) * (15.0 + 14.0) / 30.0 * (1.0 + 0.1);

			if (this.userSource == 'E2E Long Form') {
				if (this.creditLimitBiWeeklyPlus14 * 2 <= creditLimit8000BiWeeklyPlus7) {
					this.maxCreditLimitBiWeeklyPlus14 = this.creditLimitBiWeeklyPlus14 * 2;
				} else {
					this.maxCreditLimitBiWeeklyPlus14 = creditLimit8000BiWeeklyPlus7;
				}
			} else {
				this.maxCreditLimitBiWeeklyPlus14 = creditLimit2000BiWeeklyPlus7;
			}
		} else {
			this.maxCreditLimitBiWeeklyPlus14 = 0;
		}
	}


	/*******************************************************************************
	*  Name            : getDepositBiWeeklyPlus14()
	*  Summary         : Return Deposit BiWeekly Plus 14
	*  CreatedDate     : 10/10/2018
	*  ModifiedDate    : 24/10/2018
	*  Parameters      : -
	*  Returns         : Decimal
	******************************************************************************/
	public Decimal getDepositBiWeeklyPlus14() {
		if (this.depositBiWeeklyPlus14 != null) {
			if (this.depositBiWeeklyPlus14 > 0 && this.depositBiWeeklyPlus14 < 50) {
				this.depositBiWeeklyPlus14 = this.depositBiWeeklyPlus14 + 50;
			}
			this.depositBiWeeklyPlus14 = (this.depositBiWeeklyPlus14 / 100).round(System.RoundingMode.HALF_UP) * 100;
		}

		return this.depositBiWeeklyPlus14;
	}


	/*******************************************************************************
	*  Name            : setDepositBiWeeklyPlus7()
	*  Summary         : Calculate Deposit BiWeekly Plus 7    
	*  CreatedDate     : 11/10/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void setDepositBiWeeklyPlus14() {
		try {
			if (this.company.obligationOverdue == true) {
				this.depositBiWeeklyPlus14 = this.creditLimitBiWeeklyPlus14;
				this.securityLevelBiWeeklyPlus14 = 100;
			} else if (this.company.dateoffoundation != null && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(0, 4)), 
					Integer.valueOf(this.company.dateoffoundation.substring(4, 6)), Integer.valueOf(this.company.dateoffoundation.substring(6, 8))).monthsBetween(Date.today()) < 18) {
				this.depositBiWeeklyPlus14 = this.creditLimitBiWeeklyPlus14;
				this.securityLevelBiWeeklyPlus14 = 100;
			} else if (this.company.classRating == '1') {
				setDepositBiWeeklyPlus14Rating1();
			} else if (this.company.classRating == '2') {
				setDepositBiWeeklyPlus14Rating2();
			} else {
				this.depositBiWeeklyPlus14 = 0;
			}
		} catch (Exception e) {
			System.debug('Credit Factory === ' + e.getMessage());
			throw new CreditFactoryException('Deposit BiWeekly + 14 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}
	}


	/*******************************************************************************
	*  Name            : setDepositBiWeeklyPlus14Rating1()
	*  Summary         : Calculate Deposit BiWeekly Plus 14 for Rating 1    
	*  CreatedDate     : 11/10/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setDepositBiWeeklyPlus14Rating1() {
		if (this.userSource == 'E2E Long Form' || Integer.valueOf(this.sourceObject.get(this.opportunityMapping.Fuel_consumption_l_month__c)) <= 1500) {
			this.depositBiWeeklyPlus14 = 0;
		} else {
			if (this.sourceObject.Profit_loss_last_year__c == 0 && this.sourceObject.Profit_loss_year_before_last__c == 0) {
				this.depositBiWeeklyPlus14 = this.creditLimitBiWeeklyPlus14;
				this.securityLevelBiWeeklyPlus14 = 100;
			} else if (this.sourceObject.Profit_loss_last_year__c < 0) {
				this.depositBiWeeklyPlus14 = this.creditLimitBiWeeklyPlus14;
				this.securityLevelBiWeeklyPlus14 = 100;
			} else if (this.sourceObject.Profit_loss_last_year__c > 0 && this.sourceObject.Profit_loss_year_before_last__c < 0) {
				this.depositBiWeeklyPlus14 = this.creditLimitBiWeeklyPlus14 * 0.7;
				this.securityLevelBiWeeklyPlus14 = 70;
			} else if (this.sourceObject.Profit_loss_last_year__c <= 20000 || this.sourceObject.Profit_loss_year_before_last__c <= 35000) {
				this.depositBiWeeklyPlus14 = this.creditLimitBiWeeklyPlus14 * 0.5;
				this.securityLevelBiWeeklyPlus14 = 50;
			} else if (this.creditLimitBiWeeklyPlus14 > this.sourceObject.Profit_loss_last_year__c) {
				this.depositBiWeeklyPlus14 = this.creditLimitBiWeeklyPlus14 * 0.5;
				this.securityLevelBiWeeklyPlus14 = 50;
			} else if (this.creditLimitBiWeeklyPlus14 > this.sourceObject.Turnover_last_year__c * 0.1) {
				this.depositBiWeeklyPlus14 = this.creditLimitBiWeeklyPlus14 * 0.5;
				this.securityLevelBiWeeklyPlus14 = 50;
			} else {
				this.depositBiWeeklyPlus14 = 0;
			}
		}
	}


	/*******************************************************************************
	*  Name            : setDepositBiWeeklyPlus14Rating2()
	*  Summary         : Calculate Deposit BiWeekly Plus 14 for Rating 2
	*  CreatedDate     : 11/10/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setDepositBiWeeklyPlus14Rating2() {
		if (this.userSource == 'E2E Long Form' || Integer.valueOf(this.sourceObject.get(this.opportunityMapping.Fuel_consumption_l_month__c)) <= 1500) {
			if (this.policyRulesPriority != null) {
				if (this.policyRulesPriority == '2') {
					this.depositBiWeeklyPlus14 = this.creditLimitBiWeeklyPlus14;
					this.securityLevelBiWeeklyPlus14 = 100;
				} else if (this.policyRulesPriority == '3') {
					if (this.company.LegalForm == 'Private person company' || this.company.LegalForm == 'General partnership' || 
							this.company.LegalForm == 'private company' || this.company.LegalForm == 'Partnership company' || 
							this.company.LegalForm == 'Single person company confirmed') {
						this.depositBiWeeklyPlus14 = this.creditLimitBiWeeklyPlus14;
						this.securityLevelBiWeeklyPlus14 = 100;
					} else {
						this.depositBiWeeklyPlus14 = 0;
					}
				} else if (this.policyRulesPriority == '4') {
					this.depositBiWeeklyPlus14 = 0;
				}
			} else if (this.company.nameChangeDecision == 'YELLOW' || this.company.addressChangeDecision == 'YELLOW') {
				this.depositBiWeeklyPlus14 = this.creditLimitBiWeeklyPlus14;
				this.securityLevelBiWeeklyPlus14 = 100;
			}
		} else {
			if (this.sourceObject.Profit_loss_last_year__c == 0 && this.sourceObject.Profit_loss_year_before_last__c == 0) {
				this.depositBiWeeklyPlus14 = this.creditLimitBiWeeklyPlus14;
				this.securityLevelBiWeeklyPlus14 = 100;
			} else if (this.sourceObject.Profit_loss_last_year__c < 0) {
				this.depositBiWeeklyPlus14 = this.creditLimitBiWeeklyPlus14;
				this.securityLevelBiWeeklyPlus14 = 100;
			} else if (this.sourceObject.Profit_loss_last_year__c > 0 && this.sourceObject.Profit_loss_year_before_last__c < 0) {
				this.depositBiWeeklyPlus14 = this.creditLimitBiWeeklyPlus14 * 0.7;
				this.securityLevelBiWeeklyPlus14 = 70;
			} else if (this.sourceObject.Profit_loss_last_year__c <= 20000 || this.sourceObject.Profit_loss_year_before_last__c <= 35000) {
				this.depositBiWeeklyPlus14 = this.creditLimitBiWeeklyPlus14 * 0.5;
				this.securityLevelBiWeeklyPlus14 = 50;
			} else if (this.creditLimitBiWeeklyPlus14 > this.sourceObject.Profit_loss_last_year__c) {
				this.depositBiWeeklyPlus14 = this.creditLimitBiWeeklyPlus14 * 0.5;
				this.securityLevelBiWeeklyPlus14 = 50;
			} else if (this.creditLimitBiWeeklyPlus14 > this.sourceObject.Turnover_last_year__c * 0.1) {
				this.depositBiWeeklyPlus14 = this.creditLimitBiWeeklyPlus14 * 0.5;
				this.securityLevelBiWeeklyPlus14 = 50;
			} else {
				this.depositBiWeeklyPlus14 = 0;
			}
		}
	}


	/*******************************************************************************
	*  Name            : getMaxValueBiWeeklyPlus14()
	*  Summary         : Return Max value of Credit Limit including deposit BiWeekly Plus 14
	*  CreatedDate     : 11/10/2018
	*  ModifiedDate    : 28/11/2018
	*  Parameters      : -
	*  Returns         : Decimal
	******************************************************************************/
	public Decimal getMaxValueBiWeeklyPlus14() {
		if (this.maxValueBiWeeklyPlus14 != null) {
			this.maxValueBiWeeklyPlus14 = (this.maxValueBiWeeklyPlus14 / 100).round(System.RoundingMode.HALF_UP) * 100;
		}
		return this.maxValueBiWeeklyPlus14;
	}


	/*******************************************************************************
	*  Name            : setMaxValueBiWeeklyPlus14()
	*  Summary         : Calculate Max value of Credit Limit including deposit BiWeekly Plus 14
	*  CreatedDate     : 10/10/2018
	*  ModifiedDate    : 19/10/2018
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void setMaxValueBiWeeklyPlus14() {
		try {
			if (this.company.classRating == '1') {
				setMaxValueBiWeeklyPlus14Rating1();
			} else if (this.company.classRating == '2') {
				setMaxValueBiWeeklyPlus14Rating2();
			}
	    } catch (Exception e) {
	    	System.debug('Credit Factory === ' + e.getMessage());
	    	throw new CreditFactoryException('Max Value BiWeekly + 14 calculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
	    }
	}


	/*******************************************************************************
	*  Name            : setMaxValueBiWeeklyPlus14Rating1()
	*  Summary         : Calculate Max value of Credit Limit including deposit Bi-Weekly Plus 14 for Rating 1
	*  CreatedDate     : 19/10/2018
	*  ModifiedDate    : 08/04/2019
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setMaxValueBiWeeklyPlus14Rating1() {
		Decimal totalConsumption = this.sourceObject.Total_consumption_l_month__c;
		if (totalConsumption != null && totalConsumption != 0) {
			Decimal nonFuelExposure = 0;
			if (this.sourceObject.Non_fuel_exposure__c != null) nonFuelExposure = this.sourceObject.Non_fuel_exposure__c;
			Decimal creditLimit8000BiWeeklyPlus7 = (((Decimal)this.sourceObject.get(this.opportunityMapping.Monthly_Volume_Currency__c) - nonFuelExposure) / totalConsumption * 8000 + 
				this.sourceObject.Non_fuel_exposure__c) * (15.0 + 14.0) / 30.0 * (1.0 + 0.2);

			if (this.creditLimitBiWeeklyPlus14 * 2 <= creditLimit8000BiWeeklyPlus7) {
				this.maxValueBiWeeklyPlus14 = this.creditLimitBiWeeklyPlus14 * 2;
			} else {
				this.maxValueBiWeeklyPlus14 = creditLimit8000BiWeeklyPlus7;
			}
		} else {
			this.maxValueBiWeeklyPlus14 = 0;
		}
	}


	/*******************************************************************************
	*  Name            : setMaxValueBiWeeklyPlus14Rating2()
	*  Summary         : Calculate Max value of Credit Limit including deposit Bi-Weekly Plus 14 for Rating 2
	*  CreatedDate     : 19/10/2018
	*  ModifiedDate    : 08/04/2019
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setMaxValueBiWeeklyPlus14Rating2() {
		Decimal totalConsumption = this.sourceObject.Total_consumption_l_month__c;
		if (totalConsumption != null && totalConsumption != 0) {
			Decimal nonFuelExposure = 0;
			if (this.sourceObject.Non_fuel_exposure__c != null) nonFuelExposure = this.sourceObject.Non_fuel_exposure__c;
			Decimal creditLimit8000BiWeeklyPlus7 = (((Decimal)this.sourceObject.get(this.opportunityMapping.Monthly_Volume_Currency__c) - nonFuelExposure) / totalConsumption * 8000 + 
				this.sourceObject.Non_fuel_exposure__c) * (15.0 + 14.0) / 30.0 * (1.0 + 0.1);
			Decimal creditLimit2000BiWeeklyPlus7 = (((Decimal)this.sourceObject.get(this.opportunityMapping.Monthly_Volume_Currency__c) - nonFuelExposure) / totalConsumption * 2000 + 
				this.sourceObject.Non_fuel_exposure__c) * (15.0 + 14.0) / 30.0 * (1.0 + 0.1);

			if (this.creditLimitBiWeeklyPlus14 * 2 <= creditLimit8000BiWeeklyPlus7) {
				this.maxValueBiWeeklyPlus14 = this.creditLimitBiWeeklyPlus14 * 2;
			} else {
				this.maxValueBiWeeklyPlus14 = creditLimit8000BiWeeklyPlus7;
			}
		} else {
			this.maxValueBiWeeklyPlus14 = 0;
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
	*  ModifiedDate    : 16/03/2018
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void setPaymentDetails() {
		if (this.company.classRating == '1') {
			setPaymentDetailsRating1();
		} else if (this.company.classRating == '2') {
			setPaymentDetailsRating2();
		}
	}


	/*******************************************************************************
	*  Name 		   : setPaymentDetailsRating1()
	*  Summary         : Calculate payment details (billing period, payment terms) for rating 1
	*  CreatedDate     : 10/01/2018
	*  ModifiedDate    : 08/04/2019
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setPaymentDetailsRating1() {
		Boolean eInvoicingOnly = false;
		if (this.sourceObject.e_Invoicing_PDF__c == true && this.sourceObject.Papierrechnung__c == false) {
			eInvoicingOnly = true;
		}

		if (this.userSource == 'E2E Long Form' && Integer.valueOf(this.sourceObject.get(this.opportunityMapping.Fuel_consumption_l_month__c)) <= 8000) {
			this.billingPeriod = 15;
			this.paymentTerms = 14;
		} else if (this.userSource != 'E2E Long Form' && Integer.valueOf(this.sourceObject.get(this.opportunityMapping.Fuel_consumption_l_month__c)) <= 2000) {
			if (this.depositBiWeeklyPlus14 == 0) {
				if (this.sourceObject.Zahlungsziel_2__c == '7' && this.sourceObject.Rechnungsperiode_2__c == '7' && eInvoicingOnly == true) {
					this.billingPeriod = 7;
					this.paymentTerms = 7;
				} else if (this.sourceObject.Zahlungsziel_2__c == '15' && this.sourceObject.Rechnungsperiode_2__c == '7' && eInvoicingOnly == true 
						&& this.userSource != 'E2E Long Form') {
					this.billingPeriod = 15;
					this.paymentTerms = 7;
				} else {
					this.billingPeriod = 15;
					this.paymentTerms = 14;
				}
			} else if (this.depositBiWeeklyPlus7 == 0 && eInvoicingOnly == true && this.userSource != 'E2E Long Form') {
				if (this.sourceObject.Zahlungsziel__c == '7' && this.sourceObject.Rechnungsperiode_2__c == '7') {
					this.billingPeriod = 7;
					this.paymentTerms = 7;
				} else {
					this.billingPeriod = 15;
					this.paymentTerms = 7;
				}
			} else if (this.depositWeeklyPlus7 == 0 && eInvoicingOnly == true) {
				this.billingPeriod = 7;
				this.paymentTerms = 7;
			} else {
				if (this.sourceObject.Zahlungsziel_2__c == '7' && this.sourceObject.Rechnungsperiode_2__c == '7' && eInvoicingOnly == true) {
					this.billingPeriod = 7;
					this.paymentTerms = 7;
				} else if (this.sourceObject.Zahlungsziel_2__c == '15' && this.sourceObject.Rechnungsperiode_2__c == '7' && eInvoicingOnly == true && this.userSource != 'E2E Long Form') {
					this.billingPeriod = 15;
					this.paymentTerms = 7;
				} else {
					this.billingPeriod = 15;
					this.paymentTerms = 14;
				}
			}
		}
	}

	/*******************************************************************************
	*  Name 		   : setPaymentDetailsRating2()
	*  Summary         : Calculate payment details (billing period, payment terms) for rating 2
	*  CreatedDate     : 10/01/2018
	*  ModifiedDate    : 08/04/2019
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void setPaymentDetailsRating2() {
		Boolean isError = true;
		if (this.policyRulesPriority != '1' && ! (this.policyRulesPriority == null && this.company.nameChangeDecision != 'YELLOW' && this.company.addressChangeDecision != 'YELLOW') || 
				this.company.obligationOverdue == true || this.company.dateoffoundation != null && Date.newInstance(Integer.valueOf(this.company.dateoffoundation.substring(0, 4)), 
				Integer.valueOf(this.company.dateoffoundation.substring(4, 6)), Integer.valueOf(this.company.dateoffoundation.substring(6, 8))).monthsBetween(Date.today()) < 18) {
			isError = false;
		}

		Boolean eInvoicingOnly = false;
		if (this.sourceObject.e_Invoicing_PDF__c == true && this.sourceObject.Papierrechnung__c == false) {
			eInvoicingOnly = true;
		}

		if (this.userSource == 'E2E Long Form' && Integer.valueOf(this.sourceObject.get(this.opportunityMapping.Fuel_consumption_l_month__c)) <= 8000 && isError == false) {
			this.billingPeriod = 15;
			this.paymentTerms = 14;
		} else if (this.userSource != 'E2E Long Form' && Integer.valueOf(this.sourceObject.get(this.opportunityMapping.Fuel_consumption_l_month__c)) <= 2000) {
			if (this.depositBiWeeklyPlus14 == 0) {
				if (isError == false || Integer.valueOf(this.sourceObject.get(this.opportunityMapping.Fuel_consumption_l_month__c)) > 1500) { 
					if (this.sourceObject.Zahlungsziel_2__c == '7' && this.sourceObject.Rechnungsperiode_2__c == '7' && eInvoicingOnly == true) {
						this.billingPeriod = 7;
						this.paymentTerms = 7;
					} else if (this.sourceObject.Zahlungsziel_2__c == '15' && this.sourceObject.Rechnungsperiode_2__c == '7' && eInvoicingOnly == true && this.userSource != 'E2E Long Form') {
						this.billingPeriod = 15;
						this.paymentTerms = 7;
					} else {
						this.billingPeriod = 15;
						this.paymentTerms = 14;
					}
				}
			} else if (this.depositBiWeeklyPlus7 == 0 && eInvoicingOnly == true && this.userSource != 'E2E Long Form') {
				if (isError == false || Integer.valueOf(this.sourceObject.get(this.opportunityMapping.Fuel_consumption_l_month__c)) > 1500) { 
					if (this.sourceObject.Zahlungsziel__c == '7' && this.sourceObject.Rechnungsperiode_2__c == '7') {
						this.billingPeriod = 7;
						this.paymentTerms = 7;
					} else {
						this.billingPeriod = 15;
						this.paymentTerms = 7;
					}
				}
			} else if (this.depositWeeklyPlus7 == 0 && eInvoicingOnly == true) {
				if (isError == false || Integer.valueOf(this.sourceObject.get(this.opportunityMapping.Fuel_consumption_l_month__c)) > 1500) { 
					this.billingPeriod = 7;
					this.paymentTerms = 7;
				}
			} else {
				if (isError == false || Integer.valueOf(this.sourceObject.get(this.opportunityMapping.Fuel_consumption_l_month__c)) > 1500) { 
					if (this.sourceObject.Zahlungsziel_2__c == '7' && this.sourceObject.Rechnungsperiode_2__c == '7' && eInvoicingOnly == true) {
						this.billingPeriod = 7;
						this.paymentTerms = 7;
					} else if (this.sourceObject.Zahlungsziel_2__c == '15' && this.sourceObject.Rechnungsperiode_2__c == '7' && eInvoicingOnly == true && this.userSource != 'E2E Long Form') {
						this.billingPeriod = 15;
						this.paymentTerms = 7;
					} else {
						this.billingPeriod = 15;
						this.paymentTerms = 14;
					}
				}
			}
		}
	}


	/*******************************************************************************
	*  Name 		   : getBillingPeriod
	*  Summary         : Return billing period
	*  CreatedDate     : 10/01/2018
	*  ModifiedDate    : 10/01/2018
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
	*  ModifiedDate    : 18/10/2018
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void setCreditLimit() {
		try {
			if (this.billingPeriod == 15 && this.paymentTerms == 14) {
		    	this.creditLimit = getCreditLimitBiWeeklyPlus14();
		    } else if (this.billingPeriod == 15 && this.paymentTerms == 7) {
		    	this.creditLimit = getCreditLimitBiWeeklyPlus7();
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
	*  CreatedDate     : 15/10/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : Decimal
	******************************************************************************/
	public Decimal getCreditLimit() {
		return this.creditLimit;
	}


	/*******************************************************************************
	*  Name            : setMaxCreditLimit(Decimal selectedCreditLimit)
	*  Summary         : calculate max credit limit for selected credit limit
	*  CreatedDate     : 10/01/2018
	*  ModifiedDate    : 18/10/2018
	*  Parameters      : -
	*  Returns         : void 
	******************************************************************************/
	public void setMaxCreditLimit() {
		try {
			if (this.billingPeriod == 15 && this.paymentTerms == 14) {
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
	*  CreatedDate     : 10/10/2018
	*  ModifiedDate    : 18/10/2018
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
	*  CreatedDate     : 10/10/2018
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
	*  ModifiedDate    : 18/10/2018
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void setDeposit() {
		try {
			if (this.billingPeriod == 15 && this.paymentTerms == 14) {
				this.deposit = getDepositBiWeeklyPlus14(); 
				this.securityLevel = this.securityLevelBiWeeklyPlus14;
			} else if (this.billingPeriod == 15 && this.paymentTerms == 7) {
				this.deposit = getDepositBiWeeklyPlus7();
				this.securityLevel = this.securityLevelBiWeeklyPlus7;
			} else if (this.billingPeriod == 7 && this.paymentTerms == 7) {
				this.deposit = getDepositWeeklyPlus7();
				this.securityLevel = this.securityLevelWeeklyPlus7;
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
	*  ModifiedDate    : 16/10/2018
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
			List<Opportunity> opportunitiesList = [
			        SELECT Profit_loss_last_year__c, Profit_loss_year_before_last__c, Turnover_last_year__c,
			        		(SELECT Credit_Limit_Bi_Weekly_14__c, Credit_Limit_Weekly_7__c, Deposit_Bi_Weekly_14__c, Deposit_Weekly_7__c
			                FROM Credit_Factory_Reports__r
			                WHERE CreatedDate > :Date.today().addMonths(-3)
			                ORDER BY CreatedDate DESC
			                LIMIT 1)
			        FROM Opportunity
			        WHERE Id = :opportunityId];
			if (! opportunitiesList.isEmpty()) {
		        if (! opportunitiesList.get(0).Credit_Factory_Reports__r.isEmpty() && billingPeriod == 15 && paymentTerms == 14 && 
		        		creditLimit == opportunitiesList.get(0).Credit_Factory_Reports__r.get(0).Credit_Limit_Bi_Weekly_14__c) {
		        	this.deposit = opportunitiesList.get(0).Credit_Factory_Reports__r.get(0).Deposit_Bi_Weekly_14__c;
				} else if (! opportunitiesList.get(0).Credit_Factory_Reports__r.isEmpty() && billingPeriod == 7 && paymentTerms == 7 && 
		        		creditLimit == opportunitiesList.get(0).Credit_Factory_Reports__r.get(0).Credit_Limit_Weekly_7__c) {
		        	this.deposit = opportunitiesList.get(0).Credit_Factory_Reports__r.get(0).Deposit_Weekly_7__c;
		        } else if (company.obligationOverdue == true) {
					this.deposit = creditLimit;
				} else if (company.dateoffoundation != null && Date.newInstance(Integer.valueOf(company.dateoffoundation.substring(0, 4)), 
						Integer.valueOf(company.dateoffoundation.substring(4, 6)), Integer.valueOf(company.dateoffoundation.substring(6, 8))).monthsBetween(Date.today()) < 18) {
					this.deposit = creditLimit;
				} else if (company.classRating == '1') {
					this.deposit = resetDepositRating1(company, billingPeriod, paymentTerms, creditLimit, opportunitiesList.get(0).Profit_loss_last_year__c, 
						opportunitiesList.get(0).Profit_loss_year_before_last__c, opportunitiesList.get(0).Turnover_last_year__c);
				} else if (company.classRating == '2') {
					this.deposit = resetDepositRating2(company, billingPeriod, paymentTerms, creditLimit, opportunitiesList.get(0).Profit_loss_last_year__c, 
						opportunitiesList.get(0).Profit_loss_year_before_last__c, opportunitiesList.get(0).Turnover_last_year__c);
				}
			}
		} catch (Exception e) {
			System.debug('Credit Factory === ' + e.getMessage());
			throw new CreditFactoryException('Deposit recalculation failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}
	}


	/*******************************************************************************
	*  Name            : resetDepositRating1()
	*  Summary         : Reset deposit value for rating 1 and changed CL value.     
	*  CreatedDate     : 10/10/2018
	*  ModifiedDate    : 06/11/2018
	*  Parameters      : CreditCompany company - company from Credit System, 
						 Integer billingPeriod - selected billing period, 
						 Integer paymentTerms - selected payment terms,
						 Decimal creditLimit - changed CL value
						 Decimal profitLossLastYear - porfit/loss for the last year,
						 Decimal profitLossYearBeforeLast - profit/loss for year before the last, 
						 Decimal turnOverLastYear - turn over for the last year
	*  Returns         : Decimal
	******************************************************************************/
	private Decimal resetDepositRating1(CreditCompany company, Integer billingPeriod, Integer paymentTerms, Decimal creditLimit, Decimal profitLossLastYear,
			Decimal profitLossYearBeforeLast, Decimal turnOverLastYear) {
		return 0;
	}


	/*******************************************************************************
	*  Name            : resetDepositRating2()
	*  Summary         : Reset deposit value for rating 2 and changed CL value.
	*  CreatedDate     : 10/10/2018
	*  ModifiedDate    : 06/11/2018
	*  Parameters      : CreditCompany company - company from Credit System, 
						 Integer billingPeriod - selected billing period, 
						 Integer paymentTerms - selected payment terms,
						 Decimal creditLimit - changed CL value
						 Decimal profitLossLastYear - porfit/loss for the last year,
						 Decimal profitLossYearBeforeLast - profit/loss for year before the last, 
						 Decimal turnOverLastYear - turn over for the last year
	*  Returns         : Decimal
	******************************************************************************/
	private Decimal resetDepositRating2(CreditCompany company, Integer billingPeriod, Integer paymentTerms, Decimal creditLimit, Decimal profitLossLastYear,
			Decimal profitLossYearBeforeLast, Decimal turnOverLastYear) {
		setPolicyRulesPriority(company);
		if (this.policyRulesPriority != null) {
			if (this.policyRulesPriority == '2') {
				return creditLimit;
			} else if (this.policyRulesPriority == '3') {
				if (company.LegalForm == 'Private person company' || company.LegalForm == 'General partnership' || company.LegalForm == 'private company' ||
						company.LegalForm == 'Partnership company' || company.LegalForm == 'Single person company confirmed') {
					return creditLimit;
				} else {
					return 0;
				}
			} else if (this.policyRulesPriority == '4') {
				return 0;
			}
		} else if (company.nameChangeDecision == 'YELLOW' || company.addressChangeDecision == 'YELLOW') {
			return creditLimit;
		}

		return 0;
	}


	public Decimal getDeposit() {
		return this.deposit;
	}


	/*******************************************************************************
	*  Name            : setDecision()
	*  Summary         : Set company decision   
	*  CreatedDate     : 13/10/2018
	*  ModifiedDate    : 08/04/2019
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void setDecision() {
		try {
			this.decision = new CreditFactoryDecision();
			if (this.company.classRating == '1') {
				if (this.billingPeriod != null && this.paymentTerms != null && this.deposit == 0) {
					this.decision.verdict = 'Yes';
					this.decision.statusCode = '001'; // No Limits without deposit
				} else if (this.billingPeriod != null && this.paymentTerms != null && this.deposit != 0) {
					this.decision.verdict = 'Yes';
					this.decision.statusCode = '002'; // No Limits without deposit
				} else if (Integer.valueOf(this.sourceObject.get(this.opportunityMapping.Fuel_consumption_l_month__c)) > 8000 && this.userSource == 'E2E Long Form' || 
						Integer.valueOf(this.sourceObject.get(this.opportunityMapping.Fuel_consumption_l_month__c)) > 2000 && this.userSource != 'E2E Long Form') {
					this.decision.verdict = 'No';
					this.decision.statusCode = '003'; // Limit too hign and additional credit scoring allowance for E2E
				}
			} else if (this.company.classRating == '2') {
				if (this.billingPeriod != null && this.paymentTerms != null && this.deposit == 0) {
					this.decision.verdict = 'Yes';
					this.decision.statusCode = '001'; // No Limits without deposit
				} else if (this.billingPeriod != null && this.paymentTerms != null && this.deposit != 0) {
					this.decision.verdict = 'Yes';
					this.decision.statusCode = '002'; // No Limits with deposit
				} else if (Integer.valueOf(this.sourceObject.get(this.opportunityMapping.Fuel_consumption_l_month__c)) > 8000 && this.userSource == 'E2E Long Form' ||
						Integer.valueOf(this.sourceObject.get(this.opportunityMapping.Fuel_consumption_l_month__c)) > 2000 && this.userSource != 'E2E Long Form') {
					this.decision.verdict = 'No';
					this.decision.statusCode = '003'; // Limit too hign and additional credit scoring allowance for E2E
				} else if (this.policyRulesPriority == '1') {
					this.decision.verdict = 'No';
					this.decision.statusCode = '006'; // Policy rule (close lost)
				} else if (this.policyRulesPriority == null && this.company.nameChangeDecision != 'YELLOW' && this.company.addressChangeDecision != 'YELLOW') {
					this.decision.verdict = 'No';
					this.decision.statusCode = '005'; // Bad rating (refer to credit)
				}
			} else if (this.company.classRating == '3') {
				this.decision.verdict = 'No';
				this.decision.statusCode = '007'; // Bad rating (close lost)
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
					} else if (this.decision.statusCode == '006') {
						changeToClosedLost();
			            String exceptionString = 'Opportunity is Closed as Lost. Reasons:<br/><ul>';
			            for (String policyRule : this.currentPolicyRulesMap.get(this.policyRulesPriority)) {
			            	exceptionString += '<li>' + policyRule + '</li>';
			            }
			            exceptionString += '</ul>';
			 			CreditFactoryUtilities.displayMessage('error', exceptionString);
					} else if (this.decision.statusCode == '005') {
						CreditFactoryUtilities.displayMessage('error','Refer to credit (rating 2)');
					} else if (this.decision.statusCode == '007') {
						changeToClosedLost();
						CreditFactoryUtilities.displayMessage('error','Opportunity is closed as Lost (Rating 3)');
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
	*  Name            : changeToClosedLost()
	*  Summary         : Close Opportunity as Lost  
	*  CreatedDate     : 18/04/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	private void changeToClosedLost() {
		try {
			this.sourceObject.StageName = 'Closed Lost';
			this.sourceObject.Gruende_verloren__c = 'Refused Credit';
	        update this.sourceObject;
		} catch (Exception e) {
        	throw new CreditFactoryException('Change to Closed Lost failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}
	}


	/*******************************************************************************
	*  Name            : setDecision()
	*  Summary         : Set company decision   
	*  CreatedDate     : 13/10/2018
	*  ModifiedDate    : 22/12/2018
	*  Parameters      : Integer billingPeriod - selected billing period,Integer paymentTerms - selecred payment terms,
						 Decimal deposit - selected deposit, String classRating - current company class rating, 
						 Integer numberOfCards - number of cards, CreditCompany company - company from Credit System
	*  Returns         : void
	******************************************************************************/
	public void resetDecision(Integer billingPeriod, Integer paymentTerms, Decimal deposit, String classRating, Decimal numberOfCards, CreditCompany company) {
		try {
			this.decision = new CreditFactoryDecision();
			if (classRating == '1') {
				if (deposit == 0) {
					this.decision.verdict = 'Yes';
					this.decision.statusCode = '001'; // No Limits without deposit
				} else if (deposit != 0) {
					this.decision.verdict = 'Yes';
					this.decision.statusCode = '002'; // No Limits with deposit
				}
			} else if (classRating == '2') {
				if (deposit == 0) {
					this.decision.verdict = 'Yes';
					this.decision.statusCode = '001'; // No Limits without deposit
				} else if (deposit != 0) {
					this.decision.verdict = 'Yes';
					this.decision.statusCode = '002'; // No Limits with deposit
				}
			}
		} catch (Exception e) {
            System.debug('Credit Factory === ' + e.getMessage());
            throw new CreditFactoryException('Set Decision failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}
	}


	public CreditFactoryDecision getDecision() {
		return this.decision;
	}


	/*******************************************************************************
	*  Name            : checkWarnings()
	*  Summary         : check for warnings to display on page
	*  CreatedDate     : 22/02/2018
	*  ModifiedDate    : 25/10/2018
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
	*  ModifiedDate    : 25/10/2018
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
	*  CreatedDate     : 10/01/2018
	*  ModifiedDate    : 08/01/2019
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void saveReports() {
		if (this.existingCreditReport == null && this.company != null && this.errorToRequestOrder == null) {
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
	            Credit_Limit__c = this.company.creditLimit,
	            Date_of_Foundation__c = this.company.dateoffoundation,
	            Email__c = this.company.email,
	            Fax__c = this.company.fax,
	            First_Legal_Form__c = this.company.firstlegalform,
	            Fiscal_Number__c = this.company.taxnumber,
	            Housenumber__c = this.company.housenumber,
	            Legal_Form__c = this.company.legalform,
	            Mobile__c = this.company.mobile,
	            Opportunity__c = sourceObject.Id,
	            Phone__c = this.company.phone,
	            Postcode__c = this.company.postcode,
	            Register_Number__c = this.company.registerNumber,
	            Staff_Range__c = this.company.staffcompanyrange,
	            Street__c = this.company.street,
	            Trade_Name__c = this.company.tradename,
	            Turn_Over__c = this.company.turnOver,
	            Trade_Register_Number__c = this.company.tradeRegisterNumber,
	            Tax_Id__c = this.company.taxnumber,
	            Website__c = this.company.website,
	            Name = reportName,
	            Company_Id__c = this.company.identificationnumber,
	            Solvency_Index__c = this.company.solvencyIndex,
	            Request_Status__c = this.company.requestStatus,
	            Obligation_Overdue__c = this.company.obligationOverdue,
	            Class_Rating__c = this.company.classRating,
	            Number_Of_Hits__c = this.company.numberOfHits,
	            Policy_Rules_Hits__c = String.join(this.company.policyRulesHits, '\r\n'),
	            Name_Change_Decision__c = this.company.nameChangeDecision,
	            Address_Change_Decision__c = this.company.addressChangeDecision,
	            Postal_Street__c = this.company.postalStreet,
	            Postal_Housenumber__c = this.company.postalHousenumber,
	            Postal_City__c = this.company.postalCity,
	            Postal_Postcode__c = this.company.postalPostcode,
	            Registered_Street__c = this.company.registeredStreet,
	            Registered_Housenumber__c = this.company.registeredHousenumber,
	            Registered_City__c = this.company.registeredCity,
	            Registered_Postcode__c = this.company.registeredPostcode,
	            Profit_Loss_Last_Year__c = this.company.profitLossLastYear,
				Profit_Loss_Year_Before_Last__c = this.company.profitLossYearBeforeLast,
				Turn_Over_Last_Year__c = this.company.turnOverLastYear,
				PIT_Currency__c = this.company.pitCurrency,
				CurrencyIsoCode = 'PLN',
				Name__c = this.company.name);
				if (this.userSource == 'E2E Long Form') {
					newReport.Billing_Period__c = this.billingPeriod;
					newReport.Payment_Terms__c = this.paymentTerms;
					newReport.Security_Level__c = this.securityLevel;
		            newReport.Credit_Limit_Default__c = getCreditLimit();
		            newReport.Credit_Limit_Weekly_7__c = getCreditLimitWeeklyPlus7();
					newReport.Max_Credit_Limit_Weekly_7__c = getMaxCreditLimitWeeklyPlus7();
					newReport.Max_Value_Weekly_7__c = getMaxValueWeeklyPlus7();
					newReport.Deposit_Weekly_7__c = getDepositWeeklyPlus7();
		            newReport.Credit_Limit_Bi_Weekly_14__c = getCreditLimitBiWeeklyPlus14();
					newReport.Max_Credit_Limit_Bi_Weekly_14__c = getMaxCreditLimitBiWeeklyPlus14();
					newReport.Max_Value_Bi_Weekly_14__c = getMaxValueBiWeeklyPlus14();
					newReport.Deposit_Bi_Weekly_14__c = getDepositBiWeeklyPlus14();
					newReport.Decision_Verdict__c = this.decision.verdict;
					newReport.Decision_Status_Code__c = this.decision.statusCode;
				}
	        try {
	            insert newReport;
	            List<Credit_Factory_Report_Employee__c> employeesListToInsert = new List<Credit_Factory_Report_Employee__c>();
	            for (CreditCompanyEmployee e : companyEmployeesList) {
	                employeesListToInsert.add(new Credit_Factory_Report_Employee__c(
	                    Credit_Factory_Report__c = newReport.Id,
	                    Address__c = e.address,
	                    Name = e.ename,
	                    Type__c = e.type));
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
	*  Name 		   : updateOpportunityByCredit()
	*  Summary         : update opportunity with button by Credit
	*  CreatedDate     : 10/01/2018
	*  ModifiedDate    : 25/10/2018
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
	*  CreatedDate     : 10/01/2018
	*  ModifiedDate    : 18/02/2019
	*  Parameters      : 
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


	public void updateOpportunityWithPDF(sObject sourceObject) {} // Pdf is created asynchronously


	public Boolean doCreateReportAttachment(String opportunityId) {
		// Pdf is created asynchronously
        return false;
	}


	public Boolean isPendingSEPAPossible() {
		return false;
	}


	public Boolean isAutoCWPossible() {
		if (this.sourceObject.DocuSign_Status__c == 'Completed') {
			return true;
		}

		return false;
	}


	public PageReference changeToPendingSEPAConfirmation() {	
    	return null;
	}


	/*******************************************************************************
	*  Name            : countNumberOfRelatedTankkartens()
	*  Summary         : count number of Tankkarten__c objects related to the current Opportunity    
	*  CreatedDate     : 10/01/2018
	*  ModifiedDate    : 10/01/2018
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
    *  CreatedDate     : 10/01/2018
	*  ModifiedDate    : 10/01/2018
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
	*  CreatedDate     : 24/04/2018
	*  ModifiedDate    : 24/04/2018
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
		    if (this.riskCategory == null) {
				setRiskCategory(this.company.classRating);
			}
        	this.sourceObject.put(this.opportunityMapping.Risk_Category__c,this.riskCategory);
        	if (this.buffer == null) {
        		setBuffer(this.company.classRating);
        	}
        	this.sourceObject.put(this.opportunityMapping.Buffer__c, this.buffer * 100);
		    this.sourceObject.put(this.opportunityMapping.Security_Level__c, this.securityLevel);
		    this.sourceObject.Account.Gesellschaftsform__c = this.company.legalform;
			update this.sourceObject;
			update this.sourceObject.Account;
			CreditFactoryUtilities.displayMessage('error', 'Decision about deposit was accepted for your client.');
	    } catch (Exception e) {
        	throw new CreditFactoryException('Change to Pending Sales - Deposit failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}
	}


	/*******************************************************************************
	*  Name            : changeToContractCheck()
	*  Summary         : change Opportunity StageName to Pending Credit - Contract Check    
	*  CreatedDate     : 29/01/2018
	*  ModifiedDate    : 01/06/2018
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
			prepareGeneralFieldsForAutoprocess();
	        this.sourceObject.StageName = 'Pending Credit - Contract Check';
	        this.sourceObject.CF_Stage__c = 'Pending Credit - Contract Check';
	        update this.sourceObject;
	        update this.sourceObject.Account;
	        submitForApproval();
	        return new PageReference('/' + this.sourceObject.Id);
		} catch (Exception e) {
        	throw new CreditFactoryException('Change to Contract check failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
		}
	}


	/*******************************************************************************
	*  Name 		   : changeToClosedWon()
	*  Summary         : Change opportunity StageName to Closed Won
	*  CreatedDate     : 01/06/2018
	*  ModifiedDate    : -
	*  Parameters      : 
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
	*  Name            : prepareGeneralFieldsForAutoprocess()
	*  Summary         : Prepare fields for Closed Won or Contract Check    
	*  CreatedDate     : 01/06/2018
	*  ModifiedDate    : 18/02/2019
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

	public static Map<String, String> policyRulesMap = new Map<String, String> {
		'Firma była zawieszona lub zamknięta w ciągu ostatnich 12 miesięcy' => '2', //20
		'Forma własności w REGON to własność zagraniczna' => '4', //19
		'Obniżenie kapitału w ciągu ostatnich 12 miesięcy' => '4', //18
		'Mniej niż 3 sprawozdania finansowe w ciągu ostatnich 5 lat' => '4', //17
		'Więcej niż 2 zmiany adresu rejestracji firmy w ciągu ostatnich 24 miesięcy' => '2', //16
		'Firma była zawieszona lub zamknięta w ciągu ostatnich 12 miesięcy' => '2', //15
		'Firma KRS jest zarejestrowana w budynku z dużą populacją' => '4', //14
		'W tym samym budynku istnieje co najmniej 10 firm tego samego właściciela w dowolnym stanie aktywności połączenia' => '1', //13
		'Budynek z dużą ilością firm zarejestrowanych w KRS' => '4', //12
		'Istnieje informacja negatywna dla firmy siostrzanej' => '2', //11
		'Istnieje informacja negatywna dla firmy córki' => '2', //10
		'Istnieje informacja negatywna dla firmy matki' => '2', //09
		'W firmie KRS istnieje więcej niż jedna aktywna osoba decyzyjna bez numeru PESEL' => '4', //08
		'Istnieje aktywna osoba decyzyjna będąca właścicielem innej firmy która ma dane negatywne' => '3', //07
		'Istnieje aktywny właściciel połączony z firmą która ma dane negatywne' => '3', //06
		'Istnieje nieaktywna osoba decyzyjna z danymi negatywnymi i data zamknięcia funkcji jest młodsza niż 12 miesięcy' => '3', //05
		'Istnieje aktywna osoba decyzyjna z danymi negatywnymi' => '2', //04
		'Istnieją aktywne osoby decyzyjne z dużą ilością aktywnych połączeń do firm (>50)' => '1', //03
		'Aktywna osoba decyzyjna zamknęła co najmniej 5 stanowisk w ciągu ostatnich 12 miesięcy w innych firmach' => '1', //02
		'Aktywna osoba decyzyjna otworzyła co najmniej 5 stanowisk w ciągu ostatnich 12 miesięcy w innych firmach' => '1' //01
	};
}