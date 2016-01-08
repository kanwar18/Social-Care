@isTest(seeAllData=false)
public class Social_ReplyToPostControllerTest {
    static testMethod void Social_ReplyToPostControllerTestA() {
        
        Case testCaseObj = new Case();
        testCaseObj.Status = 'New';
        testCaseObj.Origin='email';     
        testCaseObj.priority = 'Low';
        testCaseObj.OwnerId = UserInfo.getUserid();
        testCaseObj.recordTypeId = System.label.HS_Care_Rep_RT;
        insert testCaseObj;
        
        custom_post__c cPost = new custom_post__c();
        cPost.Case__c = testCaseObj.id;
        insert cPost;
        
        ApexPages.StandardController StdCtrl = new ApexPages.StandardController(cPost);
        Social_ReplyToPostController replyToPos = new Social_ReplyToPostController(StdCtrl);
        
        replyToPos.replyToPost();  
        replyToPos.renderReply = true;     
    }
}