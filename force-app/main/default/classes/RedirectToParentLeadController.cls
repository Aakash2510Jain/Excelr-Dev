public without sharing class RedirectToParentLeadController {
    @auraEnabled
    public static Lead getLeadDetails(string leadid){
        List<Lead> leadRecordList = new List<Lead>();
        leadRecordList = [Select Lead_URL__c,Parent_Lead_Id__c,Lead_URL_to_Redirect__c From Lead where To_Be_Deleted__c = true and id =: leadid limit 1];
        if(!leadRecordList.isEmpty()){
            return leadRecordList[0];
        }else{
            return null;
        }
    }
}