trigger opportunityLineItemTrigger on OpportunityLineItem (after insert, before delete) {
    if(trigger.isAfter && trigger.isInsert){
        opportunityLineItemTriggerHelper.fireApprovalAfterInsert(trigger.newMap);
    }
    if(trigger.isbefore && trigger.isdelete){
        opportunityLineItemTriggerHelper.removeApprovalFromProcessing(trigger.old, trigger.oldmap);

        
    }
}