public class HTTPUtility 
{
     public static HttpResponse sendRequest(String endPoint, String token, String body, String methodType){
        
         Http http = new Http();
         HttpRequest request = new HttpRequest();
         request.setEndpoint(endpoint);
         request.setMethod(methodType); 
         request.setBody(body);
         request.setHeader( 'Content-Type', 'application/json' );
         request.setHeader( 'Authorization', 'Bearer ' + token );
         HttpResponse response = http.send(request);
      //   String returnValue =  response.getBody();
         return response ;
         
     }
}