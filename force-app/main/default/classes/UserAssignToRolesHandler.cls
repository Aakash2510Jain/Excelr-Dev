public without sharing class UserAssignToRolesHandler { 
    @AuraEnabled
    public static List<User> fetchUser() { 
        try{ 
           User loggedInInfoId = [SELECT Id FROM User WHERE Id = : UserInfo.getUserId()];
                    List<User> userlst = [Select Id,FirstName,LastName,Username,ManagerId,Alias,SenderEmail,ProfileId,EmailEncodingKey,LanguageLocaleKey,LocaleSidKey,TimeZoneSidKey,Max_Lead_Per_Day__c,Max_Lead_Per_Month__c,UserRoleId from User where ManagerId!= Null AND ManagerId =: UserInfo.getUserId() LIMIT 10];
             system.debug('userlst=='+userlst);
            for(User user: userlst){
                   Id UserIds = (Id)user.get('ManagerId');
                system.debug('Id is=='+(Id)user.get('ManagerId'));
                }
               Set<Id> UserIds = new Set<Id>(); 
 List<User> userList = [Select Id,FirstName,LastName,Username,ManagerId,Alias,SenderEmail,ProfileId,EmailEncodingKey,LanguageLocaleKey,LocaleSidKey,TimeZoneSidKey,Max_Lead_Per_Day__c,Max_Lead_Per_Month__c,UserRoleId from User where ManagerId!= Null AND ManagerId IN: UserIds LIMIT 10];
             system.debug('userList=='+userList);           
             return userlst;
        }catch(Exception e){ 
            system.debug('Error' +e.getMessage()+' Line Number' +e.getLineNumber());
            HandleBusinessException.captureError('UserAssignToRolesHandler', 'fetchUser', e , null);
        }
        return null;
    }
  
     @AuraEnabled
   public static User UpdateUser(string userId,integer maxleadperday,integer maxleadpermonth) { 
         try{
      //List<User> userlst = [Select Id,FirstName,LastName,Username,ManagerId,Alias,SenderEmail,ProfileId,EmailEncodingKey,LanguageLocaleKey,LocaleSidKey,TimeZoneSidKey,Max_Lead_Per_Day__c,Max_Lead_Per_Month__c,UserRoleId from User where Id=: userId];
      //system.debug('userlst=='+userlst); 
       User user = new User(); 
       user.Id = userId;
       user.Max_Lead_Per_Day__c = maxleadperday;
       user.Max_Lead_Per_Month__c = maxleadpermonth;   
      // userlst.add(user);
       update user;
       return user;
              }catch(Exception e){ 
            system.debug('Error' +e.getMessage()+' Line Number' +e.getLineNumber());
            HandleBusinessException.captureError('UserAssignToRolesHandler', 'fetchUser', e , null);
        }
       return null;
   }
   
}