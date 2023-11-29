/**
* CustomObject1TriggerHndlTest
* @created: 2019/07/08 Chien Truong
* @modified:
*/
@isTest
private class CustomObject1TriggerHndlTest {
	private static User objUser = new User();
	static {
		objUser = createUser();
	}

	@isTest static void testBeforeInsert() {
		System.runAs(objUser) {
		   	Test.startTest();
			   	CustomObject1__c objCustomObject1A = createCustomObject1('ALGERIA', System.today());
			Test.stopTest();
		}
	}

	@isTest static void testBeforeInsertNewMonth() {
		System.runAs(objUser) {
		   	Test.startTest();
		   		CustomObject1__c objCustomObject1A = createCustomObject1('CANADA', System.today());
			Test.stopTest();
		}
	}

	@isTest static void testBeforeInsertNewYear() {
		System.runAs(objUser) {
		   	Test.startTest();
		   		Date currentDate = Date.newinstance(System.today().year(), 1, 1);
		  		CustomObject1__c objCustomObject1A = createCustomObject1('CUBA', currentDate);
			Test.stopTest();
		}
	}

	@isTest static void testBeforeUpdate() {
		System.runAs(objUser) {
		   	CustomObject1__c objCustomObject1B = createCustomObject1('FINLAND', System.today());
		   	Test.startTest();
		   		objCustomObject1B.MonthlyHBLID__c = null;
                FlsService.doUpdate(objCustomObject1B);

		   		objCustomObject1B.ETD__c = System.today().addDays(10);
                FlsService.doUpdate(objCustomObject1B);
			Test.stopTest();
		}
	}
	
	private static CustomObject1__c createCustomObject1(String conuntryName, Date salesAccountedDate) {
		// TODO - clean up hot fix
		Map<String, Object> additionalFields = new Map<String, Object> {
                'Company_Address__c' => '123 ABC, Tokyo, Japan',
                'Company_Fax__c' => '1234567', 'Company_Phone__c' => '11122233',
                'Logo_URL__c' => 'http://afr-solutions.com/logo.png',
                'Company_Country__c' => 'JAPAN', 'Local_Currency__c' => 'JPY',
                'EnableInvoiceTemplateSet1__c' => true, 'InvoiceTemplateSet1Name__c' => 'TEST'
        };
        RecordType rt = [Select Id from RecordType where DeveloperName = 'RecordType'];

        // Create account
        additionalFields = new Map<String, Object> {
                'Custom_Type__c' => '国内顧客 - 既存'
        };
        Account account = (Account)TestDataFactory.createSObject(new Account(), true, additionalFields);
        clofor_com_cfs__Site_Custom_Settings__c cus = new clofor_com_cfs__Site_Custom_Settings__c();
        cus.clofor_com_cfs__Company_Country__c = 'JAPAN';
        cus.clofor_com_cfs__Local_Currency__c = 'JPY';
        cus.clofor_com_cfs__Disable_Monthly_Yearly_HBL_ID__c = false;
        insert cus;

		Map<String, Object> additionFields = new Map<String, Object> {'clofor_com_cfs__Country_Name__c' => conuntryName};     
        clofor_com_cfs__Port__c	objPort =  (clofor_com_cfs__Port__c) TestDataFactory.createSObject(new clofor_com_cfs__Port__c(), true, additionFields);

        additionalFields = new Map<String, Object> {
            'Field1__c' => account.Id, 'RecordTypeId' => rt.Id,
			'ETD__c' => System.today(), 'BL_TYPE__c' => 'H B/L Issue Required',
			'clofor_com_cfs__POD__c' => objPort.Id,
			'SalesAccountedDate__c' => salesAccountedDate,
               
			'clofor_com_cfs__DeliveryDate__c' => Date.newInstance(2016, 12, 9),
                'clofor_com_cfs__AlertDebitIssuedBefore__c' => 2,
                'clofor_com_cfs__AlertDebitIssuedBefore__c' => 2.2
        };
        CustomObject1__c shipment = (CustomObject1__c)TestDataFactory.createSObject(new CustomObject1__c(), true, additionalFields);
		
		return shipment;
	}

	private static User createUser(){
		Profile profile = [SELECT Id FROM Profile WHERE userType = 'standard' LIMIT 1];
		
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