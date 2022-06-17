/*******************************************************************************
* @Name         : OSF_OpportunitySummarizeBatchClass
* @Description  : Summarize Opportunity Stage
* @Created By   : Vyankatesh Chinche
* @Created Date : Jun 09, 2022
* @Modification Log :
********************************************************************************
* Version      Developer                Date        Description
*                                                       
*******************************************************************************/
global with sharing class OSF_OpportunitySummarizeBatchClass implements Database.Batchable<sObject>,Database.Stateful,Schedulable {
    public static final String Opp_Open = 'Open';
    public static final String Opp_CloseWon = 'Closed Won';
    public static final String Opp_CloseLost = 'Closed Lost';
    public static final String Opp_Amount = 'amt';
/*******************************************************************************
* @Name         : start
* @Description  : Retrive Opportunity data from  database.
* @Created By   : Vyankatesh Chinche
* @Created Date : Jun 09, 2022
*******************************************************************************/
    global Database.Querylocator start(Database.BatchableContext bc) {
        String Query = 'SELECT Id, Name FROM Account';
        return Database.getQuerylocator(Query);
    }
/*******************************************************************************
* @Name         : execute
* @Description  : Summarize Opportunity as Open,Close Won and Close Lost
* @Created By   : Vyankatesh Chinche
* @Created Date : Jun 09, 2022
*******************************************************************************/
    global void execute(Database.BatchableContext bc, List<Account> scope) { 
        try {
            Set<String> accId = new Set<String>();
            // Total Amount for Open, Close Won, Close Lost stages
            for (Account ac : scope) {
                accId.add(ac.Id);
            }
            AggregateResult[] agrOpen = [SELECT SUM(Amount)amt
                                         FROM Opportunity
                                         WHERE AccountId =: accId AND (StageName != 'Closed Won' AND StageName != 'Closed Lost')];
            AggregateResult[] agrCloseWon = [SELECT SUM(Amount)amt
                                             FROM Opportunity
                                             WHERE AccountId =: accId AND (StageName = 'Closed Won')];
            AggregateResult[] agrCloseLost = [SELECT SUM(Amount)amt
                                              FROM Opportunity
                                              WHERE AccountId =: accId AND (StageName = 'Closed Lost')];
            List<Contact> conList = [SELECT Owner.Email, Account.Name 
                                    FROM Contact
                                    WHERE AccountId =: accId And Is_Primary_Contact__c = true];
            // Send Mail to Account Primary Contact 
            for (Contact con : conList) {
                List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
                mail.setTargetObjectId(con.Id);
                mail.setSubject('SUMMARIZE OPPORTUNITY AMOUNT');
                String body = 'Below is a table of opportunities related to the account: '+con.Account.Name+'.<br/><br/><table border="1" style="border-collapse: collapse"><tr><th>Account</th><th>Stage</th><th>Amount</th></tr>';
                String accountName = con.Account.Name;
                Object openAmount = agrOpen[0].get(Opp_Amount);
                Object closeWonAmount = agrCloseWon[0].get(Opp_Amount);
                Object closeLostAmount = agrCloseLost[0].get(Opp_Amount);
                body += '<tr><td>' + accountName + '</td><td>' + Opp_Open + '</td><td>' + openAmount + '</td></tr>';
                body += '<tr><td>' + accountName + '</td><td>' + Opp_CloseWon + '</td><td>' + closeWonAmount + '</td></tr>';
                body += '<tr><td>' + accountName + '</td><td>' + Opp_CloseLost + '</td><td>' + closeLostAmount + '</td></tr>';
                body += '</table>';
                mail.setHtmlBody(body);
                mails.add(mail);
                Messaging.sendEmail(mails);
            }
        } catch(Exception e) {
            System.debug('Exception :'+e.getMessage());
        }
    }
/*******************************************************************************
* @Name         : finish
* @Description  : execute post-processing operations.
* @Created By   : Vyankatesh Chinche
* @Created Date : Jun 09, 2022
*******************************************************************************/
    global void finish(Database.BatchableContext bc) { 
        
    }
/*******************************************************************************
* @Name         : execute
* @Description  : Implements the Schedulableinterface
* @Created By   : Vyankatesh Chinche
* @Created Date : Jun 09, 2022
* @newcontact  SchedulableContext  implements the Schedulableinterface
*******************************************************************************/
    global void execute(SchedulableContext SC) {
    } 
}