trigger PE_Invoice_Attachment on Invoice_Attachment__e (after insert) {
    system.debug('After Insert');
    for(Invoice_Attachment__e invoiceAttRec : trigger.newMap.values()){
        system.debug('invoiceAttRec.Invoice__c-->'+invoiceAttRec.Invoice__c);
        RetailInvoiceHelper.attachPdf(invoiceAttRec.Invoice__c);
    }
}