public with sharing class AccountTriggerHandler extends AbstractTriggerHandler {
    private static Common_Settings__c setting = null;
    
    public override String getHandlerName() {
        return 'AccountTriggerHandler';
    }
    
    public override void bulkBefore() {
        loadCommonSettings();
    }
    
    public override void beforeInsert(SObject so) {
        Account account = (Account) so;
        setReferenceNo(account);
        upperCaseNameFields(account);
    }

    public override void beforeUpdate(SObject oldSO, SObject newSO) {
        Account account = (Account) newSO;
        setReferenceNo(account);
        upperCaseNameFields(account);
    }
    
    public override void andFinally() {
        if (setting != null) {
            upsert setting;    
        }
    }
    
    private void upperCaseNameFields(Account account) {
        account.EnglishAddress__c = StringUtils.capitalize(account.EnglishAddress__c);
        account.EnglishCompanyName__c = StringUtils.capitalize(account.EnglishCompanyName__c);
    }
    
    private void setReferenceNo(Account accn) {
        String englishName = accn.EnglishCompanyName__c;
        String shortName = accn.CompanyShortName__c;
        if (accn.Reference_Number__c == null){
            accn.Reference_Number__c = generateReferenceNo(englishName,shortName);
        }
    } 
    
    private String generateReferenceNo(String accountEnglishName, String accountShortName) {
        String refNo = '';

        if (setting == null) {
            String name = 'ACCOUNT-REF-' + System.now().getTime();
            setting = new Common_Settings__c(Name=name, Keyword__c=Constants.COMMON_SETTINGS_ACCOUNT_REFERENCE, Value__c='00000');
        }
        
        Integer nextNumber = Integer.valueOf(setting.Value__c) + 1;
        String nextNumberValue = StringUtils.prependZerosToNumber(nextNumber, 5);
        setting.Value__c = nextNumberValue;
        String abbreviation = '';
        if (accountShortName != null) {
            abbreviation = accountShortName;
            refNo = abbreviation;
        } else {
            abbreviation = StringUtils.generateNameAbbreviation(accountEnglishName);
            refNo = abbreviation + nextNumberValue;
        }
        // refNo = abbreviation + nextNumberValue;            
        return refNo;
    }
    
    
    private void loadCommonSettings() {
        try {
        	setting = [SELECT Value__c, Keyword__c FROM Common_Settings__c 
                       WHERE Keyword__c = :Constants.COMMON_SETTINGS_ACCOUNT_REFERENCE FOR UPDATE];    
        } catch(System.QueryException e) {
            setting = null;
        }
    }

    public static void syncRecordTypes(List<Account> listNew, Map<Id, Account> mapOld) {
        Map<String, String> map_RecordType_BussinessRelation = new Map<String, String> {
            Constants.RecordTypeId_Account_Customer => Constants.CUSTOMER_RELATIONSHIP,
            Constants.RecordTypeId_Account_Partner => Constants.PARTNER_RELATIONSHIP,
            Constants.RecordTypeId_Account_Vendor => Constants.VENDOR_RELATIONSHIP
        };
        
        Map<String, String> map_BussinessRelation_RecordType = new Map<String, String> {
            Constants.CUSTOMER_RELATIONSHIP => Constants.RecordTypeId_Account_Customer,
            Constants.PARTNER_RELATIONSHIP => Constants.RecordTypeId_Account_Partner,
            Constants.VENDOR_RELATIONSHIP => Constants.RecordTypeId_Account_Vendor
        };

        for (Account item : listNew) {
            if (item.RecordTypeId == null) {
                item.RecordTypeId = map_BussinessRelation_RecordType.get(item.Business_Relationship__c);
            } else if (mapOld != null && item.RecordTypeId != mapOld.get(item.Id).RecordTypeId) {
                item.Business_Relationship__c = map_RecordType_BussinessRelation.get(item.RecordTypeId);
            }
        }
    }
}