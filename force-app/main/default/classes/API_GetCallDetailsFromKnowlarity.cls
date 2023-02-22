/*
*start_time - 2023-02-01 12:00:00+05:30 	- 2023-02-01%2012%3A00%3A00%2B05%3A30
* end_time - 2023-02-01 23:00:00+05:30 	- 2023-02-01%2023%3A00%3A00%2B05%3A30
*customer_number - +917709075200       	- %2B918233121865
*/
global without sharing class API_GetCallDetailsFromKnowlarity {
    public static void basicAuthCallout(){
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://kpi.knowlarity.com/Basic/v1/account/calllog?start_time=2023-02-01%2012%3A00%3A00%2B05%3A30&end_time=2023-02-01%2023%3A00%3A00%2B05%3A30&customer_number=%2B918233121865');
        req.setMethod('GET');
        
        
        req.setHeader('channel', 'Basic');
        req.setHeader('x-api-key', '3UGvH47ybGYDU9ZlwNv45k5ZBYBh8jh6k4XVymgg');
        req.setHeader('authorization', 'b4b4636e-72cc-4a19-8b38-911c1ec3118e');
        req.setHeader('content-type', 'application/json');
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());
    }
    public static void fecthCallDetails(string leadId){
        Lead leadRec = [Select Id,Phone,CreatedDate From Lead Where Id =: leadId And Phone != null];
        if(leadRec != null){
            Knowlarity_Integration__c knowlarityConfiguration = Knowlarity_Integration__c.getValues('KnowlarityConfig');
            DateTime currentdateTime = system.now();
            DateTime startDateTime = leadRec.CreatedDate.addDays(-1);
            string leadPhone = (leadRec.Phone).replaceAll('[^0-9]', ''); 
            
            string endpoint = 'https://kpi.knowlarity.com/Basic/v1/account/calllog?start_time=';
            endpoint = endpoint+String.valueOf((startDateTime).year())+'%20'+String.valueOf((startDateTime).hour())+'%3A'+String.valueOf((startDateTime).minute())+'%3A00%2B05%3A30&end_time='+String.valueOf(currentdateTime.year())+'%20'+String.valueOf((currentdateTime).hour())+'%3A'+String.valueOf((currentdateTime).minute())+'%3A00%2B05%3A30&customer_number=%2B'+leadPhone;
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('GET');
            req.setHeader('channel', 'Basic');
            req.setHeader('x-api-key', knowlarityConfiguration.ApiKey__c);
            req.setHeader('authorization', knowlarityConfiguration.authorization__c);
            req.setHeader('content-type', 'application/json');
            
            Http http = new Http();
            HTTPResponse res = http.send(req);
            System.debug(res.getBody());
        }
    }
    /*
     * resposne body
     {
   "meta":{
      "limit":20,
      "next":"",
      "offset":0,
      "previous":"",
      "total_count":1
   },
   "objects":[
      {
         "customer_number":"+919542104052",
         "uuid":"b944d879-b6a0-4720-b2a0-b4bf0b4b033f",
         "agent_number":"+919108238354",
         "call_duration":128,
         "business_call_type":"Call Group",
         "id":1,
         "order_id":0,
         "destination":"+919108238354",
         "Call_Type":0,
         "call_recording":"https://kservices.knowlarity.com/kstorage/read?uuid=b944d879-b6a0-4720-b2a0-b4bf0b4b033f.mp3&server_name=BANGALORE&base_dir=recording&user_id=1250851",
         "knowlarity_number":"18002122121",
         "start_time":"2023-02-22 18:51:29+05:30",
         "credits_deducted":"0.00",
         "extension":"",
         "caller_name":"",
         "timezone_offset":"+0530"
      }
   ]
}
*/
}