trigger TriggerOnUser on User (After insert,After Update) {
    
    if(Trigger.isInsert && Trigger.isAfter){
        UserTriggerHandler.CreateAvailibility(Trigger.newMap);
    }
    if(Trigger.isUpdate && Trigger.isAfter){
        UserTriggerHandler.UserAfterUpdate(Trigger.newMap,Trigger.OldMap);
    }

}