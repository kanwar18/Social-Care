global class Social_CaseAssignmentScheduler implements Schedulable {
    global void execute(SchedulableContext ctx) {
        Social_CaseAssignment sca =  new Social_CaseAssignment();
        sca.initiateCaseAssignment();
    }
}