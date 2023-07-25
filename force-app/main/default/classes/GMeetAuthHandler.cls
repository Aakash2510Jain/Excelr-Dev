public without sharing class GMeetAuthHandler {
    private static final String GOOGLECALENDARENDPOINT = 'https://www.googleapis.com/calendar/v3';
    private static final String GOOGLESERVICEACCOUNT = 'calenderservice@consummate-rush-393616.iam.gserviceaccount.com'; //change this with excelr cloud console service account name
    private static final String AUDIENCE_CLAIM = 'https://www.googleapis.com/oauth2/v4/token';
    private static final String CERTIFICATE = 'googlecalendarcertificate'; // this is the name/label of the jks certificate we uplodaded in salesforce
    private static final String SCOPE = 'https://www.googleapis.com/auth/calendar';
    
    public static String getAccessToken(String subId) {
      try{
    	Auth.JWT jwt = new Auth.JWT();
        jwt.setAud(AUDIENCE_CLAIM);
        jwt.setIss(GOOGLESERVICEACCOUNT);
        jwt.setSub(subId); //'harmanpreet.singh@relevel.com'
        jwt.setAdditionalClaims(new Map<String, Object>{ 'scope' => SCOPE });
      
        Auth.JWS jws = new Auth.JWS(jwt, CERTIFICATE);
      
        Auth.JWTBearerTokenExchange bearer = new Auth.JWTBearerTokenExchange(
          jwt.getAud(),
          jws
        );
      
        return bearer.getAccessToken();
  	} catch (Exception e){
      system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
    HandleBusinessException.captureError('GMeetAuthHandler', 'getAccessToken', e , null);
     return null;
  }
  }
}