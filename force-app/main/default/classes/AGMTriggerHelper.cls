public class AGMTriggerHelper{
    static AGMTriggerHelper handlerInstance;
    
    public static AGMTriggerHelper getInstance(){
        if (handlerInstance == null)
            handlerInstance = new AGMTriggerHelper();
        return handlerInstance;
    }
    
    public void beforeUpdate(Map<Id, Assignment_Group_Member__c> newMap, Map<Id, Assignment_Group_Member__c> oldMap){
        try{
            set<Id> agmUserIds = new Set<Id>();
            List<Assignment_Group_Member__c> agmList = new List<Assignment_Group_Member__c>();
            Map<Id, Decimal> monthlyCapByUserId = new Map<Id, Decimal>();
            Map<Id, Decimal> actuallyMonthlyCapByUserId = new Map<Id, Decimal>();
            Map<Id, Id> agmIdByUserId = new Map<Id, Id>();
            Map<Id, decimal> maxLeadCapByAGMId = new Map<Id, decimal>();
            
            for (Assignment_Group_Member__c agmRec : newMap.values()){
                if (agmRec.Max_Lead_Per_Day__c != oldMap.get(agmRec.Id).Max_Lead_Per_Day__c){
                    agmUserIds.add(agmRec.Group_Member__c);
                    agmIdByUserId.put(agmRec.Group_Member__c, agmRec.Id);
                    maxLeadCapByAGMId.put(agmRec.Id, agmRec.Max_Lead_Per_Day__c);
                }
            }
            if (!agmUserIds.isEmpty()){
                agmList = [Select Id, Group_Member__c, Group_Member__r.Max_Lead_Per_Month__c, Max_Lead_Per_Day__c
                           From Assignment_Group_Member__c
                           where Group_Member__c in:agmUserIds];
                if (!agmList.isEmpty()){
                    for (Assignment_Group_Member__c agmRec : agmList){
                        actuallyMonthlyCapByUserId.put(agmRec.Group_Member__c, agmRec.Group_Member__r.Max_Lead_Per_Month__c);
                        if(maxLeadCapByAGMId.containsKey(agmRec.Id)){
                            if (monthlyCapByUserId.containsKey(agmRec.Group_Member__c)){
                                decimal userCap = monthlyCapByUserId.get(agmRec.Group_Member__c) + maxLeadCapByAGMId.get(agmRec.Id);
                                monthlyCapByUserId.put(agmRec.Group_Member__c, userCap);
                            } else{
                                monthlyCapByUserId.put(agmRec.Group_Member__c,  maxLeadCapByAGMId.get(agmRec.Id));
                            }
                        }else{
                            if (monthlyCapByUserId.containsKey(agmRec.Group_Member__c)){
                                decimal userCap = monthlyCapByUserId.get(agmRec.Group_Member__c) + agmRec.Max_Lead_Per_Day__c;
                                monthlyCapByUserId.put(agmRec.Group_Member__c, userCap);
                            } else{
                                monthlyCapByUserId.put(agmRec.Group_Member__c, agmRec.Max_Lead_Per_Day__c);
                            }
                        }
                    }
                    if (!actuallyMonthlyCapByUserId.isEmpty()){
                        for (Id userId : actuallyMonthlyCapByUserId.keyset()){
                            if (monthlyCapByUserId.containsKey(userId)){
                                
                                system.debug('actuallyMonthlyCapByUserId.get(userId)--->'+actuallyMonthlyCapByUserId.get(userId));
                                system.debug('monthlyCapByUserId.get(userId) * 30)--->'+monthlyCapByUserId.get(userId) * 30);
                                
                                if (actuallyMonthlyCapByUserId.get(userId) == (monthlyCapByUserId.get(userId) * 30)){
                                    
                                } else if (actuallyMonthlyCapByUserId.get(userId) < (monthlyCapByUserId.get(userId) * 30)){
                                    //add error to decrease daily agm limit
                                    (newMap.get(agmIdByUserId.get(userId))).addError('Decrease Daily Limit');
                                } else{
                                    //add error to Increase daily agm limit
                                    (newMap.get(agmIdByUserId.get(userId))).addError('Increase Daily Limit');
                                }
                            }
                        }
                    }
                }
            }
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('AGMTriggerHelper', 'Before AGM Update', e, null);
        }
    }
    
}