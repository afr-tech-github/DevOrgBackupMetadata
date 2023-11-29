public with sharing class BankTransactionTriggerHelper {
    public static void calculateAmount(List<BankTransaction__c> bankNews) {
        // for(BankTransaction__c bank : bankNews){
        //     Decimal amountLocal = 0;
        //     amountLocal += bank.RollupFMSUnpaidBalOfBuyingLocal__c == null? 0: bank.RollupFMSUnpaidBalOfBuyingLocal__c;
        //     amountLocal += bank.RollupWMSUnpaidBalOfBuyingLocal__c == null? 0: bank.RollupWMSUnpaidBalOfBuyingLocal__c;
        //     amountLocal += bank.RollupPIUnpaidBalanceLocal__c == null? 0: bank.RollupPIUnpaidBalanceLocal__c;
        //     amountLocal += bank.RollupKickbackUnpaidBalanceLocal__c == null? 0: bank.RollupKickbackUnpaidBalanceLocal__c;
        //     amountLocal += bank.RollupAmountOfOutboundDeposit__c == null? 0: bank.RollupAmountOfOutboundDeposit__c;
        //     amountLocal += bank.RollupPayslipUnpaidBal__c == null? 0: bank.RollupPayslipUnpaidBal__c;
        //     amountLocal += bank.RollupOtherUnpaidBalance__c == null? 0: bank.RollupOtherUnpaidBalance__c;
        //     amountLocal += bank.RollupTotalLoanRepayment__c == null? 0: bank.RollupTotalLoanRepayment__c;
        //     Decimal amountUSD = 0;
        //     amountUSD += bank.RollupFMSUnpaidBalOfBuyingUSD__c == null? 0: bank.RollupFMSUnpaidBalOfBuyingUSD__c;
        //     amountUSD += bank.RollupWMSUnpaidBalOfBuyingUSD__c == null? 0: bank.RollupWMSUnpaidBalOfBuyingUSD__c;
        //     amountUSD += bank.RollupPIUnpaidBalanceUSD__c == null? 0: bank.RollupPIUnpaidBalanceUSD__c;
        //     amountUSD += bank.RollupKickbackUnpaidBalanceUSD__c == null? 0: bank.RollupKickbackUnpaidBalanceUSD__c;
        //     amountUSD += bank.RollupAmountOfOutboundDepositUSD__c == null? 0: bank.RollupAmountOfOutboundDepositUSD__c;
        //     //amountUSD += bank.RollupOtherUnpaidBalanceUSD__c == null? 0: bank.RollupOtherUnpaidBalanceUSD__c;

        //     Decimal amountSellLocal = 0;
        //     amountSellLocal += bank.RollupFMSUnpaidBalOfSellingLocal__c == null? 0: bank.RollupFMSUnpaidBalOfSellingLocal__c;
        //     amountSellLocal += bank.RollupOtherUnreceivedBalance__c == null? 0: bank.RollupOtherUnreceivedBalance__c;
        //     amountSellLocal += bank.RollupWMSUnpaidBalOfSellingLocal__c == null? 0: bank.RollupWMSUnpaidBalOfSellingLocal__c;
        //     amountSellLocal += bank.RollupAmountOfInboundDepositLocal__c  == null? 0: bank.RollupAmountOfInboundDepositLocal__c ;
        //     amountSellLocal += bank.RollupLoanAmountLocal__c == null? 0: bank.RollupLoanAmountLocal__c;

        //     Decimal amountSellUSD = 0;
        //     amountSellUSD += bank.RollupFMSUnpaidBalOfSellingUSD__c == null? 0: bank.RollupFMSUnpaidBalOfSellingUSD__c;
        //     amountSellUSD += bank.RollupOtherUnreceivedBalUSD__c == null? 0: bank.RollupOtherUnreceivedBalUSD__c;
        //     amountSellUSD += bank.RollupWMSUnpaidBalOfSellingUSD__c == null? 0: bank.RollupWMSUnpaidBalOfSellingUSD__c;
        //     amountSellUSD += bank.RollupAmountOfInboundDepositUSD__c  == null? 0: bank.RollupAmountOfInboundDepositUSD__c ;
        //     amountSellUSD += bank.RollupLoanAmountFCY__c == null? 0: bank.RollupLoanAmountFCY__c;

        //     bank.TotalAmountOfPayableLocal__c = amountLocal; 
        //     bank.TotalAmountOfPayableUSD__c = amountUSD; 
        //     bank.TotalAmountOfReceivableLocal__c = amountSellLocal;
        //     bank.TotalAmountOfReceivableUSD__c = amountSellUSD;
        // }
    }
}