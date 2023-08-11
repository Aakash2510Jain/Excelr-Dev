@RestResource(urlMapping='/getLeadOpportunityInfo/*')
//https://excelr2--dev.sandbox.my.salesforce-sites.com/postData/services/apexrest/getLeadOpportunityInfo?id=00QN000000BCeaz
global class API_Get_Lead_Opp_Data_Webengage {
    @HttpGet
    global static Map<String, List<ResponseWrapper.UserRecord>> doGetLeadOppRecords(){
        RestResponse res = RestContext.response;
        Map<String,String> paramsMap = RestContext.request.params;
        String recordId = paramsMap.get('id');
        String jsonString = '';
        system.debug('recordId--->'+recordId);
        
        if(!string.isBlank(recordId)){
            String sObjName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
            
            system.debug('sObjName---->'+sObjName);
            if( sObjName == 'Lead'){
                List<Lead> leadlist = [Select Id, Name,LastName,Course__c,Email, Alternate_Email__c,Phone,Alternate_Phone__c,Status from  Lead where Id =:recordId];
                
                ResponseWrapper.UserAttributes attributes = new ResponseWrapper.UserAttributes();
                
                string course = leadList[0].Course__c != null ? leadList[0].Course__c : 'NA';
                string AlternatePhone = leadList[0].Alternate_Phone__c != null ? leadList[0].Alternate_Phone__c : 'NA';
                string AlternateEmail = leadList[0].Alternate_Email__c != null ? leadList[0].Alternate_Email__c : 'NA';
                string email = leadList[0].Email != null ? leadList[0].Email : leadList[0].alternate_Email__c != null ?leadList[0].alternate_Email__c : 'NA';
                string phone = leadList[0].Phone != null ? leadList[0].Phone : leadList[0].Alternate_Phone__c != null ?leadList[0].Alternate_Phone__c : String.valueOf((Datetime.now()).getTime());
                
                attributes.Course = course;
                attributes.Id = leadList[0].Id;
                attributes.lead_status = leadList[0].Status;
                attributes.AlternatePhone = AlternatePhone;
                attributes.AlternateEmail = AlternateEmail;
                attributes.lead_id = leadList[0].LID__c;
                
                ResponseWrapper.UserRecord userRecord = new ResponseWrapper.UserRecord();
                userRecord.firstName = leadList[0].LastName;
                userRecord.email = email;
                userRecord.userId = phone;
                userRecord.phone = phone;
                userRecord.attributes = attributes;
                
                Map<String, List<ResponseWrapper.UserRecord>> userData = new Map<String, List<ResponseWrapper.UserRecord>>{
                    'users' => new List<ResponseWrapper.UserRecord>{userRecord}
                };
                    return userData;
            } else if( sObjName == 'Opportunity'){
                List<Opportunity> opplist = [SELECT Id,Name,Course__c,Phone__c,Alternate_Phone__c,Email__c,Alternate_Email__c,StageName from  Opportunity where Id =:recordId];
                
                ResponseWrapper.UserAttributes attributes = new ResponseWrapper.UserAttributes();
                
                string course = opplist[0].Course__c != null ? opplist[0].Course__c : 'NA';
                string AlternatePhone = opplist[0].Alternate_Phone__c != null ? opplist[0].Alternate_Phone__c : 'NA';
                string AlternateEmail = opplist[0].Alternate_Email__c != null ? opplist[0].Alternate_Email__c : 'NA';
                string email = opplist[0].Email__c != null ? opplist[0].Email__c : opplist[0].alternate_Email__c != null ?opplist[0].alternate_Email__c : 'NA';
                string phone = opplist[0].Phone__c != null ? opplist[0].Phone__c : opplist[0].Alternate_Phone__c != null ?opplist[0].Alternate_Phone__c : String.valueOf((Datetime.now()).getTime());
                
                attributes.Course = course;
                attributes.Id = opplist[0].Id;
                attributes.lead_status = opplist[0].StageName;
                attributes.AlternatePhone = AlternatePhone;
                attributes.AlternateEmail = AlternateEmail;
                attributes.lead_id = opplist[0].LID__c;
                
                ResponseWrapper.UserRecord userRecord = new ResponseWrapper.UserRecord();
                userRecord.firstName = opplist[0].Name;
                userRecord.email = email;
                userRecord.userId = phone;
                userRecord.phone = phone;
                userRecord.attributes = attributes;
                system.debug('userRecord==>'+userRecord);
                Map<String, List<ResponseWrapper.UserRecord>> userData = new Map<String, List<ResponseWrapper.UserRecord>>{
                    'users' => new List<ResponseWrapper.UserRecord>{userRecord}
                };
                    system.debug('userData--->'+userData);
                return userData;
            }
            return null;
        }else{
            return null;
        }
    }
}
/*"{\n  \"users\" : [ {\n    \"userId\" : \"1691683082449\",\n    \"phone\" : \"1691683082449\",\n    \"firstname\" : \"jain\",\n    \"email\" : \"NA\",\n    \"attributes\" : {\n      \"Status\" : \"Lead Nurturing\",\n      \"Id\" : \"00QN000000BCeazMAD\",\n      \"Course\" : \"Artificial Intelligence\",\n      \"AlternatePhone\" : \"NA\",\n      \"AlternateEmail\" : \"NA\"\n    }\n  } ]\n}"
* */