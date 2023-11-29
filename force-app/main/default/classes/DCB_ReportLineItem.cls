public class DCB_ReportLineItem {
    public String hblId {get;set;}
    public String sisid {get; set;}
    public String customerName {get;set;}
    public String customerEnglishName {get;set;}
    public String wkid {get;set;}
    public String invoiceNo {get;set;}
    public String shipNumber {get;set;}
    public String hblNo {get;set;}
    public String status {get;set;}
    public String mblNo {get;set;}
    public Decimal suryo {get; set;}
    public Date deadlinePaymentInvoice {get;set;}
    public Date deadlinePaymentExpense {get;set;}
    public Date deliveryDate {get;set;}
    public Decimal carton {get;set;}
    public Date etd {get;set;}
    public Date eta {get;set;}
    public Date salesAccountDate {get; set;}
    public String dueDatePayment {get;set;}
    public String dueDateAdvancePayment {get;set;}
    
    public String description {get; set;}
    public String name {get; set;}
    public Id id {get; set;}
    public Date salesAccountedDateInvoicing {get; set;}
    public String insatuyouSyohin {get; set;}
    public String seikyusakiName {get; set;}
    public String paymentToName {get; set;}
    
    public Decimal credit {get;set;}
    public Decimal debit {get;set;}
    public Decimal balance {get;set;}
    
    public Decimal creditUSD {get;set;}
    public Decimal debitUSD {get;set;}
    public Decimal balanceUSD {get;set;}
    
    public Decimal sumOfAmountSelling {get;set;}
    public Decimal sumOfAmountBuying {get;set;}
    public Decimal sumOfUnPaidBalance {get;set;}
    
    public Decimal sumOfAmountSellingUSD {get;set;}
    public Decimal sumOfAmountBuyingUSD {get;set;}
    public Decimal sumOfUnPaidBalanceUSD {get;set;}
    
    public Decimal sumOfCredit {get;set;}
    public Decimal sumOfDebit {get;set;}
    public Decimal sumOfBalance {get;set;}
    
    public Decimal sumOfCreditUSD {get;set;}
    public Decimal sumOfDebitUSD {get;set;}
    public Decimal sumOfBalanceUSD {get;set;}
    
    public Integer recordCount {get;set;}
    public String stid {get;set;}
    public String remarks {get;set;}
    
    public DCB_ReportLineItem(String customerName, String customerEnglishName, String stid) {
        this.customerName = customerName;
        this.customerEnglishName = customerEnglishName;
        this.stid = stid;
        this.suryo = 0;
        
        this.credit = 0;
        this.debit = 0;
        this.balance = 0;
        this.creditUSD = 0;
        this.debitUSD = 0;
        this.balanceUSD = 0;
        
        this.sumOfAmountSelling = 0;
        this.sumOfAmountBuying = 0;
        this.sumOfUnPaidBalance = 0;
        
        this.sumOfAmountSellingUSD = 0;
    	this.sumOfAmountBuyingUSD = 0;
    	this.sumOfUnPaidBalanceUSD = 0;
        
        this.sumOfCredit = 0;
        this.sumOfDebit = 0;
        this.sumOfBalance = 0;
        this.sumOfCreditUSD = 0;
        this.sumOfDebitUSD = 0;
        this.sumOfBalanceUSD = 0;
        this.recordCount = 0;
    }
    
    public void printDebug() {
    }
}