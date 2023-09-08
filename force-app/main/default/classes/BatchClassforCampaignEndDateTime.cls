global  class BatchClassforCampaignEndDateTime implements database.batchable<Sobject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {
         //End_Date_Time__c
        return Database.getQueryLocator([SELECT Id, Name,EndDate,Lead__c,Status FROM Campaign WHERE Status !='Completed'AND  EndDate != null AND EndDate = TODAY ] );
    }

    global void execute(Database.BatchableContext bc, List<Campaign> campList) { 
        System.debug('campList----->'+campList);
        List<Campaign> updateCampList = new List<Campaign>();
        if(!campList.isEmpty()){ 
                
                for(Campaign campRec : campList){

                    campRec.Status = 'Completed';
                    updateCampList.add(campRec);
                }
                    update updateCampList;
        }
    }

    global void finish(Database.BatchableContext bc){

        system.debug('Batch ran successfully');
    }

}