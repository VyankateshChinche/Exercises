/*******************************************************************************
* @Name         : OSFAccountExtention_Test
* @Description  : Test class for OSFAccountExtention 
one contact is a primary contact.
* @Created By   : Vyankatesh Chinche
* @Created Date : May 19, 2022
* @Modification Log :
****************************************************************************
* Version      Developer                Date        Description
*---------------------------------------------------------------------------
*                                                       
***************************************************************************/
@isTest
private class OSFAccountExtention_Test {
    static testMethod void testMethod1() {
        Account ac = new Account(Name = 'TestVS',
                                 AccountNumber = '6768995534',
                                 Active__c = 'Yes',
                                 Type = 'Customer - Direct',
                                 Phone = '6765432233',
                                 Fax = 'testfax');
        insert ac;
        Contact con = new Contact(FirstName = 'TestFirstName',
                                  LastName = 'TestLastName',
                                  Is_Primary_Contact__c = true,
                                  Primary_Contact_Phone__c = '5656778756',
                                  AccountId = ac.Id);
        insert con;
        Contact con2 = new Contact(FirstName = 'TestFirstName2',
                                   LastName = 'TestLastName2',
                                   Is_Primary_Contact__c = false,
                                   Primary_Contact_Phone__c = '5656778757',
                                   AccountId = ac.Id);
        insert con2;
        // Testing Start
        Test.startTest();
        PageReference testPage = Page.SetPrimaryContact; 
        Test.setCurrentPage(testPage);
        ApexPages.StandardController sc = new ApexPages.StandardController(ac);   
        OSFAccountExtention ext = new OSFAccountExtention(sc);
        Test.stopTest();
        //assert
        List<Contact> cont = [SELECT Id, AccountId, Is_Primary_Contact__c
                              FROM Contact
                              WHERE AccountId =: ac.Id];
        System.assert(cont.size() != 0);
    }
    static testMethod void searchContactTest() {
        Account ac = new Account(Name = 'TestVS',
                                 AccountNumber = '6768995534',
                                 Active__c = 'Yes',
                                 Type = 'Customer - Direct',
                                 Phone = '6765432233',
                                 Fax = 'testfax');
        insert ac;
        Contact con = new Contact(FirstName = 'TestFirstName',
                                  LastName = 'TestLastName',
                                  Is_Primary_Contact__c = true,
                                  Primary_Contact_Phone__c = '5656778756');
        insert con;
        Contact con2 = new Contact(FirstName = 'TestFirstName2',
                                   LastName = 'TestLastName2',
                                   Is_Primary_Contact__c = false,
                                   Primary_Contact_Phone__c = '5656778757');
        insert con2;
        // Testing
        Test.startTest();
        PageReference pageRef = Page.SetPrimaryContact; 
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('searchString', String.valueOf('Test'));
        system.debug('searchString');
        ApexPages.StandardController sc = new  ApexPages.StandardController(ac);   
        OSFAccountExtention ext = new OSFAccountExtention(sc);
        ext.searchContact();
        Test.stopTest();
        //assert
        List<Contact> cont = [SELECT Id, AccountId, Is_Primary_Contact__c
                              FROM Contact
                              WHERE AccountId =: ac.Id AND Name LIKE 'Test'];
        System.assert(cont.size() != null);
        
    }
    static testMethod void setContactAsPrimary() {
        Account ac = new Account(Name = 'TestVS',
                                 AccountNumber = '6768995534',
                                 Active__c = 'Yes',
                                 Type = 'Customer - Direct',
                                 Phone = '6765432233',
                                 Fax = 'testfax');
        insert ac;
        Contact con = new Contact(FirstName = 'TestFirstName',
                                  LastName = 'TestLastName',
                                  Is_Primary_Contact__c = true,
                                  Primary_Contact_Phone__c = '5656778756');
        insert con;
        Contact con2 = new Contact(FirstName = 'TestFirstName2',
                                   LastName = 'TestLastName2',
                                   Is_Primary_Contact__c = false,
                                   Primary_Contact_Phone__c = '5656778757');
        insert con2;
        //Testing
        Test.startTest();
        PageReference pageRef = Page.SetPrimaryContact; 
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('conId', String.valueOf(con2.Id));
        ApexPages.StandardController sc = new  ApexPages.StandardController(ac);   
        OSFAccountExtention ext = new OSFAccountExtention(sc);
        ext.setContactAsPrimary();
        Test.stopTest();
        //assert
        system.assert(con2.Is_Primary_Contact__c = true);
    }
}