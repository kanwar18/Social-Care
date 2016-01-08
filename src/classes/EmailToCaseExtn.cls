public with sharing class EmailToCaseExtn {

 public Map<String,List<EmailMessage>> emailMessageMap {get;set;}
             
  public EmailToCaseExtn(){           
                    emailMessageMap = new Map<String,List<EmailMessage>> ();
              }
                        
    public void doAction(){
             try{
             List<id> lrecid =new list<id>();
             for(Recordtype rectype: [select id,name from recordtype where SobjectType='Case' and name like '%Consumer%']){
             lrecid.add(rectype.id);
             }           
            for(EmailMessage record:[select id,Subject,Parent.CaseNumber,
            Parent.Contact.Name,Parent.Owner.Name from EmailMessage where parent.status != 'Closed' and parent.status != 'Auto Closed' and parent.recordtypeid in :lrecid]){
                if(!emailMessageMap.containskey(record.Parent.CaseNumber)) {
                    emailMessageMap.put(record.Parent.CaseNumber, new List<EmailMessage>());
                }
                emailMessageMap.get(record.Parent.CaseNumber).add(record);
               
            }  
            System.debug('emailMessageMap :'+emailMessageMap);

        }catch(Exception excep){
                    System.debug('Exception Caught===> :'+excep.getMessage());
             }
        
        
        }        
         public PageReference save() 
         {
            return page.ReportToExcelPage;
         }
      
      }