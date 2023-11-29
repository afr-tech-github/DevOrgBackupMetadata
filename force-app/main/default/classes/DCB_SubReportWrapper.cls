public class DCB_SubReportWrapper {
    public String customerId {get;set;}
    public String customerName {get;set;}
    public String customerEnglishName {get;set;}
    public Date deadlinePaymentInvoice {get;set;}
    public Date deadlinePaymentExpense {get;set;}
    public Decimal sumOfAmountSelling {get;set;}
    public Decimal sumOfAmountBuying {get;set;}
    public Decimal sumOfUnPaidBalance {get;set;}
    public Decimal sumOfCredit {get;set;}
    public Decimal sumOfDebit {get;set;}
    public Decimal sumOfBalance {get;set;}
    
    public Decimal sumOfAmountSellingUSD {get;set;}
    public Decimal sumOfAmountBuyingUSD {get;set;}
    public Decimal sumOfUnPaidBalanceUSD {get;set;}
    public Decimal sumOfCreditUSD {get;set;}
    public Decimal sumOfDebitUSD {get;set;}
    public Decimal sumOfBalanceUSD {get;set;}
    
    public List<DCB_ReportLineItem> lineItems {get;private set;}
    public Integer recordCount {get;set;}
    
    public DCB_SubReportWrapper(String customerName, String customerEnglishName, String customerId) {
        this.customerName = customerName;
        this.customerEnglishName = customerEnglishName;
        this.customerId = customerId;
        this.sumOfAmountSelling = 0;
        this.sumOfAmountBuying = 0;
        this.sumOfUnPaidBalance = 0;
        this.sumOfCredit = 0;
        this.sumOfDebit = 0;
        this.sumOfBalance = 0;
        
        this.sumOfAmountSellingUSD = 0;
        this.sumOfAmountBuyingUSD = 0;
        this.sumOfUnPaidBalanceUSD = 0;
        this.sumOfCreditUSD = 0;
        this.sumOfDebitUSD = 0;
        this.sumOfBalanceUSD = 0;
        this.recordCount = 0;
        this.lineItems = new List<DCB_ReportLineItem>();
    }
    
    public void addLineItems(List<DCB_ReportLineItem> items) {
        if (items != null) {
            for (DCB_ReportLineItem item : items) {
                lineItems.add(item);
                recordCount++;
                sumOfAmountSelling += item.sumOfAmountSelling;
                sumOfAmountBuying += item.sumOfAmountBuying;
                sumOfUnPaidBalance += item.sumOfUnPaidBalance;
                sumOfCredit += item.sumOfCredit;
                sumOfDebit += item.sumOfDebit;
                sumOfBalance += item.sumOfBalance;
                
                sumOfAmountSellingUSD += item.sumOfAmountSellingUSD;
                sumOfAmountBuyingUSD += item.sumOfAmountBuyingUSD;
                sumOfUnPaidBalanceUSD += item.sumOfUnPaidBalanceUSD;
                sumOfCreditUSD += item.sumOfCreditUSD;
                sumOfDebitUSD += item.sumOfDebitUSD;
                sumOfBalanceUSD += item.sumOfBalanceUSD;

                if (deadlinePaymentInvoice == null) {
                	deadlinePaymentInvoice = item.deadlinePaymentInvoice;
                }
                
                if (deadlinePaymentExpense == null) {
                	deadlinePaymentExpense = item.deadlinePaymentExpense;
                }
            }
        }
    }
}