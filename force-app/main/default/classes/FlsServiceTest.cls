@isTest
public class FlsServiceTest {
    public static testMethod void test(){
        Test.startTest();
        Account ac = new Account(Name = 'testAc2'
               );
        List<Account> listN = new List<Account>();
        listN.add(ac);
        FlsService.doInsert(listN);
        FlsService.doUpdate(listN);
        FlsService.doUpsert(listN);
        FlsService.doDelete(listN);
        
        Account ac1 = new Account(Name = 'testAc3'
               );
        FlsService.doInsert(ac1);
        FlsService.doUpdate(ac1);
        FlsService.doUpsert(ac1);
        FlsService.doDelete(ac1);
        
        
        Test.stopTest();
    }
}