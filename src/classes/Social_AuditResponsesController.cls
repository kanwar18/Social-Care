public class Social_AuditResponsesController{
    public Id idd;
    public String userName  {get;set;}
    public String cManager  {get;set;}
    public User u {get;set;}
    public Case closedManager;
    public Social_AuditResponsesController(ApexPages.StandardController controller) {
        idd=ApexPages.currentPage().getParameters().get('id');
        profileSettings();
        closedManager = [Select Id , Closed_Operation_Manager__c From Case where id=:idd];
        cManager = closedManager.Closed_Operation_Manager__c;
    }  
   
    public ApexPages.StandardSetController con {
    
        get {
            if(con == null) {
                con = new ApexPages.StandardSetController(Database.getQueryLocator([Select id, Name,Case__c,  Audit_Question__c , Audit_Answer__c, Audit_Score__c,Audit_Coaching__c, Audit_Component__c from Audit_Responses__c where Case__c=:idd]));
                // sets the number of records in each page set
                con.setPageSize(5);
            }
            return con;
        }
        set;
    }
    public List<Audit_Responses__c> getAuditResponses() {
        return (List<Audit_Responses__c>) con.getRecords();
        
    }
    // indicates whether there are more records after the current page set.
    public Boolean hasNext{
        get {
            return con.getHasNext();
        }
        set;
    }
    // indicates whether there are more records before the current page set.
    public Boolean hasPrevious {
        get {
            return con.getHasPrevious();
        }
        set;
    }
    // returns the previous page of records
    public void previous() {
        con.previous();
    }
    // returns the next page of records
    public void next() {
        con.next();
    }  
    
    // returns the first page of records
    public void first() {
        con.first();
    }
 
    // returns the last page of records
    public void last() {
        con.last();
    }
    
    
    public void profileSettings() {
        u = [select id, Name from User where id=: Userinfo.getUserId()];
        userName =u.Id;    
    }    
}