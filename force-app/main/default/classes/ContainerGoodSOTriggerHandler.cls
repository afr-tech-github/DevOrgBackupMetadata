public with sharing class ContainerGoodSOTriggerHandler extends AbstractTriggerHandler {
    private Set<Id> soIds = new Set<Id>();
    public override String getHandlerName() {
        return 'ContainerGoodSOTriggerHandler';
    }       
    public override void andFinally() {
        rollupContainerNumberToSO();
    }
    public override void afterInsert(Sobject so) {
        clofor_com_cfs__ContainerGoodSO__c container = (clofor_com_cfs__ContainerGoodSO__c) so;
        soIds.add(container.clofor_com_cfs__GOODSSO__c);
    }
    public override void afterUpdate(Sobject oldSo, Sobject so) {
        clofor_com_cfs__ContainerGoodSO__c containerOld = (clofor_com_cfs__ContainerGoodSO__c) oldSo;
        clofor_com_cfs__ContainerGoodSO__c container = (clofor_com_cfs__ContainerGoodSO__c) so;
        if(container.clofor_com_cfs__ContainerType__c != containerOld.clofor_com_cfs__ContainerType__c){
            soIds.add(container.clofor_com_cfs__GOODSSO__c);
        }
        
    }
    public override void afterDelete(Sobject so) {
        clofor_com_cfs__ContainerGoodSO__c container = (clofor_com_cfs__ContainerGoodSO__c) so;
        soIds.add(container.clofor_com_cfs__GOODSSO__c);
    }
    private void rollupContainerNumberToSO(){
        List<clofor_com_cfs__SALES_ORDER__c> goodSOtobeUpdated = new List<clofor_com_cfs__SALES_ORDER__c>();
        for(Id soId : soIds){
            goodSOtobeUpdated.add(new clofor_com_cfs__SALES_ORDER__c(Id = soId));
        }
        
        FlsService.doUpdate(goodSOtobeUpdated);
    }
}