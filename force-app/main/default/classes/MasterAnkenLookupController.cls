public with sharing class MasterAnkenLookupController {
    public List<MasterAnken__c> lstMasterAnkens {get;set;}
    public String strSearchValue {get;set;}
    public String strMasterAnkenID {get;set;}
    public String strHShipmentID {get;set;}
    public String radioValue {get;set;}
    public Integer listSize {get;set;}
    private static List<String> fieldsToQuery = new List<String>();
    public Map<String, String> translations {get; private set;}
    
    static {
        fieldsToQuery.add('Id');
        fieldsToQuery.add('Name');
        fieldsToQuery.add('MPOL__r.Country_Name__c');
        fieldsToQuery.add('MPOL__r.City_Name__c');
        fieldsToQuery.add('MPOL__r.Name');
        fieldsToQuery.add('MPlace_of_Receipt__r.Name');
        fieldsToQuery.add('METD__c');
        fieldsToQuery.add('MPOD__r.Country_Name__c');
        fieldsToQuery.add('MPOD__r.City_Name__c');
        fieldsToQuery.add('MPOD__r.Name');        
        fieldsToQuery.add('MPlace_of_Delivery__r.Name');
        fieldsToQuery.add('META__c');
        fieldsToQuery.add('MVoy_No__c');
        fieldsToQuery.add('MContainer_No__c');
        fieldsToQuery.add('MDevan__r.Name');
        fieldsToQuery.add('MDevanRep__r.Name');
        fieldsToQuery.add('MDevanningDate__c');
        fieldsToQuery.add('MTRANSIT_VESSEL__c');
        fieldsToQuery.add('MTRANSIT_PORT__c');
        fieldsToQuery.add('MTRANSIT_T_ETD__c');
        fieldsToQuery.add('MDevanWarehouse__r.Name');
        fieldsToQuery.add('bondedtimetoCFS__c');
        fieldsToQuery.add('MVessel__c');
    }
    
    public MasterAnkenLookupController() {
        strHShipmentID = StringUtils.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('id'));
    	lstMasterAnkens = new List<MasterAnken__c>();            
        String soqlComm = 'SELECT ' + String.join(fieldsToQuery, ',') + ' FROM MasterAnken__c LIMIT 50';
        
        if (PermissionValidationUtil.isAccessibleAccount() && PermissionValidationUtil.isAccessiblePort() 
	            && PermissionValidationUtil.isAccessibleWarehouse() && PermissionValidationUtil.isAccessibleMBL()) {
			lstMasterAnkens = Database.query(soqlComm);                
        }
        
        listSize = lstMasterAnkens.size();
        radioValue= 'Name';
        initializeTranslation();
    }
    
    private void initializeTranslation() {
        TranslationService translationService = new TranslationService('COPY_MBL_HBL', UserInfo.getLanguage());
        translations = translationService.getTranslations();
    }
    
    public List<SelectOption> radioType {
        get {
        	List<SelectOption> lstOptions = new List<SelectOption>();
        	lstOptions.add(new SelectOption('Name','Name'));
        	lstOptions.add(new SelectOption('Allfield','All fields'));
        
        	return lstOptions;    
        }
        set;
    }
    
    public PageReference doSearch() {
        if (strSearchValue != null) {
            if (PermissionValidationUtil.isAccessibleAccount() && PermissionValidationUtil.isAccessiblePort() 
                	&& PermissionValidationUtil.isAccessibleWarehouse() && PermissionValidationUtil.isAccessibleMBL()) {
                if (radioValue != null && radioValue == 'Allfield') {
                    String soslString = 'FIND {' + StringUtils.escapeSingleQuotes(strSearchValue) 
                        + '} IN ALL FIELDS RETURNING MasterAnken__c (' + String.join(fieldsToQuery, ',') + ')'; 
                    
                    List<List<SObject>> lstSObj = Search.query(soslString);
                    lstMasterAnkens = (List<MasterAnken__c>)lstSObj[0];
                }
                else if (radioValue != null && radioValue == 'Name'){
                    String soqlComm = 'SELECT '+ String.join(fieldsToQuery, ',') 
                        + ' FROM MasterAnken__c WHERE Name LIKE \'%' + StringUtils.escapeSingleQuotes(strSearchValue) + '%\'';
                    lstMasterAnkens = Database.query(soqlComm);
                }
                listSize = lstMasterAnkens.size();
            }
        }

        return null;
    }
    
    public void copyFromMasterAnken() {
        try {
            if (strMasterAnkenID != null && strHShipmentID != null) {
                cntl_opportunityCopy.copyFieldsFromMasterAnken(StringUtils.escapeSingleQuotes(strHShipmentID), 
                                                               StringUtils.escapeSingleQuotes(strMasterAnkenID));
            }        
        }catch(Exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Error occurred: ' + e.getMessage()));
        }
    }
}