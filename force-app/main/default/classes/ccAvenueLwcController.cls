public class ccAvenueLwcController {
    
    
    @AuraEnabled
    Public Static String GettingPaymentLink(String recordId){
        
        try{
           
            Opportunity OppRec=[Select Id,Name,AccountId,Account.Name,Account.Email__c From Opportunity where Id=:recordId];
        
            EmailTemplate Etemplate = [Select id, Body from EmailTemplate where name = 'Cc Avenue Payment Link'];
            system.debug('Etemplate='+Etemplate);
            
            String TemplateBody=Etemplate.Body;
            system.debug('TemplateBody='+TemplateBody);
             
            string PaymentURL=DN_CCAvenue_CTRL.createPaymentURL(recordId);
            system.debug('PaymentURL='+PaymentURL);
            
            TemplateBody= TemplateBody.replace('{!PaymentURL}', PaymentURL);
            system.debug('TemplateBodyReplacedBody='+TemplateBody);
            
            TemplateBody=TemplateBody.replace(' {!Opportunity.Account}', OppRec.Account.Name);
            system.debug('TemplateBodyReplacedBodyName='+TemplateBody);
            
            //UtilityClasss(OppRec.Account.Email__c,Etemplate.id,TemplateBody);
            return 'SUCCESS';
            
        }
        catch(exception e){
            
             System.debug('The following exception has occurred: ' + e.getMessage());
             HandleBusinessException.captureError('ccAvenueLwcController','GettingPaymentLink', e, null);
            
             return e.getMessage();
        }
        
    }

    // call this method from paymentProcessLWC

    @AuraEnabled
    public static String initateCCAvenuePayment(String recId, long strUnixTimeStamp){
        System.debug(' strUnixTimeStamp ===> ' + strUnixTimeStamp);
        try{
        String name,email, ISMEmail;

        Invoice__c iv = getInvoice(recId);

 
        if(iv.Opportunity__c!=null){
            email = iv.Opportunity__r.Account.Email__c;
            ISMEmail = iv.Opportunity__r.Account.owner.Email;
            name = iv.Opportunity__r.Account.Name;
        }else if(iv.LeadInvoice__c!=null){
            email = iv.LeadInvoice__r.Email;
            ISMEmail = iv.LeadInvoice__r.owner.Email;
            name = iv.LeadInvoice__r.Name;
        }else{
            return 'Invoice is not tagged with opportunity neither lead';
        }

        Map<String,String> templateMap = getPaymentLinkTemplateId();
        Map<String,String> reqMap = getRequestMap(iv);
        String paymentURL = DN_CCAvenue_CTRL.createPaymentURLFromInvoice(iv,reqMap);

        return prepareTemplateAndSendEmail(templateMap,paymentURL,email,name,ISMEmail );

    } catch(exception e){
            
        System.debug('The following exception has occurred: ' + e.getMessage());
        HandleBusinessException.captureError('ccAvenueLwcController','initateCCAvenuePayment', e, null);
       
        return null;
   }
}

    public static Invoice__c getInvoice(String recId){
        try{
            Invoice__c invoiceREC = [Select Id,Name,Amount__c,Opportunity__c,Opportunity__r.Account.Name,Opportunity__r.Account.Email__c,Opportunity__r.Account.Phone,Opportunity__r.Account.BillingAddress,Opportunity__r.Account.Billingcity,Opportunity__r.Account.BillingStreet,Opportunity__r.Account.BillingState,Opportunity__r.Account.BillingCountry,Opportunity__r.Account.BillingPostalCode,
                                    Opportunity__r.Account.Shippingcity,Opportunity__r.Account.ShippingStreet,Opportunity__r.Account.ShippingAddress,Opportunity__r.Account.ShippingCountry,Opportunity__r.Account.ShippingPostalCode,Opportunity__r.Account.ShippingState, Opportunity__r.Account.owner.Email, LeadInvoice__r.owner.Email, Opportunity__r.Account.owner.Name,LeadInvoice__r.owner.Name,
                                     LeadInvoice__c,LeadInvoice__r.Name,LeadInvoice__r.Phone,LeadInvoice__r.Email,LeadInvoice__r.Street,LeadInvoice__r.city,LeadInvoice__r.Country,LeadInvoice__r.State,LeadInvoice__r.PostalCode,LeadInvoice__r.Address From Invoice__c Where Id=:recId];

            System.debug('invoiceREC ====> ' + invoiceREC);
        return invoiceREC;
    }catch(exception e){
            
        System.debug('The following exception has occurred: ' + e.getMessage());
        HandleBusinessException.captureError('ccAvenueLwcController','getInvoice', e, null);
       
        return null;
   }
}


    public static Map<String,String> getRequestMap(Invoice__c iv){
        try{
        Map<String,String> reqMap = new Map<String,String>();

        if(iv.Opportunity__c!=null){
            // account 

            reqMap.put('phone',iv.Opportunity__r.Account.Phone);
            reqMap.put('name',iv.Opportunity__r.Account.Name);
            reqMap.put('email',iv.Opportunity__r.Account.email__c);
            reqMap.put('billing_address',iv.Opportunity__r.Account.BillingAddress!=null ? String.valueOf(iv.Opportunity__r.Account.BillingAddress):'');
            reqMap.put('shipping_addres',iv.Opportunity__r.Account.ShippingAddress!=null ? String.valueOf(iv.Opportunity__r.Account.ShippingAddress!=null):'');
            reqMap.put('billing_city',iv.Opportunity__r.Account.BillingCity);
            reqMap.put('shipping_city',iv.Opportunity__r.Account.ShippingCity);
            reqMap.put('billing_street',iv.Opportunity__r.Account.BillingStreet);
            reqMap.put('billing_postal_code',iv.Opportunity__r.Account.BillingPostalCode);
            reqMap.put('shipping_postal_code',iv.Opportunity__r.Account.ShippingPostalCode);
            reqMap.put('billing_country',iv.Opportunity__r.Account.BillingCountry);
            reqMap.put('shipping_country',iv.Opportunity__r.Account.ShippingCountry);
        }else{
            //lead
            reqMap.put('phone',iv.LeadInvoice__r.Phone);
            reqMap.put('email',iv.LeadInvoice__r.email);
            reqMap.put('billing_address',iv.LeadInvoice__r.Address!=null ? String.valueOf(iv.LeadInvoice__r.Address):'');
            reqMap.put('shipping_addres',iv.LeadInvoice__r.Address!=null ? String.valueOf(iv.LeadInvoice__r.Address):'');
            reqMap.put('billing_city',iv.LeadInvoice__r.city);
            reqMap.put('shipping_city',iv.LeadInvoice__r.city);
            reqMap.put('billing_street',iv.LeadInvoice__r.Street);
            reqMap.put('shipping_state',iv.LeadInvoice__r.State);
            reqMap.put('billing_postal_code',iv.LeadInvoice__r.PostalCode);
            reqMap.put('shipping_postal_code',iv.LeadInvoice__r.PostalCode);
            reqMap.put('billing_country',iv.LeadInvoice__r.Country);
            reqMap.put('shipping_country',iv.LeadInvoice__r.Country);
            
            
        }


        return reqMap;
    }
     catch(exception e){
            
        System.debug('The following exception has occurred: ' + e.getMessage());
        HandleBusinessException.captureError('ccAvenueLwcController','getRequestMap', e, null);
       
        return null;
   }
}

    public static Map<String,String> getPaymentLinkTemplateId(){
        try{
        Map<String,String> respMap = new Map<String,String>();

        EmailTemplate eTemplate = [Select id,body from EmailTemplate where name = 'Cc Avenue Payment Link'];
        respMap.put('id',eTemplate.Id);
        respMap.put('body',eTemplate.body);

        return respMap;
    }catch(exception e){
            
        System.debug('The following exception has occurred: ' + e.getMessage());
        HandleBusinessException.captureError('ccAvenueLwcController','getPaymentLinkTemplateId', e, null);
       
        return null;
   }
}

    public static String prepareTemplateAndSendEmail(Map<String,String> templateMap, String paymentUrl,String email, String name, string ISMEmail){
        try{
            String emailBody = templateMap.get('body');
            String templateId = templateMap.get('id');

            emailBody = emailBody.replace('{!PaymentURL}', paymentUrl);
            emailBody = emailBody.replace(' {!Opportunity.Account}', name);

            sendPaymentLink(email,templateId,emailBody, ISMEmail);
            return 'Success';
        }catch(Exception e){
            System.debug(' the Error has occured due to =====> ' + e.getMessage());
            System.debug(' the Error has occured at  =====> ' + e.getLineNumber());
            HandleBusinessException.captureError('ccAvenueLwcController','prepareTemplateAndSendEmail', e, null);
            return  null;
        }
    }

   
    Public Static void sendPaymentLink( String email,String templateId,String body, string ISMEmail){
        try{
        Messaging.SingleEmailMessage EmailMessage = new Messaging.SingleEmailMessage();
        EmailMessage.toAddresses = new String[] {email};
        EmailMessage.setBccAddresses(new String[]{ISMEmail});
        EmailMessage.subject = 'CcAvenue Payment Initiated';
        EmailMessage.plainTextBody = body;
        EmailMessage.setTemplateId(templateId);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{EmailMessage});
    }catch(Exception e){
        System.debug(' the Error has occured due to =====> ' + e.getMessage());
        System.debug(' the Error has occured at  =====> ' + e.getLineNumber());
        HandleBusinessException.captureError('ccAvenueLwcController','sendPaymentLink', e, null);
        
    }
}

}