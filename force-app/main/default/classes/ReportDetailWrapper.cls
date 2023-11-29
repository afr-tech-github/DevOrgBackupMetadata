public class ReportDetailWrapper {
    public String stid {get;set;}
    public Decimal debit {get;set;}
    public Decimal credit {get;set;}
    public Decimal balance {get;set;}
    public Decimal index {get;set;}
    public Decimal myQuantity {get;set;}
    public String wkid {get;set;}
    public String hbl {get;set;}
    public String mbl {get;set;}
    public String eta {get;set;}
    public String etd {get;set;}
    public String status {get;set;}
    public String hblId {get; set;}
    public String sisid {get; set;}
    
    public ReportDetailWrapper() {
        sisid = '';
        wkid = '';
        eta = '';
        etd = '';
        hbl = '';
        mbl = '';
        stid = '';
        debit = 0;
        credit = 0;
        balance = 0;
        myQuantity = 0;
        index = 1;
    }
}