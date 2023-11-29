/**
 * Created by khanhpham on 5/2/17.
 */

public with sharing class LoadingLocationTriggerHandler extends AbstractTriggerHandler {
    public static final Boolean CAPACITY_VALIDATION_ENABLED = false;
    public static final String TRUCK_HANDLE_LOAD = 'Load';
    public static final String TRUCK_HANDLE_UNLOAD = 'Unload';
    public static final String TRUCK_HANDLE_PARTITAL_LOAD = 'Partially Load';
    public static final String TRUCK_HANDLE_PARTIAL_UNLOAD = 'Partially Unload';
    private static TranslationService translationService = new TranslationService('TRUCKING', UserInfo.getLanguage());
    private static final Integer TRUCK_WEIGHT_UNIT_TO_KG = 1000;
    private static Map<Id, Route__c> routeMap = new Map<Id, Route__c>();
    private Set<LoadingLocation__c> toBeUpdatedloadingLocations = new Set<LoadingLocation__c>();
    private Map<Id, Route__c> toBeUpdatedRoutes = new Map<Id, Route__c>();
    private static Integer counter = 0;

    public override void bulkBefore() {
        if (Trigger.isDelete) {
            loadReferenceData(Trigger.old);
        } else {
            loadReferenceData(Trigger.new);
        }
    }

    public override void bulkAfter() {
        if (Trigger.isDelete) {
            loadReferenceData(Trigger.old);
        } else {
            loadReferenceData(Trigger.new);
        }
    }

    public override void beforeInsert(SObject so) {
        LoadingLocation__c location = (LoadingLocation__c) so;
        Route__c route = routeMap.get(location.Route__c);
        List<LoadingLocation__c> loadingLocations = route.LoadingLocation__r;

        loadingLocations.add(location);

        List<LoadingLocationWrapper> loadingLocationWrappers = sortAndLinkLocations(loadingLocations);
        LoadingLocationWrapper loadingLocationWrapper = getRoutLoadWrapperBySequence(loadingLocationWrappers, location.SequenceNumber__c);

        String errorMessage = validate(loadingLocationWrapper, loadingLocationWrappers, route);
        if (String.isNotBlank(errorMessage)) {
            location.addError(errorMessage);
            return;
        }

        updateCapacityAtStop(loadingLocationWrapper, route);
    }

    public override void afterInsert(SObject so) {
        LoadingLocation__c location = (LoadingLocation__c) so;
        Route__c route = routeMap.get(location.Route__c);
        List<LoadingLocation__c> locations = route.LoadingLocation__r;
        List<LoadingLocationWrapper> loadingLocationWrappers = sortAndLinkLocations(locations);
        LoadingLocationWrapper loadingLocationWrapper = getRoutLoadWrapperBySequence(loadingLocationWrappers, location.SequenceNumber__c);

        updateRouteSchedule(loadingLocationWrapper, null, location);

        while ((loadingLocationWrapper = loadingLocationWrapper.nextLocation) != null) {
            updateCapacityAtStop(loadingLocationWrapper, route);
            loadingLocationWrapper.location.TriggerHandlerUpdate__c = true;
            toBeUpdatedloadingLocations.add(loadingLocationWrapper.location);
        }
    }

    public override void beforeUpdate(SObject oldSO, SObject newSO) {
        // Ensure after update only execute one for one update transaction
        if (counter > 0) {
            return;
        }
        counter++;

        LoadingLocation__c oldLocation = (LoadingLocation__c) oldSO;
        LoadingLocation__c location = (LoadingLocation__c) newSO;
        /*
            Setup relationship and validate
         */
        Route__c route = routeMap.get(location.Route__c);
        List<LoadingLocation__c> locations = route.LoadingLocation__r;

        // override the version from database by the new version
        for (Integer index = 0; index < locations.size(); index++) {
            if (locations.get(index).Id == location.Id) {
                locations.remove(index);
                locations.add(location);
                break;
            }
        }

        List<LoadingLocationWrapper> loadingLocationWrappers = sortAndLinkLocations(locations);
        LoadingLocationWrapper loadingLocationWrapper = getRoutLoadWrapperBySequence(loadingLocationWrappers, location.SequenceNumber__c);

        updateRouteSchedule(loadingLocationWrapper, oldLocation, location);

        /*
            If updating triggered by Trigger Handler or no change to load/unload information, just only update this
            record only. No synchronization is required.
         */

        if (location.TriggerHandlerUpdate__c == true || !isRequiredMassUpdate(oldLocation, location)) {
            location.TriggerHandlerUpdate__c = false;
            return;
        }

        /*
            Synchronize the load/unload for affected Loading Location causing by changes on this Loading Location.
         */
        String errorMessage = validate(loadingLocationWrapper, loadingLocationWrappers, route);

        if (String.isNotBlank(errorMessage)) {
            location.addError(errorMessage);
            return;
        }

        /*
            If the location is moved away from the first position, clear BEFORE LOAD for the new location moved to
            the first location.
         */
        if (loadingLocationWrappers.size() > 1) {
            if (oldLocation.SequenceNumber__c < loadingLocationWrappers.get(0).location.SequenceNumber__c
                    && location.SequenceNumber__c > loadingLocationWrappers.get(0).location.SequenceNumber__c) {
                loadingLocationWrappers.get(0).location.CargoMeasurementBefore__c = null;
                loadingLocationWrappers.get(0).location.CargoWeightBefore__c = null;
            }
        }
        
        for (LoadingLocationWrapper wrapper : loadingLocationWrappers) {
            updateCapacityAtStop(wrapper, route);

            if (wrapper.location.Id != loadingLocationWrapper.location.Id) {
                toBeUpdatedloadingLocations.add(wrapper.location);
            }
        }
    }

    public override void beforeDelete(SObject so) {
        LoadingLocation__c location = (LoadingLocation__c) so;
        Route__c route = routeMap.get(location.Route__c);
        List<LoadingLocation__c> locations = route.LoadingLocation__r;
        List<LoadingLocationWrapper> loadingLocationWrappers = sortAndLinkLocations(locations);
        removeRoutLoadWrapperBySequence(loadingLocationWrappers, location.SequenceNumber__c);

        String errorMessage = validate(null, loadingLocationWrappers, route);

        if (String.isNotBlank(errorMessage)) {
            location.addError(errorMessage);
            return;
        }
    }

    public override void afterDelete(SObject so) {
        LoadingLocation__c location = (LoadingLocation__c) so;
        Route__c route = routeMap.get(location.Route__c);
        List<LoadingLocation__c> locations = route.LoadingLocation__r;

        // add back the deleted record for processing with all relationships
        locations.add(location);

        List<LoadingLocationWrapper> loadingLocationWrappers = sortAndLinkLocations(locations);
        LoadingLocationWrapper loadingLocationWrapper = getRoutLoadWrapperBySequence(loadingLocationWrappers, location.SequenceNumber__c);

        /**
            Establish the relationship between remaining locations after a`location was deleted.
            If the deleted location was the first one, promote the next one to be the first hence reset before load
         */
        if (loadingLocationWrapper.prevLocation == null && loadingLocationWrapper.nextLocation != null) {
            loadingLocationWrapper.nextLocation.location.CargoWeightBefore__c = null;
            loadingLocationWrapper.nextLocation.location.CargoMeasurementBefore__c = null;
            loadingLocationWrapper.nextLocation.prevLocation = null; // no head

            updateRouteSchedule(loadingLocationWrapper.nextLocation, null, LoadingLocationWrapper.nextLocation.location);
        } else if (loadingLocationWrapper.prevLocation != null && loadingLocationWrapper.nextLocation == null) {
            loadingLocationWrapper.prevLocation.nextLocation = null; // no tail

            updateRouteSchedule(loadingLocationWrapper.prevLocation, null, LoadingLocationWrapper.prevLocation.location);
        } else if (loadingLocationWrapper.prevLocation != null && loadingLocationWrapper.nextLocation != null) {
            loadingLocationWrapper.prevLocation.nextLocation = loadingLocationWrapper.nextLocation;
            loadingLocationWrapper.nextLocation.prevLocation = loadingLocationWrapper.prevLocation;
        }

        /**
            update subsequent locations from the point a location was deleted
         */
        while ((loadingLocationWrapper = loadingLocationWrapper.nextLocation) != null) {
            updateCapacityAtStop(loadingLocationWrapper, route);
            loadingLocationWrapper.location.TriggerHandlerUpdate__c = true;
            toBeUpdatedloadingLocations.add(loadingLocationWrapper.location);
        }
    }

    public override void andFinally() {
        if (!toBeUpdatedloadingLocations.isEmpty()) {
            FlsService.doUpdate(new List<LoadingLocation__c>(toBeUpdatedloadingLocations));
        }

        if (!toBeUpdatedRoutes.values().isEmpty()) {
            FlsService.doUpdate(new List<Route__c>(toBeUpdatedRoutes.values()));
        }
    }

    private void updateRouteSchedule(LoadingLocationWrapper locationWrapper, LoadingLocation__c oldLocation, LoadingLocation__c newLocation) {
        /*
        Boolean requiredUpdatingRoute = false;
        Route__c route = routeMap.get(newLocation.Route__c);

        // populate/update Start Time for the Route
        if (locationWrapper.prevLocation == null) {
            if ((oldLocation == null)
                    || (oldLocation.ActualStartTime__c != newLocation.ActualStartTime__c
                    || oldLocation.StartingTime__c != newLocation.StartingTime__c)) {
                requiredUpdatingRoute = true;
                route.StartTime__c = newLocation.ActualStartTime__c != null ? newLocation.ActualStartTime__c : newLocation.StartingTime__c;
            }
        }

        // populate/update End Time for the Route
        if (locationWrapper.nextLocation == null) {
            if ((oldLocation == null)
                    || (oldLocation.ActualArrivalTime__c != newLocation.ActualArrivalTime__c
                    || oldLocation.ArrivalTime__c != newLocation.ArrivalTime__c)) {
                requiredUpdatingRoute = true;
                route.EndTime__c = newLocation.ActualArrivalTime__c != null ? newLocation.ActualArrivalTime__c : newLocation.ArrivalTime__c;
            }
        }

        if (requiredUpdatingRoute) {
            if (!toBeUpdatedRoutes.containsKey(route.Id)) {
                toBeUpdatedRoutes.put(route.Id, route);
            }
        }
        */
    }

    private void loadReferenceData(List<LoadingLocation__c> loadingLocations) {
        Set<Id> routeIds = new Set<Id>();

        for (LoadingLocation__c location : loadingLocations) {
            routeIds.add(location.Route__c);
        }

        routeMap = new Map<Id, Route__c>([
                SELECT Id, Name, Truck__r.MaximumMeasurement__c, Truck__r.MaximumWeight__c,
                        Chassis__r.MaximumMeasurement__c, Chassis__r.MaximumWeight__c, (
                        SELECT CargoMeasurement__c, CargoMeasurementAfter__c, CargoMeasurementBefore__c, RemainingMeasurement__c,
                                HandlingType__c, CargoWeight__c, CargoWeightBefore__c, CargoWeightAfter__c,
                                RemainingWeight__c, SequenceNumber__c, Route__c, StartingTime__c, ArrivalTime__c, ActualStartTime__c, ActualArrivalTime__c
                        FROM LoadingLocation__r
                        ORDER BY SequenceNumber__c ASC
                )
                FROM Route__c
                WHERE Id IN :routeIds
        ]);
    }

    /**
        Check whether changes to a location will require to update subsequent locations.
        Such as sequence number, weight, etc.
     */
    private Boolean isRequiredMassUpdate(LoadingLocation__c oldLocation, LoadingLocation__c newLocation) {
        return (oldLocation.SequenceNumber__c != newLocation.SequenceNumber__c
                || oldLocation.CargoWeight__c != newLocation.CargoWeight__c || oldLocation.CargoWeightBefore__c != newLocation.CargoWeightBefore__c
                || oldLocation.CargoMeasurement__c != newLocation.CargoMeasurement__c || oldLocation.CargoMeasurementBefore__c != newLocation.CargoMeasurementBefore__c);
    }

    private String validate(LoadingLocationWrapper loadingLocationWrapper, List<LoadingLocationWrapper> loadingLocationWrappers, Route__c route) {
        if (loadingLocationWrapper != null) {
            if (loadingLocationWrapper.location.Route__c == null) {
                return translationService.getTranslation('REQUIRED_ROUTE', 'ROUTE & LOAD must be set');
            }

            Decimal loadUnloadWeight = (loadingLocationWrapper.location.CargoWeight__c != null ? loadingLocationWrapper.location.CargoWeight__c : 0);
            Decimal loadUnloadMeasurement = (loadingLocationWrapper.location.CargoMeasurement__c != null ? loadingLocationWrapper.location.CargoMeasurement__c : 0);

            if (loadingLocationWrapper.location.SequenceNumber__c == null) {
                return translationService.getTranslation('REQUIRED_SEQUENCE_NUMBER', 'SEQUENCE NUMBER is required.');
            } else if (loadingLocationWrapper.location.CargoMeasurement__c < 0 || loadingLocationWrapper.location.CargoWeight__c < 0) {
                return translationService.getTranslation('NEGATIVE_NUMBER', 'Measurement and Weight cannot be negative.');
            } else if (loadingLocationWrappers != null || loadingLocationWrappers.size() > 0) {
                for (LoadingLocationWrapper ll : loadingLocationWrappers) {
                    if (ll.location.SequenceNumber__c == loadingLocationWrapper.location.SequenceNumber__c && ll.location.Id != loadingLocationWrapper.location.Id) {
                        return translationService.getTranslation('DUPLICATED_SEQUENCE_NUMBER', 'Duplicated SEQUENCE NUMBER');
                    }
                }
            }
        }

        if (loadingLocationWrappers != null && !loadingLocationWrappers.isEmpty()) {
            return validateCapacity(loadingLocationWrappers, route);
        } else {
            return null;
        }
    }

    private String validateCapacity(List<LoadingLocationWrapper> loadingLocationWrappers, Route__c route) {
        String errorMessage = null;
/*
        if (CAPACITY_VALIDATION_ENABLED) {
            Decimal truckCBMCapacity = (route.Chassis__r != null ? (route.Chassis__r.MaximumMeasurement__c != null ? route.Chassis__r.MaximumMeasurement__c : 0)
                    : (route.Truck__r.MaximumMeasurement__c != null ? route.Truck__r.MaximumMeasurement__c : 0));
            Decimal truckKGCapacity = (route.Chassis__r != null ? (route.Chassis__r.MaximumWeight__c != null ? route.Chassis__r.MaximumWeight__c : 0)
                    : (route.Truck__r.MaximumWeight__c != null ? route.Truck__r.MaximumWeight__c : 0)) * TRUCK_WEIGHT_UNIT_TO_KG;
            Decimal currentKGCapacity = (loadingLocationWrappers.get(0).location.CargoWeightBefore__c != null ? loadingLocationWrappers.get(0).location.CargoWeightBefore__c : 0);
            Decimal currentCBMCapacity = (loadingLocationWrappers.get(0).location.CargoMeasurementBefore__c != null ? loadingLocationWrappers.get(0).location.CargoMeasurementBefore__c : 0);

            for (LoadingLocationWrapper loadingLocationWrapper : loadingLocationWrappers) {
                if (TRUCK_HANDLE_LOAD.equalsIgnoreCase(loadingLocationWrapper.location.HandlingType__c)
                        || TRUCK_HANDLE_PARTITAL_LOAD.equalsIgnoreCase(loadingLocationWrapper.location.HandlingType__c)) {
                    currentCBMCapacity += (loadingLocationWrapper.location.CargoMeasurement__c != null ? loadingLocationWrapper.location.CargoMeasurement__c : 0);
                    currentKGCapacity += (loadingLocationWrapper.location.CargoWeight__c != null ? loadingLocationWrapper.location.CargoWeight__c : 0);
                } else if (TRUCK_HANDLE_UNLOAD.equalsIgnoreCase(loadingLocationWrapper.location.HandlingType__c)
                        || TRUCK_HANDLE_PARTIAL_UNLOAD.equalsIgnoreCase(loadingLocationWrapper.location.HandlingType__c)) {
                    currentCBMCapacity -= (loadingLocationWrapper.location.CargoMeasurement__c != null ? loadingLocationWrapper.location.CargoMeasurement__c : 0);
                    currentKGCapacity -= (loadingLocationWrapper.location.CargoWeight__c != null ? loadingLocationWrapper.location.CargoWeight__c : 0);
                }

                if (currentCBMCapacity > truckCBMCapacity) {
                    errorMessage = 'Measurement is overloaded from SEQUENCE NUMBER ' + loadingLocationWrapper.location.SequenceNumber__c;
                } else if (currentKGCapacity > truckKGCapacity) {
                    errorMessage = 'Weight is overloaded from SEQUENCE NUMBER ' + loadingLocationWrapper.location.SequenceNumber__c;
                } else if (currentCBMCapacity < 0) {
                    errorMessage = 'Measurement is over unloaded from SEQUENCE NUMBER ' + loadingLocationWrapper.location.SequenceNumber__c;
                } else if (currentKGCapacity < 0) {
                    errorMessage = 'Weight is over unloaded from SEQUENCE NUMBER ' + loadingLocationWrapper.location.SequenceNumber__c;
                }
            }
        }*/

        return errorMessage;
    }

    private LoadingLocationWrapper getRoutLoadWrapperBySequence(List<LoadingLocationWrapper> wrappers, Decimal sequenceNumber) {
        if (wrappers != null && !wrappers.isEmpty()) {
            for (LoadingLocationWrapper wrapper : wrappers) {
                if (wrapper.location.SequenceNumber__c == sequenceNumber) {
                    return wrapper;
                }
            }
        }

        return null;
    }

    private void removeRoutLoadWrapperBySequence(List<LoadingLocationWrapper> wrappers, Decimal sequenceNumber) {
        if (wrappers != null && !wrappers.isEmpty()) {
            Integer size = wrappers.size();
            Integer toBeRemovedIndex = -1;

            for (Integer index = 0; index < size; index++) {
                if (wrappers.get(index).location.SequenceNumber__c == sequenceNumber) {
                    toBeRemovedIndex = index;
                    break;
                }
            }

            if (toBeRemovedIndex >= 0) {
                wrappers.remove(toBeRemovedIndex);
            }
        }
    }

    private List<LoadingLocationWrapper> sortAndLinkLocations(List<LoadingLocation__c> locations) {
        List<LoadingLocationWrapper> loadingLocationWrappers = new List<LoadingLocationWrapper>();

        for (LoadingLocation__c location : locations) {
            loadingLocationWrappers.add(new LoadingLocationWrapper(location));
        }

        loadingLocationWrappers.sort();

        Integer size = loadingLocationWrappers.size();
        for (Integer i = 0; i < size; i++) {
            if (i > 0) {
                loadingLocationWrappers.get(i).prevLocation = loadingLocationWrappers.get(i - 1);
            }

            if (i < size - 1) {
                loadingLocationWrappers.get(i).nextLocation = loadingLocationWrappers.get(i + 1);
            }
        }

        return loadingLocationWrappers;
    }

    /**
        Update the capacity of the truck at each stop to load or unload.
        Information to be updated will be truck capacity before and after, capacitity to be loaded/unloaded and
        remaining capacity of the truck.
     */
    private void updateCapacityAtStop(LoadingLocationWrapper wrapper, Route__c route) {
        LoadingLocationWrapper prevLoadingLocationWrapper = wrapper.prevLocation;
        Decimal truckWeight = (route.Chassis__r != null ? (route.Chassis__r.MaximumWeight__c != null ? route.Chassis__r.MaximumWeight__c : 0)
                : (route.Truck__r.MaximumWeight__c != null ? route.Truck__r.MaximumWeight__c : 0)) * TRUCK_WEIGHT_UNIT_TO_KG;
        Decimal truckMeasurement = (route.Chassis__r != null ? (route.Chassis__r.MaximumMeasurement__c != null ? route.Chassis__r.MaximumMeasurement__c : 0)
                : (route.Truck__r.MaximumMeasurement__c != null ? route.Truck__r.MaximumMeasurement__c : 0));
        Decimal loadedMeasement = 0;
        Decimal loadedWeight = 0;

        if (prevLoadingLocationWrapper != null) {
            loadedWeight = (prevLoadingLocationWrapper.location.CargoWeightAfter__c != null ? prevLoadingLocationWrapper.location.CargoWeightAfter__c : 0);
            loadedMeasement = (prevLoadingLocationWrapper.location.CargoMeasurementAfter__c != null ? prevLoadingLocationWrapper.location.CargoMeasurementAfter__c : 0);

            Decimal addOrSub = 1;

            if (TRUCK_HANDLE_UNLOAD.equalsIgnoreCase(wrapper.location.HandlingType__c)
                    || TRUCK_HANDLE_PARTIAL_UNLOAD.equalsIgnoreCase(wrapper.location.HandlingType__c)) {
                addOrSub = -1;
            }

            wrapper.location.CargoMeasurementBefore__c = loadedMeasement;
            wrapper.location.CargoMeasurementAfter__c = loadedMeasement + addOrSub * (wrapper.location.CargoMeasurement__c != null ? wrapper.location.CargoMeasurement__c : 0);
            wrapper.location.RemainingMeasurement__c = truckMeasurement - wrapper.location.CargoMeasurementAfter__c;

            wrapper.location.CargoWeightBefore__c = loadedWeight;
            wrapper.location.CargoWeightAfter__c = loadedWeight + addOrSub * (wrapper.location.CargoWeight__c != null ? wrapper.location.CargoWeight__c : 0);
            wrapper.location.RemainingWeight__c = truckWeight - wrapper.location.CargoWeightAfter__c;
        } else {
            loadedMeasement = (wrapper.location.CargoMeasurementBefore__c != null ? wrapper.location.CargoMeasurementBefore__c : 0);
            loadedWeight = (wrapper.location.CargoWeightBefore__c != null ? wrapper.location.CargoWeightBefore__c : 0);

            wrapper.location.CargoMeasurementAfter__c = loadedMeasement + (wrapper.location.CargoMeasurement__c != null ? wrapper.location.CargoMeasurement__c : 0);
            wrapper.location.RemainingMeasurement__c = truckMeasurement - wrapper.location.CargoMeasurementAfter__c;

            wrapper.location.CargoWeightAfter__c = loadedWeight + (wrapper.location.CargoWeight__c != null ? wrapper.location.CargoWeight__c : 0);
            wrapper.location.RemainingWeight__c = truckWeight - wrapper.location.CargoWeightAfter__c;
        }
    }

    /**
        This is the wrapper for Route & Load custom object. It is created to provide sorting, linking (head/tail) capabilities.
        The default sorting will be ascending by SEQUENCE NUMBER.
        For each instance, it can help just head, tail, both or none.
     */
    public class LoadingLocationWrapper implements Comparable {
        public LoadingLocation__c location { get; private set; }
        public LoadingLocationWrapper prevLocation { get; set; }
        public LoadingLocationWrapper nextLocation { get; set; }

        public LoadingLocationWrapper(LoadingLocation__c location) {
            this.location = location;
        }

        public Integer compareTo(Object obj) {
            LoadingLocationWrapper other = (LoadingLocationWrapper) obj;

            if (location.SequenceNumber__c == other.location.SequenceNumber__c) {
                return 0;
            } else if (location.SequenceNumber__c > other.location.SequenceNumber__c) {
                return 1;
            } else {
                return -1;
            }
        }
    }
}