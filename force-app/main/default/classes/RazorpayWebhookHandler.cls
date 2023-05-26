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
                    
                    Invoice__c invoiceRec = [Select Id, Status__c,LeadInvoice__c,LeadInvoice__r.Owner.UserRoleId,Lead_ManagerId__c,Opportunity__c,Opportunity__r.Owner.UserRoleId,Amount__c,
                                             LeadInvoice__r.Owner.Name, LeadInvoice__r.Owner.Email, Opportunity__r.Owner.Email, Opportunity__r.Owner.Name,Payment_Type__c,Realized_Amount__c, Due_Amount__c,
                                             (SELECT Amount__c,CreatedDate,Id,Receipt_Status__c,Invoice__c,Name FROM Receipts__r ORDER BY CreatedDate DESC)
                                             From Invoice__c
                                             Where Opportunity__c = :recId
                                             ORDER BY CreatedDate DESC
                                             limit 1];
                    if (m4.get('captured') == true){
                        Receipt__c receipt = new Receipt__c();
                        for(Receipt__c receiptRec : invoiceRec.Receipts__r){
                            if(receiptRec.Receipt_Status__c == 'Link Sent'){
                                receipt.id = receiptRec.Id;
                                //receipt.Receipt_Status__c = Constants.RECEIPT_STATUS_RECEIVED_PAID;
                                receipt.TranactionId__c = String.ValueOf(m4.get('id'));
                                //receipt.Invoice__c = invoiceRec.id; 
                                //receipt.Payment_Realized_Date_Time__c = System.now();
                                //receipt.amount__c = Integer.valueOf(String.ValueOf(m4.get('amount')))/100;
                            }
                        }
                        update receipt;
                        
                        system.debug('recId--->'+recId);
                        Receipt_Approval__e receiptApprovalRecord = new Receipt_Approval__e();
                        receiptApprovalRecord.Opportunity_Id__c = recId;//instead of Invoice we are passing opportunity Id
                        Database.SaveResult results = EventBus.publish(receiptApprovalRecord);
                        if (results.isSuccess()){
                            System.debug('Successfully published event.');
                        } else{
                            for (Database.Error err : results.getErrors()){
                                System.debug('Error returned: ' + err.getStatusCode() +' - ' + err.getMessage());
                            }
                        }
                        invoiceRec.Payment_Realized_Date_Time__c = System.now();
                        if ( invoiceRec.Payment_Type__c == Constants.INVOICE_PAYMENT_TYPE_PARTIALPAYMENT ) {
                            if (invoiceRec.Due_Amount__c != 0 && invoiceRec.Due_Amount__c != null) {
                                invoiceRec.Due_Amount__c = invoiceRec.Due_Amount__c - (Integer.ValueOf(m4.get('amount')))/100;
                            }else if (invoiceRec.Due_Amount__c == 0 ||invoiceRec.Due_Amount__c == null ){
                                invoiceRec.Due_Amount__c = invoiceRec.Amount__c - (Integer.ValueOf(m4.get('amount')))/100;
                            }
                            
                            if (invoiceRec.Realized_Amount__c == null ) {
                               // invoiceRec.Realized_Amount__c =  (Integer.ValueOf(m4.get('amount')))/100;
                            }
                            else {
                               // invoiceRec.Realized_Amount__c = invoiceRec.Realized_Amount__c + (Integer.ValueOf(m4.get('amount')))/100;                            
                            }
                            if ((invoiceRec.Due_Amount__c).round() == 0 && (invoiceRec.Realized_Amount__c).round() == (invoiceRec.Amount__c).round()	) {
                                invoiceRec.Status__c = Constants.INVOICE_STATUS_RECEIVED_PAID;                       
                            }
                            else {
                                invoiceRec.Status__c = Constants.INVOICE_STATUS_PARTIALLYPENDING;                                
                            }
                        }
                        else if ( invoiceRec.Payment_Type__c == Constants.INVOICE_PAYMENT_TYPE_FULLPAYMENT ){
                            invoiceRec.Due_Amount__c = 0;
                            invoiceRec.Status__c = Constants.INVOICE_STATUS_RECEIVED_PAID;
                            if (invoiceRec.Realized_Amount__c == null ) {
                              //  invoiceRec.Realized_Amount__c =  (Integer.ValueOf(m4.get('amount')))/100;
                            }
                            else {
                             //   invoiceRec.Realized_Amount__c = invoiceRec.Realized_Amount__c + (Integer.ValueOf(m4.get('amount')))/100;                            
                            }
                            if (invoiceRec.Due_Amount__c == 0 && invoiceRec.Realized_Amount__c == invoiceRec.Amount__c	) {
                                invoiceRec.Status__c = Constants.INVOICE_STATUS_RECEIVED_PAID;                       
                            }
                            else {
                                invoiceRec.Status__c = Constants.INVOICE_STATUS_PARTIALLYPENDING;                                
                            }
                            
                        }
                        invoiceRec.Initiated_Amount__c = 0;
                        System.debug('invoiceRec =====> ' + invoiceRec);
                        update invoiceRec;
                        Opportunity Opprec = new Opportunity();
                        Opprec.Id = recId;
                        if (invoiceRec.Due_Amount__c != null && invoiceRec.Due_Amount__c != 0 ) {
                            Opprec.Due_Amount__c = invoiceRec.Due_Amount__c;
                            opprec.Approval_Status__c = 'Under Payment Approval';
                        }
                        else if(invoiceRec.Due_Amount__c == 0 ) {
                            Opprec.Due_Amount__c = 0;
                            opprec.Approval_Status__c = 'Payment Approved';
                            //Opprec.stagename = Constants.OPP_STAGENAME_CLOSE_WON;
                            opprec.Upfront_Amount__c = 0;
                        }
                        update opprec;
                        
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