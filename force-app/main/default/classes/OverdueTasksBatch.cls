public without sharing class OverdueTasksBatch implements Database.Batchable <Sobject> {
    
    public Database.QueryLocator Start(Database.BatchableContext bc){
        return Database.getQueryLocator('SELECT Id, ActivityDate, WhoId, OwnerId, Owner.UserRoleId FROM Task WHERE ' + 
                                        'ActivityDate < TODAY AND Status != \'Completed\' limit 4000');
    }
    
    public void Execute(Database.BatchableContext bc, List<Task> taskList){
        try{
            system.debug('TaskList :: ' + taskList);

            Utility.ApprovalWrapper approvalQAWrapper = Utility.getUserQAMap();
            for(Task taskRec : taskList){
                
                Id tskOwnersRoleId = taskRec.Owner.UserRoleId;
                system.debug('tskOwnersRoleId :: ' + tskOwnersRoleId);
                Id QAId = approvalQAWrapper.smToManagerMap.containsKey(tskOwnersRoleId) && approvalQAWrapper.managerRoleToUserIdMap.containsKey(approvalQAWrapper.smToManagerMap.get(tskOwnersRoleId)) ? approvalQAWrapper.managerRoleToUserIdMap.get(approvalQAWrapper.smToManagerMap.get(tskOwnersRoleId)) : null; //userBhMap.containsKey(tskOwnersRoleId) ? userBhMap.get(tskOwnersRoleId) : null;
                system.debug('QAId :: ' + QAId);
                if(QAId != null){
                    Case cRec = new Case();
                    cRec.OwnerId = QAId;
                    insert cRec;
                    system.debug('ID :: ' + cRec.Id);
                }
                
            }
        }
        catch(Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
          HandleBusinessException.captureError('OverdueTasksBatch', 'Execute', e, null);
        }
    }
    
    public void Finish(Database.BatchableContext bc){
        System.debug('The Batch Run Successfully');
    }
    
}