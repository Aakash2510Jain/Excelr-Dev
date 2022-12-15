public class CreatePaymentOnOppHelper {
    @auraEnabled
    public static void updatePaymentStatus(String oppId){
        if(!string.isBlank(oppId)){
            Opportunity oppRec = new Opportunity();
            oppRec.Id = oppId;
            oppRec.Payment_Status__c = 'Initiated';
            update oppRec;
        }
    }
}