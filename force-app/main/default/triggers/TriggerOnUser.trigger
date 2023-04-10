trigger TriggerOnUser on User (After insert,After Update) {
    SObject_Trigger_Control__mdt triggerConfig = SObject_Trigger_Control__mdt.getInstance('User');
    system.debug('triggerConfig:: ' + triggerConfig);
    
    if (triggerConfig != null && triggerConfig.Trigger_Status__c){
        UserTriggerHandler handlerInstance = UserTriggerHandler.getInstance();
        
        if(Trigger.isInsert && Trigger.isAfter){
            UserTriggerHandler.CreateAvailibility(Trigger.newMap);
        }
        if(Trigger.isUpdate && Trigger.isAfter){
            System.debug('After Update called');
            UserTriggerHandler.UserAfterUpdate(Trigger.newMap,Trigger.OldMap);
        }
    }

}