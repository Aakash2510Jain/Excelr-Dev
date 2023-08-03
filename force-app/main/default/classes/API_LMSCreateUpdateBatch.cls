@RestResource(urlMapping = '/LMSCreateUpdateBatch')
global with sharing class API_LMSCreateUpdateBatch{
    @HttpPost
    global static void PostLMS_CreateUpdateBatch(){
        try{
            RestRequest req = RestContext.request;
            Blob body = req.requestBody;
            String requestString = body.toString();
            System.debug('--- rquestString' + requestString);

            List<Student_Batch__c> StudentbatchList = new List<Student_Batch__c>();
            if (!String.isEmpty(requestString)){
                if (!String.isEmpty(requestString)){
                    //List<Product2> ProductInstanceList = ReturnProdListInstances(requestString);
                    //BatchmapObject
                    BatchWrapperClass BatchWrap = ReturnbatchInstance(requestString);
                    if (BatchWrap.BatchTobeCreated.size() > 0 && BatchWrap.BatchTobeCreated != null){
                        Schema.SobjectField fToken = Batch__c.Fields.Batch_Id__c;
                        Database.upsertresult[] Batchresult = Database.upsert (BatchWrap.BatchTobeCreated, fToken, false);
                        Map<ID, batch__c> batchmap = new Map<ID, batch__c>(BatchWrap.BatchTobeCreated);
                        

                        Integer i = 0;

                        for (Database.upsertresult result : Batchresult){

                            System.debug('result ===> ' + result);
                            if (result.issuccess()){
                                if (result.iscreated()){
                                    List<string> StudentIds =  BatchWrap.batchIdWithStudentIds.get( batchmap.get(result.getId()).Batch_Id__c);
                                    for (String Stu : StudentIds) {
                                        Student_Batch__c studBatch = new Student_Batch__c();
                                        studBatch.Batch__c = result.getId();
                                        if (BatchWrap.ConLMSIdWithContact.containskey(Stu)) {
                                            studBatch.Student__c = BatchWrap.ConLMSIdWithContact.get(Stu).Id;                                        }
                                            studBatch.Student_LMSId__c = stu;
                                            studBatch.Student_Name__c = (String.isNotBlank(BatchWrap.ConLMSIdWithContact.get(Stu).FirstName) ? BatchWrap.ConLMSIdWithContact.get(Stu).FirstName : '') + ' ' + (String.isNotBlank(BatchWrap.ConLMSIdWithContact.get(Stu).LastName) ? BatchWrap.ConLMSIdWithContact.get(Stu).LastName : '');
                                            studBatch.Student_RecordId__c = BatchWrap.ConLMSIdWithContact.get(Stu).Id; 
                                            StudentbatchList.add(studBatch);
                                           
                                    }
                                   
                                }
                            }
                        }

                    }

                    if (!StudentbatchList.isEmpty() && StudentbatchList.size() >0 && StudentbatchList != null) {

                        //Schema.SobjectField fToken = Student_Batch__c.Fields.Batch_Id__c;
                        Database.upsertresult[] StudentBatchresult = Database.upsert (StudentbatchList, false);
                        Map<ID, Student_Batch__c> StudBatchresult = new Map<ID, Student_Batch__c>(StudentbatchList);

                        for (Database.upsertresult result : StudentBatchresult){

                            System.debug('result ===> ' + result);
                            if (result.issuccess()){
                                if (result.iscreated()){
                                    
                                   
                                }
                                else {
                                    
                                }
                            }
                            else {
                                
                            }
                        }

                        
                    }
                }

            RestContext.response.responseBody = Blob.valueOf('{"Status": "SUCCESS","Message": "Batch Created Successfully"}');
            RestContext.response.statusCode = 200;
        } else{
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new IntegrationWrapper.APIResponseWrapper('Error', '[{"ref": "003N000001xyPbwIAE","message": "Couldn\'t process this lead due to error"}, { "ref": "003N000001xyPbwIAE","message": "Couldn\'t process this lead due to error" }]')));
            RestContext.response.statusCode = 400;
        }
    }

     catch (Exception e){
        system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
        HandleBusinessException.captureError('API_LMSUpdateStudentStatus', 'PostLMS_UpdateStudentStatus', e, null);
    }
}

