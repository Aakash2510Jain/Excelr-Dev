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
                
                if (objName == 'Lead'){
                    Lead ld = new Lead(Id = recId);
                    update ld;
                    system.debug('Lead After Updation :: ' + ld);
                    
                } else if (objName == 'Opportunity'){
                    
                    Utility.ApprovalWrapper approvalParentIdWrapper = Utility.getParentUserMap();
                    
                    Invoice__c invoiceRec = [Select Id, Status__c,LeadInvoice__c,LeadInvoice__r.Owner.UserRoleId,Lead_ManagerId__c,Opportunity__c,Opportunity__r.Owner.UserRoleId
                                             From Invoice__c
                                             Where Opportunity__c = :recId
                                             ORDER BY CreatedDate DESC
                                             limit 1];
                    if (m4.get('captured') == true){
                        invoiceRec.TranactionId__c = String.ValueOf(m4.get('id'));
                        system.debug('recId--->'+recId);
                        Invoice_Approval__e invApproval = new Invoice_Approval__e();
                        invApproval.Invoice_Id__c = recId;
                        Database.SaveResult results = EventBus.publish(invApproval);
                        if (results.isSuccess()){
                            System.debug('Successfully published event.');
                        } else{
                            for (Database.Error err : results.getErrors()){
                                System.debug('Error returned: ' + err.getStatusCode() +' - ' + err.getMessage());
                            }
                        }
                        update invoiceRec;
                    }else if (m4.get('captured') == false){
                        invoiceRec.Status__c = 'Not realized';
                    }
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