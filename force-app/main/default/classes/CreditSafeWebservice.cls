public class CreditSafeWebservice {
    public static final String CREDIT_SYSTEM_NAME = 'Creditsafe';

    /*******************************************************************************
    *  Name            : generateSearchRequest()
    *  Summary         : Generate HTTP Request to Creditsafe
    *  CreatedDate     : 31/10/2016
    *  Parameters      : 
    *  Returns         : HttpRequest
    ******************************************************************************/
    public static HttpRequest generateSearchRequest(String endpoint, String userName, String password, String apikey,
                                                    String recordName, String recordStreet, 
                                                    String recordCity, String recordCountry,
                                                    String kvkNumber) {
        try {
            String body = generateSearchXML(recordName, recordStreet, recordCity, recordCountry, kvkNumber);
            Http h = new Http();
            HttpRequest request = new HttpRequest();
            request.setHeader('SOAPAction', 'http://www.creditsafe.com/globaldata/operations/DataBrowsingService/FindCompanies');
            request.setHeader('Content-Type', 'text/xml; charset=utf-8');
            Blob headerValue = Blob.valueOf(userName + ':' + password);
            String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
            request.setHeader('Authorization', authorizationHeader);
            request.setBody(body);
            request.setTimeout(60000);
            // url that returns the XML in the response body
            request.setEndpoint(endpoint);
            request.setMethod('POST');

            return request;
        } catch (Exception e) {
            System.debug('Credit Factory Error === ' + e.getMessage());
            throw new CreditFactoryException('Search request failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : generateReportRequest(String endpoint, String userName, String password, String apikey, String companyId)
    *  Summary         : Generate HTTP Request to CreditReform
    *  CreatedDate     : 03/11/2016
    *  Parameters      : endpoint - from CreditSystem custom setting ,userName - from CreditSystem custom setting, 
                         password - from CreditSystem custom setting, apikey - from CreditSystem custom setting, 
                         companyId - Id of Credit System Company (from finder page)
    *  Returns         : HttpRequest
    ******************************************************************************/
    public static HttpRequest generateReportRequest(String endpoint, String userName, String password, String apikey,
                                                    String companyId) {
        try {
            String body = generateReportXML(companyId);
            Http h = new Http();
            HttpRequest request = new HttpRequest();
            request.setHeader('SOAPAction', 'http://www.creditsafe.com/globaldata/operations/CompanyDataAccessService/RetrieveCompanyOnlineReport');
            request.setHeader('Content-Type', 'text/xml; charset=utf-8');
            Blob headerValue = Blob.valueOf(userName + ':' + password);
            String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
            request.setHeader('Authorization', authorizationHeader);
            request.setBody(body);
            request.setTimeout(60000);
            // url that returns the XML in the response body
            request.setEndpoint(endpoint);
            request.setMethod('POST');

            return request;
        } catch (Exception e) {
            system.debug('Credit Factory Error === ' + e.getMessage());
            throw new CreditFactoryException('Report request failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : returnReportCompany(Dom.XMLNode node)
    *  Summary         : Return Company
    *  CreatedDate     : 4/11/2016
    *  Parameters      : node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static CreditCompany returnReportCompany(Dom.XMLNode node, Opportunity sourceObject) {
        try {
            CreditCompany selectedCompany = new CreditCompany();
            selectedCompany.creditSystemCompanyNumber = returnReferenceNumber(node);
            selectedCompany.classRating = CreditFactoryUtilities.returnArabicFromAlpha(returnClassRating(node));
            selectedCompany.development = returnDevelopment(node);
            selectedCompany.turnOver = returnTurnOver(node);
            selectedCompany.legalform = returnLegalForm(node, sourceObject);
            selectedCompany.vatid = returnVatId(node);
            selectedCompany.taxnumber = returnTaxNumber(node, sourceObject);
            if (sourceObject.Account.BillingCountryCode == 'FR') {
                selectedCompany.tradeRegisterNumber = returnRegisterId(node);
            }
            selectedCompany.datelegalform = returnDateLegalForm(node);
            selectedCompany.registerNumber = returnRegisterId(node);
            selectedCompany.datelastregisterentry = returnDateLastRegisterEntry(node);
            selectedCompany.staffcompanyrange = returnStaffCompanyRange(node);
            selectedCompany.creditLimit = returnCreditLimit(node);
            selectedCompany.creditLimitCurrency = returnCreditLimitCurrency(node);
            selectedCompany.creditDecision = returnCreditDecision(node);
            selectedCompany.dateoffoundation = returnDateoffoundation(node);
            selectedCompany.firstlegalform = returnFirstlegalform(node);
            selectedCompany.status = returnStatus(node);
            selectedCompany.name = returnName(node);
            selectedCompany.tradename = returnName(node);
            selectedCompany.street = returnStreet(node);
            selectedCompany.housenumber = returnHousenumber(node);
            selectedCompany.postcode = returnPostcode(node);
            selectedCompany.city = returnCity(node);
            selectedCompany.country = returnCountry(node);
            if (selectedCompany.country == null) {
                selectedCompany.country = sourceObject.Account.BillingCountryCode;
            }
            selectedCompany.phone = returnPhone(node);
            selectedCompany.mobile = returnPhone(node);
            selectedCompany.email = returnEmail(node);
            selectedCompany.website = returnWebsite(node);
            selectedCompany.identificationnumber = returnCompanyNumber(node);
            selectedCompany.dateOfLastChangeOfDirector = returnDateOfLastChangeOfDirector(node);
            selectedCompany.principalActivityCode = returnPrincipalActivityCode(node);
            selectedCompany.principalACtivityDescription = returnPrincipalActivityDescription(node);
            return selectedCompany;
        } catch (Exception e) {
            system.debug('Credit Factory Error === ' + e.getMessage());
            throw new CreditFactoryException('Parsing Report Company failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : returnReportCompanyEmployees(Dom.XMLNode node)
    *  Summary         : Return Company
    *  CreatedDate     : 4/11/2016
    *  Parameters      : node - body from response
    *  Returns         : List<CreditCompanyEmployee> - list of employees
    ******************************************************************************/
    public static List<CreditCompanyEmployee> returnReportCompanyEmployees(Dom.XMLNode node) {
        try {
            Map<String, CreditCompanyEmployee> companyEmployeesMap = new Map<String, CreditCompanyEmployee>();
            for (Dom.XMLNode reportItem : node.getChildElements()) {
                if (reportItem.getName() == 'Report') {
                    for (Dom.XMLNode reportFields : reportItem.getChildElements()) {
                        if (reportFields.getName() == 'ShareCapitalStructure') {
                            for (Dom.XMLNode shareStructureItem : reportFields.getChildElements()) {
                                if (shareStructureItem.getName() == 'ShareHolders') {
                                    for (Dom.XMLNode shareHoldersItem : shareStructureItem.getChildElements()) {
                                        if (shareHoldersItem.getName() == 'ShareHolder') {
                                            CreditCompanyEmployee newEmployee = new CreditCompanyEmployee();
                                            for (Dom.XMLNode shareHolderItem : shareHoldersItem.getChildElements()) {
                                                if (shareHolderItem.getName() == 'Name') {
                                                    newEmployee.ename = shareHolderItem.getText(); 
                                                }

                                                if (shareHolderItem.getName() == 'Address') {
                                                    for (Dom.XMLNode addressItem : shareHolderItem.getChildElements()) {
                                                        if (shareHolderItem.getName() == 'SimpleValue') {
                                                            newEmployee.address = shareHolderItem.getText();
                                                        }
                                                    }
                                                }
                                                newEmployee.companyRole = 'ShareHolder';
                                            }
                                            companyEmployeesMap.put(newEmployee.ename, newEmployee);
                                        }
                                    }
                                }
                            }
                        } else if (reportFields.getName() == 'Directors') {
                            for (Dom.XMLNode directorsItem : reportFields.getChildElements()) {
                                if (directorsItem.getName() == 'CurrentDirectors') {
                                    for (Dom.XMLNode currentDirectorsItem : directorsItem.getChildElements()) {
                                        if (currentDirectorsItem.getName() == 'Director') {
                                            CreditCompanyEmployee newEmployee = new CreditCompanyEmployee();
                                            for (Dom.XMLNode currentDirectorItem : currentDirectorsItem.getChildElements()) {
                                                if (currentDirectorItem.getName() == 'Name') {
                                                    newEmployee.ename = currentDirectorItem.getText(); 
                                                }

                                                if (currentDirectorItem.getName() == 'Position') {
                                                    newEmployee.type = currentDirectorItem.getText();

                                                    String participationdate = currentDirectorItem.getAttribute('AppointmentDate', null);
                                                    if (participationdate != null && participationdate.contains('T00:00:00Z')) {
                                                        participationdate = participationdate.replace('T00:00:00Z','');
                                                    }
                                                    newEmployee.participationdate = participationdate;
                                                }

                                                if (currentDirectorItem.getName() == 'DateOfBirth') {
                                                    String dateofbirth = currentDirectorItem.getText();
                                                    if (dateofbirth != null && dateofbirth.contains('T00:00:00Z')) {
                                                        dateofbirth = dateofbirth.replace('T00:00:00Z', '');
                                                    }
                                                    newEmployee.dateofbirth = dateofbirth; 
                                                }

                                                if (currentDirectorItem.getName() == 'Address') {
                                                    for (Dom.XMLNode addressItem : currentDirectorItem.getChildElements()) {
                                                        if (currentDirectorItem.getName() == 'SimpleValue') {
                                                            newEmployee.address = currentDirectorItem.getText();
                                                        }
                                                    }
                                                }
                                                newEmployee.companyRole = 'Director';
                                            }
                                            companyEmployeesMap.put(newEmployee.ename, newEmployee);
                                        }
                                    }
                                }
                            }
                        } 
                    }
                }
            }

            for (Dom.XMLNode reportItem : node.getChildElements()) {
                if (reportItem.getName() == 'Report') {
                    for (Dom.XMLNode reportFields : reportItem.getChildElements()) {
                        if (reportFields.getName() == 'GroupStructure') {
                            for (Dom.XMLNode groupStructureField : reportFields.getChildElements()) {
                                if (groupStructureField.getName() == 'UltimateParent') {
                                    for (Dom.XMLNode ultimateParentField : groupStructureField.getChildElements()) {
                                        if (ultimateParentField.getName() == 'Name' && companyEmployeesMap.containsKey(ultimateParentField.getText())) {
                                            companyEmployeesMap.get(ultimateParentField.getText()).companyId = groupStructureField.getAttribute('Id', null);
                                            companyEmployeesMap.get(ultimateParentField.getText()).companyType = 'Ultimate Parent';
                                        }
                                    } 
                                } else if (groupStructureField.getName() == 'AffiliatedCompanies') {
                                    for (Dom.XMLNode affiliatedFields : groupStructureField.getChildElements()) {
                                        if (affiliatedFields.getName() == 'AffiliatedCompany') {
                                            for (Dom.XMLNode affiliatedField : affiliatedFields.getChildElements()) {
                                                if (affiliatedField.getName() == 'Name' && companyEmployeesMap.containsKey(affiliatedField.getText())) {
                                                    companyEmployeesMap.get(affiliatedField.getText()).companyId = affiliatedFields.getAttribute('Id', null);
                                                    companyEmployeesMap.get(affiliatedField.getText()).companyType = 'Affiliated Company';
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            return companyEmployeesMap.values();
        } catch (Exception e) {
            system.debug('Credit Factory Error === ' + e.getMessage() + e.getStackTraceString());
            throw new CreditFactoryException('Parsing Report Company failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : returnCompanyNumber(Dom.XMLNode node)
    *  Summary         : Return company number from webservice response     
    *  CreatedDate     : 21/11/2016
    *  Parameters      : Dom.XMLNode node - part of response 
    *  Returns         : String
    ******************************************************************************/
    public static String returnCompanyNumber(Dom.XMLNode node) {        
        for (Dom.XMLNode reportItem : node.getChildElements()) {
            if (reportItem.getName() == 'Report') {
                return reportItem.getAttribute('CompanyId', null);
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnReferenceNumber(Dom.XMLNode node)
    *  Summary         : Return reference number from webservice response     
    *  CreatedDate     : 21/11/2016
    *  Parameters      : Dom.XMLNode node - part of response 
    *  Returns         : String
    ******************************************************************************/
    public static String returnReferenceNumber(Dom.XMLNode node) {        
        for (Dom.XMLNode reportItem : node.getChildElements()) {
            if (reportItem.getName() == 'Report') {
                for (Dom.XMLNode reportFields : reportItem.getChildElements()) {
                    if (reportFields.getName() == 'CompanySummary') {
                        for (Dom.XMLNode companySummaryItem : reportFields.getChildElements()) {
                            if (companySummaryItem.getName() == 'Number') {
                                return companySummaryItem.getText();
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnTaxNumber(Dom.XMLNode node, Opportunity opportunity)
    *  Summary         : Return tax number from webservice response     
    *  CreatedDate     : 21/11/2016
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - part of response, Opportunity opportunity - current Opportunity
    *  Returns         : String
    ******************************************************************************/
    public static String returnTaxNumber(Dom.XMLNode node, Opportunity opportunity) {        
        for (Dom.XMLNode reportItem : node.getChildElements()) {
            if (reportItem.getName() == 'Report') {
                for (Dom.XMLNode reportFields : reportItem.getChildElements()) {
                    if (reportFields.getName() == 'CompanySummary') {
                        for (Dom.XMLNode companySummaryItem : reportFields.getChildElements()) {
                            if (companySummaryItem.getName() == 'CompanyRegistrationNumber') {
                                String taxId = companySummaryItem.getText();
                                if (opportunity.Account.BillingCountryCode == 'FR' && taxId != null && taxId.length() >= 9) {
                                    return taxId.substring(0, 9);
                                } else {
                                    return taxId;
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }
    

    /*******************************************************************************
    *  Name            : returnTurnOver(Dom.XMLNode node)
    *  Summary         : Return turn over from webservice response     
    *  CreatedDate     : 21/11/2016
    *  Parameters      : Dom.XMLNode node - part of response 
    *  Returns         : String
    ******************************************************************************/
    public static String returnTurnOver(Dom.XMLNode node) {        
        for (Dom.XMLNode reportItem : node.getChildElements()) {
            if (reportItem.getName() == 'Report') {
                for (Dom.XMLNode reportFields : reportItem.getChildElements()) {
                    if (reportFields.getName() == 'CompanySummary') {
                        for (Dom.XMLNode companySummaryItem : reportFields.getChildElements()) {
                            if (companySummaryItem.getName() == 'LatestTurnoverFigure') {
                                return companySummaryItem.getText();
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnStaffCompanyRange(Dom.XMLNode node)
    *  Summary         : Return turn over from webservice response     
    *  CreatedDate     : 21/11/2016
    *  Parameters      : Dom.XMLNode node - part of response 
    *  Returns         : String
    ******************************************************************************/
    public static String returnStaffCompanyRange(Dom.XMLNode node) {        
        for (Dom.XMLNode reportItem : node.getChildElements()) {
            if (reportItem.getName() == 'Report') {
                for (Dom.XMLNode reportFields : reportItem.getChildElements()) {
                    if (reportFields.getName() == 'OtherInformation') {
                        for (Dom.XMLNode otherInformationItem : reportFields.getChildElements()) {
                            if (otherInformationItem.getName() == 'EmployeesInformation') {
                                for (Dom.XMLNode employeesInformationItem : reportFields.getChildElements()) {
                                    if (employeesInformationItem.getName() == 'EmployeeInformation') {
                                        for (Dom.XMLNode employeeInformationItem : employeesInformationItem.getChildElements()) {
                                            if (employeeInformationItem.getName() == 'NumberOfEmployees') {
                                                return employeeInformationItem.getText();
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnEmail(Dom.XMLNode node)
    *  Summary         : Return company Street name from webservice response     
    *  CreatedDate     : 21/11/2016
    *  Parameters      : Dom.XMLNode node - part of response 
    *  Returns         : String
    ******************************************************************************/
    public static String returnEmail(Dom.XMLNode node) {        
        for (Dom.XMLNode reportItem : node.getChildElements()) {
            if (reportItem.getName() == 'Report') {
                for (Dom.XMLNode reportFields : reportItem.getChildElements()) {
                    if (reportFields.getName() == 'ContactInformation') {
                        for (Dom.XMLNode contactInformationItem : reportFields.getChildElements()) {
                            if (contactInformationItem.getName() == 'EmailAddresses') {
                                for (Dom.XMLNode emailAddressesItem : contactInformationItem.getChildElements()) {
                                    if (emailAddressesItem.getName() == 'EmailAddress') {
                                        return emailAddressesItem.getText();
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnWebsite(Dom.XMLNode node)
    *  Summary         : Return company Street name from webservice response     
    *  CreatedDate     : 21/11/2016
    *  Parameters      : Dom.XMLNode node - part of response 
    *  Returns         : String
    ******************************************************************************/
    public static String returnWebsite(Dom.XMLNode node) {        
        for (Dom.XMLNode reportItem : node.getChildElements()) {
            if (reportItem.getName() == 'Report') {
                for (Dom.XMLNode reportFields : reportItem.getChildElements()) {
                    if (reportFields.getName() == 'ContactInformation') {
                        for (Dom.XMLNode contactInformationItem : reportFields.getChildElements()) {
                            if (contactInformationItem.getName() == 'Websites') {
                                for (Dom.XMLNode websitesItem : contactInformationItem.getChildElements()) {
                                    if (websitesItem.getName() == 'Website') {
                                        return websitesItem.getText();
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnStreet(Dom.XMLNode node)
    *  Summary         : Return company Street name from webservice response     
    *  CreatedDate     : 21/11/2016
    *  Parameters      : Dom.XMLNode node - part of response 
    *  Returns         : String
    ******************************************************************************/
    public static String returnStreet(Dom.XMLNode node) {        
        for (Dom.XMLNode reportItem : node.getChildElements()) {
            if (reportItem.getName() == 'Report') {
                for (Dom.XMLNode reportFields : reportItem.getChildElements()) {
                    if (reportFields.getName() == 'ContactInformation') {
                        for (Dom.XMLNode contactInformationItem : reportFields.getChildElements()) {
                            if (contactInformationItem.getName() == 'MainAddress') {
                                for (Dom.XMLNode mainAddressItem : contactInformationItem.getChildElements()) {
                                    if (mainAddressItem.getName() == 'Address') {
                                        for (Dom.XMLNode addressItem : mainAddressItem.getChildElements()) {
                                            if (addressItem.getName() == 'Street') {
                                                return addressItem.getText();
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnHousenumber(Dom.XMLNode node)
    *  Summary         : Return company House number from webservice response     
    *  CreatedDate     : 21/11/2016
    *  Parameters      : Dom.XMLNode node - part of response 
    *  Returns         : String
    ******************************************************************************/
    public static String returnHousenumber(Dom.XMLNode node) {   
        for (Dom.XMLNode reportItem : node.getChildElements()) {
            if (reportItem.getName() == 'Report') {
                for (Dom.XMLNode reportFields : reportItem.getChildElements()) {
                    if (reportFields.getName() == 'ContactInformation') {
                        for (Dom.XMLNode contactInformationItem : reportFields.getChildElements()) {
                            if (contactInformationItem.getName() == 'MainAddress') {
                                for (Dom.XMLNode mainAddressItem : contactInformationItem.getChildElements()) {
                                    if (mainAddressItem.getName() == 'Address') {
                                        for (Dom.XMLNode addressItem : mainAddressItem.getChildElements()) {
                                            if (addressItem.getName() == 'HouseNumber') {
                                                return addressItem.getText();
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnCity(Dom.XMLNode node)
    *  Summary         : Return company House number from webservice response     
    *  CreatedDate     : 21/11/2016
    *  Parameters      : Dom.XMLNode node - part of response 
    *  Returns         : String
    ******************************************************************************/
    public static String returnCity(Dom.XMLNode node) {        
        for (Dom.XMLNode reportItem : node.getChildElements()) {
            if (reportItem.getName() == 'Report') {
                for (Dom.XMLNode reportFields : reportItem.getChildElements()) {
                    if (reportFields.getName() == 'ContactInformation') {
                        for (Dom.XMLNode contactInformationItem : reportFields.getChildElements()) {
                            if (contactInformationItem.getName() == 'MainAddress') {
                                for (Dom.XMLNode mainAddressItem : contactInformationItem.getChildElements()) {
                                    if (mainAddressItem.getName() == 'Address') {
                                        for (Dom.XMLNode addressItem : mainAddressItem.getChildElements()) {
                                            if (addressItem.getName() == 'City') {
                                                return addressItem.getText();
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnPostcode(Dom.XMLNode node)
    *  Summary         : Return company Postal code from webservice response     
    *  CreatedDate     : 21/11/2016
    *  Parameters      : Dom.XMLNode node - part of response 
    *  Returns         : String
    ******************************************************************************/
    public static String returnPostcode(Dom.XMLNode node) {        
        for (Dom.XMLNode reportItem : node.getChildElements()) {
            if (reportItem.getName() == 'Report') {
                for (Dom.XMLNode reportFields : reportItem.getChildElements()) {
                    if (reportFields.getName() == 'ContactInformation') {
                        for (Dom.XMLNode contactInformationItem : reportFields.getChildElements()) {
                            if (contactInformationItem.getName() == 'MainAddress') {
                                for (Dom.XMLNode mainAddressItem : contactInformationItem.getChildElements()) {
                                    if (mainAddressItem.getName() == 'Address') {
                                        for (Dom.XMLNode addressItem : mainAddressItem.getChildElements()) {
                                            if (addressItem.getName() == 'PostalCode') {
                                                return addressItem.getText();
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnCountry(Dom.XMLNode node)
    *  Summary         : Return company Country from webservice response     
    *  CreatedDate     : 21/11/2016
    *  Parameters      : Dom.XMLNode node - part of response 
    *  Returns         : String
    ******************************************************************************/
    public static String returnCountry(Dom.XMLNode node) {        
        for (Dom.XMLNode reportItem : node.getChildElements()) {
            if (reportItem.getName() == 'Report') {
                for (Dom.XMLNode reportFields : reportItem.getChildElements()) {
                    if (reportFields.getName() == 'ContactInformation') {
                        for (Dom.XMLNode contactInformationItem : reportFields.getChildElements()) {
                            if (contactInformationItem.getName() == 'MainAddress') {
                                for (Dom.XMLNode mainAddressItem : contactInformationItem.getChildElements()) {
                                    if (mainAddressItem.getName() == 'Country') {
                                        return mainAddressItem.getText();
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnName(Dom.XMLNode node)
    *  Summary         : Return company name from webservice response     
    *  CreatedDate     : 21/11/2016
    *  Parameters      : Dom.XMLNode node - part of response 
    *  Returns         : String
    ******************************************************************************/
    public static String returnName(Dom.XMLNode node) {        
        for (Dom.XMLNode reportItem : node.getChildElements()) {
            if (reportItem.getName() == 'Report') {
                for (Dom.XMLNode reportFields : reportItem.getChildElements()) {
                    if (reportFields.getName() == 'CompanySummary') {
                        for (Dom.XMLNode companySummaryItem : reportFields.getChildElements()) {
                            if (companySummaryItem.getName() == 'BusinessName') {
                                return companySummaryItem.getText();
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnRegisterId(Dom.XMLNode node)
    *  Summary         : Return register number from webservice response     
    *  CreatedDate     : 21/11/2016
    *  Parameters      : Dom.XMLNode node - part of response 
    *  Returns         : String
    ******************************************************************************/
    public static String returnRegisterId(Dom.XMLNode node) {        
        for (Dom.XMLNode reportItem : node.getChildElements()) {
            if (reportItem.getName() == 'Report') {
                for (Dom.XMLNode reportFields : reportItem.getChildElements()) {
                    if (reportFields.getName() == 'CompanySummary') {
                        for (Dom.XMLNode sompanySummaryItem : reportFields.getChildElements()) {
                            if (sompanySummaryItem.getName() == 'CompanyRegistrationNumber') {
                                return sompanySummaryItem.getText();
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnClassRating(Dom.XMLNode node)
    *  Summary         : Return class rating from webservice response     
    *  CreatedDate     : 21/11/2016
    *  Parameters      : Dom.XMLNode node - part of response 
    *  Returns         : String
    ******************************************************************************/
    public static String returnClassRating(Dom.XMLNode node) {        
        for (Dom.XMLNode reportItem : node.getChildElements()) {
            if (reportItem.getName() == 'Report') {
                for (Dom.XMLNode reportFields : reportItem.getChildElements()) {
                    if (reportFields.getName() == 'CompanySummary') {
                        for (Dom.XMLNode sompanySummaryItem : reportFields.getChildElements()) {
                            if (sompanySummaryItem.getName() == 'CreditRating') {
                                for (Dom.XMLNode creditRatingItem : sompanySummaryItem.getChildElements()) {
                                    if (creditRatingItem.getName() == 'CommonValue') {
                                        return creditRatingItem.getText();
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnDevelopment(Dom.XMLNode node)
    *  Summary         : Return Development from webservice response     
    *  CreatedDate     : 21/11/2016
    *  Parameters      : Dom.XMLNode node - part of response 
    *  Returns         : String
    ******************************************************************************/
    public static String returnDevelopment(Dom.XMLNode node) {        
        for (Dom.XMLNode reportItem : node.getChildElements()) {
            if (reportItem.getName() == 'Report') {
                for (Dom.XMLNode reportFields : reportItem.getChildElements()) {
                    if (reportFields.getName() == 'CompanySummary') {
                        for (Dom.XMLNode sompanySummaryItem : reportFields.getChildElements()) {
                            if (sompanySummaryItem.getName() == 'CreditRating') {
                                for (Dom.XMLNode creditRatingItem : sompanySummaryItem.getChildElements()) {
                                    if (creditRatingItem.getName() == 'ProviderValue') {
                                        return creditRatingItem.getText();
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnCreditLimit(Dom.XMLNode node)
    *  Summary         : Return credit limit from webservice response     
    *  CreatedDate     : 21/11/2016
    *  Parameters      : Dom.XMLNode node - part of response 
    *  Returns         : String
    ******************************************************************************/
    public static String returnCreditLimit(Dom.XMLNode node) {        
        for (Dom.XMLNode reportItem : node.getChildElements()) {
            if (reportItem.getName() == 'Report') {
                for (Dom.XMLNode reportFields : reportItem.getChildElements()) {
                    if (reportFields.getName() == 'CompanySummary') {
                        for (Dom.XMLNode sompanySummaryItem : reportFields.getChildElements()) {
                            if (sompanySummaryItem.getName() == 'CreditRating') {
                                for (Dom.XMLNode creditRatingItem : sompanySummaryItem.getChildElements()) {
                                    if (creditRatingItem.getName() == 'CreditLimit') {
                                        if (creditRatingItem.getText() == 'No Credit Limit') {
                                            return '0';
                                        } else {
                                            return creditRatingItem.getText();
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnCreditDecision(Dom.XMLNode node)
    *  Summary         : Return credit decision from webservice response     
    *  CreatedDate     : 21/11/2016
    *  Parameters      : Dom.XMLNode node - part of response 
    *  Returns         : String
    ******************************************************************************/
    public static String returnCreditDecision(Dom.XMLNode node) {        
        for (Dom.XMLNode reportItem : node.getChildElements()) {
            if (reportItem.getName() == 'Report') {
                for (Dom.XMLNode reportFields : reportItem.getChildElements()) {
                    if (reportFields.getName() == 'CompanySummary') {
                        for (Dom.XMLNode sompanySummaryItem : reportFields.getChildElements()) {
                            if (sompanySummaryItem.getName() == 'CreditRating') {
                                for (Dom.XMLNode creditRatingItem : sompanySummaryItem.getChildElements()) {
                                    if (creditRatingItem.getName() == 'CommonDescription') {
                                        return creditRatingItem.getText();
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnCreditLimitCurrency(Dom.XMLNode node)
    *  Summary         : Return credit limit currency from webservice response     
    *  CreatedDate     : 21/11/2016
    *  Parameters      : Dom.XMLNode node - part of response 
    *  Returns         : String
    ******************************************************************************/
    public static String returnCreditLimitCurrency(Dom.XMLNode node) {        
        for (Dom.XMLNode reportItem : node.getChildElements()) {
            if (reportItem.getName() == 'Report') {
                return reportItem.getAttribute('ReportCurrency', null);
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnLegalForm(Dom.XMLNode node)
    *  Summary         : Return legal form from webservice response     
    *  CreatedDate     : 21/11/2016
    *  Parameters      : Dom.XMLNode node - part of response 
    *  Returns         : String
    ******************************************************************************/
    public static String returnLegalForm(Dom.XMLNode node, Opportunity sourceObject) {        
        for (Dom.XMLNode reportItem : node.getChildElements()) {
            if (reportItem.getName() == 'Report') {
                for (Dom.XMLNode reportFields : reportItem.getChildElements()) {
                    if (reportFields.getName() == 'CompanyIdentification') {
                        for (Dom.XMLNode companyIdentificationItem : reportFields.getChildElements()) {
                            if (companyIdentificationItem.getName() == 'BasicInformation') {
                                for (Dom.XMLNode basicInformationItem : companyIdentificationItem.getChildElements()) {
                                    if (basicInformationItem.getName() == 'LegalForm') {
                                        if (sourceObject.Account.BillingCountry == 'Netherlands' && netherlandslegalFormsMap.containsKey(basicInformationItem.getText())) {
                                            return netherlandslegalFormsMap.get(basicInformationItem.getText()).replace('  ', ' ').replace(' -', '-').replace('- ', '-');
                                            break;
                                        } else if (sourceObject.Account.BillingCountry == 'France' && francelegalFormsMap.containsKey(basicInformationItem.getText())) {
                                            return francelegalFormsMap.get(basicInformationItem.getText()).replace('  ', ' ').replace(' -', '-').replace('- ', '-');
                                            break;
                                        } else if (sourceObject.Account.BillingCountry == 'Belgium-NL' && belgiumNLLegalFormsMap.containsKey(basicInformationItem.getText())) {
                                            return belgiumNLLegalFormsMap.get(basicInformationItem.getText()).replace('  ', ' ').replace(' -', '-').replace('- ', '-');
                                            break;
                                        } else if (sourceObject.Account.BillingCOuntry == 'Belgium-FR' && belgiumFRLegalFormsMap.containsKey(basicInformationItem.getText())) {
                                            return belgiumFRLegalFormsMap.get(basicInformationItem.getText()).replace('  ', ' ').replace(' -', '-').replace('- ', '-');
                                            break;
                                        } else {
                                            return basicInformationItem.getText();
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnFirstlegalform(Dom.XMLNode node)
    *  Summary         : Return Previous form from webservice response     
    *  CreatedDate     : 21/11/2016
    *  Parameters      : Dom.XMLNode node - part of response 
    *  Returns         : String
    ******************************************************************************/
    public static String returnFirstlegalform(Dom.XMLNode node) {        
        for (Dom.XMLNode reportItem : node.getChildElements()) {
            if (reportItem.getName() == 'Report') {
                for (Dom.XMLNode reportFields : reportItem.getChildElements()) {
                    if (reportFields.getName() == 'CompanyIdentification') {
                        for (Dom.XMLNode companyIdentificationItem : reportFields.getChildElements()) {
                            if (companyIdentificationItem.getName() == 'PreviousLegalForms') {
                                for (Dom.XMLNode previousLegalFormsItem : companyIdentificationItem.getChildElements()) {
                                    if (previousLegalFormsItem.getName() == 'PreviousLegalForm') {
                                        for (Dom.XMLNode previousLegalFormItem : previousLegalFormsItem.getChildElements()) {
                                            if (previousLegalFormItem.getName() == 'LegalForm') {
                                                return previousLegalFormItem.getText();
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnDateoffoundation(Dom.XMLNode node)
    *  Summary         : Return Date Last Register Entry from webservice response     
    *  CreatedDate     : 21/11/2016
    *  Parameters      : Dom.XMLNode node - part of response 
    *  Returns         : String
    ******************************************************************************/
    public static String returnDateoffoundation(Dom.XMLNode node) {        
        for (Dom.XMLNode reportItem : node.getChildElements()) {
            if (reportItem.getName() == 'Report') {
                for (Dom.XMLNode reportFields : reportItem.getChildElements()) {
                    if (reportFields.getName() == 'CompanyIdentification') {
                        for (Dom.XMLNode companyIdentificationItem : reportFields.getChildElements()) {
                            if (companyIdentificationItem.getName() == 'BasicInformation') {
                                for (Dom.XMLNode basicInformationItem : companyIdentificationItem.getChildElements()) {
                                    if (basicInformationItem.getName() == 'DateofCompanyRegistration') {
                                        String basicInformation = basicInformationItem.getText();
                                        if (basicInformation.contains('T00:00:00Z')) {
                                            basicInformation = basicInformation.replace('T00:00:00Z','');
                                        }
                                        
                                        return basicInformation;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnDateLastRegisterEntry(Dom.XMLNode node)
    *  Summary         : Return Date Last Register Entry from webservice response     
    *  CreatedDate     : 21/11/2016
    *  Parameters      : Dom.XMLNode node - part of response 
    *  Returns         : String
    ******************************************************************************/
    public static String returnDateLastRegisterEntry(Dom.XMLNode node) {        
        for (Dom.XMLNode reportItem : node.getChildElements()) {
            if (reportItem.getName() == 'Report') {
                for (Dom.XMLNode reportFields : reportItem.getChildElements()) {
                    if (reportFields.getName() == 'CompanyIdentification') {
                        for (Dom.XMLNode companyIdentificationItem : reportFields.getChildElements()) {
                            if (companyIdentificationItem.getName() == 'BasicInformation') {
                                for (Dom.XMLNode basicInformationItem : companyIdentificationItem.getChildElements()) {
                                    if (basicInformationItem.getName() == 'DateOfLatestRatingChange') {
                                        return basicInformationItem.getText();
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnVatId(Dom.XMLNode node)
    *  Summary         : Return legal form from webservice response     
    *  CreatedDate     : 21/11/2016
    *  Parameters      : Dom.XMLNode node - part of response 
    *  Returns         : String
    ******************************************************************************/
    public static String returnVatId(Dom.XMLNode node) {        
        for (Dom.XMLNode reportItem : node.getChildElements()) {
            if (reportItem.getName() == 'Report') {
                for (Dom.XMLNode reportFields : reportItem.getChildElements()) {
                    if (reportFields.getName() == 'CompanyIdentification') {
                        for (Dom.XMLNode companyIdentificationItem : reportFields.getChildElements()) {
                            if (companyIdentificationItem.getName() == 'BasicInformation') {
                                for (Dom.XMLNode basicInformationItem : companyIdentificationItem.getChildElements()) {
                                    if (basicInformationItem.getName() == 'VatRegistrationNumber') {
                                        return basicInformationItem.getText();
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnPhone(Dom.XMLNode node)
    *  Summary         : Return phone from webservice response     
    *  CreatedDate     : 21/11/2016
    *  Parameters      : Dom.XMLNode node - part of response 
    *  Returns         : String
    ******************************************************************************/
    public static String returnPhone(Dom.XMLNode node) {        
        for (Dom.XMLNode reportItem : node.getChildElements()) {
            if (reportItem.getName() == 'Report') {
                for (Dom.XMLNode reportFields : reportItem.getChildElements()) {
                    if (reportFields.getName() == 'CompanyIdentification') {
                        for (Dom.XMLNode companyIdentificationItem : reportFields.getChildElements()) {
                            if (companyIdentificationItem.getName() == 'BasicInformation') {
                                for (Dom.XMLNode basicInformationItem : companyIdentificationItem.getChildElements()) {
                                    if (basicInformationItem.getName() == 'ContactTelephoneNumber') {
                                        return basicInformationItem.getText();
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnStatus(Dom.XMLNode node)
    *  Summary         : Return legal form from webservice response     
    *  CreatedDate     : 21/11/2016
    *  Parameters      : Dom.XMLNode node - part of response 
    *  Returns         : String
    ******************************************************************************/
    public static String returnStatus(Dom.XMLNode node) {        
        for (Dom.XMLNode reportItem : node.getChildElements()) {
            if (reportItem.getName() == 'Report') {
                for (Dom.XMLNode reportFields : reportItem.getChildElements()) {
                    if (reportFields.getName() == 'CompanyIdentification') {
                        for (Dom.XMLNode companyIdentificationItem : reportFields.getChildElements()) {
                            if (companyIdentificationItem.getName() == 'BasicInformation') {
                                for (Dom.XMLNode basicInformationItem : companyIdentificationItem.getChildElements()) {
                                    if (basicInformationItem.getName() == 'CompanyStatus') {
                                        return basicInformationItem.getText();
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnDateLegalForm(Dom.XMLNode node)
    *  Summary         : Return legal form date from webservice response     
    *  CreatedDate     : 21/11/2016
    *  Parameters      : Dom.XMLNode node - part of response 
    *  Returns         : String
    ******************************************************************************/
    public static String returnDateLegalForm(Dom.XMLNode node) {        
        for (Dom.XMLNode reportItem : node.getChildElements()) {
            if (reportItem.getName() == 'Report') {
                for (Dom.XMLNode reportFields : reportItem.getChildElements()) {
                    if (reportFields.getName() == 'AdditionalInformation') {
                        for (Dom.XMLNode additionalInformationItem : reportFields.getChildElements()) {
                            if (additionalInformationItem.getName() == 'Misc') {
                                for (Dom.XMLNode miscItem : additionalInformationItem.getChildElements()) {
                                    if (miscItem.getName() == 'DateofLegalForm') {
                                        String dateLegalForm = '';
                                        if (miscItem.getText().contains('T00:00:00')) {
                                            dateLegalForm = miscItem.getText().replace('T00:00:00','');
                                        } else {
                                            dateLegalForm = miscItem.getText();
                                        }
                                        return dateLegalForm;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnAttachmentBody(Dom.XMLNode node)
    *  Summary         : Return report body from webservice response     
    *  CreatedDate     : 21/11/2016
    *  Parameters      : Dom.XMLNode node - part of response 
    *  Returns         : String
    ******************************************************************************/
    public static String returnAttachmentBody(Dom.XMLNode node) {        
        for (Dom.XMLNode reportItem : node.getChildElements()) {
            if (reportItem.getName() == 'Report') {
                for (Dom.XMLNode reportFields : reportItem.getChildElements()) {
                    if (reportFields.getName() == 'AdditionalInformation') {
                        for (Dom.XMLNode additionalInformationItem : reportFields.getChildElements()) {
                            if (additionalInformationItem.getName() == 'BinaryAttachment') {
                                return additionalInformationItem.getText();
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnDateOfLastChangeOfDirector(Dom.XMLNode node)
    *  Summary         : Return date of last change of director
    *  CreatedDate     : 11/01/2019
    *  ModifiedDate    : 27/03/2019
    *  Parameters      : Dom.XMLNode node - part of response
    *  Returns         : String
    ******************************************************************************/
    public static String returnDateOfLastChangeOfDirector(Dom.XMLNode node) {        
        for (Dom.XMLNode reportsField : node.getChildElements()) {
            if (reportsField.getName() == 'Report') {
                for (Dom.XMLNode reportFields : reportsField.getChildElements()) {
                    Date dateOfLastChangeOfDirector;
                    Set<Date> appointmentDatesSet = new Set<Date>();
                    Set<Date> resignationDatesSet = new Set<Date>();
                    if (reportFields.getName() == 'Directors') {
                        for (Dom.XMLNode directorsField : reportFields.getChildElements()) {
                            if (directorsField.getName() == 'CurrentDirectors') {
                                for (Dom.XMLNode currentDirectorsField : directorsField.getChildElements()) {
                                    if (currentDirectorsField.getName() == 'Director') {
                                        for (Dom.XMLNode directorField : currentDirectorsField.getChildElements()) {
                                            if (directorField.getName() == 'Position') {
                                                if (directorField.getAttribute('AppointmentDate', null) != null) {
                                                    appointmentDatesSet.add(Date.valueOf(directorField.getAttribute('AppointmentDate', null)));
                                                }
                                            }
                                        }
                                    }
                                }
                            } else if (directorsField.getName() == 'PreviousDirectors') {
                                for (Dom.XMLNode priviousDirectorsField : directorsField.getChildElements()) {
                                    if (priviousDirectorsField.getName() == 'Director') {
                                        for (Dom.XMLNode directorField : priviousDirectorsField.getChildElements()) {
                                            if (directorField.getName() == 'ResignationDate') {
                                                if (directorField.getText() != null) {
                                                    resignationDatesSet.add(Date.valueOf(directorField.getText()));
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        for (Date appointmentDate : appointmentDatesSet) {
                            for (Date resignationDate : resignationDatesSet) {
                                if (appointmentDate >= resignationDate.addDays(-1) && appointmentDate <= resignationDate.addDays(1) && 
                                        (dateOfLastChangeOfDirector == null || appointmentDate > dateOfLastChangeOfDirector)) {
                                    dateOfLastChangeOfDirector = appointmentDate;
                                }
                            }
                        }
                    } else if (reportFields.getName() == 'AdditionalInformation') {
                        for (Dom.XMLNode additionlaInformationField : reportFields.getChildElements()) {
                            if (additionlaInformationField.getName() == 'CompanyHistory') {
                                for (Dom.XMLNode companyHistoryField : additionlaInformationField.getChildElements()) {
                                    if (companyHistoryField.getName() == 'Event') {
                                        Date eventDate;
                                        for (Dom.XMLNode eventField : companyHistoryField.getChildElements()) {
                                            if (eventField.getName() == 'Date' && eventField.getText() != null) {
                                                eventDate = Date.valueOf(eventField.getText());
                                            } else if (eventField.getName() == 'Description' && eventField.getText() == 'Change of directors') {
                                                if (dateOfLastChangeOfDirector == null || eventDate > dateOfLastChangeOfDirector) {
                                                    dateOfLastChangeOfDirector = eventDate;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    if (dateOfLastChangeOfDirector != null) {
                        return String.valueOf(dateOfLastChangeOfDirector);
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnPrincipalActivityCode(Dom.XMLNode node)
    *  Summary         : Return Principal activity code
    *  CreatedDate     : 29/01/2019
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - part of response
    *  Returns         : String
    ******************************************************************************/
    public static String returnPrincipalActivityCode(Dom.XMLNode node) {
        for (Dom.XMLNode reportsField : node.getChildElements()) {
            if (reportsField.getName() == 'Report') {
                for (Dom.XMLNode reportFields : reportsField.getChildElements()) {
                    if (reportFields.getName() == 'CompanyIdentification') {
                        for (Dom.XMLNode companyIdentificationField : reportFields.getChildElements()) {
                            if (companyIdentificationField.getName() == 'BasicInformation') {
                                for (Dom.XMLNode basicInformationField : companyIdentificationField.getChildElements()) {
                                    if (basicInformationField.getName() == 'PrincipalActivity') {
                                        for (Dom.XMLNode principalActivityField : basicInformationField.getChildElements()) {
                                            if (principalActivityField.getName() == 'ActivityCode') {
                                                return principalActivityField.getText();
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnPrincipalActivityDescription(Dom.XMLNode node)
    *  Summary         : Return date of last change of director    
    *  CreatedDate     : 29/01/2019
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - part of response
    *  Returns         : String
    ******************************************************************************/
    public static String returnPrincipalActivityDescription(Dom.XMLNode node) {
        for (Dom.XMLNode reportsField : node.getChildElements()) {
            if (reportsField.getName() == 'Report') {
                for (Dom.XMLNode reportFields : reportsField.getChildElements()) {
                    if (reportFields.getName() == 'CompanyIdentification') {
                        for (Dom.XMLNode companyIdentificationField : reportFields.getChildElements()) {
                            if (companyIdentificationField.getName() == 'BasicInformation') {
                                for (Dom.XMLNode basicInformationField : companyIdentificationField.getChildElements()) {
                                    if (basicInformationField.getName() == 'PrincipalActivity') {
                                        for (Dom.XMLNode principalActivityField : basicInformationField.getChildElements()) {
                                            if (principalActivityField.getName() == 'ActivityDescription') {
                                                return principalActivityField.getText();
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : generateSearchXML(String opportunityName, String street, String city, String country)
    *  Summary         : Generate XML String to call CreditReform search
    *  CreatedDate     : 17/11/2016
    *  Parameters      : 
    *  Returns         : String
    ******************************************************************************/
    public static String generateSearchXML(String opportunityName, String street, String city, String country, String kvkNumber) {
        String xmlbody = 
        '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:oper="http://www.creditsafe.com/globaldata/operations" xmlns:cred="http://schemas.datacontract.org/2004/07/Creditsafe.GlobalData" xmlns:dat="http://www.creditsafe.com/globaldata/datatypes">' +
           '<soapenv:Header/>' +
           '<soapenv:Body>' +
                '<oper:FindCompanies>' +
                    '<oper:countries>' +
                        '<cred:CountryCode>' + countriesMapping.get(country) + '</cred:CountryCode>' +
                    '</oper:countries>' +
                    '<oper:searchCriteria>' +
                        ((kvkNumber != null && kvkNumber != '' && (country == 'NL' || country == 'BENL' || country == 'BEFR' || country == 'FR')) ? '<dat:RegistrationNumber>' + kvkNumber + '</dat:RegistrationNumber>' : 
                            '<dat:Name MatchType="MatchBeginning">' + opportunityName.replace('&', ' ') + '</dat:Name>' + 
                                '<dat:Address>' +    
                                    ((street != null && street != '') ? '<dat:Street>' + street + '</dat:Street>' : '') + 
                                    ((city != null && city != '') ? '<dat:City>' + city + '</dat:City>' : '') +
                                '</dat:Address>') +
                    '</oper:searchCriteria>' +
                '</oper:FindCompanies>' +
            '</soapenv:Body>' +
        '</soapenv:Envelope>';
        System.debug('DEBUG: xmlbody === ' + xmlbody);
        return xmlbody;
    }


    /*******************************************************************************
    *  Name            : generateReportXML(String companyId)
    *  Summary         : Generate XML String to call CreditReform report
    *  CreatedDate     : 03/11/2016
    *  Parameters      : companyId - Id of Credit System Company (from finder page)
    *  Returns         : String
    ******************************************************************************/
    public static String generateReportXML(String companyId) {
        String xmlbody = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:oper="http://www.creditsafe.com/globaldata/operations" xmlns:dat="http://www.creditsafe.com/globaldata/datatypes">' +
            '<soapenv:Header/>' +
            '<soapenv:Body>' +
                '<oper:RetrieveCompanyOnlineReport>' +
                    '<oper:companyId>' + companyId + '</oper:companyId>' +
                    '<oper:reportType>Full</oper:reportType>' +
                    '<oper:language>EN</oper:language>' +
                    '<oper:customData>' +
                        '<dat:Entries>' +
                            '<dat:Entry key="binary_attachment">pdf</dat:Entry>' +
                        '</dat:Entries>' +
                    '</oper:customData>' +
                '</oper:RetrieveCompanyOnlineReport>' +
            '</soapenv:Body>' +
        '</soapenv:Envelope>';
        System.debug('DEBUG: xmlbody === ' + xmlbody);
        return xmlbody;
    }


    /*******************************************************************************
    *  Name            : returnReportDom(Dom.XMLNode node)
    *  Summary         : Return report dom
    *  CreatedDate     : 1/11/2016
    *  Parameters      : node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static Dom.XMLNode returnReportDom(Dom.XMLNode node) {
        for (Dom.XMLNode bodyElement : node.getChildElements()) {
            for (Dom.XMLNode retrieveCompanyOnlineReportResponseElement : bodyElement.getChildElements()) {
                for (Dom.XMLNode retrieveCompanyOnlineReportResultElement : retrieveCompanyOnlineReportResponseElement.getChildElements()) {
                    for (Dom.XMLNode reportsElement : retrieveCompanyOnlineReportResultElement.getChildElements()) {
                        if (reportsElement.getName() == 'Reports') {
                            return reportsElement;
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnSearchCompany(Dom.XMLNode node, Opportunity opportunity)
    *  Summary         : Return Body DOM element
    *  CreatedDate     : 1/11/2016
    *  ModifiedDate    : 12/12/2018
    *  Parameters      : Dom.XMLNode node - body from response, Opportunity opportunity - current Opportunity
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static List<CreditCompany> returnSearchCompany(Dom.XMLNode node, Opportunity opportunity) {
        try {
            List<CreditCompany> companiesFromSearch = new List<CreditCompany>();
            Dom.XMLNode companiesNode = returnCompanies(node);
            for (Dom.XMLNode companyItem : companiesNode.getChildElements()) {
                if (companyItem.getName() == 'Company') {
                    CreditCompany company = new CreditCompany();
                    company.identificationnumber = companyItem.getAttribute('Id', null);
                    company.isReportExists = Boolean.valueOf(companyItem.getAttribute('OnlineReports', null));
                    for (Dom.XMLNode field : companyItem.getChildElements()) {
                        if (field.getName() == 'Name') {
                            company.name = field.getText();
                        }
                        if (field.getName() == 'RegistrationNumber') {
                            String registrationNumber = field.getText();
                            if (opportunity.Account.BillingCountryCode == 'FR' && registrationNumber != null && registrationNumber.length() >= 9) {
                                company.creditSystemCompanyNumber = registrationNumber.substring(0, 9);
                            } else {
                                company.creditSystemCompanyNumber = registrationNumber;
                            }
                        }
                        if (field.getName() == 'Address') {
                            for (Dom.XMLNode addressItem : field.getChildElements()) {
                                if (addressItem.getName() == 'Street') {
                                    company.street = addressItem.getText();
                                }

                                if (addressItem.getName() == 'HouseNumber') {
                                    company.housenumber = addressItem.getText();
                                }

                                if (addressItem.getName() == 'City') {
                                    company.city = addressItem.getText();
                                }

                                if (addressItem.getName() == 'PostalCode') {
                                    company.postcode = addressItem.getText();
                                }

                                if (addressItem.getName() == 'SimpleValue') {
                                    company.address = addressItem.getText();
                                }
                            }
                        }
                        if (field.getName() == 'Status') {
                            company.status = field.getText();
                        }
                    }
                    companiesFromSearch.add(company);
                }
            }
            return companiesFromSearch;
        } catch (Exception e) {
            system.debug('Credit Factory Error === ' + e.getMessage());
            throw new CreditFactoryException('Parsing Search Company failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
            return null;
        }
    }


    /*******************************************************************************
    *  Name            : returnCompanies(Dom.XMLNode node)
    *  Summary         : Clear response and return companies node
    *  CreatedDate     : 17/11/2016
    *  Parameters      : node - request from webservice
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static Dom.XMLNode returnCompanies(Dom.XMLNode node) {
        for (Dom.XMLNode nodeItem : node.getChildElements()) {
            if (nodeItem.getName() == 'Body') {
                for (Dom.XMLNode bodyItem : nodeItem.getChildElements()) {
                    if (bodyItem.getName() == 'FindCompaniesResponse') {
                        for (Dom.XMLNode findCompaniesResponseItem : bodyItem.getChildElements()) {
                            if (findCompaniesResponseItem.getName() == 'FindCompaniesResult') {
                                for (Dom.XMLNode findCompaniesResultItem : findCompaniesResponseItem.getChildElements()) {
                                    if (findCompaniesResultItem.getName() == 'Companies') {
                                        return findCompaniesResultItem;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    public static Map<String, String> countriesMapping = new Map<String, String>{
        'NL' => 'NL',
        'FR' => 'FR',
        'BEFR' => 'BE',
        'BENL' => 'BE'
    };

    public static Map<String, String> netherlandslegalFormsMap = new Map<String, String> {
        'Sole trader with one owner' => 'Eenmanszaak',
        'Sole trafer with several owners' => 'Eenmanszaak',
        'Public limited company or limited company being set up on A form' => 'Overige',
        'Shipping company' => 'Overige',
        'Partnership' => 'Maatschap',
        'General partnership (VOF)' => 'VOF',
        'Public limited company or limited company being set up on B form' => 'Overige',
        'Limited partnership (CV) with one managing partner' => 'CV',
        'Limited partnership (CV) with several managing partners' => 'CV',
        'public limited company or limited company being set up on D form' => 'Overige',
        'Private limited liability company (BV) with ordinary structure' => 'BV',
        'Private limited liability company (BV) according regulations of the structural company' => 'BV',
        'Limited company (NV) with ordinary structure' => 'NV',
        'Limited company (NV) according regulations of the structural company' => 'NV',
        'NV investment company with a variable capital' => 'NV',
        'NV investment company with a variable capital, according to the regulations' => 'NV',
        'European limited company (SE) with ordinary structure' => 'SE',
        'European limited company (SE) according to the regulations of the structural company of the structural company' => 'SE',
        'Co-operative society excluded liability (Coöperatie U.A.) with ordinary structure' => 'Coöperatieve en onderlinge waarborgmaatschappij',
        'Co-operative society excluded liability (Coöperatie U.A.) according to the regulations of the structural Co-operative society' => 'Coöperatieve en onderlinge waarborgmaatschappij',
        'Co-operative society with legal liabilty (Coöperatie W.A.) with ordinary structure' => 'Coöperatieve en onderlinge waarborgmaatschappij',
        'Co-operative society with legal liabilty (Coöperatie W.A.) according to the regulations of the structural Co-operative society' => 'Coöperatieve en onderlinge waarborgmaatschappij',
        'Co-operative society with limited liability (Coöperatie B.A.) with ordinary structure' => 'Coöperatieve en onderlinge waarborgmaatschappij',
        'Co-operative society with limited liability (Coöperatie B.A.) according to the regulations of the structural Co-operative society' => 'Coöperatieve en onderlinge waarborgmaatschappij',
        'Association (Vereniging) with complete jurisdiction' => 'Vereniging',
        'Association (Vereniging) with limited jurisdiction' => 'Vereniging',
        'Religious community (Kerkgenootschap)' => 'Overige',
        'Foundation (Stichting)' => 'Stichting',
        'Mutual quarantee association excluded liability (Onderlinge Waarborgmaatschappij U.A.) with ordinary structure' => 'Overige',
        'Mutual quarantee association excluded liability (Onderlinge Waarborgmaatschappij U.A.) according to the regulations of the structural mutual quarantee ' => 'Overige',
        'Mutual quarantee association with legal liabilty (Onderlinge Waarborgmaatschappij W.A.) with ordinary structure' => 'Overige',
        'Mutual quarantee association with legal liabilty (Onderlinge Waarborgmaatschappij W.A.) according to the regulations of the structural mutual quarantee ' => 'Overige',
        'Mutual quarantee association with limited liabilty (Onderlinge Waarborgmaatschappij B.A.) with ordinary structure' => 'Overige',
        'Mutual quarantee association with limited liabilty (Onderlinge Waarborgmaatschappij B.A.) according to the regulations of the structural mutual quarantee ' => 'Overige',
        'Foreign legal form with headquarters in the Netherlands' => 'Overige',
        'Secondary with headquarters in foreign country' => 'Overige',
        'European Economical Cooperation (Europees Economisch Samenwerkingsverband)' => 'Overige',
        'Foreign company of the European Community with establishment in the Netherlands' => 'Overige',
        'Foreign company of the European Community with head-office in the Netherlands' => 'Overige',
        'Foreign company resembling at a company of the European Community with establishment in the Netherlands' => 'Overige',
        'Foreign company resembling at a company of the European Community with head-office in the Netherlands' => 'Overige',
        'Limited company being set up (Rechtspersoon in oprichting)' => 'Overige',
        'Other legal forms' => 'Overige',
        'Public partnership' => 'Overige',
        'Public partnership with corporate existence' => 'Overige',
        'Limited partnership (CV) with corporate existence' => 'CV',
        'Association of owners' => 'Vereniging',
        'Public corporation' => 'Overige',
        'Private corporation' => 'Overige'
    };

    public static Map<String, String> francelegalFormsMap = new Map<String, String> {
        'Mixed interest collective agriculatural public limited company with board of directors' => 'SA',
        'Awarding public limited company with board of directors' => 'SA',
        'Construction cooperative public limited company with board of directors' => 'SA',
        'Council housing public limited company with board of directors' => 'SA',
        'Council housing production cooperative society' => 'SA',
        'Real estate credit public limited company with board of directors' => 'SA',
        'Consumption cooperative public limited company with board of directors' => 'SA',
        'Shopkeeper cooperative public limited company - retailers to board of directors' => 'SA',
        'Craft cooperative public limited company with board of directors' => 'SA',
        'Maritime interest cooperative public limited company with board of directors' => 'SA',
        'Transport cooperative public limited company with board of directors' => 'SA',
        'Worker production cooperative society with board of directors' => 'SA',
        'Cooperative society union public limited company with board of directors' => 'SA',
        'cooperative public limited company with board of directors' => 'SA',
        'Liberal Practice Company in the form of a public limited company with board of directors' => 'SA',
        'Public limited company with board of directors' => 'SA',
        'Public limited company with worker participation in the board of directors' => 'SA',
        'National public limited company with board of directors' => 'SA',
        'Mixed economy public limited company with board of directors' => 'SA',
        'Open End Investment Company with board of directors' => 'SA',
        'Real estate company for industry and trading with management board' => 'SA',
        'Real estate investment public limited company with management board' => 'SA',
        'SAFER Plc with board of directors' => 'SA',
        'Agricultural mixed interest company in the form of a Plc with management board' => 'SA',
        'Agricultural collective interest company in the form of a Plc with management board' => 'SA',
        'Awarding Plc with management board' => 'SA',
        'Construction cooperative Plc with management board' => 'SA',
        'Council housing Plc with management board' => 'SA',
        'Cooperative production council housing Plc with management board' => 'SA',
        'Building society Plc with management board' => 'SA',
        'Consumption cooperative Plc with management board' => 'SA',
        'Traders cooperative Plc - retailers to board of directors' => 'SA',
        'Craft cooperative Plc with management board' => 'SA',
        'Maritime interest cooperative Plc with management board' => 'SA',
        'Transport cooperative Plc with management board' => 'SA',
        'Worker production cooperative society with management board' => 'SA',
        'Cooperative societies union Plc with management board' => 'SA',
        'Cooperative Plc with management board' => 'SA',
        'Liberal Plc with management board' => 'SA',
        'Plc with management board' => 'SA',
        'Simplified joint stock company' => 'SAS',
        'SASU (school and university administration secretary) company by simplified actions' => 'SASU',
        'Savings and provident bank' => 'SA',
        'GEIE-European economic interest group' => 'Autres',
        'Economic interest Group' => 'Autres',
        'CUMA-Common agricultural material usage cooperative' => 'Autres',
        'Agricultural cooperative company' => 'Autres',
        'Union of agricultural cooperative companies' => 'Autres',
        'Mutual Insurance Company' => 'Autres',
        'Collective Real Estate Investment Trust' => 'Autres',
        'Agricultural Collective Interest Company' => 'Autres',
        'Common farm group' => 'Autres',
        'Agricultural Land Organisation' => 'Autres',
        'Woodland Organsation' => 'Autres',
        'Open Area Organisation' => 'Autres',
        'Rural Land Organisation' => 'Autres',
        'Non Trading Land Ownership Company' => 'Autres',
        'Non Trading Estate Agents' => 'Autres',
        'Non Trading Contruction Estate Agents-Sales' => 'Autres',
        'Non Trading Attribution Company' => 'Autres',
        'Non Trading Coopertaive Contruction Company' => 'SCC',
        'Non Trading Coopertaive Consumer Company' => 'SCC',
        'Non Trading Cooperative Maritime Company' => 'SCC',
        'Non Trading Cooperative Company of Doctors' => 'SCC',
        'Non Trading Cooperative Company' => 'SCC',
        'Non Trading Professional Barrister Company' => 'SCP',
        'Non Trading Professional Legal Advisors Company' => 'SCP',
        'Non Trading Professional Registered Solicitors Company' => 'SCP',
        'Non Trading Professional Bailiff Company' => 'SCP',
        'Non Trading Professional Solicitors Company' => 'SCP',
        'Non Trading Professional Pricer Commissioner Company' => 'SCP',
        'Non Trading Professional Bankruptcy Court Clerk Company' => 'SCP',
        'Non Trading Professional Legal Advice Company' => 'SCP',
        'Non Trading Professional Auditor Company' => 'SCP',
        'Non Trading Professional Doctors Company' => 'SCP',
        'Non Trading Professional Dentistry Company' => 'SCP',
        'Non Trading Professional Nursing Company' => 'SCP',
        'Non Trading Professional Physiotherapist Company' => 'SCP',
        'Social Provident Society within the General National Insurance System' => 'Autres',
        'Social Provident Society within the Special National Insurance System' => 'Autres',
        'Social Provident Society for Pension Institution' => 'Autres',
        'Social Provident Society for the Mutual Benefit Agricultural Scheme' => 'Autres',
        'Social Provident Society for Unemployed Illnesses' => 'Autres',
        'Social Provident Society for seniors independent from social security' => 'Autres',
        'Social Provident Society for Unemployed Insurance' => 'Autres',
        'Social Provident Society' => 'Autres',
        'Mutualist Company' => 'Autres',
        'Agricultural Insurance mutualist agency' => 'Autres',
        'Mutualist agency' => 'Autres',
        'Central Business committee' => 'Autres',
        'Etablishment committee' => 'Autres',
        'Employees Union' => 'Autres',
        'Employers Union' => 'Autres',
        'Professional or Integrated Order' => 'Autres',
        'Industrial Technological Centre or the Professional Economic Development Society' => 'Autres',
        'Professional Society' => 'Autres',
        'Contingency Institute' => 'Autres',
        'Retirement Suppliment Institute' => 'Autres',
        'Joint Ownership Union' => 'Autres',
        'Free Union Association' => 'Association',
        'Non declared Association' => 'Association',
        'Declared Association' => 'Association',
        'Association déclarée \"entreprise d\'insertion par l\'économique\"' => 'Association',
        'Intermediate Association' => 'Association',
        'Employers Organization' => 'Association',
        'Declared Association, Recognized Public Benefit' => 'Association',
        'Assembly' => 'Association',
        'Local Rights Association (Bas-Rhin, Haut-Rhin et Moselle)' => 'Association',
        'Foundation' => 'Association',
        'Private Law Corporate Body' => 'Association',
        'Non Trading Professional Medical Laboratory Analysis Directors Company' => 'Autres',
        'Non Trading Professional Vetinary Company' => 'Autres',
        'Non Trading Professional Chartered Surveyors' => 'Autres',
        'Non Trading Professional Architect' => 'Autres',
        'Non Trading Professional Company' => 'Autres',
        'Average Non Trading Professional Company' => 'Autres',
        'Local Fund of Mutual Credit' => 'Autres',
        'Local Fund of Mutual Agricultural  Credit' => 'Autres',
        'Non Trading Farm' => 'Autres',
        'Liable Farms' => 'Autres',
        'Non Trading Company' => 'SC',
        'Corporate Body of Registered Private Rights' => 'Autres',
        'State Adminsitration, Contitutional Authority' => 'Secteur Public',
        'State Administration, Independent Administrative Authority' => 'Secteur Public',
        'State Administration, Department' => 'Secteur Public',
        'State Administration, Central Department' => 'Secteur Public',
        'State Administration, National Defence Department' => 'Secteur Public',
        'State Administration, National Dicentralized Department' => 'Secteur Public',
        'State Administration, Decentralized Interregional Service' => 'Secteur Public',
        'State Administration, Decentralized Inter-Departamental Service' => 'Secteur Public',
        'State Administration, Decentralized Territorial Serivce' => 'Secteur Public',
        'State Administration, National School without Corporate Body' => 'Secteur Public',
        'Regional Commune Group' => 'Secteur Public',
        'Regional Department GROUP' => 'Secteur Public',
        'Regional over seas Territory Group' => 'Secteur Public',
        'Regional Group' => 'Secteur Public',
        'Regional Region Group' => 'Secteur Public',
        'Common Associated Public Establishment' => 'Secteur Public',
        'Common Section Public Establishment' => 'Secteur Public',
        'Joint Urban Public Establishment' => 'Secteur Public',
        'Public Authorized Union Association' => 'Secteur Public',
        'Urban Land Association' => 'Secteur Public',
        'Land Re-grouping Association' => 'Secteur Public',
        'Local Public Educational Establishment' => 'Secteur Public',
        'Public Common Secter Establishment' => 'Secteur Public',
        'Urban District Establishment' => 'Secteur Public',
        'Public Urban Community Establishment' => 'Secteur Public',
        'Mutiple Vocation Public Union Establishment' => 'Secteur Public',
        'Local Authorties' => 'Secteur Public',
        'Village Community Establishment' => 'Secteur Public',
        'Town Community Establishments' => 'Secteur Public',
        'Non specialized Cooperation Society' => 'Autres',
        'Public Institutional Establishment or Interdepartamental Agreement' => 'Autres',
        'Public Institutional Establishment or Interregional Agreement' => 'Autres',
        'Unique Intercommunal union' => 'Autres',
        'Mixed Communal Union' => 'Autres',
        'Public Mixed Union' => 'Autres',
        'Union Board for the Management of Individual Community Goods' => 'Autres',
        'Communal Social Action Establishment' => 'Autres',
        'School Fund Establishment' => 'Autres',
        'Local Credit Fund Establishment' => 'Autres',
        'Hospital Department' => 'Autres',
        'Inner Hospital Department' => 'Autres',
        'Medico-social Public Establishment and Social Public Establishment' => 'Autres',
        'Establishment for Rented Accomodation' => 'Autres',
        'Fire Service Institution' => 'Autres',
        'Local Public Cultural Establishment' => 'Autres',
        'Local Public Establishment' => 'Autres',
        'Consular Body' => 'Autres',
        'Central Administration Public Society' => 'Autres',
        'National Scientific, Cultural and Professional Public Establishment' => 'Autres',
        'National Educational Public Establishment' => 'Autres',
        'Limited Territorial Competence Establishment' => 'Autres',
        'Administrative National Public Establishment' => 'Autres',
        'Public Interest Groups' => 'Autres',
        'Alsace and Lorraine Public Religion Establishment' => 'Autres',
        'Public Circle Establishment or Households in the Army' => 'Autres',
        'Corporate Body of Administrative Rights' => 'Autres',
        'Personal business-commercial craftsman' => 'Autres',
        'Personal business-commercial' => 'Profession libérale',
        'Personal business-craftsman' => 'Artisan',
        'Personal business-ministerial or public officer' => 'Profession libérale',
        'Personal business-liberal profession' => 'Profession libérale',
        'Personal business-farmer' => 'Profession libérale',
        'Personal business-sales representative' => 'Profession libérale',
        'Personal business-manager associated to company' => 'Profession libérale',
        'Personal business-Natural person' => 'ENTREPRISE INDIVIDUELLE',
        'Joint Ownership between natural people' => 'Autres',
        'Joint Ownership With Corporate Body' => 'Autres',
        'De Facto Company Between Natural People' => 'Autres',
        'De Facto Company With Corporate Body' => 'Autres',
        'Joint Equity Venture Company Between Natural People' => 'Autres',
        'Joint Equity Venture Company Wth Corporate Body' => 'Autres',
        'Joint Equity Venture Company - Liberal Professions' => 'Autres',
        'Parish Outside of the Concordat Zone' => 'Autres',
        'Private Law Group not equipped with Corporate Body' => 'Autres',
        'State Representation or Registered Foreign Public Body' => 'Autres',
        'Foreign Business Registered with RCS (business and companies Register)' => 'Autres',
        'International Organisation' => 'Autres',
        'International Organisation' => 'Autres',
        'Foreign Business not Registered with RCS (business and companies Register)' => 'Autres',
        'Foreign Law Company' => 'Autres',
        'National Public Establishment including a Public Accountant' => 'Autres',
        'National Public Establishment not Including a Public Accountant' => 'Autres',
        'Public Manager' => 'Autres',
        'Industrial or Commercial Local Public Establishement' => 'Autres',
        'Industrial or Commercial Local Group' => 'Autres',
        'French Bank Institution' => 'Autres',
        'Mutual Insurance Company' => 'Autres',
        'Cooperative Popular Bank Company' => 'Autres',
        'Maritime Mutual Savings Bank' => 'Autres',
        'Federal Mutual Savings Bank' => 'Autres',
        'Cooperative Registered Association' => 'Autres',
        'Cooperative Savings and Provident Bank' => 'Autres',
        'Partnership' => 'SNC',
        'Cooperative Partnership' => 'SNC',
        'Simple Limited partnership' => 'SNC',
        'Simple Cooperative Limited Partnership' => 'SNC',
        'Limited Partnership by policy' => 'SNC',
        'Limited Partnership by Cooperative Policy' => 'SNC',
        'Liberal Limited Partnership by policy' => 'SARL',
        'National Limited Liability Company' => 'SARL',
        'Mixed Economy Limited Liability Company' => 'SARL',
        'Real Estate Company for Industry and Trading in the form of a Ltd' => 'SARL',
        'Real Estate Management Company in the Form of a Ltd Company' => 'SARL',
        'SAFER company in the Form of a Ltd company' => 'SARL',
        'Mixed Interest Agricultural Society in the Form of a Ltd company' => 'SARL',
        'Agricultural Collective Interest Company in the Form of a Ltd Company' => 'SARL',
        'Limited Liability Granting Company' => 'SARL',
        'Construction Cooperative Limited Liabilty Company' => 'SARL',
        'Consumption Cooperative Limited Liabilty Company' => 'SARL',
        'Craft Cooperative Limited Liability Company' => 'SARL',
        'Maritime Interest Cooperative Limited Liabilty Company' => 'SARL',
        'Transport Cooperative Limited Liability Company' => 'SARL',
        'Worker Production Cooperative Society in the Form of a Ltd' => 'SARL',
        'Union of Cooperative Operated Companies in the Form of a Ltd company' => 'SARL',
        'Cooperative Operated Company in the Form of a Ltd company' => 'SARL',
        'Liberal Operated Limited Liability Company' => 'SARL',
        'Sole proprietorship Ltd' => 'SARL',
        'Limited Liability Company' => 'SARL',
        'Public Limited Company with Worker Participation in the Board of Directors' => 'SARL',
        'National Public Limited Company with Board of Directors' => 'SARL',
        'Mixed Economy Plc with board of directors' => 'SARL',
        'Open End Investment Company with Board of Directors' => 'SARL',
        'Real Estate Company for Industry and Trading with Board of Directors' => 'SARL',
        'Real Estate Investment Public Limited Company with Board of Directors' => 'SARL',
        'SAFER with Board of Directors' => 'SARL',
        'Mixed interest agricultural public limited company with board of directors' => 'SARL'
    };

    public static Map<String, String> belgiumFRLegalFormsMap = new Map<String, String> {
        'Proprietorship' => 'ENTREPRISE INDIVIDUELLE',
        'Foreign Company' => 'SE',
        'Partnership' => 'SNC',
        'Limited Partnership' => 'SCA',
        'Non-Profit Making Organisation' => 'Association',
        'Association with Shares' => 'Association',
        'Collective Name Company' => 'SNC',
        'Private Limited Company (BL/LX)' => 'SPRL',
        'One Person Private Limited Company (BE)' => 'SPRL',
        'Limited Partnership with shares (BL/LX)' => 'SA',
        'Public Limited Liability Company (BE)' => 'SA',
        'Temporary Association' => 'Autres',
        'Limited Liability Company (BE)' => 'SPRL',
        'Co-operative' => 'CVBA',
        'Co-operative Unlimited Company (BE)' => 'CVBA',
        'Co-operative Limited Liability Company (BE)' => 'CVBA',
        'Co-operative Unlimited Company by Participation (BE)' => 'CVBA',
        'Co-operative Limited Company by Participation (BE)' => 'CVBA',
        'Economic Interest Grouping' => 'Autres',
        'European Economic Interest Grouping' => 'Autres',
        'Agriculture Company' => 'Autres',
        'Professional and Interprofessional Company' => 'Autres',
        'Investment Co with Variable Capital regd. under Belgian law (BE)' => 'Autres',
        'Common Investment Fund (BE)' => 'Autres',
        'International Organisation' => 'Autres',
        'Private Limited Liability Company (BL/LX)' => 'SPRL',
        'Public Centre for Social Welfare (BE)' => 'Autres',
        'Public Utility Institute (BE)' => 'Autres',
        'Health Insurance Fund' => 'Autres',
        'Friendly Society' => 'Association',
        'Religious Corporate Body' => 'Association',
        'Civil Co in the form of Agriculture Company (BE)' => 'Autres',
        'Civil Co in form of Association with Shares (BE)' => 'Autres',
        'Civil Co in the form of Co-operative (BE)' => 'Autres',
        'Civil Co in form of Co-operative Ltd Co by Participation (BE)' => 'Autres',
        'Civil Co in the form of Co-operative Limited Liability Co (BE)' => 'Autres',
        'Civil Co in the form of Co-operative Unlimited Company (BE)' => 'Autres',
        'Civil Co in form of Co-operative Unltd Co by Participation (BE)' => 'Autres',
        'Civil Co in the form of Collective Name Company (BE)' => 'Autres',
        'Civil Co in the form of Common Investment Fund (BE)' => 'Autres',
        'Civil Co in the form of Investment Co with Variable Capital (BE)' => 'Autres',
        'Civil Co in the form of Economic Interest Grouping (BE)' => 'Autres',
        'Civil Co in the form of European Economic Interest Grouping (BE)' => 'Autres',
        'Civil Co in the form of Foreign Company (BE)' => 'Autres',
        'Civil Co in the form of International Organisation (BE)' => 'Autres',
        'Civil Co in the form of Public Limited Liability Company (BE)' => 'Autres',
        'Civil Co in the form of Limited Liability Company (BE)' => 'Autres',
        'Civil Co in the form of Limited Partnership (BE)' => 'Autres',
        'Civil Co in the form of Limited Partnership with Shares (BE)' => 'Autres',
        'Civil Co in the form of One Person Private Limited Company (BE)' => 'Autres',
        'Civil Co in the form of Private Limited Company (BE)' => 'Autres',
        'Civil Co in the form of Professional Association (BE)' => 'Autres',
        'Foreign Company with Permanent Office in Belgium (BE)' => 'SE',
        'Foreign Company with Immovable Property in Belgium (BE)' => 'SE',
        'Civil Co (BL/LX)' => 'Autres',
        'Civil Co (BL/LX)' => 'Autres',
        'Investment Co with Variable Capital regd under EU Law (BL/LX)' => 'Autres',
        'Professional Association' => 'Autres',
        'Foreign Company with Value Added Tax Number Representative (BE)' => 'Autres',
        'Public Institute in the form of Public Limited Company (BE)' => 'Autres',
        'Public Institute in the form of a Co-operative (BE)' => 'Autres',
        'Public Institute in the form of Interrelated Insurance Co (BE)' => 'Autres',
        'Public Institute (BE)' => 'Autres',
        'Foundation' => 'Autres',
        'Ministry' => 'Autres',
        'Irregular Collective Name Company (ES)' => 'Autres',
        'Limited Partnership with Social Intention (BE)' => 'Autres',
        'Collective Name Company with Social Intention (BE)' => 'Autres',
        'Private Limited Company with Social Intention (BE)' => 'Autres',
        'One Person Private Limited Company with Social Intention (BE)' => 'Autres',
        'Limited Partnership with Shares with Social Intention (BE)' => 'Autres',
        'Public Limited Liability Company with Social Intention (BE)' => 'Autres',
        'Co-operative Unlimited Company with Social Intention (BE)' => 'CV',
        'Co-operative Limited Liability Co with Social Intention (BE)' => 'CV',
        'Legal entity in formation' => 'Autres',
        'Municipal Institution' => 'Autres',
        'Provincial Institution' => 'Autres',
        'Public Institution under form of Co-operative Unlimited Co (BE)' => 'Autres',
        'Public Institution under form of a Co-operative Limited Co (BE)' => 'Autres',
        'Economic Interest Grouping with Social Intention (BE)' => 'Autres',
        'Publ. Inst. u. f. Co-operative Unltd Co Social Intention (BE)' => 'Autres',
        'Publ Institution u.f. of Co-op Ltd Co with Social Intention (BE)' => 'Autres',
        'Publ Institut form of a Publ. Ltd Co with Social Intention (BE)' => 'Autres',
        'Public Institution with Social Intention (BE)' => 'Autres',
        'European Company' => 'Autres',
        'Polders and Water Boards (BE)' => 'Autres',
        'Personal Partnership (BE)' => 'Autres',
        'European Economic Interest Grouping Registered Outside Belgium' => 'Autres',
        'Organization for Financing Pensions (BE)' => 'Autres',
        'European Cooperative Partnership' => 'Autres',
        'International Non-profit Organization (BE)' => 'Autres',
        'Foreign Non-profit Organization (BE)' => 'Autres'
    };

    public static Map<String, String> belgiumNLLegalFormsMap = new Map<String, String> {
        'Proprietorship' => 'Eenmanszaak',
        'Foreign Company' => 'SE',
        'Partnership' => 'VOF',
        'Limited Partnership' => 'CV',
        'Non-Profit Making Organisation' => 'Vereniging',
        'Association with Shares' => 'Vereniging',
        'Collective Name Company' => 'VOF',
        'Private Limited Company (BL/LX)' => 'BVBA',
        'One Person Private Limited Company (BE)' => 'BVBA',
        'Limited Partnership with shares (BL/LX)' => 'NV',
        'Public Limited Liability Company (BE)' => 'NV',
        'Temporary Association' => 'Overige',
        'Limited Liability Company (BE)' => 'BVBA',
        'Co-operative' => 'CV',
        'Co-operative Unlimited Company (BE)' => 'CV',
        'Co-operative Limited Liability Company (BE)' => 'CV',
        'Co-operative Unlimited Company by Participation (BE)' => 'CV',
        'Co-operative Limited Company by Participation (BE)' => 'CV',
        'Economic Interest Grouping' => 'Overige',
        'European Economic Interest Grouping' => 'Overige',
        'Agriculture Company' => 'Overige',
        'Professional and Interprofessional Company' => 'Overige',
        'Investment Co with Variable Capital regd. under Belgian law (BE)' => 'Overige',
        'Common Investment Fund (BE)' => 'Overige',
        'International Organisation' => 'Overige',
        'Private Limited Liability Company (BL/LX)' => 'BVBA',
        'Public Centre for Social Welfare (BE)' => 'Overige',
        'Public Utility Institute (BE)' => 'Overige',
        'Health Insurance Fund' => 'Overige',
        'Friendly Society' => 'Vereniging',
        'Religious Corporate Body' => 'Vereniging',
        'Civil Co in the form of Agriculture Company (BE)' => 'Overige',
        'Civil Co in form of Association with Shares (BE)' => 'Overige',
        'Civil Co in the form of Co-operative (BE)' => 'Overige',
        'Civil Co in form of Co-operative Ltd Co by Participation (BE)' => 'Overige',
        'Civil Co in the form of Co-operative Limited Liability Co (BE)' => 'Overige',
        'Civil Co in the form of Co-operative Unlimited Company (BE)' => 'Overige',
        'Civil Co in form of Co-operative Unltd Co by Participation (BE)' => 'Overige',
        'Civil Co in the form of Collective Name Company (BE)' => 'Overige',
        'Civil Co in the form of Common Investment Fund (BE)' => 'Overige',
        'Civil Co in the form of Investment Co with Variable Capital (BE)' => 'Overige',
        'Civil Co in the form of Economic Interest Grouping (BE)' => 'Overige',
        'Civil Co in the form of European Economic Interest Grouping (BE)' => 'Overige',
        'Civil Co in the form of Foreign Company (BE)' => 'Overige',
        'Civil Co in the form of International Organisation (BE)' => 'Overige',
        'Civil Co in the form of Public Limited Liability Company (BE)' => 'Overige',
        'Civil Co in the form of Limited Liability Company (BE)' => 'Overige',
        'Civil Co in the form of Limited Partnership (BE)' => 'Overige',
        'Civil Co in the form of Limited Partnership with Shares (BE)' => 'Overige',
        'Civil Co in the form of One Person Private Limited Company (BE)' => 'Overige',
        'Civil Co in the form of Private Limited Company (BE)' => 'Overige',
        'Civil Co in the form of Professional Association (BE)' => 'Overige',
        'Foreign Company with Permanent Office in Belgium (BE)' => 'SE',
        'Foreign Company with Immovable Property in Belgium (BE)' => 'SE',
        'Civil Co (BL/LX)' => 'Overige',
        'Civil Co (BL/LX)' => 'Overige',
        'Investment Co with Variable Capital regd under EU Law (BL/LX)' => 'Overige',
        'Professional Association' => 'Overige',
        'Foreign Company with Value Added Tax Number Representative (BE)' => 'Overige',
        'Public Institute in the form of Public Limited Company (BE)' => 'Overige',
        'Public Institute in the form of a Co-operative (BE)' => 'Overige',
        'Public Institute in the form of Interrelated Insurance Co (BE)' => 'Overige',
        'Public Institute (BE)' => 'Overige',
        'Foundation' => 'Overige',
        'Ministry' => 'Overige',
        'Irregular Collective Name Company (ES)' => 'Overige',
        'Limited Partnership with Social Intention (BE)' => 'Overige',
        'Collective Name Company with Social Intention (BE)' => 'Overige',
        'Private Limited Company with Social Intention (BE)' => 'Overige',
        'One Person Private Limited Company with Social Intention (BE)' => 'Overige',
        'Limited Partnership with Shares with Social Intention (BE)' => 'Overige',
        'Public Limited Liability Company with Social Intention (BE)' => 'Overige',
        'Co-operative Unlimited Company with Social Intention (BE)' => 'CV',
        'Co-operative Limited Liability Co with Social Intention (BE)' => 'CV',
        'Legal entity in formation' => 'Overige',
        'Municipal Institution' => 'Overige',
        'Provincial Institution' => 'Overige',
        'Public Institution under form of Co-operative Unlimited Co (BE)' => 'Overige',
        'Public Institution under form of a Co-operative Limited Co (BE)' => 'Overige',
        'Economic Interest Grouping with Social Intention (BE)' => 'Overige',
        'Publ. Inst. u. f. Co-operative Unltd Co Social Intention (BE)' => 'Overige',
        'Publ Institution u.f. of Co-op Ltd Co with Social Intention (BE)' => 'Overige',
        'Publ Institut form of a Publ. Ltd Co with Social Intention (BE)' => 'Overige',
        'Public Institution with Social Intention (BE)' => 'Overige',
        'European Company' => 'Overige',
        'Polders and Water Boards (BE)' => 'Overige',
        'Personal Partnership (BE)' => 'Overige',
        'European Economic Interest Grouping Registered Outside Belgium' => 'Overige',
        'Organization for Financing Pensions (BE)' => 'Overige',
        'European Cooperative Partnership' => 'Overige',
        'International Non-profit Organization (BE)' => 'Overige',
        'Foreign Non-profit Organization (BE)' => 'Overige'
    };
}