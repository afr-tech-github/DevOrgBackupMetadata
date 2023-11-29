trigger ContainerInfoDeleteTrigger on Container_Info__c (after delete) {
    if(Trigger.isAfter && Trigger.isDelete){
        ContainerInfoDeleteClass.isAfterDelContainerNumber(Trigger.old);
    }
}