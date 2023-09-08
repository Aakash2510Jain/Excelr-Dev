public without sharing class CreateCampaign {
    
    @AuraEnabled
    public static String CreateCampRecord(String leadId, String campainName, String sDateValue , String sTimevalue, String eDateValue, String eTimeValue, String stackholderEmail){
       System.debug('leadId--->'+leadId); //String name
       // System.debug('startDateTime--->'+startDateTime); // Datetime startDateTime,
       System.debug('campainName--->'+campainName);
       System.debug('sDateValue--->'+sDateValue);
       System.debug('sTimevalue--->'+sTimevalue);
       System.debug('eDateValue--->'+eDateValue);
       System.debug('eTimeValue--->'+eTimeValue);

       //     List<String> emailList =  splitEmails(stackholderEmail);
      // system.debug('emailList0------>'+emailList);
      
       // System.debug('name--->'+name);
        System.debug('stackholderEmail--->'+stackholderEmail);
       
       String[] strTimeSplit = sTimevalue.split(':');
       Time timeChange = Time.newInstance( Integer.valueOf(strTimeSplit[0]) //hour
                                     ,Integer.valueOf(strTimeSplit[1]) //min
                                     ,0                                //sec
                                     ,0);
      System.debug('strTimeSplit--->'+strTimeSplit);
       System.debug('timeChange--->'+timeChange);

      String[] strTimeSplit2 = eTimeValue.split(':');
      Time timeChange2 = Time.newInstance( Integer.valueOf(strTimeSplit2[0]) //hour
                                     ,Integer.valueOf(strTimeSplit2[1]) //min
                                     ,0                                //sec
                                     ,0);
      System.debug('strTimeSplit2--->'+strTimeSplit2);
       System.debug('timeChange2--->'+timeChange2);
        
        String message ;
     //   List<Campaign> campaignList = new List<Campaign>();
        // && name != null  && startDateTime != null
        if(leadId != null ){
            List<Lead> leadList = [select Id, Name,Company from Lead where Id =:leadId];
            try{
                /*List<Campaign> existingCampaigns = [SELECT Id, Start_Time__c FROM Campaign WHERE Start_Time__c =: startDateTime];
                if(existingCampaigns.size() > 0){
                    message = 'exists';
                }
                else if(existingCampaigns.size() == 0){ */
                    Campaign campRec = new Campaign();
                    //; //+' '+ name;
                    //campRec.Start_Date_Time__c = startDateTime ;
                     // StartDate  Start_Time__c
                    //     campRec.StartDate =  dateValue ;
                    //   campRec.Start_Time__c = timevalue ;
                     //    campRec.EndDate = '';
                     //     campRec.End_Time__c = '';
                   // campRec.End_Date_Time__c = endDateTime;

                     //campRec.Name  = 'testing 1';
                      campRec.Name = campainName;
                     campRec.StartDate = Date.valueOf(sDateValue) ;
                     campRec.Start_Time__c = timeChange;
                     campRec.EndDate = Date.valueOf(eDateValue);
                     campRec.End_Time__c = timeChange2;
                     campRec.Stake_Holders_Emails__c = stackholderEmail;
                     if(leadId.startsWith('00Q')){
                        campRec.Lead__c = leadId;
                     }else{
                        campRec.Account__c = leadId;
                     }
                     campRec.IsActive = true;

                //    campaignList.add(campRec.StartDate,campRec.Start_Time__c, campRec.EndDate, campRec.End_Time__c);

                    Insert campRec;           
                    message = 'SUCCESS';
                    if(campRec.Id != null){
                    GMeetAPIHandler.sendEmailsTobookCalender(campRec.Id);
                    }
                // }
            }
            catch(Exception e){
                System.debug('Exception Line Number---->'+e.getLineNumber());
                System.debug('Exception Message---->'+e.getMessage());
                message = e.getMessage();
            }
        }
        return message;
    }

    public static  List<String> splitEmails(String emails){
            String additionalEmails = emails;
            List<String> emailTestString = new  List<String>();
                for (String email : additionalEmails.split(',')) {
                    system.debug('email---->'+email);
                    String trimmed = email.trim();
                    if (trimmed.length() > 0) {
                        emailTestString.add(trimmed);
                }
                }
            system.debug('emailTestString---->'+emailTestString);
            return emailTestString;
    }
}