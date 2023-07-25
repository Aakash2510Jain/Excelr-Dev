public class ReceiptTriggerHelper {
    static ReceiptTriggerHelper handlerInstance;
    
    public static ReceiptTriggerHelper getInstance(){
        if (handlerInstance == null)
            handlerInstance = new ReceiptTriggerHelper();
        return handlerInstance;
    }
     public void beforeUpdate(Map<Id, Receipt__c> newMap, Map<Id,Receipt__c> oldmap){
         
        for(Receipt__c receiptRecord : newMap.values()){
             if(receiptRecord.Receipt_Status__c != oldmap.get(receiptRecord.Id).Receipt_Status__c && receiptRecord.Receipt_Status__c != null && receiptRecord.Receipt_Status__c == 'Received/Paid'){
                if(receiptRecord.Payment_Realized_Date_Time__c == null)
                    receiptRecord.Payment_Realized_Date_Time__c = system.now();
            }
        }
     }
    public void afterUpdate(Map<Id, Receipt__c> newMap, Map<Id,Receipt__c> oldmap){
        system.debug('Receipt Helper after update');
        set<Id> receiptIds = new Set<Id>();
        set<Id> secondReceiptId = new set<Id>();
        set<Id> InvoiceIds = new set<Id>();
        List<Receipt__c> updateReceiptsList = new List<Receipt__c>();
        List<Invoice__c> invoiceRecordsToUpdate = new List<Invoice__c>();
        List<Invoice__c> invoiceRecordsList = new List<Invoice__c>();
        Map<String, Receipt__c> MapOfINvoiceIdWithReceipts = new Map<String, Receipt__c>();
        
        for(Receipt__c receiptRecord : newMap.values()){
            InvoiceIds.add(receiptRecord.Invoice__c);
            MapOfINvoiceIdWithReceipts.put(receiptRecord.Invoice__c, receiptRecord);
            if(receiptRecord.Receipt_Status__c != oldmap.get(receiptRecord.Id).Receipt_Status__c && receiptRecord.Receipt_Status__c != null && receiptRecord.Receipt_Status__c == 'Received/Paid'){// && receiptRecord.Is_Pending_Receipt__c == false ){
                system.debug('Receipt status is updated as Received -- '+receiptIds);
                receiptIds.add(receiptRecord.Id);
                
            }
             if(receiptRecord.Receipt_Status__c != oldmap.get(receiptRecord.Id).Receipt_Status__c && receiptRecord.Receipt_Status__c != null && receiptRecord.Receipt_Status__c == 'Received/Paid' && receiptRecord.Is_Pending_Receipt__c == true ){
                 system.debug('Receipt status is updated as Received -- '+receiptIds);
                // secondReceiptId.add(receiptRecord.Id);
             }
        }

        if (!InvoiceIds.isEmpty()) {

            invoiceRecordsList = [Select Id, Do_Not_Send_Invoice__c, Status__c, LeadInvoice__c, LeadInvoice__r.Owner.UserRoleId, Lead_ManagerId__c, Opportunity__c, Opportunity__r.Owner.UserRoleId, Amount__c, LeadInvoice__r.Owner.Name, LeadInvoice__r.Owner.Email, Opportunity__r.Owner.Email, Opportunity__r.Owner.Name, Payment_Type__c, Realized_Amount__c, Due_Amount__c
                                    From Invoice__c
                                    Where Id IN : InvoiceIds];
            if (!invoiceRecordsList.isEmpty() && invoiceRecordsList.size() >0) {
                for (Invoice__c inv : invoiceRecordsList) {
                    Invoice__c invupdated = new Invoice__c();
                    invupdated.Id = inv.id;
                    if (inv.Due_Amount__c != null && !MapOfINvoiceIdWithReceipts.isEmpty() && MapOfINvoiceIdWithReceipts.containsKey(inv.id)) {
                        invupdated.Due_Amount__c = inv.Due_Amount__c - MapOfINvoiceIdWithReceipts.get(inv.id).Invoice_Realized_Amount__c;
                        invupdated.Initiated_Amount__c = 0;
                    }
                    else {
                        invupdated.Due_Amount__c = inv.Amount__c = MapOfINvoiceIdWithReceipts.get(inv.id).Invoice_Realized_Amount__c;
                        invupdated.Initiated_Amount__c = 0;
                    }
                    invoiceRecordsToUpdate.add(invupdated);
                }
                
            }
            if (!invoiceRecordsToUpdate.isEmpty()) {
               // update invoiceRecordsToUpdate;
            }
            
        }
        system.debug('receiptIds--->'+receiptIds);
        if(!receiptIds.isEmpty()){
            system.debug('Calling Receipt PDf');
            Invoice_Receipt_PDF_Controller.attachReceiptUnderRecord(receiptIds);
        }
         if(!secondReceiptId.isEmpty()){
            system.debug('Calling Receipt PDf');
            Invoice_Receipt_PDF_Controller.attachSecondReceiptUnderRecord(secondReceiptId);
        }
        
    }
     public void handleSecondReceipt(Map<Id, Receipt__c> newMap, Map<Id,Receipt__c> oldmap){
        system.debug('Receipt Helper before update');
         Set<id> invoiceIds = new Set<Id>();
         List<Invoice__c> invoiceList = new List<Invoice__c>();
         List<Receipt__c> receiptListToUpdate = new List<Receipt__C>();
         
         for(Receipt__c receiptRecord : newMap.values()){
             if(receiptRecord.Receipt_Status__c != oldmap.get(receiptRecord.Id).Receipt_Status__c && receiptRecord.Receipt_Status__c != null && receiptRecord.Receipt_Status__c == 'Received/Paid' && receiptRecord.Invoice_Type__c == 'Loan'){
                 invoiceIds.add(receiptRecord.Invoice__c);
             }
         }
         if(!invoiceIds.isEmpty()){
             invoiceList = [Select id,(Select Id,Is_Pending_Receipt__c,Receipt_Status__c From Receipts__r where Receipt_Status__c != 'Received/Paid') From Invoice__c where Id in: invoiceIds];
             if(!invoiceList.isEmpty()){
                 for(Invoice__c invoiceRec : invoiceList){
                     if(!invoiceRec.Receipts__r.isEmpty()){
                         for(Receipt__c receiptRec : invoiceRec.Receipts__r){
                             Receipt__c receiptRecToUpdate = new Receipt__c();
                             receiptRecToUpdate.Id = receiptRec.Id;
                             receiptRecToUpdate.Is_Pending_Receipt__c = true;
                             receiptListToUpdate.add(receiptRecToUpdate);
                         }
                     }
                 }
                 if(!receiptListToUpdate.isEmpty()){
                     update receiptListToUpdate;
                 }
             }
         }
    }
}