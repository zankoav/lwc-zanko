public class E2ECreditScoringDAOImpl implements E2ECreditScoringDAO {
    private Map<String, SObject> sobjectsMap;
    private Sobject jsonSettings;
    private Map<String, String> soqlFieldsMap = new Map<String, String>{
        'Opportunity' => 'E2E_Encoded_URL__c, Name, AccountId, E2E_Active_Step__c, Zahlungsart__c, Rechnungsperiode__c, CF_Credit_Limit__c, Security_Amount_To_Pay__c,' +
                          'Auftragsvolumen__c, Total_consumption_l_month__c, Credit_Limit__c,' +
                         '(SELECT Name, Name__c, Age_of_Company__c, City__c, Class_Rating__c, Company_Id__c, Company_Status__c, Country__c, County_Court__c, ' + 
                                      'Credit_Decision__c, Credit_Limit__c, Credit_Limit_Currency__c, Credit_System_Number__c, Date_Last_Register_Entry__c, ' + 
                                      'Date_Legal_Form__c, Date_of_Foundation__c, Email__c, Fax__c, First_Legal_Form__c, Fiscal_Number__c, Housenumber__c, Legal_Form__c,' +
                                      'Mobile__c, Obligation_Overdue__c, Opportunity__c, Order_Situation__c, Payment_Behaviour__c, Phone__c, Postcode__c, Reference_Number__c, ' + 
                                      'Register_Number__c, Request_Status__c, Solvency_Index__c, Staff_Range__c, Street__c, Tax_Id__c, Trade_Name__c, Turn_Over__c, VAT_Number__c, ' + 
                                      'Website__c, Billing_Period__c, Credit_Limit_Default__c, Credit_Limit_Weekly_7__c, Credit_Limit_Bi_Weekly_7__c, Credit_Limit_Monthly_7__c, ' + 
                                      'Max_Credit_Limit_Weekly_7__c, Max_Credit_Limit_Bi_Weekly_7__c, Max_Credit_Limit_Monthly_7__c, Max_Value_Weekly_7__c, Max_Value_Bi_Weekly_7__c, ' + 
                                      'Max_Value_Monthly_7__c, Deposit_Weekly_7__c, Deposit_Bi_Weekly_7__c, Deposit_Monthly_7__c, Decision_Verdict__c, Decision_Status_Code__c ' + 
                            'FROM Credit_Factory_Reports__r WHERE RecordType.Name = \'Default\')'
    };

    public E2ECreditScoringDAOImpl() {
        this.sobjectsMap = new Map<String, SObject>();
    }

    public void selectSettings(String name) {
        this.jsonSettings = [SELECT Body FROM StaticResource WHERE Name = :name LIMIT 1];
    }

    public Sobject getSettings() {
        return this.jsonSettings;
    }

    public Map<String, Object> addDataFromDatabase(Map<String, Object> originalContent, String source) {
        String opportunityId = E2ENewUtils.decryptOpportunityId(source);            
        selectRecord(opportunityId);

        Opportunity opportunity = (Opportunity)getRecord('Opportunity');
        originalContent.put('opportunity_id', opportunity.Id);
        originalContent.put('account_id', opportunity.AccountId);
        // originalContent.put('billing_period', opportunity.Zahlungsart__c);
        if (opportunity.Zahlungsart__c != null) {
            originalContent.put('payment_method', addParamToField(originalContent.get('payment_method'), 'value', opportunity.Zahlungsart__c));
        }        
        // originalContent.put('credit_limit', opportunity.CF_Credit_Limit__c);
        if (opportunity.Security_Amount_To_Pay__c != null) {
            originalContent.put('deposit', addParamToField(originalContent.get('deposit'), 'value', String.valueOf(opportunity.Security_Amount_To_Pay__c)));
        }        
        if (opportunity.Rechnungsperiode__c != null) {
            originalContent.put('billing_period', addParamToField(originalContent.get('billing_period'), 'value', String.valueOf(opportunity.Rechnungsperiode__c))); 
        } else {
            originalContent.put('billing_period', addParamToField(originalContent.get('billing_period'), 'value', String.valueOf(opportunity.Credit_Factory_Reports__r.get(0).Billing_Period__c))); 
        }   
        System.debug('DEBUG: opportunity.CF_Credit_Limit__c === ' + opportunity.CF_Credit_Limit__c);     
        if (opportunity.CF_Credit_Limit__c != null) {
            System.debug('DEBUG: INNER === ');
            originalContent.put('credit_limit', addParamToField(originalContent.get('credit_limit'), 'value', String.valueOf(opportunity.CF_Credit_Limit__c)));     
            System.debug('DEBUG: ### === ' + originalContent.get('credit_limit'));
        } else {
            originalContent.put('credit_limit', addParamToField(originalContent.get('credit_limit'), 'value', String.valueOf(opportunity.Credit_Factory_Reports__r.get(0).Credit_Limit_Default__c)));     
        }
        
        // originalContent.put('credit_limit_default', addParamToField(originalContent.get('credit_limit'), 'value', String.valueOf(opportunity.Credit_Factory_Reports__r.get(0).Credit_Limit_Default__c))); 
        originalContent.put('credit_limit_min_7', opportunity.Credit_Factory_Reports__r.get(0).Credit_Limit_Weekly_7__c); 
        originalContent.put('credit_limit_min_15', opportunity.Credit_Factory_Reports__r.get(0).Credit_Limit_Bi_Weekly_7__c); 
        originalContent.put('credit_limit_min_30', opportunity.Credit_Factory_Reports__r.get(0).Credit_Limit_Monthly_7__c); 
        originalContent.put('credit_limit_max_7', opportunity.Credit_Factory_Reports__r.get(0).Max_Credit_Limit_Weekly_7__c); 
        originalContent.put('credit_limit_max_15', opportunity.Credit_Factory_Reports__r.get(0).Max_Credit_Limit_Bi_Weekly_7__c); 
        originalContent.put('credit_limit_max_30', opportunity.Credit_Factory_Reports__r.get(0).Max_Credit_Limit_Monthly_7__c); 
        originalContent.put('max_value_7', opportunity.Credit_Factory_Reports__r.get(0).Max_Value_Weekly_7__c); 
        originalContent.put('max_value_15', opportunity.Credit_Factory_Reports__r.get(0).Max_Value_Bi_Weekly_7__c); 
        originalContent.put('max_value_30', opportunity.Credit_Factory_Reports__r.get(0).Max_Value_Monthly_7__c); 
        originalContent.put('deposit_7', opportunity.Credit_Factory_Reports__r.get(0).Deposit_Weekly_7__c); 
        originalContent.put('deposit_15', opportunity.Credit_Factory_Reports__r.get(0).Deposit_Bi_Weekly_7__c); 
        originalContent.put('deposit_30', opportunity.Credit_Factory_Reports__r.get(0).Deposit_Monthly_7__c); 
        originalContent.put('class_rating', opportunity.Credit_Factory_Reports__r.get(0).Class_Rating__c); 
        originalContent.put('date_of_foundation', opportunity.Credit_Factory_Reports__r.get(0).Date_of_Foundation__c);
        originalContent.put('monthly_volume', opportunity.Auftragsvolumen__c);         
        originalContent.put('total_consumption', opportunity.Total_consumption_l_month__c);         
        System.debug('DEBUG: originalContent === ' + originalContent.get('credit_limit'));
        return originalContent;
    }

    public void updateRecords(Map<String, Object> data) {
        System.debug('DEBUG: data === ' + data);
        AccountTriggerHandler.enablesTrigger = false;
        ContactTriggerHandler.enablesTrigger = false;
        OpportunityTriggerHandler.enablesTrigger = false;
        OpportunityTriggerHandler.isE2EForm = true;
        TankkartenHandler.enablesTrigger = false;
        System.debug('DEBUG: updateRecords data === ' + data);
        Opportunity opportunity = new Opportunity();
        opportunity.Id = (String)data.get('opportunity_id');
        opportunity.Zahlungsart__c = returnFieldValue(data.get('payment_method'),'value');
        opportunity.Rechnungsperiode__c = returnFieldValue(data.get('billing_period'),'value');
        opportunity.CF_Credit_Limit__c = Decimal.valueOf(returnFieldValue(data.get('credit_limit'),'value'));
        opportunity.Zahlungsziel_Credit__c = '7';
        opportunity.bearbeitet_von__c = 'Autoprocessed by E2E';
        opportunity.Credit_check_date__c = Date.today();
        if (returnFieldValue(data.get('deposit'),'value') != null && returnFieldValue(data.get('deposit'),'value') != '0') {
            opportunity.Security_To_Pay__c = 'Kaution';
            opportunity.Security_Amount_To_Pay__c = Decimal.valueOf(returnFieldValue(data.get('deposit'),'value'));
            opportunity.Kredit_Entscheidung__c = 'Sicherheit verlangt';
            opportunity.Billing_Period_by_Sales__c = true;
            opportunity.Pending_Deposit_by_CF__c = true;
            opportunity.CF_Stage__c = 'Pending deposit';
            opportunity.Max_Credit_Limit__c = Decimal.valueOf(returnFieldValue(data.get('credit_limit'),'value'));

            if ((String)data.get('class_rating') == '4') {
                opportunity.Security_level_H_he_der_Sicherheit__c = 4;
            } else 
            if ((String)data.get('class_rating') == '5') {
                opportunity.Security_level_H_he_der_Sicherheit__c = 70;
            } else 
            if ((String)data.get('class_rating') == '6') {
                opportunity.Security_level_H_he_der_Sicherheit__c = 110;
            } else 
            if (data.get('class_rating') == null) {
                opportunity.Credit_System_Rating__c = 'Keine Bonität';
                opportunity.Security_level_H_he_der_Sicherheit__c = 100;
            }
        } else {
            opportunity.Security_To_Pay__c = '';
            opportunity.Garantie__c = '';
            opportunity.Kredit_Entscheidung__c = 'Genehmigt';
            if (opportunity.Rechnungsperiode__c == '7') {
                opportunity.Max_Credit_Limit__c = Decimal.valueOf((String)data.get('credit_limit_max_7'));
            } else 
            if (opportunity.Rechnungsperiode__c == '15') {
                opportunity.Max_Credit_Limit__c = Decimal.valueOf((String)data.get('credit_limit_max_15'));
            } else 
            if (opportunity.Rechnungsperiode__c == '30') {
                opportunity.Max_Credit_Limit__c = Decimal.valueOf((String.valueOf(data.get('credit_limit_max_30'))));
            }

            if (data.get('class_rating') == null) {
                opportunity.Credit_System_Rating__c = '0-EX';
            }
        }
        if (data.get('class_rating') != null) {
           if ((String)data.get('class_rating') == '1' || (String)data.get('class_rating') == '2') {
               opportunity.Buffer__c = 30;
               opportunity.Risk_Category__c = 'Low';
           } else 
           if ((String)data.get('class_rating') == '3') {
               opportunity.Buffer__c = 20;
               opportunity.Risk_Category__c = 'Medium';
           } else 
           if ((String)data.get('class_rating') == '4' || (String)data.get('class_rating') == '5') {
                opportunity.Buffer__c = 10;
                opportunity.Risk_Category__c = 'High';
           } else 
           if ((String)data.get('class_rating') == '6') {
                opportunity.Buffer__c = 0;
                opportunity.Risk_Category__c = 'Very';
           }
        } else {
           opportunity.Buffer__c = 10;
           opportunity.Risk_Category__c = 'High';
        }

        if (opportunity.Zahlungsart__c == 'Lastschrift') {
            if (Integer.valueOf(data.get('total_consumption')) <= 1500) {
                opportunity.Direct_Debit_Mandate_Type__c = 'Core';
            } else {
                if (opportunity.Risk_Category__c == 'Low') {
                    opportunity.Direct_Debit_Mandate_Type__c = 'Core';
                } else {
                    opportunity.Direct_Debit_Mandate_Type__c = 'B2B';
                }
            }
        } else if (opportunity.Zahlungsart__c == 'Banküberweisung') {
            opportunity.Direct_Debit_Mandate_Type__c = '';
        }
        opportunity.E2E_Last_Activity__c = Datetime.now();
        List<User> e2eUser = [SELECT Id FROM User WHERE Name = 'E2E Site Guest User' LIMIT 1];
        if ( ! e2eUser.isEmpty() ) {
            opportunity.OwnerId = e2eUser.get(0).Id;
        }
        opportunity.StageName = 'Credit Approved';
        opportunity.E2E_Active_Step__c = 5;
        System.debug('DEBUG: opportunity === ' + opportunity);
        update opportunity;
    }

    private Object addParamToField(Object field, String parameter, String value) {
        Map<String, Object> fieldMap = (Map<String, Object>)field;
        fieldMap.put(parameter,  value);
        return fieldMap;
    }

    private String returnFieldValue(Object field, String parameter) {
        String jsonStr = JSON.serialize(field);
        Map<String, Object> fieldTemp = (Map<String, Object>)JSON.deserializeUntyped(jsonStr);
        return String.valueOf(((Map<String, Object>)fieldTemp).get(parameter));
    }

    private void selectRecord(String recordId) {
        String sobjectName = getSobjectName(recordId);
        String query = 'SELECT ' + soqlFieldsMap.get(sobjectName) + ' FROM ' + sobjectName + ' WHERE Id = :recordId';
        SObject record = Database.query(query);
        this.sobjectsMap.put(sobjectName, record);
    }

    private SObject getRecord(String sobjectName) {
        return sobjectsMap.get(sobjectName);
    }


    private String getSobjectName(String recordIdStr) {
        Id recordId = Id.valueOf(recordIdStr);
        String sobjectName = String.valueOf(recordId.getSobjectType());

        return sobjectName;
    }

    private void disableTriggers() {
        AccountTriggerHandler.enablesTrigger = false;
        ContactTriggerHandler.enablesTrigger = false;
        OpportunityTriggerHandler.enablesTrigger = false;
        OpportunityTriggerHandler.isE2EForm = true;
    }
}