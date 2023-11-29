@isTest
public class CntlOpporunityCopyTest {
    static testmethod void shouldResetFieldsForAirImportRT() {
        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'InAir'];
        clofor_com_cfs__Site_Custom_Settings__c cus = new clofor_com_cfs__Site_Custom_Settings__c();
        cus.clofor_com_cfs__Company_Country__c = 'JAPAN';
        cus.clofor_com_cfs__Local_Currency__c = 'JPY';
        cus.clofor_com_cfs__Disable_Monthly_Yearly_HBL_ID__c = false;
         insert cus;
        Account account = (Account) TestDataFactory.createSObject(new Account(), true, null);
        Map<String, Object> additionFields = new Map<String, Object> {'Field1__c' => account.Id, 'RecordTypeId' => rt.Id, 
                                                            'Container__c' => 'AIR',
                                                            'BookingNo__c' => '123', 'FlightNo__c' => 'JPN123',
                                                            'Container2__c' =>'AIR',
                                                            'Container3__c' =>'AIR',
                                                            'Container4__c' =>'AIR',
                                                            'clofor_com_cfs__ContainerNumber__c' => 1, 'clofor_com_cfs__ContainerNumber2__c' => 1, 'clofor_com_cfs__ContainerNumber3__c' => 1,
                                                            'clofor_com_cfs__ContainerNumber4__c' => 1};
        CustomObject1__c shipment = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), true, additionFields);
        
        Test.startTest();
        String clonedId = cntl_opportunityCopy.init(shipment.Id);
        Test.stopTest();
        
        CustomObject1__c clonedShipment = [SELECT BookingNo__c, FlightNo__c 
                                           FROM CustomObject1__c WHERE Id = :clonedId];
        System.assertEquals(null, clonedShipment.BookingNo__c);
        System.assertEquals(null, clonedShipment.FlightNo__c);
    }

    static testmethod void checkCopyFromMasterAnken() {
        Account acc = (Account)TestDataFactory.createSObject(new Account(),null);
        acc.Name = 'ABC';
        FlsService.doInsert(acc);
        
        Contact cont = (Contact)TestDataFactory.createSObject(new Contact(),null);
        
        Map<String, Object> additionFields = new Map<String, Object> {'WharehouseCompany__c' => acc.Id};
        LoadLocation__c loadLocation = (LoadLocation__c) TestDataFactory.createSObject(new LoadLocation__c(), true, additionFields);
        
        additionFields = new Map<String, Object> {'Country_Name__c' => 'VIETNAM', 'City_Name__c' => 'HOCHIMINH', 'Name' => 'HOCHIMINH', 'Port_Type__c' => 'AIR', 'CodeOfPort__c' => '1234'};
        Port__c port1 = (Port__c) TestDataFactory.createSObject(new Port__c(), true, additionFields);
        additionFields = new Map<String, Object> {'Country_Name__c' => 'VIETNAM', 'City_Name__c' => 'HOCHIMINH', 'Name' => 'HOCHIMINH', 'Port_Type__c' => 'SEA', 'CodeOfPort__c' => '4321'};
        Port__c port2 = (Port__c) TestDataFactory.createSObject(new Port__c(), true, additionFields);
        
        MasterAnken__c myAKM = (MasterAnken__c)TestDataFactory.createSObject(new MasterAnken__c(), null);
        myAKM.MPOL__c = port1.id;
        myAKM.MPlace_of_Receipt__c = port1.id;
        myAKM.METD__c = DAte.Today();
        myAKM.MPOD__c = port2.id;
        myAKM.MPlace_of_Delivery__c = port2.id;
        myAKM.META__c = Date.today().addDays(2);
        myAKM.MVessel__c = 'BIEN DONG STAR';
        myAKM.MVoy_No__c = 'BIEN DONG';
        myAKM.MContainer_No__c = '123456';
        myAKM.MBookingNv__c = acc.Id;
        myAKM.MDevan__c = acc.id;
        myAKM.MDevanRep__c = cont.Id;
        myAKM.MDevanningDate__c = Date.today().addDays(2);
        myAKM.MTRANSIT_VESSEL__c = 'BIEN DONG 1';
        myAKM.MTRANSIT_PORT__c = 'HOCHIMINH';
        myAKM.MTRANSIT_T_ETD__c = Date.today().addDays(2);
        myAKM.MLoadLocation__c = loadLocation.Id;
        
        FlsService.doInsert(myAKM);
        
        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'OutAir'];
        Account account = (Account) TestDataFactory.createSObject(new Account(), true, null);
        clofor_com_cfs__Site_Custom_Settings__c cus = new clofor_com_cfs__Site_Custom_Settings__c();
        cus.clofor_com_cfs__Company_Country__c = 'JAPAN';
        cus.clofor_com_cfs__Local_Currency__c = 'JPY';
        cus.clofor_com_cfs__Disable_Monthly_Yearly_HBL_ID__c = false;
         insert cus;
        additionFields = new Map<String, Object> {'Country_Name__c' => 'JAPAN', 'City_Name__c' => 'TOKYO'};
        Port__c hblPort = (Port__c) TestDataFactory.createSObject(new Port__c(), true, additionFields);
        additionFields = new Map<String, Object> {'Field1__c' => account.Id, 'RecordTypeId' => rt.Id,
                                                    'POL__c' => hblPort.Id, 'Place_of_Receipt__c' => null,
                                                    'clofor_com_cfs__ContainerNumber__c' => 1, 'clofor_com_cfs__ContainerNumber2__c' => 1, 'clofor_com_cfs__ContainerNumber3__c' => 1,
                                                    'clofor_com_cfs__ContainerNumber4__c' => 1,
                                                    'clofor_com_cfs__Container2__c' => '20\'DC',
                                                    'clofor_com_cfs__Container3__c' => '20\'DC',
                                                    'clofor_com_cfs__Container4__c' => '20\'DC',
                                                    'Container__c' => '20\'DC'};
        
        CustomObject1__c shipment = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), true, additionFields);
        shipment.MasterAnkenName__c = myAKM.Id;
        upsert shipment;
        
        Test.startTest();
        shipment = [SELECT POL__r.Country_Name__c, POL__r.City_Name__c, Place_of_Receipt__r.Name FROM CustomObject1__c WHERE Id = :shipment.Id];
        System.assertEquals('JAPAN', shipment.POL__r.Country_Name__c);
        System.assertEquals('TOKYO', shipment.POL__r.City_Name__c);
        System.assertEquals(null, shipment.Place_of_Receipt__c);
        
        cntl_opportunityCopy.copyFieldsFromMaasterAnken(shipment.Id);
        Test.stopTest();
        
        shipment = [SELECT POL__r.Country_Name__c, POL__r.City_Name__c, Place_of_Receipt__r.Name FROM CustomObject1__c WHERE Id = :shipment.Id];
        System.assertEquals('VIETNAM', shipment.POL__r.Country_Name__c);
        System.assertEquals('HOCHIMINH', shipment.POL__r.City_Name__c);
        System.assertEquals('HOCHIMINH', shipment.Place_of_Receipt__r.Name);
    }

    static testmethod void shouldResetFieldsForAirExportRT() {
        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'OutAir'];
        Account account = (Account) TestDataFactory.createSObject(new Account(), true, null);
        clofor_com_cfs__Site_Custom_Settings__c cus = new clofor_com_cfs__Site_Custom_Settings__c();
        cus.clofor_com_cfs__Company_Country__c = 'JAPAN';
        cus.clofor_com_cfs__Local_Currency__c = 'JPY';
        cus.clofor_com_cfs__Disable_Monthly_Yearly_HBL_ID__c = false;
         insert cus;
        Map<String, Object> additionFields = new Map<String, Object> {'Field1__c' => account.Id, 'RecordTypeId' => rt.Id,
                                                                    'BookingNo__c' => '123', 'FlightNo__c' => 'JPN123',
                                                                    'clofor_com_cfs__Container2__c' => '20\'DC',
                                                                    'clofor_com_cfs__Container3__c' => '20\'DC',
                                                                    'clofor_com_cfs__Container4__c' => '20\'DC',
                                                                    'Container__c' => '20\'DC',
                                                                    'clofor_com_cfs__ContainerNumber__c' => 1, 'clofor_com_cfs__ContainerNumber2__c' => 1, 'clofor_com_cfs__ContainerNumber3__c' => 1,
                                                                    'clofor_com_cfs__ContainerNumber4__c' => 1};
        CustomObject1__c shipment = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), true, additionFields);
        
        Test.startTest();
        String clonedId = cntl_opportunityCopy.init(shipment.Id);
        Test.stopTest();
        
        CustomObject1__c clonedShipment = [SELECT BookingNo__c, FlightNo__c 
                                           FROM CustomObject1__c WHERE Id = :clonedId];
        System.assertEquals(null, clonedShipment.BookingNo__c);
        System.assertEquals(null, clonedShipment.FlightNo__c);
    }
    
    static testmethod void shouldResetFieldsForAirExportRT_1() {
        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'OutAir'];
        Account account = (Account) TestDataFactory.createSObject(new Account(), true, null);
        clofor_com_cfs__Site_Custom_Settings__c cus = new clofor_com_cfs__Site_Custom_Settings__c();
        cus.clofor_com_cfs__Company_Country__c = 'JAPAN';
        cus.clofor_com_cfs__Local_Currency__c = 'JPY';
        cus.clofor_com_cfs__Disable_Monthly_Yearly_HBL_ID__c = false;
         insert cus;
        Map<String, Object> additionFields = new Map<String, Object> {'Field1__c' => account.Id, 'RecordTypeId' => rt.Id,
                                                                    'BookingNo__c' => '123', 'FlightNo__c' => 'JPN123',
                                                                    'clofor_com_cfs__Container2__c' => '20\'DC',
                                                                    'clofor_com_cfs__Container3__c' => '20\'DC',
                                                                    'clofor_com_cfs__Container4__c' => '20\'DC',
                                                                    'Container__c' => '20\'DC',
                                                                    'clofor_com_cfs__ContainerNumber__c' => 1, 'clofor_com_cfs__ContainerNumber2__c' => 1, 'clofor_com_cfs__ContainerNumber3__c' => 1,
                                                                    'clofor_com_cfs__ContainerNumber4__c' => 1};
        CustomObject1__c shipment = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), true, additionFields);
        
        Test.startTest();
        String clonedId = cntl_opportunityCopy.init(shipment.Id);
        Test.stopTest();
        
        CustomObject1__c clonedShipment = [SELECT BookingNo__c, FlightNo__c 
                                           FROM CustomObject1__c WHERE Id = :clonedId];
        System.assertEquals(null, clonedShipment.BookingNo__c);
        System.assertEquals(null, clonedShipment.FlightNo__c);
    }

    static testmethod void shouldCloneInShallowMode() {
        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'OutAir'];
        Account account = (Account) TestDataFactory.createSObject(new Account(), true, null);
        clofor_com_cfs__Site_Custom_Settings__c cus = new clofor_com_cfs__Site_Custom_Settings__c();
        cus.clofor_com_cfs__Company_Country__c = 'JAPAN';
        cus.clofor_com_cfs__Local_Currency__c = 'JPY';
        cus.clofor_com_cfs__Disable_Monthly_Yearly_HBL_ID__c = false;
         insert cus;
        Map<String, Object> additionFields = new Map<String, Object> {'Field1__c' => account.Id, 'RecordTypeId' => rt.Id,
                                                                        'HBL__c' => 'SMJ1234',
                                                                        'clofor_com_cfs__Container2__c' => '20\'DC',
                                                                        'clofor_com_cfs__Container3__c' => '20\'DC',
                                                                        'clofor_com_cfs__Container4__c' => '20\'DC',
                                                                        'Container__c' => '20\'DC',
                                                                        'clofor_com_cfs__ContainerNumber__c' => 1, 'clofor_com_cfs__ContainerNumber2__c' => 1, 'clofor_com_cfs__ContainerNumber3__c' => 1,
                                                                        'clofor_com_cfs__ContainerNumber4__c' => 1};
        CustomObject1__c shipment = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), true, additionFields);
        
        Test.startTest();
        String clonedId = cntl_opportunityCopy.init_lingtning(shipment.Id);
        Test.stopTest();
    }

    static testmethod void shouldCopyFieldsFromBMLToHBL() {
        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'OutAir'];
        Account account = (Account) TestDataFactory.createSObject(new Account(), true, null);
        clofor_com_cfs__Site_Custom_Settings__c cus = new clofor_com_cfs__Site_Custom_Settings__c();
        cus.clofor_com_cfs__Company_Country__c = 'JAPAN';
        cus.clofor_com_cfs__Local_Currency__c = 'JPY';
        cus.clofor_com_cfs__Disable_Monthly_Yearly_HBL_ID__c = false;
         insert cus;
        Map<String, Object> additionalFields = new Map<String, Object> {'Field1__c' => account.Id, 'RecordTypeId' => rt.Id,
                                                                        'clofor_com_cfs__ContainerNumber__c' => 1, 'clofor_com_cfs__ContainerNumber2__c' => 1, 'clofor_com_cfs__ContainerNumber3__c' => 1,
                                                                        'clofor_com_cfs__ContainerNumber4__c' => 1,
                                                                        'clofor_com_cfs__Container3__c' => '20\'DC',
                                                                        'clofor_com_cfs__Container4__c' => '20\'DC',
                                                                        'clofor_com_cfs__Container2__c' => '20\'DC',
                                                                        'Container__c' => '20\'DC'};
        CustomObject1__c shipment = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), true, additionalFields);
        
        additionalFields = new Map<String, Object> {'WharehouseCompany__c' => account.Id};
        LoadLocation__c loadLocation = (LoadLocation__c) TestDataFactory.createSObject(new LoadLocation__c(), true, additionalFields);
        
        additionalFields = new Map<String, Object> {'MBookingNv__c' => account.Id, 'MLoadLocation__c' => loadLocation.Id,
                                                    'MDevan__c' => account.id, 'MVessel__c' => 'SHIP123'};
        MasterAnken__c mbl = (MasterAnken__c)TestDataFactory.createSObject(new MasterAnken__c(), true, additionalFields);
        
        Test.startTest();
        cntl_opportunityCopy.copyFieldsFromMasterAnken(shipment.Id, mbl.Id);
        Test.stopTest();
        
        shipment = [SELECT Vessle__c, Devan__c FROM CustomObject1__c WHERE Id = :shipment.Id];
        System.assertEquals(shipment.Vessle__c, shipment.Vessle__c);
        System.assertEquals(account.Id, shipment.Devan__c);
    }
    
    static testmethod void shouldResetQuotationVersionOnceCopied() {
        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'RecordType'];
        Account account = (Account) TestDataFactory.createSObject(new Account(), true, null);
        clofor_com_cfs__Site_Custom_Settings__c cus = new clofor_com_cfs__Site_Custom_Settings__c();
        cus.clofor_com_cfs__Company_Country__c = 'JAPAN';
        cus.clofor_com_cfs__Local_Currency__c = 'JPY';
        cus.clofor_com_cfs__Disable_Monthly_Yearly_HBL_ID__c = false;
         insert cus;
        Map<String, Object> additionFields = new Map<String, Object> {'Field1__c' => account.Id, 'RecordTypeId' => rt.Id, 
                                                                    'Container__c' => 'ISO', 'ContainerNumber__c' => 10,
                                                                    'clofor_com_cfs__ContainerNumber__c' => 1, 'clofor_com_cfs__ContainerNumber2__c' => 1, 'clofor_com_cfs__ContainerNumber3__c' => 1,
                                                                    'clofor_com_cfs__ContainerNumber4__c' => 1,
                                                                    'clofor_com_cfs__Container2__c' => '20\'DC',
                                                                    'clofor_com_cfs__Container3__c' => '20\'DC',
                                                                    'clofor_com_cfs__Container4__c' => '20\'DC',
                                                                    'Container__c' => '20\'DC'};
        CustomObject1__c shipment = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), true, additionFields);
        
        Test.startTest();
        shipment = [SELECT QuotationVer__c FROM CustomObject1__c WHERE Id = :shipment.Id];
        System.assertEquals(1, shipment.QuotationVer__c);
        
        shipment.QuotationVer__c = 11;
        FlsService.doUpdate(shipment);
        shipment = [SELECT QuotationVer__c FROM CustomObject1__c WHERE Id = :shipment.Id];
        System.assertEquals(11, shipment.QuotationVer__c);
        
        String clonedShipmentId = cntl_opportunityCopy.init(shipment.Id);
        CustomObject1__c clonedShipment = [SELECT QuotationVer__c FROM CustomObject1__c WHERE Id = :clonedShipmentId];
        Test.stopTest();
        
        System.assertEquals(1, clonedShipment.QuotationVer__c);
    }
    
    static testmethod void shouldResetQuotationVersionOnceCloned() {
        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'RecordType'];
        Account account = (Account) TestDataFactory.createSObject(new Account(), true, null);
        clofor_com_cfs__Site_Custom_Settings__c cus = new clofor_com_cfs__Site_Custom_Settings__c();
        cus.clofor_com_cfs__Company_Country__c = 'JAPAN';
        cus.clofor_com_cfs__Local_Currency__c = 'JPY';
        cus.clofor_com_cfs__Disable_Monthly_Yearly_HBL_ID__c = false;
         insert cus;
        Map<String, Object> additionFields = new Map<String, Object> {'Field1__c' => account.Id, 'RecordTypeId' => rt.Id, 
                                                                    'Container__c' => 'ISO', 'ContainerNumber__c' => 10,
                                                                    'clofor_com_cfs__ContainerNumber__c' => 1, 'clofor_com_cfs__ContainerNumber2__c' => 1, 'clofor_com_cfs__ContainerNumber3__c' => 1,
                                                                    'clofor_com_cfs__ContainerNumber4__c' => 1,
                                                                    'clofor_com_cfs__Container2__c' => '20\'DC',
                                                                    'clofor_com_cfs__Container3__c' => '20\'DC',
                                                                    'clofor_com_cfs__Container4__c' => '20\'DC',
                                                                    'Container__c' => '20\'DC'};
        CustomObject1__c shipment = (CustomObject1__c) TestDataFactory.createSObject(new CustomObject1__c(), true, additionFields);
        
        Test.startTest();
        shipment = [SELECT QuotationVer__c FROM CustomObject1__c WHERE Id = :shipment.Id];
        System.assertEquals(1, shipment.QuotationVer__c);
        
        shipment.QuotationVer__c = 11;
        FlsService.doUpdate(shipment);
        shipment = [SELECT QuotationVer__c FROM CustomObject1__c WHERE Id = :shipment.Id];
        System.assertEquals(11, shipment.QuotationVer__c);
        
        String clonedShipmentId = cntl_opportunityCopy.cloneShallowCopy(shipment.Id);
        CustomObject1__c clonedShipment = [SELECT QuotationVer__c FROM CustomObject1__c WHERE Id = :clonedShipmentId];
        Test.stopTest();
        
        System.assertEquals(1, clonedShipment.QuotationVer__c);
    }

    static testmethod void shouldCopyMBLWithBuyingDetails() {
        Id rtId = Schema.SObjectType.CustomObject1__c.getRecordTypeInfosByDeveloperName().get('RecordType').getRecordTypeId();
        Account account = (Account)TestDataFactory.createSObject(new Account(),true, null);
        
        Map<String, Object> additionalFields = new Map<String, Object> {'AccountId' => account.Id};
        Contact contact = (Contact)TestDataFactory.createSObject(new Contact(), true, additionalFields);
        
        additionalFields = new Map<String, Object> {'WharehouseCompany__c' => account.Id};
        LoadLocation__c loadLocation = (LoadLocation__c) TestDataFactory.createSObject(new LoadLocation__c(), true, additionalFields);
       
        
        additionalFields = new Map<String, Object> {'MBookingNv__c' => account.Id, 'MLoadLocation__c' => loadLocation.Id,
                                                'MDevan__c' => account.id, 'MDevanRep__c' => contact.Id, 
                                                'MConsolidationType__c' => '自社混載(Consolidation Cargo)'};
        MasterAnken__c mbl = (MasterAnken__c)TestDataFactory.createSObject(new MasterAnken__c(), true, additionalFields);

        additionalFields = new Map<String, Object> {'MasterAnken__c' => mbl.Id, 'BuyTankaJPY__c' => 100, 'BuyTankaUSD__c' => 200};
        MasterAnkenMeisai__c buyingDetailWithPrice = (MasterAnkenMeisai__c) TestDataFactory.createSObject(new MasterAnkenMeisai__c(), true, additionalFields);
        
        additionalFields = new Map<String, Object> {'MasterAnken__c' => mbl.Id};
        MasterAnkenMeisai__c buyingDetailWithoutPrice = (MasterAnkenMeisai__c) TestDataFactory.createSObject(new MasterAnkenMeisai__c(), true, additionalFields);
        
        Test.startTest();
        String clonedMBLId = cntl_opportunityCopy.copyMBLWithBuyingDetails(mbl.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, clonedMBLId);
        
    }
}