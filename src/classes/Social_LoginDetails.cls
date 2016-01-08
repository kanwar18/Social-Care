public with sharing class Social_LoginDetails {

    public PageReference sendDetails() {
        sendEmailwithDetails();
        return null;
    }


    public Social_LoginDetails(){
    }

    public Messaging.EmailFileAttachment getProfileDetails(){
        List<Profile> profileList = [Select p.Name, p.Description From Profile p order by p.Name];
        String strHeader = 'PROFILE_NAME, SECURITY_SETTINGS \n';
        String strData = '';
        String strFinal = '';
        String strTotalRecords = '';
        if(profileList!=null && profileList.size()>0){ 
            for(Profile p: profileList){
                String strProfileName = '', strDescription = '';
                if(p.Name!=null){
                    strProfileName = p.Name;
                }
                if(p.Description!=null){
                    strDescription = p.Description;
                }
                strData = strData + strProfileName + ',' + strDescription +'\n';
            }
            Integer count = profileList.size()+2;
            strTotalRecords = 'TotalRecords,'+count+',UADM USER PROFILE DATA STANDARD 2.2';
        }
        strFinal = strHeader + strData + strTotalRecords;

        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        blob csvBlob = Blob.valueOf(strFinal);
        String csvname= 'ServiceCloud_Profile_'+System.now().format('yyyyMMdd')+'.csv';
        csvAttc.setFileName(csvname);
        csvAttc.setBody(csvBlob);

        return csvAttc;
    }
    
    public Messaging.Emailfileattachment getUserDetails(){
        List<User> userDetailList = [Select u.EmployeeNumber, u.Username, u.LastPasswordChangeDate, u.LastName, u.LastModifiedDate, u.LastLoginDate, u.FirstName, u.Email, u.Agent_ID__c From User u where u.IsActive = true order by u.EmployeeNumber];
        String strHeader = 'CUID, AWID, APPLICATIONUSERID, FIRST_NAME, MIDDLE_INITIAL, LAST_NAME, LAST_LOGON_DATE, ACCOUNT_ACTIVATION_DATE, LAST_DATE_ACCOUNT_MODIFIED, LAST_PASSWORD_CHANGE_DATE, FULL_USER_NAME, NT_ID, EMAIL \n';
        String strData = '';
        String strFinal = '';
        String strTotalRecords = '';
        
        if(userDetailList!=null && userDetailList.size()>0){
            for(User u: userDetailList){
                String CUID = '', AWID='', APPLICATIONUSERID='', FIRST_NAME='', MIDDLE_INITIAL='', LAST_NAME='', LAST_LOGON_DATE='', ACCOUNT_ACTIVATION_DATE='', LAST_DATE_ACCOUNT_MODIFIED='', LAST_PASSWORD_CHANGE_DATE='', FULL_USER_NAME='', NT_ID='', EMAIL='';
                if(u.EmployeeNumber!=null && !(u.EmployeeNumber).equals('')){
                    CUID = u.EmployeeNumber;
                }
                else if((null == u.EmployeeNumber || (u.EmployeeNumber).equals('')) && u.Username!=null && ((u.Username).contains('att.com') || (u.Username).contains('accenture.com') )){
                    CUID = 'bm8477';
                }               
                if(u.Username!=null){
                    APPLICATIONUSERID = u.Username;
                }
                if(u.FirstName!=null){
                    FIRST_NAME = u.FirstName;
                }
                if(u.LastName!=null){
                    LAST_NAME = u.lastName;
                }
                if(u.LastLoginDate!=null){
                    LAST_LOGON_DATE = ''+u.LastLoginDate;
                }
                if(u.LastModifiedDate!=null){
                    LAST_DATE_ACCOUNT_MODIFIED = ''+u.LastModifiedDate;
                }
                if(u.LastPasswordChangeDate!=null){
                    LAST_PASSWORD_CHANGE_DATE = ''+u.LastPasswordChangeDate;
                }
                if(u.Username!=null){
                    FULL_USER_NAME = u.Username;
                }
                if(u.Email!=null){
                    EMAIL = u.Email;
                }
                
                strData = strData + CUID + ','+ AWID +','+ APPLICATIONUSERID +','+ FIRST_NAME +','+ MIDDLE_INITIAL +','+ LAST_NAME +','+ LAST_LOGON_DATE +','+ ACCOUNT_ACTIVATION_DATE +','+ LAST_DATE_ACCOUNT_MODIFIED +','+ LAST_PASSWORD_CHANGE_DATE +','+ FULL_USER_NAME +','+ NT_ID +','+ EMAIL+'\n';
            }
            Integer count = userDetailList.size()+2;
            strTotalRecords = 'TotalRecords,'+count+',UADM USER PROFILE DATA STANDARD 2.2';
        }
        
        strFinal = strHeader + strData + strTotalRecords;
        
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        blob csvBlob = Blob.valueOf(strFinal);
        String csvname= 'ServiceCloud_User_'+System.now().format('yyyyMMdd')+'.csv';
        csvAttc.setFileName(csvname);
        csvAttc.setBody(csvBlob);
        return csvAttc;
    }
    
    public Messaging.Emailfileattachment getUserProfileMappingDetails(){
        List<User> userDetailList = [Select u.EmployeeNumber, u.Username, u.Agent_ID__c, u.Profile.Name From User u where u.IsActive = true order by u.Profile.Name];
        String strHeader = 'CUID, AWID, APPLICATIONUSERID, PROFILE_NAME \n';
        String strData = '';
        String strFinal = '';
        String strTotalRecords = '', CUID='', AWID='', APPLICATIONUSERID='', PROFILE_NAME='';
        
        if(userDetailList!=null && userDetailList.size()>0){
            for(User u: userDetailList){
                if(u.EmployeeNumber!=null && !(u.EmployeeNumber).equals('')){
                    CUID = u.EmployeeNumber;
                }
                else if((null == u.EmployeeNumber || (u.EmployeeNumber).equals('')) && u.Username!=null && ((u.Username).contains('att.com') || (u.Username).contains('accenture.com') )){
                    CUID = 'bm8477';
                } 
                if(u.Username!=null){
                    APPLICATIONUSERID = u.Username;
                }
                if(u.Profile.Name!=null){
                    PROFILE_NAME = u.Profile.Name;
                }
                strData = strData + CUID + ',' + AWID + ',' + APPLICATIONUSERID + ',' + PROFILE_NAME + '\n';
            }
            Integer count = userDetailList.size()+2;
            strTotalRecords = 'TotalRecords,'+count+',UADM USER PROFILE DATA STANDARD 2.2';
        }
        strFinal = strHeader + strData + strTotalRecords;
        
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        blob csvBlob = Blob.valueOf(strFinal);
        String csvname= 'ServiceCloud_userprofiles_'+System.now().format('yyyyMMdd')+'.csv';
        csvAttc.setFileName(csvname);
        csvAttc.setBody(csvBlob);
        return csvAttc;
    }
    public void sendEmailwithDetails(){
        
        Messaging.EmailFileAttachment csvAttc1 = getProfileDetails();
        Messaging.EmailFileAttachment csvAttc2 =  getUserDetails();
        Messaging.EmailFileAttachment csvAttc3 =  getUserProfileMappingDetails();
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        List<User> userList = [Select u.Email From User u where u.isActive = true and u.MyLogin_Email_Notification__c = true];
        List<String> userEmailAddressList =  new List<String>();
        if(userList!=null && userList.size()>0){
            for(User u: userList){
                userEmailAddressList.add(u.Email);
            }
        }
        if(Label.Additional_MyLogin_ToEmails!=null && !(Label.Additional_MyLogin_ToEmails).equals('')){
                if((Label.Additional_MyLogin_ToEmails).contains(',')){
                    userEmailAddressList.addAll((Label.Additional_MyLogin_ToEmails).split(','));
                }
                else{
                    userEmailAddressList.add(Label.Additional_MyLogin_ToEmails);
                }
            }
        if(userList!=null && userList.size()>0){
            email.setToAddresses(userEmailAddressList);
        }
        String subject = 'MyLogin Details - '+System.now().format('MM/dd/yyyy');
        email.setSubject(subject);
        email.setReplyTo('attcustomercare@att.com');
        email.setSenderDisplayName('ATTCustomer Care');
        email.setPlainTextBody('Hello,\n\nPlease find attached.');
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc1, csvAttc2, csvAttc3});
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    }

}