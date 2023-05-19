public class PE_Invoice_Attachment {
    @future(callout=true)
    public static void makeCallout(List<string> newListOfEvents){
        for(String invoiceId : newListOfEvents){
            system.debug('invoiceAttRec.Invoice__c-->'+invoiceId);
            system.debug('Calling RetailInvoiceHelper');
            HttpRequest request = new HttpRequest();
            request.setEndpoint(system.label.endpointForInvoiceWebhook);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            
            // Set the request body as JSON
            String requestBody = '{"invoiceId":"'+invoiceId+'"}';
            request.setBody(requestBody);
            
            // Create an instance of Http
            Http http = new Http();
            HttpResponse response;
            
            try {
                // Send the request and get the response
                response = http.send(request);
                System.debug('Response Status: ' + response.getStatus());
                System.debug('Response Body: ' + response.getBody());
            } catch (Exception e) {
                System.debug('Exception: ' + e.getMessage());
            }
            // RetailInvoiceHelper.attachPdf(invoiceAttRec.Invoice__c);
        }
    }
}