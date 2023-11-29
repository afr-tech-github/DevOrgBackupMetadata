public class FMSBillPayReqTriggerHelper {
    public static Boolean rollupFlag = false;
    public static Boolean recalculateFlag = false;
    public static void checkDuplicate(List<FMSBillPayReq__c> billRequestList){
        Set<String> uniqueKeys = new Set<String>();
        Set<String> billIds = new Set<String>();
        Set<String> requestIds = new Set<String>();
        for(FMSBillPayReq__c billReq : billRequestList){
           String uniqueKey = String.valueOf(billReq.PaymentRequestID__c) + String.valueOf(billReq.FMSBillID__c);
            if(uniqueKeys.contains(uniqueKey)){
                String errorStr = 'Duplicate found : Already connected bill {0} with TRX Plan {1}';
                errorStr = String.format(errorStr, new List<String> {billReq.FMSBillID__r.Name, billReq.PaymentRequestID__r.Name});
                billRequestList[0].addError(errorStr);
            }else{
                billIds.add(billReq.FMSBillID__c);
                requestIds.add(billReq.PaymentRequestID__c);
                uniqueKeys.add(uniqueKey);
            }
        }
        // get in database
        List<FMSBillPayReq__c> billRequestDB = [SELECT Id, PaymentRequestID__c, PaymentRequestID__r.Name, 
                                                FMSBillID__c,  FMSBillID__r.Name
                                                FROM FMSBillPayReq__c
                                                WHERE PaymentRequestID__c IN: requestIds
                                               	AND FMSBillID__c IN: billIds];
        if(!billRequestDB.isEmpty()){
            for(FMSBillPayReq__c billReqDB : billRequestDB){
                String errorStr = 'Duplicate found : Already connected bill {0} with TRX Plan {1}';
                errorStr = String.format(errorStr, new List<String> {billReqDB.FMSBillID__r.Name, billReqDB.PaymentRequestID__r.Name});
                billRequestList[0].addError(errorStr);
            }
            
        }
    }


    public static void rollupAmountToPaymentRequest(List<FMSBillPayReq__c> billRequestList, Map<Id, FMSBillPayReq__c> billReqOldMap){
        Map<Id, List<FMSBillPayReq__c>> billByRequestMap = new Map<Id, List<FMSBillPayReq__c>>();
        Set<Id> billIds = new Set<Id>();
        for(FMSBillPayReq__c billReq : billRequestList){
            billIds.add(billReq.FMSBillID__c);
            if(billByRequestMap.containsKey(billReq.PaymentRequestID__c)){
                billByRequestMap.get(billReq.PaymentRequestID__c).add(billReq);
            }else{
                billByRequestMap.put(billReq.PaymentRequestID__c, new List<FMSBillPayReq__c>{billReq});
            }
        }
        Map<Id, PaymentRequest__c> mapPaymentRequest = new Map<Id, PaymentRequest__c>([SELECT Id, PaymentTo__c, InvoiceTo__c 
                                                                                        FROM PaymentRequest__c 
                                                                                        WHERE Id IN: billByRequestMap.keySet()]);
        // get list bill
        Map<Id, AnkenMeisai__c> billMap= new Map<Id, AnkenMeisai__c>([SELECT Id, 
                                            BuyDifferentiation__c, 
                                            UNPAID_BALANCE_OF_BUYING_USD__c, 
                                            SellDifferentiation__c,
                                            UNPAID_BALANCE_OF_SELLING_USD__c,
                                            PaymentTo__c,
                                            Seikyusaki__c
                                            FROM AnkenMeisai__c
                                            WHERE Id IN: billIds]);
        // get list PaymentRequest
        Map<Id, PaymentRequest__c> paymentRequestMap = new Map<Id, PaymentRequest__c>([SELECT Id, 
                                            AmountLocalForCollection__c, 
                                            AmountUSDForCollection__c, 
                                            PaymentTo__c,
                                            InvoiceTo__c,
                                            BankID__c,
                                            CashID__c,
                                            LoanID__c,
                                            AmountLocal__c,
                                            AmountUSD__c
                                            FROM PaymentRequest__c
                                            WHERE Id IN: billByRequestMap.keySet()]);


        Set<String> setBillBankIds = new Set<String>();
        Set<String> setBillCashIds = new Set<String>();
        Set<String> setBillLoanIds = new Set<String>();
        List<CloFMSBillBank__c> billBankList = new List<CloFMSBillBank__c>();
        List<ConnectInvoicingAndCash__c> billCashList = new List<ConnectInvoicingAndCash__c>();
        List<FMSBillLoan__c> billLoanList = new List<FMSBillLoan__c>();
        
        for(PaymentRequest__c paymentReq : paymentRequestMap.values()){
            List<FMSBillPayReq__c> billIdsofReq =  billByRequestMap.get(paymentReq.Id);
            
            for(FMSBillPayReq__c billReq : billIdsofReq){

                if(billMap.containsKey(billReq.FMSBillID__c)){
                    AnkenMeisai__c bill = billMap.get(billReq.FMSBillID__c);
                    Decimal  buyDifferentiation = bill.BuyDifferentiation__c == null ? 0 :  bill.BuyDifferentiation__c;
                    Decimal  unpaidBalanceOfBuyingUSD = bill.UNPAID_BALANCE_OF_BUYING_USD__c == null ? 0 :  bill.UNPAID_BALANCE_OF_BUYING_USD__c;
                    Decimal  sellDifferentiation = bill.SellDifferentiation__c == null ? 0 :  bill.SellDifferentiation__c;
                    Decimal  unpaidBalanceOfSellingUSD = bill.UNPAID_BALANCE_OF_SELLING_USD__c == null ? 0 :  bill.UNPAID_BALANCE_OF_SELLING_USD__c;
                    if(billReq.PayReqRollupStatus__c != 'Processed'){
                        if(paymentRequestMap.get(paymentReq.Id).PaymentTo__c == bill.PaymentTo__c
                            || paymentRequestMap.get(paymentReq.Id).InvoiceTo__c == bill.PaymentTo__c){
                            billReq.FMSUnpaidBalOfBuyingLocalPayReq__c = buyDifferentiation;
                            billReq.FMSUnpaidBalOfBuyingUSDPayReq__c = unpaidBalanceOfBuyingUSD;
                        }
                        if(paymentRequestMap.get(paymentReq.Id).InvoiceTo__c == bill.Seikyusaki__c
                            || paymentRequestMap.get(paymentReq.Id).PaymentTo__c == bill.Seikyusaki__c){
                            billReq.FMSUnreceivedBalOfSellingLocalTrx__c = sellDifferentiation;
                            billReq.FMSUnreceivedBalOfSellingUSDTrx__c = unpaidBalanceOfSellingUSD;
                        }
                        

                        if(buyDifferentiation != null 
                            || unpaidBalanceOfBuyingUSD != null
                            || sellDifferentiation != null
                            || unpaidBalanceOfSellingUSD != null){

                            billReq.PayReqRollupStatus__c = 'Processed';
                        }
                    }
                    if(billReq.AutoConnectSourceToTransaction__c == 'Processing Requested'){
                        if(paymentReq.BankID__c != null){
                            String keyBillBankId = String.valueOf(paymentReq.BankID__c) + String.valueOf(billReq.FMSBillID__c);
                            if(!setBillBankIds.contains(keyBillBankId)){
                                setBillBankIds.add(keyBillBankId);
                                CloFMSBillBank__c newBillBank = new CloFMSBillBank__c(
                                    CloFMSBillID__c = billReq.FMSBillID__c,
                                    BankTransactionID__c = paymentReq.BankID__c
                                );
                                billBankList.add(newBillBank);
                                billReq.AutoConnectSourceToTransaction__c = 'Processed';
                            }
                        }

                        if(paymentReq.CashID__c != null){
                            String keyBillCashId = String.valueOf(paymentReq.CashID__c) + String.valueOf(billReq.FMSBillID__c);
                            if(!setBillCashIds.contains(keyBillCashId)){
                                setBillCashIds.add(keyBillCashId);
                                ConnectInvoicingAndCash__c newBillCash = new ConnectInvoicingAndCash__c(
                                    Invoicing__c = billReq.FMSBillID__c,
                                    Cashbook__c = paymentReq.CashID__c
                                );
                                billCashList.add(newBillCash);
                                billReq.AutoConnectSourceToTransaction__c = 'Processed';
                            }
                        }

                        if(paymentReq.LoanID__c != null){
                            String keyBillLoanId = String.valueOf(paymentReq.LoanID__c) + String.valueOf(billReq.FMSBillID__c);
                            if(!setBillLoanIds.contains(keyBillLoanId)){
                                setBillLoanIds.add(keyBillLoanId);
                                FMSBillLoan__c newBillLoan = new FMSBillLoan__c(
                                    FMSBillID__c = billReq.FMSBillID__c,
                                    LoanID__c = paymentReq.LoanID__c
                                );
                                billLoanList.add(newBillLoan);
                                billReq.AutoConnectSourceToTransaction__c = 'Processed';
                            }
                        }

                    }
                    
                }
            }
        }
        try{
            FlsService.doInsert(billBankList);
            FlsService.doInsert(billCashList);
            FlsService.doInsert(billLoanList);
        }catch(Exception ex){
             billRequestList[0].addError(ex.getMessage());
        }
	}

    public static void reCacualateAmountToPaymentRequest(List<FMSBillPayReq__c> lisBillReqOld){
        try{
            Set<Id> paymentRequest = new Set<Id>();
            for( FMSBillPayReq__c paymentReq : lisBillReqOld){
                paymentRequest.add(paymentReq.PaymentRequestID__c);
            }

            Set<Id> accountIds = new Set<Id>();
            Map<Id, PaymentRequest__c> mapPaymentRequest = new Map<Id, PaymentRequest__c>([SELECT Id, 
                                                                                            PaymentTo__c, 
                                                                                            InvoiceTo__c, 
                                                                                            AmountLocal__c,
                                                                                            AmountUSD__c,
                                                                                            AmountLocalForCollection__c,
                                                                                            AmountUSDForCollection__c,
                                                                                            RecordType.DeveloperName
                                                                                            FROM PaymentRequest__c WHERE Id IN: paymentRequest]);
            for(PaymentRequest__c pr : mapPaymentRequest.values()){
                if(!String.isBlank(pr.PaymentTo__c)){
                    accountIds.add(pr.PaymentTo__c);
                }
                 if(!String.isBlank(pr.InvoiceTo__c)){
                    accountIds.add(pr.InvoiceTo__c);
                }
            }
            List<AggregateResult> listBillPaymentRedRemaining = [SELECT PaymentRequestID__c,
                                                                    FMSBillID__r.PaymentTo__c PaymentTo, 
                                                                    FMSBillID__r.Seikyusaki__c InvoiceTo,
                                                                    sum(FMSUnpaidBalOfBuyingLocalPayReq__c) AmountLocal,
                                                                    sum(FMSUnpaidBalOfBuyingUSDPayReq__c) AmountUSD,
                                                                    sum(FMSUnreceivedBalOfSellingLocalTrx__c) AmountLocalForCollection,
                                                                    sum(FMSUnreceivedBalOfSellingUSDTrx__c) AmountUSDForCollection 
                                                                    FROM FMSBillPayReq__c
                                                                    WHERE PayReqRollupStatus__c = 'Processed'
                                                                    AND PaymentRequestID__c IN: paymentRequest
                                                                    AND (
                                                                        FMSBillID__r.PaymentTo__c IN: accountIds
                                                                        OR  FMSBillID__r.Seikyusaki__c IN: accountIds
                                                                    )
                                                                    GROUP BY  PaymentRequestID__c, FMSBillID__r.PaymentTo__c, FMSBillID__r.Seikyusaki__c
                                                                    ORDER BY PaymentRequestID__c];
            //List<PaymentRequest__c> paymentReqListToUpdate = [SELECT Id FROM PaymentRequest__c WHERE Id IN: paymentRequest];
            Map<String, List<AggregateResult>> mapSum = new Map<String, List<AggregateResult>>();
            for(AggregateResult result : listBillPaymentRedRemaining){
                if(result.get('clofor_com_cfs__PaymentRequestID__c') != null){
                    if(!mapSum.containsKey((String)result.get('clofor_com_cfs__PaymentRequestID__c'))){
                        mapSum.put((String)result.get('clofor_com_cfs__PaymentRequestID__c'), new List<AggregateResult>{result});
                    }else{
                        mapSum.get((String)result.get('clofor_com_cfs__PaymentRequestID__c')).add(result);
                    }
                    
                }
            }
            for(PaymentRequest__c request : mapPaymentRequest.values()){
                request.AmountLocal__c = 0;
                request.AmountUSD__c = 0;
                request.AmountLocalForCollection__c = 0;
                request.AmountUSDForCollection__c = 0;
                if(mapSum.containsKey(request.Id)){
                    List<AggregateResult> results = mapSum.get(request.Id);
                    for(AggregateResult result : results){
                        if(!String.isBlank(request.InvoiceTo__c)){

                            if(result.get('InvoiceTo') != null && request.InvoiceTo__c == (String)result.get('InvoiceTo')){
                                    if(result.get('AmountLocalForCollection') != null){
                                        request.AmountLocalForCollection__c = request.AmountLocalForCollection__c == null? 0 : request.AmountLocalForCollection__c;
                                        request.AmountLocalForCollection__c += (Decimal)result.get('AmountLocalForCollection');
                                    }

                                    if(result.get('AmountUSDForCollection') != null){
                                        request.AmountUSDForCollection__c = request.AmountUSDForCollection__c == null? 0 : request.AmountUSDForCollection__c;
                                        request.AmountUSDForCollection__c += (Decimal)result.get('AmountUSDForCollection');
                                    }
                            }
                            if(result.get('PaymentTo') != null && request.InvoiceTo__c == (String)result.get('PaymentTo')){
                                    if(result.get('AmountLocal') != null){
                                        request.AmountLocalForCollection__c = request.AmountLocalForCollection__c == null? 0 : request.AmountLocalForCollection__c;
                                        request.AmountLocalForCollection__c -= (Decimal)result.get('AmountLocal');
                                    }

                                    if(result.get('AmountUSD') != null){
                                        request.AmountUSDForCollection__c = request.AmountUSDForCollection__c == null? 0 : request.AmountUSDForCollection__c;
                                        request.AmountUSDForCollection__c -= (Decimal)result.get('AmountUSD');
                                    }
                            } 
                        }

                        if(!String.isBlank(request.PaymentTo__c)){
                            if(result.get('PaymentTo') != null && request.PaymentTo__c == (String)result.get('PaymentTo')){
                                if(result.get('AmountLocal') != null){
                                    request.AmountLocal__c = request.AmountLocal__c == null? 0 : request.AmountLocal__c;
                                    request.AmountLocal__c += (Decimal)result.get('AmountLocal');
                                }

                                if(result.get('AmountUSD') != null){
                                    request.AmountUSD__c = request.AmountUSD__c == null? 0 : request.AmountUSD__c;
                                    request.AmountUSD__c += (Decimal)result.get('AmountUSD');
                                }
                            }
                            if(result.get('InvoiceTo') != null && request.PaymentTo__c == (String)result.get('InvoiceTo')){
                                    if(result.get('AmountLocalForCollection') != null){
                                        request.AmountLocal__c = request.AmountLocal__c == null? 0 : request.AmountLocal__c;
                                        request.AmountLocal__c -= (Decimal)result.get('AmountLocalForCollection');
                                    }

                                    if(result.get('AmountUSDForCollection') != null){
                                        request.AmountUSD__c = request.AmountUSD__c == null? 0 : request.AmountUSD__c;
                                        request.AmountUSD__c -= (Decimal)result.get('AmountUSDForCollection');
                                    }
                            }
                        }
                    }
                }
            }

            FlsService.doUpdate(mapPaymentRequest.values());
        }catch(Exception ex){
            lisBillReqOld[0].addError(ex.getMessage());
        }

    }
}