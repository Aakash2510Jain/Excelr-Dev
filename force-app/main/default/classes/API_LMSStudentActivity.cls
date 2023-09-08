/*
Author : Esha Raaz
*/

@RestResource(urlMapping = '/post_student_activity')
global without sharing class API_LMSStudentActivity {
    global static List<String> listOfRecordIds = New List<String>();

    @HttpPost
    global static void postLMS_createStudentActivity(){
        DateTime processingStartTime = System.now();
        RestRequest req = RestContext.request;
        Blob body = req.requestBody;
        String requestString = body.toString();
        System.debug('--- rquestString'+ requestString);
        List<API_LMSStudentActivityWrapper> rWrapperList = (List<API_LMSStudentActivityWrapper>)JSON.deserialize(requestString, List<API_LMSStudentActivityWrapper>.class);
        System.debug('--- rWrapperList'+ rWrapperList);    
        String responseBody;
        
            if(!rWrapperList.isEmpty()){
                String getResponse = processStudentActivityRequest(rWrapperList);

                if(getResponse == 'Success'){
                    responseBody = JSON.serialize(new IntegrationWrapper.APIResponseWrapper('Success', getResponse));
                    HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/post_student_activity', 'POST', 200, processingStartTime, System.now(),listOfRecordIds); //Log this request
                    RestContext.response.responseBody = Blob.valueOf(responseBody);
                }else{
                    responseBody = JSON.serialize(new IntegrationWrapper.APIResponseWrapper('Error', getResponse));
                    HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/post_student_activity', 'POST', 400, processingStartTime, System.now(),listOfRecordIds); //Log this request
                    RestContext.response.responseBody = Blob.valueOf(responseBody);
                }
            }
    }

    private static string processStudentActivityRequest(List<API_LMSStudentActivityWrapper> stuActivityWrapperList){
        try{
            system.debug('stuActivityWrapperList ==> '+stuActivityWrapperList);
            set<string> setOfLmsStudentId = New set<string>();
            Map<string,string> mapOfStuIdByExternalId = New Map<string,string>();
            List<Contact> listOfExistingStudentByStuId = New List<Contact>();
            for(API_LMSStudentActivityWrapper stuActivity : stuActivityWrapperList){
                
                setOfLmsStudentId.add(string.valueOf(stuActivity.student_id));
                system.debug('setOfLmsStudentId'+setOfLmsStudentId);
            }
            system.debug('setOfLmsStudentId ==> '+setOfLmsStudentId);
            system.debug('Size of Set ==> '+setOfLmsStudentId.size());
            if(!setOfLmsStudentId.isEmpty()){
                listOfExistingStudentByStuId = [SELECT Id,Name,LMS_Student_Id__c FROM Contact WHERE LMS_Student_Id__c In:setOfLmsStudentId ];
                system.debug('listOfExistingStudentByStuId ==> '+listOfExistingStudentByStuId);
            }
            if(!listOfExistingStudentByStuId.isEmpty()){
                for(Contact conRec : listOfExistingStudentByStuId){
                    mapOfStuIdByExternalId.put(conRec.LMS_Student_Id__c, conRec.Id);
                }
            }

            List<Student_Activity__c> listOfStudentActivityToInsert = New List<Student_Activity__c>();
            for(API_LMSStudentActivityWrapper studentActivity : stuActivityWrapperList){
                Student_Activity__c studentActivityToInsert = New Student_Activity__c();
                if(!String.isBlank(studentActivity.student_id)){
                    if(mapOfStuIdByExternalId.containsKey(studentActivity.student_id)){
                        studentActivityToInsert.Student__c = mapOfStuIdByExternalId.get(studentActivity.student_id);
                    }else{
                        return 'Error: Student Id is not found for ' + studentActivity.student_id;
                    }
                }
                if(!String.isBlank(studentActivity.activityDescription)){
                    studentActivityToInsert.Description__c = studentActivity.activityDescription;
                }
                if(studentActivity.activityDate != null){
                    studentActivityToInsert.Activity_Date__c = (Date)JSON.deserialize('"' + String.valueOf(studentActivity.activityDate) + '"', Date.class);
                    // studentActivityToInsert.Activity_Date__c = studentActivity.activityDate;
                }
                listOfStudentActivityToInsert.add(studentActivityToInsert);
            }
            insert listOfStudentActivityToInsert;
            if(!listOfStudentActivityToInsert.isEmpty()){
                for(Student_Activity__c stu : listOfStudentActivityToInsert){
                    listOfRecordIds.add(stu.Id);
                }
            }
            return 'SUCCESS';
        }catch(Exception e){
            return e.getMessage()+e.getLineNumber();
        }
    }
}