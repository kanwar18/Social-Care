public class Social_caseClonecontroller {
    
    // Local Variables
    private Case requestRecord;
    
    // Class Constructor
    public Social_caseClonecontroller(ApexPages.StandardController stdController){
    
       this.requestRecord = (Case)stdController.getRecord();
    }
    
    // Clone Override Method
    public PageReference cloneCaseRecord(){
         
         PageReference clonePage = new PageReference('/' + requestRecord.Id + '/e?clone=1&' + '00NE0000004XZVI=true&' + 'nooverride=1&' + 'retURL=' + requestRecord.Id);
         return clonePage;
         
    }

}