public without sharing class CallyzerAPICallout 
{

    public static void getUserDetails(String phone,String callStartDate,String callEndDate)
    {
       try{
        Map<String, Object> obj = new Map<String, Object>();
               obj.put('callStartDate', callStartDate);
               obj.put('callEndDate', callEndDate);
               obj.put('employeeNumbers', phone);
               String body = JSON.Serialize(obj);
        HttpResponse response =  HTTPUtility.sendRequest('https://api1.callyzer.co/admin/api/call/callHistory', '924651b1-dd36-4481-b5c4-9294ac873484', body, 'POST');
        String resBody = response.getBody();
        System.debug(resBody);
        resBody = resBody.replace('date', 'xdate');
        resBody = resBody.replace('time', 'xtime');
        
       	CallHistoryWrapper calHislist = (CallHistoryWrapper) JSON.deserialize(resBody, CallHistoryWrapper.class);
        
        List<String> clientNums = new List<String>();
        for(CallHistoryWrapper.HistoryWrapper history : calHislist.data)
        {
             clientNums.add(history.clientNumber);
			 System.debug('HistoryWrapper-----'+history.clientNumber);
            
        }
          CallyzerAPIHandler.processHistory(clientNums);
   
    } catch (Exception e){
        system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
      HandleBusinessException.captureError('CallyzerAPICallout', 'getUserDetails', e , null);
       
    }
}
    
    public Static void saveLead(String recordId)
    {
        try{
        Lead leadRec = [select Id,Name,LastName,Status,Email,Company,Address,City,State,Country,PostalCode,LeadSource,Description,Phone from Lead where Id=:recordId];
         CallyzerLeadWrapper clw = new CallyzerLeadWrapper();
        clw.firstName = leadRec.Name ;
        clw.lastName = leadRec.LastName ;
        clw.xnumber = '';
        clw.assignmentStrategy = '';
        clw.secondaryNumber = '';
        //clw.devices = l.Device__c;
        clw.deviceTags = '';
        clw.status = leadRec.Status;
        clw.email = leadRec.Email;
        clw.companyName = leadRec.Company;
        clw.address1 = String.valueOf(leadRec.Address);
        clw.address2 = String.valueOf(leadRec.Address) ;
        clw.city =leadRec.City;
        clw.state = leadRec.State;
        clw.country = leadRec.Country;
        clw.zip = leadRec.PostalCode ; 
        clw.source = leadRec.LeadSource ;
        clw.description = leadRec.Description;
        clw.leadTags = '';
        clw.leadOption = '';
        clw.assignToOption = '';
        clw.tagOption = '';
        string body = JSON.serialize(CallyzerLeadWrapper.class);
        body = body.replace('xnumber', 'number');
        HttpResponse resp = HTTPUtility.sendRequest('https://api1.callyzer.co/admin/api/lead/save', '924651b1-dd36-4481-b5c4-9294ac873484', body, 'POST');
         
       if(resp.getStatusCode() == 200)
       {
         //   Lead l = new Lead();
            leadRec.SyncedInCallyzer__c = true;
            update leadRec;
        }
    } catch (Exception e){
        system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
      HandleBusinessException.captureError('CallyzerAPICallout', 'saveLead', e , null);
       
    }
    }    
    public static void getEmployeeDetails()
    {
        try{
        String body = '{}';
        HttpResponse response = HTTPUtility.sendRequest('https://api1.callyzer.co/admin/api/employee/manageEmployeeData', '924651b1-dd36-4481-b5c4-9294ac873484', body, 'POST');
        String resBody =  response.getBody();
        System.debug('ResponseBody'+resBody);
       CallyzerEmployeeWrapper s =(CallyzerEmployeeWrapper) JSON.deserialize(resBody, CallyzerEmployeeWrapper.class);
        List<String> userIds = new List<String>();
        List<String> userSalesName  = new List<String>();
        List<String> phoneNum  = new List<String>();
       for(CallyzerEmployeeWrapper.employeeWrapper empWp:s.data)
        {
             userIds.add(empWp.id);
           userSalesName.add(empWp.employeeName);
           phoneNum.add(empWp.mobile);
       }
        System.debug('User Ids'+userIds);
        System.debug('UserSalesName'+userSalesName);
        System.debug('Phone Nums'+phoneNum);
        CallyzerAPIHandler.getEmployeeId(userIds,s);
       
    }
    catch (Exception e){
        system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
      HandleBusinessException.captureError('CallyzerAPICallout', 'getEmployeeDetails', e , null);
       
    }
}
}