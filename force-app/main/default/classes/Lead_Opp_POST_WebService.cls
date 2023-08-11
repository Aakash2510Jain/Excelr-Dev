@RestResource(urlMapping='/getLeadOpportunityInfotest/*')
global with sharing Class Lead_Opp_POST_WebService {
    @HttpGet
    global static void  doGetLeadOppRecords(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        string recordId;
        string keyPrefix = req.requestURI.substring(0,3);
        system.debug('keyPrefix---->'+keyPrefix);
        if( keyPrefix == '00Q'){
            List<Lead> leadlist = [Select id,LastName,Email,Alternate_Email__c,Phone,Alternate_Phone__c,Course__c from  Lead where Id =:recordId];
            
        } if( keyPrefix == '006'){
            List<Opportunity> opplist = [Select id,Name,Email__c,Alternate_Email__c,Phone__c,Alternate_Phone__c,Course__c from  Opportunity where Id =:recordId];
        }
    }
    
}