public without sharing class GenericLeadLWCcontroller{
    @auraenabled(cacheable = true)
    public static list<lead> getLead(String EmailOrPhone){
        try{
            list<lead> leadList = new list<lead>();
            String Phonestring = '%' + EmailOrPhone;

            if (EmailOrPhone != null){
                leadList = [Select id, firstName, LastName, Owner_Email__c, OwnerId, Owner.LastName, Owner.FirstName, Owner.Name, Email, Phone
                            from Lead
                            where Email = :EmailOrPhone OR Phone LIKE:Phonestring OR Alternate_Email__c = :EmailOrPhone Or Alternate_Phone__c = :EmailOrPhone
                            Order By CreatedDate Asc
                            LIMIT 1];
            }
            System.debug('leadList ======> ' + leadList);
            // if ( EmailOrPhone.contains('@') ){
            //     leadList = [Select id, firstName, LastName, Owner_Email__c, Email, Phone
            //                 from Lead
            //                 where Email = :EmailOrPhone];
            // }
            // else{
            //     leadList = [Select id, firstName, LastName, Owner_Email__c, Email, Phone
            //                 from Lead
            //                 where Phone = :EmailOrPhone];
            // }
            // System.debug('leadList ====> ' + leadList);
            // system.debug('leadList::' + leadList);
            return leadList;
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('GenericLeadLWCcontroller', 'getLead', e, null);
            return null;
        }
    }

    // @auraenabled
    // public static String createLead(string Lastname, string email, string phone, string Course, string agentid, string city, string state, string country, string source, string medium, string VisitorId, string Transcript, string leadGenPath, string comments, string pageurllanding, string countrycode, string AlternateMobile, String AlternateEmail){
    //     // System.debug('userId ====> ' + userId);

    //     //String firstname,
    //     System.debug('agentid ====> ' + agentid);
    //     string message = '';
    //     lead leadRec = new lead();
    //     list<ExcelR_Training_User__c> existingTrainingUser = new list<ExcelR_Training_User__c>();
    //     try{

    //         if (agentid != null){
    //             existingTrainingUser = [SELECT Email__c, First_Name__c, HashCode__c, Id, Last_Name__c, Name, Password__c, Username__c
    //                                     FROM ExcelR_Training_User__c
    //                                     Where id = :agentid];
    //         }

    //         system.debug(Lastname + ' : ' + email + ' : ' + phone + ' : ' + Lastname);
    //         //leadRec.FirstName = firstname;
    //         leadRec.LastName = Lastname;
    //         leadRec.Email = email;
    //         leadRec.Alternate_Email__c = AlternateEmail;
    //         leadRec.Phone = countrycode + phone;
    //         leadRec.Alternate_Phone__c = countrycode + AlternateMobile;
    //         leadRec.Enter_UTM_Link__c = pageurllanding;
    //         leadRec.Course__c = Course;
    //         leadRec.City = city;
    //         leadRec.State = state;
    //         leadRec.Country = country;
    //         leadRec.LeadSource = source;
    //         leadRec.UTM_Medium__c = medium;
    //         //leadRec.LGE__c=LGE;
    //         leadRec.Visitor_ID__c = VisitorId;
    //         leadRec.Transcript__c = Transcript;
    //         leadRec.Lead_Gen_Path__c = leadGenPath;
    //         leadRec.Lead_Generation_Method__c = 'Generic Form';
    //         leadRec.Comments__c = comments;


    //         //leadRec.Landing_Page_URL__c=LandingPageURL;
    //         if (!existingTrainingUser.isEmpty()){
    //             leadRec.ExcelR_Training_User__c = existingTrainingUser[0].id;
    //         }
    //         leadRec.Company = Lastname;
    //         system.debug('leadRec===========================' + leadRec);
    //         insert leadRec;
    //         System.debug('lead rec Id =====> ' + leadRec.Id);

    //         if (leadRec.id != null){
    //             message = 'SUCCESS';
    //         }
    //         //return message;
    //     } catch (Exception e){
    //         System.debug(' the Error has occured due to =====> ' + e.getMessage());
    //         System.debug(' the Error has occured at  =====> ' + e.getLineNumber());
    //         HandleBusinessException.captureError('GenericLeadLWCcontroller', 'createLead', e, null);
    //         message = 'FAIL';
    //         //return null;
    //     }
    //     return message;
    // }

    @AuraEnabled
    public static string createLead(Lead Leadrec, String countrycode, string countrycodealternate,string mediumValue,string city){
        string message = '';
        try{
            System.debug('LeadTobeCreated =======> ' + Leadrec);
            System.debug('countrycode =======> ' + countrycode);
            System.debug('countrycodealternate =======> ' + countrycodealternate);

            if (countrycode != null){
                Leadrec.Phone = countrycode + Leadrec.Phone;
            }

            if (countrycodealternate != null){
                Leadrec.Alternate_Phone__c = countrycodealternate + Leadrec.Alternate_Phone__c;

            }
            if(mediumValue!=null){
                Leadrec.UTM_Medium__c=mediumValue;
            }
            if(city!=null){
                Leadrec.City__c=city;
            }
            Leadrec.Lead_Generation_Method__c = 'Generic Form';
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
    public static String createTaskForVoice(Task TaskRecord,string assignto,string leadId){
        system.debug('assignto-->' + assignto);
        system.debug('leadId-->' + leadId);
        system.debug('');
        Task taskRec = new Task();
        try{
            // Lead lRec = [select Id, OwnerId from Lead where id =''];
            // Task taskRec = new Task();
            taskRec.Subject = TaskRecord.Subject;
            taskRec.OwnerId = assignto;
            taskRec.WhoId = leadId;      // lead---Name
            taskRec.Priority = TaskRecord.Priority;
            taskRec.Status = TaskRecord.Status;
            taskRec.ActivityDate = TaskRecord.ActivityDate;
            taskRec.Description = TaskRecord.Description;
            taskRec.Followup_Date_Time__c = TaskRecord.Followup_Date_Time__c;
            insert taskRec;
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
        System.debug('Course =====> ' + LeadId);
        List<Lead> leadlist = new List<Lead>();
        try{
            if (LeadId != null){
                leadlist = [Select id, ownerId
                            from Lead
                            Where Id = :LeadId];
            }
            Application__c app = new Application__c();
            app.Course__c = course;
            app.Applied_Date_Time__c = system.now();
            app.Lead__c = LeadId;
            if (!leadlist.isEmpty()){
                app.OwnerId = leadlist[0].ownerId;

            }

            insert app;
            return app;

        } catch (Exception e){
            System.debug(' the Error has occured due to =====> ' + e.getMessage());
            System.debug(' the Error has occured at  =====> ' + e.getLineNumber());
            HandleBusinessException.captureError('GenericLeadLWCcontroller', 'CreateApplication', e, null);
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
            Lead leadRec = new Lead();
            leadRec = [SELECT Name, Owner.email
                       FROM Lead
                       WHERE Owner.Email = :ownerMail AND Id = :LiD
                       limit 1];

            EmailTemplate et = [Select id, Name, Body, HtmlValue
                                from EmailTemplate
                                where name = 'Notify ISM'];

            if (leadRec != null && leadRec.Owner.email != null){
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
            System.debug('the error has occured due to =====> ' + e.getMessage());
            System.debug('the error has occured at line number ======> ' + e.getLineNumber());
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
            HandleBusinessException.captureError('GenericLeadLWCcontroller', 'QueryPastLeads', e, null);
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
    public static List<Country_CountryCode__c> fetchCountryAndCountryCode(){
        try{
            List<Country_CountryCode__c> CCodeList = [SELECT CountryCode__c, Id, Name
                                                      FROM Country_CountryCode__c];

            return CCodeList;
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
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


            List<String> DepartmentArr = new List<String>();
            if (!ExcelRTrainUser.isEmpty()){
                DepartmentArr = ExcelRTrainUser[0].Departments__c.split(';');
            }
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
                        FinalPageToRedirect = 'https://' + headerdata + urlvalue + '&IsReloading=true';
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
            HandleBusinessException.captureError('GenericLeadLWCcontroller', 'checkExistingHashKeyMatching', e, null);
            return null;
        }
    }

}