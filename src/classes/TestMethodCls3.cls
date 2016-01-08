@isTest
private class TestMethodCls3 {

    static testMethod void myTest1() {

        // This code runs as the system user

        User u1;

        try{
          u1 = [select Id from User WHERE IsActive=True AND Profile.Name = 'System Administrator'  LIMIT 1];
        } catch (QueryException qe){

        List<User> users = [SELECT Id, Profile.PermissionsModifyAllData FROM User WHERE IsActive = true LIMIT 1000];

        for(User u : users){
            if(u.Profile.PermissionsModifyAllData = true){
              u1 = u;
              break;
        }
        }

        }

        System.debug(u1);

       //*****Create Queue 
       
       Group testGroup = new Group ();
       testGroup.Name = 'TestQueue1';
       testGroup.Type = 'Queue';
       insert testGroup;
       
       QueueSObject testQueue = new QueueSObject();
       testQueue.QueueId = testGroup.id;
       testQueue.SObjectType = 'Case';
       insert testQueue;

       // Second Queue       
       Group testGroup2 = new Group ();
       testGroup2.Name = 'TestQueue2';
       testGroup2.Type = 'Queue';
       insert testGroup2;
       
       QueueSObject testQueue2 = new QueueSObject();
       testQueue2.QueueId = testGroup2.id;
       testQueue2.SObjectType = 'Case';
       insert testQueue2;


       test.starttest();
        
        //Run test

        //Assign Case with out any Assignment Groups
        Case c1 = new Case (subject='testcase',tempOwnerID__c=testGroup2.id, OwnerID=u1.id); //tempOwnerID__c=testGroup2.id,  
        insert c1;
        update c1;
        
        
        //Create Assignment Group
        Assignment_Group_Name__c ag1 = new Assignment_Group_Name__c (Name='TestAG', Type__c = 'Case');
        insert ag1;

         
        //Add bad queue name
        Assignment_Group_Queues__c agqBad = new Assignment_Group_Queues__c(name='Bad Queue',Assignment_Group_Name__c = ag1.id );

        try {
            insert agqBad; 
        } catch (DmlException e){
             System.assert(e.getMessage().contains('CUSTOM_VALIDATION_EXCEPTION'), e.getMessage()); 
        
        } //catch

        test.stoptest();
        
    }
    
    static testMethod void myTest2() {

        // This code runs as the system user

        User u1;

        try{
          u1 = [select Id from User WHERE IsActive=True AND Profile.Name = 'System Administrator'  LIMIT 1];
        } catch (QueryException qe){

        List<User> users = [SELECT Id, Profile.PermissionsModifyAllData FROM User WHERE IsActive = true LIMIT 1000];

        for(User u : users){
            if(u.Profile.PermissionsModifyAllData = true){
              u1 = u;
              break;
        }
        }

        }

        System.debug(u1);

       //*****Create Queue 
       
       Group testGroup = new Group ();
       testGroup.Name = 'TestQueue1';
       testGroup.Type = 'Queue';
       insert testGroup;
       
       QueueSObject testQueue1 = new QueueSObject();
       testQueue1.QueueId = testGroup.id;
       testQueue1.SObjectType = 'Case';
       insert testQueue1;

       // Second Queue       
       Group testGroup2 = new Group ();
       testGroup2.Name = 'TestQueue2';
       testGroup2.Type = 'Queue';
       insert testGroup2;
       
       QueueSObject testQueue2 = new QueueSObject();
       testQueue2.QueueId = testGroup2.id;
       testQueue2.SObjectType = 'Case';
       insert testQueue2;


       test.starttest();
        
        //Run test
       
        
        //Create Assignment Group
        Assignment_Group_Name__c ag1 = new Assignment_Group_Name__c (Name='TestAG', Type__c = 'Case');
        insert ag1;        

        //Add Good Queue to Assignment Group
        Assignment_Group_Queues__c agq1 = new Assignment_Group_Queues__c(name=testGroup.Name ,Assignment_Group_Name__c = ag1.id );
        insert agq1;
        
        
        //Add User to Assignment Groups Users
        Assignment_Groups__c agu1 = new Assignment_Groups__c (User__c = u1.id, Active__c='True', Group_Name__c = ag1.id, Last_Assignment__c = datetime.valueOf('2009-01-01 21:13:24') );
        insert agu1;

        Case c2 = new Case (subject='testcase', tempOwnerID__c=testGroup2.id , OwnerID=testGroup.id); //Set owner ID to Queue
        insert c2;
        update c2;        

        test.stoptest();
        
    }

