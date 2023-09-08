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
            ATRequest.setMethod('POST');
            string reqBody = 'email=' +email+ '&password=' + password;
            
            ATRequest.setBody(reqBody);
            HttpResponse ATResponse = new HttpResponse();
            //if( !Test.isRunningTest() ){}
            ATResponse = ATHttp.send(ATRequest);
            
            System.debug('ATResponse---->'+ATResponse);
            if(ATResponse != null){
                if(ATResponse.getStatusCode()==200){
                    Map<String, Object> getResult = (Map<String, Object>)JSON.deserializeUntyped(ATResponse.getBody());
                    System.debug('getResult:: ' + getResult.keyset());
                    
                    Object accessTokenObject = getResult.get('data');
                    System.debug('accessTokenObject:: ' + accessTokenObject);
                    Map<string, Object> tokenMap = (Map<string, Object>)accessTokenObject;
                    String accessToken = (string)tokenMap.get('token');
                    System.debug('ACCESS TOKEN:: ' + accessToken);
                    return accessToken;  
                }
            }
            return null;
        }
        catch ( Exception e ){
            System.debug(' the Error has occured due to =====> ' + e.getMessage());
            System.debug(' the Error has occured at  =====> ' + e.getLineNumber());
            HandleBusinessException.captureError('LMS_ApiCallouts','getAccessToken', e, null);
            System.debug('error stack trace ======> ' + e.getStackTraceString());
            return e.getMessage();
        }
    }
    
    public class studentWrapper{
        public String name;	//Aayush
        public String gender;	//Male
        public String email;	//nms@yopmail.com
        public String country_code;	//+91
        public String mobile;	//8595847323
        public String paid_type;	//FREE
    }


    @future(callout = true)
    public static void doRegistration(List<Id> conIds) {
        try {
            List<Contact> conRecords = [SELECT Id, Name, GenderIdentity, LMS_Student_Id__c, Email, Phone, MobilePhone, Paid_Type__c FROM Contact WHERE Id IN :conIds];
            String accessToken = getAccessToken();
            
            if (accessToken != null) {
                for (Contact conRecord : conRecords) {
                    studentWrapper sWrapper = new studentWrapper();
                    sWrapper.name = conRecord.Name;
                    sWrapper.email = conRecord.Email;
                    sWrapper.gender = 'Female';
                    sWrapper.paid_type = conRecord.Paid_Type__c;
                    
                    String phone = conRecord.MobilePhone != null ? conRecord.MobilePhone : conRecord.Phone;
                    if(phone != null){
                        System.debug('phone------>'+phone);
                        if (phone.length() == 10) {
                            sWrapper.mobile = phone;
                            sWrapper.country_code = '';
                        } else if (phone.length() > 10) {
                            sWrapper.mobile = phone.right(10);
                            sWrapper.country_code = phone.left(3);
                        }
                    }
                    
                    String jsonBody = JSON.serialize(sWrapper);
                    
                    LMS_API_Callouts__mdt calloutMDT = LMS_API_Callouts__mdt.getInstance('Get_Token');  
                    
                    Map<String, String> headerMap = new Map<String, String>();
                    headerMap.put('Content-Type', 'application/json');
                    headerMap.put('Authorization', 'Bearer ' + accessToken);
                    headerMap.put('Accept-Encoding', 'gzip, deflate, br');
                    
                    HttpResponse resp = HttpUtility.getInstance().httpReqHelper(headerMap, 'POST', jsonBody, calloutMDT.Student_Registration_Endpoint__c, conIds);
                    
                    if (resp != null && resp.getStatusCode() == 200) {
                        Map<String, Object> responseData = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());
                        Map<String, Object> dataMap = (Map<String, Object>) responseData.get('data');
                        Map<String, Object> resultData = (Map<String, Object>) dataMap.get('result');
                        String studentId = (String) resultData.get('id');
                        
                        if (studentId != null && !string.isBlank(studentId)) {
                            conRecord.LMS_Student_Id__c = studentId;
                        }
                    }
                }
                update conRecords;
            }
        } catch (Exception e) {
            System.debug('The error has occurred due to =====> ' + e.getMessage());
            System.debug('The error has occurred at  =====> ' + e.getLineNumber());
            HandleBusinessException.captureError('LMS_ApiCallouts', 'doRegistration', e, null);
            System.debug('Error stack trace ======> ' + e.getStackTraceString());
        }
    }
    
    public class productPriceWrapper{
        public String product_id;	//ca46784f-9cee-4e3e-ab44-8467efe5c383
        public Decimal price;	//100
    }    
    
    public static void doProductPriceUpdate(List<Id> productIds) {
        try {
            List<Product2> prodRecs = [SELECT Id, LMS_ExternalId__c FROM Product2 WHERE Id IN :productIds];
            String accessToken = getAccessToken();
            
            if (accessToken != null) {
                for (Product2 prodRec : prodRecs) {
                    List<PriceBookEntry> pbeList = [SELECT Id, UnitPrice FROM PriceBookEntry WHERE Product2Id = :prodRec.Id];
                    LMS_API_Callouts__mdt calloutMDT = LMS_API_Callouts__mdt.getInstance('Get_Token');
                    
                    Map<String, String> headerMap = new Map<String, String>();
                    headerMap.put('Content-Type', 'application/json');
                    headerMap.put('Authorization', 'Bearer ' + accessToken);
                    headerMap.put('Cookie', calloutMDT.Cookie__c);
                    headerMap.put('Accept-Encoding', 'gzip, deflate, br');
                    
                    productPriceWrapper priceWrapper = new productPriceWrapper();
                    priceWrapper.product_id = prodRec.LMS_ExternalId__c;
                    priceWrapper.price = pbeList[0].UnitPrice; 
                    String jsonBody = JSON.serialize(priceWrapper);   
                    
                    HttpResponse resp = HttpUtility.getInstance().httpReqHelper(headerMap, 'POST', jsonBody, calloutMDT.Update_Product_Price_Endpoint_c__c, productIds);
                    
                    if(resp != null){
                        system.debug('resp -- ' + resp.getBody());
                        if (resp.getStatusCode() == 200) {
                            system.debug('Product Price update success');
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.debug('The error has occurred due to =====> ' + e.getMessage());
            System.debug('The error has occurred at  =====> ' + e.getLineNumber());
            HandleBusinessException.captureError('LMS_ApiCallouts', 'doProductPriceUpdate', e, null);
            System.debug('Error stack trace ======> ' + e.getStackTraceString());
        }
    }
    
    public class coursePriceWrapper{
        public String course_id;	//ca46784f-9cee-4e3e-ab44-8467efe5c383
        public Decimal price;	//100
    }
    
    public static void doCoursePriceUpdate(List<Id> courseIds) {
        try {
            List<Product2> courseRecs = [SELECT Id, LMS_ExternalId__c FROM Product2 WHERE Id IN :courseIds];
            String accessToken = getAccessToken();
            
            if (accessToken != null) {
                for (Product2 courseRec : courseRecs) {
                    List<PriceBookEntry> pbeList = [SELECT Id, UnitPrice FROM PriceBookEntry WHERE Product2Id = :courseRec.Id];
                    LMS_API_Callouts__mdt calloutMDT = LMS_API_Callouts__mdt.getInstance('Get_Token');
                    
                    Map<String, String> headerMap = new Map<String, String>();
                    headerMap.put('Content-Type', 'application/json');
                    headerMap.put('Authorization', 'Bearer ' + accessToken);
                    headerMap.put('Cookie', calloutMDT.Cookie__c);
                    headerMap.put('Accept-Encoding', 'gzip, deflate, br');
                    
                    coursePriceWrapper priceWrapper = new coursePriceWrapper();
                    priceWrapper.course_id = courseRec.LMS_ExternalId__c;
                    priceWrapper.price = pbeList[0].UnitPrice;
                    
                    String jsonBody = JSON.serialize(priceWrapper);
                    
                    HttpResponse resp = HttpUtility.getInstance().httpReqHelper(headerMap, 'POST', jsonBody, calloutMDT.Update_Course_Price_Endpoint_c__c, courseIds);
                    
                    if(resp != null){       
                        system.debug('resp -- ' + resp.getBody());
                        if (resp.getStatusCode() == 200) {
                            system.debug('Course Price update success');
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.debug('The error has occurred due to =====> ' + e.getMessage());
            System.debug('The error has occurred at  =====> ' + e.getLineNumber());
            HandleBusinessException.captureError('LMS_ApiCallouts', 'doCoursePriceUpdate', e, null);
            System.debug('Error stack trace ======> ' + e.getStackTraceString());
        }
    }
    
    
    public class invoiceStatusWrapper{
        public String invoice_number; //INV-12345
        public String status;	//SUBMITTED|ACKNOWLEDGED|NEED CLARIFICATION|INPROCESS|PROCESSED
    }    
    
    public static void doInvoiceStatusUpdate(set<Id> trainerInvoiceIds) {
        try {
            system.debug('trainerInvoiceIds -- ' + trainerInvoiceIds);
            List<Trainer_Invoice__c> tInvoiceList = [SELECT Id, Invoice_Number__c, Status__c FROM Trainer_Invoice__c WHERE Id IN :trainerInvoiceIds];
            String accessToken = getAccessToken();
            
            if (accessToken != null) {
                for (Trainer_Invoice__c tInvRec : tInvoiceList) {
                    LMS_API_Callouts__mdt calloutMDT = LMS_API_Callouts__mdt.getInstance('Get_Token');
                    
                    Map<String, String> headerMap = new Map<String, String>();
                    headerMap.put('Content-Type', 'application/json');
                    headerMap.put('Authorization', 'Bearer ' + accessToken);
                    headerMap.put('Cookie', calloutMDT.Cookie__c);
                    headerMap.put('Accept-Encoding', 'gzip, deflate, br');
                    
                    invoiceStatusWrapper tInvWrapper = new invoiceStatusWrapper();
                    tInvWrapper.invoice_number = tInvRec.Invoice_Number__c;
                    tInvWrapper.status = tInvRec.Status__c; 
                    String jsonBody = JSON.serialize(tInvWrapper);   
                    
                    List<Id> refIds = new List<Id>();
                    refIds.addAll(trainerInvoiceIds);
                    system.debug('refIds -- ' + refIds);
                    
                    HttpResponse resp = HttpUtility.getInstance().httpReqHelper(headerMap, 'POST', jsonBody, calloutMDT.Trainer_Invoice_Status_Update_Endpoint__c, refIds);
                    
                    if(resp != null){
                        system.debug('resp -- ' + resp.getBody());
                        if (resp.getStatusCode() == 200) {
                            system.debug('Trainer Invoice status update success');
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.debug('The error has occurred due to =====> ' + e.getMessage());
            System.debug('The error has occurred at  =====> ' + e.getLineNumber());
            HandleBusinessException.captureError('LMS_ApiCallouts', 'doInvoiceStatusUpdate', e, null);
            System.debug('Error stack trace ======> ' + e.getStackTraceString());
        }
    }

    
    public class caseStatusWrapper{
        public String ticket_number;
        public String status;
    }    
    
    public static void doCaseStatusUpdate(set<Id> caseIds) {
        try {
            system.debug('caseIds -- ' + caseIds);
            List<Case> caseList = [SELECT Id, Ticket_Number__c, Status FROM Case WHERE Id IN :caseIds];
            String accessToken = getAccessToken();
            
            if (accessToken != null) {
                for (Case csRec : caseList) {
                    LMS_API_Callouts__mdt calloutMDT = LMS_API_Callouts__mdt.getInstance('Get_Token');
                    
                    Map<String, String> headerMap = new Map<String, String>();
                    headerMap.put('Content-Type', 'application/json');
                    headerMap.put('Authorization', 'Bearer ' + accessToken);
                    headerMap.put('Cookie', calloutMDT.Cookie__c);
                    headerMap.put('Accept-Encoding', 'gzip, deflate, br');
                    
                    caseStatusWrapper caseWrapper = new caseStatusWrapper();
                    caseWrapper.ticket_number = csRec.Ticket_Number__c;
                    caseWrapper.status = csRec.Status; 
                    String jsonBody = JSON.serialize(caseWrapper);   
                    
                    List<Id> refIds = new List<Id>();
                    refIds.addAll(caseIds);
                    system.debug('refIds -- ' + refIds);
                    
                    HttpResponse resp = HttpUtility.getInstance().httpReqHelper(headerMap, 'POST', jsonBody, calloutMDT.Case_Status_Update_Endpoint__c, refIds);
                    
                    if(resp != null){
                        system.debug('resp -- ' + resp.getBody());
                        if (resp.getStatusCode() == 200) {
                            system.debug('Trainer Invoice status update success');
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.debug('The error has occurred due to =====> ' + e.getMessage());
            System.debug('The error has occurred at  =====> ' + e.getLineNumber());
            HandleBusinessException.captureError('LMS_ApiCallouts', 'doInvoiceStatusUpdate', e, null);
            System.debug('Error stack trace ======> ' + e.getStackTraceString());
        }
    }
    
}