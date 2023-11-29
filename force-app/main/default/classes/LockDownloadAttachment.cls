public class LockDownloadAttachment implements Sfc.ContentDownloadHandlerFactory {
    public Sfc.ContentDownloadHandler getContentDownloadHandler(List<ID> ids, Sfc.ContentDownloadContext context) {
        List<PaymentRequest__c> prList = [SELECT ID FROM clofor_com_cfs__PaymentRequest__c WHERE clofor_com_cfs__Lock_Attachment__c = true];
        List<ContentVersion> cvsList = [SELECT Id,FirstPublishLocationId,ContentDocumentId FROM ContentVersion WHERE Id IN :ids];
        List<ContentVersion> cvList = [SELECT Id,FirstPublishLocationId,ContentDocumentId FROM ContentVersion];
        List<String> conList = new List<String>();
        Sfc.ContentDownloadHandler cdh = new Sfc.ContentDownloadHandler();
        // for (clofor_com_cfs__PaymentRequest__c pr : prList){
            // for (ContentVersion cv : cvsList){
                // if (cv.FirstPublishLocationId == pr.Id){
                    // cdh.isDownloadAllowed = false;
                    // cdh.downloadErrorMessage = 'You cannot download this file/attachment. Please contact your Administator for more details.';
                    // return cdh;
                // }          
            // }
        // }
        for (clofor_com_cfs__PaymentRequest__c pr : prList){
            for (ContentVersion cv : cvList){
                if (cv.FirstPublishLocationId == pr.Id){
                    conList.add(cv.ContentDocumentId);
                }          
            }
        }
        for (String con : conList){
            for (ContentVersion cv : cvsList){
                if (cv.ContentDocumentId == con){
                    cdh.isDownloadAllowed = false;
                    cdh.downloadErrorMessage = 'You cannot download this file/attachment. Please contact your Administator for more details.';
                    return cdh;
                }          
            }
        }
        cdh.isDownloadAllowed = true;
        return cdh;
    }
}