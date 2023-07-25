@RestResource(urlMapping='/LMSStudentAttendence')
global with sharing class API_LMSStudentAttendence {

    @HttpGet
    global static void fetchLMSStudentAttendence(){

        try {
            RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        String studentId = req.params.get('studentId');
        System.debug('studentId =====> ' + studentId);

        if (studentId != null){
        res.responseBody = Blob.valueOf(' [{"studentId": "003N000001xyPbwIAE","progname": "Data Science","Percentage": 67.4,"TotalSessionsAttended": 4,"PlannedSessions": 10},{"studentId": "003N000001xyPbwIAE","progname": "Data Science","Percentage": 67.4,"TotalSessionsAttended": 4,"PlannedSessions": 10}]');
        }
        else{
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new IntegrationWrapper.APIResponseWrapper('Error', 'Could not Fetch Student Attendence Details. StudentID is null')));
        }
            
        } catch (Exception e) {
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('API_LMSStudentAttendence', 'fetchLMSStudentAttendence', e, null);
        }
        
       // return 'Success';

    }
    
}