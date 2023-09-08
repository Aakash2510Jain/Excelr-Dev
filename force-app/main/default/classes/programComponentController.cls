/*
* Author : Anjali Singh
*/

public without sharing class programComponentController {
    
    @AuraEnabled
    public static AllCombinedWrapper getAllApplications(string programId){
        system.debug('programId  -- > ' + programId);
        AllCombinedWrapper allWrapper = new AllCombinedWrapper();
        try{
            List<Placement_Application__c> clearedPlacementApplicationList = [SELECT Id, Contact__c, Contact__r.Name, Contact__r.Email, Contact__r.Phone, Contact__r.LMS_Student_Id__c, Aptitude_Marks__c, Aptitude_Result__c, GD_Result__c, Personal_Interview_Result__c, Remarks__c, Placement_Paid_Service_Status__c	 
                                                                              FROM Placement_Application__c WHERE Program__c =: programId AND Aptitude_Result__c = 'Pass' AND GD_Result__c = 'Pass' AND Personal_Interview_Result__c = 'Pass'];
            
            system.debug('clearedPlacementApplicationList  -- > ' + clearedPlacementApplicationList);
            
            Map<Id, placementApplicationWrapper> mapOfAppIdWithWrapper = new Map<Id, placementApplicationWrapper>();
            if(clearedPlacementApplicationList.size()>0){
                set<Id> pAppIdSet = new set<Id>();
                for(Placement_Application__c pApp : clearedPlacementApplicationList){
                    pAppIdSet.add(pApp.Id);
                    placementApplicationWrapper pWrapper = new placementApplicationWrapper(pApp.Id, pApp.Contact__c, pApp.Contact__r.LMS_Student_Id__c, pApp.Contact__r.Name,
                                                                                           pApp.Contact__r.Email, pApp.Contact__r.Phone, pApp.Aptitude_Marks__c, pApp.Aptitude_Result__c, 
                                                                                           pApp.GD_Result__c, pApp.Personal_Interview_Result__c, pApp.Remarks__c, pApp.Placement_Paid_Service_Status__c);
                    mapOfAppIdWithWrapper.put(pApp.Id, pWrapper);
                }
                
                List<Opportunity> relatedOppList = [SELECT Id, Name, Placement_Application__c FROM Opportunity WHERE Placement_Application__c IN: pAppIdSet];
                system.debug('relatedOppList  -- > ' + relatedOppList);
                if(relatedOppList.size()>0){
                    for(Opportunity opp : relatedOppList){
                        if (mapOfAppIdWithWrapper.containsKey(opp.Placement_Application__c)) {
                            placementApplicationWrapper pAppWrapper = mapOfAppIdWithWrapper.get(opp.Placement_Application__c);
                            pAppWrapper.relatedOpps.add(new OpportunityWrapper(
                                opp.Id,
                                opp.Name
                            ));
                        }
                    }
                }
            }
            
            List<Placement_Application__c> piFailedPlacementApplicationList = [SELECT Id, Contact__c, Contact__r.Name, Contact__r.Email, Contact__r.Phone, Contact__r.LMS_Student_Id__c, Aptitude_Marks__c, Aptitude_Result__c, GD_Result__c, Personal_Interview_Result__c, Remarks__c, Placement_Paid_Service_Status__c	 
                                                                               FROM Placement_Application__c WHERE Program__c =: programId AND Aptitude_Result__c = 'Pass' AND GD_Result__c = 'Pass' AND Personal_Interview_Result__c = 'Fail'];
            
            system.debug('piFailedPlacementApplicationList  -- > ' + piFailedPlacementApplicationList);
            
            Map<Id, placementApplicationWrapper> mapOfPIFailedAppIdWithWrapper = new Map<Id, placementApplicationWrapper>();
            if(piFailedPlacementApplicationList.size()>0){
                set<Id> pAppIdSet = new set<Id>();
                for(Placement_Application__c pApp : piFailedPlacementApplicationList){
                    pAppIdSet.add(pApp.Id);
                    placementApplicationWrapper pWrapper = new placementApplicationWrapper(pApp.Id, pApp.Contact__c, pApp.Contact__r.LMS_Student_Id__c, pApp.Contact__r.Name,
                                                                                           pApp.Contact__r.Email, pApp.Contact__r.Phone, pApp.Aptitude_Marks__c, pApp.Aptitude_Result__c, 
                                                                                           pApp.GD_Result__c, pApp.Personal_Interview_Result__c, pApp.Remarks__c, pApp.Placement_Paid_Service_Status__c);
                    mapOfPIFailedAppIdWithWrapper.put(pApp.Id, pWrapper);
                }
                
                List<Opportunity> relatedOppList = [SELECT Id, Name, Placement_Application__c FROM Opportunity WHERE Placement_Application__c IN: pAppIdSet];
                system.debug('relatedOppList  -- > ' + relatedOppList);
                if(relatedOppList.size()>0){
                    for(Opportunity opp : relatedOppList){
                        if (mapOfPIFailedAppIdWithWrapper.containsKey(opp.Placement_Application__c)) {
                            placementApplicationWrapper pAppWrapper = mapOfPIFailedAppIdWithWrapper.get(opp.Placement_Application__c);
                            pAppWrapper.relatedOpps.add(new OpportunityWrapper(
                                opp.Id,
                                opp.Name
                            ));
                        }
                    }
                }
            }
            
            
            List<Placement_Application__c> partiallyPlacementApplicationList = [SELECT Id, Contact__c, Contact__r.Name, Contact__r.Email, Contact__r.Phone, Contact__r.LMS_Student_Id__c, Aptitude_Marks__c, Aptitude_Result__c, GD_Result__c, Personal_Interview_Result__c, Remarks__c, Placement_Paid_Service_Status__c	 
                                                                                FROM Placement_Application__c WHERE Program__c =: programId AND (Aptitude_Result__c = 'Fail' OR GD_Result__c = 'Fail')];
            
            system.debug('partiallyPlacementApplicationList  -- > ' + partiallyPlacementApplicationList);
            
            Map<Id, placementApplicationWrapper> mapOfPartialClearedAppIdWithWrapper = new Map<Id, placementApplicationWrapper>();
            if(partiallyPlacementApplicationList.size()>0){
                set<Id> pAppIdSet = new set<Id>();
                for(Placement_Application__c pApp : partiallyPlacementApplicationList){
                    pAppIdSet.add(pApp.Id);
                    placementApplicationWrapper pWrapper = new placementApplicationWrapper(pApp.Id, pApp.Contact__c, pApp.Contact__r.LMS_Student_Id__c, pApp.Contact__r.Name,
                                                                                           pApp.Contact__r.Email, pApp.Contact__r.Phone, pApp.Aptitude_Marks__c, pApp.Aptitude_Result__c, 
                                                                                           pApp.GD_Result__c, pApp.Personal_Interview_Result__c, pApp.Remarks__c, pApp.Placement_Paid_Service_Status__c);
                    mapOfPartialClearedAppIdWithWrapper.put(pApp.Id, pWrapper);
                }
                
                List<Opportunity> relatedOppList = [SELECT Id, Name, Placement_Application__c FROM Opportunity WHERE Placement_Application__c IN: pAppIdSet];
                if(relatedOppList.size()>0){
                    for(Opportunity opp : relatedOppList){
                        if (mapOfPartialClearedAppIdWithWrapper.containsKey(opp.Placement_Application__c)) {
                            placementApplicationWrapper pAppWrapper = mapOfPartialClearedAppIdWithWrapper.get(opp.Placement_Application__c);
                            pAppWrapper.relatedOpps.add(new OpportunityWrapper(
                                opp.Id,
                                opp.Name
                            ));
                        }
                    }
                }
                
                List<Lead> relatedLeadList = [SELECT Id, Name, Placement_Application__c FROM Lead WHERE Placement_Application__c IN: pAppIdSet];
                if(relatedLeadList.size()>0){
                    for(Lead ld : relatedLeadList){
                        if (mapOfPartialClearedAppIdWithWrapper.containsKey(ld.Placement_Application__c)) {
                            placementApplicationWrapper pAppWrapper = mapOfPartialClearedAppIdWithWrapper.get(ld.Placement_Application__c);
                            pAppWrapper.relatedLeads.add(new LeadWrapper(
                                ld.Id,
                                ld.Name
                            ));
                        }
                    }
                }
            }
            
            
            List<Placement_Application__c> naPlacementApplicationList = [SELECT Id, Not_Attended__c, Contact__c, Contact__r.Name, Contact__r.Email, Contact__r.Phone, Contact__r.LMS_Student_Id__c, Aptitude_Marks__c, Aptitude_Result__c, GD_Result__c, Personal_Interview_Result__c, Remarks__c, Placement_Paid_Service_Status__c	 
                                                                         FROM Placement_Application__c WHERE Program__c =: programId AND Not_Attended__c = true];
            
            system.debug('naPlacementApplicationList  -- > ' + naPlacementApplicationList);
            
            Map<Id, placementApplicationWrapper> mapOfNAAppIdWithWrapper = new Map<Id, placementApplicationWrapper>();
            if(naPlacementApplicationList.size()>0){
                set<Id> pAppIdSet = new set<Id>();
                for(Placement_Application__c pApp : naPlacementApplicationList){
                    pAppIdSet.add(pApp.Id);
                    placementApplicationWrapper pWrapper = new placementApplicationWrapper(pApp.Id, pApp.Contact__c, pApp.Contact__r.LMS_Student_Id__c, pApp.Contact__r.Name,
                                                                                           pApp.Contact__r.Email, pApp.Contact__r.Phone, pApp.Aptitude_Marks__c, pApp.Aptitude_Result__c, 
                                                                                           pApp.GD_Result__c, pApp.Personal_Interview_Result__c, pApp.Remarks__c, pApp.Placement_Paid_Service_Status__c);
                    mapOfNAAppIdWithWrapper.put(pApp.Id, pWrapper);
                }
                
                List<Lead> relatedLeadList = [SELECT Id, Name, Placement_Application__c FROM Lead WHERE Placement_Application__c IN: pAppIdSet];
                if(relatedLeadList.size()>0){
                    for(Lead ld : relatedLeadList){
                        if (mapOfNAAppIdWithWrapper.containsKey(ld.Placement_Application__c)) {
                            placementApplicationWrapper pAppWrapper = mapOfNAAppIdWithWrapper.get(ld.Placement_Application__c);
                            pAppWrapper.relatedLeads.add(new LeadWrapper(
                                ld.Id,
                                ld.Name
                            ));
                        }
                    }
                }
            }
            
            
            allWrapper.allClearedApplications = new list<placementApplicationWrapper>(mapOfAppIdWithWrapper.values());
            allWrapper.piFailedApplications = new list<placementApplicationWrapper>(mapOfPIFailedAppIdWithWrapper.values());
            allWrapper.partiallyClearedApplications = new list<placementApplicationWrapper>(mapOfPartialClearedAppIdWithWrapper.values());
            allWrapper.nonAttendedApplications = new list<placementApplicationWrapper>(mapOfNAAppIdWithWrapper.values());
            system.debug('allWrapper.piFailedApplications -- ' + allWrapper.piFailedApplications);
            system.debug('allWrapper -- ' + allWrapper);
            
        }
        catch(Exception e){
            system.debug('getAllApplications Method Error -- ' + e.getMessage());
            system.debug('AT LINE NO -- ' + e.getLineNumber());
        }
        return allWrapper;
    }
    
    @AuraEnabled
    public static string createOpportunities(List<ResponseWrapper> rWrapperList, string programId){
        system.debug('rWrapperList  -- > ' + rWrapperList);
        system.debug('programId  -- > ' + programId);
        string result = '';
        try{
            
            Map<Id, ResponseWrapper> rWrapperMap = new Map<Id, ResponseWrapper>();
            if(rWrapperList.size()>0){
                for(ResponseWrapper rWrapper : rWrapperList){
                    rWrapperMap.put(rWrapper.appId, rWrapper);
                }
            }
            system.debug('rWrapperMap  -- > ' + rWrapperMap);
            
            Program__c prgrm = [SELECT Id, Name FROM Program__c WHERE Id =: programId];
            List<Program_Product__c> programProdList = [SELECT Id, Product__c FROM Program_Product__c WHERE Program__c =: programId];
            set<Id> prodIdSet = new set<Id>();
            for(Program_Product__c pProd : programProdList){
                prodIdSet.add(pProd.Product__c);
            }
            
            system.debug('prodIdSet  -- ' + prodIdSet);
            
            List<Placement_Application__c> placementApplicationList = [SELECT Id, Contact__c, Contact__r.Name, Contact__r.Email, Contact__r.Phone, Contact__r.LMS_Student_Id__c, Aptitude_Marks__c, Aptitude_Result__c, GD_Result__c, Personal_Interview_Result__c, Remarks__c, Placement_Paid_Service_Status__c	 
                                                                       FROM Placement_Application__c WHERE Id IN: rWrapperMap.keySet() AND Opportunity_Created__c = false];
            
            system.debug('placementApplicationList  -- > ' + placementApplicationList);
            
            List<Opportunity> oppListToBeInserted = new List<Opportunity>();
            Id priceBookId = [SELECT Id FROM PriceBook2 WHERE Name = 'Standard Price Book'].Id;
            List<PriceBookEntry> pbeList = [SELECT Id, Product2Id, UnitPrice FROM PriceBookEntry WHERE Product2Id IN: prodIdSet];
            Map<Id, PriceBookEntry> mapOfPbEntries = new Map<Id, PriceBookEntry>();
            Decimal totalPrice = 0;
            for(PriceBookEntry pbe : pbeList){
                mapOfPbEntries.put(pbe.Product2Id, pbe);
                totalPrice += pbe.UnitPrice;
            }
            system.debug('mapOfPbEntries -->> ' + mapOfPbEntries);
            List<Placement_Application__c> pAppListToUpdate = new List<Placement_Application__c>();
            
            
            for(Placement_Application__c appRec : placementApplicationList){
                if(rWrapperMap.containsKey(appRec.Id) && rWrapperMap.get(appRec.Id) != null){
                    appRec.Opportunity_Created__c = true;
                    appRec.Placement_Paid_Service_Status__c = rWrapperMap.get(appRec.Id).status;
                    appRec.Remarks__c = rWrapperMap.get(appRec.Id).remarks;
                    pAppListToUpdate.add(appRec);
                    
                    Opportunity opp = new Opportunity();
                    opp.Name = appRec.Contact__r.LMS_Student_Id__c != null ? appRec.Contact__r.LMS_Student_Id__c + '-' + prgrm.Name : prgrm.Name;
                    opp.StageName = 'Open';
                    opp.CloseDate = system.today();
                    opp.Placement_Application__c = appRec.Id;
                    opp.Contact__c = appRec.Contact__c;
                    opp.Pricebook2Id = priceBookId;
                    opp.Expected_Revenue__c = totalPrice;
                    oppListToBeInserted.add(opp);      
                }
            }
            
            if(pAppListToUpdate.size()>0){
                update pAppListToUpdate;
            }
            
            
            if(oppListToBeInserted.size()>0){
                Database.insert(oppListToBeInserted,true);
                List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
                
                for(Opportunity opp : oppListToBeInserted){
                    for(Id prodId : prodIdSet){
                        OpportunityLineItem oli = new OpportunityLineItem();
                        oli.Product2Id = prodId;
                        oli.OpportunityId = opp.Id;
                        oli.Quantity = 1;
                        if(rWrapperMap.containsKey(opp.Placement_Application__c) && ( rWrapperMap.get(opp.Placement_Application__c).discount != null || rWrapperMap.get(opp.Placement_Application__c).discount != 0) ){
                            oli.Discount = rWrapperMap.get(opp.Placement_Application__c).discount;
                        }
                        if(mapOfPbEntries.containsKey(prodId)){
                            oli.PricebookEntryId = mapOfPbEntries.get(prodId).Id; 
                            oli.UnitPrice = mapOfPbEntries.get(prodId).UnitPrice; 
                        }
                        oliList.add(oli);                          
                    }
                }
                
                if(oliList.size()>0){
                    insert oliList;
                }
            }
            
            result = 'success';
        }
        catch(Exception e){
            system.debug('createOpportunities Method Error -- ' + e.getMessage());
            system.debug('AT LINE NO -- ' + e.getLineNumber());
            result = e.getMessage();
        }
        return result;
    }
    
    @AuraEnabled
    public static string createLeads(List<ResponseWrapper> rWrapperList, string programId){
        system.debug('rWrapperList  -- > ' + rWrapperList);
        string result = '';
        try{
            
            Map<Id, ResponseWrapper> rWrapperMap = new Map<Id, ResponseWrapper>();
            if(rWrapperList.size()>0){
                for(ResponseWrapper rWrapper : rWrapperList){
                    rWrapperMap.put(rWrapper.appId, rWrapper);
                }
            }
            system.debug('rWrapperMap  -- > ' + rWrapperMap);
            
            Program__c prgrm = [SELECT Id, Name FROM Program__c WHERE Id =: programId];
            List<Program_Product__c> programProdList = [SELECT Id, Product__c FROM Program_Product__c WHERE Program__c =: programId];
            set<Id> prodIdSet = new set<Id>();
            for(Program_Product__c pProd : programProdList){
                prodIdSet.add(pProd.Product__c);
            }
            
            system.debug('prodIdSet  -- ' + prodIdSet);
            
            List<Placement_Application__c> placementApplicationList = [SELECT Id, Contact__c, Contact__r.Name, Contact__r.Email, Contact__r.Phone, Contact__r.LMS_Student_Id__c, Aptitude_Marks__c, Aptitude_Result__c, GD_Result__c, Personal_Interview_Result__c, Remarks__c, Placement_Paid_Service_Status__c	 
                                                                       FROM Placement_Application__c WHERE Id IN: rWrapperMap.keySet() AND Lead_Created__c = false];
            
            system.debug('placementApplicationList  -- > ' + placementApplicationList);
            
            List<Lead> ldListToBeInserted = new List<Lead>();
            Id retailLdRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Retail').getRecordTypeId();
            List<Placement_Application__c> pAppListToUpdate = new List<Placement_Application__c>();
            
            for(Placement_Application__c appRec : placementApplicationList){
                if(rWrapperMap.containsKey(appRec.Id) && rWrapperMap.get(appRec.Id) != null){
                    appRec.Lead_Created__c = true;
                    appRec.Placement_Paid_Service_Status__c = rWrapperMap.get(appRec.Id).status;
                    appRec.Remarks__c = rWrapperMap.get(appRec.Id).remarks;
                    pAppListToUpdate.add(appRec);
                    
                    Lead ld = new Lead();
                    ld.FirstName = appRec.Contact__r.LMS_Student_Id__c != null ? appRec.Contact__r.LMS_Student_Id__c : '';
                    ld.LastName = prgrm.Name;
                    ld.Status = 'New';
                    ld.Email = appRec.Contact__r.Email;
                    ld.Phone = appRec.Contact__r.Phone;
                    ld.LMS_StudentId__c = appRec.Contact__r.LMS_Student_Id__c;
                    ld.RecordTypeId = retailLdRecordTypeId;
                    ld.Placement_Application__c = appRec.Id;
                    ldListToBeInserted.add(ld);
                }
            }
            
            if(pAppListToUpdate.size()>0){
                update pAppListToUpdate;
            }
            
            
            if(ldListToBeInserted.size()>0){
                Database.insert(ldListToBeInserted,true);
                List<Product_Interested__c> prodInterestList = new List<Product_Interested__c>();
                
                for(Lead ld : ldListToBeInserted){
                    for(Id prodId : prodIdSet){
                        Product_Interested__c pIntRec = new Product_Interested__c();
                        pIntRec.Product__c = prodId;
                        pIntRec.Lead__c = ld.Id;
                        prodInterestList.add(pIntRec);                          
                    }
                }
                
                if(prodInterestList.size()>0){
                    insert prodInterestList;
                }
            }
            
            result = 'success';
            
        }
        catch(Exception e){
            system.debug('createLeads Method Error -- ' + e.getMessage());
            system.debug('AT LINE NO -- ' + e.getLineNumber());
            result = e.getMessage();
        }
        return result;
    }
    
    
    public class AllCombinedWrapper {
        @AuraEnabled
        public List<placementApplicationWrapper> allClearedApplications;
        @AuraEnabled
        public List<placementApplicationWrapper> piFailedApplications;
        @AuraEnabled
        public List<placementApplicationWrapper> partiallyClearedApplications;
        @AuraEnabled
        public List<placementApplicationWrapper> nonAttendedApplications;
        
        public allCombinedWrapper() {
            this.allClearedApplications = new list<placementApplicationWrapper>();
            this.piFailedApplications = new list<placementApplicationWrapper>();
            this.partiallyClearedApplications = new list<placementApplicationWrapper>();
            this.nonAttendedApplications = new list<placementApplicationWrapper>();
        }
    }
    
    public class placementApplicationWrapper {
        @AuraEnabled
        public Id applicationId;
        @AuraEnabled
        public Id studId;
        @AuraEnabled
        public string studLMSId;
        @AuraEnabled
        public string studName;
        @AuraEnabled
        public string studEmail;
        @AuraEnabled
        public string studPhone;
        @AuraEnabled
        public decimal aptiMarks;
        @AuraEnabled
        public string aptiResult;
        @AuraEnabled
        public string gdResult; 
        @AuraEnabled
        public string piResult;
        @AuraEnabled
        public string remarks;
        @AuraEnabled
        public string status;
        @AuraEnabled
        public List<OpportunityWrapper> relatedOpps;
        @AuraEnabled
        public List<LeadWrapper> relatedLeads;
        
        public placementApplicationWrapper(Id applicationId, Id studId, string studLMSId, string studName, string studEmail, string studPhone, decimal aptiMarks, string aptiResult, string gdResult, string piResult, string remarks, string status) {
            this.applicationId = applicationId;
            this.studId = studId;
            this.studLMSId = studLMSId;
            this.studName = studName; 
            this.studEmail = studEmail;
            this.studPhone = studPhone; 
            this.aptiMarks = aptiMarks;
            this.aptiResult = aptiResult; 
            this.gdResult = gdResult;
            this.piResult = piResult;
            this.remarks = remarks;
            this.status = status;  
            this.relatedOpps = new list<OpportunityWrapper>();
            this.relatedLeads = new list<LeadWrapper>();
        }
    }
    
    public class OpportunityWrapper {
        @AuraEnabled
        public Id oppId;
        @AuraEnabled
        public string oppName;
        
        public OpportunityWrapper(Id oppId, String oppName) {
            this.oppId = oppId;
            this.oppName = oppName;
        }
    }
    
    public class LeadWrapper {
        @AuraEnabled
        public Id ldId;
        @AuraEnabled
        public string ldName;
        
        public LeadWrapper(Id ldId, String ldName) {
            this.ldId = ldId;
            this.ldName = ldName;
        }
    }
    
    public class ResponseWrapper {
        @AuraEnabled
        public Id appId{get; set;}
        @AuraEnabled
        public string status{get; set;}
        @AuraEnabled
        public string remarks{get; set;}
        @AuraEnabled
        public decimal discount{get; set;}
    }
    
}