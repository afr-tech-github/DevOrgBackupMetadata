public class PermissionValidationUtil {
    public enum FLSPermission {P_READ, P_CREATE, P_EDIT, P_DELETE}
    
    public class ValidationResult {
        public List<String> errors {get; private set;}
        
        public ValidationResult() {
            errors = new List<String>();
        }
        
        public boolean isSuccess() {
            return errors.isEmpty();
        }
        
        public void addError(String errorMessage) {
            errors.add(errorMessage);
        }
    }
    
    /**
     * This function is used to validate if the current user has the permission to interact on requested object.
     * 
     * @objectName - The API Name of the requested object
     * @permission - The requested permission (READ/CREATE/EDIT/DELETE)
     * 
     * @return - The validation result. If there is any violation, the error will be added and isSuccess = False.
     * If there is any system error such as the requested object does not exist, add error to validation result.
     */ 
    public static ValidationResult validateCRUD(String objectName, FLSPermission permission) {
        ValidationResult validationResult = new ValidationResult();
        objectName = appendNamespace(objectName);
        
        try {
            Map<String, Schema.SObjectType> globalDescription = Schema.getGlobalDescribe();
            Schema.SObjectType objectType = globalDescription.get(objectName);
            Schema.DescribeSObjectResult result = objectType.getDescribe();
            
            if (FLSPermission.P_READ == permission && !result.isAccessible()) {
                validationResult.addError('Not allowed to read object: ' + objectName);
            } else if (FLSPermission.P_CREATE == permission && !result.isCreateable()) {
                validationResult.addError('Not allowed to create object: ' + objectName);
            } else if (FLSPermission.P_EDIT == permission && !result.isUpdateable()) {
                validationResult.addError('Not allowed to edit object: ' + objectName);
            } else if (FLSPermission.P_DELETE == permission && !result.isDeletable()) {
                validationResult.addError('Not allowed to delete object: ' + objectName);
            }
        } catch (Exception e) {
            validationResult.addError('ERROR: Encountered error while validating permission. [' + e.getMessage() + ']');
        }
        
        return validationResult;
    }
    
    /**
     * This function is used to validate if the current user has the permission to interact on requested fields.
     * 
     * @objectName - The API Name of the requested object
     * @requestedFields - The list of fields need to interact with
     * @permission - The requested permission (READ/CREATE/EDIT/DELETE)
     * 
     * @return - The validation result. If there is any violation, the error will be added and isSuccess = false.
     * If there is any system error such as the requested object does not exist, add error to validation result.
     */ 
    public static ValidationResult validateFLS(String objectName, Set<String> requestedFields, FLSPermission permission) {
        ValidationResult validationResult = new ValidationResult();
        objectName = appendNamespace(objectName);

        try {
            Map<String, Schema.SObjectType> globalDescription = Schema.getGlobalDescribe();
            Schema.SObjectType objectType = globalDescription.get(objectName);
            Schema.DescribeSObjectResult result = objectType.getDescribe();
            Map<String, Schema.SObjectField> mapFields = result.fields.getMap();

            for (Schema.SObjectField field : mapFields.values()) {
                Schema.DescribeFieldResult fieldResult = field.getDescribe();
                
                if (requestedFields.isEmpty()) {
                    requestedFields = getCustomFieldsNames(objectName);
                }
                
                if (requestedFields.contains(fieldResult.getName())) {
                    if (FLSPermission.P_READ == permission && !fieldResult.isAccessible()) {
                        validationResult.addError('Not allowed to read field: ' + objectName + '.' +fieldResult.getName());    
                    } else if (FLSPermission.P_CREATE == permission && !fieldResult.isCreateable() 
                               && !fieldResult.isCalculated() && !fieldREsult.isAutoNumber()) {
                        validationResult.addError('Not allowed to create field: ' + objectName + '.' +fieldResult.getName()); 
                    } else if (FLSPermission.P_EDIT == permission && !fieldResult.isUpdateable() 
                               && !fieldResult.isCalculated() && !fieldREsult.isAutoNumber()) {
                        validationResult.addError('Not allowed to edit field: ' + objectName + '.' +fieldResult.getName()); 
                    }
                }
            }
        } catch (Exception e) {
            validationResult.addError('ERROR: Encountered error while validating permission. [' + e.getMessage() + ']');
        }
        
        return validationResult;
    }
    
    private static Set<String> getCustomFieldsNames(String objectName){
        objectName = appendNamespace(objectName);
        
        Map<String, Schema.SObjectType> globalDescription = Schema.getGlobalDescribe();
        Schema.SObjectType tp = globalDescription.get(objectName);
        Set<String> fieldNames = new Set<String>();
        Map<String,Schema.sObjectField> fmap = tp.getDescribe().fields.getMap();
        
        for(String fn : fmap.keySet()){
            if(fn.endswith('__c')){
                fieldNames.add(fn);
            }
        }
        return fieldNames;
    }
    
    private static String appendNamespace(String objectName) {
        if (!StringUtils.isEmpty(Constants.NAMESPACE) && !StringUtils.isEmpty(objectName)) {
            if (!objectName.contains(Constants.NAMESPACE)) {
                objectName = Constants.NAMESPACE + objectName;
            }
        }
        
        return objectName;
    }

    public static Boolean canReadHBL() {
        return PermissionValidationUtil.validateCRUD('', PermissionValidationUtil.FLSPermission.P_READ).isSuccess();
    }
    
    public static boolean isAccessibleHBL() {
        Set<String> fieldNames = PermissionValidationUtil.getCustomFieldsNames('CustomObject1__c');
        fieldNames.add('Id');
        fieldNames.add('Name');
        fieldNames.add('RecordTypeId');
        fieldNames.add('CreatedById');
        PermissionValidationUtil.ValidationResult validationResult = PermissionValidationUtil.validateFLS('CustomObject1__c', 
                                                                     fieldNames, PermissionValidationUtil.FLSPermission.P_READ);
        
        System.debug('validationResult: '+validationResult.errors);
        return validationResult.isSuccess();
    }
    
    public static List<String> isAccessibleHBLDebug() {
        Set<String> fieldNames = PermissionValidationUtil.getCustomFieldsNames('CustomObject1__c');
        fieldNames.add('Id');
        fieldNames.add('Name');
        fieldNames.add('RecordTypeId');
        fieldNames.add('CreatedById');
        PermissionValidationUtil.ValidationResult validationResult = PermissionValidationUtil.validateFLS('CustomObject1__c', 
                                                                     fieldNames, PermissionValidationUtil.FLSPermission.P_READ);
        
        return validationResult.errors;
    }
    
    public static boolean isEditableHBL() {
        Set<String> fieldNames = PermissionValidationUtil.getCustomFieldsNames('CustomObject1__c');
        fieldNames.add('Name');
        fieldNames.add('RecordTypeId');
        PermissionValidationUtil.ValidationResult validationResult = PermissionValidationUtil.validateFLS('CustomObject1__c', 
                                                                     fieldNames, PermissionValidationUtil.FLSPermission.P_EDIT);
        
        return validationResult.isSuccess();
    }
    
    public static boolean isCreatableHBL() {
        Set<String> fieldNames = PermissionValidationUtil.getCustomFieldsNames('CustomObject1__c');
        fieldNames.add('Name');
        fieldNames.add('RecordTypeId');
        PermissionValidationUtil.ValidationResult validationResult = PermissionValidationUtil.validateFLS('CustomObject1__c', 
                                                                     fieldNames, PermissionValidationUtil.FLSPermission.P_CREATE);
        
        return validationResult.isSuccess();
    }
    
    public static boolean isAccessibleHBLBuying() {
        Set<String> fieldNames = PermissionValidationUtil.getCustomFieldsNames('AnkenMeisai__c');
        fieldNames.add('Id');
        fieldNames.add('Name');
        fieldNames.add('RecordTypeId');
        PermissionValidationUtil.ValidationResult validationResult = PermissionValidationUtil.validateFLS('AnkenMeisai__c', 
                                                                     fieldNames, PermissionValidationUtil.FLSPermission.P_READ);
        
        return validationResult.isSuccess();
    }
    
    public static boolean isCreatableHBLBuying() {
        Set<String> fieldNames = PermissionValidationUtil.getCustomFieldsNames('AnkenMeisai__c');
        fieldNames.add('Name');
        fieldNames.add('RecordTypeId');
        PermissionValidationUtil.ValidationResult validationResult = PermissionValidationUtil.validateFLS('AnkenMeisai__c', 
                                                                     fieldNames, PermissionValidationUtil.FLSPermission.P_CREATE);
        
        return validationResult.isSuccess();
    }
    
    public static boolean isEditableHBLBuying() {
        Set<String> fieldNames = PermissionValidationUtil.getCustomFieldsNames('AnkenMeisai__c');
        fieldNames.add('Name');
        fieldNames.add('RecordTypeId');
        PermissionValidationUtil.ValidationResult validationResult = PermissionValidationUtil.validateFLS('AnkenMeisai__c', 
                                                                     fieldNames, PermissionValidationUtil.FLSPermission.P_EDIT);
        
        return validationResult.isSuccess();
    }
    
    public static boolean isAccessibleMBLBuying() {
        Set<String> fieldNames = PermissionValidationUtil.getCustomFieldsNames('MasterAnkenMeisai__c');
        fieldNames.add('Id');
        fieldNames.add('Name');
        PermissionValidationUtil.ValidationResult validationResult = PermissionValidationUtil.validateFLS('MasterAnkenMeisai__c', 
                                                                     fieldNames, PermissionValidationUtil.FLSPermission.P_READ);
        
        return validationResult.isSuccess();
    }
    
    public static boolean isCreatableMBLBuying() {
        Set<String> fieldNames = PermissionValidationUtil.getCustomFieldsNames('MasterAnkenMeisai__c');
        fieldNames.add('Name');
        PermissionValidationUtil.ValidationResult validationResult = PermissionValidationUtil.validateFLS('MasterAnkenMeisai__c', 
                                                                     fieldNames, PermissionValidationUtil.FLSPermission.P_CREATE);
        
        return validationResult.isSuccess();
    }
    
    public static boolean isEditableMBLBuying() {
        Set<String> fieldNames = PermissionValidationUtil.getCustomFieldsNames('MasterAnkenMeisai__c');
        fieldNames.add('Name');
        PermissionValidationUtil.ValidationResult validationResult = PermissionValidationUtil.validateFLS('MasterAnkenMeisai__c', 
                                                                     fieldNames, PermissionValidationUtil.FLSPermission.P_EDIT);
        
        return validationResult.isSuccess();
    }
    
    public static boolean isAccessibleMBL() {
        Set<String> fieldNames = PermissionValidationUtil.getCustomFieldsNames('MasterAnken__c');
        fieldNames.add('Id');
        fieldNames.add('Name');
        fieldNames.add('CreatedById');
        PermissionValidationUtil.ValidationResult validationResult = PermissionValidationUtil.validateFLS('MasterAnken__c', 
                                                                     fieldNames, PermissionValidationUtil.FLSPermission.P_READ);
        
        return validationResult.isSuccess();
    }
    
    public static boolean isCreatableMBL() {
        Set<String> fieldNames = PermissionValidationUtil.getCustomFieldsNames('MasterAnken__c');
        fieldNames.add('Name');
        PermissionValidationUtil.ValidationResult validationResult = PermissionValidationUtil.validateFLS('MasterAnken__c', 
                                                                     fieldNames, PermissionValidationUtil.FLSPermission.P_CREATE);
        
        return validationResult.isSuccess();
    }
    
    public static boolean isEditableMBL() {
        Set<String> fieldNames = PermissionValidationUtil.getCustomFieldsNames('MasterAnken__c');
        fieldNames.add('Name');
        PermissionValidationUtil.ValidationResult validationResult = PermissionValidationUtil.validateFLS('MasterAnken__c', 
                                                                     fieldNames, PermissionValidationUtil.FLSPermission.P_EDIT);
        
        return validationResult.isSuccess();
    }
    
    public static boolean isCreatableAttachment() {
        Set<String> fieldNames = PermissionValidationUtil.getCustomFieldsNames('Attachment');
        fieldNames.add('Name');
        fieldNames.add('Body');
        fieldNames.add('ParentId');
        PermissionValidationUtil.ValidationResult validationResult = PermissionValidationUtil.validateFLS('Attachment', 
                                                                     fieldNames, PermissionValidationUtil.FLSPermission.P_CREATE);
        
        return validationResult.isSuccess();
    }
    
    public static boolean isDeletableContainerInfo() {
        PermissionValidationUtil.ValidationResult validationResult = PermissionValidationUtil.validateCRUD('Container_Info__c', 
                                                                     PermissionValidationUtil.FLSPermission.P_DELETE);
        
        return validationResult.isSuccess();
    }
    
	public static boolean isAccessibleUser() {
        Set<String> fieldNames = PermissionValidationUtil.getCustomFieldsNames('User');
        fieldNames.add('Id');
        fieldNames.add('Name');
        fieldNames.add('Email');
        fieldNames.add('Username');
        PermissionValidationUtil.ValidationResult validationResult = PermissionValidationUtil.validateFLS('User', 
                                                                     fieldNames, PermissionValidationUtil.FLSPermission.P_READ);
        
        return validationResult.isSuccess();
    }

    public static boolean isAccessibleAccount() {
        Set<String> fieldNames = PermissionValidationUtil.getCustomFieldsNames('Account');
        fieldNames.add('Id');
        fieldNames.add('Name');
        PermissionValidationUtil.ValidationResult validationResult = PermissionValidationUtil.validateFLS('Account', 
                                                                     fieldNames, PermissionValidationUtil.FLSPermission.P_READ);
        
        return validationResult.isSuccess();
    }
    
    public static boolean isAccessibleContact() {
        Set<String> fieldNames = PermissionValidationUtil.getCustomFieldsNames('Contact');
        fieldNames.add('Id');
        fieldNames.add('Name');
        PermissionValidationUtil.ValidationResult validationResult = PermissionValidationUtil.validateFLS('Contact', 
                                                                     fieldNames, PermissionValidationUtil.FLSPermission.P_READ);
        
        return validationResult.isSuccess();
    }
    
    public static boolean isAccessibleServiceMaster() {
        Set<String> fieldNames = PermissionValidationUtil.getCustomFieldsNames('TariffMaster__c');
        fieldNames.add('Id');
        fieldNames.add('Name');
        PermissionValidationUtil.ValidationResult validationResult = PermissionValidationUtil.validateFLS('TariffMaster__c', 
                                                                     fieldNames, PermissionValidationUtil.FLSPermission.P_READ);
        
        return validationResult.isSuccess();
    }
    
    public static boolean isAccessiblePort() {
        Set<String> fieldNames = PermissionValidationUtil.getCustomFieldsNames('Port__c');
        fieldNames.add('Id');
        fieldNames.add('Name');
        PermissionValidationUtil.ValidationResult validationResult = PermissionValidationUtil.validateFLS('Port__c', 
                                                                     fieldNames, PermissionValidationUtil.FLSPermission.P_READ);
        
        return validationResult.isSuccess();
    }
    
    public static boolean isAccessibleWarehouse() {
        Set<String> fieldNames = PermissionValidationUtil.getCustomFieldsNames('LoadLocation__c');
        fieldNames.add('Id');
        fieldNames.add('Name');
        PermissionValidationUtil.ValidationResult validationResult = PermissionValidationUtil.validateFLS('LoadLocation__c', 
                                                                     fieldNames, PermissionValidationUtil.FLSPermission.P_READ);
        
        return validationResult.isSuccess();
    }
    
    public static boolean isAccessibleTaxRatio() {
        Set<String> fieldNames = PermissionValidationUtil.getCustomFieldsNames('Tax_Ratio__c');
        fieldNames.add('Id');
        fieldNames.add('Name');
        PermissionValidationUtil.ValidationResult validationResult = PermissionValidationUtil.validateFLS('Tax_Ratio__c', 
                                                                     fieldNames, PermissionValidationUtil.FLSPermission.P_READ);
        
        return validationResult.isSuccess();
    }
    
    public static boolean isAccessibleExchangeRate() {
        Set<String> fieldNames = PermissionValidationUtil.getCustomFieldsNames('MgmtMaster__c');
        fieldNames.add('Id');
        fieldNames.add('Name');
        PermissionValidationUtil.ValidationResult validationResult = PermissionValidationUtil.validateFLS('MgmtMaster__c', 
                                                                     fieldNames, PermissionValidationUtil.FLSPermission.P_READ);
        
        return validationResult.isSuccess();
    }

    public static boolean isEditableExchangeRate() {
        Set<String> fieldNames = PermissionValidationUtil.getCustomFieldsNames('MgmtMaster__c');
        fieldNames.add('Name');
        PermissionValidationUtil.ValidationResult validationResult = PermissionValidationUtil.validateFLS('MgmtMaster__c',
                fieldNames, PermissionValidationUtil.FLSPermission.P_EDIT);

        return validationResult.isSuccess();
    }
    
    public static boolean isAccessibleVATInvoice() {
        Set<String> fieldNames = PermissionValidationUtil.getCustomFieldsNames('VAT_INVOICE__c');
        fieldNames.add('Id');
        fieldNames.add('Name');
        PermissionValidationUtil.ValidationResult validationResult = PermissionValidationUtil.validateFLS('VAT_INVOICE__c', 
                                                                     fieldNames, PermissionValidationUtil.FLSPermission.P_READ);
        
        return validationResult.isSuccess();
    }
    
    public static boolean isCreatableVATInvoice() {
        Set<String> fieldNames = PermissionValidationUtil.getCustomFieldsNames('VAT_INVOICE__c');
        fieldNames.add('Name');
        PermissionValidationUtil.ValidationResult validationResult = PermissionValidationUtil.validateFLS('VAT_INVOICE__c', 
                                                                     fieldNames, PermissionValidationUtil.FLSPermission.P_CREATE);
        
        return validationResult.isSuccess();
    }
    
    public static boolean isEditableVATInvoice() {
        Set<String> fieldNames = PermissionValidationUtil.getCustomFieldsNames('VAT_INVOICE__c');
        fieldNames.add('Name');
        PermissionValidationUtil.ValidationResult validationResult = PermissionValidationUtil.validateFLS('VAT_INVOICE__c', 
                                                                     fieldNames, PermissionValidationUtil.FLSPermission.P_EDIT);
        
        return validationResult.isSuccess();
    }
    
    public static boolean isDeletableVATInvoice() {
        PermissionValidationUtil.ValidationResult validationResult = PermissionValidationUtil.validateCRUD('VAT_INVOICE__c', 
                                                                     PermissionValidationUtil.FLSPermission.P_DELETE);
        
        return validationResult.isSuccess();
    }
    
    public static boolean isAccessibleManifest() {
        Set<String> fieldNames = PermissionValidationUtil.getCustomFieldsNames('Manifest__c');
        fieldNames.add('Id');
        fieldNames.add('Name');
        PermissionValidationUtil.ValidationResult validationResult = PermissionValidationUtil.validateFLS('Manifest__c', 
                                                                     fieldNames, PermissionValidationUtil.FLSPermission.P_READ);
        
        return validationResult.isSuccess();
    }
    
    public static boolean isAccessibleForwardingVAT() {
        Set<String> fieldNames = PermissionValidationUtil.getCustomFieldsNames('FORWARDING_VAT__c');
        fieldNames.add('Id');
        fieldNames.add('Name');
        PermissionValidationUtil.ValidationResult validationResult = PermissionValidationUtil.validateFLS('FORWARDING_VAT__c', 
                                                                     fieldNames, PermissionValidationUtil.FLSPermission.P_READ);
        
        return validationResult.isSuccess();
    }
    
    public static boolean isAccessibleInvoicingVAT() {
        Set<String> fieldNames = PermissionValidationUtil.getCustomFieldsNames('INVOICING_VAT__c');
        fieldNames.add('Id');
        fieldNames.add('Name');
        PermissionValidationUtil.ValidationResult validationResult = PermissionValidationUtil.validateFLS('INVOICING_VAT__c', 
                                                                     fieldNames, PermissionValidationUtil.FLSPermission.P_READ);
        
        return validationResult.isSuccess();
    }

    public static boolean isAccessiblePurchasingOrder() {
        Set<String> fieldNames = PermissionValidationUtil.getCustomFieldsNames('PurchasingOrder__c');
        fieldNames.add('Id');
        fieldNames.add('Name');
        PermissionValidationUtil.ValidationResult validationResult = PermissionValidationUtil.validateFLS('PurchasingOrder__c',
                fieldNames, PermissionValidationUtil.FLSPermission.P_READ);

        return validationResult.isSuccess();
    }

    public static boolean isCreatablePurchasingOrder() {
        Set<String> fieldNames = PermissionValidationUtil.getCustomFieldsNames('PurchasingOrder__c');
        fieldNames.add('Name');
        PermissionValidationUtil.ValidationResult validationResult = PermissionValidationUtil.validateFLS('PurchasingOrder__c',
                fieldNames, PermissionValidationUtil.FLSPermission.P_CREATE);

        return validationResult.isSuccess();
    }

    public static boolean isEditablePurchasingOrder() {
        Set<String> fieldNames = PermissionValidationUtil.getCustomFieldsNames('PurchasingOrder__c');
        fieldNames.add('Name');
        PermissionValidationUtil.ValidationResult validationResult = PermissionValidationUtil.validateFLS('PurchasingOrder__c',
                fieldNames, PermissionValidationUtil.FLSPermission.P_EDIT);

        return validationResult.isSuccess();
    }

    public static boolean isAccessibleRoute() {
        Set<String> fieldNames = PermissionValidationUtil.getCustomFieldsNames('Route__c');
        fieldNames.add('Id');
        fieldNames.add('Name');
        PermissionValidationUtil.ValidationResult validationResult = PermissionValidationUtil.validateFLS('Route__c',
                fieldNames, PermissionValidationUtil.FLSPermission.P_READ);

        return validationResult.isSuccess();
    }

    public static boolean isCreatableRoute() {
        Set<String> fieldNames = PermissionValidationUtil.getCustomFieldsNames('Route__c');
        fieldNames.add('Name');
        PermissionValidationUtil.ValidationResult validationResult = PermissionValidationUtil.validateFLS('Route__c',
                fieldNames, PermissionValidationUtil.FLSPermission.P_CREATE);

        return validationResult.isSuccess();
    }

    public static boolean isEditableRoute() {
        Set<String> fieldNames = PermissionValidationUtil.getCustomFieldsNames('Route__c');
        fieldNames.add('Name');
        PermissionValidationUtil.ValidationResult validationResult = PermissionValidationUtil.validateFLS('Route__c',
                fieldNames, PermissionValidationUtil.FLSPermission.P_EDIT);

        return validationResult.isSuccess();
    }
}