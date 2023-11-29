@isTest
public with sharing class AddMultipleBillControllerTest {
    public static testMethod void checkAddMultipleBill() {
        Test.startTest();
		List<clofor_com_cfs__AnkenMeisai__c> bill = new List<clofor_com_cfs__AnkenMeisai__c>();
        clofor_com_cfs__Site_Custom_Settings__c custom = new clofor_com_cfs__Site_Custom_Settings__c(clofor_com_cfs__Company_Country__c = 'testCompany', clofor_com_cfs__FCY_Currency__c = 'KHR',clofor_com_cfs__Local_Currency__c = 'USD');
        insert custom;
        Account ac = new Account(Name = 'testAc',
                                 clofor_com_cfs__EnglishCompanyName__c = 'testAcENG',
                                 clofor_com_cfs__CustomerType__c = 'Others'
                                );
        insert ac;

        clofor_com_cfs__CustomObject1__c shipment = new clofor_com_cfs__CustomObject1__c(clofor_com_cfs__Field1__c = ac.Id);
        insert shipment;

        clofor_com_cfs__AnkenMeisai__c bill1 = new clofor_com_cfs__AnkenMeisai__c(clofor_com_cfs__Anken__c = shipment.Id,clofor_com_cfs__curr__c ='KHR',clofor_com_cfs__CurrencyBuying__c ='KHR');
        bill.add(bill1);
        clofor_com_cfs__AnkenMeisai__c bill2 = new clofor_com_cfs__AnkenMeisai__c(clofor_com_cfs__Anken__c = shipment.Id,clofor_com_cfs__curr__c ='USD',clofor_com_cfs__CurrencyBuying__c ='USD');  
        bill.add(bill2);
        clofor_com_cfs__AnkenMeisai__c bill3 = new clofor_com_cfs__AnkenMeisai__c(clofor_com_cfs__Anken__c = shipment.Id,clofor_com_cfs__curr__c ='JPY',clofor_com_cfs__CurrencyBuying__c ='JPY');  
        bill.add(bill3);
        AddMultipleBillController.saveBillList(bill, shipment.Id);
        // add.saveBillList(bill,shipment.Id);
        // add.saveBillList(bill,shipment.Id);
        //System.assertEquals('ONE (1) 20\'DC CONTAINER ONLY', Consol.clofor_com_cfs__NumberofContainer__c);
        
        Test.stopTest();
    }
}