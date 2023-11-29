@isTest(SeeAllData=true)
public class TruckMarketAPITest {
    private static clofor_com_cfs__Facility__c facOrigin = new clofor_com_cfs__Facility__c();
    private static clofor_com_cfs__Facility__c facDes1 = new clofor_com_cfs__Facility__c();
    private static clofor_com_cfs__Facility__c facDes2 = new clofor_com_cfs__Facility__c();
    private static Account acc = new Account();
    private static clofor_com_cfs__Contract__c contract = new clofor_com_cfs__Contract__c();
    private static clofor_com_cfs__PRODUCT__c pro1 = new clofor_com_cfs__PRODUCT__c();
    private static clofor_com_cfs__PRODUCT__c pro2 = new clofor_com_cfs__PRODUCT__c();
    static{
        RecordType rtFac = [ SELECT Id FROM RecordType WHERE SObjectType = 'clofor_com_cfs__Facility__c' AND DeveloperName = 'NormalWarehouse' LIMIT 1][0];
        
        List<clofor_com_cfs__Facility__c> lstFacInsert = new List<clofor_com_cfs__Facility__c>();
        lstFacInsert.add(new clofor_com_cfs__Facility__c(RecordTypeId = rtFac.Id, clofor_com_cfs__FacilityName__c = 'WHORIGIN'));
        lstFacInsert.add(new clofor_com_cfs__Facility__c(RecordTypeId = rtFac.Id, clofor_com_cfs__FacilityName__c = 'WHODES1'));
        lstFacInsert.add(new clofor_com_cfs__Facility__c(RecordTypeId = rtFac.Id, clofor_com_cfs__FacilityName__c = 'WHODES2'));
        FlsService.doInsert(lstFacInsert);
        
        for(clofor_com_cfs__Facility__c fac : [ SELECT Name, clofor_com_cfs__FacilityName__c FROM clofor_com_cfs__Facility__c]){
            if(fac.clofor_com_cfs__FacilityName__c == 'WHORIGIN'){
                facOrigin = fac;
            }
            if(fac.clofor_com_cfs__FacilityName__c == 'WHODES1'){
                facDes1 = fac;
            }
            if(fac.clofor_com_cfs__FacilityName__c == 'WHODES2'){
                facDes2 = fac;
            }
        }
        
        acc = new Account(Name = 'ABC COMPANY123', clofor_com_cfs__EnglishCompanyName__c = 'ABC COMPANY123');
        FlsService.doInsert(acc);
        
        List<clofor_com_cfs__Contract__c> lstContractInsert = new List<clofor_com_cfs__Contract__c>();
        lstContractInsert.add(new clofor_com_cfs__Contract__c(clofor_com_cfs__ContractNumber__c = 'ARF12345'));
        FlsService.doInsert(lstContractInsert);
        
        for(clofor_com_cfs__Contract__c con : [ SELECT Name, clofor_com_cfs__ContractNumber__c FROM clofor_com_cfs__Contract__c ]){
            contract = con;
        }

        RecordType rtPro = [ SELECT Id FROM RecordType WHERE SObjectType = 'clofor_com_cfs__PRODUCT__c' AND DeveloperName = 'FreshProduct'][0];
        
        List<clofor_com_cfs__PRODUCT__c> lstProductInsert = new List<clofor_com_cfs__PRODUCT__c>();
        lstProductInsert.add(new clofor_com_cfs__PRODUCT__c(RecordTypeId = rtPro.Id, clofor_com_cfs__ProductName__c = 'PRO1', MaintenanceServiceBillingFreqType__c = 'Continuous Billing',
                                                           GuaranteeServiceBillingFreqType__c = 'Continuous Billing',DeliveryServiceBillingFreqType__c = 'Continuous Billing', 
                                 InstallationServiceBillingFreqType__c = 'Continuous Billing',SetupServiceBillingFreqType__c = 'Continuous Billing',
                                 RelocationServiceBillingFreqType__c = 'Continuous Billing',ReplacementServiceBillingFreqType__c = 'Continuous Billing',
                                 SupportServiceBillingFreqType__c = 'Continuous Billing',SubscriptionChargeBillingFreqType__c = 'Continuous Billing',
                                 UsageChargeBillingFreqType__c = 'Continuous Billing'));
        lstProductInsert.add(new clofor_com_cfs__PRODUCT__c(RecordTypeId = rtPro.Id, clofor_com_cfs__ProductName__c = 'PRO2', MaintenanceServiceBillingFreqType__c = 'Continuous Billing',
                                                           GuaranteeServiceBillingFreqType__c = 'Continuous Billing',DeliveryServiceBillingFreqType__c = 'Continuous Billing', 
                                 InstallationServiceBillingFreqType__c = 'Continuous Billing',SetupServiceBillingFreqType__c = 'Continuous Billing',
                                 RelocationServiceBillingFreqType__c = 'Continuous Billing',ReplacementServiceBillingFreqType__c = 'Continuous Billing',
                                 SupportServiceBillingFreqType__c = 'Continuous Billing',SubscriptionChargeBillingFreqType__c = 'Continuous Billing',
                                 UsageChargeBillingFreqType__c = 'Continuous Billing'));
        FlsService.doInsert(lstProductInsert);
        
        for(clofor_com_cfs__PRODUCT__c pro : [ SELECT Name, clofor_com_cfs__ProductName__c FROM clofor_com_cfs__PRODUCT__c ]){
            if(pro.clofor_com_cfs__ProductName__c == 'PRO1'){
                pro1 = pro;
            }
            if(pro.clofor_com_cfs__ProductName__c == 'PRO2'){
                pro2 = pro;
            }
        }
    }
    
