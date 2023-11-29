@isTest(SeeAllData = false)
private class ContainerInfoTriggerHandlerTest {
    private static String hblId = null;
    
	@testSetup static void setUp() {
        Map<String, Object> additionalFields = new Map<String, Object>{'Name' => 'F40DC', 'Type__c' => '40\'DC', 
            												'Code__c' => 'GP : Dry Container', 'Size__c' => '42'};
        TestDataFactory.createSObject(new CONTAINER_INFO_MAPPINGS__c(), true, additionalFields);
        
        additionalFields = new Map<String, Object>{'Name' => 'F20DC', 'Type__c' => '20\'DC', 
				            								'Code__c' => 'GP : Dry Container', 'Size__c' => '22'};
		TestDataFactory.createSObject(new CONTAINER_INFO_MAPPINGS__c(), true, additionalFields);

		additionalFields = new Map<String, Object>{'Name' => 'F40HC', 'Type__c' => '40\'HC', 
				            								'Code__c' => 'GP : Dry Container', 'Size__c' => '22'};
		TestDataFactory.createSObject(new CONTAINER_INFO_MAPPINGS__c(), true, additionalFields);

		additionalFields = new Map<String, Object>{'Name' => 'F40OT', 'Type__c' => '40\'OT', 
				            								'Code__c' => 'GP : Dry Container', 'Size__c' => '22'};
		TestDataFactory.createSObject(new CONTAINER_INFO_MAPPINGS__c(), true, additionalFields);
        
        additionalFields = new Map<String, Object>{'Name' => 'FISO', 'Type__c' => 'ISO', 
				            								'Code__c' => 'GP : Dry Container', 'Size__c' => '22'};
		TestDataFactory.createSObject(new CONTAINER_INFO_MAPPINGS__c(), true, additionalFields);
        
        RecordType rt = [Select Id from RecordType where DeveloperName = 'RecordType'];
		Account account = (Account) TestDataFactory.createSObject(new Account(), true, null);
        clofor_com_cfs__Site_Custom_Settings__c cus = new clofor_com_cfs__Site_Custom_Settings__c();
        cus.clofor_com_cfs__Company_Country__c = 'JAPAN';
        cus.clofor_com_cfs__Local_Currency__c = 'JPY';
        cus.clofor_com_cfs__Disable_Monthly_Yearly_HBL_ID__c = false;
         insert cus;
        additionalFields = new Map<String, Object> {'clofor_com_cfs__Country_Name__c' => 'BELIZE'};     
        clofor_com_cfs__Port__c	objPort =  (clofor_com_cfs__Port__c) TestDataFactory.createSObject(new clofor_com_cfs__Port__c(), true, additionalFields);
     
        additionalFields = new Map<String, Object> {'Field1__c' => account.Id, 'RecordTypeId' => rt.Id,
                                                            'ContainerNumber__c' => 1, 'Container__c' => '40\'DC',
                                                            'ContainerNumber2__c' => 1, 'Container2__c' => '20\'DC',
                                                            'ContainerNumber3__c' => 1, 'Container3__c' => '40\'HC',
                                                            'ContainerNumber4__c' => 1, 'Container4__c' => '40\'OT',
                                                            'clofor_com_cfs__POD__c' => objPort.Id
                                                        };
        CustomObject1__c shipment = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), true, additionalFields);
        hblId = shipment.Id;
    }
    
    testmethod static void shouldNotCreateWhenExceedContainerTypes() {
        try {
	        Map<String, Object> additionalFields = new Map<String, Object> {'HBL_SHIPMENT__c' => hblId, 'Container__c' => 'ISO'};		        
    	    TestDataFactory.createSObject(new Container_Info__c(), true, additionalFields);    
        	System.assert(false);    
        } catch(Exception e) {
            System.assert(true);
        }
    } 
}