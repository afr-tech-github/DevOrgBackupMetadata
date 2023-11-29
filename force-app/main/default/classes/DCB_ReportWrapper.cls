public class DCB_ReportWrapper {
    public List<DCB_SubReportWrapper> customerReports {get; private set;}
    public Decimal sumOfAmountSelling {get;set;}
    public Decimal sumOfAmountBuying {get;set;}
    public Decimal sumOfUnPaidBalance {get;set;}
    public Decimal sumOfCredit {get;set;}
    public Decimal sumOfDebit {get;set;}
    public Decimal sumOfBalance {get;set;}
    
    public Decimal sumOfAmountSellingUSD {get; set;}
    public Decimal sumOfAmountBuyingUSD {get; set;}
    public Decimal sumOfUnPaidBalanceUSD {get; set;}
    public Decimal sumOfCreditUSD {get; set;}
    public Decimal sumOfDebitUSD {get; set;}
    public Decimal sumOfBalanceUSD {get; set;}
    
    public DCB_ReportWrapper() {
        customerReports = new List<DCB_SubReportWrapper>();
        sumOfAmountSelling = 0;
        sumOfAmountBuying = 0;
        sumOfUnPaidBalance = 0;
        sumOfCredit = 0;
        sumOfDebit = 0;
        sumOfBalance = 0;
        
        sumOfAmountSellingUSD = 0;
        sumOfAmountBuyingUSD = 0;
        sumOfUnPaidBalanceUSD = 0;
        sumOfCreditUSD = 0;
        sumOfDebitUSD = 0;
        sumOfBalanceUSD = 0;
    }
    
    public void addCustomerReport(DCB_SubReportWrapper report) {
        customerReports.add(report);
        sumOfAmountSelling += report.sumOfAmountSelling;
        sumOfAmountBuying += report.sumOfAmountBuying;
        sumOfUnPaidBalance += report.sumOfUnPaidBalance;
        sumOfCredit += report.sumOfCredit;
        sumOfDebit += report.sumOfDebit;
        sumOfBalance += report.sumOfBalance;
        
        sumOfAmountSellingUSD += report.sumOfAmountSellingUSD;
        sumOfAmountBuyingUSD += report.sumOfAmountBuyingUSD;
        sumOfUnPaidBalanceUSD += report.sumOfUnPaidBalanceUSD;
        sumOfCreditUSD += report.sumOfCreditUSD;
        sumOfDebitUSD += report.sumOfDebitUSD;
        sumOfBalanceUSD += report.sumOfBalanceUSD;
    }
}