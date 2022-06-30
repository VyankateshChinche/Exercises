    /***************************************************************************
    * @Name         : OSF_OpportunitySummarizeTestClass
    * @Description  : Testing OSF_OpportunitySummarizeBatchClass class code coverage.
    * @Created By   : Vyankatesh Chinche
    * @Created Date : Jun 09, 2022
    * @Modification Log :
    ****************************************************************************
    * Version      Developer                Date        Description
    *                                                       
    ***************************************************************************/
    @isTest
    public class OSF_OpportunitySummarizeTestClass {
    
    /***************************************************************************
    * @Name         : testMethod1
    * @Description  : Test OSF_OpportunitySummarizeBatchClass Batch class
    * @Created By   : Vyankatesh Chinche
    * @Created Date : Jun 09, 2022
    * @Param  
    ***************************************************************************/
        static testMethod void testMethod1() {
            List<Contact> accList = [SELECT Id, Name, Account.Name, AccountId
                                 FROM Contact
                                 WHERE Is_Primary_Contact__c = true];
            Account a = new Account(Name = 'TestAcc');
            insert a;
            Account a2 = new Account( Name = 'TestAcc2');
            insert a2;
            Contact con = new Contact(LastName = 'TestCon',
                                  AccountId = a.Id,
                                  Email = 'vyankateshchinche18@gmail.com',
                                  Is_Primary_Contact__c = true);
            insert con;
        
            Contact con2 = new Contact(LastName = 'Testfree2',
                                   AccountId = a2.Id,
                                   Email = 'vyankateshchinche18@gmail.com',
                                   Is_Primary_Contact__c = true);
            insert con2;
            Opportunity op = new Opportunity(Name = 'TestOpen',
                                         Amount = 100,
                                         CloseDate = system.today(),
                                         AccountId = a.Id,
                                         StageName = 'Prospecting');
            insert op;
            Opportunity op2 = new Opportunity(Name = 'TestOpen2',
                                          Amount = 100,
                                          CloseDate = system.today(),
                                          AccountId = a.Id,
                                          StageName = 'Qualification');
            insert op2;
        
            Opportunity op3 = new Opportunity(Name = 'TestCloseWon',
                                          Amount = 100,
                                          AccountId = a2.Id,
                                          CloseDate = system.today(),
                                          StageName = 'Closed Won');
            insert op3;
            Opportunity op4 = new Opportunity(Name = 'TestCloseLost',
                                          Amount = 100,
                                          AccountId = a2.Id,
                                          CloseDate = system.today(),
                                          StageName = 'Closed Lost');
            insert op4;
            Test.StartTest();
            OSF_OpportunitySummarizeBatchClass b = new OSF_OpportunitySummarizeBatchClass ();
            database.executebatch(b);
            Test.StopTest();
        }
    }