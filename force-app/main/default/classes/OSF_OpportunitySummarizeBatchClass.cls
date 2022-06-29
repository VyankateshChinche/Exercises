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
    public static final String Stage_Name = 'StageName';
    Map<Id, Decimal> mapOfOpenStage = new Map<Id,Decimal>();
    Map<Id, Decimal> mapOfCloseWon = new Map<Id,Decimal>();
    Map<Id, Decimal> mapOfCloseLost = new Map<Id,Decimal>();
    /*******************************************************************************
* @Name         : start
* @Description  : Retrive Contact data from  database.
* @Created By   : Vyankatesh Chinche
* @Created Date : Jun 09, 2022
* @Param  bc   Database.BatchableContext  Database BatchableContext.
*******************************************************************************/
    global Database.Querylocator start(Database.BatchableContext bc) {
        String Query = 'SELECT Id, Name, Account.Name, AccountId FROM Contact WHERE Is_Primary_Contact__c = true';
        return Database.getQuerylocator(Query);
    }
    /******************************************************************************
* @Name         : execute
* @Description  : Summarize Opportunity as Open, Close Won and Close Lost
* @Created By   : Vyankatesh Chinche
* @Created Date : Jun 09, 2022
* @Param  scope List<Contact> store List of Contacts.
*******************************************************************************/
    global void execute(Database.BatchableContext bc, List<Contact> scope) { 
        Decimal open = 0;
        Decimal closeWon;
        Decimal closedLost;
        try {
            for (Contact con : scope) {
                List<AggregateResult> agrOpen = [SELECT StageName, SUM(Amount)amt
                                                 FROM Opportunity
                                                 WHERE AccountId =: con.AccountId GROUP BY StageName];
                for (AggregateResult agr : agrOpen) {
                    if (agr.get(Stage_Name) != Opp_CloseWon && agr.get(Stage_Name)  != Opp_CloseLost ) {
                        open += (Decimal)agr.get(Opp_Amount);
                    }
                    if (agr.get(Stage_Name) == Opp_CloseWon) {
                        closeWon = (Decimal)agr.get(Opp_Amount);
                    }
                    if (agr.get(Stage_Name) == Opp_CloseLost) {
                        closedLost = (Decimal)agr.get(Opp_Amount);
                    }
                }
                mapOfOpenStage.put(con.Id, open);
                mapOfCloseWon.put(con.Id, closeWon);
                mapOfCloseLost.put(con.Id, closedLost);
                open = 0;
                closeWon = null;
                closedLost = null;
            } 
        } catch(Exception e) {
            System.debug('Exception :'+e.getStackTraceString());
        }
    }
    /*******************************************************************************
* @Name         : finish
* @Description  : Send email to Account Primary Contact.
* @Created By   : Vyankatesh Chinche
* @Created Date : Jun 09, 2022
* @Param   bc Database.BatchableContext store Database BatchableContext.
*******************************************************************************/
    global void finish(Database.BatchableContext bc) { 
        String accountName;
        String openAmountMail;
        String closeWonAmountMail;
        String closeLostAmountMail;
        List<Contact> conList = [SELECT Id, Account.Name, Is_Primary_Contact__c
                                 FROM Contact
                                 WHERE Is_Primary_Contact__c = true];
        for(Contact c : conList){
            for ( Id aID : mapOfOpenStage.keySet() ) {
                if(mapOfOpenStage.get(c.Id) == 0) {
                    openAmountMail = '';
                } else {
                    openAmountMail = String.valueOf(mapOfOpenStage.get(c.Id));
                }
                if (mapOfCloseWon.get(c.Id) == null) {
                    closeWonAmountMail = '';
                } else {
                    closeWonAmountMail = String.valueOf(mapOfCloseWon.get(c.Id));
                }
                if (mapOfCloseLost.get(c.Id) == null) {
                    closeLostAmountMail = '';
                } else {
                    closeLostAmountMail = String.valueOf(mapOfCloseLost.get(c.Id));
                }
            }
            accountName = c.Account.Name;
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(c.Id);
            mail.setSubject(Label.TitleString);
            String body =  Label.SubTitle+accountName+Label.Table_Header;
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