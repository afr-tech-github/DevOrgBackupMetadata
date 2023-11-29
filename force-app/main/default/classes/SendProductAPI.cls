@RestResource(urlMapping='/api/product')
global with sharing class SendProductAPI {
    @HttpGet
    global static String doGetProductPricing() {
    	try{
            List<JsonObject> lstProductJson = new List<JsonObject>();
        	List<clofor_com_cfs__PRODUCT__c> lstProduct = new List<clofor_com_cfs__PRODUCT__c>();
            lstProduct = [SELECT Id
                          				,Name
                                        ,clofor_com_cfs__ProductName__c
                                        ,clofor_com_cfs__External_ID__c
                                        ,clofor_com_cfs__UnitType__c
                                        ,clofor_com_cfs__Active__c
                          				,clofor_com_cfs__IntegrationRequired__c
                          				,clofor_com_cfs__ProductScaleCode__c
                                FROM clofor_com_cfs__PRODUCT__c 
                                WHERE clofor_com_cfs__IntegrationRequired__c = true];
            for(clofor_com_cfs__PRODUCT__c pro : lstProduct){
                pro.clofor_com_cfs__IntegrationRequired__c = false;
                lstProductJson.add(new JsonObject(pro));
                
            }
            return System.JSON.serialize(lstProductJson);
            
        }catch(Exception ex){
            // Create error
            clofor_com_cfs__Call_Out_Error__c error = CreateData.createError('PRODUCT API');
            error.clofor_com_cfs__Error_Content__c 	= ex.getMessage();
            error.clofor_com_cfs__Error_Content__c 	+= ex.getLineNumber();
            error.clofor_com_cfs__Error_Content__c 	+= ex.getStackTraceString();
            error.clofor_com_cfs__Error_Content__c 	+= ex.getTypeName();
		    FlsService.doUpsert(error);
            return 'Error';
        }
    }
    
  public class JsonObject{
		Private String  ProductPricingId{get; set;}
        Private String  ProductName{get; set;}
        Private String  ExternalId{get; set;}
		Private String  UnitType{get; set;}
		Private Boolean Active{get; set;}
      	Private String  ProductScaleCode{get; set;}
        private JsonObject(clofor_com_cfs__PRODUCT__c recProduct){
            ProductPricingId	= recProduct.Name; 
			ProductName			= recProduct.clofor_com_cfs__ProductName__c;
			ExternalId			= recProduct.clofor_com_cfs__External_ID__c;
            UnitType			= recProduct.clofor_com_cfs__UnitType__c;
            Active 				= recProduct.clofor_com_cfs__Active__c;
            ProductScaleCode	= recProduct.clofor_com_cfs__ProductScaleCode__c;
		}
	}
}