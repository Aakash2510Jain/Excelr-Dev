public without sharing class walkInLeadLWCcontroller{
    @auraenabled(cacheable = true)
    public static list<lead> getLead(String EmailOrPhone){
        list<lead> leadList = new list<lead>();
        String Phonestring = '%'+ EmailOrPhone;

        System.debug('EmailOrPhone ====> ' + EmailOrPhone);
        if (EmailOrPhone != null) {
            leadList = [Select id, firstName, LastName, Owner_Email__c, Email, Phone
                        from Lead
                        where Email = :EmailOrPhone OR Phone LIKE:Phonestring  Order By CreatedDate Asc LIMIT 1];
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
    }

    @auraenabled
    public static lead createLead(String firstname, string Lastname, string email, string phone, string ownerId, string agmId, string Course, string userId, string agentid){
        System.debug('userId ====> ' + userId);
        System.debug('agentid ====> ' + agentid);
        lead leadRec = new lead();
        list<ExcelR_Training_User__c> existingTrainingUser = new list<ExcelR_Training_User__c>();
        try{

            if ( agentid != null ){
                existingTrainingUser = [SELECT Email__c, First_Name__c, HashCode__c, Id, Last_Name__c, Name, Password__c, Username__c
                                        FROM ExcelR_Training_User__c
                                        Where id = :agentid];
            }

            system.debug(firstname + ' : ' + Lastname + ' : ' + email + ' : ' + phone + ' : ' + Lastname + agmId);
            leadRec.FirstName = firstname;
            leadRec.LastName = Lastname;
            leadRec.Email = email;
            leadRec.Phone = phone;
            leadRec.OwnerId = userId;
            leadRec.ISM__c = agmId;
            leadRec.Course__c = Course;
            leadRec.City__c='NA';
            if ( !existingTrainingUser.isEmpty() ){
                leadRec.ExcelR_Training_User__c = existingTrainingUser[0].id;
            }
            leadRec.Company = '--';
            system.debug('leadRec===========================' + leadRec);
            insert leadRec;
            System.debug('lead rec Id =====> ' + leadRec.Id);
            return leadRec;
        }
        catch ( Exception ex ){
            system.debug('Error-->' + ex.getMessage());
            system.debug('Error@@-->' + ex.getLineNumber());
            //return null;
        }
        return leadRec;
    }

    @AuraEnabled
    public static Application__c CreateApplication(string Course, string LeadId ){
        System.debug('Course =====> ' + Course);
        //System.debug('Course =====> ' + userId);
        System.debug('Course =====> ' + LeadId);
        List<Lead> leadlist = new List<Lead>();
        try {
            if (LeadId != null) {
                leadlist = [Select id, ownerId from Lead Where Id =: LeadId];
            }
            Application__c app = new Application__c();
            app.Course__c = course;
            app.Applied_Date_Time__c = system.now();
            app.Lead__c = LeadId;
            if (!leadlist.isEmpty()) {
                app.OwnerId = leadlist[0].ownerId;
                
            }
            
            insert app;
            return app;

        } catch (Exception e) {
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
        System.debug('lid ====> ' +lid);
        List<Application__c> AppList = [SELECT Course__c, Id, Name,LID__c,Applied_Date_Time__c, Lead__c
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
        for ( Schema.PicklistEntry pickListVal : ple ){
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
                                where name ='Notify ISM'];
            
            if ( leadRec != null && leadRec.Owner.email != null ){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(  );
                String[] toAddresses = new String[]{ ownerMail };
                mail.setSubject('Lead assignment ');
                mail.setPlainTextBody('Lead has been assign to you..!');
                mail.setToAddresses(toAddresses);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ mail });
                message = 'Success';
            }
            return message;
        }
        catch ( Exception e ){
            System.debug('the error has occured due to =====> ' + e.getMessage());
            System.debug('the error has occured at line number ======> ' + e.getLineNumber());
            return null;
        }
        //return message;
    }


    @AuraEnabled(cacheable = true)
    public static List<Lead> QueryPastLeads(string ExcelRagentid ){
        System.debug(' ExcelRagentid =========> ' + ExcelRagentid);
        try {
            List<Lead> PastLeadRecords = [SELECT Course__c,Email,ExcelR_Training_User__c,Name,OwnerId,Owner.Name,Phone,Product__c,Product__r.Name,Status,Total_Calls__c,Total_Connected_Call__c 
                                            FROM Lead 
                                            Where ExcelR_Training_User__c =: ExcelRagentid ANd isconverted = false Order by createdDate Desc ];
            System.debug('PastLeadRecords ======> ' + PastLeadRecords);

             return PastLeadRecords;                           
        } catch (Exception e) {

            throw new AuraHandledException(e.getMessage());
        }
    }

}