@RestResource(urlMapping = '/update_platform_status')
global without sharing class API_LMSUpdateStudentStatus {
    
    @HttpPost
    global static void PostLMS_UpdateStudentStatus() {
        RestRequest req = RestContext.request;
        Blob body = req.requestBody;
        String requestString = body.toString();
        System.debug('--- requestString' + requestString);
        
        if (!String.isBlank(requestString)) {
            List<studentUpdateWrapper> studentBlocksList = (List<studentUpdateWrapper>) JSON.deserialize(requestString, List<studentUpdateWrapper>.class);
            if (studentBlocksList != null && studentBlocksList.size() > 0) {
                // Check for empty or null values in the JSON data
                if (!checkForEmptyData(studentBlocksList)) {
                    //String errorMessage = '{"status": "Error","message": "JSON data contains empty or null values!"}';
                    //respondWithError(errorMessage, studentBlocksList);
                    //return errorMessage;
                }
                string response = processStudentWrapper(studentBlocksList);
                RestContext.response.responseBody = Blob.valueOf(response);
                //RestContext.response.statusCode = 200;
            } 
            else {
                String ErrorresonseBOdy = '{"status": "Error","message": "JSON Body is empty. Please send data in JSON Body!"}';
                RestContext.response.responseBody = Blob.valueOf(ErrorresonseBOdy);
                RestContext.response.statusCode = 400;
                //return ErrorresonseBOdy;
            }
            //RestContext.response.responseBody = Blob.valueOf('{"status": "SUCCESS","message": "All Student Status have been Updated Successfully"}');
            //return '{"Status": "SUCCESS","Message": "All Student Status have been Updated Successfully"}';
            
            
        } 
        else {
            String ErrorresonseBOdy = '{"Status": "Error","Message": "JSON Body is empty. Please send data in JSON Body!"}';
            RestContext.response.responseBody = Blob.valueOf(ErrorresonseBOdy);
            RestContext.response.statusCode = 400;
        }
    }
    
    
    // Check for empty or null values in the JSON data
    private static boolean checkForEmptyData(List<studentUpdateWrapper> studentBlocksList) {
        for (studentUpdateWrapper student : studentBlocksList) {
            if (String.isBlank(student.status)
                || String.isBlank(student.block_type)
                || student.block_details == null
                || (student.block_details.course_id == null && student.block_details.product_id == null && student.block_details.batch_id == null)
                || String.isBlank(student.student_id)) {
                    return false;
                }
        }
        return true;
    }


    
    private static string processStudentWrapper(List<studentUpdateWrapper> studentBlocksList) {
        
        System.debug('studentBlocksList---------->' + studentBlocksList);
        APIResponseWrapper responseWrapper;
        List<APIResponseWrapper> responseWrapperList = new List<APIResponseWrapper>();
        
        Set<String> blockedStudentIds = new Set<String>();
        Set<String> unblockedStudentIds = new Set<String>();
        Map<String, block_details_list> mapOfBlockDetailsWithStudentId = new Map<String, block_details_list>();

        try {
            for (studentUpdateWrapper student : studentBlocksList) {
                mapOfBlockDetailsWithStudentId.put(student.student_id, student.block_details);
                System.debug('student.block_details---------->' + student.block_details);
                if (student.status.containsIgnoreCase('BLOCKED')) {
                    blockedStudentIds.add(student.student_id);
                    System.debug('student.student_id---------->' + student.student_id);
                } else if (student.status.containsIgnoreCase('UNBLOCKED')) {
                    unblockedStudentIds.add(student.student_id);
                    System.debug('student.student_id---------->' + student.student_id);
                }
            }
            
            Set<String> courseIds = getCourseIdsFromJson(studentBlocksList);
            Set<String> batchIds = getBatchIdsFromJson(studentBlocksList);
            Set<String> ProductIds = getProductIdsFromJson(studentBlocksList);
            System.debug('courseIds------>' + courseIds);
            System.debug('batchIds------>' + batchIds);
            System.debug('ProductIds----------->'+ProductIds);

            Set<String> studentIds = new Set<String>();
            for (studentUpdateWrapper student : studentBlocksList) {
                studentIds.add(student.student_id);
            }
            
            List<Student_Batch__c> MatchByBatchID = [
                SELECT Id, Student__r.LMS_Student_Id__c, Product_Batch__c, Status__c, Block_Type__c
                FROM Student_Batch__c
                WHERE Product_Batch__r.Batch__r.Batch_Id__c IN :batchIds
                    AND Student__r.LMS_Student_Id__c IN :studentIds
            ];
            
            List<Student_Batch__c> MatchByCourseId = [
                SELECT Id, Student__r.LMS_Student_Id__c, Product_Batch__c, Status__c, Block_Type__c
                FROM Student_Batch__c
                WHERE Product_Batch__r.Product__r.LMS_ExternalId__c IN :courseIds
                    AND Student__r.LMS_Student_Id__c IN :studentIds
            ];
            
            List<Student_Batch__c> MatchByProductId = [
                SELECT Id, Student__r.LMS_Student_Id__c, Product_Batch__c, Status__c, Block_Type__c
                FROM Student_Batch__c
                WHERE Product_Batch__r.Product__r.Type__c = 'Combo' AND Product_Batch__r.Product__r.LMS_ExternalId__c IN :ProductIds
                    AND Student__r.LMS_Student_Id__c IN :studentIds
            ];

            Set<String> unmatchedStudentIds = new Set<String>(studentIds);
            Set<String> unmatchedStudentIds1 = new Set<String>(studentIds);           
            Set<String> unmatchedStudentIds2 = new Set<String>(studentIds);           

            
            System.debug('studentBatchList---------->' + MatchByBatchID);
            System.debug('studentBatchList---------->' + MatchByBatchID.size());

            System.debug('MatchByCourseId---------->' + MatchByCourseId);
            System.debug('MatchByCourseId---------->' + MatchByCourseId.size());

            System.debug('MatchByCourseId---------->' + MatchByProductId);
            System.debug('MatchByCourseId---------->' + MatchByProductId.size());

            
            Map<string, string> mapOfBatchWithStudentId = new Map<string, string>();
            Map<string, string> mapOfCourseWithStudentId = new Map<string, string>();
            Map<string, string> mapOfProductWithStudentId = new Map<string, string>();
            
            Map<String, List<Student_Batch__c>> studentBatchMap = new Map<String, List<Student_Batch__c>>();
            for (Student_Batch__c studentBatch : MatchByBatchID) {
                if (!studentBatchMap.containsKey(studentBatch.Student__r.LMS_Student_Id__c)) {
                    studentBatchMap.put(studentBatch.Student__r.LMS_Student_Id__c, new List<Student_Batch__c>());
                }
                studentBatchMap.get(studentBatch.Student__r.LMS_Student_Id__c).add(studentBatch);
                mapOfBatchWithStudentId.put(studentBatch.Id, studentBatch.Student__r.LMS_Student_Id__c);
            }
            
            Map<String, List<Student_Batch__c>> studentCourseMap = new Map<String, List<Student_Batch__c>>();
            for (Student_Batch__c studentCourse : MatchByCourseId) {
                if (!studentCourseMap.containsKey(studentCourse.Student__r.LMS_Student_Id__c)) {
                    studentCourseMap.put(studentCourse.Student__r.LMS_Student_Id__c, new List<Student_Batch__c>());
                }
                studentCourseMap.get(studentCourse.Student__r.LMS_Student_Id__c).add(studentCourse);
                mapOfCourseWithStudentId.put(studentCourse.Id, studentCourse.Student__r.LMS_Student_Id__c);
            }
            
            Map<String, List<Student_Batch__c>> studentProductMap = new Map<String, List<Student_Batch__c>>();
            for (Student_Batch__c studentProduct : MatchByProductId) {
                if (!studentProductMap.containsKey(studentProduct.Student__r.LMS_Student_Id__c)) {
                    studentProductMap.put(studentProduct.Student__r.LMS_Student_Id__c, new List<Student_Batch__c>());
                }
                studentProductMap.get(studentProduct.Student__r.LMS_Student_Id__c).add(studentProduct);
                mapOfProductWithStudentId.put(studentProduct.Id, studentProduct.Student__r.LMS_Student_Id__c);
            }
            
            
            System.debug('studentBatchMap----->'+studentBatchMap.size());
            System.debug('studentBatchMap----->'+studentBatchMap);
            System.debug('studentCourseMAP----->'+studentCourseMap);
            System.debug('studentCourseMAP.size----->'+studentCourseMap.size());
            System.debug('studentCourseMAP.size----->'+studentProductMap);
            
            List<Student_Batch__c> recordsToUpdate = new List<Student_Batch__c>();
            List<Student_Batch__c> recordsToUpdates = new List<Student_Batch__c>();
            List<Student_Batch__c> recordsToUpdatess = new List<Student_Batch__c>();
            
            for (List<Student_Batch__c> studentBatches : studentBatchMap.values()) {
                recordsToUpdate.addAll(studentBatches);
            }
            
            for (List<Student_Batch__c> studentCourses : studentCourseMap.values()) {
                recordsToUpdates.addAll(studentCourses);
            }
            for (List<Student_Batch__c> studentProduct : studentProductMap.values()) {
                recordsToUpdatess.addAll(studentProduct);
            }
            
            for (studentUpdateWrapper student : studentBlocksList) {
                String studentId = student.student_id;
                if (studentBatchMap.containsKey(studentId)) {
                    List<Student_Batch__c> studentBatches = studentBatchMap.get(studentId);
                    for (Student_Batch__c studentBatch : studentBatches) {
                        // Process batch-related records
                        String status = student.status; // Get the status directly from the JSON
                        if (status != null) {
                            studentBatch.Status__c = status;
                            studentBatch.Block_Type__c = student.block_type;
                        }
                    }
                }
                if (studentCourseMap.containsKey(studentId)) {
                    List<Student_Batch__c> studentCourses = studentCourseMap.get(studentId);
                    for (Student_Batch__c studentCourse : studentCourses) {
                        // Process course-related records
                        String status = student.status; // Get the status directly from the JSON
                        if (status != null) {
                            studentCourse.Status__c = status;
                            studentCourse.Block_Type__c = student.block_type;
                        }
                    }
                }
                
                if (studentProductMap.containsKey(studentId)) {
                    List<Student_Batch__c> studentProduct = studentProductMap.get(studentId);
                    for (Student_Batch__c studentProducts : studentProduct) {
                        // Process product-related records
                        String status = student.status; // Get the status directly from the JSON
                        if (status != null) {
                            studentProducts.Status__c = status;
                            studentProducts.Block_Type__c = student.block_type;
                        }
                    }
                }
                
                if (student.block_type.equalsIgnoreCase('PLATFORM')) {
                    updateStudentBatchesForPlatform(student.student_id, blockedStudentIds, unblockedStudentIds, studentBatchMap, studentCourseMap);
                }
            }
            
            System.debug('recordsToUpdate-------->' + recordsToUpdate);
            System.debug('recordsToUpdate-------->' + recordsToUpdates);
            System.debug('recordsToUpdate-------->' + recordsToUpdatess);
            
            
            //update recordsToUpdate;
            //update recordsToUpdates;
            //update recordsToUpdatess;
            
            Database.SaveResult[] upsertResults = Database.update(recordsToUpdate, false);
            system.debug('upsertResults -- ' + upsertResults);

            
            system.debug('mapOfBatchWithStudentId -- ' + mapOfBatchWithStudentId);
            for (Student_Batch__c studentBatch : MatchByBatchID) {
                unmatchedStudentIds.remove(studentBatch.Student__r.LMS_Student_Id__c);
            }

            for (Student_Batch__c studentCourse : MatchByCourseId) {
                unmatchedStudentIds1.remove(studentCourse.Student__r.LMS_Student_Id__c);
            }
            for (Student_Batch__c studentProducts : MatchByProductId) {
                unmatchedStudentIds2.remove(studentProducts.Student__r.LMS_Student_Id__c);
            }

            System.debug('unmatchedStudentIds--------->'+unmatchedStudentIds);
            System.debug('unmatchedStudentIds1--------->'+unmatchedStudentIds1);
            System.debug('unmatchedStudentIds2--------->'+unmatchedStudentIds2);

            if (!unmatchedStudentIds.isEmpty()) {
                for (String unmatchedStudentId : unmatchedStudentIds) {
                    APIResponseWrapper errorResWrapper = new APIResponseWrapper();
                    errorResWrapper.ref = unmatchedStudentId;
                    errorResWrapper.message = 'No records found for this student ID"s Batch id ';
                    RestContext.response.statusCode = 400;
                    responseWrapperList.add(errorResWrapper);
                }
                return JSON.serialize(responseWrapperList);

            } else if (!unmatchedStudentIds1.isEmpty()) {
                for (String unmatchedStudentId : unmatchedStudentIds1) {
                    APIResponseWrapper errorResWrapper = new APIResponseWrapper();
                    errorResWrapper.ref = unmatchedStudentId;
                    errorResWrapper.message = 'No records found for this student ID"s course id';
                    RestContext.response.statusCode = 400;
                    responseWrapperList.add(errorResWrapper);
                }
                return JSON.serialize(responseWrapperList);

            } else if (!unmatchedStudentIds2.isEmpty()) {
                for (String unmatchedStudentId : unmatchedStudentIds2) {
                    APIResponseWrapper errorResWrapper = new APIResponseWrapper();
                    errorResWrapper.ref = unmatchedStudentId;
                    errorResWrapper.message = 'No records found for this student ID"s product id';
                    RestContext.response.statusCode = 400;
                    responseWrapperList.add(errorResWrapper);
                }
                return JSON.serialize(responseWrapperList);

            } else if (!unmatchedStudentIds1.isEmpty() || !unmatchedStudentIds2.isEmpty()) {
                for (String unmatchedStudentId : unmatchedStudentIds1) {
                    APIResponseWrapper errorResWrapper = new APIResponseWrapper();
                    errorResWrapper.ref = unmatchedStudentId;
                    errorResWrapper.message = 'No records found for this student ID"s course id';
                    RestContext.response.statusCode = 400;
                    responseWrapperList.add(errorResWrapper);
                }
                for (String unmatchedStudentId : unmatchedStudentIds2) {
                    APIResponseWrapper errorResWrapper = new APIResponseWrapper();
                    errorResWrapper.ref = unmatchedStudentId;
                    errorResWrapper.message = 'No records found for this student ID"s product id';
                    RestContext.response.statusCode = 400;
                    responseWrapperList.add(errorResWrapper);
                }
                return JSON.serialize(responseWrapperList);

            }  else if (!unmatchedStudentIds.isEmpty() || !unmatchedStudentIds1.isEmpty()) {
                for (String unmatchedStudentId : unmatchedStudentIds) {
                    APIResponseWrapper errorResWrapper = new APIResponseWrapper();
                    errorResWrapper.ref = unmatchedStudentId;
                    errorResWrapper.message = 'No records found for this student ID"s Batch id';
                    RestContext.response.statusCode = 400;
                    responseWrapperList.add(errorResWrapper);
                }
                for (String unmatchedStudentId : unmatchedStudentIds1) {
                    APIResponseWrapper errorResWrapper = new APIResponseWrapper();
                    errorResWrapper.ref = unmatchedStudentId;
                    errorResWrapper.message = 'No records found for this student ID"s course id';
                    RestContext.response.statusCode = 400;
                    responseWrapperList.add(errorResWrapper);
                }
                return JSON.serialize(responseWrapperList);


            } else if (!unmatchedStudentIds.isEmpty() || !unmatchedStudentIds2.isEmpty()) {
                for (String unmatchedStudentId : unmatchedStudentIds) {
                    APIResponseWrapper errorResWrapper = new APIResponseWrapper();
                    errorResWrapper.ref = unmatchedStudentId;
                    errorResWrapper.message = 'No records found for this student ID"s Batch id';
                    RestContext.response.statusCode = 400;
                    responseWrapperList.add(errorResWrapper);
                }
                for (String unmatchedStudentId : unmatchedStudentIds2) {
                    APIResponseWrapper errorResWrapper = new APIResponseWrapper();
                    errorResWrapper.ref = unmatchedStudentId;
                    errorResWrapper.message = 'No records found for this student ID"s product id';
                    RestContext.response.statusCode = 400;
                    responseWrapperList.add(errorResWrapper);
                }
                return JSON.serialize(responseWrapperList);
                

            } else {

                for (Database.SaveResult result : upsertResults) {
                    APIResponseWrapper resWrapper = new APIResponseWrapper();
                
                    if (mapOfBatchWithStudentId.containsKey(result.getId())) {
                        resWrapper.ref = mapOfBatchWithStudentId.get(result.getId());
                        if (result.isSuccess()) {
                            resWrapper.message = 'Updated Successfully!!';
                        } else {
                            Database.Error error = result.getErrors()[0];
                            resWrapper.message = String.valueOf(error);
                        }
                        responseWrapperList.add(resWrapper);
                    }
                }

             // Return the error response wrappers
             return JSON.serialize(responseWrapperList);   
        } 

        
        // return JSON.serialize(responseWrapperList);   

    }catch (Exception e) {
            System.debug('ERROR MSG === > ' + e.getMessage());
            System.debug('AT LINE NUMBER === > ' + e.getLineNumber());
            return e.getMessage();
            
        }
    }
    


    private static void updateStudentBatchesForPlatform(String studentId, Set<String> blockedStudentIds, Set<String> unblockedStudentIds, Map<String, List<Student_Batch__c>> studentBatchMap, Map<String, List<Student_Batch__c>> studentCourseMap) {
        
        if (studentBatchMap.containsKey(studentId)) {
            List<Student_Batch__c> studentBatches = studentBatchMap.get(studentId);
            for (Student_Batch__c studentBatch : studentBatches) {
                String status = blockedStudentIds.contains(studentId) ? 'BLOCKED' : unblockedStudentIds.contains(studentId) ? 'UNBLOCKED' : null;
                if (status != null) {
                    studentBatch.Status__c = status;
                    studentBatch.Block_Type__c = 'PLATFORM';
                }
            }
        }
        if (studentCourseMap.containsKey(studentId)) {
            List<Student_Batch__c> studentCourses = studentCourseMap.get(studentId);
            for (Student_Batch__c studentCourse : studentCourses) {
                String status = blockedStudentIds.contains(studentId) ? 'BLOCKED' : unblockedStudentIds.contains(studentId) ? 'UNBLOCKED' : null;
                if (status != null) {
                    studentCourse.Status__c = status;
                    studentCourse.Block_Type__c = 'PLATFORM';
                }
            }
        }
    }
    
    // Helper method to extract course IDs from the JSON data
    private static Set<String> getCourseIdsFromJson(List<studentUpdateWrapper> studentBlocksList) {
        Set<String> courseIds = new Set<String>();
        for (studentUpdateWrapper student : studentBlocksList) {
            if (student.block_details != null && student.block_details.course_id != null) {
                courseIds.addAll(student.block_details.course_id);
            }
        }
        return courseIds;
    }
    
    // Helper method to extract product IDs from the JSON data
    private static Set<String> getProductIdsFromJson(List<studentUpdateWrapper> studentBlocksList) {
        Set<String> ProductIds = new Set<String>();
        for (studentUpdateWrapper student : studentBlocksList) {
            if (student.block_details != null && student.block_details.product_id != null) {
                ProductIds.addAll(student.block_details.product_id);
            }
        }
        return ProductIds;
    }
    
    // Helper method to extract batch IDs from the JSON data
    private static Set<String> getBatchIdsFromJson(List<studentUpdateWrapper> studentBlocksList) {
        Set<String> batchIds = new Set<String>();
        for (studentUpdateWrapper student : studentBlocksList) {
            if (student.block_details != null && student.block_details.batch_id != null) {
                batchIds.addAll(student.block_details.batch_id);
            }
        }
        return batchIds;
    }
    
    
    private static void respondWithError(String errorMessage, List<studentUpdateWrapper> studentBlocksList) {
        List<APIResponseWrapper> errorResponses = new List<APIResponseWrapper>();
        if (studentBlocksList != null) {
            for (studentUpdateWrapper student : studentBlocksList) {
                //errorResponses.add(new APIResponseWrapper(student.student_id, errorMessage));
            }
        }
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(errorResponses));
    }
    
    public class APIResponseWrapper {
        public String ref;
        public String message;
    }
    
    public class studentUpdateWrapper {
        public String status;
        public String block_type;
        public block_details_list block_details;
        public String student_id;
        public String remark;
    }
    
    public class block_details_list {
        public String[] course_id;
        public String[] product_id;
        public String[] batch_id;
    }
}