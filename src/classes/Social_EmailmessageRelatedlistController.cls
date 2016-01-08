/****

This class is used as a controller class for the VF page used
to display all the cases related to the case.

**/
public class Social_EmailmessageRelatedlistController{
    public string caseid{get;set;}
    public case mcase{get;set;}
    public list<emailmessage> lemsg{get;set;}
    public Integer pageSize{get;set;}
    public Integer noOfPages{get;set;}
    public Integer pageNumber{get;set;}
    Public Boolean displayPage{get;set;}//To hide page if there are no emails
    private String baseQuery = 'select id, parentid, status,FromName,FromAddress,MessageDate,Incoming,subject,ToAddress from Emailmessage where parentid=';
    private Integer totalNoOfRecs;

    /*** THis is the default controller class for the email message page used in the standard detail layout
    ***/
    public Social_EmailmessageRelatedlistController(ApexPages.StandardController controller) {       
        mcase=(Case)controller.getRecord();
        displayPage = true;
        caseid=mcase.id;
        pageSize = 4;
        totalNoOfRecs = [select count() from emailmessage where parentid=:mcase.id];
        if (totalNoOfRecs == 0) {
            displayPage = false;
        } else {
            getInitialemailSet();
        }
    }

    /** This method returns the initial set of records as per the pagesize ***/
    public PageReference getInitialemailSet(){
        pageNumber = 0;
        noOfPages = totalNoOfRecs/pageSize;
        if (Math.mod(totalNoOfRecs, pageSize) > 0)
            noOfPages++;
        try{
            lemsg = Database.query(baseQuery +'\''+caseid+'\''+ ' order by messagedate desc limit '+pageSize);
        }
        catch(Exception e){
            ApexPages.addMessages(e);
        }
        return null;
    }

    /** This method is used to navigate to the next set of records in the list ***/
    public PageReference next(){
        pageNumber++;
        queryemails();
        return null;
    }
    
    /** This method is used to navigate to the previous set of records in the list ***/
    public PageReference previous(){
        pageNumber--;
        if (pageNumber < 0){
        } else{  
        queryemails();}
        return null;
    }
    
    /** This method is used to get the records when the next or previous button is pressed on the VF page***/   
    private void queryemails(){
        Integer offset = pageNumber * pageSize;
        String query = baseQuery +'\''+caseid+'\'' +' order by messagedate desc limit '+pageSize +' offset '+ offset;
        System.debug('Query is'+query);
        try{
            lemsg = Database.query(query);
        }
        catch(Exception e){
            ApexPages.addMessages(e);
        }
    }
}