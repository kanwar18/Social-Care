trigger Social_SocialPostTaskCreator on SocialPost (after insert, after update) {
//adding boolean flag to turn off the trigger when dynamically when batch job updates who id on social post
/*if (Social_StreamingUtil.doNtFireEmail2CaseRun) {
   // Trigger Variables 
   Set<Id> newCaseIdSet = new Set<Id>();
   Set<Id> oldCaseIdSet = new Set<Id>();
   Set<Id> caseIdSet =  new Set<Id>();
   Map<Id,List<SocialPost>> socialPostMap = new Map<Id,List<SocialPost>>();  // Map to store the List of Social Posts attached to a Case.
   boolean isRadianFlag = false;
   
   // Capture All Related Case Ids
   for(SocialPost customerPost: Trigger.new){
     
     // If Insert
     if(Trigger.isInsert){
        newCaseIdSet.add(customerPost.ParentId);
        caseIdSet.add(customerPost.ParentId);
     }
     // Code piece to update the Case Post Tag and the Initial Post Id along with Record type of case if need be
        if(customerPost.ParentId!=NULL && customerPost.R6Service__PostTags__c!=NULL && customerPost.Posted !=NULL){
            if(socialPostMap.containsKey(customerPost.ParentId)){
                socialPostMap.get(customerPost.ParentId).add(customerPost);            
            }
            else{
                socialPostMap.put(customerPost.ParentId, new List<SocialPost>{customerPost});
            }
        }
     // If Update
     else if(Trigger.isUpdate){
        
        // Check If the Parent Case Field has been Updated
        SocialPost oldPost = Trigger.oldMap.get(customerPost.Id);
        if(oldPost.ParentId!=null && customerPost.ParentId!=null && oldPost.ParentId!=customerPost.ParentId){

            // Add the New Case Id
            newCaseIdSet.add(customerPost.ParentId);
            
            // Add the Old Case Id
            oldCaseIdSet.add(oldPost.ParentId);
             // Code piece to update the Case Post Tag and the Initial Post Id along with Record type of case if need be
            if(customerPost.ParentId!=NULL && customerPost.R6Service__PostTags__c!=NULL && customerPost.Posted !=NULL){
                if(socialPostMap.containsKey(customerPost.ParentId)){
                socialPostMap.get(customerPost.ParentId).add(customerPost);            
                }
                else{
                    socialPostMap.put(customerPost.ParentId, new List<SocialPost>{customerPost});
                }
            }
        }
        caseIdSet.add(customerPost.ParentId);
     }
     //if(!isRadianFlag && (customerPost.LastModifiedById == '005E0000002G4RU')) {
       // isRadianFlag = true;
     //}
   } //end for new
   
   
    // Intialize Util Class
    Social_SocialPostTaskCreatorUtil postUtilClass = new Social_SocialPostTaskCreatorUtil(newCaseIdSet, oldCaseIdSet);
   
    // Task Creation Based On Social Posts
    for(SocialPost endUserPost:Trigger.new){
    
        // On Social Post Insert
        if(Trigger.isInsert) {
            postUtilClass.initiateSecondSla(endUserPost, true);
        }
        
        // On Social Post Update
        else if(Trigger.isUpdate){
            
            // Check For Parent Case Id Update
            SocialPost oldPost = Trigger.oldMap.get(endUserPost.Id);
            if(oldPost.ParentId!=null && endUserPost.ParentId!=null && oldPost.ParentId!=endUserPost.ParentId){
                // Second SLA for Updated Case
                postUtilClass.initiateSecondSla(endUserPost, false);
                
                // Reset SLA Fields/Event Delete On Older Case
                postUtilClass.resetSecondSla(oldPost.ParentId);
            }
       }
       
   }
    
    
    
    // DataBase Transactions
    postUtilClass.performDatabaseUpdates();
    
    if(socialPostMap.keyset().size()>0){
        Social_ClosedCaseReOpenHandler.copySocialPostDetails(socialPostMap);
    }

    //Track Social Post insert or Update on a Case
    Map<Id, String> caseMap =  new Map<Id, String>();
    for(SocialPost post : Trigger.new){
        if(Trigger.isInsert){
            caseMap.put(post.ParentId, 'Insert');
        }
        if(Trigger.isUpdate){
            caseMap.put(post.ParentId, 'Update');
        }
    }
    if(caseMap!=null && !caseMap.isEmpty()){
        SocialStreamingAPIUpdate.caseSocialPostInsertUpdate(caseMap);
        //if(!isRadianFlag && (Boolean.valueOf(Label.ACTIVATE_TIMER_APP))) {
          //  TimeTrackHandler.updateTimerRecords(caseMap.keySet(), 'Social Post ' + (Trigger.isInsert ? 'Insert' : 'Update'));
        //}
    }
     
    //Code snippet to track the response from the Trainee Care Manager to Customer
    for(SocialPost post : Trigger.new){
        if(post.R6Service__IsOutbound__c && Trigger.isUpdate && post.StatusMessage!=null && (post.StatusMessage).equalsIgnoreCase('SENT') && post.R6Service__Status__c!=null && (post.R6Service__Status__c).equalsIgnoreCase('SENT')){
            try{
            Social_CareManagerResponse scmr =  new Social_CareManagerResponse();
            scmr.updateTraineeCareManagerResponse(post);
            }
            catch(Exception e){
                //
            }
        }
    }
}*/
 }