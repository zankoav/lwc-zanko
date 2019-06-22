@isTest
private class CreditreformMailboxBatchTest {


    /*******************************************************************************
    *  Name            : testAvailableReportMailbox()
    *  Summary         : test check mailbox directory and entry with available report
    *  CreatedDate     : 20/12/2017
    *  ModifiedDate    : 20/12/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void testAvailableReportMailbox() {
        CreditSystem__c creditSystem = CreditFactoryUtils.doCreateCreditSystem();
        creditSystem.Supported_Countries__c = 'Germany';
        creditSystem.Name = 'Creditreform';
        insert creditSystem;

        Account account = new Account(
            Name = 'test',
            BillingCountry = 'Germany');
        insert account;

        Opportunity opportunity = new Opportunity(
            Anzahl_der_Karten__c = 5,
            Zahlungsart__c = 'Lastschrift',
            Zahlungsziel__c = '7',
            Product__c = 'None',
            StageName = 'Pending Credit Report',
            Name = 'test opp',
            Angebotsdauer__c = '3 Monate',
            CloseDate = Date.today(),
            AccountId = account.Id,
            CF_Order_Reference_Number__c = '100000001',
            OwnerId = UserInfo.getUserId());
        insert opportunity;

        List<Opportunity> opprtunitiesToBatchList = new List<Opportunity>{opportunity};

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformMailboxMock());
            Database.BatchableContext bc;
            CreditreformMailboxBatch batch = new CreditreformMailboxBatch();
            batch.start(bc);
            batch.execute(bc, opprtunitiesToBatchList);
            batch.finish(bc);
        Test.stopTest();

        List<Opportunity> opportunitiesList = [
                SELECT Credit_Factory_PDF_Report_Created__c, StageName, (SELECT Id FROM Credit_Factory_Reports__r)
                FROM Opportunity
                WHERE Id = :opportunity.Id
                LIMIT 1];

        System.assertEquals(1, opportunitiesList.get(0).Credit_Factory_Reports__r.size());
        System.assertEquals(true, opportunitiesList.get(0).Credit_Factory_PDF_Report_Created__c);
        System.assertEquals('Credit Report Generated', opportunitiesList.get(0).StageName);

        List<Financial_Module__c> financialModulesList = [
                SELECT Name, 
                        (SELECT Year__c, Type__c, Total_Assets__c, Total_Fixed_Assets__c, Intangible_Fixed_Assets__c, 
                            Tangible_Fixed_Assets__c, Financial_LT_Assets__c, Total_Current_Assets__c, Stock_material_work__c, 
                            Trade_debtors__c, Cash_Cash_equivalent__c,  Others_Current_Assets__c, Total_Liabilities__c, 
                            Net_worth__c, Reserves__c, Liabilities__c, LongTerm_Liabilities__c, From_that_LT_bank_debt__c, From_that_other_LT_liabilities__c,
                            ShortTerm_Liabilities__c, From_that_Trade_Creditors__c, From_that_ST_bank_debt__c, From_that_other_ST_liabilities__c,
                            Total_Turnover__c, Turnover__c, Activation__c, Other_operational_income__c, Cost_of_goods_sold__c, Gross_profit_loss__c,
                            Depreciation__c, EBIT_from_Crefo__c, Income_and_other_taxes__c, Operational_profit_EBIT__c, EBITDA__c, Calculated_CF__c, Financial_Income__c,
                            Financial_Charges__c, Net_Interest_expense__c, EAT__c, Extraordinary_Items__c, Exceptional_Income__c,
                            Exceptional_Charges__c, Exceptional_Items_Total__c, Profit_Margin__c, 
                            ROA_calculation_includes_taxes_x_D_B__c, ROE_without_Reserves__c, Profitability__c,
                            Solvency_ratio__c, Leverage__c, Debt_to_EBITDA__c, EBITDA_coverage__c, Current_ratio__c, 
                            Quick_acid_ratio__c, Working_capital__c, Cash_flow_ratio__c, DSO_in_days__c, DPO_in_days__c,
                            Overall_score__c
                        FROM Financial_Details__r
                        ORDER BY Year__c DESC)
                FROM Financial_Module__c
                WHERE Account__c = :account.Id
                ORDER BY CreatedDate DESC
                LIMIT 1];

        // 2 "annual" and 2 "change" details
        System.assertEquals(4, financialModulesList.get(0).Financial_Details__r.size());

        // 2013 annual
        System.assertEquals(653273, financialModulesList.get(0).Financial_Details__r.get(1).Total_Assets__c);
        System.assertEquals(612912, financialModulesList.get(0).Financial_Details__r.get(1).Total_Fixed_Assets__c);
        System.assertEquals(2, financialModulesList.get(0).Financial_Details__r.get(1).Intangible_Fixed_Assets__c);
        System.assertEquals(26063, financialModulesList.get(0).Financial_Details__r.get(1).Tangible_Fixed_Assets__c);
        System.assertEquals(586847, financialModulesList.get(0).Financial_Details__r.get(1).Financial_LT_Assets__c);
        System.assertEquals(40361, financialModulesList.get(0).Financial_Details__r.get(1).Total_Current_Assets__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(1).Stock_material_work__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(1).Trade_debtors__c);
        System.assertEquals(20044, financialModulesList.get(0).Financial_Details__r.get(1).Cash_Cash_equivalent__c);
        System.assertEquals(20317, financialModulesList.get(0).Financial_Details__r.get(1).Others_Current_Assets__c);
        System.assertEquals(275191, financialModulesList.get(0).Financial_Details__r.get(1).Total_Liabilities__c);
        System.assertEquals(199130, financialModulesList.get(0).Financial_Details__r.get(1).Net_worth__c);
        System.assertEquals(6322, financialModulesList.get(0).Financial_Details__r.get(1).Reserves__c);
        System.assertEquals(69739, financialModulesList.get(0).Financial_Details__r.get(1).Liabilities__c);
        System.assertEquals(0, financialModulesList.get(0).Financial_Details__r.get(1).LongTerm_Liabilities__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(1).From_that_LT_bank_debt__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(1).From_that_other_LT_liabilities__c);
        System.assertEquals(69739, financialModulesList.get(0).Financial_Details__r.get(1).ShortTerm_Liabilities__c);
        System.assertEquals(691, financialModulesList.get(0).Financial_Details__r.get(1).From_that_Trade_Creditors__c);
        System.assertEquals(36000, financialModulesList.get(0).Financial_Details__r.get(1).From_that_ST_bank_debt__c);
        System.assertEquals(33048, financialModulesList.get(0).Financial_Details__r.get(1).From_that_other_ST_liabilities__c);
        System.assertEquals(0, financialModulesList.get(0).Financial_Details__r.get(1).Total_Turnover__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(1).Turnover__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(1).Activation__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(1).Other_operational_income__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(1).Cost_of_goods_sold__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(1).Gross_profit_loss__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(1).Depreciation__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(1).EBIT_from_Crefo__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(1).Income_and_other_taxes__c);
        System.assertEquals(0, financialModulesList.get(0).Financial_Details__r.get(1).Operational_profit_EBIT__c);
        System.assertEquals(0, financialModulesList.get(0).Financial_Details__r.get(1).EBITDA__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(1).Calculated_CF__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(1).Financial_Income__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(1).Financial_Charges__c);
        System.assertEquals(0, financialModulesList.get(0).Financial_Details__r.get(1).Net_Interest_expense__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(1).EAT__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(1).Extraordinary_Items__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(1).Exceptional_Income__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(1).Exceptional_Charges__c);
        System.assertEquals(0, financialModulesList.get(0).Financial_Details__r.get(1).Exceptional_Items_Total__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(1).Profit_Margin__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(1).ROA_calculation_includes_taxes_x_D_B__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(1).ROE_without_Reserves__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(1).Profitability__c);
        System.assertEquals(0, financialModulesList.get(0).Financial_Details__r.get(1).Solvency_ratio__c);
        System.assertEquals(0.12, financialModulesList.get(0).Financial_Details__r.get(1).Leverage__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(1).Debt_to_EBITDA__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(1).EBITDA_coverage__c);
        System.assertEquals(0.58, financialModulesList.get(0).Financial_Details__r.get(1).Current_ratio__c);
        System.assertEquals(0.58, financialModulesList.get(0).Financial_Details__r.get(1).Quick_acid_ratio__c);
        System.assertEquals(-29378, financialModulesList.get(0).Financial_Details__r.get(1).Working_capital__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(1).Cash_flow_ratio__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(1).DSO_in_days__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(1).DPO_in_days__c);

        // 2013 score
        System.assertEquals(1.63, financialModulesList.get(0).Financial_Details__r.get(0).Total_Assets__c);
        System.assertEquals(1.7, financialModulesList.get(0).Financial_Details__r.get(0).Total_Fixed_Assets__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Intangible_Fixed_Assets__c);
        System.assertEquals(2.84, financialModulesList.get(0).Financial_Details__r.get(0).Tangible_Fixed_Assets__c);
        System.assertEquals(1.67, financialModulesList.get(0).Financial_Details__r.get(0).Financial_LT_Assets__c);
        System.assertEquals(1, financialModulesList.get(0).Financial_Details__r.get(0).Total_Current_Assets__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Stock_material_work__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Trade_debtors__c);
        System.assertEquals(1, financialModulesList.get(0).Financial_Details__r.get(0).Cash_Cash_equivalent__c);
        System.assertEquals(1, financialModulesList.get(0).Financial_Details__r.get(0).Others_Current_Assets__c);
        System.assertEquals(1, financialModulesList.get(0).Financial_Details__r.get(0).Total_Liabilities__c);
        System.assertEquals(1, financialModulesList.get(0).Financial_Details__r.get(0).Net_worth__c);
        System.assertEquals(1, financialModulesList.get(0).Financial_Details__r.get(0).Reserves__c);
        System.assertEquals(1, financialModulesList.get(0).Financial_Details__r.get(0).Liabilities__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).LongTerm_Liabilities__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).From_that_LT_bank_debt__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).From_that_other_LT_liabilities__c);
        System.assertEquals(1, financialModulesList.get(0).Financial_Details__r.get(0).ShortTerm_Liabilities__c);
        System.assertEquals(1, financialModulesList.get(0).Financial_Details__r.get(0).From_that_Trade_Creditors__c);
        System.assertEquals(1, financialModulesList.get(0).Financial_Details__r.get(0).From_that_ST_bank_debt__c);
        System.assertEquals(1, financialModulesList.get(0).Financial_Details__r.get(0).From_that_other_ST_liabilities__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Total_Turnover__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Turnover__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Activation__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Other_operational_income__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Cost_of_goods_sold__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Gross_profit_loss__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Depreciation__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).EBIT_from_Crefo__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Income_and_other_taxes__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Operational_profit_EBIT__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).EBITDA__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Calculated_CF__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Financial_Income__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Financial_Charges__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Net_Interest_expense__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).EAT__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Extraordinary_Items__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Exceptional_Income__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Exceptional_Charges__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Exceptional_Items_Total__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Profit_Margin__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).ROA_calculation_includes_taxes_x_D_B__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).ROE_without_Reserves__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Profitability__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Solvency_ratio__c);
        System.assertEquals(1, financialModulesList.get(0).Financial_Details__r.get(0).Leverage__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Debt_to_EBITDA__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).EBITDA_coverage__c);
        System.assertEquals(5, financialModulesList.get(0).Financial_Details__r.get(0).Current_ratio__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Quick_acid_ratio__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Working_capital__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).Cash_flow_ratio__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).DSO_in_days__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(0).DPO_in_days__c);
        System.assertEquals(3, financialModulesList.get(0).Financial_Details__r.get(0).Overall_score__c);

        // 2012 annual
        System.assertEquals(401540, financialModulesList.get(0).Financial_Details__r.get(3).Total_Assets__c);
        System.assertEquals(361179, financialModulesList.get(0).Financial_Details__r.get(3).Total_Fixed_Assets__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(3).Intangible_Fixed_Assets__c);
        System.assertEquals(9186, financialModulesList.get(0).Financial_Details__r.get(3).Tangible_Fixed_Assets__c);
        System.assertEquals(351993, financialModulesList.get(0).Financial_Details__r.get(3).Financial_LT_Assets__c);
        System.assertEquals(40361, financialModulesList.get(0).Financial_Details__r.get(3).Total_Current_Assets__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(3).Stock_material_work__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(3).Trade_debtors__c);
        System.assertEquals(20044, financialModulesList.get(0).Financial_Details__r.get(3).Cash_Cash_equivalent__c);
        System.assertEquals(20317, financialModulesList.get(0).Financial_Details__r.get(3).Others_Current_Assets__c);
        System.assertEquals(275191, financialModulesList.get(0).Financial_Details__r.get(3).Total_Liabilities__c);
        System.assertEquals(199130, financialModulesList.get(0).Financial_Details__r.get(3).Net_worth__c);
        System.assertEquals(6322, financialModulesList.get(0).Financial_Details__r.get(3).Reserves__c);
        System.assertEquals(69739, financialModulesList.get(0).Financial_Details__r.get(3).Liabilities__c);
        System.assertEquals(0, financialModulesList.get(0).Financial_Details__r.get(3).LongTerm_Liabilities__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(3).From_that_LT_bank_debt__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(3).From_that_other_LT_liabilities__c);
        System.assertEquals(69739, financialModulesList.get(0).Financial_Details__r.get(3).ShortTerm_Liabilities__c);
        System.assertEquals(691, financialModulesList.get(0).Financial_Details__r.get(3).From_that_Trade_Creditors__c);
        System.assertEquals(36000, financialModulesList.get(0).Financial_Details__r.get(3).From_that_ST_bank_debt__c);
        System.assertEquals(33048, financialModulesList.get(0).Financial_Details__r.get(3).From_that_other_ST_liabilities__c);
        System.assertEquals(0, financialModulesList.get(0).Financial_Details__r.get(3).Total_Turnover__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(3).Turnover__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(3).Activation__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(3).Other_operational_income__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(3).Cost_of_goods_sold__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(3).Gross_profit_loss__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(3).Depreciation__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(3).EBIT_from_Crefo__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(3).Income_and_other_taxes__c);
        System.assertEquals(0, financialModulesList.get(0).Financial_Details__r.get(3).Operational_profit_EBIT__c);
        System.assertEquals(0, financialModulesList.get(0).Financial_Details__r.get(3).EBITDA__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(3).Calculated_CF__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(3).Financial_Income__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(3).Financial_Charges__c);
        System.assertEquals(0, financialModulesList.get(0).Financial_Details__r.get(3).Net_Interest_expense__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(3).EAT__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(3).Extraordinary_Items__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(3).Exceptional_Income__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(3).Exceptional_Charges__c);
        System.assertEquals(0, financialModulesList.get(0).Financial_Details__r.get(3).Exceptional_Items_Total__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(3).Profit_Margin__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(3).ROA_calculation_includes_taxes_x_D_B__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(3).ROE_without_Reserves__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(3).Profitability__c);
        System.assertEquals(0, financialModulesList.get(0).Financial_Details__r.get(3).Solvency_ratio__c);
        System.assertEquals(0.19, financialModulesList.get(0).Financial_Details__r.get(3).Leverage__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(3).Debt_to_EBITDA__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(3).EBITDA_coverage__c);
        System.assertEquals(0.58, financialModulesList.get(0).Financial_Details__r.get(3).Current_ratio__c);
        System.assertEquals(0.58, financialModulesList.get(0).Financial_Details__r.get(3).Quick_acid_ratio__c);
        System.assertEquals(-29378, financialModulesList.get(0).Financial_Details__r.get(3).Working_capital__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(3).Cash_flow_ratio__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(3).DSO_in_days__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(3).DPO_in_days__c);

        // 2012 score
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Total_Assets__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Total_Fixed_Assets__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Intangible_Fixed_Assets__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Tangible_Fixed_Assets__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Financial_LT_Assets__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Total_Current_Assets__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Stock_material_work__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Trade_debtors__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Cash_Cash_equivalent__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Others_Current_Assets__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Total_Liabilities__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Net_worth__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Reserves__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Liabilities__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).LongTerm_Liabilities__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).From_that_LT_bank_debt__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).From_that_other_LT_liabilities__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).ShortTerm_Liabilities__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).From_that_Trade_Creditors__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).From_that_ST_bank_debt__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).From_that_other_ST_liabilities__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Total_Turnover__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Turnover__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Activation__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Other_operational_income__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Cost_of_goods_sold__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Gross_profit_loss__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Depreciation__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).EBIT_from_Crefo__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Income_and_other_taxes__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Operational_profit_EBIT__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).EBITDA__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Calculated_CF__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Financial_Income__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Financial_Charges__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Net_Interest_expense__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).EAT__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Extraordinary_Items__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Exceptional_Income__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Exceptional_Charges__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Exceptional_Items_Total__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Profit_Margin__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).ROA_calculation_includes_taxes_x_D_B__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).ROE_without_Reserves__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Profitability__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Solvency_ratio__c);
        System.assertEquals(1, financialModulesList.get(0).Financial_Details__r.get(2).Leverage__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Debt_to_EBITDA__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).EBITDA_coverage__c);
        System.assertEquals(5, financialModulesList.get(0).Financial_Details__r.get(2).Current_ratio__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Quick_acid_ratio__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Working_capital__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).Cash_flow_ratio__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).DSO_in_days__c);
        System.assertEquals(null, financialModulesList.get(0).Financial_Details__r.get(2).DPO_in_days__c);
        System.assertEquals(3, financialModulesList.get(0).Financial_Details__r.get(2).Overall_score__c);
    }


    /******************************************************************************
    *  Name            : testNeedReportInformationMailbox()
    *  Summary         : test check mailbox directory and entry with needed inforamtion about report
    *  CreatedDate     : 20/12/2017
    *  ModifiedDate    : 20/12/2017
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    static void testNeedReportInformationMailbox() {
        CreditSystem__c creditSystem = CreditFactoryUtils.doCreateCreditSystem();
        creditSystem.Supported_Countries__c = 'Germany';
        creditSystem.Name = 'Creditreform';
        insert creditSystem;

        Account account = new Account(
            Name = 'test',
            BillingCountry = 'Germany');
        insert account;

        Opportunity opportunity = new Opportunity(
            Anzahl_der_Karten__c = 5,
            Zahlungsart__c = 'Lastschrift',
            Zahlungsziel__c = '7',
            Product__c = 'None',
            StageName = 'Pending Credit Report',
            Name = 'test opp',
            Angebotsdauer__c = '3 Monate',
            CloseDate = Date.today(),
            AccountId = account.Id,
            CF_Order_Reference_Number__c = '100000007',
            OwnerId = UserInfo.getUserId());
        insert opportunity;

        List<Opportunity> opprtunitiesToBatchList = new List<Opportunity>{opportunity};

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformMailboxMock());
            Database.BatchableContext bc;
            CreditreformMailboxBatch batch = new CreditreformMailboxBatch();
            batch.start(bc);
            batch.execute(bc, opprtunitiesToBatchList);
            batch.finish(bc);
        Test.stopTest();

        List<Opportunity> opportunitiesList = [
                SELECT CF_Stage__c
                FROM Opportunity
                WHERE Id = :opportunity.Id
                LIMIT 1];

        System.assertEquals('Pending Credit Report - Additional information was sent', opportunitiesList.get(0).CF_Stage__c);
    }


    /*******************************************************************************
    *  Name            : testUnavailableReportMailbox()
    *  Summary         : test check mailbox directory and entry with unavailable report response  
    *  CreatedDate     : 23/03/2018
    *  ModifiedDate    : 23/03/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void testUnavailableReportMailbox() {
        CreditSystem__c creditSystem = CreditFactoryUtils.doCreateCreditSystem();
        creditSystem.Supported_Countries__c = 'Germany';
        creditSystem.Name = 'Creditreform';
        insert creditSystem;

        Account account = new Account(
            Name = 'test',
            BillingCountry = 'Germany');
        insert account;

        Opportunity opportunity = new Opportunity(
            Anzahl_der_Karten__c = 5,
            Zahlungsart__c = 'Lastschrift',
            Zahlungsziel__c = '7',
            Product__c = 'None',
            StageName = 'Pending Credit Report',
            Name = 'test opp',
            Angebotsdauer__c = '3 Monate',
            CloseDate = Date.today(),
            AccountId = account.Id,
            CF_Order_Reference_Number__c = '100000009',
            OwnerId = UserInfo.getUserId());
        insert opportunity;

        List<Opportunity> opprtunitiesToBatchList = new List<Opportunity>{opportunity};

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CreditreformMailboxMock());
            Database.BatchableContext bc;
            CreditreformMailboxBatch batch = new CreditreformMailboxBatch();
            batch.start(bc);
            batch.execute(bc, opprtunitiesToBatchList);
            batch.finish(bc);
        Test.stopTest();

        List<Opportunity> opportunitiesList = [
                SELECT StageName
                FROM Opportunity
                WHERE Id = :opportunity.Id
                LIMIT 1];

        System.assertEquals('Closed Lost', opportunitiesList.get(0).StageName);
    }
}