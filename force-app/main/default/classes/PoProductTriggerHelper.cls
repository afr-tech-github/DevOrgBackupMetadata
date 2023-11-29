public with sharing class PoProductTriggerHelper {
    public static void autoPopulateFields(List<GoodsPOProduct__c> listNew, Map<Id, GoodsPOProduct__c> mapOld) {
        Set<Id> setFromProduct = new Set<Id> ();
        List<GoodsPOProduct__c> listProcess = new List<GoodsPOProduct__c>();
        for (GoodsPOProduct__c item : listNew) {
            if (item.ProductId__c != null) {
                setFromProduct.add(item.ProductID__c);
                listProcess.add(item);
            }
        }
        Map<Id, Product__c> mapFromProdduct = new Map<Id, Product__c>([
            SELECT Id, BillingType__c, BuyingWeightUnit__c, NETWeight__c, Measurement__c, GrossWeight__c, TaxRateBuying__c, BuyingCommercialValuePerUnitLocal__c, BuyingUnitPriceLocalKg__c
            FROM Product__c 
            WHERE Id IN :setFromProduct
        ]);
        
        for (GoodsPOProduct__c item : listProcess) {
            //TODO move this first code block outside of loop
            Product__c prod = mapFromProdduct.get(item.ProductId__c);
            prod.NETWeight__c = prod.NETWeight__c == null ? 0 : prod.NETWeight__c;
            prod.GrossWeight__c = prod.GrossWeight__c == null ? 0 : prod.GrossWeight__c;
            prod.Measurement__c = prod.Measurement__c == null ? 0 : prod.Measurement__c;
            prod.TaxRateBuying__c = prod.TaxRateBuying__c == null ? 0 : prod.TaxRateBuying__c;
            prod.BuyingCommercialValuePerUnitLocal__c = prod.BuyingCommercialValuePerUnitLocal__c == null ? 0 : prod.BuyingCommercialValuePerUnitLocal__c;
            prod.BuyingUnitPriceLocalKg__c = prod.BuyingUnitPriceLocalKg__c == null ? 0 : prod.BuyingUnitPriceLocalKg__c;
            Decimal prodNetWeight = Util.ConvertWeightToUnit('Kg', prod.BuyingWeightUnit__c, prod.NETWeight__c);
            Decimal prodGrossWeight = Util.ConvertWeightToUnit('Kg', prod.BuyingWeightUnit__c, prod.GrossWeight__c);
            
            item.Quantity__c = item.Quantity__c == null ? 1 : item.Quantity__c;
            item.RecommendNetWeight__c = item.RecommendNetWeight__c == null ? 0 : item.RecommendNetWeight__c;

            //Uniprodt-based -> Calculate recommended weight from Recommended Quantity, Planned weight from planned quantity
            if (prod.BillingType__c == 'Unit') {
                if (item.PlanQuantity__c == null && item.Quantity__c > 0) {
                    item.PlanQuantity__c = item.Quantity__c;
                }
                //Measurement, gross weight, total amount of buying are populated in the following priority: Final > Plan > Recommend; set value in the reverse order to ensure the correct final value
                //recommend net weight
                if (item.Quantity__c > 0) {
                    item.RecommendNetWeight__c = item.Quantity__c * prodNetWeight;
                    item.TotalMeasurement__c = item.Quantity__c * prod.Measurement__c;
                    item.TotalGrossWeight__c = item.Quantity__c * prod.GrossWeight__c;
                    item.TotalAmountOfBuying__c = item.Quantity__c * prod.BuyingCommercialValuePerUnitLocal__c;
                }
                //planned net weight
                if (item.PlanQuantity__c > 0) {
                    item.TotalNetWeight__c = item.PlanQuantity__c * prodNetWeight;
                    item.TotalMeasurement__c = item.PlanQuantity__c * prod.Measurement__c;
                    item.TotalGrossWeight__c = item.PlanQuantity__c * prod.GrossWeight__c;
                    item.TotalAmountOfBuying__c = item.PlanQuantity__c * prod.BuyingCommercialValuePerUnitLocal__c;
                }
                //final net weight
                if (item.FinalQuantity__c > 0) {
                    item.FinalNetWeight__c = item.FinalQuantity__c * prodNetWeight;
                    item.TotalMeasurement__c = item.FinalQuantity__c * prod.Measurement__c;
                    item.TotalGrossWeight__c = item.FinalQuantity__c * prod.GrossWeight__c;
                    item.TotalAmountOfBuying__c = item.FinalQuantity__c * prod.BuyingCommercialValuePerUnitLocal__c;
                }
            } 
            //Weight-based -> RecommendNetWeight__c is populated
            else if (prod.BillingType__c == 'Weight' && (prod.NETWeight__c == null || prod.NETWeight__c == 0)) {
                if (item.TotalNetWeight__c == null && item.RecommendNetWeight__c > 0) {
                    item.TotalNetWeight__c = Util.ConvertWeightToUnit('Kg', prod.BuyingWeightUnit__c, item.RecommendNetWeight__c);
                }
                Decimal currentWeight = item.FinalNetWeight__c > 0 ? item.FinalNetWeight__c : item.TotalNetWeight__c > 0 ? item.TotalNetWeight__c : item.RecommendNetWeight__c;
                if (item.RecommendNetWeight__c > 0) {
                    item.Quantity__c = 1;
                    item.TotalAmountOfBuying__c = Util.ConvertWeightToUnit(prod.BuyingWeightUnit__c, 'Kg', item.RecommendNetWeight__c) * prod.BuyingUnitPriceLocalKg__c;
                }
                if (item.TotalNetWeight__c > 0) {
                    item.PlanQuantity__c = 1;
                    item.TotalAmountOfBuying__c = Util.ConvertWeightToUnit(prod.BuyingWeightUnit__c, 'Kg', item.TotalNetWeight__c) * prod.BuyingUnitPriceLocalKg__c;
                }
                if (item.FinalNetWeight__c > 0) {
                    item.FinalQuantity__c = 1;
                    item.TotalAmountOfBuying__c = Util.ConvertWeightToUnit(prod.BuyingWeightUnit__c, 'Kg', item.FinalNetWeight__c) * prod.BuyingUnitPriceLocalKg__c;
                }
            }
            //Weight-based but order by quantity, i.e net weight is estimated on product
            else {
                if (item.PlanQuantity__c == null && item.Quantity__c > 0) {
                    item.PlanQuantity__c = item.Quantity__c;
                }
            }
            item.TotalAmountOfBuying__c = item.TotalAmountOfBuying__c == null ? 0 : item.TotalAmountOfBuying__c;
            item.AmountOfBuyingTax__c = item.TotalAmountOfBuying__c * prod.TaxRateBuying__c / 100;
            item.BuyingAmountInclTax__c = item.TotalAmountOfBuying__c + item.AmountOfBuyingTax__c;
        } 
    }
}