@isTest
public class OSF_OpportunitySummarize_TestClass {
    static testMethod void testMethod1() {
        List<Account> accList = [SELECT Id, Name FROM Account];
        Account a = new Account();
        a.Name = 'TestAcc';
        insert a;
        List<Opportunity> opList = new List<Opportunity>();
        Opportunity op = new Opportunity(Name = 'TestOpen',
                                         Amount = 100,
                                         CloseDate = system.today(),
                                         StageName = 'Prospecting');
        insert op;
        
        Opportunity op2 = new Opportunity(AccountId = a.Id,
                                          Name = 'TestCloseWon',
                                          Amount = 100,
                                          CloseDate = system.today(),
                                          StageName = 'Closed Won');
        insert op2;
        Opportunity op3 = new Opportunity(AccountId = a.Id,
                                          Name = 'TestCloseWon',
                                          Amount = 100,
                                          CloseDate = system.today(),
                                          StageName = 'Closed Lost');
        insert op3;
        Test.StartTest();
        OSF_OpportunitySummarizeBatchClass b = new OSF_OpportunitySummarizeBatchClass ();
        database.executebatch(b);
        Test.StopTest();
    }
}