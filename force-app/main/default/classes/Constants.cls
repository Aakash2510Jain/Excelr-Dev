public class Constants{
    public static final string PENDING = 'Pending';
    public static final String UNDER_APPROVAL_PROCESS_ERR_MSG = 'Record is Under Approval';
    public static Id queueId = [select Id
                                from Group
                                where Name = 'Excelr Default Queue' and Type = 'Queue'].Id;
    // queue name
    public static final string PRIVATE_LEAD_QUEUE = 'Org Default Queue';
    public static final String CALLYZER_CALL_HISTORY_ENDPOINT = System.Label.CALLYZER_CALL_HISTORY_ENDPOINT;
    public static final string taskSubjectViaLeadCreationAPI = 'Candidate has applied again for the Same Course';
    public static final string productRecordType = Schema.getGlobalDescribe().get('Product2').getDescribe().getRecordTypeInfosByName().get('Product').getRecordTypeId();

}