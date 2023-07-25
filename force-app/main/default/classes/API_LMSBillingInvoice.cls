@RestResource(urlMapping='/LMSBillingInvoice')
Global without sharing class API_LMSBillingInvoice {

    @HttpGet
    global static void fetchLMSBillingInvoice(){

        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        String studentId = req.params.get('studentId');
        System.debug('studentId =====> ' + studentId);


        res.responseBody = Blob.valueOf('[{"progname": "Data Science","Percentage": 67.4,"TotalSessionsAttended": 4,"PlannedSessions": 10},{"progname": "Data Science","Percentage": 67.4,"TotalSessionsAttended": 4,"PlannedSessions": 10}]');
       // return 'Success';

    }
    
}
/*
 [
  {
    "progname": "Data Science",
    "Percentage": 67.4,
    "TotalSessionsAttended": 4,
    "PlannedSessions": 10
  },
  {
    "progname": "Data Science",
    "Percentage": 67.4,
    "TotalSessionsAttended": 4,
    "PlannedSessions": 10
  }
]*/