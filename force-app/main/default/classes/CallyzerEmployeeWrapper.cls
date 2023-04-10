public without sharing class CallyzerEmployeeWrapper 
{
    public List<employeeWrapper> data;
    
    public class employeeWrapper
    {
            public String id;
            public String employeeName;
            public String employeeCode;
            public String countryCode;
            public String mobile;
            public String deviceName;
            public List<String> tags;
            public String appVersion;
            public String registeredDateTime;
            public String modifiedDateTime;
            public String lastSyncedCallDateTime;
            public String lastCallSyncApiRequestTime;
            public Boolean isLeadEnabled;
            public Boolean isCallRecordingEnabled;
            public DeviceDetails deviceDetails;  
           public DevicePrefernce devicePrefernce;  
            public AppSettings appSettings;  // sub
    }  
     public class DeviceDetails
    {
           public String deviceModel;
           public Integer versionCodel;
           public String board;
           public String androidVersion;
           public Integer sdkVersion;
           public String uniqueSimId;
    }
     public class DevicePrefernce
     {
         public Boolean isAppUninstalled;
         public String batteryPercentage; //null
     }
     public class AppSettings
     {
            public String defaultHomeScreen;
            public String enableNoteDialog;
            public String callRecordingLocation; //Null
            public String isLogEnabled;
     }
   
    
}