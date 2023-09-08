/*
Author : Esha Raaz
*/

@RestResource(urlMapping = '/studentattendance')
global without sharing class API_LMSStudentAttendance {
    public API_LMSStudentAttendance() {}
    global static List<String> listOfRecordIds = New List<String>();

    @HttpPost
    global static void postLMS_createStudentAttendance(){

        DateTime processingStartTime = System.now();
        RestRequest req = RestContext.request;
        Blob body = req.requestBody;
        String requestString = body.toString();
        System.debug('--- rquestString'+ requestString);
        List<API_LMSStudentAttendanceWrapper> rWrapperList = (List<API_LMSStudentAttendanceWrapper>)JSON.deserialize(requestString, List<API_LMSStudentAttendanceWrapper>.class);
        System.debug('--- rWrapperList'+ rWrapperList);    
        String responseBody;

        if(!rWrapperList.isEmpty()){
            String getResponse = processStudentAttendanceRequest(rWrapperList);

            if(getResponse == 'Success'){
                responseBody = JSON.serialize(new IntegrationWrapper.APIResponseWrapper('Success', getResponse));
                HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/studentattendance', 'POST', 200, processingStartTime, System.now(),listOfRecordIds); //Log this request
                RestContext.response.responseBody = Blob.valueOf(responseBody);
            }else{
                responseBody = JSON.serialize(new IntegrationWrapper.APIResponseWrapper('Error', getResponse));
                HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/studentattendance', 'POST', 400, processingStartTime, System.now(),listOfRecordIds); //Log this request
                RestContext.response.responseBody = Blob.valueOf(responseBody);
            }
        }
    }

    private static string processStudentAttendanceRequest(List<API_LMSStudentAttendanceWrapper> stuAttendanceWrapperList){
        try{
            system.debug('stuAttendanceWrapperList ==> '+stuAttendanceWrapperList);
            set<string> setOfLmsStudentId = New set<string>();
            set<string> setOfLmsProductId = New set<string>();
            set<string> setOfLmsBatchId = New set<string>();
            List<Contact> listOfExistingStudentByStuId = New List<Contact>();
            List<Product2> listOfExistingProductByLMSId = New List<Product2>();
            List<Batch__c> listOfExistingBatchByBatchNo = New List<Batch__c>();
            Map<string,string> mapOfStuIdByExternalId = New Map<string,string>();
            Map<string,string> mapOfProdIdByExternalId = New Map<string,string>();
            Map<string,string> mapOfBatchIdByExternalId = New Map<string,string>();
            List<Student_Attendance__c> listOfStuAttendanceToUpsert = New List<Student_Attendance__c>();

            if(!stuAttendanceWrapperList.isEmpty()){
                for(API_LMSStudentAttendanceWrapper studentAttendance : stuAttendanceWrapperList){
                    setOfLmsStudentId.add(string.valueOf(studentAttendance.student_id));
                    setOfLmsProductId.add(string.valueOf(studentAttendance.product_id));
                    setOfLmsBatchId.add(string.valueOf(studentAttendance.batch_id));
                }
                system.debug('setOfLmsStudentId ==> '+setOfLmsStudentId);
                system.debug('setOfLmsProductId ==> '+setOfLmsProductId);
                system.debug('setOfLmsBatchId ==> '+setOfLmsBatchId);

                if(!setOfLmsStudentId.isEmpty()){
                    listOfExistingStudentByStuId = [SELECT Id,Name,LMS_Student_Id__c FROM Contact WHERE LMS_Student_Id__c In:setOfLmsStudentId ];
                    system.debug('listOfExistingStudentByStuId ==> '+listOfExistingStudentByStuId);
                }
                if(!setOfLmsProductId.isEmpty()){
                    listOfExistingProductByLMSId = [SELECT Id,Name,LMS_ExternalId__c FROM Product2 WHERE LMS_ExternalId__c In:setOfLmsProductId ];
                    system.debug('listOfExistingProductByLMSId ==> '+listOfExistingProductByLMSId);
                }
                if(!setOfLmsBatchId.isEmpty()){
                    listOfExistingBatchByBatchNo = [SELECT Id,Name,Batch_Id__c FROM Batch__c WHERE Batch_Id__c In:setOfLmsBatchId ];
                    system.debug('listOfExistingBatchByBatchNo ==> '+listOfExistingBatchByBatchNo);
                }

                if(!listOfExistingStudentByStuId.isEmpty()){
                    for(Contact conRec : listOfExistingStudentByStuId){
                        mapOfStuIdByExternalId.put(conRec.LMS_Student_Id__c, conRec.Id);
                    }
                }
                if(!listOfExistingProductByLMSId.isEmpty()){
                    for(Product2 prod : listOfExistingProductByLMSId){
                        mapOfProdIdByExternalId.put(prod.LMS_ExternalId__c, prod.Id);
                    }
                }
                if(!listOfExistingBatchByBatchNo.isEmpty()){
                    for(Batch__c batch : listOfExistingBatchByBatchNo){
                        mapOfBatchIdByExternalId.put(batch.Batch_Id__c, batch.Id);
                    }
                }

                List<Student_Attendance__c> listOfExistingStudentAttendance = [SELECT Id,Student__c,Student__r.LMS_Student_Id__c FROM Student_Attendance__c WHERE Student__r.LMS_Student_Id__c IN : setOfLmsStudentId];
                system.debug('listOfExistingStudentAttendance ==> '+listOfExistingStudentAttendance);

                Map<String, Student_Attendance__c> StuIdByExistingStuAttendance= new Map<String, Student_Attendance__c>();
            
                if(!listOfExistingStudentAttendance.isEmpty()){
                    for(Student_Attendance__c stuAtt : listOfExistingStudentAttendance){
                        StuIdByExistingStuAttendance.put(stuAtt.Student__r.LMS_Student_Id__c, stuAtt);
                    }
                }
                system.debug('StuIdByExistingStuAttendance ==> '+StuIdByExistingStuAttendance);
                for(API_LMSStudentAttendanceWrapper singleStuAttRecord : stuAttendanceWrapperList){
                    Student_Attendance__c stuAttendanceToInsert = New Student_Attendance__c();
                    system.debug('StuIdByExistingStuAttendance.containsKey(singleStuAttRecord.student_id) ==> '+StuIdByExistingStuAttendance.containsKey(singleStuAttRecord.student_id));
                    system.debug('singleStuAttRecord.student_id ==> '+singleStuAttRecord.student_id);
                    if(StuIdByExistingStuAttendance.containsKey(singleStuAttRecord.student_id)){
                        stuAttendanceToInsert.Id = StuIdByExistingStuAttendance.get(singleStuAttRecord.student_id).Id;
                    }
                    if(singleStuAttRecord.completion_percentage != null){
                        stuAttendanceToInsert.Completion_Percentage__c = singleStuAttRecord.completion_percentage;
                    }
                    if(singleStuAttRecord.total_sessions_attended != null){
                        stuAttendanceToInsert.Total_Sessions_Attend__c = singleStuAttRecord.total_sessions_attended;
                    }
                    if(singleStuAttRecord.planned_sessions != null){
                        stuAttendanceToInsert.Planned_Sessions__c = singleStuAttRecord.planned_sessions;
                    }
                    if(singleStuAttRecord.product_id != null){
                        if(mapOfProdIdByExternalId.containsKey(singleStuAttRecord.product_id)){
                            stuAttendanceToInsert.Product__c = mapOfProdIdByExternalId.get(singleStuAttRecord.product_id);
                        }else{
                            return 'Error: Product Id is not found for ' + singleStuAttRecord.product_id;
                        }
                    }
                    if(singleStuAttRecord.batch_id != null){
                        if(mapOfBatchIdByExternalId.containsKey(singleStuAttRecord.batch_id)){
                            stuAttendanceToInsert.Batch__c = mapOfBatchIdByExternalId.get(singleStuAttRecord.batch_id);
                        }else{
                            return 'Error: Batch Id is not found for ' + singleStuAttRecord.batch_id;
                        }
                    }
                    if(singleStuAttRecord.student_id != null){
                        if(mapOfStuIdByExternalId.containsKey(singleStuAttRecord.student_id)){
                            stuAttendanceToInsert.Student__c = mapOfStuIdByExternalId.get(singleStuAttRecord.student_id);
                        }else{
                            return 'Error: Student Id is not found for ' + singleStuAttRecord.student_id;
                        }
                    }
                    listOfStuAttendanceToUpsert.add(stuAttendanceToInsert);
                }
                upsert listOfStuAttendanceToUpsert;
                if(!listOfStuAttendanceToUpsert.isEmpty()){
                    for(Student_Attendance__c stuAtt : listOfStuAttendanceToUpsert){
                        listOfRecordIds.add(stuAtt.Id);
                    }
                }
            }
            return 'SUCCESS';
        }catch(Exception e){
            return e.getMessage()+e.getLineNumber();
        }
    }
}