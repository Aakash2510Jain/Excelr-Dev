@RESTResource(urlMapping = '/razorpayWebhook/*')
global without sharing class RazorpayWebhookHandler{
    @HttpPost
    global static String webhookListener(){
        try{
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            
            String body = req.requestBody.toString();
            System.debug('body =====> ' + body);
            
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
                    
                    Invoice__c invoiceRec = [Select Id, Status__c,LeadInvoice__c,LeadInvoice__r.Owner.UserRoleId,Lead_ManagerId__c,Opportunity__c,Opportunity__r.Owner.UserRoleId,
                                            LeadInvoice__r.Owner.Name, LeadInvoice__r.Owner.Email, Opportunity__r.Owner.Email, Opportunity__r.Owner.Name,
                                            (SELECT Amount__c,CreatedDate,Id,Invoice__c,Name FROM Receipts__r)
                                             From Invoice__c
                                             Where Opportunity__c = :recId
                                             ORDER BY CreatedDate DESC
                                             limit 1];
                    if (m4.get('captured') == true){
                        Receipt__c receipt = new Receipt__c();
                        receipt.id = invoiceRec.Receipts__r[0].Id;
                        receipt.Invoice__c = invoiceRec.id; // 
                        receipt.amount__c = Integer.valueOf(String.ValueOf(m4.get('amount')));
                        update receipt;

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
                        System.debug('m.containsKey(created_at) =====> ' +  m.containsKey('created_at'));
                        // if (m.containsKey('created_at')) {
                        //     string strunixtime = String.valueof(m.get('created_at'));
                        //     Long longUnixTimeStamp = Long.valueOf( strunixtime );
                        //     System.debug ( 'DateTime.newInstance( longUnixTimeStamp ) ====> ' +longUnixTimeStamp );
                        //     invoiceRec.Payment_Realized_Date_Time__c = DateTime.newInstance( longUnixTimeStamp );
                        // }
                        invoiceRec.Payment_Realized_Date_Time__c = System.now();
                        System.debug('invoiceRec =====> ' + invoiceRec);
                        update invoiceRec;

                        if (invoiceRec.id != null) {
                            Utility.SendSuccessOrFailureEmailToISM(invoiceRec.id, Constants.PAYMENT_STATUS_SUCCESS);
                        }
                    }else if (m4.get('captured') == false){
                        invoiceRec.Status__c = 'Not realized';
                        Utility.SendSuccessOrFailureEmailToISM(invoiceRec.id, Constants.PAYMENT_STATUS_FAILURE);
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