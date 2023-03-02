public without Sharing class BuildMaps {
    /*Condition Map*/
    public static map<string,integer> mapofMemIdByExceedCount = new map<string,integer>();
    public static map<string,Integer> mapofMemidByTodayLeadCount = new map<string,integer>();
    public static map<string,Integer> mapofMemIdByMaxLeadCountPerDay = new map<string,integer>();
    public static map<string,Integer> mapofMemIdByMaxLeadCountByGroupPerDay = new map<String,integer>();
    public static map<string,Integer> mapofMemidbyMaxleadCountFromUser = new map<string,integer>();
    public static map<string,Integer> mapofMemidByPendingLeads = new map<string,integer>();
    public static map<string,Integer> mapofMemidByMinLeadsCount = new map<string,integer>();
    public static map<string,integer> mapofMemidByTodayNewLead = new map<string,integer>();
    public static map<string,integer> mapofMemidByAssignedLead = new map<string,integer>();
    public static map<string,integer> mapofMemidByMaxLeadPerMonthFromUser = new map<string,integer>();
    public static map<string,integer> mapofMemidByMaxLeadPerDayFromAG = new map<string,integer>();
    public static map<string, integer> mapofMemidByLeadAssignedThisMonth = new map<string, integer>();
    public static map<string, integer> mapofMemidByLeadsAssignedInThisTransaction = new map<string, integer>();
    public static map<string, Integer> mapofMemidByLeadsToAssignInSIngleShot = new map<string, integer>();
    
    /* Condition map end*/
    
    public static boolean CheckBusinessHours(){
        try{
            Datetime toBeChecked =  System.now();
            BusinessHours hours = [SELECT ID,TimeZoneSidKey FROM BusinessHours WHERE IsDefault=true];
            Datetime targetTime = Datetime.newInstance(toBeChecked.year(), toBeChecked.month(), toBeChecked.day(), toBeChecked.hour(), toBeChecked.minute(), toBeChecked.second());
            
            
            if(BusinessHours.isWithin(hours.id,targetTime)){
                system.debug('inside ');
                return true;
            }
            return false;
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('BuildMaps', 'CheckBusinessHours', e , null);
            return null;
        }
    }
    
    public static Map<String, Integer> makeQNameToLastAssignedQmemberRRid(){
        try{
            Map<String, Integer> qNameToLastAssignedQmemberRRid = new Map<String, Integer>();
            List<Assignment_Group__c> allExistingQueue = new List<Assignment_Group__c>([SELECT id, name, Last_Allocated_RRid__c from Assignment_Group__c]);
            for(Assignment_Group__c q: allExistingQueue)
            {
                if(q.Last_Allocated_RRid__c != null)
                {
                    qNameToLastAssignedQmemberRRid.put(q.name, Integer.valueOf(q.Last_Allocated_RRid__c));    
                }
                else 
                    qNameToLastAssignedQmemberRRid.put(q.name, null);
            }
            return qNameToLastAssignedQmemberRRid;
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('BuildMaps', 'makeQNameToLastAssignedQmemberRRid', e , null);
            return null;
        }
    }
    
    public static void validateUserCapacity(String groupName,set<String> leadIdList){
        try{
            system.debug('groupName::'+groupName);
            list<Assignment_Group_Member__c> listOfGroupMember = new list<Assignment_Group_Member__c>();
            list<lead> listOfTodayLeads = new list<lead>();
            list<lead> listOfNewLeads = new list<lead>();
            list<lead> listOfAssignedTodayLeads = new list<lead>();
            list<lead> listOfAssignedThisMonth = new list<lead>();
            
            listOfGroupMember = [select id,Max_Lead_Per_Day__c,Assignment_Group__r.Minimum_Lead_Volume__c,Assignment_Group__r.Name,Group_Member__r.Id,Group_Member__r.Max_Lead_Per_Month__c,Group_Member__r.Max_Lead_Per_Day__c,Assignment_Group__r.Max_Lead_Per_Day__c,Assignment_Group__r.Lead_Stage__c,Assignment_Group__r.Lead_Stage_Exceed_Count__c from Assignment_Group_Member__c where active__c = true and assignment_group__r.name =: groupName];
            listOfTodayLeads = [select id,Lead_Assigned_Date__c,ownerId,status from lead where Lead_Assigned_Date__c = today];
            listOfNewLeads = [select id,Lead_Assigned_Date__c,ownerId,status from lead where status = 'Open'];
            listOfAssignedTodayLeads = [select id,Lead_Assigned_Date__c,ownerId,status from lead where Lead_Assigned_Date__c = today];
            listOfAssignedThisMonth = [select id, Lead_Assigned_Date__c, ownerId, status from lead where Lead_Assigned_Date__c = This_Month];
            
            if(!listOfNewLeads.isEmpty()){
                for(lead ld : listOfNewLeads){
                    if(mapofMemidByPendingLeads.containsKey(ld.OwnerId)){
                        integer count = mapofMemidByPendingLeads.get(ld.OwnerId);
                        mapofMemidByPendingLeads.put(ld.OwnerId,count + 1);
                    }else{
                        mapofMemidByPendingLeads.put(ld.OwnerId,1);
                    } 
                }
            }
            for(Assignment_Group_Member__c agm : listOfGroupMember){
                mapofMemIdByExceedCount.put(agm.Group_Member__r.Id,Integer.valueOf(agm.Assignment_Group__r.Lead_Stage_Exceed_Count__c));
                mapofMemIdByMaxLeadCountPerDay.put(agm.Group_Member__r.Id,Integer.valueOf(agm.Max_Lead_Per_Day__c));
                mapofMemIdByMaxLeadCountByGroupPerDay.put(agm.Group_Member__r.Id,Integer.valueOf(agm.Max_Lead_Per_Day__c));
                mapofMemidbyMaxleadCountFromUser.put(agm.Group_Member__r.Id,Integer.valueOf(agm.Group_Member__r.Max_Lead_Per_Day__c));
                mapofMemidByMinLeadsCount.put(agm.Group_Member__r.Id,Integer.valueOf(agm.Assignment_Group__r.Minimum_Lead_Volume__c));
                mapofMemidByMaxLeadPerMonthFromUser.put(agm.Group_Member__r.Id,Integer.valueOf(agm.Group_Member__r.Max_Lead_Per_Month__c));
                mapofMemidByMaxLeadPerDayFromAG.put(agm.Group_Member__r.Id,Integer.valueOf(agm.Group_Member__r.Max_Lead_Per_Day__c));
                mapofMemidByLeadsToAssignInSIngleShot.put(agm.Group_Member__r.Id, Integer.valueOf(agm.Assignment_Group__r.Minimum_Lead_Volume__c));
            }
            
            if(!listOfAssignedTodayLeads.isEmpty()){
                for(lead ld : listOfAssignedTodayLeads){
                    if(mapofMemidByAssignedLead.containsKey(ld.ownerId)){
                        integer count = mapofMemidByAssignedLead.get(ld.ownerId);
                        mapofMemidByAssignedLead.put(ld.ownerId,count + 1);
                    }else{
                        mapofMemidByAssignedLead.put(ld.ownerId,1);
                    }
                }
            }
            
            for(lead ld : listOfTodayLeads){
                if(mapofMemidByTodayLeadCount.containsKey(ld.ownerId)){
                    integer count = mapofMemidByTodayLeadCount.get(ld.ownerId);
                    mapofMemidByTodayLeadCount.put(ld.ownerId,count + 1);
                }else{
                    mapofMemidByTodayLeadCount.put(ld.ownerId,1);
                }
                if(ld.status == 'New'){
                    if(mapofMemidByTodayNewLead.containsKey(ld.ownerId)){
                        integer count = mapofMemidByTodayNewLead.get(ld.ownerId);
                        mapofMemidByTodayNewLead.put(ld.ownerId,count+1);
                    }else{
                        mapofMemidByTodayNewLead.put(ld.ownerId,1);
                    }
                }
            }
            if (!listOfAssignedThisMonth.isEmpty()){
                for (Lead ld : listOfAssignedThisMonth){
                    if (mapofMemidByLeadAssignedThisMonth.containsKey(ld.OwnerId)){
                        integer count = mapofMemidByLeadAssignedThisMonth.get(ld.ownerId);
                        mapofMemidByLeadAssignedThisMonth.put(ld.ownerId, count + 1);
                    } else{
                        mapofMemidByLeadAssignedThisMonth.put(ld.ownerId, 1);
                        if(ld.status == 'New'){
                            if(mapofMemidByTodayNewLead.containsKey(ld.ownerId)){
                                integer count = mapofMemidByTodayNewLead.get(ld.ownerId);
                                mapofMemidByTodayNewLead.put(ld.ownerId,count+1);
                            }else{
                                mapofMemidByTodayNewLead.put(ld.ownerId,1);
                            }
                        }
                    }
                }
            }
            
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('BuildMaps', 'validateUserCapacity', e , null);
            
        }
    }
    
    public static void makeAllMemberOOF(){
        try{
            list<Assignment_Group_Member__c> agmList = new list<Assignment_Group_Member__c>();
            agmList = [select id,Out_Of_Office__c from Assignment_Group_Member__c where active__c = true and Out_Of_Office__c = false];
            if(!agmList.isEmpty()){
                for(Assignment_Group_Member__c agm : agmList){
                    agm.Out_Of_Office__c = true; 
                }
                
                update agmList;
            }
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('BuildMaps', 'makeAllMemberOOF', e , null);
            
        }
    }
}