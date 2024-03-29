public without sharing class GMeetAPIHandler {
    private static final String GOOGLECALENDARENDPOINT = 'https://www.googleapis.com/calendar/v3';
    
    
    @future(callout=true)
    public static void sendEmailsTobookCalender(String campRecId){
     try{
       
     //Campaign campRec = [select Id,StartDate,Start_Time__c,EndDate,End_Time__c from Campaign where Id =:campRecId];
     List<Map<String,String>> emailMapList = new List<Map<String,String>>();
            
            
            
          //  Booked_Slot__c bs = [Select Id,Name,Date__c,OwnerId,Start_Time__c,End_Time__c,Email__c,Owner.Email From Booked_Slot__c Where Id=:bId];
            Campaign bs = [select Id, Name,StartDate,Start_Time__c,EndDate,End_Time__c,Stake_Holders_Emails__c,OwnerId,Owner.Email from Campaign where Id =:campRecId];
            
            String Organiser = 'Umesh@excelr.com';
         //   Booked_Slot__c updatedbs = new Booked_Slot__c();
          //  updatedbs.id = bId;
          system.debug('bs.Stake_Holders_Emails__c--->'+bs.Stake_Holders_Emails__c);
            if(bs.Stake_Holders_Emails__c.contains(',')){

                List<String> emList =  bs.Stake_Holders_Emails__c.split(',');
                system.debug('emList---->'+emList);
                for(string em:emList){
                    Map<String,String> emailMap = new Map<String,String>();
                    system.debug('em-->'+em);
                     emailMap.put('email', em);
                    emailMapList.add(emailMap);
                }         
            }else{
                Map<String,String> emailMap = new Map<String,String>();
                emailMap.put('email', bs.Stake_Holders_Emails__c);
                emailMapList.add(emailMap);
            }
                //System.debug('emailMap--->'+emailMap);
                 System.debug('emailMapList--->'+emailMapList);
           // emailMap.put('email', bs.Stake_Holders_Emails__c);
           // emailMapList.add(emailMap);
            
            String accessToken = GMeetAuthHandler.getAccessToken(bs.Owner.Email);
            system.debug('accessToken--->'+accessToken);
            //=============== for dateTime ========================================
            //time starttime = createTime(bs.Start_Time__c);
            datetime StartDatetime = Datetime.newInstance(bs.StartDate,(bs.Start_Time__c));
           // StartDatetime = StartDatetime //.addMinutes(-330);
            System.debug('StartDatetime =======> ' + StartDatetime);
            System.debug('StartDatetime serialize =======> ' + JSON.serialize(StartDatetime));
            
            datetime EndDateTime = Datetime.newInstance(bs.EndDate,(bs.End_Time__c));
          //  EndDateTime = EndDateTime //.addMinutes(-330);
            System.debug('EndDateTime =======> ' + EndDateTime);
            System.debug('EndDateTime  serialized =======> ' + JSON.serialize(EndDateTime));
            
            String endPoint = '/calendars/'+Organiser+'/events?conferenceDataVersion=1&maxAttendees=5&sendNotifications=true&sendUpdates=all&supportsAttachments=true';
            
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            
            req.setEndpoint(GOOGLECALENDARENDPOINT+endPoint);
            req.setHeader('content-type', 'application/json');
            req.setHeader('Authorization', 'Bearer ' + accessToken);
            
            string updatedBody = '{"summary":' + JSON.serialize(bs.Name) + ',"end": {"dateTime": ' + JSON.serialize(EndDateTime) + ',"timeZone": "Asia/Kolkata"},"start": {"dateTime": ' + JSON.serialize(StartDatetime) + ',"timeZone": "Asia/Kolkata"},"conferenceData": {"createRequest": {"conferenceSolutionKey": {"type": "hangoutsMeet"},"requestId": "test"}},"attendees":'+JSON.serialize(emailMapList)+'}';
            System.debug('updatedBody =======> ' + updatedBody);
            req.setBody(updatedBody);
            req.setHeader('Content-length', String.valueOf(updatedBody.length()));
            req.setTimeout(60 * 1000);
            HttpResponse resp = http.send(req);
            
            System.debug('Response---->>'+resp.getBody());
            
            if(resp.getStatusCode()==200||resp.getStatusCode()==201){
                Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(resp.getBody());
                if (m.get('hangoutLink') != null) {
                     bs.URL__c = m.get('hangoutLink').toString();
                    system.debug(' bs.URL__c ------>'+ bs.URL__c);
                }
            }
            
          //  update updatedbs;
            
            
            Task inv_task = new Task();
            inv_task.OwnerId = bs.OwnerId;
            inv_task.Subject ='Meeting with '+bs.Name;  
            inv_task.Status = 'Not Started';
            inv_task.Priority = 'High';
            inv_task.WhatId   =  campRecId;   //bId;
            inv_task.IsReminderSet = true;
            inv_task.ReminderDateTime = StartDatetime.addhours(-1);
            inv_task.ActivityDate = date.newinstance(StartDatetime.year(), StartDatetime.month(), StartDatetime.day());
            insert inv_task;


     }catch(Exception e){
       system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
     }
    
    
    
    
    }




    @future(callout=true)
    public static void generateMeetLink_V2(String bId){
        try{
            
            List<Map<String,String>> emailMapList = new List<Map<String,String>>();
            Map<String,String> emailMap = new Map<String,String>();
            
            
            Booked_Slot__c bs = [Select Id,Name,Date__c,OwnerId,Start_Time__c,End_Time__c,Email__c,Owner.Email From Booked_Slot__c Where Id=:bId];
            
            String Organiser = 'Umesh@excelr.com';
            Booked_Slot__c updatedbs = new Booked_Slot__c();
            updatedbs.id = bId;
            emailMap.put('email', bs.Email__c);
            emailMapList.add(emailMap);
            
            String accessToken = GMeetAuthHandler.getAccessToken(bs.Owner.Email);
            system.debug('accessToken--->'+accessToken);
            //=============== for dateTime ========================================
            //time starttime = createTime(bs.Start_Time__c);
            datetime StartDatetime = Datetime.newInstance(bs.Date__c,(bs.Start_Time__c));
            StartDatetime = StartDatetime.addMinutes(-330);
            System.debug('StartDatetime =======> ' + StartDatetime);
            System.debug('StartDatetime serialize =======> ' + JSON.serialize(StartDatetime));
            
            datetime EndDateTime = Datetime.newInstance(bs.Date__c,(bs.End_Time__c));
            EndDateTime = EndDateTime.addMinutes(-330);
            System.debug('EndDateTime =======> ' + EndDateTime);
            System.debug('EndDateTime  serialized =======> ' + JSON.serialize(EndDateTime));
            
            String endPoint = '/calendars/'+Organiser+'/events?conferenceDataVersion=1&maxAttendees=5&sendNotifications=true&sendUpdates=all&supportsAttachments=true';
            
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            
            req.setEndpoint(GOOGLECALENDARENDPOINT+endPoint);
            req.setHeader('content-type', 'application/json');
            req.setHeader('Authorization', 'Bearer ' + accessToken);
            
            string updatedBody = '{"summary":' + JSON.serialize(bs.Name) + ',"end": {"dateTime": ' + JSON.serialize(EndDateTime) + ',"timeZone": "Asia/Kolkata"},"start": {"dateTime": ' + JSON.serialize(StartDatetime) + ',"timeZone": "Asia/Kolkata"},"conferenceData": {"createRequest": {"conferenceSolutionKey": {"type": "hangoutsMeet"},"requestId": "test"}},"attendees":'+JSON.serialize(emailMapList)+'}';
            System.debug('updatedBody =======> ' + updatedBody);
            req.setBody(updatedBody);
            req.setHeader('Content-length', String.valueOf(updatedBody.length()));
            req.setTimeout(60 * 1000);
            HttpResponse resp = http.send(req);
            
            System.debug('Response----'+resp.getBody());
            
            if(resp.getStatusCode()==200||resp.getStatusCode()==201){
                Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(resp.getBody());
                if (m.get('hangoutLink') != null) {
                    updatedbs.Meeting_Link__c = m.get('hangoutLink').toString();
                }
            }
            
            update updatedbs;
            
            
            Task inv_task = new Task();
            inv_task.OwnerId = bs.OwnerId;
            inv_task.Subject ='Meeting with '+bs.Name;  
            inv_task.Status = 'Not Started';
            inv_task.Priority = 'High';
            inv_task.WhatId   = bId;
            inv_task.IsReminderSet = true;
            inv_task.ReminderDateTime = StartDatetime.addhours(-1);
            inv_task.ActivityDate = date.newinstance(StartDatetime.year(), StartDatetime.month(), StartDatetime.day());
            insert inv_task;
            
            
            
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('GMeetAPIHandler', 'generateMeetLink_V2', e , null);
            
        }
    }
}