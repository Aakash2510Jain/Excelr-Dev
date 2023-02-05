@isTest     
public class InvoiceTriggerTest{
     
    public static testMethod void updateInvoice(){
     try{
         Invoice__c invRec  = new Invoice__c();
        invRec.Status__c = 'Initiated';
        insert invRec;

        invRec.Status__c = 'Realized';
        Update invRec;
    } catch (Exception e){
        system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
      HandleBusinessException.captureError('InvoiceTriggerTest', 'updateInvoice', e , null);
       
    }
}

}