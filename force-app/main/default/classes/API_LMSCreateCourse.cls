@RestResource(urlMapping = '/sync_course')
global with sharing class API_LMSCreateCourse{
    @HttpPost
    global static void PostLMS_CreateCourse(){

        try{
            RestRequest req = RestContext.request;
            Blob body = req.requestBody;
            String requestString = body.toString();
            System.debug('--- rquestString' + requestString);

            List<APIResponseWrapper> ResponseWrapList = new List<APIResponseWrapper>();
            if (!String.isEmpty(requestString)){
                List<Product2> ProductInstanceList = ReturnProdListInstances(requestString);
                if (ProductInstanceList.size() > 0 && ProductInstanceList != null){
                    Schema.SobjectField fToken = Product2.Fields.LMS_ExternalId__c;
                    Database.upsertresult[] Prodresult = Database.upsert (ProductInstanceList, fToken, false);
                    Map<ID, Product2> Leadmap = new Map<ID, Product2>(ProductInstanceList);

                    System.debug('Prodresult =====> ' + Prodresult);
                    Integer i = 0;

                    for (Database.upsertresult result : Prodresult){
                        if (result.issuccess()){
                            if (result.iscreated()){
                                RestContext.response.responseBody = Blob.valueOf('{"status": "SUCCESS","message": "All Course details have been Captured Successfully"');
                                RestContext.response.statusCode = 200;
                            } else{
                                RestContext.response.responseBody = Blob.valueOf('{"status": "SUCCESS","message": "All Course details have been Updated Successfully"');
                                RestContext.response.statusCode = 200;
                            }
                        } else{

                            APIResponseWrapper APIResWrap = new APIResponseWrapper();
                            APIResWrap.message = 'Couldn\'t process this Product due to error';
                            APIResWrap.ref = String.valueOf(ProductInstanceList[i].ExternalId);
                            ResponseWrapList.add(APIResWrap);

                        }
                        i++;
                    }
                    if (ResponseWrapList != null && ResponseWrapList.size() >0 ){
                        String ErrorresponseBodyForBatch = JSON.serialize(ResponseWrapList);
                        String ErrorresonseBOdy = '{"status": "ERROR","message": ' + ErrorresponseBodyForBatch;
                        RestContext.response.responseBody = Blob.valueOf(ErrorresonseBOdy);
                        RestContext.response.statusCode = 400;
                    }
                }
            } else{
                // String ErrorresponseBodyForLead = JSON.serialize(ResponseWrapList);
                String ErrorresonseBOdy = '{"status": "Error","message": "JSON Body is empty. Please send data in JSON Body!"}';
                RestContext.response.responseBody = Blob.valueOf(ErrorresonseBOdy);
                RestContext.response.statusCode = 400;
            }

            String responseBody = RestContext.response.responseBody.toString();
            Integer statusCode = RestContext.response.statusCode;
            HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/sync_course', 'POST', statusCode, System.now(), System.now(),null);

        } catch (Exception e){
            String ErrorresponseBodyForBatch = JSON.serialize(E.getMessage());
            String ErrorresonseBOdy = '{"status": "ERROR","message": ' + ErrorresponseBodyForBatch;
            RestContext.response.responseBody = Blob.valueOf(ErrorresonseBOdy);
            RestContext.response.statusCode = 400;

            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('API_LMSUpdateStudentStatus', 'PostLMS_UpdateStudentStatus', e, null);

        }
    }

    public static List<Product2> ReturnProdListInstances(String requestString){

        List<Product2> ProductInstanceList = new List<Product2>();
        if (!String.isEmpty(requestString)){
            List<object> bodyObjectList = (List<object>)JSON.deserializeUntyped(requestString);

            if (!bodyObjectList.isEmpty()){
                for (Object ProdObj : bodyObjectList){
                    Map<string, Object> ProdMap = (Map<string, Object>)ProdObj;
                    Product2 NewProduct = new Product2();

                    if (ProdMap.containskey('name')){
                        NewProduct.Name = String.valueOf(ProdMap.get('name'));
                    }
                    if (ProdMap.containskey('product_code')){
                        NewProduct.productCode = String.valueOf(ProdMap.get('product_code'));
                    }
                    if (ProdMap.containskey('description')){
                        NewProduct.description = String.valueOf(ProdMap.get('description'));
                    }
                    if (ProdMap.containskey('family')){
                        NewProduct.family = String.valueOf(ProdMap.get('family'));
                    }
                    if (ProdMap.containskey('is_active')){
                        NewProduct.IsActive = Boolean.valueOf(ProdMap.get('is_active'));
                    }
                    if (ProdMap.containskey('category')){
                        NewProduct.Category__c = String.valueOf(ProdMap.get('category'));
                    }
                    /*if (ProdMap.containskey('type') && ProdMap.get('type') != null){
                        NewProduct.Type__c = String.valueOf(ProdMap.get('type'));
                    }
                    if (ProdMap.containskey('price') && ProdMap.get('price') != null){
                        NewProduct.Price__c = Integer.valueOf(ProdMap.get('price'));
                    }*/

                    if (ProdMap.containskey('lms_course_id') && ProdMap.get('lms_course_id') != null){
                        NewProduct.LMS_ExternalId__c = String.valueOf(ProdMap.get('lms_course_id'));
                    }

                    ProductInstanceList.add(NewProduct);
                }

            }
        }
        return ProductInstanceList;
    }

    Public class APIResponseWrapper{
        public String ref;
        public String message;

    }

}