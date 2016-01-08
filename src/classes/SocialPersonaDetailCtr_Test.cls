@isTest
private class SocialPersonaDetailCtr_Test {


    static Account a;
    static SocialPersona persona;
    static SocialPost post, reply;
    static Case aCase;

    static void populateEnvironment(){

        aCase = new Case();
        aCase.Subject = 'test this';
        insert aCase;
        
        a = new Account(Name='Test Account');
        insert a;

        persona = new SocialPersona(Name='testPersona');
        persona.ParentId = a.Id;
        persona.Provider = 'Twitter';
        persona.RealName = 'For real';
        insert persona;

        post = new SocialPost(Name='testPost');
        post.PersonaId = persona.Id;
        post.ParentId = aCase.Id;
        post.ExternalPostId = '00001';
        post.Provider = 'Twitter';
        post.MessageType = 'Tweet';
        insert post;

        reply  = new SocialPost(Name='testPost');
        reply.PersonaId = persona.Id;
        reply.ReplyToId = post.Id;
        reply.Provider = 'Twitter';
        reply.MessageType = 'Reply';
        reply.ResponseContextExternalId = post.ExternalPostId;
        insert reply;

    }

    /*
        validate that social Persona is correctly obtained from postId
    */
    static testMethod void test_controller_postID(){
        populateEnvironment();

        System.Test.startTest();

        PageReference pageRef = Page.SocialPersonaDetail;
        pageRef.getParameters().put('id',post.Id);
        System.Test.setCurrentPage(pageRef);

        SocialPersonaDetailCtr ctr = new SocialPersonaDetailCtr();
        System.Test.stopTest();

        System.assertNotEquals(ctr.persona,null);
        System.assertNotEquals(ctr.offset,null);

        SocialPersona sp = ctr.persona;
        system.assertEquals(persona.RealName, sp.RealName);
        
    }

    /*
        validate that social Persona is correctly obtained from caseId
    */
    static testMethod void test_controller_caseID(){
        populateEnvironment();

        System.Test.startTest();

        PageReference pageRef = Page.SocialPersonaDetail;
        pageRef.getParameters().put('id',aCase.Id);
        System.Test.setCurrentPage(pageRef);

        SocialPersonaDetailCtr ctr = new SocialPersonaDetailCtr();
        System.Test.stopTest();
        //searches by case and it's related social posts 
        // takes persona from latest post
        System.assertNotEquals(ctr.persona,null);

        SocialPersona sp = ctr.persona;
        system.assertEquals(persona.RealName, sp.RealName);
        
    }


    /*
        Obtain persona previous posts form case Id
    */
    static testMethod void test_getPostHistory(){
        populateEnvironment();

        System.Test.startTest();
        List<SocialPost> lSP = SocialPersonaDetailCtr.getPostHistory(aCase.Id);
       
        System.Test.stopTest();

        System.assert(!lSP.isEmpty());
        System.assertEquals(2,lSP.size());    
    }

    static testMethod void test_getConversationsPosts(){
        populateEnvironment();

        System.Test.startTest();
        List<SocialPost> lSP = SocialPersonaDetailCtr.getConversationsPosts(aCase.Id);
       
        System.Test.stopTest();

        System.assert(!lSP.isEmpty());
        System.assertEquals(1,lSP.size());  //this is just the main post in the conversation
       
        
    }

    static testMethod void test_getThreadByPostId(){
        populateEnvironment();

        System.Test.startTest();
        List<SocialPost> lSP = SocialPersonaDetailCtr.getThreadByPostId(post.Id);
       
        System.Test.stopTest();

        System.assertEquals(2,lSP.size());    // this are the two posts in the conversation     
    }

}