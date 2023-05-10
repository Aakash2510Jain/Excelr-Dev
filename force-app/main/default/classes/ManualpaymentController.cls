public without sharing class ManualpaymentController{
    @AuraEnabled
    public Static Opportunity ManualpaymentcreateInvoice(String recordId){
        Opportunity oppRec = [SELECT Id, Name, Amount, Payment_Type__c, Due_Amount__c,(Select Due_Amount__c From Invoices__r) FROM Opportunity  WHERE ID = :recordId];
        
        System.debug('oppRec Record ::' + oppRec);
        return oppRec;
    }
    
    @AuraEnabled
    public static List<String> getAllPaymentType(){
        List<String> getpayment = new List<String>();
        List<Down_Payment_Type__c> paymentList = [Select Id, Name, isActive__c, IsManual__c From Down_Payment_Type__c Where IsManual__c = true and isActive__c = true];
        for (Down_Payment_Type__c dpay : paymentList){
            getpayment.add(dpay.name);
        }
        System.debug('getpayment:::::' + getpayment);
        return getpayment;
    }
    
    @AuraEnabled
    public Static List<String> getPickListValuesMethod(String ObjectApi_name, String Field_Name){
        try{
            List<String> lstPickvals = new List<String>();
            Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);
            Sobject Object_name = targetType.newSObject();
            Schema.sObjectType sobject_type = Object_name.getSObjectType();
            Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
            Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
            List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_Name).getDescribe().getPickListValues();
            
            for (Schema.PicklistEntry a : pick_list_values){
                lstPickvals.add(String.ValueOf(a.getLabel()).trim());
            }
            System.debug('lstPickvals>>>> ::' + lstPickvals);
            return lstPickvals;
        } Catch (Exception e){
            System.debug('The Error ::' + e.getMessage() + ' AND Error Line No :' + e.getLineNumber());
        }
        return null;
    }
    
    @AuraEnabled
    public static void SaveFile(Id parentId, String fileName, String base64Data, String contentType){
        try{
            base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
            String attachmentOwner = userInfo.getUserId();  //[Select Invoice__r.Opportunity__r.OwnerId from Receipt__c where id = :parentId].Invoice__r.Opportunity__r.OwnerId;
            Attachment attach = new Attachment();
            attach.parentId = parentId;
            attach.Body = EncodingUtil.base64Decode(base64Data);
            attach.Name = fileName;
            attach.ContentType = contentType;
            
            //Insert ContentVersion
            ContentVersion cVersion = new ContentVersion();
            cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
            cVersion.PathOnClient = attach.Name;//File name with extention
            cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
            cVersion.OwnerId = attachmentOwner;//Owner of the file
            cVersion.Title = attach.Name;//Name of the file
            cVersion.VersionData = attach.Body;//File content
            Insert cVersion;
            
            //After saved the Content Verison, get the ContentDocumentId
            Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cVersion.Id].ContentDocumentId;
            
            //Insert ContentDocumentLink
            ContentDocumentLink cDocLink = new ContentDocumentLink();
            cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
            cDocLink.LinkedEntityId = attach.ParentId;//Add attachment parentId
            cDocLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
            cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
            Insert cDocLink;
            
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('ManualpaymentcreateInvoice', 'SaveFile', e, null);
        }
    }
    
    @AuraEnabled
    public static string insertInvoiceBasedOppAmount(string upfrontAmount,string dueAmount,String oppId, String description, string nextPaymentDueDate,string paymentType,string opportunityAmount){
        system.debug('nextPaymentDueDate--->' + nextPaymentDueDate);
        system.debug('upfrontAmount--->'+upfrontAmount);
        system.debug('oppId--->'+oppId);
        system.debug('dueAmount--->'+dueAmount);
        system.debug('description--->'+description);
        system.debug('paymentType--->'+paymentType);
        try{
            string receiptIdToreturn = '';
            
            Opportunity opportunityRecord = [Select Id,(Select Id From Invoices__r order By CreatedDate DESC limit 1) From Opportunity where Id=:oppId];
            
            if(opportunityRecord.Invoices__r.isEmpty()){
                Invoice__c invRec = new Invoice__c();
                invRec.Opportunity__c = oppId;
                invRec.Status__c = 'Initiated';
                invRec.Initiated_Date__c = System.Today();
                invRec.Payment_Type__c = 'Manual Payment';
                invRec.Type__c = 'Manual';
                invRec.Amount__c = decimal.valueOf(opportunityAmount);
                Time myTime = Time.newInstance(10, 0, 0, 0);
                if(nextPaymentDueDate != null){
                    DateTime followUpDateTime = DateTime.newInstanceGMT(Date.valueOf(nextPaymentDueDate), myTime);
                    invRec.Next_Followup_Date_Time__c = followUpDateTime;
                }
                invRec.Initiated_Amount__c = decimal.valueOf(upfrontAmount);
                invRec.Due_Amount__c = decimal.valueOf(opportunityAmount);
                insert invRec;
                
                if(decimal.valueOf(upfrontAmount) > 0){
                    // create 2 receipt
                    Receipt__c receiptForDownPayment = new Receipt__c();
                    receiptForDownPayment.Amount__c = decimal.valueOf(upfrontAmount);
                    receiptForDownPayment.Invoice__c = invRec.Id;
                    receiptForDownPayment.Type__c = paymentType;
                    receiptForDownPayment.Receipt_Status__c = 'Initiated';
                    if(!string.isBlank(description))
                        receiptForDownPayment.Description__c = description;
                    insert receiptForDownPayment;
                    
                    receiptIdToreturn = receiptForDownPayment.Id;
                }else{
                    // create one receipt
                    Receipt__c receiptForLoanPayment = new Receipt__c();
                    receiptForLoanPayment.Receipt_Status__c = 'Initiated';
                    receiptForLoanPayment.Amount__c = decimal.valueOf(dueAmount);
                    receiptForLoanPayment.Invoice__c = invRec.Id;
                    receiptForLoanPayment.Type__c = paymentType;
                    if(!string.isBlank(description))
                        receiptForLoanPayment.Description__c = description;
                    insert receiptForLoanPayment;
                    receiptIdToreturn = receiptForLoanPayment.Id;
                } 
            }else{
                if(!string.isBlank(upfrontAmount) && decimal.valueOf(upfrontAmount) > 0){
                    // create 2 receipt
                    Receipt__c receiptForDownPayment = new Receipt__c();
                    receiptForDownPayment.Is_Pending_Receipt__c= true;
                    receiptForDownPayment.Amount__c = decimal.valueOf(upfrontAmount);
                    receiptForDownPayment.Invoice__c = opportunityRecord.Invoices__r[0].Id;
                    receiptForDownPayment.Type__c = paymentType;
                    receiptForDownPayment.Receipt_Status__c = 'Initiated';
                    if(!string.isBlank(description))
                        receiptForDownPayment.Description__c = description;
                    insert receiptForDownPayment;
                    receiptIdToreturn = receiptForDownPayment.Id;
                }else{
                    // create one receipt
                    Receipt__c receiptForLoanPayment = new Receipt__c();
                    receiptForLoanPayment.Is_Pending_Receipt__c= true;
                    receiptForLoanPayment.Receipt_Status__c = 'Initiated';
                    receiptForLoanPayment.Amount__c = decimal.valueOf(dueAmount);
                    receiptForLoanPayment.Invoice__c = opportunityRecord.Invoices__r[0].Id;
                    receiptForLoanPayment.Type__c = paymentType;
                    if(!string.isBlank(description))
                        receiptForLoanPayment.Description__c = description;
                    insert receiptForLoanPayment;
                    receiptIdToreturn = receiptForLoanPayment.Id;
                } 
            }
            return receiptIdToreturn;
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('ManualpaymentcreateInvoice', 'insertInvoiceBasedOppAmount', e, null);
            return null;
        }
    }
}