public with sharing class PostLMS_UpdateStudentStatusWrapper {
    public List<StudentUpdateWrapper> studentUpdates { get; set; }

    public PostLMS_UpdateStudentStatusWrapper() {
        studentUpdates = new List<StudentUpdateWrapper>();
    }

    public class StudentUpdateWrapper {
        public String status;
        public String block_type;
        public BlockDetails block_details;
        public String student_id;
        public String remark;
    }

    public class BlockDetails {
        public List<String> course_id;
        public List<String> product_id;
        public List<String> batch_id;
    }
}