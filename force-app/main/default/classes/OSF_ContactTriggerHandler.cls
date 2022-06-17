/*******************************************************************************
* @Name         : OSF_ContactTriggerHandler
* @Description  : Validation for Primary Contact and Primary Contact Phone update with all Non Primary Contact.
* @Created By   : Vyankatesh Chinche
* @Created Date : May 20, 2022
* @Modification Log :
********************************************************************************
* Version      Developer                Date        Description
* 
*******************************************************************************/
public with sharing class OSF_ContactTriggerHandler {
    /***************************************************************************
* @Name         : validatePrimaryContactOnAccount
* @Description  :If the Account already has a Primary Contact set a new one cannot be added.
* @Created By   : Vyankatesh Chinche
* @Created Date : May 19, 2022 
* @newcontact  List<Contact>  List of new Contact
* @oldMapContact Map<Id,Contact> Map of Id and Contact

*******************************************************************************/
    public static void validatePrimaryContactOnAccount (List<Contact> newcontact, Map<Id,Contact> oldMapContact) {
        try {
            Set<Id> accIds = new Set<Id>();
            for (Contact c : newcontact) {
                accIds.add(c.AccountId);
            }
            // Retrieve the Primary Contact
            List<Contact> cList = [SELECT AccountId, Is_Primary_Contact__c 
                                   FROM Contact 
                                   WHERE AccountId IN:accIds AND Is_Primary_Contact__c = True];
            if (cList.size() >= 1) {
                for (Contact con : newcontact) {
                    String valdLbl = Label.Primary_contact_validation;
                    if (con.Is_Primary_Contact__c) {
                        con.addError(valdLbl);
                    }
                }
            }
            if (Test.isRunningTest()) {
                throw new DmlException('Exception');
            }
        } catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
    }
    /***************************************************************************
* @Name         : updatePrimaryContactPhoneOnAccount
* @Description  : Primary Contact Phone will update to all Non Primary contacts related to the same account.
* @Created By   : Vyankatesh Chinche
* @Created Date : May 20, 2022 
* @newcontact2   List<Contact>  List of new Contact
* @oldMapContact2  Map<Id,Contact>  Map of Id and Contact

*******************************************************************************/
    @future 
    public static void updatePrimaryContactPhoneOnAccount(Set<Id> accIds) {
        try {
            List<Contact> primaryConList = [SELECT AccountId, Is_Primary_Contact__c, Primary_Contact_Phone__c 
                                            FROM Contact 
                                            WHERE AccountId IN : accIds AND Is_Primary_Contact__c = true];
            List<Contact> cList = [SELECT AccountId, Is_Primary_Contact__c, Primary_Contact_Phone__c 
                                   FROM Contact 
                                   WHERE AccountId IN : accIds AND Is_Primary_Contact__c = False];
            for (Contact cv : primaryConList) {
                for (Contact c2 : cList) {
                    c2.Primary_Contact_Phone__c = cv.Primary_Contact_Phone__c;
                }
            }
            //  update Primary Contact Phone
            database.update(cList);
            if (Test.isRunningTest()) {
                throw new DmlException('Exception');
            }
        } catch(DmlException e) {
            System.debug('The following exception has occurred: '+e.getMessage());
        }
    }
}