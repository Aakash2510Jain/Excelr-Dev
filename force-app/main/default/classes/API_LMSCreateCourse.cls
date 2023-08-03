@RestResource(urlMapping = '/LMSCreateCourse')
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
                    Schema.SobjectField fToken = Product2.Fields.ExternalId;
                    Database.upsertresult[] Prodresult = Database.upsert (ProductInstanceList, fToken, false);
                    Map<ID, Product2> Leadmap = new Map<ID, Product2>(ProductInstanceList);

                    System.debug('Prodresult =====> ' + Prodresult);
                    Integer i = 0;

                    for (Database.upsertresult result : Prodresult){
                        if (result.issuccess()){
                            if (result.iscreated()){
                                RestContext.response.responseBody = Blob.valueOf('{"Status": "SUCCESS","Message": "All Lead details have been Captured Successfully"');
                            } else{
                                RestContext.response.responseBody = Blob.valueOf('{"Status": "SUCCESS","Message": "All Lead details have been Updated Successfully"');
                            }
                        } else{

                            APIResponseWrapper APIResWrap = new APIResponseWrapper();
                            APIResWrap.message = 'Couldn\'t process this Product due to error';
                            APIResWrap.ref = String.valueOf(ProductInstanceList[i].ExternalId);
                            ResponseWrapList.add(APIResWrap);
                        }
                        i++;
                    }

                }
            } else{
                String ErrorresponseBodyForLead = JSON.serialize(ResponseWrapList);
                String ErrorresonseBOdy = '{"Status": "SUCCESS","Message": ' + ErrorresponseBodyForLead;
                RestContext.response.responseBody = Blob.valueOf(ErrorresonseBOdy);
                RestContext.response.statusCode = 400;
            }
        } catch (Exception e){
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
                    if (ProdMap.containskey('productCode')){
                        NewProduct.productCode = String.valueOf(ProdMap.get('productCode'));
                    }
                    if (ProdMap.containskey('description')){
                        NewProduct.description = String.valueOf(ProdMap.get('description'));
                    }
                    if (ProdMap.containskey('family')){
                        NewProduct.family = String.valueOf(ProdMap.get('family'));
                    }
                    if (ProdMap.containskey('isActive')){
                        NewProduct.IsActive = Boolean.valueOf(ProdMap.get('isActive'));
                    }
                    if (ProdMap.containskey('type')){
                        NewProduct.Type__c = String.valueOf(ProdMap.get('type'));
                    }
                    if (ProdMap.containskey('price')){
                        NewProduct.Price__c = Integer.valueOf(ProdMap.get('price'));
                    }
                    if (ProdMap.containskey('ExternalId')){
                        NewProduct.ExternalId = String.valueOf(ProdMap.get('ExternalId'));
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