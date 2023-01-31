public class ManualpaymentController {
    
    @AuraEnabled
    public Static Opportunity ManualpaymentcreateInvoice(String recordId){
        Opportunity oppRec = [SELECT Id,Name,Amount,Payment_Type__c,Due_Amount__c FROM Opportunity WHERE ID =:recordId];
        
        // Invoice__c inv = [SELECT Id,Name,Opportunity__c,Opportunity__r.Amount,Amount__c,Status__c,Type__c FROM Invoice__c WHERE Opportunity__c=:oppRec.Id];
        System.debug('Inoice Record ::'+oppRec);
        return oppRec;
    }
    
    @AuraEnabled
    public Static List<String> getPickListValuesMethod(String ObjectApi_name, String Field_Name){
        try{
            List<String> lstPickvals                        = new List<String>();
            Schema.SObjectType targetType                   = Schema.getGlobalDescribe().get(ObjectApi_name);
            Sobject Object_name                             = targetType.newSObject();
            Schema.sObjectType sobject_type                 = Object_name.getSObjectType(); 
            Schema.DescribeSObjectResult sobject_describe   = sobject_type.getDescribe();
            Map<String, Schema.SObjectField> field_map      = sobject_describe.fields.getMap();
            List<Schema.PicklistEntry> pick_list_values     = field_map.get(Field_Name).getDescribe().getPickListValues();
            
            for (Schema.PicklistEntry a : pick_list_values) {
                lstPickvals.add(String.ValueOf(a.getLabel()).trim());  
            }
            System.debug('lstPickvals>>>> ::'+lstPickvals);
            return lstPickvals;
        }Catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return null;
    }
    
    @AuraEnabled
    public static Id SaveFile(Id parentId, String fileName, String base64Data, String contentType) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        Attachment attach = new Attachment();
        attach.parentId = parentId;
        attach.Body = EncodingUtil.base64Decode(base64Data);
        attach.Name = fileName;
        attach.ContentType = contentType;
        Insert attach;
        return attach.Id;
    }
    
    @AuraEnabled
    public static  Invoice__c insertInvoiceBasedOppAmount(Decimal insertingInvAmount,String oppId,  String description){
        List<Invoice__c> invoiceListToInsert = new List<Invoice__c>();
        Invoice__c invoiceRecToReturn = new Invoice__c();
        Decimal remaingAmount = 0.0;
                
        System.debug('insertingInvAmount ::'+insertingInvAmount);
        
        Opportunity oppRec = [SELECT Id,Name,Amount,Due_Amount__c FROM Opportunity WHERE ID =: oppId];
        System.debug('oppRec ::'+oppRec);

        if(oppRec.Amount != insertingInvAmount){
            remaingAmount = oppRec.Amount - insertingInvAmount;
            Invoice__c inv = new Invoice__c();
            inv.Opportunity__c = oppRec.Id;
            inv.Amount__c = insertingInvAmount;
            inv.Status__c = 'Realized';
            inv.Delivery_Note__c = description;
            invoiceListToInsert.add(inv);
            System.debug('invoiceListToInsert Realized ::'+invoiceListToInsert);

            Invoice__c pendingInvoice = new Invoice__c();
            pendingInvoice.Opportunity__c = oppRec.Id;
            pendingInvoice.Status__c = 'Pending';
            pendingInvoice.Amount__c = remaingAmount;
            invoiceListToInsert.add(pendingInvoice);
            System.debug('invoiceListToInsert Pending ::'+invoiceListToInsert);
            Insert invoiceListToInsert;            
        }else {
            Invoice__c inv1 = new Invoice__c();
            inv1.Opportunity__c =oppRec.Id;
            inv1.Amount__c = insertingInvAmount;
            inv1.Status__c = 'Realized';
            invoiceListToInsert.add(inv1);
            Insert invoiceListToInsert;
            System.debug('Ok Amount ::'+invoiceListToInsert);
        }
    
        if(remaingAmount > 0.0 ){
            oppRec.Due_Amount__c = remaingAmount;
            update oppRec;
            System.debug('Updated Record ::'+oppRec);
        }
        if(!invoiceListToInsert.isEmpty()){
            for(Invoice__c invoiceRec : invoiceListToInsert){
                if(invoiceRec.status__c == 'Realized'){
                    System.debug('Attachment Invoice Id ::');
                    invoiceRecToReturn =invoiceRec;
                }
            }
        }
        return invoiceRecToReturn;
    }
}