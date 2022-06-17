global with sharing class OSF_OpportunitySummarizeScheduler implements schedulable {
    global void execute(SchedulableContext sc) {
        OSF_OpportunitySummarizeBatchClass b = new OSF_OpportunitySummarizeBatchClass ();
        database.executebatch(b);
         /* String sch3 = '0 00 10 ? * * ';
         OSF_AccountBatchClass sqrb3 = new OSF_AccountBatchClass();
         system.schedule('Stage wise Opportunity Amount on Account', sch3, sqrb3);*/
    } 
}