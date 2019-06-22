public class CrifWebservice {
    public static final String CREDIT_SYSTEM_NAME = 'Crif';


    /*******************************************************************************
    *  Name            : generateSearchRequest(String endpoint, String userName, String password,String recordName, 
                                               String recordStreet, String recordCity, String recordHousenumber, 
                                               String recordPostalCode)
    *  Summary         : Generate HTTP Request to CreditReform
    *  CreatedDate     : 09/01/2018
    *  ModifiedDate    : 09/01/2018
    *  Parameters      : String endpoint - from CreditSystem custom setting, String userName - from CreditSystem custom setting, 
                         String password - from CreditSystem custom setting, String recordName - company name for search, 
                         String recordStreet - company street for search, String recordCity - company city for search, 
                         String recordHousenumber - company house number for search, String recordPostalCode - company postal code for search,
                         String nip - tax Id for Poland.
    *  Returns         : HttpRequest
    ******************************************************************************/
    public static HttpRequest generateSearchRequest(String endpoint, String userName, String password,
                                                    String recordName, String recordStreet, String recordCity,
                                                    String recordHouseNumber, String recordPostalCode, String nip) {
        try {
            String body = generateSearchXML(userName, password, recordName, recordStreet, recordCity, recordHouseNumber, recordPostalCode, nip);
            Http h = new Http();
            HttpRequest request = new HttpRequest();
            request.setHeader('SOAPAction', 'urn:search');
            request.setHeader('Content-Type', 'text/xml');
            request.setBody(body);
            request.setTimeout(30000);
            // url that returns the XML in the response body
            request.setEndpoint(endpoint.substringBefore(','));
            request.setMethod('POST');
            return request;
        } catch (Exception e) {
            System.debug('Credit Factory Error === ' + e.getMessage());
            throw new CreditFactoryException('Search request failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }

    /*******************************************************************************
    *  Name            : generateSearchXML()
    *  Summary         : Generate XML String to call CreditReform search
    *  CreatedDate     : 09/01/2018
    *  ModifiedDate    : 09/01/2018
    *  Parameters      : String userName - from CreditSystem custom setting, String password - from CreditSystem custom setting, 
                         String opportunityName - company name for search, String street - company street for search, 
                         String city - company city for search, String houseNumber - company house number for search, 
                         String postalCode - company postal code for search, String nip - tax Id for Poland
    *  Returns         : String
    ******************************************************************************/
    public static String generateSearchXML(String userName, String password, String opportunityName, String street, String city, 
                                           String houseNumber, String postalCode, String nip) {
        opportunityName = opportunityName.replace('&', ' ');
        String xmlbody = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sear="http://www.deltavista.com/dspone/webservices/search">' +
           '<soapenv:Header>' +
                '<sear:IdentificationMessageContext>' +
                    '<sear:Credentials>' +
                        '<sear:Login>' + userName + '</sear:Login>' +
                        '<sear:Password>' + password + '</sear:Password>' +
                    '</sear:Credentials>' +
                '</sear:IdentificationMessageContext>' +
           '</soapenv:Header>' +
           '<soapenv:Body>' +
                '<sear:SearchRequest>' +
                    '<sear:Address>' +
                        '<sear:Name>' + opportunityName + '</sear:Name>' +
                        ((street != null && street != '') ? '<sear:Street>' + street + '</sear:Street>' : '') +
                        ((houseNumber != null && houseNumber != '') ? '<sear:Unit>' + houseNumber + '</sear:Unit>' : '') +
                        ((postalCode != null && postalCode != '') ? '<sear:Zip>' + postalCode + '</sear:Zip>' : '') +
                        ((city != null && city != '') ? '<sear:City>' + city + '</sear:City>' : '') +
                        '<sear:Country>POL</sear:Country>' + 
                    '</sear:Address>' +
                    '<sear:HitQuality>' +
                        '<sear:MinSimilarity>30</sear:MinSimilarity>' +
                        '<sear:MaxReturn>10</sear:MaxReturn>' +
                    '</sear:HitQuality>' +
                    ((nip != null && nip != '') ? '<sear:CompanyRegistrationInfo>' +
                        '<sear:directoryEntry>' +
                           '<sear:type>PL_NIP</sear:type>' +
                           '<sear:ID>' + nip + '</sear:ID>' +
                        '</sear:directoryEntry>' +
                    '</sear:CompanyRegistrationInfo>' : '') +
                '</sear:SearchRequest>' +
            '</soapenv:Body>' +
        '</soapenv:Envelope>';
        return xmlbody;
    }


    /*******************************************************************************
    *  Name            : returnSearchResponse(Dom.XMLNode node)
    *  Summary         : Return Body DOM element
    *  CreatedDate     : 09/01/2018
    *  ModifiedDate    : 09/01/2018
    *  Parameters      : node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static Dom.XMLNode returnSearchResponse(Dom.XMLNode node) {
        for (Dom.XMLNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XMLNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'SearchResponse') {
                        return bodyField;
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnErrorMessage(Dom.XMLNode node)
    *  Summary         : Return Error message if search response body of xml is null
    *  CreatedDate     : 09/01/2018
    *  ModifiedDate    : 09/01/2018
    *  Parameters      : node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static String returnErrorMessage(Dom.XMLNode node) {
        for (Dom.XMLNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                for (Dom.XMLNode bodyField : envelopeField.getChildElements()) {
                    if (bodyField.getName() == 'fault') {
                        for (Dom.XMLNode faultField : bodyField.getChildElements()) {
                            if (faultField.getName() == 'faultstring') {
                                return faultField.getText();
                            }
                        }
                    }
                }
            }
        }
        return null;    
    } 


    /*******************************************************************************
    *  Name            : returnSearchedCompanies(Dom.XMLNode node)
    *  Summary         : Return searched companies list
    *  CreatedDate     : 09/01/2018
    *  ModifiedDate    : 09/01/2018
    *  Parameters      : node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static List<CreditCompany> returnSearchedCompanies(Dom.XMLNode node) {
        try {
            List<CreditCompany> companiesFromSearch = new List<CreditCompany>();
            for (Dom.XMLNode responseField : node.getChildElements()) {
                if (responseField.getName() == 'Candidates') {
                    CreditCompany company = new CreditCompany();
                    company.isReportExists = true;
                    for (Dom.XMLNode candidateField : responseField.getChildElements()) {
                        if (candidateField.getName() == 'Address') {
                            for (Dom.XMLNode addressField : candidateField.getChildElements()) {
                                if (addressField.getName() == 'Name') {
                                    company.name = addressField.getText();
                                }
                                if (addressField.getName() == 'CompanyRegistrationInfo') {
                                    for (Dom.XMLNode regInfoField : addressField.getChildElements()) {
                                        if (regInfoField.getName() == 'directoryEntry') {
                                            Boolean isNip;
                                            String nipNumber;
                                            for (Dom.XMLNode entryField : regInfoField.getChildElements()) {
                                                if (entryField.getName() == 'type' && entryField.getText() == 'PL_NIP') {
                                                    isNip = true;
                                                }

                                                if (entryField.getName() == 'ID') {
                                                    nipNumber = entryField.getText();
                                                }
                                            }

                                            if (isNip == true && nipNumber != null) {
                                                company.identificationnumber = nipNumber;
                                                company.taxnumber = nipNumber;
                                            }
                                        }
                                    }
                                }
                                if (addressField.getName() == 'Street') {
                                    company.street = addressField.getText();
                                }
                                if (addressField.getName() == 'Unit') {
                                    company.housenumber = addressField.getText();
                                }
                                if (addressField.getName() == 'UnitAdd' && ! String.isEmpty(company.housenumber) && addressField.getText() != '') {
                                    company.housenumber += '/' + addressField.getText();
                                }
                                if (addressField.getName() == 'Zip') {
                                    company.postcode = addressField.getText();
                                }
                                if (addressField.getName() == 'City') {
                                    company.city = addressField.getText();
                                }
                                if (addressField.getName() == 'CompanyStatus') {
                                    company.status = addressField.getText();
                                }
                            }
                        }
                    }

                    if (company.identificationnumber != null) {
                        companiesFromSearch.add(company);
                    }
                }
            }

            return companiesFromSearch;
        } catch (Exception e) {
            system.debug('Credit Factory Error === ' + e.getMessage());
            throw new CreditFactoryException('Parsing Search Company failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : generateReportRequest(String endpoint, String userName, String password, String companyId)
    *  Summary         : Generate HTTP Request to CreditReform
    *  CreatedDate     : 10/01/2018
    *  ModifiedDate    : 10/01/2018
    *  Parameters      : endpoint - from CreditSystem custom setting, serName - from CreditSystem custom setting, 
                         password - from CreditSystem custom setting, companyId - Id of Credit System Company (from finder page)
    *  Returns         : HttpRequest
    ******************************************************************************/
    public static HttpRequest generateReportRequest(String endpoint, String userName, String password, String companyId) {
        try {
            String body = generateReportXML(userName, password, companyId);
            Http h = new Http();
            HttpRequest request = new HttpRequest();
            request.setHeader('SOAPAction', 'urn:orderCheck');
            request.setHeader('Content-Type', 'text/xml');
            request.setBody(body);
            request.setTimeout(120000);
            // url that returns the XML in the response body
            request.setEndpoint(endpoint.substringBetween(','));
            request.setMethod('POST');

            return request;
        } catch (Exception e) {
            system.debug('Credit Factory Error === ' + e.getMessage());
            throw new CreditFactoryException('Report request failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : generateReportXML(String userName, String password, String companyId)
    *  Summary         : Generate XML String to call CreditReform report
    *  CreatedDate     : 10/01/2018
    *  ModifiedDate    : 10/01/2018
    *  Parameters      : userName - from CreditSystem custom setting, password - from CreditSystem custom setting,
                         companyId - Id of Credit System Company (from finder page)
    *  Returns         : String
    ******************************************************************************/
    public static String generateReportXML(String userName, String password, String companyId) {
        String xmlbody = '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns1="http://www.deltavista.com/dspone/ordercheck-if/V001">' +
            '<SOAP-ENV:Header>' +
                '<ns1:messageContext>' +
                    '<ns1:credentials>' +
                        '<ns1:user>' + userName + '</ns1:user>' +
                        '<ns1:password>' + password + '</ns1:password>' +
                    '</ns1:credentials>' +
                '</ns1:messageContext>' +
            '</SOAP-ENV:Header>' +
            '<SOAP-ENV:Body>' +
                '<ns1:orderCheckRequest>' +
                    '<ns1:product>' +
                        '<ns1:name>CreditCheckBusiness</ns1:name>' +
                        '<ns1:country>POL</ns1:country>' +
                    '</ns1:product>' +
                    '<ns1:searchedAddress>' +
                        '<ns1:registry>' +
                            '<ns1:type>PL_NIP</ns1:type>' +
                            '<ns1:number>' + companyId + '</ns1:number>' +
                        '</ns1:registry>' +
                    '</ns1:searchedAddress>' +
                '</ns1:orderCheckRequest>' +
            '</SOAP-ENV:Body>' +
        '</SOAP-ENV:Envelope>';
        return xmlbody;
    }


    /*******************************************************************************
    *  Name            : returnReportBody(Dom.XMLNode node)
    *  Summary         : Return Body DOM element
    *  ModifiedDate    : 10/01/2018
    *  ModifiedDate    : 10/01/2018
    *  Parameters      : node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static Dom.XMLNode returnReportBody(Dom.XMLNode node) {
        for (Dom.XMLNode envelopeField : node.getChildElements()) {
            if (envelopeField.getName() == 'Body') {
                return envelopeField;
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnReportCompany(Dom.XMLNode node, String nipNumber)
    *  Summary         : Return Company
    *  CreatedDate     : 10/01/2018
    *  ModifiedDate    : 10/01/2018
    *  Parameters      : Dom.XMLNode node - body from response, String nipNumber - nip number for getting report
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static CreditCompany returnReportCompany(Dom.XMLNode node, String nipNumber) {
        System.debug('DEBUG: 0 === ');
        try {
            CreditCompany selectedCompany = new CreditCompany();
            selectedCompany.creditSystemCompanyNumber = returnCreditSystemNumber(node);
            selectedCompany.classRating = CreditFactoryUtilities.returnArabicFromTrafficLight(returnClassRating(node));
            selectedCompany.turnOver = CreditFactoryUtilities.returnTurnOverValue(returnCrifRating(node));
            selectedCompany.legalform = returnLegalForm(node);
            selectedCompany.tradeRegisterNumber = returntradeRegisterNumber(node); 
            selectedCompany.taxnumber = returnTaxNumber(node);
            selectedCompany.registerNumber = returnRegisterId(node);
            selectedCompany.staffcompanyrange = returnStaffCompanyRange(node);
            selectedCompany.creditLimit = CreditFactoryUtilities.returnCreditLimitValue(returnCrifRating(node));
            selectedCompany.creditLimitCurrency = 'PLN';
            selectedCompany.dateoffoundation = returnDateoffoundation(node);
            selectedCompany.ageofcompany = returnAgeofcompany(node);
            selectedCompany.status = returnStatus(node);
            selectedCompany.name = returnName(node);
            selectedCompany.tradename = returnTradename(node); 
            selectedCompany.street = returnStreet(node);
            selectedCompany.housenumber = returnHousenumber(node);
            selectedCompany.postcode = returnPostcode(node);
            selectedCompany.city = returnCity(node);
            selectedCompany.postalStreet = returnPostalStreet(node);
            selectedCompany.postalHousenumber = returnPostalHousenumber(node);
            selectedCompany.postalPostcode = returnPostalPostcode(node);
            selectedCompany.postalCity = returnPostalCity(node);
            selectedCompany.registeredStreet = returnRegisteredStreet(node);
            selectedCompany.registeredHousenumber = returnRegisteredHousenumber(node);
            selectedCompany.registeredPostcode = returnRegisteredPostcode(node);
            selectedCompany.registeredCity = returnRegisteredCity(node);
            selectedCompany.country = returnCountry(node);
            selectedCompany.phone = returnPhone(node);
            selectedCompany.fax = returnFax(node);
            selectedCompany.mobile = returnMobile(node);
            selectedCompany.email = returnEmail(node);
            selectedCompany.website = returnWebsite(node);
            selectedCompany.identificationnumber = nipNumber;
            selectedCompany.solvencyIndex = CreditFactoryUtilities.returnSolvencyIndex(returnCrifRating(node));
            selectedCompany.requestStatus = returnRequestStatus(node);
            selectedCompany.obligationOverdue = returnObligationOverdue(node);
            selectedCompany.numberOfHits = returnNumberOfHits(node);
            selectedCompany.policyRulesHits = returnPolicyRules(node);
            selectedCompany.nameChangeDecision = returnNameChangeDecision(node);
            selectedCompany.addressChangeDecision = returnAddressChangeDecision(node);
            selectedCompany.identificationType = returnIdentificationType(node);
            selectedCompany.profitLossLastYear = returnProfitLossLastYear(node);
            selectedCompany.profitLossYearBeforeLast = returnProfitLossYearBeforeLast(node);
            selectedCompany.turnoverLastYear = returnTurnOverLastYear(node);
            selectedCompany.pitCurrency = 'PLN';
            return selectedCompany;
        } catch (Exception e) {
            system.debug('Credit Factory Error === ' + e.getMessage());
            throw new CreditFactoryException('Parsing Report Company failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : returnReportCompanyEmployees(Dom.XMLNode node)
    *  Summary         : Return Company
    *  CreatedDate     : 12/01/2018
    *  ModifiedDate    : 12/01/2018
    *  Parameters      : node - body from response
    *  Returns         : List<CreditCompanyEmployee> - list of employees
    ******************************************************************************/
    public static List<CreditCompanyEmployee> returnReportCompanyEmployees(Dom.XMLNode node) {
        try {
            List<CreditCompanyEmployee> companyEmployeesList = new List<CreditCompanyEmployee>();
            for (Dom.XMLNode bodyField : node.getChildElements()) {
                if (bodyField.getName() == 'orderCheckResponse') {
                    for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                        if (responseField.getName() == 'companyExtendedData') {
                            for (Dom.XMLNode extendedDataField : responseField.getChildElements()) {
                                if (extendedDataField.getName() == 'organization') {
                                    for (Dom.XMLNode orgField : extendedDataField.getChildElements()) {
                                        if (orgField.getName() == 'organizationPosition') {
                                            CreditCompanyEmployee employee = new CreditCompanyEmployee();
                                            for (Dom.XMLNode orgPositionField : orgField.getChildElements()) {
                                                if (orgPositionField.getName() == 'firstName') {
                                                    employee.ename = orgPositionField.getText();
                                                }

                                                if (orgPositionField.getName() == 'name') {
                                                    String name = orgPositionField.getText();
                                                    if (employee.ename != null) {
                                                        employee.ename = employee.ename + ' ' + name;
                                                    } else {
                                                        employee.ename = name;
                                                    }
                                                }

                                                if (orgPositionField.getName() == 'location') {
                                                    for (Dom.XMLNode locationField : orgPositionField.getChildElements()) {
                                                        if (locationField.getName() == 'street') {
                                                            employee.address = locationField.getText();
                                                        }

                                                        if (locationField.getName() == 'house') {
                                                            employee.address = employee.address + ', ' + locationField.getText();
                                                        }

                                                        if (locationField.getName() == 'city') {
                                                            employee.address = employee.address + ', ' + locationField.getText();
                                                        }

                                                        if (locationField.getName() == 'zip') {
                                                            employee.address = employee.address + ', ' + locationField.getText();
                                                        }
                                                    }
                                                }

                                                if (orgPositionField.getName() == 'function') {
                                                    for (Dom.XMLNode functionField : orgPositionField.getChildElements()) {
                                                        if (functionField.getName() == 'functionType') {
                                                            employee.type = functionField.getText();
                                                        }
                                                    }
                                                }
                                            }

                                            companyEmployeesList.add(employee);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }    
            }

            return companyEmployeesList;
        } catch (Exception e) {
            system.debug('Credit Factory Error === ' + e.getMessage() + e.getStackTraceString());
            throw new CreditFactoryException('Parsing Report Company failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : returnCreditSystemNumber(Dom.XMLNode node)
    *  Summary         : Return Company number
    *  CreatedDate     : 11/01/2018
    *  ModifiedDate    : 11/01/2018
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnCreditSystemNumber(Dom.XMLNode node) {
        for (Dom.XMLNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'archiveID') {
                        return responseField.getText();
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnClassRating(Dom.XMLNode node)
    *  Summary         : Return Company class rating
    *  CreatedDate     : 11/01/2018
    *  ModifiedDate    : 11/01/2018
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnClassRating(Dom.XMLNode node) {
        for (Dom.XMLNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'myDecision') {
                        for (Dom.XMLNode myDecisionField : responseField.getChildElements()) {
                            if (myDecisionField.getName() == 'decision') {
                                return myDecisionField.getText();
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnCrifRating(Dom.XMLNode node)
    *  Summary         : Return Company form
    *  CreatedDate     : 12/01/2018
    *  ModifiedDate    : 12/01/2018
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnCrifRating(Dom.XMLNode node) {
        for (Dom.XMLNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'myDecision') {
                        for (Dom.XMLNode myDecisionField : responseField.getChildElements()) {
                            if (myDecisionField.getName() == 'rating') {
                                return myDecisionField.getText();
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnLegalForm(Dom.XMLNode node)
    *  Summary         : Return Company form
    *  CreatedDate     : 10/01/2018
    *  ModifiedDate    : 10/01/2018
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnLegalForm(Dom.XMLNode node) {
        for (Dom.XMLNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'companyBasicData') {
                        for (Dom.XMLNode basicDataField : responseField.getChildElements()) {
                            if (basicDataField.getName() == 'classification') {
                                for (Dom.XMLNode classField : basicDataField.getChildElements()) {
                                    if (classField.getName() == 'companyLegalForm') {
                                        if (legalFormsMap.containsKey(classField.getText())) {
                                            return legalFormsMap.get(classField.getText());
                                        } else {
                                            return classField.getText();
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
    *  Name            : returntradeRegisterNumber(Dom.XMLNode node)
    *  Summary         : Return Company Trade Register Number
    *  CreatedDate     : 10/01/2018
    *  ModifiedDate    : 10/01/2018
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returntradeRegisterNumber(Dom.XMLNode node) {
        for (Dom.XMLNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'companyBasicData') {
                        for (Dom.XMLNode basicDataField : responseField.getChildElements()) {
                            if (basicDataField.getName() == 'registration') {
                                for (Dom.XMLNode regField : basicDataField.getChildElements()) {
                                    if (regField.getName() == 'companyRegistry') {
                                        Boolean isRegon;
                                        String regonNumber; 
                                        for (Dom.XMLNode companyRegField : regField.getChildElements()) {
                                            if (companyRegField.getName() == 'type' && companyRegField.getText() == 'PL_REGON') {
                                                isRegon = true;
                                            }

                                            if (companyRegField.getName() == 'number') {
                                                regonNumber = companyRegField.getText();
                                            }
                                        }

                                        if (isRegon == true && regonNumber != null) {
                                            return regonNumber;
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
    *  Name            : returnTaxNumber(Dom.XMLNode node)
    *  Summary         : Return Company tax number
    *  CreatedDate     : 10/01/2018
    *  ModifiedDate    : 10/01/2018
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnTaxNumber(Dom.XMLNode node) {
        for (Dom.XMLNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'companyBasicData') {
                        for (Dom.XMLNode basicDataField : responseField.getChildElements()) {
                            if (basicDataField.getName() == 'registration') {
                                for (Dom.XMLNode regField : basicDataField.getChildElements()) {
                                    if (regField.getName() == 'companyRegistry') {
                                        Boolean isNip;
                                        String nipNumber; 
                                        for (Dom.XMLNode companyRegField : regField.getChildElements()) {
                                            if (companyRegField.getName() == 'type' && companyRegField.getText() == 'PL_NIP') {
                                                isNip = true;
                                            }

                                            if (companyRegField.getName() == 'number') {
                                                nipNumber = companyRegField.getText();
                                            }
                                        }

                                        if (isNip == true && nipNumber != null) {
                                            return nipNumber;
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
    *  Name            : returnRegisterId(Dom.XMLNode node)
    *  Summary         : Return Company register Id
    *  CreatedDate     : 12/01/2018
    *  ModifiedDate    : 12/01/2018
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnRegisterId(Dom.XMLNode node) {
        for (Dom.XMLNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'companyBasicData') {
                        for (Dom.XMLNode basicDataField : responseField.getChildElements()) {
                            if (basicDataField.getName() == 'registration') {
                                for (Dom.XMLNode regField : basicDataField.getChildElements()) {
                                    if (regField.getName() == 'companyRegistry') {
                                        Boolean isKrs;
                                        String krsNumber; 
                                        for (Dom.XMLNode companyRegField : regField.getChildElements()) {
                                            if (companyRegField.getName() == 'type' && companyRegField.getText() == 'PL_KRS') {
                                                isKrs = true;
                                            }

                                            if (companyRegField.getName() == 'number') {
                                                krsNumber = companyRegField.getText();
                                            }
                                        }

                                        if (isKrs == true && krsNumber != null) {
                                            return krsNumber;
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
    *  Name            : returnStaffCompanyRange(Dom.XMLNode node)
    *  Summary         : Return Company range
    *  CreatedDate     : 12/01/2018
    *  ModifiedDate    : 12/01/2018
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnStaffCompanyRange(Dom.XMLNode node) {
        for (Dom.XMLNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'companyBasicData') {
                        for (Dom.XMLNode basicDataField : responseField.getChildElements()) {
                            if (basicDataField.getName() == 'FinanceData') {
                                for (Dom.XMLNode financeDataField : basicDataField.getChildElements()) {
                                    if (financeDataField.getName() == 'employeesNumberInfo') {
                                        return financeDataField.getText();
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
    *  Summary         : Return Company date of foundation
    *  CreatedDate     : 10/01/2018
    *  ModifiedDate    : 10/01/2018
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnDateoffoundation(Dom.XMLNode node) {
       for (Dom.XMLNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'companyBasicData') {
                        for (Dom.XMLNode basicDataField : responseField.getChildElements()) {
                            if (basicDataField.getName() == 'registration') {
                                for (Dom.XMLNode regField : basicDataField.getChildElements()) {
                                    if (regField.getName() == 'companyRegistry') {
                                        for (Dom.XMLNode companyRegField : regField.getChildElements()) {
                                            if (companyRegField.getName() == 'dateOfRegistration') {
                                                return companyRegField.getText();
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
    *  Name            : returnAgeofCompany(Dom.XMLNode node)
    *  Summary         : Return Company age
    *  CreatedDate     : 12/01/2018
    *  ModifiedDate    : 12/01/2018
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnAgeofCompany(Dom.XMLNode node) {
        for (Dom.XMLNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'decisionMatrix') {
                        for (Dom.XMLNode matrixField : responseField.getChildElements()) {
                            if (matrixField.getName() == 'solvencyDecision') {
                                for (Dom.XMLNode decisionField : matrixField.getChildElements()) {
                                    if (decisionField.getName() == 'daysSinceInBusiness') {
                                        for (Dom.XMLNode daysField : decisionField.getChildElements()) {
                                            if (daysField.getName() == 'value') {
                                                return String.valueOf(Integer.valueOf(daysField.getText())/365.25.round(System.RoundingMode.HALF_EVEN));
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
    *  Name            : returnStatus(Dom.XMLNode node)
    *  Summary         : Return Company status
    *  CreatedDate     : 10/01/2018
    *  ModifiedDate    : 10/01/2018
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnStatus(Dom.XMLNode node) {
        for (Dom.XMLNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'clientExtensions') {
                        for (Dom.XMLNode extensionField : responseField.getChildElements()) {
                            if (extensionField.getName() == 'additionalData') {
                                Boolean isStatus;
                                String status;
                                for (Dom.XMLNode addDataField : extensionField.getChildElements()) {
                                    if (addDataField.getName() == 'name' && addDataField.getText() == 'detailedCompanyStatus') {
                                        isStatus = true;
                                    }

                                    if (addDataField.getName() == 'value') {
                                        status = addDataField.getText();
                                    }
                                }

                                if (isStatus == true && status != null) {
                                    return status;
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
    *  Summary         : Return Company name
    *  CreatedDate     : 10/01/2018
    *  ModifiedDate    : 10/01/2018
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnName(Dom.XMLNode node) {
        for (Dom.XMLNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'foundAddress') {
                        for (Dom.XMLNode foundAddressField : responseField.getChildElements()) {
                            if (foundAddressField.getName() == 'address') {
                                for (Dom.XMLNode addressField : foundAddressField.getChildElements()) {
                                    if (addressField.getName() == 'name') {
                                        return addressField.getText();
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
    *  Name            : returnTradeName(Dom.XMLNode node)
    *  Summary         : Return Company trade name
    *  CreatedDate     : 10/01/2018
    *  ModifiedDate    : 10/01/2018
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnTradeName(Dom.XMLNode node) {
        for (Dom.XMLNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'companyBasicData') {
                        for (Dom.XMLNode basicDataField : responseField.getChildElements()) {
                            if (basicDataField.getName() == 'officialName') {
                                return basicDataField.getText();
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
    *  Summary         : Return Company best known street.
    *  CreatedDate     : 08/10/2018
    *  ModifiedDate    : -
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnStreet(Dom.XMLNode node) {
        for (Dom.XMLNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'foundAddress') {
                        for (Dom.XMLNode foundAddressField : responseField.getChildElements()) {
                            if (foundAddressField.getName() == 'address') {
                                for (Dom.XMLNode addressField : foundAddressField.getChildElements()) {
                                    if (addressField.getName() == 'location') {
                                        for (Dom.XMLNode locationField : addressField.getChildElements()) {
                                            if (locationField.getName() == 'street') {
                                                return locationField.getText();
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
    *  Summary         : Return Company best known housenumber.
    *  CreatedDate     : 08/10/2018
    *  ModifiedDate    : 30/01/2018
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnHousenumber(Dom.XMLNode node) {
        for (Dom.XMLNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'foundAddress') {
                        for (Dom.XMLNode foundAddressField : responseField.getChildElements()) {
                            if (foundAddressField.getName() == 'address') {
                                for (Dom.XMLNode addressField : foundAddressField.getChildElements()) {
                                    if (addressField.getName() == 'location') {
                                        String houseNumber;
                                        for (Dom.XMLNode locationField : addressField.getChildElements()) {
                                            if (locationField.getName() == 'house') {
                                                houseNumber = locationField.getText();
                                            }
                                            if (locationField.getName() == 'houseExtension' && ! String.isEmpty(houseNumber) && locationField.getText() != '') {
                                                houseNumber += '/' + locationField.getText();
                                            }
                                        }

                                        return houseNumber;
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
    *  Summary         : Return Company best known postcode.
    *  CreatedDate     : 08/10/2018
    *  ModifiedDate    : -
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnPostcode(Dom.XMLNode node) {
        for (Dom.XMLNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'foundAddress') {
                        for (Dom.XMLNode foundAddressField : responseField.getChildElements()) {
                            if (foundAddressField.getName() == 'address') {
                                for (Dom.XMLNode addressField : foundAddressField.getChildElements()) {
                                    if (addressField.getName() == 'location') {
                                        for (Dom.XMLNode locationField : addressField.getChildElements()) {
                                            if (locationField.getName() == 'zip') {
                                                return locationField.getText();
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
    *  Summary         : Return Company best known city.
    *  CreatedDate     : 08/10/2018
    *  ModifiedDate    : -
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnCity(Dom.XMLNode node) {
        for (Dom.XMLNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'foundAddress') {
                        for (Dom.XMLNode foundAddressField : responseField.getChildElements()) {
                            if (foundAddressField.getName() == 'address') {
                                for (Dom.XMLNode addressField : foundAddressField.getChildElements()) {
                                    if (addressField.getName() == 'location') {
                                        for (Dom.XMLNode locationField : addressField.getChildElements()) {
                                            if (locationField.getName() == 'city') {
                                                return locationField.getText();
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
    *  Name            : returnPostalStreet(Dom.XMLNode node)
    *  Summary         : Return Company Postal street.
    *  CreatedDate     : 08/10/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnPostalStreet(Dom.XMLNode node) {
        for (Dom.XMLNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'companyBasicData') {
                        for (Dom.XMLNode basicDataField : responseField.getChildElements()) {
                            if (basicDataField.getName() == 'location') {
                                String type = '';
                                String street = '';
                                for (Dom.XMLNode locationField : basicDataField.getChildElements()) {
                                    if (locationField.getName() == 'type') {
                                        type = locationField.getText();
                                    }

                                    if (locationField.getName() == 'street') {
                                        street = locationField.getText();
                                    }
                                }

                                if (type == 'POSTAL') {
                                    return street;
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
    *  Name            : returnPostalHousenumber(Dom.XMLNode node)
    *  Summary         : Return Company Postal housenumber.
    *  CreatedDate     : 09/08/2018
    *  ModifiedDate    : 30/01/2019
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnPostalHousenumber(Dom.XMLNode node) {
        for (Dom.XMLNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'companyBasicData') {
                        for (Dom.XMLNode basicDataField : responseField.getChildElements()) {
                            if (basicDataField.getName() == 'location') {
                                String type = '';
                                String houseNumber;
                                for (Dom.XMLNode locationField : basicDataField.getChildElements()) {
                                    if (locationField.getName() == 'type') {
                                        type = locationField.getText();
                                    }

                                    if (locationField.getName() == 'house') {
                                        houseNumber = locationField.getText();
                                    }

                                    if (locationField.getName() == 'houseExtension' && ! String.isEmpty(houseNumber) && locationField.getText() != '') {
                                        houseNumber += '/' + locationField.getText();
                                    }
                                }

                                if (type == 'POSTAL') {
                                    return houseNumber;
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
    *  Name            : returnPostalPostcode(Dom.XMLNode node)
    *  Summary         : Return Company Postal postcode.
    *  CreatedDate     : 09/08/2018
    *  ModifiedDate    : 08/10/2018
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnPostalPostcode(Dom.XMLNode node) {
        for (Dom.XMLNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'companyBasicData') {
                        for (Dom.XMLNode basicDataField : responseField.getChildElements()) {
                            if (basicDataField.getName() == 'location') {
                                String type = '';
                                String postalCode = '';
                                for (Dom.XMLNode locationField : basicDataField.getChildElements()) {
                                    if (locationField.getName() == 'type') {
                                        type = locationField.getText();
                                    }

                                    if (locationField.getName() == 'zip') {
                                        postalCode = locationField.getText();
                                    }
                                }

                                if (type == 'POSTAL') {
                                    return postalCode;
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
    *  Name            : returnPostalCity(Dom.XMLNode node)
    *  Summary         : Return Company Postal city.
    *  CreatedDate     : 09/08/2018
    *  ModifiedDate    : 08/10/2018
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnPostalCity(Dom.XMLNode node) {
        for (Dom.XMLNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'companyBasicData') {
                        for (Dom.XMLNode basicDataField : responseField.getChildElements()) {
                            if (basicDataField.getName() == 'location') {
                                String type = '';
                                String city = '';
                                for (Dom.XMLNode locationField : basicDataField.getChildElements()) {
                                    if (locationField.getName() == 'type') {
                                        type = locationField.getText();
                                    }

                                    if (locationField.getName() == 'city') {
                                        city = locationField.getText();
                                    }
                                }

                                if (type == 'POSTAL') {
                                    return city;
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
    *  Name            : returnRegisteredStreet(Dom.XMLNode node)
    *  Summary         : Return Company Registered street.
    *  CreatedDate     : 10/01/2018
    *  ModifiedDate    : 08/10/2018
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnRegisteredStreet(Dom.XMLNode node) {
        for (Dom.XMLNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'companyBasicData') {
                        for (Dom.XMLNode basicDataField : responseField.getChildElements()) {
                            if (basicDataField.getName() == 'location') {
                                String type = '';
                                String street = '';
                                for (Dom.XMLNode locationField : basicDataField.getChildElements()) {
                                    if (locationField.getName() == 'type') {
                                        type = locationField.getText();
                                    }

                                    if (locationField.getName() == 'street') {
                                        street = locationField.getText();
                                    }
                                }

                                if (type == 'REGISTERED') {
                                    return street;
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
    *  Name            : returnRegisteredHousenumber(Dom.XMLNode node)
    *  Summary         : Return Company Registered housenumber.
    *  CreatedDate     : 10/01/2018
    *  ModifiedDate    : 30/01/2019
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnRegisteredHousenumber(Dom.XMLNode node) {
        for (Dom.XMLNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'companyBasicData') {
                        for (Dom.XMLNode basicDataField : responseField.getChildElements()) {
                            if (basicDataField.getName() == 'location') {
                                String type = '';
                                String houseNumber = '';
                                String houseNumberExtension = '';
                                for (Dom.XMLNode locationField : basicDataField.getChildElements()) {
                                    if (locationField.getName() == 'type') {
                                        type = locationField.getText();
                                    }

                                    if (locationField.getName() == 'house') {
                                        houseNumber = locationField.getText();
                                    }

                                    if (locationField.getName() == 'houseExtension' && ! String.isEmpty(houseNumber) && locationField.getText() != '') {
                                        houseNumber += '/' + locationField.getText();
                                    }
                                }

                                if (type == 'REGISTERED') {
                                    return houseNumber;
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
    *  Name            : returnRegisteredPostcode(Dom.XMLNode node)
    *  Summary         : Return Company Registered postcode.
    *  CreatedDate     : 10/01/2018
    *  ModifiedDate    : 08/10/2018
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnRegisteredPostcode(Dom.XMLNode node) {
        for (Dom.XMLNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'companyBasicData') {
                        for (Dom.XMLNode basicDataField : responseField.getChildElements()) {
                            if (basicDataField.getName() == 'location') {
                                String type = '';
                                String postalCode = '';
                                for (Dom.XMLNode locationField : basicDataField.getChildElements()) {
                                    if (locationField.getName() == 'type') {
                                        type = locationField.getText();
                                    }

                                    if (locationField.getName() == 'zip') {
                                        postalCode = locationField.getText();
                                    }
                                }

                                if (type == 'REGISTERED') {
                                    return postalCode;
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
    *  Name            : returnRegisteredCity(Dom.XMLNode node)
    *  Summary         : Return Company Registered city.
    *  CreatedDate     : 10/01/2018
    *  ModifiedDate    : 08/10/2018
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnRegisteredCity(Dom.XMLNode node) {
        for (Dom.XMLNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'companyBasicData') {
                        for (Dom.XMLNode basicDataField : responseField.getChildElements()) {
                            if (basicDataField.getName() == 'location') {
                                String type = '';
                                String city = '';
                                for (Dom.XMLNode locationField : basicDataField.getChildElements()) {
                                    if (locationField.getName() == 'type') {
                                        type = locationField.getText();
                                    }

                                    if (locationField.getName() == 'city') {
                                        city = locationField.getText();
                                    }
                                }

                                if (type == 'REGISTERED') {
                                    return city;
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
    *  Summary         : Return Company country
    *  CreatedDate     : 10/01/2018
    *  ModifiedDate    : 10/01/2018
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnCountry(Dom.XMLNode node) {
        for (Dom.XMLNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'foundAddress') {
                        for (Dom.XMLNode foundAddressField : responseField.getChildElements()) {
                            if (foundAddressField.getName() == 'address') {
                                for (Dom.XMLNode addressField : foundAddressField.getChildElements()) {
                                    if (addressField.getName() == 'location') {
                                        for (Dom.XMLNode locationField : addressField.getChildElements()) {
                                            if (locationField.getName() == 'country') {
                                                if (countriesMap.containsKey(locationField.getText())) {
                                                    return countriesMap.get(locationField.getText());
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
        }
        return null;
    }


    /*******************************************************************************
    *  Name            : returnPhone(Dom.XMLNode node)
    *  Summary         : Return Company phone
    *  CreatedDate     : 12/01/2018
    *  ModifiedDate    : 12/01/2018
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnPhone(Dom.XMLNode node) {
        for (Dom.XMLNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'companyBasicData') {
                        for (Dom.XMLNode basicDataField : responseField.getChildElements()) {
                            if (basicDataField.getName() == 'contact') {
                                Boolean isPhone;
                                String phoneNumber;
                                for (Dom.XMLNode contactField : basicDataField.getChildElements()) {
                                    if (contactField.getName() == 'item' && contactField.getText() == 'PHONE') {
                                        isPhone = true;
                                    }

                                    if (contactField.getName() == 'value') {
                                        phoneNumber = contactField.getText();
                                    }
                                }

                                if (isPhone == true && phoneNumber != null) {
                                    return phoneNumber;
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
    *  Name            : returnFax(Dom.XMLNode node)
    *  Summary         : Return Company fax
    *  CreatedDate     : 12/01/2018
    *  ModifiedDate    : 12/01/2018
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnFax(Dom.XMLNode node) {
        for (Dom.XMLNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'companyBasicData') {
                        for (Dom.XMLNode basicDataField : responseField.getChildElements()) {
                            if (basicDataField.getName() == 'contact') {
                                Boolean isFax;
                                String faxNumber;
                                for (Dom.XMLNode contactField : basicDataField.getChildElements()) {
                                    if (contactField.getName() == 'item' && contactField.getText() == 'FAX') {
                                        isFax = true;
                                    }

                                    if (contactField.getName() == 'value') {
                                        faxNumber = contactField.getText();
                                    }
                                }

                                if (isFax == true && faxNumber != null) {
                                    return faxNumber;
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
    *  Name            : returnMobile(Dom.XMLNode node)
    *  Summary         : Return Company mobile
    *  CreatedDate     : 12/01/2018
    *  ModifiedDate    : 12/01/2018
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnMobile(Dom.XMLNode node) {
        for (Dom.XMLNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'companyBasicData') {
                        for (Dom.XMLNode basicDataField : responseField.getChildElements()) {
                            if (basicDataField.getName() == 'contact') {
                                Boolean isMobile;
                                String mobileNumber;
                                for (Dom.XMLNode contactField : basicDataField.getChildElements()) {
                                    if (contactField.getName() == 'item' && contactField.getText() == 'MOBILE') {
                                        isMobile = true;
                                    }

                                    if (contactField.getName() == 'value') {
                                        mobileNumber = contactField.getText();
                                    }
                                }

                                if (isMobile == true && mobileNumber != null) {
                                    return mobileNumber;
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
    *  Summary         : Return Company email
    *  CreatedDate     : 12/01/2018
    *  ModifiedDate    : 12/01/2018
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnEmail(Dom.XMLNode node) {
        for (Dom.XMLNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'companyBasicData') {
                        for (Dom.XMLNode basicDataField : responseField.getChildElements()) {
                            if (basicDataField.getName() == 'contact') {
                                Boolean isEmail;
                                String emailAddress;
                                for (Dom.XMLNode contactField : basicDataField.getChildElements()) {
                                    if (contactField.getName() == 'item' && contactField.getText() == 'EMAIL') {
                                        isEmail = true;
                                    }

                                    if (contactField.getName() == 'value') {
                                        emailAddress = contactField.getText();
                                    }
                                }

                                if (isEmail == true && emailAddress != null) {
                                    return emailAddress;
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
    *  Summary         : Return Company website
    *  CreatedDate     : 12/01/2018
    *  ModifiedDate    : 12/01/2018
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnWebsite(Dom.XMLNode node) {
        for (Dom.XMLNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'companyBasicData') {
                        for (Dom.XMLNode basicDataField : responseField.getChildElements()) {
                            if (basicDataField.getName() == 'contact') {
                                Boolean isWebsite;
                                String webSiteAddress;
                                for (Dom.XMLNode contactField : basicDataField.getChildElements()) {
                                    if (contactField.getName() == 'item' && contactField.getText() == 'WWW') {
                                        isWebsite = true;
                                    }

                                    if (contactField.getName() == 'value') {
                                        webSiteAddress = contactField.getText();
                                    }
                                }

                                if (isWebsite == true && webSiteAddress != null) {
                                    return webSiteAddress;
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
    *  Name            : returnRequestStatus(Dom.XMLNode node)
    *  Summary         : Return request status
    *  CreatedDate     : 12/01/2018
    *  ModifiedDate    : 12/01/2018
    *  Parameters      : node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnRequestStatus(Dom.XMLNode node) {
        for (Dom.XMLNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'decisionMatrix') {
                        for (Dom.XMLNode matrixField : responseField.getChildElements()) {
                            if (matrixField.getName() == 'SolvencyDecision') {
                                for (Dom.XMLNode decisionField : matrixField.getChildElements()) {
                                    if (decisionField.getName() == 'externalSourcesProcessingStatus') {
                                        for (Dom.XMLNode statusField : decisionField.getChildElements()) {
                                            if (statusField.getName() == 'value') {
                                                return statusField.getText();
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
    *  Name            : returnObligationOverdue(Dom.XMLNode node)
    *  Summary         : Return obligation overdue based on payment history
    *  CreatedDate     : 12/01/2018
    *  ModifiedDate    : 12/01/2018
    *  Parameters      : node - body from response
    *  Returns         : Booolean
    ******************************************************************************/
    public static Boolean returnObligationOverdue(Dom.XMLNode node) {
        for (Dom.XMLNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'paymentHistory') {
                        for (Dom.XMLNode paymentHistoryField : responseField.getChildElements()) {
                            if (paymentHistoryField.getName() == 'detail') {
                                Date openDate;
                                Date closeDate;
                                Decimal amountOpen;
                                for (Dom.XMLNode detailField : paymentHistoryField.getChildElements()) {
                                    if (detailField.getName() == 'dateOpen') {
                                        openDate = Date.newInstance(Integer.valueOf(detailField.getText().substring(0, 4)), 
                                            Integer.valueOf(detailField.getText().substring(4, 6)), Integer.valueOf(detailField.getText().substring(6, 8)));
                                    }

                                    if (detailField.getName() == 'dateClosed') {
                                        closeDate = Date.newInstance(Integer.valueOf(detailField.getText().substring(0, 4)), 
                                            Integer.valueOf(detailField.getText().substring(4, 6)), Integer.valueOf(detailField.getText().substring(6, 8)));
                                    }

                                    if (detailField.getName() == 'amountOpen') {
                                        amountOpen = Decimal.valueOf(detailField.getText());
                                    }
                                }

                                if ((openDate != null && closeDate != null && openDate.daysBetween(closeDate) > 7 ||
                                    openDate != null && closeDate == null && openDate.daysBetween(Date.today()) > 7) && amountOpen > 100) {
                                    return true;
                                }
                            }
                        }
                    }
                }
            }
        }
        return false;
    }


    /*******************************************************************************
    *  Name            : returnNumberOfHits(Dom.XMLNode node)
    *  Summary         : Return number of hits from policy rules    
    *  CreatedDate     : 18/06/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnNumberOfHits(Dom.XMLNode node) {
        for (Dom.XMLNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'decisionMatrix') {
                        for (Dom.XMLNode matrixField : responseField.getChildElements()) {
                            if (matrixField.getName() == 'clientExtensionsDecision') {
                                for (Dom.XMLNode decisionField : matrixField.getChildElements()) {
                                    if (decisionField.getName() == 'policyRule') {
                                        for (Dom.XMLNode policyRuleField : decisionField.getChildElements()) {
                                            if (policyRuleField.getName() == 'value') {
                                                return policyRuleField.getText();
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
    *  Name            : returnPolicyRules(Dom.XMLNode node)
    *  Summary         : Return policy rules    
    *  CreatedDate     : 18/06/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : List<String>
    ******************************************************************************/
    public static List<String> returnPolicyRules(Dom.XMLNode node) {
        List<String> policyRulesSet = new List<String>();
        for (Dom.XMLNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'clientExtensions') {
                        for (Dom.XMLNode extensionsField : responseField.getChildElements()) {
                            if (extensionsField.getName() == 'decisionRule') {
                                for (Dom.XMLNode decisionRuleField : extensionsField.getChildElements()) {
                                    if (decisionRuleField.getName() == 'description') {
                                        policyRulesSet.add(decisionRuleField.getText());
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        return policyRulesSet;
    }


    /*******************************************************************************
    *  Name            : returnNameChangeDecision(Dom.XMLNode node)
    *  Summary         : Return name change decision    
    *  CreatedDate     : 18/06/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnNameChangeDecision(Dom.XMLNode node) {
        for (Dom.XMLNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'decisionMatrix') {
                        for (Dom.XMLNode matrixField : responseField.getChildElements()) {
                            if (matrixField.getName() == 'solvencyDecision') {
                                for (Dom.XMLNode decisionField : matrixField.getChildElements()) {
                                    if (decisionField.getName() == 'daysSinceNameChange') {
                                        for (Dom.XMLNode nameChangeField : decisionField.getChildElements()) {
                                            if (nameChangeField.getName() == 'partialDecision') {
                                                return nameChangeField.getText();
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
    *  Name            : returnAddressChangeDecision(Dom.XMLNode node)
    *  Summary         : Return adress change decision    
    *  CreatedDate     : 18/06/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnAddressChangeDecision(Dom.XMLNode node) {
        for (Dom.XMLNode bodyField : node.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'decisionMatrix') {
                        for (Dom.XMLNode matrixField : responseField.getChildElements()) {
                            if (matrixField.getName() == 'solvencyDecision') {
                                for (Dom.XMLNode decisionField : matrixField.getChildElements()) {
                                    if (decisionField.getName() == 'daysSinceDomicileChange') {
                                        for (Dom.XMLNode nameChangeField : decisionField.getChildElements()) {
                                            if (nameChangeField.getName() == 'partialDecision') {
                                                return nameChangeField.getText();
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
    *  Name            : returnIdentificationType(Dom.XMLNode node)
    *  Summary         : Return identification type
    *  CreatedDate     : 08/08/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnIdentificationType(Dom.XMLNode body) {
        for (Dom.XMLNode bodyField : body.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'decisionMatrix') {
                        for (Dom.XMLNode matrixField : responseField.getChildElements()) {
                            if (matrixField.getName() == 'identificationDecision') {
                                for (Dom.XMLNode decisionField : matrixField.getChildElements()) {
                                    if (decisionField.getName() == 'identificationType') {
                                        for (Dom.XMLNode typeField : decisionField.getChildElements()) {
                                            if (typeField.getName() == 'value') {
                                                return typeField.getText();
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
    *  Name            : returnProfitLossLastYear(Dom.XMLNode node)
    *  Summary         : Return profit/loss for the last year.
    *  CreatedDate     : 23/10/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnProfitLossLastYear(Dom.XMLNode body) {
        for (Dom.XMLNode bodyField : body.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'companyExtendedData') {
                        for (Dom.XMLNode companyExtendedDataField : responseField.getChildElements()) {
                            if (companyExtendedDataField.getName() == 'financialStatement') {
                                for (Dom.XMLNode financialStatementField : companyExtendedDataField.getChildElements()) {
                                    if (financialStatementField.getName() == 'profitAndLoss') {
                                        String identifier;
                                        String amount;
                                        String startDate;
                                        String endDate;
                                        for (Dom.XMLNode profitAndLossField : financialStatementField.getChildElements()) {
                                            if (profitAndLossField.getName() == 'financialAccount') {
                                                for (Dom.XMLNode financialAccountField : profitAndLossField.getChildElements()) {
                                                    if (financialAccountField.getName() == 'financialSubAccount') {
                                                        for (Dom.XMLNode financialSubAccountField : financialAccountField.getChildElements()) {
                                                            if (financialSubAccountField.getName() == 'identifier') {
                                                                identifier = financialSubAccountField.getText();
                                                            } else if (financialSubAccountField.getName() == 'amount') {
                                                                for (Dom.XMLNode amountField : financialSubAccountField.getChildElements()) {
                                                                    if (identifier == 'POL_PROF_LOSS_COMP_N' && amountField.getName() == 'amount') {
                                                                        amount = amountField.getText();
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            } else if (profitAndLossField.getName() == 'period') {
                                                for (Dom.XMLNode periodField : profitAndLossField.getChildElements()) {
                                                    if (periodField.getName() == 'startDate') {
                                                        startDate = periodField.getText();
                                                    } else if (periodField.getName() == 'endDate') {
                                                        endDate = periodField.getText();
                                                    }
                                                }
                                            }

                                            if (startDate == String.valueOf(Date.today().year() - 1) + '0101' &&
                                                    endDate == String.valueOf(Date.today().year() - 1) + '1231') {
                                                return amount;
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
    *  Name            : returnProfitLossYearBeforeLast(Dom.XMLNode node)
    *  Summary         : Return profit/loss for the year before last.
    *  CreatedDate     : 23/10/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnProfitLossYearBeforeLast(Dom.XMLNode body) {
        for (Dom.XMLNode bodyField : body.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'companyExtendedData') {
                        for (Dom.XMLNode companyExtendedDataField : responseField.getChildElements()) {
                            if (companyExtendedDataField.getName() == 'financialStatement') {
                                for (Dom.XMLNode financialStatementField : companyExtendedDataField.getChildElements()) {
                                    if (financialStatementField.getName() == 'profitAndLoss') {
                                        String identifier;
                                        String amount;
                                        String startDate;
                                        String endDate;
                                        for (Dom.XMLNode profitAndLossField : financialStatementField.getChildElements()) {
                                            if (profitAndLossField.getName() == 'financialAccount') {
                                                for (Dom.XMLNode financialAccountField : profitAndLossField.getChildElements()) {
                                                    if (financialAccountField.getName() == 'financialSubAccount') {
                                                        for (Dom.XMLNode financialSubAccountField : financialAccountField.getChildElements()) {
                                                            if (financialSubAccountField.getName() == 'identifier') {
                                                                identifier = financialSubAccountField.getText();
                                                            } else if (financialSubAccountField.getName() == 'amount') {
                                                                for (Dom.XMLNode amountField : financialSubAccountField.getChildElements()) {
                                                                    if (identifier == 'POL_PROF_LOSS_COMP_N' && amountField.getName() == 'amount') {
                                                                        amount = amountField.getText();
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            } else if (profitAndLossField.getName() == 'period') {
                                                for (Dom.XMLNode periodField : profitAndLossField.getChildElements()) {
                                                    if (periodField.getName() == 'startDate') {
                                                        startDate = periodField.getText();
                                                    } else if (periodField.getName() == 'endDate') {
                                                        endDate = periodField.getText();
                                                    }
                                                }
                                            }

                                            if (startDate == String.valueOf(Date.today().year() - 2) + '0101' &&
                                                    endDate == String.valueOf(Date.today().year() - 2) + '1231') {
                                                return amount;
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
    *  Name            : returnTurnOverLastYear(Dom.XMLNode node)
    *  Summary         : Return Turn Over for the last year.
    *  CreatedDate     : 23/10/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnTurnOverLastYear(Dom.XMLNode body) {
        for (Dom.XMLNode bodyField : body.getChildElements()) {
            if (bodyField.getName() == 'orderCheckResponse') {
                for (Dom.XMLNode responseField : bodyField.getChildElements()) {
                    if (responseField.getName() == 'companyExtendedData') {
                        for (Dom.XMLNode companyExtendedDataField : responseField.getChildElements()) {
                            if (companyExtendedDataField.getName() == 'financialStatement') {
                                for (Dom.XMLNode financialStatementField : companyExtendedDataField.getChildElements()) {
                                    if (financialStatementField.getName() == 'profitAndLoss') {
                                        String identifier;
                                        String amount;
                                        String startDate;
                                        String endDate;
                                        for (Dom.XMLNode profitAndLossField : financialStatementField.getChildElements()) {
                                            if (profitAndLossField.getName() == 'financialAccount') {
                                                for (Dom.XMLNode financialAccountField : profitAndLossField.getChildElements()) {
                                                    if (financialAccountField.getName() == 'financialSubAccount') {
                                                        for (Dom.XMLNode financialSubAccountField : financialAccountField.getChildElements()) {
                                                            if (financialSubAccountField.getName() == 'identifier') {
                                                                identifier = financialSubAccountField.getText();
                                                            } else if (financialSubAccountField.getName() == 'amount') {
                                                                for (Dom.XMLNode amountField : financialSubAccountField.getChildElements()) {
                                                                    if (identifier == 'POL_PROF_LOSS_COMP_C' && amountField.getName() == 'amount') {
                                                                        amount = amountField.getText();
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            } else if (profitAndLossField.getName() == 'period') {
                                                for (Dom.XMLNode periodField : profitAndLossField.getChildElements()) {
                                                    if (periodField.getName() == 'startDate') {
                                                        startDate = periodField.getText();
                                                    } else if (periodField.getName() == 'endDate') {
                                                        endDate = periodField.getText();
                                                    }
                                                }
                                            }

                                            if (startDate == String.valueOf(Date.today().year() - 1) + '0101' &&
                                                    endDate == String.valueOf(Date.today().year() - 1) + '1231') {
                                                return amount;
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
    *  Name            : generatePdfRequest(String endpoint, String userName, String password, String companyId)
    *  Summary         : Generate HTTP Request to CreditReform
    *  CreatedDate     : 11/01/2018
    *  ModifiedDate    : 11/01/2018
    *  Parameters      : endpoint - from CreditSystem custom setting, serName - from CreditSystem custom setting, 
                         password - from CreditSystem custom setting, companyId - Id of Credit System Company (from finder page)
    *  Returns         : HttpRequest
    ******************************************************************************/
    public static HttpRequest generatePdfRequest(String endpoint, String userName, String password, String companyId) {
        try {
            Http h = new Http();
            HttpRequest request = new HttpRequest();
            request.setHeader('Accept-Encoding', 'gzip,deflate');
            request.setHeader('Content-Type', 'text/xml');
            request.setTimeout(30000);
            // url that returns the XML in the response body
            request.setEndpoint(endpoint.substringAfterLast(',') + '?login=' + userName + '&password=' + password + '&archId=' + companyId);
            // https://demo.deltavista.pl/pdfservice/pdfservlet?login=demo_fleetcor_soap&password=cvujmHe4&archId=4159000002424611
            request.setMethod('POST');
            return request;
        } catch (Exception e) {
            system.debug('Credit Factory Error === ' + e.getMessage());
            throw new CreditFactoryException('Report request failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    public static Map<String, String> countriesMap = new Map<String, String>{
        'POL' => 'Poland'
    };


    public static Map<String, String> legalFormsMap = new Map<String, String>{
        '0' => 'Unknown',
        '1' => 'Private',
        '2' => 'European Economic Interest Grouping (EEIG)',
        '3' => 'Employers Federation',
        '4' => 'Foundation',
        '5' => 'Funds',
        '6' => 'Commune self-government units',
        '7' => 'Other businesses organization',
        '8' => 'Other social or professional organization',
        '9' => 'Other legal entity, which is public benefit organizations',
        '10' => 'Other churches and religious organizations',
        '11' => 'Chamber of commerce',
        '12' => 'Chamber of Crafts',
        '13' => 'Research and development unit',
        '14' => 'Non legal entity organizational units',
        '15' => 'Agricultural circle',
        '16' => 'Medical transport',
        '17' => 'Clergyman legal entity, which is public benefit organization',
        '18' => 'Catholic church',
        '19' => 'Non legal entity church institution, which is public benefit organization',
        '20' => 'Non legal entity public benefit organization',
        '21' => 'Foreign company branch',
        '22' => 'Representation by national trade and services associations',
        '23' => 'Representation by national transport associations',
        '24' => 'National amid industry association',
        '25' => 'National amid industry union',
        '26' => 'Other social legal form',
        '27' => 'Organs of state control and protection of rights',
        '28' => 'Government administration units',
        '29' => 'Private person company',
        '30' => 'Legal entity',
        '31' => 'State agencies',
        '32' => 'Political party™',
        '33' => 'National sport association',
        '34' => 'District local organizational units',
        '35' => 'National company',
        '36' => 'Foreign company',
        '37' => 'Agricultural industry association',
        '38' => 'Courts',
        '39' => 'Independent public health care',
        '40' => 'State treasury',
        '41' => 'Economic self-government',
        '42' => 'Cooperative',
        '43' => 'Joint-stock company',
        '44' => 'Civil company',
        '45' => 'European company',
        '46' => 'General partnership',
        '47' => 'Limited partnership',
        '48' => 'Limited joint-stock',
        '49' => 'private company',
        '50' => 'Partnership company',
        '51' => 'Private limited company',
        '52' => 'Societas Cooperativa Europaea',
        '53' => 'Association',
        '54' => 'Sport association',
        '55' => 'Nationwide sport association',
        '56' => 'Insurance company',
        '57' => 'Province self-government units',
        '58' => 'Residential community',
        '59' => 'Self-government community',
        '60' => 'Trade and services associations',
        '61' => 'Transport association',
        '62' => 'Association of farmers',
        '63' => 'Employers union',
        '64' => 'Agricultural association',
        '65' => 'Polish craftsmen association',
        '66' => 'Sports Association',
        '67' => 'Union of associations',
        '68' => 'Trade union',
        '69' => 'Union of farmers',
        '70' => 'Union of farmers and agricultural circles',
        '71' => 'Any capital or non-capital company or organization',
        '72' => 'Ordinary Association',
        '73' => 'State budget agency',
        '74' => 'Single person company confirmed',
        '75' => 'Other type of partnership company',
        '76' => 'Mutual Reinsurance Associations',
        '77' => 'Main branches of foreign Mutual Reinsurance Associations',
        '78' => 'Universities',
        '79' => 'European Grouping of Territorial Cooperation',
        '80' => 'Employers\' organisations',
        '81' => 'Foreign representations',
        '82' => 'Public kindergarten',
        '83' => 'Private kindergarten',
        '84' => 'Public school',
        '85' => 'Private school',
        '86' => 'Public educational institution',
        '87' => 'Private educational institution',
        '90' => 'Limited joint-stock partnership',
        '100' => 'Private enterprise',
        '322' => 'European Cooperativa',
        '324' => 'European company',
        '348' => 'Joint-stock company',
        '390' => 'Private limited company',
        '502' => 'European Economic Interest Grouping (EEIG) 600 Public authority',
        '600' => 'Public authority',
        '905' => 'Registered branch (foreign)',
        '2000' => 'Foundation',
        '2001' => 'Funds',
        '2002' => 'National company',
        '2003' => 'Cooperative',
        '2004' => 'Civil company',
        '2005' => 'General partnership',
        '2006' => 'Limited partnership',
        '2007' => 'Limited joint-stock',
        '2008' => 'Partnership company',
        '2009' => 'Association',
        '2010' => 'Insurance company'
    };
}