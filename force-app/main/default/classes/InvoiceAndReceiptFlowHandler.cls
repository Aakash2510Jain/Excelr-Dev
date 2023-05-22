public class InvoiceAndReceiptFlowHandler implements Queueable {
    public String invoiceId;
    
    public InvoiceAndReceiptFlowHandler(String invoiceId) {
        this.invoiceId = invoiceId;
        
        system.debug('insisde constructor<---invoiceId---> '+invoiceId);
                    
    }
    public void execute(QueueableContext context) {
        system.debug('Inside execute -->'+invoiceId);
        RetailInvoiceHelper.attachPdf(invoiceId);
    }
}