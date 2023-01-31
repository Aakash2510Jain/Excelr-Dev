trigger opportunityLineItemTrigger on OpportunityLineItem (after insert) {
    if(trigger.isAfter && trigger.isInsert){
        opportunityLineItemTriggerHelper.fireApprovalAfterInsert(trigger.oldMap, trigger.newMap);
    }
}