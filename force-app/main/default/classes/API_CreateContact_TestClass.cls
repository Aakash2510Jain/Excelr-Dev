@isTest
public class API_CreateContact_TestClass {
    public static testMethod void testContactAPI(){
         try{
        map<string,string> mapemail = new map<string,string>(); 
        
        Contact con = new Contact();
        con.LastName = 'Kumar';
        con.Email = 'shubham@gmail.com';
        insert con;
         
             API_CreateContact reqst = new API_CreateContact();
            String JsonMsg=JSON.serialize(reqst);
             test.startTest();
              RestRequest req = new RestRequest(); 
              RestResponse res = new RestResponse();
             req.requestURI =  '/services/apexrest/DemoUrl'; 
             req.httpMethod = 'POST';
            req.requestBody = Blob.valueOf(JsonMsg);
            
             RestContext.request =  req;
             RestContext.response= res;
            API_CreateContact.doPost();
           // API_CreateContact.insertContacts(con);
              
           test.stopTest();
        }  catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('API_CreateContact_TestClass', 'testContactAPI', e, null);
             
        }
    
    }
}