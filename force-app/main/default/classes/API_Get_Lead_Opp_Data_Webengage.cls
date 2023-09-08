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
                List<Lead> leadlist = [Select Id, Name,LastName,Course__c,Email, Alternate_Email__c,Phone,Alternate_Phone__c,Status,Branch__c,CID__c,City__c,Country__c,
                Current_Domain__c,Designation__c,Enquired_Course__c,LID__c,Lead_Gen_Path__c,LeadSource,Medium__c,Next_follow_up_date_time__c,Organisation__c,
                Enter_UTM_Link__c,Qualification__c,Reason_For_Dead__c,State__c,Year_of_Experience__c,Owner_Email__c,CreatedDate from  Lead where Id =:recordId];
                
                ResponseWrapper.UserAttributes attributes = new ResponseWrapper.UserAttributes();
                
                string course = leadList[0].Course__c != null ? leadList[0].Course__c : 'NA';
                string AlternatePhone = leadList[0].Alternate_Phone__c != null ? leadList[0].Alternate_Phone__c : 'NA';
                string AlternateEmail = leadList[0].Alternate_Email__c != null ? leadList[0].Alternate_Email__c : 'NA';
                string email = leadList[0].Email != null ? leadList[0].Email : leadList[0].alternate_Email__c != null ?leadList[0].alternate_Email__c : 'NA';
                string phone = leadList[0].Phone != null ? leadList[0].Phone : leadList[0].Alternate_Phone__c != null ?leadList[0].Alternate_Phone__c : String.valueOf((Datetime.now()).getTime());

                /* Added By Esha */
                string branch = leadList[0].Branch__c != null ? leadList[0].Branch__c : leadList[0].Branch__c != null ?leadList[0].Branch__c : 'NA';
                string CID = leadList[0].CID__c != null ? leadList[0].CID__c : leadList[0].CID__c != null ?leadList[0].CID__c : 'NA';
                string city = leadList[0].City__c != null ? leadList[0].City__c : leadList[0].City__c != null ?leadList[0].City__c : 'NA';
                string country = leadList[0].Country__c != null ? leadList[0].Country__c : leadList[0].Country__c != null ?leadList[0].Country__c : 'NA';
                string domain = leadList[0].Current_Domain__c != null ? leadList[0].Current_Domain__c : leadList[0].Current_Domain__c != null ?leadList[0].Current_Domain__c : 'NA';
                string designation = leadList[0].Designation__c != null ? leadList[0].Designation__c : leadList[0].Designation__c != null ?leadList[0].Designation__c : 'NA';
                string enquiredCourse = leadList[0].Enquired_Course__c != null ? leadList[0].Enquired_Course__c : leadList[0].Enquired_Course__c != null ?leadList[0].Enquired_Course__c : 'NA';
                string LID = leadList[0].LID__c != null ? leadList[0].LID__c : leadList[0].LID__c != null ?leadList[0].LID__c : 'NA';
                string leadGenPath = leadList[0].Lead_Gen_Path__c != null ? leadList[0].Lead_Gen_Path__c : leadList[0].Lead_Gen_Path__c != null ?leadList[0].Lead_Gen_Path__c : 'NA';
                string source = leadList[0].LeadSource != null ? leadList[0].LeadSource : leadList[0].LeadSource != null ?leadList[0].LeadSource : 'NA';
                string status = leadList[0].Status != null ? leadList[0].Status : leadList[0].Status != null ?leadList[0].Status : 'NA';
                string medium = leadList[0].Medium__c != null ? leadList[0].Medium__c : leadList[0].Medium__c != null ?leadList[0].Medium__c : 'NA';
                string nextFollowup = string.valueOf(leadList[0].Next_follow_up_date_time__c.format('yyyy-MM-dd\'T\'HH:mm:ss')) != null ? string.valueOf(leadList[0].Next_follow_up_date_time__c.format('yyyy-MM-dd\'T\'HH:mm:ss')) : string.valueOf(leadList[0].Next_follow_up_date_time__c.format('yyyy-MM-dd\'T\'HH:mm:ss')) != null ? string.valueOf(leadList[0].Next_follow_up_date_time__c.format('yyyy-MM-dd\'T\'HH:mm:ss')) : 'NA';
                string organisation = leadList[0].Organisation__c != null ? leadList[0].Organisation__c : leadList[0].Organisation__c != null ?leadList[0].Organisation__c : 'NA';
                string pageURL = leadList[0].Enter_UTM_Link__c != null ? leadList[0].Enter_UTM_Link__c : leadList[0].Enter_UTM_Link__c != null ?leadList[0].Enter_UTM_Link__c : 'NA';
                string qualification = leadList[0].Qualification__c != null ? leadList[0].Qualification__c : leadList[0].Qualification__c != null ?leadList[0].Qualification__c : 'NA';
                string reasonForDead = leadList[0].Reason_For_Dead__c != null ? leadList[0].Reason_For_Dead__c : leadList[0].Reason_For_Dead__c != null ?leadList[0].Reason_For_Dead__c : 'NA';
                string state = leadList[0].State__c != null ? leadList[0].State__c : leadList[0].State__c != null ?leadList[0].State__c : 'NA';
                string leadStatus = leadList[0].Status != null ? leadList[0].Status : leadList[0].Status != null ?leadList[0].Status : 'NA';
                //Boolean whatsappOptIn = leadList[0].Whatsapp_Opt_in__c != null ? leadList[0].Whatsapp_Opt_in__c : leadList[0].Whatsapp_Opt_in__c != null ?leadList[0].Whatsapp_Opt_in__c : 'NA';
                string yearOfExperience = leadList[0].Year_of_Experience__c != null ? leadList[0].Year_of_Experience__c : leadList[0].Year_of_Experience__c != null ?leadList[0].Year_of_Experience__c : 'NA';
                string leadId = leadList[0].Id != null ? leadList[0].Id : leadList[0].Id != null ?leadList[0].Id : 'NA';
                string leadOwner = leadList[0].Owner_Email__c != null ? leadList[0].Owner_Email__c : leadList[0].Owner_Email__c != null ?leadList[0].Owner_Email__c : 'NA';
                string createddate = string.valueOf(leadList[0].CreatedDate.format('yyyy-MM-dd\'T\'HH:mm:ss')) != null ? string.valueOf(leadList[0].CreatedDate.format('yyyy-MM-dd\'T\'HH:mm:ss')) : string.valueOf(leadList[0].CreatedDate.format('yyyy-MM-dd\'T\'HH:mm:ss')) != null ? string.valueOf(leadList[0].CreatedDate.format('yyyy-MM-dd\'T\'HH:mm:ss')) : 'NA';
                
                attributes.Course = course;
                attributes.Id = leadList[0].Id;
                // attributes.lead_status = leadList[0].Status;
                attributes.Alternate_Phone = AlternatePhone;
                attributes.Alternate_Email = AlternateEmail;
                attributes.lead_id = leadList[0].LID__c;
                attributes.Branch = branch;
                attributes.CID = CID;
                attributes.City = city;
                attributes.Country = country;
                attributes.Created_Date = createddate;
                attributes.Current_Domain = domain;
                attributes.Designation = designation;
                attributes.Email = email;
                attributes.Enquired_Course = enquiredCourse;
                attributes.LID = LID;
                attributes.Lead_Gen_Path = leadGenPath;
                attributes.Lead_Owner = leadOwner;
                attributes.Lead_Source = source;
                attributes.Lead_Status = status;
                attributes.Medium = medium;
                attributes.Next_follow_up_datetime = nextFollowup;
                attributes.Organisation = organisation;
                attributes.Page_URL = pageURL;
                attributes.Qualification = qualification;
                attributes.Reason_for_Dead = reasonForDead;
                attributes.State = state;
                // attributes.Whatsapp_Opt_in = 
                attributes.Years_of_Experience = yearOfExperience;
                attributes.lead_id = leadlist[0].Id;
                attributes.leadstatus = status;
                
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
                List<Opportunity> opplist = [SELECT Id,Name,Course__c,Phone__c,Alternate_Phone__c,Email__c,Alternate_Email__c,StageName,Branch__c,CID__c,City__c,Country__c,
                Current_Domain__c,Designation__c,Enquired_Course__c,LID__c,Lead_Gen_Path__c,LeadSource,Medium__c,Next_follow_up_date_time__c,Organisation__c,
                Enter_UTM_Link__c,Qualification__c,Reason_For_Dead__c,State__c,Year_of_Experience__c,Owner_Email__c,CreatedDate,Status__c from  Opportunity where Id =:recordId];
                
                ResponseWrapper.UserAttributes attributes = new ResponseWrapper.UserAttributes();
                
                string course = opplist[0].Course__c != null ? opplist[0].Course__c : 'NA';
                string AlternatePhone = opplist[0].Alternate_Phone__c != null ? opplist[0].Alternate_Phone__c : 'NA';
                string AlternateEmail = opplist[0].Alternate_Email__c != null ? opplist[0].Alternate_Email__c : 'NA';
                string email = opplist[0].Email__c != null ? opplist[0].Email__c : opplist[0].alternate_Email__c != null ?opplist[0].alternate_Email__c : 'NA';
                string phone = opplist[0].Phone__c != null ? opplist[0].Phone__c : opplist[0].Alternate_Phone__c != null ?opplist[0].Alternate_Phone__c : String.valueOf((Datetime.now()).getTime());


                string branch = opplist[0].Branch__c != null ? opplist[0].Branch__c : opplist[0].Branch__c != null ?opplist[0].Branch__c : 'NA';
                string CID = opplist[0].CID__c != null ? opplist[0].CID__c : opplist[0].CID__c != null ?opplist[0].CID__c : 'NA';
                string city = opplist[0].City__c != null ? opplist[0].City__c : opplist[0].City__c != null ?opplist[0].City__c : 'NA';
                string country = opplist[0].Country__c != null ? opplist[0].Country__c : opplist[0].Country__c != null ?opplist[0].Country__c : 'NA';
                string domain = opplist[0].Current_Domain__c != null ? opplist[0].Current_Domain__c : opplist[0].Current_Domain__c != null ?opplist[0].Current_Domain__c : 'NA';
                string designation = opplist[0].Designation__c != null ? opplist[0].Designation__c : opplist[0].Designation__c != null ?opplist[0].Designation__c : 'NA';
                string enquiredCourse = opplist[0].Enquired_Course__c != null ? opplist[0].Enquired_Course__c : opplist[0].Enquired_Course__c != null ?opplist[0].Enquired_Course__c : 'NA';
                string LID = opplist[0].LID__c != null ? opplist[0].LID__c : opplist[0].LID__c != null ?opplist[0].LID__c : 'NA';
                string leadGenPath = opplist[0].Lead_Gen_Path__c != null ? opplist[0].Lead_Gen_Path__c : opplist[0].Lead_Gen_Path__c != null ?opplist[0].Lead_Gen_Path__c : 'NA';
                string source = opplist[0].LeadSource != null ? opplist[0].LeadSource : opplist[0].LeadSource != null ?opplist[0].LeadSource : 'NA';
                string status = opplist[0].Status__c != null ? opplist[0].Status__c : opplist[0].Status__c != null ?opplist[0].Status__c : 'NA';
                string medium = opplist[0].Medium__c != null ? opplist[0].Medium__c : opplist[0].Medium__c != null ?opplist[0].Medium__c : 'NA';
                string nextFollowup = string.valueOf(opplist[0].Next_follow_up_date_time__c.format('yyyy-MM-dd\'T\'HH:mm:ss')) != null ? string.valueOf(opplist[0].Next_follow_up_date_time__c.format('yyyy-MM-dd\'T\'HH:mm:ss')) : string.valueOf(opplist[0].Next_follow_up_date_time__c.format('yyyy-MM-dd\'T\'HH:mm:ss')) != null ? string.valueOf(opplist[0].Next_follow_up_date_time__c.format('yyyy-MM-dd\'T\'HH:mm:ss')) : 'NA';
                string organisation = opplist[0].Organisation__c != null ? opplist[0].Organisation__c : opplist[0].Organisation__c != null ?opplist[0].Organisation__c : 'NA';
                string pageURL = opplist[0].Enter_UTM_Link__c != null ? opplist[0].Enter_UTM_Link__c : opplist[0].Enter_UTM_Link__c != null ?opplist[0].Enter_UTM_Link__c : 'NA';
                string qualification = opplist[0].Qualification__c != null ? opplist[0].Qualification__c : opplist[0].Qualification__c != null ?opplist[0].Qualification__c : 'NA';
                string reasonForDead = opplist[0].Reason_For_Dead__c != null ? opplist[0].Reason_For_Dead__c : opplist[0].Reason_For_Dead__c != null ?opplist[0].Reason_For_Dead__c : 'NA';
                string state = opplist[0].State__c != null ? opplist[0].State__c : opplist[0].State__c != null ?opplist[0].State__c : 'NA';
                string leadStatus = opplist[0].Status__c != null ? opplist[0].Status__c : opplist[0].Status__c != null ?opplist[0].Status__c : 'NA';
                //Boolean whatsappOptIn = leadList[0].Whatsapp_Opt_in__c != null ? leadList[0].Whatsapp_Opt_in__c : leadList[0].Whatsapp_Opt_in__c != null ?leadList[0].Whatsapp_Opt_in__c : 'NA';
                string yearOfExperience = opplist[0].Year_of_Experience__c != null ? opplist[0].Year_of_Experience__c : opplist[0].Year_of_Experience__c != null ?opplist[0].Year_of_Experience__c : 'NA';
                string leadId = opplist[0].Id != null ? opplist[0].Id : opplist[0].Id != null ?opplist[0].Id : 'NA';
                string leadOwner = opplist[0].Owner_Email__c != null ? opplist[0].Owner_Email__c : opplist[0].Owner_Email__c != null ?opplist[0].Owner_Email__c : 'NA';
                string createddate = string.valueOf(opplist[0].CreatedDate.format('yyyy-MM-dd\'T\'HH:mm:ss')) != null ? string.valueOf(opplist[0].CreatedDate.format('yyyy-MM-dd\'T\'HH:mm:ss')) : string.valueOf(opplist[0].CreatedDate.format('yyyy-MM-dd\'T\'HH:mm:ss')) != null ? string.valueOf(opplist[0].CreatedDate.format('yyyy-MM-dd\'T\'HH:mm:ss')) : 'NA';
                
                attributes.Course = course;
                attributes.Id = opplist[0].Id;
                attributes.Alternate_Phone = AlternatePhone;
                attributes.Alternate_Email = AlternateEmail;
                attributes.lead_id = opplist[0].LID__c;
                attributes.Branch = branch;
                attributes.CID = CID;
                attributes.City = city;
                attributes.Country = country;
                attributes.Created_Date = createddate;
                attributes.Current_Domain = domain;
                attributes.Designation = designation;
                attributes.Email = email;
                attributes.Enquired_Course = enquiredCourse;
                attributes.LID = LID;
                attributes.Lead_Gen_Path = leadGenPath;
                attributes.Lead_Owner = leadOwner;
                attributes.Lead_Source = source;
                attributes.Lead_Status = status;
                attributes.Medium = medium;
                attributes.Next_follow_up_datetime = nextFollowup;
                attributes.Organisation = organisation;
                attributes.Page_URL = pageURL;
                attributes.Qualification = qualification;
                attributes.Reason_for_Dead = reasonForDead;
                attributes.State = state;
                // attributes.Whatsapp_Opt_in = 
                attributes.Years_of_Experience = yearOfExperience;
                attributes.lead_id = opplist[0].Id;
                attributes.leadstatus = status;
                
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