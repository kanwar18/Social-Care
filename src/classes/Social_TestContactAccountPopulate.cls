@isTest(SeeAllData=true)
private class Social_TestContactAccountPopulate {

  static testMethod void accountPopulate() {
    
    // Insert Contact
    Contact radianContact = new Contact();
    radianContact.LastName = 'lastName';
    radianContact.FirstName = 'firstName';
    radianContact.email = 'testemail@abc.com';
    insert radianContact;  
  }
}