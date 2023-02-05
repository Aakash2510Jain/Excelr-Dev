public with sharing class RazorpayPaymentHandler {
    
    public static String sendPaymentLink(String recordId){ //invoice id will come here

        if(!String.isBlank(recordId)){

            // 1) Query particular invoice with lead and opp;
            // 2) check if invoice is related with lead or opp and pass the value under email,contact,name,amount;
            // 3) 

            Opportunity opp = [Select Id,Name,Amount,AccountId,Account.Email__c,Account.Name,Account.Phone From Opportunity Where Id=:recordId];

            String email;
            String contact;
            String name;
            Decimal amount;

            if(opp.AccountId==null){
                return 'Account is not tagged';
            }

            if(opp.AccountId!=null && String.isEmpty(opp.Account.Email__c)){
                return 'Account email is empty';
            }

            if(String.isEmpty(opp.Account.Phone)){
                return 'Account phone is empty';
            }

            if(opp.Amount == null){
                return 'Amount is empty';
            }


            email = opp.Account.Email__c;
            contact = opp.Account.Phone;
            name = opp.Account.Name;
            amount = opp.Amount*100;

            try {
                RazorpayRequestJSON razorpayRequestJSON = new RazorpayRequestJSON();

                razorpayRequestJSON.amount = amount;
                razorpayRequestJSON.first_min_partial_amount = amount;
                razorpayRequestJSON.setCustomer(name,contact,email);
                razorpayRequestJSON.setNotes(recordId,opp.Id);

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
                Map<String,Object> jsonBody = (Map<String,Object>) Json.deserializeUntyped(res.getBody());

                System.debug('RESPPPP'+jsonBody);

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


    
    public static String initateRazorpayPament(String recId){
        try{
        Invoice__c iv = [Select Id,Name,Amount__c,Opportunity__c,Opportunity__r.Account.Name,Opportunity__r.Account.Email__c,Opportunity__r.Account.Phone,LeadInvoice__c,LeadInvoice__r.Name,LeadInvoice__r.Phone,LeadInvoice__r.Email From Invoice__c Where Id=:recId];

        String email;
        String contact;
        String name;
        Decimal amount = iv.Amount__c * 100;

        String objName = '';
        String triggeredRecordId;

        
        if(iv.Opportunity__c!=null){
            email = iv.Opportunity__r.Account.Email__c;
            contact = iv.Opportunity__r.Account.Phone;
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


        razorpayPaymentHandler(triggeredRecordId,name,contact,email,amount,objName);

        return 'Success';
    } catch (Exception e){
        system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
      HandleBusinessException.captureError('RazorpayPaymentHandler', 'initateRazorpayPament', e , null);
       return null;
    }
}


    @future(callout=true)
    public static void razorpayPaymentHandler(String recId, String name,String contact, String email, Decimal amount,String objName){
        try {

            RazorpayRequestJSON razorpayRequestJSON = new RazorpayRequestJSON();

            razorpayRequestJSON.amount = amount;
            razorpayRequestJSON.first_min_partial_amount = amount;
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
            Map<String,Object> jsonBody = (Map<String,Object>) Json.deserializeUntyped(res.getBody());

            System.debug('RESPPPP'+jsonBody);

           // return 'Success';     
        }
        catch (Exception e) {
            System.debug(' the Error has occured due to =====> ' + e.getMessage());
            System.debug(' the Error has occured at  =====> ' + e.getLineNumber());
            HandleBusinessException.captureError('RazorpayPaymentHandler','sendPaymentLink', e, null);
            throw new AuraHandledException(e.getMessage());
        }
    }
}