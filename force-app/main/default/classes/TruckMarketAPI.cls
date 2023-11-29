@RestResource(urlMapping='/truckmarket')
global with sharing class TruckMarketAPI {
	@HttpPOST
    global static string insertProductPerTruck() {
        return ProcessInsertProductPerTruck(RestContext.request.requestBody.tostring());
    }
    
    public static String ProcessInsertProductPerTruck(String bodyRequest){
        //DEPRECATED
        return null;
    }
}