/**
 * Created by khanhpham on 7/14/17.
 */

public with sharing class TransitTriggerHandler extends AbstractTriggerHandler {
    private Map<Id, CustomObject1__c> mapParentShipments = new Map<Id, CustomObject1__c>();
    private Map<Id, CustomObject1__c> toBeUpdatedShipments = new Map<Id, CustomObject1__c>();
    private Map<Id, Port__c> mapPorts = new Map<Id, Port__c>();

    public override void bulkBefore() {
        loadParentShipments();
        loadReferencePorts();
    }

    public override void bulkAfter() {
        loadParentShipments();
        loadReferencePorts();
    }

    public override void beforeInsert(SObject so) {
        Transit__c transit = (Transit__c) so;

        if (transit.InOrderOfTransit__c == null) {
            CustomObject1__c shipment = mapParentShipments.get(transit.ShipmentOrder__c);

            if (shipment != null) {
                List<Transit__c> existingTransits = shipment.TRANSIT__r;

                if (existingTransits != null && existingTransits.size() > 0) {
                    transit.InOrderOfTransit__c = existingTransits.size() + 1;
                } else {
                    transit.InOrderOfTransit__c = 1;
                }
            }
        }
    }

    public override void afterInsert(SObject so) {
        Transit__c transit = (Transit__c) so;

        if (!TriggerExecutionHelper.isRunning('HBLShipmentsTriggerHandler')) {
            addTransitToHBL(transit.ShipmentOrder__c);
            syncShipmentFromTransit(transit.ShipmentOrder__c, transit);
        }
    }

    public override void beforeUpdate(SObject oldSo, SObject so) {
        Transit__c newTransit = (Transit__c) so;
        CustomObject1__c shipment = mapParentShipments.get(newTransit.ShipmentOrder__c);
        List<Transit__c> transitList = shipment.TRANSIT__r;

        if (transitList != null && !transitList.isEmpty()) {
            if (transitList.size() < newTransit.InOrderOfTransit__c) {
                newTransit.addError('Order of Transit cannot be greater than number of Transit in Shipment Order');
            }
        }
    }

    public override void afterUpdate(SObject oldSo, SObject so) {
        Transit__c newTransit = (Transit__c) so;
        Transit__c oldTransit = (Transit__c) oldSo;

        if (oldTransit.ShipmentOrder__c != newTransit.ShipmentOrder__c) {
            addTransitToHBL(newTransit.ShipmentOrder__c);
            removeTransitFromHBL(oldTransit.ShipmentOrder__c);
        }

        syncShipmentFromTransit(newTransit.ShipmentOrder__c, newTransit);
    }

    public override void afterDelete(SObject so) {
        Transit__c transit = (Transit__c) so;

        if (!TriggerExecutionHelper.isRunning('HBLShipmentsTriggerHandler')) {
            removeTransitFromHBL(transit.ShipmentOrder__c);

            CustomObject1__c shipment = mapParentShipments.get(transit.ShipmentOrder__c);
            List<Transit__c> transitList = shipment.TRANSIT__r;
            syncShipmentFromTransit(transit.ShipmentOrder__c, null);
        }
    }

    public override void andFinally() {
        if (toBeUpdatedShipments.values().size() > 0) {
            FlsService.doUpdate(toBeUpdatedShipments.values());
        }
    }

    private void loadParentShipments() {
        Set<Id> parentId = new Set<Id>();
        Set<Transit__c> transitList = new Set<Transit__c>();

        if (Trigger.IsInsert) {
            transitList.addAll((List<Transit__c>) Trigger.new);
        } else if (Trigger.IsUpdate) {
            transitList.addAll((List<Transit__c>) Trigger.new);
            transitList.addAll((List<Transit__c>) Trigger.old);
        } else if (Trigger.IsDelete) {
            transitList.addAll((List<Transit__c>) Trigger.old);
        }

        for (Transit__c transit : transitList) {
            parentId.add(transit.ShipmentOrder__c);
        }

        mapParentShipments = new Map<Id, CustomObject1__c>([
                SELECT Id, MultiTransitRequired__c, RecordTypeId, (
                        SELECT Id, RecordTypeId, InOrderOfTransit__c, ETDAtTransitPort__c, ETAAtTransitPort__c,
                                TransitVesselFlight__c, SwitchHBL__c, TransitPort__c
                        FROM TRANSIT__r
                        ORDER BY InOrderOfTransit__c ASC
                )
                FROM CustomObject1__c
                WHERE Id IN :parentId
        ]);
    }

    private void addTransitToHBL(Id shipmentId) {
        CustomObject1__c shipment = mapParentShipments.get(shipmentId);

        if (shipment != null) {
            Integer transitLocations = (StringUtils.isEmpty(shipment.MultiTransitRequired__c)
                    || 'NO'.equalsIgnoreCase(shipment.MultiTransitRequired__c) ? 0 : Integer.valueOf(shipment.MultiTransitRequired__c));

            shipment.MultiTransitRequired__c = String.valueOf(++transitLocations);
            toBeUpdatedShipments.put(shipment.Id, shipment);
        }
    }

    private void removeTransitFromHBL(Id shipmentId) {
        CustomObject1__c shipment = mapParentShipments.get(shipmentId);

        if (shipment != null) {
            Integer transitLocations = (StringUtils.isEmpty(shipment.MultiTransitRequired__c)
                    || 'NO'.equalsIgnoreCase(shipment.MultiTransitRequired__c) ? 0 : Integer.valueOf(shipment.MultiTransitRequired__c));

            if (transitLocations > 0) {
                shipment.MultiTransitRequired__c = String.valueOf(--transitLocations);
                toBeUpdatedShipments.put(shipment.Id, shipment);
            }
        }
    }

    private void syncShipmentFromTransit(String shipmentId, Transit__c transit) {
        CustomObject1__c shipment = mapParentShipments.get(shipmentId);
        List<Transit__c> transitList = shipment.TRANSIT__r;
        Transit__c finalTransit = null;

        if (Trigger.isInsert || Trigger.isUpdate) {
            transitList.add(transit);
        }

        finalTransit = getFinalTransit(transitList);

        // do not sync if record being updated is not the final one
        if (finalTransit != null && transit != null && finalTransit.InOrderOfTransit__c != transit.InOrderOfTransit__c) {
            return;
        }

        if (finalTransit != null) {
            shipment.T_ETD__c = finalTransit.ETDAtTransitPort__c;
            shipment.ETAAtTransitPort__c = finalTransit.ETAAtTransitPort__c;
            shipment.TransitV__c = finalTransit.TransitVesselFlight__c;
            shipment.SwitchB_L__c = finalTransit.SwitchHBL__c;

            if (finalTransit.TransitPort__c != null) {
                Port__c port = mapPorts.get(finalTransit.TransitPort__c);

                if (port == null && Trigger.isDelete) {
                    port = loadPort(finalTransit.TransitPort__c);
                }

                shipment.TS__c = (port != null ? port.Name : null);
            }

        } else {
            shipment.T_ETD__c = null;
            shipment.ETAAtTransitPort__c = null;
            shipment.TransitV__c = null;
            shipment.SwitchB_L__c = null;
            shipment.TS__c = null;
        }

        toBeUpdatedShipments.put(shipment.Id, shipment);
    }

    private Transit__c getFinalTransit(List<Transit__c> transitList) {
        Transit__c transit = null;

        if (transitList != null && transitList.size() > 0) {
            Integer maxOrder = 0;

            for (Transit__c t : transitList) {
                if (maxOrder < t.InOrderOfTransit__c) {
                    maxOrder = (Integer) t.InOrderOfTransit__c;
                }
            }

            if (maxOrder > 0) {
                transit = transitList.get(maxOrder - 1);
            }
        }

        return transit;
    }

    private void loadReferencePorts() {
        if (Trigger.isDelete) {
            return;
        }

        List<Transit__c> transits = Trigger.new;
        Set<Id> portIds = new Set<Id>();

        for (Transit__c transit : transits) {
            if (transit.TransitPort__c != null) {
                portIds.add(transit.TransitPort__c);
            }
        }

        if (!portIds.isEmpty()) {
            mapPorts = new Map<Id, Port__c>([SELECT Id, Name FROM Port__c WHERE Id IN :portIds]);
        }
    }

    private Port__c loadPort(String portId) {
        Port__c port = [SELECT Id, Name FROM Port__c WHERE Id = :portId];

        if (port != null) {
            mapPorts.put(port.Id, port);
        }

        return port;
    }
}