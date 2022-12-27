public class CallyzerAPICallout 
{

    public static void getUserDetails(String phone,String callStartDate,String callEndDate)
    {
       
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
   
    }
    
    public Static void saveLead(String recordId)
    {
        Lead l = [select Id,Name,Phone from Lead where Id=:recordId];
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
        clw.source = l.UTM_Source__c ;
        clw.description = l.Description;
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
            l.SyncedInCallyzer__c = true;
            update l;
        }
    }    
}