public class CSC_SocialPost {
 public CSC_SocialPost(){}
 
    public id i_d             { get; private set; }
    public String msgType { get; private set; } 
    public String srcTags;
    public String getSrcTags() {
        if (srcTags==null || srcTags=='') {
            return '';
        } else {
            if ((srcTags.trim()).equals('Influencer High') || (srcTags.trim()).equals('Influencer Medium') || (srcTags.trim()).equals('Influencer Low')) { 
             return srcTags;
            } else { 
                return '';
            }
        }
    }
    public void setSrcTags(String s1) {
        srcTags = s1;
    } 
    public String pstTags;
    public String getPstTags() {
        if(pstTags == null || pstTags =='')
            return '';
        else
            return pstTags;
    }
    public void setPstTags(String pt) {
        pstTags = pt;
    } 
    public String postURL { get; private set; } 
    public SocialPersona socialPeep { get; public set; }
    public String name  { get; private set; }
    public String handle { get; private set; }
    public String formattedAvatar;
    public String headln { get; private set; }
    public String cont { get; private set; }
    /*switchable */
    public String mediaProvider { get; private set; } 
    /* dynamic */
    public String postPriority;
    public String getPostPriority() {
        if (postPriority != null)
            return postPriority;
        else
            return '';
    }
    public void setPostPriority(String s) {
        postPriority = s;
    }
    public String replyLink { get; private set; }
    public String sopoLink { get; private set; }
    public String sopeepLink { get; private set; }
    public String influencerLevel  { get; private set; }
    public String postTaggedAs  { get; private set; }

        
    public void setFormattedAvatar(String avatarUrl) { 
        formattedAvatar = avatarUrl;
    }
    
    public String getFormattedAvatar() {
        if(socialPeep.Id != null) {
            if(socialPeep.ExternalPictureURL != null || socialPeep.ExternalPictureURL != '') {
                if(socialPeep.ProfileUrl!= null || socialPeep.ProfileUrl!='')
                    return  '<a href="' + socialPeep.profileUrl + '" target="_blank">' + socialPeep.R6Service__Avatar__c + '</a>';
                else
                    return socialPeep.R6Service__Avatar__c;
            } else {
                if(socialPeep.ProfileUrl != null || socialPeep.ProfileUrl != '')
                    return  '<a href="' + socialPeep.profileUrl + '" target="_blank">' + socialPeep.R6Service__Avatar__c + '</a>';
                else
                    return socialPeep.R6Service__Avatar__c;
            }
        } else {
            return ''; 
        }
    }
    
    public String postedDate;
    public String getPostedDate() { 
        return postedDate;
    } 
    private void setPostedDate(DateTime d1) {
        postedDate = d1.format('MMM d, yyyy hh:mm a');
    }
        
    
    public CSC_SocialPost(id i, String priority, String mType, String sTag, String pTag, String provider, DateTime pDate, String pURL, String headline, String content, SocialPersona sp, String ur11, String url2) {
        i_d = i;
        postPriority = priority;
        msgType = mType;
        srcTags = sTag;
        pstTags = pTag;
        mediaProvider = provider;
        setPostedDate(pDate);
        postURL = pURL;
        socialPeep = sp;
        headln = headline;
        cont = content;
        sopoLink = ur11;
        sopeepLink = url2;
    } 

    public String getDateTimeSocialURL(){
        return postedDate;
    }  
}