global class BatchClassForCampMemRegistrationCount implements database.batchable<Sobject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {
      
        Excelr_Configuration__c cusSettingRec = [SELECT id,Minimum_Registration_Count__c, Name FROM Excelr_Configuration__c];
        System.debug('cusSettingRec--->'+cusSettingRec.Minimum_Registration_Count__c);
        return Database.getQueryLocator([SELECT Id, Name,Lead__c,Lead__r.OwnerId,Status,Total_Campaign_Members__c FROM Campaign WHERE Total_Campaign_Members__c !=null AND Lead__c ='00QN000000Bbk4OMAR' AND Total_Campaign_Members__c <:cusSettingRec.Minimum_Registration_Count__c  /*Name ='Test Seminar' AND Total_Campaign_Members__c !=null AND Name ='Satyam test'  LIMIT 1*/ ] );
    }

    global void execute(Database.BatchableContext bc, List<Campaign> campList) { 
    
        Integer Count = 0;
        Map<Id,List<Campaign>> campMapList = new  Map<Id,List<Campaign>>();
        set<Id> campIds = new Set<ID>();

        for(Campaign cmp:campList){
            if(campMapList.containsKey(cmp.Lead__r.OwnerId)){
                  

                   campMapList.get(cmp.Lead__r.OwnerId).add(cmp);
            }
            else{
                  campMapList.put(cmp.Lead__r.OwnerId, new List<Campaign> {cmp});
             }
        }
             system.debug('campMapList--keyset-->'+campMapList.keySet());
             system.debug('GET Values--->'+campMapList.values());
               if(campMapList != null){
                       sendEmailToLeadOwner(campMapList);
               }
           
     }

    global void finish(Database.BatchableContext bc){

        system.debug('Batch ran successfully');
    }

     public static void  sendEmailToLeadOwner(Map<Id,List<Campaign>> campMapList ){ //    accMapList
           System.debug('campMapList----->'+campMapList);
            
             Map<ID, User> userMap = new Map<ID, User>([SELECT ID,LastName,FirstName,Email FROM User]);
            
             List<Messaging.SingleEmailMessage> semList = new List<Messaging.SingleEmailMessage>(); 
             //Custom setting
             Excelr_Configuration__c cusSettingRec = [SELECT id,Minimum_Registration_Count__c, Name FROM Excelr_Configuration__c];
             System.debug('cusSettingRec--->'+cusSettingRec.Minimum_Registration_Count__c);
             String result ='';
             
             for(ID keyS :campMapList.keySet()){
                 
                 System.debug('First For Loop----->');
                    Messaging.SingleEmailMessage mymail = new Messaging.SingleEmailMessage();
                    mymail.setToAddresses(new string[]  {userMap.get(keyS).Email} );  
                    mymail.setSenderDisplayName('Excelr');
                    mymail.setSubject('Account Renewal Remainder');
                    mymail.setSaveAsActivity(false);
                 
                 for(Campaign campRec:campMapList.get(keyS)){
                     
                             System.debug('Second For Loop----->');
                             Integer campRegCount  =     (integer)campRec.Total_Campaign_Members__c;
                             System.debug('campRegCount---->'+campRegCount);
                          //  if(campRegCount < cusSettingRec.Minimum_Registration_Count__c ){
                          // System.debug('Checking Condition----->');
                          // String  email = userMap.get(keyS).Email;
                             String name = campRec.Name ;
                             System.debug('name---->'+name);
                             Integer totalcount = (Integer) campRec.Total_Campaign_Members__c;
                             System.debug('name---->'+totalcount);
                             result +='\n'+ campRec.Name +' '+totalcount +'\n';
                             system.debug('result inside loop---->'+result);
                    //  }
                    
                       system.debug('Final result---->'+result);
                    //  mymail.setPlainTextBody('Hello '+userMap.get(keyS).LastName +',' +'\n'+'\n' + 'Registration Count For this Month.'+ result+'\n'+' \n' + 'Thanks & Regards'+'\n' + 'Excelr Team');
                    //  semList.add(mymail);         
                 }
                    mymail.setPlainTextBody('Hello '+userMap.get(keyS).LastName +',' +'\n'+'\n' + 'Registration Count For this Month.'+ result+'\n'+' \n' + 'Thanks & Regards'+'\n' + 'Excelr Team');
                     semList.add(mymail); 
             }            
                      Messaging.sendEmail(semList); 

  } 

}