public class CallyzerAPIHandler
{
    public Static void processHistory(List<String> clientNums)
    {
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
        string str = JSON.serialize(CallyzerLeadWrapper.class);
        str = str.replace('xnumber', 'number');
        HttpResponse resp = HTTPUtility.sendRequest('https://api1.callyzer.co/admin/api/lead/save', '924651b1-dd36-4481-b5c4-9294ac873484', str, 'POST');
         
       if(resp.getStatusCode() == 200)
       {
         //   Lead l = new Lead();
            l.SyncedInCallyzer__c = true;
            update l;
        }
    }    
}