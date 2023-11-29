public with sharing class ContainerInfoTriggerHandler extends AbstractTriggerHandler {
    private Map<Id, CustomObject1__c> refHBLs = new Map<Id, CustomObject1__c>();
    private List<CustomObject1__c> toBeUpdatedHBLs = new List<CustomObject1__c>();
    private Map<Id, List<Container_Info__c>> containerInfosPerShipment;

    public override String getHandlerName() {
        return 'ContainerInfoTriggerHandler';
    }

    public ContainerInfoTriggerHandler() {
        refHBLs = loadReferenceHBLs(Trigger.old, Trigger.new);
    }

    public override void bulkAfter() {
        toBeUpdatedHBLs = refHBLs.values();
    }

    public override void beforeInsert(SObject so) {
        Container_Info__c containerInfo = (Container_Info__c) so;
        syncContainerInfo(containerInfo);
    }

    public override void beforeUpdate(SObject oldSo, SObject so) {
        Container_Info__c containerInfo = (Container_Info__c) so;
        syncContainerInfo(containerInfo);
    }

    private void syncContainerInfo(Container_Info__c containerInfo) {
        if (containerInfo.Bypass_Container_Type_Check__c == false) {
            CustomObject1__c shipment = refHBLs.get(containerInfo.HBL_SHIPMENT__c);
            ContainerInfoService.validate(containerInfosPerShipment.get(containerInfo.HBL_SHIPMENT__c), containerInfo);
        } else {
            containerInfo.Bypass_Container_Type_Check__c = false;
        }

        String containerNo = containerInfo.Container_NO__c;
        if (containerNo != null) {
            containerInfo.Container_NO__c = containerNo.toUpperCase();
        }

        String sealNo = containerInfo.Seal_No__c;
        if (sealNo != null) {
            containerInfo.Seal_No__c = sealNo.toUpperCase();
        }
    }

    public override void andFinally() {
        if (Trigger.isAfter) {
            syncContainerInfoForHBLs();
        }

        if (toBeUpdatedHBLs != null && !toBeUpdatedHBLs.isEmpty()) {
            FlsService.doUpdate(toBeUpdatedHBLs);
        }
    }

    private Map<Id, CustomObject1__c> loadReferenceHBLs(List<Container_Info__c> oldContainers, List<Container_Info__c> newContainers) {
        List<Container_Info__c> containers = new List<Container_Info__c>();

        if (newContainers != null) {
            containers.addAll(newContainers);
        } else {
            containers.addAll(oldContainers);
        }

        Set<Id> refHBLIds = new Set<Id>();
        for (Container_Info__c container : containers) {
            refHBLIds.add(container.HBL_SHIPMENT__c);
        }
		
        // 2019/07/31 Chien Truong MODIFY START
        /*Map<Id, CustomObject1__c> refHBLs = new Map<Id, CustomObject1__c>([
                SELECT Id, ContainerNumber__c, ContainerNumber2__c, TranporationType__c,
                        Container__c, Container2__c, Container3__c, Container_Measurement_Details__c,
                        ContainerNumber3__c, Container4__c, ContainerNumber4__c, UnitType__c,
                        carton__c, weight__c, NET_NET_Weight__c, CBM__c, (
                        SELECT Container_No__c, Seal_No__c, Container__c, QUANTITY_PACKAGES__c, GROSS_WEIGHT__c, NET_WEIGHT__c, MEASUREMENT_CBM__c, GOODS__c
                        FROM Container_Info__r
                )
                FROM CustomObject1__c
                WHERE Id = :refHBLIds
        ]);*/
        Map<Id, CustomObject1__c> refHBLs = new Map<Id, CustomObject1__c>([
                SELECT Id, ContainerNumber__c, ContainerNumber2__c, TranporationType__c,
                        Container__c, Container2__c, Container3__c, Container_Measurement_Details__c, ContainerNumberList__c, ContainerTypeList__c,
                        ContainerNumber3__c, Container4__c, ContainerNumber4__c, UnitType__c,
            			Container5__c, ContainerNumber5__c, Container6__c, ContainerNumber6__c, Container7__c, ContainerNumber7__c,
                        carton__c, weight__c, NET_NET_Weight__c, CBM__c, (
                        SELECT Container_No__c, Seal_No__c, Container__c, QUANTITY_PACKAGES__c, GROSS_WEIGHT__c, NET_WEIGHT__c, MEASUREMENT_CBM__c, GOODS__c
                        FROM Container_Info__r
                )
                FROM CustomObject1__c
                WHERE Id = :refHBLIds
        ]);
        // 2019/07/31 Chien Truong MODIFY END

        containerInfosPerShipment = new Map<Id, List<Container_Info__c>>();
        for (Container_Info__c containerInfo : [
                SELECT Container_No__c, Seal_No__c, Container__c, QUANTITY_PACKAGES__c, GROSS_WEIGHT__c, NET_WEIGHT__c, MEASUREMENT_CBM__c, GOODS__c, HBL_SHIPMENT__c, CargoTypeUnit__c
                FROM Container_Info__c
                WHERE HBL_SHIPMENT__c IN :refHBLIds
        ]) {
            List<Container_Info__c> containerInfos = containerInfosPerShipment.get(containerInfo.HBL_SHIPMENT__c);
            if (containerInfos == null || containerInfos.isEmpty()) {
                containerInfos = new List<Container_Info__c>();
                containerInfosPerShipment.put(containerInfo.HBL_SHIPMENT__c, containerInfos);
            }

            containerInfos.add(containerInfo);
        }

        return refHBLs;
    }

    private void syncContainerInfoForHBLs() {
        for (CustomObject1__c hbl : toBeUpdatedHBLs) {
            ContainerInfoService.resetHBLContainerInfo(hbl, containerInfosPerShipment.get(hbl.Id));
        }
    }
}