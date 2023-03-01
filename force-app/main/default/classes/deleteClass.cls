public without sharing class deleteClass {
    
    
    public static List <City_Big_Object__b> deleteMethod(string SelectedCountryId,string SelectedStateId){
        system.debug('SelectedCountryId--'+SelectedCountryId);
        system.debug('SelectedStateId--'+SelectedStateId);
        string compositekey=SelectedCountryId+SelectedStateId;
        List <City_Big_Object__b> cityList = [Select Id,City__c from City_Big_Object__b where CountryStateCompositeKey__c =:compositekey];
        system.debug('cityList--->'+cityList.size());
        //Select City__c from City_Big_Object__b where CountryStateCompositeKey__c = 'a0aN000000BcX3TIAVa0bN000000Es3saIAB'
        //
        
        return cityList;
    }
    public static void getParrentId(){
        
        
        Map<Id, UserRole> roleMap = new Map<Id, UserRole>([SELECT Id, Name, ParentRoleId FROM UserRole]);
        
        Set<Id> subordinateIds = new Set<Id>();
        Id managerId = UserInfo.getUserId();
        
        List<User> managerSubordinates = [SELECT Id, ManagerId, UserRoleId FROM User WHERE ManagerId = :managerId];
        for (User sub : managerSubordinates) {
            subordinateIds.add(sub.Id);
        }
        
        Map<Id, List<UserRole>> roleHierarchy = new Map<Id, List<UserRole>>();
        for (UserRole role : roleMap.values()) {
            List<UserRole> subRoles = roleHierarchy.get(role.ParentRoleId);
            if (subRoles == null) {
                subRoles = new List<UserRole>();
            }
            subRoles.add(role);
            roleHierarchy.put(role.ParentRoleId, subRoles);
        }
        
        List<UserRole> managerRoles = roleHierarchy.get(managerSubordinates[0].UserRoleId);
        List<UserRole> allSubordinateRoles = new List<UserRole>();
        while (!managerRoles.isEmpty()) {
            UserRole currentRole = managerRoles.remove(0);
            allSubordinateRoles.add(currentRole);
            List<UserRole> subRoles = roleHierarchy.get(currentRole.Id);
            if (subRoles != null) {
                managerRoles.addAll(subRoles);
            }
        }
        
        System.debug(allSubordinateRoles);
        
        /*

set<Id> ManagerUserId=new set<Id>();

User userDetails = new User();
userDetails = [select Id, Name, ManagerId from User where Id =: userId];
if(userDetails.ManagerId != null){
ManagerUserId.add(userDetails.managerId);
getParrentId(userDetails.ManagerId);// Recursive call to find manager of manager
system.debug('ManagerUserId-->'+ManagerUserId);
}
*/
    }
}