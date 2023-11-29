public with sharing class PrintHBLController {
    public String id {get; set;}
    public String billing {get; set;}
    public String customer {get; set;}
    public String customer1 {get; set;}
    public Boolean isCreateAttachment {get; set;}
    public Boolean isCreateNumber {get;set;}
    public clofor_com_cfs__CustomObject1__c shipment {get; set;}
    public clofor_com_cfs__CustomObject1__c shipmentnew {get; set;}

    public PrintHBLController() {
        id = ApexPages.currentPage().getParameters().get('id');
        billing = ApexPages.currentPage().getParameters().get('billing');
        customer = ApexPages.currentPage().getParameters().get('customer');
        isCreateAttachment = ApexPages.currentPage().getParameters().get('isCreateAttachment') == 'true';
        isCreateNumber = ApexPages.currentPage().getParameters().get('isNumber') == 'true';
        System.debug('id: ' + id + ' isCreateAttachment: ' + isCreateAttachment + ' customer: ' + customer);
        shipment = getData(id);

        if(customer == 'FOR SHIPPER'){
            customer1 = 'ORIGINAL 3' + ' ' + '(' + customer + ')';
        }
        else{

            customer1 = 'ORIGINAL 5' + ' ' + '(' + customer + ')';
        }
        
        if(shipment.clofor_com_cfs__CBM__c != null){
            shipment.clofor_com_cfs__CBM__c = shipment.clofor_com_cfs__CBM__c.setScale(3, RoundingMode.HALF_UP);
        }else {
            shipment.clofor_com_cfs__CBM__c = 0;
        }
        if(shipment.clofor_com_cfs__C_W_Dimension_dev__c != null){
            shipment.clofor_com_cfs__C_W_Dimension_dev__c = shipment.clofor_com_cfs__C_W_Dimension_dev__c.setScale(3, RoundingMode.HALF_UP);
        }else {
            shipment.clofor_com_cfs__C_W_Dimension_dev__c = 0;
        }
        System.debug('shipment: ' + shipment);
        
        Apexpages.currentPage().getHeaders().put('content-disposition', billing == 'hbl' ? 'inline;filename=HBL.pdf' : 'inline; filename=HAWB.pdf');
    }

    public clofor_com_cfs__CustomObject1__c getData(String id){
        List<clofor_com_cfs__CustomObject1__c> shipments = [SELECT 
        Id,
         clofor_com_cfs__ADDRESS_ON_B_L__c,
         clofor_com_cfs__CNEE_ADDRESS_ON_B_L__c,
         clofor_com_cfs__NOTIFY_ADDRESS_ON_B_L__c,
         clofor_com_cfs__HBL__c,
         clofor_com_cfs__QuotationPaymentCondition__c,
         clofor_com_cfs__PlaceOfReceiptDetailPrint__c,
         clofor_com_cfs__Vessle__c,
         clofor_com_cfs__PortOfLoadingDetailPrint__c,
         clofor_com_cfs__PlaceOfDeliveryDetailPrint__c,
         clofor_com_cfs__PortOfDischargeDetailPrint__c,
         clofor_com_cfs__Voy_No__c,
         clofor_com_cfs__CARGO_TYPE__c,
         clofor_com_cfs__Container_Measurement_Details__c,
         clofor_com_cfs__Marks_and_Numbers__c,
         clofor_com_cfs__PackageUnitCode__c,
         clofor_com_cfs__GoodsDescriptiononAN__c,
         clofor_com_cfs__Item__c,
         clofor_com_cfs__weight__c,
         clofor_com_cfs__CBM__c,
         clofor_com_cfs__S_I_PASSWORD__c,
         clofor_com_cfs__A_N_PASSWORD__c,
         clofor_com_cfs__CustomizedShipOrderIDType2__c,
         clofor_com_cfs__CustomizedShipOrderIDType__c,
         clofor_com_cfs__CustomizedShipOrderID__c,
         clofor_com_cfs__NumberOfContainers__c,
         clofor_com_cfs__Freight_Collect_Prepaid__c,
         clofor_com_cfs__Prepaid_at__c,
         clofor_com_cfs__Payable_at__c,
         clofor_com_cfs__PlaceOfHouseBLIssued__c,
         clofor_com_cfs__DATE_OF_HOUSE_BL_ISSUED__c,
         clofor_com_cfs__No_of_Original_BL__c,
		 clofor_com_cfs__FormattedETD__c,
         clofor_com_cfs__GOODS_ATTACHMENT__c,
         clofor_com_cfs__MARKS_NUMBERS_ATTACHMENT__c,
         clofor_com_cfs__HAWB__c,
         clofor_com_cfs__MAWBNumberonAWB__c,
         clofor_com_cfs__FlightNo__c,
         clofor_com_cfs__BREAL_BULK_INVOICE_PASSWORD__c,
         clofor_com_cfs__chargable_weight__c,
         clofor_com_cfs__MitumoriSyouninsyaENG__c,
         clofor_com_cfs__MitumoriSinseisya__c,
         clofor_com_cfs__CarrierCode__c,
         clofor_com_cfs__ETD__c,
         clofor_com_cfs__T_ETD__c,
         
         clofor_com_cfs__DimensionDetail__c,
         clofor_com_cfs__C_W_Dimension_dev__c,

         clofor_com_cfs__TransitV__c,
         clofor_com_cfs__FormattedTETD__c,
         clofor_com_cfs__carton__c,
         clofor_com_cfs__UnitType__c,
         clofor_com_cfs__TranporationType__c,
         clofor_com_cfs__BLtype__c,
         clofor_com_cfs__BookingNv__c,
         clofor_com_cfs__BookingNv__r.clofor_com_cfs__Carrier_Code__r.clofor_com_cfs__Carrier_Code__c,
         clofor_com_cfs__POD__c,
         clofor_com_cfs__POD__r.clofor_com_cfs__PortCodeOnly__c,
         (SELECT clofor_com_cfs__TransitVesselFlight__c, clofor_com_cfs__ETDAtTransitPort__c, clofor_com_cfs__MasterCarrierConsolidator__r.clofor_com_cfs__Carrier_Code__r.clofor_com_cfs__Carrier_Code__c,
         clofor_com_cfs__TransitPort__r.clofor_com_cfs__PortCodeOnly__c FROM clofor_com_cfs__TRANSIT__r WHERE clofor_com_cfs__InOrderOfTransit__c = 1 LIMIT 1)
         FROM clofor_com_cfs__CustomObject1__c WHERE Id = :id];

        return shipments.size() > 0 ? shipments.get(0) : null;
    }

    @AuraEnabled
    public static Boolean isAutoCheckedCreateAttachment(String id){
        try {
            clofor_com_cfs__CustomObject1__c shipment = [SELECT clofor_com_cfs__GOODS_ATTACHMENT__c, clofor_com_cfs__MARKS_NUMBERS_ATTACHMENT__c FROM clofor_com_cfs__CustomObject1__c WHERE Id = :id];
            return (shipment.clofor_com_cfs__GOODS_ATTACHMENT__c != null || shipment.clofor_com_cfs__MARKS_NUMBERS_ATTACHMENT__c != null) ? true : false;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}