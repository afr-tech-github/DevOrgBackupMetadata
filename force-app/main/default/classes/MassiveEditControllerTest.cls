/**
 * Created by khanhpham on 6/14/17.
 */

@IsTest(SeeAllData=false)
private with sharing class MassiveEditControllerTest {
    @TestSetup static void setUp() {
        setUpCargoDeliveries();
        setupLoadingLocations();
        setUpPurchasingInvoices();
        ApexPages.currentPage().getParameters().put('action','new');
        //ApexPages.currentPage().getParameters().put('action','newaction');
       	//	ApexPages.currentPage().getParameters().put('isCreation','true');
    }

    private static void setUpCargoDeliveries() {
        RecordType rt = [Select Id from RecordType where DeveloperName = :Constants.OCEAN_IMPORT_RT];
        Account account = (Account) TestDataFactory.createSObject(new Account(), true, null);
 		Site_Custom_Settings__c setting = new Site_Custom_Settings__c();
        setting.LocalCurrencyBankAccountShortName1__c = 'Bank 1';
        setting.LocalCurrencyBankAccountShortName2__c = 'Bank 2';
        setting.LocalCurrencyBankAccountShortName3__c = 'Bank 3';
        setting.LocalCurrencyBankAccountShortName4__c = 'Bank 4';
        setting.LocalCurrencyBankAccountShortName5__c = 'Bank 5';
        setting.FCYBankAccountShortName1__c = 'Bank Foreign 1';
        setting.FCYBankAccountShortName2__c = 'Bank Foreign 2';
        setting.FCYBankAccountShortName3__c = 'Bank Foreign 3';
        setting.FCYBankAccountShortName4__c = 'Bank Foreign 4';
        setting.FCYBankAccountShortName5__c = 'Bank Foreign 5';
        setting.Company_Country__c = 'VN';
        setting.Local_Currency__c = 'VND';
        setting.clofor_com_cfs__Disable_Monthly_Yearly_HBL_ID__c = false;
        insert setting;
        Map<String, Object> additionalFields = new Map<String, Object>{
                'Field1__c' => account.Id, 'RecordTypeId' => rt.Id, 'HBL__c' => '345678'
        };
        CustomObject1__c shipment = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), true, additionalFields);

        rt = [Select Id from RecordType where DeveloperName = 'Consolidation_Truck_Import'];
        additionalFields = new Map<String, Object>{
                'HBL_SHIPMENT__c' => shipment.Id, 'RecordTypeId' => rt.Id
        };
        TestDataFactory.createSObject(new Cargo_Delivery__c(), true, additionalFields);
        TestDataFactory.createSObject(new Cargo_Delivery__c(), true, additionalFields);
    }

    private static void setupLoadingLocations() {
        RecordType rt = [Select Id from RecordType where DeveloperName = 'FULL_CONTAINER_TRUCK'];
        Date routingDate = Date.newInstance(2017, 6, 10);
        Map<String, Object> additionalFields = new Map<String, Object>{
                'RecordTypeId' => rt.Id
        };
        TruckFleet__c truck = (TruckFleet__c) TestDataFactory.createSObject(new TruckFleet__c(), true, additionalFields);

        additionalFields = new Map<String, Object>{
                'RoutingDate__c' => routingDate, 'Truck__c' => truck.Id
        };
        Route__c route = (Route__c) TestDataFactory.createSObject(new Route__c(), true, additionalFields);

        additionalFields = new Map<String, Object>{
                'Route__c' => route.Id, 'SequenceNumber__c' => 1, 'HandlingType__c' => 'Load'
        };
        TestDataFactory.createSObject(new LoadingLocation__c(), true, additionalFields);
		
        additionalFields = new Map<String, Object>{
                'Route__c' => route.Id, 'SequenceNumber__c' => 2, 'HandlingType__c' => 'Load'
        };
        TestDataFactory.createSObject(new LoadingLocation__c(), true, additionalFields);
    }

    private static void setUpPurchasingInvoices() {
        RecordType rt = [Select Id from RecordType where DeveloperName = 'PurchasingOrder'];
        Map<String, Object> additionalFields = new Map<String, Object>{
                'RecordTypeId' => rt.Id, 'PurchasingOrderName__c' => 'PO0001'
        };
        PurchasingOrder__c purchasingOrder = (PurchasingOrder__c) TestDataFactory.createSObject(new PurchasingOrder__c(), true, additionalFields);

        additionalFields = new Map<String, Object>{
                'PurchasingOrder__c' => purchasingOrder.Id
        };
        TestDataFactory.createSObject(new PurchasingInvoice__c(), true, additionalFields);
        TestDataFactory.createSObject(new PurchasingInvoice__c(), true, additionalFields);
    }

    @IsTest static void shouldUpdateCargoDeliveries() {
        CustomObject1__c shipment = [SELECT Id FROM CustomObject1__c WHERE HBL__c = '345678'];
        PageReference pageReference = Page.MassiveEdit;
        Test.setCurrentPage(pageReference);
        ApexPages.currentPage().getParameters().put('id', shipment.Id);
        ApexPages.currentPage().getParameters().put('obj', MassiveEditController.CARGO_DELIVERY_OBJECT);
        ApexPages.currentPage().getParameters().put('action', 'new');
        
        MassiveEditController controller = new MassiveEditController();
        controller.init();

        Test.startTest();
        controller.updateRecords();
        Test.stopTest();

        ApexPages.Message[] messages = ApexPages.getMessages();
        System.assertEquals(0, messages.size());
    }

    @IsTest static void shouldUpdateLoadingLocations() {
        Route__c route = [SELECT Id FROM Route__c LIMIT 1];
        PageReference pageReference = Page.MassiveEdit;
        Test.setCurrentPage(pageReference);
        ApexPages.currentPage().getParameters().put('id', route.Id);
        ApexPages.currentPage().getParameters().put('obj', MassiveEditController.LOADING_LOCATION_OBJECT);
        MassiveEditController controller = new MassiveEditController();
        controller.init();

        Test.startTest();
        controller.updateRecords();
        Test.stopTest();

        ApexPages.Message[] messages = ApexPages.getMessages();
        System.assertEquals(0, messages.size());
    }

    @IsTest static void shouldUpdatePurchasingInvoices() {
        PurchasingOrder__c purchasingOrder = [SELECT Id FROM PurchasingOrder__c LIMIT 1];
        PageReference pageReference = Page.MassiveEdit;
        Test.setCurrentPage(pageReference);
    //    ApexPages.currentPage().getParameters().put('id', purchasingOrder.Id);
  //      ApexPages.currentPage().getParameters().put('obj', MassiveEditController.LOADING_LOCATION_OBJECT);
    //    ApexPages.currentPage().getParameters().put('obj', MassiveEditController.CARGO_DELIVERY_OBJECT);
    //    ApexPages.currentPage().getParameters().put('obj', MassiveEditController.PURCHASING_INVOICE_OBJECT);
     //   ApexPages.currentPage().getParameters().put('obj', MassiveEditController.CONSOL_BUYING_OBJECT);
     //   ApexPages.currentPage().getParameters().put('obj', MassiveEditController.INVOICING_VAT_OBJECT);
    //    ApexPages.currentPage().getParameters().put('obj', MassiveEditController.SHIPMENT_VAT_OBJECT);
  //      ApexPages.currentPage().getParameters().put('obj', MassiveEditController.EXCHANGE_RATE_OBJECT);
    //    ApexPages.currentPage().getParameters().put('obj', MassiveEditController.CARGO_DELIVERY_OBJECT);
        ApexPages.currentPage().getParameters().put('numberOfRecords','67');
        
        
       	List<Cargo_Delivery__c> originalCargoDeliveryList = new List<Cargo_Delivery__c>();
        insert originalCargoDeliveryList;
        List<Cargo_Delivery__c> cargoDeliveryList = new List<Cargo_Delivery__c>();
        MassiveEditController controller = new MassiveEditController();
      	controller.originalCargoDeliveryList = originalCargoDeliveryList;
        controller.cargoDeliveryList = cargoDeliveryList;
        List<LoadingLocation__c> loadingLocationList = new List<LoadingLocation__c>();
        controller.loadingLocationList = loadingLocationList;
        List<PurchasingInvoice__c> purchasingInvoiceList = new List<PurchasingInvoice__c>();
        controller.purchasingInvoiceList = purchasingInvoiceList;
        List<MasterAnkenMeisai__c> consolBuyngList = new List<MasterAnkenMeisai__c>();
        controller.consolBuyngList = consolBuyngList;
        List<INVOICING_VAT__c> invoicingVATList = new List<INVOICING_VAT__c>();
        controller.invoicingVATList = invoicingVATList;
        List<FORWARDING_VAT__c> shipmentVATList = new List<FORWARDING_VAT__c>();
        controller.shipmentVATList = shipmentVATList;
        List<MgmtMaster__c> exchangeRateList = new List<MgmtMaster__c>();
        controller.exchangeRateList = exchangeRateList;
        controller.resetCargoDeliveries();
        
        
        controller.init();
        controller.populateDeliveryDestinationInfos();
        controller.populateContainerIDForCargoDelivery();
             
        
     //   controller.createNewRecords();
        controller.cancel();
        
        Test.startTest();
        controller.updateRecords();
        
        
        Test.stopTest();

        ApexPages.Message[] messages = ApexPages.getMessages();
        // System.assertEquals(0, messages.size());
    }
     @IsTest static void shouldLoadingLocation() {
        CustomObject1__c shipment = [SELECT Id FROM CustomObject1__c WHERE HBL__c = '345678'];
        PageReference pageReference = Page.MassiveEdit;
        Test.setCurrentPage(pageReference);
        ApexPages.currentPage().getParameters().put('id', shipment.Id);
        ApexPages.currentPage().getParameters().put('obj', MassiveEditController.LOADING_LOCATION_OBJECT);
        ApexPages.currentPage().getParameters().put('action', 'new');
        
        MassiveEditController controller = new MassiveEditController();
        controller.init();

        Test.startTest();
        controller.updateRecords();
        Test.stopTest();
     } 
    @IsTest static void shouldPurchasingInvoice() {
        CustomObject1__c shipment = [SELECT Id FROM CustomObject1__c WHERE HBL__c = '345678'];
        PageReference pageReference = Page.MassiveEdit;
        Test.setCurrentPage(pageReference);
        ApexPages.currentPage().getParameters().put('id', shipment.Id);
        ApexPages.currentPage().getParameters().put('obj', MassiveEditController.PURCHASING_INVOICE_OBJECT);
        ApexPages.currentPage().getParameters().put('action', 'new');
        
        MassiveEditController controller = new MassiveEditController();
        controller.init();

        Test.startTest();
        controller.updateRecords();
        Test.stopTest();
     } 
    @IsTest static void shouldMasterAnkenMeisai() {
        CustomObject1__c shipment = [SELECT Id FROM CustomObject1__c WHERE HBL__c = '345678'];
        PageReference pageReference = Page.MassiveEdit;
        Test.setCurrentPage(pageReference);
        ApexPages.currentPage().getParameters().put('id', shipment.Id);
        ApexPages.currentPage().getParameters().put('obj', MassiveEditController.CONSOL_BUYING_OBJECT);
        ApexPages.currentPage().getParameters().put('action', 'new');
        
        MassiveEditController controller = new MassiveEditController();
        controller.init();

        Test.startTest();
        controller.updateRecords();
        Test.stopTest();
     } 
    @IsTest static void shouldINVOICINGVAT() {
        CustomObject1__c shipment = [SELECT Id FROM CustomObject1__c WHERE HBL__c = '345678'];
        PageReference pageReference = Page.MassiveEdit;
        Test.setCurrentPage(pageReference);
        ApexPages.currentPage().getParameters().put('id', shipment.Id);
        ApexPages.currentPage().getParameters().put('obj', MassiveEditController.INVOICING_VAT_OBJECT);
        ApexPages.currentPage().getParameters().put('action', 'new');
        
        MassiveEditController controller = new MassiveEditController();
        controller.init();

        Test.startTest();
        controller.updateRecords();
        Test.stopTest();
     } 
    @IsTest static void shouldFORWARDINGVAT() {
        CustomObject1__c shipment = [SELECT Id FROM CustomObject1__c WHERE HBL__c = '345678'];
        PageReference pageReference = Page.MassiveEdit;
        Test.setCurrentPage(pageReference);
        ApexPages.currentPage().getParameters().put('id', shipment.Id);
        ApexPages.currentPage().getParameters().put('obj', MassiveEditController.SHIPMENT_VAT_OBJECT);
        ApexPages.currentPage().getParameters().put('action', 'new');
        
        MassiveEditController controller = new MassiveEditController();
        controller.init();

        Test.startTest();
        controller.updateRecords();
        Test.stopTest();
     } 
    
}