trigger TriggerOnContentDocumentLink on ContentDocumentLink (after insert) {
    
    SObject_Trigger_Control__mdt triggerConfig = SObject_Trigger_Control__mdt.getInstance('CDL');
    if(triggerConfig != null && triggerConfig.Trigger_Status__c) {
        ContentDocumentLinkTrigger handlerInstance = ContentDocumentLinkTrigger.getInstance();
        if(Trigger.isAfter && Trigger.isInsert) {
            handlerInstance.onAfterInsert(Trigger.New);
        }
    }
}