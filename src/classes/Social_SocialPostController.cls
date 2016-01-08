/*** 
 * Class Name: Social_SocialPostController
 * Author: Accenture
 * Date: 20-Feb-2015
 * Requirement/Project Name: Business Care
 * Requirement Description: Class is responsible for handling threading logic on case. 
 * Version History: Debasis(5/June/2015) - Release 17June2015 - ITS1504; Users were forced to reply using the comment option for Facebook reply post. 
 * Version History: Ashween(5/June/2015) - Release 17June2015 - D-1198
 * Version history: Haemen (5/June/2015) - Release 17June2015 - ITS 001635
 * Version history: Haemen (15/July/2015) - Release 15July2015 - ITS 001545
 * Version History: Haemen(7/10/2015) - Release 21stOctober2015 - ITS1657 : Case Reassigned time Blanked out when moving case back to Queue.
**/

Global Class Social_SocialPostController {
    Public Boolean socialPersonaExists;
    Public List<Contact> contactListInsert = new List<Contact>();
    Public List<SocialPersona> socialPersonaListInsert = new List<SocialPersona>();
    Public List<Case> caseListInsert = new List<Case>();
    Public List<SocialPost> socialPostListInsert = new List<SocialPost>();
    Public set<String> ConsumerPostTagSet = new Set<String>(); 
    Public List<SocialPersona> socialPersonaList = new List<SocialPersona> ();
    Public Decimal diff;    
    Public Decimal hours; 
    public static Map<id,User> userDetailMapForInboundHandler = new Map<Id,User>();
    
    Public Social_SocialPostController (){    
    }
    
    Public Social.InboundSocialPostResult inboundSocialPost(SocialPost post, SocialPersona persona, Map<String, Object> data) {
        Social.InboundSocialPostResult result = new Social.InboundSocialPostResult();
        socialPersonaExists = checkSocialPersonaExists(persona);
        system.debug('Social Post Value'+post);   
        //Added post Id check to avoid DML failure when outbound post/tweets comes back to salesforce
        if (post.Id == null && !checkSocialPostIsDuplicate(post)) {
            try {
                if (socialPersonaExists) {
                    associatePosttoCase(socialPersonaList, post);
                } else {
                    createNewContact(persona);
                    createNewPersona(persona);
                    createNewCase(persona, post);
                    createPost(post);
                }
            } catch (Exception e) {
                List<String> sendTo= new List<String>();
                sendTo.addAll(string.valueOf(Label.Email_List_for_Class_Failure).split(','));
                Social_SendAnEmailUtility.sendEmail('Failed to Process Social Post',sendTo,'<b>Error Message:  </b>' + e.getMessage() + '</br>' + '<b>Line Number:  </b>' + e.getLineNumber() + '</br>' + '<b>Stack Trace:  </b>' + e.getStackTraceString() + '</br>' + '<b>Type of Exception:  </b>' + e.getTypeName() + '</br>' + '</br>' + '</br>' + '<b>SOCIAL POST PULLED FROM RADIAN 6</b>' + '</br>' +post + '</br>' + '</br>' +'<b>SOCIAL PERSONA PULLED FROM RADIAN 6</b>' + '</br>' +persona, userInfo.getUserName());
            }
        }
        return result;
    }
    
    
    /**
    * < checkSocialPostIsDuplicate() - Method to verify if incoming social post already exists>
    * @param:
    *     SocialPost singlePost - Incoming social post
    *       
    * @return - void
    * @see - Social_SocialPostController (same class)
    */
    
    Public Boolean checkSocialPostIsDuplicate(socialPost singlePost) {
        Boolean socialPostAlreadyExists = false;
        List<socialPost> socialPostList = [Select id from socialPost where R6PostId =: singlePost.R6PostId];
        if (!socialPostList.isEmpty()) {
            socialPostAlreadyExists = true;
        }
        return socialPostAlreadyExists;
    }
    
    /**
    * < checkSocialPersonaExists() - Method to verify if incoming social persona already exists in salesforce>
    * @param:
    *     SocialPersona singlePersona - Incoming social persona 
    *       
    * @return - void
    * @see - Social_SocialPostController (same class)
    */
    Public Boolean checkSocialPersonaExists(socialPersona singlePersona) {
        List<SocialPersona> socialPersonaListToUpdate = new List<SocialPersona>();
        socialPersonaList = [select id,parentid,ExternalId,Name,Followers,Following,NumberOfTweets from socialPersona where Name =: singlePersona.Name and ExternalId=:singlePersona.ExternalId order By lastModifiedDate];
        if (socialPersonaList.isEmpty()) {
            socialPersonaExists = false;
        } else {
            socialPersonaExists = true;
            for (SocialPersona socialPer : socialPersonaList) {
                socialPer.Followers = singlePersona.Followers;
                socialPer.Following = singlePersona.Following;
                socialPer.NumberOfTweets = singlePersona.NumberOfTweets;
                socialPersonaListToUpdate.add(socialPer);
            }
            if (!socialPersonaListToUpdate.isEmpty()) {
                Social_StreamingUtil.doNotUpdatePersona = false;
                Social_StreamingUtil.updateSObject(socialPersonaListToUpdate,'Class:Social_SocialPostController Method:UpdatePersonaDetails' + singlePersona);
            }
        }
        return socialPersonaExists;
    }   
    
    /**
    * < createNewContact() - Method to create new Contact for incoming social persona>
    * @param:
    *     SocialPersona singlePersona - Incoming social persona 
    *       
    * @return - void
    * @see - Social_SocialPostController (same class)
    */
    Public void createNewContact(SocialPersona singlePersona) {
        Contact contactObj = new Contact();
        //to trim if the real name from twitter has leading and trailing white spaces
        string trimmedRealName = singlePersona.RealName.replaceAll('^\\s+|\\s+$', '');
        if (trimmedRealName.substringAfter(' ') == '' || trimmedRealName.substringAfter(' ').startsWith(' ')) {
            contactObj.LastName = trimmedRealName.substringBefore(' ');
        } else {
            contactObj.LastName = trimmedRealName.substringAfter(' ');
            contactObj.FirstName = trimmedRealName.substringBefore(' ');
        }
        contactListInsert.add(contactObj);
        Social_StreamingUtil.insertSObject(contactListInsert,'Class:Social_SocialPostController Method:createNewContact' + singlePersona);
    }
    
    /**
    * < createNewPersona() - Method to create new Social Persona>
    * @param:
    *     SocialPersona singlePersona - Incoming social persona 
    *       
    * @return - void
    * @see - Social_SocialPostController (same class)
    */
    Public void createNewPersona(SocialPersona singlePersona) {
        if (!contactListInsert.isEmpty()) {
            singlePersona.ParentId = contactListInsert[0].Id;
            singlePersona.R6Service__Followers__c = singlePersona.Followers;
            singlePersona.R6Service__Following__c = singlePersona.Following;
            singlePersona.R6Service__Friends__c = singlePersona.NumberOfFriends;
            singlePersona.R6Service__Bio__c = singlePersona.Bio;
            singlePersona.R6Service__Listed__c = singlePersona.ListedCount;
            singlePersona.R6Service__Tweets__c = singlePersona.NumberOfTweets;
            singlePersona.R6Service__ProfileType__c = singlePersona.ProfileType;
            singlePersona.R6Service__MediaProvider__c = singlePersona.MediaProvider;
            singlePersona.R6Service__R6SourceId__c = singlePersona.R6SourceId;
            socialPersonaListInsert.add(singlePersona);
            Social_StreamingUtil.insertSObject(socialPersonaListInsert,'Class:Social_SocialPostController Method:createNewSocailPersona');
        }
    }
    
    /**
    * < createNewCase() - Method to create new Case for incoming post and Social Persona>
    * @param:        
    *     SocialPost socialPostObj - Incoming social post
    *     SocialPersona singlePersona - Incoming social persona 
    *       
    * @return - void
    * @see - Social_SocialPostController (same class)
    */
    Public void createNewCase(SocialPersona singlePersona, SocialPost singlePost) {
        List<String> caseTagList = new List<String>(singlePost.PostTags.split(','));  //List to hold the Picklist values   
        Boolean recordTypeFlag = FALSE;  // Identify if Case needs to be Consumer Record type
        Set<String> postTagConsumerSet = new Set<String>(); //Consumer Post tag set
        if (singlePost != Null && !socialPersonaListInsert.isEmpty()) {
            ConsumerPostTagSet.addAll(Label.Consumer_PostTags.split(';'));
            Case singleCase = new Case(Status = 'New',
                                       Social_Persona_Name__c = singlePost.Handle,
                                       Social_Media_Source__c = singlePost.Provider,
                                       R6Service__MediaProvider__c = singlePost.Provider, 
                                       R6Service__SocialPersona__c = socialPersonaListInsert[0].Id,
                                       Subject = singlePost.Name,
                                       Description = singlePost.Content,
                                       Priority = singlePost.PostPriority, 
                                       R6Service__InitialPostId__c = singlePost.Id , 
                                       Posted_Date__c = singlePost.Posted , 
                                       Intial_Social_Post_Created__c = singlePost.Posted,
                                       R6Service__MediaType__c = singlePost.MediaType,
                                       Customer_Response_Received__c = true,
                                       Update_Reason__c = Social_StreamingUtil.CUSTOMER_REPLY);
           
            if(!contactListInsert.isEmpty()){
                singleCase.ContactId = contactListInsert[0].Id;
            } else {
                singleCase.ContactId = singlePersona.parentId;
                //Populating DNE value on new case if contact already has DNE value populated
                if(dneDetails(singleCase.ContactId)[0].DNE_Contact__c != null){
                    singleCase.DNE__c = dneDetails(singleCase.ContactId)[0].DNE_Contact__c;
                }
            }
            if (singlePost.Content != Null) {
                if(singlePost.Content.length() < 255) {
                    singleCase.Social_Care_Handle_Name__c = singlePost.Content;
                } else {
                    singleCase.Social_Care_Handle_Name__c = singlePost.Content.substring(0,254);
                }
            }
            singleCase.Case_PostTag__c = singlePost.PostTags;
            //singleCase.R6Service__InitialPostId__r.R6Service__PostTags__c = singlePost.PostTags; // Ashween populating this field so that assignment rule work
            singleCase.Customer_Response_Received_Time__c = dateTime.Now();
            for(string CaseTag: caseTagList ){
                //singleCase.Case_PostTag__c = CaseTag+';';
                if(ConsumerPostTagSet.contains(caseTag.trim().toUpperCase())){
                    recordTypeFlag = TRUE;
                    postTagConsumerSet.add(CaseTag);
                }                
            }
            if(postTagConsumerSet.IsEmpty() && recordTypeFlag == FALSE){
                singleCase.RecordTypeId = SYSTEM.LABEL.Business_Open_RT;
                singleCase.Business_Case_Post_Tag__c = '';
                singleCase.Update_reason__c = Social_StreamingUtil.BUSINESS_ROUND_ROBIN;                  
                for(string bzPostTag: caseTagList){
                    singleCase.Business_Case_Post_Tag__c += bzPostTag+';';
                }
            }
            else{
                singleCase.RecordTypeId = SYSTEM.LABEL.ConsumerCareCase;
                singleCase.Case_Post_Tag__c = '';
                for(string consumerPostTag: postTagConsumerSet){
                    singleCase.Case_Post_Tag__c += consumerPostTag+';';
                }
            }
            Social_CaseAssignmentUtility.executeTriggerCode = false;
            Social_StreamingUtil.doNtFireEmail2CaseRun = false;
            caseListInsert.add(singleCase);
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;
            Database.update(singleCase, dmo);         
            Social_StreamingUtil.insertSObject(caseListInsert,'Class:Social_SocialPostController Method:createNewCase' + 'Persona Details : ' + singlePersona + ' Social Post Details : ' + singlePost );
            
        }        
    }
    
    /**
    * < createPost() - Method to create Social post record for incoming post>
    * @param:        
    *     SocialPost socialPostObj - Incoming social post
    *       
    * @return - void
    * @see - Social_SocialPostController (same class)
    */
    Public void createPost(SocialPost socialPostObj ) {
        if (!socialPersonaListInsert.isEmpty()) {
            socialPostObj.ParentId = caseListInsert[0].Id;
            socialPostObj.R6Service__HarvestDate__c = socialPostObj.HarvestDate;
            socialPostObj.R6Service__PostTags__c = socialPostObj.PostTags;
            socialPostObj.Attachment_URL__c = socialPostObj.AttachmentUrl;
            socialPostObj.Attachment_Type__c = socialPostObj.AttachmentType;
            socialPostObj.Response_Context_External_Id__c = socialPostObj.ResponseContextExternalId;
            if(socialPersonaListInsert[0].ParentId != NULL){
                socialPostObj.WhoId = socialPersonaListInsert[0].ParentId ;
            }    
            else{
                socialPostObj.WhoId = contactListInsert[0].Id;
            }
            //Verify if inbound social post is a Reply to a comment in Facebook. Update the ReplyTo Lookup field such that the 
            //SCS publisher points to the Parent comment of the Reply.      
            if(Social_StreamingUtil.MESSAGE_TYPE_REPLY.equalsIgnoreCase(socialPostObj.MessageType) && Social_StreamingUtil.PROVIDER_FACEBOOK.equalsIgnoreCase(socialPostObj.Provider) && socialPostObj.ReplyTo == NULL ) {
                socialPostObj.ReplyToId = Social_SocialPostSCSHandler.inReplyToDetails(socialPostObj);  
            }  
            socialPostObj.PersonaId = socialPersonaListInsert[0].Id;
            socialPostObj.R6Service__AuthorSocialHandle__c = socialPersonaListInsert[0].Name;
            socialPostObj.R6Service__AuthorExternalId__c= socialPersonaListInsert[0].ExternalId;
            socialPostObj.R6Service__SourceTags__c = socialPostObj.SourceTags;
            socialPostListInsert.add(socialPostObj);
            Social_StreamingUtil.insertSObject(socialPostListInsert,'Class:Social_SocialPostController Method:createPost');
            updateCasewithPostId(caseListInsert, socialPostObj ); 
        }             
    }
    
    /**
    * < associatePosttoCase() - Method to identify existing case for incoming social post>
    * @param:
    *     List<SocialPersona> socialPersonaList - Corresponding Salesforce social persona record for incoming social post.        
    *     SocialPost post - Incoming social post
    *       
    * @return - void
    * @see - Social_SocialPostController (same class)
    */
    public void associatePosttoCase( List<SocialPersona> socialPersonaList , SocialPost post ){
        List <Case> associatedCaseList = new List<Case>();
        Decimal diff = 0.0;
        Decimal hours = 0.0;
        List<Case> reOpenCaseList = new List<Case>();
        List<User> ownerDetail = new List<User>();
        List<Case> caseListToUpdate = new List<Case>();
        Map<Id, List<Case>> countDecCaseUserMap = New Map<Id, List<Case>>();
        Map<Id, List<Case>> countIncCaseUserMap = New Map<Id, List<Case>>();
        Map<Id, List<Case>> countCloseCaseUserMap= New Map<Id, List<Case>>();
        Boolean isNewCase ; //added on 070315 by Ashween to differentiate update reason on New case or reopen scenario
        Set<Id> contactIdSet = new Set<Id>();
        associatedCaseList = [select ID,Contains_Consumer_Post_Tag__c,Business_Case_Post_Tag__c,Auto_Reassignment_Tag__c,Case_Post_Tag__c,Reassignment_Reason__c,Update_Reason__c,owner.Name, Customer_Response_Received__c, Do_Not_Reassign__c,Prior_Care_Manager__c,ownerid,Customer_Response_Received_Time__c,ClosedDate,LastModifiedDate,Current_SLA_Phase__c,RecordTypeId,Track_Case_Queue__c,ContactId,R6Service__SocialPersona__c,Persona__c,CaseNumber,Status,Case_PostTag__c from Case where R6Service__SocialPersona__c =: socialPersonaList[0].Id ORDER By CreatedDate desc  ];                    
        if(!associatedCaseList.isEmpty()){   
            /******* IF CASE IS NOT CLOSED *******/
            if(!Social_StreamingUtil.CASE_STATUS_CLOSED.equalsIgnoreCase(associatedCaseList[0].Status) && !Social_StreamingUtil.CASE_STATUS_AUTOCLOSED.equalsIgnoreCase(associatedCaseList[0].Status)) {
                post.R6Service__HarvestDate__c = post.HarvestDate;
                post.R6Service__PostTags__c = post.PostTags;
                post.Attachment_URL__c = post.AttachmentUrl;
                post.Attachment_Type__c = post.AttachmentType;
                post.Response_Context_External_Id__c = post.ResponseContextExternalId;
                post.ParentId = associatedCaseList[0].Id;
                post.WhoId = associatedCaseList[0].ContactId;
                post.PersonaId = associatedCaseList[0].R6Service__SocialPersona__c;
                post.R6Service__AuthorSocialHandle__c = socialPersonaList[0].Name;
                post.R6Service__AuthorExternalId__c= socialPersonaList[0].ExternalId;
                post.R6Service__SourceTags__c = post.SourceTags;
                //Verify if inbound social post is a Reply to a comment in Facebook. Update the ReplyTo Lookup field such that the 
                //SCS publisher points to the Parent comment of the Reply.
                if(Social_StreamingUtil.MESSAGE_TYPE_REPLY.equalsIgnoreCase(post.MessageType) && Social_StreamingUtil.PROVIDER_FACEBOOK.equalsIgnoreCase(post.Provider) && post.ReplyTo == NULL ) {
                    post.ReplyToId = Social_SocialPostSCSHandler.inReplyToDetails(post);  
                }  
                socialPostListInsert.add(post);
                Social_StreamingUtil.insertSObject(socialPostListInsert,'Class:Social_SocialPostController Method:associatePosttoCase Consumer Case');
                //Need to add logic to identify if incoming social post is a direct reply or not
                //Based on the result will need code to launch SLA's.
                if((post.PostTags != NULL && (post.PostTags.containsIgnoreCase('AUTODIR') || post.PostTags.containsIgnoreCase('MANUALDIR'))) || (post.MessageType.equalsIgnoreCase('Reply') || post.MessageType.equalsIgnoreCase('Direct') || post.MessageType.equalsIgnoreCase('Private'))){
                    associatedCaseList[0].Customer_Response_Received__c = true;               
                }
                // logic to send the case from pending closure queue to track case queue.
                associatedCaseList[0] = Social_SocialPostSCSHandler.caseUpdateCustomerResponseReceived(associatedCaseList[0]);                 
                associatedCaseList[0].Update_Reason__c = Social_StreamingUtil.CUSTOMER_REPLY;
                if(associatedCaseList[0].RecordTypeId == SYSTEM.LABEL.Business_Open_RT){                  
                   ownerDetail = ownerDetails(associatedCaseList[0]);                    
                   associatedCaseList[0].ReadUnreadCheck__c = TRUE;                  
                   if( !ownerDetail.isEmpty()){ 
                       if(('Offline'.equalsIgnoreCase(ownerDetail[0].Availability__c) || 'Vacation'.equalsIgnoreCase(ownerDetail[0].Availability__c))&& String.valueOf(associatedCaseList[0].ownerId).Startswith(Social_StreamingUtil.USER_ID) ){                            
                            associatedCaseList[0].OwnerId = associatedCaseList[0].Track_Case_Queue__c;                                                                                    
                       }
                       
                   if ((!'Offline'.equalsIgnoreCase(ownerDetail[0].Availability__c) ||!'Vacation'.equalsIgnoreCase(ownerDetail[0].Availability__c)) && String.valueOf(associatedCaseList[0].ownerId).Startswith(Social_StreamingUtil.USER_ID) && Social_StreamingUtil.SLA1_ENDED.equalsIgnoreCase(associatedCaseList[0].Current_SLA_Phase__c)){                                                                          
                             associatedCaseList[0].Current_SLA_Phase__c = Social_StreamingUtil.SLA2_INITIATED;
                             associatedCaseList[0].Second_SLA_Scheduled_Time__c = system.Now().addMinutes(60);
                             associatedCaseList[0].Second_SLA_Start_Time__c  = system.now();
                             insertEvents(associatedCaseList[0]);                             
                        }                        
                   }
                }                 
                caseListToUpdate.add(associatedCaseList[0]);                
            /******* IF CASE IS Closed *******/    
            } else {    
                /******* IF CASE IS A BUSINESS CLOSED CASE *******/
                if(associatedCaseList[0].RecordTypeId == SYSTEM.LABEL.Business_Closed_RT ){
                    diff = decimal.valueof((System.Now().getTime() - associatedCaseList[0].ClosedDate.getTime())/(60*60));
                    hours =(diff /1000);   
                    //Block of code specific to Business case reopen.                             
                    if(hours < = Double.ValueOf(SYSTEM.LABEL.Case_Reopen_Duration)){
                        ownerDetail = ownerDetails(associatedCaseList[0]);
                        if( !ownerDetail.isEmpty()){                
                           if(('Offline'.equalsIgnoreCase(ownerDetail[0].Availability__c) || 'Vacation'.equalsIgnoreCase(ownerDetail[0].Availability__c))&& String.valueOf(associatedCaseList[0].ownerId).Startswith(Social_StreamingUtil.USER_ID) ){
                                associatedCaseList[0].OwnerId = associatedCaseList[0].Track_Case_Queue__c;                                
                                isNewCase = true;
                           }
                           else{
                               isNewCase = false;
                            if(countDecCaseUserMap.containsKey(associatedCaseList[0].OwnerId)){
                                countDecCaseUserMap.get(associatedCaseList[0].OwnerId).add(associatedCaseList[0]);
                            }
                            else{
                                countDecCaseUserMap.put(associatedCaseList[0].OwnerId,New List<Case>{associatedCaseList[0]});
                            }
                           }
                        } 
                        if(isNewCase){                      
                            associatedCaseList[0].Update_Reason__c = Social_StreamingUtil.BUSINESS_ROUND_ROBIN;
                        }
                        else{
                            associatedCaseList[0].Update_Reason__c = Social_StreamingUtil.CASE_REOPENED;
                        }
                        associatedCaseList[0].ReadUnreadCheck__c = TRUE;
                        associatedCaseList[0].Status = Social_StreamingUtil.CASE_STATUS_REOPEN;
                        //Check Buisness care manager's availability, if manager is available then initate sla
                        if ((!'Offline'.equalsIgnoreCase(ownerDetail[0].Availability__c) ||!'Vacation'.equalsIgnoreCase(ownerDetail[0].Availability__c)) && String.valueOf(associatedCaseList[0].ownerId).Startswith(Social_StreamingUtil.USER_ID) && Social_StreamingUtil.SLA1_ENDED.equalsIgnoreCase(associatedCaseList[0].Current_SLA_Phase__c)){                                             
                             associatedCaseList[0].Current_SLA_Phase__c = Social_StreamingUtil.SLA2_INITIATED;
                             associatedCaseList[0].Second_SLA_Scheduled_Time__c = system.Now().addMinutes(60);
                             associatedCaseList[0].Second_SLA_Start_Time__c  = system.now();
                             insertEvents(associatedCaseList[0]);                             
                        }
                        post.R6Service__HarvestDate__c = post.HarvestDate;
                        post.R6Service__PostTags__c = post.PostTags;
                        post.Response_Context_External_Id__c = post.ResponseContextExternalId;
                        post.ParentId = associatedCaseList[0].Id;
                        post.WhoId = associatedCaseList[0].ContactId;
                        post.PersonaId = associatedCaseList[0].R6Service__SocialPersona__c;
                        post.R6Service__AuthorSocialHandle__c = socialPersonaList[0].Name;
                        post.R6Service__AuthorExternalId__c= socialPersonaList[0].ExternalId;
                        post.R6Service__SourceTags__c = post.SourceTags;
                        //Verify if inbound social post is a Reply to a comment in Facebook. Update the ReplyTo Lookup field such that the 
                        //SCS publisher points to the Parent comment of the Reply.
                        if(Social_StreamingUtil.MESSAGE_TYPE_REPLY.equalsIgnoreCase(post.MessageType) && Social_StreamingUtil.PROVIDER_FACEBOOK.equalsIgnoreCase(post.Provider) && post.ReplyTo == NULL ) {
                            post.ReplyToId = Social_SocialPostSCSHandler.inReplyToDetails(post);  
                        } 
                        reOpenCaseList.add(associatedCaseList[0]);
                        socialPostListInsert.add(post);
                        Social_StreamingUtil.insertSObject(socialPostListInsert,'Class:Social_SocialPostController Method:associatePosttoCase Consumer Case');
                        // add sla logic
                       if(countDecCaseUserMap.size()>0){
                            Social_BusinessRoundRobin.countUserCaseUpdate(countIncCaseUserMap ,countDecCaseUserMap,countCloseCaseUserMap);
                        }
                     } else {  
                          socialPersonaListInsert.add(socialPersonaList[0]);                       
                          createNewCase(socialPersonaList[0], post);
                          createPost(post);                         
                     }                   
                     
                 /******* IF CASE IS A CONSUMER CLOSED CASE *******/
                 } else if (associatedCaseList[0].RecordTypeId == System.Label.HS_Care_Rep_RT || associatedCaseList[0].RecordTypeId == System.Label.ConsumerCareCase || associatedCaseList[0].RecordTypeId == System.Label.ConsumerClosedCase_RT || associatedCaseList[0].RecordTypeId == System.Label.ConsumerQAClosedCase_RT) { // Block of code specific to Consumer case reopen
                     Set<String> traineeProfileSet = new Set<String>(System.Label.HS_Care_Rep_Profile_Id.split(';'));
                     //Check if case is discoverable or directed and case closed duration
                     if(Social_SocialPostSCSHandler.caseReopenCheck(associatedCaseList[0])){
                         if((post.PostTags != NULL && (post.PostTags.containsIgnoreCase('AUTODIR') || post.PostTags.containsIgnoreCase('MANUALDIR'))) || (post.MessageType.equalsIgnoreCase('Reply') || post.MessageType.equalsIgnoreCase('Direct Message') || post.MessageType.equalsIgnoreCase('Private Message'))){
                             associatedCaseList[0].Customer_Response_Received__c = true;
                         }
                         //If case owner is queue then update Customer response time and send the case back to original queue
                         if (String.valueOf(associatedCaseList[0].ownerId).Startswith(Social_StreamingUtil.QUEUE_ID)) {
                             associatedCaseList[0] = Social_SocialPostSCSHandler.caseUpdateCustomerResponseReceived(associatedCaseList[0]);
                             associatedCaseList[0].RecordTypeId = System.Label.ConsumerCareCase;
                         //If case owner is user then initate SLA for the user
                         } else if (string.valueOf(associatedCaseList[0].ownerId).Startswith(Social_StreamingUtil.USER_ID)) {
                             associatedCaseList[0].ReadUnreadCheck__c = TRUE;
                             //Adding the Owner Id of the case where owner is a user 
                             Set<Id> userIdSet = new Set<Id>();
                             userIdSet.add(associatedCaseList[0].OwnerId);
                             associatedCaseList[0].Customer_Response_Received_Time__c = system.now();
                             //Check care manager is availability, if manager is available then initate sla
                             String caseOnwerAvaibility = ownerDetails(associatedCaseList[0])[0].Availability__c;
                             if (!Social_StreamingUtil.USER_STATUS_VACATION.equalsIgnoreCase(caseOnwerAvaibility) && !Social_StreamingUtil.USER_STATUS_OFFLINE.equalsIgnoreCase(caseOnwerAvaibility) && associatedCaseList[0].Customer_Response_Received__c) {
                                 if(Social_StreamingUtil.SLA1_ENDED.equalsIgnoreCase(associatedCaseList[0].Current_SLA_Phase__c)){
                                     associatedCaseList[0].Current_SLA_Phase__c = Social_StreamingUtil.SLA2_INITIATED;
                                     associatedCaseList[0].Second_SLA_Scheduled_Time__c = system.Now().addMinutes(60);
                                     associatedCaseList[0].Second_SLA_Start_Time__c  = system.now();
                                     insertEvents(associatedCaseList[0]);
                                 }
                                 //To fetch User Details of the Owner
                                 if(!userIdSet.isEmpty() && userDetailMapForInboundHandler.values().isEmpty()){
                                      userDetailMapForInboundHandler = Social_GroupMemberHandler.userDetailMap(userIdSet);
                                 }
                                 //To flip the record type of the case if the assigned owner belongs Trainee Profile
                                 if(userDetailMapForInboundHandler.containsKey(associatedCaseList[0].ownerId) && traineeProfileSet.Contains(userDetailMapForInboundHandler.get(associatedCaseList[0].ownerId).profileId) && associatedCaseList[0].RecordTypeId != System.Label.HS_Care_Rep_RT){
                                     associatedCaseList[0].RecordTypeId = System.Label.HS_Care_Rep_RT;
                                 } else {
                                     associatedCaseList[0].RecordTypeId = System.Label.ConsumerCareCase;
                                 }
                                 //Add owner id to static set in order to update case counter on user
                                 Social_StreamingUtil.ownerIdSetForCaseCounter.add(associatedCaseList[0].ownerId);                                 
                             } else if((Social_StreamingUtil.USER_STATUS_VACATION.equalsIgnoreCase(caseOnwerAvaibility) || Social_StreamingUtil.USER_STATUS_OFFLINE.equalsIgnoreCase(caseOnwerAvaibility)) && associatedCaseList[0].Track_Case_Queue__c != null) {
                                 associatedCaseList[0].ownerId = associatedCaseList[0].Track_Case_Queue__c;
                                 associatedCaseList[0].RecordTypeId = System.Label.ConsumerCareCase;
                                 associatedCaseList[0].Case_Reassigned_Time__c = null;
                             }
                         }
                         post.R6Service__HarvestDate__c = post.HarvestDate;
                         post.Response_Context_External_Id__c = post.ResponseContextExternalId;
                         post.R6Service__PostTags__c = post.PostTags;
                         post.ParentId = associatedCaseList[0].Id;
                         post.WhoId = associatedCaseList[0].ContactId;
                         post.PersonaId = associatedCaseList[0].R6Service__SocialPersona__c;
                         post.R6Service__AuthorSocialHandle__c = socialPersonaList[0].Name;
                         post.R6Service__AuthorExternalId__c= socialPersonaList[0].ExternalId;       
                         post.R6Service__SourceTags__c = post.SourceTags;               
                         //Verify if inbound social post is a Reply to a comment in Facebook. Update the ReplyTo Lookup field such that the 
                         //SCS publisher points to the Parent comment of the Reply.
                         if(Social_StreamingUtil.MESSAGE_TYPE_REPLY.equalsIgnoreCase(post.MessageType) && Social_StreamingUtil.PROVIDER_FACEBOOK.equalsIgnoreCase(post.Provider) && post.ReplyTo == NULL ) {
                             post.ReplyToId = Social_SocialPostSCSHandler.inReplyToDetails(post);  
                         } 
                         associatedCaseList[0].Update_Reason__c = Social_StreamingUtil.CASE_REOPENED;
                         associatedCaseList[0].ReadUnreadCheck__c = TRUE;
                         associatedCaseList[0].Status = Social_StreamingUtil.CASE_STATUS_REOPEN;
                         associatedCaseList[0].Is_Auto_Closed__c = False;
                         associatedCaseList[0].No_Contact_Email_Available__c = False;
                         //Storing contact Id of case been reopened in order to update last case closed field on contact
                         if (associatedCaseList[0].contactId != Null) {
                             contactIdSet.add(associatedCaseList[0].contactId);
                         }
                         reOpenCaseList.add(associatedCaseList[0]);                  
                         socialPostListInsert.add(post);
                         Social_StreamingUtil.insertSObject(socialPostListInsert,'Class:Social_SocialPostController Method:associatePosttoCase Consumer Case');
                     //Create a new case, post
                     } else {
                         socialPersonaListInsert.add(socialPersonaList[0]); //adding exsiting social persona to the list.  
                         createNewCase(socialPersonaList[0], post);
                         createPost(post);
                     }                     
                 }              
            }
        } else {  
            socialPersonaListInsert.add(socialPersonaList[0]); //adding exsiting social persona to the list.  
            createNewCase(socialPersonaList[0], post);       
            createPost(post);                
        }
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        if (!reOpenCaseList.isEmpty()) {
              if(Social_StreamingUtil.fireAssignmentRule){
                Social_StreamingUtil.fireAssignmentRule = false;
                Database.DMLOptions dmo = new Database.DMLOptions();
                dmo.assignmentRuleHeader.useDefaultRule = true;
                Database.update(caseListToUpdate, dmo);
            } else {
                Social_StreamingUtil.updateSObject(reOpenCaseList,'Class:Social_SocialPostController Method:associatePosttoCase Consumer Case');
            }
        }
        if (!caseListToUpdate.isEmpty()) {
            if(Social_StreamingUtil.fireAssignmentRule){
                Social_StreamingUtil.fireAssignmentRule = false;
                Database.DMLOptions dmo = new Database.DMLOptions();
                dmo.assignmentRuleHeader.useDefaultRule = true;
                Database.update(caseListToUpdate, dmo);
            } else {
                Social_StreamingUtil.updateSObject(caseListToUpdate,'Class:Social_SocialPostController Method:associatePosttoCase Consumer Case');
            }
        }
        //Update Last Case Closed field on contact when a case is reopened
        if (!contactIdSet.isEmpty()) {
            Social_ContactLastClosedCaseController.updateContactOnCaseReopen(contactIdSet);
        }
        //DML to update case counte field on user record
        if (!Social_StreamingUtil.ownerIdSetForCaseCounter.isEmpty()) {
            social_caseCounterUserUpdate.updateCaseCounterUser(Social_StreamingUtil.ownerIdSetForCaseCounter);
        }
    } 
      
    /**
    * < updateCasewithPostId() - Method to populate the Initial Post field on case, once the first social post comes in>   
    * @param:
    *     List<Case> caseListInsert - Corresponding Salesforce social persona record for incoming social post.        
    *     SocialPost socialPostObj  - First social post
    *       
    * @return - void
    * @see - Social_SocialPostController (same class)
    */
    
    public void updateCasewithPostId(List<Case> caseListInsert, SocialPost socialPostObj){
        List<Case> updateCaseList = new List<Case>();
        if(caseListInsert[0].R6Service__InitialPostId__c == null){
            caseListInsert[0].R6Service__InitialPostId__c = socialPostObj.Id;
            updateCaseList.add(caseListInsert[0]);
        }
        if(!updateCaseList.isEmpty()){
            Social_StreamingUtil.updateSObject(updateCaseList,'Class:Social_SocialPostController Method:updateCasewithPostId');    
        }
    }
    
     /**
    * < dneDetails() - Method to populate DNE details on case record>   
    * @param:
    *     Id contactId - Id of contact record
    *       
    * @return - contactDetails
    * @see - Social_SocialPostController (same class)
    */
    
    Public List<Contact> dneDetails (Id contactId) {
        List<Contact> contactDetails = [Select id,DNE_Contact__c from contact where Id=:contactId];
        return contactDetails;
    }
    
   /**
    * < ownerDetails() - Method to fetch the Availability of case Owner>   
    * @param:
    *     Case singleCase - current case
    *       
    * @return - ownerDetails
    * @see - Social_SocialPostController (same class)
    */
    Public static List<User> ownerDetails (Case singleCase) {
        List<User> ownerDetails = [Select Id,Availability__c from User where Id =: singleCase.OwnerId];
        return ownerDetails;
    }    
    
    /**
    * < insertEvents() - Method to insert events>   
    * @param:
    *     Case singleCase - current case
    *       
    * @return - void
    * @see - Social_SocialPostController (same class)
    */
    
    Public static void insertEvents (case caseObj) {  
        List<Event> eventList = new List<Event>();       
        Event eventObj = new Event();
        eventObj.WhatId = caseObj.Id;
        eventObj.Event_Type__c = 'SLA - 2';
        eventObj.Event_Status__c = Social_StreamingUtil.EVENT_STATUS_OPEN;
        eventObj.Description = Social_StreamingUtil.EVENT_DESCRIPTION_SLA2;
        eventObj.OwnerId = caseObj.ownerId;
        eventObj.StartDateTime = caseObj.Second_SLA_Start_Time__c;
        eventObj.DurationInMinutes = 60;
        eventObj.IsReminderSet = false;
        eventObj.ReminderDateTime = caseObj.Second_SLA_Start_Time__c.addMinutes(45);
        eventObj.Subject = 'SLA - 2:' + caseObj.owner.Name + ':' + caseObj.caseNumber;
        eventList.add(eventObj);
        // ashween added the SLA2 events for BCS senior op manager
        if(caseObj.RecordTypeId == SYSTEM.LABEL.Business_Open_RT || caseObj.RecordTypeId == SYSTEM.LABEL.Business_Closed_RT) {
            Map<Id,Id> userManagerMap = new Map<Id,Id>();
            for(User endUser: [Select u.Name, u.ManagerId, u.Manager.Email, u.Id From User u where u.IsActive=true limit 10000]){    
                userManagerMap.put(endUser.Id, endUser.ManagerId);
            }
            if(userManagerMap.containsKey(caseObj.ownerId) && userManagerMap.get(caseObj.ownerId)!= NULL) {
                Event operationEvent = new Event();        
                operationEvent.WhatId = caseObj.Id;            
                operationEvent.Event_Status__c = Social_StreamingUtil.EVENT_STATUS_OPEN ;
                operationEvent.Description = Social_StreamingUtil.EVENT_DESCRIPTION_SLA2;
                operationEvent.OwnerId = userManagerMap.get(caseObj.ownerId);
                operationEvent.StartDateTime = caseObj.Second_SLA_Start_Time__c;
                operationEvent.DurationInMinutes = 60;
                operationEvent.IsReminderSet = true;
                operationEvent.ReminderDateTime = caseObj.Second_SLA_Start_Time__c.addMinutes(45);
                operationEvent.Subject = 'SLA - 2:' + caseObj.owner.Name + ':' +caseObj.caseNumber;        
                eventList.add(operationEvent); 
            } 
       } else {
            for (User userObj : [Select Id From User where Profile.Name = 'Operations Manager' and IsActive = True and Receive_SLA_Missed_Notification_Email__c = True]) {
                Event eventObjOM = new Event();
                eventObjOM.WhatId = caseObj.Id;
                eventObjOM.Event_Status__c = Social_StreamingUtil.EVENT_STATUS_OPEN;
                eventObjOM.Description = Social_StreamingUtil.EVENT_DESCRIPTION_SLA2;
                eventObjOM.OwnerId = userObj.Id;
                eventObjOM.StartDateTime = caseObj.Second_SLA_Start_Time__c;
                eventObjOM.DurationInMinutes = 60;
                eventObjOM.IsReminderSet = true;
                eventObjOM.ReminderDateTime = caseObj.Second_SLA_Start_Time__c.addMinutes(45);
                eventObjOM.Subject = 'SLA - 2:' + caseObj.owner.Name + ':' +caseObj.caseNumber;
                eventList.add(eventObjOM);
            }
        }
        if (!eventList.isEmpty()) {
            Social_StreamingUtil.doNotFireUpdateReason = false;
            Social_StreamingUtil.insertSObject(eventList,'Class:Social_SocialPostController Method:insertEvents. Failed to insert events. Case Number' + caseObj.caseNumber);
        }
    
    }
}