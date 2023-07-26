@RestResource(urlMapping = '/LMSCreateUpdateProduct') 
global with sharing class API_LMSCreateProduct {
   
    @HttpPost
    global static void PostLMS_CreateProduct(){

        try{
            RestRequest req = RestContext.request;
            Blob body = req.requestBody;
            String requestString = body.toString();
            System.debug('--- rquestString' + requestString);
            if (!String.isEmpty(requestString)){
                RestContext.response.responseBody = Blob.valueOf('{"Status": "SUCCESS","Message": "Batch Created Successfully"}');
                RestContext.response.statusCode = 200;
            } else{
                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new IntegrationWrapper.APIResponseWrapper('Error', '[{"ref": "003N000001xyPbwIAE","message": "Couldn\'t process this lead due to error"}, { "ref": "003N000001xyPbwIAE","message": "Couldn\'t process this lead due to error" }]')));
                RestContext.response.statusCode = 400;
            }
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('API_LMSUpdateStudentStatus', 'PostLMS_UpdateStudentStatus', e, null);

        }
    }
}