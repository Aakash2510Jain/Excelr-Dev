public without sharing class opportunityLineItemTriggerHelper{
    static opportunityLineItemTriggerHelper handlerInstance;
    public static opportunityLineItemTriggerHelper getInstance(){
        if (handlerInstance == null)
            handlerInstance = new opportunityLineItemTriggerHelper();
        return handlerInstance;
    }
    public void fireApprovalAfterInsert(Map<Id, OpportunityLineItem> newMap){
        try{
            system.debug('newMap -- ' + newMap);
            Map<Id, OpportunityLineItem> oppItemMap = new Map<Id, OpportunityLineItem>([SELECT Id, Opportunity.Owner.UserRoleId
                                                                                        FROM OpportunityLineItem
                                                                                        WHERE Id IN:newMap.keySet()]);
            Map<Id, Approval.ProcessSubmitRequest> cdToapprovalRequestMap = new Map<Id, Approval.ProcessSubmitRequest>();
            List<Approval.ProcessSubmitRequest> approvalRequestList = new List<Approval.ProcessSubmitRequest>();
            Utility.ApprovalWrapper approvalParentIdWrapper = Utility.getParentUserMap();
            String syedUserId = [Select Id
                                 from User
                                 where name = 'Syed Moshin'].Id;
            System.debug('syedUserId ===> ' + syedUserId);
            
            for (OpportunityLineItem OLIRec : newMap.values()){
                if (!Approval.isLocked(OLIRec.OpportunityId)){
                    if (OLIRec.Discount > 20 && OLIRec.Discount <= 30){
                        Id approverId;
                        Id userRoleId = oppItemMap.get(OLIRec.Id).Opportunity.Owner.UserRoleId;
                        system.debug('userRoleId -- ' + userRoleId);
                        Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
                        approvalRequest.setComments('Submitting for Manager Approval');
                        approvalRequest.setObjectId(OLIRec.OpportunityId);
                        approvalRequest.setProcessDefinitionNameOrId('Discount_exceeded_threshold_value');
                        if (OLIRec.Opportunities_Owner_s_Manager_Id__c != null){
                            approverId = OLIRec.Opportunities_Owner_s_Manager_Id__c;
                        } else{
                            approverId = approvalParentIdWrapper.smToManagerMap.containsKey(userRoleId) && approvalParentIdWrapper.managerRoleToUserIdMap.containsKey(approvalParentIdWrapper.smToManagerMap.get(userRoleId)) ? approvalParentIdWrapper.managerRoleToUserIdMap.get(approvalParentIdWrapper.smToManagerMap.get(userRoleId)) : null; //userBhMap.containsKey(oppOwnersRoleId) ? userBhMap.get(oppOwnersRoleId) : null;
                        }
                        System.debug('approverId ====> ' + approverId);
                        
                        approvalRequest.setNextApproverIds(new Id[]{ approverId });
                        
                        
                        cdToapprovalRequestMap.put(OLIRec.Id, approvalRequest);
                        System.debug('cdToapprovalRequestMap values ===> ' + cdToapprovalRequestMap.values());
                        
                        if (!cdToapprovalRequestMap.isEmpty())
                            List<Approval.ProcessResult> result = Approval.process(cdToapprovalRequestMap.values());
                    } else if (OLIRec.Discount > 30){
                        //String syedUserId = [Select Id from User where name = 'Syed Moshin'].Id;
                        Id approverId;
                        Id userRoleId = oppItemMap.get(OLIRec.Id).Opportunity.Owner.UserRoleId;
                        system.debug('userRoleId -- ' + userRoleId);
                        Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
                        approvalRequest.setComments('Submitting for Manager Approval');
                        approvalRequest.setObjectId(OLIRec.OpportunityId);
                        approvalRequest.setProcessDefinitionNameOrId('Discount_exceeded_threshold_value');
                        approverId = syedUserId;
                        
                        approvalRequest.setNextApproverIds(new List<Id>{ approverId });
                        cdToapprovalRequestMap.put(OLIRec.Id, approvalRequest);
                        
                        if (!cdToapprovalRequestMap.isEmpty())
                            List<Approval.ProcessResult> result = Approval.process(cdToapprovalRequestMap.values());
                    }
                }
            }
            System.debug('cdToapprovalRequestMap ===> ' + cdToapprovalRequestMap);
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('opportunityLineItemTriggerHelper', 'fireApprovalAfterInsert', e, null);
            
        }
    }
    
    public void removeApprovalFromProcessing(List<OpportunityLineItem> oldOppLineItem, Map<Id, OpportunityLineItem> OldOLIMap){
        System.debug('oldOppLineItem ====> ' + oldOppLineItem);
        System.debug('OldOLIMap ====> ' + OldOLIMap);
        set<Id> OppIds = new Set<Id>();
        List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
        try{
            List<Opportunity> OppList = new List<Opportunity>();
            List<Opportunity> UpdatedOppList = new List<Opportunity>();
            
            if (!OldOLIMap.isEmpty()){
                
                for (OpportunityLineItem Oli : OldOLIMap.values()){
                    if (Approval.isLocked(Oli.OpportunityId)){
                        if(Oli.Discount > 20){
                            OppIds.add(Oli.OpportunityId);
                        }
                    }
                }
            }
            
            System.debug('OppIds =====> ' + OppIds);
            if (!OppIds.isEmpty()){
                OppList = [Select Id from Opportunity where Id In:OppIds];
                for (Opportunity OppRec : OppList) {
                    Opportunity updatedOppRec = new Opportunity();
                    updatedOppRec.id = OppRec.Id;
                    updatedOppRec.Approval_Status__c = '';
                    UpdatedOppList.add(updatedOppRec);
                    
                }
                Map<ID, Opportunity> oppmap = New Map<ID, Opportunity>([Select Id
                                                                        from Opportunity
                                                                        where Id In:OppIds]);
                System.debug('oppmap ===> ' + oppmap);
                Map<ID, ProcessInstance> piMap = New Map<ID, ProcessInstance>([Select Id
                                                                               from ProcessInstance
                                                                               where TargetObjectId IN:oppmap.keySet()]);
                System.debug('piMap ===> ' + piMap);    
                
                for (ProcessInstanceWorkItem wi : [Select Id
                                                   from ProcessInstanceWorkItem
                                                   where ProcessInstanceId IN:piMap.keySet()]){
                                                       System.debug('wi ====> ' + piMap);
                                                       
                                                       
                                                       // if there's a work item, set the action to 'removed' and execute
                                                       Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
                                                       req2.setAction('Removed');
                                                       req2.setWorkitemId(wi.Id);
                                                       requests.add(req2);
                                                       
                                                   }
                
            }
            if (!requests.isEmpty() && requests.size() >0) {
                Approval.ProcessResult[] processResults = null;
                processResults = Approval.process(requests, true);
            }
            if (!UpdatedOppList.isEmpty()) {
                update UpdatedOppList;
            }
            
            
            //Get Opps
            
            
            //Get ProcessInstance Items
            
            
            
            
        } catch (Exception e){
            
            
        }
    }
    
}