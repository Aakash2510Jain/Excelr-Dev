public class BulkOpportunityTransfer {
    @invocableMethod(label='Get Opportunity Details' description='Returns the list of Opportunities corresponding to the specified Opportunity IDs.' category='Opportunity')
    public static List<Opportunity> getOppDetails(List<Id> ids){
        List<Opportunity> oppListToUpdate = new List<Opportunity>();
        List<Opportunity> oppListToNotUpdate = new List<Opportunity>();
        List<Opportunity> oppList = [SELECT Expected_Revenue__c, Name, OwnerId FROM Opportunity WHERE Id IN: ids];
        for(Opportunity oppRec : oppList){
            if(oppRec.Expected_Revenue__c <= 0 || oppRec.Expected_Revenue__c == null){
                oppListToNotUpdate.add(oppRec);
            }
        }
        return oppListToNotUpdate;
    }
}