@isTest
private class VATInvoiceExcelControllerTest {
	private static User objUser = new User();
	static {
		objUser = createUser();
	}

	@isTest static void testConstructor() {
		System.runAs(objUser) {
			VAT_INVOICE__c objVATInvoice = createVATInvoice();			
		   	Test.startTest();
				VATInvoiceExcelController controller = new VATInvoiceExcelController();
				VATInvoiceExcelController.getDataInit();
			Test.stopTest();
		}
	}
	
	@isTest static void testGenerateExcel() {
		System.runAs(objUser) {
			VAT_INVOICE__c objVATInvoice = createVATInvoice();			
		   	Test.startTest();
				ApexPages.currentPage().getParameters().put('invoiceId', objVATInvoice.Id);
				VATInvoiceExcelController controller = new VATInvoiceExcelController();
				controller.generateExcel();
			Test.stopTest();
		}
	}

	private static VAT_INVOICE__c createVATInvoice() {
		// TODO - clean up hot fix
		Map<String, Object> additionalFields = new Map<String, Object> {
                'Company_Address__c' => '123 ABC, Tokyo, Japan',
                'Company_Fax__c' => '1234567', 'Company_Phone__c' => '11122233',
                'Logo_URL__c' => 'http://afr-solutions.com/logo.png',
                'Company_Country__c' => 'JAPAN', 'Local_Currency__c' => 'JPY',
                'EnableInvoiceTemplateSet1__c' => true, 'InvoiceTemplateSet1Name__c' => 'TEST'
        };
        TestDataFactory.createSObject(new Site_Custom_Settings__c(), true, additionalFields);
		Custom_Application_Config__c config = new Custom_Application_Config__c(
        	Disabled_Trigger__c = true
        );
		FlsService.doInsert(config);
        RecordType rt = [Select Id from RecordType where DeveloperName = 'RecordType'];

        // Create account
        additionalFields = new Map<String, Object> {
                'Custom_Type__c' => '国内顧客 - 既存'
        };
        Account account = (Account)TestDataFactory.createSObject(new Account(), true, additionalFields);
       
        VAT_INVOICE__c objVatInvoice = (VAT_INVOICE__c)TestDataFactory.createSObject(new VAT_INVOICE__c(), true, null);

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

        // Create H B/L Selling/Buying
        additionalFields = new Map<String, Object> {
                'Anken__c' => shipment.Id, 'curr__c' => 'JPY', 'SerchSyubetu__c' => 'FCL輸入',
                'Tariff__c' => tariff.Id,
                'Seikyusaki__c' => account.Id
        };
        AnkenMeisai__c objAnkenMeisai = (AnkenMeisai__c)TestDataFactory.createSObject(new AnkenMeisai__c(), true, additionalFields);
		
		additionalFields = new Map<String, Object>{'Invoicing__c' => objAnkenMeisai.Id, 'VAT_INVOICE__c' => objVatInvoice.Id};
            
        INVOICING_VAT__c objInvoicingVat = (INVOICING_VAT__c)TestDataFactory.createSObject(new INVOICING_VAT__c(), true, additionalFields);
		
		return objVatInvoice;
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