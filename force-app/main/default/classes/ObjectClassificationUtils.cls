public with sharing class ObjectClassificationUtils {
    public static boolean isDomesticCustomerOrPartner(String customerType) {
        return (!StringUtils.isEmpty(customerType) && customerType.contains(Constants.CL_DOMESTIC));
    }
    
    public static boolean isOverseaCustomerOrPartner(String customerType) {
        return (!StringUtils.isEmpty(customerType) && customerType.contains(Constants.CL_OVERSEA));
    }
    
    public static boolean isImportMBL(String masterRecordType) {
        return (!StringUtils.isEmpty(masterRecordType) && masterRecordType.containsIgnoreCase(Constants.CL_MRT_IMPORT));
    }
    
    public static boolean isExportMBL(String masterRecordType) {
        return (!StringUtils.isEmpty(masterRecordType) && masterRecordType.containsIgnoreCase(Constants.CL_MRT_EXPORT));
    }
    
    public static Boolean isImportHBL(CustomObject1__c shipment) {
        String recordType = RecordTypeUtil.getRecordTypeDeveloperNameById(CustomObject1__c.SObjectType, shipment.RecordTypeId);
                                                                          
        if (Constants.AIR_IMPORT_RT.equalsIgnoreCase(recordType) || Constants.OCEAN_IMPORT_RT.equalsIgnoreCase(recordType) || Constants.AIR_IMPORT_LOCK_RT.equalsIgnoreCase(recordType) || Constants.OCEAN_IMPORT_LOCK_RT.equalsIgnoreCase(recordType)) {
            return true;
        }
        
        return false;
    }

    public static Boolean isImportHBL(Id recordTypeId) {
        String recordType = RecordTypeUtil.getRecordTypeDeveloperNameById(CustomObject1__c.SObjectType, recordTypeId);

        if (Constants.AIR_IMPORT_RT.equalsIgnoreCase(recordType) || Constants.OCEAN_IMPORT_RT.equalsIgnoreCase(recordType) || Constants.AIR_IMPORT_LOCK_RT.equalsIgnoreCase(recordType) || Constants.OCEAN_IMPORT_LOCK_RT.equalsIgnoreCase(recordType)) {
            return true;
        }

        return false;
    }
    
    public static Boolean isExportHBL(CustomObject1__c shipment) {
        String recordType = RecordTypeUtil.getRecordTypeDeveloperNameById(CustomObject1__c.SObjectType, shipment.RecordTypeId);
        
        if (Constants.AIR_EXPORT_RT.equalsIgnoreCase(recordType) || Constants.OCEAN_EXPORT_RT.equalsIgnoreCase(recordType)|| Constants.AIR_EXPORT_LOCK_RT.equalsIgnoreCase(recordType) || Constants.OCEAN_EXPORT_LOCK_RT.equalsIgnoreCase(recordType)) {
            return true;
        }
        
        return false;
    }

    public static Boolean isExportHBL(Id recordTypeId) {
        String recordType = RecordTypeUtil.getRecordTypeDeveloperNameById(CustomObject1__c.SObjectType, recordTypeId);

        if (Constants.AIR_EXPORT_RT.equalsIgnoreCase(recordType) || Constants.OCEAN_EXPORT_RT.equalsIgnoreCase(recordType)|| Constants.AIR_EXPORT_LOCK_RT.equalsIgnoreCase(recordType) || Constants.OCEAN_EXPORT_LOCK_RT.equalsIgnoreCase(recordType)) {
            return true;
        }

        return false;
    }

    public static Boolean isDomesticTransportation(CustomObject1__c shipment) {
        String recordType = RecordTypeUtil.getRecordTypeDeveloperNameById(CustomObject1__c.SObjectType, shipment.RecordTypeId);

        if (Constants.DOMESTIC_TRANSPORTATION_RT.equalsIgnoreCase(recordType) || Constants.DOMESTIC_TRANSPORTATION_LOCK_RT.equalsIgnoreCase(recordType)) {
            return true;
        }

        return false;
    }

    public static Boolean isCrossBoarder(CustomObject1__c shipment) {
        String recordType = RecordTypeUtil.getRecordTypeDeveloperNameById(CustomObject1__c.SObjectType, shipment.RecordTypeId);

        if (Constants.CROSS_BOARDER_RT.equalsIgnoreCase(recordType) || Constants.CROSS_BOARDER_LOCK_RT.equalsIgnoreCase(recordType)) {
            return true;
        }

        return false;
    }
    
    public static Boolean isQuotationHBL(CustomObject1__c shipment) {
        if(shipment == null){
            return false;
        }
        String recordType = RecordTypeUtil.getRecordTypeDeveloperNameById(CustomObject1__c.SObjectType, shipment.RecordTypeId);

        if (Constants.QUOTATION_RT.equalsIgnoreCase(recordType)) {
            return true;
        }
        
        return false;
    }
    
    public static Boolean isAirHBL(CustomObject1__c shipment) {
        String recordType = RecordTypeUtil.getRecordTypeDeveloperNameById(CustomObject1__c.SObjectType, shipment.RecordTypeId);
        
        if (Constants.AIR_EXPORT_RT.equals(recordType) || Constants.AIR_EXPORT_LOCK_RT.equals(recordType) || Constants.AIR_IMPORT_RT.equals(recordType) || Constants.AIR_IMPORT_LOCK_RT.equals(recordType)) {
            return true;                    
        }
        
        return false;
    }
    
    public static Boolean isLockedHBL(CustomObject1__c shipment) {
        //String recordType = RecordTypeUtil.getRecordTypeDeveloperNameById(CustomObject1__c.SObjectType, shipment.RecordTypeId);
        
        // if (Constants.OCEAN_IMPORT_LOCK_RT_ID.equals(recordType) || Constants.AIR_EXPORT_LOCK_RT_ID.equals(recordType) 
        //         || Constants.OCEAN_EXPORT_LOCK_RT_ID.equals(recordType) || Constants.AIR_IMPORT_LOCK_RT_ID.equals(recordType)
        //         || Constants.DOMESTIC_TRANSPORTATION_LOCK_RT_ID.equals(recordType)) {
        //     return true;                    
        // }

        // return false;
        return new Set<Id> { 
            Constants.OCEAN_IMPORT_LOCK_RT_ID, 
            Constants.AIR_EXPORT_LOCK_RT_ID, 
            Constants.OCEAN_EXPORT_LOCK_RT_ID, 
            Constants.AIR_IMPORT_LOCK_RT_ID, 
            Constants.DOMESTIC_TRANSPORTATION_LOCK_RT_ID
        }.contains(shipment.RecordTypeId);
    }
    
    public static Boolean isOceanHBL(CustomObject1__c shipment) {
        String recordType = RecordTypeUtil.getRecordTypeDeveloperNameById(CustomObject1__c.SObjectType, shipment.RecordTypeId);
        
        if (Constants.OCEAN_IMPORT_RT.equals(recordType) || Constants.OCEAN_IMPORT_LOCK_RT.equals(recordType) || Constants.OCEAN_EXPORT_RT.equals(recordType) || Constants.OCEAN_EXPORT_LOCK_RT.equals(recordType)) {
            return true;                    
        }
        
        return false;
    }
    
    public static Boolean isImportCargoDelivery(String recordTypeId) {
        String recordType = RecordTypeUtil.getRecordTypeDeveloperNameById(Cargo_Delivery__c.SObjectType, recordTypeId);
        
        return (!StringUtils.isEmpty(recordType) && recordType.contains('Import'));
    }
    
    public static Boolean isExportCargoDelivery(String recordTypeId) {
        String recordType = RecordTypeUtil.getRecordTypeDeveloperNameById(Cargo_Delivery__c.SObjectType, recordTypeId);
        
        return (!StringUtils.isEmpty(recordType) && recordType.contains('Export'));
    }
    
    public static boolean isPartner(String customerType) {
        return (!StringUtils.isEmpty(customerType) && customerType.contains(Constants.CL_PARTNER_TYPE));
    }

    public static String getObjectTypeId(final String objectType) {
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType sObjectType = schemaMap.get(objectType);
        String objectTypeId = sObjectType.getDescribe().getKeyPrefix();

        return objectTypeId;
    }
}