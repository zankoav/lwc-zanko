@IsTest
public class FinancialReportSparkTest {

    @IsTest
    static void test() {
        FinancialReportSpark objFinancialReportSpark = new FinancialReportSpark();
        System.assert(objFinancialReportSpark != null);
        System.assert(objFinancialReportSpark.sparkID == null);
        System.assert(objFinancialReportSpark.inn == null);
        System.assert(objFinancialReportSpark.ogrn == null);
        System.assert(objFinancialReportSpark.okpo == null);
        System.assert(objFinancialReportSpark.shortName == null);
        System.assert(objFinancialReportSpark.period == null);
        System.assert(objFinancialReportSpark.egrullikvidation == null);
        System.assert(objFinancialReportSpark.egrpoincluded == null);

        FinancialReportSpark.Form objForm = new FinancialReportSpark.Form();
        System.assert(objForm != null);
        System.assert(objForm.value == null);
        System.assert(objForm.id == null);
        System.assert(objForm.power == null);

        FinancialReportSpark.Value objValue = new FinancialReportSpark.Value();
        System.assert(objValue != null);
        System.assert(objValue.value == null);
        System.assert(objValue.code == null);
        System.assert(objValue.name == null);
        System.assert(objValue.column == null);

        FinancialReportSpark.Period objPeriod = new FinancialReportSpark.Period();
        System.assert(objPeriod != null);
        System.assert(objPeriod.form == null);
        System.assert(objPeriod.periodName == null);
        System.assert(objPeriod.dateEnd == null);
        System.assert(objPeriod.dateBegin == null);
    }
}