public   class CreateAndUpdateTaskOnLeadRecordID {
    public static void  CreateAndUpdateTaskOnLeadRecordID(string jsonstring,  string leadId ) {
        set<String> setobject  = new set<string>();
    // API_GetCallDetailsFromKnowlarity var1 = new API_GetCallDetailsFromKnowlarity();
    // string jsonstring =    var1.fecthCallDetails(leadId);
    System.debug('jsonstring =====> ' + jsonstring);
        Map<string, Object> m = (Map<string, Object>)JSON.deserializeUntyped(jsonstring);
         System.debug('m map-->>' +m);
     
     // Set<id> setLeadid = new Set<id>();
      if(m.containsKey('objects')){
        List<Object> logsList = (List<Object>)m.get('objects');
        System.debug('loglist--->>' +logsList);

        for(Object obj :logsList){
            Map<string, Object> logmap = (Map<string, Object>)obj;
            System.debug('logmap =====> ' + logmap);
         string uuid = string.valueof(logmap.get('uuid'));
         System.debug('uuid--->>>'+uuid);
         setobject.add(uuid);
          
          }
          
      }
     List<task> tasklist = [select id, callobject from task where callobject IN:setobject AND whoid=:leadId ];
      System.debug('tasklist-->>>' +tasklist);
    }
}