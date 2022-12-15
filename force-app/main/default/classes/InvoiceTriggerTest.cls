@isTest     
public class InvoiceTriggerTest{
     
    public static testMethod void updateInvoice(){

         Invoice__c invRec  = new Invoice__c();
        invRec.Status__c = 'Initiated';
        insert invRec;

        invRec.Status__c = 'Realized';
        Update invRec;
    }
}