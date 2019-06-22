public class E2ECreditScoringBasicImpl implements E2ECreditScoring {
    private Map<String, Object> content;

    public void selectContent(String jsonSettings, String source) {
        E2ECreditScoringDao dao = new E2ECreditScoringDaoImpl();
        dao.selectSettings(jsonSettings);        
        StaticResource settings = (StaticResource)dao.getSettings();
        this.content = (Map<String, Object>)JSON.deserializeUntyped(settings.Body.toString());

        if (source != null) {
            this.content = dao.addDataFromDatabase(content, source);
        }
        setCreditLimits(true);
        System.debug('DEBUG: this.content === ' + this.content.get('payment_method'));
    }

    public Map<String, Object> getContent() {
        return this.content;
    }

    public void setContent(Map<String, Object> data) {
        this.content = data;
    }

    public void save() {
        E2ECreditScoringDAO dao = new E2ECreditScoringDaoImpl();
        dao.updateRecords(this.content);
    }

    public void changeBillingPeriod(String billing_period) {
        content.put('billing_period', addParamToField(content.get('billing_period'), 'value', billing_period));
        setCreditLimits(false);
    }

    public void changeCreditLimit(Map<String, Object> data) {
        String opportunityId = (String)data.get('opportunity_id');
        CreditFactoryReportController cfReportCtrl = new CreditFactoryReportController();
        cfReportCtrl.creditService = new CreditSystemService();
        cfReportCtrl.creditService.setCreditSystemSource(opportunityId);
        String creditSystemName = cfReportCtrl.creditService.getCreditSystemName();
        cfReportCtrl.reportService = cfReportCtrl.returnReportService(creditSystemName, opportunityId);
        
        CreditCompany company = new CreditCompany();
        company.classRating = (String)data.get('class_rating');
        company.dateoffoundation = (String)data.get('date_of_foundation');

        cfReportCtrl.reportService.resetDeposit(
                                                company, 
                                                Integer.valueOf(returnFieldValue(content.get('billing_period'),'value')), 
                                                null, 
                                                Decimal.valueOf(returnFieldValue(content.get('credit_limit'),'value')), 
                                                Decimal.valueOf(String.valueOf(data.get('credit_limit_max'))), 
                                                Decimal.valueOf(String.valueOf(data.get('monthly_volume'))),
                                                Decimal.valueOf(String.valueOf(data.get('total_consumption'))),
                                                opportunityId);
        Decimal deposit = cfReportCtrl.reportService.getDeposit();
        content.put('deposit', addParamToField(data.get('deposit'), 'value', String.valueOf(deposit)));
    }

    public void save(Map<String, Object> data) {
        E2ECreditScoringDAO dao = new E2ECreditScoringDaoImpl();
        dao.updateRecords(data);
    }

    private Object addParamToField(Object field, String parameter, String value) {
        String jsonStr = JSON.serialize(field);
        System.debug('DEBUG: jsonStr === ' + jsonStr);
        Map<String, Object> fieldTemp = (Map<String, Object>)JSON.deserializeUntyped(jsonStr);
        // Map<String, Object> fieldMap = (Map<String, Object>)field;
        fieldTemp.put(parameter,  value);
        return fieldTemp;
    }

    private void setCreditLimits(Boolean isInit) {
        System.debug('DEBUG: 555 === ' + content.get('credit_limit'));
        if (returnFieldValue(content.get('billing_period'),'value') == '7') {
            if ( ! isInit ) {
                content.put('credit_limit', addParamToField(content.get('credit_limit'), 'value', String.valueOf(content.get('credit_limit_min_7'))));
            }
            content.put('credit_limit_min', String.valueOf(content.get('credit_limit_min_7')));
            content.put('credit_limit_max', String.valueOf(content.get('credit_limit_max_7')));
            content.put('max_value', String.valueOf(content.get('max_value_7')));
            content.put('deposit', addParamToField(content.get('deposit'), 'value',String.valueOf(content.get('deposit_7'))));
        } else 
        if (returnFieldValue(content.get('billing_period'),'value') == '15') {
            if ( ! isInit ) {
                content.put('credit_limit', addParamToField(content.get('credit_limit'), 'value', String.valueOf(content.get('credit_limit_min_7'))));
            }
            content.put('credit_limit_min', String.valueOf(content.get('credit_limit_min_15')));
            content.put('credit_limit_max', String.valueOf(content.get('credit_limit_max_15')));
            content.put('max_value', String.valueOf(content.get('max_value_15')));
            content.put('deposit', addParamToField(content.get('deposit'), 'value',String.valueOf(content.get('deposit_15'))));
        } else 
        if (returnFieldValue(content.get('billing_period'),'value') == '30') {
            if ( ! isInit ) {
                content.put('credit_limit', addParamToField(content.get('credit_limit'), 'value', String.valueOf(content.get('credit_limit_min_7'))));
            }
            content.put('credit_limit_min', String.valueOf(content.get('credit_limit_min_30')));
            content.put('credit_limit_max', String.valueOf(content.get('credit_limit_max_30')));
            content.put('max_value', String.valueOf(content.get('max_value_30')));
            content.put('deposit', addParamToField(content.get('deposit'), 'value',String.valueOf(content.get('deposit_30'))));
        }
        System.debug('DEBUG: 777 === ' + content.get('credit_limit'));
    }


    private void validateField(String fieldValue, String regex) {
        Pattern lettersPattern = Pattern.compile(regex);
        Matcher lettersMatcher = lettersPattern.matcher(fieldValue);
        if ( ! lettersMatcher.matches() || fieldValue == '' || fieldValue == null) {
            throw new E2EException('Invalid field ' + fieldValue);
        }
    }

    private String returnFieldValue(Object field, String parameter) {
        String jsonStr = JSON.serialize(field);
        Map<String, Object> fieldTemp = (Map<String, Object>)JSON.deserializeUntyped(jsonStr);
        return String.valueOf(((Map<String, Object>)fieldTemp).get(parameter));
    }
}