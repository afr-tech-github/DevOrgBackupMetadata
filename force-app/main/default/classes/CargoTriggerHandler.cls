public with sharing class CargoTriggerHandler {
    public static void autoPopulateFields(List<Cargo__c> listNew, Map<Id, Cargo__c> mapOld) {
        for(Cargo__c item : listNew) {
            //sync address
            if (!String.isBlank(item.DeliveryAddressNew__c)) {
                item.DeliveryAddress__c = item.DeliveryAddressNew__c;
            } else if (!String.isBlank(item.DeliveryAddress__c)) {
                item.DeliveryAddressNew__c = item.DeliveryAddress__c.left(255);
            }
        }
    }
}