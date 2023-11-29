public with sharing class HouseBillLadingReportController {
    private String shipmentId;
    private static List<String> shipmentFields;
    private static List<String> containerFields;
    private static List<String> manifestFields;
    
    public ShipmentWrapper wrapper {get; private set;}
    public Manifest manifest {get; private set;}
    
    public HouseBillLadingReportController() {
        readParameters();
        if (PermissionValidationUtil.isAccessibleHBL()) {
            prepareReportData();
        }
        
        manifest = new Manifest();
        buildManifestList();
    }
    
    public String xlsHeader {
        get {
            String strHeader = '';
            strHeader += '<?xml version="1.0"?>';
            strHeader += '<?mso-application progid="Excel.Sheet"?>';
            return strHeader;
        }
    }
    
    private void readParameters() {
        shipmentId = ApexPages.currentPage().getParameters().get('id');
    }
    
    private void prepareReportData() {
        final String query = buildQuery(shipmentId);
        CustomObject1__c shipmentWithContainers = Database.query(query);
        wrapper = new ShipmentWrapper();
        
        if (shipmentWithContainers != null) {
            wrapper.consignerAddress = shipmentWithContainers.ADDRESS_ON_B_L__c;
            wrapper.consigneeAddress = shipmentWithContainers.CNEE_ADDRESS_ON_B_L__c;
            wrapper.notifyAddress = shipmentWithContainers.NOTIFY_ADDRESS_ON_B_L__c;
            wrapper.portOfTransit = shipmentWithContainers.TS__c;
            wrapper.placeOfDelivery = shipmentWithContainers.Place_Of_Delivery__r.Name;
            wrapper.portOfLoad = shipmentWithContainers.POL__r.Name;
            wrapper.portOfDischarge = shipmentWithContainers.POD__r.Name;
            wrapper.cargoType = shipmentWithContainers.CARGO_TYPE__c;
            wrapper.houseBillNumber = shipmentWithContainers.HBL_Number_SEA_AIR__c;
            wrapper.dateOfBill = shipmentWithContainers.PrintDate__c;
            wrapper.masterBillNumber = shipmentWithContainers.MBL_Number_SEA_AIR__c;
            wrapper.dateOfMasterBillIssued = shipmentWithContainers.DATE_OF_MASTER_BL_ISSUED__c;
            wrapper.departureDate = shipmentWithContainers.ETD__c;
            wrapper.numberOfPackages = shipmentWithContainers.carton__c;
            wrapper.unitType = shipmentWithContainers.UnitType__c;
            wrapper.remarks = shipmentWithContainers.Remarks__c;
            //wrapper.hsCode = shipmentWithContainers.HSCode__r.Name;
            wrapper.hsCode = '';
            wrapper.placeOfReceipt = shipmentWithContainers.Place_Of_Receipt__r.Name;
            
            String transportationType = shipmentWithContainers.TranporationType__c;
            if (PicklistReference.TRANSPORTATION_FCL.equalsIgnoreCase(transportationType)) {
                List<Container_Info__c> containerInfos = shipmentWithContainers.Container_Info__r;
                if (containerInfos != null && !containerInfos.isEmpty()) {
                    for (Container_Info__c ci : containerInfos) {
                        ContainerWrapper container = new ContainerWrapper();
                        container.goods = ci.GOODS__c;
                        container.containerNo = ci.Container_NO__c;
                        container.sealNo = ci.Seal_No__c;
                        container.grossWeigth = ci.GROSS_WEIGHT__c;
                        container.measurement = ci.MEASUREMENT_CBM__c;
                        container.netWeigth = ci.NET_WEIGHT__c;
                        
                        wrapper.addContainer(container);
                    }
                }
                
            } else {
                ContainerWrapper container = new ContainerWrapper();
                String containerAndSealNo = shipmentWithContainers.CONTAINERSEALNO__c;
                
                if (!StringUtils.isEmpty(containerAndSealNo)) {
                    List<String> tokens = containerAndSealNo.split('/');
                    
                    if (tokens.size() == 2) {
                        container.containerNo = tokens.get(0);
                        container.sealNo = tokens.get(1);
                    } else if (tokens.size() == 1) {
                        container.containerNo = tokens.get(0);
                        container.sealNo = '';
                    }
                }
                
                container.goods = shipmentWithContainers.Item__c;
                container.grossWeigth = shipmentWithContainers.weight__c;
                container.measurement = shipmentWithContainers.CBM__c;
                container.netWeigth = shipmentWithContainers.NET_NET_Weight__c;
                
                wrapper.addContainer(container); 
            }
        }
    }
    
    private String buildQuery(String shipmentId) {
        final String query = 'SELECT ' + String.join(shipmentFields, ',') + ', (SELECT ' + String.join(containerFields, ',') 
                            + ' FROM Container_Info__r) FROM CustomObject1__c WHERE Id = \'' + StringUtils.escapeSingleQuotes(shipmentId) + '\'';
        return query;
    }
    
    private void buildManifestList() {
        if (PermissionValidationUtil.isAccessibleManifest()) {
            final String query = 'SELECT ' + String.join(manifestFields, ',') + ' FROM MANIFEST__c ORDER BY Code__c';
            List<Manifest__c> manifestList = Database.query(query);
            
            if (manifestList != null && !manifestList.isEmpty()) {
                for (MANIFEST__c m : manifestList) {
                    manifest.addManifestRecord(m.Category__c, m.Code__c, m.NAME__c);
                }
            }
        }
    }
    
    static {
        shipmentFields = new List<String>();
        //shipmentFields.add('HSCode__r.Name');
        shipmentFields.add('Name');
        shipmentFields.add('ADDRESS_ON_B_L__c');
        shipmentFields.add('CNEE_ADDRESS_ON_B_L__c');
        shipmentFields.add('NOTIFY_ADDRESS_ON_B_L__c');
        shipmentFields.add('TS__c');
        shipmentFields.add('Place_Of_Delivery__r.Name');
        shipmentFields.add('POL__r.Name');
        shipmentFields.add('POD__r.Name');
        shipmentFields.add('CARGO_TYPE__c');
        shipmentFields.add('HBL_Number_SEA_AIR__c');
        shipmentFields.add('PrintDate__c');
        shipmentFields.add('MBL_Number_SEA_AIR__c');
        shipmentFields.add('DATE_OF_MASTER_BL_ISSUED__c');
        shipmentFields.add('ETD__c');
        shipmentFields.add('carton__c');
        shipmentFields.add('UnitType__c');
        shipmentFields.add('Remarks__c');
        shipmentFields.add('Place_Of_Receipt__r.Name');
        shipmentFields.add('TranporationType__c');
        shipmentFields.add('Item__c');
        shipmentFields.add('weight__c');
        shipmentFields.add('CBM__c');
        shipmentFields.add('NET_NET_Weight__c');
        shipmentFields.add('CONTAINERSEALNO__c');
        
        containerFields = new List<String>();
        containerFields.add('GOODS__c');
        containerFields.add('GROSS_WEIGHT__c');
        containerFields.add('MEASUREMENT_CBM__c');
        containerFields.add('Container_NO__c');
        containerFields.add('Seal_No__c');
        containerFields.add('NET_WEIGHT__c');
        
        manifestFields = new List<String>();
        manifestFields.add('Category__c');
        manifestFields.add('Code__c');
        manifestFields.add('NAME__c');
    }

    class ShipmentWrapper{
        public List<ContainerWrapper> containers {get; private set;}
        public String consignerAddress {get; set;}
        public String consigneeAddress {get; set;}
        public String notifyAddress {get; set;}
        public String portOfTransit {get; set;}
        public String placeOfDelivery {get; set;}
        public String placeOfReceipt {get; set;}
        public String portOfLoad {get; set;}
        public String portOfDischarge {get; set;}
        public String cargoType {get; set;}
        public String houseBillNumber {get; set;}
        public Date dateOfBill {get; set;}
        public String masterBillNumber {get; set;}
        public Date dateOfMasterBillIssued {get; set;}
        public Date departureDate {get; set;}
        public Decimal numberOfPackages {get; set;}
        public String unitType {get; set;}
        public String remarks {get; set;}
        public String hsCode {get; set;}
        
        public ShipmentWrapper() {
            containers = new List<ContainerWrapper>();
        }
        
        public void addContainer(ContainerWrapper container) {
            if (container != null) {
                containers.add(container);
            }
        }
    }
    
    class ContainerWrapper{
        public String goods {get; set;}
        public String containerNo {get; set;}
        public String sealNo {get; set;}
        public Decimal grossWeigth {get; set;}
        public Decimal measurement {get; set;}
        public Decimal netWeigth {get; set;}
    }
    
    class Manifest {
        public Integer numberOfPorts {get; private set;}
        public Integer numberOfGrossUnits {get; private set;}
        public Integer numberOfDocFunctions {get; private set;}
        public List<ManifestRecord> manifestRecords {get; set;}
        
        public Manifest() {
            manifestRecords = new List<ManifestRecord>();
            numberOfPorts = 0;
            numberOfGrossUnits = 0;
            numberOfDocFunctions = 0;
        }
        
        public void addManifestRecord(final String category, final String code, final String description) {
            if (!StringUtils.isEmpty(category) && !StringUtils.isEmpty(code)) {
                if (category.contains('Port')) {
                    ManifestRecord mr = getManifestRecord(numberOfPorts);
                    mr.portCode = code;
                    mr.portCodeName = description;
                    numberOfPorts++;
                } else if (category.contains('Document')) {
                    ManifestRecord mr = getManifestRecord(numberOfDocFunctions);
                    mr.docFunction = code;
                    mr.docFunctionName = description;
                    numberOfDocFunctions++;
                } else if (category.contains('GrossUnit')) {
                    ManifestRecord mr = getManifestRecord(numberOfGrossUnits);
                    mr.grossUnit = code;
                    mr.grossUnitName = description;
                    numberOfGrossUnits++;
                }
            }
        }
        
        private ManifestRecord getManifestRecord(Integer index) {
            ManifestRecord mr = null;
            
            if ((index + 1) > manifestRecords.size() || manifestRecords.isEmpty()) {
                mr = new ManifestRecord();
                manifestRecords.add(mr);
            } else {
                mr = manifestRecords.get(index);
            }
            return mr;
        }
    }
    
    class ManifestRecord {
        public String portCode {get; set;}
        public String portCodeName {get; set;}
        public String grossUnit {get; set;}
        public String grossUnitName {get; set;}
        public String docFunction {get; set;}
        public String docFunctionName {get; set;}
    }
}