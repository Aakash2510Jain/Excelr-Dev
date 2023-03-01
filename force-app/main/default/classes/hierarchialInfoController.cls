Public Without Sharing class hierarchialInfoController{
   
    public static List<User> getRoleSubordinateUsers(Id roleId) {
        Set<Id> allSubRoleIds = getAllSubRoleIds(new Set<ID>{roleId});
        Map<Id, User> users = new Map<Id, User>([Select Id, Name,Username, Max_Lead_Per_Day__c,Max_Lead_Per_Month__c From User where IsActive = True AND UserRoleId IN :allSubRoleIds]);
        system.debug('users.keySet() -- ' + users.keySet());
        return users.values();
    }
    
    public static Set<ID> getAllSubRoleIds(Set<ID> roleIds) {
        Set<ID> currentRoleIds = new Set<ID>();
        for(UserRole userRole :[select Id from UserRole where ParentRoleId IN :roleIds AND ParentRoleID != null])
            currentRoleIds.add(userRole.Id);
        if(currentRoleIds.size() > 0){
            currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));
        }
        return currentRoleIds;
    }
}