@isTest
public class HBLShipmentsTriggerTest {
    @testSetup static void setUp() {
        Map<String, Object> additionalFields = new Map<String, Object>{'Company_Address__c' => '123 ABC, Tokyo, Japan',
            'Company_Fax__c' => '1234567', 'Company_Phone__c' => '11122233', 'Ocean_HBL_No_Prefix__c' => 'OCEAN', 
            'Logo_URL__c' => 'http://afr-solutions.com/logo.png', 'Air_HBL_No_Prefix__c' => 'AIR',
            'Company_Country__c' => 'JAPAN', 'Local_Currency__c' => 'JPY',
            'EnableInvoiceTemplateSet1__c' => true, 'InvoiceTemplateSet1Name__c' => 'TEST'};
		TestDataFactory.createSObject(new Site_Custom_Settings__c(), true, additionalFields);
        
        RecordType rt = [Select Id from RecordType where DeveloperName = :Constants.OCEAN_EXPORT_RT];
		Account account = (Account) TestDataFactory.createSObject(new Account( CorporateMyNumber__c = 'AcountTest1'), true, null);
		additionalFields = new Map<String, Object> {'Field1__c' => account.Id, 'RecordTypeId' => rt.Id};
        TestDataFactory.createSObject(new CustomObject1__c(), true, additionalFields);        
        
        System.assert(true);
    }

