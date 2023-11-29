trigger AttachmentTrigger on Attachment (before delete) {
    if (Trigger.isDelete && Trigger.isBefore){
        LockAttachment.onBeforeDeleteAttachment(Trigger.Old);
    }
}