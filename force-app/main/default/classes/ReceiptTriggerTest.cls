@isTest public class ReceiptTriggerTest {
    public static testMethod void testLeadRecClass() {
        Invoice__c invoiceRec = new Invoice__c();
        insert invoiceRec;
        Receipt__C receiptRec = new Receipt__C();
        receiptRec.Invoice__c = invoiceRec.id;
        insert receiptRec;
        receiptRec.Amount__c = 123;
        update receiptRec;
    }
    
}