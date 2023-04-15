trigger PE_Delete_Leads on Delete_Lead__e (after insert) {
    SObject_Trigger_Control__mdt triggerConfig = SObject_Trigger_Control__mdt.getInstance('PEDeleteLead');
    system.debug('triggerConfig:: ' + triggerConfig);
    
    if (triggerConfig != null && triggerConfig.Trigger_Status__c){
        PE_Delete_Lead_elper handlerInstance = PE_Delete_Lead_elper.getInstance();
        
        system.debug('After Insert');
        if(trigger.isAfter && trigger.isInsert){
            handlerInstance.deleteLeadRecords(trigger.new);
        }
        
    }
}