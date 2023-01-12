@RESTResource(urlMapping = '/Webhook/*')
global with sharing class CallyzerWebhook {
    
    @HttpPost
    global static void engageWebhookListener(){

        RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            String body = req.requestBody.toString();
            system.debug('body-->'+body);

            

            /*if ( !String.isEmpty(body) ){
                // Webhookwrapper RealTimeCallHistory = ( Webhookwrapper )JSON.deserialize(body, Webhookwrapper.class);
                // System.debug('RealTimeCallHistory ===> ' + RealTimeCallHistory);

                List<object> bodyMap = (List<object>) JSON.deserializeUntyped(body);
                system.debug('bodymap ===> ' + bodyMap);

                for (OBject obj : bodyMap) {
                    Map<string,Object> m = (Map<string,Object>) obj;
                    List<Object> logsList = (List<Object>)  m.get('Logs');
                    // for (Object logObj : logsList) {
                    //     Map<string,Object> logmap = (Map<string,Object>) logObj;
                    //     System.debug('logmap =====> '  + logmap);
                    // }

                    
                }
                
            }*/
            RestContext.response.statusCode = 200;

    }
}