@isTest
public with sharing class DataComLeadPhoneControllerTest {
    @isTest
    public static void testUpdatePhone() {
    	Lead lead = new Lead(Country = 'Germany', Company = 'Shell Tankstelle', FirstName = 'Michael', LastName = 'Becke', Email = 'mbecke@ppr.info');
    	insert lead; 
    	ApexPages.currentPage().getParameters().put('id', lead.Id);
        String companyId = '92049827';
    	ApexPages.currentPage().getParameters().put('companyId', companyId);
    	DataComLeadPhoneController controller = new DataComLeadPhoneController();
        
    	Test.startTest();

    	Test.setMock(HttpCalloutMock.class, new DataComLeadPhoneMock());
    	controller.init();
        controller.purchaseCompanyFromDataCom();
    	controller.backToLead();

    	Test.stopTest();
    }
}