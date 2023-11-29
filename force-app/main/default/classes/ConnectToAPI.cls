public class ConnectToAPI {
    final static String STR_EMAIL = 'afr@3ffood.com';
    final static String STR_PASSWORD = 'afrtopos';
    
    final static String STR_ENDPOINT_LOGIN = 'https://api.3ffood.com/closcm/auth/signin';
    final static String STR_AUTH_URL_LOGIN = 'email={0}&password={1}';

    public final static Map<String, String> Config;
    static {
        SystemConfig__mdt temp = [SELECT Value__c FROM SystemConfig__mdt WHERE QualifiedApiName = 'clofor_com_cfs__ApiConfig'];
        Config = (Map<String, String>)JSON.deserialize(temp.Value__c, Map<String, String>.class);
    }
    private String sid;
    private String uid;

    public ConnectToAPI() {
        List<String> token = EncodingUtil.base64Decode(Config.get('token')).toString().split(':');
        Map<String, Object> response = (Map<String, Object>)this.initPost(Config.get('api_auth')).setBodyKey('email', token[0]).setBodyKey('password', token[1]).invoke();
        this.sid = (String)response.get('sid');
        this.uid = (String)response.get('uid');
    }

    private HttpRequest req;

    public ConnectToAPI initGet(String endpoint){ return initCallout('GET', endpoint); }
    public ConnectToAPI initPost(String endpoint){ return initCallout('POST', endpoint); }
    public ConnectToAPI setHeader(String key, String value){ 
		this.req.setHeader(key, value);
        return this;
    }
    public ConnectToAPI setBody(String body) {
        this.req.setBody(body);
        return this;
    }
    public ConnectToAPI setBodyKey(String key, String value) {
        String body = this.req.getBody();
        body += String.isBlank(body) ? '' : '&';
        this.req.setBody(body + key + '=' + value);
        return this;
    }
    public ConnectToAPI initCallout(String method, String endpoint) {
        this.req = new HttpRequest();
        this.req.setMethod(method);
		this.req.setTimeout(30000);
        this.req.setEndpoint(Config.get('host_' + Config.get('environment')) + endpoint);
		if (!String.isBlank(this.uid)) { this.req.setHeader('uid', this.uid); }
		if (!String.isBlank(this.sid)) { this.req.setHeader('sid', this.sid); }
        return this;
    }
    public Object invoke() {
		HttpResponse res = new Http().send(this.req);
        if (res.getStatusCode() == 200) {
			Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            if (response.get('error') != null) {
                throw new CustomException(JSON.serialize(response.get('error')));
            }
            return response.get('result');
        }
        else {
            throw new CustomException(res.getStatusCode() + ' - ' + res.getBody());
        }
    }

    // Login to api 3ffood
    public static Map<String, Object> login(){
        Map<String, Object> result = new Map<String, Object>();
		String body = String.format(STR_AUTH_URL_LOGIN, new String[]{STR_EMAIL, STR_PASSWORD});
        
        // Login to api 3ffood
		HttpResponse res = ConnectToAPI.callOut('POST', STR_ENDPOINT_LOGIN, '', '', body);
        if (res.getStatusCode() == 200) {
			Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
			result = (Map<String, Object>)m.get('result');
        }
        return result;
    }
    
    // get data to 3ffood
    public static  Map<String, Object> getData(String method, String endPoint, String uid, String sid, String body){
        Map<String, Object> result = new Map<String, Object>();
        HttpResponse res = ConnectToAPI.callOut(method, endPoint, uid, sid, body);
        if (res.getStatusCode() == 200) {
			result = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
			//result = (Map<String, Object>)m.get('result');
        }
        return result;
        //return JSON.serialize(result);
    }
    
    // callout to 3ffood
    public static HttpResponse callOut(String httpMethod, String endPoint, String uid, String sid, String body){
		HttpRequest req = new HttpRequest();
		req.setMethod(httpMethod);
		req.setEndpoint(endPoint);
		req.setTimeout(30000);
		if(String.isNotBlank(uid)){
			req.setHeader('uid', uid);
		}	
		if (String.isNotBlank(sid)){
			req.setHeader('sid', sid);
		}
		req.setBody(body); 
		HttpResponse res = new Http().send(req);
		return res;	
	} 
}