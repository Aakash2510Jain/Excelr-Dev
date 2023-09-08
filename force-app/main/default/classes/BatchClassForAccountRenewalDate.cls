global class BatchClassForAccountRenewalDate implements database.batchable<Sobject>  {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        //  string queueId =[SELECT Id, Name, DeveloperName, Email, Type FROM Group where Type='Queue' And Name ='Excelr Default Queue' limit 1].id;
           Date dt = System.today().addDays(7);
     System.debug(System.today().addDays(7));   
        return Database.getQueryLocator([SELECT Id,Name,ECAP_Confirm_Date__c,OwnerId FROM Account WHERE  ECAP_Confirm_Date__c != null  AND ECAP_Confirm_Date__c =:dt ]);
    }

    global void execute(Database.BatchableContext bc, List<Account> accList) {
         System.debug('accList----->'+accList);
            Map<Id,List<Account>> accMapList = new Map<ID,List<Account>>();
              List<Account> accountsList ;
            for(Account accRec: accList){       
                 accountsList =   accMapList.get(accRec.OwnerId);
                System.debug('accountsList---->'+accountsList);
                // if(accountsList == null){
                //      accountsList = new List<Account>();
                //      accountsList.add(accRec);
                //      accMapList.put(accRec.OwnerId,accountsList);
                // }
                if(!accMapList.containsKey(accRec.OwnerId)){

                      accMapList.put(accRec.OwnerId,new List<Account>{accRec});
                }else{
                       accMapList.get(accRec.OwnerId).add(accRec);
                }
            }
            System.debug('accMapList--->'+accMapList);
            System.debug('accountsList--->'+accountsList);
             sendEmailToOwnersAccount(accMapList);
           //  sendEmailToOwnersAccount(accMapList.keySet());
    }

    global void finish(Database.BatchableContext bc) {
           system.debug('Batch ran successfully');
    }  
     
    public static void  sendEmailToOwnersAccount(Map<Id,List<Account>> accMapList){
            
             Map<ID, User> userMap = new Map<ID, User>([SELECT ID,LastName,FirstName,Email FROM User]);
             List<Messaging.SingleEmailMessage> semList = new List<Messaging.SingleEmailMessage>(); 
             for(ID keyS:accMapList.keySet()){
                 //  List<Account> accNames = new List<Account>();
                // accNames.add(accMapList.get(keyS));
                 List<String> accNames = new  List<String>(); // accMapList.get(keyS);
                  for(Account acc:  accMapList.get(keyS)){
                       accNames.add(acc.Name);
                  }
                Messaging.SingleEmailMessage mymail = new Messaging.SingleEmailMessage();
                mymail.setToAddresses(new string[]  {userMap.get(keyS).Email} );  
                mymail.setSenderDisplayName('Excelr');
                mymail.setSubject('Account Renewal Remainder');
                mymail.setSaveAsActivity(false);
                mymail.setPlainTextBody('Hello '+userMap.get(keyS).LastName +',' +'\n'+'\n' + 'This Accounts Will be Renewed In 1 week.'+accNames+'\n'+' \n' + 'Thanks & Regards'+'\n' + 'Excelr Team');
               //   mymail.setHtmlBody('Hello'+userMap.get(keyS).LastName +''+' <a href='+URL.getSalesforceBaseUrl().toExternalForm() + '/' + acc.id;">'+acc.Name+'</a> ');
                 semList.add(mymail);
            }
               
           //  }
                     Messaging.sendEmail(semList);

  } 
}