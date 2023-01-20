public class UserTriggerHandler {
    
   
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
            Exceptions__c Exc = new Exceptions__c();
            Exc.Class_Name__c = 'UserTriggerHandler';
			Exc.Error_Message__c = e.getMessage();     
            Exc.Error_Line_No__c = e.getLineNumber();
            Exc.Error_Stack_Trace__c = e.getStackTraceString();
            Exc.Error_Type__c = e.getTypeName();
            Exc.Method_Name__c = 'UserAfterUpdate';
            insert Exc;
            System.debug('Exception----'+e.getMessage());
        }
         
    }
    
    Public Static Void DeleteAvailibility(Map<Id,User>UserMap){
        System.debug('UserMapDelete----'+UserMap);
        List<Availability__c> AvailableRecList=[Select Id,Name From Availability__c Where OwnerId IN:UserMap.keySet()];
        if(!AvailableRecList.isEmpty()){
            delete AvailableRecList;
        }
  
    }
    
    Public Static Void CreateAvailibility(Map<Id,User>UserMap){
        System.debug('UserMap----'+UserMap);
        List<Availability__c> Av=new List<Availability__c>();
        for(User U:UserMap.values()){
            
            Date startDate = U.Start_Date__c;
            Date endDate = U.End_Date__c;
            
            Integer AvailableDays=startDate.daysBetween(endDate)+1;
            
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
    }

}