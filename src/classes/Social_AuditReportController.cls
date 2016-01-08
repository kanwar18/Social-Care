public class Social_AuditReportController{
   
   private List<Case> cases;
   private List<Case> allAuditedCases;
   private List<Case> allClosedCases_CM;
   private List<Case> allAuditCases_OP;
   private transient List<Case> allCompletedAuditCases_OP;
   private String sortDirection = 'ASC';
   private String sortExp = 'CaseNumber';
   Public Boolean isOperationalManager {get;set;}
   Public Boolean isCareManager {get;set;}
   Public Boolean isSystemAdmin {get;set;}
   Public Boolean isSeniorOperationalManagerBus {get;set;}
   Public Boolean isCareManagerBusiness {get;set;}
   public Profile p;
   
   // Constractor
   public Social_AuditReportController(){
       ViewData();
       allCompletedAuditCases();
       AllClosedCases_CM();
       AllAuditCases_OP();
       AllCompletedAuditCases_OP();
       profileSettings();
   }
   
   
   public String sortExpression{
     get{
        return sortExp;
     }
     set
     {
       //if the column is clicked on then switch between Ascending and Descending modes
       if (value == sortExp)
           sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
       else
         sortDirection = 'ASC';
       sortExp = value;
     }
   }

    public String getSortDirection(){
        //if not column is selected 
        if (sortExpression == null || sortExpression == '')
            return 'ASC';
        else
         return sortDirection;
    }

    public void setSortDirection(String value){  
        sortDirection = value;
    }
  
   public List<Case> getCases() {
       return cases;
   }
   
   public List<Case> getAllAuditedCases() {
       return allAuditedCases;
   }
   
   public List<Case> getAllClosedCases_CM() {
       return AllClosedCases_CM;
   }
   
   public List<Case> getAllAuditCases_OP() {
       return allAuditCases_OP;
   }
   
   public List<Case> getAllCompletedAuditCases_OP() {
       return allCompletedAuditCases_OP;
   }


   public PageReference ViewData(){
       //build the full sort expression
       string sortFullExp = sortExpression  + ' ' + sortDirection;
      
        cases = Database.query('Select Owner.Id,ClosedDate,status, Owner.name,   No_Of_Audit_Responses__c,Closed_Operation_Manager__c, CaseNumber,  Audit_Status__c, Audit_Score__c,  Assigned_Operation_Manager__c,  AccountId From Case where Audit_Status__c =\'Under QA\' AND (Status =\'Closed\' OR Status =\'Auto Closed\') ORDER BY  ' + sortFullExp +'');
       return null;  
   }
   
   public PageReference allCompletedAuditCases(){
       //build the full sort expression
       string sortFullExp = sortExpression  + ' ' + sortDirection;
       allAuditedCases = Database.query('Select Owner.Id,ClosedDate,status, Owner.name,   No_Of_Audit_Responses__c,Closed_Operation_Manager__c, CaseNumber,  Audit_Status__c, Audit_Score__c,  Assigned_Operation_Manager__c,  AccountId From Case where Audit_Status__c =\'QA Completed\' AND (Status =\'Closed\' OR Status =\'Auto Closed\') ORDER BY  ' + sortFullExp + '');
       return null;  
   }
   
   // all care manager closed cases
   public PageReference AllClosedCases_CM(){
       //build the full sort expression
       string sortFullExp = sortExpression  + ' ' + sortDirection;
       AllClosedCases_CM= Database.query('Select Owner.Id,ClosedDate,status, Owner.name,No_Of_Audit_Responses__c,Closed_Operation_Manager__c, CaseNumber,  Audit_Status__c, Audit_Score__c,  Assigned_Operation_Manager__c,  AccountId From Case where Audit_Status__c =\'QA Completed\' AND (Status =\'Closed\' OR Status =\'Auto Closed\') AND OwnerId=\'' + UserInfo.getUserId() + '\' ORDER BY  ' + sortFullExp +'');
       return null;  
   }
   
    // All Unser Audit Cases of OP
   public PageReference AllAuditCases_OP(){
       //build the full sort expression
       string sortFullExp = sortExpression  + ' ' + sortDirection;
       AllAuditCases_OP= Database.query('Select Owner.Id,ClosedDate,status, Owner.name,No_Of_Audit_Responses__c,Closed_Operation_Manager__c, CaseNumber,  Audit_Status__c, Audit_Score__c,  Assigned_Operation_Manager__c,  AccountId From Case where Audit_Status__c =\'Under QA\' AND (Status =\'Closed\' OR Status =\'Auto Closed\') AND Closed_Operation_Manager__c =\'' + UserInfo.getUserId() + '\' ORDER BY  ' + sortFullExp + '');
       return null;  
   }
   
    // All Completed Audit Cases of OP
   public PageReference AllCompletedAuditCases_OP(){
       //build the full sort expression
       string sortFullExp = sortExpression  + ' ' + sortDirection;
       AllCompletedAuditCases_OP= Database.query('Select Owner.Id,ClosedDate,status, Owner.name,No_Of_Audit_Responses__c,Closed_Operation_Manager__c, CaseNumber,  Audit_Status__c, Audit_Score__c,  Assigned_Operation_Manager__c,  AccountId From Case where Audit_Status__c =\'QA Completed\' AND (Status =\'Closed\' OR Status =\'Auto Closed\') AND Closed_Operation_Manager__c =\'' + UserInfo.getUserId() + '\' ORDER BY  ' + sortFullExp + '');
       return null;  
   }
   
    //Method to Check the profile with which user has login.
   public void profileSettings() {
        isOperationalManager = true;
        isCareManager = true;
        isSystemAdmin = true;
        isCareManagerBusiness = true;
        isSeniorOperationalManagerBus = true;
        
        p = [select id, Name from Profile where id=: Userinfo.getProfileId()];
        if(p.Name == 'Operations Manager'){
            isOperationalManager = false;
        }
         if(p.Name == 'Care Manager'){
            isCareManager = false;
        }
        if(p.Name == 'System Administrator'){
            isSystemAdmin= false;
        }
        if(p.Name == 'Care Manager Business'){
            isCareManagerBusiness= false;
        }
        if(p.Name == 'Senior Operations Manager Business'){
            isSeniorOperationalManagerBus= false;
        }

   }      


}