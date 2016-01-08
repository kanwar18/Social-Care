@IsTest(seeAllData = True)
private class TestITSupport_MetricsCompute
{
    static testMethod void ITSupport_MetricsCompute()
    {
       id itSupportID;

       List<IT_Support_Ticket__History> ticketHistory = [select id, newValue,oldValue, field, ParentId from IT_Support_Ticket__History where field = 'Status__c'];
       for(IT_Support_Ticket__History hist: ticketHistory)
         {
           
           if(hist.newValue == 'In Progress')
                  {
                      itSupportID = hist.parentID;
                      system.debug('inside for loop' + itSupportID);
                      break;
                  }          
            
          }
               
        IT_Support_Ticket__c its = [select id, name, Status__c from IT_Support_Ticket__c where id =: itSupportID];

        ApexPages.currentPage().getParameters().put('id', its.id);  
        ITSupport_MetricsCompute  itsComp= new ITSupport_MetricsCompute(new ApexPages.StandardController(its));  
        itsComp.doAction();
        itsComp.gettotalResTime();
        system.debug('Total Resolution time' + itsComp.totalResolutionTime);
                
    }
}