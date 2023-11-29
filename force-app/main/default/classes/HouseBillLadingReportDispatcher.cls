global with sharing class HouseBillLadingReportDispatcher {
    webservice static String createAttachment(Id id, String wkid, String version) {
        if (PermissionValidationUtil.isCreatableAttachment()) {
            PageReference pageRef = new PageReference('/apex/' + Constants.NAMESPACE + 'HouseBillLadingReport');
            pageRef.getParameters().put(Constants.REQUEST_ID, id);
            
            Attachment attachment = new Attachment();
            attachment.Name = EncodingUtil.urlDecode('Manifest(' + wkid + '-' + version + ').xls', 'UTF-8');
            
            String attachmentId = null;
            if (!Test.IsRunningTest()){
                attachment.Body = pageRef.getContent();
                attachment.ParentId = id; 
                FlsService.doinsert(attachment);
                
                attachmentId = attachment.Id;
            }
            
            return attachmentId;
        } 
        return null;
    }
}