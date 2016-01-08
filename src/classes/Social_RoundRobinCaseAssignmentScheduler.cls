global class Social_RoundRobinCaseAssignmentScheduler implements Schedulable {
    global void execute(SchedulableContext ctx) {
        Social_RoundRobinCaseAssignment srrca =  new Social_RoundRobinCaseAssignment();
        //database.executeBatch(srrca);
        Integer batchsize = 200;
        try{
            batchsize = Integer.valueOf(System.label.Case_Assignment_Batch_Size);
        }
        catch(Exception e){
            System.debug('Error in setting the batch size: '+e.getMessage());
        }
        Database.executeBatch(srrca, batchsize);
    }

}