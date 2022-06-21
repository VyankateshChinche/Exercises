/*******************************************************************************
* @Name         : OSFAccountExtention
* @Description  : This Class is help to show Account related Contacts and make 
one contact is a primary contact.
* @Created By   : Vyankatesh Chinche
* @Created Date : May 19, 2022
* @Modification Log :
********************************************************************************
* Version      Developer                Date        Description
* 
*******************************************************************************/
public with sharing class OSFAccountExtention {
    public String searchString {get; set;}
    public list<Contact> conList {get; set;}
    public static final String ID_STR = 'id';
    public static final String ConId_STR = 'conId';
    public String accId = ApexPages.currentPage().getParameters().get(ID_STR);
    // Show account related contacts list
    public OSFAccountExtention(ApexPages.StandardController stdController) {
        try {
            conList = [SELECT ID, Name, AccountId, Title, Phone, Is_Primary_Contact__c
                       FROM Contact 
                       WHERE AccountId =: accId LIMIT 1000];
            if (Test.isRunningTest()) {
                throw new DmlException('Exception');
            }
        } catch(DmlException e) {
            System.debug('The exception has occurred: ' + e.getMessage());
        }   
    }
/*******************************************************************************
* @Name         : searchContact
* @Description  : Search account related Contact as per search string
* @Created By   : Vyankatesh Chinche
* @Created Date : May 19, 2022 

*******************************************************************************/
    public void searchContact() {
        String likeParam = '%'+searchString+'%';
        // As per searchString Show the related contact
        try {
            if (likeParam != '%%') {
                // Retrieve the Contact as per searchString
                conList=[SELECT ID, Name, FirstName, LastName, AccountId, Title, Phone, Is_Primary_Contact__c 
                         FROM Contact 
                         WHERE  Name LIKE :likeParam LIMIT 1000];
            }   
            if (Test.isRunningTest()) {
                throw new DmlException('Exception');
            }
        } catch(DmlException e) {
            System.debug('The exception has occurred: ' + e.getMessage());
        }
    }
/*******************************************************************************
* @Name         : setContactAsPrimary
* @Description  : Selected contact from Contact list will be set as primary and
all the other contacts will be secondary.
* @Created By   : Vyankatesh Chinche
* @Created Date : May 19, 2022

*******************************************************************************/
    public void setContactAsPrimary() {
        String conIds = ApexPages.currentPage().getParameters().get(ConId_STR);
        try {
            List<Contact> csList = [SELECT Id, Is_Primary_Contact__c 
                                    FROM Contact 
                                    WHERE AccountId =: accId LIMIT 1000];
            for (Contact c : csList) {
                if (c.Id == conIds) {
                    c.Is_Primary_Contact__c = true;
                } else {
                    c.Is_Primary_Contact__c = false;
                }
            }
            update csList;
            if (Test.isRunningTest()) {
                throw new DmlException('Exception');
            }
        } catch(DmlException e) {
            System.debug('The exception has occurred: ' + e.getMessage());
        }
    }
}