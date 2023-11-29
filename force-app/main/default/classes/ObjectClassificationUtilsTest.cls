@IsTest
public with sharing class ObjectClassificationUtilsTest {
    @testSetup static void setUp() {
        Map<String, Object> additionalFields = new Map<String, Object>{
                'Company_Address__c' => '123 ABC, Tokyo, Japan',
                'Company_Fax__c' => '1234567', 'Company_Phone__c' => '11122233',
                'Logo_URL__c' => 'http://afr-solutions.com/logo.png',
                'Company_Country__c' => 'JAPAN', 'Local_Currency__c' => 'JPY',
                'EnableInvoiceTemplateSet1__c' => true, 'InvoiceTemplateSet1Name__c' => 'TEST'
        };
        TestDataFactory.createSObject(new Site_Custom_Settings__c(), true, additionalFields);
        // Setup an Account
        Date printDate = Date.newInstance(2015, 09, 09);
        additionalFields = new Map<String, Object>{
                'Custom_Type__c' => PicklistReference.DOMESTIC_CUSTOMER_EXISTING,
                'Primary_Exchange_Rate_Currency__c' => 'JPY - Japanese Yen',
                'Secondary_Exchange_Rate_Currency__c' => 'VND - Vietnamese Dong'
        };
        Account domesticCustomer = (Account) TestDataFactory.createSObject(new Account(), true, additionalFields);
        // Setup a SHIPMENT ORDER
        String shipmentRecordTypeOceIm = RecordTypeUtil.getRecordTypeIdByDeveloperName(CustomObject1__c.SObjectType, Constants.OCEAN_IMPORT_RT);
        additionalFields = new Map<String, Object>{
                'Field1__c' => domesticCustomer.Id, 'RecordTypeId' => shipmentRecordTypeOceIm,
                'Custom__c' => PicklistReference.CUSTOMER_CLEARANCE_SERVICE_REQUIRED_NO,
                'PrinteDate_ED__c' => printDate, 'HBL__c' => 'SO_TEST_123'
        };
        CustomObject1__c shipmentOrder = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), true, additionalFields);
        
        // String shipmentRecordTypeOceEx = RecordTypeUtil.getRecordTypeIdByDeveloperName(CustomObject1__c.SObjectType, Constants.OCEAN_EXPORT_RT);
        // additionalFields = new Map<String, Object>{
                // 'Field1__c' => domesticCustomer.Id, 'RecordTypeId' => shipmentRecordTypeOceEx,
                // 'Custom__c' => PicklistReference.CUSTOMER_CLEARANCE_SERVICE_REQUIRED_NO,
                // 'PrinteDate_ED__c' => printDate, 'HBL__c' => 'SO_TEST_123'
        // };
        // CustomObject1__c shipmentOrder1 = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), true, additionalFields);
        // 
        // String shipmentRecordTypeDom = RecordTypeUtil.getRecordTypeIdByDeveloperName(CustomObject1__c.SObjectType, Constants.DOMESTIC_TRANSPORTATION_RT);
        // additionalFields = new Map<String, Object>{
                // 'Field1__c' => domesticCustomer.Id, 'RecordTypeId' => shipmentRecordTypeDom,
                // 'Custom__c' => PicklistReference.CUSTOMER_CLEARANCE_SERVICE_REQUIRED_NO,
                // 'PrinteDate_ED__c' => printDate, 'HBL__c' => 'SO_TEST_123'
        // };
        // CustomObject1__c shipmentOrder2 = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), true, additionalFields);

        // String shipmentRecordTypeCros = RecordTypeUtil.getRecordTypeIdByDeveloperName(CustomObject1__c.SObjectType, Constants.CROSS_BOARDER_RT);
        // additionalFields = new Map<String, Object>{
                // 'Field1__c' => domesticCustomer.Id, 'RecordTypeId' => shipmentRecordTypeCros,
                // 'Custom__c' => PicklistReference.CUSTOMER_CLEARANCE_SERVICE_REQUIRED_NO,
                // 'PrinteDate_ED__c' => printDate, 'HBL__c' => 'SO_TEST_123'
        // };
        // CustomObject1__c shipmentOrder3 = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), true, additionalFields);

        // String shipmentRecordTypeQuo = RecordTypeUtil.getRecordTypeIdByDeveloperName(CustomObject1__c.SObjectType, Constants.QUOTATION_RT);
        // additionalFields = new Map<String, Object>{
                // 'Field1__c' => domesticCustomer.Id, 'RecordTypeId' => shipmentRecordTypeQuo,
                // 'Custom__c' => PicklistReference.CUSTOMER_CLEARANCE_SERVICE_REQUIRED_NO,
                // 'PrinteDate_ED__c' => printDate, 'HBL__c' => 'SO_TEST_123'
        // };
        // CustomObject1__c shipmentOrder4 = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), true, additionalFields);

        // String shipmentRecordTypeAir = RecordTypeUtil.getRecordTypeIdByDeveloperName(CustomObject1__c.SObjectType, Constants.AIR_EXPORT_RT);
        // additionalFields = new Map<String, Object>{
                // 'Field1__c' => domesticCustomer.Id, 'RecordTypeId' => shipmentRecordTypeAir,
                // 'Custom__c' => PicklistReference.CUSTOMER_CLEARANCE_SERVICE_REQUIRED_NO,
                // 'PrinteDate_ED__c' => printDate, 'HBL__c' => 'SO_TEST_123'
        // };
        // CustomObject1__c shipmentOrder5 = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), true, additionalFields);
    }

    @IsTest
    static void TestDomesticCustomerOrPartner() {
    System.assertEquals(true,ObjectClassificationUtils.isDomesticCustomerOrPartner('国内'));
    }
    @IsTest
    static void TestOverseaCustomerOrPartner() {
        System.assertEquals(true,ObjectClassificationUtils.isOverseaCustomerOrPartner('海外'));
        }
    @IsTest
    static void TestImportMBL(){
        System.assertEquals(true,ObjectClassificationUtils.isImportMBL('import'));
    }
    @IsTest
    static void TestExportMBL(){
        System.assertEquals(true,ObjectClassificationUtils.isExportMBL('export'));
    }
    @IsTest
    static void TestImportHBL(){
        CustomObject1__c ship = [SELECT id,RecordTypeId FROM CustomObject1__c LIMIT 1];
        System.assertEquals(false,ObjectClassificationUtils.isImportHBL(ship.Id));
    }
    @IsTest
    static void TestImportHBLRecordTypeId(){
        CustomObject1__c ship1 = [SELECT id,RecordTypeId FROM CustomObject1__c LIMIT 1];
        System.assertEquals(true,ObjectClassificationUtils.isImportHBL(ship1.RecordTypeId));
    }
    @IsTest
    static void TestExportHBL(){
        CustomObject1__c ship2 = [SELECT id,RecordTypeId FROM CustomObject1__c LIMIT 1];
        System.assertEquals(false,ObjectClassificationUtils.isExportHBL(ship2.Id));
    }
    @IsTest
    static void TestExportHBLRecordTypeId(){
        CustomObject1__c ship3 = [SELECT id,RecordTypeId FROM CustomObject1__c LIMIT 1];
        System.assertEquals(false,ObjectClassificationUtils.isExportHBL(ship3.RecordTypeId));
    }
    @IsTest
    static void TestDomesticTransportation(){
        CustomObject1__c ship4 = [SELECT id,RecordTypeId FROM CustomObject1__c LIMIT 1];
        System.assertEquals(false,ObjectClassificationUtils.isDomesticTransportation(ship4));
    }
    @IsTest
    static void TestCrossBoarder(){
        CustomObject1__c ship5 = [SELECT id,RecordTypeId FROM CustomObject1__c LIMIT 1];
        System.assertEquals(false,ObjectClassificationUtils.isCrossBoarder(ship5));
    }
    @IsTest
    static void TestQuotationHBL(){
        CustomObject1__c ship6 = [SELECT id,RecordTypeId FROM CustomObject1__c LIMIT 1];
        System.assertEquals(false,ObjectClassificationUtils.isQuotationHBL(ship6));
    }
    @IsTest
    static void TestAirHBL(){
        CustomObject1__c ship7 = [SELECT id,RecordTypeId FROM CustomObject1__c LIMIT 1];
        System.assertEquals(false,ObjectClassificationUtils.isAirHBL(ship7));
    }
    @IsTest
    static void TestisLockedHBL(){
        CustomObject1__c ship8 = [SELECT id,RecordTypeId FROM CustomObject1__c LIMIT 1];
        System.assertEquals(false,ObjectClassificationUtils.isLockedHBL(ship8));
    }
    @IsTest
    static void TestisOceanHBL(){
        CustomObject1__c ship9 = [SELECT id,RecordTypeId FROM CustomObject1__c LIMIT 1];
        System.assertEquals(true,ObjectClassificationUtils.isOceanHBL(ship9));
    }
    @IsTest
    static void TestisImportCargoDelivery(){
        CustomObject1__c ship10 = [SELECT id,RecordTypeId FROM CustomObject1__c LIMIT 1];
        System.assertEquals(false,ObjectClassificationUtils.isImportCargoDelivery(ship10.RecordTypeId));
    }
    @IsTest
    static void TestisExportCargoDelivery(){
        CustomObject1__c ship11 = [SELECT id,RecordTypeId FROM CustomObject1__c LIMIT 1];
        System.assertEquals(false,ObjectClassificationUtils.isExportCargoDelivery(ship11.RecordTypeId));
    }
    @IsTest
    static void TestisPartner(){
        System.assertEquals(true,ObjectClassificationUtils.isPartner('パートナー'));
    }
    @IsTest
    static void TestgetObjectTypeId(){
        System.assertEquals('a06',ObjectClassificationUtils.getObjectTypeId('clofor_com_cfs__CustomObject1__c'));
    }        
}