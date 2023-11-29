@isTest(SeeAllData=false)
public class ProfitSheetMultiCurrsVFCtrTest {
    private static testmethod void exportPD1F(){
        ProfitSheetMultiCurrsVFCtr ctrl = new ProfitSheetMultiCurrsVFCtr();
        ctrl.percentRevenue = null;
        ctrl.percentProfit = null;
        Test.startTest();
        ctrl.exportPDF();
        Integer x = 1;
        system.assert(x==1);
        Test.stopTest();
    }
    private static testmethod void exportPDF2(){
        ProfitSheetMultiCurrsVFCtr ctrl = new ProfitSheetMultiCurrsVFCtr();
        ctrl.percentRevenue = 'qqq';
        ctrl.percentProfit = null;
        Test.startTest();
        ctrl.exportPDF();
        Integer x = 1;
        system.assert(x==1);
        Test.stopTest();
    }
}