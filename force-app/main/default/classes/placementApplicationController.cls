/*Author : Isha Raaz */


public without sharing class placementApplicationController {
    public placementApplicationController() {

    }
    
    @AuraEnabled(cacheable=true)
    public static List<Placement_Application__c> getAllApplications(string oppId){
        system.debug('oppId  -- > ' + oppId);
        List<Placement_Application__c> placementApplicationList = new List<Placement_Application__c>();
        try{
            placementApplicationList = [SELECT Id, Contact__c, Aptitude_Marks__c, Aptitude_Result__c, GD_Result__c, Personal_Interview_Result__c, Remarks__c FROM Placement_Application__c WHERE Opportunity__c	=: oppId AND Placement_Paid_Service_Status__c = 'Interested'];
            system.debug('placementApplicationList  -- > ' + placementApplicationList);
        }
        catch(Exception e){
            system.debug('getAllApplications Method Error -- ' + e.getMessage());
            system.debug('AT LINE NO -- ' + e.getLineNumber());
        }
        return placementApplicationList;
    }
    
    @AuraEnabled
    public static string submitAllStudentApplications(List<Id> contactIdList, string programId){
        system.debug('contactIdList  -- > ' + contactIdList);
        string result = '';
        try{
            Program__c prgm = [SELECT Id FROM Program__c WHERE Id =: programId];
            List<Contact> conList = [SELECT Id, Name, AccountId, Account.Name FROM Contact WHERE Id IN: contactIdList];
            List<Lead> ldListToBeInserted = new List<Lead>();
            for(Contact con : conList){
                Lead ld = new Lead();
                ld.FirstName = con.Account.Name;
                ld.LastName = '-Opportunity';
                ld.Status = 'New';
                ldListToBeInserted.add(ld);
            }
            Database.insert(ldListToBeInserted,true);
            
            set<Id> ldIdSet = new set<Id>();
            for(Lead ld : ldListToBeInserted){
                ldIdSet.add(ld.Id);
            }
            system.debug('ldIdSet -- ' + ldIdSet);
            result = 'Success';            
        }
        catch(Exception e){
            system.debug('getAllApplications Method Error -- ' + e.getMessage());
            system.debug('AT LINE NO -- ' + e.getLineNumber());
            result = e.getMessage();
        }
        return result;
    }
    

    public static String sendEmailToAllContacts(List<Id> listOfOppIds){
        try{
            system.debug('listOfOppIds ==> '+listOfOppIds);

            BatchToSendRazorPayPaymentLink batchClass = new BatchToSendRazorPayPaymentLink(listOfOppIds);
            Database.executeBatch(batchClass,1);

            return 'SUCCESS';
        }catch(Exception e){
            system.debug('Error Message ==> '+e.getMessage()+e.getLineNumber());
            return e.getMessage()+e.getLineNumber();
        }
    }


    /* SEND RAZOR PAY PAYMENT LINK METHOD */

    public static String sendPaymentLink(List<Id> listOfOpportunityIds){ 
        system.debug('Inside Payment Link !!');
        if(!listOfOpportunityIds.isEmpty()){
           
            List<Opportunity> oppList = [Select Id,Name,Amount,Email__c,Phone__c,AccountId,Account.Email__c,Account.Name,Account.Phone From Opportunity Where Id IN :listOfOpportunityIds];
            system.debug('oppList ==> '+oppList);

            List<RazorpayRequestJSON> razorpayRequestList = new List<RazorpayRequestJSON>();

            for(Opportunity opp : oppList){
                if(opp.AccountId==null){
                    return 'Account is not tagged';
                }
                
                if(String.isEmpty(opp.Email__c)){
                    return 'Account email is empty';
                }
                
                if(String.isEmpty(opp.Phone__c)){
                    return 'Account phone is empty';
                }
                
                if(opp.Amount == null){
                    return 'Amount is empty';
                }
            }
            
            try {
                for (Opportunity opp : oppList){
                    RazorpayRequestJSON razorpayRequestJSON = new RazorpayRequestJSON();
                
                    razorpayRequestJSON.amount = opp.Amount;
                    razorpayRequestJSON.first_min_partial_amount = opp.Amount;
                    razorpayRequestJSON.setCustomer(opp.Name,opp.Phone__c,opp.Email__c);
                    razorpayRequestJSON.setNotes(opp.Id,opp.Id);
                    razorpayRequestList.add(razorpayRequestJSON);
                }
                system.debug('razorpayRequestList ==> '+razorpayRequestList);
                
                String body = JSON.serialize(razorpayRequestList);
                body = body.replace('currencyType','currency');
                
                System.debug('Body---'+body);
                
                HTTP http = new HTTP();
                HttpRequest req = new HttpRequest();
                
                req.setHeader('Content-Type', 'application/json');
                req.setEndpoint('callout:RazorPay');
                req.setMethod('POST');
                req.setBody(body);
                
                HTTPResponse res = http.send(req);
                if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
                    Map<String,Object> jsonBody = (Map<String,Object>) Json.deserializeUntyped(res.getBody());
                
                    System.debug('RESPPPP'+jsonBody);
                }
                else {
                    system.debug('res ====> ' + res);
                }
                
                return 'Success';     
            }
            catch (Exception e) {
                System.debug(' the Error has occured due to =====> ' + e.getMessage());
                System.debug(' the Error has occured at  =====> ' + e.getLineNumber());
                HandleBusinessException.captureError('RazorpayPaymentHandler','sendPaymentLink', e, null);
                throw new AuraHandledException(e.getMessage());
            }
        }else{
            return 'Record Id not found';
        }
    }
    
    
    
    public static String initateRazorpayPament(String recId, long expirydateString){

        System.debug(' expirydateString ===> ' + expirydateString);
        try{
            Invoice__c iv = [Select Id,Name,Amount__c,Payment_Type__c,Opportunity__c,Opportunity__r.Email__c,Opportunity__r.Phone__c,Opportunity__r.Account.Name,Opportunity__r.Account.Email__c,Opportunity__r.Account.Phone,LeadInvoice__c,LeadInvoice__r.Name,LeadInvoice__r.Phone,LeadInvoice__r.Email,
                            (SELECT Amount__c,Id,Invoice__c,Name,Receipt_Status__c FROM Receipts__r order by createdDate DESC)
                            From Invoice__c Where Id=:recId];
            
            String email;
            String contact;
            String name;
            String ISMEmail;
            Decimal amount = 0.0;
            system.debug('iv.Payment_Type__c---->'+iv.Payment_Type__c);
                if (iv.Payment_Type__c == Constants.INVOICE_PAYMENT_TYPE_FULLPAYMENT) {
                    if(iv.Amount__c != null){
                        amount = iv.Amount__c;   
                    }
                }
                if (iv.Payment_Type__c == Constants.INVOICE_PAYMENT_TYPE_PARTIALPAYMENT) {
                    if (!iv.Receipts__r.isempty() && iv.Receipts__r.size() >0) {
                        for(Receipt__c receipt : iv.Receipts__r){
                            if (receipt.Receipt_Status__c == Constants.RECEIPT_STATUS_LINKSENT) {
                                amount = receipt.Amount__c ; 
                            }
                        }                       
                    }
                }
                
            
            String objName = '';
            String triggeredRecordId;
            
            
            if(iv.Opportunity__c!=null){
                email = iv.Opportunity__r.Email__c;
                contact = iv.Opportunity__r.Phone__c;
                name = iv.Opportunity__r.Account.Name;
                objName = 'Opportunity';
                triggeredRecordId = iv.Opportunity__c;
            }else if(iv.LeadInvoice__c!=null){
                email = iv.LeadInvoice__r.Email;
                contact = iv.LeadInvoice__r.Phone;
                name = iv.LeadInvoice__r.Name;
                objName = 'Lead';
                triggeredRecordId = iv.LeadInvoice__c;
            }else{
                return 'Invoice is not tagged with opportunity neither lead';
            }
            
            if(String.isEmpty(email)) return 'Email is empty';
            if(String.isEmpty(contact)) return 'Phone is empty';
            if(amount==null) return 'Amount is empty';
            
            
            razorpayPaymentHandler(triggeredRecordId,name,contact,email,amount,objName, recId, expirydateString);
            
            return 'Success';
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('RazorpayPaymentHandler', 'initateRazorpayPament', e , null);
            return null;
        }
    }
    
    
    @future(callout=true)
    public static void razorpayPaymentHandler(String recId, String name,String contact, String email, Decimal amount,String objName, string invrecID, Long expirydateString){
        System.debug(' expirydateString ===> ' + expirydateString);
        try {
            
            razorpayRequestJSON razorpayRequestJSON = new RazorpayRequestJSON();
            amount = amount*100;
            razorpayRequestJSON.amount = amount;
            razorpayRequestJSON.first_min_partial_amount = amount;
            razorpayRequestJSON.expire_by = expirydateString;  //"expire_by": 1691097057,  "expired_at": 0,
           
            razorpayRequestJSON.setCustomer(name,contact,email);
            razorpayRequestJSON.setNotes(recId,objName);
            
            String body = JSON.serialize(razorpayRequestJSON);
            body = body.replace('currencyType','currency');
            
            System.debug('Body---'+body);
            
            HTTP http = new HTTP();
            HttpRequest req = new HttpRequest();
            
            req.setHeader('Content-Type', 'application/json');
            req.setEndpoint('callout:RazorPay');
            req.setMethod('POST');
            req.setBody(body);
            
            HTTPResponse res = http.send(req);
            System.debug('res ===> ' + res);
            Map<String,Object> jsonBody = (Map<String,Object>) Json.deserializeUntyped(res.getBody());
            
            System.debug('RESPPPP ====> '+jsonBody);
            string PaymentUrl = String.valueof(jsonBody.get('short_url'));
            System.debug('PaymentUrl ======> '+ PaymentUrl);

            
            System.debug('invrecID-->'+invrecID);

            if (PaymentUrl != null && invrecID != null ) {
                //Utility.SendPaymentLinkToISM( invrecID, PaymentUrl);
                Receipt__c receiptRec = [Select Id,Payment_Link__c From Receipt__c where Type__c = 'RazorPay' and Receipt_Status__c = 'Link Sent' limit 1];
                receiptRec.Payment_Link__c = PaymentUrl;
                update receiptRec;
            }
        }
        catch (Exception e) {
            System.debug(' the Error has occured due to =====> ' + e.getMessage());
            System.debug(' the Error has occured at  =====> ' + e.getLineNumber());
            HandleBusinessException.captureError('RazorpayPaymentHandler','sendPaymentLink', e, null);
            throw new AuraHandledException(e.getMessage());
        }
    }
}