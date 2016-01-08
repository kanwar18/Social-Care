/*
    Class to handle the responses from Trainee Care Managers to Customers 
*/
public class Social_CareManagerResponse {
    private final Custom_Post__c customPost;
    public String strTemp{get;set;}
    public boolean twitterBlock{get;set;}
    public boolean faceBookBlock{get;set;}
    public SocialPersona persona{get;set;}
    public String strMessage{get;set;} 
    public string customPostId{get;set;}
    public Social_CareManagerResponse(){
    }

   
    public Social_CareManagerResponse(ApexPages.StandardController controller) {
        try{
            twitterBlock = false;
            faceBookBlock = false;
            
            customPost =  new Custom_Post__c();
            List<SocialPost> spList =  new List<SocialPost>();
            SocialPost sp =  new SocialPost();
            sp = [Select id, parentId, PersonaId, Content, handle from SocialPost where id =: ApexPages.currentPage().getParameters().get('postId')];
            if(sp.PersonaId!=null){
                persona = [Select s.Name, s.R6Service__Avatar__c, s.R6Service__AvatarIconResource__c From SocialPersona s where s.id =: sp.PersonaId];
            }
            
            if(sp.parentId!=null){
                customPost.case__c = sp.parentId;
                customPost.Social_Persona__c = sp.PersonaId;
                customPost.social_post__c = sp.Id;
                customPost.Social_Post_Content__c = sp.Content;
                if(ApexPages.currentPage().getParameters().get('category')!=null && ApexPages.currentPage().getParameters().get('category').equalsIgnoreCase('twitter')){
                    String strTemp = '';
                    if(customPost.Message__c!=null){
                        strTemp = customPost.Message__c;
                    }
                    customPost.Message__c = '@'+sp.handle+strTemp;
                    strMessage = customPost.Message__c;
                }
            }
            if(ApexPages.currentPage().getParameters().get('category')!=null && !ApexPages.currentPage().getParameters().get('category').equals('')){
                if(ApexPages.currentPage().getParameters().get('category').equalsIgnoreCase('Twitter')){
                    twitterBlock = true;
                }
                else if(ApexPages.currentPage().getParameters().get('category').equalsIgnoreCase('facebook')){
                    faceBookBlock = true;
                }
                customPost.category__c = ApexPages.currentPage().getParameters().get('category');
            }
        }
        catch(Exception e){
            System.debug('Error :'+e);
        }
    }
    public Custom_Post__c getCustomPost(){
        return customPost;
    }
    
    public List<SelectOption> getSendAs(){
        List<SelectOption> optionsList = new List<SelectOption>();
        //String atttest= 'ATTCustomer';
        List<Social_Media_Account__c> socialMediaAccountList =  new List<Social_Media_Account__c>();
        for(Social_Media_Account__c singleAccount: [Select s.Social_Media_Handle_Name__c, s.IsDeleted From Social_Media_Account__c s where s.IsDeleted = false]){
            if(singleAccount.Social_Media_Handle_Name__c.startsWith('ATTCustomer')){
                socialMediaAccountList.add(singleAccount);
            }            
        }
        Map<String, String> uniqueMap =  new Map<String, String>();
        if(socialMediaAccountList!=null && socialMediaAccountList.size()>0 && customPost.category__c!=null && customPost.category__c.equalsIgnoreCase('twitter')){
            for(Social_Media_Account__c sma : socialMediaAccountList){
                optionsList.add(new SelectOption(sma.id, sma.Social_Media_Handle_Name__c)); 
            }
        }
        if(customPost.category__c!=null && customPost.category__c.equalsIgnoreCase('facebook')){
            if(customPost.case__c!=null){
                Case c = [Select ownerId from Case where id=: customPost.case__c];
                if(c.ownerId!=null && String.ValueOf(c.ownerId).equalsIgnoreCase(UserInfo.getUserId())){
                    optionsList.add(new SelectOption(UserInfo.getUserId(), UserInfo.getName()));
                }
                else{
                    optionsList.add(new SelectOption('', ''));
                }
            }
        }
        return optionsList;
    }
    
    public List<SelectOption> getFromEmailAddress(){
        List<SelectOption> optionsList = new List<SelectOption>();
            optionsList.add(new SelectOption('', ''));
        return optionsList;
    }

    public PageReference save() {
        insert customPost;
        customPostId = customPost.id;
        return null;
    }

    public boolean checkCustomPostExists(String socialPostId){
        boolean returnValue = true;
        List<Custom_Post__c> customPostList = [Select id from Custom_Post__c where (category__c = 'Twitter' OR category__c = 'Facebook') and Social_Post__c=: socialPostId and status__c <> 'Sent' ];
        if(customPostList!=null && customPostList.size()>0){
            returnValue = false;
        }
        return returnValue;
    }

    public void updateTraineeCareManagerResponse(SocialPost sp){
        if(sp.ParentId!=null){
            Custom_Post__c customPost = [Select id, Message_Type__c, Message__c, Replied_message__c, Status__c from Custom_Post__c where Case__c =: sp.ParentId and Status__c = 'Approved'];
            String strTemp = '';
            if(sp.MessageType!=null && !(sp.MessageType).equals('')){
                strTemp = sp.MessageType;
            }
            if(sp.Content!=null && !(sp.Content).equals('')){
                strTemp = strTemp + '\n\n' +sp.Content;
            }
            //Update Message, Status and Record Type
            customPost.Replied_message__c =  strTemp;
            customPost.Status__c = 'Sent';
            
            RecordType rType = [Select id from RecordType where name = :Label.Custom_Post_Sent_Record_Type];
            customPost.RecordTypeId = rType.id;
            try{
                update customPost;
            }
            catch(Exception e){
                System.debug('Error in updateTraineeCareManagerResponse '+e.getMessage());
            }
        }
    }
}