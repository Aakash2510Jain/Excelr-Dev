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
    public static string saveFormDetails(Contact con, string description, string campaignId){
        try{
            system.debug('description -- ' + description);
            system.debug('con -- ' + con);
            system.debug('campaignId -- ' + campaignId);
            
            List<Contact> existingContactList = [SELECT Id FROM Contact WHERE Email =: con.Email];
            if(existingContactList.size()>0){
                existingContactList[0].Email = con.Email;
            }
            else{
                existingContactList.add(con);
            }
            upsert existingContactList;
            
            Campaign cmp = [SELECT Id, Description FROM Campaign WHERE Id =: campaignId];
            cmp.Description = description;
            update cmp;
            
            if(cmp != null){
                CampaignMember cMember = new CampaignMember();
                cMember.ContactId = existingContactList[0].Id;
                cMember.CampaignId = campaignId;
                insert cMember;
            }            
            return 'success';
        }
        catch(Exception e){
            return e.getMessage();
        }
    } 
    
}