@RestResource(urlMapping = '/LMSPostBulkRegistration')
global with sharing class API_LMSPostBulkRegistration {

    @HttpPost
    global static void PostLMS_BulkLeadRegistration(){
        try{
            RestRequest req = RestContext.request;
            Blob body = req.requestBody;
            String requestString = body.toString();
            System.debug('--- rquestString' + requestString);
            if (!String.isEmpty(requestString)){
                RestContext.response.responseBody = Blob.valueOf('{"Status": "SUCCESS","Message": "All Lead details have been Captured Successfully","ref_id": "vfsvfsv228"}');
                RestContext.response.statusCode = 200;
            } else{
                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new IntegrationWrapper.APIResponseWrapper('Error', 'Bad Request')));
                RestContext.response.statusCode = 400;
            }
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('API_LMSPostBulkRegistration', 'PostLMS_BulkLeadRegistration', e, null);

        }
    }
    
}