public with sharing class BillingTriggerHelper {
	public static void onBeforeInsert(List<Billing__c> newBilling){
		Set<Id> workOrderIdSet = new Set<Id>();
		for( Billing__c billing : newBilling){
			if(billing.WorkOrderID__c != null){
				workOrderIdSet.add(billing.WorkOrderID__c);
			}
			
		}
		Map<Id, Decimal> mapMaxNoBilling = new Map<Id, Decimal>();
		// get list oldBilling
		List<WorkOrder__c> listWorkOrder = [SELECT Id, MaxNoBilling__c FROM WorkOrder__c WHERE Id IN: workOrderIdSet];
		for(WorkOrder__c workOrder : listWorkOrder){
			Decimal maxNo = 0;
			if(workOrder.MaxNoBilling__c ==null){
				mapMaxNoBilling.put(workOrder.Id, 0);
			}else{
				mapMaxNoBilling.put(workOrder.Id, workOrder.MaxNoBilling__c);
			}
			
		}
		for( Billing__c billing : newBilling){
			if(billing.WorkOrderID__c == null){
				continue;
			}
			billing.BillingDisplayNo__c = 0;
			billing.BillingDisplayNo__c = mapMaxNoBilling.get(billing.WorkOrderID__c) + 1;
			mapMaxNoBilling.put(billing.WorkOrderID__c, billing.BillingDisplayNo__c);
		}
	}
    
    public static void translateUnitValue(List<Billing__c> newBills){
        //get unit formula value.
        
        for(Billing__c bill : newBills){
            
            bill.ChargeUnitInPrint__c = bill.ChargeUnitFormula__c;
            if(bill.ChargeUnitFormula__c =='本'){
                bill.ChargeUnitInPrint__c = 'Unit';
            } 
            if(bill.ChargeUnitFormula__c =='コンテナ' || bill.ChargeUnitFormula__c =='Container'){
                bill.ChargeUnitInPrint__c = bill.ContainerrSizeFormula__c;
            }
            if(bill.ChargeUnitFormula__c =='件'){
                bill.ChargeUnitInPrint__c = 'Case';
            }
        }
    }
	public static void onBeforeUpdate(List<Billing__c> newBilling){
		//Set<Id> workOrderIdSet = new Set<Id>();
		//for( Billing__c billing : newBilling){
		//	if(billing.WorkOrderID__c != null){
		//		workOrderIdSet.add(billing.WorkOrderID__c);
		//	}
			
		//}
		//Map<Id, Decimal> mapMaxNoBilling = new Map<Id, Decimal>();
		//// get list oldBilling
		//List<WorkOrder__c> listWorkOrder = [SELECT Id, MaxNoBilling__c FROM WorkOrder__c WHERE Id IN: workOrderIdSet];
		//for(WorkOrder__c workOrder : listWorkOrder){
		//	Decimal maxNo = 0;
		//	if(workOrder.MaxNoBilling__c ==null){
		//		mapMaxNoBilling.put(workOrder.Id, 0);
		//	}else{
		//		mapMaxNoBilling.put(workOrder.Id, workOrder.MaxNoBilling__c);
		//	}
			
		//}
		//for( Billing__c billing : newBilling){
		//	if(billing.WorkOrderID__c == null){
		//		continue;
		//	}
		//	billing.BillingDisplayNo__c = 0;
		//	billing.BillingDisplayNo__c = mapMaxNoBilling.get(billing.WorkOrderID__c) + 1;
		//	mapMaxNoBilling.put(billing.WorkOrderID__c, billing.BillingDisplayNo__c);
		//}
	}
}