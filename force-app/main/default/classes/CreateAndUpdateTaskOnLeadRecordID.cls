public   class CreateAndUpdateTaskOnLeadRecordID {
    public static void  CreateAndUpdateTaskOnLeadRecordID(string jsonstring,  string leadId ) {
        
    // API_GetCallDetailsFromKnowlarity var1 = new API_GetCallDetailsFromKnowlarity();
    // string jsonstring =    var1.fecthCallDetails(leadId);
    System.debug('jsonstring =====> ' + jsonstring);
        Map<string, Object> m = (Map<string, Object>)JSON.deserializeUntyped(jsonstring);
         System.debug('m map-->>' +m);
        
 

    }
}