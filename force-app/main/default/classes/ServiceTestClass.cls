@IsTest
public  class ServiceTestClass {
    
    @IsTest static void test_API_CreateAccount(){
        
        RestRequest request 				=	new RestRequest();
        RestResponse res 					= 	new RestResponse();
        request.requestUri 					= 	'https://excelr2--dev.sandbox.my.salesforce.com/services/apexrest/create_Account';
        request.httpMethod 					= 	'POST';
        request.requestBody 				= 	Blob.valueOf('{"Name": "Aakash Jain",    "Phone": "9560635420",    "Email__c": "aakash.123jain@gmail.com ",    "Course__c": "Data Science",    "Type_of_Course__c": "combo",    "City__c": "Delhi",    "Form_Names__c": "Live Virtual",    "UTM_Medium__c": "Direct",    "UTM_Campaign__c": "Campaign Name",    "UTM_Device__c": "Device Name",    "UTM_AdGroup__c": "Ad Group",    "UTM_Term__c": "Term",    "UTM_Channel__c": "Channel",    "UTM_Type__c": "RMKT",    "Location_UTM__c": "Location",    "UTM_Variety__c": "Variety",    "UTM_Experiment__c": "Experiment",    "Enter_UTM_Link__c": "Link"}');
        RestContext.request 				= 	request;
        RestContext.response				= 	res;
        API_CreateAccount.doPost();
        API_CreateAccount.insertLead(null, null);
        API_CreateAccount.updateLead(null);
        API_CreateAccount.insertApplication(null,null);
    }  
    @IsTest static void test_API_CreateAccount_V1(){
        
        RestRequest request 				=	new RestRequest();
        RestResponse res 					= 	new RestResponse();
        request.requestUri 					= 	'https://excelr2--dev.sandbox.my.salesforce.com/services/apexrest/create_Account';
        request.httpMethod 					= 	'POST';
        request.requestBody 				= 	Blob.valueOf('');
        RestContext.request 				= 	request;
        RestContext.response				= 	res;
        API_CreateAccount.doPost();
    }  
    @IsTest static void test_API_CreateLead(){
        
        RestRequest request 				=	new RestRequest();
        RestResponse res 					= 	new RestResponse();
        request.requestUri 					= 	'https://excelr2--dev.sandbox.my.salesforce.com/services/apexrest/create_lead';
        request.httpMethod 					= 	'POST';
        request.requestBody 				= 	Blob.valueOf('{"Name": "Aakash Jain",    "Phone": "9560635420",    "Email__c": "aakash.123jain@gmail.com ",    "Course__c": "Data Science",    "Type_of_Course__c": "combo",    "City__c": "Delhi",    "Form_Names__c": "Live Virtual",    "UTM_Medium__c": "Direct",    "UTM_Campaign__c": "Campaign Name",    "UTM_Device__c": "Device Name",    "UTM_AdGroup__c": "Ad Group",    "UTM_Term__c": "Term",    "UTM_Channel__c": "Channel",    "UTM_Type__c": "RMKT",    "Location_UTM__c": "Location",    "UTM_Variety__c": "Variety",    "UTM_Experiment__c": "Experiment",    "Enter_UTM_Link__c": "Link"}');
        RestContext.request 				= 	request;
        RestContext.response				= 	res;
        API_CreateLead.doPost();
      //  API_CreateLead.insertLead(null);
         
     }
    @IsTest static void test_API_CreateLead_V1(){
        
        RestRequest request 				=	new RestRequest();
        RestResponse res 					= 	new RestResponse();
        request.requestUri 					= 	'https://excelr2--dev.sandbox.my.salesforce.com/services/apexrest/create_Account';
        request.httpMethod 					= 	'POST';
        request.requestBody 				= 	Blob.valueOf('');
        RestContext.request 				= 	request;
        RestContext.response				= 	res;
        API_CreateLead.doPost();
    } 
    
    @IsTest static Application__c test_AppWithLead()  {
        Application__c appRec = new Application__c();
         appRec.Course__c = 'Cloud Computing';
        Datetime myDate = Datetime.newInstance(2008, 12, 1, 12, 30, 2);
         Lead ld = new Lead(LastName ='Akash',Company='util',Course__c='ACP');
        insert ld;
        appRec.Applied_Date_Time__c = myDate ;  
        appRec.Lead__c = ld.id;
        insert appRec;
        string appId = apprec.id;
        AppWithLead var = new AppWithLead();
        
        AppWithLead.fetchApp(appId);
        return apprec;
     }  
 
    @IsTest static void test_BatchForOverdueTasks(){
        Contact conRec = new Contact(LastName='Jain');
        insert conRec;
        list<Task> tasklist = new list<TasK>();
        Task taskRec = new Task( Subject='call',Priority='High',Status='Open',WhoId =conRec.id);
        tasklist.add(taskRec);
        insert tasklist;
        
         
        Case caseRec  = new Case();
        caseRec.Subject = 'Define Severity on Case Number 00001054';
        caseRec.ContactId = taskRec.WhoId;
        caseRec.OwnerId = [Select Id from User where isActive= true limit 1 ].Id;
        insert caseRec;
        BatchForOverdueTasks batchInstance =  new BatchForOverdueTasks();
        database.executeBatch(batchInstance);
    }
}