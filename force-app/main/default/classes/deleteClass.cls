public without sharing class deleteClass {

   
    public static List <City_Big_Object__b> deleteMethod(string SelectedCountryId,string SelectedStateId){
        system.debug('SelectedCountryId--'+SelectedCountryId);
        system.debug('SelectedStateId--'+SelectedStateId);
        string compositekey=SelectedCountryId+SelectedStateId;
       List <City_Big_Object__b> cityList = [Select Id,City__c from City_Big_Object__b where CountryStateCompositeKey__c =:compositekey];
       system.debug('cityList--->'+cityList.size());
       //Select City__c from City_Big_Object__b where CountryStateCompositeKey__c = 'a0aN000000BcX3TIAVa0bN000000Es3saIAB'
       //
 
       return cityList;
    }
}