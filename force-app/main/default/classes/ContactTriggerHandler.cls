public with sharing class ContactTriggerHandler extends AbstractTriggerHandler {
    private List<CustomObject1__c> toBeUpdatedShipments = new List<CustomObject1__c>();
    private Map<Id, Set<CustomObject1__c>> mapShipments = new Map<Id, Set<CustomObject1__c>>();
    
    public override String getHandlerName() {
        return 'ContactTriggerHandler';
    }
    
    public override void bulkAfter() {
        loadReferenceShipments(Trigger.newMap);
    }
    
    public override void afterUpdate(SObject oldSo, SObject so) {
        Contact oldContact = (Contact) oldSo;
        Contact newContact = (Contact) so;

        if (oldContact.MailS__c != newContact.MailS__c) {
            updateNotifyCustomersFlag(newContact.Id, newContact.MailS__c);
        }
    }
    
    public override void andFinally() {
        if (toBeUpdatedShipments.size() > 0) {
            try {
                FlsService.doUpdate(toBeUpdatedShipments);
            } catch(Exception e) {
            }
        }
    }
    
    private void updateNotifyCustomersFlag(Id contactId, Boolean flag) {
        Set<CustomObject1__c> shipments = mapShipments.get(contactId);
        
        if (shipments != null && shipments.size() > 0) {
            for (CustomObject1__c shipment : shipments) {
                if (shipment.CustmerInCharge__c == contactId) {
                    shipment.Customer_Do_Not_Disturb_State__c = flag;
                }
                
                if (shipment.PartnerRep__c == contactId) {
                    shipment.Partner_Do_Not_Disturb_State__c = flag;
                }

                toBeUpdatedShipments.add(shipment);
            }
        }
    }
    
    private void loadReferenceShipments(Map<Id, SObject> contacts) {
        Set<Id> contactIds = contacts.keySet();

        for (List<CustomObject1__c> shipments : [SELECT Partner_Do_Not_Disturb_State__c, Customer_Do_Not_Disturb_State__c,
                                                 PartnerRep__c, CustmerInCharge__c 
                                                 FROM CustomObject1__c 
                                                 WHERE PartnerRep__c IN :contactIds OR CustmerInCharge__c IN :contactIds]) {
            for (CustomObject1__c shipment : shipments) {
                addShipmentToMap(mapShipments, shipment, shipment.CustmerInCharge__c);
                addShipmentToMap(mapShipments, shipment, shipment.PartnerRep__c);
            }
        }
    }
    
    private void addShipmentToMap(Map<Id, Set<CustomObject1__c>> mapShipments, CustomObject1__c shipment, 
                                  Id contactId) {
		if (contactId != null) {
            if (mapShipments.containsKey(contactId)) {
                mapShipments.get(contactId).add(shipment);
            } else {
                Set<CustomObject1__c> shipments = new Set<CustomObject1__c>();
                shipments.add(shipment);
                mapShipments.put(contactId, shipments);
            }
		}
    }
}