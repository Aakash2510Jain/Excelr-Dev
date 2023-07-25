@RestResource(urlMapping = '/LMSGetStudentStatus')
global with sharing class API_LMSGetStudentStatus{

    @HttpGet
    global static void fetchLMSStudentStatus(){

        try{
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            res.addHeader('Content-Type', 'application/json');
            String studentId = req.params.get('student_Id');
            System.debug('studentId =====> ' + studentId);
            if (studentId != null){
                res.responseBody = Blob.valueOf('[{"status": "", "refered_by_details" : {"referrer_id" : "cust-1311","referrer_name" : "XYZ","referrer_email" : "referrer.email123@mailinator.com"},"student_id": "003N000001xyPbwIAE"},{"status": "","refered_by_details" : { "referrer_id" : "cust-1311","referrer_name" : "XYZ", "referrer_email" : "referrer.email123@mailinator.com"},"student_id": "003N000001xyPbwIAE" }]');
                res.statusCode = 200;
            } else{
                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new IntegrationWrapper.APIResponseWrapper('Error', 'Could not Fetch Student Status. StudentID is null')));
                res.statusCode = 400;
            }
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('API_LMSGetStudentStatus', 'fetchLMSStudentStatus', e, null);


        }
    }

}