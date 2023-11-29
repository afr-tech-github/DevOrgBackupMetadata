public with sharing class SalesOrderTriggerHelper extends AbstractTriggerHandler{
    private Map<Id, Map<String, Integer>> mapContainerNumberBySO = new Map<Id, Map<String, Integer>>();
    Map<Id, List<String>>  threeFirstContainerTypes = new Map<Id, List<String>> ();
    public override String getHandlerName() {
        return 'SalesOrderTriggerHelper';
    }
    public override void bulkBeforeUpdate() {
        countContainerNumberBySO((Map<Id,clofor_com_cfs__SALES_ORDER__c>)Trigger.newMap);
    }
    public override void beforeUpdate(SObject soOld, SObject so) {
        clofor_com_cfs__SALES_ORDER__c salesOrder = (clofor_com_cfs__SALES_ORDER__c) so;
        clofor_com_cfs__SALES_ORDER__c oldSalesOrder = (clofor_com_cfs__SALES_ORDER__c) soOld;
        System.debug('new' + salesOrder.clofor_com_cfs__ContainerQty2__c);
        System.debug('old' + oldSalesOrder.clofor_com_cfs__ContainerQty2__c);
        Map<Integer, String> wordingMap = new Map<Integer, String>();
        if(mapContainerNumberBySO.containsKey(salesOrder.Id)){
            Map<String, Integer> containerTypeNumberMap = mapContainerNumberBySO.get(salesOrder.Id);
            List<Integer> numbersList = new List<Integer>();
            List<String> containerTypes = threeFirstContainerTypes.get(salesOrder.Id); 
            
            Integer index = 0;
            for(String containerType : containerTypes){
                Integer numberContainer = containerTypeNumberMap.get(containerType);
                if(index == 0){
                    salesOrder.clofor_com_cfs__ContainerType1__c = containerType;
                    salesOrder.clofor_com_cfs__ContainerQty1__c	= numberContainer;
                    
                }
                if(index == 1){
                    salesOrder.clofor_com_cfs__ContainerType2__c = containerType;
                    salesOrder.clofor_com_cfs__ContainerQty2__c	= numberContainer;
                }
                if(index == 2){
                    salesOrder.clofor_com_cfs__ContainerType3__c = containerType;
                    salesOrder.clofor_com_cfs__ContainerQty3__c	= numberContainer;
                }
                index ++;
            }
            if(index < 1){
                salesOrder.clofor_com_cfs__ContainerType2__c = null;
                salesOrder.clofor_com_cfs__ContainerQty2__c = null;
            }
            if(index < 2){
                salesOrder.clofor_com_cfs__ContainerType3__c = null;
                salesOrder.clofor_com_cfs__ContainerQty3__c = null;
            }
        }else{
            salesOrder.clofor_com_cfs__ContainerType1__c = null;
            salesOrder.clofor_com_cfs__ContainerQty1__c = null;
            salesOrder.clofor_com_cfs__ContainerType2__c = null;
            salesOrder.clofor_com_cfs__ContainerQty2__c = null;
            salesOrder.clofor_com_cfs__ContainerType3__c = null;
            salesOrder.clofor_com_cfs__ContainerQty3__c = null;
        }

        System.debug('new' + salesOrder.clofor_com_cfs__ContainerQty2__c);
        System.debug('old' + oldSalesOrder.clofor_com_cfs__ContainerQty2__c);
        if((salesOrder.clofor_com_cfs__ContainerType1__c != oldSalesOrder.clofor_com_cfs__ContainerType1__c)
           || (salesOrder.clofor_com_cfs__ContainerQty1__c != oldSalesOrder.clofor_com_cfs__ContainerQty1__c)
           || (salesOrder.clofor_com_cfs__ContainerType2__c != oldSalesOrder.clofor_com_cfs__ContainerType2__c)
           || (salesOrder.clofor_com_cfs__ContainerQty2__c != oldSalesOrder.clofor_com_cfs__ContainerQty2__c)
           || (salesOrder.clofor_com_cfs__ContainerType3__c != oldSalesOrder.clofor_com_cfs__ContainerType3__c)
           || (salesOrder.clofor_com_cfs__ContainerQty3__c != oldSalesOrder.clofor_com_cfs__ContainerQty3__c)
         	|| String.isBlank(salesOrder.clofor_com_cfs__NumberofContainer_inwords__c)){
               
               String wordingContainer='';
               List<String> wordingContainerTypes = new List<String>();
               Integer numberWording = 0;
               String containerType = '';
               if(!String.IsBlank(salesOrder.clofor_com_cfs__ContainerType1__c)
                  || salesOrder.clofor_com_cfs__ContainerQty1__c != null){
                    containerType = 'Unknown';
                    if(salesOrder.clofor_com_cfs__ContainerQty1__c != null){
                        numberWording = (Integer)salesOrder.clofor_com_cfs__ContainerQty1__c;
                    }
                    if(!String.IsBlank(salesOrder.clofor_com_cfs__ContainerType1__c)){
                        containerType =  salesOrder.clofor_com_cfs__ContainerType1__c;
                    }
                    wordingContainer = NumbericUtils.convertNumberToEnglishText(numberWording) 
                        + ' (' + String.valueOf(numberWording) 
                        + ' x ' +  containerType + ')';
                    if(numberWording > 1){
                        wordingContainer += ' containers';
                    }else{
                        wordingContainer += ' container';
                    }
                      wordingContainerTypes.add(wordingContainer);
                      
                  }
               if(!String.IsBlank(salesOrder.clofor_com_cfs__ContainerType2__c)
                  || salesOrder.clofor_com_cfs__ContainerQty2__c != null){
                    numberWording = 0;
                    containerType = 'Unknown';
                    if(salesOrder.clofor_com_cfs__ContainerQty2__c != null){
                        numberWording =  (Integer)salesOrder.clofor_com_cfs__ContainerQty2__c;
                    }
                    if(!String.IsBlank(salesOrder.clofor_com_cfs__ContainerType2__c)){
                        containerType =  salesOrder.clofor_com_cfs__ContainerType2__c;
                    }
                    wordingContainer = NumbericUtils.convertNumberToEnglishText(numberWording) 
                          + ' (' + String.valueOf(numberWording) 
                          + ' x ' +  containerType + ')';
                    if(numberWording > 1){
                        wordingContainer += ' containers';
                    }else{
                        wordingContainer += ' container';
                    }
                    wordingContainerTypes.add(wordingContainer);
                      
                }
               if(!String.IsBlank(salesOrder.clofor_com_cfs__ContainerType3__c)
                  || salesOrder.clofor_com_cfs__ContainerQty3__c != null){
                      numberWording = 0;
                      containerType = 'Unknown';
                      if(salesOrder.clofor_com_cfs__ContainerQty3__c != null){
                          numberWording =  (Integer)salesOrder.clofor_com_cfs__ContainerQty3__c;
                      }
                      if(!String.IsBlank(salesOrder.clofor_com_cfs__ContainerType3__c)){
                          containerType =  salesOrder.clofor_com_cfs__ContainerType3__c;
                      }
                      wordingContainer = NumbericUtils.convertNumberToEnglishText(numberWording) 
                          + ' (' + String.valueOf(numberWording) 
                          + ' x ' + containerType + ')';

                    if(numberWording > 1){
                        wordingContainer += ' containers';
                    }else{
                        wordingContainer += ' container';
                    }
                      wordingContainerTypes.add(wordingContainer);
                      
                }
               	String wordingResult = String.join(wordingContainerTypes, ' and ');
                wordingResult += ' only';
                
               salesOrder.clofor_com_cfs__NumberofContainer_inwords__c = wordingResult.toUpperCase();
               
           }
        /*if(salesOrder.clofor_com_cfs__ContainerType1__c == null
            && salesOrder.clofor_com_cfs__ContainerQty1__c == null
            && salesOrder.clofor_com_cfs__ContainerType2__c == null
            && salesOrder.clofor_com_cfs__ContainerQty2__c == null
            && salesOrder.clofor_com_cfs__ContainerType3__c == null
            && salesOrder.clofor_com_cfs__ContainerQty3__c == null){
            salesOrder.clofor_com_cfs__NumberofContainer_inwords__c = '';
        }*/
    
        
    }
    
    
    private void countContainerNumberBySO(Map<Id, clofor_com_cfs__SALES_ORDER__c> salesOrderMap ){
        mapContainerNumberBySO = new Map<Id, Map<String, Integer>>();
        threeFirstContainerTypes = new Map<Id, List<String>> ();
        for( clofor_com_cfs__ContainerGoodSO__c oldContainer : [SELECT Id, clofor_com_cfs__GOODSSO__c, clofor_com_cfs__ContainerType__c
                                                                FROM clofor_com_cfs__ContainerGoodSO__c
                                                                WHERE clofor_com_cfs__GOODSSO__c IN: salesOrderMap.keySet()
                                                                ORDER BY CreatedDate ASC]){
           if(!mapContainerNumberBySO.containsKey(oldContainer.clofor_com_cfs__GOODSSO__c)){
                                                                            
               mapContainerNumberBySO.put(oldContainer.clofor_com_cfs__GOODSSO__c, new Map<String, Integer>{oldContainer.clofor_com_cfs__ContainerType__c => 1});
               threeFirstContainerTypes.put(oldContainer.clofor_com_cfs__GOODSSO__c, new List<String>{oldContainer.clofor_com_cfs__ContainerType__c});
           }else {
               Map<String, Integer> containerTypeNumberMap = mapContainerNumberBySO.get(oldContainer.clofor_com_cfs__GOODSSO__c);
               if(containerTypeNumberMap.containsKey(oldContainer.clofor_com_cfs__ContainerType__c)){
                   Integer numberContainer = containerTypeNumberMap.get(oldContainer.clofor_com_cfs__ContainerType__c);
                   numberContainer += 1;
                   containerTypeNumberMap.put(oldContainer.clofor_com_cfs__ContainerType__c, numberContainer);
               }else if(!containerTypeNumberMap.containsKey(oldContainer.clofor_com_cfs__ContainerType__c) && containerTypeNumberMap.size() < 3){
                   containerTypeNumberMap.put(oldContainer.clofor_com_cfs__ContainerType__c, 1);
                   threeFirstContainerTypes.get(oldContainer.clofor_com_cfs__GOODSSO__c).add(oldContainer.clofor_com_cfs__ContainerType__c);
               }
               mapContainerNumberBySO.put(oldContainer.clofor_com_cfs__GOODSSO__c, containerTypeNumberMap);
               
           }                                                         
                                                                    
      }
        
    }
    
}