public class WOServiceInputController {

    @AuraEnabled
    public static String loadWOService(String recId){
        String output = '';
        //WorkOrder__c wo = [select id, name, recordType.Name from WorkOrder__c where id = :recId];
        list<WorkOrderService__c> lstService = getListWorkOrderService(recId);
        for(WorkOrderService__c wos : lstService){
            output = ','+wos.id;
        }
        output = output.replaceFirst(',', '');
        //output = wo.recordType.name +'_'+output;
        return output;
    }

    @AuraEnabled
    public static String createCargo(String jsonStr, String recId){
        
        
        List<CargoWrapper> listCargoWrp = new List<CargoWrapper>();
       	listCargoWrp = (List<CargoWrapper>)JSON.deserialize(jsonStr, List<CargoWrapper>.class);
        List<Cargo__c> listCargo = CargoWrpToCargo(listCargoWrp);
        try{
            FlsService.doUpsert(listCargo);

            //Matching Service to Cargo
            List<WOSLineItem__c> lstWOSLineItem = new List<WOSLineItem__c>();
            integer cargoIdx = 0;
            for(integer j = 0; j < listCargoWrp.size(); j++){
                CargoWrapper cw = listCargoWrp[j];
                for(integer i = 0; i < cw.quantity; i++){
                    WOSLineItem__c WOSli = new WOSLineItem__c();
                    WOSli.WorkOrderService__c = cw.serviceIds;
                    WOSli.Cargo__c = listCargo[cargoIdx].id;
                    WOSli.CargoStatus__c = 'Planned';
                    lstWOSLineItem.add(WOSli);
                    cargoIdx++;
                }            
            }

            FlsService.doInsert(lstWOSLineItem);
        } catch(exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
        return 'success';
        //return JSON.serialize(listCargoOutput);
    }

    public static List<Cargo__c> CargoWrpToCargo(List<CargoWrapper> listCargoWrp){
        List<Cargo__c> listCargo = new List<Cargo__c>();
        for(integer j = 0; j < listCargoWrp.size(); j++){
            CargoWrapper cw = listCargoWrp[j];
            for(integer i = 0; i < cw.quantity; i++){
                Cargo__c c = new Cargo__c();
            	c.Product__c = cw.productId;
                listCargo.add(c);
            }            
        }
        return listCargo;
    }
    
    public static list<WorkOrderService__c> getListWorkOrderService(String recId){
        return [Select id, name, Status__c from WorkOrderService__c where WorkOrder__c = :recId];
    }
    
    public class CargoWrapper{
        public String cargoId{get;set;}
        public String productId{get;set;}
        public integer quantity{get;set;}
        public String serviceIds{get;set;}
    }

    public class ServiceWrapper{
        public String serviceIds{get;set;}
    }
}