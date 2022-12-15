public class ConvertLeadByKajalHandler {
    @AuraEnabled
    public static void convertLeadOnLead(List<Id> LeadIds){
        try{
        LeadStatus cLeadStatus=[Select Id,MasterLabel from LeadStatus where isConverted=true limit 1];
        
        List<Database.LeadConvert> massLeadConvert=new List<Database.LeadConvert>();
        
        for(Id currentLead:LeadIds){
            
            Database.LeadConvert LeadConvert=new Database.LeadConvert();
            
            LeadConvert.setLeadId(currentLead);
            
            LeadConvert.setConvertedStatus(cLeadStatus.MasterLabel);
            
            LeadConvert.setDoNotCreateOpportunity(false);
            
            massLeadConvert.add(LeadConvert);
        }
        
        if(!massLeadConvert.isEmpty()){
            
            List<Database.LeadConvertResult> lcr=Database.convertLead(massLeadConvert);
            
            system.debug('lcr==>'+lcr);
            
        }
             Lead lead = [Select Product__c,Quantity__c,Total_Amount__c,Payment_Initiated_Date_Time__c from Lead LIMIT 1];
        
    }catch(Exception e){
            system.debug('Error' +e.getMessage()+' Line Number' +e.getLineNumber());
    }        
    }
}