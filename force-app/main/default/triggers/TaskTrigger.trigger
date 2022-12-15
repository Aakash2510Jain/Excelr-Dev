trigger TaskTrigger on Task (before update) {
    if(trigger.isBefore && trigger.isUpdate){
        TaskTriggerHelper.beforeUpdate(trigger.newMap, trigger.oldMap);
    }
}