global class Social_CaseAssignmentSyncScheduler implements Schedulable {
    global void execute(SchedulableContext ctx) {
        Social_CaseAssignmentSync scas =  new Social_CaseAssignmentSync();
        scas.resetCounters();
    }
}