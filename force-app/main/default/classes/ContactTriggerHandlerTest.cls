@isTest(SeeAllData=false)
public class ContactTriggerHandlerTest {
      testmethod static void shouldPopulateDoNotSendEmailFlagsOnCreation() {
		RecordType rt = [Select Id from RecordType where DeveloperName = 'RecordType'];
        Map<String, Object> additionFields = new Map<String, Object> {'Custom_Type__c' => PicklistReference.DOMESTIC_CUSTOMER_EXISTING};
		Account account = (Account) TestDataFactory.createSObject(new Account(), true, additionFields);
        clofor_com_cfs__Site_Custom_Settings__c cus = new clofor_com_cfs__Site_Custom_Settings__c();
        cus.clofor_com_cfs__Company_Country__c = 'JAPAN';
        cus.clofor_com_cfs__Local_Currency__c = 'JPY';
        cus.clofor_com_cfs__Disable_Monthly_Yearly_HBL_ID__c = false;
         insert cus;
        additionFields = new Map<String, Object> {'Phone' => '12345678', 'MailS__c' => true, 'AccountId' => account.Id};
        Contact customer = (Contact) TestDataFactory.createSObject(new Contact(), true, additionFields);
        
        additionFields = new Map<String, Object> {'Phone' => '12345678', 'MailS__c' => false, 'AccountId' => account.Id};
        Contact partner = (Contact) TestDataFactory.createSObject(new Contact(), true, additionFields);

        Map<String, Object> additionalFields = new Map<String, Object> {'clofor_com_cfs__Country_Name__c' => 'BELIZE'};     
        clofor_com_cfs__Port__c	objPort =  (clofor_com_cfs__Port__c) TestDataFactory.createSObject(new clofor_com_cfs__Port__c(), true, additionalFields);
     
        additionFields = new Map<String, Object> {'Field1__c' => account.Id, 'Partner__c' => account.Id,
            										'CustmerInCharge__c' => customer.Id, 
                                                    'PartnerRep__c' => partner.Id, 'RecordTypeId' => rt.Id,
                                                    'clofor_com_cfs__POD__c' => objPort.Id
                                                };
		CustomObject1__c shipment = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), 
                                                                                     false, additionFields);        
        
        Test.startTest();
		FlsService.doInsert(shipment);
        Test.stopTest();
        
        shipment = [SELECT Partner_Do_Not_Disturb_State__c, Customer_Do_Not_Disturb_State__c 
                    FROM CustomObject1__c 
                    WHERE Id = :shipment.Id];
        System.assertEquals(false, shipment.Partner_Do_Not_Disturb_State__c);
        System.assertEquals(true, shipment.Customer_Do_Not_Disturb_State__c);
    }
    
    testmethod static void shouldPopulateDoNotSendEmailFlagsOnUpdate() {
		RecordType rt = [Select Id from RecordType where DeveloperName = 'RecordType'];
        Map<String, Object> additionFields = new Map<String, Object> {'Custom_Type__c' => PicklistReference.DOMESTIC_CUSTOMER_EXISTING};
		Account account = (Account) TestDataFactory.createSObject(new Account(), true, additionFields);
        clofor_com_cfs__Site_Custom_Settings__c cus = new clofor_com_cfs__Site_Custom_Settings__c();
        cus.clofor_com_cfs__Company_Country__c = 'JAPAN';
        cus.clofor_com_cfs__Local_Currency__c = 'JPY';
        cus.clofor_com_cfs__Disable_Monthly_Yearly_HBL_ID__c = false;
         insert cus;
        additionFields = new Map<String, Object> {'Phone' => '12345678', 'MailS__c' => true, 'AccountId' => account.Id};
        Contact customer = (Contact) TestDataFactory.createSObject(new Contact(), true, additionFields);
        
        additionFields = new Map<String, Object> {'Phone' => '12345678', 'MailS__c' => false, 'AccountId' => account.Id};
        Contact partner = (Contact) TestDataFactory.createSObject(new Contact(), true, additionFields);

        Map<String, Object> additionalFields = new Map<String, Object> {'clofor_com_cfs__Country_Name__c' => 'BELIZE'};     
        clofor_com_cfs__Port__c	objPort =  (clofor_com_cfs__Port__c) TestDataFactory.createSObject(new clofor_com_cfs__Port__c(), true, additionalFields);
     
        additionFields = new Map<String, Object> {'Field1__c' => account.Id, 'Partner__c' => account.Id,
            										'CustmerInCharge__c' => customer.Id,
                                                    'RecordTypeId' => rt.Id, 'PartnerRep__c' => partner.Id,
                                                    'clofor_com_cfs__POD__c' => objPort.Id
                                                };
		CustomObject1__c shipment = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), 
                                                                                     true, additionFields);        
        
        Test.startTest();
        shipment = [SELECT Partner_Do_Not_Disturb_State__c, Customer_Do_Not_Disturb_State__c 
                    FROM CustomObject1__c 
                    WHERE Id = :shipment.Id];
        System.assertEquals(false, shipment.Partner_Do_Not_Disturb_State__c);
        System.assertEquals(true, shipment.Customer_Do_Not_Disturb_State__c);
        
        partner.MailS__c = true;
        FlsService.doUpdate(partner);
        Test.stopTest();
        
        shipment = [SELECT Partner_Do_Not_Disturb_State__c, Customer_Do_Not_Disturb_State__c 
                    FROM CustomObject1__c 
                    WHERE Id = :shipment.Id];
        System.assertEquals(true, shipment.Partner_Do_Not_Disturb_State__c);
        System.assertEquals(true, shipment.Customer_Do_Not_Disturb_State__c);
    }
}