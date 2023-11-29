public class ReportWrapper {
    public String partnerName {get;set;} //Contain partnerName
    public String partnerEnglishName {get;set;} //Contain partnerName
    public Decimal totalDebit {get;set;} //total debit for each partner
    public Decimal totalCredit {get;set;} //total credit for each partner
    public Decimal totalBalance {get;set;} //total balance for each partner
    public Decimal partnerQuantity {  //total STID of a partner
        get {
            Decimal i = 0;
            if (!lstSTID.isEmpty()) {
                for (ReportDetailWrapper item : lstSTID) {
                    i += item.myQuantity;
                }
            }  
            return i;
        }
        set;
    } 
    
    Map<String,ReportDetailWrapper> mapTemp;
    
    //List to contain the STID detail for each partner, get data from mapSTID, using to display on report
    public List<ReportDetailWrapper> lstSTID {
        get {
            List<ReportDetailWrapper> lstTemp = new List<ReportDetailWrapper>();
            
            if (!mapTemp.isEmpty()) {
                Decimal i = 1;
                for (ReportDetailWrapper item : mapTemp.values()) {
                    item.index = i;
                    lstTemp.add(item);
                    i++;
                }
            }
            return lstTemp;
        }
    }
    
    //Constructor
    public ReportWrapper(){
        mapTemp = new Map<String,ReportDetailWrapper>();
        totalDebit = 0;
        totalCredit = 0;
        totalBalance = 0;
        partnerQuantity = 0;
    }
    
    public void setPartnerData(String stid, Decimal debit, Decimal credit,String wkid,
                               String hbl, String mbl,String eta, String etd, String status, String hblId, String sisid) {   
		Decimal balance = (debit - credit);

        if (mapTemp.containsKey(stid)) {
            mapTemp.get(stid).debit += debit;
            mapTemp.get(stid).credit += credit;
            mapTemp.get(stid).balance += balance;
            mapTemp.get(stid).myQuantity +=1;
        }
        else {
            ReportDetailWrapper temp = new ReportDetailWrapper();
            temp.myQuantity = 1;
            setSTIDData(temp,stid,debit,credit,balance,wkid,hbl,mbl,eta,etd, status, hblId, sisid);
            mapTemp.put(stid, temp);
        }
        totalDebit += debit;
        totalCredit += credit;
        totalBalance += balance;
    }
    
    private void setSTIDData(ReportDetailWrapper temp,String stid, Decimal debit, Decimal credit, 
                             Decimal balance,String wkid,String hbl, String mbl,String eta, String etd, 
                             String status, String hblId, String sisid) {
        temp.stid = stid;
        temp.debit = debit;
        temp.credit = credit;
        temp.balance = balance;
        temp.wkid = wkid;
        temp.hbl = hbl;
        temp.mbl = mbl;
        temp.eta = eta;
        temp.etd = etd;
        temp.status = status;
		temp.hblId = hblId;
        temp.sisid = sisid;
    }
}