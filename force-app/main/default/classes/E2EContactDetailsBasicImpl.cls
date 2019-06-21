public class E2EContactDetailsBasicImpl implements E2EContactDetails {    
    public E2EContactDetailsDAO dao;
    private Map<String, Object> content;

    public void setContent(String jsonSettings, String source) {
        StaticResource resource = [SELECT Body FROM StaticResource WHERE Name = :jsonSettings LIMIT 1];
        this.content = (Map<String, Object>)JSON.deserializeUntyped(resource.Body.toString());

        if (source != null) {
            String opportunityId = E2ENewUtils.decryptOpportunityId(source);
            this.dao = new E2EContactDetailsDAOImpl();
            this.dao.selectRecord(opportunityId);
            List<OpportunityContactRole> oppContactRoles = (List<OpportunityContactRole>)this.dao.getRecord('Opportunity').getSObjects('OpportunityContactRoles');
            String contactId = oppContactRoles.get(0).ContactId;
            this.dao.selectRecord(contactId);

            content.put(
                'salutation', 
                addParamToField(content.get('salutation'), 'value',(String)this.dao.getRecord('Contact').get('Salutation')));
            content.put(
                'first_name', 
                addParamToField(content.get('first_name'), 'value',(String)this.dao.getRecord('Contact').get('FirstName')));            
            content.put(
                'last_name', 
                addParamToField(content.get('last_name'), 'value',(String)this.dao.getRecord('Contact').get('LastName')));
            content.put(
                'phone', 
                addParamToField(content.get('phone'), 'value',(String)this.dao.getRecord('Contact').get('Phone')));
            content.put(
                'email', 
                addParamToField(content.get('email'), 'value',(String)this.dao.getRecord('Contact').get('Email')));
            content.put(
                'business_type', 
                addParamToField(content.get('business_type'), 'value',(String)this.dao.getRecord('Opportunity').get('E2E_Form_of_Business__c')));
            content.put(
                'number_of_cards', 
                addParamToField(content.get('number_of_cards'), 'value',(String)this.dao.getRecord('Opportunity').get('Anzahl_der_Karten__c')));
            content.put(
                'news_agreement', 
                addParamToField(content.get('news_agreement'), 'value',(String)this.dao.getRecord('Opportunity').get('Agree_to_Privacy_Policy__c')));
        }
    }


    public Map<String, Object> getContent() {
        return this.content;
    }

    public void save(Map<String, Object> data) {
        data.put('phone',returnPhone((String)data.get('phone'),'Germany'));
        if (this.dao != null) {
            // update
            this.dao.updateRecords(data);
        } else {
            this.dao = new E2EContactDetailsDAOImpl();
            this.dao.insertRecords(data);
        }
        Cookie sourceCookie = new Cookie('source', (String)this.dao.getRecord('Opportunity').get('E2E_Encoded_URL__c'), null, 315569260, false);
        ApexPages.currentPage().setCookies(new Cookie[]{sourceCookie});
    }

    public void validate(Map<String, Object> data) {
        validateField((String)data.get('first_name'), returnFieldValue(content.get('first_name'),'validationRegex'));
        validateField((String)data.get('last_name'), returnFieldValue(content.get('last_name'),'validationRegex'));
        validateField((String)data.get('email'), returnFieldValue(content.get('email'),'validationRegex'));
        validateField((String)data.get('phone'), returnFieldValue(content.get('phone'),'validationRegex'));
        validateField((String)data.get('business_type'), returnFieldValue(content.get('business_type'),'validationRegex'));
    }

    private void validateField(String fieldValue, String regex) {
        if (regex == null) {
            System.debug('DEBUG: EXCEPTION EMPTY REGEX === ');
            return;
        }
        Pattern lettersPattern = Pattern.compile(regex);
        Matcher lettersMatcher = lettersPattern.matcher(fieldValue);
        if ( ! lettersMatcher.matches() || fieldValue == '' || fieldValue == null) {
            throw new E2EException('Invalid field value' + fieldValue + ', regex: ' + regex);
        }
    }

    private String returnFieldValue(Object field, String parameter) {
        return String.valueOf(((Map<String, Object>)field).get(parameter));
    }

    private Object addParamToField(Object field, String parameter, String value) {
        Map<String, Object> fieldMap = (Map<String, Object>)field;
        fieldMap.put(parameter,  value);
        return fieldMap;
    }

    private String returnPhone(String phone, String country) {
        if (country == 'Germany' && phone != null && phone.contains('+490')) {
            phone = phone.replace('+490','+49');
        }

        return phone;
    }
}