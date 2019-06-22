/**
 * Created by Nikita.Milhailov on 26.02.2019.
 */

@IsTest
public with sharing class GFNI_ApplicationStatusSchedulableTest {

    @IsTest
    public static void testExecuteAT() {
        Id accAT = createAccount('AT', 'AT123');
        Id oppAT = createOpportunity(accAT);
        Id cardAT = createCard(oppAT);
        Test.startTest();
        GFNI_ApplicationStatusSchedulable app = new GFNI_ApplicationStatusSchedulable();
        app.execute(null);
        Test.stopTest();
    }

    @IsTest
    public static void testExecuteBEFR() {
        Id accAT = createAccount('BEFR', 'BENL123');
        Id oppAT = createOpportunity(accAT);
        Id cardAT = createCard(oppAT);
        Test.startTest();
        GFNI_ApplicationStatusSchedulable app = new GFNI_ApplicationStatusSchedulable();
        app.execute(null);
        Test.stopTest();
    }

    @IsTest
    public static void testExecuteBENL() {
        Id accAT = createAccount('BENL', 'BENL123');
        Id oppAT = createOpportunity(accAT);
        Id cardAT = createCard(oppAT);
        Test.startTest();
        GFNI_ApplicationStatusSchedulable app = new GFNI_ApplicationStatusSchedulable();
        app.execute(null);
        Test.stopTest();
    }

    @IsTest
    public static void testExecuteCHDE() {
        Id accAT = createAccount('CHDE', 'CHDE123');
        Id oppAT = createOpportunity(accAT);
        Id cardAT = createCard(oppAT);
        Test.startTest();
        GFNI_ApplicationStatusSchedulable app = new GFNI_ApplicationStatusSchedulable();
        app.execute(null);
        Test.stopTest();
    }

    @IsTest
    public static void testExecuteCHFR() {
        Id accAT = createAccount('CHFR', 'CHFR123');
        Id oppAT = createOpportunity(accAT);
        Id cardAT = createCard(oppAT);
        Test.startTest();
        GFNI_ApplicationStatusSchedulable app = new GFNI_ApplicationStatusSchedulable();
        app.execute(null);
        Test.stopTest();
    }

    @IsTest
    public static void testExecuteCHIT() {
        Id accAT = createAccount('CHIT', 'CHIT123');
        Id oppAT = createOpportunity(accAT);
        Id cardAT = createCard(oppAT);
        Test.startTest();
        GFNI_ApplicationStatusSchedulable app = new GFNI_ApplicationStatusSchedulable();
        app.execute(null);
        Test.stopTest();
    }

    @IsTest
    public static void testExecuteCZ() {
        Id accAT = createAccount('CZ', 'CZ123');
        Id oppAT = createOpportunity(accAT);
        Id cardAT = createCard(oppAT);
        Test.startTest();
        GFNI_ApplicationStatusSchedulable app = new GFNI_ApplicationStatusSchedulable();
        app.execute(null);
        Test.stopTest();
    }

    @IsTest
    public static void testExecuteDE() {
        Id accAT = createAccount('DE', 'DE123');
        Id oppAT = createOpportunity(accAT);
        Id cardAT = createCard(oppAT);
        Test.startTest();
        GFNI_ApplicationStatusSchedulable app = new GFNI_ApplicationStatusSchedulable();
        app.execute(null);
        Test.stopTest();
    }

    @IsTest
    public static void testExecuteFR() {
        Id accAT = createAccount('FR', 'FR123');
        Id oppAT = createOpportunity(accAT);
        Id cardAT = createCard(oppAT);
        Test.startTest();
        GFNI_ApplicationStatusSchedulable app = new GFNI_ApplicationStatusSchedulable();
        app.execute(null);
        Test.stopTest();
    }

    @IsTest
    public static void testExecuteHU() {
        Id accAT = createAccount('HU', 'HU123');
        Id oppAT = createOpportunity(accAT);
        Id cardAT = createCard(oppAT);
        Test.startTest();
        GFNI_ApplicationStatusSchedulable app = new GFNI_ApplicationStatusSchedulable();
        app.execute(null);
        Test.stopTest();
    }

    @IsTest
    public static void testExecuteLU() {
        Id accAT = createAccount('LU', 'LU123');
        Id oppAT = createOpportunity(accAT);
        Id cardAT = createCard(oppAT);
        Test.startTest();
        GFNI_ApplicationStatusSchedulable app = new GFNI_ApplicationStatusSchedulable();
        app.execute(null);
        Test.stopTest();
    }

    @IsTest
    public static void testExecuteNL() {
        Id accAT = createAccount('NL', 'NL123');
        Id oppAT = createOpportunity(accAT);
        Id cardAT = createCard(oppAT);
        Test.startTest();
        GFNI_ApplicationStatusSchedulable app = new GFNI_ApplicationStatusSchedulable();
        app.execute(null);
        Test.stopTest();
    }

    @IsTest
    public static void testExecutePL() {
        Id accAT = createAccount('PL', 'PL123');
        Id oppAT = createOpportunity(accAT);
        Id cardAT = createCard(oppAT);
        Test.startTest();
        GFNI_ApplicationStatusSchedulable app = new GFNI_ApplicationStatusSchedulable();
        app.execute(null);
        Test.stopTest();
    }

    @IsTest
    public static void testExecuteSK() {
        Id accAT = createAccount('SK', 'SK123');
        Id oppAT = createOpportunity(accAT);
        Id cardAT = createCard(oppAT);
        Test.startTest();
        GFNI_ApplicationStatusSchedulable app = new GFNI_ApplicationStatusSchedulable();
        app.execute(null);
        Test.stopTest();
    }

    private static Id createAccount(String countryCode, String gfnNumber) {
        Account acc = new Account();
        acc.Name = 'Test';
        acc.BillingCountryCode = countryCode;
        acc.GFN_Nr__c = gfnNumber;

        insert acc;

        return acc.Id;
    }

    private static Id createOpportunity(Id accId) {
        Opportunity opp = new Opportunity();
        opp.AccountId = accId;
        opp.Name = 'TestName';
        opp.StageName = 'ClosedWon';
        opp.CloseDate = System.today();
        opp.GFNI_ApplicationId__c = 'fdc9254d-17ba-4d7d-9858-e6376893e2a9';

        insert opp;

        return opp.Id;
    }

    private static Id createCard(Id oppId) {
        Tankkarten__c card = new Tankkarten__c();
        card.Opportunity__c = oppId;
        card.GFNI_Status__c = 'Pending';
        card.Driver_Name__c = 'Test name';

        insert card;

        return card.Id;
    }
}