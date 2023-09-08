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

        Map<String, Opportunity> PhoneWithOpportunity = new Map<String, Opportunity>();

        Map<String, task> TaskCallObjectIdWithLeadTask = new Map<string, task>();
        Map<String, task> TaskCallObjectIdWithContactTask = new Map<string, task>();
        Map<String, task> TaskCallObjectIdWithOppTask = new Map<string, task>();
        List<Task> ExistingtaskList;
        Set<String> PhoneStringNotExistintheSystem = new Set<String>();
        map<string, Callyzer_Sales_User__c> PhoneWithCallSalesUser = new Map<String, Callyzer_Sales_User__c>();
        map<String, String> LeadCustomerPhoneWithEmployeePhone = new Map<String, String>();
        map<String, String> ContactCustomerPhoneWithEmployeePhone = new Map<String, String>();

        // ------------------------------------ To Insert Task ----------------------------------------
        List<Task> TaskListTobeInserted = new List<Task>();

        // ------------------------------------ Existing Leads ----------------------------------------

        list<Lead> ExistingLeadwithPhone = new List<Lead>();
        list<Opportunity> ExistingOpportunitieswithPhone = new List<Opportunity>();
        LIst<Contact> ExistingContactwithPhone = new List<Contact>();
        List<Lead> leadListToBeUpdatedForTelephonicConversation = new List<Lead>();

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

                        LeadCustomerPhoneWithEmployeePhone.put(((String) logmap.get('number')), EmployeePhone);
                        ContactCustomerPhoneWithEmployeePhone.put(((String) logmap.get('number')), EmployeePhone);

                        CustomerPhones.add('+' + (String) logmap.get('countryCode') + ((String) logmap.get('number')));
                        //country code and + should be added
                        CustomerPhonesForContact.add('+' + (String) logmap.get('countryCode') + ((String) logmap.get('number')));
                        TaskIds.add((string) logmap.get('id'));
                        //country code and + should be added
                        //CustomerPhoneWithObject.put((string) logmap.get('number'), logmap);
                        CustomerPhoneWithObject.put('+' + (String) logmap.get('countryCode') + (string) logmap.get('number'), logmap);
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
                    ExistingLeadwithPhone = [Select id, Phone, ownerId, MobilePhone, Alternate_Phone__c, Telephonic_Conversation__c
                                             From Lead
                                             Where (Phone IN:CustomerPhones OR Alternate_Phone__c IN:CustomerPhones) And isConverted = false];
                    System.debug('ExistingLeadwithPhone ====> ' + ExistingLeadwithPhone);


                    if (ExistingLeadwithPhone.size() > 0){
                        for (Lead ld : ExistingLeadwithPhone){
                            if (ld.Phone != null && CustomerPhoneWithObject.containskey((ld.Phone))){
                                PhoneWithLead.put(ld.Phone, ld);
                            } else if (ld.Alternate_Phone__c != null && CustomerPhoneWithObject.containskey((ld.Alternate_Phone__c))){
                                PhoneWithLead.put(ld.Alternate_Phone__c, ld);
                            }
                            leadListToBeUpdatedForTelephonicConversation.add(new Lead(id = ld.Id, Telephonic_Conversation__c = true));
                        }

                        if (!leadListToBeUpdatedForTelephonicConversation.isEmpty()){
                            update leadListToBeUpdatedForTelephonicConversation;
                        }
                    }
                    System.debug('PhoneWithLead =====> ' + PhoneWithLead);

                    ExistingOpportunitieswithPhone = [SELECT Alternate_Email__c, Alternate_Phone__c, Course__c, Customers__c, Email__c, Id, LeadSource, Lead_Gen_Path__c, Name, Phone__c, State__c, Type, OwnerId
                                                      FROM Opportunity
                                                      Where (Phone__c IN:CustomerPhones OR Alternate_Phone__c IN:CustomerPhones)];

                    if (!ExistingOpportunitieswithPhone.isEmpty()){
                        for (Opportunity opp : ExistingOpportunitieswithPhone){
                            if (opp.Phone__c != null && CustomerPhoneWithObject.containskey((opp.Phone__c))){
                                PhoneWithOpportunity.put(opp.Phone__c, opp);
                            } else if (opp.Alternate_Phone__c != null && CustomerPhoneWithObject.containskey((opp.Alternate_Phone__c))){
                                PhoneWithOpportunity.put(opp.Alternate_Phone__c, opp);
                            }

                        }
                    }

                    System.debug('PhoneWithOpportunity =====> ' + PhoneWithOpportunity);

                }
                if (CustomerPhonesForContact.size() > 0){
                    ExistingContactwithPhone = [Select id, Phone, ownerId, Alternate_Phone__c
                                                From Contact
                                                Where (Phone IN:CustomerPhonesForContact OR Alternate_Phone__c IN:CustomerPhonesForContact)];
                    if (ExistingContactwithPhone.size() > 0){
                        for (Contact con : ExistingContactwithPhone){
                            if (con.Phone != null && CustomerPhoneWithObject.containskey((con.Phone))){
                                PhoneWithContact.put(con.Phone, con);
                            } else if (con.Alternate_Phone__c != null && CustomerPhoneWithObject.containskey((con.Alternate_Phone__c))){
                                PhoneWithContact.put(con.Alternate_Phone__c, con);
                            }

                        }
                    }
                }
                System.debug('PhoneWithContact =====> ' + PhoneWithContact);

                if (CustomerPhones.size() > 0){
                    for (string phoneStr : CustomerPhones){
                        if (!PhoneWithContact.containsKey(phoneStr) && !PhoneWithLead.containsKey(phoneStr) && !PhoneWithOpportunity.containsKey(phoneStr)){
                            PhoneStringNotExistintheSystem.add(phoneStr);
                        }
                    }
                }

                System.debug('TaskIds ====> ' + TaskIds);
                if (!TaskIds.isEmpty()){
                    ExistingtaskList = [Select id, WhoId, ownerId, CallObject, whatId
                                        From task
                                        where CallObject IN:TaskIds];

                    if (!ExistingtaskList.isEmpty()){
                        for (task tas : ExistingtaskList){
                            if (tas.whoId != null && String.valueof((tas.whoId).getsobjecttype()) == 'Lead'){
                                TaskCallObjectIdWithLeadTask.put(tas.CallObject, tas);
                            } else if (tas.whoId != null && String.valueof((tas.whoId).getsobjecttype()) == 'Contact'){
                                TaskCallObjectIdWithContactTask.put(tas.CallObject, tas);
                            } else if (tas.whatId != null && String.valueof((tas.whatId).getsobjecttype()) == 'Opportunity'){
                                TaskCallObjectIdWithOppTask.put(tas.CallObject, tas);
                            }
                            //TaskCallObjectIdWithTask.put(tas.CallObject, tas);
                        }
                    }
                }

                System.debug('TaskCallObjectIdWithLeadTask =====> ' + TaskCallObjectIdWithLeadTask);
                System.debug('TaskCallObjectIdWithContactTask =====> ' + TaskCallObjectIdWithContactTask);

                System.debug('PhoneStringNotExistintheSystem =====> ' + PhoneStringNotExistintheSystem);
                system.debug('TaskIdWithObject---->' + TaskIdWithObject);
                for (String str : TaskIdWithObject.keyset()){
                    for (lead leadRec : ExistingLeadwithPhone){
                        if (!PhoneWithLead.isEmpty()){
                            System.debug('(String) (TaskIdWithObject.get(str)).get(number)) ==== >' + ((String) (TaskIdWithObject.get(str)).get('number')));
                            if ((leadRec.Phone == ('+' + ((String) (TaskIdWithObject.get(str)).get('countryCode')) + ((String) (TaskIdWithObject.get(str)).get('number')))) || (leadRec.MobilePhone == ('+' + ((String) (TaskIdWithObject.get(str)).get('countryCode')) + ((String) (TaskIdWithObject.get(str)).get('number')))) || (leadRec.Alternate_Phone__c == ('+' + ((String) (TaskIdWithObject.get(str)).get('countryCode')) + ((String) (TaskIdWithObject.get(str)).get('number'))))){
                                //&& !PhoneWithContact.containsKey(((String) (TaskIdWithObject.get(str)).get('number')))
                                System.debug('I am inside to create task for Lead');
                                if (!TaskCallObjectIdWithLeadTask.isEmpty() && !TaskCallObjectIdWithLeadTask.containsKey(str) && !TaskCallObjectIdWithOppTask.containsKey(str)){
                                    Task tsk = CreateTaskForLead(TaskIdWithObject, str, leadRec);

                                    if (LeadCustomerPhoneWithEmployeePhone.containsKey(((String) (TaskIdWithObject.get(str)).get('number')))){
                                        string customerphone = ((String) (TaskIdWithObject.get(str)).get('number'));
                                        String employeenumber = LeadCustomerPhoneWithEmployeePhone.get(customerphone);
                                        if (!PhoneWithCallSalesUser.isEmpty() && PhoneWithCallSalesUser.containsKey(employeenumber)){
                                            tsk.Callyzer_Sales_User__c = PhoneWithCallSalesUser.get(employeenumber).Id;
                                        }
                                    }

                                    TaskListTobeInserted.add(tsk);
                                } else if (!TaskCallObjectIdWithLeadTask.isEmpty() && TaskCallObjectIdWithLeadTask.containsKey(str) && !TaskCallObjectIdWithOppTask.containsKey(str)){
                                    Task tsk = CreateTaskForLead(TaskIdWithObject, str, leadRec);
                                    tsk.Id = TaskCallObjectIdWithLeadTask.get(str).Id;

                                    if (LeadCustomerPhoneWithEmployeePhone.containsKey(((String) (TaskIdWithObject.get(str)).get('number')))){
                                        string customerphone = ((String) (TaskIdWithObject.get(str)).get('number'));
                                        String employeenumber = LeadCustomerPhoneWithEmployeePhone.get(customerphone);
                                        if (!PhoneWithCallSalesUser.isEmpty() && PhoneWithCallSalesUser.containsKey(employeenumber)){
                                            tsk.Callyzer_Sales_User__c = PhoneWithCallSalesUser.get(employeenumber).Id;
                                        }
                                    }
                                    TaskListTobeInserted.add(tsk);
                                } else{
                                    if (!TaskCallObjectIdWithOppTask.containsKey(str)){
                                        Task tsk = CreateTaskForLead(TaskIdWithObject, str, leadRec);

                                        if (LeadCustomerPhoneWithEmployeePhone.containsKey(((String) (TaskIdWithObject.get(str)).get('number')))){
                                            string customerphone = ((String) (TaskIdWithObject.get(str)).get('number'));
                                            String employeenumber = LeadCustomerPhoneWithEmployeePhone.get(customerphone);
                                            if (!PhoneWithCallSalesUser.isEmpty() && PhoneWithCallSalesUser.containsKey(employeenumber)){
                                                tsk.Callyzer_Sales_User__c = PhoneWithCallSalesUser.get(employeenumber).Id;
                                            }
                                        }
                                        TaskListTobeInserted.add(tsk);

                                    }

                                }

                                //insert tsk;
                            }
                        }
                    }

                    /*for (Contact con : ExistingContactwithPhone) {
                     if (!PhoneWithContact.isEmpty()){
                     System.debug('(String) (TaskIdWithObject.get(str)).get(number)) ==== >' + ((String) (TaskIdWithObject.get(str)).get('number')));
                     System.debug('phone exist in Lead or not ====> ' + PhoneWithLead.containsKey(((String) (TaskIdWithObject.get(str)).get('number'))));
                     if (!PhoneWithLead.containsKey(((String) (TaskIdWithObject.get(str)).get('number'))) && ( con.Phone == ((String) (TaskIdWithObject.get(str)).get('number'))  || con.Alternate_Phone__c == ((String) (TaskIdWithObject.get(str)).get('number')) )){
                     //!PhoneWithLead.containsKey(((String) (TaskIdWithObject.get(str)).get('number'))) &&
                     System.debug('I am inside to create task for Contact');
                     if (!TaskCallObjectIdWithContactTask.isEmpty() && !TaskCallObjectIdWithContactTask.containsKey(str)){
                     Task tsk = CreatetaskForContact(TaskIdWithObject, str, PhoneWithContact);

                     if (ContactCustomerPhoneWithEmployeePhone.containsKey(((String) (TaskIdWithObject.get(str)).get('number')))){
                     string customerphone = ((String) (TaskIdWithObject.get(str)).get('number'));
                     String employeenumber = ContactCustomerPhoneWithEmployeePhone.get(customerphone);
                     if (!PhoneWithCallSalesUser.isEmpty() && PhoneWithCallSalesUser.containsKey(employeenumber)){
                     tsk.Callyzer_Sales_User__c = PhoneWithCallSalesUser.get(employeenumber).Id;
                     }
                     }
                     TaskListTobeInserted.add(tsk);
                     } else if (!TaskCallObjectIdWithContactTask.isEmpty() && TaskCallObjectIdWithContactTask.containsKey(str)){
                     Task tsk = CreatetaskForContact(TaskIdWithObject, str, PhoneWithContact);
                     tsk.Id = TaskCallObjectIdWithContactTask.get(str).Id;
                     if (ContactCustomerPhoneWithEmployeePhone.containsKey(((String) (TaskIdWithObject.get(str)).get('number')))){
                     string customerphone = ((String) (TaskIdWithObject.get(str)).get('number'));
                     String employeenumber = ContactCustomerPhoneWithEmployeePhone.get(customerphone);
                     if (!PhoneWithCallSalesUser.isEmpty() && PhoneWithCallSalesUser.containsKey(employeenumber)){
                     tsk.Callyzer_Sales_User__c = PhoneWithCallSalesUser.get(employeenumber).Id;
                     }
                     }
                     TaskListTobeInserted.add(tsk);

                     } else{
                     Task tsk = CreatetaskForContact(TaskIdWithObject, str, PhoneWithContact);
                     if (ContactCustomerPhoneWithEmployeePhone.containsKey(((String) (TaskIdWithObject.get(str)).get('number')))){
                     string customerphone = ((String) (TaskIdWithObject.get(str)).get('number'));
                     String employeenumber = ContactCustomerPhoneWithEmployeePhone.get(customerphone);
                     if (!PhoneWithCallSalesUser.isEmpty() && PhoneWithCallSalesUser.containsKey(employeenumber)){
                     tsk.Callyzer_Sales_User__c = PhoneWithCallSalesUser.get(employeenumber).Id;
                     }
                     }
                     TaskListTobeInserted.add(tsk);
                     }
                     }
                     }

                     }*/

                    for (Opportunity Opp : ExistingOpportunitieswithPhone){
                        if (!PhoneWithOpportunity.isEmpty()){
                            if ((Opp.Phone__c == ('+' + ((String) (TaskIdWithObject.get(str)).get('countryCode')) + ((String) (TaskIdWithObject.get(str)).get('number')))) || (Opp.Alternate_Phone__c == ('+' + ((String) (TaskIdWithObject.get(str)).get('countryCode')) + ((String) (TaskIdWithObject.get(str)).get('number'))))){
                                //&& !PhoneWithContact.containsKey(((String) (TaskIdWithObject.get(str)).get('number')))
                                System.debug('I am inside to create task for Lead');
                                if (!TaskCallObjectIdWithOppTask.isEmpty() && !TaskCallObjectIdWithOppTask.containsKey(str) && !TaskCallObjectIdWithLeadTask.containsKey(str)){
                                    Task tsk = CreateTaskForOpportunity(TaskIdWithObject, str, Opp);

                                    if (LeadCustomerPhoneWithEmployeePhone.containsKey(((String) (TaskIdWithObject.get(str)).get('number')))){
                                        string customerphone = ((String) (TaskIdWithObject.get(str)).get('number'));
                                        String employeenumber = LeadCustomerPhoneWithEmployeePhone.get(customerphone);
                                        if (!PhoneWithCallSalesUser.isEmpty() && PhoneWithCallSalesUser.containsKey(employeenumber)){
                                            tsk.Callyzer_Sales_User__c = PhoneWithCallSalesUser.get(employeenumber).Id;
                                        }
                                    }

                                    TaskListTobeInserted.add(tsk);
                                } else if (!TaskCallObjectIdWithOppTask.isEmpty() && TaskCallObjectIdWithOppTask.containsKey(str) && !TaskCallObjectIdWithLeadTask.containsKey(str)){
                                    Task tsk = CreateTaskForOpportunity(TaskIdWithObject, str, Opp);
                                    tsk.Id = TaskCallObjectIdWithOppTask.get(str).Id;

                                    if (LeadCustomerPhoneWithEmployeePhone.containsKey(((String) (TaskIdWithObject.get(str)).get('number')))){
                                        string customerphone = ((String) (TaskIdWithObject.get(str)).get('number'));
                                        String employeenumber = LeadCustomerPhoneWithEmployeePhone.get(customerphone);
                                        if (!PhoneWithCallSalesUser.isEmpty() && PhoneWithCallSalesUser.containsKey(employeenumber)){
                                            tsk.Callyzer_Sales_User__c = PhoneWithCallSalesUser.get(employeenumber).Id;
                                        }
                                    }
                                    TaskListTobeInserted.add(tsk);
                                } else{
                                    if (!TaskCallObjectIdWithLeadTask.containsKey(str)){
                                        Task tsk = CreateTaskForOpportunity(TaskIdWithObject, str, Opp);

                                        if (LeadCustomerPhoneWithEmployeePhone.containsKey(((String) (TaskIdWithObject.get(str)).get('number')))){
                                            string customerphone = ((String) (TaskIdWithObject.get(str)).get('number'));
                                            String employeenumber = LeadCustomerPhoneWithEmployeePhone.get(customerphone);
                                            if (!PhoneWithCallSalesUser.isEmpty() && PhoneWithCallSalesUser.containsKey(employeenumber)){
                                                tsk.Callyzer_Sales_User__c = PhoneWithCallSalesUser.get(employeenumber).Id;
                                            }
                                        }
                                        TaskListTobeInserted.add(tsk);

                                    }

                                }

                                //insert tsk;
                            }

                        }

                    }

                    /*if (PhoneStringNotExistintheSystem.size() > 0){
                     if (!PhoneWithLead.containsKey('+91' + ((String) (TaskIdWithObject.get(str)).get('number'))) && !PhoneWithContact.containsKey(((String) (TaskIdWithObject.get(str)).get('number')))){
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
                                System.debug('Successfully inserted. Task ID: ' + sr.getId());
                                Utility.API_ErrorORSuccess(null, 'SUCCESS', null, sr.getId(), 'Queueable_CallyzerWebhook', 'execute', callLogString);
                            } else{
                                // Operation failed, so get all errors
                                for (Database.Error err : sr.getErrors()){
                                    System.debug('The following error has occurred.');
                                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                    System.debug('Account fields that affected this error: ' + err.getFields());
                                    Utility.API_ErrorORSuccess(err.getFields(), err.getMessage(), String.valueof(err.getStatusCode()), null, 'Queueable_CallyzerWebhook', 'execute', callLogString);
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

    Public static Task CreateTaskForLead(map<String, Map<string, Object>> TaskIdWithObject, String str, Lead PhoneWithLead){
        try{
            Task tsk = new Task();
            tsk.Subject = (String) (TaskIdWithObject.get(str)).get('callType') + ' Callyzer Call Log';
            tsk.CallObject = (String) (TaskIdWithObject.get(str)).get('id');
            //This is the default...
            tsk.OwnerId = PhoneWithLead.OwnerId;//PhoneWithLead.get('+'+(String) (TaskIdWithObject.get(str)).get('countryCode')+ ((String) (TaskIdWithObject.get(str)).get('number'))).OwnerId;
            tsk.whoid = PhoneWithLead.Id;//PhoneWithLead.get('+'+(String) (TaskIdWithObject.get(str)).get('countryCode')+ ((String) (TaskIdWithObject.get(str)).get('number'))).Id;
            tsk.Status = 'Completed';
            tsk.Calling_Party__c = 'Callyzer';
            tsk.Call_Type__c = (String) (TaskIdWithObject.get(str)).get('callType');
            tsk.CallDurationInSeconds = Integer.valueof((TaskIdWithObject.get(str)).get('duration'));
            //tsk.Call_Start_Date_Time__c = (DateTime)JSON.deserialize('"' + String.valueOf((TaskIdWithObject.get(str)).get('callTime')) + '"', DateTime.class);
            // tsk.Call_Start_Date_Time__c = Datetime.valueof((TaskIdWithObject.get(str)).get('callTime'));
            // tsk.Call_End_Date_Time__c = (Datetime.valueof((TaskIdWithObject.get(str)).get('callTime'))).addSeconds((Integer) (TaskIdWithObject.get(str)).get('duration'));
            String formatted = (String) (TaskIdWithObject.get(str)).get('callTime');
            if(formatted.contains(',')){
                String formattedDate = formatted.replace(',', '');
                tsk.Call_Start_Date_Time__c = Datetime.valueof(formattedDate);
            }
            else {
                tsk.Call_Start_Date_Time__c = Datetime.valueof(formatted);
            }
            //tsk.Call_Start_Date_Time__c = Datetime.valueof(formatted);
            if(formatted.contains(',')){
                String formattedDate = formatted.replace(',', '');
                tsk.Call_End_Date_Time__c = (Datetime.valueof(formattedDate)).addSeconds(Integer.valueof((TaskIdWithObject.get(str)).get('duration')));
            }
            else {
                tsk.Call_End_Date_Time__c = (Datetime.valueof(formatted)).addSeconds(Integer.valueof((TaskIdWithObject.get(str)).get('duration')));
            }
            //tsk.Call_End_Date_Time__c = (Datetime.valueof(formatted)).addSeconds(Integer.valueof((TaskIdWithObject.get(str)).get('duration')));
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
            System.debug('((String) (TaskIdWithObject.get(str)).get(number))' + ((String) (TaskIdWithObject.get(str)).get('number')));
            tsk.OwnerId = PhoneWithContact.get(((String) (TaskIdWithObject.get(str)).get('number'))).OwnerId;
            tsk.WhoId = PhoneWithContact.get(((String) (TaskIdWithObject.get(str)).get('number'))).Id;
            tsk.Status = 'Completed';
            tsk.Calling_Party__c = 'Callyzer';
            tsk.Call_Type__c = (String) (TaskIdWithObject.get(str)).get('callType');
            tsk.CallDurationInSeconds = Integer.valueof((TaskIdWithObject.get(str)).get('duration'));

            String formatted = (String) (TaskIdWithObject.get(str)).get('callTime');
            //tsk.Call_Start_Date_Time__c = Datetime.valueof(formatted);
            //tsk.Call_End_Date_Time__c = (Datetime.valueof(formatted)).addSeconds(Integer.valueof((TaskIdWithObject.get(str)).get('duration')));
            if(formatted.contains(',')){
                String formattedDate = formatted.replace(',', '');
                tsk.Call_Start_Date_Time__c = Datetime.valueof(formattedDate);
            }
            else {
                tsk.Call_Start_Date_Time__c = Datetime.valueof(formatted);
            }
            //tsk.Call_Start_Date_Time__c = Datetime.valueof(formatted);
            if(formatted.contains(',')){
                String formattedDate = formatted.replace(',', '');
                tsk.Call_End_Date_Time__c = (Datetime.valueof(formattedDate)).addSeconds(Integer.valueof((TaskIdWithObject.get(str)).get('duration')));
            }
            else {
                tsk.Call_End_Date_Time__c = (Datetime.valueof(formatted)).addSeconds(Integer.valueof((TaskIdWithObject.get(str)).get('duration')));
            }
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
            System.debug('((String) (TaskIdWithObject.get(str)).get(number))' + ((String) (TaskIdWithObject.get(str)).get('number')));
            tsk.OwnerId = ld.OwnerId;
            tsk.WhoId = ld.Id;
            tsk.Status = 'Completed';
            tsk.Calling_Party__c = 'Callyzer';
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

    Public static Task CreateTaskForOpportunity(map<String, Map<string, Object>> TaskIdWithObject, String str, Opportunity PhoneWithOpp){
        try{
            Task tsk = new Task();
            tsk.Subject = (String) (TaskIdWithObject.get(str)).get('callType') + ' Callyzer Call Log';
            tsk.CallObject = (String) (TaskIdWithObject.get(str)).get('id');
            //This is the default...
            tsk.OwnerId = PhoneWithOpp.OwnerId;//PhoneWithLead.get('+'+(String) (TaskIdWithObject.get(str)).get('countryCode')+ ((String) (TaskIdWithObject.get(str)).get('number'))).OwnerId;
            tsk.whatId = PhoneWithOpp.Id;//PhoneWithLead.get('+'+(String) (TaskIdWithObject.get(str)).get('countryCode')+ ((String) (TaskIdWithObject.get(str)).get('number'))).Id;
            tsk.Status = 'Completed';
            tsk.Calling_Party__c = 'Callyzer';
            tsk.Call_Type__c = (String) (TaskIdWithObject.get(str)).get('callType');
            tsk.CallDurationInSeconds = Integer.valueof((TaskIdWithObject.get(str)).get('duration'));
            String formatted = (String) (TaskIdWithObject.get(str)).get('callTime');
            //tsk.Call_Start_Date_Time__c = Datetime.valueof(formatted);
            //tsk.Call_End_Date_Time__c = (Datetime.valueof(formatted)).addSeconds(Integer.valueof((TaskIdWithObject.get(str)).get('duration')));
            if(formatted.contains(',')){
                String formattedDate = formatted.replace(',', '');
                tsk.Call_Start_Date_Time__c = Datetime.valueof(formattedDate);
            }
            else {
                tsk.Call_Start_Date_Time__c = Datetime.valueof(formatted);
            }
            //tsk.Call_Start_Date_Time__c = Datetime.valueof(formatted);
            if(formatted.contains(',')){
                String formattedDate = formatted.replace(',', '');
                tsk.Call_End_Date_Time__c = (Datetime.valueof(formattedDate)).addSeconds(Integer.valueof((TaskIdWithObject.get(str)).get('duration')));
            }
            else {
                tsk.Call_End_Date_Time__c = (Datetime.valueof(formatted)).addSeconds(Integer.valueof((TaskIdWithObject.get(str)).get('duration')));
            }
            return tsk;
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('WebEngageWebhookHandler', 'CreateTaskForLead', e, null);
            return null;
        }
    }

}