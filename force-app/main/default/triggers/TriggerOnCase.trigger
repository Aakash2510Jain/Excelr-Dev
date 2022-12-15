trigger TriggerOnCase on Case (after insert, after update) {
SObject_Trigger_Control__mdt triggerConfig = SObject_Trigger_Control__mdt.getInstance('Case');
    system.debug('triggerConfig:: ' + triggerConfig);
    
    if(triggerConfig != null && triggerConfig.Trigger_Status__c) {
        CaseTriggerHeper handlerInstance = CaseTriggerHeper.getInstance();
        if(trigger.isAfter && trigger.isInsert) {
            System.debug('On After Insert Case Trigger fired');
            handlerInstance.onAfterInsert(trigger.new, trigger.newMap);
        }
        if(trigger.isAfter && trigger.isUpdate) {
            System.debug('On After Update Case Trigger fired');
            handlerInstance.onAfterUpdate(trigger.new, trigger.oldMap);
        }
    }
}