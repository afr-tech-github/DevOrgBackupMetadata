public with sharing class GoodSearchController {
	public PRODUCT__c objectProductSearch{get; set;}
	public Boolean isDisplayResultSearch{get; set;}
	public List<ProductWapper> listProductResult {get; set;}
	public List<LocatorWapper> currentListLocator {get; set;}
	public ProductWapper currentProductWapper{get; set;}
	public List<Stock__c> listResultSearch{get; set;}
	public Boolean isDisplayDetailProduct {get; set;}
	public String sqlStr {get; set;}
	public PRODUCT__c currentProduct {get; set;}
	//==================Pagination variable===============
    public Integer sizeSearchPage{get;set;}
    public Integer sizeDetailPage{get;set;}
    public List<SelectOption> paginationSizeOptions{get;set;}
    public ProductWapperIterable objProductIterable{get; set;}
    public LocatorWapperIterable objLocatorIterable{get; set;}
    public List<ProductWapper> listSetProduct{get; set;}
    public List<LocatorWapper> listSetLocator{get; set;}
    

	public GoodSearchController() {
		sizeSearchPage = 10;
		sizeDetailPage = 10;
		paginationSizeOptions = new List<SelectOption>();
        paginationSizeOptions.add(new SelectOption('5','5'));
        paginationSizeOptions.add(new SelectOption('10','10'));
        paginationSizeOptions.add(new SelectOption('20','20'));
        paginationSizeOptions.add(new SelectOption('50','50'));
        paginationSizeOptions.add(new SelectOption('100','100'));


		objectProductSearch = new PRODUCT__c();
		isDisplayResultSearch = false;
		listResultSearch = new List<Stock__c>();
		isDisplayDetailProduct = false;
		sqlStr = '';

	}

	/*public ApexPages.StandardSetController setResultSearch{
        get {
            if(setResultSearch == null) {
                setResultSearch = new ApexPages.StandardSetController(listProductResult);
                setResultSearch.setPageSize(sizeSearchPage);
            }
            return setResultSearch;
        }
        set;
    }*/

	private String buildQuery(PRODUCT__c objectSearch){
		String strQuery = '';
		String strSelect = '';
		String strCondition = '';
		strSelect = 'SELECT '
		+ 'Id, Name, RecordType.Name, '
		+ 'ProductID__r.Name, '
		+ 'ProductID__r.ProductName__c, '
		+ 'ProductID__r.GoodOwner__c, '
		+ 'ProductID__r.Manufacturer__c, '
		+ 'ProductID__r.SKUNumber__c, '
		+ 'ProductID__r.Buyer__c, '
		+ 'ProductID__r.SerialNumber__c, '
		+ 'ProductID__r.Measurement__c, '
		+ 'ProductID__r.NETWeight__c, '
		+ 'ProductID__r.GrossWeight__c, '
		+ 'StockLocator__c, '
		+ 'StockLocator__r.Name, '
		+ 'StockStatus__c, '
		+ 'RecordTypeId, '
		+ 'RecordType.DeveloperName, '
		+ 'Measurement__c, '
		+ 'GrossWeight__c,'
		+ 'Quantity__c '
		+ 'FROM Stock__c ';
		if(!String.isBlank(objectProductSearch.Name)){
			strCondition = strCondition + ' AND ProductID__r.Name like \'%' + objectProductSearch.Name + '%\'';
		}

		if(!String.isBlank(objectProductSearch.ProductName__c)){
			strCondition = strCondition + ' AND ProductID__r.ProductName__c like \'%' + objectProductSearch.ProductName__c + '%\'';
		}

		if(objectProductSearch.GoodOwner__c != null){
			strCondition = strCondition + ' AND ProductID__r.GoodOwner__c = \'' + objectProductSearch.GoodOwner__c + '\'';
		}
		if(objectProductSearch.Buyer__c != null){
			strCondition = strCondition + ' AND ProductID__r.Buyer__c = \'' + objectProductSearch.Buyer__c + '\'';
		}
		if(objectProductSearch.Manufacturer__c != null){
			strCondition = strCondition + ' AND ProductID__r.Manufacturer__c = \'' + objectProductSearch.Manufacturer__c + '\'';
		}
		if(!String.isBlank(objectProductSearch.SKUNumber__c )){
			strCondition = strCondition + ' AND ProductID__r.SKUNumber__c like \'%' + objectProductSearch.SKUNumber__c + '%\'';
		}
		if(!String.isBlank(objectProductSearch.SerialNumber__c)){
			strCondition = strCondition + ' AND ProductID__r.SerialNumber__c like \'%' + objectProductSearch.SerialNumber__c + '%\'';
		}
		if(!String.isBlank(objectProductSearch.ItemNumber__c)){
			strCondition = strCondition + ' AND ProductID__r.ItemNumber__c like \'%' + objectProductSearch.ItemNumber__c + '%\'';
		}
		if(!String.isBlank(objectProductSearch.LOTNumber__c)){
			strCondition = strCondition + ' AND ProductID__r.LOTNumber__c like \'%' + objectProductSearch.LOTNumber__c + '%\'';
		}
		if(objectProductSearch.InventoryType__c != null){
			strCondition = strCondition + ' AND ProductID__r.InventoryType__c = \'' + objectProductSearch.InventoryType__c + '\'';
		}
		if(!String.isBlank(objectProductSearch.PartNumber__c)){
			strCondition = strCondition + ' AND ProductID__r.PartNumber__c like \'%' + objectProductSearch.PartNumber__c + '%\'';
		}
		if(objectProductSearch.FastSlowClassification__c != null){
			strCondition = strCondition + ' AND ProductID__r.FastSlowClassification__c = \'' + objectProductSearch.FastSlowClassification__c + '\'';
		}
		if(objectProductSearch.ItemType__c != null){
			strCondition = strCondition + ' AND ProductID__r.ItemType__c = \'' + objectProductSearch.ItemType__c + '\'';
		}
		if(objectProductSearch.InventoryType__c != null){
			strCondition = strCondition + ' AND ProductID__r.InventoryType__c = \'' + objectProductSearch.InventoryType__c + '\'';
		}
		if(objectProductSearch.DangerousClassification__c != null){
			strCondition = strCondition + ' AND ProductID__r.DangerousClassification__c = \'' + objectProductSearch.DangerousClassification__c + '\'';
		}
		if(objectProductSearch.HSCode__c != null){
			strCondition = strCondition + ' AND ProductID__r.HSCode__c = \'' + objectProductSearch.HSCode__c + '\'';
		}
		if(objectProductSearch.SKU__c != null){
			strCondition = strCondition + ' AND ProductID__r.SKU__c = \'' + objectProductSearch.SKU__c + '\'';
		}

		strCondition = strCondition + ' AND (StockStatus__c = \'Completed\' OR StockStatus__c = \'Planning\')';
		//strCondition =+ 'AND RecordTypeId.Name = \'StockIn \'';
		strCondition = strCondition + ' Order by ProductID__c, StockLocator__c   Limit 5000';

		if(strCondition != ''){
			strCondition = strCondition.replaceFirst('AND', 'WHERE');
		}
		strQuery = strSelect + strCondition;
		return strQuery;
	}

	public void doSearch(){
		isDisplayResultSearch = true;
		isDisplayDetailProduct = false;
		currentListLocator = new List<LocatorWapper>();
		currentProduct = new PRODUCT__c();
		String strQuery = buildQuery(objectProductSearch);
		listResultSearch = Database.query(strQuery);
		// get Stock by Product
		listProductResult = new List<ProductWapper>();
		sqlStr = strQuery;
		//Integer countLocator = 0;
		LocatorWapper locator = new LocatorWapper();
		ProductWapper prtWapper = new ProductWapper();
		String nextlocatorId;
		String nextProductId;
		Integer countStock = 0;
		Map<Id, LocatorWapper> stockHaveNoLocator = new Map<Id, LocatorWapper>();
		for(Stock__c objStock : listResultSearch){
			countStock = countStock + 1;
			if(listResultSearch.size() > countStock){
				nextlocatorId = listResultSearch[countStock].StockLocator__c;
				nextProductId = listResultSearch[countStock].ProductID__c;
			}else{
				nextlocatorId = null;
				nextProductId = null;
			}
			if(objStock.ProductID__c != prtWapper.product.Id){
				prtWapper = new ProductWapper();
				prtWapper.product.Id = objStock.ProductID__c;
				prtWapper.productName = objStock.ProductID__r.Name;
				prtWapper.product.ProductName__c = objStock.ProductID__r.ProductName__c;
				prtWapper.product.GoodOwner__c = objStock.ProductID__r.GoodOwner__c;
				prtWapper.product.Manufacturer__c = objStock.ProductID__r.Manufacturer__c;
				prtWapper.product.SKUNumber__c = objStock.ProductID__r.SKUNumber__c;
				prtWapper.product.Buyer__c = objStock.ProductID__r.Buyer__c;
				prtWapper.product.SerialNumber__c = objStock.ProductID__r.SerialNumber__c;
				prtWapper.product.Measurement__c = objStock.ProductID__r.Measurement__c;
				prtWapper.product.NETWeight__c = objStock.ProductID__r.NETWeight__c;
				prtWapper.product.GrossWeight__c = objStock.ProductID__r.GrossWeight__c;
				locator = new LocatorWapper();
				locator.locatorId = objStock.StockLocator__c;
				locator.locatorName = objStock.StockLocator__r.Name;
				locator.productName = objStock.ProductID__r.Name;
				locator.listStock = new List<Stock__c>();
			}
			if(objStock.Measurement__c == null){
				objStock.Measurement__c = 0;
			}
			if(objStock.GrossWeight__c == null){
				objStock.GrossWeight__c = 0;
			}
			if(objStock.Quantity__c == null){
				objStock.Quantity__c = 0;
			}
			if(locator.locatorId != objStock.StockLocator__c && objStock.ProductID__c == prtWapper.product.Id){
				locator = new LocatorWapper();
				locator.locatorId = objStock.StockLocator__c;
				locator.locatorName = objStock.StockLocator__r.Name;
				locator.productName = objStock.ProductID__r.Name;
				locator.listStock = new List<Stock__c>();
			}
			if(locator.locatorId == objStock.StockLocator__c && objStock.ProductID__c == prtWapper.product.Id){
				locator.listStock.add(objStock);
				if(objStock.RecordType.DeveloperName == 'StockIn'
				&& objStock.StockStatus__c == 'Completed'){

					locator.totalLocatorMeasurement = locator.totalLocatorMeasurement + objStock.Measurement__c == null? 0: objStock.Measurement__c;
					locator.totalLocatorGrossWeight = locator.totalLocatorGrossWeight + objStock.GrossWeight__c == null? 0: objStock.GrossWeight__c;
					
					locator.totalLocatorMeasurementIncludePlan = locator.totalLocatorMeasurementIncludePlan + objStock.Measurement__c == null? 0: objStock.Measurement__c;
					locator.totalLocatorGrossWeightIncludePlan = locator.totalLocatorGrossWeightIncludePlan + objStock.GrossWeight__c == null? 0: objStock.GrossWeight__c;
					locator.remainQuantity = locator.remainQuantity + (Integer)objStock.Quantity__c;
				}
				if(objStock.RecordType.DeveloperName == 'StockOut'
				&& objStock.StockStatus__c == 'Completed'){ 

					locator.totalLocatorMeasurement = locator.totalLocatorMeasurement - objStock.Measurement__c == null? 0: objStock.Measurement__c;
					locator.totalLocatorGrossWeight = locator.totalLocatorGrossWeight - objStock.GrossWeight__c == null? 0: objStock.GrossWeight__c;
					locator.totalLocatorMeasurementIncludePlan = locator.totalLocatorMeasurementIncludePlan - objStock.Measurement__c == null? 0: objStock.Measurement__c;
					locator.totalLocatorGrossWeightIncludePlan = locator.totalLocatorGrossWeightIncludePlan - objStock.GrossWeight__c == null? 0: objStock.GrossWeight__c;
					locator.remainQuantity = locator.remainQuantity - (Integer)objStock.Quantity__c;
				}
				if(objStock.RecordType.DeveloperName == 'StockIn'
				&& objStock.StockStatus__c == 'Planning'){
					locator.totalLocatorMeasurementIncludePlan = locator.totalLocatorMeasurementIncludePlan + objStock.Measurement__c == null? 0: objStock.Measurement__c;
					locator.totalLocatorGrossWeightIncludePlan = locator.totalLocatorGrossWeightIncludePlan + objStock.GrossWeight__c == null? 0: objStock.GrossWeight__c;
				}
				if(objStock.RecordType.DeveloperName == 'StockOut'
				&& objStock.StockStatus__c == 'Planning'){
					locator.totalLocatorMeasurementIncludePlan = locator.totalLocatorMeasurementIncludePlan - objStock.Measurement__c == null? 0: objStock.Measurement__c;
					locator.totalLocatorGrossWeightIncludePlan = locator.totalLocatorGrossWeightIncludePlan - objStock.GrossWeight__c == null? 0: objStock.GrossWeight__c;
				}
			}
			if(objStock.StockLocator__c != nextlocatorId && objStock.ProductID__c == prtWapper.product.Id
				|| objStock.ProductID__c != nextProductId){


				locator.totalLocatorMeasurement = locator.totalLocatorMeasurement.setScale(3);
				locator.totalLocatorGrossWeight = locator.totalLocatorGrossWeight.setScale(3);
				locator.totalLocatorMeasurementIncludePlan = locator.totalLocatorMeasurementIncludePlan.setScale(3);
				locator.totalLocatorGrossWeightIncludePlan = locator.totalLocatorGrossWeightIncludePlan.setScale(3);
				prtWapper.totalProductMeasurement = prtWapper.totalProductMeasurement + locator.totalLocatorMeasurement;
				prtWapper.totalProductGrossWeight = prtWapper.totalProductGrossWeight + locator.totalLocatorGrossWeight;
				prtWapper.totalProductMeasurementIncludePlan = prtWapper.totalProductMeasurementIncludePlan + locator.totalLocatorMeasurementIncludePlan;
				prtWapper.totalProductGrossWeightIncludePlan = prtWapper.totalProductGrossWeightIncludePlan + locator.totalLocatorGrossWeightIncludePlan;
				prtWapper.remainQuantityProduct = prtWapper.remainQuantityProduct + locator.remainQuantity;
				prtWapper.totalProductMeasurement = prtWapper.totalProductMeasurement.setScale(3);
				prtWapper.totalProductGrossWeight = prtWapper.totalProductGrossWeight.setScale(3);
				prtWapper.totalProductMeasurementIncludePlan = prtWapper.totalProductMeasurementIncludePlan.setScale(3);
				prtWapper.totalProductGrossWeightIncludePlan = prtWapper.totalProductGrossWeightIncludePlan.setScale(3);
				prtWapper.listLocator.add(locator);
				//continue;
			}
			
			if(nextProductId != objStock.ProductId__c){
				listProductResult.add(prtWapper);
			}

			
		}
		objProductIterable = new ProductWapperIterable(listProductResult); 
        objProductIterable.setPageSize(sizeSearchPage);
        listSetProduct = objProductIterable.next(); 
	}
	public void viewDetailProduct(){
		isDisplayResultSearch = false;
		isDisplayDetailProduct = true;
		currentProductWapper = new ProductWapper();
		string productId = ApexPages.currentPage().getParameters().get('productId');
		// query product
		List<PRODUCT__c> listProductSelected = [SELECT 
												Id,
												Name,
												ProductName__c,
												GoodOwner__c,
												Buyer__c,
												Manufacturer__c,
												SKUNumber__c,
												SerialNumber__c,
												ItemNumber__c,
												LOTNumber__c,
												PartNumber__c,
												FastSlowClassification__c,
												InventoryType__c,
												ItemType__c,
												DangerousClassification__c,
												HSCode__c,
												SKU__c,
												Measurement__c,
												NETWeight__c,
												GrossWeight__c
												FROM PRODUCT__c WHERE Id =: productId];

		// query stock
		if(!listProductSelected.isEmpty()){
			currentProductWapper.product = listProductSelected[0];
			currentProduct = listProductSelected[0];
			List<Stock__c> listStockbyProduct = [SELECT 
												Id, 
												StockLocator__r.Name, 
												StockLocator__c,
												Name, 
												Measurement__c, 
												GrossWeight__c,
												StockDate__c,
												Quantity__c,
												RecordType.Name, 
												StockStatus__c,
												StockLocator__r.WarehouseID__c,
												StockLocator__r.WarehouseID__r.Name,
												ProductID__c,
												RecordType.DeveloperName
												FROM Stock__c
												WHERE ProductID__c =: currentProduct.Id
												AND (StockStatus__c ='Completed' OR StockStatus__c ='Planning')
												ORDER BY StockLocator__c];
			String idLocatorTemp = null;
			LocatorWapper locator = new LocatorWapper();
			locator.locatorId = null;
			locator.listStock = new List<Stock__c>();
			Integer countStock = 0;
			Id nextLocatorId;
			for(Stock__c stock: listStockbyProduct){
				countStock = countStock + 1;
				if(listStockbyProduct.size() > countStock){
					nextLocatorId = listStockbyProduct[countStock].StockLocator__c;
				}else{
					nextLocatorId = null;
				}
				if(locator.locatorId != stock.StockLocator__c){
					locator = new LocatorWapper();
					locator.locatorId = stock.StockLocator__c;
					locator.listStock = new List<Stock__c>();
				}

				locator.locatorName = stock.StockLocator__r.Name;
				locator.facitityName = stock.StockLocator__r.WarehouseID__r.Name;
				locator.facitityId = stock.StockLocator__r.WarehouseID__c;
				if(stock.Measurement__c == null){
				stock.Measurement__c = 0;
				}
				if(stock.GrossWeight__c == null){
					stock.GrossWeight__c = 0;
				}
				if(stock.Quantity__c == null){
					stock.Quantity__c = 0;
				}
				if(locator.locatorId == stock.StockLocator__c){
					if(stock.RecordType.DeveloperName == 'StockIn'
						&& stock.StockStatus__c == 'Completed'){
							locator.totalLocatorMeasurement = locator.totalLocatorMeasurement + stock.Measurement__c;
							locator.totalLocatorGrossWeight = locator.totalLocatorGrossWeight + stock.GrossWeight__c;
							locator.totalLocatorMeasurementIncludePlan = locator.totalLocatorMeasurementIncludePlan + stock.Measurement__c;
							locator.totalLocatorGrossWeightIncludePlan = locator.totalLocatorGrossWeightIncludePlan + stock.GrossWeight__c;
							locator.remainQuantity = locator.remainQuantity + (Integer)stock.Quantity__c;
						}
					if(stock.RecordType.DeveloperName == 'StockOut'
					&& stock.StockStatus__c == 'Completed'){
						locator.totalLocatorMeasurement = locator.totalLocatorMeasurement - stock.Measurement__c;
						locator.totalLocatorGrossWeight = locator.totalLocatorGrossWeight - stock.GrossWeight__c;
						locator.totalLocatorMeasurementIncludePlan = locator.totalLocatorMeasurementIncludePlan - stock.Measurement__c;
						locator.totalLocatorGrossWeightIncludePlan = locator.totalLocatorGrossWeightIncludePlan - stock.GrossWeight__c;
						locator.remainQuantity = locator.remainQuantity - (Integer)stock.Quantity__c;
					}
					if(stock.RecordType.DeveloperName == 'StockIn'
					&& stock.StockStatus__c == 'Planning'){
						locator.totalLocatorMeasurementIncludePlan = locator.totalLocatorMeasurementIncludePlan + stock.Measurement__c;
						locator.totalLocatorGrossWeightIncludePlan = locator.totalLocatorGrossWeightIncludePlan + stock.GrossWeight__c;
					}
					if(stock.RecordType.DeveloperName == 'StockOut'
					&& stock.StockStatus__c == 'Planning'){
						locator.totalLocatorMeasurementIncludePlan = locator.totalLocatorMeasurementIncludePlan - stock.Measurement__c;
						locator.totalLocatorGrossWeightIncludePlan = locator.totalLocatorGrossWeightIncludePlan - stock.GrossWeight__c;
					}
					locator.listStock.add(stock);
				}
				if(nextlocatorId != stock.StockLocator__c
					|| (countStock == listStockbyProduct.size())){
					locator.totalLocatorMeasurement = locator.totalLocatorMeasurement.setScale(3);
					locator.totalLocatorGrossWeight = locator.totalLocatorGrossWeight.setScale(3);
					locator.totalLocatorMeasurementIncludePlan = locator.totalLocatorMeasurementIncludePlan.setScale(3);
					locator.totalLocatorGrossWeightIncludePlan = locator.totalLocatorGrossWeightIncludePlan.setScale(3);
					currentProductWapper.totalProductMeasurement = currentProductWapper.totalProductMeasurement + locator.totalLocatorMeasurement;
					currentProductWapper.totalProductGrossWeight = currentProductWapper.totalProductGrossWeight + locator.totalLocatorGrossWeight;
					currentProductWapper.totalProductMeasurementIncludePlan = currentProductWapper.totalProductMeasurementIncludePlan + locator.totalLocatorMeasurementIncludePlan;
					currentProductWapper.totalProductGrossWeightIncludePlan = currentProductWapper.totalProductGrossWeightIncludePlan + locator.totalLocatorGrossWeightIncludePlan;
					currentProductWapper.remainQuantityProduct = currentProductWapper.remainQuantityProduct + locator.remainQuantity;
					currentListLocator.add(locator);

				}
				
			}
		}
		objLocatorIterable = new LocatorWapperIterable(currentListLocator); 
        objLocatorIterable.setPageSize(sizeDetailPage);
        listSetLocator = objLocatorIterable.next(); 

	}

	public PageReference refreshPageSizeSearch(){
		objProductIterable.setPageSize(sizeSearchPage);
		listSetProduct = objProductIterable.next();
		return null;
	}

	public Boolean hasNextProduct {
            get 
            {
                return objProductIterable.hasNext();
            }
            set;
        }
        
    public Boolean hasPreviousProduct {
        get 
        {
            return objProductIterable.hasPrevious();
        }
        set;
    }
    
    public void nextProduct() 
    {
        listSetProduct = objProductIterable.next();
    }
    
    public void previousProduct() 
    {
        listSetProduct = objProductIterable.previous();
    }
    public Integer getPageNumberProduct() 
    {
        return objProductIterable.pageNumber;
    }
    public Integer getTotalPageProduct() 
    {
        return objProductIterable.totalPage;
    }

    public PageReference refreshPageSizeDetail(){
		objLocatorIterable.setPageSize(sizeDetailPage);
		listSetLocator = objLocatorIterable.next();
		return null;
	}

	public Boolean hasNextLocator {
            get 
            {
                return objLocatorIterable.hasNext();
            }
            set;
        }
        
    public Boolean hasPreviousLocator {
        get 
        {
            return objLocatorIterable.hasPrevious();
        }
        set;
    }
    
    public void nextLocator() 
    {
        listSetLocator = objLocatorIterable.next();
    }
    
    public void previousLocator() 
    {
        listSetLocator = objLocatorIterable.previous();
    }
    public Integer getPageNumberLocator() 
    {
        return objLocatorIterable.pageNumber;
    }
    public Integer getTotalPageLocator() 
    {
        return objLocatorIterable.totalPage;
    }
}