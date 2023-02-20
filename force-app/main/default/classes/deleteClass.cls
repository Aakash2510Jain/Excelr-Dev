public without sharing class deleteClass {
    public static void deleteMethod(){
        
       List <City_Big_Object__b> cityList = [Select City__c from City_Big_Object__b where CountryStateCompositeKey__c = 'a0aN000000BcX3TIAVa0bN000000Es3saIAB'];
       system.debug('cityList--->'+cityList.size());
    }
}