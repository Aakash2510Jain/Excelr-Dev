@RESTResource(urlMapping = '/callyzerWebhook/*')
global without sharing class CallyzerWebhook{

    public static string requestbody;
    @HttpPost
    global static String WebhookListener(){

        try{
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            String body = req.requestBody.toString();
            system.debug('body-->' + body);
            requestbody = body;
            //WebhookForFuture.uploadcalllogs(body);

            //WebhookForFuture QueueablaWebhookJob = new WebhookForFuture (body);

            Queueable_CallyzerWebhook QueueablaCallyzerWebhookJob = new Queueable_CallyzerWebhook(body);
            ID jobID = System.enqueueJob(QueueablaCallyzerWebhookJob);
            AsyncApexJob jobInfo = [SELECT Id, Status, NumberOfErrors
                                    FROM AsyncApexJob
                                    WHERE Id = :jobID];

            return 'SUCCESS';
        } catch (Exception e){
            system.debug('error due to ' + e.getMessage());
            system.debug('at line number ' + e.getLineNumber());
            HandleBusinessException.captureError('CallyzerWebhook','WebhookListener', e, requestbody );
            return 'Error - ' + e.getMessage();

        }
    }

}