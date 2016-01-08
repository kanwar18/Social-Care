global class Social_LoginDetailsScheduler implements Schedulable {
    global void execute(SchedulableContext ctx) {
        Social_LoginDetails sold =  new Social_LoginDetails();
        sold.sendEmailwithDetails();
    }
}