/**
* FMS_ShowReceivablePayableControllerTest
* @created: 2019/02/11 Chien Truong
* @modified:
*/
@isTest
private class FMS_ShowReceivablePayableControllerTest {
	private static final String TAB_PARAMETER_NAME = 'isTabShow';
	private static final String RECEIVABLE_TAB = 'receivableTab';
	private static final String PAYABLE_TAB = 'payableTab';
	private static final String MEISAIID = 'meisaiIds';
	private static final String SHOW_ALL = 'Show all';
	private static final String CHECK_ONLY = 'Check only';
	private static final String UNCHECK_ONLY = 'Un-check only';

	private static User objUser = new User();
	static {
		objUser = createUser();
	}

	@isTest static void testConstructor() {
		System.runAs(objUser) {
			clofor_com_cfs__AnkenMeisai__c objAnkenMeisai = createAnkenMeisai();
		   	Test.startTest();
				ApexPages.StandardSetController standardController = new ApexPages.standardSetController(new List<AnkenMeisai__c> { objAnkenMeisai });
				FMS_ShowReceivablePayableController controller = new FMS_ShowReceivablePayableController(standardController);
            	FMS_ShowReceivablePayableController1 controller1 = new FMS_ShowReceivablePayableController1(standardController);
				controller.getAmount();
				controller.getUnpaid();
				controller.getItemsLanguage();
            	controller1.getAmount();
				controller1.getUnpaid();
				controller1.getItemsLanguage();
			Test.stopTest();
		}
	}

	@isTest static void testGetDataReceivable() {
		System.runAs(objUser) {
			clofor_com_cfs__AnkenMeisai__c objAnkenMeisai = createAnkenMeisai();
		   	Test.startTest();
				ApexPages.StandardSetController standardController = new ApexPages.standardSetController(new List<AnkenMeisai__c> { objAnkenMeisai });
				FMS_ShowReceivablePayableController controller = new FMS_ShowReceivablePayableController(standardController);
				FMS_ShowReceivablePayableController.getData(true, 0, 0, null, SHOW_ALL, null, null, null);
            
            	FMS_ShowReceivablePayableController1 controller1 = new FMS_ShowReceivablePayableController1(standardController);
				FMS_ShowReceivablePayableController1.getData(true, 0, 0, null, SHOW_ALL, null, null, null,null);
			Test.stopTest();
		}
	}

	@isTest static void testGetDataPayble() {
		System.runAs(objUser) {
			clofor_com_cfs__AnkenMeisai__c objAnkenMeisai = createAnkenMeisai();
		   	Test.startTest();
				ApexPages.StandardSetController standardController = new ApexPages.standardSetController(new List<AnkenMeisai__c> { objAnkenMeisai });
				FMS_ShowReceivablePayableController controller = new FMS_ShowReceivablePayableController(standardController);
				FMS_ShowReceivablePayableController.getData(false, 0, 0, null, CHECK_ONLY, null, null, null);
            	FMS_ShowReceivablePayableController1 controller1 = new FMS_ShowReceivablePayableController1(standardController);
				FMS_ShowReceivablePayableController1.getData(false, 0, 0, null, CHECK_ONLY, null, null, null,null);
			Test.stopTest();
		}
	}

	@isTest static void testActionProcessingReceivable() {
		System.runAs(objUser) {
			clofor_com_cfs__AnkenMeisai__c objAnkenMeisai = createAnkenMeisai();
		   	Test.startTest();
				ApexPages.StandardSetController standardController = new ApexPages.standardSetController(new List<AnkenMeisai__c> { objAnkenMeisai });
				FMS_ShowReceivablePayableController controller = new FMS_ShowReceivablePayableController(standardController);
            FMS_ShowReceivablePayableController1 controller1 = new FMS_ShowReceivablePayableController1(standardController);
				ApexPages.currentPage().getParameters().put(MEISAIID, objAnkenMeisai.Id);
				controller.isShowReceivable = true;
				controller.actionProcessing();
           		controller1.isShowReceivable = true;
				controller1.actionProcessing();
			Test.stopTest();
		}
	}

