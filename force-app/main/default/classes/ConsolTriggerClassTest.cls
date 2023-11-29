@isTest
public class ConsolTriggerClassTest {
    public static testMethod void checkConsol() {
        Test.startTest();

        Account ac = new Account(Name = 'testAc',
                                 clofor_com_cfs__EnglishCompanyName__c = 'testAcENG',
                                 clofor_com_cfs__CustomerType__c = 'Others'
                                );
        insert ac;

        clofor_com_cfs__MasterAnken__c Consol =  new clofor_com_cfs__MasterAnken__c ( Name = 'testConsol',
                                                                                     clofor_com_cfs__MBookingNv__c = ac.Id);

        insert Consol;

        
        clofor_com_cfs__ConsolCNTR__c con = new clofor_com_cfs__ConsolCNTR__c (clofor_com_cfs__Consolidation__c = Consol.Id,
                                                                                clofor_com_cfs__ContainerType__c = '20\'DC');
        insert con;
        Consol.clofor_com_cfs__NumberofContainer1__c = null;
        update Consol;
        //System.assertEquals('ONE (1) 20\'DC CONTAINER ONLY', Consol.clofor_com_cfs__NumberofContainer__c);
        
        Test.stopTest();
    }
}