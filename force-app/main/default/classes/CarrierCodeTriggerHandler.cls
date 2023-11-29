public with sharing class CarrierCodeTriggerHandler extends AbstractTriggerHandler {
    public override String getHandlerName() {
        return 'CarrierCodeTriggerHandler';
    }    
    
    public override void beforeInsert(SObject so) {
        Carrier_Code__c carrierCode = (Carrier_Code__c) so;
        
        carrierCode.Name = carrierCode.Carrier_Code__c;
    }
    public override void beforeUpdate(SObject oldSo, SObject so) {
        Carrier_Code__c newCarrierCode = (Carrier_Code__c) so;
        
        newCarrierCode.Name = newCarrierCode.Carrier_Code__c;
    }
}