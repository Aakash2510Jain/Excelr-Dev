public without sharing class GetAGMRecordsHelper {
@AuraEnabled(cacheable=true)
  public static List<Assignment_Group_Member__c> getAGMMembers(String userName) {
    System.debug('userName--->'+userName);
    List<Assignment_Group_Member__c> agmList = [SELECT Assignment_Group__r.Name,Group_Member__r.Name,Id,AGM_URL__c,Max_Lead_Per_Day__c,Name,Queue_Type__c FROM Assignment_Group_Member__c WHERE Group_Member__r.Name LIKE : userName+'%'];
    system.debug('agmList--->'+agmList);
    return agmList;
  }
}