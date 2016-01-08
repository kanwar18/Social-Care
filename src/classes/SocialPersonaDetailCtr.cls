/********************************************************************************************************
*    Author :     Accenture
*    Requirement: To display case related information like social post for facebook and twitter cases.
*    Version:     1.0
*    Created Date: 9th November 2015.
*    Requirement : ITS 1721
*********************************************************************************************************/

global with sharing class SocialPersonaDetailCtr {
  public   SocialPersona persona {get; set;}
  public   ExternalSocialAccount socialAccount {get; set;}

  public static SocialPersona personaST;
  public static ExternalSocialAccount socialAccountST;

  public Boolean error { get; set; } // CONFIRM ERROR FATAL INFO WARNING

  /**
   * Read the the selected listview filter parameters and create a where clause of it
   **/
  public String offset{
      get{
        if (offset == null){
          TimeZone tz =  UserInfo.getTimeZone();   
          Integer offsetNum =  tz.getOffset(System.now()) / 3600000  ;
          Boolean isNEg =  offsetNum < 0;      
            offsetNum = Math.abs(offsetNum);
            if ( offsetNum <10){
              offset = '0'+String.valueOf(offsetNum)+'00';
            }else{
              offset = String.valueOf(Math.floor(offsetNum/10))+'0'+String.valueOf(Math.mod(offsetNum,10));
            }
            if (isNEg )  offset ='-'+offset;
        }
          
        return offset;
      }
      set;
    }

    /**
     * Uses incoming Id to obtain oringinal SocialPersona
     *  if Social Post Id - uses authorId
     *  if Case Id - finds autor of first related socialpost
     * @param Social Post or Case id  Id
     * @return void
     **/
    private static void obtainPersonaOrSocialPersona(Id objId){

        list<SocialPost> lPosts;
        if (!String.isNotBlank(objId)) return;
            Id idValue = objId;
            Schema.SObjectType token = idValue.getSObjectType();
            Schema.DescribeSObjectResult dr = token.getDescribe();


 

        if (dr.getName()  == 'SocialPost'){
           lPosts = [SELECT Id,  PersonaId, Persona.ExternalId, Persona.Name, Parent.Name, Persona.RealName, Persona.ProfileUrl, OutboundSocialAccountId
            FROM SocialPost WHERE Id = :objId ];
        }else 
            if (dr.getName()  == 'Case'){
                list<Case> lc = [select Id , (Select id from Posts where isoutbound = false order by createdDate limit 1) from Case where id =: objId];
                if (!lc.isEmpty()){
                    lPosts = lc[0].Posts;
                    if ( ! lPosts.isEmpty() )
                      lPosts = [SELECT Id,  PersonaId, Persona.ExternalId, Persona.Name, Parent.Name, Persona.RealName, Persona.ProfileUrl, OutboundSocialAccountId, Provider
                      FROM SocialPost WHERE Id = :lPosts[0].Id limit 1];
                }
            }

        if (lPosts != null && !lPosts.isEmpty()){ 
            List<SocialPersona> l = [SELECT AreWeFollowing,Bio,CreatedById,CreatedDate,
                    ExternalId,ExternalPictureURL,Followers,Following,
                    Id,IsBlacklisted,IsDefault,IsDeleted,IsFollowingUs,
                    Klout,LastModifiedById,LastModifiedDate,ListedCount,
                    MediaProvider,MediaType,Name,NumberOfFriends,
                    NumberOfTweets,ParentId,ProfileType,ProfileUrl,Provider,
                    R6SourceId,RealName,SystemModstamp,TopicType,Parent.Name
                    FROM SocialPersona
                    WHERE Id = :lPosts[0].PersonaId LIMIT 1];
            if (!l.isEmpty()){
                personaST = l[0];
            }
            else{
                List<ExternalSocialAccount> esa = [SELECT Id, ExternalPictureURL, Provider, Username 
                                                    FROM ExternalSocialAccount 
                                                    WHERE Id = :lPosts[0].OutboundSocialAccountId Limit 1];
                
                if(!esa.isEmpty()){
                    socialAccountST = esa[0];
                }
            }
        }
    }


    public SocialPersonaDetailCtr() {

        error = false;
        String objId = ApexPages.currentPage().getParameters().get('id');

        //load instance variables to display SocialPersona header details
        obtainPersonaOrSocialPersona(objId);
        persona = personaST;
        socialAccount = socialAccountST;

 
    }


  /**
   * Returns all SocialPosts from persona 
   * @param Social Post or Case id  Id
   * @return List<SocialPost>
   **/
  @RemoteAction
    global static List<SocialPost> getPostHistory(String objId) {

      obtainPersonaOrSocialPersona(objId);

      List<SocialPost> result  = null;
        if ( personaST != null ){

            Map<Id,SocialPost> mp = new Map<Id,SocialPost>([Select Id from SocialPost where IsOutbound = false AND PersonaId =: personaST.Id]);
            result = [ SELECT Name, MessageType,Content,Handle, Posted, ParentId, Parent.Name,  
                        Provider,  PersonaId, TopicProfileName, IsOutbound, Persona.ExternalPictureURL, OutboundSocialAccount.ExternalPictureURL
                        FROM SocialPost
                        WHERE 
                            ( IsOutbound = false AND PersonaId =: personaST.Id ) 
                            OR 
                            ( IsOutbound = true AND ReplyToId in: mp.keySet() ) 
                        ORDER BY Posted DESC 
                        LIMIT 50000 ];
         }
         
         if ( socialAccountST != null ){

            Map<Id,SocialPost> mp = new Map<Id,SocialPost>([Select Id from SocialPost where IsOutbound = true AND OutboundSocialAccountId=: socialAccountST.Id]);
            result = [ SELECT Name, MessageType,Content,Handle, Posted, ParentId, Parent.Name,
                        Provider,  PersonaId, TopicProfileName, IsOutbound, Persona.ExternalPictureURL, OutboundSocialAccount.ExternalPictureURL
                        FROM SocialPost
                        WHERE 
                            ( IsOutbound = true AND OutboundSocialAccountId =: socialAccountST.Id) 
                            OR 
                            ( IsOutbound = false AND ReplyToId in: mp.keySet() ) 
                        ORDER BY Posted DESC 
                        LIMIT 50000 ];
         }

        return result;
    }


  /**
   * Returns all SocialPosts conversations initial posts from persona 
   * @param Social Post or Case id  Id
   * @return List<SocialPost>
   **/
  @RemoteAction
    global static List<SocialPost> getConversationsPosts(String objId) {
      
      obtainPersonaOrSocialPersona(objId);

      List<SocialPost> result = new List<SocialPost>();

        if ( personaST != null ){
        
            result = [SELECT Content,Handle,Provider,Headline,Id,ReplyToId, MessageType , 
                                  ParentId,Posted ,Persona.Name , Persona.ExternalPictureURL , 
                                  IsOutbound,  OutboundSocialAccount.MasterLabel ,  Parent.Name,
                  OutboundSocialAccount.ExternalPictureURL  , (select id from Replies ) 
                                FROM SocialPost 
                                WHERE PersonaId =:personaST.Id
                                AND ( ( MessageType ='Private' and ReplyToId != null  ) 
                                        or 
                                        ( ( MessageType not in ('Private','Reply') and ReplyToId = null  ))
                                    )
                                order by  Posted desc 
                                limit 50000];
        }else
          if ( socialAccountST != null ){
              result = [SELECT Content,Handle,Provider,Headline,Id,ReplyToId, MessageType , 
                                  ParentId,Posted ,Persona.Name , Persona.ExternalPictureURL , 
                                  IsOutbound,  OutboundSocialAccount.MasterLabel ,  Parent.Name,
                                  OutboundSocialAccount.ExternalPictureURL  , (select id from Replies ) 
                                FROM SocialPost 
                                WHERE OutboundSocialAccountId =:socialAccountST.Id
                                AND ReplyToId = null  
                                AND ResponseContextExternalId = null 
                                order by  Posted desc 
                                limit 50000];              
         }
    return  result;

    }

  /**
   * Returns all SocialPosts inside same thread of social conversation  
   * @param Social Post id  Id
   * @return List<SocialPost>
   **/
  @RemoteAction
  global static List<SocialPost> getThreadByPostId(String postId) {
 
      list<SocialPost> result = new list<SocialPost>();
      if (  ! String.isNotBlank(postId) )
                  return result;
      //search first post
      return getConversations(postId);
  }


 global static List<SocialPost> getConversations(Id postId){

    List<SocialPost> result = new List<SocialPost>();
    SocialPost firstPost;

    if (  String.isNotBlank(postId) )  {
      result = [  Select Content,Handle,Provider,Headline,Id,ReplyToId, MessageType , 
                  ParentId,Posted ,Persona.Name , Persona.ExternalPictureURL , 
                  IsOutbound,  OutboundSocialAccount.MasterLabel , Parent.Name,
                  OutboundSocialAccount.ExternalPictureURL ,
                  ResponseContextExternalId , ExternalPostId
            from SocialPost 
            where id =: postId];

      if (!result.isEmpty()){
        firstPost = result[0]; 
          while(firstPost.ResponseContextExternalId != null) {
            firstPost = [SELECT Content,Handle,Provider,Headline,Id,ReplyToId, MessageType , 
                    ParentId,Posted ,Persona.Name , Persona.ExternalPictureURL , 
                    IsOutbound,  OutboundSocialAccount.MasterLabel , Parent.Name,
                    OutboundSocialAccount.ExternalPictureURL, 
                    ResponseContextExternalId , ExternalPostId
                  FROM SocialPost 
                  WHERE ExternalPostId=:firstPost.ResponseContextExternalId];
          }

          result.addAll(getThreads(firstPost)); 
      }
    }


      return result;
    }
 

    /*
    * @description
    * @param    - list of SocialPost 
    *           - message type   
    *    returns  ordered list containing all replies to the incoming posts   
    * @return List<SocialPost>
    */
  global static List<SocialPost> getThreads( SocialPost fpost ){

    List<SocialPost> result = new List<SocialPost>();
    
      if (fpost != null && String.isNotBlank(fpost.ExternalPostId)){
          Id fPostId = fpost.Id;
          String fPostExternalPostId = fpost.ExternalPostId;
          Datetime fPostPosted = fpost.Posted;
          String dbQuery =   ' Select Id , ReplyToId, Content, Handle, MessageType , ParentId, Posted , '
                            +'  OutboundSocialAccount.ExternalPictureURL , '
                            +'  Persona.Name , Persona.ExternalPictureURL, IsOutbound, '
                            +'  OutboundSocialAccount.MasterLabel , Parent.Name, '
                            +'  ResponseContextExternalId , ExternalPostId, Provider '
                            +'  from SocialPost '
                            +'  where '
                            +'   ResponseContextExternalId  =: fPostExternalPostId   '
                            +'   and ExternalPostId  !=: fPostExternalPostId  '
                            +'   and Id  !=: fPostId  '
                            +'   and Posted >= :fPostPosted'
                            +'   order by Posted ';
                  if (fpost.Provider =='Facebook'){
                      dbQuery += (fpost.MessageType == 'Comment') ? ' desc ' :' asc ';
                  }else{
                      dbQuery +=  ' desc ';
                  }
                  dbQuery +='   limit 10000 ';

          for(SocialPost sp  : Database.query(dbQuery)){ 
            result.addAll(getThreads(sp  ));  

            result.add( sp);      
      }
    }
    return result;
  }



}