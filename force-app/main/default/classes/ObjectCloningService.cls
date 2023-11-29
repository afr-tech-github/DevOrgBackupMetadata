/**
 * This is a webservice to clone object
 *
 * Created by khanhpham on 5/5/17.
 */

global with sharing class ObjectCloningService {
    webService static String cloneDeepRoute(final String routeId) {
        String clonedRouteId = cloneRoute(routeId);

        if (String.isNotBlank(clonedRouteId)) {
            cloneLoadLocationsByRoute(routeId, clonedRouteId);
        }

        return clonedRouteId;
    }

    private static void cloneLoadLocationsByRoute(final String routeId, final String clonedRouteId) {
        Schema.SObjectType objectType = LoadingLocation__c.Schema.SObjectType;
        String query = 'SELECT Id, Name, ' + getCustomFieldNames(objectType)
                + ' FROM ' + objectType
                + ' WHERE Route__r.Id =\'' + routeId + '\'';
        List<LoadingLocation__c> loadingLocationList = Database.query(query);

        if (loadingLocationList != null && !loadingLocationList.isEmpty()) {
            List<LoadingLocation__c> clonedLoadingLocationList = loadingLocationList.deepClone();

            if (clonedLoadingLocationList != null && !clonedLoadingLocationList.isEmpty()) {
                for (LoadingLocation__c location : clonedLoadingLocationList) {
                    location.Route__c = clonedRouteId;

                    /*
                        Reset fields
                     */
                    location.LoadingUnloadingStatus__c = null;
                    location.ActualStartTime__c = null;
                    location.ActualArrivalTime__c = null;
                    location.StartingTime__c = null;
                    location.ArrivalTime__c = null;
                }

                FlsService.doInsert(clonedLoadingLocationList);
            }
        }
    }

    private static String cloneRoute(final String routeId) {
        Schema.SObjectType objectType = Route__c.Schema.SObjectType;
        String query = 'SELECT Id, Name, ' + getCustomFieldNames(objectType)
                + ' FROM ' + objectType
                + ' WHERE Id =\'' + routeId + '\'';
        List<Route__c> routeList = Database.query(query);

        if (routeList != null && !routeList.isEmpty()) {
            List<Route__c> clonedRouteList = routeList.deepClone();

            if (clonedRouteList != null && !clonedRouteList.isEmpty()) {
                FlsService.doInsert(clonedRouteList);
                return clonedRouteList.get(0).Id;
            }
        }

        return null;
    }

    private static String getCustomFieldNames(Schema.SObjecttype tp){
        List<String> customFieldNames = new List<String>();

        Map<String,Schema.sObjectField> fmap = tp.getDescribe().fields.getMap();
        for(String fn:fmap.keySet()){
            if(fn.endswith('__c')){
                customFieldNames.add(fn);
            }
        }
        return String.join(customFieldNames, ',');
    }
}