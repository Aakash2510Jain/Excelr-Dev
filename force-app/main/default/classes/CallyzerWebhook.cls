@RESTResource(urlMapping = '/callyzerWebhook/*')
global with sharing class CallyzerWebhook {

@HttpPost
global static String WebhookListener(){

    try {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String body = req.requestBody.toString();
        system.debug('body-->'+body);


        Set<String> EmployeePhones = new Set<String>();
        Set<String> TaskIds = new Set<String>();
        Set<String> CustomerPhones = new Set<String>();
        map<String, Map<string,Object>> CustomerPhoneWithObject = new map<String, Map<string,Object>>();
        map<String, Map<string,Object>> TaskIdWithObject = new map<String, Map<string,Object>>();
        Map<String, String> TaskIdwithCutomerPone = new map<String, String>();

        List<Task> ExistingtaskList;
        if ( !String.isEmpty(body) ){
            // Webhookwrapper RealTimeCallHistory = ( Webhookwrapper )JSON.deserialize(body, Webhookwrapper.class);
            // System.debug('RealTimeCallHistory ===> ' + RealTimeCallHistory);

            List<object> bodyMap = (List<object>) JSON.deserializeUntyped(body);
            system.debug('bodymap ===> ' + bodyMap);

            for (OBject obj : bodyMap) {
                Map<string,Object> m = (Map<string,Object>) obj;
                List<Object> logsList = (List<Object>)  m.get('Logs');
                EmployeePhones.add((String)m.get('employeeNumber'));
                
                for (Object logObj : logsList) {
                    Map<string,Object> logmap = (Map<string,Object>) logObj;
                    System.debug('logmap =====> '  + logmap);
                    CustomerPhones.add((String)logmap.get('number'));
                    TaskIds.add((string)logmap.get('id'));
                    CustomerPhoneWithObject.put((string)logmap.get('number'),logmap);
                    TaskIdWithObject.put((string)logmap.get('id'),logmap);
                    TaskIdwithCutomerPone.put((string)logmap.get('id'), (string)logmap.get('number'));
                }
            }

            if (!TaskIds.isEmpty()) {
                ExistingtaskList = [Select id From task where Id IN: TaskIds];

                if (!ExistingtaskList.isEmpty()) {
                    for (task tas : ExistingtaskList) {
                        if (TaskIdWithObject.containskey(tas.Id)) {
                            // Task tsk = new Task();
					        // tsk.Subject = 'Test Task';
					        // tsk.Status = 'Open';
					        // tsk.Priority = 'Normal';
					        // tsk.WhatId = accObj.ID;
					        // tsk.OwnerId = accObj.OwnerId;
					        // tskList.add(tsk);
                        }
                    }
                }
            
            }
        }
        return 'SUCCESS';
    } catch (Exception e) {
        system.debug('error due to ' + e.getMessage());
            system.debug('at line number ' + e.getLineNumber());
            //HandleBusinessException.captureError('WebEngageWebhookHandler','engageWebhookListener', e);
            return 'Error - ' + e.getMessage();
        
    }
    
        //RestContext.response.statusCode = 200;

}
}