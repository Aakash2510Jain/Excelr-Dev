public with sharing class WebhookForFuture {
    
    @future
    Public static void uploadcalllogs(string callLogString){


        //-------------------------------------------- For Payload -------------------------------------------
        Set<String> EmployeePhones = new Set<String>();
        Set<String> TaskIds = new Set<String>();
        Set<String> CustomerPhones = new Set<String>();
        map<String, Map<string,Object>> CustomerPhoneWithObject = new map<String, Map<string,Object>>();
        map<String, Map<string,Object>> TaskIdWithObject = new map<String, Map<string,Object>>();
        Map<String, String> TaskIdwithCutomerPone = new map<String, String>();

        // ------------------------------------ From SalesForce ----------------------------------------
        Map<String, Lead> PhoneWithLead = new Map<String, Lead>();
        Map<String, Contact> PhoneWithContact = new Map<String, Contact>();
        Map<String, task> TaskCallObjectIdWithTask = new Map<string, task>();
        List<Task> ExistingtaskList;

        // ------------------------------------ To Insert Task ----------------------------------------
        List<Task> TaskListTobeInserted = new List<Task>();

        if ( !String.isEmpty(callLogString) ){
            // Webhookwrapper RealTimeCallHistory = ( Webhookwrapper )JSON.deserialize(body, Webhookwrapper.class);
            // System.debug('RealTimeCallHistory ===> ' + RealTimeCallHistory);

            List<object> bodyMap = (List<object>) JSON.deserializeUntyped(callLogString);
            system.debug('bodymap ===> ' + bodyMap);

            for (OBject obj : bodyMap) {
                Map<string,Object> m = (Map<string,Object>) obj;
                List<Object> logsList = (List<Object>)  m.get('Logs');
                EmployeePhones.add((String)m.get('employeeNumber'));
                
                for (Object logObj : logsList) {
                    Map<string,Object> logmap = (Map<string,Object>) logObj;
                    System.debug('logmap =====> '  + logmap);
                    CustomerPhones.add(((String)logmap.get('number')).right(10));
                    TaskIds.add((string)logmap.get('id'));
                    CustomerPhoneWithObject.put((string)logmap.get('number'),logmap);
                    TaskIdWithObject.put((string)logmap.get('id'),logmap);
                    TaskIdwithCutomerPone.put((string)logmap.get('id'), (string)logmap.get('number'));
                }
            }

            System.debug('CustomerPhones ====> ' + CustomerPhones);
            if (!CustomerPhones.isEmpty()) {
                list<Lead> ExistingLeadwithPhone = [Select id, Phone From Lead Where Phone IN:CustomerPhones And isConverted = false];

                if (!ExistingLeadwithPhone.isEmpty()) {
                    for (Lead ld : ExistingLeadwithPhone) {
                        PhoneWithLead.put(ld.Phone, ld);
                    }
                }
                LIst<Contact> ExistingContactwithPhone = [Select id, Phone From Contact Where Phone IN:CustomerPhones];

                for (Contact con : ExistingContactwithPhone) {
                    PhoneWithContact.put(con.Phone, con);
                }
            }
            System.debug('TaskIds ====> ' + TaskIds);
            if (!TaskIds.isEmpty()) {
                ExistingtaskList = [Select id, WhoId From task where CallObject IN: TaskIds];

                if (!ExistingtaskList.isEmpty()) {
                    for (task tas : ExistingtaskList) {
                        TaskCallObjectIdWithTask.put(tas.CallObject, tas);
                    }
                }
            }

            /*for (String str : CustomerPhoneWithObject.keyset()) {
                
                if (!PhoneWithLead.isEmpty()) {
                    if (PhoneWithLead.containsKey(str) && !TaskCallObjectIdWithTask.containsKey((String)(CustomerPhoneWithObject.get('str')).get('id')) && !PhoneWithContact.containsKey(str)) {
                        //Task tas = new 
                    }
                    
                }
                if (!PhoneWithContact.isEmpty()) {
                    if (PhoneWithContact.containsKey(str) && !TaskCallObjectIdWithTask.containsKey((String)(CustomerPhoneWithObject.get('str')).get('id')) && !PhoneWithLead.containsKey(str)) {
                    
                    }
                }
            }*/

            for (String  str : TaskIdWithObject.keyset()) {
                if (!PhoneWithLead.isEmpty()) {
                    if (PhoneWithLead.containsKey((String)(TaskIdWithObject.get(str)).get('number')) && !PhoneWithContact.containsKey((String)(TaskIdWithObject.get(str)).get('number')) ) {
                        if (!TaskCallObjectIdWithTask.isEmpty() && !TaskCallObjectIdWithTask.containsKey(str) ) {
                            Task tsk = new Task();
                            tsk.Subject = 'OUTBOUND CALLLOG';
                            tsk.CallObject = (String)(TaskIdWithObject.get(str)).get('id');
                            //This is the default...
                            tsk.OwnerId = PhoneWithLead.get((String)(TaskIdWithObject.get(str)).get('number')).OwnerId;
                            tsk.whoid = PhoneWithLead.get((String)(TaskIdWithObject.get(str)).get('number')).Id;
                            tsk.Status = 'New';
                            tsk.CallType = (String)(TaskIdWithObject.get(str)).get('callType');
                            tsk.CallDurationInSeconds = (Integer)(TaskIdWithObject.get(str)).get('duration');

                            tsk.Call_Start_Date_Time__c = (Datetime)(TaskIdWithObject.get(str)).get('callTime');
                            tsk.Call_End_Date_Time__c = ((Datetime)(TaskIdWithObject.get(str)).get('callTime')).addSeconds((Integer)(TaskIdWithObject.get(str)).get('duration'));
                            TaskListTobeInserted.add(tsk);
                        }
                        else {
                            Task tsk = new Task();
                            tsk.Subject = 'OUTBOUND CALLLOG';
                            tsk.CallObject = (String)(TaskIdWithObject.get(str)).get('id');
                            //This is the default...
                            tsk.OwnerId = PhoneWithLead.get((String)(TaskIdWithObject.get(str)).get('number')).OwnerId;
                            tsk.whoid = PhoneWithLead.get((String)(TaskIdWithObject.get(str)).get('number')).Id;
                            tsk.Status = 'New';
                            tsk.CallType = (String)(TaskIdWithObject.get(str)).get('callType');
                            tsk.CallDurationInSeconds = (Integer)(TaskIdWithObject.get(str)).get('duration');

                            tsk.Call_Start_Date_Time__c = (Datetime)(TaskIdWithObject.get(str)).get('callTime');
                            tsk.Call_End_Date_Time__c = ((Datetime)(TaskIdWithObject.get(str)).get('callTime')).addSeconds((Integer)(TaskIdWithObject.get(str)).get('duration'));
                            TaskListTobeInserted.add(tsk);
                        }
                            
                            //insert tsk;
                    }                    
                }
                if (!PhoneWithContact.isEmpty()){
                    if (!PhoneWithLead.containsKey((String)(TaskIdWithObject.get(str)).get('number')) && PhoneWithContact.containsKey((String)(TaskIdWithObject.get(str)).get('number')) && !TaskCallObjectIdWithTask.containsKey(str)) {
                        if (!TaskCallObjectIdWithTask.isEmpty() && !TaskCallObjectIdWithTask.containsKey(str) ) {
                            Task tsk = new Task();
                            tsk.Subject = 'OUTBOUND CALLLOG';
                            tsk.CallObject = (String)(TaskIdWithObject.get(str)).get('id');
                            //This is the default...
                            tsk.OwnerId = PhoneWithContact.get((String)(TaskIdWithObject.get(str)).get('number')).OwnerId;
                            tsk.WhoId = PhoneWithContact.get((String)(TaskIdWithObject.get(str)).get('number')).Id;
                            tsk.Status = 'New';
                            tsk.CallType = (String)(TaskIdWithObject.get(str)).get('callType');
                            tsk.CallDurationInSeconds = (Integer)(TaskIdWithObject.get(str)).get('duration');
                            tsk.Call_Start_Date_Time__c = (Datetime)(TaskIdWithObject.get(str)).get('callTime');
                            tsk.Call_End_Date_Time__c = ((Datetime)(TaskIdWithObject.get(str)).get('callTime')).addSeconds((Integer)(TaskIdWithObject.get(str)).get('duration'));
                            TaskListTobeInserted.add(tsk);
                            
                        }
                            
                    }
                    else {
                        Task tsk = new Task();
                            tsk.Subject = 'OUTBOUND CALLLOG';
                            tsk.CallObject = (String)(TaskIdWithObject.get(str)).get('id');
                            //This is the default...
                            tsk.OwnerId = PhoneWithContact.get((String)(TaskIdWithObject.get(str)).get('number')).OwnerId;
                            tsk.WhoId = PhoneWithContact.get((String)(TaskIdWithObject.get(str)).get('number')).Id;
                            tsk.Status = 'New';
                            tsk.CallType = (String)(TaskIdWithObject.get(str)).get('callType');
                            tsk.CallDurationInSeconds = (Integer)(TaskIdWithObject.get(str)).get('duration');
                            tsk.Call_Start_Date_Time__c = (Datetime)(TaskIdWithObject.get(str)).get('callTime');
                            tsk.Call_End_Date_Time__c = ((Datetime)(TaskIdWithObject.get(str)).get('callTime')).addSeconds((Integer)(TaskIdWithObject.get(str)).get('duration'));
                            TaskListTobeInserted.add(tsk);
                        
                    }
                            
                }
            }

            System.debug('TaskListTobeInserted =====> ' + TaskListTobeInserted);
            if (!TaskListTobeInserted.isEmpty()) {
                Database.SaveResult[] srList = Database.insert(TaskListTobeInserted, false);

                if (!srList.isEmpty()) {
                    for (Database.SaveResult sr : srList) {
                        if (sr.isSuccess()) {
                            // Operation was successful, so get the ID of the record that was processed
                            System.debug('Successfully inserted account. Account ID: ' + sr.getId());
                           Utility.API_ErrorORSuccess(null,  'SUCCESS',null, sr.getId());
                        }
                        else {
                            // Operation failed, so get all errors                
                            for(Database.Error err : sr.getErrors()) {
                                System.debug('The following error has occurred.');                    
                                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                System.debug('Account fields that affected this error: ' + err.getFields());
                                Utility.API_ErrorORSuccess(err.getFields(), err.getMessage(), Integer.valueof(err.getStatusCode()), null);
                            }
                        }
                    }
                    
                }
            }
        }

    }


    public Static void ConvertDatetimeObjectToDateTime(String DTObj){

        String DTOBJECT = '2022-12-08 11:48:54';
        DTOBJECT = DTOBJECT.replace(' ', 'T') + '.000Z';
        
    }
}