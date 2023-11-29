public with sharing class CopyingMShipDataToHShipController {
    public transient Boolean selectAll {get; set;}
    public List<HBLShipmentWrapper> shipmentWrappers {get; private set;}
    private static List<String> fieldsToQueryFromHShip = new List<String>();
    private static List<String> fieldsToQueryFromMShip = new List<String>();
    private String mshipId;
    private MasterAnken__c mship;
    public String errorMessage {get;set;}
    public Map<String, String> translations {get; private set;}
    
    static {
        fieldsToQueryFromHShip.add('Id');
        fieldsToQueryFromHShip.add('Name');
        fieldsToQueryFromHShip.add('WkInitial__c');
        fieldsToQueryFromHShip.add('ID__c');
        fieldsToQueryFromHShip.add('POL__r.Country_Name__c');
        fieldsToQueryFromHShip.add('POL__r.City_Name__c');
        fieldsToQueryFromHShip.add('Place_of_Receipt__r.Name');
        fieldsToQueryFromHShip.add('ETD__c');
        fieldsToQueryFromHShip.add('POD__r.Country_Name__c');
        fieldsToQueryFromHShip.add('POD__r.City_Name__c');
        fieldsToQueryFromHShip.add('Place_of_Delivery__r.Name');
        fieldsToQueryFromHShip.add('ETA__c');
        fieldsToQueryFromHShip.add('Vessle__c');
        fieldsToQueryFromHShip.add('Voy_No__c');
        fieldsToQueryFromHShip.add('ContainerSeal_No__c');
        fieldsToQueryFromHShip.add('Devan__r.Name');
        fieldsToQueryFromHShip.add('Devan__c');
        //fieldsToQueryFromHShip.add('DevanRep__r.Name');
        //fieldsToQueryFromHShip.add('DevanRep__c');
        fieldsToQueryFromHShip.add('DevanningDate__c');
        fieldsToQueryFromHShip.add('TransitV__c');
        fieldsToQueryFromHShip.add('TS__c');
        fieldsToQueryFromHShip.add('T_ETD__c');
        fieldsToQueryFromHShip.add('Master_B_L__c');
        fieldsToQueryFromHShip.add('BookingNv__c');
        fieldsToQueryFromHShip.add('LoadLocation__c');
        fieldsToQueryFromHShip.add('BookingNv__r.Name');
        fieldsToQueryFromHShip.add('LoadLocation__r.Name');
        fieldsToQueryFromHShip.add('LoadingTime__c');
        fieldsToQueryFromHShip.add('ConsolidationType__c');
      
        fieldsToQueryFromMShip.add('Id');
        fieldsToQueryFromMShip.add('Name');
        fieldsToQueryFromMShip.add('MPOL__r.Country_Name__c');
        fieldsToQueryFromMShip.add('MPOL__r.City_Name__c');
        fieldsToQueryFromMShip.add('MPlace_of_Receipt__r.Name');
        fieldsToQueryFromMShip.add('METD__c');
        fieldsToQueryFromMShip.add('MPOD__r.Country_Name__c');
        fieldsToQueryFromMShip.add('MPOD__r.City_Name__c');
        fieldsToQueryFromMShip.add('MPlace_of_Delivery__r.Name');
        fieldsToQueryFromMShip.add('META__c');
        fieldsToQueryFromMShip.add('MVessel__c');
        fieldsToQueryFromMShip.add('MVoy_No__c');
        fieldsToQueryFromMShip.add('MContainer_No__c');
        fieldsToQueryFromMShip.add('MDevan__r.Name');
        fieldsToQueryFromMShip.add('MDevan__c');
        fieldsToQueryFromMShip.add('MDevanRep__r.Name');
        fieldsToQueryFromMShip.add('MDevanRep__c');
        fieldsToQueryFromMShip.add('MDevanningDate__c');
        fieldsToQueryFromMShip.add('MTRANSIT_VESSEL__c');
        fieldsToQueryFromMShip.add('MTRANSIT_PORT__c');
        fieldsToQueryFromMShip.add('MTRANSIT_T_ETD__c');
        fieldsToQueryFromMShip.add('MMaster_B_L_No__c');
        fieldsToQueryFromMShip.add('MBookingNv__c');
        fieldsToQueryFromMShip.add('MLoadLocation__c');
        fieldsToQueryFromMShip.add('MBookingNv__r.Name');
        fieldsToQueryFromMShip.add('MLoadLocation__r.Name');
        fieldsToQueryFromMShip.add('bondedtimetoCFS__c');
    }
    
    public CopyingMShipDataToHShipController() {
        mshipId = StringUtils.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('id'));
        shipmentWrappers = new List<HBLShipmentWrapper>();
        
        initializeTranslation();
        loadRelatedHShips(mshipId);    
        loadMBLShip(mshipId);
        selectAll = true;
    }
    
    private void initializeTranslation() {
        TranslationService translationService = new TranslationService('COPY_MBL_HBL', UserInfo.getLanguage());
        translations = translationService.getTranslations();
    }
    
    private void loadRelatedHShips(String mshipId) {
        String queryFields = String.join(fieldsToQueryFromHShip, ',');
        String query = 'SELECT ' + queryFields + ' FROM CustomObject1__c WHERE MasterAnkenName__c = \'' + mshipId + '\'';
        
        if (PermissionValidationUtil.isAccessibleAccount() && PermissionValidationUtil.isAccessiblePort() 
            	&& PermissionValidationUtil.isAccessibleWarehouse() && PermissionValidationUtil.isAccessibleHBL()) {
            List<CustomObject1__c> shipments = (List<CustomObject1__c>) Database.query(query);
            for (CustomObject1__c shipment : shipments) {
                shipmentWrappers.add(new HBLShipmentWrapper(true, shipment));
            }
        }
    }

    public class HBLShipmentWrapper {
        public Boolean selected {get;set;}
        public CustomObject1__c shipment {get;set;}
        
        public HBLShipmentWrapper(Boolean checked, CustomObject1__c shipment) {
            this.selected = checked;
            this.shipment = shipment;
        }   
    }
    
    private void loadMBLShip(String mshipId) {
        String queryFields = String.join(fieldsToQueryFromMShip, ',');  
        String query = 'SELECT ' + queryFields + ' FROM MasterAnken__c WHERE Id = \'' + mshipId + '\'';
        
        if (PermissionValidationUtil.isAccessibleAccount() && PermissionValidationUtil.isAccessiblePort() 
            	&& PermissionValidationUtil.isAccessibleWarehouse() && PermissionValidationUtil.isAccessibleMBL()) {
        	mship = (MasterAnken__c) Database.query(query);
		}
    }
    
    public List<MasterAnken__c> getMBLShips() {
        List<MasterAnken__c> mships = new List<MasterAnken__c>();
        if (mship != null) {
                mships.add(mship);    
        }
        
        return mships;
    }
    
    public PageReference copy() {
        String message = '';
        if (mship != null && PermissionValidationUtil.isEditableHBL()) {        
            List<CustomObject1__c> toBeUpdated = new List<CustomObject1__c>();
    
            for (HBLShipmentWrapper shipmentWrapper : shipmentWrappers) {
                if (shipmentWrapper.selected) {
                    CustomObject1__c shipment = shipmentWrapper.shipment;
                    
                    shipment.POD__c = mship.MPOD__c;
                    shipment.POL__c = mship.MPOL__c;
                    shipment.Place_Of_Delivery__c = mship.MPlace_Of_Delivery__c;
                    shipment.Place_Of_Receipt__c = mship.MPlace_Of_Receipt__c;
                    shipment.ETD__c = mship.METD__c;
                    shipment.ETA__c = mship.META__c;
                    shipment.Vessle__c = mship.MVessel__c;
                    shipment.Voy_No__c = mship.MVoy_No__c;
                    shipment.Devan__c = mship.MDevan__c;
                    //shipment.DevanRep__c = mship.MDevanRep__c;
                    shipment.DevanningDate__c = mship.MDevanningDate__c;
                    shipment.TransitV__c = mship.MTRANSIT_VESSEL__c;
                    shipment.TS__c = mship.MTRANSIT_PORT__c;
                    shipment.T_ETD__c = mship.MTRANSIT_T_ETD__c;
                    shipment.Master_B_L__c = mship.MMaster_B_L_No__c;
                    shipment.BookingNv__c = mship.MBookingNv__c;
                    shipment.LoadLocation__c = mship.MLoadLocation__c;
                    
                    if (mship.bondedtimetoCFS__c != null) {
                		shipment.LoadingTime__c = Date.newInstance(mship.bondedtimetoCFS__c.year(), mship.bondedtimetoCFS__c.month(), mship.bondedtimetoCFS__c.day()) ;
            		}
                    
                    if (PicklistReference.CONSOLIDATION_TYPE_CONSOLIDATION.equals(shipment.ConsolidationType__c) 
                        	&& !StringUtils.isEmpty(mship.MContainer_No__c)) {
                        shipment.ContainerSeal_No__c = ContainerInfoService.extractContainerNo(mship.MContainer_No__c);
                    } else if (PicklistReference.CONSOLIDATION_TYPE_MULTIPLE_BL.equals(shipment.ConsolidationType__c)) {
                        shipment.ContainerSeal_No__c = mship.MContainer_No__c;
                    }
                    
                    toBeUpdated.add(shipment);
                }
            }
            
            if (toBeUpdated.size() > 0) {
                try {
                    Database.SaveResult[] results = Database.update(FlsService.checkFls(AccessType.UPDATABLE, toBeUpdated).getRecords(), false);
                    if (results != null){
                        Integer index = 0;
                        String errorMessage = '';
                        
                        for (Database.SaveResult result : results) {
                            if (!result.isSuccess()) {
                                errorMessage = 'There are some H B/L_SHIPMENTs were failed to synchonize with M B/L-SHIPMENT';	
                                Database.Error[] errors = result.getErrors();
                                
                                for (Database.Error error : errors) {
                                }
                            }
							
                            index++;
                        }
                        
                        if (errorMessage.length() > 0) {
                            errorMessage = 'There is error occurred for some H B/L-SHIPMENTS. Error: ' + errorMessage;
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, errorMessage));
                        } else {
                            message = translations.get('MBL_HBL_COPY_COMPLETED');
                            if (StringUtils.isEmpty(message)) {
                            	message = 'Copying data from M B/L-SHIPMENT to H B/L-SHIPMENTS completed';
                            }
                            
	                    	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, message));    
                            shipmentWrappers = new List<HBLShipmentWrapper>();
                            loadRelatedHShips(mshipId);
                        }
                    }
                } catch (Exception e) {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'ERROR: ' + e.getMessage()));
                }
            }
        } else {
            errorMessage = 'Insufficient Permissions';
        }

        return null;
    }
}