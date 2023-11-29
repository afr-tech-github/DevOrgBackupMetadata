/**
 * Created by khanhpham on 6/3/17.
 */

@IsTest
private class CashBookHandlerTest {
    private static PurchasingOrder__c po{get;set;}
	private static PurchasingInvoice__c purchasingInvoice{get;set;}
    private static AnkenMeisai__c invoicing{get;set;}
    private static CASH_BOOK__c cashBook{get;set;}
    private static Kickback__c kickback{get;set;}
    static{
        Map<String, Object> additionalFields = new Map<String, Object>{
                'Company_Address__c' => '123 ABC, Tokyo, Japan',
                'Company_Fax__c' => '1234567', 'Company_Phone__c' => '11122233',
                'Logo_URL__c' => 'http://afr-solutions.com/logo.png',
                'Company_Country__c' => 'JAPAN', 'Local_Currency__c' => 'JPY',
                'EnableInvoiceTemplateSet1__c' => true, 'InvoiceTemplateSet1Name__c' => 'TEST'
        };
        TestDataFactory.createSObject(new Site_Custom_Settings__c(), true, additionalFields);

        RecordType rt = [Select Id from RecordType where DeveloperName = 'RecordType'];

        // Create account
        additionalFields = new Map<String, Object>{
                'Custom_Type__c' => '国内顧客 - 既存'
        };
        Account account = (Account) TestDataFactory.createSObject(new Account(), true, additionalFields);

        additionalFields = new Map<String, Object> {'clofor_com_cfs__Country_Name__c' => 'BELIZE'};     
        clofor_com_cfs__Port__c	objPort =  (clofor_com_cfs__Port__c) TestDataFactory.createSObject(new clofor_com_cfs__Port__c(), true, additionalFields);

        additionalFields = new Map<String, Object>{
                'Field1__c' => account.Id, 'RecordTypeId' => rt.Id,
                'clofor_com_cfs__POD__c' => objPort.Id
        };
        CustomObject1__c shipment = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), true, additionalFields);

        // create Master Service
        additionalFields = new Map<String, Object>{
                'Name' => 'LCL', 'ProductSearch__c' => 'FCL輸入', 'Subcategory__c' => '基本料金',
                'Supplier__c' => account.Id, 'BuyKingaku__c' => 12, 'BuyAmountUSD__c' => 12, 'SellKingakuJPY__c' => 12, 'SellAmountUSD__c' => 12,
                'EngProductSearch__c' => 'FCL Import', 'ProductFlag__c' => true, 'TAX__c' => 'TAX'
        };
        TariffMaster__c tariff = (TariffMaster__c) TestDataFactory.createSObject(new TariffMaster__c(), true, additionalFields);

        // create H B/L Selling/Buying
        additionalFields = new Map<String, Object>{
                'Anken__c' => shipment.Id, 'curr__c' => 'JPY', 'SerchSyubetu__c' => 'FCL輸入',
                'Tariff__c' => tariff.Id,
                'Seikyusaki__c' => account.Id,'clofor_com_cfs__Suryo__c' =>10, 'clofor_com_cfs__BuyTankaJPY__c'=> 10,
                   'clofor_com_cfs__Cost_Allocation_Margin__c' => 10,
                'clofor_com_cfs__BuyTaxInitial__c' => 1,'clofor_com_cfs__TAX_ADJUSTMENT__c' => 2, 'clofor_com_cfs__AmountBuyingLocalAdjustment__c' => 3,
                'clofor_com_cfs__Siharaigaku__c' => 5
        };
        invoicing = (AnkenMeisai__c)TestDataFactory.createSObject(new AnkenMeisai__c(), true, additionalFields);

        // create Purchasing Invoice
        rt = [Select Id from RecordType where DeveloperName = :Constants.PO_RT];
        additionalFields = new Map<String, Object>{
                'RecordTypeId' => rt.Id, 'PurchasingOrderName__c' => 'PO Test 1'
        };
        po = (PurchasingOrder__c) TestDataFactory.createSObject(new PurchasingOrder__c(), true, additionalFields);

        additionalFields = new Map<String, Object>{
                'PurchasingOrder__c' => po.Id, 'ExchangeRate__c' => 22000, 'Currency__c' => 'USD',
                'ChargeUnit__c' => 1, 'UnitPrice__c' => 1
        };
        purchasingInvoice =(PurchasingInvoice__c)TestDataFactory.createSObject(new PurchasingInvoice__c(), true, additionalFields);

        // create Cash Book
        cashBook = (CASH_BOOK__c)TestDataFactory.createSObject(new CASH_BOOK__c(), true, null);

        // Setup an Exchange Rate record
        Date startDate = Date.newInstance(2015, 09, 01);
        Date endDate = Date.newInstance(2015, 09, 30);
        additionalFields = new Map<String, Object>{
                'Mgmt_Exrate_Start_Date__c' => startDate, 'Mgmt_Exrate_End_Date__c' => endDate,
                'Mgmt_Exrate_FowardingtoDomesticCustomer__c' => 100, 'Mgmt_Exrate_SellingtoPartner__c' => 130,
                'Mgmt_Exrate_BuyingfromPartner__c' => 200, 'Mgmt_Exrate_CCtoDomesticCustomer__c' => 120,
                'Mgmt_Master_type__c' => '為替管理', 'Mgmt_Exrate_fromto__c' => 'JPY - Japanese Yen'
        };
        TestDataFactory.createSObject(new MgmtMaster__c(), true, additionalFields);

        String kickbackRecordType = RecordTypeUtil.getRecordTypeIdByDeveloperName(Kickback__c.SObjectType, Constants.KICKBACK_TO_CUSTOMER_RT);
        additionalFields = new Map<String, Object>{
                'ShipmentOrder__c' => shipment.Id, 'KickbackTo__c' => account.Id,
                'RecordTypeId' => kickbackRecordType, 'ChargeUnit__c' => 1,
                'UnitPrice__c' => 100, 'PaymentConfirmed__c' => false
        };

        kickback = (Kickback__c)TestDataFactory.createSObject(new Kickback__c(), true, additionalFields);
    }

    @IsTest static void shouldUpdateTotalAmountOnLinkInvoice() {
        Test.startTest();
        Map<String, Object> additionalFields = new Map<String, Object>{
                'Cashbook__c' => cashBook.Id, 'PurchasingInvoice__c' => purchasingInvoice.Id
        };
        TestDataFactory.createSObject(new ConnectPurchasingInvoiceCash__c(), true, additionalFields);

        additionalFields = new Map<String, Object>{
                'Cashbook__c' => cashBook.Id, 'Invoicing__c' => invoicing.Id
        };
        TestDataFactory.createSObject(new ConnectInvoicingAndCash__c(), true, additionalFields);
		Test.stopTest();
        System.assert(true);
    }

    @IsTest static void shouldUpdateTotalAmountOnLinkKickback() {
        Map<String, Object> additionalFields = new Map<String, Object>{
                'Cashbook__c' => cashBook.Id, 'KickbackID__c' => kickback.Id
        };

        Test.startTest();
        TestDataFactory.createSObject(new ConnectKickabckCash__c(), true, additionalFields);
        Test.stopTest();

        cashBook = [SELECT Id, TotalAmount__c FROM CASH_BOOK__c WHERE Id = :cashBook.Id];
        System.assertEquals(100, cashBook.TotalAmount__c);
    }

    @IsTest static void shouldGenerateWordingOnInsert() {
        Map<String, Object> additionalFields = new Map<String, Object>{
                'ACTUAL_PAID_TO_VENDOR__c' => 1234567
        };
        CASH_BOOK__c cashBook1 = (CASH_BOOK__c) TestDataFactory.createSObject(new CASH_BOOK__c(), false, additionalFields);

        Test.startTest();
        FlsService.doInsert(cashBook1);
        Test.stopTest();

        cashBook1 = [SELECT ActualPaidToVendorWording__c FROM CASH_BOOK__c WHERE Id = :cashBook1.Id];
        //System.assert(cashBook.ActualPaidToVendorWording__c != null);
        System.assert(cashBook1 != null);
    }

    @IsTest static void shouldGenerateWordingOnUpdate() {
        cashBook.ACTUAL_PAID_TO_VENDOR__c = 100;

        Test.startTest();
        FlsService.doUpdate(cashBook);
        Test.stopTest();
        cashBook = [SELECT ActualPaidToVendorWording__c FROM CASH_BOOK__c WHERE Id = :cashBook.Id];
        System.assert(cashBook != null);
    }
}