@RestResource(urlMapping = '/LMSCreateUpdateProduct') 
global with sharing class API_LMSCreateProduct {
    
    @HttpPost
    global static void PostLMS_CreateProduct(){
        List<String> ProductidSet = new List<String>();
        List<LMS_Product_Bundle__c> LMSProductListToInsert = new List<LMS_Product_Bundle__c>();
        Map<Id,String> mapOfProdIdPBId = new Map<Id,String>();
        Map<String, String> courseIdByProdBundleId = new Map<String, String>();
        Map<String,List<String>> mapOfPBIdProudctIdset = new Map<String,List<String>>();
        
        try{
            RestRequest req = RestContext.request;
            Blob body = req.requestBody;
            String requestString = body.toString();
            System.debug('--- rquestString' + requestString);
            
            if (!String.isEmpty(requestString)){
                List<LMSDataWrapper> lmsDataWrapperList = (List<LMSDataWrapper>) JSON.deserialize(requestString, List<LMSDataWrapper>.class);
                if(null !=lmsDataWrapperList && lmsDataWrapperList.size()>0){
                    for(LMSDataWrapper wrap : lmsDataWrapperList){
                        system.debug('wrap === >'+wrap);
                        if(String.isNotBlank(wrap.lms_product_id)){
                            if(!mapOfPBIdProudctIdset.containsKey(wrap.lms_product_id)){
                                mapOfPBIdProudctIdset.put(wrap.lms_product_id,wrap.course_ids);
                            }else{
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
                }
                // RestContext.response.responseBody = Blob.valueOf('{"Status": "SUCCESS","Message": "Batch Created Successfully"}');
                // RestContext.response.statusCode = 200;
            } else{
                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new IntegrationWrapper.APIResponseWrapper('Error', '[{"ref": "003N000001xyPbwIAE","message": "Couldn\'t process this lead due to error"}, { "ref": "003N000001xyPbwIAE","message": "Couldn\'t process this lead due to error" }]')));
                RestContext.response.statusCode = 400;
            }
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('API_LMSUpdateStudentStatus', 'PostLMS_UpdateStudentStatus', e, null);
            
        }
    }
    
    
    
    public class LMSDataWrapper {
        public String lms_product_id;
        public List<String> course_ids;
    }
}