trigger Social_AuditUpdate on Audit_Responses__c (before Update) {
    
    public List<Audit_Question__c> auditCqlist;    
    public Audit_Responses__c ar = Trigger.New[0];
   
   
     if(RecursionController.controller== true){
          
        auditCqlist=[Select Id, Name, Question__c, Coaching__c,Answer__c, Score__c, Component__c from Audit_Question__c  Order By Component__c ASC];
        
        for(Audit_Question__c a : auditCqlist)
        {          
            if(a.Question__c == ar.Audit_Question__c && ar.Audit_answer__c.equalsIgnoreCase('NA')) { 
                
                ar.Audit_score__c = 0;     
                           
                  
            }     
            else if(a.Question__c == ar.Audit_Question__c && ar.Audit_answer__c.equalsIgnoreCase('No')) 
            {                 
                  ar.Audit_score__c = 0;                 
                     
            }
            else if(a.Question__c == ar.Audit_Question__c  && ar.Audit_answer__c.equalsIgnoreCase('Yes'))
            {            
               ar.Audit_score__c = a.Score__c;
                  
            } 
             
        } 
        }
     }