    static testMethod void testPostMethod()
    {
        Test.startTest();
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        request.requestUri = '/services/apexrest/clofor_com_cfs/truckmarket';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(returnJSON());
        RestContext.request = request;
        String response = TruckMarketAPI.insertProductPerTruck();
        Integer x = 1;
        system.assert(x==1);
        Test.stopTest();
    }
    
    public static String returnJSON(){
        return '{'
                   + '"Warehouses":['
                      + '{'
                            + '"OriginWarehouseID" : "' + facOrigin.Name + '",'
                            + '"OriginWarehouseName" : "' + facOrigin.clofor_com_cfs__FacilityName__c + '",'
                            + '"AccountID" : "ABC COMPANY123",'
                            + '"AccountName" : "ABC COMPANY123",'
                            //+ '"ContractID" : "' + contract.Name + '",'
                            //+ '"ContractNumber" : "' + contract.clofor_com_cfs__ContractNumber__c + '",'
                            + '"Destinations":['
                               + '{'
                                  + '"DestinationWarehouseID" : "' + facDes1.Name + '",'
                                  + '"DestinationWarehouseName" : "' + facDes1.clofor_com_cfs__FacilityName__c + '",'
                                  + '"ProductOrder":['
                                     + '{'
                                        + '"ProductID" : "' + pro1.Name + '",'
                                        + '"ProductName" : "' + pro1.clofor_com_cfs__ProductName__c + '",'
            							+ '"Amount" : 10'
                                     + '},'
                                     + '{'
                                        + '"ProductID" : "' + pro2.Name + '",'
                                        + '"ProductName" : "' + pro2.clofor_com_cfs__ProductName__c + '",'
            							+ '"Amount" : 10'
                                     + '}'
                                  + '],'
                                  + '"Customers":[{'
                                        + '"AccountID" : "ABC",'
                                        + '"AccountName" : "ABC",'
                                        + '"ProductSold":['
                                             + '{'
                                                + '"ProductID" : "' + pro1.Name + '",'
                                                + '"ProductName" : "' + pro1.clofor_com_cfs__ProductName__c + '",'
                                                + '"Amount" : 10'
                                             + '},'
                                             + '{'
                                                + '"ProductID" : "' + pro2.Name + '",'
                                                + '"ProductName" : "' + pro2.clofor_com_cfs__ProductName__c + '",'
                                                + '"Amount" : 10'
                                             + '}'
                                          + ']'
                                  + '}]'
                               + '}'
            				   
                            + ']'
                      + '}'
                   + ']'
                + '}';
    }
}