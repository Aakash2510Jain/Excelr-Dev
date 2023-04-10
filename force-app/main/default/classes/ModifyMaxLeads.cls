public without sharing class ModifyMaxLeads 
{
    @AuraEnabled
    public Static List<User> getUser(){
        try{   
            Set<Id> reporteeIds = new Set<Id>();
            List<Id> roleIds = new List<Id>();
            List<User> reportees = new List<User>();
            string currentUserRoleId = [select Id, Max_Lead_Per_Day__c, Max_Lead_Per_Month__c, UserRoleId from User where Id =: UserInfo.getUserId()].UserRoleId;
            /*if(!string.isBlank(currentUserRoleId)){
                for(UserRole role : [SELECT Id, Name FROM UserRole WHERE ParentRoleId =: currentUserRoleId]) {
                    roleIds.add(role.Id);
                }
                if(!roleIds.isEmpty()){
                    for(User u : [SELECT Id, UserRoleId FROM User WHERE UserRoleId IN :roleIds]) {
                        reporteeIds.add(u.Id);
                    }
                    if(!reporteeIds.isEmpty()){
                        reportees = [SELECT Id, Name,Username, Max_Lead_Per_Day__c,Max_Lead_Per_Month__c FROM User WHERE Id IN : reporteeIds];
                    }
                }
            }*/
            
            //Added by Anjali Singh
            reportees = hierarchialInfoController.getRoleSubordinateUsers(currentUserRoleId);
            return reportees ;
        }catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('ModifyMaxLeads', 'getUser', e , null);
            return null;
        }
    }
    
    @AuraEnabled
    public static boolean updaterecord(List<User> userList){
        try {
            update userList;
            return true;
        } catch(Exception e) {
            return false;
        }
    }
    
    public static Set<Id> reporteeIds = new Set<Id>();
    public static  Map<Id, UserRole> roleMap = new Map<Id, UserRole>([SELECT Id, Name, ParentRoleId FROM UserRole]);
    
    public static Set<Id> getAllReporteesByRole(Id managerId) {
        
        // Get the manager's role ID
        Id managerRoleId = [SELECT Id, UserRole.Name FROM User WHERE Id =: managerId].UserRoleId;
        
        // Call the recursive function for the manager's role
        getReporteesForRole(managerRoleId);
        
        // Do something with the reportee IDs, for example:
        List<User> reportees = [SELECT Id, Name, Email FROM User WHERE Id IN : reporteeIds];
        
        return reporteeIds;
    }
    public static void getReporteesForRole(Id roleId) {
        for(User u : [SELECT Id, UserRoleId FROM User WHERE UserRoleId =: roleId]) {
            reporteeIds.add(u.Id);
            getReporteesForRole(u.UserRoleId); // recursively get reportees for the reportee's role
        }
    }
}