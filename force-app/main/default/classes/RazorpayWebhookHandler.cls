@RESTResource(urlMapping = '/razorpayWebhook/*')
global without sharing class RazorpayWebhookHandler{
    @HttpPost
    global static String webhookListener(){
        try{
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;

            String body = req.requestBody.toString();

            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(body);
            Map<String, Object> m2 = (Map<String, Object>)m.get('payload');
            Map<String, Object> m3 = (Map<String, Object>)m2.get('payment');
            Map<String, Object> m4 = (Map<String, Object>)m3.get('entity');
            Map<String, Object> m5 = new Map<String, Object>();
            Map<Id, Approval.ProcessSubmitRequest> cdToapprovalRequestMap = new Map<Id, Approval.ProcessSubmitRequest>();

            if (m4.containsKey('captured')){
                m5 = (Map<String, Object>)m4.get('notes');
                String recId = m5.get('policy_name').toString();
                String objName = m5.get('objectName').toString();

                /* Invoice__c iv = new Invoice__c(Id = recId, Status__c = 'Realized');
                 update iv;*/

                if (objName == 'Lead'){
                    //Convert Lead
                    Lead ld = new Lead(Id = recId);
                    update ld;
                    system.debug('Lead After Updation :: ' + ld);
                    
                    //Utility.convertLeadAfterPayment(recId, m4);
                    //Attach applications to account
                    //Attach invoice to opportunity
                    //attah invoice pdf under invoice
                    //Email to customer

                } else if (objName == 'Opportunity'){
                    //attah invoice pdf under invoice
                    //Email to customer
                    /*Opportunity opp = new Opportunity(Id = recId, Payment_Captured__c = m4.get('captured') == true ? true : false);
                    opp.StageName = 'Closed Won';
                    update opp;*/
                    Utility.ApprovalWrapper approvalParentIdWrapper = Utility.getParentUserMap();

                    Invoice__c invoiceRec = [Select Id, Status__c,LeadInvoice__c,LeadInvoice__r.Owner.UserRoleId,Lead_ManagerId__c,Opportunity__c,Opportunity__r.Owner.UserRoleId
                                             From Invoice__c
                                             Where Opportunity__c = :recId
                                             ORDER BY CreatedDate DESC
                                             limit 1];
                    if (m4.get('captured') == true){
                        //invoiceRec.Status__c = 'Realized';
                        invoiceRec.TranactionId__c = String.ValueOf(m4.get('id'));
                        Id approverId;
                        String userRoleId;
                        Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
                        approvalRequest.setComments('Submitting for Manager Approval');
                        approvalRequest.setObjectId(invoiceRec.Id);
                        approvalRequest.setProcessDefinitionNameOrId('Invoice_Payment_Approval');
                        if(invoiceRec.LeadInvoice__c != null){
                            userRoleId = invoiceRec.LeadInvoice__r.Owner.UserRoleId;
                            if(invoiceRec.Lead_ManagerId__c != null){
                                approverId = invoiceRec.Lead_ManagerId__c;
                            }
                            else{
                                approverId = approvalParentIdWrapper.smToManagerMap.containsKey(userRoleId) && approvalParentIdWrapper.managerRoleToUserIdMap.containsKey(approvalParentIdWrapper.smToManagerMap.get(userRoleId)) ? approvalParentIdWrapper.managerRoleToUserIdMap.get(approvalParentIdWrapper.smToManagerMap.get(userRoleId)) : null; //userBhMap.containsKey(oppOwnersRoleId) ? userBhMap.get(oppOwnersRoleId) : null;
                            }
                        }
                        else if(invoiceRec.Opportunity__c != null ){
                            userRoleId = invoiceRec.Opportunity__r.Owner.UserRoleId;
                            if(invoiceRec.Opportunity__r.Owner.managerid != null){
                                approverId = invoiceRec.Opportunity__r.Owner.managerid;
                            }
                            else{
                                approverId = approvalParentIdWrapper.smToManagerMap.containsKey(userRoleId) && approvalParentIdWrapper.managerRoleToUserIdMap.containsKey(approvalParentIdWrapper.smToManagerMap.get(userRoleId)) ? approvalParentIdWrapper.managerRoleToUserIdMap.get(approvalParentIdWrapper.smToManagerMap.get(userRoleId)) : null; //userBhMap.containsKey(oppOwnersRoleId) ? userBhMap.get(oppOwnersRoleId) : null;
                            }
                        }
                        approvalRequest.setNextApproverIds(new List<Id> {approverId});
                        cdToapprovalRequestMap.put(invoiceRec.Id, approvalRequest);
                        
                        if(!cdToapprovalRequestMap.isEmpty())
                            List<Approval.ProcessResult> result = Approval.process(cdToapprovalRequestMap.values());
                        
                    }
                    if (m4.get('captured') == false){
                        invoiceRec.Status__c = 'Not realized';
                    }
                    update invoiceRec;
                }
            }


            return 'Success';
        } catch (Exception e){
            System.debug(' the Error has occured due to =====> ' + e.getMessage());
            System.debug(' the Error has occured at  =====> ' + e.getLineNumber());
            HandleBusinessException.captureError('RazorpayWebhookHandler','webhookListener', e, null);
            return 'Error - ' + e.getMessage();
        }
    }

}