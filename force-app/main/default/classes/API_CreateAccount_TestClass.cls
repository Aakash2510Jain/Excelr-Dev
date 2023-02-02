@isTest
public class API_CreateAccount_TestClass {
    public static testMethod void testRequstRecord(){
        try{
            list<Account> acclist = new List<Account>();
            Account newAcc = new Account();
            newAcc.Name = 'shubham';
            newAcc.Phone = '2345678';
            newAcc.Email__c ='shubham@gmail.com';
            newAcc.Source__c ='Corporate';
            newAcc.Enter_UTM_Link__c = 'sadsfdg';
            newAcc.Course__c = 'Core Python Training';  
            // acclist.add(newAcc);
            insert newAcc;
            
            opportunity  TestOpp=new opportunity ();
            TestOpp.Name = newAcc.Course__c;
            TestOpp.AccountId = newAcc.Id;
            TestOpp.CloseDate = Date.today();
            TestOpp.StageName = 'Proposal';
            insert TestOpp;
            
            
            Lead ld = new Lead();
            ld.LastName = newAcc.Name;
            ld.Phone = newAcc.Phone;
            ld.Email = newAcc.Email__c;
            ld.LeadSource = newAcc.Source__c;
            ld.Enter_UTM_Link__c = newAcc.Enter_UTM_Link__c;
            // ldlist.add(ld);
            insert ld;
            string leadid = ld.id;
            
            API_CreateAccount reqst = new API_CreateAccount();
            String JsonMsg=JSON.serialize(reqst);
            
            test.startTest();
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI =  '/services/apexrest/DemoUrl'; 
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueOf(JsonMsg);
            string Jsonbody = '';
            RestContext.request =  req;
            RestContext.response= res;
            API_CreateAccount.doPost();
            API_CreateAccount.insertLead(ld, Jsonbody);
            API_CreateAccount.updateLead(ld);
            insert TestOpp;
            update ld;
            test.stopTest();
            
        }catch(Exception e){
            System.debug('ERROR ::'+e.getMessage() +' LINE ::'+e.getLineNumber());
            HandleBusinessException.captureError('API_CreateAccount_TestClass', 'testRequstRecord', e, null);

        }
        
    }
}