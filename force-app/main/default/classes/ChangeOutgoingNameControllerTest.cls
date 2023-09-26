@isTest
private class ChangeOutgoingNameControllerTest {
    
    @TestSetup
    static void makeData(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'tuser', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, SenderName = 'Test 1',
            TimeZoneSidKey='America/Los_Angeles', UserName='testuser' + Datetime.now().getTime() + '@testorg.com');
        insert u;

        PermissionSet testTaskPemission = [
            SELECT Id
            FROM PermissionSet
            WHERE Name = 'Test_Task_Permission_Set'
        ];

        PermissionSetAssignment psa = new PermissionSetAssignment(
            PermissionSetId = testTaskPemission.Id, AssigneeId = u.Id
        );
        insert psa;
    }

    @IsTest
    static void testAll(){
        
        Test.startTest();
        System.runAs([
            SELECT Id
            FROM User
            WHERE Lastname = 'Testing'
        ][0]) {
            User u = ChangeOutgoingNameController.getUserData();
            System.assertEquals('Testing', u.Name);
            System.assertEquals('Test 1', u.SenderName);
            ChangeOutgoingNameController.changeSenderName('Test 2');
            u = ChangeOutgoingNameController.getUserData();
            System.assertEquals('Test 2', u.SenderName);
        }
        Test.stopTest();
        
    }

}