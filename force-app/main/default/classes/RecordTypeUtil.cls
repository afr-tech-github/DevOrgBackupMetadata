public with sharing class RecordTypeUtil {
    private static Map<Schema.SObjectType, RecordTypeWrapper> recordTypeMappings = new Map<Schema.SObjectType, RecordTypeWrapper>();
    
    public static String getRecordTypeIdByDeveloperName(Schema.SObjectType objectType, String developerName) {
        RecordTypeWrapper mappings = getRecordTypesByObjectType(objectType);
        RecordType recordType = mappings.recordTypes.get(developerName);
        
        if (recordType != null) {
            return recordType.Id;
        }
        
        return null;
    }
    
    public static String getRecordTypeDeveloperNameById(Schema.SObjectType objectType, String recordTypeId) {
        RecordTypeWrapper mappings = getRecordTypesByObjectType(objectType);
        RecordType recordType = mappings.recordTypes.get(recordTypeId);
        
        if (recordType != null) {
            return recordType.DeveloperName;
        }
        
        return null;
    }
    
    public static String getRecordTypeName(Schema.SObjectType objectType, String idOrDeveloperName) {
        RecordTypeWrapper mappings = getRecordTypesByObjectType(objectType);
        RecordType recordType = mappings.recordTypes.get(idOrDeveloperName);
        
        if (recordType != null) {
            return recordType.Name;
        }
        
        return null;
    }
    
    private static RecordTypeWrapper getRecordTypesByObjectType(Schema.SObjectType objectType) {
        RecordTypeWrapper mappings = null;
        
        if (recordTypeMappings.containsKey(objectType)) {
            mappings = recordTypeMappings.get(objectType);
        } else {
            mappings = loadRecordTypeMapping(objectType);
            recordTypeMappings.put(objectType, mappings);
        }
        
        return mappings;
    }
    
    private static RecordTypeWrapper loadRecordTypeMapping(Schema.SObjectType objectType) {
        Schema.DescribeSObjectResult obj = objectType.getDescribe();
        String soql = 'SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = \'' 
            + String.escapeSingleQuotes(obj.getName()) + '\' AND IsActive = TRUE';
        
        List<SObject> results;
        try {
            results = Database.query(soql);
        } catch (Exception ex) {
            results = new List<SObject>();
        }
        
        Map<Id,Schema.RecordTypeInfo> recordTypeInfos = obj.getRecordTypeInfosByID();
        RecordTypeWrapper wrapper = new RecordTypeWrapper(objectType);
        
        for (SObject rt : results) {  
            if (recordTypeInfos.get(rt.Id).isAvailable()) {
                wrapper.addRecordType(rt.Id, (RecordType) rt);
                wrapper.addRecordType(String.valueOf(rt.get('DeveloperName')), (RecordType) rt);
            }
        }
        
        return wrapper;
    }
    
    class RecordTypeWrapper {
        private Schema.SObjectType objectType;
        private Map<String, RecordType> recordTypes {get; private set;}
        
        public RecordTypeWrapper(Schema.SObjectType objectType) {
            this.objectType = objectType;
            recordTypes = new Map<String, RecordType>();
        }
        
        public void addRecordType(String key, RecordType recordType) {
            if (!StringUtils.isEmpty(key) && recordType != null) {
                recordTypes.put(key, recordType);
            }
        }
    }
}