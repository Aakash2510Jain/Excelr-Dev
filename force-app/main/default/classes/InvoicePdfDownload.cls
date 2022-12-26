public class InvoicePdfDownload {
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
        }Catch(Exception ex){
                    system.debug('Error -->'+ex.getMessage());
                    system.debug('Error -->'+ex.getLineNumber());
                }
    }
}