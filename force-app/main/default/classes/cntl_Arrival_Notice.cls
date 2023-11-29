public with sharing class cntl_Arrival_Notice {
    public CustomObject1__c AnkenList {get;set;}
    public List<AnkenMeisai__c> ItemList {get;set;}
    public Map<Integer, List<AnkenMeisai__c>> ItemList2 {get;set;}
    public List<Integer> PageList {get;set;}
    public Decimal TotalAmount   {get;set;}
    public Decimal TotalAmountUSD   {get;set;}
    public Map<String, String> translations {get; private set;}
    public Map<String, Object> Labels {get; private set;}
    public Map<String, Decimal> mapTotalAmountByCurr {get; set;}
    public String containerAltText {get; private set;}
    public boolean ShowTaxCol {get; private set;}
    public Integer numberOfRowsTotal {get;set;}
    public List<List<String>> lstCurrs {get;set;}
    public String companyAddress {get; set;}
    public boolean isBreakPage {get; set;}
    public String foreignCur {get; set;}
    public String localCur {get; set;}
    public clofor_com_cfs__Site_Custom_Settings__c banks {get;set;}
    public String bankName {get; set;}
    public String bankNumber {get; set;}
    public String bankAccount {get; set;}


    private String AnkenID;
    private String reportName;
    private String pageName;
    private String language;
    private String bank;
    private Integer CONTAINER_SEAL_NO_MAX_LENGTH = 100;
    private Integer MAX_LINE_ITEM_NUMBER = 20;
    public Decimal SumLocal {get;set;}
    public Decimal SumFCY {get; set;}

    public cntl_Arrival_Notice(){
        clofor_com_cfs__Site_Custom_Settings__c customSettings = [
            SELECT clofor_com_cfs__FCY_Currency__c,
            clofor_com_cfs__Local_Currency__c
            FROM clofor_com_cfs__Site_Custom_Settings__c limit 1];

        clofor_com_cfs__Site_Custom_Settings__c banks = [
            SELECT 
            clofor_com_cfs__Local_Bank_Name_1__c,
            clofor_com_cfs__Local_Bank_Name_2__c,
            clofor_com_cfs__Local_Bank_Name_3__c,
            clofor_com_cfs__Local_Bank_Name_4__c,
            clofor_com_cfs__Local_Bank_Name_5__c,
            clofor_com_cfs__Local_Account_No_1__c,
            clofor_com_cfs__Local_Account_No_2__c,
            clofor_com_cfs__Local_Account_No_3__c,
            clofor_com_cfs__Local_Account_No_4__c,
            clofor_com_cfs__Local_Account_No_5__c,
            clofor_com_cfs__Local_Bank_Account_1__c,
            clofor_com_cfs__Local_Bank_Account_2__c,
            clofor_com_cfs__Local_Bank_Account_3__c,
            clofor_com_cfs__Local_Bank_Account_4__c,
            clofor_com_cfs__Local_Bank_Account_5__c,
            clofor_com_cfs__Foreign_Bank_Name_1__c,
            clofor_com_cfs__Foreign_Bank_Name_2__c,
            clofor_com_cfs__Foreign_Bank_Name_3__c,
            clofor_com_cfs__Foreign_Bank_Name_4__c,
            clofor_com_cfs__Foreign_Bank_Name_5__c,
            clofor_com_cfs__Foreign_Account_No_1__c,
            clofor_com_cfs__Foreign_Account_No_2__c,
            clofor_com_cfs__Foreign_Account_No_3__c,
            clofor_com_cfs__Foreign_Account_No_4__c,
            clofor_com_cfs__Foreign_Account_No_5__c,
            clofor_com_cfs__Foreign_Bank_Account_1__c,
            clofor_com_cfs__Foreign_Bank_Account_2__c,
            clofor_com_cfs__Foreign_Bank_Account_3__c,
            clofor_com_cfs__Foreign_Bank_Account_4__c,
            clofor_com_cfs__Foreign_Bank_Account_5__c
            FROM clofor_com_cfs__Site_Custom_Settings__c]; 
        
        SumLocal = 0;
        SumFCY = 0;     
        foreignCur = customSettings.clofor_com_cfs__FCY_Currency__c;
        localCur = customSettings.clofor_com_cfs__Local_Currency__c;
        this.ShowTaxCol = false;
        isBreakPage = false;
        GetURLPram();
        if(bank == 'local1') {
            bankName = banks.clofor_com_cfs__Local_Bank_Name_1__c;
            bankNumber = banks.clofor_com_cfs__Local_Account_No_1__c;
            bankAccount = banks.clofor_com_cfs__Local_Bank_Account_1__c;
        }
        if(bank == 'local2') {
            bankName = banks.clofor_com_cfs__Local_Bank_Name_2__c;
            bankNumber = banks.clofor_com_cfs__Local_Account_No_2__c;
            bankAccount = banks.clofor_com_cfs__Local_Bank_Account_2__c;
        }
        if(bank == 'local3') {
            bankName = banks.clofor_com_cfs__Local_Bank_Name_3__c;
            bankNumber = banks.clofor_com_cfs__Local_Account_No_3__c;
            bankAccount = banks.clofor_com_cfs__Local_Bank_Account_3__c;
        }
        if(bank == 'local4') {
            bankName = banks.clofor_com_cfs__Local_Bank_Name_4__c;
            bankNumber = banks.clofor_com_cfs__Local_Account_No_4__c;
            bankAccount = banks.clofor_com_cfs__Local_Bank_Account_4__c;
        }
        if(bank == 'local5') {
            bankName = banks.clofor_com_cfs__Local_Bank_Name_5__c;
            bankNumber = banks.clofor_com_cfs__Local_Account_No_5__c;
            bankAccount = banks.clofor_com_cfs__Local_Bank_Account_5__c;
        }

        if(bank == 'foreign1') {
            bankName = banks.clofor_com_cfs__Foreign_Bank_Name_1__c;
            bankNumber = banks.clofor_com_cfs__Foreign_Account_No_1__c;
            bankAccount = banks.clofor_com_cfs__Foreign_Bank_Account_1__c;
        }   
        if(bank == 'foreign2') {
            bankName = banks.clofor_com_cfs__Foreign_Bank_Name_2__c;
            bankNumber = banks.clofor_com_cfs__Foreign_Account_No_2__c;
            bankAccount = banks.clofor_com_cfs__Foreign_Bank_Account_2__c;
        }  
        if(bank == 'foreign3') {
            bankName = banks.clofor_com_cfs__Foreign_Bank_Name_3__c;
            bankNumber = banks.clofor_com_cfs__Foreign_Account_No_3__c;
            bankAccount = banks.clofor_com_cfs__Foreign_Bank_Account_3__c;
        }  
        if(bank == 'foreign4') {
            bankName = banks.clofor_com_cfs__Foreign_Bank_Name_4__c;
            bankNumber = banks.clofor_com_cfs__Foreign_Account_No_4__c;
            bankAccount = banks.clofor_com_cfs__Foreign_Bank_Account_4__c;
        }  
        if(bank == 'foreign5') {
            bankName = banks.clofor_com_cfs__Foreign_Bank_Name_5__c;
            bankNumber = banks.clofor_com_cfs__Foreign_Account_No_5__c;
            bankAccount = banks.clofor_com_cfs__Foreign_Bank_Account_5__c;
        }
        mapTotalAmountByCurr = new Map<String, Decimal>();
        lstCurrs = new List<List<String>>();
        ItemList = new List<AnkenMeisai__c>();
        /*
        if (PermissionValidationUtil.isAccessibleHBL() && PermissionValidationUtil.isAccessibleHBLBuying()
           && PermissionValidationUtil.isAccessibleAccount() && PermissionValidationUtil.isAccessiblePort()
           && PermissionValidationUtil.isAccessibleServiceMaster() && PermissionValidationUtil.isAccessibleWarehouse()) {
            
        }
        */
        GetAnkenList();
        GetAnkenMeisai();
        SetMapTotalAmountByCurr();

        initializeTranslation();
        
        // Get company address from Metadata Company_Address__mdt
        Site_Metadata_Types__mdt recordCompanyAdrress = [Select Address__c From Site_Metadata_Types__mdt limit 1];
        if(recordCompanyAdrress?.Address__c != null){
            companyAddress = recordCompanyAdrress.Address__c;
        }
        
        //handle break page
        Integer pageCount;
        if(this.ItemList.size()<=10){
            pageCount =0;
            isBreakPage = false;
        }else if(this.ItemList.size() > 10 && this.ItemList.size() <= 20){
            pageCount =0;
            isBreakPage = true;
        } else{
            pageCount = Integer.valueOf(Math.ceil((decimal)this.ItemList.size() / (decimal)MAX_LINE_ITEM_NUMBER));
            isBreakPage = false;
        }
        
        this.ItemList2 = new Map<Integer, List<AnkenMeisai__c>>();
        this.PageList = new List<Integer> ();

        if (pageCount == 0){
            pageCount = 1;
        }
        for (Integer i = 1; i <= pageCount; i++) {
            this.PageList.add(i);
            List<AnkenMeisai__c> temp = new List<AnkenMeisai__c>();
            for (Integer j = 0; j < MAX_LINE_ITEM_NUMBER; j++) {
                Integer itemIdx = (i - 1) * MAX_LINE_ITEM_NUMBER + j;
                if (itemIdx < this.ItemList.size()) {
                    temp.add(this.ItemList[itemIdx]);
                }
            }
            this.ItemList2.put(i, temp);
        }
    }

    public String getDateFormat() {
        return DateTimeUtils.getDateFormat();
    }
    
    public String getTruncatedContainerSealNumbers() {
        
        /*
        if (AnkenList != null) {
            if (AnkenList.ContainerSealNo__c != null && AnkenList.ContainerSealNo__c.length() > CONTAINER_SEAL_NO_MAX_LENGTH) {
                return AnkenList.ContainerSealNo__c.substring(0, CONTAINER_SEAL_NO_MAX_LENGTH) + '...';
            } else {
                return AnkenList.ContainerSealNo__c;
            }
        }
		*/
        return null;
    }
	
    public String getFullContainerSealNumbers() {
        /*
        if (AnkenList != null && AnkenList.ContainerSealNo__c != null && AnkenList.ContainerSealNo__c.length() > CONTAINER_SEAL_NO_MAX_LENGTH) {
            return AnkenList.ContainerSealNo__c;
        }
		*/
        String temp;
        if(AnkenList != null && AnkenList.CONTAINERSEALNO__c != null) {
            temp = (AnkenList.CONTAINERSEALNO__c).replaceAll('/<missing>', '');
            While(temp.right(1) == '<missing>' || temp.right(1) == '/') {
                temp = temp.right(1) == '/' ? temp.removeEnd('/') : temp.removeEnd('<missing>');
            }
            return temp;
        }
        return null;
    }

    private void GetURLPram() {
        AnkenID = ApexPages.currentPage().getParameters().get(Constants.REQUEST_ID);
        reportName = ApexPages.currentPage().getParameters().get(Constants.REQUEST_REPORT_NAME);
        language = ApexPages.currentPage().getParameters().get(Constants.REQUEST_LANGUAGE);
        bank = ApexPages.currentPage().getParameters().get('bank');
        // Get Page name 
        pageName = ApexPages.CurrentPage().getUrl();
        pageName = pageName.replaceFirst('/apex/','');
        pageName = EncodingUtil.urlEncode(pageName, 'UTF-8');
        String[] pageNameExtra = pageName.split('%3F', 0);
        pageName = pageNameExtra[0];
    }

    private void initializeTranslation() {
        TranslationService service = new TranslationService('Invoice', language);
        translations = service.getTranslations();

        if (translations.get('CONTAINER_NO_ATL_TEXT') != null) {
            containerAltText = translations.get('CONTAINER_NO_ATL_TEXT');
        } else {
            containerAltText = 'A part of Container/Seal Number' + translations.get('CONTAINER_NO_ATL_TEXT');
        }

        this.Labels = TranslationService.getByLanguage(this.Language);
    }

    private void GetAnkenList() {
        AnkenList = [
            SELECT
                ID,
                ShipperEnglishCompanyName__c,       //Shipper名
                shipper__r.EnglishCompanyName__c,
                shipper__r.EnglishAddress__c,
                Vessle__c,                          //船・便名(VESSEL/FLIGHT)
                Voy_No__c,                          //VOY NO
                HBL__c,                             //House B/L番号(No.)
                Master_B_L__c,                      //Master B/L番号(No.)
                ConsigneeEnglishCompanyName__c,     //Consignee English Company Name&Address
                Cnee__r.EnglishCompanyName__c,
                Cnee__r.EnglishAddress__c,
                POL__r.City_Name__c,
                POL__r.Country_Name__c,
                POL__r.Name,
                POL__r.JURISDICTION_CUSTOMS__c,
                Place_of_Delivery__r.Name,
                Place_of_Delivery__r.City_Name__c,
                Place_of_Delivery__r.Country_Name__c,
                Place_of_Delivery__r.JURISDICTION_CUSTOMS__c,
                POD__r.City_Name__c,
                POD__r.Country_Name__c,
                POD__r.Name,
                POD__r.JURISDICTION_CUSTOMS__c,
                ETA__c,                             //入港日(ETA)
                ETD__c,                             //出港日(ETD)
                NotifyPartyEnglishCompanyName__c,   //Notify Party English Company Name&Addres
                Notifyparty__r.EnglishCompanyName__c,
                Notifyparty__r.EnglishAddress__c,
                carton__c,                          //個数(QUANTITY)
                UnitType__c,                        //種類(UNIT TYPE)
                weight__c,                          //重量(WEIGHT)
                CBM__c,                             //体積(CBM)
                Marks_and_Numbers__c,               //Marks and Numbers
                Item__c,                            //商品(ITEM)
                ContainerSeal_No__c,                //Container/Seal No (OLD)
                //ContainerSealNo__c,                //Container/Seal No (NEW SINCE 2016/12/17)
                TransitV__c,                        //TRANSIT VESSEL
                No_Of_LoadingConfirmation__c,       //搬入確認番号
                BLtype__c,                          //BLtype
                ExchangeRate__c,                    //★為替レート
                TotalInvoicesArePaid__c,            //請求入金額
                Name,                               //WKID
                WkInitial__c,
                QuotationVer__c,
                recordtype.name,
                PrintDate__c,
                Container__c,                       //コンテナタイプ
                ContainerNumber__c,                 //コンテナサイズ１
                Container2__c,                      //コンテナタイプ2
                ContainerNumber2__c,                //コンテナサイズ２
                Container3__c,
                ContainerNumber3__c,
                Container4__c,
                ContainerNumber4__c,
                TS__c,                              //TS（トランジット港）
                LoadAddressContact__c,              //搬入先住所及び連絡先
                LoadLocation__r.LoadAddress__c,
                LoadLocation__r.LoadTEL__c,
                LoadLocation__r.LoadFAX__c,
                LoadLocation_Remarks__c,            //搬入場所Remarks
                LoadLocationPIC__c,                 //搬入先担当者
                LoadLocation__r.name,               //搬入場所
                PersonInCharge__r.Name,              //営業担当者
                FreeDemurrageTime__c,
                FreeDetentionTime__c,
                Remarks__c,
                Exchange_Currency__c,
                chargable_weight__c,
                FlightNo__c,
                HAWB__c,
                MAWB__c,
                Sum_Of_GROSS_WEIGHT__c,
                Sum_Of_NET_WEIGHT__c,
                Sum_Of_QUANTITY_PACKAGES__c,
                Sum_Of_MEASUREMENT_CBM__c,
                CARGO_TYPE__c,
                TranporationType__c,
            	ADDRESS_ON_B_L__c,
            	CNEE_ADDRESS_ON_B_L__c,
            	NOTIFY_ADDRESS_ON_B_L__c,
            	GoodsDescriptiononAN__c,
            	ANRemark__c,
            	JobRequestID__c,
            	PortOfLoadingDetailPrint__c,
            	PortOfDischargeDetailPrint__c,
            	PlaceOfDeliveryDetailPrint__c,
            	CONTAINERSEALNO__c
            FROM
                CustomObject1__c
            WHERE
                ID = :AnkenID
        ];

        if (Constants.IV_DELIVERY_ORDER.equalsIgnoreCase(reportName)) {
            if (!StringUtils.isEmpty(AnkenList.ContainerSeal_No__c)) {
                AnkenList.ContainerSeal_No__c = ContainerInfoService.extractContainerNo(AnkenList.ContainerSeal_No__c);
            }
        }
    }
    
    private void SetMapTotalAmountByCurr() {
        List <String> lstTemp = new List <String>();
        List<AggregateResult> lstTotalByCurr = [SELECT 
                                curr__c curr            
                                FROM
                                AnkenMeisai__c
                                WHERE
                                Anken__c = :AnkenList.id AND PrintFlag__c = true
                                AND Seikyusaki__c != :null AND (SellInTaxAmountJPY__c != :null OR SellInTaxAmount_USD__c != :null)
                                AND curr__c != :null
                                GROUP BY curr__c
                               ];
        
        // Remove the item and amount with TorihikisakiLink__c != Seikyusaki__c
        for(AggregateResult totalItem: lstTotalByCurr) {
            Decimal sumOtherAmount = 0;
            Decimal sumUSDAmount = 0;
            for(AnkenMeisai__c item: itemList) {
                String unitCurrency = (String)totalItem.get('curr');
                if(item.curr__c == unitCurrency) {
                    if ((pageName == 'clofor_com_cfs__AirPortraitArrivalNoticeENG' || pageName == 'clofor_com_cfs__OceanPortraitArrivalNoticeENG')) {
                        if(unitCurrency == 'USD') {
                            sumUSDAmount += item.SellInTaxAmount_USD__c;
                        } else if (unitCurrency == 'VND' && item.SellInTaxAmountJPY__c != null && item.SellInTaxAmountJPY__c != 0) {
                            sumOtherAmount += item.SellInTaxAmountJPY__c;
                        }
                    } else {
                        if(unitCurrency == 'USD') {
                            sumUSDAmount += item.SellInTaxAmount_USD__c;
                        } else if (unitCurrency != foreignCur && unitCurrency != localCur && item.AmountSellingInclTax3rdCurrency__c != null && item.AmountSellingInclTax3rdCurrency__c != 0) {
                            sumOtherAmount += item.AmountSellingInclTax3rdCurrency__c;
                        } else if (unitCurrency == localCur && item.SellInTaxAmountJPY__c != null && item.SellInTaxAmountJPY__c != 0) {
                            sumOtherAmount += item.SellInTaxAmountJPY__c;
                        }
                        
                    }
                    
                        SumLocal += item.SellInTaxAmountJPY__c;
                    
                    
                        SumFCY += item.SellInTaxAmount_USD__c;
                    
                }
            }

            if((String)totalItem.get('curr') == 'USD' && sumUSDAmount != 0) {
                mapTotalAmountByCurr.put((String)totalItem.get('curr'), sumUSDAmount);
            } else if((String)totalItem.get('curr') != 'USD' && sumOtherAmount != 0) {
                mapTotalAmountByCurr.put((String)totalItem.get('curr'), sumOtherAmount);
            }  
        }
        
        for(String keyItem: mapTotalAmountByCurr.keySet()) {
            lstTemp.add(keyItem);
            if(lstTemp.size() ==3){
                lstCurrs.add(lstTemp.clone());
                lstTemp.clear();
            }  
        }
        if(lstTemp.size() <3 && lstTemp.size()>0) {
            lstCurrs.add(lstTemp.clone());
        }
        if((mapTotalAmountByCurr.size() / 3)*3 == mapTotalAmountByCurr.size()) {
            numberOfRowsTotal = mapTotalAmountByCurr.size() / 3;
        }else {
            numberOfRowsTotal = mapTotalAmountByCurr.size() / 3 + 1;
        }

    }

    private void GetAnkenMeisai() {
        List<AnkenMeisai__c> itemListTemp = [
            SELECT ID,                             //salesforceID
                    CreatedDate,                    //作成日
                    InsatuyouSyohin__c,             //印刷用商品名
                    InsatuyouSyohinEng__c,
                    Tariff__r.ContainerSize__c,
                    Suryo__c,                       //数量
                    Tariff__r.UNIT__c,              //単位
                    SellTankaJPY__c,                //単価
                    UnitPriceofSelling3rdCurrency__c,
                    curr__c,                        //通貨
                    SellInTaxAmountJPY__c,          //消費税込販売金額(JPY)
                    SellAmountJPN__c,               //合計販売金額(JPY)
                    TotalAmountofSelling3rdCurrency__c,
                    Anken__c,                       //親案件への参照
                    SeikyuBangou__c,                //No.
                    wkSuryo__c,                      //wk数量
                    SellTankaUSD__c,
                    SellAmountUSD__c,
                    SellInTaxAmount_USD__c,
                    AmountSellingInclTax3rdCurrency__c,
                    ProductTax__c,
                    KawaseSel__c,
                    SellTaxNum__c,
                    SellTaxNum_USD__c,
                    TAX_ADJUSTMENTSELL__c,
                    TaxInitial__c,
                    ChargeUnitInPrint__c,
                    Seikyusaki__r.Name,
                    Anken__r.Field1__r.Name,
                    AmountofTaxSelling3rdCurrency__c
            FROM AnkenMeisai__c
            WHERE Anken__c = :AnkenList.id 
            AND PrintFlag__c = true
            AND Seikyusaki__c != :null 
            AND (SellInTaxAmountJPY__c != :null OR SellInTaxAmount_USD__c != :null) 
            AND curr__c != :null
            ORDER BY SeikyuBangou__c NULLS LAST, CreatedDate
        ];
        
        // Set value for ItemList and comparisonItemList
        for(AnkenMeisai__c item: itemListTemp) {
            if(item?.Seikyusaki__r.Name != null && item?.Anken__r.Field1__r.Name != null && item?.Seikyusaki__r.Name == item?.Anken__r.Field1__r.Name) {
                itemList.add(item);
            }
        }

        TotalAmount = 0;
        TotalAmountUSD = 0;
        for(AnkenMeisai__c temp :itemList){
//            TotalAmount   += temp.SellInTaxAmountJPY__c;
            TotalAmount += Util.calculateSellingInTaxAmount(temp);//.Suryo__c * temp.SellTankaJPY__c) * (1 + temp.TaxInitial__c/100) + (temp.TAX_ADJUSTMENTSELL__c != null ? temp.TAX_ADJUSTMENTSELL__c : 0);
            TotalAmountUSD   += temp.SellInTaxAmount_USD__c;

            if (temp.InsatuyouSyohin__c != null &&
                    (PicklistReference.PRODUCT_TAX.equals(temp.ProductTax__c) || PicklistReference.DUAL_PRODUCT_TAX.equals(temp.ProductTax__c))
                    && (!temp.InsatuyouSyohin__c.endsWith('('+ PicklistReference.PRODUCT_TAX + ')')
                    || !temp.InsatuyouSyohin__c.endsWith('('+ PicklistReference.DUAL_PRODUCT_TAX + ')'))) {
                temp.InsatuyouSyohin__c = temp.InsatuyouSyohin__c + ' (TAX)';
            }

            if (temp.InsatuyouSyohinEng__c != null &&
                    (PicklistReference.PRODUCT_TAX.equals(temp.ProductTax__c) || PicklistReference.DUAL_PRODUCT_TAX.equals(temp.ProductTax__c))
                    && (!temp.InsatuyouSyohinEng__c.endsWith('('+ PicklistReference.PRODUCT_TAX + ')')
                    || !temp.InsatuyouSyohinEng__c.endsWith('('+ PicklistReference.DUAL_PRODUCT_TAX + ')'))) {
                temp.InsatuyouSyohinEng__c = temp.InsatuyouSyohinEng__c + ' (TAX)';
            }

            this.ShowTaxCol = this.ShowTaxCol || (temp.SellTaxNum__c != null && temp.SellTaxNum__c != 0) || (temp.SellTaxNum_USD__c != null && temp.SellTaxNum_USD__c != 0);
        }
        TotalAmount = TotalAmount.setScale(0, System.RoundingMode.HALF_UP);
    }
}