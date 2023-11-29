/**
 * Created by khanhpham on 3/13/18.
 */

public with sharing class SyncExRateController {
    public List<ShipmentOrderWrapper> shipmentOrderWrappers { get; private set; }
    private Map<Id, CustomObject1__c> toBeSyncedShipmentOrders;
    public Non_Standard_Exchange_Rate__c dummyNonExRate { get; set; }
    public SearchCriteria searchCriteria { get; set; }
    private String queryString;

    public SyncExRateController() {
        shipmentOrderWrappers = new List<ShipmentOrderWrapper>();
        toBeSyncedShipmentOrders = new Map<Id, CustomObject1__c>();
        dummyNonExRate = new Non_Standard_Exchange_Rate__c();
        searchCriteria = new SearchCriteria();
        queryString = 'SELECT Id, ID__c, Name, REFNO__c, HBL_Number_SEA_AIR__c, toLabel(status__c), shipper__r.Name, ' +
                'Cnee__r.Name, ETA__c, ETD__c ' +
                'FROM CustomObject1__c';
    }

    public ApexPages.StandardSetController con {
        get {
            if (con == null) {
                con = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                con.setPageSize(10);
            }
            return con;
        }
        set;
    }

    public Boolean hasNext {
        get {
            return con.getHasNext();
        }
        set;
    }

    public Boolean hasPrevious {
        get {
            return con.getHasPrevious();
        }
        set;
    }

    public Integer pageNumber {
        get {
            return con.getPageNumber();
        }
        set;
    }

    public void first() {
        con.first();
        prepareResult();
    }

    public void last() {
        con.last();
        prepareResult();
    }

    public void previous() {
        con.previous();
        prepareResult();
    }

    public void next() {
        con.next();
        prepareResult();
    }

    public void searchShipmentOrders() {
        con = null;

        queryString = 'SELECT Id, ID__c, Name, REFNO__c, HBL_Number_SEA_AIR__c, toLabel(status__c), shipper__r.Name, ' +
                'Cnee__r.Name, ETA__c, ETD__c ' +
                'FROM CustomObject1__c';
        String whereClause = '';

        if (!StringUtils.isEmpty(searchCriteria.shipmentName)) {
            queryString += (StringUtils.isEmpty(whereClause) ? ' WHERE ' : ' AND ');
            queryString += ' Name LIKE \'%' + searchCriteria.shipmentName + '%\'';
        }

        if (!StringUtils.isEmpty(searchCriteria.hblNo)) {
            queryString += (StringUtils.isEmpty(whereClause) ? ' WHERE ' : ' AND ');
            queryString += ' HBL_Number_SEA_AIR__c LIKE \'%' + searchCriteria.hblNo + '%\'';
        }

        prepareResult();
    }

    private void prepareResult() {
        shipmentOrderWrappers = new List<ShipmentOrderWrapper>();
        List<CustomObject1__c> shipmentOrders = (List<CustomObject1__c>) con.getRecords();

        if (shipmentOrders != null && !shipmentOrders.isEmpty()) {
            for (CustomObject1__c shipmentOrder : shipmentOrders) {
                shipmentOrderWrappers.add(new ShipmentOrderWrapper(shipmentOrder));
            }
        }
    }

    public PageReference addToList() {
        for (ShipmentOrderWrapper wrapper : shipmentOrderWrappers) {
            if (wrapper.checked & !toBeSyncedShipmentOrders.containsKey(wrapper.shipmentOrder.Id)) {
                toBeSyncedShipmentOrders.put(wrapper.shipmentOrder.Id, wrapper.shipmentOrder);
            }
        }

        return null;
    }

    public void synchronizeExchangeRate() {
        for (CustomObject1__c shipmentOrder : toBeSyncedShipmentOrders.values()) {
            ExchangeRateSynchronizationService.syncHBLShipmentAndSellingBuyings(shipmentOrder.Id);
        }
    }

    public PageReference removeFromList() {
        String removedId = ApexPages.currentPage().getParameters().get('shipmentOrderId');

        if (toBeSyncedShipmentOrders.containsKey(removedId)) {
            toBeSyncedShipmentOrders.remove(removedId);
        }

        return null;
    }

    public List<CustomObject1__c> getSelectedShipmentOrders() {
        return toBeSyncedShipmentOrders.values();
    }

    public class ShipmentOrderWrapper {
        public Boolean checked { get; set; }
        public CustomObject1__c shipmentOrder { get; private set; }

        public ShipmentOrderWrapper(CustomObject1__c shipmentOrder) {
            this.shipmentOrder = shipmentOrder;
            checked = false;
        }
    }

    public class SearchCriteria {
        public String shipmentName { get; set; }
        public String hblNo { get; set; }

        public SearchCriteria() {
            shipmentName = '';
            hblNo = '';
        }
    }
}