@isTest(SeeAllData=True)
public class Social_Activity_Test{
    public static testmethod void  Social_ActivityHistory(){
        try{
            Task task=new Task();
            task.Type='Call';
            insert task;                
            delete task;
        }
        catch(Exception e){
            System.Debug('Task here'+e.getMessage());            
        }
}
public static testmethod void  Social_ActivityHistoryEvent(){
    try{
        Event event=new Event();
        event.Type='Meeting';
        event.DurationInMinutes=12;
        event.ActivityDateTime=System.Today();
        insert event;        
        delete event;
    }
    catch(Exception e){
        System.Debug('Event here'+e.getMessage());    
        } 
    }    
}