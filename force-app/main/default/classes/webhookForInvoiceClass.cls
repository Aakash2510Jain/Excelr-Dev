@RESTResource(urlMapping = '/webhookForInvoice/*')
global without sharing class webhookForInvoiceClass {
    @HttpPost
    global static String WebhookListener(){
                
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String body = req.requestBody.toString();
        Map<String, Object> requestBodyMap = (Map<String, Object>) JSON.deserializeUntyped(body);
        
        String invoiceId = (String) requestBodyMap.get('invoiceId');
        system.debug('invoiceId-->'+invoiceId);
        
        RetailInvoiceHelper.attachPdf(invoiceId);
        return 'Success';
    }
}