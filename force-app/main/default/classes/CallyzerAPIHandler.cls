public without sharing class CallyzerAPIHandler
{
    public Static void processHistory(List<String> clientNums)
    {
        try{
        List<Contact> contacts = [Select Id,FirstName,LastName,Phone,OwnerId from Contact where Phone IN :clientNums];
        System.debug('Contacts'+contacts);
        List<Lead> leads = [select Id,Name,Phone,OwnerId from Lead where Phone IN :clientNums];
        System.debug('Leads'+leads);
        List<Task> conTask = new List<Task>();
        List<Task> leadTask = new List<Task>();
        
        for(Contact c: contacts)
        {
            Task t = new Task();
            t.Subject = 'Call';
            t.OwnerId = c.OwnerId;  
            conTask.add(t);       
        }
        insert conTask;
        System.debug('Contact Tasks'+conTask);
        
        for(Lead l:leads)
        {
            Task t = new Task();
            t.Subject ='Call';
            t.OwnerId = l.OwnerId;
            leadTask.add(t);
        }
        insert leadTask;
        System.debug('Lead Tasks'+leadTask);
    }  catch (Exception e){
        system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
      HandleBusinessException.captureError('CallyzerAPIHandler', 'processHistory', e , null);
       
    }
}
    
    public Static void saveLead(String recordId)
    {
        try{
        Lead l = [select Id,Name,LastName,Status,Email,Company,Address,City,State,Country,PostalCode,LeadSource,Description,Phone from Lead where Id=:recordId];
        CallyzerLeadWrapper clw = new CallyzerLeadWrapper();
        clw.firstName = l.Name ;
        clw.lastName = l.LastName ;
        clw.xnumber = '';
        clw.assignmentStrategy = '';
        clw.secondaryNumber = '';
        //clw.devices = l.Device__c;
        clw.deviceTags = '';
        clw.status = l.Status;
        clw.email = l.Email;
        clw.companyName = l.Company;
        clw.address1 = String.valueOf(l.Address);
        clw.address2 = String.valueOf(l.Address) ;
        clw.city =l.City;
        clw.state = l.State;
        clw.country = l.Country;
        clw.zip = l.PostalCode ; 
        clw.source = l.LeadSource ;
        clw.description = l.Description;
        clw.leadTags = '';
        clw.leadOption = '';
        clw.assignToOption = '';
        clw.tagOption = '';
        string str = JSON.serialize(CallyzerLeadWrapper.class);
        str = str.replace('xnumber', 'number');
        HttpResponse resp = HTTPUtility.sendRequest('https://api1.callyzer.co/admin/api/lead/save', '924651b1-dd36-4481-b5c4-9294ac873484', str, 'POST');
        
        if(resp.getStatusCode() == 200)
        {
            //   Lead l = new Lead();
            l.SyncedInCallyzer__c = true;
            update l;
        }
    } catch (Exception e){
        system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
      HandleBusinessException.captureError('CallyzerAPIHandler', 'saveLead', e , null);
       
    }
    }    
    public static void getEmployeeId(List<String> userIds,CallyzerEmployeeWrapper s)
    { 
        try{
        List<Callyzer_Sales_User__c> updateCallyzer = new List<Callyzer_Sales_User__c>();
        List<Callyzer_Sales_User__c> InsertCallyzer = new List<Callyzer_Sales_User__c>();
        
        map<string, Callyzer_Sales_User__c> existingcallyzersalesusermap = new map<string, Callyzer_Sales_User__c>();
        
        //  List<Callyzer_Sales_User__c> upsertCallyzerSaleRec = new List<Callyzer_Sales_User__c>();
        List<Callyzer_Sales_User__c> callyzerSalesUserRec = [select Id,Name,callyzerId__c,countryCode__c,deviceName__c,employeeCode__c,mobile__c from Callyzer_Sales_User__c where callyzerId__c =:userIds];
        if(callyzerSalesUserRec.size()>0){
            for(Callyzer_Sales_User__c calRec:callyzerSalesUserRec)
            {
                existingcallyzersalesusermap.put(calRec.callyzerId__c, calRec);
            }
        }
        if(callyzerSalesUserRec.size()>0){ }
        for(CallyzerEmployeeWrapper.employeeWrapper cew:s.data) //wrapper loop
        {
            
            system.debug('cew-->'+cew);
            Callyzer_Sales_User__c csu = new Callyzer_Sales_User__c();
            if(existingcallyzersalesusermap.containsKey(cew.id))
            {
                system.debug('existingcallyzersalesusermap.get(cew.id)-->'+existingcallyzersalesusermap.get(cew.id));
                csu.Id = existingcallyzersalesusermap.get(cew.id).Id;
                csu.mobile__c = cew.mobile;
                csu.countryCode__c = cew.countryCode;
                csu.deviceName__c = cew.deviceName;
                csu.Name = cew.employeeName;
                csu.employeeCode__c = cew.employeeCode ;
                updateCallyzer.add(csu);
                // update updateCallyzer;
            } 
            else
            {
                csu.callyzerId__c = cew.id;
                csu.mobile__c = cew.mobile;
                csu.countryCode__c = cew.countryCode;
                csu.deviceName__c = cew.deviceName;
                csu.Name = cew.employeeName;
                csu.employeeCode__c = cew.employeeCode ;
                InsertCallyzer.add(csu);
                //  insert InsertCallyzer;                
            }
        }
        if(!updateCallyzer.isEmpty())
            update updateCallyzer;
        if(!InsertCallyzer.isEmpty())
            insert InsertCallyzer;
        System.debug('UpdatedCallyzer---'+updateCallyzer);
        System.debug('InsertedCallyzer---'+InsertCallyzer);
    } catch (Exception e){
        system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
      HandleBusinessException.captureError('CallyzerAPIHandler', 'getEmployeeId', e , null);
       
    }
}
    
    //}
}