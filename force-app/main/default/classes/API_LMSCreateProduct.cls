@RestResource(urlMapping = '/sync_product')
global with sharing class API_LMSCreateProduct{
    @HttpPost
    global static void PostLMS_CreateProduct(){
        List<String> ProductidSet = new List<String>();
        List<LMS_Product_Bundle__c> LMSProductListToInsert = new List<LMS_Product_Bundle__c>();
        Map<Id, String> mapOfProdIdPBId = new Map<Id, String>();
        Map<String, String> courseIdByProdBundleId = new Map<String, String>();
        Map<String, List<String>> mapOfPBIdProudctIdset = new Map<String, List<String>>();

        List<Id> insertedRecordIds = new List<Id>();

        List<Child_Product__c> ChildProductRecords = new List<Child_Product__c>();

        try{
            RestRequest req = RestContext.request;
            Blob body = req.requestBody;
            String requestString = body.toString();
            System.debug('--- rquestString' + requestString);
            APIResponseWrapper APIResponseWrap = new APIResponseWrapper();
            List<APIResponseWrapper> ResponseWrapList = new List<APIResponseWrapper>();

            if (!String.isEmpty(requestString)){

                BundledProductWrapper BundledProductWrap = CreateproductInstance(requestString);

                if (BundledProductWrap.ProductBundledTobeCreatedList.size() > 0 && BundledProductWrap.ProductBundledTobeCreatedList != null){
                    Schema.SobjectField fToken = Product2.Fields.LMS_ExternalId__c;
                    Database.upsertresult[] Prodresult = Database.upsert (BundledProductWrap.ProductBundledTobeCreatedList, fToken, false);
                    Map<ID, Product2> Leadmap = new Map<ID, Product2>(BundledProductWrap.ProductBundledTobeCreatedList);

                    System.debug('Prodresult =====> ' + Prodresult);
                    Integer i = 0;

                    for (Database.upsertresult result : Prodresult){
                        if (result.issuccess()){
                            if (result.iscreated()){
                                Child_Product__c ChildProducttobecreated = new Child_Product__c();
                                if ((BundledProductWrap.BundledProductWithProductIdmap).containskey(Leadmap.get(result.getId()).LMS_ExternalId__c)){
                                    List<String> CourseList = BundledProductWrap.BundledProductWithProductIdmap.get(Leadmap.get(result.getId()).LMS_ExternalId__c);
                                    for (String str : CourseList){
                                        if (BundledProductWrap.ProductLMSIdwithRecId.containskey(str)){
                                            ChildProducttobecreated.Child_Product__c = BundledProductWrap.ProductLMSIdwithRecId.get(str);
                                            ChildProducttobecreated.Bundle_Product__c = result.getId();
                                            ChildProductRecords.add(ChildProducttobecreated);
                                        }
                                    }
                                }


                                RestContext.response.responseBody = Blob.valueOf('{"status": "SUCCESS","message": "All Course details have been Captured Successfully"');
                                RestContext.response.statusCode = 200;
                            } else{
                                RestContext.response.responseBody = Blob.valueOf('{"status": "SUCCESS","message": "All Course details have been Updated Successfully"');
                                RestContext.response.statusCode = 200;
                            }
                        } else{

                            APIResponseWrapper APIResWrap = new APIResponseWrapper();
                            APIResWrap.message = 'Couldn\'t process this Product due to error';
                            APIResWrap.ref = String.valueOf(BundledProductWrap.ProductBundledTobeCreatedList[i].LMS_ExternalId__c);
                            ResponseWrapList.add(APIResWrap);


                        }
                        i++;
                    }

                    if (!ChildProductRecords.isEmpty()){
                        Database.SaveResult[] srList = Database.insert (ChildProductRecords, false);

                        Map<ID, Child_Product__c> ChildProductRecordsMap = new Map<ID, Child_Product__c>(ChildProductRecords);

                        for (Database.SaveResult sr : srList){
                            if (sr.isSuccess()){
                                insertedRecordIds.add(sr.getId());
                                // Operation was successful, so get the ID of the record that was processed
                                System.debug('Successfully inserted account. Account ID: ' + sr.getId());
                            } else{
                                // Operation failed, so get all errors
                                for (Database.Error err : sr.getErrors()){
                                    System.debug('The following error has occurred.');
                                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                    System.debug('Account fields that affected this error: ' + err.getFields());
                                }
                            }
                        }

                       
                    }
                    

                        /*List<LMSDataWrapper> lmsDataWrapperList = (List<LMSDataWrapper>) JSON.deserialize(requestString, List<LMSDataWrapper>.class);
                         if(null !=lmsDataWrapperList && lmsDataWrapperList.size()>0){
                         for(LMSDataWrapper wrap : lmsDataWrapperList){
                         system.debug('wrap === >'+wrap);
                         if(String.isNotBlank(wrap.lms_product_id)){
                         if(!mapOfPBIdProudctIdset.containsKey(wrap.lms_product_id)){
                         mapOfPBIdProudctIdset.put(wrap.lms_product_id,wrap.course_ids);
                         }
                         }
                         }
                         System.debug('mapOfPBIdProudctIdset === >'+mapOfPBIdProudctIdset);
                         if(!mapOfPBIdProudctIdset.isEmpty()){
                         for(String lmsProdId : mapOfPBIdProudctIdset.keySet()){
                         for(String productId : mapOfPBIdProudctIdset.get(lmsProdId)){
                         courseIdByProdBundleId.put(productId,lmsProdId);
                         }
                         }
                         if(!courseIdByProdBundleId.isEmpty()){
                         for(Product2 productrec : [SELECT Id,Name FROM Product2 WHERE ID IN: courseIdByProdBundleId.keySet()]){
                         LMS_Product_Bundle__c lmsProd = new LMS_Product_Bundle__c();
                         lmsProd.Product__c = productrec.id;
                         lmsProd.Product_Bundle__c = courseIdByProdBundleId.get(productrec.id);
                         LMSProductListToInsert.add(lmsProd);
                         }
                         if(!LMSProductListToInsert.isEmpty()){
                         insert LMSProductListToInsert;
                         system.debug('LMSProductListToInsert === >'+LMSProductListToInsert);
                         }
                         }
                         }
                         }*/
                        // RestContext.response.responseBody = Blob.valueOf('{"Status": "SUCCESS","Message": "Batch Created Successfully"}');
                        // RestContext.response.statusCode = 200;
                    } else{
                        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new IntegrationWrapper.APIResponseWrapper('Error', 'JSON Body is empty. Please send JSON body!!')));
                        RestContext.response.statusCode = 400;
                    }
                }
                
                String responseBody = RestContext.response.responseBody.toString();
                Integer statusCode = RestContext.response.statusCode;
                System.debug('insertedRecordIds------->'+insertedRecordIds);
                HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/sync_product', 'POST', statusCode, System.now(), System.now(),insertedRecordIds);

            } catch (Exception e){
                system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
                HandleBusinessException.captureError('API_LMSUpdateStudentStatus', 'PostLMS_UpdateStudentStatus', e, null);

            }
        }

        public static BundledProductWrapper CreateproductInstance(String requestString){

            set<String> CourseIds = new Set<String>();
            List<Product2> ProductList = new List<Product2>();
            Map<String, String> ProductLMSIdwithRecId = new Map<String, String>();
            List<Product2> ProductBundledTobeCreatedList = new List<Product2>();
            Map<String, List<String>> BundledProductWithProductIdmap = new Map<String, List<String>>();

            BundledProductWrapper BundledProductWrap = new BundledProductWrapper();

            try{
                if (!String.isEmpty(requestString)){
                    List<object> bodyObjectList = (List<object>)JSON.deserializeUntyped(requestString);

                    if (!bodyObjectList.isEmpty()){
                        for (Object ProdObj : bodyObjectList){
                            Map<string, Object> ProdMap = (Map<string, Object>)ProdObj;
                            if (ProdMap.containsKey('course_ids')){
                                List<Object> ProdExtobjIdList = (List<Object>)ProdMap.get('course_ids');
                                List<String> prodExtIdList = new List<String>();
                                for (Object obj : ProdExtobjIdList){
                                    prodExtIdList.add(String.valueOf(obj));
                                }
                                if (ProdMap.containskey('lms_product_id')){
                                    BundledProductWithProductIdmap.put(String.valueOf(ProdMap.containskey('lms_product_id')), prodExtIdList);
                                }

                                if (!prodExtIdList.isEmpty()){
                                    ProductList = [Select Id, Name, LMS_ExternalId__c
                                                   from Product2
                                                   Where LMS_ExternalId__c IN:prodExtIdList];
                                    if (!ProductList.isEmpty() && ProductList.size() > 0){
                                        for (Product2 prod : ProductList){
                                            ProductLMSIdwithRecId.put(prod.LMS_ExternalId__c, prod.Id);
                                        }
                                    }
                                }
                            }
                        }
                        BundledProductWrap.BundledProductWithProductIdmap = BundledProductWithProductIdmap;
                        BundledProductWrap.ProductLMSIdwithRecId = ProductLMSIdwithRecId;

                        for (Object ProdObj : bodyObjectList){
                            Map<string, Object> ProdMap = (Map<string, Object>)ProdObj;
                            Product2 Productbundled = new Product2();
                            if (ProdMap.containskey('lms_product_id')){
                                Productbundled.LMS_ExternalId__c = String.valueOf(ProdMap.get('lms_product_id'));
                                Productbundled.Name = String.valueOf(ProdMap.get('lms_product_id'));
                            }
                            ProductBundledTobeCreatedList.add(Productbundled);

                        }
                        BundledProductWrap.ProductBundledTobeCreatedList = ProductBundledTobeCreatedList;
                    }
                }


            } catch (Exception e){

            }


            return BundledProductWrap;
        }

        public class BundledProductWrapper{
            public List<Product2> ProductBundledTobeCreatedList;
            public Map<String, List<String>> BundledProductWithProductIdmap;
            public Map<String, String> ProductLMSIdwithRecId;
        }

        Public class APIResponseWrapper{
            public String ref;
            public String message;
        }

        public class LMSDataWrapper{
            public String lms_product_id;
            public List<String> course_ids;

        }

    }