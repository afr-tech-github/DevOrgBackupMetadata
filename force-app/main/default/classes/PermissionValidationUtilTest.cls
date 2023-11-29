@isTest(SeeAllData = false)
public class PermissionValidationUtilTest {
    testmethod static void Test() {
        // PermissionValidationUtil.ValidationResult validationResult1 = PermissionValidationUtil.validateCRUD('CustomObject1__c', 
                                                    //  PermissionValidationUtil.FLSPermission.P_READ);
        // String string1 = PermissionValidationUtil.getCustomFieldsNames('CustomObject1__c');
        // System.assertEquals('CustomObject1__c', PermissionValidationUtil.appendNamespace('CustomObject1__c'));
        System.assertEquals(false, PermissionValidationUtil.canReadHBL());
        System.assertEquals(true, PermissionValidationUtil.isAccessibleHBL());
        List<String> error = PermissionValidationUtil.isAccessibleHBLDebug();
        System.assertEquals(true, PermissionValidationUtil.isEditableHBL());
        System.assertEquals(true, PermissionValidationUtil.isCreatableHBL());
        System.assertEquals(true, PermissionValidationUtil.isAccessibleHBLBuying());
        System.assertEquals(true, PermissionValidationUtil.isCreatableHBLBuying());
        System.assertEquals(true, PermissionValidationUtil.isEditableHBLBuying());
        System.assertEquals(true, PermissionValidationUtil.isAccessibleMBLBuying());
        System.assertEquals(true, PermissionValidationUtil.isCreatableMBLBuying());
        System.assertEquals(true, PermissionValidationUtil.isEditableMBLBuying());
        System.assertEquals(true, PermissionValidationUtil.isAccessibleMBL());
        System.assertEquals(true, PermissionValidationUtil.isCreatableMBL());
        System.assertEquals(true, PermissionValidationUtil.isEditableMBL());
        System.assertEquals(true, PermissionValidationUtil.isCreatableAttachment());
        System.assertEquals(true, PermissionValidationUtil.isDeletableContainerInfo());
        System.assertEquals(true, PermissionValidationUtil.isAccessibleUser());
        System.assertEquals(true, PermissionValidationUtil.isAccessibleAccount());
        System.assertEquals(true, PermissionValidationUtil.isAccessibleContact());
        System.assertEquals(true, PermissionValidationUtil.isAccessibleServiceMaster());
        System.assertEquals(true, PermissionValidationUtil.isAccessiblePort());
        System.assertEquals(true, PermissionValidationUtil.isAccessibleWarehouse());
        System.assertEquals(true, PermissionValidationUtil.isAccessibleTaxRatio());
        System.assertEquals(true, PermissionValidationUtil.isAccessibleExchangeRate());
        System.assertEquals(true, PermissionValidationUtil.isEditableExchangeRate());
        System.assertEquals(true, PermissionValidationUtil.isAccessibleVATInvoice());
        System.assertEquals(true, PermissionValidationUtil.isCreatableVATInvoice());
        System.assertEquals(true, PermissionValidationUtil.isEditableVATInvoice());
        System.assertEquals(true, PermissionValidationUtil.isDeletableVATInvoice());
        System.assertEquals(true, PermissionValidationUtil.isAccessibleManifest());
        System.assertEquals(true, PermissionValidationUtil.isAccessibleForwardingVAT());
        System.assertEquals(true, PermissionValidationUtil.isAccessibleInvoicingVAT());
        System.assertEquals(true, PermissionValidationUtil.isAccessiblePurchasingOrder());
        System.assertEquals(true, PermissionValidationUtil.isCreatablePurchasingOrder());
        System.assertEquals(true, PermissionValidationUtil.isEditablePurchasingOrder());
        System.assertEquals(true, PermissionValidationUtil.isAccessibleRoute());
        System.assertEquals(true, PermissionValidationUtil.isCreatableRoute());
        System.assertEquals(true, PermissionValidationUtil.isEditableRoute());


    }
}