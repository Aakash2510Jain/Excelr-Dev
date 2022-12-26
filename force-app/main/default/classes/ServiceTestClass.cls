@IsTest
public class ServiceTestClass {

    @IsTest static void testAPICreateAccount(){
        Account accRec = UtilityClassForTestClass.insertAccRec('Akash','shubhma@gmail.com','2345678','Corporate','Webinar','sadsfdg','Core Python Training');
        insert accRec;  
        Lead leadRec = UtilityClassForTestClass.insertLead('Akash','jain ','shubhma@gmail.com','2345678','Corporate','Webinar','sadsfdg','Core Python Training');
        insert leadRec; 
        
        Opportunity oppRec = UtilityClassForTestClass.insertOpp('Akash','26/12/2022','Proposal',accRec.id);
        update oppRec;
        
         API_CreateAccount reqst = new API_CreateAccount();
          String JsonMsg = JSON.serialize(reqst);
         test.startTest();
        RestRequest request 	= new RestRequest();
       // RestResponse res        = new RestResponse();
        request.requestUri 		= '/services/apexrest/DemoUrl';
       // request.addParameter('id', recordId);
        request.requestBody = Blob.valueOf(JsonMsg);
        request.httpMethod 		= 'POST';
        RestContext.request 	= request;
        //RestContext.response    = res;
        API_CreateAccount.doPost();
        API_CreateAccount.insertLead(leadRec);
        API_CreateAccount.updateLead(leadRec);
        test.stopTest();
    }    

}