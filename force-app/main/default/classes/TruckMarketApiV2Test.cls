@isTest
private class TruckMarketApiV2Test {
	static PRODUCT__c prod;
	static PRODUCT__c prod1;
	static Account acc;
	static Facility__c fac;
	static Facility__c fac1;
	static Facility__c fac2;
    static Map<String, Object> apiRequest;
	
	static void queryTestData() {
		fac   = [SELECT Id, FacExternalID__c FROM Facility__c WHERE FacExternalID__c = 'Origin' LIMIT 1];
		fac1  = [SELECT Id, FacExternalID__c FROM Facility__c WHERE FacExternalID__c = 'Destination1' LIMIT 1];
		fac2  = [SELECT Id, FacExternalID__c FROM Facility__c WHERE FacExternalID__c = 'Destination2' LIMIT 1];
		prod  = [SELECT Id, Name, QR_Code__c FROM Product__c WHERE ProductName__c = 'prod' LIMIT 1];
		prod1 = [SELECT Id, Name, QR_Code__c FROM Product__c WHERE ProductName__c = 'prod1' LIMIT 1];
		acc   = [SELECT Id, EnglishCompanyName__c FROM Account LIMIT 1];
        
		apiRequest = new Map<String, Object> {
            'Warehouses' => new Object[] {
                new Map<String, Object> {
                    'OriginWarehouseID' => fac.FacExternalID__c,
                    'AccountName' => acc.EnglishCompanyName__c,
                    'Destinations' => new Object[] {
                        new Map<String, Object> {
                            'DestinationWarehouseID' => fac1.FacExternalID__c,
                            'Customers' => new Object[] {},
                            'ProductOrder' => new Object[] {
                                new Map<String, Object> { 'ProductID' => prod.Name, 'Amount' => 3 },
                                new Map<String, Object> { 'ProductID' => prod1.Name, 'Amount' => 7000 }
                            }
                        },
                        new Map<String, Object> {
                            'DestinationWarehouseID' => fac2.FacExternalID__c,
                            'Customers' => new Object[] {},
                            'ProductOrder' => new Object[] {
                                new Map<String, Object> { 'ProductID' => prod.Name, 'Amount' => 4 },
                                new Map<String, Object> { 'ProductID' => prod1.Name, 'Amount' => 8000 }
                            }
                        }
                    }
                }
            }
        };
	}

    @TestSetUp static void testSetup(){
        fac   = new Facility__c(FacExternalID__c = 'Origin');
        fac1  = new Facility__c(FacExternalID__c = 'Destination1');
        fac2  = new Facility__c(FacExternalID__c = 'Destination2');
        prod  = new Product__c(ProductName__c = 'prod', BillingType__c = 'Unit', WeightUnit__c = 'g', BuyingWeightUnit__c = 'Kg', MaintenanceServiceBillingFreqType__c = 'Continuous Billing',
                              GuaranteeServiceBillingFreqType__c = 'Continuous Billing',DeliveryServiceBillingFreqType__c = 'Continuous Billing', 
                                 InstallationServiceBillingFreqType__c = 'Continuous Billing',SetupServiceBillingFreqType__c = 'Continuous Billing',
                                 RelocationServiceBillingFreqType__c = 'Continuous Billing',ReplacementServiceBillingFreqType__c = 'Continuous Billing',
                                 SupportServiceBillingFreqType__c = 'Continuous Billing',SubscriptionChargeBillingFreqType__c = 'Continuous Billing',
                                 UsageChargeBillingFreqType__c = 'Continuous Billing');
        prod1 = new Product__c(ProductName__c = 'prod1', BillingType__c = 'Weight', WeightUnit__c = 'g', BuyingWeightUnit__c = 'Kg', MaintenanceServiceBillingFreqType__c = 'Continuous Billing',
                              GuaranteeServiceBillingFreqType__c = 'Continuous Billing',DeliveryServiceBillingFreqType__c = 'Continuous Billing', 
                                 InstallationServiceBillingFreqType__c = 'Continuous Billing',SetupServiceBillingFreqType__c = 'Continuous Billing',
                                 RelocationServiceBillingFreqType__c = 'Continuous Billing',ReplacementServiceBillingFreqType__c = 'Continuous Billing',
                                 SupportServiceBillingFreqType__c = 'Continuous Billing',SubscriptionChargeBillingFreqType__c = 'Continuous Billing',
                                 UsageChargeBillingFreqType__c = 'Continuous Billing');
        acc   = new Account(name = 'testAcc', EnglishCompanyName__c = 'testAcc');

        FlsService.doInsert(new List<SObject> { prod, prod1, acc, fac, fac1, fac2, new Contract__c() });
    }
    
    @IsTest static void test(){
        queryTestData();

        Test.startTest();
        TruckMarketWrapper.TruckMarketResponse apiResponse = new TruckMarketApiV2.TruckMarketApiService().execute(JSON.serialize(apiRequest));
        Test.stopTest();

        System.assert(apiResponse.status);
    }
}