Public static BatchWrapperClass ReturnbatchInstance(String requestString){

    Map<String, Object> BatchIdWithBatchOBject = new Map<String, Object>();

    Map<String, List<String>> BatchIdWithStudentIdList = new Map<String, List<String>>();
    Set<String> StudentIds = new Set<String>();
    Set<String> courseIds = new Set<String>();
    Set<String> LMSBatcIdWithStudid = new Set<String>();

    List<Contact> conlist = new List<Contact>();
    List<Product2> ProdList = new List<Product2>();
    Map<String, Contact> StudentLMSIdwithStudent = new Map<String, Contact>();
    Map<String, String> ProductLMSIdwithProdId = new Map<String, String>();
    List<Batch__c> BatchTobeUpdatedCreatd = new List<Batch__c>();
    List<Student_batch__c> StudentsBatches = new List<Student_batch__c>();

    Map<String, List<String>> batchIdwithListStudentId = new Map<String, List<String>>();


    BatchWrapperClass batchWrap = new BatchWrapperClass();
    try{

        if (!String.isEmpty(requestString)){
            List<object> bodyMap = (List<object>)JSON.deserializeUntyped(requestString);
            if (bodyMap.size() > 0){
                for (Object batchObj : bodyMap){
                    Map<string, Object> batchMap = (Map<string, Object>)batchObj;
                    if (batchMap.containsKey('batch_id')){
                        BatchIdWithBatchOBject.put(String.valueOf(batchMap.get('batch_id')), batchMap);
                        batchWrap.BatchmapObject = BatchIdWithBatchOBject;
                    }
                    if (batchMap.containsKey('course_id')){
                        courseIds.add(String.valueOf(batchMap.get('course_id')));
                        //LeadWrap.leadmap = StudentIdWithLeadOBject;
                    }
                    if (batchMap.containsKey('student_ids')){
                        List<String> StudentExtIdList = (List<String>)batchMap.get('student_ids');
                        System.debug('StudentExtIdList ====> ' + StudentExtIdList);
                        BatchIdWithStudentIdList.put(String.valueOf(batchMap.get('batch_id')), StudentExtIdList);
                        batchWrap.batchIdWithStudentIds = BatchIdWithStudentIdList;
                        for (String str : StudentExtIdList){
                            StudentIds.add(str);
                            LMSBatcIdWithStudid.add(String.valueOf(batchMap.get('batch_id')) + str);
                            
                        }
                    }
                }
            }

            if (StudentIds.size() > 0){
                conlist = [SELECT Id, LMS_Student_Id__c
                           FROM Contact
                           where LMS_Student_Id__c IN:StudentIds];


                if (conlist.size() > 0){
                    for (Contact con : conlist){
                        StudentLMSIdwithStudent.put(con.LMS_Student_Id__c, con);
                        batchWrap.ConLMSIdWithContact = StudentLMSIdwithStudent;
                    }

                }
                //batchIdwithStuId__c
                StudentsBatches = [SELECT Batch__c, Id, Name, Student__c
                                   FROM Student_Batch__c
                                   Where batchIdwithStuId__c IN:LMSBatcIdWithStudid];

            }
            if (courseIds.size() > 0){
                prodList = [select id, ExternalId
                            from Product2
                            Where ExternalId IN:courseIds];

                if (prodList.size() > 0){
                    for (Product2 prod : prodList){
                        ProductLMSIdwithProdId.put(prod.ExternalId, prod.Id);
                    }
                }
            }

            if (bodyMap.size() > 0){
                for (Object batchObj : bodyMap){
                    Batch__c batchTobeCreatedUpdate = new Batch__c();
                    Map<string, Object> batchMap = (Map<string, Object>)batchObj;
                    // if (batchMap.containsKey('student_ids')){
                    //     batchIdwithListStudentId.put(String.valueOf(batchMap.containsKey('batch_name')), value)

                    //     batchTobeCreatedUpdate.name = String.valueOf(batchMap.containsKey('batch_name'));
                    // }
                    if (batchMap.containsKey('batch_name')){
                        batchTobeCreatedUpdate.name = String.valueOf(batchMap.containsKey('batch_name'));
                    }
                    if (batchMap.containsKey('batch_start_date')){
                        batchTobeCreatedUpdate.Start_Date__c = Date.valueOf(batchMap.get('batch_start_date'));
                    }
                    if (batchMap.containsKey('batch_end_date')){
                        batchTobeCreatedUpdate.End_Date__c = date.valueOf(batchMap.get('batch_end_date'));
                    }
                    if (batchMap.containsKey('batch_completion_percent')){
                        batchTobeCreatedUpdate.Completion_Percent__c = Integer.valueOf(batchMap.get('batch_completion_percent'));
                    }
                    if (batchMap.containsKey('batch_id')){
                        batchTobeCreatedUpdate.Batch_Id__c = String.valueOf(batchMap.get('batch_id'));
                    }
                    if (batchMap.containsKey('course_id')){
                        if (!ProductLMSIdwithProdId.isEmpty() && ProductLMSIdwithProdId.containsKey(String.valueof(batchMap.get('course_id')))){
                            batchTobeCreatedUpdate.Course__c = ProductLMSIdwithProdId.get(String.valueof(batchMap.get('course_id')));
                        }
                    }

                    BatchTobeUpdatedCreatd.add(batchTobeCreatedUpdate);
                }
            }
        }
        if (BatchTobeUpdatedCreatd.size() > 0){
            batchWrap.BatchTobeCreated = BatchTobeUpdatedCreatd;
        }

    } catch (Exception e){
        System.debug('The error has occured due to ======> ' + e.getMessage());
        System.debug('The error has occured at ======> ' + e.getLineNumber());

    }
    return batchWrap;
}
public class BatchWrapperClass{
    public List<Batch__c> BatchTobeCreated{ get; set; }

    //public Map<String, String> ProductMap{ get; set; }
    public Map<string, Object> BatchmapObject{ get; set; }
    Public Map<String, List<String>> batchIdWithStudentIds { get; set; }
    Public Map<String, Contact> ConLMSIdWithContact { get; set; }

}

}
/*
 [
 {
 "batch_id": "",
 "course_id" : "123",
 "batch_start_date" : "01/08/2023",
 "batch_end_date" : "01/11/2023",
 "batch_name" : "Py-batch-0015",
 "student_ids" : ["34565456", "123"]
 "batch_completion_percent" : 60
 }
 ]
 */