public class Social_CaseRedirectController {
    
    private Case caseRecord;
    public Social_CaseRedirectController(ApexPages.StandardController controller) {
        this.caseRecord = (Case)controller.getRecord();
        returnMethod();
    }
    
    public PageReference returnMethod(){
        PageReference returnPage = new PageReference('/'+caseRecord.id);
        //for(string key:ApexPages.currentPage().getParameters().keySet()){
            //returnPage.getParameters().put(key, ApexPages.currentPage().getParameters().get(key));
        //}
        returnPage.getParameters().put('nooverride', '1');
        returnPage.setRedirect(true);
        
        return returnPage;
    
    }
}