    static testMethod void myTest3() {

        // This code runs as the system user

        User u1;

        try{
          u1 = [select Id from User WHERE IsActive=True AND Profile.Name = 'System Administrator'  LIMIT 1];
        } catch (QueryException qe){

        List<User> users = [SELECT Id, Profile.PermissionsModifyAllData FROM User WHERE IsActive = true LIMIT 1000];

        for(User u : users){
            if(u.Profile.PermissionsModifyAllData = true){
              u1 = u;
              break;
        }
        }

        }

        System.debug(u1);

       //*****Create Queue 
       
       Group testGroup = new Group ();
       testGroup.Name = 'TestQueue1';
       testGroup.Type = 'Queue';
       insert testGroup;
       
       QueueSObject testQueue1 = new QueueSObject();
       testQueue1.QueueId = testGroup.id;
       testQueue1.SObjectType = 'Case';
       insert testQueue1;

       test.starttest();
        
        //Run test        
        
        //Create Assignment Group
        Assignment_Group_Name__c ag1 = new Assignment_Group_Name__c (Name='TestAG', Type__c = 'Case');
        insert ag1;        

        //Add Good Queue to Assignment Group
        Assignment_Group_Queues__c agq1 = new Assignment_Group_Queues__c(name=testGroup.Name ,Assignment_Group_Name__c = ag1.id );
        insert agq1;
        
        
        //Add User to Assignment Groups Users
        Assignment_Groups__c agu1 = new Assignment_Groups__c (User__c = u1.id, Active__c='True', Group_Name__c = ag1.id, Last_Assignment__c = datetime.valueOf('2009-01-01 21:13:24') );
        insert agu1;      
 
        Case c3 = new Case (subject='testcase', OwnerID=testGroup.id); //Set owner ID to Queue
        insert c3;
        update c3;

        test.stoptest();
        
    }

    static testMethod void myTest4() {

        // This code runs as the system user

        User u1;

        try{
          u1 = [select Id from User WHERE IsActive=True AND Profile.Name = 'System Administrator'  LIMIT 1];
        } catch (QueryException qe){

        List<User> users = [SELECT Id, Profile.PermissionsModifyAllData FROM User WHERE IsActive = true LIMIT 1000];

        for(User u : users){
            if(u.Profile.PermissionsModifyAllData = true){
              u1 = u;
              break;
        }
        }

        }

        System.debug(u1);

       //*****Create Queue 
       
       Group testGroup = new Group ();
       testGroup.Name = 'TestQueue1';
       testGroup.Type = 'Queue';
       insert testGroup;
       
       QueueSObject testQueue = new QueueSObject();
       testQueue.QueueId = testGroup.id;
       testQueue.SObjectType = 'Case';
       insert testQueue;
      

       test.starttest();
        
        //Run test

        //Create Assignment Group
        Assignment_Group_Name__c ag1 = new Assignment_Group_Name__c (Name='TestAG', Type__c = 'Case');
        insert ag1;        

        //Add Good Queue to Assignment Group
        Assignment_Group_Queues__c agq1 = new Assignment_Group_Queues__c(name=testGroup.Name ,Assignment_Group_Name__c = ag1.id );
        insert agq1;
        
          //Test for AG-Queues already assigned to another Assignment Group
        Assignment_Group_Queues__c agq2 = new Assignment_Group_Queues__c(name=testGroup.Name,Assignment_Group_Name__c = ag1.id );
        try {
            insert agq2;
        } catch (DmlException e){
             System.assert(e.getMessage().contains('CUSTOM_VALIDATION_EXCEPTION'), e.getMessage()); 
        } //catch

        test.stoptest();
        
    }
    
    static testMethod void myTest5 () {
        RecordTypeHelper.GetRecordTypeIdByDevName('cases','Consumer Care Case');
    }
}