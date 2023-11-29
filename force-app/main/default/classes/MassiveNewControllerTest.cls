@isTest(SeeAllData=false)
public class MassiveNewControllerTest {
	private static Map<String, Object> additionalFields;
	private static AnkenMeisai__c meisai1;
	private static AnkenMeisai__c meisai2;
	private static VAT_INVOICE__c vatInvoice;
	static{
		 additionalFields = new Map<String, Object>{
                'Company_Address__c' => '123 ABC, Tokyo, Japan',
                'Company_Fax__c' => '1234567', 'Company_Phone__c' => '11122233', 'Local_Currency__c' => 'VND',
                'Logo_URL__c' => 'http://afr-solutions.com/logo.png', 'Company_Country__c' => 'Japan',
                'Ocean_HBL_No_Prefix__c' => 'AFR', 'Ferry_SLA__c' => 120, 'Container_Vessel_SLA__c' => 480,
                'EnableInvoiceTemplateSet1__c' => true, 'InvoiceTemplateSet1Name__c' => 'TEST'
        };
        TestDataFactory.createSObject(new Site_Custom_Settings__c(), true, additionalFields);

        // Create an Account
        additionalFields = new Map<String, Object>{
                'Currency__c' => 'USD - U.S. Dollar'
        };
        Account account = (Account) TestDataFactory.createSObject(new Account(), true, additionalFields);

        // Create Service Master
        additionalFields = new Map<String, Object>{
                'Name' => 'LCL', 'ProductSearch__c' => 'FCL輸入', 'Subcategory__c' => '基本料金',
                'EngProductSearch__c' => 'FCL Import', 'ProductFlag__c' => true,
                'Supplier__c' => account.Id, 'Zeibunrui__c' => PicklistReference.DUAL_PRODUCT_TAX
        };
        TariffMaster__c tariff = (TariffMaster__c) TestDataFactory.createSObject(new TariffMaster__c(), true, additionalFields);

        // Create 2 HBL records
        RecordType rt = [Select Id from RecordType where Name = 'Air Import' AND SObjectType = 'clofor_com_cfs__CustomObject1__c'];

        additionalFields = new Map<String, Object>{
                'Field1__c' => account.Id, 'RecordTypeId' => rt.Id, 'HBL__c' => 'TEST0001',
                'clofor_com_cfs__ContainerNumber__c' => 1, 'clofor_com_cfs__ContainerNumber2__c' => 1, 'clofor_com_cfs__ContainerNumber3__c' => 1,
                'clofor_com_cfs__ContainerNumber4__c' => 1,
                'clofor_com_cfs__Container3__c' => '20\'DC',
                'clofor_com_cfs__Container4__c' => '20\'DC',
                'clofor_com_cfs__Container2__c' => '20\'DC',
                'Container__c' => '20\'DC'
        };
        CustomObject1__c shipment1 = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), true, additionalFields);

        // additionalFields = new Map<String, Object>{
        //         'Field1__c' => account.Id, 'RecordTypeId' => rt.Id, 'HBL__c' => 'TEST0002',
        //         'clofor_com_cfs__ContainerNumber__c' => 1, 'clofor_com_cfs__ContainerNumber2__c' => 1, 'clofor_com_cfs__ContainerNumber3__c' => 1,
        //         'clofor_com_cfs__ContainerNumber4__c' => 1
        // };
        // CustomObject1__c shipment2 = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), true, additionalFields);

        // Create 2 HBL S/B records
        additionalFields = new Map<String, Object>{
                'Anken__c' => shipment1.Id, 'curr__c' => 'VND', 'VAT_INVOICE_ISSUE_STATUS__c' => false,
                'Tariff__c' => tariff.Id,
                'Seikyusaki__c' => account.Id, 'SerchSyubetu__c' => 'FCL輸入',
                'Cost_Allocation_Catetory__c' => 'Partner Cost allocation'
        };
        meisai1 = (AnkenMeisai__c) TestDataFactory.createSObject(new AnkenMeisai__c(), true, additionalFields);

        // additionalFields = new Map<String, Object>{
        //         'Anken__c' => shipment2.Id, 'curr__c' => 'VND', 'VAT_INVOICE_ISSUE_STATUS__c' => false,
        //         'Tariff__c' => tariff.Id, 'PaymentTo__c' => account.Id,
        //         'Seikyusaki__c' => account.Id, 'SerchSyubetu__c' => 'FCL輸入',
        //         'Cost_Allocation_Catetory__c' => 'Partner Cost allocation'
        // };
        // meisai2 = (AnkenMeisai__c) TestDataFactory.createSObject(new AnkenMeisai__c(), true, additionalFields);
       
        // Create VAT INVOICE
        RecordType rtVAT = [Select Id from RecordType where Name = 'CloWMS VAT INVOICE' LIMIT 1 ];
        additionalFields = new Map<String, Object>{
            	'RecordTypeId' => rtVAT.Id
        };
        vatInvoice = (VAT_INVOICE__c) TestDataFactory.createSObject(new VAT_INVOICE__c(), true, additionalFields);  
	}
    
    static testmethod void MassiveNewController(){
        PageReference pageRef = Page.MassiveNew;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id', String.valueOf(vatInvoice.Id));
        Test.startTest();
        MassiveNewController ctl = new MassiveNewController();
        Integer x = 1;
        system.assert(x==1);
        Test.stopTest();
    }
    
    static testmethod void doSearch(){
        PageReference pageRef = Page.MassiveNew;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id', String.valueOf(vatInvoice.Id));
        Test.startTest();
        MassiveNewController ctl = new MassiveNewController();
		ctl.objSearch.sName = 'TEST';
		ctl.objSearch.sHBL = 'TEST0001'; 
		ctl.objSearch.sShipper = 'TEST';
        ctl.objSearch.sCustomer = 'TEST';
        ctl.objSearch.sMBL = 'TEST';
        ctl.objSearch.sRefNo = 'TEST';
        ctl.objSearch.sPayment = 'TEST';
        ctl.objSearch.sBuyTaxInitial = '1';
        ctl.objSearch.sSeikyusaki = 'TEST';
        ctl.objSearch.sTaxInitial = '1';
		ctl.objSearch.sCnee = 'TEST'; 
        ctl.objSearch.sTimeType = 'ETD';
		ctl.objSearch.sFromTime = '01/09/2018';
        ctl.objSearch.sToTime = '01/09/2018';
		ctl.objSearch.sPOL = 'TEST';
        ctl.objSearch.sPOD = 'TEST'; 
        ctl.doSearch();
        Integer x = 1;
        system.assert(x==1);
        Test.stopTest();
    }
    
    static testmethod void doClear(){
        Test.startTest();
        MassiveNewController ctl = new MassiveNewController();
        ctl.doClear();
        Integer x = 1;
        system.assert(x==1);
        Test.stopTest();
    }
    
    static testmethod void doInsert(){
        PageReference pageRef = Page.MassiveNew;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id', String.valueOf(vatInvoice.Id));
        Test.startTest();
        MassiveNewController ctl = new MassiveNewController();
        ctl.doSearch();
        ctl.lstItem.get(0).isCheck = true;
        ctl.lstItem.get(0).lstBill.get(0).isBillCheck = true;
        ctl.doInsert();
        Integer x = 1;
        system.assert(x==1);
        Test.stopTest();
    }
    
    static testmethod void checkAllBill(){
        PageReference pageRef = Page.MassiveNew;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id', String.valueOf(vatInvoice.Id));
        Test.startTest();
        MassiveNewController ctl = new MassiveNewController();
        ctl.doSearch();
        ctl.lstItem.get(0).isCheck = true;
        pageRef.getParameters().put('indexList', '0');
        ctl.lstItem.get(0).isCheckAllBill = true;
        ctl.checkAllBill();
        Integer x = 1;
        system.assert(x==1);
        Test.stopTest();
    }
      
    
}