	@isTest static void testActionProcessingPayable() {
		System.runAs(objUser) {
			clofor_com_cfs__AnkenMeisai__c objAnkenMeisai = createAnkenMeisai();
		   	Test.startTest();
				ApexPages.StandardSetController standardController = new ApexPages.standardSetController(new List<AnkenMeisai__c> { objAnkenMeisai });
				FMS_ShowReceivablePayableController controller = new FMS_ShowReceivablePayableController(standardController);
            	FMS_ShowReceivablePayableController1 controller1 = new FMS_ShowReceivablePayableController1(standardController);
				controller.isShowReceivable = false;
           		controller1.isShowReceivable = false;
				ApexPages.currentPage().getParameters().put(MEISAIID, objAnkenMeisai.Id);
				controller.actionProcessing();
            	controller1.actionProcessing();
			Test.stopTest();
		}
	}	

	@isTest static void testActionFilter() {
		System.runAs(objUser) {
			clofor_com_cfs__AnkenMeisai__c objAnkenMeisai = createAnkenMeisai();
		   	Test.startTest();
				ApexPages.StandardSetController standardController = new ApexPages.standardSetController(new List<AnkenMeisai__c> { objAnkenMeisai });
				FMS_ShowReceivablePayableController controller = new FMS_ShowReceivablePayableController(standardController);
				controller.getItems();
				controller.actionFilter();
            	FMS_ShowReceivablePayableController1 controller1 = new FMS_ShowReceivablePayableController1(standardController);
				controller1.getItems();
				controller1.actionFilter();
			Test.stopTest();
		}
	}

	@isTest static void testActionChangeTab() {
		System.runAs(objUser) {
			clofor_com_cfs__AnkenMeisai__c objAnkenMeisai = createAnkenMeisai();
		   	Test.startTest();
				ApexPages.StandardSetController standardController = new ApexPages.standardSetController(new List<AnkenMeisai__c> { objAnkenMeisai });
				FMS_ShowReceivablePayableController controller = new FMS_ShowReceivablePayableController(standardController);
            	FMS_ShowReceivablePayableController1 controller1 = new FMS_ShowReceivablePayableController1(standardController);
				ApexPages.currentPage().getParameters().put(TAB_PARAMETER_NAME, 'true');
				controller.actionChangeTab();
            	controller1.actionChangeTab();
			Test.stopTest();
		}
	}

	@isTest static void testActionCancel() {
		System.runAs(objUser) {
			clofor_com_cfs__AnkenMeisai__c objAnkenMeisai = createAnkenMeisai();
		   	Test.startTest();
				ApexPages.StandardSetController standardController = new ApexPages.standardSetController(new List<AnkenMeisai__c> { objAnkenMeisai });
				FMS_ShowReceivablePayableController controller = new FMS_ShowReceivablePayableController(standardController);
				controller.actionCancel();
            	
            	FMS_ShowReceivablePayableController1 controller1 = new FMS_ShowReceivablePayableController1(standardController);
				controller1.actionCancel();
            	controller1.getItemsCurrency();
			Test.stopTest();
		}
	}


	private static clofor_com_cfs__AnkenMeisai__c createAnkenMeisai() {
		// TODO - clean up hot fix
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

	private static User createUser(){
		Profile profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
		
		String uniqueName = UserInfo.getOrganizationId() +           
			Datetime.now().format('yyyyMMddHHmmssSSS') +               
			Integer.valueOf(math.rint(math.random()* (2000000 - 1)));

		User user = new User(
			FirstName = uniqueName.subString(29, 34)              
			,LastName = uniqueName.subString(30, 35)              
			,Email = uniqueName + '@afr.com'                    
			,UserName = uniqueName + '@afr.com'                  
			,EmailEncodingKey = 'UTF-8'                                
			,Alias = 'afrDev'                                          
			,TimeZoneSidKey = 'Asia/Tokyo'                             
			,LocaleSidKey = 'ja_JP'                                
			,LanguageLocaleKey = 'ja'                              
			,ProfileId = profile.Id                                     
			,PostalCode = '123456789'                                
			,Department = 'IT'                                   
			,Phone = '123456789'                                   
			,Fax = '123456789'                                      
			,CompanyName  = 'afr'                                    
			,IsActive = true                                   
		);
		
		FlsService.doInsert(user);
		return user;
	}	
}