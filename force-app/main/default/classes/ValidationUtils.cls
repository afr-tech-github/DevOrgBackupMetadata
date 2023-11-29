public class ValidationUtils {
    public static final String AGGREGATE_MAX = 'MAX';
    public static final String AGGREGATE_MIN = 'MIN';
    
    public static boolean canExecuteTrigger() {
        Custom_Application_Config__c config = Custom_Application_Config__c.getOrgDefaults();
        Boolean disabledTrigger = config.Disabled_Trigger__c;
        
        return (disabledTrigger == null || disabledTrigger == false ? true : false);
    }
    
    public static String validateDeliveryDates(CustomObject1__c shipment, List<Cargo_Delivery__c> cds, List<Custom_Clearance__c> ccs) {
        String errorMessage = '';
        Date maxPickupDate = null;
        Date maxDeliveryDate = null;
        Date minPickupDate = null;
        Date minDeliveryDate = null;
        Date maxCustomClearanceDate = null;
        Date minCustomClearanceDate = null;
        List<Date> vDates = new List<Date>();
        boolean isImport = ObjectClassificationUtils.isImportHBL(shipment);
        boolean isExport = ObjectClassificationUtils.isExportHBL(shipment);

        if (cds != null && !cds.isEmpty()) {
            maxPickupDate = getAggregateDateForCargo(cds, Constants.NAMESPACE + 'Pickupdate__c', AGGREGATE_MAX);
            maxDeliveryDate = getAggregateDateForCargo(cds, Constants.NAMESPACE + 'DeliveryDate__c', AGGREGATE_MAX);
            minPickupDate = getAggregateDateForCargo(cds, Constants.NAMESPACE + 'Pickupdate__c', AGGREGATE_MIN);
            minDeliveryDate = getAggregateDateForCargo(cds, Constants.NAMESPACE + 'DeliveryDate__c', AGGREGATE_MIN);
        }            
       
        if (ccs != null && !ccs.isEmpty()) {
            maxCustomClearanceDate = getAggregateDateForCustomClearance(ccs, AGGREGATE_MAX);
            minCustomClearanceDate = getAggregateDateForCustomClearance(ccs, AGGREGATE_MIN);
        }
      
        if (isImport) {
            if (shipment.ETD__c != null) vDates.add(shipment.ETD__c);
            if (shipment.T_ETD__c != null) vDates.add(shipment.T_ETD__c);
            if (shipment.ETA__c != null) vDates.add(shipment.ETA__c);
            if (minCustomClearanceDate != null) vDates.add(minCustomClearanceDate);
            if (minPickupDate != null) vDates.add(minPickupDate);
            if (minDeliveryDate != null) vDates.add(minDeliveryDate);
        } else if (isExport) {
            if (maxPickupDate != null) vDates.add(maxPickupDate);
            if (maxDeliveryDate != null) vDates.add(maxDeliveryDate);
            if (minCustomClearanceDate != null) vDates.add(minCustomClearanceDate);
            if (shipment.CutDay__c != null) vDates.add(shipment.CutDay__c);
            if (shipment.ETD__c != null) vDates.add(shipment.ETD__c);
            if (shipment.T_ETD__c != null) vDates.add(shipment.T_ETD__c);
            if (shipment.ETA__c != null) vDates.add(shipment.ETA__c);
        }
        
        if (!vDates.isEmpty()) {
            Integer size = vDates.size();

            for (Integer i=0; i<(size-1); i++) {
                if (vDates.get(i) > vDates.get(i+1)) {
                    if (isExport) {
                        // errorMessage = Constants.INVALID_EXPORT_PROCESS_TIME_ORDER;    
                    } else if (isImport) {
                        // errorMessage = Constants.INVALID_IMPORT_PROCESS_TIME_ORDER;    
                    }
                    break;
                }
            }
        }

        return errorMessage;
    }

    public static Date getAggregateDateForCargo(List<Cargo_Delivery__c> cds, String aggFieldName, String aggType) {
        Date aggDate = null;
        
        if (!cds.isEmpty()) {
            for (Cargo_Delivery__c cd : cds) {
                Date aggFieldValue = (Date) cd.get(aggFieldName);
                
                if (aggDate == null 
                        || (aggFieldValue != null && AGGREGATE_MAX.equals(aggType) && aggFieldValue > aggDate) 
                        || (aggFieldValue != null && AGGREGATE_MIN.equals(aggType) && aggFieldValue < aggDate)) {
                    aggDate = aggFieldValue;
                }
            }
        }
        
        return aggDate;
    } 

  
    public static Date getAggregateDateForCustomClearance(List<Custom_Clearance__c> ccs, String aggType) {
        Date aggDate = null;
        
        if (!ccs.isEmpty()) {
            for (Custom_Clearance__c cc : ccs) {
                if (aggDate == null 
                        || (cc.Customs_Release_Day__c != null && AGGREGATE_MAX.equals(aggType) && cc.Customs_Release_Day__c > aggDate) 
                        || (cc.Customs_Release_Day__c != null && AGGREGATE_MIN.equals(aggType) && cc.Customs_Release_Day__c < aggDate)) {
                    aggDate = cc.Customs_Release_Day__c;
                }
            }
        }
        return aggDate;
    }
  
    
}