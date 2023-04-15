trigger opportunityLineItemTrigger on OpportunityLineItem (after insert, before delete) {
    SObject_Trigger_Control__mdt triggerConfig = SObject_Trigger_Control__mdt.getInstance('OpportunityLineItem');
    system.debug('triggerConfig:: ' + triggerConfig);
    
    if (triggerConfig != null && triggerConfig.Trigger_Status__c){
        opportunityLineItemTriggerHelper handlerInstance = opportunityLineItemTriggerHelper.getInstance();
        
        if(trigger.isAfter && trigger.isInsert){
            handlerInstance.fireApprovalAfterInsert(trigger.newMap);
        }
        if(trigger.isbefore && trigger.isdelete){
            handlerInstance.removeApprovalFromProcessing(trigger.old, trigger.oldmap);
        }
    }
}