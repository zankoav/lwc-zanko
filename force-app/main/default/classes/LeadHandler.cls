public class LeadHandler {
    public static Boolean isNeedToSend = false;
    public static Boolean enablesTrigger = true;
    public static Boolean isNewPartners = true;
    public static Boolean isLeadClosed = true;
    public static Boolean isSwitchToE2E = true;


    /*******************************************************************************
    *  Name            : setRecordType(List<Lead> newList)
    *  Summary         : set Record for Lead
    *  CreatedDate     : 05.09.2017
    *  Parameters      : List<Lead> new List - new Lead values
    *  Returns         : void
    ******************************************************************************/
    public static void setRecordType(List<Lead> newList) {
        Map<Id, Lead> leadsForUpdate = new Map<Id, Lead>();
        for (Lead lead : newList) {
            if (lead.CountryCode == 'RU' && lead.LeadSource == 'Facebook') {
                leadsForUpdate.put(lead.Id, lead);
            } else if ((lead.CountryCode == 'CZ' || lead.CountryCode == 'SK') && lead.Source_of_Lead__c == 'Facebook_CCS') {
                leadsForUpdate.put(lead.Id, lead);
            }
        }

        if (leadsForUpdate != null){
            List<RecordType> recordTypesList = [
                    SELECT Name
                    FROM RecordType
                    WHERE (Name = 'Russian Sales' OR Name = 'CCS Sales process') AND sObjectType = 'Lead'
            ];
            Map<String, RecordType> recordTypesMap = new Map<String, RecordType>();
            for (RecordType recordType : recordTypesList) {
                recordTypesMap.put(recordType.Name, recordType);
            }

            if (!recordTypesMap.isEmpty()) {
                for (Lead lead : newList) {
                    if (lead.CountryCode == 'RU' && lead.LeadSource == 'Facebook' && recordTypesMap.containsKey('Russian Sales')) {
                        lead.RecordTypeId = recordTypesMap.get('Russian Sales').Id;
                    } else if ((lead.CountryCode == 'CZ' || lead.CountryCode == 'SK') && lead.Source_of_Lead__c == 'Facebook_CCS' && recordTypesMap.containsKey('CCS Sales process')) {
                        lead.RecordTypeId = recordTypesMap.get('CCS Sales process').Id;
                    }
                }
            }
        }
    }


    /*******************************************************************************
    *  Name            : prepareFacebookNumberOfCards(List<Lead> newList)
    *  Summary         : Replace + with empty string    
    *  CreatedDate     : 03/03/2019
    *  ModifiedDate    : -
    *  Parameters      : newList - Trigger.new
    *  Returns         : void
    ******************************************************************************/
    public static void prepareFacebookNumberOfCards(List<Lead> newList) {
        for (Lead leadRecord : newList) {
            if (leadRecord.Number_of_Cards_facebook__c != null && leadRecord.Number_of_Cards_facebook__c.contains('+')) {
                leadRecord.Number_of_Cards_facebook__c = leadRecord.Number_of_Cards_facebook__c.replace('+','');
            }
        }
    }


    /*******************************************************************************
    *  Name            : switchToE2E(List<Lead> newList)
    *  Summary         : Automatically switch to e2e: Inbound email      
    *  CreatedDate     : 14.11.2018
    *  ModifiedDate    : 
    *  Parameters      : newMap - Trigger.newMap
    *  Returns         : void
    ******************************************************************************/
    public static void switchToE2E(Map<Id, Lead> newMap) {
        if (newMap.size() > 1 || ! isSwitchToE2E) return;
        isSwitchToE2E = false;
        Lead currentLead = newMap.values().get(0);
        if (currentLead.CountryCode == null && currentLead.Country == null) return;
        if ( ! countryCodeToCountryMap.containsKey(currentLead.CountryCode) || currentLead.Quali_Status__c == 'Switched to E2E') return;
        String country = countryCodeToCountryMap.get(currentLead.CountryCode); 
        if (currentLead.Sec_Channel__c == 'JITB') country += 'JITB';       
        Lead_Switched_To_E2E__c switchedToE2ESettings = Lead_Switched_To_E2E__c.getInstance(country);
        if (switchedToE2ESettings == null) return;
        if (isSwitchToE2EInboundCall(currentLead) || 
            isSwitchToE2EInboundEmail(currentLead) ||
            isSwitchToE2EShellEmail(currentLead)) {                        
            if (currentLead.CCS_number_of_cards__c >= switchedToE2ESettings.Min_Cards__c && 
                currentLead.CCS_number_of_cards__c <= switchedToE2ESettings.Max_Cards__c) {
                switchToE2EFuture(currentLead.Id);
            }
        } else 
        if ((isSwitchToE2EFromFacebook(currentLead) || isSwitchToE2EFromPopup(currentLead) || isSwitchToE2EFromShortForm(currentLead)) && 
            currentLead.Number_of_Cards_facebook__c != null) {
            if (Integer.valueOf(currentLead.Number_of_Cards_facebook__c) >= switchedToE2ESettings.Min_Cards__c && 
                Integer.valueOf(currentLead.Number_of_Cards_facebook__c) <= switchedToE2ESettings.Max_Cards__c) {
                switchToE2EFuture(currentLead.Id);
            }            
        } else if (isSwitchToE2EFromPartnerJITB(currentLead)) {
            if ((currentLead.CountryCode == 'DE' || currentLead.Country == 'Germany') && currentLead.Anzahl_der_Fahrzeuge__c != null) {
                if (Integer.valueOf(currentLead.Anzahl_der_Fahrzeuge__c) >= switchedToE2ESettings.Min_Cards__c && 
                    Integer.valueOf(currentLead.Anzahl_der_Fahrzeuge__c) <= switchedToE2ESettings.Max_Cards__c) {
                    switchToE2EFuture(currentLead.Id);
                }
            } else if (((currentLead.CountryCode == 'PL' || currentLead.Country == 'Poland') ||
                        (currentLead.CountryCode == 'HU' || currentLead.Country == 'Hungary')) && currentLead.CCS_number_of_cards__c != null) {
                if (Integer.valueOf(currentLead.CCS_number_of_cards__c) >= switchedToE2ESettings.Min_Cards__c && 
                    Integer.valueOf(currentLead.CCS_number_of_cards__c) <= switchedToE2ESettings.Max_Cards__c) {
                    switchToE2EFuture(currentLead.Id);
                }
            }
        }       
    }

    @future
    public static void switchToE2EFuture(String leadId) {
        Lead lead = [SELECT Contact_Email_Body__c, Country, Company, LastName, FirstName, Phone, Email, (SELECT NewValue FROM Histories LIMIT 100) FROM Lead WHERE Id = :leadId LIMIT 1];

        List<Lead> checkDuplicatesList = [
                SELECT Id 
                FROM Lead 
                WHERE ((FirstName = :lead.FirstName AND LastName = :lead.LastName AND Email = :lead.Email) OR 
                      (FirstName = :lead.FirstName AND LastName = :lead.LastName AND Phone = :lead.Phone) OR 
                      (Company = :lead.Company AND Phone = :lead.Phone) OR 
                      (Company = :lead.Company AND Email = :lead.Email)) AND 
                      Country = :lead.Country AND 
                      Id != :lead.Id
                LIMIT 1];
        if ( ! checkDuplicatesList.isEmpty() ) {
            isSwitchToE2E = false;
            lead.Status = 'Disqualified';
            lead.Quali_Status__c = 'Auto-detect (E2E)';
            update lead;

            return;
        }

        for (LeadHistory leadhistory : lead.Histories) {
            if (String.valueOf(leadhistory.NewValue) == 'Switched to E2E') {
                return;
            }
        }

        E2E_Form_General_Settings__c e2eGeneralSettings = E2E_Form_General_Settings__c.getInstance(lead.Country);
        if (e2eGeneralSettings == null) {
            return;
        }
        lead.OwnerId = e2eGeneralSettings.E2E_Guest_User_Id__c;
        lead.Quali_Status__c = 'Switched to E2E';
        
        if (lead.Company != null && lead.Company.containsIgnoreCase('[nicht vorhanden]') || lead.Company == null) {
            lead.Company = 'LONGFORM: ' + (lead.FirstName != null ? lead.FirstName + ' ' : '') + lead.LastName;
        }
        update lead;
    }


    private static Boolean isSwitchToE2EFromPartnerJITB(Lead lead) {
        if (lead.Sec_Channel__c == 'JITB' &&
            lead.Channel__c == 'Internet' &&
            lead.LeadSource == 'Partner' &&
            lead.Salutation != null) {
            return true;
        }
        return false;
    }


    private static Boolean isSwitchToE2EFromFacebook(Lead lead) {
        if ((lead.Country == 'Germany' || lead.CountryCode == 'DE' ||
             lead.Country == 'Netherlands' || lead.CountryCode == 'NL' ||
             lead.Country == 'Belgium-NL' || lead.CountryCode == 'BENL' ||
             lead.Country == 'Belgium-FR' || lead.CountryCode == 'BEFR') && 
             lead.LeadSource == 'Facebook' && lead.Number_of_Cards_facebook__c != null) {
            return true;
        }
        return false;
    }    


    private static Boolean isSwitchToE2EInboundCall(Lead lead) {
        if ((lead.Country == 'Germany' || lead.CountryCode == 'DE' ||
             lead.Country == 'Netherlands' || lead.CountryCode == 'NL' ||
             lead.Country == 'Belgium-NL' || lead.CountryCode == 'BENL' ||
             lead.Country == 'Belgium-FR' || lead.CountryCode == 'BEFR') && 
             lead.LeadSource == 'Inbound Call' && lead.CCS_number_of_cards__c != null && lead.Email != null) {
            return true;
        }
        return false;
    }   


    private static Boolean isSwitchToE2EInboundEmail(Lead lead) {
        if ((lead.Country == 'Germany' || lead.CountryCode == 'DE' ||
             lead.Country == 'Netherlands' || lead.CountryCode == 'NL' ||
             lead.Country == 'Belgium-NL' || lead.CountryCode == 'BENL' ||
             lead.Country == 'Belgium-FR' || lead.CountryCode == 'BEFR') && 
             lead.LeadSource == 'Inbound Email' && lead.CCS_number_of_cards__c != null && 
             lead.Email != null) {
            return true;
        }
        return false;
    }


    private static Boolean isSwitchToE2EShellEmail(Lead lead) {
        if ((lead.Country == 'Netherlands' || lead.CountryCode == 'NL' ||
             lead.Country == 'Belgium-NL' || lead.CountryCode == 'BENL' ||
             lead.Country == 'Belgium-FR' || lead.CountryCode == 'BEFR') && 
             lead.CCS_number_of_cards__c != null &&
             lead.LeadSource == 'Shell Email' && lead.Email != null) {
            return true;
        }
        return false;
    }         


    private static Boolean isSwitchToE2EFromPopup(Lead lead) {
        if ((lead.Country == 'Germany' || lead.CountryCode == 'DE' ||
             lead.Country == 'Netherlands' || lead.CountryCode == 'NL' ||
             lead.Country == 'Belgium-NL' || lead.CountryCode == 'BENL' ||
             lead.Country == 'Belgium-FR' || lead.CountryCode == 'BEFR') && 
             lead.LeadSource == 'popup_window' && lead.Number_of_Cards_facebook__c != null) {
            return true;
        }
        return false;
    }    


    private static Boolean isSwitchToE2EFromShortForm(Lead lead) {
        if ((lead.Country == 'Germany' || lead.CountryCode == 'DE' ||
             lead.Country == 'Netherlands' || lead.CountryCode == 'NL' ||
             lead.Country == 'Belgium-NL' || lead.CountryCode == 'BENL' ||
             lead.Country == 'Belgium-FR' || lead.CountryCode == 'BEFR') && 
             lead.LeadSource == 'Web_LP' && lead.Number_of_Cards_facebook__c != null) {
            return true;
        }
        return false;
    } 


    public static void prepareShellEmailLead(List<Lead> leadsList) {
        if (leadsList.size() > 1) return;
        Lead currentLead = leadsList.get(0);
        if (currentLead.Contact_Email_Body__c == null) return;
        String country = currentLead.Country;
        if (country == null && currentLead.CountryCode != null && countryCodeToCountryMap.containsKey(currentLead.CountryCode)) {
            country = countryCodeToCountryMap.get(currentLead.CountryCode);
        }
        if (country == null) return;     
        String contactEmailBody = currentLead.Contact_Email_Body__c.replace('\n','').normalizeSpace();

        if (contactEmailBody != null && contactEmailBody.containsIgnoreCase('Formstack') && currentLead.Country == 'Belgium-FR') { 
            String lastName = returnFieldFromShellEmail(contactEmailBody, 'Nom: </td>');
            if (lastName != null) currentLead.LastName = lastName;

            String company = returnFieldFromShellEmail(contactEmailBody, 'entreprise: </td>');
            if (company != null) currentLead.Company = company;

            String phone = returnFieldFromShellEmail(contactEmailBody, 'Numéro de téléphone: </td>');
            if (phone != null) currentLead.Phone = phone;

            String email = returnFieldFromShellEmail(contactEmailBody, 'Adresse email: </td>');
            if (email != null) currentLead.Email = email;

            String numberOfCards = returnFieldFromShellEmail(contactEmailBody, 'Nombre de voitures: </td>');
            if (numberOfCards != null && numberOfCards.isNumeric()) {
                currentLead.CCS_number_of_cards__c = Integer.valueOf(numberOfCards);
            }            
        } else 
        if (contactEmailBody != null && contactEmailBody.containsIgnoreCase('Formstack') && currentLead.Country == 'Belgium-NL') {    
            String lastName = returnFieldFromShellEmail(contactEmailBody, 'Naam: </td>');
            if (lastName != null) currentLead.LastName = lastName;

            String company = returnFieldFromShellEmail(contactEmailBody, 'Bedrijfsnaam: </td>');
            if (company != null) currentLead.Company = company;

            String phone = returnFieldFromShellEmail(contactEmailBody, 'Telefoonummer: </td>');
            if (phone != null) currentLead.Phone = phone;

            String email = returnFieldFromShellEmail(contactEmailBody, 'Emailadres: </td>');
            if (email != null) currentLead.Email = email;

            String numberOfCards = returnFieldFromShellEmail(contactEmailBody, 'Aantal voertuigen: </td>');            
            if (numberOfCards != null && numberOfCards.isNumeric()) {
                currentLead.CCS_number_of_cards__c = Integer.valueOf(numberOfCards);
            }              
        } else        
        if (contactEmailBody != null && contactEmailBody.containsIgnoreCase('Formstack') && currentLead.Country == 'Netherlands') {
            String lastName = returnFieldFromShellEmail(contactEmailBody, 'Voor- & Achternaam: </td>');
            if (lastName != null) currentLead.LastName = lastname;

            String company = returnFieldFromShellEmail(contactEmailBody, 'Bedrijfsnaam: </td>');            
            if (company != null) currentLead.Company = company;

            String phone = returnFieldFromShellEmail(contactEmailBody, 'Telefoonnummer: </td>');
            if (phone != null) currentLead.Phone = phone;

            String email = returnFieldFromShellEmail(contactEmailBody, 'Email: </td>');
            if (email != null) currentLead.Email = email;

            String numberOfCards = returnFieldFromShellEmail(contactEmailBody, 'bestelwagens in wagenpark: </td>');
            if (numberOfCards != null && numberOfCards.isNumeric()) {
                currentLead.CCS_number_of_cards__c = Integer.valueOf(numberOfCards);
            } 
            String numberOfCards2 = returnFieldFromShellEmail(contactEmailBody, 'tourbussen in wagenpark: </td>');
            if (numberOfCards2 != null && numberOfCards2.isNumeric()) {
                if (currentLead.CCS_number_of_cards__c != null) {
                    currentLead.CCS_number_of_cards__c = currentLead.CCS_number_of_cards__c + Integer.valueOf(numberOfCards2);
                } else {
                    currentLead.CCS_number_of_cards__c = Integer.valueOf(numberOfCards2);
                }                
            } 
        }
    } 

    public static String returnFieldFromShellEmail(String body, String tagToCheck) {
        String finalBody = body;
        finalBody = finalBody.replace('&amp;','&');
        String tagToCheckToReplace = tagToCheck.replace(' </td>', '</td>');
        if (finalBody.contains(tagToCheck)) {
            finalBody = finalBody.replace(tagToCheck, tagToCheckToReplace);
        }
        String field = finalBody.substringBetween(tagToCheckToReplace,'/td>');
        if (field != null) {
            field = field.substringBetween('>','<').trim();    
            return field;
        }
        return null;
    }         


    /*******************************************************************************
    *  Name            : setValidPhone(Map<Id, Lead> oldMap, List<Lead> newList)
    *  Summary         : Set Phone in E.164 format
    *  CreatedDate     :
    *  ModifiedDate    : 30/03/2018
    *  Parameters      : oldMap, newMap – maps from the trigger
    *  Returns         : void
    ******************************************************************************/
    public static void setValidPhone(Map<Id, Lead> oldMap, List<Lead> newList) {
        for (Lead lead : newList) {
            if (lead.CountryCode != null) {
                if (oldMap != null) {
                    // before update
                    if (lead.Phone != null && oldMap.get(lead.Id).Phone != lead.Phone) {
                        lead.Phone = ClickToCallHandler.returnValidNumber(lead.Phone, lead.CountryCode);
                    }
                    if (lead.MobilePhone != null && oldMap.get(lead.Id).MobilePhone != lead.MobilePhone) {
                        lead.MobilePhone = ClickToCallHandler.returnValidNumber(lead.MobilePhone, lead.CountryCode);
                    }
                }
                if (OldMap == null) {
                    // before insert
                    if (lead.Phone != null) {
                        lead.Phone = ClickToCallHandler.returnValidNumber(lead.Phone, lead.CountryCode);
                    }
                    if (lead.MobilePhone != null) {
                        lead.MobilePhone = ClickToCallHandler.returnValidNumber(lead.MobilePhone, lead.CountryCode);
                    }
                }
            }
        }
    }


    /*******************************************************************************
    *  Name            : setDublicateStatus(List<Lead> newLeads)
    *  Summary         : set status to Disqualified and Quali status to Dublicate or Sent to support
    *  CreatedDate     :
    *  Parameters      : List<Lead> newLeads - leads before insert
    *  Returns         : void
    ******************************************************************************/
    public static void setDublicateStatus(List<Lead> newLeads) {
        Map<String, List<Lead>> emailToLeadsMap = new Map<String, List<Lead>>();
        for (Lead lead : newLeads) {
            if ((lead.LeadSource == 'Web_short-form' || lead.LeadSource == 'Inbound Email' || lead.LeadSource == 'Web_LP') && lead.Email != null &&
                    !String.valueOf(lead.Email).contains('shell.com') && lead.Email != 'noreply@formstack.com') {
                if (!emailToLeadsMap.containsKey(lead.Email)) {
                    emailToLeadsMap.put(lead.Email, new List<Lead>());
                }
                emailToLeadsMap.get(lead.Email).add(lead);
            }
        }

        List<Messaging.SingleEmailMessage> emailsToSendList = new List<Messaging.SingleEmailMessage>();
        if (!emailToLeadsMap.isEmpty()) {
            RecordType endkundeRecordType = [
                    SELECT Id
                    FROM RecordType
                    WHERE Name = 'Endkunde' AND SobjectType = 'Lead'
            ];

            Map<Id, Lead> masterLeadsMap = new Map<Id, Lead>([
                    SELECT Salutation, FirstName, LastName, Email, Company, Status, ConvertedOpportunityId, ConvertedOpportunity.Name, ConvertedOpportunity.OwnerId,
                            Owner.Name, Name, CountryCode
                    FROM Lead
                    WHERE Email IN :emailToLeadsMap.keySet() AND (Status = 'Open' OR Status = 'Contacted' OR (Status = 'Konvertierte Leads'
                    AND ConvertedOpportunity.StageName != 'Closed Won' AND ConvertedOpportunity.StageName != 'Closed Lost')) AND
                    (LeadSource = 'Web_short-form' OR LeadSource = 'Inbound Email' OR lead.LeadSource = 'Web_LP') AND RecordTypeId = :endkundeRecordType.Id
                    LIMIT 10000
            ]);

            Set<String> masterEmailsList = new Set<String>();
            for (Lead lead : masterLeadsMap.values()) {
                masterEmailsList.add(lead.Email);
            }

            if (!masterEmailsList.isEmpty()) {
                for (Lead lead : newLeads) {
                    if (masterEmailsList.contains(lead.Email) && lead.Email != 'noreply@formstack.com') {
                        lead.Status = 'Disqualified';
                        lead.Quali_Status__c = 'Auto-detect';
                    }
                }

                List<Task> tasksList = new List<Task>();
                for (Lead lead : masterLeadsMap.values()) {
                    if (emailToLeadsMap.get(lead.Email) != null) {
                        if (emailToLeadsMap.get(lead.Email).size() > 0) {
                            if (emailToLeadsMap.get(lead.Email).get(0).Salutation != null && emailToLeadsMap.get(lead.Email).get(0).Salutation != lead.Salutation) {
                                lead.Salutation = emailToLeadsMap.get(lead.Email).get(0).Salutation;
                            }

                            if (emailToLeadsMap.get(lead.Email).get(0).Company != null && emailToLeadsMap.get(lead.Email).get(0).Company != lead.Company) {
                                lead.Company = emailToLeadsMap.get(lead.Email).get(0).Company;
                            }

                            if (emailToLeadsMap.get(lead.Email).get(0).FirstName != null && emailToLeadsMap.get(lead.Email).get(0).FirstName != lead.FirstName) {
                                lead.FirstName = emailToLeadsMap.get(lead.Email).get(0).FirstName;
                            }

                            if (emailToLeadsMap.get(lead.Email).get(0).LastName != null && emailToLeadsMap.get(lead.Email).get(0).LastName != lead.LastName) {
                                lead.LastName = emailToLeadsMap.get(lead.Email).get(0).LastName;
                            }

                            emailsToSendList.add(prepareEmailToOwner(lead, emailToLeadsMap));
                            tasksList.add(prepareTaskForMasterLead(lead, emailToLeadsMap));
                        }
                    }
                }
                insert tasksList;
            }

            for (Lead lead : masterLeadsMap.values()) {
                if (lead.Status == 'Konvertierte Leads') {
                    masterLeadsMap.remove(lead.Id);
                }
            }
            update masterLeadsMap.values();

            List<Lead> sendToSupportMasterLeadsList = [
                    SELECT Email, Contact_Email_Body__c
                    FROM Lead
                    WHERE Email IN :emailToLeadsMap.keySet() AND Status = 'Disqualified' AND Quali_Status__c = 'Sent to support' AND
                    (LeadSource = 'Web_short-form' OR LeadSource = 'Inbound Email' OR lead.LeadSource = 'Web_LP') AND RecordTypeId = :endkundeRecordType.Id
                    AND (CreatedDate = LAST_N_WEEKS:1 OR CreatedDate = THIS_WEEK)
                    LIMIT 10000
            ];

            if (!sendToSupportMasterLeadsList.isEmpty()) {
                Map<String, List<Lead>> sendToSupportEmailToLeadsMap = new Map<String, List<Lead>>();
                for (Lead lead : sendToSupportMasterLeadsList) {
                    if (!sendToSupportEmailToLeadsMap.containsKey(lead.Email)) {
                        sendToSupportEmailToLeadsMap.put(lead.Email, new List<Lead>());
                    }
                    sendToSupportEmailToLeadsMap.get(lead.Email).add(lead);
                }

                String sendToEmail = '';
                Map<String, String> emailToLeadMap = new Map<String, String>();
                for (Lead lead : newLeads) {
                    if (lead.Country == 'Austria') {
                        sendToEmail = 'kundenservice@fleetcor.at';
                        emailToLeadMap.put(lead.Id, sendToEmail);
                    } else if (lead.Country == 'Belgium-NL') {
                        sendToEmail = 'klantendienst@fleetcorcards.be';
                        emailToLeadMap.put(lead.Id, sendToEmail);
                    } else if (lead.Country == 'Belgium-FR') {
                        sendToEmail = 'serviceclients@fleetcorcards.be';
                        emailToLeadMap.put(lead.Id, sendToEmail);
                    } else if (lead.Country == 'Netherlands') {
                        sendToEmail = 'klantenservice@fleetcor.nl';
                        emailToLeadMap.put(lead.Id, sendToEmail);
                    } else if (lead.Country == 'France') {
                        sendToEmail = 'serviceclients@fleetcor.fr';
                        emailToLeadMap.put(lead.Id, sendToEmail);
                    } else if (lead.Country == 'Hungary') {
                        sendToEmail = 'kapcsolat@fleetcor.hu';
                        emailToLeadMap.put(lead.Id, sendToEmail);
                    } else if (lead.Country == 'Poland') {
                        sendToEmail = 'obslugaklienta@fleetcor.pl';
                        emailToLeadMap.put(lead.Id, sendToEmail);
                    } else if (lead.Country == 'Germany') {
                        sendToEmail = 'kundenservice@fleetcor.de';
                        emailToLeadMap.put(lead.Id, sendToEmail);
                    } else if (lead.Country == 'Slovakia') {
                        sendToEmail = 'backoffice@fleetcor.sk';
                        emailToLeadMap.put(lead.Id, sendToEmail);
                    } else if (lead.Country == 'Czech Republic') {
                        sendToEmail = 'backoffice@fleetcor.cz';
                        emailToLeadMap.put(lead.Id, sendToEmail);
                    } else if (lead.Country == 'Luxembourg') {
                        sendToEmail = 'backoffice@fleetcor.lu';
                        emailToLeadMap.put(lead.Id, sendToEmail);
                    } else if (lead.Country == 'Switzerland-IT' || lead.Country == 'Switzerland-FR' || lead.Country == 'Switzerland-DE') {
                        sendToEmail = 'backoffice@fleetcor.ch';
                        emailToLeadMap.put(lead.Id, sendToEmail);
                    }
                }

                if (!String.isBlank(sendToEmail)) {
                    for (Lead lead : newLeads) {
                        if (sendToSupportEmailToLeadsMap.containsKey(lead.Email)) {
                            String emailTo = emailToLeadMap.get(lead.Id);
                            lead.Status = 'Disqualified';
                            lead.Quali_Status__c = 'Sent to support';
                            emailsToSendList.add(prepareEmailToSupport(lead, sendToSupportEmailToLeadsMap, emailTo));
                        }
                    }
                }
            }
        }
        if (isNeedToSend) {
            Messaging.sendEmail(emailsToSendList);
        }
    }


    /*******************************************************************************
    *  Name            : prepareEmailToOwner()
    *  Summary         : prepare email to lead owner before creating dublicate
    *  CreatedDate     : 02/03/2017
    *  Parameters      : Lead lead - master lead, Map<String, List<Lead>> emailToLeadsMap - master leads map
    *  Returns         : Messaging.SingleEmailMessage
    ******************************************************************************/
    public static Messaging.SingleEmailMessage prepareEmailToOwner(Lead lead, Map<String, List<Lead>> emailToLeadsMap) {
        isNeedToSend = true;
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSenderDisplayName('Salesforce Notification');
        String emailBody = '';
        mail.saveAsActivity = false;
        if (lead.Status != 'Konvertierte Leads') {
            String bodyInEnglish = 'Hello ' + lead.Owner.Name + ',<br><br>Your customer ' + lead.Name + ' has filled out the web form on FleetCor website again.<br>' +
                    'The updated information was saved to the following Salesforce object: ' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + lead.Id +
                    '<br>Please perform the required follow-up activities with the customer.';
            String bodyInGerman = 'Hallo ' + lead.Owner.Name + ',<br><br>Dein Kunden ' + lead.Name + ' hat unser Webformular auf der FleetCor Website erneut ausgefüllt.<br>' +
                    'Die aktualisierten Informationen wurden im folgendem Objekt in Salesforce gespeichert: ' + System.URL.getSalesforceBaseUrl().toExternalForm()
                    + '/' + lead.Id + '<br>Bitte führe die notwendigen Folgemaßnahmen mit Deinem Kunden durch.';
            if (lead.CountryCode == 'DE' || lead.CountryCode == 'AT' || lead.CountryCode == 'CHDE') {
                emailBody = bodyInGerman;
            } else {
                emailBody = bodyInEnglish;
            }

            mail.setTargetObjectId(lead.OwnerId);
            mail.setSubject('Duplicate Web-Form ' + lead.Name);
            if (String.valueOf(lead.OwnerId).subString(0, 3) == '00G') {
                isNeedToSend = false;
            }
        } else {
            if (lead.ConvertedOpportunityId != null) {
                String firstName = (emailToLeadsMap.get(lead.Email).get(0).FirstName != null ? emailToLeadsMap.get(lead.Email).get(0).FirstName : '');
                emailBody = 'One of your current customers submitted additional short form for Lead: ' + emailToLeadsMap.get(lead.Email).get(0).LastName + ' '
                        + firstName + '. Please update the information in the existing Opportunity if necessary: '
                        + lead.ConvertedOpportunity.Name + ' ' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + lead.ConvertedOpportunityId
                        + ' and contact the customer.';
                mail.setTargetObjectId(lead.ConvertedOpportunity.OwnerId);
                mail.setSubject('Existing customer submitted new lead');
                mail.saveAsActivity = false;
            }
        }

        mail.setHtmlBody(emailBody);
        return mail;
    }


    /*******************************************************************************
    *  Name            : prepareTaskForMasterLead()
    *  Summary         : prepare task on lead before creating dublicate
    *  CreatedDate     : 02/03/2017
    *  ModifiedDate    : 14/03/2018
    *  Parameters      : Lead lead - master lead, Map<String, List<Lead>> emailToLeadsMap - master leads map
    *  Returns         : Task
    ******************************************************************************/
    public static Task prepareTaskForMasterLead(Lead lead, Map<String, List<Lead>> emailToLeadsMap) {
        Task task = new Task();
        String currentUserId = UserInfo.getUserId();
        if (lead.Status != 'Konvertierte Leads') {
            String descriptionForLeadInEnglish = 'Hello ' + lead.Owner.Name + ',\n\nYour customer ' + lead.Name + ' has filled out the web form on FleetCor website again.\n' +
                    'The updated information was saved to the following Salesforce object: ' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + lead.Id +
                    '\nPlease perform the required follow-up activities with the customer.';
            String descriptionForLeadInGerman = 'Hallo ' + lead.Owner.Name + ',\n\nDein Kunden ' + lead.Name + ' hat unser Webformular auf der FleetCor Website erneut ausgefüllt.\n' +
                    'Die aktualisierten Informationen wurden im folgendem Objekt in Salesforce gespeichert: ' + System.URL.getSalesforceBaseUrl().toExternalForm()
                    + '/' + lead.Id + '\nBitte führe die notwendigen Folgemaßnahmen mit Deinem Kunden durch.';
            task = new Task(WhoId = lead.Id, Subject = 'Duplicate Web-Form ' + lead.Name, OwnerId = currentUserId);
            if (lead.CountryCode == 'DE' || lead.CountryCode == 'AT' || lead.CountryCode == 'CHDE') {
                task.Description = descriptionForLeadInGerman;
            } else {
                task.Description = descriptionForLeadInEnglish;
            }
        } else {
            if (lead.ConvertedOpportunityId != null) {
                String firstName = (emailToLeadsMap.get(lead.Email).get(0).FirstName != null ? emailToLeadsMap.get(lead.Email).get(0).FirstName : '');
                String descriptionForOpportunity = 'One of your current customers submitted additional short form for Lead: ' + emailToLeadsMap.get(lead.Email).get(0).LastName + ' '
                        + firstName + '. Please update the information in the existing Opportunity if necessary: '
                        + lead.ConvertedOpportunity.Name + ' ' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + lead.ConvertedOpportunityId
                        + ' and contact the customer.';
                task = new Task(WhatId = lead.ConvertedOpportunityId, Subject = 'Existing customer submitted new lead', Description = descriptionForOpportunity, OwnerId = currentUserId);
            }
        }
        return task;
    }


    /*******************************************************************************
    *  Name            : prepareEmailToSupport()
    *  Summary         : prepare email to support before creating dublicate
    *  CreatedDate     : 02/03/2017
    *  Parameters      : Lead lead - master lead, Map<String, List<Lead>> sendToSupportEmailToLeadsMap - master leads map,
                        String sendToEmail - recipient address
    *  Returns         : Messaging.SingleEmailMessage
    ******************************************************************************/
    public static Messaging.SingleEmailMessage prepareEmailToSupport(Lead lead, Map<String, List<Lead>> sendToSupportEmailToLeadsMap, String sendToEmail) {
        isNeedToSend = true;
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String finalBody = 'Name: ' + (lead.FirstName != null ? lead.FirstName : '') + ' '
                + (lead.LastName != null ? lead.LastName : '') + '<br/>' + 'Company: '
                + (lead.Company != null ? lead.Company : '') + '<br/>' +
                'Phone: ' + (lead.Phone != null ? lead.Phone : '') + '<br/>' +
                'Email: ' + (lead.Email != null ? lead.Email : '') + '<br/>' +
                (sendToSupportEmailToLeadsMap.get(lead.Email).get(0).Contact_Email_Body__c != null ? 'Email text: ' + sendToSupportEmailToLeadsMap.get(lead.Email).get(0).Contact_Email_Body__c : '');
        String[] toAddresses = new String[]{
                sendToEmail
        };
        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('SFDC');
        mail.setSubject('Request from customer');
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setHtmlBody(finalBody);
        return mail;
    }


    public static void createTaskForContacted(Map<Id, Lead> oldMap, Map<Id, Lead> newMap) {
        Boolean isCheck = false;
        for (Lead lead : newMap.values()) {
            if (lead.Status != oldMap.get(lead.Id).Status && lead.Status == 'Contacted'  &&
                    lead.Quali_Status__c != 'Customer reached – forwarded to Field') {
                isCheck = true;
            }
        }
        if (isCheck){
            List<Task> currentCallTasksList = [
                    SELECT WhoId
                    FROM Task
                    WHERE Status = 'In Bearbeitung' AND WhoId IN :newMap.keySet()
                    LIMIT 10000
            ];

            Map<Id, Task> leadToTask = new Map<Id, Task>();
            for (Task task : currentCallTasksList) {
                leadToTask.put(task.WhoId, task);
            }

            List<Lead> leadIdsToDisplayMessageSet = new List<Lead>();
            for (Lead lead : newMap.values()) {
                if (lead.Status != oldMap.get(lead.Id).Status && lead.Status == 'Contacted' && !leadToTask.containsKey(lead.Id) &&
                        lead.Quali_Status__c != 'Customer reached – forwarded to Field') {
                    leadIdsToDisplayMessageSet.add(lead);
                }
            }

            if (leadIdsToDisplayMessageSet.size() != 0) {

                String userId = UserInfo.getUserId();

                List<User> currentUser = [
                        SELECT Profile.Name
                        FROM User
                        WHERE Id = :userId
                        LIMIT 1
                ];
                String ccsRecordType;
                List<RecordType> recordTypeList = ([
                        SELECT Id
                        FROM RecordType
                        WHERE SobjectType = 'Lead'
                        AND DeveloperName = 'CCS_Sales_process'
                        LIMIT 1]); 
                if ( ! recordTypeList.isEmpty() ) {
                    ccsRecordType = recordTypeList.get(0).Id;
                }
                for (Lead lead : leadIdsToDisplayMessageSet) {
                    if (!currentUser.isEmpty() && ccsRecordType != null && lead.RecordTypeId == ccsRecordType) {
                        String leadError = 'Zaregistrujte prosím volání a <a href=\'/00T/e?title=Call&who_id=' + lead.Id +
                                '&followup=1&tsk5=Call&retURL=%2F' + lead.Id + '&ent=Task\' target=\'_blank\'>vytvořte následný úkol.</a>';
                        newMap.get(lead.Id).addError(leadError, false);
                        continue;
                    }

                    if (!currentUser.isEmpty() && shellProfileSet.contains(currentUser.get(0).Profile.Name)) {
                        String leadError = 'Please log a call and create follow-up task <a href=\'/00T/e?title=Call&who_id=' + lead.Id +
                                '&followup=1&tsk5=Call&retURL=%2F' + lead.Id + '&ent=Task\' target=\'_blank\'>Log a call and create Follow-up Task</a>';
                        newMap.get(lead.Id).addError(leadError, false);
                    }
                }
            }
        }
    }


    public static void mergeChatLead(Map<Id, Lead> newLeadsMap) {
        Map<String, String> chatLeadsPhones = new Map<String, String>();
        Map<String, String> chatLeadsNames = new Map<String, String>();
        for (Lead l : newLeadsMap.values()) {
            if (l.LeadSource == 'Online_chat') {
                chatLeadsPhones.put(l.Id, l.Phone);
                chatLeadsNames.put(l.Id, l.LastName);
            }
        }

        if ((chatLeadsPhones.size() > 0) && (chatLeadsNames.size() > 0)){
            Map<Id, Lead> masterLeadsMap = new Map<Id, Lead>([
                    SELECT Email, LastName, Phone
                    FROM Lead
                    WHERE Id NOT IN :chatLeadsPhones.keySet() AND Status = 'Open' AND
                    Phone IN :chatLeadsPhones.values() AND LastName IN :chatLeadsNames.values() AND
                    LeadSource = 'Online_chat'
                    LIMIT 50000
            ]);

            Map<String, String> finalMergeMap = new Map<String, String>();
            for (String existingId : chatLeadsPhones.keySet()) {
                for (String masterId : masterLeadsMap.keySet()) {
                    if (newLeadsMap.get(existingId).Phone == masterLeadsMap.get(masterId).Phone &&
                            newLeadsMap.get(existingId).LastName == masterLeadsMap.get(masterId).LastName) {
                        finalMergeMap.put(masterId, existingId);
                    }
                }
            }
            for (String masterId : finalMergeMap.keySet()) {
                merge masterLeadsMap.get(masterId) newLeadsMap.get(finalMergeMap.get(masterId));
            }
        }
    }

    public static void updateFirstLastOwnerDate(List<Lead> newLeads) {
        for (Lead l : newLeads) {
            l.Last_Owner_Change_Date__c = Datetime.now();
        }
    }

    public static void updateLastOwnerDate(Map<Id, Lead> oldMap, Map<Id, Lead> newMap) {
        for (Lead lead : newMap.values()) {
            if (lead.OwnerId != oldMap.get(lead.Id).OwnerId && lead.First_Call__c == null) {
                lead.Last_Owner_Change_Date__c = Datetime.now();
            }
        }
    }

    public static void makeFirstCall(Map<Id, Lead> oldMap, Map<Id, Lead> newMap) {
        for (Lead lead : newMap.values()) {
            if (oldMap.get(lead.Id).Status == 'Open' && lead.Status != oldMap.get(lead.Id).Status && lead.First_Call__c == null) {
                lead.First_Call__c = Datetime.now();
            }
        }
    }

    public static void assignPartnerforOpportunity(Map<Id, Lead> oldMap, Map<Id, Lead> newMap) {
        if (!isNewPartners) return;
        List<Partner> newPartnersList = new List<Partner>();
        for (Lead l : newMap.values()) {
            if (l.ConvertedOpportunityId != oldMap.get(l.Id).ConvertedOpportunityId && l.isConverted == true &&
                    l.LeadSource == 'Partner' && l.Partner__c != null) {
                Partner newPartner = new Partner();
                newPartner.AccountToId = l.Partner__c;
                newPartner.OpportunityId = l.ConvertedOpportunityId;
                newPartner.Role = 'Multiplier';
                newPartnersList.add(newPartner);
                isNewPartners = false;
            }
        }
        if (!newPartnersList.isEmpty()) {
            insert newPartnersList;
        }
    }

    public static void updateCCS(Map<Id, Lead> oldMap, Map<Id, Lead> newMap) {
        RecordType ccsRecordType = [
                SELECT Id
                FROM RecordType
                WHERE Name = 'CCS Sales process' AND sObjectType = 'Lead'
                LIMIT 1
        ];

        Boolean isCheck = false;
        for(Lead lead: newMap.values()){
            if(lead.RecordTypeId == ccsRecordType.Id){
                isCheck = true;
            }
        }
        if(isCheck){
            //CCS Bonus
            List<CCS_Bonus__c> orderBonusArrList = [
                    SELECT Name, Lead__c
                    FROM CCS_Bonus__c
                    WHERE Lead__c IN :newMap.keySet()
                    LIMIT 50000
            ];
            Map<String, List<CCS_Bonus__c>> leadToCCSBonusMap = new Map<String, List<CCS_Bonus__c>>();
            for (CCS_Bonus__c bonus : orderBonusArrList) {
                if (!leadToCCSBonusMap.containsKey(bonus.Lead__c)) {
                    leadToCCSBonusMap.put(bonus.Lead__c, new List<CCS_Bonus__c>());
                }

                leadToCCSBonusMap.get(bonus.Lead__c).add(bonus);
            }

            //CCS Limit
            List<CCS_Limit__c> orderLimitArrList = [
                    SELECT Name, Lead__c
                    FROM CCS_Limit__c
                    WHERE Lead__c IN :newMap.keySet()
                    LIMIT 50000
            ];
            Map<String, List<CCS_Limit__c>> leadToCCSLimitMap = new Map<String, List<CCS_Limit__c>>();
            for (CCS_Limit__c ccslimit : orderLimitArrList) {
                if (!leadToCCSLimitMap.containsKey(ccslimit.Lead__c)) {
                    leadToCCSLimitMap.put(ccslimit.Lead__c, new List<CCS_Limit__c>());
                }

                leadToCCSLimitMap.get(ccslimit.Lead__c).add(ccslimit);
            }

            //CCS Carnet
            List<CCS_Carnet__c> orderCarnetArrList = [
                    SELECT Name, Lead__c
                    FROM CCS_Carnet__c
                    WHERE Lead__c IN :newMap.keySet()
                    LIMIT 50000
            ];
            Map<String, List<CCS_Carnet__c>> leadToCCSCarnetMap = new Map<String, List<CCS_Carnet__c>>();
            for (CCS_Carnet__c carnet : orderCarnetArrList) {
                if (!leadToCCSCarnetMap.containsKey(carnet.Lead__c)) {
                    leadToCCSCarnetMap.put(carnet.Lead__c, new List<CCS_Carnet__c>());
                }

                leadToCCSCarnetMap.get(carnet.Lead__c).add(carnet);
            }

            List<CCS_Bonus__c> listToUpdateCCSBonus = new List<CCS_Bonus__c>();
            List<CCS_Limit__c> listToUpdateCCSLimit = new List<CCS_Limit__c>();
            List<CCS_Carnet__c> listToUpdateCCSCarnet = new List<CCS_Carnet__c>();

            for (Lead lead : newMap.values()) {
                if (lead.IsConverted == true &&
                        oldMap.get(lead.Id).isConverted == false &&
                        lead.RecordTypeId == ccsRecordType.Id) {
                    //CCS Bonus
                    if (leadToCCSBonusMap.containsKey(lead.Id)) {
                        for (CCS_Bonus__c orderBonus : leadToCCSBonusMap.get(lead.Id)) {
                            orderBonus.Klient__c = lead.ConvertedAccountId;
                            orderBonus.Prilezitost__c = lead.ConvertedOpportunityId;
                            listToUpdateCCSBonus.add(orderBonus);
                        }
                    }

                    //CCS LIMIT
                    if (leadToCCSLimitMap.containsKey(lead.Id)) {
                        for (CCS_Limit__c orderLimit : leadToCCSLimitMap.get(lead.Id)) {
                            orderLimit.Klient__c = lead.ConvertedAccountId;
                            orderLimit.Prilezitost__c = lead.ConvertedOpportunityId;
                            listToUpdateCCSLimit.add(orderLimit);
                        }
                    }

                    //CCS Carnet
                    if (leadToCCSCarnetMap.containsKey(lead.Id)) {
                        for (CCS_Carnet__c orderCarnet : leadToCCSCarnetMap.get(lead.Id)) {
                            orderCarnet.Klient__c = lead.ConvertedAccountId;
                            orderCarnet.Prilezitost__c = lead.ConvertedOpportunityId;
                            listToUpdateCCSCarnet.add(orderCarnet);
                        }
                    }
                }
            }
            update listToUpdateCCSBonus;
            update listToUpdateCCSLimit;
            update listToUpdateCCSCarnet;
        }
    }


    public static void updateDisqualifiedLeadFields(Map<Id, Lead> oldMap, Map<Id, Lead> newMap) {
        for (Lead l : newMap.values()) {
            if (l.Status != oldMap.get(l.Id).Status && l.Status == 'Disqualified') {
                l.OLD_Quali_Status__c = l.Quali_Status__c;
                l.OLD_Service_Other_specific__c = l.Service_Sonstiges_specific__c;
                l.OLD_Why_not_interested__c = l.warum_kein_Interesse__c;
            }
            if (l.Status == 'Disqualified' &&
                    (l.Quali_Status__c != oldMap.get(l.Id).Quali_Status__c ||
                            l.Service_Sonstiges_specific__c != oldMap.get(l.Id).Service_Sonstiges_specific__c ||
                            l.warum_kein_Interesse__c != oldMap.get(l.Id).warum_kein_Interesse__c)) {

                l.OLD_Quali_Status__c = l.Quali_Status__c;
                l.OLD_Service_Other_specific__c = l.Service_Sonstiges_specific__c;
                l.OLD_Why_not_interested__c = l.warum_kein_Interesse__c;
            }
        }
    }


    public static void setStatusForRecordType(List<Lead> newList) {
        for (Lead lead : newList) {
            if (lead.RecordTypeId == '0120O000000jmuLQAQ' && lead.Source_of_Lead__c == 'Партнерская Программа') {
                lead.Status = 'NEW - Not Yet Contacted';
            }
        }
    }


    public static void populateCCSTelesalesOperator(Map<Id, Lead> oldMap, List<Lead> newList) {
        RecordType ccsRecordType = [
                SELECT Id
                FROM RecordType
                WHERE Name = 'CCS Sales process' AND sObjectType = 'Lead'
                LIMIT 1
        ];
        Set<Id> ownerIds = new Set<Id>();
        for (Lead record : newList) {
            if(record.RecordTypeId == ccsRecordType.Id){
                ownerIds.add(record.OwnerId);
            }
        }

        if(ownerIds.size() > 0){
            Map<Id, User> userMap = new Map<Id, User>([
                    SELECT UserRole.Name
                    FROM User
                    WHERE Id IN :ownerIds
            ]);

            for (Lead lead : newList) {
                if (lead.RecordTypeId == ccsRecordType.Id &&
                        lead.OwnerId.getSObjectType() == User.sObjectType) {
                    User owner = userMap.get(lead.OwnerId);

                    if (lead.CCS_Telesales_Operator__c == null) {
                        lead.CCS_Telesales_Operator__c = lead.OwnerId;
                    } else if (lead.OwnerId != oldMap.get(lead.Id).OwnerId &&
                            owner.UserRole.Name == 'CCS Salesteam Inbound' && oldMap != null) {
                        lead.CCS_Telesales_Operator__c = lead.OwnerId;
                    }
                }
            }
        }
    }

    public static void validateCountry(List<Lead> newLeads) {
        for (Lead currentLead : newLeads) {
            if (validCountriesMap.containsKey(currentLead.Country)) {
                currentLead.Country = validCountriesMap.get(currentLead.Country);
            }
        }
    }

    /*******************************************************************************
      *  Name            : updateLastOwnerChangeDateRUS()
      *  Summary         : insert lead, set Last_Date_Change_Owner_RUS__c
      *  CreatedDate     : 20.11.2017
      *  Parameters      : List<Lead> newLeads
      *  Returns         : -
      ******************************************************************************/
    public static void insertLastOwnerChangeDateRUS(List<Lead> newLeads) {
        Set<id> idRecordTypesRussianSales = getRussianSalesRecordType();
        for (Lead l : newLeads) {
            if (idRecordTypesRussianSales.contains(l.RecordTypeId)) {
                l.Last_Owner_Change_Date_RUS__c = Datetime.now();
            }
        }
    }

    /*******************************************************************************
    *  Name            : updateLastOwnerChangeDateRUS()
    *  Summary         : update lead, set Last_Date_Change_Owner_RUS__c to Opportunity
    *  CreatedDate     : 20.11.2017
    *  Parameters      : List<Lead> newLeads, Map<Id, Lead> oldMap
    *  Returns         : -
    ******************************************************************************/
    public static void updateLastOwnerChangeDateRUS(List<Lead> newLeads, Map<Id, Lead> oldMap) {
        Set<id> idRecordTypesRussianSales = getRussianSalesRecordType();
        Map<Id, Lead> convertedLeadsMap = new Map<Id, Lead>();
        for (Lead l : newLeads) {
            if (idRecordTypesRussianSales.contains(l.RecordTypeId) &&
                    (l.ConvertedOpportunityId != null && oldMap.get(l.Id).ConvertedOpportunityId == null)) {
                convertedLeadsMap.put(l.ConvertedOpportunityId, l);
            }
        }

        if (!convertedLeadsMap.isEmpty()) {
            List<Opportunity> opptyToUpdateList = new List<Opportunity>();
            List<Opportunity> oppList = [SELECT Id, OwnerId, Last_Owner_Change_Date_RUS__c FROM Opportunity WHERE Id IN :convertedLeadsMap.keySet()];
            for (Opportunity opp : oppList) {
                if (opp.OwnerId == convertedLeadsMap.get(opp.Id).OwnerId) {
                    opp.Last_Owner_Change_Date_RUS__c = convertedLeadsMap.get(opp.Id).Last_Owner_Change_Date_RUS__c;
                    opptyToUpdateList.add(opp);
                }
            }
            update opptyToUpdateList;
        }
    }


    /*******************************************************************************
    *  Name            : updateBeforeLastOwnerchangeDateRUS()
    *  Summary         : update lead, set Last_Date_Change_Owner_RUS__c
    *  CreatedDate     : 20.11.2017
    *  Parameters      : Map<Id, Lead> oldMap, Map<Id, Lead> newMap
    *  Returns         : -
    ******************************************************************************/
    public static void updateBeforeLastOwnerchangeDateRUS(Map<Id, Lead> oldMap, Map<Id, Lead> newMap) {
        Set<id> idRecordTypesRussianSales = getRussianSalesRecordType();
        for (Lead lead : newMap.values()) {
            if (idRecordTypesRussianSales.contains(lead.RecordTypeId) && lead.OwnerId != oldMap.get(lead.Id).OwnerId) {
                lead.Last_Owner_Change_Date_RUS__c = Datetime.now();
            }
        }
    }


    /*******************************************************************************
    *  Name            : calculateLeadProcessingTime (Map<Id, Lead> oldMap, Map<Id, Lead> newMap)
    *  Summary         : calculating lead processing time (BEFORE UPDATE TRIGGER)
    *  CreatedDate     : 13/12/2017
    *  ModifiedDate    : -
    *  Parameters      : Map<Id, Lead> oldMap, Map<Id, Lead> newMap
    *  Returns         : void
    ******************************************************************************/
    public static void calculateLeadProcessingTime(Map<Id, Lead> oldMap, Map<Id, Lead> newMap) {
        List<Lead> processedLeadsList = new List<Lead>();
        Set<Id> currentUserOwnerLeadsIdSet = new Set<Id>();
        Set<Id> currentQueuesOwnerLeadsIdSet = new Set<Id>();
        for (Lead lead : newMap.values()) {
            if (lead.First_Call__c != oldMap.get(lead.Id).First_Call__c && lead.First_Call__c != null &&
                    ((lead.Sec_Channel__c == 'Inbound' && (lead.Channel__c == 'Internet' || lead.Channel__c == 'E-mail')) ||
                            (lead.Sec_Channel__c == 'JITB' && lead.Channel__c == 'Internet') || (lead.Sec_Channel__c == 'Partner')) &&
                    lead.LeadSource != 'Online_chat' &&
                    lead.Quali_Status__c != 'Spam' &&
                    lead.Quali_Status__c != 'Sent to support' &&
                    lead.Quali_Status__c != 'Not a legal entity' &&
                    lead.Disable_for_Processing_Time__c == FALSE) {
                processedLeadsList.add(lead);
                if (String.valueOf(lead.OwnerId).subString(0, 3) == '005') {
                    currentUserOwnerLeadsIdSet.add(lead.OwnerId);
                } else {
                    currentQueuesOwnerLeadsIdSet.add(lead.OwnerId);
                }
            }
        }
        if (!processedLeadsList.isEmpty()) {
            List<BusinessHours> businessHoursList = [
                    SELECT Id, Name, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, WednesdayEndTime, WednesdayStartTime,
                            ThursdayEndTime, ThursdayStartTime, FridayEndTime, FridayStartTime, SaturdayEndTime, SaturdayStartTime,
                            SundayEndTime, SundayStartTime
                    FROM BusinessHours
                    LIMIT 10000
            ];

            Map<String, BusinessHours> localeBusinessHoursMap = new Map<String, BusinessHours>();
            for (BusinessHours bh : businessHoursList) {
                if (bh.Name == 'CZ') {
                    localeBusinessHoursMap.put('cs_CZ', bh);
                } else if (bh.Name == 'SK') {
                    localeBusinessHoursMap.put('sk_SK', bh);
                } else if (bh.Name == 'HU') {
                    localeBusinessHoursMap.put('hu_HU', bh);
                } else if (bh.Name == 'PL') {
                    localeBusinessHoursMap.put('pl_PL', bh);
                } else if (bh.Name == 'Default') {
                    localeBusinessHoursMap.put('Default', bh);
                }
            }

            List<User> currentUserList = new List<User>();
            if (!currentUserOwnerLeadsIdSet.isEmpty()) {
                currentUserList = [
                        SELECT Id, Name, LocaleSidKey
                        FROM User
                        WHERE Id IN :currentUserOwnerLeadsIdSet
                        LIMIT 10000
                ];
            }

            List<Group> currentQueuesList = new List<Group>();
            if (!currentQueuesOwnerLeadsIdSet.isEmpty()) {
                currentQueuesList = [
                        SELECT Id
                        FROM Group
                        WHERE Id IN :currentQueuesOwnerLeadsIdSet
                        LIMIT 10000
                ];
            }

            Map<String, BusinessHours> businessHoursForUsersMap = new Map<String, BusinessHours>();
            for (User usr : currentUserList) {
                if (!currentUserList.isEmpty()) {
                    if (usr.LocaleSidKey == 'cs_CZ' || usr.LocaleSidKey == 'cs_CZ_EURO') {
                        businessHoursForUsersMap.put(usr.Id, localeBusinessHoursMap.get('cs_CZ'));
                    } else if (usr.LocaleSidKey == 'sk_SK' || usr.LocaleSidKey == 'sk_SK_EURO') {
                        businessHoursForUsersMap.put(usr.Id, localeBusinessHoursMap.get('sk_SK'));
                    } else if (usr.LocaleSidKey == 'hu_HU' || usr.LocaleSidKey == 'hu_HU_EURO') {
                        businessHoursForUsersMap.put(usr.Id, localeBusinessHoursMap.get('hu_HU'));
                    } else if (usr.LocaleSidKey == 'pl_PL' || usr.LocaleSidKey == 'pl_PL_EURO') {
                        businessHoursForUsersMap.put(usr.Id, localeBusinessHoursMap.get('pl_PL'));
                    } else {
                        businessHoursForUsersMap.put(usr.Id, localeBusinessHoursMap.get('Default'));
                    }
                }
            }

            for (Group gr : currentQueuesList) {
                if (!currentQueuesList.isEmpty()) {
                    businessHoursForUsersMap.put(gr.Id, localeBusinessHoursMap.get('Default'));
                }
            }

            for (Lead lead : processedLeadsList) {
                lead.Lead_Processing_Time__c = BusinessHours.diff(businessHoursForUsersMap.get(lead.OwnerId).Id, lead.CreatedDate, lead.First_Call__c) / 1000 / 60;
            }
        }
    }


    /*******************************************************************************
    *  Name            : getRussianSalesRecordType()
    *  Summary         : return set of RecordType for Russia
    *  CreatedDate     : 20.11.2017
    *  Parameters      : -
    *  Returns         : result
    ******************************************************************************/
    public static Set<Id> getRussianSalesRecordType() {
        Set<id> result = new Set<id>();
        if (Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Российские продажи') != null) {
            result.add(Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Российские продажи').getRecordTypeId());
        } else if (Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Russian Sales') != null) {
            result.add(Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Russian Sales').getRecordTypeId());
        }
        return result;
    }


    /*******************************************************************************
    *  Name            : sendEmailAllStarShortFormLeadDuplicates(List<Lead> newLeads)
    *  Summary         : Finding lead duplicates of AllStar short form
    *  CreatedDate     : 09/11/2017
    *  ModifiedDate    : -
    *  Parameters      : List<Lead> newLeads
    *  Returns         : -
    ******************************************************************************/
    public static void searchAllStarShortFormLeadDuplicates(List<Lead> newLeads) {
        Map<String, Lead> allAllStarShortFormLeadsMap = new Map<String, Lead>();
        Set<String> nipLeadValuesSet = new Set<String>();
        for (Lead lead : newLeads) {
            if (lead.LeadSource == 'Allstar Mondo Web Short Form' && lead.NIP__c != null) {
                allAllStarShortFormLeadsMap.put(lead.Id, lead);
                nipLeadValuesSet.add(lead.NIP__c);
            }
        }

        if (!allAllStarShortFormLeadsMap.isEmpty() && !nipLeadValuesSet.isEmpty()) {
            List<Lead> nipLeadDuplicatesList = [
                    SELECT Id, OwnerId, Status, Quali_Status__c, NIP__c, Company, FirstName, LastName, Phone, Email
                    FROM Lead
                    WHERE NIP__c IN :nipLeadValuesSet AND
                    RecordType.Name = 'Allstar' AND
                    Status != 'Disqualified'
                    LIMIT 50000
            ];

            List<Opportunity> opptyDuplicatesList = [
                    SELECT OwnerId, Account.NIP__c
                    FROM Opportunity
                    WHERE Account.NIP__c IN :nipLeadValuesSet AND
                    RecordType.Name = 'Allstar' AND
                    StageName != 'Closed Won' AND
                    StageName != 'Closed Lost'
                    LIMIT 50000
            ];

            for (Lead lead : allAllStarShortFormLeadsMap.values()) {
                for (Opportunity opp : opptyDuplicatesList) {
                    if (lead.NIP__c == opp.Account.NIP__c) {

                        lead.Status = 'Disqualified';
                        lead.Quali_Status__c = 'Auto detect';
                        break;
                    }
                }
                for (Lead l : nipLeadDuplicatesList) {
                    if (lead.NIP__c == l.NIP__c) {
                        lead.Status = 'Disqualified';
                        lead.Quali_Status__c = 'Auto detect';
                        break;
                    }
                }
            }
        }
    }


    /*******************************************************************************
    *  Name            : disqualifySpecificLeads(List<Lead> newLeads)
    *  Summary         : Disqualify leads with specific email addresses
    *  CreatedDate     : 30/11/2017
    *  ModifiedDate    : -
    *  Parameters      : List<Lead> newLeads
    *  Returns         : void
    ******************************************************************************/
    public static void disqualifySpecificLeads(List<Lead> newLeads) {
        Set<String> specificEmailAddressesSet = new Set<String>();
        List<DisqualifiedEmailAddressesOfLead__c> emailAddressesCustomSettingsList = DisqualifiedEmailAddressesOfLead__c.getall().values();
        for (DisqualifiedEmailAddressesOfLead__c cs : emailAddressesCustomSettingsList) {
            specificEmailAddressesSet.add(cs.Email__c);
        }

        for (Lead lead : newLeads) {
            if (specificEmailAddressesSet.contains(lead.Email)) {
                lead.Status = 'Disqualified';
                lead.Quali_Status__c = 'Spam';
                lead.Disable_for_Processing_Time__c = TRUE;
            }
        }
    }


    /*******************************************************************************
    *  Name            : sendEmailLeadDuplicatesAllStarShortForm(List<Lead> newLeads)
    *  Summary         : e-mail notification if a Customer that already exists in SF database as an Opportunity in non-terminal stage (Stage ≠ Closed Won) or as a Lead in any Lead Status, tries to submit a new Short
    *  CreatedDate     : 09/11/2017
    *  Parameters      : List<Lead> newLeads
    *  Returns         : void
    ******************************************************************************/
    public static void sendEmailLeadDuplicatesAllStarShortForm(List<Lead> newLeads) {
        Map<String, Lead> allAllStarShortFormLeadsMap = new Map<String, Lead>();
        Set<String> nipLeadValuesSet = new Set<String>();
        for (Lead lead : newLeads) {
            if (lead.LeadSource == 'Allstar Mondo Web Short Form' &&
                    lead.Status == 'Disqualified' && lead.Quali_Status__c == 'Auto detect' && lead.NIP__c != null) {
                allAllStarShortFormLeadsMap.put(lead.Id, lead);
                nipLeadValuesSet.add(lead.NIP__c);
            }
        }

        if (!allAllStarShortFormLeadsMap.isEmpty() && !nipLeadValuesSet.isEmpty()) {
            List<Lead> nipLeadDuplicatesList = [
                    SELECT Id, OwnerId, Status, Quali_Status__c, NIP__c, Company, FirstName, LastName, Phone, Email
                    FROM Lead
                    WHERE NIP__c IN :nipLeadValuesSet AND
                    RecordType.Name = 'Allstar' AND
                    Status != 'Disqualified'
                    LIMIT 50000
            ];

            List<Opportunity> opptyDuplicatesList = [
                    SELECT OwnerId, Account.NIP__c
                    FROM Opportunity
                    WHERE Account.NIP__c IN :nipLeadValuesSet AND
                    RecordType.Name = 'Allstar' AND
                    StageName != 'Closed Won' AND
                    StageName != 'Closed Lost'
                    LIMIT 50000
            ];

            Map<String, Lead> finalLeadsToSendEmailMap = new Map<String, Lead>();
            for (Lead lead : allAllStarShortFormLeadsMap.values()) {
                for (Opportunity opp : opptyDuplicatesList) {
                    if (!finalLeadsToSendEmailMap.containsKey(opp.OwnerId) && lead.NIP__c == opp.Account.NIP__c) {
                        finalLeadsToSendEmailMap.put(opp.OwnerId, lead);
                        break;
                    }
                }
                for (Lead l : nipLeadDuplicatesList) {
                    if (!finalLeadsToSendEmailMap.containsKey(l.OwnerId) && lead.NIP__c == l.NIP__c) {
                        finalLeadsToSendEmailMap.put(l.OwnerId, lead);
                        break;
                    }
                }
            }

            List<EmailTemplate> emailTemplateList = [
                    SELECT Id, Subject, HtmlValue, Body
                    FROM EmailTemplate
                    WHERE DeveloperName = 'Duplicate_AllStar_web_short_form'
                    LIMIT 1
            ];

            Map<String, User> recipientsMap = new Map<String, User>([
                    SELECT Id, Name, Email
                    FROM User
                    WHERE Id IN :finalLeadsToSendEmailMap.keySet() AND
                    Email != null AND
                    isActive = true
                    LIMIT 100
            ]);

            if (!emailTemplateList.isEmpty()) {
                EmailTemplate emailTemplate = emailTemplateList.get(0);
                List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
                for (String ownerId : finalLeadsToSendEmailMap.keySet()) {
                    String emailText = emailTemplate.HtmlValue;
                    List<String> addressesList = new List<String>();
                    if (recipientsMap.containsKey(ownerId)) {
                        addressesList.add(recipientsMap.get(ownerId).Email);

                        List<String> mergeFieldsList = new List<String>{
                                recipientsMap.get(ownerId).Name,
                                finalLeadsToSendEmailMap.get(ownerId).Company,
                                finalLeadsToSendEmailMap.get(ownerId).NIP__c,
                                finalLeadsToSendEmailMap.get(ownerId).FirstName,
                                finalLeadsToSendEmailMap.get(ownerId).LastName,
                                finalLeadsToSendEmailMap.get(ownerId).Phone,
                                finalLeadsToSendEmailMap.get(ownerId).Email,
                                finalLeadsToSendEmailMap.get(ownerId).Id
                        };
                        emailText = String.format(emailText, mergeFieldsList);
                        emailText = emailText.replace('null', '-');
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setToAddresses(addressesList);
                        mail.setSubject('Duplicate web form: ' + finalLeadsToSendEmailMap.get(ownerId).NIP__c);
                        mail.setHtmlBody(emailText);
                        mail.setSaveAsActivity(false);
                        mail.setCharset('UTF8');

                        allmsg.add(mail);
                    }
                }
                if (!Test.isRunningTest()) {
                    Messaging.sendEmail(allmsg);
                }
            }
        }
    }


    /*******************************************************************************
    *  Name            : validateMobilePhone(Map<Id, Lead> oldLeadsMap, List<Lead> newLeadsList)
    *  Summary         : check phone prefix
    *  CreatedDate     : 27/11/2017
    *  ModifiedDate    : 27/11/2017
    *  Parameters      : oldLeadsMap - List of old Leads values, newLeadsList - List of new Leads values
    *  Returns         : void
    ******************************************************************************/
    public static void validateMobilePhone(Map<Id, Lead> oldLeadsMap, List<Lead> newLeadsList) {
        Map<String, Mobile_Phone_Prefixes__c> mobilePhonePrefixes = Mobile_Phone_Prefixes__c.getAll();
        if (oldLeadsMap == null) {
            //Before insert
            for (Lead lead : newLeadsList) {
                if (lead.Phone != null) {
                    String phone = RemoveExtraCharacters(lead.Phone, lead.CountryCode);
                    for (String prefix : mobilePhonePrefixes.keySet()) {
                        if (lead.CountryCode == prefix.substringBefore('_') && phone.startsWith(prefix.substringAfter('_'))) {
                            lead.Is_Mobile_Phone_Valid__c = true;
                        }
                    }
                }
            }
        } else {
            //Before Update
            for (Lead lead : newLeadsList) {
                if (lead.Phone != oldLeadsMap.get(lead.Id).Phone || lead.CountryCode != oldLeadsMap.get(lead.Id).CountryCode) {
                    lead.Is_Mobile_Phone_Valid__c = false;
                    if (lead.Phone != null) {
                        String phone = RemoveExtraCharacters(lead.Phone, lead.CountryCode);
                        for (String prefix : mobilePhonePrefixes.keySet()) {
                            if (lead.CountryCode == prefix.substringBefore('_') && phone.startsWith(prefix.substringAfter('_'))) {
                                lead.Is_Mobile_Phone_Valid__c = true;
                            }
                        }
                    }
                }
            }
        }
    }


    /*******************************************************************************
    *  Name            : removeExtraCharacters(String phone)
    *  Summary         : remove extra characters to check mobile prefix
    *  CreatedDate     : 29/11/2017
    *  ModifiedDate    : 29/11/2017
    *  Parameters      : String phone - phone number
    *  Returns         : String
    ******************************************************************************/
    public static String removeExtraCharacters(String phone, String countryCode) {
        if (phone.contains(' ')) {
            phone = phone.replace(' ', '');
        }
        if (phone.contains('-')) {
            phone = phone.replace('-', '');
        }
        if (phone.contains(',')) {
            phone = phone.replace(',', '');
        }
        if (phone.contains('.')) {
            phone = phone.replace('.', '');
        }

        Set<String> phoneCodesSet;
        if (countryCode == 'PL') {
            phoneCodesSet = new Set<String>{
                    '+48', '+48(0)', '0048', '48(0)', '00048', '48', '048', '0'
            };
            for (String phoneCode : phoneCodesSet) {
                if (phone.startsWith(phoneCode)) {
                    phone = phone.removeStart(phoneCode);
                }
            }
        }

        return phone;
    }


    /*******************************************************************************
    *  Name            : setPrimaryContactPhoneField(Map<Id, Lead> newMap, Map<Id, Lead> oldMap)
    *  Summary         : set Primary_Contact_Phone__c field in Opportunity during conversion lead (AFTER UPDATE)
    *  CreatedDate     : 19/12/2017
    *  ModifiedDate    : -
    *  Parameters      : Map<Id, Lead> newMap, Map<Id, Lead> oldMap
    *  Returns         : void
    ******************************************************************************/
    public static void setPrimaryContactPhoneField(Map<Id, Lead> newMap, Map<Id, Lead> oldMap) {
        Map<Id, Lead> convertedLeadsMap = new Map<Id, Lead>();
        for (Lead lead : newMap.values()) {
            if (lead.ConvertedOpportunityId != oldMap.get(lead.Id).ConvertedOpportunityId) {
                convertedLeadsMap.put(lead.ConvertedOpportunityId, lead);
            }
        }
        if (!convertedLeadsMap.isEmpty()) {
            List<Opportunity> convertedOpportunitiesList = [
                    SELECT Primary_Contact_Phone__c
                    FROM Opportunity
                    WHERE Id IN :convertedLeadsMap.keySet()
                    LIMIT 50000
            ];

            for (Opportunity oppty : convertedOpportunitiesList) {
                oppty.Primary_Contact_Phone__c = convertedLeadsMap.get(oppty.Id).Phone;
            }
            update convertedOpportunitiesList;
        }
    }


    /*******************************************************************************
    *  Name            : activeLeadRelocationBatchChecker(Map<Id, Lead> oldMap, Map<Id, Lead> newMap)
    *  Summary         : checking active Lead Relocation Batch if changing lead status from "Open"
    *  CreatedDate     : 03/01/2018
    *  ModifiedDate    : -
    *  Parameters      : Map<Id, Lead> oldMap, Map<Id, Lead> newMap
    *  Returns         : -
    ******************************************************************************/
    public static void activeLeadRelocationBatchChecker(Map<Id, Lead> oldMap, Map<Id, Lead> newMap) {
        List<Lead> changedLeadsList = new List<Lead>();
        for (Lead lead : newMap.values()) {
            if (lead.Status != oldMap.get(lead.Id).Status && oldMap.get(lead.Id).Status == 'Open' &&
                    UserInfo.getUserId() != '0050O000006SCWoQAO' && lead.Status != 'Online_chat' && lead.Status != 'Disqualified' &&
                    (lead.Sec_Channel__c == 'Inbound' || lead.Sec_Channel__c == 'JITB' || lead.Sec_Channel__c == 'Partner')) {
                changedLeadsList.add(lead);
            }
        }

        if (!changedLeadsList.isEmpty()) {
            List<AsyncApexJob> apexJobList = [
                    SELECT Id, ApexClass.Name, CompletedDate
                    FROM AsyncApexJob
                    WHERE ApexClass.Name = 'LeadRelocationBatch' AND
                    Status != 'Aborted' AND
                    Status != 'Completed' AND
                    Status != 'Failed'
                    LIMIT 1
            ];

            if (!apexJobList.isEmpty()) {
                for (Lead lead : changedLeadsList) {
                    newMap.get(lead.Id).addError(Label.Lead_Reassign_Active_Job_Error, false);
                }
            }
        }
    }


    /*******************************************************************************
    *  Name            : updateCurrencyIsoCode(Map<Id, Lead> oldMap, List<Lead> newList)
    *  Summary         : Update the CurrencyIsoCode by countryCode
    *  CreatedDate     : 02.03.2018
    *  ModifiedDate    : -
    *  Parameters      : Map<Id, Lead> oldMap, List<Lead> newList
    *  Returns         : void
    ******************************************************************************/
    public static void updateCurrencyIsoCode(Map<Id, Lead> oldMap, List<Lead> newList) {
        if (oldMap == null) {
            // Before insert
            for (Lead lead : newList) {
                if (countryCodeToCurrencyIsoCodeMap.containsKey(lead.CountryCode) && lead.CountryCode != null) {
                    lead.CurrencyIsoCode = countryCodeToCurrencyIsoCodeMap.get(lead.CountryCode);
                }
            }
        } else {
            // Before Update
            for (Lead lead : newList) {
                if (countryCodeToCurrencyIsoCodeMap.containsKey(lead.CountryCode) && lead.CountryCode != null && oldMap.get(lead.Id).CountryCode != lead.CountryCode) {
                    lead.CurrencyIsoCode = countryCodeToCurrencyIsoCodeMap.get(lead.CountryCode);
                }
            }
        }
    }

    /*******************************************************************************************************
    *  Name            : updateLeadAZSShellOne()
    *  Summary         : update AZS SHELL fields AZS_with_Discount_1_address__c and AZS_with_Discount_1__c  on LEAD
    *  CreatedDate     : 02/03/2018
    *  ModifiedDate    : -
    *  Parameters      : List<Lead> newList
    *  Returns         : void
    *  *****************************************************************************************************/
    public static void updateLeadAZSShellOne(List<Lead> newList) {
        Set<id> idRecordTypesRussianSales = getRussianSalesRecordType();
        Set<String> azsRetailerSet = new Set<String>();
        for (Lead newLead : newList) {
            if ((newLead.PPR_AZS_Retailer__c != null) &&
                    (idRecordTypesRussianSales.contains(newLead.RecordTypeId))) {
                azsRetailerSet.add(newLead.PPR_AZS_Retailer__c);
            }
        }
        if (!azsRetailerSet.isEmpty()) {
            List<ShellTerminalAZS__c> shellTerminalAZS = [
                    SELECT name, TerminalList__c
                    FROM ShellTerminalAZS__c
                    WHERE name in :azsRetailerSet
            ];
            for (Lead newLead : newList) {
                if (newLead.PPR_AZS_Retailer__c != null) {
                    for (ShellTerminalAZS__c shell : shellTerminalAZS) {
                        if (newLead.PPR_AZS_Retailer__c == shell.name) {
                            newLead.AZS_with_Discount_1_address__c = shell.name;
                            newLead.AZS_with_Discount_1__c = shell.TerminalList__c;
                        }
                    }
                }
            }
        }
    }

    /*******************************************************************************************************
    *  Name            : updateLeadAZSShellOneTwo()
    *  Summary         : update AZS SHELL fields AZS_with_Discount_1_address__c, AZS_with_Discount_1__c and
                         AZS_with_Discount_2_address__c, AZS_with_Discount_2__con LEAD
    *  CreatedDate     : 02/03/2018s
    *  ModifiedDate    : 06/06/2018
    *  Parameters      : Map<Id, Lead> oldMap, Map<Id, Lead> newMap)
    *  Returns         : void
    *  *****************************************************************************************************/
    public static void updateLeadAZSShellOneTwo(Map<Id, Lead> oldMap, Map<Id, Lead> newMap) {
        Set<id> idRecordTypesRussianSales = getRussianSalesRecordType();
        Map<Lead, String> azsLeadsOne = new Map<Lead, String>();
        Map<Lead, String> azsLeadsTwo = new Map<Lead, String>();
        for (Lead newLead : newMap.values()) {
            Lead oldLead = oldMap.get(newLead.Id);
            if ((newLead.AZS_with_Discount_1_address__c != oldLead.AZS_with_Discount_1_address__c) &&
                    (idRecordTypesRussianSales.contains(newLead.RecordTypeId)))
                azsLeadsOne.put(newLead, newLead.AZS_with_Discount_1_address__c);

            if ((newLead.AZS_with_Discount_2_address__c != oldLead.AZS_with_Discount_2_address__c) &&
                    (idRecordTypesRussianSales.contains(newLead.RecordTypeId)))
                azsLeadsTwo.put(newLead, newLead.AZS_with_Discount_2_address__c);
        }

        if ( ! azsLeadsOne.isEmpty() || ! azsLeadsTwo.isEmpty() ) {
            Map<String, String> shellAZS = new Map<String, String>();
            for (ShellTerminalAZS__c shellTerminalAZS : [
                    SELECT name, TerminalList__c
                    FROM ShellTerminalAZS__c
                    WHERE (name IN :azsLeadsOne.values()
                    OR name IN :azsLeadsTwo.values())
            ]) {
                shellAZS.put(shellTerminalAZS.name, shellTerminalAZS.TerminalList__c);
            }

            for (Lead lead : azsLeadsOne.keySet()) {
                if (lead.AZS_with_Discount_1_address__c == null) {
                    lead.AZS_with_Discount_1__c = '';
                } else {
                    lead.AZS_with_Discount_1__c = shellAZS.get(lead.AZS_with_Discount_1_address__c);
                }
            }

            for (Lead lead : azsLeadsTwo.keySet()) {
                if (lead.AZS_with_Discount_2_address__c == null) {
                    lead.AZS_with_Discount_2__c = '';
                } else {
                    lead.AZS_with_Discount_2__c = shellAZS.get(lead.AZS_with_Discount_2_address__c);
                }
            }
        }
    }


    /******************************************************************************************************
    *  Name            : closeTasksAfterLeadClosed()
    *  Summary         : checks of the Lead Status changed to 'Disqualified', and if there are opened Tasks
    *                    closes them.
    *  CreatedDate     : 20/02/2018
    *  ModifiedDate    : -
    *  Parameters      : List<Lead> newList
    *  Returns         : void
    ********************************************************************************************************/
    public static void closeTasksAfterLeadClosed(List<Lead> newList, Map<Id, Lead> newMap) {
        isLeadClosed = false;
        String endkundeRecId = GlobalUtils.returnRecordTypeId('Lead', 'Endkunde');
        String allstarRecId = GlobalUtils.returnRecordTypeId('Lead', 'AllStar');
        String ccsSalesRecId = GlobalUtils.returnRecordTypeId('Lead', 'CCS Sales process');
        List<User> userList = [SELECT Id FROM User WHERE Name = 'Integration Administrator' LIMIT 1];

        Set<Id> leadsWithChangedStatusIds = new Set<Id>();
        for (Lead disqualLead : newList) {
            if (disqualLead.Status == 'Disqualified' &&
                    (disqualLead.RecordTypeId == endkundeRecId || disqualLead.RecordTypeId == allstarRecId || disqualLead.RecordTypeId == ccsSalesRecId)) {
                leadsWithChangedStatusIds.add(disqualLead.Id);
            }
        }

        if (leadsWithChangedStatusIds.isEmpty() || userList.isEmpty()) {
            return;
        }

        List<Task> listTasksToClose = new List<Task>();
        for (List<Task> listTasks : [
                SELECT Id, WhoId, IsClosed, OwnerId
                FROM Task
                WHERE WhoId IN :leadsWithChangedStatusIds
                AND IsClosed = False
        ]) {
            for (Task tk : listTasks) {
                Lead ld = newMap.get(tk.WhoId);
                if (tk.OwnerId == ld.OwnerId || tk.OwnerId == userList.get(0).Id) {
                    tk.Status = 'Completed';
                    listTasksToClose.add(tk);
                }
            }
        }

        if (!listTasksToClose.isEmpty()) {
            update listTasksToClose;
        }
    }

    public static Map<String, String> countryCodeToCurrencyIsoCodeMap = new Map<String, String>{
            'AT' => 'EUR',
            'BEFR' => 'EUR',
            'BENL' => 'EUR',
            'FR' => 'EUR',
            'CZ' => 'CZK',
            'DE' => 'EUR',
            'Deutschland' => 'EUR',
            'HU' => 'HUF',
            'LU' => 'EUR',
            'NL' => 'EUR',
            'Nederland' => 'EUR',
            'PL' => 'PLN',
            'Polska' => 'PLN',
            'SK' => 'EUR'
    };


    public static Map<String, String> validCountriesMap = new Map<String, String>{
            'Österreich' => 'Austria',
            'Osterreich' => 'Austria',
            'AT' => 'Austria',
            'Deutschland' => 'Germany',
            'DE' => 'Germany',
            'FR' => 'France',
            'HU' => 'Hungary',
            'Nederland' => 'Netherlands',
            'NL' => 'Netherlands',
            'Polska' => 'Poland',
            'PL' => 'Poland',
            'Luxemburg' => 'Luxembourg',
            'LU' => 'Luxembourg',
            'CZ' => 'Czech Republic',
            'SK' => 'Slovakia'
    };

    public static Set<String> shellProfileSet = new Set<String>{
            'Sales',
            'Sales Inbound'
    };

    /*******************************************************************************************************
    *  Name            : updateOpenTaskCheckbox(Map<Id, Lead> oldMap, List<Lead> newList)
    *  Summary         : update Open_Task__c field when lead owner is changed
    *  CreatedDate     : 07/05/2018
    *  ModifiedDate    : -
    *  Parameters      : Map<Id, Lead> oldMap, List<Lead> newList
    *  Returns         : void
    *****************************************************************************************************/
    public static void updateOpenTaskCheckbox(Map<Id, Lead> oldMap, Map<Id, Lead> newMap) {
        Set<Id> leadsToUpdate = new Set<Id>();
        for (Lead lead : newMap.values()) {
            if (lead.OwnerId != oldMap.get(lead.Id).OwnerId) {
                leadsToUpdate.add(lead.Id);
            }
        }

        if (leadsToUpdate.size() > 0) {
            List<Lead> leadList = [SELECT Id, (SELECT Id, OwnerId FROM Tasks WHERE IsClosed = false) FROM Lead WHERE Id in :leadsToUpdate];
            String requestUrl = System.URL.getCurrentRequestUrl().getPath();
            for (Lead lead : leadList) {
                newMap.get(lead.Id).Open_Task__c = false;
                if (lead.Tasks.size() > 0) {
                    if (requestUrl.contains('services') || requestUrl.contains('waitingJobPage')) {
                        //owner change from data loader
                        for (Task task : lead.Tasks) {
                            if (task.OwnerId.equals(newMap.get(lead.Id).OwnerId)) {
                                newMap.get(lead.Id).Open_Task__c = true;
                                break;
                            }
                        }
                    } else {
                        //owner change from lead page
                        for (Task task : lead.Tasks) {
                            if (task.OwnerId.equals(newMap.get(lead.Id).OwnerId) || task.OwnerId.equals(oldMap.get(lead.Id).OwnerId)) {
                                newMap.get(lead.Id).Open_Task__c = true;
                                break;
                            }
                        }
                    }
                }
            }
        }
    }


    /******************************************************************************************************
    *  Name            : isJITBPortalToE2ELead(Lead lead)
    *  Summary         : checks if the lead is JITB lead.
    *  CreatedDate     : 29/07/2018
    *  ModifiedDate    : -
    *  Parameters      : Lead lead
    *  Returns         : Boolean
    ********************************************************************************************************/
    public static Boolean isJITBPortalToE2ELead(Lead lead) {
        Map<String, Lead_Switched_To_E2E__c> leadSwitchToE2EMap = Lead_Switched_To_E2E__c.getall();
        String settingKey;
        if (lead.CountryCode == 'PL') {
            settingKey = 'PolandJITB';
        } else 
        if (lead.CountryCode == 'HU') {
            settingKey = 'HungaryJITB';
        } else 
        if (lead.CountryCode == 'DE') {
            settingKey = 'GermanyJITB';
        }       
        if ( ! leadSwitchToE2EMap.containsKey(settingKey) ) return false;

        if (
            lead.Sec_Channel__c == 'JITB' &&
            lead.Channel__c == 'Internet' &&
            lead.LeadSource == 'Partner' &&
            lead.Salutation != null &&
                (
                    (lead.Anzahl_der_Fahrzeuge__c != null && lead.Anzahl_der_Fahrzeuge__c >= leadSwitchToE2EMap.get(settingKey).Min_Cards__c && lead.Anzahl_der_Fahrzeuge__c <= leadSwitchToE2EMap.get(settingKey).Max_Cards__c && (lead.CountryCode == 'DE' || lead.Country == 'Germany')) ||
                    (lead.CCS_number_of_cards__c != null && lead.CCS_number_of_cards__c >= leadSwitchToE2EMap.get(settingKey).Min_Cards__c && lead.CCS_number_of_cards__c <= leadSwitchToE2EMap.get(settingKey).Max_Cards__c && ((lead.CountryCode == 'PL' || lead.Country == 'Poland') || (lead.CountryCode == 'HU' || lead.Country == 'Hungary')))
                )
            ) {
            return true;
        }
        return false;
    }


    /******************************************************************************************************
    *  Name            : prepareJITBLeadToE2E(Lead lead)
    *  Summary         : clear Steuernummer__c field value if the lead is JITBChannel lead.
    *  CreatedDate     : 29/07/2018
    *  ModifiedDate    : -
    *  Parameters      : Lead lead
    *  Returns         : void
    ********************************************************************************************************/
    public static void prepareJITBLeadToE2E(Lead lead) {
        if (lead.Steuernummer__c == 'nicht bekannt' ||
            lead.Steuernummer__c == 'unbekannt' ||
            lead.Steuernummer__c == '0') {

            lead.Steuernummer__c = '';
        }
        if (lead.Branche_NACE__c == null || lead.Branche_NACE__c == '') {
            lead.Branche_NACE__c = 'Other';
        }
        if (lead.Beschaeftigte__c == null || lead.Beschaeftigte__c == '') {
            lead.Beschaeftigte__c = '1-4';
        }
        lead.Is_External__c = false;
    }


    public static void updateRelatedLeadInDeduplication(List<Lead> newList) {

        List <Lead> listLeadWithDuplicate = new List<Lead>();
        Set<Id> leadDuplicateIds = new Set<Id>();
        Set<Id> leadIds = new Set<Id>();
        Set<Id> opportunityIds = new Set<Id>();
        for (Lead allTriggeredLead : newList) {
            if (allTriggeredLead.Lead_and_Opp_For_Dedublication__c != NULL && allTriggeredLead.Status == 'Disqualified' && allTriggeredLead.Lead_Status_Specific__c == 'Возврат в воронку') {
                listLeadWithDuplicate.add(allTriggeredLead);
                leadDuplicateIds.add(allTriggeredLead.OwnerId);
                if (allTriggeredLead.Lead_and_Opp_For_Dedublication__c.startsWith('00Q')) {
                    allTriggeredLead.Return_funnel_Lead__c = allTriggeredLead.Lead_and_Opp_For_Dedublication__c;
                    leadIds.add(allTriggeredLead.Lead_and_Opp_For_Dedublication__c);
                } else if (allTriggeredLead.Lead_and_Opp_For_Dedublication__c.startsWith('006')) {
                    allTriggeredLead.Return_funnel_Opp__c = allTriggeredLead.Lead_and_Opp_For_Dedublication__c;
                    opportunityIds.add(allTriggeredLead.Lead_and_Opp_For_Dedublication__c);
                }
            }
        }
        if (listLeadWithDuplicate.isEmpty())
            return;
        Map<Id, Id> mapUsersLead = new Map<Id, Id>();
        for (Lead leadsOwner : [Select Id, OwnerId From Lead Where id = :leadIds])
            mapUsersLead.put(leadsOwner.Id, leadsOwner.OwnerId);

        Map<Id, Id> mapUsersOppo = new Map<Id, Id>();
        for (Opportunity oppsOwner : [Select Id, OwnerId From Opportunity Where id = :opportunityIds])
            mapUsersOppo.put(oppsOwner.Id, oppsOwner.OwnerId);

        Map<Id, User> userLeadDuplicate = new Map<Id, User>([SELECT Id, UserRole.Name, Name, Manager.Email, Email FROM User WHERE Id IN (SELECT OwnerId FROM Lead WHERE Id = :leadIds)]);

        for (User emailMangerOfUser : [SELECT Id, UserRole.Name, Name, Manager.Email, Email FROM User WHERE Id IN (SELECT OwnerId FROM Opportunity WHERE Id = :opportunityIds)])
            userLeadDuplicate.put(emailMangerOfUser.Id, emailMangerOfUser);

        for (User emailMangerOfUser : [SELECT Id, UserRole.Name, Name, Manager.Email, Email FROM User WHERE Id = :leadDuplicateIds])
            userLeadDuplicate.put(emailMangerOfUser.Id, emailMangerOfUser);

        List<LinkEmailNotifyOnDeduplication__c> settingsOfEmails = LinkEmailNotifyOnDeduplication__c.getAll().values();
        List <String> emails = new List <String>();
        if (!settingsOfEmails.isEmpty()) {
            for (LinkEmailNotifyOnDeduplication__c setting : settingsOfEmails)
                emails.add(setting.Name);
        }

        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();

        for (Lead leadWithDuplicate : listLeadWithDuplicate) {

            if (userLeadDuplicate.get(leadWithDuplicate.OwnerId).Email != NULL)
                emails.add(userLeadDuplicate.get(leadWithDuplicate.OwnerId).Email);

            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.subject = 'Возврат в воронку';

            if (leadWithDuplicate.Lead_and_Opp_For_Dedublication__c.startsWith('00Q')) {
                emails.add(userLeadDuplicate.get(mapUsersLead.get(leadWithDuplicate.Lead_and_Opp_For_Dedublication__c)).Email);
                if (userLeadDuplicate.get(mapUsersLead.get(leadWithDuplicate.Lead_and_Opp_For_Dedublication__c)).Manager.Email != NULL)
                    emails.add(userLeadDuplicate.get(mapUsersLead.get(leadWithDuplicate.Lead_and_Opp_For_Dedublication__c)).Manager.Email);
                message.setToAddresses(emails);
                message.plainTextBody = 'В базе SF появился Интерес в дисквале по причине Возврата в Воронку: \n'
                        + userLeadDuplicate.get(mapUsersLead.get(leadWithDuplicate.Lead_and_Opp_For_Dedublication__c)).UserRole.Name + ' ' + userLeadDuplicate.get(mapUsersLead.get(leadWithDuplicate.Lead_and_Opp_For_Dedublication__c)).Name + '\n'
                        + 'Интерес: https://eu9.salesforce.com/' + leadWithDuplicate.Lead_and_Opp_For_Dedublication__c + '\n'
                        + 'Свяжитесь с потенциальным клиентом в кратчайшие сроки! \n \n'
                        + 'Дисквалифицированный Интерес: https://eu9.salesforce.com/' + leadWithDuplicate.Id + ' \n'
                        + userLeadDuplicate.get(leadWithDuplicate.OwnerId).UserRole.Name + ' ' + userLeadDuplicate.get(leadWithDuplicate.OwnerId).Name;
            }

            else if (leadWithDuplicate.Lead_and_Opp_For_Dedublication__c.startsWith('006')) {

                emails.add(userLeadDuplicate.get(mapUsersOppo.get(leadWithDuplicate.Lead_and_Opp_For_Dedublication__c)).Email);
                if (userLeadDuplicate.get(mapUsersOppo.get(leadWithDuplicate.Lead_and_Opp_For_Dedublication__c)).Manager.Email != NULL)
                    emails.add(userLeadDuplicate.get(mapUsersOppo.get(leadWithDuplicate.Lead_and_Opp_For_Dedublication__c)).Manager.Email);
                message.setToAddresses(emails);
                message.plainTextBody = 'В базе SF появился Интерес в дисквале по причине Возврата в Воронку: \n'
                        + userLeadDuplicate.get(mapUsersOppo.get(leadWithDuplicate.Lead_and_Opp_For_Dedublication__c)).UserRole.Name + ' ' + userLeadDuplicate.get(mapUsersOppo.get(leadWithDuplicate.Lead_and_Opp_For_Dedublication__c)).Name + '\n'
                        + 'Возможность: https://eu9.salesforce.com/' + leadWithDuplicate.Lead_and_Opp_For_Dedublication__c + '\n'
                        + 'Свяжитесь с потенциальным клиентом в кратчайшие сроки! \n \n'
                        + 'Дисквалифицированный Интерес: https://eu9.salesforce.com/' + leadWithDuplicate.Id + ' \n'
                        + userLeadDuplicate.get(leadWithDuplicate.OwnerId).UserRole.Name + ' ' + userLeadDuplicate.get(leadWithDuplicate.OwnerId).Name;
            }
            messages.add(message);
        }
        Messaging.sendEmail(messages);
    }

    public static Map<String,String> countryCodeToCountryMap = new Map<String,String>{
        'DE' => 'Germany',
        'NL' => 'Netherlands',
        'BENL' => 'Belgium-NL',
        'BEFR' => 'Belgium-FR',
        'PL' => 'Poland',
        'HU' => 'Hungary',
        'RU' => 'Russia'
    };
}