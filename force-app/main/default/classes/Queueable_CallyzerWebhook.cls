/**
* @author [Mukesh Chawla]
* @email [mukesh.chawla@utilitarianLab.com]
* @create date 2023-02-06 16:55:16
* @modify date 2023-02-06 16:55:16
* @desc [description]
*/
public without sharing class Queueable_CallyzerWebhook implements Queueable{
    private String callLogString;
    public Queueable_CallyzerWebhook(String callLogString){
        this.callLogString = callLogString;
    }
    
    Public void execute(QueueableContext context){
        
        //-------------------------------------------- For Payload -------------------------------------------
        Set<String> EmployeePhones = new Set<String>();
        Set<String> TaskIds = new Set<String>();
        Set<String> CustomerPhones = new Set<String>();
        Set<String> CustomerPhonesForContact = new Set<String>();
        map<String, Map<string, Object>> CustomerPhoneWithObject = new map<String, Map<string, Object>>();
        map<String, Map<string, Object>> TaskIdWithObject = new map<String, Map<string, Object>>();
        Map<String, String> TaskIdwithCutomerPone = new map<String, String>();
        
        // ------------------------------------ From SalesForce ----------------------------------------
        Map<String, Lead> PhoneWithLead = new Map<String, Lead>();
        Map<String, Contact> PhoneWithContact = new Map<String, Contact>();
        Map<String, task> TaskCallObjectIdWithTask = new Map<string, task>();
        List<Task> ExistingtaskList;
        Set<String> PhoneStringNotExistintheSystem = new Set<String>();
        map<string, Callyzer_Sales_User__c> PhoneWithCallSalesUser = new Map<String, Callyzer_Sales_User__c>();
        map<String, String> LeadCustomerPhoneWithEmployeePhone = new Map<String, String>();
        map<String, String> ContactCustomerPhoneWithEmployeePhone = new Map<String, String>();
        
        // ------------------------------------ To Insert Task ----------------------------------------
        List<Task> TaskListTobeInserted = new List<Task>();
        
        
        try{
            
            if (!String.isEmpty(callLogString)){
                
                List<object> bodyMap = (List<object>)JSON.deserializeUntyped(callLogString);
                system.debug('bodymap ===> ' + bodyMap);
                
                for (OBject obj : bodyMap){
                    Map<string, Object> m = (Map<string, Object>)obj;
                    List<Object> logsList = (List<Object>)m.get('logs');
                    EmployeePhones.add((String) m.get('employeeNumber'));
                    String EmployeePhone = (String) m.get('employeeNumber');
                    
                    for (Object logObj : logsList){
                        
                        Map<string, Object> logmap = (Map<string, Object>)logObj;
                        System.debug('logmap =====> ' + logmap);
                        
                        LeadCustomerPhoneWithEmployeePhone.put('+'+(String) logmap.get('countryCode')+ ((String) logmap.get('number')).right(10), EmployeePhone);
                        ContactCustomerPhoneWithEmployeePhone.put(((String) logmap.get('number')).right(10), EmployeePhone);
                        
                        CustomerPhones.add('+'+(String) logmap.get('countryCode')+((String) logmap.get('number')).right(10));
                        CustomerPhonesForContact.add(((String) logmap.get('number')).right(10));
                        TaskIds.add((string) logmap.get('id'));
                        CustomerPhoneWithObject.put((string) logmap.get('number'), logmap);
                        TaskIdWithObject.put((string) logmap.get('id'), logmap);
                        TaskIdwithCutomerPone.put((string) logmap.get('id'), (string) logmap.get('number'));
                    }
                }
                List<Callyzer_Sales_User__c> CallyzerSalesUser = [SELECT callyzerId__c, countryCode__c, deviceName__c, employeeCode__c, Id, mobile__c, Name, OwnerId
                                                                  FROM Callyzer_Sales_User__c
                                                                  Where mobile__c IN:EmployeePhones];
                System.debug('CallyzerSalesUser ===> ' + CallyzerSalesUser);
                
                if (!CallyzerSalesUser.isEmpty() && CallyzerSalesUser.size() > 0){
                    for (Callyzer_Sales_User__c CSU : CallyzerSalesUser){
                        PhoneWithCallSalesUser.put(CSU.mobile__c, CSU);
                        
                    }
                    
                }
                
                System.debug('CustomerPhones ====> ' + CustomerPhones);
                if (!CustomerPhones.isEmpty()){
                    System.debug('I am finding existing Lead');
                    list<Lead> ExistingLeadwithPhone = [Select id, Phone, ownerId
                                                        From Lead
                                                        Where Phone IN:CustomerPhones And status != 'Dead' And status != 'Junk' And isConverted = false];
                    System.debug('ExistingLeadwithPhone ====> ' + ExistingLeadwithPhone);
                    
                    
                    if (ExistingLeadwithPhone.size() > 0){
                        for (Lead ld : ExistingLeadwithPhone){
                            PhoneWithLead.put(ld.Phone, ld);
                        }
                    }
                    System.debug('PhoneWithLead =====> ' + PhoneWithLead);
                    
                }
                if (CustomerPhonesForContact.size() > 0){
                    LIst<Contact> ExistingContactwithPhone = [Select id, Phone, ownerId
                                                              From Contact
                                                              Where Phone IN:CustomerPhonesForContact];
                    if (ExistingContactwithPhone.size() > 0){
                        for (Contact con : ExistingContactwithPhone){
                            PhoneWithContact.put(con.Phone, con);
                        }
                    }
                }
                System.debug('PhoneWithContact =====> ' + PhoneWithContact);
                
                if (CustomerPhones.size() > 0){
                    for (string phoneStr : CustomerPhones){
                        if (!PhoneWithContact.containsKey(phoneStr.right(10)) && !PhoneWithLead.containsKey(phoneStr)){
                            PhoneStringNotExistintheSystem.add(phoneStr);
                        }
                    }
                }
                
                System.debug('PhoneStringNotExistintheSystem =====> ' + PhoneStringNotExistintheSystem);
                system.debug('TaskIdWithObject---->'+TaskIdWithObject);
                for (String str : TaskIdWithObject.keyset()){
                    if (!PhoneWithLead.isEmpty()){
                        System.debug('(String) (TaskIdWithObject.get(str)).get(number)).right(10) ==== >' + ((String) (TaskIdWithObject.get(str)).get('number')));
                        if (PhoneWithLead.containsKey('+'+((String) (TaskIdWithObject.get(str)).get('countryCode'))+((String) (TaskIdWithObject.get(str)).get('number')).right(10))){
                            //&& !PhoneWithContact.containsKey(((String) (TaskIdWithObject.get(str)).get('number')).right(10))
                            System.debug('I am inside to create task for Lead');
                            if (!TaskCallObjectIdWithTask.isEmpty() && !TaskCallObjectIdWithTask.containsKey(str)){
                                Task tsk = CreateTaskForLead(TaskIdWithObject, str, PhoneWithLead);
                                
                                if (LeadCustomerPhoneWithEmployeePhone.containsKey(((String) (TaskIdWithObject.get(str)).get('number')).right(10))){
                                    string customerphone = ((String) (TaskIdWithObject.get(str)).get('number')).right(10);
                                    String employeenumber = LeadCustomerPhoneWithEmployeePhone.get(customerphone);
                                    if (!PhoneWithCallSalesUser.isEmpty() && PhoneWithCallSalesUser.containsKey(employeenumber)){
                                        tsk.Callyzer_Sales_User__c = PhoneWithCallSalesUser.get(employeenumber).Id;
                                    }
                                }
                                /*if (!PhoneWithCallSalesUser.isEmpty()){
tsk.Callyzer_Sales_User__c = CallyzerSalesUser[0].id;
}*/
                                
                                TaskListTobeInserted.add(tsk);
                            } else if (!TaskCallObjectIdWithTask.isEmpty() && TaskCallObjectIdWithTask.containsKey(str)){
                                Task tsk = CreateTaskForLead(TaskIdWithObject, str, PhoneWithLead);
                                tsk.Id = TaskCallObjectIdWithTask.get(str).Id;
                                /*if (CallyzerSalesUser.size() > 0){
tsk.Callyzer_Sales_User__c = CallyzerSalesUser[0].id;
}*/
                                if (LeadCustomerPhoneWithEmployeePhone.containsKey( ((String) (TaskIdWithObject.get(str)).get('number')).right(10))){
                                    string customerphone = ((String) (TaskIdWithObject.get(str)).get('number')).right(10);
                                    String employeenumber = LeadCustomerPhoneWithEmployeePhone.get(customerphone);
                                    if (!PhoneWithCallSalesUser.isEmpty() && PhoneWithCallSalesUser.containsKey(employeenumber)){
                                        tsk.Callyzer_Sales_User__c = PhoneWithCallSalesUser.get(employeenumber).Id;
                                    }
                                }
                                TaskListTobeInserted.add(tsk);
                            } else{
                                Task tsk = CreateTaskForLead(TaskIdWithObject, str, PhoneWithLead);
                                //tsk.Id = TaskCallObjectIdWithTask.get(str).Id;
                                /*if (CallyzerSalesUser.size() > 0){
tsk.Callyzer_Sales_User__c = CallyzerSalesUser[0].id;
}*/
                                if (LeadCustomerPhoneWithEmployeePhone.containsKey( ((String) (TaskIdWithObject.get(str)).get('number')).right(10))){
                                    string customerphone = '+91' + ((String) (TaskIdWithObject.get(str)).get('number')).right(10);
                                    String employeenumber = LeadCustomerPhoneWithEmployeePhone.get(customerphone);
                                    if (!PhoneWithCallSalesUser.isEmpty() && PhoneWithCallSalesUser.containsKey(employeenumber)){
                                        tsk.Callyzer_Sales_User__c = PhoneWithCallSalesUser.get(employeenumber).Id;
                                    }
                                }
                                TaskListTobeInserted.add(tsk);
                            }
                            
                            //insert tsk;
                        }
                    }
                    if (!PhoneWithContact.isEmpty()){
                        System.debug('(String) (TaskIdWithObject.get(str)).get(number)).right(10) ==== >' + ((String) (TaskIdWithObject.get(str)).get('number')));
                        System.debug('phone exist in Lead or not ====> ' + PhoneWithLead.containsKey(((String) (TaskIdWithObject.get(str)).get('number')).right(10)));
                        if (!PhoneWithLead.containsKey( ((String) (TaskIdWithObject.get(str)).get('number')).right(10)) && PhoneWithContact.containsKey(((String) (TaskIdWithObject.get(str)).get('number')).right(10))){
                            //!PhoneWithLead.containsKey(((String) (TaskIdWithObject.get(str)).get('number')).right(10)) &&
                            System.debug('I am inside to create task for Contact');
                            if (!TaskCallObjectIdWithTask.isEmpty() && !TaskCallObjectIdWithTask.containsKey(str)){
                                Task tsk = CreatetaskForContact(TaskIdWithObject, str, PhoneWithContact);
                                /*if (CallyzerSalesUser.size() > 0){
tsk.Callyzer_Sales_User__c = CallyzerSalesUser[0].id;
}*/
                                
                                if (ContactCustomerPhoneWithEmployeePhone.containsKey(((String) (TaskIdWithObject.get(str)).get('number')).right(10))){
                                    string customerphone = ((String) (TaskIdWithObject.get(str)).get('number')).right(10);
                                    String employeenumber = ContactCustomerPhoneWithEmployeePhone.get(customerphone);
                                    if (!PhoneWithCallSalesUser.isEmpty() && PhoneWithCallSalesUser.containsKey(employeenumber)){
                                        tsk.Callyzer_Sales_User__c = PhoneWithCallSalesUser.get(employeenumber).Id;
                                    }
                                }
                                TaskListTobeInserted.add(tsk);
                            } else if (!TaskCallObjectIdWithTask.isEmpty() && TaskCallObjectIdWithTask.containsKey(str)){
                                Task tsk = CreatetaskForContact(TaskIdWithObject, str, PhoneWithContact);
                                tsk.Id = TaskCallObjectIdWithTask.get(str).Id;
                                /*if (CallyzerSalesUser.size() > 0){
tsk.Callyzer_Sales_User__c = CallyzerSalesUser[0].id;
}*/
                                if (ContactCustomerPhoneWithEmployeePhone.containsKey(((String) (TaskIdWithObject.get(str)).get('number')).right(10))){
                                    string customerphone = ((String) (TaskIdWithObject.get(str)).get('number')).right(10);
                                    String employeenumber = ContactCustomerPhoneWithEmployeePhone.get(customerphone);
                                    if (!PhoneWithCallSalesUser.isEmpty() && PhoneWithCallSalesUser.containsKey(employeenumber)){
                                        tsk.Callyzer_Sales_User__c = PhoneWithCallSalesUser.get(employeenumber).Id;
                                    }
                                }
                                TaskListTobeInserted.add(tsk);
                                
                            } else{
                                Task tsk = CreatetaskForContact(TaskIdWithObject, str, PhoneWithContact);
                                //tsk.Id = TaskCallObjectIdWithTask.get(str).Id;
                                /*if (CallyzerSalesUser.size() > 0){
tsk.Callyzer_Sales_User__c = CallyzerSalesUser[0].id;
}*/
                                if (ContactCustomerPhoneWithEmployeePhone.containsKey(((String) (TaskIdWithObject.get(str)).get('number')).right(10))){
                                    string customerphone = ((String) (TaskIdWithObject.get(str)).get('number')).right(10);
                                    String employeenumber = ContactCustomerPhoneWithEmployeePhone.get(customerphone);
                                    if (!PhoneWithCallSalesUser.isEmpty() && PhoneWithCallSalesUser.containsKey(employeenumber)){
                                        tsk.Callyzer_Sales_User__c = PhoneWithCallSalesUser.get(employeenumber).Id;
                                    }
                                }
                                TaskListTobeInserted.add(tsk);
                            }
                        }
                    }
                    /*if (PhoneStringNotExistintheSystem.size() > 0){
if (!PhoneWithLead.containsKey('+91' + ((String) (TaskIdWithObject.get(str)).get('number')).right(10)) && !PhoneWithContact.containsKey(((String) (TaskIdWithObject.get(str)).get('number')).right(10))){
if (!TaskCallObjectIdWithTask.isEmpty() && !TaskCallObjectIdWithTask.containsKey(str)){
Task tsk = createLeadAndtask(str,TaskIdWithObject);
if (CallyzerSalesUser.size() >0) {
tsk.Callyzer_Sales_User__c = CallyzerSalesUser[0].id;
}
TaskListTobeInserted.add(tsk);
} else{
Task tsk = createLeadAndtask(str, TaskIdWithObject);
if (CallyzerSalesUser.size() >0) {
tsk.Callyzer_Sales_User__c = CallyzerSalesUser[0].id;
}
TaskListTobeInserted.add(tsk);

}
}

}*/
                }
                
                System.debug('TaskListTobeInserted =====> ' + TaskListTobeInserted);
                if (!TaskListTobeInserted.isEmpty()){
                    //Database.SaveResult[] srList = Database.insert (TaskListTobeInserted, false);
                    
                    Database.UpsertResult[] srList = Database.upsert (TaskListTobeInserted, false);
                    
                    if (!srList.isEmpty()){
                        for (Database.UpsertResult sr : srList){
                            if (sr.isSuccess()){
                                // Operation was successful, so get the ID of the record that was processed
                                System.debug('Successfully inserted account. Task ID: ' + sr.getId());
                                Utility.API_ErrorORSuccess(null, 'SUCCESS', null, sr.getId(), 'Queueable_CallyzerWebhook', 'execute', callLogString);
                            } else{
                                // Operation failed, so get all errors
                                for (Database.Error err : sr.getErrors()){
                                    System.debug('The following error has occurred.');
                                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                    System.debug('Account fields that affected this error: ' + err.getFields());
                                    Utility.API_ErrorORSuccess(err.getFields(), err.getMessage(), Integer.valueof(err.getStatusCode()), null, 'Queueable_CallyzerWebhook', 'execute', callLogString);
                                }
                            }
                        }
                        
                    }
                }
                
                
            }
            
        } catch (Exception e){
            system.debug('at line number ' + e.getLineNumber());
            HandleBusinessException.captureError('Queueable_CallyzerWebhook', 'execute', e, callLogString);
            //HandleBusinessException.captureError('WebEngageWebhookHandler', 'engageWebhookListener', e, callLogString);
            
        }
    }
    
    Public static Task CreateTaskForLead(map<String, Map<string, Object>> TaskIdWithObject, String str, Map<String, Lead> PhoneWithLead){
        try{
            Task tsk = new Task();
            tsk.Subject = (String) (TaskIdWithObject.get(str)).get('callType') + ' Callyzer Call Log';
            tsk.CallObject = (String) (TaskIdWithObject.get(str)).get('id');
            //This is the default...
            tsk.OwnerId = PhoneWithLead.get('+'+(String) (TaskIdWithObject.get(str)).get('countryCode')+ ((String) (TaskIdWithObject.get(str)).get('number')).right(10)).OwnerId;
            tsk.whoid = PhoneWithLead.get('+'+(String) (TaskIdWithObject.get(str)).get('countryCode')+ ((String) (TaskIdWithObject.get(str)).get('number')).right(10)).Id;
            tsk.Status = 'Completed';
            tsk.Call_Type__c = (String) (TaskIdWithObject.get(str)).get('callType');
            tsk.CallDurationInSeconds = Integer.valueof((TaskIdWithObject.get(str)).get('duration'));
            //tsk.Call_Start_Date_Time__c = (DateTime)JSON.deserialize('"' + String.valueOf((TaskIdWithObject.get(str)).get('callTime')) + '"', DateTime.class);
            // tsk.Call_Start_Date_Time__c = Datetime.valueof((TaskIdWithObject.get(str)).get('callTime'));
            // tsk.Call_End_Date_Time__c = (Datetime.valueof((TaskIdWithObject.get(str)).get('callTime'))).addSeconds((Integer) (TaskIdWithObject.get(str)).get('duration'));
            String formatted = (String) (TaskIdWithObject.get(str)).get('callTime');
            tsk.Call_Start_Date_Time__c = Datetime.valueof(formatted);
            tsk.Call_End_Date_Time__c = (Datetime.valueof(formatted)).addSeconds(Integer.valueof((TaskIdWithObject.get(str)).get('duration')));
            return tsk;
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('WebEngageWebhookHandler', 'CreateTaskForLead', e, null);
            return null;
        }
    }
    
    Public static Task CreatetaskForContact(map<String, Map<string, Object>> TaskIdWithObject, String str, Map<String, Contact> PhoneWithContact){
        try{
            Task tsk = new Task();
            tsk.Subject = (String) (TaskIdWithObject.get(str)).get('callType') + ' Callyzer Call Log';
            tsk.CallObject = (String) (TaskIdWithObject.get(str)).get('id');
            //This is the default...
            System.debug('((String) (TaskIdWithObject.get(str)).get(number)).right(10)' + ((String) (TaskIdWithObject.get(str)).get('number')).right(10));
            tsk.OwnerId = PhoneWithContact.get(((String) (TaskIdWithObject.get(str)).get('number')).right(10)).OwnerId;
            tsk.WhoId = PhoneWithContact.get(((String) (TaskIdWithObject.get(str)).get('number')).right(10)).Id;
            tsk.Status = 'New';
            tsk.Call_Type__c = (String) (TaskIdWithObject.get(str)).get('callType');
            tsk.CallDurationInSeconds = Integer.valueof((TaskIdWithObject.get(str)).get('duration'));
            
            String formatted = (String) (TaskIdWithObject.get(str)).get('callTime');
            tsk.Call_Start_Date_Time__c = Datetime.valueof(formatted);
            tsk.Call_End_Date_Time__c = (Datetime.valueof(formatted)).addSeconds(Integer.valueof((TaskIdWithObject.get(str)).get('duration')));
            Return tsk;
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('WebEngageWebhookHandler', 'CreatetaskForContact', e, null);
            return null;
        }
    }
    
    Public Static task createLeadAndtask(String str, map<String, Map<string, Object>> TaskIdWithObject){
        try{
            Lead ld = new Lead();
            ld.lastname = str.right(10);
            ld.company = str.right(10);
            ld.Phone = '+91' + str.right(10);
            insert ld;
            
            Task tsk = new Task();
            tsk.Subject = (String) (TaskIdWithObject.get(str)).get('callType') + ' Callyzer Call Log';
            tsk.CallObject = (String) (TaskIdWithObject.get(str)).get('id');
            //This is the default...
            System.debug('((String) (TaskIdWithObject.get(str)).get(number)).right(10)' + ((String) (TaskIdWithObject.get(str)).get('number')).right(10));
            tsk.OwnerId = ld.OwnerId;
            tsk.WhoId = ld.Id;
            tsk.Status = 'New';
            tsk.Call_Type__c = (String) (TaskIdWithObject.get(str)).get('callType');
            tsk.CallDurationInSeconds = Integer.valueof((TaskIdWithObject.get(str)).get('duration'));
            
            String formatted = (String) (TaskIdWithObject.get(str)).get('callTime');
            tsk.Call_Start_Date_Time__c = Datetime.valueof(formatted);
            tsk.Call_End_Date_Time__c = (Datetime.valueof(formatted)).addSeconds(Integer.valueof((TaskIdWithObject.get(str)).get('duration')));
            Return tsk;
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('WebEngageWebhookHandler', 'createLeadAndtask', e, null);
            return null;
        }
    }
    
}