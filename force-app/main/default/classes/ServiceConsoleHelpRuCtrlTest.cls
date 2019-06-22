@isTest
private  class ServiceConsoleHelpRuCtrlTest {

    @isTest
    private static void setTargetLinkTest(){
        Lead lead = new Lead(
                Status = 'Contacted',
                LastName = 'test',
                Company = 'test',
                Phone = '1234567890',
                Country = 'Russia',
                Email = 'test@test.ru'
        );
        insert lead;

        ServiceConsoleHelpRuCtrl serviceConsole = new ServiceConsoleHelpRuCtrl();
        serviceConsole.sourceText = lead.id;
        serviceConsole.prepareTabParams();

        system.assertEquals(serviceConsole.tabLink, lead.id);
        system.assertEquals(serviceConsole.tabName, 'test');
    }

    @isTest
    private static void setTargetLinkTest_2(){
        Lead lead = new Lead(
                Status = 'Contacted',
                LastName = 'test',
                Company = 'test',
                Phone = '1234567890',
                Country = 'Russia',
                Email = 'test@test.ru'
        );
        insert lead;

        ServiceConsoleHelpRuCtrl serviceConsole = new ServiceConsoleHelpRuCtrl();
        serviceConsole.sourceText = 'https://eu9.salesforce.com/'+lead.id;
        serviceConsole.prepareTabParams();

        system.assertEquals(serviceConsole.tabLink, lead.id);
        system.assertEquals(serviceConsole.tabName, 'test');
    }

}