global without sharing class ScheduleBatchForPendingInvoiceReminder implements Schedulable{
    global void execute(SchedulableContext SC){ 
        BatchForPendingInvoiceReminder batchInstance = new BatchForPendingInvoiceReminder();
        database.executeBatch(batchInstance, 20);
    }
}