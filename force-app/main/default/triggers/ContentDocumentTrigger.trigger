trigger ContentDocumentTrigger on ContentDocument (before delete) {
    if (Trigger.isDelete && Trigger.isBefore){
        LockAttachment.onBeforeDeleteContent(Trigger.Old);
    }
}