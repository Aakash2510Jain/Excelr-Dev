public with sharing class API_LMSStudentActivityWrapper {
   // public cls_studentactivity_post[] post_student_activity;
   // public class cls_studentactivity_post {
		public String student_id;	    //123
		public String activityDescription;	    //Registered Webinar <webinar name>
		public string activityDate;	    //10/12/2023
	//}

    public static List<API_LMSStudentActivityWrapper> parse(String json){
        return (List<API_LMSStudentActivityWrapper>) System.JSON.deserialize(json, List<API_LMSStudentActivityWrapper>.class);
    }
}