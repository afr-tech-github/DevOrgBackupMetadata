public class excuteTriggerControll {
	public static boolean firstRunCashPaymentAutoProcesing = true;
    public static boolean firstRunHBLSellingBuyingTrigger = true;
    public static boolean firstRun = true;
    public static void translateUnitValueInsert(List<AnkenMeisai__c> newBills){
        //get unit formula value.
        //List<AnkenMeisai__c> bills = [SELECT Id, ChargeUnitFormula__c, ContainerSizeFormula__c from AnkenMeisai__c where Id IN: mapNewBills.keySet()];
        for(AnkenMeisai__c bill : newBills){
            if (bill.ChargeUnitInPrint__c == null){ 
                if (bill.ContainerSizeFormula__c != null){
                    bill.ChargeUnitInPrint__c = bill.ContainerSizeFormula__c;
                } else {
                    bill.ChargeUnitInPrint__c = bill.ChargeUnitFormula__c;
                }
                // bill.ChargeUnitInPrint__c = bill.ChargeUnitFormula__c;
                // if(bill.ChargeUnitFormula__c =='本'){
                    // bill.ChargeUnitInPrint__c = 'Unit';
                // } 
                // if(bill.ChargeUnitFormula__c =='コンテナ' || bill.ChargeUnitFormula__c =='Container'){
                    // bill.ChargeUnitInPrint__c = bill.ContainerSizeFormula__c;
                // }
                // if(bill.ChargeUnitFormula__c =='件'){
                    // bill.ChargeUnitInPrint__c = 'Case';
                // }
            }
        }
    }

    public static void translateUnitValueUpdate(List<AnkenMeisai__c> oldBills, List<AnkenMeisai__c> newBills){
        //get unit formula value.
        //List<AnkenMeisai__c> bills = [SELECT Id, ChargeUnitFormula__c, ContainerSizeFormula__c from AnkenMeisai__c where Id IN: mapNewBills.keySet()];
        for (AnkenMeisai__c billold : oldBills){
            for(AnkenMeisai__c bill : newBills){
                if ((bill.Id == billold.Id ) && (bill.ChargeUnitInPrint__c == null || bill.clofor_com_cfs__ContainerSize__c != billold.clofor_com_cfs__ContainerSize__c || bill.clofor_com_cfs__ChargeUnit__c != billold.clofor_com_cfs__ChargeUnit__c)){       
                    // bill.ChargeUnitInPrint__c = bill.ChargeUnitFormula__c;
                    // if(bill.ChargeUnitFormula__c =='本'){
                        // bill.ChargeUnitInPrint__c = 'Unit';
                    // } 
                    // if(bill.ChargeUnitFormula__c =='コンテナ' || bill.ChargeUnitFormula__c =='Container'){
                        // bill.ChargeUnitInPrint__c = bill.ContainerSizeFormula__c;
                    // }
                    // if(bill.ChargeUnitFormula__c =='件'){
                        // bill.ChargeUnitInPrint__c = 'Case';
                    // }
                    if (bill.ContainerSizeFormula__c != null){
                        bill.ChargeUnitInPrint__c = bill.ContainerSizeFormula__c;
                    } else {
                        bill.ChargeUnitInPrint__c = bill.ChargeUnitFormula__c;
                    }
                }
            }
        }
    }
}