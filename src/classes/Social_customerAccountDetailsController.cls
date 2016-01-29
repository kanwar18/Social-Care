/*** 
 * Class Name: Social_customerAccountDetailsController
 * Author: Accenture
 * Date: 27-Jan-2016
 * Requirement/Project Name: Consumer - Social Care
 * Requirement Description: Controller to handle new customer account records insert/update.  
**/

public class Social_customerAccountDetailsController {
    public Customer_Account_Details__c cad {get;set;}    
    public boolean doNavigate{get;set;}  
    public string data{get;set;}  
    public boolean insertrecord{get;set;}
    public boolean checkemail;
    public boolean checktext;
    public boolean checkphone;
    Public static String cadIdString {get;set;}
    Public String contactFirstName{get;set;}
    Public String contactLastName{get;set;}
    Public Boolean newRecord{get;set;}
    public string pageBlockMode{get;set;}
    
    /**
    * < Social_customerAccountDetailsController() - Constructor>   
    */
    
    public Social_customerAccountDetailsController(ApexPages.StandardController controller) {
        cad = (Customer_Account_Details__c)controller.getRecord();
        cadIdString = '';
        insertrecord = false;
        if (ApexPages.currentPage().getParameters().get('isNew') != Null) {
            newRecord = Boolean.ValueOf(ApexPages.currentPage().getParameters().get('isNew'));
            contactFirstName = ApexPages.currentPage().getParameters().get('contactFirstName');
            contactLastName = ApexPages.currentPage().getParameters().get('contactLastName');
            cad.Contact_Id__c = ApexPages.currentPage().getParameters().get('contactId');
            pageBlockMode='New';
        } else {
            pageBlockMode='Edit';
            newRecord = false;
            contactFirstName = 'Customer Account Detail';
            if(cad.Account_Number__c == NULL && cad.Email_Id__c == NULL && cad.Phone__c != NULL ) {
                data = cad.Phone__c ;
            } else if(cad.Email_Id__c == NULL && cad.Phone__c == NULL && cad.Account_Number__c != NULL ) {
                data = cad.Account_Number__c ; 
            }else if(cad.Phone__c == NULL && cad.Account_Number__c == NULL && cad.Email_Id__c != NULL  ) {
                data = cad.Email_Id__c ; 
            }
        }
    }
    
    /**
    * < save() - Method to insert/update customer account detail records>
    * @param:
    *     
    * @return - PageReference (insert-->Contact Detail Page, update-->Customer Account Detail page)
    * @see -  (VF Page - Social_customerAccountDetails)   
    */
      
    public pagereference save() {         
        checkphone = Pattern.matches('[0-9]{10}',data);   
        checkemail = Pattern.matches('[a-zA-Z0-9._-]+@[a-zA-Z]+.[a-zA-Z]{2,4}', data);   
        checktext = Pattern.matches('[0-9]{1,15}',data);
        if (cad.Account_Type__c == Null || cad.Account_Type__c == '') {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Please select Account Type')); 
        }
        if(data==null || data.length() == 0 ) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Value field is mandatory'));
        }
        if(checkphone==true && (cad.Account_Type__c=='Home Phone'||cad.Account_Type__c=='Wireless CTN')){                      
            cad.Phone__c = data;
            cad.Email_Id__c = null;
            cad.Account_Number__c = null;  
            insertrecord = true; 
        } else if(checkphone == false && (cad.Account_Type__c == 'Home Phone'||cad.Account_Type__c == 'Wireless CTN')) {            
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter a valid 10 digits phone number.')); 
        } else if(checkemail==true && cad.Account_Type__c=='Email') {
            cad.Email_Id__c = data; 
            cad.Account_Number__c = null;
            cad.Phone__c = null;
            insertrecord = true; 
        } else if(checkemail==false && cad.Account_Type__c=='Email') {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Please enter a valid email address in the value field')); 
        } else if(checktext == true && (cad.Account_Type__c == 'U-Verse(BAN)'|| cad.Account_Type__c == 'DIRECTV' || cad.Account_Type__c == 'Wireless(BAN)')) {
            cad.Account_Number__c = data;
            cad.Phone__c = null;
            cad.Email_Id__c = null;
            insertrecord=true; 
        } else if(checktext == false && (cad.Account_Type__c == 'U-Verse(BAN)'|| cad.Account_Type__c == 'DIRECTV' || cad.Account_Type__c == 'Wireless(BAN)')) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter a valid account number upto 15 digits.'));  
        }
         else if(cad.Account_Type__c=='Forums Handle' && data!='')
        {
            cad.Phone__c = data;
            insertrecord=true;
        }
        
        if(insertrecord == true && newRecord == true) {
            insert cad;
            cadIdString = cad.Id;
            ID con;
            con=cad.Contact_Id__c;
            PageReference custPage =new PageReference('/'+con);
            custPage.setRedirect(true);   
            return custPage;                    
        } else if (insertrecord == true && newRecord == false) {
            update cad;
            PageReference conPage = new PageReference('/'+cad.Id);
            conPage.setRedirect(true);   
            return conPage; 
        }
        return null;
    }
    
    /**
    * < contactDetail() - Method return to previous page when cancel button is clicked>
    * @param:
    *     
    * @return - PageReference (insert-->Contact Detail Page, update-->Customer Account Detail page)
    * @see -  (VF Page - Social_customerAccountDetails)   
    */
    
    Public PageReference contactDetail() {
        if (newRecord) {
            PageReference conPage = new PageReference('/'+cad.Contact_Id__c);
            conPage.setRedirect(true);   
            return conPage;
        } else {
            PageReference conPage = new PageReference('/'+cad.Id);
            conPage.setRedirect(true);   
            return conPage;
        }
        return null;
    }
}