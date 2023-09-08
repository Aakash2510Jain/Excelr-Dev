global without sharing class BatchClassforCampaignStartDateTime implements database.batchable<Sobject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        Datetime currentTime = Datetime.now();
        String formattedTime = currentTime.format('h:mm a');
        System.debug('Current time in AM/PM format: ' + formattedTime);


        return Database.getQueryLocator([SELECT Id, Name,Start_Time__c,StartDate,  Lead__c,Lead__r.Status FROM Campaign WHERE Lead__c !=null AND Lead__r.Status !='Event Conducted' AND   StartDate = TODAY  ] );
    }

    global void execute(Database.BatchableContext bc, List<Campaign> campList) { 
      System.debug('campList----->'+campList);
        if(!campList.isEmpty()){ 
                   System.debug('INSIDE COND----->'+campList);
            set<ID> leadIdList = new set<ID>();
            List<Campaign> updateCampaignList = new List<Campaign>();
            for(Campaign campRec :campList){
                
                campRec.Status = 'In Progress';
                leadIdList.add(campRec.Lead__c);
                updateCampaignList.add(campRec);

            }

            List<Lead> leadList = [SELECT ID, Name, Status FROM Lead where Id IN :leadIdList];
            List<Lead> updateLeadList = new List<Lead>();

        for(Lead leadRec:leadList){
              
              leadRec.Status = 'Event Conducted';
              updateLeadList.add(leadRec);

        }
               update updateCampaignList;
               update updateLeadList ;
            //  if(updateLeadList != null){
           
            //  }
             System.debug('updateLeadList---->'+updateLeadList);
        }     
    }

    global void finish(Database.BatchableContext bc) {

        system.debug('Batch ran successfully');
    }

}