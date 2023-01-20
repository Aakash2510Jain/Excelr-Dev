@RESTResource(urlMapping = '/callyzerWebhook/*')
global without sharing class CallyzerWebhook {

@HttpPost
global static String WebhookListener(){

    try {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String body = req.requestBody.toString();
        system.debug('body-->'+body);
        //WebhookForFuture.uploadcalllogs(body);

        WebhookForFuture QueueablaWebhookJob = new WebhookForFuture (body);
        ID jobID = System.enqueueJob(QueueablaWebhookJob);  
        AsyncApexJob jobInfo = [SELECT Id, Status, NumberOfErrors FROM AsyncApexJob WHERE Id =: jobID];

        return 'SUCCESS';
    } catch (Exception e) {
        system.debug('error due to ' + e.getMessage());
            system.debug('at line number ' + e.getLineNumber());
            //HandleBusinessException.captureError('WebEngageWebhookHandler','engageWebhookListener', e, body );
            return 'Error - ' + e.getMessage();
        
    }

}
}