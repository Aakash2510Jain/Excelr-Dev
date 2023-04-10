public without sharing class UserTriggerHandler {
    static UserTriggerHandler handlerInstance;
    
    public static UserTriggerHandler getInstance(){
        if (handlerInstance == null)
            handlerInstance = new UserTriggerHandler();
        return handlerInstance;
    }
    
    Public Static Void UserAfterUpdate(Map<Id,User> NewMap,Map<Id,User>OldMap ){
        
        try{
            Map<Id,User> UpdatedUser=new Map<Id,User>();
            
            For(User Users:NewMap.Values()){
                if((NewMap.get(Users.id).Working_Days__c!=OldMap.get(Users.id).Working_Days__c) || 
                   (NewMap.get(Users.id).Working_Start_Time__c!=OldMap.get(Users.id).Working_Start_Time__c)||
                   (NewMap.get(Users.id).Working_End_Time__c!=OldMap.get(Users.id).Working_End_Time__c)||
                   (NewMap.get(Users.id).Start_Date__c!=OldMap.get(Users.id).Start_Date__c) || 
                   (NewMap.get(Users.id).End_Date__c!=OldMap.get(Users.id).End_Date__c)){
                       
                       UpdatedUser.put(Users.Id,Users);
                   }
            }
            
            if(!UpdatedUser.isEmpty()){
                DeleteAvailibility(UpdatedUser);
                CreateAvailibility(UpdatedUser);
            }   
        }catch(Exception e){
            System.debug(' the Error has occured due to =====> ' + e.getMessage());
            System.debug(' the Error has occured at  =====> ' + e.getLineNumber());
            HandleBusinessException.captureError('UserTriggerHandler','UserAfterUpdate', e, null);
            
        }
        
    }
    
    Public Static Void DeleteAvailibility(Map<Id,User>UserMap){
        try{
        System.debug('UserMapDelete----'+UserMap);
        List<Availability__c> AvailableRecList=[Select Id,Name From Availability__c Where OwnerId IN:UserMap.keySet()];
        if(!AvailableRecList.isEmpty()){
            delete AvailableRecList;
        }
        
    } catch(Exception e){
        System.debug(' the Error has occured due to =====> ' + e.getMessage());
        System.debug(' the Error has occured at  =====> ' + e.getLineNumber());
        HandleBusinessException.captureError('UserTriggerHandler','DeleteAvailibility', e, null);
        
    }
}
    
    Public Static Void CreateAvailibility(Map<Id,User>UserMap){
        try{
        System.debug('UserMap----'+UserMap);
        List<Availability__c> Av=new List<Availability__c>();
        for(User U:UserMap.values()){
            
            Date startDate = U.Start_Date__c;
            Date endDate = U.End_Date__c;
            
            Integer AvailableDays= startDate.daysBetween(endDate)+1;
            
            for(Integer i=0;i<AvailableDays;i++){
                
                Date currentDate = startDate.addDays(i);
                
                Availability__c AvailableRec=new Availability__c();
                AvailableRec.Name=U.firstName+'-'+currentDate.format();
                AvailableRec.Date__c=currentDate;
                AvailableRec.Start_Time__c=U.Working_Start_Time__c;
                AvailableRec.End_Time__c=U.Working_End_Time__c;
                AvailableRec.OwnerId = U.Id;
                
                DateTime dt=(dateTime)CurrentDate;
                String DayofWeek=dt.format('EEEE');
                
                if(!String.isEmpty(u.Working_Days__c) && u.Working_Days__c.containsIgnoreCase(DayofWeek)){
                    Av.add(AvailableRec);
                }
            }
            
            System.debug('Av----'+Av);
            insert Av;
            
        }
    } catch(Exception e){
        System.debug(' the Error has occured due to =====> ' + e.getMessage());
        System.debug(' the Error has occured at  =====> ' + e.getLineNumber());
        HandleBusinessException.captureError('UserTriggerHandler','CreateAvailibility', e, null);
        
    }
}
    
}