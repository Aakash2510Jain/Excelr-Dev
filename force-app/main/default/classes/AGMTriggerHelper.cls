public without sharing class AGMTriggerHelper{
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
                                    //(newMap.get(agmIdByUserId.get(userId))).addError('Increase Daily Limit');
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
    public void afterInsert(Map<Id,Assignment_Group_Member__c> newMap, Map<Id,Assignment_Group_Member__c> oldMap){
        try{
            Set<Id> assignmentGroupIds = new Set<Id>();
            List<Assignment_Group__c> assignmentGroupList = new List<Assignment_Group__c>();
            List<Assignment_Group_Member__c> assignmentGroupMemberListToUpdate = new List<Assignment_Group_Member__c>();
            
            system.debug('newMap--->> '+newMap);
            system.debug('oldMap--->> '+oldMap);
            
            for(Assignment_Group_Member__c agmRec : newMap.values()){
                if(agmRec.Assignment_Group__c != null)
                    assignmentGroupIds.add(agmRec.Assignment_Group__c);
            }
            if(!assignmentGroupIds.isEmpty()){
                assignmentGroupList = [Select Id,(Select Id,Assignment_Id__c FROM Assignment_Group_Members__r order By Assignment_Id__c ASC nulls last) From Assignment_Group__c where Id in :assignmentGroupIds];
                if(!assignmentGroupList.isEmpty()){
                    system.debug('assignmentGroupList-->'+assignmentGroupList);
                    for(Assignment_Group__c agRec : assignmentGroupList){
                        
                        system.debug('agRec--->'+agRec);
                        integer i = 1;
                        for(Assignment_Group_Member__c agmRec : agRec.Assignment_Group_Members__r){
                            Assignment_Group_Member__c agmrecToUpdate = new Assignment_Group_Member__c();
                            if(agmRec.Assignment_Id__c == null ){
                                agmRec.Assignment_Id__c = 0;
                            }
                            system.debug('agmRec.id--->'+agmRec.id);
                            system.debug('agmRec.Assignment_Id__c--->'+agmRec.Assignment_Id__c);
                            agmrecToUpdate.id = agmRec.id;
                            agmrecToUpdate.Assignment_Id__c = i;
                            system.debug('agmRec.Assignment_Id__c--->'+agmRec.Assignment_Id__c);
                            
                            assignmentGroupMemberListToUpdate.add(agmrecToUpdate);
                            i++;
                        }
                    }
                    system.debug('assignmentGroupMemberListToUpdate---->'+assignmentGroupMemberListToUpdate);
                    if(!assignmentGroupMemberListToUpdate.isEmpty()){
                        update assignmentGroupMemberListToUpdate;
                    }
                }
            }
            
        }catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('AGMTriggerHelper', 'After AGM Insert', e, null);
        }
    }
    public void afterDelete(Map<Id,Assignment_Group_Member__c> oldMap){
        try{
            Set<Id> assignmentGroupIds = new Set<Id>();
            List<Assignment_Group__c> assignmentGroupList = new List<Assignment_Group__c>();
            List<Assignment_Group_Member__c> assignmentGroupMemberListToUpdate = new List<Assignment_Group_Member__c>();
            
            system.debug('oldMap--->> '+oldMap);
            
            for(Assignment_Group_Member__c agmRec : oldMap.values()){
                if(agmRec.Assignment_Group__c != null)
                    assignmentGroupIds.add(agmRec.Assignment_Group__c);
            }
            if(!assignmentGroupIds.isEmpty()){
                assignmentGroupList = [Select Id,(Select Id,Assignment_Id__c FROM Assignment_Group_Members__r order By Assignment_Id__c ASC nulls last) From Assignment_Group__c where Id in :assignmentGroupIds];
                if(!assignmentGroupList.isEmpty()){
                    system.debug('assignmentGroupList-->'+assignmentGroupList);
                    for(Assignment_Group__c agRec : assignmentGroupList){
                        
                        system.debug('agRec--->'+agRec);
                        integer i = 1;
                        for(Assignment_Group_Member__c agmRec : agRec.Assignment_Group_Members__r){
                            Assignment_Group_Member__c agmrecToUpdate = new Assignment_Group_Member__c();
                            if(agmRec.Assignment_Id__c == null ){
                                agmRec.Assignment_Id__c = 0;
                            }
                            system.debug('agmRec.id--->'+agmRec.id);
                            system.debug('agmRec.Assignment_Id__c--->'+agmRec.Assignment_Id__c);
                            agmrecToUpdate.id = agmRec.id;
                            agmrecToUpdate.Assignment_Id__c = i;
                            system.debug('agmRec.Assignment_Id__c--->'+agmRec.Assignment_Id__c);
                            
                            assignmentGroupMemberListToUpdate.add(agmrecToUpdate);
                            i++;
                        }
                    }
                    system.debug('assignmentGroupMemberListToUpdate---->'+assignmentGroupMemberListToUpdate);
                    if(!assignmentGroupMemberListToUpdate.isEmpty()){
                        update assignmentGroupMemberListToUpdate;
                    }
                }
            }
            
        }catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('AGMTriggerHelper', 'After AGM Delete', e, null);
        }
    }
    
    public void reassignAssignmentAfterDeactivation(Map<Id, Assignment_Group_Member__c> agmOldmap , Map<Id, Assignment_Group_Member__c> agmNewmap){
        try{
            system.debug('agmOldmap::'+agmOldmap);
            system.debug('agmNewmap::'+agmNewmap);
            Set<Id> assignmentGroupId = new Set<Id>();
            List<Assignment_Group_Member__c> agmListToBeUpdated = new List<Assignment_Group_Member__c>();
            List<Assignment_Group__c> assignmentGroup = new List<Assignment_Group__c>();
            
            List<Assignment_Group_Member__c> assignmentGroupMemberList = new List<Assignment_Group_Member__c>();
            Map<String, List<Assignment_Group_Member__c>> deactivatedAGMListwithAGId = new Map<String, List<Assignment_Group_Member__c>>();
            Map<String, List<Assignment_Group_Member__c>> ActivatedAGMListwithAGId = new Map<String, List<Assignment_Group_Member__c>>();
            Map<String, List<Assignment_Group_Member__c>> UpdatedAGMListwithAGId = new Map<String, List<Assignment_Group_Member__c>>();
            
            List<Assignment_Group_Member__c> FinalAGMListUpdated = new List<Assignment_Group_Member__c>();
            
            if(!agmNewmap.isEmpty()){
                for(Assignment_Group_Member__c agmRec : agmNewmap.values() ){
                    if ((agmRec.Active__c == false || agmRec.Active__c == true ) && agmrec.Active__c != agmOldmap.get(agmRec.Id).active__c) {
                        assignmentGroupId.add(agmRec.Assignment_Group__c);                   
                    }
                }
                system.debug('assignmentGroupId--->'+assignmentGroupId);
                if(!assignmentGroupId.isEmpty()){
                    assignmentGroupMemberList = [SELECT Active__c,Assignment_Group__c,Assignment_Id__c,BreakTime_Started__c,End_Date__c,Group_Member__c,Id,Name,Out_Of_Office__c 
                                                 FROM Assignment_Group_Member__c Where Assignment_Group__c IN:assignmentGroupId];
                    system.debug('assignmentGroupMemberList-->'+assignmentGroupMemberList);
                    if (!assignmentGroupMemberList.isEmpty()) {
                        for (Assignment_Group_Member__c agmRec : assignmentGroupMemberList) {
                            if (agmRec.Active__c == true) {
                                if (ActivatedAGMListwithAGId.containskey(agmRec.Assignment_Group__c)) {
                                    List<Assignment_Group_Member__c> ExistingAGMlist = ActivatedAGMListwithAGId.get(agmRec.Assignment_Group__c);
                                    ExistingAGMlist.add(agmRec);
                                    ActivatedAGMListwithAGId.put(agmRec.Assignment_Group__c, ExistingAGMlist);
                                }else {
                                    ActivatedAGMListwithAGId.put(agmRec.Assignment_Group__c, new list<Assignment_Group_Member__c>{agmRec});
                                }
                            }
                            if (agmRec.Active__c == false) {
                                if (deactivatedAGMListwithAGId.containskey(agmRec.Assignment_Group__c)) {
                                    List<Assignment_Group_Member__c> ExistingAGMlist = deactivatedAGMListwithAGId.get(agmRec.Assignment_Group__c);
                                    ExistingAGMlist.add(agmRec);
                                    deactivatedAGMListwithAGId.put(agmRec.Assignment_Group__c, ExistingAGMlist);
                                }else {
                                    deactivatedAGMListwithAGId.put(agmRec.Assignment_Group__c, new list<Assignment_Group_Member__c>{agmRec});
                                }
                            }
                        }
                        system.debug('ActivatedAGMListwithAGId--->'+ActivatedAGMListwithAGId);
                        system.debug('deactivatedAGMListwithAGId--->'+deactivatedAGMListwithAGId);
                    }
                    if (!ActivatedAGMListwithAGId.isEmpty()) {
                        for ( String  Str: ActivatedAGMListwithAGId.keyset()) {
                            integer i =1;
                            List<Assignment_Group_Member__c> LocalAGMListTobeUpdated = new List<Assignment_Group_Member__c>();
                            if (!ActivatedAGMListwithAGId.isEmpty()) {
                                for (Assignment_Group_Member__c activeagmRec : ActivatedAGMListwithAGId.get(str)) {
                                    system.debug('i ==>'+i);
                                    Assignment_Group_Member__c agmRecToBeUpdated = new Assignment_Group_Member__c();
                                    agmRecToBeUpdated.id = activeagmRec.Id;
                                    agmRecToBeUpdated.Assignment_Id__c = i;
                                    LocalAGMListTobeUpdated.add(agmRecToBeUpdated);
                                    i++;
                                }                                
                            }
                            system.debug('i ==>'+i);
                            system.debug('LocalAGMListTobeUpdated.size()--->'+LocalAGMListTobeUpdated.size());
                            i = LocalAGMListTobeUpdated.size() + 1;
                            system.debug('i ==>'+i);
                            if (!deactivatedAGMListwithAGId.isEmpty()) {
                                if(deactivatedAGMListwithAGId.ContainsKey(str)){
                                    for (Assignment_Group_Member__c deactiveagmRec : deactivatedAGMListwithAGId.get(str)) {
                                        system.debug('i ==>'+i);
                                        Assignment_Group_Member__c agmRecToBeUpdated = new Assignment_Group_Member__c();
                                        agmRecToBeUpdated.id = deactiveagmRec.Id;
                                        agmRecToBeUpdated.Assignment_Id__c = i;
                                        LocalAGMListTobeUpdated.add(agmRecToBeUpdated);
                                        i++;
                                    } 
                                }
                            }  
                            FinalAGMListUpdated.addAll(LocalAGMListTobeUpdated);
                        } 
                    }
                    if (!FinalAGMListUpdated.isEmpty()) {
                        update FinalAGMListUpdated;
                    }                    
                }
            }
        }
        catch(Exception ex){
            system.debug('Erro>>'+ex.getMessage());
            system.debug('Error@@@'+ex.getLineNumber());
        }
    }
    
    
    Public void  BeforeDelteCheckAGMCheck( Map<Id, Assignment_Group_Member__c> oldAGMmap, Map<Id, Assignment_Group_Member__c> newAGMmap){
        system.debug('oldAGMmap---->'+oldAGMmap);
        system.debug('newAGMmap---->'+newAGMmap);
        
        
        Map<string, integer> assignmentGroupIdByLastAllocatedCount = new  Map<string, integer>();
        List<Assignment_Group__c> agRecToUpdateList  = new List<Assignment_Group__c>();
        for (Assignment_Group_Member__c agmRecord : oldAGMmap.values()) {
            if(agmRecord.Assignment_Id__c == agmRecord.Last_Allocated_RRID__c)
                assignmentGroupIdByLastAllocatedCount.put(agmRecord.Assignment_Group__c, integer.valueOf(agmRecord.Last_Allocated_RRID__c));
        }
        if(!assignmentGroupIdByLastAllocatedCount.isEmpty()){
            for(string agId : assignmentGroupIdByLastAllocatedCount.keySet()){
                Assignment_Group__c agRecToUpdate = new Assignment_Group__c();
                agRecToUpdate.Id = agId;
                agRecToUpdate.Last_Allocated_RRid__c = integer.valueOf(assignmentGroupIdByLastAllocatedCount.get(agId)) - 1;
                agRecToUpdateList.add(agRecToUpdate);
            }
            if(!agRecToUpdateList.isEmpty()){
                update agRecToUpdateList;
            }
        }
    }
}