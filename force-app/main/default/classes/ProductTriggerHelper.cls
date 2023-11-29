public with sharing class ProductTriggerHelper {
	public static void rollUpStockInAndOutNumber(Map<Id, PRODUCT__c> mapProductNew) {
		List<AggregateResult> listResult = [SELECT 
                                            ProductID__c, RecordType.DeveloperName, Sum(Quantity__c) quantityTotal 
                                          FROM Stock__c WHERE ProductID__c In: mapProductNew.keySet()
                                          AND StockStatus__c ='Completed'
                                          GROUP BY ProductID__c, RecordType.DeveloperName];

    	List<PRODUCT__c> listProductUpdate = new List<PRODUCT__c>();

    	Map<Id, PRODUCT__c> mapProductUpdate = new Map<Id, PRODUCT__c>();

      
    	for(AggregateResult result : listResult){
        	if(!String.isBlank((Id)result.get('clofor_com_cfs__ProductID__c'))){
        		if(mapProductNew.containsKey((Id)result.get('clofor_com_cfs__ProductID__c'))){
            
		            if((String)result.get('DeveloperName') == 'StockOut'){

		            	mapProductNew.get((Id)result.get('clofor_com_cfs__ProductID__c')).RollupStockOut__c = (Decimal)result.get('quantityTotal');
		            }
		            if((String)result.get('DeveloperName') == 'StockIn'){
		            	mapProductNew.get((Id)result.get('clofor_com_cfs__ProductID__c')).RollupStockIn__c = (Decimal)result.get('quantityTotal');
		        	}
          		}
          
    		}

		}
    	
	}
}