public with sharing class API_LMSStudentAttendanceWrapper {
    public API_LMSStudentAttendanceWrapper() {}
    public String student_id;
	public String course_name;
	public String product_id;
	public Double completion_percentage;
	public Integer total_sessions_attended;
	public Integer planned_sessions;
	public String batch_id;

    public static List<API_LMSStudentActivityWrapper> parse(String json){
        return (List<API_LMSStudentActivityWrapper>) System.JSON.deserialize(json, List<API_LMSStudentActivityWrapper>.class);
    }
}