@isTest public class AGMTriggerTest {
    @isTest
    static void test_AGMTrigger() {
        try{
        User userRec = TestUtility.insertUser();
        insert userRec;    
        
        Assignment_Group__c agRec = TestUtility.insertAG('SLM');
        insert agRec;
        
        Assignment_Group__c agRec1 = TestUtility.insertAG('PLM');
        insert agRec1;
        
        Assignment_Group_Member__c agmRec = TestUtility.insertAGM(8,true,true);
        agmRec.Group_Member__c = userRec.Id;
        agmRec.Assignment_Group__c = agRec.Id;
        insert agmRec;
        
        Assignment_Group_Member__c agmRec1 = TestUtility.insertAGM(1,true,true);
        agmRec1.Group_Member__c = userRec.Id;
        agmRec1.Assignment_Group__c = agRec1.Id;
        insert agmRec1;
        
        agmRec.Max_Lead_Per_Day__c = 9;
        update agmRec;
    }catch (Exception e){
        system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
        HandleBusinessException.captureError('AGMTriggerTest', 'test_AGMTrigger', e, null);
 }
}
}