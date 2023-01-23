public class LeadTriggerHelper {
    public static void handleStateAndCountry(){
        Map<String, String> mapOfStateByCity = new Map<String, String>();
        Map<String, String> mapOfCountryByCity = new Map<String, String>();
        
        //Custom Setting
        List<City_State_Country__c> cityStateCountryList = [ Select City__c,Country__c,State__c From City_State_Country__c];
        
        if(!cityStateCountryList.isEmpty()){
            for(City_State_Country__c CSC_Rec : cityStateCountryList){
                mapOfStateByCity.put(CSC_Rec.City__c, CSC_Rec.State__c);
                mapOfCountryByCity.put(CSC_Rec.City__c, CSC_Rec.Country__c);
            }    
        }
        
    }
}