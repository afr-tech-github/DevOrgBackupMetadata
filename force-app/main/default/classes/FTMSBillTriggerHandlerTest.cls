@isTest
public class FTMSBillTriggerHandlerTest {
    public static testMethod void checkDelBill() {
        Test.startTest();
        Account ac = new Account(Name = 'Test1',CustomerType__c = 'Others');
        clofor_com_cfs__Site_Custom_Settings__c cus = new clofor_com_cfs__Site_Custom_Settings__c();
        cus.clofor_com_cfs__Company_Country__c = 'JAPAN';
        cus.clofor_com_cfs__Local_Currency__c = 'JPY';
        cus.clofor_com_cfs__Disable_Monthly_Yearly_HBL_ID__c = false;
         insert cus;
        insert ac;
        clofor_com_cfs__CustomObject1__c ship = new clofor_com_cfs__CustomObject1__c(clofor_com_cfs__ETD__c =  Date.newInstance(2008, 1, 1),
                                                                                     clofor_com_cfs__ETA__c =  Date.newInstance(2008, 1, 31),
                                                                                     clofor_com_cfs__Branch__c = 'Hanoi',
                                                                                     clofor_com_cfs__Field1__c = ac.Id);
        insert ship;
        clofor_com_cfs__AnkenMeisai__c bill = new clofor_com_cfs__AnkenMeisai__c(clofor_com_cfs__InboundVATInvNo__c = 'abc',
        																		 clofor_com_cfs__OutboundVATInvNo__c = 'xyz',
                                                                                 clofor_com_cfs__Anken__c =ship.Id);
        insert bill;
        try {
            delete bill;
        } catch (Exception e) {
            system.assert(e.getMessage().contains('Cannot be deleted because VAT output and VAT input have been entered'));
        }
        Test.stopTest();
    }
}