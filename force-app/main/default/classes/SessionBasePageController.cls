public with sharing class SessionBasePageController {
    public void testsession() {
        Type customType = Type.forName('E2EContactDetailsBasicImpl');
        E2EContactDetails service = (E2EContactDetails)customType.newInstance();
        service.setContent('contactDetails_DE', null);
		Cache.Session.put('local.e2e.service1', service);
    }


    public void testgetsession() {
    	E2EContactDetails serviceTest = (E2EContactDetails)Cache.Session.get('local.e2e.service1');
    	System.debug('DEBUG: serviceTest === ' + serviceTest);
    	Map<String, Object> content = serviceTest.getContent();
    	System.debug('DEBUG: content === ' + content);
    	System.debug('DEBUG: content # === ' + content.get('first_name'));
    }
}