global with sharing class  AccountImportScheduled implements Schedulable, Database.AllowsCallouts  {

    global void execute() {
        System.enqueueJob(new CalloutAsync());
    }
	global void execute(SchedulableContext ctx) { // SchedulableContext sc
        System.enqueueJob(new CalloutAsync());
	}

    public class CalloutAsync implements Queueable, Database.AllowsCallouts {
        public void execute(QueueableContext context) {
            try {
                Object result = new ConnectToAPI().initGet(ConnectToAPI.Config.get('api_customer')).invoke();
                
                String jsonData =  JSON.serialize(result); 
                List<AccountWapper> listAccount = new  List<AccountWapper>();
                listAccount = (List<AccountWapper>) System.JSON.deserialize(jsonData, List<AccountWapper>.class);
                List<Account> listAccInsert = creatListAccount(listAccount);
                Schema.SObjectField f = Account.Fields.clofor_com_cfs__AccountExternalID__c;
                Database.UpsertResult [] cr = Database.upsert((List<Account>)FlsService.checkFls(AccessType.UPSERTABLE, listAccInsert).getRecords(), f, false);   
            } catch (Exception ex) {
                Call_Out_Error__c error = new Call_Out_Error__c(API_Name__c = ConnectToAPI.Config.get('api_customer'), Error_Content__c = ex.getMessage());
                FlsService.doInsert(error);
            }
        }
    }

    // TEST 
	final static String STR_ENDPOINT_API_CUSTOMER_DEV = 'http://apidev.3ffood.com/closcm/3ffood/customers';
    // TEST 
    //final static String STR_ENDPOINT_API_CUSTOMER = 'https://api.3ffood.com/closcm/3ffood/customers';
	final static String STR_AUTH_PARAMETER_URL = 'uid={1}&&sid={2}';
	/**
	 * @description Executes the scheduled Apex job. 
	 * @param sc contains the job ID   
	 */
     /*
	global void execute() {
    	// Login to api 3ffood
		Map<String, Object> resultLogin = ConnectToAPI.login();
        
        // get data from 3ffood
        String body = String.format(STR_AUTH_PARAMETER_URL
                                   , new String[]{ String.valueOf(resultLogin.get('uid'))
                                   , String.valueOf(resultLogin.get('sid'))});
        Map<String, Object> res = ConnectToAPI.getData('GET'
                            							,STR_ENDPOINT_API_CUSTOMER
                                                       , String.valueOf(resultLogin.get('uid'))
                                                       , String.valueOf(resultLogin.get('sid'))
                                                       , body);
        // TEST START
		String uid = '5';
		String sid = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6IjUiLCJ0aW1lIjoxNTU4MzUyNzIzLCJncm91cF9pZCI6MSwiZXhwaXJlc19pbiI6MzAsImFnZW50X2lkIjoiNDEyIn0.u0WQjjjRvljy-TzoTt_5OYnQrrqfsKs4-xT4xUDru6I';
		String body = String.format(STR_AUTH_PARAMETER_URL, new String[]{ uid, sid});
        Map<String, Object> res = ConnectToAPI.getData('GET'
                            							,STR_ENDPOINT_API_CUSTOMER_DEV
                                                       , uid
                                                       , sid
                                                       , body);
        // TEST END
        
        String jsonData =  JSON.serialize(res.get('result')); 
        system.debug('jsonData:' + jsonData);
        List<AccountWapper> listAccount = new  List<AccountWapper>();
        listAccount = (List<AccountWapper>) System.JSON.deserialize(jsonData, List<AccountWapper>.class);
        
        List<Account> listAccInsert = this.creatListAccount(listAccount);
        Schema.SObjectField f = Account.Fields.clofor_com_cfs__AccountExternalID__c;
        try{
		    Database.UpsertResult [] cr = Database.upsert(listAccInsert , f, false);   
        }catch(Exception ex){
            System.debug(ex.getMessage());
        }
    }
    */
    // Create List Account
    public static  List<Account> creatListAccount(List<AccountWapper> listAcccWapper){
        List<Account> listAccount = new List<Account>();
        for(AccountWapper item : listAcccWapper){
            Account acc = new Account();
            acc.clofor_com_cfs__Active__c 					= item.Active == '1' ? 'Yes' : 'No';
            acc.Name										= item.CustomerName + item.Mobile;
            acc.clofor_com_cfs__mail__c						= item.Email;
            acc.Phone										= item.Mobile;
            acc.clofor_com_cfs__EnglishCompanyName__c 		= item.CustomerName + item.Mobile;
            acc.BillingStreet 								= item.Address;
            acc.clofor_com_cfs__AccountExternalID__c 		= item.Mobile;
            acc.clofor_com_cfs__AccountIntExtType__c 		= 'External';
            acc.clofor_com_cfs__Business_Relationship__c 	= 'CUSTOMER';
            acc.clofor_com_cfs__Custom_Type__c 				= 'LOCAL CUSTOMER - EXISTING';
            listAccount.add(acc);
        }
        return listAccount;
    }
    // Account data from API
    public class AccountWapper {
        public String Active;
        public String Address;
        public String CustomerName;
        public String Email;
        public String Mobile;
    }
}