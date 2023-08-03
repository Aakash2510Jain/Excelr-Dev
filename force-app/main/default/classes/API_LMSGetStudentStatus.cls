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
                res.responseBody = Blob.valueOf('{ "status":"success","message": "Student status updated successfully"}');
                res.statusCode = 200;
            } else{
                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new IntegrationWrapper.APIResponseWrapper('Error', '[{"ref": "003N000001xyPbwIAE","message": "Couldn\'t process this lead due to error"}, { "ref": "003N000001xyPbwIAE","message": "Couldn\'t process this lead due to error" }]')));
                res.statusCode = 400;
            }
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('API_LMSGetStudentStatus', 'fetchLMSStudentStatus', e, null);


        }
    }

}