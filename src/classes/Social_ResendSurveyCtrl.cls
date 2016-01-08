/* Version History
Aug 20th 2013:ITS-000121
-- This class is used as a controller class for the resend Forsee url functionality. THis button also counts the number
   of resends.
   Deployment Date: 28th August 2013
*/


public class Social_ResendSurveyCtrl
{
public Id userId{get;set;}
public Forsee_Survey__c mforseesur { get; set;}// Forsee Survey object instance 
public boolean enablebutton{get;set;}// this variable used to enable or disable the forsee survey URL
Set<Id> caseIdSet = null;// Used to pass case id to generate new Forsee URL
public list<case> caseid{get;set;}// Used to store the case id for URL generation
public list<Forsee_survey__c> lforseesur=new list<Forsee_survey__c>();
private static final String VANITY_URL = Label.Vanity_URL; // this string is used to generate the Vanity URL
private static final String VANITY_PAGE = VANITY_URL + '/SocialMediaPage?noc='; // this string is used to generate the Vanity URL
list<Forsee_Survey__c> lFinalforseesur=new List<Forsee_Survey__c>();
Map<String,List<Forsee_Survey__c>> mForseeMap=new Map<String,List<Forsee_Survey__c>>();
LinkForce_Settings__c toggles=LinkForce_Settings__c.getInstance();// Custom setting for the count of surveys resent
public boolean errorflag{get;set;}
public string errormsg{get;set;}
public list<Forsee_Survey__C> lallforseesurvey=new list<Forsee_Survey__C>();
private static String resendSurveyEnabledProfiles = Label.Resend_Survey_Profile_Names;

public Social_ResendSurveyCtrl(ApexPages.StandardController controller)
    {
    errorflag=false;
    enablebutton=false;
    mforseesur=(Forsee_Survey__c)controller.getRecord();
    Profile singleProfile = [select name from Profile where Id =: Userinfo.getProfileId()];// To get the logged in User Profile id
        if(mforseesur.Number_of_Surveys_Resent__c==null)
        {
            mforseesur.Number_of_Surveys_Resent__c=0;
        }
            if(resendSurveyEnabledProfiles.contains(singleProfile.name) && (toggles.Resent_Survey_Limit__c > mforseesur.Number_of_Surveys_Resent__c))
            {
                   enablebutton=true;
            }
   caseid = [select id from case where casenumber=:mforseesur.Case_Number__c limit 1];    
            if(!(caseid.size()>0)) 
           { 
           enablebutton=false;
           }         
    }

// Method Used to Generate the Forsee Survey URL
  public void GenerateForseeURl()
{
 
 integer count=0;
 SocialCareForseeHandler socialCareHandler = new SocialCareForseeHandler();
 caseIdSet = new Set<Id>();
    if(mforseesur.Case_Number__c!=null)
     {  
       caseid = [select id from case where casenumber=:mforseesur.Case_Number__c limit 1];    
            if(caseid.size()>0) 
           { 
                caseidset.add(caseid[0].id);
                socialCareHandler.resend=true;
                socialCareHandler.generateForSeeUrls(caseIdSet);
            }
            
            else
            {
            errorflag=true;
            }
   }
    else
     {
         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Ensure that a Case id is Present on the Failed Forsee Survey'));
         return;
     }
 
    if(!errorflag)
    {
          lallforseesurvey=[select id,Vanity_URL__c,resent_survey__C,Number_of_Surveys_Resent__c from Forsee_Survey__c where  Case_Number__c=:mforseesur.Case_Number__c order by createddate desc];
   
            for(Forsee_survey__c singleForesee: [Select id,case_number__c,Vanity_URL__c, Number_of_Surveys_Resent__c,Resent_Survey__c from Forsee_Survey__c where Case_Number__c = :mforseesur.Case_Number__c and Resent_Survey__c=true  order by createddate desc]){
            if(mForseeMap.containsKey(singleForesee.case_number__c)){
                mForseeMap.get(singleForesee.case_number__c).add(singleForesee);          
            }
            else
            {
                mForseeMap.put(singleForesee.case_number__c,new List<Forsee_Survey__c>{singleForesee});
            }
         }

          for (String fieldName : mForseeMap.keySet()){ 
                for(Forsee_survey__c singleForesee: mForseeMap.get(fieldName)){
             
                    singleForeSee.Number_of_Surveys_Resent__c = mForseeMap.get(fieldName).size();
                    singleForeSee.Recent_Forsee_Survey__c= URL.getSalesforceBaseUrl().toExternalForm() + '/' + lallforseesurvey[0].id;
                    singleForeSee.Vanity_URL__c = VANITY_PAGE + lallforseesurvey[0].id ;
                    if(singleForeSee.id==lallforseesurvey[0].id)
                    {
                    singleForeSee.Recent_Forsee_Survey__c=null;
                    }
                    if(singleForeSee.id !=lallforseesurvey[0].id)
                    {
                    singleForeSee.Recent_Forsee_ID__c=lallforseesurvey[0].id;
                    singleForeSee.Survey_Expired__c=true;
                    singleForeSee.URL_Active__c=false;
                    }
                    lFinalforseesur.add(singleForeSee);
                }    
          }
   
   for(Forsee_survey__c origforsee:lallforseesurvey)
   {
   if(!origforsee.Resent_survey__c)
   {
    origforsee.Recent_Forsee_ID__c= lallforseesurvey[0].id;
    origforsee.Number_of_Surveys_Resent__c = lFinalforseesur[0].Number_of_Surveys_Resent__c;
    origforsee.Survey_Expired__c=true;
    origforsee.URL_Active__c=false;
    lFinalforseesur.add(origforsee);
   }
   }
   

         try
     {   
       update lFinalforseesur;
     }
    catch(Exception excep) {
            System.debug('Exception Caught from update:'+ excep.getMessage());
        }
  }
}   
}