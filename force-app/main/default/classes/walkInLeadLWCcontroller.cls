public without sharing class walkInLeadLWCcontroller{
    @auraenabled(cacheable = true)
    public static list<lead> getLead(String EmailOrPhone){
        list<lead> leadList = new list<lead>();
        String Phonestring = '%'+ EmailOrPhone;

        if (EmailOrPhone != null) {
            leadList = [Select id, firstName, LastName, Owner_Email__c, Email, Phone
                        from Lead
                        where Email = :EmailOrPhone OR Phone LIKE:Phonestring Order By CreatedDate Asc LIMIT 1];
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
            if ( !existingTrainingUser.isEmpty() ){
                leadRec.ExcelR_Training_User__c = existingTrainingUser[0].id;
            }
            leadRec.Company = '--';
            leadRec.Status = 'Open';
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

}