public without sharing class ECAP_StudentsFormController {
    
    public string getCampaignId {get;set;}
    public string campaignId = System.currentPageReference().getParameters().get('cid');
    
    public ECAP_StudentsFormController() {
        try{
            if(!String.isBlank(campaignId)){
                System.debug('campaignId === > '+campaignId);
                getCampaignId = campaignId;
            }
        }
        catch(Exception e){
            system.debug('load error -- ' + e.getMessage());
        }
    }
    
    @RemoteAction
    public static string saveFormDetails(Lead led, string description, string campaignId){
        string result = '';
        try{
            system.debug('description -- ' + description);
            system.debug('led -- ' + led);
            system.debug('campaignId -- ' + campaignId);
            
            Campaign cmp = [SELECT Id, Name, Account__r.Name,Lead__c,Lead__r.Company, Description FROM Campaign WHERE Id =: campaignId];
            cmp.Description = description;
            update cmp;
            
            List<Lead> existingLeadList = [SELECT Id FROM Lead WHERE Email =: led.Email];
            if(existingLeadList.size() == 0){
                Id institutionRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Institution').getRecordTypeId();
                system.debug('institutionRecordTypeId ==> '+institutionRecordTypeId);
                Lead LeadRec = new Lead();
                LeadRec.FirstName = led.FirstName;
                LeadRec.LastName = led.LastName;
                LeadRec.Email = led.Email;
                LeadRec.Phone = led.Phone != null ? led.Phone : '';
                LeadRec.City = led.City != null ? led.City : '';
                LeadRec.Country = led.Country != null ? led.Country : '';
                LeadRec.State = led.State != null ? led.State : '';
                LeadRec.Street = led.Street != null ? led.Street : '';
                LeadRec.PostalCode = led.PostalCode != null ? led.PostalCode : '';
                LeadRec.RecordTypeId = '012N0000003t1cfIAA';
                existingLeadList.add(led);
                result = 'success';                
            }
            else{
                existingLeadList[0].FirstName = led.FirstName;
                existingLeadList[0].LastName = led.LastName;
                existingLeadList[0].Phone = led.Phone != null ? led.Phone : '';
                existingLeadList[0].City = led.City != null ? led.City : '';
                existingLeadList[0].Country = led.Country != null ? led.Country : '';
                existingLeadList[0].State = led.State != null ? led.State : '';
                existingLeadList[0].Street = led.Street != null ? led.Street : '';
                existingLeadList[0].PostalCode = led.PostalCode != null ? led.PostalCode : '';
                result = 'existing';
            }
            upsert existingLeadList;
                        
            if(cmp != null && existingLeadList.size()>0){
                List<CampaignMember> cmpMemberRec = [SELECT Id, ContactId FROM CampaignMember WHERE ContactId =: existingLeadList[0].Id];
                if(cmpMemberRec.size() == 0){
                    CampaignMember cMember = new CampaignMember();
                    cMember.LeadId = existingLeadList[0].Id;
                    cMember.CampaignId = campaignId;
                    insert cMember;
                }
            }   
            
            if(result == 'success'){
                Utility.sendRegistrationEmail1(existingLeadList[0].Id, cmp.Name, cmp.Lead__r.Company);
            }
        }
        catch(Exception e){
            system.debug('ERROR Campaign Form -- >> ' + e.getMessage() + ' At Line No -- >> ' + e.getLineNumber());
            return e.getMessage() + e.getLineNumber();
        }
        return result;
    } 

    @RemoteAction
    public static Campaign getCampaignDate(String campId){
        try{
            List<Campaign> existingCampaignList = [SELECT Id,Name,StartDate,EndDate FROM Campaign WHERE Id=: campId LIMIT 1];
            return existingCampaignList[0];
        }catch(exception e){
            return null;
        }
    }
    
}