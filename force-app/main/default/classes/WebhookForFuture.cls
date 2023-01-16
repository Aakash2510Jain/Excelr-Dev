public without sharing class WebhookForFuture implements Queueable{
    

    private String callLogString;

    public WebhookForFuture(String callLogString) {
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

        // ------------------------------------ To Insert Task ----------------------------------------
        List<Task> TaskListTobeInserted = new List<Task>();

        if (!String.isEmpty(callLogString)){
            // Webhookwrapper RealTimeCallHistory = ( Webhookwrapper )JSON.deserialize(body, Webhookwrapper.class);
            // System.debug('RealTimeCallHistory ===> ' + RealTimeCallHistory);

            Map<string, Object> m = (Map<string, Object>)JSON.deserializeUntyped(callLogString);
            system.debug('bodymap ===> ' + m);

            //for (OBject obj : bodyMap){
                //Map<string, Object> m = (Map<string, Object>)obj;
                String EmployeeName = String.valueof(m.get('employeeName'));
                List<Object> logsList = (List<Object>)m.get('logs');
                EmployeePhones.add((String) m.get('employeeNumber'));
                String EmployeePhoneNumber  = (String) m.get('employeeNumber');

                List<Callyzer_Sales_User__c> CallyzerSalesUser = [SELECT callyzerId__c,countryCode__c,deviceName__c,employeeCode__c,Id,mobile__c,Name,OwnerId 
                                            FROM Callyzer_Sales_User__c 
                                            Where mobile__c IN:EmployeePhones ];
                                            System.debug('CallyzerSalesUser ===> ' + CallyzerSalesUser);

                for (Object logObj : logsList){
                    Map<string, Object> logmap = (Map<string, Object>)logObj;
                    System.debug('logmap =====> ' + logmap);
                    CustomerPhones.add('+91' + ((String) logmap.get('number')).right(10));
                    CustomerPhonesForContact.add(((String) logmap.get('number')).right(10));
                    TaskIds.add((string) logmap.get('id'));
                    CustomerPhoneWithObject.put((string) logmap.get('number'), logmap);
                    TaskIdWithObject.put((string) logmap.get('id'), logmap);
                    TaskIdwithCutomerPone.put((string) logmap.get('id'), (string) logmap.get('number'));
                }
            //}

            System.debug('CustomerPhones ====> ' + CustomerPhones);
            if (!CustomerPhones.isEmpty()){
                System.debug('I am finding existing Lead');
                list<Lead> ExistingLeadwithPhone = [Select id, Phone, ownerId
                                                    From Lead
                                                    Where Phone IN:CustomerPhones And isConverted = false];
                System.debug('ExistingLeadwithPhone ====> ' + ExistingLeadwithPhone);


                if (ExistingLeadwithPhone.size() > 0){
                    for (Lead ld : ExistingLeadwithPhone){
                        PhoneWithLead.put(ld.Phone, ld);
                    }
                }
                System.debug('PhoneWithLead =====> ' + PhoneWithLead);
                LIst<Contact> ExistingContactwithPhone = [Select id, Phone, ownerId
                                                          From Contact
                                                          Where Phone IN:CustomerPhonesForContact];

                if (ExistingContactwithPhone.size() > 0){
                    for (Contact con : ExistingContactwithPhone){
                        PhoneWithContact.put(con.Phone, con);
                    }

                    if (CustomerPhones.size() > 0){
                        for (string phoneStr : CustomerPhones){
                            if (!PhoneWithContact.containsKey(phoneStr.right(10)) && !PhoneWithLead.containsKey(phoneStr)){
                                PhoneStringNotExistintheSystem.add(phoneStr);
                            }
                        }
                    }
                }
                System.debug('PhoneStringNotExistintheSystem =====> ' + PhoneStringNotExistintheSystem);
                System.debug('PhoneWithContact =====> ' + PhoneWithContact);
            }
            System.debug('TaskIds ====> ' + TaskIds);
            if (!TaskIds.isEmpty()){
                ExistingtaskList = [Select id, WhoId, ownerId
                                    From task
                                    where CallObject IN:TaskIds];

                if (!ExistingtaskList.isEmpty()){
                    for (task tas : ExistingtaskList){
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


            System.debug('TaskIdWithObject =====> ' + TaskIdWithObject);
            System.debug('TaskIdWithObject =====> ' + TaskIdWithObject.keySet());

            for (String str : TaskIdWithObject.keyset()){
                if (!PhoneWithLead.isEmpty()){
                    System.debug('(String) (TaskIdWithObject.get(str)).get(number)).right(10) ==== >' + ((String) (TaskIdWithObject.get(str)).get('number')));
                    if (PhoneWithLead.containsKey('+91' + ((String) (TaskIdWithObject.get(str)).get('number')).right(10))){
                        //&& !PhoneWithContact.containsKey(((String) (TaskIdWithObject.get(str)).get('number')).right(10))
                        System.debug('I am inside to create task for Lead');
                        if (!TaskCallObjectIdWithTask.isEmpty() && !TaskCallObjectIdWithTask.containsKey(str)){
                            Task tsk = CreateTaskForLead(TaskIdWithObject, str, PhoneWithLead);
                            if (CallyzerSalesUser.size() >0) {
                                tsk.Callyzer_Sales_User__c = CallyzerSalesUser[0].id;
                            }

                            TaskListTobeInserted.add(tsk);
                        } else{
                            Task tsk = CreateTaskForLead(TaskIdWithObject, str, PhoneWithLead);
                            if (CallyzerSalesUser.size() >0) {
                                tsk.Callyzer_Sales_User__c = CallyzerSalesUser[0].id;
                            }
                            TaskListTobeInserted.add(tsk);
                        }

                        //insert tsk;
                    }
                }
                if (!PhoneWithContact.isEmpty()){
                    System.debug('(String) (TaskIdWithObject.get(str)).get(number)).right(10) ==== >' + ((String) (TaskIdWithObject.get(str)).get('number')));
                    System.debug('phone exist in Lead or not ====> ' + PhoneWithLead.containsKey('+91' + ((String) (TaskIdWithObject.get(str)).get('number')).right(10)));
                    if (!PhoneWithLead.containsKey('+91' + ((String) (TaskIdWithObject.get(str)).get('number')).right(10)) && PhoneWithContact.containsKey(((String) (TaskIdWithObject.get(str)).get('number')).right(10))){
                        //!PhoneWithLead.containsKey(((String) (TaskIdWithObject.get(str)).get('number')).right(10)) &&
                        System.debug('I am inside to create task for Contact');
                        if (!TaskCallObjectIdWithTask.isEmpty() && !TaskCallObjectIdWithTask.containsKey(str)){
                            Task tsk = CreatetaskForContact(TaskIdWithObject, str, PhoneWithContact);
                            if (CallyzerSalesUser.size() >0) {
                                tsk.Callyzer_Sales_User__c = CallyzerSalesUser[0].id;
                            }
                            TaskListTobeInserted.add(tsk);
                        } else{
                            Task tsk = CreatetaskForContact(TaskIdWithObject, str, PhoneWithContact);
                            if (CallyzerSalesUser.size() >0) {
                                tsk.Callyzer_Sales_User__c = CallyzerSalesUser[0].id;
                            }
                            TaskListTobeInserted.add(tsk);

                        }
                    }
                }
                if (PhoneStringNotExistintheSystem.size() > 0){
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

                }
            }

            System.debug('TaskListTobeInserted =====> ' + TaskListTobeInserted);
            if (!TaskListTobeInserted.isEmpty()){
                Database.SaveResult[] srList = Database.insert (TaskListTobeInserted, false);

                if (!srList.isEmpty()){
                    for (Database.SaveResult sr : srList){
                        if (sr.isSuccess()){
                            // Operation was successful, so get the ID of the record that was processed
                            System.debug('Successfully inserted account. Account ID: ' + sr.getId());
                            Utility.API_ErrorORSuccess(null, 'SUCCESS', null, sr.getId(), 'WebhookForFuture', 'uploadcalllogs');
                        } else{
                            // Operation failed, so get all errors
                            for (Database.Error err : sr.getErrors()){
                                System.debug('The following error has occurred.');
                                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                System.debug('Account fields that affected this error: ' + err.getFields());
                                Utility.API_ErrorORSuccess(err.getFields(), err.getMessage(), Integer.valueof(err.getStatusCode()), null, 'WebhookForFuture', 'uploadcalllogs');
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

    Public static Task CreateTaskForLead(map<String, Map<string, Object>> TaskIdWithObject, String str, Map<String, Lead> PhoneWithLead){
        Task tsk = new Task();
        tsk.Subject = 'OUTBOUND CALLLOG';
        tsk.CallObject = (String) (TaskIdWithObject.get(str)).get('id');
        //This is the default...
        tsk.OwnerId = PhoneWithLead.get('+91' + ((String) (TaskIdWithObject.get(str)).get('number')).right(10)).OwnerId;
        tsk.whoid = PhoneWithLead.get('+91' + ((String) (TaskIdWithObject.get(str)).get('number')).right(10)).Id;
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
    }

    Public static Task CreatetaskForContact(map<String, Map<string, Object>> TaskIdWithObject, String str, Map<String, Contact> PhoneWithContact){
        Task tsk = new Task();
        tsk.Subject = 'OUTBOUND CALLLOG';
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
    }

    Public Static task createLeadAndtask(String str, map<String, Map<string, Object>> TaskIdWithObject){
        Lead ld = new Lead();
        ld.lastname = str.right(10);
        ld.company = 'Unknown';
        ld.Phone = '+91'+ str.right(10);
        insert ld;

        Task tsk = new Task();
        tsk.Subject = 'OUTBOUND CALLLOG';
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
    }

}