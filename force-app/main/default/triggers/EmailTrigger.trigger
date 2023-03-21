trigger EmailTrigger on EmailMessage (after insert) {
    if(trigger.isAfter && trigger.isInsert){
        EmailTriggerHelper.attachEmailToLead(trigger.new);
    }
}