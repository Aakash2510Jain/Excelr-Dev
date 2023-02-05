public class ModifyMaxLeads 
{
    @AuraEnabled
    public Static List<User> getUser()
    {
      try{   
        Id userId = UserInfo.getUserId();
        System.debug('UserId'+userId);
        User userRecord = [select Id,Max_Lead_Per_Day__c,Max_Lead_Per_Month__c,UserRoleId from User where Id =:userId];
         System.debug('roleId'+userRecord);
        
      //  set<Id> allSubRoleIds = new set<Id>();
      //  allSubRoleIds.add(userRecord.UserRoleId);
        Set<Id> allSubRoleIds = getAllSubRoleIds(New Set<ID>{userRecord.UserRoleId});
         System.debug('allSubRoleIds'+allSubRoleIds);
         Map<Id, User> users = new Map<Id, User>([SELECT Id,Username, Name,Max_Lead_Per_Day__c,Max_Lead_Per_Month__c From User Where UserRoleId IN :allSubRoleIds]); 
        System.debug('Usersssss'+users);
       // ModifyMaxLeads.getAllSubRoleIds(allSubRoleIds);
        return users.values() ;
    } catch (Exception e){
        system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
      HandleBusinessException.captureError('ModifyMaxLeads', 'getUser', e , null);
       return null;
    }
}
    
    public Static Set<ID> getAllSubRoleIds(set<Id> roleIds)
    { 
        try{
         Set<ID> currentRoleIds = new Set<ID>();
         
        //Get all of the roles below the passed roles
        for(UserRole userRole :[SELECT Id from UserRole Where ParentRoleId =:roleIds AND ParentRoleID != null])
        {
            System.debug('userRole'+userRole);
            currentRoleIds.add(userRole.Id);
        }
        System.debug('currentRoleIds'+currentRoleIds);
        return currentRoleIds;
    } catch (Exception e){
        system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
      HandleBusinessException.captureError('ModifyMaxLeads', 'getAllSubRoleIds', e , null);
       return null;
    }
}

    @AuraEnabled
    public static boolean updaterecord(List<User> userList){
        try {
            System.debug('userList====='+userList);
             List<User> uList = [select Id,Username, Name,Max_Lead_Per_Day__c,Max_Lead_Per_Month__c From User Where Id =:userList];
            System.debug('Ulist..........'+uList);
        /*    for(User u :uList)
            {
                if(u.Max_Lead_Per_Day__c !=0 & u.Max_Lead_Per_Month__c != 0 )
                {
                     update uList;
                }
            }*/
           update userList;
            return true;
        } catch(Exception e) {
            return false;
        }
    }

}