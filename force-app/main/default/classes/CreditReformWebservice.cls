public class CreditReformWebservice {
    public static final String CREDIT_SYSTEM_NAME = 'Creditreform';
    public static Map<String, Boolean> eatCalculationMap;

    /*******************************************************************************
    *  Name            : generateSearchRequest()
    *  Summary         : Generate HTTP Request to CreditReform
    *  CreatedDate     : 31/10/2016
    *  ModifiedDate    : 02/02/2018
    *  Parameters      : String endpoint - from CreditSystem custom setting, String userName - from CreditSystem custom setting, 
                         String apiKey - from CreditSystem custom setting, String password - from CreditSystem custom setting, 
                         String recordName - company name for search, String recordStreet - company street for search, 
                         String recordCity - company city for search, String recordHousenumber - company house number for search, 
                         String recordPostalCode - company postal code for search, String creditSystemId - Id of Creditreform company,
                         String email - email of solo-trader company
    *  Returns         : HttpRequest
    ******************************************************************************/
    public static HttpRequest generateSearchRequest(String endpoint, String userName, String password, String apikey,
                                                    String recordName, String recordStreet, String recordCity, String recordHousenumber, 
                                                    String creditSystemId, String email) {
        try {
            String body = generateSearchXML(userName, password, apiKey, recordName, recordStreet, recordCity, recordHousenumber, creditSystemId, email);
            Http h = new Http();
            HttpRequest request = new HttpRequest();
            request.setHeader('SOAPAction', '');
            request.setHeader('Content-Type', 'application/soap+xml');
            request.setBody(body);
            request.setTimeout(30000);
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
    *  Name            : generateSearchXML()
    *  Summary         : Generate XML String to call CreditReform search
    *  CreatedDate     : 31/10/2016
    *  ModifiedDate    : 25/03/2019
    *  Parameters      : String userName - from CreditSystem custom setting, String password - from CreditSystem custom setting, 
                         String opportunityName - company name for search, String street - company street for search, 
                         String city - company city for search, String houseNumber - company house number for search, 
                         String postalCode - company postal code for search, String creditSystemId - Id of Creditreform company,
                         String email - email of solo-trader company
    *  Returns         : String
    ******************************************************************************/
    public static String generateSearchXML(String userName, String password, String apikey, String opportunityName, String street, 
                                           String city, String housenumber, String creditSystemId, String email) {
        opportunityName = opportunityName.replace('&', ' ');
        if (opportunityName.length() > 90) {
            opportunityName = opportunityName.substring(0, 90);
        }
        if (city != null && city.length() > 25) {
            city = city.substring(0, 25);
        }
        String xmlbody = '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:ns="https://onlineservice.creditreform.de/webservice/0520-0018">' +
           '<soap:Header/>'+
           '<soap:Body>'+
              '<ns:searchRequest>'+
                 '<ns:header>'+
                    '<ns:communicationlanguage>en</ns:communicationlanguage>'+
                    // '<ns:transmissiontimestamp>2016-04-15T14:45:01.95</ns:transmissiontimestamp>'+
                    '<ns:transmissiontimestamp>' + CreditFactoryUtilities.returnCurrentDate() + '</ns:transmissiontimestamp>'+
                    '<ns:keylistversion>20</ns:keylistversion>'+
                    '<ns:clientapplicationname>FleetCor Credit Factory</ns:clientapplicationname>'+
                    '<ns:clientapplicationversion>3</ns:clientapplicationversion>'+
                    '<ns:useraccount>'+ userName +'</ns:useraccount>'+
                    '<ns:generalpassword>'+ password +'</ns:generalpassword>'+
                    '<ns:individualpassword>'+ apikey +'</ns:individualpassword>'+
                 '</ns:header>'+
                 '<ns:body>'+
                    '<ns:searchtype>SETY-1</ns:searchtype>'+
                    ((creditSystemId != null && creditSystemId != '') ? '<ns:identificationnumber>' + creditSystemId + '</ns:identificationnumber>' : '') +
                    '<ns:companyname>'+ opportunityName +'</ns:companyname>' +
                    ((street != null && street != '') ? '<ns:street>'+ street +'</ns:street>' : '') +
                    ((housenumber != null && housenumber != '' && housenumber.replaceAll('[^0-9]', '') != '') ? '<ns:housenumber>'+ housenumber.replaceAll('[^0-9]', '') +'</ns:housenumber>' : '') +
                    (city != null ? '<ns:city>'+ city +'</ns:city>' : '') +
                    '<ns:country>DE</ns:country>' +
                    (email != null ? '<ns:email>' + email + '</ns:email>' : '') +
                 '</ns:body>'+
              '</ns:searchRequest>'+
           '</soap:Body>'+
        '</soap:Envelope>';
        return xmlbody;
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
            String body = generateReportXML(userName, password, apiKey, companyId);
            Http h = new Http();
            HttpRequest request = new HttpRequest();
            request.setHeader('SOAPAction', '');
            request.setHeader('Content-Type', 'application/soap+xml');
            request.setBody(body);
            request.setTimeout(30000);
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
    *  Name            : generateReportXML(String userName, String password, String apikey, String companyId)
    *  Summary         : Generate XML String to call CreditReform report
    *  CreatedDate     : 03/11/2016
    *  Parameters      : userName - from CreditSystem custom setting, password - from CreditSystem custom setting, 
                         apikey - from CreditSystem custom setting, companyId - Id of Credit System Company (from finder page)
    *  Returns         : String
    ******************************************************************************/
    public static String generateReportXML(String userName, String password, String apikey, 
                                           String companyId) {
        String xmlbody = '<soap:Envelope xmlns:ns="https://onlineservice.creditreform.de/webservice/0520-0018" xmlns:soap="http://www.w3.org/2003/05/soap-envelope">'+
                '<soap:Header></soap:Header>'+
                '<soap:Body>'+
                    '<ns:reportRequest>'+
                        '<ns:header>'+
                            '<ns:communicationlanguage>de</ns:communicationlanguage>'+
                            '<ns:transmissiontimestamp>' + CreditFactoryUtilities.returnCurrentDate() + '</ns:transmissiontimestamp>'+
                            '<ns:keylistversion>20</ns:keylistversion>'+
                            '<ns:clientapplicationname>FleetCor Credit Factory</ns:clientapplicationname>'+
                            '<ns:clientapplicationversion>3</ns:clientapplicationversion>'+
                            '<ns:useraccount>'+ userName +'</ns:useraccount>'+
                            '<ns:generalpassword>'+ password +'</ns:generalpassword>'+
                            '<ns:individualpassword>'+ apikey +'</ns:individualpassword>'+
                        '</ns:header>'+
                        '<ns:body>'+
                            '<ns:identificationnumber>' + companyId + '</ns:identificationnumber>'+
                            '<ns:legitimateinterest>LEIN-100</ns:legitimateinterest>'+
                            '<ns:reportlanguage>de</ns:reportlanguage>'+
                            '<ns:producttype>PRTY-5</ns:producttype>'+
                        '</ns:body>'+
                    '</ns:reportRequest>'+
                '</soap:Body>'+
            '</soap:Envelope>';
        return xmlbody;
    }


    /*******************************************************************************
    *  Name            : generateFinanceReportRequest(String endpoint, String userName, String password, String apikey, String companyId)
    *  Summary         : Generate HTTP Request to CreditReform
    *  CreatedDate     : 24/09/2018
    *  ModifiedDate    : -
    *  Parameters      : endpoint - from CreditSystem custom setting ,userName - from CreditSystem custom setting, 
                         password - from CreditSystem custom setting, apikey - from CreditSystem custom setting, 
                         companyId - Id of Credit System Company (from finder page)
    *  Returns         : HttpRequest
    ******************************************************************************/
    public static HttpRequest generateFinanceReportRequest(String endpoint, String userName, String password, String apikey,
                                                           String companyId) {
        try {
            String body = generateFinanceReportXML(userName, password, apiKey, companyId);
            Http h = new Http();
            HttpRequest request = new HttpRequest();
            request.setHeader('SOAPAction', '');
            request.setHeader('Content-Type', 'application/soap+xml');
            request.setBody(body);
            request.setTimeout(30000);
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
    *  Name            : generateFinanceReportXML(String userName, String password, String apikey, String companyId)
    *  Summary         : Generate XML String to call CreditReform report    
    *  CreatedDate     : 24/09/2018
    *  ModifiedDate    : -
    *  Parameters      : userName - from CreditSystem custom setting, password - from CreditSystem custom setting, 
                         apikey - from CreditSystem custom setting, companyId - Id of Credit System Company (from finder page)
    *  Returns         : String
    ******************************************************************************/
    public static String generateFinanceReportXML(String userName, String password, String apikey, 
                                                  String companyId) {
        String xmlbody = '<soap:Envelope xmlns:ns="https://onlineservice.creditreform.de/webservice/0520-0018" xmlns:soap="http://www.w3.org/2003/05/soap-envelope">'+
                '<soap:Header></soap:Header>'+
                '<soap:Body>'+
                    '<ns:reportRequest>'+
                        '<ns:header>'+
                            '<ns:communicationlanguage>de</ns:communicationlanguage>'+
                            '<ns:transmissiontimestamp>' + CreditFactoryUtilities.returnCurrentDate() + '</ns:transmissiontimestamp>'+
                            '<ns:keylistversion>20</ns:keylistversion>'+
                            '<ns:clientapplicationname>FleetCor Credit Factory</ns:clientapplicationname>'+
                            '<ns:clientapplicationversion>3</ns:clientapplicationversion>'+
                            '<ns:useraccount>'+ userName +'</ns:useraccount>'+
                            '<ns:generalpassword>'+ password +'</ns:generalpassword>'+
                            '<ns:individualpassword>'+ apikey +'</ns:individualpassword>'+
                        '</ns:header>'+
                        '<ns:body>'+
                            '<ns:identificationnumber>' + companyId + '</ns:identificationnumber>'+
                            '<ns:legitimateinterest>LEIN-100</ns:legitimateinterest>'+
                            '<ns:reportlanguage>en</ns:reportlanguage>'+
                            '<ns:producttype>PRTY-2</ns:producttype>'+
                        '</ns:body>'+
                    '</ns:reportRequest>'+
                '</soap:Body>'+
            '</soap:Envelope>';
        return xmlbody;
    }


    /*******************************************************************************
    *  Name            : generateOrderRequest(String endpoint, String userName, String password, 
                         String city, String companyName, String postalCode)
    *  Summary         : generate HTTP Request to CreditReform    
    *  CreatedDate     : 13/13/2017 
    *  ModifiedDate    : 15/13/2017
    *  Parameters      : String endpoint - endpoint url, String userName - Creditreform account name, 
                         String password - Creditreform password, String apiKey - Creditreform api key, 
                         String name - company name, String legalForm - company form, 
                         String postalCode - company postal code, String city - company city, 
                         String houseNumber - company house number, String orderSpecifyingText - company additional information
    *  Returns         : HttpRequest
    ******************************************************************************/
    public static HttpRequest generateOrderRequest(String endpoint, String userName, String password, String apiKey, String name, String legalForm, 
                                                   String postalCode, String city, String street, String houseNumber, String orderSpecifyingText) {
        try {
            String xmlBody = generateOrderXML(userName, password, apiKey, name, legalForm, postalCode, city, street, houseNumber, orderSpecifyingText);
            HttpRequest request = new HttpRequest();
            request.setHeader('SOAPAction', '');
            request.setHeader('Content-Type', 'application/soap+xml');
            request.setBody(xmlBody);
            request.setTimeout(30000);
            request.setEndpoint(endpoint);
            request.setMethod('POST');
            return request;
        } catch (Exception e) {
            system.debug('Credit Factory Error === ' + e.getMessage());
            throw new CreditFactoryException('Order request failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : generateOrderXML(String userName, String password, 
                         String city, String companyName, String postalCode)
    *  Summary         : generate XML String to call CreditReform order    
    *  CreatedDate     : 13/13/2017
    *  ModifiedDate    : 15/13/2017
    *  Parameters      : String userName - Creditreform account name, String password - Creditreform password, 
                         String apiKey - Creditreform api key, String name - company name, String legalForm - company form,
                         String postalCode - company postal code, String city - company city,
                         String houseNumber - company house number, String orderSpecifyingText - company additional information
    *  Returns         : String
    ******************************************************************************/
    public static String generateOrderXML(String userName, String password, String apiKey, String name, String legalForm, 
                                          String postalCode, String city, String street, String houseNumber, String orderSpecifyingText) {
        String xmlBody = 
            '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:ns="https://onlineservice.creditreform.de/webservice/0520-0018">' +
                '<soap:Header/>' +
                '<soap:Body>' +
                    '<ns:orderRequest>' +
                        '<ns:header>' +
                            '<ns:communicationlanguage>en</ns:communicationlanguage>' +
                            // '<ns:transmissiontimestamp>2017-12-18T11:00:00.00</ns:transmissiontimestamp>'+
                            '<ns:transmissiontimestamp>' + CreditFactoryUtilities.returnCurrentDate() + '</ns:transmissiontimestamp>' +
                            '<ns:keylistversion>20</ns:keylistversion>' +
                            '<ns:clientapplicationname>FleetCor Credit Factory</ns:clientapplicationname>' +
                            '<ns:clientapplicationversion>3</ns:clientapplicationversion>' +
                            '<ns:useraccount>'+ userName +'</ns:useraccount>' +
                            '<ns:generalpassword>'+ password +'</ns:generalpassword>' +
                            '<ns:individualpassword>'+ apikey +'</ns:individualpassword>' +
                        '</ns:header>' +
                        '<ns:body>' +
                            '<ns:producttype>PRTY-2</ns:producttype>' +
                            '<ns:ordertype>ORTY-1</ns:ordertype>' +
                            '<ns:legitimateinterest>LEIN-100</ns:legitimateinterest>' +
                            '<ns:reportlanguage>de</ns:reportlanguage>' +
                            '<ns:company>' +
                                '<ns:companyname>' + name + '</ns:companyname>' +
                                ((legalForm != null && legalForm != '' && legalform.contains('LEFO')) ? '<ns:legalform>'+ legalForm +'</ns:legalform>' : '') +
                            '</ns:company>' +
                            ((street != null && street != '') ? '<ns:street>'+ street +'</ns:street>' : '') +
                            ((houseNumber != null && houseNumber != '') ? '<ns:housenumber>'+ houseNumber +'</ns:housenumber>' : '') +
                            '<ns:postcode>'+ postalCode +'</ns:postcode>' +
                            '<ns:city>' + city + '</ns:city>' +
                            '<ns:country>DE</ns:country>' +
                            ((orderSpecifyingText != null && orderSpecifyingText != '') ? '<ns:orderspecifyingtext>'+ orderSpecifyingText +'</ns:orderspecifyingtext>' : '') +
                        '</ns:body>' +
                    '</ns:orderRequest>' +
                '</soap:Body>' +
            '</soap:Envelope>';
        return xmlbody;
    }


    /*******************************************************************************
    *  Name            : generateMailboxDirectoryRequest(String endpoint, String userName, String password, String apiKey, String referenceNumber)
    *  Summary         : generate HTTP Request to CreditReform    
    *  CreatedDate     : 13/13/2017 
    *  ModifiedDate    : 13/13/2017
    *  Parameters      : String endpoint - endpoint url, String userName - Creditreform account name, 
                         String password - Creditreform password, String apiKey - Creditreform api key,
                         String referenceNumber - order reference number
    *  Returns         : HttpRequest
    ******************************************************************************/
    public static HttpRequest generateMailboxDirectoryRequest(String endpoint, String userName, String password,
                                                              String apiKey, String referenceNumber) {
        try {
            String xmlBody = generateMailboxDirectoryXML(userName, password, apiKey, referenceNumber);
            HttpRequest request = new HttpRequest();
            request.setHeader('SOAPAction', '');
            request.setHeader('Content-Type', 'application/soap+xml');
            request.setBody(xmlBody);
            request.setTimeout(30000);
            request.setEndpoint(endpoint);
            request.setMethod('POST');
            return request;
        } catch (Exception e) {
            system.debug('Credit Factory Error === ' + e.getMessage());
            throw new CreditFactoryException('Mailbox Directory request failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : generateMailboxDirectoryXML(String userName, String password, String apiKey, String referenceNumber)
    *  Summary         : generate XML String to call CreditReform order    
    *  CreatedDate     : 13/13/2017
    *  ModifiedDate    : 13/13/2017
    *  Parameters      : String userName - Creditreform account name, String password - Creditreform password, 
                         String apiKey - Creditreform api key, String referenceNumber - order reference number
    *  Returns         : String
    ******************************************************************************/
    public static String generateMailboxDirectoryXML(String userName, String password, String apiKey, String referenceNumber) {
        String xmlBody = 
            '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:ns="https://onlineservice.creditreform.de/webservice/0520-0018">' +
               '<soap:Header/>' +
               '<soap:Body>' +
                    '<ns:mailboxdirectoryRequest>' +
                        '<ns:header>' +
                            '<ns:communicationlanguage>en</ns:communicationlanguage>' +
                            // '<ns:transmissiontimestamp>2017-12-18T11:00:00.00</ns:transmissiontimestamp>'+
                            '<ns:transmissiontimestamp>' + CreditFactoryUtilities.returnCurrentDate() + '</ns:transmissiontimestamp>' +
                            '<ns:keylistversion>20</ns:keylistversion>' +
                            '<ns:clientapplicationname>FleetCor Credit Factory</ns:clientapplicationname>' +
                            '<ns:clientapplicationversion>3</ns:clientapplicationversion>' +
                            '<ns:useraccount>'+ userName +'</ns:useraccount>' +
                            '<ns:generalpassword>'+ password +'</ns:generalpassword>' +
                            '<ns:individualpassword>'+ apikey +'</ns:individualpassword>' +
                        '</ns:header>' +
                        '<ns:body>' +
                            '<ns:referencenumber>' + referenceNumber + '</ns:referencenumber>' +
                            '<ns:openorders>false</ns:openorders>' +
                            '<ns:entriesread>false</ns:entriesread>' +
                            '<ns:entriesunread>true</ns:entriesunread>' +
                            '<ns:deliverytypeupdate>true</ns:deliverytypeupdate>' +
                            '<ns:deliverytypereport>true</ns:deliverytypereport>' +
                            '<ns:deliverytypestatusreply>true</ns:deliverytypestatusreply>' +
                            '<ns:deliverytypesupplement>true</ns:deliverytypesupplement>' +
                            '<ns:deliverytypestockdelivery>true</ns:deliverytypestockdelivery>' +
                        '</ns:body>' +
                    '</ns:mailboxdirectoryRequest>' +
                '</soap:Body>' +
            '</soap:Envelope>';
        return xmlBody;
    }


    /*******************************************************************************
    *  Name            : generateMailboxEntryRequest(String endpoint, String userName, String password, String apiKey, String mailboxEntryNumber)
    *  Summary         : generate HTTP Request to CreditReform    
    *  CreatedDate     : 18/18/2017 
    *  ModifiedDate    : 18/18/2017
    *  Parameters      : String endpoint - endpoint url, String userName - Creditreform account name, String password - Creditreform password, 
                         String apiKey - Creditreform api key, String mailboxEntryNumber - number of checked mailbox entry
    *  Returns         : HttpRequest
    ******************************************************************************/
    public static HttpRequest generateMailboxEntryRequest(String endpoint, String userName, String password, 
                                                          String apiKey, String mailboxEntryNumber) {
        try {
            String xmlBody = generateMailboxEntryXML(userName, password, apiKey, mailboxEntryNumber);
            HttpRequest request = new HttpRequest();
            request.setHeader('SOAPAction', '');
            request.setHeader('Content-Type', 'application/soap+xml');
            request.setBody(xmlBody);
            request.setTimeout(30000);
            request.setEndpoint(endpoint);
            request.setMethod('POST');
            return request;
        } catch (Exception e) {
            system.debug('Credit Factory Error === ' + e.getMessage());
            throw new CreditFactoryException('Mailbox Entry request failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }


    /*******************************************************************************
    *  Name            : generateMailboxEntryXML(String userName, String password, String apiKey, String mailboxEntryNumber)
    *  Summary         : generate XML String to call CreditReform order    
    *  CreatedDate     : 18/18/2017
    *  ModifiedDate    : 18/18/2017
    *  Parameters      : String userName - Creditreform account name, String password - Creditreform password, 
                         String apiKey - Creditreform api key, String mailboxEntryNumber - number of checked mailbox entry
    *  Returns         : String
    ******************************************************************************/
    public static String generateMailboxEntryXML(String userName, String password, String apiKey, String mailboxEntryNumber) {
        String xmlbody =
            '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:ns="https://onlineservice.creditreform.de/webservice/0520-0018">' +
                '<soap:Header/>' +
                '<soap:Body>' +
                    '<ns:mailboxentryRequest>' +
                        '<ns:header>' +
                            '<ns:communicationlanguage>en</ns:communicationlanguage>' +
                            // '<ns:transmissiontimestamp>2017-12-18T11:00:00.00</ns:transmissiontimestamp>'+
                            '<ns:transmissiontimestamp>' + CreditFactoryUtilities.returnCurrentDate() + '</ns:transmissiontimestamp>' +
                            '<ns:keylistversion>20</ns:keylistversion>' +
                            '<ns:clientapplicationname>FleetCor Credit Factory</ns:clientapplicationname>' +
                            '<ns:clientapplicationversion>3</ns:clientapplicationversion>' +
                            '<ns:useraccount>'+ userName +'</ns:useraccount>' +
                            '<ns:generalpassword>'+ password +'</ns:generalpassword>' +
                            '<ns:individualpassword>'+ apikey +'</ns:individualpassword>' +
                        '</ns:header>' +
                        '<ns:body>' +
                            '<ns:mailboxentrynumber>' + mailboxEntryNumber + '</ns:mailboxentrynumber>' +
                        '</ns:body>' +
                    '</ns:mailboxentryRequest>' +
                '</soap:Body>' +
            '</soap:Envelope>';
        return xmlBody;
    }


    /*******************************************************************************
    *  Name            : returnSearchCompany(Dom.XMLNode node)
    *  Summary         : Return Body DOM element
    *  CreatedDate     : 1/11/2016
    *  Parameters      : node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static List<CreditCompany> returnSearchCompany(Dom.XMLNode node) {
        try {
            List<CreditCompany> companiesFromSearch = new List<CreditCompany>();
            for (Dom.XMLNode hit : node.getChildElements()) {
                if (hit.getName() == 'hit') {
                    CreditCompany company = new CreditCompany();
                    company.isReportExists = true;
                    for (Dom.XMLNode field : hit.getChildElements()) {
                        if (field.getName() == 'companyname') {
                            company.name = field.getText();
                        }
                        if (field.getName() == 'identificationnumber') {
                            company.identificationnumber = field.getText();
                            company.creditSystemCompanyNumber = company.identificationnumber.subString(4, 14);
                        }
                        if (field.getName() == 'tradename') {
                            company.tradename = field.getText();
                        }
                        if (field.getName() == 'street') {
                            company.street = field.getText();
                        }
                        if (field.getName() == 'housenumber') {
                            company.housenumber = field.getText();
                        }
                        if (field.getName() == 'postcode') {
                            company.postcode = field.getText();
                        }
                        if (field.getName() == 'city') {
                            company.city = field.getText();
                        }
                        if (field.getName() == 'operationalstatus') {
                            for (Dom.XMLNode status : field.getChildElements()) {
                                if (status.getName() == 'designation') {
                                    company.status = status.getText();
                                }
                            }
                        }
                    }
                    companiesFromSearch.add(company);
                }
            }

            return companiesFromSearch;
        } catch (Exception e) {
            system.debug('Credit Factory Error === ' + e.getMessage());
            throw new CreditFactoryException('Parsing Search Company failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }

    /*******************************************************************************
    *  Name            : returnReportCompany(Dom.XMLNode node)
    *  Summary         : Return Company
    *  CreatedDate     : 4/11/2016
    *  Parameters      : node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static CreditCompany returnReportCompany(Dom.XMLNode node, String creditSystemCompanyNumber) {
        try {
            CreditCompany selectedCompany = new CreditCompany();
            selectedCompany.creditSystemCompanyNumber = creditSystemCompanyNumber.subString(4, 14);
            selectedCompany.referencenumber = returnReferenceNumber(node);
            selectedCompany.classRating = CreditFactoryUtilities.returnArabic(returnClassRating(node));
            selectedCompany.solvencyIndex = returnSolvencyIndex(node);
            selectedCompany.development = returnDevelopment(node);
            selectedCompany.turnOver = returnTurnOver(node);
            selectedCompany.legalform = returnLegalForm(node);
            selectedCompany.vatid = returnVatId(node);
            selectedCompany.taxnumber = returnTaxNumber(node);
            selectedCompany.datelegalform = returnDateLegalForm(node);
            selectedCompany.registerNumber = returnRegisterId(node);
            selectedCompany.datelastregisterentry = returnDateLastRegisterEntry(node);
            selectedCompany.countyCourt = returnCountyCourt(node);
            selectedCompany.paymentBehaviour = returnPaymentBehaviour(node);
            selectedCompany.staffcompanyrange = returnStaffCompanyRange(node);
            selectedCompany.creditLimit = returnCreditLimit(node);
            selectedCompany.creditLimitCurrency = returnCreditLimitCurrency(node);
            selectedCompany.creditDecision = returnCreditDecision(node);
            selectedCompany.dateoffoundation = returnDateoffoundation(node);
            selectedCompany.ageofcompany = returnAgeofcompany(node);
            selectedCompany.firstlegalform = returnFirstlegalform(node);
            selectedCompany.status = returnStatus(node);
            selectedCompany.name = returnName(node);
            selectedCompany.tradename = returnTradename(node);
            selectedCompany.street = returnStreet(node);
            selectedCompany.housenumber = returnHousenumber(node);
            selectedCompany.postcode = returnPostcode(node);
            selectedCompany.city = returnCity(node);
            selectedCompany.country = returnCountry(node);
            selectedCompany.phone = returnPhone(node);
            selectedCompany.fax = returnFax(node);
            selectedCompany.mobile = returnMobile(node);
            selectedCompany.email = returnEmail(node);
            selectedCompany.website = returnWebsite(node);
            selectedCompany.identificationnumber = creditSystemCompanyNumber;
            return selectedCompany;
        } catch (Exception e) {
            system.debug('Credit Factory Error === ' + e.getMessage());
            throw new CreditFactoryException('Parsing Report Company failed. ' + CreditFactoryUtilities.CONTACT_ADMIN);
        }
    }

    /*******************************************************************************
    *  Name            : returnReportCompanyEmployees(Dom.XMLNode node)
    *  Summary         : Return Company Employees
    *  CreatedDate     : 4/11/2016
    *  Parameters      : node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static List<CreditCompanyEmployee> returnReportCompanyEmployees(Dom.XMLNode node) {
        List<CreditCompanyEmployee> companyEmployeesList = returnEmployees(node);
        return companyEmployeesList;
    }

    public static List<CreditCompanyEmployee> returnEmployees(Dom.XMLNode node) {
        List<CreditCompanyEmployee> companyEmployeesList = new List<CreditCompanyEmployee>();

        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'deputymanagement') {
                        for (Dom.XMLNode deputymanagementfields : reportfields.getChildElements()) {
                            if (deputymanagementfields.getName() == 'participantcapacities') {
                                companyEmployeesList.addAll(returnEmployee(deputymanagementfields.getChildElements()));
                                for (Dom.XMLNode deputymanagementfeildsInner : deputymanagementfields.getChildElements()) {
                                    if (deputymanagementfeildsInner.getName() == 'active') {
                                        for (Dom.XMLNode activefields : deputymanagementfeildsInner.getChildElements()) {
                                            if (activefields.getName() == 'complementaryparticipantcapacities') {
                                                for (Dom.XMLNode complementaryparticipantcapacitiesFields : activefields.getChildElements()) {
                                                    if (complementaryparticipantcapacitiesFields.getName() == 'participantcapacities') {
                                                        companyEmployeesList.addAll(returnEmployee(complementaryparticipantcapacitiesFields.getChildElements()));
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
        }
        return companyEmployeesList;
    }

    public static List<CreditCompanyEmployee> returnEmployee(List<Dom.XMLNode> fields) {
        String eType = '';
        List<CreditCompanyEmployee> currentEmployeesList = new List<CreditCompanyEmployee>();
        for (Dom.XMLNode participantcapacitiesFields : fields) {

            if (participantcapacitiesFields.getName() == 'capacity') {
                for (Dom.XMLNode capacityFields : participantcapacitiesFields.getChildElements()) {
                    if (capacityFields.getName() == 'designation') {
                        eType = '';
                        eType = capacityFields.getText();
                        break;
                    }
                }
            }
            if (participantcapacitiesFields.getName() == 'active') {
                CreditCompanyEmployee currentEmployee = new CreditCompanyEmployee();
                currentEmployee.type = eType;
                for (Dom.XMLNode activeFields : participantcapacitiesFields.getChildElements()) {
                    if (activeFields.getName() == 'identificationnumber') {
                        currentEmployee.enumber = activeFields.getText();
                    }

                    if (activeFields.getName() == 'privateperson') {
                        for (Dom.XMLNode privatepersonFields : activeFields.getChildElements()) {
                            if (privatepersonFields.getName() == 'firstname') {
                                if (String.isEmpty(currentEmployee.ename)) {
                                    currentEmployee.ename = privatepersonFields.getText();
                                } else {
                                    currentEmployee.ename = currentEmployee.ename + ' ' + privatepersonFields.getText();
                                }
                            }

                            if (privatepersonFields.getName() == 'surname') {
                                if (String.isEmpty(currentEmployee.ename)) {
                                    currentEmployee.ename = privatepersonFields.getText();
                                } else {
                                    currentEmployee.ename = currentEmployee.ename + ' ' + privatepersonFields.getText();
                                }
                            }

                            if (privatepersonFields.getName() == 'dateofbirth') {
                                currentEmployee.dateofbirth = privatepersonFields.getText();
                            }
                        }
                    }

                    if (activeFields.getName() == 'participatingsince') {
                        currentEmployee.participationdate = activeFields.getText();
                    }

                    if (activeFields.getName() == 'country') {
                        for (Dom.XMLNode countryFields : activeFields.getChildElements()) {
                            if (countryFields.getName() == 'key') {
                                if (String.isEmpty(currentEmployee.address)) {
                                    currentEmployee.address = activeFields.getText();
                                } else {
                                    currentEmployee.address = currentEmployee.address + ', ' + activeFields.getText();
                                }
                            }
                        }
                    }

                    if (activeFields.getName() == 'city') {
                        if (String.isEmpty(currentEmployee.address)) {
                            currentEmployee.address = activeFields.getText();
                        } else {
                            currentEmployee.address = currentEmployee.address + ', ' + activeFields.getText();
                        }
                    }

                    if (activeFields.getName() == 'street') {
                        if (String.isEmpty(currentEmployee.address)) {
                            currentEmployee.address = activeFields.getText();
                        } else {
                            currentEmployee.address = currentEmployee.address + ', ' + activeFields.getText();
                        }
                    }

                    if (activeFields.getName() == 'housenumber') {
                        if (String.isEmpty(currentEmployee.address)) {
                            currentEmployee.address = activeFields.getText();
                        } else {
                            currentEmployee.address = currentEmployee.address + ', ' + activeFields.getText();
                        }
                    }

                    if (activeFields.getName() == 'postcode') {
                        if (String.isEmpty(currentEmployee.address)) {
                            currentEmployee.address = activeFields.getText();
                        } else {
                            currentEmployee.address = currentEmployee.address + ', ' + activeFields.getText();
                        }
                    }
                }
                if (currentEmployee.address != null) {
                    currentEmployee.address = currentEmployee.address.removeEnd(', ');
                }
                currentEmployeesList.add(currentEmployee);
            }
        }

        return currentEmployeesList;
    }

    public static String returnReferenceNumber(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'referencenumber') {
                return field.getText();
                break;
            }
        }
        return null;
    }


    public static String returnClassRating(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'solvencyfinanceindustry') {
                        for (Dom.XMLNode industryfields : reportfields.getChildElements()) {
                            if (industryfields.getName() == 'class') {
                                return industryfields.getText();
                            }
                        }
                    }

                    if (reportfields.getName() == 'solvencyindex') {
                        for (Dom.XMLNode indexFields : reportfields.getChildElements()) {
                            if (indexFields.getName() == 'solvencyindextwozero') {
                                return CreditFactoryUtilities.returnArabicFromSolvencyIndex(indexFields.getText());
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    public static String returnSolvencyIndex(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'solvencyindex') {
                        for (Dom.XMLNode indexFields : reportfields.getChildElements()) {
                            if (indexFields.getName() == 'solvencyindextwozero') {
                                return indexFields.getText();
                            }
                        }
                    }
                }
            }
        }
        return null;
    }


    public static String returnDevelopment(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'businessdevelopment') {
                        for (Dom.XMLNode developmentfields : reportfields.getChildElements()) {
                            if (developmentfields.getName() == 'businessdevelopment') {
                                for (Dom.XMLNode development2fields : developmentfields.getChildElements()) {
                                    if (developmentfields.getName() == 'grade') {
                                        return development2fields.getText();
                                        break;
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

    public static String returnTurnOver(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'turnovercompanyrange') {
                        for (Dom.XMLNode turnovercompanyrangeFields : reportfields.getChildElements()) {
                            if (turnovercompanyrangeFields.getName() == 'range') {
                                return turnovercompanyrangeFields.getText();
                                break;
                            }
                        }
                    }
                }
            }
        }
        return null;
    }

    public static String returnLegalForm(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'legalform') {
                        for (Dom.XMLNode legalformfields : reportfields.getChildElements()) {
                            if (legalformfields.getName() == 'presentlegalform') {
                                for (Dom.XMLNode presentlegalformfields : legalformfields.getChildElements()) {
                                    if (presentlegalformfields.getName() == 'key') {
                                        if (legalFormsMap.containsKey(presentlegalformfields.getText())) {
                                            return legalFormsMap.get(presentlegalformfields.getText());
                                            break;
                                        } else {
                                            return presentlegalformfields.getText();
                                            break;
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

    public static String returnVatId(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'taxdata') {
                        for (Dom.XMLNode taxdatafields : reportfields.getChildElements()) {
                            if (taxdatafields.getName() == 'vatid') {
                                return taxdatafields.getText();
                                break;
                            }
                        }
                    }
                }
            }
        }
        return null;
    }

    public static String returnTaxNumber(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'taxdata') {
                        for (Dom.XMLNode taxdatafields : reportfields.getChildElements()) {
                            if (taxdatafields.getName() == 'taxnumber') {
                                return taxdatafields.getText();
                                break;
                            }
                        }
                    }
                }
            }
        }
        return null;
    }

    public static String returnDateLegalForm(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'register') {
                        for (Dom.XMLNode registerfields : reportfields.getChildElements()) {
                            if (registerfields.getName() == 'datelegalform') {
                                return registerfields.getText();
                                break;
                            }
                        }
                    }
                }
            }
        }
        return null;
    }

    public static String returnRegisterId(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'register') {
                        for (Dom.XMLNode registerfields : reportfields.getChildElements()) {
                            if (registerfields.getName() == 'registerid') {
                                return registerfields.getText();
                                break;
                            }
                        }
                    }
                }
            }
        }
        return null;
    }

    public static String returnDateLastRegisterEntry(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'register') {
                        for (Dom.XMLNode registerfields : reportfields.getChildElements()) {
                            if (registerfields.getName() == 'datelastregisterentry') {
                                return registerfields.getText();
                                break;
                            }
                        }
                    }
                }
            }
        }
        return null;
    }

    public static String returnCountyCourt(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'register') {
                        for (Dom.XMLNode registerfields : reportfields.getChildElements()) {
                            if (registerfields.getName() == 'register') {
                                String countyCourt = '';
                                for (Dom.XMLNode register2fields : registerfields.getChildElements()) {
                                    if (register2fields.getName() == 'shortdesignationcourt') {
                                        countyCourt += register2fields.getText();
                                    }

                                    if (register2fields.getName() == 'city') {
                                        countyCourt += ' ' + register2fields.getText();
                                    }

                                    if (register2fields.getName() == 'postcode') {
                                        countyCourt += ' ' + register2fields.getText();
                                    }
                                }
                                return countyCourt;
                                break;
                            }
                        }
                    }
                }
            }
        }
        return null;
    }

    public static String returnPaymentBehaviour(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'paymentmode') {
                        for (Dom.XMLNode paymentmodeFields : reportfields.getChildElements()) {
                            if (paymentmodeFields.getName() == 'paymentmode') {
                                String paymentBehaviour = '';
                                for (Dom.XMLNode paymentmodeFields2 : paymentmodeFields.getChildElements()) {
                                    if (paymentmodeFields2.getName() == 'key') {
                                        paymentBehaviour = paymentBehaviour + paymentmodeFields2.getText() + ' ';
                                    }
                                    if (paymentmodeFields2.getName() == 'designation') {
                                        paymentBehaviour = paymentBehaviour + paymentmodeFields2.getText() + ' ';
                                    }
                                    if (paymentmodeFields2.getName() == 'grade') {
                                        paymentBehaviour = paymentBehaviour + paymentmodeFields2.getText() + ' ';
                                    }
                                    return paymentBehaviour;
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }

    public static String returnStaffCompanyRange(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'staffcompanyrange') {
                        for (Dom.XMLNode staffcompanyrangefields : reportfields.getChildElements()) {
                            if (staffcompanyrangefields.getName() == 'range') {
                                return staffcompanyrangefields.getText();
                                break;
                            }
                        }
                    }
                }
            }
        }
        return null;
    }

    public static String returnCreditLimit(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'creditopinion') {
                        for (Dom.XMLNode creditopinionfields : reportfields.getChildElements()) {
                            if (creditopinionfields.getName() == 'creditlimit') {
                                for (Dom.XMLNode creditlimitfields : creditopinionfields.getChildElements()) {
                                    if (creditlimitfields.getName() == 'value') {
                                        return creditlimitfields.getText();
                                        break;
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

    public static String returnDateoffoundation(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'foundation') {
                        for (Dom.XMLNode foundationfields : reportfields.getChildElements()) {
                            if (foundationfields.getName() == 'dateoffoundation') {
                                return foundationfields.getText();
                                break;
                            }
                        }
                    }
                }
            }
        }
        return null;
    }

    public static String returnAgeofcompany(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'foundation') {
                        for (Dom.XMLNode foundationfields : reportfields.getChildElements()) {
                            if (foundationfields.getName() == 'ageofcompany') {
                                return foundationfields.getText();
                                break;
                            }
                        }
                    }
                }
            }
        }
        return null;
    }

    public static String returnFirstlegalform(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'foundation') {
                        for (Dom.XMLNode foundationfields : reportfields.getChildElements()) {
                            if (foundationfields.getName() == 'firstlegalform') {
                                for (Dom.XMLNode firstlegalformfields : foundationfields.getChildElements()) {
                                    if (firstlegalformfields.getName() == 'designation') {
                                        return firstlegalformfields.getText();
                                        break;
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

    public static String returnStatus(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'companyidentification') {
                        for (Dom.XMLNode companyidentificationfields : reportfields.getChildElements()) {
                            if (companyidentificationfields.getName() == 'status') {
                                for (Dom.XMLNode statusfields : companyidentificationfields.getChildElements()) {
                                    if (statusfields.getName() == 'designation') {
                                        return statusfields.getText();
                                        break;
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

    public static String returnName(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'companyidentification') {
                        for (Dom.XMLNode companyidentificationfields : reportfields.getChildElements()) {
                            if (companyidentificationfields.getName() == 'companyname') {
                                return companyidentificationfields.getText();
                                break;
                            }
                        }
                    }
                }
            }
        }
        return null;
    }

    public static String returnTradename(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'companyidentification') {
                        for (Dom.XMLNode companyidentificationfields : reportfields.getChildElements()) {
                            if (companyidentificationfields.getName() == 'tradename') {
                                return companyidentificationfields.getText();
                                break;
                            }
                        }
                    }
                }
            }
        }
        return null;
    }

    public static String returnStreet(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'companyidentification') {
                        for (Dom.XMLNode companyidentificationfields : reportfields.getChildElements()) {
                            if (companyidentificationfields.getName() == 'street') {
                                return companyidentificationfields.getText();
                                break;
                            }
                        }
                    }
                }
            }
        }
        return null;
    }

    public static String returnHousenumber(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'companyidentification') {
                        String houseNumber = '';
                        for (Dom.XMLNode companyidentificationfields : reportfields.getChildElements()) {
                            if (companyidentificationfields.getName() == 'housenumber') {
                                houseNumber = companyidentificationfields.getText();
                            }

                            if (companyidentificationfields.getName() == 'housenumberaffix') {
                                houseNumber += ' ' + companyidentificationfields.getText();
                            }
                        }

                        return houseNumber;
                    }
                }
            }
        }
        return null;
    }

    public static String returnPostcode(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'companyidentification') {
                        for (Dom.XMLNode companyidentificationfields : reportfields.getChildElements()) {
                            if (companyidentificationfields.getName() == 'postcode') {
                                return companyidentificationfields.getText();
                                break;
                            }
                        }
                    }
                }
            }
        }
        return null;
    }

    public static String returnCity(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'companyidentification') {
                        for (Dom.XMLNode companyidentificationfields : reportfields.getChildElements()) {
                            if (companyidentificationfields.getName() == 'city') {
                                return companyidentificationfields.getText();
                                break;
                            }
                        }
                    }
                }
            }
        }
        return null;
    }

    public static String returnCountry(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'companyidentification') {
                        for (Dom.XMLNode companyidentificationfields : reportfields.getChildElements()) {
                            if (companyidentificationfields.getName() == 'country') {
                                for (Dom.XMLNode countryfields : companyidentificationfields.getChildElements()) {
                                    if (countryfields.getName() == 'key') {
                                        return countryfields.getText();
                                        break;
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

    public static String returnPhone(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'companyidentification') {
                        for (Dom.XMLNode companyidentificationfields : reportfields.getChildElements()) {
                            String phone = '';
                            if (companyidentificationfields.getName() == 'phone') {
                                for (Dom.XMLNode phonefields : companyidentificationfields.getChildElements()) {
                                    if (phonefields.getName() == 'countrycode') {
                                        phone = phonefields.getText();
                                    }

                                    if (phonefields.getName() == 'diallingcode') {
                                        phone = phone + phonefields.getText();
                                    }

                                    if (phonefields.getName() == 'phonenumber') {
                                        phone = phone + phonefields.getText();
                                    }
                                }
                                return phone;
                                break;
                            }
                        }
                    }
                }
            }
        }
        return null;
    }

    public static String returnFax(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'companyidentification') {
                        for (Dom.XMLNode companyidentificationfields : reportfields.getChildElements()) {
                            String fax = '';
                            if (companyidentificationfields.getName() == 'fax') {
                                for (Dom.XMLNode faxfields : companyidentificationfields.getChildElements()) {
                                    if (faxfields.getName() == 'countrycode') {
                                        fax += faxfields.getText();
                                    }

                                    if (faxfields.getName() == 'diallingcode') {
                                        fax += faxfields.getText();
                                    }

                                    if (faxfields.getName() == 'phonenumber') {
                                        fax += faxfields.getText();
                                    }
                                }
                                return fax;
                                break;
                            }
                        }
                    }
                }
            }
        }
        return null;
    }

    public static String returnMobile(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'companyidentification') {
                        for (Dom.XMLNode companyidentificationfields : reportfields.getChildElements()) {
                            String mobile = '';
                            if (companyidentificationfields.getName() == 'mobile') {
                                for (Dom.XMLNode mobilefields : companyidentificationfields.getChildElements()) {
                                    if (mobilefields.getName() == 'countrycode') {
                                        mobile = mobilefields.getText();
                                    }

                                    if (mobilefields.getName() == 'diallingcode') {
                                        mobile = mobile + mobilefields.getText();
                                    }

                                    if (mobilefields.getName() == 'phonenumber') {
                                        mobile = mobile + mobilefields.getText();
                                    }
                                }
                                return mobile;
                                break;
                            }
                        }
                    }
                }
            }
        }
        return null;
    }

    public static String returnEmail(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'companyidentification') {
                        for (Dom.XMLNode companyidentificationfields : reportfields.getChildElements()) {
                            if (companyidentificationfields.getName() == 'email') {
                                return companyidentificationfields.getText();
                                break;
                            }
                        }
                    }
                }
            }
        }
        return null;
    }

    public static String returnWebsite(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'companyidentification') {
                        for (Dom.XMLNode companyidentificationfields : reportfields.getChildElements()) {
                            if (companyidentificationfields.getName() == 'website') {
                                return companyidentificationfields.getText();
                                break;
                            }
                        }
                    }
                }
            }
        }
        return null;
    }

    public static String returnCreditLimitCurrency(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'creditopinion') {
                        for (Dom.XMLNode creditopinionfields : reportfields.getChildElements()) {
                            if (creditopinionfields.getName() == 'creditlimit') {
                                for (Dom.XMLNode creditlimitfields : creditopinionfields.getChildElements()) {
                                    if (creditlimitfields.getName() == 'currency') {
                                        for (Dom.XMLNode currencyfields : creditlimitfields.getChildElements()) {
                                            if (currencyfields.getName() == 'key') {
                                                return currencyfields.getText();
                                                break;
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

    public static String returnCreditDecision(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportfields : field.getChildElements()) {
                    if (reportfields.getName() == 'creditopinion') {
                        for (Dom.XMLNode creditopinionfields : reportfields.getChildElements()) {
                            if (creditopinionfields.getName() == 'typeofcreditopinion') {
                                for (Dom.XMLNode typeofcreditopinionfields : creditopinionfields.getChildElements()) {
                                    if (typeofcreditopinionfields.getName() == 'designation') {
                                        return typeofcreditopinionfields.getText();
                                        break;
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
    *  Name            : returnMailboxEntryNumber(Dom.XMLNode node)
    *  Summary         : return mailbox entry number    
    *  CreatedDate     : 15/12/2017
    *  ModifiedDate    : 15/12/2017
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnMailboxEntryNumber(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'mailboxentrynumber') {
                return field.getText();
            }
        }

        return null;
    }


    /*******************************************************************************
    *  Name            : returnIdentificationNumber(Dom.XMLNode node)
    *  Summary         : return mailbox entry number    
    *  CreatedDate     : 18/12/2017
    *  ModifiedDate    : 18/12/2017
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnIdentificationNumber(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'identificationnumber') {
                return field.getText();
            }
        }

        return null;
    }


    /*******************************************************************************
    *  Name            : returnOrderStatus(Dom.XMLNode node)
    *  Summary         : return status of order    
    *  CreatedDate     : 19/12/2017
    *  ModifiedDate    : 19/12/2017
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnOrderStatus(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'statusoforder') {
                for (Dom.XMLNode statusField : field.getChildElements()) {
                    if (statusField.getName() == 'key') {
                        return statusField.getText();
                    }
                }
            }
        }

        return null;
    }


    /*******************************************************************************
    *  Name            : returnReportStatus(Dom.XMLNode node)
    *  Summary         : return mailbox entry number    
    *  CreatedDate     : 18/12/2017
    *  ModifiedDate    : 18/12/2017
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnReportStatus(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'deliverytype') {
                for (Dom.XMLNode entryField : field.getChildElements()) {
                    if (entryField.getName() == 'key') {
                        return entryField.getText();
                    }
                }
            }
        }

        return null;
    }


    /*******************************************************************************
    *  Name            : returnNegativeReport(Dom.XMLNode node)
    *  Summary         : return mailbox entry number    
    *  CreatedDate     : 18/12/2017
    *  ModifiedDate    : 18/12/2017
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnNegativeReport(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'negativereport') {
                return field.getText();
            }
        }

        return null;
    }


    /*******************************************************************************
    *  Name            : returnReplyInformation(Dom.XMLNode node)
    *  Summary         : return information from order researcher
    *  CreatedDate     : 19/12/2017
    *  ModifiedDate    : 19/12/2017
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : String
    ******************************************************************************/
    public static String returnReplyInformation(Dom.XMLNode node) {
        for (Dom.XMLNode field : node.getChildElements()) {
            if (field.getName() == 'reportdata') {
                for (Dom.XMLNode reportField : field.getChildElements()) {
                    if (reportField.getName() == 'statusreply') {
                        for (Dom.XMLNode statusField : reportField.getChildElements()) {
                            if (statusField.getName() == 'reason') {
                                for (Dom.XMLNode reasonField : statusField.getChildElements()) {
                                    if (reasonField.getName() == 'designation') {
                                        return reasonField.getText();
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return '';
    }


    /*******************************************************************************
    *  Name            : returnGlobalBody(Dom.XMLNode node)
    *  Summary         : Return Body DOM element
    *  CreatedDate     : 1/11/2016
    *  Parameters      : node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static Dom.XMLNode returnGlobalBody(Dom.XMLNode node) {
        for (Dom.XMLNode child : node.getChildElements()) {
            if (child.getName() == 'Body') {
                return child;
                break;
            }
        }
        return null;
    }

    /*******************************************************************************
    *  Name            : returnInnerBody(Dom.XMLNode node)
    *  Summary         : Return Inner Body DOM element
    *  CreatedDate     : 1/11/2016
    *  Parameters      : node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static Dom.XMLNode returnInnerBody(Dom.XMLNode node) {
        for (Dom.XMLNode searchResponse : node.getChildElements()) {
            for (Dom.XMLNode bodyInner : searchResponse.getChildElements()) {
                if (bodyInner.getName() == 'body') {
                    return bodyInner;
                    break;
                }
            }
        }
        return null;
    }

    /*******************************************************************************
    *  Name            : returnErrorMessage(Dom.XMLNode node)
    *  Summary         : Return Error message if inner body of xml is null
    *  CreatedDate     : 1/11/2016
    *  Parameters      : node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static String returnErrorMessage(Dom.XMLNode node) {
        String errorString = '';
        for (Dom.XMLNode searchResponse : node.getChildElements()) {
            if (searchResponse.getName() == 'fault') {
                for (Dom.XMLNode faultField : searchResponse.getChildElements()) {
                    if (faultField.getName() == 'detail') {
                        for (Dom.XMLNode detailField : faultField.getChildElements()) {
                            if (detailField.getName() == 'servicefault') {
                                for (Dom.XMLNode servicefaultField : detailField.getChildElements()) {
                                    if (servicefaultField.getName() == 'body') {
                                        for (Dom.XMLNode bodyFaultField : servicefaultField.getChildElements()) {
                                            if (bodyFaultField.getName() == 'fault') {
                                                for (Dom.XMLNode secondFaultField : bodyFaultField.getChildElements()) {
                                                    if (secondFaultField.getName() == 'errorkey') {
                                                        for (Dom.XMLNode errorkeyField : secondFaultField.getChildElements()) {
                                                            if (errorkeyField.getName() == 'key') {
                                                                errorString = errorString + errorkeyField.getText();
                                                            }

                                                            if (errorkeyField.getName() == 'designation') {
                                                                errorString = errorString + ' ' + errorkeyField.getText();
                                                            }
                                                        }
                                                        return errorString;
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
        }
        return null;    
    } 


    /*******************************************************************************
    *  Name            : returnSearchErrorMessage(Dom.XMLNode node)
    *  Summary         : Return Error message if inner body of xml is null
    *  CreatedDate     : 29/08/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode node - body from response
    *  Returns         : Dom.XMLNode
    ******************************************************************************/
    public static String returnSearchErrorMessage(Dom.XMLNode node) {
        String errorString = '';
        for (Dom.XMLNode searchResponse : node.getChildElements()) {
            if (searchResponse.getName() == 'fault') {
                for (Dom.XMLNode faultField : searchResponse.getChildElements()) {
                    if (faultField.getName() == 'detail') {
                        for (Dom.XMLNode detailField : faultField.getChildElements()) {
                            if (detailField.getName() == 'validationfault') {
                                return detailField.getText();
                            }
                        }
                    }
                }
            }
        }
        return null;    
    } 


    /*******************************************************************************
    *  Name            : clearSearchXML(String xmlString)
    *  Summary         : Remove Content Type from response XML
    *  CreatedDate     : 31/10/2016
    *  Parameters      : xmlString - String from response 
    *  Returns         : String
    ******************************************************************************/
    public static String clearSearchXML(String xmlString) {
        List<String> newString = xmlString.split('\n');
        String finalString = '';
        Boolean isFirstPart = false;
        for (String s : newString) {
            if (s.startsWith('------=_Part') && isFirstPart == false) {
                isFirstPart = true;
                continue;
            }
            if (isFirstPart && s.startsWith('Content-Type:')) {
                continue;
            }
            if (s.startsWith('------=_Part') && isFirstPart) {
                break;
            }
            finalString = finalString + s;
        }
        return finalString;
    }


    /*******************************************************************************
    *  Name            : returnFinancialModule(Dom.XMLNode body)
    *  Summary         : Return Financial Module on Creditreform.
    *  CreatedDate     : 25/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode body - body from report response
    *  Returns         : Financial_Module__c
    ******************************************************************************/
    public static Financial_Module__c returnFinancialModule(Dom.XMLNode body) {
        Financial_Module__c financialModule = new Financial_Module__c();
        String moduleName = returnName(body);
        financialModule.Name__c = moduleName;
        financialModule.Name = moduleName;
        if (moduleName.length() > 80) financialModule.Name = moduleName.substring(0,80);

        return financialModule;
    }


    /*******************************************************************************
    *  Name            : returnFinancialDetails(Dom.XMLNode body)
    *  Summary         : Return Financial Details on Creditreform.    
    *  CreatedDate     : 25/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Dom.XMLNode body - body from report response
    *  Returns         : Map<String, Financial_Detail__c>
    ******************************************************************************/
    public static Map<String, Financial_Detail__c> returnFinancialDetails(Dom.XMLNode body) {
        Map<String, Financial_Detail__c> financialDetailsMap = new Map<String, Financial_Detail__c>();
        for (Dom.XMLNode bodyField : body.getChildElements()) {
            if (bodyField.getName() == 'reportdata') {
                financialDetailsMap = calculateAssetsData(financialDetailsMap, bodyField);
                financialDetailsMap = calculateLiabilitiesData(financialDetailsMap, bodyField);
                eatCalculationMap = new Map<String, Boolean>();
                financialDetailsMap = calculateChaptersData(financialDetailsMap, bodyField);
                financialDetailsMap = calculateItemsData(financialDetailsMap, bodyField);
            }
        }

        return financialDetailsMap;
    }


    /*******************************************************************************
    *  Name            : calculateAssetsData(Map<String, Financial_Detail__c> financialDetailsMap, Dom.XMLNode bodyField)
    *  Summary         : Calculate Financial Detail data based on Creditreform balancesheet assets.     
    *  CreatedDate     : 18/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Map<String, Financial_Detail__c> financialDetailsMap - Financial Details for years Map,
                         Dom.XMLNode bodyField - body from response.
    *  Returns         : Map<String, Financial_Detail__c> 
    ******************************************************************************/
    public static Map<String, Financial_Detail__c> calculateAssetsData(Map<String, Financial_Detail__c> financialDetailsMap, Dom.XMLNode bodyField) {
        for (Dom.XMLNode reportDataField : bodyField.getChildElements()) {
            if (reportDataField.getName() == 'balancesheet') {
                String typeOfBalance;
                for (Dom.XMLNode balanceSheetField : reportDataField.getChildElements()) {
                    if (balanceSheetField.getName() == 'typeofbalance') {
                        for (Dom.XMLNode typeOfBalanceField : balanceSheetField.getChildElements()) {
                            if (typeOfBalanceField.getName() == 'key') {
                                typeOfBalance = typeOfBalanceField.getText();
                            }
                        }
                    } else if (balanceSheetField.getName() == 'balance' && typeOfBalance == 'BATY-1') {
                        String year;
                        for (Dom.XMLNode balanceField : balanceSheetField.getChildElements()) {
                            if (balanceField.getName() == 'reportperiod') {
                                for (Dom.XMLNode reportPeriodField : balanceField.getChildElements()) {
                                    if (reportPeriodField.getName() == 'datestart') {
                                        year = reportPeriodField.getText().substring(0, 4);
                                        if (! financialDetailsMap.containsKey(year)) {
                                            financialDetailsMap.put(year, new Financial_Detail__c());
                                        }
                                    }
                                }
                            } else if (balanceField.getName() == 'assets') {
                                for (Dom.XMLNode assetsField : balanceField.getChildElements()) {
                                    if (assetsField.getName() == 'assets') {
                                        String key;
                                        for (Dom.XMLNode assets2Field : assetsField.getChildElements()) {
                                            if (assets2Field.getName() == 'itemtext') {
                                                for (Dom.XMLNode itemTextField : assets2Field.getChildElements()) {
                                                    if (itemTextField.getName() == 'key') {
                                                        key = itemTextField.getText();
                                                    }
                                                }
                                            } else if (assets2Field.getName() == 'amount') {
                                                financialDetailsMap.get(year).Intangible_Fixed_Assets__c = 
                                                    calculateIntangibleFixedAssets(key, financialDetailsMap.get(year).Intangible_Fixed_Assets__c, Decimal.valueOf(assets2Field.getText()));
                                                financialDetailsMap.get(year).Tangible_Fixed_Assets__c = 
                                                    calculateTangibleFixedAssets(key, financialDetailsMap.get(year).Tangible_Fixed_Assets__c, Decimal.valueOf(assets2Field.getText()));
                                                financialDetailsMap.get(year).Financial_LT_Assets__c = 
                                                    calculateFinancialLTAssets(key, financialDetailsMap.get(year).Financial_LT_Assets__c, Decimal.valueOf(assets2Field.getText()));
                                                financialDetailsMap.get(year).Other_Fixed_assets__c = 
                                                    calculateOtherFixedAssets(key, financialDetailsMap.get(year).Other_Fixed_assets__c, Decimal.valueOf(assets2Field.getText()));
                                                financialDetailsMap.get(year).Stock_material_work__c = 
                                                    calculateStockMaterialWork(key, financialDetailsMap.get(year).Stock_material_work__c, Decimal.valueOf(assets2Field.getText()));
                                                financialDetailsMap.get(year).Trade_debtors__c = 
                                                    calculateTradeDebtors(key, financialDetailsMap.get(year).Trade_debtors__c, Decimal.valueOf(assets2Field.getText()));
                                                financialDetailsMap.get(year).Cash_Cash_equivalent__c = 
                                                    calculateCashCashEquivalent(key, financialDetailsMap.get(year).Cash_Cash_equivalent__c, Decimal.valueOf(assets2Field.getText()));
                                                financialDetailsMap.get(year).Others_Current_Assets__c = 
                                                    calculateOthersCurrentAssets(key, financialDetailsMap.get(year).Others_Current_Assets__c, Decimal.valueOf(assets2Field.getText()));
                                                financialDetailsMap.get(year).Net_worth__c = 
                                                    calculateNetWorth(key, financialDetailsMap.get(year).Net_worth__c, Decimal.valueOf(assets2Field.getText()));
                                                financialDetailsMap.get(year).Reserves__c = 
                                                    calculateReserves(key, financialDetailsMap.get(year).Reserves__c, Decimal.valueOf(assets2Field.getText()));
                                                financialDetailsMap.get(year).From_that_LT_bank_debt__c = 
                                                    calculateFromThatLTBankDebt(key, financialDetailsMap.get(year).From_that_LT_bank_debt__c, Decimal.valueOf(assets2Field.getText()));
                                                financialDetailsMap.get(year).From_that_other_LT_liabilities__c = 
                                                    calculateFromThatOtherLTLiabilities(key, financialDetailsMap.get(year).From_that_other_LT_liabilities__c, Decimal.valueOf(assets2Field.getText()));
                                                financialDetailsMap.get(year).Leasing_Engagement__c = 
                                                    calculateleasingEngagement(key, financialDetailsMap.get(year).Leasing_Engagement__c, Decimal.valueOf(assets2Field.getText()));
                                                financialDetailsMap.get(year).From_that_Trade_Creditors__c = 
                                                    calculateFromThatTradeCreditors(key, financialDetailsMap.get(year).From_that_Trade_Creditors__c, Decimal.valueOf(assets2Field.getText()));
                                                financialDetailsMap.get(year).From_that_ST_bank_debt__c = 
                                                    calculateFromThatSTBankDebt(key, financialDetailsMap.get(year).From_that_ST_bank_debt__c, Decimal.valueOf(assets2Field.getText()));
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

        return financialDetailsMap;
    }


    /*******************************************************************************
    *  Name            : calculateLiabilitiesData(Map<String, Financial_Detail__c> financialDetailsMap, Dom.XMLNode bodyField)
    *  Summary         : Calculate Financial Detail data based on Creditreform balancesheet liabilities.     
    *  CreatedDate     : 19/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Map<String, Financial_Detail__c> financialDetailsMap - Financial Details for years Map,
                         Dom.XMLNode bodyField - body from response.
    *  Returns         : Map<String, Financial_Detail__c> 
    ******************************************************************************/
    public static Map<String, Financial_Detail__c> calculateLiabilitiesData(Map<String, Financial_Detail__c> financialDetailsMap, Dom.XMLNode bodyField) {
        for (Dom.XMLNode reportDataField : bodyField.getChildElements()) {
            if (reportDataField.getName() == 'balancesheet') {
                String typeOfBalance;
                for (Dom.XMLNode balanceSheetField : reportDataField.getChildElements()) {
                    if (balanceSheetField.getName() == 'typeofbalance') {
                        for (Dom.XMLNode typeOfBalanceField : balanceSheetField.getChildElements()) {
                            if (typeOfBalanceField.getName() == 'key') {
                                typeOfBalance = typeOfBalanceField.getText();
                            }
                        }
                    } else if (balanceSheetField.getName() == 'balance' && typeOfBalance == 'BATY-1') {
                        String year;
                        for (Dom.XMLNode balanceField : balanceSheetField.getChildElements()) {
                            if (balanceField.getName() == 'reportperiod') {
                                for (Dom.XMLNode reportPeriodField : balanceField.getChildElements()) {
                                    if (reportPeriodField.getName() == 'datestart') {
                                        year = reportPeriodField.getText().substring(0, 4);
                                        if (! financialDetailsMap.containsKey(year)) {
                                            financialDetailsMap.put(year, new Financial_Detail__c());
                                        }
                                    }
                                }
                            } else if (balanceField.getName() == 'liabilities') {
                                for (Dom.XMLNode liabilitiesField : balanceField.getChildElements()) {
                                    if (liabilitiesField.getName() == 'liabilities') {
                                        String key;
                                        for (Dom.XMLNode liabilities2Field : liabilitiesField.getChildElements()) {
                                            if (liabilities2Field.getName() == 'itemtext') {
                                                for (Dom.XMLNode itemTextField : liabilities2Field.getChildElements()) {
                                                    if (itemTextField.getName() == 'key') {
                                                        key = itemTextField.getText();
                                                        
                                                    }
                                                }
                                            } else if (liabilities2Field.getName() == 'amount') {
                                                financialDetailsMap.get(year).Intangible_Fixed_Assets__c = 
                                                    calculateIntangibleFixedAssets(key, financialDetailsMap.get(year).Intangible_Fixed_Assets__c, Decimal.valueOf(liabilities2Field.getText()));
                                                financialDetailsMap.get(year).Tangible_Fixed_Assets__c = 
                                                    calculateTangibleFixedAssets(key, financialDetailsMap.get(year).Tangible_Fixed_Assets__c, Decimal.valueOf(liabilities2Field.getText()));
                                                financialDetailsMap.get(year).Financial_LT_Assets__c = 
                                                    calculateFinancialLTAssets(key, financialDetailsMap.get(year).Financial_LT_Assets__c, Decimal.valueOf(liabilities2Field.getText()));
                                                financialDetailsMap.get(year).Other_Fixed_assets__c = 
                                                    calculateOtherFixedAssets(key, financialDetailsMap.get(year).Other_Fixed_assets__c, Decimal.valueOf(liabilities2Field.getText()));
                                                financialDetailsMap.get(year).Stock_material_work__c = 
                                                    calculateStockMaterialWork(key, financialDetailsMap.get(year).Stock_material_work__c, Decimal.valueOf(liabilities2Field.getText()));
                                                financialDetailsMap.get(year).Trade_debtors__c = 
                                                    calculateTradeDebtors(key, financialDetailsMap.get(year).Trade_debtors__c, Decimal.valueOf(liabilities2Field.getText()));
                                                financialDetailsMap.get(year).Cash_Cash_equivalent__c = 
                                                    calculateCashCashEquivalent(key, financialDetailsMap.get(year).Cash_Cash_equivalent__c, Decimal.valueOf(liabilities2Field.getText()));
                                                financialDetailsMap.get(year).Others_Current_Assets__c = 
                                                    calculateOthersCurrentAssets(key, financialDetailsMap.get(year).Others_Current_Assets__c, Decimal.valueOf(liabilities2Field.getText()));
                                                financialDetailsMap.get(year).Net_worth__c = 
                                                    calculateNetWorth(key, financialDetailsMap.get(year).Net_worth__c, Decimal.valueOf(liabilities2Field.getText()));
                                                financialDetailsMap.get(year).Reserves__c = 
                                                    calculateReserves(key, financialDetailsMap.get(year).Reserves__c, Decimal.valueOf(liabilities2Field.getText()));
                                                financialDetailsMap.get(year).From_that_LT_bank_debt__c = 
                                                    calculateFromThatLTBankDebt(key, financialDetailsMap.get(year).From_that_LT_bank_debt__c, Decimal.valueOf(liabilities2Field.getText()));
                                                financialDetailsMap.get(year).From_that_other_LT_liabilities__c = 
                                                    calculateFromThatOtherLTLiabilities(key, financialDetailsMap.get(year).From_that_other_LT_liabilities__c, Decimal.valueOf(liabilities2Field.getText()));
                                                financialDetailsMap.get(year).Leasing_Engagement__c = 
                                                    calculateLeasingEngagement(key, financialDetailsMap.get(year).Leasing_Engagement__c, Decimal.valueOf(liabilities2Field.getText()));
                                                financialDetailsMap.get(year).From_that_Trade_Creditors__c = 
                                                    calculateFromThatTradeCreditors(key, financialDetailsMap.get(year).From_that_Trade_Creditors__c, Decimal.valueOf(liabilities2Field.getText()));
                                                financialDetailsMap.get(year).From_that_ST_bank_debt__c = 
                                                    calculateFromThatSTBankDebt(key, financialDetailsMap.get(year).From_that_ST_bank_debt__c, Decimal.valueOf(liabilities2Field.getText()));
                                                financialDetailsMap.get(year).From_that_other_ST_liabilities__c = 
                                                    calculateFromThatOtherSTLiabilities(key, financialDetailsMap.get(year).From_that_other_ST_liabilities__c, Decimal.valueOf(liabilities2Field.getText()));
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

        return financialDetailsMap;
    }


    /*******************************************************************************
    *  Name            : calculateIntangibleFixedAssets(String key, Decimal intangibleFixedAssets, Decimal amount)
    *  Summary         : Calculate Intangible Fixed Assets based on Creditreform Assets or Liabilities. 
    *  CreatedDate     : 18/09/2018
    *  ModifiedDate    : -
    *  Parameters      : String key - item key, Decimal intangibleFixedAssets - Intangible Fixed Assets,
                         Decimal amount - amount of current item
    *  Returns         : Decimal
    ******************************************************************************/
    public static Decimal calculateIntangibleFixedAssets(String key, Decimal intangibleFixedAssets, Decimal amount) {
        /* BAIT-101 - Start-up and business expansion expenses; BAIT-120 - Intangible assets; BAIT-121 - Concessions and industrial rights; 
            BAIT-122 - Goodwill; BAIT-123 - Down payment made; BAIT-150 - Start-up costs; BAIT-100110 - intangible assets; 
            BAIT-100111 - concessions, industrial rights */
        if (key.equals('BAIT-101') || key.equals('BAIT-120') || key.equals('BAIT-121') || key.equals('BAIT-122') || 
                key.equals('BAIT-123') || key.equals('BAIT-150') || key.equals('BAIT-100110') || key.equals('BAIT-100111')) {
            if (intangibleFixedAssets != null) {
                intangibleFixedAssets += amount / 1000;
            } else {
                intangibleFixedAssets = amount / 1000;
            }
        }

        return intangibleFixedAssets;
    }


    /*******************************************************************************
    *  Name            : calculateTangibleFixedAssets(String key, Decimal tangibleFixedAssets, Decimal amount)
    *  Summary         : Calculate Tangible Fixed Assets based on Creditreform Assets or Liabilities. 
    *  CreatedDate     : 18/09/2018
    *  ModifiedDate    : -
    *  Parameters      : String key - item key, Decimal tangibleFixedAssets - Tangible Fixed Assets,
                         Decimal amount - amount of current item
    *  Returns         : Decimal
    ******************************************************************************/
    public static Decimal calculateTangibleFixedAssets(String key, Decimal tangibleFixedAssets, Decimal amount) {
        /* BAIT-130 - Tangible assets; BAIT-131 - Land and buildings; BAIT-132 - Technical equipment and machines;
            BAIT-134 - Factory and office equipment; BAIT-135 - Down payments made, plant under construction;
            BAIT-100120 - tangible assets; BAIT-100121 - land and buildings; BAIT-100122 - fixtures + fittings */
        if (key.equals('BAIT-130') || key.equals('BAIT-131') || key.equals('BAIT-132') || key.equals('BAIT-134') || 
                key.equals('BAIT-135') || key.equals('BAIT-100120') || key.equals('BAIT-100121') || key.equals('BAIT-100122')) {
            if (tangibleFixedAssets != null) {
                tangibleFixedAssets += amount / 1000;
            } else {
                tangibleFixedAssets = amount / 1000;
            }
        } 

        return tangibleFixedAssets;
    }


    /*******************************************************************************
    *  Name            : calculateFinancialLTAssets(String key, Decimal financialLTAssets, Decimal amount)
    *  Summary         : Calculate Financial LT Assets based on Creditreform Assets or Liabilities. 
    *  CreatedDate     : 18/09/2018
    *  ModifiedDate    : -
    *  Parameters      : String key - item key, Decimal financialLTAssets - Financial LT Assets,
                         Decimal amount - amount of current item
    *  Returns         : Decimal
    ******************************************************************************/
    public static Decimal calculateFinancialLTAssets(String key, Decimal financialLTAssets, Decimal amount) {
        /* BAIT-140 - Financial assets; BAIT-141 - Securities and loans; BAIT-142 - Shares in affiliated companies;
            BAIT-143 - Loans to affiliated companies; BAIT-144 - Participations; BAIT-145 - Loans to companies in which a participaton is held;
            BAIT-146 - Securities of fixed assets; BAIT-147 - Other loans; BAIT-100130 - financial assets; BAIT-100131 - loans, shares + participations;
            BAIT-100132 - investment securities */
        if (key.equals('BAIT-140') || key.equals('BAIT-141') || key.equals('BAIT-142') || key.equals('BAIT-143') || 
                key.equals('BAIT-144') || key.equals('BAIT-145') || key.equals('BAIT-146') || key.equals('BAIT-147') || 
                key.equals('BAIT-100130') || key.equals('BAIT-100131') || key.equals('BAIT-100132')) {
            if (financialLTAssets != null) {
                financialLTAssets += amount / 1000;
            } else {
                financialLTAssets = amount / 1000;
            }
        }

        return financialLTAssets;
    }


    /*******************************************************************************
    *  Name            : calculateOtherFixedAssets(String key, Decimal otherFixedAssets, Decimal amount)
    *  Summary         : Calculate Other Fixed Assets based on Creditreform Assets or Liabilities. 
    *  CreatedDate     : 17/12/2018
    *  ModifiedDate    : -
    *  Parameters      : String key - item key, Decimal otherFixedAssets - Other Fixed Assets,
                         Decimal amount - amount of current item
    *  Returns         : Decimal
    ******************************************************************************/
    public static Decimal calculateOtherFixedAssets(String key, Decimal otherFixedAssets, Decimal amount) {
        /* BAIT-139 - Tangible assets, intangible assets; BAIT-290 - Other fixed assets; BAIT-110 - Fixed assets;
            BAIT-100100 - fixed assets */
        if (key.equals('BAIT-139') || key.equals('BAIT-290') || key.equals('BAIT-110') || key.equals('BAIT-100100')) {
            if (otherFixedAssets != null) {
                otherFixedAssets += amount / 1000;
            } else {
                otherFixedAssets = amount / 1000;
            }
        }

        return otherFixedAssets;
    }


    /*******************************************************************************
    *  Name            : calculateStockMaterialWork(String key, Decimal stockMaterialWork, Decimal amount)
    *  Summary         : Calculate Stock Material Work based on Creditreform Assets or Liabilities. 
    *  CreatedDate     : 18/09/2018
    *  ModifiedDate    : -
    *  Parameters      : String key - item key, Decimal stockMaterialWork - Stock Material Work,
                         Decimal amount - amount of current item
    *  Returns         : Decimal
    ******************************************************************************/
    public static Decimal calculateStockMaterialWork(String key, Decimal stockMaterialWork, Decimal amount) {
        /* BAIT-310 - Stocks; BAIT-311 - Raw materials and supplies; BAIT-312 - Unfinished goods and work in progress;
            BAIT-313 - Finished goods; BAIT-100210 - inventories and work in progress */
        if (key.equals('BAIT-310') || key.equals('BAIT-311') || key.equals('BAIT-312') || key.equals('BAIT-313') || 
                key.equals('BAIT-100210')) {
            if (stockMaterialWork != null) {
                stockMaterialWork += amount / 1000;
            } else {
                stockMaterialWork = amount / 1000;
            }
        }

        return stockMaterialWork;
    }


    /*******************************************************************************
    *  Name            : calculateTradeDebtors(String key, Decimal tradeDebtors, Decimal amount)
    *  Summary         : Calculate Trade Debtors based on Creditreform Assets or Liabilities. 
    *  CreatedDate     : 18/09/2018
    *  ModifiedDate    : -
    *  Parameters      : String key - item key, Decimal tradeDebtors - Trade Debtors,
                         Decimal amount - amount of current item
    *  Returns         : Decimal
    ******************************************************************************/
    public static Decimal calculateTradeDebtors(String key, Decimal tradeDebtors, Decimal amount) {
        /* BAIT-315 - Down payments made; BAIT-320 - Receivables and other assets; BAIT-321 - Accounts receivable;
            BAIT-100220 - accounts receivablee */
        if (key.equals('BAIT-315') || key.equals('BAIT-320') || key.equals('BAIT-321') || key.equals('BAIT-100220')) {
            if (tradeDebtors != null) {
                tradeDebtors += amount / 1000;
            } else {
                tradeDebtors = amount / 1000;
            }
        }

        return tradeDebtors;
    }


    /*******************************************************************************
    *  Name            : calculateCashCashEquivalent(String key, Decimal cashCashEquivalent, Decimal amount)
    *  Summary         : Calculate Cash Cash Equivalent based on Creditreform Assets or Liabilities. 
    *  CreatedDate     : 18/09/2018
    *  ModifiedDate    : -
    *  Parameters      : String key - item key, Decimal cashCashEquivalent - Cash Cash Equivalent,
                         Decimal amount - amount of current item
    *  Returns         : Decimal
    ******************************************************************************/
    public static Decimal calculateCashCashEquivalent(String key, Decimal cashCashEquivalent, Decimal amount) {
        /* BAIT-340 - Cheque, cash in hand and in banks; BAIT-349 - Notes receivable; BAIT-100240 - securities; 
            BAIT-100250 -liquid assets*/
        if (key.equals('BAIT-340') || key.equals('BAIT-349') || key.equals('BAIT-100240') || key.equals('BAIT-100250')) {
            if (cashCashEquivalent != null) {
                cashCashEquivalent += amount / 1000;
            } else {
                cashCashEquivalent = amount / 1000;
            }
        }

        return cashCashEquivalent;
    }


    /*******************************************************************************
    *  Name            : calculateOthersCurrentAssets(String key, Decimal othersCurrentAssets, Decimal amount)
    *  Summary         : Calculate Others Current Assets based on Creditreform Assets or Liabilities. 
    *  CreatedDate     : 18/09/2018
    *  ModifiedDate    : -
    *  Parameters      : String key - item key, Decimal othersCurrentAssets - Others Current Assets,
                         Decimal amount - amount of current item
    *  Returns         : Decimal
    ******************************************************************************/
    public static Decimal calculateOthersCurrentAssets(String key, Decimal othersCurrentAssets, Decimal amount) {
        /* BAIT-322 - Receivables from affiliates; BAIT-323 - Receivables from companies in which a participation is held;
            BAIT-324 - Other assets; BAIT-325 - Receivables from shareholders; BAIT-328 - Other short-term receivables;
            BAIT-329 - Other receivables; BAIT-330 - Securities; BAIT-331 - Part of shares in affiliates;
            BAIT-332 - Own shares; BAIT-333 - Other securities; BAIT-350 - Other current assets; BAIT-449 - Other assets;
            BAIT-480 - Deferred items - assets -; BAIT-100230 - receiv.f.affiliates/participati.; BAIT-100300 - deferred items assets;
            BAIT-300 - Current assets; BAIT-100200 - current assets */
        if (key.equals('BAIT-322') || key.equals('BAIT-323') || key.equals('BAIT-324') || key.equals('BAIT-325') || 
                key.equals('BAIT-328') || key.equals('BAIT-329') || key.equals('BAIT-330') || key.equals('BAIT-331') || 
                key.equals('BAIT-332') || key.equals('BAIT-333') || key.equals('BAIT-350') || key.equals('BAIT-449') || 
                key.equals('BAIT-480') || key.equals('BAIT-100230') || key.equals('BAIT-100300') || key.equals('BAIT-300') ||
                key.equals('BAIT-100200')) {
            if (othersCurrentAssets != null) {
                othersCurrentAssets += amount / 1000;
            } else {
                othersCurrentAssets = amount / 1000;
            }
        }

        return othersCurrentAssets;
    }


    /*******************************************************************************
    *  Name            : calculateNetWorth(String key, Decimal netWorth, Decimal amount)
    *  Summary         : Calculate Net Worth based on Creditreform Assets or Liabilities. 
    *  CreatedDate     : 18/09/2018
    *  ModifiedDate    : -
    *  Parameters      : String key - item key, Decimal netWorth - Net Worth,
                         Decimal amount - amount of current item
    *  Returns         : Decimal
    ******************************************************************************/
    public static Decimal calculateNetWorth(String key, Decimal netWorth, Decimal amount) {
        /* BAIT-500 - Shareholders' funds; BAIT-501 - Shareholders' funds (nominal); BAIT-505 - Credit balance;
            BAIT-510 - Subscribed capital, credit balance, capital accounts; BAIT-520 - Capital reserves;
            BAIT-530 - Profit reserves; BAIT-531 - Legal reserves; BAIT-532 - Reserves for own shares;
            BAIT-533 - Statutory reserves; BAIT-534 - Other profit reserves; BAIT-535 - Special reserves;
            BAIT-550 - Reserves; BAIT-559 - Other reserves; BAIT-560 - Profit carried forward; BAIT-580 - Net profit;
            BAIT-593 - Shareholders' loan of equity nature; BAIT-595 - Balance sheet profit; BAIT-890 - Balance sheet profit;
            BAIT-891 - Profit carried forward; BAIT-100600 - shareholders' funds; BAIT-100610 - subscribed capital/share capital;
            BAIT-100620 - capital reserves/capital surplus; BAIT-100621 - Capital reserve; BAIT-100622 - Share premium account;
            BAIT-100630 - profit reserves; BAIT-100631 - statutory reserves; BAIT-100632 - legal reserves;
            BAIT-100640 - revaluation reserves; BAIT-100650 - minority interests; BAIT-100660 - profit/loss carried forward;
            BAIT-100670 - profit/loss carr.forw. prev.year; BAIT-100680 - annual profit or loss; BAIT-100690 - balance sheet profit/loss;
            BAIT-100700 - subordinate loan; BAIT-190001 - capital; BAIT-190002 - Subscribed capital; BAIT-190003 - paid-up capital;
            BAIT-190004 - nominal capital; BAIT-198001 - capital; BAIT-198002 - legal reserves; BAIT-198003 - free reserves;
            BAIT-100 - Subscribed but unpaid capital; BAIT-490 - Balance sheet loss; BAIT-491 - Loss carried forward;
            BAIT-493 - Share of loss not covered by asset deposit; BAIT-494 - Deficit not covered by shareholders'  funds;
            BAIT-570 - Loss carried forward; Net loss; BAIT-590 - Net loss; BAIT-594 - Balance sheet loss;
            BAIT-597 - Deficit not covered by equity by shareholders' funds; BAIT-100050 - outstanding deposit on subscrib.capital, thereof called;
            BAIT-100350 - deficit not cover.b.shareh.funds; BAIT-100825 - Uncalled capital */
        if (key.equals('BAIT-500') || key.equals('BAIT-501') || key.equals('BAIT-505') || key.equals('BAIT-510') || 
                key.equals('BAIT-520') || key.equals('BAIT-530') || key.equals('BAIT-531') || key.equals('BAIT-532') || 
                key.equals('BAIT-533') || key.equals('BAIT-534') || key.equals('BAIT-535') || key.equals('BAIT-550') ||
                key.equals('BAIT-559') || key.equals('BAIT-560') || key.equals('BAIT-580') || key.equals('BAIT-593') ||
                key.equals('BAIT-595') || key.equals('BAIT-890') || key.equals('BAIT-891') || key.equals('BAIT-100600') || 
                key.equals('BAIT-100610') || key.equals('BAIT-100620') || key.equals('BAIT-100621') || key.equals('BAIT-100622') || 
                key.equals('BAIT-100630') || key.equals('BAIT-100631') || key.equals('BAIT-100632') || key.equals('BAIT-100640') || 
                key.equals('BAIT-100650') || key.equals('BAIT-100660') || key.equals('BAIT-100670') || key.equals('BAIT-100680') ||
                key.equals('BAIT-100690') || key.equals('BAIT-100700') || key.equals('BAIT-190001') || key.equals('BAIT-190002') ||
                key.equals('BAIT-190003') || key.equals('BAIT-190004') || key.equals('BAIT-198001') || key.equals('BAIT-198002') || 
                key.equals('BAIT-198003')) {
            if (netWorth != null) {
                netWorth += amount / 1000;
            } else {
                netWorth = amount / 1000;
            }
        } else if (key.equals('BAIT-100') || key.equals('BAIT-490') || key.equals('BAIT-491') || key.equals('BAIT-493') || 
                key.equals('BAIT-494') || key.equals('BAIT-570') || key.equals('BAIT-590') || key.equals('BAIT-594') || 
                key.equals('BAIT-597') || key.equals('BAIT-100050') || key.equals('BAIT-100350') || 
                key.equals('BAIT-100825')) {
            if (amount < 0) {
                amount = amount * (-1);
            }
            
            if (netWorth != null) {
                netWorth -= amount / 1000;
            } else {
                netWorth = -amount / 1000;
            }
        }

        return netWorth;
    }


    /*******************************************************************************
    *  Name            : calculateReserves(String key, Decimal reserves, Decimal amount)
    *  Summary         : Calculate Reserves based on Creditreform Assets or Liabilities. 
    *  CreatedDate     : 18/09/2018
    *  ModifiedDate    : -
    *  Parameters      : String key - item key, Decimal reserves - Reserves,
                         Decimal amount - amount of current item
    *  Returns         : Decimal
    ******************************************************************************/
    public static Decimal calculateReserves(String key, Decimal reserves, Decimal amount) {
        /* BAIT-599 - Special reserves; BAIT-600 - Provisions; BAIT-610 - General provisions;
            BAIT-611 - Pension provision; BAIT-612 - Tax provisions; BAIT-613 - Other provisions;
            BAIT-100750 - provisions */
        if (key.equals('BAIT-599') || key.equals('BAIT-600') || key.equals('BAIT-610') || key.equals('BAIT-611') || 
                key.equals('BAIT-612') || key.equals('BAIT-613') || key.equals('BAIT-100750')) {
            if (reserves != null) {
                reserves += amount / 1000;
            } else {
                reserves = amount / 1000;
            }
        }

        return reserves;
    }


    /*******************************************************************************
    *  Name            : calculateFromThatLTBankDebt(String key, Decimal fromThatLTBankDebt, Decimal amount)
    *  Summary         : Calculate Liabilities From That LT Bank Debt based on Creditreform Assets or Liabilities. 
    *  CreatedDate     : 18/09/2018
    *  ModifiedDate    : -
    *  Parameters      : String key - item key, Decimal fromThatLTBankDebt - Liabilities From That LT Bank Debt,
                         Decimal amount - amount of current item
    *  Returns         : Decimal
    ******************************************************************************/
    public static Decimal calculateFromThatLTBankDebt(String key, Decimal fromThatLTBankDebt, Decimal amount) {
        /* BAIT-701 - Borrowings; BAIT-100811 - bonds (loans, mortgages); BAIT-100812 - long-term debts towards bankers */
        if (key.equals('BAIT-701') || key.equals('BAIT-100811') || key.equals('BAIT-100812')) {
            if (fromThatLTBankDebt != null) {
                fromThatLTBankDebt += amount / 1000;
            } else {
                fromThatLTBankDebt = amount / 1000;
            }
        }

        return fromThatLTBankDebt;
    }


    /*******************************************************************************
    *  Name            : calculateFromThatOtherLTLiabilities(String key, Decimal fromThatLTBankDebt, Decimal amount)
    *  Summary         : Calculate Other LT Liabilities based on Creditreform Assets or Liabilities. 
    *  CreatedDate     : 06/12/2018
    *  ModifiedDate    : -
    *  Parameters      : String key - item key, Decimal fromThatOtherLTLiabilities - Other LT Liabilities,
                         Decimal amount - amount of current item
    *  Returns         : Decimal
    ******************************************************************************/
    public static Decimal calculateFromThatOtherLTLiabilities(String key, Decimal fromThatOtherLTLiabilities, Decimal amount) {
        /* BAIT-711 - Long-term liabilities; BAIT-712 - Liabilities over 1 year; BAIT-718 - Liabilities towards shareholders; 
            BAIT-820 - Borrowed capital; BAIT-825 - Medium- and long-term borrowed capital; BAIT-829 - Other borrowed capital; 
            BAIT-100810 - long-term liabilities; BAIT-100813 - liab.to.affiliates/participations; BAIT-100814 - Other long-term liabilities */
        if (key.equals('BAIT-711') || key.equals('BAIT-712') || key.equals('BAIT-718') || key.equals('BAIT-820') || 
                key.equals('BAIT-825') || key.equals('BAIT-829') || key.equals('BAIT-100810') || key.equals('BAIT-100813') || 
                key.equals('BAIT-100814')) {
            if (fromThatOtherLTLiabilities != null) {
                fromThatOtherLTLiabilities += amount / 1000;
            } else {
                fromThatOtherLTLiabilities = amount / 1000;
            }
        }

        return fromThatOtherLTLiabilities;
    }


     /*******************************************************************************
    *  Name            : calculateLeasingEngagement(String key, Decimal leasingEngagement, Decimal amount)
    *  Summary         : Calculate Liabilities From That LT Bank Debt based on Creditreform Assets or Liabilities. 
    *  CreatedDate     : 14/12/2018
    *  ModifiedDate    : -
    *  Parameters      : String key - item key, Decimal leasingEngagement - Leasing Engagements,
                         Decimal amount - amount of current item
    *  Returns         : Decimal
    ******************************************************************************/
    public static Decimal calculateLeasingEngagement(String key, Decimal leasingEngagement, Decimal amount) {
        /* BAIT-850 - Leasing engagements */
        if (key.equals('BAIT-850')) {
            if (leasingEngagement != null) {
                leasingEngagement += amount / 1000;
            } else {
                leasingEngagement = amount / 1000;
            }
        }

        return leasingEngagement;
    }


    /*******************************************************************************
    *  Name            : calculateFromThatTradeCreditors(String key, Decimal fromThatTradeCreditors, Decimal amount)
    *  Summary         : Calculate Liabilities From That Trade Creditors based on Creditreform Assets or Liabilities. 
    *  CreatedDate     : 18/09/2018
    *  ModifiedDate    : -
    *  Parameters      : String key - item key, Decimal fromThatTradeCreditors - Liabilities From That Trade Creditors,
                         Decimal amount - amount of current item
    *  Returns         : Decimal
    ******************************************************************************/
    public static Decimal calculateFromThatTradeCreditors(String key, Decimal fromThatTradeCreditors, Decimal amount) {
        /* BAIT-704 - Down payment received; BAIT-705 - Accounts payable; BAIT-706 - Notes payable; BAIT-710 - Accounts payable of a normal scope;
            BAIT-713 - Accounts payable; BAIT-100821 - accounts payable */
        if (key.equals('BAIT-704') || key.equals('BAIT-705') || key.equals('BAIT-706') || key.equals('BAIT-710') || 
                key.equals('BAIT-713') || key.equals('BAIT-100821')) {
            if (fromThatTradeCreditors != null) {
                fromThatTradeCreditors += amount / 1000;
            } else {
                fromThatTradeCreditors = amount / 1000;
            }
        }

        return fromThatTradeCreditors;
    }


    /*******************************************************************************
    *  Name            : calculateFromThatSTBankDebt(String key, Decimal fromThatSTBankDebt, Decimal amount)
    *  Summary         : Calculate Liabilities From That ST Bank Debt based on Creditreform Assets or Liabilities. 
    *  CreatedDate     : 19/09/2018
    *  ModifiedDate    : -
    *  Parameters      : String key - item key, Decimal fromThatSTBankDebt - Liabilities From That ST Bank Debt,
                         Decimal amount - amount of current item
    *  Returns         : Decimal
    ******************************************************************************/
    public static Decimal calculateFromThatSTBankDebt(String key, Decimal fromThatSTBankDebt, Decimal amount) {
        /* BAIT-702 - Liabilities towards credit institutes; BAIT-703 - Credit line; BAIT-100822 - liabilities to banks */
        if (key.equals('BAIT-702') || key.equals('BAIT-703') || key.equals('BAIT-100822')) {
            if (fromThatSTBankDebt != null) {
                fromThatSTBankDebt += amount / 1000;
            } else {
                fromThatSTBankDebt = amount / 1000;
            }
        }

        return fromThatSTBankDebt;
    }

    /*******************************************************************************
    *  Name            : calculateFromThatOtherSTLiabilities(String key, Decimal fromThatOtherLTLiabilities, Decimal amount)
    *  Summary         : Calculate Other ST Liabilities based on Creditreform Assets or Liabilities. 
    *  CreatedDate     : 17/12/2018
    *  ModifiedDate    : -
    *  Parameters      : String key - item key, Decimal fromThatOtherLTLiabilities - Other ST Liabilities,
                         Decimal amount - amount of current item
    *  Returns         : Decimal
    ******************************************************************************/
    public static Decimal calculateFromThatOtherSTLiabilities(String key, Decimal fromThatOtherLTLiabilities, Decimal amount) {
        /* BAIT-100900 - deferred items - liabilities; BAIT-849 - Miscellaneous items; BAIT-880 - Deferred items - liabilities -; 
            BAIT-707 - Liabilities towards affiliates; BAIT-708 - Liabilities towards participations; BAIT-709 - Miscellaneous items; 
            BAIT-716 - Other short-term liabilities; BAIT-717 - Liabilities under 1 year; BAIT-720 - Tax-VAT-liabilities; 
            BAIT-730 - Taxes and social security contributions; BAIT-740 - Salaries, social contributions and taxes; BAIT-823 - Short-term borrowed capital; 
            BAIT-100820 - short-term liabilities; BAIT-100823 - curr.liab.to affiliates/particip.; BAIT-100824 - liab.f.income tax/social contrib.; 
            BAIT-100826 - Other current liabilities; BAIT-700 - Liabilities; BAIT-100800 - liabilities */
        if (key.equals('BAIT-100900') || key.equals('BAIT-849') || key.equals('BAIT-880') || key.equals('BAIT-707') || 
                key.equals('BAIT-708') || key.equals('BAIT-709') || key.equals('BAIT-716') || key.equals('BAIT-717') || 
                key.equals('BAIT-720') || key.equals('BAIT-730') || key.equals('BAIT-740') || key.equals('BAIT-823') || 
                key.equals('BAIT-100820') || key.equals('BAIT-100823') || key.equals('BAIT-100824') || key.equals('BAIT-100826') ||
                key.equals('BAIT-700') || key.equals('BAIT-100800')) {
            if (fromThatOtherLTLiabilities != null) {
                fromThatOtherLTLiabilities += amount / 1000;
            } else {
                fromThatOtherLTLiabilities = amount / 1000;
            }
        }

        return fromThatOtherLTLiabilities;
    }


    /*******************************************************************************
    *  Name            : calculateChaptersData(Map<String, Financial_Detail__c> financialDetailsMap)
    *  Summary         : Calculate Financial Detail data based on Creditreform profilossessheet chapters.     
    *  CreatedDate     : 19/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Map<String, Financial_Detail__c> financialDetailsMap - Financial Details for years Map,
                         Dom.XMLNode bodyField - body from response.
    *  Returns         : Map<String, Financial_Detail__c> 
    ******************************************************************************/
    public static Map<String, Financial_Detail__c> calculateChaptersData(Map<String, Financial_Detail__c> financialDetailsMap, Dom.XMLNode bodyField) {
        for (Dom.XMLNode reportDataField : bodyField.getChildElements()) {
            if (reportDataField.getName() == 'profitslosses') {
                for (Dom.XMLNode profitsLossesField : reportDataField.getChildElements()) {
                    if (profitsLossesField.getName() == 'profitslossessheet') {
                        String year;
                        String typeOfBalance;
                        for (Dom.XMLNode profitsLossesSheetField : profitsLossesField.getChildElements()) {
                            if (profitsLossesSheetField.getName() == 'reportperiod') {
                                for (Dom.XMLNode reportPeriodField : profitsLossesSheetField.getChildElements()) {
                                    if (reportPeriodField.getName() == 'datestart') {
                                        year = reportPeriodField.getText().substring(0, 4);
                                        
                                    }
                                }
                            } else if (profitsLossesSheetField.getName() == 'typeofbalance') {
                                for (Dom.XMLNode typeOfBalanceField : profitsLossesSheetField.getChildElements()) {
                                    if (typeOfBalanceField.getName() == 'key') {
                                        typeOfBalance = typeOfBalanceField.getText();
                                        if (typeofbalance == 'BATY-1') {
                                            if (! financialDetailsMap.containsKey(year)) {
                                                financialDetailsMap.put(year, new Financial_Detail__c());
                                            }
                                            if (! eatCalculationMap.containsKey(year)) {
                                                eatCalculationMap.put(year, false);
                                            }
                                        }
                                    }
                                }
                            } else if (profitsLossesSheetField.getName() == 'chapter' && typeofbalance == 'BATY-1') {
                                String key;
                                for (Dom.XMLNode chapterField : profitsLossesSheetField.getChildElements()) {
                                    if (chapterField.getName() == 'chaptername') {
                                        for (Dom.XMLNode chapternameField : chapterField.getChildElements()) {
                                            if (chapternameField.getName() == 'key') {
                                                key = chapternameField.getText();
                                            }
                                        }
                                    } else if (chapterField.getName() == 'amount') {
                                        financialDetailsMap.get(year).Turnover__c = 
                                            calculateTurnover(key, financialDetailsMap.get(year).Turnover__c, Decimal.valueOf(chapterField.getText()));
                                        financialDetailsMap.get(year).Activation__c = 
                                            calculateActivation(key, financialDetailsMap.get(year).Activation__c, Decimal.valueOf(chapterField.getText()));
                                        financialDetailsMap.get(year).Other_operational_income__c = 
                                            calculateOtherOperationalIncome(key, financialDetailsMap.get(year).Other_operational_income__c, Decimal.valueOf(chapterField.getText()));
                                        financialDetailsMap.get(year).Cost_of_goods_sold__c = 
                                            calculateCostOfGoodsSold(key, financialDetailsMap.get(year).Cost_of_goods_sold__c, Decimal.valueOf(chapterField.getText()));
                                        financialDetailsMap.get(year).Gross_profit_loss__c =
                                            calculateGrossProfitLoss(key, financialDetailsMap.get(year).Gross_profit_loss__c, Decimal.valueOf(chapterField.getText()));
                                        financialDetailsMap.get(year).Depreciation__c = 
                                            calculateDepreciation(key, financialDetailsMap.get(year).Depreciation__c, Decimal.valueOf(chapterField.getText()));
                                        financialDetailsMap.get(year).Income_and_other_taxes__c = 
                                            calculateIncomeAndOtherTaxes(key, financialDetailsMap.get(year).Income_and_other_taxes__c, Decimal.valueOf(chapterField.getText()));
                                        financialDetailsMap.get(year).EBIT_from_Crefo__c = 
                                            calculateEBITFromCrefo(key, financialDetailsMap.get(year).EBIT_from_Crefo__c, Decimal.valueOf(chapterField.getText()));
                                        financialDetailsMap.get(year).Financial_Income__c = 
                                            calculateFinancialIncome(key, financialDetailsMap.get(year).Financial_Income__c, Decimal.valueOf(chapterField.getText()));
                                        financialDetailsMap.get(year).Financial_Charges__c = 
                                            calculateFinancialCharges(key, financialDetailsMap.get(year).Financial_Charges__c, Decimal.valueOf(chapterField.getText()));
                                        financialDetailsMap.get(year).EAT__c = 
                                            calculateEAT(key, financialDetailsMap.get(year).EAT__c, Decimal.valueOf(chapterField.getText()), year);
                                        financialDetailsMap.get(year).Exceptional_Income__c = 
                                            calculateExceptionalIncome(key, financialDetailsMap.get(year).Exceptional_Income__c, Decimal.valueOf(chapterField.getText()));
                                        financialDetailsMap.get(year).Exceptional_Charges__c = 
                                            calculateExceptionalCharges(key, financialDetailsMap.get(year).Exceptional_Charges__c, Decimal.valueOf(chapterField.getText()));
                                    } 
                                }
                            }
                        }
                    }
                }
            }
        }

        return financialDetailsMap;
    }


    /*******************************************************************************
    *  Name            : calculateItemsData(Map<String, Financial_Detail__c> financialDetailsMap)
    *  Summary         : Calculate Financial Detail data based on Creditreform profitlossessheet items.     
    *  CreatedDate     : 20/09/2018
    *  ModifiedDate    : -
    *  Parameters      : Map<String, Financial_Detail__c> financialDetailsMap - Financial Details for years Map,
                         Dom.XMLNode bodyField - body from response.
    *  Returns         : Map<String, Financial_Detail__c> 
    ******************************************************************************/
    public static Map<String, Financial_Detail__c> calculateItemsData(Map<String, Financial_Detail__c> financialDetailsMap, Dom.XMLNode bodyField) {
        for (Dom.XMLNode reportDataField : bodyField.getChildElements()) {
            if (reportDataField.getName() == 'profitslosses') {
                for (Dom.XMLNode profitsLossesField : reportDataField.getChildElements()) {
                    if (profitsLossesField.getName() == 'profitslossessheet') {
                        String year;
                        String typeOfBalance;
                        for (Dom.XMLNode profitsLossesSheetField : profitsLossesField.getChildElements()) {
                            if (profitsLossesSheetField.getName() == 'reportperiod') {
                                for (Dom.XMLNode reportPeriodField : profitsLossesSheetField.getChildElements()) {
                                    if (reportPeriodField.getName() == 'datestart') {
                                        year = reportPeriodField.getText().substring(0, 4);
                                    }
                                }
                            } else if (profitsLossesSheetField.getName() == 'typeofbalance') {
                                for (Dom.XMLNode typeOfBalanceField : profitsLossesSheetField.getChildElements()) {
                                    if (typeOfBalanceField.getName() == 'key') {
                                        typeOfBalance = typeOfBalanceField.getText();
                                        if (typeofbalance == 'BATY-1') {
                                            if (! financialDetailsMap.containsKey(year)) {
                                                financialDetailsMap.put(year, new Financial_Detail__c());
                                            }
                                            if (! eatCalculationMap.containsKey(year)) {
                                                eatCalculationMap.put(year, false);
                                            }
                                        }
                                    }
                                }
                            } else if (profitsLossesSheetField.getName() == 'chapter' && typeofbalance == 'BATY-1') {
                                String key;
                                for (Dom.XMLNode chapterField : profitsLossesSheetField.getChildElements()) {
                                    if (chapterField.getName() == 'item') {
                                        for (Dom.XMLNode itemField : chapterField.getChildElements()) {
                                            if (itemField.getName() == 'itemname') {
                                                for (Dom.XMLNode itemTextField : itemField.getChildElements()) {
                                                    if (itemTextField.getName() == 'key') {
                                                        key = itemTextField.getText();
                                                    }
                                                }
                                            } else if (itemField.getName() == 'amount') {
                                                financialDetailsMap.get(year).Turnover__c = 
                                                    calculateTurnover(key, financialDetailsMap.get(year).Turnover__c, Decimal.valueOf(itemField.getText()));
                                                financialDetailsMap.get(year).Activation__c = 
                                                    calculateActivation(key, financialDetailsMap.get(year).Activation__c, Decimal.valueOf(itemField.getText()));
                                                financialDetailsMap.get(year).Other_operational_income__c = 
                                                    calculateOtherOperationalIncome(key, financialDetailsMap.get(year).Other_operational_income__c, Decimal.valueOf(itemField.getText()));
                                                financialDetailsMap.get(year).Cost_of_goods_sold__c = 
                                                    calculateCostOfGoodsSold(key, financialDetailsMap.get(year).Cost_of_goods_sold__c, Decimal.valueOf(itemField.getText()));
                                                financialDetailsMap.get(year).Gross_profit_loss__c =
                                                    calculateGrossProfitLoss(key, financialDetailsMap.get(year).Gross_profit_loss__c, Decimal.valueOf(itemField.getText()));
                                                financialDetailsMap.get(year).Depreciation__c = 
                                                    calculateDepreciation(key, financialDetailsMap.get(year).Depreciation__c, Decimal.valueOf(itemField.getText()));
                                                financialDetailsMap.get(year).Income_and_other_taxes__c = 
                                                    calculateIncomeAndOtherTaxes(key, financialDetailsMap.get(year).Income_and_other_taxes__c, Decimal.valueOf(itemField.getText()));
                                                financialDetailsMap.get(year).EBIT_from_Crefo__c = 
                                                    calculateEBITFromCrefo(key, financialDetailsMap.get(year).EBIT_from_Crefo__c, Decimal.valueOf(itemField.getText()));
                                                financialDetailsMap.get(year).Financial_Income__c = 
                                                    calculateFinancialIncome(key, financialDetailsMap.get(year).Financial_Income__c, Decimal.valueOf(itemField.getText()));
                                                financialDetailsMap.get(year).Financial_Charges__c = 
                                                    calculateFinancialCharges(key, financialDetailsMap.get(year).Financial_Charges__c, Decimal.valueOf(itemField.getText()));
                                                financialDetailsMap.get(year).EAT__c = 
                                                    calculateEAT(key, financialDetailsMap.get(year).EAT__c, Decimal.valueOf(itemField.getText()), year);
                                                financialDetailsMap.get(year).Exceptional_Income__c = 
                                                    calculateExceptionalIncome(key, financialDetailsMap.get(year).Exceptional_Income__c, Decimal.valueOf(itemField.getText()));
                                                financialDetailsMap.get(year).Exceptional_Charges__c = 
                                                    calculateExceptionalCharges(key, financialDetailsMap.get(year).Exceptional_Charges__c, Decimal.valueOf(itemField.getText()));
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

        return financialDetailsMap;
    }


    /*******************************************************************************
    *  Name            : calculateTurnover(String key, Decimal turnover, Decimal amount)
    *  Summary         : Calculate Turnover based on Creditreform Chapters or Profitlossessheet Items. 
    *  CreatedDate     : 19/09/2018
    *  ModifiedDate    : -
    *  Parameters      : String key - item key, Decimal turnover - Turnover,
                         Decimal amount - amount of current item
    *  Returns         : Decimal
    ******************************************************************************/
    public static Decimal calculateTurnover(String key, Decimal turnover, Decimal amount) {
        /* PLIT-11000 - Sales revenues; PLIT-101100 - operating revenues; PLIT-101110 - sales revenues */
        if (key.equals('PLIT-11000') || key.equals('PLIT-101100') || key.equals('PLIT-101110')) {
            if (turnover != null) {
                turnover += amount / 1000;
            } else {
                turnover = amount / 1000;
            }
        }

        return turnover;
    }


    /*******************************************************************************
    *  Name            : calculateActivation(String key, Decimal activation, Decimal amount)
    *  Summary         : Calculate Activation based on Creditreform Chapters or Profitlossessheet Items. 
    *  CreatedDate     : 19/09/2018
    *  ModifiedDate    : -
    *  Parameters      : String key - item key, Decimal activation - Activation,
                         Decimal amount - amount of current item
    *  Returns         : Decimal
    ******************************************************************************/
    public static Decimal calculateActivation(String key, Decimal activation, Decimal amount) {
        /* PLIT-11100 - Change in stock (+/-); PLIT-11200 - Own work capitalized */
        if (key.equals('PLIT-11100') || key.equals('PLIT-11200')) {
            if (activation != null) {
                activation += amount / 1000;
            } else {
                activation = amount / 1000;
            }
        }

        return activation;
    }


    /*******************************************************************************
    *  Name            : calculateOtherOperationalIncome(String key, Decimal otherOperationalIncome, Decimal amount)
    *  Summary         : Calculate Other Operational Income based on Creditreform Chapters or Profitlossessheet Items. 
    *  CreatedDate     : 19/09/2018
    *  ModifiedDate    : -
    *  Parameters      : String key - item key, Decimal otherOperationalIncome - Other Operational Income,
                         Decimal amount - amount of current item
    *  Returns         : Decimal
    ******************************************************************************/
    public static Decimal calculateOtherOperationalIncome(String key, Decimal otherOperationalIncome, Decimal amount) {
        /* PLIT-11800 - Other operating income */
        if (key.equals('PLIT-11800')) {
            if (otherOperationalIncome != null) {
                otherOperationalIncome += amount / 1000;
            } else {
                otherOperationalIncome = amount / 1000;
            }
        }

        return otherOperationalIncome;
    }


    /*******************************************************************************
    *  Name            : calculateCostOfGoodsSold(String key, Decimal costOfGoodsSold, Decimal amount)
    *  Summary         : Calculate Cost Of Goods Sold based on Creditreform Chapters or Profitlossessheet Items. 
    *  CreatedDate     : 19/09/2018
    *  ModifiedDate    : -
    *  Parameters      : String key - item key, Decimal costOfGoodsSold - Cost Of Goods Sold,
                         Decimal amount - amount of current item
    *  Returns         : Decimal
    ******************************************************************************/
    public static Decimal calculateCostOfGoodsSold(String key, Decimal costOfGoodsSold, Decimal amount) {
        /* PLIT-11300 - Cost of goods; PLIT-11900 - Cost of materials; PLIT-101210 - cost of material; PLIT-101220 - production costs */
        if (key.equals('PLIT-11300') || key.equals('PLIT-11900') || key.equals('PLIT-101210') || key.equals('PLIT-101220')) {
            if (costOfGoodsSold != null) {
                costOfGoodsSold += amount / 1000;
            } else {
                costOfGoodsSold = amount / 1000;
            }
        }

        return costOfGoodsSold;
    }


    /*******************************************************************************
    *  Name            : calculateGrossProfitLoss(String key, Decimal grossProfitLoss, Decimal amount)
    *  Summary         : Calculate Gross profit/loss on Creditreform Chapters or Profitlossessheet Items. 
    *  CreatedDate     : 25/01/2019
    *  ModifiedDate    : -
    *  Parameters      : String key - item key, Decimal grossProfitLoss - Gross profit/loss
                         Decimal amount - amount of current item
    *  Returns         : Decimal
    ******************************************************************************/
    public static Decimal calculateGrossProfitLoss(String key, Decimal grossProfitLoss, Decimal amount) {
        /* PLIT-11400 - Gross profit/loss on sales */
        if (key.equals('PLIT-11400')) {
            if (grossProfitLoss != null) {
                grossProfitLoss += amount / 1000;
            } else {
                grossProfitLoss = amount / 1000;
            }
        }

        return grossProfitLoss;
    }


    /*******************************************************************************
    *  Name            : calculateDepreciation(String key, Decimal depreciation, Decimal amount)
    *  Summary         : Calculate Depreciation based on Creditreform Chapters or Profitlossessheet Items. 
    *  CreatedDate     : 19/09/2018
    *  ModifiedDate    : -
    *  Parameters      : String key - item key, Decimal depreciation - Depreciation,
                         Decimal amount - amount of current item
    *  Returns         : Decimal
    ******************************************************************************/
    public static Decimal calculateDepreciation(String key, Decimal depreciation, Decimal amount) {
        /* PLIT-12200 - Depreciations; PLIT-101320 - depreciations */
        if (key.equals('PLIT-12200') || key.equals('PLIT-101320')) {
            if (depreciation != null) {
                depreciation += amount / 1000;
            } else {
                depreciation = amount / 1000;
            }
        }

        return depreciation;
    }


    /*******************************************************************************
    *  Name            : calculateIncomeAndOtherTaxes(String key, Decimal incomeAndOtherTaxes, Decimal amount)
    *  Summary         : Calculate Income and other taxes based on Creditreform Chapters or Profitlossessheet Items. 
    *  CreatedDate     : 25/01/2019
    *  ModifiedDate    : -
    *  Parameters      : String key - item key, Decimal incomeAndOtherTaxes,
                         Decimal amount - amount of current item
    *  Returns         : Decimal
    ******************************************************************************/
    public static Decimal calculateIncomeAndOtherTaxes(String key, Decimal incomeAndOtherTaxes, Decimal amount) {
        /* PLIT-13100 - Taxes on income; PLIT-13200 - Other taxes, PLIT-101850 - taxes */
        if (key.equals('PLIT-13100') || key.equals('PLIT-13200') || key.equals('PLIT-101850')) {
            if (incomeAndOtherTaxes != null) {
                incomeAndOtherTaxes += amount / 1000;
            } else {
                incomeAndOtherTaxes = amount / 1000;
            }
        }

        return incomeAndOtherTaxes;
    }


    /*******************************************************************************
    *  Name            : calculateEBITFromCrefo(String key, Decimal ebitFromCrefo, Decimal amount)
    *  Summary         : Calculate EBIT from Crefo based on Crefitreform Chapters or Profitlossessheet Items.    
    *  CreatedDate     : 25/01/2019
    *  ModifiedDate    : -
    *  Parameters      : String key - item key, Decimal - ebitFromCrefo - EBIT from Crefo, 
                         Decimal amount - amount of current item
    *  Returns         : Decimal
    ******************************************************************************/
    public static Decimal calculateEBITFromCrefo(String key, Decimal ebitFromCrefo, Decimal amount) {
        /* PLIT-12400 - Operating result; PLIT-101400 - operating result */
        if (key.equals('PLIT-12400') || key.equals('PLIT-101400')) {
            if (ebitFromCrefo != null) {
                ebitFromCrefo += amount / 1000;
            } else {
                ebitFromCrefo = amount / 1000;
            }
        }

        return ebitFromCrefo;
    }


    /*******************************************************************************
    *  Name            : calculateFinancialIncome(String key, Decimal financialIncome, Decimal amount)
    *  Summary         : Calculate Financial Income based on Creditreform Chapters or Profitlossessheet Items. 
    *  CreatedDate     : 19/09/2018
    *  ModifiedDate    : -
    *  Parameters      : String key - item key, Decimal financialIncome - Financial Income,
                         Decimal amount - amount of current item
    *  Returns         : Decimal
    ******************************************************************************/
    public static Decimal calculateFinancialIncome(String key, Decimal financialIncome, Decimal amount) {
        /* PLIT-12500 - Income from participations; PLIT-12600 - Interests and similar income; PLIT-101450 - financial income */
        if (key.equals('PLIT-12500') || key.equals('PLIT-12600') || key.equals('PLIT-101450')) {
            if (financialIncome != null) {
                financialIncome += amount / 1000;
            } else {
                financialIncome = amount / 1000;
            }
        }

        return financialIncome;
    }


    /*******************************************************************************
    *  Name            : calculateFinancialCharges(String key, Decimal financialCharges, Decimal amount)
    *  Summary         : Calculate Financial Charges based on Creditreform Chapters or Profitlossessheet Items. 
    *  CreatedDate     : 19/09/2018
    *  ModifiedDate    : -
    *  Parameters      : String key - item key, Decimal financialCharges - Financial Charges,
                         Decimal amount - amount of current item
    *  Returns         : Decimal
    ******************************************************************************/
    public static Decimal calculateFinancialCharges(String key, Decimal financialCharges, Decimal amount) {
        /* PLIT-12700 - Interests and similar expenses; PLIT-101500 - financial expenses */
        if (key.equals('PLIT-12700') || key.equals('PLIT-101500')) {
            if (financialCharges != null) {
                financialCharges += amount / 1000;
            } else {
                financialCharges = amount / 1000;
            }
        }

        return financialCharges;
    }


    /*******************************************************************************
    *  Name            : calculateEAT(String key, Decimal eat, Decimal amount, String year)
    *  Summary         : Calculate EAT based on Creditreform Chapters or Profitlossessheet Items. 
    *  CreatedDate     : 19/09/2018
    *  ModifiedDate    : -
    *  Parameters      : String key - item key, Decimal eat - EAT,
                         Decimal amount - amount of current item, String year - current year
    *  Returns         : Decimal
    ******************************************************************************/
    public static Decimal calculateEAT(String key, Decimal eat, Decimal amount, String year) {
        /* PLIT-13400 - Net profit / net loss; PLIT-13600 - Balance sheet profit / balance sheet loss; PLIT-101900 - annual profit or loss */
        if ((eatCalculationMap.get(year) == false && (key.equals('PLIT-13400') || key.equals('PLIT-13600'))) || key.equals('PLIT-101900')) {
            if (eat != null) {
                eat += amount / 1000;
            } else {
                eat = amount / 1000;
            }
        }

        if (key.equals('PLIT-13400') || key.equals('PLIT-13600')) {
            eatCalculationMap.put(year, true);
        }

        return eat;
    }


    /*******************************************************************************
    *  Name            : calculateExceptionalIncome(String key, Decimal exceptionalIncome, Decimal amount)
    *  Summary         : Calculate Exceptional Income based on Creditreform Chapters or Profitlossessheet Items. 
    *  CreatedDate     : 17/12/2018
    *  ModifiedDate    : -
    *  Parameters      : String key - item key, Decimal exceptionalIncome - ExceptionalIncome,
                         Decimal amount - amount of current item
    *  Returns         : Decimal
    ******************************************************************************/
    public static Decimal calculateExceptionalIncome(String key, Decimal exceptionalIncome, Decimal amount) {
        /* PLIT-13000 - Extraordinary result; PLIT-101600 - extraordinary income; PLIT-101700 - extraordinary result */
        if (key.equals('PLIT-13000') || key.equals('PLIT-101600') || key.equals('PLIT-101700') && amount > 0) {
            if (exceptionalIncome != null) {
                exceptionalIncome += amount / 1000;
            } else {
                exceptionalIncome = amount / 1000;
            }
        }

        return exceptionalIncome;
    }


    /*******************************************************************************
    *  Name            : calculateExceptionalCharges(String key, Decimal exceptionalCharges, Decimal amount)
    *  Summary         : Calculate Exceptional Charges based on Creditreform Chapters or Profitlossessheet Items. 
    *  CreatedDate     : 17/12/2018
    *  ModifiedDate    : -
    *  Parameters      : String key - item key, Decimal exceptionalCharges - Exceptional Charges,
                         Decimal amount - amount of current item
    *  Returns         : Decimal
    ******************************************************************************/
    public static Decimal calculateExceptionalCharges(String key, Decimal exceptionalCharges, Decimal amount) {
        /* PLIT-101650 - extraordinary expenses; PLIT-101700 - extraordinary result */
        if (key.equals('PLIT-101650') || key.equals('PLIT-101700') && amount < 0) {
            if (key.equals('PLIT-101700')) {
                amount = amount * (-1);
            }
            if (exceptionalCharges != null) {
                exceptionalCharges += amount / 1000;
            } else {
                exceptionalCharges = amount / 1000;
            }
        }

        return exceptionalCharges;
    }


    public static Map<String, String> legalFormsMap = new Map<String, String>{
        'LEFO-DE-2' => 'Freier Beruf',
        'LEFO-DE-3' => 'Gewerbebetrieb',
        'LEFO-DE-6' => 'Einzelfirma',
        'LEFO-DE-11' => 'AG',
        'LEFO-DE-13' => 'e.V.',
        'LEFO-DE-14' => 'Sonstige Kapitalgesselschaften',
        'LEFO-DE-15' => 'Sonstige Kapitalgesselschaften',
        'LEFO-DE-17' => 'Körperschaft öffentlichen Rechts',
        'LEFO-DE-19' => 'AöR',
        'LEFO-DE-45' => 'Sonstige Kapitalgesselschaften',
        'LEFO-DE-46' => 'Sonstige Kapitalgesselschaften',
        'LEFO-DE-101' => 'Sonstige Kapitalgesselschaften',
        'LEFO-DE-102' => 'UG',
        'LEFO-DE-103' => 'Sonstige Kapitalgesselschaften',
        'LEFO-DE-111' => 'Sonstige Kapitalgesselschaften',
        'LEFO-DE-121' => 'Sonstige Kapitalgesselschaften',
        'LEFO-DE-141' => 'Sonstige Kapitalgesselschaften',
        'LEFO-DE-142' => 'Sonstige Kapitalgesselschaften',
        'LEFO-DE-143' => 'Sonstige Kapitalgesselschaften',
        'LEFO-DE-144' => 'Sonstige Kapitalgesselschaften',
        'LEFO-DE-145' => 'Sonstige Kapitalgesselschaften',
        'LEFO-DE-146' => 'Sonstige Kapitalgesselschaften',
        'LEFO-DE-900' => 'GmbH & Co KG',
        'LEFO-DE-901' => 'Sonstige Kapitalgesselschaften',
        'LEFO-DE-902' => 'Sonstige Kapitalgesselschaften',
        'LEFO-DE-903' => 'Sonstige Kapitalgesselschaften',
        'LEFO-DE-904' => 'Sonstige Kapitalgesselschaften',
        'LEFO-DE-905' => 'Sonstige Kapitalgesselschaften',
        'LEFO-DE-906' => 'Sonstige Kapitalgesselschaften',
        'LEFO-DE-907' => 'Sonstige Kapitalgesselschaften',
        'LEFO-DE-908' => 'Sonstige Kapitalgesselschaften',
        'LEFO-DE-909' => 'Sonstige Kapitalgesselschaften',
        'LEFO-DE-910' => 'Sonstige Kapitalgesselschaften',
        'LEFO-DE-911' => 'Sonstige Kapitalgesselschaften',
        'LEFO-DE-912' => 'Sonstige Kapitalgesselschaften',
        'LEFO-DE-913' => 'Sonstige Kapitalgesselschaften',
        'LEFO-DE-914' => 'Sonstige Kapitalgesselschaften',
        'LEFO-DE-915' => 'Sonstige Kapitalgesselschaften',
        'LEFO-DE-916' => 'Stiftung',
        'LEFO-DE-917' => 'Stiftung',
        'LEFO-DE-10' => 'GmbH',
        'LEFO-DE-4' => 'GbR',
        'LEFO-DE-8' => 'KG',
        'LEFO-DE-7' => 'oHG'
    };
}