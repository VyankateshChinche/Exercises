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
    object openAmount='';
    object closeWonAmount='';
    object closeLostAmount='';
    Set<String> accId = new Set<String>();
/*******************************************************************************
* @Name         : start
* @Description  : Retrive Opportunity data from  database.
* @Created By   : Vyankatesh Chinche
* @Created Date : Jun 09, 2022
* @Param  bc   Database.BatchableContext  Database BatchableContext.
*******************************************************************************/
    global Database.Querylocator start(Database.BatchableContext bc) {
        String Query = 'SELECT Id, Name FROM Account';
        return Database.getQuerylocator(Query);
    }
 /******************************************************************************
* @Name         : execute
* @Description  : Summarize Opportunity as Open,Close Won and Close Lost
* @Created By   : Vyankatesh Chinche
* @Created Date : Jun 09, 2022
* @Param  scope List<Account> store List of accounts.
*******************************************************************************/
    global void execute(Database.BatchableContext bc, List<Account> scope) { 
        try {
            // Total Amount for Open, Close Won, Close Lost stages
            for (Account ac : scope) {
                accId.add(ac.Id);
            }
            AggregateResult[] agr = [SELECT StageName, SUM(Amount)amt
                                     FROM Opportunity
                                     WHERE Account.Id =: accId GROUP BY StageName];
            Decimal totalopenAmount = 0;
            for(Integer i=0;i<=(agr.size());i++){
                // Close Lost
                if(i == (agr.size() - 1)){
                    closeLostAmount = (Decimal)agr[i].get(Opp_Amount);
                }
                if((agr.size()) < 3){
                    closeLostAmount = '';
                }
                //Close Won
                if(i == (agr.size() - 2)){
                    closeWonAmount = (Decimal)agr[i].get(Opp_Amount);
                }
                if((agr.size()) < 3){
                    closeWonAmount = (Decimal)agr[1].get(Opp_Amount);
                }
                // Open
                if(i <= (agr.size() - 3)){
                    totalopenAmount += (Decimal)agr[i].get(Opp_Amount);
                }
                if((agr.size()) < 3){
                    totalopenAmount = (Decimal)agr[0].get(Opp_Amount);
                }
            }
            openAmount = totalopenAmount;
        } catch(Exception e) {
            System.debug('Exception :'+e.getMessage());
        }
    }
/*******************************************************************************
* @Name         : finish
* @Description  : execute post-processing operations.
* @Created By   : Vyankatesh Chinche
* @Created Date : Jun 09, 2022
* @Param   bc Database.BatchableContext store Database BatchableContext.
*******************************************************************************/
    global void finish(Database.BatchableContext bc) { 
        List<Contact> conList = [SELECT Owner.Email, Account.Name 
                                 FROM Contact
                                 WHERE AccountId =: accId And Is_Primary_Contact__c = true];
        // Send Mail to Account Primary Contact 
        for (Contact con : conList) {
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(con.Id);
            mail.setSubject(Label.TitleString);
            String accountName = con.Account.Name;
            String openAmountMail = '';
            String closeWonAmountMail = '';
            String closeLostAmountMail = '';
            if(openAmount != null){
                openAmountMail = String.valueOf(openAmount);
            }
            if(closeWonAmount != null){
                closeWonAmountMail = String.valueOf(closeWonAmount);
            }
            if(closeLostAmount != null){
                closeLostAmountMail = String.valueOf(closeLostAmount);
            }
            String body =  Label.SubTitle+con.Account.Name+Label.Table_Header;
            body += '<tr><td>' + accountName + '</td><td>' + Opp_Open + '</td><td>' + openAmountMail + '</td></tr>';
            body += '<tr><td>' + accountName + '</td><td>' + Opp_CloseWon + '</td><td>' + closeWonAmountMail + '</td></tr>';
            body += '<tr><td>' + accountName + '</td><td>' + Opp_CloseLost + '</td><td>' + closeLostAmountMail + '</td></tr>';
            body += '</table>';
            mail.setHtmlBody(body);
            mails.add(mail);
            Messaging.sendEmail(mails);
        }
    }
/*******************************************************************************
* @Name         : execute
* @Description  : Implements the Schedulableinterface
* @Created By   : Vyankatesh Chinche
* @Created Date : Jun 09, 2022
* @Param  SC   SchedulableContext  store Schedulable Context.
*******************************************************************************/
    global void execute(SchedulableContext SC) {
    } 
    
}