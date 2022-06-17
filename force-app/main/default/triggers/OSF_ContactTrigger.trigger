trigger OSF_ContactTrigger on Contact (before insert,after update,after insert) {
    //if the Account already has a Primary Contact set a new one cannot be added.
    if (Trigger.Isbefore && Trigger.IsInsert) {
        OSF_ContactTriggerHandler.validatePrimaryContactOnAccount (Trigger.new,Trigger.oldMap);
    }
    //Primary Contact Phone update to all Contacts related to the same account.
    if (Trigger.IsAfter && Trigger.IsInsert || Trigger.IsUpdate) {
        Set<Id> accIds = new Set<Id>();
        for (Contact c : Trigger.new) {
            accIds.add(c.AccountId); 
        }
        if(System.IsBatch() == false && System.isFuture() == false){ 
            OSF_ContactTriggerHandler.updatePrimaryContactPhoneOnAccount
                (accIds);
        }
    }
}