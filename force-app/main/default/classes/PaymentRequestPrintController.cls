public with sharing class PaymentRequestPrintController {
    public PaymentRequest__c paymentRequest{get; set;}
    public Site_Custom_Settings__c setting{get; set;}
    public List<ShipmentWrapper> listShippmentWrapper{get; set;}
    public TotalWrapper total{get;set;}
    public String customerAddress{get;set;}
    public PaymentRequestPrintController() {
        total = new TotalWrapper();
        String paymentRequestId = Apexpages.currentpage().getparameters().get('id');
        if(String.isBlank(paymentRequestId)){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Invalid Payment Request Id'));
            return;
        }
        paymentRequest = getPaymentRequest(paymentRequestId);
        
        setting = Site_Custom_Settings__c.getOrgDefaults();
        String curr = 'VND';
        if(paymentRequest.Currency__c != 'VND'){
            curr = 'USD';
        }
        total.curr = curr;
        List<String> address = new List<String>();
			if(!String.isBlank(paymentRequest.PaymentTo__r.BillingStreet)){
				address.add(paymentRequest.PaymentTo__r.BillingStreet);
			}
			if(!String.isBlank(paymentRequest.PaymentTo__r.BillingCity)){
				address.add(paymentRequest.PaymentTo__r.BillingCity);
			}
			if(!String.isBlank(paymentRequest.PaymentTo__r.BillingState)){
				address.add(paymentRequest.PaymentTo__r.BillingState);
			}
			if(!String.isBlank(paymentRequest.PaymentTo__r.BillingPostalCode)){
				address.add(paymentRequest.PaymentTo__r.BillingPostalCode);
			}
			if(!String.isBlank(paymentRequest.PaymentTo__r.BillingCountry)){
				address.add(paymentRequest.PaymentTo__r.BillingCountry);
			}
            
			customerAddress = String.join(address, ', ');
        listShippmentWrapper = getListShipmentWrapper(paymentRequestId, curr);
    }

    private List<ShipmentWrapper> getListShipmentWrapper(String paymentRequestId, String curr){
        List<ShipmentWrapper> listResult = new List<ShipmentWrapper>();
        List<FMSBillPayReq__c> listBillPayReq = [SELECT Id,
                                                        BillNameatPrintLocal__c,
                                                        Name,
                                                        FMSBillID__c,
                                                        FMSBillID__r.Anken__c,
                                                        VesselFlight__c,
                                                        ETDETA__c,
                                                        POLAODPODAOA__c,
                                                        MBLNumber__c,
                                                        FMSShipmentOrderID__c,
                                                        HBLNumber__c,
                                                        ReferNumber__c,
                                                        JobRequestID__c,
                                                        UnitPriceofBuyingLocal__c,
                                                        UnitPriceofBuyingFCY__c,
                                                        ChargeQuantity__c, 
                                                        ChargeUnitinPrint__c,
                                                        FMSBillID__r.ChargeUnitFormula__c,
                                                        FMSBillID__r.ContainerSizeFormula__c,
                                                        TotalAmountofBuyingLocal__c,
                                                        TotalAmountofBuyingFCY__c,
                                                        AmountofTaxBuyingLocal__c,
                                                        AmountofTaxBuyingFCY__c, 
                                                        UnpaidBalanceOfBuyingUSDFormula__c,
                                                        UnpaidBalanceOfBuyingLocalFormula__c,
                                                        UnitPriceofSellingLocal__c,
                                                        UnitPriceofSellingFCY__c,
                                                        FMSBillID__r.PaymentTo__c, 
                                                        FMSBillID__r.Seikyusaki__c,
                                                        TotalAmountofSellingLocal__c,
                                                        AmountofTaxSellingLocal__c,
                                                        UnreceiveBalOfSellingLocalFormula__c,
                                                 		TotalAmountofSellingFCY__c,
                                                 		UnreceiveBalOfSellingUSDFormula__c,
                                                 		AmountofTaxSellingFCY__c
                                                    FROM FMSBillPayReq__c
                                                    WHERE PaymentRequestID__c =: paymentRequestId
                                                    ORDER BY FMSBillID__r.Anken__c];
        if(listBillPayReq.isEmpty()){
            return listResult;
        }
        Set<Id> shipmentIds = new Set<Id>();
        Set<Id> billIds = new Set<Id>();
        shipmentIds.add(listBillPayReq[0].FMSBillID__r.Anken__c);
        ShipmentWrapper shipmentItem =  new ShipmentWrapper();
        List<String> firstShipmentNames = new List<String>();
        if(listBillPayReq[0].FMSBillID__r.Anken__c != null && listBillPayReq[0].HBLNumber__c != null){
            firstShipmentNames.add(listBillPayReq[0].HBLNumber__c);
        }
        if(listBillPayReq[0].FMSBillID__r.Anken__c != null && listBillPayReq[0].ReferNumber__c != null){
            firstShipmentNames.add(listBillPayReq[0].ReferNumber__c);
        }
        if(listBillPayReq[0].FMSBillID__r.Anken__c != null && listBillPayReq[0].JobRequestID__c != null){
            firstShipmentNames.add(listBillPayReq[0].JobRequestID__c);
        }
        shipmentItem.shipmentName = String.join(firstShipmentNames, ' / ');
        shipmentItem.listBilling = new List<BillingWrapper>();
        for(FMSBillPayReq__c billReq : listBillPayReq){
            
            if(!shipmentIds.contains(billReq.FMSBillID__r.Anken__c)){

                listResult.add(shipmentItem);
                shipmentIds.add(billReq.FMSBillID__r.Anken__c);
                shipmentItem.caculateTotalAmount();
                total.totalPreTaxAmount += shipmentItem.totalAmount;
                total.totalVatAmount += shipmentItem.totalAmountTax;
                total.totalAmountIncludeTax += shipmentItem.totalAmountIncludeTax;
                total.totalPaidAmount += shipmentItem.totalPaidAmount;
                total.totalUnpaidAmount += shipmentItem.totalUnpaidAmount;
                shipmentItem = new ShipmentWrapper();
                List<String> shipmentNames = new List<String>();
                if(!String.isBlank(billReq.HBLNumber__c)){
                    shipmentNames.add(billReq.HBLNumber__c);
                }
                if(!String.isBlank(billReq.ReferNumber__c )){
                    shipmentNames.add(billReq.ReferNumber__c);
                }
                if(!String.isBlank(billReq.JobRequestID__c )){
                    shipmentNames.add(billReq.JobRequestID__c);
                }
                if(!String.isBlank(billReq.VesselFlight__c)){
                    shipmentNames.add(billReq.VesselFlight__c);
                    shipmentItem.flight = billReq.VesselFlight__c;
                }
                if(!String.isBlank(billReq.ETDETA__c )){
                    shipmentNames.add(billReq.ETDETA__c);
                    shipmentItem.etd = billReq.ETDETA__c;
                }
                if(!String.isBlank(billReq.POLAODPODAOA__c) ){
                    shipmentNames.add(billReq.POLAODPODAOA__c);
                    shipmentItem.pol = billReq.POLAODPODAOA__c;
                }
                if(!String.isBlank(billReq.MBLNumber__c) ){
                    shipmentNames.add(billReq.MBLNumber__c);
                    shipmentItem.mbl = billReq.MBLNumber__c;
                }
                shipmentItem.shipmentName = String.join(shipmentNames, ' / ');
                shipmentItem.listBilling = new List<BillingWrapper>();
            }
            if(shipmentIds.contains(billReq.FMSBillID__r.Anken__c)){
                if(!billIds.contains(billReq.FMSBillID__c)){
                    billIds.add(billReq.FMSBillID__c);
                    String type = 'payment';
                    if(paymentRequest.PaymentTo__c == billReq.FMSBillID__r.PaymentTo__c){
                        BillingWrapper billItem = new BillingWrapper(billReq, curr, type);
                        shipmentItem.listBilling.add(billItem);
                    }
                    if(paymentRequest.PaymentTo__c == billReq.FMSBillID__r.Seikyusaki__c){
                        type = 'invoice';
                        BillingWrapper billItem = new BillingWrapper(billReq, curr, type);
                        shipmentItem.listBilling.add(billItem);
                    }
                    
                }
            }
            
        }
        shipmentItem.caculateTotalAmount();
        listResult.add(shipmentItem);
        total.totalPreTaxAmount += shipmentItem.totalAmount;
        total.totalVatAmount += shipmentItem.totalAmountTax;
        total.totalAmountIncludeTax += shipmentItem.totalAmountIncludeTax;
        total.totalPaidAmount += shipmentItem.totalPaidAmount;
        total.totalUnpaidAmount += shipmentItem.totalUnpaidAmount;
        total.totalFinalAmount = total.totalUnpaidAmount - total.totalPaidAmount;
        return listResult;
    }

    private PaymentRequest__c getPaymentRequest(String paymentRequestId){
        
        List<PaymentRequest__c> paymentRequests = [SELECT Id, Name,
                                                    Currency__c,
                                                    PaymentTo__c,
                                                    PaymentTo__r.Name,
                                                    TransportType__c,
                                                    RequesterDepartment__c,
                                                    PaymentType__c,
                                                    PaymentDueDate__c,
                                                    NotesinDocument__c,
                                                    PaymentTo__r.BillingStreet, 
                                                    PaymentTo__r.BillingCity, 
                                                    PaymentTo__r.BillingState, 
                                                    PaymentTo__r.BillingPostalCode, 
                                                    PaymentTo__r.BillingCountry,
                                                    PaymentTo__r.CompanyShortName__c,
                                                    PaymentTo__r.Bank1__c,
                                                    PaymentTo__r.Bank2__c
                                                    FROM PaymentRequest__c
                                                    WHERE Id =: paymentRequestId];
        if(!paymentRequests.isEmpty()){
            return paymentRequests[0];
        }
        return new PaymentRequest__c();
    }
    public class TotalWrapper{
        public String curr;
        public Decimal totalPreTaxAmount{get; set;}
        public Decimal totalVatAmount{get; set;}
        public Decimal totalAmountIncludeTax{get; set;}
        public Decimal totalPaidAmount{get; set;}
        public Decimal totalUnpaidAmount{get; set;}
        public Decimal totalFinalAmount{get; set;}
        public TotalWrapper(){
            totalPreTaxAmount = 0;
            totalVatAmount = 0;
            totalAmountIncludeTax = 0;
            totalPaidAmount = 0;
            totalUnpaidAmount = 0;
            totalFinalAmount = 0;
        }
        public String getTotalPreTaxAmountStr(){
            if(totalPreTaxAmount == 0 || totalPreTaxAmount == null){
                return '0';
            }
            List<String> args = new String[]{'0','number','###.###.###.###'};
            if(curr=='VND'){
                return String.format(totalPreTaxAmount.format(), args);
            }else{
                args = new String[]{'0','number','###,###,###,###.###'};

                return String.format(totalPreTaxAmount.format(), args);
            }
        }
        public String getTotalVatAmountStr(){
            if(totalVatAmount == 0 || totalVatAmount == null){
                return '0';
            }
            List<String> args = new String[]{'0','number','###.###.###.###'};
            if(curr=='VND'){
                return String.format(totalVatAmount.format(), args);
            }else{
                args = new String[]{'0','number','###,###,###,###.###'};

                return String.format(totalVatAmount.format(), args);
            }

        }
        public String getTotalAmountIncludeTaxStr(){
            if(totalAmountIncludeTax == 0 || totalAmountIncludeTax == null){
                return '0';
            }
            List<String> args = new String[]{'0','number','###.###.###.###'};
            if(curr=='VND'){
                return String.format(totalAmountIncludeTax.format(), args);
            }else{
                args = new String[]{'0','number','###,###,###,###.###'};

                return String.format(totalAmountIncludeTax.format(), args);
            }

        }
        public String getTotalPaidAmountStr(){
            if(totalPaidAmount == 0 || totalPaidAmount == null){
                return '0';
            }
            
            List<String> args = new String[]{'0','number','###.###.###.###'};
            if(curr=='VND'){
                return String.format(totalPaidAmount.format(), args);
            }else{
                args = new String[]{'0','number','###,###,###,###.###'};

                return String.format(totalPaidAmount.format(), args);
            }

        }

        public String getTotalUnpaidAmountStr(){
            if(totalUnpaidAmount == 0 || totalUnpaidAmount == null){
                return '0';
            }
            
            List<String> args = new String[]{'0','number','###.###.###.###'};
            if(curr=='VND'){
                return String.format(totalUnpaidAmount.format(), args);
            }else{
                args = new String[]{'0','number','###,###,###,###.###'};

                return String.format(totalUnpaidAmount.format(), args);
            }

        }
        
        public String getTotalFinalAmountStr(){
            if(totalFinalAmount == 0 || totalFinalAmount == null){
                return '0';
            }
            
            List<String> args = new String[]{'0','number','###.###.###.###'};
            if(curr=='VND'){
                return String.format(totalFinalAmount.format(), args);
            }else{
                args = new String[]{'0','number','###,###,###,###.###'};

                return String.format(totalFinalAmount.format(), args);
            }

        }
        
        
    }

    
    public class ShipmentWrapper{
        public String shipmentName{get;set;}
        public List<BillingWrapper> listBilling{get; set;}
        public Decimal totalAmount{get; set;}
        public Decimal totalAmountTax{get; set;}
        public Decimal totalAmountIncludeTax{get; set;}
        public Decimal totalPaidAmount{get; set;}
        public Decimal totalUnpaidAmount{get; set;}
        public String flight{get; set;}
        public String etd{get; set;}
        public String pol{get; set;}
        public String mbl{get; set;}
        public ShipmentWrapper(){

        }
        public void caculateTotalAmount(){
            totalAmount = 0;
            totalAmountIncludeTax = 0;
            totalAmountTax = 0;
            totalPaidAmount = 0;
            totalUnpaidAmount = 0;
            for(BillingWrapper billingItem : listBilling){
                if(billingItem.type == 'payment'){
                    totalAmount += billingItem.amount == null? 0 : billingItem.amount;
                    totalAmountTax += billingItem.amountTax == null? 0 : billingItem.amountTax;
                    totalAmountIncludeTax += billingItem.amountIncludeTax == null? 0 : billingItem.amountIncludeTax;
                }
                if(billingItem.type == 'invoice'){
                    totalAmount -= billingItem.amount == null? 0 : billingItem.amount;
                    totalAmountTax -= billingItem.amountTax == null? 0 : billingItem.amountTax;
                    totalAmountIncludeTax -= billingItem.amountIncludeTax == null? 0 : billingItem.amountIncludeTax;
                }
                totalPaidAmount += billingItem.paidAmount == null? 0 : billingItem.paidAmount;
                totalUnpaidAmount += billingItem.unpaidAmount == null? 0 : billingItem.unpaidAmount;
            }
        }
    }
    
    public class BillingWrapper{
        public String billingName{get;set;}
        public Decimal unitPrice{get; set;}
        public String curr{get; set;}
        public String quantity{get; set;}
        public Decimal amount{get; set;}
        public Decimal amountTax{get; set;}
        public Decimal amountIncludeTax{get; set;}
        public Decimal paidAmount{get; set;}
        public Decimal unpaidAmount{get; set;}
        public String type{get; set;}
        public BillingWrapper(FMSBillPayReq__c billingRequest, String curr, String type){
            this.curr = curr;
            this.billingName = billingRequest.BillNameatPrintLocal__c;
            this.quantity = String.valueOf(billingRequest.ChargeQuantity__c);
            this.quantity += ' ' +  translateUnit(billingRequest);
            this.amount = 0;
            this.amountTax = 0;
            this.type = type;

            if(type == 'invoice'){
                this.unitPrice = billingRequest.UnitPriceofSellingLocal__c;
                this.amount = billingRequest.TotalAmountofSellingLocal__c == null? 0 : billingRequest.TotalAmountofSellingLocal__c;
                this.amountTax = billingRequest.AmountofTaxSellingLocal__c == null? 0 : billingRequest.AmountofTaxSellingLocal__c;
                this.paidAmount = billingRequest.UnreceiveBalOfSellingLocalFormula__c == null? 0 : billingRequest.UnreceiveBalOfSellingLocalFormula__c;
                if(curr == 'USD'){
                    this.unitPrice = billingRequest.UnitPriceofSellingFCY__c;
                    this.amount = billingRequest.TotalAmountofSellingFCY__c == null? 0 : billingRequest.TotalAmountofSellingFCY__c;
                    this.amountTax = billingRequest.AmountofTaxSellingFCY__c == null? 0 : billingRequest.AmountofTaxSellingFCY__c;
                    this.paidAmount = billingRequest.UnreceiveBalOfSellingUSDFormula__c == null? 0 : billingRequest.UnreceiveBalOfSellingUSDFormula__c;
                }
                this.amountincludeTax = amount + amountTax;
                //this.unpaidAmount = this.amountincludeTax - this.paidAmount;
            }

            if(type == 'payment'){
                
                this.unitPrice = billingRequest.UnitPriceofBuyingLocal__c;
                this.amount = billingRequest.TotalAmountofBuyingLocal__c == null? 0 : billingRequest.TotalAmountofBuyingLocal__c;
                this.amountTax = billingRequest.AmountofTaxBuyingLocal__c == null? 0 : billingRequest.AmountofTaxBuyingLocal__c;
                this.unpaidAmount = billingRequest.UnpaidBalanceOfBuyingLocalFormula__c == null? 0 : billingRequest.UnpaidBalanceOfBuyingLocalFormula__c;
                if(curr == 'USD'){
                    this.unitPrice = billingRequest.UnitPriceofBuyingFCY__c;
                    this.amount = billingRequest.TotalAmountofBuyingFCY__c == null? 0 : billingRequest.TotalAmountofBuyingFCY__c;
                    this.amountTax = billingRequest.AmountofTaxBuyingFCY__c == null? 0 : billingRequest.AmountofTaxBuyingFCY__c;
                    this.unpaidAmount = billingRequest.UnpaidBalanceOfBuyingUSDFormula__c == null? 0 : billingRequest.UnpaidBalanceOfBuyingUSDFormula__c;
                }
                this.amountincludeTax = amount + amountTax;
                //this.paidAmount = amountincludeTax - unpaidAmount;
            }
            
            
            
            
        }

        private String translateUnit(FMSBillPayReq__c billingRequest){
            String unit = billingRequest.FMSBillID__r.ChargeUnitFormula__c;
            if(billingRequest.FMSBillID__r.ChargeUnitFormula__c =='本'){
                    unit = 'Unit';
                } 
            if(billingRequest.FMSBillID__r.ChargeUnitFormula__c =='コンテナ' || billingRequest.FMSBillID__r.ChargeUnitFormula__c =='Container'){
                unit = billingRequest.FMSBillID__r.ContainerSizeFormula__c;
                if(String.isBlank(unit)){
                    unit = 'Container';
                }
            }
            if(billingRequest.FMSBillID__r.ChargeUnitFormula__c =='件'){
                unit = 'Case';
            }
            return unit;
        }
        public String getAmountStr(){
            if(amount == 0 || amount == null){
                return '0';
            }
            List<String> args = new String[]{'0','number','###.###.###.###'};
            if(curr=='VND'){
                return String.format(amount.format(), args);
            }else{
                args = new String[]{'0','number','###,###,###,###.###'};

                return String.format(amount.format(), args);
            }
        }
        public String getAmountTaxStr(){
            if(amountTax == 0 || amountTax == null){
                return '0';
            }
            List<String> args = new String[]{'0','number','###.###.###.###'};
            if(curr=='VND'){
                return String.format(amountTax.format(), args);
            }else{
                args = new String[]{'0','number','###,###,###,###.###'};

                return String.format(amountTax.format(), args);
            }

        }
        public String getAmountIncludeTaxStr(){
            if(amountIncludeTax == 0 || amountIncludeTax == null){
                return '0';
            }
            List<String> args = new String[]{'0','number','###.###.###.###'};
            if(curr=='VND'){
                return String.format(amountIncludeTax.format(), args);
            }else{
                args = new String[]{'0','number','###,###,###,###.###'};

                return String.format(amountIncludeTax.format(), args);
            }

        }
        public String getPaidAmountStr(){
            if(paidAmount == 0 || paidAmount == null){
                return '0';
            }
            
            List<String> args = new String[]{'0','number','###.###.###.###'};
            if(curr=='VND'){
                return String.format(paidAmount.format(), args);
            }else{
                args = new String[]{'0','number','###,###,###,###.###'};

                return String.format(paidAmount.format(), args);
            }

        }

        public String getUnpaidAmountStr(){
            if(unpaidAmount == 0 || unpaidAmount == null){
                return '0';
            }
            
            List<String> args = new String[]{'0','number','###.###.###.###'};
            if(curr=='VND'){
                return String.format(unpaidAmount.format(), args);
            }else{
                args = new String[]{'0','number','###,###,###,###.###'};

                return String.format(unpaidAmount.format(), args);
            }

        }
    }
}