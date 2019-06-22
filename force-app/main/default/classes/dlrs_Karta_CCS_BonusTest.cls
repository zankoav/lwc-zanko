/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Karta_CCS_BonusTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Karta_CCS_BonusTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Karta_CCS_Bonus__c());
    }
}