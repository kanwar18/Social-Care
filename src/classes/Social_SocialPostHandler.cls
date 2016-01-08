/*** 
 * Class Name: Social_SocialPostHandler
 * Author: Accenture
 * Date: 20-Feb-2015
 * Requirement/Project Name: Business Care
 * Requirement Description: Handler for social customer service  
**/

global virtual class Social_SocialPostHandler implements Social.InboundSocialPostHandler {
    global Social.InboundSocialPostResult handleInboundSocialPost(SocialPost post, SocialPersona author, Map<String, Object> data) {   
        Social_SocialPostController socialPostHandler = new Social_SocialPostController();
        Social.InboundSocialPostResult result = socialPostHandler.inboundSocialPost(post,author,data);
        return result;
    }
}