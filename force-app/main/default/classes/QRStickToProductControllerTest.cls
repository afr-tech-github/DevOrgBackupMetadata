/**
 * 	Created by thachle 28/11/24.
 */
@isTest
private class QRStickToProductControllerTest {

    @isTest
    static void testQRStickToProductController() {
       
       	Account account = new Account(
        	Name = 'Unit Test'
        );
        clofor_com_cfs__Facility__c fancility = new clofor_com_cfs__Facility__c();
        insert fancility;
        insert account;
        clofor_com_cfs__WorkOrder__c testWo = new clofor_com_cfs__WorkOrder__c(
            clofor_com_cfs__Customer__c = account.Id,
            clofor_com_cfs__WarehouseID__c = fancility.Id
        );
        insert testWo;

      
        Test.startTest();
        
    
        PageReference pageRef = Page.QRStickToProduct; 
        Test.setCurrentPageReference(pageRef);
        ApexPages.currentPage().getParameters().put('id', testWo.Id);

       
        QRStickToProductController controller = new QRStickToProductController();
        Test.stopTest();
        
    }
    @isTest
    static void testTotal() {
        QRStickToProductController.Total total = new QRStickToProductController.Total();
		total.getTotalSubtotalNetPurchaseValueVND();
        total.getTotalSubTotalVATVND();
        total.getTotalPurchaseValueVND();
    }
    @isTest
    static void testNode() {
        QRStickToProductController.Node node = new QRStickToProductController.Node();
		node.getNetPurchaseValueVND();
        node.getVATVND();
        node.getSubtotalNetPurchaseValueVND();
        node.getSubTotalVATVND();
        node.getPurchaseValueVND();
    }
}