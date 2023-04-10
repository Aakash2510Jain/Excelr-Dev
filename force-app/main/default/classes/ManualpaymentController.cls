public without sharing class ManualpaymentController{
    @AuraEnabled
    public Static Opportunity ManualpaymentcreateInvoice(String recordId){
        Opportunity oppRec = [SELECT Id, Name, Amount, Payment_Type__c, Due_Amount__c
                              FROM Opportunity
                              WHERE ID = :recordId];

        // Invoice__c inv = [SELECT Id,Name,Opportunity__c,Opportunity__r.Amount,Amount__c,Status__c,Type__c FROM Invoice__c WHERE Opportunity__c=:oppRec.Id];
        System.debug('Inoice Record ::' + oppRec);
        return oppRec;
    }

    @AuraEnabled
    public static List<String> getAllPaymentType(){
        List<String> getpayment = new List<String>();
        List<Down_Payment_Type__c> paymentList = [Select Id, Name, isActive__c, IsManual__c
                                                  From Down_Payment_Type__c
                                                  Where IsManual__c = true and isActive__c = true];
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
            String attachmentOwner = [Select ownerId
                                      from Invoice__c
                                      where id = :parentId].ownerId;
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
            Id conDocument = [SELECT ContentDocumentId
                              FROM ContentVersion
                              WHERE Id = :cVersion.Id].ContentDocumentId;

            //Insert ContentDocumentLink
            ContentDocumentLink cDocLink = new ContentDocumentLink();
            cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
            cDocLink.LinkedEntityId = attach.ParentId;//Add attachment parentId
            cDocLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
            cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
            Insert cDocLink;


            /*
             Attachment attach = new Attachment();
             attach.parentId = parentId;
             attach.Body = EncodingUtil.base64Decode(base64Data);
             attach.Name = fileName;
             attach.ContentType = contentType;
             Insert attach;
             return attach.Id;*/
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('ManualpaymentcreateInvoice', 'SaveFile', e, null);
        }
    }

    @AuraEnabled
    public static Invoice__c insertInvoiceBasedOppAmount(Decimal insertingInvAmount, String oppId, String description, date nextPaymentDueDate){
        system.debug('nextPaymentDueDate--->' + nextPaymentDueDate);
        try{
            List<Invoice__c> invoiceListToInsert = new List<Invoice__c>();
            List<Receipt__c> reciepttobeinsert = new List<Receipt__c>();
            Invoice__c invoiceRecToReturn = new Invoice__c();
            Decimal remaingAmount = 0.0;

            System.debug('insertingInvAmount ::' + insertingInvAmount);

            Opportunity oppRec = [SELECT Id, Name, Amount, Due_Amount__c
                                  FROM Opportunity
                                  WHERE ID = :oppId];
            System.debug('oppRec ::' + oppRec);
            OppRec.Payment_Type__c = 'Manual Payment';
            OppRec.Payment_Initiated__c = true;
            OppRec.Payment_Initiated_Date_Time__c = system.now();
            OppRec.Payment_Mode__c = null;
            OppRec.Loan_Amount__c = null;
            OppRec.Loan_Tenure__c = null;
            OppRec.NBFCPartner__c = null;
            OppRec.Loan_Type__c = null;

            update oppRec;
            if (math.floor(oppRec.Amount) != insertingInvAmount){
                remaingAmount = oppRec.Amount - insertingInvAmount;
                Invoice__c inv = new Invoice__c();
                inv.Opportunity__c = oppRec.Id;
                inv.Amount__c = insertingInvAmount;
                inv.Status__c = 'Initiated';
                inv.Type__c = 'Payment';
                inv.Mode_Terms_of_Payment__c = 'Offline';
                inv.Delivery_Note__c = description;
                inv.Initiated_Date__c = system.today();
                inv.Invoice_Due_Date__c = system.today() + 2;
                invoiceListToInsert.add(inv);

                Invoice__c pendingInvoice = new Invoice__c();
                pendingInvoice.Opportunity__c = oppRec.Id;
                pendingInvoice.Status__c = 'Pending';
                pendingInvoice.Type__c = 'Payment';
                pendingInvoice.Mode_Terms_of_Payment__c = 'Offline';
                Time myTime = Time.newInstance(11, 0, 0, 0); // 11:00 AM
                pendingInvoice.Next_Followup_Date_Time__c = DateTime.newInstance(nextPaymentDueDate.year(), nextPaymentDueDate.month(), nextPaymentDueDate.day(), myTime.hour(), myTime.minute(), myTime.second());
                pendingInvoice.Invoice_Due_Date__c = nextPaymentDueDate + 2;
                pendingInvoice.Initiated_Date__c = system.today();
                pendingInvoice.Amount__c = remaingAmount;
                invoiceListToInsert.add(pendingInvoice);
                System.debug('invoiceListToInsert Pending ::' + invoiceListToInsert);
                //Insert invoiceListToInsert;

                Database.SaveResult[] srList = Database.insert (invoiceListToInsert, false);
                Map<Id, Invoice__c> Invoicemap = new Map<Id, Invoice__c>(invoiceListToInsert);

                // Iterate through each returned result
                for (Database.SaveResult sr : srList){
                    if (sr.isSuccess()){
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully inserted account. Account ID: ' + sr.getId());
                        Receipt__c newreceipt = new Receipt__c();
                        newreceipt.Invoice__c = sr.getId();
                        newreceipt.Amount__c = Invoicemap.get(sr.getId()).Amount__c;
                        
                        if (Invoicemap.get(sr.getId()).Status__c == Constants.INVOICE_STATUS_LINKSENT) {
                            newreceipt.Receipt_Status__c = Constants.RECEIPT_STATUS_LINKSENT;
                        }
                        else if(Invoicemap.get(sr.getId()).Status__c == Constants.INVOICE_STATUS_PENDING){
                            newreceipt.Receipt_Status__c = Constants.RECEIPT_STATUS_PENDING;
                        }
                        else {
                            newreceipt.Receipt_Status__c = Invoicemap.get(sr.getId()).Status__c;
                        }
                        reciepttobeinsert.add(newreceipt);

                    } else{
                        // Operation failed, so get all errors
                        for (Database.Error err : sr.getErrors()){
                            System.debug('The following error has occurred.');
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Account fields that affected this error: ' + err.getFields());
                        }
                    }
                }
                
                } else{
                    Invoice__c inv1 = new Invoice__c();
                    inv1.Opportunity__c = oppRec.Id;
                    inv1.Amount__c = insertingInvAmount;
                    inv1.Status__c = 'Initiated';
                    inv1.Type__c = 'Payment';
                    inv1.Mode_Terms_of_Payment__c = 'Offline';
                    inv1.Initiated_Date__c = system.today();
                    inv1.Invoice_Due_Date__c = system.today() + 2;
                    //insert inv1;
                    invoiceListToInsert.add(inv1);
                    // Insert invoiceListToInsert;
                    System.debug('Ok Amount ::' + invoiceListToInsert);

                    Database.SaveResult[] srList = Database.insert (invoiceListToInsert, false);
                    Map<Id, Invoice__c> Invoicemap = new Map<Id, Invoice__c>(invoiceListToInsert);
                    for (Database.SaveResult sr : srList){
                        if (sr.isSuccess()){
                            // Operation was successful, so get the ID of the record that was processed
                            System.debug('Successfully inserted account. Account ID: ' + sr.getId());
                            Receipt__c newreceipt = new Receipt__c();
                            newreceipt.Invoice__c = sr.getId();
                            newreceipt.Amount__c = Invoicemap.get(sr.getId()).Amount__c;
                            
                            if (Invoicemap.get(sr.getId()).Status__c == Constants.INVOICE_STATUS_LINKSENT) {
                                newreceipt.Receipt_Status__c = Constants.RECEIPT_STATUS_LINKSENT;
                            }
                            else if(Invoicemap.get(sr.getId()).Status__c == Constants.INVOICE_STATUS_PENDING){
                                newreceipt.Receipt_Status__c = Constants.RECEIPT_STATUS_PENDING;
                            }
                            else {
                                newreceipt.Receipt_Status__c = Invoicemap.get(sr.getId()).Status__c;
                            }
                            reciepttobeinsert.add(newreceipt);
    
                        } else{
                            // Operation failed, so get all errors
                            for (Database.Error err : sr.getErrors()){
                                System.debug('The following error has occurred.');
                                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                System.debug('Account fields that affected this error: ' + err.getFields());
                            }
                        }
                    }

                    
                    // if (inv1.Id != null) {
                    //     Receipt__c newreceipt = new Receipt__c();
                    //     newreceipt.Invoice__c = inv1.id;
                    //     newreceipt.Amount__c = inv1.Amount__c;
                        
                    //     if (inv1.Status__c == Constants.INVOICE_STATUS_LINKSENT) {
                    //         newreceipt.Receipt_Status__c = Constants.RECEIPT_STATUS_LINKSENT;
                    //     }
                    //     else if(inv1.Status__c == Constants.INVOICE_STATUS_PENDING){
                    //         newreceipt.Receipt_Status__c = Constants.RECEIPT_STATUS_PENDING;
                    //     }
                    //     else {
                    //         newreceipt.Receipt_Status__c = inv1.Status__c;
                    //     }
                    //     reciepttobeinsert.add(newreceipt);  
                    // }
                }

                if (!reciepttobeinsert.isEmpty()) {
                    insert reciepttobeinsert;
                    
                }

                if (remaingAmount > 0.0){
                    oppRec.Due_Amount__c = remaingAmount;
                    update oppRec;
                    System.debug('Updated Record ::' + oppRec);
                }
                if (!invoiceListToInsert.isEmpty()){
                    for (Invoice__c invoiceRec : invoiceListToInsert){
                        if (invoiceRec.status__c == 'Initiated'){
                            System.debug('Attachment Invoice Id ::');
                            invoiceRecToReturn = invoiceRec;
                        }
                    }
                }
                return invoiceRecToReturn;
            } catch (Exception e){
                system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
                HandleBusinessException.captureError('ManualpaymentcreateInvoice', 'insertInvoiceBasedOppAmount', e, null);
                return null;
            }
        }
    }