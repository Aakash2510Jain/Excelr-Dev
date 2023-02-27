public class CreateAndUpdateTaskOnLeadRecordID{
    /* public static void  CreateAndUpdateTaskOnLeadRecordID(string jsonstring,  string leadId ) {
     set<String> setobject  = new set<string>();

     Map<string, Object> m = (Map<string, Object>)JSON.deserializeUntyped(jsonstring);
     System.debug('Json on Map-->>:: ' +m);

     if(m.containsKey('objects')){
     List<Object> logsList = (List<Object>)m.get('objects');
     System.debug('loglist--->>' +logsList);

     for(Object obj :logsList){
     Map<string, Object> logmap 1 (Map<string, Object>)obj;
     System.debug('logmap =====> ' + logmap);
     string uuid = string.valueof(logmap.get('uuid'));
     System.debug('uuid--->>>'+uuid);
     setobject.add(uuid);
     }
     System.debug('setobject ::'+setobject);

     List<task> tasklist = [select id, callobject from task where callobject IN:setobject AND whoid=:leadId ];
     System.debug('tasklist-->>>' +tasklist.size());
     List<Task> tasklist1 = new list<Task>();
     if(!tasklist.isEmpty()){
     System.debug('1--->>' );
     for(Object obj :logsList){
     System.debug('2--->>' );
     Map<string, Object> logmap = (Map<string, Object>)obj;
     //   System.debug('logmap =====> ' + logmap);

     Task tk = new Task();
     tk.Subject = string.valueof(logmap.get('customer_number'));
     system.debug('Subject--->>>' +tk.Subject);
     tk.CallObject  = string.valueof(logmap.get('uuid'));
     system.debug(' tk.CallObject--->>>' +tk.CallObject);

     tk.knowlarity_cti__Knowlarity_Number__c =  string.valueof(logmap.get('knowlarity_number'));
     system.debug(' tk.knowlarity_cti__Knowlarity_Number__c--->>>' + tk.knowlarity_cti__Knowlarity_Number__c);
     tk.Call_Recording__c =  string.valueof(logmap.get('call_recording'));
     system.debug(' tk.Call_Recording__c--->>>' + tk.Call_Recording__c);

     tk.CallDurationInSeconds =  Integer.valueof(logmap.get('call_duration'));
     system.debug(' tk.CallDurationInSeconds--->>>' + tk.CallDurationInSeconds);
     tk.Call_Start_Date_Time__c =  DateTime.valueof(logmap.get('start_time'));
     system.debug('tk.Call_Start_Date_Time__c--->>>' + tk.Call_Start_Date_Time__c);
     tk.Call_Type__c = string.valueof(logmap.get('Call_Type'));
     system.debug(' tk.Call_Type__c--->>>' + tk.Call_Type__c);
     tk.knowlarity_cti__Second_Agent_Number__c = string.valueof(logmap.get('Call Group'));
     system.debug(' tk.knowlarity_cti__Second_Agent_Number__c--->>>' +  tk.knowlarity_cti__Second_Agent_Number__c);
     tk.Id = string.valueof(logmap.get('id'));
     system.debug(' tk.Id--->>>' + tk.Id);
     tk.RecurrenceTimeZoneSidKey = string.valueof(logmap.get('timezone_offset'));
     system.debug('  tk.RecurrenceTimeZoneSidKey--->>>' +  tk.RecurrenceTimeZoneSidKey);
     tasklist1.add(tk);
     }
     // insert tasklist1;
     }else if(tasklist.isEmpty()){
     System.debug('3--->>' );
     for(Object obj :logsList){
     System.debug('4--->>' );
     Map<string, Object> logmap = (Map<string, Object>)obj;
     Task tk = new Task();
     if(tk.Subject != null){
     tk.Subject = string.valueof(logmap.get('customer_number'));
     }
     if(tk.CallObject != null){
     tk.CallObject  = string.valueof(logmap.get('uuid'));
     }
     if(tk.knowlarity_cti__Knowlarity_Number__c != null){
     tk.knowlarity_cti__Knowlarity_Number__c =  string.valueof(logmap.get('knowlarity_number'));
     }
     if(tk.Call_Recording__c != null){
     tk.Call_Recording__c =  string.valueof(logmap.get('call_recording'));
     }
     if(tk.CallDurationInSeconds != null){

     if(tk.Call_Type__c != null){
     tk.Call_Type__c = string.valueof(logmap.get('Call_Type'));
     }
     if(tk.knowlarity_cti__Second_Agent_Number__c != null){
     tk.knowlarity_cti__Second_Agent_Number__c = string.valueof(logmap.get('Call Group'));
     }
     if(tk.Id != null){
     tk.Id = string.valueof(logmap.get('id'));
     }
     if(tk.RecurrenceTimeZoneSidKey != null){
     tk.RecurrenceTimeZoneSidKey = string.valueof(logmap.get('timezone_offset'));
     }
     tasklist1.add(tk);
     }
     }



     }
     upsert tasklist1;
     System.debug('tasklist1 ::'+tasklist1);
     }
     }*/
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
                                    Utility.API_ErrorORSuccess(err.getFields(), err.getMessage(), Integer.valueof(err.getStatusCode()), null, 'WebhookForFuture', 'uploadcalllogs', jsonstring);
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

            Task tsk = new Task();
            tsk.Subject = ' Knowlarity Call Log'; //(String) (TaskIdWithObject.get(str)).get('Call_Type') +
            tsk.CallObject = (String) (TaskIdWithObject.get(str)).get('uuid');

            tsk.OwnerId = ld[0].OwnerId;
            tsk.whoid = ld[0].Id;
            tsk.Call_Recording__c = (String) (TaskIdWithObject.get(str)).get('call_recording');
            tsk.CallDurationInSeconds = Integer.valueof((TaskIdWithObject.get(str)).get('call_duration'));

            String formatted = (String) (TaskIdWithObject.get(str)).get('start_time');
            tsk.Call_Start_Date_Time__c = Datetime.valueof(formatted);
            tsk.Call_End_Date_Time__c = (Datetime.valueof(formatted)).addSeconds(Integer.valueof((TaskIdWithObject.get(str)).get('call_duration')));
            return tsk;
        } catch (Exception e) {

            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('CreateAndUpdateTaskOnLeadRecordID', 'CreateTaskForLead', e , null);
            return null;
        }

    }

}