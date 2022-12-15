public class InvoiceTriggerHelper{
    static InvoiceTriggerHelper handlerInstance;
    
    public static InvoiceTriggerHelper getInstance(){
        if (handlerInstance == null)
            handlerInstance = new InvoiceTriggerHelper();
        return handlerInstance;
    }
    public void beforeUpdate(Map<Id, Invoice__c> newMap, Map<Id, Invoice__c> oldMap){
        try{
            set<id> invoiceIds = new set<Id>();
            for (Invoice__c invoiceRec : newMap.values()){
                if (invoiceRec.Status__c != oldMap.get(invoiceRec.Id).Status__c && invoiceRec.Status__c == 'Realized'){
                    invoiceIds.add(invoiceRec.Id);
                }
            }
            if (!invoiceIds.isEmpty()){
                for (Id invoiceId : invoiceIds){
                    TaxInvoiceHelper.attachPdf(invoiceId);
                }
            }
        } catch (exception ex){
            system.debug('Errror-->' + ex.getMessage());
            system.debug('Errror-->' + ex.getCause());
            system.debug('Errror-->' + ex.getLineNumber());
            HandleBusinessException.captureError('InvoiceTriggerHelper', 'Tax Invoice', ex);
            
        }
    }
    
}