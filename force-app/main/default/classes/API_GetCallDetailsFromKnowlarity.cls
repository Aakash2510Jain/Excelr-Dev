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
    
    
    @AuraEnabled
    public static void fecthCallDetails(string leadId){
        system.debug('leadId--->'+leadId);
        
        Lead leadRec = [Select Id,Phone,CreatedDate,Alternate_Phone__c From Lead Where Id =: leadId ];
        system.debug('leadRec--->'+leadRec);
        if(!string.isBlank(leadRec.Phone) && (leadRec.Phone).Length() > 7){
            Knowlarity_Integration__c knowlarityConfiguration = Knowlarity_Integration__c.getValues('KnowlarityConfig');
            DateTime currentdateTime = system.now().addDays(1);
            DateTime startDateTime = leadRec.CreatedDate.addDays(-2);
            string leadPhone = (leadRec.Phone).replaceAll('[^0-9]', ''); 
            system.debug('startDateTime--->'+startDateTime);
            system.debug('currentdateTime--->'+currentdateTime);
            
            string endpoint = 'https://kpi.knowlarity.com/Basic/v1/account/calllog?start_time=';
            endpoint = endpoint+String.valueOf((startDateTime).date())+'%20'+String.valueOf((startDateTime).hour())+'%3A'+String.valueOf((startDateTime).minute())+'%3A00%2B05%3A30&end_time='+String.valueOf(currentdateTime.date())+'%20'+String.valueOf((currentdateTime).hour())+'%3A'+String.valueOf((currentdateTime).minute())+'%3A00%2B05%3A30&customer_number=%2B'+leadPhone;
            system.debug('endpoint--->'+endpoint);
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('GET');
            req.setHeader('channel', 'Basic');
            req.setHeader('x-api-key', knowlarityConfiguration.ApiKey__c);
            req.setHeader('authorization', knowlarityConfiguration.authorization__c);
            req.setHeader('content-type', 'application/json');
            
            Http http = new Http();
            HTTPResponse res = http.send(req);
            System.debug('Response Body :'+res.getBody());
            
            if (res.getBody() != null) {
                CreateAndUpdateTaskOnLeadRecordID.CreateandUpdatetask(res.getBody(),leadId );
            }
        }
        
    }
    @AuraEnabled
    public static void fecthCallDetailsForAlternatePhone(string leadId){
        system.debug('leadId--->'+leadId);
        
        Lead leadRec = [Select Id,Phone,CreatedDate,Alternate_Phone__c From Lead Where Id =: leadId ];
        system.debug('leadRec--->'+leadRec);
        if(!string.isBlank(leadRec.Alternate_Phone__c) && (leadRec.Alternate_Phone__c).Length() > 7){
            Knowlarity_Integration__c knowlarityConfiguration = Knowlarity_Integration__c.getValues('KnowlarityConfig');
            DateTime currentdateTime = system.now().addDays(1);
            DateTime startDateTime = leadRec.CreatedDate.addDays(-2);
            string leadPhone = (leadRec.Alternate_Phone__c).replaceAll('[^0-9]', ''); 
            system.debug('startDateTime--->'+startDateTime);
            system.debug('currentdateTime--->'+currentdateTime);
            
            string endpoint = 'https://kpi.knowlarity.com/Basic/v1/account/calllog?start_time=';
            endpoint = endpoint+String.valueOf((startDateTime).date())+'%20'+String.valueOf((startDateTime).hour())+'%3A'+String.valueOf((startDateTime).minute())+'%3A00%2B05%3A30&end_time='+String.valueOf(currentdateTime.date())+'%20'+String.valueOf((currentdateTime).hour())+'%3A'+String.valueOf((currentdateTime).minute())+'%3A00%2B05%3A30&customer_number=%2B'+leadPhone;
            system.debug('endpoint--->'+endpoint);
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('GET');
            req.setHeader('channel', 'Basic');
            req.setHeader('x-api-key', knowlarityConfiguration.ApiKey__c);
            req.setHeader('authorization', knowlarityConfiguration.authorization__c);
            req.setHeader('content-type', 'application/json');
            
            Http http = new Http();
            HTTPResponse res = http.send(req);
            System.debug('Response Body :'+res.getBody());
            
            if (res.getBody() != null) {
                CreateAndUpdateTaskOnLeadRecordID.CreateandUpdatetask(res.getBody(),leadId );
            }
        }
        
    }
}