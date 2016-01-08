/* This class is used by the CSC_CaseHistoryExtension controller class and the CSC_caseHistory
 * Visualforce pages. The purpose is to hold heterogenous
 * sobject information that allows multiple types to be presented in a uniform manner.
 */
public class CSC_History {
 
    public CSC_SocialPost socPost { get; private set; }
    
    /* Properties of the class */
    public String messageType { get; private set; } // Passed in from the CSC_CaseHistoryExtension class
    public id i_d             { get; private set; }
    public String replyLink   { get; private set; }
    public datetime historydt   { get; private set; }
    public string actorname   { get; private set; }
    public string customTxt   { get; private set; }
    public string formattedCustomTxt { get {return customTxt.replaceAll('<','(').replaceAll('>',')').replaceAll('\n','<br/>'); } }
    public boolean isAttachment { get; private set; }
    public boolean isSocialPost { get; private set; }
    public String sendSuccess { get; private set; }
    public String sendErr     { get; private set; }
    public String escalateLink{get;private set;}
    public string purtyDateTime  { get { return historydt.format('M-d-yyyy h:mm:ss a'); } }
    
    /* Class constructor */
    public CSC_History(id i, DateTime d, String actor, String customText, String replyHTML, String strEscalationLink, String success, String errTxt, boolean attach, boolean social) {
        i_d         = i;
        historydt   = d;//.format('M-d-yyyy H:mm:ss');
        actorname   = actor;
        customTxt = customText;
        replyLink = replyHTML;
        sendSuccess = success;
        sendErr = errTxt;
        isAttachment = attach;
        isSocialPost = social;
        escalateLink = strEscalationLink;
        
    }
    
    /* Social Class constructor */
    public CSC_History(id i, DateTime d, String actor, String customText, String replyHTML, String strEscalationLink, String success, String errTxt, boolean attach, boolean social, CSC_SocialPost soPost) {
        i_d         = i;
        historydt   = d;//.format('M-d-yyyy H:mm:ss');
        actorname   = actor;
        customTxt = customText;
        replyLink = replyHTML;
        sendSuccess = success;
        sendErr = errTxt;
        isAttachment = attach;
        isSocialPost = social;
        socPost = soPost;
        escalateLink = strEscalationLink;
    }
    
}