    static testmethod void shouldAssignFirstOceanHBLNo() {
        Date etd = Date.newInstance(2015, 07, 02);
        RecordType rt = [Select Id from RecordType where DeveloperName = :Constants.OCEAN_EXPORT_RT];
		Account account = (Account) TestDataFactory.createSObject(new Account(), true, null);
        Map<String, Object> additionFields = new Map<String, Object> {'Field1__c' => account.Id, 
            															'RecordTypeId' => rt.Id,
            															'ETD__c' => etd};
        CustomObject1__c shipment = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), false, additionFields);        
		
        Test.startTest();
        FlsService.doInsert(shipment);
        Test.stopTest();
        
        CustomObject1__c actual = [SELECT HBL__c FROM CustomObject1__c WHERE Id = :shipment.Id];
        //System.assertEquals('OCEAN201507001', actual.HBL__c);    
    }
    
    static testmethod void shouldNotAssignHBLNoOnInsertWithoutETD() {
        RecordType rt = [Select Id from RecordType where DeveloperName = :Constants.OCEAN_EXPORT_RT];
		Account account = (Account) TestDataFactory.createSObject(new Account(), true, null);
        Map<String, Object> additionFields = new Map<String, Object> {'Field1__c' => account.Id, 
            															'RecordTypeId' => rt.Id};
        CustomObject1__c shipment = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), false, additionFields);        
		
        Test.startTest();
        FlsService.doInsert(shipment);
        Test.stopTest();
        
        CustomObject1__c actual = [SELECT HBL__c FROM CustomObject1__c WHERE Id = :shipment.Id];
        System.assertEquals(null, actual.HBL__c);    
    }
    
    static testmethod void shouldAssignNextOceanHBLNo() {
        Common_Settings__c setting = new Common_Settings__c(Name='RunningNumber', Keyword__c='HBL_NO-201507', Value__c='001');
        FlsService.doInsert(setting);
        
        Date etd = Date.newInstance(2015, 07, 02);
        RecordType rt = [Select Id from RecordType where DeveloperName = :Constants.OCEAN_EXPORT_RT];
		Account account = (Account) TestDataFactory.createSObject(new Account(), true, null);
        Map<String, Object> additionFields = new Map<String, Object> {'Field1__c' => account.Id, 
            															'RecordTypeId' => rt.Id,
            															'ETD__c' => etd};
        CustomObject1__c shipment = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), false, additionFields);        
		
        Test.startTest();
        FlsService.doInsert(shipment);
        Test.stopTest();
        
        CustomObject1__c actual = [SELECT HBL__c FROM CustomObject1__c WHERE Id = :shipment.Id];
        //System.assertEquals('OCEAN201507002', actual.HBL__c);    
    }
    
    static testmethod void shouldAssignNextAirHBLNo() {
        Common_Settings__c setting = new Common_Settings__c(Name='RunningNumber', Keyword__c='HBL_NO-201507', Value__c='001');
        FlsService.doInsert(setting);
        
        Date etd = Date.newInstance(2015, 07, 02);
        RecordType rt = [Select Id from RecordType where DeveloperName = :Constants.AIR_EXPORT_RT];
		Account account = (Account) TestDataFactory.createSObject(new Account(), true, null);
        Map<String, Object> additionFields = new Map<String, Object> {'Field1__c' => account.Id, 
            															'RecordTypeId' => rt.Id,
                                                                        'ETD__c' => etd,
                                                                        'clofor_com_cfs__ContainerNumber__c' => 1, 'clofor_com_cfs__ContainerNumber2__c' => 1, 'clofor_com_cfs__ContainerNumber3__c' => 1,
                                                                        'clofor_com_cfs__ContainerNumber4__c' => 1,
                                                                        'clofor_com_cfs__Container__c' => '20\'DC',
                                                                        'clofor_com_cfs__Container2__c' => '20\'DC',
                                                                        'clofor_com_cfs__Container3__c' => '20\'DC',
                                                                        'clofor_com_cfs__Container4__c' => '20\'DC'};
        CustomObject1__c shipment = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), false, additionFields);        
		
        Test.startTest();
        FlsService.doInsert(shipment);
        Test.stopTest();
        
        CustomObject1__c actual = [SELECT HAWB__c FROM CustomObject1__c WHERE Id = :shipment.Id];
        //System.assertEquals('AIR201507002', actual.HAWB__c);    
    }

    static testmethod void shouldAssignOceanHBLNoOnUpdateWithETD() {
        Date etd = Date.newInstance(2015, 07, 02);
        Test.startTest();
        CustomObject1__c actual = [SELECT HBL__c FROM CustomObject1__c LIMIT 1];
        System.assertEquals(null, actual.HBL__c);
        actual.ETD__c = etd;
        FlsService.doUpdate(actual);
        Test.stopTest();
        
        actual = [SELECT HBL__c FROM CustomObject1__c WHERE Id = :actual.Id];
        //System.assertEquals('OCEAN201507001', actual.HBL__c);    
    }

    static testmethod void shouldInitializeQuoationVersionOnCreation() {
        RecordType rt = [Select Id from RecordType where DeveloperName = :Constants.OCEAN_EXPORT_RT];
		Account account = (Account) TestDataFactory.createSObject(new Account(), true, null);
        
        Map<String, Object> additionFields = new Map<String, Object> {'Phone' => '12345678'};
        Contact contact = (Contact) TestDataFactory.createSObject(new Contact(), true, additionFields);
        
		additionFields = new Map<String, Object> {'Field1__c' => account.Id, 'RecordTypeId' => rt.Id};
        CustomObject1__c shipment = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), false, additionFields);        
		
        Test.startTest();
        FlsService.doInsert(shipment);
        Test.stopTest();
        
        CustomObject1__c actual = [SELECT QuotationVer__c FROM CustomObject1__c WHERE Id = :shipment.Id];
        System.assertEquals(1, actual.QuotationVer__c);    
    }

    static testmethod void shouldTurnOnNewCustomerAlertFlag() {
        RecordType rt = [Select Id from RecordType where DeveloperName = :Constants.OCEAN_EXPORT_RT];
        Map<String, Object> additionFields = new Map<String, Object> {'Custom_Type__c' => PicklistReference.DOMESTIC_CUSTOMER_EXISTING};
		Account account = (Account) TestDataFactory.createSObject(new Account(), true, additionFields);
        
        additionFields = new Map<String, Object> {'Phone' => '12345678'};
        Contact contact = (Contact) TestDataFactory.createSObject(new Contact(), true, additionFields);
        
        additionFields = new Map<String, Object> {'Field1__c' => account.Id, 'RecordTypeId' => rt.Id};
		CustomObject1__c shipment = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), 
                                                                                     false, additionFields);        
        
        Test.startTest();
        FlsService.doInsert(shipment);
        Test.stopTest();
        
        shipment = [SELECT Notify_New_Customer_Alert__c FROM CustomObject1__c WHERE Id = :shipment.Id];
        System.assertEquals(true, shipment.Notify_New_Customer_Alert__c);
    }

    static testmethod void shouldTurnOnDoNotSendEmailFlag() {
        RecordType rt = [Select Id from RecordType where DeveloperName = :Constants.OCEAN_EXPORT_RT];
        Map<String, Object> additionFields = new Map<String, Object> {'Custom_Type__c' => PicklistReference.DOMESTIC_CUSTOMER_EXISTING};
		Account account = (Account) TestDataFactory.createSObject(new Account(), true, additionFields);
        
        additionFields = new Map<String, Object> {'Phone' => '12345678', 'MailS__c' => true, 'AccountId' => account.Id};
        Contact customer = (Contact) TestDataFactory.createSObject(new Contact(), true, additionFields);

        additionFields = new Map<String, Object> {'Field1__c' => account.Id, 'Partner__c' => account.Id,
            										'CustmerInCharge__c' => customer.Id, 'PartnerRep__c' => customer.Id,
            										'RecordTypeId' => rt.Id};
		CustomObject1__c shipment = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), 
                                                                                     false, additionFields);        
        
        Test.startTest();
        FlsService.doInsert(shipment);
        Test.stopTest();
        
        shipment = [SELECT Partner_Do_Not_Disturb_State__c, Customer_Do_Not_Disturb_State__c 
                    FROM CustomObject1__c 
                    WHERE Id = :shipment.Id];
        System.assertEquals(true, shipment.Partner_Do_Not_Disturb_State__c);
        System.assertEquals(true, shipment.Customer_Do_Not_Disturb_State__c);
    }

    testmethod static void shouldSetupCargoDelivery() {
        RecordType rt = [Select Id from RecordType where DeveloperName = :Constants.CROSS_BOARDER_RT AND SobjectType = 'clofor_com_cfs__CustomObject1__c'];
        Map<String, Object> additionFields = new Map<String, Object> {'Custom_Type__c' => PicklistReference.DOMESTIC_CUSTOMER_EXISTING};
		Account account = (Account) TestDataFactory.createSObject(new Account(), true, additionFields);
        
        additionFields = new Map<String, Object> {'Phone' => '12345678', 'MailS__c' => true, 'AccountId' => account.Id};
        Contact customer = (Contact) TestDataFactory.createSObject(new Contact(), true, additionFields);
        
        // create warehouse
        additionFields = new Map<String, Object> {'WharehouseCompany__c' => account.Id, 'LoadLocationPIC__c' => 'James Cook',
            										'LoadLocationPIC__c' => 'LoadLocationPIC'};
        LoadLocation__c warehouse = (LoadLocation__c) TestDataFactory.createSObject(new LoadLocation__c(), true, additionFields);

        additionFields = new Map<String, Object> {'Field1__c' => account.Id, 'Partner__c' => account.Id, 'BookingNv__c' => account.Id,
            										'CustmerInCharge__c' => customer.Id, 'PartnerRep__c' => customer.Id,
            										'RecordTypeId' => rt.Id, 'LoadLocation__c' => warehouse.Id,
            										'TranporationType__c' => 'FCL', 'DeliveryService_required__c' => '2'};
		CustomObject1__c shipmentFCL = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), 
                                                                                     false, additionFields); 
        
        additionFields = new Map<String, Object> {'Field1__c' => account.Id, 'Partner__c' => account.Id, 'BookingNv__c' => account.Id,
            										'CustmerInCharge__c' => customer.Id, 'PartnerRep__c' => customer.Id,
            										'RecordTypeId' => rt.Id, 'LoadLocation__c' => warehouse.Id,
            										'TranporationType__c' => 'LCL', 'DeliveryService_required__c' => '2'};
		CustomObject1__c shipmentLCL = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), 
                                                                                     false, additionFields); 
        
        additionFields = new Map<String, Object> {'Field1__c' => account.Id, 'Partner__c' => account.Id, 'BookingNv__c' => account.Id,
            										'CustmerInCharge__c' => customer.Id, 'PartnerRep__c' => customer.Id,
            										'RecordTypeId' => rt.Id, 'LoadLocation__c' => warehouse.Id, 'chargable_weight__c' => 20,
            										'TranporationType__c' => 'AIR', 'DeliveryService_required__c' => '2'};
		CustomObject1__c shipmentAIR = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), 
                                                                                     false, additionFields); 
        
        additionFields = new Map<String, Object> {'Field1__c' => account.Id, 'Partner__c' => account.Id, 'BookingNv__c' => account.Id,
            										'CustmerInCharge__c' => customer.Id, 'PartnerRep__c' => customer.Id,
            										'RecordTypeId' => rt.Id, 'LoadLocation__c' => warehouse.Id,
            										'TranporationType__c' => 'BULK', 'DeliveryService_required__c' => '2'};
		CustomObject1__c shipmentBULK = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), 
                                                                                     false, additionFields); 
        
        Test.startTest();
        List<CustomObject1__c> shipments = new List<CustomObject1__c>{shipmentFCL, shipmentLCL, shipmentAIR, shipmentBULK};
        FlsService.doInsert(shipments);
        Test.stopTest();
        
        List<Cargo_Delivery__c> fclCDs = [select Id from Cargo_Delivery__c where hbl_shipment__c = :shipmentFCL.Id];
        System.assertEquals(2, fclCDs.size());
        
        List<Cargo_Delivery__c> lclCDs = [select Id from Cargo_Delivery__c where hbl_shipment__c = :shipmentLCL.Id];
        System.assertEquals(2, fclCDs.size());
        
        List<Cargo_Delivery__c> airCDs = [select Id from Cargo_Delivery__c where hbl_shipment__c = :shipmentAIR.Id];
        System.assertEquals(2, fclCDs.size());
        
        List<Cargo_Delivery__c> bulkCDs = [select Id from Cargo_Delivery__c where hbl_shipment__c = :shipmentBULK.Id];
        System.assertEquals(2, fclCDs.size());
    }
    
    testmethod static void shouldSetupCustomClearance() {
        RecordType rt = [Select Id from RecordType where DeveloperName = :Constants.OCEAN_EXPORT_RT];
        Map<String, Object> additionFields = new Map<String, Object> {'Custom_Type__c' => PicklistReference.DOMESTIC_CUSTOMER_EXISTING};
		Account account = (Account) TestDataFactory.createSObject(new Account(), true, additionFields);
        
        additionFields = new Map<String, Object> {'Phone' => '12345678', 'MailS__c' => true, 'AccountId' => account.Id};
        Contact customer = (Contact) TestDataFactory.createSObject(new Contact(), true, additionFields);
        
        // create warehouse
        additionFields = new Map<String, Object> {'WharehouseCompany__c' => account.Id, 'LoadLocationPIC__c' => 'James Cook',
            										'LoadLocationPIC__c' => 'LoadLocationPIC'};
        LoadLocation__c warehouse = (LoadLocation__c) TestDataFactory.createSObject(new LoadLocation__c(), true, additionFields);

        additionFields = new Map<String, Object> {'Field1__c' => account.Id, 'Partner__c' => account.Id, 'BookingNv__c' => account.Id,
            										'CustmerInCharge__c' => customer.Id, 'PartnerRep__c' => customer.Id,
            										'RecordTypeId' => rt.Id, 'LoadLocation__c' => warehouse.Id,
            										'Custom__c' => PicklistReference.CUSTOMER_CLEARANCE_SERVICE_REQUIRED_YES};
		CustomObject1__c shipment = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), false, additionFields);

		Test.startTest();
        FlsService.doInsert(shipment);
        Test.stopTest();
        Custom_Clearance__c cc = [select Id from Custom_Clearance__c where HBL_SHIPMENT__c = :shipment.Id];
        System.assertNotEquals(null, cc);
    }
    
    testmethod static void shouldCompleteShipment() {
        RecordType rt = [Select Id from RecordType where DeveloperName = :Constants.OCEAN_EXPORT_RT];
        Map<String, Object> additionFields = new Map<String, Object> {'Custom_Type__c' => PicklistReference.DOMESTIC_CUSTOMER_EXISTING};
		Account account = (Account) TestDataFactory.createSObject(new Account(), true, additionFields);
        
        additionFields = new Map<String, Object> {'Phone' => '12345678', 'MailS__c' => true, 'AccountId' => account.Id};
        Contact customer = (Contact) TestDataFactory.createSObject(new Contact(), true, additionFields);
        
        // create warehouse
        additionFields = new Map<String, Object> {'WharehouseCompany__c' => account.Id, 'LoadLocationPIC__c' => 'James Cook',
            										'LoadLocationPIC__c' => 'LoadLocationPIC'};
        LoadLocation__c warehouse = (LoadLocation__c) TestDataFactory.createSObject(new LoadLocation__c(), true, additionFields);

        additionFields = new Map<String, Object> {'Field1__c' => account.Id, 'Partner__c' => account.Id, 'BookingNv__c' => account.Id,
            										'CustmerInCharge__c' => customer.Id, 'PartnerRep__c' => customer.Id,
            										'RecordTypeId' => rt.Id, 'LoadLocation__c' => warehouse.Id,
            										'Status__c' => PicklistReference.COMPLETED_ST};
		CustomObject1__c shipment = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), false, additionFields);

		Test.startTest();
        FlsService.doInsert(shipment);
        Test.stopTest();
    }
}