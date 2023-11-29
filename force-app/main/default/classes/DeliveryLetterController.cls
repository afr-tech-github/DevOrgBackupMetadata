public with sharing class DeliveryLetterController {
    public CustomObject1__c shipment { get; private set; }
    public List<Cargo_Delivery__c> cargoDeliveries { get; private set; }
    public Map<String, String> translations { get; private set; }
    public String deliveryCompany { get; private set; }
    public String deliveryCompanyEnglish { get; private set; }
    public boolean isAir { get; private set; }
    public boolean isOcean { get; private set; }
    public boolean isImport { get; private set; }
    public boolean isExport { get; private set; }
    public Integer totalCargoes { get; private set; }

    public DeliveryLetterController() {
        String shipmentId = StringUtils.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('shipmentId'));
        String cargoDeliveryId = StringUtils.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('cargoId'));

        if (PermissionValidationUtil.isAccessibleAccount() && PermissionValidationUtil.isAccessibleUser()
                && PermissionValidationUtil.isAccessiblePort() && PermissionValidationUtil.isAccessibleWarehouse()
                && PermissionValidationUtil.isAccessibleHBL()) {
            if (StringUtils.isEmpty(cargoDeliveryId) || 'all'.equalsIgnoreCase(cargoDeliveryId)) {
                loadAllCargoDeliveries(shipmentId);
            } else {
                loadCargoDeliveries(shipmentId, cargoDeliveryId);
            }

            if (shipment != null) {
                cargoDeliveries = shipment.Cargo_Delivery__r;
                if (!cargoDeliveries.isEmpty()) {
                    deliveryCompany = cargoDeliveries.get(0).DeliveryCompany__r.Name;
                    deliveryCompanyEnglish = cargoDeliveries.get(0).DeliveryCompany__r.EnglishCompanyName__c;
                }

                isAir = ObjectClassificationUtils.isAirHBL(shipment);
                isOcean = ObjectClassificationUtils.isOceanHBL(shipment);
                isImport = ObjectClassificationUtils.isImportHBL(shipment);
                isExport = ObjectClassificationUtils.isExportHBL(shipment);
                totalCargoes = cargoDeliveries.size();
            }
        }

        initializeTranslation();
    }

    private void initializeTranslation() {
        String language = StringUtils.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('lang'));
        TranslationService translationService = new TranslationService('DeliveryLetter', language);
        translations = translationService.getTranslations();
    }

    private void loadAllCargoDeliveries(String shipmentId) {
        shipment = [
                SELECT Id, Name, WkInitial__c, Mail_Merge_Company_Signature__c, Cnee__r.Name, Cnee__r.EnglishCompanyName__c, UnitType__c, carton__c, CBM__c,
                        weight__c, HAWB__c, Marks_and_Numbers__c, Custom_Clearance_Broker__r.Name, Custom_Clearance_Broker__r.EnglishCompanyName__c, Container__c, Container2__c,
                        Container3__c, Container4__c, Style_Number__c,
                        PersonInCharge__r.Name, PrintDate__c, QuotationVer__c, D_O_type__c, HBL__c, RecordTypeId, BookingNo__c, HouseBookingNo__c, MASTER_BOOKINGNO__c,MAWB__c,
                        shipper__r.Name, shipper__r.EnglishCompanyName__c, POD__r.Country_Name__c, POL__r.Country_Name__c, Vessle__c, Voy_No__c, ETA__c, Master_B_L__c,
                        ContainerSeal_No__c, CutDay__c, LoadingTime__c, LoadLocation__r.Name, LoadAddressContact__c, Field1__r.Name, Item__c, (
                        SELECT Id, Name, DeliveryType__c, Pickupdate__c, Receiver__c, DeliveryCompany__r.Name, DeliveryCompany__r.EnglishCompanyName__c,
                                AddressForAccept__c, ReceiverContact__c, PersonInChargeForAccept__c, CONTAINER_ID__r.Name, CONTAINER_ID__r.Container_NO__c,
                                DeliveryDate__c, DeliveryTime__c, Destination__c, DestinationAddress__c, DeliveryPhone__c,
                                ReceiverRep__c, DeliveryNote__c, NumberPlateOfTheTruck__c, NameOfTheDriver__c, CPNumberOfTheDriver__c
                        FROM Cargo_Delivery__r
                        ORDER BY CreatedDate ASC
                )
                FROM CustomObject1__c
                WHERE Id = :shipmentId
        ];
    }

    private void loadCargoDeliveries(String shipmentId, String cargoDeliveryId) {
        shipment = [
                SELECT Id, Name, WkInitial__c, Mail_Merge_Company_Signature__c, Cnee__r.Name, Cnee__r.EnglishCompanyName__c, UnitType__c, carton__c, CBM__c,
                        weight__c, HAWB__c, Marks_and_Numbers__c, Custom_Clearance_Broker__r.Name, Custom_Clearance_Broker__r.EnglishCompanyName__c, Container__c, Container2__c,
                        Container3__c, Container4__c, Style_Number__c,
                        PersonInCharge__r.Name, PrintDate__c, QuotationVer__c, D_O_type__c, HBL__c, RecordTypeId, BookingNo__c, HouseBookingNo__c, MASTER_BOOKINGNO__c,MAWB__c,
                        shipper__r.Name, shipper__r.EnglishCompanyName__c, POD__r.Country_Name__c, POL__r.Country_Name__c, Vessle__c, Voy_No__c, ETA__c, Master_B_L__c,
                        ContainerSeal_No__c, CutDay__c, LoadingTime__c, LoadLocation__r.Name, LoadAddressContact__c, Field1__r.Name, Item__c, (
                        SELECT Id, Name, DeliveryType__c, Pickupdate__c, Receiver__c, DeliveryCompany__r.Name, DeliveryCompany__r.EnglishCompanyName__c,
                                AddressForAccept__c, ReceiverContact__c, PersonInChargeForAccept__c, CONTAINER_ID__r.Name, CONTAINER_ID__r.Container_NO__c,
                                DeliveryDate__c, DeliveryTime__c, Destination__c, DestinationAddress__c, DeliveryPhone__c,
                                ReceiverRep__c, DeliveryNote__c, NumberPlateOfTheTruck__c, NameOfTheDriver__c, CPNumberOfTheDriver__c
                        FROM Cargo_Delivery__r
                        WHERE Id = :cargoDeliveryId
                        ORDER BY CreatedDate ASC
                )
                FROM CustomObject1__c
                WHERE Id = :shipmentId
        ];
    }
}