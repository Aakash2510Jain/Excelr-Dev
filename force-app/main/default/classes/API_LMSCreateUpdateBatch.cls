@RestResource(urlMapping = '/sync_batch')
global with sharing class API_LMSCreateUpdateBatch{
    @HttpPost
    global static void PostLMS_CreateUpdateBatch(){
        try{
            RestRequest req = RestContext.request;
            Blob body = req.requestBody;
            String requestString = body.toString();
            System.debug('--- rquestString' + requestString);

            List<Student_Batch__c> StudentbatchList = new List<Student_Batch__c>();
            List<Product_Batch__c> ProdBatchList = new List<Product_Batch__c>();
            Map<String, String> LmsBatchIdwithBatchRecId = new Map<String, String>();
            Map<String, String> ProdandbatchIdWithStudeBatchRecId = new Map<String, String>();

            List<APIResponseWrapper> ResponseWrapList = new List<APIResponseWrapper>();

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
                                    LmsBatchIdwithBatchRecId.put(batchmap.get(result.getId()).Batch_Id__c, result.getId());
                                    Product_Batch__c ProdBatch = new Product_Batch__c();
                                    ProdBatch.Batch__c = result.getId();
                                    //if (batchwrap.ProductLMSIdwithProdId != null && ) {
                                    //  if (batchwrap.ProductLMSIdwithProdId.containsKey('course_id')){
                                    System.debug('batchwrap.BatchmapObject ======> ' + batchwrap.BatchmapObject);
                                    System.debug('batchmap.get(result.getId()).Batch_Id__c ======> ' + batchmap.get(result.getId()).Batch_Id__c);
                                    System.debug('batchwrap.BatchmapObject.containsKey(batchmap.get(result.getId()).Batch_Id__c) =====> ' + batchwrap.BatchmapObject.containsKey(batchmap.get(result.getId()).Batch_Id__c));
                                    /*if (!batchwrap.BatchmapObject.isEmpty() && batchwrap.BatchmapObject.containsKey(batchmap.get(result.getId()).Batch_Id__c)){

                                        System.debug('LmsBatchIdwithBatchRecId ====> ' + LmsBatchIdwithBatchRecId);
                                        //batchTobeCreatedUpdate.Course__c = ProductLMSIdwithProdId.get(String.valueof(batchMap.get('course_id')));
                                        Map<string, Object> ProdbatchMap = (Map<string, Object>)batchwrap.BatchmapObject.get(batchmap.get(result.getId()).Batch_Id__c);
                                        System.debug('ProdbatchMap =====> ' + ProdbatchMap);

                                        if (ProdbatchMap.containsKey('course_id') && batchWrap.ProductLMSIdwithProdId.containsKey(String.valueOf(ProdbatchMap.get('course_id')))){
                                            ProdBatch.Product__c = batchWrap.ProductLMSIdwithProdId.get(String.valueOf(ProdbatchMap.get('course_id')));
                                        }
                                    }*/

                                    if (!batchwrap.BatchmapObject.isEmpty() && batchwrap.BatchmapObject.containsKey(batchmap.get(result.getId()).Batch_Id__c)){
                                        if (!batchwrap.BatchIdwithCourseList.isempty() && batchwrap.BatchIdwithCourseList.containskey(batchmap.get(result.getId()).Batch_Id__c)){
                                            list<String> courseLMSIds = batchwrap.BatchIdwithCourseList.get(batchmap.get(result.getId()).Batch_Id__c);
                                            if (!courseLMSIds.isEmpty() && courseLMSIds.size() > 0){
                                                for (String cousreStr : courseLMSIds){
                                                    ProdBatch.Product__c = batchWrap.ProductLMSIdwithProdId.get(cousreStr);
                                                    ProdBatchList.add(ProdBatch);
                                                }

                                            }
                                        }
                                    }
                                    //}
                                    //}

                                    

                                } else{
                                    LmsBatchIdwithBatchRecId.put(batchmap.get(result.getId()).Batch_Id__c, result.getId());
                                    Product_Batch__c ProdBatch = new Product_Batch__c();
                                    ProdBatch.Batch__c = result.getId();
                                    //if (batchwrap.ProductLMSIdwithProdId != null && ) {
                                    //  if (batchwrap.ProductLMSIdwithProdId.containsKey('course_id')){
                                    System.debug('batchwrap.BatchmapObject ======> ' + batchwrap.BatchmapObject);
                                    System.debug('batchmap.get(result.getId()).Batch_Id__c ======> ' + batchmap.get(result.getId()).Batch_Id__c);
                                    System.debug('batchwrap.BatchmapObject.containsKey(batchmap.get(result.getId()).Batch_Id__c) =====> ' + batchwrap.BatchmapObject.containsKey(batchmap.get(result.getId()).Batch_Id__c));
                                    if (!batchwrap.BatchmapObject.isEmpty() && batchwrap.BatchmapObject.containsKey(batchmap.get(result.getId()).Batch_Id__c)){
                                        if (!batchwrap.BatchIdwithCourseList.isempty() && batchwrap.BatchIdwithCourseList.containskey(batchmap.get(result.getId()).Batch_Id__c)){
                                            list<String> courseLMSIds = batchwrap.BatchIdwithCourseList.get(batchmap.get(result.getId()).Batch_Id__c);
                                            if (!courseLMSIds.isEmpty() && courseLMSIds.size() > 0){
                                                for (String cousreStr : courseLMSIds){
                                                    ProdBatch.Product__c = batchWrap.ProductLMSIdwithProdId.get(cousreStr);
                                                    ProdBatchList.add(ProdBatch);
                                                    // Map<string, Object> ProdbatchMap = (Map<string, Object>)batchwrap.BatchmapObject.get(batchmap.get(result.getId()).Batch_Id__c);
                                                    // System.debug('ProdbatchMap =====> ' + ProdbatchMap);

                                                    // if (ProdbatchMap.containsKey('course_id') && batchWrap.ProductLMSIdwithProdId.containsKey(String.valueOf(ProdbatchMap.get('course_id')))){
                                                    //     ProdBatch.Product__c = batchWrap.ProductLMSIdwithProdId.get(String.valueOf(ProdbatchMap.get('course_id')));
                                                    // }

                                                }

                                            }
                                        }
                                    }


                                    //}
                                    //}
                                    ProdBatchList.add(ProdBatch);
                                    System.debug('LmsBatchIdwithBatchRecId ====> ' + LmsBatchIdwithBatchRecId);
                                }
                            } else{
                                APIResponseWrapper APIResWrap = new APIResponseWrapper();
                                APIResWrap.message = 'Couldn\'t process this Product due to error';
                                APIResWrap.ref = String.valueOf(BatchWrap.BatchTobeCreated[i].Batch_Id__c);
                                ResponseWrapList.add(APIResWrap);
    

                            }
                            i++;
                        }

                    }

                    System.debug('ProdBatchList ====> ' + ProdBatchList);

                    if (!ProdBatchList.isEmpty() && ProdBatchList.size() > 0 && ProdBatchList != null){
                        Database.upsertresult[] prodBatchresult = Database.upsert (ProdBatchList, false);
                        Map<ID, Product_Batch__c> ProdBatchresultMap = new Map<ID, Product_Batch__c>(ProdBatchList);

                        for (Database.upsertresult result : prodBatchresult){

                            System.debug('result ===> ' + result);
                            if (result.issuccess()){
                                if (result.iscreated()){
                                    System.debug('ProdBatchresultMap.get(result.getId()).Product__c) ====> ' + ProdBatchresultMap.get(result.getId()).Product__c);
                                    System.debug('String.valueOf( ProdBatchresultMap.get(result.getId()).Batch__c) ====> ' + String.valueOf(ProdBatchresultMap.get(result.getId()).Batch__c));
                                    String prodandBatch = String.valueOf(ProdBatchresultMap.get(result.getId()).Product__c) + String.valueOf(ProdBatchresultMap.get(result.getId()).Batch__c);
                                    ProdandbatchIdWithStudeBatchRecId.put(prodandBatch, result.getId());
                                } else{
                                    String prodandBatch = String.valueOf(ProdBatchresultMap.get(result.getId()).Product__c) + String.valueOf(ProdBatchresultMap.get(result.getId()).Batch__c);
                                    ProdandbatchIdWithStudeBatchRecId.put(prodandBatch, result.getId());
                                    //ProdandbatchIdWithStudeBatchRecId.put(ProdBatchresultMap.get(result.getId()).Product__c+ProdBatchresultMap.get(result.getId()).Batch__c, result.getI());
                                }
                            } else{

                            }
                        }
                    }

                    List<object> bodyMap = (List<object>)JSON.deserializeUntyped(requestString);
                    if (bodyMap.size() > 0){
                        for (Object batchObj : bodyMap){
                            Map<string, Object> batchMap = (Map<string, Object>)batchObj;
                            String BatchrecId, productrecId, studentBatchrecId;
                            if (batchMap.containsKey('batch_id')){
                                if (LmsBatchIdwithBatchRecId.containsKey(String.valueOf(batchMap.get('batch_id')))){
                                    BatchrecId = LmsBatchIdwithBatchRecId.get(String.valueOf(batchMap.get('batch_id')));
                                }
                            }
                            if (batchMap.containsKey('course_id')){
                                System.debug('String.valueOf(batchMap.get(course_id)) =====> ' + String.valueOf(batchMap.get('course_id')));
                                System.debug('atchWrap.ProductLMSIdwithProdId ====> ' + batchWrap.ProductLMSIdwithProdId);
                                if (batchWrap.ProductLMSIdwithProdId.containsKey(String.valueOf(batchMap.get('course_id')))){
                                    productrecId = batchWrap.ProductLMSIdwithProdId.get(String.valueOf(batchMap.get('course_id')));
                                }

                            }
                            System.debug('String.valueOf(productrecId) =====> ' + String.valueOf(productrecId));
                            System.debug('String.valueOf(BatchrecId)) =====> ' + String.valueOf(BatchrecId));
                            System.debug('ProdandbatchIdWithStudeBatchRecId ====> ' + ProdandbatchIdWithStudeBatchRecId);
                            if (ProdandbatchIdWithStudeBatchRecId.containsKey(String.valueOf(productrecId) + String.valueOf(BatchrecId))){
                                studentBatchrecId = ProdandbatchIdWithStudeBatchRecId.get(String.valueOf(productrecId) + String.valueOf(BatchrecId));

                            }
                            if (batchMap.containsKey('student_ids')){
                                List<Object> StudentExtobjIdList = (List<Object>)batchMap.get('student_ids');
                                List<String> StudentExtIdList = new List<String>();
                                System.debug('StudentExtIdList ====> ' + StudentExtIdList);
                                for (Object obj : StudentExtobjIdList){
                                    StudentExtIdList.add(String.valueOf(obj));
                                }
                                for (String stu : StudentExtIdList){
                                    Student_Batch__c studBatch = new Student_Batch__c();
                                    studBatch.Product_Batch__c = studentBatchrecId;
                                    studBatch.Student_LMSId__c = stu;
                                    if (BatchWrap.ConLMSIdWithContact.containskey(Stu)){
                                        studBatch.Student__c = BatchWrap.ConLMSIdWithContact.get(Stu).Id;
                                    }
                                    studBatch.Student_Name__c = (String.isNotBlank(BatchWrap.ConLMSIdWithContact.get(Stu).FirstName) ? BatchWrap.ConLMSIdWithContact.get(Stu).FirstName : '') + ' ' + (String.isNotBlank(BatchWrap.ConLMSIdWithContact.get(Stu).LastName) ? BatchWrap.ConLMSIdWithContact.get(Stu).LastName : '');
                                    studBatch.Student_RecordId__c = BatchWrap.ConLMSIdWithContact.get(Stu).Id;
                                    StudentbatchList.add(studBatch);

                                }
                            }

                        }
                    }
                    if (!StudentbatchList.isEmpty() && StudentbatchList.size() > 0 && StudentbatchList != null){

                        //Schema.SobjectField fToken = Student_Batch__c.Fields.Batch_Id__c;
                        Database.upsertresult[] StudentBatchresult = Database.upsert (StudentbatchList, false);
                        Map<ID, Student_Batch__c> StudBatchresult = new Map<ID, Student_Batch__c>(StudentbatchList);

                        for (Database.upsertresult result : StudentBatchresult){

                            System.debug('result ===> ' + result);
                            if (result.issuccess()){
                                if (result.iscreated()){


                                } else{

                                }
                            } else{

                            }
                        }


                    }
                }
                String responseBody = RestContext.response.responseBody.toString();
                Integer statusCode = RestContext.response.statusCode;
                HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/bulk_leadcreate', 'POST', statusCode, System.now(), System.now(),null);


                RestContext.response.responseBody = Blob.valueOf('{"status": "SUCCESS","message": "Batch Created Successfully"}');
                RestContext.response.statusCode = 200;
            } else{
                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new IntegrationWrapper.APIResponseWrapper('Error', '[{"ref": "003N000001xyPbwIAE","message": "Couldn\'t process this lead due to error"}, { "ref": "003N000001xyPbwIAE","message": "Couldn\'t process this lead due to error" }]')));
                RestContext.response.statusCode = 400;
            }
        } catch (Exception e){
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new IntegrationWrapper.APIResponseWrapper('Error', '[{"ref": "003N000001xyPbwIAE","message": "Couldn\'t process this lead due to error"}, { "ref": "003N000001xyPbwIAE","message": "Couldn\'t process this lead due to error" }]')));
            RestContext.response.statusCode = 400;
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('API_LMSUpdateStudentStatus', 'PostLMS_UpdateStudentStatus', e, null);
        }
    }

    Public static BatchWrapperClass ReturnbatchInstance(String requestString){

        Map<String, Object> BatchIdWithBatchOBject = new Map<String, Object>();
        Map<String, Object> CourseIdWithBatchOBject = new Map<String, Object>();
        Map<String, List<String>> BatchIdwithCourseList = new Map<String, List<String>>();

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
                            if (!BatchIdWithBatchOBject.containsKey(String.valueOf(batchMap.get('batch_id')))){
                                BatchIdWithBatchOBject.put(String.valueOf(batchMap.get('batch_id')), batchMap);
                            }

                        }
                        if (batchMap.containsKey('course_id')){
                            List<Object> CourseExtobjIdList = (List<Object>)batchMap.get('course_id');
                            List<String> CourseExtIdList = new List<String>();
                            BatchIdwithCourseList.put(String.valueOf(batchMap.get('batch_id')), CourseExtIdList);
                            for (Object obj : CourseExtobjIdList){

                                courseIds.add(String.valueOf(batchMap.get('obj')));
                                //if (!CourseIdWithBatchOBject.containsKey(String.valueOf(batchMap.get('course_id')))){
                                CourseIdWithBatchOBject.put(String.valueOf(obj), batchMap);

                                //}
                            }
                            //courseIds.add(String.valueOf(batchMap.get('course_id')));

                            //LeadWrap.leadmap = StudentIdWithLeadOBject;
                        }
                        if (batchMap.containsKey('student_ids')){
                            List<Object> StudentExtobjIdList = (List<Object>)batchMap.get('student_ids');
                            List<String> StudentExtIdList = new List<String>();
                            System.debug('StudentExtIdList ====> ' + StudentExtIdList);
                            for (Object obj : StudentExtobjIdList){
                                StudentExtIdList.add(String.valueOf(obj));
                            }
                            if (!BatchIdWithStudentIdList.containsKey(String.valueOf(batchMap.get('batch_id')))){
                                BatchIdWithStudentIdList.put(String.valueOf(batchMap.get('batch_id')), StudentExtIdList);
                            }
                            for (String str : StudentExtIdList){
                                StudentIds.add(str);
                                LMSBatcIdWithStudid.add(String.valueOf(batchMap.get('batch_id')) + str);

                            }
                        }
                    }
                    batchWrap.batchIdWithStudentIds = BatchIdWithStudentIdList;
                    batchWrap.BatchmapObject = BatchIdWithBatchOBject;
                    batchWrap.CourseIdWithBatchOBject = CourseIdWithBatchOBject;
                    batchWrap.BatchIdwithCourseList = BatchIdwithCourseList;
                }

                if (StudentIds.size() > 0){
                    conlist = [SELECT Id, LMS_Student_Id__c, FirstName, LastName
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
                    prodList = [select id, ExternalId, LMS_ExternalId__c
                                from Product2
                                Where LMS_ExternalId__c IN:courseIds];

                    if (prodList.size() > 0){
                        for (Product2 prod : prodList){
                            ProductLMSIdwithProdId.put(prod.LMS_ExternalId__c, prod.Id);
                        }
                        batchWrap.ProductLMSIdwithProdId = ProductLMSIdwithProdId;
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
                            String[] Datelist     = String.valueOf(batchMap.get('batch_start_date')).split('/');
                            Date batchStartDate = Date.newInstance(integer.valueOf(Datelist[2]), integer.valueOf(Datelist[1]), integer.valueOf(Datelist[0]));
                            batchTobeCreatedUpdate.Start_Date__c = batchStartDate; 
                            //batchTobeCreatedUpdate.Start_Date__c = Date.valueOf('2023-12-23');   //Date.valueOf(String.valueOf(batchMap.get('batch_start_date')));
                        }
                        if (batchMap.containsKey('batch_end_date')){
                            String[] Datelist     = String.valueOf(batchMap.get('batch_end_date')).split('/');
                            Date batchendDate = Date.newInstance(integer.valueOf(Datelist[2]), integer.valueOf(Datelist[1]), integer.valueOf(Datelist[0]));
                            batchTobeCreatedUpdate.End_Date__c = batchendDate; //Date.valueOf('2023-12-20'); //Date.valueOf(String.valueOf(batchMap.get('batch_end_date')));
                        }
                        if (batchMap.containsKey('batch_completion_percent')){
                            batchTobeCreatedUpdate.Completion_Percent__c = Integer.valueOf(batchMap.get('batch_completion_percent'));
                        }
                        if (batchMap.containsKey('batch_id')){
                            batchTobeCreatedUpdate.Batch_Id__c = String.valueOf(batchMap.get('batch_id'));
                        }
                        /*if (batchMap.containsKey('course_id')){
                         if (!ProductLMSIdwithProdId.isEmpty() && ProductLMSIdwithProdId.containsKey(String.valueof(batchMap.get('course_id')))){
                         batchTobeCreatedUpdate.Course__c = ProductLMSIdwithProdId.get(String.valueof(batchMap.get('course_id')));
                         }
                         }*/

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

        public Map<String, List<String>> batchIdWithStudentIds{ get; set; }

        public Map<String, Contact> ConLMSIdWithContact{ get; set; }

        public Map<String, String> ProductLMSIdwithProdId{ get; set; }

        public Map<String, Object> CourseIdWithBatchOBject{ get; set; }

        public map<String, List<String>> BatchIdwithCourseList{ get; set; }

    }

    Public class APIResponseWrapper{
        public String ref;
        public String message;

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