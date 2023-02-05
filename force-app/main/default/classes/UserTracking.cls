public without sharing class UserTracking{
    public UserTracking(){
    }
    
    @AuraEnabled(cacheable = true)
    public static UserTrack OnpageLoad(string userId){
        try{
        UserTrack usr = new UserTrack();
        
        User xUser = [Select Name
                      From User
                      where Id = :UserInfo.getUserId()];
        
        list<User_Tracking__c> userTracking = [select id, Checkin_Datetime__c, Checkout_Datetime__c, BreakTime_Started__c, Member__c
                                               from User_Tracking__c
                                               where Member__c = :userId and CreatedDate = TODAY
                                               limit 1];
        if (!userTracking.isEmpty()){
            usr.IsbreakStarted = userTracking[0].BreakTime_Started__c;
            usr.checkin = true;
            if (userTracking[0].Checkout_Datetime__c != null)
                usr.checkout = true;
            else
                usr.checkout = false;
        } else{
            usr.checkin = false;
            usr.checkout = true;
        }
        
        usr.username = xUser.Name;
        
        return usr;
    } catch (Exception e){
        system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
      HandleBusinessException.captureError('UserTracking', 'OnpageLoad', e , null);
       return null;
    }
}
    
    @AuraEnabled
    public static String UserCheckin(string userId){
        
       try{ 
        List<Lead> leadList = new List<Lead>();
        String eventStatus = 'Something went wrong';
        string groupName = '';
        DateTime dt = DateTime.now();
        
        String dayOfWeek = dt.format('EEEE');
        
        if (System.now().time() < Time.newInstance(10, 00, 00, 00)){
            system.debug('Inside 9 :30');
            eventStatus = 'You can not checkin before 10:00 AM.';
            system.debug('eventStatus-->' + eventStatus);
            return eventStatus;
        }
        system.debug('Outside');
        map<string, string> mapofGroupNameBySourceIntent = new map<string, string>();
        if (userId != null){
            boolean isTaskAssignmentGroupMember = false;
            list<User_Tracking__c> userTracking = new list<User_Tracking__c>();
            list<Assignment_Group_Member__c> agmList = new list<Assignment_Group_Member__c>();
            userTracking = [select id, Checkin_Datetime__c, Checkout_Datetime__c, Member__c
                            from User_Tracking__c
                            where Member__c = :userId and CreatedDate = TODAY
                            limit 1];
            agmList = [select id, Group_Member__c, Assignment_Group__r.name
                       from Assignment_Group_Member__c
                       where Group_Member__c = :userId];
            if (userTracking.isEmpty()){
                list<Course_Interested_And_Group_Name__mdt> groupNameSourceIntent = [select id, Group_Name__c, Source_Intent__c
                                                                                     from Course_Interested_And_Group_Name__mdt];
               
                if (!groupNameSourceIntent.isEmpty()){
                    for (Course_Interested_And_Group_Name__mdt signMeta : groupNameSourceIntent){
                        mapofGroupNameBySourceIntent.put(signMeta.Group_Name__c, signMeta.Source_Intent__c);
                    }
                }
                
                User_Tracking__c userTrackRec = new User_Tracking__c();
                userTrackRec.Member__c = userId;
                userTrackRec.Checkin_Datetime__c = DateTime.now();
                insert userTrackRec;
                if (!agmList.isEmpty()){
                    for (Assignment_Group_Member__c agm : agmList){
                        agm.Out_Of_Office__c = false;
                    }
                    
                    update agmList;
                    
                }
                
                eventStatus = 'Checkin successful';
            } else{
                eventStatus = 'Your checkin was already created.';
            }
            
        } else{
            eventStatus = 'User is not registered in system.Please contact to your admin.';
        }
        
        
        return eventStatus;
    } catch (Exception e){
        system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
      HandleBusinessException.captureError('UserTracking', 'UserCheckin', e , null);
       return null;
    }
}
    
    @AuraEnabled
    public static String UserCheckout(string userId){
        try{
        String eventStatus = 'Something went wrong';
        if (userId != null){
            list<User_Tracking__c> userTracking = new list<User_Tracking__c>();
            list<Assignment_Group_Member__c> agmList = new list<Assignment_Group_Member__c>();
            userTracking = [select id, Checkin_Datetime__c, Checkout_Datetime__c, Member__c
                            from User_Tracking__c
                            where Member__c = :userId and createddate = TODAY
                            limit 1];
            agmList = [select id, Group_Member__c
                       from Assignment_Group_Member__c
                       where Group_Member__c = :userId];
            if (!userTracking.isEmpty()){
                for (User_Tracking__c ut : userTracking){
                    ut.Checkout_Datetime__c = DateTime.now();
                }
                update userTracking;
                if (!agmList.isEmpty()){
                    for (Assignment_Group_Member__c agm : agmList){
                        agm.Out_Of_Office__c = true;
                        agm.BreakTime_Started__c = false;
                    }
                    
                    update agmList;
                }
                eventStatus = 'Checkout datetime has been updated.';
            } else{
                eventStatus = 'You can not checkout without checkin.';
            }
            
        } else{
            eventStatus = 'User is not registered in system.Please contact to your admin.';
        }
        
        
        return eventStatus;
    } catch (Exception e){
        system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
      HandleBusinessException.captureError('UserTracking', 'UserCheckout', e , null);
       return null;
    }
}
    
    @AuraEnabled
    public static void manageBreakTime(string userId){
        try{
        UserTrack usr = new UserTrack();
        List<Assignment_Group_Member__c> agmListToBeUpdated = new List<Assignment_Group_Member__c>();
        list<User_Tracking__c> userTracking = [select id, BreakTime_Started__c, Checkin_Datetime__c, Checkout_Datetime__c, Member__c
                                               from User_Tracking__c
                                               where Member__c = :userId and CreatedDate = TODAY
                                               limit 1];
        List<Assignment_Group_Member__c> agmList = [Select Id, BreakTime_Started__c
                                                    From Assignment_Group_Member__c
                                                    where Group_Member__c = :userId];
        if (!userTracking.isEmpty()){
            userTracking[0].BreakTime_Started__c = !userTracking[0].BreakTime_Started__c;
            update userTracking[0];
        }
        if (!agmList.isEmpty()){
            for (Assignment_Group_Member__c agm : agmList){
                Assignment_Group_Member__c agmRec = new Assignment_Group_Member__c();
                agmRec.Id = agm.Id;
                agmRec.BreakTime_Started__c = !agm.BreakTime_Started__c;
                agmListToBeUpdated.add(agmRec);
            }
            if (!agmListToBeUpdated.isEmpty()){
                update agmListToBeUpdated;
            }
        }
    } catch (Exception e){
        system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
      HandleBusinessException.captureError('UserTracking', 'manageBreakTime', e , null);
      
    }
}
    
    public class UserTrack{
        @AuraEnabled
        public boolean checkin;
        @AuraEnabled
        public boolean checkout;
        @AuraEnabled
        public boolean IsbreakStarted;
        @AuraEnabled
        public String username;
        
    }
    
}