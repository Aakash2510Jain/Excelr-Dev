public without sharing class ChatFormLWCcontroller{
    @auraenabled(cacheable = true)
    public static LeadOppWrapper getLead(String EmailOrPhone){
        LeadOppWrapper LdoppWrap = new LeadOppWrapper();

        try{
            list<lead> leadList = new list<lead>();
            List<Opportunity> OppoRtunityRec = new List<Opportunity>();
            String Phonestring = '%' + EmailOrPhone;

            if (EmailOrPhone != null){
                leadList = [Select id, firstName, LastName, Owner_Email__c, OwnerId, Owner.LastName, Owner.FirstName, Owner.Name, Email, Phone
                            from Lead
                            where (Email = :EmailOrPhone OR Phone LIKE:Phonestring OR Alternate_Email__c = :EmailOrPhone Or Alternate_Phone__c = :EmailOrPhone) AND isconverted = false
                            Order By CreatedDate Asc
                            LIMIT 1];
                if (!leadList.isEmpty() && leadList.size() > 0){
                    LdoppWrap.Leadrec = leadList;
                    LdoppWrap.OppRec = null;
                    //return LdoppWrap;
                }

            }
            if (leadList.isEmpty() || leadList.size() == 0){
                string stageClosedLost = constants.OPP_STAGENAME_CLOSE_LOST;
                OppoRtunityRec = [Select id, Name, Owner_Email__c, OwnerId, Owner.LastName, Owner.FirstName, Owner.Name, Email__c, Phone__c
                                  from Opportunity
                                  Where ((Email__c = :EmailOrPhone OR Phone__c LIKE:Phonestring OR Alternate_Email__c = :EmailOrPhone Or Alternate_Phone__c = :EmailOrPhone) AND StageName !=: stageClosedLost)
                                  Order By CreatedDate Asc
                                  LIMIT 1];
                if (!OppoRtunityRec.isEmpty() && OppoRtunityRec.size() > 0){
                    LdoppWrap.Leadrec = null;
                    LdoppWrap.OppRec = OppoRtunityRec;
                    
                }

            }

            System.debug('LdoppWrap ====> ' + LdoppWrap);
            System.debug('leadList ======> ' + leadList);
            return LdoppWrap;
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('ChatFormLWCcontroller', 'getLead', e, null);
            return null;
        }
    }

    public class LeadOppWrapper{
        @AuraEnabled
        public List<Lead> Leadrec{ get; set; }

        @AuraEnabled
        public List<Opportunity> OppRec{ get; set; }

    }

    
    @AuraEnabled
    public static string createLead(Lead Leadrec, String countrycode, string countrycodealternate,string mediumValue,string city){
        string message = '';
        List<Opportunity> OpportunityList = new List<Opportunity>();
        List<Account> accList = new List<Account>();
        try{
            System.debug('LeadTobeCreated =======> ' + Leadrec);
            System.debug('countrycode =======> ' + countrycode);
            System.debug('countrycodealternate =======> ' + countrycodealternate);

            if (countrycode != null && (Leadrec.Phone != null && Leadrec.Phone != '') ){
                Leadrec.Phone = countrycode + Leadrec.Phone;
            }

            if (countrycodealternate != null && Leadrec.Alternate_Phone__c != null && Leadrec.Alternate_Phone__c != ''){
                Leadrec.Alternate_Phone__c = countrycodealternate + Leadrec.Alternate_Phone__c;

            }
            if(mediumValue!=null){
                Leadrec.UTM_Medium__c=mediumValue;
            }
            if(city!=null){
                Leadrec.City__c=city;
            }                            
            Leadrec.Lead_Generation_Method__c = 'Chat Form';
            leadRec.Company = Leadrec.Lastname;
            
            insert Leadrec;
            if (leadRec.id != null){
                message = 'SUCCESS';
            }

        } catch (Exception e){
            System.debug(' the Error has occured due to =====> ' + e.getMessage());
            System.debug(' the Error has occured at  =====> ' + e.getLineNumber());
            HandleBusinessException.captureError('ChatFormLWCcontroller', 'createLead', e, null);
            message = 'FAIL';

        }



        return message;
    }

    @AuraEnabled
    public static String createTaskForVoice(Task TaskRecord,string assignto,Id RecordId){
        system.debug('assignto-->' + assignto);
        system.debug('RecordId-->' + RecordId);
        system.debug('');
        List<Lead> NotconvertedLead = new List<Lead>();
        List<Opportunity> OpportunityList = new List<Opportunity>();
        List<Task> tasklisttobeinserted = new List<Task>();
        Task taskRec = new Task();
        taskRec.Subject = TaskRecord.Subject;
        taskRec.OwnerId = assignto;
        taskRec.Priority = TaskRecord.Priority;
        taskRec.Status = TaskRecord.Status;
        taskRec.ActivityDate = TaskRecord.ActivityDate;
        taskRec.Description = TaskRecord.Description;
        taskRec.IsReminderSet = true;
        taskRec.ReminderDateTime = system.now().addMinutes(1);
        taskRec.Followup_Date_Time__c = TaskRecord.Followup_Date_Time__c.addminutes(-330);
        
        
        System.debug('object name>> '+ RecordId.getsobjecttype() );
        if (String.valueOf(RecordId.getsobjecttype()) == Constants.SOBJECT_LEAD) {
            NotconvertedLead = [Select Id from Lead Where Id =:RecordId and IsConverted = false];
            if (NotconvertedLead.size() >0 && !NotconvertedLead.isEmpty()) {
                taskRec.WhoId = NotconvertedLead[0].Id; 
                tasklisttobeinserted.add(taskRec);
            }
            
        }
        if (String.valueOf(RecordId.getsobjecttype()) == Constants.SOBJECT_OPPORTUNITY) {
            OpportunityList = [Select id, name, StageName, ownerId,accountId From Opportunity where Id =:RecordId];
            if (OpportunityList.size() >0 && !OpportunityList.isEmpty()) {
                taskRec.whatId = OpportunityList[0].accountId; 
                tasklisttobeinserted.add(taskRec);

                Task taskRecforOpp = new Task();
                taskRecforOpp.Subject = TaskRecord.Subject;
                taskRecforOpp.OwnerId = assignto;
                taskRecforOpp.Priority = TaskRecord.Priority;
                taskRecforOpp.Status = TaskRecord.Status;
                taskRecforOpp.ActivityDate = TaskRecord.ActivityDate;
                taskRecforOpp.Description = TaskRecord.Description;
                taskRecforOpp.Followup_Date_Time__c = TaskRecord.Followup_Date_Time__c.addminutes(-330);
                taskRecforOpp.whatId = OpportunityList[0].id;
                taskRecforOpp.IsReminderSet = true;
                taskRecforOpp.ReminderDateTime = system.now().addMinutes(1);
                tasklisttobeinserted.add(taskRecforOpp);
                
            }

            
        }

        //List<Lead> NotconvertedLead = [Select Id from Lead Where Id =:RecorId and IsConverted = false];
        //List<Lead> convertedLead = [Select Id , ConvertedAccountId,ConvertedContactId,ConvertedOpportunityId from Lead Where Id =:leadId and IsConverted = true];

        try{
            // Lead lRec = [select Id, OwnerId from Lead where id =''];
            // Task taskRec = new Task();
            /*if (NotconvertedLead.size() >0 && !NotconvertedLead.isEmpty()) {
                taskRec.WhoId = leadId; 
                tasklisttobeinserted.add(taskRec);
            }
            else if (convertedLead.size() >0 && !convertedLead.isEmpty()) {
                string accountId = convertedLead[0].ConvertedAccountId;
                String oppID = convertedLead[0].ConvertedOpportunityId;
                taskRec.whatId = accountId; 
                tasklisttobeinserted.add(taskRec);

                Task taskRecforOpp = new Task();
                taskRecforOpp.Subject = TaskRecord.Subject;
                taskRecforOpp.OwnerId = assignto;
                taskRecforOpp.Priority = TaskRecord.Priority;
                taskRecforOpp.Status = TaskRecord.Status;
                taskRecforOpp.ActivityDate = TaskRecord.ActivityDate;
                taskRecforOpp.Description = TaskRecord.Description;
                taskRecforOpp.Followup_Date_Time__c = TaskRecord.Followup_Date_Time__c;
                taskRecforOpp.whatId = oppID;
                taskRecforOpp.IsReminderSet = true;
                taskRecforOpp.ReminderDateTime = system.now().addMinutes(1);
                tasklisttobeinserted.add(taskRecforOpp);

                
}*/
            if (!tasklisttobeinserted.isEmpty()) {
                insert tasklisttobeinserted;
                //NotifyUser.processNotifications(tasklisttobeinserted);
            }
            return 'Success';

        } catch (Exception e){
            System.debug(' the Error has occured due to =====> ' + e.getMessage());
            System.debug(' the Error has occured at  =====> ' + e.getLineNumber());
            HandleBusinessException.captureError('ChatFormLWCcontroller', 'createTaskForVoice', e, null);
            return 'error';
        }
    }

    @AuraEnabled
    public static Application__c CreateApplication(string Course, string LeadId){
        System.debug('Course =====> ' + Course);
        //System.debug('Course =====> ' + userId);
        System.debug('LeadId =====> ' + LeadId);
        List<Lead> leadlist = new List<Lead>();
        try{
            if (LeadId != null){
                leadlist = [Select id, ownerId
                            from Lead
                            Where Id = :LeadId];
            }
            System.debug('leadlist ===> ' + leadlist);
            Application__c app = new Application__c();
            app.Course__c = course;
            app.Applied_Date_Time__c = system.now();
            app.Lead__c = LeadId;
            if (!leadlist.isEmpty()){
                app.OwnerId = leadlist[0].ownerId;

            }
            System.debug('app ====> ' + app);
            insert app;
            return app;

        } catch (Exception e){
            System.debug(' the Error has occured due to =====> ' + e.getMessage());
            System.debug(' the Error has occured at  =====> ' + e.getLineNumber());
            HandleBusinessException.captureError('ChatFormLWCcontroller', 'CreateApplication', e, null);
            throw new AuraHandledException(e.getMessage());
        }
    }

    @auraenabled(cacheable = true)
    public static List<Assignment_Group_Member__c> getMember(){
        List<Assignment_Group_Member__c> GmList = [SELECT Name, Group_Member__c, Group_Member__r.Name, Id
                                                   FROM Assignment_Group_Member__c];
        system.debug('GmList' + GmList);
        return GmList;
    }

    @auraenabled(cacheable = true)
    public static List<Application__c> getApplication(String lid){
        System.debug('lid ====> ' + lid);
        List<Application__c> AppList = [SELECT Course__c, Id, Name, LID__c, Applied_Date_Time__c, Lead__c
                                        FROM Application__c
                                        WHERE Lead__c = :lid];
        system.debug('AppList' + AppList);
        return AppList;
    }

    @auraenabled(cacheable = true)
    Public Static map<String, String> getPuckistOflead(){
        String objectName = 'Lead';
        String fieldName = 'Course__c';
        map<String, String> getLablePick = new map<String, String>();
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult r = s.getDescribe();
        Map<String, Schema.SObjectField> fields = r.fields.getMap();
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pickListVal : ple){
            System.debug(pickListVal.getLabel() + ' ' + pickListVal.getValue());
            getLablePick.put(pickListVal.getLabel(), pickListVal.getValue());
        }
        system.debug('getLablePick::' + getLablePick);
        return getLablePick;
    }

    @auraenabled(cacheable = true)
    Public Static map<String, String> getPickiststatusOfTask(){
        String objectName = 'Task';
        String fieldName = 'Status';
        map<String, String> getLablePick = new map<String, String>();
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult r = s.getDescribe();
        Map<String, Schema.SObjectField> fields = r.fields.getMap();
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pickListVal : ple){
            System.debug(pickListVal.getLabel() + ' ' + pickListVal.getValue());
            getLablePick.put(pickListVal.getLabel(), pickListVal.getValue());
        }
        system.debug('getLablePick::' + getLablePick);
        return getLablePick;
    }

    @auraenabled(cacheable = true)
    Public Static map<String, String> getPickistpriorityOfTask(){
        String objectName = 'Task';
        String fieldName = 'Priority';
        map<String, String> getLablePick = new map<String, String>();
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult r = s.getDescribe();
        Map<String, Schema.SObjectField> fields = r.fields.getMap();
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pickListVal : ple){
            System.debug(pickListVal.getLabel() + ' ' + pickListVal.getValue());
            getLablePick.put(pickListVal.getLabel(), pickListVal.getValue());
        }
        system.debug('getLablePick::' + getLablePick);
        return getLablePick;
    }

    @auraEnabled
    Public Static string EmailIsm(String LiD, String ownerMail){
        System.debug('LiD =========> ' + LiD);
        System.debug('ownerMail =======> ' + ownerMail);
        string message = '';
        try{
            List<Lead> leadList = new List<Lead>();
            leadList = [SELECT Name, Owner.email
                       FROM Lead
                       WHERE Owner.Email = :ownerMail AND Id = :LiD
                       limit 1];

            EmailTemplate et = [Select id, Name, Body, HtmlValue
                                from EmailTemplate
                                where name = 'Notify ISM'];

            if (leadList != null && leadList[0].Owner.email != null){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[]{ ownerMail };
                mail.setSubject('Lead assignment ');
                mail.setPlainTextBody('Lead has been assign to you..!');
                mail.setToAddresses(toAddresses);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ mail });
                message = 'Success';
            }
            return message;
        } catch (Exception e){
            System.debug(' the Error has occured due to =====> ' + e.getMessage());
            System.debug(' the Error has occured at  =====> ' + e.getLineNumber());
            HandleBusinessException.captureError('ChatFormLWCcontroller', 'EmailIsm', e, null);
            return null;
        }
        //return message;
    }

    @AuraEnabled(cacheable = true)
    public static List<Lead> QueryPastLeads(string ExcelRagentid){
        System.debug(' ExcelRagentid =========> ' + ExcelRagentid);
        try{
            List<Lead> PastLeadRecords = [SELECT Course__c, Email, ExcelR_Training_User__c, Name, OwnerId, Owner.Name, Phone, Status, Total_Calls__c, Total_Connected_Call__c //Product__r.Name,
                                          FROM Lead
                                          Where ExcelR_Training_User__c = :ExcelRagentid ANd isconverted = false
                                          Order by createdDate Desc];
            System.debug('PastLeadRecords ======> ' + PastLeadRecords);

            return PastLeadRecords;
        } catch (Exception e){
            System.debug(' the Error has occured due to =====> ' + e.getMessage());
            System.debug(' the Error has occured at  =====> ' + e.getLineNumber());
            HandleBusinessException.captureError('ChatFormLWCcontroller', 'QueryPastLeads', e, null);
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(Cacheable = True)
    Public Static List<City_State_Country__c> FetchStateCounty(){
        List<City_State_Country__c> cityStateCountry = [Select City__c, Country__c, State__c
                                                        From City_State_Country__c];

        return cityStateCountry;
    }

    @AuraEnabled(Cacheable = True)
    Public Static List<City_State_Country__c> Fetchcities(){
        List<City_State_Country__c> cityValues = [Select City__c, Order_Number__c
                                                  From City_State_Country__c
                                                  ORDER BY Order_Number__c ASC];

        return cityValues;
    }

    @AuraEnabled(Cacheable = True)
    Public Static List<Country__c> FetchCountryRec(){
        List<Country__c> countryRecordList = [Select name, Id
                                              From Country__c
                                              ORDER BY Name ASC];

        return countryRecordList;
    }

    @AuraEnabled(Cacheable = True)
    Public Static List<State__c> FetchStateRec(string countryid){
        List<State__c> statesList = [Select name, Id
                                     From State__c
                                     where Country__c = :countryid
                                     ORDER BY Name ASC];

        return statesList;
    }

    public PageReference checkExistingHashKeyMatching(){

        //String LoginPageBaseurl = 'https://whitemart--partial.sandbox.my.salesforce-sites.com/Abasoft_LoginPage';
        //String CustomerDetailPageBaseUrl = 'https://whitemart--partial.sandbox.my.salesforce-sites.com/CusomerDetailAURA_IN_VFPage';
        try{
            String LoginPageBaseurl = System.Label.LoginPageBaseurl;
            String ExistingHashcode = '';
            string FinalPageToRedirect = '';
            Boolean redirecttoLoginPage;

            String LoginHashcode = Apexpages.currentPage().getparameters().get('hascode'); //IsReloading
            String LGEMemberRecordid = Apexpages.currentPage().getparameters().get('id');
            String Reloading = Apexpages.currentPage().getparameters().get('IsReloading');
            string headerdata = ApexPages.currentPage().getHeaders().get('Host');
            string urlvalue = Apexpages.currentPage().getUrl();

            List<ExcelR_Training_User__c> ExcelRTrainUser = [SELECT Departments__c, Email__c, First_Name__c, HashCode__c, Id, Last_Name__c, Name, Password__c, Username__c
                                                             FROM ExcelR_Training_User__c
                                                             WHERE id = :LGEMemberRecordid
                                                             LIMIT 1]; //


            List<String> DepartmentArr = ExcelRTrainUser[0].Departments__c.split(';');

            System.debug('hashCode ======> ' + Apexpages.currentPage().getparameters().get('hascode'));
            System.debug('Reloading ====> ' + Reloading);

            Cookie userHashCodeCookie = ApexPages.currentPage().getCookies().get('userHashCodeCookie');
            System.debug('userHashCodeCookie ==> ' + userHashCodeCookie);

            if (userHashCodeCookie != null && LoginHashcode != null){
                ExistingHashcode = String.valueOf(userHashCodeCookie.getValue());
                if (LoginHashcode == ExistingHashcode && ExcelRTrainUser[0].HashCode__c == ExistingHashcode){
                    if (Reloading == '' || Reloading == null){
                        if (urlvalue.contains('apex')){
                            urlvalue = urlvalue.replace('apex', 'Loginpage');
                        }
                        System.debug('System.Label.siteUrlForm ====> ' + System.Label.siteUrlForm);

                        FinalPageToRedirect = System.Label.siteUrlForm + urlvalue + '&IsReloading=true';
                        // FinalPageToRedirect = LoginHashcode+ '?id='+ExistingHashcode +'&IsReloading=true';
                        System.debug('FinalPageToRedirect ====> ' + FinalPageToRedirect);


                        PageReference LGEMemberFormPage = new PageReference(FinalPageToRedirect);
                        LGEMemberFormPage.setRedirect(true);
                        return LGEMemberFormPage;
                    }

                }
            } else if (userHashCodeCookie == null && LoginHashcode != null){
                System.debug('Redirect to Login Page');
                FinalPageToRedirect = LoginPageBaseurl;
                System.debug('FinalPageToRedirect ====> ' + FinalPageToRedirect);

                PageReference LoginPage = new PageReference(FinalPageToRedirect);
                LoginPage.setRedirect(true);
                return LoginPage;
                /*FinalPageToRedirect = 'https://' + headerdata + urlvalue + '&IsReloading=true';
                 //FinalPageToRedirect = LoginPageBaseurl + '?id='+ LoginHashcode +'&hascode=' +LoginHashcode ;
                 System.debug('FinalPageToRedirect =====> ' + FinalPageToRedirect);
                 PageReference CustomerDetailPage = new PageReference(FinalPageToRedirect);
                 CustomerDetailPage.setRedirect(true);
                 return CustomerDetailPage;*/
            }
            return null;
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('ChatFormLWCcontroller', 'checkExistingHashKeyMatching', e, null);
            return null;
        }
    }

    @AuraEnabled
    public static ResponseWrapper LogoutAgent(String AgrecId, String AgentHashCode){
        ResponseWrapper reswrap = new ResponseWrapper();
        try{
            System.debug('AgrecId ===> ' + AgrecId);
            System.debug('AgentHashCode ===> ' + AgentHashCode);

            
            String LoginPageBaseurl = System.Label.LoginPageBaseurl;
            string message = '';

            // string headerdata = ApexPages.currentPage().getHeaders().get('Host');
            // System.debug('headerdata ====> ' + headerdata);

            // string urlvalue = Apexpages.currentPage().getUrl();
            // System.debug('urlvalue =====> ' + urlvalue);

            if (AgrecId != null && AgentHashCode != null){
                List<ExcelR_Training_User__c> ExcelRTrainUser = [SELECT Departments__c, Email__c, First_Name__c, HashCode__c, Id, Last_Name__c, Name, Password__c, Username__c
                                                                 FROM ExcelR_Training_User__c
                                                                 WHERE id = :AgrecId AND HashCode__c = :AgentHashCode
                                                                 LIMIT 1];
                if (!ExcelRTrainUser.isEmpty() && ExcelRTrainUser.size() > 0){
                    ExcelRTrainUser[0].HashCode__c = '';
                    update ExcelRTrainUser[0];
                    message = LoginPageBaseurl;
                    reswrap.Message = LoginPageBaseurl;
                    reswrap.HashcodeName = 'userHashCodeCookie';
                    // Cookie userHashCodeCookie = ApexPages.currentPage().getCookies().get('userHashCodeCookie');
                    // System.debug('userHashCodeCookie ===> ' + userHashCodeCookie);

                    //Cookie ExistinguserHashCodeCookie = ApexPages.currentPage().getCookies().get('userHashCodeCookie');
                    /*if (ExistinguserHashCodeCookie != null) {
                        
                        String ExistingHashcode = String.valueOf(ExistinguserHashCodeCookie.getValue());
                        Cookie userHashCodeCookie = new Cookie('userHashCodeCookie', ExistingHashcode, null, 0, true);
                        ApexPages.currentPage().setCookies(new Cookie[]{ userHashCodeCookie });
                    }*/
                }

            }
            return reswrap;

        } catch (Exception e){
            //throw new AuraHandledException(e.getMessage());
            System.debug('The error has coccured due to =====> ' + e.getMessage());
            System.debug('The error has coccured due to =====> ' + e.getLineNumber());
            reswrap.Message = 'Error';
            reswrap.HashcodeName = 'userHashCodeCookie';
            return reswrap;
        }
    }
    
    public class ResponseWrapper {
        @AuraEnabled public String HashcodeName;
        @AuraEnabled public String Message;
    }

}