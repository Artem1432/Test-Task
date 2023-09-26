public with sharing class ChangeOutgoingNameController {
    
    @AuraEnabled(cacheable=true)
    public static User getUserData(){
        return [
            SELECT
                Name,
                SenderName
            FROM User
            WHERE Id = :UserInfo.getUserId()
            WITH USER_MODE
            LIMIT 1
        ];
    }

    @AuraEnabled
    public static void changeSenderName(String newName) {
        User currentUser = [
            SELECT Id 
            FROM User 
            WHERE Id = :UserInfo.getUserId()
            WITH USER_MODE
            LIMIT 1
        ];
        currentUser.SenderName = newName;
        Database.update(currentUser, AccessLevel.USER_MODE);
    }

}