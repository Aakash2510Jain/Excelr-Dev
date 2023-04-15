trigger TriggerOnOpportunity on Opportunity (before insert, after update, before update) {

    SObject_Trigger_Control__mdt triggerConfig = SObject_Trigger_Control__mdt.getInstance('Opportunity');
    system.debug('triggerConfig:: ' + triggerConfig);
    system.debug('Inside Opportunity Trigger');
    if (triggerConfig != null && triggerConfig.Trigger_Status__c){

        Opportunitytriggerhandler handlerInstance = Opportunitytriggerhandler.getInstance();
        if (trigger.isAfter && trigger.isUpdate) {
            handlerInstance.afterUpdate(trigger.oldMap, trigger.newMap);
        }
        if (trigger.isBefore && trigger.isUpdate) {
            handlerInstance.beforeupdate(trigger.oldMap, trigger.newMap);            
        }
    }

}