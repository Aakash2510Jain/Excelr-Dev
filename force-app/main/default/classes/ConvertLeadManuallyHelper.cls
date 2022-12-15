public class ConvertLeadManuallyHelper {
    @auraEnabled
    public static void convertLead(string leadId){
        system.debug('leadId-->'+leadId);
    }
}