public with sharing class SonController {
	private static final String APIKEY = 'AIzaSyCEjPIMYn3Omn0PjYyepLM5Hf4_YgTM_as';
	private static final String ENDPOINT = 'https://maps.googleapis.com/maps/api/geocode/json?latlng={0},{1}&key=' + APIKEY;

	@AuraEnabled
	public static String getAddress(Decimal inputLat, Decimal inputLong) {
		try {
			Http http = new Http();
			HttpRequest req = new HttpRequest();
			req.setMethod('GET');
			req.setEndpoint(String.format(ENDPOINT, new String[]{ String.valueOf(inputLat), String.valueOf(inputLong) }));

			HttpResponse res = http.send(req);

			if (res.getStatusCode() != 200) {
				throw new SonException(String.format ('{0} {1} {2}', new String[]{ String.valueOf(res.getStatusCode()), res.getStatus(), res.getBody() }));
			}

			return res.getBody();
		}
		catch (Exception ex) {
			throw new AuraHandledException(ex.getMessage());
		}
	}
}