/*******************************************************************************
* @Name         : OSF_OpportunitySummarizeBatchClass
* @Description  : Summarize Opportunity Stage
* @Created By   : Vyankatesh Chinche
* @Created Date : Jun 09, 2022
* @Modification Log :
********************************************************************************
* Version      Developer                Date        Description
* ------------------------------------------------------------------------------
*                                                      
*******************************************************************************/
global with sharing class OSF_OpportunitySummarizeBatchClass implements Database.Batchable<sObject>,Database.Stateful,Schedulable {
    public static final String OPP_OPEN = 'Open';
    public static final String OPP_CLOSEWON = 'Closed Won';
    public static final String OPP_CLOSELOST = 'Closed Lost';
    public static final String OPP_AMOUNT = 'amt';
    public static final String STAGE_NAME = 'StageName';
    Set<Id> conIds = new Set<Id>();
    List<StageAmount> stageAmountList = new List<StageAmount>();
    Map<Id, StageAmount> mapOfStageAmount = new Map<Id,StageAmount>();
    String openAmount;
    String closeWonAmount;
    String closeLostAmount;
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
            List<AggregateResult> agrAmountResult = [SELECT AccountId, StageName, SUM(Amount)amt
                                                     FROM Opportunity
                                                     WHERE AccountId =: conIds GROUP BY StageName,AccountId];
            for (Contact c : scope) {
                StageAmount sa = new StageAmount();
                sa.accountName = c.Account.Name;
                sa.conId = c.Id;
                for (AggregateResult agr : agrAmountResult) {
                    if (agr.get('AccountId') == c.AccountId) {
                        if (agr.get(Stage_Name) != OPP_CLOSEWON && agr.get (Stage_Name)  != OPP_CLOSELOST ) {
                            sa.openAmount += (Decimal)agr.get(OPP_AMOUNT);
                        }
                        if (agr.get(Stage_Name) == OPP_CLOSEWON) {
                            sa.closeWonAmount = (Decimal)agr.get(OPP_AMOUNT);
                        }
                        if (agr.get(Stage_Name) == OPP_CLOSELOST) {
                            sa.closeLostAmount = (Decimal)agr.get(OPP_AMOUNT);
                        }
                    }
                }
                stageAmountList.add(sa);
                mapOfStageAmount.put(c.Id, sa);
            }
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
        for (StageAmount stg : stageAmountList) {
            if (mapOfStageAmount.get(stg.conId).openAmount == 0) {
                openAmount = '';
            } else {
                openAmount = String.valueOf(mapOfStageAmount.get(stg.conId).openAmount);
            }
            if (mapOfStageAmount.get(stg.conId).closeWonAmount == null) {
                closeWonAmount = '';
            } else {
                closeWonAmount = String.valueOf(mapOfStageAmount.get(stg.conId).closeWonAmount);
            }
            if (mapOfStageAmount.get(stg.conId).closeLostAmount == null) {
                closeLostAmount = '';
            } else {
                closeLostAmount = String.valueOf(mapOfStageAmount.get(stg.conId).closeLostAmount);
            }
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(stg.conId);
            mail.setSubject(Label.TitleString);
            String body =  Label.SubTitle + mapOfStageAmount.get(stg.conId).accountName + Label.Table_Header;
            body += '<tr><td>' + mapOfStageAmount.get(stg.conId).accountName + '</td><td>' + OPP_OPEN + '</td><td>' + openAmount + '</td></tr>';
            body += '<tr><td>' + mapOfStageAmount.get(stg.conId).accountName + '</td><td>' + OPP_CLOSEWON + '</td><td>' + closeWonAmount + '</td></tr>';
            body += '<tr><td>' + mapOfStageAmount.get(stg.conId).accountName + '</td><td>' + OPP_CLOSELOST + '</td><td>' + closeLostAmount + '</td></tr>';
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
    class StageAmount {
        Id conId;
        Decimal openAmount = 0;
        Decimal closeWonAmount;
        Decimal closeLostAmount;
        String accountName;
    }
}