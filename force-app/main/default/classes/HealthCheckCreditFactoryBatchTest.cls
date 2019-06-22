@isTest
private class HealthCheckCreditFactoryBatchTest {


	/*******************************************************************************
	*  Name            : testGermanCreditFactoryCheck()
	*  Summary         : Test availability check of Credit Factory for Germany
	*  CreatedDate     : 09/01/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	@isTest
    static void testGermanCreditFactoryCheck() {
    	Health_Check_Credit_Factory__c healthCheck = new Health_Check_Credit_Factory__c(
    		Name = 'DE',
    		Country__c = 'Germany',
    		City__c = 'Weimar',
    		Name__c = 'Kundentestsystem Stadt 1 - BITTE NICHT ÄNDERN',
    		Id__c = '03453452013903');
    	insert healthCheck;

    	CreditSystem__c creditSystem = new CreditSystem__c(
            Name = 'Creditreform',
            Endpoint__c = 'https://ktu.onlineservice.creditreform.de:443/webservice/0520-0018/soap12/messages.wsdl', 
            Username__c = '345013323001', 
            Password__c = '1ppf39vE',
            Supported_Countries__c = 'Germany',
            API_Key__c = 'CFflt123');
        insert creditSystem;

    	HealthCheckCreditFactoryBatch batch = new HealthCheckCreditFactoryBatch();

    	Test.startTest();
    		Test.setMock(HttpCalloutMock.class, new HealthCheckCreditFactoryMockDE());
    		Database.executeBatch(batch);
    	Test.stopTest();

    	List<Health_Check__c> healthCheckList = [
    	        SELECT Id
    	        FROM Health_Check__c];

    	System.assertEquals(0, healthCheckList.size());
    }


    /*******************************************************************************
	*  Name            : testNetherlandsCreditFactoryCheck()
	*  Summary         : Test availability check of Credit Factory for Netherlands
	*  CreatedDate     : 09/01/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	@isTest
    static void testNetherlandsCreditFactoryCheck() {
    	Health_Check_Credit_Factory__c healthCheck = new Health_Check_Credit_Factory__c(
    		Name = 'NL',
    		Country__c = 'Netherlands',
    		Name__c = 'Test',
    		Id__c = 'NL007/X/092052510000',
    		Tax_Id__c = '09205251');
    	insert healthCheck;

    	CreditSystem__c creditSystem = new CreditSystem__c(
            Name = 'Creditsafe', 
            Endpoint__c = 'https://testwebservices.creditsafe.com/GlobalData/1.3/MainServiceBasic.svc',
            Username__c = 'FleetCortest', 
            Password__c = 'FleetCor855220', 
            Supported_Countries__c = 'Netherlands');
        insert creditSystem;

    	HealthCheckCreditFactoryBatch batch = new HealthCheckCreditFactoryBatch();

    	Test.startTest();
    		Test.setMock(HttpCalloutMock.class, new HealthCheckCreditFactoryMockNL());
    		Database.executeBatch(batch);
    	Test.stopTest();

    	List<Health_Check__c> healthCheckList = [
    	        SELECT Id
    	        FROM Health_Check__c];

    	System.assertEquals(0, healthCheckList.size());
    }


    /*******************************************************************************
	*  Name            : testBelgiumNLCreditFactoryCheck()
	*  Summary         : Test availability check of Credit Factory for Belgium-NL
	*  CreatedDate     : 09/01/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	@isTest
    static void testBelgiumNLCreditFactoryCheck() {
    	Health_Check_Credit_Factory__c healthCheck = new Health_Check_Credit_Factory__c(
    		Name = 'BENL',
    		Country__c = 'Belgium-NL',
    		Name__c = 'TESTO NV',
    		Id__c = 'BE009/X/427483255',
    		Tax_Id__c = '427483255');
    	insert healthCheck;

    	CreditSystem__c creditSystem = new CreditSystem__c(
            Name = 'Creditsafe', 
            Endpoint__c = 'https://testwebservices.creditsafe.com/GlobalData/1.3/MainServiceBasic.svc',
            Username__c = 'FleetCortest', 
            Password__c = 'FleetCor855220', 
            Supported_Countries__c = 'Belgium-NL');
        insert creditSystem;

    	HealthCheckCreditFactoryBatch batch = new HealthCheckCreditFactoryBatch();

    	Test.startTest();
    		Test.setMock(HttpCalloutMock.class, new HealthCheckCreditFactoryMockBENL());
    		Database.executeBatch(batch);
    	Test.stopTest();

    	List<Health_Check__c> healthCheckList = [
    	        SELECT Id
    	        FROM Health_Check__c];

    	System.assertEquals(0, healthCheckList.size());
    }


    /*******************************************************************************
	*  Name            : testBelgiumFRCreditFactoryCheck()
	*  Summary         : Test availability check of Credit Factory for Belgium-FR
	*  CreatedDate     : 09/01/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	@isTest
    static void testBelgiumFRCreditFactoryCheck() {
    	Health_Check_Credit_Factory__c healthCheck = new Health_Check_Credit_Factory__c(
    		Name = 'BEFR',
    		Country__c = 'Belgium-FR',
    		Name__c = 'TESTO NV',
    		Id__c = 'BE009/X/427483255',
    		Tax_Id__c = '427483255');
    	insert healthCheck;

    	CreditSystem__c creditSystem = new CreditSystem__c(
            Name = 'Creditsafe', 
            Endpoint__c = 'https://testwebservices.creditsafe.com/GlobalData/1.3/MainServiceBasic.svc',
            Username__c = 'FleetCortest', 
            Password__c = 'FleetCor855220', 
            Supported_Countries__c = 'Belgium-FR');
        insert creditSystem;

    	HealthCheckCreditFactoryBatch batch = new HealthCheckCreditFactoryBatch();

    	Test.startTest();
    		Test.setMock(HttpCalloutMock.class, new HealthCheckCreditFactoryMockBEFR());
    		Database.executeBatch(batch);
    	Test.stopTest();

    	List<Health_Check__c> healthCheckList = [
    	        SELECT Id
    	        FROM Health_Check__c];

    	System.assertEquals(0, healthCheckList.size());
    }


    /*******************************************************************************
	*  Name            : testPolandCreditFactoryCheck()
	*  Summary         : Test availability check of Credit Factory for Poland
	*  CreatedDate     : 09/01/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	@isTest
    static void testPolandCreditFactoryCheck() {
    	Health_Check_Credit_Factory__c healthCheck = new Health_Check_Credit_Factory__c(
    		Name = 'PL',
    		Country__c = 'Poland',
    		Name__c = 'Lambda sp. z o.o. komandytowo-akcyjna',
    		Id__c = '4835372542',
    		Tax_Id__c = '4835372542',
    		Archive_Id__c = '4394000002849121');
    	insert healthCheck;

    	CreditSystem__c creditSystem = new CreditSystem__c(
            Name = 'Crif',
            Endpoint__c = 'https://demo.deltavista.pl/Search_Soap_Service_PL/services/SearchService,' + 
                'https://demo.deltavista.pl/dvs-soap/services/OrderCheckService,https://demo.deltavista.pl/pdfservice/pdfservlet', 
            Username__c = 'demo_fleetcor_soap', 
            Password__c = 'cvujmHe4',
            Supported_Countries__c = 'Poland');
        insert creditSystem;

    	HealthCheckCreditFactoryBatch batch = new HealthCheckCreditFactoryBatch();

    	Test.startTest();
    		Test.setMock(HttpCalloutMock.class, new HealthCheckCreditFactoryMockPL());
    		Database.executeBatch(batch);
    	Test.stopTest();

    	List<Health_Check__c> healthCheckList = [
    	        SELECT Error_Description__c
    	        FROM Health_Check__c];

    	System.assertEquals(0, healthCheckList.size());
    }


    /*******************************************************************************
	*  Name            : testHungaryCreditFactoryCheck()
	*  Summary         : Test availability check of Credit Factory for Hunagary
	*  CreatedDate     : 09/01/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	@isTest
    static void testHungaryCreditFactoryCheck() {
    	Health_Check_Credit_Factory__c healthCheck = new Health_Check_Credit_Factory__c(
    		Name = 'HU',
    		Country__c = 'Hungary',
    		Name__c = 'M-SÉTÁNY Kereskedelmi, Szolgáltató és Vendéglátó Korlátolt Felelősségű Társaság',
    		Id__c = '81466010',
    		Vat_Number__c = '14066436-2-42');
    	insert healthCheck;

    	CreditSystem__c creditSystem = new CreditSystem__c(
            Name = 'Coface',
            Endpoint__c = 'https://test.cofacecentraleurope.com/iconwebservices', 
            Username__c = 'Petr.Cermak@fleetcor.eu', 
            Password__c = 'Fleetcor2018',
            Supported_Countries__c = 'Hungary');
        insert creditSystem;

    	HealthCheckCreditFactoryBatch batch = new HealthCheckCreditFactoryBatch();

    	Test.startTest();
    		Test.setMock(HttpCalloutMock.class, new HealthCheckCreditFactoryMockHU());
    		Database.executeBatch(batch);
    	Test.stopTest();

    	List<Health_Check__c> healthCheckList = [
    	        SELECT Error_Description__c
    	        FROM Health_Check__c];

    	System.assertEquals(0, healthCheckList.size());
    }
}