public with sharing class ContainerInfoDeleteClass {
    public static void isAfterDelContainerNumber(List<clofor_com_cfs__Container_Info__c> lstNew){
        String shipId = '';
        String ConId = '';
        for(clofor_com_cfs__Container_Info__c info : lstNew){
            shipId = info.clofor_com_cfs__HBL_SHIPMENT__c;
            ConId = info.Id;
        }
        clofor_com_cfs__CustomObject1__c ship = [Select 
        Id,
        ContainerNumberList__c,
        ContainerTypeList__c,
        clofor_com_cfs__Container__c,clofor_com_cfs__ContainerNumber__c,
        clofor_com_cfs__Container2__c,clofor_com_cfs__ContainerNumber2__c,
        clofor_com_cfs__Container3__c,clofor_com_cfs__ContainerNumber3__c,
        clofor_com_cfs__Container4__c,clofor_com_cfs__ContainerNumber4__c,
        clofor_com_cfs__Container5__c,clofor_com_cfs__ContainerNumber5__c,
        clofor_com_cfs__Container6__c,clofor_com_cfs__ContainerNumber6__c,
        clofor_com_cfs__Container7__c,clofor_com_cfs__ContainerNumber7__c,
        CONTAINERSEALNO__c,
        ContainerDetail__c,
        ContainerDetailBLType2__c,
        Container_Details_SL__c,
        ContainerDetailSIType2__c,
        Container_Measurement_Details__c,
            (SELECT Id, Container_NO__c, Seal_No__c, Container__c, Container_Ownership_Code__c,
            Container_Size_Code__c, Container_Type_Code__c, Empty_Full_Container_Identification__c,
            QUANTITY_PACKAGES__c, GROSS_WEIGHT__c, MEASUREMENT_CBM__c, NET_WEIGHT__c, GOODS__c, CargoTypeUnit__c
            FROM Container_Info__r
            ORDER BY Id)
        From clofor_com_cfs__CustomObject1__c 
        Where Id =: shipId];
        system.debug('ship1 :' +ship);
        List<clofor_com_cfs__Container_Info__c> lstinfo = [Select 
        Id,
        Container_NO__c, Seal_No__c, Container__c, Container_Ownership_Code__c,
        Container_Size_Code__c, Container_Type_Code__c, Empty_Full_Container_Identification__c,
        QUANTITY_PACKAGES__c, GROSS_WEIGHT__c, MEASUREMENT_CBM__c, NET_WEIGHT__c, GOODS__c, CargoTypeUnit__c
        From clofor_com_cfs__Container_Info__c 
        Where clofor_com_cfs__HBL_SHIPMENT__c =: shipId AND Id !=: ConId];
        system.debug('lstinfo :'+lstinfo);
        Integer count = 0;
        Integer count2 = 0;
        Integer count3 = 0;
        Integer count4 = 0;
        Integer count5 = 0;
        Integer count6 = 0;
        Integer count7 = 0;
        Integer temp = 0;
        String ContainerBL = '';
        String ContainerBL2 = '';
        String ContainerSI = '';
        String ContainerSI2 = '';
        String ContainerNLF = '';
        String ContainerTLF = '';
        String containerSealNo = '';
        String test = 'dsdsdsd / ';
        String test2 = test.substring(0,test.length()-2);
        System.debug('test2 :'+test2);
        for(clofor_com_cfs__Container_Info__c inf : lstinfo){
        String containerType = inf.Container__c;
        // if (containerType != null) { 
        //     containerSealNo += (inf.Container_NO__c != null ? inf.Container_NO__c.toUpperCase() : '<missing>') + '/'
        //                     + (inf.Seal_No__c != null ? inf.Seal_No__c.toUpperCase() : '<missing>') + ' ';
        // }
        if(inf.Container_NO__c != null){
            ContainerNLF += String.valueOf(inf.Container_NO__c+'\n');
        }
        if(inf.Container__c != null){
            ContainerTLF += String.valueOf(inf.Container__c+'\n');
        }
        if(inf.Container_NO__c != null){
            ContainerBL += String.valueOf(inf.Container_NO__c+' / ');
            ContainerBL2 += String.valueOf(inf.Container_NO__c+' / ');
            ContainerSI += String.valueOf(inf.Container_NO__c+' / ');
            ContainerSI2 += String.valueOf(inf.Container_NO__c+' / ');
        }if(inf.Seal_No__c != null){
            ContainerBL += String.valueOf(inf.Seal_No__c+' / ') ;
            ContainerSI += String.valueOf(inf.Seal_No__c+' / ');
            ContainerSI2 += String.valueOf(inf.Seal_No__c+' / ');
        }if(inf.Container__c != null){
            ContainerBL += String.valueOf(inf.Container__c+' / ');
            ContainerBL2 += String.valueOf(inf.Container__c+' / ');
            ContainerSI += String.valueOf(inf.Container__c+' / ');
            ContainerSI2 += String.valueOf(inf.Container__c+' / ');
        }if(inf.QUANTITY_PACKAGES__c != null){
            if(inf.QUANTITY_PACKAGES__c > 1){
            ContainerBL += String.valueOf(inf.QUANTITY_PACKAGES__c+' '+inf.CargoTypeUnit__c+'s'+' / ');
        }else
            ContainerBL += String.valueOf(inf.QUANTITY_PACKAGES__c+' '+inf.CargoTypeUnit__c+' / ');
            ContainerSI2 += String.valueOf(inf.QUANTITY_PACKAGES__c+' / ');
        }
        // if(inf.QUANTITY_PACKAGES__c > 1){
        //     ContainerBL += String.valueOf(inf.QUANTITY_PACKAGES__c+inf.CargoTypeUnit__c+'s'+' / ');
        // }
        if(inf.GROSS_WEIGHT__c != null){
            ContainerBL += String.valueOf(inf.GROSS_WEIGHT__c+'KGS'+' / ');
        }if(inf.MEASUREMENT_CBM__c != null){
            ContainerBL += String.valueOf(inf.MEASUREMENT_CBM__c+'CBM');
            ContainerSI2 += String.valueOf(inf.MEASUREMENT_CBM__c+'CBM');
        }
        if(ContainerBL2.endsWith(' ')){
            ContainerBL2 = ContainerBL2.substring(0,ContainerBL2.length()-2);
        }
        if(ContainerBL.endsWith(' ')){
            ContainerBL = ContainerBL.substring(0,ContainerBL.length()-2);
        }
        if(ContainerSI.endsWith(' ')){
            ContainerSI = ContainerSI.substring(0,ContainerSI.length()-2);
        }
        if(ContainerSI2.endsWith(' ') || ContainerSI2.endsWith('/')){
            ContainerSI2 = ContainerSI2.substring(0,ContainerSI2.length()-2);
        }
            ContainerBL +='\n';
            ContainerBL2 += '\n';
            ContainerSI += '\n';
            ContainerSI2 += '\n';
            // containerSealNo += '\n';
            // String t = String.valueOf(ContainerBL2.charAt(ContainerBL2.length() - 1));  
            // System.debug('ContainerBL2 :'+t); 
            
            temp ++;
            
            containerSealNo += (inf.Container_NO__c != null ? inf.Container_NO__c.toUpperCase() : '<missing>') + '/'
                            + (inf.Seal_No__c != null ? inf.Seal_No__c.toUpperCase() : '<missing>') + ' ';
            
                // ContainerBL += '<br/>';
                // ContainerBL2 += '<br/>';
                // ContainerSI += '<br/>';
                // ContainerSI2 += '<br/>';
            
            if(ship.clofor_com_cfs__Container__c == inf.clofor_com_cfs__Container__c){
                count ++;
            }else if(ship.clofor_com_cfs__Container2__c == inf.clofor_com_cfs__Container__c){
                count2 ++;
            }
            else if(ship.clofor_com_cfs__Container3__c == inf.clofor_com_cfs__Container__c){
                count3 ++;
            }
            else if(ship.clofor_com_cfs__Container4__c == inf.clofor_com_cfs__Container__c){
                count4 ++;
            }
            else if(ship.clofor_com_cfs__Container5__c == inf.clofor_com_cfs__Container__c){
                count5 ++;
            }
            else if(ship.clofor_com_cfs__Container6__c == inf.clofor_com_cfs__Container__c){
                count6 ++;
            }
            else if(ship.clofor_com_cfs__Container7__c == inf.clofor_com_cfs__Container__c){
                count7 ++;
            }
        }
        // System.debug('ContainerBL'+ContainerBL);
        //system.debug('count :' +count +count2 +count3 +count4 +count5 +count6 +count7);
        if(count != 0){
            ship.clofor_com_cfs__ContainerNumber__c = count;
        }else
        {
            ship.clofor_com_cfs__ContainerNumber__c = null;
            ship.clofor_com_cfs__Container__c = null;
        }
        if(count2 != 0){
            ship.clofor_com_cfs__ContainerNumber2__c = count2;
        }else
        {
            ship.clofor_com_cfs__ContainerNumber2__c = null;
            ship.clofor_com_cfs__Container2__c = null;
        }
        if(count3 != 0){
            ship.clofor_com_cfs__ContainerNumber3__c = count3;
        }else
        {
            ship.clofor_com_cfs__ContainerNumber3__c = null;
            ship.clofor_com_cfs__Container3__c = null;
        }
        if(count4 != 0){
            ship.clofor_com_cfs__ContainerNumber4__c = count4;
        }else
        {
            ship.clofor_com_cfs__ContainerNumber4__c = null;
            ship.clofor_com_cfs__Container4__c = null;
        }
        if(count5 != 0){
            ship.clofor_com_cfs__ContainerNumber5__c = count5;
        }else
        {
            ship.clofor_com_cfs__ContainerNumber5__c = null;
            ship.clofor_com_cfs__Container5__c = null;
        }
        if(count6 != 0){
            ship.clofor_com_cfs__ContainerNumber6__c = count6;
        }else
        {
            ship.clofor_com_cfs__ContainerNumber6__c = null;
            ship.clofor_com_cfs__Container6__c = null;
        }
        if(count7 != 0){
            ship.clofor_com_cfs__ContainerNumber7__c = count7;
        }else
        {
            ship.clofor_com_cfs__ContainerNumber7__c = null;
            ship.clofor_com_cfs__Container7__c = null;
        }
        ship.Container_Measurement_Details__c = ContainerBL ;
        ship.ContainerDetailBLType2__c = ContainerBL2;
        ship.Container_Details_SL__c = ContainerSI;
        ship.ContainerDetailSIType2__c = ContainerSI2;
        ship.CONTAINERSEALNO__c = containerSealNo;
        ship.ContainerNumberList__c = ContainerNLF;
        ship.ContainerTypeList__c = ContainerTLF;

        try {
            update ship;
        } catch (DmlException e){
            // System.debug('ship mes: '+e.getMessage());
        }


    }
}