public with sharing class InvoicingVATTriggerHandler extends AbstractTriggerHandler {
    private Map<Id, VAT_INVOICE__c> mapVATInvoices = new Map<Id, VAT_INVOICE__c>();
    private Map<Id, AnkenMeisai__c> mapHBLSB = new Map<Id, AnkenMeisai__c>();
    private Set<VAT_INVOICE__c> toBeUpdatedVATInvoices = new Set<VAT_INVOICE__c>();
    private static TranslationService translationService = new TranslationService('VAT_Invoice', UserInfo.getLanguage());
    
    public override void bulkBefore() {
        loadVATInvoices(Trigger.new);
    }
    
    public override void beforeInsert(SObject so) {
        INVOICING_VAT__c iv = (INVOICING_VAT__c) so;
        // disable checking same tax ratio in invoice
        //if (!isAcceptedInvoicing(iv)) {
        //    return;
        //}
    } 
    
    public override void beforeUpdate(SObject oldSo, SObject so) {
        INVOICING_VAT__c iv = (INVOICING_VAT__c) so;
        // disable checking same tax ratio in invoice
        //if (!isAcceptedInvoicing(iv)) {
        //    return;
        //}
    }
    
    public override void andFinally() {
        if (!toBeUpdatedVATInvoices.isEmpty()) {
            FlsService.doUpdate(new List<VAT_INVOICE__c>(toBeUpdatedVATInvoices));
        }
    }
    // disable checking same tax ratio in invoice
    /*private boolean isAcceptedInvoicing(INVOICING_VAT__c iv) {
        VAT_INVOICE__c vatInvoice = mapVATInvoices.get(iv.VAT_INVOICE__c);
        AnkenMeisai__c hblsb = mapHBLSB.get(iv.INVOICING__c);
        
        if (vatInvoice.Number_of_Invoicing__c == null || vatInvoice.Number_of_Invoicing__c == 0) {
            vatInvoice.Selling_Tax_Ratio__c = hblsb.TaxInitial__c;
            toBeUpdatedVATInvoices.add(vatInvoice);
            return true;
        } else if (vatInvoice.Selling_Tax_Ratio__c == hblsb.TaxInitial__c) {
            return true;
        }
        
        final String errorMessage = translationService.getTranslation('DIFF_TAX_RATIO');
        final List<String> fillers = new List<String>{String.valueOf(hblsb.TaxInitial__c), String.valueOf(vatInvoice.Selling_Tax_Ratio__c)};
        iv.addError(String.format(errorMessage, fillers));
        return false;
    }*/
	
    private void loadVATInvoices(List<INVOICING_VAT__c> ivs) {
        Set<Id> vatInvoiceIds = new Set<Id>();
        Set<Id> hblsbIds = new Set<Id>();
        
        for (INVOICING_VAT__c iv : ivs) {
            vatInvoiceIds.add(iv.VAT_INVOICE__c);
            hblsbIds.add(iv.INVOICING__c);
        }
        
        mapVATInvoices = new Map<Id, VAT_INVOICE__c>([SELECT Id, Selling_Tax_Ratio__c, Number_of_Invoicing__c FROM VAT_INVOICE__c WHERE Id IN :vatInvoiceIds]);
        mapHBLSB = new Map<Id, AnkenMeisai__c>([SELECT Id, TaxInitial__c FROM AnkenMeisai__c WHERE Id IN :hblsbIds]);
    }
}