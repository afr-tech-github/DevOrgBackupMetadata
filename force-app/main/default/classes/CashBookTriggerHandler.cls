/**
 * Created by khanhpham on 5/22/18.
 */

public with sharing class CashBookTriggerHandler extends AbstractTriggerHandler {
    public override String getHandlerName() {
        return 'CashBookTriggerHandler';
    }

    public override void beforeInsert(SObject so) {
        CASH_BOOK__c cashBook = (CASH_BOOK__c) so;
        cashBook.ActualPaidToVendorWording__c = getWordingForNumber(cashBook.ACTUAL_PAID_TO_VENDOR__c);
    }

    public override void beforeUpdate(SObject oldSO, SObject newSO) {
        CASH_BOOK__c cashBook = (CASH_BOOK__c) newSO;
        cashBook.ActualPaidToVendorWording__c = getWordingForNumber(cashBook.ACTUAL_PAID_TO_VENDOR__c);
    }

    private String getWordingForNumber(Decimal value) {
        // Only generate wording for whole-number part
        if (value != null) {
            return NumbericUtils.convertNumberToText(value);
        }

        return '';
    }
}