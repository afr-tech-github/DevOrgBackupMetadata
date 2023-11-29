public with sharing class SoProductTriggerHelper {
    public static void autoPopulateFields(List<SalesOrderProduct__c> listNew, Map<Id, SalesOrderProduct__c> mapOld) {
        Set<Id> setFromProduct = new Set<Id> ();
        List<SalesOrderProduct__c> listProcess = new List<SalesOrderProduct__c>();
        for (SalesOrderProduct__c item : listNew) {
            if (item.ProductId__c != null) {
                setFromProduct.add(item.ProductID__c);
                listProcess.add(item);
            }
        }
        Map<Id, Product__c> mapFromProdduct = new Map<Id, Product__c>([
            SELECT Id, BillingType__c, WeightUnit__c, NETWeight__c, Measurement__c, GrossWeight__c, TaxRateSelling__c, SellingUnitPriceLocal__c, SellingUnitPriceLocalKg__c
            FROM Product__c 
            WHERE Id IN :setFromProduct
        ]);
        
        for (SalesOrderProduct__c item : listProcess) {
            Product__c prod = mapFromProdduct.get(item.ProductId__c);
            prod.NETWeight__c = prod.NETWeight__c == null ? 0 : prod.NETWeight__c;
            prod.GrossWeight__c = prod.GrossWeight__c == null ? 0 : prod.GrossWeight__c;
            prod.Measurement__c = prod.Measurement__c == null ? 0 : prod.Measurement__c;
            prod.TaxRateSelling__c = prod.TaxRateSelling__c == null ? 0 : prod.TaxRateSelling__c;
            prod.SellingUnitPriceLocal__c = prod.SellingUnitPriceLocal__c == null ? 0 : prod.SellingUnitPriceLocal__c;
            prod.SellingUnitPriceLocalKg__c = prod.SellingUnitPriceLocalKg__c == null ? 0 : prod.SellingUnitPriceLocalKg__c;
            
            //Uniprodt-based -> Calculate recommended weight from Recommended Quantity, Planned weight from planned quantity
            if (prod.BillingType__c == 'Unit') {
                Decimal prodNetWeight = Util.ConvertWeightToUnit('Kg', prod.WeightUnit__c, prod.NETWeight__c);
                Decimal prodGrossWeight = Util.ConvertWeightToUnit('Kg', prod.WeightUnit__c, prod.GrossWeight__c);

                item.Quantity__c = item.Quantity__c == null ? 1 : item.Quantity__c;
                if (item.PlannedQuantity__c == null && item.Quantity__c > 0) {
                    item.PlannedQuantity__c = item.Quantity__c;
                }
                //Measurement, gross weight, total amount of Selling are populated in the following priority: Final > Plan > Recommend; set value in the reverse order to ensure the correct final value
                //recommend net weight
                if (item.Quantity__c > 0) {
                    item.RecommendNetWeight__c = item.Quantity__c * prodNetWeight;
                    item.TotalMeasurement__c = item.Quantity__c * prod.Measurement__c;
                    item.TotalGrossWeight__c = item.Quantity__c * prod.GrossWeight__c;
                    //item.TotalAmountOfSelling__c = item.Quantity__c * prod.SellingUnitPriceLocal__c;
                }
                //planned net weight
                if (item.PlannedQuantity__c > 0) {
                    item.TotalNetWeight__c = item.PlannedQuantity__c * prodNetWeight;
                    item.TotalMeasurement__c = item.PlannedQuantity__c * prod.Measurement__c;
                    item.TotalGrossWeight__c = item.PlannedQuantity__c * prod.GrossWeight__c;
                    //item.TotalAmountOfSelling__c = item.PlannedQuantity__c * prod.SellingUnitPriceLocal__c;
                }
                //final net weight
                if (item.FinalQuantity__c > 0) {
                    item.FinalNetWeight__c = item.FinalQuantity__c * prodNetWeight;
                    item.TotalMeasurement__c = item.FinalQuantity__c * prod.Measurement__c;
                    item.TotalGrossWeight__c = item.FinalQuantity__c * prod.GrossWeight__c;
                    //item.TotalAmountOfSelling__c = item.FinalQuantity__c * prod.SellingUnitPriceLocal__c;
                }
            } 
            //Weight-based -> RecommendNetWeight__c is populated
            else if (prod.BillingType__c == 'Weight') {
                item.RecommendNetWeight__c = item.RecommendNetWeight__c == null ? 0 : item.RecommendNetWeight__c;
                
                if (item.TotalNetWeight__c == null && item.RecommendNetWeight__c > 0) {
                    item.TotalNetWeight__c = Util.ConvertWeightToUnit('Kg', prod.WeightUnit__c, item.RecommendNetWeight__c);
                }
                Decimal currentWeight = item.FinalNetWeight__c > 0 ? item.FinalNetWeight__c : item.TotalNetWeight__c > 0 ? item.TotalNetWeight__c : item.RecommendNetWeight__c;
                if (item.RecommendNetWeight__c > 0) {
                    item.Quantity__c = 1;
                    //item.TotalAmountOfSelling__c = Util.ConvertWeightToUnit(prod.WeightUnit__c, 'Kg', item.RecommendNetWeight__c) * prod.SellingUnitPriceLocalKg__c;
                }
                if (item.TotalNetWeight__c > 0) {
                    item.PlannedQuantity__c = 1;
                    //item.TotalAmountOfSelling__c = Util.ConvertWeightToUnit(prod.WeightUnit__c, 'Kg', item.TotalNetWeight__c) * prod.SellingUnitPriceLocalKg__c;
                }
                if (item.FinalNetWeight__c > 0) {
                    item.FinalQuantity__c = 1;
                    //item.TotalAmountOfSelling__c = Util.ConvertWeightToUnit(prod.WeightUnit__c, 'Kg', item.FinalNetWeight__c) * prod.SellingUnitPriceLocalKg__c;
                }
            }
            //item.TotalAmountOfSelling__c = item.TotalAmountOfSelling__c == null ? 0 : item.TotalAmountOfSelling__c;
            //item.AmountOfSellingTax__c = item.TotalAmountOfSelling__c * prod.TaxRateSelling__c / 100;
            //item.SellingAmountInclTax__c = item.TotalAmountOfSelling__c + item.AmountOfSellingTax__c;
        } 
    }
}