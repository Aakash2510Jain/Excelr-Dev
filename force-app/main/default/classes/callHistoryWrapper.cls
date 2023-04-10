public without sharing class CallHistoryWrapper
{
    public List<HistoryWrapper> data;
    
    public class HistoryWrapper
    {
         public String employee;
         public String employeeName ;
         public String employeeNumber ;
         public String employeeCode;
         public String  client;
         public String clientName;
         public String  countryCode ;
         public String clientNumber;
         public String  xdate;
         public String  xtime;
         public String  duration;
         public String durationInSeconds;
         public String callType;
         public String note;
         public String callRecordingPath;
         public String uniqueId;
    }

}