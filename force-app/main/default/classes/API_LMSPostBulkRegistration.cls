@RestResource(urlMapping = '/bulk_leadcreate')
global with sharing class API_LMSPostBulkRegistration{
    @HttpPost
    global static void PostLMS_BulkLeadRegistration(){
        List<Lead> Leadlist = new List<Lead>();
        List<APIResponseWrapper> APIResWrapperList = new List<APIResponseWrapper>();
        List<Product_Interested__c> ProdInterestedList = new List<Product_Interested__c>();
        try{
            RestRequest req = RestContext.request;
            Blob body = req.requestBody;
            String requestString = body.toString();
            System.debug('--- rquestString' + requestString);
            if (!String.isEmpty(requestString)){
                LeadWrapperClass LeadWrap = ReturnLeadLisInstances(requestString);
                if (LeadWrap.LeadsTobeCreated.size() > 0 && LeadWrap.LeadsTobeCreated != null){
                    Schema.SobjectField fToken = Lead.Fields.LMS_StudentId__c;
                    Database.upsertresult[] Leadresult = Database.upsert (LeadWrap.LeadsTobeCreated, fToken, false);
                    //Map<ID, Lead> Leadmap = new Map<ID, Lead>(LeadWrap.LeadsTobeCreated);

                    //System.debug('Leadmap =====> ' + Leadmap);
                    Integer i = 0;

                    for (Database.upsertresult result : Leadresult){

                        System.debug('result ===> ' + result);
                        if (result.issuccess()){
                            if (result.iscreated()){
                                RestContext.response.responseBody = Blob.valueOf('{"Status": "SUCCESS","Message": "All Lead details have been Captured Successfully"');
                                Map<string, Object> LeadCreatedMap = (Map<string, Object>)((LeadWrap.leadmap).get((LeadWrap.LeadsTobeCreated)[i].LMS_StudentId__c));
                                if (LeadCreatedMap.containskey('product_interested_in')) {
                                    List<Object> ProdExtIdObjectList = (List<Object>)(LeadCreatedMap).get('product_interested_in');
                                    List<String> ProdExtIdList = new List<String>();
                                    for (Object Obj : ProdExtIdObjectList) {
                                        ProdExtIdList.add(String.valueOf(Obj));                                        
                                    }
                                    
                                    if (ProdExtIdList.size() >0) {
                                        for (String str : ProdExtIdList) {
                                            Product_Interested__c NewProdInt = new Product_Interested__c();
                                            NewProdInt.Lead__c = result.getid();
                                            NewProdInt.Product__c = (LeadWrap.ProductMap).get(str);
                                            ProdInterestedList.add(NewProdInt);
                                        }
                                    }
                                }
                            } else{
                                RestContext.response.responseBody = Blob.valueOf('{"Status": "SUCCESS","Message": "All Lead details have been Updated Successfully"}');

                            }
                        } else{

                            Database.Error error = result.getErrors()[0];
                            APIResponseWrapper APIResWrap = new APIResponseWrapper();
                            APIResWrap.message = String.valueOf(error);
                            //APIResWrap.message = 'Couldn\'t process this lead due to error';
                            APIResWrap.ref = String.valueOf((LeadWrap.LeadsTobeCreated)[i].LMS_StudentId__c);
                            APIResWrapperList.add(APIResWrap);
                        }
                        i++;
                    }

                }
                if (!ProdInterestedList.isEmpty()) {

                    Database.upsertresult[] Leadresult = Database.upsert (ProdInterestedList, false);

                }
                if (!APIResWrapperList.isEmpty() && APIResWrapperList.size() >0 ) {
                    String ErrorresponseBodyForLead = JSON.serialize(APIResWrapperList);
                    String ErrorresonseBOdy = '{"Status": "ERROR","Message": ' + ErrorresponseBodyForLead + '}';
                    RestContext.response.responseBody = Blob.valueOf(ErrorresonseBOdy);
                    RestContext.response.statusCode = 400;
                    
                }
                // RestContext.response.responseBody = Blob.valueOf('{"Status": "SUCCESS","Message": "All Lead details have been Captured Successfully","ref_id": "vfsvfsv228"}');
                // RestContext.response.statusCode = 200;
            } else{
                String ErrorresonseBOdy = '{"Status": "Error","Message": "JSON Body is empty. Please send data in JSON Body!"}';
                RestContext.response.responseBody = Blob.valueOf(ErrorresonseBOdy);
                RestContext.response.statusCode = 400;
                /*
                String ErrorresponseBodyForLead = JSON.serialize(APIResWrapperList);
                String ErrorresonseBOdy = '{"Status": "ERROR","Message": ' + ErrorresponseBodyForLead;
                RestContext.response.responseBody = Blob.valueOf(ErrorresonseBOdy);
                RestContext.response.statusCode = 400;*/
            }

            String responseBody = RestContext.response.responseBody.toString();
            Integer statusCode = RestContext.response.statusCode;
            HttpUtility.getInstance().createServiceLogger(requestString, responseBody, '/bulk_leadcreate', 'POST', statusCode, System.now(), System.now(),null);


        } catch (Exception e){
            //RestContext.response.responseBody = Blob.valueOf(String.valueOf(e.getMessage()));
            RestContext.response.responseBody = Blob.valueOf('{"Status": "ERROR","Message":"" }');
            RestContext.response.statusCode = 400;
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('API_LMSPostBulkRegistration', 'PostLMS_BulkLeadRegistration', e, null);

        }
    }

    public static LeadWrapperClass ReturnLeadLisInstances(String requestString){

        // ============================= From API Map OBject ==============================
        Map<String, String> ProductExtIdwith = new Map<String, String>();
        Map<String, Object> StudentIdWithLeadOBject = new Map<String, Object>();
        Map<String, List<String>> StudentIdWithCousreList = new Map<String, List<String>>();

        // =============================For and from Salesforce =============================
        List<Lead> LeadlistTobeCreated = new List<Lead>();
        Set<String> CourseIds = new Set<String>();
        List<Product2> ProductList = new List<Product2>();
        LeadWrapperClass LeadWrap = new LeadWrapperClass();


        if (!String.isEmpty(requestString)){
            List<object> bodyMap = (List<object>)JSON.deserializeUntyped(requestString);
            if (bodyMap.size() > 0){
                for (Object LeadObj : bodyMap){
                    Map<string, Object> leadmap = (Map<string, Object>)LeadObj;
                    //LeadWrap.leadmap = leadmap;
                    if (leadmap.containsKey('student_id')){
                        StudentIdWithLeadOBject.put(String.valueOf(leadmap.get('student_id')), leadmap);
                        LeadWrap.leadmap = StudentIdWithLeadOBject;
                    }

                    if (leadmap.containsKey('product_interested_in')){
                        //Map<string, Object> leadmap = (Map<string, Object>)leadmap.get('product_interested_in');
                        List<Object> ProdExtIdObjectList = (List<Object>)(leadmap.get('product_interested_in'));
                        System.debug('ProdExtIdObjectList ====> ' + ProdExtIdObjectList);
                        List<String> ProdExtIdList = new List<String>();
                        for (Object obj : ProdExtIdObjectList) {
                            ProdExtIdList.add(String.valueOf(obj));
                        }
                        StudentIdWithCousreList.put(String.valueOf(leadmap.get('student_id')), ProdExtIdList);
                        for (string str : ProdExtIdList){
                            CourseIds.add(str);

                        }
                    }
                }
            }

            if (CourseIds.size() > 0){
                ProductList = [SELECT City__c, Course_1__c, Course_2__c, Course_3__c, Discount__c, Family, Id, IsActive, isCombo__c, Mode_One__c, Mode_Three__c, Mode_Two__c, Mode__c, Name, Offer__c, LMS_ExternalId__c, ProductCode, QuantityUnitOfMeasure, RecordTypeId, Type__c
                               FROM Product2
                               Where LMS_ExternalId__c IN:CourseIds];
                if (!ProductList.isEmpty()){
                    for (Product2 Pro : ProductList){
                        ProductExtIdwith.put(Pro.LMS_ExternalId__c, Pro.Id);
                        LeadWrap.ProductMap = ProductExtIdwith;
                    }
                }

            }

            for (Object LeadObj : bodyMap){
                Lead LeadToBeCreated = new Lead();
                Map<string, Object> leadmap = (Map<string, Object>)LeadObj;

                if (leadmap.containskey('name')){
                    LeadToBeCreated.LastName = String.valueOf(leadmap.get('name'));
                }
                if (leadmap.containskey('name')){
                    LeadToBeCreated.Company = String.valueOf(leadmap.get('name'));
                }
                if (leadmap.containskey('email')){
                    LeadToBeCreated.email = String.valueOf(leadmap.get('email'));
                }
                if (leadmap.containskey('mobile')){
                    LeadToBeCreated.phone = String.valueOf(leadmap.get('mobile'));
                }
                if (leadmap.containskey('paid_type')){
                    LeadToBeCreated.Paid_Type__c = String.valueOf(leadmap.get('paid_type'));
                }
                if (leadmap.containskey('gender')){
                    LeadToBeCreated.GenderIdentity = String.valueOf(leadmap.get('gender'));
                }
                if (leadmap.containskey('referred_by_email')){
                    LeadToBeCreated.Referral_Email__c = String.valueOf(leadmap.get('referred_by_email'));
                }
                if (leadmap.containskey('student_id')){
                    LeadToBeCreated.LMS_StudentId__c = String.valueOf(leadmap.get('student_id'));
                }
                LeadlistTobeCreated.add(LeadToBeCreated);
            }
        }
        LeadWrap.LeadsTobeCreated = LeadlistTobeCreated;
        System.debug('LeadWrap ===> ' + LeadWrap);
        return LeadWrap;
    }

    public class LeadWrapperClass{
        public List<Lead> LeadsTobeCreated{ get; set; }

        public Map<String, String> ProductMap{ get; set; }

        public Map<string, Object> leadmap{ get; set; }

    }

    Public class APIResponseWrapper{
        public String ref;
        public String message;

    }

}

/*{
 "name": "",
 "email": "",
 "mobile": "",
 "paid_type": "FREE|CORP|ECAC|PREMIUM",
 "product_interested_in": [
 "course_id_1",
 "course_id_2"
 ],
 "gender": "",
 "referred_by_email": "",
 "student_id": ""
 }
 */
//This is the contructor method. When we create a new wrapAccount object we pass a Account that is set to the acc property. We also set the selected value to false
/*public wrapAccount(Account a) {
 acc = a;
 selected = false;
 }*/