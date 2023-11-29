public with sharing class VATInvoiceTriggerHandler extends AbstractTriggerHandler {
    private Set<CustomObject1__c> toBeUpdatedHBLs = new Set<CustomObject1__c>();
    private Site_Custom_Settings__c settings = null;
    private Set<AnkenMeisai__c> toBeUpdateHBLSBs = new Set<AnkenMeisai__c>();
    private Map<Id, List<AnkenMeisai__c>> vatToHBLSB;
    
    public override String getHandlerName() {
        return 'VATInvoiceTriggerHandler';
    }
    
    public override void bulkAfter() {
        if (Trigger.isUpdate) {
            loadHBLSB(Trigger.new);           
        }
    }
    
    public override void beforeInsert(SObject so) {
        VAT_INVOICE__c invoice = (VAT_INVOICE__c) so;
        //Integer nextRunningNumber = getNextVATRunningNumber();
        //String vatRunningNumber = StringUtils.prependZerosToNumber(nextRunningNumber, Constants.RUNNING_NUMBER_LENGTH);
        //invoice.RED_INVOICE_NO__c = vatRunningNumber;
    }
        
    public override void afterUpdate(SObject old, SObject so) {
        VAT_INVOICE__c invoice = (VAT_INVOICE__c) so;
        syncIssueStatusToHBLSB(invoice);
    }
    
    public override void andFinally() {
        if (!toBeUpdatedHBLs.isEmpty()) {
            try {
                FlsService.doUpdate(new List<CustomObject1__c>(toBeUpdatedHBLs));
            } catch(Exception e) {
            }
        }
        
        if (Trigger.isUpdate && !toBeUpdateHBLSBs.isEmpty()) {
            try {
                FlsService.doUpdate(new List<AnkenMeisai__c>(toBeUpdateHBLSBs));
            } catch(Exception e) {
            }
        }
        
        if (settings != null) {
            FlsService.doUpdate(settings);
        }
    }
    
    private void syncIssueStatusToHBLSB(VAT_INVOICE__c invoice) {
        if (invoice.APPROVED_AND_LOCK__c && (vatToHBLSB != null && vatToHBLSB.containsKey(invoice.Id))) {
            List<AnkenMeisai__c> hblsbs = vatToHBLSB.get(invoice.Id);
            for (AnkenMeisai__c hblsb : hblsbs) {
                hblsb.VAT_INVOICE_ISSUE_STATUS__c = true;
                toBeUpdateHBLSBs.add(hblsb);
            }
        }
    }
    
    private void loadHBLSB(List<VAT_INVOICE__c> invoices) {
        Set<Id> hblsbIds = new Set<Id>();
        Set<Id> vatInvoiceIds = new Set<id>();

        for (VAT_INVOICE__c vi : invoices) {
            if (vi.Id != null && vi.APPROVED_AND_LOCK__c) {
            	vatInvoiceIds.add(vi.Id);    
            }
        }
        
		List<INVOICING_VAT__c> invoicingVATs = [SELECT Invoicing__c, VAT_INVOICE__c FROM INVOICING_VAT__c WHERE VAT_INVOICE__c IN :vatInvoiceIds];
        Map<Id, Id> invoicingToVAT = new Map<Id, Id>();
        if (invoicingVATs != null && !invoicingVATs.isEmpty()) {
            for (INVOICING_VAT__c iv : invoicingVATs) {
                hblsbIds.add(iv.Invoicing__c);
                invoicingToVAT.put(iv.Invoicing__c, iv.VAT_INVOICE__c);
            }
        }
        List<AnkenMeisai__c> lstHBLSBs = [SELECT Id, VAT_INVOICE_ISSUE_STATUS__c FROM AnkenMeisai__c WHERE Id IN :hblsbIds AND VAT_INVOICE_ISSUE_STATUS__c = False];
        vatToHBLSB = new Map<Id, List<AnkenMeisai__c>>();
        for (AnkenMeisai__c hblsb : lstHBLSBs) {
            Id invoicingVATId = invoicingToVAT.get(hblsb.Id);
            
            if (vatToHBLSB.containsKey(invoicingVATId)) {
                vatToHBLSB.get(invoicingVATId).add(hblsb);
            } else {
                List<AnkenMeisai__c> lst = new List<AnkenMeisai__c>();
                lst.add(hblsb);
                vatToHBLSB.put(invoicingVATId, lst);
            }
        }
    }
    
    private Integer getNextVATRunningNumber() {
        settings = Site_Custom_Settings__c.getOrgDefaults();
        Integer nextRunningNumber = null;
        
        if (settings.VAT_Running_Number__c == null) {
            nextRunningNumber = 1;
        } else {
            nextRunningNumber = (Integer)settings.VAT_Running_Number__c;
        }
        
        settings.VAT_Running_Number__c = settings.VAT_Running_Number__c == Constants.MAX_VAT_RUNNING_NUMBER ? 1 : nextRunningNumber + 1;
        FlsService.doupdate (settings);
        return nextRunningNumber;
    }
}