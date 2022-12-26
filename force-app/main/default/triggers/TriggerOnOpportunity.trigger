trigger TriggerOnOpportunity on Opportunity (before insert, after update) {

    SObject_Trigger_Control__mdt triggerConfig = SObject_Trigger_Control__mdt.getInstance('Opportunity');
    system.debug('triggerConfig:: ' + triggerConfig);

    if (triggerConfig != null && triggerConfig.Trigger_Status__c){

        Opportunitytriggerhandler handlerInstance = Opportunitytriggerhandler.getInstance();
        if (trigger.isAfter && trigger.isUpdate) {
            handlerInstance.createtaskForIsm(trigger.oldMap, trigger.newMap);
        }
    }

}