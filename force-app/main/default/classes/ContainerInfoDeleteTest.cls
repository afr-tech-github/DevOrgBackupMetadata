@isTest
public class ContainerInfoDeleteTest {
    public static testMethod void delContainerInfo() {
        Test.startTest();
        Account ac = new Account(Name = 'testName112233',
                                 clofor_com_cfs__CustomerType__c = 'Others',
                                 clofor_com_cfs__Primary_Exchange_Rate_Currency__c='USD - U.S. Dollar');
        insert ac;
        clofor_com_cfs__Site_Custom_Settings__c cus = new clofor_com_cfs__Site_Custom_Settings__c();
        cus.clofor_com_cfs__Company_Country__c = 'JAPAN';
        cus.clofor_com_cfs__Local_Currency__c = 'JPY';
        cus.clofor_com_cfs__Disable_Monthly_Yearly_HBL_ID__c = false;
         insert cus;
        
        clofor_com_cfs__CustomObject1__c ship = new clofor_com_cfs__CustomObject1__c(clofor_com_cfs__Field1__c = ac.Id,
        clofor_com_cfs__Container__c = '40\'ISO',
        clofor_com_cfs__ContainerNumber__c = 1,
        clofor_com_cfs__Container2__c = '45\'DC',
        clofor_com_cfs__ContainerNumber2__c = 1,
        clofor_com_cfs__Container3__c = '20\'DC',
        clofor_com_cfs__ContainerNumber3__c = 1,
        clofor_com_cfs__Container4__c = '20\'RF',
        clofor_com_cfs__ContainerNumber4__c = 1,  
        clofor_com_cfs__Container5__c = '40\'RF',
        clofor_com_cfs__ContainerNumber5__c = 1,
        clofor_com_cfs__Container6__c = '45\'RF',
        clofor_com_cfs__ContainerNumber6__c = 1,  
        clofor_com_cfs__Container7__c = '20\'OT',
        clofor_com_cfs__ContainerNumber7__c = 1, 
        clofor_com_cfs__ETD__c = Date.newInstance(2008, 1, 1),
        clofor_com_cfs__ETA__c = Date.newInstance(2008, 8, 21),    
        clofor_com_cfs__Container_Measurement_Details__c = 'TEMU12346 / 1234578 / 20\'DC / 1 Box / 20704.300KGS / 12.000CBM',
        clofor_com_cfs__ContainerDetailBLType2__c = 'TEMU12346 / 20\'DC',
        clofor_com_cfs__Container_Details_SL__c = 'TEMU12346 / 1234578 / 20\'DC',
        clofor_com_cfs__ContainerDetailSIType2__c = 'TEMU12346 / 1234578 / 20\'DC / 1 / 20704.300 / 12.000',
        clofor_com_cfs__CONTAINERSEALNO__c = 'TEMU12346/1234578'
        );
        insert ship;
        List<clofor_com_cfs__Container_Info__c> lstInfo = new List<clofor_com_cfs__Container_Info__c>();
        clofor_com_cfs__Container_Info__c inff = new clofor_com_cfs__Container_Info__c(clofor_com_cfs__Container__c = '40\'ISO',
                                                                                       clofor_com_cfs__HBL_SHIPMENT__c = ship.Id);
        lstInfo.add(inff);
        clofor_com_cfs__Container_Info__c inf = new clofor_com_cfs__Container_Info__c(clofor_com_cfs__Container__c = '40\'ISO',
                                                                                       clofor_com_cfs__HBL_SHIPMENT__c = ship.Id);
        lstInfo.add(inf);
        clofor_com_cfs__Container_Info__c inf2 = new clofor_com_cfs__Container_Info__c(clofor_com_cfs__Container__c = '45\'DC',
                                                                                       clofor_com_cfs__HBL_SHIPMENT__c = ship.Id);
        lstInfo.add(inf2);
        clofor_com_cfs__Container_Info__c inf3 = new clofor_com_cfs__Container_Info__c(clofor_com_cfs__Container__c = '20\'DC',
                                                                                       clofor_com_cfs__HBL_SHIPMENT__c = ship.Id);
        lstInfo.add(inf3);
        clofor_com_cfs__Container_Info__c inf4 = new clofor_com_cfs__Container_Info__c(clofor_com_cfs__Container__c = '20\'RF',
                                                                                       clofor_com_cfs__HBL_SHIPMENT__c = ship.Id);
        lstInfo.add(inf4);
        clofor_com_cfs__Container_Info__c inf5 = new clofor_com_cfs__Container_Info__c(clofor_com_cfs__Container__c = '40\'RF',
                                                                                       clofor_com_cfs__HBL_SHIPMENT__c = ship.Id);
        lstInfo.add(inf5);
        clofor_com_cfs__Container_Info__c inf6 = new clofor_com_cfs__Container_Info__c(clofor_com_cfs__Container__c = '45\'RF',
                                                                                       clofor_com_cfs__HBL_SHIPMENT__c = ship.Id);
        lstInfo.add(inf6);
        clofor_com_cfs__Container_Info__c inf7 = new clofor_com_cfs__Container_Info__c(clofor_com_cfs__Container__c = '20\'OT',
                                                                                       clofor_com_cfs__HBL_SHIPMENT__c = ship.Id);
        lstInfo.add(inf7);

        clofor_com_cfs__Container_Info__c bl1 = new clofor_com_cfs__Container_Info__c(clofor_com_cfs__Container_NO__c = 'TEMU12346', clofor_com_cfs__HBL_SHIPMENT__c = ship.Id);
        lstInfo.add(bl1);
        clofor_com_cfs__Container_Info__c bl2 = new clofor_com_cfs__Container_Info__c(clofor_com_cfs__Seal_No__c = '1234578', clofor_com_cfs__HBL_SHIPMENT__c = ship.Id);
        lstInfo.add(bl2);
        clofor_com_cfs__Container_Info__c bl3 = new clofor_com_cfs__Container_Info__c(clofor_com_cfs__QUANTITY_PACKAGES__c = 1, clofor_com_cfs__HBL_SHIPMENT__c = ship.Id);
        lstInfo.add(bl3);
        clofor_com_cfs__Container_Info__c bl4 = new clofor_com_cfs__Container_Info__c(clofor_com_cfs__CargoTypeUnit__c = 'Box', clofor_com_cfs__HBL_SHIPMENT__c = ship.Id);
        lstInfo.add(bl4);
        clofor_com_cfs__Container_Info__c bl5 = new clofor_com_cfs__Container_Info__c(clofor_com_cfs__GROSS_WEIGHT__c = 20704.300, clofor_com_cfs__HBL_SHIPMENT__c = ship.Id);
        lstInfo.add(bl5);
        clofor_com_cfs__Container_Info__c bl6 = new clofor_com_cfs__Container_Info__c(clofor_com_cfs__MEASUREMENT_CBM__c = 12.000, clofor_com_cfs__HBL_SHIPMENT__c = ship.Id);
        lstInfo.add(bl6);

        insert lstInfo;
        delete inf;
        // clofor_com_cfs__Container_Info__c inf01 = [Select Id From clofor_com_cfs__Container_Info__c where Id =: inf.Id];
        // try{
            // delete inf01;
        // }catch(Exception e){
            // 
        // }                
        Test.stopTest();
    }
}