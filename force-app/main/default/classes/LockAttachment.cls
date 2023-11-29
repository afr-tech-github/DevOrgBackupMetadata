public class LockAttachment {
    public static void onBeforeDeleteAttachment(List<Attachment> attList){
        List<PaymentRequest__c> prList = new List<PaymentRequest__c>();
        prList = [SELECT ID FROM clofor_com_cfs__PaymentRequest__c WHERE clofor_com_cfs__Lock_Attachment__c = true];
        for (clofor_com_cfs__PaymentRequest__c pr : prList){
            for (Attachment att : attList){
                if (att.ParentId == pr.ID){
                    att.addError('You cannot delete this file/attachment. Please contact your Administator for more details.');
                }
            }
        }
    }
    public static void onBeforeDeleteContent(List<ContentDocument > conList){
        List<clofor_com_cfs__PaymentRequest__c> prList = new List<clofor_com_cfs__PaymentRequest__c>();
        prList = [SELECT ID FROM PaymentRequest__c WHERE clofor_com_cfs__Lock_Attachment__c = true];
        List<ContentVersion> cvList = new List<ContentVersion>();
        cvList = [SELECT ID,FirstPublishLocationId,ContentDocumentId FROM ContentVersion];
        List<String> contentList = new List<String>();
        // for (clofor_com_cfs__PaymentRequest__c pr : prList){
            // for (ContentVersion cv : cvList){
                // if (cv.FirstPublishLocationId == pr.Id){
                    // for (ContentDocument con : conList){
                        // if (con.LatestPublishedVersionId == cv.ID){
                            // con.addError('You cannot delete this file/attachment. Please contact your Administator for more details.');
                        // }
                    // }
                // }
            // }
        // }
        for (clofor_com_cfs__PaymentRequest__c pr : prList){
            for (ContentVersion cv : cvList){
                if (cv.FirstPublishLocationId == pr.Id){
                    contentList.add(cv.ContentDocumentId);
                }
            }
        }
        for (String content : contentList){
            for (ContentVersion cv : cvList){
                if (cv.ContentDocumentId == content){
                    for (ContentDocument con : conList){
                        if (con.LatestPublishedVersionId == cv.ID){
                            con.addError('You cannot delete this file/attachment. Please contact your Administator for more details.');
                        }
                    }           
                }          
            }
        }
    }
}