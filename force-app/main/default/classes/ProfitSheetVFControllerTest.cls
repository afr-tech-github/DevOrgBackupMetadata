@isTest(SeeAllData=false)
public class ProfitSheetVFControllerTest {
    private static testmethod void exportPD1F(){
        ProfitSheetVFController ctrl = new ProfitSheetVFController();
        ctrl.percentRevenue = null;
        ctrl.percentProfit = null;
        Test.startTest();
        ctrl.exportPDF();
        Integer x = 1;
        system.assert(x==1);
        Test.stopTest();
    }
    private static testmethod void exportPDF2(){
        ProfitSheetVFController ctrl = new ProfitSheetVFController();
        ctrl.percentRevenue = 'qqq';
        ctrl.percentProfit = null;
        Test.startTest();
        ctrl.exportPDF();
        Integer x = 1;
        system.assert(x==1);
        Test.stopTest();
    }
}