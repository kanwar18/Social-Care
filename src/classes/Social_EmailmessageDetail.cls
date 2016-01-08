public class Social_EmailmessageDetail {

    public boolean disableButtons{get;set;}
    private final EmailMessage message; 
    public String strTemp{get;set;}    
    public Social_EmailmessageDetail(ApexPages.StandardController controller) {
        message = (EmailMessage)controller.getRecord();
        strTemp = message.parentId;
        if(message.parentId!=null){
             Case c = [Select status from Case where id=: message.parentId];
                if(c!=null && c.status!=null && ((c.status).equalsIgnoreCase('Closed') || (c.status).equalsIgnoreCase('Auto Closed'))){
                    disableButtons = false;
                }
                else{
                    disableButtons = true;
                }        
        }       
    }

}