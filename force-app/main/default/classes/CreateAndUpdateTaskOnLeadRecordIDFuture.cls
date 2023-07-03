public without sharing class CreateAndUpdateTaskOnLeadRecordIDFuture {
    @future(callout=true)
    public static void CreateandUpdatetask(string jsonstring, string leadId){
        
        try{
            
            // =================================================== From Knowlarity data ======================================================
            set<String> setobject  = new set<string>();
            List<Task> ExistingtaskList = new List<Task>();
            Map<String, Task> TaskCallObjectIdWithTask = new Map<String, task>();
            map<String, Map<string, Object>> TaskIdWithObject = new map<String, Map<string, Object>>();
            
            // =================================================== In salesforce data ======================================================
            List<Task> TaskTobeCreatedorUpdated = new List<Task>();
            
            List<lead> Leadrec = [Select id, ownerId from lead where id =: leadId];
            
            
            if (jsonstring != null){
                Map<string, Object> m = (Map<string, Object>)JSON.deserializeUntyped(jsonstring);
                System.debug('Json on Map-->>:: ' + m);
                
                if (m.containsKey('objects')){
                    
                    List<Object> logsList = (List<Object>)m.get('objects');
                    System.debug('loglist--->>' + logsList);
                    
                    for (Object obj : logsList){
                        Map<string, Object> logmap = (Map<string, Object>)obj;
                        System.debug('logmap =====> ' + logmap);
                        string uuid = string.valueof(logmap.get('uuid'));
                        System.debug('uuid--->>>' + uuid);
                        setobject.add(uuid);
                        TaskIdWithObject.put((string) logmap.get('uuid'), logmap);
                    }
                }
                
                
                
                if (!setobject.isempty()) {
                    ExistingtaskList = [Select id, WhoId, ownerId, CallObject
                                        From task
                                        where CallObject IN:setobject and whoId =:leadId];
                    
                    if (!ExistingtaskList.isEmpty()){
                        for (task tas : ExistingtaskList){
                            TaskCallObjectIdWithTask.put(tas.CallObject, tas);
                        }
                    }
                }
                
                System.debug('TaskIdWithObject====> ' + TaskIdWithObject);
                
                integer i = 0;
                for (String str : TaskIdWithObject.keyset()) {
                    i++;
                    //if (i<3) {
                    if (!TaskCallObjectIdWithTask.isempty() && TaskCallObjectIdWithTask.containskey(str)) {
                        
                        task tsk = CreateTaskForLead(TaskIdWithObject, str, Leadrec);
                        tsk.id = TaskCallObjectIdWithTask.get(str).id;
                        TaskTobeCreatedorUpdated.add(tsk);
                        
                    }else if(TaskCallObjectIdWithTask.isempty() && !TaskCallObjectIdWithTask.containskey(str) ){ 
                        task tsk = CreateTaskForLead(TaskIdWithObject, str, Leadrec);
                        TaskTobeCreatedorUpdated.add(tsk);
                        
                    }
                    else {
                        task tsk = CreateTaskForLead(TaskIdWithObject, str, Leadrec);
                        TaskTobeCreatedorUpdated.add(tsk);
                    }
                    
                    //}
                    
                    
                }
                
                System.debug('TaskTobeCreatedorUpdated =====> ' + TaskTobeCreatedorUpdated);
                System.debug('TaskTobeCreatedorUpdated =====> ' + TaskTobeCreatedorUpdated.size());
                if (!TaskTobeCreatedorUpdated.isEmpty()){
                    //Database.SaveResult[] srList = Database.insert (TaskListTobeInserted, false);
                    
                    Database.UpsertResult[] srList = Database.upsert (TaskTobeCreatedorUpdated, false);
                    
                    if (!srList.isEmpty()){
                        for (Database.UpsertResult sr : srList){
                            if (sr.isSuccess()){
                                // Operation was successful, so get the ID of the record that was processed
                                System.debug('Successfully inserted account. Account ID: ' + sr.getId());
                                Utility.API_ErrorORSuccess(null, 'SUCCESS', null, sr.getId(), 'WebhookForFuture', 'uploadcalllogs', jsonstring);
                            } else{
                                // Operation failed, so get all errors
                                for (Database.Error err : sr.getErrors()){
                                    System.debug('The following error has occurred.');
                                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                    System.debug('Account fields that affected this error: ' + err.getFields());
                                    Utility.API_ErrorORSuccess(err.getFields(), err.getMessage(), String.valueof(err.getStatusCode()), null, 'WebhookForFuture', 'uploadcalllogs', jsonstring);
                                }
                            }
                        }
                        
                    }
                }
                
            }
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('CreateAndUpdateTaskOnLeadRecordID', 'CreateandUpdatetask', e , null);
            
        }
    }
    
    Public static Task CreateTaskForLead(map<String, Map<string, Object>> TaskIdWithObject, String str, list<Lead> ld ){
        
        try {
            
            String formatted = (String) (TaskIdWithObject.get(str)).get('start_time');
            
            Task tsk = new Task();
            tsk.Subject = ' Knowlarity Call Log' + ' - ' + Datetime.valueof(formatted).addMinutes(330) ; //(String) (TaskIdWithObject.get(str)).get('Call_Type') +
            tsk.CallObject = (String) (TaskIdWithObject.get(str)).get('uuid');
            tsk.Status = 'Completed';
            tsk.Calling_Party__c = 'Knowlarity';
            tsk.OwnerId = ld[0].OwnerId;
            tsk.whoid = ld[0].Id;
            tsk.Call_Recording__c = (String) (TaskIdWithObject.get(str)).get('call_recording');
            tsk.CallDurationInSeconds = Integer.valueof((TaskIdWithObject.get(str)).get('call_duration'));
            
            tsk.Call_Start_Date_Time__c = Datetime.valueof(formatted).addMinutes(330);
            tsk.Call_End_Date_Time__c = ((Datetime.valueof(formatted)).addSeconds(Integer.valueof((TaskIdWithObject.get(str)).get('call_duration')))).addMinutes(330);
            return tsk;
        } catch (Exception e) {
            
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('CreateAndUpdateTaskOnLeadRecordID', 'CreateTaskForLead', e , null);
            return null;
        }
        
    }
}