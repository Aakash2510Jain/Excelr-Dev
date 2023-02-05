public class opportunityLineItemTriggerHelper {
    public static void fireApprovalAfterInsert(Map<Id, OpportunityLineItem> oldMap, Map<Id, OpportunityLineItem> newMap){
   try{ 
        Map<Id, Approval.ProcessSubmitRequest> cdToapprovalRequestMap = new Map<Id, Approval.ProcessSubmitRequest>();
        
        for(OpportunityLineItem OLIRec : newMap.values()){
            if(OLIRec.Discount > 20){
                Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
                approvalRequest.setComments('Submitting for Manager Approval');
                approvalRequest.setObjectId(OLIRec.OpportunityId);
                approvalRequest.setProcessDefinitionNameOrId('Discount_exceeded_threshold_value');
                if(OLIRec.Opportunities_Owner_s_Manager_Id__c != null){
                    approvalRequest.setNextApproverIds(new List<Id> {OLIRec.Opportunities_Owner_s_Manager_Id__c});
                }
                else {
                    approvalRequest.setNextApproverIds(new List<Id> {system.label.Admin_User_Id});                        
                }
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