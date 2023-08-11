global class ResponseWrapper {
    global class UserRecord {
        public String firstName;
        public String email;
        public String userId;
        public String phone;
        public UserAttributes attributes;
    }
    
    global class UserAttributes {
        public String Course;
        public String Id;
        public String lead_status;
        public String AlternatePhone;
        public String AlternateEmail;
        public String lead_id;
    }
}