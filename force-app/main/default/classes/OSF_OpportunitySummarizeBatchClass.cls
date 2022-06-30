    /***************************************************************************
    * @Name         : OSF_OpportunitySummarizeBatchClass
    * @Description  : Summarize Opportunity Stage
    * @Created By   : Vyankatesh Chinche
    * @Created Date : Jun 09, 2022
    * @Modification Log :
    ****************************************************************************
    * Version      Developer                Date        Description
    *                                                       
    ***************************************************************************/
    global with sharing class OSF_OpportunitySummarizeBatchClass implements         Database.Batchable<sObject>,Database.Stateful,Schedulable {
        public static final String OPP_OPEN = 'Open';
        public static final String OPP_CLOSEWON = 'Closed Won';
        public static final String OPP_CLOSELOST = 'Closed Lost';
        public static final String OPP_AMOUNT = 'amt';
        public static final String STAGE_NAME = 'StageName';
        Decimal open = 0;
        Decimal closeWon;
        Decimal closedLost;
        Set<Id> conIds = new Set<Id>();
        List<AggregateResult> agrAmountResult;
        Map<Id, Decimal> mapOfOpenStage = new Map<Id,Decimal>();
        Map<Id, Decimal> mapOfCloseWon = new Map<Id,Decimal>();
        Map<Id, Decimal> mapOfCloseLost = new Map<Id,Decimal>();
    /***************************************************************************
    * @Name         : start
    * @Description  : Retrive Contact data from  database.
    * @Created By   : Vyankatesh Chinche
    * @Created Date : Jun 09, 2022
    * @Param  bc   Database.BatchableContext  Database BatchableContext.
    ***************************************************************************/
        global Database.Querylocator start(Database.BatchableContext bc) {
            String Query = 'SELECT Id, Name, Account.Name, AccountId FROM Contact WHERE Is_Primary_Contact__c = true';
            return Database.getQuerylocator(Query);
        }
    /***************************************************************************
    * @Name         : execute
    * @Description  : Summarize Opportunity as Open, Close Won and Close Lost
    * @Created By   : Vyankatesh Chinche
    * @Created Date : Jun 09, 2022
    * @Param  scope List<Contact> store List of Contacts.
    ***************************************************************************/
        global void execute(Database.BatchableContext bc, List<Contact> scope) { 
            try {
                for (Contact con : scope) {
                    conIds.add(con.AccountId);
                    }
                    agrAmountResult = [SELECT AccountId, StageName, SUM(Amount)amt
                    FROM Opportunity
                    WHERE AccountId =: conIds GROUP BY StageName,AccountId];
            } catch(Exception e) {
                    System.debug('Exception :'+e.getStackTraceString());
                }
        }
    /***************************************************************************
    * @Name         : finish
    * @Description  : Send email to Account Primary Contact.
    * @Created By   : Vyankatesh Chinche
    * @Created Date : Jun 09, 2022
    * @Param   bc Database.BatchableContext store Database BatchableContext.
    ***************************************************************************/
        global void finish(Database.BatchableContext bc) { 
            String accountName;
            String openAmountMail;
            String closeWonAmountMail;
            String closeLostAmountMail;
            List<Contact> conList = [SELECT Id, Account.Name, AccountId,        Is_Primary_Contact__c
            FROM Contact
            WHERE Is_Primary_Contact__c = true];
            for(Contact c : conList){
                accountName = c.Account.Name;
                for (AggregateResult agr : agrAmountResult) {
                    if (agr.get('AccountId') == c.AccountId) {
                        if (agr.get(Stage_Name) != OPP_CLOSEWON && agr.get      (Stage_Name)  != OPP_CLOSELOST ) {
                            open += (Decimal)agr.get(OPP_AMOUNT);
                        }
                        if (agr.get(Stage_Name) == OPP_CLOSEWON) {
                            closeWon = (Decimal)agr.get(OPP_AMOUNT);
                        }
                        if (agr.get(Stage_Name) == OPP_CLOSELOST) {
                        closedLost = (Decimal)agr.get(OPP_AMOUNT);
                        }
                    }
                    mapOfOpenStage.put(c.id, open);
                    mapOfCloseWon.put(c.id, closeWon);
                    mapOfCloseLost.put(c.id, closedLost);
                }
                open = 0;
                for ( Id aID : mapOfOpenStage.keySet()) {
                    if (mapOfOpenStage.get(c.Id) == 0) {
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
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(c.Id);
            mail.setSubject(Label.TitleString);
            String body =  Label.SubTitle+accountName+Label.Table_Header;
            body += '<tr><td>' + accountName + '</td><td>' + OPP_OPEN + '</td><td>' + openAmountMail + '</td></tr>';
            body += '<tr><td>' + accountName + '</td><td>' + OPP_CLOSEWON + '</td><td>' + closeWonAmountMail + '</td></tr>';
            body += '<tr><td>' + accountName + '</td><td>' + OPP_CLOSELOST + '</td><td>' + closeLostAmountMail + '</td></tr>';
            body += '</table>';
            mail.setHtmlBody(body);
            mails.add(mail);
            Messaging.sendEmail(mails);
            }
        }
    
    /***************************************************************************
    * @Name         : execute
    * @Description  : Implements the Schedulableinterface
    * @Created By   : Vyankatesh Chinche
    * @Created Date : Jun 09, 2022
    * @Param  SC   SchedulableContext  store Schedulable Context.
    ***************************************************************************/
        global void execute(SchedulableContext SC) {
        } 
    }