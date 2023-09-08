public with sharing class API_LMSTrainerInvoicesWrapper {
    public API_LMSTrainerInvoicesWrapper() {}

    public String first_name;
    public String last_name;
    public String email;
    public String trainer_lms_id;
    public String phone;
    public List<invoice_list> invoice_list;

    public class invoice_list {
		public String product_id;
		public String batch_id;
		public String invoice_number;
		public Integer amount;
		public String status;
		public String initiated_date;
		public Integer total_no_of_hours;
		public String contract_type;
	}
}