@isTest
public class CreditNoteSelection_V2ControllerTest {
		@isTest
    public static void Test1(){
                Test.startTest();
                Account ac = new Account(Name = 'testAcENG',
                                 clofor_com_cfs__EnglishCompanyName__c = 'testAcENG',
                                 clofor_com_cfs__CustomerType__c = 'Others'
                                );
        insert ac;
        clofor_com_cfs__Site_Custom_Settings__c cus = new clofor_com_cfs__Site_Custom_Settings__c();
        cus.clofor_com_cfs__Company_Country__c = 'JAPAN';
        cus.clofor_com_cfs__Local_Currency__c = 'JPY';
        cus.clofor_com_cfs__Disable_Monthly_Yearly_HBL_ID__c = false;
         insert cus;
        
        clofor_com_cfs__CustomObject1__c ship = new clofor_com_cfs__CustomObject1__c(clofor_com_cfs__ETD__c =  Date.newInstance(2021, 1, 1),
            																	 	 clofor_com_cfs__ETA__c =  Date.newInstance(2021, 3, 20),
                                                                                     clofor_com_cfs__Field1__c = ac.Id);
        insert ship;
        
        
        
        clofor_com_cfs__TariffMaster__c ser = new clofor_com_cfs__TariffMaster__c(Name = 'testService');
        insert ser;
        
        clofor_com_cfs__AnkenMeisai__c bill = new clofor_com_cfs__AnkenMeisai__c(clofor_com_cfs__Anken__c =ship.Id,
                                                                                 clofor_com_cfs__Tariff__c =ser.Id,
                                                                                 clofor_com_cfs__Seikyusaki__c = ac.Id,
                                                                                 clofor_com_cfs__Description__c	= 'testDescription',
                                                                                 clofor_com_cfs__Suryo__c = 1,
                                                                                 clofor_com_cfs__SellTankaUSD__c = 100000,
                                                                                 clofor_com_cfs__ChargeUnit__c = 'CBM'
                                                                                );
        insert bill;
        
        
		PageReference pageRef = Page.page_InvoicePrint;
        pageRef.getParameters().put('shipmentId', ship.Id);
        pageRef.getParameters().put('customerId',ac.Id);
        Test.setCurrentPage(pageRef);
        
        
        CreditNoteSelection_V2Controller ctrl= new CreditNoteSelection_V2Controller();
        ApexPages.currentPage().getParameters().put('shipmentId',ship.Id);
        ApexPages.currentPage().getParameters().put('customerId',ac.Id);
        ctrl.closePopupDialog();
        ctrl.getCustomerList();
        ctrl.getFileTypeOptions();
        ctrl.getLanguageOptions();
        ctrl.getPrintOptions();
        ctrl.getCurrencyTypeOptions();
        ctrl.getBankOptions();
        ctrl.getTemplateOptions();
        //ctrl.generateAttachmentFile();
        
        
        Test.stopTest();
    }
}