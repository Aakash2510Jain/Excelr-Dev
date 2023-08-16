public without sharing class LMS_ApiCallouts {
    
    public static string getAccessToken(){
        try{
            
            LMS_API_Callouts__mdt calloutMDT = LMS_API_Callouts__mdt.getInstance('Get_Token');
            system.debug('calloutMDT -- ' + calloutMDT);
            
            string email = calloutMDT.Email__c;
            string password = calloutMDT.Password__c ;
            String accessTokenEndpoint = calloutMDT.Token_Endpoint__c ;
            System.debug('accessTokenEndpoint--->'+accessTokenEndpoint);
            Http ATHttp = new Http();
            HttpRequest ATRequest = new HttpRequest();
            ATRequest.setEndpoint(accessTokenEndpoint);
            ATRequest.setMethod('GET');
            string reqBody = 'email=' +email+ '&password=' + password;
            
            ATRequest.setBody(reqBody);
            HttpResponse ATResponse = new HttpResponse();
            //if( !Test.isRunningTest() ){}
            ATResponse = ATHttp.send(ATRequest);
            
            System.debug('ATResponse---->'+ATResponse);
            if(ATResponse.getStatusCode()==200){
                Map<String, Object> getResult = (Map<String, Object>)JSON.deserializeUntyped(ATResponse.getBody());
                System.debug('getResult:: ' + getResult.keyset());
                                
                String accessToken = (string)getResult.get('');
                System.debug('ACCESS TOKEN:: ' + accessToken);
                
                return accessToken;  
            }
            return null;
        }
        catch ( Exception e ){
            System.debug(' the Error has occured due to =====> ' + e.getMessage());
            System.debug(' the Error has occured at  =====> ' + e.getLineNumber());
            HandleBusinessException.captureError('afterUpdate','createtaskForIsm', e, null);
            System.debug('error stack trace ======> ' + e.getStackTraceString());
            return e.getMessage();
        }
    }
    
    
    public static void doRegistration(Id contactId){
        try{
            system.debug('contactId -- ' + contactId);
            
            Contact contactRecord = [SELECT Id, Name, GenderIdentity, Email, Phone, MobilePhone, Paid_Type__c FROM Contact WHERE Id =: contactId];
            system.debug('contactRecord -- ' + contactRecord);
            
            if(contactRecord != null){
                studentWrapper sWrapper = new studentWrapper();
                sWrapper.Name = contactRecord.Name;
                sWrapper.gender = contactRecord.GenderIdentity;
                sWrapper.email = contactRecord.Email;
                sWrapper.mobile = contactRecord.MobilePhone != null ? contactRecord.MobilePhone : contactRecord.Phone;
                sWrapper.paid_type = contactRecord.Paid_Type__c;
                
                string jsonBody = JSON.serialize(sWrapper);
                
                string accessToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjIwMTU1MzkzNjkyMTIzMDc2LCJkYXRhIjp7ImlkIjoiMWJiOWE4YWItZGUyYS00NTE5LTliYjktNGI2MjRiMTM3YWE5IiwiaXNfc2ZhZG1pbiI6dHJ1ZX0sImlhdCI6MTY5MjEyMzA3NX0.6fy7K7aP3ilRYC7QDfNj42ECMm_JrHNPonE4gUwludc'; //getAccessToken();
                LMS_API_Callouts__mdt calloutMDT = LMS_API_Callouts__mdt.getInstance('Get_Token');            
                string registrationEndpoint = calloutMDT.Student_Registration_Endpoint__c;
                system.debug('registrationEndpoint -- ' + registrationEndpoint);
                
                HttpResponse resp = HTTPUtility.sendRequest(registrationEndpoint, accessToken, jsonBody, 'POST');
                system.debug('resp -- ' + resp);
                if(resp.getStatusCode() == 200){
                    system.debug('Success');                    
                }         
            }
            
            
        }
        catch ( Exception e ){
            System.debug(' the Error has occured due to =====> ' + e.getMessage());
            System.debug(' the Error has occured at  =====> ' + e.getLineNumber());
            HandleBusinessException.captureError('afterUpdate','createtaskForIsm', e, null);
            System.debug('error stack trace ======> ' + e.getStackTraceString());
        }
    }
    
    public class studentWrapper{
        public String name;	//Aayush
        public String gender;	//Male
        public String email;	//nms@yopmail.com
        public String mobile;	//8595847323
        public String paid_type;	//FREE
    }
    
    public static void doProductPriceUpdate(Id productId){
        try{
            system.debug('productId -- ' + productId);
            
        }
        catch ( Exception e ){
            System.debug(' the Error has occured due to =====> ' + e.getMessage());
            System.debug(' the Error has occured at  =====> ' + e.getLineNumber());
            HandleBusinessException.captureError('afterUpdate','createtaskForIsm', e, null);
            System.debug('error stack trace ======> ' + e.getStackTraceString());
        }
    }
    
     public class productPriceWrapper{
        public String product_id;	//ca46784f-9cee-4e3e-ab44-8467efe5c383
        public String price;	//100
    }
    
    public static void doCoursePriceUpdate(Id productId){
        try{
            system.debug('productId -- ' + productId);
            
        }
        catch ( Exception e ){
            System.debug(' the Error has occured due to =====> ' + e.getMessage());
            System.debug(' the Error has occured at  =====> ' + e.getLineNumber());
            HandleBusinessException.captureError('afterUpdate','createtaskForIsm', e, null);
            System.debug('error stack trace ======> ' + e.getStackTraceString());
        }
    }
    
     public class coursePriceWrapper{
        public String course_id;	//ca46784f-9cee-4e3e-ab44-8467efe5c383
        public String price;	//100
    }
    
}