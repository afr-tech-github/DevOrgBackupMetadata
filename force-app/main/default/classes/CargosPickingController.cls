public with sharing class CargosPickingController {
    /*@AuraEnabled(cacheable=true)
    public static List<Cargo__c> findCargos(String searchKey) {
        return [SELECT Id, Name, Product__r.Name, InboundDate__c, ExpiredDate__c
                     FROM Cargo__c 
                     WHERE Product__c = :searchKey 
                     AND LastWOSRecordType__c = 'Putaway' Limit 1000];
    }
*/
    @AuraEnabled
    public static ResultWrapper pickCargos(String workOrderProductId, List<String> cargoIdList, String sortedBy, String sortedDirection){
        ResultWrapper result = new ResultWrapper();
        List<ConnectWOProduct__c> wops = [SELECT Id, ProductID__c, Quantity__c,WorkOrderID__c, ProductID__r.InventoryType__c FROM ConnectWOProduct__c WHERE Id =: workOrderProductId];
        // create w/o/s picking
        if(!cargoIdList.isEmpty()){
            
            //check if there are more than 1 warehouse is selected
            List<String> lastLocatorList = new List<String>();
            List<Cargo__c> cargoLastLocator = [SELECT LastWosLineItem__r.Locator__c, LastLocator__c FROM Cargo__c
                                               WHERE ID in: cargoIdList];
            for (Cargo__c caLaLo : cargoLastLocator ){
                lastLocatorList.add(caLaLo.LastWosLineItem__r.Locator__c);
            }
            List<LOCATOR__c> warehouseIdList = [SELECT warehouseId__c FROM LOCATOR__c 
                                               WHERE ID in: lastLocatorList];
            //Set<LOCATOR__c> warehouseId = new Set<LOCATOR__c>();
            //warehouseId.addAll(warehouseIdList);
            
            Set<Id> warehouseIds = new Set<Id>();
            for (LOCATOR__c lastloc : warehouseIdList){
                warehouseIds.add(lastloc.WarehouseId__c);
            }
            if (warehouseIds.size()>1){
                result.error= 'Please pick the cargo in the same warehouse';
                return result;
            }
                

            
            // picking work order service
            List<WorkOrderService__c> woslist = [SELECT Id FROM WorkOrderService__c 
                                                        WHERE WorkOrder__c =: wops[0].WorkOrderID__c
                                                        AND RecordType.DeveloperName = 'Picking'];
            if(woslist.isEmpty()){
                result.error= 'Please create W/O/S Picking before picking cargos';
                 return result;
            }
            
            try{
                List<WOSLineItem__c> newWOSLList = new List<WOSLineItem__c>();
                List<Cargo__c> cargoNeedToUpdate = new List<Cargo__c>();
                for(String cargoId : cargoIdList){
                    WOSLineItem__c newWOSL = new WOSLineItem__c(
                        WorkOrderService__c = woslist[0].Id,
                        Cargo__c = cargoId
                        
                    );
                    newWOSLList.add(newWOSL);
                    
                }
                FlsService.doInsert(newWOSLList);
                for(WOSLineItem__c line : newWOSLList){
                    cargoNeedToUpdate.add(new Cargo__c(Id = line.Cargo__c, CargoLifeCycle__c = 'Picking Planned'));
                }
                FlsService.doUpdate(cargoNeedToUpdate);
                result = getData(workOrderProductId, sortedBy, sortedDirection);
            }catch(Exception ex){
                result.error= 'No cargo is picked' + ex.getMessage();
            }
        }
        return result;  
    }
    @AuraEnabled(cacheable=true)
    public static ResultWrapper getData(String workOrderProductId, String sortedBy, String sortedDirection) {
        ResultWrapper result = new ResultWrapper();
        List<ConnectWOProduct__c> wops = [SELECT Id, ProductID__c, Quantity__c,WorkOrderID__c, ProductID__r.InventoryType__c FROM ConnectWOProduct__c WHERE Id =: workOrderProductId];
        
        if(!wops.isEmpty()){
            List<WOSLineItem__c> woslPikings = [SELECT Id, Cargo__r.Quantity__c, Cargo__c 
                                                FROM WOSLineItem__c 
                                                WHERE WorkOrderService__r.WorkOrder__c =: wops[0].WorkOrderID__c
                                                AND WorkOrderService__r.RecordType.DeveloperName = 'Picking'
                                                AND Cargo__r.Product__c =: wops[0].ProductID__c];
            Decimal pickedNumber = 0;
            List<String> cargoIds = new List<String>();
            for(WOSLineItem__c wosl : woslPikings){
                cargoIds.add(wosl.Cargo__c);
                if(wosl.Cargo__r.Quantity__c < 1 || wosl.Cargo__r.Quantity__c == null){
                    pickedNumber += 1;
                }else{
                    pickedNumber += wosl.Cargo__r.Quantity__c;
                }
            }
            if(wops[0].Quantity__c == null || wops[0].Quantity__c == 0){
                result.requiredQuantity = 0;
            }else{
                result.requiredQuantity = wops[0].Quantity__c - pickedNumber;
                if(result.requiredQuantity < 0){
                    result.requiredQuantity = 0;
                }
            }
            result.wop = wops[0];
            String orderBy = '';
            if(String.isBlank(sortedBy) || String.isBlank(sortedDirection)){
                orderBy = ' ORDER BY Name asc';
                sortedBy = 'Name';
                sortedDirection = 'ASC';

                if (wops[0].ProductID__r.InventoryType__c == 'FIFO(First In First Out)') {
                    orderBy = ' ORDER BY InboundDate__c ASC';
                    sortedBy = 'InboundDate__c';
                    sortedDirection = 'ASC';
                }else if (wops[0].ProductID__r.InventoryType__c == 'LIFO(Last In First Out)') {
                    orderBy = ' ORDER BY InboundDate__c DESC';
                    sortedBy = 'InboundDate__c';
                    sortedDirection = 'DESC';
                }
                if (wops[0].ProductID__r.InventoryType__c == 'FEFO( First Expiry First Out )') {
                    orderBy = ' ORDER BY ExpiredDate__c ASC';
                    sortedBy = 'ExpiredDate__c';
                    sortedDirection = 'ASC';
                }
            }else {
                orderBy = ' ORDER BY ' + sortedBy + ' ' + sortedDirection + ' ';
            }
            result.sortedBy = sortedBy;
            result.sortedDirection = sortedDirection;
            String query = 'SELECT Id, Name, Product__r.Name, InboundDate__c, ExpiredDate__c,'
                        + 'AcceptedQuantityInUnit__c, AgingDaysTillExpire__c, CargoLifeCycle__c,'
                        + 'CargoType__c, ExpireDateSKUNumber__c, InventoryType__c, ItemNumber__c,LastWosLineItem__r.Name,'
                        + 'LastLocatorCode__c, LastLocator__c, LastWORecordType__c, LastWOSRecordType__c,'
                        + 'LastWOS__c, LastWosLineItem__c, LotNumber__c, LotQuantity__c, ManufacturedDate__c, '
                        + 'MissingQuantityinUnit__c, PartNumber__c,PlannedWeight__c, PlannedWeightCal__c, Product__c,'
                        + 'ProductDetails__c, ProductSKUNumber__c, QrCodeImage__c, Quantity__c,QuantityInUnit__c, QuantityPerUnit__c,'
                        + 'QuantityVarianceinUnit__c,clofor_com_cfs__Summary__c '
                     + ' FROM Cargo__c'
                     + ' WHERE Product__c =\'' +  StringUtils.escapeSingleQuotes(wops[0].ProductID__c) + '\''
                     + ' AND LastWOSRecordType__c = \'Putaway\'' 
                     + ' AND CargoLifeCycle__c = \'For sales\''
                     + 'AND Id NOT IN : cargoIds';
            query += orderBy + ' Limit 1000';
            result.cargos = Database.query(query);
        }
        return result;
    }

    public class ResultWrapper{
        @AuraEnabled
        public String error{get;set;}
        @AuraEnabled
        public String sortedBy{get;set;}
        @AuraEnabled
        public String sortedDirection{get;set;}
        @AuraEnabled
        public ConnectWOProduct__c wop{get;set;}
        @AuraEnabled
        public Decimal requiredQuantity{get;set;}
        // @AuraEnabled
        // public Product__c product{get; set;}
        @AuraEnabled
        public List<Cargo__c> cargos{get; set;}
        public ResultWrapper(){
            wop = new ConnectWOProduct__c();
            //product = new Product__c();
            cargos = new List<Cargo__c>();
            requiredQuantity = 0;
        }


    }
}