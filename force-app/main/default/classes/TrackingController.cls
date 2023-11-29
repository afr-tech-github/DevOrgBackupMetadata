/**
 * This controller provides service for searching Shipment Order by either
 * - ID
 * - HBL No
 * - MBL No
 * - Reference ID
 *
 * The front-end will be Site
 *
 * Created by khanhpham on 6/8/17.
 */

public with sharing class TrackingController {
    public String searchString { get; set; }
    public List<CustomObject1__c> shipmentOrderList { get; private set; }
    public List<SelectOption> searchFieldList { get; private set; }
    public String searchField { get; set; }

    private static List<String> queryFieldList;

    public TrackingController() {
        initialize();
    }

    private void initialize() {
        searchFieldList = new List<SelectOption>();
        searchFieldList.add(new SelectOption('ID__c', 'Shipment Order ID'));
        searchFieldList.add(new SelectOption('HBL_Number_SEA_AIR__c', 'HBL No'));
        searchFieldList.add(new SelectOption('MBL_Number_SEA_AIR__c', 'MBL No'));
        searchFieldList.add(new SelectOption('CONTAINERSEALNO__c', 'Container Number'));
        searchFieldList.add(new SelectOption('RefNo__c', 'Reference Number'));
    }

    public void doSearch() {
        if (StringUtils.isEmpty(searchString)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter search string'));
        }

        String queryString = 'SELECT ' + String.join(queryFieldList, ',')
                + ' FROM ' + Constants.NAMESPACE + 'CustomObject1__c'
                + ' WHERE ' + Constants.NAMESPACE + String.escapeSingleQuotes(searchField) + ' LIKE \'%' + String.escapeSingleQuotes(searchString) + '%\'';

        if (PermissionValidationUtil.isAccessibleHBL()) {
            try {
                if ('CONTAINERSEALNO__c'.equalsIgnoreCase(searchField)) {
                    shipmentOrderList = searchByContainerNumber(searchString);
                } else {
                    shipmentOrderList = Database.query(queryString);
                }

                if (shipmentOrderList == null || shipmentOrderList.size() == 0) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Cannot find any shipment order for search condition!'));
                }
            } catch (Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Sorry. The system encountered an error. ERROR: ' + e.getMessage()));
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Insufficent permissions. Please contact System Administrator for support!'));
        }
    }

    private List<CustomObject1__c> searchByContainerNumber(String containerNumber) {
        List<CustomObject1__c> shipmentOrders = new List<CustomObject1__c>();
        containerNumber = '%' + containerNumber.trim() + '%';
        List<String> shipmentOrderIds = new List<String>();

        for (Container_Info__c container : [SELECT Id, HBL_SHIPMENT__c FROM Container_Info__c WHERE Container_NO__c LIKE :containerNumber]) {
            shipmentOrderIds.add('\'' + container.HBL_SHIPMENT__c + '\'');
        }

        if (!shipmentOrderIds.isEmpty()) {
            String queryString = 'SELECT ' + String.join(queryFieldList, ',')
                    + ' FROM ' + Constants.NAMESPACE + 'CustomObject1__c'
                    + ' WHERE Id IN (' + String.join(shipmentOrderIds, ',') + ')';
            shipmentOrders = Database.query(queryString);
        }

        return shipmentOrders;
    }

    static {
        queryFieldList = new List<String>();
        queryFieldList.add('Id');
        queryFieldList.add('Name');
        queryFieldList.add('ID__c');
        queryFieldList.add('RefNo__c');
        queryFieldList.add('RecordTypeId');
        queryFieldList.add('TS__c');
        queryFieldList.add('HBL_Number_SEA_AIR__c');
        queryFieldList.add('MBL_Number_SEA_AIR__c');
        queryFieldList.add('Status__c');
        queryFieldList.add('CarrierType__c');
        queryFieldList.add('TranporationType__c');
        queryFieldList.add('Vessel_Flight__c');
        queryFieldList.add('No_Voyage_Flight__c');
        queryFieldList.add('ContainerSealNo__c');
        queryFieldList.add('Item__c');
        queryFieldList.add('Carton__c');
        queryFieldList.add('UnitType__c');
        queryFieldList.add('Net_Net_Weight__c');
        queryFieldList.add('Weight__c');
        queryFieldList.add('Chargable_Weight__c');
        queryFieldList.add('CBM__c');
        queryFieldList.add('POL__r.Name');
        queryFieldList.add('POD__r.Name');
        queryFieldList.add('ETD__c');
        queryFieldList.add('T_ETD__c');
        queryFieldList.add('ETA__c');
        queryFieldList.add('Container__c');
        queryFieldList.add('Container2__c');
        queryFieldList.add('Container3__c');
        queryFieldList.add('Container4__c');
        queryFieldList.add('ContainerNumber__c');
        queryFieldList.add('ContainerNumber2__c');
        queryFieldList.add('ContainerNumber3__c');
        queryFieldList.add('ContainerNumber4__c');
        queryFieldList.add('SwitchB_L__c');
        queryFieldList.add('TransitV__c');
    }
}