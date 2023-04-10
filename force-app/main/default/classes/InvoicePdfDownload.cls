public without sharing class InvoicePdfDownload {
    @AuraEnabled
    public static void getInvoicePdf(string recordId){
        system.debug('recordId==>' +recordId);
        try{
            List<Attachment> attachmentList = new List<Attachment>();
            PageReference pageRef = page.RetailInvoice_Attachment;
            pageRef.getParameters().put('id',recordId);
            blob vBody;
            vBody=pageRef.getContent();
            Attachment attach = new Attachment();
            attach.Body = vBody;
            attach.Name = 'Retail Invoice.pdf';
            attach.ParentId = recordId;
            attach.ContentType = 'application/pdf';
            attachmentList.add(attach);
            if(!attachmentList.isEmpty()){
                insert attachmentList;
                system.debug('attachmentList==>' +attachmentList);
            }
        }Catch(Exception e){
            System.debug(' the Error has occured due to =====> ' + e.getMessage());
            System.debug(' the Error has occured at  =====> ' + e.getLineNumber());
            HandleBusinessException.captureError('InvoicePdfDownload','getInvoicePdf', e, null);
        }
    }
}