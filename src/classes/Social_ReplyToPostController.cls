public class Social_ReplyToPostController{
    public List<case> caseList = new list<Case>();
    custom_post__c cPost{get; set;} //Custom Post object instance
    public boolean renderReply{get; set;} // to render reply to Post
    
    public Social_ReplyToPostController(ApexPages.StandardController controller){
        cPost=(custom_post__c)controller.getRecord();
    }
    
    public void replyToPost(){
        caseList = [select CaseNumber ,id,recordTypeId from case where id =: cPost.Case__c limit 1];
        if(!caseList.isEmpty() && caseList[0].recordTypeId != system.label.ConsumerCareCase){
            caseList[0].recordTypeId = system.label.ConsumerCareCase;
        }        
        if(!caseList.isEmpty()){
            Social_CaseAssignmentUtility.executeTriggerCode = false;
            Social_StreamingUtil.preventCaseValidateTriggerToFire = false;
            Social_StreamingUtil.doNtFireEmail2CaseRun = false;
            Social_StreamingUtil.doNotFireUpdateReason = false;
            Social_StreamingUtil.updateSObject(caseList,'Class:Social_ReplyToPostController Method:replyToPost');
        }
    }
}