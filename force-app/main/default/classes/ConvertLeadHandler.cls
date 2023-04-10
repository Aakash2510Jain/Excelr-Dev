public without sharing class ConvertLeadHandler {
    @AuraEnabled
    public static void convertLeadOnLead(String recordId){
        try{
            if (!String.isBlank(recordId) ){
              
                  system.debug('recordId-->' + recordId);
                
                List<Application__c> existingApplicationUnderLead = new   List<Application__c>();
                List<Application__c> attachApplicationToAccount = new   List<Application__c>();
                List<Application__c> applicationsToBeUpdated = new  List<Application__c>();  
                List<Invoice__c> existingInvoiceUnderLead = new  List<Invoice__c>();        
                List<Invoice__c> attachInvoiceToOpportunity =new  List<Invoice__c>(); 
                List<OpportunityLineItem> attachOLIToProduct= new  List<OpportunityLineItem>();
                List<PriceBookEntry> existingpriceBook= new  List<PriceBookEntry>();        
                    
                existingApplicationUnderLead = [Select Id,Name,Account__c,Lead__c,Course__c,Applied_Date_Time__c From Application__c where Lead__c = :recordId];
                existingInvoiceUnderLead= [Select Id, Opportunity__c,Amount__c,LeadInvoice__c From Invoice__c where LeadInvoice__c= :recordId];
              
                existingpriceBook =[ Select Id,Product2Id,Pricebook2Id,UseStandardPrice,UnitPrice from PricebookEntry limit 1 ];
                
                List<Lead> leadList = new  List<Lead>();
                leadList=[Select Id,Payment_Initiated_Date_Time__c,Name, Email, isConverted  from Lead where Id=: recordId  and isConverted = false];
                //[Select Id, Name, Email, isConverted from Lead Where Id = :recordId and isConverted = false]
                for (Lead leadObj : leadList){
                    
                    Database.LeadConvert lc = new Database.LeadConvert();
                    lc.setLeadId(leadObj.Id);
                    lc.setDoNotCreateOpportunity(false);
                    
                    LeadStatus convertStatus = [SELECT Id, MasterLabel, IsConverted FROM LeadStatus WHERE IsConverted = true limit 1];
                    lc.setConvertedStatus(convertStatus.MasterLabel);
                    
                    Database.LeadConvertResult lcResults = Database.convertLead(lc);
                    system.debug('lcResults-->' + lcResults);
                    if (lcResults.isSuccess()){
                        system.debug('lcResults.accountid-->'+lcResults.accountid);
                        system.debug(' lcResults.getAccountId();-->'+ lcResults.getAccountId());
                        for (Application__c appRec : existingApplicationUnderLead){
                            Application__c appRecToUpdate = new Application__c();
                            appRecToUpdate.Id = appRec.Id;
                            appRecToUpdate.Account__c = lcResults.accountid;
                           
                            attachApplicationToAccount.add(appRecToUpdate);
                        }
                        for (Invoice__c invoiceRec : existingInvoiceUnderLead){               
                            Invoice__c invoice = new Invoice__c();
                            invoice.Id= invoiceRec.Id;
                            invoice.Opportunity__c= lcResults.OpportunityId;
                            attachInvoiceToOpportunity.add(invoice);
                        }
                    /*   for(Lead ld: leadList){
                           OpportunityLineItem OLI = new OpportunityLineItem();          
                            OLI.OpportunityId= lcResults.OpportunityId;
                            OLI.PricebookEntryId= existingpriceBook[0].Id;
                            OLI.Product2Id = ld.Product__c;
                            OLI.Quantity = ld.Quantity__c;
                            OLI.TotalPrice = ld.Total_Amount__c;
                            OLI.Payment_Initiated_Date_Time__c= ld.Payment_Initiated_Date_Time__c;
                              insert OLI;  
                          
                        } 
					*/
                        
                    }
                    
                }
                if (!attachApplicationToAccount.isEmpty()){
                    update attachApplicationToAccount;
                }
                if (!attachInvoiceToOpportunity.isEmpty()){
                    update attachInvoiceToOpportunity;
                }
                
            }
            
        } catch(Exception e){
            system.debug('Error' +e.getMessage()+' Line Number' +e.getLineNumber());
            Exceptions__c Exc = new Exceptions__c();
            Exc.Class_Name__c = 'ConvertLeadHandler';
			Exc.Error_Message__c = e.getMessage();     
            Exc.Error_Line_No__c = e.getLineNumber();
            Exc.Error_Stack_Trace__c = e.getStackTraceString();
            Exc.Error_Type__c = e.getTypeName();
            Exc.Method_Name__c = 'convertLeadOnLead';
            insert Exc;
        }
    }   
}