public class InitiateLoanPaymentController {
    @AuraEnabled
    public static opportunityWrapper getOpportunityData(String opportunityId){
        system.debug('opportunityId--->'+opportunityId);
        Opportunity oppRecordToBeReturned = new Opportunity();
        List<NBFC__c> NBFCPartnerList = new List<NBFC__c>();
        List<Down_Payment_Type__c> downPaymentTypeList = new List<Down_Payment_Type__c>();
        
        oppRecordToBeReturned = [Select Id,Name,Amount,Email__c,Phone__c From Opportunity where Id =:opportunityId];
        NBFCPartnerList = [Select Interest_Rate__c,NBFC_Name__c,GST_on_Subvention__c,Processing_Fee__c,Tenure__c From NBFC__c order by NBFC_Name__c ASC];
        downPaymentTypeList = [Select Name From Down_Payment_Type__c where isActive__c = true order by name Asc];
        opportunityWrapper opportunityWrapperInstance = new opportunityWrapper(oppRecordToBeReturned,NBFCPartnerList, downPaymentTypeList);
        
        return opportunityWrapperInstance;
    }
    @AuraEnabled
    public static string handleLoanPayment(string opportunityId,string loanPartner,string loanTenure,string downPaymentType,string downPayment,string loanAmount,string opportunityAmount,string expiryDate){
        try{
            system.debug('opportunityAmount---->'+opportunityAmount);
            system.debug('downPayment---->'+downPayment);
            system.debug('loanAmount---->'+loanAmount);
            system.debug('loanPartner---->'+loanPartner);
            system.debug('loanTenure---->'+loanTenure);
            system.debug('downPaymentType---->'+downPaymentType);
            system.debug('expiryDate---->'+expiryDate);
            Long longUnixTimeStamp =0;
            if(!string.isBlank(expiryDate)){
                
                datetime datetimevalueCurrentDT = DateTime.newInstance(Date.valueOf(expiryDate).year(), Date.valueOf(expiryDate).month(), Date.valueOf(expiryDate).day());
                String strUnixTimeStamp = String.valueof(datetimevalueCurrentDT.getTime());
                long unixtimestamp = datetimevalueCurrentDT.getTime();
                longUnixTimeStamp = Long.valueOf(strUnixTimeStamp);
                
            }
            Opportunity oppRec = new Opportunity();
            oppRec.Id = opportunityId;
            oppRec.Payment_Status__c = 'In Progress';	
            update oppRec;

            Invoice__c invRec = new Invoice__c();
            invRec.Opportunity__c = opportunityId;
            invRec.Status__c = 'Loan Processed';
            invRec.Amount__c = decimal.valueOf(opportunityAmount);
            invRec.Down_Payment__c = integer.valueOf(downPayment);
            invRec.Loan_Amount__c = decimal.valueOf(loanAmount);
            invRec.Loan_Partner__c = loanPartner;
            if(downPaymentType != null && (downPaymentType == 'RazorPay' || downPaymentType == 'CC Avenue' ))
                invRec.Payment_Type__c = Constants.INVOICE_PAYMENT_TYPE_PARTIALPAYMENT;
            invRec.Loan_Tenure__c = decimal.valueOf(loanTenure);
            invRec.Down_Payment_Type__c = downPaymentType;
            if(!string.isBlank(downPaymentType))
                invRec.Down_Payment_Expiry_Date__c = Date.valueOf(expiryDate);
            invRec.Type__c = 'Loan';
            if(integer.valueOf(downPayment) > 0)
               invRec.Payment_Type__c = 'Partial Loan Payment';
            else
                invRec.Payment_Type__c = 'Full Loan Payment';
            invRec.Initiated_Date__c = System.Today();
            invRec.Due_Amount__c = decimal.valueOf(opportunityAmount);
            insert invRec;
            
            if(integer.valueOf(downPayment) > 0){
                // create 2 receipt
                List<Receipt__c> receiptListToInsert = new List<Receipt__c>();
                Receipt__c receiptForDownPayment = new Receipt__c();
                receiptForDownPayment.Amount__c = integer.valueOf(downPayment);
                receiptForDownPayment.Invoice__c = invRec.Id;
                receiptForDownPayment.Type__c = downPaymentType;
                if(downPaymentType == 'CC Avenue' || downPaymentType == 'RazorPay'){
                    receiptForDownPayment.Receipt_Status__c = 'Link Sent';
                }else{
                     receiptForDownPayment.Receipt_Status__c = 'Initiated';
                }
                //receiptForDownPayment.Receipt_Status__c = Constants.RECEIPT_STATUS_LINKSENT;
                receiptListToInsert.add(receiptForDownPayment);
                
                Receipt__c receiptForLoanPayment = new Receipt__c();
                receiptForLoanPayment.Amount__c = integer.valueOf(loanAmount);
                receiptForLoanPayment.Invoice__c = invRec.Id;
                receiptForLoanPayment.Type__c = 'Loan';
                receiptForLoanPayment.Receipt_Status__c = 'Loan Initiated';
                receiptListToInsert.add(receiptForLoanPayment);
                if(!receiptListToInsert.isEmpty()){
                    insert receiptListToInsert;
                }
            }else{
                // create one receipt
                Receipt__c receiptForLoanPayment = new Receipt__c();
                receiptForLoanPayment.Receipt_Status__c = 'Loan Initiated';
                receiptForLoanPayment.Amount__c = decimal.valueOf(loanAmount);
                receiptForLoanPayment.Invoice__c = invRec.Id;
                receiptForLoanPayment.Type__c = 'Loan';
                insert receiptForLoanPayment;
            }
            if (downPaymentType != null && downPaymentType == 'RazorPay'){
                RazorpayPaymentHandler.initateRazorpayPament(invRec.id, longUnixTimeStamp);
            } else if (downPaymentType != null && downPaymentType == 'CC Avenue'){
                ccAvenueLwcController.initateCCAvenuePayment(invRec.id, longUnixTimeStamp);
            }

            return invRec.Id;
        } catch(Exception e){
            System.debug(' the Error has occured due to =====> ' + e.getMessage());
            System.debug(' the Error has occured at  =====> ' + e.getLineNumber());
            HandleBusinessException.captureError('InitiateLoanPaymentController','handleLoanPayment', e, null);    
            return null;
        }
    }
    @AuraEnabled
    public static void saveAttachmentUnderInvoice(String invoiceId,string FileName, String Base64Data, String ContentType,string isLoanAttachment){
        system.debug('invoiceId--->'+invoiceId);
        system.debug('FileName--->'+FileName);
        system.debug('Base64Data--->'+Base64Data);
        system.debug('ContentType--->'+ContentType);
        system.debug('isLoanAttachment--->'+isLoanAttachment);
        String DownPaymentReceiptId = '';
        
        String loanReceiptId = [select Id from receipt__c where Invoice__c =: invoiceId and type__c = 'Loan'].Id;
        if(isLoanAttachment == 'no')
            DownPaymentReceiptId = [select Id from receipt__c where Invoice__c =: invoiceId and type__c != 'Loan'].Id;
        try{
            base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
            String attachmentOwner = [Select ownerId from Invoice__c where id =: invoiceId].ownerId;
            Attachment attach = new Attachment();
            if(isLoanAttachment == 'yes')
                attach.parentId = loanReceiptId;
            else
                attach.parentId = DownPaymentReceiptId;
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
            Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
            
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
            HandleBusinessException.captureError('ManualpaymentcreateInvoice', 'SaveFile', e , null);
        }
    }    
    
    public class opportunityWrapper{
        @AuraEnabled
        public Opportunity opportunityRecord;
        @AuraEnabled
        public List<NBFC__c> NBFCPartnerList;
        @AuraEnabled
        public List<Down_Payment_Type__c> downPaymentTypeList;
        
        public opportunityWrapper(Opportunity opportunityRecord, List<NBFC__c> NBFCPartnerList, List<Down_Payment_Type__c> downPaymentTypeList){
            this.opportunityRecord = opportunityRecord; 
            this.NBFCPartnerList = NBFCPartnerList;
            this.downPaymentTypeList = downPaymentTypeList;
        }
    }
}