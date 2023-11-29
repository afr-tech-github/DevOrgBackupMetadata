public class HSCodeTriggerHandler extends AbstractTriggerHandler {
    private Map<Id, HS_Code__c> parent = new Map<Id, HS_Code__c>();
    private Set<HS_Code__c> toBeUpdatedChapters = new Set<HS_Code__c>();
    
    public override String getHandlerName() {
        return 'HSCodeTriggerHandler';
    }
    
    public override void bulkBefore() {
        loadChapters();
    }
    
    public override void beforeInsert(SObject so) {
        HS_Code__c hsCode = (HS_Code__c) so;        
        hsCode.Name = hsCode.HS_Code__c;

        if (hsCode.Is_Chapter__c != true) {
            HS_Code__c chapter = null;

            if (hsCode.Chapter__c != null) {
                chapter = parent.get(hsCode.Chapter__c);
            } else {
                chapter = findParentId(hsCode.HS_Code__c);
            }
            
            if (chapter != null) {
                hsCode.Chapter__c = chapter.Id;
                
                if (chapter.Has_Subcategory__c != true) {
                    chapter.Has_Subcategory__c = true;
                    toBeUpdatedChapters.add(chapter);
                }
            }            
        }
    }
    
    public override void andFinally() {
        if (!toBeUpdatedChapters.isEmpty()) {
            FlsService.doUpdate(new List<HS_Code__c>(toBeUpdatedChapters));
        }
    }
    
    private void loadChapters() {
        Set<Id> parentIds = new Set<Id>();
        
        for (SObject so : Trigger.new) {
            HS_Code__c hsCode = (HS_Code__c) so;
            if (hsCode.Chapter__c != null) {
                parentIds.add(hsCode.Chapter__c);
            }
        }

        parent = new Map<Id, HS_Code__c>([SELECT Id, HS_Code__c, Has_Subcategory__c FROM HS_Code__c WHERE Is_Chapter__c = true OR Id IN :parentIds]);
    }
    
    private HS_Code__c findParentId(String hsCode) {
        if (!parent.isEmpty()) {
            for (HS_Code__c chapter : parent.values()) {
                String chapterCode = chapter.HS_Code__c;
                
                if (chapterCode.left(4).equals(hsCode.left(4))) {
                    return chapter;
                }
            }    
        }

        return null;
    }
}