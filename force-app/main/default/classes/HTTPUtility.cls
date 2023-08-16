public without sharing class HTTPUtility 
{
    public static HttpResponse sendRequest(String endPoint, String token, String body, String methodType){
        try{
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod(methodType); 
            request.setBody(body);
            request.setHeader( 'Content-Type', 'application/json' );
            request.setHeader( 'Authorization', 'Bearer ' + token );
            request.setHeader( 'Cookie', 'connect.sid=s%3A5cHT9SvlXjk40NIhxKha8bmgS4E5Qb2A.MlAhOPJ123OhpoyYo7ndk%2BnNJyfkEVFj4xJBSWiH0mY');
            request.setHeader( 'Accept-Encoding', 'gzip, deflate, br' );
            
            
            HttpResponse response = http.send(request);
            //   String returnValue =  response.getBody()
            return response ;
            
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('HTTPUtility', 'sendRequest', e , null);
            return null;
            
        }
    }
}