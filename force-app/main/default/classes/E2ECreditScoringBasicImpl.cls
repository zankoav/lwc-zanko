public class E2ECreditScoringBasicImpl implements E2ECreditScoring {
    private E2ECreditScoringDAO dao;
    private Map<String, Object> content;

    public void setContent(String jsonSettings, String source) {
        StaticResource resource = [SELECT Body FROM StaticResource WHERE Name = :jsonSettings LIMIT 1];
        this.content = (Map<String, Object>)JSON.deserializeUntyped(resource.Body.toString());

        if (source != null) {
            String opportunityId = E2ENewUtils.decryptOpportunityId(source);
            this.dao = new E2ECreditScoringDAOImpl();
            this.dao.selectRecord(opportunityId);

            if ((String)this.dao.getRecord('Opportunity').get('Zahlungsart__c') != null) {
                content.put(
                    'billing_period', 
                    addParamToField(content.get('billing_period'), 'value',(String)this.dao.getRecord('Opportunity').get('Zahlungsart__c')));
            }
            if ((String)this.dao.getRecord('Opportunity').get('Rechnungsperiode__c') != null) {
                content.put(
                    'payment_method', 
                    addParamToField(content.get('payment_method'), 'value',(String)this.dao.getRecord('Opportunity').get('Rechnungsperiode__c')));
            }
            if ((String)this.dao.getRecord('Opportunity').get('CF_Credit_Limit__c') != null) {
                content.put(
                    'credit_limit', 
                    addParamToField(content.get('credit_limit'), 'value',(String)this.dao.getRecord('Opportunity').get('CF_Credit_Limit__c')));
            }
            if ((String)this.dao.getRecord('Opportunity').get('Security_Amount_To_Pay__c') != null) {
                content.put(
                    'deposit', 
                    addParamToField(content.get('deposit'), 'value',(String)this.dao.getRecord('Opportunity').get('Security_Amount_To_Pay__c')));
            }
        }
    }

    public Map<String, Object> getContent() {
        return this.content;
    }

    public void validate(Map<String, Object> data) {
    	
    }

    public void calculateDeposit(Map<String, Object> data) {
    	
    }

    public void save(Map<String, Object> data) {
        this.dao.updateRecords(data);
    }

    private Object addParamToField(Object field, String parameter, String value) {
        Map<String, Object> fieldMap = (Map<String, Object>)field;
        fieldMap.put(parameter,  value);
        return fieldMap;
    }

    private void validateField(String fieldValue, String regex) {
        Pattern lettersPattern = Pattern.compile(regex);
        Matcher lettersMatcher = lettersPattern.matcher(fieldValue);
        if ( ! lettersMatcher.matches() || fieldValue == '' || fieldValue == null) {
            throw new E2EException('Invalid field ' + fieldValue);
        }
    }

    private String returnFieldValue(Object field, String parameter) {
        return (String)((Map<String, Object>)field).get(parameter);
    }
}