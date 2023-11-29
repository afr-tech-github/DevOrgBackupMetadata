public class TruckMarketWrapper {
    
    public List<Warehouse> Warehouses;

    public class Warehouse{
        //fields from external service
        public String OriginWarehouseID;
        public String OriginWarehouseName;
        public String AccountID;
        public String AccountName;
        public List<Destination> Destinations;
        
        //fields for transformation
        public List<Product> Sum_Products;
        public Account SfAccount;
        public Facility__c SfWarehouse;
        public Decimal Sum_Quantity;
        public Decimal Sum_Weight;
    }
    
    public class Destination{
        //fields from external service
        public String DestinationWarehouseID;
        public String DestinationWarehouseName;
        public List<Product> ProductOrder;
        public List<Customer> Customers;

        //fields for transformation
        public Facility__c SfWarehouse;
        public Decimal Sum_Quantity;
        public Decimal Sum_Weight;
    }
	
    public class Product{
        //fields from external service
        public String ProductID;
        public String ProductName;
        public Decimal Amount;

        //fields for transformation
        public Product__c SfProduct;
        public Decimal Sum_Quantity;
        public Decimal Sum_Weight;
    }

    public class Customer{
        //fields from external service
        public String AccountID;
        public String AccountName;
        public String Mobile;
        public List<Product> ProductSold;

        //fields for transformation
        public Account SfAccount;
        public Decimal Sum_Quantity;
        public Decimal Sum_Weight;

        public Customer() {
            this.Sum_Quantity = this.Sum_Weight = 0;
        }
    }

    public static TruckMarketWrapper parse(String json){
		return (TruckMarketWrapper) System.JSON.deserialize(json, TruckMarketWrapper.class);
	}
    
    public class TruckMarketResponse{
        public Boolean status {get; set;}
        public Integer totalError {get; set;}
        public String errMessage {get; set;}
        public Integer totalOriginWarehouse {get; set;}
        public List<Warehouse> Warehouses {get; set;}
        public TruckMarketResponse(){
            status = false;
            totalError = 0;
            errMessage = '';
            totalOriginWarehouse = 0;
            Warehouses = new List<Warehouse>();
        }
    }
}