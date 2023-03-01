public class opportunityLineItemTriggerHelper {
    
    public static void fireApprovalAfterInsert(Map<Id, OpportunityLineItem> newMap){
        try{ 
            system.debug('newMap -- ' + newMap);
            Map<Id, OpportunityLineItem> oppItemMap = new Map<Id, OpportunityLineItem>([SELECT Id, Opportunity.Owner.UserRoleId FROM OpportunityLineItem WHERE Id IN: newMap.keySet()]);
            Map<Id, Approval.ProcessSubmitRequest> cdToapprovalRequestMap = new Map<Id, Approval.ProcessSubmitRequest>();
            Utility.ApprovalWrapper approvalParentIdWrapper = Utility.getParentUserMap();
            
            for(OpportunityLineItem OLIRec : newMap.values()){
                if(OLIRec.Discount > 20){
                    Id approverId;
                    Id userRoleId = oppItemMap.get(OLIRec.Id).Opportunity.Owner.UserRoleId;
                    system.debug('userRoleId -- ' + userRoleId);
                    Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
                    approvalRequest.setComments('Submitting for Manager Approval');
                    approvalRequest.setObjectId(OLIRec.OpportunityId);
                    approvalRequest.setProcessDefinitionNameOrId('Discount_exceeded_threshold_value');
                    if(OLIRec.Opportunities_Owner_s_Manager_Id__c != null){
                        approverId = OLIRec.Opportunities_Owner_s_Manager_Id__c;
                    }
                    else {
                        approverId = approvalParentIdWrapper.smToManagerMap.containsKey(userRoleId) && approvalParentIdWrapper.managerRoleToUserIdMap.containsKey(approvalParentIdWrapper.smToManagerMap.get(userRoleId)) ? approvalParentIdWrapper.managerRoleToUserIdMap.get(approvalParentIdWrapper.smToManagerMap.get(userRoleId)) : null; //userBhMap.containsKey(oppOwnersRoleId) ? userBhMap.get(oppOwnersRoleId) : null;
                        //approvalRequest.setNextApproverIds(new List<Id> {system.label.Admin_User_Id});                        
                    }
                    approvalRequest.setNextApproverIds(new List<Id> {approverId});
                    cdToapprovalRequestMap.put(OLIRec.Id, approvalRequest);
                    
                    if(!cdToapprovalRequestMap.isEmpty())
                        List<Approval.ProcessResult> result = Approval.process(cdToapprovalRequestMap.values());
                }
            }
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('opportunityLineItemTriggerHelper', 'fireApprovalAfterInsert', e , null);
            
        }
    }
}