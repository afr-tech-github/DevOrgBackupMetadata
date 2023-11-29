/**
* ClassName:   FMS_MassiveCreateInvoiceControllerTest
* Description: FMS Massive Create Invoice Controller Test
* @created:    2022/10/24 Truong Lai
* @modified:
*/
@isTest(SeeAllData=false)
public with sharing class FMS_MassiveCreateInvoiceControllerTest {
    private static User userTest = createUser();
    private static clofor_com_cfs__AnkenMeisai__c objAnkenMeisai{get;set;}
    private static final String TAB_PARAMETER_NAME = 'isTabShow';
	private static final String RECEIVABLE_TAB = 'receivableTab';
	private static final String PAYABLE_TAB = 'payableTab';
	private static final String MEISAIID = 'meisaiIds';
	private static final String SHOW_ALL = 'Show all';
	private static final String CHECK_ONLY = 'Check only';
	private static final String UNCHECK_ONLY = 'Un-check only';

    static {
        System.runAs(userTest){
            objAnkenMeisai = createAnkenMeisai();
        }
    }

    @IsTest
    static void testMethodInstance(){
        System.runAs(userTest){
            Test.startTest();
            ApexPages.StandardSetController standardController = new ApexPages.standardSetController(new List<AnkenMeisai__c> { objAnkenMeisai });
            FMS_MassiveCreateInvoiceController controller = new FMS_MassiveCreateInvoiceController(standardController);
            controller.getAmount();
            controller.getUnpaid();
            controller.getItemsLanguage();
            Test.stopTest();
            System.assertEquals(true, controller != null);
        }
    }

    @IsTest
    static void testMethodGetData(){
        System.runAs(userTest){
            Test.startTest();
            ApexPages.StandardSetController standardController = new ApexPages.standardSetController(new List<AnkenMeisai__c> { objAnkenMeisai });
            FMS_MassiveCreateInvoiceController controller = new FMS_MassiveCreateInvoiceController(standardController);
            FMS_MassiveCreateInvoiceController.getData(true, 0, 0, null, SHOW_ALL, null, null, null);
            String dtFrom = '10/01/2022';
            String dtTo = '10/24/2022';
            String orderNo = '1,2,3';
            FMS_MassiveCreateInvoiceController.getData(false, null, null, null, CHECK_ONLY, dtFrom, dtTo, orderNo);
            Test.stopTest();
            System.assertEquals(true, controller != null);
        }
    }

    @IsTest
    static void testMethodActionProcessing(){
        System.runAs(userTest){
            Test.startTest();
            ApexPages.StandardSetController standardController = new ApexPages.standardSetController(new List<AnkenMeisai__c> { objAnkenMeisai });
            FMS_MassiveCreateInvoiceController controller = new FMS_MassiveCreateInvoiceController(standardController);
            ApexPages.currentPage().getParameters().put(MEISAIID, objAnkenMeisai.Id);
            controller.isShowReceivable = false;
            controller.actionProcessing();
            controller.isShowReceivable = true;
            controller.actionProcessing();
            Test.stopTest();
            System.assertEquals(true, controller != null);
        }
    }

    @IsTest
    static void testMethodActionFilter(){
        System.runAs(userTest){
            Test.startTest();
            ApexPages.StandardSetController standardController = new ApexPages.standardSetController(new List<AnkenMeisai__c> { objAnkenMeisai });
            FMS_MassiveCreateInvoiceController controller = new FMS_MassiveCreateInvoiceController(standardController);
            controller.getItems();
            controller.actionFilter();
            Test.stopTest();
            System.assertEquals(true, controller != null);
        }
    }

    @IsTest
    static void testMethodActionChangeTab(){
        System.runAs(userTest){
            Test.startTest();
            ApexPages.StandardSetController standardController = new ApexPages.standardSetController(new List<AnkenMeisai__c> { objAnkenMeisai });
            FMS_MassiveCreateInvoiceController controller = new FMS_MassiveCreateInvoiceController(standardController);
            ApexPages.currentPage().getParameters().put(TAB_PARAMETER_NAME, 'true');
            controller.actionChangeTab();
            ApexPages.currentPage().getParameters().put(TAB_PARAMETER_NAME, 'false');
            controller.actionChangeTab();
            Test.stopTest();
            System.assertEquals(true, controller != null);
        }
    }

    @IsTest
    static void testMethodActionCancel(){
        System.runAs(userTest){
            Test.startTest();
            ApexPages.StandardSetController standardController = new ApexPages.standardSetController(new List<AnkenMeisai__c> { objAnkenMeisai });
            FMS_MassiveCreateInvoiceController controller = new FMS_MassiveCreateInvoiceController(standardController);
            controller.actionCancel();
            Test.stopTest();
            System.assertEquals(true, controller != null);
        }
    }

    @IsTest
    static void testMethodActionCreateInvoice(){
        System.runAs(userTest){
            VAT_INVOICE__c sobjVatInvoice = createVatInvoice();
            Test.startTest();
            ApexPages.StandardSetController standardController = new ApexPages.standardSetController(new List<AnkenMeisai__c> { objAnkenMeisai });
            FMS_MassiveCreateInvoiceController controller = new FMS_MassiveCreateInvoiceController(standardController);
            ApexPages.currentPage().getParameters().put('id', sobjVatInvoice.Id);
            ApexPages.currentPage().getParameters().put(MEISAIID, objAnkenMeisai.Id);
            controller.init();
            controller.actionCreateInvoice();
            Test.stopTest();
            System.assertEquals(true, controller != null);
        }
    }

    private static VAT_INVOICE__c createVatInvoice(){
		Map<String,Schema.RecordTypeInfo> recordTypeInfosMap = Schema.SObjectType.VAT_INVOICE__c.getRecordTypeInfosByDeveloperName();
        VAT_INVOICE__c sobj = new VAT_INVOICE__c(
            RecordTypeId = recordTypeInfosMap.get('CloWMSVATInvoice').getRecordTypeId()
        );

        FlsService.doInsert(sobj);
        return sobj;
    }

    private static clofor_com_cfs__AnkenMeisai__c createAnkenMeisai() {
		Map<String, Object> additionalFields = new Map<String, Object> {
            'Company_Address__c' => '123 ABC, Tokyo, Japan',
            'Company_Fax__c' => '1234567', 'Company_Phone__c' => '11122233',
            'Logo_URL__c' => 'http://afr-solutions.com/logo.png',
            'Company_Country__c' => 'JAPAN', 'Local_Currency__c' => 'JPY',
            'EnableInvoiceTemplateSet1__c' => true, 'InvoiceTemplateSet1Name__c' => 'TEST'
        };
        TestDataFactory.createSObject(new Site_Custom_Settings__c(), true, additionalFields);

        RecordType rt = [Select Id from RecordType where DeveloperName = 'RecordType'];

        // Create account
        additionalFields = new Map<String, Object> {
                'Custom_Type__c' => '国内顧客 - 既存'
        };
        Account account = (Account)TestDataFactory.createSObject(new Account(), true, additionalFields);

        additionalFields = new Map<String, Object> {
                'Field1__c' => account.Id, 'RecordTypeId' => rt.Id
        };
        CustomObject1__c shipment = (CustomObject1__c)TestDataFactory.createSObject(new CustomObject1__c(), true, additionalFields);

        // Create Master Service
        additionalFields = new Map<String, Object> {
                'Name' => 'LCL', 'ProductSearch__c' => 'FCL輸入', 'Subcategory__c' => '基本料金',
                'Supplier__c' => account.Id, 'BuyKingaku__c' => 12, 'BuyAmountUSD__c' => 12, 'SellKingakuJPY__c' => 12, 'SellAmountUSD__c' => 12,
                'EngProductSearch__c' => 'FCL Import', 'ProductFlag__c' => true, 'TAX__c' => 'TAX'
        };
        TariffMaster__c tariff = (TariffMaster__c)TestDataFactory.createSObject(new TariffMaster__c(), true, additionalFields);

        // create H B/L Selling/Buying
        additionalFields = new Map<String, Object> {
                'Anken__c' => shipment.Id, 'curr__c' => 'JPY', 'SerchSyubetu__c' => 'FCL輸入',
                'Tariff__c' => tariff.Id,
                'Seikyusaki__c' => account.Id
        };
        AnkenMeisai__c objAnkenMeisai = (AnkenMeisai__c)TestDataFactory.createSObject(new AnkenMeisai__c(), true, additionalFields);
		
		return objAnkenMeisai;
	}

    private static User createUser() {
        // Profile
        Profile profile = [SELECT Id FROM Profile WHERE userType = 'standard' AND Name LIKE 'System Administrator' LIMIT 1];
        // Unique name
        String uniqueName = UserInfo.getOrganizationId()
                            + Datetime.now().format('yyyyMMddHHmmssSSS')
                            + Integer.valueOf(math.rint(math.random()* (2000000 - 1)));
        // User
        User user = new User (
            FirstName = uniqueName.subString(29, 34),
            LastName = uniqueName.subString(30, 35),
            Email = uniqueName + '@usertest.co.us',
            UserName = uniqueName + '@usertest.co.us',
            EmailEncodingKey = 'UTF-8',
            Alias = uniqueName.substring(29, 34),
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            ProfileId = profile.Id,
            PostalCode = '123456789',
            Department = 'test',
            Phone = '123456789',
            Fax = '123456789',
            CompanyName  = 'testing service'
        );
        FlsService.doInsert(user);
        return user;
    }
}