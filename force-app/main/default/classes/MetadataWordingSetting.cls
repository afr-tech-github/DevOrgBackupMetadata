public class MetadataWordingSetting {
	private static MetadataWordingSetting instance = null;
    public Map<String, Map<String,Amount_Wording_Setting__mdt>> wordingFieldMapbyObject{get;set;}
	private MetadataWordingSetting(){
        List<Amount_Wording_Setting__mdt> listWordingField = [SELECT 
                                                                API_Object_Name__c, 
                                                                API_Amount_Field_Name__c, 
                                                                API_Wording_Field_Name__c,
                                                                Currency_Type__c,
                                                                API_En_Wording_Field_Name__c
                                                            FROM Amount_Wording_Setting__mdt LIMIT 50000];
        wordingFieldMapbyObject = new  Map<String, Map<String,Amount_Wording_Setting__mdt>>();
        for(Amount_Wording_Setting__mdt wordingSetting : listWordingField){
            Map<String,Amount_Wording_Setting__mdt> mapbyfield;
            if(wordingFieldMapbyObject.containsKey(wordingSetting.API_Object_Name__c)){
                mapbyfield = wordingFieldMapbyObject.get(wordingSetting.API_Object_Name__c);
                mapbyfield.put(wordingSetting.API_Amount_Field_Name__c, wordingSetting);
                wordingFieldMapbyObject.put(wordingSetting.API_Object_Name__c,mapbyfield);
            }else{
				mapbyfield= new  Map<String,Amount_Wording_Setting__mdt>();
                mapbyfield.put(wordingSetting.API_Amount_Field_Name__c, wordingSetting);
                wordingFieldMapbyObject.put(wordingSetting.API_Object_Name__c, mapbyfield);
            }
            
        }
        system.debug(wordingFieldMapbyObject);
    }
    public static MetadataWordingSetting getInstance(){
        // lazy load the record type - only initialize if it doesn't already exist
        if(instance == null) instance = new MetadataWordingSetting();
        return instance;
    }
}