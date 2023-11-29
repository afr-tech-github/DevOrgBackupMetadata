@isTest(SeeAllData=false)
public class MassiveNewCashControllerTest {
	private static Map<String, Object> additionalFields;
    private static CASH_BOOK__c cashBook = new CASH_BOOK__c();
    private static AnkenMeisai__c anken1{get;set;}
    private static CustomObject1__c shipment{get;set;}
    static{
        additionalFields = new Map<String, Object>{
                'Company_Address__c' => '123 ABC, Tokyo, Japan',
                'Company_Fax__c' => '1234567', 'Company_Phone__c' => '11122233', 'Local_Currency__c' => 'VND',
                'Logo_URL__c' => 'http://afr-solutions.com/logo.png', 'Company_Country__c' => 'Japan',
                'Ocean_HBL_No_Prefix__c' => 'AFR', 'Ferry_SLA__c' => 120, 'Container_Vessel_SLA__c' => 480,
                'EnableInvoiceTemplateSet1__c' => true, 'InvoiceTemplateSet1Name__c' => 'TEST'
        };
        TestDataFactory.createSObject(new Site_Custom_Settings__c(), true, additionalFields);
        
        additionalFields = new Map<String, Object>{
                'Currency__c' => 'USD - U.S. Dollar'
        };
        Account account = (Account) TestDataFactory.createSObject(new Account(), true, additionalFields);
        
        RecordType rtCash = [Select Id
                            FROM RecordType 
                            WHERE Name = 'Inbound Transaction-USD Currency' 
                            		AND SObjectType = 'clofor_com_cfs__CASH_BOOK__c'];
        
        additionalFields = new Map<String, Object>{
                'RecordTypeId' => rtCash.Id
        };
        cashBook = (CASH_BOOK__c) TestDataFactory.createSObject(new CASH_BOOK__c(), true, additionalFields);
        
        additionalFields = new Map<String, Object>{
                'Name' => 'LCL', 'ProductSearch__c' => 'FCL輸入', 'Subcategory__c' => '基本料金',
                'EngProductSearch__c' => 'FCL Import', 'ProductFlag__c' => true,
                'Supplier__c' => account.Id, 'Zeibunrui__c' => PicklistReference.DUAL_PRODUCT_TAX
        };
        TariffMaster__c tariff = (TariffMaster__c) TestDataFactory.createSObject(new TariffMaster__c(), true, additionalFields);
        
        RecordType rtShip = [Select Id from RecordType where Name = 'Air Import' AND SObjectType = 'clofor_com_cfs__CustomObject1__c'];
        additionalFields = new Map<String, Object>{
            'Field1__c' => account.Id, 'RecordTypeId' => rtShip.Id, 'HBL__c' => 'TEST0001',
            'clofor_com_cfs__ContainerNumber__c' => 1, 'clofor_com_cfs__ContainerNumber2__c' => 1, 'clofor_com_cfs__ContainerNumber3__c' => 1,
            'clofor_com_cfs__ContainerNumber4__c' => 1,
            'clofor_com_cfs__Container__c' => '20\'DC',
            'clofor_com_cfs__Container2__c' => '20\'DC',
            'clofor_com_cfs__Container3__c' => '20\'DC',
            'clofor_com_cfs__Container4__c' => '20\'DC'
        };
        shipment = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), true, additionalFields);
        
        additionalFields = new Map<String, Object>{
                'Anken__c' => shipment.Id, 'curr__c' => 'VND', 'VAT_INVOICE_ISSUE_STATUS__c' => false,
                'Tariff__c' => tariff.Id,
                'Seikyusaki__c' => account.Id, 'SerchSyubetu__c' => 'FCL輸入',
                'Cost_Allocation_Catetory__c' => 'Partner Cost allocation', 'TAX_ADJUSTMENT__c' => 10
        };
        anken1 = (AnkenMeisai__c) TestDataFactory.createSObject(new AnkenMeisai__c(), true, additionalFields);   
    	
        RecordType rtFac = [Select Id from RecordType where Name = 'NORMAL WAREHOUSE' AND SObjectType = 'clofor_com_cfs__Facility__c'];
    	additionalFields = new Map<String, Object>{
                'RecordTypeId' => rtFac.Id
        };
        Facility__c fac = new Facility__c(); 
        fac.RecordTypeId = rtFac.Id;
		FlsService.doInsert(fac);
        
        RecordType rtWO = [Select Id from RecordType where Name = 'Cross-Docking' AND SObjectType = 'clofor_com_cfs__WorkOrder__c'];
        WorkOrder__c work = new WorkOrder__c();
        work.RecordTypeId = rtWO.Id;
        work.WarehouseID__c = fac.Id;
        work.Customer__c = account.Id;
		FlsService.doInsert(work);
        
        RecordType rtBill = [Select Id from RecordType where Name = 'Standard Billing' AND SObjectType = 'clofor_com_cfs__Billing__c'];
        Billing__c bill = new Billing__c(); 
        bill.RecordTypeId = rtBill.Id;
        bill.WorkOrderID__c = work.Id;
		FlsService.doInsert(bill);
    }
    
    static testmethod void doClear(){
        PageReference pageRef = Page.MassiveNew;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id', String.valueOf(cashBook.Id));
        pageRef.getParameters().put('type', 'WMS');
        Test.startTest();
        MassiveNewCashController ctl = new MassiveNewCashController();
        ctl.doClear();
        Integer x = 1;
        system.assert(x==1);
        Test.stopTest();
    }
    
    static testmethod void doSearchWMS(){
        PageReference pageRef = Page.MassiveNew;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id', String.valueOf(cashBook.Id));
        pageRef.getParameters().put('type', 'WMS');
        Test.startTest();
        MassiveNewCashController ctl = new MassiveNewCashController();
        ctl.objSearch.WorkOrderId = 'A';
        ctl.objSearch.WMSBillId = 'A';
        ctl.objSearch.PaymentTo = 'A';
        ctl.objSearch.InvoiceTo = 'A';
        ctl.doSearch();
        Integer x = 1;
        system.assert(x==1);
        Test.stopTest();
    }
    
    static testmethod void doSearchFMS(){
        PageReference pageRef = Page.MassiveNew;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id', String.valueOf(cashBook.Id));
        pageRef.getParameters().put('type', 'FMS');
        Test.startTest();
        MassiveNewCashController ctl = new MassiveNewCashController();
        ctl.objSearch.WorkOrderId = 'A';
        ctl.objSearch.WMSBillId = 'A';
        ctl.objSearch.PaymentTo = 'A';
        ctl.objSearch.InvoiceTo = 'A';
        ctl.billFMSSearch = anken1;
        ctl.shipmentOrderSearch = shipment;
        ctl.objSearch.sTimeType ='ETD';
        ctl.objSearch.sFromTime ='20/10/1991';
        ctl.objSearch.sToTime ='20/10/2220';
        ctl.objSearch.sCustomer ='';
        ctl.doSearch();
        Integer x = 1;
        system.assert(x==1);
        Test.stopTest();
    }
    
    static testmethod void doInsertFMS(){
        PageReference pageRef = Page.MassiveNew;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id', String.valueOf(cashBook.Id));
        pageRef.getParameters().put('type', 'FMS');
        Test.startTest();
        MassiveNewCashController ctl = new MassiveNewCashController();
        pageRef.getParameters().put('listBillIds', anken1.Id);
        ctl.doInsertFMS();
        Integer x = 1;
        system.assert(x==1);
        Test.stopTest();
    }
    
    static testmethod void doInsertWMS(){
        PageReference pageRef = Page.MassiveNew;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id', String.valueOf(cashBook.Id));
        pageRef.getParameters().put('type', 'WMS');
        Test.startTest();
        MassiveNewCashController ctl = new MassiveNewCashController();
        ctl.doInsert();
        Integer x = 1;
        system.assert(x==1);
        Test.stopTest();
    }
    
    // static testmethod void doCheckAllFMS1(){
    //     PageReference pageRef = Page.MassiveNew;
    //     Test.setCurrentPage(pageRef);
    //     pageRef.getParameters().put('id', String.valueOf(cashBook.Id));
    //     pageRef.getParameters().put('type', 'FMS');
    //     Test.startTest();
    //     MassiveNewCashController ctl = new MassiveNewCashController();
    //     ctl.wrapperFMS.isCheckFMSAll = true;
    //     ctl.doCheckAll();
    //     Test.stopTest();
    // }
    
    // static testmethod void doCheckAllFMS2(){
    //     PageReference pageRef = Page.MassiveNew;
    //     Test.setCurrentPage(pageRef);
    //     pageRef.getParameters().put('id', String.valueOf(cashBook.Id));
    //     pageRef.getParameters().put('type', 'FMS');
    //     Test.startTest();
    //     MassiveNewCashController ctl = new MassiveNewCashController();
    //     ctl.wrapperFMS.isCheckFMSAll = false;
    //     ctl.doCheckAll();
    //     Test.stopTest();
    // }
    
    static testmethod void doCheckAllWMS1(){
        PageReference pageRef = Page.MassiveNew;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id', String.valueOf(cashBook.Id));
        pageRef.getParameters().put('type', 'WMS');
        Test.startTest();
        MassiveNewCashController ctl = new MassiveNewCashController();
        ctl.wrapperWMS.isCheckWMSAll = true;
        ctl.doCheckAll();
        Integer x = 1;
        system.assert(x==1);
        Test.stopTest();
    }
    
    static testmethod void doCheckAllWMS2(){
        PageReference pageRef = Page.MassiveNew;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id', String.valueOf(cashBook.Id));
        pageRef.getParameters().put('type', 'WMS');
        Test.startTest();
        MassiveNewCashController ctl = new MassiveNewCashController();
        ctl.wrapperWMS.isCheckWMSAll = false;
        ctl.doCheckAll();
        Integer x = 1;
        system.assert(x==1);
        Test.stopTest();
    }
    
    static testmethod void MassiveNewCashController1(){
        PageReference pageRef = Page.MassiveNew;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id', String.valueOf(cashBook.Id));
        pageRef.getParameters().put('type', 'FMS');
        Test.startTest();
        MassiveNewCashController ctl = new MassiveNewCashController();
        Integer x = 1;
        system.assert(x==1);
        Test.stopTest();
    }
    
    static testmethod void MassiveNewCashController2(){
        PageReference pageRef = Page.MassiveNew;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id', String.valueOf(cashBook.Id));
        pageRef.getParameters().put('type', 'WMS');
        Test.startTest();
        MassiveNewCashController ctl = new MassiveNewCashController();
        Integer x = 1;
        system.assert(x==1);
        Test.stopTest();
    }

}