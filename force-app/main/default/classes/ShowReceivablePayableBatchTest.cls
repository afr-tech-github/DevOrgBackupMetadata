@isTest
private class ShowReceivablePayableBatchTest {
    private static User objUser = new User();

	static {
        objUser = createUser();
    }
    
    @isTest static void testExecuteBatchReceivable() {
        System.runAs(objUser) {
            List<String> ankenMeisaiIdList = new List<String>();
            clofor_com_cfs__AnkenMeisai__c objAnkenMeisaiInput = new clofor_com_cfs__AnkenMeisai__c();
            clofor_com_cfs__AnkenMeisai__c objAnkenMeisai = createAnkenMeisai();
            ankenMeisaiIdList.add(objAnkenMeisai.Id);

            ShowReceivablePayableBatch batch = new ShowReceivablePayableBatch(ankenMeisaiIdList, objAnkenMeisaiInput, true);
      
            Test.startTest();
                Database.executeBatch(batch, 30);
            Test.stopTest();
        }
    }
    
    
    @isTest static void testExecuteBatchPayable() {
        System.runAs(objUser) {
            List<String> ankenMeisaiIdList = new List<String>();
            clofor_com_cfs__AnkenMeisai__c objAnkenMeisaiInput = new clofor_com_cfs__AnkenMeisai__c();
            clofor_com_cfs__AnkenMeisai__c objAnkenMeisai = createAnkenMeisai();
            ankenMeisaiIdList.add(objAnkenMeisai.Id);

            ShowReceivablePayableBatch batch = new ShowReceivablePayableBatch(ankenMeisaiIdList, objAnkenMeisaiInput, false);
      
            Test.startTest();
                Database.executeBatch(batch, 30);
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
		
		insert user;
		return user;
	}	
}