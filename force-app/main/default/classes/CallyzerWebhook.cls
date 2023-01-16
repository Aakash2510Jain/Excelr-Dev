@RESTResource(urlMapping = '/callyzerWebhook/*')
global without sharing class CallyzerWebhook {

@HttpPost
global static String WebhookListener(){

    try {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String body = req.requestBody.toString();
        system.debug('body-->'+body);
        WebhookForFuture.uploadcalllogs(body);
        return 'SUCCESS';
    } catch (Exception e) {
        system.debug('error due to ' + e.getMessage());
            system.debug('at line number ' + e.getLineNumber());
            //HandleBusinessException.captureError('WebEngageWebhookHandler','engageWebhookListener', e);
            return 'Error - ' + e.getMessage();
        
    }

}
}