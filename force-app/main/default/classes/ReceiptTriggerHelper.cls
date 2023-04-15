public class ReceiptTriggerHelper {
    static ReceiptTriggerHelper handlerInstance;
    
    public static ReceiptTriggerHelper getInstance(){
        if (handlerInstance == null)
            handlerInstance = new ReceiptTriggerHelper();
        return handlerInstance;
    }
    public void afterUpdate(Map<Id, Receipt__c> newMap, Map<Id,Receipt__c> oldmap){
        system.debug('Receipt Helper after update');
        set<Id> receiptIds = new Set<Id>();
        List<Receipt__c> updateReceiptsList = new List<Receipt__c>();
        List<Invoice__c> invoiceRecordsToUpdate = new List<Invoice__c>();
        
        for(Receipt__c receiptRecord : newMap.values()){
            if(receiptRecord.Receipt_Status__c != oldmap.get(receiptRecord.Id).Receipt_Status__c && receiptRecord.Receipt_Status__c != null && receiptRecord.Receipt_Status__c == 'Received/Paid'){
                system.debug('Receipt status is updated as Received -- '+receiptIds);
                receiptIds.add(receiptRecord.Id);
            }
        }
        system.debug('receiptIds--->'+receiptIds);
        if(!receiptIds.isEmpty()){
            system.debug('Calling Receipt PDf');
            Invoice_Receipt_PDF_Controller.attachReceiptUnderRecord(receiptIds);
        }
    }
}