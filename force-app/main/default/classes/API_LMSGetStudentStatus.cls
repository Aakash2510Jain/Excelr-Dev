/*
* Author : Anjali Singh
*/

@RestResource(urlMapping = '/get_student_status')
global with sharing class API_LMSGetStudentStatus{
    
    global static List<String> listOfRecordIds = New List<String>();

    @HttpGet
    global static void fetchLMSStudentStatus(){
        
        try{
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            
            /*Blob body = req.requestBody;
            String requestString = body.toString();
            System.debug('--- requestString' + requestString);*/
            
            res.addHeader('Content-Type', 'application/json');
            String studentId = '';
            studentId = req.params.get('student_ids');
            System.debug('studentId =====> ' + studentId);
            
            if (!string.isBlank(studentId) || studentId != '') {
                
                List<string> allStudentIdsList = new List<string>();
                allStudentIdsList = studentId.split(',');
                //getStudentBatch studentIdsList = (getStudentBatch) JSON.deserialize(requestString, getStudentBatch.class);
                String jsonBodyToSend = processWrapper(allStudentIdsList);
                System.debug('jsonBodyToSend =====> ' + jsonBodyToSend);
                
                res.responseBody = Blob.valueOf(jsonBodyToSend);
                if(jsonBodyToSend.containsIgnoreCase('error')){
                    res.statusCode = 400;
                }
                else{
                    res.statusCode = 200;
                }
            } 
            else{
                //RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new IntegrationWrapper.APIResponseWrapper('Error', '[{"ref": "003N000001xyPbwIAE","message": "Couldn\'t process this lead due to error"}, { "ref": "003N000001xyPbwIAE","message": "Couldn\'t process this lead due to error" }]')));
                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new IntegrationWrapper.APIResponseWrapper('Error', 'No Ids Found!!')));
                res.statusCode = 400;
            }

            String requestString = req.requestURI + '?' + req.requestURI.substring(req.requestURI.indexOf('?')+1);
            String responseBody = res.responseBody.toString();
            Integer statusCode = res.statusCode;
            HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/get_student_status', 'GET', statusCode, System.now(), System.now(),null);
            
        } 
        catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('API_LMSGetStudentStatus', 'fetchLMSStudentStatus', e, null);
        }
    }
    
    
    private static string processWrapper(List<string> idList){
        try{
            string response = '';
            system.debug('idList -->> ' + idList);
            
            List<Lead> leadList = [SELECT Id, LMS_StudentId__c, Name, Email FROM Lead WHERE LMS_StudentId__c IN: idList];
            system.debug('leadList -->> ' + leadList);
            
            Map<String, Lead> mapOfLMSIdByLeadId = new Map<String, Lead>();
            if(leadList.size()>0){
                for(Lead ld : leadList){
                    mapOfLMSIdByLeadId.put(ld.LMS_StudentId__c, ld);
                }
            }
            system.debug('mapOfLMSIdByLeadId -->> ' + mapOfLMSIdByLeadId);
            
            List<Contact> conList = [SELECT Id, LMS_Student_Id__c, referrer__r.LMS_StudentId__c, referrer__r.Name, referrer__r.Email, Referral_Email__c, Referral_Phone__c, referrer__c, Refree_Mob_No__c FROM Contact WHERE LMS_Student_Id__c IN: idList];
            system.debug('conList -->> ' + conList);
            
            Map<String, Contact> mapOfLMSIdByContactId = new Map<String, Contact>();
            if(conList.size()>0){
                for(Contact con : conList){
                    mapOfLMSIdByContactId.put(con.LMS_Student_Id__c, con);
                }
            }
            system.debug('mapOfLMSIdByContactId -->> ' + mapOfLMSIdByContactId);
            string errorMsg = '';
            
            sendErrorAPIResponse errorResponse = new sendErrorAPIResponse();
            List<cls_message> listOf = new List<cls_message>();
            cls_message msgs = new cls_message();
            
            List<student_details> sendAllDetails = new List<student_details> ();        
            for(String id : idList){
                system.debug('id -- ' + id);
                
                student_details sDetails = new student_details();
                sDetails.student_id = id;
                cls_refered_by_details refDetails = new cls_refered_by_details();
                
                if(mapOfLMSIdByLeadId.containsKey(id)){
                    sDetails.status = false;
                    refDetails.referrer_id = mapOfLMSIdByLeadId.get(id).LMS_StudentId__c;
                    refDetails.referrer_name = mapOfLMSIdByLeadId.get(id).Name;
                    refDetails.referrer_email = mapOfLMSIdByLeadId.get(id).Email;
                    sDetails.refered_by_details  = refDetails;
                }  
                else if(mapOfLMSIdByContactId.containsKey(id)){
                    sDetails.status = true;
                    refDetails.referrer_id = mapOfLMSIdByContactId.get(id).LMS_Student_Id__c;
                    refDetails.referrer_name = mapOfLMSIdByContactId.get(id).referrer__r.Name;
                    refDetails.referrer_email = mapOfLMSIdByContactId.get(id).referrer__r.Email;
                    sDetails.refered_by_details  = refDetails;
                }               
                else{
                    refDetails.referrer_id = 'Student Id doesn\'t exist';
                    refDetails.referrer_name = 'Student Id doesn\'t exist';
                    refDetails.referrer_email = 'Student Id doesn\'t exist';
                    sDetails.refered_by_details  = refDetails;
                    
                    /*errorResponse.status = 'Error';
                    msgs.ref = id;
                    msgs.msg = 'does not exist';     
                    listOf.add(msgs);
                    errorResponse.message = listOf;
                    errorMsg = JSON.serialize(errorResponse);*/
                }
                sendAllDetails.add(sDetails);   
            }
            
            /*if(errorMsg != '')
                return errorMsg;
            else
                return JSON.serialize(sendAllDetails);
            
            if(errorMsg != ''){
                response = errorMsg + '{ "status":"success","message": ' + JSON.serialize(sendAllDetails) + '}';
            }
            else{  */
            //}

           
            response = '{ "status":"success","message": ' + JSON.serialize(sendAllDetails) + '}';
            return response;                       
        }
        catch(Exception e){
            system.debug('Error :: ' + e.getMessage());
            system.debug('At Line No :: ' + e.getLineNumber());
            return e.getMessage();
        }
        
    }
    
    
    public class getStudentBatch{
        public List<String> student_id;
    }
    
    public class sendAPIResponse{
        public List<student_details> allStudentDetails;
    }
    
    public class student_details{
        public boolean status;	//
        public cls_refered_by_details refered_by_details;
        public String student_id;	//003N000001xyPbwIAE
    }
    public class cls_refered_by_details {
        public String referrer_id;	//cust-1311
        public String referrer_name;	//XYZ
        public String referrer_email;	//referrer.email123@mailinator.com
    }
    
    public class sendErrorAPIResponse{
        public string status;
        public cls_message[] message;
    }
    
    public class cls_message {
        public string ref;	
        public string msg;	
    }   
    
    /*
* [
{
"status": "",
"refered_by_details": {
"referrer_id": "cust-1311",
"referrer_name": "XYZ",
"referrer_email": "referrer.email123@mailinator.com"
},
"student_id": "003N000001xyPbwIAE"
},
{
"status": "",
"refered_by_details": {
"referrer_id": "cust-1311",
"referrer_name": "XYZ",
"referrer_email": "referrer.email123@mailinator.com"
},
"student_id": "003N000001xyPbwIAE"
}
] */
    
    
    
}