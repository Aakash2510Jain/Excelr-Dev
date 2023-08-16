global class ScheduleLeadAssignment implements Schedulable{
    global void execute(SchedulableContext SC){ 
        LeadAssignmentExecutionCriteria.validateEntryCriteria();
    }
}